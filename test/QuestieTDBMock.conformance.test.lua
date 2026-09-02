dofile("setupTests.lua")

-- Mock-versus-provider conformance.
--
-- Every other Questie test runs against `test/QuestieTDBMock.lua`, a hand-written double of
-- `LibQuestieDB`. This file runs the double's behavioral cases a second time against the real
-- provider, loaded headless in Source mode from the QuestieTDB checkout, and asserts that both
-- report the same observations for the same inputs. When they disagree, the mock is wrong.
--
-- Each case is a function of the library under test; it reads real entity IDs from `FIXTURE`,
-- writes only under the owner it is handed, and returns a table of observations. The mock is
-- fresh per case and seeded from the provider's composed rows for the fixture IDs, so a read
-- of a fixture entity has the same answer on both sides unless the semantics differ.
--
-- The provider is loaded once per file. Its Correction registry is shared across cases, so
-- every write goes through recording wrappers and is withdrawn after each case; owner ranks
-- persist in the provider, which is why `OwnersOf` filters `GetOwners` to the case's owners.
--
-- Skipped, with the reason printed, when the checkout is absent. Point `QUESTIE_TDB_PATH` at
-- another checkout to run it elsewhere.
--
-- Deliberately not compared: the mock raises on an unknown field name and on a lowercase
-- datatype where the provider returns nil or accepts the spelling. Both are guards that can
-- only fail a test loudly, never hide a provider behavior, so the mock keeps them. Not modeled
-- at all: the provider's write-time normalization (constant fields dropped, a table refused on
-- a scalar field, `""` and `{0, 0}` reading nil). Questie tests seed normalized values.

local PROVIDER_PATH = os.getenv("QUESTIE_TDB_PATH") or "../Questie-toc/QuestieTDB"
local PROVIDER_TOC = PROVIDER_PATH .. "/QuestieTDB.toc"

local LoadQuestieTDBMock = dofile("test/QuestieTDBMock.lua")

-- Classic Era entities every case reads. Names are what the provider ships for them.
local FIXTURE = {
    Npc = {
        forestSpider = 30, -- "Forest Spider", Elwynn Forest (zone 12)
        gelvas = 14828, -- "Gelvas Grimegate", Darkmoon Faire, two spawn zones
        yebb = 14829, -- "Yebb Neblegear"
    },
    Object = {
        oldLionStatue = 31, -- "Old Lion Statue"
        silverleaf = 1617, -- "Silverleaf", shares its name with 3725
    },
    Quest = {
        sharptalonsClaw = 2, -- "Sharptalon's Claw"
        jittersGrowlingGut = 5, -- "Jitters' Growling Gut", no preQuestSingle
    },
    Item = {
        tinyIronKey = 5518, -- "Tiny Iron Key"
    },
}
-- Name-index cases enumerate every ID behind these names, so the fixture must carry them all.
local INDEXED_OBJECT_NAMES = {"Battered Chest", "Silverleaf", "Old Lion Statue"}

-- An ID no flavor ships, used for overlay-added entities.
local ABSENT_ID = 999999

local function ProviderCheckoutPresent()
    local file = io.open(PROVIDER_TOC, "r")
    if file then
        file:close()
        return true
    end
    return false
end

---Loads the provider in Source mode the way its own suite does, then restores every global the
---emulator replaced so the rest of this file, and the mock, keep Questie's test environment.
---@return table lib The provider's `LibQuestieDB`
local function LoadProvider()
    local snapshot = {}
    for key, value in pairs(_G) do
        snapshot[key] = value
    end
    -- The emulator writes into an existing `Enum` table in place; give it a fresh one so the
    -- restore below hands Questie's own back untouched.
    _G.Enum = nil

    local client = dofile(PROVIDER_PATH .. "/emulator/client.lua")
    local emulator = dofile(PROVIDER_PATH .. "/emulator/metadata.lua")
    client.reset()
    client.install({expansion = "Classic"})
    local lib = emulator.loadAddon(PROVIDER_TOC, "QuestieTDB", PROVIDER_PATH)

    for key in pairs(_G) do
        if snapshot[key] == nil then
            _G[key] = nil
        end
    end
    for key, value in pairs(snapshot) do
        _G[key] = value
    end
    return lib
end

---Every fixture ID per datatype, plus every Object behind the indexed names.
---@param provider table
---@return table<string, number[]>
local function FixtureIds(provider)
    local ids = {}
    for datatype, entries in pairs(FIXTURE) do
        ids[datatype] = {}
        for _, id in pairs(entries) do
            table.insert(ids[datatype], id)
        end
    end
    local seen = {}
    for _, id in ipairs(ids.Object) do
        seen[id] = true
    end
    for _, name in ipairs(INDEXED_OBJECT_NAMES) do
        for _, id in ipairs(provider.Object.IdsByName(name) or {}) do
            if not seen[id] then
                seen[id] = true
                table.insert(ids.Object, id)
            end
        end
    end
    return ids
end

---Seeds the mock's base rows from the provider's composed reads of the fixture entities.
---
---Only stored values are seeded: a number that reads as the provider's 0 default and a
---structure that reads as its `{}` default are left out, so the mock answers those reads through
---its own default rule rather than through the seed. Every seeded scalar must also read the same
---raw and composed, otherwise a provider-owned Dynamic Correction on a fixture entity would make
---the mock's `GetRaw` disagree for a reason that is a fixture choice, not a mock bug.
---@param mock QuestieTDBMock
---@param provider table
---@param ids table<string, number[]>
local function SeedMock(mock, provider, ids)
    local keysByDatatype = {
        Quest = provider.Meta.QuestMeta.questKeys,
        Npc = provider.Meta.NpcMeta.npcKeys,
        Item = provider.Meta.ItemMeta.itemKeys,
        Object = provider.Meta.ObjectMeta.objectKeys,
    }
    for datatype, list in pairs(ids) do
        for _, id in ipairs(list) do
            local row = {}
            for fieldName, fieldIndex in pairs(keysByDatatype[datatype]) do
                local value = provider[datatype].Get(id, fieldName)
                if type(value) ~= "table" then
                    assert(value == provider[datatype].GetRaw(id, fieldName),
                        ("fixture %s %d has a provider Correction on %s; pick another fixture entity"):format(datatype, id, fieldName))
                end
                local isDefault = value == 0 or (type(value) == "table" and next(value) == nil)
                if not isDefault then
                    row[fieldIndex] = value
                end
            end
            mock.SetBaseRow(datatype, id, row)
        end
    end
end

---Wraps the provider's write paths so every slot and function entry a case creates can be
---withdrawn afterwards. Returns the cleanup function.
---@param lib table
---@return fun() cleanup
local function RecordProviderWrites(lib)
    local slots, entries = {}, {}
    local originalSet = lib.Corrections.Set
    local originalGetRegistrar = lib.GetRegistrar

    lib.Corrections.Set = function(owner, datatype, name, rows)
        local changed = originalSet(owner, datatype, name, rows)
        if rows ~= nil then
            slots[owner .. "/" .. datatype .. "/" .. name] = {owner, datatype, name}
        end
        return changed
    end
    -- Questie writes through the `SetCorrection` alias; keep it pointing at the recorder.
    assert(lib.SetCorrection == originalSet, "the provider no longer aliases SetCorrection to Corrections.Set")
    lib.SetCorrection = lib.Corrections.Set

    lib.GetRegistrar = function(owner)
        local registrar = originalGetRegistrar(owner)
        local originalRegister = registrar.RegisterRuntimeCorrection
        registrar.RegisterRuntimeCorrection = function(datatype, name, provider, loadOrder)
            entries[owner .. "/" .. datatype .. "/" .. name] = {owner, datatype, name}
            return originalRegister(datatype, name, provider, loadOrder)
        end
        registrar.Set = function(datatype, name, rows)
            return lib.Corrections.Set(owner, datatype, name, rows)
        end
        return registrar
    end

    return function()
        lib.l10n.SetLocale("enUS")
        for key, slot in pairs(slots) do
            originalSet(slot[1], slot[2], slot[3], nil)
            slots[key] = nil
        end
        local touchedOwners = {}
        for key, entry in pairs(entries) do
            -- Registration is append-only, so a name registered twice needs two withdrawals.
            while lib.Corrections.UnregisterCorrection(entry[1], entry[2], entry[3]) do end
            touchedOwners[entry[1]] = true
            entries[key] = nil
        end
        for owner in pairs(touchedOwners) do
            lib.Corrections.ApplyRegisteredCorrections(owner)
        end
    end
end

---`GetOwners()` reduced to the base owner and the owners this case created, in rank order.
---@param lib table
---@param ownerPrefix string
---@return string[]
local function OwnersOf(lib, ownerPrefix)
    local owners = {}
    for _, owner in ipairs(lib.GetOwners()) do
        if owner == "QuestieTDB" or owner:sub(1, #ownerPrefix) == ownerPrefix then
            table.insert(owners, owner)
        end
    end
    return owners
end

---@param list number[]
---@return boolean
local function IsAscending(list)
    for i = 2, #list do
        if list[i - 1] >= list[i] then
            return false
        end
    end
    return true
end

describe("QuestieTDBMock conformance with LibQuestieDB", function()
    if not ProviderCheckoutPresent() then
        it("is skipped without the provider checkout", function()
            pending("QuestieTDB checkout not found at " .. PROVIDER_TOC .. "; set QUESTIE_TDB_PATH to run the conformance cases")
        end)
        return
    end

    local provider, cleanupProvider, fixtureIds
    ---@type QuestieTDBMock
    local mock
    local caseNumber = 0

    setup(function()
        provider = LoadProvider()
        cleanupProvider = RecordProviderWrites(provider)
        fixtureIds = FixtureIds(provider)
    end)

    before_each(function()
        mock = LoadQuestieTDBMock()
        SeedMock(mock, provider, fixtureIds)
        caseNumber = caseNumber + 1
    end)

    after_each(function()
        cleanupProvider()
    end)

    ---Runs one case against both libraries and asserts the observations agree. The provider's
    ---observations are returned so a test can pin a literal value on top and prove the case
    ---exercised what it claims.
    ---@param case fun(lib: table, owner: string): table
    ---@return table providerObservations
    local function Conform(case)
        -- The trailing colon keeps case 2 from matching case 20 in `OwnersOf`.
        local owner = ("Conformance%d:"):format(caseNumber)
        local fromMock = case(mock.lib, owner)
        local fromProvider = case(provider, owner)
        assert.are_same(fromProvider, fromMock)
        return fromProvider
    end

    describe("schema", function()
        it("carries the provider's Database Key Enums and field types", function()
            for _, metaName in ipairs({"QuestMeta", "NpcMeta", "ItemMeta", "ObjectMeta"}) do
                local keysName = metaName:sub(1, 1):lower() .. metaName:sub(2, -5) .. "Keys"
                assert.are_same(provider.Meta[metaName][keysName], mock.lib.Meta[metaName][keysName])
                assert.are_same(provider.Meta[metaName].types, mock.lib.Meta[metaName].types)
            end
        end)

        it("answers RequireContract(1) the same way", function()
            local seen = Conform(function(lib)
                local ok, message = lib.RequireContract(1)
                local nonNumeric = lib.RequireContract("1")
                return {ok = ok, message = message, nonNumeric = nonNumeric}
            end)
            assert.is_true(seen.ok)
        end)
    end)

    describe("entity reads", function()
        it("reads one field by name, by index, and through the named getter", function()
            local seen = Conform(function(lib)
                local npcKeys = lib.Meta.NpcMeta.npcKeys
                local id = FIXTURE.Npc.forestSpider
                return {
                    byName = lib.Npc.Get(id, "name"),
                    byIndex = lib.Npc.Get(id, npcKeys.name),
                    getter = lib.Npc.name(id),
                    zoneID = lib.Npc.zoneID(id),
                }
            end)
            assert.are_same("Forest Spider", seen.byName)
            assert.are_same(12, seen.zoneID)
        end)

        it("returns nil for every field of an unknown entity", function()
            Conform(function(lib)
                return {
                    name = lib.Npc.Get(ABSENT_ID, "name"),
                    all = lib.Npc.GetAll(ABSENT_ID, {"name", "zoneID"}),
                    exists = lib.Npc.Exists(ABSENT_ID),
                    nilId = lib.Npc.Get(nil, "name"),
                    stringId = lib.Npc.Exists(tostring(FIXTURE.Npc.forestSpider)),
                    rank = lib.Npc.Get(ABSENT_ID, "rank"),
                    provenance = lib.Corrections.GetProvenance("Npc", ABSENT_ID, "name"),
                }
            end)
        end)

        it("packs bulk reads with n so nil slots survive unpack", function()
            local seen = Conform(function(lib)
                return lib.Npc.GetAll(FIXTURE.Npc.forestSpider, {"name", "subName", "zoneID"})
            end)
            assert.are_same({"Forest Spider", nil, 12, n = 3}, seen)
        end)

        it("enumerates composed IDs ascending and answers Exists from the same set", function()
            Conform(function(lib)
                local list = lib.Npc.GetAllIds()
                local map = lib.Npc.GetAllIds(true)
                local seen = {ascending = IsAscending(list), listIsShared = list == lib.Npc.GetAllIds()}
                for _, id in ipairs(fixtureIds.Npc) do
                    seen[id] = {inMap = map[id], exists = lib.Npc.Exists(id)}
                end
                return seen
            end)
        end)

        it("returns a fresh copy of a table value on every read", function()
            Conform(function(lib)
                local id = FIXTURE.Npc.forestSpider
                local spawns = lib.Npc.Get(id, "spawns")
                local zone = next(spawns)
                spawns[zone] = nil
                return {
                    rereadKeepsZone = lib.Npc.Get(id, "spawns")[zone] ~= nil,
                    distinctReads = lib.Npc.Get(id, "spawns") ~= lib.Npc.Get(id, "spawns"),
                    distinctRawReads = lib.Npc.GetRaw(id, "spawns") ~= lib.Npc.GetRaw(id, "spawns"),
                }
            end)
        end)

        it("reads 0 for a number field an existing entity does not store, and nil for a string field", function()
            local seen = Conform(function(lib)
                local id = FIXTURE.Npc.forestSpider
                return {
                    rank = lib.Npc.Get(id, "rank"),
                    npcFlags = lib.Npc.npcFlags(id),
                    subName = lib.Npc.Get(id, "subName"),
                    all = lib.Npc.GetAll(id, {"rank", "subName"}),
                }
            end)
            assert.are_same(0, seen.rank)
            assert.is_nil(seen.subName)
        end)

        it("reads the never-nil Quest structures as empty tables and numbers as 0 for a Quest that exists only in a slot", function()
            local seen = Conform(function(lib, owner)
                local questKeys = lib.Meta.QuestMeta.questKeys
                lib.Corrections.Set(owner, "Quest", "AddedQuest", {[ABSENT_ID] = {[questKeys.name] = "Added Quest"}})
                return {
                    startedBy = lib.Quest.Get(ABSENT_ID, "startedBy"),
                    finishedBy = lib.Quest.Get(ABSENT_ID, "finishedBy"),
                    objectives = lib.Quest.Get(ABSENT_ID, "objectives"),
                    preQuestSingle = lib.Quest.Get(ABSENT_ID, "preQuestSingle"),
                    requiredLevel = lib.Quest.Get(ABSENT_ID, "requiredLevel"),
                    rawStartedBy = lib.Quest.GetRaw(ABSENT_ID, "startedBy"),
                    shippedPreQuestSingle = lib.Quest.Get(FIXTURE.Quest.jittersGrowlingGut, "preQuestSingle"),
                    absentStartedBy = lib.Quest.Get(ABSENT_ID + 1, "startedBy"),
                }
            end)
            assert.are_same({}, seen.startedBy)
            assert.are_same(0, seen.requiredLevel)
        end)
    end)

    describe("Correction registrar", function()
        it("composes the corrected field over base data and leaves GetRaw untouched", function()
            local seen = Conform(function(lib, owner)
                local npcKeys = lib.Meta.NpcMeta.npcKeys
                local id = FIXTURE.Npc.gelvas
                local registrar = lib.GetRegistrar(owner)
                registrar.RegisterRuntimeCorrection("Npc", "DarkmoonFaire", function()
                    return {[id] = {[npcKeys.spawns] = {[12] = {{37.24, 37.67}}}, [npcKeys.zoneID] = 12}}
                end, 100)
                registrar.Apply()
                local rawSpawns = lib.Npc.GetRaw(id, "spawns")
                return {
                    spawns = lib.Npc.Get(id, "spawns"),
                    zoneID = lib.Npc.Get(id, "zoneID"),
                    name = lib.Npc.Get(id, "name"),
                    rawKeepsBothZones = rawSpawns[12] ~= nil and rawSpawns[215] ~= nil,
                    provenance = lib.Corrections.GetProvenance("Npc", id, "zoneID"),
                }
            end)
            assert.are_same(12, seen.zoneID)
            assert.is_true(seen.rawKeepsBothZones)
        end)

        it("invokes every provider again on each apply", function()
            local seen = Conform(function(lib, owner)
                local providerCalls = 0
                local registrar = lib.GetRegistrar(owner)
                registrar.RegisterRuntimeCorrection("Object", "GatheringNodeDisplayPolicy", function()
                    providerCalls = providerCalls + 1
                    return {}
                end, 200)
                registrar.Apply()
                registrar.Apply()
                return {providerCalls = providerCalls}
            end)
            assert.are_same(2, seen.providerCalls)
        end)

        it("rebuilds the owner layer on reapply instead of accumulating", function()
            local seen = Conform(function(lib, owner)
                local npcKeys = lib.Meta.NpcMeta.npcKeys
                local rows = {[FIXTURE.Npc.gelvas] = {[npcKeys.zoneID] = 12}}
                local registrar = lib.GetRegistrar(owner)
                registrar.RegisterRuntimeCorrection("Npc", "DarkmoonFaire", function() return rows end, 100)
                registrar.Apply()
                rows = {[FIXTURE.Npc.yebb] = {[npcKeys.name] = "Yebb Neblegear (renamed)"}}
                registrar.Apply()
                return {
                    gelvasZone = lib.Npc.Get(FIXTURE.Npc.gelvas, "zoneID"),
                    yebbName = lib.Npc.Get(FIXTURE.Npc.yebb, "name"),
                }
            end)
            assert.are_same(215, seen.gelvasZone)
            assert.are_same("Yebb Neblegear (renamed)", seen.yebbName)
        end)

        it("withdraws every earlier row when a provider returns an empty top-level table", function()
            local seen = Conform(function(lib, owner)
                local npcKeys = lib.Meta.NpcMeta.npcKeys
                local rows = {[FIXTURE.Npc.gelvas] = {[npcKeys.zoneID] = 12}}
                local registrar = lib.GetRegistrar(owner)
                registrar.RegisterRuntimeCorrection("Npc", "DarkmoonFaire", function() return rows end, 100)
                registrar.Apply()
                rows = {}
                registrar.Apply()
                return {
                    zoneID = lib.Npc.Get(FIXTURE.Npc.gelvas, "zoneID"),
                    provenance = lib.Corrections.GetProvenance("Npc", FIXTURE.Npc.gelvas, "zoneID"),
                }
            end)
            assert.are_same("QuestieTDB", seen.provenance)
        end)

        it("clears a field with {} while GetRaw still returns base data", function()
            local seen = Conform(function(lib, owner)
                local objectKeys = lib.Meta.ObjectMeta.objectKeys
                local id = FIXTURE.Object.silverleaf
                local registrar = lib.GetRegistrar(owner)
                registrar.RegisterRuntimeCorrection("Object", "GatheringNodeDisplayPolicy", function()
                    return {[id] = {[objectKeys.spawns] = {}}}
                end, 200)
                registrar.Apply()
                return {
                    spawns = lib.Object.Get(id, "spawns"),
                    name = lib.Object.Get(id, "name"),
                    rawSpawnsKept = type(lib.Object.GetRaw(id, "spawns")) == "table",
                    provenance = lib.Corrections.GetProvenance("Object", id, "spawns"),
                }
            end)
            assert.is_nil(seen.spawns)
            assert.is_true(seen.rawSpawnsKept)
        end)

        it("creates an entity absent from base data and removes it again on withdrawal", function()
            local seen = Conform(function(lib, owner)
                local itemKeys = lib.Meta.ItemMeta.itemKeys
                local rows = {[ABSENT_ID] = {[itemKeys.name] = "Repaired Item"}}
                local registrar = lib.GetRegistrar(owner)
                registrar.RegisterRuntimeCorrection("Item", "RuntimeItemRepair", function() return rows end, 400)
                local mapBefore = lib.Item.GetAllIds(true)
                registrar.Apply()
                local list = lib.Item.GetAllIds()
                local seen = {
                    exists = lib.Item.Exists(ABSENT_ID),
                    name = lib.Item.Get(ABSENT_ID, "name"),
                    inMap = lib.Item.GetAllIds(true)[ABSENT_ID],
                    lastInList = list[#list],
                    listAscending = IsAscending(list),
                    raw = lib.Item.GetRaw(ABSENT_ID, "name"),
                    provenance = lib.Corrections.GetProvenance("Item", ABSENT_ID, "name"),
                    mapSwapped = mapBefore ~= lib.Item.GetAllIds(true),
                }
                rows = {}
                registrar.Apply()
                seen.existsAfter = lib.Item.Exists(ABSENT_ID)
                seen.inMapAfter = lib.Item.GetAllIds(true)[ABSENT_ID]
                return seen
            end)
            assert.is_true(seen.exists)
            assert.are_same("Repaired Item", seen.name)
            assert.is_true(seen.mapSwapped)
            assert.is_false(seen.existsAfter)
        end)

        it("does not invent an entity from a row that writes no schema field", function()
            local seen = Conform(function(lib, owner)
                local mapBefore = lib.Npc.GetAllIds(true)
                lib.Corrections.Set(owner, "Npc", "EmptyRows", {
                    [ABSENT_ID] = {},
                    [ABSENT_ID + 1] = {[999] = "outside the schema"},
                })
                return {
                    emptyExists = lib.Npc.Exists(ABSENT_ID),
                    outsideSchemaExists = lib.Npc.Exists(ABSENT_ID + 1),
                    mapKept = mapBefore == lib.Npc.GetAllIds(true),
                }
            end)
            assert.are_same({emptyExists = false, outsideSchemaExists = false, mapKept = true}, seen)
        end)

        it("keeps the ID map identity while an apply adds no entity, and swaps it when one is added", function()
            local seen = Conform(function(lib, owner)
                local npcKeys = lib.Meta.NpcMeta.npcKeys
                local rows = {[FIXTURE.Npc.gelvas] = {[npcKeys.zoneID] = 12}}
                local registrar = lib.GetRegistrar(owner)
                registrar.RegisterRuntimeCorrection("Npc", "DarkmoonFaire", function() return rows end, 100)
                local mapBefore = lib.Npc.GetAllIds(true)
                registrar.Apply()
                local mapAfterEdit = lib.Npc.GetAllIds(true)
                rows[ABSENT_ID] = {[npcKeys.name] = "Added"}
                registrar.Apply()
                local mapAfterAdd = lib.Npc.GetAllIds(true)
                rows[ABSENT_ID] = nil
                registrar.Apply()
                return {
                    keptOnEdit = mapAfterEdit == mapBefore,
                    swappedOnAdd = mapAfterAdd ~= mapBefore,
                    restoredOnWithdrawal = lib.Npc.GetAllIds(true) == mapBefore,
                }
            end)
            assert.are_same({keptOnEdit = true, swappedOnAdd = true, restoredOnWithdrawal = true}, seen)
        end)

        it("lets the later loadOrder win within one owner", function()
            local seen = Conform(function(lib, owner)
                local npcKeys = lib.Meta.NpcMeta.npcKeys
                local id = FIXTURE.Npc.gelvas
                local registrar = lib.GetRegistrar(owner)
                registrar.RegisterRuntimeCorrection("Npc", "ExternalLocaleNpc", function()
                    return {[id] = {[npcKeys.name] = "Gelvas Grimegate (external)"}}
                end, 502)
                registrar.RegisterRuntimeCorrection("Npc", "DarkmoonFaire", function()
                    return {[id] = {[npcKeys.name] = "Darkmoon name"}}
                end, 100)
                registrar.Apply()
                return {name = lib.Npc.Get(id, "name")}
            end)
            assert.are_same("Gelvas Grimegate (external)", seen.name)
        end)

        it("applies two registrations of one name in sequence instead of replacing the first", function()
            local seen = Conform(function(lib, owner)
                local npcKeys = lib.Meta.NpcMeta.npcKeys
                local id = FIXTURE.Npc.gelvas
                local registrar = lib.GetRegistrar(owner)
                registrar.RegisterRuntimeCorrection("Npc", "DarkmoonFaire", function()
                    return {[id] = {[npcKeys.zoneID] = 99, [npcKeys.name] = "First"}}
                end)
                registrar.RegisterRuntimeCorrection("Npc", "DarkmoonFaire", function()
                    return {[id] = {[npcKeys.zoneID] = 12}}
                end)
                registrar.Apply()
                return {zoneID = lib.Npc.Get(id, "zoneID"), name = lib.Npc.Get(id, "name")}
            end)
            assert.are_same({zoneID = 12, name = "First"}, seen)
        end)

        it("fixes owner precedence at first apply and lists owners in that order", function()
            local seen = Conform(function(lib, owner)
                local npcKeys = lib.Meta.NpcMeta.npcKeys
                local id = FIXTURE.Npc.gelvas
                local registrar = lib.GetRegistrar(owner)
                registrar.RegisterRuntimeCorrection("Npc", "DarkmoonFaire", function()
                    return {[id] = {[npcKeys.zoneID] = 12}}
                end, 100)
                registrar.Apply()
                local thirdParty = lib.GetRegistrar(owner .. "ThirdParty")
                thirdParty.RegisterRuntimeCorrection("Npc", "override", function()
                    return {[id] = {[npcKeys.zoneID] = 99}}
                end, 1)
                thirdParty.Apply()
                registrar.Apply()
                return {
                    zoneID = lib.Npc.Get(id, "zoneID"),
                    provenance = lib.GetProvenance("Npc", id, "zoneID"),
                    owners = OwnersOf(lib, owner),
                }
            end)
            assert.are_same(99, seen.zoneID)
            assert.are_same(3, #seen.owners)
        end)

        it("republishes only the datatypes the owner has entries in", function()
            local seen = Conform(function(lib, owner)
                local objectKeys = lib.Meta.ObjectMeta.objectKeys
                local registrar = lib.GetRegistrar(owner)
                registrar.RegisterRuntimeCorrection("Object", "AddedObject", function()
                    return {[ABSENT_ID] = {[objectKeys.name] = "Added"}}
                end, 200)
                local npcMapBefore = lib.Npc.GetAllIds(true)
                local objectMapBefore = lib.Object.GetAllIds(true)
                registrar.Apply()
                return {
                    npcMapKept = npcMapBefore == lib.Npc.GetAllIds(true),
                    objectMapSwapped = objectMapBefore ~= lib.Object.GetAllIds(true),
                }
            end)
            assert.are_same({npcMapKept = true, objectMapSwapped = true}, seen)
        end)
    end)

    describe("Corrections.Set", function()
        it("publishes a data slot immediately and composes it over base data", function()
            local seen = Conform(function(lib, owner)
                local npcKeys = lib.Meta.NpcMeta.npcKeys
                local id = FIXTURE.Npc.gelvas
                local changed = lib.Corrections.Set(owner, "Npc", "DarkmoonFaire", {[id] = {[npcKeys.zoneID] = 12}})
                return {
                    changed = changed,
                    zoneID = lib.Npc.Get(id, "zoneID"),
                    raw = lib.Npc.GetRaw(id, "zoneID"),
                    provenance = lib.Corrections.GetProvenance("Npc", id, "zoneID"),
                    owners = OwnersOf(lib, owner),
                }
            end)
            assert.is_true(seen.changed)
            assert.are_same(215, seen.raw)
        end)

        it("replaces a slot in place and removes it with nil", function()
            Conform(function(lib, owner)
                local npcKeys = lib.Meta.NpcMeta.npcKeys
                local id = FIXTURE.Npc.gelvas
                local registrar = lib.GetRegistrar(owner)
                registrar.Set("Npc", "DarkmoonFaire", {[id] = {[npcKeys.zoneID] = 12}})
                registrar.Set("Npc", "DarkmoonFaire", {[id] = {[npcKeys.zoneID] = 1}})
                local replaced = lib.Npc.Get(id, "zoneID")
                local removed = registrar.Set("Npc", "DarkmoonFaire", nil)
                return {
                    replaced = replaced,
                    removed = removed,
                    restored = lib.Npc.Get(id, "zoneID"),
                    removedAgain = registrar.Set("Npc", "DarkmoonFaire", nil),
                    emptyRowsKeepSlot = registrar.Set("Npc", "DarkmoonFaire", {}),
                }
            end)
        end)

        it("republishes only the written datatype", function()
            local seen = Conform(function(lib, owner)
                local npcKeys = lib.Meta.NpcMeta.npcKeys
                local objectKeys = lib.Meta.ObjectMeta.objectKeys
                lib.Corrections.Set(owner, "Npc", "DarkmoonFaire", {[FIXTURE.Npc.gelvas] = {[npcKeys.zoneID] = 12}})
                local npcMapBefore = lib.Npc.GetAllIds(true)
                local objectMapBefore = lib.Object.GetAllIds(true)
                lib.Corrections.Set(owner, "Object", "AddedObject", {[ABSENT_ID] = {[objectKeys.name] = "Added"}})
                return {
                    npcMapKept = npcMapBefore == lib.Npc.GetAllIds(true),
                    objectMapSwapped = objectMapBefore ~= lib.Object.GetAllIds(true),
                }
            end)
            assert.are_same({npcMapKept = true, objectMapSwapped = true}, seen)
        end)

        it("refuses a data write into a function-shaped correction name", function()
            local seen = Conform(function(lib, owner)
                local registrar = lib.GetRegistrar(owner)
                registrar.RegisterRuntimeCorrection("Npc", "DarkmoonFaire", function() return {} end)
                return {refused = not pcall(registrar.Set, "Npc", "DarkmoonFaire", {})}
            end)
            assert.is_true(seen.refused)
        end)

        it("fixes owner precedence at the first write", function()
            local seen = Conform(function(lib, owner)
                local npcKeys = lib.Meta.NpcMeta.npcKeys
                local id = FIXTURE.Npc.gelvas
                lib.Corrections.Set(owner, "Npc", "slotA", {[id] = {[npcKeys.zoneID] = 12}})
                lib.Corrections.Set(owner .. "ThirdParty", "Npc", "slotB", {[id] = {[npcKeys.zoneID] = 99}})
                lib.Corrections.Set(owner, "Npc", "slotA", {[id] = {[npcKeys.zoneID] = 300}})
                return {zoneID = lib.Npc.Get(id, "zoneID"), owners = OwnersOf(lib, owner)}
            end)
            assert.are_same(99, seen.zoneID)
        end)
    end)

    -- Source mode ships no translations, so these cases cover the locale plumbing, not the translated text.
    describe("l10n.SetLocale", function()
        it("exposes the current locale and keeps reads working across a change", function()
            local seen = Conform(function(lib)
                lib.l10n.SetLocale("deDE")
                local duringGerman = lib.l10n.currentLocale
                local readsDuringGerman = lib.Npc.Get(FIXTURE.Npc.forestSpider, "zoneID")
                lib.l10n.SetLocale("enUS")
                return {
                    duringGerman = duringGerman,
                    readsDuringGerman = readsDuringGerman,
                    after = lib.l10n.currentLocale,
                    name = lib.Npc.Get(FIXTURE.Npc.forestSpider, "name"),
                }
            end)
            assert.are_same("deDE", seen.duringGerman)
        end)
    end)

    describe("Object name index", function()
        it("returns ascending IDs sharing the current name, or nil when no Object has it", function()
            local seen = Conform(function(lib)
                return {
                    batteredChest = lib.Object.IdsByName("Battered Chest"),
                    oldLionStatue = lib.Object.IdsByName("Old Lion Statue"),
                    unknown = lib.Object.IdsByName("No Such Name"),
                    nonString = lib.Object.IdsByName(nil),
                }
            end)
            assert.is_true(#seen.batteredChest >= 2)
            assert.is_true(IsAscending(seen.batteredChest))
        end)

        it("answers the same after an explicit BuildNameIndex", function()
            local seen = Conform(function(lib)
                lib.Object.BuildNameIndex()
                return {
                    silverleaf = lib.Object.IdsByName("Silverleaf"),
                    sharedList = lib.Object.IdsByName("Silverleaf") == lib.Object.IdsByName("Silverleaf"),
                }
            end)
            assert.are_same({1617, 3725}, seen.silverleaf)
        end)

        it("follows a Correction rename after the next apply", function()
            local seen = Conform(function(lib, owner)
                local objectKeys = lib.Meta.ObjectMeta.objectKeys
                lib.Object.BuildNameIndex()
                local registrar = lib.GetRegistrar(owner)
                registrar.RegisterRuntimeCorrection("Object", "ExternalLocaleObject", function()
                    return {[FIXTURE.Object.oldLionStatue] = {[objectKeys.name] = "Alte Löwenstatue"}}
                end, 503)
                registrar.Apply()
                return {
                    oldName = lib.Object.IdsByName("Old Lion Statue"),
                    newName = lib.Object.IdsByName("Alte Löwenstatue"),
                }
            end)
            assert.are_same({FIXTURE.Object.oldLionStatue}, seen.newName)
        end)

        it("keeps answering after a locale change", function()
            Conform(function(lib)
                lib.Object.BuildNameIndex()
                lib.l10n.SetLocale("deDE")
                -- Looked up by the composed name so the case holds whether or not a translation ships.
                local duringGerman = lib.Object.IdsByName(lib.Object.Get(FIXTURE.Object.oldLionStatue, "name"))
                lib.l10n.SetLocale("enUS")
                return {duringGerman = duringGerman, after = lib.Object.IdsByName("Old Lion Statue")}
            end)
        end)
    end)
end)
