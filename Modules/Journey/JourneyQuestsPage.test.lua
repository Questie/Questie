dofile("setupTests.lua")

local FakeUI = dofile("cli/testData/options/FakeUI.lua")

describe("JourneyQuestsPage", function()
    ---@type JourneyPage
    local JourneyPage
    local ui
    local originals
    local listArea, detailsArea, page
    local categoriesBySource, detailRowCount

    local WOLVES, KOBOLDS, DAILY, DONE = 7, 8, 9, 10
    local NAMES = {[WOLVES] = "Wolves", [KOBOLDS] = "Kobolds", [DAILY] = "Daily Bread", [DONE] = "Done Before"}
    local ELWYNN, STORMWIND = 12, 72

    -- In the order of JourneyQuestCategories
    local CATEGORIES = {
        {key = "log", text = "Quest Log"},
        {key = "available", text = "Available Quests"},
        {key = "repeatable", text = "Repeatable Quests"},
        {key = "completed", text = "Completed Quests"},
    }

    ---Like JourneyQuestCategories.Collect, new each time: the categories, with the quests in them.
    ---@param questIds {log: number[]?, available: number[]?, repeatable: number[]?, completed: number[]?}
    ---@return JourneyTreeNode[] nodes
    ---@return number completed
    ---@return number total
    local function Collect(questIds)
        local nodes = {}
        for index, category in ipairs(CATEGORIES) do
            local quests = {}
            for questIndex, id in ipairs(questIds[category.key] or {}) do
                quests[questIndex] = {value = id, text = NAMES[id]}
            end
            nodes[index] = {value = category.key, text = category.text, children = quests}
        end
        local completed = #(questIds.completed or {})
        return nodes, completed, completed + #(questIds.log or {}) + #(questIds.available or {})
    end

    before_each(function()
        ui = FakeUI.Install()
        originals = {}
        for _, name in ipairs({"Questie", "OVERVIEW"}) do
            originals[name] = {value = _G[name]}
        end
        _G.OVERVIEW = "Overview"
        _G.Questie = {
            db = {char = {}, profile = {}},
            Error = function(prefix, message) error(tostring(prefix) .. " " .. tostring(message)) end,
        }

        dofile("Modules/Libs/QuestieLoader.lua")
        dofile("Localization/l10n.lua")
        categoriesBySource, detailRowCount = {}, 1
        local JourneyPlaces = QuestieLoader:ImportModule("JourneyPlaces")
        local splits = {["zone:12"] = {"zone", ELWYNN}, ["faction:72"] = {"faction", STORMWIND}}
        JourneyPlaces.Split = function(source) return splits[source][1], splits[source][2] end
        JourneyPlaces.GetQuestIds = function(source) return categoriesBySource[source] end
        QuestieLoader:ImportModule("JourneyQuestCategories").Collect = Collect
        -- What a faction shows is tested with JourneyFactions
        local JourneyFactions = QuestieLoader:ImportModule("JourneyFactions")
        -- Like the real one, it puts the quests below their zone. Here they are all in Elwynn Forest.
        JourneyFactions.Arrange = function(factionId, categories)
            for _, category in ipairs(categories) do
                if category.children[1] then
                    category.children = {{value = ELWYNN, text = "Elwynn Forest", children = category.children}}
                end
            end
            return {factionId = factionId}
        end
        JourneyFactions.GetRows = function(factionId, overview, onZone)
            return {
                {type = "text", text = "Reputation with " .. factionId .. " from " .. overview.factionId},
                {type = "link", text = "Elwynn Forest", onClick = function() onZone(ELWYNN) end},
            }
        end
        QuestieLoader:ImportModule("QuestieDB").GetQuest = function(id) return {Id = id} end
        QuestieLoader:ImportModule("JourneyQuestDetails").GetRows = function(quest)
            local rows = {}
            for index = 1, detailRowCount do
                rows[index] = {type = "text", text = "Quest " .. quest.Id .. (index > 1 and (" " .. index) or "")}
            end
            return rows
        end
        QuestieLoader:ImportModule("JourneyLinks").TryInsertIntoChat = function() end

        dofile("Modules/Libs/ThreadLib.lua")
        dofile("Modules/Options/QuestieOptionsUtils.lua")
        dofile("Modules/Options/QuestieOptionsControls.lua")
        dofile("Modules/Journey/JourneyThread.lua")
        dofile("Modules/Journey/JourneyIcon.lua")
        dofile("Modules/Journey/JourneyScrollBox.lua")
        dofile("Modules/Journey/JourneyList.lua")
        dofile("Modules/Journey/JourneyTree.lua")
        dofile("Modules/Journey/JourneyDetails.lua")
        dofile("Modules/Journey/JourneyPage.lua")
        dofile("Modules/Journey/JourneyQuestsPage.lua")
        JourneyPage = QuestieLoader:ImportModule("JourneyPage")

        listArea, detailsArea = CreateFrame("Frame", nil, UIParent), CreateFrame("Frame", nil, UIParent)
    end)

    after_each(function()
        for name, original in pairs(originals) do
            _G[name] = original.value
        end
        ui.Restore()
    end)

    local function Refresh()
        JourneyPage.Refresh(page)
        ui.RunUntilIdle()
    end

    ---@param source string
    local function Open(source)
        page = JourneyPage.Create({list = {contentArea = listArea}, details = {contentArea = detailsArea}}, function() end, function() end)
        JourneyPage.SetContent(page, QuestieLoader:ImportModule("JourneyQuestsPage"), source)
        JourneyPage.SetShown(page, true)
        Refresh()
    end

    ---@return string[]
    local function ListTexts()
        return ui.RowTexts(listArea, 1)
    end

    ---@return string[]
    local function SelectedTexts()
        return ui.SelectedRowTexts(listArea, 1)
    end

    ---@return table
    local function DetailsList()
        return ui.FindByTemplate(detailsArea, "WowScrollBoxList")[1]
    end

    ---@return string[]
    local function Details()
        local texts = {}
        for _, row in ipairs(DetailsList().rowFrames) do
            table.insert(texts, row.elementData.text)
        end
        return texts
    end

    ---@param text string
    local function ClickDetails(text)
        for _, row in ipairs(DetailsList().rowFrames) do
            if row.elementData.text == text then
                return row.elementData.onClick()
            end
        end
        error("There are no details " .. text)
    end

    describe("a zone", function()
        before_each(function()
            categoriesBySource["zone:12"] = {log = {WOLVES}, available = {KOBOLDS}, repeatable = {DAILY}, completed = {DONE}}
        end)

        it("should list its quests, with those in the quest log, the available and the repeatable ones open", function()
            Open("zone:12")

            assert.are_same({
                "Quest Log", "Wolves", "Available Quests", "Kobolds", "Repeatable Quests", "Daily Bread", "Completed Quests",
            }, ListTexts())
        end)

        it("should show the first quest at first", function()
            Open("zone:12")

            assert.are_same({"Wolves"}, SelectedTexts())
            assert.are_same({"Quest 7"}, Details())
        end)

        it("should keep the completed quests closed when they are all it has", function()
            categoriesBySource["zone:12"] = {completed = {DONE}}

            Open("zone:12")

            assert.are_same({"Completed Quests"}, ListTexts())
            assert.are_same({}, Details())
        end)

        it("should say how many of its quests were completed", function()
            Open("zone:12")

            -- The repeatable one doesn't count
            assert.are_same({"1 of 3 completed", 1 / 3}, {page.progressText, page.progressShare})
        end)

        it("should break up large numbers of quests, like the bars do", function()
            QuestieLoader:ImportModule("JourneyQuestCategories").Collect = function(questIds)
                local nodes = Collect(questIds)
                return nodes, 1234, 5678
            end

            Open("zone:12")

            assert.are.equal("1,234 of 5,678 completed", page.progressText)
        end)

        it("should say so when it has no quests, and show no progress", function()
            categoriesBySource["zone:12"] = {}

            Open("zone:12")

            local emptyText = ui.FindAll(listArea, function(frame) return frame.text == "No Quests found" end)[1]
            assert.is_true(emptyText:IsVisible())
            assert.are_same({"", nil}, {page.progressText, page.progressShare})
            assert.are_same({}, Details())
        end)
    end)

    describe("a zone that is loaded again", function()
        before_each(function()
            categoriesBySource["zone:12"] = {log = {WOLVES}, available = {KOBOLDS}, repeatable = {DAILY}, completed = {DONE}}
            Open("zone:12")
        end)

        it("should keep what the user selected, and the categories the user opened and closed", function()
            ui.ClickRow(listArea, 1, "Kobolds")
            ui.ClickRow(listArea, 1, "Quest Log")
            ui.ClickRow(listArea, 1, "Completed Quests")

            Refresh()

            assert.are_same({
                "Quest Log", "Available Quests", "Kobolds", "Repeatable Quests", "Daily Bread", "Completed Quests", "Done Before",
            }, ListTexts())
            assert.are_same({"Kobolds"}, SelectedTexts())
            assert.are_same({"Quest 8"}, Details())
        end)

        -- It is loaded again whenever a quest changes, while the user reads the details
        it("should stay where its details were scrolled to", function()
            detailRowCount = 10
            ui.visibleRows = 3
            ui.ClickRow(listArea, 1, "Kobolds")
            DetailsList():ScrollToElementDataIndex(9)
            assert.are.equal("Quest 8 9", Details()[3])

            Refresh()

            assert.are.equal("Quest 8 9", Details()[3])
        end)
    end)

    describe("a faction", function()
        before_each(function()
            categoriesBySource["faction:72"] = {available = {WOLVES, KOBOLDS}, completed = {DONE}}
        end)

        it("should show its overview at first, above its quests", function()
            Open("faction:72")

            assert.are_same({"Overview", "Available Quests", "Elwynn Forest", "Completed Quests"}, ListTexts())
            assert.are_same({"Overview"}, SelectedTexts())
            assert.are_same({"Reputation with 72 from 72", "Elwynn Forest"}, Details())
        end)

        it("should show the quests of a zone that is clicked in the overview", function()
            Open("faction:72")

            ClickDetails("Elwynn Forest")

            assert.are_same({"Overview", "Available Quests", "Elwynn Forest", "Wolves", "Kobolds", "Completed Quests"}, ListTexts())
        end)

        it("should keep showing the overview when it is loaded again", function()
            Open("faction:72")

            Refresh()

            assert.are_same({"Overview", "Available Quests", "Elwynn Forest", "Completed Quests"}, ListTexts())
            assert.are_same({"Overview"}, SelectedTexts())
            assert.are_same({"Reputation with 72 from 72", "Elwynn Forest"}, Details())
        end)

        it("should be shown again from its overview after a quest was looked at", function()
            Open("faction:72")
            ui.ClickRow(listArea, 1, "Elwynn Forest")
            ui.ClickRow(listArea, 1, "Wolves")

            ui.ClickRow(listArea, 1, "Overview")

            assert.are_same({"Reputation with 72 from 72", "Elwynn Forest"}, Details())
        end)
    end)
end)
