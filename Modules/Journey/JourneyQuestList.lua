---A list of quests in categories, with the details of the selected one next to it. Quests by Zone and Quests by Faction
---consist of it.
---@class JourneyQuestList
local JourneyQuestList = QuestieLoader:CreateModule("JourneyQuestList")

---@type ActiveQuests
local ActiveQuests = QuestieLoader:ImportModule("ActiveQuests")
---@type JourneyDetails
local JourneyDetails = QuestieLoader:ImportModule("JourneyDetails")
---@type JourneyIcon
local JourneyIcon = QuestieLoader:ImportModule("JourneyIcon")
---@type JourneyLinks
local JourneyLinks = QuestieLoader:ImportModule("JourneyLinks")
---@type JourneyPanes
local JourneyPanes = QuestieLoader:ImportModule("JourneyPanes")
---@type JourneyThread
local JourneyThread = QuestieLoader:ImportModule("JourneyThread")
---@type JourneyTree
local JourneyTree = QuestieLoader:ImportModule("JourneyTree")
---@type JourneyQuestDetails
local JourneyQuestDetails = QuestieLoader:ImportModule("JourneyQuestDetails")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

-- Most of the quests in this category are also in another one
local BREADCRUMB_CATEGORY = "b"

---@class JourneyQuestList.Instance
---@field tree JourneyTree.Instance
---@field details JourneyDetails.Instance
---@field emptyText FontString
---@field source string? Where the listed quests come from
---@field questId QuestId? The selected quest, which doesn't have to be in the list
---@field loadTimer Ticker?

---@param list JourneyQuestList.Instance
---@param keepsScrollPosition boolean?
local function _ShowDetails(list, keepsScrollPosition)
    local quest = list.questId and QuestieDB.GetQuest(list.questId)
    JourneyDetails.SetRows(list.details, quest and JourneyQuestDetails.GetRows(quest) or {}, keepsScrollPosition)
end

---@param list JourneyQuestList.Instance
---@param questId QuestId
---@return string? path Where the quest is in the list. Nil if it isn't.
local function _FindPath(list, questId)
    local path = JourneyTree.FindPath(list.tree, function(node, category)
        return node.value == questId and category.value ~= BREADCRUMB_CATEGORY
    end)
    return path or JourneyTree.FindPath(list.tree, function(node) return node.value == questId end)
end

---The icon in front of a quest in a list.
---@param questId QuestId
---@return JourneyIcon.Icon? icon Nil for a quest the user didn't hide, that is neither in the quest log nor completed
function JourneyQuestList.GetIcon(questId)
    if Questie.db.char.hidden[questId] then
        return JourneyIcon.HIDDEN
    elseif ActiveQuests.Get(questId) then
        return Questie.icons[QuestieDB.IsComplete(questId) == 1 and "complete" or "incomplete"]
    elseif Questie.db.char.complete[questId] then
        return Questie.icons["checkmark"]
    end
end

---@param canvas Frame
---@param topInset number Space above the list
---@return JourneyQuestList.Instance
function JourneyQuestList.Create(canvas, topInset)
    ---@type JourneyQuestList.Instance
    local list = {}
    local panes = JourneyPanes.Create(canvas, l10n("Quests"), topInset)
    list.tree = JourneyTree.Create(panes.list.contentArea, function(node)
        JourneyLinks.TryInsertIntoChat(node.value)
        list.questId = node.value
        _ShowDetails(list)
    end, function(node)
        return JourneyQuestList.GetIcon(node.value)
    end)
    list.details = JourneyDetails.Create(panes.details.contentArea)

    list.emptyText = panes.list.contentArea:CreateFontString(nil, "ARTWORK", "GameFontDisable")
    list.emptyText:SetPoint("TOP", panes.list.contentArea, "TOP", 0, -12)
    list.emptyText:SetText(l10n("No Quests found"))
    list.emptyText:Hide()

    return list
end

---@param list JourneyQuestList.Instance
---@param questId QuestId
---@return boolean
function JourneyQuestList.Contains(list, questId)
    return _FindPath(list, questId) ~= nil
end

---Shows a quest. It is highlighted in the list if it is there.
---@param list JourneyQuestList.Instance
---@param questId QuestId
function JourneyQuestList.Select(list, questId)
    list.questId = questId
    JourneyTree.Select(list.tree, _FindPath(list, questId))
    _ShowDetails(list)
end

---Lists quests. The selected one stays selected when they come from the same source as before, because then they are the
---same quests, after something about them can have changed.
---@param list JourneyQuestList.Instance
---@param source string What identifies a zone or faction
---@param collect fun(): JourneyTreeNode[]? Runs in a thread, so it can yield. Nil when there is nothing to look for quests in.
function JourneyQuestList.Load(list, source, collect)
    if list.source ~= source then
        list.source = source
        list.questId = nil
        JourneyTree.Select(list.tree, nil)
        JourneyTree.SetNodes(list.tree, {})
        list.emptyText:Hide()
        _ShowDetails(list)
    end

    if list.loadTimer then
        list.loadTimer:Cancel()
    end
    list.loadTimer = JourneyThread.Start("JourneyQuestList", function()
        local nodes = collect()
        JourneyTree.SetNodes(list.tree, nodes or {})
        list.emptyText:SetShown(nodes ~= nil and JourneyTree.IsEmpty(list.tree))
        -- A row the user clicked stays selected as long as it is there
        if list.questId and not JourneyTree.IsSelectionListed(list.tree) then
            local path = _FindPath(list, list.questId)
            if list.tree.selectedPath then
                JourneyTree.MoveSelection(list.tree, path) -- To another category, e.g. because the quest was completed
            else
                JourneyTree.Select(list.tree, path) -- It was selected before it was listed
            end
        end
        _ShowDetails(list, true)
    end)
end

return JourneyQuestList
