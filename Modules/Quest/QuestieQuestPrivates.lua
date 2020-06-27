---@type QuestieQuest
local QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")
local _QuestieQuest = QuestieQuest.private

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule("ZoneDB")
---@type QuestiePlayer
local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")


_QuestieQuest.objectiveSpawnListCallTable = {
    ["monster"] = function(id, Objective)
        local npc = QuestieDB:GetNPC(id)
        if not npc then
            -- todo: log this
            return nil
        end
        local ret = {}
        local mon = {};

        mon.Name = npc.name
        if not npc.spawns then
            Questie:Debug(DEBUG_CRITICAL, "Spawn data missing for NPC:", npc.id)
            npc.spawns = {}
        end
        mon.Spawns = npc.spawns
        mon.Icon = ICON_TYPE_SLAY
        mon.Id = id
        mon.GetIconScale = function() return Questie.db.global.monsterScale or 1 end
        mon.IconScale = mon:GetIconScale();
        mon.TooltipKey = "m_" .. id -- todo: use ID based keys

        ret[id] = mon;
        return ret
    end,
    ["object"] = function(id, Objective)
        local object = QuestieDB:GetObject(id)
        if not object then
            -- todo: log this
            return nil
        end
        local ret = {}
        local obj = {}

        obj.Name = object.name
        if not object.spawns then
            Questie:Debug(DEBUG_CRITICAL, "Spawn data missing for object:", object.id)
            object.spawns = {}
        end
        obj.Spawns = object.spawns
        obj.Icon = ICON_TYPE_LOOT
        obj.GetIconScale = function() return Questie.db.global.objectScale or 1 end
        obj.IconScale = obj:GetIconScale()
        obj.TooltipKey = "o_" .. id
        obj.Id = id

        ret[id] = obj
        return ret
    end,
    ["event"] = function(id, Objective)
        local ret = {}
        ret[1] = {};
        ret[1].Name = Objective.Description or "Event Trigger";
        ret[1].Icon = ICON_TYPE_EVENT
        ret[1].GetIconScale = function() return Questie.db.global.eventScale or 1.35 end
        ret[1].IconScale = ret[1]:GetIconScale();
        ret[1].Id = id or 0
        if Objective.Coordinates then
            ret[1].Spawns = Objective.Coordinates
        else
            ret[1].Spawns = {}
            Questie:Error("Missing event data for Objective:", Objective.Description, "id:", id)
        end
        return ret
    end,
    ["item"] = function(id, Objective)
        local ret = {};
        local item = QuestieDB:GetItem(id);
        if item ~= nil and item.Sources ~= nil and (not item.Hidden) then
            for _, source in pairs(item.Sources) do
                if _QuestieQuest.objectiveSpawnListCallTable[source.Type] and source.Type ~= "item" then -- anti-recursive-loop check, should never be possible but would be bad if it was
                    local sourceList = _QuestieQuest.objectiveSpawnListCallTable[source.Type](source.Id, Objective);
                    if sourceList == nil then
                        -- log this
                    else
                        for id, sourceData in pairs(sourceList) do
                            if not ret[id] then
                                ret[id] = {};
                                ret[id].Name = sourceData.Name;
                                ret[id].Spawns = {};
                                if source.Type == "object" then
                                    ret[id].Icon = ICON_TYPE_OBJECT
                                    ret[id].GetIconScale = function() return Questie.db.global.objectScale or 1 end
                                    ret[id].IconScale = ret[id]:GetIconScale()
                                else
                                    ret[id].Icon = ICON_TYPE_LOOT
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
