dofile("setupTests.lua")

_G.QuestieCompat = {}

describe("AutoQuesting", function()
    ---@type AutoQuesting
    local AutoQuesting

    before_each(function()
        Questie.db.profile.autoaccept = true
        _G.QuestieCompat.SelectAvailableQuest = spy.new(function() end)
        AutoQuesting = require("Modules/Auto/AutoQuesting")
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
