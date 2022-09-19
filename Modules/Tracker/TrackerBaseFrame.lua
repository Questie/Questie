local WatchFrame = QuestWatchFrame or WatchFrame

---@class TrackerBaseFrame
local TrackerBaseFrame = QuestieLoader:CreateModule("TrackerBaseFrame")

---@type QuestieCombatQueue
local QuestieCombatQueue = QuestieLoader:ImportModule("QuestieCombatQueue")
---@type FadeTicker
local FadeTicker = QuestieLoader:ImportModule("FadeTicker")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local baseFrame
local _UpdateTracker, _MoveDurabilityFrame

TrackerBaseFrame.IsInitialized = false
local isSizing = false

---@param UpdateTracker function @The QuestieTracker:Update function
---@param MoveDurabilityFrame function @The QuestieTracker:MoveDurabilityFrame function
---@return Frame
function TrackerBaseFrame.Initialize(UpdateTracker, MoveDurabilityFrame)
    _UpdateTracker = UpdateTracker
    _MoveDurabilityFrame = MoveDurabilityFrame

    baseFrame = CreateFrame("Frame", "Questie_BaseFrame", UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
    baseFrame:SetClampedToScreen(true) -- We don't want this frame to be able to move off screen at all!
    baseFrame:SetFrameStrata("BACKGROUND")
    baseFrame:SetFrameLevel(0)
    baseFrame:SetSize(280, 32)

    baseFrame:EnableMouse(true)
    baseFrame:SetMovable(true)
    baseFrame:SetResizable(true)
    baseFrame:SetMinResize(1, 1)

    baseFrame:SetScript("OnMouseDown", TrackerBaseFrame.OnDragStart)
    baseFrame:SetScript("OnMouseUp", TrackerBaseFrame.OnDragStop)
    baseFrame:SetScript("OnEnter", FadeTicker.OnEnter)
    baseFrame:SetScript("OnLeave", FadeTicker.OnLeave)

    baseFrame:SetBackdrop( {
        bgFile="Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile=true, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })

    baseFrame:SetBackdropColor(0, 0, 0, 0)
    baseFrame:SetBackdropBorderColor(1, 1, 1, 0)

    local sizer = CreateFrame("Frame", "Questie_Sizer", baseFrame)
    sizer:SetPoint("BOTTOMRIGHT", 0, 0)
    sizer:SetWidth(25)
    sizer:SetHeight(25)
    sizer:SetAlpha(0)
    sizer:EnableMouse()
    sizer:SetScript("OnMouseDown", TrackerBaseFrame.OnResizeStart)
    sizer:SetScript("OnMouseUp", TrackerBaseFrame.OnResizeStop)
    sizer:SetScript("OnEnter", FadeTicker.OnEnter)
    sizer:SetScript("OnLeave", FadeTicker.OnLeave)

    baseFrame.sizer = sizer

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
        local result, reason = pcall(baseFrame.SetPoint, baseFrame, unpack(Questie.db[Questie.db.global.questieTLoc].TrackerLocation))

        if (not result) then
            Questie.db[Questie.db.global.questieTLoc].TrackerLocation = nil
            print(l10n("Error: Questie tracker in invalid location, resetting..."))
            Questie:Debug(Questie.DEBUG_CRITICAL, "Resetting reason:", reason)

            if WatchFrame then
                local result2, _ = pcall(baseFrame.SetPoint, baseFrame, unpack({ WatchFrame:GetPoint()}))
                Questie.db[Questie.db.global.questieTLoc].trackerSetpoint = "AUTO"
                if (not result2) then
                    Questie.db[Questie.db.global.questieTLoc].TrackerLocation = nil
                    TrackerBaseFrame.SetSafePoint(baseFrame)
                end
            else
                TrackerBaseFrame.SetSafePoint(baseFrame)
            end
        end
    else
        if WatchFrame then
            local result, _ = pcall(baseFrame.SetPoint, baseFrame, unpack({ WatchFrame:GetPoint()}))
            Questie.db[Questie.db.global.questieTLoc].trackerSetpoint = "AUTO"

            if not result then
                Questie.db[Questie.db.global.questieTLoc].TrackerLocation = nil
                print(l10n("Error: Questie tracker in invalid location, resetting..."))
                TrackerBaseFrame.SetSafePoint(baseFrame)
            end
        else
            TrackerBaseFrame.SetSafePoint(baseFrame)
        end
    end

    baseFrame:Hide()
    TrackerBaseFrame.IsInitialized = true
    return baseFrame
end

function TrackerBaseFrame.Update()
    if Questie.db.char.isTrackerExpanded and GetNumQuestLogEntries() > 0 then
        if Questie.db.global.trackerBackdropEnabled then
            if not Questie.db.global.trackerBackdropFader then
                baseFrame:SetBackdropColor(0, 0, 0, Questie.db.global.trackerBackdropAlpha)
                if Questie.db.global.trackerBorderEnabled then
                    baseFrame:SetBackdropBorderColor(1, 1, 1, Questie.db.global.trackerBackdropAlpha)
                end
            end

        else
            baseFrame:SetBackdropColor(0, 0, 0, 0)
            baseFrame:SetBackdropBorderColor(1, 1, 1, 0)
        end

    else
        baseFrame.sizer:SetAlpha(0)
        baseFrame:SetBackdropColor(0, 0, 0, 0)
        baseFrame:SetBackdropBorderColor(1, 1, 1, 0)
    end

    -- Enables Click-Through when the tracker is locked
    if IsControlKeyDown() or (not Questie.db.global.trackerLocked) then
        baseFrame:SetMovable(true)
        QuestieCombatQueue:Queue(function()
            if IsMouseButtonDown() then
                return
            end
            baseFrame:EnableMouse(true)
            baseFrame:SetResizable(true)
        end)

    else
        baseFrame:SetMovable(false)
        QuestieCombatQueue:Queue(function()
            if IsMouseButtonDown() then
                return
            end
            baseFrame:EnableMouse(false)
            baseFrame:SetResizable(false)
        end)
    end
end

function TrackerBaseFrame.SetSafePoint()
    baseFrame:ClearAllPoints()

    local xOff, yOff = baseFrame:GetWidth()/2, baseFrame:GetHeight()/2
    local resetCords = {["BOTTOMLEFT"] = {x = -xOff, y = -yOff}, ["BOTTOMRIGHT"] = {x = xOff, y = -yOff}, ["TOPLEFT"] = {x = -xOff, y =  yOff}, ["TOPRIGHT"] = {x = xOff, y =  yOff}}

    local trackerSetPoint = Questie.db[Questie.db.global.questieTLoc].trackerSetpoint
    if trackerSetPoint == "AUTO" then
        baseFrame:SetPoint("TOPLEFT", UIParent, "CENTER", resetCords["TOPLEFT"].x, resetCords["TOPLEFT"].y)
    else
        baseFrame:SetPoint(trackerSetPoint, UIParent, "CENTER", resetCords[trackerSetPoint].x, resetCords[trackerSetPoint].y)
    end
end

function TrackerBaseFrame.ShrinkToMinSize(minSize)
    local xOff, yOff = baseFrame:GetLeft(), baseFrame:GetTop()

    baseFrame:ClearAllPoints()
    -- Offsets start from BOTTOMLEFT. So TOPLEFT is +, - for offsets. Thanks Blizzard >_>
    baseFrame:SetPoint("TOPLEFT", UIParent, xOff, -(GetScreenHeight() - yOff))

    baseFrame:SetHeight(minSize)
end

local mouselookTicker = {}
local dragButton

---@param button string @The mouse button that is pressed when dragging starts
function TrackerBaseFrame.OnDragStart(button)
    Questie:Debug(Questie.DEBUG_DEVELOP, "[TrackerBaseFrame:OnDragStart]", button)
    if InCombatLockdown() then
        return
    end

    if IsMouseButtonDown(button) then
        if (IsControlKeyDown() and Questie.db.global.trackerLocked and not ChatEdit_GetActiveWindow()) or not Questie.db.global.trackerLocked then
            dragButton = button
            baseFrame:StartMoving()
            if Questie.db.char.isTrackerExpanded then
                baseFrame.sizer:SetAlpha(1)
            end
        else
            -- Turns off mouse looking to prevent frame from becoming stuck to the pointer
            if not IsMouselooking() then
                MouselookStart()
                mouselookTicker = C_Timer.NewTicker(0.1, function()
                    if not IsMouseButtonDown(button) then
                        MouselookStop()
                        mouselookTicker:Cancel()
                    end
                end)
            end
        end
    end
end

local function _UpdateTrackerPosition()
    local xOff, yOff = baseFrame:GetLeft(), baseFrame:GetTop()

    baseFrame:ClearAllPoints()
    -- Offsets start from BOTTOMLEFT. So TOPLEFT is +, - for offsets. Thanks Blizzard >_>
    baseFrame:SetPoint("TOPLEFT", UIParent, xOff, -(GetScreenHeight() - yOff))

    Questie.db[Questie.db.global.questieTLoc].TrackerLocation = {"TOPLEFT", "UIParent", "TOPLEFT", xOff, -(GetScreenHeight() - yOff)}

    _MoveDurabilityFrame()
    _UpdateTracker()
end

function TrackerBaseFrame.OnDragStop()
    Questie:Debug(Questie.DEBUG_DEVELOP, "[TrackerBaseFrame:OnDragStop]")

    if (not dragButton) or IsMouseButtonDown(dragButton) then
        return
    end

    dragButton = nil
    baseFrame:StopMovingOrSizing()

    QuestieCombatQueue:Queue(_UpdateTrackerPosition)
end

local updateTimer

---@param button string @The mouse button that is pressed when resize starts
function TrackerBaseFrame.OnResizeStart(_, button)
    Questie:Debug(Questie.DEBUG_DEVELOP, "[TrackerBaseFrame:OnResizeStart]", button)
    if InCombatLockdown() or (not baseFrame:IsResizable()) then
        return
    end

    if button == "LeftButton" then
        if IsMouseButtonDown(button) then
            if IsControlKeyDown() or (not Questie.db.global.trackerLocked) then
                isSizing = true
                baseFrame:StartSizing("RIGHT")
                updateTimer = C_Timer.NewTicker(0.1, function()
                    Questie.db[Questie.db.global.questieTLoc].TrackerWidth = baseFrame:GetWidth()
                    _UpdateTracker() -- TODO: This really needs to work flawlessly and fast when its called every 0.1 second
                end)
            end
        end
    elseif button == "RightButton" then
        Questie.db[Questie.db.global.questieTLoc].TrackerWidth = 0
        _UpdateTracker()
        baseFrame.sizer:SetAlpha(1)
    end
end

---@param button string @The mouse button that is pressed when resize stops
function TrackerBaseFrame.OnResizeStop(_, button)
    Questie:Debug(Questie.DEBUG_DEVELOP, "[TrackerBaseFrame:OnResizeStop]", button)
    if button == "RightButton" or isSizing ~= true then
        return
    end

    isSizing = false
    baseFrame:StopMovingOrSizing()
    updateTimer:Cancel()
end

---Updates the TrackerBaseFrame width to be at a minimum width of the activeQuestsHeader
---@param activeQuestsHeaderWidth number @The width of the ActiveQuestsHeader
---@param trackerVarsCombined number @Combined tracker width parameters
function TrackerBaseFrame.UpdateWidth(activeQuestsHeaderWidth, trackerVarsCombined)
    local baseFrameWidth = baseFrame:GetWidth()

    if Questie.db[Questie.db.global.questieTLoc].TrackerWidth > 0 then
        -- Manual user width
        if (not isSizing) and (Questie.db[Questie.db.global.questieTLoc].TrackerWidth < activeQuestsHeaderWidth) then
            baseFrame:SetWidth(activeQuestsHeaderWidth)
            Questie.db[Questie.db.global.questieTLoc].TrackerWidth = activeQuestsHeaderWidth
        elseif (not isSizing) and (Questie.db[Questie.db.global.questieTLoc].TrackerWidth ~= baseFrameWidth) then
            baseFrame:SetWidth(Questie.db[Questie.db.global.questieTLoc].TrackerWidth)
        end
    else
        -- auto width
        if (trackerVarsCombined < activeQuestsHeaderWidth) then
            baseFrame:SetWidth(activeQuestsHeaderWidth)
        elseif (trackerVarsCombined ~= baseFrameWidth) then
            baseFrame:SetWidth(trackerVarsCombined)
        end
    end
end