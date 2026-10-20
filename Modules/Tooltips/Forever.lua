---@class Forever
local Forever = QuestieLoader:CreateModule("Forever")

---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

---Renders the native quest rows of one tooltip rebuild. Objective rows belong to the most recent title row.
---@class ForeverFormatter
---@field Title fun(questId: any, title: any): string
---@field Objective fun(text: any): string

local function _IsSecret(value)
    return issecretvalue and issecretvalue(value)
end

local function _IsPublicTable(value)
    return not _IsSecret(value) and type(value) == "table" and not (issecrettable and issecrettable(value))
end

local function _ColoredQuestName(questId)
    return QuestieLib:GetColoredQuestName(questId, Questie.db.profile.enableTooltipsQuestLevel, true)
end

-- Unknown quests keep Blizzard's title. A readable ID still allows Questie's normal title lookup.
local function _UnknownTitle(questId, title)
    if not _IsSecret(questId) and type(questId) == "number" then
        local found, name = pcall(_ColoredQuestName, questId)
        if found then return name end
    end
    local format = Questie.db.profile.enableTooltipsQuestLevel and "[??] %s" or "%s"
    local id = "???"
    if Questie.db.profile.enableTooltipsQuestID then
        format = format .. " " .. l10n("(") .. "%s" .. l10n(")")
        if _IsSecret(questId) or type(questId) == "number" then id = questId end
    end
    return string.format(format, title, id)
end

local function _PlainObjective(text)
    return text
end

---@type ForeverFormatter
local unknownFormatter = {Title = _UnknownTitle, Objective = _PlainObjective}

local function _CanSelect()
    return Questie.IsForever and Enum and Enum.CollationStrength and Enum.CollationStrength.Identical
        and Enum.NormalizationForm and Enum.NormalizationForm.Nfc
        and C_Intl and type(C_Intl.CompareStrings) == "function" and type(C_Intl.IsNormalized) == "function"
        and C_StringUtil and type(C_StringUtil.TruncateWhenZero) == "function" and type(C_StringUtil.WrapString) == "function"
        and C_CurveUtil and type(C_CurveUtil.EvaluateColorValueFromBoolean) == "function"
        and C_QuestLog and type(C_QuestLog.GetNumQuestLogEntries) == "function" and type(C_QuestLog.GetInfo) == "function"
end

-- Matching objectives only matters when progress changes their color; "white" and "minimal" never do.
local function _ColorsObjectives()
    return QuestieLib:GetRGBForObjective({fulfilled = 0, required = 1}) ~= QuestieLib:GetRGBForObjective({fulfilled = 1, required = 1})
end

-- A native objective row repeats the quest log's objective text exactly, so the log supplies its readable counters.
local function _GetObjectives(questId)
    local objectives, seen = {}, {}
    for _, objective in ipairs(C_QuestLog.GetQuestObjectives(questId) or {}) do
        if _IsPublicTable(objective) then
            local text, fulfilled, required = objective.text, objective.numFulfilled, objective.numRequired
            -- Repeated text would open two fragments for one row; the first entry wins.
            if not (_IsSecret(text) or _IsSecret(fulfilled) or _IsSecret(required))
                and type(text) == "string" and text ~= "" and not seen[text] then
                seen[text] = true
                local counters = {}
                if type(fulfilled) == "number" and type(required) == "number" and required > 0 then
                    counters = {fulfilled = fulfilled, required = required}
                end
                objectives[#objectives + 1] = {text = text, presentation = QuestieLib:GetRGBForObjective(counters) .. text .. "|r"}
            end
        end
    end
    return objectives
end

local function _GetCandidate(questId, colorsObjectives)
    -- A quest missing from Questie's database keeps Blizzard's title but can still color its objectives.
    local found, title = pcall(_ColoredQuestName, questId)
    -- An unavailable objective list only loses objective colors, not the quest's title.
    local listed, objectives = false, nil
    if colorsObjectives then listed, objectives = pcall(_GetObjectives, questId) end
    return {
        idText = string.format("%d", questId),
        title = found and title or nil,
        objectives = listed and objectives or {},
    }
end

local function _BuildCandidates(colorsObjectives)
    local candidates, seen = {}, {}
    for index = 1, C_QuestLog.GetNumQuestLogEntries() do
        local info = C_QuestLog.GetInfo(index)
        if _IsPublicTable(info) then
            local questId = info.questID
            if not _IsSecret(info.isHeader) and not info.isHeader and not _IsSecret(questId)
                and type(questId) == "number" and questId > 0 and not seen[questId] then
                seen[questId] = true
                local ok, candidate = pcall(_GetCandidate, questId, colorsObjectives)
                if ok then candidates[#candidates + 1] = candidate end
            end
        end
    end
    return candidates
end

-- Equal text compares as 0, which becomes empty NFC-normalized text. Any difference retains a decomposed
-- e + combining acute accent, so concatenated markers stay normalized only when every comparison matched.
-- The marker and anything derived from it may be secret and must never reach a Lua branch.
local function _MismatchMarker(text, publicText)
    local comparison = C_Intl.CompareStrings(text, publicText, Enum.CollationStrength.Identical)
    if not _IsSecret(comparison) and type(comparison) ~= "number" then
        error("Quest text comparison unavailable")
    end
    return C_StringUtil.WrapString(C_StringUtil.TruncateWhenZero(comparison), "e\204\129", "")
end

local function _AllMatched(markers)
    return C_Intl.IsNormalized(markers, Enum.NormalizationForm.Nfc)
end

local function _DisplayFragment(gate, presentation)
    local token = C_StringUtil.TruncateWhenZero(gate)
    -- A matching "1" completes a glyph-free color code; an empty token suppresses the entire fragment.
    return C_StringUtil.WrapString(token, "|c0000000", "|r" .. presentation)
end

-- Returns the display text and each candidate's title mismatch marker for the objective rows that follow.
local function _SelectTitle(candidates, questId, title)
    local idText = string.format("%d", questId)
    local unknown = _UnknownTitle(questId, title)
    local output, unmatched, selection = "", 1, {}
    for index, candidate in ipairs(candidates) do
        selection[index] = _MismatchMarker(idText, candidate.idText)
        local matches = _AllMatched(selection[index])
        unmatched = C_CurveUtil.EvaluateColorValueFromBoolean(matches, 0, unmatched)
        output = output .. _DisplayFragment(C_CurveUtil.EvaluateColorValueFromBoolean(matches, 1, 0), candidate.title or unknown)
    end
    return output .. _DisplayFragment(unmatched, unknown), selection
end

local function _SelectObjective(candidates, selection, text)
    local output, unmatched = "", 1
    for index, candidate in ipairs(candidates) do
        for _, objective in ipairs(candidate.objectives) do
            -- Only the selected title's objectives can open. The same text under another quest stays closed.
            local matches = _AllMatched(selection[index] .. _MismatchMarker(text, objective.text))
            unmatched = C_CurveUtil.EvaluateColorValueFromBoolean(matches, 0, unmatched)
            output = output .. _DisplayFragment(C_CurveUtil.EvaluateColorValueFromBoolean(matches, 1, 0), objective.presentation)
        end
    end
    return output .. _DisplayFragment(unmatched, text)
end

---Builds public quest-log candidates once for a native tooltip rebuild. Discard the formatter on tooltip clear.
---Rendering accepts possibly secret IDs and text without exposing the selected quest. Only the latest title's
---possibly secret mismatch markers are kept, until the next title row or tooltip clear.
---@return ForeverFormatter
function Forever.CreateFormatter()
    if not _CanSelect() then return unknownFormatter end
    local colorsObjectives = _ColorsObjectives()
    local ok, candidates = pcall(_BuildCandidates, colorsObjectives)
    if not ok or #candidates == 0 then return unknownFormatter end

    local selection
    return {
        Title = function(questId, title)
            selection = nil
            if not _IsSecret(questId) and type(questId) ~= "number" then return _UnknownTitle(questId, title) end
            -- Native helper availability/locale failures must not discard Blizzard's information or expose a partial match.
            local rendered, text, markers = pcall(_SelectTitle, candidates, questId, title)
            if not rendered then return _UnknownTitle(questId, title) end
            selection = markers
            return text
        end,
        Objective = function(text)
            if not (colorsObjectives and selection) then return text end
            local rendered, output = pcall(_SelectObjective, candidates, selection, text)
            if rendered then return output end
            return text
        end,
    }
end
