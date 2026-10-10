---@class Forever
local Forever = QuestieLoader:CreateModule("Forever")

---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")

---@alias ForeverFormatter fun(questId: any, title: any): string

local function _IsSecret(value)
    return issecretvalue and issecretvalue(value)
end

local function _FormatTitle(questId, title, prefix)
    local format = prefix .. "%s"
    local id = "???"
    if Questie.db.profile.enableTooltipsQuestID then
        format = format .. " (%s)"
        if _IsSecret(questId) or type(questId) == "number" then id = questId end
    end
    return string.format(format, title, id)
end

local function _UnknownTitle(questId, title)
    local prefix = Questie.db.profile.enableTooltipsQuestLevel == false and "" or "[??] "
    return _FormatTitle(questId, title, prefix)
end

local function _CanSelect()
    return Questie.IsForever and Enum and Enum.CollationStrength and Enum.CollationStrength.Identical
        and Enum.NormalizationForm and Enum.NormalizationForm.Nfc
        and _G.C_Intl and type(_G.C_Intl.CompareStrings) == "function" and type(_G.C_Intl.IsNormalized) == "function"
        and _G.C_StringUtil and type(_G.C_StringUtil.TruncateWhenZero) == "function" and type(_G.C_StringUtil.WrapString) == "function"
        and _G.C_CurveUtil and type(_G.C_CurveUtil.EvaluateColorValueFromBoolean) == "function"
        and C_QuestLog and type(C_QuestLog.GetNumQuestLogEntries) == "function" and type(C_QuestLog.GetInfo) == "function"
        and type(C_QuestLog.GetQuestDifficultyLevel) == "function"
        and type(QuestieLib.GetDifficultyColorPercent) == "function" and type(_G.CreateColor) == "function"
end

local function _GetCandidate(questId)
    -- Resolve level and Questie's normal difficulty palette using only public candidate IDs.
    local level = C_QuestLog.GetQuestDifficultyLevel(questId)
    if _IsSecret(level) or type(level) ~= "number" or level <= 0 then return end
    local r, g, b = QuestieLib:GetDifficultyColorPercent(level, questId)
    if _IsSecret(r) or _IsSecret(g) or _IsSecret(b) then return end
    return {
        idText = string.format("%d", questId),
        level = level,
        colorMarkup = _G.CreateColor(r, g, b, 1):GenerateHexColorMarkup(),
    }
end

local function _BuildCandidates()
    local candidates, seen = {}, {}
    for index = 1, C_QuestLog.GetNumQuestLogEntries() do
        local info = C_QuestLog.GetInfo(index)
        if not _IsSecret(info) and type(info) == "table" and not (issecrettable and issecrettable(info)) then
            local questId = info.questID
            if not _IsSecret(info.isHeader) and not info.isHeader and not _IsSecret(questId)
                and type(questId) == "number" and questId > 0 and not seen[questId] then
                seen[questId] = true
                local ok, candidate = pcall(_GetCandidate, questId)
                if ok and candidate then candidates[#candidates + 1] = candidate end
            end
        end
    end
    return candidates
end

local function _DisplayFragment(gate, presentation)
    local token = _G.C_StringUtil.TruncateWhenZero(gate)
    -- A matching "1" completes a glyph-free color code; an empty token suppresses the entire fragment.
    return _G.C_StringUtil.WrapString(token, "|c0000000", "|r" .. presentation)
end

local function _SelectTitle(candidates, questId, title)
    local idText = string.format("%d", questId)
    local output, unmatched = "", 1
    for _, candidate in ipairs(candidates) do
        local comparison = _G.C_Intl.CompareStrings(idText, candidate.idText, Enum.CollationStrength.Identical)
        if not _IsSecret(comparison) and type(comparison) ~= "number" then
            error("Quest title comparison unavailable")
        end
        -- Equality becomes empty text, which is NFC-normalized. A mismatch retains a decomposed
        -- e + combining acute accent. Native helpers produce the match gate without a Lua branch.
        local mismatch = _G.C_StringUtil.TruncateWhenZero(comparison)
        local marker = _G.C_StringUtil.WrapString(mismatch, "e\204\129", "")
        local matches = _G.C_Intl.IsNormalized(marker, Enum.NormalizationForm.Nfc)
        local gate = _G.C_CurveUtil.EvaluateColorValueFromBoolean(matches, 1, 0)
        unmatched = _G.C_CurveUtil.EvaluateColorValueFromBoolean(matches, 0, unmatched)
        local prefix = Questie.db.profile.enableTooltipsQuestLevel == false and "" or string.format("[%d] ", candidate.level)
        local presentation = candidate.colorMarkup .. _FormatTitle(questId, title, prefix) .. "|r"
        output = output .. _DisplayFragment(gate, presentation)
    end
    return output .. _DisplayFragment(unmatched, _UnknownTitle(questId, title))
end

---Builds public candidates once for a native tooltip rebuild. Discard the formatter on tooltip clear.
---The returned function renders a possibly secret ID/title without retaining inputs or exposing the selected ID.
---@return ForeverFormatter
function Forever.CreateFormatter()
    if not _CanSelect() then return _UnknownTitle end
    local ok, candidates = pcall(_BuildCandidates)
    if not ok or #candidates == 0 then return _UnknownTitle end
    return function(questId, title)
        if not _IsSecret(questId) and type(questId) ~= "number" then return _UnknownTitle(questId, title) end
        -- Native helper availability/locale failures must not discard Blizzard's information or expose a partial match.
        local selected, text = pcall(_SelectTitle, candidates, questId, title)
        if selected then return text end
        return _UnknownTitle(questId, title)
    end
end
