---@class FadeTicker
local FadeTicker = QuestieLoader:CreateModule("FadeTicker")

---@type LinePool
local LinePool = QuestieLoader:ImportModule("LinePool")

local ticker
local fadeTickerDirection = false
local fadeTickerValue = 0

---@param trackerBaseFrame Frame
local function _Start(trackerBaseFrame, highestIndex)
    if (not ticker) and QuestieTracker.started then
        ticker = C_Timer.NewTicker(0.02, function()
            if fadeTickerDirection then
                if fadeTickerValue < 0.3 then
                    fadeTickerValue = fadeTickerValue + 0.02

                    -- Un-fade the background and border(if enabled)
                    if Questie.db.char.isTrackerExpanded and Questie.db.global.trackerBackdropEnabled and Questie.db.global.trackerBackdropFader then
                        trackerBaseFrame:SetBackdropColor(0, 0, 0, math.min(Questie.db.global.trackerBackdropAlpha, fadeTickerValue*3.3))
                        if Questie.db.global.trackerBorderEnabled then
                            trackerBaseFrame:SetBackdropBorderColor(1, 1, 1, math.min(Questie.db.global.trackerBackdropAlpha, fadeTickerValue*3.3))
                        end
                    end

                    -- Un-fade the resizer
                    if Questie.db.char.isTrackerExpanded then
                        trackerBaseFrame.sizer:SetAlpha(fadeTickerValue*3.3)
                    end

                    -- Un-fade the minimize buttons
                    if (Questie.db.char.isTrackerExpanded and Questie.db.global.trackerFadeMinMaxButtons) then
                        for i=1, highestIndex do
                            LinePool.GetLine(i).expandQuest:SetAlpha(fadeTickerValue*3.3)
                        end
                    end

                    -- Un-fade the quest item buttons
                    if (Questie.db.char.isTrackerExpanded and Questie.db.global.trackerFadeQuestItemButtons) then
                        for i=1, highestIndex do
                            local line = LinePool.GetLine(i)
                            if line.button then
                                line.button:SetAlpha(fadeTickerValue*3.3)
                            end
                        end
                    end

                else
                    ticker:Cancel()
                    ticker = nil
                end
            else
                if fadeTickerValue > 0 then
                    fadeTickerValue = fadeTickerValue - 0.02

                    -- Fade the background and border(if enabled)
                    if Questie.db.char.isTrackerExpanded and Questie.db.global.trackerBackdropEnabled and Questie.db.global.trackerBackdropFader then
                        trackerBaseFrame:SetBackdropColor(0, 0, 0, math.min(Questie.db.global.trackerBackdropAlpha, fadeTickerValue*3.3))
                        if Questie.db.global.trackerBorderEnabled then
                            trackerBaseFrame:SetBackdropBorderColor(1, 1, 1, math.min(Questie.db.global.trackerBackdropAlpha, fadeTickerValue*3.3))
                        end
                    end

                    -- Fade the resizer
                    if Questie.db.char.isTrackerExpanded then
                        trackerBaseFrame.sizer:SetAlpha(fadeTickerValue*3.3)
                    end

                    -- Fade the minimuze buttons
                    if (Questie.db.char.isTrackerExpanded and Questie.db.global.trackerFadeMinMaxButtons) then
                        for i=1, highestIndex do
                            LinePool.GetLine(i).expandQuest:SetAlpha(fadeTickerValue*3.3)
                        end
                    end

                    -- Fade the quest item buttons
                    if (Questie.db.char.isTrackerExpanded and Questie.db.global.trackerFadeQuestItemButtons) then
                        for i=1, highestIndex do
                            local line = LinePool.GetLine(i)
                            if line.button then
                                line.button:SetAlpha(fadeTickerValue*3.3)
                            end
                        end
                    end

                else
                    ticker:Cancel()
                    ticker = nil
                end
            end
        end)
    end
end

function FadeTicker.OnEnter()
    fadeTickerDirection = true
    _Start()
end

function FadeTicker.OnLeave()
    fadeTickerDirection = false
    _Start()
end
