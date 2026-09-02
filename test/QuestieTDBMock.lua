-- Focused Contract Version 1 test double for LibQuestieDB.
--
-- It reproduces only what Questie consumes from QuestieTDB: the Contract check, composed entity
-- reads, shared ID maps that swap identity when their datatype is republished, the owner-scoped
-- Correction registrar, the data-shaped Correction slots (`Corrections.Set`), provenance,
-- provider locale forwarding, Objective Order tables, and the entity Name index. Publication is
-- per datatype, as in the provider: an Item write leaves Quest, Npc, and Object ID maps and Name
-- indexes untouched. It deliberately omits encoding, Source/Baked storage, and provider read
-- caches. Tests seed literal rows; reads return fresh copies and apply the provider's nil rules:
-- number fields of an existing entity read 0, `{}` reads nil, and the never-nil Quest structures
-- read `{}`.
local LoadQuestieTDBMetaMock = dofile("test/QuestieTDBMetaMock.lua")

local ENTITY_TYPES = {"Quest", "Npc", "Item", "Object"}
-- The provider's own layer sits below every registered owner.
local BASE_OWNER = "QuestieTDB"

---@alias QuestieTDBMockDatatype "Quest"|"Npc"|"Item"|"Object"
---@alias QuestieTDBMockRow table<integer, unknown> Field values keyed by Database Key Enum index.
---@alias QuestieTDBMockRows table<number, QuestieTDBMockRow> Correction or base rows keyed by entity ID.

---@class QuestieTDBMockRegistration
---@field datatype QuestieTDBMockDatatype
---@field name string
---@field provider (fun(): QuestieTDBMockRows)? Function-shaped registration; absent on a data slot.
---@field rows QuestieTDBMockRows? Data slot written through `Corrections.Set`; absent on a function entry.
---@field loadOrder number? Explicit order as passed by the caller, when any.
---@field order number Effective order: loadOrder, or a registration-sequence fraction mirroring the provider.
---@field sequence integer Creation order, breaking order ties.

---@class QuestieTDBMock
---@field lib table The installed `LibQuestieDB` fake, also reachable as `_G.LibQuestieDB`.
---@field base table<QuestieTDBMockDatatype, QuestieTDBMockRows> Base rows; seed them through `SetBaseRow`.
---@field registrations table<string, QuestieTDBMockRegistration[]> Function entries and data slots per owner, in creation order.
---@field applyCount table<string, number> `Apply()` calls per owner.
---@field publishCounts table<QuestieTDBMockDatatype, number> How often each datatype's composed view was republished.
---@field setLocaleCalls string[] Locales forwarded through `l10n.SetLocale`, in call order.
---@field nameIndexBuilds table<QuestieTDBMockDatatype, number> Name index builds per datatype.
---@field contractVersion number Highest Contract Version the fake provides.
---@field minSupportedContract number Lowest Contract Version the fake still accepts.
---@field SetBaseRow fun(datatype: QuestieTDBMockDatatype, id: number, row: QuestieTDBMockRow): nil

---Installs a fresh `LibQuestieDB` fake as a global, binds the Database Key Enums onto QuestieDB,
---and returns the inspection handle. Call it in `before_each` so registrar, overlay, provenance,
---and call history never leak between tests.
---@return QuestieTDBMock mock
local function LoadQuestieTDBMock()
    local keys = LoadQuestieTDBMetaMock.keys
    local types = LoadQuestieTDBMetaMock.types

    ---@type QuestieTDBMock
    local mock = {
        base = {Quest = {}, Npc = {}, Item = {}, Object = {}},
        registrations = {},
        applyCount = {},
        publishCounts = {Quest = 0, Npc = 0, Item = 0, Object = 0},
        setLocaleCalls = {},
        nameIndexBuilds = {Quest = 0, Npc = 0, Item = 0, Object = 0},
        contractVersion = 1,
        minSupportedContract = 1,
    }
    local lib = {}

    -- Correction Overlay state: one layer per owner, owners ranked by their first apply or Set.
    ---@type table<string, table<QuestieTDBMockDatatype, QuestieTDBMockRows>>
    local layers = {}
    ---@type string[]
    local ownerOrder = {}
    ---@type table<string, number>
    local ownerRank = {}

    -- Mirrors the provider's global registration sequence: a nil loadOrder defaults to a tiny
    -- sequence fraction, so unnumbered entries apply before explicitly numbered ones.
    local registrationSequence = 0

    -- Quest `startedBy`, `finishedBy`, and `objectives` read `{}` rather than nil for an entity that
    -- exists; Questie's Quest projection indexes them unconditionally.
    ---@type table<QuestieTDBMockDatatype, table<integer, true>>
    local neverNilFields = {
        Quest = {
            [keys.Quest.startedBy] = true,
            [keys.Quest.finishedBy] = true,
            [keys.Quest.objectives] = true,
        },
        Npc = {},
        Item = {},
        Object = {},
    }

    -- Derived structures the provider drops per datatype on publish and rebuilds on the next read.
    ---@type table<QuestieTDBMockDatatype, {map: table<number, true>, list: number[]}>
    local idMaps = {}
    ---@type table<QuestieTDBMockDatatype, table<string, number[]>>
    local nameIndexes = {}

    ---@return nil
    local function InvalidateIdMaps()
        idMaps = {}
    end

    ---@return nil
    local function InvalidateNameIndexes()
        nameIndexes = {}
    end

    ---Every table read is a fresh copy, as with the provider: a caller may mutate what it read
    ---without changing the next read, and two reads are never the same table.
    ---@param value unknown
    ---@return unknown
    local function CopyValue(value)
        if type(value) ~= "table" then
            return value
        end
        local copy = {}
        for key, entry in pairs(value) do
            copy[key] = CopyValue(entry)
        end
        return copy
    end

    ---@param datatype QuestieTDBMockDatatype
    ---@return nil
    local function AssertDatatype(datatype)
        if not keys[datatype] then
            error(("QuestieTDBMock: unknown datatype %q; use Quest, Npc, Item, or Object"):format(tostring(datatype)), 3)
        end
    end

    ---@param datatype QuestieTDBMockDatatype
    ---@param key string|integer Field name or Database Key Enum index.
    ---@return integer fieldIndex
    local function FieldIndex(datatype, key)
        if type(key) == "number" then
            return key
        end
        local fieldIndex = keys[datatype][key]
        if not fieldIndex then
            error(("QuestieTDBMock: unknown %s field %q"):format(datatype, tostring(key)), 3)
        end
        return fieldIndex
    end

    -------------------------------------------------------------------------------------------
    -- Composition: base row, then every owner layer in first-apply order; the last writer wins.
    -------------------------------------------------------------------------------------------

    ---@param datatype QuestieTDBMockDatatype
    ---@param id number
    ---@return boolean
    local function Exists(datatype, id)
        if mock.base[datatype][id] then
            return true
        end
        for _, owner in ipairs(ownerOrder) do
            if layers[owner][datatype][id] then
                return true
            end
        end
        return false
    end

    ---@param datatype QuestieTDBMockDatatype
    ---@param id number
    ---@param fieldIndex integer
    ---@return unknown value Composed value; `{}` from any layer reads back as nil.
    ---@return string|nil owner Owner whose value won, `"QuestieTDB"` for base data, nil when no layer set the field.
    local function ComposedValue(datatype, id, fieldIndex)
        local value, owner
        local baseRow = mock.base[datatype][id]
        if baseRow and baseRow[fieldIndex] ~= nil then
            value, owner = baseRow[fieldIndex], BASE_OWNER
        end
        for _, layerOwner in ipairs(ownerOrder) do
            local row = layers[layerOwner][datatype][id]
            if row and row[fieldIndex] ~= nil then
                value, owner = row[fieldIndex], layerOwner
            end
        end
        -- `{}` is the clear idiom: an empty table never reaches a reader.
        if type(value) == "table" and next(value) == nil then
            value = nil
        end
        -- Provider read rule for an entity that exists: number fields read 0, never nil, and the
        -- never-nil Quest structures read a fresh empty table.
        if value == nil then
            if types[datatype][fieldIndex] == "number" then
                value = 0
            elseif neverNilFields[datatype][fieldIndex] then
                value = {}
            end
        end
        return value, owner
    end

    ---@param datatype QuestieTDBMockDatatype
    ---@return {map: table<number, true>, list: number[]} ids Shared until the datatype is republished.
    local function ComposedIds(datatype)
        if idMaps[datatype] then
            return idMaps[datatype]
        end
        local map, list = {}, {}
        for id in pairs(mock.base[datatype]) do
            map[id] = true
        end
        for _, owner in ipairs(ownerOrder) do
            for id in pairs(layers[owner][datatype]) do
                map[id] = true
            end
        end
        for id in pairs(map) do
            list[#list + 1] = id
        end
        table.sort(list)
        idMaps[datatype] = {map = map, list = list}
        return idMaps[datatype]
    end

    ---Builds the reverse `name` index from composed reads; a no-op while an index exists.
    ---@param datatype QuestieTDBMockDatatype
    ---@return nil
    local function BuildNameIndex(datatype)
        if nameIndexes[datatype] then
            return
        end
        local index = {}
        local nameFieldIndex = keys[datatype].name
        -- IDs are visited ascending, so every bucket stays ascending.
        for _, id in ipairs(ComposedIds(datatype).list) do
            local name = ComposedValue(datatype, id, nameFieldIndex)
            if name ~= nil then
                index[name] = index[name] or {}
                table.insert(index[name], id)
            end
        end
        nameIndexes[datatype] = index
        mock.nameIndexBuilds[datatype] = mock.nameIndexBuilds[datatype] + 1
    end

    -------------------------------------------------------------------------------------------
    -- Entity globals: LibQuestieDB.Quest / Npc / Item / Object
    -------------------------------------------------------------------------------------------

    ---@param datatype QuestieTDBMockDatatype
    ---@return table entity
    local function CreateEntity(datatype)
        local entity = {}

        ---@param id number
        ---@param key string|integer
        ---@return unknown
        function entity.Get(id, key)
            local fieldIndex = FieldIndex(datatype, key)
            if type(id) ~= "number" or not Exists(datatype, id) then
                return nil
            end
            return CopyValue((ComposedValue(datatype, id, fieldIndex)))
        end

        ---Packed bulk read: `n` carries the requested count so nil slots survive `unpack`.
        ---@param id number
        ---@param requestedKeys (string|integer)[]
        ---@return table|nil values
        function entity.GetAll(id, requestedKeys)
            if type(id) ~= "number" or not Exists(datatype, id) then
                return nil
            end
            local values = {n = #requestedKeys}
            for i = 1, #requestedKeys do
                values[i] = CopyValue((ComposedValue(datatype, id, FieldIndex(datatype, requestedKeys[i]))))
            end
            return values
        end

        ---@param hashmap boolean? true for the `{[id] = true}` map, otherwise the ascending list.
        ---@return table ids Shared, read-only; replaced when an apply or Set touches this datatype.
        function entity.GetAllIds(hashmap)
            local ids = ComposedIds(datatype)
            if hashmap then
                return ids.map
            end
            return ids.list
        end

        ---@param id number
        ---@return boolean
        function entity.Exists(id)
            return type(id) == "number" and Exists(datatype, id)
        end

        ---Base data only: bypasses every Correction layer, so an overlay-added entity reads nil.
        ---@param id number
        ---@param key string|integer
        ---@return unknown
        function entity.GetRaw(id, key)
            local fieldIndex = FieldIndex(datatype, key)
            local row = type(id) == "number" and mock.base[datatype][id]
            if not row then
                return nil
            end
            return CopyValue(row[fieldIndex])
        end

        ---@param name string
        ---@return number[]|nil ids Ascending composed IDs whose current name equals `name`.
        function entity.IdsByName(name)
            BuildNameIndex(datatype)
            return nameIndexes[datatype][name]
        end

        ---@return nil
        function entity.BuildNameIndex()
            BuildNameIndex(datatype)
        end

        -- Named getters mirror the provider's schema-generated accessors, e.g. `Object.name(id)`.
        for fieldName in pairs(keys[datatype]) do
            entity[fieldName] = function(id)
                return entity.Get(id, fieldName)
            end
        end

        return entity
    end

    for _, datatype in ipairs(ENTITY_TYPES) do
        lib[datatype] = CreateEntity(datatype)
    end

    -------------------------------------------------------------------------------------------
    -- Schema, Objective Order, Contract, locale
    -------------------------------------------------------------------------------------------

    lib.Meta = {
        QuestMeta = {questKeys = keys.Quest, types = types.Quest},
        NpcMeta = {npcKeys = keys.Npc, types = types.Npc},
        ItemMeta = {itemKeys = keys.Item, types = types.Item},
        ObjectMeta = {objectKeys = keys.Object, types = types.Object},
    }

    -- Provider-owned Objective Order hints; tests seed IDs directly.
    lib.ObjectiveFirst = {
        killCreditObjectiveFirst = {},
        objectObjectiveFirst = {},
        itemObjectiveFirst = {},
        eventObjectiveFirst = {},
        spellObjectiveFirst = {},
    }

    ---Range check over `mock.minSupportedContract .. mock.contractVersion`, read at call time so a
    ---test can move the provider's range after installing the fake.
    ---@param required number
    ---@return boolean ok
    ---@return string? message
    function lib.RequireContract(required)
        if type(required) == "number" and required >= mock.minSupportedContract and required <= mock.contractVersion then
            return true
        end
        return false, ("QuestieTDB contract mismatch: this consumer needs version %s, the installed QuestieTDB provides %s " ..
            "(supporting consumers back to %s). Update whichever is older.")
            :format(tostring(required), tostring(mock.contractVersion), tostring(mock.minSupportedContract))
    end

    lib.l10n = {currentLocale = "enUS"}

    ---Records the forwarded locale. Built-in translations are not modeled; a locale change only
    ---drops the Name indexes, as provider invalidation does.
    ---@param locale string
    ---@return nil
    function lib.l10n.SetLocale(locale)
        lib.l10n.currentLocale = locale
        table.insert(mock.setLocaleCalls, locale)
        InvalidateNameIndexes()
    end

    -------------------------------------------------------------------------------------------
    -- Correction Overlay: owner ranking, layer rebuild, per-datatype publish
    -------------------------------------------------------------------------------------------

    ---Owner precedence is fixed by the first apply or Set; later refreshes stay in place.
    ---@param owner string
    ---@return nil
    local function RankOwner(owner)
        if not ownerRank[owner] then
            table.insert(ownerOrder, owner)
            ownerRank[owner] = #ownerOrder
        end
    end

    ---@param owner string
    ---@return nil
    local function EnsureOwnerState(owner)
        mock.registrations[owner] = mock.registrations[owner] or {}
        mock.applyCount[owner] = mock.applyCount[owner] or 0
    end

    ---Rebuilds one owner's layer from its entries: function providers run again, data slots are
    ---used as-is. Nothing accumulates across rebuilds, so an entry returning or holding `{}`
    ---withdraws its earlier rows.
    ---@param owner string
    ---@return nil
    local function RebuildOwnerLayer(owner)
        local ordered = {}
        for index, registration in ipairs(mock.registrations[owner]) do
            ordered[index] = registration
        end
        table.sort(ordered, function(a, b)
            if a.order ~= b.order then
                return a.order < b.order
            end
            return a.sequence < b.sequence
        end)

        local layer = {Quest = {}, Npc = {}, Item = {}, Object = {}}
        for _, registration in ipairs(ordered) do
            local rows = registration.rows
            if rows == nil then
                rows = registration.provider()
                if type(rows) ~= "table" then
                    error(("QuestieTDBMock: correction %q must return a table"):format(registration.name), 2)
                end
            end
            for id, fields in pairs(rows) do
                local row = layer[registration.datatype][id] or {}
                layer[registration.datatype][id] = row
                for fieldIndex, value in pairs(fields) do
                    row[fieldIndex] = value
                end
            end
        end
        layers[owner] = layer
    end

    ---Drops the shared ID map and Name index of exactly the given datatypes, as the provider's
    ---per-datatype publish does. Untouched datatypes keep both.
    ---@param datatypes table<QuestieTDBMockDatatype, true>
    ---@return nil
    local function PublishDatatypes(datatypes)
        for datatype in pairs(datatypes) do
            idMaps[datatype] = nil
            nameIndexes[datatype] = nil
            mock.publishCounts[datatype] = mock.publishCounts[datatype] + 1
        end
    end

    ---@param owner string
    ---@return table registrar `{RegisterRuntimeCorrection = fun(...), Apply = fun(), Set = fun(...)}`
    function lib.GetRegistrar(owner)
        if type(owner) ~= "string" or owner == "" then
            error("QuestieTDBMock: registrar owner must be a non-empty string", 2)
        end
        EnsureOwnerState(owner)
        local registrar = {}

        ---Append-only, like the provider: registering one name twice keeps both entries.
        ---@param datatype QuestieTDBMockDatatype
        ---@param name string
        ---@param provider fun(): QuestieTDBMockRows
        ---@param loadOrder number? Sequence within this owner; later values overwrite earlier ones.
        ---@return nil
        function registrar.RegisterRuntimeCorrection(datatype, name, provider, loadOrder)
            AssertDatatype(datatype)
            if type(name) ~= "string" then
                error("QuestieTDBMock: correction name must be a string", 2)
            end
            if type(provider) ~= "function" then
                error(("QuestieTDBMock: correction %q must be registered as a provider function"):format(name), 2)
            end
            if loadOrder ~= nil and type(loadOrder) ~= "number" then
                error(("QuestieTDBMock: correction %q needs a numeric loadOrder or none"):format(name), 2)
            end
            registrationSequence = registrationSequence + 1
            table.insert(mock.registrations[owner], {
                datatype = datatype,
                name = name,
                provider = provider,
                loadOrder = loadOrder,
                order = loadOrder or (registrationSequence * 0.001),
                sequence = registrationSequence,
            })
        end

        ---Runs every provider again and rebuilds this owner's layer from scratch, then republishes
        ---the datatypes this owner has entries in — other datatypes keep their ID maps and indexes.
        ---@return nil
        function registrar.Apply()
            RebuildOwnerLayer(owner)
            RankOwner(owner)
            mock.applyCount[owner] = mock.applyCount[owner] + 1

            local touched = {}
            for _, registration in ipairs(mock.registrations[owner]) do
                touched[registration.datatype] = true
            end
            PublishDatatypes(touched)
        end

        ---@param datatype QuestieTDBMockDatatype
        ---@param name string
        ---@param rows QuestieTDBMockRows?
        ---@return boolean changed
        function registrar.Set(datatype, name, rows)
            return lib.Corrections.Set(owner, datatype, name, rows)
        end

        return registrar
    end

    lib.Corrections = {}

    ---Data-shaped write-through slot, as the provider's `Corrections.Set`: each (owner, datatype,
    ---name) holds one rows table; writing replaces it, nil removes it, and only the written
    ---datatype is republished. A name registered as a function correction is refused.
    ---@param owner string
    ---@param datatype QuestieTDBMockDatatype
    ---@param name string
    ---@param rows QuestieTDBMockRows?
    ---@return boolean changed False only when removing a slot that does not exist.
    function lib.Corrections.Set(owner, datatype, name, rows)
        if type(owner) ~= "string" or owner == "" then
            error("QuestieTDBMock: Set owner must be a non-empty string", 2)
        end
        AssertDatatype(datatype)
        if type(name) ~= "string" or name == "" then
            error("QuestieTDBMock: Set name must be a non-empty string", 2)
        end
        if rows ~= nil and type(rows) ~= "table" then
            error(("QuestieTDBMock: Set rows for %q must be a table or nil"):format(name), 2)
        end
        EnsureOwnerState(owner)

        local entryIndex
        for index, registration in ipairs(mock.registrations[owner]) do
            if registration.datatype == datatype and registration.name == name then
                if registration.provider then
                    error(("QuestieTDBMock: %q is a function-shaped correction; update its captured state and Apply instead"):format(name), 2)
                end
                entryIndex = index
                break
            end
        end

        if rows == nil then
            if not entryIndex then
                return false
            end
            table.remove(mock.registrations[owner], entryIndex)
        elseif entryIndex then
            mock.registrations[owner][entryIndex].rows = rows
        else
            registrationSequence = registrationSequence + 1
            table.insert(mock.registrations[owner], {
                datatype = datatype,
                name = name,
                rows = rows,
                order = registrationSequence * 0.001,
                sequence = registrationSequence,
            })
        end

        RebuildOwnerLayer(owner)
        RankOwner(owner)
        PublishDatatypes({[datatype] = true})
        return true
    end

    ---@param datatype QuestieTDBMockDatatype
    ---@param id number
    ---@param key string|integer
    ---@return string|nil owner Owner whose value a reader receives, `"QuestieTDB"` for base data.
    function lib.Corrections.GetProvenance(datatype, id, key)
        AssertDatatype(datatype)
        local fieldIndex = FieldIndex(datatype, key)
        if not Exists(datatype, id) then
            return nil
        end
        local _, owner = ComposedValue(datatype, id, fieldIndex)
        return owner
    end
    lib.GetProvenance = lib.Corrections.GetProvenance
    lib.SetCorrection = lib.Corrections.Set

    ---@return string[] owners `"QuestieTDB"` followed by registered owners in first-apply order.
    function lib.GetOwners()
        local owners = {BASE_OWNER}
        for _, owner in ipairs(ownerOrder) do
            owners[#owners + 1] = owner
        end
        return owners
    end

    -------------------------------------------------------------------------------------------
    -- Test seams
    -------------------------------------------------------------------------------------------

    ---Seeds or replaces one base row and drops the derived ID maps and Name indexes.
    ---@param datatype QuestieTDBMockDatatype
    ---@param id number
    ---@param row QuestieTDBMockRow
    ---@return nil
    function mock.SetBaseRow(datatype, id, row)
        AssertDatatype(datatype)
        mock.base[datatype][id] = row
        InvalidateIdMaps()
        InvalidateNameIndexes()
    end

    mock.lib = lib
    _G.LibQuestieDB = lib
    LoadQuestieTDBMetaMock()

    return mock
end

return LoadQuestieTDBMock
