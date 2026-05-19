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

local function _BuildSpawnList(objective, objectiveData)
    local objectiveType = OBJECTIVE_TYPE_LOOKUP[objective.type]
    if not objectiveType then
        return nil, nil
    end

    local spawnBuilder = QuestieQuest.private.objectiveSpawnListCallTable[objectiveType]
    if not spawnBuilder then
        return nil, objectiveType
    end

    local fakeObjective = {
        Description = objectiveData and objectiveData.Description or "Objective",
        Icon = objectiveData and objectiveData.Icon,
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
    local spawnList, objectiveType = _BuildSpawnList(objective, objectiveData)
    if not spawnList then
        return
    end

    local objectiveDescription = objectiveData and objectiveData.Description or objectiveType or "Objective"
    local iconType = ICON_BY_OBJECTIVE_TYPE[objectiveType] or Questie.ICON_TYPE_LOOT
    local sharedDataId = (questId * 1000) + objectiveIndex

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
                    if required > fulfilled then
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

    for questId, questEntries in pairs(QuestieComms.remoteQuestLogs) do
        for remotePlayerName, _ in pairs(questEntries) do
            local isMatch = (not normalizedPlayer) or (_GetNormalizedName(remotePlayerName) == normalizedPlayer)
            if isMatch and QuestieComms:CheckInGroup(remotePlayerName) then
                questCount = questCount + 1
                local questName = _GetQuestName(questId)
                Questie:Print("|cFFFF6F22[PartyQuests]|r", remotePlayerName .. ":", questName)
                break
            end
        end
    end

    if questCount == 0 then
        if playerName then
            Questie:Print("|cFFFF6F22[PartyQuests]|r", "No shared quests found for " .. playerName .. ".")
        else
            Questie:Print("|cFFFF6F22[PartyQuests]|r", "No shared party quests found.")
        end
    end
end

function PartyQuests:Initialize()
    Questie:RegisterMessage("QC_ID_REMOTE_QUESTLOG_UPDATED", PartyQuests.QueueRefresh)
end

return PartyQuests
