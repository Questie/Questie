---What the plus behind the tabs leads to: the zones and factions there are, starting with those that are good for the player now.
---On the left are the categories, on the right what is in the selected one. Choosing something there opens it in a tab.
---@class JourneyOverviewPage
local JourneyOverviewPage = QuestieLoader:CreateModule("JourneyOverviewPage")

---@type JourneyDetails
local JourneyDetails = QuestieLoader:ImportModule("JourneyDetails")
---@type JourneyFactions
local JourneyFactions = QuestieLoader:ImportModule("JourneyFactions")
---@type JourneyIcon
local JourneyIcon = QuestieLoader:ImportModule("JourneyIcon")
---@type JourneyOverviewRows
local JourneyOverviewRows = QuestieLoader:ImportModule("JourneyOverviewRows")
---@type JourneyPage
local JourneyPage = QuestieLoader:ImportModule("JourneyPage")
---@type JourneyPlaces
local JourneyPlaces = QuestieLoader:ImportModule("JourneyPlaces")
---@type JourneySummary
local JourneySummary = QuestieLoader:ImportModule("JourneySummary")
---@type JourneyZoneLevels
local JourneyZoneLevels = QuestieLoader:ImportModule("JourneyZoneLevels")
---@type QuestieJourney
local QuestieJourney = QuestieLoader:ImportModule("QuestieJourney")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

-- Categories that aren't a group of zones, which have a number
local GOOD, FACTIONS = "good", "factions"
JourneyOverviewPage.FACTIONS = FACTIONS
local MAX_GOOD_ZONES, MAX_GOOD_DUNGEONS, MAX_GOOD_FACTIONS = 4, 3, 2
local REPUTATION_COLOR = {0.36, 0.36, 0.78}
local CITIES = BUG_CATEGORY4 -- Blizzard's only string that is just "Cities"

-- Icons. The ones for achievements, with the continents, were checked in the files of every client but TBC's.
local GOOD_PICTURE, FACTIONS_PICTURE, ALL_PICTURE, DEFAULT_PICTURE = {atlas = "auctionhouse-icon-favorite"}, 236681, 133741, 134269
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
    page.pastSelections = {}
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

    local rows = {{type = "gap", height = 4}, JourneyOverviewRows.GetTiles({{
        text = RECOMMENDED,
        picture = GOOD_PICTURE,
        note = l10n("Good for your level"),
        isSelected = _IsSelected(page, GOOD),
        onClick = function() _SelectCategory(page, GOOD) end,
    }}, true)}
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
    local rows = {JourneyOverviewRows.GetBanner(RECOMMENDED, l10n("Good for your level") .. l10n(": ") .. UnitLevel("player"), GOOD_PICTURE)}
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
-- Page
-------------------------

---@param page JourneyPage.Instance
local function _Show(page)
    _ShowCategories(page)
    JourneyPage.ShowDetails(page, true)
    local completed, total = _CountAll()
    JourneyPage.SetProgress(page, total > 0 and l10n("%s of %s completed", completed, total) or "", total > 0 and completed / total or nil)
end

---@param page JourneyPage.Instance
function JourneyOverviewPage.Load(page)
    if not page.categories then
        page.categories = JourneyDetails.Create(page.listFrame, true)
        page.tree.list:Hide()
    end
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
    if page.categories then
        _ShowCategories(page)
    end
end

---@param page JourneyPage.Instance
---@param selection JourneyPage.Selection
---@return JourneyDetails.Row[]?
function JourneyOverviewPage.GetRows(page, selection)
    if selection.kind ~= "category" then
        return nil
    elseif selection.id == GOOD then
        return _GetGoodRows(page)
    elseif selection.id == FACTIONS then
        return _GetFactionRows(page)
    end
    return _GetGroupRows(page, selection.id)
end

return JourneyOverviewPage
