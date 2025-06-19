---@type AvailableQuests
local AvailableQuests = QuestieLoader:ImportModule("AvailableQuests")

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
---@type QuestiePlayer
local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
---@type QuestieEvent
local QuestieEvent = QuestieLoader:ImportModule("QuestieEvent")

local levelRequirementCache = {}
AvailableQuests.levelRequirementCache = levelRequirementCache

---@param questId QuestId
---@param minLevel Level @The level a quest must have at least to be shown
---@param maxLevel Level @The level a quest can have at most to be shown
---@param playerLevel Level? @Pass player level to avoid calling UnitLevel or to use custom level
---@return boolean
function AvailableQuests.IsLevelRequirementsFulfilled(questId, minLevel, maxLevel, playerLevel)
    if levelRequirementCache[questId] ~= nil then
        return levelRequirementCache[questId]
    end

    local level, requiredLevel, requiredMaxLevel = QuestieLib.GetTbcLevel(questId, playerLevel)

    local parentQuestId = QuestieDB.QueryQuestSingle(questId, "parentQuest")
    if parentQuestId and QuestiePlayer.currentQuestlog[parentQuestId] then
        -- If the quest is in the player's log already, there's no need to do any logic here, it must already be available
        levelRequirementCache[questId] = true
        return true
    end

    if (Questie.db.profile.lowLevelStyle ~= Questie.LOWLEVEL_RANGE) and
        minLevel > requiredLevel and QuestieEvent.activeQuests[questId] and (requiredMaxLevel == 0 or playerLevel < requiredMaxLevel) then
        levelRequirementCache[questId] = true
        return true
    end

    if (Questie.IsSoD == true) and (QuestieDB.IsSoDRuneQuest(questId) == true) and (requiredLevel <= playerLevel) then
        -- Season of Discovery Rune quests are still shown when trivial
        levelRequirementCache[questId] = true
        return true
    end

    if maxLevel >= level then
        if (Questie.db.profile.lowLevelStyle ~= Questie.LOWLEVEL_ALL) and minLevel > level then
            -- The quest level is too low and trivial quests are not shown
            levelRequirementCache[questId] = false
            return false
        end
    else
        if (Questie.db.profile.lowLevelStyle == Questie.LOWLEVEL_RANGE) or maxLevel < requiredLevel then
            -- Either an absolute level range is set and maxLevel < level OR the maxLevel is manually set to a lower value
            levelRequirementCache[questId] = false
            return false
        end
    end

    if maxLevel < requiredLevel then
        -- Either the players level is not high enough or the maxLevel is manually set to a lower value
        levelRequirementCache[questId] = false
        return false
    end

    if requiredMaxLevel ~= 0 and playerLevel > requiredMaxLevel then
        -- The players level exceeds the requiredMaxLevel of a quest
        levelRequirementCache[questId] = false
        return false
    end

    levelRequirementCache[questId] = true
    return true
end

-- This needs to be called when the player levels up and when the lowLevelStyle is changed
function AvailableQuests.ResetLevelRequirementCache()
    levelRequirementCache = {}
    AvailableQuests.levelRequirementCache = levelRequirementCache
end
