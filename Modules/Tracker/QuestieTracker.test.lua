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

        it("should not claim ownership of an already-manually-minimized tracker when entering an instance, so it is not auto-expanded on leaving", function()
            Questie.db.profile.minimizeTrackerInInstances = true
            Questie.db.char.isTrackerExpanded = false -- manually minimized by the player before entering
            _G.IsInInstance = function() return true end
            QuestieTracker.Collapse = spy.new(function() end)

            QuestieTracker.HandleZoneChanged() -- entering the instance

            _G.IsInInstance = function() return false end
            _G.UnitIsGhost = function() return false end
            QuestieTracker.Expand = spy.new(function() end)

            QuestieTracker.HandleZoneChanged() -- leaving the instance

            assert.spy(QuestieTracker.Expand).was.not_called()
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

    describe("OnMinimizeInInstancesChanged", function()
        it("should collapse the tracker when enabled while in an instance and expanded", function()
            Questie.db.char.isTrackerExpanded = true
            _G.IsInInstance = function() return true end
            QuestieTracker.Collapse = spy.new(function() end)

            QuestieTracker.OnMinimizeInInstancesChanged(true)

            assert.spy(QuestieTracker.Collapse).was.called()
        end)

        it("should not collapse the tracker when enabled while not in an instance", function()
            _G.IsInInstance = function() return false end
            QuestieTracker.Collapse = spy.new(function() end)

            QuestieTracker.OnMinimizeInInstancesChanged(true)

            assert.spy(QuestieTracker.Collapse).was.not_called()
        end)

        it("should expand the tracker when disabled after it claimed ownership of the collapse", function()
            Questie.db.char.isTrackerExpanded = true
            _G.IsInInstance = function() return true end
            QuestieTracker.OnMinimizeInInstancesChanged(true) -- claims ownership

            Questie.db.char.isTrackerExpanded = false
            QuestieTracker.Expand = spy.new(function() end)

            QuestieTracker.OnMinimizeInInstancesChanged(false)

            assert.spy(QuestieTracker.Expand).was.called()
        end)

        it("should not expand the tracker when disabled if it never claimed ownership (manually minimized)", function()
            Questie.db.char.isTrackerExpanded = false -- already manually minimized
            _G.IsInInstance = function() return true end
            QuestieTracker.OnMinimizeInInstancesChanged(true) -- does not claim ownership

            QuestieTracker.Expand = spy.new(function() end)

            QuestieTracker.OnMinimizeInInstancesChanged(false)

            assert.spy(QuestieTracker.Expand).was.not_called()
        end)
    end)

    describe("OnHideInInstancesChanged", function()
        it("should hide the tracker when enabled while in an instance", function()
            _G.IsInInstance = function() return true end
            QuestieTracker.Hide = spy.new(function() end)

            QuestieTracker.OnHideInInstancesChanged(true)

            assert.spy(QuestieTracker.Hide).was.called()
        end)

        it("should not hide the tracker when enabled while not in an instance", function()
            _G.IsInInstance = function() return false end
            QuestieTracker.Hide = spy.new(function() end)

            QuestieTracker.OnHideInInstancesChanged(true)

            assert.spy(QuestieTracker.Hide).was.not_called()
        end)

        it("should show the tracker when disabled after it claimed ownership of the hide", function()
            _G.IsInInstance = function() return true end
            QuestieTracker.OnHideInInstancesChanged(true) -- claims ownership

            QuestieTracker.Show = spy.new(function() end)

            QuestieTracker.OnHideInInstancesChanged(false)

            assert.spy(QuestieTracker.Show).was.called()
        end)

        it("should not show the tracker when disabled if it never claimed ownership", function()
            QuestieTracker.Show = spy.new(function() end)

            QuestieTracker.OnHideInInstancesChanged(false)

            assert.spy(QuestieTracker.Show).was.not_called()
        end)
    end)

    describe("HandleCombatChanged", function()
        it("should collapse the tracker when entering combat with minimize enabled and expanded", function()
            Questie.db.profile.minimizeTrackerInCombat = true
            Questie.db.char.isTrackerExpanded = true
            _G.InCombatLockdown = function() return true end
            QuestieTracker.Collapse = spy.new(function() end)

            QuestieTracker.HandleCombatChanged()

            assert.spy(QuestieTracker.Collapse).was.called()
        end)

        it("should hide the tracker when entering combat with hide enabled", function()
            Questie.db.profile.hideTrackerInCombat = true
            _G.InCombatLockdown = function() return true end
            QuestieTracker.Hide = spy.new(function() end)

            QuestieTracker.HandleCombatChanged()

            assert.spy(QuestieTracker.Hide).was.called()
        end)

        it("should re-collapse when entering combat while already in an instance with minimize enabled", function()
            Questie.db.profile.minimizeTrackerInInstances = true
            _G.InCombatLockdown = function() return true end
            _G.IsInInstance = function() return true end
            QuestieTracker.Collapse = spy.new(function() end)

            QuestieTracker.HandleCombatChanged()

            assert.spy(QuestieTracker.Collapse).was.called()
        end)

        it("should expand the tracker when leaving combat after it was minimized due to combat", function()
            Questie.db.profile.minimizeTrackerInCombat = true
            Questie.db.char.isTrackerExpanded = true
            _G.InCombatLockdown = function() return true end
            QuestieTracker.HandleCombatChanged() -- entered combat, claims ownership

            _G.InCombatLockdown = function() return false end
            QuestieTracker.Expand = spy.new(function() end)

            QuestieTracker.HandleCombatChanged()

            assert.spy(QuestieTracker.Expand).was.called()
        end)

        it("should not expand when leaving combat while still in an instance that also wants it minimized", function()
            Questie.db.profile.minimizeTrackerInCombat = true
            Questie.db.profile.minimizeTrackerInInstances = true
            Questie.db.char.isTrackerExpanded = true
            _G.InCombatLockdown = function() return true end
            _G.IsInInstance = function() return true end
            QuestieTracker.HandleCombatChanged() -- entered combat, claims ownership

            _G.InCombatLockdown = function() return false end
            QuestieTracker.Expand = spy.new(function() end)

            QuestieTracker.HandleCombatChanged()

            assert.spy(QuestieTracker.Expand).was.not_called()
        end)

        it("should show the tracker when leaving combat after it was hidden due to combat", function()
            Questie.db.profile.hideTrackerInCombat = true
            _G.InCombatLockdown = function() return true end
            QuestieTracker.HandleCombatChanged() -- entered combat, claims ownership

            _G.InCombatLockdown = function() return false end
            QuestieTracker.Show = spy.new(function() end)

            QuestieTracker.HandleCombatChanged()

            assert.spy(QuestieTracker.Show).was.called()
        end)

        it("should not show when leaving combat while still in an instance that also wants it hidden", function()
            Questie.db.profile.hideTrackerInCombat = true
            Questie.db.profile.hideTrackerInInstances = true
            _G.InCombatLockdown = function() return true end
            _G.IsInInstance = function() return true end
            QuestieTracker.HandleCombatChanged() -- entered combat, claims ownership

            _G.InCombatLockdown = function() return false end
            QuestieTracker.Show = spy.new(function() end)

            QuestieTracker.HandleCombatChanged()

            assert.spy(QuestieTracker.Show).was.not_called()
        end)

        it("should queue an Update when leaving combat after minimize was active due to combat", function()
            Questie.db.profile.minimizeTrackerInCombat = true
            Questie.db.char.isTrackerExpanded = true
            _G.InCombatLockdown = function() return true end
            QuestieTracker.HandleCombatChanged()

            _G.InCombatLockdown = function() return false end
            QuestieCombatQueue.Queue = spy.new(function() end)

            QuestieTracker.HandleCombatChanged()

            assert.spy(QuestieCombatQueue.Queue).was.called()
        end)
    end)

    describe("OnMinimizeInCombatChanged", function()
        it("should collapse the tracker when enabled while in combat and expanded", function()
            Questie.db.char.isTrackerExpanded = true
            _G.InCombatLockdown = function() return true end
            QuestieTracker.Collapse = spy.new(function() end)

            QuestieTracker.OnMinimizeInCombatChanged(true)

            assert.spy(QuestieTracker.Collapse).was.called()
        end)

        it("should not collapse the tracker when enabled while not in combat", function()
            _G.InCombatLockdown = function() return false end
            QuestieTracker.Collapse = spy.new(function() end)

            QuestieTracker.OnMinimizeInCombatChanged(true)

            assert.spy(QuestieTracker.Collapse).was.not_called()
        end)

        it("should expand the tracker when disabled after it claimed ownership of the collapse", function()
            Questie.db.char.isTrackerExpanded = true
            _G.InCombatLockdown = function() return true end
            QuestieTracker.OnMinimizeInCombatChanged(true) -- claims ownership

            QuestieTracker.Expand = spy.new(function() end)

            QuestieTracker.OnMinimizeInCombatChanged(false)

            assert.spy(QuestieTracker.Expand).was.called()
        end)

        it("should not expand the tracker when disabled if it never claimed ownership (manually minimized)", function()
            Questie.db.char.isTrackerExpanded = false -- already manually minimized
            _G.InCombatLockdown = function() return true end
            QuestieTracker.OnMinimizeInCombatChanged(true) -- does not claim ownership, tracker was not expanded

            QuestieTracker.Expand = spy.new(function() end)

            QuestieTracker.OnMinimizeInCombatChanged(false)

            assert.spy(QuestieTracker.Expand).was.not_called()
        end)
    end)

    describe("OnHideInCombatChanged", function()
        it("should hide the tracker when enabled while in combat", function()
            _G.InCombatLockdown = function() return true end
            QuestieTracker.Hide = spy.new(function() end)

            QuestieTracker.OnHideInCombatChanged(true)

            assert.spy(QuestieTracker.Hide).was.called()
        end)

        it("should not hide the tracker when enabled while not in combat", function()
            _G.InCombatLockdown = function() return false end
            QuestieTracker.Hide = spy.new(function() end)

            QuestieTracker.OnHideInCombatChanged(true)

            assert.spy(QuestieTracker.Hide).was.not_called()
        end)

        it("should show the tracker when disabled after it claimed ownership of the hide", function()
            _G.InCombatLockdown = function() return true end
            QuestieTracker.OnHideInCombatChanged(true) -- claims ownership

            QuestieTracker.Show = spy.new(function() end)

            QuestieTracker.OnHideInCombatChanged(false)

            assert.spy(QuestieTracker.Show).was.called()
        end)

        it("should not show the tracker when disabled if it never claimed ownership", function()
            QuestieTracker.Show = spy.new(function() end)

            QuestieTracker.OnHideInCombatChanged(false)

            assert.spy(QuestieTracker.Show).was.not_called()
        end)

        it("should not clear instance-hidden state when disabling hide-in-combat while still hidden by an instance", function()
            Questie.db.profile.hideTrackerInInstances = true
            _G.IsInInstance = function() return true end
            QuestieTracker.HandleZoneChanged() -- legitimately hidden by the instance

            Questie.db.profile.hideTrackerInCombat = true
            _G.InCombatLockdown = function() return true end
            QuestieTracker.OnHideInCombatChanged(true) -- also hidden by combat now

            QuestieTracker.OnHideInCombatChanged(false) -- toggling combat-hide off mid-fight, still inside the instance

            -- The instance-hide should still be in effect: leaving the instance afterwards
            -- should still show the tracker, proving hiddenByInstance was not cleared above.
            _G.IsInInstance = function() return false end
            QuestieTracker.Show = spy.new(function() end)
            QuestieTracker.HandleZoneChanged()

            assert.spy(QuestieTracker.Show).was.called()
        end)
    end)
end)
