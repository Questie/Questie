dofile("setupTests.lua")

local FakeUI = dofile("cli/testData/options/FakeUI.lua")

describe("JourneyFactions", function()
    ---@type JourneyFactions
    local JourneyFactions
    local ui
    -- Globals replaced by a test, with what they were before
    local stubbed
    local reputations, metFactions, rewards, questZones

    local STORMWIND, DARNASSUS, IRONFORGE, GNOMEREGAN, BOOTY_BAY, EXODAR = 72, 69, 47, 54, 21, 930
    local FACTION_NAMES = {
        [STORMWIND] = "Stormwind", [DARNASSUS] = "Darnassus", [IRONFORGE] = "Ironforge", [GNOMEREGAN] = "Gnomeregan",
        [BOOTY_BAY] = "Booty Bay", [EXODAR] = "Exodar",
    }
    local ELWYNN_FOREST, WESTFALL, DUSKWOOD, MAGE = 12, 40, 10, -161
    local GOLDSHIRE = 87 -- A part of Elwynn Forest
    local ZONE_NAMES = {[ELWYNN_FOREST] = "Elwynn Forest", [WESTFALL] = "Westfall", [DUSKWOOD] = "Duskwood", [MAGE] = "Mage"}
    local STANDING_NAMES = {"Hated", "Hostile", "Unfriendly", "Neutral", "Friendly", "Honored", "Revered", "Exalted"}
    -- Blizzard's texts, in English
    local GLOBAL_STRINGS = {OTHER = "Other", REPUTATION = "Reputation", QUEST_LOG = "Quest Log"}

    ---@param name string
    ---@param value any
    local function Stub(name, value)
        if not stubbed[name] then
            stubbed[name] = {value = _G[name]}
        end
        _G[name] = value
    end

    before_each(function()
        -- For Blizzard's colors and numbers with thousands separators
        ui = FakeUI.Install()
        stubbed = {}
        for name, text in pairs(GLOBAL_STRINGS) do
            Stub(name, text)
        end
        -- A red of its own for each standing, so the hex code tells which it is: 0x50 is Friendly, 0x60 Honored
        local colors = {}
        for id = 1, 8 do
            colors[id] = {r = id * 16 / 255, g = 0, b = 0}
        end
        Stub("FACTION_BAR_COLORS", colors)
        Stub("GetText", function(token) return STANDING_NAMES[tonumber(token:match("^FACTION_STANDING_LABEL(%d)$"))] end)
        Stub("UnitSex", function() return 2 end)
        Stub("Questie", {
            db = {profile = {}},
            icons = {incomplete = "incomplete icon", available = "available icon", repeatable = "repeatable icon", checkmark = "checkmark icon"},
            Colorize = function(_, text) return text end,
        })

        dofile("Modules/Libs/QuestieLoader.lua")
        dofile("Localization/l10n.lua")
        local JourneyPlaces = QuestieLoader:ImportModule("JourneyPlaces")
        JourneyPlaces.GetFactionName = function(factionId) return FACTION_NAMES[factionId] or "" end
        JourneyPlaces.GetFactions = function()
            local factions = {}
            for _, id in ipairs({BOOTY_BAY, DARNASSUS, EXODAR, GNOMEREGAN, IRONFORGE, STORMWIND}) do
                table.insert(factions, {id = id, name = FACTION_NAMES[id]})
            end
            return factions
        end
        JourneyPlaces.GetZoneName = function(zoneId) return ZONE_NAMES[zoneId] or "" end
        QuestieLoader:ImportModule("JourneyThread").YieldIfNeeded = function() end

        reputations, metFactions, rewards, questZones = {}, {}, {}, {}
        QuestieLoader:ImportModule("QuestieCompat").GetFactionInfoByID = function(factionId)
            if reputations[factionId] then
                return FACTION_NAMES[factionId], "", 0, 0, 0, reputations[factionId]
            end
        end
        local QuestieReputation = QuestieLoader:ImportModule("QuestieReputation")
        QuestieReputation.GetPlayerReputations = function() return metFactions end
        QuestieReputation.GetReputationReward = function(questId) return rewards[questId] or {} end
        QuestieLoader:ImportModule("QuestieDB").QueryQuestSingle = function(questId, field)
            return field == "zoneOrSort" and questZones[questId] or nil
        end
        QuestieLoader:ImportModule("ZoneDB").GetParentZoneId = function(_, zoneId) return zoneId == GOLDSHIRE and ELWYNN_FOREST or nil end

        dofile("Modules/Journey/Data/JourneyFactions.lua")
        JourneyFactions = QuestieLoader:ImportModule("JourneyFactions")
    end)

    after_each(function()
        for name, original in pairs(stubbed) do
            _G[name] = original.value
        end
        ui.Restore()
    end)

    ---Puts the faction in the player's list of factions
    ---@param factionId FactionId
    ---@param reputation number
    local function Meet(factionId, reputation)
        reputations[factionId] = reputation
        metFactions[factionId] = {0, reputation}
    end

    ---@param standing JourneyFactions.Standing
    ---@return table
    local function Describe(standing)
        return {id = standing.id, name = standing.name, reputation = standing.reputation, value = standing.value, size = standing.size}
    end

    ---@param rows JourneyDetails.Row[]
    ---@param rowType string
    ---@return JourneyDetails.Row[]
    local function OfType(rows, rowType)
        local found = {}
        for _, row in ipairs(rows) do
            if row.type == rowType then
                table.insert(found, row)
            end
        end
        return found
    end

    ---@param rows JourneyDetails.Row[]
    ---@param caption string
    ---@return JourneyDetails.Row[] steps The steps below the caption
    local function StepsBelow(rows, caption)
        local steps, isBelow = {}, false
        for _, row in ipairs(rows) do
            if row.type == "caption" then
                isBelow = row.text == caption
            elseif isBelow and row.type == "step" then
                table.insert(steps, row)
            end
        end
        return steps
    end

    describe("standings", function()
        it("should tell the standing of a reputation, and how far into it the player is", function()
            local standing = JourneyFactions.GetStandingAt(3500)

            assert.are_same({id = 5, name = "Friendly", reputation = 3500, value = 500, size = 6000}, Describe(standing))
            assert.are.equal("|cff500000Friendly|r", JourneyFactions.GetStandingText(standing))
        end)

        it("should start a standing at its first point", function()
            assert.are_same({id = 5, name = "Friendly", reputation = 3000, value = 0, size = 6000}, Describe(JourneyFactions.GetStandingAt(3000)))
            assert.are_same({id = 4, name = "Neutral", reputation = 2999, value = 2999, size = 3000}, Describe(JourneyFactions.GetStandingAt(2999)))
            assert.are_same({id = 1, name = "Hated", reputation = -42000, value = 0, size = 36000}, Describe(JourneyFactions.GetStandingAt(-42000)))
        end)

        it("should keep the highest reputation in exalted, one point short of its end like the reputation bar", function()
            local expected = {id = 8, name = "Exalted", reputation = 42999, value = 999, size = 1000}

            assert.are_same(expected, Describe(JourneyFactions.GetStandingAt(42999)))
            assert.are_same(expected, Describe(JourneyFactions.GetStandingAt(43000)))
            assert.are_same(expected, Describe(JourneyFactions.GetStandingAt(50000)))
        end)

        it("should have the standing of a faction the client knows, and none for another", function()
            reputations[STORMWIND] = 9500

            assert.are_same({id = 6, name = "Honored", reputation = 9500, value = 500, size = 12000}, Describe(JourneyFactions.GetStanding(STORMWIND)))
            assert.is_nil(JourneyFactions.GetStanding(DARNASSUS))
        end)
    end)

    describe("GetReward", function()
        it("should add up what a quest gives the faction, rounded to whole points", function()
            rewards[1] = {{STORMWIND, 82.5}, {DARNASSUS, 500}, {STORMWIND, 10}}
            rewards[2] = {{DARNASSUS, 75}}

            assert.are.equal(93, JourneyFactions.GetReward(1, STORMWIND))
            assert.are.equal(0, JourneyFactions.GetReward(2, STORMWIND))
            assert.are.equal(0, JourneyFactions.GetReward(3, STORMWIND))
        end)
    end)

    describe("Arrange", function()
        ---@param questIds QuestId[]
        ---@return JourneyTreeNode[]
        local function Quests(questIds)
            local quests = {}
            for index, questId in ipairs(questIds) do
                quests[index] = {value = questId, text = "Quest " .. questId}
            end
            return quests
        end

        ---@param nodes JourneyTreeNode[]
        ---@return table[] Of each node, what is shown
        local function Shown(nodes)
            local shown = {}
            for index, node in ipairs(nodes) do
                shown[index] = {node.text, node.note}
            end
            return shown
        end

        it("should note what each quest gives the faction, and add it up for each part", function()
            rewards[1] = {{STORMWIND, 1250}}
            rewards[2] = {{STORMWIND, -275}} -- Like the Aldor's quests do for the Scryers
            rewards[4] = {{STORMWIND, 75}}
            local log, completed = {value = "log", children = Quests({1, 2, 3})}, {value = "completed", children = Quests({4})}

            local overview = JourneyFactions.Arrange(STORMWIND, {log, completed})

            assert.are_same({log = {count = 3, reputation = 975}, completed = {count = 1, reputation = 75}}, overview.parts)
            assert.are_same({{"Quest 1", "+1,250"}, {"Quest 2", "-275"}, {"Quest 3", nil}}, Shown(log.children))
            assert.are_same({{"Quest 4", "+75"}}, Shown(completed.children))
        end)

        it("should group the available quests by zone, those of the most reputation first", function()
            questZones = {[1] = ELWYNN_FOREST, [2] = GOLDSHIRE, [3] = WESTFALL, [4] = DUSKWOOD, [5] = MAGE, [6] = -999}
            rewards = {
                [1] = {{STORMWIND, 250}}, [2] = {{STORMWIND, 100}}, [3] = {{STORMWIND, 500}}, [4] = {{STORMWIND, 50}}, [5] = {{STORMWIND, 50}},
            }
            -- 6 is of a quest sort the Journey doesn't list, 7 has no zone
            local available = {value = "available", children = Quests({1, 2, 3, 4, 5, 6, 7})}

            local overview = JourneyFactions.Arrange(STORMWIND, {available})

            assert.are_same({{"Westfall", "+500"}, {"Elwynn Forest", "+350"}, {"Duskwood", "+50"}, {"Mage", "+50"}, {"Other", nil}},
                Shown(available.children))
            assert.are_same({{"Quest 1", "+250"}, {"Quest 2", "+100"}}, Shown(available.children[2].children))
            assert.are_same({{"Quest 6", nil}, {"Quest 7", nil}}, Shown(available.children[5].children))
            assert.are_same({
                {key = WESTFALL, name = "Westfall", count = 1, reputation = 500},
                {key = ELWYNN_FOREST, name = "Elwynn Forest", count = 2, reputation = 350},
                {key = DUSKWOOD, name = "Duskwood", count = 1, reputation = 50},
                {key = MAGE, name = "Mage", count = 1, reputation = 50},
                {key = 0, name = "Other", count = 2, reputation = 0},
            }, overview.zones)
        end)

        it("should group the quests with a missing requirement by zone too, but have only the available ones in the zones of the page", function()
            questZones = {[1] = ELWYNN_FOREST, [2] = WESTFALL, [3] = DUSKWOOD}
            local log = {value = "log", children = Quests({1})}
            local later = {value = "later", children = Quests({2})}
            local available = {value = "available", children = Quests({3})}

            local overview = JourneyFactions.Arrange(STORMWIND, {log, later, available})

            assert.are_same({{"Quest 1", nil}}, Shown(log.children))
            assert.are_same({{"Westfall", nil}}, Shown(later.children))
            assert.are_same({{key = DUSKWOOD, name = "Duskwood", count = 1, reputation = 0}}, overview.zones)
        end)
    end)

    describe("GetRows", function()
        ---@param parts table<JourneyQuestCategory, JourneyFactions.Part>
        ---@param zones table[]?
        ---@return JourneyFactions.Overview
        local function Overview(parts, zones)
            return {parts = parts, zones = zones or {}}
        end

        it("should show the standing, and the one all quests the player can do now would bring", function()
            Meet(STORMWIND, 8000)
            -- Completed quests and those with a missing requirement can't be done now
            local overview = Overview({
                log = {count = 1, reputation = 500}, available = {count = 2, reputation = 1500},
                completed = {count = 3, reputation = 3000}, later = {count = 1, reputation = 2000},
            })

            local rows = JourneyFactions.GetRows(STORMWIND, overview, function() end)

            assert.are_same({type = "page", text = "Stormwind"}, rows[1])
            local standingRow = OfType(rows, "standing")[1]
            assert.are_same({id = 5, name = "Friendly", reputation = 8000, value = 5000, size = 6000}, Describe(standingRow.standing))
            assert.are.equal(2000, standingRow.gain)
            assert.are.equal("With all quests you can do now: |cff600000Honored|r  1,000 / 12,000", OfType(rows, "text")[1].text)
        end)

        it("should not show a standing to reach when the quests only lose reputation", function()
            Meet(STORMWIND, 8000)

            local rows = JourneyFactions.GetRows(STORMWIND, Overview({log = {count = 1, reputation = -500}}), function() end)

            assert.are.equal(-500, OfType(rows, "standing")[1].gain)
            assert.are_same({}, OfType(rows, "text"))
        end)

        it("should show no standing for a faction the client doesn't know, but its quests", function()
            local rows = JourneyFactions.GetRows(STORMWIND, Overview({available = {count = 2, reputation = 500}}), function() end)

            assert.are_same({}, OfType(rows, "standing"))
            assert.are_same({}, OfType(rows, "text"))
            assert.are.equal(1, #StepsBelow(rows, "Reputation"))
        end)

        it("should list the parts that have quests in a fixed order, with how many quests and how much reputation", function()
            Meet(STORMWIND, 0)
            local overview = Overview({
                completed = {count = 3, reputation = 0}, log = {count = 1, reputation = 250}, later = {count = 2, reputation = -50},
                available = {count = 0, reputation = 0},
            })

            local steps = StepsBelow(JourneyFactions.GetRows(STORMWIND, overview, function() end), "Reputation")

            assert.are_same({
                {type = "step", text = "Quest Log", trailingIcon = "incomplete icon", tag = "1     +250"},
                {type = "step", text = "Missing Requirement", tag = "2     -50"},
                {type = "step", text = "Completed Quests", trailingIcon = "checkmark icon", tag = "3"},
            }, steps)
        end)

        it("should list where the most reputation is, at most 8 zones, and show a zone's quests when it is clicked", function()
            Meet(STORMWIND, 0)
            local zones = {}
            for index = 1, 10 do
                zones[index] = {key = index * 10, name = "Zone " .. index, count = 1, reputation = 1000 - index}
            end
            local clicked = {}

            local rows = JourneyFactions.GetRows(STORMWIND, Overview({available = {count = 10, reputation = 9945}}, zones), function(key)
                table.insert(clicked, key)
            end)
            local steps = StepsBelow(rows, "Where")
            steps[3].onClick()

            local texts = {}
            for index, step in ipairs(steps) do texts[index] = step.text .. " " .. step.tag end
            assert.are_same({
                "Zone 1 1     +999", "Zone 2 1     +998", "Zone 3 1     +997", "Zone 4 1     +996", "Zone 5 1     +995",
                "Zone 6 1     +994", "Zone 7 1     +993", "Zone 8 1     +992",
            }, texts)
            assert.are_same({30}, clicked)
        end)

        it("should leave out where the quests are when none are available", function()
            Meet(STORMWIND, 0)

            local rows = JourneyFactions.GetRows(STORMWIND, Overview({completed = {count = 1, reputation = 0}}), function() end)

            local captions = {}
            for index, row in ipairs(OfType(rows, "caption")) do captions[index] = row.text end
            assert.are_same({"Reputation"}, captions)
        end)
    end)

    describe("factions of the player", function()
        it("should list the met factions with the highest reputation first, and the others by name", function()
            Meet(STORMWIND, 9000)
            Meet(IRONFORGE, 3000)
            Meet(DARNASSUS, 3000)
            reputations[GNOMEREGAN] = 0 -- The client knows it, but the player hasn't met it

            local met, others = JourneyFactions.GetMet()

            local metNames = {}
            for index, entry in ipairs(met) do metNames[index] = entry.faction.name .. " " .. entry.standing.name end
            assert.are_same({"Stormwind Honored", "Darnassus Friendly", "Ironforge Friendly"}, metNames)
            assert.are_same({
                {id = BOOTY_BAY, name = "Booty Bay"}, {id = EXODAR, name = "Exodar"}, {id = GNOMEREGAN, name = "Gnomeregan"},
            }, others)
        end)

        it("should list the factions closest to their next standing, without the exalted and the unfriendly ones", function()
            Meet(STORMWIND, 8900) -- 100 to Honored
            Meet(DARNASSUS, 41500) -- 500 to Exalted
            Meet(IRONFORGE, 2000) -- 1000 to Friendly
            Meet(EXODAR, 9000) -- 12000 to Revered
            Meet(GNOMEREGAN, 42500) -- Exalted, there is nothing more
            Meet(BOOTY_BAY, -100) -- Unfriendly, quests won't help with that

            local function Closest(maxCount)
                local names = {}
                for index, entry in ipairs(JourneyFactions.GetClosest(maxCount)) do names[index] = entry.faction.name end
                return names
            end

            assert.are_same({"Stormwind", "Darnassus", "Ironforge"}, Closest(3))
            assert.are_same({"Stormwind", "Darnassus", "Ironforge", "Exodar"}, Closest(10))
        end)
    end)
end)
