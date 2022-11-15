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
    wipe(QuestieQuest.Show.NPC)
    wipe(QuestieQuest.Show.GameObject)
    wipe(QuestieQuest.Show.Item)
    QuestieQuest.CalculateAvailableQuests()
    QuestieQuest.CalculateCompleteQuests()
    QuestEventBus:RegisterRepeating(QuestEventBus.events.QUEST_ACCEPTED, QuestieQuest.CalculateAvailableQuests)
    QuestEventBus:RegisterRepeating(QuestEventBus.events.QUEST_COMPLETED, QuestieQuest.CalculateAvailableQuests)
    QuestEventBus:RegisterRepeating(QuestEventBus.events.QUEST_ABANDONED, QuestieQuest.CalculateAvailableQuests)

    QuestEventBus:RegisterRepeating(QuestEventBus.events.QUEST_COMPLETED, QuestieQuest.CalculateCompleteQuests)
end

SystemEventBus:RegisterOnce(SystemEventBus.events.INITIALIZE_DONE, InitializeModule)

---@class RelationMapData
---@field type "availablePickup"|"availableDrop"|"finisherComplete"

local relationTypes = {
    availablePickup = { type = "availablePickup" },
    availableDrop = { type = "availableDrop" },
    finisherComplete = { type = "finisherComplete" },
}

---@alias Show {NPC: table<NpcId, {available: table<QuestId, RelationMapData>, finisher: table<QuestId, RelationMapData>}>, GameObject: table, Item: table}
---@type Show
QuestieQuest.Show = {
    NPC = {
        --ID
        [0] = {
            available = {
                --[Questid] = { type }
            },
            finisher = {
                --[Questid] = { type }
            },
            slay = {
                --[Questid] = { type }
            },
            loot = {
                --[Questid] = { type }
            },
            extra = {
                --[Questid] = { some data }
            }
        }
    },
    GameObject = {
        --ID
        [0] = {
            available = {
                --[Questid] = { type }
            },
            finisher = {
                --[Questid] = { type }
            },
            loot = {
                --[Questid] = { type }
            },
            extra = {
                --[Questid] = { some data }
            }
        }
    },
    Item = {
        --ID
        [0] = {
            available = {
                --[Questid] = { type }
            },
            loot = {
                --[Questid] = { type }
            },
            extra = {
                --[Questid] = { some data }
            }
        }
    }
}

do
    -- A bit of a workaround to avoid putting the function in the global space
    local MergeShowData
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

        local starts = QuestieDB.QueryQuestSingle(questId, "startedBy") or {}
        if (starts[1] ~= nil) then
            local npcs = starts[1]
            for i = 1, #npcs do
                local npcId = npcs[i]
                -- print("Adding quest giver NPC :", npcId, "for quest", questId)
                show.NPC[npcId] = show.NPC[npcId] or {}
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

    local function CalculateAvailableQuests()
        local questsPerYield = 64

        -- Wipe the previous data
        for _, categoryData in pairs(QuestieQuest.Show) do
            for _, questData in pairs(categoryData) do
                if questData.available then
                    wipe(questData.available)
                end
            end
        end

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
        -- local DB = QuestieLoader:ImportModule("DB")

        local isLevelRequirementsFulfilled = QuestieDB.IsLevelRequirementsFulfilled
        local isDoable = QuestieDB.IsDoable

        -- This contains the new show data
        local newShowData = { NPC = {}, GameObject = {}, Item = {} }

        local questCount = 0
        for questId in pairs(data) do
            -- local quest = DB.Quest[questId]
            --? Quick exit through autoBlacklist if IsDoable has blacklisted it.
            if (not autoBlacklist[questId]) then
                --Check if we've already completed the quest and that it is not "manually" hidden and that the quest is not currently in the questlog.
                if (
                    (not Questie.db.char.complete[questId]) and -- Don't show completed quests
                        -- Don't show quests if they're already in the quest log
                        ((not QuestiePlayer.currentQuestlog[questId]) or QuestieDB.IsComplete(questId) == -1) and
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


        --! Verify that the merge is working correctly
        -- Clear the previous data
        for _, categoryData in pairs(QuestieQuest.Show) do
            for _, questData in pairs(categoryData) do
                if questData.available then
                    wipe(questData.available)
                end
            end
        end
        -- Merge in the new data
        QuestieQuest.MergeShowData(QuestieQuest.Show, newShowData)
        -- Redraw
        MapEventBus.FireEvent.REMOVE_ALL_AVAILABLE()
        QuestEventBus.FireEvent.CALCULATED_AVAILABLE_QUESTS(QuestieQuest.Show)
    end

    -- Starts a thread to calculate available quests to avoid lag spikes
    function QuestieQuest.CalculateAvailableQuests()
        Questie:Debug(Questie.DEBUG_INFO, "[QuestieQuest.CalculateAvailableQuests] PlayerLevel =", QuestiePlayer.GetPlayerLevel())

        --? Cancel the previously running timer to not have multiple running at the same time
        if timer then
            timer:Cancel()
        end

        --? Run this first because there are parts that depend on the Show data still being there.
        -- MapEventBus:Fire(MapEventBus.events.REMOVE_ALL_AVAILABLE)

        timer = ThreadLib.Thread(CalculateAvailableQuests, 0, "Error in CalculateAvailableQuests", function() print("test") end)
    end
end

do
    --- Used to keep track of the active timer for CalculateAvailableQuests
    --- Is used by the QuestieQuest.CalculateAndDrawAvailableQuestsIterative func
    ---@type Ticker|nil
    local timer

    ---@param show Show
    ---@param questId QuestId
    local function AddQuestFinishers(show, questId)
        -- print("Add questgives", questId)
        local finishes = QuestieDB.QueryQuestSingle(questId, "finishedBy") or {}
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

        --! Verify that the merge is working correctly
        -- Clear the previous data
        for _, categoryData in pairs(QuestieQuest.Show) do
            for _, questData in pairs(categoryData) do
                if questData.finisher then
                    wipe(questData.finisher)
                end
            end
        end
        -- Merge in the new data
        QuestieQuest.MergeShowData(QuestieQuest.Show, newShowData)
        -- Redraw
        MapEventBus.FireEvent.REMOVE_ALL_COMPLETED()
        QuestEventBus.FireEvent.CALCULATED_COMPLETED_QUESTS(QuestieQuest.Show)
    end

    -- Starts a thread to calculate available quests to avoid lag spikes
    function QuestieQuest.CalculateCompleteQuests()
        Questie:Debug(Questie.DEBUG_INFO, "[QuestieQuest.CalculateCompleteQuests] PlayerLevel =", QuestiePlayer.GetPlayerLevel())

        --? Cancel the previously running timer to not have multiple running at the same time
        if timer then
            timer:Cancel()
        end

        --? Run this first because there are parts that depend on the Show data still being there.
        MapEventBus:Fire(MapEventBus.events.REMOVE_ALL_COMPLETED)

        timer = ThreadLib.Thread(CalculateCompleteQuests, 0, "Error in CalculateCompleteQuests", function() print("test") end)
    end
end
