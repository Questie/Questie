---@class QuestieTrackerUtils
local QuestieTrackerUtils = QuestieLoader:CreateModule("QuestieTrackerUtils")
---@type QuestieMap
local QuestieMap = QuestieLoader:ImportModule("QuestieMap")


local objectiveFlashTicker = {}


function QuestieTrackerUtils:ShowQuestLog(quest)
    -- Priority order first check if addon exist otherwise default to original
    local questFrame = QuestLogExFrame or QuestLogFrame;
    HideUIPanel(questFrame);
    local questLogIndex = GetQuestLogIndexByID(quest.Id);
    SelectQuestLogEntry(questLogIndex)
    ShowUIPanel(questFrame);

    --Addon specific behaviors
    if(QuestLogEx) then
        QuestLogEx:Maximize();
    end

    QuestLog_UpdateQuestDetails()
    QuestLog_Update()
end

function QuestieTrackerUtils:SetTomTomTarget(title, zone, x, y)
    if TomTom and TomTom.AddWaypoint then
        if Questie.db.char._tom_waypoint and TomTom.RemoveWaypoint then -- remove old waypoint
            TomTom:RemoveWaypoint(Questie.db.char._tom_waypoint)
        end
        Questie.db.char._tom_waypoint = TomTom:AddWaypoint(ZoneDataAreaIDToUiMapID[zone], x/100, y/100,  {title = title, crazy = true})
    end
end

function QuestieTrackerUtils:ShowObjectiveOnMap(Objective)
    -- calculate nearest spawn
    local spawn, zone, name = QuestieTrackerUtils:GetNearestSpawn(Objective)
    if spawn then
        --print("Found best spawn: " .. name .. " in zone " .. tostring(zone) .. " at " .. tostring(spawn[1]) .. " " .. tostring(spawn[2]))
        WorldMapFrame:Show()
        WorldMapFrame:SetMapID(ZoneDataAreaIDToUiMapID[zone])
        QuestieTrackerUtils:FlashObjective(Objective)
    end
end

function QuestieTrackerUtils:ShowFinisherOnMap(Quest)
    -- calculate nearest spawn
    local spawn, zone, name = QuestieMap:GetNearestQuestSpawn(Quest)
    if spawn then
        --print("Found best spawn: " .. name .. " in zone " .. tostring(zone) .. " at " .. tostring(spawn[1]) .. " " .. tostring(spawn[2]))
        WorldMapFrame:Show()
        WorldMapFrame:SetMapID(ZoneDataAreaIDToUiMapID[zone])
        QuestieTrackerUtils:FlashFinisher(Quest)
    end
end

function QuestieTrackerUtils:FlashObjective(Objective) -- really terrible animation code, sorry guys
    if Objective.AlreadySpawned then
        local toFlash = {}
        -- ugly code
        for questId, framelist in pairs(QuestieMap.questIdFrames) do
            for index, frameName in ipairs(framelist) do
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


        for _, spawn in pairs(Objective.AlreadySpawned) do
            if spawn.mapRefs then
                for _, frame in pairs(spawn.mapRefs) do
                    table.insert(toFlash, frame)
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
                                for questId, framelist in pairs(QuestieMap.questIdFrames) do
                                    for index, frameName in ipairs(framelist) do
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

function QuestieTrackerUtils:FlashFinisher(Quest) -- really terrible animation copypasta, sorry guys
    local toFlash = {}
    -- ugly code
    for questId, framelist in pairs(QuestieMap.questIdFrames) do
        if questId ~= Quest.Id then
            for index, frameName in ipairs(framelist) do
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
            for index, frameName in ipairs(framelist) do
                local icon = _G[frameName];
                if not icon.miniMapIcon then
                    icon._size = icon:GetWidth()
                    table.insert(toFlash, icon)
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
                            for questId, framelist in pairs(QuestieMap.questIdFrames) do
                                for index, frameName in ipairs(framelist) do
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

function QuestieTrackerUtils:IsBindTrue(bind, button)
    return bind and button and bindTruthTable[bind] and bindTruthTable[bind](button)
end
