dofile("setupTests.lua")

_G.QuestieCompat = {}

describe("AutoQuesting", function()
    ---@type AutoQuesting
    local AutoQuesting

    before_each(function()
        Questie.db.profile.autoaccept = true
        Questie.db.profile.autoModifier = "disabled"
        _G.QuestieCompat.SelectAvailableQuest = spy.new(function() end)

        _G.AcceptQuest = spy.new(function() end)
        _G.print = function()  end -- TODO: Remove this line when print is removed from the module

        AutoQuesting = require("Modules/Auto/AutoQuesting")
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

    it("should accept available quest from gossip", function()
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
end)
