---@type QuestieTracker
local QuestieTracker = QuestieLoader:ImportModule("QuestieTracker")
local _QuestieTracker = QuestieTracker.private

local startDragAnchor = {}
local startDragPos = {}
local endDragPos = {}

local mouselookTicker = {}

function _QuestieTracker:OnDragStart(self, button)
    local baseFrame = QuestieTracker:GetBaseFrame()

    if IsControlKeyDown() or not Questie.db.global.trackerLocked then
        startDragAnchor = {baseFrame:GetPoint()}
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
    if not startDragPos or not startDragPos[4] or not startDragPos[5] or not endDragPos or not startDragAnchor then
        return
    end
    local baseFrame = QuestieTracker:GetBaseFrame()

    endDragPos = {baseFrame:GetPoint()}
    baseFrame:StopMovingOrSizing()

    local xMoved = endDragPos[4] - startDragPos[4]
    local yMoved = endDragPos[5] - startDragPos[5]

    startDragAnchor[4] = startDragAnchor[4] + xMoved
    startDragAnchor[5] = startDragAnchor[5] + yMoved

    baseFrame:ClearAllPoints()
    baseFrame:SetPoint(unpack(startDragAnchor))
    Questie.db.char.TrackerLocation = {baseFrame:GetPoint()}
    if Questie.db.char.TrackerLocation[2] and type(Questie.db.char.TrackerLocation[2]) == "table" and Questie.db.char.TrackerLocation[2].GetName then
        Questie.db.char.TrackerLocation[2] = Questie.db.char.TrackerLocation[2]:GetName()
    end
    startDragPos = nil
    -- QuestieTracker:SetBaseFrame(baseFrame)
end

--[[function _QuestieTracker:RepositionFrames(trackerLineCount, lineFrames) -- this is only for SetCounterEnabled, nothing else should be using this function
    local lastFrame = nil
    local baseFrame = QuestieTracker:GetBaseFrame()

    for i=1, trackerLineCount do
        local frm = lineFrames[i]
        if lastFrame then
            frm:SetPoint("TOPLEFT", lastFrame, "BOTTOMLEFT", 0,0)
        else
            local padding = QuestieTracker:GetBackgroundPadding()
            if Questie.db.global.trackerCounterEnabled then
                frm:SetPoint("TOPLEFT", baseFrame, "TOPLEFT", padding, -(padding + QuestieTracker:GetActiveQuestsFrame():GetHeight()))
            else
                frm:SetPoint("TOPLEFT", baseFrame, "TOPLEFT", padding, -padding)
            end
        end
        --frm:Show()
        lastFrame = frm
    end
end]]--
