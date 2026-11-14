-- Draws scenario objectives. Challenge Mode dungeons are scenarios with an additional timer line.
---@class ScenarioSection
local ScenarioSection = QuestieLoader:CreateModule("ScenarioSection")

---@type TrackerLayout
local TrackerLayout = QuestieLoader:ImportModule("TrackerLayout")
---@type TrackerLinePool
local TrackerLinePool = QuestieLoader:ImportModule("TrackerLinePool")
---@type ChallengeModeTimer
local ChallengeModeTimer = QuestieLoader:ImportModule("ChallengeModeTimer")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local LSM30 = LibStub("LibSharedMedia-3.0")

---@param line TrackerLineFrame
---@param fontName string
---@param fontSize number
---@param marginLeft number
local function _SetupLine(line, fontName, fontSize, marginLeft)
    line.label:SetFont(LSM30:Fetch("font", fontName), fontSize, Questie.db.profile.trackerFontOutline)
    line.label:SetHeight(fontSize)
    line.expandZone:Hide()
    line.expandQuest:Hide()
    line.criteriaMark:Hide()
    line.playButton:Hide()

    line.label:ClearAllPoints()
    line.label:SetPoint("TOPLEFT", line, "TOPLEFT", marginLeft, 0)
end

---@param line TrackerLineFrame
---@param padding number
local function _ShowLine(line, padding)
    line.label:SetWidth(TrackerLayout.GetBaseFrameWidth())
    line:SetWidth(line.label:GetWidth())
    TrackerLayout.TrackLineWidth(line.label:GetUnboundedStringWidth())
    line:SetHeight(line.label:GetHeight() + padding)

    line:Show()
    line.label:Show()
end

---@param isChallengeMode boolean
function ScenarioSection.Draw(isChallengeMode)
    local line = TrackerLinePool.GetNextLine()
    if (not line) then
        return
    end

    _SetupLine(line, Questie.db.profile.trackerFontZone, Questie.db.profile.trackerFontSizeZone + 3, 0)

    local dungeonName = GetInstanceInfo()
    if isChallengeMode then
        line.label:SetText("|cFFC0C0C0" .. l10n(dungeonName) .. " (" .. l10n("Challenge Mode") .. ")|r")
    else
        line.label:SetText("|cFFC0C0C0" .. l10n(dungeonName) .. "|r")
    end

    _ShowLine(line, 3)
    line.Quest = nil
    line.Objective = nil

    if isChallengeMode then
        line = TrackerLinePool.GetNextLine()
        if (not line) then
            return
        end

        _SetupLine(line, Questie.db.profile.trackerFontQuest, Questie.db.profile.trackerFontSizeQuest + 10, 15)

        line.label:SetText(ChallengeModeTimer.GetTimerString())
        ChallengeModeTimer.SetTimerLabel(line.label)

        _ShowLine(line, 3)
        line.Quest = nil
        line.Objective = nil
    end

    local _, _, numSteps = C_Scenario.GetStepInfo()
    for i = 1, numSteps do
        line = TrackerLinePool.GetNextLine()
        if (not line) then
            break
        end

        local criteriaInfo = C_ScenarioInfo.GetCriteriaInfo(i)

        -- We re-shape the criteriaInfo to match quest objectives used by the tracker.
        local objective = {
            Id = criteriaInfo.criteriaID,
            Index = i,
            Description = criteriaInfo.description,
            Collected = criteriaInfo.quantity,
            Needed = criteriaInfo.totalQuantity,
            Completed = criteriaInfo.completed,
        }

        _SetupLine(line, Questie.db.profile.trackerFontObjective, Questie.db.profile.trackerFontSizeObjective + 2, 15)
        line:SetScenarioCriteria(objective)

        local lineEnding = tostring(objective.Collected) .. "/" .. tostring(objective.Needed)
        line.label:SetText(QuestieLib:GetRGBForObjective(objective) .. objective.Description .. ": " .. lineEnding)

        _ShowLine(line, 1)
    end

    TrackerLayout.UpdateWidth(TrackerLayout.GetLineWidth())
    TrackerLayout.UpdateHeight()
end
