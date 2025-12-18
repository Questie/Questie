--Contains functions to fetch the Quest Experiance for quests.
---@class QuestXP
local QuestXP = QuestieLoader:CreateModule("QuestXP")

---@type Expansions
local Expansions = QuestieLoader:ImportModule("Expansions")

---@type table<QuestId,table<Level,XP>> -- { questId={level, xp}, ..... }
QuestXP.db = {}

local floor = floor
local UnitLevel = UnitLevel

local globalXPMultiplier = 1
local isDiscovererDelightActive = false

local _GetBuffMultiplier

function QuestXP.Init()
    if Questie.IsSoD or Expansions.Current >= Expansions.Wotlk and globalXPMultiplier == 1 then
        for i = 1, 40 do
            local _, _, _, _, _, _, _, _, _, buffSpellId = UnitBuff("player", i)

            if buffSpellId == 377749 then
                -- Joyous Journeys is active - 50% bonus XP
                globalXPMultiplier = 1.5
                break
            end

            if buffSpellId == 436412 then
                -- Discoverer's Delight is active - 150% bonus XP till level 50 and 50% after
                globalXPMultiplier = UnitLevel("player") < 50 and 2.5 or 1.5
                isDiscovererDelightActive = true
                break
            end
        end
    end

    if Expansions.Current >= Expansions.Wotlk then
        -- Handle Fast Track "Guild Perk"
        -- We don't check for Rank 1, because Blizzard made Rank 2 active for all characters
        local isFastTrackActive = IsSpellKnown(78632) -- Fast Track (Rank 2)
        if isFastTrackActive then
            globalXPMultiplier = globalXPMultiplier + 0.1 -- 10% bonus XP
        end
    end
end

---@param xp XP
---@param qLevel Level
---@param ignorePlayerLevel boolean
---@return XP experience
local function getAdjustedXP(xp, qLevel, ignorePlayerLevel)
    local charLevel = UnitLevel("player")
    if charLevel == GetMaxPlayerLevel() and (not ignorePlayerLevel) then
        return 0
    end

    --? These calculations are fetched from cmangos
    local xpMultiplier = 2 * (qLevel - charLevel) + 20
    if (xpMultiplier < 1) then
        xpMultiplier = 1
    elseif (xpMultiplier > 10) then
        xpMultiplier = 10
    end

    xp = xp * xpMultiplier / 10
    --? I am unsure if the first xp <= 100 is actually correct... because some 85 xp quests should actually give 90
    if (xp <= 100) then
        xp = 5 * floor((xp + 2) / 5)
    elseif (xp <= 500) then
        xp = 10 * floor((xp + 5) / 10)
    elseif (xp <= 1000) then
        xp = 25 * floor((xp + 12) / 25)
    else
        xp = 50 * floor((xp + 25) / 50)
    end

    return floor(xp * (globalXPMultiplier + _GetBuffMultiplier()))
end


---Get the adjusted XP for a quest.
---@param questId QuestId
---@param ignorePlayerLevel boolean
---@return XP experience
function QuestXP:GetQuestLogRewardXP(questId, ignorePlayerLevel)
    if QuestXP.db[questId] then
        local level = QuestXP.db[questId][1]
        local xp = QuestXP.db[questId][2]

        --? We have -1 as a level for quests that are event quests and so on for TBC and WOTLK.
        if level > 0 and xp > 0 then
            return getAdjustedXP(xp, level, ignorePlayerLevel)
        end
    end

    -- Return 0 if questId or xp data is not found for some reason
    return 0
end

local exclusions = {
    [78612] = true,
    [78872] = true,
    [79101] = true,
    [79102] = true,
    [79103] = true,
    [80307] = true,
    [80308] = true,
    [80309] = true,
}

function QuestXP.GetQuestRewardMoney(questId)
    local modifier = 1
    if isDiscovererDelightActive and (not exclusions[questId]) then
        modifier = 3
    end
    return floor(GetQuestLogRewardMoney(questId) * modifier)
end

---Check for temporary buffs being active that give XP bonuses.
---@return number
_GetBuffMultiplier = function()
    local buffMultiplier = 0
    for i = 1, 40 do
        local _, _, _, _, _, _, _, _, _, spellId, _ = UnitAura("player", i, "HELPFUL")
        if spellId == nil then
            break
        end

        if spellId == 46668 then
            buffMultiplier = buffMultiplier + 0.1 -- 10% bonus reputation from Darkmoon Faire buff
        elseif spellId == 95987 then
            buffMultiplier = buffMultiplier + 0.1 -- 10% bonus reputation from Unburdened (Hallow's End Alliance)
        elseif spellId == 24705 then
            buffMultiplier = buffMultiplier + 0.1 -- 10% bonus reputation from Grim Visage (Hallow's End Horde)
        end
    end

    return buffMultiplier
end
