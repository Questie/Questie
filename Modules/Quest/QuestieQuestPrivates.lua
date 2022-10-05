---@type QuestieQuest
local QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")
local _QuestieQuest = QuestieQuest.private

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestieCorrections
local QuestieCorrections = QuestieLoader:ImportModule("QuestieCorrections")

local function _GetIconScaleForMonster()
    return Questie.db.global.monsterScale or 1
end

local function _GetIconScaleForObject()
    return Questie.db.global.objectScale or 1
end

local function _GetIconScaleForEvent()
    return Questie.db.global.eventScale or 1.35
end

local function _GetIconScaleForLoot()
    return Questie.db.global.lootScale or 1
end


---@class SpawnListBase
---@field Name string
---@field Spawns table<AreaId, CoordPair[]>>
---@field Icon string @Icon path
---@field GetIconScale function Function to get the iconScale
---@field IconScale number Initial value returned by the GetIconScale function


---@class SpawnListTooltip
---@field TooltipKey string

---@class SpawnListObject : SpawnListBase, SpawnListTooltip
---@field Id ObjectId The ID of the Object

---@class SpawnListNPC : SpawnListBase, SpawnListTooltip
---@field Id NpcId The ID of the NPC
---@field Waypoints table<AreaId, CoordPair[]>
---@field Hostile true|boolean

---@class SpawnListItem : SpawnListBase, SpawnListTooltip, SpawnListNPC, SpawnListObject
---@field Id ObjectId|NpcId The ID of the Object or Npc
---@field ItemId ItemId The ID of the item that the spawn drops

---@class SpawnListEvent : SpawnListBase
---@field Id number The ID of the Event (Is this even used?)

local killcredit, monster, object, event, item

---@type table<"killcredit"|"monster"|"object"|"event"|"item", function>
_QuestieQuest.objectiveSpawnListCallTable = {}
---comment
---@param npcId NpcId
---@param objective any
---@param objectiveData KillObjective
---@return table<NpcId, SpawnListNPC>[]
killcredit = function(npcId, objective, objectiveData)
    ---@type SpawnListNPC[]
    local ret = {}
    for npcIdIndex = 1, #objectiveData.IdList do
        local killCreditNpcId = objectiveData.IdList[npcIdIndex]
        ret[killCreditNpcId] = monster(killCreditNpcId, objective)[killCreditNpcId]
    end
    return ret
end

---@param npcId any
---@param objective any
---@return table<NpcId, SpawnListNPC>?
monster = function(npcId, objective)
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
        Questie:Debug(Questie.DEBUG_CRITICAL, "Name missing for NPC:", npcId)
        return nil
    end

    local spawns = QuestieDB.QueryNPCSingle(npcId, "spawns")
    if (not spawns) then
        Questie:Debug(Questie.DEBUG_CRITICAL, "Spawn data missing for NPC:", npcId)
        spawns = {}
    end

    local rank = QuestieDB.QueryNPCSingle(npcId, "rank")

    local enableSpawns = not QuestieCorrections.questNPCBlacklist[npcId]
    local enableWaypoints = enableSpawns and 2 ~= rank -- a rare mob spawn. todo: option for this

    ---@type SpawnListNPC
    local monster = {
        Id = npcId,
        Name = name,
        Spawns = enableSpawns and spawns or {},
        Waypoints = enableWaypoints and QuestieDB.QueryNPCSingle(npcId, "waypoints") or {},
        Hostile = true,
        Icon = ICON_TYPE_SLAY,
        GetIconScale = _GetIconScaleForMonster,
        IconScale = _GetIconScaleForMonster(),
        TooltipKey = "m_" .. npcId, -- todo: use ID based keys
    }

    return {
        [npcId] = monster
    }
end

---comment
---@param objectId any
---@param objective any
---@return table<ObjectId, SpawnListObject>?
object = function(objectId, objective)
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
        Questie:Debug(Questie.DEBUG_CRITICAL, "Name missing for object:", objectId)
        return nil
    end

    local spawns = QuestieDB.QueryObjectSingle(objectId, "spawns")
    if (not spawns) then
        Questie:Debug(Questie.DEBUG_CRITICAL, "Spawn data missing for object:", objectId)
        spawns = {}
    end


    ---@type SpawnListObject
    local retObject = {
        Id = objectId,
        Name = name,
        Spawns = spawns,
        Icon = ICON_TYPE_OBJECT,
        GetIconScale = _GetIconScaleForObject,
        IconScale = _GetIconScaleForObject(),
        TooltipKey = "o_" .. objectId,
    }

    return {
        [objectId] = retObject
    }
end

---comment
---@param eventId any
---@param objective any
---@return { [1]: SpawnListEvent }?
event = function(eventId, objective)
    local spawns = objective.Coordinates
    if (not spawns) then
        Questie:Error("Missing event data for Objective:", objective.Description, "id:", eventId)
        spawns = {}
    end

    ---@type SpawnListEvent
    local retEvent = {
        Id = eventId or 0,
        Name = objective.Description or "Event Trigger",
        Spawns = spawns,
        Icon = ICON_TYPE_EVENT,
        GetIconScale = _GetIconScaleForEvent,
        IconScale = _GetIconScaleForEvent(),
    }

    return {
        [1] = retEvent
    }
end

---comment
---@param itemId any
---@param objective any
---@return table<ItemId, SpawnListItem>?
item = function(itemId, objective)
    if (not itemId) then
        Questie:Error(
            "Corrupted objective data handed to objectiveSpawnListCallTable['item']:",
            "'" .. objective.Description .. "' -",
            "Please report this error on Discord or GitHub."
        )
        return nil
    end

    local ret = {}
    local item = QuestieDB:GetItem(itemId)
    if item and item.Sources and (not item.Hidden) then
        for _, source in pairs(item.Sources) do
            if _QuestieQuest.objectiveSpawnListCallTable[source.Type] and source.Type ~= "item" then -- anti-recursive-loop check, should never be possible but would be bad if it was
                local sourceList = _QuestieQuest.objectiveSpawnListCallTable[source.Type](source.Id, objective)
                if not sourceList then
                    Questie:Error("Missing objective data for", source.Type, "'", objective, "'", source.Id)
                else
                    for id, sourceData in pairs(sourceList) do
                        if (not ret[id]) then
                            ret[id] = {
                                Id = id,
                                Name = sourceData.Name,
                                Hostile = true,
                                ItemId = item.Id,
                                TooltipKey = sourceData.TooltipKey,
                            }
                            ret[id].Spawns = {}
                            ret[id].Waypoints = {}
                            if source.Type == "object" then
                                ret[id].Icon = ICON_TYPE_OBJECT
                                ret[id].GetIconScale = _GetIconScaleForObject
                                ret[id].IconScale = _GetIconScaleForObject()
                            else
                                ret[id].Icon = (
                                    (not QuestieDB.fakeTbcItemStartId) or itemId < QuestieDB.fakeTbcItemStartId) and
                                    ICON_TYPE_LOOT or ICON_TYPE_EVENT
                                ret[id].GetIconScale = _GetIconScaleForLoot
                                ret[id].IconScale = _GetIconScaleForLoot()
                            end
                        end
                        if sourceData.Spawns then
                            for zone, spawns in pairs(sourceData.Spawns) do
                                if (not ret[id].Spawns[zone]) then
                                    ret[id].Spawns[zone] = {}
                                end
                                for _, spawn in pairs(spawns) do
                                    tinsert(ret[id].Spawns[zone], spawn)
                                end
                            end
                        end
                        if sourceData.Waypoints then
                            for zone, spawns in pairs(sourceData.Waypoints) do
                                if (not ret[id].Waypoints[zone]) then
                                    ret[id].Waypoints[zone] = {}
                                end
                                for _, spawn in pairs(spawns) do
                                    tinsert(ret[id].Waypoints[zone], spawn)
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

_QuestieQuest.objectiveSpawnListCallTable["killcredit"] = killcredit
_QuestieQuest.objectiveSpawnListCallTable["monster"] = monster
_QuestieQuest.objectiveSpawnListCallTable["object"] = object
_QuestieQuest.objectiveSpawnListCallTable["event"] = event
_QuestieQuest.objectiveSpawnListCallTable["item"] = item
