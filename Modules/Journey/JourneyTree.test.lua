dofile("setupTests.lua")

local FakeUI = dofile("cli/testData/options/FakeUI.lua")

describe("JourneyTree", function()
    ---@type JourneyTree
    local JourneyTree
    local ui
    local parent, tree, selected

    ---@return JourneyTreeNode[]
    local function CreateNodes()
        return {
            {value = "a", text = "Available", children = {
                {value = 7, text = "Wolves"},
                {value = 8, text = "Kobolds"},
            }},
            {value = "c", text = "Completed", children = {
                {value = 9, text = "Letters"},
            }},
            {value = "u", text = "Unobtainable", children = {}},
        }
    end

    ---@return string[]
    local function Texts()
        return ui.RowTexts(parent, 1)
    end

    ---@return string[]
    local function SelectedTexts()
        return ui.SelectedRowTexts(parent, 1)
    end

    ---@param text string
    local function Click(text)
        ui.ClickRow(parent, 1, text)
    end

    before_each(function()
        ui = FakeUI.Install()
        dofile("Modules/Libs/QuestieLoader.lua")
        dofile("Modules/Options/QuestieOptionsUtils.lua")
        dofile("Modules/Journey/JourneyIcon.lua")
        dofile("Modules/Journey/JourneyScrollBox.lua")
        dofile("Modules/Journey/JourneyList.lua")
        dofile("Modules/Journey/JourneyTree.lua")
        JourneyTree = QuestieLoader:ImportModule("JourneyTree")

        parent, selected = CreateFrame("Frame", nil, UIParent), {}
        tree = JourneyTree.Create(
            parent,
            function(node) table.insert(selected, node.value) end,
            function(node) return (node.value == 8 or node.children) and "complete" or nil end
        )
    end)

    after_each(function()
        ui.Restore()
    end)

    it("should only show headers at first", function()
        JourneyTree.SetNodes(tree, CreateNodes())

        assert.are_same({"Available", "Completed"}, Texts())
    end)

    it("should show what is below a header once it is clicked, and hide it again", function()
        JourneyTree.SetNodes(tree, CreateNodes())

        Click("Available")
        assert.are_same({"Available", "Wolves", "Kobolds", "Completed"}, Texts())

        Click("Available")
        assert.are_same({"Available", "Completed"}, Texts())
        assert.are_same({}, selected)
    end)

    it("should not show a header without anything below it", function()
        JourneyTree.SetNodes(tree, {
            {value = "a", text = "Available", children = {}},
            {value = "c", text = "Completed", children = {{value = 9, text = "Letters"}}},
        })
        assert.are_same({"Completed"}, Texts())

        JourneyTree.SetNodes(tree, CreateNodes())
        assert.are_same({"Available", "Completed"}, Texts())
    end)

    it("should show a header that had nothing below it for a while like before", function()
        JourneyTree.SetNodes(tree, CreateNodes())
        Click("Completed")
        JourneyTree.SetNodes(tree, {CreateNodes()[1]})

        JourneyTree.SetNodes(tree, CreateNodes())

        assert.are_same({"Available", "Completed", "Letters"}, Texts())
    end)

    it("should know whether it shows anything", function()
        assert.is_true(JourneyTree.IsEmpty(tree))

        JourneyTree.SetNodes(tree, {{value = "u", text = "Unobtainable", children = {}}})
        assert.is_true(JourneyTree.IsEmpty(tree))

        JourneyTree.SetNodes(tree, CreateNodes())
        assert.is_false(JourneyTree.IsEmpty(tree))
    end)

    it("should show headers and entries differently", function()
        JourneyTree.SetNodes(tree, CreateNodes())
        Click("Available")
        local available, wolves, kobolds, completed = unpack(ui.Rows(parent, 1))

        assert.are.equal("common-button-dropdown-open", available.Toggle.atlas)
        assert.are.equal("common-button-dropdown-closed", completed.Toggle.atlas)
        assert.is_false(wolves.Toggle:IsShown())
        assert.is_false(available.Icon:IsShown()) -- The toggle is there
        assert.is_false(wolves.Icon:IsShown())
        assert.is_true(kobolds.Icon:IsShown())
        assert.are.equal("complete", kobolds.Icon:GetTexture())
        assert.is_true(wolves.Label.points[2][4] > available.Label.points[2][4])
    end)

    it("should select an entry that is clicked", function()
        JourneyTree.SetNodes(tree, CreateNodes())
        Click("Available")

        Click("Wolves")
        assert.are_same({7}, selected)
        assert.are_same({"Wolves"}, SelectedTexts())

        Click("Kobolds")
        assert.are_same({7, 8}, selected)
        assert.are_same({"Kobolds"}, SelectedTexts())
    end)

    it("should keep what is expanded and selected when the entries change", function()
        JourneyTree.SetNodes(tree, CreateNodes())
        Click("Available")
        Click("Kobolds")

        local nodes = CreateNodes()
        table.remove(nodes[1].children, 1)
        JourneyTree.SetNodes(tree, nodes)

        assert.are_same({"Available", "Kobolds", "Completed"}, Texts())
        assert.are_same({"Kobolds"}, SelectedTexts())
        assert.are_same({8}, selected)
    end)

    it("should stay scrolled when the entries change or one is clicked", function()
        local nodes = {{value = "a", text = "Available", children = {}}, {value = "c", text = "Completed", children = {}}}
        for id = 1, 50 do table.insert(nodes[1].children, {value = id, text = "Quest " .. id}) end
        JourneyTree.Expand(tree, "a")
        JourneyTree.SetNodes(tree, nodes)
        JourneyTree.Select(tree, "a\00150")
        local textsBefore = Texts()

        JourneyTree.SetNodes(tree, nodes)
        assert.are_same(textsBefore, Texts())

        Click("Quest 45")
        assert.are_same(textsBefore, Texts())
    end)

    it("should stay scrolled when a header is clicked", function()
        local nodes = {{value = "a", text = "Available", children = {}}, {value = "c", text = "Completed", children = {}}}
        for id = 1, 50 do table.insert(nodes[1].children, {value = id, text = "Quest " .. id}) end
        for id = 51, 90 do table.insert(nodes[2].children, {value = id, text = "Quest " .. id}) end
        JourneyTree.Expand(tree, "a")
        JourneyTree.SetNodes(tree, nodes)
        ui.FindByTemplate(parent, "WowScrollBoxList")[1]:ScrollToElementDataIndex(52)
        local firstText = Texts()[1]
        assert.are.equal("Quest 32", firstText)

        Click("Completed")

        assert.are.equal(firstText, Texts()[1])
        assert.are.equal(92, ui.FindByTemplate(parent, "WowScrollBoxList")[1].dataProvider.size)
    end)

    describe("FindPath", function()
        it("should find an entry below a collapsed header", function()
            JourneyTree.SetNodes(tree, CreateNodes())

            assert.are.equal("c\0019", JourneyTree.FindPath(tree, function(node) return node.value == 9 end))
        end)

        it("should not find headers", function()
            JourneyTree.SetNodes(tree, CreateNodes())

            assert.is_nil(JourneyTree.FindPath(tree, function(node) return node.value == "u" end))
        end)

        it("should be able to go by the header", function()
            JourneyTree.SetNodes(tree, CreateNodes())

            assert.are.equal("c\0019", JourneyTree.FindPath(tree, function(_, header) return header.value == "c" end))
        end)
    end)

    describe("Select", function()
        before_each(function()
            JourneyTree.SetNodes(tree, CreateNodes())
        end)

        it("should show and mark an entry below a collapsed header", function()
            JourneyTree.Select(tree, "c\0019")

            assert.are_same({"Available", "Completed", "Letters"}, Texts())
            assert.are_same({"Letters"}, SelectedTexts())
            assert.is_true(JourneyTree.IsSelectionListed(tree))
        end)

        it("should not act as if the user clicked it", function()
            JourneyTree.Select(tree, "c\0019")

            assert.are_same({}, selected)
        end)

        it("should scroll to the entry", function()
            local nodes = {}
            for id = 1, 100 do table.insert(nodes, {value = id, text = "Quest " .. id}) end
            JourneyTree.SetNodes(tree, nodes)

            JourneyTree.Select(tree, "90")

            assert.are_same({"Quest 90"}, SelectedTexts())
        end)

        it("should be able to select nothing", function()
            JourneyTree.Select(tree, "c\0019")

            JourneyTree.Select(tree, nil)

            assert.are_same({}, SelectedTexts())
            assert.is_false(JourneyTree.IsSelectionListed(tree))
        end)

        it("should notice that the selected entry is gone", function()
            JourneyTree.Select(tree, "c\0019")

            JourneyTree.SetNodes(tree, {CreateNodes()[1]})

            assert.is_false(JourneyTree.IsSelectionListed(tree))
        end)
    end)

    describe("moving the selection", function()
        before_each(function()
            JourneyTree.SetNodes(tree, CreateNodes())
            Click("Available")
            Click("Wolves")
        end)

        it("should mark the other entry, but leave what is shown alone", function()
            local path = JourneyTree.FindPath(tree, function(node) return node.value == 9 end)

            JourneyTree.MoveSelection(tree, path)

            assert.are_same({"Available", "Wolves", "Kobolds", "Completed"}, Texts())
            assert.are_same({}, SelectedTexts())
            Click("Completed")
            assert.are_same({"Letters"}, SelectedTexts())
            assert.are_same({7}, selected)
        end)

        it("should be able to select nothing", function()
            JourneyTree.MoveSelection(tree, nil)

            assert.are_same({}, SelectedTexts())
            assert.is_false(JourneyTree.IsSelectionListed(tree))
        end)
    end)

    it("should keep its rows when as many are shown as before, because releasing them loses a click that is being made", function()
        JourneyTree.SetNodes(tree, CreateNodes())
        Click("Available")
        ui.rowsReleased = 0
        local nodes = CreateNodes()
        nodes[1].children[2].text = "Kobold Miners"

        JourneyTree.SetNodes(tree, nodes)

        assert.are.equal(0, ui.rowsReleased)
        assert.are_same({"Available", "Wolves", "Kobold Miners", "Completed"}, Texts())
    end)

    it("should expand several levels of headers that only come later", function()
        JourneyTree.Expand(tree, 2026, 11)

        JourneyTree.SetNodes(tree, {
            {value = 2026, text = 2026, children = {
                {value = 11, text = "November", children = {{value = 1, text = "Newest"}}},
                {value = 10, text = "October", children = {{value = 2, text = "Older"}}},
            }},
        })

        assert.are_same({"2026", "November", "Newest", "October"}, Texts())
    end)
end)
