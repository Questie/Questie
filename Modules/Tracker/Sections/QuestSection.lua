---@class QuestSection
local QuestSection = QuestieLoader:CreateModule("QuestSection")

---@type TrackerLayout
local TrackerLayout = QuestieLoader:ImportModule("TrackerLayout")
---@type LineBuilder
local LineBuilder = QuestieLoader:ImportModule("LineBuilder")
---@type TrackerData
local TrackerData = QuestieLoader:ImportModule("TrackerData")
---@type TrackerUtils
local TrackerUtils = QuestieLoader:ImportModule("TrackerUtils")
---@type TrackerQuestTimers
local TrackerQuestTimers = QuestieLoader:ImportModule("TrackerQuestTimers")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

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
        if (not questId) then
            break
        end

        -- reset objectiveMarginLeft for each quest, it can be increased if there are quest items
        objectiveMarginLeft = margins.objective

        ---@type TrackerQuest
        local quest = questDetails[questId].quest
        local complete = quest:IsComplete()
        local zoneName = questDetails[questId].zoneName

        TrackerQuestTimers:UpdateAndGetRemainingTime(quest, nil, true)
        local timedQuest = (quest.trackTimedQuest or quest.timedBlizzardQuest)

        if ((complete ~= 1 and (not quest.isComplete)) or Questie.db.profile.trackerShowCompleteQuests or timedQuest)
            and ((Questie.db.profile.autoTrackQuests and (not Questie.db.char.AutoUntrackedQuests[questId]))
            or (not Questie.db.profile.autoTrackQuests and Questie.db.char.TrackedQuests[questId])) then
            -- Add Quest Zones
            if zoneCheck ~= zoneName then
                firstQuestInZone = true
            end

            if firstQuestInZone then
                line = LineBuilder.AddHeader({key = zoneName, text = zoneName})
                if (not line) then
                    break
                end

                firstQuestInZone = false
                zoneCheck = zoneName
            end

            -- Add quest
            if (not Questie.db.char.collapsedZones[zoneName]) then
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
                if Questie.db.profile.collapseCompletedQuests and isMinimizable and (not timedQuest) then
                    if (not Questie.db.char.collapsedQuests[quest.Id]) then
                        Questie.db.char.collapsedQuests[quest.Id] = true
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

                line = LineBuilder.AddTitle({
                    text = coloredQuestName,
                    colored = true,
                    clickMode = "quest",
                    target = quest,
                    collapseId = quest.Id,
                    zoneKey = zoneName,
                })
                if (not line) then
                    break
                end

                line.questFocus:SetQuest(quest, complete == 1 or (complete ~= -1 and quest.isComplete == true))

                -- Adds the AI_VoiceOver Play Buttons
                line.playButton:SetPlayButton(questId)

                local shouldContinue = TrackerUtils.AddQuestItemButtons(quest, complete, line, margins.itemButtonSize, trackerBaseFrame, isMinimizable,
                    function()
                        if (not Questie.db.char.collapsedQuests[quest.Id]) then
                            LineBuilder.IndentTitle(line, margins.itemButtonSize)
                        end

                        secondaryButton = true
                    end)

                if (not shouldContinue) then
                    -- We exceeded the button pool
                    break
                end

                -- Indent the objectives behind a secondary quest item button
                if secondaryButton then
                    objectiveMarginLeft = objectiveMarginLeft + margins.itemButtonSize
                end

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
                        line = LineBuilder.AddTimer({
                            text = timerText,
                            target = quest,
                            activeTimer = activeTimer,
                            marginLeft = objectiveMarginLeft,
                        })
                        if (not line) then
                            break
                        end

                        if activeTimer then
                            TrackerQuestTimers:UpdateAndGetRemainingTime(quest, line, false)
                        end
                    end
                end

                -- Add quest Objectives (if applicable)
                if (not Questie.db.char.collapsedQuests[quest.Id]) then
                    -- Add incomplete Quest Objectives
                    if complete == 0 and quest.isComplete ~= true then
                        for _, objective in ipairs(quest.Objectives) do
                            if (not Questie.db.profile.hideCompletedQuestObjectives) or (not objective.Completed) then
                                line = LineBuilder.AddObjective({
                                    text = TrackerData.GetObjectiveText(objective),
                                    clickMode = "quest",
                                    target = quest,
                                    objective = objective,
                                    marginLeft = objectiveMarginLeft,
                                })
                                if (not line) then
                                    break
                                end

                                line.questHasSecondaryQIB = secondaryButton
                            end
                        end

                        -- Add complete/failed Quest Objectives and tag them as either complete or failed so as to always have at least one objective.
                        -- Some quests have "Blizzard Completion Text" that is displayed to show where to go next or where to turn in the quest.
                    elseif (complete == 1 or complete == -1 or quest.isComplete == true) and (not (timedQuest and isMinimizable and Questie.db.profile.collapseCompletedQuests)) then
                        local objectiveText
                        local isCompletionText = ((complete == 1 and completionText ~= nil and #quest.Objectives == 0) or (quest.isComplete == true and completionText ~= nil)) and objectiveColor ~= "minimal"
                        if isCompletionText then
                            -- Blizzard Completion text for single objectives
                            objectiveText = completionText
                        elseif complete == 1 or (#quest.Objectives == 0 and quest.isComplete == true and completionText == nil and complete ~= -1) then
                            objectiveText = Questie:Colorize(l10n("Quest Complete!"), "28FF28")
                        elseif complete == -1 then
                            objectiveText = Questie:Colorize(l10n("Quest Failed!"), "red")
                        end

                        line = LineBuilder.AddObjective({
                            text = objectiveText or "",
                            clickMode = "quest",
                            target = quest,
                            marginLeft = objectiveMarginLeft,
                        })
                        if (not line) then
                            break
                        end

                        -- Hide the Secondary Quest Item Button. There are some quests with usable items after a quest is completed I
                        -- have yet to encounter a completed quest where both a Primary and Secondary "usable" Quest Item was needed.
                        if isCompletionText and secondaryButton then
                            line.altButton:SetParent(UIParent)
                            line.altButton:Hide()
                        end
                    end
                end

                LineBuilder.FinishEntry(line)
            end

            secondaryButton = false
        end
    end
end
