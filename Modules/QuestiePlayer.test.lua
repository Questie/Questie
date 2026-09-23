dofile("setupTests.lua")

describe("QuestiePlayer", function()
    ---@type QuestiePlayer
    local QuestiePlayer

    before_each(function()
        dofile("Modules/QuestiePlayer.lua")
        QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
    end)

    describe("HasRequiredRace", function()
        local globalNames = {"UnitLevel", "UnitRace", "UnitClass", "UnitFactionGroup"}
        local savedGlobals
        local originalForever
        local originalFaction
        local originalLevel

        before_each(function()
            savedGlobals = {}
            for _, name in ipairs(globalNames) do
                savedGlobals[name] = _G[name]
            end
            originalForever = Questie.IsForever
            originalFaction = QuestiePlayer.faction
            originalLevel = QuestiePlayer.private.playerLevel
            Questie.IsForever = true
            _G.UnitLevel = function() return 1 end
            _G.UnitRace = function() return "High Order Skyborne", "Skyborne", 95 end
            _G.UnitClass = function() return "Mage", "MAGE", 8 end
            _G.UnitFactionGroup = function() return "Alliance" end
        end)

        after_each(function()
            for _, name in ipairs(globalNames) do
                _G[name] = savedGlobals[name]
            end
            Questie.IsForever = originalForever
            QuestiePlayer.faction = originalFaction
            QuestiePlayer.private.playerLevel = originalLevel
        end)

        it("uses the High Order Skyborne bit in single and mixed masks", function()
            QuestiePlayer:Initialize()

            assert.is_true(QuestiePlayer.HasRequiredRace(4294967296))
            assert.is_true(QuestiePlayer.HasRequiredRace(4294967297))
            assert.is_false(QuestiePlayer.HasRequiredRace(8589934592))
            assert.is_true(QuestiePlayer.HasRequiredRace(nil))
            assert.is_true(QuestiePlayer.HasRequiredRace(0))
        end)

        it("allows Alliance-wide restrictions without granting Human-only quests to Skyborne", function()
            QuestiePlayer:Initialize()

            assert.is_true(QuestiePlayer.HasRequiredRace(77))
            assert.is_false(QuestiePlayer.HasRequiredRace(178))
            assert.is_false(QuestiePlayer.HasRequiredRace(1))
            assert.is_false(QuestiePlayer.HasRequiredRace(5))
        end)

        it("uses the Windshaper bit and only the Horde-wide faction exception", function()
            _G.UnitRace = function() return "Windshaper Skyborne", "Skyborne", 96 end
            _G.UnitFactionGroup = function() return "Horde" end
            QuestiePlayer:Initialize()

            assert.is_true(QuestiePlayer.HasRequiredRace(8589934592))
            assert.is_true(QuestiePlayer.HasRequiredRace(8589934594))
            assert.is_false(QuestiePlayer.HasRequiredRace(4294967296))
            assert.is_true(QuestiePlayer.HasRequiredRace(178))
            assert.is_false(QuestiePlayer.HasRequiredRace(77))
            assert.is_false(QuestiePlayer.HasRequiredRace(2))
            assert.is_true(QuestiePlayer.HasRequiredRace(nil))
            assert.is_true(QuestiePlayer.HasRequiredRace(0))
        end)

        local ordinaryClients = {
            {name = "Classic", isForever = false},
            {name = "Forever", isForever = true},
        }
        for _, client in ipairs(ordinaryClients) do
            it("preserves Human race restrictions on " .. client.name, function()
                Questie.IsForever = client.isForever
                _G.UnitRace = function() return "Human", "Human", 1 end
                QuestiePlayer:Initialize()

                assert.is_true(QuestiePlayer.HasRequiredRace(1))
                assert.is_true(QuestiePlayer.HasRequiredRace(77))
                assert.is_false(QuestiePlayer.HasRequiredRace(178))
                assert.is_false(QuestiePlayer.HasRequiredRace(4294967296))
            end)
        end
    end)

    describe("GetCurrentZoneId", function()
        ---@type ZoneDB
        local ZoneDB

        before_each(function()
            ZoneDB = QuestieLoader:ImportModule("ZoneDB")
            ZoneDB.GetAreaIdByUiMapId = function(_, uiMapId)
                return ({[1426] = 1, [1415] = 10074})[uiMapId]
            end
            ZoneDB.GetAreaIdByName = function(_, name)
                if name == "Dun Morogh" then return 1 end
            end
            _G.GetRealZoneText = function() return "Dun Morogh" end
        end)

        it("should return the zone of the players map", function()
            _G.C_Map = {GetBestMapForUnit = function() return 1426 end, GetMapInfo = function() return {mapType = Enum.UIMapType.Zone} end}

            assert.is_equal(1, QuestiePlayer:GetCurrentZoneId())
        end)

        it("should resolve a continent map to the zone named by the zone text", function()
            _G.C_Map = {GetBestMapForUnit = function() return 1415 end, GetMapInfo = function() return {mapType = Enum.UIMapType.Continent} end}

            assert.is_equal(1, QuestiePlayer:GetCurrentZoneId())
        end)

        it("should keep the continent AreaId when the zone text is unknown", function()
            _G.C_Map = {GetBestMapForUnit = function() return 1415 end, GetMapInfo = function() return {mapType = Enum.UIMapType.Continent} end}
            _G.GetRealZoneText = function() return "Unknown" end

            assert.is_equal(10074, QuestiePlayer:GetCurrentZoneId())
        end)
    end)

    describe("GetPartyMemberByName", function()
        it("should return nil if the player is not in a party and not in a raid", function()
            _G.UnitInParty = function() return false end
            _G.UnitInRaid = function() return false end

            local player = QuestiePlayer:GetPartyMemberByName("playerName")

            assert.is_nil(player)
        end)

        it("should return party member for same realm", function()
            _G.UnitInParty = function(name) return name == "Testi" end
            _G.UnitInRaid = function() return false end
            _G.UnitClass = function(name) if name == "Testi" then return nil, "PALADIN" end end
            _G.GetClassColor = function() return 0.96, 0.55, 0.73, "fff58cba" end

            local player = QuestiePlayer:GetPartyMemberByName("Testi")

            assert.is_not_nil(player)
            assert.are_same({
                name = "Testi",
                class = "PALADIN",
                r = 0.96,
                g = 0.55,
                b = 0.73,
                colorHex = "fff58cba"
            }, player)
        end)

        it("should return party member for cross-realm", function()
            _G.UnitInParty = function(name) return name == "Testi-FancyRealm" end
            _G.UnitInRaid = function() return false end
            _G.UnitClass = function(name) if name == "Testi-FancyRealm" then return nil, "PALADIN" end end
            _G.GetClassColor = function() return 0.96, 0.55, 0.73, "fff58cba" end

            local player = QuestiePlayer:GetPartyMemberByName("Testi-FancyRealm")

            assert.is_not_nil(player)
            assert.are_same({
                name = "Testi-FancyRealm",
                class = "PALADIN",
                r = 0.96,
                g = 0.55,
                b = 0.73,
                colorHex = "fff58cba"
            }, player)
        end)

        it("should return nil if player name is not found", function()
            _G.UnitInParty = function(name) return name == "Questie" end
            _G.UnitInRaid = function() return false end
            _G.UnitClass = function() return nil, "PALADIN" end

            local player = QuestiePlayer:GetPartyMemberByName("notQuestie")

            assert.is_nil(player)
        end)

        it("should return nil if the class can not be resolved", function()
            _G.UnitInParty = function() return true end
            _G.UnitInRaid = function() return false end
            _G.UnitClass = function() return nil, nil end

            local player = QuestiePlayer:GetPartyMemberByName("Testi")

            assert.is_nil(player)
        end)
    end)
end)
