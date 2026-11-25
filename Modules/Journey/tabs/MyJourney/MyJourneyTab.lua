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
---@type JourneyPicker
local JourneyPicker = QuestieLoader:ImportModule("JourneyPicker")
---@type JourneyQuestDetails
local JourneyQuestDetails = QuestieLoader:ImportModule("JourneyQuestDetails")
---@type JourneyTree
local JourneyTree = QuestieLoader:ImportModule("JourneyTree")
---@type JourneyWindow
local JourneyWindow = QuestieLoader:ImportModule("JourneyWindow")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
---@type QuestieOptionsControls
local QuestieOptionsControls = QuestieLoader:ImportModule("QuestieOptionsControls")
---@type QuestiePlayer
local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local PICKER_WIDTH = 180
local TOOLBAR_HEIGHT = 46
local NOTE_BUTTON_WIDTH = 220

local NOTE_ICON = "Interface\\Buttons\\UI-GuildButton-PublicNote-Up"

-- What is listed
local EVERYTHING, QUESTS, LEVELS, NOTES = "everything", "quests", "levels", "notes"
local FILTERS = {
    {value = EVERYTHING, text = "Everything"},
    {value = QUESTS, text = "Quests"},
    {value = LEVELS, text = "Level ups"},
    {value = NOTES, text = "Notes"},
}
local FILTER_BY_EVENT = {Quest = QUESTS, Level = LEVELS, Note = NOTES}

local filter = EVERYTHING
---@type Frame
local picker
---@type FontString
local summary
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
local listedFilter

-------------------------
-- Details
-------------------------

---@param entry JourneyEntry
---@return JourneyDetails.Row[]
local function _GetLevelRows(entry)
    local previous, quests = nil, {}
    for _, other in ipairs(Questie.db.char.journey) do
        if other == entry then
            break
        elseif other.Event == "Level" then
            previous, quests = other, {}
        elseif other.SubType == "Complete" then
            table.insert(quests, other)
        end
    end

    local rows = {
        {type = "page", text = l10n("Level %s", entry.NewLevel)},
        {type = "gap", height = 6},
        {type = "text", text = QuestieLib.FormatDate(entry.Timestamp)},
    }
    if previous then
        local hours = (entry.Timestamp - previous.Timestamp) / 3600
        local text = hours >= 48 and l10n("%s days after level %s", math.floor(hours / 24), previous.NewLevel)
            or l10n("%s hours after level %s", math.floor(hours * 10 + 0.5) / 10, previous.NewLevel)
        table.insert(rows, {type = "text", text = Questie:Colorize(text, "gray")})
    end
    if #quests > 0 then
        table.insert(rows, {type = "caption", text = l10n("Quests completed on the way") .. Questie:Colorize("   " .. #quests, "gray")})
        for index = #quests, 1, -1 do
            local questId = quests[index].Quest
            table.insert(rows, {
                type = "step",
                text = QuestieDB.QuestPointers[questId] and QuestieLib:GetColoredQuestName(questId, true, false) or tostring(questId),
                tag = date("%H:%M", quests[index].Timestamp),
                trailingIcon = Questie.icons["checkmark"],
                onClick = function() JourneyWindow.OpenLink("quest", questId) end,
            })
        end
    end
    return rows
end

---@param keepsScrollPosition boolean?
local function _ShowDetails(keepsScrollPosition)
    local rows = {}
    if selectedEntry and selectedEntry.Event == "Level" then
        rows = _GetLevelRows(selectedEntry)
    elseif selectedEntry and selectedEntry.Event == "Quest" and QuestieDB.QuestPointers[selectedEntry.Quest] then
        rows = JourneyQuestDetails.GetRows(QuestieDB.GetQuest(selectedEntry.Quest), function() _ShowDetails(true) end)
    elseif selectedEntry then
        rows = _QuestieJourney.myJourney.GetEntryRows(selectedEntry)
    end
    JourneyDetails.SetRows(details, rows, keepsScrollPosition)
end

-------------------------
-- List
-------------------------

local QUEST_ICONS = {Accept = "available", Complete = "checkmark", Abandon = "cross"}

---@param entry JourneyEntry
---@param index number
---@return JourneyTreeNode
local function _GetNode(entry, index)
    local node = {value = index, note = date("%H:%M", entry.Timestamp)}
    if entry.Event == "Level" then
        node.text = Questie:Colorize(l10n("Level %s", entry.NewLevel), "gold")
        node.icon = Questie.icons["fav"]
    elseif entry.Event == "Note" then
        node.text = Questie:Colorize(entry.Title, "lightBlue")
        node.icon = NOTE_ICON
    else
        node.icon = Questie.icons[QUEST_ICONS[entry.SubType]]
        node.quest = entry.Quest
    end
    return node
end

---@return JourneyTreeNode[] nodes Months with their days, newest first
local function _GetNodes()
    local journey = Questie.db.char.journey
    local months, month, day = {}, nil, nil
    for index = #journey, 1, -1 do
        local entry = journey[index]
        if filter == EVERYTHING or FILTER_BY_EVENT[entry.Event] == filter then
            local monthKey, dayKey = date("%Y-%m", entry.Timestamp), date("%d", entry.Timestamp)
            if not month or month.value ~= monthKey then
                local name = CALENDAR_FULLDATE_MONTH_NAMES[tonumber(date("%m", entry.Timestamp))] or ""
                month = {value = monthKey, text = name .. " " .. date("%Y", entry.Timestamp), children = {}}
                day = nil
                table.insert(months, month)
            end
            if not day or day.value ~= dayKey then
                local weekday = CALENDAR_WEEKDAY_NAMES[tonumber(date("%w", entry.Timestamp)) + 1] or ""
                day = {value = dayKey, text = weekday .. ", " .. month.text:gsub(" %d+$", "") .. " " .. tonumber(dayKey), children = {}}
                table.insert(month.children, day)
            end
            table.insert(day.children, _GetNode(entry, index))
        end
    end
    for _, monthNode in ipairs(months) do
        local count = 0
        for _, dayNode in ipairs(monthNode.children) do
            dayNode.note = tostring(#dayNode.children)
            count = count + #dayNode.children
        end
        monthNode.note = tostring(count)
    end
    return months
end

local function _List()
    local journey = Questie.db.char.journey
    local nodes = _GetNodes()
    local isNew = listedJourney ~= journey or listedFilter ~= filter
    listedJourney, listedCount, listedFilter = journey, #journey, filter
    if isNew and nodes[1] then
        JourneyTree.Expand(tree, nodes[1].value, nodes[1].children[1].value)
        if nodes[1].children[2] then
            JourneyTree.Expand(tree, nodes[1].value, nodes[1].children[2].value)
        end
        if filter == LEVELS or filter == NOTES then
            for _, month in ipairs(nodes) do
                for _, day in ipairs(month.children) do JourneyTree.Expand(tree, month.value, day.value) end
            end
        end
    end
    JourneyTree.SetNodes(tree, nodes)

    local completed = 0
    for _, entry in ipairs(journey) do
        if entry.SubType == "Complete" then completed = completed + 1 end
    end
    summary:SetText(journey[1] and l10n("%s quests completed, level %s, since %s", completed, QuestiePlayer.GetPlayerLevel(),
        (QuestieLib.FormatDate(journey[1].Timestamp):gsub(" at .*$", ""))) or l10n("It's about time you embark on your first Journey!"))

    local selectedIndex
    for index, entry in ipairs(journey) do
        if entry == selectedEntry then selectedIndex = index end
    end
    if not selectedIndex then
        selectedEntry = nil
        local first = nodes[1] and nodes[1].children[1].children[1]
        selectedEntry = first and journey[first.value]
        selectedIndex = first and first.value
    end
    JourneyTree.MoveSelection(tree, selectedIndex and JourneyTree.FindPath(tree, function(node) return node.value == selectedIndex end))
end

-------------------------
-- Tab
-------------------------

---@param canvas Frame
function _QuestieJourney.myJourney.Build(canvas)
    local texts, choices = {}, {}
    for index, choice in ipairs(FILTERS) do
        texts[choice.value] = l10n(choice.text)
        choices[index] = {text = l10n(choice.text), value = choice.value}
    end
    picker = JourneyPicker.Create(canvas, PICKER_WIDTH, function() return choices end, function(value)
        filter = value
        JourneyPicker.SetText(picker, texts[value])
        _QuestieJourney.myJourney.Refresh()
    end)
    picker:SetPoint("TOPLEFT", canvas, "TOPLEFT", 14, -10)
    JourneyPicker.SetText(picker, texts[filter])

    local noteButton = QuestieOptionsControls.Create(canvas, {
        type = "button",
        title = "",
        btnLabel = l10n("Add New Adventure Note"),
        align = "RIGHT",
        func = _QuestieJourney.ToggleNoteWindow,
    }, NOTE_BUTTON_WIDTH, 1)
    noteButton:SetPoint("TOPRIGHT", canvas, "TOPRIGHT", -4, -3)

    summary = canvas:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    summary:SetPoint("LEFT", picker, "RIGHT", 18, 0)
    summary:SetPoint("RIGHT", noteButton, "LEFT", -10, 0)
    summary:SetJustifyH("LEFT")
    summary:SetWordWrap(false)

    local panes = JourneyPanes.Create(canvas, "", TOOLBAR_HEIGHT)
    tree = JourneyTree.Create(panes.list.contentArea, function(node)
        selectedEntry = Questie.db.char.journey[node.value]
        _ShowDetails()
    end, nil, function(node)
        return QuestieDB.QuestPointers[node.quest] and QuestieLib:GetColoredQuestName(node.quest, true, false) or tostring(node.quest)
    end)
    details = JourneyDetails.Create(panes.details.contentArea)
end

function _QuestieJourney.myJourney.Refresh()
    local journey = Questie.db.char.journey
    if journey ~= listedJourney or #journey ~= listedCount or filter ~= listedFilter then
        _List()
    end
    _ShowDetails(true)
end
