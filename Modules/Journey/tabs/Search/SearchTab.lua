---@type QuestieJourney
local QuestieJourney = QuestieLoader:ImportModule("QuestieJourney")
local _QuestieJourney = QuestieJourney.private
_QuestieJourney.search = {}
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
---@type JourneyQuestDetails
local JourneyQuestDetails = QuestieLoader:ImportModule("JourneyQuestDetails")
---@type JourneyQuestList
local JourneyQuestList = QuestieLoader:ImportModule("JourneyQuestList")
---@type JourneyResultList
local JourneyResultList = QuestieLoader:ImportModule("JourneyResultList")
---@type JourneyThread
local JourneyThread = QuestieLoader:ImportModule("JourneyThread")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestieSearch
local QuestieSearch = QuestieLoader:ImportModule("QuestieSearch")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")
---@type utf8
local utf8 = QuestieLoader:ImportModule("utf8")

---@type table<JourneyKind, string>
local KIND_TITLES = {quest = "Quests", npc = "NPCs", object = "Objects", item = "Items"}

local SEARCH_DELAY_SECONDS = 0.15
-- Shorter text matches too much to search for it while it is still being typed. Enter searches for it anyway.
local MIN_SEARCH_LENGTH = 3
-- Languages where two characters are a word already
local MIN_SEARCH_LENGTHS = {koKR = 2, zhCN = 2, zhTW = 2}

local SEARCH_BOX_WIDTH = 320
local TAB_PADDING = 30

---@type EditBox
local searchBox
---@type table<JourneyKind, Button>
local tabs = {}
---@type JourneyResultList.Instance
local resultList
---@type JourneyDetails.Instance
local details

---Runs after the user stopped typing
---@type Ticker?
local searchTimer
---@type Ticker?
local searchThread

---What the results are for. Empty when nothing is searched for.
local query = ""
---The same, or what is being searched for right now
local runningQuery = ""
---@type table<JourneyKind, number[]>
local results = {quest = {}, npc = {}, object = {}, item = {}}
---@type JourneyKind
local shownKind = "quest"

---What the details show. It doesn't have to be one of the results, because links lead here.
---@type {kind: JourneyKind, id: number}?
local selection

---@param keepsScrollPosition boolean
local function _ShowDetails(keepsScrollPosition)
    local rows = {}
    if selection and selection.kind == "quest" then
        local quest = QuestieDB.GetQuest(selection.id)
        rows = quest and JourneyQuestDetails.GetRows(quest) or {}
    elseif selection then
        rows = JourneyEntityDetails.GetRows(selection.kind, selection.id, function() _ShowDetails(true) end)
    elseif query ~= "" and #results.quest + #results.npc + #results.object + #results.item == 0 then
        rows = {{type = "text", text = Questie:Colorize(l10n("No Match for Search Results: %s", query), "yellow")}}
    end
    JourneyDetails.SetRows(details, rows, keepsScrollPosition)
end

local function _ShowResults()
    for kind, tab in pairs(tabs) do
        local count = #results[kind]
        tab.Text:SetText(l10n(KIND_TITLES[kind]) .. " (" .. count .. ")")
        tab:SetWidth(tab.Text:GetStringWidth() + TAB_PADDING)
        tab:SetEnabled(count > 0)
        tab:SetSelected(kind == shownKind)
        if count == 0 then
            tab.Text:SetFontObject("GameFontDisableSmall")
        else
            tab.Text:SetFontObject(kind == shownKind and "GameFontHighlightSmall" or "GameFontNormalSmall")
        end
    end

    local selectedId = selection and selection.kind == shownKind and selection.id or nil
    JourneyResultList.Show(resultList, results[shownKind], selectedId)
end

---@param kind JourneyKind
---@param id number
---@return boolean
local function _IsResult(kind, id)
    for _, resultId in ipairs(results[kind]) do
        if resultId == id then
            return true
        end
    end
    return false
end

---@param newQuery string
---@param newResults table<JourneyKind, number[]>
---@param selectionBefore table? What was open when this was searched for. It is closed if it wasn't found.
local function _SetResults(newQuery, newResults, selectionBefore)
    query, runningQuery, results = newQuery, newQuery, newResults

    if selection and selection == selectionBefore and not _IsResult(selection.kind, selection.id) then
        selection = nil
    end
    if #results[shownKind] == 0 then
        for _, kind in ipairs(QuestieSearch.KINDS) do
            if #results[kind] > 0 then
                shownKind = kind
                break
            end
        end
    end
    _ShowResults()
    _ShowDetails(true)
end

local function _CancelSearch()
    if searchTimer then
        searchTimer:Cancel()
    end
    if searchThread then
        searchThread:Cancel()
    end
    runningQuery = query
end

---Shows the results once all are found. Until then the ones before stay.
---@param newQuery string
local function _Search(newQuery)
    _CancelSearch()
    runningQuery = newQuery
    local selectionBefore = selection
    searchThread = JourneyThread.Start("QuestieSearch", function()
        local newResults = {}
        for _, kind in ipairs(QuestieSearch.KINDS) do
            newResults[kind] = QuestieSearch.Search(kind, newQuery)
        end
        _SetResults(newQuery, newResults, selectionBefore)
    end)
end

---@return string
local function _GetTypedQuery()
    return strtrim(searchBox:GetText(), " \n\r\t[]")
end

local function _OnTextChanged()
    -- A link is searched for by what it says. Setting the text runs this again.
    local linkText = searchBox:GetText():match("|h%[(.-)%]|h")
    if linkText then
        searchBox:SetText(linkText)
        return
    end

    if searchTimer then
        searchTimer:Cancel()
    end
    local typedQuery = _GetTypedQuery()
    if typedQuery ~= runningQuery then
        _CancelSearch()
    end
    if typedQuery == runningQuery then
        return -- It is searched for already, or was
    end
    local minLength = MIN_SEARCH_LENGTHS[l10n:GetUILocale()] or MIN_SEARCH_LENGTH
    if utf8.strlen(typedQuery) >= minLength then
        searchTimer = C_Timer.NewTimer(SEARCH_DELAY_SECONDS, function() _Search(typedQuery) end)
    elseif typedQuery == "" then
        _SetResults("", {quest = {}, npc = {}, object = {}, item = {}}, selection)
    end
end

local function _OnEnterPressed()
    searchBox:ClearFocus()
    local typedQuery = _GetTypedQuery()
    if typedQuery ~= "" then
        _Search(typedQuery)
    end
end

---An item that is dropped on the search box is searched for.
local function _OnReceiveDrag()
    local cursorType, _, itemLink = GetCursorInfo()
    if cursorType == "item" then
        ClearCursor()
        searchBox:SetText(itemLink)
    end
end

---@param id number
---@return string
local function _GetResultText(id)
    local text = QuestieSearch.GetName(shownKind, id) or ""
    if Questie.db.profile.enableTooltipsQuestID then
        text = text .. " (" .. id .. ")"
    end
    return text
end

---@param id number
---@return JourneyIcon.Icon? icon
local function _GetResultIcon(id)
    return shownKind == "quest" and JourneyQuestList.GetIcon(id) or nil
end

---@param canvas Frame
local function _CreateSearchBox(canvas)
    searchBox = CreateFrame("EditBox", nil, canvas, "SearchBoxTemplate")
    searchBox:SetSize(SEARCH_BOX_WIDTH, 22)
    searchBox:SetPoint("TOPLEFT", canvas, "TOPLEFT", 20, -10)
    local kinds = {}
    for _, kind in ipairs(QuestieSearch.KINDS) do
        table.insert(kinds, l10n(KIND_TITLES[kind]))
    end
    searchBox.Instructions:SetText(table.concat(kinds, ", "))

    -- Hooked, because the template shows and hides its placeholder and clear button from this
    searchBox:HookScript("OnTextChanged", _OnTextChanged)
    searchBox:SetScript("OnEnterPressed", _OnEnterPressed)
    searchBox:SetScript("OnReceiveDrag", _OnReceiveDrag)
    searchBox:HookScript("OnMouseDown", _OnReceiveDrag)
    JourneyLinkInput.Enable(searchBox)
end

---@param canvas Frame
function _QuestieJourney.search.Build(canvas)
    _CreateSearchBox(canvas)

    local panes = JourneyPanes.Create(canvas, "", 56)
    resultList = JourneyResultList.Create(panes.list.contentArea, _GetResultText, _GetResultIcon, function(id)
        searchBox:ClearFocus()
        selection = {kind = shownKind, id = id}
        if shownKind == "quest" then
            JourneyLinks.TryInsertIntoChat(id)
        end
        _ShowDetails(false)
    end)
    details = JourneyDetails.Create(panes.details.contentArea)

    local previousTab
    for _, kind in ipairs(QuestieSearch.KINDS) do
        local tab = CreateFrame("Button", nil, canvas, "MinimalTabTemplate")
        if previousTab then
            tab:SetPoint("BOTTOMLEFT", previousTab, "BOTTOMRIGHT", 0, 0)
        else
            tab:SetPoint("BOTTOMLEFT", panes.list, "TOPLEFT", 8, 2)
        end
        -- The template's own script would also deselect the tab
        tab:SetScript("OnClick", function()
            PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
            searchBox:ClearFocus()
            shownKind = kind
            _ShowResults()
        end)
        tabs[kind] = tab
        previousTab = tab
    end
end

function _QuestieJourney.search.Refresh()
    _ShowResults()
    _ShowDetails(true)
end

function _QuestieJourney.search.OnSelected()
    searchBox:SetFocus()
end

---Ends typing.
function _QuestieJourney.search.ClearFocus()
    if searchBox then
        searchBox:ClearFocus()
    end
end

---Shows something in the details. The results stay as they are.
---@param kind JourneyKind
---@param id number
function _QuestieJourney.search.Open(kind, id)
    searchBox:ClearFocus()
    selection = {kind = kind, id = id}
    if _IsResult(kind, id) then
        shownKind = kind
    end
    _ShowResults()
    JourneyResultList.ScrollToSelected(resultList)
    _ShowDetails(false)
end
