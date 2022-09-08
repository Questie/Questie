local WatchFrame = QuestWatchFrame or WatchFrame

---@class QuestieTracker
local QuestieTracker = QuestieLoader:CreateModule("QuestieTracker")
local _QuestieTracker = QuestieTracker.private
-------------------------
--Import modules.
-------------------------
---@type TrackerUtils
local TrackerUtils = QuestieLoader:ImportModule("TrackerUtils")
---@type TrackerMenu
local TrackerMenu = QuestieLoader:ImportModule("TrackerMenu")
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
---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule("ZoneDB")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")
---@type ActiveQuestsHeader
local ActiveQuestsHeader = QuestieLoader:ImportModule("ActiveQuestsHeader")
---@type LinePool
local LinePool = QuestieLoader:ImportModule("LinePool")
---@type FadeTicker
local FadeTicker = QuestieLoader:ImportModule("FadeTicker")

-- Local Vars
local trackerLineWidth = 1
local trackerLineIndent = 1
local trackerSpaceBuffer = 10
local trackerFontSizeHeader = 1
local trackerFontSizeZone = 1
local trackerFontSizeQuest = 1
local trackerFontSizeObjective = 1

local activeQuestHeaderMarginLeft = 10
local questHeaderMarginLeft = activeQuestHeaderMarginLeft + 15
local objectiveMarginLeft = activeQuestHeaderMarginLeft + questHeaderMarginLeft + 5

local buttonIndex = 0
local lastAQW = GetTime()
local durabilityInitialPosition
local LSM30 = LibStub("LibSharedMedia-3.0", true)

-- Private Global Vars
local itemButtons = {}
local isFirstRun = true

-- Forward declaration
local _OnTrackedQuestClick
local _RemoveQuestWatch
local _PlayerPosition, _QuestProximityTimer
local _GetDistanceToClosestObjective, _GetContinent

local function _UpdateLayout()
    trackerLineIndent = math.max(Questie.db.global.trackerFontSizeQuest, Questie.db.global.trackerFontSizeObjective)*2.75

    trackerFontSizeHeader = Questie.db.global.trackerFontSizeHeader
    trackerFontSizeZone = Questie.db.global.trackerFontSizeZone
    trackerFontSizeQuest = Questie.db.global.trackerFontSizeQuest
    trackerFontSizeObjective = Questie.db.global.trackerFontSizeObjective
end

function QuestieTracker.Initialize()
    if QuestieTracker.started or (not Questie.db.global.trackerEnabled) then
        return
    end
    if (not Questie.db.char.TrackerHiddenQuests) then
        Questie.db.char.TrackerHiddenQuests = {}
    end
    if (not Questie.db.char.TrackerHiddenObjectives) then
        Questie.db.char.TrackerHiddenObjectives = {}
    end
    if (not Questie.db.char.TrackedQuests) then
        Questie.db.char.TrackedQuests = {}
    end
    if (not Questie.db.char.AutoUntrackedQuests) then
        Questie.db.char.AutoUntrackedQuests = {}
    end
    if (not Questie.db.char.collapsedZones) then
        Questie.db.char.collapsedZones = {}
    end
    if (not Questie.db.char.collapsedQuests) then
        Questie.db.char.collapsedQuests = {}
    end
    if (not Questie.db[Questie.db.global.questieTLoc].TrackerWidth) then
        Questie.db[Questie.db.global.questieTLoc].TrackerWidth = 0
    end
    if (not Questie.db[Questie.db.global.questieTLoc].trackerSetpoint) then
        Questie.db[Questie.db.global.questieTLoc].trackerSetpoint = "AUTO"
    end

    _UpdateLayout()

    -- Create tracker frames and assign them to a var
    _QuestieTracker.baseFrame = _QuestieTracker:CreateBaseFrame()
    TrackerMenu.Initialize(function() _QuestieTracker.baseFrame:Update() end, QuestieTracker.Untrack)

    --_QuestieTracker.activeQuestsHeader = _QuestieTracker:CreateActiveQuestsHeader()
    _QuestieTracker.activeQuestsHeader = ActiveQuestsHeader.Initialize(_QuestieTracker.baseFrame, _OnTrackedQuestClick, _QuestieTracker.OnDragStart, _QuestieTracker.OnDragStop)
    _QuestieTracker.trackedQuestsFrame = _QuestieTracker:CreateTrackedQuestsFrame(_QuestieTracker.activeQuestsHeader)
    LinePool.Initialize(_QuestieTracker.trackedQuestsFrame, QuestieTracker.Untrack, QuestieTracker.Update, _QuestieTracker.OnDragStart, _QuestieTracker.OnDragStop)

    -- Quest and Item button tables
    _QuestieTracker:CreateTrackedQuestItemButtons()
    QuestieTracker.started = true
    FadeTicker.Initialize(_QuestieTracker.baseFrame)

    if Questie.db.global.hookTracking then
        QuestieTracker:HookBaseTracker()
    end

    -- Atach durability frame to the tracker if shown and Sticky Durability Frame is enabled
    if not durabilityInitialPosition then
        durabilityInitialPosition = {DurabilityFrame:GetPoint()}
    end

    C_Timer.After(0.2, function()
        DurabilityFrame:Hide()
    end)

    -- Santity checks and settings applied at login
    C_Timer.After(0.4, function()
        -- Make sure the saved tracker location cords are on the players screen
        if Questie.db[Questie.db.global.questieTLoc].TrackerLocation and Questie.db[Questie.db.global.questieTLoc].TrackerLocation[2] and (Questie.db[Questie.db.global.questieTLoc].TrackerLocation[2] == "MinimapCluster" or Questie.db[Questie.db.global.questieTLoc].TrackerLocation[2] == "UIParent") then
            local baseFrame = QuestieTracker:GetBaseFrame()
            local verifyBaseFrame = {unpack(Questie.db[Questie.db.global.questieTLoc].TrackerLocation)}

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

    C_Timer.After(4.0, function()
        if Questie.db.global.stickyDurabilityFrame then
            -- This is the best way to not check 19238192398 events which might reset the position of the DurabilityFrame
            hooksecurefunc("UIParent_ManageFramePositions", QuestieTracker.MoveDurabilityFrame)

            -- Attach DurabilityFrame to tracker
            QuestieTracker:CheckDurabilityAlertStatus()
            QuestieTracker:MoveDurabilityFrame()
        end

        -- Prevents addons like Dugi Guides from turning off Automatic Quest Tracking and automatically un-tracking quests from the tracker
        if Questie.db.global.autoTrackQuests then
            if IsAddOnLoaded("DugisGuideViewerZ") then
                SetCVar("autoQuestWatch", "1")
                DugisGuideViewer:SetDB(false, 39)
            end
        end

        if Questie.db.char.TrackerFocus then
            local focusType = type(Questie.db.char.TrackerFocus)
            if focusType == "number" then
                TrackerUtils:FocusQuest(Questie.db.char.TrackerFocus)
                QuestieQuest:ToggleNotes(false)
            elseif focusType == "string" then
                local questId, objectiveIndex = string.match(Questie.db.char.TrackerFocus, "(%d+) (%d+)")
                TrackerUtils:FocusObjective(questId, objectiveIndex)
                QuestieQuest:ToggleNotes(false)
            end
        end

        if Questie.db.global.hideTrackerInDungeons and IsInInstance() then
            QuestieTracker:Collapse()
        end

        -- Font's and cooldowns can occationally not apply upon login
        QuestieTracker:Update()
    end)
end

function _QuestieTracker:CreateBaseFrame()
    local frm = CreateFrame("Frame", "Questie_BaseFrame", UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
    frm:SetFrameStrata("BACKGROUND")
    frm:SetFrameLevel(0)
    frm:SetSize(280, 32)

    frm:EnableMouse(true)
    frm:SetMovable(true)
    frm:SetResizable(true)
    frm:SetMinResize(1, 1)

    frm:SetScript("OnMouseDown", _QuestieTracker.OnDragStart)
    frm:SetScript("OnMouseUp", _QuestieTracker.OnDragStop)
    frm:SetScript("OnEnter", FadeTicker.OnEnter)
    frm:SetScript("OnLeave", FadeTicker.OnLeave)

    frm:SetBackdrop( {
        bgFile="Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile=true, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })

    frm:SetBackdropColor(0, 0, 0, 0)
    frm:SetBackdropBorderColor(1, 1, 1, 0)

    frm.Update = function(self)
        if Questie.db.char.isTrackerExpanded and GetNumQuestLogEntries() > 0 then
            if Questie.db.global.trackerBackdropEnabled then
                if not Questie.db.global.trackerBackdropFader then
                    _QuestieTracker.baseFrame:SetBackdropColor(0, 0, 0, Questie.db.global.trackerBackdropAlpha)
                    if Questie.db.global.trackerBorderEnabled then
                        _QuestieTracker.baseFrame:SetBackdropBorderColor(1, 1, 1, Questie.db.global.trackerBackdropAlpha)
                    end
                end

            else
                _QuestieTracker.baseFrame:SetBackdropColor(0, 0, 0, 0)
                _QuestieTracker.baseFrame:SetBackdropBorderColor(1, 1, 1, 0)
            end

        else
            _QuestieTracker.baseFrame.sizer:SetAlpha(0)
            _QuestieTracker.baseFrame:SetBackdropColor(0, 0, 0, 0)
            _QuestieTracker.baseFrame:SetBackdropBorderColor(1, 1, 1, 0)
        end

        -- Enables Click-Through when the tracker is locked
        if IsControlKeyDown() or (not Questie.db.global.trackerLocked) then
            self:SetMovable(true)
            QuestieCombatQueue:Queue(function(tracker)
                if IsMouseButtonDown() then
                    return
                end
                tracker:EnableMouse(true)
                tracker:SetResizable(true)
            end, self)

        else
            self:SetMovable(false)
            QuestieCombatQueue:Queue(function(tracker)
                if IsMouseButtonDown() then
                    return
                end
                tracker:EnableMouse(false)
                tracker:SetResizable(false)
            end, self)
        end
    end

    local sizer = CreateFrame("Frame", "Questie_Sizer", frm)
    sizer:SetPoint("BOTTOMRIGHT", 0, 0)
    sizer:SetWidth(25)
    sizer:SetHeight(25)
    sizer:SetAlpha(0)
    sizer:EnableMouse()
    sizer:SetScript("OnMouseDown", _QuestieTracker.OnResizeStart)
    sizer:SetScript("OnMouseUp", _QuestieTracker.OnResizeStop)
    sizer:SetScript("OnEnter", FadeTicker.OnEnter)
    sizer:SetScript("OnLeave", FadeTicker.OnLeave)

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
    x = 0.1 * 11/17
    line2:SetTexCoord(1/32 - x, 0.5, 1/32, 0.5 + x, 1/32, 0.5 - x, 1/32 + x, 0.5)

    local line3 = sizer:CreateTexture(nil, "BACKGROUND")
    line3:SetWidth(8)
    line3:SetHeight(8)
    line3:SetPoint("BOTTOMRIGHT", -4, 4)
    line3:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
    x = 0.1 * 8/17
    line3:SetTexCoord(1/32 - x, 0.5, 1/32, 0.5 + x, 1/32, 0.5 - x, 1/32 + x, 0.5)

    if Questie.db[Questie.db.global.questieTLoc].TrackerLocation then
        -- we need to pcall this because it can error if something like MoveAnything is used to move the tracker
        local result, reason = pcall(frm.SetPoint, frm, unpack(Questie.db[Questie.db.global.questieTLoc].TrackerLocation))

        if (not result) then
            Questie.db[Questie.db.global.questieTLoc].TrackerLocation = nil
            print(l10n("Error: Questie tracker in invalid location, resetting..."))
            Questie:Debug(Questie.DEBUG_CRITICAL, "Resetting reason:", reason)

            if WatchFrame then
                local result2, _ = pcall(frm.SetPoint, frm, unpack({WatchFrame:GetPoint()}))
                Questie.db[Questie.db.global.questieTLoc].trackerSetpoint = "AUTO"
                if (not result2) then
                    Questie.db[Questie.db.global.questieTLoc].TrackerLocation = nil
                    _QuestieTracker:SetSafePoint(frm)
                end
            else
                _QuestieTracker:SetSafePoint(frm)
            end
        end
    else
        if WatchFrame then
            local result, _ = pcall(frm.SetPoint, frm, unpack({WatchFrame:GetPoint()}))
            Questie.db[Questie.db.global.questieTLoc].trackerSetpoint = "AUTO"

            if not result then
                Questie.db[Questie.db.global.questieTLoc].TrackerLocation = nil
                print(l10n("Error: Questie tracker in invalid location, resetting..."))
                _QuestieTracker:SetSafePoint(frm)
            end
        else
            _QuestieTracker:SetSafePoint(frm)
        end
    end

    frm:Hide()

    return frm
end

local function _PositionTrackedQuestsFrame(frm, activeQuestHeader)
    if Questie.db.global.trackerHeaderEnabled then
        if Questie.db.global.trackerHeaderAutoMove then
            if Questie.db[Questie.db.global.questieTLoc].TrackerLocation and (Questie.db[Questie.db.global.questieTLoc].TrackerLocation[1] == "BOTTOMLEFT" or Questie.db[Questie.db.global.questieTLoc].TrackerLocation[1] == "BOTTOMRIGHT") then
                -- Auto move tracker header to the bottom
                frm:SetPoint("TOPLEFT", activeQuestHeader, "TOPLEFT", 0, -10)
            else
                -- Auto move tracker header to the top
                frm:SetPoint("TOPLEFT", activeQuestHeader, "TOPLEFT", 0, -(trackerFontSizeHeader+3))
            end
        else
            -- No Automove. Tracker header always up top
            frm:SetPoint("TOPLEFT", activeQuestHeader, "TOPLEFT", 0, -(trackerFontSizeHeader+5))
        end
    else
        -- No header. TrackedQuestsFrame always up top
        frm:SetPoint("TOPLEFT", activeQuestHeader, "TOPLEFT", 0, -10)
    end
end

function _QuestieTracker:CreateTrackedQuestsFrame(previousFrame)
    local frm = CreateFrame("Frame", "Questie_TrackedQuests", _QuestieTracker.baseFrame)
    frm:SetWidth(165)
    frm:SetHeight(32)

    _PositionTrackedQuestsFrame(frm, previousFrame)

    frm.Update = function(self)
        self:ClearAllPoints()
        _PositionTrackedQuestsFrame(self, previousFrame)
    end

    frm:EnableMouse(true)
    frm:RegisterForDrag("LeftButton")

    frm:SetScript("OnDragStart", _QuestieTracker.OnDragStart)
    frm:SetScript("OnDragStop", _QuestieTracker.OnDragStop)
    frm:SetScript("OnEnter", FadeTicker.OnEnter)
    frm:SetScript("OnLeave", FadeTicker.OnLeave)

    frm:Hide()

    return frm
end

function _QuestieTracker:CreateTrackedQuestItemButtons()
    -- create buttons for quest items
    for i = 1, C_QuestLog.GetMaxNumQuestsCanAccept() do
        local buttonName = "Questie_ItemButton"..i
        local btn = CreateFrame("Button", buttonName, UIParent, "SecureActionButtonTemplate, ActionButtonTemplate")
        local cooldown = CreateFrame("Cooldown", nil, btn, "CooldownFrameTemplate")
        btn.range = btn:CreateFontString(nil, "OVERLAY", "NumberFontNormalSmallGray")
        btn.count = btn:CreateFontString(nil, "ARTWORK", "Game10Font_o1")
        btn:SetAttribute("type1", "item")
        btn:SetAttribute("type2", "stop")
        btn:Hide()

        if Questie.db.global.trackerFadeQuestItemButtons then
            btn:SetAlpha(0)
        end

        btn.SetItem = function(self, quest, size)
            local validTexture
            local isFound = false

            for bag = 0 , 4 do
                for slot = 1, GetContainerNumSlots(bag) do
                    local texture, _, _, _, _, _, _, _, _, itemID = GetContainerItemInfo(bag, slot)
                    if quest.sourceItemId == itemID then
                        validTexture = texture
                        isFound = true
                        break
                    end
                end
            end

            -- Edge case to find "equipped" quest items since they will no longer be in the players bag
            if (not isFound) then
                for inventorySlot = 1, 19 do
                    local itemID = GetInventoryItemID("player", inventorySlot)
                    if quest.sourceItemId == itemID then
                        validTexture = GetInventoryItemTexture("player", inventorySlot)
                        isFound = true
                        break
                    end
                end
            end

            if validTexture and isFound then
                self.itemID = quest.sourceItemId
                self.questID = quest.Id
                self.charges = GetItemCount(self.itemID, nil, true)
                self.rangeTimer = -1

                self:SetAttribute("item", "item:" .. tostring(self.itemID))
                self:SetNormalTexture(validTexture)
                self:SetPushedTexture(validTexture)
                self:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
                self:SetSize(size, size)

                self:RegisterForClicks("LeftButtonUp", "RightButtonUp")

                self:SetScript("OnEvent", self.OnEvent)
                self:SetScript("OnShow", self.OnShow)
                self:SetScript("OnHide", self.OnHide)
                self:SetScript("OnEnter", self.OnEnter)
                self:SetScript("OnLeave", self.OnLeave)

                -- Cooldown Updates
                cooldown:SetSize(size-4, size-4)
                cooldown:SetPoint("CENTER", self, "CENTER", 0, 0)
                cooldown:Hide()

                -- Range Updates
                self.range:SetText("●")
                self.range:SetPoint("TOPRIGHT", self, "TOPRIGHT", 3, 0)
                self.range:Hide()

                -- Charges Updates
                self.count:Hide()
                self.count:SetFont(LSM30:Fetch("font", Questie.db.global.trackerFontSizeObjective), trackerSpaceBuffer*0.40)
                if self.charges > 1 then
                    self.count:SetText(self.charges)
                    self.count:Show()
                end
                self.count:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -2, 3)

                self.UpdateButton(self)

                return true
            end

            return false
        end

        btn.UpdateButton = function(self)
            if not self.itemID or not self:IsVisible() then
                return
            end

            local start, duration, enabled = GetItemCooldown(self.itemID)

            if enabled and duration > 3 and enabled == 1 then
                cooldown:Show()
                cooldown:SetCooldown(start, duration)
            else
                cooldown:Hide()
            end
        end

        btn.OnEvent = function(self, event, ...)
            if (event == "PLAYER_TARGET_CHANGED") then
                self.rangeTimer = -1
                self.range:Hide()

            elseif (event == "BAG_UPDATE_COOLDOWN") then
                self.UpdateButton(self)
            end
        end

        btn.OnUpdate = function(self, elapsed)
            if not self.itemID or not self:IsVisible() then
                return
            end

            local valid
            local rangeTimer = self.rangeTimer
            local charges = GetItemCount(self.itemID, nil, true)

            if (not charges or charges ~= self.charges) then
                self.count:Hide()
                self.charges = GetItemCount(self.itemID, nil, true)
                if self.charges > 1 then
                    self.count:SetText(self.charges)
                    self.count:Show()
                end
            end

            if UnitExists("target") then

                if not self.itemName then
                    self.itemName = GetItemInfo(self.itemID)
                end

                if (rangeTimer) then
                    rangeTimer = rangeTimer - elapsed

                    if (rangeTimer <= 0) then

                        valid = IsItemInRange(self.itemName, "target")

                        if valid == false then
                            self.range:SetVertexColor(1.0, 0.1, 0.1)
                            self.range:Show()

                        elseif valid == true then
                            self.range:SetVertexColor(0.6, 0.6, 0.6)
                            self.range:Show()
                        end

                        rangeTimer = 0.3
                    end

                    self.rangeTimer = rangeTimer
                end
            end
        end

        btn.OnShow = function(self)
            self:RegisterEvent("PLAYER_TARGET_CHANGED")
            self:RegisterEvent("BAG_UPDATE_COOLDOWN")
        end

        btn.OnHide = function(self)
            self:UnregisterEvent("PLAYER_TARGET_CHANGED")
            self:UnregisterEvent("BAG_UPDATE_COOLDOWN")
        end

        btn.OnEnter = function(self)
            GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
            GameTooltip:SetHyperlink("item:"..tostring(self.itemID)..":0:0:0:0:0:0:0")
            GameTooltip:Show()

            FadeTicker.OnEnter(self)
        end

        btn.OnLeave = function(self)
            GameTooltip:Hide()

            FadeTicker.OnLeave(self)
        end

        btn.FakeHide = function(self)
            self:RegisterForClicks(nil)
            self:SetScript("OnEnter", nil)
            self:SetScript("OnLeave", nil)

            self:SetNormalTexture(nil)
            self:SetPushedTexture(nil)
            self:SetHighlightTexture(nil)
        end

        btn:HookScript("OnUpdate", btn.OnUpdate)

        btn:FakeHide()

        itemButtons[i] = btn
        itemButtons[i]:Hide()
    end
end

function QuestieTracker:GetBaseFrame()
    return _QuestieTracker.baseFrame
end

function QuestieTracker:ResetLocation()
    _QuestieTracker.activeQuestsHeader.trackedQuests:SetMode(1) -- maximized
    Questie.db.char.isTrackerExpanded = true
    Questie.db.char.AutoUntrackedQuests = {}
    Questie.db[Questie.db.global.questieTLoc].TrackerLocation = nil
    Questie.db.char.collapsedQuests = {}
    Questie.db.char.collapsedZones = {}
    Questie.db[Questie.db.global.questieTLoc].TrackerWidth = 0

    _QuestieTracker.baseFrame:SetSize(280, 32)
    _QuestieTracker:SetSafePoint(_QuestieTracker.baseFrame)

    QuestieTracker:Update()
end

function QuestieTracker:ResetDurabilityFrame()
    DurabilityFrame:ClearAllPoints()
    DurabilityFrame:SetPoint(unpack(durabilityInitialPosition))
end

function QuestieTracker:MoveDurabilityFrame()
    if Questie.db.global.trackerEnabled and Questie.db.global.stickyDurabilityFrame and DurabilityFrame:IsShown() and QuestieTracker.started and Questie.db[Questie.db.global.questieTLoc].TrackerLocation ~= nil then
        if Questie.db[Questie.db.global.questieTLoc].TrackerLocation and Questie.db[Questie.db.global.questieTLoc].TrackerLocation[1] == "TOPLEFT" or Questie.db[Questie.db.global.questieTLoc].TrackerLocation[1] == "BOTTOMLEFT" then
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

function QuestieTracker:CheckDurabilityAlertStatus()
    local numAlerts = 0
    for i = 1, #INVENTORY_ALERT_STATUS_SLOTS do
        if GetInventoryAlertStatus(i) > 0 then
            numAlerts = numAlerts + 1
        end
    end
    if numAlerts > 0 then
        DurabilityFrame:Show()
    end
end

function _QuestieTracker:SetSafePoint(frm)
    frm:ClearAllPoints()
    local xOff, yOff = frm:GetWidth()/2, frm:GetHeight()/2
    local resetCords = {["BOTTOMLEFT"] = {x = -xOff, y = -yOff}, ["BOTTOMRIGHT"] = {x = xOff, y = -yOff}, ["TOPLEFT"] = {x = -xOff, y =  yOff}, ["TOPRIGHT"] = {x = xOff, y =  yOff}}

    if Questie.db[Questie.db.global.questieTLoc].trackerSetpoint == "AUTO" then
        frm:SetPoint("TOPLEFT", UIParent, "CENTER", resetCords["TOPLEFT"].x, resetCords["TOPLEFT"].y)
    else
        frm:SetPoint(Questie.db[Questie.db.global.questieTLoc].trackerSetpoint, UIParent, "CENTER", resetCords[Questie.db[Questie.db.global.questieTLoc].trackerSetpoint].x, resetCords[Questie.db[Questie.db.global.questieTLoc].trackerSetpoint].y)
    end
end

function QuestieTracker:Enable()
    Questie.db.global.trackerEnabled = true

    -- may not have been initialized yet
    if Questie.db.global.hookTracking then
        QuestieTracker:HookBaseTracker()
    end

    QuestieQuestTimers:HideBlizzardTimer()
    QuestieTracker.Initialize()
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

function QuestieTracker:Toggle()
    if Questie.db.global.trackerEnabled then
        QuestieTracker:Disable()
    else
        QuestieTracker:Enable()
    end
end

function QuestieTracker:Collapse()
    if _QuestieTracker.activeQuestsHeader and _QuestieTracker.activeQuestsHeader.trackedQuests and Questie.db.char.isTrackerExpanded then
        _QuestieTracker.activeQuestsHeader.trackedQuests:Click()
    end
end

function QuestieTracker:Expand()
    if _QuestieTracker.activeQuestsHeader and _QuestieTracker.activeQuestsHeader.trackedQuests and (not Questie.db.char.isTrackerExpanded) then
        _QuestieTracker.activeQuestsHeader.trackedQuests:Click()
    end
end

local function _GetNextItemButton()
    buttonIndex = buttonIndex + 1
    return itemButtons[buttonIndex]
end

---@param quest Quest
local function _UpdateQuestItem(self, quest)
    if self:SetItem(quest, trackerFontSizeQuest+2+trackerFontSizeObjective) then
        local height = 0
        local frame = self.line

        while frame and frame ~= _QuestieTracker.trackedQuestsFrame do
            local _, parent, _, _, yOff = frame:GetPoint()
            height = height - (frame:GetHeight() - yOff)
            frame = parent
        end

        self.line.expandQuest:Hide()

        self:SetPoint("TOPLEFT", self.line, "TOPLEFT", 0, 0)
        self:SetParent(self.line)
        self:Show()

        if Questie.db.char.collapsedZones[quest.zoneOrSort] or Questie.db.char.collapsedQuests[quest.Id] then
            self:SetParent(UIParent)
            self:Hide()
        end
    else
        self.line.expandQuest:Show()
        self:SetParent(UIParent)
        self:Hide()
    end
end


local function _ReportErrorMessage(zoneOrtSort)
    Questie:Error("SortID: |cffffbf00"..zoneOrtSort.."|r was not found in the Database. Please file a bugreport at:")
    Questie:Error("|cff00bfffhttps://github.com/Questie/Questie/issues|r")
end

local questCompletePercent = {}

local function _GetSortedQuestIds()
    local sortedQuestIds = {}

    -- Update quest objectives
    for questId in pairs (QuestiePlayer.currentQuestlog) do
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
                _ReportErrorMessage(qAZone)
            end

            if qB.zoneOrSort > 0 then
                qBZone = TrackerUtils:GetZoneNameByID(qB.zoneOrSort)
            elseif qB.zoneOrSort < 0 then
                qBZone = TrackerUtils:GetCategoryNameByID(qB.zoneOrSort)
            else
                qBZone = tostring(qB.zoneOrSort)
                _ReportErrorMessage(qBZone)
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
        QuestieTracker._sorter = function(a, b)
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
        table.sort(sortedQuestIds, QuestieTracker._sorter)

        if not _QuestProximityTimer then
            QuestieTracker:UpdateQuestProximityTimer()
        end
    end

    return sortedQuestIds
end

function QuestieTracker:Update()
    Questie:Debug(Questie.DEBUG_DEVELOP, "QuestieTracker: Update")
    if (not QuestieTracker.started) then
        return
    end

    -- Tracker has started but not enabled
    if (not Questie.db.global.trackerEnabled) then
        if _QuestieTracker.baseFrame and _QuestieTracker.baseFrame:IsShown() then
            QuestieCombatQueue:Queue(function()
                _QuestieTracker.baseFrame:Hide()
            end)
        end
        return
    end

    LinePool.ResetLinesForChange()

    -- Update primary frames and layout
    QuestieCombatQueue:Queue(function()
        _QuestieTracker.baseFrame:Update()
        _QuestieTracker.activeQuestsHeader:Update()
        _QuestieTracker.trackedQuestsFrame:Update()
    end)

    _UpdateLayout()
    buttonIndex = 0

    if not Questie.db.char.isTrackerExpanded then
        -- The Tracker is not expanded. No use to calculate anything - just hide everything
        local xOff, yOff = _QuestieTracker.baseFrame:GetLeft(), _QuestieTracker.baseFrame:GetTop()

        _QuestieTracker.baseFrame:ClearAllPoints()
        -- Offsets start from BOTTOMLEFT. So TOPLEFT is +, - for offsets. Thanks Blizzard >_>
        _QuestieTracker.baseFrame:SetPoint("TOPLEFT", UIParent, xOff, -(GetScreenHeight() - yOff))

        _QuestieTracker.baseFrame:SetHeight(trackerSpaceBuffer)
        _QuestieTracker.trackedQuestsFrame:Hide()

        LinePool.HideUnusedLines()
        return
    end

    local order = _GetSortedQuestIds()
    QuestieTracker._order = order

    if (Questie.db.global.trackerSortObjectives ~= "byProximity") and _QuestProximityTimer and (_QuestProximityTimer:IsCancelled() ~= "true") then
        _QuestProximityTimer:Cancel()
        _QuestProximityTimer = nil
    end

    local firstQuestInZone = false
    local zoneCheck

    local line
    -- Begin populating the tracker with quests
    for _, questId in pairs(order) do
        local quest = QuestieDB:GetQuest(questId)
        local complete = quest:IsComplete()
        local zoneName

        -- Valid ZoneID
        if (quest.zoneOrSort) > 0 then
            zoneName = TrackerUtils:GetZoneNameByID(quest.zoneOrSort)

        -- Valid CategoryID
        elseif (quest.zoneOrSort) < 0 then
            zoneName = TrackerUtils:GetCategoryNameByID(quest.zoneOrSort)

        -- Probobly not in the Database. Assign zoneOrSort ID so Questie doesn't error
        else
            zoneName = tostring(quest.zoneOrSort)
            _ReportErrorMessage(zoneName)
        end

        -- Look for any updated objectives since last update
        if quest then
            for _,Objective in pairs(quest.Objectives) do
                if Objective.Update then
                    Objective:Update()
                end
            end
        end

        -- Check for valid timed quests
        quest.timedBlizzardQuest = nil
        quest.trackTimedQuest = false
        local remainingSeconds = QuestieQuestTimers:GetRemainingTime(questId, nil, true)

        if remainingSeconds then
            if Questie.db.global.showBlizzardQuestTimer then
                QuestieQuestTimers:ShowBlizzardTimer()
                quest.timedBlizzardQuest = true
            else
                QuestieQuestTimers:HideBlizzardTimer()
                quest.timedBlizzardQuest = false
                quest.trackTimedQuest = true
            end
        end

        if ((complete ~= 1 or Questie.db.global.trackerShowCompleteQuests) and not quest.timedBlizzardQuest) and ((GetCVar("autoQuestWatch") == "1" and not Questie.db.char.AutoUntrackedQuests[questId]) or (GetCVar("autoQuestWatch") == "0" and Questie.db.char.TrackedQuests[questId])) then

            -- Add zones
            if Questie.db.global.trackerSortObjectives == "byZone" then
                if zoneCheck ~= zoneName then
                    firstQuestInZone = true
                end

                if firstQuestInZone then
                    line = LinePool.GetNextLine()
                    if not line then break end -- stop populating the tracker
                    
                    line:SetMode("zone")
                    line:SetZone(quest.zoneOrSort)
                    line.expandQuest:Hide()
                    line.expandZone:Show()

                    line.label:ClearAllPoints()
                    line.label:SetPoint("TOPLEFT", line, "TOPLEFT", 0, 0)

                    if Questie.db.char.collapsedZones[quest.zoneOrSort] then
                        line.expandZone:SetMode(0)
                        line.label:SetText("|cFFC0C0C0" .. zoneName .. " +|r")
                    else
                        line.expandZone:SetMode(1)
                        line.label:SetText("|cFFC0C0C0" .. zoneName .. "|r")
                    end

                    line.label:SetWidth(_QuestieTracker.baseFrame:GetWidth() - trackerSpaceBuffer)
                    line:SetWidth(trackerSpaceBuffer + _QuestieTracker.activeQuestsHeader.trackedQuests.label:GetUnboundedStringWidth() + trackerSpaceBuffer)

                    line.expandZone:ClearAllPoints()
                    line.expandZone:SetWidth(line.label:GetWidth())
                    line.expandZone:SetHeight(trackerFontSizeZone)
                    line.expandZone:SetPoint("TOPLEFT", line.label, "TOPLEFT", 0, 0)

                    line:SetVerticalPadding(4)
                    line:Show()
                    line.label:Show()

                    line.Quest = nil
                    line.Objective = nil

                    firstQuestInZone = false
                    zoneCheck = zoneName
                end
            end

            if (not Questie.db.char.collapsedZones[quest.zoneOrSort]) then

                -- Add quests
                line = LinePool.GetNextLine()
                if not line then break end -- stop populating the tracker

                line:SetMode("quest")
                line:SetQuest(quest)
                line:SetObjective(nil)
                line.expandZone:Hide()

                line.label:ClearAllPoints()
                line.label:SetPoint("TOPLEFT", line, "TOPLEFT", questHeaderMarginLeft, 0)
                line.expandQuest:SetPoint("RIGHT", line, "LEFT", questHeaderMarginLeft - 8, 0)

                local coloredQuestName = QuestieLib:GetColoredQuestName(quest.Id, Questie.db.global.trackerShowQuestLevel, Questie.db.global.collapseCompletedQuests, false)
                line.label:SetText(coloredQuestName)

                line.label:SetWidth(_QuestieTracker.baseFrame:GetWidth() - questHeaderMarginLeft - 10 - trackerSpaceBuffer)
                line:SetWidth(line.label:GetWidth())

                if Questie.db.global.collapseCompletedQuests and (complete == 1 or complete == -1) then
                    if not Questie.db.char.collapsedQuests[quest.Id] then
                        Questie.db.char.collapsedQuests[quest.Id] = true
                        line.expandQuest:SetMode(1)
                    end
                else
                    if Questie.db.char.collapsedQuests[quest.Id] then
                        line.expandQuest:SetMode(0)
                    else
                        line.expandQuest:SetMode(1)
                    end
                end

                trackerLineWidth = math.max(trackerLineWidth, line.label:GetWidth())

                line:SetVerticalPadding(2)

                -- Add quest items
                if quest.sourceItemId and questCompletePercent[quest.Id] ~= 1 then
                    local fontSizeCompare = trackerFontSizeQuest + trackerFontSizeObjective + Questie.db.global.trackerQuestPadding -- hack to allow refreshing when changing font size
                    local button = _GetNextItemButton()
                    button.itemID = quest.sourceItemId
                    button.fontSize = fontSizeCompare
                    button.line = line
                    QuestieCombatQueue:Queue(_UpdateQuestItem, button, quest)
                    line.button = button
                elseif Questie.db.global.collapseCompletedQuests and complete == 1 then
                    line.expandQuest:Hide()
                else
                    line.expandQuest:Show()
                end

                line:Show()
                line.label:Show()

                -- Add quest objectives (if applicable)
                if (not Questie.db.char.collapsedQuests[quest.Id]) then

                    -- Add quest timers (if applicable)
                    if quest.trackTimedQuest then
                        line = LinePool.GetNextLine()
                        if not line then break end -- stop populating the tracker

                        line:SetMode("objective")
                        line:SetQuest(quest)
                        line.expandZone:Hide()
                        line.expandQuest:Hide()

                        line.label:ClearAllPoints()
                        line.label:SetPoint("TOPLEFT", line, "TOPLEFT", trackerSpaceBuffer/1.50, 0)

                        line.label:SetText(QuestieQuestTimers:GetRemainingTime(questId, line, false))

                        line.label:SetFont(LSM30:Fetch("font", Questie.db.global.trackerFontSizeObjective), Questie.db.global.trackerFontSizeObjective * 1.3)
                        line.label:SetHeight(Questie.db.global.trackerFontSizeObjective * 1.3)

                        local lineWidth = _QuestieTracker.baseFrame:GetWidth() - objectiveMarginLeft - trackerSpaceBuffer
                        line.label:SetWidth(lineWidth)
                        line:SetWidth(lineWidth)

                        trackerLineWidth = math.max(trackerLineWidth, line.label:GetWidth())
                        line:Show()
                        line.label:Show()
                    end

                    if complete == 0 then
                        for _, objective in pairs(quest.Objectives) do
                            line = LinePool.GetNextLine()
                            if not line then break end -- stop populating the tracker
                            line:SetMode("objective")
                            line:SetQuest(quest)
                            line:SetObjective(objective)
                            line.expandZone:Hide()
                            line.expandQuest:Hide()

                            line.label:ClearAllPoints()
                            line.label:SetPoint("TOPLEFT", line, "TOPLEFT", objectiveMarginLeft, 0)

                            local lineEnding = ""
                            local objDesc = objective.Description:gsub("%.", "")
                            if objective.Needed > 0 then lineEnding = tostring(objective.Collected) .. "/" .. tostring(objective.Needed) end
                            line.label:SetText(QuestieLib:GetRGBForObjective(objective) .. objDesc .. ": " .. lineEnding)

                            local lineWidth = _QuestieTracker.baseFrame:GetWidth() - objectiveMarginLeft - 10 - trackerSpaceBuffer
                            line.label:SetWidth(lineWidth)
                            line:SetWidth(lineWidth)

                            trackerLineWidth = math.max(trackerLineWidth, line.label:GetWidth())
                            line:SetVerticalPadding(1)
                            line:Show()
                            line.label:Show()
                        end

                    -- Tags quest as either complete or failed so as to always have at least one objective.
                    -- (TODO: change tags to reflect NPC to turn a quest into or in the case of a failure
                    -- which NPC to obtain the quest from again...)
                    elseif (complete == 1 or complete == -1) then
                        line = LinePool.GetNextLine()
                        if not line then break end -- stop populating the tracker

                        line:SetMode("objective")
                        line:SetQuest(quest)
                        line.expandZone:Hide()
                        line.expandQuest:Hide()

                        line.label:ClearAllPoints()
                        line.label:SetPoint("TOPLEFT", line, "TOPLEFT", objectiveMarginLeft, 0)

                        if (complete == 1) then
                            line.label:SetText(Questie:Colorize(l10n("Quest completed!"), "green"))
                        elseif (complete == -1) then
                            line.label:SetText(Questie:Colorize(l10n("Quest completion failed!"), "red"))
                        end

                        line.label:SetWidth(_QuestieTracker.baseFrame:GetWidth() - objectiveMarginLeft - 10 - trackerSpaceBuffer)
                        line:SetWidth(line.label:GetWidth())

                        trackerLineWidth = math.max(trackerLineWidth, line.label:GetWidth())
                        line:SetVerticalPadding(1)
                        line:Show()
                        line.label:Show()
                    end
                else
                    QuestieQuestTimers:GetRemainingTime(questId, nil, true)
                end

                if not line then
                    line = LinePool.GetLastLine()
                end

                line:SetVerticalPadding(Questie.db.global.trackerQuestPadding)
            end
        end
    end

    if not line then
        line = LinePool.GetLastLine()
    end

    -- Begin post clean up of unused frameIndexes
    local startUnusedButtons = 1

    if Questie.db.char.isTrackerExpanded then
        startUnusedButtons = buttonIndex + 1
    end

    LinePool.HideUnusedLines()

    -- Hide unused item buttons
    QuestieCombatQueue:Queue(function()
        for i = startUnusedButtons, C_QuestLog.GetMaxNumQuestsCanAccept() do
            local button = itemButtons[i]
            if button.itemID then
                button:FakeHide()
                button.itemID = nil
                button.itemName = nil
                button.lineID = nil
                button.fontSize = nil
                button:SetParent(UIParent)
                button:Hide()
            end
        end
    end)

    -- Auto adjust tracker size and visibility
    local activeQuestsHeaderTotal = trackerSpaceBuffer + _QuestieTracker.activeQuestsHeader.trackedQuests.label:GetUnboundedStringWidth() + trackerFontSizeHeader
    local trackerVARScombined = trackerLineWidth + trackerSpaceBuffer + trackerLineIndent
    local trackerBaseFrame = _QuestieTracker.baseFrame:GetWidth()

    if line then
        if Questie.db[Questie.db.global.questieTLoc].TrackerWidth > 0 then
            if (Questie.db[Questie.db.global.questieTLoc].TrackerWidth < activeQuestsHeaderTotal and _QuestieTracker.isSizing ~= true) then
                _QuestieTracker.baseFrame:SetWidth(activeQuestsHeaderTotal)
                Questie.db[Questie.db.global.questieTLoc].TrackerWidth = activeQuestsHeaderTotal
            elseif (Questie.db[Questie.db.global.questieTLoc].TrackerWidth ~= trackerBaseFrame and _QuestieTracker.isSizing ~= true) then
                _QuestieTracker.baseFrame:SetWidth(Questie.db[Questie.db.global.questieTLoc].TrackerWidth)
            end
        else

            if (trackerVARScombined < activeQuestsHeaderTotal) then
                _QuestieTracker.baseFrame:SetWidth(activeQuestsHeaderTotal)
            elseif (trackerVARScombined ~= trackerBaseFrame) then
                _QuestieTracker.baseFrame:SetWidth(trackerVARScombined)
            end
        end

        -- Trims the bottom of the tracker (overall height) based on min/max'd zones and/or quests
        local trackerBottomPadding
        if Questie.db.global.trackerHeaderEnabled and Questie.db.global.trackerHeaderAutoMove and Questie.db[Questie.db.global.questieTLoc].TrackerLocation and (Questie.db[Questie.db.global.questieTLoc].TrackerLocation[1] == "BOTTOMLEFT" or Questie.db[Questie.db.global.questieTLoc].TrackerLocation[1] == "BOTTOMRIGHT") then
            trackerBottomPadding = trackerFontSizeHeader+4
        else
            trackerBottomPadding = 0
        end

        if line:IsVisible() or LinePool.IsFirstLine() then
            if LinePool.IsFirstLine() then
                _QuestieTracker.baseFrame:SetHeight( (_QuestieTracker.baseFrame:GetTop() - line:GetBottom()) - (Questie.db.global.trackerQuestPadding+2) + trackerBottomPadding )
            else
                _QuestieTracker.baseFrame:SetHeight( (_QuestieTracker.baseFrame:GetTop() - line:GetBottom() + 14) - (Questie.db.global.trackerQuestPadding+2) + trackerBottomPadding )
            end
        else
            line = LinePool.GetPreviousLine()
            
            if not line then
                line = LinePool.GetLastLine()
            end
            
            _QuestieTracker.baseFrame:SetHeight( (_QuestieTracker.baseFrame:GetTop() - line:GetBottom() + 25) + trackerBottomPadding )
            
        end

        _QuestieTracker.baseFrame:SetMaxResize(GetScreenWidth()/2, GetScreenHeight())
        _QuestieTracker.baseFrame:SetMinResize(activeQuestsHeaderTotal, _QuestieTracker.baseFrame:GetHeight())
        _QuestieTracker.trackedQuestsFrame:Show()
    end

    -- First run clean up
    if isFirstRun then
        for questId in pairs (QuestiePlayer.currentQuestlog) do
            local quest = QuestieDB:GetQuest(questId)
            if quest then
                if Questie.db.char.TrackerHiddenQuests[questId] then
                    quest.HideIcons = true
                end
                if Questie.db.char.TrackerFocus and type(Questie.db.char.TrackerFocus) == "number" and Questie.db.char.TrackerFocus == quest.Id then -- quest focus
                    TrackerUtils:FocusQuest(quest.Id)
                end
                for _, objective in pairs(quest.Objectives) do
                    if Questie.db.char.TrackerHiddenObjectives[tostring(questId) .. " " .. tostring(objective.Index)] then
                        objective.HideIcons = true
                    end
                    if  Questie.db.char.TrackerFocus and type(Questie.db.char.TrackerFocus) == "string" and Questie.db.char.TrackerFocus == tostring(quest.Id) .. " " .. tostring(objective.Index) then
                        TrackerUtils:FocusObjective(quest.Id, objective.Index)
                    end
                end

                for _, objective in pairs(quest.SpecialObjectives) do
                    if Questie.db.char.TrackerHiddenObjectives[tostring(questId) .. " " .. tostring(objective.Index)] then
                        objective.HideIcons = true
                    end
                    if  Questie.db.char.TrackerFocus and type(Questie.db.char.TrackerFocus) == "string" and Questie.db.char.TrackerFocus == tostring(quest.Id) .. " " .. tostring(objective.Index) then
                        TrackerUtils:FocusObjective(quest.Id, objective.Index)
                    end
                end
            end
        end
        isFirstRun = nil
        C_Timer.After(2.0, function()
            QuestieCombatQueue:Queue(function()
                QuestieTracker:Update()
            end)
        end)
    end


    if not isFirstRun then
        _QuestieTracker.baseFrame:Show()
    else
        _QuestieTracker.baseFrame:Hide()
    end
end

function QuestieTracker.Untrack(quest)
    Questie:Debug(Questie.DEBUG_DEVELOP, "QuestieTracker: Untrack")
    QuestieTracker:UntrackQuestId(quest.Id)
end

function QuestieTracker:Unhook()
    if (not QuestieTracker._alreadyHooked) then
        return
    end

    QuestieTracker._disableHooks = true
    if QuestieTracker._IsQuestWatched then
        IsQuestWatched = QuestieTracker._IsQuestWatched
        GetNumQuestWatches = QuestieTracker._GetNumQuestWatches
    end
    _QuestieTracker._alreadyHooked = nil
    WatchFrame:Show()
end

function QuestieTracker:HookBaseTracker()
    if _QuestieTracker._alreadyHooked then
        return
    end
    QuestieTracker._disableHooks = nil

    if not QuestieTracker._alreadyHookedSecure then
        if AutoQuestWatch_Insert then
            hooksecurefunc("AutoQuestWatch_Insert", function(index, watchTimer)
                QuestieTracker:AQW_Insert(index, watchTimer)
            end)
        end
        hooksecurefunc("AddQuestWatch", function(index, watchTimer)
            QuestieTracker:AQW_Insert(index, watchTimer)
        end)
        hooksecurefunc("RemoveQuestWatch", _RemoveQuestWatch)

        -- totally prevent the blizzard tracker frame from showing (BAD CODE, shouldn't be needed but some have had trouble)
        WatchFrame:HookScript("OnShow", function(self)
            if QuestieTracker._disableHooks then
                return
            end
            self:Hide()
        end)
        QuestieTracker._alreadyHookedSecure = true
    end

    if not QuestieTracker._IsQuestWatched then
        QuestieTracker._IsQuestWatched = IsQuestWatched
        QuestieTracker._GetNumQuestWatches = GetNumQuestWatches
    end

    -- this is probably bad
    IsQuestWatched = function(index)
        local questId = select(8, GetQuestLogTitle(index));
        if questId == 0 then
            -- When an objective progresses in TBC "index" is the questId, but when a quest is manually added to the quest watch
            -- (e.g. shift clicking it in the quest log) "index" is the questLogIndex.
            questId = index;
        end
        if "0" == GetCVar("autoQuestWatch") then
            return Questie.db.char.TrackedQuests[questId or -1]
        else
            return questId and QuestiePlayer.currentQuestlog[questId] and (not Questie.db.char.AutoUntrackedQuests[questId])
        end
    end

    GetNumQuestWatches = function()
        return 0
    end

    WatchFrame:Hide()
    QuestieTracker._alreadyHooked = true
end

_OnTrackedQuestClick = function(self)
    if InCombatLockdown() then
        return
    end
    if self.mode == 1 then
        self:SetMode(0)
        Questie.db.char.isTrackerExpanded = false
    else
        self:SetMode(1)
        Questie.db.char.isTrackerExpanded = true
        _QuestieTracker.baseFrame.sizer:SetAlpha(1)
        _QuestieTracker.baseFrame:SetBackdropColor(0, 0, 0, Questie.db.global.trackerBackdropAlpha)
        if Questie.db.global.trackerBorderEnabled then
            _QuestieTracker.baseFrame:SetBackdropBorderColor(1, 1, 1, Questie.db.global.trackerBackdropAlpha)
        end
    end
    if Questie.db.global.stickyDurabilityFrame then
        QuestieTracker:CheckDurabilityAlertStatus()
        QuestieTracker:MoveDurabilityFrame()
    end
    QuestieTracker:Update()
end

function QuestieTracker:RemoveQuest(questId)
    Questie:Debug(Questie.DEBUG_DEVELOP, "QuestieTracker: RemoveQuest")
    if Questie.db.char.collapsedQuests then -- if because this function is called even Tracker isn't initialized
        Questie.db.char.collapsedQuests[questId] = nil  -- forget the collapsed/expanded state
    end
    if Questie.db.char.TrackerFocus then
        if (type(Questie.db.char.TrackerFocus) == "number" and Questie.db.char.TrackerFocus == questId)
        or (type(Questie.db.char.TrackerFocus) == "string" and Questie.db.char.TrackerFocus:sub(1, #tostring(questId)) == tostring(questId)) then
            TrackerUtils:UnFocus()
            QuestieQuest:ToggleNotes(true)
        end
    end
end

local hexTable = {
    "00","11","22","33","44","55","66","77","88","99","AA","BB","CC","DD","EE","FF"
}

function _QuestieTracker:PrintProgressColor(percent, text)
    local hexGreen = hexTable[5 + math.floor(percent * 10)]
    local hexRed = hexTable[8 + math.floor((1 - percent) * 6)]
    local hexBlue = hexTable[4 + math.floor(percent * 6)]

    return "|cFF"..hexRed..hexGreen..hexBlue..text.."|r"
end

_RemoveQuestWatch = function(index, isQuestie)
    Questie:Debug(Questie.DEBUG_DEVELOP, "QuestieTracker: RemoveQuestWatch")
    if QuestieTracker._disableHooks then
        return
    end

    if not isQuestie then
        local questId = select(8, GetQuestLogTitle(index))
        if questId == 0 then
            -- When an objective progresses in TBC "index" is the questId, but when a quest is manually removed from
            --  the quest watch (e.g. shift clicking it in the quest log) "index" is the questLogIndex.
            questId = index;
        end
        if questId then
            QuestieTracker:UntrackQuestId(questId)
        end
    end
end

function QuestieTracker:UntrackQuestId(questId)
    if "0" == GetCVar("autoQuestWatch") then
        Questie.db.char.TrackedQuests[questId] = nil
    else
        Questie.db.char.AutoUntrackedQuests[questId] = true
    end

    if Questie.db.char.hideUntrackedQuestsMapIcons then
        -- Remove quest Icons from map when untracking quest.
        -- Also reset caches of spawned Icons so re-tracking works.
        QuestieMap:UnloadQuestFrames(questId)
        local quest = QuestieDB:GetQuest(questId)
        if quest then
            for _, objective in pairs(quest.Objectives) do
                objective.AlreadySpawned = {}
            end
            for _, objective in pairs(quest.SpecialObjectives) do
                objective.AlreadySpawned = {}
            end
        end
    end

    QuestieCombatQueue:Queue(function()
        QuestieTracker:Update()
    end)
end

function QuestieTracker:AQW_Insert(index, expire)
    Questie:Debug(Questie.DEBUG_DEVELOP, "QuestieTracker: AQW_Insert")
    if (not Questie.db.global.trackerEnabled) or QuestieTracker._disableHooks then
        return
    end

    if index == 0 then
        -- TODO: This is a work around, because something is up with the AQW events again. Whenever you progress an
        -- TODO: objective for the first time, the index parameter is 0.
        return;
    end

    local now = GetTime()
    if index and index == QuestieTracker._last_aqw and (now - lastAQW) < 0.1 then
        -- this fixes double calling due to AQW+AQW_Insert (QuestGuru fix)
        return
    end

    lastAQW = now
    QuestieTracker._last_aqw = index
    RemoveQuestWatch(index, true) -- prevent hitting 5 quest watch limit

    local questId = select(8, GetQuestLogTitle(index))
    if questId == 0 then
        -- When an objective progresses in TBC "index" is the questId, but when a quest is manually added to the quest watch
        -- (e.g. shift clicking it in the quest log) "index" is the questLogIndex.
        questId = index;
    end

    if questId > 0 then
        if "0" == GetCVar("autoQuestWatch") then
            if Questie.db.char.TrackedQuests[questId] then
                Questie.db.char.TrackedQuests[questId] = nil
            else
                Questie.db.char.TrackedQuests[questId] = true
            end
        else
            if Questie.db.char.AutoUntrackedQuests[questId] then
                Questie.db.char.AutoUntrackedQuests[questId] = nil
            elseif IsShiftKeyDown() and (QuestLogFrame:IsShown() or (QuestLogExFrame and QuestLogExFrame:IsShown())) then--hack
                Questie.db.char.AutoUntrackedQuests[questId] = true
            end
        end

        -- Make sure quests or zones (re)added to the tracker isn't in a minimized state
        local quest = QuestieDB:GetQuest(questId)
        if quest then
            local zoneId = quest.zoneOrSort

            if Questie.db.char.collapsedQuests[questId] == true then
                Questie.db.char.collapsedQuests[questId] = nil
            end

            if Questie.db.char.collapsedZones[zoneId] == true then
                Questie.db.char.collapsedZones[zoneId] = nil
            end
        else
            Questie:Error("Missing quest " .. tostring(questId) .. "," .. tostring(expire) .. " during tracker update")
        end
        QuestieCombatQueue:Queue(function()
            QuestieTracker:Update()
            if Questie.db.char.hideUntrackedQuestsMapIcons then
                -- Quest had its Icons removed, paint them again
                QuestieQuest:PopulateObjectiveNotes(quest)
            end
        end)
    end
end

local function _GetWorldPlayerPosition()
    -- Turns coords into 'world' coords so it can be compared with any coords in another zone
    local uiMapId = C_Map.GetBestMapForUnit("player");

    if (not uiMapId) then
        return nil;
    end

    local mapPosition = C_Map.GetPlayerMapPosition(uiMapId, "player");
    if (not mapPosition) or (not mapPosition.x) then
        return nil
    end
    local _, worldPosition = C_Map.GetWorldPosFromMapPos(uiMapId, mapPosition);

    return worldPosition;
end

local function _GetDistance(x1, y1, x2, y2)
    -- Basic proximity distance calculation to compare two locs (normally player position and provided loc)
    return math.sqrt( (x2-x1)^2 + (y2-y1)^2 );
end

_GetDistanceToClosestObjective = function(questId)
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

_GetContinent = function(uiMapId)
    if (not uiMapId) then
        return
    end

    if (uiMapId == 947) or (uiMapId == 1459) or (uiMapId == 1460) or (uiMapId == 1461) then
        return "Azeroth"
    elseif ((uiMapId >= 1415) and (uiMapId <= 1437)) or (uiMapId == 1453) or (uiMapId == 1455) or (uiMapId == 1458) or (uiMapId == 1463) then
        return "Eastern Kingdoms"
    elseif ((uiMapId >= 1411) and (uiMapId <= 1414)) or ((uiMapId >= 1438) and (uiMapId <= 1452)) or (uiMapId == 1454) or (uiMapId == 1456) or (uiMapId == 1457) then
        return "Kalimdor"
    elseif uiMapId > 1900 and uiMapId < 2000 then
        return "Outland"
    else -- todo: check C_Map.GetMapInfo parent (we need to test that more, this is safe for now)
        return "Outland" --Questie:Error("[QuestieTracker] " .. uiMapId .. " is an unknown uiMapId")
    end
end

function QuestieTracker:UpdateQuestProximityTimer()
    -- Check location often and update if you've moved
    C_Timer.After(3.0, function()
        _QuestProximityTimer = C_Timer.NewTicker(5.0, function()
            local position = _GetWorldPlayerPosition();
            if position then
                local distance = _PlayerPosition and _GetDistance(position.x, position.y, _PlayerPosition.x, _PlayerPosition.y);
                if not distance or distance > 0.01 then
                    _PlayerPosition = position;
                    --QuestieTracker:Update()
                    local orderCopy = {}
                    for index, val in pairs(QuestieTracker._order) do
                        orderCopy[index] = val
                    end
                    table.sort(orderCopy, QuestieTracker._sorter)
                    for index, val in pairs(QuestieTracker._order) do
                        if orderCopy[index] ~= val then
                            -- the order has changed
                            QuestieTracker:Update()
                            break;
                        end
                    end
                end
            end
        end)
    end)
end
