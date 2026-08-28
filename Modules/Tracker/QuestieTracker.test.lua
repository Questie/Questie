dofile("setupTests.lua")

_G.GetQuestTimers = function() return nil end

-- Real Classic Alliance Elwynn Forest quests: 11 = Riverpaw Gnoll Bounty, 112 = Collecting Kelp.
local RIVERPAW_GNOLL_BOUNTY_ID = 11
local COLLECTING_KELP_ID = 112
local COLLECTING_KELP_OBJECTIVE_INDEX = 1

describe("QuestieTracker", function()
    ---@type QuestieTracker
    local QuestieTracker
    ---@type TrackerUtils
    local TrackerUtils
    ---@type QuestieQuest
    local QuestieQuest

    before_each(function()
        Questie.db.char = {
            collapsedQuests = {},
            AutoUntrackedQuests = {},
            TrackedQuests = {},
            isTrackerExpanded = true,
        }
        Questie.db.profile = {
            trackerEnabled = true,
        }

        TrackerUtils = QuestieLoader:ImportModule("TrackerUtils")
        TrackerUtils.UnFocus = spy.new(function() end)
        QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")
        QuestieQuest.ToggleNotes = spy.new(function() end)

        dofile("Modules/Tracker/QuestieTracker.lua")
        QuestieTracker = QuestieLoader:ImportModule("QuestieTracker")
    end)

    describe("RemoveQuest", function()
        it("should not unfocus when the removed quest id is only a prefix of the focused quest id", function()
            Questie.db.char.TrackerFocus = tostring(COLLECTING_KELP_ID) .. " " .. tostring(COLLECTING_KELP_OBJECTIVE_INDEX)

            QuestieTracker:RemoveQuest(RIVERPAW_GNOLL_BOUNTY_ID)

            assert.spy(TrackerUtils.UnFocus).was.not_called()
            assert.spy(QuestieQuest.ToggleNotes).was.not_called()
        end)

        it("should unfocus when the removed quest id matches the focused quest id", function()
            Questie.db.char.TrackerFocus = tostring(COLLECTING_KELP_ID) .. " " .. tostring(COLLECTING_KELP_OBJECTIVE_INDEX)

            QuestieTracker:RemoveQuest(COLLECTING_KELP_ID)

            assert.spy(TrackerUtils.UnFocus).was.called()
            assert.spy(QuestieQuest.ToggleNotes).was.called_with(QuestieQuest, true)
        end)
    end)

    describe("ToggleTracker", function()
        it("should collapse when tracker is expanded", function()
            Questie.db.char.isTrackerExpanded = true
            QuestieTracker.Collapse = spy.new(function() end)

            QuestieTracker.ToggleTracker()

            assert.spy(QuestieTracker.Collapse).was.called()
        end)

        it("should expand when tracker is collapsed", function()
            Questie.db.char.isTrackerExpanded = false
            QuestieTracker.Expand = spy.new(function() end)

            QuestieTracker.ToggleTracker()

            assert.spy(QuestieTracker.Expand).was.called()
        end)

        it("should do nothing when tracker is disabled", function()
            Questie.db.profile.trackerEnabled = false
            QuestieTracker.Collapse = spy.new(function() end)
            QuestieTracker.Expand = spy.new(function() end)

            QuestieTracker.ToggleTracker()

            assert.spy(QuestieTracker.Collapse).was.not_called()
            assert.spy(QuestieTracker.Expand).was.not_called()
        end)
    end)
end)
