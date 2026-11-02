---@type QuestieCompat
local QuestieCompat = QuestieLoader:ImportModule("QuestieCompat")

---@class TrackerUtils
local TrackerUtils = QuestieLoader:ImportModule("TrackerUtils")
-------------------------
--Import QuestieTracker modules.
-------------------------
---@type QuestieTracker
local QuestieTracker = QuestieLoader:ImportModule("QuestieTracker")
---@type Sorter
local Sorter = QuestieLoader:ImportModule("Sorter")
---@type TrackerLinePool
local TrackerLinePool = QuestieLoader:ImportModule("TrackerLinePool")
---@type QuestFocusButton
local QuestFocusButton = QuestieLoader:ImportModule("QuestFocusButton")
---@type AchievementTracking
local AchievementTracking = QuestieLoader:ImportModule("AchievementTracking")
---@type TrackerData
local TrackerData = QuestieLoader:ImportModule("TrackerData")
---@type TrackerRecipes
local TrackerRecipes = QuestieLoader:ImportModule("TrackerRecipes")
---@type TrackerMapEligibility
local TrackerMapEligibility = QuestieLoader:ImportModule("TrackerMapEligibility")
---@type TrackerFadeTicker
local TrackerFadeTicker = QuestieLoader:ImportModule("TrackerFadeTicker")
---@type QuestieCombatQueue
local QuestieCombatQueue = QuestieLoader:ImportModule("QuestieCombatQueue")
-------------------------
--Import Questie modules.
-------------------------
---@type Expansions
local Expansions = QuestieLoader:ImportModule("Expansions")
---@type QuestiePlayer
local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestieMap
local QuestieMap = QuestieLoader:ImportModule("QuestieMap")
---@type QuestieCoords
local QuestieCoords = QuestieLoader:ImportModule("QuestieCoords")
---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule("ZoneDB")
---@type DistanceUtils
local DistanceUtils = QuestieLoader:ImportModule("DistanceUtils")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")
---@type QuestieWaypoints
local QuestieWaypoints = QuestieLoader:ImportModule("QuestieWaypoints")


local IsAddOnLoaded = QuestieCompat.IsAddOnLoaded
local GetItemCount = QuestieCompat.GetItemCount
local GetItemSpell = QuestieCompat.GetItemSpell
local IsEquippableItem = QuestieCompat.IsEquippableItem

local tinsert = table.insert

local objectiveFlashTicker
-- Time between two steps of the map icon flash animation.
local FLASH_STEP_SECONDS = 0.065
---@type table<number, table> Icons of the running flash, to restore their size when a new flash starts.
local flashingIcons = {}
local zoneCache = {}
local questProximityTimer
local questZoneProximityTimer
local bindTruthTable = {
    ["left"] = function(button)
        return "LeftButton" == button
    end,
    ["right"] = function(button)
        return "RightButton" == button
    end,
    ["shiftleft"] = function(button)
        return "LeftButton" == button and IsShiftKeyDown()
    end,
    ["shiftright"] = function(button)
        return "RightButton" == button and IsShiftKeyDown()
    end,
    ["ctrlleft"] = function(button)
        return "LeftButton" == button and IsControlKeyDown()
    end,
    ["ctrlright"] = function(button)
        return "RightButton" == button and IsControlKeyDown()
    end,
    ["altleft"] = function(button)
        return "LeftButton" == button and IsAltKeyDown()
    end,
    ["altright"] = function(button)
        return "RightButton" == button and IsAltKeyDown()
    end,
    ["disabled"] = function() return false end,
}

local _QuestLogScrollBar = (QuestLogListScrollFrame and QuestLogListScrollFrame.ScrollBar) or QuestLogListScrollFrameScrollBar

---@param quest table The table provided by QuestieDB.GetQuest(questId)
function TrackerUtils:ShowQuestLog(quest)
    -- Opening it from addon code taints Forever's gamepad bindings, which leads to a crash
    if Questie.IsForever and InputUtil and InputUtil.IsGamepadUIEnabled() then
        Questie:Print(l10n("Opening the quest log from Questie is disabled in controller mode. Open it with your controller instead."))
        return
    end

    -- Classic can expose both interfaces; preserve its standalone log and addon replacements.
    local questFrame = QuestLogExFrame or ClassicQuestLog or QuestLogFrame
    if QuestMapFrame_OpenToQuestDetails and not questFrame then
        -- The modern quest log owns selection and scrolling, and takes a quest ID rather than a log index.
        if not InCombatLockdown() then
            QuestMapFrame_OpenToQuestDetails(quest.Id)
        else
            Questie:Print(l10n("Can't open Quest Log while in combat. Open it manually."))
        end
        return
    end

    --HideUIPanel(questFrame) -- don't use as I don't see why to use and protected function taints in combat
    local questLogIndex = QuestieCompat.GetQuestLogIndexByID(quest.Id)
    QuestieCompat.SelectQuestLogEntry(questLogIndex)

    -- Scroll to the quest in the quest log
    local scrollSteps = _QuestLogScrollBar:GetValueStep()
    _QuestLogScrollBar:SetValue(questLogIndex * scrollSteps - scrollSteps * 3)

    if not questFrame:IsShown() then
        if not InCombatLockdown() then
            ShowUIPanel(questFrame)

            --Addon specific behaviors
            if (QuestLogEx) then
                QuestLogEx:Maximize()
            end
        else
            Questie:Print(l10n("Can't open Quest Log while in combat. Open it manually."))
        end
    end

    QuestieCompat.QuestLog_UpdateQuestDetails()
    QuestieCompat.QuestLog_Update()
end

---@param title string The name of the WayPoint
---@param zone number The zone ID number
---@param x number X coordinate
---@param y number Y coordinate
function TrackerUtils:SetTomTomTarget(title, zone, x, y)
    if TomTom and TomTom.AddWaypoint then
        if Questie.db.char._tom_waypoint and TomTom.RemoveWaypoint then -- remove old waypoint
            TomTom:RemoveWaypoint(Questie.db.char._tom_waypoint)
        end
        local uiMapId = ZoneDB:GetUiMapIdByAreaId(zone)
        Questie.db.char._tom_waypoint = TomTom:AddWaypoint(uiMapId, x / 100, y / 100, {title = title, crazy = true, from = "Questie"})
    end
end

---Quest navigation and ctrl-click use the same eligibility as the menu, evaluated against current data.
---@param questId QuestId
---@param expectedQuest Quest? Original quest captured by the initiating row or menu.
---@return boolean
function TrackerUtils.SetQuestTomTomTarget(questId, expectedQuest)
    local quest, capabilities = TrackerMapEligibility.RefreshAndGetCapabilities(questId, expectedQuest)
    if not (capabilities and capabilities.canNavigateQuest) then
        return false
    end
    local spawn, zone, name = DistanceUtils.GetNearestSpawnForQuest(quest)
    if not spawn then
        return false
    end
    TrackerUtils:SetTomTomTarget(name, zone, spawn[1], spawn[2])
    return true
end

---Opens the world map on the zone of the quest's nearest objective or finisher and flashes the quest's icons.
---@param questId QuestId
---@param expectedQuest Quest? Original quest captured by the initiating row.
---@return boolean
function TrackerUtils.ShowQuestOnMap(questId, expectedQuest)
    local quest, capabilities = TrackerMapEligibility.RefreshAndGetCapabilities(questId, expectedQuest)
    if not (capabilities and capabilities.canNavigateQuest) then
        return false
    end
    local spawn, zone = DistanceUtils.GetNearestSpawnForQuest(quest)
    if not spawn then
        return false
    end
    if (not QuestieCompat.OpenWorldMap(ZoneDB:GetUiMapIdByAreaId(zone))) then
        -- Flashing hides all other icons, which must not happen on a map that did not switch.
        return false
    end
    -- FlashFinisher flashes all map icons of a quest, not only its finisher.
    TrackerUtils:FlashFinisher(capabilities.quest)
    return true
end

---@param objective QuestObjective
function TrackerUtils:ShowObjectiveOnMap(objective)
    local _, zoneId = DistanceUtils.GetNearestObjective(objective.spawnList)
    if zoneId then
        if QuestieCompat.OpenWorldMap(ZoneDB:GetUiMapIdByAreaId(zoneId)) then
            TrackerUtils:FlashObjective(objective)
        end
    end
end

---@param objectives QuestObjective[]
---@return AreaId?
local function _GetNearestObjectiveZone(objectives)
    local bestZone, bestDistance
    for _, objective in pairs(objectives) do
        local spawn, zone, _, distance = DistanceUtils.GetNearestObjective(objective.spawnList)
        if spawn and (not bestDistance or distance < bestDistance) then
            bestZone, bestDistance = zone, distance
        end
    end
    return bestZone
end

---Opens the map at the nearest objective and flashes all given objectives together.
---@param objectives QuestObjective[]
function TrackerUtils:ShowQuestObjectivesOnMap(objectives)
    local zoneId = _GetNearestObjectiveZone(objectives)
    if zoneId then
        if QuestieCompat.OpenWorldMap(ZoneDB:GetUiMapIdByAreaId(zoneId)) then
            TrackerUtils:FlashObjectives(objectives)
        end
    end
end

---@param quest Quest The table provided by QuestieDB.GetQuest(questId)
function TrackerUtils:ShowFinisherOnMap(quest)
    local _, zoneId = DistanceUtils.GetNearestFinisherOrStarter(quest.Finisher)
    if zoneId then
        if QuestieCompat.OpenWorldMap(ZoneDB:GetUiMapIdByAreaId(zoneId)) then
            TrackerUtils:FlashFinisher(quest)
        end
    end
end

---Calls the callback for every world map icon, including townsfolk icons, but skips minimap icons.
---@param callback fun(icon: table)
local function _ForEachFlashableIcon(callback)
    for _, framelist in pairs(QuestieMap.questIdFrames) do
        for _, frameName in pairs(framelist) do
            local icon = _G[frameName]
            if icon and (not icon.miniMapIcon) then
                callback(icon)
            end
        end
    end
    for _, townsfolk in pairs(QuestieMap.manualFrames or {}) do
        for _, framelist in pairs(townsfolk) do
            for _, frameName in pairs(framelist) do
                local icon = _G[frameName]
                if icon and (not icon.miniMapIcon) then
                    callback(icon)
                end
            end
        end
    end
end

---Hides townsfolk icons while a flash runs; _StopFlash shows them again.
local function _HideManualIconsForFlash()
    for _, townsfolk in pairs(QuestieMap.manualFrames or {}) do
        for _, framelist in pairs(townsfolk) do
            for _, frameName in pairs(framelist) do
                local icon = _G[frameName]
                if icon and (not icon.miniMapIcon) and icon:IsShown() then
                    icon._hidden_by_flash = true
                    icon:Hide()
                end
            end
        end
    end
end

---Ends a running flash right away, so a new flash starts from the icons' real sizes and visibility.
local function _StopFlash()
    if (not objectiveFlashTicker) then
        return
    end
    objectiveFlashTicker:Cancel()
    objectiveFlashTicker = nil
    for _, frame in pairs(flashingIcons) do
        if frame._size then
            frame:SetWidth(frame._size)
            frame:SetHeight(frame._size)
            frame._size = nil
        end
    end
    flashingIcons = {}
    _ForEachFlashableIcon(function(icon)
        if icon._hidden_by_flash then
            icon._hidden_by_flash = nil
            icon:Show()
        end
    end)
    QuestieWaypoints.SetSolo(nil)
end

---@param objective table The table provided by QuestieDB.GetQuest(questId).Objectives[objective]
function TrackerUtils:FlashObjective(objective)
    TrackerUtils:FlashObjectives({objective})
end

---Flashes the map icons of all given objectives together, hiding every other icon during the flash.
---@param objectives table[] Tables provided by QuestieDB.GetQuest(questId).Objectives
function TrackerUtils:FlashObjectives(objectives)
    local hasSpawned = false
    for _, objective in pairs(objectives) do
        if objective.AlreadySpawned and next(objective.AlreadySpawned) then
            hasSpawned = true
            break
        end
    end
    if hasSpawned then
        _StopFlash()
        _HideManualIconsForFlash()
        local toFlash = {}
        -- ugly code
        for _, framelist in pairs(QuestieMap.questIdFrames) do
            for _, frameName in pairs(framelist) do
                local icon = _G[frameName]
                if not icon.miniMapIcon then
                    -- todo: move into frame.session
                    if icon:IsShown() then
                        icon._hidden_by_flash = true
                        icon:Hide()
                    end
                end
            end
        end


        -- Only the flashed objectives' patrol paths show during the flash.
        local flashedData = {}
        -- A frame shared by two objectives must be resized once per tick, not twice.
        local queued = {}
        for _, objective in pairs(objectives) do
            for _, spawn in pairs(objective.AlreadySpawned or {}) do
                if spawn.mapRefs then
                    for _, frame in pairs(spawn.mapRefs) do
                        if not queued[frame] then
                            queued[frame] = true
                            tinsert(toFlash, frame)
                            if frame._hidden_by_flash then
                                frame:Show()
                            end

                            -- todo: move into frame.session
                            frame._hidden_by_flash = nil
                            frame._size = frame:GetWidth()

                            if frame.data then
                                flashedData[frame.data] = true
                            end
                        end
                    end
                end
            end
        end
        QuestieWaypoints.SetSolo(flashedData)
        local flashW = 1
        local flashB = true
        local flashDone = 0
        flashingIcons = toFlash
        local ticker
        ticker = C_Timer.NewTicker(FLASH_STEP_SECONDS, function()
            for _, frame in pairs(toFlash) do
                frame:SetWidth(frame._size + flashW)
                frame:SetHeight(frame._size + flashW)
            end
            if flashB then
                if flashW < 10 then
                    flashW = flashW + (16 - flashW) / 2 + 0.06
                    if flashW >= 9.5 then
                        flashB = false
                    end
                end
            else
                if flashW > 0 then
                    flashW = flashW - 2
                    --flashW = (flashW + (-flashW) / 3) - 0.06
                    if flashW < 1 then
                        --flashW = 0
                        flashB = true
                        -- ugly code
                        if flashDone > 0 then
                            C_Timer.After(0.1, function()
                                if objectiveFlashTicker ~= ticker then
                                    return
                                end
                                ticker:Cancel()
                                for _, frame in pairs(toFlash) do
                                    frame:SetWidth(frame._size)
                                    frame:SetHeight(frame._size)
                                    frame._size = nil
                                end
                            end)
                            C_Timer.After(0.5, function()
                                if objectiveFlashTicker == ticker then
                                    _StopFlash()
                                end
                            end)
                        end
                        flashDone = flashDone + 1
                    end
                end
            end
        end)
        objectiveFlashTicker = ticker
    end
end

---@param quest table The table provided by QuestieDB.GetQuest(questId)
function TrackerUtils:FlashFinisher(quest)
    _StopFlash()
    _HideManualIconsForFlash()
    local toFlash = {}
    -- Only the flashed quest's patrol paths show during the flash.
    local flashedData = {}
    -- ugly code
    for questId, framelist in pairs(QuestieMap.questIdFrames) do
        if questId ~= quest.Id then
            for _, frameName in pairs(framelist) do
                local icon = _G[frameName]
                if not icon.miniMapIcon then
                    -- todo: move into frame.session
                    if icon:IsShown() then
                        icon._hidden_by_flash = true
                        icon:Hide()
                    end
                end
            end
        else
            for _, frameName in pairs(framelist) do
                local icon = _G[frameName]
                if not icon.miniMapIcon then
                    icon._size = icon:GetWidth()
                    tinsert(toFlash, icon)
                    if icon.data then
                        flashedData[icon.data] = true
                    end
                end
            end
        end
    end
    QuestieWaypoints.SetSolo(flashedData)

    local flashW = 1
    local flashB = true
    local flashDone = 0
    flashingIcons = toFlash
    local ticker
    ticker = C_Timer.NewTicker(FLASH_STEP_SECONDS, function()
        for _, frame in pairs(toFlash) do
            frame:SetWidth(frame._size + flashW)
            frame:SetHeight(frame._size + flashW)
        end
        if flashB then
            if flashW < 10 then
                flashW = flashW + (16 - flashW) / 2 + 0.06
                if flashW >= 9.5 then
                    flashB = false
                end
            end
        else
            if flashW > 0 then
                flashW = flashW - 2
                --flashW = (flashW + (-flashW) / 3) - 0.06
                if flashW < 1 then
                    --flashW = 0
                    flashB = true
                    -- ugly code
                    if flashDone > 0 then
                        C_Timer.After(0.1, function()
                            if objectiveFlashTicker ~= ticker then
                                return
                            end
                            ticker:Cancel()
                            for _, frame in pairs(toFlash) do
                                frame:SetWidth(frame._size)
                                frame:SetHeight(frame._size)
                                frame._size = nil
                            end
                        end)
                        C_Timer.After(0.5, function()
                            if objectiveFlashTicker == ticker then
                                _StopFlash()
                            end
                        end)
                    end
                    flashDone = flashDone + 1
                end
            end
        end
    end)
    objectiveFlashTicker = ticker
end

---@param bind string
---@param button string
---@return string bind The input keybind string
---@return string button The input button string
---@return string bindTruthTable.bind Returns matched bind string
---@return function|boolean bindTruthTable.bind.button Returns button function or false if there is no keybind set
function TrackerUtils:IsBindTrue(bind, button)
    return bind and button and bindTruthTable[bind] and bindTruthTable[bind](button)
end

---@param itemId number
---@return boolean
function TrackerUtils:IsQuestItemUsable(itemId)
    if itemId and (GetItemSpell(itemId) or IsEquippableItem(itemId)) then
        return true
    end

    return false
end

---@param quest Quest
---@return string|nil completionText Quest Completion text string or nil
function TrackerUtils:GetCompletionText(quest)
    local completionText
    if GetQuestLogCompletionText then
        local questIndex = QuestieCompat.GetQuestLogIndexByID(quest.Id)
        completionText = GetQuestLogCompletionText(questIndex)
    end

    if completionText then
        return completionText
    elseif quest.Description and next(quest.Description) then
        local descr = quest.Description[1]
        return descr
    end
end

---@param zoneId number Zone ID number
---@return string @Zone Name (Localized) or l10n("Unknown Zone")
local function GetZoneNameByIDFallback(zoneId)
    if zoneCache[zoneId] then
        return zoneCache[zoneId]
    end

    if zoneId <= 0 or type(zoneId) ~= "number" then
        return l10n("Unknown Zone")
    end

    for _, zone in pairs(l10n.zoneLookup) do
        if zone[zoneId] then
            zoneCache[zoneId] = zone[zoneId]
            return zoneCache[zoneId]
        end
    end

    Questie.Debug(Questie.DEBUG_CRITICAL, "[GetZoneNameByIDFallback]: Unable to find a zone name for zoneId", zoneId)

    return l10n("Unknown Zone")
end

---@param zoneId number Zone ID number
---@return string @Zone Name (Localized)
function TrackerUtils:GetZoneNameByID(zoneId)
    if zoneCache[zoneId] then
        return zoneCache[zoneId]
    end

    if C_Map.GetAreaInfo(zoneId) then
        zoneCache[zoneId] = C_Map.GetAreaInfo(zoneId)
    elseif ZoneDB:GetLocalizedDungeonName(zoneId) then
        zoneCache[zoneId] = ZoneDB:GetLocalizedDungeonName(zoneId)
    else
        zoneCache[zoneId] = GetZoneNameByIDFallback(zoneId)
    end

    return zoneCache[zoneId]
end

---@param catId number Catagory ID number
---@return string CatagoryName Catagory Name (Localized) or "Unknown Category"
function TrackerUtils:GetCategoryNameByID(catId)
    if zoneCache[catId] then
        return zoneCache[catId]
    end

    if type(catId) == "number" and catId < 0 and type(l10n.questCategoryLookup[catId]) == "string" then
        zoneCache[catId] = l10n(l10n.questCategoryLookup[catId])
        return zoneCache[catId]
    end

    return "Unknown Category"
end

---Clears Blizzard super tracking only when it points at the quest Questie focused, so other super tracking stays.
---@param questId QuestId
local function _ClearSuperTrackedQuest(questId)
    if QuestieCompat.GetSuperTrackedQuestID() == questId then
        QuestieCompat.ClearSuperTrackedQuest()
    end
end

function TrackerUtils:UnFocus()
    -- reset HideIcons to match savedvariable state
    if (not Questie.db.char.TrackerFocus) then
        return
    end
    for questId in pairs(QuestiePlayer.currentQuestlog) do
        local quest = QuestieDB.GetQuest(questId)

        if quest then
            quest.FadeIcons = nil
            if next(quest.Objectives) then
                if Questie.db.char.TrackerHiddenQuests[quest.Id] then
                    quest.HideIcons = true
                    quest.FadeIcons = nil
                else
                    quest.HideIcons = nil
                    quest.FadeIcons = nil
                end
            end
        end
    end

    -- Clear the focus first: the super tracking change may notify TrackerSuperTrack right away.
    local focus = Questie.db.char.TrackerFocus
    Questie.db.char.TrackerFocus = nil
    _ClearSuperTrackedQuest(focus)
end

---@param questId number Quest ID number
---@param expectedQuest Quest? Original quest captured by a menu.
---@return boolean
function TrackerUtils:FocusQuest(questId, expectedQuest)
    local _, capabilities = TrackerMapEligibility.RefreshAndGetCapabilities(questId, expectedQuest)
    if not (capabilities and capabilities.canFocusQuest) then
        return false
    end

    if Questie.db.char.TrackerFocus and Questie.db.char.TrackerFocus ~= questId then
        TrackerUtils:UnFocus()
    end

    Questie.db.char.TrackerFocus = questId
    if QuestieCompat.GetSuperTrackedQuestID() ~= questId then
        QuestieCompat.SetSuperTrackedQuestID(questId)
    end
    for questLogQuestId in pairs(QuestiePlayer.currentQuestlog) do
        local quest = QuestieDB.GetQuest(questLogQuestId)
        if quest then
            if questLogQuestId == questId then
                quest.HideIcons = nil
                quest.FadeIcons = nil
            else
                quest.FadeIcons = true
            end
        end
    end
    return true
end

---@return table|nil position Returns Players current X/Y coordinates or nil if a Players postion can't be determined
local function _GetWorldPlayerPosition()
    -- Turns coords into 'world' coords so it can be compared with any coords in another zone
    local mapPosition, mapID = QuestieCoords.GetPlayerMapPosition()
    if (not mapPosition) or (not mapPosition.x) then
        return nil
    end

    local worldPosition = select(2, C_Map.GetWorldPosFromMapPos(mapID, mapPosition))
    local position = {
        x = worldPosition.x,
        y = worldPosition.y
    }

    return position
end

---@param uiMapId number Continent ID number
---@return string Continent Returns Continent Name or "UNKNOW"
local function _GetContinent(uiMapId)
    if (not uiMapId) then
        return "UNKNOWN"
    end

    local useUiMapId = uiMapId
    local mapInfo = C_Map.GetMapInfo(useUiMapId)
    while mapInfo and mapInfo.mapType ~= 2 and mapInfo.parentMapID ~= useUiMapId do
        useUiMapId = mapInfo.parentMapID
        mapInfo = C_Map.GetMapInfo(useUiMapId)
    end

    if mapInfo ~= nil then
        return mapInfo.name
    else
        return "UNKNOWN"
    end
end

---@param zoneOrSort ZoneOrSort
---@param questId QuestId
---@return string zoneName Returns the zone name for a quest based on the quests zoneOrSort value and the current tracker sorting method. If the quest has no explicit zone or category, it will return "Unknown Zone".
--- If the sorting method is not byZone, it will return a custom zone name based on the sorting type.
local function _GetZoneName(zoneOrSort, questId, nativeHeader)
    local zoneName
    local sortObj = Questie.db.profile.trackerSortObjectives
    if sortObj == "byZone" or sortObj == "byZonePlayerProximity" or sortObj == "byZonePlayerProximityReversed" then
        if nativeHeader then
            return nativeHeader
        elseif not zoneOrSort then
            return l10n("Unknown Zone")
        elseif zoneOrSort > 0 then
            -- Valid ZoneID
            zoneName = TrackerUtils:GetZoneNameByID(zoneOrSort)
        elseif (zoneOrSort) < 0 then
            -- Valid CategoryID
            zoneName = TrackerUtils:GetCategoryNameByID(zoneOrSort)
        else
            -- The quest has no explicit zone or category. Fallback to "Unknown Zone"
            zoneName = "Unknown Zone"
            Questie.Debug(Questie.DEBUG_CRITICAL, "[TrackerUtils:_GetZoneName] zoneOrSort", zoneOrSort, "of quest", questId, "is not in the Database!")
        end
    else
        -- Let's create custom Zones based on Sorting type.
        if sortObj == "byComplete" then
            zoneName = "Quests (By %% Complete)"
        elseif sortObj == "byCompleteReversed" then
            zoneName = "Quests (By %% Complete Reversed)"
        elseif sortObj == "byLevel" then
            zoneName = "Quests (By Level)"
        elseif sortObj == "byLevelReversed" then
            zoneName = "Quests (By Level Reversed)"
        elseif sortObj == "byProximity" then
            zoneName = "Quests (By Proximity)"
        elseif sortObj == "byProximityReversed" then
            zoneName = "Quests (By Proximity Reversed)"
        end
    end
    return zoneName or "Unknown Zone"
end

---Returns the tracker group a quest is listed under; `collapsedZones` is keyed by this name.
---@param quest TrackerQuest
---@return string groupName The zone or category when sorting by zone, otherwise the sort mode's single group.
function TrackerUtils.GetQuestGroupName(quest)
    return _GetZoneName(quest.zoneOrSort, quest.Id, quest.zoneName)
end

---@return table sortedQuestIds Table with sorted Quest ID's by Sort Type
---@return table questDetails Display records, completion fractions and grouping labels.
function TrackerUtils:GetSortedQuestIds()
    ---@type QuestId[]
    local sortedQuestIds = {}
    ---@type table<QuestId, QuestSortDetails>
    local questDetails = {}
    local sortObj = Questie.db.profile.trackerSortObjectives

    -- Update quest objectives
    for questId, quest in pairs(TrackerData.GetQuests()) do
        if quest then
            tinsert(sortedQuestIds, questId)

            local percent = 0
            if quest:IsComplete() == 1 or quest.isComplete then
                percent = 1
            elseif #quest.Objectives > 0 then
                for _, objective in ipairs(quest.Objectives) do
                    if objective.Completed then
                        percent = percent + 1
                    elseif objective.Needed and objective.Needed > 0 and objective.Collected then
                        percent = percent + math.min(1, math.max(0, objective.Collected / objective.Needed))
                    end
                end
                percent = percent / #quest.Objectives
            end

            questDetails[questId] = {
                quest = quest,
                zoneName = TrackerUtils.GetQuestGroupName(quest),
                questCompletePercent = percent,
            }
        end
    end

    -- Quests and objectives sort
    if sortObj == "byZone" then
        Sorter.byZone(sortedQuestIds, questDetails)
    elseif sortObj == "byComplete" then
        Sorter.byComplete(sortedQuestIds, questDetails)
    elseif sortObj == "byCompleteReversed" then
        Sorter.byCompleteReverse(sortedQuestIds, questDetails)
    elseif sortObj == "byLevel" then
        Sorter.byLevel(sortedQuestIds, questDetails)
    elseif sortObj == "byLevelReversed" then
        Sorter.byLevelReverse(sortedQuestIds, questDetails)
    elseif sortObj == "byZonePlayerProximity" or sortObj == "byZonePlayerProximityReversed" then
        local toSort = {}
        local continent = _GetContinent(C_Map.GetBestMapForUnit("player"))

        for _, questId in pairs(sortedQuestIds) do
            local sortData = {}
            sortData.questId = questId
            sortData.q = questDetails[questId].quest

            local _, zone, _, distance = DistanceUtils.GetNearestSpawnForQuest(sortData.q)
            sortData.zone = zone
            sortData.distance = distance
            sortData.continent = _GetContinent(ZoneDB:GetUiMapIdByAreaId(zone))
            toSort[questId] = sortData
        end

        local sorter = function(a, b)
            local qAZone = questDetails[a].zoneName
            local qBZone = questDetails[b].zoneName

            -- If same Zone as Player then sort by Proximity
            if qAZone == qBZone then
                a = toSort[a]
                b = toSort[b]
                if ((continent == a.continent) and (continent == b.continent)) or ((continent ~= a.continent) and (continent ~= b.continent)) then
                    if a.distance == b.distance then
                        -- Same distance then sort by Level
                        return a.q and b.q and a.q.level < b.q.level
                    end

                    if not a.distance and b.distance then
                        return false
                    elseif a.distance and not b.distance then
                        return true
                    end

                    return a.distance < b.distance
                elseif (continent == a.continent) and (continent ~= b.continent) then
                    return true
                elseif (continent ~= a.continent) and (continent == b.continent) then
                    return false
                end
            else
                return qAZone < qBZone
            end
        end

        local sorterReversed = function(a, b)
            local qAZone = questDetails[a].zoneName
            local qBZone = questDetails[b].zoneName

            -- If same Zone as Player then sort by Proximity
            if qAZone == qBZone then
                a = toSort[a]
                b = toSort[b]
                if ((continent == a.continent) and (continent == b.continent)) or ((continent ~= a.continent) and (continent ~= b.continent)) then
                    if a.distance == b.distance then
                        -- Same distance then sort by Level
                        return a.q and b.q and a.q.level > b.q.level
                    end

                    if not a.distance and b.distance then
                        return true
                    elseif a.distance and not b.distance then
                        return false
                    end

                    return a.distance > b.distance
                elseif (continent == a.continent) and (continent ~= b.continent) then
                    return false
                elseif (continent ~= a.continent) and (continent == b.continent) then
                    return true
                end
            else
                return qAZone < qBZone
            end
        end

        if sortObj == "byZonePlayerProximity" then
            table.sort(sortedQuestIds, sorter)
        else
            table.sort(sortedQuestIds, sorterReversed)
        end

        if not questZoneProximityTimer and not IsInInstance() then
            -- Check location often and update if you've moved
            Questie.Debug(Questie.DEBUG_DEVELOP, "[TrackerUtils:GetSortedQuestIds] - Zone Proximity Timer Started!")

            local playerPosition
            questZoneProximityTimer = C_Timer.NewTicker(5.0, function()
                if IsInInstance() and questZoneProximityTimer then
                    Questie.Debug(Questie.DEBUG_DEVELOP, "[TrackerUtils:GetSortedQuestIds] - Zone Proximity Timer Stopped!")
                    questZoneProximityTimer:Cancel()
                    questZoneProximityTimer = nil
                else
                    local position = _GetWorldPlayerPosition()
                    if position then
                        local distance = playerPosition and QuestieLib.Euclid(position.x, position.y, playerPosition.x, playerPosition.y)
                        if not distance or distance > 0.01 then -- Position has changed
                            Questie.Debug(Questie.DEBUG_SPAM, "[TrackerUtils:GetSortedQuestIds] - Zone Proximity Timer Updated!")
                            playerPosition = position
                            local orderCopy = {}

                            for index, val in pairs(sortedQuestIds) do
                                orderCopy[index] = val
                            end

                            if sortObj == "byZonePlayerProximity" then
                                table.sort(sortedQuestIds, sorter)
                            else
                                table.sort(sortedQuestIds, sorterReversed)
                            end

                            for index, val in pairs(sortedQuestIds) do
                                if orderCopy[index] ~= val then -- The order has changed
                                    break
                                end
                            end

                            QuestieCombatQueue:Queue(function()
                                -- Don't update tracker if we're in a pet battle
                                if Expansions.Current >= Expansions.MoP and Questie.db.profile.hideTrackerInPetBattles and C_PetBattles and C_PetBattles.IsInBattle() then
                                    Questie.Debug(Questie.DEBUG_DEVELOP, "[TrackerUtils] Skipped zone proximity timer tracker update - in pet battle")
                                    return
                                end
                                TrackerUtils.FilterProximityTimer = true
                                QuestieTracker:Update()
                            end)
                        end
                    end
                end
            end)
        end
    elseif sortObj == "byProximity" or sortObj == "byProximityReversed" then
        local toSort = {}
        local continent = _GetContinent(C_Map.GetBestMapForUnit("player"))

        for _, questId in pairs(sortedQuestIds) do
            local sortData = {}
            sortData.questId = questId
            sortData.q = questDetails[questId].quest

            local _, zone, _, distance = DistanceUtils.GetNearestSpawnForQuest(sortData.q)
            sortData.zone = zone
            sortData.distance = distance
            sortData.continent = _GetContinent(ZoneDB:GetUiMapIdByAreaId(zone))
            toSort[questId] = sortData
        end

        local sorter = function(a, b)
            a = toSort[a]
            b = toSort[b]
            if ((continent == a.continent) and (continent == b.continent)) or ((continent ~= a.continent) and (continent ~= b.continent)) then
                if a.distance == b.distance then
                    return a.q and b.q and a.q.level < b.q.level
                end

                if not a.distance and b.distance then
                    return false
                elseif a.distance and not b.distance then
                    return true
                end

                return a.distance < b.distance
            elseif (continent == a.continent) and (continent ~= b.continent) then
                return true
            elseif (continent ~= a.continent) and (continent == b.continent) then
                return false
            end
        end

        local sorterReversed = function(a, b)
            a = toSort[a]
            b = toSort[b]
            if ((continent == a.continent) and (continent == b.continent)) or ((continent ~= a.continent) and (continent ~= b.continent)) then
                if a.distance == b.distance then
                    return a.q and b.q and a.q.level > b.q.level
                end

                if not a.distance and b.distance then
                    return true
                elseif a.distance and not b.distance then
                    return false
                end

                return a.distance > b.distance
            elseif (continent == a.continent) and (continent ~= b.continent) then
                return false
            elseif (continent ~= a.continent) and (continent == b.continent) then
                return true
            end
        end

        if sortObj == "byProximity" then
            table.sort(sortedQuestIds, sorter)
        else
            table.sort(sortedQuestIds, sorterReversed)
        end

        if not questProximityTimer and not IsInInstance() then
            -- Check location often and update if you've moved
            Questie.Debug(Questie.DEBUG_DEVELOP, "[TrackerUtils:GetSortedQuestIds] - Proximity Timer Started!")

            local playerPosition
            questProximityTimer = C_Timer.NewTicker(5.0, function()
                if IsInInstance() and questProximityTimer then
                    Questie.Debug(Questie.DEBUG_DEVELOP, "[TrackerUtils:GetSortedQuestIds] - Proximity Timer Stopped!")
                    questProximityTimer:Cancel()
                    questProximityTimer = nil
                else
                    local position = _GetWorldPlayerPosition()
                    if position then
                        local distance = playerPosition and QuestieLib.Euclid(position.x, position.y, playerPosition.x, playerPosition.y)
                        if not distance or distance > 0.01 then -- Position has changed
                            Questie.Debug(Questie.DEBUG_SPAM, "[TrackerUtils:GetSortedQuestIds] - Proximity Timer Updated!")
                            playerPosition = position
                            local orderCopy = {}

                            for index, val in pairs(sortedQuestIds) do
                                orderCopy[index] = val
                            end

                            if sortObj == "byProximity" then
                                table.sort(sortedQuestIds, sorter)
                            else
                                table.sort(sortedQuestIds, sorterReversed)
                            end

                            for index, val in pairs(sortedQuestIds) do
                                if orderCopy[index] ~= val then -- The order has changed
                                    break
                                end
                            end

                            QuestieCombatQueue:Queue(function()
                                -- Don't update tracker if we're in a pet battle
                                if Expansions.Current >= Expansions.MoP and Questie.db.profile.hideTrackerInPetBattles and C_PetBattles and C_PetBattles.IsInBattle() then
                                    Questie.Debug(Questie.DEBUG_DEVELOP, "[TrackerUtils] Skipped proximity timer tracker update - in pet battle")
                                    return
                                end
                                TrackerUtils.FilterProximityTimer = true
                                QuestieTracker:Update()
                            end)
                        end
                    end
                end
            end)
        end
    end


    if (sortObj ~= strmatch(sortObj, "byProximity.*")) and questProximityTimer and questProximityTimer ~= nil then
        Questie.Debug(Questie.DEBUG_DEVELOP, "[TrackerUtils:GetSortedQuestIds] - Proximity Timer Stopped!")
        questProximityTimer:Cancel()
        TrackerUtils.FilterProximityTimer = nil
        questProximityTimer = nil
    end

    if (sortObj ~= strmatch(sortObj, "byZonePlayerProximity.*")) and questZoneProximityTimer and questZoneProximityTimer ~= nil then
        Questie.Debug(Questie.DEBUG_DEVELOP, "[TrackerUtils:GetSortedQuestIds] - Zone Proximity Timer Stopped!")
        questZoneProximityTimer:Cancel()
        TrackerUtils.FilterProximityTimer = nil
        questZoneProximityTimer = nil
    end

    return sortedQuestIds, questDetails
end

function TrackerUtils:IsVoiceOverLoaded()
    if (IsAddOnLoaded("AI_VoiceOver") and IsAddOnLoaded("AI_VoiceOverData_Vanilla")) then
        return true
    end

    return false
end

function TrackerUtils:ShowVoiceOverPlayButtons()
    if self:IsVoiceOverLoaded() then
        if Questie.db.char.isTrackerExpanded then
            if IsShiftKeyDown() and QuestieCompat.MouseIsOver(Questie_BaseFrame) then
                if Questie_BaseFrame.isSizing == true or Questie_BaseFrame.isMoving == true then
                    Questie.Debug(Questie.DEBUG_SPAM, "[TrackerUtils:ShowVoiceOverPlayButtons]")
                else
                    Questie.Debug(Questie.DEBUG_INFO, "[TrackerUtils:ShowVoiceOverPlayButtons]")
                end
            end

            if IsShiftKeyDown() then
                if QuestieCompat.MouseIsOver(Questie_BaseFrame) then
                    TrackerLinePool.SetAllPlayButtonAlpha(1)
                    TrackerFadeTicker.Fade()

                    if not Questie.db.profile.trackerFadeMinMaxButtons then
                        TrackerLinePool.SetAllExpandQuestAlpha(0)
                    end

                    if not Questie.db.profile.trackerFadeQuestItemButtons then
                        TrackerLinePool.SetAllItemButtonAlpha(0)
                    end
                end
            else
                if QuestieCompat.MouseIsOver(Questie_BaseFrame) then
                    TrackerLinePool.SetAllPlayButtonAlpha(0)
                    TrackerFadeTicker.Unfade()
                else
                    TrackerLinePool.SetAllPlayButtonAlpha(0)
                    TrackerFadeTicker.Fade()
                end

                if not Questie.db.profile.trackerFadeMinMaxButtons then
                    TrackerLinePool.SetAllExpandQuestAlpha(1)
                end

                if not Questie.db.profile.trackerFadeQuestItemButtons then
                    TrackerLinePool.SetAllItemButtonAlpha(1)
                end
            end
        end
    end
end

function TrackerUtils:UpdateVoiceOverPlayButtons()
    if self:IsVoiceOverLoaded() then
        if Questie_BaseFrame.isSizing == true or Questie_BaseFrame.isMoving == true then
            Questie.Debug(Questie.DEBUG_SPAM, "[TrackerUtils:UpdateVoiceOverPlayButtons]")
        else
            Questie.Debug(Questie.DEBUG_INFO, "[TrackerUtils:UpdateVoiceOverPlayButtons]")
        end

        for i = 1, 75 do
            local title, _, _, isHeader, _, _, _, questId = QuestieCompat.GetQuestLogTitle(i)

            if not (title and questId) then
                break
            end

            if not isHeader then
                if not VoiceOver.QuestOverlayUI.questPlayButtons[questId] then
                    VoiceOver.QuestOverlayUI:CreatePlayButton(questId)
                    table.insert(VoiceOver.QuestOverlayUI.displayedButtons, VoiceOver.QuestOverlayUI.questPlayButtons[questId])
                end
            end
        end
    end
end

---Owned, usable items the tracker shows buttons for, in button order. Reads bags, never frames.
---@param quest TrackerQuest
---@param complete number @0 if the quest is not complete, 1 if the quest is complete, -1 if the quest is failed
---@return ItemId[] usableQuestItems
---@return ItemId? nativeItemId Blizzard's quest item, even when not owned. Its button skips the database item-class check.
function TrackerUtils.GetQuestItemIds(quest, complete)
    local usableQuestItems = {}
    local nativeItemId
    local questComplete = complete == 1 or quest.isComplete == true

    -- Blizzard identifies the primary quest action even when neither the quest nor item is in QuestieDB.
    -- It skips only the button's database item-class check. It must still be owned like other candidates:
    -- a primary button that fails to set up stops the rest, so an unowned native item would hide owned database items.
    if GetQuestLogSpecialItemInfo then
        local index = QuestieCompat.GetQuestLogIndexByID(quest.Id)
        if index and index > 0 then
            local link, _, _, showWhenComplete = GetQuestLogSpecialItemInfo(index)
            nativeItemId = link and tonumber(link:match("item:(%d+)"))
            if nativeItemId and (not questComplete or showWhenComplete) and GetItemCount(nativeItemId) > 0 then
                tinsert(usableQuestItems, nativeItemId)
            end
        end
    end

    local function AddDatabaseItem(itemId)
        if not questComplete and itemId and not tContains(usableQuestItems, itemId)
            and GetItemCount(itemId) > 0 and TrackerUtils:IsQuestItemUsable(itemId) then
            tinsert(usableQuestItems, itemId)
        end
    end

    AddDatabaseItem(quest.sourceItemId)
    for _, itemId in pairs(quest.requiredSourceItems or {}) do
        AddDatabaseItem(itemId)
    end
    for _, objective in pairs(quest.ObjectiveData) do
        if objective.Type == "item" then
            AddDatabaseItem(objective.Id)
        end
    end

    return usableQuestItems, nativeItemId
end

---@param quest TrackerQuest @The quest to add the quest item buttons for
---@param complete number @0 if the quest is not complete, 1 if the quest is complete, -1 if the quest is failed
---@param line table @The line to add the quest item buttons to
---@param questItemButtonSize number @The size of the quest item buttons
---@param trackerQuestFrame table @The tracker quest frame
---@param isMinimizable boolean @true if the quest is minimizable
---@param rePositionLine function @Callback function to reposition the line
---@return boolean @true if the quest item buttons were added successfully, false if the tracker should stop populating
function TrackerUtils.AddQuestItemButtons(quest, complete, line, questItemButtonSize, trackerQuestFrame, isMinimizable, rePositionLine)
    local usableQuestItems, nativeItemId = TrackerUtils.GetQuestItemIds(quest, complete)
    if #usableQuestItems > 0 then
        -- Get button from buttonPool
        local button = TrackerLinePool.GetNextItemButton()
        if not button then
            return false -- stop populating the tracker
        end

        local questId = quest.Id

        local primaryButtonAdded = button:SetItem(usableQuestItems[1], questId, questItemButtonSize, usableQuestItems[1] == nativeItemId)

        -- Setup button and set attributes
        if primaryButtonAdded then
            local height = 0
            local frame = line
            while frame and frame ~= trackerQuestFrame do
                local _, parent, _, _, yOff = frame:GetPoint()
                height = height - (frame:GetHeight() - yOff)
                frame = parent
            end

            -- If the Quest is minimized show the Expand Quest button
            if Questie.db.char.collapsedQuests[questId] then
                if Questie.db.profile.collapseCompletedQuests and isMinimizable then
                    line.expandQuest:Hide()
                else
                    line.expandQuest:Show()
                end
            else
                line.expandQuest:Hide()
            end

            -- Attach button to Quest Title linePool
            button:SetPoint("TOPLEFT", line, "TOPLEFT", QuestFocusButton.GetColumnWidth(), 0)
            button:SetParent(line)
            button:Show()

            -- If the Quest Zone or Quest is minimized then set UIParent and hide buttons since the buttons are normally attached to the Quest frame.
            -- If buttons are left attached to the Quest frame and if the Tracker frame is hidden in combat, then it would also try and hide the
            -- buttons which you can't do in combat. This helps avoid violating the Blizzard SecureActionButtonTemplate restrictions relating to combat.
            if Questie.db.char.collapsedZones[line.expandZone.zoneId] or Questie.db.char.collapsedQuests[questId] then
                button:SetParent(UIParent)
                button:Hide()
            end

            if #usableQuestItems > 1 then
                local secondaryButton = TrackerLinePool.GetNextItemButton()
                if not secondaryButton then
                    return false -- stop populating the tracker
                end

                -- We add the altButton to be able to position things correctly in QuestieTracker.lua
                line.altButton = secondaryButton

                -- TODO: Handle more than 2 buttons if required
                local secondaryButtonAdded = secondaryButton:SetItem(usableQuestItems[2], questId, questItemButtonSize, usableQuestItems[2] == nativeItemId)

                if secondaryButtonAdded then
                    height = 0
                    frame = line

                    while frame and frame ~= trackerQuestFrame do
                        local _, parent, _, _, yOff = frame:GetPoint()
                        height = height - (frame:GetHeight() - yOff)
                        frame = parent
                    end

                    rePositionLine()

                    -- Attach button to Quest Title linePool
                    secondaryButton:SetPoint("TOPLEFT", line, "TOPLEFT", QuestFocusButton.GetColumnWidth() + 2 + questItemButtonSize, 0)
                    secondaryButton:SetParent(line)
                    secondaryButton:Show()

                    if Questie.db.char.collapsedZones[line.expandZone.zoneId] or Questie.db.char.collapsedQuests[questId] then
                        secondaryButton:SetParent(UIParent)
                        secondaryButton:Hide()
                    end
                end
            end
        else
            -- Show button when primary button was not added (e.g. the requiredSourceItems are not in the bag yet)
            line.expandQuest:Show()
        end
    elseif (Questie.db.profile.collapseCompletedQuests and isMinimizable) then
        -- Hide button if quest complete or failed
        line.expandQuest:Hide()
    else
        line.expandQuest:Show()
    end

    return true
end

---@return boolean @true if the Tracker tracks a quest, false if not
function TrackerUtils.HasQuest()
    local hasQuest

    if (QuestieTracker.GetNumTrackedQuests() == 0) then
        hasQuest = AchievementTracking.HasTrackedAchievements()
    else
        if not Questie.db.profile.trackerShowCompleteQuests then
            local isTrackingIncompleteQuest = false
            for _, quest in pairs(TrackerData.GetQuests()) do
                if QuestieTracker.IsTrackedByQuestie(quest.Id)
                    and ((quest:IsComplete() ~= 1 and not quest.isComplete) or quest.trackTimedQuest or quest.timedBlizzardQuest) then
                    isTrackingIncompleteQuest = true
                    break
                end
            end

            -- This hides the Tracker when all tracked Quests are complete
            if (not isTrackingIncompleteQuest) then
                hasQuest = false
            else
                hasQuest = true
            end
        else
            hasQuest = true
        end
    end

    -- Recipes whose data is not loaded yet are not shown, so only the shown ones keep the tracker visible
    if (not hasQuest) and TrackerRecipes.HasShownRecipes() then
        hasQuest = true
    end

    Questie.Debug(Questie.DEBUG_SPAM, "[TrackerUtils.HasQuest] - ", hasQuest)
    return hasQuest
end
