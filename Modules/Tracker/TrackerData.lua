---@class TrackerData
local TrackerData = QuestieLoader:CreateModule("TrackerData")

---@type QuestieCompat
local QuestieCompat = QuestieLoader:ImportModule("QuestieCompat")
---@type QuestLogCache
local QuestLogCache = QuestieLoader:ImportModule("QuestLogCache")
---@type QuestiePlayer
local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
---@type QuestieEvent
local QuestieEvent = QuestieLoader:ImportModule("QuestieEvent")
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
---@field isComplete boolean Additional Questie completion handling, distinct from IsComplete().
---@field IsComplete fun(self: TrackerQuest): number

local quests = {}
local counterTypes = {monster = true, item = true, object = true, reputation = true, killcredit = true, spell = true}

local function _IsComplete(self)
    return self.completionState
end

-- Both bulk rendering and single-quest progress updates retain record identity so existing rows see new state.
local function _RefreshQuest(questId, title, level, header, nativeComplete)
    local quest = quests[questId]
    if not quest then
        quest = {
            Id = questId, Objectives = {}, ObjectiveData = {}, SpecialObjectives = {}, Finisher = {},
            requiredSourceItems = {}, sourceItemId = 0, objectivesLoaded = false,
            completionState = 0, isComplete = false, IsComplete = _IsComplete,
        }
        quests[questId] = quest
    end
    quest.name = title
    -- Older clients use -1 for quests whose effective level follows the player.
    quest.level = level == -1 and QuestiePlayer.GetPlayerLevel() or level or 0
    quest.zoneName = header

    local enriched = QuestiePlayer.currentQuestlog[questId]
    if type(enriched) ~= "table" then
        enriched = nil
    end
    quest.enrichment = enriched
    quest.zoneOrSort = enriched and enriched.zoneOrSort
    quest.Description = enriched and enriched.Description
    quest.Finisher = enriched and enriched.Finisher or {}
    quest.sourceItemId = enriched and enriched.sourceItemId or 0
    quest.requiredSourceItems = enriched and enriched.requiredSourceItems or {}

    -- Try to get the last valid quest snapshot. A missing entry is expected while loading;
    -- unlike GetQuest, this read-only lookup does not report it as an error. Never modify the entry.
    local cached = QuestLogCache.questLog_DO_NOT_MODIFY[questId]
    local previousObjectives = quest.Objectives
    quest.Objectives = {}
    quest.ObjectiveData = {}
    quest.SpecialObjectives = {}
    quest.objectivesLoaded = cached ~= nil

    if cached then
        quest.completionState = QuestieDB.IsComplete(questId)
        local allObjectivesMatched = enriched ~= nil
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
            local rawText = live.raw_text or live.text
            objective.Index = displayIndex
            objective.NativeIndex = index
            objective.questId = questId
            objective.Type = live.type
            objective.Description = live.text
            objective.FullDescription = QuestieLib.GetFullObjectiveTextConditional(rawText)
            objective.Collected = tonumber(live.numFulfilled) or 0
            objective.Needed = tonumber(live.numRequired) or 0
            objective.Completed = (counterTypes[live.type] and objective.Needed > 0 and objective.Collected == objective.Needed)
                or (live.finished == true and (objective.Needed == 0 or not counterTypes[live.type])) or false
            objective.RawText = rawText
            objective.enrichment = nil
            objective.Id = nil
            objective.spawnList = {}
            objective.AlreadySpawned = {}
            objective.Icon = nil

            -- Index/type alone cannot prove entity identity after a quest changes. Match database wording
            -- or localized entity name as well; otherwise keep live progress but omit entity-dependent actions.
            local metadata = enriched and enriched.ObjectiveData and enriched.ObjectiveData[index]
            local original = enriched and enriched.Objectives and enriched.Objectives[index]
            if metadata and original and metadata.Type == live.type then
                local expectedText = metadata.Text
                if not expectedText and metadata.Id then
                    if metadata.Type == "monster" then
                        expectedText = QuestieDB.QueryNPCSingle(metadata.Id, "name")
                    elseif metadata.Type == "item" then
                        expectedText = QuestieDB.QueryItemSingle(metadata.Id, "name")
                    elseif metadata.Type == "object" then
                        expectedText = QuestieDB.QueryObjectSingle(metadata.Id, "name")
                    end
                end
                local liveText = QuestieLib.TrimObjectiveText(rawText, live.type):gsub("%.$", "")
                local expected = expectedText and QuestieLib.TrimObjectiveText(expectedText, live.type):gsub("%.$", "")
                if expected and liveText == expected and original.Id == metadata.Id then
                    objective.enrichment = original
                    objective.Id = original.Id
                    objective.spawnList = original.spawnList or {}
                    objective.AlreadySpawned = original.AlreadySpawned or {}
                    objective.Icon = original.Icon
                    quest.ObjectiveData[#quest.ObjectiveData + 1] = metadata
                end
            end
            if not objective.enrichment then
                allObjectivesMatched = false
            end
            quest.Objectives[displayIndex] = objective
        end

        -- Preserve the existing missing-source-item objective for zero-objective quests. This is a Questie
        -- correction, not evidence that an empty Blizzard result by itself means the quest is complete.
        if #objectiveIndices == 0 and enriched and enriched.Objectives then
            for _, original in ipairs(enriched.Objectives) do
                if original.Type == "item" and original.Id == enriched.sourceItemId and original.Completed == false then
                    local objective = {}
                    for key, value in pairs(original) do
                        objective[key] = value
                    end
                    objective.Index = #quest.Objectives + 1
                    objective.questId = questId
                    objective.enrichment = original
                    quest.Objectives[objective.Index] = objective
                    allObjectivesMatched = false
                end
            end
        end
        quest.SpecialObjectives = allObjectivesMatched and enriched.SpecialObjectives or {}
        -- The additional completion flag is meaningful only for compatible live objectives. An old
        -- database quest must not hide newly added objectives, or a synthetic missing-source-item step.
        quest.isComplete = quest.completionState ~= -1 and (quest.completionState == 1
            or (allObjectivesMatched and enriched.isComplete == true)) or false
    else
        -- Do not infer completion from an initial cache miss. Native failure can still be shown.
        quest.completionState = nativeComplete == -1 and -1 or 0
        quest.isComplete = false
    end
    return quest
end

---Native membership is independent of both QuestieDB and the last valid objective cache.
---@param questId QuestId
---@return boolean
function TrackerData.ContainsQuest(questId)
    local index = QuestieCompat.GetQuestLogIndexByID(questId)
    return index ~= nil and index > 0
end

---Refresh once before a full layout; ordinary layout reads use GetQuests without rescanning objectives.
---@return table<QuestId, TrackerQuest>
function TrackerData.Refresh()
    local present = {}
    local header
    for index = 1, QuestieCompat.GetNumQuestLogEntries() do
        local title, level, _, isHeader, _, complete, _, questId = QuestieCompat.GetQuestLogTitle(index)
        if isHeader then
            header = title
        elseif title and questId and questId > 0 then
            present[questId] = true
            _RefreshQuest(questId, title, level, header, complete)
        end
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

---Refreshes only this quest's objectives. Header discovery reads log metadata, not other quests' progress.
---@param questId QuestId
---@return TrackerQuest?
function TrackerData.GetQuest(questId)
    local index = QuestieCompat.GetQuestLogIndexByID(questId)
    if not index or index <= 0 then
        quests[questId] = nil
        return nil
    end
    local title, level, _, isHeader, _, complete, _, currentId = QuestieCompat.GetQuestLogTitle(index)
    if not title or isHeader or currentId ~= questId then
        return nil
    end
    local header
    for headerIndex = index - 1, 1, -1 do
        local headerTitle, _, _, entryIsHeader = QuestieCompat.GetQuestLogTitle(headerIndex)
        if entryIsHeader then
            header = headerTitle
            break
        end
    end
    return _RefreshQuest(questId, title, level, header, complete)
end

---@param questId QuestId
function TrackerData.RemoveQuest(questId)
    quests[questId] = nil
end

---@param quest TrackerQuest
---@param showLevel boolean
---@param showState boolean
---@return string
function TrackerData.GetColoredQuestName(quest, showLevel, showState)
    local name = quest.name
    if showLevel then
        name = QuestieLib:GetLevelString(quest.Id, quest.level) .. name
    end
    if Questie.db.profile.enableTooltipsQuestID then
        name = name .. " " .. l10n("(") .. quest.Id .. l10n(")")
    end
    if showState then
        if quest:IsComplete() == -1 then
            name = name .. " " .. Questie:Colorize(l10n("(") .. l10n("Failed") .. l10n(")"), "red")
        elseif quest:IsComplete() == 1 or quest.isComplete then
            name = name .. " " .. Questie:Colorize(l10n("(") .. l10n("Complete") .. l10n(")"), "green")
        end
    end
    local enriched = quest.enrichment
    return QuestieLib:PrintDifficultyColor(quest.level, name,
        enriched and enriched.IsRepeatable, enriched and QuestieEvent.IsEventQuest(quest.Id),
        enriched and QuestieDB.IsPvPQuest(quest.Id))
end

---Keep Questie's chat-safe bracket format without requiring a database title.
---@param quest TrackerQuest
---@return string
function TrackerData.GetQuestLink(quest)
    local name = quest.name .. " (" .. quest.Id .. ")]"
    if Questie.db.profile.trackerShowQuestLevel then
        return "[[" .. quest.level .. "] " .. name
    end
    return "[" .. name
end

---@param objective table
---@return string
function TrackerData.GetObjectiveText(objective)
    local description = QuestieLib:GetObjectiveDescription(objective)
    local countable = counterTypes[objective.Type] and type(objective.Needed) == "number" and objective.Needed > 0
        and type(objective.Collected) == "number"
    local colorObjective = countable and objective or {Collected = objective.Completed and 1 or 0, Needed = 1}
    if countable then
        description = description .. ": " .. objective.Collected .. "/" .. objective.Needed
    end
    return QuestieLib:GetRGBForObjective(colorObjective) .. description
end
