---@class TrackerQuestTooltip
local TrackerQuestTooltip = QuestieLoader:CreateModule("TrackerQuestTooltip")

---@type TrackerData
local TrackerData = QuestieLoader:ImportModule("TrackerData")
---@type QuestieTooltips
local QuestieTooltips = QuestieLoader:ImportModule("QuestieTooltips")
---@type TrackerLinePool
local TrackerLinePool = QuestieLoader:ImportModule("TrackerLinePool")

local REFRESH_INTERVAL = 0.5

---@type GameTooltip?
local tooltip
---@type TrackerLineFrame?
local hoveredLine
local refreshTicker

---@param line TrackerLineFrame
---@return QuestId?
local function _GetQuestId(line)
    if not line:IsVisible() or (line.mode ~= "quest" and line.mode ~= "objective") then
        return nil
    end
    local quest = line.Quest
    -- Achievement objectives also use SetQuest and can have the same ID as a quest.
    if quest and TrackerData.GetQuest(quest.Id) == quest then
        return quest.Id
    end
end

---@param line TrackerLineFrame? Only dismiss this line's tooltip when given.
function TrackerQuestTooltip.Hide(line)
    if line and hoveredLine ~= line then
        return
    end
    hoveredLine = nil
    if refreshTicker then
        refreshTicker:Cancel()
        refreshTicker = nil
    end
    if tooltip then
        tooltip:Hide()
    end
end

---@param line TrackerLineFrame
---@return TrackerLineFrame
local function _GetTitleLine(line)
    if line.mode == "quest" then
        return line
    end
    for i = 1, TrackerLinePool.GetHighestIndex() do
        local candidate = TrackerLinePool.GetLine(i)
        if candidate and candidate.mode == "quest" and candidate.Quest == line.Quest and candidate:IsVisible() then
            return candidate
        end
    end
    return line
end

local function _CanShow()
    return IsInGroup() and Questie.db.profile.enableTooltips and Questie.db.profile.trackerEnabled
        and C_TooltipInfo and type(C_TooltipInfo.GetQuestPartyProgress) == "function"
end

local function _Refresh()
    local line = hoveredLine
    local questId = line and _GetQuestId(line)
    if not _CanShow() or not questId or not line:IsMouseOver() then
        TrackerQuestTooltip.Hide()
        return
    end

    local titleLine = _GetTitleLine(line)
    tooltip:SetOwner(titleLine, "ANCHOR_NONE")
    tooltip:SetPoint("BOTTOMLEFT", titleLine, "TOPLEFT")
    -- Keep native rendering in its secure accessor path, including the title and solo player's progress.
    -- Missing native data hides the tooltip; keep refreshing while hovered so it can recover.
    if not tooltip:SetQuestPartyProgress(questId, false, false) then
        tooltip:Hide()
    end
end

---@param line TrackerLineFrame
function TrackerQuestTooltip.Show(line)
    TrackerQuestTooltip.Hide()
    if not _CanShow() or not _GetQuestId(line) then
        return
    end

    if not tooltip then
        tooltip = CreateFrame("GameTooltip", "QuestieTrackerQuestTooltip", UIParent, "GameTooltipTemplate")
        tooltip:Hide()
        QuestieTooltips.RegisterNativeQuestTooltip(tooltip)
    end
    if type(tooltip.SetQuestPartyProgress) ~= "function" then
        return
    end

    hoveredLine = line
    _Refresh()
    if hoveredLine then
        refreshTicker = C_Timer.NewTicker(REFRESH_INTERVAL, _Refresh)
    end
end
