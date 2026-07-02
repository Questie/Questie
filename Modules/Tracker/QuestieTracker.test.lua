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
    ---@type CommsVisibility
    local CommsVisibility
    ---@type QuestieCombatQueue
    local QuestieCombatQueue
    ---@type QuestiePlayer
    local QuestiePlayer
    ---@type QuestieDB
    local QuestieDB
    ---@type TrackerBaseFrame
    local TrackerBaseFrame
    local trackerBaseFrame
    local trackerHeaderFrame

    before_each(function()
        Questie.db.char = {
            collapsedQuests = {},
            collapsedZones = {},
            AutoUntrackedQuests = {},
            TrackedQuests = {},
        }
        Questie.db.profile = {
            trackerEnabled = true,
        }
        Questie.Debug = function() end
        _G.RemoveQuestWatch = spy.new(function() end)

        TrackerUtils = QuestieLoader:ImportModule("TrackerUtils")
        TrackerUtils.UnFocus = spy.new(function() end)
        QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")
        QuestieQuest.ToggleNotes = spy.new(function() end)
        CommsVisibility = QuestieLoader:ImportModule("CommsVisibility")
        CommsVisibility.ScheduleSnapshot = spy.new(function() end)
        QuestieCombatQueue = QuestieLoader:ImportModule("QuestieCombatQueue")
        QuestieCombatQueue.Queue = spy.new(function() end)
        QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
        QuestiePlayer.currentQuestlog = {}
        QuestieDB = QuestieLoader:ImportModule("QuestieDB")
        QuestieDB.GetQuest = spy.new(function() return {zoneOrSort = 12} end)

        dofile("Modules/Tracker/QuestieTracker.lua")
        QuestieTracker = QuestieLoader:ImportModule("QuestieTracker")
        QuestieTracker.started = nil
        QuestieTracker.alreadyHooked = nil

        trackerBaseFrame = {
            SetSize = spy.new(function() end),
            Hide = spy.new(function() end),
            IsShown = function() return false end,
        }
        trackerHeaderFrame = {
            trackedQuests = {
                SetMode = spy.new(function() end),
            },
        }

        TrackerBaseFrame = QuestieLoader:ImportModule("TrackerBaseFrame")
        TrackerBaseFrame.Initialize = spy.new(function() return trackerBaseFrame end)
        TrackerBaseFrame.SetSafePoint = spy.new(function() end)
        QuestieLoader:ImportModule("TrackerHeaderFrame").Initialize = spy.new(function() return trackerHeaderFrame end)
        QuestieLoader:ImportModule("TrackerQuestFrame").Initialize = spy.new(function() return {} end)
        QuestieLoader:ImportModule("TrackerLinePool").Initialize = spy.new(function() end)
        QuestieLoader:ImportModule("TrackerFadeTicker").Initialize = spy.new(function() end)
        QuestieLoader:ImportModule("AutoCompleteFrame").Initialize = spy.new(function() end)
        QuestieTracker.HookBaseTracker = spy.new(function() end)
        QuestieTracker.Update = spy.new(function() end)

        QuestieTracker.Initialize()
        QuestieCombatQueue.Queue = spy.new(function(_, callback) callback() end)
    end)

    describe("tracking visibility sync", function()
        it("schedules a visibility snapshot after resetting tracker location", function()
            Questie.db.char.AutoUntrackedQuests[RIVERPAW_GNOLL_BOUNTY_ID] = true

            QuestieTracker:ResetLocation()

            assert.are_same({}, Questie.db.char.AutoUntrackedQuests)
            assert.spy(CommsVisibility.ScheduleSnapshot).was.called_with(CommsVisibility, "RESET_TRACKER_LOCATION")
            assert.spy(trackerHeaderFrame.trackedQuests.SetMode).was.called_with(trackerHeaderFrame.trackedQuests, 1)
            assert.spy(trackerBaseFrame.SetSize).was.called_with(trackerBaseFrame, 25, 25)
            assert.spy(TrackerBaseFrame.SetSafePoint).was.called_with(TrackerBaseFrame)
        end)

        it("schedules a visibility snapshot after untracking a quest", function()
            Questie.db.profile.autoTrackQuests = true

            QuestieTracker:UntrackQuestId(RIVERPAW_GNOLL_BOUNTY_ID)

            assert.is_true(Questie.db.char.AutoUntrackedQuests[RIVERPAW_GNOLL_BOUNTY_ID])
            assert.spy(CommsVisibility.ScheduleSnapshot).was.called_with(CommsVisibility, "UNTRACK_QUEST")
        end)

        it("schedules a visibility snapshot after the tracker watch state changes", function()
            Questie.db.profile.trackerEnabled = true
            Questie.db.profile.autoTrackQuests = true
            Questie.db.char.AutoUntrackedQuests[RIVERPAW_GNOLL_BOUNTY_ID] = true
            QuestiePlayer.currentQuestlog[RIVERPAW_GNOLL_BOUNTY_ID] = true
            _G.GetQuestLogTitle = function()
                return nil, nil, nil, nil, nil, nil, nil, RIVERPAW_GNOLL_BOUNTY_ID
            end

            QuestieTracker:AQW_Insert(1)

            assert.is_nil(Questie.db.char.AutoUntrackedQuests[RIVERPAW_GNOLL_BOUNTY_ID])
            assert.spy(CommsVisibility.ScheduleSnapshot).was.called_with(CommsVisibility, "TRACK_QUEST")
        end)
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
end)
