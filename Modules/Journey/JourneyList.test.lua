dofile("setupTests.lua")

local FakeUI = dofile("cli/testData/options/FakeUI.lua")

describe("JourneyList", function()
    ---@type JourneyList
    local JourneyList
    local ui
    local parent, list, contents, contentsAsked, clicked

    local SELECTED, HOVERED = "Options_List_Active", "Options_List_Hover"

    before_each(function()
        ui = FakeUI.Install()
        dofile("Modules/Libs/QuestieLoader.lua")
        dofile("Modules/Options/QuestieOptionsUtils.lua")
        dofile("Modules/Journey/JourneyIcon.lua")
        dofile("Modules/Journey/JourneyScrollBox.lua")
        dofile("Modules/Journey/JourneyList.lua")
        JourneyList = QuestieLoader:ImportModule("JourneyList")

        parent, contents, contentsAsked, clicked = CreateFrame("Frame", nil, UIParent), {}, 0, {}
        list = JourneyList.Create(parent, function(index)
            contentsAsked = contentsAsked + 1
            return contents[index] or {text = "Row " .. index, isSelected = false}
        end, function(index) table.insert(clicked, index) end)
    end)

    after_each(function()
        ui.Restore()
    end)

    ---@param content JourneyList.Content
    ---@return table row
    local function ShowRow(content)
        contents[1] = content
        JourneyList.SetCount(list, 1, true)
        return ui.Rows(parent, 1)[1]
    end

    ---@param row table
    ---@return string? atlas Nil when the row doesn't stand out
    local function Background(row)
        return row.Background:IsShown() and row.Background.atlas or nil
    end

    ---@param region table
    ---@return number x Where it is in its row
    local function GetX(region)
        for index = 1, #region.points do
            local _, _, relativePoint, x = region:GetPoint(index)
            if relativePoint == "LEFT" then return x end
        end
    end

    it("should show as many rows as it is told", function()
        JourneyList.SetCount(list, 3, false)

        assert.are_same({"Row 1", "Row 2", "Row 3"}, ui.RowTexts(parent, 1))
    end)

    it("should only ask for the content of rows on screen, because there can be tens of thousands", function()
        JourneyList.SetCount(list, 30000, false)

        assert.are.equal(20, contentsAsked)
    end)

    it("should say which row was clicked, also after it was reused", function()
        JourneyList.SetCount(list, 100, false)
        ui.Rows(parent, 1)[2]:Click()
        JourneyList.ScrollTo(list, 50)

        ui.ClickRow(parent, 1, "Row 50")

        assert.are_same({2, 50}, clicked)
    end)

    it("should be clicked once by a double-click", function()
        local row = ShowRow({text = "Wolves", isSelected = false})

        row:Click()
        row.scripts.OnDoubleClick(row)

        assert.are_same({1}, clicked)
    end)

    it("should start at the top, or stay scrolled", function()
        JourneyList.SetCount(list, 100, false)
        JourneyList.ScrollTo(list, 50)
        local texts = ui.RowTexts(parent, 1)

        JourneyList.SetCount(list, 101, true)
        assert.are_same(texts, ui.RowTexts(parent, 1))

        JourneyList.SetCount(list, 101, false)
        assert.are.equal("Row 1", ui.RowTexts(parent, 1)[1])
    end)

    it("should bring its rows up to date", function()
        ShowRow({text = "Wolves", isSelected = false})
        contents[1] = {text = "Wolves (Complete)", isSelected = true}

        JourneyList.Update(list)

        assert.are_same({"Wolves (Complete)"}, ui.SelectedRowTexts(parent, 1))
    end)

    it("should reuse the frames of rows", function()
        JourneyList.SetCount(list, 100, false)
        local frameCount = #ui.frames

        for index = 10, 100, 10 do
            JourneyList.SetCount(list, index, true)
            JourneyList.ScrollTo(list, index)
        end

        assert.are.equal(frameCount, #ui.frames)
    end)

    describe("a row", function()
        it("should look selected, hovered or neither", function()
            local row = ShowRow({text = "Wolves", isSelected = false})
            assert.is_nil(Background(row))

            row.scripts.OnEnter(row)
            assert.are.equal(HOVERED, Background(row))

            ui.mouseFocus = row
            row = ShowRow({text = "Wolves", isSelected = true})
            assert.are.equal(SELECTED, Background(row))

            row.scripts.OnLeave(row)
            assert.are.equal(SELECTED, Background(row))
        end)

        it("should only look hovered with other content when the mouse is still over it", function()
            local row = ShowRow({text = "Wolves", isSelected = false})
            row.scripts.OnEnter(row)

            ui.mouseFocus = row
            assert.are.equal(HOVERED, Background(ShowRow({text = "Kobolds", isSelected = false})))

            ui.mouseFocus = nil
            assert.is_nil(Background(ShowRow({text = "Murlocs", isSelected = false})))
        end)

        it("should show its whole text while it doesn't fit", function()
            local row = ShowRow({text = "Wolves", isSelected = false})
            row.scripts.OnEnter(row)
            assert.is_false(GameTooltip:IsShown())
            row.scripts.OnLeave(row)

            ui.isTextTruncated = true
            row.scripts.OnEnter(row)
            assert.are.equal("Wolves", GameTooltip.text)
            assert.are.equal(row, GameTooltip.owner)
            assert.is_true(GameTooltip:IsShown())

            row.scripts.OnLeave(row)
            assert.is_false(GameTooltip:IsShown())
        end)

        describe("note", function()
            -- FakeUI makes each character 7 wide. The text of a row starts 22 from its left, and its note ends 8 from its right.
            local QUEST = "Supplies to Private Thorsen" -- 189 wide
            local XP = "1,250 xp" -- 56 wide, and 10 between it and the name

            ---@param row table
            ---@return number x Of the right edge of the name, from the right edge of the row
            local function LabelRight(row)
                for index = 1, #row.Label.points do
                    local point, _, _, x = row.Label:GetPoint(index)
                    if point == "RIGHT" then return x end
                end
            end

            it("should be next to the name while both fit", function()
                list:SetWidth(22 + 189 + 10 + 56 + 8)
                local row = ShowRow({text = QUEST, note = XP, isSelected = false})

                assert.is_true(row.Note:IsShown())
                assert.are.equal(XP, row.Note.text)
                assert.are.equal(-8 - 56 - 10, LabelRight(row))
            end)

            it("should be left out rather than cut off the name", function()
                list:SetWidth(22 + 189 + 10 + 56 + 8 - 1)
                local row = ShowRow({text = QUEST, note = XP, isSelected = false})

                assert.is_false(row.Note:IsShown())
                assert.are.equal(-8, LabelRight(row))
            end)

            it("should be in the tooltip while it is left out", function()
                list:SetWidth(200)
                local row = ShowRow({text = QUEST, note = XP, isSelected = false})

                row.scripts.OnEnter(row)

                assert.is_true(GameTooltip:IsShown())
                assert.are.equal(QUEST, GameTooltip.text)
                assert.are_same({XP}, GameTooltip.lines)
            end)

            it("should be shown or left out again when the list gets wider or narrower", function()
                list:SetWidth(400)
                local row = ShowRow({text = QUEST, note = XP, isSelected = false})
                assert.is_true(row.Note:IsShown())

                list:SetWidth(200)
                assert.is_false(row.Note:IsShown())

                list:SetWidth(400)
                assert.is_true(row.Note:IsShown())
            end)
        end)

        it("should show whether it can be collapsed", function()
            local row = ShowRow({text = "Wolves", isSelected = false})
            assert.is_false(row.Toggle:IsShown())

            ShowRow({text = "Available", isSelected = false, isCollapsed = true})
            assert.is_true(row.Toggle:IsShown())
            assert.are.equal("Interface\\Buttons\\UI-PlusButton-Up", row.Toggle.texture)

            ShowRow({text = "Available", isSelected = false, isCollapsed = false})
            assert.is_true(row.Toggle:IsShown())
            assert.are.equal("Interface\\Buttons\\UI-MinusButton-Up", row.Toggle.texture)
        end)

        it("should tell headers apart by their font", function()
            assert.are.equal("GameFontNormal", ShowRow({text = "Available", isSelected = false, isCollapsed = false}).Label.fontObject)
            assert.are.equal("GameFontHighlight", ShowRow({text = "Wolves", isSelected = false}).Label.fontObject)
        end)

        it("should not keep the icon of what it showed before", function()
            local row = ShowRow({text = "Kobolds", isSelected = false, icon = "complete"})
            assert.is_true(row.Icon:IsShown())
            assert.are.equal("complete", row.Icon:GetTexture())

            ShowRow({text = "Wolves", isSelected = false})
            assert.is_false(row.Icon:IsShown())
        end)

        it("should be below the text of its header, with its icon below the toggle", function()
            for depth = 0, 1 do
                local row = ShowRow({text = "Available", isSelected = false, isCollapsed = false, depth = depth})
                local toggleCenter, label = GetX(row.Toggle) + row.Toggle:GetWidth() / 2, GetX(row.Label)

                ShowRow({text = "Wolves", isSelected = false, icon = "complete", depth = depth + 1})

                assert.are.equal(label, GetX(row.Label))
                assert.is_true(math.abs(GetX(row.Icon) - toggleCenter) <= 1)
            end
        end)

        it("should move everything to the right the deeper it is, and back", function()
            local row = ShowRow({text = "Wolves", isSelected = false})
            local toggle, icon, label = GetX(row.Toggle), GetX(row.Icon), GetX(row.Label)

            ShowRow({text = "Wolves", isSelected = false, depth = 2})
            local distance = GetX(row.Label) - label
            assert.is_true(distance > 0)
            assert.are_same({toggle + distance, icon + distance}, {GetX(row.Toggle), GetX(row.Icon)})

            ShowRow({text = "Wolves", isSelected = false})
            assert.are.equal(label, GetX(row.Label))
        end)
    end)
end)
