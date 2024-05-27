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

AvailableQuests.levelRequirementCache = {}

---@param questId QuestId
---@param minLevel Level @The level a quest must have at least to be shown
---@param maxLevel Level @The level a quest can have at most to be shown
---@param playerLevel Level? @Pass player level to avoid calling UnitLevel or to use custom level
---@return boolean
function AvailableQuests.IsLevelRequirementsFulfilled(questId, minLevel, maxLevel, playerLevel)
    if AvailableQuests.levelRequirementCache[questId] ~= nil then
        return AvailableQuests.levelRequirementCache[questId]
    end

    local level, requiredLevel, requiredMaxLevel = QuestieLib.GetTbcLevel(questId, playerLevel)

    --* QuestiePlayer.currentQuestlog[parentQuestId] logic is from QuestieDB.IsParentQuestActive, if you edit here, also edit there
    local parentQuestId = QuestieDB.QueryQuestSingle(questId, "parentQuest")
    if parentQuestId and QuestiePlayer.currentQuestlog[parentQuestId] then
        -- If the quest is in the player's log already, there's no need to do any logic here, it must already be available
        AvailableQuests.levelRequirementCache[questId] = true
        return true
    end

    --* QuestieEvent.activeQuests[questId] logic is from QuestieDB.IsParentQuestActive, if you edit here, also edit there
    if (Questie.db.profile.lowLevelStyle ~= Questie.LOWLEVEL_RANGE) and
        minLevel > requiredLevel and QuestieEvent.activeQuests[questId] then
        AvailableQuests.levelRequirementCache[questId] = true
        return true
    end

    if (Questie.IsSoD == true) and (QuestieDB.IsSoDRuneQuest(questId) == true) and (requiredLevel <= playerLevel) then
        -- Season of Discovery Rune quests are still shown when trivial
        AvailableQuests.levelRequirementCache[questId] = true
        return true
    end

    if maxLevel >= level then
        if (Questie.db.profile.lowLevelStyle ~= Questie.LOWLEVEL_ALL) and minLevel > level then
            -- The quest level is too low and trivial quests are not shown
            AvailableQuests.levelRequirementCache[questId] = false
            return false
        end
    else
        if (Questie.db.profile.lowLevelStyle == Questie.LOWLEVEL_RANGE) or maxLevel < requiredLevel then
            -- Either an absolute level range is set and maxLevel < level OR the maxLevel is manually set to a lower value
            AvailableQuests.levelRequirementCache[questId] = false
            return false
        end
    end

    if maxLevel < requiredLevel then
        -- Either the players level is not high enough or the maxLevel is manually set to a lower value
        AvailableQuests.levelRequirementCache[questId] = false
        return false
    end

    if requiredMaxLevel ~= 0 and playerLevel > requiredMaxLevel then
        -- The players level exceeds the requiredMaxLevel of a quest
        AvailableQuests.levelRequirementCache[questId] = false
        return false
    end

    AvailableQuests.levelRequirementCache[questId] = true
    return true
end

-- This needs to be called when the player levels up and when the lowLevelStyle is changed
function AvailableQuests.ResetLevelRequirementCache()
    AvailableQuests.levelRequirementCache = {}
end
