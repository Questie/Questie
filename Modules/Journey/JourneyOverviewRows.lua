---The rows of the overview of the Journey, see JourneyDetails.
---
---What a row shows is in the fields below. Its state is made from them, so it is only shown again when something has changed.
---@class JourneyOverviewRows
local JourneyOverviewRows = QuestieLoader:CreateModule("JourneyOverviewRows")

---@type JourneyDetails
local JourneyDetails = QuestieLoader:ImportModule("JourneyDetails")
---@type JourneyIcon
local JourneyIcon = QuestieLoader:ImportModule("JourneyIcon")
---@type QuestieOptionsUtils
local QuestieOptionsUtils = QuestieLoader:ImportModule("QuestieOptionsUtils")

local BAR_TEXTURE = "Interface\\TargetingFrame\\UI-StatusBar"
local EDGE_COLOR = {0.45, 0.36, 0.22}
local DONE_COLOR = {0.20, 0.45, 0.13}
local GOLD = {1, 0.82, 0}
-- Forever's, which the other clients have older art for under the same name, StoryHeader-BG. In the top left of the file.
local BANNER_TEXTURE = "Interface\\AddOns\\Questie\\Icons\\Journey\\banner.png"
local BANNER_RIGHT, BANNER_BOTTOM = 608 / 1024, 138 / 256

---A picture: an icon, as a file ID or a path, which is shown without the frame that is part of icons. In a table, an atlas or a file
---that is shown whole, like a round one.
---@alias JourneyOverviewRows.Picture number|string|{atlas: string}|{file: number|string}

---@class JourneyOverviewRows.Tile
---@field text string
---@field picture JourneyOverviewRows.Picture? Without it, the text starts at the left
---@field width number? Without it, the tile shares what the others leave of the row
---@field note string? Instead of the bar
---@field value number? For the bar
---@field maximum number?
---@field color number[]? Of the bar
---@field isSelected boolean
---@field onClick fun()

-------------------------
-- Parts
-------------------------

---@param texture Texture
---@param picture JourneyOverviewRows.Picture
---@param size number
local function _SetPicture(texture, picture, size)
    texture:SetSize(size, size)
    if type(picture) == "table" and picture.file then
        texture:SetTexture(picture.file)
        texture:SetTexCoord(0, 1, 0, 1)
    elseif type(picture) == "table" then
        texture:SetTexCoord(0, 1, 0, 1)
        texture:SetAtlas(picture.atlas)
    else
        texture:SetTexture(picture)
        texture:SetTexCoord(0.07, 0.93, 0.07, 0.93) -- Without the frame that is part of the icons
    end
end

-- The tabs of the quests show their pictures like these
JourneyOverviewRows.SetPicture = _SetPicture

---@param frame Frame
---@param layer string
---@return Texture[]
local function _CreateEdges(frame, layer)
    local edges = {}
    for _, points in ipairs({{"TOPLEFT", "TOPRIGHT"}, {"BOTTOMLEFT", "BOTTOMRIGHT"}, {"TOPLEFT", "BOTTOMLEFT"}, {"TOPRIGHT", "BOTTOMRIGHT"}}) do
        local edge = frame:CreateTexture(nil, layer)
        edge:SetColorTexture(1, 1, 1)
        edge:SetPoint(points[1], frame, points[1])
        edge:SetPoint(points[2], frame, points[2])
        edge:SetSize(1.2, 1.2)
        QuestieOptionsUtils.DisableSnapping(edge) -- Otherwise some of them disappear
        table.insert(edges, edge)
    end
    return edges
end

---@param edges Texture[]
---@param color number[]
---@param alpha number
local function _ColorEdges(edges, color, alpha)
    for _, edge in ipairs(edges) do
        edge:SetVertexColor(color[1], color[2], color[3], alpha)
    end
end

---@param parent Frame
---@param height number
---@return StatusBar
local function _CreateBar(parent, height)
    local bar = CreateFrame("StatusBar", nil, parent)
    bar:SetHeight(height)
    bar:SetStatusBarTexture(BAR_TEXTURE)
    local background = bar:CreateTexture(nil, "BACKGROUND")
    background:SetAllPoints(bar)
    background:SetColorTexture(0, 0, 0, 0.5)
    _ColorEdges(_CreateEdges(bar, "OVERLAY"), EDGE_COLOR, 0.7)
    bar.Text = bar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    bar.Text:SetPoint("CENTER", bar, "CENTER", 0, 0)
    return bar
end

---@param bar StatusBar
---@param value number
---@param maximum number
---@param color number[]
---@param text string
local function _SetBar(bar, value, maximum, color, text)
    bar:SetMinMaxValues(0, math.max(1, maximum))
    bar:SetValue(value)
    bar:SetStatusBarColor(color[1], color[2], color[3])
    bar.Text:SetText(text)
end

---@param value number
---@param maximum number
---@return string
local function _GetBarText(value, maximum)
    return BreakUpLargeNumbers(value) .. " / " .. BreakUpLargeNumbers(maximum)
end

---Fades out to the right.
---@param texture Texture
---@param color number[]
---@param alpha number
local function _SetFade(texture, color, alpha)
    texture:SetColorTexture(1, 1, 1)
    texture:SetGradient("HORIZONTAL", CreateColor(color[1], color[2], color[3], alpha), CreateColor(color[1], color[2], color[3], 0))
end

-------------------------
-- Tiles
-------------------------

local TILE_HEIGHT, TOP_TILE_HEIGHT, TILE_GAP = 48, 46, 6
local TILE_PICTURE_SIZE = 34

---@param row Frame
---@return Button
local function _CreateTile(row)
    local tile = CreateFrame("Button", nil, row)
    tile.Background = tile:CreateTexture(nil, "BACKGROUND")
    tile.Background:SetAllPoints(tile)
    tile.Background:SetColorTexture(0.13, 0.10, 0.075, 0.75)
    tile.Glow = tile:CreateTexture(nil, "BORDER")
    tile.Glow:SetAllPoints(tile)
    tile.Edges = _CreateEdges(tile, "ARTWORK")

    local frame = tile:CreateTexture(nil, "BORDER", nil, 1)
    frame:SetColorTexture(0, 0, 0, 0.8)
    frame:SetPoint("LEFT", tile, "LEFT", 6, 0)
    frame:SetSize(TILE_PICTURE_SIZE + 2, TILE_PICTURE_SIZE + 2)
    tile.Frame = frame
    tile.Picture = tile:CreateTexture(nil, "ARTWORK")
    tile.Picture:SetPoint("CENTER", frame, "CENTER", 0, 0)

    -- Where the text starts, right of the picture or at the left without one
    tile.TextStart = tile:CreateTexture(nil, "BORDER")
    tile.TextStart:SetSize(1, TILE_PICTURE_SIZE + 2)
    tile.Title = tile:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    tile.Title:SetJustifyH("LEFT")
    tile.Title:SetWordWrap(false)
    tile.Note = tile:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
    tile.Note:SetJustifyH("LEFT")
    tile.Note:SetPoint("BOTTOMLEFT", tile.TextStart, "BOTTOMLEFT", 0, 3)
    tile.Bar = _CreateBar(tile, 12)
    tile.Bar:SetPoint("BOTTOMLEFT", tile.TextStart, "BOTTOMLEFT", 0, 2)
    tile.Bar:SetPoint("RIGHT", tile, "RIGHT", -8, 0)

    local function UpdateColors()
        local isSelected, isHovered = tile.data.isSelected, tile.isHovered
        _ColorEdges(tile.Edges, isSelected and GOLD or EDGE_COLOR, isSelected and 0.85 or isHovered and 0.95 or 0.55)
        _SetFade(tile.Glow, GOLD, isSelected and 0.22 or isHovered and 0.10 or 0)
        tile.Title:SetFontObject(isSelected and "GameFontHighlight" or "GameFontNormal")
    end
    tile.UpdateColors = UpdateColors
    tile:SetScript("OnEnter", function() tile.isHovered = true UpdateColors() end)
    tile:SetScript("OnLeave", function() tile.isHovered = false UpdateColors() end)
    tile:SetScript("OnClick", function()
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
        tile.data.onClick()
    end)
    return tile
end

---@param tile Button
---@param data JourneyOverviewRows.Tile
local function _UpdateTile(tile, data)
    tile.data = data
    tile.Picture:SetShown(data.picture ~= nil)
    tile.Frame:SetShown(data.picture ~= nil and type(data.picture) ~= "table")
    if data.picture then
        _SetPicture(tile.Picture, data.picture, TILE_PICTURE_SIZE)
    end
    tile.TextStart:SetPoint("LEFT", tile, "LEFT", data.picture and 6 + TILE_PICTURE_SIZE + 2 + 9 or 10, 0)
    -- In the middle when there is nothing below it
    tile.Title:ClearAllPoints()
    if data.note or data.maximum then
        tile.Title:SetPoint("TOPLEFT", tile.TextStart, "TOPLEFT", 0, -2)
    else
        tile.Title:SetPoint("LEFT", tile.TextStart, "LEFT", 0, 0)
    end
    tile.Title:SetPoint("RIGHT", tile, "RIGHT", -6, 0)
    tile.Title:SetText(data.text)
    tile.Note:SetText(data.note or "")
    tile.Bar:SetShown(data.maximum ~= nil)
    if data.maximum then
        _SetBar(tile.Bar, data.value, data.maximum, data.color or DONE_COLOR, _GetBarText(data.value, data.maximum))
    end
    tile.UpdateColors()
end

---One or two tiles next to each other.
---@param tiles JourneyOverviewRows.Tile[]
---@param isTop boolean? For the tiles at the top, which are a bit lower
---@return JourneyDetails.Row
function JourneyOverviewRows.GetTiles(tiles, isTop)
    local state = {}
    for _, tile in ipairs(tiles) do
        table.insert(state, table.concat({
            tile.text, tile.note or "", tile.value or "", tile.maximum or "", tostring(tile.isSelected), tile.width or "",
        }, "\001"))
    end
    return {type = "tiles", tiles = tiles, isTop = isTop, state = table.concat(state, "\002")}
end

JourneyDetails.AddRowType("tiles", {
    Create = function(part)
        part.Tiles = {_CreateTile(part), _CreateTile(part)}
    end,
    Update = function(part, data, width)
        -- There is room for two. A tile with a width takes that much of it.
        local fixedWidth, fixedCount = 0, 0
        for _, tile in ipairs(data.tiles) do
            if tile.width then
                fixedWidth, fixedCount = fixedWidth + tile.width, fixedCount + 1
            end
        end
        local sharedWidth = (width - TILE_GAP - fixedWidth) / math.max(1, 2 - fixedCount)

        local x = 0
        for index, tile in ipairs(part.Tiles) do
            local tileData = data.tiles[index]
            tile:SetShown(tileData ~= nil)
            if tileData then
                local tileWidth = tileData.width or sharedWidth
                tile:SetPoint("TOPLEFT", part, "TOPLEFT", x, 0)
                tile:SetSize(tileWidth, data.isTop and TOP_TILE_HEIGHT or TILE_HEIGHT)
                _UpdateTile(tile, tileData)
                x = x + tileWidth + TILE_GAP
            end
        end
    end,
    GetHeight = function(data) return (data.isTop and TOP_TILE_HEIGHT or TILE_HEIGHT) + TILE_GAP end,
})

-------------------------
-- Banner
-------------------------

local BANNER_HEIGHT, BANNER_PICTURE_SIZE = 56, 40
-- Banners and sections fill the whole row, so their backgrounds reach the edges. What is on them keeps the usual space.
local INSET = JourneyDetails.ROW_INSET

---The top of a page.
---@param text string
---@param note string
---@param picture JourneyOverviewRows.Picture? Without it, the text starts at the left
---@return JourneyDetails.Row
function JourneyOverviewRows.GetBanner(text, note, picture)
    return {type = "banner", text = text, tag = note, picture = picture}
end

JourneyDetails.AddRowType("banner", {
    isFullWidth = true,
    Create = function(part)
        local background = part:CreateTexture(nil, "BACKGROUND")
        background:SetTexture(BANNER_TEXTURE)
        background:SetTexCoord(0, BANNER_RIGHT, 0, BANNER_BOTTOM)
        background:SetPoint("TOPLEFT", part, "TOPLEFT", 0, 0)
        background:SetPoint("BOTTOMRIGHT", part, "BOTTOMRIGHT", 0, 4)
        background:SetAlpha(0.75)
        part.Frame = part:CreateTexture(nil, "BORDER")
        part.Frame:SetColorTexture(0, 0, 0, 0.8)
        part.Frame:SetSize(BANNER_PICTURE_SIZE + 2, BANNER_PICTURE_SIZE + 2)
        part.Frame:SetPoint("LEFT", part, "LEFT", INSET + 6, 3)
        part.Picture = part:CreateTexture(nil, "ARTWORK")
        part.Picture:SetPoint("CENTER", part.Frame, "CENTER", 0, 0)
        -- Where the text starts, right of the picture or at the left without one
        part.TextStart = part:CreateTexture(nil, "BORDER")
        part.TextStart:SetSize(1, BANNER_PICTURE_SIZE + 2)
        part.Title = part:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
        part.Title:SetPoint("TOPLEFT", part.TextStart, "TOPLEFT", 0, -3)
        part.Note = part:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
        part.Note:SetPoint("BOTTOMLEFT", part.TextStart, "BOTTOMLEFT", 0, 5)
        part.Note:SetTextColor(0.85, 0.79, 0.66)
    end,
    Update = function(part, data)
        part.Picture:SetShown(data.picture ~= nil)
        if data.picture then
            _SetPicture(part.Picture, data.picture, BANNER_PICTURE_SIZE)
        end
        part.Frame:SetAlpha((data.picture == nil or type(data.picture) == "table") and 0 or 1)
        part.TextStart:SetPoint("LEFT", part, "LEFT", INSET + (data.picture and 6 + BANNER_PICTURE_SIZE + 2 + 11 or 6), 3)
        part.Title:SetText(data.text)
        part.Note:SetText(data.tag)
    end,
    GetHeight = function() return BANNER_HEIGHT end,
})

-------------------------
-- Sections
-------------------------

local SECTION_HEIGHT, SECTION_PICTURE_SIZE = 32, 18

---The title of some rows, with the ornament of Blizzard's list of objectives.
---@param text string
---@param color {r: number, g: number, b: number}?
---@param note string?
---@param picture JourneyOverviewRows.Picture?
---@return JourneyDetails.Row
function JourneyOverviewRows.GetSection(text, color, note, picture)
    color = color or {r = GOLD[1], g = GOLD[2], b = GOLD[3]}
    return {type = "section", text = text, color = color, tag = note, picture = picture, state = color.r .. color.g .. color.b}
end

JourneyDetails.AddRowType("section", {
    isFullWidth = true,
    Create = function(part)
        part.Fade = part:CreateTexture(nil, "BACKGROUND")
        part.Fade:SetPoint("BOTTOMLEFT", part, "BOTTOMLEFT", 0, 2)
        part.Fade:SetPoint("RIGHT", part, "RIGHT", 0, 0)
        part.Fade:SetHeight(22)
        part.Ornament = part:CreateTexture(nil, "ARTWORK")
        part.Ornament:SetAtlas("Objective-Header")
        part.Ornament:SetPoint("BOTTOMLEFT", part, "BOTTOMLEFT", -14, -44) -- From the left edge, like the background
        part.Picture = part:CreateTexture(nil, "OVERLAY")
        part.Picture:SetPoint("CENTER", part, "BOTTOMLEFT", INSET + 4 + SECTION_PICTURE_SIZE / 2, 6 + SECTION_PICTURE_SIZE / 2)
        part.Title = part:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        part.Note = part:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        part.Note:SetPoint("BOTTOMRIGHT", part, "BOTTOMRIGHT", -INSET - 6, 9)
        QuestieOptionsUtils.DisableSnapping(part.Ornament)
    end,
    Update = function(part, data, width)
        local color = {data.color.r, data.color.g, data.color.b}
        _SetFade(part.Fade, color, 0.16)
        part.Ornament:SetSize(math.max(297, (width - 2 * INSET) * 0.75), 86)
        part.Ornament:SetDesaturated(true)
        part.Ornament:SetVertexColor(color[1], color[2], color[3])
        part.Picture:SetShown(data.picture ~= nil)
        if data.picture then
            _SetPicture(part.Picture, data.picture, SECTION_PICTURE_SIZE)
        end
        part.Title:SetPoint("BOTTOMLEFT", part, "BOTTOMLEFT", INSET + (data.picture and 28 or 8), 9)
        part.Title:SetTextColor(color[1], color[2], color[3])
        part.Title:SetText(data.text)
        part.Note:SetText(data.tag or "")
    end,
    GetHeight = function() return SECTION_HEIGHT end,
})

---The title of some tiles.
---@param text string
---@return JourneyDetails.Row
function JourneyOverviewRows.GetLabel(text)
    return {type = "label", text = text}
end

JourneyDetails.AddRowType("label", {
    Create = function(part)
        part.Title = part:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
        part.Title:SetPoint("BOTTOM", part, "BOTTOM", 0, 6)
        for _, side in ipairs({"LEFT", "RIGHT"}) do
            local isLeft = side == "LEFT"
            local line = part:CreateTexture(nil, "ARTWORK")
            line:SetPoint(side, part, side, 0, 0)
            line:SetPoint(isLeft and "RIGHT" or "LEFT", part.Title, side, isLeft and -8 or 8, 0)
            line:SetHeight(1.5)
            line:SetAtlas("Options_HorizontalDivider")
            line:SetTexCoord(isLeft and 1 or 0.4, isLeft and 0.4 or 1, 0, 1)
            line:SetAlpha(0.7)
        end
    end,
    Update = function(part, data) part.Title:SetText(data.text) end,
    GetHeight = function() return 24 end,
})

-------------------------
-- Zones
-------------------------

local ZONE_HEIGHT = 24
local ZONE_BAR_WIDTH = 96
local HERE_SIZE = 16
-- From the right edge to the right edge of the number
local SUITED_X, LOG_X = -ZONE_BAR_WIDTH - 12, -ZONE_BAR_WIDTH - 58

---@class JourneyOverviewRows.Zone
---@field name string
---@field color {r: number, g: number, b: number}?
---@field levels string?
---@field icon JourneyIcon.Icon?
---@field isHere boolean Whether the player is there
---@field suited number
---@field log number
---@field isLogComplete boolean
---@field completed number
---@field total number
---@field isOdd boolean Has a slightly brighter background
---@field onClick fun()
---@field showTooltip fun()

---@param zone JourneyOverviewRows.Zone
---@return JourneyDetails.Row
function JourneyOverviewRows.GetZone(zone)
    local state = table.concat({
        zone.name, zone.levels or "", tostring(zone.icon), tostring(zone.isHere), zone.suited, zone.log, tostring(zone.isLogComplete), zone.completed, zone.total,
        zone.color and zone.color.r .. zone.color.g .. zone.color.b or "",
    }, "\001")
    return {type = "zone", zone = zone, state = state}
end

---@param button Button
---@param x number
---@return FontString count
---@return Texture icon
local function _CreateCount(button, x)
    local count = button:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    count:SetPoint("RIGHT", button, "RIGHT", x, 0)
    local icon = JourneyIcon.Create(button)
    icon:SetPoint("RIGHT", button, "RIGHT", x - 18, 0)
    return count, icon
end

JourneyDetails.AddRowType("zone", {
    Create = function(part)
        local button = CreateFrame("Button", nil, part)
        button:SetAllPoints(part)
        button:SetHighlightAtlas("Options_List_Hover")
        part.Background = button:CreateTexture(nil, "BACKGROUND")
        part.Background:SetAllPoints(button)
        part.Background:SetColorTexture(1, 1, 1, 0.025)
        part.Icon = JourneyIcon.Create(button)
        part.Icon:SetPoint("CENTER", button, "LEFT", 12, 0)
        part.Here = button:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
        part.Here:SetPoint("CENTER", button, "LEFT", 12, 0)
        part.Here:SetText(JourneyIcon.GetHereMarkup(HERE_SIZE))
        part.Name = button:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
        part.Name:SetPoint("LEFT", button, "LEFT", 24, 0)
        part.Name:SetJustifyH("LEFT")
        part.Name:SetWordWrap(false)
        part.Levels = button:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
        part.Levels:SetPoint("LEFT", part.Name, "RIGHT", 8, -1)
        part.Suited, part.SuitedIcon = _CreateCount(button, SUITED_X)
        part.Log, part.LogIcon = _CreateCount(button, LOG_X)
        part.Bar = _CreateBar(button, 13)
        part.Bar:SetWidth(ZONE_BAR_WIDTH)
        part.Bar:SetPoint("RIGHT", button, "RIGHT", -4, 0)
        button:SetScript("OnClick", function()
            GameTooltip:Hide()
            part.data.zone.onClick()
        end)
        button:SetScript("OnEnter", function()
            GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
            part.data.zone.showTooltip()
            GameTooltip:Show()
        end)
        button:SetScript("OnLeave", function() GameTooltip:Hide() end)
        QuestieOptionsUtils.HideTooltipOnHide(button)
    end,
    Update = function(part, data, width)
        local zone = data.zone
        part.Background:SetShown(zone.isOdd)
        JourneyIcon.Set(part.Icon, not zone.isHere and zone.icon or nil)
        part.Here:SetShown(zone.isHere)
        local color = zone.color or {r = 0.85, g = 0.85, b = 0.85}
        part.Name:SetTextColor(color.r, color.g, color.b)
        part.Name:SetWidth(0)
        part.Name:SetText(zone.name)
        part.Levels:SetText(zone.levels or "")
        local space = width + LOG_X - 40 - 24 - part.Levels:GetStringWidth() - 8
        part.Name:SetWidth(math.max(1, math.min(part.Name:GetStringWidth() + 1, space)))
        part.Suited:SetText(zone.suited > 0 and zone.suited or "")
        JourneyIcon.Set(part.SuitedIcon, zone.suited > 0 and Questie.icons["available"] or nil)
        part.Log:SetText(zone.log > 0 and zone.log or "")
        JourneyIcon.Set(part.LogIcon, zone.log > 0 and Questie.icons[zone.isLogComplete and "complete" or "incomplete"] or nil)
        part.Bar:SetShown(zone.total > 0)
        _SetBar(part.Bar, zone.completed, zone.total, DONE_COLOR, _GetBarText(zone.completed, zone.total))
    end,
    GetHeight = function() return ZONE_HEIGHT end,
})

-------------------------
-- Factions
-------------------------

---@param name string
---@param standing JourneyFactions.Standing? Nil when the player hasn't met it
---@param isOdd boolean
---@param onClick fun()
---@return JourneyDetails.Row
function JourneyOverviewRows.GetFaction(name, standing, isOdd, onClick)
    return {type = "faction", text = name, standing = standing, isOdd = isOdd, onClick = onClick, state = standing and standing.reputation or ""}
end

JourneyDetails.AddRowType("faction", {
    Create = function(part)
        local button = CreateFrame("Button", nil, part)
        button:SetAllPoints(part)
        button:SetHighlightAtlas("Options_List_Hover")
        button:SetScript("OnClick", function() part.data.onClick() end)
        part.Background = button:CreateTexture(nil, "BACKGROUND")
        part.Background:SetAllPoints(button)
        part.Background:SetColorTexture(1, 1, 1, 0.025)
        part.Name = button:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
        part.Name:SetPoint("LEFT", button, "LEFT", 24, 0)
        part.Name:SetJustifyH("LEFT")
        part.Name:SetWordWrap(false)
        part.Bar = _CreateBar(button, 15)
        part.Bar:SetPoint("RIGHT", button, "RIGHT", -4, 0)
    end,
    Update = function(part, data, width)
        local standing = data.standing
        local barWidth = math.floor(width * 0.48)
        part.Background:SetShown(data.isOdd)
        part.Name:SetText(data.text)
        part.Name:SetWidth(math.max(1, width - barWidth - 40))
        part.Name:SetTextColor(standing and 1 or 0.6, standing and 1 or 0.6, standing and 1 or 0.6)
        part.Bar:SetShown(standing ~= nil)
        part.Bar:SetWidth(barWidth)
        if standing then
            local r, g, b = standing.color:GetRGB()
            _SetBar(part.Bar, standing.value, standing.size, {r, g, b}, standing.name .. "   " .. _GetBarText(standing.value, standing.size))
        end
    end,
    GetHeight = function() return ZONE_HEIGHT end,
})

return JourneyOverviewRows
