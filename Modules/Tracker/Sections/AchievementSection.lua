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
                        line = LineBuilder.AddObjective({
                            text = QuestieLib:GetRGBForObjective(criteria) .. criteria.Text,
                            clickMode = "achieve",
                            target = achieve,
                        })
                        if (not line) then
                            return
                        end
                    else
                        local target = achieve
                        if criteria.LinkedAchievementId then
                            target = {Id = criteria.LinkedAchievementId}
                        end

                        -- Set Objectives with more than one Objective number criteria
                        if criteria.Progress then
                            line = TrackerLinePool.GetAchievementObjectiveLine(target, margins.objective)
                            if (not line) then
                                break
                            end

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

                            -- Adds 1 pixel between multiple Objectives
                            line:SetHeight(line.label:GetHeight() + 1)

                            -- Set Objective state
                            line:Show()
                            line.label:Show()
                        else
                            -- Set Objectives with a single Objective number criteria
                            line = LineBuilder.AddObjective({
                                text = QuestieLib:GetRGBForObjective(criteria) .. criteria.Text,
                                clickMode = "achieve",
                                target = target,
                            })
                            if (not line) then
                                break
                            end

                            -- Set Objective criteria mark
                            if (not Questie.db.profile.hideCompletedAchieveObjectives) and (not objectiveColor or objectiveColor == "white") then
                                line.criteriaMark:SetCriteria(criteria.Completed)

                                if line.criteriaMark.mode == true then
                                    line.criteriaMark:Show()
                                end
                            end
                        end
                    end
                end
            end

            LineBuilder.FinishEntry(line)
        end
    end
end
