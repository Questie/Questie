---The window of the Journey: its side tabs, and which of them is shown.
---
---The window doesn't exist until it is first opened, and a tab's canvas until that tab is first shown. After that the
---canvas is kept, and brought up to date each time it is shown.
---@class JourneyWindow
local JourneyWindow = QuestieLoader:CreateModule("JourneyWindow")

---@type QuestieJourney
local QuestieJourney = QuestieLoader:ImportModule("QuestieJourney")
local _QuestieJourney = QuestieJourney.private
---@type QuestieOptionsEngine
local QuestieOptionsEngine = QuestieLoader:ImportModule("QuestieOptionsEngine")
---@type QuestieOptionsUtils
local QuestieOptionsUtils = QuestieLoader:ImportModule("QuestieOptionsUtils")
---@type QuestieOptionsWindow
local QuestieOptionsWindow = QuestieLoader:ImportModule("QuestieOptionsWindow")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local WINDOW_WIDTH, WINDOW_HEIGHT = 1000, 665
local ABOVE_CENTER = 15
local MIN_WINDOW_WIDTH, MIN_WINDOW_HEIGHT = 550, 400
-- Left free on both sides of the window, so its tabs are still on a narrow screen
local SIDE_TAB_SPACE = 60
local OPEN_SOUND = 882
-- Height of the header with the title of the tab
local CANVAS_TOP = 36

-- Every client has these icons under the same ID

-- The book of the quest log, Interface\QuestFrame\UI-QuestLog-BookIcon. It only fills part of its round picture.
JourneyWindow.ICON = 136797
JourneyWindow.ICON_CROP = 0.1875

JourneyWindow.MAP_ICON = 137195 -- Interface\WorldMap\WorldMap-Icon
local SETTINGS_ICON = 134063 -- Interface\Icons\INV_Misc_Gear_01

---@class JourneyTab
---@field Build fun(canvas: Frame) Creates everything on the canvas, once
---@field Refresh fun() Brings the canvas up to date. Also happens while it is used, so it shows the same as before.
---@field OnSelected fun()? The user switched to the tab, or opened the window on it. It is refreshed next.
---@field OpenQuest fun(questId: QuestId)? Shows a quest in the tab. Without it, links to quests lead to the search.

---@class JourneySearchTab: JourneyTab
---@field Open fun(kind: JourneyKind, id: number)
---@field ClearFocus fun()

---@class JourneyTabInfo
---@field key string
---@field module string Where its JourneyTab is in the private table of QuestieJourney
---@field title string
---@field icon number
---@field iconCrop number?

local SEARCH_WIDTH = 270

---In display order
---@type JourneyTabInfo[]
local TABS = {
    {key = "quests", module = "quests", title = "Quests", icon = JourneyWindow.MAP_ICON},
    {key = "history", module = "myJourney", title = HISTORY, icon = JourneyWindow.ICON, iconCrop = JourneyWindow.ICON_CROP},
}

-- What the menus and bindings ask for
local REQUESTS = {
    zone = {tab = "quests", show = function() _QuestieJourney.quests.ShowCurrentZone() end},
    faction = {tab = "quests", show = function() _QuestieJourney.quests.ShowWatchedFaction() end},
    search = {tab = "quests", focusesSearch = true},
    journey = {tab = "history"},
}

---Nil until the window is first opened.
---@type Frame?
local window

---@type FontString
local canvasTitle

---@type table<string, Frame> By tab key, of the tabs that were shown before
local canvases = {}

---@type table<string, Frame> By tab key
local sideTabs = {}

---The tab that is shown, or was shown last while the window is closed.
local selectedKey = TABS[1].key

---@return JourneyTab
local function _GetSelectedTab()
    for _, tabInfo in ipairs(TABS) do
        if tabInfo.key == selectedKey then
            return _QuestieJourney[tabInfo.module]
        end
    end
    error("Unknown tab: " .. tostring(selectedKey))
end

---@param tabInfo JourneyTabInfo
local function _CreateCanvas(tabInfo)
    local canvas = CreateFrame("Frame", nil, window.canvasContainer)
    canvas:SetPoint("TOPLEFT", window.canvasContainer, "TOPLEFT", 0, -CANVAS_TOP)
    canvas:SetPoint("BOTTOMRIGHT", window.canvasContainer, "BOTTOMRIGHT", 0, 0)
    canvases[tabInfo.key] = canvas
    _QuestieJourney[tabInfo.module].Build(canvas)
end

---@param tabKey string
local function _SelectTab(tabKey)
    selectedKey = tabKey

    for _, tabInfo in ipairs(TABS) do
        local isSelected = tabInfo.key == tabKey
        QuestieOptionsWindow.SetSideTabSelected(sideTabs[tabInfo.key], isSelected)
        if isSelected then
            canvasTitle:SetText(l10n(tabInfo.title))
            if not canvases[tabInfo.key] then
                _CreateCanvas(tabInfo)
            end
        end
        if canvases[tabInfo.key] then
            canvases[tabInfo.key]:SetShown(isSelected)
        end
    end

    local tab = _GetSelectedTab()
    if tab.OnSelected then
        tab.OnSelected()
    end
    tab.Refresh()
end

---Not for opening the window, which refreshes its tab even when it is the same one.
---@param tabKey string
local function _OnSideTabClicked(tabKey)
    if tabKey ~= selectedKey then
        _SelectTab(tabKey)
    end
end

local function _CreateWindow()
    window = QuestieOptionsWindow.Create({
        name = "QuestieJourneyFrame",
        title = l10n("%s's Journey", GetUnitName("player", true)),
        strata = "FULLSCREEN_DIALOG", -- Above the maximized world map
        width = math.min(WINDOW_WIDTH, GetScreenWidth() - 2 * SIDE_TAB_SPACE),
        height = WINDOW_HEIGHT,
        minWidth = MIN_WINDOW_WIDTH,
        minHeight = MIN_WINDOW_HEIGHT,
    })
    window:SetPoint("CENTER", 0, ABOVE_CENTER)
    canvasTitle = QuestieOptionsWindow.CreatePageTitle(window.canvasContainer, window.canvasContainer, QuestieOptionsWindow.HEADER_INSET)

    local headerLine = window.canvasContainer:CreateTexture(nil, "BORDER")
    headerLine:SetPoint("TOPLEFT", window.canvasContainer, "TOPLEFT", 0, -CANVAS_TOP + 2)
    headerLine:SetPoint("BOTTOMRIGHT", window.canvasContainer, "TOPRIGHT", 0, -CANVAS_TOP + 0.5)
    headerLine:SetAtlas("Options_HorizontalDivider", true)
    QuestieOptionsUtils.DisableSnapping(headerLine)

    for _, frame in ipairs({window, window.dragBar, window.resizeGrip}) do
        frame:HookScript("OnMouseDown", function() window.searchBox:ClearFocus() end)
    end
    QuestieOptionsWindow.AddSearchBox(window, function() end, SEARCH_WIDTH, table.concat({l10n("Quests"), l10n("NPCs"), l10n("Objects"), l10n("Items")}, ", "))
    window.searchBox:SetPoint("RIGHT", window.canvasContainer, "TOPRIGHT", -16, -17)
    _QuestieJourney.quests.UseSearchBox(window.searchBox)

    local previousSideTab
    for _, tab in ipairs(TABS) do
        sideTabs[tab.key] = QuestieOptionsWindow.CreateSideTab(window, tab.key, tab, previousSideTab, _OnSideTabClicked)
        previousSideTab = sideTabs[tab.key]
    end

    QuestieOptionsWindow.CreateLinkTab(window, "settings", {title = "Questie Options", icon = SETTINGS_ICON}, function()
        JourneyWindow.Hide()
        QuestieOptionsEngine:ShowFrame()
    end)
end

---Opens the window if it isn't open yet, and shows a tab.
---@param tabKey string? The tab that was shown last when nil
function JourneyWindow.Show(tabKey)
    if not window then
        _CreateWindow()
    end
    if not window:IsShown() then
        PlaySound(OPEN_SOUND)
        window:Show()
    end
    local request = REQUESTS[tabKey]
    _SelectTab(request and request.tab or tabKey or selectedKey)
    if request and request.show then
        request.show()
    elseif request and request.focusesSearch then
        window.searchBox:SetFocus()
    end
end

---Shows the list of quests, in which search results are shown as well.
function JourneyWindow.ShowQuests()
    if selectedKey ~= "quests" then
        _SelectTab("quests")
    end
end

---Opens the window again as it was hidden.
function JourneyWindow.ShowAgain()
    if window and not window:IsShown() then
        window:Show()
        JourneyWindow.Refresh()
    end
end

function JourneyWindow.Hide()
    if window then
        window:Hide()
    end
end

---Brings the tab that is shown up to date, if one is.
function JourneyWindow.Refresh()
    if JourneyWindow.IsShown() then
        _GetSelectedTab().Refresh()
    end
end

---Shows what a link in the details leads to. Quests stay in the tab the link is in, so its list isn't lost.
---@param kind JourneyKind
---@param id number
function JourneyWindow.OpenLink(kind, id)
    JourneyWindow.ShowQuests()
    _QuestieJourney.quests.Open(kind, id)
end

---@return boolean
function JourneyWindow.IsShown()
    return window ~= nil and window:IsShown()
end

return JourneyWindow
