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

local GetQuestGreenRange = GetQuestGreenRange
local yield = coroutine.yield
local NewThread = ThreadLib.ThreadSimple

local QUESTS_PER_YIELD = 24

--- Used to keep track of the active timer for CalculateAndDrawAll
---@type Ticker|nil
local timer

-- Keep track of all available quests to unload undoable when abandoning a quest
local availableQuests = {}

local dungeons = ZoneDB:GetDungeons()


---@param questId number
local function _DrawAvailableQuest(questId)
    NewThread(function()
        local quest = QuestieDB:GetQuest(questId)
        if (not quest.tagInfoWasCached) then
            QuestieDB.GetQuestTagInfo(questId) -- cache to load in the tooltip

            quest.tagInfoWasCached = true
        end

        AvailableQuests.DrawAvailableQuest(quest)
    end, 0)
end

---@param quest Quest
local function _GetQuestIcon(quest)
    if QuestieDB.IsActiveEventQuest(quest.Id) then
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

local function _GetIconScaleForAvailable()
    return Questie.db.global.availableScale or 1.3
end

local function _CalculateAvailableQuests()
    -- Localize the variables for speeeeed
    local debugEnabled = Questie.db.global.debugEnabled

    local questData = QuestieDB.QuestPointers or QuestieDB.questData

    local playerLevel = QuestiePlayer.GetPlayerLevel()
    local minLevel = playerLevel - GetQuestGreenRange("player")
    local maxLevel = playerLevel

    if Questie.db.char.absoluteLevelOffset then
        minLevel = Questie.db.char.minLevelFilter
        maxLevel = Questie.db.char.maxLevelFilter
    elseif Questie.db.char.manualMinLevelOffset then
        minLevel = playerLevel - Questie.db.char.minLevelFilter
    end

    local completedQuests = Questie.db.char.complete
    local showRepeatableQuests = Questie.db.char.showRepeatableQuests
    local showDungeonQuests = Questie.db.char.showDungeonQuests
    local showRaidQuests = Questie.db.char.showRaidQuests
    local showPvPQuests = Questie.db.char.showPvPQuests
    local showAQWarEffortQuests = Questie.db.char.showAQWarEffortQuests

    local autoBlacklist = QuestieDB.autoBlacklist
    local hiddenQuests = QuestieCorrections.hiddenQuests
    local hidden = Questie.db.char.hidden

    local currentQuestlog = QuestiePlayer.currentQuestlog
    local currentIsleOfQuelDanasQuests = IsleOfQuelDanas.quests[Questie.db.global.isleOfQuelDanasPhase]

    QuestieDB.activeChildQuests = {} -- Reset here so we don't need to keep track in the quest event system

    local questCount = 0
    for questId in pairs(questData) do
        --? Quick exit through autoBlacklist if IsDoable has blacklisted it.
        if (not autoBlacklist[questId]) then

            if currentQuestlog[questId] then
                -- Mark all child quests as active when the parent quest is in the quest log
                local childQuests = QuestieDB.QueryQuestSingle(questId, "childQuests")
                if childQuests then
                    for _, childQuestId in pairs(childQuests) do
                        QuestieDB.activeChildQuests[childQuestId] = true
                        availableQuests[childQuestId] = true
                        -- Draw them right away and skip all other irrelevant checks
                        _DrawAvailableQuest(childQuestId)
                    end
                end
            elseif (
                (not completedQuests[questId]) and                                                            -- Don't show completed quests
                (not QuestieDB.activeChildQuests[questId]) and                                            -- Don't show child quests again. We already did that above
                ((not currentQuestlog[questId]) or QuestieDB.IsComplete(questId) == -1) and               -- Don't show quests if they're already in the quest log
                (not hiddenQuests[questId] and not hidden[questId]) and                                   -- Don't show blacklisted or player hidden quests
                (showRepeatableQuests or (not QuestieDB.IsRepeatable(questId))) and                       -- Show repeatable quests if the quest is repeatable and the option is enabled
                (showDungeonQuests or (not QuestieDB.IsDungeonQuest(questId))) and                        -- Show dungeon quests only with the option enabled
                (showRaidQuests or (not QuestieDB.IsRaidQuest(questId))) and                              -- Show Raid quests only with the option enabled
                (showPvPQuests or (not QuestieDB.IsPvPQuest(questId))) and                                -- Show PvP quests only with the option enabled
                (showAQWarEffortQuests or (not QuestieQuestBlacklist.AQWarEffortQuests[questId])) and     -- Don't show AQ War Effort quests with the option enabled
                ((not Questie.IsWotlk) or (not currentIsleOfQuelDanasQuests[questId]))
            ) then
                if QuestieDB.IsLevelRequirementsFulfilled(questId, minLevel, maxLevel, playerLevel) and QuestieDB.IsDoable(questId, debugEnabled) then
                    availableQuests[questId] = true
                    --If the quest is not drawn draw the quest, otherwise skip.
                    if (not QuestieMap.questIdFrames[questId]) then
                        --? This looks expensive, and it kind of is but it offloads the work to a thread, which happens "next frame"
                        _DrawAvailableQuest(questId)
                    else
                        --* TODO: How the frames are handled needs to be reworked, why are we getting them from _G
                        --We might have to update the icon in this situation (config changed/level up)
                        for _, frame in ipairs(QuestieMap:GetFramesForQuest(questId)) do
                            if frame and frame.data and frame.data.QuestData then
                                local newIcon = _GetQuestIcon(frame.data.QuestData)

                                if newIcon ~= frame.data.Icon then
                                    frame:UpdateTexture(Questie.usedIcons[newIcon])
                                end
                            end
                        end
                    end
                else
                    --If the quests are not within level range we want to unload them
                    --(This is for when people level up or change settings etc)
                    QuestieMap:UnloadQuestFrames(questId)

                    if availableQuests[questId] then
                        QuestieTooltips:RemoveQuest(questId)
                    end
                end
            end
        end

        -- Reset the questCount
        questCount = questCount + 1
        if questCount > QUESTS_PER_YIELD then
            questCount = 0
            yield()
        end
    end
end

---@param callback function | nil
function AvailableQuests.CalculateAndDrawAll(callback)
    Questie:Debug(Questie.DEBUG_INFO, "[AvailableQuests.CalculateAndDrawAll]")

    --? Cancel the previously running timer to not have multiple running at the same time
    if timer then
        timer:Cancel()
    end
    timer = ThreadLib.Thread(_CalculateAvailableQuests, 0, "Error in CalculateAndDrawAll", callback)
end

--Draw a single available quest, it is used by the CalculateAndDrawAll function.
---@param quest Quest
function AvailableQuests.DrawAvailableQuest(quest) -- prevent recursion
    --? Some quests can be started by both an NPC and a GameObject

    if quest.Starts["GameObject"] then
        local gameObjects = quest.Starts["GameObject"]
        for i = 1, #gameObjects do
            local obj = QuestieDB:GetObject(gameObjects[i])
            if (obj and obj.spawns) then
                QuestieTooltips:RegisterQuestStartTooltip(quest.Id, obj, "o_" .. obj.id)

                for zone, spawns in pairs(obj.spawns) do
                    if (zone and spawns) then
                        local coords
                        for spawnIndex = 1, #spawns do
                            coords = spawns[spawnIndex]
                            local data = {
                                Id = quest.Id,
                                Icon = _GetQuestIcon(quest),
                                GetIconScale = _GetIconScaleForAvailable,
                                IconScale = _GetIconScaleForAvailable(),
                                Type = "available",
                                QuestData = quest,
                                Name = obj.name,
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
                                QuestieMap:DrawWorldIcon(data, zone, coords[1], coords[2])
                            end
                        end
                    end
                end
            end
        end
    end
    if (quest.Starts["NPC"]) then
        local npcs = quest.Starts["NPC"]
        for i = 1, #npcs do
            local npc = QuestieDB:GetNPC(npcs[i])

            if (npc and npc.spawns) then
                QuestieTooltips:RegisterQuestStartTooltip(quest.Id, npc, "m_" .. npc.id)

                local starterIcons = {}
                local starterLocs = {}
                for npcZone, spawns in pairs(npc.spawns) do
                    if (npcZone and spawns) then
                        local coords
                        for spawnIndex = 1, #spawns do
                            coords = spawns[spawnIndex]
                            local data = {
                                Id = quest.Id,
                                Icon = _GetQuestIcon(quest),
                                GetIconScale = _GetIconScaleForAvailable,
                                IconScale = _GetIconScaleForAvailable(),
                                Type = "available",
                                QuestData = quest,
                                Name = npc.name,
                                IsObjectiveNote = false,
                            }
                            if (coords[1] == -1 or coords[2] == -1) then
                                local dungeonLocation = ZoneDB:GetDungeonLocation(npcZone)
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
                                starterIcons[npcZone] = QuestieMap:DrawWorldIcon(data, npcZone, x, y)
                                if not starterLocs[npcZone] then
                                    starterLocs[npcZone] = { x, y }
                                end
                            end
                        end
                    end
                end

                if npc.waypoints then
                    for zone, waypoints in pairs(npc.waypoints) do
                        if not dungeons[zone] and waypoints[1] and waypoints[1][1] and waypoints[1][1][1] then
                            if not starterIcons[zone] then
                                local data = {
                                    Id = quest.Id,
                                    Icon = _GetQuestIcon(quest),
                                    GetIconScale = _GetIconScaleForAvailable,
                                    IconScale = _GetIconScaleForAvailable(),
                                    Type = "available",
                                    QuestData = quest,
                                    Name = npc.name,
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
