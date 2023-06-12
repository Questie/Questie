---@class TrackerBaseFrame
local TrackerBaseFrame = QuestieLoader:CreateModule("TrackerBaseFrame")
-------------------------
--Import QuestieTracker modules.
-------------------------
---@type QuestieTracker
local QuestieTracker = QuestieLoader:ImportModule("QuestieTracker")
---@type TrackerFadeTicker
local TrackerFadeTicker = QuestieLoader:ImportModule("TrackerFadeTicker")
-------------------------
--Import Questie modules.
-------------------------
---@type QuestieCombatQueue
local QuestieCombatQueue = QuestieLoader:ImportModule("QuestieCombatQueue")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local WatchFrame = QuestWatchFrame or WatchFrame
local baseFrame, sizer, sizerSetPoint, sizerSetPointY, sizerLine1, sizerLine2, sizerLine3
local mouseLookTicker
local updateTimer

TrackerBaseFrame.IsInitialized = false
TrackerBaseFrame.isSizing = false
TrackerBaseFrame.isMoving = false

function TrackerBaseFrame.Initialize()
    baseFrame = CreateFrame("Frame", "Questie_BaseFrame", UIParent, BackdropTemplateMixin and "BackdropTemplate")
    baseFrame:SetClampedToScreen(true) -- We don't want this frame to be able to move off screen at all!
    baseFrame:SetFrameStrata("MEDIUM")
    baseFrame:SetFrameLevel(0)
    baseFrame:SetSize(25, 25)

    baseFrame:EnableMouse(true)
    baseFrame:SetMovable(true)
    baseFrame:SetResizable(true)

    baseFrame:SetScript("OnMouseDown", TrackerBaseFrame.OnDragStart)
    baseFrame:SetScript("OnMouseUp", TrackerBaseFrame.OnDragStop)
    baseFrame:SetScript("OnEnter", TrackerFadeTicker.Unfade)

    baseFrame:SetScript("OnLeave", TrackerFadeTicker.Fade)

    baseFrame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })

    baseFrame:SetBackdropColor(0, 0, 0, 0)
    baseFrame:SetBackdropBorderColor(1, 1, 1, 0)

    local QuestieTrackerLoc = Questie.db[Questie.db.global.questieTLoc].TrackerLocation
    if QuestieTrackerLoc and (QuestieTrackerLoc[1] == "BOTTOMLEFT" or QuestieTrackerLoc[1] == "BOTTOMRIGHT") then
        sizerSetPoint = "TOPRIGHT"
        sizerSetPointY = -4
    else
        sizerSetPoint = "BOTTOMRIGHT"
        sizerSetPointY = 4
    end

    sizer = CreateFrame("Frame", "Questie_Sizer", baseFrame)
    sizer:SetPoint(sizerSetPoint, 0, 0)
    sizer:SetWidth(25)
    sizer:SetHeight(25)
    sizer:SetAlpha(0)
    sizer:EnableMouse(true)
    sizer:SetScript("OnMouseDown", TrackerBaseFrame.OnResizeStart)
    sizer:SetScript("OnMouseUp", TrackerBaseFrame.OnResizeStop)

    sizer:SetScript("OnEnter", function(self)
        if InCombatLockdown() then
            if GameTooltip:IsShown() then
                GameTooltip:Hide()
                return
            end
        end

        -- Set Sizer mode
        local trackerSizeMode
        if Questie.db[Questie.db.global.questieTLoc].TrackerHeight == 0 then
            trackerSizeMode = Questie:Colorize(l10n("Auto"), "green")
        else
            trackerSizeMode = Questie:Colorize(l10n("Manual"), "orange")
        end

        -- Set initial tooltip
        if not Questie.db.global.sizerHidden then
            GameTooltip._owner = self
            GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
            if IsShiftKeyDown() then
                GameTooltip:ClearLines()
                GameTooltip:AddLine(Questie:Colorize(l10n("Sizer Mode") .. ": ", "white") .. trackerSizeMode)
                GameTooltip:AddLine(Questie:Colorize(l10n("Left Click + Hold") .. ": ", "gray") .. l10n("Resize Tracker (Manual)"))
                GameTooltip:AddLine(Questie:Colorize(l10n("Right Click") .. ": ", "gray") .. l10n("Reset Sizer (Auto)"))
                GameTooltip:AddLine(" ")
                GameTooltip:AddLine(Questie:Colorize(l10n("Ctrl + Left Click + Hold") .. ": ", "gray") .. l10n("Resize while Locked"))
                GameTooltip:AddLine(Questie:Colorize(l10n("Ctrl + Right Click") .. ": ", "gray") .. l10n("Reset while Locked"))
                GameTooltip:AddLine(" ")
                GameTooltip:AddLine(Questie:Colorize(l10n("NOTE") .. ": ", "red") .. l10n("The Tracker Height Ratio\nis ignored while in Manual mode"))
                GameTooltip:Show()
            else
                GameTooltip:ClearLines()
                GameTooltip:AddLine(Questie:Colorize(l10n("Sizer Mode") .. ": ", "white") .. trackerSizeMode)
                GameTooltip:AddLine(Questie:Colorize("(" .. l10n("Hold Shift") .. ")", "gray"))
                GameTooltip:Show()
            end

            -- Update tooltip
            GameTooltip._SizerToolTip = function()
                if IsShiftKeyDown() then
                    GameTooltip:ClearLines()
                    GameTooltip:AddLine(Questie:Colorize(l10n("Sizer Mode") .. ": ", "white") .. trackerSizeMode)
                    GameTooltip:AddLine(Questie:Colorize(l10n("Left Click + Hold") .. ": ", "gray") .. l10n("Resize Tracker (Manual)"))
                    GameTooltip:AddLine(Questie:Colorize(l10n("Right Click") .. ": ", "gray") .. l10n("Reset Sizer (Auto)"))
                    GameTooltip:AddLine(" ")
                    GameTooltip:AddLine(Questie:Colorize(l10n("Ctrl + Left Click + Hold") .. ": ", "gray") .. l10n("Resize while Locked"))
                    GameTooltip:AddLine(Questie:Colorize(l10n("Ctrl + Right Click") .. ": ", "gray") .. l10n("Reset while Locked"))
                    GameTooltip:AddLine(" ")
                    GameTooltip:AddLine(Questie:Colorize(l10n("NOTE") .. ": ", "red") .. l10n("The Tracker Height Ratio\nis ignored while in Manual mode"))
                    GameTooltip:Show()
                else
                    GameTooltip:ClearLines()
                    GameTooltip:AddLine(Questie:Colorize(l10n("Sizer Mode") .. ": ", "white") .. trackerSizeMode)
                    GameTooltip:AddLine(Questie:Colorize("(" .. l10n("Hold Shift") .. ")", "gray"))
                    GameTooltip:Show()
                end
            end
        end

        TrackerFadeTicker.Unfade(self)
    end)

    sizer:SetScript("OnLeave", function(self)
        if GameTooltip:IsShown() then
            GameTooltip:Hide()
            GameTooltip._SizerToolTip = nil
        end

        TrackerFadeTicker.Fade(self)
    end)

    baseFrame.sizer = sizer

    sizerLine1 = sizer:CreateTexture(nil, "BACKGROUND")
    sizerLine1:SetWidth(14)
    sizerLine1:SetHeight(14)
    sizerLine1:SetPoint(sizerSetPoint, -4, sizerSetPointY)
    sizerLine1:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")

    local x = 0.1 * 14 / 17
    if QuestieTrackerLoc and (QuestieTrackerLoc[1] == "BOTTOMLEFT" or QuestieTrackerLoc[1] == "BOTTOMRIGHT") then
        sizerLine1:SetTexCoord(1 / 32, 0.5 + x, 1 / 32 - x, 0.5, 1 / 32 + x, 0.5, 1 / 32, 0.5 - x)
    else
        sizerLine1:SetTexCoord(1 / 32 - x, 0.5, 1 / 32, 0.5 + x, 1 / 32, 0.5 - x, 1 / 32 + x, 0.5)
    end

    sizerLine2 = sizer:CreateTexture(nil, "BACKGROUND")
    sizerLine2:SetWidth(11)
    sizerLine2:SetHeight(11)
    sizerLine2:SetPoint(sizerSetPoint, -4, sizerSetPointY)
    sizerLine2:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")

    x = 0.1 * 11 / 17
    if QuestieTrackerLoc and (QuestieTrackerLoc[1] == "BOTTOMLEFT" or QuestieTrackerLoc[1] == "BOTTOMRIGHT") then
        sizerLine2:SetTexCoord(1 / 32, 0.5 + x, 1 / 32 - x, 0.5, 1 / 32 + x, 0.5, 1 / 32, 0.5 - x)
    else
        sizerLine2:SetTexCoord(1 / 32 - x, 0.5, 1 / 32, 0.5 + x, 1 / 32, 0.5 - x, 1 / 32 + x, 0.5)
    end

    sizerLine3 = sizer:CreateTexture(nil, "BACKGROUND")
    sizerLine3:SetWidth(8)
    sizerLine3:SetHeight(8)
    sizerLine3:SetPoint(sizerSetPoint, -4, sizerSetPointY)
    sizerLine3:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")

    x = 0.1 * 8 / 17
    if QuestieTrackerLoc and (QuestieTrackerLoc[1] == "BOTTOMLEFT" or QuestieTrackerLoc[1] == "BOTTOMRIGHT") then
        sizerLine3:SetTexCoord(1 / 32, 0.5 + x, 1 / 32 - x, 0.5, 1 / 32 + x, 0.5, 1 / 32, 0.5 - x)
    else
        sizerLine3:SetTexCoord(1 / 32 - x, 0.5, 1 / 32, 0.5 + x, 1 / 32, 0.5 - x, 1 / 32 + x, 0.5)
    end

    if Questie.db[Questie.db.global.questieTLoc].TrackerLocation then
        -- we need to pcall this because it can error if something like MoveAnything is used to move the tracker
        local result, reason = pcall(baseFrame.SetPoint, baseFrame, unpack(Questie.db[Questie.db.global.questieTLoc].TrackerLocation))

        if (not result) then
            Questie.db[Questie.db.global.questieTLoc].TrackerLocation = nil
            print(l10n("Error: Questie tracker in invalid location, resetting..."))
            Questie:Debug(Questie.DEBUG_CRITICAL, "Resetting reason:", reason)

            if WatchFrame then
                local result2, _ = pcall(baseFrame.SetPoint, baseFrame, unpack({ WatchFrame:GetPoint() }))
                Questie.db[Questie.db.global.questieTLoc].trackerSetpoint = "TOPLEFT"

                if (not result2) then
                    Questie.db[Questie.db.global.questieTLoc].TrackerLocation = nil
                    TrackerBaseFrame:SetSafePoint()
                end
            else
                TrackerBaseFrame:SetSafePoint()
            end
        end
    else
        if WatchFrame then
            local result, reason = pcall(baseFrame.SetPoint, baseFrame, unpack({ WatchFrame:GetPoint() }))
            Questie.db[Questie.db.global.questieTLoc].trackerSetpoint = "TOPLEFT"

            if not result then
                Questie.db[Questie.db.global.questieTLoc].TrackerLocation = nil
                print(l10n("Error: Questie tracker in invalid location, resetting..."))
                Questie:Debug(Questie.DEBUG_CRITICAL, "Resetting reason:", reason)
                TrackerBaseFrame:SetSafePoint()
            end
        else
            TrackerBaseFrame:SetSafePoint()
        end
    end

    baseFrame:Hide()
    baseFrame.isSizing = false
    baseFrame.isMoving = false

    TrackerBaseFrame.IsInitialized = true
    TrackerBaseFrame.baseFrame = baseFrame

    return baseFrame
end

function TrackerBaseFrame:Update()
    if Questie.db.char.isTrackerExpanded and QuestieTracker:HasQuest() then
        if Questie.db.global.trackerBackdropEnabled then
            if Questie.db.global.trackerBorderEnabled then
                if not Questie.db.global.trackerBackdropFader then
                    baseFrame:SetBackdropColor(0, 0, 0, Questie.db.global.trackerBackdropAlpha)
                    baseFrame:SetBackdropBorderColor(1, 1, 1, Questie.db.global.trackerBackdropAlpha)
                else
                    baseFrame:SetBackdropColor(0, 0, 0, 0)
                    baseFrame:SetBackdropBorderColor(1, 1, 1, 0)
                end
            else
                if not Questie.db.global.trackerBackdropFader then
                    baseFrame:SetBackdropColor(0, 0, 0, Questie.db.global.trackerBackdropAlpha)
                else
                    baseFrame:SetBackdropColor(0, 0, 0, 0)
                end
                baseFrame:SetBackdropBorderColor(1, 1, 1, 0)
            end
        else
            baseFrame:SetBackdropColor(0, 0, 0, 0)
            baseFrame:SetBackdropBorderColor(1, 1, 1, 0)
        end

        local QuestieTrackerLoc = Questie.db[Questie.db.global.questieTLoc].TrackerLocation

        if QuestieTrackerLoc and (QuestieTrackerLoc[1] == "BOTTOMLEFT" or QuestieTrackerLoc[1] == "BOTTOMRIGHT") and Questie.db.global.autoMoveHeader then
            -- Move Sizer to Top Right corner
            sizer:ClearAllPoints()
            sizer:SetPoint("TOPRIGHT", 0, 0)

            sizerLine1:ClearAllPoints()
            sizerLine1:SetPoint("TOPRIGHT", -4, -4)
            local x = 0.1 * 14 / 17
            sizerLine1:SetTexCoord(1 / 32, 0.5 + x, 1 / 32 - x, 0.5, 1 / 32 + x, 0.5, 1 / 32, 0.5 - x)

            sizerLine2:ClearAllPoints()
            sizerLine2:SetPoint("TOPRIGHT", -4, -4)
            x = 0.1 * 11 / 17
            sizerLine2:SetTexCoord(1 / 32, 0.5 + x, 1 / 32 - x, 0.5, 1 / 32 + x, 0.5, 1 / 32, 0.5 - x)

            sizerLine3:ClearAllPoints()
            sizerLine3:SetPoint("TOPRIGHT", -4, -4)
            x = 0.1 * 8 / 17
            sizerLine3:SetTexCoord(1 / 32, 0.5 + x, 1 / 32 - x, 0.5, 1 / 32 + x, 0.5, 1 / 32, 0.5 - x)
        else
            -- Move Sizer to Bottom Right corner
            sizer:ClearAllPoints()
            sizer:SetPoint("BOTTOMRIGHT", 0, 0)

            sizerLine1:ClearAllPoints()
            sizerLine1:SetPoint("BOTTOMRIGHT", -4, 4)
            local x = 0.1 * 14 / 17
            sizerLine1:SetTexCoord(1 / 32 - x, 0.5, 1 / 32, 0.5 + x, 1 / 32, 0.5 - x, 1 / 32 + x, 0.5)

            sizerLine2:ClearAllPoints()
            sizerLine2:SetPoint("BOTTOMRIGHT", -4, 4)
            x = 0.1 * 11 / 17
            sizerLine2:SetTexCoord(1 / 32 - x, 0.5, 1 / 32, 0.5 + x, 1 / 32, 0.5 - x, 1 / 32 + x, 0.5)

            sizerLine3:ClearAllPoints()
            sizerLine3:SetPoint("BOTTOMRIGHT", -4, 4)
            x = 0.1 * 8 / 17
            sizerLine3:SetTexCoord(1 / 32 - x, 0.5, 1 / 32, 0.5 + x, 1 / 32, 0.5 - x, 1 / 32 + x, 0.5)
        end

        if Questie.db.global.sizerHidden then
            baseFrame.sizer:SetAlpha(0)
        end
    else
        baseFrame.sizer:SetAlpha(0)
        DurabilityFrame:Hide()
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

    QuestieTracker:UpdateVoiceOverFrame()
    QuestieTracker:CheckDurabilityAlertStatus()
end

function TrackerBaseFrame:SetSafePoint()
    if TrackerBaseFrame.isMoving ~= true and TrackerBaseFrame.isResizing ~= true then
        Questie:Debug(Questie.DEBUG_DEVELOP, "[TrackerBaseFrame:SetSafePoint]")
    else
        Questie:Debug(Questie.DEBUG_DEVELOP, "[TrackerBaseFrame:SetSafePoint] - Frame is moving or resizing! --> Exiting.")
        return
    end

    local xOff, yOff = baseFrame:GetWidth() / 2, baseFrame:GetHeight() / 2
    local trackerSetPoint = Questie.db[Questie.db.global.questieTLoc].trackerSetpoint
    local resetCords = { ["BOTTOMLEFT"] = { x = -xOff, y = -yOff }, ["BOTTOMRIGHT"] = { x = xOff, y = -yOff }, ["TOPLEFT"] = { x = -xOff, y = yOff }, ["TOPRIGHT"] = { x = xOff, y = yOff } }
    baseFrame:ClearAllPoints()

    if trackerSetPoint then
        baseFrame:SetPoint(trackerSetPoint, UIParent, "CENTER", resetCords[trackerSetPoint].x, resetCords[trackerSetPoint].y)
        Questie.db[Questie.db.global.questieTLoc].TrackerLocation = { trackerSetPoint, "UIParent", "CENTER", resetCords[trackerSetPoint].x, resetCords[trackerSetPoint].y }
    end

    QuestieTracker:Update()
end

function TrackerBaseFrame.ShrinkToMinSize(minSize)
    baseFrame:SetHeight(minSize)
end

---@param button string @The mouse button that is pressed when dragging starts
function TrackerBaseFrame.OnDragStart(frame, button)
    if GameTooltip:IsShown() then
        GameTooltip:Hide()
        GameTooltip._SizerToolTip = nil
    end

    if InCombatLockdown() or IsShiftKeyDown() or IsAltKeyDown() then
        Questie:Debug(Questie.DEBUG_DEVELOP, "[TrackerBaseFrame:OnDragStart] - In Combat or shift key or alt key detected! --> Exiting.")
        return
    else
        if (IsControlKeyDown() and Questie.db.global.trackerLocked and not ChatEdit_GetActiveWindow()) or not Questie.db.global.trackerLocked then
            if TrackerBaseFrame.isMoving ~= false or TrackerBaseFrame.isSizing == true then
                Questie:Debug(Questie.DEBUG_DEVELOP, "[TrackerBaseFrame:OnDragStart] - Frame is already moving or frame is already resizing! --> Exiting.")
                return
            end
        else
            Questie:Debug(Questie.DEBUG_DEVELOP, "[TrackerBaseFrame:OnDragStart] - Tracker is Locked. Use CTRL Key. --> Exiting.")
            return
        end
    end

    if TrackerBaseFrame.isMoving ~= true and TrackerBaseFrame.isSizing ~= true then
        if IsMouseButtonDown(button) and button ~= "MiddleButton" then
            if (IsControlKeyDown() and Questie.db.global.trackerLocked and not ChatEdit_GetActiveWindow()) or not Questie.db.global.trackerLocked then
                if baseFrame:IsMovable() then
                    Questie:Debug(Questie.DEBUG_DEVELOP, "[TrackerBaseFrame:OnDragStart] - Dragging Started.")
                    TrackerBaseFrame.isMoving = true
                    TrackerBaseFrame.baseFrame.isMoving = true

                    baseFrame:StartMoving()
                    TrackerBaseFrame:Update()
                else
                    Questie:Debug(Questie.DEBUG_DEVELOP, "[TrackerBaseFrame:OnDragStart] - Frame is not movable!")
                end
            end
        end
    end
end

local function _UpdateTrackerPosition()
    if TrackerBaseFrame.isMoving ~= true and TrackerBaseFrame.isResizing ~= true then
        Questie:Debug(Questie.DEBUG_DEVELOP, "[TrackerBaseFrame:UpdateTrackerPosition]")
    else
        Questie:Debug(Questie.DEBUG_DEVELOP, "[TrackerBaseFrame:UpdateTrackerPosition] - Frame is moving or resizing! --> Exiting.")
        return
    end

    local xLeft, yTop, xRight, yBottom = baseFrame:GetLeft(), baseFrame:GetTop(), baseFrame:GetRight(), baseFrame:GetBottom()
    local trackerSetPoint = Questie.db[Questie.db.global.questieTLoc].trackerSetpoint
    baseFrame:ClearAllPoints()

    if trackerSetPoint == "BOTTOMLEFT" then
        baseFrame:SetPoint("BOTTOMLEFT", UIParent, xLeft, yBottom)
        Questie.db[Questie.db.global.questieTLoc].TrackerLocation = { "BOTTOMLEFT", "UIParent", "BOTTOMLEFT", xLeft, yBottom }
    elseif trackerSetPoint == "BOTTOMRIGHT" then
        baseFrame:SetPoint("BOTTOMRIGHT", UIParent, -(GetScreenWidth() - xRight), yBottom)
        Questie.db[Questie.db.global.questieTLoc].TrackerLocation = { "BOTTOMRIGHT", "UIParent", "BOTTOMRIGHT", -(GetScreenWidth() - xRight), yBottom }
    elseif trackerSetPoint == "TOPRIGHT" then
        baseFrame:SetPoint("TOPRIGHT", UIParent, -(GetScreenWidth() - xRight), -(GetScreenHeight() - yTop))
        Questie.db[Questie.db.global.questieTLoc].TrackerLocation = { "TOPRIGHT", "UIParent", "TOPRIGHT", -(GetScreenWidth() - xRight), -(GetScreenHeight() - yTop) }
    else
        baseFrame:SetPoint("TOPLEFT", UIParent, xLeft, -(GetScreenHeight() - yTop))
        Questie.db[Questie.db.global.questieTLoc].TrackerLocation = { "TOPLEFT", "UIParent", "TOPLEFT", xLeft, -(GetScreenHeight() - yTop) }
    end

    C_Timer.After(0.12, function()
        QuestieCombatQueue:Queue(function()
            QuestieTracker:Update()
        end)
    end)
end

function TrackerBaseFrame.OnDragStop(frame, button)
    if IsShiftKeyDown() or IsAltKeyDown() then
        Questie:Debug(Questie.DEBUG_DEVELOP, "[TrackerBaseFrame:OnDragStop] - Shift key or alt key detected! --> Exiting.")
        return
    else
        if TrackerBaseFrame.isMoving ~= true or TrackerBaseFrame.isSizing == true then
            Questie:Debug(Questie.DEBUG_DEVELOP, "[TrackerBaseFrame:OnDragStop] - Frame isn't moving or frame is resizing! --> Exiting.")
            return
        end
    end

    if TrackerBaseFrame.isMoving ~= false and TrackerBaseFrame.isSizing ~= true then
        Questie:Debug(Questie.DEBUG_DEVELOP, "[TrackerBaseFrame:OnDragStop] - Dragging Stopped.")

        TrackerBaseFrame.isMoving = false
        TrackerBaseFrame.baseFrame.isMoving = false

        baseFrame:StopMovingOrSizing()
        QuestieCombatQueue:Queue(_UpdateTrackerPosition)
    end
end

---@param button string @The mouse button that is pressed when resize starts
function TrackerBaseFrame.OnResizeStart(frame, button)
    if GameTooltip:IsShown() then
        GameTooltip:Hide()
        GameTooltip._SizerToolTip = nil
    end

    if InCombatLockdown() or IsShiftKeyDown() or IsAltKeyDown() then
        Questie:Debug(Questie.DEBUG_DEVELOP, "[TrackerBaseFrame:OnResizeStart] - In Combat or shift key or alt key detected! --> Exiting.")
        return
    else
        if (IsControlKeyDown() and Questie.db.global.trackerLocked and not ChatEdit_GetActiveWindow()) or not Questie.db.global.trackerLocked then
            if TrackerBaseFrame.isSizing ~= false or TrackerBaseFrame.isMoving == true then
                Questie:Debug(Questie.DEBUG_DEVELOP, "[TrackerBaseFrame:OnResizeStart] - Frame is already resizing or frame is moving! --> Exiting.")
                return
            end
        else
            Questie:Debug(Questie.DEBUG_DEVELOP, "[TrackerBaseFrame:OnResizeStart] - Tracker is Locked. Use CTRL Key. --> Exiting.")
            return
        end
    end

    if TrackerBaseFrame.isSizing ~= true and TrackerBaseFrame.isMoving ~= true then
        if IsMouseButtonDown(button) and button ~= "MiddleButton" then
            if (IsControlKeyDown() and Questie.db.global.trackerLocked and not ChatEdit_GetActiveWindow()) or not Questie.db.global.trackerLocked then
                if baseFrame:IsResizable() then
                    if button == "LeftButton" then
                        Questie:Debug(Questie.DEBUG_DEVELOP, "[TrackerBaseFrame:OnResizeStart] - Sizing Started.")
                        TrackerBaseFrame.isSizing = true
                        TrackerBaseFrame.baseFrame.isSizing = true

                        updateTimer = C_Timer.NewTicker(0.12, function()
                            local QuestieTrackerLoc = Questie.db[Questie.db.global.questieTLoc].TrackerLocation

                            Questie.db[Questie.db.global.questieTLoc].TrackerWidth = baseFrame:GetWidth()
                            Questie.db[Questie.db.global.questieTLoc].TrackerHeight = baseFrame:GetHeight()

                            -- This keeps the trackers SetPoint "clamped" to the players desired location
                            -- while the tracker lines expand and shrink due to Text Wrapping.
                            baseFrame:StopMovingOrSizing()
                            baseFrame:ClearAllPoints()
                            baseFrame:SetPoint(QuestieTrackerLoc[1], QuestieTrackerLoc[2], QuestieTrackerLoc[3], QuestieTrackerLoc[4], QuestieTrackerLoc[5])
                            ------------------------------------------------------------------------------

                            -- This switches ON the Tracker Background and Border and switches OFF
                            -- the Tracker Fader to make it easier to see the Trackers boundaries.
                            Questie.db.global.trackerBackdropEnabled = true
                            Questie.db.global.trackerBorderEnabled = true
                            Questie.db.global.trackerBackdropFader = false
                            ------------------------------------------------------------------------------

                            if QuestieTrackerLoc and (QuestieTrackerLoc[1] == "BOTTOMLEFT" or QuestieTrackerLoc[1] == "BOTTOMRIGHT") then
                                baseFrame:StartSizing("TOPRIGHT")
                            else
                                baseFrame:StartSizing("BOTTOMRIGHT")
                            end

                            QuestieTracker:Update()
                        end)
                    end
                else
                    Questie:Debug(Questie.DEBUG_DEVELOP, "[TrackerBaseFrame:OnResizeStart] - Frame is not resizable!")
                end

                if button == "RightButton" then
                    Questie:Debug(Questie.DEBUG_DEVELOP, "[TrackerBaseFrame:OnResizeStart] - Resetting Sizer mode.")
                    Questie.db[Questie.db.global.questieTLoc].TrackerWidth = 0
                    Questie.db[Questie.db.global.questieTLoc].TrackerHeight = 0
                end
            end
        end
    end
end

---@param button string @The mouse button that is pressed when resize stops
function TrackerBaseFrame.OnResizeStop(frame, button)
    if IsShiftKeyDown() or IsAltKeyDown() then
        Questie:Debug(Questie.DEBUG_DEVELOP, "[TrackerBaseFrame:OnResizeStop] - Shift key or alt key detected! --> Exiting.")
        return
    else
        if TrackerBaseFrame.isSizing ~= true or TrackerBaseFrame.isMoving == true then
            if button == "LeftButton" or button == "MiddleButton" then
                Questie:Debug(Questie.DEBUG_DEVELOP, "[TrackerBaseFrame:OnResizeStop] - Frame isn't resizing or frame is moving! --> Exiting.")
                return
            end

            if button == "RightButton" then
                Questie:Debug(Questie.DEBUG_DEVELOP, "[TrackerBaseFrame:OnResizeStop] - Sizer mode reset. Updating Tracker.")

                QuestieCombatQueue:Queue(function()
                    QuestieTracker:Update()
                end)
                return
            end
        end
    end

    if TrackerBaseFrame.isSizing ~= false and TrackerBaseFrame.isMoving ~= true then
        Questie:Debug(Questie.DEBUG_DEVELOP, "[TrackerBaseFrame:OnResizeStop] - Sizing Stopped.")

        TrackerBaseFrame.isSizing = false
        TrackerBaseFrame.baseFrame.isSizing = false

        -- This returns the players desired Background, Border and Fader to the correct setting
        Questie.db.global.trackerBackdropEnabled = Questie.db.global.currentBackdropEnabled
        Questie.db.global.trackerBorderEnabled = Questie.db.global.currentBorderEnabled
        Questie.db.global.trackerBackdropFader = Questie.db.global.currentBackdropFader

        baseFrame:StopMovingOrSizing()
        updateTimer:Cancel()
        QuestieCombatQueue:Queue(_UpdateTrackerPosition)
    end
end
