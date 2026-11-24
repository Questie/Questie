dofile("setupTests.lua")

local LoadQuestieDBMock = dofile("test/QuestieDBMock.lua")

-- Forever's factions, which have races above 32 bits
local ALLIANCE, HORDE = 4294967373, 8589934770

describe("JourneyPrerequisites", function()
    ---@type JourneyPrerequisites
    local JourneyPrerequisites
    ---@type QuestiePlayer
    local QuestiePlayer
    ---@type table<QuestId, number> Race masks of the prerequisites
    local requiredRaces
    local originalLibQuestieDB

    before_each(function()
        originalLibQuestieDB = _G.LibQuestieDB
        LoadQuestieDBMock()

        requiredRaces = {}
        local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
        QuestieDB.raceKeys = {ALL_ALLIANCE = ALLIANCE, ALL_HORDE = HORDE}
        QuestieDB.QueryQuestSingle = function(questId, field)
            assert.are_equal("requiredRaces", field)
            return requiredRaces[questId]
        end
        QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
        QuestiePlayer.faction = "Horde"

        dofile("Modules/Journey/JourneyPrerequisites.lua")
        JourneyPrerequisites = QuestieLoader:ImportModule("JourneyPrerequisites")
    end)

    after_each(function()
        _G.LibQuestieDB = originalLibQuestieDB
    end)

    describe("GetShown", function()
        it("should leave out the other faction's version of a prerequisite", function()
            requiredRaces = {[79366] = HORDE, [96135] = ALLIANCE}

            local shown = JourneyPrerequisites.GetShown(HORDE, {79366, 96135})

            assert.are_same({79366}, shown)
        end)

        it("should keep the order and every prerequisite the quest's faction has access to", function()
            local dwarfAndGnome, nightElf = 68, 8
            requiredRaces = {
                [95998] = ALLIANCE, [96101] = nil, [96604] = HORDE, [96605] = HORDE, [96606] = nightElf, [96607] = HORDE, [96608] = dwarfAndGnome,
            }

            local shown = JourneyPrerequisites.GetShown(ALLIANCE, {95998, 96101, 96604, 96605, 96606, 96607, 96608})

            assert.are_same({95998, 96101, 96606, 96608}, shown)
        end)

        it("should go by the quest's faction, not the player's", function()
            QuestiePlayer.faction = "Alliance"
            requiredRaces = {[79366] = HORDE, [96135] = ALLIANCE}

            local shown = JourneyPrerequisites.GetShown(HORDE, {79366, 96135})

            assert.are_same({79366}, shown)
        end)

        it("should go by the player's faction for a quest both factions have access to", function()
            requiredRaces = {[92514] = HORDE, [93461] = ALLIANCE}

            QuestiePlayer.faction = "Horde"
            assert.are_same({92514}, JourneyPrerequisites.GetShown(0, {92514, 93461}))

            QuestiePlayer.faction = "Alliance"
            assert.are_same({93461}, JourneyPrerequisites.GetShown(0, {92514, 93461}))
        end)

        it("should go by the player's faction when the quest has no race mask", function()
            requiredRaces = {[92514] = HORDE, [93461] = ALLIANCE}

            assert.are_same({92514}, JourneyPrerequisites.GetShown(nil, {92514, 93461}))
        end)

        it("should show nothing for a quest that requires none", function()
            assert.are_same({}, JourneyPrerequisites.GetShown(HORDE, {}))
        end)

        it("should tell the two Skyborne races apart", function()
            local highOrder, windshaper = 4294967296, 8589934592
            requiredRaces = {[1] = highOrder, [2] = windshaper}
            local preQuestSingle = {1, 2}

            assert.are_same({1}, JourneyPrerequisites.GetShown(highOrder, preQuestSingle))
            assert.are_same({2}, JourneyPrerequisites.GetShown(windshaper, preQuestSingle))
        end)

        it("should keep prerequisites both factions have access to", function()
            local tauren, nightElf = 32, 8
            requiredRaces = {[1] = 0, [2] = ALLIANCE + HORDE, [3] = tauren + nightElf, [4] = ALLIANCE}

            assert.are_same({1, 2, 3}, JourneyPrerequisites.GetShown(HORDE, {1, 2, 3, 4}))
        end)

        it("should show all prerequisites when the faction has access to none of them", function()
            requiredRaces = {[1] = ALLIANCE, [2] = ALLIANCE}

            assert.are_same({1, 2}, JourneyPrerequisites.GetShown(HORDE, {1, 2}))
        end)

        it("should show all prerequisites of a quest for both factions to a player without a faction", function()
            QuestiePlayer.faction = "Neutral"
            requiredRaces = {[1] = ALLIANCE, [2] = HORDE, [3] = 0}

            assert.are_same({1, 2, 3}, JourneyPrerequisites.GetShown(0, {1, 2, 3}))
        end)
    end)
end)
