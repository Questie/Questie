---@class PartyQuests
local PartyQuests = QuestieLoader:CreateModule("PartyQuests")
PartyQuests.private = PartyQuests.private or {}
local _PartyQuests = PartyQuests.private

---@type QuestieComms
local QuestieComms = QuestieLoader:ImportModule("QuestieComms")
---@type QuestieQuest
local QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")
---@type QuestieMap
local QuestieMap = QuestieLoader:ImportModule("QuestieMap")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")

local C_Timer_After = C_Timer.After
local stringlower = string.lower
local tostring = tostring

local REMOTE_MAP_TYPE = "partyQuests"
local OBJECTIVE_TYPE_LOOKUP = {
    ["m"] = "monster",
    ["o"] = "object",
    ["i"] = "item",
    ["e"] = "event",
    ["s"] = "spell",
    ["k"] = "killcredit",
}
local ICON_BY_OBJECTIVE_TYPE = {
    ["monster"] = Questie.ICON_TYPE_SLAY,
    ["killcredit"] = Questie.ICON_TYPE_SLAY,
    ["object"] = Questie.ICON_TYPE_OBJECT,
    ["item"] = Questie.ICON_TYPE_LOOT,
    ["spell"] = Questie.ICON_TYPE_LOOT,
    ["event"] = Questie.ICON_TYPE_EVENT,
}

_PartyQuests.enabled = false
_PartyQuests.focusPlayer = nil
_PartyQuests.refreshPending = false
_PartyQuests.showCompleted = false  -- show completed quests on map
_PartyQuests.showOnlyObjectives = true  -- show only incomplete objectives (false = show all including completed)

local function _GetQuestName(questId)
    return QuestieLib:GetColoredQuestName(
        questId,
        Questie.db.profile.enableTooltipsQuestLevel,
        false
    )
end

local function _GetNormalizedName(name)
    if not name then
        return nil
    end
    return stringlower(name)
end

local function _ShouldRenderPlayer(playerName)
    if not QuestieComms:CheckInGroup(playerName) then
        return false
    end

    if not _PartyQuests.focusPlayer then
        return true
    end

    return _GetNormalizedName(playerName) == _GetNormalizedName(_PartyQuests.focusPlayer)
end

local function _GetTableSize(t)
    local count = 0
    for _ in pairs(t) do count = count + 1 end
    return count
end

local _classToIdLookup = {
    ["DRUID"] = "DRUID",
    ["HUNTER"] = "HUNTER",
    ["MAGE"] = "MAGE",
    ["PRIEST"] = "PRIEST",
    ["ROGUE"] = "ROGUE",
    ["SHAMAN"] = "SHAMAN",
    ["WARLOCK"] = "WARLOCK",
    ["WARRIOR"] = "WARRIOR",
}

local function _BuildSpawnList(objective, objectiveData, questObjective)
    local objectiveType = OBJECTIVE_TYPE_LOOKUP[objective.type]
    if not objectiveType then
        return nil, nil
    end

    local spawnBuilder = QuestieQuest.private.objectiveSpawnListCallTable[objectiveType]
    if not spawnBuilder then
        return nil, objectiveType
    end

    -- Guard against partial comms payloads: Questie core spawn builders expect
    -- required IDs/coordinates and will emit hard error logs if missing.
    if objectiveType == "event" then
        local hasCoordinates = (questObjective and questObjective.Coordinates) or (objectiveData and objectiveData.Coordinates)
        if not hasCoordinates then
            return nil, objectiveType
        end
    elseif objectiveType == "killcredit" then
        if not (objectiveData and objectiveData.IdList) then
            return nil, objectiveType
        end
    elseif not objective.id then
        return nil, objectiveType
    end

    local fakeObjective = {
        Description = objectiveData and objectiveData.Description or "Objective",
        Icon = objectiveData and objectiveData.Icon,
        Coordinates = (questObjective and questObjective.Coordinates) or (objectiveData and objectiveData.Coordinates),
    }

    return spawnBuilder(objective.id, fakeObjective, objectiveData), objectiveType
end

local function _GetTooltipBody(questName, objectiveText, playerName, objective)
    local progressText = tostring(objective.fulfilled or 0) .. "/" .. tostring(objective.required or 0)
    return {
        {"Quest: ", questName},
        {"Player: ", playerName},
        {"Objective: ", objectiveText},
        {"Progress: ", progressText},
    }
end

local function _DrawObjective(questId, questName, objectiveIndex, objective, playerName)
    local quest = QuestieDB.GetQuest(questId)
    local objectiveData = quest and quest.ObjectiveData and quest.ObjectiveData[objectiveIndex]
    local questObjective = quest and quest.Objectives and quest.Objectives[objectiveIndex]
    local spawnList, objectiveType = _BuildSpawnList(objective, objectiveData, questObjective)
    if not spawnList then
        return
    end

    local objectiveDescription = objectiveData and objectiveData.Description or objectiveType or "Objective"
    local iconType = ICON_BY_OBJECTIVE_TYPE[objectiveType] or Questie.ICON_TYPE_LOOT
    local playerKey = _GetNormalizedName(playerName) or playerName or "unknown"
    local sharedDataId = tostring(questId) .. ":" .. tostring(objectiveIndex) .. ":" .. tostring(playerKey)

    for _, spawnData in pairs(spawnList) do
        for zone, spawns in pairs(spawnData.Spawns or {}) do
            local count = 0
            for _, coords in ipairs(spawns) do
                local x, y = coords[1], coords[2]
                if x and y and x ~= -1 and y ~= -1 then
                    count = count + 1
                    if count > 10 then
                        break
                    end

                    local data = {
                        id = sharedDataId,
                        Icon = Questie.usedIcons[iconType],
                        Name = objectiveDescription,
                        Type = "manual",
                        ManualTooltipData = {
                            Title = questName,
                            Body = _GetTooltipBody(questName, objectiveDescription, playerName, objective),
                            disableShiftToRemove = true,
                        },
                        GetIconScale = function()
                            return 0.9
                        end,
                    }
                    data.IconScale = data:GetIconScale()

                    QuestieMap:DrawManualIcon(data, zone, x, y, REMOTE_MAP_TYPE)
                end
            end
        end
    end
end

function PartyQuests:RefreshMapPins()
    QuestieMap:ResetManualFrames(REMOTE_MAP_TYPE)
    if not _PartyQuests.enabled then
        return
    end

    for questId, questEntries in pairs(QuestieComms.remoteQuestLogs) do
        local questName = _GetQuestName(questId)
        for playerName, objectives in pairs(questEntries) do
            if _ShouldRenderPlayer(playerName) then
                for objectiveIndex, objective in pairs(objectives) do
                    local fulfilled = objective.fulfilled or 0
                    local required = objective.required or 0
                    -- Show objective if: only incomplete objectives mode AND progress incomplete
                    --                   OR show all objectives mode (always show)
                    local isIncomplete = required > fulfilled
                    local shouldShow = isIncomplete
                    if not _PartyQuests.showOnlyObjectives and _PartyQuests.showCompleted then
                        shouldShow = true
                    end
                    if shouldShow then
                        _DrawObjective(questId, questName, objectiveIndex, objective, playerName)
                    end
                end
            end
        end
    end
end

function PartyQuests:SetEnabled(enabled)
    _PartyQuests.enabled = enabled and true or false
    PartyQuests:RefreshMapPins()
end

function PartyQuests:IsEnabled()
    return _PartyQuests.enabled
end

function PartyQuests:SetFocusPlayer(playerName)
    _PartyQuests.focusPlayer = playerName
    PartyQuests:RefreshMapPins()
end

function PartyQuests:GetFocusPlayer()
    return _PartyQuests.focusPlayer
end

function PartyQuests:QueueRefresh()
    if _PartyQuests.refreshPending then
        return
    end

    _PartyQuests.refreshPending = true
    C_Timer_After(0.4, function()
        _PartyQuests.refreshPending = false
        PartyQuests:RefreshMapPins()
    end)
end

function PartyQuests:PrintRemoteQuestLog(playerName)
    local normalizedPlayer = _GetNormalizedName(playerName)
    local questCount = 0
    local groupedQuests = {}

    -- Gather quests by player
    for questId, questEntries in pairs(QuestieComms.remoteQuestLogs) do
        for remotePlayerName, objectives in pairs(questEntries) do
            local isMatch = (not normalizedPlayer) or (_GetNormalizedName(remotePlayerName) == normalizedPlayer)
            if isMatch and QuestieComms:CheckInGroup(remotePlayerName) then
                if not groupedQuests[remotePlayerName] then
                    groupedQuests[remotePlayerName] = {}
                end

                -- Calculate quest progress
                local totalObjectives = 0
                local completedObjectives = 0
                for _, objective in pairs(objectives) do
                    totalObjectives = totalObjectives + 1
                    if objective.fulfilled and objective.required and objective.fulfilled >= objective.required then
                        completedObjectives = completedObjectives + 1
                    end
                end

                groupedQuests[remotePlayerName][questId] = {
                    name = _GetQuestName(questId),
                    completed = completedObjectives,
                    total = totalObjectives,
                    objectives = objectives,
                }
                questCount = questCount + 1
            end
        end
    end

    if questCount == 0 then
        if playerName then
            Questie:Print("|cFFFF6F22[PartyQuests]|r", "No quests found for " .. playerName .. ".")
        else
            Questie:Print("|cFFFF6F22[PartyQuests]|r", "No party quests found.")
        end
        return
    end

    -- Print grouped output
    for remotePlayerName, quests in pairs(groupedQuests) do
        local classColor = _PartyQuests:GetPlayerClassColor(remotePlayerName)
        Questie:Print("|cFFFF6F22[PartyQuests]|r", classColor .. remotePlayerName .. "|r (" .. _GetTableSize(quests) .. " quests)")
        for questId, questInfo in pairs(quests) do
            local progressColor = questInfo.completed == questInfo.total and "|cFF00FF00" or "|cFFFFA500"
            Questie:Print("  " .. progressColor .. questInfo.name .. "|r (" .. questInfo.completed .. "/" .. questInfo.total .. " objectives)")
        end
    end
end

function _PartyQuests:GetPlayerClassColor(playerName)
    local classId = _classToIdLookup[QuestieComms.remotePlayerClasses[playerName]]
    if classId then
        return "|c" .. RAID_CLASS_COLORS[classId].colorStr
    end
    return "|cFFFFFFFF"
end

function PartyQuests:GetShowCompleted()
    return _PartyQuests.showCompleted
end

function PartyQuests:SetShowCompleted(showCompleted)
    _PartyQuests.showCompleted = showCompleted and true or false
    _PartyQuests.showOnlyObjectives = not _PartyQuests.showCompleted
    PartyQuests:RefreshMapPins()
end

function PartyQuests:GetShowOnlyObjectives()
    return _PartyQuests.showOnlyObjectives
end

function PartyQuests:SetShowOnlyObjectives(showOnlyObjectives)
    _PartyQuests.showOnlyObjectives = showOnlyObjectives and true or false
    _PartyQuests.showCompleted = not _PartyQuests.showOnlyObjectives
    PartyQuests:RefreshMapPins()
end

function PartyQuests:Initialize()
    Questie:RegisterMessage("QC_ID_REMOTE_QUESTLOG_UPDATED", PartyQuests.QueueRefresh)
end

return PartyQuests
