---@type QuestieJourney
local QuestieJourney = QuestieLoader:ImportModule("QuestieJourney")
local _QuestieJourney = QuestieJourney.private
-------------------------
--Import modules.
-------------------------
---@type JourneyDetails
local JourneyDetails = QuestieLoader:ImportModule("JourneyDetails")
---@type JourneyPanes
local JourneyPanes = QuestieLoader:ImportModule("JourneyPanes")
---@type JourneyTree
local JourneyTree = QuestieLoader:ImportModule("JourneyTree")
---@type QuestieOptionsControls
local QuestieOptionsControls = QuestieLoader:ImportModule("QuestieOptionsControls")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local RECENT_COUNT = 5
local RECENT_LINE_HEIGHT = 16
local RECENT_TOP = 24
local RECENT_HEIGHT = RECENT_COUNT * RECENT_LINE_HEIGHT + 16
local NOTE_BUTTON_WIDTH = 240

---@type FontString[]
local recentLines = {}
---@type JourneyTree.Instance
local tree
---@type JourneyDetails.Instance
local details

---The selected entry itself, because the index of an entry changes when one before it is deleted.
---@type JourneyEntry?
local selectedEntry

---What is listed. The journey is another one after an import, and otherwise entries are only added and deleted.
---@type JourneyEntry[]?
local listedJourney
---@type number?
local listedCount

---The journey whose newest month was expanded.
---@type JourneyEntry[]?
local expandedJourney

---@param keepsScrollPosition boolean?
local function _ShowDetails(keepsScrollPosition)
    local rows = selectedEntry and _QuestieJourney.myJourney.GetEntryRows(selectedEntry) or {}
    JourneyDetails.SetRows(details, rows, keepsScrollPosition)
end

---@param canvas Frame
local function _CreateRecentHistory(canvas)
    local box = QuestieOptionsControls.Create(canvas, {type = "container", title = l10n("Your Recent History")}, 200, 3)
    box:EnableMouse(false)
    box:SetPoint("TOPLEFT", canvas, "TOPLEFT", 12, -RECENT_TOP)
    box:SetPoint("TOPRIGHT", canvas, "TOPRIGHT", -12, -RECENT_TOP)
    box:SetHeight(RECENT_HEIGHT)

    for index = 1, RECENT_COUNT do
        local line = box.contentArea:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
        local y = -8 - (index - 1) * RECENT_LINE_HEIGHT
        line:SetPoint("TOPLEFT", box.contentArea, "TOPLEFT", 14, y)
        line:SetPoint("TOPRIGHT", box.contentArea, "TOPRIGHT", -14, y)
        line:SetJustifyH("LEFT")
        line:SetWordWrap(false)
        recentLines[index] = line
    end
end

local function _UpdateRecentHistory()
    local journey = Questie.db.char.journey
    for index, line in ipairs(recentLines) do
        local entry = journey[#journey + 1 - index] -- Newest first
        line:SetText(entry and _QuestieJourney.myJourney.GetRecentText(entry) or "")
    end
    if #journey == 0 then
        recentLines[1]:SetText(Questie:Colorize(l10n("It's about time you embark on your first Journey!"), "yellow"))
    end
end

---@param entry JourneyEntry?
---@return number?
local function _GetIndex(entry)
    for index, candidate in ipairs(Questie.db.char.journey) do
        if candidate == entry then
            return index
        end
    end
end

local function _ListHistory()
    local journey = Questie.db.char.journey
    local history = _QuestieJourney:GetHistory()
    local newestYear = history[1]
    if newestYear and expandedJourney ~= journey then
        expandedJourney = journey
        JourneyTree.Expand(tree, newestYear.value, newestYear.children[1].value)
    end
    JourneyTree.SetNodes(tree, history)
    listedJourney, listedCount = journey, #journey

    local selectedIndex = _GetIndex(selectedEntry)
    if not selectedIndex then
        selectedEntry = nil
    end
    local path = selectedIndex and JourneyTree.FindPath(tree, function(node) return node.value == selectedIndex end)
    JourneyTree.MoveSelection(tree, path)
end

---@param canvas Frame
function _QuestieJourney.myJourney.Build(canvas)
    local noteButton = QuestieOptionsControls.Create(canvas, {
        type = "button",
        title = "",
        btnLabel = l10n("Add New Adventure Note"),
        align = "RIGHT",
        func = _QuestieJourney.ToggleNoteWindow,
    }, NOTE_BUTTON_WIDTH, 1)
    noteButton:SetPoint("BOTTOMRIGHT", canvas, "TOPRIGHT", -10, -3) -- In the header

    _CreateRecentHistory(canvas)

    local panes = JourneyPanes.Create(canvas, l10n("%s's Journey", GetUnitName("player", true)), RECENT_TOP + RECENT_HEIGHT + 12)
    tree = JourneyTree.Create(panes.list.contentArea, function(node)
        selectedEntry = Questie.db.char.journey[node.value]
        _ShowDetails()
    end)
    details = JourneyDetails.Create(panes.details.contentArea)
end

function _QuestieJourney.myJourney.Refresh()
    local journey = Questie.db.char.journey
    if journey ~= listedJourney or #journey ~= listedCount then
        _UpdateRecentHistory()
        _ListHistory()
    end
    _ShowDetails(true)
end
