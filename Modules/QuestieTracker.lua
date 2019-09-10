QuestieTracker = {}
local _QuestieTracker = {}
_QuestieTracker.LineFrames = {}

local HBD = LibStub("HereBeDragonsQuestie-2.0")

-- these should be configurable maybe
local trackerLineCount = 64 -- shouldnt need more than this
local trackerBackgroundPadding = 4

-- used for fading the background of the trakcer
_QuestieTracker.FadeTickerValue = 0
_QuestieTracker.FadeTickerDirection = false -- true to fade in
_QuestieTracker.IsFirstRun = true -- bad code

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
    if QuestieQuest:IsComplete(Quest) then
        local NPC = nil
        if Quest.Finisher ~= nil then
            if Quest.Finisher.Type == "monster" then
                NPC = QuestieDB:GetNPC(Quest.Finisher.Id)
            elseif Quest.Finisher.Type == "object" then
                NPC = QuestieDB:GetObject(Quest.Finisher.Id)
            end
        end
        if NPC and NPC.Spawns then -- redundant code
            local bestDistance = 999999999
            local playerX, playerY, playerI = HBD:GetPlayerWorldPosition()
            local bestSpawn, bestSpawnZone, bestSpawnId, bestSpawnType, bestSpawnName
            for zone, spawns in pairs(NPC.Spawns) do
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
                            bestSpawnType = Quest.Finisher.Type
                            bestSpawnName = NPC.LocalizedName or NPC.Name
                        end
                    end
                end
            end
            return bestSpawn, bestSpawnZone, bestSpawnName, bestSpawnId, bestSpawnType, bestDistance
        end
        return nil
    end
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

local function _UnFocus() -- reset HideIcons to match savedvariable state 
    if not Questie.db.char.TrackerFocus then return; end
    for quest in pairs (qCurrentQuestlog) do
        local Quest = QuestieDB:GetQuest(quest)
        if Quest.Objectives then
            if Questie.db.char.TrackerHiddenQuests[Quest.Id] then
                Quest.HideIcons = true
            else
                Quest.HideIcons = nil
            end
            for _,Objective in pairs(Quest.Objectives) do
                if Questie.db.char.TrackerHiddenObjectives[tostring(quest) .. " " .. tostring(Objective.Index)] then
                    Objective.HideIcons = true
                else
                    Objective.HideIcons = nil
                end
            end
        end
    end
    Questie.db.char.TrackerFocus = nil
end

local function _FocusObjective(TargetQuest, TargetObjective)
    if Questie.db.char.TrackerFocus and type(Questie.db.char.TrackerFocus) == "string" and Questie.db.char.TrackerFocus ~= tostring(TargetQuest.Id) .. " " .. tostring(TargetObjective.Index) then
        _UnFocus()
    end
    Questie.db.char.TrackerFocus = tostring(TargetQuest.Id) .. " " .. tostring(TargetObjective.Index)
    for quest in pairs (qCurrentQuestlog) do
        local Quest = QuestieDB:GetQuest(quest)
        if Quest.Objectives then
            if quest == TargetQuest.Id then
                Quest.HideIcons = nil
            else
                Quest.HideIcons = true
            end
            for _,Objective in pairs(Quest.Objectives) do
                if Objective.Index == TargetObjective.Index then
                    Objective.HideIcons = nil
                else
                    Objective.HideIcons = true
                end
            end
        end
    end
end

local function _FocusQuest(TargetQuest)
    if Questie.db.char.TrackerFocus and type(Questie.db.char.TrackerFocus) == "number" and Questie.db.char.TrackerFocus ~= TargetQuest.Id then
        _UnFocus()
    end
    Questie.db.char.TrackerFocus = TargetQuest.Id
    for quest in pairs (qCurrentQuestlog) do
        local Quest = QuestieDB:GetQuest(quest)
        if quest == TargetQuest.Id then
            Quest.HideIcons = nil
        else
            Quest.HideIcons = true
        end
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
    --print("Found best spawn: " .. name .. " in zone " .. tostring(zone) .. " at " .. tostring(spawn[1]) .. " " .. tostring(spawn[2]))
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
        --_UnFocus()
        if Questie.db.char.TrackerFocus and type(Questie.db.char.TrackerFocus) == "string" and Questie.db.char.TrackerFocus == tostring(Quest.Id) .. " " .. tostring(Objective.Index) then
            table.insert(objectiveMenu, {text = QuestieLocale:GetUIString('TRACKER_UNFOCUS'), func = function() LQuestie_CloseDropDownMenus(); _UnFocus(); QuestieQuest:UpdateHiddenNotes() end})
        else
            table.insert(objectiveMenu, {text = QuestieLocale:GetUIString('TRACKER_FOCUS_OBJECTIVE'), func = function() LQuestie_CloseDropDownMenus(); _FocusObjective(Quest, Objective); QuestieQuest:UpdateHiddenNotes() end})
        end
        table.insert(objectiveMenu, {text = QuestieLocale:GetUIString('TRACKER_SET_TOMTOM'), func = function() 
            LQuestie_CloseDropDownMenus()
            spawn, zone, name = _GetNearestSpawn(Objective)
            if spawn then
                _SetTomTomTarget(name, zone, spawn[1], spawn[2])
            end
        end})
        if Objective.HideIcons then
            table.insert(objectiveMenu, {text = QuestieLocale:GetUIString('TRACKER_SHOW_ICONS'), func = function() 
                LQuestie_CloseDropDownMenus()
                Objective.HideIcons = nil;
                QuestieQuest:UpdateHiddenNotes()
                Questie.db.char.TrackerHiddenObjectives[tostring(Quest.Id) .. " " .. tostring(Objective.Index)] = nil
            end})
        else
            table.insert(objectiveMenu, {text = QuestieLocale:GetUIString('TRACKER_HIDE_ICONS'), func = function()
                LQuestie_CloseDropDownMenus()
                Objective.HideIcons = true;
                QuestieQuest:UpdateHiddenNotes()
                Questie.db.char.TrackerHiddenObjectives[tostring(Quest.Id) .. " " .. tostring(Objective.Index)] = true
            end})
        end
        
        table.insert(objectiveMenu, {text = QuestieLocale:GetUIString('TRACKER_SHOW_ON_MAP'), func = function()
            LQuestie_CloseDropDownMenus()
            local needHiddenUpdate
            if (Questie.db.char.TrackerFocus and type(Questie.db.char.TrackerFocus) == "string" and Questie.db.char.TrackerFocus ~= tostring(Quest.Id) .. " " .. tostring(Objective.Index))
            or (Questie.db.char.TrackerFocus and type(Questie.db.char.TrackerFocus) == "number" and Questie.db.char.TrackerFocus ~= Quest.Id) then
                _UnFocus()
                needHiddenUpdate = true
            end
            if Objective.HideIcons then
                Objective.HideIcons = nil
                needHiddenUpdate = true
            end
            if Quest.HideIcons then
                Quest.HideIcons = nil
                needHiddenUpdate = true
            end
            if needHiddenUpdate then QuestieQuest:UpdateHiddenNotes(); end
            _ShowObjectiveOnMap(Objective)
        end})
        
        table.insert(subMenu, {text = Objective.Description, hasArrow = true, menuList = objectiveMenu})
    end
    
    
    table.insert(menu, {text=Quest:GetColoredQuestName(), isTitle = true})
    if not QuestieQuest:IsComplete(Quest) then
        table.insert(menu, {text=QuestieLocale:GetUIString('TRACKER_OBJECTIVES'), hasArrow = true, menuList = subMenu})
    end
    if Quest.HideIcons then
        table.insert(menu, {text=QuestieLocale:GetUIString('TRACKER_SHOW_ICONS'), func = function() 
            Quest.HideIcons = nil
            QuestieQuest:UpdateHiddenNotes() 
            Questie.db.char.TrackerHiddenQuests[Quest.Id] = nil
        end})
    else
        table.insert(menu, {text=QuestieLocale:GetUIString('TRACKER_HIDE_ICONS'), func = function() 
            Quest.HideIcons = true
            QuestieQuest:UpdateHiddenNotes() 
            Questie.db.char.TrackerHiddenQuests[Quest.Id] = true
        end})
    end
    table.insert(menu, {text=QuestieLocale:GetUIString('TRACKER_SET_TOMTOM'), func = function() 
        LQuestie_CloseDropDownMenus()
        spawn, zone, name = _GetNearestQuestSpawn(Quest)
        if spawn then
            _SetTomTomTarget(name, zone, spawn[1], spawn[2])
        end
    end})
    table.insert(menu, {text=QuestieLocale:GetUIString('TRACKER_SHOW_QUESTLOG'), func = function() 
        LQuestie_CloseDropDownMenus() 
        QuestLogFrame:Show() 
        SelectQuestLogEntry(GetQuestLogIndexByID(Quest.Id)) 
        QuestLog_UpdateQuestDetails() 
        QuestLog_Update() 
    end})
    if GetCVar("autoQuestWatch") == "0" then
        table.insert(menu, {text=QuestieLocale:GetUIString('TRACKER_UNTRACK'), func = function()
            LQuestie_CloseDropDownMenus();
            Questie.db.char.TrackedQuests[Quest.Id] = nil
            QuestieTracker:Update()
        end})
    end
    if Questie.db.char.TrackerFocus and type(Questie.db.char.TrackerFocus) == "number" and Questie.db.char.TrackerFocus == Quest.Id then
        table.insert(menu, {text=QuestieLocale:GetUIString('TRACKER_UNFOCUS'), func = function() LQuestie_CloseDropDownMenus(); _UnFocus(); QuestieQuest:UpdateHiddenNotes() end})
    else
        table.insert(menu, {text=QuestieLocale:GetUIString('TRACKER_FOCUS_QUEST'), func = function() LQuestie_CloseDropDownMenus(); _FocusQuest(Quest); QuestieQuest:UpdateHiddenNotes()  end})
    end
    table.insert(menu, {text=QuestieLocale:GetUIString('TRACKER_CANCEL'), func = function() end})
    LQuestie_EasyMenu(menu, _QuestieTracker.menuFrame, "cursor", 0 , 0, "MENU")
end

local function _OnClick(self, button)
    if button == "RightButton" then
        _BuildMenu(self.Quest)
    elseif button == "LeftButton" and IsShiftKeyDown() then
        spawn, zone, name = _GetNearestQuestSpawn(self.Quest)
        if spawn then
            _SetTomTomTarget(name, zone, spawn[1], spawn[2])
        end
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

function QuestieTracker:_ResetLinesForFontChange()
    for i=1,trackerLineCount do
        _QuestieTracker.LineFrames[i].mode = nil
    end
end

function QuestieTracker:Initialize()
    if QuestieTracker.started or (not Questie.db.global.trackerEnabled) then return; end
    if not Questie.db.char.TrackerHiddenQuests then
        Questie.db.char.TrackerHiddenQuests = {}
    end
    if not Questie.db.char.TrackerHiddenObjectives then
        Questie.db.char.TrackerHiddenObjectives = {}
    end
    if not Questie.db.char.TrackedQuests then
        Questie.db.char.TrackedQuests = {}
    end
    _QuestieTracker.baseFrame = QuestieTracker:CreateBaseFrame()
    _QuestieTracker.menuFrame = LQuestie_Create_UIDropDownMenu("QuestieTrackerMenuFrame", UIParent)

    if Questie.db.global.hookTracking then
        QuestieTracker:HookBaseTracker()
    end
    
    -- this number is static, I doubt it will ever need more
    local lastFrame = nil
    for i=1,trackerLineCount do
        local frm = CreateFrame("Button", nil, _QuestieTracker.baseFrame)
        frm.label = frm:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        function frm:SetMode(mode)
            if mode ~= self.mode then
                self.mode = mode
                if mode == "header" then
                    self.label:SetFont(self.label:GetFont(), Questie.db.global.trackerFontSizeHeader)
                    self:SetHeight(Questie.db.global.trackerFontSizeHeader)
                else
                    self.label:SetFont(self.label:GetFont(), Questie.db.global.trackerFontSizeLine)
                    self:SetHeight(Questie.db.global.trackerFontSizeLine)
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
                self:SetHeight(Questie.db.global.trackerFontSizeHeader + amount)
            else
                self:SetHeight(Questie.db.global.trackerFontSizeLine + amount)
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

_QuestieTracker.HexTableHack = {
    '00','11','22','33','44','55','66','77','88','99','AA','BB','CC','DD','EE','FF'
}
function _QuestieTracker:PrintProgressColor(percent, text)
    local hexGreen, hexRed, hexBlue = 
    _QuestieTracker.HexTableHack[5 + math.floor(percent * 10)], _QuestieTracker.HexTableHack[8 + math.floor((1-percent) * 6)], _QuestieTracker.HexTableHack[4 + math.floor(percent * 6)]
    return "|cFF"..hexRed..hexGreen..hexBlue..text.."|r"
end

-- 1.12 color logic
local function RGBToHex(r, g, b)
    if r > 255 then r = 255; end
    if g > 255 then g = 255; end
    if b > 255 then b = 255; end
    return string.format("|cFF%02x%02x%02x", r, g, b);
end
local function fRGBToHex(r, g, b)
    return RGBToHex(r*254, g*254, b*254);
end
function _QuestieTracker:getRGBForObjective(Objective)
    if not Objective.Collected or type(Objective.Collected) ~= "number" then return 0.8,0.8,0.8; end
    local float = Objective.Collected / Objective.Needed
    
    if Questie.db.global.trackerColorObjectives == "whiteToGreen" then
        return fRGBToHex(0.8-float/2, 0.8+float/3, 0.8-float/2);
    else
        if float < .49 then return fRGBToHex(1, 0+float/.5, 0); end
        if float == .50 then return fRGBToHex(1, 1, 0); end
        if float > .50 then return fRGBToHex(1-float/2, 1, 0); end
    end
    --return fRGBToHex(0.8-float/2, 0.8+float/3, 0.8-float/2);
    
    --[[if QuestieConfig.boldColors == false then
        if not (type(objective) == "function") then
            local lastIndex = findLast(objective, ":");
            if not (lastIndex == nil) then
                local progress = string.sub(objective, lastIndex+2);
                local slash = findLast(progress, "/");
                local have = tonumber(string.sub(progress, 0, slash-1));
                local need = tonumber(string.sub(progress, slash+1));
                if not have or not need then return 0.8, 0.8, 0.8; end
                local float = have / need;
                return 0.8-float/2, 0.8+float/3, 0.8-float/2;
            end
        end
        return 0.3, 1, 0.3;
    else
        if not (type(objective) == "function") then
            local lastIndex = findLast(objective, ":");
            if not (lastIndex == nil) then
                local progress = string.sub(objective, lastIndex+2);
                local slash = findLast(progress, "/");
                local have = tonumber(string.sub(progress, 0, slash-1));
                local need = tonumber(string.sub(progress, slash+1));
                if not have or not need then return 1, 0, 0; end
                local float = have / need;
                if float < .49 then return 1, 0+float/.5, 0; end
                if float == .50 then return 1, 1, 0; end
                if float > .50 then return 1-float/2, 1, 0; end
            end
        end
        return 0, 1, 0;
    end]]--
end


function QuestieTracker:Update()
    if (not QuestieTracker.started) or (not Questie.db.global.trackerEnabled) then return; end
    index = 0 -- zero because it simplifies GetNextLine()
    -- populate tracker
    local trackerWidth = 0
    local line = nil
    
    local order = {}
    local questCompletePercent = {}
    for quest in pairs (qCurrentQuestlog) do
        local Quest = QuestieDB:GetQuest(quest)
        if QuestieQuest:IsComplete(Quest) or not Quest.Objectives then
            questCompletePercent[Quest.Id] = 1
        else
            local percent = 0
            local count = 0;
            for _,Objective in pairs(Quest.Objectives) do
                percent = percent + (Objective.Collected / Objective.Needed)
                count = count + 1
            end
            percent = percent / count
            questCompletePercent[Quest.Id] = percent
        end
        table.insert(order, quest)
    end
    if Questie.db.global.trackerSortObjectives == "byComplete" then
        table.sort(order, function(a, b) 
            local vA, vB = questCompletePercent[a], questCompletePercent[b]
            if vA == vB then
                return QuestieDB:GetQuest(a).Level < QuestieDB:GetQuest(b).Level
            end
            return vB < vA
        end)
    elseif Questie.db.global.trackerSortObjectives == "byLevel" then
        table.sort(order, function(a, b) 
            return QuestieDB:GetQuest(a).Level < QuestieDB:GetQuest(b).Level
        end)
    elseif Questie.db.global.trackerSortObjectives == "byLevelReversed" then
        table.sort(order, function(a, b) 
            return QuestieDB:GetQuest(a).Level > QuestieDB:GetQuest(b).Level
        end)
    end
    
    for _,quest in pairs (order) do
        -- if quest.userData.tracked 
        local Quest = QuestieDB:GetQuest(quest)
        local complete = QuestieQuest:IsComplete(Quest)
        if ((not complete) or Questie.db.global.trackerShowCompleteQuests) and ((GetCVar("autoQuestWatch") == "1") or Questie.db.char.TrackedQuests[quest])  then -- maybe have an option to display quests in the list with (Complete!) in the title
            line = _QuestieTracker:GetNextLine()
            line:SetMode("header")
            line:SetQuest(Quest)
            line:SetObjective(nil)
            if complete then
                line.label:SetText(QuestieTooltips:PrintDifficultyColor(Quest.Level, "[" .. Quest.Level .. "] " .. (Quest.LocalizedName or Quest.Name) .. " " .. QuestieLocale:GetUIString('TOOLTIP_QUEST_COMPLETE')))
            else
                line.label:SetText(Quest:GetColoredQuestName())
            end
            line.label:Show()
            trackerWidth = math.max(trackerWidth, line.label:GetWidth())
            --
            if _QuestieTracker.IsFirstRun then
                if Questie.db.char.TrackerHiddenQuests[quest] then
                    Quest.HideIcons = true
                end
                if Questie.db.char.TrackerFocus then
                    if Questie.db.char.TrackerFocus and type(Questie.db.char.TrackerFocus) == "number" and Questie.db.char.TrackerFocus == Quest.Id then -- quest focus
                        _FocusQuest(Quest)
                    end
                end
            end
            
            
            
            for _,Objective in pairs(Quest.Objectives) do
                line = _QuestieTracker:GetNextLine()
                line:SetMode("line")
                line:SetQuest(Quest)
                line:SetObjective(Objective)
                if (Questie.db.global.trackerColorObjectives and Questie.db.global.trackerColorObjectives ~= "white") and Objective.Collected and type(Objective.Collected) == "number" then
                    line.label:SetText("    " .. _QuestieTracker:getRGBForObjective(Objective) .. Objective.Description .. ": " .. tostring(Objective.Collected) .. "/" .. tostring(Objective.Needed))
                else
                    line.label:SetText("    |cFFEEEEEE" .. Objective.Description .. ": " .. tostring(Objective.Collected) .. "/" .. tostring(Objective.Needed))
                end
                line.label:Show()
                trackerWidth = math.max(trackerWidth, line.label:GetWidth())
                
                if _QuestieTracker.IsFirstRun then
                    if Questie.db.char.TrackerHiddenObjectives[tostring(quest) .. " " .. tostring(Objective.Index)] then
                        Objective.HideIcons = true
                    end
                    if  Questie.db.char.TrackerFocus and type(Questie.db.char.TrackerFocus) == "string" and Questie.db.char.TrackerFocus == tostring(Quest.Id) .. " " .. tostring(Objective.Index) then
                        _FocusObjective(Quest, Objective)
                    end
                end
            end
            line:SetVerticalPadding(Questie.db.global.trackerQuestPadding)
        end
    end
    
    -- hide remaining lines
    for i=index+1,trackerLineCount do
        _QuestieTracker.LineFrames[i].label:Hide()
    end
    
    -- adjust base frame size for dragging
    if line then
        _QuestieTracker.baseFrame:SetWidth(trackerWidth + trackerBackgroundPadding*2)
        _QuestieTracker.baseFrame:SetHeight((_QuestieTracker.baseFrame:GetTop() - line:GetBottom()) + trackerBackgroundPadding*2 - Questie.db.global.trackerQuestPadding*2)
    end
    -- make sure tracker is inside the screen
    
    if _QuestieTracker.IsFirstRun then
        _QuestieTracker.IsFirstRun = nil
        -- bad code 
        QuestieQuest:UpdateHiddenNotes()
    end
end

local function _RemoveQuestWatch(index, isQuestie)
    if not isQuestie then
        Questie.db.char.TrackedQuests[select(8,GetQuestLogTitle(index)) or -1] = nil
        C_Timer.After(0.1, function() 
            QuestieTracker:Update()
        end)
    end
end

local function _AQW_Insert(index, expire)
    RemoveQuestWatch(index, true)
    local qid = select(8,GetQuestLogTitle(index))
    if Questie.db.char.TrackedQuests[qid] then
        Questie.db.char.TrackedQuests[qid] = nil
    else
        Questie.db.char.TrackedQuests[qid] = true
    end
    C_Timer.After(0.1, function() 
        QuestieTracker:Update()
    end)
end

function QuestieTracker:HookBaseTracker()
    if _QuestieTracker._alreadyHooked then return; end
    hooksecurefunc("AutoQuestWatch_Insert", _AQW_Insert)
    hooksecurefunc("RemoveQuestWatch", _RemoveQuestWatch)
    
    -- this is probably bad
    IsQuestWatched = function(index)
        return Questie.db.char.TrackedQuests[select(8,GetQuestLogTitle(index)) or -1]
    end
    QuestieTracker._alreadyHooked = true
end

function QuestieTracker:ResetLocation()
    Questie.db.char.TrackerLocation = nil
    if _QuestieTracker.baseFrame then
        _QuestieTracker.baseFrame:SetPoint("CENTER",0,0)
        _QuestieTracker.baseFrame:Show()
    end
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
        -- we need to pcall this because it can error if something like MoveAnything is used to move the tracker
        result, error = pcall(frm.SetPoint, frm, unpack(Questie.db.char.TrackerLocation))
        if not result then
            Questie.db.char.TrackerLocation = nil
            print(QuestieLocale:GetUIString('TRACKER_INVALID_LOCATION'))
            frm:SetPoint("CENTER",0,0)
        end
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