---@class PartyObjectiveDrawer : QuestieModule
local PartyObjectiveDrawer = QuestieLoader:CreateModule("PartyObjectiveDrawer")
-------------------------
--Import modules.
-------------------------
---@type QuestieQuest
local QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")

local NOP_FUNCTION = function() end

-- Total ceiling on the number of party objective map-icons, independent of the per-objective
-- icon limit, so a crowded zone with a full group can't flood the map.
local MAX_PARTY_ICONS = 500

-- drawnByQuest[questId] = { objectives = { synthetic objective tables }, iconCount = number }
-- Tracked per quest so we can clear/redraw a single quest incrementally and account for the
-- icon budget.
local drawnByQuest = {}
-- spawnListCache[questId][objectiveIndex] = spawnList. Spawn data is static (DB + the
-- objective's icon, both constant per questId+objectiveIndex), so it is built once and reused.
local spawnListCache = {}
-- Running total of party map-icons currently drawn, compared against MAX_PARTY_ICONS.
local drawnIconCount = 0

---@param objective table
---@return number @the number of map-icons this objective drew
local function _CountIcons(objective)
    local count = 0
    for _, spawn in pairs(objective.AlreadySpawned) do
        count = count + #spawn.mapRefs
    end
    return count
end

-- Unload an objective's icons. We only unload an icon if it still holds the exact data table
-- we drew it with: party icons are keyed by questId in QuestieMap.questIdFrames, the same key
-- the local player's own quest uses, so an icon may have already been unloaded and recycled.
-- _Qframe.Unload sets `data = nil` on unload, so unloaded/reused frames are skipped.
---@param objective table
local function _UnloadObjective(objective)
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

-- Build the runtime objective table PopulateObjective consumes from a generator descriptor.
---@param descriptor PartyObjectiveDescriptor
---@return table
local function _BuildObjective(descriptor)
    return {
        Id = descriptor.Id,
        Type = descriptor.Type,
        Index = descriptor.Index,
        questId = descriptor.questId,
        Description = descriptor.Description,
        FullDescription = descriptor.FullDescription,
        Icon = descriptor.Icon,
        Coordinates = descriptor.Coordinates,
        Completed = false,
        AlreadySpawned = {},
        Update = NOP_FUNCTION,
        -- Marks this as a party member's objective (the local player does not have the
        -- quest), so the map tooltip doesn't label it with the local player's name.
        IsPartyObjective = true,
        -- Skip in-world unit/item tooltip registration; the map icon tooltip already
        -- shows party members via QuestieComms, and this avoids leaking tooltip entries.
        hasRegisteredTooltips = true,
        registeredItemTooltips = true,
    }
end

---@param questId number
function PartyObjectiveDrawer:ClearQuest(questId)
    local entry = drawnByQuest[questId]
    if not entry then
        return
    end
    for _, objective in pairs(entry.objectives) do
        _UnloadObjective(objective)
    end
    drawnIconCount = drawnIconCount - entry.iconCount
    drawnByQuest[questId] = nil
end

-- Draw a single party quest from a generator plan (assumes it has already been cleared). The
-- generator decided what should be drawn; this performs the actual addon calls (spawn building
-- via PopulateObjective, the Blizzard text prefetch, icon counting and the icon budget).
---@param plan PartyObjectiveQuestPlan
function PartyObjectiveDrawer:DrawQuest(plan)
    if drawnIconCount >= MAX_PARTY_ICONS then
        return
    end

    local questId = plan.questId
    local quest = plan.quest
    local drawn = {}
    local iconCount = 0

    for _, descriptor in ipairs(plan.objectives) do
        if drawnIconCount + iconCount >= MAX_PARTY_ICONS then
            break
        end

        local objective = _BuildObjective(descriptor)

        -- Pre-fill from cache so PopulateObjective skips rebuilding the spawn list.
        local cachedSpawnList = spawnListCache[questId] and spawnListCache[questId][descriptor.Index]
        objective.spawnList = cachedSpawnList or {}

        -- must be p-called (matches how QuestieQuest calls it internally)
        local ok, err = pcall(QuestieQuest.PopulateObjective, QuestieQuest, quest, descriptor.Index, objective, true)
        if ok then
            local objectiveIconCount = _CountIcons(objective)
            if drawnIconCount + iconCount + objectiveIconCount > MAX_PARTY_ICONS then
                _UnloadObjective(objective)
                break
            end
            if (not cachedSpawnList) and objective.spawnList and next(objective.spawnList) then
                if not spawnListCache[questId] then
                    spawnListCache[questId] = {}
                end
                spawnListCache[questId][descriptor.Index] = objective.spawnList
            end
            drawn[#drawn + 1] = objective
            iconCount = iconCount + objectiveIconCount
        else
            Questie:Debug(Questie.DEBUG_ELEVATED, "[PartyObjectiveDrawer] Error populating party objective for quest", questId, "objective", descriptor.Index, err)
        end
    end

    -- Special objectives are drawn after the standard ones. They never carry a spawn cache, but
    -- enforce the same icon cap as the standard path so a special objective can't overshoot it.
    for _, descriptor in ipairs(plan.specialObjectives) do
        if drawnIconCount + iconCount >= MAX_PARTY_ICONS then
            break
        end

        local objective = _BuildObjective(descriptor)
        -- Reuse the DB-built spawn list read-only; PopulateObjective builds it from
        -- Type/Id when absent (the required-source-item case).
        objective.spawnList = descriptor.spawnList or {}

        local ok = pcall(QuestieQuest.PopulateObjective, QuestieQuest, quest, descriptor.Index, objective, true)
        if ok then
            local objectiveIconCount = _CountIcons(objective)
            if drawnIconCount + iconCount + objectiveIconCount > MAX_PARTY_ICONS then
                _UnloadObjective(objective)
                break
            end
            drawn[#drawn + 1] = objective
            iconCount = iconCount + objectiveIconCount
        end
    end

    if #drawn > 0 then
        drawnByQuest[questId] = { objectives = drawn, iconCount = iconCount }
        drawnIconCount = drawnIconCount + iconCount
    end
end

-- Unload all party objective icons and forget them.
function PartyObjectiveDrawer:ClearAll()
    for _, entry in pairs(drawnByQuest) do
        for _, objective in pairs(entry.objectives) do
            _UnloadObjective(objective)
        end
    end
    drawnByQuest = {}
    drawnIconCount = 0
end

return PartyObjectiveDrawer
