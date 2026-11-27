dofile("setupTests.lua")

local FakeUI = dofile("cli/testData/options/FakeUI.lua")

describe("JourneyPage", function()
    ---@type JourneyPage
    local JourneyPage
    ---@type JourneyTree
    local JourneyTree
    local ui
    local originalQuestie
    local listArea, detailsArea, panes, page
    local content, nodes, loads, quests, openedSources, linkedQuests, shownDetails, updateQuestDetails

    local WOLVES, KOBOLDS, HOGGER = 7, 8, 448

    before_each(function()
        ui = FakeUI.Install()
        originalQuestie = _G.Questie
        _G.Questie = {
            db = {char = {}, profile = {}},
            Error = function(prefix, message) error(tostring(prefix) .. " " .. tostring(message)) end,
        }

        dofile("Modules/Libs/QuestieLoader.lua")
        dofile("Localization/l10n.lua")
        quests = {[WOLVES] = {Id = WOLVES, state = "available"}, [KOBOLDS] = {Id = KOBOLDS, state = "available"}}
        QuestieLoader:ImportModule("QuestieDB").GetQuest = function(id) return quests[id] end
        -- The details themselves are tested with JourneyQuestDetails and JourneyEntityDetails
        QuestieLoader:ImportModule("JourneyQuestDetails").GetRows = function(quest, update)
            updateQuestDetails = update
            return {{type = "text", text = "Quest " .. quest.Id .. " is " .. quest.state}}
        end
        QuestieLoader:ImportModule("JourneyEntityDetails").GetRows = function(kind, id)
            return {{type = "text", text = kind .. " " .. id}}
        end
        linkedQuests = {}
        QuestieLoader:ImportModule("JourneyLinks").TryInsertIntoChat = function(questId) table.insert(linkedQuests, questId) end

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
        JourneyPage = QuestieLoader:ImportModule("JourneyPage")
        JourneyTree = QuestieLoader:ImportModule("JourneyTree")

        listArea, detailsArea = CreateFrame("Frame", nil, UIParent), CreateFrame("Frame", nil, UIParent)
        panes = {list = {contentArea = listArea}, details = {contentArea = detailsArea}}
        nodes = {
            {value = "available", text = "Available Quests", children = {{value = WOLVES, text = "Wolves"}, {value = KOBOLDS, text = "Kobolds"}}},
            {value = "npcs", text = "NPCs", children = {{value = HOGGER, kind = "npc", text = "Hogger"}}},
            {value = "zone:40", text = "Westfall", source = "zone:40"},
        }
        loads, openedSources, shownDetails = 0, {}, 0
        -- Lists the nodes, with every header open
        ---@type JourneyPage.Content
        content = {
            Load = function(loadedPage)
                loads = loads + 1
                for _, node in ipairs(nodes) do
                    JourneyTree.Expand(loadedPage.tree, node.value)
                end
                JourneyPage.SetNodes(loadedPage, nodes, "Nothing here")
            end,
            OnShowDetails = function() shownDetails = shownDetails + 1 end,
        }
    end)

    after_each(function()
        _G.Questie = originalQuestie
        ui.Restore()
    end)

    ---@return JourneyPage.Instance
    local function CreatePage()
        local created = JourneyPage.Create(panes, function(source) table.insert(openedSources, source) end, function() end)
        JourneyPage.SetContent(created, content, "zone:12")
        JourneyPage.SetShown(created, true)
        return created
    end

    local function Load()
        page = CreatePage()
        JourneyPage.Refresh(page)
        ui.RunUntilIdle()
    end

    ---@return table list The list of the page that is shown, with the rows on screen in rowFrames
    local function ShownList(parent)
        for _, list in ipairs(ui.FindByTemplate(parent, "WowScrollBoxList")) do
            if list:IsVisible() then
                return list
            end
        end
    end

    ---@return string[]
    local function ListTexts()
        local texts = {}
        for _, row in ipairs(ShownList(listArea).rowFrames) do
            table.insert(texts, row.Label.text)
        end
        return texts
    end

    ---@return string[]
    local function SelectedTexts()
        local texts = {}
        for _, row in ipairs(ShownList(listArea).rowFrames) do
            if row.Background:IsShown() and row.Background.atlas == "Options_List_Active" then
                table.insert(texts, row.Label.text)
            end
        end
        return texts
    end

    ---@param text string
    local function Click(text)
        for _, row in ipairs(ShownList(listArea).rowFrames) do
            if row.Label.text == text then
                return row:Click()
            end
        end
        error("There is no row " .. text)
    end

    ---@return string[]
    local function Details()
        local texts = {}
        for _, row in ipairs(ShownList(detailsArea).rowFrames) do
            table.insert(texts, row.elementData.text)
        end
        return texts
    end

    describe("its list", function()
        -- A list can have thousands of quests, which would freeze the game
        it("should be filled by its content from the next frame on, a bit in each frame", function()
            page = CreatePage()

            JourneyPage.Refresh(page)
            assert.are.equal(0, loads)

            ui.RunUntilIdle()
            assert.are.equal(1, loads)
            assert.are_same({"Available Quests", "Wolves", "Kobolds", "NPCs", "Hogger", "Westfall"}, ListTexts())
        end)

        it("should be filled once when it is refreshed again before it was filled", function()
            page = CreatePage()

            JourneyPage.Refresh(page)
            JourneyPage.Refresh(page)
            ui.RunUntilIdle()

            assert.are.equal(1, loads)
        end)

        it("should say so while there is nothing in it", function()
            local listed = nodes
            nodes = {}

            Load()
            local emptyText = ui.FindAll(listArea, function(frame) return frame.text == "Nothing here" end)[1]
            assert.is_true(emptyText:IsVisible())

            nodes = listed
            JourneyPage.Refresh(page)
            ui.RunUntilIdle()
            assert.is_false(emptyText:IsVisible())
        end)
    end)

    describe("the details", function()
        before_each(function()
            Load()
        end)

        it("should show a quest that is clicked, and offer it to the chat", function()
            Click("Kobolds")

            assert.are_same({"Quest 8 is available"}, Details())
            assert.are_same({"Kobolds"}, SelectedTexts())
            assert.are_same({KOBOLDS}, linkedQuests)
        end)

        it("should show an NPC that is clicked, which is no quest for the chat", function()
            Click("Hogger")

            assert.are_same({"npc 448"}, Details())
            assert.are_same({}, linkedQuests)
        end)

        it("should show nothing for a quest that isn't in the database", function()
            JourneyPage.Select(page, {kind = "quest", id = 404})

            assert.are_same({}, Details())
        end)

        it("should show what only the content knows, from the content", function()
            content.GetRows = function(_, selection)
                return selection.kind == "faction" and {{type = "text", text = "Faction " .. selection.id}} or nil
            end

            JourneyPage.Select(page, {kind = "faction", id = 72})
            assert.are_same({"Faction 72"}, Details())

            JourneyPage.Select(page, {kind = "quest", id = WOLVES})
            assert.are_same({"Quest 7 is available"}, Details())
        end)

        it("should be shown again when what they show changes, like a quest that was completed", function()
            Click("Wolves")

            quests[WOLVES].state = "completed"
            updateQuestDetails()

            assert.are_same({"Quest 7 is completed"}, Details())
        end)

        it("should tell the content when they show something else, but not when the same is shown again", function()
            Click("Wolves")
            shownDetails = 0

            updateQuestDetails()
            assert.are.equal(0, shownDetails)

            Click("Kobolds")
            assert.are.equal(1, shownDetails)
        end)

        it("should mark what is selected in the list, and nothing when it isn't there", function()
            JourneyPage.Select(page, {kind = "quest", id = KOBOLDS})
            assert.are_same({"Kobolds"}, SelectedTexts())

            JourneyPage.Select(page, {kind = "npc", id = 299})
            assert.are_same({}, SelectedTexts())
            assert.are_same({"npc 299"}, Details())
        end)

        -- A quest and an NPC can have the same ID
        it("should mark only the entry of the same kind", function()
            nodes[2].children[1].value = WOLVES
            JourneyPage.Refresh(page)
            ui.RunUntilIdle()

            JourneyPage.Select(page, {kind = "npc", id = WOLVES})

            assert.are_same({"Hogger"}, SelectedTexts())
        end)
    end)

    describe("an entry that leads somewhere else", function()
        it("should be opened, while what was shown stays selected", function()
            Load()
            Click("Kobolds")

            Click("Westfall")

            assert.are_same({"zone:40"}, openedSources)
            assert.are_same({"Kobolds"}, SelectedTexts())
            assert.are_same({"Quest 8 is available"}, Details())
            assert.is_false(JourneyPage.CanGoBack(page))
        end)
    end)

    describe("back and forward", function()
        before_each(function()
            Load()
            Click("Wolves")
        end)

        it("should go back through what was clicked and opened, and forward again", function()
            Click("Kobolds")
            JourneyPage.Open(page, "npc", 299)

            JourneyPage.GoBack(page)
            assert.are_same({"Quest 8 is available"}, Details())
            assert.are_same({"Kobolds"}, SelectedTexts())

            JourneyPage.GoBack(page)
            assert.are_same({"Quest 7 is available"}, Details())
            assert.is_false(JourneyPage.CanGoBack(page))

            JourneyPage.GoForward(page)
            JourneyPage.GoForward(page)
            assert.are_same({"npc 299"}, Details())
            assert.is_false(JourneyPage.CanGoForward(page))
        end)

        it("should not go forward before something was gone back from", function()
            Click("Kobolds")

            assert.are_same({true, false}, {JourneyPage.CanGoBack(page), JourneyPage.CanGoForward(page)})
        end)

        it("should forget what was gone back from once something else is opened, like a browser", function()
            Click("Kobolds")
            JourneyPage.GoBack(page)

            JourneyPage.Open(page, "npc", 299)

            assert.is_false(JourneyPage.CanGoForward(page))
            JourneyPage.GoBack(page)
            assert.are_same({"Quest 7 is available"}, Details())
        end)

        it("should not remember what is opened again while it is shown", function()
            Click("Wolves")
            JourneyPage.Open(page, "quest", WOLVES)

            assert.is_false(JourneyPage.CanGoBack(page))
        end)

        it("should be forgotten when it is asked to", function()
            Click("Kobolds")
            JourneyPage.GoBack(page)

            JourneyPage.ForgetHistory(page)

            assert.are_same({false, false}, {JourneyPage.CanGoBack(page), JourneyPage.CanGoForward(page)})
            assert.are_same({"Quest 7 is available"}, Details())
        end)
    end)

    describe("being about something else", function()
        local other

        before_each(function()
            other = {Load = function(loadedPage)
                JourneyPage.SetNodes(loadedPage, {{value = 100, text = "The Defias Brotherhood"}}, "Nothing here")
            end}
        end)

        it("should leave nothing of what it showed", function()
            Load()
            Click("Wolves")
            Click("Kobolds")
            JourneyPage.SetProgress(page, "1 of 2 completed", 0.5)

            JourneyPage.SetContent(page, other, "zone:40")

            assert.are_same({}, Details())
            assert.is_nil(page.selection)
            assert.are_same({false, false}, {JourneyPage.CanGoBack(page), JourneyPage.CanGoForward(page)})
            assert.are_same({"", nil}, {page.progressText, page.progressShare})
            JourneyPage.Refresh(page)
            ui.RunUntilIdle()
            assert.are_same({"The Defias Brotherhood"}, ListTexts())
        end)

        -- A page is reused for the next tab, which must not get the quests of the one before
        it("should stop filling the list for what it was about before", function()
            page = CreatePage()
            JourneyPage.Refresh(page)

            JourneyPage.SetContent(page, other, "zone:40")
            ui.RunUntilIdle()

            assert.are.equal(0, loads)
            assert.are_same({}, ListTexts())
        end)
    end)

    describe("being hidden", function()
        it("should hide its list and its details, and keep them as they were", function()
            Load()
            Click("Kobolds")
            local otherPage = CreatePage()

            JourneyPage.SetShown(page, false)
            JourneyPage.SetShown(otherPage, true)
            JourneyPage.Refresh(otherPage)
            ui.RunUntilIdle()
            assert.are_same({}, SelectedTexts(), "the other page is shown")
            JourneyPage.SetShown(otherPage, false)
            JourneyPage.SetShown(page, true)

            assert.are_same({"Kobolds"}, SelectedTexts())
            assert.are_same({"Quest 8 is available"}, Details())
        end)
    end)
end)
