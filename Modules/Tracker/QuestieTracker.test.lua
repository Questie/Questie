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
    ---@type QuestieCombatQueue
    local QuestieCombatQueue

    before_each(function()
        Questie.db.char = {
            collapsedQuests = {},
            AutoUntrackedQuests = {},
            TrackedQuests = {},
            isTrackerExpanded = true,
        }
        Questie.db.profile = {
            trackerEnabled = true,
            minimizeTrackerInInstances = false,
            hideTrackerInInstances = false,
        }

        TrackerUtils = QuestieLoader:ImportModule("TrackerUtils")
        TrackerUtils.UnFocus = spy.new(function() end)
        QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")
        QuestieQuest.ToggleNotes = spy.new(function() end)
        QuestieCombatQueue = QuestieLoader:ImportModule("QuestieCombatQueue")
        QuestieCombatQueue.Queue = function(_, callback) callback() end

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

    describe("HandleZoneChanged", function()
        it("should collapse the tracker when entering an instance with minimize enabled", function()
            Questie.db.profile.minimizeTrackerInInstances = true
            _G.IsInInstance = function() return true end
            QuestieTracker.Collapse = spy.new(function() end)

            QuestieTracker.HandleZoneChanged()

            assert.spy(QuestieTracker.Collapse).was.called()
        end)

        it("should queue the collapse via QuestieCombatQueue instead of calling it directly", function()
            Questie.db.profile.minimizeTrackerInInstances = true
            _G.IsInInstance = function() return true end
            QuestieCombatQueue.Queue = spy.new(function() end)
            QuestieTracker.Collapse = spy.new(function() end)

            QuestieTracker.HandleZoneChanged()

            assert.spy(QuestieCombatQueue.Queue).was.called()
            assert.spy(QuestieTracker.Collapse).was.not_called()
        end)

        it("should hide the tracker directly when entering an instance with hide enabled", function()
            Questie.db.profile.hideTrackerInInstances = true
            _G.IsInInstance = function() return true end
            QuestieTracker.Hide = spy.new(function() end)

            QuestieTracker.HandleZoneChanged()

            assert.spy(QuestieTracker.Hide).was.called()
        end)

        it("should do nothing when the tracker is disabled, even if in an instance with minimize enabled", function()
            Questie.db.profile.trackerEnabled = false
            Questie.db.profile.minimizeTrackerInInstances = true
            _G.IsInInstance = function() return true end
            QuestieTracker.Collapse = spy.new(function() end)

            QuestieTracker.HandleZoneChanged()

            assert.spy(QuestieTracker.Collapse).was.not_called()
        end)

        it("should do nothing when leaving an instance while the tracker is disabled, even if previously minimized", function()
            Questie.db.profile.minimizeTrackerInInstances = true
            _G.IsInInstance = function() return true end
            QuestieTracker.HandleZoneChanged() -- entered instance, minimizedByInstance is now true

            Questie.db.profile.trackerEnabled = false
            _G.IsInInstance = function() return false end
            _G.UnitIsGhost = function() return false end
            Questie.db.char.isTrackerExpanded = false
            QuestieTracker.Expand = spy.new(function() end)

            QuestieTracker.HandleZoneChanged()

            assert.spy(QuestieTracker.Expand).was.not_called()
        end)

        it("should expand the tracker when leaving an instance after having been minimized", function()
            Questie.db.profile.minimizeTrackerInInstances = true
            _G.IsInInstance = function() return true end
            QuestieTracker.HandleZoneChanged() -- entered instance, minimizedByInstance is now true

            _G.IsInInstance = function() return false end
            _G.UnitIsGhost = function() return false end
            Questie.db.char.isTrackerExpanded = false
            QuestieTracker.Expand = spy.new(function() end)

            QuestieTracker.HandleZoneChanged()

            assert.spy(QuestieTracker.Expand).was.called()
        end)

        it("should show the tracker when leaving an instance after having been hidden", function()
            Questie.db.profile.hideTrackerInInstances = true
            _G.IsInInstance = function() return true end
            QuestieTracker.HandleZoneChanged() -- entered instance, hiddenByInstance is now true

            _G.IsInInstance = function() return false end
            QuestieTracker.Show = spy.new(function() end)

            QuestieTracker.HandleZoneChanged()

            assert.spy(QuestieTracker.Show).was.called()
        end)

        it("should not expand when leaving an instance if minimize was turned off in the meantime", function()
            Questie.db.profile.minimizeTrackerInInstances = true
            _G.IsInInstance = function() return true end
            QuestieTracker.HandleZoneChanged() -- entered instance, minimizedByInstance is now true

            Questie.db.profile.minimizeTrackerInInstances = false
            _G.IsInInstance = function() return false end
            _G.UnitIsGhost = function() return false end
            Questie.db.char.isTrackerExpanded = false
            QuestieTracker.Expand = spy.new(function() end)

            QuestieTracker.HandleZoneChanged()

            assert.spy(QuestieTracker.Expand).was.not_called()
        end)

        it("should not expand when leaving an instance while the player is a ghost", function()
            Questie.db.profile.minimizeTrackerInInstances = true
            _G.IsInInstance = function() return true end
            QuestieTracker.HandleZoneChanged() -- entered instance, minimizedByInstance is now true

            _G.IsInInstance = function() return false end
            _G.UnitIsGhost = function() return true end
            Questie.db.char.isTrackerExpanded = false
            QuestieTracker.Expand = spy.new(function() end)

            QuestieTracker.HandleZoneChanged()

            assert.spy(QuestieTracker.Expand).was.not_called()
        end)

        it("should not show when leaving an instance if hide was turned off in the meantime", function()
            Questie.db.profile.hideTrackerInInstances = true
            _G.IsInInstance = function() return true end
            QuestieTracker.HandleZoneChanged() -- entered instance, hiddenByInstance is now true

            Questie.db.profile.hideTrackerInInstances = false
            _G.IsInInstance = function() return false end
            QuestieTracker.Show = spy.new(function() end)

            QuestieTracker.HandleZoneChanged()

            assert.spy(QuestieTracker.Show).was.not_called()
        end)

        it("should do nothing when leaving an instance if the tracker was never minimized or hidden by it", function()
            _G.IsInInstance = function() return false end
            QuestieTracker.Expand = spy.new(function() end)
            QuestieTracker.Show = spy.new(function() end)

            QuestieTracker.HandleZoneChanged()

            assert.spy(QuestieTracker.Expand).was.not_called()
            assert.spy(QuestieTracker.Show).was.not_called()
        end)
    end)
end)
