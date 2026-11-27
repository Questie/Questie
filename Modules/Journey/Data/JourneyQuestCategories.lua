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
---@type utf8
local utf8 = QuestieLoader:ImportModule("utf8")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

-- Trying out the Journey without it: the gray "!" of a quest that misses a requirement
local SHOW_MISSING_REQUIREMENT_ICON = false

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

---The quest that has to be finished before this one.
---@param questId QuestId
---@return QuestId?
function JourneyQuestCategories.GetMissingQuest(questId)
    local group = QuestieDB.QueryQuestSingle(questId, "preQuestGroup")
    for _, id in pairs(group or {}) do
        -- QuestieDB counts a quest as done too when one of its exclusive quests was done instead
        if not QuestieDB:IsPreQuestGroupFulfilled({id}) then
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

---@alias JourneyQuestLogState "ready"|"failed"|"active"

---How far a quest in the log is: ready to be turned in, failed, or still to be done.
---@param questId QuestId
---@return JourneyQuestLogState
function JourneyQuestCategories.GetLogState(questId)
    local isComplete = QuestieDB.IsComplete(questId)
    if isComplete == 1 then
        return "ready"
    elseif isComplete == -1 then
        return "failed"
    end
    return "active"
end

---How far a quest in the log is, added up over all its objectives.
---@param questId QuestId
---@return string? text
function JourneyQuestCategories.GetProgress(questId)
    local quest = QuestieDB.GetQuest(questId)
    local objectives = quest and quest.Objectives or {}
    local state = JourneyQuestCategories.GetLogState(questId)
    if state == "ready" then
        return Questie:Colorize(l10n("Complete"):lower(), "green") -- Like Ready to turn-in in the details
    elseif state == "failed" then
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
    -- Three characters, not bytes: those of Russian, Korean and Chinese take several bytes each
    return utf8.sub(month or "", 1, 3) .. " " .. tonumber(date("%d", timestamp))
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
---@param category JourneyQuestCategory
---@param reason string?
---@param completionTimes table<QuestId, number>
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

---Some quests are handed in without being accepted, so they are never in the quest log.
---@param questId QuestId
---@return boolean
local function _IsTurnInOnly(questId)
    local objectivesText = QuestieDB.QueryQuestSingle(questId, "objectivesText")
    return not objectivesText or #objectivesText == 0 -- QuestieDB has none for those
end

---The kind of a quest, in the order the map uses too (QuestieLib.GetQuestIcon).
---@param questId QuestId
---@return string name Of its icon in Questie.icons
local function _GetKind(questId)
    if Questie.IsSoD and QuestieDB.IsSoDRuneQuest(questId) then
        return "sod_rune"
    elseif QuestieDB.IsActiveEventQuest(questId) then
        return "eventquest"
    elseif QuestieDB.IsPvPQuest(questId) then
        return "pvpquest"
    elseif QuestieDB.IsRepeatable(questId) then
        return _IsTurnInOnly(questId) and "repeatable_complete" or "repeatable"
    end
    return "available"
end

---@param questId QuestId
---@return string|JourneyIcon.DarkIcon icon Darker for a low-level quest
function JourneyQuestCategories.GetKindIcon(questId)
    local kind = _GetKind(questId)
    local isLowLevel = QuestieDB.IsTrivial(QuestieLib.GetEffectiveQuestLevel(questId))
    return isLowLevel and JourneyIcon.GetLowLevel(kind) or Questie.icons[kind]
end

---@param questId QuestId
---@return string icon For where it starts, also bright for a low-level quest
function JourneyQuestCategories.GetStartIcon(questId)
    return Questie.icons[_GetKind(questId)]
end

---The same as for its turn-in on the map (QuestFinisher).
---@param questId QuestId One that is complete
---@return string icon
function JourneyQuestCategories.GetCompleteIcon(questId)
    if QuestieEvent.IsEventQuest(questId) then
        return Questie.icons["eventquest_complete"]
    elseif QuestieDB.IsPvPQuest(questId) then
        return Questie.icons["pvpquest_complete"]
    elseif QuestieDB.IsRepeatable(questId) then
        return Questie.icons["repeatable_complete"]
    end
    return Questie.icons["complete"]
end

---@param questId QuestId
---@param category JourneyQuestCategory
---@return JourneyIcon.Icon?
function JourneyQuestCategories.GetIcon(questId, category)
    if Questie.db.char.hidden[questId] then
        return JourneyIcon.HIDDEN
    elseif category == "available" or category == "repeatable" then
        return JourneyQuestCategories.GetKindIcon(questId)
    elseif category == "later" then
        if _GetKind(questId) ~= "available" then
            return JourneyQuestCategories.GetKindIcon(questId)
        end
        return SHOW_MISSING_REQUIREMENT_ICON and Questie.icons["available_gray"] or nil
    elseif category == "log" then
        local state = JourneyQuestCategories.GetLogState(questId)
        if state == "ready" then
            return JourneyQuestCategories.GetCompleteIcon(questId)
        elseif state == "failed" then
            return Questie.icons["cross"]
        end
        return Questie.icons["incomplete"]
    elseif category == "completed" then
        return Questie.icons["checkmark"]
    elseif category == "unobtainable" then
        return Questie.icons["cross"]
    end
end

---What can be done with a quest, as the top of its details and its tooltip say it.
---@param questId QuestId
---@return string text With an icon in front
function JourneyQuestCategories.GetStatus(questId)
    local category, reason, stateName = JourneyQuestCategories.Get(questId)
    if category == "log" then
        local state = JourneyQuestCategories.GetLogState(questId)
        if state == "ready" then
            return JourneyIcon.GetMarkup(JourneyQuestCategories.GetCompleteIcon(questId)) .. Questie:Colorize(QUEST_WATCH_QUEST_READY, "green")
        elseif state == "failed" then
            return JourneyIcon.GetMarkup(Questie.icons["cross"]) .. Questie:Colorize(l10n("Failed"), "red")
        end
        return Questie:Colorize(QUEST_TOOLTIP_ACTIVE, "lightBlue") -- Like the timers of quests in the tracker
    elseif category == "available" or category == "repeatable" then
        return JourneyIcon.GetMarkup(JourneyQuestCategories.GetKindIcon(questId)) .. Questie:Colorize(l10n("Available"), "gold") -- Like the headings
    elseif category == "completed" then
        return JourneyIcon.GetMarkup(Questie.icons["checkmark"]) .. l10n("Completed")
    elseif category == "later" then
        if stateName == "NO_PREQUESTSINGLE" then
            reason = l10n("Incomplete pre-quest")
        elseif stateName == "NO_PREQUESTGROUP" then
            reason = l10n("Incomplete pre-quest group")
        elseif stateName == "LEVEL_TOO_LOW" then
            reason = ITEM_MIN_LEVEL:format(QuestieDB.QueryQuestSingle(questId, "requiredLevel"))
        end
        return JourneyIcon.GetMarkup(Questie.icons["cross"]) .. Questie:Colorize(l10n("Unavailable") .. l10n(": "), "red") .. (reason or "")
    elseif category == "unobtainable" then
        return JourneyIcon.GetMarkup(Questie.icons["cross"]) .. Questie:Colorize(l10n("Unavailable") .. l10n(": "), "red")
            .. (reason or l10n("Exclusive quest completed"))
    end
    return JourneyIcon.GetMarkup(Questie.icons["cross"]) .. (QuestieDB.IsDoableVerbose(questId, false, true, true) or "")
end

---@param questId QuestId
---@return boolean
function JourneyQuestCategories.IsListed(questId)
    local hidden = QuestieCorrections.hiddenQuests[questId]
    return QuestieDB.QuestPointers[questId] ~= nil
        and (not hidden or hidden == QuestieQuestBlacklist.HIDE_ON_MAP or QuestieEvent.IsEventQuest(questId))
end

---What the player can do with a quest, and what its entry in the list says at the right edge.
---@param questId QuestId
---@param completionTimes table<QuestId, number>
---@return JourneyQuestCategory? category Nil for a quest that isn't listed at all
---@return string? note
local function _Categorize(questId, completionTimes)
    if not JourneyQuestCategories.IsListed(questId) then
        return nil
    end
    local category, reason = JourneyQuestCategories.Get(questId)
    return category, category and _GetNote(questId, category, reason, completionTimes) or nil
end

---@class JourneyQuestCategories.Entry
---@field questId QuestId
---@field category JourneyQuestCategory
---@field note string? What the list says at the right edge

---A few quests, like those of an NPC, in the order of the list: by category, and by level in each. Those the list leaves out are
---left out. It doesn't yield, so it isn't for many.
---@param questIds QuestId[]
---@return JourneyQuestCategories.Entry[]
function JourneyQuestCategories.Arrange(questIds)
    local completionTimes = _GetCompletionTimes()
    local questIdSet = {}
    for _, questId in ipairs(questIds) do questIdSet[questId] = true end

    local entriesByCategory = {}
    for _, levelAndQuest in ipairs(QuestieLib:SortQuestIDsByLevel(questIdSet, false)) do
        local questId = levelAndQuest[2]
        local category, note = _Categorize(questId, completionTimes)
        if category then
            entriesByCategory[category] = entriesByCategory[category] or {}
            table.insert(entriesByCategory[category], {questId = questId, category = category, note = note})
        end
    end

    local entries = {}
    for _, category in ipairs(CATEGORIES) do
        for _, entry in ipairs(entriesByCategory[category.key] or {}) do table.insert(entries, entry) end
    end
    return entries
end

-- The quests that can be done once, done or not yet: what "of how many" counts
local COUNTED = {log = true, available = true, later = true, completed = true}

---@param category string
---@return boolean isCounted Whether the quests of the category count towards how many quests there are
function JourneyQuestCategories.IsCounted(category)
    return COUNTED[category] == true
end

---Yields, so it runs in a thread.
---@async
---@param questIds table<QuestId, any>
---@return JourneyTreeNode[] nodes The categories with their quests
---@return number completed
---@return number total Of those that can be done once
function JourneyQuestCategories.Collect(questIds)
    local completionTimes = _GetCompletionTimes()
    local nodes, nodesByKey = {}, {}
    for index, category in ipairs(CATEGORIES) do
        nodes[index] = {value = category.key, text = l10n(category.title), children = {}}
        nodesByKey[category.key] = nodes[index]
    end

    for _, levelAndQuest in ipairs(QuestieLib:SortQuestIDsByLevel(questIds, false, JourneyThread.YieldIfNeeded)) do
        JourneyThread.YieldIfNeeded()
        local questId = levelAndQuest[2]
        local category, note = _Categorize(questId, completionTimes)
        if category then
            local node = {
                value = questId,
                text = QuestieLib:GetColoredQuestName(questId, Questie.db.profile.enableTooltipsQuestLevel, false),
                note = note,
                icon = JourneyQuestCategories.GetIcon(questId, category),
            }
            table.insert(nodesByKey[category].children, node)
            if Questie.db.char.hidden[questId] then
                table.insert(nodesByKey.hidden.children, node)
            end
        end
    end

    local total = 0
    for _, node in ipairs(nodes) do
        node.note = tostring(#node.children)
        if JourneyQuestCategories.IsCounted(node.value) then
            total = total + #node.children
        end
    end
    return nodes, #nodesByKey.completed.children, total
end

return JourneyQuestCategories
