dofile("setupTests.lua")

describe("QuestLifecycle", function()
    ---@type QuestLifecycle
    local QuestLifecycle
    ---@type QuestieQuest
    local QuestieQuest
    ---@type AvailableQuests
    local AvailableQuests
    ---@type QuestieDB
    local QuestieDB
    ---@type QuestiePlayer
    local QuestiePlayer
    ---@type QuestieTooltips
    local QuestieTooltips

    before_each(function()
        Questie.db.char = {
            complete = {},
            collapsedQuests = {},
            AutoUntrackedQuests = {},
        }
        Questie.SendMessage = spy.new(function() end)

        QuestieDB = QuestieLoader:ImportModule("QuestieDB")
        QuestieDB.GetQuest = spy.new(function() return nil end)
        QuestieDB.QueryQuestSingle = spy.new(function() return nil end)
        QuestieDB.IsDailyQuest = spy.new(function() return false end)

        AvailableQuests = QuestieLoader:ImportModule("AvailableQuests")
        AvailableQuests.RemoveQuest = spy.new(function() end)
        AvailableQuests.CalculateAndDrawAll = spy.new(function() end)

        QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
        QuestiePlayer.currentQuestlog = {}

        QuestieTooltips = QuestieLoader:ImportModule("QuestieTooltips")
        QuestieTooltips.RemoveQuest = spy.new(function() end)

        dofile("Modules/Quest/Lifecycle/QuestLifecycle.lua")
        QuestLifecycle = QuestieLoader:ImportModule("QuestLifecycle")
        QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")

        -- Stub out functions in QuestieQuest that are not under test here
        QuestieQuest.PopulateQuestLogInfo = spy.new(function() end)
        QuestieQuest.PopulateObjectiveNotes = spy.new(function() end)
    end)

    describe("AcceptQuest", function()
        it("should do nothing when quest is not in DB", function()
            QuestieDB.GetQuest = spy.new(function() return nil end)

            QuestLifecycle:AcceptQuest(999)

            assert.spy(AvailableQuests.RemoveQuest).was.not_called()
            assert.spy(QuestieDB.QueryQuestSingle).was.not_called()
            assert.is_nil(QuestiePlayer.currentQuestlog[999])
        end)

        it("should add a new quest to currentQuestlog and populate it", function()
            local quest = {IsComplete = function() return 0 end}
            QuestieDB.GetQuest = spy.new(function() return quest end)
            AvailableQuests.RemoveQuest = spy.new(function(_, callback) callback() end)

            QuestLifecycle:AcceptQuest(100)

            assert.are_equal(quest, QuestiePlayer.currentQuestlog[100])
            assert.spy(AvailableQuests.RemoveQuest).was.called()
            assert.spy(QuestieQuest.PopulateQuestLogInfo).was.called_with(QuestieQuest, quest)
            assert.spy(Questie.SendMessage).was.called_with(Questie, "QC_ID_BROADCAST_QUEST_UPDATE", 100)
            assert.spy(QuestieQuest.PopulateObjectiveNotes).was.called_with(QuestieQuest, quest)
        end)

        it("should reset stale quest state before re-accepting", function()
            local questId = 100
            local quest = {
                IsComplete = function() return 0 end,
                WasComplete = true,
                isComplete = true,
                Objectives = {{}}
            }
            QuestieDB.GetQuest = spy.new(function() return quest end)
            QuestiePlayer.currentQuestlog[questId] = quest

            QuestLifecycle:AcceptQuest(questId)

            assert.is_nil(quest.WasComplete)
            assert.is_nil(quest.isComplete)
            assert.are_same({}, quest.Objectives)
            assert.spy(QuestieTooltips.RemoveQuest).was.called_with(QuestieTooltips, questId)
        end)

        it("should reset stale quest when complete flag is 0", function()
            local questId = 100
            local quest = {
                IsComplete = function() return 0 end,
                isComplete = false,
                Objectives = {}
            }
            QuestieDB.GetQuest = spy.new(function() return quest end)
            QuestiePlayer.currentQuestlog[questId] = quest

            QuestLifecycle:AcceptQuest(questId)

            assert.spy(QuestieTooltips.RemoveQuest).was.called_with(QuestieTooltips, questId)
        end)

        it("should set Alliance tournament eligibility marker", function()
            local allianceQuestId = 13684
            local quest = {IsComplete = function() return 0 end}
            QuestieDB.GetQuest = spy.new(function() return quest end)

            QuestLifecycle:AcceptQuest(allianceQuestId)

            assert.is_true(Questie.db.char.complete[13686])
        end)

        it("should set Horde tournament eligibility marker", function()
            local hordeQuestId = 13691
            local quest = {IsComplete = function() return 0 end}
            QuestieDB.GetQuest = spy.new(function() return quest end)

            QuestLifecycle:AcceptQuest(hordeQuestId)

            assert.is_true(Questie.db.char.complete[13687])
        end)

        it("should set Xiao breadcrumb marker", function()
            local xiaoQuestId = 29577
            local quest = {IsComplete = function() return 0 end}
            QuestieDB.GetQuest = spy.new(function() return quest end)

            QuestLifecycle:AcceptQuest(xiaoQuestId)

            assert.is_true(Questie.db.char.complete[30087])
        end)

        it("should clear character flags on re-accept", function()
            local questId = 100
            Questie.db.char.collapsedQuests = {[questId] = true}
            Questie.db.char.AutoUntrackedQuests = {[questId] = true}
            local quest = {IsComplete = function() return 0 end}
            QuestieDB.GetQuest = spy.new(function() return quest end)

            QuestLifecycle:AcceptQuest(questId)

            assert.is_nil(Questie.db.char.collapsedQuests[questId])
            assert.is_nil(Questie.db.char.AutoUntrackedQuests[questId])
        end)

        it("should not add quest again if already in log without stale flags", function()
            local questId = 100
            local quest = {
                IsComplete = function() return 1 end,
                WasComplete = nil,
                isComplete = nil,
            }
            QuestieDB.GetQuest = spy.new(function() return quest end)
            QuestiePlayer.currentQuestlog[questId] = quest -- already in log, no stale flags

            QuestLifecycle:AcceptQuest(questId)

            -- RemoveQuest should not be called since the quest wasn't re-added
            assert.spy(AvailableQuests.RemoveQuest).was.not_called()
        end)

        it("should reset child daily quests when parent is accepted", function()
            local questId = 100
            local childQuestId = 200
            local quest = {IsComplete = function() return 0 end}
            QuestieDB.GetQuest = spy.new(function() return quest end)
            QuestieDB.QueryQuestSingle = spy.new(function(_, key)
                if key == "childQuests" then
                    return {childQuestId}
                end
            end)
            QuestieDB.IsDailyQuest = spy.new(function() return true end)
            Questie.db.char.complete[childQuestId] = true

            QuestLifecycle:AcceptQuest(questId)

            assert.is_nil(Questie.db.char.complete[childQuestId])
        end)
    end)
end)
