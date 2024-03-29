---@class WatchFrameHook
local WatchFrameHook = QuestieLoader:CreateModule("WatchFrameHook")

local WatchFrame, QuestTimerFrame = WatchFrame, QuestTimerFrame

local function _PositionQuestPopUp()
    if WatchFrameAutoQuestPopUp1 then
        WatchFrameAutoQuestPopUp1:ClearAllPoints()
        WatchFrameAutoQuestPopUp1:SetPoint("TOPLEFT", "Questie_BaseFrame", -220, 0)
    end
end

-- TODO: The WatchFrame is moved very often, when an auto complete quest is active. We need to work around that
-- Timers are not good, because they will flicker the WatchFrame
-- We should recreate WatchFrameAutoQuestPopUp1
-- We can use ShowQuestComplete(GetQuestLogIndexByID(questId)) to show the QuestFrame

--- Blizzards WatchFrame position resets sometimes, so we move it off screen again
function WatchFrameHook.Reposition()
    if (not Questie.db.profile.trackerEnabled) then
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

function WatchFrameHook.Hide()
    if Questie.IsWotlk or Questie.IsCata then
        QuestTimerFrame:Hide()
    end

    WatchFrame:Hide()
end
