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

local ROW_INSET = 8
local END_SPACE = 14 -- Below the last row, so it doesn't look cut off
-- Space between the border of a box and what is in it
local BOX_INSET = 14
local BOX_PADDING = 8
local BOX_ALPHA = 0.45 -- Like the boxes of the settings
local HEADING_FONT = "GameFontNormalMed1"
local HEADING_LINES_WIDTH = 80 -- Left for the lines on both sides of a long heading
local PICTURE_SIZE = 46
local PICTURE_GAP = 10
local ITEM_TOOLTIP_PADDING = 4
local UNKNOWN_ITEM_TOOLTIP_HEIGHT = 60
local ITEM_TOOLTIP_UPDATES, ITEM_TOOLTIP_UPDATE_SECONDS = 10, 0.5
local UNKNOWN_ICON = 134400 -- Interface\Icons\INV_Misc_QuestionMark
local PORTRAIT_ATTEMPTS = 4
local PORTRAIT_RETRY_SECONDS = 0.5

---@class JourneyDetails.Row
---@field type "heading"|"title"|"text"|"link"|"checkbox"|"button"|"entity"|"itemTooltip"|"gap"|"page"|"caption"|"buttons"|"step"
---@field text string? Finished text. It is never translated or formatted, because it can contain names and notes.
---@field title string? For the type entity, above the text
---@field onBack fun()? For the type page
---@field tag string? For the type page, at its right edge
---@field buttons {text: string, onClick: fun(), isOff: boolean?}[]? For the type buttons
---@field action {icon: number|string, tooltip: string, isOn: boolean?, onClick: fun()}? For the types link, step and entity, a button at the right edge
---@field font string? For the type text, a font object
---@field height number? For the type gap
---@field onClick fun()? For the types link, button and entity
---@field showTooltip fun()? For the types link, checkbox and entity. Fills the tooltip that was opened at the row.
---@field npcId NpcId? For the type entity, shows a portrait of the NPC
---@field trailingIcon JourneyIcon.Icon? For the type text, behind it
---@field icon number|string|nil For the type entity
---@field itemId ItemId? For the type itemTooltip
---@field get fun(): boolean For the type checkbox
---@field set fun()? For the type checkbox
---@field isFirstInBox boolean?
---@field isLastInBox boolean?
---@field isInBox boolean?

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

---@param data JourneyDetails.Row
---@param rowWidth number
---@return number
local function _GetContentWidth(data, rowWidth)
    return math.max(1, rowWidth - 2 * (data.isInBox and BOX_INSET or ROW_INSET))
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
---@param width number
---@return number textWidth
local function _GetEntityTextWidth(data, width)
    if data.npcId or data.icon then
        return math.max(1, width - PICTURE_SIZE - PICTURE_GAP)
    end
    return width
end

---Shows an NPC's face. The client asks the server about one it hasn't seen yet, and only knows it some time later.
---@param part Frame
---@param npcId NpcId
---@param attempts number
local function _ShowPortrait(part, npcId, attempts)
    if not part.Model then
        part.Model = CreateFrame("PlayerModel", nil, part.Picture)
        part.Model:SetAllPoints(part.Picture)
        part.Model:SetScript("OnModelLoaded", function(model) model:SetPortraitZoom(1) end)
    end

    part.Model:ClearModel()
    part.Model:SetCreature(npcId)
    part.Model:SetPortraitZoom(1)

    local isKnown = part.Model:GetDisplayInfo() ~= 0
    part.Icon:SetShown(not isKnown)
    if not isKnown and attempts > 1 then
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
    itemTooltip:SetPoint("TOPLEFT", part, "TOPLEFT", 0, -ITEM_TOOLTIP_PADDING)

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

local ACTION_SIZE = 18
local BUTTON_GAP, BUTTON_LINE_HEIGHT, BUTTON_PADDING = 6, 28, 28

---@param text string
---@return number
local function _GetButtonWidth(text)
    _MeasureText(text, "GameFontNormal", 0)
    return math.ceil(measuringText:GetStringWidth()) + BUTTON_PADDING
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
        part.Action.Icon:SetTexture(data.action.icon)
        part.Action.Icon:SetDesaturated(not data.action.isOn)
        part.Action.Icon:SetAlpha(data.action.isOn and 1 or 0.75)
    end
end

---@class JourneyDetails.RowType
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

    -- What the whole page is about
    page = {
        Create = function(part)
            local back = CreateFrame("Button", nil, part)
            back:SetSize(24, 24)
            back:SetPoint("TOPLEFT", part, "TOPLEFT", -4, -2)
            back:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up")
            back:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Down")
            back:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
            back:SetScript("OnClick", function() part.data.onBack() end)
            part.Back = back
            part.Tag = part:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
            part.Tag:SetPoint("TOPRIGHT", part, "TOPRIGHT", -4, -9)
            part.Title = part:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
            part.Title:SetJustifyH("LEFT")
            part.Title:SetWordWrap(false)
            local line = part:CreateTexture(nil, "ARTWORK")
            line:SetAtlas("Options_HorizontalDivider")
            line:SetPoint("BOTTOMLEFT", part, "BOTTOMLEFT", 0, 1)
            line:SetPoint("BOTTOMRIGHT", part, "BOTTOMRIGHT", 0, 1)
            line:SetHeight(1.5)
        end,
        Update = function(part, data)
            part.Back:SetShown(data.onBack ~= nil)
            part.Title:ClearAllPoints()
            part.Title:SetPoint("TOPLEFT", part, "TOPLEFT", data.onBack and 24 or 0, -6)
            part.Title:SetPoint("RIGHT", part.Tag, "LEFT", -8, 0)
            part.Tag:SetText(data.tag or " ")
            part.Title:SetText(data.text)
        end,
        GetHeight = function() return 32 end,
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

    -- Several buttons next to each other
    buttons = {
        Create = function(part) part.controls = {} end,
        Update = function(part, data, width)
            local x, y = 0, -4
            for index, button in ipairs(data.buttons) do
                local control = part.controls[index]
                if not control then
                    control = CreateFrame("Button", nil, part, "UIPanelButtonTemplate")
                    control:SetHeight(24)
                    control:SetScript("OnClick", function() part.data.buttons[index].onClick() end)
                    part.controls[index] = control
                end
                control:SetText(button.text)
                control:SetWidth(_GetButtonWidth(button.text))
                if x > 0 and x + control:GetWidth() > width then
                    x, y = 0, y - BUTTON_LINE_HEIGHT
                end
                control:SetPoint("TOPLEFT", part, "TOPLEFT", x, y)
                control:Show()
                x = x + control:GetWidth() + BUTTON_GAP
            end
            for index = #data.buttons + 1, #part.controls do part.controls[index]:Hide() end
        end,
        GetHeight = function(data, width)
            local x, lines = 0, 1
            for _, button in ipairs(data.buttons) do
                local buttonWidth = _GetButtonWidth(button.text)
                if x > 0 and x + buttonWidth > width then
                    x, lines = 0, lines + 1
                end
                x = x + buttonWidth + BUTTON_GAP
            end
            return lines * BUTTON_LINE_HEIGHT + 6
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
            part.Text:SetPoint("LEFT", button, "LEFT", 26, 0)
            part.Text:SetJustifyH("LEFT")
            part.Text:SetWordWrap(false)
            part.Note = button:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
            part.Note:SetPoint("RIGHT", button, "RIGHT", -6, 0)
            button:SetScript("OnClick", function()
                GameTooltip:Hide()
                if part.data.onClick then part.data.onClick() end
            end)
            _AddTooltip(button, part, "ANCHOR_CURSOR")
            _CreateAction(part, button)
            part.Action:SetPoint("RIGHT", button, "RIGHT", -2, 0)
        end,
        Update = function(part, data)
            part.Background:SetShown(data.isCurrent == true)
            JourneyIcon.Set(part.Icon, data.trailingIcon)
            part.Note:SetText(data.tag or "")
            part.Text:SetText(data.text)
            part.Text:SetPoint("RIGHT", part.Button, "RIGHT", data.action and -34 or -8 - part.Note:GetStringWidth() - 8, 0)
            part.Button:EnableMouse(data.onClick ~= nil)
            _UpdateAction(part, data)
        end,
        GetHeight = function() return 21 end,
    },

    -- The title of a box, above it
    title = {
        Create = function(part)
            part.Title = part:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            part.Title:SetPoint("BOTTOMLEFT", part, "BOTTOMLEFT", 10, 4)
        end,
        Update = function(part, data)
            part.Title:SetText(data.text)
        end,
        GetHeight = function() return 26 end,
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

    link = {
        Create = function(part)
            local button = CreateFrame("Button", nil, part)
            button:SetAllPoints(part)
            button:SetHighlightAtlas("Options_List_Hover")
            part.Text = _CreateWrappingText(button, "GameFontHighlight")
            part.Text:SetPoint("TOPLEFT", button, "TOPLEFT", 4, -2)
            button:SetScript("OnClick", function()
                GameTooltip:Hide()
                part.data.onClick()
            end)
            _AddTooltip(button, part, "ANCHOR_CURSOR")
        end,
        Update = function(part, data, width)
            part.Text:SetWidth(width - 8)
            part.Text:SetText(data.text)
        end,
        GetHeight = function(data, width)
            return _MeasureText(data.text, "GameFontHighlight", width - 8) + 6
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

            local title = button:CreateFontString(nil, "ARTWORK", "GameFontNormal")
            title:SetJustifyH("LEFT")
            title:SetWordWrap(true)
            part.Title = title
            part.Text = _CreateWrappingText(button, "GameFontHighlight")
            _CreateAction(part, button)
            part.Action:SetPoint("TOPRIGHT", part, "TOPRIGHT", -2, -2)
        end,
        Update = function(part, data, width)
            local textWidth = _GetEntityTextWidth(data, width)
            local x = width - textWidth

            part.Button:EnableMouse(data.onClick ~= nil)
            _UpdateAction(part, data)

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
            return (data.npcId or data.icon) and math.max(height, PICTURE_SIZE + 6) or height
        end,
    },

    itemTooltip = {
        Create = function() end,
        Update = _ShowItemTooltip,
        GetHeight = function(data) return itemTooltipHeights[data.itemId] or UNKNOWN_ITEM_TOOLTIP_HEIGHT end,
    },

    gap = {
        Create = function() end,
        Update = function() end,
        GetHeight = function(data) return data.height end,
    },
}

-------------------------
-- Boxes
-------------------------

-- The pieces of the NineSlice layout the settings use for their boxes, TooltipGluesLayout. A box goes over several rows,
-- so each row draws its part of it.
local BOX_PIECES = {
    topLeft = "Tooltip-Glues-NineSlice-CornerTopLeft",
    topRight = "Tooltip-Glues-NineSlice-CornerTopRight",
    bottomLeft = "Tooltip-Glues-NineSlice-CornerBottomLeft",
    bottomRight = "Tooltip-Glues-NineSlice-CornerBottomRight",
    top = "_Tooltip-Glues-NineSlice-EdgeTop",
    bottom = "_Tooltip-Glues-NineSlice-EdgeBottom",
    left = "!Tooltip-Glues-NineSlice-EdgeLeft",
    right = "!Tooltip-Glues-NineSlice-EdgeRight",
}

---@param row Frame
---@return table box
local function _CreateBox(row)
    local box = {}
    for name, atlas in pairs(BOX_PIECES) do
        local piece = row:CreateTexture(nil, "BORDER")
        piece:SetAtlas(atlas, true)
        piece:SetAlpha(BOX_ALPHA)
        QuestieOptionsUtils.DisableSnapping(piece)
        box[name] = piece
    end

    box.topLeft:SetPoint("TOPLEFT", row, "TOPLEFT", 0, 0)
    box.topRight:SetPoint("TOPRIGHT", row, "TOPRIGHT", 0, 0)
    box.bottomLeft:SetPoint("BOTTOMLEFT", row, "BOTTOMLEFT", 0, 0)
    box.bottomRight:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", 0, 0)
    box.top:SetPoint("TOPLEFT", box.topLeft, "TOPRIGHT", 0, 0)
    box.top:SetPoint("TOPRIGHT", box.topRight, "TOPLEFT", 0, 0)
    box.bottom:SetPoint("BOTTOMLEFT", box.bottomLeft, "BOTTOMRIGHT", 0, 0)
    box.bottom:SetPoint("BOTTOMRIGHT", box.bottomRight, "BOTTOMLEFT", 0, 0)
    return box
end

---@param row Frame
---@param data JourneyDetails.Row
local function _UpdateBox(row, data)
    if not row.box then
        if not data.isInBox then
            return
        end
        row.box = _CreateBox(row)
    end

    local box = row.box
    for _, name in ipairs({"topLeft", "top", "topRight"}) do
        box[name]:SetShown(data.isFirstInBox == true)
    end
    for _, name in ipairs({"bottomLeft", "bottom", "bottomRight"}) do
        box[name]:SetShown(data.isLastInBox == true)
    end
    for _, side in ipairs({"left", "right"}) do
        local sidePoint = side:upper()
        local topCorner = side == "left" and box.topLeft or box.topRight
        local bottomCorner = side == "left" and box.bottomLeft or box.bottomRight
        box[side]:ClearAllPoints()
        if data.isFirstInBox then
            box[side]:SetPoint("TOP" .. sidePoint, topCorner, "BOTTOM" .. sidePoint, 0, 0)
        else
            box[side]:SetPoint("TOP" .. sidePoint, row, "TOP" .. sidePoint, 0, 0)
        end
        if data.isLastInBox then
            box[side]:SetPoint("BOTTOM" .. sidePoint, bottomCorner, "TOP" .. sidePoint, 0, 0)
        else
            box[side]:SetPoint("BOTTOM" .. sidePoint, row, "BOTTOM" .. sidePoint, 0, 0)
        end
        box[side]:SetShown(data.isInBox == true)
    end
end

-------------------------
-- Rows
-------------------------

---@param data JourneyDetails.Row
---@param rowWidth number
---@return number
local function _GetRowHeight(data, rowWidth)
    local height = ROW_TYPES[data.type].GetHeight(data, _GetContentWidth(data, rowWidth))
    if data.isFirstInBox then height = height + BOX_PADDING end
    if data.isLastInBox then height = height + BOX_PADDING end
    return height
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

    local inset = data.isInBox and BOX_INSET or ROW_INSET
    part:SetPoint("TOPLEFT", row, "TOPLEFT", inset, data.isFirstInBox and -BOX_PADDING or 0)
    part:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", -inset, data.isLastInBox and BOX_PADDING or 0)
    part.data = data
    ROW_TYPES[data.type].Update(part, data, _GetContentWidth(data, rowWidth))

    _UpdateBox(row, data)
end

---@class JourneyDetails.Instance
---@field scrollBox Frame
---@field rows JourneyDetails.Row[]
---@field heights table<JourneyDetails.Row, number> Those measured already, as scrolling asks for them again and again

---@param details JourneyDetails.Instance
---@param keepsScrollPosition boolean
local function _ShowRows(details, keepsScrollPosition)
    details.heights = {}
    details.scrollBox:SetDataProvider(
        CreateDataProvider(details.rows),
        keepsScrollPosition and ScrollBoxConstants.RetainScrollPosition or ScrollBoxConstants.DiscardScrollPosition
    )
end

---@param parent Frame The details fill it
---@return JourneyDetails.Instance
function JourneyDetails.Create(parent)
    ---@type JourneyDetails.Instance
    local details = {rows = {}, heights = {}}

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
    scrollBox = JourneyScrollBox.Create(parent, view)
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
    "type", "text", "title", "font", "height", "npcId", "icon", "trailingIcon", "itemId", "isInBox", "isFirstInBox", "isLastInBox", "tag",
    "isCurrent", "state",
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
    return Questie:Colorize(l10n(label) .. l10n(": "), "yellow") .. value
end

---Adds a box with some rows in it. Nothing is added without any rows.
---@param rows JourneyDetails.Row[]
---@param title string Shown above the box
---@param boxRows JourneyDetails.Row[]
function JourneyDetails.AddBox(rows, title, boxRows)
    if #boxRows == 0 then
        return
    end

    if title ~= "" then
        table.insert(rows, {type = "title", text = title})
    end
    for index, row in ipairs(boxRows) do
        row.isInBox = true
        row.isFirstInBox = index == 1
        row.isLastInBox = index == #boxRows
        table.insert(rows, row)
    end
end

return JourneyDetails
