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
    ---@type QuestieTracker
    local QuestieTracker
    ---@type QuestieCombatQueue
    local QuestieCombatQueue
    ---@type CommsVisibility
    local CommsVisibility

    before_each(function()
        _G.WOW_PROJECT_ID = nil
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
        QuestieDB.IsRepeatable = spy.new(function() return false end)
        QuestieDB.IsWeeklyQuest = spy.new(function() return false end)
        QuestieDB.IsMonthlyQuest = spy.new(function() return false end)

        AvailableQuests = QuestieLoader:ImportModule("AvailableQuests")
        AvailableQuests.RemoveQuest = spy.new(function() end)
        AvailableQuests.CalculateAndDrawAll = spy.new(function() end)

        QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
        QuestiePlayer.currentQuestlog = {}

        QuestieTooltips = QuestieLoader:ImportModule("QuestieTooltips")
        QuestieTooltips.RemoveQuest = spy.new(function() end)

        QuestieTracker = QuestieLoader:ImportModule("QuestieTracker")
        QuestieTracker.RemoveQuest = spy.new(function() end)
        QuestieTracker.Update = spy.new(function() end)

        QuestieCombatQueue = QuestieLoader:ImportModule("QuestieCombatQueue")
        QuestieCombatQueue.Queue = function(_, callback) callback() end

        CommsVisibility = QuestieLoader:ImportModule("CommsVisibility")
        CommsVisibility.ScheduleSnapshot = spy.new(function() end)

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
            assert.spy(CommsVisibility.ScheduleSnapshot).was.called()
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

    describe("CompleteQuest", function()
        it("should remove quest from currentQuestlog", function()
            local questId = 100
            QuestiePlayer.currentQuestlog[questId] = {WasComplete = true, isComplete = true}

            QuestLifecycle:CompleteQuest(questId)

            assert.is_nil(QuestiePlayer.currentQuestlog[questId])
        end)

        it("should reset WasComplete and isComplete flags before removing from log", function()
            local questId = 100
            local quest = {WasComplete = true, isComplete = true}
            QuestiePlayer.currentQuestlog[questId] = quest

            QuestLifecycle:CompleteQuest(questId)

            assert.is_nil(quest.WasComplete)
            assert.is_nil(quest.isComplete)
        end)

        it("should mark non-repeatable quest as complete", function()
            local questId = 100
            QuestieDB.IsRepeatable = spy.new(function() return false end)
            QuestieDB.IsDailyQuest = spy.new(function() return false end)
            QuestieDB.IsWeeklyQuest = spy.new(function() return false end)
            QuestieDB.IsMonthlyQuest = spy.new(function() return false end)

            QuestLifecycle:CompleteQuest(questId)

            assert.is_true(Questie.db.char.complete[questId])
        end)

        it("should not mark repeatable non-daily quest as complete", function()
            local questId = 100
            QuestieDB.IsRepeatable = spy.new(function() return true end)
            QuestieDB.IsDailyQuest = spy.new(function() return false end)
            QuestieDB.IsWeeklyQuest = spy.new(function() return false end)
            QuestieDB.IsMonthlyQuest = spy.new(function() return false end)

            QuestLifecycle:CompleteQuest(questId)

            assert.is_false(Questie.db.char.complete[questId])
        end)

        it("should mark repeatable daily quest as complete", function()
            local questId = 100
            QuestieDB.IsRepeatable = spy.new(function() return true end)
            QuestieDB.IsDailyQuest = spy.new(function() return true end)
            QuestieDB.IsWeeklyQuest = spy.new(function() return false end)
            QuestieDB.IsMonthlyQuest = spy.new(function() return false end)

            QuestLifecycle:CompleteQuest(questId)

            assert.is_true(Questie.db.char.complete[questId])
        end)

        it("should set Alliance champion marker and clear tournament eligibility marker on WotLK+", function()
            _G.WOW_PROJECT_ID = 11 -- WotLK
            dofile("Modules/Expansions.lua")
            local questId = 13699 -- in allianceChampionMarkerQuests
            Questie.db.char.complete[13686] = true

            QuestLifecycle:CompleteQuest(questId)

            _G.WOW_PROJECT_ID = nil
            dofile("Modules/Expansions.lua")
            assert.is_true(Questie.db.char.complete[13700])
            assert.is_nil(Questie.db.char.complete[13686])
        end)

        it("should set Horde champion marker and clear tournament eligibility marker on WotLK+", function()
            _G.WOW_PROJECT_ID = 11 -- WotLK
            dofile("Modules/Expansions.lua")
            local questId = 13726 -- in hordeChampionMarkerQuests
            Questie.db.char.complete[13687] = true

            QuestLifecycle:CompleteQuest(questId)

            _G.WOW_PROJECT_ID = nil
            dofile("Modules/Expansions.lua")
            assert.is_true(Questie.db.char.complete[13701])
            assert.is_nil(Questie.db.char.complete[13687])
        end)

        it("should remove child quests that are not in the quest log", function()
            local questId = 100
            local childQuestId = 200
            QuestieDB.QueryQuestSingle = spy.new(function(_, key)
                if key == "childQuests" then
                    return {childQuestId}
                end
            end)

            QuestLifecycle:CompleteQuest(questId)

            assert.spy(AvailableQuests.RemoveQuest).was.called_with(childQuestId)
        end)

        it("should not remove child quest if it is in the quest log", function()
            local questId = 100
            local childQuestId = 200
            QuestiePlayer.currentQuestlog[childQuestId] = {}
            QuestieDB.QueryQuestSingle = spy.new(function(_, key)
                if key == "childQuests" then
                    return {childQuestId}
                end
            end)

            QuestLifecycle:CompleteQuest(questId)

            -- RemoveQuest is called for the parent quest itself, but not for the child
            assert.spy(AvailableQuests.RemoveQuest).was.not_called_with(childQuestId)
        end)

        it("should remove quest from tracker", function()
            local questId = 100

            QuestLifecycle:CompleteQuest(questId)

            assert.spy(QuestieTracker.RemoveQuest).was.called_with(QuestieTracker, questId)
        end)

        it("should schedule snapshot for comms visibility", function()
            local questId = 100

            QuestLifecycle:CompleteQuest(questId)

            assert.spy(CommsVisibility.ScheduleSnapshot).was.called()
        end)

        it("should call AvailableQuests.RemoveQuest with callback that calls CalculateAndDrawAll", function()
            local questId = 100
            AvailableQuests.RemoveQuest = spy.new(function(_questId, callback)
                if callback then
                    callback()
                end
            end)

            QuestLifecycle:CompleteQuest(questId)

            assert.spy(AvailableQuests.RemoveQuest).was.called()
            assert.spy(AvailableQuests.CalculateAndDrawAll).was.called()
        end)

        it("should work when quest is not in currentQuestlog", function()
            local questId = 999

            -- Should not error
            QuestLifecycle:CompleteQuest(questId)

            assert.is_nil(QuestiePlayer.currentQuestlog[questId])
        end)
    end)

    describe("AbandonQuest", function()
        it("should do nothing when quest is not in currentQuestlog", function()
            QuestLifecycle:AbandonQuest(999)

            assert.spy(QuestieDB.GetQuest).was.not_called()
            assert.spy(AvailableQuests.RemoveQuest).was.not_called()
        end)

        it("should remove quest from currentQuestlog", function()
            local questId = 100
            local quest = {}
            QuestiePlayer.currentQuestlog[questId] = quest
            QuestieDB.GetQuest = spy.new(function() return quest end)
            AvailableQuests.RemoveQuest = spy.new(function(_, callback) callback() end)

            QuestLifecycle:AbandonQuest(questId)

            assert.is_nil(QuestiePlayer.currentQuestlog[questId])

            assert.spy(QuestieTracker.RemoveQuest).was.called_with(QuestieTracker, questId)

            assert.spy(CommsVisibility.ScheduleSnapshot).was.called()
            assert.spy(AvailableQuests.RemoveQuest).was.called()
            assert.spy(AvailableQuests.CalculateAndDrawAll).was.called()
        end)

        it("should reset quest objectives and flags", function()
            local questId = 100
            local quest = {WasComplete = true, isComplete = true, Objectives = {{}}}
            QuestiePlayer.currentQuestlog[questId] = quest
            QuestieDB.GetQuest = spy.new(function() return quest end)

            QuestLifecycle:AbandonQuest(questId)

            assert.are_same({}, quest.Objectives)
            assert.is_nil(quest.WasComplete)
            assert.is_nil(quest.isComplete)
        end)

        it("should clear Alliance tournament eligibility marker", function()
            local questId = 13684 -- in allianceTournamentMarkerQuests
            QuestiePlayer.currentQuestlog[questId] = {}
            QuestieDB.GetQuest = spy.new(function() return {} end)
            Questie.db.char.complete[13686] = true

            QuestLifecycle:AbandonQuest(questId)

            assert.is_nil(Questie.db.char.complete[13686])
        end)

        it("should clear Horde tournament eligibility marker", function()
            local questId = 13691 -- in hordeTournamentMarkerQuests
            QuestiePlayer.currentQuestlog[questId] = {}
            QuestieDB.GetQuest = spy.new(function() return {} end)
            Questie.db.char.complete[13687] = true

            QuestLifecycle:AbandonQuest(questId)

            assert.is_nil(Questie.db.char.complete[13687])
        end)

        it("should remove child quests that are not in the quest log", function()
            local questId = 100
            local childQuestId = 200
            QuestiePlayer.currentQuestlog[questId] = {}
            QuestieDB.GetQuest = spy.new(function() return {} end)
            QuestieDB.QueryQuestSingle = spy.new(function(_id, key)
                if key == "childQuests" then
                    return {childQuestId}
                end
            end)

            QuestLifecycle:AbandonQuest(questId)

            assert.spy(AvailableQuests.RemoveQuest).was.called_with(childQuestId)
        end)

        it("should not remove child quest if it is in the quest log", function()
            local questId = 100
            local childQuestId = 200
            QuestiePlayer.currentQuestlog[questId] = {}
            QuestiePlayer.currentQuestlog[childQuestId] = {}
            QuestieDB.GetQuest = spy.new(function() return {} end)
            QuestieDB.QueryQuestSingle = spy.new(function(_id, key)
                if key == "childQuests" then
                    return {childQuestId}
                end
            end)

            QuestLifecycle:AbandonQuest(questId)

            assert.spy(AvailableQuests.RemoveQuest).was.not_called_with(childQuestId)
        end)
    end)
end)
