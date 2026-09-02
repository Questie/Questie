dofile("setupTests.lua")

local LoadQuestieTDBMock = dofile("test/QuestieTDBMock.lua")

describe("QuestieTDBMock", function()
    ---@type QuestieTDBMock
    local mock
    local LibQuestieDB
    local questKeys, npcKeys, itemKeys, objectKeys

    before_each(function()
        mock = LoadQuestieTDBMock()
        LibQuestieDB = mock.lib
        questKeys = LibQuestieDB.Meta.QuestMeta.questKeys
        npcKeys = LibQuestieDB.Meta.NpcMeta.npcKeys
        itemKeys = LibQuestieDB.Meta.ItemMeta.itemKeys
        objectKeys = LibQuestieDB.Meta.ObjectMeta.objectKeys
    end)

    describe("RequireContract", function()
        it("accepts Contract Version 1", function()
            local ok, message = LibQuestieDB.RequireContract(1)

            assert.is_true(ok)
            assert.is_nil(message)
        end)

        it("rejects a consumer version below the provider floor with a specific message", function()
            mock.minSupportedContract = 2
            mock.contractVersion = 2

            local ok, message = LibQuestieDB.RequireContract(1)

            assert.is_false(ok)
            assert.are_same(
                "QuestieTDB contract mismatch: this consumer needs version 1, the installed QuestieTDB provides 2 " ..
                "(supporting consumers back to 2). Update whichever is older.",
                message)
        end)

        it("rejects a non-numeric version", function()
            assert.is_false((LibQuestieDB.RequireContract("1")))
        end)
    end)

    describe("entity reads", function()
        before_each(function()
            mock.SetBaseRow("Npc", 30, {
                [npcKeys.name] = "Forest Spider",
                [npcKeys.spawns] = {[12] = {{36.43, 55.89}}},
                [npcKeys.zoneID] = 12,
            })
        end)

        it("reads one field by name, by index, and through the named getter", function()
            assert.are_same("Forest Spider", LibQuestieDB.Npc.Get(30, "name"))
            assert.are_same("Forest Spider", LibQuestieDB.Npc.Get(30, npcKeys.name))
            assert.are_same("Forest Spider", LibQuestieDB.Npc.name(30))
            assert.are_same(12, LibQuestieDB.Npc.zoneID(30))
        end)

        it("returns nil for every field of an unknown entity", function()
            assert.is_nil(LibQuestieDB.Npc.Get(31, "name"))
            assert.is_nil(LibQuestieDB.Npc.GetAll(31, {"name", "zoneID"}))
            assert.is_false(LibQuestieDB.Npc.Exists(31))
            assert.is_nil(LibQuestieDB.Npc.Get(nil, "name"))
        end)

        it("packs bulk reads with n so nil slots survive unpack", function()
            local values = LibQuestieDB.Npc.GetAll(30, {"name", "subName", "zoneID"})

            assert.are_same({"Forest Spider", nil, 12, n = 3}, values)
            local name, subName, zoneID = unpack(values, 1, values.n)
            assert.are_same("Forest Spider", name)
            assert.is_nil(subName)
            assert.are_same(12, zoneID)
        end)

        it("enumerates composed IDs ascending as a list and as a map", function()
            mock.SetBaseRow("Npc", 7, {[npcKeys.name] = "Kobold Vermin"})

            assert.are_same({7, 30}, LibQuestieDB.Npc.GetAllIds())
            assert.are_same({[7] = true, [30] = true}, LibQuestieDB.Npc.GetAllIds(true))
            assert.is_true(LibQuestieDB.Npc.Exists(7))
        end)

        it("reads 0 for a number field an existing entity does not store, and nil for a string field", function()
            assert.are_same(0, LibQuestieDB.Npc.Get(30, "rank"))
            assert.are_same(0, LibQuestieDB.Npc.npcFlags(30))
            assert.is_nil(LibQuestieDB.Npc.Get(30, "subName"))
            assert.is_nil(LibQuestieDB.Npc.Get(31, "rank"))
            assert.are_same({0, nil, n = 2}, LibQuestieDB.Npc.GetAll(30, {"rank", "subName"}))
        end)

        it("reads the never-nil Quest structures as empty tables for an existing Quest", function()
            mock.SetBaseRow("Quest", 2, {[questKeys.name] = "Sharptalon's Claw"})

            assert.are_same({}, LibQuestieDB.Quest.Get(2, "startedBy"))
            assert.are_same({}, LibQuestieDB.Quest.Get(2, "finishedBy"))
            assert.are_same({}, LibQuestieDB.Quest.Get(2, "objectives"))
            assert.is_nil(LibQuestieDB.Quest.Get(2, "preQuestSingle"))
            assert.is_nil(LibQuestieDB.Quest.Get(3, "startedBy"))
        end)

        it("fails fast on an unknown field name instead of returning nil", function()
            assert.has_error(function()
                LibQuestieDB.Npc.Get(30, "healthPool")
            end, "QuestieTDBMock: unknown Npc field \"healthPool\"")
        end)
    end)

    describe("schema and Objective Order", function()
        it("exposes the four Database Key Enums and binds them onto QuestieDB", function()
            local QuestieDB = QuestieLoader:ImportModule("QuestieDB")

            assert.are_same(1, questKeys.name)
            assert.are_same(13, questKeys.preQuestSingle)
            assert.are_same(7, npcKeys.spawns)
            assert.are_same(1, itemKeys.name)
            assert.are_same(4, objectKeys.spawns)
            assert.are_equal(questKeys, QuestieDB.questKeys)
            assert.are_equal(npcKeys, QuestieDB.npcKeys)
            assert.are_equal(itemKeys, QuestieDB.itemKeys)
            assert.are_equal(objectKeys, QuestieDB.objectKeys)
        end)

        it("provides the five provider-owned Objective Order tables", function()
            assert.are_same({}, LibQuestieDB.ObjectiveFirst.killCreditObjectiveFirst)
            assert.are_same({}, LibQuestieDB.ObjectiveFirst.objectObjectiveFirst)
            assert.are_same({}, LibQuestieDB.ObjectiveFirst.itemObjectiveFirst)
            assert.are_same({}, LibQuestieDB.ObjectiveFirst.eventObjectiveFirst)
            assert.are_same({}, LibQuestieDB.ObjectiveFirst.spellObjectiveFirst)
        end)
    end)

    describe("Correction registrar", function()
        local registrar
        local darkmoonRows

        before_each(function()
            mock.SetBaseRow("Npc", 14828, {
                [npcKeys.name] = "Gelvas Grimegate",
                [npcKeys.spawns] = {[1] = {{10, 10}}},
                [npcKeys.zoneID] = 1,
            })
            mock.SetBaseRow("Object", 1617, {
                [objectKeys.name] = "Silverleaf",
                [objectKeys.spawns] = {[1] = {{20, 20}}},
            })
            darkmoonRows = {}
            registrar = LibQuestieDB.GetRegistrar("Questie")
            registrar.RegisterRuntimeCorrection("Npc", "DarkmoonFaire", function() return darkmoonRows end, 100)
        end)

        it("keeps registrations append-only, so registering one name twice yields two entries", function()
            registrar.RegisterRuntimeCorrection("Npc", "DarkmoonFaire", function() return {} end, 100)

            assert.are_same(2, #mock.registrations.Questie)
        end)

        it("invokes every provider again on each apply", function()
            local providerCalls = 0
            registrar.RegisterRuntimeCorrection("Object", "GatheringNodeDisplayPolicy", function()
                providerCalls = providerCalls + 1
                return {}
            end, 200)

            registrar.Apply()
            registrar.Apply()

            assert.are_same(2, providerCalls)
            assert.are_same(2, mock.applyCount.Questie)
        end)

        it("composes the corrected field over base data and leaves GetRaw untouched", function()
            darkmoonRows[14828] = {[npcKeys.spawns] = {[12] = {{37.24, 37.67}}}, [npcKeys.zoneID] = 12}

            registrar.Apply()

            assert.are_same({[12] = {{37.24, 37.67}}}, LibQuestieDB.Npc.Get(14828, "spawns"))
            assert.are_same(12, LibQuestieDB.Npc.Get(14828, "zoneID"))
            assert.are_same("Gelvas Grimegate", LibQuestieDB.Npc.Get(14828, "name"))
            assert.are_same({[1] = {{10, 10}}}, LibQuestieDB.Npc.GetRaw(14828, "spawns"))
        end)

        it("rebuilds the owner layer on reapply instead of accumulating", function()
            darkmoonRows[14828] = {[npcKeys.zoneID] = 12}
            registrar.Apply()

            darkmoonRows = {[14829] = {[npcKeys.name] = "Yebb Neblegear"}}
            registrar.Apply()

            assert.are_same(1, LibQuestieDB.Npc.Get(14828, "zoneID"))
            assert.are_same("Yebb Neblegear", LibQuestieDB.Npc.Get(14829, "name"))
        end)

        it("withdraws every earlier row when a provider returns an empty top-level table", function()
            darkmoonRows[14828] = {[npcKeys.zoneID] = 12}
            registrar.Apply()

            darkmoonRows = {}
            registrar.Apply()

            assert.are_same(1, LibQuestieDB.Npc.Get(14828, "zoneID"))
            assert.are_same("QuestieTDB", LibQuestieDB.Corrections.GetProvenance("Npc", 14828, "zoneID"))
        end)

        it("clears a field with {} while GetRaw still returns base data", function()
            registrar.RegisterRuntimeCorrection("Object", "GatheringNodeDisplayPolicy", function()
                return {[1617] = {[objectKeys.spawns] = {}}}
            end, 200)

            registrar.Apply()

            assert.is_nil(LibQuestieDB.Object.Get(1617, "spawns"))
            assert.are_same("Silverleaf", LibQuestieDB.Object.Get(1617, "name"))
            assert.are_same({[1] = {{20, 20}}}, LibQuestieDB.Object.GetRaw(1617, "spawns"))
            assert.are_same("Questie", LibQuestieDB.Corrections.GetProvenance("Object", 1617, "spawns"))
        end)

        it("creates an entity absent from base data and removes it again on withdrawal", function()
            local repairedItems = {[999] = {[itemKeys.name] = "Repaired Item"}}
            registrar.RegisterRuntimeCorrection("Item", "RuntimeItemRepair", function() return repairedItems end, 400)

            registrar.Apply()

            assert.is_true(LibQuestieDB.Item.Exists(999))
            assert.are_same("Repaired Item", LibQuestieDB.Item.Get(999, "name"))
            assert.is_true(LibQuestieDB.Item.GetAllIds(true)[999])
            assert.are_same({999}, LibQuestieDB.Item.GetAllIds())
            assert.is_nil(LibQuestieDB.Item.GetRaw(999, "name"))
            assert.are_same("Questie", LibQuestieDB.Corrections.GetProvenance("Item", 999, "name"))

            repairedItems = {}
            registrar.Apply()

            assert.is_false(LibQuestieDB.Item.Exists(999))
            assert.is_nil(LibQuestieDB.Item.GetAllIds(true)[999])
        end)

        it("shares one ID map between applies and swaps its identity on apply", function()
            local beforeApply = LibQuestieDB.Npc.GetAllIds(true)
            assert.are_equal(beforeApply, LibQuestieDB.Npc.GetAllIds(true))

            registrar.Apply()

            local afterApply = LibQuestieDB.Npc.GetAllIds(true)
            assert.are_not_equal(beforeApply, afterApply)
            assert.are_same(beforeApply, afterApply)
        end)

        it("lets the later loadOrder win within one owner", function()
            registrar.RegisterRuntimeCorrection("Npc", "ExternalLocaleNpc", function()
                return {[14828] = {[npcKeys.name] = "Gelvas Grimegate (external)"}}
            end, 502)
            darkmoonRows[14828] = {[npcKeys.name] = "Darkmoon name"}

            registrar.Apply()

            assert.are_same("Gelvas Grimegate (external)", LibQuestieDB.Npc.Get(14828, "name"))
        end)

        it("fixes owner precedence at first apply and lists owners in that order", function()
            darkmoonRows[14828] = {[npcKeys.zoneID] = 12}
            registrar.Apply()
            local thirdParty = LibQuestieDB.GetRegistrar("ThirdParty")
            thirdParty.RegisterRuntimeCorrection("Npc", "override", function()
                return {[14828] = {[npcKeys.zoneID] = 99}}
            end, 1)
            thirdParty.Apply()

            -- Refreshing the earlier owner must not hoist it above the later one.
            registrar.Apply()

            assert.are_same(99, LibQuestieDB.Npc.Get(14828, "zoneID"))
            assert.are_same("ThirdParty", LibQuestieDB.GetProvenance("Npc", 14828, "zoneID"))
            assert.are_same({"QuestieTDB", "Questie", "ThirdParty"}, LibQuestieDB.GetOwners())
        end)

        it("rejects datatypes outside Quest, Npc, Item, and Object", function()
            assert.has_error(function()
                registrar.RegisterRuntimeCorrection("npc", "lowercase", function() return {} end, 1)
            end, "QuestieTDBMock: unknown datatype \"npc\"; use Quest, Npc, Item, or Object")
        end)
    end)

    describe("l10n.SetLocale", function()
        it("records every forwarded locale and exposes the current one", function()
            LibQuestieDB.l10n.SetLocale("deDE")
            LibQuestieDB.l10n.SetLocale("enUS")

            assert.are_same({"deDE", "enUS"}, mock.setLocaleCalls)
            assert.are_same("enUS", LibQuestieDB.l10n.currentLocale)
        end)
    end)

    describe("Object name index", function()
        before_each(function()
            mock.SetBaseRow("Object", 2849, {[objectKeys.name] = "Battered Chest"})
            mock.SetBaseRow("Object", 2843, {[objectKeys.name] = "Battered Chest"})
            mock.SetBaseRow("Object", 31, {[objectKeys.name] = "Old Lion Statue"})
        end)

        it("returns ascending IDs sharing the current name, or nil when no Object has it", function()
            assert.are_same({2843, 2849}, LibQuestieDB.Object.IdsByName("Battered Chest"))
            assert.are_same({31}, LibQuestieDB.Object.IdsByName("Old Lion Statue"))
            assert.is_nil(LibQuestieDB.Object.IdsByName("No Such Name"))
        end)

        it("builds once on first use and treats BuildNameIndex as a no-op afterwards", function()
            assert.are_same(0, mock.nameIndexBuilds.Object)

            LibQuestieDB.Object.IdsByName("Battered Chest")
            LibQuestieDB.Object.IdsByName("Old Lion Statue")
            LibQuestieDB.Object.BuildNameIndex()

            assert.are_same(1, mock.nameIndexBuilds.Object)
        end)

        it("warms the index through BuildNameIndex so the first lookup does not build", function()
            LibQuestieDB.Object.BuildNameIndex()
            LibQuestieDB.Object.IdsByName("Battered Chest")

            assert.are_same(1, mock.nameIndexBuilds.Object)
        end)

        it("follows a Correction rename after the next apply", function()
            LibQuestieDB.Object.BuildNameIndex()
            local registrar = LibQuestieDB.GetRegistrar("Questie")
            registrar.RegisterRuntimeCorrection("Object", "ExternalLocaleObject", function()
                return {[31] = {[objectKeys.name] = "Alte Löwenstatue"}}
            end, 503)

            registrar.Apply()

            assert.is_nil(LibQuestieDB.Object.IdsByName("Old Lion Statue"))
            assert.are_same({31}, LibQuestieDB.Object.IdsByName("Alte Löwenstatue"))
            assert.are_same(2, mock.nameIndexBuilds.Object)
        end)

        it("drops the index on a locale change and rebuilds on the next lookup", function()
            LibQuestieDB.Object.BuildNameIndex()

            LibQuestieDB.l10n.SetLocale("deDE")
            LibQuestieDB.Object.IdsByName("Battered Chest")

            assert.are_same(2, mock.nameIndexBuilds.Object)
        end)
    end)
end)
