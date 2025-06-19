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

local linePoolSize = 250
local lineIndex = 0
local buttonPoolSize = 25
local buttonIndex = 0
local linePool = {}
local buttonPool = {}

---@type table<QuestId, table<Frame>>
local linesByQuest = {}

---@param questFrame Frame
function TrackerLinePool.Initialize(questFrame)
    local trackerQuestFrame = questFrame

    -- create linePool for quests/achievements
    local previousLine
    for i = 1, linePoolSize do
        local line = TrackerLine.New(i, trackerQuestFrame.ScrollChildFrame, previousLine, TrackerLinePool.OnHighlightEnter, TrackerLinePool.OnHighlightLeave, TrackerLinePool.AddQuestLine)
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
                    line.label:SetText(line.label:GetText())

                    if line.altButton then
                        line.label:SetWidth(trackerLineWidth - objectiveMarginLeft - questItemButtonSize)
                        line:SetWidth(trackerLineWidth + questItemButtonSize)
                    else
                        line.label:SetWidth(trackerLineWidth - objectiveMarginLeft)
                        line:SetWidth(trackerLineWidth)
                    end

                    line:SetHeight(line.label:GetStringHeight() + 2 + Questie.db.profile.trackerQuestPadding)
                    line.label:SetHeight(line:GetHeight() - 2 - Questie.db.profile.trackerQuestPadding)
                end
            end
        end
    end
end

---@return table|nil lineIndex linePool[lineIndex + 1]
function TrackerLinePool.GetNextLine()
    lineIndex = lineIndex + 1
    if not linePool[lineIndex] then
        return nil -- past the line limit
    end

    return linePool[lineIndex]
end

---@return table|nil buttonIndex buttonPool[buttonIndex]
function TrackerLinePool.GetNextItemButton()
    buttonIndex = buttonIndex + 1
    if not buttonPool[buttonIndex] then
        return nil -- past the line limit
    end

    return buttonPool[buttonIndex]
end

---@return number lineIndex lineIndex == 1
function TrackerLinePool.IsFirstLine()
    return linePool[1]
end

---@param index number
---@return table index linePool[index]
function TrackerLinePool.GetLine(index)
    return linePool[index]
end

---@return table lineIndex linePool[lineIndex]
function TrackerLinePool.GetCurrentLine()
    return linePool[lineIndex]
end

---@return table buttonIndex buttonPool[buttonIndex]
function TrackerLinePool.GetCurrentButton()
    return buttonPool[buttonIndex]
end

---@return table|nil lineIndex linePool[lineIndex - 1]
function TrackerLinePool.GetPreviousLine()
    lineIndex = lineIndex - 1
    if not linePool[lineIndex] then
        return nil -- past the line limit
    end

    return linePool[lineIndex]
end

---@return table linePool linePool[1]
function TrackerLinePool.GetFirstLine()
    return linePool[1]
end

---@return table linePool linePool[linePoolSize]
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
---@param line LineFrame
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
            objective:Update()
            local lineEnding = tostring(objective.Collected) .. "/" .. tostring(objective.Needed)

            local objDesc = objective.Description:gsub("%.", "")
            line.label:SetText(QuestieLib:GetRGBForObjective(objective) .. objDesc .. ": " .. lineEnding)
        end
    end
end

return TrackerLinePool
