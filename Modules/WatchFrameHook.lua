---@class WatchFrameHook
local WatchFrameHook = QuestieLoader:CreateModule("WatchFrameHook")

local WatchFrame = WatchFrame

local function _PositionQuestPopUp()
    if WatchFrameAutoQuestPopUp1 then
        WatchFrameAutoQuestPopUp1:ClearAllPoints()
        WatchFrameAutoQuestPopUp1:SetPoint("TOPLEFT", "Questie_BaseFrame", -220, 0)
    end
end

--- Blizzards WatchFrame position resets sometimes, so we move it off screen again
---@param hideWatchFrame boolean @True if the tracker is not shown and the WatchFrame should be hidden
function WatchFrameHook.Reposition(hideWatchFrame)
    if (not Questie.db.profile.trackerEnabled) then
        return
    end

    if hideWatchFrame then
        WatchFrame:Hide()
        return
    end

    -- We move the WatchFrame off screen because:
    -- 1. OnUpdate does not work when hidden
    -- 2. WatchFrameAutoQuestPopUp1 is a child frame and would be hidden as well
    WatchFrame:SetClampedToScreen(false)
    WatchFrame:ClearAllPoints()
    WatchFrame:SetPoint("TOP", "UIParent", -10000, -10000)

    if (not WatchFrame:IsShown()) then
        -- On first load we need a timer because the WatchFrame gets repositioned by Blizzard
        C_Timer.After(0.5, _PositionQuestPopUp)
    else
        _PositionQuestPopUp()
    end

    WatchFrame:Show()
end
