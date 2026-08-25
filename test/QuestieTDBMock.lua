local questKeys = {
    name = 1,
    startedBy = 2,
    finishedBy = 3,
    requiredLevel = 4,
    questLevel = 5,
    requiredRaces = 6,
    requiredClasses = 7,
    objectivesText = 8,
    triggerEnd = 9,
    objectives = 10,
    sourceItemId = 11,
    preQuestGroup = 12,
    preQuestSingle = 13,
    childQuests = 14,
    inGroupWith = 15,
    exclusiveTo = 16,
    zoneOrSort = 17,
    requiredSkill = 18,
    requiredMinRep = 19,
    requiredMaxRep = 20,
    requiredSourceItems = 21,
    nextQuestInChain = 22,
    questFlags = 23,
    specialFlags = 24,
    parentQuest = 25,
    reputationReward = 26,
    breadcrumbForQuestId = 27,
    breadcrumbs = 28,
    extraObjectives = 29,
    requiredSpell = 30,
    requiredSpecialization = 31,
    requiredMaxLevel = 32,
    availableUntilCompleted = 33,
    availableStartingWith = 34,
    requiredRanks = 35,
    disabledByQuest = 36,
}

local npcKeys = {
    name = 1,
    minLevelHealth = 2,
    maxLevelHealth = 3,
    minLevel = 4,
    maxLevel = 5,
    rank = 6,
    spawns = 7,
    waypoints = 8,
    zoneID = 9,
    questStarts = 10,
    questEnds = 11,
    factionID = 12,
    friendlyToFaction = 13,
    subName = 14,
    npcFlags = 15,
}

local itemKeys = {
    name = 1,
    npcDrops = 2,
    objectDrops = 3,
    itemDrops = 4,
    startQuest = 5,
    questRewards = 6,
    flags = 7,
    foodType = 8,
    itemLevel = 9,
    requiredLevel = 10,
    ammoType = 11,
    class = 12,
    subClass = 13,
    vendors = 14,
    relatedQuests = 15,
    teachesSpell = 16,
}

local objectKeys = {
    name = 1,
    questStarts = 2,
    questEnds = 3,
    spawns = 4,
    zoneID = 5,
    factionID = 6,
    waypoints = 7,
}

local function _CopyValue(value)
    if type(value) ~= "table" then
        return value
    end

    local copied = {}
    for key, nestedValue in pairs(value) do
        copied[key] = _CopyValue(nestedValue)
    end
    return copied
end

local function _CreateEntity(keys)
    local rows = {}
    local ids = {}
    local idMap = {}
    local entity = {}

    local function _RefreshIds()
        for index in pairs(ids) do
            ids[index] = nil
        end
        for id in pairs(idMap) do
            idMap[id] = nil
        end

        for id in pairs(rows) do
            ids[#ids + 1] = id
            idMap[id] = true
        end
        table.sort(ids)
    end

    function entity.Get(id, key)
        local row = rows[id]
        if not row then
            return nil
        end

        local fieldIndex = type(key) == "number" and key or keys[key]
        return fieldIndex and _CopyValue(row[fieldIndex]) or nil
    end

    function entity.GetAll(id, requestedKeys)
        if not rows[id] then
            return nil
        end

        local values = {n = #requestedKeys}
        for index, key in ipairs(requestedKeys) do
            values[index] = entity.Get(id, key)
        end
        return values
    end

    function entity.GetAllIds(hashmap)
        return hashmap and idMap or ids
    end

    function entity.Exists(id)
        return rows[id] ~= nil
    end

    return entity, rows, _RefreshIds
end

local Quest, questRows, refreshQuestIds = _CreateEntity(questKeys)
local Npc, npcRows, refreshNpcIds = _CreateEntity(npcKeys)
local Item, itemRows, refreshItemIds = _CreateEntity(itemKeys)
local Object, objectRows, refreshObjectIds = _CreateEntity(objectKeys)

local objectiveFirst = {
    killCreditObjectiveFirst = {},
    objectObjectiveFirst = {},
    itemObjectiveFirst = {},
    eventObjectiveFirst = {},
    spellObjectiveFirst = {},
}

_G.LibQuestieDB = {
    Meta = {
        QuestMeta = {questKeys = questKeys},
        NpcMeta = {npcKeys = npcKeys},
        ItemMeta = {itemKeys = itemKeys},
        ObjectMeta = {objectKeys = objectKeys},
    },
    Quest = Quest,
    Npc = Npc,
    Item = Item,
    Object = Object,
    ObjectiveFirst = objectiveFirst,
}

local contractError
function _G.LibQuestieDB.RequireContract(required)
    if contractError then
        return false, contractError
    end
    if required == 1 then
        return true
    end
    return false, "QuestieTDB contract mismatch"
end

local rowsByType = {
    Quest = questRows,
    Npc = npcRows,
    Item = itemRows,
    Object = objectRows,
}

local refreshIdsByType = {
    Quest = refreshQuestIds,
    Npc = refreshNpcIds,
    Item = refreshItemIds,
    Object = refreshObjectIds,
}

local QuestieTDBMock = {}

local function _ClearTable(target)
    for key in pairs(target) do
        target[key] = nil
    end
end

function QuestieTDBMock.Reset()
    contractError = nil
    for datatype, rows in pairs(rowsByType) do
        _ClearTable(rows)
        refreshIdsByType[datatype]()
    end
    for _, questIds in pairs(objectiveFirst) do
        _ClearTable(questIds)
    end
end

function QuestieTDBMock.SetContractError(message)
    contractError = message
end

function QuestieTDBMock.AddEntity(datatype, id, row)
    rowsByType[datatype][id] = row
    refreshIdsByType[datatype]()
end

function QuestieTDBMock.SetObjectiveFirst(objectiveType, questId)
    objectiveFirst[objectiveType][questId] = true
end

return QuestieTDBMock
