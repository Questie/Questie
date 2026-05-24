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
local stringbyte = string.byte
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
local GENERIC_OBJECTIVE_TEXT = {
    ["monster"] = true,
    ["monsters"] = true,
    ["object"] = true,
    ["objects"] = true,
    ["item"] = true,
    ["items"] = true,
    ["event"] = true,
    ["spell"] = true,
    ["killcredit"] = true,
    ["objective"] = true,
}

_PartyQuests.enabled = false
_PartyQuests.focusPlayer = nil
_PartyQuests.refreshPending = false
_PartyQuests.showCompleted = false  -- show completed quests on map
_PartyQuests.showOnlyObjectives = true  -- show only incomplete objectives (false = show all including completed)
local periodicSyncTicker

---@param questId QuestId
---@return string
local function _GetQuestName(questId)
    return QuestieLib:GetColoredQuestName(
        questId,
        Questie.db.profile.enableTooltipsQuestLevel,
        false
    )
end

---@param name string|nil
---@return string|nil
local function _GetNormalizedName(name)
    if not name then
        return nil
    end
    return stringlower(name)
end

---@param playerName string
---@return boolean
local function _ShouldRenderPlayer(playerName)
    if not QuestieComms:CheckInGroup(playerName) then
        return false
    end

    if not _PartyQuests.focusPlayer then
        return true
    end

    return _GetNormalizedName(playerName) == _GetNormalizedName(_PartyQuests.focusPlayer)
end

---@param t table
---@return number
local function _GetTableSize(t)
    local count = 0
    for _ in pairs(t) do count = count + 1 end
    return count
end

local function _RefreshMapPinsFresh()
    if not _PartyQuests.enabled then
        PartyQuests:RefreshMapPins()
        return
    end

    Questie:SendMessage("QC_ID_REQUEST_FULL_QUESTLIST")
    C_Timer_After(0.8, function()
        PartyQuests:RefreshMapPins()
    end)
end

local _classToIdLookup = {
    ["DRUID"] = "DRUID",
    ["HUNTER"] = "HUNTER",
    ["MAGE"] = "MAGE",
    ["PALADIN"] = "PALADIN",
    ["PRIEST"] = "PRIEST",
    ["ROGUE"] = "ROGUE",
    ["SHAMAN"] = "SHAMAN",
    ["WARLOCK"] = "WARLOCK",
    ["WARRIOR"] = "WARRIOR",
    ["DEATHKNIGHT"] = "DEATHKNIGHT",
    ["MONK"] = "MONK",
}

---@param playerName string
---@return string
local function _GetPlayerClassColor(playerName)
    local classId = _classToIdLookup[QuestieComms.remotePlayerClasses[playerName]]
    if classId and RAID_CLASS_COLORS[classId] then
        return "|c" .. RAID_CLASS_COLORS[classId].colorStr
    end
    return "|cFFFFFFFF"
end

---@param objectiveType string
---@param spawnData table
---@return string
local function _ResolveSpawnIconTexture(objectiveType, spawnData)
    local iconType = ICON_BY_OBJECTIVE_TYPE[objectiveType]
    if not iconType and spawnData and type(spawnData.Icon) == "number" then
        iconType = spawnData.Icon
    end
    return Questie.usedIcons[iconType or Questie.ICON_TYPE_LOOT] or Questie.icons["loot"]
end

---@param questId QuestId
---@param objectiveIndex number
---@param playerKey string
---@param targetId number
---@return number
local function _BuildPartyIconId(questId, objectiveIndex, playerKey, targetId)
    local hash = 0
    for i = 1, #playerKey do
        hash = (hash * 33 + stringbyte(playerKey, i)) % 100000
    end
    local seed = ((questId or 0) % 100000) * 1000000 + ((objectiveIndex or 0) % 1000) * 1000 + ((targetId or 0) % 1000)
    return -(seed + hash + 1)
end

---@param text string|nil
---@param objectiveType string|nil
---@return boolean
local function _IsGenericObjectiveText(text, objectiveType)
    if not text then
        return true
    end
    local normalized = stringlower(tostring(text))
    return GENERIC_OBJECTIVE_TEXT[normalized] or (objectiveType and normalized == objectiveType)
end

---@param objective table
---@param objectiveData table|nil
---@param spawnData table
---@param objectiveType string|nil
---@return string
local function _ResolveObjectiveText(objective, objectiveData, spawnData, objectiveType)
    local remoteText = objective and objective.text
    if remoteText and not _IsGenericObjectiveText(remoteText, objectiveType) then
        return remoteText
    end

    local description = objectiveData and objectiveData.Description
    if description and not _IsGenericObjectiveText(description, objectiveType) then
        return description
    end

    return spawnData.Name or description or objectiveType or "Objective"
end

---@param objective table
---@param objectiveData table|nil
---@param questObjective table|nil
---@return table|nil, string|nil
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
    elseif objectiveType == "monster" then
        -- Skip NPCs not in the database to avoid error spam for unknown IDs
        -- (e.g. new NPCs added in recent patches not yet in Questie's DB)
        if not QuestieDB.QueryNPCSingle(objective.id, "name") then
            return nil, objectiveType
        end
    elseif objectiveType == "object" then
        -- Same guard for game objects
        if not QuestieDB.QueryObjectSingle(objective.id, "name") then
            return nil, objectiveType
        end
    end

    local fakeObjective = {
        Description = objectiveData and objectiveData.Description or "Objective",
        Coordinates = (questObjective and questObjective.Coordinates) or (objectiveData and objectiveData.Coordinates),
    }

    return spawnBuilder(objective.id, fakeObjective, objectiveData), objectiveType
end

---@param objectiveText string
---@param playerName string
---@param objective table
---@return table
local function _GetTooltipBody(objectiveText, playerName, objective)
    local progressText = tostring(objective.fulfilled or 0) .. "/" .. tostring(objective.required or 0)
    local objectiveColor = QuestieLib:GetRGBForObjective(objective)
    local playerColor = _GetPlayerClassColor(playerName)
    local line = objectiveColor .. progressText .. " " .. objectiveText .. " (" .. playerColor .. playerName .. "|r" .. objectiveColor .. ")|r"
    return { [line] = false }
end

---@param objectiveText string
---@param playerName string
---@param objective table
---@return table
local function _GetFallbackManualTooltipBody(objectiveText, playerName, objective)
    return _GetTooltipBody(objectiveText, playerName, objective)
end

---@param questId QuestId
---@param questName string
---@param objectiveIndex number
---@param objective table
---@param playerName string
local function _DrawObjective(questId, questName, objectiveIndex, objective, playerName)
    local quest = QuestieDB.GetQuest(questId)
    local objectiveData = quest and quest.ObjectiveData and quest.ObjectiveData[objectiveIndex]
    local questObjective = quest and quest.Objectives and quest.Objectives[objectiveIndex]
    local spawnList, objectiveType = _BuildSpawnList(objective, objectiveData, questObjective)
    if not spawnList then
        return
    end

    local playerKey = _GetNormalizedName(playerName) or playerName or "unknown"
    local sharedManualKey = tostring(questId) .. ":" .. tostring(objectiveIndex) .. ":" .. tostring(playerKey)

    for _, spawnData in pairs(spawnList) do
        local objectiveDescription = _ResolveObjectiveText(objective, objectiveData, spawnData, objectiveType)
        local targetId = spawnData.Id or objective.id
        if type(targetId) ~= "number" then
            targetId = 0
        end
        local iconId = _BuildPartyIconId(questId, objectiveIndex, playerKey, targetId)
        local iconTexture = _ResolveSpawnIconTexture(objectiveType, spawnData)
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
                        id = iconId,
                        manualKey = sharedManualKey .. ":" .. tostring(targetId),
                        Icon = iconTexture,
                        Name = objectiveDescription,
                        Type = REMOTE_MAP_TYPE,
                        GetIconScale = spawnData.GetIconScale or function() return 0.9 end,
                    }
                    if quest then
                        data.QuestData = quest
                        data.CustomTooltipData = {
                            Title = questId,
                            Key = sharedManualKey,
                            Body = _GetTooltipBody(objectiveDescription, playerName, objective),
                        }
                    else
                        data.ManualTooltipData = {
                            Title = questName,
                            Body = _GetFallbackManualTooltipBody(objectiveDescription, playerName, objective),
                            disableShiftToRemove = true,
                        }
                    end
                    data.IconScale = data:GetIconScale()

                    QuestieMap:DrawManualIcon(data, zone, x, y, REMOTE_MAP_TYPE)
                end
            end
        end
    end
end

---Refreshes all PartyQuests manual pins on the world map and minimap.
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

---@param enabled boolean
function PartyQuests:SetEnabled(enabled)
    _PartyQuests.enabled = enabled and true or false
    if Questie.db and Questie.db.profile then
        Questie.db.profile.partyQuestsEnabled = _PartyQuests.enabled
    end
    if _PartyQuests.enabled then
        _RefreshMapPinsFresh()
    else
        PartyQuests:RefreshMapPins()
    end
end

---@return boolean
function PartyQuests:IsEnabled()
    return _PartyQuests.enabled
end

---@param playerName string|nil
---@param shouldRefresh boolean|nil
function PartyQuests:SetFocusPlayer(playerName, shouldRefresh)
    _PartyQuests.focusPlayer = playerName
    if shouldRefresh ~= false then
        _RefreshMapPinsFresh()
    end
end

---@return string|nil
function PartyQuests:GetFocusPlayer()
    return _PartyQuests.focusPlayer
end

---Queues a debounced map refresh after remote quest-log updates.
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

---@param playerName string|nil
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

---@param playerName string
---@return string
function _PartyQuests:GetPlayerClassColor(playerName)
    return _GetPlayerClassColor(playerName)
end

---@return boolean
function PartyQuests:GetShowCompleted()
    return _PartyQuests.showCompleted
end

---@param showCompleted boolean
function PartyQuests:SetShowCompleted(showCompleted)
    _PartyQuests.showCompleted = showCompleted and true or false
    _PartyQuests.showOnlyObjectives = not _PartyQuests.showCompleted
    if Questie.db and Questie.db.profile then
        Questie.db.profile.partyQuestsShowCompleted = _PartyQuests.showCompleted
    end
    _RefreshMapPinsFresh()
end

---@return boolean
function PartyQuests:GetShowOnlyObjectives()
    return _PartyQuests.showOnlyObjectives
end

---@param showOnlyObjectives boolean
function PartyQuests:SetShowOnlyObjectives(showOnlyObjectives)
    _PartyQuests.showOnlyObjectives = showOnlyObjectives and true or false
    _PartyQuests.showCompleted = not _PartyQuests.showOnlyObjectives
    if Questie.db and Questie.db.profile then
        Questie.db.profile.partyQuestsShowCompleted = _PartyQuests.showCompleted
    end
    _RefreshMapPinsFresh()
end

---Registers PartyQuests listeners for remote quest-log updates.
function PartyQuests:Initialize()
    Questie:RegisterMessage("QC_ID_REMOTE_QUESTLOG_UPDATED", PartyQuests.QueueRefresh)
    if Questie.db and Questie.db.profile then
        _PartyQuests.enabled = Questie.db.profile.partyQuestsEnabled and true or false
        _PartyQuests.showCompleted = Questie.db.profile.partyQuestsShowCompleted and true or false
        _PartyQuests.showOnlyObjectives = not _PartyQuests.showCompleted
    end

    if periodicSyncTicker then
        periodicSyncTicker:Cancel()
    end
    periodicSyncTicker = C_Timer.NewTicker(60, function()
        if _PartyQuests.enabled then
            _RefreshMapPinsFresh()
        end
    end)
end

return PartyQuests
