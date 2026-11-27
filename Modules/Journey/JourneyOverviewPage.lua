---What the plus behind the tabs leads to: the search, and the zones and factions there are, starting with those that are good
---for the player now. On the left are the categories, on the right what is in the selected one. Choosing something there opens
---it in a tab.
---@class JourneyOverviewPage
local JourneyOverviewPage = QuestieLoader:CreateModule("JourneyOverviewPage")

---@type JourneyDetails
local JourneyDetails = QuestieLoader:ImportModule("JourneyDetails")
---@type JourneyFactions
local JourneyFactions = QuestieLoader:ImportModule("JourneyFactions")
---@type JourneyIcon
local JourneyIcon = QuestieLoader:ImportModule("JourneyIcon")
---@type JourneyLinkInput
local JourneyLinkInput = QuestieLoader:ImportModule("JourneyLinkInput")
---@type JourneyLinks
local JourneyLinks = QuestieLoader:ImportModule("JourneyLinks")
---@type JourneyOverviewRows
local JourneyOverviewRows = QuestieLoader:ImportModule("JourneyOverviewRows")
---@type JourneyPage
local JourneyPage = QuestieLoader:ImportModule("JourneyPage")
---@type JourneyPlaces
local JourneyPlaces = QuestieLoader:ImportModule("JourneyPlaces")
---@type JourneyResultsPage
local JourneyResultsPage = QuestieLoader:ImportModule("JourneyResultsPage")
---@type JourneySummary
local JourneySummary = QuestieLoader:ImportModule("JourneySummary")
---@type JourneyThread
local JourneyThread = QuestieLoader:ImportModule("JourneyThread")
---@type JourneyTree
local JourneyTree = QuestieLoader:ImportModule("JourneyTree")
---@type JourneyZoneLevels
local JourneyZoneLevels = QuestieLoader:ImportModule("JourneyZoneLevels")
---@type QuestieJourney
local QuestieJourney = QuestieLoader:ImportModule("QuestieJourney")
---@type QuestieOptionsUtils
local QuestieOptionsUtils = QuestieLoader:ImportModule("QuestieOptionsUtils")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")
---@type utf8
local utf8 = QuestieLoader:ImportModule("utf8")

-- Categories that aren't a group of zones, which have a number
local SEARCH, GOOD, FACTIONS = "search", "good", "factions"
JourneyOverviewPage.SEARCH, JourneyOverviewPage.GOOD, JourneyOverviewPage.FACTIONS = SEARCH, GOOD, FACTIONS
local MAX_GOOD_ZONES, MAX_GOOD_DUNGEONS, MAX_GOOD_FACTIONS = 4, 3, 2
local REPUTATION_COLOR = {0.36, 0.36, 0.78}
local CITIES = BUG_CATEGORY4 -- Blizzard's only string that is just "Cities"

-- Icons. The ones for achievements, with the continents, were checked in the files of every client but TBC's.
local FACTIONS_PICTURE, ALL_PICTURE, DEFAULT_PICTURE = 236681, 133741, 134269
local SEARCH_PICTURE = "Interface\\Icons\\INV_Misc_Spyglass_03"
local SEARCH_TILE_WIDTH = 116
-- Blizzard's mark for the entrance of a dungeon, which Leatrix Maps shows on the map too
-- The ring is 53% of the atlas, the rest is glow (measured in the client)
local DUNGEONS_PICTURE = {atlas = "Dungeon", middle = 0.58}
local ALLIANCE_BANNER, HORDE_BANNER = 132486, 132485

---@type table<number, JourneyOverviewRows.Picture> By group
local pictures

---@param groupId number
---@return JourneyOverviewRows.Picture
local function _GetPicture(groupId)
    local keys = QuestieJourney.questCategoryKeys
    pictures = pictures or {
        [keys.EASTERN_KINGDOMS] = 236759,
        [keys.KALIMDOR] = 236807,
        [keys.OUTLAND] = 236813,
        [keys.NORTHREND] = 236812,
        [keys.DUNGEONS] = DUNGEONS_PICTURE,
        [keys.BATTLEGROUNDS] = UnitFactionGroup("player") == "Horde" and HORDE_BANNER or ALLIANCE_BANNER,
        [keys.CLASS] = {atlas = "classicon-" .. UnitClassBase("player"):lower()},
        [keys.PROFESSIONS] = 136241, -- Trade_BlackSmithing
        [keys.EVENTS] = 133202, -- INV_Holiday_Christmas_Present_01
    }
    return pictures[groupId] or DEFAULT_PICTURE
end

-------------------------
-- Counts
-------------------------

---@param zone JourneyPlace
---@return JourneySummary.Summary? summary Nil until it is counted
local function _GetSummary(zone)
    return JourneySummary.Get("zone:" .. zone.id)
end

---@param zones JourneyPlace[]
---@return number completed
---@return number total
local function _CountZones(zones)
    local completed, total = 0, 0
    for _, zone in ipairs(zones) do
        local summary = _GetSummary(zone)
        if summary then
            completed, total = completed + summary.completed, total + summary.total
        end
    end
    return completed, total
end

---@return number completed
---@return number total
local function _CountAll()
    local completed, total = 0, 0
    for _, group in ipairs(JourneyPlaces.GetGroups()) do
        local groupCompleted, groupTotal = _CountZones(JourneyPlaces.GetZones(group.id))
        completed, total = completed + groupCompleted, total + groupTotal
    end
    return completed, total
end

---@param zone JourneyPlace
---@return number
local function _GetSuited(zone)
    local summary = _GetSummary(zone)
    return summary and summary.suited or 0
end

---@param a JourneyPlace
---@param b JourneyPlace
---@return boolean
local function _HasMoreSuited(a, b)
    local suitedA, suitedB = _GetSuited(a), _GetSuited(b)
    return suitedA > suitedB or suitedA == suitedB and a.name < b.name
end

---@param groupId number
---@return boolean isWorld Whether its entries are zones, unlike professions and events
local function _IsWorld(groupId)
    local keys = QuestieJourney.questCategoryKeys
    return JourneyPlaces.IsContinent(groupId) or groupId == keys.DUNGEONS or groupId == keys.BATTLEGROUNDS or groupId == keys.SCENARIOS
end

-------------------------
-- Categories
-------------------------

---@param page JourneyPage.Instance
---@param id number|string
---@return boolean
local function _IsSelected(page, id)
    return page.selection ~= nil and page.selection.kind == "category" and page.selection.id == id
end

---@param page JourneyPage.Instance
---@param id number|string
local function _SelectCategory(page, id)
    JourneyPage.Select(page, {kind = "category", id = id})
end

---@param rows JourneyDetails.Row[]
---@param title string
---@param tiles JourneyOverviewRows.Tile[] Two of them are next to each other
local function _AddTiles(rows, title, tiles)
    if #tiles == 0 then
        return
    end
    table.insert(rows, JourneyOverviewRows.GetLabel(title))
    for index = 1, #tiles, 2 do
        table.insert(rows, JourneyOverviewRows.GetTiles({tiles[index], tiles[index + 1]}))
    end
end

---@param page JourneyPage.Instance
---@param group JourneyPlace
---@return JourneyOverviewRows.Tile
local function _GetGroupTile(page, group)
    local completed, total = _CountZones(JourneyPlaces.GetZones(group.id))
    return {
        text = group.name,
        picture = _GetPicture(group.id),
        value = completed,
        maximum = total,
        isSelected = _IsSelected(page, group.id),
        onClick = function() _SelectCategory(page, group.id) end,
    }
end

---@param page JourneyPage.Instance
local function _ShowCategories(page)
    local world, character, other = {}, {}, {}
    for _, group in ipairs(JourneyPlaces.GetGroups()) do
        local isEvents = group.id == QuestieJourney.questCategoryKeys.EVENTS
        table.insert(_IsWorld(group.id) and world or isEvents and other or character, _GetGroupTile(page, group))
    end

    local met, unmet = JourneyFactions.GetMet()
    table.insert(character, {
        text = REPUTATION,
        picture = FACTIONS_PICTURE,
        value = #met,
        maximum = #met + #unmet,
        color = REPUTATION_COLOR,
        isSelected = _IsSelected(page, FACTIONS),
        onClick = function() _SelectCategory(page, FACTIONS) end,
    })
    local completed, total = _CountAll()
    table.insert(other, {
        text = l10n("All Quests"),
        picture = ALL_PICTURE,
        value = completed,
        maximum = total,
        isSelected = false,
        onClick = function() page.onOpenSource(JourneyPlaces.ALL) end,
    })

    -- The search is also behind the magnifier of the tabs. Both ways are there, so the tabs don't have to be used.
    local rows = {{type = "gap", height = 4}, JourneyOverviewRows.GetTiles({
        {
            text = l10n("Search"),
            picture = SEARCH_PICTURE,
            width = SEARCH_TILE_WIDTH,
            isSelected = _IsSelected(page, SEARCH),
            onClick = function()
                _SelectCategory(page, SEARCH)
                JourneyOverviewPage.FocusSearch(page)
            end,
        },
        {
            text = OVERVIEW,
            note = l10n("Good for your level"),
            isSelected = _IsSelected(page, GOOD),
            onClick = function() _SelectCategory(page, GOOD) end,
        },
    }, true)}
    _AddTiles(rows, WORLD, world)
    _AddTiles(rows, CHARACTER, character)
    _AddTiles(rows, OTHER, other)
    JourneyDetails.SetRows(page.categories, rows, true)
end

-------------------------
-- Zones
-------------------------

---@param zone JourneyPlace
---@param summary JourneySummary.Summary
---@param levels JourneyZoneLevels.Levels?
local function _ShowTooltip(zone, summary, levels)
    local color = levels and JourneyZoneLevels.GetColor(levels) or HIGHLIGHT_FONT_COLOR
    GameTooltip:SetText(zone.name, color.r, color.g, color.b)
    GameTooltip:AddLine(zone.group, 0.6, 0.6, 0.6)
    if levels then
        GameTooltip:AddDoubleLine(l10n("Level"), JourneyZoneLevels.GetText(levels), 1, 1, 1, 1, 0.82, 0)
    end
    for _, line in ipairs({
        {l10n("Good for your level"), summary.suited},
        {QUEST_LOG, summary.log},
        {l10n("Available Quests"), summary.available},
        {l10n("Missing Requirement"), summary.later},
        {l10n("Completed Quests"), summary.completed},
    }) do
        if line[2] > 0 then
            GameTooltip:AddDoubleLine(line[1], line[2], 1, 1, 1, 1, 0.82, 0)
        end
    end
end

---@param page JourneyPage.Instance
---@param zone JourneyPlace
---@param index number In its section
---@return JourneyDetails.Row
local function _GetZoneRow(page, zone, index)
    local summary = _GetSummary(zone) or JourneySummary.EMPTY
    local levels = JourneyZoneLevels.Get(zone.id)
    return JourneyOverviewRows.GetZone({
        name = zone.name,
        color = levels and JourneyZoneLevels.GetColor(levels),
        levels = levels and JourneyZoneLevels.GetText(levels),
        icon = JourneySummary.IsFinished(summary) and Questie.icons["checkmark"] or nil,
        isHere = zone.id == JourneyPlaces.GetPlayerZone(),
        suited = summary.suited,
        log = summary.log,
        isLogComplete = summary.complete > 0,
        completed = summary.completed,
        total = summary.total,
        isOdd = index % 2 == 1,
        onClick = function() page.onOpenSource("zone:" .. zone.id) end,
        showTooltip = function() _ShowTooltip(zone, summary, levels) end,
    })
end

---@param rows JourneyDetails.Row[]
---@param page JourneyPage.Instance
---@param section JourneyDetails.Row
---@param zones JourneyPlace[] Nothing is added when it is empty
local function _AddZones(rows, page, section, zones)
    if #zones > 0 then
        table.insert(rows, section)
        for index, zone in ipairs(zones) do
            table.insert(rows, _GetZoneRow(page, zone, index))
        end
    end
end

---@param zones JourneyPlace[]
---@return string? note
local function _GetSuitedNote(zones)
    local suited = 0
    for _, zone in ipairs(zones) do
        suited = suited + _GetSuited(zone)
    end
    return suited > 0 and JourneyIcon.GetMarkup(Questie.icons["available"]) .. suited or nil
end

---@class JourneyOverviewPage.Bracket
---@field levels JourneyZoneLevels.Levels
---@field zones JourneyPlace[]

---@param groupId number
---@param zones JourneyPlace[]
---@return JourneyOverviewPage.Bracket[] brackets Those with the lowest levels come first
---@return JourneyPlace[] cities
---@return JourneyPlace[] others Those without levels
local function _SplitByLevel(groupId, zones)
    local brackets, bracketsByLevel, cities, others = {}, {}, {}, {}
    for _, zone in ipairs(zones) do
        local levels = JourneyZoneLevels.Get(zone.id)
        if JourneyZoneLevels.IsCity(zone.id) then
            table.insert(cities, zone)
        elseif not levels or not _IsWorld(groupId) then
            table.insert(others, zone)
        else
            local bracketLevels = JourneyZoneLevels.GetBracket(levels)
            local bracket = bracketsByLevel[bracketLevels.low]
            if not bracket then
                bracket = {levels = bracketLevels, zones = {}}
                bracketsByLevel[bracketLevels.low] = bracket
                table.insert(brackets, bracket)
            end
            table.insert(bracket.zones, zone)
        end
    end
    table.sort(brackets, function(a, b) return a.levels.low < b.levels.low end)
    for _, bracket in ipairs(brackets) do
        table.sort(bracket.zones, function(a, b)
            local lowA, lowB = JourneyZoneLevels.Get(a.id).low, JourneyZoneLevels.Get(b.id).low
            return lowA < lowB or lowA == lowB and a.name < b.name
        end)
    end
    return brackets, cities, others
end

---@param page JourneyPage.Instance
---@param groupId number
---@return JourneyDetails.Row[]
local function _GetGroupRows(page, groupId)
    local zones = JourneyPlaces.GetZones(groupId)
    local completed, total = _CountZones(zones)
    local rows = {JourneyOverviewRows.GetBanner(
        JourneyPlaces.GetGroupName(groupId),
        l10n("%s of %s completed", BreakUpLargeNumbers(completed), BreakUpLargeNumbers(total)),
        _GetPicture(groupId)
    )}
    local brackets, cities, others = _SplitByLevel(groupId, zones)
    for _, bracket in ipairs(brackets) do
        local title, color = JourneyZoneLevels.GetBracketTitle(bracket.levels), JourneyZoneLevels.GetColor(bracket.levels)
        _AddZones(rows, page, JourneyOverviewRows.GetSection(title, color, _GetSuitedNote(bracket.zones)), bracket.zones)
    end
    _AddZones(rows, page, JourneyOverviewRows.GetSection(CITIES, nil, _GetSuitedNote(cities)), cities)

    -- What isn't a zone, like a profession, has no levels. What there is something to do for comes first.
    local withQuests, rest = {}, {}
    for _, zone in ipairs(others) do
        local summary = _GetSummary(zone)
        table.insert(summary and summary.available + summary.log > 0 and withQuests or rest, zone)
    end
    _AddZones(rows, page, JourneyOverviewRows.GetSection(l10n("Available Quests"), nil, _GetSuitedNote(withQuests)), withQuests)
    _AddZones(rows, page, JourneyOverviewRows.GetSection(OTHER), rest)
    return rows
end

-------------------------
-- Other categories
-------------------------

---@param page JourneyPage.Instance
---@return JourneyDetails.Row[]
local function _GetGoodRows(page)
    local rows = {JourneyOverviewRows.GetBanner(OVERVIEW, l10n("Good for your level") .. l10n(": ") .. UnitLevel("player"))}
    for _, group in ipairs(JourneyPlaces.GetGroups()) do
        local isDungeons = JourneyPlaces.IsDungeons(group.id)
        if isDungeons or JourneyPlaces.IsContinent(group.id) then
            local suited = {}
            for _, zone in ipairs(JourneyPlaces.GetZones(group.id)) do
                local levels = JourneyZoneLevels.Get(zone.id)
                if _GetSuited(zone) > 0 and not (levels and JourneyZoneLevels.IsOutgrown(levels)) then
                    table.insert(suited, zone)
                end
            end
            table.sort(suited, _HasMoreSuited)
            for index = #suited, (isDungeons and MAX_GOOD_DUNGEONS or MAX_GOOD_ZONES) + 1, -1 do
                suited[index] = nil
            end
            _AddZones(rows, page, JourneyOverviewRows.GetSection(group.name, nil, nil, _GetPicture(group.id)), suited)
        end
    end

    local closest = JourneyFactions.GetClosest(MAX_GOOD_FACTIONS)
    if #closest > 0 then
        table.insert(rows, JourneyOverviewRows.GetSection(REPUTATION, nil, nil, FACTIONS_PICTURE))
    end
    for index, entry in ipairs(closest) do
        table.insert(rows, JourneyOverviewRows.GetFaction(entry.faction.name, entry.standing, index % 2 == 1, function()
            page.onOpenSource("faction:" .. entry.faction.id)
        end))
    end
    return rows
end

---@param page JourneyPage.Instance
---@return JourneyDetails.Row[]
local function _GetFactionRows(page)
    local met, unmet = JourneyFactions.GetMet()
    local rows = {JourneyOverviewRows.GetBanner(REPUTATION, #met .. " / " .. #met + #unmet, FACTIONS_PICTURE)}

    local standingId, index
    for _, entry in ipairs(met) do
        if entry.standing.id ~= standingId then
            standingId, index = entry.standing.id, 0
            table.insert(rows, JourneyOverviewRows.GetSection(entry.standing.name, entry.standing.color))
        end
        index = index + 1
        table.insert(rows, JourneyOverviewRows.GetFaction(entry.faction.name, entry.standing, index % 2 == 1, function()
            page.onOpenSource("faction:" .. entry.faction.id)
        end))
    end

    if #unmet > 0 then
        table.insert(rows, JourneyOverviewRows.GetSection(OTHER))
    end
    for unmetIndex, faction in ipairs(unmet) do
        table.insert(rows, JourneyOverviewRows.GetFaction(faction.name, nil, unmetIndex % 2 == 1, function()
            page.onOpenSource("faction:" .. faction.id)
        end))
    end
    return rows
end

-------------------------
-- Search
-------------------------

local SEARCH_DELAY_SECONDS = 0.15
local MIN_SEARCH_LENGTH = 3
local MIN_SEARCH_LENGTHS = {koKR = 2, zhCN = 2, zhTW = 2}
-- Kinds with more results than this start collapsed
local MAX_EXPANDED_RESULTS = 30
local SEARCH_AREA_HEIGHT = 34

---The box, and the list of what was found, like the lists of the other tabs. While something that was found is shown, they
---move into the list, so that it is next to them. The box isn't in the list, as that is shown again while the user types.
---@class JourneyOverviewPage.Search
---@field frame Frame In the details, or in the list while something that was found is shown
---@field box EditBox
---@field tree JourneyTree.Instance
---@field emptyText FontString
---@field query string What was searched for
---@field timer {Cancel: fun(self)}? Until the results are shown

---@param page JourneyPage.Instance
---@param search JourneyOverviewPage.Search
---@return string? path Of what is shown, if it was found
local function _FindShown(page, search)
    local selection = page.selection
    if not selection or selection.kind == "category" then
        return nil
    end
    return JourneyTree.FindPath(search.tree, function(node)
        return node.kind == selection.kind and node.value == selection.id
    end)
end

---Marks what is shown in the list, and brings it into view, unless it was clicked there.
---@param page JourneyPage.Instance
---@param search JourneyOverviewPage.Search
local function _SelectShown(page, search)
    local path = _FindShown(page, search)
    if path == search.tree.selectedPath then
        return
    elseif path then
        JourneyTree.Select(search.tree, path)
    else
        JourneyTree.MoveSelection(search.tree, nil)
    end
end

---@param search JourneyOverviewPage.Search
---@return string
local function _GetTypedQuery(search)
    return strtrim(search.box:GetText(), " \n\r\t[]")
end

---@param page JourneyPage.Instance
---@param search JourneyOverviewPage.Search
---@param delay number? Seconds to wait for more typing. Without it, even a short text is searched for, right away.
local function _Search(page, search, delay)
    if search.timer then
        search.timer:Cancel()
        search.timer = nil
    end
    local query = _GetTypedQuery(search)
    if query == search.query then
        return
    end

    local function Start()
        search.timer = JourneyThread.Start("JourneyOverviewPage.Search", function()
            local groups = JourneyResultsPage.Find(query)
            local expandedPaths, count = {}, 0
            for _, group in ipairs(groups) do
                count = count + #group.children
                expandedPaths[group.value] = #group.children <= MAX_EXPANDED_RESULTS or nil
            end
            search.query, search.tree.expandedPaths = query, expandedPaths
            JourneyTree.SetNodes(search.tree, groups)
            search.emptyText:SetText(l10n("No Match for Search Results: %s", query))
            search.emptyText:SetShown(count == 0)
            _SelectShown(page, search)
        end)
    end
    if query == "" then
        search.query = ""
        JourneyTree.Clear(search.tree)
        search.emptyText:Hide()
    elseif not delay then
        Start()
    elseif utf8.strlen(query) >= (MIN_SEARCH_LENGTHS[l10n:GetUILocale()] or MIN_SEARCH_LENGTH) then
        search.timer = C_Timer.NewTimer(delay, Start)
    end
end

---@param page JourneyPage.Instance
---@return JourneyOverviewPage.Search
local function _CreateSearch(page)
    local frame = CreateFrame("Frame", nil, page.detailsFrame)
    frame:SetAllPoints(page.detailsFrame)
    frame:Hide()

    local box = CreateFrame("EditBox", nil, frame, "SearchBoxTemplate")
    box:SetHeight(22)
    box:SetPoint("LEFT", frame, "TOPLEFT", 20, -4 - SEARCH_AREA_HEIGHT / 2)
    box:SetPoint("RIGHT", frame, "TOPRIGHT", -14, -4 - SEARCH_AREA_HEIGHT / 2)

    -- Under the box, which stays while the list below it changes. Like the line under the header of the window.
    local line = frame:CreateTexture(nil, "ARTWORK")
    line:SetAtlas("Options_HorizontalDivider")
    line:SetPoint("TOPLEFT", frame, "TOPLEFT", 4, -4 - SEARCH_AREA_HEIGHT)
    line:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", -4, -4 - SEARCH_AREA_HEIGHT - 1.5)
    QuestieOptionsUtils.DisableSnapping(line)
    box:SetAutoFocus(false)
    box.Instructions:SetText(table.concat({l10n("Quests"), l10n("NPCs"), l10n("Objects"), l10n("Items")}, ", "))

    local listArea = CreateFrame("Frame", nil, frame)
    listArea:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -4 - SEARCH_AREA_HEIGHT)
    listArea:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)

    ---@type JourneyOverviewPage.Search
    local search = {frame = frame, box = box, query = ""}
    search.tree = JourneyTree.Create(listArea, function(node)
        if node.source then
            -- It leads to a tab, so what is shown here stays selected
            JourneyTree.MoveSelection(search.tree, _FindShown(page, search))
            page.onOpenSource(node.source)
            return
        end
        if node.kind == "quest" then
            JourneyLinks.TryInsertIntoChat(node.value)
        end
        JourneyPage.Open(page, node.kind, node.value)
    end, JourneyResultsPage.GetIcon, JourneyResultsPage.GetText, JourneyResultsPage.GetNote)

    search.emptyText = frame:CreateFontString(nil, "ARTWORK", "GameFontDisable")
    search.emptyText:SetPoint("TOP", listArea, "TOP", 0, -12)
    search.emptyText:SetPoint("LEFT", listArea, "LEFT", 12, 0)
    search.emptyText:SetPoint("RIGHT", listArea, "RIGHT", -12, 0)
    search.emptyText:Hide()

    -- Hooked, because the template shows and hides its placeholder and clear button from this
    box:HookScript("OnTextChanged", function()
        -- A link that was shift-clicked or dropped becomes its name
        local linkText = box:GetText():match("|h%[(.-)%]|h")
        if linkText then
            box:SetText(linkText)
            return
        end
        _Search(page, search, SEARCH_DELAY_SECONDS)
    end)
    box:SetScript("OnEnterPressed", function()
        box:ClearFocus()
        local query = _GetTypedQuery(search)
        local place = query ~= "" and JourneyResultsPage.GetTypedPlace(query)
        if place then
            page.onOpenSource(place)
        else
            _Search(page, search)
        end
    end)
    local function TakeItem()
        local cursorType, _, itemLink = GetCursorInfo()
        if cursorType == "item" then
            ClearCursor()
            box:SetText(itemLink)
        end
    end
    box:SetScript("OnReceiveDrag", TakeItem)
    box:HookScript("OnMouseDown", TakeItem)
    JourneyLinkInput.Enable(box)
    -- Otherwise the keys would still type into it
    frame:SetScript("OnHide", function() box:ClearFocus() end)
    return search
end

---@param page JourneyPage.Instance
---@return boolean isSearchShown The search, or something that was found with it
function JourneyOverviewPage.IsSearchShown(page)
    local selection = page.selection
    return selection ~= nil and (selection.kind ~= "category" or selection.id == SEARCH)
end

---Shows the search, with the cursor in its box.
---@param page JourneyPage.Instance The search has to be selected in it
---@param text string? Searched for instead of what was typed
function JourneyOverviewPage.FocusSearch(page, text)
    local box = page.search.box
    if text then
        box:SetText(text)
    end
    box:SetFocus()
end

-------------------------
-- Page
-------------------------

---The categories and the search are only made for the overview.
---@param page JourneyPage.Instance
local function _CreateFrames(page)
    if page.categories then
        return
    end
    page.tree.list:Hide()
    page.categoriesFrame = CreateFrame("Frame", nil, page.listFrame)
    page.categoriesFrame:SetAllPoints(page.listFrame)
    page.categories = JourneyDetails.Create(page.categoriesFrame, true)
    page.search = _CreateSearch(page)
end

---The categories are in the list, and what is in the selected one in the details. While something that was found is
---shown in the details, the search is in the list instead.
---@param page JourneyPage.Instance
local function _Arrange(page)
    local selection = page.selection
    local isFound = selection ~= nil and selection.kind ~= "category"
    local search = page.search
    page.categoriesFrame:SetShown(not isFound)

    local pane = isFound and page.listFrame or page.detailsFrame
    if search.frame:GetParent() ~= pane then
        search.frame:SetParent(pane)
        search.frame:ClearAllPoints()
        search.frame:SetAllPoints(pane)
    end
    search.frame:SetFrameLevel(pane:GetFrameLevel() + 10) -- Above the details, which have nothing in them for the search
    search.frame:SetShown(isFound or _IsSelected(page, SEARCH))
    _SelectShown(page, search)
end

---@param page JourneyPage.Instance
local function _Show(page)
    _ShowCategories(page)
    JourneyPage.ShowDetails(page, true)
    local completed, total = _CountAll()
    JourneyPage.SetProgress(page, total > 0 and l10n("%s of %s completed", completed, total) or "", total > 0 and completed / total or nil)
end

---@param page JourneyPage.Instance
function JourneyOverviewPage.Load(page)
    _CreateFrames(page)
    page.selection = page.selection or {kind = "category", id = GOOD}
    if page.isLoaded then
        _Show(page) -- With what was counted before
    end
    JourneyZoneLevels.Read()
    for _, group in ipairs(JourneyPlaces.GetGroups()) do
        for _, zone in ipairs(JourneyPlaces.GetZones(group.id)) do
            local source = "zone:" .. zone.id
            JourneySummary.Count(source, JourneyPlaces.GetQuestIds(source))
        end
    end
    _Show(page)
end

---@param page JourneyPage.Instance
function JourneyOverviewPage.OnShowDetails(page)
    _CreateFrames(page)
    _ShowCategories(page)
    _Arrange(page)
end

---@param page JourneyPage.Instance
---@param selection JourneyPage.Selection
---@return JourneyDetails.Row[]?
function JourneyOverviewPage.GetRows(page, selection)
    if selection.kind ~= "category" then
        return nil -- Something that was found
    elseif selection.id == SEARCH then
        return {} -- The search shows its results itself
    elseif selection.id == GOOD then
        return _GetGoodRows(page)
    elseif selection.id == FACTIONS then
        return _GetFactionRows(page)
    end
    return _GetGroupRows(page, selection.id)
end

return JourneyOverviewPage
