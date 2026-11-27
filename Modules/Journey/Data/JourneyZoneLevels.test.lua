dofile("setupTests.lua")

describe("JourneyZoneLevels", function()
    ---@type JourneyZoneLevels
    local JourneyZoneLevels
    local GLOBALS = {"UnitLevel", "QuestDifficultyColors"}
    local originals
    local ELWYNN, GOLDSHIRE, WESTFALL, ORGRIMMAR = 12, 87, 40, 1637
    local CLASS_QUESTS = -61 -- A quest sort, not a zone
    ---@type table<QuestId, {zoneOrSort: number, questLevel: number?}>
    local quests
    local unlisted, playerLevel, trivialBelow

    ---@param zoneId number
    ---@param ... number The levels of its quests
    local function AddQuests(zoneId, ...)
        for _, level in ipairs({...}) do
            quests[#quests + 1] = {zoneOrSort = zoneId, questLevel = level}
        end
    end

    before_each(function()
        originals = {}
        for _, name in ipairs(GLOBALS) do originals[name] = _G[name] end
        quests, unlisted, playerLevel, trivialBelow = {}, {}, 20, 15
        _G.UnitLevel = function() return playerLevel end
        -- Blizzard's colors of quests, by how hard they are
        _G.QuestDifficultyColors = {
            impossible = "red", verydifficult = "orange", difficult = "yellow", standard = "green", trivial = "gray",
        }

        QuestieLoader:ImportModule("JourneyThread").YieldIfNeeded = function() end
        QuestieLoader:ImportModule("JourneyQuestCategories").IsListed = function(questId) return not unlisted[questId] end
        local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
        QuestieDB.QuestPointers = quests
        QuestieDB.QueryQuestSingle = function(questId, field) return quests[questId][field] end
        QuestieDB.IsTrivial = function(level) return level < trivialBelow end
        local ZoneDB = QuestieLoader:ImportModule("ZoneDB")
        ZoneDB.zoneIDs = {ORGRIMMAR = ORGRIMMAR}
        ZoneDB.GetParentZoneId = function(_, zoneId) return zoneId == GOLDSHIRE and ELWYNN or nil end

        dofile("Localization/l10n.lua")
        dofile("Modules/Journey/Data/JourneyZoneLevels.lua")
        JourneyZoneLevels = QuestieLoader:ImportModule("JourneyZoneLevels")
    end)

    after_each(function()
        for _, name in ipairs(GLOBALS) do _G[name] = originals[name] end
    end)

    describe("Get", function()
        it("should have the narrowest levels that three quarters of a zone's quests have", function()
            -- Any six of them: 10 and 30 are left out
            AddQuests(ELWYNN, 14, 30, 11, 12, 10, 14, 13, 12)

            JourneyZoneLevels.Read()

            assert.are_same({low = 11, high = 14}, JourneyZoneLevels.Get(ELWYNN))
        end)

        it("should count the quests of a part of a zone for the zone", function()
            AddQuests(ELWYNN, 5, 5)
            AddQuests(GOLDSHIRE, 9, 9)

            JourneyZoneLevels.Read()

            assert.are_same({low = 5, high = 9}, JourneyZoneLevels.Get(ELWYNN))
            assert.is_nil(JourneyZoneLevels.Get(GOLDSHIRE))
        end)

        it("should leave out quests that aren't listed, and those without a zone or a level", function()
            AddQuests(WESTFALL, 18, 18, 0, 50)
            unlisted[#quests] = true
            quests[#quests + 1] = {zoneOrSort = WESTFALL} -- No level
            AddQuests(CLASS_QUESTS, 10)

            JourneyZoneLevels.Read()

            assert.are_same({low = 18, high = 18}, JourneyZoneLevels.Get(WESTFALL))
            assert.is_nil(JourneyZoneLevels.Get(CLASS_QUESTS))
        end)

        it("should have no levels for a city, whose quests are for every level", function()
            AddQuests(ORGRIMMAR, 10, 30, 60)
            AddQuests(ELWYNN, 5)

            JourneyZoneLevels.Read()

            assert.is_nil(JourneyZoneLevels.Get(ORGRIMMAR))
            assert.are_same({true, false}, {JourneyZoneLevels.IsCity(ORGRIMMAR), JourneyZoneLevels.IsCity(ELWYNN)})
        end)

        it("should have no levels until they are read, and read them only once", function()
            AddQuests(ELWYNN, 5)
            assert.is_nil(JourneyZoneLevels.Get(ELWYNN))

            JourneyZoneLevels.Read()
            AddQuests(WESTFALL, 18)
            JourneyZoneLevels.Read()

            assert.are_same({low = 5, high = 5}, JourneyZoneLevels.Get(ELWYNN))
            assert.is_nil(JourneyZoneLevels.Get(WESTFALL))
        end)
    end)

    it("should show one level, or the lowest and the highest", function()
        assert.are.equal("5", JourneyZoneLevels.GetText({low = 5, high = 5}))
        assert.are.equal("10 - 20", JourneyZoneLevels.GetText({low = 10, high = 20}))
        assert.are.equal("Level 10 - 20", JourneyZoneLevels.GetBracketTitle({low = 10, high = 20}))
    end)

    it("should be outgrown when the player is above its levels, and its highest quests are too low to be worth it", function()
        -- Quests below level 15 are too low for the player at 20
        assert.is_true(JourneyZoneLevels.IsOutgrown({low = 5, high = 14}))
        assert.is_false(JourneyZoneLevels.IsOutgrown({low = 5, high = 15}))

        playerLevel, trivialBelow = 14, 0
        assert.is_false(JourneyZoneLevels.IsOutgrown({low = 5, high = 14}))
    end)

    it("should be yellow within its levels and up to two below, orange and red further below, and green or gray above", function()
        local colors = {}
        for _, levels in ipairs({
            {low = 25, high = 30}, {low = 24, high = 30}, {low = 23, high = 30}, {low = 22, high = 30}, -- The player at 20 is below
            {low = 15, high = 20}, -- Within
            {low = 10, high = 19}, {low = 5, high = 14}, -- Above, and outgrown
        }) do
            table.insert(colors, JourneyZoneLevels.GetColor(levels))
        end

        assert.are_same({"red", "orange", "orange", "yellow", "yellow", "green", "gray"}, colors)
    end)

    describe("GetBracket", function()
        it("should put zones together in steps of ten levels, up to the highest there is", function()
            AddQuests(ELWYNN, 1, 10)
            AddQuests(WESTFALL, 55, 60) -- The highest
            JourneyZoneLevels.Read()

            local brackets = {}
            for _, low in ipairs({1, 9, 10, 19, 55}) do
                local bracket = JourneyZoneLevels.GetBracket({low = low, high = low + 5})
                table.insert(brackets, bracket.low .. "-" .. bracket.high)
            end

            assert.are_same({"1-10", "1-10", "10-20", "10-20", "50-60"}, brackets)
        end)

        it("should put zones of the highest level into the last step, rather than one of their own", function()
            AddQuests(WESTFALL, 60, 60)
            AddQuests(ELWYNN, 55, 58)
            JourneyZoneLevels.Read()

            assert.are_same({low = 50, high = 60}, JourneyZoneLevels.GetBracket(JourneyZoneLevels.Get(WESTFALL)))
        end)

        it("should end the last step at the highest level, when that isn't a ten, like in Cataclysm", function()
            AddQuests(WESTFALL, 84, 85)
            AddQuests(ELWYNN, 81, 83)
            JourneyZoneLevels.Read()

            assert.are_same({low = 80, high = 85}, JourneyZoneLevels.GetBracket(JourneyZoneLevels.Get(ELWYNN)))
        end)
    end)
end)
