dofile("setupTests.lua")

local FakeUI = dofile("cli/testData/options/FakeUI.lua")

describe("Advanced Search", function()
    local search
    local ui
    local originalQuestie, originalGetCursorInfo, originalClearCursor, originalHook, originalChatFrameUtil
    local QuestieSearch, l10n
    local canvas, searches, searchFrames, insertedLinks, changeCallback, cursor

    ---What each search finds
    local RESULTS = {
        wolf = {quest = {33, 7}, npc = {299}, object = {}, item = {2070}},
        wolves = {quest = {7}, npc = {299}, object = {}, item = {2070}},
        kobold = {quest = {}, npc = {6, 40}, object = {}, item = {}},
        gnoll = {quest = {}, npc = {98}, object = {}, item = {725}},
        nothing = {quest = {}, npc = {}, object = {}, item = {}},
    }

    before_each(function()
        ui = FakeUI.Install()
        originalQuestie, originalGetCursorInfo, originalClearCursor = _G.Questie, _G.GetCursorInfo, _G.ClearCursor
        _G.Questie = {
            db = {char = {}, profile = {enableTooltipsQuestID = true}},
            Colorize = function(_, text) return text end,
            Error = function(_, message) error(message) end,
        }
        cursor, searches, insertedLinks = nil, {}, {}
        _G.GetCursorInfo = function() return unpack(cursor or {}) end
        _G.ClearCursor = function() cursor = nil end

        dofile("Modules/Libs/QuestieLoader.lua")
        dofile("Localization/l10n.lua")
        dofile("Modules/Libs/ThreadLib.lua")
        dofile("Modules/Libs/utf8.lua")
        l10n = QuestieLoader:ImportModule("l10n")
        originalHook, originalChatFrameUtil = _G.hooksecurefunc, _G.ChatFrameUtil
        _G.ChatFrameUtil = {InsertLink = function() end}
        _G.hooksecurefunc = function(owner, name, hook) owner[name] = hook end
        dofile("Modules/Journey/JourneyLinkInput.lua")
        QuestieLoader:ImportModule("JourneyLinks").TryInsertIntoChat = function(id) table.insert(insertedLinks, id) end
        QuestieLoader:ImportModule("JourneyQuestList").GetIcon = function() end
        QuestieLoader:ImportModule("QuestieDB").GetQuest = function(id) return {Id = id} end
        QuestieLoader:ImportModule("JourneyQuestDetails").GetRows = function(quest)
            return {{type = "text", text = "Details of quest " .. quest.Id}}
        end
        QuestieLoader:ImportModule("JourneyEntityDetails").GetRows = function(kind, id, onChanged)
            changeCallback = onChanged
            return {{type = "text", text = "Details of " .. kind .. " " .. id}}
        end

        dofile("Modules/Options/QuestieOptionsUtils.lua")
        dofile("Modules/Options/QuestieOptionsControls.lua")
        dofile("Modules/Journey/JourneyThread.lua")
        dofile("Modules/Journey/JourneyPanes.lua")
        dofile("Modules/Journey/JourneyIcon.lua")
        dofile("Modules/Journey/JourneyScrollBox.lua")
        dofile("Modules/Journey/JourneyList.lua")
        dofile("Modules/Journey/JourneyResultList.lua")
        dofile("Modules/Journey/JourneyDetails.lua")
        dofile("Modules/Journey/QuestieSearch.lua")
        QuestieSearch = QuestieLoader:ImportModule("QuestieSearch")
        searchFrames = 0
        QuestieSearch.Search = function(kind, query)
            if kind == "quest" then
                table.insert(searches, query)
            end
            for _ = 1, searchFrames do coroutine.yield() end
            return (RESULTS[query] or RESULTS.nothing)[kind]
        end
        QuestieSearch.GetName = function(kind, id) return kind .. " " .. id end

        dofile("Modules/Journey/tabs/Search/SearchTab.lua")
        search = QuestieLoader:ImportModule("QuestieJourney").private.search
        canvas = CreateFrame("Frame", nil, UIParent)
        canvas:SetSize(1000, 500)
        search.ClearFocus() -- Reached by clicking the window, also before this tab was ever shown
        search.Build(canvas)
        search.OnSelected()
        search.Refresh()
    end)

    after_each(function()
        _G.Questie, _G.GetCursorInfo, _G.ClearCursor = originalQuestie, originalGetCursorInfo, originalClearCursor
        _G.hooksecurefunc, _G.ChatFrameUtil = originalHook, originalChatFrameUtil
        ui.Restore()
    end)

    ---@return table editBox
    local function SearchBox()
        return ui.FindByTemplate(canvas, "SearchBoxTemplate")[1]
    end

    ---@param text string
    local function Type(text)
        SearchBox():SetText(text)
        ui.RunUntilIdle()
    end

    ---@param text string The start of its text
    ---@return table tab
    local function Tab(text)
        for _, tab in ipairs(ui.FindByTemplate(canvas, "MinimalTabTemplate")) do
            if tab.Text.text:sub(1, #text) == text then
                return tab
            end
        end
    end

    ---@return string[]
    local function ResultTexts()
        return ui.RowTexts(canvas, 1)
    end

    ---@return string[]
    local function SelectedTexts()
        return ui.SelectedRowTexts(canvas, 1)
    end

    ---@return string? text
    local function Details()
        local row = ui.Rows(canvas, 2)[1]
        return row and row.elementData.text
    end

    describe("typing", function()
        it("should be possible right after the tab is selected", function()
            assert.is_true(SearchBox():HasFocus())
        end)

        it("should not start because something about the tab changed", function()
            SearchBox():ClearFocus()

            search.Refresh()

            assert.is_false(SearchBox():HasFocus())
        end)

        it("should say what can be searched for while nothing is typed", function()
            assert.are.equal("Quests, NPCs, Objects, Items", SearchBox().Instructions.text)
            assert.is_true(SearchBox().Instructions:IsShown())

            SearchBox():SetText("wolf")

            assert.is_false(SearchBox().Instructions:IsShown())
        end)

        it("should search without pressing Enter", function()
            Type("wolf")

            assert.are_same({"wolf"}, searches)
            assert.are_same({"quest 33 (33)", "quest 7 (7)"}, ResultTexts())
        end)

        it("should only search once for text that is typed in one go", function()
            for _, text in ipairs({"wol", "wolf", "wolfe", "wolf"}) do
                SearchBox():SetText(text)
            end
            ui.RunUntilIdle()

            assert.are_same({"wolf"}, searches)
        end)

        it("should wait until the user paused, but not for long", function()
            SearchBox():SetText("wolf")

            ui.RunFor(0.1)
            assert.are_same({}, searches)

            ui.RunFor(0.2)
            assert.are_same({"wolf"}, searches)
        end)

        it("should stop a search that is out of date", function()
            searchFrames = 20
            SearchBox():SetText("kobold")
            ui.RunFor(0.3)
            assert.are_same({"kobold"}, searches)
            searchFrames = 1

            Type("wolf")

            assert.are.equal("Quests (2)", Tab("Quests").Text.text)
        end)

        it("should leave the results before until all new ones are found", function()
            Type("wolf")
            searchFrames = 5
            SearchBox():SetText("kobold")

            for _ = 1, 20 do
                ui.RunFrame()
                assert.is_true((Tab("Quests").Text.text == "Quests (2)") ~= (Tab("NPCs").Text.text == "NPCs (2)"))
            end
        end)

        it("should keep the results while the text is too short to search for", function()
            Type("wolf")

            Type("wo")

            assert.are_same({"quest 33 (33)", "quest 7 (7)"}, ResultTexts())
        end)

        it("should search for three letters", function()
            Type("wol")

            assert.are_same({"wol"}, searches)
        end)

        it("should not search for text that was deleted meanwhile", function()
            SearchBox():SetText("wolf")

            Type("")

            assert.are_same({}, searches)
            assert.are_same({}, ResultTexts())
        end)

        it("should not search for text that was changed back meanwhile", function()
            Type("wolf")
            SearchBox():SetText("kobold")

            Type("wolf")

            assert.are_same({"wolf"}, searches)
        end)

        it("should go back to the results that are shown when the search for something else is running already", function()
            Type("wolf")
            searchFrames = 20
            SearchBox():SetText("kobold")
            ui.RunFor(0.3)

            Type("wolf")

            assert.are_same({"wolf", "kobold"}, searches)
            assert.are_same({"quest 33 (33)", "quest 7 (7)"}, ResultTexts())
        end)

        it("should not search for text that would match too much", function()
            Type("wo")

            assert.are_same({}, searches)
        end)

        for _, locale in ipairs({"koKR", "zhCN", "zhTW"}) do
            it("should search for shorter words in " .. locale, function()
                l10n.GetUILocale = function() return locale end

                Type("狼")
                assert.are_same({}, searches)

                Type("狼人")
                assert.are_same({"狼人"}, searches)
            end)
        end

        it("should count characters, not bytes", function()
            Type("äö")

            assert.are_same({}, searches)
        end)

        it("should search for text of any length with Enter, and stop typing", function()
            SearchBox():SetText("wo")
            SearchBox():PressEnter()
            ui.RunUntilIdle()

            assert.are_same({"wo"}, searches)
            assert.is_false(SearchBox():HasFocus())
        end)

        it("should not search a second time when Enter is pressed while it would search anyway", function()
            SearchBox():SetText("wolf")
            SearchBox():PressEnter()
            ui.RunUntilIdle()

            assert.are_same({"wolf"}, searches)
        end)

        it("should not search for nothing but spaces, not even with Enter", function()
            SearchBox():SetText("    ")
            SearchBox():PressEnter()
            ui.RunUntilIdle()

            assert.are_same({}, searches)
        end)

        it("should ignore the spaces and brackets around what is searched for", function()
            Type(" [wolf] ")

            assert.are_same({"wolf"}, searches)
        end)

        it("should show nothing anymore once the box is cleared", function()
            Type("wolf")
            ui.Rows(canvas, 1)[1]:Click()

            Type("")

            assert.are_same({}, ResultTexts())
            assert.is_nil(Details())
            assert.are.equal("Quests (0)", Tab("Quests").Text.text)
        end)
    end)

    describe("a link", function()
        for color, link in pairs({
            ["with a color"] = "|cff1eff00|Hitem:725::::::::60:::::|h[wolf]|h|r",
            ["with the color of a quality"] = "|cnIQ2:|Hitem:725::::::::60:::::|h[wolf]|h|r",
        }) do
            it(color .. " should be searched for by its name", function()
                Type(link)

                assert.are.equal("wolf", SearchBox():GetText())
                assert.are_same({"wolf"}, searches)
            end)
        end

        it("should replace what was typed before", function()
            SearchBox():SetText("kob")
            ChatFrameUtil.InsertLink("|cff1eff00|Hitem:725|h[wolf]|h|r")
            ui.RunUntilIdle()

            assert.are_same({"wolf"}, searches)
        end)

        it("should be told apart from text in brackets", function()
            Type("[wolf] and [kobold]")

            assert.are.equal("[wolf] and [kobold]", SearchBox():GetText())
        end)
    end)

    for _, script in ipairs({"OnReceiveDrag", "OnMouseDown"}) do
        it("should search for an item that is dropped on the box: " .. script, function()
            cursor = {"item", 725, "|cff1eff00|Hitem:725|h[wolf]|h|r"}

            SearchBox().scripts[script](SearchBox())
            ui.RunUntilIdle()

            assert.are_same({"wolf"}, searches)
            assert.is_nil(cursor)
        end)
    end

    it("should keep something else on the cursor", function()
        cursor = {"spell", 5}

        SearchBox().scripts.OnReceiveDrag(SearchBox())
        ui.RunUntilIdle()

        assert.are_same({}, searches)
        assert.are_same({"spell", 5}, cursor)
    end)

    describe("the kinds of results", function()
        it("should show how many there are, and grey out those without any", function()
            Type("wolf")

            for text, isEnabled in pairs({["Quests (2)"] = true, ["NPCs (1)"] = true, ["Objects (0)"] = false, ["Items (1)"] = true}) do
                assert.are.equal(isEnabled, Tab(text):IsEnabled())
            end
        end)

        it("should be switched by clicking", function()
            Type("wolf")

            Tab("NPCs"):Click()

            assert.are_same({"npc 299 (299)"}, ResultTexts())
            assert.is_true(Tab("NPCs").isSelected)
            assert.is_false(Tab("Quests").isSelected)
            assert.is_false(SearchBox():HasFocus())
        end)

        it("should show the icons of quests, but not for an NPC with the same ID", function()
            QuestieLoader:ImportModule("JourneyQuestList").GetIcon = function(id)
                return (id == 7 or id == 299) and "icon of quest " .. id or nil
            end
            Type("wolf")
            local quest33, quest7 = unpack(ui.Rows(canvas, 1))
            assert.is_false(quest33.Icon:IsShown())
            assert.are.equal("icon of quest 7", quest7.Icon:GetTexture())

            Tab("NPCs"):Click()
            assert.is_false(ui.Rows(canvas, 1)[1].Icon:IsShown())
        end)

        it("should show the first one with results when the shown one has none", function()
            Type("gnoll")

            assert.are_same({"npc 98 (98)"}, ResultTexts())
            assert.is_true(Tab("NPCs").isSelected)
        end)

        it("should stay on the shown one while it has results", function()
            Type("wolf")
            Tab("Items"):Click()

            Type("wolves")

            assert.are_same({"item 2070 (2070)"}, ResultTexts())
        end)
    end)

    it("should say so when nothing is found", function()
        Type("nothing")

        assert.are.equal("No Match for Search Results: nothing", Details())
        assert.are_same({}, ResultTexts())
    end)

    it("should only show IDs when the user wants to", function()
        Questie.db.profile.enableTooltipsQuestID = false

        Type("wolf")

        assert.are_same({"quest 33", "quest 7"}, ResultTexts())
    end)

    describe("a result", function()
        it("should show its details when it is clicked, and stop typing", function()
            Type("wolf")

            ui.Rows(canvas, 1)[2]:Click()

            assert.are.equal("Details of quest 7", Details())
            assert.are_same({"quest 7 (7)"}, SelectedTexts())
            assert.are_same({7}, insertedLinks)
            assert.is_false(SearchBox():HasFocus())
        end)

        it("should show details of its kind, and only put links to quests into the chat", function()
            Type("wolf")
            Tab("NPCs"):Click()

            ui.Rows(canvas, 1)[1]:Click()

            assert.are.equal("Details of npc 299", Details())
            assert.are_same({}, insertedLinks)
        end)

        it("should show its details again after they changed, still scrolled", function()
            local state = "isn't on the map"
            QuestieLoader:ImportModule("JourneyEntityDetails").GetRows = function(_, _, onChanged)
                changeCallback = onChanged
                local rows = {}
                for line = 1, 50 do rows[line] = {type = "text", text = line .. " " .. state} end
                return rows
            end
            Type("wolf")
            Tab("NPCs"):Click()
            ui.Rows(canvas, 1)[1]:Click()
            ui.FindByTemplate(canvas, "WowScrollBoxList")[2]:ScrollToElementDataIndex(45)
            state = "is on the map"

            changeCallback()
            assert.are.equal("26 is on the map", Details())

            search.Refresh()
            assert.are.equal("26 is on the map", Details())
        end)

        it("should stay open as long as it is found", function()
            Type("wolf")
            ui.Rows(canvas, 1)[2]:Click()

            Type("wolves")
            assert.are.equal("Details of quest 7", Details())

            Type("kobold")
            assert.is_nil(Details())
        end)

        it("should still be open when the canvas is shown again, with the results", function()
            Type("wolf")
            ui.Rows(canvas, 1)[2]:Click()

            search.Refresh()

            assert.are.equal("Details of quest 7", Details())
            assert.are_same({"quest 7 (7)"}, SelectedTexts())
        end)
    end)

    describe("with more results than fit", function()
        local ids

        before_each(function()
            ids = {}
            for index = 1, 100 do ids[index] = index end
            RESULTS.many = {quest = ids, npc = {}, object = {}, item = {}}
            Type("many")
            ui.FindByTemplate(canvas, "WowScrollBoxList")[1]:ScrollToElementDataIndex(70)
        end)

        it("should stay scrolled when the tab is shown again", function()
            local textsBefore = ResultTexts()

            search.Refresh()

            assert.are_same(textsBefore, ResultTexts())
        end)

        it("should stay scrolled when something else is opened", function()
            local textsBefore = ResultTexts()

            search.Open("npc", 299)

            assert.are_same(textsBefore, ResultTexts())
        end)

        it("should scroll to a result that is opened", function()
            search.Open("quest", 5)

            assert.are_same({"quest 5 (5)"}, SelectedTexts())
        end)
    end)

    describe("opening something", function()
        it("should select it when it is a result", function()
            Type("wolf")

            search.Open("npc", 299)

            assert.are.equal("Details of npc 299", Details())
            assert.are_same({"npc 299 (299)"}, SelectedTexts())
            assert.is_true(Tab("NPCs").isSelected)
        end)

        it("should keep the results when it isn't one of them", function()
            Type("wolf")

            search.Open("item", 725)

            assert.are.equal("Details of item 725", Details())
            assert.are_same({"quest 33 (33)", "quest 7 (7)"}, ResultTexts())
            assert.are_same({}, SelectedTexts())
        end)

        it("should not select a result of another kind with the same ID", function()
            Type("wolf")
            Tab("NPCs"):Click()

            search.Open("quest", 299)

            assert.are.equal("Details of quest 299", Details())
            assert.are_same({"npc 299 (299)"}, ResultTexts())
            assert.are_same({}, SelectedTexts())
        end)

        it("should work when the tab wasn't shown before", function()
            search.Open("npc", 99)

            ui.RunUntilIdle()

            assert.are.equal("Details of npc 99", Details())
        end)

        it("should leave it open when a search that was running finds other things", function()
            searchFrames = 5
            SearchBox():SetText("wolf")
            ui.RunFor(0.2)

            search.Open("npc", 99)
            ui.RunUntilIdle()

            assert.are.equal("Quests (2)", Tab("Quests").Text.text)
            assert.are.equal("Details of npc 99", Details())
        end)

        it("should close it once something else is searched for", function()
            search.Open("npc", 99)

            Type("nothing")

            assert.are.equal("No Match for Search Results: nothing", Details())
        end)

        it("should not keep the keyboard, because nobody asked for a search", function()
            search.Open("npc", 299)

            assert.is_false(SearchBox():HasFocus())
        end)
    end)

    it("should create nothing for more searches", function()
        for _ = 1, 2 do
            Type("wolf")
            ui.Rows(canvas, 1)[1]:Click()
            Tab("NPCs"):Click()
            ui.Rows(canvas, 1)[1]:Click()
            Type("kobold")
        end
        local frameCount = #ui.frames

        for _ = 1, 3 do
            Type("wolf")
            ui.Rows(canvas, 1)[1]:Click()
            Type("kobold")
            search.Refresh()
        end

        assert.are.equal(frameCount, #ui.frames)
    end)
end)
