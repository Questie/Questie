---@class QuestieTracker
QuestieTracker = QuestieLoader:CreateModule("QuestieTracker")
local _QuestieTracker = QuestieTracker.private
-------------------------
--Import modules.
-------------------------
---@type QuestieQuest
local QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")
---@type QuestieMap
local QuestieMap = QuestieLoader:ImportModule("QuestieMap")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
---@type QuestiePlayer
local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestieQuestTimers
local QuestieQuestTimers = QuestieLoader:ImportModule("QuestieQuestTimers")
---@type QuestieCombatQueue
local QuestieCombatQueue = QuestieLoader:ImportModule("QuestieCombatQueue")

-- Local Vars
local trackerLineCount = 120
local trackerLineWidth = 1
local trackerHeaderBuffer = 1
local trackerLineBuffer = 1
local lineIndex = 0
local buttonIndex = 0
local lastAQW = GetTime()
local durabilityInitialPosition = nil
local LSM30 = LibStub("LibSharedMedia-3.0", true)

-- Private Global Vars
_QuestieTracker.LineFrames = {}
_QuestieTracker.ItemButtons = {}
_QuestieTracker.FadeTickerValue = 0
_QuestieTracker.FadeTickerDirection = false
_QuestieTracker.IsFirstRun = true
_QuestieTracker.trackerFontSize = 1
_QuestieTracker.trackerSpaceBuffer = 1
_QuestieTracker.trackerHeaderBuffer = 1
_QuestieTracker.trackerLineBuffer = 1
_QuestieTracker.QuestFrameIndent = 1

-- Forward declaration
local _OnClick, _OnEnter, _OnLeave
local _AQW_Insert, _RemoveQuestWatch
local _PlayerPosition, _QuestProximityTimer

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
    if not Questie.db.char.AutoUntrackedQuests then
        Questie.db.char.AutoUntrackedQuests = {}
    end
    if not Questie.db.char.collapsedZones then
        Questie.db.char.collapsedZones = {}
    end
    if not Questie.db.char.collapsedQuests then
        Questie.db.char.collapsedQuests = {}
    end
    if not Questie.db.char.TrackerWidth then
        Questie.db.char.TrackerWidth = 0
    end
    if not Questie.db.char.trackerSetpoint then
        Questie.db.char.trackerSetpoint = "AUTO"
    end

    -- Create tracker frames and assign them to a var
    _QuestieTracker.baseFrame = _QuestieTracker:CreateBaseFrame()
    _QuestieTracker.activeQuestsHeader = _QuestieTracker:CreateActiveQuestsHeader()
    _QuestieTracker.trackedQuestsFrame = _QuestieTracker:CreateTrackedQuestsFrame()

    -- Quest and Item button tables
    _QuestieTracker:CreateTrackedQuestItemButtons()
    _QuestieTracker:CreateTrackedQuestButtons()

    -- Tracker right click menu
    _QuestieTracker.menuFrame = LQuestie_Create_UIDropDownMenu("QuestieTrackerMenuFrame", UIParent)

    if Questie.db.global.hookTracking then
        QuestieTracker:HookBaseTracker()
    end

    -- Atach durability frame to the tracker if shown and Sticky Durability Frame is enabled
    if not durabilityInitialPosition then
        durabilityInitialPosition = {DurabilityFrame:GetPoint()}
    end

    C_Timer.After(0.2, function()

        -- Hide the durability frame
        DurabilityFrame:Hide()

        -- Load Objective Sorting and Tracker Layout Vars
        _QuestieTracker:UpdateLayout()
    end)

    QuestieTracker.started = true

    -- Santity checks and settings applied at login
    C_Timer.After(0.4, function()
        if Questie.db.char.TrackerLocation == nil then return end

        -- Make sure the saved tracker location cords are on the players screen
        if Questie.db.char.TrackerLocation and Questie.db.char.TrackerLocation[2] and Questie.db.char.TrackerLocation[2] == "MinimapCluster" or Questie.db.char.TrackerLocation[2] == "UIParent" then
            local baseFrame = QuestieTracker:GetBaseFrame()
            verifyBaseFrame = {unpack(Questie.db.char.TrackerLocation)}

            -- Max X values
            local maxLeft = -GetScreenWidth()/2
            if verifyBaseFrame[4] < 0 and verifyBaseFrame[4] < maxLeft then
               verifyBaseFrame[4] = maxLeft
            end

            local maxRight = GetScreenWidth()/2
            if verifyBaseFrame[4] > 0 and verifyBaseFrame[4] > maxRight then
                verifyBaseFrame[4] = maxRight
            end

            -- Max Y values
            local maxBottom = -GetScreenHeight()/2
            if verifyBaseFrame[5] < 0 and verifyBaseFrame[5] < maxBottom then
                verifyBaseFrame[5] = maxBottom
            end

            local maxTop = GetScreenHeight()/2
            if verifyBaseFrame[5] > 0 and verifyBaseFrame[5] > maxTop then
                verifyBaseFrame[5] = maxTop
            end

            -- Just in case we're in combat upon login - yeah, like that doesn't happen.
            QuestieCombatQueue:Queue(function()
                baseFrame:ClearAllPoints()
                baseFrame:SetPoint(unpack(verifyBaseFrame))
                verifyBaseFrame = nil
            end)
        end
    end)

    C_Timer.After(14.0, function()

        -- This is the best way to not check 19238192398 events which might reset the position of the DurabilityFrame
        hooksecurefunc("UIParent_ManageFramePositions", QuestieTracker.MoveDurabilityFrame)

        -- Attach DurabilityFrame to tracker
        DurabilityFrame:Show()
        QuestieTracker:MoveDurabilityFrame()

        -- Font's can occationally not apply upon login
        QuestieTracker:ResetLinesForChange()
        QuestieTracker:Update()
    end)
end

function _QuestieTracker:UpdateLayout()
    _QuestieTracker.trackerFontSize = math.max(Questie.db.global.trackerFontSizeHeader, Questie.db.global.trackerFontSizeLine)
    _QuestieTracker.trackerSpaceBuffer = Questie.db.global.trackerFontSizeHeader
    trackerHeaderBuffer = Questie.db.global.trackerFontSizeHeader
    trackerLineBuffer = Questie.db.global.trackerFontSizeLine

    if Questie.db.global.trackerSortObjectives == "byZone" then
        _QuestieTracker.QuestFrameIndent = trackerHeaderBuffer*4.25
        _QuestieTracker.trackerHeaderBuffer = trackerHeaderBuffer*4.25
        _QuestieTracker.trackerLineBuffer = trackerLineBuffer*4.25
    else
        _QuestieTracker.QuestFrameIndent = trackerHeaderBuffer*2.75
        _QuestieTracker.trackerHeaderBuffer = trackerHeaderBuffer*2.75
        _QuestieTracker.trackerLineBuffer = trackerLineBuffer*2.75
    end
end

function _QuestieTracker:CreateBaseFrame()
    local frm = CreateFrame("Frame", nil, UIParent)
    frm:SetWidth(1)
    frm:SetHeight(1)
    frm:EnableMouse(true)
    frm:SetMovable(true)
    frm:SetResizable(true)
    frm:SetMinResize(1, 1)
    frm:SetScript("OnMouseDown", _QuestieTracker.OnDragStart)
    frm:SetScript("OnMouseUp", _QuestieTracker.OnDragStop)
    frm:SetScript("OnEnter", _OnEnter)
    frm:SetScript("OnLeave", _OnLeave)
    frm:SetBackdrop( {
        bgFile="Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile=true, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    frm:SetBackdropColor(0, 0, 0, 0)
    frm:SetBackdropBorderColor(1, 1, 1, 0)

    frm.Update = function(self)
        if (Questie.db.global.trackerBackdropEnabled and Questie.db.char.isTrackerExpanded) then
            if not Questie.db.global.trackerBackdropFader then
                _QuestieTracker.baseFrame:SetBackdropColor(0, 0, 0, Questie.db.global.trackerBackdropAlpha)
                _QuestieTracker.baseFrame:SetBackdropBorderColor(1, 1, 1, Questie.db.global.trackerBackdropAlpha)
            end
        else
            _QuestieTracker.baseFrame:SetBackdropColor(0, 0, 0, 0)
            _QuestieTracker.baseFrame:SetBackdropBorderColor(1, 1, 1, 0)
            _QuestieTracker.baseFrame.sizer:SetAlpha(0)
            if (_QuestieTracker.isMoving == true) then
                _QuestieTracker.baseFrame.sizer:SetAlpha(1)
            else
                _QuestieTracker.baseFrame.sizer:SetAlpha(0)
            end
        end
    end

    local sizer = CreateFrame("Frame", nil, frm)
    sizer:SetPoint("BOTTOMRIGHT", 0, 0)
    sizer:SetWidth(25)
    sizer:SetHeight(25)
    sizer:SetAlpha(0)
    sizer:EnableMouse()
    sizer:SetFrameStrata("MEDIUM")
    sizer:SetScript("OnMouseDown", _QuestieTracker.OnResizeStart)
    sizer:SetScript("OnMouseUp", _QuestieTracker.OnResizeStop)
    sizer:SetScript("OnEnter", _OnEnter)
    sizer:SetScript("OnLeave", _OnLeave)

    frm.sizer = sizer

    local line1 = sizer:CreateTexture(nil, "BACKGROUND")
    line1:SetWidth(14)
    line1:SetHeight(14)
    line1:SetPoint("BOTTOMRIGHT", -4, 4)
    line1:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
    local x = 0.1 * 14/17
    line1:SetTexCoord(1/32 - x, 0.5, 1/32, 0.5 + x, 1/32, 0.5 - x, 1/32 + x, 0.5)

    local line2 = sizer:CreateTexture(nil, "BACKGROUND")
    line2:SetWidth(11)
    line2:SetHeight(11)
    line2:SetPoint("BOTTOMRIGHT", -4, 4)
    line2:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
    local x = 0.1 * 11/17
    line2:SetTexCoord(1/32 - x, 0.5, 1/32, 0.5 + x, 1/32, 0.5 - x, 1/32 + x, 0.5)

    local line3 = sizer:CreateTexture(nil, "BACKGROUND")
    line3:SetWidth(8)
    line3:SetHeight(8)
    line3:SetPoint("BOTTOMRIGHT", -4, 4)
    line3:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
    local x = 0.1 * 8/17
    line3:SetTexCoord(1/32 - x, 0.5, 1/32, 0.5 + x, 1/32, 0.5 - x, 1/32 + x, 0.5)

    if Questie.db.char.TrackerLocation then
        -- we need to pcall this because it can error if something like MoveAnything is used to move the tracker
        local result, error = pcall(frm.SetPoint, frm, unpack(Questie.db.char.TrackerLocation))
        if not result then
            Questie.db.char.TrackerLocation = nil
            print(QuestieLocale:GetUIString('TRACKER_INVALID_LOCATION'))
            if QuestWatchFrame then
                result, error = pcall(frm.SetPoint, frm, unpack({QuestWatchFrame:GetPoint()}))
                Questie.db.char.trackerSetpoint = "AUTO"
                if not result then
                    Questie.db.char.TrackerLocation = nil
                    _QuestieTracker:SetSafePoint(frm)
                end
            else
                _QuestieTracker:SetSafePoint(frm)
            end
        end
    else
        if QuestWatchFrame then
            local result, error = pcall(frm.SetPoint, frm, unpack({QuestWatchFrame:GetPoint()}))
            Questie.db.char.trackerSetpoint = "AUTO"
            if not result then
                Questie.db.char.TrackerLocation = nil
                print(QuestieLocale:GetUIString('TRACKER_INVALID_LOCATION'))
                _QuestieTracker:SetSafePoint(frm)
            end
        else
            _QuestieTracker:SetSafePoint(frm)
        end
    end

    frm:Hide()

    return frm
end

function _QuestieTracker:CreateActiveQuestsHeader()
    local _, numQuests = GetNumQuestLogEntries()
    local frm = CreateFrame("Button", nil, _QuestieTracker.baseFrame)
    frm.label = frm:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    frm.label:SetFont(LSM30:Fetch('font', Questie.db.global.trackerFontHeader) or STANDARD_TEXT_FONT, trackerHeaderBuffer)
    frm.label:SetText(QuestieLocale:GetUIString("TRACKER_ACTIVE_QUESTS") .. tostring(numQuests) .. "/20")
    frm.label:SetPoint("TOPLEFT", frm, "TOPLEFT", 0, 0)

    frm:SetWidth(frm.label:GetUnboundedStringWidth())
    frm:SetHeight(trackerHeaderBuffer)
    frm:SetPoint("TOPLEFT", _QuestieTracker.baseFrame, "TOPLEFT", (trackerHeaderBuffer), -(trackerHeaderBuffer))

    frm.Update = function(self)
        local _, activeQuests = GetNumQuestLogEntries()
        self.label:SetFont(LSM30:Fetch('font', Questie.db.global.trackerFontHeader) or STANDARD_TEXT_FONT, trackerHeaderBuffer)
        self.label:SetText(QuestieLocale:GetUIString("TRACKER_ACTIVE_QUESTS") .. tostring(activeQuests) .. "/20")
        self.label:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0)

        self:SetWidth(self.label:GetUnboundedStringWidth())
        self:SetHeight(trackerHeaderBuffer)

        _QuestieTracker.baseFrame:SetMinResize(trackerHeaderBuffer*2 + self.label:GetUnboundedStringWidth(), trackerHeaderBuffer*2)

        if not Questie.db.char.isTrackerExpanded then
            _QuestieTracker.trackedQuestsFrame:Hide()
            self:ClearAllPoints()
            self:SetPoint("TOPLEFT", _QuestieTracker.baseFrame, "TOPLEFT", (trackerHeaderBuffer), -(trackerHeaderBuffer))
        else
            _QuestieTracker.trackedQuestsFrame:Show()
            self:ClearAllPoints()
            self:SetPoint("TOPLEFT", _QuestieTracker.baseFrame, "TOPLEFT", (trackerHeaderBuffer), -(trackerHeaderBuffer))
        end
    end

    frm.SetMode = function(self, mode)
        if mode ~= self.mode then
            self.mode = mode
        end
    end

    if Questie.db.char.isTrackerExpanded then
        frm:SetMode(1) -- minimized
    else
        frm:SetMode(0) -- maximized
    end

    frm:EnableMouse(true)
    frm:RegisterForDrag("LeftButton")
    frm:RegisterForClicks("RightButtonUp", "LeftButtonUp")

    frm:SetScript("OnClick", function(self)
        if self.mode == 1 then
            self:SetMode(0)
            Questie.db.char.isTrackerExpanded = false
            if Questie.db.global.stickyDurabilityFrame then
                DurabilityFrame:Hide()
            end
        else
            self:SetMode(1)
            Questie.db.char.isTrackerExpanded = true
            if Questie.db.global.stickyDurabilityFrame then
                DurabilityFrame:Show()
                QuestieTracker:MoveDurabilityFrame()
            end
            _QuestieTracker.baseFrame.sizer:SetAlpha(1)
            _QuestieTracker.baseFrame:SetBackdropColor(0, 0, 0, Questie.db.global.trackerBackdropAlpha)
            _QuestieTracker.baseFrame:SetBackdropBorderColor(1, 1, 1, Questie.db.global.trackerBackdropAlpha)
        end
        QuestieTracker:Update()
    end)

    frm:SetScript("OnDragStart", _QuestieTracker.OnDragStart)
    frm:SetScript("OnDragStop", _QuestieTracker.OnDragStop)
    frm:SetScript("OnEnter", _OnEnter)
    frm:SetScript("OnLeave", _OnLeave)

    frm:Show()

    return frm
end

function _QuestieTracker:CreateTrackedQuestsFrame()
    local frm = CreateFrame("Frame", nil, _QuestieTracker.baseFrame)
    frm:SetWidth(1)
    frm:SetHeight(1)
    frm:SetPoint("TOPLEFT", _QuestieTracker.baseFrame, "TOPLEFT", (trackerHeaderBuffer*2.75), -(trackerHeaderBuffer*2.25))

    frm.Update = function(self)
        frm:ClearAllPoints()
        if Questie.db.global.trackerSortObjectives == "byZone" then
            self:SetPoint("TOPLEFT", _QuestieTracker.baseFrame, "TOPLEFT", (trackerHeaderBuffer*4.25 ), -(trackerHeaderBuffer*2.25))
        else
            self:SetPoint("TOPLEFT", _QuestieTracker.baseFrame, "TOPLEFT", (trackerHeaderBuffer*2.75), -(trackerHeaderBuffer*2.25))
        end
    end

    frm:EnableMouse(true)
    frm:RegisterForDrag("LeftButton")
    frm:SetScript("OnDragStart", _QuestieTracker.OnDragStart)
    frm:SetScript("OnDragStop", _QuestieTracker.OnDragStop)
    frm:SetScript("OnEnter", _OnEnter)
    frm:SetScript("OnLeave", _OnLeave)

    frm:Hide()

    return frm
end

function _QuestieTracker:CreateTrackedQuestItemButtons()
    -- create buttons for quest items
    for i = 1, 20 do
        local btn = CreateFrame("Button", nil, nil, "SecureActionButtonTemplate,ActionButtonTemplate")
        btn:SetAttribute("type", "item");

        btn.SetItem = function(self, id, size)
            local validTexture = nil
            for bag = 0 , 5 do -- maybe keyring still acts like a bag
                for slot = 0 , 24 do
                    local texture, count, locked, quality, _, _, link, filtered, _, itemID = GetContainerItemInfo(bag, slot)
                    if id == itemID then
                        validTexture = texture
                        break
                    end
                end
            end
            if validTexture then
                self.itemID = id
                self:SetAttribute("item", "item:" .. tostring(id));
                self:SetNormalTexture(validTexture)
                self:SetPushedTexture(validTexture)
                self:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
                self:SetSize(size, size)
                self:SetScript("OnEnter", self.OnEnter)
                self:SetScript("OnLeave", self.OnLeave)
                self:RegisterForClicks("AnyUp")
                return true
            end -- else error?
            return false
        end

        btn.OnEnter = function(self)
            GameTooltip:SetOwner(self, "ANCHOR_PRESERVE")
            GameTooltip:SetHyperlink("item:"..tostring(self.itemID)..":0:0:0:0:0:0:0")
            GameTooltip:Show()
            _OnEnter(self)
        end

        btn.OnLeave = function(self)
            GameTooltip:Hide()
            _OnLeave(self)
        end

        btn.FakeHide = function(self)
            self:RegisterForClicks(nil)
            self:SetScript("OnEnter", nil)
            self:SetScript("OnLeave", nil)
            self:SetNormalTexture(nil)
            self:SetPushedTexture(nil)
            self:SetHighlightTexture(nil)
        end

        btn:FakeHide()

        _QuestieTracker.ItemButtons[i] = btn
        _QuestieTracker.ItemButtons[i]:Hide()
    end

    return btn
end

function _QuestieTracker:CreateTrackedQuestButtons()
    -- create buttons for quests
    local lastFrame = nil
    for i = 1, trackerLineCount do
        local btn = CreateFrame("Button", nil, _QuestieTracker.trackedQuestsFrame)
        btn.label = btn:CreateFontString(nil, "ARTWORK", "GameFontNormal")

        function btn:SetMode(mode)
            if mode ~= self.mode then
                self.mode = mode
                if mode == "zone" then
                    self.label:SetFont(LSM30:Fetch('font', Questie.db.global.trackerFontHeader) or STANDARD_TEXT_FONT, trackerHeaderBuffer)
                    self.label:SetHeight(trackerHeaderBuffer)
                elseif mode == "header" then
                    self.label:SetFont(LSM30:Fetch('font', Questie.db.global.trackerFontHeader) or STANDARD_TEXT_FONT, trackerHeaderBuffer)
                    self.label:SetHeight(trackerHeaderBuffer)
                    self.button = nil
                else
                    self.label:SetFont(LSM30:Fetch('font', Questie.db.global.trackerFontHeader) or STANDARD_TEXT_FONT, trackerLineBuffer)
                    self.label:SetHeight(trackerLineBuffer)
                end
            end
        end

        function btn:SetZone(ZoneId)
            self.ZoneId = QuestieTracker.utils:GetZoneNameByID(ZoneId)
            self.expandZone.zoneId = ZoneId
        end

        function btn:SetQuest(Quest)
            self.Quest = Quest
            self.expandQuest.questId = Quest.Id
        end

        function btn:SetObjective(Objective)
            self.Objective = Objective
        end

        function btn:SetVerticalPadding(amount)
            if self.mode == "zone" then
                self:SetHeight(trackerHeaderBuffer + amount)
            elseif self.mode == "header" then
                self:SetHeight(trackerHeaderBuffer + amount)
            else
                self:SetHeight(trackerLineBuffer + amount)
            end
        end

        btn.label:SetJustifyH("LEFT")
        btn.label:SetPoint("TOPLEFT", btn)
        btn.label:Hide()

        -- autoadjust parent size for clicks
        btn.label._SetText = btn.label.SetText
        btn.label.frame = btn
        btn.label.SetText = function(self, text)
            self:_SetText(text)
            self.frame:SetWidth(self:GetWidth())
            self.frame:SetHeight(self:GetHeight())
        end

        btn:EnableMouse(true)
        btn:RegisterForDrag("LeftButton")
        btn:RegisterForClicks("RightButtonUp", "LeftButtonUp")
        btn:SetScript("OnDragStart", _QuestieTracker.OnDragStart)
        btn:SetScript("OnDragStop", _QuestieTracker.OnDragStop)
        btn:SetScript("OnClick", _OnClick)
        btn:SetScript("OnEnter", _OnEnter)
        btn:SetScript("OnLeave", _OnLeave)

        if lastFrame then
            btn:SetPoint("TOPLEFT", lastFrame, "BOTTOMLEFT", 0,0)
        else
            btn:SetPoint("TOPLEFT", _QuestieTracker.trackedQuestsFrame, "TOPLEFT", 0,0)
        end

        btn:SetWidth(1)
        btn:SetHeight(1)
        btn:SetMode("header")

        --btn:SetBackdrop({bgFile="Interface\\Tooltips\\UI-Tooltip-Background"})
        --btn:SetBackdropColor(0, 0, 0, 1)

        _QuestieTracker.LineFrames[i] = btn
        lastFrame = btn

        -- create expanding zone headers for quests sorted by zones
        local expandZone = CreateFrame("Button", nil, btn)
        expandZone:SetWidth(1)
        expandZone:SetHeight(1)
        expandZone:SetPoint("TOPLEFT", btn, "TOPLEFT", 0, 0)

        expandZone.SetMode = function(self, mode)
            if mode ~= self.mode then
                self.mode = mode
            end
        end

        expandZone:SetMode(1)
        expandZone:SetMovable(true)
        expandZone:EnableMouse(true)
        expandZone:RegisterForDrag("LeftButton")
        expandZone:RegisterForClicks("LeftButtonUp", "RightButtonUp")

        expandZone:SetScript("OnClick", function(self)
            if self.mode == 1 then
                self:SetMode(0)
            else
                self:SetMode(1)
            end
            if Questie.db.char.collapsedZones[self.zoneId] == true then
                Questie.db.char.collapsedZones[self.zoneId] = nil
            else
                Questie.db.char.collapsedZones[self.zoneId] = true
            end
            QuestieTracker:ResetLinesForChange()
            QuestieTracker:Update()
        end)

        expandZone:SetScript("OnEnter", _OnEnter)
        expandZone:SetScript("OnLeave", _OnLeave)
        expandZone:SetScript("OnDragStart", _QuestieTracker.OnDragStart)
        expandZone:SetScript("OnDragStop", _QuestieTracker.OnDragStop)
        expandZone:SetAlpha(0)
        expandZone:Hide()

        btn.expandZone = expandZone

        -- create expanding buttons for quests with objectives
        local expandQuest = CreateFrame("Button", nil, btn)
        expandQuest.texture = expandQuest:CreateTexture(nil, "OVERLAY", nil, 0)
        expandQuest.texture:SetWidth(trackerHeaderBuffer)
        expandQuest.texture:SetHeight(trackerHeaderBuffer)
        expandQuest.texture:SetAllPoints(expandQuest)

        expandQuest:SetWidth(trackerHeaderBuffer)
        expandQuest:SetHeight(trackerHeaderBuffer)
        expandQuest:SetPoint("LEFT", btn, "LEFT", 0, 0)

        expandQuest.SetMode = function(self, mode)
            if mode ~= self.mode then
                self.mode = mode
                if mode == 1 then
                    self.texture:SetTexture("Interface\\Buttons\\UI-MinusButton-Up")
                else
                    self.texture:SetTexture("Interface\\Buttons\\UI-PlusButton-Up")
                end
                self:SetWidth(trackerHeaderBuffer)
                self:SetHeight(trackerHeaderBuffer)
            end
        end

        expandQuest:SetMode(1) -- minus
        expandQuest:EnableMouse(true)
        expandQuest:RegisterForClicks("LeftButtonUp", "RightButtonUp")

        expandQuest:SetScript("OnClick", function(self)
            if self.mode == 1 then
                self:SetMode(0)
            else
                self:SetMode(1)
            end
            if Questie.db.char.collapsedQuests[self.questId] then
                Questie.db.char.collapsedQuests[self.questId] = nil
            else
                Questie.db.char.collapsedQuests[self.questId] = true
            end
            QuestieTracker:ResetLinesForChange()
            QuestieTracker:Update()
        end)

        expandQuest:SetScript("OnEnter", _OnEnter)
        expandQuest:SetScript("OnLeave", _OnLeave)
        expandQuest:SetAlpha(0)
        expandQuest:Hide()

        btn.expandQuest = expandQuest
    end

    return btn
end

function QuestieTracker:GetBaseFrame()
    return _QuestieTracker.baseFrame
end

function QuestieTracker:ResetLocation()
    if _QuestieTracker.trackerLineWidth == nil then return end
    _QuestieTracker.activeQuestsHeader:SetMode(1)
    Questie.db.char.isTrackerExpanded = true
    Questie.db.char.AutoUntrackedQuests = {}
    Questie.db.char.TrackerLocation = {}
    Questie.db.char.collapsedQuests = {}
    Questie.db.char.collapsedZones = {}
    Questie.db.char.TrackerWidth = 0

    QuestieTracker:ResetLinesForChange()

    if _QuestieTracker.baseFrame then
        _QuestieTracker:SetSafePoint(_QuestieTracker.baseFrame)
        _QuestieTracker.baseFrame:Show()
    end
end

function QuestieTracker:ResetDurabilityFrame()
    DurabilityFrame:ClearAllPoints()
    DurabilityFrame:SetPoint(unpack(durabilityInitialPosition))
end

function QuestieTracker:MoveDurabilityFrame()
    if Questie.db.global.trackerEnabled and Questie.db.global.stickyDurabilityFrame and DurabilityFrame:IsShown() and QuestieTracker.started and Questie.db.char.TrackerLocation ~= nil then
        if Questie.db.char.TrackerLocation and Questie.db.char.TrackerLocation[1] == "TOPLEFT" or Questie.db.char.TrackerLocation[1] == "BOTTOMLEFT" then
            DurabilityFrame:ClearAllPoints()
            DurabilityFrame:SetPoint("LEFT", _QuestieTracker.baseFrame, "TOPRIGHT", 0, -30)
        else
            DurabilityFrame:ClearAllPoints()
            DurabilityFrame:SetPoint("RIGHT", _QuestieTracker.baseFrame, "TOPLEFT", 0, -30)
        end
    else
        QuestieTracker:ResetDurabilityFrame()
    end
end

function _QuestieTracker:SetSafePoint(frm)
    frm:ClearAllPoints()
    local xOff, yOff = frm:GetWidth()/2, frm:GetHeight()/2
    local resetCords = {["BOTTOMLEFT"] = {x = -xOff, y = -yOff}, ["BOTTOMRIGHT"] = {x = xOff, y = -yOff}, ["TOPLEFT"] = {x = -xOff, y =  yOff}, ["TOPRIGHT"] = {x = xOff, y =  yOff}}
    if Questie.db.char.trackerSetpoint == "AUTO" then
        frm:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    else
        frm:SetPoint(Questie.db.char.trackerSetpoint, UIParent, "CENTER", resetCords[Questie.db.char.trackerSetpoint].x, resetCords[Questie.db.char.trackerSetpoint].y)
    end
end

function QuestieTracker:Enable()
    Questie.db.global.trackerEnabled = true

    -- may not have been initialized yet
    if Questie.db.global.hookTracking then
        QuestieTracker:HookBaseTracker()
    end

    QuestieQuestTimers:HideBlizzardTimer()
    QuestieTracker:Initialize()
    QuestieTracker:MoveDurabilityFrame()
    QuestieTracker:Update()
end

function QuestieTracker:Disable()
    Questie.db.global.trackerEnabled = false

    if Questie.db.global.hookTracking then
        QuestieTracker:Unhook()
    end

    QuestieQuestTimers:ShowBlizzardTimer()
    QuestieTracker:ResetDurabilityFrame()
    QuestieTracker:Update()
end

function QuestieTracker:Toggle(value)
    if value == nil then
        value = not Questie.db.global.trackerEnabled
    end

    Questie.db.global.trackerEnabled = value

    if value then
        QuestieTracker:Enable()
    else
        QuestieTracker:Disable()
    end
end

function QuestieTracker:Collapse()
    if _QuestieTracker.activeQuestsHeader and Questie.db.char.isTrackerExpanded then
        _QuestieTracker.activeQuestsHeader:Click()
    end
end

function QuestieTracker:Expand()
    if _QuestieTracker.activeQuestsHeader and (not Questie.db.char.isTrackerExpanded) then
        _QuestieTracker.activeQuestsHeader:Click()
    end
end

function QuestieTracker:Update()
    Questie:Debug(DEBUG_DEVELOP, "QuestieTracker: Update")
    trackerLineWidth = 0
    if (not QuestieTracker.started) then return; end

    -- Tracker has started but not enabled
    if (not Questie.db.global.trackerEnabled) then
        if _QuestieTracker.baseFrame and _QuestieTracker.baseFrame:IsShown() then
            QuestieCombatQueue:Queue(function()
                _QuestieTracker.baseFrame:Hide()
            end)
        end
        return
    end

    -- Update primary frames and layout
    _QuestieTracker.baseFrame:Update()
    _QuestieTracker.activeQuestsHeader:Update()
    _QuestieTracker:UpdateLayout()

    lineIndex = 0
    buttonIndex = 0

    local line = nil
    local order = {}
    local questCompletePercent = {}

    -- Update quest objectives
    for questId in pairs (QuestiePlayer.currentQuestlog) do
        local quest = QuestieDB:GetQuest(questId)
        if quest then
            if QuestieQuest:IsComplete(quest) == 1 or (not quest.Objectives) or (not next(quest.Objectives)) then
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
            table.insert(order, questId)
        end
    end

    -- Quests and objectives sort
    if Questie.db.global.trackerSortObjectives == "byComplete" then
        table.sort(order, function(a, b)
            local vA, vB = questCompletePercent[a], questCompletePercent[b]
            if vA == vB then
                local qA = QuestieDB:GetQuest(a)
                local qB = QuestieDB:GetQuest(b)
                return qA and qB and qA.level < qB.level
            end
            return vB < vA
        end)

    elseif Questie.db.global.trackerSortObjectives == "byLevel" then
        table.sort(order, function(a, b)
            local qA = QuestieDB:GetQuest(a)
            local qB = QuestieDB:GetQuest(b)
            return qA and qB and qA.level < qB.level
        end)

    elseif Questie.db.global.trackerSortObjectives == "byLevelReversed" then
        table.sort(order, function(a, b)
            local qA = QuestieDB:GetQuest(a)
            local qB = QuestieDB:GetQuest(b)
            return qA and qB and qA.level > qB.level
        end)

    elseif Questie.db.global.trackerSortObjectives == "byZone" then
        table.sort(order, function(a, b)
            qA = QuestieDB:GetQuest(a)
            qB = QuestieDB:GetQuest(b)
            local qAZone, qBZone
            if qA.zoneOrSort > 0 then
                qAZone = QuestieTracker.utils:GetZoneNameByID(qA.zoneOrSort)
            elseif qA.zoneOrSort < 0 then
                qAZone = QuestieTracker.utils:GetCatagoryNameByID(qA.zoneOrSort)
            else
                qAZone = qA.zoneOrSort
                Questie:Error("SortID: |cffffbf00"..qA.zoneOrSort.."|r was not found in the Database. Please file a bugreport at:")
                Questie:Error("|cff00bfffhttps://github.com/AeroScripts/QuestieDev/issues|r")
            end
            if qB.zoneOrSort > 0 then
                qBZone = QuestieTracker.utils:GetZoneNameByID(qB.zoneOrSort)
            elseif qB.zoneOrSort < 0 then
                qBZone = QuestieTracker.utils:GetCatagoryNameByID(qB.zoneOrSort)
            else
                qBZone = qB.zoneOrSort
                Questie:Error("SortID: |cffffbf00"..qB.zoneOrSort.."|r was not found in the Database. Please file a bugreport at:")
                Questie:Error("|cff00bfffhttps://github.com/AeroScripts/QuestieDev/issues|r")
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
        table.sort(order, function(a, b)
            local distanceA = GetDistanceToClosestObjective(a)
            local distanceB = GetDistanceToClosestObjective(b)
            local qA = QuestieDB:GetQuest(a)
            local qB = QuestieDB:GetQuest(b)
            local _, zoneA, _ = QuestieMap:GetNearestQuestSpawn(qA)
            local _, zoneB, _ = QuestieMap:GetNearestQuestSpawn(qB)
            local continent = getContinent(C_Map.GetBestMapForUnit("player"))
            local continentA = getContinent(ZoneDataAreaIDToUiMapID[zoneA])
            local continentB = getContinent(ZoneDataAreaIDToUiMapID[zoneB])
            if ((continent == continentA) and (continent == continentB)) or ((continent ~= continentA) and (continent ~= continentB)) then
                if distanceA == distanceB then
                    return qA and qB and qA.level < qB.level;
                end
                if not distanceA and distanceB then
                    return false;
                elseif distanceA and not distanceB then
                    return true;
                end
                return distanceA < distanceB;
            elseif (continent == continentA) and (continent ~= continentB) then
                return true
            elseif (continent ~= continentA) and (continent == continentB) then
                return false
            end
        end)
        if not _QuestProximityTimer then
            QuestieTracker:updateQuestProximityTimer()
        end
    end
    if (Questie.db.global.trackerSortObjectives ~= "byProximity") and _QuestProximityTimer and (_QuestProximityTimer:IsCancelled() ~= "true") then
        _QuestProximityTimer:Cancel()
        _QuestProximityTimer = nil
    end

    local hasQuest = false
    local firstQuestInZone = false
    local zoneCheck

    -- Begin populating the tracker with quests
    for _, questId in pairs (order) do
        local quest = QuestieDB:GetQuest(questId)
        local zoneName

        -- Valid ZoneID
        if (quest.zoneOrSort) > 0 then
            zoneName = QuestieTracker.utils:GetZoneNameByID(quest.zoneOrSort)

        -- Valid CatagoryID
        elseif (quest.zoneOrSort) < 0 then
            zoneName = QuestieTracker.utils:GetCatagoryNameByID(quest.zoneOrSort)

        -- Probobly not in the Database. Assign zoneOrSort ID so Questie doesn't error
        else
            zoneName = quest.zoneOrSort
            Questie:Error("SortID: |cffffbf00"..quest.zoneOrSort.."|r was not found in the Database. Please file a bugreport at:")
            Questie:Error("|cff00bfffhttps://github.com/AeroScripts/QuestieDev/issues|r")
        end

        -- Look for any updated objectives since last update
        quest.expandQuest = nil
        if quest and quest.Objectives then
            for _,Objective in pairs(quest.Objectives) do
                if Objective.Update then Objective:Update() end
                if Objective.Needed > 0 then
                    quest.expandQuest = true
                end
            end
        end

        -- Check for valid quests
        local complete = QuestieQuest:IsComplete(quest)
        if ((complete ~= 1) or Questie.db.global.trackerShowCompleteQuests) and ((GetCVar("autoQuestWatch") == "1" and not Questie.db.char.AutoUntrackedQuests[questId]) or (GetCVar("autoQuestWatch") == "0" and Questie.db.char.TrackedQuests[questId])) then
            hasQuest = true

            -- Add zones
            if Questie.db.global.trackerSortObjectives == "byZone" then
                if zoneCheck ~= zoneName then
                    firstQuestInZone = true
                end
                if firstQuestInZone then
                    line = _QuestieTracker:GetNextLine()
                    line:SetMode("zone")
                    line:SetZone(quest.zoneOrSort)
                    line.label:ClearAllPoints()
                    line.label:SetPoint("TOPLEFT", line, "TOPLEFT", -(trackerHeaderBuffer*1.75), 0)
                    line.label:SetText("|cFFC0C0C0" .. zoneName .. "|r")
                    line.label:SetWidth(math.min(math.max(Questie.db.char.TrackerWidth, _QuestieTracker.baseFrame:GetWidth()) - ((_QuestieTracker.QuestFrameIndent + trackerHeaderBuffer) - trackerHeaderBuffer*1.75), line.label:GetUnboundedStringWidth()))
                    line:SetWidth(line.label:GetWidth() - trackerHeaderBuffer*1.75)
                    trackerLineWidth = math.max(trackerLineWidth, line.label:GetUnboundedStringWidth() - trackerHeaderBuffer*1.75)

                    if Questie.db.char.collapsedZones[quest.zoneOrSort] then
                        line.expandZone:SetMode(0)
                    else
                        line.expandZone:SetMode(1)
                    end

                    line.expandZone:ClearAllPoints()
                    line.expandZone:SetWidth(line.label:GetWidth())
                    line.expandZone:SetHeight(trackerHeaderBuffer)
                    line.expandZone:SetPoint("TOPLEFT", line.label, "TOPLEFT", 0, 0)
                    line.expandZone:Show()

                    line:SetVerticalPadding(2)
                    line:Show()
                    line.label:Show()

                    firstQuestInZone = false
                    zoneCheck = zoneName
                end
            end

            -- Add quests
            line = _QuestieTracker:GetNextLine()
            line:SetMode("header")
            line:SetQuest(quest)
            line:SetObjective(nil)

            if line.expandZone then
                line.expandZone:SetAlpha(0)
                line.expandZone:Hide()
            end

            line.label:ClearAllPoints()
            line.label:SetPoint("TOPLEFT", line, "TOPLEFT", 0, 0)
            local questName = (quest.LocalizedName or quest.name)
            local coloredQuestName = QuestieLib:GetColoredQuestName(quest.Id, questName, quest.level, Questie.db.global.trackerShowQuestLevel, complete)
            line.label:SetText(coloredQuestName)
            line.label:SetWidth(math.min(math.max(Questie.db.char.TrackerWidth, _QuestieTracker.baseFrame:GetWidth()) - (_QuestieTracker.QuestFrameIndent + trackerHeaderBuffer), line.label:GetUnboundedStringWidth()))
            line:SetWidth(line.label:GetWidth())

            -- Add quest items
            if quest.sourceItemId and questCompletePercent[quest.Id] ~= 1 then
                local fontSizeCompare = trackerHeaderBuffer + trackerLineBuffer + Questie.db.global.trackerQuestPadding -- hack to allow refreshing when changing font size
                local button = _QuestieTracker:GetNextItemButton()
                button.itemID = quest.sourceItemId
                button.fontSize = fontSizeCompare
                line.button = button
                button:Hide()
                if button:SetItem(quest.sourceItemId, trackerHeaderBuffer * 1.5) then
                    button:SetParent(line)
                    local height = 0
                    local frame = line

                    while frame and frame ~= _QuestieTracker.trackedQuestsFrame do
                        local _, parent, _, xOff, yOff = frame:GetPoint()
                        height = height - (frame:GetHeight() - yOff)
                        frame = parent
                    end

                    button:ClearAllPoints()
                    button:SetPoint("TOPRIGHT", line, "TOPLEFT", -trackerHeaderBuffer/3, 0)

                    if Questie.db.char.collapsedZones[quest.zoneOrSort] then
                        quest.expandQuest = true
                        QuestieCombatQueue:Queue(function(self)
                            self:SetParent(UIParent)
                            self:Hide()
                        end, button)
                    else
                        quest.expandQuest = false
                        Questie.db.char.collapsedQuests[quest.Id] = nil
                        button:SetFrameStrata("MEDIUM")
                        button:Show()
                    end

                else
                    quest.expandQuest = true
                    button:Hide()
                end
            end

            if Questie.db.char.collapsedQuests[quest.Id] then
                line.expandQuest:SetMode(0)
            else
                line.expandQuest:SetMode(1)
            end

            if quest.expandQuest and (complete ~= 1) then
                line.expandQuest:ClearAllPoints()
                line.expandQuest:SetPoint("RIGHT", line, "LEFT", -trackerHeaderBuffer/3.25, 0)
                line:SetVerticalPadding(1)
                line.expandQuest:Show()
            elseif (complete == 1) then
                line:SetVerticalPadding(Questie.db.global.trackerQuestPadding)
            end

            line:SetVerticalPadding(2)
            line:Show()
            line.label:Show()

            if Questie.db.char.collapsedZones[quest.zoneOrSort] then
                lineIndex = lineIndex - 1;
                line:Hide()
                line.label:Hide()
            else
                trackerLineWidth = math.max(trackerLineWidth, line.label:GetUnboundedStringWidth())
            end

            -- Add quest timers (if applicable)
            line = _QuestieTracker:GetNextLine()
            local seconds = QuestieQuestTimers:GetQuestTimerByQuestId(questId, line)
            if seconds then
                line:SetMode("line")
                line:SetQuest(quest)

                if line.expandZone then
                    line.expandZone:SetAlpha(0)
                    line.expandZone:Hide()
                end

                line.label:ClearAllPoints()
                line.label:SetPoint("TOPLEFT", line, "TOPLEFT", trackerHeaderBuffer*0.25, 0)
                line.label:SetText(seconds)
                line.label:SetWidth(math.min(math.max(Questie.db.char.TrackerWidth, _QuestieTracker.baseFrame:GetWidth()) - (_QuestieTracker.QuestFrameIndent + trackerHeaderBuffer*2.25), trackerHeaderBuffer*1.25 + line.label:GetUnboundedStringWidth()))
                line:SetWidth(line.label:GetWidth())
                line:SetVerticalPadding(2)
                line:Show()
                line.label:Show()

                if Questie.db.char.collapsedZones[quest.zoneOrSort] or Questie.db.char.collapsedQuests[quest.Id] then
                    lineIndex = lineIndex - 1;
                    line:Hide()
                    line.label:Hide()
                else
                    trackerLineWidth = math.max(trackerLineWidth, line.label:GetUnboundedStringWidth() + trackerHeaderBuffer*1.25)
                end
            else
                lineIndex = lineIndex - 1
            end

            -- Add quest objectives (if applicable)
            if quest.Objectives and complete == 0 then
                if not (Questie.db.char.collapsedZones[quest.zoneOrSort] or Questie.db.char.collapsedQuests[quest.Id]) then
                    for _, objective in pairs(quest.Objectives) do
                        line = _QuestieTracker:GetNextLine()
                        line:SetMode("line")
                        line:SetQuest(quest)
                        line:SetObjective(objective)

                        if line.expandZone then
                            line.expandZone:SetAlpha(0)
                            line.expandZone:Hide()
                        end

                        line.label:ClearAllPoints()
                        line.label:SetPoint("TOPLEFT", line, "TOPLEFT", trackerHeaderBuffer*1.25, 0)
                        local lineEnding = ""
                        local objDesc = objective.Description:gsub("%.", "")
                        if objective.Needed > 0 then lineEnding = tostring(objective.Collected) .. "/" .. tostring(objective.Needed) end
                        line.label:SetText(QuestieLib:GetRGBForObjective(objective) .. objDesc .. ": " .. lineEnding)
                        line.label:SetWidth(math.min(math.max(Questie.db.char.TrackerWidth, _QuestieTracker.baseFrame:GetWidth()) - (_QuestieTracker.QuestFrameIndent + trackerHeaderBuffer*2.25), trackerHeaderBuffer*1.25 + line.label:GetUnboundedStringWidth()))
                        line:SetWidth(line.label:GetWidth())
                        trackerLineWidth = math.max(trackerLineWidth, line.label:GetUnboundedStringWidth() + trackerHeaderBuffer*1.25)
                        line:SetVerticalPadding(1)
                        line:Show()
                        line.label:Show()
                    end
                else
                    line = _QuestieTracker:GetNextLine()
                    lineIndex = lineIndex - 1
                    line.mode = nil
                    line.Quest = nil
                    line.Objective = nil
                    line.label.frame.expandQuest.questId = nil
                    line.label:ClearAllPoints()
                    line:Hide()
                end
                line:SetVerticalPadding(Questie.db.global.trackerQuestPadding)
            end
        end
    end

    -- Begin post clean up of unused frameIndexes
    _QuestieTracker.highestIndex = lineIndex
    local startUnusedFrames = 1
    local startUnusedButtons = 1

    if Questie.db.char.isTrackerExpanded then
        startUnusedFrames = lineIndex + 1
        startUnusedButtons = buttonIndex + 1
    end

    -- Hide unused quest buttons
    for i = startUnusedFrames, trackerLineCount do
        _QuestieTracker.LineFrames[i]:Hide()
        if _QuestieTracker.LineFrames[i].expandQuest then
            _QuestieTracker.LineFrames[i].expandQuest:Hide()
        end
        if _QuestieTracker.LineFrames[i].expandZone then
            _QuestieTracker.LineFrames[i].expandZone:Hide()
        end
    end

    -- Hide unused item buttons
    for i = startUnusedButtons, 20 do
        local button = _QuestieTracker.ItemButtons[i]
        if button.itemID then
            button:FakeHide()
            button.itemID = nil
            button.lineID = nil
            button.fontSize = nil
            QuestieCombatQueue:Queue(function(self)
                self:SetParent(UIParent)
                self:Hide()
            end, button)
        end
    end

    -- Auto adjust tracker size and visibility
    if not Questie.db.char.isTrackerExpanded then
        _QuestieTracker.baseFrame:SetHeight(trackerHeaderBuffer*2)
        _QuestieTracker.baseFrame:SetWidth(trackerLineWidth + _QuestieTracker.trackerSpaceBuffer + _QuestieTracker.QuestFrameIndent)
        _QuestieTracker.trackedQuestsFrame:Hide()
    elseif line then
        local activeQuestsHeaderTotal = trackerHeaderBuffer*2 + _QuestieTracker.activeQuestsHeader.label:GetUnboundedStringWidth()
        local trackerVARScombined = trackerLineWidth + _QuestieTracker.trackerSpaceBuffer + _QuestieTracker.QuestFrameIndent
        local trackerBaseFrame = _QuestieTracker.baseFrame:GetWidth()
        if Questie.db.char.TrackerWidth > 0 then
            if (Questie.db.char.TrackerWidth < activeQuestsHeaderTotal and _QuestieTracker.isMoving ~= true) then
                Questie.db.char.TrackerWidth = activeQuestsHeaderTotal

            elseif (Questie.db.char.TrackerWidth ~= trackerBaseFrame and _QuestieTracker.isMoving ~= true) then
                Questie.db.char.TrackerWidth = trackerVARScombined

            else
                _QuestieTracker.baseFrame:SetWidth(Questie.db.char.TrackerWidth)
            end
        else
            _QuestieTracker.baseFrame:SetWidth(trackerVARScombined)
            if (trackerVARScombined < activeQuestsHeaderTotal and _QuestieTracker.isMoving ~= true) then
                _QuestieTracker.baseFrame:SetWidth(activeQuestsHeaderTotal)

            elseif (trackerVARScombined ~= trackerBaseFrame and _QuestieTracker.isMoving ~= true) then
                _QuestieTracker.baseFrame:SetWidth(trackerVARScombined)
            end
        end

        -- Trims the bottom of the tracker (overall height) based on min/max'd zones and/or quests
        if line:IsVisible() or lineIndex == 1 then
            if lineIndex == 1 then
                _QuestieTracker.baseFrame:SetHeight(_QuestieTracker.baseFrame:GetTop() - line:GetBottom())
            else
                _QuestieTracker.baseFrame:SetHeight((_QuestieTracker.baseFrame:GetTop() - line:GetBottom()) + trackerHeaderBuffer  - Questie.db.global.trackerQuestPadding)
            end
        else
            local lineNum = lineIndex - 1
            line = _QuestieTracker.LineFrames[lineNum]
            _QuestieTracker.baseFrame:SetHeight((_QuestieTracker.baseFrame:GetTop() - line:GetBottom()) + trackerHeaderBuffer*2)
        end

        _QuestieTracker.baseFrame:SetMaxResize(GetScreenWidth()/2, GetScreenHeight())
        _QuestieTracker.baseFrame:SetMinResize(trackerHeaderBuffer*2 + _QuestieTracker.activeQuestsHeader.label:GetUnboundedStringWidth(), _QuestieTracker.baseFrame:GetHeight())
        _QuestieTracker.trackerLineWidth = trackerLineWidth
        _QuestieTracker.trackedQuestsFrame:Show()
    end

    -- First run clean up
    if _QuestieTracker.IsFirstRun then
        _QuestieTracker.IsFirstRun = nil
        for questId in pairs (QuestiePlayer.currentQuestlog) do
            local quest = QuestieDB:GetQuest(questId)
            if quest then
                if Questie.db.char.TrackerHiddenQuests[questId] then
                    quest.HideIcons = true
                end
                if Questie.db.char.TrackerFocus then
                    if Questie.db.char.TrackerFocus and type(Questie.db.char.TrackerFocus) == "number" and Questie.db.char.TrackerFocus == quest.Id then -- quest focus
                        QuestieTracker:FocusQuest(quest)
                    end
                end
                if quest.Objectives then
                    for _,Objective in pairs(quest.Objectives) do
                        if Questie.db.char.TrackerHiddenObjectives[tostring(questId) .. " " .. tostring(Objective.Index)] then
                            Objective.HideIcons = true
                        end
                        if  Questie.db.char.TrackerFocus and type(Questie.db.char.TrackerFocus) == "string" and Questie.db.char.TrackerFocus == tostring(quest.Id) .. " " .. tostring(Objective.Index) then
                            QuestieTracker:FocusObjective(quest, Objective)
                        end
                    end
                end
                if quest.SpecialObjectives then
                    for _, objective in pairs(quest.SpecialObjectives) do
                        if Questie.db.char.TrackerHiddenObjectives[tostring(questId) .. " " .. tostring(objective.Index)] then
                            objective.HideIcons = true
                        end
                        if  Questie.db.char.TrackerFocus and type(Questie.db.char.TrackerFocus) == "string" and Questie.db.char.TrackerFocus == tostring(quest.Id) .. " " .. tostring(objective.Index) then
                            QuestieTracker:FocusObjective(quest, objective)
                        end
                    end
                end
            end
        end
    end
    if hasQuest then
        QuestieCombatQueue:Queue(function()
            _QuestieTracker.baseFrame:Show()
        end)
    else
        QuestieCombatQueue:Queue(function()
            _QuestieTracker.baseFrame:Hide()
        end)
    end
end

function _QuestieTracker:GetNextLine()
    lineIndex = lineIndex + 1
    if _QuestieTracker.LineFrames[lineIndex].expandQuest then
        _QuestieTracker.LineFrames[lineIndex].expandQuest:Hide()
    elseif _QuestieTracker.LineFrames[lineIndex].expandZone then
        _QuestieTracker.LineFrames[lineIndex].expandZone:Hide()
    end
    return _QuestieTracker.LineFrames[lineIndex]
end

function _QuestieTracker:GetNextItemButton()
    buttonIndex = buttonIndex + 1
    return _QuestieTracker.ItemButtons[buttonIndex]
end

function _QuestieTracker:StartFadeTicker()
    if not _QuestieTracker.FadeTicker and QuestieTracker.started then
        _QuestieTracker.FadeTicker = C_Timer.NewTicker(0.02, function()
            if _QuestieTracker.FadeTickerDirection then
                if _QuestieTracker.FadeTickerValue < 0.3 then
                    _QuestieTracker.FadeTickerValue = _QuestieTracker.FadeTickerValue + 0.02

                    -- Un-fade the background and border
                    if Questie.db.char.isTrackerExpanded and Questie.db.global.trackerBackdropEnabled and Questie.db.global.trackerBackdropFader then
                        _QuestieTracker.baseFrame:SetBackdropColor(0, 0, 0, math.min(Questie.db.global.trackerBackdropAlpha, _QuestieTracker.FadeTickerValue*3.3))
                        _QuestieTracker.baseFrame:SetBackdropBorderColor(1, 1, 1, math.min(Questie.db.global.trackerBackdropAlpha, _QuestieTracker.FadeTickerValue*3.3))
                    end

                    -- Un-fade the resizer
                    if Questie.db.char.isTrackerExpanded then
                        _QuestieTracker.baseFrame.sizer:SetAlpha(_QuestieTracker.FadeTickerValue*3.3)
                    end

                    -- Un-fade the minimize buttons
                    if Questie.db.char.isTrackerExpanded then
                        for i=1, _QuestieTracker.highestIndex do
                            _QuestieTracker.LineFrames[i].expandQuest:SetAlpha(_QuestieTracker.FadeTickerValue*3.3)
                        end
                    end
                else
                    _QuestieTracker.FadeTicker:Cancel()
                    _QuestieTracker.FadeTicker = nil
                end
            else
                if _QuestieTracker.FadeTickerValue > 0 then
                    _QuestieTracker.FadeTickerValue = _QuestieTracker.FadeTickerValue - 0.02

                    -- Fade the background and border
                    if Questie.db.char.isTrackerExpanded and Questie.db.global.trackerBackdropEnabled and Questie.db.global.trackerBackdropFader then
                        _QuestieTracker.baseFrame:SetBackdropColor(0, 0, 0, math.min(Questie.db.global.trackerBackdropAlpha, _QuestieTracker.FadeTickerValue*3.3))
                        _QuestieTracker.baseFrame:SetBackdropBorderColor(1, 1, 1, math.min(Questie.db.global.trackerBackdropAlpha, _QuestieTracker.FadeTickerValue*3.3))
                    end

                    -- Fade the resizer
                    if Questie.db.char.isTrackerExpanded then
                        _QuestieTracker.baseFrame.sizer:SetAlpha(_QuestieTracker.FadeTickerValue*3.3)
                    end

                    -- Fade the minimuze buttons
                    if Questie.db.char.isTrackerExpanded then
                        for i=1, _QuestieTracker.highestIndex do
                            _QuestieTracker.LineFrames[i].expandQuest:SetAlpha(_QuestieTracker.FadeTickerValue*3.3)
                        end
                    end
                else
                    _QuestieTracker.FadeTicker:Cancel()
                    _QuestieTracker.FadeTicker = nil
                end
            end
        end)
    end
end

function QuestieTracker:UnFocus()
    -- reset HideIcons to match savedvariable state
    if not Questie.db.char.TrackerFocus then return; end
    for questId in pairs (QuestiePlayer.currentQuestlog) do
        local quest = QuestieDB:GetQuest(questId)
        if quest then
            quest.FadeIcons = nil
            if quest.Objectives then
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
                if quest.SpecialObjectives then
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
    end
    Questie.db.char.TrackerFocus = nil
end

function QuestieTracker:FocusObjective(targetQuest, targetObjective)
    if Questie.db.char.TrackerFocus and (type(Questie.db.char.TrackerFocus) ~= "string" or Questie.db.char.TrackerFocus ~= tostring(targetQuest.Id) .. " " .. tostring(targetObjective.Index)) then
        QuestieTracker:UnFocus()
    end
    Questie.db.char.TrackerFocus = tostring(targetQuest.Id) .. " " .. tostring(targetObjective.Index)
    for questId in pairs (QuestiePlayer.currentQuestlog) do
        local quest = QuestieDB:GetQuest(questId)
        if quest and quest.Objectives then
            if questId == targetQuest.Id then
                quest.HideIcons = nil
                quest.FadeIcons = nil
                for _,Objective in pairs(quest.Objectives) do
                    if Objective.Index == targetObjective.Index then
                        Objective.HideIcons = nil
                        Objective.FadeIcons = nil
                    else
                        Objective.FadeIcons = true
                    end
                end
                if quest.SpecialObjectives then
                    for _, objective in pairs(quest.SpecialObjectives) do
                        if objective.Index == targetObjective.Index then
                            objective.HideIcons = nil
                            objective.FadeIcons = nil
                        else
                            objective.FadeIcons = true
                        end
                    end
                end
            else
                quest.FadeIcons = true
            end
        end
    end
end

function QuestieTracker:FocusQuest(targetQuest)
    if Questie.db.char.TrackerFocus and (type(Questie.db.char.TrackerFocus) ~= "number" or Questie.db.char.TrackerFocus ~= targetQuest.Id) then
        QuestieTracker:UnFocus()
    end
    Questie.db.char.TrackerFocus = targetQuest.Id
    for questId in pairs (QuestiePlayer.currentQuestlog) do
        local quest = QuestieDB:GetQuest(questId)
        if quest then
            if questId == targetQuest.Id then
                quest.HideIcons = nil
                quest.FadeIcons = nil
            else
                -- if hideOnFocus
                --Quest.HideIcons = true
                quest.FadeIcons = true
            end
        end
    end
end

function QuestieTracker:Untrack(quest)
    Questie:Debug(DEBUG_DEVELOP, "QuestieTracker: Untrack")
    if GetCVar("autoQuestWatch") == "0" then
        Questie.db.char.TrackedQuests[quest.Id] = nil
    else
        Questie.db.char.AutoUntrackedQuests[quest.Id] = true
    end
    QuestieTracker:Update()
end

function QuestieTracker:Unhook()
    if not QuestieTracker._alreadyHooked then return; end
    QuestieTracker._disableHooks = true
    if QuestieTracker._IsQuestWatched then
        IsQuestWatched = QuestieTracker._IsQuestWatched
        GetNumQuestWatches = QuestieTracker._GetNumQuestWatches
    end
    _QuestieTracker._alreadyHooked = nil
    QuestWatchFrame:Show()
end

function QuestieTracker:HookBaseTracker()
    if _QuestieTracker._alreadyHooked then return; end
    QuestieTracker._disableHooks = nil

    if not QuestieTracker._alreadyHookedSecure then
        hooksecurefunc("AutoQuestWatch_Insert", _AQW_Insert)
        hooksecurefunc("AddQuestWatch", _AQW_Insert)
        hooksecurefunc("RemoveQuestWatch", _RemoveQuestWatch)

        -- completed/objectiveless tracking fix
        -- blizzard quest tracker
        local baseQLTB_OnClick = QuestLogTitleButton_OnClick
        QuestLogTitleButton_OnClick = function(self, button) -- I wanted to use hooksecurefunc but this needs to be a pre-hook to work properly unfortunately
            if (not self) or self.isHeader or not IsShiftKeyDown() then baseQLTB_OnClick(self, button) return end
            local questLogLineIndex = self:GetID() + FauxScrollFrame_GetOffset(QuestLogListScrollFrame);
            if GetNumQuestLeaderBoards(questLogLineIndex) == 0 and not IsQuestWatched(questLogLineIndex) then -- only call if we actually want to fix this quest (normal quests already call AQW_insert)
                _AQW_Insert(questLogLineIndex, QUEST_WATCH_NO_EXPIRE)
                QuestWatch_Update()
                QuestLog_SetSelection(questLogLineIndex)
                QuestLog_Update()
            else
                baseQLTB_OnClick(self, button)
            end
        end
        -- other addons


        -- totally prevent the blizzard tracker frame from showing (BAD CODE, shouldn't be needed but some have had trouble)
        QuestWatchFrame:HookScript("OnShow", function(self) if QuestieTracker._disableHooks then return end self:Hide() end)
        QuestieTracker._alreadyHookedSecure = true
    end
    if not QuestieTracker._IsQuestWatched then
        QuestieTracker._IsQuestWatched = IsQuestWatched
        QuestieTracker._GetNumQuestWatches = GetNumQuestWatches
    end
    -- this is probably bad
    IsQuestWatched = function(index)
        if "0" == GetCVar("autoQuestWatch") then
            return Questie.db.char.TrackedQuests[select(8,GetQuestLogTitle(index)) or -1]
        else
            local qid = select(8,GetQuestLogTitle(index))
            return qid and QuestiePlayer.currentQuestlog[qid] and not Questie.db.char.AutoUntrackedQuests[qid]
        end
    end
    GetNumQuestWatches = function()
        return 0
    end

    QuestWatchFrame:Hide()
    QuestieTracker._alreadyHooked = true
end

_OnClick = function(self, button)
    Questie:Debug(DEBUG_DEVELOP, "[QuestieTracker:_OnClick]")
    if _QuestieTracker.isMoving == true then
        Questie:Debug(DEBUG_DEVELOP, "[QuestieTracker:_OnClick]", "Tracker is being dragged. Don't show the menu")
        return
    end
    if self.Quest == nil then return end
    if QuestieTracker.utils:IsBindTrue(Questie.db.global.trackerbindSetTomTom, button) then
        local spawn, zone, name = QuestieMap:GetNearestQuestSpawn(self.Quest)
        if spawn then
            QuestieTracker.utils:SetTomTomTarget(name, zone, spawn[1], spawn[2])
        end
    elseif QuestieTracker.utils:IsBindTrue(Questie.db.global.trackerbindUntrack, button) then
        QuestieTracker:Untrack(self.Quest)
    elseif QuestieTracker.utils:IsBindTrue(Questie.db.global.trackerbindOpenQuestLog, button) then
        QuestieTracker.utils:ShowQuestLog(self.Quest)
    elseif button == "RightButton" then
        local menu = QuestieTracker.menu:GetMenuForQuest(self.Quest)
        LQuestie_EasyMenu(menu, _QuestieTracker.menuFrame, "cursor", 0 , 0, "MENU")
    end
end

_OnEnter = function()
    _QuestieTracker.FadeTickerDirection = true
    _QuestieTracker:StartFadeTicker()
end

_OnLeave = function()
    _QuestieTracker.FadeTickerDirection = false
    _QuestieTracker:StartFadeTicker()
end

function QuestieTracker:ResetLinesForChange()
    Questie:Debug(DEBUG_DEVELOP, "QuestieTracker: ResetLinesForChange")
    for i = 1, trackerLineCount do
        _QuestieTracker.LineFrames[i].mode = nil
        _QuestieTracker.LineFrames[i].expandQuest.mode = nil
        _QuestieTracker.LineFrames[i].expandZone.mode = nil
        _QuestieTracker.LineFrames[i]:SetWidth(1)
        _QuestieTracker.LineFrames[i].label:SetWidth(1)
        _QuestieTracker.trackedQuestsFrame:Hide()
        _QuestieTracker.trackedQuestsFrame:Update()
    end
    QuestieTracker:Update()
end

function QuestieTracker:RemoveQuest(id)
    Questie:Debug(DEBUG_DEVELOP, "QuestieTracker: RemoveQuest")
    if Questie.db.char.TrackerFocus then
        if (type(Questie.db.char.TrackerFocus) == "number" and Questie.db.char.TrackerFocus == id)
        or (type(Questie.db.char.TrackerFocus) == "string" and Questie.db.char.TrackerFocus:sub(1, #tostring(id)) == tostring(id)) then
            QuestieTracker:UnFocus()
            QuestieQuest:UpdateHiddenNotes()
        end
    end
end

local hexTable = {
    '00','11','22','33','44','55','66','77','88','99','AA','BB','CC','DD','EE','FF'
}

function _QuestieTracker:PrintProgressColor(percent, text)
    local hexGreen = hexTable[5 + math.floor(percent * 10)]
    local hexRed = hexTable[8 + math.floor((1 - percent) * 6)]
    local hexBlue = hexTable[4 + math.floor(percent * 6)]

    return "|cFF"..hexRed..hexGreen..hexBlue..text.."|r"
end

_RemoveQuestWatch = function(index, isQuestie)
    Questie:Debug(DEBUG_DEVELOP, "QuestieTracker: RemoveQuestWatch")
    if QuestieTracker._disableHooks then return end
    if not isQuestie then
        local qid = select(8,GetQuestLogTitle(index))
        if qid then
            if "0" == GetCVar("autoQuestWatch") then
                Questie.db.char.TrackedQuests[qid] = nil
            else
                Questie.db.char.AutoUntrackedQuests[qid] = true
            end
            QuestieTracker:ResetLinesForChange()
            QuestieTracker:Update()
        end
    end
end

_AQW_Insert = function(index, expire)
    Questie:Debug(DEBUG_DEVELOP, "QuestieTracker: AQW_Insert")
    if QuestieTracker._disableHooks then return end

    local now = GetTime()
    if index and index == QuestieTracker._last_aqw and (now - lastAQW) < 0.1 then return end -- this fixes double calling due to AQW+AQW_Insert (QuestGuru fix)

    lastAQW = now
    QuestieTracker._last_aqw = index
    RemoveQuestWatch(index, true) -- prevent hitting 5 quest watch limit

    local qid = select(8,GetQuestLogTitle(index))
    if qid then
        if "0" == GetCVar("autoQuestWatch") then
            if Questie.db.char.TrackedQuests[qid] then
                Questie.db.char.TrackedQuests[qid] = nil
            else
                Questie.db.char.TrackedQuests[qid] = true
            end
        else
            if Questie.db.char.AutoUntrackedQuests[qid] then
                Questie.db.char.AutoUntrackedQuests[qid] = nil
            elseif IsShiftKeyDown() and (QuestLogFrame:IsShown() or (QuestLogExFrame and QuestLogExFrame:IsShown())) then--hack
                Questie.db.char.AutoUntrackedQuests[qid] = true
            end
        end

        -- Make sure quests or zones (re)added to the tracker isn't in a minimized state
        local quest = QuestieDB:GetQuest(qid)
        local zoneId = quest.zoneOrSort

        if Questie.db.char.collapsedQuests[qid] == true then
            Questie.db.char.collapsedQuests[qid] = nil
        end

        if Questie.db.char.collapsedZones[zoneId] == true then
            Questie.db.char.collapsedZones[zoneId] = nil
        end

        QuestieTracker:ResetLinesForChange()
        QuestieTracker:Update()
    end
end

local function getWorldPlayerPosition()
    -- Turns coords into 'world' coords so it can be compared with any coords in another zone
    local uiMapId = C_Map.GetBestMapForUnit("player");
    if not uiMapId then
        return nil;
    end
    local mapPosition = C_Map.GetPlayerMapPosition(uiMapId, "player");
    local _, worldPosition = C_Map.GetWorldPosFromMapPos(uiMapId, mapPosition);
    return worldPosition;
end

local function getDistance(x1, y1, x2, y2)
    -- Basic proximity distance calculation to compare two locs (normally player position and provided loc)
    return math.sqrt( (x2-x1)^2 + (y2-y1)^2 );
end

function GetDistanceToClosestObjective(questId)
    -- main function for proximity sorting
    local player = getWorldPlayerPosition();
    if not player then
        return nil;
    end
    local coordinates = {};
    local quest = QuestieDB:GetQuest(questId);
    if not quest then return end;

    local spawn, zone, name = QuestieMap:GetNearestQuestSpawn(quest)
    if not spawn then return end;
    if not zone then return end;
    if not name then return end;
    local _, worldPosition = C_Map.GetWorldPosFromMapPos(ZoneDataAreaIDToUiMapID[zone], {
        x = spawn[1] / 100,
        y = spawn[2] / 100
        });
    tinsert(coordinates, {
        x = worldPosition.x,
        y = worldPosition.y
        });

    if not coordinates then return end
    local closestDistance;
    for _, coords in pairs(coordinates) do
        local distance = getDistance(player.x, player.y, worldPosition.x, worldPosition.y);
        if closestDistance == nil or distance < closestDistance then
            closestDistance = distance;
        end
    end
    return closestDistance;
end

function getContinent(uiMapId)
    if not uiMapId then return end;
    if (uiMapId == 947) or (uiMapId == 1459) or (uiMapId == 1460) or (uiMapId == 1461) then
        return "Azeroth"
    elseif ((uiMapId >= 1415) and (uiMapId <= 1437)) or (uiMapId == 1453) or (uiMapId == 1455) or (uiMapId == 1458) or (uiMapId == 1463) then
        return "Eastern Kingdoms"
    elseif ((uiMapId >= 1411) and (uiMapId <= 1414)) or ((uiMapId >= 1438) and (uiMapId <= 1452)) or (uiMapId == 1454) or (uiMapId == 1456) or (uiMapId == 1457) then
        return "Kalimdor"
    else
        print(uiMapId, "is unknown")
    end
end

function QuestieTracker:updateQuestProximityTimer()
    -- Check location often and update if you've moved
    C_Timer.After(3.0, function()
        _QuestProximityTimer = C_Timer.NewTicker(5.0, function()
            local position = getWorldPlayerPosition();
            if position then
                local distance = _PlayerPosition and getDistance(position.x, position.y, _PlayerPosition.x, _PlayerPosition.y);
                if not distance or distance > 0.01 then
                    initialized = true;
                    _PlayerPosition = position;
                    QuestieTracker:Update()
                end
            end
        end)
    end)
end
