dofile("setupTests.lua")

describe("TrackerSuperTrack", function()
    ---@type TrackerSuperTrack
    local TrackerSuperTrack
    local TrackerUtils
    local QuestieQuest
    local QuestieTracker
    local superTrackedQuestId

    before_each(function()
        Questie.db.char.TrackerFocus = nil
        superTrackedQuestId = nil

        local QuestieCompat = QuestieLoader:ImportModule("QuestieCompat")
        QuestieCompat.GetSuperTrackedQuestID = function() return superTrackedQuestId end
        TrackerUtils = QuestieLoader:ImportModule("TrackerUtils")
        TrackerUtils.FocusQuest = spy.new(function() return true end)
        TrackerUtils.UnFocus = spy.new(function() end)
        QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")
        QuestieQuest.ToggleQuestNotes = spy.new(function() end)
        QuestieTracker = QuestieLoader:ImportModule("QuestieTracker")
        QuestieTracker.Update = spy.new(function() end)
        QuestieLoader:ImportModule("QuestieCombatQueue").Queue = function(_, callback) callback() end

        dofile("Modules/Tracker/TrackerSuperTrack.lua")
        TrackerSuperTrack = QuestieLoader:ImportModule("TrackerSuperTrack")
    end)

    describe("OnSuperTrackingChanged", function()
        it("should focus a quest super tracked by Blizzard", function()
            superTrackedQuestId = 123

            TrackerSuperTrack.OnSuperTrackingChanged()

            assert.spy(TrackerUtils.FocusQuest).was.called_with(TrackerUtils, 123)
            assert.spy(QuestieQuest.ToggleQuestNotes).was.called_with(false)
            assert.spy(QuestieTracker.Update).was.called()
        end)

        it("should only redraw the tracker when the super tracked quest is already focused", function()
            superTrackedQuestId = 123
            Questie.db.char.TrackerFocus = 123

            TrackerSuperTrack.OnSuperTrackingChanged()

            assert.spy(TrackerUtils.FocusQuest).was.not_called()
            assert.spy(QuestieQuest.ToggleQuestNotes).was.not_called()
            assert.spy(QuestieTracker.Update).was.called()
        end)

        it("should unfocus the focused quest when Blizzard super tracks a quest Questie can not focus", function()
            superTrackedQuestId = 123
            Questie.db.char.TrackerFocus = 99
            TrackerUtils.FocusQuest = spy.new(function() return false end)

            TrackerSuperTrack.OnSuperTrackingChanged()

            assert.spy(TrackerUtils.UnFocus).was.called()
            assert.spy(QuestieQuest.ToggleQuestNotes).was.called_with(true)
            assert.spy(QuestieTracker.Update).was.called()
        end)

        it("should redraw the tracker when Blizzard super tracks a quest Questie can not focus without a focus", function()
            superTrackedQuestId = 123
            TrackerUtils.FocusQuest = spy.new(function() return false end)

            TrackerSuperTrack.OnSuperTrackingChanged()

            assert.spy(TrackerUtils.UnFocus).was.not_called()
            assert.spy(QuestieTracker.Update).was.called()
        end)

        it("should unfocus the focused quest when Blizzard clears super tracking", function()
            Questie.db.char.TrackerFocus = 123

            TrackerSuperTrack.OnSuperTrackingChanged()

            assert.spy(TrackerUtils.UnFocus).was.called()
            assert.spy(QuestieQuest.ToggleQuestNotes).was.called_with(true)
            assert.spy(QuestieTracker.Update).was.called()
        end)

        it("should redraw the tracker when super tracking is cleared without a focus", function()
            TrackerSuperTrack.OnSuperTrackingChanged()

            assert.spy(TrackerUtils.UnFocus).was.not_called()
            assert.spy(QuestieTracker.Update).was.called()
        end)
    end)
end)
