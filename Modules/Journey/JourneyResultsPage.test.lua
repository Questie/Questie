dofile("setupTests.lua")

describe("JourneyResultsPage", function()
    ---@type JourneyResultsPage
    local JourneyResultsPage
    local originalQuestie
    local found, names, questZones, npcZones, objectZones

    local STORMWIND_CITY, ELWYNN_FOREST, WESTFALL, DARNASSUS_CITY, DUROTAR, THE_STOCKADE = 1519, 12, 40, 1657, 14, 717
    local MAGE = -161 -- A quest sort, which the class quests are listed by
    local STORMWIND, DARNASSUS, ARGENT_DAWN, STEAMWHEEDLE_CARTEL = 72, 69, 529, 169
    local ZONE_NAMES = {[ELWYNN_FOREST] = "Elwynn Forest", [WESTFALL] = "Westfall"}
    local MAP_ICON, FACTION_ICON = "Interface\\AddOns\\Questie\\Icons\\map_scroll.png", "Interface\\Icons\\INV_Shirt_GuildTabard_01"

    before_each(function()
        originalQuestie = _G.Questie
        _G.Questie = {db = {profile = {enableTooltipsQuestID = false}}}

        dofile("Modules/Libs/QuestieLoader.lua")
        dofile("Localization/l10n.lua")
        local QuestieJourney = QuestieLoader:ImportModule("QuestieJourney")
        QuestieJourney.continents = {[1] = "Eastern Kingdoms", [2] = "Kalimdor", [9] = "Dungeons"}
        QuestieJourney.zones = {
            [1] = {[STORMWIND_CITY] = "Stormwind City", [ELWYNN_FOREST] = "Elwynn Forest", [WESTFALL] = "Westfall"},
            [2] = {[DARNASSUS_CITY] = "Darnassus", [DUROTAR] = "Durotar"},
            [9] = {[THE_STOCKADE] = "The Stockade"},
        }
        QuestieJourney.factionsByExpansion = {classic = {
            [STORMWIND] = "Stormwind", [DARNASSUS] = "Darnassus", [ARGENT_DAWN] = "Argent Dawn", [STEAMWHEEDLE_CARTEL] = "Steamwheedle Cartel",
        }}
        dofile("Modules/Journey/JourneyPlaces.lua")

        -- What the databases have, which QuestieSearch finds and is tested with
        found = {quest = {176, 184}, npc = {448}, object = {}, item = {2589}}
        names = {npc = {[448] = "Hogger"}, object = {[55] = "Half-eaten body"}, item = {[2589] = "Linen Cloth"}}
        dofile("Modules/Journey/QuestieSearch.lua")
        local QuestieSearch = QuestieLoader:ImportModule("QuestieSearch")
        QuestieSearch.Search = function(kind, query) return query == "storm" and found[kind] or {} end
        QuestieSearch.GetName = function(kind, id) return names[kind][id] end

        questZones, npcZones, objectZones = {}, {}, {}
        local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
        QuestieDB.QueryQuestSingle = function(id, field) return field == "zoneOrSort" and questZones[id] or nil end
        QuestieDB.QueryNPCSingle = function(id, field) return field == "zoneID" and npcZones[id] or nil end
        QuestieDB.QueryObjectSingle = function(id, field) return field == "zoneID" and objectZones[id] or nil end
        -- Like the zone names, which have a name for anything
        QuestieLoader:ImportModule("QuestieJourneyUtils").GetZoneName = function(_, zoneId) return ZONE_NAMES[zoneId] or "Unknown Zone" end

        dofile("Modules/Journey/JourneyResultsPage.lua")
        JourneyResultsPage = QuestieLoader:ImportModule("JourneyResultsPage")
    end)

    after_each(function()
        _G.Questie = originalQuestie
    end)

    describe("Find", function()
        it("should list the zones and factions found first, each leading to its own tab", function()
            local groups = JourneyResultsPage.Find("storm")

            assert.are_same({value = "result zone", text = "Quests by Zone", note = "1", children = {
                {value = "zone:1519", kind = "zone", source = "zone:1519", text = "Stormwind City", note = "Eastern Kingdoms", icon = MAP_ICON},
            }}, groups[1])
            assert.are_same({value = "result faction", text = "Quests by Faction", note = "1", children = {
                {value = "faction:72", kind = "faction", source = "faction:72", text = "Stormwind", icon = FACTION_ICON},
            }}, groups[2])
        end)

        it("should list what was found in the databases after the places, by kind, with how many there are", function()
            local groups = JourneyResultsPage.Find("storm")

            assert.are_same({
                {value = "result quest", text = "Quests", note = "2", children = {{value = 176, kind = "quest"}, {value = 184, kind = "quest"}}},
                {value = "result npc", text = "NPCs", note = "1", children = {{value = 448, kind = "npc"}}},
                {value = "result object", text = "Objects", note = "0", children = {}},
                {value = "result item", text = "Items", note = "1", children = {{value = 2589, kind = "item"}}},
            }, {groups[3], groups[4], groups[5], groups[6]})
            assert.are.equal(6, #groups)
        end)
    end)

    describe("GetText", function()
        it("should name an NPC, an object or an item, with its ID when tooltips show IDs", function()
            assert.are.equal("Hogger", JourneyResultsPage.GetText({value = 448, kind = "npc"}))

            Questie.db.profile.enableTooltipsQuestID = true

            assert.are.equal("Hogger (448)", JourneyResultsPage.GetText({value = 448, kind = "npc"}))
            assert.are.equal("Half-eaten body (55)", JourneyResultsPage.GetText({value = 55, kind = "object"}))
            assert.are.equal("Linen Cloth (2589)", JourneyResultsPage.GetText({value = 2589, kind = "item"}))
        end)
    end)

    describe("GetNote", function()
        it("should say in which zone a quest, an NPC or an object is", function()
            questZones[176] = WESTFALL
            npcZones[448] = ELWYNN_FOREST
            objectZones[55] = ELWYNN_FOREST

            assert.are.equal("Westfall", JourneyResultsPage.GetNote({value = 176, kind = "quest"}))
            assert.are.equal("Elwynn Forest", JourneyResultsPage.GetNote({value = 448, kind = "npc"}))
            assert.are.equal("Elwynn Forest", JourneyResultsPage.GetNote({value = 55, kind = "object"}))
        end)

        it("should say nothing for a quest of a quest sort, or something without a zone", function()
            questZones[7] = MAGE
            npcZones[1] = 0

            assert.is_nil(JourneyResultsPage.GetNote({value = 7, kind = "quest"}))
            assert.is_nil(JourneyResultsPage.GetNote({value = 1, kind = "npc"}))
            assert.is_nil(JourneyResultsPage.GetNote({value = 2, kind = "object"}))
            assert.is_nil(JourneyResultsPage.GetNote({value = 2589, kind = "item"}))
        end)
    end)

    describe("GetTypedPlace", function()
        it("should open the zone whose name was started to be typed, also over a faction of the same name", function()
            assert.are.equal("zone:1519", JourneyResultsPage.GetTypedPlace("storm"))
            assert.are.equal("zone:1519", JourneyResultsPage.GetTypedPlace("STORMWIND"))
            assert.are.equal("zone:1657", JourneyResultsPage.GetTypedPlace("darn"))
        end)

        it("should open the faction whose name was started to be typed when no zone's name starts with it", function()
            assert.are.equal("faction:169", JourneyResultsPage.GetTypedPlace("steam"))
            -- Darnassus and Durotar only have it inside their names
            assert.are.equal("faction:529", JourneyResultsPage.GetTypedPlace("ar"))
        end)

        it("should open nothing when no name starts with what was typed", function()
            assert.is_nil(JourneyResultsPage.GetTypedPlace("wind"))
            assert.is_nil(JourneyResultsPage.GetTypedPlace("hogger"))
        end)
    end)
end)
