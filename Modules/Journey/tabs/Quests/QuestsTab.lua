---The quests of the Journey, in tabs like those of a browser. The first one is always the zone the player is in. The plus leads
---to the search and to all the other zones and factions, which get a tab of their own.
---@type QuestieJourney
local QuestieJourney = QuestieLoader:CreateModule("QuestieJourney")
local _QuestieJourney = QuestieJourney.private
_QuestieJourney.quests = {}
-------------------------
--Import modules.
-------------------------
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
---@type JourneyTabBar
local JourneyTabBar = QuestieLoader:ImportModule("JourneyTabBar")
---@type JourneyWindow
local JourneyWindow = QuestieLoader:ImportModule("JourneyWindow")
---@type QuestieCompat
local QuestieCompat = QuestieLoader:ImportModule("QuestieCompat")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestieOptionsWindow
local QuestieOptionsWindow = QuestieLoader:ImportModule("QuestieOptionsWindow")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local TOOLBAR_HEIGHT = 40
local BAR_HEIGHT = 18
local HISTORY_BUTTON_SIZE = 24
local TITLE_GAP, TAB_BAR_RIGHT_INSET = 18, 16

-- A capital city has the icon of the spell that teleports there. The other zones have the picture of their continent. From SpellMisc of
-- Mists. Every client with the city has its icon, checked in the files of each build.
local CITY_PICTURES = {
    [1519] = 135763, -- Stormwind City, Spell_Arcane_TeleportStormWind
    [1537] = 135757, -- Ironforge
    [1657] = 135755, -- Darnassus
    [3557] = 135756, -- The Exodar
    [1637] = 135759, -- Orgrimmar
    [1497] = 135766, -- Undercity
    [1638] = 135765, -- Thunder Bluff
    [3487] = 135761, -- Silvermoon City
    [3703] = 135760, -- Shattrath City
    [4395] = 237509, -- Dalaran
}

local sorts = QuestieDB.sortKeys
-- The icons of the professions, from SkillLine of Forever and Wrath (Era's and TBC's has a placeholder instead of most). Every client
-- with the profession has its icon, checked in the files of each build.
local PROFESSION_PICTURES = {
    [sorts.ALCHEMY] = 136240,
    [sorts.BLACKSMITHING] = 136241,
    [sorts.COOKING] = 133971,
    [sorts.ENGINEERING] = 136243,
    [sorts.FIRST_AID] = 135966,
    [sorts.FISHING] = 136245,
    [sorts.HERBALISM] = 136246,
    [sorts.INSCRIPTION] = 237171,
    [sorts.JEWELCRAFTING] = 134071,
    [sorts.LEATHERWORKING] = 136247,
    [sorts.TAILORING] = 136249,
}

-- The class of each sort of class quests. Its key in the sorts is its name in UnitClassBase.
local CLASS_OF_SORT = {}
for _, classFile in ipairs({"WARRIOR", "PALADIN", "HUNTER", "ROGUE", "PRIEST", "DEATHKNIGHT", "SHAMAN", "MAGE", "WARLOCK", "MONK", "DRUID"}) do
    CLASS_OF_SORT[sorts[classFile]] = classFile
end

---@class JourneyQuestsTab
---@field source string? What is listed. Nil for the overview.
---@field content JourneyPage.Content
---@field page JourneyPage.Instance? Nil until the tab is shown
---@field openedFrom JourneyPage.Selection? When the overview created the tab: what the overview showed. After the tab's own
---history, back leads there and closes the tab, like it was never opened.

---Where the player is. It only changes when the window is opened, so the list doesn't change while the player is using it.
---@type JourneyQuestsTab
local hereTab = {content = JourneyQuestsPage}
---In the order they are shown in. The overview isn't in it.
---@type JourneyQuestsTab[]
local tabs = {hereTab}
---@type JourneyQuestsTab
local overviewTab = {content = JourneyOverviewPage}
local selectedTab = hereTab

---Of closed tabs, for the next ones.
---@type JourneyPage.Instance[]
local freePages = {}

---@type JourneyPanes.Instance
local panes
---@type Frame
local tabBar
---@type Frame
local progressBar
---@type Button
local backButton
---@type Button
local forwardButton
---@type FontString
local title

-------------------------
-- Tabs
-------------------------

local _Select, _Close

local function _ShowToolbar()
    local page = selectedTab.page
    local text, share = page and page.progressText or "", page and page.progressShare
    progressBar.Text:SetText(text)
    progressBar:SetValue(share or 0)
    progressBar.Background:SetShown(share ~= nil)
    for _, edge in ipairs(progressBar.Edges) do edge:SetShown(share ~= nil) end

    backButton:SetEnabled(page ~= nil and (JourneyPage.CanGoBack(page) or selectedTab.openedFrom ~= nil))
    forwardButton:SetEnabled(page ~= nil and JourneyPage.CanGoForward(page))
end

---@param source string
---@return JourneyOverviewRows.Picture
local function _GetPicture(source)
    local kind, id = JourneyPlaces.Split(source)
    if kind == "zone" then
        if CLASS_OF_SORT[id] then
            return JourneyOverviewPage.GetClassPicture(CLASS_OF_SORT[id])
        end
        return CITY_PICTURES[id] or PROFESSION_PICTURES[id] or JourneyOverviewPage.GetGroupPicture(JourneyPlaces.GetGroupOf(id))
    elseif kind == "faction" then
        return JourneyOverviewPage.FACTIONS_PICTURE
    end
    return JourneyOverviewPage.ALL_PICTURE
end

---What kind of place it is, for below its name. Blizzard's texts, which every supported client has (checked in GlobalStrings), but
---Blizzard has none for the current zone.
---@param tab JourneyQuestsTab
---@return string
local function _GetLabel(tab)
    if tab == hereTab then
        return l10n("Current Zone")
    end
    local kind, id = JourneyPlaces.Split(tab.source)
    if kind == "faction" then
        return FACTION
    elseif kind ~= "zone" then
        return ""
    end
    local groupId = JourneyPlaces.GetGroupOf(id)
    local keys = QuestieJourney.questCategoryKeys
    if groupId == keys.DUNGEONS then
        return LFG_TYPE_DUNGEON
    elseif groupId == keys.BATTLEGROUNDS then
        return BATTLEGROUND
    elseif groupId and not JourneyPlaces.IsContinent(groupId) then
        return JourneyPlaces.GetGroupName(groupId) -- Like the class, professions and events
    end
    return ZONE
end

local function _ShowTabs()
    local shownTabs = {}
    for index, tab in ipairs(tabs) do
        shownTabs[index] = {
            name = JourneyPlaces.GetName(tab.source),
            picture = _GetPicture(tab.source),
            isHere = tab == hereTab,
            label = _GetLabel(tab),
            isSelected = tab == selectedTab,
            onSelect = function() _Select(tab) end,
            onClose = tab ~= hereTab and function() _Close(tab) end or nil,
        }
    end
    local shownFind = selectedTab == overviewTab and (JourneyOverviewPage.IsSearchShown(overviewTab.page) and "search" or "overview") or nil
    JourneyTabBar.SetTabs(tabBar, shownTabs, shownFind)
end

-- The overview can switch between its search and its categories
local function _OnPageChanged()
    _ShowTabs()
    _ShowToolbar()
end

local _OpenSource, _OpenFromOverview

---@param tab JourneyQuestsTab
local function _EnsurePage(tab)
    if not tab.page then
        if tab == overviewTab then
            -- The overview has its own list, so its page is never for anything else
            tab.page = JourneyPage.Create(panes, _OpenFromOverview, _OnPageChanged)
        else
            tab.page = table.remove(freePages) or JourneyPage.Create(panes, function(source) _OpenSource(source) end, _OnPageChanged)
        end
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
    _ShowToolbar()
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

---@param selection JourneyPage.Selection
local function _ShowOverview(selection)
    _EnsurePage(overviewTab)
    _Select(overviewTab)
    JourneyPage.Select(overviewTab.page, selection)
end

---The plus always starts at the overview, like a new tab of a browser.
local function _ResetOverview()
    _EnsurePage(overviewTab)
    JourneyPage.ForgetHistory(overviewTab.page)
    _ShowOverview({kind = "category", id = JourneyOverviewPage.GOOD})
end

---Shows a zone, a faction and so on, in the tab it already has or in a new one.
---@param source string Of quests, or a category of the overview, like "overview:1"
_OpenSource = function(source)
    local kind, category = source:match("^(overview):(.+)$")
    if kind then
        _ShowOverview({kind = "category", id = tonumber(category) or category})
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

---A tab that is already open is only shown, so it doesn't lead back to the overview.
---@param source string
_OpenFromOverview = function(source)
    local shown = overviewTab.page.selection
    local isNew = _FindTab(source) == nil
    _OpenSource(source)
    if isNew then
        selectedTab.openedFrom = shown
        _ShowToolbar()
    end
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

---Shows the search, which is in the overview, with the cursor in its box.
---@param text string? Searched for instead of what was typed
function _QuestieJourney.quests.ShowSearch(text)
    _OpenSource("overview:" .. JourneyOverviewPage.SEARCH)
    JourneyOverviewPage.FocusSearch(overviewTab.page, text)
end

---The title belongs to the window, because it is there whichever of its tabs is shown.
---@param newTitle FontString
function _QuestieJourney.quests.UseHeader(newTitle)
    title = newTitle
end

-------------------------
-- Canvas
-------------------------

local function _GoBack()
    local tab = selectedTab
    if JourneyPage.CanGoBack(tab.page) then
        JourneyPage.GoBack(tab.page)
    else
        _ShowOverview(tab.openedFrom)
        _Close(tab)
    end
end

---Back and forward through what the shown tab showed, like in a browser
---@param canvas Frame
local function _CreateHistoryButtons(canvas)
    ---@param textureName string Of the arrows of the spellbook
    ---@param onClick fun()
    ---@return Button
    local function Create(textureName, onClick)
        local button = CreateFrame("Button", nil, canvas)
        button:SetSize(HISTORY_BUTTON_SIZE, HISTORY_BUTTON_SIZE)
        local path = "Interface\\Buttons\\UI-SpellbookIcon-" .. textureName
        button:SetNormalTexture(path .. "-Up")
        button:SetPushedTexture(path .. "-Down")
        button:SetDisabledTexture(path .. "-Disabled")
        button:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
        button:SetScript("OnClick", onClick)
        return button
    end

    backButton = Create("PrevPage", _GoBack)
    backButton:SetPoint("LEFT", canvas, "TOPLEFT", -2, -TOOLBAR_HEIGHT / 2)
    forwardButton = Create("NextPage", function() JourneyPage.GoForward(selectedTab.page) end)
    forwardButton:SetPoint("LEFT", backButton, "RIGHT", -2, 0)
end

---@param canvas Frame
local function _CreateProgressBar(canvas)
    progressBar = CreateFrame("StatusBar", nil, canvas)
    -- It ends a bit before the border of the box below
    progressBar:SetPoint("LEFT", forwardButton, "RIGHT", 4, 0)
    progressBar:SetPoint("RIGHT", canvas, "TOPRIGHT", -10, -TOOLBAR_HEIGHT / 2)
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
    tabBar = JourneyTabBar.Create(canvas, _QuestieJourney.quests.ShowSearch, _ResetOverview)
    tabBar:SetPoint("BOTTOMLEFT", canvas, "TOPLEFT", QuestieOptionsWindow.HEADER_INSET + title:GetStringWidth() + TITLE_GAP, 1)
    tabBar:SetPoint("BOTTOMRIGHT", canvas, "TOPRIGHT", -TAB_BAR_RIGHT_INSET, 1)
    _CreateHistoryButtons(canvas)
    _CreateProgressBar(canvas)
    panes = JourneyPanes.Create(canvas, "", TOOLBAR_HEIGHT, Questie.db.char.journeyWindow.quests)
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
