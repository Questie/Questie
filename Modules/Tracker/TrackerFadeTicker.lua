---@class TrackerFadeTicker
local TrackerFadeTicker = QuestieLoader:CreateModule("TrackerFadeTicker")
-------------------------
--Import QuestieTracker modules.
-------------------------
---@type TrackerUtils
local TrackerUtils = QuestieLoader:ImportModule("TrackerUtils")
---@type TrackerLinePool
local TrackerLinePool = QuestieLoader:ImportModule("TrackerLinePool")

local fadeTicker
local fadeTickerDirection
local fadeTickerValue = 0
local fadeTickerStarted = false
local trackerBaseFrame, trackerHeaderFrame

local function _SetTrackerAlpha(alpha)
    if Questie.db.profile.trackerFadeTracker then
        trackerBaseFrame:SetAlpha(math.min(1, alpha))
    end
end

function TrackerFadeTicker.Initialize(baseFrame, headerFrame)
    trackerBaseFrame = baseFrame
    trackerHeaderFrame = headerFrame
    _SetTrackerAlpha(0)
    fadeTickerValue = 0
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
                    _SetTrackerAlpha(fadeTickerValue * 3.3)

                    -- Un-fade the background and border(if enabled)
                    if (Questie.db.char.isTrackerExpanded and Questie.db.profile.trackerBackdropEnabled and Questie.db.profile.trackerBackdropFader) then
                        local c = Questie.db.profile.trackerBackdropColor
                        trackerBaseFrame:SetBackdropColor(c.r, c.g, c.b, math.min(c.a, fadeTickerValue * 3.3))
                        if Questie.db.profile.trackerBorderEnabled then
                            trackerBaseFrame:SetBackdropBorderColor(1, 1, 1, math.min(c.a, fadeTickerValue * 3.3))
                        end
                    end

                    -- Un-fade the Questie Icon
                    if (Questie.db.char.isTrackerExpanded and not Questie.db.profile.trackerHeaderEnabled) then
                        trackerHeaderFrame.questieIcon:SetAlpha(fadeTickerValue * 3.3)
                    end

                    -- Un-fade the re-sizer
                    if (Questie.db.char.isTrackerExpanded and not Questie.db.profile.sizerHidden) then
                        trackerBaseFrame.sizer:SetAlpha(fadeTickerValue * 3.3)
                    end

                    -- Un-fade the minimize buttons
                    if (Questie.db.char.isTrackerExpanded and Questie.db.profile.trackerFadeMinMaxButtons) then
                        TrackerLinePool.SetAllExpandQuestAlpha(fadeTickerValue * 3.3)
                    end

                    -- Un-fade the quest focus buttons
                    if (Questie.db.char.isTrackerExpanded and Questie.db.profile.trackerFadeQuestFocusButtons) then
                        TrackerLinePool.SetAllQuestFocusAlpha(fadeTickerValue * 3.3)
                    end

                    -- Un-fade the quest item buttons
                    if (Questie.db.char.isTrackerExpanded and Questie.db.profile.trackerFadeQuestItemButtons) then
                        TrackerLinePool.SetAllItemButtonAlpha(fadeTickerValue * 3.3)
                    end
                else
                    _SetTrackerAlpha(1)
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
                    _SetTrackerAlpha(fadeTickerValue * 3.3)

                    -- Fade the background and border(if enabled)
                    if (Questie.db.char.isTrackerExpanded and Questie.db.profile.trackerBackdropEnabled and Questie.db.profile.trackerBackdropFader) then
                        local c = Questie.db.profile.trackerBackdropColor
                        trackerBaseFrame:SetBackdropColor(c.r, c.g, c.b, math.min(c.a, fadeTickerValue * 3.3))
                        if Questie.db.profile.trackerBorderEnabled then
                            trackerBaseFrame:SetBackdropBorderColor(1, 1, 1, math.min(c.a, fadeTickerValue * 3.3))
                        end
                    end

                    -- Fade the Questie Icon
                    if (Questie.db.char.isTrackerExpanded and not Questie.db.profile.trackerHeaderEnabled) then
                        trackerHeaderFrame.questieIcon:SetAlpha(fadeTickerValue * 3.3)
                    end

                    -- Fade the re-sizer
                    if (Questie.db.char.isTrackerExpanded and not Questie.db.profile.sizerHidden) then
                        trackerBaseFrame.sizer:SetAlpha(fadeTickerValue * 3.3)
                    end

                    -- Fade the minimize buttons
                    if (Questie.db.char.isTrackerExpanded and Questie.db.profile.trackerFadeMinMaxButtons) then
                        TrackerLinePool.SetAllExpandQuestAlpha(fadeTickerValue * 3.3)
                    end

                    -- Fade the quest focus buttons
                    if (Questie.db.char.isTrackerExpanded and Questie.db.profile.trackerFadeQuestFocusButtons) then
                        TrackerLinePool.SetAllQuestFocusAlpha(fadeTickerValue * 3.3)
                    end

                    -- Fade the quest item buttons
                    if (Questie.db.char.isTrackerExpanded and Questie.db.profile.trackerFadeQuestItemButtons) then
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

local function _CanFade()
    return TrackerUtils.HasQuest() or Questie.db.profile.alwaysShowTracker
end

function TrackerFadeTicker.Unfade()
    if _CanFade() then
        fadeTickerDirection = true
        TrackerFadeTicker.Start()
    end
end

function TrackerFadeTicker.Fade()
    if _CanFade() or (trackerBaseFrame and (not trackerBaseFrame:IsShown())) then
        fadeTickerDirection = false
        TrackerFadeTicker.Start()
    end
end
