dofile("setupTests.lua")

describe("QuestiePlayer", function()
    ---@type QuestiePlayer
    local QuestiePlayer

    before_each(function()
        dofile("Modules/QuestiePlayer.lua")
        QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
    end)

    describe("race requirements", function()
        -- Independent test values; the provider's encoding inventory is tested in QuestieDB.
        local RACE_ID = {HUMAN = 1, SKYBORNE_ALLIANCE = 95, SKYBORNE_HORDE = 96}
        local RACE_MASK = {HUMAN = 1, ORC = 2, SKYBORNE_ALLIANCE = 4294967296, SKYBORNE_HORDE = 8589934592}
        local globalNames = {"LibQuestieDB", "UnitLevel", "UnitRace", "UnitClass", "UnitFactionGroup"}
        local savedGlobals
        local originalFaction
        local originalLevel
        local raceId

        before_each(function()
            savedGlobals = {}
            for _, name in ipairs(globalNames) do
                savedGlobals[name] = _G[name]
            end
            originalFaction = QuestiePlayer.faction
            originalLevel = QuestiePlayer.private.playerLevel
            raceId = RACE_ID.HUMAN
            _G.LibQuestieDB = {Enum = {raceMaskById = {
                [RACE_ID.HUMAN] = RACE_MASK.HUMAN,
                [RACE_ID.SKYBORNE_ALLIANCE] = RACE_MASK.SKYBORNE_ALLIANCE,
                [RACE_ID.SKYBORNE_HORDE] = RACE_MASK.SKYBORNE_HORDE,
            }}}
            _G.UnitLevel = function() return 1 end
            _G.UnitRace = function() return "Test Race", "TestRace", raceId end
            _G.UnitClass = function() return "Mage", "MAGE", 8 end
            _G.UnitFactionGroup = function() return "Alliance" end
        end)

        after_each(function()
            for _, name in ipairs(globalNames) do
                _G[name] = savedGlobals[name]
            end
            QuestiePlayer.faction = originalFaction
            QuestiePlayer.private.playerLevel = originalLevel
        end)

        describe("Initialize", function()
            it("uses the provider mapping instead of assuming an encoding", function()
                -- Deliberately remap a known ID so a hardcoded mask cannot pass this test.
                LibQuestieDB.Enum.raceMaskById[RACE_ID.HUMAN] = RACE_MASK.ORC

            assert.is_true(QuestiePlayer.HasRequiredRace(4294967296))
            assert.is_true(QuestiePlayer.HasRequiredRace(4294967297))
            assert.is_false(QuestiePlayer.HasRequiredRace(8589934592))
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

                assert.is_true(QuestiePlayer.HasRequiredRace(RACE_MASK.ORC))
                assert.is_false(QuestiePlayer.HasRequiredRace(RACE_MASK.HUMAN))
            end)

            it("rejects a race ID missing from the provider mapping", function()
                LibQuestieDB.Enum.raceMaskById[RACE_ID.HUMAN] = nil

                assert.has_error(function() QuestiePlayer:Initialize() end,
                    "QuestieDB has no race mask for race ID 1. Update QuestieDB and reload.")
            end)
        end)

        describe("HasRequiredRace", function()
            it("allows unrestricted masks", function()
                QuestiePlayer:Initialize()

                assert.is_true(QuestiePlayer.HasRequiredRace(nil))
                assert.is_true(QuestiePlayer.HasRequiredRace(0))
            end)

            it("matches the player's bit and rejects other races", function()
                QuestiePlayer:Initialize()

                assert.is_true(QuestiePlayer.HasRequiredRace(RACE_MASK.HUMAN))
                assert.is_false(QuestiePlayer.HasRequiredRace(RACE_MASK.ORC))
            end)

            it("matches a mixed mask only when it contains the player's bit", function()
                QuestiePlayer:Initialize()

                assert.is_true(QuestiePlayer.HasRequiredRace(RACE_MASK.HUMAN + RACE_MASK.ORC))
                assert.is_false(QuestiePlayer.HasRequiredRace(RACE_MASK.ORC + RACE_MASK.SKYBORNE_ALLIANCE))
            end)

            it("preserves bit 32 when mixed with lower bits", function()
                raceId = RACE_ID.SKYBORNE_ALLIANCE
                QuestiePlayer:Initialize()

                assert.is_true(QuestiePlayer.HasRequiredRace(RACE_MASK.SKYBORNE_ALLIANCE + RACE_MASK.HUMAN))
                assert.is_false(QuestiePlayer.HasRequiredRace(RACE_MASK.SKYBORNE_HORDE + RACE_MASK.HUMAN))
            end)

            it("preserves bit 33 when mixed with lower bits", function()
                raceId = RACE_ID.SKYBORNE_HORDE
                QuestiePlayer:Initialize()

                assert.is_true(QuestiePlayer.HasRequiredRace(RACE_MASK.SKYBORNE_HORDE + RACE_MASK.HUMAN))
                assert.is_false(QuestiePlayer.HasRequiredRace(RACE_MASK.SKYBORNE_ALLIANCE + RACE_MASK.HUMAN))
            end)
        end)
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
