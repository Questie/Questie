---@class TrackerUtils
local TrackerUtils = QuestieLoader:ImportModule("TrackerUtils")
-------------------------
--Import QuestieTracker modules.
-------------------------
---@type QuestieTracker
local QuestieTracker = QuestieLoader:ImportModule("QuestieTracker")
---@type TrackerLinePool
local TrackerLinePool = QuestieLoader:ImportModule("TrackerLinePool")
---@type TrackerFadeTicker
local TrackerFadeTicker = QuestieLoader:ImportModule("TrackerFadeTicker")
---@type QuestieCombatQueue
local QuestieCombatQueue = QuestieLoader:ImportModule("QuestieCombatQueue")
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
local questProximityTimer = nil
local questZoneProximityTimer = nil
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
    ['disabled'] = function() return false end,
}

local _QuestLogScrollBar = QuestLogListScrollFrame.ScrollBar or QuestLogListScrollFrameScrollBar

---@param quest table The table provided by QuestieDB:GetQuest(questId)
function TrackerUtils:ShowQuestLog(quest)
    -- Priority order first check if addon exist otherwise default to original
    local questFrame = QuestLogExFrame or ClassicQuestLog or QuestLogFrame
    --HideUIPanel(questFrame) -- don't use as I don't see why to use and protected function taints in combat
    local questLogIndex = GetQuestLogIndexByID(quest.Id)
    SelectQuestLogEntry(questLogIndex)

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

    QuestLog_UpdateQuestDetails()
    QuestLog_Update()
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
        Questie.db.char._tom_waypoint = TomTom:AddWaypoint(uiMapId, x / 100, y / 100, { title = title, crazy = true })
    end
end

---@param objective table The table provided by QuestieDB:GetQuest(questId).Objectives[objective]
function TrackerUtils:ShowObjectiveOnMap(objective)
    local spawn, zone = QuestieMap:GetNearestSpawn(objective)
    if spawn then
        WorldMapFrame:Show()
        local uiMapId = ZoneDB:GetUiMapIdByAreaId(zone)
        WorldMapFrame:SetMapID(uiMapId)
        TrackerUtils:FlashObjective(objective)
    end
end

---@param quest table The table provided by QuestieDB:GetQuest(questId)
function TrackerUtils:ShowFinisherOnMap(quest)
    local spawn, zone = QuestieMap:GetNearestQuestSpawn(quest)
    if spawn then
        WorldMapFrame:Show()
        local uiMapId = ZoneDB:GetUiMapIdByAreaId(zone)
        WorldMapFrame:SetMapID(uiMapId)
        TrackerUtils:FlashFinisher(quest)
    end
end

---@param objective table The table provided by QuestieDB:GetQuest(questId).Objectives[objective]
function TrackerUtils:FlashObjective(objective)
    if next(objective.AlreadySpawned) then
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
                                        local icon = _G[frameName]
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

---@param quest table The table provided by QuestieDB:GetQuest(questId)
function TrackerUtils:FlashFinisher(quest)
    local toFlash = {}
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
            for _, frameName in ipairs(framelist) do
                local icon = _G[frameName]
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
                                    local icon = _G[frameName]
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

---@param quest table Quest Table
---@return string|nil completionText Quest Completion text string or nil
function TrackerUtils:GetCompletionText(quest)
    local questIndex = GetQuestLogIndexByID(quest.Id)
    local completionText

    if Questie.IsWotlk then
        completionText = GetQuestLogCompletionText(questIndex)
    else
        completionText = quest.Description[1]:gsub("%.", "")
    end

    if completionText then
        return completionText
    else
        return nil
    end
end

---@param zoneId number Zone ID number
---@return string @Zone Name (Localized) or "Unknown Zone"
local function GetZoneNameByIDFallback(zoneId)
    if zoneCache[zoneId] then
        return zoneCache[zoneId]
    end

    for _, zone in pairs(l10n.zoneLookup) do
        if zone and type(zoneId) == "number" and zoneId > 0 and (l10n.zoneLookup[zone][zoneId]) == "string" then
            zoneCache[zoneId] = l10n.zoneLookup[zone][zoneId]
            return zoneCache[zoneId]
        end
    end

    return "Unknown Zone"
end

---@param zoneId number Zone ID number
---@return string @Zone Name (Localized)
function TrackerUtils:GetZoneNameByID(zoneId)
    if zoneCache[zoneId] then
        return zoneCache[zoneId]
    end

    if C_Map and C_Map.GetAreaInfo(zoneId) then
        zoneCache[zoneId] = C_Map.GetAreaInfo(zoneId)
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
        zoneCache[catId] = l10n.questCategoryLookup[catId]
        return zoneCache[catId]
    end

    return "Unknown Category"
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

---@param questId number Quest ID number
---@param objectiveIndex number Objective Index number
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

---@param questId number Quest ID number
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

---@param zoneOrSort string The name of the Zone
function TrackerUtils:ReportErrorMessage(zoneOrSort)
    Questie:Error("SortID: |cffffbf00" .. zoneOrSort .. "|r was not found in the Database. Please file a bugreport at:")
    Questie:Error("|cff00bfffhttps://github.com/Questie/Questie/issues|r")
end

---@return table|nil position Retuns Players current X/Y coordinates or nil if a Players postion can't be determined
local function _GetWorldPlayerPosition()
    -- Turns coords into 'world' coords so it can be compared with any coords in another zone
    local uiMapId = C_Map.GetBestMapForUnit("player")
    if (not uiMapId) then
        return nil
    end

    local mapPosition = C_Map.GetPlayerMapPosition(uiMapId, "player")
    if (not mapPosition) or (not mapPosition.x) then
        return nil
    end

    local worldPosition = select(2, C_Map.GetWorldPosFromMapPos(uiMapId, mapPosition))
    local position = {
        x = worldPosition.x,
        y = worldPosition.y
    }

    return position
end

---@param x1 number Current Position X
---@param y1 number Current Position Y
---@param x2 number Previous Position X
---@param y2 number Previous Position Y
---@return number Distance @Distance between Current and Previous X/Y coordinates
local function _GetDistance(x1, y1, x2, y2)
    return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
end

---@param questId number Quest ID number
---@return number|nil closestDistance Returns X/Y coordinates to closest Objective or nil if nothing is found
local function _GetDistanceToClosestObjective(questId)
    -- main function for proximity sorting
    local player = _GetWorldPlayerPosition()

    if (not player) then
        return nil
    end

    local coordinates = {}
    local quest = QuestieDB:GetQuest(questId)

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
    })

    tinsert(coordinates, {
        x = worldPosition.x,
        y = worldPosition.y
    })

    if (not coordinates) then
        return nil
    end

    local closestDistance
    for _, _ in pairs(coordinates) do
        local distance = _GetDistance(player.x, player.y, worldPosition.x, worldPosition.y)
        if (not closestDistance) or (distance < closestDistance) then
            closestDistance = distance
        end
    end

    return closestDistance
end

---@param uiMapId number Continent ID number
---@return string Continent Returns Continent Name or "UNKNOW"
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

local function _GetZoneName(zoneOrSort)
    if not zoneOrSort then return end
    local zoneName
    local sortObj = Questie.db.global.trackerSortObjectives
    if sortObj == "byZone" or sortObj == "byZonePlayerProximity" or sortObj == "byZonePlayerProximityReversed" then
        if (zoneOrSort) > 0 then
            -- Valid ZoneID
            zoneName = TrackerUtils:GetZoneNameByID(zoneOrSort)
        elseif (zoneOrSort) < 0 then
            -- Valid CategoryID
            zoneName = TrackerUtils:GetCategoryNameByID(zoneOrSort)
        else
            -- Probobly not in the Database. Assign zoneOrSort ID so Questie doesn't error
            zoneName = tostring(zoneOrSort)
            TrackerUtils:ReportErrorMessage(zoneName)
        end
    else
        -- Let's create custom Zones based on Sorting type.
        if sortObj == "byComplete" then
            zoneName = "Quests (By % Complete)"
        elseif sortObj == "byCompleteReversed" then
            zoneName = "Quests (By % Complete Reversed)"
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
    return zoneName
end

---@return table sortedQuestIds Table with sorted Quest ID's by Sort Type
---@return table questDetails Table with raw quest table from QuestiePlayer.currentQuestLog, percentage completed value per quest, and a "translated" zoneName
function TrackerUtils:GetSortedQuestIds()
    local sortedQuestIds = {}
    local questDetails = {}
    local sortObj = Questie.db.global.trackerSortObjectives
    -- Update quest objectives
    for questId, quest in pairs(QuestiePlayer.currentQuestlog) do
        if quest then
            -- Insert Quest Ids into sortedQuestIds table
            tinsert(sortedQuestIds, questId)

            -- Create questDetails table keys and insert values
            questDetails[quest.Id] = {}
            questDetails[quest.Id].quest = quest
            questDetails[quest.Id].zoneName = _GetZoneName(quest.zoneOrSort)

            if quest:IsComplete() == 1 or (not next(quest.Objectives)) then
                questDetails[quest.Id].questCompletePercent = 1
            else
                local percent = 0
                local count = 0
                for _, Objective in pairs(quest.Objectives) do
                    percent = percent + (Objective.Collected / Objective.Needed)
                    count = count + 1
                end
                percent = percent / count

                questDetails[quest.Id].questCompletePercent = percent
            end
        end
    end

    -- Quests and objectives sort
    if sortObj == "byComplete" or sortObj == "byCompleteReversed" then
        table.sort(sortedQuestIds, function(a, b)
            local vA, vB = questDetails[a].questCompletePercent, questDetails[b].questCompletePercent
            if vA == vB then
                local qA = questDetails[a].quest
                local qB = questDetails[b].quest
                return qA and qB and qA.level < qB.level
            end

            if sortObj == "byComplete" then
                return vB < vA
            else
                return vB > vA
            end
        end)
    elseif sortObj == "byLevel" or sortObj == "byLevelReversed" then
        table.sort(sortedQuestIds, function(a, b)
            local qA = questDetails[a].quest
            local qB = questDetails[b].quest
            if sortObj == "byLevel" then
                return qA and qB and qA.level < qB.level
            else
                return qA and qB and qA.level > qB.level
            end
        end)
    elseif sortObj == "byZone" then
        table.sort(sortedQuestIds, function(a, b)
            local qA = questDetails[a].quest
            local qB = questDetails[b].quest
            local qAZone = questDetails[a].zoneName
            local qBZone = questDetails[b].zoneName

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
    elseif sortObj == "byZonePlayerProximity" or sortObj == "byZonePlayerProximityReversed" then
        local toSort = {}
        local continent = _GetContinent(C_Map.GetBestMapForUnit("player"))

        for _, questId in pairs(sortedQuestIds) do
            local sortData = {}
            sortData.questId = questId
            sortData.distance = _GetDistanceToClosestObjective(questId)
            sortData.q = questDetails[questId].quest

            local _, zone, _ = QuestieMap:GetNearestQuestSpawn(sortData.q)
            sortData.zone = zone
            sortData.continent = _GetContinent(ZoneDB:GetUiMapIdByAreaId(zone))
            toSort[questId] = sortData
        end

        local sorter = function(a, b)
            local qA = questDetails[a].quest
            local qB = questDetails[b].quest
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
                -- Sort by Zone
                if qAZone ~= nil and qBZone ~= nil then
                    return qAZone < qBZone
                else
                    return qAZone and qBZone
                end
            end
        end

        local sorterReversed = function(a, b)
            local qA = questDetails[a].quest
            local qB = questDetails[b].quest
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
                -- Sort by Zone
                if qAZone ~= nil and qBZone ~= nil then
                    return qAZone < qBZone
                else
                    return qAZone and qBZone
                end
            end
        end

        if sortObj == "byZonePlayerProximity" then
            table.sort(sortedQuestIds, sorter)
        else
            table.sort(sortedQuestIds, sorterReversed)
        end

        if not questZoneProximityTimer and not IsInInstance() then
            -- Check location often and update if you've moved
            Questie:Debug(Questie.DEBUG_DEVELOP, "[TrackerUtils:GetSortedQuestIds] - Zone Proximity Timer Started!")

            local playerPosition
            questZoneProximityTimer = C_Timer.NewTicker(5.0, function()
                if IsInInstance() and questZoneProximityTimer then
                    Questie:Debug(Questie.DEBUG_DEVELOP, "[TrackerUtils:GetSortedQuestIds] - Zone Proximity Timer Stoped!")
                    questZoneProximityTimer:Cancel()
                    questZoneProximityTimer = nil
                else
                    local position = _GetWorldPlayerPosition()
                    if position then
                        local distance = playerPosition and _GetDistance(position.x, position.y, playerPosition.x, playerPosition.y)
                        if not distance or distance > 0.01 then -- Position has changed
                            Questie:Debug(Questie.DEBUG_SPAM, "[TrackerUtils:GetSortedQuestIds] - Zone Proximity Timer Updated!")
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
            sortData.distance = _GetDistanceToClosestObjective(questId)
            sortData.q = questDetails[questId].quest

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
            Questie:Debug(Questie.DEBUG_DEVELOP, "[TrackerUtils:GetSortedQuestIds] - Proximity Timer Started!")

            local playerPosition
            questProximityTimer = C_Timer.NewTicker(5.0, function()
                if IsInInstance() and questProximityTimer then
                    Questie:Debug(Questie.DEBUG_DEVELOP, "[TrackerUtils:GetSortedQuestIds] - Proximity Timer Stoped!")
                    questProximityTimer:Cancel()
                    questProximityTimer = nil
                else
                    local position = _GetWorldPlayerPosition()
                    if position then
                        local distance = playerPosition and _GetDistance(position.x, position.y, playerPosition.x, playerPosition.y)
                        if not distance or distance > 0.01 then -- Position has changed
                            Questie:Debug(Questie.DEBUG_SPAM, "[TrackerUtils:GetSortedQuestIds] - Proximity Timer Updated!")
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
        Questie:Debug(Questie.DEBUG_DEVELOP, "[TrackerUtils:GetSortedQuestIds] - Proximity Timer Stoped!")
        questProximityTimer:Cancel()
        TrackerUtils.FilterProximityTimer = nil
        questProximityTimer = nil
    end

    if (sortObj ~= strmatch(sortObj, "byZonePlayerProximity.*")) and questZoneProximityTimer and questZoneProximityTimer ~= nil then
        Questie:Debug(Questie.DEBUG_DEVELOP, "[TrackerUtils:GetSortedQuestIds] - Zone Proximity Timer Stoped!")
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
            if IsShiftKeyDown() and MouseIsOver(Questie_BaseFrame) then
                if Questie_BaseFrame.isSizing == true or Questie_BaseFrame.isMoving == true then
                    Questie:Debug(Questie.DEBUG_SPAM, "[TrackerUtils:ShowVoiceOverPlayButtons]")
                else
                    Questie:Debug(Questie.DEBUG_INFO, "[TrackerUtils:ShowVoiceOverPlayButtons]")
                end
            end

            if IsShiftKeyDown() then
                if MouseIsOver(Questie_BaseFrame) then
                    TrackerLinePool.SetAllPlayButtonAlpha(1)
                    TrackerFadeTicker.Fade()

                    if not Questie.db.global.trackerFadeMinMaxButtons then
                        TrackerLinePool.SetAllExpandQuestAlpha(0)
                    end

                    if not Questie.db.global.trackerFadeQuestItemButtons then
                        TrackerLinePool.SetAllItemButtonAlpha(0)
                    end
                end
            else
                if MouseIsOver(Questie_BaseFrame) then
                    TrackerLinePool.SetAllPlayButtonAlpha(0)
                    TrackerFadeTicker.Unfade()
                else
                    TrackerLinePool.SetAllPlayButtonAlpha(0)
                    TrackerFadeTicker.Fade()
                end

                if not Questie.db.global.trackerFadeMinMaxButtons then
                    TrackerLinePool.SetAllExpandQuestAlpha(1)
                end

                if not Questie.db.global.trackerFadeQuestItemButtons then
                    TrackerLinePool.SetAllItemButtonAlpha(1)
                end
            end
        end
    end
end

function TrackerUtils:UpdateVoiceOverPlayButtons()
    if self:IsVoiceOverLoaded() then
        if Questie_BaseFrame.isSizing == true or Questie_BaseFrame.isMoving == true then
            Questie:Debug(Questie.DEBUG_SPAM, "[TrackerUtils:UpdateVoiceOverPlayButtons]")
        else
            Questie:Debug(Questie.DEBUG_INFO, "[TrackerUtils:UpdateVoiceOverPlayButtons]")
        end

        for i = 1, 75 do
            local title, _, _, isHeader, _, _, _, questId = GetQuestLogTitle(i)

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
