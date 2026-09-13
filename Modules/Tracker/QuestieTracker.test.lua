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

    describe("UpdateVoiceOverFrame", function()
        local originalVoiceOver
        local originalVoiceOverFrame
        local originalGetScreenWidth
        local originalStarted
        local stubs

        before_each(function()
            originalVoiceOver = _G.VoiceOver
            originalVoiceOverFrame = _G.VoiceOverFrame
            originalGetScreenWidth = _G.GetScreenWidth
            originalStarted = QuestieTracker.started
            _G.VoiceOverFrame = nil
            _G.GetScreenWidth = function() return 1920 end
            QuestieTracker.started = false
            dofile("Modules/Tracker/QuestieTracker.lua")

            local baseFrame = {GetCenter = function() return 100 end}
            stubs = {
                stub(QuestieTracker, "SetupKeybinding", function() end),
                stub(QuestieTracker, "HookBaseTracker", function() end),
                stub(TrackerUtils, "IsVoiceOverLoaded", function() return VoiceOverFrame ~= nil end),
                stub(TrackerUtils, "HasQuest", function() return true end),
                stub(QuestieLoader:ImportModule("TrackerBaseFrame"), "Initialize", function() return baseFrame end),
                stub(QuestieLoader:ImportModule("TrackerHeaderFrame"), "Initialize", function() return {} end),
                stub(QuestieLoader:ImportModule("TrackerQuestFrame"), "Initialize", function() return {} end),
                stub(QuestieLoader:ImportModule("TrackerLinePool"), "Initialize", function() end),
                stub(QuestieLoader:ImportModule("TrackerFadeTicker"), "Initialize", function() end),
                stub(QuestieLoader:ImportModule("AutoCompleteFrame"), "Initialize", function() end),
                stub(QuestieLoader:ImportModule("QuestieCombatQueue"), "Queue", function() end),
            }
            assert.is_true(coroutine.resume(coroutine.create(QuestieTracker.Initialize)))
        end)

        after_each(function()
            for _, mockedFunction in ipairs(stubs) do
                mockedFunction:revert()
            end
            QuestieTracker.started = originalStarted
            _G.VoiceOver = originalVoiceOver
            _G.VoiceOverFrame = originalVoiceOverFrame
            _G.GetScreenWidth = originalGetScreenWidth
        end)

        it("should restore the original position when VoiceOver loads after Questie", function()
            local position = {"CENTER", UIParent, "CENTER", 200, 100}
            _G.VoiceOverFrame = {
                GetPoint = function() return unpack(position) end,
                SetPoint = function(_, ...) position = {...} end,
                ClearAllPoints = function() end,
                SetClampedToScreen = function() end,
                SetFrameStrata = function() end,
                SetFrameLevel = function() end,
                SetWidth = function() end,
                SetHeight = function() end,
                IsShown = function() return false end,
            }
            _G.VoiceOver = {
                Addon = {db = {profile = {SoundQueueUI = {LockFrame = false}}}},
                SoundQueueUI = {RefreshConfig = function() end, UpdateSoundQueueDisplay = function() end},
            }
            Questie.db.profile.stickyVoiceOverFrame = true

            QuestieTracker:UpdateVoiceOverFrame()
            assert.are_equal("TOPLEFT", position[1])
            assert.is_true(VoiceOver.Addon.db.profile.SoundQueueUI.LockFrame)

            QuestieTracker:UpdateVoiceOverFrame()
            QuestieTracker:ResetVoiceOverFrame()

            assert.are_same({"CENTER", UIParent, "CENTER", 200, 100}, position)
            assert.is_false(VoiceOver.Addon.db.profile.SoundQueueUI.LockFrame)
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
