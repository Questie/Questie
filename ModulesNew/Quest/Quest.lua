---@class QQuest
local QuestieQuest = QuestieLoader:CreateModule("QQuest")

-- System imports
---@type ThreadLib
local ThreadLib = QuestieLoader:ImportModule("ThreadLib")
---@type SystemEventBus
local SystemEventBus = QuestieLoader:ImportModule("SystemEventBus")
---@type QuestEventBus
local QuestEventBus = QuestieLoader:ImportModule("QuestEventBus")
---@type MapEventBus
local MapEventBus = QuestieLoader:ImportModule("MapEventBus")

-- Module Imports
--! REMOVE THIS
local QQ = QuestieLoader:CreateModule("QuestieQuest")

---@type QuestLogCache
local QuestLogCache = QuestieLoader:ImportModule("QuestLogCache")

---@type QuestieMap
local QuestieMap = QuestieLoader:ImportModule("QuestieMap")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
---@type QuestiePlayer
local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestieCorrections
local QuestieCorrections = QuestieLoader:ImportModule("QuestieCorrections")
---@type QuestieQuestBlacklist
local QuestieQuestBlacklist = QuestieLoader:ImportModule("QuestieQuestBlacklist")
---@type IsleOfQuelDanas
local IsleOfQuelDanas = QuestieLoader:ImportModule("IsleOfQuelDanas")

--- Up values
local yield = coroutine.yield
local wipe = wipe

local function InitializeModule()
    -- Wipe the table to make sure we don't have any old data
    wipe(QuestieQuest.Show.NPC)
    wipe(QuestieQuest.Show.GameObject)
    wipe(QuestieQuest.Show.Item)

    -- Register the events
    QuestEventBus:RegisterRepeating(QuestEventBus.events.QUEST_ACCEPTED, QuestieQuest.CalculateAvailableQuests)
    QuestEventBus:RegisterRepeating(QuestEventBus.events.QUEST_COMPLETED, QuestieQuest.CalculateAvailableQuests)
    QuestEventBus:RegisterRepeating(QuestEventBus.events.QUEST_ABANDONED, QuestieQuest.CalculateAvailableQuests)

    QuestEventBus:RegisterRepeating(QuestEventBus.events.QUEST_ACCEPTED, QuestieQuest.CalculateCompleteQuests)
    QuestEventBus:RegisterRepeating(QuestEventBus.events.QUEST_COMPLETED, QuestieQuest.CalculateCompleteQuests)

    QuestEventBus:RegisterRepeating(QuestEventBus.events.QUEST_UPDATED, function(questId, objIds)
        local isComplete = QuestieDB.IsComplete(questId)
        if isComplete == 1 then -- Quest is complete
            QuestieQuest.CalculateAvailableQuests()
        elseif isComplete == -1 then -- Quest is incomplete
            QuestieQuest.CalculateCompleteQuests()
        end
    end)

    -- Run the first time
    QuestieQuest.CalculateAvailableQuests()
    QuestieQuest.CalculateCompleteQuests()
end

SystemEventBus:RegisterOnce(SystemEventBus.events.INITIALIZE_DONE, InitializeModule)

---@class RelationMapData
---@field type "availablePickup"|"availableDrop"|"finisherComplete"

---@class ObjectiveMapData
---@field objectiveIndex ObjectiveIndex

local relationTypes = {
    availablePickup = { type = "availablePickup" },
    availableDrop = { type = "availableDrop" },
    finisherComplete = { type = "finisherComplete" },
}

-- This table containts all the data that wants to be showed in some way, each subtable is a different of provider
-- The relevant parts reads the table and use the data that is relevant to them, Relation parts read available and finisher for example
-- -@type Show
---@class Show
QuestieQuest.Show = {
    --! NPC CATEGORY
    ---@type table<NpcId, ShowNPC>
    NPC = {
        --ID (These are just here for reference)
        ---@class ShowNPC
        [0] = {
            ---@type table<QuestId, RelationMapData>
            available = {
                --[Questid] = { type }
            },
            ---@type table<QuestId, RelationMapData>
            finisher = {
                --[Questid] = { type }
            },
            ---@type table<QuestId, ObjectiveMapData>
            slay = {
                --[Questid] = { objectiveIndex }
            },
            ---@type table<QuestId, ObjectiveMapData>
            loot = {
                --[Questid] = { objectiveIndex }
            },
            extra = {
                --[Questid] = { some data }
            }
        }
    },
    --! GameObject CATEGORY
    ---@type table<ObjectId, ShowGameObject>
    GameObject = {
        --ID (These are just here for reference)
        ---@class ShowGameObject
        [0] = {
            ---@type table<QuestId, RelationMapData>
            available = {
                --[Questid] = { type }
            },
            ---@type table<QuestId, RelationMapData>
            finisher = {
                --[Questid] = { type }
            },
            ---@type table<QuestId, ObjectiveMapData>
            use = {
                --[Questid] = { objectiveIndex }
            },
            ---@type table<QuestId, ObjectiveMapData>
            loot = {
                --[Questid] = { objectiveIndex }
            },
            extra = {
                --[Questid] = { some data }
            }
        }
    },
    --! Item CATEGORY
    ---@type table<ItemId, ShowItem>
    Item = {
        --ID (These are just here for reference)
        ---@class ShowItem
        [0] = {
            ---@type table<QuestId, RelationMapData>
            available = {
                --[Questid] = { type }
            },
            ---@type table<QuestId, ObjectiveMapData>
            loot = {
                --[Questid] = { type }
            },
            extra = {
                --[Questid] = { some data }
            }
        }
    },
    --! Reputation CATEGORY
    -- ?????
    Reputation = {

    },
    --! Event CATEGORY
    -- ?????
    Event = {

    },
    --! SpecialObjectives CATEGORY
    -- ?????
    SpecialObjectives = {

    }
}


do
    -- A bit of a workaround to avoid putting the function in the global space
    local MergeShowData

    -- Merges two ShowData tables together
    function QuestieQuest.MergeShowData(t1, t2)
        for k, v in pairs(t2) do
            if type(v) == "table" then
                if type(t1[k] or false) == "table" then
                    MergeShowData(t1[k] or {}, t2[k] or {})
                else
                    t1[k] = v
                end
            else
                t1[k] = v
            end
        end
        return t1
    end

    MergeShowData = QuestieQuest.MergeShowData
end


--------------------------------------------
-------------- Available Quest -------------
--------------------------------------------
--? Creates a localized space where the local variables and functions are stored
do
    --- Used to keep track of the active timer for CalculateAvailableQuests
    --- Is used by the QuestieQuest.CalculateAndDrawAvailableQuestsIterative func
    ---@type Ticker|nil
    local timer

    ---@param show Show
    ---@param questId QuestId
    local function AddQuestGivers(show, questId)
        -- print("Add questgives", questId)
        -- local show = QuestieQuest.Show

        local starts = QuestieDB.QueryQuestSingle(questId, "startedBy")
        if starts then
            if (starts[1] ~= nil) then
                local npcs = starts[1]
                for i = 1, #npcs do
                    local npcId = npcs[i]
                    -- print("Adding quest giver NPC :", npcId, "for quest", questId)
                    if show.NPC[npcId] == nil then
                        show.NPC[npcId] = {}
                    end
                    if show.NPC[npcId].available == nil then
                        show.NPC[npcId].available = {}
                    end
                    show.NPC[npcId].available[questId] = relationTypes.availablePickup
                end
            end
            if (starts[2] ~= nil) then
                local gameobjects = starts[2]
                for i = 1, #gameobjects do
                    local gameObjectId = gameobjects[i]
                    if show.GameObject[gameObjectId] == nil then
                        show.GameObject[gameObjectId] = {}
                    end
                    if show.GameObject[gameObjectId].available == nil then
                        show.GameObject[gameObjectId].available = {}
                    end
                    show.GameObject[gameObjectId].available[questId] = relationTypes.availablePickup
                end
            end
            if (starts[3] ~= nil) then
                local items = starts[3]
                for i = 1, #items do
                    local itemId = items[i]
                    -- print("Adding quest giver ITEM:", itemId, "for quest", questId)
                    if show.Item[itemId] == nil then
                        show.Item[itemId] = {}
                    end
                    if show.Item[itemId].available == nil then
                        show.Item[itemId].available = {}
                    end
                    show.Item[itemId].available[questId] = relationTypes.availableDrop
                end
            end
        end
    end

    local function CalculateAvailableQuests()
        local questsPerYield = 64

        -- Localize the variable for speeeeed
        local debugEnabled = Questie.db.global.debugEnabled

        local data = QuestieDB.QuestPointers or QuestieDB.questData

        local playerLevel = QuestiePlayer.GetPlayerLevel()
        local minLevel = playerLevel - GetQuestGreenRange("player")
        local maxLevel = playerLevel

        if Questie.db.char.absoluteLevelOffset then
            minLevel = Questie.db.char.minLevelFilter
            maxLevel = Questie.db.char.maxLevelFilter
        elseif Questie.db.char.manualMinLevelOffset then
            minLevel = playerLevel - Questie.db.char.minLevelFilter
        end

        local showRepeatableQuests = Questie.db.char.showRepeatableQuests
        local showDungeonQuests = Questie.db.char.showDungeonQuests
        local showRaidQuests = Questie.db.char.showRaidQuests
        local showPvPQuests = Questie.db.char.showPvPQuests
        local showAQWarEffortQuests = Questie.db.char.showAQWarEffortQuests

        --- Fast Localizations
        local autoBlacklist = QQ.autoBlacklist
        local hiddenQuests  = QuestieCorrections.hiddenQuests
        local hidden        = Questie.db.char.hidden
        local NewThread     = ThreadLib.ThreadSimple

        local isLevelRequirementsFulfilled = QuestieDB.IsLevelRequirementsFulfilled
        local isDoable = QuestieDB.IsDoable

        -- This contains the new show data
        local newShowData = { NPC = {}, GameObject = {}, Item = {} }

        local questCount = 0
        for questId in pairs(data) do
            --? Quick exit through autoBlacklist if IsDoable has blacklisted it.
            if (not autoBlacklist[questId]) then
                --Check if we've already completed the quest and that it is not "manually" hidden and that the quest is not currently in the questlog.
                if (
                    (not Questie.db.char.complete[questId]) and -- Don't show completed quests
                        -- Don't show quests if they're already in the quest log
                        ((not QuestLogCache.questLog_DO_NOT_MODIFY[questId]) or QuestieDB.IsComplete(questId) == -1) and
                        -- Don't show blacklisted or player hidden quests
                        (not hiddenQuests[questId] and not hidden[questId]) and
                        -- Show repeatable quests if the quest is repeatable and the option is enabled
                        (showRepeatableQuests or (not QuestieDB.IsRepeatable(questId))) and
                        -- Show dungeon quests only with the option enabled
                        (showDungeonQuests or (not QuestieDB.IsDungeonQuest(questId))) and
                        -- Show Raid quests only with the option enabled
                        (showRaidQuests or (not QuestieDB.IsRaidQuest(questId))) and
                        -- Show PvP quests only with the option enabled
                        (showPvPQuests or (not QuestieDB.IsPvPQuest(questId))) and
                        -- Don't show AQ War Effort quests with the option enabled
                        (showAQWarEffortQuests or (not QuestieQuestBlacklist.AQWarEffortQuests[questId])) and
                        ((not Questie.IsWotlk) or (not IsleOfQuelDanas.quests[Questie.db.global.isleOfQuelDanasPhase][questId]))
                    ) then

                    if isLevelRequirementsFulfilled(questId, minLevel, maxLevel, playerLevel) and isDoable(questId, debugEnabled) then
                        AddQuestGivers(newShowData, questId)
                    end
                end
            end

            -- Reset the questCount
            questCount = questCount + 1
            if questCount > questsPerYield then
                questCount = 0
                yield()
            end
        end

        yield()

        --! Verify that the merge is working correctly
        -- Clear the previous data
        for _, categoryData in pairs(QuestieQuest.Show) do
            for id, questData in pairs(categoryData) do
                -- if questData.available then
                --     wipe(questData.available)
                -- end
                questData.available = nil
                -- Remove empty object
                if next(questData) == nil then
                    categoryData[id] = nil
                end
            end
        end
        -- Merge in the new data
        QuestieQuest.MergeShowData(QuestieQuest.Show, newShowData)
        yield()
        QuestEventBus.FireEvent.CALCULATE_AVAILABLE_QUESTS_DONE(QuestieQuest.Show)
    end

    -- Starts a thread to calculate available quests to avoid lag spikes
    function QuestieQuest.CalculateAvailableQuests()
        Questie:Debug(Questie.DEBUG_INFO, "[QuestieQuest.CalculateAvailableQuests] PlayerLevel =", QuestiePlayer.GetPlayerLevel())

        --? Cancel the previously running timer to not have multiple running at the same time
        if timer then
            timer:Cancel()
        end

        timer = ThreadLib.Thread(CalculateAvailableQuests, 0, "Error in CalculateAvailableQuests")
    end
end


--------------------------------------------
-------------- Complete Quest --------------
--------------------------------------------
do
    --- Used to keep track of the active timer for CalculateAvailableQuests
    --- Is used by the QuestieQuest.CalculateAndDrawAvailableQuestsIterative func
    ---@type Ticker|nil
    local timer

    ---@param show Show
    ---@param questId QuestId
    local function AddQuestFinishers(show, questId)
        -- print("Add questgives", questId)
        local finishes = QuestieDB.QueryQuestSingle(questId, "finishedBy")
        if finishes then
            if (finishes[1] ~= nil) then
                local npcs = finishes[1]
                for i = 1, #npcs do
                    local npcId = npcs[i]
                    -- printE("Adding quest finisher NPC :", npcId, "for quest", questId)
                    if show.NPC[npcId] == nil then
                        show.NPC[npcId] = {}
                    end
                    if show.NPC[npcId].finisher == nil then
                        show.NPC[npcId].finisher = {}
                    end
                    show.NPC[npcId].finisher[questId] = relationTypes.finisherComplete
                end
            end
            if (finishes[2] ~= nil) then
                local gameobjects = finishes[2]
                for i = 1, #gameobjects do
                    local gameObjectId = gameobjects[i]
                    -- printE("Adding quest finisher GO  :", gameObjectId, "for quest", questId)
                    if show.GameObject[gameObjectId] == nil then
                        show.GameObject[gameObjectId] = {}
                    end
                    if show.GameObject[gameObjectId].finisher == nil then
                        show.GameObject[gameObjectId].finisher = {}
                    end
                    show.GameObject[gameObjectId].finisher[questId] = relationTypes.finisherComplete
                end
            end
        end
    end

    local function CalculateCompleteQuests()
        local questsPerYield = 6

        -- This contains the new show data
        local newShowData = { NPC = {}, GameObject = {} }

        local questCount = 0
        for questId, data in pairs(QuestLogCache.questLog_DO_NOT_MODIFY) do -- DO NOT MODIFY THE RETURNED TABLE
            if QuestieDB.IsComplete(questId) == 1 then
                AddQuestFinishers(newShowData, questId)
            end

            -- Reset the questCount
            questCount = questCount + 1
            if questCount > questsPerYield then
                questCount = 0
                yield()
            end
        end

        yield()

        --! Verify that the merge is working correctly
        -- Clear the previous data
        for _, categoryData in pairs(QuestieQuest.Show) do
            for id, questData in pairs(categoryData) do
                -- if questData.finisher then
                --     wipe(questData.finisher)
                -- end
                questData.finisher = nil
                -- Remove empty object
                if next(questData) == nil then
                    categoryData[id] = nil
                end
            end
        end
        -- Merge in the new data
        QuestieQuest.MergeShowData(QuestieQuest.Show, newShowData)
        yield()
        QuestEventBus.FireEvent.CALCULATE_COMPLETED_QUESTS_DONE(QuestieQuest.Show)
    end

    -- Starts a thread to calculate available quests to avoid lag spikes
    function QuestieQuest.CalculateCompleteQuests()
        Questie:Debug(Questie.DEBUG_INFO, "[QuestieQuest.CalculateCompleteQuests] PlayerLevel =", QuestiePlayer.GetPlayerLevel())

        --? Cancel the previously running timer to not have multiple running at the same time
        if timer then
            timer:Cancel()
        end

        timer = ThreadLib.Thread(CalculateCompleteQuests, 0, "Error in CalculateCompleteQuests")
    end
end


do
    -- Helper values to increase readability
    local MONSTER, GAMEOBJECT, ITEM = 1, 2, 3
    local ID = 1 -- The index for ID in objectives is 1

    ---comment
    ---@param showData table<NpcId|ObjectId|ItemId, table<string, table<QuestId, table>>>
    ---@param questId QuestId
    ---@param id NpcId|ObjectId|ItemId
    ---@param subTable string @ The subtable to add the objectiveData to
    ---@param objectiveData table
    local function AddObjectiveHelper(showData, questId, id, subTable, objectiveData)
        if showData[id] == nil then
            showData[id] = {}
        end
        if showData[id][subTable] == nil then
            showData[id][subTable] = {}
        end
        if showData[id][subTable][questId] == nil then
            showData[id][subTable][questId] = {}
        end
        showData[id][subTable][questId][#showData[id][subTable][questId]+1] = objectiveData
    end

    function QuestieQuest.CalculateQuestObjectives()
        local data = {}
        -- local show = QuestieQuest.Show
        local newShowData = { NPC = {}, GameObject = {}, Item = {} }

        for questId, questData in pairs(QuestLogCache.questLog_DO_NOT_MODIFY) do
            ---@type RawObjectives
            local objectives = QuestieDB.QueryQuestSingle(questId, "objectives")
            -- ---@type Objective[]
            -- local ObjectiveOrder
            -- local ObjectiveData
            if (objectives ~= nil) then -- or rawdata.triggerEnd or rawdata.requiredSourceItems
                -- We create the base objects and fill them with tables if they are not nil
                -- ObjectiveOrder = {}
                -- ObjectiveData = {
                --     ---@type NpcObjective[]
                --     monster = objectives[1] and {} or nil,
                --     ---@type ObjectObjective[]
                --     object = objectives[2] and {} or nil,
                --     ---@type ItemObjective[]
                --     item = objectives[3] and {} or nil,
                --     ---@type ReputationObjective
                --     -- reputation = objectives[4] and { Type = "reputation", Id = nil, RequiredRepValue = nil } or nil,
                --     ---@type KillObjective[]
                --     -- killcredit = objectives[5] and {} or nil,
                --     ---@type TriggerEndObjective
                --     -- event = rawdata.triggerEnd and { Type = "event", Text = nil, Coordinates = nil } or nil,
                --     ---@type SourceItemObjective[]
                --     -- sourceitem = rawdata.requiredSourceItems and {} or nil,
                --     ---@type ExtraObjective[]
                --     -- specialobjective = rawdata.extraObjectives and {} or nil,
                -- }

                local questObjectiveIndex = 1
                -- Monster
                if objectives[MONSTER] then
                    for creatureObjectiveIndex = 1, #objectives[MONSTER] do
                        local creatureObjective = objectives[MONSTER][creatureObjectiveIndex]
                        -- Add info to the NPC table
                        AddObjectiveHelper(newShowData.NPC, questId, creatureObjective[ID], "slay", { objectiveIndex = questObjectiveIndex })
                        -- Increment the index
                        questObjectiveIndex = questObjectiveIndex + 1
                    end
                end
                -- Object
                if objectives[GAMEOBJECT] then
                    for objectObjectiveIndex = 1, #objectives[GAMEOBJECT] do
                        local objectObjective = objectives[GAMEOBJECT][objectObjectiveIndex]
                        -- Add info to the GameObject table
                        AddObjectiveHelper(newShowData.GameObject, questId, objectObjective[ID], "use", { objectiveIndex = questObjectiveIndex })
                        -- Increment the index
                        questObjectiveIndex = questObjectiveIndex + 1
                    end
                end
                -- Item
                if objectives[ITEM] then
                    for itemObjectiveIndex = 1, #objectives[ITEM] do
                        local itemObjective = objectives[ITEM][itemObjectiveIndex]
                        local itemId = itemObjective[ID]

                        -- Add info to the Item table
                        AddObjectiveHelper(newShowData.Item, questId, itemId, "loot", { objectiveIndex = questObjectiveIndex })

                        -- Add info to the NPC table
                        local npcDrops = QuestieDB.QueryItemSingle(itemId, "npcDrops")
                        if npcDrops then
                            for i = 1, #npcDrops do
                                AddObjectiveHelper(newShowData.NPC, questId, npcDrops[i], "loot", { objectiveIndex = questObjectiveIndex })
                            end
                        end

                        -- Add info to the GameObject table
                        local objectDrops = QuestieDB.QueryItemSingle(itemId, "objectDrops")
                        if objectDrops then
                            for i = 1, #objectDrops do
                                AddObjectiveHelper(newShowData.GameObject, questId, objectDrops[i], "loot", { objectiveIndex = questObjectiveIndex })
                            end
                        end
                        -- Increment the index
                        questObjectiveIndex = questObjectiveIndex + 1
                    end
                end

                -- if ObjectiveData.reputation then
                --     local reputationObjective = objectives[4]
                --     ObjectiveData.reputation.Id = reputationObjective[1]
                --     ObjectiveData.reputation.RequiredRepValue = reputationObjective[2]
                --     ObjectiveOrder[#ObjectiveOrder + 1] = ObjectiveData.reputation
                -- end
                -- if ObjectiveData.killcredit then
                --     for killcreditObjectiveIndex = 1, #objectives[5] do
                --         local killcreditObjective = objectives[5][killcreditObjectiveIndex]
                --         ---@type KillObjective
                --         local killcredit = {
                --             Type = "killcredit",
                --             IdList = killcreditObjective[1],
                --             RootId = killcreditObjective[2],
                --             Text = killcreditObjective[3]
                --         }
                --         ObjectiveData.killcredit[killcreditObjectiveIndex] = killcredit
                --         --? There are quest(s) which have the killCredit at first so we need to switch them
                --         -- Place the kill credit objective first
                --         if QuestieCorrections.killCreditObjectiveFirst[questId] then
                --             tinsert(ObjectiveOrder, 1, killcredit);
                --         else
                --             ObjectiveOrder[#ObjectiveOrder + 1] = killcredit
                --         end
                --     end
                -- end

                -- Events need to be added at the end of ObjectiveOrder
                -- if ObjectiveData.event then
                --     ObjectiveData.event.Text = rawdata.triggerEnd[1]
                --     ObjectiveData.event.Coordinates = rawdata.triggerEnd[2]
                --     ObjectiveOrder[#ObjectiveOrder + 1] = ObjectiveData.event
                -- end

                -- if ObjectiveData.sourceitem then
                --     for sourceItemObjectiveIndex = 1, #rawdata.requiredSourceItems do
                --         local sourceItemObjective = rawdata.requiredSourceItems[sourceItemObjectiveIndex]
                --         ---@type ItemObjective
                --         local sourceItem = {
                --             Type = "item",
                --             Id = sourceItemObjective,
                --         }
                --         ObjectiveData.sourceitem[sourceItemObjectiveIndex] = sourceItem
                --     end
                -- end

                -- if rawdata.extraObjectives then
                --     ObjectiveData.specialobjective = rawdata.extraObjectives
                --     --? This logic happens deeper in the code, keeping it here for now
                --     -- for index, eObjective in pairs(rawdata.extraObjectives) do
                --     --     ObjectiveData.specialobjective[index] = {
                --     --         Icon = eObjective[2],
                --     --         Description = eObjective[3],
                --     --     }
                --     --     if eObjective[1] then -- custom spawn
                --     --         ObjectiveData.specialobjective[index].spawnList = {{
                --     --             Name = eObjective[3],
                --     --             Spawns = eObjective[1],
                --     --             Icon = eObjective[2],
                --     --         }}
                --     --     elseif eObjective[5] then -- db ref
                --     --         ObjectiveData.specialobjective[index].Type = eObjective[5][1][1]
                --     --         ObjectiveData.specialobjective[index].Id = eObjective[5][1][2]
                --     --         local spawnList = {}

                --     --         for _, ref in pairs(eObjective[5]) do
                --     --             for k, v in pairs(_QuestieQuest.objectiveSpawnListCallTable[ref[1]](ref[2], ObjectiveData.specialobjective[index])) do
                --     --                 -- we want to be able to override the icon in the corrections (e.g. ICON_TYPE_OBJECT on objects instead of ICON_TYPE_LOOT)
                --     --                 v.Icon = eObjective[2]
                --     --                 spawnList[k] = v
                --     --             end
                --     --         end

                --     --         ObjectiveData.specialobjective[index].spawnList = spawnList
                --     --     end
                --     -- end
                -- end
            end
        end
        --! Verify that the merge is working correctly
        -- Clear the previous data
        for _, categoryData in pairs(QuestieQuest.Show) do
            for id, questData in pairs(categoryData) do
                -- if questData.finisher then
                --     wipe(questData.finisher)
                -- end
                questData.slay = nil
                questData.use = nil
                questData.loot = nil
                -- Remove empty object
                if next(questData) == nil then
                    categoryData[id] = nil
                end
            end
        end
        -- yield()
        -- Merge in the new data
        QuestieQuest.MergeShowData(QuestieQuest.Show, newShowData)
    end
end
