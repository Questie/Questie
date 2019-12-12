---@type QuestieTracker
local QuestieTracker = QuestieLoader:ImportModule("QuestieTracker")
QuestieTracker.utils = {}
---@type QuestieMap
local QuestieMap = QuestieLoader:ImportModule("QuestieMap")


local objectiveFlashTicker = {}
local tinsert = table.insert


function QuestieTracker.utils:ShowQuestLog(quest)
    -- Priority order first check if addon exist otherwise default to original
    local questFrame = QuestLogExFrame or ClassicQuestLog or QuestLogFrame;
    HideUIPanel(questFrame);
    local questLogIndex = GetQuestLogIndexByID(quest.Id);
    SelectQuestLogEntry(questLogIndex)

    -- Scroll to the quest in the quest log
    local scrollSteps = QuestLogListScrollFrame.ScrollBar:GetValueStep()
    QuestLogListScrollFrame.ScrollBar:SetValue(questLogIndex * scrollSteps - scrollSteps * 3);

    ShowUIPanel(questFrame);

    --Addon specific behaviors
    if(QuestLogEx) then
        QuestLogEx:Maximize();
    end

    QuestLog_UpdateQuestDetails()
    QuestLog_Update()
end

function QuestieTracker.utils:SetTomTomTarget(title, zone, x, y)
    if TomTom and TomTom.AddWaypoint then
        if Questie.db.char._tom_waypoint and TomTom.RemoveWaypoint then -- remove old waypoint
            TomTom:RemoveWaypoint(Questie.db.char._tom_waypoint)
        end
        Questie.db.char._tom_waypoint = TomTom:AddWaypoint(ZoneDataAreaIDToUiMapID[zone], x/100, y/100,  {title = title, crazy = true})
    end
end

function QuestieTracker.utils:ShowObjectiveOnMap(Objective)
    -- calculate nearest spawn
    local spawn, zone, name = QuestieMap:GetNearestSpawn(Objective)
    if spawn then
        --print("Found best spawn: " .. name .. " in zone " .. tostring(zone) .. " at " .. tostring(spawn[1]) .. " " .. tostring(spawn[2]))
        WorldMapFrame:Show()
        WorldMapFrame:SetMapID(ZoneDataAreaIDToUiMapID[zone])
        QuestieTracker.utils:FlashObjective(Objective)
    end
end

function QuestieTracker.utils:ShowFinisherOnMap(Quest)
    -- calculate nearest spawn
    local spawn, zone, name = QuestieMap:GetNearestQuestSpawn(Quest)
    if spawn then
        --print("Found best spawn: " .. name .. " in zone " .. tostring(zone) .. " at " .. tostring(spawn[1]) .. " " .. tostring(spawn[2]))
        WorldMapFrame:Show()
        WorldMapFrame:SetMapID(ZoneDataAreaIDToUiMapID[zone])
        QuestieTracker.utils:FlashFinisher(Quest)
    end
end

function QuestieTracker.utils:FlashObjective(Objective) -- really terrible animation code, sorry guys
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

function QuestieTracker.utils:FlashFinisher(Quest) -- really terrible animation copypasta, sorry guys
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

-- function QuestieTracker.utils:FlashObjectiveByTexture(Objective) -- really terrible animation code, sorry guys
--     if Objective.AlreadySpawned then
--         local toFlash = {}
--         -- ugly code
--         for questId, framelist in pairs(QuestieMap.questIdFrames) do
--             for index, frameName in ipairs(framelist) do
--                 local icon = _G[frameName];
--                 if not icon.miniMapIcon then

--                     -- todo: move into frame.session
--                     if icon:IsShown() then
--                         icon._hidden_by_flash = true
--                         icon:Hide()
--                     end
--                 end
--             end
--         end


--         for _, spawn in pairs(Objective.AlreadySpawned) do
--             if spawn.mapRefs then
--                 for _, frame in pairs(spawn.mapRefs) do
--                     if frame.data.ObjectiveData then
--                         tinsert(toFlash, frame)
--                         if frame._hidden_by_flash then
--                             frame:Show()
--                         end

--                         -- todo: move into frame.session
--                         frame._hidden_by_flash = nil
--                         frame._size = frame:GetWidth()
--                         frame._sizemul = 2
--                         frame:SetWidth(frame._size * 2)
--                         frame:SetHeight(frame._size * 2)
--                     end
--                 end
--             end
--         end
--         local flashB = true
--         _QuestieTracker._ObjectiveFlashTicker = C_Timer.NewTicker(0.28, function()
--             if flashB then
--                 flashB = false
--                 for _, frame in pairs(toFlash) do
--                     frame.texture:SetVertexColor(0.3,0.3,0.3,1)
--                     frame.glowTexture:SetVertexColor(frame.data.ObjectiveData.Color[1]/3,frame.data.ObjectiveData.Color[2]/3,frame.data.ObjectiveData.Color[3]/3,1)
--                 end
--             else
--                 flashB = true
--                 for _, frame in pairs(toFlash) do
--                     frame.texture:SetVertexColor(1,1,1,1)
--                     frame.glowTexture:SetVertexColor(frame.data.ObjectiveData.Color[1],frame.data.ObjectiveData.Color[2],frame.data.ObjectiveData.Color[3],1)
--                 end
--             end
--         end, 6)
--         C_Timer.After(5*0.28, function()
--             C_Timer.NewTicker(0.1, function()
--                 for _, frame in pairs(toFlash) do
--                     frame._sizemul = frame._sizemul - 0.2
--                     frame:SetWidth(frame._size * frame._sizemul)
--                     frame:SetHeight(frame._size  * frame._sizemul)
--                 end
--             end, 5)
--         end)
--         --C_Timer.After(6*0.3+0.1, function()
--         --    for _, frame in pairs(toFlash) do
--         --        frame:SetWidth(frame._size)
--         --        frame:SetHeight(frame._size)
--         --      frame._size = nil; frame._sizemul = nil
--         --    end
--         --end)
--         C_Timer.After(6*0.28+0.7, function()
--             for questId, framelist in pairs(QuestieMap.questIdFrames) do
--                 for index, frameName in ipairs(framelist) do
--                     local icon = _G[frameName];
--                     if icon._hidden_by_flash then
--                         icon._hidden_by_flash = nil
--                         icon:Show()
--                     end
--                 end
--             end
--         end)
--     end
-- end

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

function QuestieTracker.utils:IsBindTrue(bind, button)
    return bind and button and bindTruthTable[bind] and bindTruthTable[bind](button)
end
