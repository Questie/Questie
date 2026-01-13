dofile("setupTests.lua")

describe("Comms", function()
    ---@type AvailableQuests
    local AvailableQuests

    ---@type Comms
    local Comms

    before_each(function()
        AvailableQuests = require("Modules.Quest.AvailableQuests.AvailableQuests")
        AvailableQuests.RemoveQuestsForToday = spy.new(function() end)

        Comms = require("Modules.Network.Comms")
    end)

    describe("OnCommReceived", function()
        it("should handle HideDailyQuests event", function()
            local npcId = 1234
            local questIds = {5678, 91011}

            ---@type CommEvent
            local event = {
                eventName = "HideDailyQuests",
                data = {
                    npcId = npcId,
                    questIds = questIds
                }
            }
            Questie.Deserialize = function() return event end

            Comms.OnCommReceived("Questie", "eventAsSerializedString", "GUILD", "SomeSender")

            assert.spy(AvailableQuests.RemoveQuestsForToday).was.called_with(npcId, questIds)
        end)
    end)
end)
