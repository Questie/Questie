dofile("setupTests.lua")

local FakeUI = dofile("cli/testData/options/FakeUI.lua")

-- FakeUI makes each character 7 wide. Most rows are 8 narrower on both sides than the list, banners and sections fill it.
describe("JourneyOverviewRows", function()
    ---@type JourneyOverviewRows
    local JourneyOverviewRows
    ---@type JourneyDetails
    local JourneyDetails
    local ui
    local originalQuestie
    local parent, details

    before_each(function()
        ui = FakeUI.Install()
        originalQuestie = _G.Questie
        _G.Questie = {
            db = {profile = {}},
            icons = {available = "available", complete = "complete", incomplete = "incomplete", checkmark = "checkmark"},
        }

        dofile("Modules/Libs/QuestieLoader.lua")
        dofile("Localization/l10n.lua")
        dofile("Modules/Options/QuestieOptionsUtils.lua")
        dofile("Modules/Journey/JourneyIcon.lua")
        dofile("Modules/Journey/JourneyScrollBox.lua")
        dofile("Modules/Journey/JourneyDetails.lua")
        dofile("Modules/Journey/JourneyOverviewRows.lua")
        JourneyDetails = QuestieLoader:ImportModule("JourneyDetails")
        JourneyOverviewRows = QuestieLoader:ImportModule("JourneyOverviewRows")

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

    ---@param rows JourneyDetails.Row[]
    ---@param width number Of what is in the rows
    ---@param keepsScrollPosition boolean? Like the overview, which updates what it shows
    local function ShowAll(rows, width, keepsScrollPosition)
        local isFullWidth = rows[1].type == "banner" or rows[1].type == "section"
        details.scrollBox:SetWidth(width + (isFullWidth and 0 or 2 * JourneyDetails.ROW_INSET))
        JourneyDetails.SetRows(details, rows, keepsScrollPosition)
    end

    ---@param row JourneyDetails.Row
    ---@param width number Of what is in the row
    ---@return table part
    local function Show(row, width)
        ShowAll({row}, width)
        return Part(1)
    end

    ---@param region table
    ---@param name string Of the point
    ---@return number x
    ---@return number y
    local function Offset(region, name)
        for index = 1, #region.points do
            local point, _, _, x, y = region:GetPoint(index)
            if point == name then return x, y end
        end
        error("There is no point " .. name)
    end

    ---@param fontString table
    ---@return boolean
    local function IsWhole(fontString)
        return fontString:GetWidth() >= fontString:GetUnboundedStringWidth()
    end

    ---@param region table
    ---@return boolean isSeen Shown, and not see-through
    local function IsSeen(region)
        return region:IsVisible() and region.alpha ~= 0
    end

    describe("tiles", function()
        -- Two are next to each other while both can be this wide
        local MIN_TILE_WIDTH, GAP = 170, 6

        ---@param text string
        ---@param fields table?
        ---@return JourneyOverviewRows.Tile
        local function Tile(text, fields)
            local tile = {text = text, isSelected = false, onClick = function() end}
            for key, value in pairs(fields or {}) do
                tile[key] = value
            end
            return tile
        end

        ---@param tile table
        ---@return number[] position x, y, width
        local function Place(tile)
            local x, y = Offset(tile, "TOPLEFT")
            return {x, -y, tile:GetWidth()}
        end

        it("should be next to each other while both can be 170 wide", function()
            ShowAll({
                JourneyOverviewRows.GetTiles({Tile("Eastern Kingdoms"), Tile("Kalimdor")}),
                JourneyOverviewRows.GetTiles({Tile("Reputation")}),
            }, 2 * MIN_TILE_WIDTH + GAP)

            assert.are_same({0, 0, MIN_TILE_WIDTH}, Place(Part(1).Tiles[1]))
            assert.are_same({MIN_TILE_WIDTH + GAP, 0, MIN_TILE_WIDTH}, Place(Part(1).Tiles[2]))
            assert.are.equal(RowHeight(2), RowHeight(1)) -- As high as one
        end)

        it("should be below each other in a narrower row, which is high enough for all of them", function()
            local width = 2 * MIN_TILE_WIDTH + GAP - 1
            ShowAll({
                JourneyOverviewRows.GetTiles({Tile("Eastern Kingdoms"), Tile("Kalimdor")}),
                JourneyOverviewRows.GetTiles({Tile("Reputation")}),
            }, width)

            local oneHigh = RowHeight(2)
            assert.are_same({0, 0, width}, Place(Part(1).Tiles[1]))
            assert.are_same({0, oneHigh, width}, Place(Part(1).Tiles[2]))
            assert.are.equal(2 * oneHigh, RowHeight(1))
        end)

        it("should give a tile with a width that much, and the other one the rest", function()
            local part = Show(JourneyOverviewRows.GetTiles({Tile("Search", {width = 116}), Tile("Overview")}), 400)

            assert.are_same({0, 0, 116}, Place(part.Tiles[1]))
            assert.are_same({116 + GAP, 0, 400 - 116 - GAP}, Place(part.Tiles[2]))
        end)

        it("should make a tile with a width as wide as the row while they are below each other", function()
            local part = Show(JourneyOverviewRows.GetTiles({Tile("Search", {width = 116}), Tile("Overview")}), 300)

            local first, second = Place(part.Tiles[1]), Place(part.Tiles[2])
            assert.are_same({0, 0, 300}, first)
            assert.are_same({0, 300}, {second[1], second[3]})
            assert.is_true(second[2] > 0)
        end)

        -- A last tile alone stays in line with those above it, where there is room for two
        it("should only show one tile in a row that showed two before, as wide as one of them", function()
            Show(JourneyOverviewRows.GetTiles({Tile("Class"), Tile("Professions")}), 400)

            local part = Show(JourneyOverviewRows.GetTiles({Tile("Reputation")}), 400)

            assert.are.equal("Reputation", part.Tiles[1].Title.text)
            assert.are_same({0, 0, (400 - GAP) / 2}, Place(part.Tiles[1]))
            assert.is_false(part.Tiles[2]:IsShown())
        end)

        it("should show in a bar how many are completed", function()
            local tile = Show(JourneyOverviewRows.GetTiles({Tile("Eastern Kingdoms", {value = 1234, maximum = 5000})}), 400).Tiles[1]

            assert.is_true(tile.Bar:IsShown())
            assert.are.equal("1,234 / 5,000", tile.Bar.Text.text)
            assert.are_same({0, 5000, 1234}, {tile.Bar.minValue, tile.Bar.maxValue, tile.Bar:GetValue()})
        end)

        -- Like before anything is counted
        it("should show an empty bar rather than a full one when there is nothing", function()
            local tile = Show(JourneyOverviewRows.GetTiles({Tile("Eastern Kingdoms", {value = 0, maximum = 0})}), 400).Tiles[1]

            assert.are.equal("0 / 0", tile.Bar.Text.text)
            assert.is_true(tile.Bar:GetValue() < tile.Bar.maxValue)
        end)

        it("should show a note instead of a bar, also in a row that showed a bar before", function()
            Show(JourneyOverviewRows.GetTiles({Tile("Eastern Kingdoms", {value = 1, maximum = 2})}), 400)

            local tile = Show(JourneyOverviewRows.GetTiles({Tile("Overview", {note = "Good for your level"})}), 400).Tiles[1]

            assert.are.equal("Good for your level", tile.Note.text)
            assert.is_false(tile.Bar:IsShown())
        end)

        describe("pictures", function()
            ---@param picture JourneyOverviewRows.Picture?
            ---@return table tile
            local function ShowPicture(picture)
                return Show(JourneyOverviewRows.GetTiles({Tile("Eastern Kingdoms", {picture = picture})}), 400).Tiles[1]
            end

            it("should show an icon without the frame that is part of it, in a frame of its own", function()
                local tile = ShowPicture(136241)

                local left, right, top, bottom = unpack(tile.Picture.texCoord)
                assert.are.equal(136241, tile.Picture:GetTexture())
                assert.is_true(left > 0 and top > 0 and right < 1 and bottom < 1)
                assert.is_true(IsSeen(tile.Frame))
            end)

            -- Cut to the frame of an icon, they would lose their edges
            it("should show an atlas, and a round file, whole and without a frame, also after an icon", function()
                ShowPicture(136241)
                local tile = ShowPicture({atlas = "classicon-mage"})
                assert.are.equal("classicon-mage", tile.Picture.atlas)
                assert.are.equal("the part that is the atlas", tile.Picture.texCoord)
                assert.is_false(IsSeen(tile.Frame))

                tile = ShowPicture({file = "dungeon.png"})
                assert.are.equal("dungeon.png", tile.Picture:GetTexture())
                assert.is_nil(tile.Picture.atlas)
                assert.are_same({0, 1, 0, 1}, tile.Picture.texCoord)
                assert.is_false(IsSeen(tile.Frame))
            end)

            it("should put the text right of the picture, and at the left without one", function()
                local tile = ShowPicture(136241)
                local frameRight = Offset(tile.Frame, "LEFT") + tile.Frame:GetWidth()
                assert.is_true(Offset(tile.TextStart, "LEFT") >= frameRight)

                tile = ShowPicture(nil)
                assert.is_false(tile.Picture:IsShown())
                assert.is_false(IsSeen(tile.Frame))
                assert.is_true(Offset(tile.TextStart, "LEFT") < frameRight)
            end)
        end)

        it("should do what the tile it shows says, also after the row was reused", function()
            local clicked = {}
            ---@param text string
            ---@return JourneyDetails.Row
            local function Clickable(text)
                return JourneyOverviewRows.GetTiles({Tile(text, {onClick = function() table.insert(clicked, text) end})})
            end
            Show(Clickable("Kalimdor"), 400)
            local part = Show(Clickable("Outland"), 400)

            part.Tiles[1]:Click()

            assert.are_same({"Outland"}, clicked)
        end)

        -- The overview updates its tiles while keeping them, when another one is selected or something was counted
        describe("that are updated", function()
            ---@param kalimdor table? Fields of the second tile
            ---@param search table? Of the first one
            ---@return JourneyDetails.Row
            local function CreateRow(kalimdor, search)
                local first, second = Tile("Search", {width = 116}), Tile("Kalimdor", {value = 1, maximum = 2})
                for key, value in pairs(search or {}) do first[key] = value end
                for key, value in pairs(kalimdor or {}) do second[key] = value end
                return JourneyOverviewRows.GetTiles({first, second})
            end

            before_each(function()
                ShowAll({CreateRow()}, 400)
            end)

            -- With new functions for their clicks, like each time the overview makes them. Showing them again would lose a click.
            it("should stay as they are when nothing about them changed", function()
                local row = ui.Rows(parent, 1)[1].elementData

                ShowAll({CreateRow()}, 400, true)

                assert.are.equal(row, ui.Rows(parent, 1)[1].elementData)
            end)

            it("should look selected only while they are", function()
                ShowAll({CreateRow({isSelected = true})}, 400, true)
                assert.are.equal("GameFontHighlight", Part(1).Tiles[2].Title.fontObject)
                assert.are.equal("GameFontNormal", Part(1).Tiles[1].Title.fontObject)

                ShowAll({CreateRow()}, 400, true)
                assert.are.equal("GameFontNormal", Part(1).Tiles[2].Title.fontObject)
            end)

            for name, change in pairs({
                ["a text"] = {kalimdor = {text = "Outland"}},
                ["a note"] = {search = {note = "Wolves"}},
                ["a count"] = {kalimdor = {value = 2}},
                ["what there is to count"] = {kalimdor = {maximum = 3}},
                ["a width"] = {search = {width = 120}},
            }) do
                it("should be shown again when " .. name .. " changed", function()
                    local row = CreateRow(change.kalimdor, change.search)

                    ShowAll({row}, 400, true)

                    assert.are.equal(row, ui.Rows(parent, 1)[1].elementData)
                end)
            end
        end)
    end)

    describe("a banner", function()
        it("should show its title and note, and no picture of the banner before", function()
            Show(JourneyOverviewRows.GetBanner("Kalimdor", "1 of 2 completed", 133741), 400)

            local part = Show(JourneyOverviewRows.GetBanner("Overview", "Good for your level: 5"), 400)

            assert.are.equal("Overview", part.Title.text)
            assert.are.equal("Good for your level: 5", part.Note.text)
            assert.is_false(part.Picture:IsShown())
            assert.is_false(IsSeen(part.Frame))
        end)

        it("should only show the frame behind an icon, not behind a round picture", function()
            local part = Show(JourneyOverviewRows.GetBanner("Kalimdor", "1 of 2 completed", 133741), 400)
            assert.is_true(part.Picture:IsShown())
            assert.is_true(IsSeen(part.Frame))

            part = Show(JourneyOverviewRows.GetBanner("Dungeons", "1 of 2 completed", {file = "dungeon.png"}), 400)
            assert.are.equal("dungeon.png", part.Picture:GetTexture())
            assert.is_false(IsSeen(part.Frame))
        end)
    end)

    describe("a section", function()
        local TITLE, NOTE = "Eastern Kingdoms", "12 quests" -- 112 and 63 wide
        -- The title starts 16 from the left and gets 1 more than its text. The note ends 14 from the right, 8 away from the title.
        local FITTING_WIDTH = 16 + 112 + 1 + 8 + 63 + 14
        -- A picture moves the title 20 to the right
        local PICTURE_WIDTH = 20

        it("should show its note next to a title that fits with it", function()
            local part = Show(JourneyOverviewRows.GetSection(TITLE, nil, NOTE), FITTING_WIDTH)

            assert.is_true(part.Note:IsShown())
            assert.are.equal(NOTE, part.Note.text)
            assert.is_true(IsWhole(part.Title))
        end)

        it("should leave out its note rather than cut off the title", function()
            local part = Show(JourneyOverviewRows.GetSection(TITLE, nil, NOTE), FITTING_WIDTH - 1)

            assert.is_false(part.Note:IsShown())
            assert.is_true(IsWhole(part.Title))
        end)

        it("should keep room for its picture", function()
            local part = Show(JourneyOverviewRows.GetSection(TITLE, nil, NOTE, 133741), FITTING_WIDTH + PICTURE_WIDTH - 1)
            assert.is_false(part.Note:IsShown())

            part = Show(JourneyOverviewRows.GetSection(TITLE, nil, NOTE, 133741), FITTING_WIDTH + PICTURE_WIDTH)
            assert.is_true(part.Note:IsShown())
            assert.is_true(part.Picture:IsShown())
        end)

        it("should only cut off the title when it doesn't fit by itself, and keep it off the edge", function()
            local part = Show(JourneyOverviewRows.GetSection(TITLE, nil, NOTE), 100)

            assert.is_false(part.Note:IsShown())
            assert.is_false(IsWhole(part.Title))
            assert.is_true(Offset(part.Title, "BOTTOMLEFT") + part.Title:GetWidth() <= 100 - JourneyDetails.ROW_INSET)
        end)

        it("should be in the color it is given", function()
            local part = Show(JourneyOverviewRows.GetSection("Level 10 - 20", {r = 0.25, g = 0.75, b = 0.25}), 400)

            assert.are_same({0.25, 0.75, 0.25}, part.Title.textColor)
        end)

        it("should stay as it is when nothing about it changed", function()
            ShowAll({JourneyOverviewRows.GetSection("Level 10 - 20", {r = 1, g = 1, b = 0}, NOTE)}, 400)
            local row = ui.Rows(parent, 1)[1].elementData

            ShowAll({JourneyOverviewRows.GetSection("Level 10 - 20", {r = 1, g = 1, b = 0}, NOTE)}, 400, true)

            assert.are.equal(row, ui.Rows(parent, 1)[1].elementData)
        end)

        -- The color of the levels changes when the player levels up
        it("should be shown again when its color changed", function()
            ShowAll({JourneyOverviewRows.GetSection("Level 10 - 20", {r = 1, g = 1, b = 0})}, 400)
            local row = JourneyOverviewRows.GetSection("Level 10 - 20", {r = 0.25, g = 0.75, b = 0.25})

            ShowAll({row}, 400, true)

            assert.are.equal(row, ui.Rows(parent, 1)[1].elementData)
        end)
    end)

    describe("a zone", function()
        local NAME, LEVELS = "Elwynn Forest", "1 - 10" -- 91 and 42 wide
        -- The name starts 24 from the left and gets 1 more than its text. What is next to it is 8 away. The quest log count, "suited"
        -- and the bar start 194, 148 and 100 from the right.
        local NAME_RIGHT = 24 + 91 + 1 + 8
        local LEVELS_FIT = NAME_RIGHT + 42 + 8 + 194
        local LOG_FITS, SUITED_FITS, BAR_FITS = NAME_RIGHT + 194, NAME_RIGHT + 148, NAME_RIGHT + 100

        ---@param fields table?
        ---@return JourneyOverviewRows.Zone
        local function Zone(fields)
            local zone = {
                name = NAME, levels = LEVELS, isHere = false, suited = 3, log = 2, isLogComplete = false, completed = 4, total = 10,
                isOdd = false, onClick = function() end, showTooltip = function() end,
            }
            for key, value in pairs(fields or {}) do
                zone[key] = value
            end
            return zone
        end

        ---@param part table
        ---@return string[] shown What is shown next to the name, also partly, like only the number of a count
        local function Shown(part)
            local shown = {}
            if part.Levels:IsShown() then table.insert(shown, "levels") end
            if part.Log.text ~= "" or part.LogIcon:IsShown() then table.insert(shown, "log") end
            if part.Suited.text ~= "" or part.SuitedIcon:IsShown() then table.insert(shown, "suited") end
            if part.Bar:IsShown() then table.insert(shown, "bar") end
            return shown
        end

        -- The name comes first. What is next to it is left out from the name outwards.
        for _, case in ipairs({
            {width = LEVELS_FIT, shown = {"levels", "log", "suited", "bar"}},
            {width = LEVELS_FIT - 1, shown = {"log", "suited", "bar"}},
            {width = LOG_FITS, shown = {"log", "suited", "bar"}},
            {width = LOG_FITS - 1, shown = {"suited", "bar"}},
            {width = SUITED_FITS, shown = {"suited", "bar"}},
            {width = SUITED_FITS - 1, shown = {"bar"}},
            {width = BAR_FITS, shown = {"bar"}},
            {width = BAR_FITS - 1, shown = {}},
        }) do
            local shownText = #case.shown > 0 and table.concat(case.shown, ", ") or "nothing"
            it("should show " .. shownText .. " next to the whole name in a row that is " .. case.width .. " wide", function()
                local part = Show(JourneyOverviewRows.GetZone(Zone()), case.width)

                assert.are_same(case.shown, Shown(part))
                assert.is_true(IsWhole(part.Name))
            end)
        end

        -- The levels are next to it, so it can't be wider
        it("should make the name as wide as its text", function()
            local part = Show(JourneyOverviewRows.GetZone(Zone()), 600)

            assert.is_true(IsWhole(part.Name))
            assert.is_true(part.Name:GetWidth() <= part.Name:GetUnboundedStringWidth() + 1)
        end)

        it("should only cut off the name when nothing else is left to leave out", function()
            local width = 100
            local part = Show(JourneyOverviewRows.GetZone(Zone()), width)

            assert.are_same({}, Shown(part))
            assert.is_false(IsWhole(part.Name))
            assert.is_true(Offset(part.Name, "LEFT") + part.Name:GetWidth() <= width)
        end)

        it("should give the name the room of a column that has nothing to show", function()
            local part = Show(JourneyOverviewRows.GetZone(Zone({log = 0})), LEVELS_FIT - (194 - 148))

            assert.are_same({"levels", "suited", "bar"}, Shown(part))
        end)

        it("should show what is counted, with whether the quests in the log are complete", function()
            local part = Show(JourneyOverviewRows.GetZone(Zone({isLogComplete = true, completed = 1500, total = 2000})), 600)
            assert.are.equal("2", part.Log.text)
            assert.are.equal("complete", part.LogIcon:GetTexture())
            assert.are.equal("3", part.Suited.text)
            assert.are.equal("available", part.SuitedIcon:GetTexture())
            assert.are.equal("1,500 / 2,000", part.Bar.Text.text)

            part = Show(JourneyOverviewRows.GetZone(Zone({isLogComplete = false})), 600)
            assert.are.equal("incomplete", part.LogIcon:GetTexture())
        end)

        it("should show where the player is instead of its icon", function()
            local part = Show(JourneyOverviewRows.GetZone(Zone({icon = "checkmark", isHere = true})), 600)
            assert.is_true(part.Here:IsShown())
            assert.is_false(part.Icon:IsShown())

            part = Show(JourneyOverviewRows.GetZone(Zone({icon = "checkmark", isHere = false})), 600)
            assert.is_false(part.Here:IsShown())
            assert.are.equal("checkmark", part.Icon:GetTexture())
        end)

        it("should explain itself in a tooltip, which is hidden when it is clicked", function()
            local clicks = 0
            local part = Show(JourneyOverviewRows.GetZone(Zone({
                onClick = function() clicks = clicks + 1 end,
                showTooltip = function() GameTooltip:AddLine("Level 1 - 10") end,
            })), 600)
            local button = part.children[1]

            button.scripts.OnEnter(button)
            assert.are_same({"Level 1 - 10"}, GameTooltip.lines)
            assert.are.equal(button, GameTooltip.owner)
            assert.is_true(GameTooltip:IsShown())

            button:Click()
            assert.are.equal(1, clicks)
            assert.is_false(GameTooltip:IsShown())
        end)

        it("should stay as it is when nothing about it changed", function()
            ShowAll({JourneyOverviewRows.GetZone(Zone({color = {r = 1, g = 1, b = 0}}))}, 600)
            local row = ui.Rows(parent, 1)[1].elementData

            ShowAll({JourneyOverviewRows.GetZone(Zone({color = {r = 1, g = 1, b = 0}}))}, 600, true)

            assert.are.equal(row, ui.Rows(parent, 1)[1].elementData)
        end)

        -- The overview counts again while it is open
        for _, field in ipairs({"name", "levels", "icon", "isHere", "suited", "log", "isLogComplete", "completed", "total", "color"}) do
            it("should be shown again when its " .. field .. " changed", function()
                ShowAll({JourneyOverviewRows.GetZone(Zone({color = {r = 1, g = 1, b = 0}}))}, 600)
                local changed = {
                    name = "Westfall", levels = "10 - 20", icon = "checkmark", isHere = true, suited = 4, log = 3, isLogComplete = true,
                    completed = 5, total = 11, color = {r = 0.25, g = 0.75, b = 0.25},
                }
                local row = JourneyOverviewRows.GetZone(Zone({color = {r = 1, g = 1, b = 0}, [field] = changed[field]}))

                ShowAll({row}, 600, true)

                assert.are.equal(row, ui.Rows(parent, 1)[1].elementData)
            end)
        end
    end)

    describe("a faction", function()
        local NAME = "Knights of the Ebon Blade" -- 175 wide
        -- "Friendly   1,500 / 6,000" and "Friendly" are 168 and 56 wide, and need 8 more in the bar
        local STANDING
        -- The name starts 24 from the left and gets 1 more than its text. The bar is 8 away from it, and 4 away from the right.
        local NAME_RIGHT = 24 + 175 + 1 + 8 + 4
        local NUMBERS_FIT, STANDING_FITS = NAME_RIGHT + 168 + 8, NAME_RIGHT + 56 + 8

        before_each(function()
            STANDING = {name = "Friendly", value = 1500, size = 6000, reputation = 4500, color = CreateColor(0, 0.6, 0.1)}
        end)

        ---@param width number
        ---@param standing table?
        ---@return table part
        local function ShowFaction(width, standing)
            return Show(JourneyOverviewRows.GetFaction(NAME, standing, false, function() end), width)
        end

        it("should show the standing and the numbers in the bar when they fit next to the whole name", function()
            local part = ShowFaction(NUMBERS_FIT, STANDING)

            assert.is_true(part.Bar:IsShown())
            assert.are.equal("Friendly   1,500 / 6,000", part.Bar.Text.text)
            assert.are_same({0, 6000, 1500}, {part.Bar.minValue, part.Bar.maxValue, part.Bar:GetValue()})
            assert.is_true(IsWhole(part.Name))
        end)

        it("should leave out the numbers first", function()
            local part = ShowFaction(NUMBERS_FIT - 1, STANDING)
            assert.is_true(part.Bar:IsShown())
            assert.are.equal("Friendly", part.Bar.Text.text)
            assert.is_true(IsWhole(part.Name))

            part = ShowFaction(STANDING_FITS, STANDING)
            assert.is_true(part.Bar:IsShown())
        end)

        it("should leave out the bar rather than cut off the name", function()
            local part = ShowFaction(STANDING_FITS - 1, STANDING)

            assert.is_false(part.Bar:IsShown())
            assert.is_true(IsWhole(part.Name))
        end)

        it("should only cut off the name when it doesn't fit by itself", function()
            local width = 150
            local part = ShowFaction(width, STANDING)

            assert.is_false(part.Bar:IsShown())
            assert.is_false(IsWhole(part.Name))
            assert.is_true(Offset(part.Name, "LEFT") + part.Name:GetWidth() <= width)
        end)

        it("should not take more than half of a wide row for the bar", function()
            local part = ShowFaction(800, STANDING)

            assert.is_true(part.Bar:IsShown())
            assert.are.equal("Friendly   1,500 / 6,000", part.Bar.Text.text)
            assert.is_true(part.Bar:GetWidth() <= 800 / 2)
        end)

        it("should show a faction the player hasn't met in gray and without a bar, also after one with a bar", function()
            ShowFaction(600, STANDING)

            local part = ShowFaction(600, nil)

            assert.is_false(part.Bar:IsShown())
            assert.are_same({0.6, 0.6, 0.6}, part.Name.textColor)
            assert.is_true(IsWhole(part.Name))
        end)

        it("should stay as it is when nothing about it changed", function()
            ShowAll({JourneyOverviewRows.GetFaction(NAME, STANDING, false, function() end)}, 600)
            local row = ui.Rows(parent, 1)[1].elementData
            local standing = {name = "Friendly", value = 1500, size = 6000, reputation = 4500, color = CreateColor(0, 0.6, 0.1)}

            ShowAll({JourneyOverviewRows.GetFaction(NAME, standing, false, function() end)}, 600, true)

            assert.are.equal(row, ui.Rows(parent, 1)[1].elementData)
        end)

        it("should be shown again when the reputation changed", function()
            ShowAll({JourneyOverviewRows.GetFaction(NAME, STANDING, false, function() end)}, 600)
            local standing = {name = "Friendly", value = 1600, size = 6000, reputation = 4600, color = STANDING.color}
            local row = JourneyOverviewRows.GetFaction(NAME, standing, false, function() end)

            ShowAll({row}, 600, true)

            assert.are.equal("Friendly   1,600 / 6,000", Part(1).Bar.Text.text)
        end)

        it("should do what its row says, also after the row was reused", function()
            local clicked = {}
            ShowAll({JourneyOverviewRows.GetFaction(NAME, STANDING, false, function() table.insert(clicked, "first") end)}, 600)
            ShowAll({JourneyOverviewRows.GetFaction("Stormwind", STANDING, false, function() table.insert(clicked, "second") end)}, 600)

            Part(1).children[1]:Click()

            assert.are_same({"second"}, clicked)
        end)
    end)
end)
