dofile("setupTests.lua")

describe("JourneyPlaces", function()
    ---@type JourneyPlaces
    local JourneyPlaces
    ---@type QuestieJourney
    local QuestieJourney
    local originalCMap
    local currentZoneId

    local ELWYNN_FOREST, WESTFALL, STORMWIND_CITY, BURNING_STEPPES = 12, 40, 1519, 46
    local DUROTAR, STONETALON_MOUNTAINS = 14, 406
    local BLACKROCK_DEPTHS, BLACKROCK_SPIRE = 1584, 1583
    local MAGE = -161 -- A quest sort, which the class quests are listed by
    local GOLDSHIRE = 87 -- A part of Elwynn Forest
    local TIRISFAL_GLADES = 85 -- In no group
    local STORMWIND, DARNASSUS, THE_ALDOR = 72, 69, 932

    -- The maps the client knows, by the area IDs ZoneDB has for them
    local EASTERN_KINGDOMS_MAP, KALIMDOR_MAP = 1415, 1414
    local UI_MAPS = {
        [ELWYNN_FOREST] = 1429, [WESTFALL] = 1436, [STORMWIND_CITY] = 1453, [BURNING_STEPPES] = 1428,
        [DUROTAR] = 1411, [STONETALON_MOUNTAINS] = 1442, [BLACKROCK_DEPTHS] = 242, [BLACKROCK_SPIRE] = 250,
    }
    local MAP_INFOS = {
        [EASTERN_KINGDOMS_MAP] = {mapType = Enum.UIMapType.Continent, parentMapID = 947},
        [KALIMDOR_MAP] = {mapType = Enum.UIMapType.Continent, parentMapID = 947},
        [1429] = {mapType = Enum.UIMapType.Zone, parentMapID = EASTERN_KINGDOMS_MAP},
        [1436] = {mapType = Enum.UIMapType.Zone, parentMapID = EASTERN_KINGDOMS_MAP},
        [1453] = {mapType = Enum.UIMapType.Zone, parentMapID = EASTERN_KINGDOMS_MAP},
        [1428] = {mapType = Enum.UIMapType.Zone, parentMapID = EASTERN_KINGDOMS_MAP},
        [1411] = {mapType = Enum.UIMapType.Zone, parentMapID = KALIMDOR_MAP},
        [1442] = {mapType = Enum.UIMapType.Zone, parentMapID = KALIMDOR_MAP},
        -- Both dungeons are in the same zone, not on a continent
        [242] = {mapType = Enum.UIMapType.Dungeon, parentMapID = 1428},
        [250] = {mapType = Enum.UIMapType.Dungeon, parentMapID = 1428},
    }

    before_each(function()
        originalCMap = _G.C_Map
        _G.C_Map = {GetMapInfo = function(uiMapId)
            local info = MAP_INFOS[uiMapId]
            return info and {mapID = uiMapId, mapType = info.mapType, parentMapID = info.parentMapID}
        end}

        dofile("Modules/Libs/QuestieLoader.lua")
        dofile("Localization/l10n.lua")
        dofile("Modules/Journey/QuestieJourney.lua")
        QuestieJourney = QuestieLoader:ImportModule("QuestieJourney")
        local keys = QuestieJourney.questCategoryKeys
        -- Like this character's: Outland has zones, but isn't on this client, and there are no event quests
        QuestieJourney.continents = {
            [keys.EASTERN_KINGDOMS] = "Eastern Kingdoms", [keys.KALIMDOR] = "Kalimdor", [keys.DUNGEONS] = "Dungeons",
            [keys.CLASS] = "Class", [keys.EVENTS] = "Events",
        }
        QuestieJourney.zones = {
            [keys.EASTERN_KINGDOMS] = {
                [WESTFALL] = "Westfall", [STORMWIND_CITY] = "Stormwind City", [ELWYNN_FOREST] = "Elwynn Forest",
                [BURNING_STEPPES] = "Burning Steppes",
            },
            [keys.KALIMDOR] = {[DUROTAR] = "Durotar", [STONETALON_MOUNTAINS] = "Stonetalon Mountains"},
            [keys.OUTLAND] = {[3483] = "Hellfire Peninsula"},
            [keys.DUNGEONS] = {[BLACKROCK_DEPTHS] = "Blackrock Depths", [BLACKROCK_SPIRE] = "Blackrock Spire"},
            [keys.CLASS] = {[MAGE] = "Mage"},
            [keys.EVENTS] = {},
        }
        QuestieJourney.factionsByExpansion = {
            classic = {[STORMWIND] = "Stormwind", [DARNASSUS] = "Darnassus"},
            tbc = {[THE_ALDOR] = "The Aldor"},
        }
        QuestieJourney.zoneMap = {[ELWYNN_FOREST] = {[1] = true, [2] = true}, [MAGE] = {[3] = true}}
        QuestieJourney.factionMap = {[STORMWIND] = {[2] = true}}

        QuestieLoader:ImportModule("QuestieJourneyUtils").GetZoneName = function(_, zoneId)
            return zoneId == TIRISFAL_GLADES and "Tirisfal Glades" or "Unknown Zone"
        end
        currentZoneId = ELWYNN_FOREST
        QuestieLoader:ImportModule("QuestiePlayer").GetCurrentZoneId = function() return currentZoneId end
        QuestieLoader:ImportModule("JourneyThread").YieldIfNeeded = function() end
        local ZoneDB = QuestieLoader:ImportModule("ZoneDB")
        ZoneDB.GetParentZoneId = function(_, areaId) return ({[GOLDSHIRE] = ELWYNN_FOREST})[areaId] end
        ZoneDB.GetUiMapIdByAreaId = function(_, areaId) return UI_MAPS[areaId] end

        dofile("Modules/Journey/JourneyPlaces.lua")
        JourneyPlaces = QuestieLoader:ImportModule("JourneyPlaces")
    end)

    after_each(function()
        _G.C_Map = originalCMap
    end)

    ---@param places JourneyPlace[]
    ---@return string[] names
    local function Names(places)
        local names = {}
        for index, place in ipairs(places) do
            names[index] = place.name
        end
        return names
    end

    describe("zones", function()
        it("should list the groups that have zones, in the order of their IDs", function()
            -- Outland isn't on this client, and the events have no quests
            assert.are_same({
                {id = 1, name = "Eastern Kingdoms"}, {id = 2, name = "Kalimdor"}, {id = 9, name = "Dungeons"}, {id = 11, name = "Class"},
            }, JourneyPlaces.GetGroups())
        end)

        it("should list the zones of a group by name, each with its group", function()
            assert.are_same({
                {id = BURNING_STEPPES, name = "Burning Steppes", group = "Eastern Kingdoms", groupId = 1},
                {id = ELWYNN_FOREST, name = "Elwynn Forest", group = "Eastern Kingdoms", groupId = 1},
                {id = STORMWIND_CITY, name = "Stormwind City", group = "Eastern Kingdoms", groupId = 1},
                {id = WESTFALL, name = "Westfall", group = "Eastern Kingdoms", groupId = 1},
            }, JourneyPlaces.GetZones(1))
            assert.are_same({}, JourneyPlaces.GetZones(99))
        end)

        it("should find the group a zone is in", function()
            assert.are.equal(1, JourneyPlaces.GetGroupOf(WESTFALL))
            assert.are.equal(9, JourneyPlaces.GetGroupOf(BLACKROCK_DEPTHS))
            assert.are.equal(11, JourneyPlaces.GetGroupOf(MAGE))
            assert.is_nil(JourneyPlaces.GetGroupOf(TIRISFAL_GLADES))
        end)

        it("should name a zone like its group does, and a zone of no group by the zone names", function()
            assert.are.equal("Stormwind City", JourneyPlaces.GetZoneName(STORMWIND_CITY))
            assert.are.equal("Mage", JourneyPlaces.GetZoneName(MAGE))
            assert.are.equal("Tirisfal Glades", JourneyPlaces.GetZoneName(TIRISFAL_GLADES))
            -- A quest sort, or no zone at all, has no name outside the groups
            assert.are.equal("", JourneyPlaces.GetZoneName(-999))
            assert.are.equal("", JourneyPlaces.GetZoneName(0))
        end)

        it("should count only the groups before the dungeons as continents", function()
            local keys = QuestieJourney.questCategoryKeys

            assert.is_true(JourneyPlaces.IsContinent(keys.EASTERN_KINGDOMS))
            assert.is_true(JourneyPlaces.IsContinent(keys.ZEPHRAS_ISLE))
            assert.is_false(JourneyPlaces.IsContinent(keys.DUNGEONS))
            assert.is_false(JourneyPlaces.IsContinent(keys.EVENTS))
            assert.is_true(JourneyPlaces.IsDungeons(keys.DUNGEONS))
            assert.is_false(JourneyPlaces.IsDungeons(keys.BATTLEGROUNDS))
        end)

        it("should give the zone the player is in, or the zone that has the quests of the part of it the player is in", function()
            assert.are.equal(ELWYNN_FOREST, JourneyPlaces.GetPlayerZone())

            currentZoneId = GOLDSHIRE
            assert.are.equal(ELWYNN_FOREST, JourneyPlaces.GetPlayerZone())
        end)
    end)

    describe("maps", function()
        it("should find the zone a map shows", function()
            assert.are_same({id = WESTFALL, name = "Westfall", group = "Eastern Kingdoms", groupId = 1}, JourneyPlaces.GetZoneOfMap(1436))
            assert.are_same({id = BLACKROCK_DEPTHS, name = "Blackrock Depths", group = "Dungeons", groupId = 9}, JourneyPlaces.GetZoneOfMap(242))
            assert.is_nil(JourneyPlaces.GetZoneOfMap(EASTERN_KINGDOMS_MAP))
        end)

        it("should find the continent the zones of a group are on", function()
            assert.are_same({id = 1, name = "Eastern Kingdoms"}, JourneyPlaces.GetContinentOfMap(EASTERN_KINGDOMS_MAP))
            assert.are_same({id = 2, name = "Kalimdor"}, JourneyPlaces.GetContinentOfMap(KALIMDOR_MAP))
        end)

        it("should not take the zone the dungeons are in for a continent", function()
            assert.is_nil(JourneyPlaces.GetContinentOfMap(1428))
        end)
    end)

    describe("factions", function()
        it("should list the factions of every expansion by name", function()
            assert.are_same({
                {id = DARNASSUS, name = "Darnassus"}, {id = STORMWIND, name = "Stormwind"}, {id = THE_ALDOR, name = "The Aldor"},
            }, JourneyPlaces.GetFactions())
        end)

        it("should name a faction of any expansion, and nothing for one without quests", function()
            assert.are.equal("The Aldor", JourneyPlaces.GetFactionName(THE_ALDOR))
            assert.are.equal("", JourneyPlaces.GetFactionName(47))
        end)
    end)

    describe("sources", function()
        it("should split a source into its kind and ID, also the negative ID of a quest sort", function()
            assert.are_same({"zone", ELWYNN_FOREST}, {JourneyPlaces.Split("zone:12")})
            assert.are_same({"zone", MAGE}, {JourneyPlaces.Split("zone:-161")})
            assert.are_same({"faction", STORMWIND}, {JourneyPlaces.Split("faction:72")})
            assert.are_same({"overview", 2}, {JourneyPlaces.Split("overview:2")})
            assert.are_same({"all"}, {JourneyPlaces.Split(JourneyPlaces.ALL)})
        end)

        it("should name a source after its zone or faction", function()
            assert.are.equal("All Quests", JourneyPlaces.GetName(JourneyPlaces.ALL))
            assert.are.equal("Elwynn Forest", JourneyPlaces.GetName("zone:12"))
            assert.are.equal("Mage", JourneyPlaces.GetName("zone:-161"))
            assert.are.equal("Stormwind", JourneyPlaces.GetName("faction:72"))
        end)

        it("should give the quests of a zone, of a faction, or of all zones together", function()
            assert.are_same({[1] = true, [2] = true}, JourneyPlaces.GetQuestIds("zone:12"))
            assert.are_same({[2] = true}, JourneyPlaces.GetQuestIds("faction:72"))
            assert.are_same({[1] = true, [2] = true, [3] = true}, JourneyPlaces.GetQuestIds(JourneyPlaces.ALL))
            assert.are_same({}, JourneyPlaces.GetQuestIds("zone:40"))
            assert.are_same({}, JourneyPlaces.GetQuestIds("faction:69"))
        end)
    end)

    describe("Search", function()
        it("should find the zones and factions with the text in their name, those that start with it first", function()
            QuestieJourney.factionsByExpansion.classic[169] = "Steamwheedle Cartel"
            QuestieJourney.factionsByExpansion.classic[729] = "Frostwolf Clan"

            local zones, factions = JourneyPlaces.Search("sT")

            -- Kalimdor comes after the Eastern Kingdoms, but Stonetalon starts with it
            assert.are_same({"Stormwind City", "Stonetalon Mountains", "Burning Steppes", "Elwynn Forest", "Westfall"}, Names(zones))
            assert.are_same({"Steamwheedle Cartel", "Stormwind", "Frostwolf Clan"}, Names(factions))
            assert.are_same({id = STORMWIND_CITY, name = "Stormwind City", group = "Eastern Kingdoms", groupId = 1}, zones[1])
        end)

        it("should take the text as it is, not as a pattern", function()
            local zones, factions = JourneyPlaces.Search(".")
            assert.are_same({}, zones)
            assert.are_same({}, factions)

            zones = JourneyPlaces.Search("(")
            assert.are_same({}, zones)
        end)
    end)
end)
