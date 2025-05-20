---@class AvailableQuests
local AvailableQuests = QuestieLoader:CreateModule("AvailableQuests")

---@type ThreadLib
local ThreadLib = QuestieLoader:ImportModule("ThreadLib")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule("ZoneDB")
---@type QuestiePlayer
local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
---@type QuestieMap
local QuestieMap = QuestieLoader:ImportModule("QuestieMap")
---@type QuestieTooltips
local QuestieTooltips = QuestieLoader:ImportModule("QuestieTooltips")
---@type QuestieCorrections
local QuestieCorrections = QuestieLoader:ImportModule("QuestieCorrections")
---@type QuestieQuestBlacklist
local QuestieQuestBlacklist = QuestieLoader:ImportModule("QuestieQuestBlacklist")
---@type IsleOfQuelDanas
local IsleOfQuelDanas = QuestieLoader:ImportModule("IsleOfQuelDanas")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")

local GetQuestGreenRange = GetQuestGreenRange
local yield = coroutine.yield
local tinsert = table.insert
local NewThread = ThreadLib.ThreadSimple

local QUESTS_PER_YIELD = 24

--- Used to keep track of the active timer for CalculateAndDrawAll
---@type Ticker|nil
local timer

-- Keep track of all available quests to unload undoable when abandoning a quest
local availableQuests = {}

local dungeons
local playerFaction
local QIsComplete, IsLevelRequirementsFulfilled, IsDoable = QuestieDB.IsComplete, AvailableQuests.IsLevelRequirementsFulfilled, QuestieDB.IsDoable

local _CalculateAndDrawAvailableQuests, _DrawChildQuests, _AddStarter, _DrawAvailableQuest, _GetIconScaleForAvailable, _HasProperDistanceToAlreadyAddedSpawns

function AvailableQuests.Initialize()
    Questie:Debug(Questie.DEBUG_DEVELOP, "AvailableQuests: Initialize")
    dungeons = ZoneDB:GetDungeons()
    playerFaction = UnitFactionGroup("player")
end

---@param callback function | nil
function AvailableQuests.CalculateAndDrawAll(callback)
    Questie:Debug(Questie.DEBUG_INFO, "[AvailableQuests.CalculateAndDrawAll]")

    --? Cancel the previously running timer to not have multiple running at the same time
    if timer then
        timer:Cancel()
    end
    timer = ThreadLib.Thread(_CalculateAndDrawAvailableQuests, 0, "Error in AvailableQuests.CalculateAndDrawAll", callback)
end

--Draw a single available quest, it is used by the CalculateAndDrawAll function.
---@param quest Quest
function AvailableQuests.DrawAvailableQuest(quest) -- prevent recursion
    --? Some quests can be started by both an NPC and a GameObject

    local added = 0
    local limit = Questie.db.profile.availableIconLimit
    if quest.Starts.Item then
        local items = quest.Starts.Item
        for i = 1, #items do
            local item = QuestieDB:GetItem(quest.Starts.Item[i])

            if (not item) then
                -- TODO: This check can be removed once the DB is fixed
                Questie:Error("Item not found for quest", quest.Id, "Item ID:", items[i], "- Please report this on Github or Discord!")
                return
            end

            if item.npcDrops then
                for _, npc in ipairs(item.npcDrops) do
                    local no = QuestieDB:GetNPC(npc)
                    if limit == 0 or added < limit then
                        added = added + _AddStarter(no, quest, "im_"..npc, (limit == 0 and 0) or (limit - added))
                    else
                        QuestieTooltips:RegisterQuestStartTooltip(quest.Id, no.name, npc, "m_"..npc)
                    end
                end
            end
            if item.objectDrops then
                for _, obj in ipairs(item.objectDrops) do
                    local oo = QuestieDB:GetObject(obj)
                    if limit == 0 or added < limit then
                        added = added + _AddStarter(oo, quest, "io_"..obj, (limit == 0 and 0) or (limit - added))
                    else
                        QuestieTooltips:RegisterQuestStartTooltip(quest.Id, oo.name, obj, "o_"..obj)
                    end
                end
            end
        end
    end
    if quest.Starts.GameObject then
        local gameObjects = quest.Starts.GameObject
        for i = 1, #gameObjects do
            local obj = QuestieDB:GetObject(gameObjects[i])

            if (not obj) then
                -- TODO: This check can be removed once the DB is fixed
                Questie:Error("Object not found for quest", quest.Id, "Object ID:", gameObjects[i], "- Please report this on Github or Discord!")
                return
            end

            if limit == 0 or added < limit then
                added = added + _AddStarter(obj, quest, "o_" .. obj.id, (limit == 0 and 0) or (limit - added))
            else
                QuestieTooltips:RegisterQuestStartTooltip(quest.Id, obj.name, obj.id, "o_"..obj.id)
            end
        end
    end
    if (quest.Starts.NPC) then
        local npcs = quest.Starts.NPC
        for i = 1, #npcs do
            local npc = QuestieDB:GetNPC(npcs[i])

            if (not npc) then
                -- TODO: This check can be removed once the DB is fixed
                Questie:Error("NPC not found for quest", quest.Id, "NPC ID:", npcs[i], "- Please report this on Github or Discord!")
                return
            end

            if limit == 0 or added < limit then
                added = added + _AddStarter(npc, quest, "m_" .. npc.id, (limit == 0 and 0) or (limit - added))
            else
                QuestieTooltips:RegisterQuestStartTooltip(quest.Id, npc.name, npc.id, "m_"..npc.id)
            end
        end
    end
end

function AvailableQuests.UnloadUndoable()
    for questId, _ in pairs(availableQuests) do
        if (not QuestieDB.IsDoable(questId)) then
            QuestieMap:UnloadQuestFrames(questId)
        end
    end
end

_CalculateAndDrawAvailableQuests = function()
    -- Localize the variables for speeeeed
    local debugEnabled = Questie.db.profile.debugEnabled

    local questData = QuestieDB.QuestPointers or QuestieDB.questData

    local playerLevel = QuestiePlayer.GetPlayerLevel()
    local minLevel = playerLevel - GetQuestGreenRange("player")
    local maxLevel = playerLevel

    if Questie.db.profile.lowLevelStyle == Questie.LOWLEVEL_RANGE then
        minLevel = Questie.db.profile.minLevelFilter
        maxLevel = Questie.db.profile.maxLevelFilter
    elseif Questie.db.profile.lowLevelStyle == Questie.LOWLEVEL_OFFSET then
        minLevel = playerLevel - Questie.db.profile.manualLevelOffset
    end

    local completedQuests = Questie.db.char.complete
    local showRepeatableQuests = Questie.db.profile.showRepeatableQuests
    local showDungeonQuests = Questie.db.profile.showDungeonQuests
    local showRaidQuests = Questie.db.profile.showRaidQuests
    local showPvPQuests = Questie.db.profile.showPvPQuests
    local showAQWarEffortQuests = Questie.db.profile.showAQWarEffortQuests

    local autoBlacklist = QuestieDB.autoBlacklist
    local hiddenQuests = QuestieCorrections.hiddenQuests
    local hidden = Questie.db.char.hidden

    local currentQuestlog = QuestiePlayer.currentQuestlog
    local currentIsleOfQuelDanasQuests = IsleOfQuelDanas.quests[Questie.db.profile.isleOfQuelDanasPhase] or {}
    local aqWarEffortQuests = QuestieQuestBlacklist.AQWarEffortQuests

    QuestieDB.activeChildQuests = {} -- Reset here so we don't need to keep track in the quest event system

    local IsClassic = Questie.IsClassic
    local IsSoD = Questie.IsSoD

    -- We create a local function here to improve readability but use the localized variables above.
    -- The order of checks is important here to bring the speed to a max
    local function _CheckAvailability(questId)
        if (autoBlacklist[questId] or       -- Don't show autoBlacklist quests marked as such by IsDoable
            completedQuests[questId] or     -- Don't show completed quests
            hiddenQuests[questId] or        -- Don't show blacklisted quests
            hidden[questId]                 -- Don't show quests hidden by the player
        ) then
            availableQuests[questId] = nil
            return
        end

        if currentQuestlog[questId] then
            _DrawChildQuests(questId, currentQuestlog, completedQuests, hiddenQuests)

            if QIsComplete(questId) ~= -1 then -- The quest in the quest log is not failed, so we don't show it as available
                availableQuests[questId] = nil
                return
            end
        end

        if (
            ((not showRepeatableQuests) and QuestieDB.IsRepeatable(questId)) or     -- Don't show repeatable quests if option is disabled
            ((not showPvPQuests) and QuestieDB.IsPvPQuest(questId)) or              -- Don't show PvP quests if option is disabled
            ((not showDungeonQuests) and QuestieDB.IsDungeonQuest(questId)) or      -- Don't show dungeon quests if option is disabled
            ((not showRaidQuests) and QuestieDB.IsRaidQuest(questId)) or            -- Don't show raid quests if option is disabled
            ((not showAQWarEffortQuests) and aqWarEffortQuests[questId]) or         -- Don't show AQ War Effort quests if the option disabled
            (IsClassic and currentIsleOfQuelDanasQuests[questId]) or        -- Don't show Isle of Quel'Danas quests for Era/HC/SoX
            (IsSoD and QuestieDB.IsRuneAndShouldBeHidden(questId))          -- Don't show SoD Rune quests with the option disabled
        ) then
            availableQuests[questId] = nil
            return
        end

        if (
            (not IsLevelRequirementsFulfilled(questId, minLevel, maxLevel, playerLevel)) or
            (not IsDoable(questId, debugEnabled))
        ) then
            --If the quests are not within level range we want to unload them
            --(This is for when people level up or change settings etc)

            if availableQuests[questId] then
                QuestieMap:UnloadQuestFrames(questId)
                QuestieTooltips:RemoveQuest(questId)
            end
            availableQuests[questId] = nil
            return
        end

        availableQuests[questId] = true
    end

    for questId in pairs(questData) do
        _CheckAvailability(questId)
    end

    local questCount = 0
    for questId in pairs(availableQuests) do
        if QuestieMap.questIdFrames[questId] then
            -- We already drew this quest so we might need to update the icon (config changed/level up)
            QuestieMap.UpdateDrawnIcons(questId)
        else
            _DrawAvailableQuest(questId)
        end

        -- Reset the questCount
        questCount = questCount + 1
        if questCount > QUESTS_PER_YIELD then
            questCount = 0
            yield()
        end
    end
end

--- Mark all child quests as active when the parent quest is in the quest log
---@param questId number
---@param currentQuestlog table<number, boolean>
---@param completedQuests table<number, boolean>
_DrawChildQuests = function(questId, currentQuestlog, completedQuests, hiddenQuests)
    local childQuests = QuestieDB.QueryQuestSingle(questId, "childQuests")
    if (not childQuests) then
        return
    end

    for _, childQuestId in pairs(childQuests) do
        if (not completedQuests[childQuestId]) and (not currentQuestlog[childQuestId]) and (not hiddenQuests[childQuestId]) then
            local childQuestExclusiveTo = QuestieDB.QueryQuestSingle(childQuestId, "exclusiveTo")
            local blockedByExclusiveTo = false
            for _, exclusiveToQuestId in pairs(childQuestExclusiveTo or {}) do
                if QuestiePlayer.currentQuestlog[exclusiveToQuestId] or completedQuests[exclusiveToQuestId] then
                    blockedByExclusiveTo = true
                    break
                end
            end
            if (not blockedByExclusiveTo) then
                local isPreQuestSingleFulfilled = true
                local isPreQuestGroupFulfilled = true

                local preQuestSingle = QuestieDB.QueryQuestSingle(childQuestId, "preQuestSingle")
                if preQuestSingle then
                    isPreQuestSingleFulfilled = QuestieDB:IsPreQuestSingleFulfilled(preQuestSingle)
                else
                    local preQuestGroup = QuestieDB.QueryQuestSingle(childQuestId, "preQuestGroup")
                    if preQuestGroup then
                        isPreQuestGroupFulfilled = QuestieDB:IsPreQuestGroupFulfilled(preQuestGroup)
                    end
                end

                if isPreQuestSingleFulfilled and isPreQuestGroupFulfilled then
                    QuestieDB.activeChildQuests[childQuestId] = true
                    availableQuests[childQuestId] = true
                    -- Draw them right away and skip all other irrelevant checks
                    _DrawAvailableQuest(childQuestId)
                end
            end
        end
    end
end

---@param questId number
_DrawAvailableQuest = function(questId)
    NewThread(function()
        local quest = QuestieDB.GetQuest(questId)
        if (not quest.tagInfoWasCached) then
            QuestieDB.GetQuestTagInfo(questId) -- cache to load in the tooltip

            quest.tagInfoWasCached = true
        end

        AvailableQuests.DrawAvailableQuest(quest)
    end, 0)
end

-- TODO: RawObject|RawNPC is not 100% correct, as it is the result from GetNPC and GetObject
---@param starter RawObject|RawNPC Either an object or an NPC from QuestieDB.
---@param quest Quest A Quest from QuestieDB.
---@param tooltipKey string The tooltip key. For objects it's "o_<ID>", for NPCs it's "m_<ID>", for items it's "im_<ID>" or "io_<ID".
---@param limit number The number of icons left to draw before the limit set in AvailableQuests.DrawAvailableQuest is reached. Zero means no limit.
---@return number added The amount of notes that were added (excluding waypoints)
_AddStarter = function(starter, quest, tooltipKey, limit)
    if (not starter) then
        return 0
    end

    -- Need to know when this quest starts from an item, so we save it later
    ---@type string|nil
    local starterType

    if tooltipKey == "m_"..starter.id then
        -- filter hostile starters
        if playerFaction == "Alliance" and starter.friendlyToFaction == "H" then
            return 0
        elseif playerFaction == "Horde" and starter.friendlyToFaction == "A" then
            return 0
        end
    elseif tooltipKey == "im_"..starter.id then
        -- filter drops from friendlies
        if playerFaction == "Alliance" and starter.friendlyToFaction == "A" then
            return 0
        elseif playerFaction == "Horde" and starter.friendlyToFaction == "H" then
            return 0
        elseif starter.friendlyToFaction == "AH" then
            return 0
        end
        -- overwrite tooltipKey, so stuff shows in monster tooltips
        tooltipKey = "m_"..starter.id
        starterType = "itemFromMonster"
    elseif tooltipKey == "io_"..starter.id then
        -- overwrite tooltipKey, so stuff shows in object tooltips
        tooltipKey = "o_"..starter.id
        starterType = "itemFromObject"
    end

    QuestieTooltips:RegisterQuestStartTooltip(quest.Id, starter.name, starter.id, tooltipKey)

    local starterIcons = {}
    local starterLocs = {}
    local added = 0
    for zone, spawns in pairs(starter.spawns or {}) do
        local alreadyAddedSpawns = {}
        if (zone and spawns) then
            local coords
            for spawnIndex = 1, #spawns do
                coords = spawns[spawnIndex]
                if (#spawns == 1 or _HasProperDistanceToAlreadyAddedSpawns(coords, alreadyAddedSpawns)) and (limit == 0  or limit-added>0) then
                    ---@class IconData
                    local data = {
                        Id = quest.Id,
                        Icon =  QuestieLib.GetQuestIcon(quest),
                        GetIconScale = _GetIconScaleForAvailable,
                        IconScale = _GetIconScaleForAvailable(),
                        Type = "available",
                        QuestData = quest,
                        Name = starter.name,
                        IsObjectiveNote = false,
                        StarterType = starterType,
                    }

                    if (coords[1] == -1 or coords[2] == -1) then
                        local dungeonLocation = ZoneDB:GetDungeonLocation(zone)
                        if dungeonLocation then
                            for _, value in ipairs(dungeonLocation) do
                                QuestieMap:DrawWorldIcon(data, value[1], value[2], value[3])
                                added = added + 1
                            end
                        end
                    else
                        local icon = QuestieMap:DrawWorldIcon(data, zone, coords[1], coords[2], coords[3])
                        if starter.waypoints then
                            -- This is only relevant for waypoint drawing
                            starterIcons[zone] = icon
                            if not starterLocs[zone] then
                                starterLocs[zone] = { coords[1], coords[2] }
                            end
                        end
                        if icon then
                            tinsert(alreadyAddedSpawns, coords)
                            added = added + 1
                        end
                    end
                end
            end
        end
    end

    -- Only for NPCs since objects do not move
    if starter.waypoints then
        for zone, waypoints in pairs(starter.waypoints or {}) do
            if not dungeons[zone] and waypoints[1] and waypoints[1][1] and waypoints[1][1][1] then
                if not starterIcons[zone] then
                    ---@class IconData
                    local data = {
                        Id = quest.Id,
                        Icon =  QuestieLib.GetQuestIcon(quest),
                        GetIconScale = _GetIconScaleForAvailable,
                        IconScale = _GetIconScaleForAvailable(),
                        Type = "available",
                        QuestData = quest,
                        Name = starter.name,
                        IsObjectiveNote = false,
                        StarterType = starterType,
                    }
                    starterIcons[zone] = QuestieMap:DrawWorldIcon(data, zone, waypoints[1][1][1], waypoints[1][1][2])
                    starterLocs[zone] = { waypoints[1][1][1], waypoints[1][1][2] }
                    added = added + 1
                end
                QuestieMap:DrawWaypoints(starterIcons[zone], waypoints, zone)
            end
        end
    end
    return added
end

_HasProperDistanceToAlreadyAddedSpawns = function(coords, alreadyAddedSpawns)
    for _, alreadyAdded in pairs(alreadyAddedSpawns) do
        local distance = QuestieLib.GetSpawnDistance(alreadyAdded, coords)
        -- 28 seems like a good distance. The NPC Denalan in Teldrassil shows both spawns for the quests
        if distance < Questie.db.profile.spawnFilterDistance then
            return false
        end
    end
    return true
end

_GetIconScaleForAvailable = function()
    return Questie.db.profile.availableScale or 1.3
end

return AvailableQuests
