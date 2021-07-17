---@class DailyQuests
local DailyQuests = QuestieLoader:CreateModule("DailyQuests");
local _DailyQuests = {}

local IsQuestFlaggedCompleted = IsQuestFlaggedCompleted or C_QuestLog.IsQuestFlaggedCompleted

---@type QuestieMap
local QuestieMap = QuestieLoader:ImportModule("QuestieMap");

local nhcDailyIds, hcDailyIds, cookingDailyIds, fishingDailyIds, pvpDailyIds


---@param message string
---@return nil
function DailyQuests:FilterDailies(message, _, _)
    if message then
        local nhcQuestId, hcQuestId, cookingQuestId, fishingQuestId, pvpQuestId = _DailyQuests:GetDailyIds(message);

        local somethingChanged = _DailyQuests:ResetIfRequired(nhcQuestId, hcQuestId, cookingQuestId, fishingQuestId, pvpQuestId);
        if (not somethingChanged) then
            -- We are already showing the correct quests
            return;
        end

        _DailyQuests:HandleDailyQuests(nhcDailyIds, nhcQuestId, "nhc");
        _DailyQuests:HandleDailyQuests(hcDailyIds, hcQuestId, "hc");
        _DailyQuests:HandleDailyQuests(cookingDailyIds, cookingQuestId, "cooking");
        _DailyQuests:HandleDailyQuests(fishingDailyIds, fishingQuestId, "fishing");
        _DailyQuests:HandleDailyQuests(pvpDailyIds, pvpQuestId, "pvp");
    end
end

-- /run DailyQuests:FilterDailies("0:0:11364:0:11354:0:11377:0:11667:0:11340:0")

---@param message string
---@return table<number, number, number, number, number>
function _DailyQuests:GetDailyIds(message)
    -- Each questId is followed by the timestamp from GetQuestResetTime(). We don't use that timestamp (yet)
    local _, _, nhcQuestId, _, hcQuestId, _, cookingQuestId, _, fishingQuestId, _, pvpQuestId, _ = strsplit(":", message);

    return tonumber(nhcQuestId) or 0,
        tonumber(hcQuestId) or 0,
        tonumber(cookingQuestId) or 0,
        tonumber(fishingQuestId) or 0,
        tonumber(pvpQuestId) or 0
end

---@param nhcQuestId number
---@param hcQuestId number
---@param cookingQuestId number
---@param fishingQuestId number
---@param pvpQuestId number
---@return boolean
function _DailyQuests:ResetIfRequired(nhcQuestId, hcQuestId, cookingQuestId, fishingQuestId, pvpQuestId)
    local somethingChanged = false
    if (Questie.db.char.hiddenDailies.nhc[nhcQuestId] or (not next(Questie.db.char.hiddenDailies.nhc))) and (not IsQuestFlaggedCompleted(nhcQuestId)) then
        Questie.db.char.hiddenDailies.nhc = {};
        somethingChanged = true;
    end
    if (Questie.db.char.hiddenDailies.hc[hcQuestId] or (not next(Questie.db.char.hiddenDailies.hc))) and (not IsQuestFlaggedCompleted(hcQuestId)) then
        Questie.db.char.hiddenDailies.hc = {};
        somethingChanged = true;
    end
    if (Questie.db.char.hiddenDailies.cooking[cookingQuestId] or (not next(Questie.db.char.hiddenDailies.cooking))) and (not IsQuestFlaggedCompleted(cookingQuestId)) then
        Questie.db.char.hiddenDailies.cooking = {};
        somethingChanged = true;
    end
    if (Questie.db.char.hiddenDailies.fishing[fishingQuestId] or (not next(Questie.db.char.hiddenDailies.fishing))) and (not IsQuestFlaggedCompleted(fishingQuestId)) then
        Questie.db.char.hiddenDailies.fishing = {};
        somethingChanged = true;
    end
    if (Questie.db.char.hiddenDailies.pvp[pvpQuestId] or (not next(Questie.db.char.hiddenDailies.pvp))) and (not IsQuestFlaggedCompleted(pvpQuestId)) then
        Questie.db.char.hiddenDailies.pvp = {};
        somethingChanged = true;
    end

    return somethingChanged;
end

---@param possibleQuestIds table<number, number>
---@param currentQuestId number
---@param type string
---@return nil
function _DailyQuests:HandleDailyQuests(possibleQuestIds, currentQuestId, type)
    if currentQuestId == 0 then
        return;
    end

    for _, questId in pairs(possibleQuestIds) do
        if (not (questId == currentQuestId)) then
            _DailyQuests:HideDailyQuest(questId);
            Questie.db.char.hiddenDailies[type][questId] = true;
        else
            _DailyQuests:ShowDailyQuest(questId);
            Questie.db.char.hiddenDailies[type][questId] = nil;
        end
    end
end

---@param questId number
---@return nil
function _DailyQuests:HideDailyQuest(questId)
    if QuestieMap.questIdFrames[questId] then
        for _, iconName in pairs(QuestieMap.questIdFrames[questId]) do
            _G[iconName]:FakeHide()
        end
    end
end

---@param questId number
---@return nil
function _DailyQuests:ShowDailyQuest(questId)
    if QuestieMap.questIdFrames[questId] then
        for _, iconName in pairs(QuestieMap.questIdFrames[questId]) do
            _G[iconName]:FakeShow()
        end
    end
end

---@param questId number
---@return boolean
function DailyQuests:IsActiveDailyQuest(questId)
    local hiddenQuests = Questie.db.char.hiddenDailies
    return not (hiddenQuests.nhc[questId] or
        hiddenQuests.hc[questId] or
        hiddenQuests.cooking[questId] or
        hiddenQuests.fishing[questId] or
        hiddenQuests.pvp[questId]);
end

nhcDailyIds = {
    11364,
    11371,
    11376,
    11383,
    11385,
    11387,
    11389,
    11500,
};

hcDailyIds = {
    11354,
    11362,
    11363,
    11368,
    11369,
    11370,
    11372,
    11373,
    11374,
    11375,
    11378,
    11382,
    11384,
    11386,
    11388,
};

cookingDailyIds = {
    11377,
    11379,
    11380,
    11381,
};

fishingDailyIds = {
    11667,
    11665,
    11666,
    11668,
    11669,
};

pvpDailyIds = {
    11336,
    11337,
    11338,
    11339,
    11340,
    11341,
    11342,
}