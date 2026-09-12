dofile("setupTests.lua")

_G.ERR_QUEST_ACCEPTED_S = "Quest accepted: %s"
_G.ERR_QUEST_COMPLETE_S = "Quest completed: %s"

describe("EventHandler", function()
    ---@type EventHandler
    local EventHandler
    ---@type QuestieTracker
    local QuestieTracker

    before_each(function()
        Questie.db.char = {
            isTrackerExpanded = true,
        }
        Questie.db.profile = {
            trackerEnabled = true,
        }

        QuestieTracker = QuestieLoader:ImportModule("QuestieTracker")
        QuestieTracker.Collapse = spy.new(function() end)
        QuestieTracker.Expand = spy.new(function() end)

        dofile("Modules/EventHandler/EventHandler.lua")
        EventHandler = QuestieLoader:ImportModule("EventHandler")
    end)

    describe("OnMinimizeInCombatChanged", function()
        it("should collapse the tracker when enabled while in combat and expanded", function()
            Questie.db.char.isTrackerExpanded = true
            _G.InCombatLockdown = function() return true end

            EventHandler.OnMinimizeInCombatChanged(true)

            assert.spy(QuestieTracker.Collapse).was.called()
        end)

        it("should not collapse the tracker when enabled while not in combat", function()
            _G.InCombatLockdown = function() return false end

            EventHandler.OnMinimizeInCombatChanged(true)

            assert.spy(QuestieTracker.Collapse).was.not_called()
        end)

        it("should expand the tracker when disabled after it claimed ownership of the collapse", function()
            Questie.db.char.isTrackerExpanded = true
            _G.InCombatLockdown = function() return true end
            EventHandler.OnMinimizeInCombatChanged(true) -- claims ownership

            EventHandler.OnMinimizeInCombatChanged(false)

            assert.spy(QuestieTracker.Expand).was.called()
        end)

        it("should not expand the tracker when disabled if it never claimed ownership (manually minimized)", function()
            Questie.db.char.isTrackerExpanded = false -- already manually minimized
            _G.InCombatLockdown = function() return true end
            EventHandler.OnMinimizeInCombatChanged(true) -- does not claim ownership, tracker was not expanded

            EventHandler.OnMinimizeInCombatChanged(false)

            assert.spy(QuestieTracker.Expand).was.not_called()
        end)
    end)
end)
