---Questie's settings: the tabs, both places they are shown, and building them when they are first opened.
---@class QuestieOptionsEngine
local QuestieOptionsEngine = QuestieLoader:CreateModule("QuestieOptionsEngine");

---@type QuestieOptionsControls
local QuestieOptionsControls = QuestieLoader:ImportModule("QuestieOptionsControls")
---@type QuestieOptionsLayout
local QuestieOptionsLayout = QuestieLoader:ImportModule("QuestieOptionsLayout")
---@type QuestieOptionsUtils
local QuestieOptionsUtils = QuestieLoader:ImportModule("QuestieOptionsUtils")
---@type QuestieOptionsWindow
local QuestieOptionsWindow = QuestieLoader:ImportModule("QuestieOptionsWindow")
---@type QuestieJourney
local QuestieJourney = QuestieLoader:ImportModule("QuestieJourney")
---@type ThreadLib
local ThreadLib = QuestieLoader:ImportModule("ThreadLib")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local coYield = coroutine.yield

---- How the settings fit together
--
-- Control - An element the user interacts with to adjust settings, like a checkbox or a slider.
-- Element - Any object placed on a canvas. All controls are elements, but there are also
--           non-control elements like containers, dividers, and text.
-- Canvas  - The area showing one tab. Every tab has one canvas in Blizzard's settings panel,
--           and one in Questie's own window.
--
-- There are four parts:
-- - The tab files in NativeOptions/ hold the data: which settings exist and how they read and write.
-- - QuestieOptionsLayout decides where each element goes. It fills rows of elements until a row is
--   horizontally full, then starts a new one. Elements specify their width as a fraction of the canvas, and
--   never their height or coordinates.
-- - QuestieOptionsControls draws each element and keeps it showing the current setting.
-- - This file owns the tabs and their canvases, and decides when they are built and refreshed.
--
-- As long as there isn't a bug or you don't need new functionality, you should only need to modify
-- the tab files in order to tweak, remove, or add settings.
--
-- A tab file registers on QuestieOptionsEngine.tabs, and its Initialize function returns:
--   title     Tab name. Also the name of its category in Blizzard's settings panel.
--   subtitle  Shown next to the title at the top of the tab.
--   order     Tabs are sorted by this. The first tab becomes the main Questie category in Blizzard's settings panel.
--   icon      Texture of the tab's button in Questie's own window.
--   visible   False skips the whole tab, for example when an addon it integrates with is missing.
--   items     The elements of the tab, by key. Their fields are listed in QuestieOptionsLayout.
--
-- title, description, label, and tooltip values go through l10n() later, so tab files don't call it for those.
--
-- Supported element types:
--   "checkbox"      Typical checkbox.
--   "slider"        Slider between numeric values.
--   "dropdown"      Lets you pick a single value from a preset list.
--   "fontDropdown"  Nearly identical to a dropdown, except it assumes the values are fonts, and renders each entry with that font.
--   "divider"       Simple horizontal divider. Title optional.
--   "container"     Container to group and nest other controls together.
--   "text"          Simple text label.
--   "button"        A button. The 'btnLabel' field is what appears on the button; 'title' is only used for the tooltip.
--   "soundButton"   A button, but instead of using a label field, it's square and shows a play symbol.
--   "colorPicker"   Opens a dialog allowing users to pick an RGB(A) color.
--   "radioButton"   Similar to a checkbox in function, but used in conjunction and exclusive with other radio buttons.
--   "textbox"       Text input with a confirmation button.
--   "spacer"        Empty space, useful for aligning controls relative to other controls.

---Tab files register here while they load.
QuestieOptionsEngine.tabs = {}

---Questie's own settings window. Stays nil until it is first opened.
---@type Frame?
QuestieOptionsEngine.popup = nil

local RenderMode = {
    BLIZZARD = 1,
    POPUP = 2,
}

local CANVAS_WIDTH = 625

-- How long canvas builds can run per frame, together. Keeps a slow client far from the script time limit, which
-- is much stricter in Hardcore, however long a single control takes to create and however many tabs are building.
local BUILD_BUDGET_SECONDS = 0.004

---@class QuestieOptionsTab
---@field key string
---@field data table What the tab file's Initialize returned

---Visible tabs in display order. Nil until Initialize has registered them all.
---@type QuestieOptionsTab[]?
local visibleTabs

---@type Frame[] Every canvas, built or not, in both modes
local canvases = {}

---@type table<string, Frame> Canvases of Questie's own window by tab key
local popupCanvases = {}
---@type table<string, Frame> Buttons of Questie's own window by tab key
local sideTabs = {}

---Text currently entered in Questie's own options window.
---@type string
QuestieOptionsEngine.searchText = ""

local _BuildCanvas

-------------------------
-- Canvases
-------------------------

---@param controls QuestieOptionsControl[]
local function _RefreshControls(controls)
    for _, control in ipairs(controls) do
        QuestieOptionsControls.Refresh(control)
    end
end

---@param canvas Frame
local function _RefreshCanvas(canvas)
    _RefreshControls(canvas.controls)
    if canvas.pendingControls and canvas.pendingControls ~= canvas.controls then
        _RefreshControls(canvas.pendingControls)
    end
end

---Throws away what a failed or superseded build created, so the tab is built from scratch the next time it is shown.
---The finished content is kept while a replacement is being built, so a search update cannot blank the active tab.
---@param canvas Frame
---@param keepContent boolean? Keep the currently displayed content while discarding a replacement.
local function _DiscardFailedBuild(canvas, keepContent)
    if canvas.buildTimer then
        canvas.buildTimer:Cancel()
        canvas.buildTimer = nil
    end
    canvas.buildGeneration = (canvas.buildGeneration or 0) + 1

    if canvas.pendingContent then
        canvas.pendingContent:Hide()
        canvas.pendingContent:SetParent(nil)
        canvas.pendingContent = nil
    end
    canvas.pendingControls = nil

    if not keepContent and canvas.content then
        canvas.content:Hide()
        canvas.content:SetParent(nil)
        canvas.content = nil
    end
    if not keepContent then
        canvas.controls = {}
        canvas.UpdateScrollLayout = nil
    end
    canvas.isBuildStarted = false
end

---A canvas is built the first time it is shown. After that, each time it is shown it catches up on
---settings that changed while it was hidden, because RefreshStates skips hidden canvases.
---@param canvas Frame
local function _OnCanvasShown(canvas)
    if not canvas.isBuildStarted then
        canvas.isBuildStarted = true
        canvas.buildGeneration = (canvas.buildGeneration or 0) + 1
        local buildGeneration = canvas.buildGeneration
        local buildTimer
        local function IsCurrentBuild()
            return canvas.buildGeneration == buildGeneration and canvas.buildTimer == buildTimer
        end
        buildTimer = ThreadLib.Thread(
            function() _BuildCanvas(canvas, buildGeneration) end, 0, "Error while building a Questie settings tab:", nil,
            function()
                if IsCurrentBuild() then
                    _DiscardFailedBuild(canvas, canvas.content ~= nil)
                end
            end, "QuestieOptionsEngine.BuildCanvas"
        )
        canvas.buildTimer = buildTimer
        return
    end

    _RefreshCanvas(canvas)

    -- While the build is still running this is not set yet, and the build lays itself out when it finishes
    if canvas.UpdateScrollLayout then
        canvas.UpdateScrollLayout()
    end
end

---Creates an empty hidden canvas. This is cheap, so it is fine for every tab to have them from the start.
---@param parent Frame
---@param tab QuestieOptionsTab
---@param mode number One of RenderMode
---@return Frame canvas
local function _CreateCanvas(parent, tab, mode)
    local modeName = mode == RenderMode.POPUP and "Popup" or "Blizz"

    local canvas = CreateFrame("Frame", "QuestieOptionsTab_" .. modeName .. "_" .. tab.key, parent)
    canvas:SetAllPoints(parent)
    canvas:Hide()
    canvas.tab = tab
    canvas.mode = mode
    canvas.controls = {}
    canvas:HookScript("OnShow", _OnCanvasShown)

    table.insert(canvases, canvas)
    return canvas
end

---@param canvas Frame
---@param content Frame Holds what the build creates
---@param leftInset number
---@return Frame headerWrapper Spans the top of the canvas, down to the bottom of the title
local function _CreateCanvasHeader(canvas, content, leftInset)
    local tabData = canvas.tab.data

    local headerWrapper = CreateFrame("Frame", canvas:GetName() .. "_headerWrapper", content)
    headerWrapper:SetAllPoints(canvas)
    headerWrapper:SetPoint("TOPLEFT", canvas, "TOPLEFT", 0, -4)

    local subtitle = content:CreateFontString(nil, "OVERLAY", "Game13Font")
    subtitle:SetPoint("TOPLEFT", canvas, "TOPLEFT", 8 + leftInset, -10)
    subtitle:SetTextColor(0.9, 0.9, 0.9, 1.0)
    subtitle:SetText(l10n(tabData.subtitle or tabData.title))

    headerWrapper:SetPoint("BOTTOM", subtitle, "BOTTOM", 0, 0)

    return headerWrapper
end

---@param parent Frame
---@param name string
---@param header Frame
---@param mode number One of RenderMode
---@return Frame scrollBox
---@return Frame scrollChild Expanding area inside the scroll box that controls are placed on
local function _CreateScrollFrames(parent, name, header, mode)
    local BAR_PADDING = 12

    local scrollBox = CreateFrame("Frame", name, parent, "WowScrollBox")
    local scrollBar = CreateFrame("EventFrame", name .. "ScrollBar", parent, "MinimalScrollBar")
    scrollBar:SetPoint("RIGHT", parent, "RIGHT", -BAR_PADDING, 0)
    scrollBar:SetPoint("BOTTOM", parent, "BOTTOM", 0, 5)
    scrollBar:SetPoint("TOP", parent, "TOP", 0, -36)
    scrollBox:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -10)
    scrollBox:SetPoint("BOTTOM", parent, 0, mode == RenderMode.POPUP and -7 or -1)
    scrollBox:SetPoint("RIGHT", scrollBar, "LEFT", -BAR_PADDING, 0)

    local scrollChild = CreateFrame("Frame", name .. "ScrollChild", scrollBox, "ResizeLayoutFrame")
    scrollChild.scrollable = true
    scrollChild:SetFixedWidth(SettingsPanel.Container.SettingsCanvas:GetWidth() - scrollBar:GetWidth())
    scrollChild:SetHeight(100)
    scrollChild.ScrollBox = scrollBox
    scrollChild.ScrollBar = scrollBar

    local scrollView = CreateScrollBoxLinearView()
    scrollView:SetPadding(10, 25) -- Pad the bottom of the view
    scrollView:SetPanExtent(50) -- Scroll step
    ScrollUtil.InitScrollBoxWithScrollBar(scrollBox, scrollBar, scrollView)
    ScrollUtil.AddManagedScrollBarVisibilityBehavior(scrollBox, scrollBar) -- Hides the bar when everything fits

    return scrollBox, scrollChild
end

local budgetFrameTime, budgetStartedAt

---Starts the budget of this frame, unless another build already did earlier in the frame.
local function _StartFrameBudget()
    -- GetTime only changes between frames, which tells this apart from other builds earlier in the same frame
    local frameTime = GetTime()
    if frameTime ~= budgetFrameTime then
        budgetFrameTime = frameTime
        budgetStartedAt = GetTimePreciseSec()
    end
end

---Continues in a later frame once this frame's budget is spent. A resumed build starts the budget before it does
---anything, so its first control counts as well, and it waits for another frame if other builds already spent it.
---@async
local function _YieldIfFrameBudgetSpent()
    _StartFrameBudget()
    while GetTimePreciseSec() - budgetStartedAt >= BUILD_BUDGET_SECONDS do
        coYield()
        _StartFrameBudget()
    end
end

---Continues in a later frame that no other build has used yet, and keeps the other builds out of the rest of it.
---@async
local function _YieldForFrameOfItsOwn()
    repeat
        coYield()
    until GetTime() ~= budgetFrameTime
    budgetFrameTime = GetTime()
    budgetStartedAt = GetTimePreciseSec() - BUILD_BUDGET_SECONDS
end

---Creates everything on a canvas, pausing whenever the frame's budget is used up.
---Each control shows the current setting from the moment it exists, so settings changing mid-build are no problem.
---@async
---@param canvas Frame
---@param buildGeneration number
_BuildCanvas = function(canvas, buildGeneration)
    local isPopup = canvas.mode == RenderMode.POPUP
    local searchText = isPopup and QuestieOptionsEngine.searchText or nil
    local tabTitleMatches = isPopup and QuestieOptionsLayout.MatchesSearch({
        title = canvas.tab.data.title,
        description = canvas.tab.data.subtitle,
    }, searchText)

    local controls = {}
    if not canvas.content then
        -- During the first build there is no committed content to refresh yet, so expose the
        -- controls as they are created. Replacement builds keep the old controls until commit.
        canvas.controls = controls
    end
    canvas.pendingControls = controls
    local function AddControl(control)
        table.insert(controls, control)
        _YieldIfFrameBudgetSpent()
    end

    _YieldIfFrameBudgetSpent()

    -- Everything the build creates goes on here, so a failed or superseded build can be thrown away.
    -- Keep the previously committed content visible until this replacement is complete.
    local content = CreateFrame("Frame", nil, canvas)
    content:SetAllPoints(canvas)
    content:Hide()
    canvas.pendingContent = content

    local headerWrapper = _CreateCanvasHeader(canvas, content, isPopup and 44 or 0)
    local searchAnchor

    if isPopup then
        local journeyButton = QuestieOptionsControls.Create(content, {
            title = "My Journey",
            type = "button",
            align = "RIGHT",
            func = function()
                QuestieOptionsEngine:ToggleConfigWindow()
                QuestieJourney:ToggleJourneyWindow()
            end,
            btnLabel = l10n("My Journey"),
        }, 240, 1)
        journeyButton:SetPoint("TOPRIGHT", canvas, "TOPRIGHT", -36, 7)
        searchAnchor = journeyButton.widget
        AddControl(journeyButton)
    end

    local scrollBox, scrollChild = _CreateScrollFrames(content, canvas:GetName() .. "_Scroll", headerWrapper, canvas.mode)

    -- Controls are created out of sight. Otherwise the tab visibly assembles itself on a slow client,
    -- and an edit box can take the keyboard focus before it is told not to.
    scrollBox:Hide()

    local divider = content:CreateTexture(nil, "BORDER")
    divider:SetPoint("TOPLEFT", scrollBox, "TOPLEFT", 0, 2)
    divider:SetPoint("BOTTOMRIGHT", scrollBox, "TOPRIGHT", 0, 0.5)
    divider:SetAtlas("Options_HorizontalDivider", true)
    QuestieOptionsUtils.DisableSnapping(divider)

    local contentWidth = CANVAS_WIDTH - QuestieOptionsControls.ROOT_INDENT * 2
    local contentHeight, visibleCount = QuestieOptionsLayout.Build(
        scrollChild, canvas.tab.data.items, contentWidth, 1, AddControl, searchText, tabTitleMatches
    )
    scrollChild:SetHeight(contentHeight + 20)

    local noResults
    if isPopup and searchText ~= "" and visibleCount == 0 then
        noResults = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        noResults:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 10, 0)
        noResults:SetText(l10n("No matching options"))
    end

    -- Laying out a finished tab is a lot of work at once, so it gets a frame of its own
    _YieldForFrameOfItsOwn()

    if canvas.buildGeneration ~= buildGeneration then
        content:Hide()
        if canvas.pendingContent == content then
            canvas.pendingContent = nil
        end
        if canvas.pendingControls == controls then
            canvas.pendingControls = nil
        end
        return
    end

    if canvas.content then
        canvas.content:Hide()
        canvas.content:SetParent(nil)
    end
    canvas.content = content
    canvas.pendingContent = nil
    canvas.pendingControls = nil
    canvas.controls = controls
    canvas.noResults = noResults

    scrollBox:Show()

    -- Updates the scroll child's resizable layout height, and then the scroll box to match
    canvas.UpdateScrollLayout = function()
        scrollChild:Layout()
        scrollBox:FullUpdate(true)
    end
    canvas.UpdateScrollLayout()
    content:Show()
    if searchAnchor and canvas:IsShown() then
        local window = canvas:GetParent():GetParent()
        if not window.searchAnchor then
            -- The Journey button belongs to the canvas and is replaced on every search. Copy
            -- its geometry to a window-owned anchor so the search box never follows a transient
            -- or hidden button during a rebuild.
            local stableAnchor = CreateFrame("Frame", nil, window)
            stableAnchor:SetSize(searchAnchor:GetSize())
            stableAnchor:SetPoint("TOPRIGHT", canvas, "TOPRIGHT", -36, 7)
            window.searchAnchor = stableAnchor
            QuestieOptionsWindow.AnchorSearchTo(window, window.searchAnchor)
        end
    end
end

-------------------------
-- Questie's own window
-------------------------

---@param selectedKey string
local function _SelectPopupTab(selectedKey)
    for _, tab in ipairs(visibleTabs) do
        local isSelected = tab.key == selectedKey
        popupCanvases[tab.key]:SetShown(isSelected)
        QuestieOptionsWindow.SetSideTabSelected(sideTabs[tab.key], isSelected)
    end
end

---@return Frame window
local function _CreatePopup()
    local window = QuestieOptionsWindow.Create(function(searchText)
        QuestieOptionsEngine:SetSearchText(searchText)
    end)
    -- Reset the search and selected tab for every close path, including Escape and the close button.
    window:HookScript("OnHide", function()
        QuestieOptionsEngine:SetSearchText("")
        window.searchBox:SetText("")
        _SelectPopupTab(visibleTabs[1].key)
    end)

    local previousSideTab
    for _, tab in ipairs(visibleTabs) do
        popupCanvases[tab.key] = _CreateCanvas(window.canvasContainer, tab, RenderMode.POPUP)
        sideTabs[tab.key] = QuestieOptionsWindow.CreateSideTab(window, tab.key, tab.data, previousSideTab, _SelectPopupTab)
        previousSideTab = sideTabs[tab.key]
    end

    _SelectPopupTab(visibleTabs[1].key)

    return window
end

-------------------------
-- Public functions
-------------------------

---Defines every tab and registers them with Blizzard's settings panel, with empty canvases.
---Runs in the startup coroutine, because all the tab definitions together are too much for one frame in Hardcore.
---@async
function QuestieOptionsEngine:Initialize()
    local tabs = {}
    for key, tabFile in pairs(self.tabs) do
        local data = tabFile:Initialize()
        if data.visible ~= false then
            table.insert(tabs, {key = key, data = data})
        end
        coYield()
    end

    -- Tabs without an order go last, and tabs with the same order alphabetically by their English title
    table.sort(tabs, function(a, b)
        local aOrder = a.data.order or 100
        local bOrder = b.data.order or 100
        if aOrder == bOrder then
            return (a.data.title or "") < (b.data.title or "")
        end
        return aOrder < bOrder
    end)

    local mainCategory
    for _, tab in ipairs(tabs) do
        local canvas = _CreateCanvas(UIParent, tab, RenderMode.BLIZZARD)
        local category
        if mainCategory then
            category = Settings.RegisterCanvasLayoutSubcategory(mainCategory, canvas, l10n(tab.data.title))
        else
            category = Settings.RegisterCanvasLayoutCategory(canvas, l10n("Questie"))
            mainCategory = category
        end
        Settings.RegisterAddOnCategory(category)
        coYield()
    end

    visibleTabs = tabs
end

---Updates the controls on every visible canvas to show the current settings.
---Hidden canvases catch up when they are next shown. Must stay synchronous, because clicks and timers call this
---outside of a coroutine, where yielding throws.
function QuestieOptionsEngine:RefreshStates()
    for _, canvas in ipairs(canvases) do
        if canvas:IsVisible() then
            _RefreshCanvas(canvas)
        end
    end
end

local function _PopupTabMatchesSearch(tab)
    if QuestieOptionsEngine.searchText == "" then
        return true
    end

    return QuestieOptionsLayout.MatchesSearch({
        title = tab.data.title,
        description = tab.data.subtitle,
        items = tab.data.items,
    }, QuestieOptionsEngine.searchText)
end

local function _UpdatePopupTabVisibility()
    for _, tab in ipairs(visibleTabs) do
        local matches = QuestieOptionsEngine.searchText == "" or _PopupTabMatchesSearch(tab)
        sideTabs[tab.key]:SetShown(matches)
    end
end

local function _RebuildPopupCanvases()
    for _, canvas in pairs(popupCanvases) do
        local wasShown = canvas:IsShown()
        _DiscardFailedBuild(canvas, wasShown)
        if wasShown then
            -- Start the replacement directly. The old content remains visible until the new
            -- content is committed, so restarting a search build must not hide the canvas.
            _OnCanvasShown(canvas)
        end
    end
end

---Changes the popup's option search and rebuilds every matching tab with matching items.
---@param searchText string
function QuestieOptionsEngine:SetSearchText(searchText)
    searchText = strtrim(searchText or "")
    if self.searchText == searchText then
        return
    end

    self.searchText = searchText

    if not self.popup then
        return
    end

    local selectedKey
    for _, tab in ipairs(visibleTabs) do
        if _PopupTabMatchesSearch(tab) then
            selectedKey = selectedKey or tab.key
            if popupCanvases[tab.key]:IsShown() then
                selectedKey = tab.key
                break
            end
        end
    end
    if selectedKey then
        _SelectPopupTab(selectedKey)
    end

    _UpdatePopupTabVisibility()
    _RebuildPopupCanvases()
end

local isRefreshQueued = false

local function _FlushQueuedRefresh()
    isRefreshQueued = false
    QuestieOptionsEngine:RefreshStates()
end

---Combines all the calls of a frame into one refresh, for controls that change continuously.
function QuestieOptionsEngine:QueueRefresh()
    if not isRefreshQueued then
        isRefreshQueued = true
        C_Timer.After(0, _FlushQueuedRefresh)
    end
end

function QuestieOptionsEngine:HideFrame()
    if QuestieOptionsEngine.popup then
        QuestieOptionsEngine.popup:Hide()
    end
end

function QuestieOptionsEngine:ShowFrame()
    -- Only reachable right after login, because Initialize runs for just a few frames
    if not visibleTabs then
        print(Questie:Colorize(l10n("Please wait a moment for Questie to finish loading")))
        return
    end

    if not QuestieOptionsEngine.popup then
        QuestieOptionsEngine.popup = _CreatePopup()
    end
    QuestieOptionsEngine.popup:Show()
end

---@return boolean
function QuestieOptionsEngine:IsShown()
    return QuestieOptionsEngine.popup ~= nil and QuestieOptionsEngine.popup:IsShown()
end

function QuestieOptionsEngine:ToggleConfigWindow()
    if QuestieOptionsEngine:IsShown() then
        QuestieOptionsEngine:HideFrame()
    else
        QuestieOptionsEngine:ShowFrame()
    end
end
