QuestieTracker = {}
local _QuestieTracker = {}
_QuestieTracker.LineFrames = {}

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

function QuestieTracker:Initialize()
    if QuestieTracker.started or (not Questie.db.char.trackerEnabled) then return; end
    _QuestieTracker.baseFrame = QuestieTracker:CreateBaseFrame()
    
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
        frm:RegisterForDrag("LeftButton")
        --frm:RegisterForClicks("RightButtonUp")
        
        -- hack for click-through
        frm:SetScript("OnDragStart", function(self, button)
            if button == "RightButton" then

            elseif IsControlKeyDown() then
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
            
        end)
        
        -- MouselookStart() calls OnMouseUp immediately :(
        --frm:SetScript("OnMouseUp", function(self)
        --    print("OMU")
        --    if IsMouselooking() then MouselookStop() end
        --end)
        --frm:SetScript("OnClick", function(self)
        --    print("Clicka clacka")
        --end)
        
        frm:SetScript("OnDragStop", function() 
            _QuestieTracker.baseFrame:StopMovingOrSizing()
            Questie.db.char.TrackerLocation = {_QuestieTracker.baseFrame:GetPoint()}
        end)
        
        frm:SetScript("OnEnter", function(self)
            _QuestieTracker.FadeTickerDirection = true
            _QuestieTracker:StartFadeTicker()
        end)
        
        frm:SetScript("OnLeave", function(self)
            _QuestieTracker.FadeTickerDirection = false
            _QuestieTracker:StartFadeTicker()
        end)
        
        
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
            line.label:SetText(Quest:GetColoredQuestName())
            line.label:Show()
            trackerWidth = math.max(trackerWidth, line.label:GetWidth())
            for _,Objective in pairs(Quest.Objectives) do
                line = _QuestieTracker:GetNextLine()
                line:SetMode("line")
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
    frm:SetScript("OnEnter", function(self)
        _QuestieTracker.FadeTickerDirection = true
        _QuestieTracker:StartFadeTicker()
    end)
    
    frm:SetScript("OnLeave", function(self)
        _QuestieTracker.FadeTickerDirection = false
        _QuestieTracker:StartFadeTicker()
    end)
    
    frm:EnableMouse(true)
    frm:RegisterForDrag("LeftButton")
    
    frm:SetScript("OnDragStart", function(self, button)
        if IsControlKeyDown() then
            _QuestieTracker.baseFrame:StartMoving()
        else
            if not IsMouselooking() then
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
    end)
    
    -- MouselookStart() calls OnMouseUp immediately :(
    --frm:SetScript("OnMouseUp", function(self)
    --    print("OMU")
    --    if IsMouselooking() then MouselookStop() end
    --end)
    --frm:SetScript("OnClick", function(self)
    --    print("Clicka clacka")
    --end)
    
    frm:SetScript("OnDragStop", function() 
        _QuestieTracker.baseFrame:StopMovingOrSizing()
        Questie.db.char.TrackerLocation = {_QuestieTracker.baseFrame:GetPoint()}
    end)
    
    
    frm:Show()
    
    return frm
end