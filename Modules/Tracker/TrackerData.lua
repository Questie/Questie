-- Owns native metadata, objective display records and their lifetime for every tracked quest.
-- TrackerQuestieBehavior owns quest completion, database additions and Questie compatibility exceptions.
-- Shared formatting at the end of this file affects both known and database-unknown quests.
---@class TrackerData
local TrackerData = QuestieLoader:CreateModule("TrackerData")

---@type QuestieCompat
local QuestieCompat = QuestieLoader:ImportModule("QuestieCompat")
---@type QuestLogCache
local QuestLogCache = QuestieLoader:ImportModule("QuestLogCache")
---@type QuestiePlayer
local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
---@type TrackerQuestieBehavior
local TrackerQuestieBehavior = QuestieLoader:ImportModule("TrackerQuestieBehavior")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

---@class TrackerQuest
---@field Id QuestId
---@field name string
---@field level number
---@field zoneName string? Native quest-log header, including quests absent from the database.
---@field zoneOrSort number?
---@field Objectives table[] Live display objectives; optional enrichment points to original map objects.
---@field enrichment Quest? Never mutate this through the display record.
---@field objectivesLoaded boolean Whether a valid objective snapshot has been obtained.
---@field completionState number Numeric quest state resolved by TrackerQuestieBehavior.
---@field isComplete boolean Additional completion state resolved by TrackerQuestieBehavior, distinct from IsComplete().
---@field IsComplete fun(self: TrackerQuest): number

local quests = {}
local counterTypes = {monster = true, item = true, object = true, reputation = true, killcredit = true, spell = true}

local function _IsComplete(self)
    return self.completionState
end

-- Both bulk rendering and single-quest progress updates retain record identity so existing rows see new state.
local function _RefreshQuest(questId, title, level, header, nativeComplete)
    local displayQuest = quests[questId]
    if not displayQuest then
        displayQuest = {
            Id = questId, Objectives = {}, objectivesLoaded = false, IsComplete = _IsComplete,
        }
        quests[questId] = displayQuest
    end
    displayQuest.name = title
    -- Older clients use -1 for quests whose effective level follows the player.
    displayQuest.level = level == -1 and QuestiePlayer.GetPlayerLevel() or level or 0
    displayQuest.zoneName = header

    -- Blizzard data: build objective wording and progress for every quest, without database matching.
    -- Quest-level completion is resolved once by TrackerQuestieBehavior below.
    -- Keep rendering while the initial snapshot loads; a cache miss is expected, not an error.
    local cached = QuestLogCache.TryGetQuest(questId)
    local previousObjectives = displayQuest.Objectives
    displayQuest.Objectives = {}
    displayQuest.objectivesLoaded = cached ~= nil

    if cached then
        local objectiveIndices = {}
        for index in pairs(cached.objectives) do
            objectiveIndices[#objectiveIndices + 1] = index
        end

        -- QuestLogCache can omit invalid empty rows. Keep native ordering without letting a hole
        -- discard later objectives; display indices stay dense for the line pool's incremental updates.
        table.sort(objectiveIndices)
        for displayIndex, index in ipairs(objectiveIndices) do
            local live = cached.objectives[index]
            local objective = previousObjectives[displayIndex] or {}
            objective.Index = displayIndex
            objective.NativeIndex = index
            objective.questId = questId
            objective.Type = live.type
            -- The cache validates native text. Keep its accepted wording, counters and punctuation intact.
            objective.Description = live.text
            objective.Collected = tonumber(live.numFulfilled) or 0
            objective.Needed = tonumber(live.numRequired) or 0
            -- Native action objectives can report 1/1 while unfinished. The cache owns completion normalization.
            objective.Completed = live.finished == true
            displayQuest.Objectives[displayIndex] = objective
        end
    end

    -- Resolve quest completion and apply Questie-specific behavior in one place, including the unloaded case.
    -- This step never replaces the native title, objective wording or live progress with database values.
    TrackerQuestieBehavior.Apply(displayQuest, cached, nativeComplete)
    return displayQuest
end

---Native membership is independent of both QuestieDB and the last valid objective cache.
---@param questId QuestId
---@return boolean
function TrackerData.ContainsQuest(questId)
    local index = QuestieCompat.GetQuestLogIndexByID(questId)
    return index ~= nil and index > 0
end

---Collapsed logs can list all headers before their quests, so the preceding header may be unrelated.
---Use the client's explicit association when available; callers retain sequential fallback for other clients.
---@param questLogIndex number
---@return string?
local function _GetQuestHeader(questLogIndex)
    if GetQuestSortIndex then
        local headerIndex = GetQuestSortIndex(questLogIndex)
        if headerIndex and headerIndex > 0 then
            local title, _, _, isHeader = QuestieCompat.GetQuestLogTitle(headerIndex)
            if isHeader then
                return title
            end
        end
    end
end

---Refresh once before a full layout; ordinary layout reads use GetQuests without rescanning objectives.
---@return table<QuestId, TrackerQuest>
function TrackerData.Refresh()
    local present = {}
    local header
    local index = 1
    -- Titan's entry count can disagree with title enumeration at login (4 entries, but 6 quests).
    -- Follow the title API to the end, or valid quests can disappear until the quest log is opened.
    while true do
        local title, level, _, isHeader, _, complete, _, questId = QuestieCompat.GetQuestLogTitle(index)
        if not title then
            break
        end
        if isHeader then
            header = title
        elseif questId and questId > 0 then
            present[questId] = true
            _RefreshQuest(questId, title, level, _GetQuestHeader(index) or header, complete)
        end
        index = index + 1
    end
    for questId in pairs(quests) do
        if not present[questId] then
            quests[questId] = nil
        end
    end
    return quests
end

---Returns the current display snapshot without reading client data.
---@return table<QuestId, TrackerQuest>
function TrackerData.GetQuests()
    return quests
end

---Reads the current display snapshot without client queries, refreshes or membership changes.
---Call Refresh or RefreshQuest from update paths before reading; RemoveQuest invalidates lifecycle removals.
---@param questId QuestId
---@return TrackerQuest?
function TrackerData.GetQuest(questId)
    return quests[questId]
end

---Refreshes only this quest's objectives. Header discovery reads log metadata, not other quests' progress.
---Use for incremental updates and commands that must revalidate a possibly stale display record.
---@param questId QuestId
---@return TrackerQuest?
function TrackerData.RefreshQuest(questId)
    local index = QuestieCompat.GetQuestLogIndexByID(questId)
    if not index or index <= 0 then
        quests[questId] = nil
        return nil
    end
    local title, level, _, isHeader, _, complete, _, currentId = QuestieCompat.GetQuestLogTitle(index)
    if not title or isHeader or currentId ~= questId then
        return nil
    end
    local header = _GetQuestHeader(index)
    if not header then
        for headerIndex = index - 1, 1, -1 do
            local headerTitle, _, _, entryIsHeader = QuestieCompat.GetQuestLogTitle(headerIndex)
            if entryIsHeader then
                header = headerTitle
                break
            end
        end
    end
    return _RefreshQuest(questId, title, level, header, complete)
end

---@param questId QuestId
function TrackerData.RemoveQuest(questId)
    quests[questId] = nil
end

---@param displayQuest TrackerQuest
---@param showLevel boolean
---@param showState boolean
---@return string
function TrackerData.GetColoredQuestName(displayQuest, showLevel, showState)
    local name = displayQuest.name
    if showLevel then
        name = QuestieLib:GetLevelString(displayQuest.Id, displayQuest.level) .. name
    end
    if Questie.db.profile.enableTooltipsQuestID then
        name = name .. " " .. l10n("(") .. displayQuest.Id .. l10n(")")
    end
    if showState then
        if displayQuest:IsComplete() == -1 then
            name = name .. " " .. Questie:Colorize(l10n("(") .. l10n("Failed") .. l10n(")"), "red")
        elseif displayQuest:IsComplete() == 1 or displayQuest.isComplete then
            name = name .. " " .. Questie:Colorize(l10n("(") .. l10n("Complete") .. l10n(")"), "green")
        end
    end
    local isRepeatable, isEvent, isPvP = TrackerQuestieBehavior.GetTitleFlags(displayQuest)
    return QuestieLib:PrintDifficultyColor(displayQuest.level, name, isRepeatable, isEvent, isPvP)
end

---Keep Questie's chat-safe bracket format without requiring a database title.
---@param displayQuest TrackerQuest
---@return string
function TrackerData.GetQuestLink(displayQuest)
    local name = displayQuest.name .. " (" .. displayQuest.Id .. ")]"
    if Questie.db.profile.trackerShowQuestLevel then
        return "[[" .. displayQuest.level .. "] " .. name
    end
    return "[" .. name
end

---@param objective table
---@return string
function TrackerData.GetObjectiveText(objective)
    -- Counts provide intermediate progress colors, but must not turn an unfinished 1/1 action green.
    local hasPartialProgress = counterTypes[objective.Type] and type(objective.Needed) == "number" and objective.Needed > 0
        and type(objective.Collected) == "number" and objective.Collected < objective.Needed
    local colorObjective = not objective.Completed and hasPartialProgress and objective
        or {Collected = objective.Completed and 1 or 0, Needed = 1}
    return QuestieLib:GetRGBForObjective(colorObjective) .. objective.Description
end
