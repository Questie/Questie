dofile("setupTests.lua")

describe("QuestiePlayer", function()
    ---@type QuestiePlayer
    local QuestiePlayer

    before_each(function()
        QuestiePlayer = require("Modules.QuestiePlayer")
    end)

    describe("GetPartyMemberByName", function()
        it("should return nil if the player is not in a party and not in a raid", function()
            _G.UnitInParty = function() return false end
            _G.UnitInRaid = function() return false end

            local player = QuestiePlayer:GetPartyMemberByName("playerName")

            assert.is_nil(player)
        end)

        it("should return party member for same realm", function()
            _G.UnitInParty = function() return true end
            _G.UnitInRaid = function() return false end
            _G.UnitName = function() return "Testi" end
            _G.UnitClass = function() return nil, "PALADIN" end
            _G.GetClassColor = function() return 0.96, 0.55, 0.73, "fff58cba" end

            local player = QuestiePlayer:GetPartyMemberByName("Testi")

            assert.is_not_nil(player)
            assert.are.same({
                name = "Testi",
                class = "PALADIN",
                r = 0.96,
                g = 0.55,
                b = 0.73,
                colorHex = "fff58cba"
            }, player)
        end)

        it("should return party member for cross-realm", function()
            _G.UnitInParty = function() return true end
            _G.UnitInRaid = function() return false end
            _G.UnitName = function() return "Testi", "FancyRealm" end
            _G.UnitClass = function() return nil, "PALADIN" end
            _G.GetClassColor = function() return 0.96, 0.55, 0.73, "fff58cba" end

            local player = QuestiePlayer:GetPartyMemberByName("Testi-FancyRealm")

            assert.is_not_nil(player)
            assert.are.same({
                name = "Testi-FancyRealm",
                class = "PALADIN",
                r = 0.96,
                g = 0.55,
                b = 0.73,
                colorHex = "fff58cba"
            }, player)
        end)

        it("should return nil if player name is not found", function()
            _G.UnitInParty = function() return true end
            _G.UnitInRaid = function() return false end
            _G.UnitName = function() return "Questie" end
            _G.UnitClass = function() return nil, "PALADIN" end

            local player = QuestiePlayer:GetPartyMemberByName("notQuestie")

            assert.is_nil(player)
        end)
    end)
end)
