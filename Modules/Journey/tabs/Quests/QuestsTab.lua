---The quests of the Journey, in tabs like those of a browser. The first one is always the zone the player is in. The plus leads
---to all the other zones and factions, and what is searched for gets a tab of its own.
---@type QuestieJourney
local QuestieJourney = QuestieLoader:CreateModule("QuestieJourney")
local _QuestieJourney = QuestieJourney.private
_QuestieJourney.quests = {}
-------------------------
--Import modules.
-------------------------
---@type JourneyIcon
local JourneyIcon = QuestieLoader:ImportModule("JourneyIcon")
---@type JourneyLinkInput
local JourneyLinkInput = QuestieLoader:ImportModule("JourneyLinkInput")
---@type JourneyOverviewPage
local JourneyOverviewPage = QuestieLoader:ImportModule("JourneyOverviewPage")
---@type JourneyPage
local JourneyPage = QuestieLoader:ImportModule("JourneyPage")
---@type JourneyPanes
local JourneyPanes = QuestieLoader:ImportModule("JourneyPanes")
---@type JourneyPlaces
local JourneyPlaces = QuestieLoader:ImportModule("JourneyPlaces")
---@type JourneyQuestsPage
local JourneyQuestsPage = QuestieLoader:ImportModule("JourneyQuestsPage")
---@type JourneyResultsPage
local JourneyResultsPage = QuestieLoader:ImportModule("JourneyResultsPage")
---@type JourneyTabBar
local JourneyTabBar = QuestieLoader:ImportModule("JourneyTabBar")
---@type JourneyWindow
local JourneyWindow = QuestieLoader:ImportModule("JourneyWindow")
---@type QuestieCompat
local QuestieCompat = QuestieLoader:ImportModule("QuestieCompat")
---@type QuestieOptionsWindow
local QuestieOptionsWindow = QuestieLoader:ImportModule("QuestieOptionsWindow")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")
---@type utf8
local utf8 = QuestieLoader:ImportModule("utf8")

local TOOLBAR_HEIGHT = 40
local BAR_HEIGHT = 18
local TITLE_GAP, SEARCH_GAP, SEARCH_INSET = 18, 12, 16
local HERE_ICON_SIZE = 10
local SEARCH_ICON = "|TInterface\\Common\\UI-Searchbox-Icon:10:10:0:-2|t "
local SEARCH_DELAY_SECONDS = 0.15
local MIN_SEARCH_LENGTH = 3
local MIN_SEARCH_LENGTHS = {koKR = 2, zhCN = 2, zhTW = 2}

---@class JourneyQuestsTab
---@field source string? What is listed. For the search, what was searched for. Nil for the overview.
---@field content JourneyPage.Content
---@field page JourneyPage.Instance? Nil until the tab is shown

---Where the player is. It only changes when the window is opened, so the list doesn't change while the player is using it.
---@type JourneyQuestsTab
local hereTab = {content = JourneyQuestsPage}
---In the order they are shown in. The search and the overview aren't in it.
---@type JourneyQuestsTab[]
local tabs = {hereTab}
---@type JourneyQuestsTab
local overviewTab = {content = JourneyOverviewPage}
---Nil while nothing is searched for.
---@type JourneyQuestsTab?
local searchTab
local selectedTab = hereTab
---@type JourneyQuestsTab
local tabBeforeSearch

---Of closed tabs, for the next ones.
---@type JourneyPage.Instance[]
local freePages = {}

---@type JourneyPanes.Instance
local panes
---@type Frame
local tabBar
---@type Frame
local progressBar
---@type EditBox
local searchBox
---@type FontString
local title

-------------------------
-- Tabs
-------------------------

local _Select, _Close, _EndSearch

local function _ShowProgress()
    local page = selectedTab.page
    local text, share = page and page.progressText or "", page and page.progressShare
    progressBar.Text:SetText(text)
    progressBar:SetValue(share or 0)
    progressBar.Background:SetShown(share ~= nil)
    for _, edge in ipairs(progressBar.Edges) do edge:SetShown(share ~= nil) end
end

local function _ShowTabs()
    local shownTabs = {}
    for index, tab in ipairs(tabs) do
        shownTabs[index] = {
            name = (tab == hereTab and JourneyIcon.GetHereMarkup(HERE_ICON_SIZE) .. " " or "") .. JourneyPlaces.GetName(tab.source),
            isSelected = tab == selectedTab,
            onSelect = function() _Select(tab) end,
            onClose = tab ~= hereTab and function() _Close(tab) end or nil,
        }
    end
    if searchTab then
        table.insert(shownTabs, {
            name = SEARCH_ICON .. searchTab.source,
            isSelected = searchTab == selectedTab,
            onSelect = function() _Select(searchTab) end,
            onClose = function() searchBox:SetText("") _EndSearch() end,
        })
    end
    JourneyTabBar.SetTabs(tabBar, shownTabs, selectedTab == overviewTab)
end

local _OpenSource

---@param tab JourneyQuestsTab
local function _EnsurePage(tab)
    if not tab.page then
        -- The overview has its own list, so its page is never for anything else
        tab.page = tab ~= overviewTab and table.remove(freePages)
            or JourneyPage.Create(panes, function(source) _OpenSource(source) end, _ShowProgress)
        JourneyPage.SetContent(tab.page, tab.content, tab.source)
    end
end

---@param tab JourneyQuestsTab
local function _ReleasePage(tab)
    if tab.page then
        JourneyPage.SetShown(tab.page, false)
        JourneyPage.Clear(tab.page)
        table.insert(freePages, tab.page)
        tab.page = nil
    end
end

---@param tab JourneyQuestsTab
_Select = function(tab)
    if selectedTab ~= tab and selectedTab.page then
        JourneyPage.SetShown(selectedTab.page, false)
    end
    selectedTab = tab
    _EnsurePage(tab)
    JourneyPage.SetShown(tab.page, true)
    _ShowTabs()
    _ShowProgress()
    JourneyPage.Refresh(tab.page)
end

---@param tab JourneyQuestsTab
---@return number?
local function _GetIndex(tab)
    for index, otherTab in ipairs(tabs) do
        if otherTab == tab then
            return index
        end
    end
end

---@param tab JourneyQuestsTab Not the first one
_Close = function(tab)
    local index = _GetIndex(tab)
    table.remove(tabs, index)
    _ReleasePage(tab)
    if selectedTab == tab then
        _Select(tabs[index] or tabs[index - 1])
    else
        _ShowTabs()
    end
end

---@param source string
---@return JourneyQuestsTab?
local function _FindTab(source)
    for _, tab in ipairs(tabs) do
        if tab.source == source then
            return tab
        end
    end
end

---Shows a zone, a faction and so on, in the tab it already has or in a new one.
---@param source string Of quests, or a category of the overview, like "overview:1"
_OpenSource = function(source)
    local kind, category = source:match("^(overview):(.+)$")
    if kind then
        _EnsurePage(overviewTab)
        _Select(overviewTab)
        overviewTab.page.pastSelections = {}
        JourneyPage.Select(overviewTab.page, {kind = "category", id = tonumber(category) or category})
        return
    end

    local tab = _FindTab(source)
    if not tab then
        if not JourneyTabBar.HasRoom(tabBar) and #tabs > 1 then
            _ReleasePage(table.remove(tabs))
        end
        tab = {source = source, content = JourneyQuestsPage}
        table.insert(tabs, tab)
    end
    _Select(tab)
end

---The player can have gone somewhere else since the window was open. A tab the zone already had stays, for when the player leaves it.
local function _MoveHere()
    local source = "zone:" .. JourneyPlaces.GetPlayerZone()
    if hereTab.source == source then
        return
    end
    hereTab.source = source
    if hereTab.page then
        JourneyPage.SetContent(hereTab.page, hereTab.content, source)
    end
end

-------------------------
-- Search
-------------------------

local searchTimer

---@return string
local function _GetTypedQuery()
    return strtrim(searchBox:GetText(), " \n\r\t[]")
end

_EndSearch = function()
    if searchTimer then
        searchTimer:Cancel()
    end
    if searchTab then
        local tab, isSelected = searchTab, searchTab == selectedTab
        searchTab = nil
        _ReleasePage(tab)
        if isSelected then
            _Select(_GetIndex(tabBeforeSearch) and tabBeforeSearch or tabBeforeSearch == overviewTab and overviewTab or hereTab)
        else
            _ShowTabs()
        end
    end
end

---@param query string
local function _Search(query)
    JourneyWindow.ShowQuests()
    if selectedTab ~= searchTab then
        tabBeforeSearch = selectedTab
    end
    if searchTab then
        -- What was found before stays until there is something new
        searchTab.source, searchTab.page.source, searchTab.page.isLoaded = query, query, false
    else
        searchTab = {source = query, content = JourneyResultsPage}
    end
    _Select(searchTab)
end

local function _OnTextChanged()
    local linkText = searchBox:GetText():match("|h%[(.-)%]|h")
    if linkText then
        searchBox:SetText(linkText)
        return
    end
    if searchTimer then
        searchTimer:Cancel()
    end
    local query = _GetTypedQuery()
    if searchTab and searchTab.source == query then
        return
    end
    local minLength = MIN_SEARCH_LENGTHS[l10n:GetUILocale()] or MIN_SEARCH_LENGTH
    if utf8.strlen(query) >= minLength then
        searchTimer = C_Timer.NewTimer(SEARCH_DELAY_SECONDS, function() _Search(query) end)
    elseif query == "" then
        _EndSearch()
    end
end

local function _OnEnterPressed()
    searchBox:ClearFocus()
    local query = _GetTypedQuery()
    if query == "" then
        return
    end
    local place = JourneyResultsPage.GetTypedPlace(query)
    if place then
        JourneyWindow.ShowQuests()
        searchBox:SetText("")
        _EndSearch()
        _OpenSource(place)
    else
        _Search(query)
    end
end

---The title and the search box belong to the window, because they are there whichever of its tabs is shown.
---@param newSearchBox EditBox
---@param newTitle FontString
function _QuestieJourney.quests.UseHeader(newSearchBox, newTitle)
    searchBox, title = newSearchBox, newTitle
    searchBox:HookScript("OnTextChanged", _OnTextChanged)
    searchBox:SetScript("OnEnterPressed", _OnEnterPressed)
    local function TakeItem()
        local cursorType, _, itemLink = GetCursorInfo()
        if cursorType == "item" then
            ClearCursor()
            searchBox:SetText(itemLink)
        end
    end
    searchBox:SetScript("OnReceiveDrag", TakeItem)
    searchBox:HookScript("OnMouseDown", TakeItem)
    JourneyLinkInput.Enable(searchBox)
end

-------------------------
-- Canvas
-------------------------

---@param canvas Frame
local function _CreateProgressBar(canvas)
    progressBar = CreateFrame("StatusBar", nil, canvas)
    progressBar:SetPoint("TOPLEFT", canvas, "TOPLEFT", 14, -11)
    progressBar:SetPoint("TOPRIGHT", canvas, "TOPRIGHT", -14, -11)
    progressBar:SetHeight(BAR_HEIGHT)
    progressBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    progressBar:SetStatusBarColor(0.20, 0.45, 0.13)
    progressBar:SetMinMaxValues(0, 1)

    progressBar.Background = progressBar:CreateTexture(nil, "BACKGROUND")
    progressBar.Background:SetAllPoints(progressBar)
    progressBar.Background:SetColorTexture(0, 0, 0, 0.45)

    progressBar.Edges = {}
    for _, edge in ipairs({{"TOPLEFT", "TOPRIGHT"}, {"BOTTOMLEFT", "BOTTOMRIGHT"}, {"TOPLEFT", "BOTTOMLEFT"}, {"TOPRIGHT", "BOTTOMRIGHT"}}) do
        local texture = progressBar:CreateTexture(nil, "OVERLAY")
        texture:SetColorTexture(0.45, 0.36, 0.22, 0.9)
        texture:SetPoint(edge[1], progressBar, edge[1])
        texture:SetPoint(edge[2], progressBar, edge[2])
        texture:SetSize(1, 1)
        table.insert(progressBar.Edges, texture)
    end

    progressBar.Text = progressBar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    progressBar.Text:SetPoint("CENTER")
end

---@param canvas Frame
function _QuestieJourney.quests.Build(canvas)
    tabBar = JourneyTabBar.Create(canvas, function() _Select(overviewTab) end)
    tabBar:SetPoint("BOTTOMLEFT", canvas, "TOPLEFT", QuestieOptionsWindow.HEADER_INSET + title:GetStringWidth() + TITLE_GAP, 1)
    tabBar:SetPoint("BOTTOMRIGHT", canvas, "TOPRIGHT", -SEARCH_INSET - searchBox:GetWidth() - SEARCH_GAP, 1)
    _CreateProgressBar(canvas)
    panes = JourneyPanes.Create(canvas, "", TOOLBAR_HEIGHT)
end

function _QuestieJourney.quests.OnSelected()
    _MoveHere()
end

function _QuestieJourney.quests.Refresh()
    _Select(selectedTab)
end

-------------------------
-- Interface
-------------------------

---Shows something in the tab that is shown. What was there before can be gone back to.
---@param kind JourneyKind
---@param id number
function _QuestieJourney.quests.Open(kind, id)
    JourneyPage.Open(selectedTab.page, kind, id)
end

---@param source string
function _QuestieJourney.quests.OpenSource(source)
    _OpenSource(source)
end

function _QuestieJourney.quests.ShowWatchedFaction()
    QuestieCompat.ExpandFactionHeader(0)
    for i = 1, QuestieCompat.GetNumFactions() do
        local _, _, _, _, _, _, _, _, isHeader, _, _, isWatched, _, id = QuestieCompat.GetFactionInfo(i)
        if isWatched and not isHeader and QuestieJourney.factionMap[id] then
            _OpenSource("faction:" .. id)
            return
        end
    end
    _OpenSource("overview:" .. JourneyOverviewPage.FACTIONS)
end

function _QuestieJourney.quests.ShowCurrentZone()
    _Select(hereTab)
end
