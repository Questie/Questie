---The details next to the list of a Journey Tab, as a scrolling list of rows.
---
---What is shown is plain data, see JourneyDetails.Row. Each type of row has one function that creates its parts and one
---that updates them, like the settings' controls. Only the rows on screen have frames, which are reused.
---@class JourneyDetails
local JourneyDetails = QuestieLoader:CreateModule("JourneyDetails")

---@type JourneyIcon
local JourneyIcon = QuestieLoader:ImportModule("JourneyIcon")
---@type JourneyScrollBox
local JourneyScrollBox = QuestieLoader:ImportModule("JourneyScrollBox")
---@type QuestieOptionsControls
local QuestieOptionsControls = QuestieLoader:ImportModule("QuestieOptionsControls")
---@type QuestieOptionsUtils
local QuestieOptionsUtils = QuestieLoader:ImportModule("QuestieOptionsUtils")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

-- Of what is in front of a value, like the level. Quieter than the headings and the values.
JourneyDetails.LABEL_COLOR = "E0D2B0"

local ROW_INSET = 8
-- For a row type that fills the whole row
JourneyDetails.ROW_INSET = ROW_INSET
local END_SPACE = 14 -- Below the last row, so it doesn't look cut off
local HEADING_FONT = "GameFontNormalMed1"
local HEADING_LINES_WIDTH = 80 -- Left for the lines on both sides of a long heading
local PICTURE_SIZE = 46
local PICTURE_GAP = 10
local BADGE_SIZE, BADGE_ONLY_SIZE = 22, 30
-- From the lower right corner of the picture. Two badges overlap and are tilted, like cards in a hand. Set by eye in the client.
local SINGLE_BADGE = {x = -4, y = 6, degrees = 0}
local TWO_BADGES = {{x = -12, y = 8, degrees = 16}, {x = -3, y = 8.3, degrees = -8}}
local ITEM_TOOLTIP_PADDING = 4
local UNKNOWN_ITEM_TOOLTIP_HEIGHT = 60
local ITEM_TOOLTIP_UPDATES, ITEM_TOOLTIP_UPDATE_SECONDS = 10, 0.5
local UNKNOWN_ICON = 134400 -- Interface\Icons\INV_Misc_QuestionMark
local PORTRAIT_ATTEMPTS = 50
local PORTRAIT_RETRY_SECONDS = 0.1
-- The button for the map in Blizzard's quest log. The image is the same on every supported client, also on those whose quest
-- log doesn't have the button (checked in the files of each).
local MAP_TEXTURE = 316593 -- Interface\QuestFrame\UI-QuestMap_Button
local MAP_WIDTH, MAP_HEIGHT = 48, 32
local ACTION_SIZE = 20
local STATUS_HEIGHT = 24
local PAGE_FONT, PAGE_TAG_FONT = "GameFontNormalLarge", "GameFontDisableSmall"
local PAGE_HEIGHT = 32
-- Above and below the title of a page that takes more than one line, with the line below it
local PAGE_TITLE_SPACE = 15
-- Left of the tag of a page, and right of it
local PAGE_TAG_SPACE = 12
local STEP_TEXT_X = 26
local BAR_TEXTURE = "Interface\\TargetingFrame\\UI-StatusBar"
local STANDING_BAR_HEIGHT = 18
local FOOTER_HEIGHT, FOOTER_BUTTON_HEIGHT, FOOTER_GAP, FOOTER_ICON_WIDTH, FOOTER_PADDING = 30, 22, 16, 20, 10

---@class JourneyDetails.Row
---@field type string One of those below, or of those that were added with AddRowType: "heading"|"text"|"checkbox"|"button"|"entity"|"itemTooltip"|"gap"|"page"|"caption"|"status"|"step"|"footer"|"standing"
---@field text string? Finished text. It is never translated or formatted, because it can contain names and notes.
---@field title string? For the type entity, above the text
---@field tag string? For the types page and step, at its right edge while all of the text fits next to it
---@field buttons {text: string, icon: JourneyIcon.Icon, onClick: fun()}[]? For the type footer
---@field onShowMap fun()? For the types status and entity, a button with a text at the right edge
---@field action {tooltip: string, isOn: boolean?, onClick: fun()}? For the types step and entity, a small map at the right edge
---@field font string? For the type text, a font object
---@field height number? For the type gap
---@field standing JourneyFactions.Standing? For the type standing
---@field gain number? For the type standing, reputation that would be added to it
---@field onClick fun()? For the types step, button and entity, and the icon of the type itemTooltip
---@field showTooltip fun()? For the types step, checkbox and entity. Fills the tooltip that was opened at the row.
---@field npcId NpcId? For the type entity, shows a portrait of the NPC
---@field badges JourneyIcon.Icon[]? For the type entity, up to two icons at the lower right corner of the picture, or instead of one
---@field trailingIcon JourneyIcon.Icon? For the type text, behind it
---@field icon number|string|nil For the types entity and itemTooltip, in front of what it shows
---@field itemId ItemId? For the type itemTooltip
---@field get fun(): boolean For the type checkbox
---@field set fun()? For the type checkbox

---Measures text without showing it
---@type FontString
local measuringText

---@param text string
---@param font string
---@param width number
---@return number height
local function _MeasureText(text, font, width)
    measuringText = measuringText or UIParent:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    measuringText:Hide()
    measuringText:SetFontObject(font)
    measuringText:SetWidth(width)
    measuringText:SetWordWrap(true)
    measuringText:SetText(text)
    return math.ceil(measuringText:GetStringHeight())
end

---@param row Frame
---@param font string
---@return FontString
local function _CreateWrappingText(row, font)
    local text = row:CreateFontString(nil, "ARTWORK", font)
    text:SetJustifyH("LEFT")
    text:SetJustifyV("TOP")
    text:SetWordWrap(true)
    text:SetPoint("TOPLEFT", row, "TOPLEFT", 0, 0)
    return text
end

---@param data JourneyDetails.Row
---@return number x Behind the picture, if there is one
local function _GetEntityTextX(data)
    return (data.npcId or data.icon or data.badges) and PICTURE_SIZE + PICTURE_GAP or 0
end

---@param text string
---@param font string
---@return number width On one line
local function _GetTextWidth(text, font)
    _MeasureText(text, font, 0)
    return measuringText:GetUnboundedStringWidth()
end

---The title comes first: the tag is only shown while all of the title fits next to it.
---@param data JourneyDetails.Row
---@param width number
---@return boolean
local function _ShowsPageTag(data, width)
    return (data.tag or "") ~= "" and _GetTextWidth(data.text, PAGE_FONT) + _GetTextWidth(data.tag, PAGE_TAG_FONT) + PAGE_TAG_SPACE <= width
end

---@return number
local function _GetShowMapWidth()
    _MeasureText(SHOW_MAP, "GameFontNormal", 0)
    return math.ceil(measuringText:GetStringWidth()) + MAP_WIDTH
end

---@param data JourneyDetails.Row
---@return number width Left free for what is at the right edge
local function _GetRightWidth(data)
    if data.onShowMap then
        return _GetShowMapWidth()
    end
    return data.action and ACTION_SIZE + 14 or 0
end

---@param data JourneyDetails.Row
---@param width number
---@return number textWidth
local function _GetEntityTextWidth(data, width)
    return math.max(1, width - _GetEntityTextX(data) - _GetRightWidth(data))
end

---Whether there is a model, which can still be loading. The display doesn't tell, because it stays the one of the NPC before.
---@param model Frame
---@return boolean
local function _HasModel(model)
    local file = model:GetModelFileID()
    return file ~= nil and file ~= 0
end

---Shows an NPC's face, when it is loaded. The client asks the server about an NPC it hasn't seen yet, and doesn't show it when it
---gets the answer, so it has to be asked again.
---@param part Frame
---@param npcId NpcId
---@param attempts number
local function _ShowPortrait(part, npcId, attempts)
    if not part.Model then
        part.Model = CreateFrame("PlayerModel", nil, part.Picture)
        part.Model:SetAllPoints(part.Picture)
        part.Model:SetScript("OnModelLoaded", function(model)
            model:SetPortraitZoom(1)
            part.Icon:SetShown(not _HasModel(model))
        end)
    end

    part.Icon:Show()
    part.Model:ClearModel()
    part.Model:SetCreature(npcId)
    part.Model:SetPortraitZoom(1)

    if not _HasModel(part.Model) and attempts > 1 then
        part.portraitTimer = C_Timer.NewTimer(PORTRAIT_RETRY_SECONDS, function()
            if part:IsVisible() then
                _ShowPortrait(part, npcId, attempts - 1)
            end
        end)
    end
end

---A frame that shows a tooltip while the mouse is over it, if its row has one.
---@param frame Frame
---@param part Frame
---@param anchor string
local function _AddTooltip(frame, part, anchor)
    frame:HookScript("OnEnter", function()
        if part.data.showTooltip then
            GameTooltip:SetOwner(frame, anchor)
            part.data.showTooltip()
            GameTooltip:Show()
        end
    end)
    frame:HookScript("OnLeave", function() GameTooltip:Hide() end)
    QuestieOptionsUtils.HideTooltipOnHide(frame)
end

-- There is only one, because nothing shows the details of several items
---@type GameTooltip
local itemTooltip
---@type Ticker?
local itemTooltipTicker

---@type table<ItemId, number>
local itemTooltipHeights = {}

---Shows the tooltip of an item inside its row, which becomes as high as it.
---@param part Frame
local function _ShowItemTooltip(part)
    local itemId = part.data.itemId
    if not itemTooltip then
        itemTooltip = CreateFrame("GameTooltip", "QuestieJourneyItemTooltip", part, "GameTooltipTemplate")
        -- Otherwise it moves over other rows while its own is only partly on the screen
        itemTooltip:SetClampedToScreen(false)
    end
    itemTooltip:SetParent(part)
    itemTooltip:SetOwner(part, "ANCHOR_NONE")
    itemTooltip:ClearAllPoints()
    itemTooltip:SetPoint("TOPLEFT", part, "TOPLEFT", _GetEntityTextX(part.data), -ITEM_TOOLTIP_PADDING)

    local function UpdateHeight()
        local height = math.ceil(itemTooltip:GetHeight()) + 2 * ITEM_TOOLTIP_PADDING
        if itemTooltip:IsShown() and itemTooltipHeights[itemId] ~= height then
            itemTooltipHeights[itemId] = height
            part.onHeightChanged()
        end
    end
    local function UpdateText()
        itemTooltip:SetItemByID(itemId)
        itemTooltip:Show()
        UpdateHeight()
    end
    itemTooltip:SetScript("OnSizeChanged", UpdateHeight)
    UpdateText()
    itemTooltip:SetFrameStrata(part:GetFrameStrata())
    itemTooltip:SetFrameLevel(part:GetFrameLevel() + 1)

    -- The client loads what it doesn't know yet about the item, and then about its spells. Like for Blizzard's own tooltips,
    -- it has to be asked again and again, because no event tells every client that all of it arrived.
    if itemTooltipTicker then
        itemTooltipTicker:Cancel()
    end
    itemTooltipTicker = C_Timer.NewTicker(ITEM_TOOLTIP_UPDATE_SECONDS, function()
        if part:IsVisible() then
            UpdateText()
        end
    end, ITEM_TOOLTIP_UPDATES)
end

---@param icon Texture
---@param isPushed boolean
local function _SetMapPushed(icon, isPushed)
    local top = isPushed and 0.5 or 0
    icon:SetTexCoord(0.125, 0.875, top, top + 0.5)
end

---Blizzard's button that opens the map.
---@param part Frame
---@param owner Frame
local function _CreateShowMap(part, owner)
    local button = CreateFrame("Button", nil, owner)
    button:SetSize(_GetShowMapWidth(), MAP_HEIGHT)
    button:SetFrameLevel(owner:GetFrameLevel() + 2)

    local icon = button:CreateTexture(nil, "ARTWORK")
    icon:SetPoint("RIGHT", button, "RIGHT", 0, 0)
    icon:SetSize(MAP_WIDTH, MAP_HEIGHT)
    icon:SetTexture(MAP_TEXTURE)
    _SetMapPushed(icon, false)

    local text = button:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    text:SetPoint("RIGHT", icon, "LEFT", 0, 0)
    text:SetText(SHOW_MAP)

    local highlight = button:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetTexture("Interface\\Buttons\\ButtonHilight-Square")
    highlight:SetBlendMode("ADD")
    highlight:SetPoint("CENTER", icon, "CENTER", 0, 0)
    highlight:SetSize(36, 25)

    button:SetScript("OnMouseDown", function() _SetMapPushed(icon, true) end)
    button:SetScript("OnMouseUp", function() _SetMapPushed(icon, false) end)
    button:SetScript("OnClick", function() part.data.onShowMap() end)
    part.ShowMap = button
end

---@param part Frame
---@param owner Frame
local function _CreateAction(part, owner)
    local action = CreateFrame("Button", nil, owner)
    action:SetSize(ACTION_SIZE + 8, ACTION_SIZE + 4)
    action:SetFrameLevel(owner:GetFrameLevel() + 2)
    action.Icon = action:CreateTexture(nil, "ARTWORK")
    action.Icon:SetPoint("CENTER")
    action.Icon:SetSize(ACTION_SIZE, ACTION_SIZE)
    action.Icon:SetTexture(JourneyIcon.MAP)
    action:SetHighlightAtlas("Options_List_Hover")
    action:SetScript("OnClick", function()
        GameTooltip:Hide()
        part.data.action.onClick()
    end)
    action:SetScript("OnEnter", function()
        GameTooltip:SetOwner(action, "ANCHOR_RIGHT")
        GameTooltip:SetText(part.data.action.tooltip, 1, 1, 1)
        GameTooltip:Show()
    end)
    action:SetScript("OnLeave", function() GameTooltip:Hide() end)
    QuestieOptionsUtils.HideTooltipOnHide(action)
    part.Action = action
end

---@param part Frame
---@param data JourneyDetails.Row
local function _UpdateAction(part, data)
    part.Action:SetShown(data.action ~= nil)
    if data.action then
        part.Action.Icon:SetDesaturated(not data.action.isOn)
        part.Action.Icon:SetAlpha(data.action.isOn and 1 or 0.75)
    end
end

---@param part Frame
---@param data JourneyDetails.Row
local function _ShowBadges(part, data)
    local badges = data.badges or {}
    local hasPicture = data.npcId or data.icon
    local size = hasPicture and BADGE_SIZE or BADGE_ONLY_SIZE
    for index, texture in ipairs(part.Badges) do
        JourneyIcon.Set(texture, badges[index])
        texture:SetSize(size, size)
        if hasPicture then
            local place = #badges == 2 and TWO_BADGES[index] or SINGLE_BADGE
            texture:SetPoint("CENTER", part.Picture, "BOTTOMRIGHT", place.x, place.y)
            texture:SetRotation(math.rad(place.degrees))
        else
            texture:SetPoint("CENTER", part.Picture, "CENTER", #badges == 1 and 0 or index == 1 and -10 or 10, 0)
            texture:SetRotation(0)
        end
    end
end

---@class JourneyDetails.RowType
---@field isFullWidth boolean? Its part fills the whole row, so that a background can reach the edges. It keeps ROW_INSET free for the rest.
---@field Create fun(part: Frame)
---@field Update fun(part: Frame, data: JourneyDetails.Row, width: number)
---@field GetHeight fun(data: JourneyDetails.Row, width: number): number

---@type table<string, JourneyDetails.RowType>
local ROW_TYPES = {
    heading = {
        Create = function(part)
            local title = part:CreateFontString(nil, "OVERLAY", HEADING_FONT)
            title:SetPoint("CENTER", part, "CENTER", 0, 0)
            title:SetWordWrap(true)
            part.Title = title

            local left = part:CreateTexture(nil, "ARTWORK")
            left:SetPoint("LEFT", part, "LEFT", 0, 0)
            left:SetPoint("RIGHT", title, "LEFT", -6, 0)
            left:SetAtlas("Options_HorizontalDivider", true)
            left:SetTexCoord(1, 0.4, 0, 1)

            local right = part:CreateTexture(nil, "ARTWORK")
            right:SetPoint("LEFT", title, "RIGHT", 6, 0)
            right:SetPoint("RIGHT", part, "RIGHT", 0, 0)
            right:SetAtlas("Options_HorizontalDivider", true)
            right:SetTexCoord(0.4, 1, 0, 1)

            QuestieOptionsUtils.DisableSnapping(left)
            QuestieOptionsUtils.DisableSnapping(right)
        end,
        Update = function(part, data, width)
            part.Title:SetWidth(0) -- As wide as the text
            part.Title:SetText(data.text)
            part.Title:SetWidth(math.min(part.Title:GetStringWidth() + 1, width - HEADING_LINES_WIDTH))
        end,
        GetHeight = function(data, width)
            return _MeasureText(data.text, HEADING_FONT, width - HEADING_LINES_WIDTH) + 12
        end,
    },

    -- What the whole page is about. Its title is never cut off, but takes more lines when it doesn't fit on one.
    page = {
        Create = function(part)
            part.Tag = part:CreateFontString(nil, "ARTWORK", PAGE_TAG_FONT)
            part.Tag:SetPoint("TOPRIGHT", part, "TOPRIGHT", -4, -9)
            part.Title = _CreateWrappingText(part, PAGE_FONT)
            part.Title:SetPoint("TOPLEFT", part, "TOPLEFT", 0, -6)
            local line = part:CreateTexture(nil, "ARTWORK")
            line:SetAtlas("Options_HorizontalDivider")
            line:SetPoint("BOTTOMLEFT", part, "BOTTOMLEFT", 0, 1)
            line:SetPoint("BOTTOMRIGHT", part, "BOTTOMRIGHT", 0, 1)
            line:SetHeight(1.5)
        end,
        Update = function(part, data, width)
            part.Tag:SetShown(_ShowsPageTag(data, width))
            part.Tag:SetText(data.tag)
            part.Title:SetWidth(width) -- Next to the tag, the title fits anyway
            part.Title:SetText(data.text)
        end,
        GetHeight = function(data, width)
            if _ShowsPageTag(data, width) then
                return PAGE_HEIGHT
            end
            return math.max(PAGE_HEIGHT, _MeasureText(data.text, PAGE_FONT, width) + PAGE_TITLE_SPACE)
        end,
    },

    -- The title of a section, with a line next to it
    caption = {
        Create = function(part)
            part.Title = part:CreateFontString(nil, "ARTWORK", "GameFontNormal")
            part.Title:SetPoint("BOTTOMLEFT", part, "BOTTOMLEFT", 0, 4)
            local line = part:CreateTexture(nil, "ARTWORK")
            line:SetPoint("LEFT", part.Title, "RIGHT", 8, 0)
            line:SetPoint("RIGHT", part, "RIGHT", 0, 0)
            line:SetHeight(1.5)
            line:SetAtlas("Options_HorizontalDivider")
            line:SetTexCoord(0.4, 1, 0, 1)
            line:SetAlpha(0.6)
        end,
        Update = function(part, data) part.Title:SetText(data.text) end,
        GetHeight = function() return 30 end,
    },

    -- What can be done with a quest
    status = {
        Create = function(part)
            part.Text = _CreateWrappingText(part, "GameFontHighlight")
            _CreateShowMap(part, part)
            part.ShowMap:SetPoint("RIGHT", part, "RIGHT", -2, 0)
        end,
        Update = function(part, data, width)
            part.Text:SetWidth(width - _GetRightWidth(data))
            part.Text:SetText(data.text)
            part.Text:ClearAllPoints()
            part.Text:SetPoint("LEFT", part, "LEFT", 0, 0)
            part.ShowMap:SetShown(data.onShowMap ~= nil)
        end,
        GetHeight = function(data, width)
            return math.max(STATUS_HEIGHT, _MeasureText(data.text, "GameFontHighlight", width - _GetRightWidth(data)) + 4)
        end,
    },

    -- One of several things in an order, like the quests of a chain
    step = {
        Create = function(part)
            local button = CreateFrame("Button", nil, part)
            button:SetAllPoints(part)
            button:SetHighlightAtlas("Options_List_Hover")
            part.Button = button
            part.Background = button:CreateTexture(nil, "BACKGROUND")
            part.Background:SetAllPoints(button)
            part.Background:SetAtlas("Options_List_Active")
            part.Icon = JourneyIcon.Create(button)
            part.Icon:SetPoint("CENTER", button, "LEFT", 12, 0)
            part.Text = button:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
            part.Text:SetPoint("LEFT", button, "LEFT", STEP_TEXT_X, 0)
            part.Text:SetJustifyH("LEFT")
            part.Text:SetWordWrap(false)
            part.Note = button:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
            button:SetScript("OnClick", function()
                GameTooltip:Hide()
                if part.data.onClick then part.data.onClick() end
            end)
            _AddTooltip(button, part, "ANCHOR_CURSOR")
            _CreateAction(part, button)
            part.Action:SetPoint("RIGHT", button, "RIGHT", -2, 0)
        end,
        Update = function(part, data, width)
            part.Background:SetShown(data.isCurrent == true)
            JourneyIcon.Set(part.Icon, data.trailingIcon)
            part.Text:SetText(data.text)
            part.Note:SetText(data.tag or "")
            -- The name comes first: the tag is only shown while all of the name fits next to it
            local right = data.action and ACTION_SIZE + 14 or 8
            local tagSpace = data.tag and part.Note:GetUnboundedStringWidth() + 8 or 0
            local showsTag = tagSpace > 0 and part.Text:GetUnboundedStringWidth() + tagSpace <= width - STEP_TEXT_X - right
            part.Note:SetShown(showsTag)
            part.Note:SetPoint("RIGHT", part.Button, "RIGHT", 2 - right, 0) -- Left of the small map, if there is one
            part.Text:SetPoint("RIGHT", part.Button, "RIGHT", -right - (showsTag and tagSpace or 0), 0)
            part.Button:EnableMouse(data.onClick ~= nil)
            _UpdateAction(part, data)
        end,
        GetHeight = function() return 21 end,
    },

    text = {
        Create = function(part)
            part.Text = _CreateWrappingText(part, "GameFontHighlight")
            part.Icon = JourneyIcon.Create(part)
        end,
        Update = function(part, data, width)
            part.Text:SetFontObject(data.font or "GameFontHighlight")
            part.Text:SetWidth(width)
            part.Text:SetText(data.text)
            part.Icon:SetPoint("LEFT", part.Text, "LEFT", part.Text:GetStringWidth(), 0)
            JourneyIcon.Set(part.Icon, data.trailingIcon)
        end,
        GetHeight = function(data, width)
            return _MeasureText(data.text, data.font or "GameFontHighlight", width) + 4
        end,
    },

    checkbox = {
        Create = function(part)
            part.control = QuestieOptionsControls.Create(part, {
                type = "checkbox",
                title = " ",
                get = function() return part.data and part.data.get() end,
                set = function() part.data.set() end,
            }, 300, 1)
            part.control:SetPoint("TOPLEFT", part, "TOPLEFT", 0, 0)
            _AddTooltip(part.control, part, "ANCHOR_LEFT")
        end,
        Update = function(part, data)
            part.control.titleFrame:SetText(data.text)
            QuestieOptionsControls.Refresh(part.control)
        end,
        GetHeight = function() return 30 end,
    },

    button = {
        Create = function(part)
            part.control = QuestieOptionsControls.Create(part, {
                type = "button",
                title = "",
                btnLabel = " ",
                align = "LEFT",
                func = function() part.data.onClick() end,
            }, 300, 1)
            part.control:SetPoint("TOPLEFT", part, "TOPLEFT", 0, 0)
        end,
        Update = function(part, data)
            part.control.widget:SetText(data.text)
        end,
        GetHeight = function() return 40 end,
    },

    -- An NPC, object or item: a picture with text next to it
    entity = {
        Create = function(part)
            local button = CreateFrame("Button", nil, part)
            button:SetAllPoints(part)
            button:SetHighlightAtlas("Options_List_Hover")
            button:SetScript("OnClick", function()
                GameTooltip:Hide()
                part.data.onClick()
            end)
            _AddTooltip(button, part, "ANCHOR_CURSOR")
            part.Button = button

            local picture = CreateFrame("Frame", nil, button)
            picture:SetPoint("TOPLEFT", part, "TOPLEFT", 0, -2)
            picture:SetSize(PICTURE_SIZE, PICTURE_SIZE)
            part.Picture = picture

            part.Icon = picture:CreateTexture(nil, "ARTWORK")
            part.Icon:SetAllPoints(picture)

            local badges = CreateFrame("Frame", nil, button)
            badges:SetAllPoints(picture)
            badges:SetFrameLevel(picture:GetFrameLevel() + 10) -- Above the model of an NPC
            part.Badges = {JourneyIcon.Create(badges), JourneyIcon.Create(badges)}
            part.Badges[2]:SetDrawLayer("ARTWORK", 1) -- In front of the first
            for _, badge in ipairs(part.Badges) do
                QuestieOptionsUtils.DisableSnapping(badge) -- Otherwise they can end up a pixel apart
            end

            local title = button:CreateFontString(nil, "ARTWORK", "GameFontNormal")
            title:SetJustifyH("LEFT")
            title:SetWordWrap(true)
            part.Title = title
            part.Text = _CreateWrappingText(button, "GameFontHighlight")
            _CreateAction(part, button)
            part.Action:SetPoint("TOPRIGHT", part, "TOPRIGHT", -2, -2)
            _CreateShowMap(part, button)
            part.ShowMap:SetPoint("TOPRIGHT", part, "TOPRIGHT", -2, -2)
        end,
        Update = function(part, data, width)
            local textWidth = _GetEntityTextWidth(data, width)
            local x = _GetEntityTextX(data)

            part.Button:EnableMouse(data.onClick ~= nil)
            _UpdateAction(part, data)
            part.ShowMap:SetShown(data.onShowMap ~= nil)

            part.Picture:SetShown(data.npcId ~= nil or data.icon ~= nil)
            part.Icon:SetTexture(data.icon)
            part.Icon:Show()
            if part.portraitTimer then
                part.portraitTimer:Cancel()
            end
            if part.Model then
                part.Model:SetShown(data.npcId ~= nil)
            end
            if data.npcId then
                part.Icon:SetTexture(UNKNOWN_ICON)
                _ShowPortrait(part, data.npcId, PORTRAIT_ATTEMPTS)
            end

            _ShowBadges(part, data)

            part.Title:SetShown(data.title ~= nil)
            part.Title:SetPoint("TOPLEFT", part, "TOPLEFT", x, -2)
            part.Title:SetWidth(textWidth)
            part.Title:SetText(data.title)
            part.Text:SetWidth(textWidth)
            part.Text:SetText(data.text)
            part.Text:ClearAllPoints()
            if data.title then
                part.Text:SetPoint("TOPLEFT", part.Title, "BOTTOMLEFT", 0, -2)
            else
                part.Text:SetPoint("TOPLEFT", part, "TOPLEFT", x, -2)
            end
        end,
        GetHeight = function(data, width)
            local textWidth = _GetEntityTextWidth(data, width)
            local height = _MeasureText(data.text, "GameFontHighlight", textWidth) + 6
            if data.title then
                height = height + _MeasureText(data.title, "GameFontNormal", textWidth) + 2
            end
            if data.onShowMap then
                height = math.max(height, MAP_HEIGHT + 2)
            end
            return (data.npcId or data.icon or data.badges) and math.max(height, PICTURE_SIZE + 6) or height
        end,
    },

    -- The game's tooltip of an item, with its icon in front of it like a button in the bags
    itemTooltip = {
        Create = function(part)
            local button = CreateFrame("Button", nil, part)
            button:SetPoint("TOPLEFT", part, "TOPLEFT", 0, -ITEM_TOOLTIP_PADDING)
            button:SetSize(PICTURE_SIZE, PICTURE_SIZE)
            button:SetScript("OnClick", function() part.data.onClick() end)
            part.Icon = button:CreateTexture(nil, "ARTWORK")
            part.Icon:SetAllPoints(button)
            local highlight = button:CreateTexture(nil, "HIGHLIGHT")
            highlight:SetTexture("Interface\\Buttons\\ButtonHilight-Square")
            highlight:SetBlendMode("ADD")
            highlight:SetAllPoints(button)
            part.IconButton = button
        end,
        Update = function(part, data)
            part.IconButton:SetShown(data.icon ~= nil)
            part.IconButton:EnableMouse(data.onClick ~= nil)
            part.Icon:SetTexture(data.icon)
            _ShowItemTooltip(part)
        end,
        GetHeight = function(data)
            local height = itemTooltipHeights[data.itemId] or UNKNOWN_ITEM_TOOLTIP_HEIGHT
            return data.icon and math.max(height, PICTURE_SIZE + 2 * ITEM_TOOLTIP_PADDING) or height
        end,
    },

    -- A bar like the ones in Blizzard's list of factions, below a name if there is one
    standing = {
        Create = function(part)
            local button = CreateFrame("Button", nil, part)
            button:SetAllPoints(part)
            button:SetHighlightAtlas("Options_List_Hover")
            button:SetScript("OnClick", function() part.data.onClick() end)
            part.Button = button
            part.Title = button:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
            part.Title:SetPoint("TOPLEFT", button, "TOPLEFT", 2, -3)

            local bar = CreateFrame("StatusBar", nil, button)
            bar:SetPoint("BOTTOMLEFT", button, "BOTTOMLEFT", 2, 3)
            bar:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -2, 3)
            bar:SetHeight(STANDING_BAR_HEIGHT)
            bar:SetStatusBarTexture(BAR_TEXTURE)
            part.Bar = bar
            local background = bar:CreateTexture(nil, "BACKGROUND")
            background:SetAllPoints(bar)
            background:SetColorTexture(0, 0, 0, 0.45)
            part.Gain = bar:CreateTexture(nil, "BORDER")
            part.Gain:SetTexture(BAR_TEXTURE)
            part.Gain:SetPoint("TOPLEFT", bar:GetStatusBarTexture(), "TOPRIGHT", 0, 0)
            part.Gain:SetPoint("BOTTOMLEFT", bar:GetStatusBarTexture(), "BOTTOMRIGHT", 0, 0)
            for _, edge in ipairs({{"TOPLEFT", "TOPRIGHT"}, {"BOTTOMLEFT", "BOTTOMRIGHT"}, {"TOPLEFT", "BOTTOMLEFT"}, {"TOPRIGHT", "BOTTOMRIGHT"}}) do
                local texture = bar:CreateTexture(nil, "OVERLAY")
                texture:SetColorTexture(0.45, 0.36, 0.22, 0.9)
                texture:SetPoint(edge[1], bar, edge[1])
                texture:SetPoint(edge[2], bar, edge[2])
                texture:SetSize(1.2, 1.2)
            end
            part.Text = bar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            part.Text:SetPoint("CENTER")
        end,
        Update = function(part, data, width)
            local standing = data.standing
            local r, g, b = standing.color:GetRGB()
            part.Button:EnableMouse(data.onClick ~= nil)
            part.Title:SetText(data.text or "")
            part.Bar:SetMinMaxValues(0, standing.size)
            part.Bar:SetValue(standing.value)
            part.Bar:SetStatusBarColor(r, g, b)
            local share = math.min(data.gain or 0, standing.size - standing.value) / standing.size
            part.Gain:SetShown(share > 0)
            part.Gain:SetWidth(math.max(1, share * (width - 4)))
            part.Gain:SetVertexColor(r, g, b, 0.35)
            part.Text:SetText(standing.name .. "   " .. BreakUpLargeNumbers(standing.value) .. " / " .. BreakUpLargeNumbers(standing.size))
        end,
        GetHeight = function(data) return STANDING_BAR_HEIGHT + 6 + (data.text and 18 or 0) end,
    },

    gap = {
        Create = function() end,
        Update = function() end,
        GetHeight = function(data) return data.height end,
    },
}

-------------------------
-- Rows
-------------------------

---@param data JourneyDetails.Row
---@return number inset Between the row and its part, on both sides
local function _GetInset(data)
    if ROW_TYPES[data.type].isFullWidth then
        return 0
    end
    return ROW_INSET
end

---@param data JourneyDetails.Row
---@param rowWidth number
---@return number
local function _GetContentWidth(data, rowWidth)
    return math.max(1, rowWidth - 2 * _GetInset(data))
end

---@param data JourneyDetails.Row
---@param rowWidth number
---@return number
local function _GetRowHeight(data, rowWidth)
    return ROW_TYPES[data.type].GetHeight(data, _GetContentWidth(data, rowWidth))
end

---Fills a row, which may have shown something else before.
---@param row Frame
---@param data JourneyDetails.Row
---@param rowWidth number
---@param onHeightChanged fun() For parts whose height can change later
local function _InitializeRow(row, data, rowWidth, onHeightChanged)
    row.parts = row.parts or {}
    for rowType, part in pairs(row.parts) do
        part:SetShown(rowType == data.type)
    end

    local part = row.parts[data.type]
    if not part then
        part = CreateFrame("Frame", nil, row)
        row.parts[data.type] = part
        part.onHeightChanged = onHeightChanged
        part.data = data
        ROW_TYPES[data.type].Create(part)
    end

    local inset = _GetInset(data)
    part:SetPoint("TOPLEFT", row, "TOPLEFT", inset, 0)
    part:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", -inset, 0)
    part.data = data
    ROW_TYPES[data.type].Update(part, data, _GetContentWidth(data, rowWidth))
end

-------------------------
-- Footer
-------------------------

---@param footer Frame
---@return Button
local function _CreateFooterButton(footer)
    local button = CreateFrame("Button", nil, footer)
    button:SetHeight(FOOTER_BUTTON_HEIGHT)
    button:SetHighlightAtlas("Options_List_Hover")
    button.Icon = JourneyIcon.Create(button)
    button.Icon:SetPoint("CENTER", button, "LEFT", FOOTER_PADDING + 8, 0)
    button.Text = button:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
    button.Text:SetPoint("LEFT", button, "LEFT", FOOTER_PADDING + FOOTER_ICON_WIDTH, 0)
    button:SetScript("OnEnter", function() button.Text:SetFontObject("GameFontHighlightSmall") end)
    button:SetScript("OnLeave", function() button.Text:SetFontObject("GameFontDisableSmall") end)
    button:SetScript("OnClick", function() button.onClick() end)
    return button
end

---@param parent Frame
---@return Frame footer Below what can be scrolled
local function _CreateFooter(parent)
    local footer = CreateFrame("Frame", nil, parent)
    footer:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", ROW_INSET, 2)
    footer:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -ROW_INSET, 2)
    footer:SetHeight(FOOTER_HEIGHT)
    footer.buttons = {}

    local line = footer:CreateTexture(nil, "ARTWORK")
    line:SetAtlas("Options_HorizontalDivider")
    line:SetPoint("TOPLEFT", footer, "TOPLEFT", 0, 0)
    line:SetPoint("TOPRIGHT", footer, "TOPRIGHT", 0, 0)
    line:SetHeight(1.5)
    line:SetAlpha(0.6)

    footer:Hide()
    return footer
end

---@param footer Frame
---@param data JourneyDetails.Row?
local function _ShowFooter(footer, data)
    footer:SetShown(data ~= nil)
    local buttons = data and data.buttons or {}

    local totalWidth = (#buttons - 1) * FOOTER_GAP
    for index, content in ipairs(buttons) do
        local button = footer.buttons[index] or _CreateFooterButton(footer)
        footer.buttons[index] = button
        button.onClick = content.onClick
        button.Text:SetText(content.text)
        JourneyIcon.Set(button.Icon, content.icon)
        button:SetWidth(math.ceil(button.Text:GetStringWidth()) + FOOTER_ICON_WIDTH + 2 * FOOTER_PADDING)
        button:Show()
        totalWidth = totalWidth + button:GetWidth()
    end
    for index = #buttons + 1, #footer.buttons do
        footer.buttons[index]:Hide()
    end

    local x = -totalWidth / 2
    for index = 1, #buttons do
        local button = footer.buttons[index]
        button:SetPoint("LEFT", footer, "CENTER", x, -1)
        x = x + button:GetWidth() + FOOTER_GAP
    end
end

---@class JourneyDetails.Instance
---@field scrollBox Frame
---@field parent Frame
---@field scrollArea Frame Ends above the footer, if there is one
---@field footer Frame
---@field rows JourneyDetails.Row[]
---@field heights table<JourneyDetails.Row, number> Those measured already, as scrolling asks for them again and again

---@param details JourneyDetails.Instance
---@param keepsScrollPosition boolean
local function _ShowRows(details, keepsScrollPosition)
    details.heights = {}
    local rows, footer = {}, nil
    for _, row in ipairs(details.rows) do
        if row.type == "footer" then
            footer = row
        else
            table.insert(rows, row)
        end
    end
    _ShowFooter(details.footer, footer)
    details.scrollArea:SetPoint("BOTTOMRIGHT", details.parent, "BOTTOMRIGHT", 0, footer and FOOTER_HEIGHT or 0)
    details.scrollBox:SetDataProvider(
        CreateDataProvider(rows),
        keepsScrollPosition and ScrollBoxConstants.RetainScrollPosition or ScrollBoxConstants.DiscardScrollPosition
    )
end

---Adds a type of row, for what is only shown in one place.
---@param name string
---@param rowType JourneyDetails.RowType
function JourneyDetails.AddRowType(name, rowType)
    ROW_TYPES[name] = rowType
end

---@param parent Frame The details fill it
---@param isWiderWithoutBar boolean? See JourneyScrollBox
---@return JourneyDetails.Instance
function JourneyDetails.Create(parent, isWiderWithoutBar)
    ---@type JourneyDetails.Instance
    local details = {parent = parent, rows = {}, heights = {}}

    local isUpdateScheduled = false
    local function OnHeightChanged()
        if not isUpdateScheduled then
            isUpdateScheduled = true
            C_Timer.After(0, function()
                isUpdateScheduled = false
                _ShowRows(details, true)
            end)
        end
    end

    local scrollBox
    local view = CreateScrollBoxListLinearView(0, END_SPACE)
    view:SetElementExtentCalculator(function(_, data)
        local height = details.heights[data]
        if not height then
            height = _GetRowHeight(data, scrollBox:GetWidth())
            details.heights[data] = height
        end
        return height
    end)
    view:SetElementInitializer("Frame", function(row, data)
        _InitializeRow(row, data, scrollBox:GetWidth(), OnHeightChanged)
    end)
    local scrollArea = CreateFrame("Frame", nil, parent)
    scrollArea:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
    scrollArea:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 0, 0)
    details.scrollArea = scrollArea
    details.footer = _CreateFooter(parent)
    scrollBox = JourneyScrollBox.Create(scrollArea, view, isWiderWithoutBar)
    details.scrollBox = scrollBox

    -- Text wraps differently, so every height has to be measured again
    local measuredWidth = scrollBox:GetWidth()
    scrollBox:HookScript("OnSizeChanged", function(_, width)
        if width ~= measuredWidth then
            measuredWidth = width
            _ShowRows(details, true)
        end
    end)

    return details
end

-- All that can be different in details of the same thing, except for what a checkbox gets
local SHOWN_FIELDS = {
    "type", "text", "title", "font", "height", "npcId", "icon", "trailingIcon", "itemId", "tag", "isCurrent", "state",
}

---@param rows JourneyDetails.Row[]
---@param otherRows JourneyDetails.Row[]
---@return boolean
local function _ShowTheSame(rows, otherRows)
    if #rows ~= #otherRows then
        return false
    end
    for index, row in ipairs(rows) do
        for _, field in ipairs(SHOWN_FIELDS) do
            if row[field] ~= otherRows[index][field] then
                return false
            end
        end
    end
    return true
end

---@param details JourneyDetails.Instance
local function _RefreshCheckboxes(details)
    details.scrollBox:ForEachFrame(function(row)
        local checkbox = row.parts.checkbox
        if checkbox and checkbox:IsShown() then
            QuestieOptionsControls.Refresh(checkbox.control)
        end
    end)
end

---@param details JourneyDetails.Instance
---@param rows JourneyDetails.Row[]
---@param keepsScrollPosition boolean? For details of the same thing as before
function JourneyDetails.SetRows(details, rows, keepsScrollPosition)
    if keepsScrollPosition and _ShowTheSame(details.rows, rows) then
        -- Showing them again would load portraits again, and lose a click that is being made right now
        _RefreshCheckboxes(details)
        return
    end
    details.rows = rows
    _ShowRows(details, keepsScrollPosition == true)
end

---@param label string Is translated
---@param value string|number
---@return string
function JourneyDetails.GetFactText(label, value)
    return Questie:Colorize(l10n(label) .. l10n(": "), JourneyDetails.LABEL_COLOR) .. value
end

return JourneyDetails
