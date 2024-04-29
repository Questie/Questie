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

local dungeons = ZoneDB:GetDungeons()

local _CalculateAvailableQuests, _DrawChildQuests, _AddStarter, _DrawAvailableQuest, _GetQuestIcon, _GetIconScaleForAvailable, _HasProperDistanceToAlreadyAddedSpawns

---@param callback function | nil
function AvailableQuests.CalculateAndDrawAll(callback)
    Questie:Debug(Questie.DEBUG_INFO, "[AvailableQuests.CalculateAndDrawAll]")

    --? Cancel the previously running timer to not have multiple running at the same time
    if timer then
        timer:Cancel()
    end
    timer = ThreadLib.Thread(_CalculateAvailableQuests, 0, "Error in AvailableQuests.CalculateAndDrawAll", callback)
end

--Draw a single available quest, it is used by the CalculateAndDrawAll function.
---@param quest Quest
function AvailableQuests.DrawAvailableQuest(quest) -- prevent recursion
    --? Some quests can be started by both an NPC and a GameObject

    if quest.Starts["GameObject"] then
        local gameObjects = quest.Starts["GameObject"]
        for i = 1, #gameObjects do
            local obj = QuestieDB:GetObject(gameObjects[i])

            _AddStarter(obj, quest, "o_" .. obj.id)
        end
    end
    if (quest.Starts["NPC"]) then
        local npcs = quest.Starts["NPC"]
        for i = 1, #npcs do
            local npc = QuestieDB:GetNPC(npcs[i])

            _AddStarter(npc, quest, "m_" .. npc.id)
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

_CalculateAvailableQuests = function()
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
    local activeChildQuests = QuestieDB.activeChildQuests

    -- We create a local function here to improve readability but use the localized variables above.
    -- The order of checks is important here to bring the speed to a max
    local function _DrawQuestIfAvailable(questId)
        if (autoBlacklist[questId] or       -- Don't show autoBlacklist quests marked as such by IsDoable
            completedQuests[questId] or     -- Don't show completed quests
            hiddenQuests[questId] or        -- Don't show blacklisted quests
            hidden[questId] or              -- Don't show quests hidden by the player
            activeChildQuests[questId]      -- We already drew this quest in a previous loop iteration
        ) then
            return
        end

        if currentQuestlog[questId] then
            _DrawChildQuests(questId, currentQuestlog, completedQuests)

            if QuestieDB.IsComplete(questId) ~= -1 then -- The quest in the quest log is not failed, so we don't show it as available
                return
            end
        end

        if (
            ((not showRepeatableQuests) and QuestieDB.IsRepeatable(questId)) or     -- Don't show repeatable quests if option is disabled
            ((not showPvPQuests) and QuestieDB.IsPvPQuest(questId)) or              -- Don't show PvP quests if option is disabled
            ((not showDungeonQuests) and QuestieDB.IsDungeonQuest(questId)) or      -- Don't show dungeon quests if option is disabled
            ((not showRaidQuests) and QuestieDB.IsRaidQuest(questId)) or            -- Don't show raid quests if option is disabled
            ((not showAQWarEffortQuests) and aqWarEffortQuests[questId]) or         -- Don't show AQ War Effort quests if the option disabled
            (Questie.IsClassic and currentIsleOfQuelDanasQuests[questId]) or        -- Don't show Isle of Quel'Danas quests for Era/HC/SoX
            (Questie.IsSoD and QuestieDB.IsRuneAndShouldBeHidden(questId))          -- Don't show SoD Rune quests with the option disabled
        ) then
            return
        end

        if (
            (not QuestieDB.IsLevelRequirementsFulfilled(questId, minLevel, maxLevel, playerLevel)) or
            (not QuestieDB.IsDoable(questId, debugEnabled))
        ) then
            --If the quests are not within level range we want to unload them
            --(This is for when people level up or change settings etc)

            if availableQuests[questId] then
                QuestieMap:UnloadQuestFrames(questId)
                QuestieTooltips:RemoveQuest(questId)
            end
            return
        end

        availableQuests[questId] = true

        if QuestieMap.questIdFrames[questId] then
            -- We already drew this quest so we might need to update the icon (config changed/level up)
            for _, frame in ipairs(QuestieMap:GetFramesForQuest(questId)) do
                if frame and frame.data and frame.data.QuestData then
                    local newIcon = _GetQuestIcon(frame.data.QuestData)

                    if newIcon ~= frame.data.Icon then
                        frame:UpdateTexture(Questie.usedIcons[newIcon])
                    end
                end
            end
            return
        end

        _DrawAvailableQuest(questId)
    end

    local questCount = 0
    for questId in pairs(questData) do
        _DrawQuestIfAvailable(questId)

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
_DrawChildQuests = function(questId, currentQuestlog, completedQuests)
    local childQuests = QuestieDB.QueryQuestSingle(questId, "childQuests")
    if (not childQuests) then
        return
    end

    for _, childQuestId in pairs(childQuests) do
        if (not completedQuests[childQuestId]) and (not currentQuestlog[childQuestId]) then
            local childQuestExclusiveTo = QuestieDB.QueryQuestSingle(childQuestId, "exclusiveTo")
            local blockedByExclusiveTo = false
            for _, exclusiveToQuestId in pairs(childQuestExclusiveTo or {}) do
                if QuestiePlayer.currentQuestlog[exclusiveToQuestId] or completedQuests[exclusiveToQuestId] then
                    blockedByExclusiveTo = true
                    break
                end
            end
            if (not blockedByExclusiveTo) then
                QuestieDB.activeChildQuests[childQuestId] = true
                availableQuests[childQuestId] = true
                -- Draw them right away and skip all other irrelevant checks
                _DrawAvailableQuest(childQuestId)
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

---@param quest Quest
_GetQuestIcon = function(quest)
    if Questie.IsSoD == true and QuestieDB.IsSoDRuneQuest(quest.Id) then
        return Questie.ICON_TYPE_SODRUNE
    elseif QuestieDB.IsActiveEventQuest(quest.Id) then
        return Questie.ICON_TYPE_EVENTQUEST
    end
    if QuestieDB.IsPvPQuest(quest.Id) then
        return Questie.ICON_TYPE_PVPQUEST
    end
    if quest.requiredLevel > QuestiePlayer.GetPlayerLevel() then
        return Questie.ICON_TYPE_AVAILABLE_GRAY
    end
    if quest.IsRepeatable then
        return Questie.ICON_TYPE_REPEATABLE
    end
    if (QuestieDB.IsTrivial(quest.level)) then
        return Questie.ICON_TYPE_AVAILABLE_GRAY
    end
    return Questie.ICON_TYPE_AVAILABLE
end

---@param starter table Either an object or an NPC
---@param quest Quest
---@param tooltipKey string the tooltip key. For objects it's "o_<ID>", for NPCs it's "m_<ID>"
_AddStarter = function(starter, quest, tooltipKey)
    if (not starter) then
        return
    end

    QuestieTooltips:RegisterQuestStartTooltip(quest.Id, starter.name, starter.id, tooltipKey)

    local starterIcons = {}
    local starterLocs = {}
    for zone, spawns in pairs(starter.spawns or {}) do
        local alreadyAddedSpawns = {}
        if (zone and spawns) then
            local coords
            for spawnIndex = 1, #spawns do
                coords = spawns[spawnIndex]
                if #spawns == 1 or _HasProperDistanceToAlreadyAddedSpawns(coords, alreadyAddedSpawns) then
                    local data = {
                        Id = quest.Id,
                        Icon = _GetQuestIcon(quest),
                        GetIconScale = _GetIconScaleForAvailable,
                        IconScale = _GetIconScaleForAvailable(),
                        Type = "available",
                        QuestData = quest,
                        Name = starter.name,
                        IsObjectiveNote = false,
                    }

                    if (coords[1] == -1 or coords[2] == -1) then
                        local dungeonLocation = ZoneDB:GetDungeonLocation(zone)
                        if dungeonLocation then
                            for _, value in ipairs(dungeonLocation) do
                                QuestieMap:DrawWorldIcon(data, value[1], value[2], value[3])
                            end
                        end
                    else
                        local icon = QuestieMap:DrawWorldIcon(data, zone, coords[1], coords[2])
                        if starter.waypoints then
                            -- This is only relevant for waypoint drawing
                            starterIcons[zone] = icon
                            if not starterLocs[zone] then
                                starterLocs[zone] = { coords[1], coords[2] }
                            end
                        end
                        tinsert(alreadyAddedSpawns, coords)
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
                    local data = {
                        Id = quest.Id,
                        Icon = _GetQuestIcon(quest),
                        GetIconScale = _GetIconScaleForAvailable,
                        IconScale = _GetIconScaleForAvailable(),
                        Type = "available",
                        QuestData = quest,
                        Name = starter.name,
                        IsObjectiveNote = false,
                    }
                    starterIcons[zone] = QuestieMap:DrawWorldIcon(data, zone, waypoints[1][1][1], waypoints[1][1][2])
                    starterLocs[zone] = { waypoints[1][1][1], waypoints[1][1][2] }
                end
                QuestieMap:DrawWaypoints(starterIcons[zone], waypoints, zone)
            end
        end
    end
end

_HasProperDistanceToAlreadyAddedSpawns = function(coords, alreadyAddedSpawns)
    for _, alreadyAdded in pairs(alreadyAddedSpawns) do
        local distance = QuestieLib.GetSpawnDistance(alreadyAdded, coords)
        -- 29 seems like a good distance. The "Undying Laborer" in Westfall shows both spawns for the "Horn of Lordaeron" rune
        if distance < 29 then
            return false
        end
    end
    return true
end

_GetIconScaleForAvailable = function()
    return Questie.db.profile.availableScale or 1.3
end
