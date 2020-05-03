---@class QuestieTracker
local QuestieTracker = QuestieLoader:CreateModule("QuestieTracker");
-------------------------
--Import modules.
-------------------------
---@type QuestieQuest
local QuestieQuest = QuestieLoader:ImportModule("QuestieQuest");
---@type QuestieMap
local QuestieMap = QuestieLoader:ImportModule("QuestieMap");
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib");
---@type QuestiePlayer
local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer");
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB");
---@type QuestieQuestTimers
local QuestieQuestTimers = QuestieLoader:ImportModule("QuestieQuestTimers")
---@type QuestieCombatQueue
local QuestieCombatQueue = QuestieLoader:ImportModule("QuestieCombatQueue")

local _QuestieTracker = QuestieTracker.private
_QuestieTracker.LineFrames = {}
_QuestieTracker.ItemButtons = {}

-- these should be configurable maybe
local trackerLineCount = 64 -- shouldnt need more than this
local trackerWidth = 0
local trackerBackgroundPadding = 4
local lineIndex = 0
local buttonIndex = 0
local lastAQW = GetTime()
local durabilityInitialPosition = nil
local LSM30 = LibStub("LibSharedMedia-3.0", true)

-- used for fading the background of the tracker
_QuestieTracker.FadeTickerValue = 0
_QuestieTracker.FadeTickerDirection = false -- true to fade in
_QuestieTracker.IsFirstRun = true -- bad code

-- Forward declaration
local _OnClick, _OnEnter, _OnLeave, _AQW_Insert, _RemoveQuestWatch, _PlayerPosition, _QuestProximityTimer

local function getWorldPlayerPosition() -- Turns coords into 'world' coords so it can be compared with any coords in another zone
    local uiMapID = C_Map.GetBestMapForUnit("player");
    if not uiMapID then
        return nil;
    end
    local mapPosition = C_Map.GetPlayerMapPosition(uiMapID, "player");
    local _, worldPosition = C_Map.GetWorldPosFromMapPos(uiMapID, mapPosition);
    return worldPosition;
end

local function getDistance(x1, y1, x2, y2) -- Basic proximity distance calculation to compare two locs (normally player position and provided loc)
    return math.sqrt( (x2-x1)^2 + (y2-y1)^2 );
end

function GetDistanceToClosestObjective(questID) -- main function for proximity sorting
    local player = getWorldPlayerPosition();
    if not player then
        return nil;
    end
    local coordinates = {};
    local quest = QuestieDB:GetQuest(questID);
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

function getContinent(uiMapID)
    if not uiMapID then return end;
    if (uiMapID == 947) or (uiMapID == 1459) or (uiMapID == 1460) or (uiMapID == 1461) then
        return "Azeroth"
    elseif ((uiMapID >= 1415) and (uiMapID <= 1437)) or (uiMapID == 1453) or (uiMapID == 1455) or (uiMapID == 1458) or (uiMapID == 1463) then
        return "Eastern Kingdoms"
    elseif ((uiMapID >= 1411) and (uiMapID <= 1414)) or ((uiMapID >= 1438) and (uiMapID <= 1452)) or (uiMapID == 1454) or (uiMapID == 1456) or (uiMapID == 1457) then
        return "Kalimdor"
    else
        print(uiMapID, "is unknown")
    end
end

function QuestieTracker:updateQuestProximityTimer() -- Check location often and update if you've moved
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
    end);
end

--[[function _TEST_F2()
    local bag = CreateFrame("Frame", nil, UIParent)
    local btn = CreateFrame("Button", nil, bag, "ContainerFrameItemButtonTemplate")
    btn:SetSize(32, 32)
    bag:SetSize(32, 32)
    btn:SetPoint("Center",UIParent)
    btn:SetID(3)
    bag:SetID(0)
    btn.Update = function(self)
        local texture, count, locked, quality, _, _, link, filtered, _, id = GetContainerItemInfo(0, 3)
        SetItemButtonTexture(self, texture)
        --SetItemButtonQuality(self, quality, id)
        SetItemButtonCount(self, count)
        SetItemButtonDesaturated(self, locked)
        --UpdateCooldown(self)
    end
    --local oldOnClick = btn:GetScript("OnClick")
    --btn:RegisterForClicks("LeftButton")
    btn:SetScript("OnClick", function(self)
        ContainerFrameItemButton_OnClick(self, "RightButton")
    end)
    --btn:SetScript("OnClick", function(self, a, b, c, d, e, f)
    --    oldOnClick(self, a, b, c, d, e, f)
    --end)
    btn:Update()
    btn:Show()
    return btn
end]]--

local function createItemButton()
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
        GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
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
    --btn:SetParent(_QuestieTracker.baseFrame)
    --btn:SetPoint("Center",_QuestieTracker.baseFrame)
    --btn:SetItem(159, 24)
    --btn:Show()

    return btn
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
    if not Questie.db.char.AutoUntrackedQuests then
        Questie.db.char.AutoUntrackedQuests = {} -- the reason why we separate this from TrackedQuests is so that users can switch between auto/manual without losing their manual tracking selection
    end
    if not Questie.db.char.collapsedZones then
        Questie.db.char.collapsedZones = {}
    end
    if not Questie.db.char.collapsedQuests then
        Questie.db.char.collapsedQuests = {}
    end

	_QuestieTracker.baseFrame = QuestieTracker:CreateBaseFrame()
    _QuestieTracker.activeQuestsFrame = _QuestieTracker:CreateActiveQuestsFrame()
    _QuestieTracker.menuFrame = LQuestie_Create_UIDropDownMenu("QuestieTrackerMenuFrame", UIParent)

    if Questie.db.global.hookTracking then
        QuestieTracker:HookBaseTracker()
    end

    -- Move the durability frame next to the tracker if shown
    if not durabilityInitialPosition then
        durabilityInitialPosition = {DurabilityFrame:GetPoint()}
    end
    if Questie.db.global.stickyDurabilityFrame then
        QuestieTracker:MoveDurabilityFrame()
    end

    -- This is the best way to not check 19238192398 events which might reset the position of the DurabilityFrame
    hooksecurefunc("UIParent_ManageFramePositions", QuestieTracker.MoveDurabilityFrame)

    -- create buttons for quest items
    for i = 1, 20 do
        _QuestieTracker.ItemButtons[i] = createItemButton()
    end

	local frm = CreateFrame("Button", nil, _QuestieTracker.baseFrame)
    frm:SetWidth(1)
    frm:SetHeight(1)
	frm:SetPoint("TOPLEFT", _QuestieTracker.baseFrame, "TOPLEFT", (Questie.db.global.trackerFontSizeHeader*2.75), -(Questie.db.global.trackerFontSizeHeader*2.25))

    frm.Update = function(self)
        frm:SetWidth(1)
        frm:SetHeight(1)
        frm:SetPoint("TOPLEFT", _QuestieTracker.baseFrame, "TOPLEFT", (Questie.db.global.trackerFontSizeHeader*2.75), -(Questie.db.global.trackerFontSizeHeader*2.25))
    end

	frm:EnableMouse(true)
    frm:RegisterForDrag("LeftButton")
    frm:RegisterForClicks("RightButtonUp", "LeftButtonUp")
    frm:SetScript("OnDragStart", _QuestieTracker.OnDragStart)
    frm:SetScript("OnDragStop", _QuestieTracker.OnDragStop)
    frm:SetScript("OnClick", _OnClick)
    frm:SetScript("OnEnter", _OnEnter)
    frm:SetScript("OnLeave", _OnLeave)

	_QuestieTracker.trackedQuestsFrame = frm

	_QuestieTracker.trackedQuestButtons = QuestieTracker:CreateTrackedQuestButtons()

	QuestieTracker.started = true

	C_Timer.After(0.1, function() -- quick fix for font changes not being applied on login
		QuestieTracker:ResetLinesForFontChange()
		QuestieTracker:Update()
	end)
end

function QuestieTracker:ResetLocation()
    Questie.db.char.TrackerLocation = nil
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
    if Questie.db.global.trackerEnabled and DurabilityFrame:IsShown() then -- todo: check if frames are actually on top of eachother (user might have tracker at the other side of the screen)
        DurabilityFrame:ClearAllPoints()
        DurabilityFrame:SetPoint("RIGHT", _QuestieTracker.baseFrame, "TOPLEFT", 0, -30)
    end
end

function _QuestieTracker:SetSafePoint(frm)
    frm:ClearAllPoints();
    frm:SetPoint(Questie.db.global.trackerSetpoint, UIParent, "CENTER", 0,0)
end

function QuestieTracker:CreateBaseFrame()
    local frm = CreateFrame("Frame", nil, UIParent)
    frm:SetWidth(1)
    frm:SetHeight(1)

	frm.Update = function(self)
		if (Questie.db.global.trackerBackdropEnabled == true and Questie.db.char.isTrackerExpanded == true) then
			_QuestieTracker.baseFrame:SetBackdrop( {
				bgFile="Interface\\Tooltips\\UI-Tooltip-Background",
				edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
				tile=true, edgeSize = 16,
				insets = { left = 4, right = 4, top = 4, bottom = 4 },
			});
			_QuestieTracker.baseFrame:SetBackdropColor(0,0,0,Questie.db.global.trackerBackdropAlpha);
			_QuestieTracker.baseFrame:SetBackdropBorderColor(1,1,1,Questie.db.global.trackerBackdropAlpha);
		else
			_QuestieTracker.baseFrame:SetBackdropColor(0,0,0,0);
			_QuestieTracker.baseFrame:SetBackdropBorderColor(1,1,1,0);
		end
	end

    if Questie.db.char.TrackerLocation and Questie.db.char.TrackerLocation[1] and Questie.db.char.TrackerLocation[1] ~= Questie.db.global.trackerSetpoint then
        print(QuestieLocale:GetUIString('TRACKER_INVALID_LOCATION') .. " (2)")
        Questie.db.char.TrackerLocation = nil
    end
    if Questie.db.char.TrackerLocation then
        -- we need to pcall this because it can error if something like MoveAnything is used to move the tracker
        local result, error = pcall(frm.SetPoint, frm, unpack(Questie.db.char.TrackerLocation))
        if not result then
            Questie.db.char.TrackerLocation = nil
            print(QuestieLocale:GetUIString('TRACKER_INVALID_LOCATION'))
            if QuestWatchFrame then
                result, error = pcall(frm.SetPoint, frm, unpack({QuestWatchFrame:GetPoint()}))
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
            if not result then
                Questie.db.char.TrackerLocation = nil
                print(QuestieLocale:GetUIString('TRACKER_INVALID_LOCATION'))
                _QuestieTracker:SetSafePoint(frm)
            end
        else
            _QuestieTracker:SetSafePoint(frm)
        end
    end

	frm:SetMovable(true)
	frm:EnableMouse(true)
	frm:SetScript("OnMouseDown", _QuestieTracker.OnDragStart)
	frm:SetScript("OnMouseUp", _QuestieTracker.OnDragStop)

	frm:SetScript("OnEnter", _OnEnter)
	frm:SetScript("OnLeave", _OnLeave)

    frm:Hide()

    return frm
end

function QuestieTracker:GetBaseFrame()
    return _QuestieTracker.baseFrame
end

function QuestieTracker:SetBaseFrame(frm)
    _QuestieTracker.baseFrame = frm
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

function _QuestieTracker:CreateActiveQuestsFrame()
    local _, numQuests = GetNumQuestLogEntries()
    local frm = CreateFrame("Button", nil, _QuestieTracker.baseFrame)
    frm.label = frm:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	frm.label:SetFont(LSM30:Fetch('font', Questie.db.global.trackerFontHeader) or STANDARD_TEXT_FONT, Questie.db.global.trackerFontSizeHeader)
    frm.label:SetText(QuestieLocale:GetUIString("TRACKER_ACTIVE_QUESTS") .. tostring(numQuests) .. "/20")
	frm.label:SetPoint("TOPLEFT", _QuestieTracker.baseFrame, "TOPLEFT", 0,0)
    frm:SetWidth(frm.label:GetWidth())
    frm:SetHeight(frm.label:GetHeight())
	frm:SetPoint("TOPLEFT", _QuestieTracker.baseFrame, "TOPLEFT", 0,0)

	frm.Update = function(self)
        local _, activeQuests = GetNumQuestLogEntries()
        self.label:SetFont(LSM30:Fetch('font', Questie.db.global.trackerFontHeader) or STANDARD_TEXT_FONT, Questie.db.global.trackerFontSizeHeader)
        self.label:SetText(QuestieLocale:GetUIString("TRACKER_ACTIVE_QUESTS") .. tostring(activeQuests) .. "/20")
        self:SetHeight(Questie.db.global.trackerFontSizeHeader)
        self.label:SetPoint("TOPLEFT", _QuestieTracker.baseFrame, "TOPLEFT", (Questie.db.global.trackerFontSizeHeader), -(Questie.db.global.trackerFontSizeHeader))
		if not Questie.db.char.isTrackerExpanded then
			_QuestieTracker.baseFrame:Hide()
			if _QuestieTracker.baseFrame:GetPoint() == "BOTTOMLEFT" or _QuestieTracker.baseFrame:GetPoint() == "BOTTOMRIGHT" then
				self:SetPoint("BOTTOMLEFT", _QuestieTracker.baseFrame, "BOTTOMLEFT", (Questie.db.global.trackerFontSizeHeader), (Questie.db.global.trackerFontSizeHeader))
			end
		else
			_QuestieTracker.baseFrame:Show()
			self:SetPoint("TOPLEFT", _QuestieTracker.baseFrame, "TOPLEFT", (Questie.db.global.trackerFontSizeHeader), -(Questie.db.global.trackerFontSizeHeader))
		end
    end

	frm:EnableMouse(true)
    frm:RegisterForDrag("LeftButton")
    frm:RegisterForClicks("RightButtonUp", "LeftButtonUp")
    frm:SetScript("OnDragStart", _QuestieTracker.OnDragStart)
    frm:SetScript("OnDragStop", _QuestieTracker.OnDragStop)
    frm:SetScript("OnClick", _OnClick)
    frm:SetScript("OnEnter", _OnEnter)
    frm:SetScript("OnLeave", _OnLeave)

    local expandHeader = CreateFrame("Button", nil, frm)
    expandHeader:SetWidth(frm.label:GetWidth())
    expandHeader:SetHeight(Questie.db.global.trackerFontSizeHeader)
    expandHeader:SetPoint("TOPLEFT", _QuestieTracker.baseFrame, "TOPLEFT", 0,0)

    expandHeader.SetMode = function(self, mode)
        if mode ~= self.mode then
            self.mode = mode
        end
    end
    if Questie.db.char.isTrackerExpanded then
        expandHeader:SetMode(1) -- minimized
    else
        expandHeader:SetMode(0) -- maximized
    end
    expandHeader:EnableMouse(true)
	expandHeader:RegisterForDrag("LeftButton")
    expandHeader:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    expandHeader:SetScript("OnClick", function(self)
        if self.mode == 1 then
            self:SetMode(0)
            Questie.db.char.isTrackerExpanded = false
        else
            self:SetMode(1)
            Questie.db.char.isTrackerExpanded = true
        end
		_QuestieTracker.trackedQuestsFrame:Hide()
        QuestieTracker:Update()
    end)
    expandHeader:SetScript("OnDragStart", _QuestieTracker.OnDragStart)
    expandHeader:SetScript("OnDragStop", _QuestieTracker.OnDragStop)
    expandHeader:SetScript("OnEnter", _OnEnter)
    expandHeader:SetScript("OnLeave", _OnLeave)

	expandHeader.Update = function(self)
		expandHeader:SetWidth(frm.label:GetWidth())
		expandHeader:SetHeight(Questie.db.global.trackerFontSizeHeader)
		expandHeader:SetPoint("TOPLEFT", _QuestieTracker.baseFrame, "TOPLEFT", (Questie.db.global.trackerFontSizeHeader*2), -(Questie.db.global.trackerFontSizeHeader))
    end

    _QuestieTracker.expandHeader = expandHeader

    frm:Show()

    return frm
end

function QuestieTracker:GetActiveQuestsFrame()
    return _QuestieTracker.activeQuestsFrame
end

function QuestieTracker:CreateTrackedQuestButtons()
    local lastFrame = nil
    for i = 1, trackerLineCount do
        local frm = CreateFrame("Button", nil, _QuestieTracker.trackedQuestsFrame)
        frm.label = frm:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		function frm:SetMode(mode)
			if mode ~= self.mode then
				self.mode = mode
				if mode == "zone" then
					self.label:SetFont(LSM30:Fetch('font', Questie.db.global.trackerFontHeader) or STANDARD_TEXT_FONT, Questie.db.global.trackerFontSizeHeader)
					self:SetHeight(Questie.db.global.trackerFontSizeHeader)
				elseif mode == "header" then
					self.label:SetFont(LSM30:Fetch('font', Questie.db.global.trackerFontHeader) or STANDARD_TEXT_FONT, Questie.db.global.trackerFontSizeHeader)
					self:SetHeight(Questie.db.global.trackerFontSizeHeader)
				else
					self.label:SetFont(LSM30:Fetch('font', Questie.db.global.trackerFontHeader) or STANDARD_TEXT_FONT, Questie.db.global.trackerFontSizeLine)
					self:SetHeight(Questie.db.global.trackerFontSizeLine)
				end
			end
		end

		function frm:SetZone(ZoneId)
			self.ZoneId = QuestieTracker.utils:GetZoneNameByID(ZoneId)
			self.expandHeader.zoneId = ZoneId
		end

        function frm:SetQuest(Quest)
            self.Quest = Quest
            self.expandButton.questId = Quest.Id
        end

        function frm:SetObjective(Objective)
            self.Objective = Objective
        end

        function frm:SetVerticalPadding(amount)
            if self.mode == "zone" then
                self:SetHeight(Questie.db.global.trackerFontSizeHeader + amount)
            elseif self.mode == "header" then
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
        frm:RegisterForDrag("LeftButton")
        frm:RegisterForClicks("RightButtonUp", "LeftButtonUp")
        frm:SetScript("OnDragStart", _QuestieTracker.OnDragStart)
        frm:SetScript("OnDragStop", _QuestieTracker.OnDragStop)
        frm:SetScript("OnClick", _OnClick)
        frm:SetScript("OnEnter", _OnEnter)
        frm:SetScript("OnLeave", _OnLeave)


        if lastFrame then
            frm:SetPoint("TOPLEFT", lastFrame, "BOTTOMLEFT", 0,0)
        else
            frm:SetPoint("TOPLEFT", _QuestieTracker.trackedQuestsFrame, "TOPLEFT", 0,0)
        end

		frm:SetWidth(1)
        frm:SetMode("header")
        _QuestieTracker.LineFrames[i] = frm
        lastFrame = frm

		-- create expanding zone headers for quests sorted by zones
		local expandHeader = CreateFrame("Button", nil, frm)
		expandHeader:SetWidth(1)
		expandHeader:SetHeight(1)
		expandHeader:SetPoint("TOPLEFT", frm, "TOPLEFT", 0, 0)

		expandHeader.SetMode = function(self, mode)
			if mode ~= self.mode then
				self.mode = mode
			end
		end

		expandHeader:SetMode(1)
		expandHeader:SetMovable(true)
		expandHeader:EnableMouse(true)
		expandHeader:RegisterForDrag("LeftButton")
		expandHeader:RegisterForClicks("LeftButtonUp", "RightButtonUp")

		expandHeader:SetScript("OnClick", function(self)
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
			_QuestieTracker.trackedQuestsFrame:Hide()
			QuestieTracker:Update()
		end)

		expandHeader:SetScript("OnEnter", _OnEnter)
		expandHeader:SetScript("OnLeave", _OnLeave)
		expandHeader:SetScript("OnDragStart", _QuestieTracker.OnDragStart)
		expandHeader:SetScript("OnDragStop", _QuestieTracker.OnDragStop)
		expandHeader:SetAlpha(0)
		expandHeader:Hide()

		frm.expandHeader = expandHeader

		-- create expanding buttons for quests with objectives
		local expandButton = CreateFrame("Button", nil, frm)
		expandButton.texture = expandButton:CreateTexture(nil, "OVERLAY", nil, 0)
		expandButton.texture:SetWidth(Questie.db.global.trackerFontSizeHeader)
		expandButton.texture:SetHeight(Questie.db.global.trackerFontSizeHeader)
		expandButton.texture:SetAllPoints(expandButton)

		expandButton:SetWidth(Questie.db.global.trackerFontSizeHeader)
		expandButton:SetHeight(Questie.db.global.trackerFontSizeHeader)
		expandButton:SetPoint("TOPLEFT", frm, "TOPLEFT", 0, 0)

		expandButton.SetMode = function(self, mode)
			if mode ~= self.mode then
				self.mode = mode
				if mode == 1 then
					self.texture:SetTexture("Interface\\Buttons\\UI-MinusButton-Up")
				else
					self.texture:SetTexture("Interface\\Buttons\\UI-PlusButton-Up")
				end
			end
		end

		expandButton:SetMode(1) -- minus
		expandButton:SetMovable(true)
		expandButton:EnableMouse(true)
		expandButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")

		expandButton:SetScript("OnClick", function(self)
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
			_QuestieTracker.trackedQuestsFrame:Hide()
			QuestieTracker:Update()
		end)

		expandButton:SetScript("OnEnter", _OnEnter)
		expandButton:SetScript("OnLeave", _OnLeave)
		expandButton:SetScript("OnDragStart", _QuestieTracker.OnDragStart)
		expandButton:SetScript("OnDragStop", _QuestieTracker.OnDragStop)
		expandButton:SetAlpha(0)
		expandButton:Hide()

		frm.expandButton = expandButton
    end

    return frm
end

function QuestieTracker:Collapse()
    if _QuestieTracker.expandHeader and Questie.db.char.isTrackerExpanded then
        _QuestieTracker.expandHeader:Click()
    end
end

function QuestieTracker:Expand()
    if _QuestieTracker.expandHeader and (not Questie.db.char.isTrackerExpanded) then
        _QuestieTracker.expandHeader:Click()
    end
end

function QuestieTracker:GetBackgroundPadding()
    return trackerBackgroundPadding
end

function QuestieTracker:Update()
    Questie:Debug(DEBUG_DEVELOP, "QuestieTracker: Update")
	trackerWidth = 0
    if (not QuestieTracker.started) then return; end
    if (not Questie.db.global.trackerEnabled) then

        -- tracker has started but not enabled
        if _QuestieTracker.baseFrame and _QuestieTracker.baseFrame:IsShown() then
            QuestieCombatQueue:Queue(function()
                _QuestieTracker.baseFrame:Hide()
            end)
        end
        return
    end
	_QuestieTracker.baseFrame:Update()
    _QuestieTracker.activeQuestsFrame:Update()
	_QuestieTracker.expandHeader:Update()
    lineIndex = 0 -- zero because it simplifies GetNextLine()
    buttonIndex = 0
    local line = nil
    order = {}
    local questCompletePercent = {}
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

    for _, questId in pairs (order) do

		-- Quest.userData.tracked and zone kung-fu
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

        -- Make sure objective data is up to date
		quest.expandButton = nil
        if quest and quest.Objectives then
            for _,Objective in pairs(quest.Objectives) do
                if Objective.Update then Objective:Update() end
				if Objective.Needed > 0 then
					quest.expandButton = true
				end
            end
        end

		-- Populate the QuestTracker
		local complete = QuestieQuest:IsComplete(quest)
        if ((complete ~= 1) or Questie.db.global.trackerShowCompleteQuests) and ((GetCVar("autoQuestWatch") == "1" and not Questie.db.char.AutoUntrackedQuests[questId]) or (GetCVar("autoQuestWatch") == "0" and Questie.db.char.TrackedQuests[questId])) then -- maybe have an option to display quests in the list with (Complete!) in the title
            hasQuest = true

			-- Add zone header
			if Questie.db.global.trackerSortObjectives == "byZone" then
				if zoneCheck ~= zoneName then
					firstQuestInZone = true
				end

				if firstQuestInZone then
					line = _QuestieTracker:GetNextLine()
					line:SetMode("zone")
					line:SetZone(quest.zoneOrSort)
					line.label:SetText("|cFFC0C0C0" .. zoneName .. "|r")
					if Questie.db.char.collapsedZones[quest.zoneOrSort] then
						line.expandHeader:SetMode(0)
					else
						line.expandHeader:SetMode(1)
					end
					line.expandHeader:SetWidth(line.label:GetWidth())

					line.expandHeader:SetHeight(Questie.db.global.trackerFontSizeHeader)
					line.expandHeader:SetPoint("TOPLEFT", line, "TOPLEFT", 0, 0)
					line.expandHeader:Show()
					line.label:Show()
					line:SetVerticalPadding(Questie.db.global.trackerQuestPadding)
					line:Show()
					firstQuestInZone = false
					zoneCheck = zoneName
				end
			end

			-- Add quests
			line = _QuestieTracker:GetNextLine()
            line:SetMode("header")
            line:SetQuest(quest)
            line:SetObjective(nil)

			-- Quest item buttons
            if quest.sourceItemId and questCompletePercent[quest.Id] ~= 1 then
                local button = _QuestieTracker:GetNextItemButton()
                local fontSizeCompare = Questie.db.global.trackerFontSizeHeader + Questie.db.global.trackerFontSizeLine + Questie.db.global.trackerQuestPadding -- hack to allow refreshing when changing font size
				if (lineIndex ~= button.lineID or quest.sourceItemId ~= button.itemID or fontSizeCompare ~= button.fontSize) then
                    button.lineID = lineIndex -- immediately set to prevent double-queue
                    button.itemID = quest.sourceItemId
                    button.fontSize = fontSizeCompare
                    button.line = line
                    QuestieCombatQueue:Queue(function(self)
                        if self:SetItem(quest.sourceItemId, Questie.db.global.trackerFontSizeHeader * 1.7) then
                            self:SetParent(_QuestieTracker.trackedQuestsFrame)
                            local height = 0 -- there has to be a better way of calculating this
                            local frame = self.line
                            while frame and frame ~= _QuestieTracker.trackedQuestsFrame do
                                local _,parent,_,xOff,yOff = frame:GetPoint()
                                height = height - (frame:GetHeight() - yOff)
                                frame = parent
                            end
                            local linep = {self.line:GetPoint()}
							if Questie.db.global.trackerSortObjectives == "byZone" then
	                            self:SetPoint("TOPLEFT", button.line, "TOPLEFT", Questie.db.global.trackerFontSizeHeader/10, -Questie.db.global.trackerFontSizeHeader/6)
							else
								self:SetPoint("TOPLEFT", button.line, "TOPLEFT", -(Questie.db.global.trackerFontSizeHeader*2), -Questie.db.global.trackerFontSizeHeader/6)
							end
							self:SetFrameStrata("HIGH")
							self:Show()
                        else
                            self:Hide()
                        end
                    end, button)
                end
				quest.expandButton = false
				button.line:SetVerticalPadding(Questie.db.global.trackerQuestPadding)
            else
				if Questie.db.global.trackerSortObjectives == "byZone" then
					line.expandButton:SetPoint("TOPLEFT", line, "TOPLEFT", (Questie.db.global.trackerFontSizeHeader/1.20), -Questie.db.global.trackerFontSizeHeader/6)
				else
					line.expandButton:SetPoint("TOPLEFT", line, "TOPLEFT", -(Questie.db.global.trackerFontSizeHeader*1.25), -Questie.db.global.trackerFontSizeHeader/6)
				end
            end

			-- Show item button depending on collapsed zone state
			for i = 1, buttonIndex do
				local button = _QuestieTracker.ItemButtons[i]
				if button.itemID and button.line.Quest.Zone == quest.zoneOrSort and Questie.db.char.collapsedZones[quest.zoneOrSort] then
					QuestieCombatQueue:Queue(function(self)
						self:SetParent(UIParent)
						self:Hide()
					end, button)
				else
					button:SetFrameStrata("HIGH")
					button:Show()
				end
			end

			local questName = (quest.LocalizedName or quest.name)
            local coloredQuestName = QuestieLib:GetColoredQuestName(quest.Id, questName, quest.level, Questie.db.global.trackerShowQuestLevel, complete)

            if Questie.db.char.collapsedQuests[quest.Id] then
                line.expandButton:SetMode(0)
            else
                line.expandButton:SetMode(1)
            end

			if quest.expandButton and (complete ~= 1) then
				line.expandButton:Show()
			end

			if Questie.db.global.trackerSortObjectives == "byZone" then
				line.label:SetPoint("TOPLEFT", line, "TOPLEFT", 0, 0)
	            line.label:SetText("        " .. coloredQuestName)
			else
				line.label:SetText(coloredQuestName)
			end

			line:SetVerticalPadding(Questie.db.global.trackerQuestPadding)
            line:Show()
            line.label:Show()

			if line.expandHeader then
				line.expandHeader:SetAlpha(0)
				line.expandHeader:Hide()
			end

            trackerWidth = math.max(trackerWidth, line.label:GetWidth())

			if Questie.db.char.collapsedZones[quest.zoneOrSort] then
				lineIndex = lineIndex - 1;
				line:Hide()
				line.label:Hide()
			end

			-- Add quest timer (if applicable)
            line = _QuestieTracker:GetNextLine()
            local seconds = QuestieQuestTimers:GetQuestTimerByQuestId(questId, line)
            if seconds then
                line:SetMode("line")
                line:SetQuest(quest)
				if Questie.db.global.trackerSortObjectives == "byZone" then
					line.label:SetPoint("TOPLEFT", line, "TOPLEFT", 32, 0)
					line.label:SetText(seconds)
				else
					line.label:SetText("    " .. seconds)
				end
				line:SetVerticalPadding(Questie.db.global.trackerQuestPadding)
                line:Show()
                line.label:Show()
				if Questie.db.char.collapsedZones[quest.zoneOrSort] or Questie.db.char.collapsedQuests[quest.Id] then
					lineIndex = lineIndex - 1;
					line:Hide()
					line.label:Hide()
				end
            else
                -- We didn't need the line so we can reuse it
				lineIndex = lineIndex - 1
            end

			-- Add quest objectives (if applicable)
            if quest.Objectives and complete == 0 then
                for _, objective in pairs(quest.Objectives) do
                    line = _QuestieTracker:GetNextLine()
                    line:SetMode("line")
                    line:SetQuest(quest)
                    line:SetObjective(objective)
                    local lineEnding = "" -- initialize because its not set if Needed is 0
                    if objective.Needed > 0 then
                        lineEnding = tostring(objective.Collected) .. "/" .. tostring(objective.Needed)
                    end

					if Questie.db.global.trackerSortObjectives == "byZone" then
						line.label:SetText("              " .. QuestieLib:GetRGBForObjective(objective) .. objective.Description .. ": " .. lineEnding)
					else
	                    line.label:SetText("    " .. QuestieLib:GetRGBForObjective(objective) .. objective.Description .. ": " .. lineEnding)
					end

					line:SetVerticalPadding(Questie.db.global.trackerQuestPadding)
					line:Show()
                    line.label:Show()

					if line.expandHeader then
						line.expandHeader:SetAlpha(0)
						line.expandHeader:Hide()
					end

					trackerWidth = math.max(trackerWidth, line.label:GetWidth())

					if Questie.db.char.collapsedZones[quest.zoneOrSort] or Questie.db.char.collapsedQuests[quest.Id] then
						lineIndex = lineIndex - 1;
						line:Hide()
						line.label:Hide()
					end
                end
			end
        end
    end
    _QuestieTracker.highestIndex = lineIndex
    local startUnusedFrames = 1 -- Hide all frames
    local startUnusedButtons = 1
    if Questie.db.char.isTrackerExpanded then
        startUnusedFrames = lineIndex + 1 -- Only hide unused frames
        startUnusedButtons = buttonIndex + 1
    end
    for i = startUnusedFrames, trackerLineCount do
		_QuestieTracker.LineFrames[i]:Hide()
		if _QuestieTracker.LineFrames[i].expandButton then
			_QuestieTracker.LineFrames[i].expandButton:Hide()
		end
		if _QuestieTracker.LineFrames[i].expandHeader then
			_QuestieTracker.LineFrames[i].expandHeader:Hide()
		end
    end
    -- and remaining buttons
    for i = startUnusedButtons, 20 do
        local button = _QuestieTracker.ItemButtons[i]
        if button.itemID then
            button:FakeHide()
            button.itemID = nil -- immediately clear to prevent double-queue
            button.lineID = nil
            button.fontSize = nil
            QuestieCombatQueue:Queue(function(self)
                self:SetParent(UIParent)
                self:Hide()
            end, button)
        end
    end
    -- adjust base frame size
    if not Questie.db.char.isTrackerExpanded then
        _QuestieTracker.baseFrame:SetHeight(Questie.db.global.trackerFontSizeHeader*2)
        _QuestieTracker.trackedQuestsFrame:Hide()
    elseif line then
        _QuestieTracker.baseFrame:SetWidth(trackerWidth + trackerBackgroundPadding*2 + Questie.db.global.trackerFontSizeHeader*4 )
        _QuestieTracker.baseFrame:SetHeight((_QuestieTracker.baseFrame:GetTop() - line:GetBottom()) + Questie.db.global.trackerFontSizeHeader)
        _QuestieTracker.trackedQuestsFrame:Show()
    end
    -- make sure tracker is inside the screen
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
    -- bit of a hack
	if _QuestieTracker.LineFrames[lineIndex].expandButton then
	    _QuestieTracker.LineFrames[lineIndex].expandButton:Hide()
	elseif _QuestieTracker.LineFrames[lineIndex].expandHeader then
	    _QuestieTracker.LineFrames[lineIndex].expandHeader:Hide()
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
                    _QuestieTracker.FadeTickerValue = _QuestieTracker.FadeTickerValue + 0.06
                    if Questie.db.char.trackerBackgroundEnabled then
                        _QuestieTracker.baseFrame.texture:SetVertexColor(1,1,1,_QuestieTracker.FadeTickerValue)
                    end
                    if Questie.db.char.isTrackerExpanded then
                        for i=1, _QuestieTracker.highestIndex do
                            _QuestieTracker.LineFrames[i].expandButton:SetAlpha(_QuestieTracker.FadeTickerValue*3.3)
                        end
                    end
					if _QuestieTracker.expandButton then
						_QuestieTracker.expandButton:SetAlpha(_QuestieTracker.FadeTickerValue*3.3)
					end
                else
                    _QuestieTracker.FadeTicker:Cancel()
                    _QuestieTracker.FadeTicker = nil
                end
            else
                if _QuestieTracker.FadeTickerValue > 0 then
                    _QuestieTracker.FadeTickerValue = _QuestieTracker.FadeTickerValue - 0.06
                    if Questie.db.char.trackerBackgroundEnabled then
                        _QuestieTracker.baseFrame.texture:SetVertexColor(1,1,1,math.max(0,_QuestieTracker.FadeTickerValue))
                    end
                    if Questie.db.char.isTrackerExpanded then
                        for i=1, _QuestieTracker.highestIndex do
                            _QuestieTracker.LineFrames[i].expandButton:SetAlpha(_QuestieTracker.FadeTickerValue*3.3)
                        end
                    end
					if _QuestieTracker.expandButton then
						_QuestieTracker.expandButton:SetAlpha(_QuestieTracker.FadeTickerValue*3.3)
					end
                else
                    _QuestieTracker.FadeTicker:Cancel()
                    _QuestieTracker.FadeTicker = nil
                end
            end
        end)
    end
end

function QuestieTracker:UnFocus() -- reset HideIcons to match savedvariable state
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

function QuestieTracker:FocusObjective(TargetQuest, TargetObjective)
    if Questie.db.char.TrackerFocus and (type(Questie.db.char.TrackerFocus) ~= "string" or Questie.db.char.TrackerFocus ~= tostring(TargetQuest.Id) .. " " .. tostring(TargetObjective.Index)) then
        QuestieTracker:UnFocus()
    end
    Questie.db.char.TrackerFocus = tostring(TargetQuest.Id) .. " " .. tostring(TargetObjective.Index)
    for questId in pairs (QuestiePlayer.currentQuestlog) do
        local quest = QuestieDB:GetQuest(questId)
        if quest and quest.Objectives then
            if questId == TargetQuest.Id then
                quest.HideIcons = nil
                quest.FadeIcons = nil
                for _,Objective in pairs(quest.Objectives) do
                    if Objective.Index == TargetObjective.Index then
                        Objective.HideIcons = nil
                        Objective.FadeIcons = nil
                    else
                        Objective.FadeIcons = true
                    end
                end
                if quest.SpecialObjectives then
                    for _, objective in pairs(quest.SpecialObjectives) do
                        if objective.Index == TargetObjective.Index then
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

function QuestieTracker:FocusQuest(TargetQuest)
    if Questie.db.char.TrackerFocus and (type(Questie.db.char.TrackerFocus) ~= "number" or Questie.db.char.TrackerFocus ~= TargetQuest.Id) then
        QuestieTracker:UnFocus()
    end
    Questie.db.char.TrackerFocus = TargetQuest.Id
    for questId in pairs (QuestiePlayer.currentQuestlog) do
        local quest = QuestieDB:GetQuest(questId)
        if quest then
            if questId == TargetQuest.Id then
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

function QuestieTracker:ResetLinesForFontChange()
    for i = 1, trackerLineCount do
        _QuestieTracker.LineFrames[i].mode = nil
        _QuestieTracker.trackedQuestsFrame:Hide()
        _QuestieTracker.trackedQuestsFrame:Update()
    end
end

function QuestieTracker:RemoveQuest(id)
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
    if QuestieTracker._disableHooks then return end
    if not isQuestie then
        local qid = select(8,GetQuestLogTitle(index))
        if qid then
            if "0" == GetCVar("autoQuestWatch") then
                Questie.db.char.TrackedQuests[qid] = nil
            else
                Questie.db.char.AutoUntrackedQuests[qid] = true
            end
            C_Timer.After(0.1, function()
                QuestieTracker:Update()
            end)
        end
    end
end

_AQW_Insert = function(index, expire)
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

        C_Timer.After(0.1, function()
            QuestieTracker:Update()
        end)
    end
end
