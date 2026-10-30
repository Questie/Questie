---@class AchievementSection
local AchievementSection = QuestieLoader:CreateModule("AchievementSection")

---@type AchievementTracking
local AchievementTracking = QuestieLoader:ImportModule("AchievementTracking")
---@type TrackerLayout
local TrackerLayout = QuestieLoader:ImportModule("TrackerLayout")
---@type TrackerLinePool
local TrackerLinePool = QuestieLoader:ImportModule("TrackerLinePool")
---@type LineBuilder
local LineBuilder = QuestieLoader:ImportModule("LineBuilder")
---@type TrackerAchievements
local TrackerAchievements = QuestieLoader:ImportModule("TrackerAchievements")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local ZONE_NAME = "Achievements"

function AchievementSection.Draw()
    local margins = TrackerLayout.GetMargins()
    local objectiveColor = Questie.db.profile.trackerColorObjectives
    local line, zoneCheck

    -- Tracked achievements are listed under their own "Zone" called Achievements.
    local firstAchieveInZone = false

    local achievementIds = AchievementTracking.GetTrackedIds()

    for _, achieve in ipairs(TrackerAchievements.GetAchievements(achievementIds)) do
        -- Add Achievement Zone
        if zoneCheck ~= ZONE_NAME then
            firstAchieveInZone = true
        end

        if firstAchieveInZone then
            line = LineBuilder.AddHeader({
                key = ZONE_NAME,
                text = l10n("Achievements") .. ": " .. #achievementIds .. "/" .. AchievementTracking.GetMaxTracked(),
                collapsedText = l10n("Achievements") .. " +",
            })
            if (not line) then
                break
            end

            firstAchieveInZone = false
            zoneCheck = ZONE_NAME
        end

        -- Add Achievements
        if (not Questie.db.char.collapsedZones[ZONE_NAME]) then
            local title = achieve.Name
            if Questie.db.profile.enableTooltipsQuestID then
                title = title .. " (" .. achieve.Id .. ")"
            end

            local collapsed
            line, collapsed = LineBuilder.AddTitle({
                text = title,
                clickMode = "achieve",
                target = achieve,
                collapseId = achieve.Id,
                zoneKey = ZONE_NAME,
            })
            if (not line) then
                break
            end

            -- Add achievement Objectives (if applicable)
            if (not collapsed) then
                for _, criteria in ipairs(achieve.Criteria) do
                    if criteria.IsDescription then
                        -- Achievements without criteria show their description
                        line = TrackerLinePool.GetAchievementObjectiveLine(achieve, margins.objective)
                        if (not line) then
                            return
                        end

                        line.label:SetText(QuestieLib:GetRGBForObjective(criteria) .. criteria.Text)
                        TrackerLayout.UpdateLineWidth(line, margins.objective)

                        -- Set Objective state
                        line:Show()
                        line.label:Show()
                    else
                        local target = achieve
                        if criteria.LinkedAchievementId then
                            target = {Id = criteria.LinkedAchievementId}
                        end

                        line = TrackerLinePool.GetAchievementObjectiveLine(target, margins.objective)
                        if (not line) then
                            break
                        end

                        -- Set Objectives with more than one Objective number criteria
                        if criteria.Progress then
                            -- Set Objective text
                            line.label:SetText(QuestieLib:GetRGBForObjective(criteria) .. criteria.Text .. ": " .. criteria.Progress)

                            -- Check and measure Objective text width and update tracker width
                            TrackerLayout.UpdateWidth(line.label:GetUnboundedStringWidth() + margins.objective + margins.right)

                            -- Set Label width
                            line.label:SetWidth(TrackerLayout.GetBaseFrameWidth() - margins.objective - margins.right)

                            -- Split Objective description and Progress/Needed into seperate lines
                            if (TrackerLayout.GetLineWidth() < line.label:GetUnboundedStringWidth() + margins.objective) and (line.label:GetWidth() < line.label:GetUnboundedStringWidth() + 5) then
                                -- Set Objective text
                                line.label:SetText(QuestieLib:GetRGBForObjective(criteria) .. criteria.Text .. ": ")

                                -- Check and measure Objective text width and update tracker width
                                TrackerLayout.UpdateWidth(line.label:GetUnboundedStringWidth() + margins.objective + margins.right)

                                -- Set Label and Line widths
                                line.label:SetWidth(TrackerLayout.GetBaseFrameWidth() - margins.objective - margins.right)
                                line:SetWidth(line.label:GetWidth() + margins.objective)

                                -- Compare largest text Label in the tracker with current Label, then save widest width
                                TrackerLayout.TrackLineWidth(line.label:GetUnboundedStringWidth() + margins.objective)

                                -- Adds 1 pixel between split Objectives
                                line:SetHeight(line.label:GetHeight() + 1)

                                -- Set Objective state
                                line:Show()
                                line.label:Show()

                                line = TrackerLinePool.GetAchievementObjectiveLine(achieve, margins.objective)
                                if (not line) then
                                    break
                                end

                                -- Set Objective text
                                line.label:SetText(QuestieLib:GetRGBForObjective(criteria) .. "    > " .. criteria.Progress)

                                -- Check and measure Objective text width and update tracker width
                                TrackerLayout.UpdateWidth(line.label:GetUnboundedStringWidth() + margins.objective + margins.right)

                                -- Set Label and Line widths
                                line.label:SetWidth(TrackerLayout.GetBaseFrameWidth() - margins.objective - margins.right)
                                line:SetWidth(line.label:GetWidth() + margins.objective)
                            else
                                -- Set Line widths
                                line:SetWidth(line.label:GetWidth() + margins.objective)

                                -- Compare largest text Label in the tracker with current Label, then save widest width
                                TrackerLayout.TrackLineWidth(line.label:GetUnboundedStringWidth() + margins.objective)
                            end

                            -- Set Objectives with a single Objective number criteria
                        else
                            -- Set Objective text
                            line.label:SetText(QuestieLib:GetRGBForObjective(criteria) .. criteria.Text)

                            -- Set Objective criteria mark
                            if (not Questie.db.profile.hideCompletedAchieveObjectives) and (not objectiveColor or objectiveColor == "white") then
                                line.criteriaMark:SetCriteria(criteria.Completed)

                                if line.criteriaMark.mode == true then
                                    line.criteriaMark:Show()
                                end
                            end

                            -- Check and measure Objective text width and update tracker width
                            TrackerLayout.UpdateWidth(line.label:GetUnboundedStringWidth() + margins.objective + margins.right)

                            -- Set Objective Label and Line widths
                            line.label:SetWidth(TrackerLayout.GetBaseFrameWidth() - margins.objective - margins.right)
                            line:SetWidth(line.label:GetWidth() + margins.objective)

                            -- Compare largest text Label in the tracker with current Label, then save widest width
                            TrackerLayout.TrackLineWidth(line.label:GetUnboundedStringWidth() + margins.objective)
                        end

                        -- Adds 1 pixel between multiple Objectives
                        line:SetHeight(line.label:GetHeight() + 1)

                        -- Set Objective state
                        line:Show()
                        line.label:Show()
                    end
                end
            end

            -- Safety check in case we hit the linePool limit
            if (not line) then
                line = TrackerLinePool.GetLastLine()
            end

            -- Adds 2 pixels and "Padding Between Quests" setting in Tracker Options
            line:SetHeight(line.label:GetHeight() + (Questie.db.profile.trackerQuestPadding + 2))
        end
    end
end
