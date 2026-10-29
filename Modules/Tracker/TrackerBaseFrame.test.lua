dofile("setupTests.lua")

---@type QuestieTracker
local QuestieTracker = QuestieLoader:ImportModule("QuestieTracker")
QuestieTracker.Enable = spy.new(function() end)
QuestieTracker.Disable = spy.new(function() end)

dofile("Modules/Tracker/TrackerBaseFrame.lua")
local TrackerBaseFrame = QuestieLoader:ImportModule("TrackerBaseFrame")

describe("TrackerBaseFrame", function()
    describe("OnProfileChange", function()
        before_each(function()
            QuestieTracker.Enable:clear()
            QuestieTracker.Disable:clear()
        end)

        it("should not error when the tracker was never created and stays disabled", function()
            Questie.db.profile.trackerEnabled = false
            Questie.db.profile.TrackerLocation = {"TOPLEFT", nil, "TOPLEFT", 0, 0}

            assert.has_no.errors(function()
                TrackerBaseFrame:OnProfileChange()
            end)
            assert.spy(QuestieTracker.Enable).was_not.called()
            assert.spy(QuestieTracker.Disable).was_not.called()
        end)

        it("should enable the tracker when it was never created and is now enabled", function()
            Questie.db.profile.trackerEnabled = true

            TrackerBaseFrame:OnProfileChange()

            assert.spy(QuestieTracker.Enable).was.called()
        end)
    end)
end)
