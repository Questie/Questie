local deflate = require("cli.LibDeflate")
local format = string.format
local type = type
local tostring = tostring

local function countTable(table)
    local count = 0
    for _ in pairs(table) do
        count = count + 1
    end
    return count
end

local serializeTable = nil
function SerializeTable(val, name, skipnewlines)
    skipnewlines = skipnewlines or false

    local tmp = ""

    if name then tmp = tmp .. "  [" .. name .. "]=" end

    if type(val) == "table" then
        tmp = tmp .. "{"
        local maxIndex = countTable(val)
        for i = 1, maxIndex do
            if val[i] then
                tmp = tmp .. serializeTable(val[i], nil, skipnewlines) .. ","
            else
                tmp = tmp .. "nil,"
            end
            if not skipnewlines then
                tmp = tmp .. "\n"
            end
        end

        tmp = tmp .. "}"
    elseif type(val) == "number" then
        tmp = tmp .. tostring(val)
    elseif type(val) == "string" then
        -- Replace ' with \' and " with \" in npc name
        local data = val
        data = data:gsub("'", "\\'")
        data = data:gsub('"', '\\"')
        tmp = tmp .. format("'%s'", data)
    elseif type(val) == "boolean" then
        tmp = tmp .. (val and "true" or "false")
    else
        tmp = tmp .. "nil"
    end

    return tmp
end
serializeTable = SerializeTable

function DumpQuests(questsData, output)
    -- Sort ids on a table and loop through them
    local sortedQuestIds = {}
    for questId in pairs(questsData) do
        table.insert(sortedQuestIds, questId)
    end
    table.sort(sortedQuestIds)

    local file = io.open(output, "w")
    file:write("{\n")
    -- for questId, questData in pairs(questsData) do
    -- QuestieDB.questKeys = {
    --     ['name'] = 1, -- string
    --     ['startedBy'] = 2, -- table
    --     --['creatureStart'] = 1, -- table {creature(int),...}
    --     --['objectStart'] = 2, -- table {object(int),...}
    --     --['itemStart'] = 3, -- table {item(int),...}
    --     ['finishedBy'] = 3, -- table
    --     --['creatureEnd'] = 1, -- table {creature(int),...}
    --     --['objectEnd'] = 2, -- table {object(int),...}
    --     ['requiredLevel'] = 4, -- int
    --     ['questLevel'] = 5, -- int
    --     ['requiredRaces'] = 6, -- bitmask
    --     ['requiredClasses'] = 7, -- bitmask
    --     ['objectivesText'] = 8, -- table: {string,...}, Description of the quest. Auto-complete if nil.
    --     ['triggerEnd'] = 9, -- table: {text, {[zoneID] = {coordPair,...},...}}
    --     ['objectives'] = 10, -- table
    --     --['creatureObjective'] = 1, -- table {{creature(int), text(string)},...}, If text is nil the default "<Name> slain x/y" is used
    --     --['objectObjective'] = 2, -- table {{object(int), text(string)},...}
    --     --['itemObjective'] = 3, -- table {{item(int), text(string)},...}
    --     --['reputationObjective'] = 4, -- table: {faction(int), value(int)}
    --     --['killCreditObjective'] = 5, -- table: {{{creature(int), ...}, baseCreatureID, baseCreatureText}, ...}
    --     ['sourceItemId'] = 11,   -- int, item provided by quest starter
    --     ['preQuestGroup'] = 12,  -- table: {quest(int)}
    --     ['preQuestSingle'] = 13, -- table: {quest(int)}
    --     ['childQuests'] = 14,    -- table: {quest(int)}
    --     ['inGroupWith'] = 15,    -- table: {quest(int)}
    --     ['exclusiveTo'] = 16,    -- table: {quest(int)}
    --     ['zoneOrSort'] = 17,     -- int, >0: AreaTable.dbc ID; <0: QuestSort.dbc ID
    --     ['requiredSkill'] = 18,  -- table: {skill(int), value(int)}
    --     ['requiredMinRep'] = 19, -- table: {faction(int), value(int)}
    --     ['requiredMaxRep'] = 20, -- table: {faction(int), value(int)}
    --     ['requiredSourceItems'] = 21, -- table: {item(int), ...} Items that are not an objective but still needed for the quest.
    --     ['nextQuestInChain'] = 22, -- int: if this quest is active/finished, the current quest is not available anymore
    --     ['questFlags'] = 23,     -- bitmask: see https://github.com/cmangos/issues/wiki/Quest_template#questflags
    --     ['specialFlags'] = 24,   -- bitmask: 1 = Repeatable, 2 = Needs event, 4 = Monthly reset (req. 1). See https://github.com/cmangos/issues/wiki/Quest_template#specialflags
    --     ['parentQuest'] = 25,    -- int, the ID of the parent quest that needs to be active for the current one to be available. See also 'childQuests' (field 14)
    --     ['rewardReputation'] = 26, --table: {{faction(int), value(int)},...}, a list of reputation rewarded upon quest completion
    --     ['extraObjectives'] = 27, -- table: {{spawnlist, iconFile, text, objectiveIndex (optional), {{dbReferenceType, id}, ...} (optional)},...}, a list of hidden special objectives for a quest. Similar to requiredSourceItems
    --     ['requiredSpell'] = 28,  -- int: quest is only available if character has this spellID
    --     ['requiredSpecialization'] = 29, -- int: quest is only available if character meets the spec requirements. Use QuestieProfessions.specializationKeys for having a spec, or QuestieProfessions.professionKeys to indicate having the profession with no spec. See QuestieProfessions.lua for more info.
    -- }
    for _, questId in ipairs(sortedQuestIds) do
        local questData = questsData[questId]
        file:write(SerializeTable(questData, questId, true, 0) .. ",\n")
    end
    file:write("}")
    file:close()
end

function DumpNpcs(npcsData, output)
    -- Sort ids on a table and loop through them
    local sortedNpcIds = {}
    for npcId in pairs(npcsData) do
        table.insert(sortedNpcIds, npcId)
    end
    table.sort(sortedNpcIds)

    local file = io.open(output, "w")
    file:write("{\n")
    -- QuestieDB.npcKeys = {
    --     ['name'] = 1,           -- string
    --     ['minLevelHealth'] = 2, -- int
    --     ['maxLevelHealth'] = 3, -- int
    --     ['minLevel'] = 4,       -- int
    --     ['maxLevel'] = 5,       -- int
    --     ['rank'] = 6,           -- int, see https://github.com/cmangos/issues/wiki/creature_template#rank
    --     ['spawns'] = 7,         -- table {[zoneID(int)] = {coordPair(floatVector2D),...},...}
    --     ['waypoints'] = 8,      -- table {[zoneID(int)] = {coordPair(floatVector2D),...},...}
    --     ['zoneID'] = 9,         -- guess as to where this NPC is most common
    --     ['questStarts'] = 10,   -- table {questID(int),...}
    --     ['questEnds'] = 11,     -- table {questID(int),...}
    --     ['factionID'] = 12,     -- int, see https://github.com/cmangos/issues/wiki/FactionTemplate.dbc
    --     ['friendlyToFaction'] = 13, -- string, Contains "A" and/or "H" depending on NPC being friendly towards those factions. nil if hostile to both.
    --     ['subName'] = 14,       -- string, The title or function of the NPC, e.g. "Weapon Vendor"
    --     ['npcFlags'] = 15,      -- int, Bitmask containing various flags about the NPCs function (Vendor, Trainer, Flight Master, etc.).
    --     -- For flag values see https://github.com/cmangos/mangos-classic/blob/172c005b0a69e342e908f4589b24a6f18246c95e/src/game/Entities/Unit.h#L536
    -- }
    for _, npcId in ipairs(sortedNpcIds) do
        local npcData = npcsData[npcId]
        file:write(SerializeTable(npcData, npcId, true, 0) .. ",\n")
    end
    file:write("}")
    file:close()
end

function DumpObjects(objectsData, output)
    -- Sort ids on a table and loop through them
    local sortedObjectIds = {}
    for objectId in pairs(objectsData) do
        table.insert(sortedObjectIds, objectId)
    end
    table.sort(sortedObjectIds)

    -- local data = "{\n"
    local file = io.open(output, "w")
    file:write("{\n")
    -- QuestieDB.objectKeys = {
    --     ['name'] = 1,    -- string
    --     ['questStarts'] = 2, -- table {questID(int),...}
    --     ['questEnds'] = 3, -- table {questID(int),...}
    --     ['spawns'] = 4,  -- table {[zoneID(int)] = {coordPair(floatVector2D),...},...}
    --     ['zoneID'] = 5,  -- guess as to where this object is most common
    --     ['factionID'] = 6, -- faction restriction mask (same as spawndb factionid)
    -- }
    for _, objectId in ipairs(sortedObjectIds) do
        local objectData = objectsData[objectId]
        file:write(SerializeTable(objectData, objectId, true, 0) .. ",\n")
    end
    file:write("}")
    file:close()
end

function DumpItems(itemsData, output)
    local sortedItemIds = {}
    for itemId in pairs(itemsData) do
        table.insert(sortedItemIds, itemId)
    end
    table.sort(sortedItemIds)

    -- QuestieDB.itemKeys = {
    --     ['name'] = 1, -- string
    --     ['npcDrops'] = 2, -- table or nil, NPC IDs
    --     ['objectDrops'] = 3, -- table or nil, object IDs
    --     ['itemDrops'] = 4, -- table or nil, item IDs
    --     ['startQuest'] = 5, -- int or nil, ID of the quest started by this item
    --     ['questRewards'] = 6, -- table or nil, quest IDs
    --     ['flags'] = 7, -- int or nil, see: https://github.com/cmangos/issues/wiki/Item_template#flags
    --     ['foodType'] = 8, -- int or nil, see https://github.com/cmangos/issues/wiki/Item_template#foodtype
    --     ['itemLevel'] = 9, -- int, the level of this item
    --     ['requiredLevel'] = 10, -- int, the level required to equip/use this item
    --     ['ammoType'] = 11, -- int,
    --     ['class'] = 12, -- int,
    --     ['subClass'] = 13, -- int,
    --     ['vendors'] = 14, -- table or nil, NPC IDs
    --     ['relatedQuests'] = 15, -- table or nil, IDs of quests that are related to this item
    -- }
    local file = io.open(output, "w")
    file:write("{\n")
    for _, itemId in ipairs(sortedItemIds) do
        local itemData = itemsData[itemId]
        file:write(SerializeTable(itemData, itemId, true, 0) .. ",\n")
    end
    file:write("}")
    file:close()
end
