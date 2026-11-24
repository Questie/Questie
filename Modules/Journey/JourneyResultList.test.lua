dofile("setupTests.lua")

local FakeUI = dofile("cli/testData/options/FakeUI.lua")

describe("JourneyResultList", function()
    ---@type JourneyResultList
    local JourneyResultList
    local ui
    local parent, results, selected, suffix

    ---@return string[]
    local function Texts()
        return ui.RowTexts(parent, 1)
    end

    ---@return string[]
    local function SelectedTexts()
        return ui.SelectedRowTexts(parent, 1)
    end

    ---@return number[]
    local function CreateIds(count)
        local ids = {}
        for index = 1, count do ids[index] = index * 10 end
        return ids
    end

    before_each(function()
        ui = FakeUI.Install()
        dofile("Modules/Libs/QuestieLoader.lua")
        dofile("Modules/Options/QuestieOptionsUtils.lua")
        dofile("Modules/Journey/JourneyIcon.lua")
        dofile("Modules/Journey/JourneyScrollBox.lua")
        dofile("Modules/Journey/JourneyList.lua")
        dofile("Modules/Journey/JourneyResultList.lua")
        JourneyResultList = QuestieLoader:ImportModule("JourneyResultList")

        parent, selected, suffix = CreateFrame("Frame", nil, UIParent), {}, ""
        results = JourneyResultList.Create(
            parent,
            function(id) return "Result " .. id .. suffix end,
            function(id) return id == 33 and "checkmark" or nil end,
            function(id) table.insert(selected, id) end
        )
    end)

    after_each(function()
        ui.Restore()
    end)

    it("should show the results", function()
        JourneyResultList.Show(results, {7, 33, 299}, nil)

        assert.are_same({"Result 7", "Result 33", "Result 299"}, Texts())
    end)

    it("should show the icons of results that have one", function()
        JourneyResultList.Show(results, {7, 33}, nil)

        local without, with = unpack(ui.Rows(parent, 1))
        assert.is_false(without.Icon:IsShown())
        assert.are.equal("checkmark", with.Icon:GetTexture())
    end)

    it("should select a result that is clicked", function()
        JourneyResultList.Show(results, {7, 33, 299}, nil)

        ui.ClickRow(parent, 1, "Result 33")

        assert.are_same({33}, selected)
        assert.are_same({"Result 33"}, SelectedTexts())
    end)

    it("should start at the top with other results", function()
        JourneyResultList.Show(results, CreateIds(100), 900)
        JourneyResultList.ScrollToSelected(results)

        JourneyResultList.Show(results, CreateIds(100), 900)

        assert.are.equal("Result 10", Texts()[1])
    end)

    it("should stay scrolled with the same results, and show what changed about them", function()
        local ids = CreateIds(100)
        JourneyResultList.Show(results, ids, 900)
        JourneyResultList.ScrollToSelected(results)
        local firstText = Texts()[1]
        suffix = " (Complete)"

        JourneyResultList.Show(results, ids, 890)

        assert.are.equal(firstText .. " (Complete)", Texts()[1])
        assert.are_same({"Result 890 (Complete)"}, SelectedTexts())
    end)

    it("should scroll to the selected result, without acting as if it was clicked", function()
        JourneyResultList.Show(results, CreateIds(100), 900)

        JourneyResultList.ScrollToSelected(results)

        assert.are_same({"Result 900"}, SelectedTexts())
        assert.are_same({}, selected)
    end)

    it("should be able to have something selected that isn't a result", function()
        JourneyResultList.Show(results, {7, 33}, 90)
        JourneyResultList.ScrollToSelected(results)

        assert.are_same({}, SelectedTexts())
    end)
end)
