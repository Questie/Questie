format = string.format
local function countTable(table)
    local count = 0
    for _ in pairs(table) do
        count = count + 1
    end
    return count
end

function DumpQuests(questsData, output)
    -- Sort ids on a table and loop through them
    local sortedQuestIds = {}
    for questId in pairs(questsData) do
        table.insert(sortedQuestIds, questId)
    end
    table.sort(sortedQuestIds)


    -- local QuestieDBCompiler = QuestieLoader:ImportModule("DBCompiler")
    local format = string.format
    -- local questsData = "{\n"
    local file = io.open(output, "w")
    file:write("{\n")
    local count = 0
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
        --print("Quest", questId)
        local data = ""
        data = data .. format("[%s] = {", questId)
        -- Replace ' with \' and " with \" in quest name
        questData[1] = questData[1]:gsub("'", "\\'")
        questData[1] = questData[1]:gsub('"', '\\"')
        data = data .. format("'%s',", questData[1] or "nil")
        -- startedBy
        if questData[2] then
            data = data .. "{"
            for i = 1, 3 do
                if questData[2][i] then
                    data = data .. "{"
                    for _, npc in pairs(questData[2][i]) do
                        data = data .. format("%s,", npc)
                    end
                    data = data .. "},"
                else
                    data = data .. "nil,"
                end
            end
            data = data .. "},"
        else
            data = data .. "nil,"
        end
        -- finishedBy
        if questData[3] then
            data = data .. "{"
            for i = 1, 2 do
                if questData[3][i] then
                    data = data .. "{"
                    for _, npc in pairs(questData[3][i]) do
                        data = data .. format("%s,", npc)
                    end
                    data = data .. "},"
                else
                    data = data .. "nil,"
                end
            end
            data = data .. "},"
        else
            data = data .. "nil,"
        end
        -- requiredLevel
        data = data .. format("%s,", questData[4] or "nil")
        -- questLevel
        data = data .. format("%s,", questData[5] or "nil")
        -- requiredRaces
        data = data .. format("%s,", questData[6] or "nil")
        -- requiredClasses
        data = data .. format("%s,", questData[7] or "nil")
        -- objectivesText
        if questData[8] then
            data = data .. "{"
            for _, text in pairs(questData[8]) do
                -- Replace ' with \' and " with \" in quest name
                local fixedText = text:gsub("'", "\\'")
                fixedText = fixedText:gsub('"', '\\"')
                data = data .. format('"%s",', fixedText)
            end
            data = data .. "},"
        else
            data = data .. "nil,"
        end
        -- triggerEnd
        if questData[9] then
            data = data .. "{"
            -- Replace ' with \' and " with \" in quest name
            local fixedText = questData[9][1]:gsub("'", "\\'")
            fixedText = fixedText:gsub('"', '\\"')
            data = data .. format('"%s", ', fixedText)
            data = data .. format("{")
            if not questData[9][2] then
                error("No coords for quest " .. questId)
            end
            for zoneId, coords in pairs(questData[9][2]) do
                data = data .. format("[%s] = {", zoneId)
                for _, coord in pairs(coords) do
                    data = data .. "{"
                    for _, value in pairs(coord) do
                        data = data .. format("%s,", value)
                    end
                    data = data .. "},"
                end
                data = data .. "},"
            end
            data = data .. "},"
            data = data .. "},"
        else
            data = data .. "nil,"
        end
        -- objectives
        if questData[10] then
            data = data .. "{"
            --creatureObjective
            --objectObjective
            --itemObjective
            for i = 1, 3 do
                if questData[10][i] then
                    data = data .. "{"
                    -- if type(questData[10][i]) ~= "table" then
                    --     print(questId)
                    --     print(i)
                    --     print(questData[10][i])
                    -- end
                    for _, objective in pairs(questData[10][i]) do
                        data = data .. "{"
                        for _, value in pairs(objective) do
                            if type(value) == "string" then
                                -- Replace ' with \' and " with \" in quest name
                                local fixedText = value:gsub("'", "\\'")
                                fixedText = fixedText:gsub('"', '\\"')
                                data = data .. format('"%s",', fixedText)
                            else
                                data = data .. format("%s,", value)
                            end
                        end
                        data = data .. "},"
                    end
                    data = data .. "},"
                else
                    data = data .. "nil,"
                end
            end
            -- reputationObjective
            if questData[10][4] then
                data = data .. "{"
                data = data .. format('%s, %s', questData[10][4][1], questData[10][4][2])
                data = data .. "},"
            else
                data = data .. "nil,"
            end
            --! NOT TESTED
            ---@class RawKillObjective : { [1]: NpcId[], [2]: NpcId, [3]: string }
            if questData[10][5] then
                data = data .. "{"
                for _, objective in pairs(questData[10][5]) do
                    data = data .. "{"
                    data = data .. "{"
                    for _, npcId in pairs(objective[1]) do
                        data = data .. format("%s,", npcId)
                    end
                    data = data .. "},"
                    data = data .. format("%s,", objective[2])
                    if objective[3] then
                        -- Replace ' with \' and " with \" in quest name
                        local fixedText = objective[3]:gsub("'", "\\'")
                        fixedText = fixedText:gsub('"', '\\"')
                        data = data .. format('"%s",', fixedText)
                        --? we don't print nil here because i am pretty sure that this is not actually used.
                    end
                    data = data .. "},"
                end
                data = data .. "},"
            else
                data = data .. "nil,"
            end

            data = data .. "},"
        else
            data = data .. "nil,"
        end
        -- sourceItemId
        data = data .. format("%s,", questData[11] or "nil")
        -- preQuestGroup
        if questData[12] and countTable(questData[12]) > 0 then
            data = data .. "{"
            for _, quest in pairs(questData[12]) do
                data = data .. format("%s,", quest)
            end
            data = data .. "},"
        else
            data = data .. "nil,"
        end
        -- preQuestSingle
        if questData[13] and countTable(questData[13]) > 0 then
            data = data .. "{"
            for _, quest in pairs(questData[13]) do
                data = data .. format("%s,", quest)
            end
            data = data .. "},"
        else
            data = data .. "nil,"
        end
        -- childQuests
        if questData[14] and countTable(questData[14]) > 0 then
            data = data .. "{"
            for _, quest in pairs(questData[14]) do
                data = data .. format("%s,", quest)
            end
            data = data .. "},"
        else
            data = data .. "nil,"
        end
        -- inGroupWith
        if questData[15] and countTable(questData[15]) > 0 then
            data = data .. "{"
            for _, quest in pairs(questData[15]) do
                data = data .. format("%s,", quest)
            end
            data = data .. "},"
        else
            data = data .. "nil,"
        end
        -- exclusiveTo
        if questData[16] and countTable(questData[16]) > 0 then
            data = data .. "{"
            for _, quest in pairs(questData[16]) do
                data = data .. format("%s,", quest)
            end
            data = data .. "},"
        else
            data = data .. "nil,"
        end
        -- zoneOrSort
        data = data .. format("%s,", questData[17] or "nil")
        -- requiredSkill
        if questData[18] and countTable(questData[18]) > 0 then
            data = data .. "{"
            data = data .. format("%s,%s", questData[18][1] or "nil", questData[18][2] or "nil")
            data = data .. "},"
        else
            data = data .. "nil,"
        end
        -- requiredMinRep
        if questData[19] and countTable(questData[19]) > 0 then
            data = data .. "{"
            data = data .. format("%s,%s", questData[19][1] or "nil", questData[19][2] or "nil")
            data = data .. "},"
        else
            data = data .. "nil,"
        end
        -- requiredMaxRep
        if questData[20] and countTable(questData[20]) > 0 then
            data = data .. "{"
            data = data .. format("%s,%s", questData[20][1] or "nil", questData[20][2] or "nil")
            data = data .. "},"
        else
            data = data .. "nil,"
        end
        -- requiredSourceItems
        if questData[21] and countTable(questData[21]) > 0 then
            data = data .. "{"
            for _, item in pairs(questData[21]) do
                data = data .. format("%s,", item)
            end
            data = data .. "},"
        else
            data = data .. "nil,"
        end
        -- nextQuestInChain
        data = data .. format("%s,", questData[22] or "nil")
        -- questFlags
        data = data .. format("%s,", questData[23] or "nil")
        -- specialFlags
        data = data .. format("%s,", questData[24] or "nil")
        -- parentQuest
        data = data .. format("%s,", questData[25] or "nil")
        -- rewardReputation
        if questData[26] and countTable(questData[26]) > 0 then
            data = data .. "{"
            for _, faction in pairs(questData[26]) do
                data = data .. "{"
                data = data .. format("%s,%s", faction[1] or "nil", faction[2] or "nil")
                data = data .. "},"
            end
            data = data .. "},"
        else
            data = data .. "nil,"
        end
        -- extraObjectives
        -- @class ExtraObjective
        -- @field [1] table<AreaId, CoordPair[]>? spawnList
        -- @field [2] string iconFile path
        -- @field [3] string Objective Text
        -- @field [4] ObjectiveIndex? Optional ObjectiveIndex
        -- @field [5] table<"monster"|"object", function>? dbReference which uses _QuestieQuest.objectiveSpawnListCallTable to fetch spawns
        if questData[27] and countTable(questData[27]) > 0 then
            data = data .. "{"
            for _, objective in pairs(questData[27]) do
                data = data .. "{"
                if objective[1] and countTable(objective[1]) > 0 then
                    data = data .. "{"
                    for zoneId, coords in pairs(objective[1]) do
                        data = data .. format("[%s] = {", zoneId)
                        for _, coord in pairs(coords) do
                            data = data .. "{"
                            for _, value in pairs(coord) do
                                data = data .. format("%s,", value)
                            end
                            data = data .. "},"
                        end
                        data = data .. "},"
                    end
                    data = data .. "},"
                else
                    data = data .. "nil,"
                end
                data = data .. format("%s,", objective[2] or "nil")
                if objective[3] then
                    -- Replace ' with \' and " with \" in quest name
                    objective[3] = objective[3]:gsub("'", "\\'")
                    objective[3] = objective[3]:gsub('"', '\\"')
                    data = data .. format("'%s',", objective[3] or "nil")
                else
                    data = data .. "nil,"
                end
                data = data .. format("%s,", objective[4] or "nil")
                if objective[5] and countTable(objective[5]) > 0 then
                    data = data .. "{"
                    for _, dbReference in pairs(objective[5]) do
                        data = data .. "{"
                        data = data .. format("%s,%s", dbReference[1] or "nil", dbReference[2] or "nil")
                        data = data .. "},"
                    end
                    data = data .. "},"
                else
                    data = data .. "nil,"
                end
                data = data .. "},"
            end
            data = data .. "},"
        else
            data = data .. "nil,"
        end
        -- requiredSpell
        data = data .. format("%s,", questData[28] or "nil")
        -- requiredSpecialization
        data = data .. format("%s,", questData[29] or "nil")


        count = count + 1

        data = data .. "}"
        -- print(data)
        local loadedData = loadstring("return {" .. data .. "}")()
        file:write("  " .. data .. ",\n")
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

    -- local npcsData = "{\n"
    local file = io.open(output, "w")
    file:write("{\n")
    local count = 0
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
        --print("Npc", npcId)
        local data = ""
        data = data .. format("[%s] = {", npcId)
        -- Replace ' with \' and " with \" in npc name
        npcData[1] = npcData[1]:gsub("'", "\\'")
        npcData[1] = npcData[1]:gsub('"', '\\"')
        data = data .. format("'%s',", npcData[1] or "nil")
        -- do -- Default
        --     -- minLevelHealth, We will stop supporting this value
        --     -- data = data .. format("%s,", npcData[2] or "nil")
        --     data = data .. "nil,"
        --     -- maxLevelHealth, We will stop supporting this value
        --     -- data = data .. format("%s,", npcData[3] or "nil")
        --     data = data .. "nil,"
        --     -- minLevel, Only write the data if it is greater than 1
        --     data = data .. format("%s,", npcData[4] and npcData[4] > 1 and npcData[4] or "nil")
        --     -- maxLevel, Only write the data if it is greater than 1
        --     data = data .. format("%s,", npcData[5] and npcData[5] > 1 and npcData[5] or "nil")
        --     -- rank, Only write the data if it is not 0
        --     data = data .. format("%s,", npcData[6] and npcData[6] ~= 0 and npcData[6] or "nil")
        -- end
        do -- Improved
            -- minLevelHealth, We will stop supporting this value
            data = data .. format("'%s;", npcData[2] or "0")
            -- maxLevelHealth, We will stop supporting this value
            data = data .. format("%s;", npcData[3] or "0")
            -- minLevel, Only write the data if it is greater than 1
            data = data .. format("%s;", npcData[4] or "0")
            -- maxLevel, Only write the data if it is greater than 1
            data = data .. format("%s;", npcData[5] or "0")
            -- rank, Only write the data if it is not 0
            data = data .. format("%s',", npcData[6] or "0")
        end
        -- spawns
        if npcData[7] and countTable(npcData[7]) > 0 then
            data = data .. "{"
            for zoneId, coords in pairs(npcData[7]) do
                data = data .. format("[%s] = {", zoneId)
                for _, coord in pairs(coords) do
                    data = data .. "{"
                    for _, value in pairs(coord) do
                        data = data .. format("%s,", value)
                    end
                    data = data .. "},"
                end
                data = data .. "},"
            end
            data = data .. "},"
        else
            data = data .. "nil,"
        end
        -- waypoints
        if npcData[8] and countTable(npcData[8]) > 0 then
            data = data .. "{"
            for _, waypoint in pairs(npcData[8]) do
                for zoneId, coords in pairs(waypoint) do
                    data = data .. format("[%s] = {", zoneId)
                    for _, coord in pairs(coords) do
                        data = data .. "{"
                        for _, value in pairs(coord) do
                            data = data .. format("%s,", value)
                        end
                        data = data .. "},"
                    end
                    data = data .. "},"
                end
            end
            data = data .. "},"
        else
            data = data .. "nil,"
        end
        -- zoneID, Only write the data if it is not 0
        data = data .. format("%s,", npcData[9] and npcData[9] ~= 0 and npcData[9] or "nil")
        -- questStarts
        if npcData[10] and countTable(npcData[10]) > 0 then
            data = data .. "{"
            for _, quest in pairs(npcData[10]) do
                data = data .. format("%s,", quest)
            end
            data = data .. "},"
        else
            data = data .. "nil,"
        end
        -- questEnds
        if npcData[11] and countTable(npcData[11]) > 0 then
            data = data .. "{"
            for _, quest in pairs(npcData[11]) do
                data = data .. format("%s,", quest)
            end
            data = data .. "},"
        else
            data = data .. "nil,"
        end
        -- factionID
        data = data .. format("%s,", npcData[12] or "nil")
        -- friendlyToFaction
        data = data .. format("'%s',", npcData[13] or "nil")
        -- subName
        if npcData[14] then
            -- Replace ' with \' and " with \" in npc name
            npcData[14] = npcData[14]:gsub("'", "\\'")
            npcData[14] = npcData[14]:gsub('"', '\\"')
            data = data .. format("'%s',", npcData[14] or "nil")
        else
            data = data .. "nil,"
        end
        -- npcFlags
        data = data .. format("%s,", npcData[15] ~= 0 and npcData[15] or "nil")

        count = count + 1

        data = data .. "}"
        -- print(data)
        local loadedData = loadstring("return {" .. data .. "}")()
        file:write("  " .. data .. ",\n")
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
    local count = 0
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
        --print("Object", objectId)
        local data = ""
        data = data .. format("[%s] = {", objectId)
        -- Replace ' with \' and " with \" in object name
        objectData[1] = objectData[1]:gsub("'", "\\'")
        objectData[1] = objectData[1]:gsub('"', '\\"')
        data = data .. format("'%s',", objectData[1] or "nil")
        -- questStarts
        if objectData[2] and countTable(objectData[2]) > 0 then
            data = data .. "{"
            for _, quest in pairs(objectData[2]) do
                data = data .. format("%s,", quest)
            end
            data = data .. "},"
        else
            data = data .. "nil,"
        end
        -- questEnds
        if objectData[3] and countTable(objectData[3]) > 0 then
            data = data .. "{"
            for _, quest in pairs(objectData[3]) do
                data = data .. format("%s,", quest)
            end
            data = data .. "},"
        else
            data = data .. "nil,"
        end
        -- spawns
        if objectData[4] and countTable(objectData[4]) > 0 then
            local objectSpawns = "{"
            for zoneId, coords in pairs(objectData[4]) do
                objectSpawns = objectSpawns .. format("[%s] = {", zoneId)
                for _, coord in pairs(coords) do
                    objectSpawns = objectSpawns .. "{"
                    for _, value in pairs(coord) do
                        objectSpawns = objectSpawns .. format("%s,", value)
                    end
                    objectSpawns = objectSpawns .. "},"
                end
                objectSpawns = objectSpawns .. "},"
            end
            objectSpawns = objectSpawns .. "},"
            -- local configs = { level = 9 , strategy = "dynamic" }
            -- local compress_deflate = deflate:CompressDeflate(objectSpawns, configs)
            -- -- error(compress_deflate)
            -- local compress_base64 = deflate:EncodeForPrint(compress_deflate)
            -- print(compress_base64)
            data = data .. format("'%s',", objectSpawns)
        else
            data = data .. "nil,"
        end
        -- zoneID, Only write the data if it is not 0
        data = data .. format("%s,", objectData[5] and objectData[5] ~= 0 and objectData[5] or "nil")
        -- factionID
        data = data .. format("%s,", objectData[6] or "nil")

        count = count + 1

        data = data .. "}"
        -- print(data)
        local loadedData = loadstring("return {" .. data .. "}")()
        file:write("  " .. data .. ",\n")
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

    local file = io.open(output, "w")
    file:write("{\n")
    local count = 0
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
    for _, itemId in ipairs(sortedItemIds) do
        local itemData = itemsData[itemId]
        --print("Item", itemId)
        local data = ""
        data = data .. format("[%s] = {", itemId)
        -- Replace ' with \' and " with \" in item name
        itemData[1] = itemData[1]:gsub("'", "\\'")
        itemData[1] = itemData[1]:gsub('"', '\\"')
        data = data .. format("'%s',", itemData[1] or "nil")
        -- npcDrops
        if itemData[2] and countTable(itemData[2]) > 0 then
            data = data .. "{"
            for _, npcId in pairs(itemData[2]) do
                data = data .. format("%s,", npcId)
            end
            data = data .. "},"
        else
            data = data .. "nil,"
        end
        -- objectDrops
        if itemData[3] and countTable(itemData[3]) > 0 then
            data = data .. "{"
            for _, objectId in pairs(itemData[3]) do
                data = data .. format("%s,", objectId)
            end
            data = data .. "},"
        else
            data = data .. "nil,"
        end
        -- itemDrops
        if itemData[4] and countTable(itemData[4]) > 0 then
            data = data .. "{"
            for _, itemIdd in pairs(itemData[4]) do
                data = data .. format("%s,", itemIdd)
            end
            data = data .. "},"
        else
            data = data .. "nil,"
        end
        -- startQuest
        data = data .. format("%s,", itemData[5] or "nil")
        -- questRewards
        if itemData[6] and countTable(itemData[6]) > 0 then
            data = data .. "{"
            for _, questId in pairs(itemData[6]) do
                data = data .. format("%s,", questId)
            end
            data = data .. "},"
        else
            data = data .. "nil,"
        end
        -- do -- default
        --     -- flags
        --     data = data .. format("%s,", itemData[7] or "nil")
        --     -- foodType
        --     data = data .. format("%s,", itemData[8] or "nil")
        --     -- itemLevel
        --     data = data .. format("%s,", itemData[9] or "nil")
        --     -- requiredLevel
        --     data = data .. format("%s,", itemData[10] or "nil")
        --     -- ammoType, 0 = no ammo
        --     data = data .. format("%s,", itemData[11] and itemData[11] ~= 0 and itemData[11] or "nil")
        --     -- class
        --     data = data .. format("%s,", itemData[12] or "nil")
        --     -- subClass
        --     data = data .. format("%s,", itemData[13] or "nil")
        -- end
        do -- improved
            -- flags
            data = data .. format("'%s;", itemData[7] or "0")
            -- foodType
            data = data .. format("%s;", itemData[8] or "0")
            -- itemLevel
            data = data .. format("%s;", itemData[9] or "0")
            -- requiredLevel
            data = data .. format("%s;", itemData[10] or "0")
            -- ammoType, 0 = no ammo
            data = data .. format("%s;", itemData[11] or "0")
            -- class
            data = data .. format("%s;", itemData[12] or "nil")
            -- subClass
            data = data .. format("%s',", itemData[13] or "nil")
        end
        -- vendors
        if itemData[14] and countTable(itemData[14]) > 0 then
            data = data .. "{"
            for _, npcId in pairs(itemData[14]) do
                data = data .. format("%s,", npcId)
            end
            data = data .. "},"
        else
            data = data .. "nil,"
        end
        -- relatedQuests
        if itemData[15] and countTable(itemData[15]) > 0 then
            data = data .. "{"
            for _, questId in pairs(itemData[15]) do
                data = data .. format("%s,", questId)
            end
            data = data .. "},"
        else
            data = data .. "nil,"
        end

        count = count + 1

        data = data .. "}"
        -- print(data)
        local loadedData = loadstring("return {" .. data .. "}")()
        file:write("  " .. data .. ",\n")
    end
    file:write("}")
    file:close()
end

function DumpItems2(itemsData, output)
    local sortedItemIds = {}
    for itemId in pairs(itemsData) do
        table.insert(sortedItemIds, itemId)
    end
    table.sort(sortedItemIds)

    local file = io.open(output, "w")
    -- table.save(itemsData, output)
    file:write("{\n")
    local count = 0
    for _, objectId in ipairs(sortedItemIds) do
        local itemData = itemsData[objectId]
        file:write(SerializeTable(itemData, objectId, true, 0) .. ",\n")
    end
    file:write("}")
    file:close()
end

-- function SerializeTable(val, name, skipnewlines)
--     skipnewlines = skipnewlines or false

--     local tmp = ""

--     if name then tmp = tmp .. "  [" .. name .. "]=" end

--     if type(val) == "table" then
--         tmp = tmp .. "{"
--         local maxIndex = 0
--         for k, v in pairs(val) do
--             if type(k) == "number" and k > maxIndex then
--                 maxIndex = k
--             end
--         end
--         for i = 1, maxIndex do
--             if val[i] then
--                 tmp = tmp .. SerializeTable(val[i], nil, skipnewlines) .. ","
--             else
--                 tmp = tmp .. "nil,"
--             end
--             if not skipnewlines then
--                 tmp = tmp .. "\n"
--             end
--         end

--         tmp = tmp .. "}"
--     elseif type(val) == "number" then
--         tmp = tmp .. tostring(val)
--     elseif type(val) == "string" then
--         -- Replace ' with \' and " with \" in npc name
--         local data = val
--         data = data:gsub("'", "\\'")
--         data = data:gsub('"', '\\"')
--         tmp = tmp .. format("'%s'", data)
--     elseif type(val) == "boolean" then
--         tmp = tmp .. (val and "true" or "false")
--     else
--         tmp = tmp .. "nil"
--     end

--     return tmp
-- end
