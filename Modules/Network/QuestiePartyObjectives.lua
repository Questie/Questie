---@class QuestiePartyObjectives : QuestieModule
local QuestiePartyObjectives = QuestieLoader:CreateModule("QuestiePartyObjectives")
-------------------------
--Import modules.
-------------------------
---@type QuestieComms
local QuestieComms = QuestieLoader:ImportModule("QuestieComms")
---@type QuestieQuest
local QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
---@type QuestiePlayer
local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
---@type QuestLogCache
local QuestLogCache = QuestieLoader:ImportModule("QuestLogCache")

local NOP_FUNCTION = function() end

-- The single-character objective types used in the QuestieComms packets, mapped to the
-- full type names used by the drawing pipeline and the database ObjectiveData.
local typeCharToFull = {
    ["m"] = "monster",
    ["o"] = "object",
    ["i"] = "item",
}

-- The synthetic objectives we have drawn this cycle. We keep them so we can unload exactly
-- the icons we created (their AlreadySpawned refs), without touching the local player's own
-- icons that may share the same questId key in QuestieMap.questIdFrames.
local drawnObjectives = {}

local updateScheduled = false

---@param questId number
---@return boolean @true if the local player currently has this quest in their log
local function _PlayerHasQuest(questId)
    return QuestLogCache.questLog_DO_NOT_MODIFY[questId] ~= nil
end

-- The objective needs a non-nil Description or the map icon tooltip skips it entirely
-- (see MapIconTooltip "iconData.ObjectiveData.Description" check). The compiled database
-- objective text is often empty, so fall back to the target's name.
---@param objType string
---@param objId number
---@return string?
local function _GetObjectiveName(objType, objId)
    if objType == "monster" then
        local npc = QuestieDB:GetNPC(objId)
        return npc and npc.name
    elseif objType == "object" then
        local object = QuestieDB:GetObject(objId)
        return object and object.name
    elseif objType == "item" then
        local item = QuestieDB:GetItem(objId)
        return item and item.name
    end
end

-- Unload every icon we drew for party members and forget them.
-- We only unload an icon if it still holds the exact data table we drew it with. Party
-- icons are keyed by questId in QuestieMap.questIdFrames, the same key the local player's own
-- quest uses, so an icon may have already been unloaded and recycled (e.g. the player picked
-- up or abandoned the quest). The identity check prevents us from unloading a frame that has
-- since been reused for a different quest. _Qframe.Unload sets `data = nil` on unload, so an
-- unloaded-but-not-reused frame is skipped too.
function QuestiePartyObjectives:Clear()
    for _, objective in pairs(drawnObjectives) do
        for _, spawn in pairs(objective.AlreadySpawned) do
            for _, mapIcon in pairs(spawn.mapRefs) do
                if mapIcon.data == spawn.data then
                    mapIcon:Unload()
                end
            end
            for _, minimapIcon in pairs(spawn.minimapRefs) do
                if minimapIcon.data == spawn.data then
                    minimapIcon:Unload()
                end
            end
        end
    end
    drawnObjectives = {}
end

-- Redraw all party members' quest objectives from the shared remote quest logs.
function QuestiePartyObjectives:Update()
    QuestiePartyObjectives:Clear()

    if (not Questie.db.profile.showPartyQuestObjectives) or (not QuestiePlayer:GetGroupType()) then
        return
    end

    for questId, players in pairs(QuestieComms.remoteQuestLogs) do
        -- Quests the local player has are drawn by the normal pipeline; don't double up.
        if not _PlayerHasQuest(questId) then
            -- An objective index is drawn if at least one party member still needs it.
            local neededIndices = {}
            for _, objectives in pairs(players) do
                for objectiveIndex, objective in pairs(objectives) do
                    if not objective.finished then
                        neededIndices[objectiveIndex] = objective
                    end
                end
            end

            if next(neededIndices) then
                local quest = QuestieDB.GetQuest(questId)
                if quest and quest.ObjectiveData then
                    if (not quest.Color) then
                        quest.Color = QuestieLib:ColorWheel()
                    end

                    for objectiveIndex, remoteObjective in pairs(neededIndices) do
                        -- Prefer the database ObjectiveData (it carries the canonical Type/Id); fall back to the comms-supplied id/type if the index is missing.
                        local objData = quest.ObjectiveData[objectiveIndex]
                        local objType = objData and objData.Type or typeCharToFull[remoteObjective.type]
                        local objId = objData and objData.Id or remoteObjective.id

                        if objType and objId then
                            local objective = {
                                Id = objId,
                                Type = objType,
                                Index = objectiveIndex,
                                questId = questId,
                                Description = (objData and objData.Text) or _GetObjectiveName(objType, objId) or "",
                                Icon = objData and objData.Icon,
                                Completed = false,
                                spawnList = {},
                                AlreadySpawned = {},
                                Update = NOP_FUNCTION,
                                -- Marks this as a party member's objective (the local player does not have the quest), so the map tooltip doesn't label the objective with the local player's name.
                                IsPartyObjective = true,
                                -- Don't register in-world unit/item tooltips for party objectives; the map icon tooltip already shows party members via QuestieComms. Setting these flags makes
                                -- PopulateObjective skip QuestieTooltips registration so we never leak tooltip entries across redraws.
                                hasRegisteredTooltips = true,
                                registeredItemTooltips = true,
                            }

                            -- Must be p-called (matches how QuestieQuest calls it internally)
                            local ok = pcall(QuestieQuest.PopulateObjective, QuestieQuest, quest, objectiveIndex, objective, true)
                            if ok then
                                drawnObjectives[#drawnObjectives + 1] = objective
                            end
                        end
                    end
                end
            end
        end
    end
end

-- Debounced redraw, used by the QuestieComms hooks to coalesce bursts of incoming packets.
function QuestiePartyObjectives:ScheduleUpdate()
    if updateScheduled or (not Questie.db.profile.showPartyQuestObjectives) then
        return
    end
    updateScheduled = true
    C_Timer.After(1.5, function()
        updateScheduled = false
        QuestiePartyObjectives:Update()
    end)
end

return QuestiePartyObjectives
