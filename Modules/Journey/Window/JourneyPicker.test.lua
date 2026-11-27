dofile("setupTests.lua")

local FakeUI = dofile("cli/testData/options/FakeUI.lua")

describe("JourneyPicker", function()
    ---@type JourneyPicker
    local JourneyPicker
    local ui
    local parent, picker, choices, asked, picked

    before_each(function()
        ui = FakeUI.Install()
        dofile("Modules/Libs/QuestieLoader.lua")
        dofile("Modules/Journey/Window/JourneyPicker.lua")
        JourneyPicker = QuestieLoader:ImportModule("JourneyPicker")

        choices = {
            {text = "All Quests", value = "all"},
            {isDivider = true},
            {text = "Eastern Kingdoms", choices = {{text = "Elwynn Forest", value = "zone:12"}, {text = "Westfall", value = "zone:40"}}},
        }
        asked, picked = 0, {}
        parent = CreateFrame("Frame", nil, UIParent)
        picker = JourneyPicker.Create(parent, 200, function()
            asked = asked + 1
            return choices
        end, function(value) table.insert(picked, value) end)
    end)

    after_each(function()
        ui.Restore()
    end)

    ---@param entries table[]
    ---@return string[] texts "-" for a divider
    local function Texts(entries)
        local texts = {}
        for _, entry in ipairs(entries) do
            table.insert(texts, entry.isDivider and "-" or entry.text)
        end
        return texts
    end

    ---@param entries table[]
    ---@param text string
    ---@return table entry
    local function Find(entries, text)
        for _, entry in ipairs(entries) do
            if entry.text == text then
                return entry
            end
        end
        error("There is no choice " .. text)
    end

    -- The choices can be every zone there is
    it("should not ask for its choices before it is opened, also not each time it is shown", function()
        parent:Hide()
        parent:Show()

        assert.are.equal(0, asked)
    end)

    it("should show the choices, with those below others in a menu of their own", function()
        picker:OpenMenu()

        assert.are_same({"All Quests", "-", "Eastern Kingdoms"}, Texts(picker.menuEntries))
        assert.are_same({"Elwynn Forest", "Westfall"}, Texts(Find(picker.menuEntries, "Eastern Kingdoms").entries))
    end)

    it("should ask for its choices each time it is opened, because they can be others by then", function()
        picker:OpenMenu()
        picker:CloseMenu()
        choices = {{text = "Westfall", value = "zone:40"}}

        picker:OpenMenu()

        assert.are_same({"Westfall"}, Texts(picker.menuEntries))
    end)

    it("should keep its choices when the menu is made again while it is open", function()
        picker:OpenMenu()

        picker:GenerateMenu()

        assert.are_same({"All Quests", "-", "Eastern Kingdoms"}, Texts(picker.menuEntries))
    end)

    it("should say which choice was picked, also in a menu below another", function()
        picker:OpenMenu()
        picker:Pick(Find(picker.menuEntries, "All Quests"))

        picker:OpenMenu()
        Find(Find(picker.menuEntries, "Eastern Kingdoms").entries, "Westfall").select()

        assert.are_same({"all", "zone:40"}, picked)
    end)

    it("should not let a choice that only has others be picked itself", function()
        picker:OpenMenu()

        assert.is_nil(Find(picker.menuEntries, "Eastern Kingdoms").select)
    end)

    -- A continent has more zones than fit on the screen
    it("should scroll a menu that is too long, also one below another", function()
        picker:OpenMenu()

        assert.is_true(picker.menuEntries.scrollHeight > 0)
        assert.is_true(Find(picker.menuEntries, "Eastern Kingdoms").entries.scrollHeight > 0)
    end)
end)
