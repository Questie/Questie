---@class TrackerLinePool
local TrackerLinePool = QuestieLoader:CreateModule("TrackerLinePool")
-------------------------
--Import QuestieTracker modules.
-------------------------
---@type TrackerBaseFrame
local TrackerBaseFrame = QuestieLoader:ImportModule("TrackerBaseFrame")
---@type TrackerUtils
local TrackerUtils = QuestieLoader:ImportModule("TrackerUtils")
---@type TrackerItemButton
local TrackerItemButton = QuestieLoader:ImportModule("TrackerItemButton")
---@type TrackerLine
local TrackerLine = QuestieLoader:ImportModule("TrackerLine")

---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
---@type WrappedText
local WrappedText = QuestieLoader:ImportModule("WrappedText")

local linePoolSize = 250
local lineIndex = 0
local buttonPoolSize = 25
local buttonIndex = 0
---@type table<number, TrackerLineFrame>
local linePool = {}
local buttonPool = {}

---@type table<QuestId, table<TrackerLineFrame>>
local linesByQuest = {}

---@type table<number, table<TrackerLineFrame>>
local linesByScenarioIndex = {}

local function _GetObjectiveText(colorPrefix, description, progressText)
    local text = (description or "")
    if progressText then
        text = text .. ": " .. progressText
    end

    return (colorPrefix or "") .. text
end

local function _TextFits(label, text, width)
    if (not label.SetText) or (not label.GetUnboundedStringWidth) then
        return true
    end

    label:SetText(text)

    return label:GetUnboundedStringWidth() <= width
end

local function _GetWrappedDescriptionLines(description, width, label)
    local lines = {}
    local normalizedDescription = (description or ""):gsub("\r\n", "\n")

    for hardLine in (normalizedDescription .. "\n"):gmatch("(.-)\n") do
        local wrappedLines = WrappedText:TextWrap(hardLine, "", false, width, label)
        for _, wrappedLine in ipairs(wrappedLines) do
            table.insert(lines, wrappedLine)
        end
    end

    if #lines == 0 then
        table.insert(lines, "")
    end

    return lines
end

local function _UpdateWrappedLineHeight(line)
    if (not line.label.GetStringHeight) or (not line.label.SetHeight) then
        return
    end

    local labelHeight = line.label:GetStringHeight()
    if (not labelHeight or labelHeight <= 0) and line.label.GetFont and line.label.GetNumLines then
        local _, fontSize = line.label:GetFont()
        labelHeight = fontSize * line.label:GetNumLines()
    end

    if labelHeight and labelHeight > 0 then
        line.label:SetHeight(labelHeight)
        if line.SetHeight then
            line:SetHeight(labelHeight + 2 + Questie.db.profile.trackerQuestPadding)
        end
    end
end

function TrackerLinePool.ClearWrappedObjectiveText(line)
    line.wrappedObjectiveText = nil
end

function TrackerLinePool.GetWrappedObjectiveText(line)
    if not line.wrappedObjectiveText then
        return nil
    end

    return _GetObjectiveText(line.wrappedObjectiveText.colorPrefix, line.wrappedObjectiveText.description, line.wrappedObjectiveText.progressText)
end

function TrackerLinePool.ApplyWrappedObjectiveText(line, targetWidth)
    local data = line.wrappedObjectiveText
    if not data then
        return
    end

    local fullText = TrackerLinePool.GetWrappedObjectiveText(line)
    if (not targetWidth) or targetWidth <= 0 or string.find(data.description or "", "|", 1, true) then
        line.label:SetText(fullText)
        _UpdateWrappedLineHeight(line)
        return
    end

    local descriptionLines = _GetWrappedDescriptionLines(data.description, targetWidth, line.label)
    if data.progressText then
        local progressSuffix = ": " .. data.progressText
        local lastLineIndex = #descriptionLines
        local lastLineWithProgress = descriptionLines[lastLineIndex] .. progressSuffix
        if _TextFits(line.label, lastLineWithProgress, targetWidth) then
            descriptionLines[lastLineIndex] = lastLineWithProgress
        else
            table.insert(descriptionLines, "    > " .. data.progressText)
        end
    end

    line.label:SetText((data.colorPrefix or "") .. table.concat(descriptionLines, "\n"))
    _UpdateWrappedLineHeight(line)
end

function TrackerLinePool.SetWrappedObjectiveText(line, colorPrefix, description, progressText, targetWidth)
    line.wrappedObjectiveText = {
        colorPrefix = colorPrefix,
        description = description or "",
        progressText = progressText,
    }

    TrackerLinePool.ApplyWrappedObjectiveText(line, targetWidth)
end

---@param questFrame Frame
function TrackerLinePool.Initialize(questFrame)
    local trackerQuestFrame = questFrame

    -- create linePool for quests/achievements
    local previousLine
    for i = 1, linePoolSize do
        local line = TrackerLine.New(i, trackerQuestFrame.ScrollChildFrame, previousLine, TrackerLinePool.OnHighlightEnter, TrackerLinePool.OnHighlightLeave, TrackerLinePool.AddQuestLine, TrackerLinePool.AddScenarioLine)
        linePool[i] = line
        previousLine = line
    end

    -- create buttonPool for quest items
    for i = 1, C_QuestLog.GetMaxNumQuestsCanAccept() do
        local btn = TrackerItemButton.New("Questie_ItemButton" .. i)

        buttonPool[i] = btn
        buttonPool[i]:Hide()
    end
end

function TrackerLinePool.ResetLinesForChange()
    if TrackerBaseFrame.isSizing == true or TrackerBaseFrame.isMoving == true then
        Questie:Debug(Questie.DEBUG_SPAM, "[TrackerLinePool:ResetLinesForChange]")
    else
        Questie:Debug(Questie.DEBUG_INFO, "[TrackerLinePool:ResetLinesForChange]")
    end

    if InCombatLockdown() or not Questie.db.profile.trackerEnabled then
        return
    end

    linesByQuest = {} -- Reset to keep correct questId <-> line mapping

    for _, line in pairs(linePool) do
        line.mode = nil
        line.trackTimedQuest = nil
        line.questHasSecondaryQIB = false
        TrackerLinePool.ClearWrappedObjectiveText(line)
        if line.expandQuest then
            line.expandQuest.mode = nil
            line.expandQuest.questId = nil
        end
        if line.expandZone then
            line.expandZone.mode = nil
            line.expandZone.zoneId = nil
        end
        if line.criteriaMark then
            line.criteriaMark.mode = nil
            line.criteriaMark:SetCriteria(false)
            line.criteriaMark:Hide()
        end
        if line.playButton then
            line.playButton.mode = nil
            line.playButton:SetAlpha(0)
            line.playButton:Hide()
        end
    end

    lineIndex = 0
end

function TrackerLinePool.ResetButtonsForChange()
    if TrackerBaseFrame.isSizing == true or TrackerBaseFrame.isMoving == true then
        Questie:Debug(Questie.DEBUG_SPAM, "[TrackerLinePool:ResetButtonsForChange]")
    else
        Questie:Debug(Questie.DEBUG_INFO, "[TrackerLinePool:ResetButtonsForChange]")
    end

    if InCombatLockdown() or not Questie.db.profile.trackerEnabled then
        return
    end

    buttonIndex = 0
end

---@param callback function
function TrackerLinePool.UpdateObjectiveLines(callback)
    for _, line in pairs(linePool) do
        if line.mode == "objective" then
            callback(line)
        end
    end
end

---@param callback function
function TrackerLinePool.UpdateQuestTitleLines(callback)
    for _, line in pairs(linePool) do
        if line.mode == "quest" then
            callback(line)
        end
    end
end

function TrackerLinePool.UpdateWrappedLineWidths(trackerLineWidth)
    local trackerFontSizeQuest = Questie.db.profile.trackerFontSizeQuest
    local trackerMarginLeft = 14
    local trackerMarginRight = 30
    local questMarginLeft = (trackerMarginLeft + trackerMarginRight) - (18 - trackerFontSizeQuest)
    local objectiveMarginLeft = questMarginLeft + trackerFontSizeQuest
    local questItemButtonSize = 12 + trackerFontSizeQuest

    -- Updates all the line.label widths in the linePool for wrapped text only
    for _, line in pairs(linePool) do
        if Questie.db.profile.TrackerWidth == 0 then
            if line.mode == "objective" then
                if line.label:GetNumLines() > 1 and line:GetHeight() > Questie.db.profile.trackerFontSizeObjective then
                    local labelWidth
                    if line.altButton then
                        labelWidth = trackerLineWidth - objectiveMarginLeft - questItemButtonSize
                        line:SetWidth(trackerLineWidth + questItemButtonSize)
                    else
                        labelWidth = trackerLineWidth - objectiveMarginLeft
                        line:SetWidth(trackerLineWidth)
                    end

                    line.label:SetWidth(labelWidth)
                    if line.wrappedObjectiveText then
                        TrackerLinePool.ApplyWrappedObjectiveText(line, labelWidth)
                    else
                        line.label:SetText(line.label:GetText())
                        line:SetHeight(line.label:GetStringHeight() + 2 + Questie.db.profile.trackerQuestPadding)
                        line.label:SetHeight(line:GetHeight() - 2 - Questie.db.profile.trackerQuestPadding)
                    end
                end
            end
        end
    end
end

---@return TrackerLineFrame|nil
function TrackerLinePool.GetNextLine()
    lineIndex = lineIndex + 1
    if not linePool[lineIndex] then
        return nil -- past the line limit
    end

    TrackerLinePool.ClearWrappedObjectiveText(linePool[lineIndex])

    return linePool[lineIndex]
end

---@param zoneName string
---@return TrackerLineFrame|nil
function TrackerLinePool.GetZoneLine(zoneName)
    local line = TrackerLinePool.GetNextLine()
    if (not line) then
        return nil
    end

    line:SetMode("zone")
    line:SetZone(zoneName)
    line.expandQuest:Hide()
    line.criteriaMark:Hide()
    line.playButton:Hide()

    line.label:ClearAllPoints()
    line.label:SetPoint("TOPLEFT", line, "TOPLEFT", 0, 0)

    return line
end

---@param quest Quest
---@param lineWidth number
---@return TrackerLineFrame|nil
function TrackerLinePool.GetQuestTitleLine(quest, lineWidth)
    local line = TrackerLinePool.GetNextLine()
    if (not line) then
        return nil
    end

    line:SetMode("quest")
    line:SetOnClick("quest")
    line:SetQuest(quest)
    line:SetObjective(nil)
    line.expandZone:Hide()
    line.criteriaMark:Hide()

    line.label:ClearAllPoints()
    line.label:SetPoint("TOPLEFT", line, "TOPLEFT", lineWidth, 0)

    return line
end

---@param quest Quest
---@param objective QuestObjective|nil
---@param lineWidth number
---@return TrackerLineFrame|nil
function TrackerLinePool.GetQuestObjectiveLine(quest, objective, lineWidth)
   local line = TrackerLinePool.GetNextLine()
    if (not line) then
        return nil
    end

    line:SetMode("objective")
    line:SetOnClick("quest")
    line:SetQuest(quest)
    line:SetObjective(objective)
    line.expandZone:Hide()
    line.expandQuest:Hide()
    line.criteriaMark:Hide()
    line.playButton:Hide()

    line.label:ClearAllPoints()
    line.label:SetPoint("TOPLEFT", line, "TOPLEFT", lineWidth, 0)

    return line
end

---@param achieve Achievement
---@param lineWidth number
---@return TrackerLineFrame|nil
function TrackerLinePool.GetAchievementTitleLine(achieve, lineWidth)
   local line = TrackerLinePool.GetNextLine()
    if (not line) then
        return nil
    end

    line:SetMode("achieve")
    line:SetOnClick("achieve")
    line:SetQuest(achieve)
    line:SetObjective(nil)
    line.expandZone:Hide()
    line.criteriaMark:Hide()
    line.playButton:Hide()

    line.label:ClearAllPoints()
    line.label:SetPoint("TOPLEFT", line, "TOPLEFT", lineWidth, 0)

    return line
end

---@param achieve Achievement
---@param lineWidth number
---@return TrackerLineFrame|nil
function TrackerLinePool.GetAchievementObjectiveLine(achieve, lineWidth)
   local line = TrackerLinePool.GetNextLine()
    if (not line) then
        return nil
    end

    line:SetMode("objective")
    line:SetOnClick("achieve")
    line:SetQuest(achieve)
    line:SetObjective(nil)
    line.expandZone:Hide()
    line.expandQuest:Hide()
    line.criteriaMark:Hide()
    line.playButton:Hide()

    line.label:ClearAllPoints()
    line.label:SetPoint("TOPLEFT", line, "TOPLEFT", lineWidth, 0)

    return line
end

---@return table|nil buttonIndex buttonPool[buttonIndex]
function TrackerLinePool.GetNextItemButton()
    buttonIndex = buttonIndex + 1
    if not buttonPool[buttonIndex] then
        return nil -- past the line limit
    end

    return buttonPool[buttonIndex]
end

---@param index number
---@return TrackerLineFrame
function TrackerLinePool.GetLine(index)
    return linePool[index]
end

---@return TrackerLineFrame
function TrackerLinePool.GetCurrentLine()
    return linePool[lineIndex]
end

---@return table buttonIndex buttonPool[buttonIndex]
function TrackerLinePool.GetCurrentButton()
    return buttonPool[buttonIndex]
end

---@return TrackerLineFrame
function TrackerLinePool.GetFirstLine()
    return linePool[1]
end

---@return TrackerLineFrame
function TrackerLinePool.GetLastLine()
    return linePool[linePoolSize]
end

function TrackerLinePool.HideUnusedLines()
    if TrackerBaseFrame.isSizing == true or TrackerBaseFrame.isMoving == true then
        Questie:Debug(Questie.DEBUG_SPAM, "[TrackerLinePool:HideUnusedLines]")
    else
        Questie:Debug(Questie.DEBUG_INFO, "[TrackerLinePool:HideUnusedLines]")
    end
    local startUnusedLines = 0

    if Questie.db.char.isTrackerExpanded then
        startUnusedLines = lineIndex + 1
    end

    for i = startUnusedLines, linePoolSize do
        local line = linePool[i]
        if line then -- Safe Guard to really concurrent triggers
            line:Hide()
            line.mode = nil
            line.ZoneId = nil
            line.Quest = nil
            line.Objective = nil
            line.Button = nil
            line.altButton = nil
            line.questHasSecondaryQIB = false
            TrackerLinePool.ClearWrappedObjectiveText(line)
            line.trackTimedQuest = nil
            line.expandQuest.mode = nil
            line.expandQuest.questId = nil
            line.expandZone.mode = nil
            line.expandZone.zoneId = nil
            line.criteriaMark.mode = nil
            line.playButton.mode = nil
        end
    end
end

function TrackerLinePool.HideUnusedButtons()
    if TrackerBaseFrame.isSizing == true or TrackerBaseFrame.isMoving == true then
        Questie:Debug(Questie.DEBUG_SPAM, "[TrackerLinePool:HideUnusedButtons]")
    else
        Questie:Debug(Questie.DEBUG_INFO, "[TrackerLinePool:HideUnusedButtons]")
    end
    local startUnusedButtons = 0

    if Questie.db.char.isTrackerExpanded then
        startUnusedButtons = buttonIndex + 1
    end

    for i = startUnusedButtons, buttonPoolSize do
        local button = buttonPool[i]
        if button then
            button:FakeHide()
            button.itemId = nil
            button.lineID = nil
            button.fontSize = nil
            button:ClearAllPoints()
            button:SetParent(UIParent)
            button:Hide()
        end
    end
end

---@return number lineIndex
function TrackerLinePool.GetHighestIndex()
    return lineIndex > linePoolSize and linePoolSize or lineIndex
end

---@param alpha number
function TrackerLinePool.SetAllPlayButtonAlpha(alpha)
    if TrackerUtils:IsVoiceOverLoaded() then
        local highestIndex = TrackerLinePool.GetHighestIndex()
        for i = 1, highestIndex do
            local line = linePool[i]
            local questId = line.playButton.mode
            local button = VoiceOver.QuestOverlayUI.questPlayButtons[questId]
            local sound = VoiceOver.DataModules:PrepareSound({ event = 1, questID = questId })

            if button then
                local isPlaying = button.soundData and VoiceOver.SoundQueue:Contains(button.soundData)
                local texturePath = isPlaying and "Interface\\Addons\\Questie\\Icons\\QuestLogStopButton" or "Interface\\Addons\\Questie\\Icons\\QuestLogPlayButton"

                line.playButton:SetNormalTexture(texturePath)
            end

            if IsShiftKeyDown() then
                if sound then
                    line.playButton:SetAlpha(alpha)
                else
                    line.playButton:SetAlpha(0.33)
                end

                line.playButton:SetFrameLevel(200)
            else
                line.playButton:SetAlpha(alpha)
                line.playButton:SetFrameLevel(0)
            end
        end
    end
end

---@param alpha number
function TrackerLinePool.SetAllExpandQuestAlpha(alpha)
    local highestIndex = TrackerLinePool.GetHighestIndex()
    for i = 1, highestIndex do
        linePool[i].expandQuest:SetAlpha(alpha)
    end
end

---@param alpha number
function TrackerLinePool.SetAllItemButtonAlpha(alpha)
    for i = 1, buttonIndex do
        local button = buttonPool[i]
        if (not button) then
            -- This should not happen as we keep track of the buttonIndex
            break
        end

        button:SetAlpha(alpha)
    end
end

TrackerLinePool.OnHighlightEnter = function(self)
    if Questie.db.profile.trackerDisableHoverFade then
        return
    end

    local highestIndex = TrackerLinePool.GetHighestIndex()
    for i = 1, highestIndex do
        local line = linePool[i]
        line:SetAlpha(0.5)

        if (line.Quest ~= nil and line.Quest == self.Quest) or (line.expandZone ~= nil and self:GetParent().expandZone ~= nil and line.expandZone.zoneId == self:GetParent().expandZone.zoneId) then
            line:SetAlpha(1)
        end
    end
end

TrackerLinePool.OnHighlightLeave = function()
    local highestIndex = TrackerLinePool.GetHighestIndex()
    for i = 1, highestIndex do
        linePool[i]:SetAlpha(1)
    end
end

---@param questId QuestId
---@param line TrackerLineFrame
function TrackerLinePool.AddQuestLine(questId, line)
    if (not linesByQuest[questId]) then
        linesByQuest[questId] = {}
    end

    if (not tContains(linesByQuest[questId], line)) then
        table.insert(linesByQuest[questId], line)
    end
end

---@param questId QuestId
function TrackerLinePool.UpdateQuestLines(questId)
    if not linesByQuest[questId] then
        return
    end

    local lines = linesByQuest[questId]
    for _, line in pairs(lines) do
        if line.Objective then
            ---@type QuestObjective
            local objective = line.Objective
            local lineEnding = tostring(objective.Collected) .. "/" .. tostring(objective.Needed)

            local objDesc = QuestieLib:GetObjectiveDescription(objective)
            local targetWidth
            if line.label.GetWidth then
                targetWidth = line.label:GetWidth()
            end
            TrackerLinePool.SetWrappedObjectiveText(line, QuestieLib:GetRGBForObjective(objective), objDesc, lineEnding, targetWidth)
        end
    end
end

---@param criteriaIndex number
---@param line TrackerLineFrame
function TrackerLinePool.AddScenarioLine(criteriaIndex, line)
    if (not linesByScenarioIndex[criteriaIndex]) then
        linesByScenarioIndex[criteriaIndex] = {}
    end

    if (not tContains(linesByScenarioIndex[criteriaIndex], line)) then
        linesByScenarioIndex[criteriaIndex] = line
    end
end

---@param criteriaIndex number
function TrackerLinePool.UpdateScenarioLines(criteriaIndex)
    if not linesByScenarioIndex[criteriaIndex] then
        return
    end

    local line = linesByScenarioIndex[criteriaIndex]
    if line.Objective then
        ---@type QuestObjective
        local objective = line.Objective
        local criteriaInfo = C_ScenarioInfo.GetCriteriaInfo(objective.Index)
        if (not criteriaInfo) then
            return
        end

        local lineEnding = tostring(criteriaInfo.quantity) .. "/" .. tostring(criteriaInfo.totalQuantity)
        local targetWidth
        if line.label.GetWidth then
            targetWidth = line.label:GetWidth()
        end
        TrackerLinePool.SetWrappedObjectiveText(line, QuestieLib:GetRGBForObjective(objective), objective.Description, lineEnding, targetWidth)
    end
end

return TrackerLinePool
