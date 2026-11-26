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
---@type Forever
local Forever = QuestieLoader:ImportModule("Forever")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")

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

local function _IsShareBound()
    local bind = Questie.db.profile.trackerbindShareQuest
    return bind ~= nil and bind ~= "disabled"
end

---@param questId QuestId
---@return boolean
local function _CanShare(questId)
    return _IsShareBound() and TrackerUtils.CanShareQuest(questId)
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

local INDENT = "   "

---@param quest TrackerQuest
---@param members QuestPartyMember[]
local function _RenderParty(quest, members)
    tooltip:SetText(TrackerData.GetColoredQuestName(quest, Questie.db.profile.enableTooltipsQuestLevel, true))

    local pending, longest = {}, 0
    for _, member in ipairs(members) do
        local name = member.classColor .. member.name .. "|r"
        local complete = member.complete or (member.isPlayer and (quest:IsComplete() == 1 or quest.isComplete))
        if complete then
            tooltip:AddLine(INDENT .. Questie:Colorize(l10n("Quest Complete!"), "28FF28") .. " (" .. name .. ")", 238 / 255, 238 / 255, 238 / 255, false)
        else
            pending[#pending + 1] = {name = name, objectives = member.objectives}
            longest = math.max(longest, #member.objectives)
        end
    end

    for index = 1, longest do
        for _, member in ipairs(pending) do
            local objective = member.objectives[index]
            if objective then
                local counters = {fulfilled = objective.fulfilled, required = objective.required}
                local color = QuestieLib:GetRGBForObjective(counters)
                tooltip:AddLine(INDENT .. color .. objective.text .. "|r (" .. member.name .. ")", 238 / 255, 238 / 255, 238 / 255, false)
            end
        end
    end
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
    local quest = TrackerData.GetQuest(questId)
    local members = quest and _HasPartyProgress() and Forever.GetQuestPartyMembers(C_TooltipInfo.GetQuestPartyProgress(questId, true, false))
    if members then
        _RenderParty(quest, members)
    elseif _HasPartyProgress() then
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
    elseif _IsShareBound() then
        tooltip:AddLine(Questie:Colorize(l10n("(") .. l10n("Quest can't be shared") .. l10n(")"), "gray"))
    end
    -- Resizes the tooltip to the objective rows Questie widened after Blizzard laid them out
    tooltip:Show()
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
