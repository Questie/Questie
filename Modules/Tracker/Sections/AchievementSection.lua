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
            line = TrackerLinePool.GetAchievementTitleLine(achieve, margins.quest)
            if (not line) then
                break
            end

            -- Set Min/Max Button and default states
            line.expandQuest:Show()
            line.expandQuest:SetPoint("TOPRIGHT", line, "TOPLEFT", margins.quest - 8, 1)
            line.expandQuest.zoneId = ZONE_NAME

            -- The minAllQuestsInZone table is always blank until a player Shift+Clicks the Zone header (MouseDown).
            -- QuestieTracker:Update is triggered and the table is then filled with all Achievement ID's in the same Zone.
            if Questie.db.char.minAllQuestsInZone[ZONE_NAME] ~= nil and Questie.db.char.minAllQuestsInZone[ZONE_NAME].isTrue then
                Questie.db.char.minAllQuestsInZone[ZONE_NAME][achieve.Id] = true
            end

            -- Handles all the Min/Max behavior individually for each Achievement.
            if Questie.db.char.collapsedQuests[achieve.Id] then
                line.expandQuest:SetMode(0)
            else
                line.expandQuest:SetMode(1)
            end

            -- Set Achievement Title
            if Questie.db.profile.enableTooltipsQuestID then
                line.label:SetText("|cFFFFFF00" .. achieve.Name .. " (" .. achieve.Id .. ")|r")
            else
                line.label:SetText("|cFFFFFF00" .. achieve.Name .. "|r")
            end

            -- Check and measure Achievement Label text width and update tracker width
            TrackerLayout.UpdateWidth(line.label:GetUnboundedStringWidth() + margins.quest + margins.right)

            -- Set Achievement Label and Line widths
            line.label:SetWidth(TrackerLayout.GetBaseFrameWidth() - margins.quest - margins.right)
            line:SetWidth(line.label:GetWidth() + margins.quest)

            -- Compare largest text Label in the tracker with current Label, then save widest width
            TrackerLayout.TrackLineWidth(line.label:GetUnboundedStringWidth() + margins.quest)

            -- Adds 4 pixels between Achievement Title and first Objective
            line:SetHeight(line.label:GetHeight() + 4)

            -- Set Achievement states
            line:Show()
            line.label:Show()

            -- Add achievement Objectives (if applicable)
            if (not Questie.db.char.collapsedQuests[achieve.Id]) then
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
