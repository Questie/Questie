dofile("setupTests.lua")

-- Issue references:
-- https://github.com/Questie/Questie/issues/6734
-- https://github.com/Questie/Questie/issues/6829


describe("Issue 6734 - The quest does not exist in QuestLogCache", function()

    ---@type QuestEventHandler
    local QuestEventHandler
    ---@type QuestLogCache
    local QuestLogCache
    ---@type QuestieNameplate
    local QuestieNameplate
    ---@type QuestieQuest
    local QuestieQuest
    ---@type QuestieTracker
    local QuestieTracker
    ---@type QuestieLib
    local QuestieLib
    ---@type QuestieCombatQueue
    local QuestieCombatQueue
    ---@type Sounds
    local Sounds
    ---@type QuestieJourney
    local QuestieJourney
    ---@type QuestieAnnounce
    local QuestieAnnounce
    ---@type QuestieDB
    local QuestieDB

    _G.HaveQuestData = function()
        return true
    end
    _G.GetQuestTimers = function()
        return nil
    end
    _G.C_Timer = {NewTicker = function() return {
        Cancel = function() end
    } end}
    _G.GetNumQuestLogRewards = function()
        return 0
    end
    _G.GetQuestLogRewardInfo = function()
        return nil
    end

    it("should work", function()
        local mockedQuestLogTitle = {
            [1] = {"Feralas", nil, nil, true, false, false, nil, nil},
            [2] = {"The Mark of Quality", 46, nil, false, false, nil, nil, 2822},
        }
        _G.GetQuestLogTitle = function(index)
            return table.unpack(mockedQuestLogTitle[index] or {nil, nil, nil, false, nil, false, nil, nil})
        end
        local markOfQualityComplete = false
        local alphaStrikeProgressed = false
        _G.C_QuestLog = {
            GetQuestObjectives = function(questId)
                if questId == 2822 then
                    if markOfQualityComplete then
                        return {{
                            type = "item",
                            numRequired = 10,
                            text = "Thick Yeti Hide: 10/10",
                            finished = true,
                            numFulfilled = 10,
                        }}
                    else
                        return {{
                            type = "item",
                            numRequired = 10,
                            text = "Thick Yeti Hide: 0/10",
                            finished = false,
                            numFulfilled = 0,
                        }}
                    end
                elseif questId == 7734 then
                    return {{
                        type = "item",
                        numRequired = 10,
                        text = "Rage Scar Yeti Hide: 0/10",
                        finished = false,
                        numFulfilled = 0,
                    }}
                elseif questId == 2863 then
                    if alphaStrikeProgressed then
                        return {{
                            type = "monster",
                            numRequired = 5,
                            text = "Woodpaw Alpha slain: 1/5",
                            finished = false,
                            numFulfilled = 1,
                        }}
                    else
                        return {{
                            type = "monster",
                            numRequired = 5,
                            text = "Woodpaw Alpha slain: 0/5",
                            finished = false,
                            numFulfilled = 0,
                        }}
                    end
                end
                return {}
            end
        }
        QuestLogCache = require("Modules.Quest.QuestLogCache")
        QuestieNameplate = require("Modules.QuestieNameplate")
        QuestieNameplate.UpdateNameplate = spy.new(function() end)
        QuestieQuest = require("Modules.Quest.QuestieQuest")
        QuestieQuest.SetObjectivesDirty = spy.new(function() end)
        QuestieQuest.UpdateQuest = spy.new(function() end)
        QuestieQuest.AcceptQuest = spy.new(function() end)
        QuestieQuest.CompleteQuest = spy.new(function() end)
        QuestieTracker = require("Modules.Tracker.QuestieTracker")
        QuestieTracker.UpdateQuestLines = spy.new(function() end)
        QuestieLib = require("Modules.Libs.QuestieLib")
        QuestieLib.CacheItemNames = spy.new(function() end)
        QuestieCombatQueue = require("Modules.Libs.QuestieCombatQueue")
        QuestieCombatQueue.Queue = function() end
        Sounds = require("Modules.Sounds")
        Sounds.PlayObjectiveComplete = spy.new(function() end)
        Sounds.PlayQuestComplete = spy.new(function() end)
        QuestieJourney = require("Modules.Journey.QuestieJourney")
        QuestieJourney.AcceptQuest = spy.new(function() end)
        QuestieJourney.CompleteQuest = spy.new(function() end)
        QuestieAnnounce = require("Modules.QuestieAnnounce")
        QuestieAnnounce.AcceptedQuest = spy.new(function() end)
        QuestieAnnounce.CompletedQuest = spy.new(function() end)
        QuestieDB = require("Database.QuestieDB")
        QuestieDB.QueryQuestSingle = function() return nil end
        QuestEventHandler = require("Modules.EventHandler.QuestEventHandler")

        QuestEventHandler.InitQuestLogStates({})

        QuestEventHandler:QuestAccepted(2, 2822)
        QuestEventHandler:UnitQuestLogChanged("player")
        QuestEventHandler.QuestLogUpdate()

        local cachedQuest = QuestLogCache.GetQuest(2822)
        assert.equals(0, cachedQuest.isComplete)
        assert.equals(1, #cachedQuest.objectives)
        assert.same({
            finished = false,
            numFulfilled = 0,
            numRequired = 10,
            raw_finished = false,
            raw_numFulfilled = 0,
            raw_text = "Thick Yeti Hide: 0/10",
            text = "Thick Yeti Hide",
            type = "item"
        }, cachedQuest.objectives[1])

        mockedQuestLogTitle[2] = {"The Mark of Quality", 46, nil, false, false, 1, nil, 2822}
        markOfQualityComplete = true

        QuestEventHandler:QuestWatchUpdate(2822)
        QuestEventHandler:UnitQuestLogChanged("player")
        QuestEventHandler.QuestLogUpdate()

        cachedQuest = QuestLogCache.GetQuest(2822)
        assert.equals(1, cachedQuest.isComplete)
        assert.equals(1, #cachedQuest.objectives)
        assert.same({
            finished = true,
            numFulfilled = 10,
            numRequired = 10,
            raw_finished = true,
            raw_numFulfilled = 10,
            raw_text = "Thick Yeti Hide: 10/10",
            text = "Thick Yeti Hide",
            type = "item"
        }, cachedQuest.objectives[1])
        assert.spy(Sounds.PlayObjectiveComplete).was_called(1)

        QuestEventHandler:QuestRemoved(2822)
        QuestEventHandler:UnitQuestLogChanged("player")
        QuestEventHandler.QuestLogUpdate()
        QuestEventHandler:QuestTurnedIn(2822, 4050, 0)

        assert.equals(0, QuestLogCache.GetQuestCount())

        mockedQuestLogTitle[2] = {"Improved Quality", 40, nil, false, false, nil, nil, 7734}
        QuestEventHandler:QuestAccepted(2, 7734)
        QuestEventHandler:UnitQuestLogChanged("player")
        QuestEventHandler.QuestLogUpdate()

        assert.equals(1, QuestLogCache.GetQuestCount())
        cachedQuest = QuestLogCache.GetQuest(7734)
        assert.equals(0, cachedQuest.isComplete)
        assert.equals(1, #cachedQuest.objectives)
        assert.same({
            finished = false,
            numFulfilled = 0,
            numRequired = 10,
            raw_finished = false,
            raw_numFulfilled = 0,
            raw_text = "Rage Scar Yeti Hide: 0/10",
            text = "Rage Scar Yeti Hide",
            type = "item"
        }, cachedQuest.objectives[1])

        mockedQuestLogTitle[3] = {"Alpha Strike", 43, nil, false, false, nil, nil, 2863}
        QuestEventHandler:QuestAccepted(2, 2863)
        QuestEventHandler:UnitQuestLogChanged("player")
        QuestEventHandler.QuestLogUpdate()

        assert.equals(2, QuestLogCache.GetQuestCount())
        cachedQuest = QuestLogCache.GetQuest(2863)
        assert.equals(0, cachedQuest.isComplete)
        assert.equals(1, #cachedQuest.objectives)
        assert.same({
            finished = false,
            numFulfilled = 0,
            numRequired = 5,
            raw_finished = false,
            raw_numFulfilled = 0,
            raw_text = "Woodpaw Alpha slain: 0/5",
            text = "Woodpaw Alpha",
            type = "monster"
        }, cachedQuest.objectives[1])

        alphaStrikeProgressed = true
        QuestEventHandler:UnitQuestLogChanged("player")
        QuestEventHandler.QuestLogUpdate()

        cachedQuest = QuestLogCache.GetQuest(2863)
        assert.equals(0, cachedQuest.isComplete)
        assert.equals(1, #cachedQuest.objectives)
        assert.same({
            finished = false,
            numFulfilled = 1,
            numRequired = 5,
            raw_finished = false,
            raw_numFulfilled = 1,
            raw_text = "Woodpaw Alpha slain: 1/5",
            text = "Woodpaw Alpha",
            type = "monster"
        }, cachedQuest.objectives[1])
    end)
end)
