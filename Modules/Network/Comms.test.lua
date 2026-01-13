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
            Questie.Deserialize = function() return true, event end

            Comms.OnCommReceived("Questie", "eventAsSerializedString", "GUILD", "SomeSender")

            assert.spy(AvailableQuests.RemoveQuestsForToday).was.called_with(npcId, questIds)
        end)

        it("should reject unknown prefixes", function()
            Questie.Deserialize = spy.new(function() end)

            Comms.OnCommReceived("Unknown", "eventAsSerializedString", "GUILD", "SomeSender")

            assert.spy(Questie.Deserialize).was.not_called()
            assert.spy(AvailableQuests.RemoveQuestsForToday).was.not_called()
        end)

        it("should reject own HideDailyQuests events", function()
            Questie.Deserialize = spy.new(function() end)

            Comms.OnCommReceived("Questie", "eventAsSerializedString", "GUILD", UnitName("player"))

            assert.spy(Questie.Deserialize).was.not_called()
            assert.spy(AvailableQuests.RemoveQuestsForToday).was.not_called()
        end)

        it("should reject own HideDailyQuests events when sender is in realm format", function()
            Questie.Deserialize = spy.new(function() end)

            Comms.OnCommReceived("Questie", "eventAsSerializedString", "GUILD", UnitName("player") .. "-" .. GetRealmName())

            assert.spy(Questie.Deserialize).was.not_called()
            assert.spy(AvailableQuests.RemoveQuestsForToday).was.not_called()
        end)

        it("should reject malformed HideDailyQuests events", function()
            Questie.Deserialize = function() return false, nil end

            Comms.OnCommReceived("Questie", "eventAsSerializedString", "GUILD", "SomeSender")

            assert.spy(AvailableQuests.RemoveQuestsForToday).was.not_called()
        end)

        it("should reject HideDailyQuests events without data", function()
            local event = {
                eventName = "HideDailyQuests"
            }
            Questie.Deserialize = function() return true, event end

            Comms.OnCommReceived("Questie", "eventAsSerializedString", "GUILD", "SomeSender")

            assert.spy(AvailableQuests.RemoveQuestsForToday).was.not_called()
        end)

        it("should reject HideDailyQuests events without npcId", function()
            local questIds = {5678, 91011}

            ---@type CommEvent
            local event = {
                eventName = "HideDailyQuests",
                data = {
                    questIds = questIds
                }
            }
            Questie.Deserialize = function() return true, event end

            Comms.OnCommReceived("Questie", "eventAsSerializedString", "GUILD", "SomeSender")

            assert.spy(AvailableQuests.RemoveQuestsForToday).was.not_called()
        end)

        it("should reject HideDailyQuests events without questIds", function()
            local npcId = 1234

            ---@type CommEvent
            local event = {
                eventName = "HideDailyQuests",
                data = {
                    npcId = npcId
                }
            }
            Questie.Deserialize = function() return true, event end

            Comms.OnCommReceived("Questie", "eventAsSerializedString", "GUILD", "SomeSender")

            assert.spy(AvailableQuests.RemoveQuestsForToday).was.not_called()
        end)

        it("should reject HideDailyQuests events when questIds is not a table", function()
            local npcId = 1234

            ---@type CommEvent
            local event = {
                eventName = "HideDailyQuests",
                data = {
                    npcId = npcId,
                    questIds = "notATable"
                }
            }
            Questie.Deserialize = function() return true, event end

            Comms.OnCommReceived("Questie", "eventAsSerializedString", "GUILD", "SomeSender")

            assert.spy(AvailableQuests.RemoveQuestsForToday).was.not_called()
        end)
    end)

    describe("BroadcastUnavailableDailyQuests", function()
        it("should broadcast to guild", function()
            _G.IsInGuild = function() return true end
            _G.IsInRaid = function() return false end
            _G.IsInGroup = function() return false end
            Questie.SendCommMessage = spy.new(function() end)
            Questie.Serialize = function() return "eventAsSerializedString" end

            Comms.BroadcastUnavailableDailyQuests(1234, {5678, 91011})

            assert.spy(Questie.SendCommMessage).was.called_with(Questie, "Questie", "eventAsSerializedString", "GUILD")
        end)

        it("should broadcast only to party when in a party and not in a guild", function()
            _G.IsInGuild = function() return false end
            _G.IsInRaid = function() return false end
            _G.IsInGroup = function() return true end
            Questie.SendCommMessage = spy.new(function() end)
            Questie.Serialize = function() return "eventAsSerializedString" end

            Comms.BroadcastUnavailableDailyQuests(1234, {5678, 91011})

            assert.spy(Questie.SendCommMessage).was.called_with(Questie, "Questie", "eventAsSerializedString", "PARTY")
        end)

        it("should broadcast only to raid when in a raid and not in a guild", function()
            _G.IsInGuild = function() return false end
            _G.IsInRaid = function() return true end
            _G.IsInGroup = function() return false end
            Questie.SendCommMessage = spy.new(function() end)
            Questie.Serialize = function() return "eventAsSerializedString" end

            Comms.BroadcastUnavailableDailyQuests(1234, {5678, 91011})

            assert.spy(Questie.SendCommMessage).was.called_with(Questie, "Questie", "eventAsSerializedString", "RAID")
        end)

        it("should broadcast to guild and raid when in a raid", function()
            _G.IsInGuild = function() return true end
            _G.IsInRaid = function() return true end
            _G.IsInGroup = function() return false end
            Questie.SendCommMessage = spy.new(function() end)
            Questie.Serialize = function() return "eventAsSerializedString" end

            Comms.BroadcastUnavailableDailyQuests(1234, {5678, 91011})

            assert.spy(Questie.SendCommMessage).was.called_with(Questie, "Questie", "eventAsSerializedString", "GUILD")
            assert.spy(Questie.SendCommMessage).was.called_with(Questie, "Questie", "eventAsSerializedString", "RAID")
        end)

        it("should broadcast to guild and party when in a party", function()
            _G.IsInGuild = function() return true end
            _G.IsInRaid = function() return false end
            _G.IsInGroup = function() return true end
            Questie.SendCommMessage = spy.new(function() end)
            Questie.Serialize = function() return "eventAsSerializedString" end

            Comms.BroadcastUnavailableDailyQuests(1234, {5678, 91011})

            assert.spy(Questie.SendCommMessage).was.called_with(Questie, "Questie", "eventAsSerializedString", "GUILD")
            assert.spy(Questie.SendCommMessage).was.called_with(Questie, "Questie", "eventAsSerializedString", "PARTY")
        end)

        it("should not broadcast when not in a guild, raid or party", function()
            _G.IsInGuild = function() return false end
            _G.IsInRaid = function() return false end
            _G.IsInGroup = function() return false end
            Questie.SendCommMessage = spy.new(function() end)
            Questie.Serialize = function() return "eventAsSerializedString" end

            Comms.BroadcastUnavailableDailyQuests(1234, {5678, 91011})

            assert.spy(Questie.SendCommMessage).was.not_called()
        end)
    end)
end)
