--Contains functions to fetch the Quest Experiance for quests.
---@class QuestXP : Module
local QuestXP = QuestieLoader:CreateModule("QuestXP")

---@class QuestId
---@class Level
---@class XP

---@type table<QuestId,table<Level,XP>>
QuestXP.db = {}

local floor = floor

---@param xp number
---@param qLevel Level
---@param ignorePlayerLevel boolean
---@return number
local function getAdjustedXP(xp, qLevel, ignorePlayerLevel)
    local charLevel = UnitLevel("player");
    local expansionLevel = GetExpansionLevel();
    if (charLevel == 60 + 10 * expansionLevel and not ignorePlayerLevel) then -- 60 for classic, 70 for tbc and 80 for wotlk
        return 0;
    end

    local diffFactor = 2 * (qLevel - charLevel) + 20;
    if (diffFactor < 1) then
        diffFactor = 1;
    elseif (diffFactor > 10) then
        diffFactor = 10;
    end

    xp = xp * diffFactor / 10;
    --? I am unsure if the first xp <= 100 is actually correct...
    if (xp <= 100) then
        xp = 5 * floor((xp + 2) / 5);
    elseif (xp <= 500) then
        xp = 10 * floor((xp + 5) / 10);
    elseif (xp <= 1000) then
        xp = 25 * floor((xp + 12) / 25);
    else
        xp = 50 * floor((xp + 25) / 50);
    end

    return xp;
end


---Get the adjusted XP for a quest.
---@param questID QuestId
---@param ignorePlayerLevel boolean
---@return number experience
function QuestXP:GetQuestLogRewardXP(questID, ignorePlayerLevel)
    -- Return 0 if quest ID is not found for some reason
    if (questID == nil) then return 0 end
    ---@type number
    local adjustedXP = 0
    if QuestXP.db[questID] ~= nil then
        local level = QuestXP.db[questID][1]
        local xp = QuestXP.db[questID][2]

        adjustedXP = getAdjustedXP(xp, level, ignorePlayerLevel)
    end
    
    return adjustedXP
end