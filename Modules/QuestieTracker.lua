QuestieTracker = {}
local _QuestieTracker = {}
_QuestieTracker.LineFrames = {}

local HBD = LibStub("HereBeDragonsQuestie-2.0")

-- these should be configurable maybe
local fontSizeHeader = 13
local fontSizeLine = 11
local trackerLineCount = 64 -- shouldnt need more than this
local trackerBackgroundPadding = 4
local trackerQuestPadding = 2 -- padding between quests in the tracker

-- used for fading the background of the trakcer
_QuestieTracker.FadeTickerValue = 0
_QuestieTracker.FadeTickerDirection = false -- true to fade in

function _QuestieTracker:StartFadeTicker()
    if not _QuestieTracker.FadeTicker then
        _QuestieTracker.FadeTicker = C_Timer.NewTicker(0.02, function()
            if _QuestieTracker.FadeTickerDirection then
                if _QuestieTracker.FadeTickerValue < 0.3 then
                    _QuestieTracker.FadeTickerValue = _QuestieTracker.FadeTickerValue + 0.06
                    _QuestieTracker.baseFrame.texture:SetVertexColor(1,1,1,_QuestieTracker.FadeTickerValue)
                else
                    _QuestieTracker.FadeTicker:Cancel()
                    _QuestieTracker.FadeTicker = nil
                end
            else
                if _QuestieTracker.FadeTickerValue > 0 then
                    _QuestieTracker.FadeTickerValue = _QuestieTracker.FadeTickerValue - 0.06
                    _QuestieTracker.baseFrame.texture:SetVertexColor(1,1,1,math.max(0,_QuestieTracker.FadeTickerValue))
                else
                    _QuestieTracker.FadeTicker:Cancel()
                    _QuestieTracker.FadeTicker = nil
                end
            end
        end)
    end
end

local function _OnDragStart(self, button)
    if IsControlKeyDown() then
        _QuestieTracker.baseFrame:StartMoving()
    else
        if not IsMouselooking() then-- this is a HORRIBLE solution, why does MouselookStart have to break OnMouseUp (is there a MOUSE_RELEASED event that always fires?)
            MouselookStart() -- unfortunately, even though we only want to catch right click for a context menu
            -- the only api function we can use is MouselookStart/MouselookStop which replicates the default 
            -- right click-drag behavior of also making your player turn :(
            _QuestieTracker._mouselook_ticker = C_Timer.NewTicker(0.1, function()
                if not IsMouseButtonDown(button) then
                    MouselookStop()
                    _QuestieTracker._mouselook_ticker:Cancel()
                end
            end)
        end
    end
end

local function _GetNearestSpawn(Objective) 
    print("GetNearest...")
    local playerX, playerY, playerI = HBD:GetPlayerWorldPosition()
    local bestDistance = 999999999
    local bestSpawn, bestSpawnZone, bestSpawnId, bestSpawnType, bestSpawnName
    if Objective.spawnList then
        for id, spawnData in pairs(Objective.spawnList) do
            for zone, spawns in pairs(spawnData.Spawns) do
                for _,spawn in pairs(spawns) do
                    local dX, dY, dInstance = HBD:GetWorldCoordinatesFromZone(spawn[1]/100.0, spawn[2]/100.0, zoneDataAreaIDToUiMapID[zone])
                    --print (" " .. tostring(dX) .. " " .. tostring(dY) .. " " .. zoneDataAreaIDToUiMapID[zone])
                    if dInstance == playerI then
                        local dist = HBD:GetWorldDistance(dInstance, playerX, playerY, dX, dY)
                        if dist < bestDistance then
                            bestDistance = dist
                            bestSpawn = spawn
                            bestSpawnZone = zone
                            bestSpawnId = id
                            bestSpawnType = spawnData.Type
                            bestSpawnName = spawnData.Name
                        end
                    end
                end
            end
        end
    end
    return bestSpawn, bestSpawnZone, bestSpawnName, bestSpawnId, bestSpawnType, bestDistance
end

local function _GetNearestQuestSpawn(Quest)
    local bestDistance = 999999999
    local bestSpawn, bestSpawnZone, bestSpawnId, bestSpawnType, bestSpawnName
    for _,Objective in pairs(Quest.Objectives) do
        local spawn, zone, Name, id, Type, dist = _GetNearestSpawn(Objective)
        if spawn and dist < bestDistance then
            bestDistance = dist
            bestSpawn = spawn
            bestSpawnZone = zone
            bestSpawnId = id
            bestSpawnType = Type
            bestSpawnName = Name
        end
    end
    return bestSpawn, bestSpawnZone, bestSpawnName, bestSpawnId, bestSpawnType, bestDistance
end

local function _SetTomTomTarget(title, zone, x, y)
    if TomTom and TomTom.AddWaypoint then
        if Questie.db.char._tom_waypoint and TomTom.RemoveWaypoint then -- remove old waypoint
            TomTom:RemoveWaypoint(Questie.db.char._tom_waypoint)
        end
        Questie.db.char._tom_waypoint = TomTom:AddWaypoint(zoneDataAreaIDToUiMapID[zone], x/100, y/100,  {title = title, crazy = true})
    end
end

local function _FlashObjectiveByTexture(Objective) -- really terrible animation code, sorry guys
    if Objective.AlreadySpawned then
        local toFlash = {}
        -- ugly code
        for questId, framelist in pairs(qQuestIdFrames) do
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
                    if frame.data.ObjectiveData then
                        table.insert(toFlash, frame)
                        if frame._hidden_by_flash then
                            frame:Show()
                        end
                        
                        -- todo: move into frame.session
                        frame._hidden_by_flash = nil
                        frame._size = frame:GetWidth()
                        frame._sizemul = 2
                        frame:SetWidth(frame._size * 2)
                        frame:SetHeight(frame._size * 2)
                    end
                end
            end
        end
        local flashB = true
        _QuestieTracker._ObjectiveFlashTicker = C_Timer.NewTicker(0.28, function() 
            if flashB then
                flashB = false
                for _, frame in pairs(toFlash) do
                    frame.texture:SetVertexColor(0.3,0.3,0.3,1)
                    frame.glowTexture:SetVertexColor(frame.data.ObjectiveData.Color[1]/3,frame.data.ObjectiveData.Color[2]/3,frame.data.ObjectiveData.Color[3]/3,1)
                end
            else
                flashB = true
                for _, frame in pairs(toFlash) do
                    frame.texture:SetVertexColor(1,1,1,1)
                    frame.glowTexture:SetVertexColor(frame.data.ObjectiveData.Color[1],frame.data.ObjectiveData.Color[2],frame.data.ObjectiveData.Color[3],1)
                end
            end
        end, 6)
        C_Timer.After(5*0.28, function() 
            C_Timer.NewTicker(0.1, function() 
                for _, frame in pairs(toFlash) do
                    frame._sizemul = frame._sizemul - 0.2
                    frame:SetWidth(frame._size * frame._sizemul)
                    frame:SetHeight(frame._size  * frame._sizemul)
                end
            end, 5)
        end)
        --C_Timer.After(6*0.3+0.1, function() 
        --    for _, frame in pairs(toFlash) do
        --        frame:SetWidth(frame._size)
        --        frame:SetHeight(frame._size)
        --      frame._size = nil; frame._sizemul = nil
        --    end
        --end)
        C_Timer.After(6*0.28+0.7, function() 
            for questId, framelist in pairs(qQuestIdFrames) do
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
end

local function _FlashObjective(Objective) -- really terrible animation code, sorry guys
    if Objective.AlreadySpawned then
        local toFlash = {}
        -- ugly code
        for questId, framelist in pairs(qQuestIdFrames) do
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
        _QuestieTracker._ObjectiveFlashTicker = C_Timer.NewTicker(0.1, function() 
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
                                _QuestieTracker._ObjectiveFlashTicker:Cancel()
                                for _, frame in pairs(toFlash) do
                                    frame:SetWidth(frame._size)
                                    frame:SetHeight(frame._size)
                                    frame._size = nil
                                end
                            end)
                            C_Timer.After(0.5, function()
                                for questId, framelist in pairs(qQuestIdFrames) do
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

local function _ShowObjectiveOnMap(Objective)
    -- calculate nearest spawn
    spawn, zone, name = _GetNearestSpawn(Objective) 
    print("Found best spawn: " .. name .. " in zone " .. tostring(zone) .. " at " .. tostring(spawn[1]) .. " " .. tostring(spawn[2]))
    WorldMapFrame:Show()
    WorldMapFrame:SetMapID(zoneDataAreaIDToUiMapID[zone])
    _FlashObjective(Objective)
end

local function _BuildMenu(Quest) 
    local menu = {}
    
    --[[table.insert(menu, {text=Quest:GetColoredQuestName(), isTitle = true})
    if Objective then
        table.insert(menu, {text="Focus Objective", func = function() end})
    else
        table.insert(menu, {text="Focus Quest", func = function() end})
    end
    table.insert(menu, {text="Show on Map", func = function() end})
    table.insert(menu, {text="Set TomTom Target", func = function() end})
    table.insert(menu, {text="Hide Icons", func = function() end})
    table.insert(menu, {text="Un-track Quest", func = function() end})
    table.insert(menu, {text="Show in Quest Log", func = function() end})
    table.insert(menu, {text="Cancel", func = function() end})]]--
    
    --[[[if Objective then
        local subMenu = {}
        
        table.insert(menu, {"Objective Options", hasArrow = true, menuList = subMenu})
    end]]--
    
    local subMenu = {}
    for _, Objective in pairs(Quest.Objectives) do
        local objectiveMenu = {}
        
        table.insert(objectiveMenu, {text = "Focus Objective", func = function() LQuestie_CloseDropDownMenus()end})
        table.insert(objectiveMenu, {text = "Set TomTom Target", func = function() 
            LQuestie_CloseDropDownMenus()
            spawn, zone, name = _GetNearestSpawn(Objective)
            _SetTomTomTarget(name, zone, spawn[1], spawn[2])
        end})
        if Objective.HideIcons then
            table.insert(objectiveMenu, {text = "Show Icons", func = function() LQuestie_CloseDropDownMenus() Objective.HideIcons = false; QuestieQuest:UpdateHiddenNotes() end})
        else
            table.insert(objectiveMenu, {text = "Hide Icons", func = function() LQuestie_CloseDropDownMenus() Objective.HideIcons = true; QuestieQuest:UpdateHiddenNotes() end})
        end
        
        table.insert(objectiveMenu, {text = "Show on Map", func = function() LQuestie_CloseDropDownMenus() _ShowObjectiveOnMap(Objective) end})
        
        table.insert(subMenu, {text = Objective.Description, hasArrow = true, menuList = objectiveMenu})
    end
    
    
    table.insert(menu, {text=Quest:GetColoredQuestName(), isTitle = true})
    table.insert(menu, {text="Objectives", hasArrow = true, menuList = subMenu})
    if Quest.HideIcons then
        table.insert(menu, {text="Show Icons", func = function() Quest.HideIcons = false; QuestieQuest:UpdateHiddenNotes() end})
    else
        table.insert(menu, {text="Hide Icons", func = function() Quest.HideIcons = true; QuestieQuest:UpdateHiddenNotes() end})
    end
    table.insert(menu, {text="Set TomTom Target", func = function() 
        LQuestie_CloseDropDownMenus()
        spawn, zone, name = _GetNearestQuestSpawn(Quest)
        _SetTomTomTarget(name, zone, spawn[1], spawn[2])
    end})
    table.insert(menu, {text="Show in Quest Log", func = function() 
        LQuestie_CloseDropDownMenus() 
        QuestLogFrame:Show() 
        SelectQuestLogEntry(GetQuestLogIndexByID(Quest.Id)) 
        QuestLog_UpdateQuestDetails() 
        QuestLog_Update() 
    end})
    table.insert(menu, {text="Un-track Quest", func = function() end})
    table.insert(menu, {text="Focus Quest", func = function() end})
    table.insert(menu, {text="Cancel", func = function() end})
    LQuestie_EasyMenu(menu, _QuestieTracker.menuFrame, "cursor", 0 , 0, "MENU")
end

local function _OnClick(self, button)
    print("Click " .. button)
    if button == "RightButton" then
        _BuildMenu(self.Quest)
    end
end

local function _OnDragStop()
    _QuestieTracker.baseFrame:StopMovingOrSizing()
    Questie.db.char.TrackerLocation = {_QuestieTracker.baseFrame:GetPoint()}
end

local function _OnEnter()
    _QuestieTracker.FadeTickerDirection = true
    _QuestieTracker:StartFadeTicker()
end

local function _OnLeave()
    _QuestieTracker.FadeTickerDirection = false
    _QuestieTracker:StartFadeTicker()
end

function QuestieTracker:Initialize()
    if QuestieTracker.started or (not Questie.db.char.trackerEnabled) then return; end
    _QuestieTracker.baseFrame = QuestieTracker:CreateBaseFrame()
    _QuestieTracker.menuFrame = LQuestie_Create_UIDropDownMenu("QuestieTrackerMenuFrame", UIParent)

    
    -- this number is static, I doubt it will ever need more
    local lastFrame = nil
    for i=1,trackerLineCount do
        local frm = CreateFrame("Button", nil, _QuestieTracker.baseFrame)
        frm.label = frm:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        function frm:SetMode(mode)
            if mode ~= self.mode then
                self.mode = mode
                if mode == "header" then
                    self.label:SetFont(self.label:GetFont(), fontSizeHeader)
                    self:SetHeight(fontSizeHeader)
                else
                    self.label:SetFont(self.label:GetFont(), fontSizeLine)
                    self:SetHeight(fontSizeLine)
                end
            end
        end
        
        function frm:SetQuest(Quest)
            self.Quest = Quest
        end
        
        function frm:SetObjective(Objective)
            self.Objective = Objective
        end
        
        function frm:SetVerticalPadding(amount)
            if self.mode == "header" then
                self:SetHeight(fontSizeHeader + amount)
            else
                self:SetHeight(fontSizeLine + amount)
            end
        end
        
        frm.label:SetJustifyH("LEFT")
        frm.label:SetPoint("TOPLEFT", frm)
        frm.label:Hide()
        
        -- autoadjust parent size for clicks
        frm.label._SetText = frm.label.SetText
        frm.label.frame = frm
        frm.label.SetText = function(self, text)
            self:_SetText(text)
            self.frame:SetWidth(self:GetWidth())
            self.frame:SetHeight(self:GetHeight())
        end
        
        frm:EnableMouse(true)
        frm:RegisterForDrag("LeftButton", "RightButton")
        frm:RegisterForClicks("RightButtonUp", "LeftButtonUp")
        
        -- hack for click-through
        frm:SetScript("OnDragStart", _OnDragStart)
        frm:SetScript("OnClick", _OnClick)
        frm:SetScript("OnDragStop", _OnDragStop)
        frm:SetScript("OnEnter", _OnEnter)
        frm:SetScript("OnLeave", _OnLeave)
        
        
        if lastFrame then
            frm:SetPoint("TOPLEFT", lastFrame, "BOTTOMLEFT", 0,0)
        else
            frm:SetPoint("TOPLEFT", _QuestieTracker.baseFrame, "TOPLEFT", trackerBackgroundPadding, -trackerBackgroundPadding)
        end
        frm:SetWidth(1)
        frm:SetMode("header")
        --frm:Show()
        _QuestieTracker.LineFrames[i] = frm
        lastFrame = frm
    end
    QuestieTracker.started = true
end

local index = 0
function _QuestieTracker:GetNextLine()
    index = index + 1
    return _QuestieTracker.LineFrames[index]
end

function QuestieTracker:Update()
    if (not QuestieTracker.started) or (not Questie.db.char.trackerEnabled) then return; end
    index = 0 -- zero because it simplifies GetNextLine()
    -- populate tracker
    local trackerWidth = 0
    local line = nil
    for quest in pairs (qCurrentQuestlog) do
        -- if quest.userData.tracked 
        local Quest = QuestieDB:GetQuest(quest)
        if not QuestieQuest:IsComplete(Quest) then -- maybe have an option to display quests in the list with (Complete!) in the title
            line = _QuestieTracker:GetNextLine()
            line:SetMode("header")
            line:SetQuest(Quest)
            line:SetObjective(nil)
            line.label:SetText(Quest:GetColoredQuestName())
            line.label:Show()
            trackerWidth = math.max(trackerWidth, line.label:GetWidth())
            for _,Objective in pairs(Quest.Objectives) do
                line = _QuestieTracker:GetNextLine()
                line:SetMode("line")
                line:SetQuest(Quest)
                line:SetObjective(Objective)
                line.label:SetText("    |cFFEEEEEE" .. Objective.Description .. ": " .. tostring(Objective.Collected) .. "/" .. tostring(Objective.Needed))
                line.label:Show()
                trackerWidth = math.max(trackerWidth, line.label:GetWidth())
            end
            line:SetVerticalPadding(trackerQuestPadding)
        end
    end
    
    -- hide remaining lines
    for i=index+1,trackerLineCount do
        _QuestieTracker.LineFrames[i].label:Hide()
    end
    
    -- adjust base frame size for dragging
    if line then
        _QuestieTracker.baseFrame:SetWidth(trackerWidth + trackerBackgroundPadding*2)
        _QuestieTracker.baseFrame:SetHeight((_QuestieTracker.baseFrame:GetTop() - line:GetBottom()) + trackerBackgroundPadding*2 - trackerQuestPadding*2)
    end
    -- make sure tracker is inside the screen
end

function QuestieTracker:CreateBaseFrame()
    local frm = CreateFrame("Frame", nil, UIParent)

    frm:SetWidth(100)
    frm:SetHeight(100)
    
    local t = frm:CreateTexture(nil,"BACKGROUND")
    t:SetTexture(ICON_TYPE_BLACK)
    t:SetVertexColor(1,1,1,0)
    t:SetAllPoints(frm)
    frm.texture = t
    
    if Questie.db.char.TrackerLocation then
        frm:SetPoint(unpack(Questie.db.char.TrackerLocation))
    else
        frm:SetPoint("CENTER",0,0)
    end
    
    frm:SetMovable(true)
    frm:EnableMouse(true)
    frm:RegisterForDrag("LeftButton", "RightButton")
    
    frm:SetScript("OnDragStart", _OnDragStart)
    frm:SetScript("OnDragStop", _OnDragStop)
    frm:SetScript("OnEnter", _OnEnter)
    frm:SetScript("OnLeave", _OnLeave)
    
    frm:Show()
    
    return frm
end