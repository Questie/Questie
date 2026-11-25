---Sorts quests by what the player can do with them, and says why.
---@class JourneyQuestCategories
local JourneyQuestCategories = QuestieLoader:CreateModule("JourneyQuestCategories")

---@type ActiveQuests
local ActiveQuests = QuestieLoader:ImportModule("ActiveQuests")
---@type JourneyIcon
local JourneyIcon = QuestieLoader:ImportModule("JourneyIcon")
---@type JourneyPrerequisites
local JourneyPrerequisites = QuestieLoader:ImportModule("JourneyPrerequisites")
---@type JourneyThread
local JourneyThread = QuestieLoader:ImportModule("JourneyThread")
---@type QuestieCorrections
local QuestieCorrections = QuestieLoader:ImportModule("QuestieCorrections")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestieEvent
local QuestieEvent = QuestieLoader:ImportModule("QuestieEvent")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
---@type QuestieQuestBlacklist
local QuestieQuestBlacklist = QuestieLoader:ImportModule("QuestieQuestBlacklist")
---@type QuestXP
local QuestXP = QuestieLoader:ImportModule("QuestXP")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

---@alias JourneyQuestCategory "log"|"available"|"repeatable"|"later"|"completed"|"unobtainable"|"hidden"

---In display order
---@type {key: JourneyQuestCategory, title: string}[]
local CATEGORIES = {
    {key = "log", title = QUEST_LOG},
    {key = "available", title = "Available Quests"},
    {key = "repeatable", title = "Repeatable Quests"},
    {key = "later", title = "Missing Requirement"},
    {key = "completed", title = "Completed Quests"},
    {key = "unobtainable", title = "Unobtainable Quests"},
    {key = "hidden", title = "Hidden Quests"},
}

---The category for each reason why a quest can be done, or can't. Others aren't listed at all.
---@type table<string, JourneyQuestCategory>
local CATEGORY_BY_STATE = {
    AVAILABLE = "available", PARENT_ACTIVE = "available", QUEST_LOG = "log", COMPLETED = "completed",
    NO_PREQUESTSINGLE = "later", NO_PREQUESTGROUP = "later", PARENT_INACTIVE = "later", ENABLING_QUEST_MISSING = "later",
    BREADCRUMB_ACTIVE = "later", MISSING_REPUTATION = "later", EXCEED_REPUTATION = "later", PROFESSION_SKILL = "later",
    PROFESSION_RANK = "later", SPELL_MISSING = "later", MISSING_ACHIEVEMENT = "later", LEVEL_TOO_LOW = "later", ARENA_RATING = "later",
    EXCLUSIVE_COMPLETED = "unobtainable", EXCLUSIVE_IN_QUEST_LOG = "unobtainable", NEXTQUESTINCHAIN_ACTIVE_OR_COMPLETED = "unobtainable",
    BREADCRUMB_FOLLOWUP = "unobtainable", DISABLING_QUEST_COMPLETED = "unobtainable", DISABLED_BY = "unobtainable",
    MISSING_DAILY = "unobtainable", INACTIVE_DAILY = "unobtainable", EVENT_INACTIVE = "unobtainable",
    PROFESSION_SPECIALIZATION = "unobtainable", PROFESSION_MISSING = "unobtainable", SPELL_KNOWN = "unobtainable",
    LEVEL_TOO_HIGH = "unobtainable",
}

---@type table<number, string>
local stateNames

---@param state number?
---@return string?
local function _GetStateName(state)
    if not stateNames then
        stateNames = {}
        for name, value in pairs(QuestieDB.DoableStates) do
            stateNames[value] = name
        end
    end
    return state and stateNames[state]
end

---@param questId QuestId
---@return boolean
local function _IsChildAvailable(questId)
    if Questie.db.char.complete[questId] or QuestieCorrections.hiddenQuests[questId] then
        return false
    end
    local preQuestSingle = QuestieDB.QueryQuestSingle(questId, "preQuestSingle")
    if preQuestSingle then
        return QuestieDB:IsPreQuestSingleFulfilled(preQuestSingle)
    end
    local preQuestGroup = QuestieDB.QueryQuestSingle(questId, "preQuestGroup")
    return not preQuestGroup or QuestieDB:IsPreQuestGroupFulfilled(preQuestGroup)
end

---The quest that has to be finished before this one.
---@param questId QuestId
---@return QuestId?
function JourneyQuestCategories.GetMissingQuest(questId)
    local group = QuestieDB.QueryQuestSingle(questId, "preQuestGroup")
    for _, id in pairs(group or {}) do
        if not Questie.db.char.complete[math.abs(id)] then
            return math.abs(id)
        end
    end
    local single = QuestieDB.QueryQuestSingle(questId, "preQuestSingle")
    return JourneyPrerequisites.GetShown(QuestieDB.QueryQuestSingle(questId, "requiredRaces"), single or {})[1]
end

---@param questId QuestId
---@return JourneyQuestCategory? category Nil for a quest that isn't listed at all
---@return string? reason
---@return string? stateName
function JourneyQuestCategories.Get(questId)
    local text, _, state = QuestieDB.IsDoableVerbose(questId, false, true, true)
    local name = _GetStateName(state)
    local category = CATEGORY_BY_STATE[name]

    if name == "PARENT_ACTIVE" then
        for _, id in pairs(QuestieDB.QueryQuestSingle(questId, "exclusiveTo") or {}) do
            if ActiveQuests.Get(id) or Questie.db.char.complete[id] then
                return "unobtainable", nil, name
            end
        end
        if not _IsChildAvailable(questId) then
            return nil
        end
    elseif name == "EXCEED_REPUTATION" and QuestieDB.questsOnlyAvailableUntilReputationValue[questId] then
        category = "unobtainable"
    elseif name == "PARENT_INACTIVE" and Questie.db.char.complete[QuestieDB.QueryQuestSingle(questId, "parentQuest")] then
        category = "unobtainable"
    end
    if category == "available" and QuestieDB.IsRepeatable(questId) then
        category = "repeatable"
    end

    local reason
    if category == "later" or category == "unobtainable" then
        local prefix = l10n("Unavailable") .. l10n(": ")
        reason = text and text:sub(1, #prefix) == prefix and text:sub(#prefix + 1) or text
        if name == "NO_PREQUESTSINGLE" or name == "NO_PREQUESTGROUP" then
            local missing = JourneyQuestCategories.GetMissingQuest(questId)
            reason = missing and l10n("after %s", QuestieDB.QueryQuestSingle(missing, "name") or missing) or reason
        elseif name == "LEVEL_TOO_LOW" then
            reason = l10n("Level %s", QuestieDB.QueryQuestSingle(questId, "requiredLevel"))
        end
    end
    return category, reason, name
end

---How far a quest in the log is, added up over all its objectives.
---@param questId QuestId
---@return string? text
function JourneyQuestCategories.GetProgress(questId)
    local quest = QuestieDB.GetQuest(questId)
    local objectives = quest and quest.Objectives or {}
    if QuestieDB.IsComplete(questId) == 1 then
        return Questie:Colorize(l10n("Complete"):lower(), "yellow")
    elseif QuestieDB.IsComplete(questId) == -1 then
        return Questie:Colorize(l10n("Failed"):lower(), "red")
    end
    local collected, needed = 0, 0
    for _, objective in pairs(objectives) do
        collected = collected + (objective.Collected or 0)
        needed = needed + (objective.Needed or 0)
    end
    return needed > 1 and collected .. "/" .. needed or nil
end

---@param timestamp number
---@return string
function JourneyQuestCategories.GetShortDate(timestamp)
    local month = CALENDAR_FULLDATE_MONTH_NAMES[tonumber(date("%m", timestamp))]
    return (month or ""):sub(1, 3) .. " " .. tonumber(date("%d", timestamp))
end

---@return table<QuestId, number> timestamps When the quests were completed last, as far as the journey knows
local function _GetCompletionTimes()
    local timestamps = {}
    for _, entry in ipairs(Questie.db.char.journey) do
        if entry.SubType == "Complete" then
            timestamps[entry.Quest] = entry.Timestamp
        end
    end
    return timestamps
end

---@param questId QuestId
---@return string? note
local function _GetNote(questId, category, reason, completionTimes)
    if category == "log" then
        return JourneyQuestCategories.GetProgress(questId)
    elseif category == "completed" then
        return completionTimes[questId] and JourneyQuestCategories.GetShortDate(completionTimes[questId])
    elseif category == "available" or category == "repeatable" then
        local xp = QuestXP:GetQuestLogRewardXP(questId, Questie.db.profile.showQuestXpAtMaxLevel)
        return xp and xp > 0 and BreakUpLargeNumbers(xp) .. " " .. l10n("xp") or nil
    end
    return reason
end

---@param questId QuestId
---@param category JourneyQuestCategory
---@return JourneyIcon.Icon?
function JourneyQuestCategories.GetIcon(questId, category)
    if Questie.db.char.hidden[questId] then
        return JourneyIcon.HIDDEN
    elseif category == "log" then
        return Questie.icons[QuestieDB.IsComplete(questId) == 1 and "complete" or "incomplete"]
    elseif category == "available" then
        return Questie.icons["available"]
    elseif category == "repeatable" then
        return Questie.icons["repeatable"]
    elseif category == "later" then
        return Questie.icons["available_gray"]
    elseif category == "completed" then
        return Questie.icons["checkmark"]
    elseif category == "unobtainable" then
        return Questie.icons["cross"]
    end
end

---Yields, so it runs in a thread.
---@async
---@param questIds table<QuestId, any>
---@return JourneyTreeNode[] nodes The categories with their quests
---@return number completed
---@return number total Of those that can be done once
function JourneyQuestCategories.Collect(questIds)
    local HIDE_ON_MAP, hiddenQuests = QuestieQuestBlacklist.HIDE_ON_MAP, QuestieCorrections.hiddenQuests
    local completionTimes = _GetCompletionTimes()
    local nodes, nodesByKey = {}, {}
    for index, category in ipairs(CATEGORIES) do
        nodes[index] = {value = category.key, text = l10n(category.title), children = {}}
        nodesByKey[category.key] = nodes[index]
    end

    for _, levelAndQuest in ipairs(QuestieLib:SortQuestIDsByLevel(questIds, false, JourneyThread.YieldIfNeeded)) do
        JourneyThread.YieldIfNeeded()
        local questId = levelAndQuest[2]
        local hidden = hiddenQuests[questId]
        local isListed = QuestieDB.QuestPointers[questId] and (not hidden or hidden == HIDE_ON_MAP or QuestieEvent.IsEventQuest(questId))
        local category, reason
        if isListed then
            category, reason = JourneyQuestCategories.Get(questId)
        end
        if category then
            local node = {
                value = questId,
                text = QuestieLib:GetColoredQuestName(questId, Questie.db.profile.enableTooltipsQuestLevel, false),
                note = _GetNote(questId, category, reason, completionTimes),
                icon = JourneyQuestCategories.GetIcon(questId, category),
            }
            table.insert(nodesByKey[category].children, node)
            if Questie.db.char.hidden[questId] then
                table.insert(nodesByKey.hidden.children, node)
            end
        end
    end

    for _, node in ipairs(nodes) do
        node.note = tostring(#node.children)
    end
    local completed = #nodesByKey.completed.children
    return nodes, completed, completed + #nodesByKey.log.children + #nodesByKey.available.children + #nodesByKey.later.children
end

return JourneyQuestCategories
