---@type QuestieTracker
local QuestieTracker = QuestieLoader:ImportModule("QuestieTracker")
local _QuestieTracker = QuestieTracker.private

---@type QuestieCombatQueue
local QuestieCombatQueue = QuestieLoader:ImportModule("QuestieCombatQueue")
local startDragAnchor = {}
local startDragPos = {}
local endDragPos = {}
local mouselookTicker = {}

function _QuestieTracker:OnDragStart(button)
    Questie:Debug(DEBUG_DEVELOP, "[_QuestieTracker:OnDragStart]", button)
    local baseFrame = QuestieTracker:GetBaseFrame()
    _QuestieTracker.isMoving = true

    if IsControlKeyDown() or not Questie.db.global.trackerLocked then
        startDragAnchor = {baseFrame:GetPoint()}
        baseFrame:SetClampedToScreen(true)
        baseFrame:StartMoving()
        startDragPos = {baseFrame:GetPoint()}
    else
        if not IsMouselooking() then-- this is a HORRIBLE solution, why does MouselookStart have to break OnMouseUp (is there a MOUSE_RELEASED event that always fires?)
            MouselookStart() -- unfortunately, even though we only want to catch right click for a context menu
            -- the only api function we can use is MouselookStart/MouselookStop which replicates the default
            -- right click-drag behavior of also making your player turn :(
                mouselookTicker = C_Timer.NewTicker(0.1, function()
                if not IsMouseButtonDown(button) then
                    MouselookStop()
                    mouselookTicker:Cancel()
                end
            end)
        end
    end
end

function _QuestieTracker:OnDragStop()
    Questie:Debug(DEBUG_DEVELOP, "[_QuestieTracker:OnDragStop]")
    if not startDragPos or not startDragPos[4] or not startDragPos[5] or not endDragPos or not startDragAnchor then
        return
    end
    local baseFrame = QuestieTracker:GetBaseFrame()
    _QuestieTracker.isMoving = false
    endDragPos = {baseFrame:GetPoint()}
    baseFrame:StopMovingOrSizing()


    -- Max X cord values
    local maxLeft = 0
    if endDragPos[4] < maxLeft then
       endDragPos[4] = maxLeft
    end
    local maxRight = GetScreenWidth() - baseFrame:GetWidth()
    if endDragPos[4] > maxRight then
        endDragPos[4] = maxRight
    end

    -- Max Y cord values
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
        startDragPos = nil
    end)
end
