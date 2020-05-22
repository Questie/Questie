---@type QuestieTracker
local QuestieTracker = QuestieLoader:ImportModule("QuestieTracker")
local _QuestieTracker = QuestieTracker.private

---@type QuestieCombatQueue
local QuestieCombatQueue = QuestieLoader:ImportModule("QuestieCombatQueue")

local startDragAnchor = {}
local startDragPos = {}
local endDragPos = {}
local preSetPoint = nil

local mouselookTicker = {}

function _QuestieTracker:OnDragStart(button)
    Questie:Debug(DEBUG_DEVELOP, "[_QuestieTracker:OnDragStart]", button)
    local baseFrame = QuestieTracker:GetBaseFrame()

    if IsMouseButtonDown(button) then
        if IsControlKeyDown() or not Questie.db.global.trackerLocked then
            _QuestieTracker.isMoving = true
            startDragAnchor = {baseFrame:GetPoint()}
            preSetPoint = ({baseFrame:GetPoint()})[1]
            baseFrame:SetClampedToScreen(true)
            baseFrame:StartMoving()
            startDragPos = {baseFrame:GetPoint()}
            _QuestieTracker.baseFrame.sizer:SetAlpha(1)
        else
            -- This is a HORRIBLE solution, why does MouselookStart have to break OnMouseUp (is there a
            -- MOUSE_RELEASED event that always fires?) Unfortunately, even though we only want to
            -- catch right click for a context menu. The only api function we can use is MouselookStart
            -- and MouselookStop which replicates the default right click-drag behavior of also making
            -- your player turn :(
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

function _QuestieTracker:OnDragStop(button)
    Questie:Debug(DEBUG_DEVELOP, "[_QuestieTracker:OnDragStop]", button)

    if IsMouseButtonDown(button) or not startDragPos or not startDragPos[4] or not startDragPos[5] or not endDragPos or not startDragAnchor then
        return
    end

    local baseFrame = QuestieTracker:GetBaseFrame()
    _QuestieTracker.isMoving = false
    endDragPos = {baseFrame:GetPoint()}
    baseFrame:StopMovingOrSizing()

    -----------------------------------------------------------------------------------------------
    -- Since frame:SetClampedToScreen() only applies to frames, the end X,Y values can potentially
    -- traverse off the players screen and cause weird anomalies such as frame "snapping" where
    -- values from screen edge and (mouse pointer/frame set point) end locations can be located
    -- beyond the players screen values. The following checks simply subtracts those values keeping
    -- the end point setting inside the players screen boundaries, thus preventing frame "snapping"
    -- from ever occurring. Screen coords are calculated based on the relativePoint of the frame.
    --
    -- Before frame:StartMoving() is called the relativePoint of frame:GetPoint() is, in Questie's
    -- case, "CENTER", so (-x, -y) values would be in the "BOTTOMLEFT" area of the players screen.
    --
    -- After frame:StartMoving() or frame:StopMovingOrSizing() is called the relativePoint of
    -- frame:GetPoint() is, in Questie's case, "TOPLEFT", so (0, 0) values would set the frame in
    -- the "TOPLEFT" most corner of the players screen.
    -----------------------------------------------------------------------------------------------

    -- Trim X end cords
    local maxLeft = 0
    if endDragPos[4] < maxLeft then
       endDragPos[4] = maxLeft
    end

    local maxRight = GetScreenWidth() - baseFrame:GetWidth()
    if endDragPos[4] > maxRight then
        endDragPos[4] = maxRight
    end

    -- Trim Y end cords
    local maxBottom = -GetScreenHeight() - -baseFrame:GetHeight()
    if endDragPos[5] < maxBottom then
        endDragPos[5] = maxBottom
    end

    local maxTop = 0
    if endDragPos[5] > maxTop then
        endDragPos[5] = maxTop
    end

    local xMoved = endDragPos[4] - startDragPos[4]
    local yMoved = endDragPos[5] - startDragPos[5]

    startDragAnchor[4] = startDragAnchor[4] + xMoved
    startDragAnchor[5] = startDragAnchor[5] + yMoved

    QuestieCombatQueue:Queue(function()
        baseFrame:ClearAllPoints()
        baseFrame:SetPoint(unpack(startDragAnchor))
        Questie.db.char.TrackerLocation = {baseFrame:GetPoint()}

        if Questie.db.char.TrackerLocation[2] and type(Questie.db.char.TrackerLocation[2]) == "table" and Questie.db.char.TrackerLocation[2].GetName then
            Questie.db.char.TrackerLocation[2] = Questie.db.char.TrackerLocation[2]:GetName()
        end

        -------------------------------------------------------------------------------------------
        -- Automatically converts screen cords system from TOPRIGHT/MinimapCluster/BOTTOMRIGHT
        -- setPoint to [CUSTOM]/UIParent/CENTER based on where the user drags the tracker. This is
        -- only run upon first load or if at some point the Tracker Location becomes corrupted,
        -- reset or is pcall() and reattached to the QuestWatchFrame. Once this startup is complete
        -- it falls down to ELSEIF. This is neccessary for the "Auto SetPoint" setting to work
        -- properly because if the user overrides the default and manually sets a setPoint then
        -- decides to reset back to Auto, the easiest setPoint to manage is "UIParent/CENTER" which
        -- works flawlessly across all reset scenarios. While in Auto mode the setPoint is
        -- 'silently' applied based on tracker position. If the user has set a specific setPoint
        -- then it passes both IF and ELSEIF, sets the setPoint value based on user preference and
        -- then exits the function.
        -------------------------------------------------------------------------------------------

        -- This section "detatches" the tracker from the Minimapcluster and converts x,y to "CENTER"
        if Questie.db.char.TrackerLocation and Questie.db.char.TrackerLocation[2] and Questie.db.char.TrackerLocation[2] == "MinimapCluster" and Questie.db.char.trackerSetpoint == "AUTO" then
            local vertOffset = ({MinimapCluster:GetPoint()})[5] - MinimapCluster:GetHeight()
            local maxWidth = -GetScreenWidth()/2
            local maxHeight = -GetScreenHeight()/2 - vertOffset
            local trackerHeight = baseFrame:GetHeight()
            local trackerWidth = baseFrame:GetWidth()

            -- setPoint Topleft = Down and Right
            if Questie.db.char.TrackerLocation[4] < maxWidth and Questie.db.char.TrackerLocation[5] > maxHeight then
                Questie.db.char.TrackerLocation[1] = "TOPLEFT"
                Questie.db.char.TrackerLocation[4] = Questie.db.char.TrackerLocation[4] - maxWidth - trackerWidth
                Questie.db.char.TrackerLocation[5] = Questie.db.char.TrackerLocation[5] - maxHeight

            -- setPoint Topright = Down and Left
            elseif Questie.db.char.TrackerLocation[4] > maxWidth and Questie.db.char.TrackerLocation[5] > maxHeight then
                Questie.db.char.TrackerLocation[1] = "TOPRIGHT"
                Questie.db.char.TrackerLocation[4] = Questie.db.char.TrackerLocation[4] + -maxWidth
                Questie.db.char.TrackerLocation[5] = Questie.db.char.TrackerLocation[5] + -maxHeight

            -- setPoint Bottomleft = Up and Right
            elseif Questie.db.char.TrackerLocation[4] < maxWidth and Questie.db.char.TrackerLocation[5] < maxHeight then
                Questie.db.char.TrackerLocation[1] = "BOTTOMLEFT"
                Questie.db.char.TrackerLocation[4] = Questie.db.char.TrackerLocation[4] - maxWidth - trackerWidth
                Questie.db.char.TrackerLocation[5] = Questie.db.char.TrackerLocation[5] - maxHeight - trackerHeight

            -- setPoint Bottomright = Up and Left
            elseif Questie.db.char.TrackerLocation[4] > maxWidth and Questie.db.char.TrackerLocation[5] < maxHeight then
                Questie.db.char.TrackerLocation[1] = "BOTTOMRIGHT"
                Questie.db.char.TrackerLocation[4] = Questie.db.char.TrackerLocation[4] + -maxWidth
                Questie.db.char.TrackerLocation[5] = Questie.db.char.TrackerLocation[5] + -maxHeight - trackerHeight
            end

            Questie.db.char.TrackerLocation[2] = "UIParent"
            Questie.db.char.TrackerLocation[3] = "CENTER"

            baseFrame:ClearAllPoints()
            baseFrame:SetPoint(unpack(Questie.db.char.TrackerLocation))

        -- This is the section that processes "Auto setPoint" movements between quadrants.
        -- _QuestieTracker:ConvertSetPointCords() converts endpoints so the frame doesn't appear to
        -- shift or "snap" due to changing setPoint values.
        elseif Questie.db.char.TrackerLocation and Questie.db.char.TrackerLocation[2] and Questie.db.char.TrackerLocation[2] == "UIParent" and Questie.db.char.trackerSetpoint == "AUTO" then
            local yAdj = 0
            if baseFrame:GetHeight()/GetScreenHeight() > 0.25 and (Questie.db.char.TrackerLocation[1] == "TOPLEFT" or Questie.db.char.TrackerLocation[1] == "TOPRIGHT") then
                yAdj = baseFrame:GetHeight()/2
            elseif baseFrame:GetHeight()/GetScreenHeight() > 0.25 and (Questie.db.char.TrackerLocation[1] == "BOTTOMLEFT" or Questie.db.char.TrackerLocation[1] == "BOTTOMRIGHT") then
                yAdj = -baseFrame:GetHeight()/2
            elseif baseFrame:GetHeight()/GetScreenHeight() > 0.75 then
                yAdj = baseFrame:GetHeight()
            end

            -- setPoint Topleft = Down and Right
            if Questie.db.char.TrackerLocation[4] < 0 and Questie.db.char.TrackerLocation[5] > yAdj and Questie.db.char.TrackerLocation[1] ~= "TOPLEFT" then
                xOff, yOff = _QuestieTracker:ConvertSetPointCords(baseFrame, "TOPLEFT")
                Questie.db.char.TrackerLocation[1] = "TOPLEFT"
                Questie.db.char.TrackerLocation[4] = xOff
                Questie.db.char.TrackerLocation[5] = yOff

            -- setPoint Topright = Down and Left
            elseif Questie.db.char.TrackerLocation[4] > 0 and Questie.db.char.TrackerLocation[5] > yAdj and Questie.db.char.TrackerLocation[1] ~= "TOPRIGHT" then
                xOff, yOff = _QuestieTracker:ConvertSetPointCords(baseFrame, "TOPRIGHT")
                Questie.db.char.TrackerLocation[1] = "TOPRIGHT"
                Questie.db.char.TrackerLocation[4] = xOff
                Questie.db.char.TrackerLocation[5] = yOff

            -- setPoint Bottomleft = Up and Right
            elseif Questie.db.char.TrackerLocation[4] < 0 and Questie.db.char.TrackerLocation[5] < yAdj and Questie.db.char.TrackerLocation[1] ~= "BOTTOMLEFT" then
                xOff, yOff = _QuestieTracker:ConvertSetPointCords(baseFrame, "BOTTOMLEFT")
                Questie.db.char.TrackerLocation[1] = "BOTTOMLEFT"
                Questie.db.char.TrackerLocation[4] = xOff
                Questie.db.char.TrackerLocation[5] = yOff

            -- setPoint Bottomright = Up and Left
            elseif Questie.db.char.TrackerLocation[4] > 0 and Questie.db.char.TrackerLocation[5] < yAdj and Questie.db.char.TrackerLocation[1] ~= "BOTTOMRIGHT" then
                xOff, yOff = _QuestieTracker:ConvertSetPointCords(baseFrame, "BOTTOMRIGHT")
                Questie.db.char.TrackerLocation[1] = "BOTTOMRIGHT"
                Questie.db.char.TrackerLocation[4] = xOff
                Questie.db.char.TrackerLocation[5] = yOff
            end

            Questie.db.char.TrackerLocation[2] = "UIParent"
            Questie.db.char.TrackerLocation[3] = "CENTER"

            baseFrame:ClearAllPoints()
            baseFrame:SetPoint(unpack(Questie.db.char.TrackerLocation))

        -- When the user sets a manual setPoint it runs QuestieTracker:ResetLocation() which
        -- converts everything over to a [CUSTOM]/UIParent/CENTER centric x,y cords so no pre/post
        -- processing of location data is needed. It's done "as-is".
        elseif Questie.db.char.trackerSetpoint ~= "AUTO" then
            Questie.db.char.TrackerLocation[1] = Questie.db.char.trackerSetpoint
        end

        -- Moves the durability frame based on the tracker setpoint done above
        QuestieTracker:MoveDurabilityFrame()

        startDragPos = nil
        preSetPoint = nil
    end)
end

function _QuestieTracker:ConvertSetPointCords(frame, setpoint)
    -----------------------------------------------------------------------------------------------
    -- Uses exsisting frames setPoints and dimentions to return a new set of cords based on the new
    -- setPoints so the frame doesn't appear to shift or "snap" from it's desired location when the
    -- new setPoints are applied. Inputs are the frame, and desired setpoint.
    -----------------------------------------------------------------------------------------------
    if ({frame:GetPoint()})[2]:GetName() == "UIParent" and setpoint then
        local height = frame:GetHeight()
        local width = frame:GetWidth()
        local setPoint = setpoint
        local xOn = ({frame:GetPoint()})[4]
        local yOn = ({frame:GetPoint()})[5]
        if not (height or width or preSetPoint or xOn or yOn or setPoint or preSetPoint)then return end
        if (setPoint ~= preSetPoint) then

            -- To "TOPLEFT" from...
            if setPoint == "TOPLEFT" then
                if preSetPoint == "TOPRIGHT" then
                    xOff = xOn + -width
                    yOff = yOn
                elseif preSetPoint == "BOTTOMLEFT" then
                    xOff = xOn
                    yOff = yOn + height
                elseif preSetPoint == "BOTTOMRIGHT" then
                    xOff = xOn + -width
                    yOff = yOn + height
                end
                return xOff, yOff

            -- To "TOPRIGHT" from...
            elseif setPoint == "TOPRIGHT" then
                if preSetPoint == "TOPLEFT" then
                    xOff = xOn + width
                    yOff = yOn
                elseif preSetPoint == "BOTTOMLEFT" then
                    xOff = xOn + width
                    yOff = yOn + height
                elseif preSetPoint == "BOTTOMRIGHT" then
                    xOff = xOn
                    yOff = yOn + height
                end
                return xOff, yOff

            -- To "BOTTOMLEFT" from...
            elseif setPoint == "BOTTOMLEFT" then
                if preSetPoint == "TOPRIGHT" then
                    xOff = xOn + -width
                    yOff = yOn + -height
                elseif preSetPoint == "TOPLEFT" then
                    xOff = xOn
                    yOff = yOn + -height
                elseif preSetPoint == "BOTTOMRIGHT" then
                    xOff = xOn + -width
                    yOff = yOn
                end
                return xOff, yOff

            -- To "BOTTOMRIGHT" from...
            elseif setPoint == "BOTTOMRIGHT" then
                if preSetPoint == "TOPRIGHT" then
                    xOff = xOn
                    yOff = yOn + -height
                elseif preSetPoint == "TOPLEFT" then
                    xOff = xOn + width
                    yOff = yOn + -height
                elseif preSetPoint == "BOTTOMLEFT" then
                    xOff = xOn + width
                    yOff = yOn
                end
                return xOff, yOff
            end
        else
            return xOn, yOn
        end
    end
end

function _QuestieTracker:OnResizeStart(button)
    Questie:Debug(DEBUG_DEVELOP, "[_QuestieTracker:OnResizeStart]", button)
    local baseFrame = QuestieTracker:GetBaseFrame()

    if button == "LeftButton" then
        if IsMouseButtonDown(button) then
            if IsControlKeyDown() or not Questie.db.global.trackerLocked then
                _QuestieTracker.isSizing = true
                tempTrackerLocation = {baseFrame:GetPoint()}
                baseFrame:StartSizing("RIGHT")
                _QuestieUpdateTimer = C_Timer.NewTicker(0.1, function()
                    local baseFrame = QuestieTracker:GetBaseFrame()
                    Questie.db.char.TrackerWidth = baseFrame:GetWidth()
                    QuestieTracker:ResetLinesForChange()
                    QuestieTracker:Update()
                end)
            end
        end
    elseif button =="RightButton" then
        Questie.db.char.TrackerWidth = 0
        QuestieTracker:ResetLinesForChange()
        QuestieTracker:Update()
        _QuestieTracker.baseFrame.sizer:SetAlpha(1)
    end
end

function _QuestieTracker:OnResizeStop(button)
    Questie:Debug(DEBUG_DEVELOP, "[_QuestieTracker:OnResizeStop]", button)
    local baseFrame = QuestieTracker:GetBaseFrame()
    if button == "RightButton" or _QuestieTracker.isSizing ~= true then return end
    _QuestieTracker.isSizing = false
    baseFrame:StopMovingOrSizing()
    _QuestieUpdateTimer:Cancel()
    baseFrame:ClearAllPoints()
    baseFrame:SetPoint(unpack(tempTrackerLocation))
end
