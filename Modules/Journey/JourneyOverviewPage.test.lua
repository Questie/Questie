dofile("setupTests.lua")

local FakeUI = dofile("cli/testData/options/FakeUI.lua")

-- The overview runs in a page like the one of the tabs of the quests, with its rows and lists. The places, what is counted for
-- them, the levels of zones, the factions and the search are stubbed, because they go through whole databases.
describe("JourneyOverviewPage", function()
    ---@type JourneyOverviewPage
    local JourneyOverviewPage
    ---@type JourneyPage
    local JourneyPage
    local ui, originals
    local listArea, detailsArea, page
    local keys
    local playerLevel, playerZone, opened, linkedQuests
    ---@type table<string, table> What counting finds, by source
    local counts
    local summaries
    local met, unmet, closest
    local found, searches, typedPlaces

    -- Blizzard's texts, in English
    local GLOBAL_STRINGS = {
        BUG_CATEGORY4 = "Cities", REPUTATION = "Reputation", OVERVIEW = "Overview", WORLD = "World", CHARACTER = "Character",
        OTHER = "Other", QUEST_LOG = "Quest Log",
    }
    local GLOBALS = {"Questie", "UnitLevel", "UnitClassBase", "UnitFactionGroup", "HIGHLIGHT_FONT_COLOR"}
    for name in pairs(GLOBAL_STRINGS) do table.insert(GLOBALS, name) end

    local ZONES = {
        "Duskwood", "Elwynn Forest", "Ironforge", "Loch Modan", "Redridge Mountains", "Stormwind City", "Westfall", -- Eastern Kingdoms
        "Darkshore", "Teldrassil", -- Kalimdor
        "Gnomeregan", "Razorfen Kraul", "Scarlet Monastery", "The Deadmines", "The Stockade", "Wailing Caverns", -- Dungeons
        "Warsong Gulch", "Mage", "Alchemy", "Cooking", "Tailoring", "Seasonal",
    }
    local ID = {} -- Of each zone
    for index, name in ipairs(ZONES) do ID[name] = index end
    local LEVELS = {
        ["Duskwood"] = {18, 30}, ["Elwynn Forest"] = {1, 10}, ["Loch Modan"] = {10, 18}, ["Redridge Mountains"] = {15, 25},
        ["Westfall"] = {10, 20}, ["Darkshore"] = {10, 20}, ["Teldrassil"] = {1, 10}, ["Gnomeregan"] = {24, 34},
        ["Scarlet Monastery"] = {30, 45}, ["The Deadmines"] = {15, 25}, ["The Stockade"] = {20, 30}, ["Warsong Gulch"] = {10, 60},
        ["Razorfen Kraul"] = {25, 35}, ["Wailing Caverns"] = {15, 25},
    }
    local CITIES = {["Ironforge"] = true, ["Stormwind City"] = true}

    ---@param fields table?
    ---@return JourneySummary.Summary
    local function Summary(fields)
        local summary = {log = 0, complete = 0, available = 0, later = 0, completed = 0, suited = 0}
        for key, value in pairs(fields or {}) do summary[key] = value end
        -- Like JourneySummary counts it
        summary.total = summary.log + summary.available + summary.later + summary.completed
        return summary
    end

    ---@param name string Of a zone
    ---@param fields table
    local function Count(name, fields)
        counts["zone:" .. ID[name]] = Summary(fields)
    end

    ---@param id number
    ---@param name string
    ---@param standingId number 8 is Exalted
    ---@param standingName string
    ---@param value number How far the player is in the standing
    ---@param size number Of the standing
    ---@return JourneyFactions.Met
    local function Met(id, name, standingId, standingName, value, size)
        return {
            faction = {id = id, name = name},
            standing = {id = standingId, name = standingName, value = value, size = size, reputation = standingId * 10000 + value,
                color = CreateColor(1, 1, 1)},
        }
    end

    local function StubPlaces()
        local groups = {
            -- With the first and the last of their zones
            {id = keys.EASTERN_KINGDOMS, name = "Eastern Kingdoms", zones = {1, 7}},
            {id = keys.KALIMDOR, name = "Kalimdor", zones = {8, 9}},
            {id = keys.DUNGEONS, name = "Dungeons", zones = {10, 15}},
            {id = keys.BATTLEGROUNDS, name = "Battlegrounds", zones = {16, 16}},
            {id = keys.CLASS, name = "Mage", zones = {17, 17}},
            {id = keys.PROFESSIONS, name = "Professions", zones = {18, 20}},
            {id = keys.EVENTS, name = "Events", zones = {21, 21}},
        }
        local JourneyPlaces = QuestieLoader:ImportModule("JourneyPlaces")
        JourneyPlaces.ALL = "all"
        JourneyPlaces.GetGroups = function()
            local result = {}
            for index, group in ipairs(groups) do result[index] = {id = group.id, name = group.name} end
            return result
        end
        JourneyPlaces.GetZones = function(groupId)
            for _, group in ipairs(groups) do
                if group.id == groupId then
                    local zones = {}
                    for id = group.zones[1], group.zones[2] do
                        table.insert(zones, {id = id, name = ZONES[id], group = group.name, groupId = groupId})
                    end
                    return zones
                end
            end
            return {}
        end
        JourneyPlaces.GetGroupName = function(groupId)
            for _, group in ipairs(groups) do
                if group.id == groupId then return group.name end
            end
            return ""
        end
        JourneyPlaces.IsContinent = function(groupId) return groupId == keys.EASTERN_KINGDOMS or groupId == keys.KALIMDOR end
        JourneyPlaces.IsDungeons = function(groupId) return groupId == keys.DUNGEONS end
        JourneyPlaces.GetPlayerZone = function() return playerZone end
        JourneyPlaces.GetQuestIds = function() return {} end
    end

    local function StubCounts()
        local JourneySummary = QuestieLoader:ImportModule("JourneySummary")
        JourneySummary.Get = function(source) return summaries[source] end
        JourneySummary.Count = function(source)
            summaries[source] = counts[source] or Summary()
            return summaries[source]
        end

        local JourneyZoneLevels = QuestieLoader:ImportModule("JourneyZoneLevels")
        JourneyZoneLevels.Read = function() end
        JourneyZoneLevels.Get = function(zoneId)
            local levels = LEVELS[ZONES[zoneId]]
            return levels and {low = levels[1], high = levels[2]}
        end
        JourneyZoneLevels.IsCity = function(zoneId) return CITIES[ZONES[zoneId]] == true end
        JourneyZoneLevels.GetColor = function() return {r = 1, g = 0.82, b = 0} end
        JourneyZoneLevels.IsOutgrown = function(levels) return levels.high + 10 < playerLevel end
        -- By ten levels, like the real ones
        JourneyZoneLevels.GetBracket = function(levels)
            local low = math.floor(levels.low / 10) * 10
            return {low = math.max(1, low), high = low + 10}
        end

        local JourneyFactions = QuestieLoader:ImportModule("JourneyFactions")
        JourneyFactions.GetMet = function() return met, unmet end
        JourneyFactions.GetClosest = function() return closest end
    end

    local function StubSearch()
        local JourneyResultsPage = QuestieLoader:ImportModule("JourneyResultsPage")
        JourneyResultsPage.Find = function(query)
            table.insert(searches, query)
            return found
        end
        JourneyResultsPage.GetTypedPlace = function(query) return typedPlaces[query] end
        JourneyResultsPage.GetText = function(node) return node.kind .. " " .. node.value end
        JourneyResultsPage.GetIcon = function() end
        JourneyResultsPage.GetNote = function() end
        QuestieLoader:ImportModule("JourneyLinkInput").Enable = function() end
        QuestieLoader:ImportModule("JourneyLinks").TryInsertIntoChat = function(questId) table.insert(linkedQuests, questId) end
        -- The details of what was found are tested with JourneyQuestDetails
        QuestieLoader:ImportModule("QuestieDB").GetQuest = function(id) return {Id = id} end
        QuestieLoader:ImportModule("JourneyQuestDetails").GetRows = function(quest)
            return {{type = "text", text = "The details of quest " .. quest.Id}}
        end
    end

    before_each(function()
        ui = FakeUI.Install()
        ui.visibleRows = 100
        originals = {}
        for _, name in ipairs(GLOBALS) do originals[name] = {value = _G[name]} end
        for name, text in pairs(GLOBAL_STRINGS) do _G[name] = text end
        _G.HIGHLIGHT_FONT_COLOR = {r = 1, g = 1, b = 1}
        playerLevel, playerZone = 20, ID["Elwynn Forest"]
        _G.UnitLevel = function() return playerLevel end
        _G.UnitClassBase = function() return "MAGE" end
        _G.UnitFactionGroup = function() return "Alliance" end
        _G.Questie = {
            db = {profile = {}},
            icons = {available = "available", complete = "complete", incomplete = "incomplete", checkmark = "checkmark"},
        }
        counts, summaries, opened, linkedQuests = {}, {}, {}, {}
        met, unmet, closest = {}, {}, {}
        found, searches, typedPlaces = {}, {}, {}

        dofile("Modules/Libs/QuestieLoader.lua")
        dofile("Localization/l10n.lua")
        dofile("Modules/Libs/utf8.lua")
        dofile("Modules/Libs/ThreadLib.lua")
        dofile("Modules/Options/QuestieOptionsUtils.lua")
        dofile("Modules/Journey/QuestieJourney.lua")
        keys = QuestieLoader:ImportModule("QuestieJourney").questCategoryKeys
        dofile("Modules/Journey/JourneyThread.lua")
        dofile("Modules/Journey/JourneyIcon.lua")
        dofile("Modules/Journey/JourneyScrollBox.lua")
        dofile("Modules/Journey/JourneyList.lua")
        dofile("Modules/Journey/JourneyTree.lua")
        dofile("Modules/Journey/JourneyDetails.lua")
        dofile("Modules/Journey/JourneySummary.lua")
        dofile("Modules/Journey/JourneyZoneLevels.lua")
        StubPlaces()
        StubCounts()
        StubSearch()
        dofile("Modules/Journey/JourneyPage.lua")
        dofile("Modules/Journey/JourneyOverviewRows.lua")
        dofile("Modules/Journey/JourneyOverviewPage.lua")
        JourneyPage = QuestieLoader:ImportModule("JourneyPage")
        JourneyOverviewPage = QuestieLoader:ImportModule("JourneyOverviewPage")

        -- Like the tab of the quests makes it
        listArea, detailsArea = CreateFrame("Frame", nil, UIParent), CreateFrame("Frame", nil, UIParent)
        listArea:SetSize(300, 500)
        detailsArea:SetSize(500, 500)
        page = JourneyPage.Create({list = {contentArea = listArea}, details = {contentArea = detailsArea}}, function(source)
            table.insert(opened, source)
        end, function() end)
        JourneyPage.SetContent(page, JourneyOverviewPage)
    end)

    after_each(function()
        for name, original in pairs(originals) do _G[name] = original.value end
        ui.Restore()
    end)

    ---@param id number|string Of the category
    local function Select(id)
        JourneyPage.Select(page, {kind = "category", id = id})
    end

    ---Like the tab of the quests opens the overview.
    ---@param id number|string? Of the category
    local function Open(id)
        JourneyPage.SetShown(page, true)
        JourneyPage.Refresh(page)
        Select(id or JourneyOverviewPage.GOOD)
        ui.RunUntilIdle()
    end

    ---@param root table
    ---@return table[] lists Below root, those that can be seen
    local function VisibleLists(root)
        return ui.FindAll(root, function(frame) return frame.template == "WowScrollBoxList" and frame:IsVisible() end)
    end

    ---@param root table
    ---@return JourneyDetails.Row[] rows Of the first list below root that can be seen
    local function ShownRows(root)
        local list = VisibleLists(root)[1]
        local rows = {}
        for _, rowFrame in ipairs(list.rowFrames) do
            table.insert(rows, rowFrame.elementData)
        end
        return rows
    end

    ---@param rows JourneyDetails.Row[]
    ---@return string[] lines What each row shows, without the gaps
    local function Lines(rows)
        local lines = {}
        for _, row in ipairs(rows) do
            if row.type == "tiles" then
                local texts = {}
                for _, tile in ipairs(row.tiles) do table.insert(texts, tile.text) end
                table.insert(lines, "tiles: " .. table.concat(texts, " | "))
            elseif row.type == "zone" then
                table.insert(lines, "zone: " .. row.zone.name)
            elseif row.type == "banner" then
                table.insert(lines, "banner: " .. row.text .. " (" .. row.tag .. ")")
            elseif row.type ~= "gap" then
                table.insert(lines, row.type .. ": " .. row.text)
            end
        end
        return lines
    end

    ---@return string[]
    local function Categories()
        return Lines(ShownRows(listArea))
    end

    ---@return string[]
    local function Details()
        return Lines(ShownRows(detailsArea))
    end

    ---@param text string
    ---@return JourneyOverviewRows.Tile
    local function Tile(text)
        for _, row in ipairs(ShownRows(listArea)) do
            for _, tile in ipairs(row.tiles or {}) do
                if tile.text == text then return tile end
            end
        end
        error("There is no tile " .. text)
    end

    ---@param name string
    ---@return JourneyOverviewRows.Zone
    local function Zone(name)
        for _, row in ipairs(ShownRows(detailsArea)) do
            if row.zone and row.zone.name == name then return row.zone end
        end
        error("There is no zone " .. name)
    end

    ---@return string[] texts Of the tiles that look selected
    local function SelectedTiles()
        local texts = {}
        for _, row in ipairs(ShownRows(listArea)) do
            for _, tile in ipairs(row.tiles or {}) do
                if tile.isSelected then table.insert(texts, tile.text) end
            end
        end
        return texts
    end

    describe("categories", function()
        it("should have tiles for the search, the overview, the continents, dungeons, battlegrounds, class, professions, "
            .. "reputation, events and all quests", function()
            Open()

            assert.are_same({
                "tiles: Search | Overview",
                "label: World",
                "tiles: Eastern Kingdoms | Kalimdor",
                "tiles: Dungeons | Battlegrounds",
                "label: Character",
                "tiles: Mage | Professions",
                "tiles: Reputation",
                "label: Other",
                "tiles: Events | All Quests",
            }, Categories())
        end)

        it("should show on each tile how many of its quests are completed, once they are counted", function()
            Count("Elwynn Forest", {completed = 10, available = 3})
            Count("Westfall", {completed = 20})
            Count("Darkshore", {completed = 1, later = 4})
            met, unmet = {Met(72, "Stormwind", 5, "Friendly", 100, 6000)}, {{id = 54, name = "Gnomeregan Exiles"}}

            JourneyPage.SetShown(page, true)
            Select(JourneyOverviewPage.GOOD)
            assert.are_same({0, 0}, {Tile("Eastern Kingdoms").value, Tile("Eastern Kingdoms").maximum})

            Open()
            assert.are_same({30, 33}, {Tile("Eastern Kingdoms").value, Tile("Eastern Kingdoms").maximum})
            assert.are_same({1, 5}, {Tile("Kalimdor").value, Tile("Kalimdor").maximum})
            assert.are_same({1, 2}, {Tile("Reputation").value, Tile("Reputation").maximum})
            assert.are_same({31, 38}, {Tile("All Quests").value, Tile("All Quests").maximum})
        end)

        it("should show how many of all quests are completed above the page", function()
            Count("Elwynn Forest", {completed = 10, available = 3})
            Count("The Deadmines", {completed = 2, later = 5})

            Open()

            assert.are.equal("12 of 20 completed", page.progressText)
            assert.are.equal(12 / 20, page.progressShare)
        end)

        it("should show what is in the one whose tile was clicked, and mark its tile", function()
            Open()
            assert.are_same({"Overview"}, SelectedTiles())

            Tile("Kalimdor").onClick()

            assert.are_same({"Kalimdor"}, SelectedTiles())
            assert.are.equal("banner: Kalimdor (0 of 0 completed)", Details()[1])
        end)

        it("should open all quests in a tab of their own, and keep showing what it showed", function()
            Open()

            Tile("All Quests").onClick()

            assert.are_same({"all"}, opened)
            assert.are_same({"Overview"}, SelectedTiles())
        end)

        it("should show the search with the cursor in its box when its tile is clicked", function()
            Open()

            Tile("Search").onClick()

            local box = ui.FindByTemplate(UIParent, "SearchBoxTemplate")[1]
            assert.is_true(box:IsVisible())
            assert.are.equal(box, ui.focus)
            assert.is_true(JourneyOverviewPage.IsSearchShown(page))
        end)
    end)

    describe("a continent", function()
        before_each(function()
            Count("Elwynn Forest", {log = 1, complete = 1, available = 2, completed = 10, suited = 3})
            Count("Westfall", {completed = 2000})
            Count("Stormwind City", {available = 1, suited = 1})
            Open()
            Select(keys.EASTERN_KINGDOMS)
        end)

        it("should list its capital cities first, then its zones by level", function()
            assert.are_same({
                "banner: Eastern Kingdoms (2,010 of 2,014 completed)",
                "section: Cities",
                "zone: Ironforge",
                "zone: Stormwind City",
                "section: Level 1 - 10",
                "zone: Elwynn Forest",
                "section: Level 10 - 20",
                "zone: Loch Modan",
                "zone: Westfall",
                "zone: Redridge Mountains",
                "zone: Duskwood",
            }, Details())
        end)

        it("should show for each zone what is counted for it", function()
            local elwynn = Zone("Elwynn Forest")
            assert.are_same({"1 - 10", 3, 1, 10, 13}, {elwynn.levels, elwynn.suited, elwynn.log, elwynn.completed, elwynn.total})
            assert.is_true(elwynn.isLogComplete)
            assert.is_true(elwynn.isHere)
            assert.is_nil(elwynn.icon)

            local westfall = Zone("Westfall")
            assert.is_false(westfall.isHere)
            assert.are.equal("checkmark", westfall.icon)

            local duskwood = Zone("Duskwood") -- Nothing was counted for it
            assert.are_same({0, 0, 0, 0}, {duskwood.suited, duskwood.log, duskwood.completed, duskwood.total})
            assert.is_nil(duskwood.icon)
        end)

        it("should open a zone in a tab of its own", function()
            Zone("Westfall").onClick()

            assert.are_same({"zone:" .. ID["Westfall"]}, opened)
        end)

        it("should explain a zone in its tooltip, with only what there is", function()
            GameTooltip:SetOwner(UIParent)

            Zone("Elwynn Forest").showTooltip()

            assert.are.equal("Elwynn Forest", GameTooltip.text)
            assert.are_same({
                "Eastern Kingdoms",
                {"Level", "1 - 10"},
                {"Good for your level", "3"},
                {"Quest Log", "1"},
                {"Available Quests", "2"},
                {"Completed Quests", "10"},
            }, GameTooltip.lines)
        end)

    end)

    it("should list what isn't a zone, like a profession, with what there is something to do for first", function()
        Count("Alchemy", {available = 2})
        Count("Cooking", {log = 1})
        Count("Tailoring", {completed = 3})
        Open()

        Select(keys.PROFESSIONS)

        assert.are_same({
            "banner: Professions (3 of 6 completed)",
            "section: Available Quests",
            "zone: Alchemy",
            "zone: Cooking",
            "section: Other",
            "zone: Tailoring",
        }, Details())
    end)

    describe("good for your level", function()
        ---@return table<string, string[]> zones By section
        ---@return string[] sections In their order
        local function Sections()
            local zones, sections, section = {}, {}, nil
            for _, line in ipairs(Details()) do
                if line:match("^section: ") then
                    section = line:match("^section: (.+)$")
                    table.insert(sections, section)
                    zones[section] = {}
                elseif section then
                    table.insert(zones[section], (line:match("^%a+: (.+)$")))
                end
            end
            return zones, sections
        end

        -- How many is up to the overview
        it("should list some of the zones with the most quests for the player's level, of each continent and of the dungeons", function()
            local ranked = {
                ["Eastern Kingdoms"] = {
                    "Loch Modan", "Westfall", "Stormwind City", "Elwynn Forest", "Duskwood", "Redridge Mountains", "Ironforge",
                },
                ["Dungeons"] = {"Wailing Caverns", "Scarlet Monastery", "Gnomeregan", "Razorfen Kraul", "The Deadmines", "The Stockade"},
            }
            for name, suited in pairs({
                ["Loch Modan"] = 6, ["Westfall"] = 6, ["Stormwind City"] = 5, ["Elwynn Forest"] = 4, ["Duskwood"] = 3,
                ["Redridge Mountains"] = 2, ["Ironforge"] = 1, ["Darkshore"] = 2,
                ["Wailing Caverns"] = 6, ["Scarlet Monastery"] = 5, ["Gnomeregan"] = 4, ["Razorfen Kraul"] = 3, ["The Deadmines"] = 2,
                ["The Stockade"] = 1,
            }) do
                Count(name, {available = suited, suited = suited})
            end

            Open()

            local zones, sections = Sections()
            assert.are.equal("banner: Overview (Good for your level: 20)", Details()[1])
            assert.are_same({"Eastern Kingdoms", "Kalimdor", "Dungeons"}, sections)
            for _, name in ipairs({"Eastern Kingdoms", "Dungeons"}) do
                local shown = zones[name]
                assert.are_same({unpack(ranked[name], 1, #shown)}, shown)
                assert.is_true(#shown > 0 and #shown < #ranked[name])
            end
            assert.are_same({"Darkshore"}, zones["Kalimdor"])
        end)

        it("should leave out zones the player outgrew, and what isn't a continent or the dungeons", function()
            playerLevel = 30
            Count("Elwynn Forest", {available = 9, suited = 9}) -- Up to level 10
            Count("Westfall", {available = 1, suited = 1})
            for _, name in ipairs({"Warsong Gulch", "Mage", "Alchemy", "Seasonal"}) do
                Count(name, {available = 9, suited = 9})
            end

            Open()

            assert.are_same({
                "banner: Overview (Good for your level: 30)",
                "section: Eastern Kingdoms",
                "zone: Westfall",
            }, Details())
        end)

        it("should list the factions that are closest to their next standing, which lead to their tabs", function()
            closest = {Met(72, "Stormwind", 5, "Friendly", 5900, 6000), Met(47, "Ironforge", 6, "Honored", 11000, 12000)}

            Open()

            assert.are_same({
                "banner: Overview (Good for your level: 20)",
                "section: Reputation",
                "faction: Stormwind",
                "faction: Ironforge",
            }, Details())
            ShownRows(detailsArea)[4].onClick()
            assert.are_same({"faction:47"}, opened)
        end)
    end)

    it("should list the factions the player met by standing, and the others after them", function()
        met = {
            Met(69, "Darnassus", 8, "Exalted", 500, 1000), Met(47, "Ironforge", 8, "Exalted", 100, 1000),
            Met(72, "Stormwind", 5, "Friendly", 100, 6000),
        }
        unmet = {{id = 54, name = "Gnomeregan Exiles"}}
        Open()

        Select(JourneyOverviewPage.FACTIONS)

        assert.are_same({
            "banner: Reputation (3 / 4)",
            "section: Exalted",
            "faction: Darnassus",
            "faction: Ironforge",
            "section: Friendly",
            "faction: Stormwind",
            "section: Other",
            "faction: Gnomeregan Exiles",
        }, Details())
        ShownRows(detailsArea)[8].onClick()
        assert.are_same({"faction:54"}, opened)
    end)

    describe("the search", function()
        local box, searchFrame

        before_each(function()
            Open(JourneyOverviewPage.SEARCH)
            box = ui.FindByTemplate(UIParent, "SearchBoxTemplate")[1]
            searchFrame = box:GetParent()
        end)

        ---@param kind string
        ---@param count number
        ---@return JourneyTreeNode
        local function Results(kind, count)
            local children = {}
            for id = 1, count do children[id] = {value = id, kind = kind} end
            return {value = "result " .. kind, text = kind .. "s", note = tostring(count), children = children}
        end

        ---@return string[]
        local function ResultTexts()
            return ui.RowTexts(searchFrame, 1)
        end

        ---@return string? text Saying that nothing was found, while it is shown
        local function NoMatchText()
            local texts = ui.FindAll(searchFrame, function(frame)
                return frame.frameType == "FontString" and frame:IsVisible() and (frame.text or ""):find("^No Match") ~= nil
            end)
            return texts[1] and texts[1].text
        end

        it("should wait for three letters before searching while the user types", function()
            box:SetText("wo")
            ui.RunFor(1)
            assert.are_same({}, searches)

            box:SetText("wol")
            ui.RunUntilIdle()
            assert.are_same({"wol"}, searches)
        end)

        it("should only search once the user stopped typing for a moment", function()
            box:SetText("wol")
            ui.RunFor(0.1)
            box:SetText("wolf")
            ui.RunFor(0.1)
            assert.are_same({}, searches)

            ui.RunUntilIdle()

            assert.are_same({"wolf"}, searches)
        end)

        it("should search for any text right away when Enter is pressed", function()
            box:SetText("wo")
            box:PressEnter()
            ui.RunFrame()
            ui.RunFrame()

            assert.are_same({"wo"}, searches)
        end)

        -- Their words are often two characters, which are more than one byte each
        for locale, word in pairs({koKR = {"늑", "늑대"}, zhCN = {"狼", "狼群"}, zhTW = {"狼", "狼群"}}) do
            it("should wait for two characters in " .. locale, function()
                QuestieLoader:ImportModule("l10n"):SetUILocale(locale)

                box:SetText(word[1])
                ui.RunFor(1)
                assert.are_same({}, searches)

                box:SetText(word[2])
                ui.RunUntilIdle()
                assert.are_same({word[2]}, searches)
            end)
        end

        it("should open the zone or faction whose name was typed when Enter is pressed", function()
            typedPlaces["elwy"] = "zone:" .. ID["Elwynn Forest"]
            box:SetText("elwy")

            box:PressEnter()

            assert.are_same({"zone:" .. ID["Elwynn Forest"]}, opened)
        end)

        it("should search for the name of a link that was put into the box", function()
            box:SetText("|cffffff00|Hquest:7:5|h[Wolves]|h|r")
            ui.RunUntilIdle()

            assert.are.equal("Wolves", box:GetText())
            assert.are_same({"Wolves"}, searches)
        end)

        it("should not search again for the same text with spaces or brackets around it", function()
            box:SetText("wolf")
            ui.RunUntilIdle()

            box:SetText(" [wolf] ")
            ui.RunUntilIdle()

            assert.are_same({"wolf"}, searches)
        end)

        it("should say when nothing was found, and only then", function()
            found = {Results("quest", 0)}
            box:SetText("wolf")
            ui.RunUntilIdle()
            assert.are.equal("No Match for Search Results: wolf", NoMatchText())

            found = {Results("quest", 2)}
            box:SetText("wolves")
            ui.RunUntilIdle()
            assert.is_nil(NoMatchText())
            assert.are_same({"quests", "quest 1", "quest 2"}, ResultTexts())
        end)

        it("should show nothing when the box is emptied, without searching", function()
            found = {Results("quest", 2)}
            box:SetText("wolf")
            ui.RunUntilIdle()
            box:SetText("")
            ui.RunUntilIdle()
            assert.are_same({}, ResultTexts())

            found = {Results("quest", 0)}
            box:SetText("wolves")
            ui.RunUntilIdle()
            box:SetText("")
            ui.RunUntilIdle()
            assert.is_nil(NoMatchText())

            assert.are_same({"wolf", "wolves"}, searches)
        end)

        -- How many is up to the overview
        it("should collapse the kinds with many results, and expand those with few", function()
            found = {Results("quest", 200), Results("npc", 2)}

            box:SetText("wolf")
            ui.RunUntilIdle()

            assert.are_same({"quests", "npcs", "npc 1", "npc 2"}, ResultTexts())
        end)

        describe("what was found", function()
            local ELWYNN = "zone:" .. ID["Elwynn Forest"]

            before_each(function()
                found = {
                    {value = "result zone", text = "Zones", children = {
                        {value = ELWYNN, kind = "zone", source = ELWYNN, text = "Elwynn Forest"},
                    }},
                    Results("quest", 2),
                }
                box:SetText("wolf")
                ui.RunUntilIdle()
            end)

            it("should be shown next to the search, which moves into the list", function()
                ui.ClickRow(searchFrame, 1, "quest 2")

                assert.are_same({"text: The details of quest 2"}, Details())
                assert.are.equal(page.listFrame, searchFrame:GetParent())
                assert.is_true(searchFrame:IsVisible())
                -- Instead of the categories
                local lists = VisibleLists(listArea)
                assert.are.equal(1, #lists)
                assert.are.equal(ui.FindByTemplate(searchFrame, "WowScrollBoxList")[1], lists[1])
                assert.are_same({"quest 2"}, ui.SelectedRowTexts(searchFrame, 1))
                assert.is_true(JourneyOverviewPage.IsSearchShown(page))
            end)

            -- Like clicking it elsewhere in the Journey does, while typing in the chat
            it("should put the link of a quest that was clicked into the chat", function()
                ui.ClickRow(searchFrame, 1, "quest 2")

                assert.are_same({2}, linkedQuests)
            end)

            it("should leave the list to the categories again when going back", function()
                ui.ClickRow(searchFrame, 1, "quest 2")

                JourneyPage.GoBack(page)

                assert.are.equal(page.detailsFrame, searchFrame:GetParent())
                assert.is_true(searchFrame:IsVisible())
                assert.are.equal("tiles: Search | Overview", Categories()[1])
                assert.are_same({}, ui.SelectedRowTexts(searchFrame, 1))
            end)

            it("should open a zone in a tab of its own, and keep showing the search", function()
                ui.ClickRow(searchFrame, 1, "Elwynn Forest")

                assert.are_same({ELWYNN}, opened)
                assert.are_same({}, ui.SelectedRowTexts(searchFrame, 1))
                assert.are.equal(page.detailsFrame, searchFrame:GetParent())
            end)

            it("should be marked when it is shown in another way, like through a link", function()
                JourneyPage.Open(page, "quest", 1)

                assert.are_same({"quest 1"}, ui.SelectedRowTexts(searchFrame, 1))
            end)
        end)

        it("should not be shown with another category", function()
            Select(keys.KALIMDOR)

            assert.is_false(box:IsVisible())
            assert.is_false(JourneyOverviewPage.IsSearchShown(page))
        end)
    end)

    describe("GetClassPicture", function()
        it("should be the atlas of a class where the client has it, otherwise its icon", function()
            ui.atlases = {["classicon-mage"] = {}}

            assert.are_same({atlas = "classicon-mage"}, JourneyOverviewPage.GetClassPicture("MAGE"))
            assert.are.equal("Interface\\Icons\\ClassIcon_MONK", JourneyOverviewPage.GetClassPicture("MONK"))
        end)
    end)
end)
