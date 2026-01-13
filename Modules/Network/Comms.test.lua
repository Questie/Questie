dofile("setupTests.lua")

describe("Comms", function()
    ---@type AvailableQuests
    local AvailableQuests

    ---@type Comms
    local Comms

    before_each(function()
        AvailableQuests = require("Modules/Quest/AvailableQuests/AvailableQuests")
        AvailableQuests.RemoveQuestsForToday = spy.new(function() end)

        Comms = require("Modules/Network/Comms")
    end)

    describe("OnHideDailyQuests", function()
        it("should hide daily quests", function()
            local npcId = 1234
            local questIds = {5678, 91011}

            Comms.OnHideDailyQuests(npcId, questIds)

            assert.spy(AvailableQuests.RemoveQuestsForToday).was.called_with(npcId, questIds)
        end)
    end)
end)
