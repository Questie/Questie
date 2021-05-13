---@type QuestieQuest
local QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")
local _QuestieQuest = QuestieQuest.private

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestiePlayer
local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
---@type QuestieCorrections
local QuestieCorrections = QuestieLoader:ImportModule("QuestieCorrections")


_QuestieQuest.objectiveSpawnListCallTable = {
    ["killcredit"] = function(npcId, objective, objectiveData)
        local ret = {}
        for _, npc in pairs(objectiveData.IdList) do
            ret[npc] = _QuestieQuest.objectiveSpawnListCallTable["monster"](npc, objective)[npc]
        end
        return ret
    end,
    ["monster"] = function(npcId, objective)
        if (not npcId) then
            Questie:Error(
                    "Corrupted objective data handed to objectiveSpawnListCallTable['monster']:",
                    "'" .. objective.Description .. "' -",
                    "Please report this error on Discord or GitHub."
            )
            return nil
        end

        local name = QuestieDB.QueryNPCSingle(npcId, "name")

        if (not name) then
            Questie:Debug(DEBUG_CRITICAL, "Name missing for NPC:", npcId)
            return nil
        end

        local spawns = QuestieDB.QueryNPCSingle(npcId, "spawns")

        if (not spawns) then
            Questie:Debug(DEBUG_CRITICAL, "Spawn data missing for NPC:", npcId)
            spawns = {}
        end

        local rank = QuestieDB.QueryNPCSingle(npcId, "rank")

        local enableSpawns = not QuestieCorrections.questNPCBlacklist[npcId]
        local enableWaypoints = enableSpawns and 2 ~= rank -- a rare mob spawn. todo: option for this

        local _GetIconScale = function() return Questie.db.global.monsterScale or 1 end

        return {
            [npcId] = {
                Id = npcId,
                Name = name,
                Spawns = enableSpawns and QuestieDB.QueryNPCSingle(npcId, "spawns") or {},
                Waypoints = enableWaypoints and QuestieDB.QueryNPCSingle(npcId, "waypoints") or {},
                Hostile = true,
                Icon = ICON_TYPE_SLAY,
                GetIconScale = _GetIconScale,
                IconScale = _GetIconScale(),
                TooltipKey = "m_" .. npcId, -- todo: use ID based keys
            }
        }
    end,
    ["object"] = function(objectId, objective)
        if (not objectId) then
            Questie:Error(
                    "Corrupted objective data handed to objectiveSpawnListCallTable['object']:",
                    "'" .. objective.Description .. "' -",
                    "Please report this error on Discord or GitHub."
            )
            return nil
        end

        local name = QuestieDB.QueryObjectSingle(objectId, "name")

        if (not name) then
            Questie:Debug(DEBUG_CRITICAL, "Name missing for object:", objectId)
            return nil
        end

        local spawns = QuestieDB.QueryObjectSingle(objectId, "spawns")

        if (not spawns) then
            Questie:Debug(DEBUG_CRITICAL, "Spawn data missing for object:", objectId)
            spawns = {}
        end

        local _GetIconScale = function()
            return Questie.db.global.objectScale or 1
        end

        return {
            [objectId] = {
                Id = objectId,
                Name = name,
                Spawns = spawns,
                Icon = ICON_TYPE_OBJECT,
                GetIconScale = _GetIconScale,
                IconScale = _GetIconScale(),
                TooltipKey = "o_" .. objectId,
            }
        }
    end,
    ["event"] = function(id, objective)
        local spawns = {}
        if objective.Coordinates then
            spawns = objective.Coordinates
        else
            Questie:Error("Missing event data for Objective:", objective.Description, "id:", id)
        end

        local _GetIconScale = function() return Questie.db.global.eventScale or 1.35 end

        return {
            [1] = {
                Id = id or 0,
                Name = objective.Description or "Event Trigger",
                Spawns = spawns,
                Icon = ICON_TYPE_EVENT,
                GetIconScale = _GetIconScale,
                IconScale = _GetIconScale(),
            }
        }
    end,
    ["item"] = function(itemId, objective)
        if (not itemId) then
            Questie:Error(
                    "Corrupted objective data handed to objectiveSpawnListCallTable['item']:",
                    "'" .. objective.Description .. "' -",
                    "Please report this error on Discord or GitHub."
            )
            return nil
        end

        local ret = {};
        local item = QuestieDB:GetItem(itemId);
        if item ~= nil and item.Sources ~= nil and (not item.Hidden) then
            for _, source in pairs(item.Sources) do
                if _QuestieQuest.objectiveSpawnListCallTable[source.Type] and source.Type ~= "item" then -- anti-recursive-loop check, should never be possible but would be bad if it was
                    local sourceList = _QuestieQuest.objectiveSpawnListCallTable[source.Type](source.Id, objective);
                    if sourceList == nil then
                        Questie:Error("Missing objective data for", source.Type, "'", objective, "'", source.Id)
                    else
                        for id, sourceData in pairs(sourceList) do
                            if not ret[id] then
                                ret[id] = {}
                                ret[id].Name = sourceData.Name
                                ret[id].Spawns = {}
                                ret[id].Waypoints = {}
                                ret[id].Hostile = true
                                ret[id].ItemId = item.Id
                                if source.Type == "object" then
                                    ret[id].Icon = ICON_TYPE_OBJECT
                                    ret[id].GetIconScale = function() return Questie.db.global.objectScale or 1 end
                                    ret[id].IconScale = ret[id]:GetIconScale()
                                else
                                    ret[id].Icon = itemId < QuestieDB.fakeTbcItemStartId and ICON_TYPE_LOOT or ICON_TYPE_EVENT
                                    ret[id].GetIconScale = function() return Questie.db.global.lootScale or 1 end
                                    ret[id].IconScale = ret[id]:GetIconScale()
                                end
                                ret[id].TooltipKey = sourceData.TooltipKey
                                ret[id].Id = id
                            end
                            if sourceData.Spawns and not item.Hidden then
                                for zone, spawns in pairs(sourceData.Spawns) do
                                    if not ret[id].Spawns[zone] then
                                        ret[id].Spawns[zone] = {};
                                    end
                                    for _, spawn in pairs(spawns) do
                                        tinsert(ret[id].Spawns[zone], spawn);
                                    end
                                end
                            end
                            if sourceData.Waypoints and not Item.Hidden then
                                for zone, spawns in pairs(sourceData.Waypoints) do
                                    if not ret[id].Waypoints[zone] then
                                        ret[id].Waypoints[zone] = {};
                                    end
                                    for _, spawn in pairs(spawns) do
                                        tinsert(ret[id].Waypoints[zone], spawn);
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        return ret
    end
}

function _QuestieQuest:LevelRequirementsFulfilled(quest, playerLevel, minLevel, maxLevel)
    return (quest.level == 60 and quest.requiredLevel == 1) or (quest.level >= minLevel or Questie.db.char.lowlevel) and quest.level <= maxLevel and (quest.requiredLevel <= playerLevel or Questie.db.char.manualMinLevelOffset or Questie.db.char.manualMinLevelOffsetAbsolute)
end

-- We always want to show a quest if it is a childQuest and its parent is in the quest log
function _QuestieQuest:IsParentQuestActive(parentID)
    if parentID == nil or parentID == 0 then
        return false
    end
    if QuestiePlayer.currentQuestlog[parentID] then
        return true
    end
    return false
end
