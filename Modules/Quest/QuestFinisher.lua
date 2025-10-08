---@class QuestFinisher
local QuestFinisher = QuestieLoader:CreateModule("QuestFinisher")

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule("ZoneDB")
---@type QuestiePlayer
local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
---@type QuestieTooltips
local QuestieTooltips = QuestieLoader:ImportModule("QuestieTooltips")
---@type QuestieMap
local QuestieMap = QuestieLoader:ImportModule("QuestieMap")

--- COMPATIBILITY ---
local IsQuestFlaggedCompleted = IsQuestFlaggedCompleted or C_QuestLog.IsQuestFlaggedCompleted

local pairs, ipairs, tostring = pairs, ipairs, tostring
local _GetIconData, _GetIcon, _GetIconScale, _RemoveDuplicateQuestTitle, _AddFinisherToMap

---@param quest Quest
function QuestFinisher.AddFinisher(quest)
    local questId = quest.Id
    Questie:Debug(Questie.DEBUG_INFO, "[QuestieQuest] Adding finisher for quest", questId)

    if (not QuestiePlayer.currentQuestlog[questId]) or
        IsQuestFlaggedCompleted(questId) or
        quest:IsComplete() == -1 or
        Questie.db.char.complete[questId] then
        -- We don't add finisher for quests that are not in the quest log or are already completed
        return
    end

    if (not quest.Finisher.NPC) and (not quest.Finisher.GameObject) then
        Questie:Debug(Questie.DEBUG_CRITICAL, "[QuestieQuest] Quest has no finisher:", questId, quest.name)
        return
    end

    if quest.Finisher.NPC then
        for i = 1, #quest.Finisher.NPC do
            local finisher = QuestieDB:GetNPC(quest.Finisher.NPC[i])
            _AddFinisherToMap(finisher, quest, "m_" .. finisher.id)
        end
    end

    if quest.Finisher.GameObject then
        local playerZone = QuestiePlayer:GetCurrentZoneId()
        for i = 1, #quest.Finisher.GameObject do
            local finisher = QuestieDB:GetObject(quest.Finisher.GameObject[i])
            _AddFinisherToMap(finisher, quest, "o_" .. finisher.id, playerZone)
        end
    end
end

---@param finisher NPC|Object
---@param quest Quest
---@param key string
---@param playerZone AreaId|nil
_AddFinisherToMap = function(finisher, quest, key, playerZone)
    -- Clear duplicate keys if they exist
    if QuestieTooltips.lookupByKey[key] then
        _RemoveDuplicateQuestTitle(quest.Id, key, finisher.name, quest.SpecialObjectives[1], playerZone)
    end

    QuestieTooltips:RegisterQuestStartTooltip(quest.Id, finisher.name, finisher.id, key)

    local finisherIcons = {}
    local finisherLocs = {}

    for finisherZone, spawns in pairs(finisher.spawns or {}) do
        if finisherZone and spawns then
            for _, coords in ipairs(spawns) do
                local data = _GetIconData(quest, finisher.name)

                if (coords[1] == -1 or coords[2] == -1) then
                    local dungeonLocation = ZoneDB:GetDungeonLocation(finisherZone)
                    if dungeonLocation then
                        for _, value in ipairs(dungeonLocation) do
                            local zone = value[1];
                            local x = value[2];
                            local y = value[3];

                            QuestieMap:DrawWorldIcon(data, zone, x, y)
                        end
                    end
                else
                    local x = coords[1];
                    local y = coords[2];


                    Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieQuest] Adding world icon as finisher:", finisherZone, x, y)
                    finisherIcons[finisherZone] = QuestieMap:DrawWorldIcon(data, finisherZone, x, y, coords[3])

                    if (not finisherLocs[finisherZone]) then
                        finisherLocs[finisherZone] = { x, y }
                    end
                end
            end
        end
    end

    if finisher.waypoints then
        for zone, waypoints in pairs(finisher.waypoints) do
            if (not ZoneDB.IsDungeonZone(zone)) then
                if (not finisherIcons[zone]) and waypoints[1] and waypoints[1][1] and waypoints[1][1][1] then
                    local data = _GetIconData(quest, finisher.name)

                    finisherIcons[zone] = QuestieMap:DrawWorldIcon(data, zone, waypoints[1][1][1], waypoints[1][1][2])
                    finisherLocs[zone] = { waypoints[1][1][1], waypoints[1][1][2] }
                end

                QuestieMap:DrawWaypoints(finisherIcons[zone], waypoints, zone)
            end
        end
    end
end

_GetIconData = function(quest, finisherName)
    return {
        Id = quest.Id,
        Icon = _GetIcon(quest),
        GetIconScale = _GetIconScale,
        IconScale = _GetIconScale(),
        Type = "complete",
        QuestData = quest,
        Name = finisherName,
        IsObjectiveNote = false,
    }
end

_GetIcon = function(quest)
    if QuestieDB.IsActiveEventQuest(quest.Id) then
        return Questie.ICON_TYPE_EVENTQUEST_COMPLETE
    elseif QuestieDB.IsPvPQuest(quest.Id) then
        return Questie.ICON_TYPE_PVPQUEST_COMPLETE
    elseif quest.IsRepeatable then
        return Questie.ICON_TYPE_REPEATABLE_COMPLETE
    end
    return Questie.ICON_TYPE_COMPLETE
end

_GetIconScale = function()
    return Questie.db.profile.availableScale or 1.3
end

-- TODO: Is this still true?
-- Certain race conditions can occur when the NPC/Objects are both the Quest Starter and Quest Finisher
-- which can result in duplicate Quest Title tooltips appearing. DrawAvailableQuest() would have already
-- registered this NPC/Object so, the appropriate tooltip lines are already present. This checks and clears
-- any duplicate keys before registering the Quest Finisher.
_RemoveDuplicateQuestTitle = function(questId, key, finisherName, specialObjective, playerZone)
    local tooltip = QuestieTooltips.GetTooltip(key, playerZone)
    if tooltip and #tooltip > 1 then
        for ttline = 1, #tooltip do
            for index, line in pairs(tooltip) do
                if ttline == index then
                    Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieQuest] AddFinisher - Removing duplicate Quest Title!")

                    -- Remove duplicate Quest Title
                    QuestieTooltips.lookupByKey[key][tostring(questId) .. " " .. finisherName] = nil

                    -- Now check to see if the dup has a Special Objective
                    local objText = string.match(line, ".*|cFFcbcbcb.*")

                    if objText then
                        local objIndex

                        -- Grab the Special Objective index
                        if specialObjective then
                            objIndex = specialObjective.Index
                        end

                        if objIndex then
                            Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieQuest] AddFinisher - Removing Special Objective!")

                            -- Remove Special Objective Text
                            QuestieTooltips.lookupByKey[key][tostring(questId) .. " " .. objIndex] = nil
                        end
                    end
                end
            end
        end
    end
end

return QuestFinisher
