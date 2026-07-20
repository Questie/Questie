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
    ---@type CommsVisibility
    local CommsVisibility
    ---@type QuestieTracker
    local QuestieTracker
    ---@type QuestieCombatQueue
    local QuestieCombatQueue

    before_each(function()
        Questie.db.char = {}
        Questie.Debug = function() end
        Questie.SendMessage = spy.new(function() end)
        ZoneDB = QuestieLoader:ImportModule("ZoneDB")
        ZoneDB.GetDungeons = function() return {} end
        QuestieDB = QuestieLoader:ImportModule("QuestieDB")
        QuestieDB.GetQuest = spy.new(function() return {} end)
        QuestieDB.QueryQuestSingle = spy.new(function() return nil end)
        QuestieDB.IsDailyQuest = spy.new(function() return false end)
        QuestieDB.IsRepeatable = spy.new(function() return false end)
        QuestieDB.IsWeeklyQuest = spy.new(function() return false end)
        QuestieDB.IsMonthlyQuest = spy.new(function() return false end)
        AvailableQuests = QuestieLoader:ImportModule("AvailableQuests")
        AvailableQuests.RemoveQuest = spy.new(function() end)
        AvailableQuests.CalculateAndDrawAll = spy.new(function() end)
        QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
        QuestiePlayer.currentQuestlog = {}
        CommsVisibility = QuestieLoader:ImportModule("CommsVisibility")
        CommsVisibility.ScheduleSnapshot = spy.new(function() end)
        QuestieTracker = QuestieLoader:ImportModule("QuestieTracker")
        QuestieTracker.RemoveQuest = spy.new(function() end)
        QuestieTracker.Update = spy.new(function() end)
        QuestieCombatQueue = QuestieLoader:ImportModule("QuestieCombatQueue")
        QuestieCombatQueue.Queue = spy.new(function() end)

        dofile("Modules/Quest/QuestieQuest.lua")
        QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")
    end)

    describe("AcceptQuest", function()
        it("schedules a visibility snapshot after adding the accepted quest", function()
            local questId = 123
            local quest = {IsComplete = function() return 1 end}
            Questie.db.char = {complete = {}, AutoUntrackedQuests = {[questId] = true}, collapsedQuests = {}}
            QuestieDB.GetQuest = spy.new(function() return quest end)
            QuestieQuest.PopulateQuestLogInfo = spy.new(function() end)
            QuestieQuest.PopulateObjectiveNotes = spy.new(function() end)

            QuestieQuest:AcceptQuest(questId)

            assert.are_equal(quest, QuestiePlayer.currentQuestlog[questId])
            assert.is_nil(Questie.db.char.AutoUntrackedQuests[questId])
            assert.spy(CommsVisibility.ScheduleSnapshot).was.called_with(CommsVisibility, "ACCEPT_QUEST")
        end)
    end)

    describe("CompleteQuest", function()
        it("schedules a visibility snapshot after removing the completed quest", function()
            local questId = 123
            Questie.db.char = {complete = {}}
            QuestiePlayer.currentQuestlog[questId] = {WasComplete = true, isComplete = true}

            QuestieQuest:CompleteQuest(questId)

            assert.is_nil(QuestiePlayer.currentQuestlog[questId])
            assert.spy(QuestieTracker.RemoveQuest).was.called_with(QuestieTracker, questId)
            assert.spy(CommsVisibility.ScheduleSnapshot).was.called_with(CommsVisibility, "COMPLETE_QUEST")
        end)
    end)

    describe("AbandonedQuest", function()
        it("schedules a visibility snapshot after removing the abandoned quest", function()
            local questId = 123
            Questie.db.char = {complete = {}}
            QuestiePlayer.currentQuestlog[questId] = {}
            QuestieDB.GetQuest = spy.new(function() return {} end)

            QuestieQuest:AbandonedQuest(questId)

            assert.is_nil(QuestiePlayer.currentQuestlog[questId])
            assert.spy(QuestieTracker.RemoveQuest).was.called_with(QuestieTracker, questId)
            assert.spy(CommsVisibility.ScheduleSnapshot).was.called_with(CommsVisibility, "ABANDON_QUEST")
        end)
    end)

    describe("UnhideQuest", function()
        it("should unhide a quest", function()
            local questId = 123
            Questie.db.char = {hidden = {[questId] = true}}
            QuestieQuest.PopulateObjectiveNotes = spy.new(function() end)

            QuestieQuest:UnhideQuest(questId)

            assert.is_nil(Questie.db.char.hidden[questId])
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
            assert.spy(AvailableQuests.CalculateAndDrawAll).was.not_called()
            assert.spy(QuestieDB.GetQuest).was.called_with(123)
            assert.spy(QuestieQuest.PopulateObjectiveNotes).was.called_with(QuestieQuest, {})
        end)
    end)
end)
