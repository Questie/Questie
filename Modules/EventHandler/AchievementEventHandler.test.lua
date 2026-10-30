dofile("setupTests.lua")

describe("AchievementEventHandler", function()
    ---@type AchievementEventHandler
    local AchievementEventHandler
    local QuestieTracker, QuestieCombatQueue, AchievementTracking
    local originalUpdate, originalQueue, originalGetTrackedIds, trackedIds

    before_each(function()
        QuestieTracker = QuestieLoader:ImportModule("QuestieTracker")
        QuestieCombatQueue = QuestieLoader:ImportModule("QuestieCombatQueue")
        AchievementTracking = QuestieLoader:ImportModule("AchievementTracking")
        originalUpdate, originalQueue = QuestieTracker.Update, QuestieCombatQueue.Queue
        originalGetTrackedIds = AchievementTracking.GetTrackedIds
        trackedIds = {}
        QuestieTracker.Update = spy.new(function() end)
        QuestieCombatQueue.Queue = function(_, callback) callback() end
        AchievementTracking.GetTrackedIds = function() return trackedIds end
        Questie.db.char.collapsedQuests = {}
        Questie.db.char.collapsedZones = {}

        dofile("Modules/EventHandler/AchievementEventHandler.lua")
        AchievementEventHandler = QuestieLoader:ImportModule("AchievementEventHandler")
    end)

    after_each(function()
        QuestieTracker.Update, QuestieCombatQueue.Queue = originalUpdate, originalQueue
        AchievementTracking.GetTrackedIds = originalGetTrackedIds
    end)

    describe("AchievementEarned", function()
        it("should update the tracker", function()
            AchievementEventHandler.AchievementEarned()

            assert.spy(QuestieTracker.Update).was.called(1)
        end)
    end)

    describe("TrackedAchievementListChanged", function()
        it("should update the tracker", function()
            AchievementEventHandler.TrackedAchievementListChanged(12, true)

            assert.spy(QuestieTracker.Update).was.called(1)
        end)

        it("should expand a newly tracked achievement and the Achievements zone", function()
            Questie.db.char.collapsedQuests = {[12] = true, [13] = true}
            Questie.db.char.collapsedZones = {Achievements = true, Durotar = true}

            AchievementEventHandler.TrackedAchievementListChanged(12, true)

            assert.are_same({[13] = true}, Questie.db.char.collapsedQuests)
            assert.are_same({Durotar = true}, Questie.db.char.collapsedZones)
        end)

        it("should expand when the game does not say whether the achievement was added", function()
            Questie.db.char.collapsedQuests = {[12] = true}

            AchievementEventHandler.TrackedAchievementListChanged(12)

            assert.are_same({}, Questie.db.char.collapsedQuests)
        end)

        it("should keep the minimized states when an achievement is untracked", function()
            Questie.db.char.collapsedQuests = {[12] = true}
            Questie.db.char.collapsedZones = {Achievements = true}

            AchievementEventHandler.TrackedAchievementListChanged(12, false)

            assert.are_same({[12] = true}, Questie.db.char.collapsedQuests)
            assert.are_same({Achievements = true}, Questie.db.char.collapsedZones)
            assert.spy(QuestieTracker.Update).was.called(1)
        end)

        it("should not change the minimized states without an achievement id", function()
            Questie.db.char.collapsedZones = {Achievements = true}

            AchievementEventHandler.TrackedAchievementListChanged(0, true)

            assert.are_same({Achievements = true}, Questie.db.char.collapsedZones)
        end)
    end)

    describe("CriteriaUpdate", function()
        it("should update the tracker while achievements are tracked", function()
            trackedIds = {12}

            AchievementEventHandler.CriteriaUpdate()

            assert.spy(QuestieTracker.Update).was.called(1)
        end)

        it("should not update the tracker without tracked achievements", function()
            AchievementEventHandler.CriteriaUpdate()

            assert.spy(QuestieTracker.Update).was.not_called()
        end)
    end)
end)
