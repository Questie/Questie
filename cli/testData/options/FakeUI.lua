---A small simulation of the WoW UI for testing the settings.
---
---The behavior the settings depend on is implemented for real: parents and visibility, OnShow firing when a frame
---becomes visible through its parent, script hooks, sliders firing OnValueChanged only when the value changes,
---tickers running once per frame, and a clock.
---
---It is strict on purpose. A frame only has the methods listed here, each of which exists in Blizzard's UI, and only
---the template children listed in TEMPLATE_CHILDREN. So a mistyped method or a field that was never stored fails
---like it would in the game. What it can't tell is whether the game accepts the arguments, or how anything looks.

local FakeUI = {}

local GLOBALS = {
    "CreateFrame", "UIParent", "SettingsPanel", "CreateScrollBoxLinearView", "ScrollUtil", "Settings", "GameTooltip",
    "ColorPickerFrame", "NineSliceUtil", "UISpecialFrames", "tinsert", "GetScreenHeight", "CreateFont",
    "GameFontHighlightSmall", "C_Timer", "GetTime", "GetTimePreciseSec", "PlaySound", "SOUNDKIT", "IsMouseButtonDown",
    "strtrim", "print", "LibStub", "debugstack", "wipe", "OKAY", "Menu",
}

-- Art and setup calls that have no behavior worth simulating
local NO_OP_METHODS = {
    "AddMaskTexture", "ClearAllPoints", "EnableMouse", "RegisterForClicks", "SetAllPoints", "SetAtlas", "SetAutoFocus",
    "SetBlendMode", "SetCheckedTexture", "SetClampedToScreen", "SetColorTexture", "SetDisabledCheckedTexture",
    "SetDisabledTexture", "SetDrawLayer", "SetFixedWidth", "SetFontHeight", "SetFontString",
    "SetFrameStrata", "SetHighlightAtlas", "SetHighlightTexture", "SetHorizTile", "SetJustifyH", "SetJustifyV",
    "SetMaxLetters", "SetMovable", "SetNormalTexture", "SetOwner", "SetPortraitTextureRaw", "SetPushedTexture",
    "SetRotation", "SetSnapToPixelGrid", "SetTexCoord", "SetTexelSnappingBias", "SetTexture", "SetTitle", "SetWordWrap",
    "StartMoving", "StopMovingOrSizing",
}

local TEXTURE_GETTERS = {
    "GetCheckedTexture", "GetDisabledCheckedTexture", "GetDisabledTexture", "GetHighlightTexture", "GetNormalTexture",
    "GetPushedTexture", "GetThumbTexture",
}

local TEMPLATE_CHILDREN = {
    OptionsSliderTemplate = {"Text", "Low", "High", "NineSlice"},
    PortraitFrameTemplate = {"CloseButton", "PortraitContainer", "Bg"},
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
        clock = 0,
        clockStep = 0, -- Seconds the clock advances each time it is read, to simulate slow frames
        printed = {},
        stringWidth = 50, -- Measured size of every font string, to simulate long or wrapped text
        stringHeight = 14,
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
    end
    function methods:SetShown(shown)
        if shown then self:Show() else self:Hide() end
    end

    -- Scripts
    function methods:SetScript(scriptName, handler) self.scripts[scriptName] = handler end
    function methods:GetScript(scriptName) return self.scripts[scriptName] end
    function methods:HookScript(scriptName, hook)
        local previous = self.scripts[scriptName]
        self.scripts[scriptName] = function(...)
            if previous then previous(...) end
            hook(...)
        end
    end
    function methods:Click() FireScript(self, "OnClick") end

    -- Size and position
    function methods:SetSize(width, height) self.width, self.height = width, height end
    function methods:SetWidth(width) self.width = width end
    function methods:SetHeight(height) self.height = height end
    function methods:GetWidth() return self.width end
    function methods:GetHeight() return self.height end
    function methods:GetSize() return self.width, self.height end
    function methods:SetPoint(...) table.insert(self.points, {...}) end
    function methods:GetPoint(index)
        local point = self.points[index] or {}
        return point[1], point[2], point[3], point[4], point[5]
    end
    function methods:SetFrameLevel(level) self.frameLevel = level end
    function methods:GetFrameLevel() return self.frameLevel end
    function methods:GetStringWidth() return ui.stringWidth end
    function methods:GetStringHeight() return ui.stringHeight end
    function methods:IsMouseOver() return self.mouseOver == true end

    -- Children
    function methods:CreateTexture() return NewFrame("Texture", nil, self) end
    function methods:CreateMaskTexture() return NewFrame("MaskTexture", nil, self) end
    function methods:CreateFontString() return NewFrame("FontString", nil, self) end
    function methods:GetRegions() return unpack(self.regions or {}) end
    function methods:IsObjectType(objectType) return self.frameType == objectType end

    -- Widgets
    function methods:SetText(text) self.text = text end
    function methods:GetText() return self.text end
    function methods:AddLine(text) self.lines = self.lines or {}; table.insert(self.lines, text) end
    function methods:GetFont() return "font.ttf", 12, "" end
    function methods:SetChecked(isChecked) self.isChecked = isChecked end
    function methods:GetChecked() return self.isChecked end
    function methods:SetEnabled(isEnabled) self.enabled = isEnabled end
    function methods:IsEnabled() return self.enabled end
    function methods:HasFocus() return self.hasFocus == true end
    function methods:ClearFocus() self.hasFocus = false; FireScript(self, "OnEditFocusLost") end
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
        dropdown.text = nil
        for _, entry in ipairs(dropdown.menuEntries or {}) do
            if entry.isSelected() then
                dropdown.text = entry.text
                return
            end
        end
    end
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

    -- Scroll frames
    function methods:Layout() self.layouts = (self.layouts or 0) + 1 end
    function methods:FullUpdate() self.fullUpdates = (self.fullUpdates or 0) + 1 end

    _G.CreateFrame = function(frameType, name, parent, template)
        return NewFrame(frameType, name, parent, template)
    end

    _G.UIParent = NewFrame("Frame", "UIParent")
    _G.SettingsPanel = NewFrame("Frame", "SettingsPanel", _G.UIParent)
    _G.SettingsPanel.Container = NewFrame("Frame", nil, _G.SettingsPanel)
    _G.SettingsPanel.Container.SettingsCanvas = NewFrame("Frame", nil, _G.SettingsPanel.Container)
    _G.GameTooltip = NewFrame("GameTooltip", "GameTooltip", _G.UIParent)
    _G.ColorPickerFrame = NewFrame("ColorSelect", "ColorPickerFrame", _G.UIParent)
    _G.GameFontHighlightSmall = NewFrame("Font", "GameFontHighlightSmall")
    _G.ScrollUtil = {
        InitScrollBoxWithScrollBar = function() end,
        AddManagedScrollBarVisibilityBehavior = function() end,
    }
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
    _G.strtrim = function(text) return (text:gsub("^%s+", ""):gsub("%s+$", "")) end
    _G.GetScreenHeight = function() return 1000 end
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
    _G.C_Timer = {
        After = function(_, callback)
            table.insert(ui.tickers, {callback = callback, once = true})
        end,
        NewTicker = function(_, callback)
            local ticker = {callback = callback}
            function ticker:Cancel() self.cancelled = true end
            table.insert(ui.tickers, ticker)
            return ticker
        end,
    }

    ---Runs one frame: every timer that is due fires once.
    function ui.RunFrame()
        ui.frameCount = ui.frameCount + 1
        local due = ui.tickers
        ui.tickers = {}
        for _, ticker in ipairs(due) do
            if not ticker.cancelled then
                ticker.callback()
                if not ticker.once and not ticker.cancelled then
                    table.insert(ui.tickers, ticker)
                end
            end
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

    function ui.Restore()
        for _, name in ipairs(GLOBALS) do
            _G[name] = originals[name]
        end
    end

    return ui
end

return FakeUI
