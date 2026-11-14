---@class TrackerQuestTooltip
local TrackerQuestTooltip = QuestieLoader:CreateModule("TrackerQuestTooltip")

---@type TrackerData
local TrackerData = QuestieLoader:ImportModule("TrackerData")
---@type QuestieTooltips
local QuestieTooltips = QuestieLoader:ImportModule("QuestieTooltips")
---@type TrackerLinePool
local TrackerLinePool = QuestieLoader:ImportModule("TrackerLinePool")
---@type TrackerUtils
local TrackerUtils = QuestieLoader:ImportModule("TrackerUtils")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

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

local SHORTCUT_MODIFIERS = {shift = "Shift", ctrl = "Control", alt = "Alt"}

---@param bind string e.g. "shiftleft"
---@return string shortcut e.g. "Shift + Left Click"
local function _GetShortcutText(bind)
    local modifier, button = bind:match("^(%a-)(left)$")
    if (not modifier) then
        modifier, button = bind:match("^(%a-)(right)$")
    end
    local click = l10n(button == "left" and "Left Click" or "Right Click")
    if SHORTCUT_MODIFIERS[modifier] then
        return l10n(SHORTCUT_MODIFIERS[modifier]) .. " + " .. click
    end
    return click
end

---@param questId QuestId
---@return boolean
local function _CanShare(questId)
    local bind = Questie.db.profile.trackerbindShareQuest
    return bind ~= nil and bind ~= "disabled" and TrackerUtils.CanShareQuest(questId)
end

local function _HasPartyProgress()
    return C_TooltipInfo and type(C_TooltipInfo.GetQuestPartyProgress) == "function"
        and ((not tooltip) or type(tooltip.SetQuestPartyProgress) == "function")
end

---@param canShare boolean
local function _CanShow(canShare)
    return IsInGroup() and Questie.db.profile.enableTooltips and Questie.db.profile.trackerEnabled
        and (_HasPartyProgress() or canShare)
end

local function _Refresh()
    local line = hoveredLine
    local questId = line and _GetQuestId(line)
    if (not questId) or (not line:IsMouseOver()) then
        TrackerQuestTooltip.Hide()
        return
    end
    -- Checking the quest on Classic selects it in the quest log, so do it once per refresh
    local canShare = _CanShare(questId)
    if (not _CanShow(canShare)) then
        TrackerQuestTooltip.Hide()
        return
    end

    local titleLine = _GetTitleLine(line)
    tooltip:SetOwner(titleLine, "ANCHOR_NONE")
    tooltip:SetPoint("BOTTOMLEFT", titleLine, "TOPLEFT")
    if _HasPartyProgress() then
        -- Keep native rendering in its secure accessor path, including the title and solo player's progress.
        -- Missing native data hides the tooltip; keep refreshing while hovered so it can recover.
        if not tooltip:SetQuestPartyProgress(questId, false, false) then
            tooltip:Hide()
            return
        end
    else
        tooltip:SetText(TrackerData.GetColoredQuestName(TrackerData.GetQuest(questId), Questie.db.profile.enableTooltipsQuestLevel, true))
    end

    if canShare then
        local hint = l10n("(") .. _GetShortcutText(Questie.db.profile.trackerbindShareQuest) .. l10n(": ") .. l10n("Share Quest") .. l10n(")")
        tooltip:AddLine(Questie:Colorize(hint, "gray"))
        tooltip:Show()
    end
end

---@param line TrackerLineFrame
function TrackerQuestTooltip.Show(line)
    TrackerQuestTooltip.Hide()
    local questId = _GetQuestId(line)
    if (not questId) then
        return
    end
    local canShare = _CanShare(questId)
    if (not _CanShow(canShare)) then
        return
    end

    if not tooltip then
        tooltip = CreateFrame("GameTooltip", "QuestieTrackerQuestTooltip", UIParent, "GameTooltipTemplate")
        tooltip:Hide()
        QuestieTooltips.RegisterNativeQuestTooltip(tooltip)
    end
    -- Only the created tooltip tells if its template has the party progress accessor
    if (not _CanShow(canShare)) then
        return
    end

    hoveredLine = line
    _Refresh()
    if hoveredLine then
        refreshTicker = C_Timer.NewTicker(REFRESH_INTERVAL, _Refresh)
    end
end
