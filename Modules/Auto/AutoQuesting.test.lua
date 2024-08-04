dofile("setupTests.lua")

_G.QuestieCompat = {}
_G.C_Timer = {
    After = function(_, callback)
        callback()
    end
}

describe("AutoQuesting", function()
    ---@type AutoQuesting
    local AutoQuesting

    before_each(function()
        Questie.db.profile.autoaccept = true
        Questie.db.profile.autoModifier = "disabled"
        _G.QuestieCompat.SelectAvailableQuest = spy.new(function() end)

        _G.AcceptQuest = spy.new(function() end)
        _G.SelectAvailableQuest = spy.new(function() end)
        _G.print = function()  end -- TODO: Remove this line when print is removed from the module

        AutoQuesting = require("Modules/Auto/AutoQuesting")
        AutoQuesting.private.disallowedNPCs = {
            accept = {}
        }
    end)

    it("should accept quest from quest detail", function()
        AutoQuesting.OnQuestDetail()

        assert.spy(_G.AcceptQuest).was.called()
    end)

    it("should not accept quest from quest detail when auto accept is disabled", function()
        Questie.db.profile.autoaccept = false

        AutoQuesting.OnQuestDetail()

        assert.spy(_G.AcceptQuest).was_not.called()
    end)

    it("should not accept quest from detail when auto modifier is held", function()
        Questie.db.profile.autoModifier = "shift"
        _G.IsShiftKeyDown = function() return true end

        AutoQuesting.OnQuestDetail()

        assert.spy(_G.AcceptQuest).was_not.called()
    end)

    it("should accept quests from quest greetings", function()
        _G.GetNumAvailableQuests = function() return 2 end

        AutoQuesting.OnQuestGreetings()

        assert.spy(_G.SelectAvailableQuest).was.called_with(1)
    end)

    it("should not accept quest from quest greetings when auto accept is disabled", function()
        _G.GetNumAvailableQuests = function() return 2 end
        Questie.db.profile.autoaccept = false

        AutoQuesting.OnQuestGreetings()

        assert.spy(_G.SelectAvailableQuest).was_not.called()
    end)

    it("should not accept quest from greetings when auto modifier is held", function()
        _G.GetNumAvailableQuests = function() return 2 end
        Questie.db.profile.autoModifier = "shift"
        _G.IsShiftKeyDown = function() return true end

        AutoQuesting.OnQuestGreetings()

        assert.spy(_G.SelectAvailableQuest).was_not.called()
    end)

    it("should not accept quest from details when coming from greetings and auto modifier was held", function()
        _G.GetNumAvailableQuests = function() return 2 end
        Questie.db.profile.autoModifier = "shift"
        _G.IsShiftKeyDown = function() return true end

        AutoQuesting.OnQuestGreetings()
        assert.spy(_G.SelectAvailableQuest).was_not.called()

        _G.IsShiftKeyDown = function() return false end
        AutoQuesting.OnQuestDetail()

        assert.spy(_G.AcceptQuest).was_not.called()
    end)

    it("should not select available quest from greetings when coming from details and auto modifier was held", function()
        _G.GetNumAvailableQuests = function() return 2 end
        Questie.db.profile.autoModifier = "shift"
        _G.IsShiftKeyDown = function() return true end

        AutoQuesting.OnQuestGreetings()
        assert.spy(_G.SelectAvailableQuest).was_not.called()

        _G.IsShiftKeyDown = function() return false end
        AutoQuesting.OnQuestDetail()

        assert.spy(_G.AcceptQuest).was_not.called()

        AutoQuesting.OnQuestGreetings()
        assert.spy(_G.SelectAvailableQuest).was_not.called()
    end)

    it("should select available quest from greetings when re-talking to an NPC after auto modifier was held", function()
        _G.GetNumAvailableQuests = function() return 2 end
        Questie.db.profile.autoModifier = "shift"
        _G.IsShiftKeyDown = function() return true end

        AutoQuesting.OnQuestGreetings()
        assert.spy(_G.SelectAvailableQuest).was_not.called()

        AutoQuesting.OnQuestFinished()

        _G.IsShiftKeyDown = function() return false end
        AutoQuesting.OnQuestGreetings()
        assert.spy(_G.SelectAvailableQuest).was.called_with(1)
    end)

    it("should accept available quest from gossip", function()
        _G.UnitGUID = function() return "0-0-0-0-0-123" end
        _G.QuestieCompat.GetAvailableQuests = function()
            return "Test Quest", 1, false, 1, false, false, false
        end

        AutoQuesting.OnGossipShow()

        assert.spy(_G.QuestieCompat.SelectAvailableQuest).was.called_with(1)
    end)

    it("should not accept available quest from gossip when auto accept is disabled", function()
        _G.QuestieCompat.GetAvailableQuests = function()
            return "Test Quest", 1, false, 1, false, false, false
        end
        Questie.db.profile.autoaccept = false

        AutoQuesting.OnGossipShow()

        assert.spy(_G.QuestieCompat.SelectAvailableQuest).was_not.called()
    end)

    it("should not accept available quest from gossip when auto modifier is held", function()
        _G.QuestieCompat.GetAvailableQuests = function()
            return "Test Quest", 1, false, 1, false, false, false
        end
        Questie.db.profile.autoModifier = "shift"
        _G.IsShiftKeyDown = function() return true end

        AutoQuesting.OnGossipShow()

        assert.spy(_G.QuestieCompat.SelectAvailableQuest).was_not.called()
    end)

    it("should not accept available quest from gossip when coming from progress and auto modifier was held", function()
        _G.QuestieCompat.GetAvailableQuests = function()
            return "Test Quest", 1, false, 1, false, false, false
        end
        Questie.db.profile.autoModifier = "shift"
        _G.IsShiftKeyDown = function() return true end

        AutoQuesting.OnGossipShow()
        assert.spy(_G.QuestieCompat.SelectAvailableQuest).was_not.called()

        _G.IsShiftKeyDown = function() return false end
        AutoQuesting.OnQuestProgress()

        AutoQuesting.OnGossipShow()
        assert.spy(_G.QuestieCompat.SelectAvailableQuest).was_not.called()
    end)

    it("should not accept available quest from gossip when NPC is not allowed to accept quests from", function()
        _G.UnitGUID = function() return "0-0-0-0-0-123" end
        AutoQuesting.private.disallowedNPCs.accept[123] = true
        _G.QuestieCompat.GetAvailableQuests = function()
            return "Test Quest", 1, false, 1, false, false, false
        end

        AutoQuesting.OnGossipShow()

        assert.spy(_G.QuestieCompat.SelectAvailableQuest).was_not.called()
    end)
end)
