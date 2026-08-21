dofile("setupTests.lua")

describe("QuestieQuest", function()
    ---@type QuestieQuest
    local QuestieQuest
    ---@type AvailableQuests
    local AvailableQuests
    ---@type ZoneDB
    local ZoneDB
    ---@type QuestieDB
    local QuestieDB
    ---@type QuestiePlayer
    local QuestiePlayer
    ---@type QuestieMap
    local QuestieMap
    ---@type QuestLogCache
    local QuestLogCache
    ---@type QuestieCombatQueue
    local QuestieCombatQueue
    ---@type CommsVisibility
    local CommsVisibility
    ---@type l10n
    local l10n

    before_each(function()
        Questie.db.char = {}
        ZoneDB = QuestieLoader:ImportModule("ZoneDB")
        ZoneDB.GetDungeons = function() return {} end
        QuestieDB = QuestieLoader:ImportModule("QuestieDB")
        QuestieDB.GetQuest = spy.new(function() return {} end)
        AvailableQuests = QuestieLoader:ImportModule("AvailableQuests")
        AvailableQuests.CalculateAndDrawAll = spy.new(function() end)
        QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
        QuestiePlayer.currentQuestlog = {}
        QuestieMap = QuestieLoader:ImportModule("QuestieMap")
        QuestLogCache = QuestieLoader:ImportModule("QuestLogCache")
        QuestieCombatQueue = QuestieLoader:ImportModule("QuestieCombatQueue")
        QuestieCombatQueue.Queue = function() end
        CommsVisibility = QuestieLoader:ImportModule("CommsVisibility")
        CommsVisibility.ScheduleSnapshot = spy.new(function() end)
        l10n = QuestieLoader:ImportModule("l10n")
        setmetatable(l10n, {__call = function(_, key, ...) return key end})

        dofile("Modules/Quest/QuestieQuest.lua")
        QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")
    end)

    describe("UnhideQuest", function()
        it("should unhide a quest", function()
            local questId = 123
            Questie.db.char = {hidden = {[questId] = true}}
            QuestieQuest.PopulateObjectiveNotes = spy.new(function() end)

            QuestieQuest:UnhideQuest(questId)

            assert.is_nil(Questie.db.char.hidden[questId])
            assert.spy(CommsVisibility.ScheduleSnapshot).was.called()
            assert.spy(AvailableQuests.CalculateAndDrawAll).was.called()
            assert.spy(QuestieDB.GetQuest).was.not_called()
            assert.spy(QuestieQuest.PopulateObjectiveNotes).was.not_called()
        end)

        it("should unhide a quest that is in the quest log", function()
            local questId = 123
            Questie.db.char = {hidden = {[questId] = true}}
            QuestiePlayer.currentQuestlog[questId] = true
            QuestieQuest.PopulateObjectiveNotes = spy.new(function() end)

            QuestieQuest:UnhideQuest(questId)

            assert.is_nil(Questie.db.char.hidden[questId])
            assert.spy(CommsVisibility.ScheduleSnapshot).was.called()
            assert.spy(AvailableQuests.CalculateAndDrawAll).was.not_called()
            assert.spy(QuestieDB.GetQuest).was.called_with(123)
            assert.spy(QuestieQuest.PopulateObjectiveNotes).was.called_with(QuestieQuest, {})
        end)
    end)

    describe("ShowQuestIcons", function()
        it("should not throw an error when called from a coroutine", function()
            QuestieMap.questIdFrames = {}

            local co = coroutine.create(function()
                QuestieQuest:ShowQuestIcons()
            end)

            assert.is_true(coroutine.resume(co))
        end)

        it("should throw an error when not called from a coroutine", function()
            assert.has_error(function()
                QuestieQuest:ShowQuestIcons()
            end, "ShowQuestIcons must be called from a coroutine")
        end)
    end)

    describe("HideQuestIcons", function()
        it("should not throw an error when called from a coroutine", function()
            QuestieMap.questIdFrames = {}

            local co = coroutine.create(function()
                QuestieQuest:HideQuestIcons()
            end)

            assert.is_true(coroutine.resume(co))
        end)

        it("should throw an error when not called from a coroutine", function()
            assert.has_error(function()
                QuestieQuest:HideQuestIcons()
            end, "HideQuestIcons must be called from a coroutine")
        end)
    end)

    describe("GetAllQuestIds", function()
        it("should not throw an error when called from a coroutine", function()
            QuestLogCache.questLog_DO_NOT_MODIFY = {}

            local co = coroutine.create(function()
                QuestieQuest:GetAllQuestIds()
            end)

            assert.is_true(coroutine.resume(co))
        end)

        it("should throw an error when not called from a coroutine", function()
            assert.has_error(function()
                QuestieQuest:GetAllQuestIds()
            end, "GetAllQuestIds must be called from a coroutine")
        end)
    end)

    describe("PopulateObjective", function()
        it("should not throw an error when called from a coroutine", function()
            local quest = {ObjectiveData = {}}
            local objective = {Description = "test"}

            local co = coroutine.create(function()
                QuestieQuest:PopulateObjective(quest, 1, objective, false)
            end)

            assert.is_true(coroutine.resume(co))
        end)

        it("should throw an error when not called from a coroutine", function()
            assert.has_error(function()
                QuestieQuest:PopulateObjective({}, 1, {Description = "test"}, false)
            end, "PopulateObjective must be called from a coroutine")
        end)
    end)

    describe("RegisterObjectiveTooltips", function()
        before_each(function()
            QuestieQuest.private.objectiveSpawnListCallTable = {}
        end)

        it("should not crash when objectives have nil spawnList (guard against nil in next())", function()
            -- The bug was that RegisterObjectiveTooltips called next(objective.spawnList) without checking if spawnList was nil first
            -- This should complete without error (not crash on "bad argument #1 to next")
            local quest = {
                Id = 123,
                Objectives = {},
                SpecialObjectives = {},
                ObjectiveData = {}
            }

            -- Should not throw an error
            QuestieQuest.RegisterObjectiveTooltips(quest)
            assert.is_true(true)
        end)

        it("should not crash when special objectives have nil spawnList", function()
            -- Same check for SpecialObjectives path
            local quest = {
                Id = 123,
                Objectives = {},
                SpecialObjectives = {},
                ObjectiveData = {}
            }

            -- Should not throw an error
            QuestieQuest.RegisterObjectiveTooltips(quest)
            assert.is_true(true)
        end)

        it("should assign Index to regular objectives if not already set", function()
            local quest = {
                Id = 123,
                Objectives = {
                    [1] = {Description = "Objective 1", spawnList = {}},
                    [5] = {Description = "Objective 5", spawnList = {}},
                },
                SpecialObjectives = {},
                ObjectiveData = {}
            }

            assert.is_nil(quest.Objectives[1].Index)
            assert.is_nil(quest.Objectives[5].Index)

            QuestieQuest.RegisterObjectiveTooltips(quest)

            assert.are_equal(1, quest.Objectives[1].Index)
            assert.are_equal(5, quest.Objectives[5].Index)
        end)

        it("should assign Index to special objectives (64 + loop index) before processing", function()
            local quest = {
                Id = 123,
                Objectives = {},
                SpecialObjectives = {
                    {Description = "Special 1", spawnList = {}},
                    {Description = "Special 2", spawnList = {}},
                },
                ObjectiveData = {}
            }

            assert.is_nil(quest.SpecialObjectives[1].Index)
            assert.is_nil(quest.SpecialObjectives[2].Index)

            QuestieQuest.RegisterObjectiveTooltips(quest)

            assert.are_equal(65, quest.SpecialObjectives[1].Index) -- 64 + 1
            assert.are_equal(66, quest.SpecialObjectives[2].Index) -- 64 + 2
        end)
    end)
end)
