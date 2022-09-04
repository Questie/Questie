---@class DailyQuests
local DailyQuests = QuestieLoader:CreateModule("DailyQuests");
local _DailyQuests = {}

local IsQuestFlaggedCompleted = IsQuestFlaggedCompleted or C_QuestLog.IsQuestFlaggedCompleted

---@type QuestieMap
local QuestieMap = QuestieLoader:ImportModule("QuestieMap");
---@type QuestieQuest
local QuestieQuest = QuestieLoader:ImportModule("QuestieQuest");
---@type QuestieTooltips
local QuestieTooltips = QuestieLoader:ImportModule("QuestieTooltips");
---@type QuestiePlayer
local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer");

local nhcDailyIds, hcDailyIds, cookingDailyIds, fishingDailyIds, pvpDailyIds

local lastCheck

---@param message string
---@return nil
function DailyQuests:FilterDailies(message, _, _)
    if message and Questie.db.char.showRepeatableQuests and QuestiePlayer.GetPlayerLevel() == 70 then
        -- If the REPUTABLE message is empty, i.e contains "::::::::::" we don't count it as a check.
        if (not lastCheck) and not string.find(message, "::::::::::") then
            lastCheck = GetTime();
        elseif lastCheck and GetTime() - lastCheck < 10 and not string.find(message, "::::::::::") then
            lastCheck = GetTime();
            return;
        end

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
-- /run Questie.db.char.hiddenDailies = {nhc={},hc={},cooking={},fishing={},pvp={}}

---@param message string
---@return number, number, number, number, number
function _DailyQuests:GetDailyIds(message)
    -- Each questId is followed by the timestamp from GetQuestResetTime(). We don't use that timestamp (yet)
    local _, _, nhcQuestId, _, hcQuestId, _, cookingQuestId, _, fishingQuestId, _, pvpQuestId, _ = strsplit(":", message);

    return tonumber(nhcQuestId) or 0,
        tonumber(hcQuestId) or 0,
        tonumber(cookingQuestId) or 0,
        tonumber(fishingQuestId) or 0,
        tonumber(pvpQuestId) or 0;
end

---@param nhcQuestId number
---@param hcQuestId number
---@param cookingQuestId number
---@param fishingQuestId number
---@param pvpQuestId number
---@return boolean
function _DailyQuests:ResetIfRequired(nhcQuestId, hcQuestId, cookingQuestId, fishingQuestId, pvpQuestId)
    local somethingChanged = false
    if nhcQuestId > 0 and (Questie.db.char.hiddenDailies.nhc[nhcQuestId] or (not next(Questie.db.char.hiddenDailies.nhc))) and (not IsQuestFlaggedCompleted(nhcQuestId)) then
        Questie.db.char.hiddenDailies.nhc = {};
        somethingChanged = true;
    end
    if hcQuestId > 0 and (Questie.db.char.hiddenDailies.hc[hcQuestId] or (not next(Questie.db.char.hiddenDailies.hc))) and (not IsQuestFlaggedCompleted(hcQuestId)) then
        Questie.db.char.hiddenDailies.hc = {};
        somethingChanged = true;
    end
    if cookingQuestId > 0 and (Questie.db.char.hiddenDailies.cooking[cookingQuestId] or (not next(Questie.db.char.hiddenDailies.cooking))) and (not IsQuestFlaggedCompleted(cookingQuestId)) then
        Questie.db.char.hiddenDailies.cooking = {};
        somethingChanged = true;
    end
    if fishingQuestId > 0 and (Questie.db.char.hiddenDailies.fishing[fishingQuestId] or (not next(Questie.db.char.hiddenDailies.fishing))) and (not IsQuestFlaggedCompleted(fishingQuestId)) then
        Questie.db.char.hiddenDailies.fishing = {};
        somethingChanged = true;
    end
    if pvpQuestId > 0 and (Questie.db.char.hiddenDailies.pvp[pvpQuestId] or (not next(Questie.db.char.hiddenDailies.pvp))) and (not IsQuestFlaggedCompleted(pvpQuestId)) then
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

    for questId, _ in pairs(possibleQuestIds) do
        if questId == currentQuestId then
            _DailyQuests:ShowDailyQuest(questId);
            Questie.db.char.hiddenDailies[type][questId] = nil;
        else
            -- If the quest is not in the questlog remove all frames
            if (GetQuestLogIndexByID(questId) == 0) then
                _DailyQuests:HideDailyQuest(questId);
            end
            Questie.db.char.hiddenDailies[type][questId] = true;
        end
    end
end

---@param questId number
---@return nil
function _DailyQuests:HideDailyQuest(questId)
    QuestieMap:UnloadQuestFrames(questId);
    QuestieTooltips:RemoveQuest(questId);
end

---@param questId number
---@return nil
function _DailyQuests:ShowDailyQuest(questId)
    if (not QuestieMap.questIdFrames[questId]) then
        QuestieQuest:DrawDailyQuest(questId);
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

---@param questId number
---@return boolean
function DailyQuests:IsDailyQuest(questId)
    return nhcDailyIds[questId] ~= nil or
            hcDailyIds[questId] ~= nil or
            cookingDailyIds[questId] ~= nil or
            fishingDailyIds[questId] ~= nil or
            pvpDailyIds[questId] ~= nil;
end

nhcDailyIds = {
    [11364] = true,
    [11371] = true,
    [11376] = true,
    [11383] = true,
    [11385] = true,
    [11387] = true,
    [11389] = true,
    [11500] = true,
};

hcDailyIds = {
    [11354] = true,
    [11362] = true,
    [11363] = true,
    [11368] = true,
    [11369] = true,
    [11370] = true,
    [11372] = true,
    [11373] = true,
    [11374] = true,
    [11375] = true,
    [11378] = true,
    [11382] = true,
    [11384] = true,
    [11386] = true,
    [11388] = true,
    [11499] = true,
};

cookingDailyIds = {
    [11377] = true,
    [11379] = true,
    [11380] = true,
    [11381] = true,
};

fishingDailyIds = {
    [11667] = true,
    [11665] = true,
    [11666] = true,
    [11668] = true,
    [11669] = true,
};

pvpDailyIds = {
    [11335] = true,
    [11336] = true,
    [11337] = true,
    [11338] = true,
    [11339] = true,
    [11340] = true,
    [11341] = true,
    [11342] = true,
}