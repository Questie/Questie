---A small simulation of the WoW UI for testing the settings and My Journey.
---
---The behavior they depend on is implemented for real: parents and visibility, OnShow firing when a frame
---becomes visible through its parent, script hooks, sliders firing OnValueChanged only when the value changes,
---lists that only have frames for the rows on screen, tickers running once per frame, and a clock.
---
---It is strict on purpose. A frame only has the methods listed here, each of which exists in Blizzard's UI, and only
---the template children listed in TEMPLATE_CHILDREN. So a mistyped method or a field that was never stored fails
---like it would in the game. What it can't tell is whether the game accepts the arguments, or how anything looks.

local FakeUI = {}

local SECONDS_PER_FRAME = 1 / 60
-- Text is measured as if every character had the same width
local CHARACTER_WIDTH = 7
local LINE_HEIGHTS = {GameFontNormalMed1 = 16}
local DEFAULT_LINE_HEIGHT = 14

local GLOBALS = {
    "CreateFrame", "UIParent", "SettingsPanel", "CreateScrollBoxLinearView", "ScrollUtil", "Settings", "GameTooltip",
    "ColorPickerFrame", "NineSliceUtil", "UISpecialFrames", "tinsert", "GetScreenHeight", "GetScreenWidth",
    "CreateFont",
    "GameFontHighlightSmall", "C_Timer", "GetTime", "GetTimePreciseSec", "PlaySound", "SOUNDKIT", "IsMouseButtonDown",
    "strtrim", "print", "LibStub", "debugstack", "wipe", "OKAY", "Menu", "strsplit", "CreateScrollBoxListLinearView",
    "CreateDataProvider", "CreateIndexRangeDataProvider", "ScrollBoxConstants", "GetCursorPosition", "SetCursor",
}

-- Art and setup calls that have no behavior worth simulating
local NO_OP_METHODS = {
    "AddMaskTexture", "ClearAllPoints", "RegisterForClicks", "SetAllPoints", "SetAutoFocus",
    "SetBlendMode", "SetCheckedTexture", "SetClampedToScreen", "SetColorTexture", "SetDisabledCheckedTexture",
    "SetDisabledTexture", "SetDrawLayer", "SetFixedWidth", "SetFontHeight", "SetFontString",
    "SetHighlightAtlas", "SetHighlightTexture", "SetHorizTile", "SetJustifyH", "SetJustifyV",
    "SetMaxLetters", "SetMovable", "SetNormalTexture", "SetPortraitTextureRaw", "SetPushedTexture",
    "SetRotation", "SetSnapToPixelGrid", "SetTexelSnappingBias", "SetTitle", "SetWordWrap",
    "StartMoving", "SetPortraitZoom",
}

-- Only these have scripts for clicks. Setting one on another frame is an error.
local BUTTON_TYPES = {Button = true, CheckButton = true, DropdownButton = true, ItemButton = true, EventButton = true}
local BUTTON_SCRIPTS = {OnClick = true, OnDoubleClick = true, PreClick = true, PostClick = true}

local TEXTURE_GETTERS = {
    "GetCheckedTexture", "GetDisabledCheckedTexture", "GetDisabledTexture", "GetHighlightTexture", "GetNormalTexture",
    "GetPushedTexture", "GetThumbTexture",
}

local TEMPLATE_CHILDREN = {
    OptionsSliderTemplate = {"Text", "Low", "High", "NineSlice"},
    PortraitFrameTemplate = {"CloseButton", "PortraitContainer", "Bg"},
    SearchBoxTemplate = {"Instructions"},
    MinimalTabTemplate = {"Text"},
}

-- Like Blizzard's PanelResizeButtonMixin, without limiting the size
local TEMPLATE_METHODS = {
    PanelResizeButtonTemplate = {
        Init = function(self, target, minWidth, minHeight)
            self.target, self.minWidth, self.minHeight = target, minWidth, minHeight
        end,
        OnMouseDown = function(self)
            self.isActive = true
            self.target:StartSizing("BOTTOMRIGHT", true)
        end,
        OnMouseUp = function(self)
            self.isActive = false
            self.target:StopMovingOrSizing()
        end,
        IsActive = function(self) return self.isActive == true end,
    },
    MinimalTabTemplate = {
        SetSelected = function(self, isSelected) self.isSelected = isSelected end,
    },
    ScrollingEditBoxTemplate = {
        GetScrollBox = function(self) return self end,
        GetEditBox = function(self) return self end,
        GetInputText = function(self) return self:GetText() or "" end,
        ClearText = function(self) self:SetText("") end,
    },
    -- Like Blizzard's ScrollBoxListMixin, with rows that are all as high as one of ui.visibleRows
    WowScrollBoxList = {
        SetDataProvider = function(self, dataProvider, retainScrollPosition)
            self.onRowsReleased(#self.rowFrames)
            self.dataProvider = dataProvider
            if not retainScrollPosition then
                self.firstIndex = 1
            end
            self:UpdateRows()
        end,
        GetDataProvider = function(self) return self.dataProvider end,
        ForEachFrame = function(self, callback)
            for _, frame in ipairs(self.rowFrames) do
                callback(frame)
            end
        end,
        ReinitializeFrames = function(self)
            for _, frame in ipairs(self.rowFrames) do
                self.view.initialize(frame, frame.elementData)
            end
        end,
        ScrollToElementDataIndex = function(self, index)
            assert(index <= self.dataProvider.size, "scrolled to something that isn't in the list")
            if index < self.firstIndex then
                self.firstIndex = index
            elseif index >= self.firstIndex + self.visibleRows() then
                self.firstIndex = index - self.visibleRows() + 1
            end
            self:UpdateRows()
        end,
    },
}

---Replaces the UI globals. Call Restore on the returned object when done.
---@return table ui
function FakeUI.Install()
    local ui = {
        frames = {},
        categories = {},
        addOnCategories = {},
        tickers = {},
        frameCount = 0,
        timerCount = 0,
        runsLatestTimersFirst = false, -- The client runs the timers of a frame in no particular order
        time = 0, -- Seconds that passed in all frames, which timers go by
        clock = 0,
        clockStep = 0, -- Seconds the clock advances each time it is read, to simulate slow frames
        screenWidth = 1800,
        printed = {},
        -- Measured size of every font string, instead of one that depends on its text
        stringWidth = nil,
        stringHeight = nil,
        visibleRows = 20, -- Of every list
        rowsReleased = 0, -- Of all lists, when they got other data
    }

    local originals = {}
    for _, name in ipairs(GLOBALS) do
        originals[name] = _G[name]
    end

    local methods = {}
    local frameMeta = {__index = methods}

    local function NewFrame(frameType, name, parent, template)
        local frame = setmetatable({
            frameType = frameType,
            name = name,
            parent = parent,
            template = template,
            children = {},
            scripts = {},
            points = {},
            shown = true,
            enabled = true,
            width = 100,
            height = 20,
            frameLevel = parent and parent.frameLevel + 1 or 0,
        }, frameMeta)
        if parent then
            table.insert(parent.children, frame)
        end
        table.insert(ui.frames, frame)

        for _, childName in ipairs(TEMPLATE_CHILDREN[template] or {}) do
            frame[childName] = NewFrame("Frame", nil, frame)
        end
        for methodName, method in pairs(TEMPLATE_METHODS[template] or {}) do
            frame[methodName] = method
        end
        if frameType == "EditBox" then
            frame.text = ""
        end
        if template == "WowScrollBoxList" then
            frame.rowFrames, frame.framePool, frame.firstIndex = {}, {}, 1
            frame.visibleRows = function() return ui.visibleRows end
            frame.onRowsReleased = function(count) ui.rowsReleased = ui.rowsReleased + count end
        end
        if template == "SearchBoxTemplate" then
            frame.scripts.OnTextChanged = function(searchBox)
                searchBox.Instructions:SetShown((searchBox:GetText() or "") == "")
            end
        end
        return frame
    end

    local function FireScript(frame, scriptName, ...)
        local script = frame.scripts[scriptName]
        if script then
            script(frame, ...)
        end
    end

    local function FireShown(frame, scriptName)
        FireScript(frame, scriptName)
        for _, child in ipairs(frame.children) do
            if child.shown then
                FireShown(child, scriptName)
            end
        end
    end

    for _, methodName in ipairs(NO_OP_METHODS) do
        methods[methodName] = function() end
    end

    for _, methodName in ipairs(TEXTURE_GETTERS) do
        methods[methodName] = function(self)
            local key = "fake" .. methodName
            if not rawget(self, key) then
                rawset(self, key, NewFrame("Texture", nil, self))
            end
            return rawget(self, key)
        end
    end

    function methods:GetName() return self.name end
    function methods:GetParent() return self.parent end
    function methods:SetParent(parent)
        if self.parent then
            for index, child in ipairs(self.parent.children) do
                if child == self then
                    table.remove(self.parent.children, index)
                    break
                end
            end
        end
        self.parent = parent
        if parent then
            table.insert(parent.children, self)
        end
    end

    -- Visibility
    function methods:IsShown() return self.shown end
    function methods:IsVisible()
        if not self.shown then return false end
        return self.parent == nil or self.parent:IsVisible()
    end
    function methods:Show()
        if self.shown then return end
        self.shown = true
        if self:IsVisible() then FireShown(self, "OnShow") end
    end
    function methods:Hide()
        if not self.shown then return end
        local wasVisible = self:IsVisible()
        self.shown = false
        if wasVisible then FireShown(self, "OnHide") end
        if ui.focus and not ui.focus:IsVisible() then ui.focus:ClearFocus() end
    end
    function methods:SetShown(shown)
        if shown then self:Show() else self:Hide() end
    end

    -- Scripts
    ---@param frame table
    ---@param scriptName string
    local function AssertHasScript(frame, scriptName)
        assert(not BUTTON_SCRIPTS[scriptName] or BUTTON_TYPES[frame.frameType], frame.frameType .. " has no script " .. scriptName)
    end
    ---@param region table
    local function AssertIsTexture(region)
        assert(region.frameType:find("Texture"), region.frameType .. " is no texture")
    end

    function methods:SetScript(scriptName, handler)
        AssertHasScript(self, scriptName)
        self.scripts[scriptName] = handler
    end
    function methods:GetScript(scriptName) return self.scripts[scriptName] end
    function methods:HookScript(scriptName, hook)
        AssertHasScript(self, scriptName)
        local previous = self.scripts[scriptName]
        self.scripts[scriptName] = function(...)
            if previous then previous(...) end
            hook(...)
        end
    end
    function methods:Click()
        if self.enabled then FireScript(self, "OnClick") end
    end

    -- Size and position
    function methods:SetSize(width, height)
        local hasChanged = width ~= self.width or height ~= self.height
        self.width, self.height = width, height
        self.maxTextWidth = width > 0 and width or nil -- 0 is as wide as the text
        if hasChanged then FireScript(self, "OnSizeChanged", width, height) end
    end
    function methods:SetWidth(width) self:SetSize(width, self.height) end
    function methods:SetHeight(height)
        local maxTextWidth = self.maxTextWidth
        self:SetSize(self.width, height)
        self.maxTextWidth = maxTextWidth
    end
    function methods:GetWidth() return self.width end
    function methods:GetHeight() return self.height end
    function methods:GetSize() return self.width, self.height end
    -- A frame only has one of each point, so setting it again moves it
    function methods:SetPoint(...)
        local point = {...}
        for index, existing in ipairs(self.points) do
            if existing[1] == point[1] then
                self.points[index] = point
                return
            end
        end
        table.insert(self.points, point)
    end
    function methods:GetPoint(index)
        local point = self.points[index] or {}
        return point[1], point[2], point[3], point[4], point[5]
    end
    function methods:SetResizable(isResizable) self.resizable = isResizable end
    function methods:StartSizing()
        assert(self.resizable, "StartSizing on a frame that isn't resizable")
        self.isSizing = true
    end
    function methods:StopMovingOrSizing() self.isSizing = false end

    function methods:GetEffectiveScale() return self.effectiveScale or 1 end
    function methods:SetFrameStrata(strata) self.frameStrata = strata end
    function methods:GetFrameStrata() return self.frameStrata end
    function methods:SetFrameLevel(level) self.frameLevel = level end
    function methods:GetFrameLevel() return self.frameLevel end
    function methods:GetStringWidth()
        if ui.stringWidth then return ui.stringWidth end
        local width = 0
        for line in ((self.text or "") .. "\n"):gmatch("(.-)\n") do
            width = math.max(width, #line * CHARACTER_WIDTH)
        end
        return self.maxTextWidth and math.min(width, self.maxTextWidth) or width
    end
    function methods:GetStringHeight()
        if ui.stringHeight then return ui.stringHeight end
        local lines = 0
        for line in ((self.text or "") .. "\n"):gmatch("(.-)\n") do
            local width = #line * CHARACTER_WIDTH
            lines = lines + (self.maxTextWidth and math.max(1, math.ceil(width / self.maxTextWidth)) or 1)
        end
        return lines * (LINE_HEIGHTS[self.fontObject] or DEFAULT_LINE_HEIGHT)
    end
    function methods:IsMouseOver() return self.mouseOver == true end
    function methods:IsMouseMotionFocus() return ui.mouseFocus == self end

    -- Children
    function methods:CreateTexture() return NewFrame("Texture", nil, self) end
    function methods:CreateMaskTexture() return NewFrame("MaskTexture", nil, self) end
    function methods:CreateFontString(_, _, fontObject)
        local fontString = NewFrame("FontString", nil, self)
        fontString.fontObject = fontObject
        return fontString
    end
    function methods:GetRegions() return unpack(self.regions or {}) end
    function methods:IsObjectType(objectType) return self.frameType == objectType end

    -- Widgets
    function methods:SetText(text)
        self.text = type(text) == "number" and tostring(text) or text
        if self.frameType == "EditBox" then
            FireScript(self, "OnTextChanged", false)
        end
    end
    function methods:GetText() return self.text end
    function methods:AddLine(text) self.lines = self.lines or {}; table.insert(self.lines, text) end
    -- Like the real one, which is empty until something is added and hidden until it is shown
    function methods:SetOwner(owner)
        self.owner, self.text, self.lines = owner, nil, nil
        self:Hide()
    end
    function methods:IsOwned(frame) return self.owner == frame end
    function methods:GetFont() return "font.ttf", 12, "" end
    function methods:SetChecked(isChecked) self.isChecked = isChecked end
    function methods:GetChecked() return self.isChecked end
    function methods:SetEnabled(isEnabled) self.enabled = isEnabled end
    function methods:IsEnabled() return self.enabled end
    function methods:HasFocus() return ui.focus == self end
    function methods:ClearFocus()
        if ui.focus == self then
            ui.focus = nil
            FireScript(self, "OnEditFocusLost")
        end
    end
    function methods:SetAlpha(alpha) self.alpha = alpha end
    function methods:SetDesaturated(isDesaturated) self.isDesaturated = isDesaturated end
    function methods:SetVertexColor(...) self.vertexColor = {...} end
    function methods:SetTextColor(...) self.textColor = {...} end
    function methods:SetFont(path) self.fontPath = path end
    function methods:SetFontObject(font) self.fontObject = font end

    function methods:SetMinMaxValues(min, max) self.minValue, self.maxValue = min, max; self.value = min end
    function methods:SetValueStep(step) self.valueStep = step end
    function methods:SetObeyStepOnDrag(obeyStep) self.obeysStepOnDrag = obeyStep end
    function methods:GetValue() return self.value end
    function methods:SetValue(value)
        value = math.max(self.minValue, math.min(self.maxValue, value))
        -- The real slider snaps to the steps counted from its minimum, so 1500 becomes 1501 with a minimum of 1 and a step of 10
        if self.valueStep and self.valueStep > 0 then
            value = self.minValue + math.floor((value - self.minValue) / self.valueStep + 0.5) * self.valueStep
            value = math.max(self.minValue, math.min(self.maxValue, value))
        end
        if value ~= self.value then
            self.value = value
            FireScript(self, "OnValueChanged", value, false)
        end
    end

    -- Dropdowns follow DropdownButtonMixin: being set up while shown and every OnShow generate the menu, the text comes
    -- from the selected entry, and opening generates the menu before it counts as open.
    local function UpdateSelectionText(dropdown)
        dropdown.text = dropdown.defaultText
        for _, entry in ipairs(dropdown.menuEntries or {}) do
            if entry.isSelected and entry.isSelected() then
                dropdown.text = entry.text
                return
            end
        end
    end
    -- Like Blizzard's, this only shows once the text is updated
    function methods:SetDefaultText(text) self.defaultText = text end
    function methods:SetupMenu(generator)
        self.menuGenerator = generator
        self:HookScript("OnShow", function(dropdown) dropdown:GenerateMenu() end)
        if self:IsShown() then self:GenerateMenu() end
    end
    function methods:GenerateMenu()
        self.generatedMenus = (self.generatedMenus or 0) + 1
        local entries = {}
        self.menuGenerator(self, {
            SetScrollMode = function(_, height) entries.scrollHeight = height end,
            CreateDivider = function() table.insert(entries, {isDivider = true}) end,
            CreateRadio = function(_, text, isSelected, select)
                local entry = {text = text, isSelected = isSelected, select = select}
                function entry:AddInitializer(initializer) self.initializer = initializer end
                table.insert(entries, entry)
                return entry
            end,
        })
        self.menuEntries = entries
        UpdateSelectionText(self)
    end
    function methods:OpenMenu()
        if not self:IsEnabled() or self:IsMenuOpen() then return end
        self:GenerateMenu()
        -- The menu manager doesn't open a menu without entries
        if #self.menuEntries == 0 then return end
        self.menu = NewFrame("Frame", nil, _G.UIParent)
        ui.openMenu = self.menu
    end
    function methods:CloseMenu()
        self.menu = nil
        ui.openMenu = nil
        UpdateSelectionText(self)
    end
    -- Escape or a click elsewhere closes the menu through the menu manager, which leaves the text as it was
    function methods:CloseMenuFromOutside()
        self.menu = nil
        ui.openMenu = nil
    end
    function methods:IsMenuOpen() return self.menu ~= nil end
    function methods:Pick(entry)
        entry.select()
        self:CloseMenu()
    end

    -- Edit boxes. Setting the text fires OnTextChanged, like typing does.
    function methods:SetFocus()
        if ui.focus ~= self and self:IsVisible() then
            if ui.focus then ui.focus:ClearFocus() end
            ui.focus = self
            FireScript(self, "OnEditFocusGained")
        end
    end
    function methods:Insert(text)
        self:SetText((self.text or "") .. text)
    end
    function methods:PressEnter() FireScript(self, "OnEnterPressed") end

    -- Textures and models
    -- An atlas is a part of an image, which a texture that is set afterwards would be cropped to as well
    function methods:SetAtlas(atlas, useAtlasSize)
        AssertIsTexture(self)
        self.atlas, self.texCoord = atlas, "the part that is the atlas"
        if useAtlasSize then self:SetSize(64, 64) end
    end
    function methods:SetTexture(texture)
        AssertIsTexture(self)
        self.texture, self.atlas = texture, nil
    end
    function methods:SetTexCoord(...)
        AssertIsTexture(self)
        self.texCoord = {...}
    end
    function methods:GetTexture() return self.texture end
    function methods:SetCreature(npcId) self.npcId, self.modelSets = npcId, (self.modelSets or 0) + 1 end
    function methods:ClearModel() self.npcId = nil end
    function methods:GetDisplayInfo() return ui.knownNpcs[self.npcId] and 1 or 0 end

    -- Tooltips
    function methods:SetItemByID(itemId) self.itemId = itemId end

    -- Lists
    function methods:IsTruncated() return ui.isTextTruncated == true end
    function methods:GetElementData() return self.elementData end
    function methods:EnableMouse(isEnabled) self.mouseEnabled = isEnabled end
    function methods:UpdateRows()
        for _, rowFrame in ipairs(self.rowFrames) do
            rowFrame:Hide()
            table.insert(self.framePool, rowFrame)
        end
        self.rowFrames = {}

        local view, dataProvider = self.view, self.dataProvider
        if view.calculateExtent then
            for index = 1, dataProvider.size do
                assert(type(view.calculateExtent(index, dataProvider.Find(index))) == "number", "a row has no height")
            end
        end
        self.firstIndex = math.max(1, math.min(self.firstIndex, dataProvider.size - ui.visibleRows + 1))
        for index = self.firstIndex, math.min(self.firstIndex + ui.visibleRows - 1, dataProvider.size) do
            local rowFrame = table.remove(self.framePool) or NewFrame(view.frameType, nil, self)
            rowFrame.elementData = dataProvider.Find(index)
            rowFrame:Show()
            table.insert(self.rowFrames, rowFrame)
            view.initialize(rowFrame, rowFrame.elementData)
        end
    end

    -- Scroll frames
    function methods:Layout() self.layouts = (self.layouts or 0) + 1 end
    function methods:FullUpdate() self.fullUpdates = (self.fullUpdates or 0) + 1 end
    function methods:ScrollToBegin() self.scrollsToBegin = (self.scrollsToBegin or 0) + 1 end

    _G.CreateFrame = function(frameType, name, parent, template)
        local frame = NewFrame(frameType, name, parent, template)
        if frameType == "EditBox" then
            -- The client does this once by itself, without anything being typed
            _G.C_Timer.After(0, function() FireScript(frame, "OnTextChanged", false) end)
        end
        return frame
    end

    _G.UIParent = NewFrame("Frame", "UIParent")
    _G.SettingsPanel = NewFrame("Frame", "SettingsPanel", _G.UIParent)
    _G.SettingsPanel.Container = NewFrame("Frame", nil, _G.SettingsPanel)
    _G.SettingsPanel.Container.SettingsCanvas = NewFrame("Frame", nil, _G.SettingsPanel.Container)
    _G.GameTooltip = NewFrame("GameTooltip", "GameTooltip", _G.UIParent)
    _G.GameTooltip.shown = false
    _G.ColorPickerFrame = NewFrame("ColorSelect", "ColorPickerFrame", _G.UIParent)
    _G.GameFontHighlightSmall = NewFrame("Font", "GameFontHighlightSmall")
    _G.ScrollUtil = {
        InitScrollBoxWithScrollBar = function() end,
        InitScrollBoxListWithScrollBar = function(scrollBox, _, view) scrollBox.view = view end,
        RegisterScrollBoxWithScrollBar = function() end,
        AddManagedScrollBarVisibilityBehavior = function() end,
    }
    _G.ScrollBoxConstants = {RetainScrollPosition = true, DiscardScrollPosition = false, AlignNearest = 1}
    _G.CreateScrollBoxListLinearView = function()
        return {
            SetElementExtent = function() end,
            SetElementExtentCalculator = function(self, calculate) self.calculateExtent = calculate end,
            SetElementInitializer = function(self, frameType, initialize) self.frameType, self.initialize = frameType, initialize end,
        }
    end
    _G.CreateDataProvider = function(elements)
        local collection = {}
        for index, element in ipairs(elements) do
            collection[index] = element
        end
        return {size = #collection, Find = function(index) return collection[index] end}
    end
    _G.CreateIndexRangeDataProvider = function(size)
        return {size = size, Find = function(index) return index end}
    end
    _G.GetCursorPosition = function() return ui.cursorX or 0, 0 end
    _G.SetCursor = function(cursor) ui.cursor = cursor end
    ui.knownNpcs = {}
    _G.NineSliceUtil = {ApplyLayoutByName = function() end}
    _G.CreateScrollBoxLinearView = function()
        return {SetPadding = function() end, SetPanExtent = function() end}
    end
    _G.CreateFont = function(name) return NewFrame("Font", name) end
    _G.Settings = {
        RegisterCanvasLayoutCategory = function(canvas, name)
            local category = {canvas = canvas, name = name}
            table.insert(ui.categories, category)
            return category
        end,
        RegisterCanvasLayoutSubcategory = function(parentCategory, canvas, name)
            local category = {canvas = canvas, name = name, parent = parentCategory}
            table.insert(ui.categories, category)
            return category
        end,
        RegisterAddOnCategory = function(category) table.insert(ui.addOnCategories, category) end,
    }
    _G.UISpecialFrames = {}
    _G.tinsert = table.insert
    _G.wipe = function(t)
        for key in pairs(t) do t[key] = nil end
        return t
    end
    _G.strtrim = function(text, characters)
        local class = characters and ("[" .. characters:gsub("[%]%[%%^-]", "%%%0") .. "]") or "%s"
        return (text:gsub("^" .. class .. "+", ""):gsub(class .. "+$", ""))
    end
    _G.strsplit = function(separator, text)
        local parts = {}
        for part in (text .. separator):gmatch("(.-)" .. separator:gsub("%W", "%%%0")) do
            table.insert(parts, part)
        end
        return unpack(parts)
    end
    _G.GetScreenHeight = function() return 1000 end
    _G.GetScreenWidth = function() return ui.screenWidth end
    _G.PlaySound = function() end
    _G.SOUNDKIT = {IG_CHARACTER_INFO_TAB = 1}
    _G.IsMouseButtonDown = function() return false end
    _G.OKAY = "Okay"
    _G.Menu = {GetManager = function() return {GetOpenMenu = function() return ui.openMenu end} end}
    _G.debugstack = function() return "" end
    _G.print = function(...) table.insert(ui.printed, table.concat({...}, " ")) end
    _G.LibStub = function()
        return {
            HashTable = function() return {["Friz Quadrata TT"] = "Fonts\\FRIZQT__.TTF", ["Arial Narrow"] = "Fonts\\ARIALN.TTF"} end,
            Fetch = function() return "Font" end,
        }
    end
    -- Stays the same within a frame, like the real one
    _G.GetTime = function() return ui.frameCount end
    _G.GetTimePreciseSec = function()
        ui.clock = ui.clock + ui.clockStep
        return ui.clock
    end
    ---@param delay number
    ---@param callback fun()
    ---@param repeats boolean
    local function Schedule(delay, callback, repeats)
        ui.timerCount = ui.timerCount + 1
        local timer = {callback = callback, delay = delay, repeats = repeats, dueAt = ui.time + delay, number = ui.timerCount}
        function timer:Cancel() self.cancelled = true end
        table.insert(ui.tickers, timer)
        return timer
    end
    _G.C_Timer = {
        After = function(delay, callback) Schedule(delay, callback, false) end,
        NewTicker = function(delay, callback, iterations)
            local timer = Schedule(delay, callback, true)
            timer.iterations = iterations
            return timer
        end,
        NewTimer = function(delay, callback) return Schedule(delay, callback, false) end,
    }

    ---Runs one frame: every timer that is due fires once.
    function ui.RunFrame()
        ui.frameCount = ui.frameCount + 1
        ui.time = ui.time + SECONDS_PER_FRAME
        local timers = ui.tickers
        ui.tickers = {}
        if ui.runsLatestTimersFirst then
            table.sort(timers, function(a, b) return a.number > b.number end)
        end
        for _, timer in ipairs(timers) do
            if not timer.cancelled and timer.dueAt > ui.time then
                table.insert(ui.tickers, timer)
            elseif not timer.cancelled then
                timer.callback()
                timer.iterations = timer.iterations and timer.iterations - 1
                if timer.repeats and not timer.cancelled and timer.iterations ~= 0 then
                    timer.dueAt = ui.time + timer.delay
                    table.insert(ui.tickers, timer)
                end
            end
        end
    end

    ---@param seconds number
    function ui.RunFor(seconds)
        local stopAt = ui.time + seconds
        while ui.time < stopAt do
            ui.RunFrame()
        end
    end

    ---Runs frames until nothing is scheduled anymore.
    ---@return number frames How many frames it took
    function ui.RunUntilIdle()
        local frames = 0
        while #ui.tickers > 0 do
            ui.RunFrame()
            frames = frames + 1
            assert(frames < 100000, "timers never finished")
        end
        return frames
    end

    ---What Blizzard's settings panel does to show a category, see SettingsPanelMixin:DisplayLayout.
    function ui.DisplayCanvas(canvas)
        canvas:SetParent(_G.SettingsPanel.Container.SettingsCanvas)
        canvas:ClearAllPoints()
        canvas:SetAllPoints(_G.SettingsPanel.Container.SettingsCanvas)
        canvas:Show()
    end

    ---What Blizzard's settings panel does to leave a category, see SettingsPanelMixin:ClearCurrentCategoryCanvas.
    function ui.ClearCanvas(canvas)
        canvas:SetParent(nil)
        canvas:ClearAllPoints()
        canvas:Hide()
    end

    ---@param root table
    ---@param predicate fun(frame: table): boolean
    ---@return table[] frames Every matching descendant of root, in creation order
    function ui.FindAll(root, predicate)
        local found = {}
        local function Visit(frame)
            for _, child in ipairs(frame.children) do
                if predicate(child) then
                    table.insert(found, child)
                end
                Visit(child)
            end
        end
        Visit(root)
        return found
    end

    ---@param root table
    ---@param template string
    ---@return table[] frames
    function ui.FindByTemplate(root, template)
        return ui.FindAll(root, function(frame) return frame.template == template end)
    end

    ---@param root table
    ---@param listIndex number Which of the lists below root, in creation order
    ---@return table[] rowFrames The rows on screen, from top to bottom
    function ui.Rows(root, listIndex)
        return ui.FindByTemplate(root, "WowScrollBoxList")[listIndex].rowFrames
    end

    -- The rows of a JourneyList

    ---@return string[] texts Of the rows on screen
    function ui.RowTexts(root, listIndex)
        local texts = {}
        for _, row in ipairs(ui.Rows(root, listIndex)) do
            table.insert(texts, row.Label.text)
        end
        return texts
    end

    ---@return string[] texts Of the rows on screen that look selected
    function ui.SelectedRowTexts(root, listIndex)
        local texts = {}
        for _, row in ipairs(ui.Rows(root, listIndex)) do
            if row.Background:IsShown() and row.Background.atlas == "Options_List_Active" then
                table.insert(texts, row.Label.text)
            end
        end
        return texts
    end

    ---@param text string
    function ui.ClickRow(root, listIndex, text)
        for _, row in ipairs(ui.Rows(root, listIndex)) do
            if row.Label.text == text then
                return row:Click()
            end
        end
        error("There is no row " .. text)
    end

    function ui.Restore()
        for _, name in ipairs(GLOBALS) do
            _G[name] = originals[name]
        end
    end

    return ui
end

return FakeUI
