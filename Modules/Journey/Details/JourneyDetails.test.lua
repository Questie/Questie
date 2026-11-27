dofile("setupTests.lua")

local FakeUI = dofile("cli/testData/options/FakeUI.lua")

describe("JourneyDetails", function()
    ---@type JourneyDetails
    local JourneyDetails
    local ui
    local originalQuestie
    local parent, details

    before_each(function()
        ui = FakeUI.Install()
        originalQuestie = _G.Questie
        _G.Questie = {IsForever = true, db = {profile = {}}, Colorize = function(_, text) return "<" .. text .. ">" end}

        dofile("Modules/Libs/QuestieLoader.lua")
        dofile("Localization/l10n.lua")
        dofile("Modules/Options/QuestieOptionsUtils.lua")
        dofile("Modules/Options/QuestieOptionsControls.lua")
        QuestieLoader:ImportModule("QuestieOptionsEngine").RefreshStates = function() end
        dofile("Modules/Journey/Window/JourneyIcon.lua")
        dofile("Modules/Journey/Window/JourneyScrollBox.lua")
        dofile("Modules/Journey/Details/JourneyDetails.lua")
        JourneyDetails = QuestieLoader:ImportModule("JourneyDetails")

        parent = CreateFrame("Frame", nil, UIParent)
        parent:SetSize(500, 400)
        details = JourneyDetails.Create(parent)
    end)

    after_each(function()
        _G.Questie = originalQuestie
        ui.Restore()
    end)

    ---@param rowIndex number
    ---@return table part What the row consists of
    local function Part(rowIndex)
        local row = ui.Rows(parent, 1)[rowIndex]
        return row.parts[row.elementData.type]
    end

    ---@param rowIndex number
    ---@return number
    local function RowHeight(rowIndex)
        local scrollBox = ui.FindByTemplate(parent, "WowScrollBoxList")[1]
        return scrollBox.view.calculateExtent(rowIndex, scrollBox.dataProvider.Find(rowIndex))
    end

    it("should show each type of row", function()
        JourneyDetails.SetRows(details, {
            {type = "heading", text = "Wolves"},
            {type = "caption", text = "Starts"},
            {type = "text", text = "Kill ten wolves."},
            {type = "gap", height = 10},
        })

        assert.are.equal("Wolves", Part(1).Title.text)
        assert.are.equal("Starts", Part(2).Title.text)
        assert.are.equal("Kill ten wolves.", Part(3).Text.text)
        assert.are.equal(10, RowHeight(4))
    end)

    it("should make rows high enough for their text, in its font and width", function()
        local long = string.rep("A long text with many words in it. ", 12)
        JourneyDetails.SetRows(details, {
            {type = "heading", text = long},
            {type = "text", text = long},
            {type = "text", text = long, font = "GameFontNormalMed1"},
            {type = "entity", text = long, title = long, icon = 1},
            {type = "entity", text = long},
        })

        assert.is_true(RowHeight(1) >= Part(1).Title:GetStringHeight())
        for index = 2, 3 do
            assert.is_true(RowHeight(index) >= Part(index).Text:GetStringHeight())
        end
        assert.is_true(RowHeight(3) > RowHeight(2))
        assert.is_true(RowHeight(4) >= Part(4).Title:GetStringHeight() + Part(4).Text:GetStringHeight())
        assert.is_true(RowHeight(5) >= Part(5).Text:GetStringHeight())
        -- But not much higher
        assert.is_true(RowHeight(2) < Part(2).Text:GetStringHeight() + 14)
    end)

    it("should not let text reach over the right edge", function()
        JourneyDetails.SetRows(details, {{type = "text", text = "Kill ten wolves."}})

        local left = Part(1).points[1][4]
        assert.is_true(left > 0)
        assert.is_true(left + Part(1).Text:GetWidth() <= details.scrollBox:GetWidth() - left)
    end)

    it("should only measure a row once, because scrolling asks for its height again and again", function()
        local measured = 0
        local row = setmetatable({type = "text"}, {__index = function(_, key)
            if key == "text" then
                measured = measured + 1
                return "Kill ten wolves."
            end
        end})
        JourneyDetails.SetRows(details, {row})
        local measuredBefore = measured

        for _ = 1, 10 do RowHeight(1) end

        assert.are.equal(measuredBefore, measured)
    end)

    it("should show only what a row consists of now when it is used for another type", function()
        JourneyDetails.SetRows(details, {{type = "heading", text = "Wolves"}})
        local row = ui.Rows(parent, 1)[1]

        JourneyDetails.SetRows(details, {{type = "text", text = "Kill ten wolves."}})

        assert.are.equal(row, ui.Rows(parent, 1)[1])
        assert.is_false(row.parts.heading:IsShown())
        assert.is_true(row.parts.text:IsShown())
    end)

    it("should reuse the frames of rows", function()
        local rows = {
            {type = "heading", text = "Wolves"},
            {type = "text", text = "Kill ten wolves."},
            {type = "step", text = "Wolf", onClick = function() end},
            {type = "checkbox", text = "Complete", get = function() return true end},
            {type = "button", text = "Show", onClick = function() end},
            {type = "entity", text = "NPC ID: 299", npcId = 299},
            {type = "itemTooltip", itemId = 725},
        }
        JourneyDetails.SetRows(details, rows)
        JourneyDetails.SetRows(details, {})
        JourneyDetails.SetRows(details, rows)
        local frameCount = #ui.frames

        for _ = 1, 5 do
            JourneyDetails.SetRows(details, {})
            JourneyDetails.SetRows(details, rows)
        end

        assert.are.equal(frameCount, #ui.frames)
    end)

    it("should start at the top with new rows, but stay scrolled when the same ones are updated", function()
        local rows = {}
        for index = 1, 50 do rows[index] = {type = "text", text = "Line " .. index} end
        JourneyDetails.SetRows(details, rows)
        details.scrollBox:ScrollToElementDataIndex(40)
        local firstText = Part(1).Text.text

        JourneyDetails.SetRows(details, rows, true)
        assert.are.equal(firstText, Part(1).Text.text)

        JourneyDetails.SetRows(details, rows)
        assert.are.equal("Line 1", Part(1).Text.text)
    end)

    describe("that are updated", function()
        local isHidden

        ---@return JourneyDetails.Row[]
        local function CreateRows()
            local rows = {
                {type = "heading", text = "Wolves"},
                {type = "checkbox", text = "Hide", get = function() return isHidden end, set = function() end},
                {type = "text", text = "Complete: ", trailingIcon = "cross"},
                {type = "gap", height = 10},
                {type = "itemTooltip", itemId = 725},
                {type = "entity", title = "Young Wolf", text = "NPC ID: 299", npcId = 299, icon = 1},
            }
            return rows
        end

        before_each(function()
            isHidden = false
            ui.visibleRows = 10
            JourneyDetails.SetRows(details, CreateRows())
            ui.rowsReleased = 0
        end)

        -- Otherwise portraits are loaded again, and a click that is being made is lost
        it("should stay as they are when nothing about them changed", function()
            local modelSets = Part(6).Model.modelSets

            JourneyDetails.SetRows(details, CreateRows(), true)

            assert.are.equal(0, ui.rowsReleased)
            assert.are.equal(modelSets, Part(6).Model.modelSets)
        end)

        it("should show whether a checkbox is checked now", function()
            isHidden = true

            JourneyDetails.SetRows(details, CreateRows(), true)

            assert.is_true(Part(2).control.widget:GetChecked())
        end)

        it("should be shown again when there is another row", function()
            local rows = CreateRows()
            table.insert(rows, {type = "text", text = "Doable: yes"})

            JourneyDetails.SetRows(details, rows, true)

            assert.are.equal("Doable: yes", Part(7).Text.text)
        end)

        for name, change in pairs({
            ["a text"] = {row = 1, field = "text", value = "Boars"},
            ["an icon behind a text"] = {row = 3, field = "trailingIcon", value = "checkmark"},
            ["a font"] = {row = 3, field = "font", value = "GameFontNormalMed1"},
            ["a gap"] = {row = 4, field = "height", value = 20},
            ["an item"] = {row = 5, field = "itemId", value = 726},
            ["a title"] = {row = 6, field = "title", value = "Wolf"},
            ["an NPC"] = {row = 6, field = "npcId", value = 300},
            ["a picture"] = {row = 6, field = "icon", value = 2},
            ["a type"] = {row = 1, field = "type", value = "text"},
        }) do
            it("should be shown again when " .. name .. " changed", function()
                local rows = CreateRows()
                rows[change.row][change.field] = change.value

                JourneyDetails.SetRows(details, rows, true)

                assert.are.equal(rows[change.row], ui.Rows(parent, 1)[change.row].elementData)
            end)
        end
    end)

    describe("a row that is used for something else", function()
        it("should show whether the other checkbox is checked", function()
            JourneyDetails.SetRows(details, {{type = "checkbox", text = "Hide", get = function() return true end, set = function() end}})

            JourneyDetails.SetRows(details, {{type = "checkbox", text = "Show", get = function() return false end, set = function() end}})

            assert.are.equal("Show", Part(1).control.titleFrame.text)
            assert.is_false(Part(1).control.widget:GetChecked())
        end)

        it("should have enough space for a longer heading", function()
            details.scrollBox:SetWidth(500)
            JourneyDetails.SetRows(details, {{type = "heading", text = "Wolf"}})
            local width = Part(1).Title:GetWidth()

            JourneyDetails.SetRows(details, {{type = "heading", text = "Wolves and Boars"}})

            assert.are.equal(4 * (width - 1), Part(1).Title:GetWidth() - 1)
        end)

        it("should have the usual font again", function()
            JourneyDetails.SetRows(details, {{type = "text", text = "Wolves", font = "GameFontNormalMed1"}})
            assert.are.equal("GameFontNormalMed1", Part(1).Text.fontObject)

            JourneyDetails.SetRows(details, {{type = "text", text = "Wolves"}})

            assert.are.equal("GameFontHighlight", Part(1).Text.fontObject)
        end)

        it("should only keep space for a title there is", function()
            JourneyDetails.SetRows(details, {{type = "entity", title = "Young Wolf", text = "NPC ID: 299"}})
            assert.are.equal(Part(1).Title, (select(2, Part(1).Text:GetPoint(1))))

            JourneyDetails.SetRows(details, {{type = "entity", text = "NPC ID: 299"}})

            assert.are.equal(Part(1), (select(2, Part(1).Text:GetPoint(1))))
        end)
    end)

    it("should show the same again from the top when it belongs to something else", function()
        JourneyDetails.SetRows(details, {{type = "text", text = "Wolves"}})
        ui.rowsReleased = 0

        JourneyDetails.SetRows(details, {{type = "text", text = "Wolves"}})

        assert.are.equal(1, ui.rowsReleased)
    end)

    it("should wrap the text again when there is more or less space for it, and stay scrolled", function()
        local rows = {}
        for index = 1, 50 do rows[index] = {type = "text", text = index .. string.rep(" wolves", 30)} end
        JourneyDetails.SetRows(details, rows)
        details.scrollBox:ScrollToElementDataIndex(40)
        local firstText, width, height = Part(1).Text.text, Part(1).Text:GetWidth(), RowHeight(1)

        details.scrollBox:SetWidth(details.scrollBox:GetWidth() + 50)

        assert.are.equal(firstText, Part(1).Text.text)
        assert.are.equal(width + 50, Part(1).Text:GetWidth())
        assert.is_true(RowHeight(1) < height)
    end)

    describe("a text", function()
        ---@return number
        local function IconLeft()
            local _, relativeTo, _, x = Part(1).Icon:GetPoint(1)
            assert.are.equal(Part(1).Text, relativeTo)
            return x
        end

        it("should be followed by its icon, however long it is", function()
            for _, text in ipairs({"Complete: ", "Hidden by Questie: "}) do
                JourneyDetails.SetRows(details, {{type = "text", text = text, trailingIcon = "checkmark"}})

                assert.is_true(Part(1).Icon:IsShown())
                assert.are.equal("checkmark", Part(1).Icon:GetTexture())
                assert.is_true(IconLeft() >= Part(1).Text:GetStringWidth())
                assert.is_true(IconLeft() < Part(1).Text:GetStringWidth() + 10)
            end
        end)

        it("should not keep the icon of what its row showed before", function()
            JourneyDetails.SetRows(details, {{type = "text", text = "Complete: ", trailingIcon = "checkmark"}})

            JourneyDetails.SetRows(details, {{type = "text", text = "Quest ID: 7"}})

            assert.is_false(Part(1).Icon:IsShown())
        end)
    end)

    -- FakeUI makes each character 7 wide. A row is 8 narrower on both sides than the list.
    describe("a step", function()
        local QUEST, TAG = "Supplies to Private Thorsen", "this quest" -- 189 and 70 wide
        -- Its name starts 26 from the left, and its tag ends 8 from the right, 8 away from the name
        local FITTING_WIDTH = 2 * 8 + 26 + 189 + 8 + 70 + 8

        ---@return number x Of the right edge of the name, from the right edge of the row
        local function NameRight()
            for index = 1, #Part(1).Text.points do
                local point, _, _, x = Part(1).Text:GetPoint(index)
                if point == "RIGHT" then return x end
            end
        end

        it("should show its tag next to a name that fits with it", function()
            details.scrollBox:SetWidth(FITTING_WIDTH)
            JourneyDetails.SetRows(details, {{type = "step", text = QUEST, tag = TAG}})

            assert.is_true(Part(1).Note:IsShown())
            assert.are.equal(TAG, Part(1).Note.text)
            assert.are.equal(-8 - 70 - 8, NameRight())
        end)

        it("should leave out its tag rather than cut off the name", function()
            details.scrollBox:SetWidth(FITTING_WIDTH - 1)
            JourneyDetails.SetRows(details, {{type = "step", text = QUEST, tag = TAG}})

            assert.is_false(Part(1).Note:IsShown())
            assert.are.equal(-8, NameRight())
        end)

        it("should show its tag left of its small map, also in a row that had none before", function()
            details.scrollBox:SetWidth(500)
            JourneyDetails.SetRows(details, {{type = "step", text = "Wolf", tag = TAG}})
            JourneyDetails.SetRows(details, {{type = "step", text = "Wolf", tag = TAG, action = {tooltip = "Show on Map", onClick = function() end}}})

            local _, _, _, noteRight = Part(1).Note:GetPoint(1)
            local _, _, _, actionRight = Part(1).Action:GetPoint(1)
            assert.is_true(Part(1).Note:IsShown())
            assert.is_true(noteRight <= actionRight - Part(1).Action:GetWidth(), "The tag is under the small map")
            assert.is_true(NameRight() < noteRight - Part(1).Note:GetUnboundedStringWidth(), "The name reaches into the tag")
        end)
    end)

    describe("a page", function()
        local TITLE, TAG = "Welcome to the Jungle", "Dungeon" -- 147 and 49 wide
        -- The tag is 12 away from the title, and 4 from the right edge
        local FITTING_WIDTH = 2 * 8 + 147 + 12 + 49

        it("should show its tag next to a title that fits with it", function()
            details.scrollBox:SetWidth(FITTING_WIDTH)
            JourneyDetails.SetRows(details, {{type = "page", text = TITLE, tag = TAG}})

            assert.is_true(Part(1).Tag:IsShown())
            assert.are.equal(TAG, Part(1).Tag.text)
            assert.are.equal(TITLE, Part(1).Title.text)
            assert.are.equal(32, RowHeight(1))
        end)

        it("should take more lines for a long title rather than cut it off, and leave out its tag", function()
            details.scrollBox:SetWidth(2 * 8 + 100)
            JourneyDetails.SetRows(details, {{type = "page", text = TITLE, tag = TAG}})

            assert.is_false(Part(1).Tag:IsShown())
            assert.are.equal(100, Part(1).Title:GetWidth())
            assert.is_true(RowHeight(1) >= Part(1).Title:GetStringHeight() + 6)
            assert.is_true(RowHeight(1) > 32)
        end)

        it("should keep its height without a tag, while the title fits on one line", function()
            JourneyDetails.SetRows(details, {{type = "page", text = "Wolves"}})

            assert.is_false(Part(1).Tag:IsShown())
            assert.are.equal(32, RowHeight(1))
        end)
    end)

    describe("a step that leads somewhere", function()
        it("should do what its row says, also after the row was reused", function()
            local clicked = {}
            JourneyDetails.SetRows(details, {{type = "step", text = "Wolf", onClick = function() table.insert(clicked, "wolf") end}})
            JourneyDetails.SetRows(details, {{type = "step", text = "Boar", onClick = function() table.insert(clicked, "boar") end}})

            Part(1).Button:Click()

            assert.are_same({"boar"}, clicked)
        end)

        it("should show a tooltip, and hide it when it is clicked", function()
            JourneyDetails.SetRows(details, {{
                type = "step", text = "Wolf", onClick = function() end,
                showTooltip = function() GameTooltip:AddLine("Young Wolf") end,
            }})
            local button = Part(1).Button

            button.scripts.OnEnter(button)
            assert.are_same({"Young Wolf"}, GameTooltip.lines)
            assert.are.equal(button, GameTooltip.owner)
            assert.is_true(GameTooltip:IsShown())

            button:Click()
            assert.is_false(GameTooltip:IsShown())

            button.scripts.OnEnter(button)
            button.scripts.OnLeave(button)
            assert.is_false(GameTooltip:IsShown())
        end)
    end)

    describe("a checkbox", function()
        it("should show and change what it stands for", function()
            local isHidden = false
            JourneyDetails.SetRows(details, {{
                type = "checkbox", text = "Hide", get = function() return isHidden end, set = function() isHidden = not isHidden end,
            }})
            local checkbox = Part(1).control.widget
            assert.are.equal("Hide", Part(1).control.titleFrame.text)
            assert.is_false(checkbox:GetChecked())

            checkbox:Click()

            assert.is_true(isHidden)
        end)

        it("should explain itself in a tooltip", function()
            JourneyDetails.SetRows(details, {{
                type = "checkbox", text = "Hide", get = function() return true end,
                showTooltip = function() GameTooltip:AddLine("Hides the quest") end,
            }})

            Part(1).control.scripts.OnEnter(Part(1).control)

            assert.are_same({"Hides the quest"}, GameTooltip.lines)
            assert.is_true(GameTooltip:IsShown())
        end)

    end)

    it("should do what a button says", function()
        local clicks = 0
        JourneyDetails.SetRows(details, {{type = "button", text = "Show on Map", onClick = function() clicks = clicks + 1 end}})

        Part(1).control.widget:Click()

        assert.are.equal("Show on Map", Part(1).control.widget:GetText())
        assert.are.equal(1, clicks)
    end)

    for _, rowType in ipairs({"status", "entity"}) do
        it("should offer Blizzard's map button in a " .. rowType .. " that has a place to show, and leave room for it", function()
            local shown = 0
            JourneyDetails.SetRows(details, {{type = rowType, text = "Elwynn Forest"}})
            assert.is_false(Part(1).ShowMap:IsShown())
            local fullWidth = Part(1).Text:GetWidth()

            JourneyDetails.SetRows(details, {{type = rowType, text = "Elwynn Forest", onShowMap = function() shown = shown + 1 end}})
            Part(1).ShowMap:Click()

            assert.is_true(Part(1).ShowMap:IsShown())
            assert.are.equal(1, shown)
            assert.is_true(Part(1).Text:GetWidth() < fullWidth)
        end)
    end

    describe("an entity", function()
        local UNKNOWN_ICON = 134400

        it("should show the face of an NPC", function()
            ui.knownNpcs[299] = true

            JourneyDetails.SetRows(details, {{type = "entity", title = "Young Wolf", text = "NPC ID: 299", npcId = 299}})

            assert.are.equal("Young Wolf", Part(1).Title.text)
            assert.are.equal("NPC ID: 299", Part(1).Text.text)
            assert.are.equal(299, Part(1).Model.npcId)
            assert.is_true(Part(1).Model:IsVisible())
            assert.is_false(Part(1).Icon:IsShown())
        end)

        it("should show a placeholder until the client knows the NPC", function()
            JourneyDetails.SetRows(details, {{type = "entity", text = "NPC ID: 299", npcId = 299}})
            assert.are.equal(UNKNOWN_ICON, Part(1).Icon:GetTexture())
            assert.is_true(Part(1).Icon:IsShown())

            ui.knownNpcs[299] = true
            ui.RunUntilIdle()

            assert.is_false(Part(1).Icon:IsShown())
        end)

        it("should show a placeholder until the client knows the NPC, also after the face of another one", function()
            ui.knownNpcs[299] = true
            JourneyDetails.SetRows(details, {{type = "entity", text = "NPC ID: 299", npcId = 299}})
            JourneyDetails.SetRows(details, {{type = "entity", text = "NPC ID: 300", npcId = 300}})
            assert.is_true(Part(1).Icon:IsShown())

            ui.knownNpcs[300] = true
            ui.RunFor(0.3)

            assert.is_false(Part(1).Icon:IsShown())
            assert.are.equal(300, Part(1).Model.modelFile)
        end)

        it("should show a placeholder until the face is loaded, without asking again, which would load it again", function()
            ui.knownNpcs[299] = true
            ui.modelLoadSeconds = 0.5

            JourneyDetails.SetRows(details, {{type = "entity", text = "NPC ID: 299", npcId = 299}})
            ui.RunFor(0.4)
            assert.is_true(Part(1).Icon:IsShown())

            ui.RunFor(0.2)
            assert.is_false(Part(1).Icon:IsShown())
            assert.are.equal(1, Part(1).Model.modelSets)
        end)

        it("should stop asking for an NPC the server doesn't know", function()
            JourneyDetails.SetRows(details, {{type = "entity", text = "NPC ID: 1", npcId = 1}})

            ui.RunUntilIdle()

            assert.are.equal(50, Part(1).Model.modelSets)
            assert.is_true(Part(1).Icon:IsShown())
        end)

        it("should not ask right away, because the server needs some time", function()
            JourneyDetails.SetRows(details, {{type = "entity", text = "NPC ID: 1", npcId = 1}})

            ui.RunFor(0.05)

            assert.are.equal(1, Part(1).Model.modelSets)
        end)

        it("should not ask for an NPC that can't be seen anymore", function()
            JourneyDetails.SetRows(details, {{type = "entity", text = "NPC ID: 1", npcId = 1}})
            local model = Part(1).Model

            parent:Hide()
            ui.RunUntilIdle()

            assert.are.equal(1, model.modelSets)
        end)

        it("should only ask once at a time, however often the row is updated", function()
            local rows = {{type = "entity", text = "NPC ID: 1", npcId = 1}}
            for _ = 1, 5 do JourneyDetails.SetRows(details, rows) end

            ui.RunUntilIdle()

            assert.are.equal(5 + 49, Part(1).Model.modelSets)
        end)

        it("should lead somewhere, if its row says so", function()
            local clicks = 0
            JourneyDetails.SetRows(details, {{
                type = "entity", text = "NPC ID: 299", npcId = 299, onClick = function() clicks = clicks + 1 end,
                showTooltip = function() GameTooltip:AddLine("Young Wolf") end,
            }})
            local button = Part(1).Button
            assert.is_true(button.mouseEnabled)

            button.scripts.OnEnter(button)
            assert.are_same({"Young Wolf"}, GameTooltip.lines)
            button:Click()
            assert.are.equal(1, clicks)
            assert.is_false(GameTooltip:IsShown())

            JourneyDetails.SetRows(details, {{type = "entity", text = "NPC ID: 299", npcId = 299}})
            assert.is_false(Part(1).Button.mouseEnabled)
        end)

        it("should not keep the title of what the row showed before", function()
            JourneyDetails.SetRows(details, {{type = "entity", title = "Young Wolf", text = "NPC ID: 299"}})
            assert.is_true(Part(1).Title:IsShown())

            JourneyDetails.SetRows(details, {{type = "entity", text = "Object ID: 55"}})
            assert.is_false(Part(1).Title:IsShown())
        end)

        it("should not show an NPC that was asked for before the row was reused", function()
            JourneyDetails.SetRows(details, {{type = "entity", text = "NPC ID: 1", npcId = 1}})
            ui.knownNpcs[299] = true
            JourneyDetails.SetRows(details, {{type = "entity", text = "NPC ID: 299", npcId = 299}})

            ui.RunUntilIdle()

            assert.are.equal(299, Part(1).Model.npcId)
            assert.are.equal(2, Part(1).Model.modelSets)
        end)

        it("should show an icon instead of the NPC the row showed before", function()
            ui.knownNpcs[299] = true
            JourneyDetails.SetRows(details, {{type = "entity", text = "NPC ID: 299", npcId = 299}})

            JourneyDetails.SetRows(details, {{type = "entity", text = "Item ID: 725", icon = 1234}})

            assert.is_false(Part(1).Model:IsShown())
            assert.is_true(Part(1).Icon:IsShown())
            assert.are.equal(1234, Part(1).Icon:GetTexture())
        end)

        describe("badges", function()
            local START, FINISH = "available", "complete"

            ---@param badges string[]?
            ---@return table[] textures Those that are shown
            local function ShowBadges(badges)
                ui.knownNpcs[299] = true
                JourneyDetails.SetRows(details, {{type = "entity", text = "NPC ID: 299", npcId = 299, badges = badges}})
                local shown = {}
                for _, texture in ipairs(Part(1).Badges) do
                    if texture:IsShown() then table.insert(shown, texture) end
                end
                return shown
            end

            it("should show what an NPC does, and nothing of the row before", function()
                local both = ShowBadges({START, FINISH})
                assert.are_same({START, FINISH}, {both[1]:GetTexture(), both[2]:GetTexture()})

                local one = ShowBadges({FINISH})
                assert.are.equal(1, #one)
                assert.are.equal(FINISH, one[1]:GetTexture())

                assert.are.equal(0, #ShowBadges(nil))
            end)

            it("should only be tilted, away from each other, when there are two", function()
                assert.are.equal(0, ShowBadges({START})[1].rotation)

                local both = ShowBadges({START, FINISH})
                assert.is_true(both[1].rotation > 0 and both[2].rotation < 0)

                assert.are.equal(0, ShowBadges({START})[1].rotation)
            end)
        end)

        it("should use the whole width without a picture", function()
            JourneyDetails.SetRows(details, {{type = "entity", text = "Object ID: 55"}, {type = "entity", text = "Item", icon = 1}})

            assert.is_false(Part(1).Picture:IsShown())
            assert.is_true(Part(1).Text:GetWidth() > Part(2).Text:GetWidth())
        end)

        it("should be high enough for its picture", function()
            JourneyDetails.SetRows(details, {{type = "entity", text = "Item", icon = 1}})

            assert.is_true(RowHeight(1) >= Part(1).Picture:GetHeight())
        end)
    end)

    describe("an item tooltip", function()
        ---@return table tooltip
        local function Tooltip()
            return ui.FindAll(UIParent, function(frame) return frame.name == "QuestieJourneyItemTooltip" end)[1]
        end

        it("should be shown in the row, which becomes as high as it", function()
            JourneyDetails.SetRows(details, {{type = "itemTooltip", itemId = 725}})
            assert.are.equal(725, Tooltip().itemId)
            assert.are.equal(Part(1), Tooltip():GetParent())

            Tooltip():SetSize(200, 120)
            ui.RunUntilIdle()

            assert.are.equal(128, RowHeight(1))
        end)

        it("should grow without scrolling", function()
            local rows = {{type = "itemTooltip", itemId = 725}}
            for index = 2, 50 do rows[index] = {type = "text", text = "Line " .. index} end
            JourneyDetails.SetRows(details, rows)
            details.scrollBox:ScrollToElementDataIndex(40)
            local firstText = Part(1).Text.text

            Tooltip():SetSize(200, 150)
            ui.RunUntilIdle()

            assert.are.equal(firstText, Part(1).Text.text)
        end)

        it("should still have its height the next time the item is shown", function()
            JourneyDetails.SetRows(details, {{type = "itemTooltip", itemId = 725}})
            Tooltip():SetSize(200, 120)
            ui.RunUntilIdle()

            JourneyDetails.SetRows(details, {{type = "itemTooltip", itemId = 725}})

            assert.are.equal(128, RowHeight(1))
        end)

        it("should follow the height again and again", function()
            JourneyDetails.SetRows(details, {{type = "itemTooltip", itemId = 725}})

            for height = 100, 140, 20 do
                Tooltip():SetSize(200, height)
                ui.RunUntilIdle()
                assert.are.equal(height + 8, RowHeight(1))
            end
        end)

        it("should be updated for a while, because the client only loads all of it then", function()
            JourneyDetails.SetRows(details, {{type = "itemTooltip", itemId = 725}})
            Tooltip().itemId = nil

            ui.RunFor(0.6)
            assert.are.equal(725, Tooltip().itemId)

            Tooltip().itemId = nil
            ui.RunFor(2)
            assert.are.equal(725, Tooltip().itemId)
        end)

        it("should stop being updated after a while", function()
            JourneyDetails.SetRows(details, {{type = "itemTooltip", itemId = 725}})

            ui.RunUntilIdle()

            Tooltip().itemId = nil
            ui.RunFor(5)
            assert.is_nil(Tooltip().itemId)
        end)

        it("should not go back to the item that was shown before", function()
            JourneyDetails.SetRows(details, {{type = "itemTooltip", itemId = 725}})
            ui.RunFor(0.6)

            JourneyDetails.SetRows(details, {{type = "heading", text = "Linen Cloth"}, {type = "itemTooltip", itemId = 2589}})
            ui.RunUntilIdle()

            assert.are.equal(Part(2), Tooltip():GetParent())
            assert.are.equal(2589, Tooltip().itemId)
        end)

        it("should not go back to the item that was shown in the same row before", function()
            JourneyDetails.SetRows(details, {{type = "itemTooltip", itemId = 725}})
            ui.RunFor(0.3)

            JourneyDetails.SetRows(details, {{type = "itemTooltip", itemId = 2589}})
            ui.RunFor(0.3) -- The next update of the first one would be due

            assert.are.equal(2589, Tooltip().itemId)
        end)

        it("should not be updated while it can't be seen", function()
            JourneyDetails.SetRows(details, {{type = "itemTooltip", itemId = 725}})
            ui.RunFor(0.1)
            parent:Hide()
            Tooltip().itemId = nil

            ui.RunUntilIdle()

            assert.is_nil(Tooltip().itemId)
        end)

        it("should not update endlessly", function()
            JourneyDetails.SetRows(details, {{type = "itemTooltip", itemId = 725}})
            Tooltip():SetSize(200, 120)

            ui.RunUntilIdle()

            assert.are.equal(0, #ui.tickers)
        end)

        it("should have the icon of the item in front of it, which does what the row says when it is clicked", function()
            local clicks = 0
            details.scrollBox:SetWidth(500)
            JourneyDetails.SetRows(details, {{type = "itemTooltip", itemId = 725, icon = 134400, onClick = function() clicks = clicks + 1 end}})

            assert.is_true(Part(1).IconButton:IsShown())
            assert.are.equal(134400, Part(1).Icon:GetTexture())
            local _, _, _, tooltipX = Tooltip():GetPoint(1)
            assert.is_true(tooltipX > Part(1).IconButton:GetWidth(), "The tooltip covers the icon")
            Part(1).IconButton:Click()
            assert.are.equal(1, clicks)
        end)

        it("should be as high as its icon, while the tooltip is lower", function()
            details.scrollBox:SetWidth(500)
            JourneyDetails.SetRows(details, {{type = "itemTooltip", itemId = 725, icon = 134400}})
            Tooltip():SetSize(200, 10)
            ui.RunUntilIdle()

            assert.are.equal(Part(1).IconButton:GetHeight() + 8, RowHeight(1))
        end)

        it("should give the tooltip the whole row where the icon and it don't fit next to each other, and the icon where they do", function()
            details.scrollBox:SetWidth(200)
            JourneyDetails.SetRows(details, {{type = "itemTooltip", itemId = 725, icon = 134400}})
            Tooltip():SetSize(180, 100)
            ui.RunUntilIdle()

            local _, _, _, tooltipX = Tooltip():GetPoint(1)
            assert.are_same({false, 0}, {Part(1).IconButton:IsShown(), tooltipX})

            details.scrollBox:SetWidth(500)
            ui.RunUntilIdle()

            _, _, _, tooltipX = Tooltip():GetPoint(1)
            assert.is_true(Part(1).IconButton:IsShown())
            assert.is_true(tooltipX >= Part(1).IconButton:GetWidth())
        end)

        it("should start at the edge without an icon", function()
            JourneyDetails.SetRows(details, {{type = "itemTooltip", itemId = 725, icon = 134400}})
            JourneyDetails.SetRows(details, {{type = "itemTooltip", itemId = 2589}})

            assert.is_false(Part(1).IconButton:IsShown())
            local _, _, _, tooltipX = Tooltip():GetPoint(1)
            assert.are.equal(0, tooltipX)
        end)
    end)

    it("should put a colon between what a fact is about and its value", function()
        assert.are.equal("<Level: >5", JourneyDetails.GetFactText("Level", 5))
    end)
end)
