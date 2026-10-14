dofile("setupTests.lua")

describe("TrackerActiveQuest", function()
    ---@type TrackerActiveQuest
    local TrackerActiveQuest
    ---@type QuestieTracker
    local QuestieTracker

    local originalCSuperTrack, originalTimer
    local activeQuestId
    local sortedQuestIds
    local questDetails
    local timers
    local timerDelay

    local function _RunTimers()
        local pending = timers
        timers = {}
        for _, callback in ipairs(pending) do
            callback()
        end
    end

    before_each(function()
        originalCSuperTrack = _G.C_SuperTrack
        originalTimer = _G.C_Timer
        timers = {}
        _G.C_Timer = {After = function(delay, callback)
            timerDelay = delay
            table.insert(timers, callback)
        end}
        activeQuestId = 0
        _G.C_SuperTrack = {
            GetSuperTrackedQuestID = function() return activeQuestId end,
            SetSuperTrackedQuestID = spy.new(function(questId) activeQuestId = questId end),
        }

        Questie.db.profile.trackerShowActiveQuestOnTop = false
        Questie.db.profile.trackerKeepActiveQuestInZone = false

        sortedQuestIds = {1, 2, 3}
        questDetails = {
            [1] = {zoneName = "The Barrens"},
            [2] = {zoneName = "The Barrens"},
            [3] = {zoneName = "Shaman"},
        }

        QuestieTracker = QuestieLoader:ImportModule("QuestieTracker")
        QuestieTracker.Update = spy.new(function() end)
        QuestieLoader:ImportModule("QuestieCombatQueue").Queue = function(_, callback) callback() end

        dofile("Modules/Tracker/TrackerActiveQuest.lua")
        TrackerActiveQuest = QuestieLoader:ImportModule("TrackerActiveQuest")
    end)

    after_each(function()
        _G.C_SuperTrack = originalCSuperTrack
        _G.C_Timer = originalTimer
    end)

    describe("IsAvailable", function()
        it("should be available when the client can super track quests", function()
            assert.is_true(TrackerActiveQuest.IsAvailable())
        end)

        it("should not be available without C_SuperTrack", function()
            _G.C_SuperTrack = nil

            assert.is_false(TrackerActiveQuest.IsAvailable())
        end)
    end)

    describe("GetActiveQuestId", function()
        it("should return the active quest", function()
            activeQuestId = 96

            assert.are_same(96, TrackerActiveQuest.GetActiveQuestId())
        end)

        it("should return nil when there is no active quest", function()
            activeQuestId = 0

            assert.is_nil(TrackerActiveQuest.GetActiveQuestId())
        end)

        it("should return nil without C_SuperTrack", function()
            _G.C_SuperTrack = nil

            assert.is_nil(TrackerActiveQuest.GetActiveQuestId())
        end)
    end)

    describe("ToggleQuest", function()
        it("should make a quest the active quest", function()
            activeQuestId = 914

            TrackerActiveQuest.ToggleQuest(96)

            assert.spy(C_SuperTrack.SetSuperTrackedQuestID).was.called_with(96)
        end)

        it("should clear the active quest when the quest already is the active quest", function()
            activeQuestId = 96

            TrackerActiveQuest.ToggleQuest(96)

            assert.spy(C_SuperTrack.SetSuperTrackedQuestID).was.called_with(0)
        end)

        it("should do nothing without C_SuperTrack", function()
            _G.C_SuperTrack = nil

            TrackerActiveQuest.ToggleQuest(96)

            assert.are_same({}, timers)
        end)

        it("should update the tracker when the active quest is shown on top", function()
            Questie.db.profile.trackerShowActiveQuestOnTop = true

            TrackerActiveQuest.ToggleQuest(96)
            _RunTimers()

            assert.spy(QuestieTracker.Update).was.called(1)
        end)
    end)

    describe("GetQuestIdOnTop", function()
        it("should return nil when the option is disabled", function()
            activeQuestId = 2

            assert.is_nil(TrackerActiveQuest.GetQuestIdOnTop(questDetails))
        end)

        it("should return nil when there is no active quest", function()
            Questie.db.profile.trackerShowActiveQuestOnTop = true

            assert.is_nil(TrackerActiveQuest.GetQuestIdOnTop(questDetails))
        end)

        it("should return the active quest", function()
            Questie.db.profile.trackerShowActiveQuestOnTop = true
            activeQuestId = 3

            assert.are_same(3, TrackerActiveQuest.GetQuestIdOnTop(questDetails))
        end)

        it("should return nil when the active quest is not in the tracker", function()
            Questie.db.profile.trackerShowActiveQuestOnTop = true
            activeQuestId = 99

            assert.is_nil(TrackerActiveQuest.GetQuestIdOnTop(questDetails))
        end)
    end)

    describe("GetQuestIdsBelowTop", function()
        it("should return the sorted quests unchanged without a quest on top", function()
            assert.are.equal(sortedQuestIds, TrackerActiveQuest.GetQuestIdsBelowTop(sortedQuestIds, nil))
        end)

        it("should remove the quest on top", function()
            assert.are_same({1, 2}, TrackerActiveQuest.GetQuestIdsBelowTop(sortedQuestIds, 3))
            assert.are_same({1, 2, 3}, sortedQuestIds)
        end)

        it("should keep the quest on top in its zone when enabled", function()
            Questie.db.profile.trackerKeepActiveQuestInZone = true

            assert.are.equal(sortedQuestIds, TrackerActiveQuest.GetQuestIdsBelowTop(sortedQuestIds, 3))
        end)
    end)

    describe("OnActiveQuestChanged", function()
        it("should update the tracker after the update throttle when the active quest is shown on top", function()
            Questie.db.profile.trackerShowActiveQuestOnTop = true

            TrackerActiveQuest.OnActiveQuestChanged()

            assert.spy(QuestieTracker.Update).was.not_called()
            assert.is_true(timerDelay > 0.1)
            _RunTimers()
            assert.spy(QuestieTracker.Update).was.called(1)
        end)

        it("should not update the tracker when the active quest is not shown on top", function()
            TrackerActiveQuest.OnActiveQuestChanged()
            _RunTimers()

            assert.spy(QuestieTracker.Update).was.not_called()
        end)
    end)

    describe("Initialize", function()
        local originalCreateFrame
        local eventFrame

        before_each(function()
            originalCreateFrame = _G.CreateFrame
            eventFrame = {
                RegisterEvent = spy.new(function() end),
                SetScript = spy.new(function() end),
            }
            _G.CreateFrame = function() return eventFrame end
        end)

        after_each(function()
            _G.CreateFrame = originalCreateFrame
        end)

        it("should listen to active quest changes", function()
            TrackerActiveQuest.Initialize()

            assert.spy(eventFrame.RegisterEvent).was.called_with(eventFrame, "SUPER_TRACKING_CHANGED")
            assert.spy(eventFrame.SetScript).was.called_with(eventFrame, "OnEvent", TrackerActiveQuest.OnActiveQuestChanged)
        end)

        it("should not listen without C_SuperTrack", function()
            _G.C_SuperTrack = nil

            TrackerActiveQuest.Initialize()

            assert.spy(eventFrame.RegisterEvent).was.not_called()
        end)

        it("should not listen when the client does not know the event", function()
            eventFrame.RegisterEvent = function() error("unknown event") end

            TrackerActiveQuest.Initialize()

            assert.spy(eventFrame.SetScript).was.not_called()
        end)
    end)
end)
