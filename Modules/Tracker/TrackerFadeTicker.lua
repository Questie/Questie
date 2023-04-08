---@class TrackerFadeTicker
local TrackerFadeTicker = QuestieLoader:CreateModule("TrackerFadeTicker")
-------------------------
--Import QuestieTracker modules.
-------------------------
---@type QuestieTracker
local QuestieTracker = QuestieLoader:ImportModule("QuestieTracker")
---@type TrackerLinePool
local TrackerLinePool = QuestieLoader:ImportModule("TrackerLinePool")

local fadeTicker
local fadeTickerDirection
local fadeTickerValue = 0
local fadeTickerStarted = false
local trackerBaseFrame

function TrackerFadeTicker.Initialize(baseFrame)
    trackerBaseFrame = baseFrame
    fadeTickerStarted = true
    TrackerFadeTicker.Start()
end

function TrackerFadeTicker.Start()
    if (not fadeTicker) and fadeTickerStarted then
        fadeTicker = C_Timer.NewTicker(0.02, function()
            if fadeTickerDirection then
                -- Un-Fade All
                if fadeTickerValue < 0.3 then
                    fadeTickerValue = fadeTickerValue + 0.02

                    -- Un-fade the background and border(if enabled)
                    if (Questie.db.char.isTrackerExpanded and Questie.db.global.trackerBackdropEnabled and Questie.db.global.trackerBackdropFader) then
                        trackerBaseFrame:SetBackdropColor(0, 0, 0, math.min(Questie.db.global.trackerBackdropAlpha, fadeTickerValue * 3.3))
                        if Questie.db.global.trackerBorderEnabled then
                            trackerBaseFrame:SetBackdropBorderColor(1, 1, 1, math.min(Questie.db.global.trackerBackdropAlpha, fadeTickerValue * 3.3))
                        end
                    end

                    -- Un-fade the re-sizer
                    if (Questie.db.char.isTrackerExpanded and not Questie.db.global.sizerHidden) then
                        trackerBaseFrame.sizer:SetAlpha(fadeTickerValue * 3.3)
                    end

                    -- Un-fade the minimize buttons
                    if (Questie.db.char.isTrackerExpanded and Questie.db.global.trackerFadeMinMaxButtons) then
                        TrackerLinePool.SetAllExpandQuestAlpha(fadeTickerValue * 3.3)
                    end

                    -- Un-fade the quest item buttons
                    if (Questie.db.char.isTrackerExpanded and Questie.db.global.trackerFadeQuestItemButtons) then
                        TrackerLinePool.SetAllItemButtonAlpha(fadeTickerValue * 3.3)
                    end
                else
                    fadeTicker:Cancel()
                    fadeTicker = nil
                end
            else
                -- Fade All
                if fadeTickerValue >= 0 then
                    fadeTickerValue = fadeTickerValue - 0.02

                    if fadeTickerValue < 0 then
                        fadeTickerValue = 0
                        fadeTicker:Cancel()
                        fadeTicker = nil
                    end

                    -- Fade the background and border(if enabled)
                    if (Questie.db.char.isTrackerExpanded and Questie.db.global.trackerBackdropEnabled and Questie.db.global.trackerBackdropFader) then
                        trackerBaseFrame:SetBackdropColor(0, 0, 0, math.min(Questie.db.global.trackerBackdropAlpha, fadeTickerValue * 3.3))
                        if Questie.db.global.trackerBorderEnabled then
                            trackerBaseFrame:SetBackdropBorderColor(1, 1, 1, math.min(Questie.db.global.trackerBackdropAlpha, fadeTickerValue * 3.3))
                        end
                    end

                    -- Fade the re-sizer
                    if (Questie.db.char.isTrackerExpanded and not Questie.db.global.sizerHidden) then
                        trackerBaseFrame.sizer:SetAlpha(fadeTickerValue * 3.3)
                    end

                    -- Fade the minimize buttons
                    if (Questie.db.char.isTrackerExpanded and Questie.db.global.trackerFadeMinMaxButtons) then
                        TrackerLinePool.SetAllExpandQuestAlpha(fadeTickerValue * 3.3)
                    end

                    -- Fade the quest item buttons
                    if (Questie.db.char.isTrackerExpanded and Questie.db.global.trackerFadeQuestItemButtons) then
                        TrackerLinePool.SetAllItemButtonAlpha(fadeTickerValue * 3.3)
                    end
                else
                    fadeTickerValue = 0
                    TrackerLinePool.SetAllItemButtonAlpha(0)
                    fadeTicker:Cancel()
                    fadeTicker = nil
                end
            end
        end)
    end
end

function TrackerFadeTicker.OnEnter()
    if QuestieTracker:HasQuest() then
        fadeTickerDirection = true
        TrackerFadeTicker.Start()
    end
end

function TrackerFadeTicker.OnLeave()
    if QuestieTracker:HasQuest() then
        fadeTickerDirection = false
        TrackerFadeTicker.Start()
    end
end
