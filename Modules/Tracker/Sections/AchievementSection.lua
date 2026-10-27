---@class AchievementSection
local AchievementSection = QuestieLoader:CreateModule("AchievementSection")

---@type TrackerLayout
local TrackerLayout = QuestieLoader:ImportModule("TrackerLayout")
---@type TrackerLinePool
local TrackerLinePool = QuestieLoader:ImportModule("TrackerLinePool")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

---@param trackedAchievementIds table<number, boolean>
function AchievementSection.Draw(trackedAchievementIds)
    local margins = TrackerLayout.GetMargins()
    local objectiveColor = Questie.db.profile.trackerColorObjectives
    local line, zoneCheck

    -- Begin populating the tracker with tracked achievements - Note: We're limited to tracking only 10 Achievements at a time.
    -- For all intents and purposes at a code level we're going to treat each tracked Achievement the same way we treat and add Quests. This loop is
    -- necessary to keep separate from the above tracked Quests loop so we can place all tracked Achievements into it's own "Zone" called Achievements.
    -- This will force Achievements to always appear at the bottom of the tracker. Obviously it'll show at the top if there are no quests being tracked.
    local firstAchieveInZone = false
    local achieveId, achieveName, achieveDescription, achieveComplete, numCriteria, zoneName, achieve

    for trackedId, _ in pairs(trackedAchievementIds) do
        achieveId, achieveName, _, _, _, _, _, achieveDescription, _, _, _, _, achieveComplete, _, _ = GetAchievementInfo(trackedId)
        numCriteria = GetAchievementNumCriteria(trackedId)
        zoneName = "Achievements"

        ---@class Achievement
        achieve = {
            Id = achieveId,
            Name = achieveName,
            Description = achieveDescription
        }

        if achieveId and (not achieveComplete) and trackedAchievementIds[achieveId] == true then
            -- Add Achievement Zone
            if zoneCheck ~= zoneName then
                firstAchieveInZone = true
            end

            if firstAchieveInZone then
                line = TrackerLinePool.GetZoneLine(zoneName)
                if not line then break end

                -- Set Zone Title and Min/Max states
                if Questie.db.char.collapsedZones[zoneName] then
                    line.expandZone:SetMode(0)
                    local text = zoneName == "Achievements" and l10n("Achievements") or zoneName
                    line.label:SetText("|cFFC0C0C0" .. text .. " +|r")
                else
                    line.expandZone:SetMode(1)
                    local text = zoneName == "Achievements" and l10n("Achievements") or zoneName
                    line.label:SetText("|cFFC0C0C0" .. text .. ": " .. GetNumTrackedAchievements(true) .. "/10|r")
                end

                -- Checks the minAllQuestsInZone[zone] table and if empty, zero out the table.
                if Questie.db.char.minAllQuestsInZone[zoneName] ~= nil and not Questie.db.char.minAllQuestsInZone[zoneName].isTrue and not Questie.db.char.collapsedZones[zoneName] then
                    local minQuestIdCount = 0
                    for minQuestId, _ in pairs(Questie.db.char.minAllQuestsInZone[zoneName]) do
                        if type(minQuestId) == "number" then
                            minQuestIdCount = minQuestIdCount + 1
                        end
                    end

                    if minQuestIdCount == 0 then
                        Questie.db.char.minAllQuestsInZone[zoneName] = nil
                    end
                end

                -- Check and measure Zone Label text width and update tracker width
                TrackerLayout.UpdateWidth(line.label:GetUnboundedStringWidth() + margins.left + margins.right)

                -- Set Zone Label and Line widths
                line.label:SetWidth(TrackerLayout.GetBaseFrameWidth() - margins.left - margins.right)
                line:SetWidth(line.label:GetWidth())

                -- Compare largest text Label in the tracker with current Label, then save widest width
                TrackerLayout.TrackLineWidth(line.label:GetUnboundedStringWidth() + margins.left)

                -- Setup Min/Max Button
                line.expandZone:ClearAllPoints()
                line.expandZone:SetPoint("TOPLEFT", line.label, "TOPLEFT", 0, 0)
                line.expandZone:SetWidth(line.label:GetWidth())
                line.expandZone:SetHeight(line.label:GetHeight())
                line.expandZone:Show()

                -- Adds 4 pixels between Zone and first Achievement Title
                line:SetHeight(line.label:GetHeight() + 4)

                -- Set Zone states
                line:Show()
                line.label:Show()
                line.Quest = nil
                line.Objective = nil
                firstAchieveInZone = false
                zoneCheck = zoneName
            end

            -- Add Achievements
            if (not Questie.db.char.collapsedZones[zoneName]) then
                line = TrackerLinePool.GetAchievementTitleLine(achieve, margins.quest)
                if not line then break end

                -- Set Min/Max Button and default states
                line.expandQuest:Show()
                line.expandQuest:SetPoint("TOPRIGHT", line, "TOPLEFT", margins.quest - 8, 1)
                line.expandQuest.zoneId = zoneName

                -- The minAllQuestsInZone table is always blank until a player Shift+Clicks the Zone header (MouseDown).
                -- QuestieTracker:Update is triggered and the table is then filled with all Achievement ID's in the same Zone.
                if Questie.db.char.minAllQuestsInZone[zoneName] ~= nil and Questie.db.char.minAllQuestsInZone[zoneName].isTrue then
                    Questie.db.char.minAllQuestsInZone[zoneName][achieve.Id] = true
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

                -- Add achievement Objective (if applicable)
                if (not Questie.db.char.collapsedQuests[achieve.Id]) then
                    -- Achievements with no number criteria
                    if numCriteria == 0 then
                        line = TrackerLinePool.GetAchievementObjectiveLine(achieve, margins.objective)
                        if not line then break end

                        -- Set Objective text
                        local objDesc = achieve.Description:gsub("%.$", "")
                        line.label:SetText(QuestieLib:GetRGBForObjective({Collected = 0, Needed = 1}) .. objDesc)
                        TrackerLayout.UpdateLineWidth(line, margins.objective)

                        -- Set Objective state
                        line:Show()
                        line.label:Show()
                    end

                    -- Achievements with number criteria
                    for objCriteria = 1, numCriteria do
                        local criteriaString, _, completed, quantityProgress, quantityNeeded, _, _, refId, quantityString = GetAchievementCriteriaInfo(
                            achieve.Id, objCriteria)
                        if ((Questie.db.profile.hideCompletedAchieveObjectives) and (not completed)) or (not Questie.db.profile.hideCompletedAchieveObjectives) then
                            local achievementCopy = achieve
                            if refId and select(2, GetAchievementInfo(refId)) == criteriaString and ((GetAchievementInfo(refId) and refId ~= 0) or (refId > 0 and (not QuestieDB.GetQuest(refId)))) then
                                -- Sometimes stand alone trackable Achievements are part of a group of Achievements under a parent Achievement.
                                -- E.g. "Champion of the Horde" from the Argent Tournament
                                achievementCopy = {
                                    Id = refId
                                }
                            end

                            line = TrackerLinePool.GetAchievementObjectiveLine(achievementCopy, margins.objective)
                            if not line then break end

                            -- Set Objective label based on state
                            if (criteriaString == "") then
                                criteriaString = achieve.Description:gsub("%.$", "")
                            end

                            local objDesc = criteriaString:gsub("%.$", "")

                            -- Set Objectives with more than one Objective number criteria
                            if not (completed or quantityNeeded == 1 or quantityProgress == quantityNeeded) then
                                if string.find(quantityString, "|") then
                                    quantityString = quantityString:gsub("/%s?", "/")
                                else
                                    quantityString = quantityProgress .. "/" .. quantityNeeded
                                end

                                local lineEnding = tostring(quantityString)

                                -- Set Objective text
                                line.label:SetText(QuestieLib:GetRGBForObjective({Collected = quantityProgress, Needed = quantityNeeded}) ..
                                    objDesc .. ": " .. lineEnding)

                                -- Check and measure Objective text width and update tracker width
                                TrackerLayout.UpdateWidth(line.label:GetUnboundedStringWidth() + margins.objective + margins.right)

                                -- Set Label width
                                line.label:SetWidth(TrackerLayout.GetBaseFrameWidth() - margins.objective - margins.right)

                                -- Split Objective description and Progress/Needed into seperate lines
                                if (TrackerLayout.GetLineWidth() < line.label:GetUnboundedStringWidth() + margins.objective) and (line.label:GetWidth() < line.label:GetUnboundedStringWidth() + 5) then
                                    -- Set Objective text
                                    line.label:SetText(QuestieLib:GetRGBForObjective({Collected = quantityProgress, Needed = quantityNeeded}) ..
                                        objDesc .. ": ")

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
                                    if not line then break end

                                    -- Set Objective text
                                    line.label:SetText(QuestieLib:GetRGBForObjective({Collected = quantityProgress, Needed = quantityNeeded}) ..
                                        "    > " .. lineEnding)

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
                                if completed then
                                    line.label:SetText(QuestieLib:GetRGBForObjective({Collected = 1, Needed = 1}) .. objDesc)
                                else
                                    line.label:SetText(QuestieLib:GetRGBForObjective({Collected = 0, Needed = 1}) .. objDesc)
                                end

                                -- Set Objective criteria mark
                                if not Questie.db.profile.hideCompletedAchieveObjectives and (not objectiveColor or objectiveColor == "white") then
                                    line.criteriaMark:SetCriteria(completed)

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
                if not line then
                    line = TrackerLinePool.GetLastLine()
                end

                -- Adds 2 pixels and "Padding Between Quests" setting in Tracker Options
                line:SetHeight(line.label:GetHeight() + (Questie.db.profile.trackerQuestPadding + 2))
            end
        end
    end
end
