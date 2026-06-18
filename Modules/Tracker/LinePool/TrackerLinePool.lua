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
---@type utf8
local utf8 = QuestieLoader:ImportModule("utf8")

local linePoolSize = 250
local lineIndex = 0
local buttonPoolSize = 25
local buttonIndex = 0
---@type table<number, TrackerLineFrame>
local linePool = {}
local buttonPool = {}
local PROGRESS_COLUMN_GAP = 8
local DESCRIPTION_PROGRESS_SEPARATOR = ":"

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

    return (label:GetUnboundedStringWidth() or 0) <= width
end

local function _TrimTrailingWhitespace(text)
    local trimmedText = (text or ""):gsub("%s+$", "")
    return trimmedText
end

local function _IsAsciiText(text)
    return not string.find(text, "[\128-\255]")
end

local function _EllipsizeToFit(text, width, label)
    local ellipsis = "..."
    if _TextFits(label, text, width) then
        return text
    end

    if width <= 0 or _TextFits(label, ellipsis, width) then
        local textLength = utf8.strlen(text)
        for endIndex = textLength, 1, -1 do
            local candidate = utf8.sub(text, 1, endIndex) .. ellipsis
            if _TextFits(label, candidate, width) then
                return candidate
            end
        end

        return ellipsis
    end

    return ""
end

local function _SplitLineToFit(line, width, label)
    line = _TrimTrailingWhitespace(line)
    if _TextFits(label, line, width) then
        return {line}
    end

    if (not string.find(line, "%s")) and _IsAsciiText(line) then
        return {_EllipsizeToFit(line, width, label)}
    end

    local lines = {}
    local remainingLine = line:gsub("^%s+", "")

    while remainingLine ~= "" do
        if _TextFits(label, remainingLine, width) then
            table.insert(lines, _TrimTrailingWhitespace(remainingLine))
            break
        end

        if (not string.find(remainingLine, "%s")) and _IsAsciiText(remainingLine) then
            table.insert(lines, _EllipsizeToFit(remainingLine, width, label))
            break
        end

        local remainingLineLength = utf8.strlen(remainingLine)
        local lastFittingIndex
        local lastSpaceIndex

        for endIndex = 1, remainingLineLength do
            local character = utf8.sub(remainingLine, endIndex, endIndex)
            local candidate = utf8.sub(remainingLine, 1, endIndex)
            if _TextFits(label, candidate, width) then
                lastFittingIndex = endIndex
                if character == " " and endIndex > 1 then
                    lastSpaceIndex = endIndex - 1
                end
            else
                break
            end
        end

        local lineEndIndex = lastSpaceIndex or lastFittingIndex or 1
        local newLine = _TrimTrailingWhitespace(utf8.sub(remainingLine, 1, lineEndIndex))
        if newLine == "" then
            newLine = utf8.sub(remainingLine, 1, 1)
            lineEndIndex = 1
        end

        if (not lastSpaceIndex) and _IsAsciiText(newLine) and (not string.find(newLine, "%s")) and (not _TextFits(label, newLine, width)) then
            newLine = _EllipsizeToFit(newLine, width, label)
            table.insert(lines, newLine)
            break
        end

        table.insert(lines, newLine)
        remainingLine = utf8.sub(remainingLine, lineEndIndex + 1, remainingLineLength):gsub("^%s+", "")
    end

    if #lines == 0 then
        table.insert(lines, "")
    end

    return lines
end

local function _GetWrappedDescriptionLines(description, width, label)
    local lines = {}
    local normalizedDescription = (description or ""):gsub("\r\n", "\n")

    if normalizedDescription == "" then
        return {""}
    end

    for hardLine in (normalizedDescription .. "\n"):gmatch("(.-)\n") do
        if hardLine ~= "" then
            local wrappedLines = WrappedText:TextWrap(hardLine, "", false, width, label)
            for _, wrappedLine in ipairs(wrappedLines) do
                local fittingLines = _SplitLineToFit(wrappedLine, width, label)
                for _, fittingLine in ipairs(fittingLines) do
                    table.insert(lines, fittingLine)
                end
            end
        end
    end

    if #lines == 0 then
        table.insert(lines, "")
    end

    return lines
end

local function _GetReliableLabelHeight(label)
    if (not label) or (not label.GetStringHeight) then
        return 0
    end

    local labelHeight = label:GetStringHeight() or 0
    if label.GetFont and label.GetNumLines then
        local _, fontSize = label:GetFont()
        local numLines = label:GetNumLines()
        if fontSize and numLines then
            labelHeight = math.max(labelHeight, (fontSize * numLines) + 1)
        end
    end

    return labelHeight
end

local function _UpdateWrappedLineHeight(line)
    local labelHeight = _GetReliableLabelHeight(line.label)
    local progressHeight = _GetReliableLabelHeight(line.progressLabel)
    local lineHeight = math.max(labelHeight, progressHeight)

    if lineHeight > 0 then
        if line.label.SetHeight then
            line.label:SetHeight(labelHeight > 0 and labelHeight or lineHeight)
        end
        if line.progressLabel and line.progressLabel.SetHeight and progressHeight > 0 then
            line.progressLabel:SetHeight(progressHeight)
        end
        if line.SetHeight then
            line:SetHeight(lineHeight + 2 + (Questie.db.profile.trackerQuestPadding or 0))
        end
    end
end

function TrackerLinePool.ClearWrappedObjectiveText(line)
    line.wrappedObjectiveText = nil
    if line.progressLabel then
        if line.progressLabel.SetText then
            line.progressLabel:SetText("")
        end
        if line.progressLabel.Hide then
            line.progressLabel:Hide()
        end
    end
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
    data.lastTargetWidth = targetWidth

    if (not targetWidth) or targetWidth <= 0 or string.find(data.description or "", "|", 1, true) or (not data.progressText) or (not line.progressLabel) or (not line.progressLabel.SetText) then
        if line.progressLabel then
            if line.progressLabel.SetText then
                line.progressLabel:SetText("")
            end
            if line.progressLabel.Hide then
                line.progressLabel:Hide()
            end
        end
        if line.label.SetWidth and targetWidth and targetWidth > 0 then
            line.label:SetWidth(targetWidth)
        end
        line.label:SetText(fullText)
        _UpdateWrappedLineHeight(line)
        return
    end

    local coloredProgressText = (data.colorPrefix or "") .. data.progressText
    line.progressLabel:SetText(coloredProgressText)
    if line.progressLabel.Show then
        line.progressLabel:Show()
    end

    local progressWidth = 0
    if line.progressLabel.GetUnboundedStringWidth then
        progressWidth = line.progressLabel:GetUnboundedStringWidth() or 0
    end
    if progressWidth <= 0 and line.progressLabel.GetWidth then
        progressWidth = line.progressLabel:GetWidth() or 0
    end

    local descriptionWidth = math.max(1, targetWidth - progressWidth - PROGRESS_COLUMN_GAP)
    if line.label.SetWidth then
        line.label:SetWidth(descriptionWidth)
    end
    if line.progressLabel.SetWidth then
        line.progressLabel:SetWidth(progressWidth)
    end
    if line.progressLabel.ClearAllPoints then
        line.progressLabel:ClearAllPoints()
    end
    if line.progressLabel.SetPoint then
        line.progressLabel:SetPoint("TOPRIGHT", line, "TOPRIGHT", 0, 0)
    end

    local descriptionText = (data.description or "") .. DESCRIPTION_PROGRESS_SEPARATOR
    local descriptionLines = _GetWrappedDescriptionLines(descriptionText, descriptionWidth, line.label)
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
    linesByScenarioIndex = {} -- Reset to avoid stale scenario criteria <-> line mapping

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
            local targetWidth = line.wrappedObjectiveText and line.wrappedObjectiveText.lastTargetWidth
            if (not targetWidth) and line.label.GetWidth then
                targetWidth = line.label:GetWidth()
            end
            TrackerLinePool.SetWrappedObjectiveText(line, QuestieLib:GetRGBForObjective(objective), objDesc, lineEnding, targetWidth)
        end
    end
end

---@param criteriaIndex number
---@param line TrackerLineFrame
function TrackerLinePool.AddScenarioLine(criteriaIndex, line)
    linesByScenarioIndex[criteriaIndex] = line
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
        if objective.Id ~= criteriaIndex then
            return
        end

        local criteriaInfo = C_ScenarioInfo.GetCriteriaInfo(objective.Index)
        if (not criteriaInfo) then
            return
        end

        local lineEnding = tostring(criteriaInfo.quantity) .. "/" .. tostring(criteriaInfo.totalQuantity)
        local targetWidth = line.wrappedObjectiveText and line.wrappedObjectiveText.lastTargetWidth
        if (not targetWidth) and line.label.GetWidth then
            targetWidth = line.label:GetWidth()
        end
        TrackerLinePool.SetWrappedObjectiveText(line, QuestieLib:GetRGBForObjective(objective), objective.Description, lineEnding, targetWidth)
    end
end

return TrackerLinePool
