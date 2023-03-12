local _QuestLogScrollBar = QuestLogListScrollFrame.ScrollBar or QuestLogListScrollFrameScrollBar

---@class TrackerUtils
local TrackerUtils = QuestieLoader:ImportModule("TrackerUtils")

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

local objectiveFlashTicker = {}
local zoneCache = {}

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
            if(QuestLogEx) then
                QuestLogEx:Maximize();
            end
        else
            Questie:Print(l10n("Can't open Quest Log while in combat. Open it manually."))
        end
    end

    QuestLog_UpdateQuestDetails()
    QuestLog_Update()
end

function TrackerUtils:SetTomTomTarget(title, zone, x, y)
    if TomTom and TomTom.AddWaypoint then
        if Questie.db.char._tom_waypoint and TomTom.RemoveWaypoint then -- remove old waypoint
            TomTom:RemoveWaypoint(Questie.db.char._tom_waypoint)
        end
        local uiMapId = ZoneDB:GetUiMapIdByAreaId(zone)
        Questie.db.char._tom_waypoint = TomTom:AddWaypoint(uiMapId, x/100, y/100,  {title = title, crazy = true})
    end
end

function TrackerUtils:ShowObjectiveOnMap(objective)
    local spawn, zone = QuestieMap:GetNearestSpawn(objective)
    if spawn then
        WorldMapFrame:Show()
        local uiMapId = ZoneDB:GetUiMapIdByAreaId(zone)
        WorldMapFrame:SetMapID(uiMapId)
        TrackerUtils:FlashObjective(objective)
    end
end

function TrackerUtils:ShowFinisherOnMap(quest)
    local spawn, zone = QuestieMap:GetNearestQuestSpawn(quest)
    if spawn then
        WorldMapFrame:Show()
        local uiMapId = ZoneDB:GetUiMapIdByAreaId(zone)
        WorldMapFrame:SetMapID(uiMapId)
        TrackerUtils:FlashFinisher(quest)
    end
end

function TrackerUtils:FlashObjective(objective) -- really terrible animation code, sorry guys
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

function TrackerUtils:FlashFinisher(quest) -- really terrible animation copypasta, sorry guys
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

function TrackerUtils:IsBindTrue(bind, button)
    return bind and button and bindTruthTable[bind] and bindTruthTable[bind](button)
end

---@param zoneId AreaId
---@return Name Name of zone (localized)
local function GetZoneNameByIDFallback(zoneId)
    if zoneCache[zoneId] then
        return zoneCache[zoneId]
    end
    for _, zones in pairs(l10n.zoneLookup) do
        for zoneIDnum, zoneName in pairs(zones) do
            if zoneIDnum == zoneId then
                local translatedZoneName = l10n(zoneName)
                zoneCache[zoneId] = translatedZoneName
                return translatedZoneName
            end
        end
    end
    return "Unknown Zone"
end

---@param zoneId AreaId
---@return Name ZoneName of zone (localized)
function TrackerUtils:GetZoneNameByID(zoneId)
    if C_Map and C_Map.GetAreaInfo then
        local name = C_Map.GetAreaInfo(zoneId)
        return name or GetZoneNameByIDFallback(zoneId)
    else
        return GetZoneNameByIDFallback(zoneId)
    end
end


---@param catId CategoryId
---@return Name CategoryName
function TrackerUtils:GetCategoryNameByID(catId)
    for cat, name in pairs(l10n.questCategoryLookup) do
        if catId == cat then
            return l10n(name)
        end
    end
    return "Unknown Category"
end

function TrackerUtils:UnFocus()
    -- reset HideIcons to match savedvariable state
    if (not Questie.db.char.TrackerFocus) then
        return
    end
    for questId in pairs (QuestiePlayer.currentQuestlog) do
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

function TrackerUtils:FocusObjective(questId, objectiveIndex)
    if Questie.db.char.TrackerFocus and (type(Questie.db.char.TrackerFocus) ~= "string" or Questie.db.char.TrackerFocus ~= tostring(questId) .. " " .. tostring(objectiveIndex)) then
        TrackerUtils:UnFocus()
    end

    Questie.db.char.TrackerFocus = tostring(questId) .. " " .. tostring(objectiveIndex)
    for questLogQuestId in pairs (QuestiePlayer.currentQuestlog) do
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

function TrackerUtils:FocusQuest(questId)
    if Questie.db.char.TrackerFocus and (type(Questie.db.char.TrackerFocus) ~= "number" or Questie.db.char.TrackerFocus ~= questId) then
        TrackerUtils:UnFocus()
    end

    Questie.db.char.TrackerFocus = questId
    for questLogQuestId in pairs (QuestiePlayer.currentQuestlog) do
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
