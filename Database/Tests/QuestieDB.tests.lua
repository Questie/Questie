---@class QuestieDBTests
local QuestieDBTests = QuestieLoader:CreateModule("QuestieDBTests")

do
    local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
    local QuestieCorrections = QuestieLoader:ImportModule("QuestieCorrections")

    local QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")
    local _QuestieQuest = QuestieQuest.private

    local QuestieLib = QuestieLoader:ImportModule("QuestieLib")

    local ThreadLib = QuestieLoader:ImportModule("ThreadLib")

    local function equals(a, b)
        if a == nil and b == nil then return true end
        if a == nil or b == nil then return false end
        local ta = type(a)
        local tb = type(b)
        if ta ~= tb then return false end

        if ta == "number" then
            return math.abs(a - b) < 0.2
        elseif ta == "table" then
            for k, v in pairs(a) do
                if not equals(b[k], v) then
                    DevTools_Dump(k, v)
                    return false
                end
            end
            for k, v in pairs(b) do
                if not equals(a[k], v) then
                    DevTools_Dump(k, v)
                    return false
                end
            end
            return true
        elseif ta == "function" and tb == "function" then
            return true
        else
            return a == b
        end
    end

    --- This function tests the old GetItem function to the new one
    --- Suuuuper slow
    function QuestieDBTests:TestItemDB()
        local function GetItemOLD(itemId)
            if (not itemId) or (itemId == 0) then
                return nil
            end
            -- In the test we disable the cache
            -- if _QuestieDB.itemCache[itemId] ~= nil then
            --     return _QuestieDB.itemCache[itemId];
            -- end

            local rawdata = QuestieDB.QueryItem(itemId, unpack(QuestieDB._itemAdapterQueryOrder))

            if not rawdata then
                Questie:Debug(Questie.DEBUG_CRITICAL, "[QuestieDB:GetItem] rawdata is nil for itemID:", itemId)
                return nil
            end

            local item = {
                Id = itemId,
                Sources = {},
                Hidden = QuestieCorrections.questItemBlacklist[itemId]
            }

            for stringKey, intKey in pairs(QuestieDB.itemKeys) do
                item[stringKey] = rawdata[intKey]
            end

            local sources = item.Sources

            if rawdata[QuestieDB.itemKeys.npcDrops] then
                for _, npcId in pairs(rawdata[QuestieDB.itemKeys.npcDrops]) do
                    sources[#sources + 1] = {
                        Id = npcId,
                        Type = "monster",
                    }
                end
            end

            if rawdata[QuestieDB.itemKeys.vendors] then
                for _, npcId in pairs(rawdata[QuestieDB.itemKeys.vendors]) do
                    sources[#sources + 1] = {
                        Id = npcId,
                        Type = "monster",
                    }
                end
            end

            if rawdata[QuestieDB.itemKeys.objectDrops] then
                for _, v in pairs(rawdata[QuestieDB.itemKeys.objectDrops]) do
                    sources[#sources + 1] = {
                        Id = v,
                        Type = "object",
                    }
                end
            end

            return item
        end

        ThreadLib.Thread(function()
            local data = QuestieDB.ItemPointers or QuestieDB.itemData

            local count = 0
            Questie:Debug(Questie.DEBUG_CRITICAL, "[" .. Questie:Colorize("QuestieDBTests", "yellow") .. "] Testing ItemDB")
            for itemId in pairs(data) do
                local item = QuestieDB:GetItem(itemId)
                local item2 = GetItemOLD(itemId)
                assert(equals(item, item2), Questie:Colorize("[QuestieDBTests] Item " .. itemId .. " is not equal", "red"))
                count = count + 1
                if count % 100 == 0 then
                    coroutine.yield()
                end
            end
            Questie:Debug(Questie.DEBUG_CRITICAL, "[" .. Questie:Colorize("QuestieDBTests", "yellow") .. "] Testing ItemDB done")
        end, 0)
    end

    --- This function tests the old GetQuest function to the new one
    --- Suuuuper slow
    function QuestieDBTests:TestQuestDB()
        local function GetQuestOLD(questId)
            if not questId then
                Questie:Debug(Questie.DEBUG_CRITICAL, "[QuestieDB:GetQuest] No questId.")
                return nil
            end
            -- ! No cache
            -- if _QuestieDB.questCache[questId] ~= nil then
            --     return _QuestieDB.questCache[questId];
            -- end

            local rawdata = QuestieDB.QueryQuest(questId, unpack(QuestieDB._questAdapterQueryOrder))

            if (not rawdata) then
                Questie:Debug(Questie.DEBUG_CRITICAL, "[QuestieDB:GetQuest] rawdata is nil for questID:", questId)
                return nil
            end

            ---@class ObjectiveIndex

            ---@class Quest
            ---@field public Id QuestId
            ---@field public name Name
            ---@field public startedBy StartedBy
            ---@field public finishedBy FinishedBy
            ---@field public requiredLevel Level
            ---@field public questLevel Level
            ---@field public requiredRaces number @bitmask
            ---@field public requiredClasses number @bitmask
            ---@field public objectivesText string[]
            ---@field public triggerEnd { [1]: string, [2]: table<AreaId, CoordPair[]>}
            ---@field public objectives RawObjectives
            ---@field public sourceItemId ItemId
            ---@field public preQuestGroup QuestId[]
            ---@field public preQuestSingle QuestId[]
            ---@field public childQuests QuestId[]
            ---@field public inGroupWith QuestId[]
            ---@field public exclusiveTo QuestId[]
            ---@field public zoneOrSort ZoneOrSort
            ---@field public requiredSkill SkillPair
            ---@field public requiredMinRep ReputationPair
            ---@field public requiredMaxRep ReputationPair
            ---@field public requiredSourceItems ItemId[]
            ---@field public nextQuestInChain number
            ---@field public questFlags number @bitmask: see https://github.com/cmangos/issues/wiki/Quest_template#questflags
            ---@field public specialFlags number @bitmask: 1 = Repeatable, 2 = Needs event, 4 = Monthly reset (req. 1). See https://github.com/cmangos/issues/wiki/Quest_template#specialflags
            ---@field public parentQuest QuestId
            ---@field public reputationReward ReputationPair[]
            ---@field public extraObjectives table
            local QO = {
                Id = questId
            }

            -- General filling of the QuestObjective with all database values
            local questKeys = QuestieDB.questKeys
            for stringKey, intKey in pairs(questKeys) do
                QO[stringKey] = rawdata[intKey]
            end

            local questLevel, requiredLevel = QuestieLib.GetTbcLevel(questId)
            QO.level = questLevel
            QO.requiredLevel = requiredLevel

            ---@type StartedBy
            local startedBy = rawdata[questKeys.startedBy]
            QO.Starts = {
                NPC = startedBy[1],
                GameObject = startedBy[2],
                Item = startedBy[3],
            }
            -- ! Is hidden is never used so we removed it in the new version
            -- QO.isHidden = rawdata.hidden or QuestieCorrections.hiddenQuests[questId]
            QO.Description = rawdata[questKeys.objectivesText]
            if QO.specialFlags then
                QO.IsRepeatable = mod(QO.specialFlags, 2) == 1
            end

            QO.IsComplete = function() end

            ---@type FinishedBy
            local finishedBy = rawdata[questKeys.finishedBy]
            if finishedBy[1] ~= nil then
                for _, id in pairs(finishedBy[1]) do
                    if id ~= nil then
                        QO.Finisher = {
                            Type = "monster",
                            Id = id,
                            ---@type Name @We have to hard-type it here because of the function
                            Name = QuestieDB.QueryNPCSingle(id, "name")
                        }
                    end
                end
            end
            if finishedBy[2] ~= nil then
                for _, id in pairs(finishedBy[2]) do
                    if id ~= nil then
                        QO.Finisher = {
                            Type = "object",
                            Id = id,
                            ---@type Name @We have to hard-type it here because of the function
                            Name = QuestieDB.QueryObjectSingle(id, "name")
                        }
                    end
                end
            end

            --- to differentiate from the current quest log info.
            --- Quest objectives generated from DB+Corrections.
            --- Data itself is for example for monster type { Type = "monster", Id = 16518, Text = "Nestlewood Owlkin inoculated" }
            ---@type Objective[]
            QO.ObjectiveData = {}

            ---@type RawObjectives
            local objectives = rawdata[questKeys.objectives]
            if objectives ~= nil then
                if objectives[1] ~= nil then
                    for _, creatureObjective in pairs(objectives[1]) do
                        if creatureObjective ~= nil then
                            ---@type NpcObjective
                            local obj = {
                                Type = "monster",
                                Id = creatureObjective[1],
                                Text = creatureObjective[2]
                            }
                            tinsert(QO.ObjectiveData, obj);
                        end
                    end
                end
                if objectives[2] ~= nil then
                    for _, objectObjective in pairs(objectives[2]) do
                        if objectObjective ~= nil then
                            ---@type ObjectObjective
                            local obj = {
                                Type = "object",
                                Id = objectObjective[1],
                                Text = objectObjective[2]
                            }
                            tinsert(QO.ObjectiveData, obj);
                        end
                    end
                end
                if objectives[3] ~= nil then
                    for _, itemObjective in pairs(objectives[3]) do
                        if itemObjective ~= nil then
                            ---@type ItemObjective
                            local obj = {
                                Type = "item",
                                Id = itemObjective[1],
                                Text = itemObjective[2]
                            }
                            tinsert(QO.ObjectiveData, obj);
                        end
                    end
                end
                if objectives[4] ~= nil then
                    ---@type ReputationObjective
                    local reputationObjective = {
                        Type = "reputation",
                        Id = objectives[4][1],
                        RequiredRepValue = objectives[4][2]
                    }
                    tinsert(QO.ObjectiveData, reputationObjective);
                end
                if objectives[5] ~= nil and type(objectives[5]) == "table" and #objectives[5] > 0 then
                    for _, creditObjective in pairs(objectives[5]) do
                        ---@type KillObjective
                        local killCreditObjective = {
                            Type = "killcredit",
                            IdList = creditObjective[1],
                            RootId = creditObjective[2],
                            Text = creditObjective[3]
                        }
                        tinsert(QO.ObjectiveData, killCreditObjective);
                    end
                end

                -- There are quest(s) which have the killCredit at first so we need to switch them
                if QuestieCorrections.killCreditObjectiveFirst[questId] then
                    local tmp = QO.ObjectiveData[1]
                    QO.ObjectiveData[1] = QO.ObjectiveData[2]
                    QO.ObjectiveData[2] = tmp
                end
            end

            -- Events need to be added at the end of ObjectiveData
            local triggerEnd = rawdata[questKeys.triggerEnd]
            if triggerEnd then
                ---@type TriggerEndObjective
                local obj = {
                    Type = "event",
                    Text = triggerEnd[1],
                    Coordinates = triggerEnd[2]
                }
                tinsert(QO.ObjectiveData, obj);
            end

            local preQuestGroup = rawdata[questKeys.preQuestGroup]
            local preQuestSingle = rawdata[questKeys.preQuestSingle]
            if (preQuestGroup ~= nil and next(preQuestGroup) ~= nil and preQuestSingle ~= nil and next(preQuestSingle) ~= nil) then
                Questie:Debug(Questie.DEBUG_CRITICAL, "ERRRRORRRRRRR not mutually exclusive for questID:", questId)
            end

            --- Quest objectives generated from quest log in QuestieQuest.lua -> QuestieQuest:PopulateQuestLogInfo(quest)
            --- Includes also icons drawn to maps, and other stuff.
            ---@type table<number, table>
            QO.Objectives = {}

            QO.SpecialObjectives = {}

            ---@type ItemId[]
            local requiredSourceItems = rawdata[questKeys.requiredSourceItems]
            if requiredSourceItems ~= nil then --required source items
                for _, itemId in pairs(requiredSourceItems) do
                    if itemId ~= nil then
                        QO.SpecialObjectives[itemId] = {
                            Type = "item",
                            Id = itemId,
                            ---@type string @We have to hard-type it here because of the function
                            Description = QuestieDB.QueryItemSingle(itemId, "name")
                        }
                    end
                end
            end

            local zoneOrSort = rawdata[questKeys.zoneOrSort]
            -- ! Zone and Sort are never used so we removed them in the new version
            -- if zoneOrSort and zoneOrSort ~= 0 then
            --     if zoneOrSort > 0 then
            --         QO.Zone = zoneOrSort
            --     else
            --         QO.Sort = -zoneOrSort
            --     end
            -- end

            QO.IsTrivial = function() end

            local extraObjectives = rawdata[questKeys.extraObjectives]
            if extraObjectives then
                for index, o in pairs(extraObjectives) do
                    QO.SpecialObjectives[index] = {
                        Icon = o[2],
                        Description = o[3],
                    }
                    if o[1] then -- custom spawn
                        QO.SpecialObjectives[index].spawnList = { {
                            Name = o[3],
                            Spawns = o[1],
                            Icon = o[2],
                            GetIconScale = function() end,
                            IconScale = Questie.db.global.objectScale or 1,
                        } }
                    end
                    if o[5] then -- db ref
                        QO.SpecialObjectives[index].Type = o[5][1][1]
                        QO.SpecialObjectives[index].Id = o[5][1][2]
                        local spawnList = {}

                        for _, ref in pairs(o[5]) do
                            for k, v in pairs(_QuestieQuest.objectiveSpawnListCallTable[ref[1]](ref[2], QO.SpecialObjectives[index])) do
                                -- we want to be able to override the icon in the corrections (e.g. ICON_TYPE_OBJECT on objects instead of ICON_TYPE_LOOT)
                                v.Icon = o[2]
                                spawnList[k] = v
                            end
                        end

                        QO.SpecialObjectives[index].spawnList = spawnList
                    end
                end
            end

            return QO
        end

        ThreadLib.Thread(function()
            local data = QuestieDB.QuestPointers or QuestieDB.questData

            local count = 0
            Questie:Debug(Questie.DEBUG_CRITICAL, "[" .. Questie:Colorize("QuestieDBTests", "yellow") .. "] Testing QuestDB")
            for questId in pairs(data) do
                local quest = QuestieDB.GetQuest(questId, true)
                local quest2 = GetQuestOLD(questId)
                assert(equals(quest, quest2), Questie:Colorize("[QuestieDBTests] Quest " .. questId .. " is not equal", "red"))
                count = count + 1
                if count % 100 == 0 then
                    coroutine.yield()
                end
            end
            Questie:Debug(Questie.DEBUG_CRITICAL, "[" .. Questie:Colorize("QuestieDBTests", "yellow") .. "] Testing QuestDB done")
        end, 0)
    end

    --- This function tests the old GetNPC function to the new one
    --- Suuuuper slow
    function QuestieDBTests:TestNpcDB()
        local playerFaction = UnitFactionGroup("player")
        local function GetNPCOLD(npcId)
            if not npcId then
                return nil
            end
            -- if(_QuestieDB.npcCache[npcId]) then
            --     return _QuestieDB.npcCache[npcId]
            -- end

            local rawdata = QuestieDB.QueryNPC(npcId, unpack(QuestieDB._npcAdapterQueryOrder))
            if (not rawdata) then
                Questie:Debug(Questie.DEBUG_CRITICAL, "[QuestieDB:GetNPC] rawdata is nil for npcID:", npcId)
                return nil
            end

            local npcKeys = QuestieDB.npcKeys
            local npc = {
                id = npcId,
                type = "monster",
            }
            for stringKey, intKey in pairs(npcKeys) do
                npc[stringKey] = rawdata[intKey]
            end

            local friendlyToFaction = rawdata[npcKeys.friendlyToFaction]
            if friendlyToFaction then
                if friendlyToFaction == "AH" then
                    npc.friendly = true
                else
                    if playerFaction == "Horde" and friendlyToFaction == "H" then
                        npc.friendly = true
                    elseif playerFaction == "Alliance" and friendlyToFaction == "A" then
                        npc.friendly = true
                    end
                end
            else
                npc.friendly = true
            end

            return npc
        end

        ThreadLib.Thread(function()
            local data = QuestieDB.NPCPointers or QuestieDB.npcData

            local count = 0
            Questie:Debug(Questie.DEBUG_CRITICAL, "[" .. Questie:Colorize("QuestieDBTests", "yellow") .. "] Testing NpcDB")
            for npcId in pairs(data) do
                local npc = QuestieDB:GetNPC(npcId, true)
                local npc2 = GetNPCOLD(npcId)
                assert(equals(npc, npc2), Questie:Colorize("[QuestieDBTests] Npc " .. npcId .. " is not equal", "red"))
                count = count + 1
                if count % 100 == 0 then
                    coroutine.yield()
                end
            end
            Questie:Debug(Questie.DEBUG_CRITICAL, "[" .. Questie:Colorize("QuestieDBTests", "yellow") .. "] Testing NpcDB done")
        end, 0)
    end

    --- This function tests the old GetNPC function to the new one
    --- Suuuuper slow
    function QuestieDBTests:TestObjectDB()
        local function GetObjectOLD(objectId)
            if not objectId then
                return nil
            end
            -- if _QuestieDB.objectCache[objectId] and not skipCache then
            --     return _QuestieDB.objectCache[objectId];
            -- end

            --- Credit for the QueryAll structure goes to @Laume/Laumesis

            ---@class Object : RawObject
            ---@field type "object" -- This is a object? duh, why is this here.
            local object = QuestieDB.QueryObjectAll(objectId) --[[@as Object]] -- We cast it here because we handle it correctly.

            if not object then
                Questie:Debug(Questie.DEBUG_CRITICAL, "[QuestieDB:GetObject] object is nil for objectID:", objectId)
                Questie:Debug(Questie.DEBUG_CRITICAL, debugstack(2, 0, 5))
                return nil
            end

            object.id = objectId
            object.type = "object"

            --_QuestieDB.objectCache[objectId] = obj;
            return object;
        end

        ThreadLib.Thread(function()
            local data = QuestieDB.ObjectPointers or QuestieDB.objectData

            local count = 0
            Questie:Debug(Questie.DEBUG_CRITICAL, "[" .. Questie:Colorize("QuestieDBTests", "yellow") .. "] Testing ObjectDB")
            for objectId in pairs(data) do
                local object = QuestieDB:GetObject(objectId, true)
                local object2 = GetObjectOLD(objectId)
                assert(equals(object, object2), Questie:Colorize("[QuestieDBTests] Object " .. objectId .. " is not equal", "red"))
                count = count + 1
                if count % 100 == 0 then
                    coroutine.yield()
                end
            end
            Questie:Debug(Questie.DEBUG_CRITICAL, "[" .. Questie:Colorize("QuestieDBTests", "yellow") .. "] Testing ObjectDB done")
        end, 0)
    end
end
