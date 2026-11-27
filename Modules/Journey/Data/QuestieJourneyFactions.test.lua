dofile("setupTests.lua")

describe("QuestieJourneyFactions", function()
    ---@type QuestieJourneyFactions
    local QuestieJourneyFactions
    ---@type QuestieJourney
    local QuestieJourney
    local quests, factionNames, hiddenQuests, eventQuests

    local STORMWIND, DARNASSUS = 72, 69
    -- In no expansion's list
    local NEW_FACTION = 2000
    local HIDE_ON_MAP = "hide on map"

    before_each(function()
        local otherIds = 100000
        _G.LibQuestieDB = {Enum = {factionIDs = setmetatable({STORMWIND = STORMWIND, DARNASSUS = DARNASSUS}, {
            -- Every other faction of the lists gets an ID of its own, as in the database
            __index = function(ids, name)
                otherIds = otherIds + 1
                rawset(ids, name, otherIds)
                return otherIds
            end,
        })}}

        quests, hiddenQuests, eventQuests = {}, {}, {}
        factionNames = {[STORMWIND] = "Stormwind", [DARNASSUS] = "Darnassus", [NEW_FACTION] = "New Faction"}

        local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
        QuestieDB.QuestPointers = quests
        QuestieDB.QueryQuest = function(questId, fields)
            local quest = quests[questId]
            local values = {}
            for index, field in ipairs(fields) do
                values[index] = quest[field]
            end
            return values
        end
        QuestieLoader:ImportModule("QuestieReputation").GetFactionName = function(factionId) return factionNames[factionId] end
        QuestieLoader:ImportModule("QuestiePlayer").HasRequiredRace = function(races) return races ~= "other race" end
        QuestieLoader:ImportModule("QuestiePlayer").HasRequiredClass = function(classes) return classes ~= "other class" end
        QuestieLoader:ImportModule("QuestieCorrections").hiddenQuests = hiddenQuests
        QuestieLoader:ImportModule("QuestieQuestBlacklist").HIDE_ON_MAP = HIDE_ON_MAP
        QuestieLoader:ImportModule("QuestieEvent").IsEventQuest = function(questId) return eventQuests[questId] == true end
        dofile("Modules/Expansions.lua")

        dofile("Modules/Journey/Data/QuestieJourneyFactions.lua")
        QuestieJourneyFactions = QuestieLoader:ImportModule("QuestieJourneyFactions")
        QuestieJourney = QuestieLoader:ImportModule("QuestieJourney")
    end)

    after_each(function()
        _G.LibQuestieDB = nil
    end)

    ---@return table<FactionId, QuestId[]> questIds Sorted, by faction
    local function QuestsByFaction()
        local result = {}
        for factionId, questIds in pairs(QuestieJourney.factionMap) do
            result[factionId] = {}
            for questId in pairs(questIds) do
                table.insert(result[factionId], questId)
            end
            table.sort(result[factionId])
        end
        return result
    end

    it("should list a quest under every faction it needs a standing with or gives reputation with", function()
        quests[1] = {requiredMinRep = {STORMWIND, 3000}}
        quests[2] = {reputationReward = {{STORMWIND, 250}, {DARNASSUS, 75}}}
        quests[3] = {requiredMaxRep = {DARNASSUS, 9000}}
        quests[4] = {} -- Nothing to do with a faction

        QuestieJourneyFactions.Initialize()

        assert.are_same({[STORMWIND] = {1, 2}, [DARNASSUS] = {2, 3}}, QuestsByFaction())
    end)

    it("should leave out quests the player's race or class can't do, and those Questie hides", function()
        quests[1] = {reputationReward = {{STORMWIND, 250}}, requiredRaces = "other race"}
        quests[2] = {reputationReward = {{STORMWIND, 250}}, requiredClasses = "other class"}
        quests[3] = {reputationReward = {{STORMWIND, 250}}}
        hiddenQuests[3] = true
        -- Only hidden on the map, or an event's, which are hidden until the event
        quests[4] = {reputationReward = {{STORMWIND, 250}}}
        hiddenQuests[4] = HIDE_ON_MAP
        quests[5] = {reputationReward = {{STORMWIND, 250}}}
        hiddenQuests[5], eventQuests[5] = true, true

        QuestieJourneyFactions.Initialize()

        assert.are_same({[STORMWIND] = {4, 5}}, QuestsByFaction())
    end)

    it("should group the factions with quests by the expansion that introduced them", function()
        quests[1] = {reputationReward = {{STORMWIND, 250}, {NEW_FACTION, 250}}}

        QuestieJourneyFactions.Initialize()

        assert.are_same({
            classic = {[STORMWIND] = "Stormwind"},
            -- A faction that isn't in a list belongs to the last expansion
            mop = {[NEW_FACTION] = "New Faction"},
        }, QuestieJourney.factionsByExpansion)
    end)

    it("should not name a faction the client has no name for, but keep its quests", function()
        quests[1] = {reputationReward = {{DARNASSUS, 250}}}
        factionNames[DARNASSUS] = nil

        QuestieJourneyFactions.Initialize()

        assert.are_same({}, QuestieJourney.factionsByExpansion)
        assert.are_same({[DARNASSUS] = {1}}, QuestsByFaction())
    end)
end)
