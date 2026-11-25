---@type QuestieJourney
local QuestieJourney = QuestieLoader:CreateModule("QuestieJourney")
local _QuestieJourney = QuestieJourney.private
_QuestieJourney.quests = {}
-------------------------
--Import modules.
-------------------------
---@type JourneyDetails
local JourneyDetails = QuestieLoader:ImportModule("JourneyDetails")
---@type JourneyEntityDetails
local JourneyEntityDetails = QuestieLoader:ImportModule("JourneyEntityDetails")
---@type JourneyLinkInput
local JourneyLinkInput = QuestieLoader:ImportModule("JourneyLinkInput")
---@type JourneyLinks
local JourneyLinks = QuestieLoader:ImportModule("JourneyLinks")
---@type JourneyPanes
local JourneyPanes = QuestieLoader:ImportModule("JourneyPanes")
---@type JourneyPicker
local JourneyPicker = QuestieLoader:ImportModule("JourneyPicker")
---@type JourneyQuestCategories
local JourneyQuestCategories = QuestieLoader:ImportModule("JourneyQuestCategories")
---@type JourneyQuestDetails
local JourneyQuestDetails = QuestieLoader:ImportModule("JourneyQuestDetails")
---@type JourneyThread
local JourneyThread = QuestieLoader:ImportModule("JourneyThread")
---@type JourneyTree
local JourneyTree = QuestieLoader:ImportModule("JourneyTree")
---@type JourneyWindow
local JourneyWindow = QuestieLoader:ImportModule("JourneyWindow")
---@type QuestieCompat
local QuestieCompat = QuestieLoader:ImportModule("QuestieCompat")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestieJourneyUtils
local QuestieJourneyUtils = QuestieLoader:ImportModule("QuestieJourneyUtils")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
---@type QuestiePlayer
local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
---@type QuestieSearch
local QuestieSearch = QuestieLoader:ImportModule("QuestieSearch")
---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule("ZoneDB")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")
---@type utf8
local utf8 = QuestieLoader:ImportModule("utf8")

local PICKER_WIDTH = 260
local TOOLBAR_HEIGHT = 46
local BAR_HEIGHT = 18
local SEARCH_DELAY_SECONDS = 0.15
local MIN_SEARCH_LENGTH = 3
local MIN_SEARCH_LENGTHS = {koKR = 2, zhCN = 2, zhTW = 2}
-- Kinds with more results than this start collapsed
local MAX_EXPANDED_RESULTS = 30
local KIND_TITLES = {quest = "Quests", npc = "NPCs", object = "Objects", item = "Items"}

-- Sources of quests. A zone, an overview of zones and a faction also have an ID: "zone:40".
local HERE, ALL, CLASS, PETS = "here", "all", "class", "pets"

local playerClass = UnitClassBase("player")

local source = HERE
---@type Frame
local picker
---@type Frame
local bar
---@type JourneyTree.Instance
local tree
---@type JourneyDetails.Instance
local details
---@type FontString
local emptyText
---@type EditBox
local searchBox

---What the details show. It doesn't have to be in the list, because links lead anywhere.
---@type {kind: JourneyKind, id: number}?
local selection
---What was shown before
---@type {kind: JourneyKind, id: number}[]
local pastSelections = {}

local listedSource
local loadTimer, searchTimer
local query, runningQuery = "", ""
---@type table<JourneyKind, number[]>?
local results

-------------------------
-- Sources
-------------------------

---@param newSource string
---@return string kind
---@return number? id
local function _Split(newSource)
    local kind, id = newSource:match("^(%a+):(%-?%d+)$")
    return kind or newSource, tonumber(id)
end

---@return number
local function _GetPlayerZone()
    local subZoneToParentZoneOverride = loadstring(ZoneDB.private.subZoneToParentZoneOverride)()
    local currentZoneId = QuestiePlayer:GetCurrentZoneId()
    return subZoneToParentZoneOverride[currentZoneId] or currentZoneId
end

---@param factionId number
---@return string?
local function _GetFactionName(factionId)
    for _, factions in pairs(QuestieJourney.factionsByExpansion) do
        if factions[factionId] then
            return factions[factionId]
        end
    end
end

---@param zoneId number
---@return string
local function _GetZoneName(zoneId)
    for _, zones in pairs(QuestieJourney.zones) do
        if zones[zoneId] then
            return zones[zoneId]
        end
    end
    return zoneId > 0 and QuestieJourneyUtils:GetZoneName(zoneId) or ""
end

---@param anySource string
---@return string
local function _GetSourceName(anySource)
    local kind, id = _Split(anySource)
    if kind == HERE then
        return _GetZoneName(_GetPlayerZone())
    elseif kind == ALL then
        return l10n("All Quests")
    elseif kind == CLASS then
        return QuestieJourney.continents[QuestieJourney.questCategoryKeys.CLASS]
    elseif kind == PETS then
        return QuestieJourney.continents[QuestieJourney.questCategoryKeys.PET_BATTLES]
    elseif kind == "zones" then
        return QuestieJourney.continents[id] or ""
    elseif kind == "faction" then
        return _GetFactionName(id) or ""
    end
    return _GetZoneName(id)
end

---Yields, so it runs in a thread.
---@async
---@param anySource string
---@return table<QuestId, any>
local function _GetQuestIds(anySource)
    local kind, id = _Split(anySource)
    if kind == HERE then
        return QuestieJourney.zoneMap[_GetPlayerZone()] or {}
    elseif kind == CLASS then
        return QuestieJourney.zoneMap[QuestieDB:GetZoneOrSortForClass(playerClass)] or {}
    elseif kind == PETS then
        return QuestieJourney.zoneMap[QuestieDB.sortKeys.PET_BATTLE] or {}
    elseif kind == "faction" then
        return QuestieJourney.factionMap[id] or {}
    elseif kind == ALL then
        local questIds = {}
        for _, quests in pairs(QuestieJourney.zoneMap) do
            for questId in pairs(quests) do questIds[questId] = true end
            JourneyThread.YieldIfNeeded()
        end
        return questIds
    end
    return QuestieJourney.zoneMap[id] or {}
end

---@param names table<number, string>
---@param prefix string
---@return JourneyPicker.Choice[]
local function _GetNamedChoices(names, prefix)
    local choices = {}
    for _, id in ipairs(QuestieJourneyUtils:GetSortedZoneKeys(names)) do
        table.insert(choices, {text = names[id], value = prefix .. ":" .. id})
    end
    return choices
end

---@return JourneyPicker.Choice[]
local function _GetChoices()
    local keys = QuestieJourney.questCategoryKeys
    local choices = {
        {text = l10n("Current zone") .. "  " .. Questie:Colorize(_GetSourceName(HERE), "gray"), value = HERE},
        {text = l10n("All Quests"), value = ALL},
        {isDivider = true},
    }
    local categories = {}
    for id in pairs(QuestieJourney.continents) do table.insert(categories, id) end
    table.sort(categories)
    for _, id in ipairs(categories) do
        local name = QuestieJourney.continents[id]
        if id == keys.CLASS then
            table.insert(choices, {text = name, value = CLASS})
        elseif id == keys.PET_BATTLES then
            table.insert(choices, {text = name, value = PETS})
        elseif QuestieJourney.zones[id] then
            local zones = _GetNamedChoices(QuestieJourney.zones[id], "zone")
            table.insert(zones, 1, {text = Questie:Colorize(OVERVIEW, "yellow"), value = "zones:" .. id})
            table.insert(zones, 2, {isDivider = true})
            table.insert(choices, {text = name, value = "zones:" .. id, choices = zones})
        end
    end
    table.insert(choices, {isDivider = true})
    for _, key in ipairs(QuestieJourney.availableFactionExpansionOrder) do
        table.insert(choices, {
            text = #QuestieJourney.availableFactionExpansionOrder == 1 and l10n("Factions") or QuestieJourney.availableFactionExpansions[key],
            choices = _GetNamedChoices(QuestieJourney.factionsByExpansion[key], "faction"),
        })
    end
    return choices
end

-------------------------
-- Details
-------------------------

local _Open

---@param keepsScrollPosition boolean?
local function _ShowDetails(keepsScrollPosition)
    local rows = {}
    local function Update() _ShowDetails(true) end
    if selection and selection.kind == "quest" then
        local quest = QuestieDB.GetQuest(selection.id)
        rows = quest and JourneyQuestDetails.GetRows(quest, Update) or {}
    elseif selection then
        rows = JourneyEntityDetails.GetRows(selection.kind, selection.id, Update)
    end
    if rows[1] and #pastSelections > 0 then
        rows[1].onBack = function()
            local past = table.remove(pastSelections)
            selection = nil
            _Open(past.kind, past.id)
        end
        rows[1].state = "back"
    end
    JourneyDetails.SetRows(details, rows, keepsScrollPosition)
end

---@param kind JourneyKind
---@param id number
---@return string? path
local function _FindPath(kind, id)
    return JourneyTree.FindPath(tree, function(node) return node.value == id and (node.kind or "quest") == kind end)
end

---@param kind JourneyKind
---@param id number
_Open = function(kind, id)
    selection = {kind = kind, id = id}
    local path = _FindPath(kind, id)
    if path then
        JourneyTree.Select(tree, path)
    else
        JourneyTree.MoveSelection(tree, nil)
    end
    _ShowDetails()
end

-------------------------
-- List
-------------------------

---@param text string
---@param share number?
local function _ShowProgress(text, share)
    bar.Text:SetText(text)
    bar:SetValue(share or 0)
    bar.Background:SetShown(share ~= nil)
    for _, edge in ipairs(bar.Edges) do edge:SetShown(share ~= nil) end
end

---@param nodes JourneyTreeNode[]
---@return JourneyTreeNode?
local function _GetFirstQuest(nodes)
    for _, node in ipairs(nodes) do
        if node.value ~= "completed" and node.children[1] then
            return node.children[1]
        end
    end
end

---@param thisSource string
local function _LoadQuests(thisSource)
    local isNew = listedSource ~= thisSource
    local nodes, completed, total = JourneyQuestCategories.Collect(_GetQuestIds(thisSource))
    if isNew then
        JourneyTree.Expand(tree, "log")
        JourneyTree.Expand(tree, "available")
        JourneyTree.Expand(tree, "repeatable")
    end
    listedSource = thisSource
    JourneyTree.SetNodes(tree, nodes)
    emptyText:SetText(l10n("No Quests found"))
    emptyText:SetShown(JourneyTree.IsEmpty(tree))
    _ShowProgress(total > 0 and l10n("%s of %s completed", completed, total) or "", total > 0 and completed / total or nil)

    if isNew and not selection then
        local first = _GetFirstQuest(nodes)
        if first then
            selection = {kind = "quest", id = first.value}
        end
    end
    if selection and not JourneyTree.IsSelectionListed(tree) then
        local path = _FindPath(selection.kind, selection.id)
        if tree.selectedPath then
            JourneyTree.MoveSelection(tree, path)
        else
            JourneyTree.Select(tree, path)
        end
    end
    _ShowDetails(not isNew)
end

---@param node JourneyTreeNode Of a zone
---@param categories JourneyTreeNode[]
---@return {zoneId: number, name: string, count: number, low: number, high: number}?
local function _GetSuggestion(node, categories)
    local playerLevel = UnitLevel("player")
    local count, low, high = 0, 999, 0
    for _, category in ipairs(categories) do
        if category.value == "available" or category.value == "log" then
            for _, quest in ipairs(category.children) do
                local level = QuestieLib.GetEffectiveQuestLevel(quest.value)
                if level <= playerLevel + 3 and not QuestieDB.IsTrivial(level) then
                    count, low, high = count + 1, math.min(low, level), math.max(high, level)
                end
            end
        end
    end
    return count > 0 and {zoneId = node.value, name = node.text, count = count, low = low, high = high} or nil
end

---@param categoryId number
---@param suggestions {zoneId: number, name: string, count: number, low: number, high: number}[]
local function _ShowSuggestions(categoryId, suggestions)
    table.sort(suggestions, function(a, b) return a.count > b.count or a.count == b.count and a.name < b.name end)
    local rows = {
        {type = "page", text = QuestieJourney.continents[categoryId]},
        {type = "caption", text = l10n("Good for your level")},
    }
    for _, suggestion in ipairs(suggestions) do
        table.insert(rows, {
            type = "step",
            text = suggestion.name,
            tag = Questie:Colorize(l10n("Level %s", suggestion.low == suggestion.high and suggestion.low or suggestion.low .. "-" .. suggestion.high), "gray")
                .. "     " .. Questie:Colorize(tostring(suggestion.count), "yellow"),
            trailingIcon = Questie.icons["available"],
            onClick = function() _QuestieJourney.quests.Choose("zone:" .. suggestion.zoneId) end,
        })
    end
    if #suggestions == 0 then
        table.insert(rows, {type = "text", text = Questie:Colorize(l10n("Nothing available here right now"), "gray")})
    end
    JourneyDetails.SetRows(details, rows, true)
end

---Lists the zones of a continent, with how many of their quests are completed.
---@param thisSource string
local function _LoadZones(thisSource)
    local _, categoryId = _Split(thisSource)
    local nodes = {}
    local zones = QuestieJourney.zones[categoryId] or {}
    for _, zoneId in ipairs(QuestieJourneyUtils:GetSortedZoneKeys(zones)) do
        table.insert(nodes, {value = zoneId, kind = "zone", text = zones[zoneId], note = "..."})
    end
    listedSource = thisSource
    JourneyTree.SetNodes(tree, nodes)
    emptyText:Hide()
    local allCompleted, allTotal = 0, 0
    local suggestions = {}
    for _, node in ipairs(nodes) do
        local categories, completed, total = JourneyQuestCategories.Collect(QuestieJourney.zoneMap[node.value] or {})
        local suggestion = _GetSuggestion(node, categories)
        if suggestion then
            table.insert(suggestions, suggestion)
        end
        allCompleted, allTotal = allCompleted + completed, allTotal + total
        node.note = completed .. " / " .. total
        node.icon = total > 0 and completed == total and Questie.icons["checkmark"] or nil
        if completed == 0 then
            node.note = Questie:Colorize(node.note, "gray")
        elseif completed < total then
            node.note = Questie:Colorize(node.note, "yellow")
        else
            node.note = Questie:Colorize(node.note, "green")
        end
        JourneyTree.SetNodes(tree, nodes)
        _ShowProgress(l10n("%s of %s completed", allCompleted, allTotal), allTotal > 0 and allCompleted / allTotal or 0)
        _ShowSuggestions(categoryId, suggestions)
        JourneyThread.YieldIfNeeded()
    end
end

local function _LoadResults()
    listedSource = nil
    local nodes, count = {}, 0
    for _, kind in ipairs(QuestieSearch.KINDS) do
        local ids = results[kind]
        count = count + #ids
        local children = {}
        for index, id in ipairs(ids) do
            children[index] = {value = id, kind = kind}
        end
        table.insert(nodes, {value = "result " .. kind, text = l10n(KIND_TITLES[kind]), note = tostring(#ids), children = children})
        tree.expandedPaths["result " .. kind] = #ids <= MAX_EXPANDED_RESULTS or nil
    end
    JourneyTree.SetNodes(tree, nodes)
    emptyText:SetText(l10n("No Match for Search Results: %s", query))
    emptyText:SetShown(count == 0)
    _ShowProgress(l10n("Results for %s: %s", Questie:Colorize(query, "yellow"), count), nil)
end

local function _Load()
    if loadTimer then
        loadTimer:Cancel()
    end
    local sourceText = _GetSourceName(source) .. (source == HERE and Questie:Colorize("   " .. l10n("current zone"), "gray") or "")
    JourneyPicker.SetText(picker, query ~= "" and Questie:Colorize(sourceText, "gray") or sourceText)
    if query ~= "" then
        _LoadResults()
        _ShowDetails(true)
        return
    end

    local thisSource = source
    local effectiveSource = thisSource == HERE and "zone:" .. _GetPlayerZone() or thisSource
    if listedSource ~= effectiveSource then
        JourneyTree.Select(tree, nil)
        JourneyTree.SetNodes(tree, {})
        emptyText:Hide()
    end
    local load = _Split(effectiveSource) == "zones" and _LoadZones or _LoadQuests
    loadTimer = JourneyThread.Start("JourneyQuests", function() load(effectiveSource) end)
end

---@param newSource string
local function _Choose(newSource)
    source = newSource
    selection, pastSelections = nil, {}
    if query ~= "" then
        query, runningQuery, results = "", "", nil
        searchBox:SetText("")
    end
    listedSource = nil
    _ShowDetails()
    _Load()
end

-------------------------
-- Search
-------------------------

local function _CancelSearch()
    if searchTimer then
        searchTimer:Cancel()
    end
    if loadTimer and runningQuery ~= query then
        loadTimer:Cancel()
    end
    runningQuery = query
end

---@param newQuery string
local function _Search(newQuery)
    _CancelSearch()
    runningQuery = newQuery
    if loadTimer then
        loadTimer:Cancel()
    end
    loadTimer = JourneyThread.Start("QuestieSearch", function()
        local newResults = {}
        for _, kind in ipairs(QuestieSearch.KINDS) do
            newResults[kind] = QuestieSearch.Search(kind, newQuery)
        end
        query, results = newQuery, newResults
        _Load()
    end)
end

local function _GetTypedQuery()
    return strtrim(searchBox:GetText(), " \n\r\t[]")
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
    local typedQuery = _GetTypedQuery()
    if typedQuery == runningQuery then
        return
    end
    _CancelSearch()
    local minLength = MIN_SEARCH_LENGTHS[l10n:GetUILocale()] or MIN_SEARCH_LENGTH
    if utf8.strlen(typedQuery) >= minLength then
        searchTimer = C_Timer.NewTimer(SEARCH_DELAY_SECONDS, function()
            JourneyWindow.ShowQuests()
            _Search(typedQuery)
        end)
    elseif typedQuery == "" and query ~= "" then
        query, runningQuery, results = "", "", nil
        listedSource = nil
        _Load()
    end
end

---The search box belongs to the window, because it is there whichever tab is shown.
---@param box EditBox
function _QuestieJourney.quests.UseSearchBox(box)
    searchBox = box
    box:HookScript("OnTextChanged", _OnTextChanged)
    box:SetScript("OnEnterPressed", function()
        box:ClearFocus()
        local typedQuery = _GetTypedQuery()
        if typedQuery ~= "" then
            JourneyWindow.ShowQuests()
            _Search(typedQuery)
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
end

---@param node JourneyTreeNode
---@return string
local function _GetResultText(node)
    if node.kind == "quest" then
        return QuestieLib:GetColoredQuestName(node.value, true, false)
    end
    local text = QuestieSearch.GetName(node.kind, node.value) or ""
    if Questie.db.profile.enableTooltipsQuestID then
        text = text .. " (" .. node.value .. ")"
    end
    return text
end

---@param node JourneyTreeNode
---@return JourneyIcon.Icon?
local function _GetResultIcon(node)
    if node.kind == "quest" then
        return JourneyQuestCategories.GetIcon(node.value, (JourneyQuestCategories.Get(node.value)))
    end
end

---@param node JourneyTreeNode
---@return string? note Where it is
local function _GetResultNote(node)
    local zoneId
    if node.kind == "quest" then
        zoneId = QuestieDB.QueryQuestSingle(node.value, "zoneOrSort")
    elseif node.kind == "npc" then
        zoneId = QuestieDB.QueryNPCSingle(node.value, "zoneID")
    elseif node.kind == "object" then
        zoneId = QuestieDB.QueryObjectSingle(node.value, "zoneID")
    end
    if zoneId and zoneId > 0 then
        local isKnown, name = pcall(QuestieJourneyUtils.GetZoneName, QuestieJourneyUtils, zoneId)
        return isKnown and name or nil
    end
end

-------------------------
-- Tab
-------------------------

---@param canvas Frame
local function _CreateBar(canvas)
    bar = CreateFrame("StatusBar", nil, canvas)
    bar:SetPoint("LEFT", picker, "RIGHT", 18, 0)
    bar:SetPoint("RIGHT", canvas, "TOPRIGHT", -14, -10 - picker:GetHeight() / 2)
    bar:SetHeight(BAR_HEIGHT)
    bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    bar:SetStatusBarColor(0.20, 0.45, 0.13)
    bar:SetMinMaxValues(0, 1)

    bar.Background = bar:CreateTexture(nil, "BACKGROUND")
    bar.Background:SetAllPoints(bar)
    bar.Background:SetColorTexture(0, 0, 0, 0.45)

    bar.Edges = {}
    for _, edge in ipairs({{"TOPLEFT", "TOPRIGHT", 0, 1}, {"BOTTOMLEFT", "BOTTOMRIGHT", 0, 1}, {"TOPLEFT", "BOTTOMLEFT", 1, 0}, {"TOPRIGHT", "BOTTOMRIGHT", 1, 0}}) do
        local texture = bar:CreateTexture(nil, "OVERLAY")
        texture:SetColorTexture(0.45, 0.36, 0.22, 0.9)
        texture:SetPoint(edge[1], bar, edge[1])
        texture:SetPoint(edge[2], bar, edge[2])
        if edge[3] == 1 then texture:SetWidth(1) else texture:SetHeight(1) end
        table.insert(bar.Edges, texture)
    end

    bar.Text = bar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    bar.Text:SetPoint("CENTER")
end

---@param canvas Frame
function _QuestieJourney.quests.Build(canvas)
    picker = JourneyPicker.Create(canvas, PICKER_WIDTH, _GetChoices, _Choose)
    picker:SetPoint("TOPLEFT", canvas, "TOPLEFT", 14, -10)
    _CreateBar(canvas)

    local panes = JourneyPanes.Create(canvas, "", TOOLBAR_HEIGHT)
    tree = JourneyTree.Create(panes.list.contentArea, function(node)
        if searchBox then searchBox:ClearFocus() end
        if node.kind == "zone" then
            _Choose("zone:" .. node.value)
            return
        end
        local kind = node.kind or "quest"
        if kind == "quest" then
            JourneyLinks.TryInsertIntoChat(node.value)
        end
        selection, pastSelections = {kind = kind, id = node.value}, {}
        _ShowDetails()
    end, _GetResultIcon, _GetResultText, _GetResultNote)
    details = JourneyDetails.Create(panes.details.contentArea)

    emptyText = panes.list.contentArea:CreateFontString(nil, "ARTWORK", "GameFontDisable")
    emptyText:SetPoint("TOP", panes.list.contentArea, "TOP", 0, -12)
    emptyText:SetPoint("LEFT", panes.list.contentArea, "LEFT", 12, 0)
    emptyText:SetPoint("RIGHT", panes.list.contentArea, "RIGHT", -12, 0)
    emptyText:Hide()
end

local shownZone

function _QuestieJourney.quests.OnSelected()
    -- Only here, so the list doesn't change while the player is using it
    shownZone = shownZone or _GetPlayerZone()
    if source == HERE and shownZone ~= _GetPlayerZone() then
        shownZone = _GetPlayerZone()
        selection, pastSelections, listedSource = nil, {}, nil
    end
end

function _QuestieJourney.quests.Refresh()
    _Load()
end

---Shows something. What was shown before can be gone back to.
---@param kind JourneyKind
---@param id number
function _QuestieJourney.quests.Open(kind, id)
    if selection and not (selection.kind == kind and selection.id == id) then
        table.insert(pastSelections, selection)
    end
    _Open(kind, id)
end

function _QuestieJourney.quests.ShowWatchedFaction()
    QuestieCompat.ExpandFactionHeader(0)
    for i = 1, QuestieCompat.GetNumFactions() do
        local _, _, _, _, _, _, _, _, isHeader, _, _, isWatched, _, id = QuestieCompat.GetFactionInfo(i)
        if isWatched and not isHeader and QuestieJourney.factionMap[id] then
            _Choose("faction:" .. id)
            return
        end
    end
end

function _QuestieJourney.quests.ShowCurrentZone()
    if source ~= HERE then
        _Choose(HERE)
    end
end

---For trying things out
function _QuestieJourney.quests.Choose(newSource)
    _Choose(newSource)
end
