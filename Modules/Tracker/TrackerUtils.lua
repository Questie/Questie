---@class TrackerUtils
local TrackerUtils = QuestieLoader:ImportModule("TrackerUtils")
-------------------------
--Import QuestieTracker modules.
-------------------------
---@type QuestieTracker
local QuestieTracker = QuestieLoader:ImportModule("QuestieTracker")
-------------------------
--Import Questie modules.
-------------------------
---@type QuestiePlayer
local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestieMap
local QuestieMap = QuestieLoader:ImportModule("QuestieMap")
---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule("ZoneDB")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local tinsert = table.insert

local objectiveFlashTicker
local zoneCache = {}
local questCompletePercent = {}
local playerPosition, questProximityTimer
local bindTruthTable = {
    ['left'] = function(button)
        return "LeftButton" == button
    end,
    ['right'] = function(button)
        return "RightButton" == button
    end,
    ['shiftleft'] = function(button)
        return "LeftButton" == button and IsShiftKeyDown()
    end,
    ['shiftright'] = function(button)
        return "RightButton" == button and IsShiftKeyDown()
    end,
    ['ctrlleft'] = function(button)
        return "LeftButton" == button and IsControlKeyDown()
    end,
    ['ctrlright'] = function(button)
        return "RightButton" == button and IsControlKeyDown()
    end,
    ['altleft'] = function(button)
        return "LeftButton" == button and IsAltKeyDown()
    end,
    ['altright'] = function(button)
        return "RightButton" == button and IsAltKeyDown()
    end,
    ['disabled'] = function() return false; end,
}

local _QuestLogScrollBar = QuestLogListScrollFrame.ScrollBar or QuestLogListScrollFrameScrollBar

---@param quest table
function TrackerUtils:ShowQuestLog(quest)
    -- Priority order first check if addon exist otherwise default to original
    local questFrame = QuestLogExFrame or ClassicQuestLog or QuestLogFrame;
    --HideUIPanel(questFrame); -- don't use as I don't see why to use and protected function taints in combat
    local questLogIndex = GetQuestLogIndexByID(quest.Id);
    SelectQuestLogEntry(questLogIndex)

    -- Scroll to the quest in the quest log
    local scrollSteps = _QuestLogScrollBar:GetValueStep()
    _QuestLogScrollBar:SetValue(questLogIndex * scrollSteps - scrollSteps * 3);

    if not questFrame:IsShown() then
        if not InCombatLockdown() then
            ShowUIPanel(questFrame)

            --Addon specific behaviors
            if (QuestLogEx) then
                QuestLogEx:Maximize();
            end
        else
            Questie:Print(l10n("Can't open Quest Log while in combat. Open it manually."))
        end
    end

    QuestLog_UpdateQuestDetails()
    QuestLog_Update()
end

---@param title string
---@param zone number
---@param x number
---@param y number
function TrackerUtils:SetTomTomTarget(title, zone, x, y)
    if TomTom and TomTom.AddWaypoint then
        if Questie.db.char._tom_waypoint and TomTom.RemoveWaypoint then -- remove old waypoint
            TomTom:RemoveWaypoint(Questie.db.char._tom_waypoint)
        end
        local uiMapId = ZoneDB:GetUiMapIdByAreaId(zone)
        Questie.db.char._tom_waypoint = TomTom:AddWaypoint(uiMapId, x / 100, y / 100, { title = title, crazy = true })
    end
end

---@param objective table
function TrackerUtils:ShowObjectiveOnMap(objective)
    local spawn, zone = QuestieMap:GetNearestSpawn(objective)
    if spawn then
        WorldMapFrame:Show()
        local uiMapId = ZoneDB:GetUiMapIdByAreaId(zone)
        WorldMapFrame:SetMapID(uiMapId)
        TrackerUtils:FlashObjective(objective)
    end
end

---@param quest table
function TrackerUtils:ShowFinisherOnMap(quest)
    local spawn, zone = QuestieMap:GetNearestQuestSpawn(quest)
    if spawn then
        WorldMapFrame:Show()
        local uiMapId = ZoneDB:GetUiMapIdByAreaId(zone)
        WorldMapFrame:SetMapID(uiMapId)
        TrackerUtils:FlashFinisher(quest)
    end
end

---@param objective table
function TrackerUtils:FlashObjective(objective)
    if next(objective.AlreadySpawned) then
        local toFlash = {}
        -- ugly code
        for _, framelist in pairs(QuestieMap.questIdFrames) do
            for _, frameName in pairs(framelist) do
                local icon = _G[frameName];
                if not icon.miniMapIcon then
                    -- todo: move into frame.session
                    if icon:IsShown() then
                        icon._hidden_by_flash = true
                        icon:Hide()
                    end
                end
            end
        end


        for _, spawn in pairs(objective.AlreadySpawned) do
            if spawn.mapRefs then
                for _, frame in pairs(spawn.mapRefs) do
                    tinsert(toFlash, frame)
                    if frame._hidden_by_flash then
                        frame:Show()
                    end

                    -- todo: move into frame.session
                    frame._hidden_by_flash = nil
                    frame._size = frame:GetWidth()
                end
            end
        end
        local flashW = 1
        local flashB = true
        local flashDone = 0
        objectiveFlashTicker = C_Timer.NewTicker(0.1, function()
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
                                objectiveFlashTicker:Cancel()
                                for _, frame in pairs(toFlash) do
                                    frame:SetWidth(frame._size)
                                    frame:SetHeight(frame._size)
                                    frame._size = nil
                                end
                            end)
                            C_Timer.After(0.5, function()
                                for _, framelist in pairs(QuestieMap.questIdFrames) do
                                    for _, frameName in pairs(framelist) do
                                        local icon = _G[frameName];
                                        if icon._hidden_by_flash then
                                            icon._hidden_by_flash = nil
                                            icon:Show()
                                        end
                                    end
                                end
                            end)
                        end
                        flashDone = flashDone + 1
                    end
                end
            end
        end)
    end
end

---@param quest table
function TrackerUtils:FlashFinisher(quest)
    local toFlash = {}
    -- ugly code
    for questId, framelist in pairs(QuestieMap.questIdFrames) do
        if questId ~= quest.Id then
            for _, frameName in pairs(framelist) do
                local icon = _G[frameName];
                if not icon.miniMapIcon then
                    -- todo: move into frame.session
                    if icon:IsShown() then
                        icon._hidden_by_flash = true
                        icon:Hide()
                    end
                end
            end
        else
            for _, frameName in ipairs(framelist) do
                local icon = _G[frameName];
                if not icon.miniMapIcon then
                    icon._size = icon:GetWidth()
                    tinsert(toFlash, icon)
                end
            end
        end
    end

    local flashW = 1
    local flashB = true
    local flashDone = 0
    objectiveFlashTicker = C_Timer.NewTicker(0.1, function()
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
                            objectiveFlashTicker:Cancel()
                            for _, frame in pairs(toFlash) do
                                frame:SetWidth(frame._size)
                                frame:SetHeight(frame._size)
                                frame._size = nil
                            end
                        end)
                        C_Timer.After(0.5, function()
                            for _, framelist in pairs(QuestieMap.questIdFrames) do
                                for _, frameName in pairs(framelist) do
                                    local icon = _G[frameName];
                                    if icon._hidden_by_flash then
                                        icon._hidden_by_flash = nil
                                        icon:Show()
                                    end
                                end
                            end
                        end)
                    end
                    flashDone = flashDone + 1
                end
            end
        end
    end)
end

---@param bind string
---@param button string
---@return string bind Keybind
---@return string button Mouse Button
---@return string bind Returns matched bindTruthTable table key
---@return function function Returns bindTruthTable table key and matched function
---@return boolean false If the keybind is not set
function TrackerUtils:IsBindTrue(bind, button)
    return bind and button and bindTruthTable[bind] and bindTruthTable[bind](button)
end

---@param zoneId number
---@return string translatedZoneName Zone Name (Localized)
local function GetZoneNameByIDFallback(zoneId)
    local translatedZoneName

    if zoneCache[zoneId] then
        translatedZoneName = zoneCache[zoneId]
    end

    for _, zones in pairs(l10n.zoneLookup) do
        for zoneIDnum, zoneName in pairs(zones) do
            if zoneIDnum == zoneId then
                translatedZoneName = l10n(zoneName)
                zoneCache[zoneId] = translatedZoneName
            else
                translatedZoneName = "Unknown Zone"
            end
        end
    end

    return translatedZoneName
end

---@param zoneId number
---@return string translatedZoneName Zone Name (Localized)
function TrackerUtils:GetZoneNameByID(zoneId)
    local translatedZoneName
    if C_Map and C_Map.GetAreaInfo then
        local name = C_Map.GetAreaInfo(zoneId)
        translatedZoneName = name or GetZoneNameByIDFallback(zoneId)
    else
        translatedZoneName = GetZoneNameByIDFallback(zoneId)
    end

    return translatedZoneName
end

---@param catId number
---@return string translatedCatId Category Name (Localized)
function TrackerUtils:GetCategoryNameByID(catId)
    local translatedCatId

    for cat, name in pairs(l10n.questCategoryLookup) do
        if catId == cat then
            translatedCatId = l10n(name)
        else
            translatedCatId = "Unknown Category"
        end
    end

    return translatedCatId
end

function TrackerUtils:UnFocus()
    -- reset HideIcons to match savedvariable state
    if (not Questie.db.char.TrackerFocus) then
        return
    end
    for questId in pairs(QuestiePlayer.currentQuestlog) do
        local quest = QuestieDB:GetQuest(questId)

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

                for _, objective in pairs(quest.Objectives) do
                    if Questie.db.char.TrackerHiddenObjectives[tostring(questId) .. " " .. tostring(objective.Index)] then
                        objective.HideIcons = true
                        objective.FadeIcons = nil
                    else
                        objective.HideIcons = nil
                        objective.FadeIcons = nil
                    end
                end

                for _, objective in pairs(quest.SpecialObjectives) do
                    if Questie.db.char.TrackerHiddenObjectives[tostring(questId) .. " " .. tostring(objective.Index)] then
                        objective.HideIcons = true
                        objective.FadeIcons = nil
                    else
                        objective.HideIcons = nil
                        objective.FadeIcons = nil
                    end
                end
            end
        end
    end

    Questie.db.char.TrackerFocus = nil
end

---@param questId number
---@param objectiveIndex number
function TrackerUtils:FocusObjective(questId, objectiveIndex)
    if Questie.db.char.TrackerFocus and (type(Questie.db.char.TrackerFocus) ~= "string" or Questie.db.char.TrackerFocus ~= tostring(questId) .. " " .. tostring(objectiveIndex)) then
        TrackerUtils:UnFocus()
    end

    Questie.db.char.TrackerFocus = tostring(questId) .. " " .. tostring(objectiveIndex)
    for questLogQuestId in pairs(QuestiePlayer.currentQuestlog) do
        local quest = QuestieDB:GetQuest(questLogQuestId)
        if quest and next(quest.Objectives) then
            if questLogQuestId == questId then
                quest.HideIcons = nil
                quest.FadeIcons = nil

                for _, objective in pairs(quest.Objectives) do
                    if objective.Index == objectiveIndex then
                        objective.HideIcons = nil
                        objective.FadeIcons = nil
                    else
                        objective.FadeIcons = true
                    end
                end

                for _, objective in pairs(quest.SpecialObjectives) do
                    if objective.Index == objectiveIndex then
                        objective.HideIcons = nil
                        objective.FadeIcons = nil
                    else
                        objective.FadeIcons = true
                    end
                end
            else
                quest.FadeIcons = true
            end
        end
    end
end

---@param questId number
function TrackerUtils:FocusQuest(questId)
    if Questie.db.char.TrackerFocus and (type(Questie.db.char.TrackerFocus) ~= "number" or Questie.db.char.TrackerFocus ~= questId) then
        TrackerUtils:UnFocus()
    end

    Questie.db.char.TrackerFocus = questId
    for questLogQuestId in pairs(QuestiePlayer.currentQuestlog) do
        local quest = QuestieDB:GetQuest(questLogQuestId)
        if quest then
            if questLogQuestId == questId then
                quest.HideIcons = nil
                quest.FadeIcons = nil
            else
                quest.FadeIcons = true
            end
        end
    end
end

---@param zoneOrtSort string
function TrackerUtils:ReportErrorMessage(zoneOrtSort)
    Questie:Error("SortID: |cffffbf00" .. zoneOrtSort .. "|r was not found in the Database. Please file a bugreport at:")
    Questie:Error("|cff00bfffhttps://github.com/Questie/Questie/issues|r")
end

---@return number|nil worldPosition
local function _GetWorldPlayerPosition()
    -- Turns coords into 'world' coords so it can be compared with any coords in another zone
    local uiMapId = C_Map.GetBestMapForUnit("player")
    local mapPosition = C_Map.GetPlayerMapPosition(uiMapId, "player")
    local worldPosition = select(2, C_Map.GetWorldPosFromMapPos(uiMapId, mapPosition))

    if (not uiMapId) then
        worldPosition = nil
    end

    if (not mapPosition) or (not mapPosition.x) then
        worldPosition = nil
    end

    return worldPosition
end

---@param x1 number
---@param y1 number
---@param x2 number
---@param y2 number
---@return number
local function _GetDistance(x1, y1, x2, y2)
    -- Basic proximity distance calculation to compare two locs (normally player position and provided loc)
    return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2);
end

---@param questId number
local function _GetDistanceToClosestObjective(questId)
    -- main function for proximity sorting
    local player = _GetWorldPlayerPosition();

    if (not player) then
        return nil
    end

    local coordinates = {};
    local quest = QuestieDB:GetQuest(questId);

    if (not quest) then
        return nil
    end

    local spawn, zone, name = QuestieMap:GetNearestQuestSpawn(quest)

    if (not spawn) or (not zone) or (not name) then
        return nil
    end

    local uiMapId = ZoneDB:GetUiMapIdByAreaId(zone)
    if not uiMapId then
        return nil
    end
    local _, worldPosition = C_Map.GetWorldPosFromMapPos(uiMapId, {
        x = spawn[1] / 100,
        y = spawn[2] / 100
    });

    tinsert(coordinates, {
        x = worldPosition.x,
        y = worldPosition.y
    });

    if (not coordinates) then
        return nil
    end

    local closestDistance;
    for _, _ in pairs(coordinates) do
        local distance = _GetDistance(player.x, player.y, worldPosition.x, worldPosition.y);
        if (not closestDistance) or (distance < closestDistance) then
            closestDistance = distance;
        end
    end

    return closestDistance;
end

---@param uiMapId number
local function _GetContinent(uiMapId)
    if (not uiMapId) then
        return
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

function TrackerUtils:GetSortedQuestIds()
    local sortedQuestIds = {}
    -- Update quest objectives
    for questId in pairs(QuestiePlayer.currentQuestlog) do
        local quest = QuestieDB:GetQuest(questId)
        if quest then
            if quest:IsComplete() == 1 or (not next(quest.Objectives)) then
                questCompletePercent[quest.Id] = 1
            else
                local percent = 0
                local count = 0
                for _, Objective in pairs(quest.Objectives) do
                    percent = percent + (Objective.Collected / Objective.Needed)
                    count = count + 1
                end
                percent = percent / count
                questCompletePercent[quest.Id] = percent
            end
            table.insert(sortedQuestIds, questId)
        end
    end

    -- Quests and objectives sort
    if Questie.db.global.trackerSortObjectives == "byComplete" then
        table.sort(sortedQuestIds, function(a, b)
            local vA, vB = questCompletePercent[a], questCompletePercent[b]
            if vA == vB then
                local qA = QuestieDB:GetQuest(a)
                local qB = QuestieDB:GetQuest(b)
                return qA and qB and qA.level < qB.level
            end
            return vB < vA
        end)
    elseif Questie.db.global.trackerSortObjectives == "byLevel" then
        table.sort(sortedQuestIds, function(a, b)
            local qA = QuestieDB:GetQuest(a)
            local qB = QuestieDB:GetQuest(b)
            return qA and qB and qA.level < qB.level
        end)
    elseif Questie.db.global.trackerSortObjectives == "byLevelReversed" then
        table.sort(sortedQuestIds, function(a, b)
            local qA = QuestieDB:GetQuest(a)
            local qB = QuestieDB:GetQuest(b)
            return qA and qB and qA.level > qB.level
        end)
    elseif Questie.db.global.trackerSortObjectives == "byZone" then
        table.sort(sortedQuestIds, function(a, b)
            local qA = QuestieDB:GetQuest(a)
            local qB = QuestieDB:GetQuest(b)
            local qAZone, qBZone
            if qA.zoneOrSort > 0 then
                qAZone = TrackerUtils:GetZoneNameByID(qA.zoneOrSort)
            elseif qA.zoneOrSort < 0 then
                qAZone = TrackerUtils:GetCategoryNameByID(qA.zoneOrSort)
            else
                qAZone = tostring(qA.zoneOrSort)
                TrackerUtils:ReportErrorMessage(qAZone)
            end

            if qB.zoneOrSort > 0 then
                qBZone = TrackerUtils:GetZoneNameByID(qB.zoneOrSort)
            elseif qB.zoneOrSort < 0 then
                qBZone = TrackerUtils:GetCategoryNameByID(qB.zoneOrSort)
            else
                qBZone = tostring(qB.zoneOrSort)
                TrackerUtils:ReportErrorMessage(qBZone)
            end

            -- Sort by Zone then by Level to mimic QuestLog sorting
            if qAZone == qBZone then
                return qA.level < qB.level
            else
                if qAZone ~= nil and qBZone ~= nil then
                    return qAZone < qBZone
                else
                    return qAZone and qBZone
                end
            end
        end)
    elseif Questie.db.global.trackerSortObjectives == "byProximity" then
        local toSort = {}
        local continent = _GetContinent(C_Map.GetBestMapForUnit("player"))

        for _, questId in pairs(sortedQuestIds) do
            local sortData = {}

            sortData.questId = questId
            sortData.distance = _GetDistanceToClosestObjective(questId)
            sortData.q = QuestieDB:GetQuest(questId)

            local _, zone, _ = QuestieMap:GetNearestQuestSpawn(sortData.q)

            sortData.zone = zone
            sortData.continent = _GetContinent(ZoneDB:GetUiMapIdByAreaId(zone))
            toSort[questId] = sortData
        end

        local sorter = function(a, b)
            a = toSort[a]
            b = toSort[b]
            if ((continent == a.continent) and (continent == b.continent)) or ((continent ~= a.continent) and (continent ~= b.continent)) then
                if a.distance == b.distance then
                    return a.q and b.q and a.q.level < b.q.level;
                end

                if not a.distance and b.distance then
                    return false;
                elseif a.distance and not b.distance then
                    return true;
                end

                return a.distance < b.distance;
            elseif (continent == a.continent) and (continent ~= b.continent) then
                return true
            elseif (continent ~= a.continent) and (continent == b.continent) then
                return false
            end
        end

        table.sort(sortedQuestIds, sorter)

        if not questProximityTimer then
            TrackerUtils.UpdateQuestProximityTimer(sortedQuestIds, sorter)
        end
    end

    if (Questie.db.global.trackerSortObjectives ~= "byProximity") and questProximityTimer and questProximityTimer ~= nil then
        Questie:Debug(Questie.DEBUG_DEVELOP, "TrackerUtils.UpdateQuestProximityTimer - Stoped!")
        questProximityTimer:Cancel()
        questProximityTimer = nil
    end

    return sortedQuestIds, questCompletePercent
end

---@param sortedQuestIds number
---@param sorter function
function TrackerUtils.UpdateQuestProximityTimer(sortedQuestIds, sorter)
    Questie:Debug(Questie.DEBUG_DEVELOP, "TrackerUtils.UpdateQuestProximityTimer - Started!")
    -- Check location often and update if you've moved
    C_Timer.After(3.0, function()
        questProximityTimer = C_Timer.NewTicker(5.0, function()
            local position = _GetWorldPlayerPosition()
            if position then
                local distance = playerPosition and _GetDistance(position.x, position.y, playerPosition.x, playerPosition.y)
                if not distance or distance > 0.01 then -- Position has changed
                    Questie:Debug(Questie.DEBUG_SPAM, "TrackerUtils.questProximityTimer")
                    playerPosition = position
                    local orderCopy = {}

                    for index, val in pairs(sortedQuestIds) do
                        orderCopy[index] = val
                    end

                    table.sort(orderCopy, sorter)

                    for index, val in pairs(sortedQuestIds) do
                        if orderCopy[index] ~= val then -- The order has changed
                            break
                        end
                    end
                    QuestieTracker:Update()
                end
            end
        end)
    end)
end
