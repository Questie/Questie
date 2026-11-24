dofile("setupTests.lua")

local FakeUI = dofile("cli/testData/options/FakeUI.lua")

describe("JourneyQuestList", function()
    ---@type JourneyQuestList
    local JourneyQuestList
    ---@type JourneyIcon
    local JourneyIcon
    local ui
    local originalQuestie
    local canvas, list, insertedLinks

    before_each(function()
        ui = FakeUI.Install()
        originalQuestie = _G.Questie
        _G.Questie = {
            db = {profile = {}, char = {complete = {}, hidden = {}}},
            icons = {complete = "question mark", incomplete = "gray question mark", checkmark = "checkmark"},
            Error = function(_, message) error(message) end,
        }
        insertedLinks = {}

        dofile("Modules/Libs/QuestieLoader.lua")
        dofile("Localization/l10n.lua")
        dofile("Modules/Libs/ThreadLib.lua")
        QuestieLoader:ImportModule("QuestieDB").GetQuest = function(id)
            return id ~= 404 and {Id = id, name = "Quest " .. id} or nil
        end
        QuestieLoader:ImportModule("JourneyQuestDetails").GetRows = function(quest)
            return {{type = "heading", text = "Details of " .. quest.name}}
        end
        QuestieLoader:ImportModule("ActiveQuests").Get = function() end
        QuestieLoader:ImportModule("JourneyLinks").TryInsertIntoChat = function(id) table.insert(insertedLinks, id) end

        dofile("Modules/Options/QuestieOptionsUtils.lua")
        dofile("Modules/Options/QuestieOptionsControls.lua")
        dofile("Modules/Journey/JourneyThread.lua")
        dofile("Modules/Journey/JourneyPanes.lua")
        dofile("Modules/Journey/JourneyIcon.lua")
        dofile("Modules/Journey/JourneyScrollBox.lua")
        dofile("Modules/Journey/JourneyList.lua")
        dofile("Modules/Journey/JourneyTree.lua")
        dofile("Modules/Journey/JourneyDetails.lua")
        dofile("Modules/Journey/JourneyQuestList.lua")
        JourneyQuestList = QuestieLoader:ImportModule("JourneyQuestList")
        JourneyIcon = QuestieLoader:ImportModule("JourneyIcon")

        canvas = CreateFrame("Frame", nil, UIParent)
        canvas:SetSize(1000, 500)
        list = JourneyQuestList.Create(canvas, 64)
    end)

    after_each(function()
        _G.Questie = originalQuestie
        ui.Restore()
    end)

    ---@param idsByCategory table<string, number[]>
    ---@return fun(): JourneyTreeNode[]
    local function Quests(idsByCategory)
        return function()
            local nodes = {}
            for _, category in ipairs({"b", "a", "c"}) do
                local children = {}
                for _, id in ipairs(idsByCategory[category] or {}) do
                    table.insert(children, {value = id, text = "Quest " .. id})
                end
                table.insert(nodes, {value = category, text = category, children = children})
            end
            return nodes
        end
    end

    ---@param source string
    ---@param idsByCategory table<string, number[]>
    local function Load(source, idsByCategory)
        JourneyQuestList.Load(list, source, Quests(idsByCategory))
        ui.RunUntilIdle()
    end

    ---@param text string
    local function Click(text)
        ui.ClickRow(canvas, 1, text)
    end

    ---@return string[]
    local function ListTexts()
        return ui.RowTexts(canvas, 1)
    end

    ---@return string[]
    local function SelectedTexts()
        return ui.SelectedRowTexts(canvas, 1)
    end

    ---@return string? text
    local function ShownDetails()
        local row = ui.Rows(canvas, 2)[1]
        return row and row.parts.heading.Title.text
    end

    it("should show the details of a quest that is clicked", function()
        Load("Elwynn", {a = {7, 8}})
        Click("a")

        Click("Quest 8")

        assert.are.equal("Details of Quest 8", ShownDetails())
        assert.are_same({"Quest 8"}, SelectedTexts())
        assert.are_same({8}, insertedLinks)
    end)

    it("should keep the quest open when the same quests are listed again", function()
        Load("Elwynn", {a = {7, 8}})
        Click("a")
        Click("Quest 8")

        Load("Elwynn", {a = {7, 8, 9}})

        assert.are.equal("Details of Quest 8", ShownDetails())
        assert.are_same({"Quest 8"}, SelectedTexts())
    end)

    it("should update the details of the open quest, which can have changed", function()
        Load("Elwynn", {a = {7, 8}})
        Click("a")
        Click("Quest 8")
        QuestieLoader:ImportModule("JourneyQuestDetails").GetRows = function()
            return {{type = "heading", text = "Is complete now"}}
        end

        Load("Elwynn", {a = {7, 8}})

        assert.are.equal("Is complete now", ShownDetails())
    end)

    it("should keep the details scrolled when the same quests are listed again", function()
        QuestieLoader:ImportModule("JourneyQuestDetails").GetRows = function()
            local rows = {{type = "heading", text = "Heading"}}
            for line = 1, 50 do rows[line + 1] = {type = "text", text = "Line " .. line} end
            return rows
        end
        Load("Elwynn", {a = {7}})
        Click("a")
        Click("Quest 7")
        ui.FindByTemplate(canvas, "WowScrollBoxList")[2]:ScrollToElementDataIndex(45)
        local firstText = ui.Rows(canvas, 2)[1].elementData.text

        Load("Elwynn", {a = {7}})

        assert.are.equal(firstText, ui.Rows(canvas, 2)[1].elementData.text)
    end)

    it("should leave a quest selected where the user clicked it, although it is in another category as well", function()
        Load("Elwynn", {b = {8}, c = {8}})
        Click("b")
        Click("Quest 8")

        Load("Elwynn", {b = {8}, c = {8}})

        assert.are_same({"b", "Quest 8", "c"}, ListTexts())
        assert.are_same({"Quest 8"}, SelectedTexts())
        Click("c")
        assert.are_same({"Quest 8"}, SelectedTexts()) -- And not twice
    end)

    it("should keep the quest selected in another category, without opening it or scrolling there", function()
        Load("Elwynn", {a = {7, 8}})
        Click("a")
        Click("Quest 8")

        Load("Elwynn", {a = {7}, c = {8}})

        assert.are_same({"a", "Quest 7", "c"}, ListTexts())
        assert.are.equal("Details of Quest 8", ShownDetails())
        Click("c")
        assert.are_same({"Quest 8"}, SelectedTexts())
    end)

    it("should keep the quest selected that comes back after it wasn't listed for a while", function()
        Load("Elwynn", {a = {7, 8}})
        Click("a")
        Click("Quest 8")
        Load("Elwynn", {a = {7}})
        assert.are_same({}, SelectedTexts())

        Load("Elwynn", {a = {7, 8}})

        assert.are_same({"Quest 8"}, SelectedTexts())
    end)

    it("should forget the quest when other quests are listed", function()
        Load("Elwynn", {a = {7, 8}})
        Click("a")
        Click("Quest 8")

        JourneyQuestList.Load(list, "Westfall", Quests({a = {20, 8}}))
        assert.are_same({}, ListTexts())
        assert.is_nil(ShownDetails())

        ui.RunUntilIdle()
        assert.are_same({"a", "Quest 20", "Quest 8"}, ListTexts())
        assert.are_same({}, SelectedTexts())
        assert.is_nil(ShownDetails())
    end)

    it("should only list the quests that were asked for last", function()
        ui.clockStep = 1 -- Every step takes too long
        local JourneyThread = QuestieLoader:ImportModule("JourneyThread")
        JourneyQuestList.Load(list, "Elwynn", function()
            for _ = 1, 5 do JourneyThread.YieldIfNeeded() end
            return Quests({a = {7}})()
        end)
        ui.RunFrame()

        JourneyQuestList.Load(list, "Westfall", Quests({a = {20}}))
        ui.RunUntilIdle()
        Click("a")

        assert.are_same({"a", "Quest 20"}, ListTexts())
    end)

    describe("without any quests", function()
        ---@return boolean
        local function SaysSo()
            return #ui.FindAll(canvas, function(frame) return frame.text == "No Quests found" and frame:IsVisible() end) == 1
        end

        it("should say so, until there are some", function()
            Load("Durotar", {})
            assert.is_true(SaysSo())
            assert.are_same({}, ListTexts())

            Load("Durotar", {a = {7}})
            assert.is_false(SaysSo())
        end)

        it("should not say so before it looked for them", function()
            assert.is_false(SaysSo())

            JourneyQuestList.Load(list, "Durotar", Quests({}))
            assert.is_false(SaysSo())

            ui.RunUntilIdle()
            JourneyQuestList.Load(list, "Elwynn", Quests({}))
            assert.is_false(SaysSo())
        end)

        it("should not say so while there is nothing to look for them in, like a zone", function()
            JourneyQuestList.Load(list, "nothing", function() return nil end)
            ui.RunUntilIdle()

            assert.is_false(SaysSo())
        end)
    end)

    describe("Select", function()
        it("should show a quest and where it is in the list", function()
            Load("Elwynn", {a = {7}, c = {8}})

            JourneyQuestList.Select(list, 8)

            assert.are.equal("Details of Quest 8", ShownDetails())
            assert.are_same({"Quest 8"}, SelectedTexts())
        end)

        it("should show a quest that isn't in the list", function()
            Load("Elwynn", {a = {7}})
            JourneyQuestList.Select(list, 7)

            JourneyQuestList.Select(list, 99)

            assert.are.equal("Details of Quest 99", ShownDetails())
            assert.are_same({}, SelectedTexts())
        end)

        it("should prefer the category that says more than that a quest leads to another one", function()
            Load("Elwynn", {b = {8}, c = {8}})

            JourneyQuestList.Select(list, 8)

            assert.are_same({"b", "c", "Quest 8"}, ListTexts())
        end)

        it("should find a quest that is only listed as leading to another one", function()
            Load("Elwynn", {b = {8}})

            JourneyQuestList.Select(list, 8)

            assert.are_same({"Quest 8"}, SelectedTexts())
        end)

        it("should select a quest that only gets listed later", function()
            JourneyQuestList.Load(list, "Elwynn", Quests({c = {8}}))
            JourneyQuestList.Select(list, 8)
            assert.are.equal("Details of Quest 8", ShownDetails())

            ui.RunUntilIdle()

            assert.are_same({"Quest 8"}, SelectedTexts())
        end)

        it("should show nothing about a quest that isn't in the database", function()
            JourneyQuestList.Select(list, 404)

            assert.is_nil(ShownDetails())
        end)
    end)

    describe("the icon of a quest", function()
        local questLog

        before_each(function()
            questLog = {}
            QuestieLoader:ImportModule("ActiveQuests").Get = function(id) return questLog[id] end
            QuestieLoader:ImportModule("QuestieDB").IsComplete = function(id) return questLog[id].isComplete end
        end)

        it("should be a checkmark once it is completed", function()
            assert.is_nil(JourneyQuestList.GetIcon(7))

            Questie.db.char.complete[7] = true

            assert.are.equal("checkmark", JourneyQuestList.GetIcon(7))
        end)

        it("should show whether a quest in the quest log is ready to turn in, also when it was completed before", function()
            Questie.db.char.complete[7] = true

            questLog[7] = {isComplete = 0}
            assert.are.equal("gray question mark", JourneyQuestList.GetIcon(7))

            questLog[7] = {isComplete = 1}
            assert.are.equal("question mark", JourneyQuestList.GetIcon(7))

            questLog[7] = {isComplete = -1} -- Failed
            assert.are.equal("gray question mark", JourneyQuestList.GetIcon(7))
        end)

        it("should show that the user hid it, whatever else it is", function()
            Questie.db.char.hidden[7] = true
            assert.are.equal(JourneyIcon.HIDDEN, JourneyQuestList.GetIcon(7))

            Questie.db.char.complete[7] = true
            assert.are.equal(JourneyIcon.HIDDEN, JourneyQuestList.GetIcon(7))

            questLog[7] = {isComplete = 0}
            assert.are.equal(JourneyIcon.HIDDEN, JourneyQuestList.GetIcon(7))

            Questie.db.char.hidden[7] = nil
            assert.are.equal("gray question mark", JourneyQuestList.GetIcon(7))
        end)

        it("should be in front of it, and come and go with the next loading", function()
            Load("Elwynn", {a = {7}})
            Click("a")
            assert.is_false(ui.Rows(canvas, 1)[2].Icon:IsShown())

            Questie.db.char.complete[7] = true
            Load("Elwynn", {a = {7}})
            assert.are.equal("checkmark", ui.Rows(canvas, 1)[2].Icon:GetTexture())
            assert.is_false(ui.Rows(canvas, 1)[1].Icon:IsShown())
        end)
    end)

    it("should know whether it contains a quest, also below a collapsed header", function()
        Load("Elwynn", {a = {7}})

        assert.is_true(JourneyQuestList.Contains(list, 7))
        assert.is_false(JourneyQuestList.Contains(list, 8))
    end)
end)
