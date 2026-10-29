---@class QuestSection
local QuestSection = QuestieLoader:CreateModule("QuestSection")

---@type TrackerLayout
local TrackerLayout = QuestieLoader:ImportModule("TrackerLayout")
---@type TrackerLinePool
local TrackerLinePool = QuestieLoader:ImportModule("TrackerLinePool")
---@type TrackerData
local TrackerData = QuestieLoader:ImportModule("TrackerData")
---@type TrackerUtils
local TrackerUtils = QuestieLoader:ImportModule("TrackerUtils")
---@type TrackerQuestTimers
local TrackerQuestTimers = QuestieLoader:ImportModule("TrackerQuestTimers")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local LSM30 = LibStub("LibSharedMedia-3.0")

---@param sortedQuestIds QuestId[]
---@param questDetails table<QuestId, {quest: TrackerQuest, zoneName: string}>
function QuestSection.Draw(sortedQuestIds, questDetails)
    local margins = TrackerLayout.GetMargins()
    local objectiveMarginLeft
    local objectiveColor = Questie.db.profile.trackerColorObjectives
    local trackerBaseFrame = TrackerLayout.GetBaseFrame()

    local line
    local firstQuestInZone = false
    local zoneCheck

    local secondaryButton = false

    for _, questId in ipairs(sortedQuestIds) do
        if not questId then break end

        -- reset objectiveMarginLeft for each quest, it can be increased if there are quest items
        objectiveMarginLeft = margins.objective

        ---@type TrackerQuest
        local quest = questDetails[questId].quest
        local complete = quest:IsComplete()
        local zoneName = questDetails[questId].zoneName

        TrackerQuestTimers:UpdateAndGetRemainingTime(quest, nil, true)
        local timedQuest = (quest.trackTimedQuest or quest.timedBlizzardQuest)

        if ((complete ~= 1 and not quest.isComplete) or Questie.db.profile.trackerShowCompleteQuests or timedQuest)
            and ((Questie.db.profile.autoTrackQuests and not Questie.db.char.AutoUntrackedQuests[questId])
            or (not Questie.db.profile.autoTrackQuests and Questie.db.char.TrackedQuests[questId])) then
            -- Add Quest Zones
            if zoneCheck ~= zoneName then
                firstQuestInZone = true
            end

            if firstQuestInZone then
                -- Get first line in linePool
                line = TrackerLinePool.GetZoneLine(zoneName)
                if not line then break end

                -- Set Zone Title and default Min/Max states
                if Questie.db.char.collapsedZones[zoneName] then
                    line.expandZone:SetMode(0)
                    line.label:SetText("|cFFC0C0C0" .. zoneName .. " +|r")
                else
                    line.expandZone:SetMode(1)
                    line.label:SetText("|cFFC0C0C0" .. zoneName .. "|r")
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
                line.expandZone:SetPoint("TOPLEFT", line, "TOPLEFT", 0, 0)
                line.expandZone:SetWidth(line.label:GetWidth())
                line.expandZone:SetHeight(line.label:GetHeight())
                line.expandZone:Show()

                -- Adds 4 pixels between Zone and first Quest Title
                line:SetHeight(line.label:GetHeight() + 4)

                -- Set Zone states
                line:Show()
                line.label:Show()
                line.Quest = nil
                line.Objective = nil
                firstQuestInZone = false
                zoneCheck = zoneName
            end

            -- Add quest
            if (not Questie.db.char.collapsedZones[zoneName]) then
                line = TrackerLinePool.GetQuestTitleLine(quest, margins.quest)
                if not line then break end

                -- Set Min/Max Button and default states
                line.expandQuest:SetPoint("TOPRIGHT", line, "TOPLEFT", margins.quest - 8, 1)
                line.expandQuest.zoneId = zoneName

                line.questFocus:SetQuest(quest, complete == 1 or (complete ~= -1 and quest.isComplete == true))

                -- Set Completion Text
                local completionText = TrackerUtils:GetCompletionText(quest)

                -- Clear Blizzard Completion Text
                if (Questie.db.profile.hideBlizzardCompletionText or objectiveColor == "minimal") and (not timedQuest or complete ~= 0) or complete == -1 then
                    completionText = nil
                end

                -- This removes any blank lines from Completion Text
                if completionText ~= nil then
                    if strfind(completionText, "\r\n") then
                        completionText = completionText:gsub("\r\n", "")
                    else
                        completionText = completionText:gsub("(.\r?\n?)\r?\n?", "%1")
                    end

                    -- Completion Text should always be green
                    completionText = "|cFF28FF28" .. completionText
                end

                -- Set minimizable quest flag
                local isMinimizable = (complete == 1 or complete == -1) or (#quest.Objectives == 0 and quest.isComplete == true)

                -- Handles the collapseCompletedQuests option from the Questie Config --> Tracker options.
                if Questie.db.profile.collapseCompletedQuests and isMinimizable and not timedQuest then
                    if not Questie.db.char.collapsedQuests[quest.Id] then
                        Questie.db.char.collapsedQuests[quest.Id] = true
                    end
                else
                    -- The minAllQuestsInZone table is always blank until a player Shift+Clicks the Zone header (MouseDown).
                    -- QuestieTracker:Update is triggered and the table is then filled with all Quest ID's in the same Zone.
                    if Questie.db.char.minAllQuestsInZone[zoneName] ~= nil and Questie.db.char.minAllQuestsInZone[zoneName].isTrue then
                        Questie.db.char.minAllQuestsInZone[zoneName][quest.Id] = true
                    end

                    -- Handles all the Min/Max behavior individually for each quest.
                    if Questie.db.char.collapsedQuests[quest.Id] then
                        line.expandQuest:SetMode(0)
                    else
                        line.expandQuest:SetMode(1)
                    end
                end

                -- Set Quest Title - This handles the "Auto Minimize Completed Quests" option but we don't auto-minimize timed quests.
                local coloredQuestName

                if timedQuest then
                    local showTimedState = isMinimizable and (Questie.db.profile.collapseCompletedQuests or Questie.db.char.collapsedQuests[quest.Id] ~= nil)
                    coloredQuestName = TrackerData.GetColoredQuestName(quest, Questie.db.profile.trackerShowQuestLevel, showTimedState)
                else
                    coloredQuestName = TrackerData.GetColoredQuestName(quest, Questie.db.profile.trackerShowQuestLevel,
                        ((isMinimizable and Questie.db.profile.collapseCompletedQuests) or Questie.db.char.collapsedQuests[quest.Id] ~= nil))
                end

                line.label:SetText(coloredQuestName)

                -- Check and measure Quest Label text width and update tracker width
                TrackerLayout.UpdateWidth(line.label:GetUnboundedStringWidth() + margins.quest + margins.right)

                -- Set Quest Label and Line widths
                line.label:SetWidth(TrackerLayout.GetBaseFrameWidth() - margins.quest - margins.right)
                line:SetWidth(line.label:GetWidth() + margins.quest)

                -- Compare largest text Label in the tracker with current Label, then save widest width
                TrackerLayout.TrackLineWidth(line.label:GetUnboundedStringWidth() + margins.quest)

                -- Adds 4 pixels between Quest Title and first Objective
                line:SetHeight(line.label:GetHeight() + 4)

                -- Adds the AI_VoiceOver Play Buttons
                line.playButton:SetPlayButton(questId)

                local shouldContinue = TrackerUtils.AddQuestItemButtons(quest, complete, line, margins.itemButtonSize, trackerBaseFrame, isMinimizable,
                    function()
                        if (not Questie.db.char.collapsedQuests[quest.Id]) then
                            -- Set and indent Quest Title linePool
                            line.label:ClearAllPoints()
                            line.label:SetPoint("TOPLEFT", line, "TOPLEFT", margins.quest + 2 + margins.itemButtonSize, 0)

                            -- Recheck and Remeasure Quest Label text width and update tracker width
                            TrackerLayout.UpdateWidth(line.label:GetUnboundedStringWidth() + margins.quest + margins.right + margins.itemButtonSize)

                            -- Reset Quest Title Label and linePool widths
                            line.label:SetWidth(TrackerLayout.GetBaseFrameWidth() - margins.quest - margins.right - margins.itemButtonSize)
                            line:SetWidth(line.label:GetWidth() + margins.quest + margins.itemButtonSize)

                            -- Re-compare largest text Label in the tracker with Secondary Button/Quest and current Label, then save widest width
                            TrackerLayout.TrackLineWidth(line.label:GetUnboundedStringWidth() + margins.quest + margins.itemButtonSize)
                        end

                        secondaryButton = true
                    end)

                if (not shouldContinue) then
                    -- We exceeded the button pool
                    break
                end

                -- Set Secondary Quest Item Button Margins (QBC - Quest Button Check)
                local lineLabelWidthQBC, lineLabelBaseFrameQBC, lineWidthQBC
                if secondaryButton then
                    lineLabelWidthQBC = objectiveMarginLeft + margins.right + margins.itemButtonSize
                    lineLabelBaseFrameQBC = objectiveMarginLeft + margins.right + margins.itemButtonSize
                    lineWidthQBC = objectiveMarginLeft + margins.itemButtonSize
                    objectiveMarginLeft = objectiveMarginLeft + margins.itemButtonSize
                else
                    lineLabelWidthQBC = objectiveMarginLeft + margins.right
                    lineLabelBaseFrameQBC = objectiveMarginLeft + margins.right
                    lineWidthQBC = objectiveMarginLeft
                end

                -- Set Quest Line states
                line:Show()
                line.label:Show()

                -- Add Quest Timers (if applicable) - always shown for timed quests, even when collapsed
                if timedQuest then
                    local timerText = nil
                    local activeTimer = false

                    if quest.timedBlizzardQuest then
                        timerText = Questie:Colorize(l10n("Blizzard Timer Active!"), "lightBlue")
                    else
                        local timeRemainingString, timeRemaining = TrackerQuestTimers:GetRemainingTimeByQuestId(quest.Id)
                        if timeRemaining then
                            if timeRemaining <= 1 then
                                timerText = Questie:Colorize(l10n("Time's up!"), "lightBlue")
                            else
                                timerText = Questie:Colorize(timeRemainingString, "lightBlue")
                                activeTimer = true
                            end
                        end
                    end

                    if timerText then
                        line = TrackerLinePool.GetQuestObjectiveLine(quest, nil, lineWidthQBC)
                        if not line then break end

                        -- Set Timer font
                        line.label:SetFont(LSM30:Fetch("font", Questie.db.profile.trackerFontObjective), Questie.db.profile.trackerFontSizeObjective,
                            Questie.db.profile.trackerFontOutline)

                        -- Set Timer Title
                        line.label.activeTimer = activeTimer
                        line.label:SetText(timerText)

                        if activeTimer then
                            TrackerQuestTimers:UpdateAndGetRemainingTime(quest, line, false)
                        end

                        -- Check and measure Timer text width and update tracker width
                        TrackerLayout.UpdateWidth(line.label:GetUnboundedStringWidth() + lineLabelWidthQBC)

                        -- Set Timer Label and Line widths. We add 40 pixels, because timers start with "15 Minutes" and will then be "14 Minutes 59 Seconds" right after.
                        line.label:SetWidth(TrackerLayout.GetBaseFrameWidth() - lineLabelBaseFrameQBC + 40)
                        line:SetWidth(line.label:GetWidth() + lineWidthQBC)

                        -- Compare largest text Label in the tracker with current Label, then save widest width
                        TrackerLayout.TrackLineWidth(line.label:GetUnboundedStringWidth() + lineWidthQBC)

                        line:SetHeight(line.label:GetHeight() + 1)

                        -- Set Timer states
                        line:Show()
                        line.label:Show()
                    end
                end

                -- Add quest Objectives (if applicable)
                if (not Questie.db.char.collapsedQuests[quest.Id]) then
                    -- Add incomplete Quest Objectives
                    if complete == 0 and quest.isComplete ~= true then
                        for _, objective in ipairs(quest.Objectives) do
                            if not Questie.db.profile.hideCompletedQuestObjectives or not objective.Completed then
                                line = TrackerLinePool.GetQuestObjectiveLine(quest, objective, lineWidthQBC)
                                if not line then break end

                                line.questHasSecondaryQIB = secondaryButton

                                -- Sometimes the API returns messy objective data (finished=false, but numRequired==numFulfilled)
                                local questIsIncompleteButObjectiveIsComplete = ((not quest.isComplete) and objective.Completed == true and #quest.Objectives == 1)
                                if (objective.Completed ~= true or (objective.Completed == true and #quest.Objectives > 1) or questIsIncompleteButObjectiveIsComplete) then
                                    line.label:SetText(TrackerData.GetObjectiveText(objective))
                                    TrackerLayout.UpdateLineWidth(line, objectiveMarginLeft)
                                end

                                -- Adds 1 pixel between multiple Objectives
                                line:SetHeight(line.label:GetHeight() + 1)

                                -- Set Objective state
                                line:Show()
                                line.label:Show()
                            end
                        end

                        -- Add complete/failed Quest Objectives and tag them as either complete or failed so as to always have at least one objective.
                        -- Some quests have "Blizzard Completion Text" that is displayed to show where to go next or where to turn in the quest.
                    elseif (complete == 1 or complete == -1 or quest.isComplete == true) and (not (timedQuest and isMinimizable and Questie.db.profile.collapseCompletedQuests)) then
                        line = TrackerLinePool.GetQuestObjectiveLine(quest, nil, lineWidthQBC)
                        if not line then break end

                        -- Set Objective label based on states
                        if ((complete == 1 and completionText ~= nil and #quest.Objectives == 0) or (quest.isComplete == true and completionText ~= nil)) and objectiveColor ~= "minimal" then
                            -- Set Blizzard Completion text for single objectives
                            line.label:SetText(completionText)
                            TrackerLayout.UpdateLineWidth(line, objectiveMarginLeft)

                            -- Hide the Secondary Quest Item Button. There are some quests with usable items after a quest is completed I
                            -- have yet to encounter a completed quest where both a Primary and Secondary "usable" Quest Item was needed.
                            if secondaryButton then
                                line.altButton:SetParent(UIParent)
                                line.altButton:Hide()
                            end
                        else
                            if complete == 1 or (#quest.Objectives == 0 and quest.isComplete == true and completionText == nil and complete ~= -1) then
                                line.label:SetText(Questie:Colorize(l10n("Quest Complete!"), "28FF28"))
                            elseif complete == -1 then
                                line.label:SetText(Questie:Colorize(l10n("Quest Failed!"), "red"))
                            end

                            -- Check and measure Objective text width and update tracker width
                            TrackerLayout.UpdateWidth(line.label:GetUnboundedStringWidth() + lineLabelWidthQBC)

                            -- Set Objective Label and Line widths
                            line.label:SetWidth(TrackerLayout.GetBaseFrameWidth() - lineLabelBaseFrameQBC)
                            line:SetWidth(line.label:GetWidth() + lineWidthQBC)

                            -- Compare largest text Label in the tracker with current Label, then save widest width
                            TrackerLayout.TrackLineWidth(line.label:GetUnboundedStringWidth() + lineWidthQBC)
                        end

                        -- Set Objective state
                        line:Show()
                        line.label:Show()
                    end
                end

                -- Safety check in case we hit the linePool limit
                if not line then
                    line = TrackerLinePool.GetLastLine()
                end

                -- Adds 2 pixels and "Padding Between Quests" setting in Tracker Options
                line:SetHeight(line.label:GetHeight() + (Questie.db.profile.trackerQuestPadding + 2))
            end

            secondaryButton = false
        end
    end
end
