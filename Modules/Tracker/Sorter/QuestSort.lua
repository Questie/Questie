-- The orders available for the quests inside one tracker group.
---@class QuestSort
local QuestSort = QuestieLoader:CreateModule("QuestSort")

---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")

---@class QuestSortDefinition
---@field compare fun(a: QuestSortDetails, b: QuestSortDetails): boolean Whether quest a is listed above quest b.
---@field usesPlayerPosition boolean? The sort reads `distance` and `isOnPlayerContinent`, which are only set for these sorts.

---Quest type, then quest ID: the order of quests that share a level.
---@param a QuestSortDetails
---@param b QuestSortDetails
---@return boolean
local function _CompareByTypeAndId(a, b)
    local typePriorityA = QuestieLib.GetQuestTypeSuffixPriority(a.quest.Id)
    local typePriorityB = QuestieLib.GetQuestTypeSuffixPriority(b.quest.Id)
    if typePriorityA == typePriorityB then
        return a.quest.Id < b.quest.Id
    end
    return typePriorityA < typePriorityB
end

---Lowest level first. The other sorts fall back to this order for quests they rank equal.
---@param a QuestSortDetails
---@param b QuestSortDetails
---@return boolean
local function _CompareByLevel(a, b)
    if a.quest.level == b.quest.level then
        return _CompareByTypeAndId(a, b)
    end
    return a.quest.level < b.quest.level
end

---Quests on the player's continent first. On either side the nearest quest first, and quests without a known location last.
---@param a QuestSortDetails
---@param b QuestSortDetails
---@return boolean
local function _CompareByProximity(a, b)
    if a.isOnPlayerContinent ~= b.isOnPlayerContinent then
        return a.isOnPlayerContinent
    end
    if a.distance == b.distance then
        return _CompareByLevel(a, b)
    end
    if not a.distance then
        return false
    elseif not b.distance then
        return true
    end
    return a.distance < b.distance
end

---@type table<string, QuestSortDefinition>
QuestSort.sorts = {
    level = {compare = _CompareByLevel},

    -- Only the level is reversed: quests that share a level keep the order by type and ID.
    levelReversed = {
        compare = function(a, b)
            if a.quest.level == b.quest.level then
                return _CompareByTypeAndId(a, b)
            end
            return a.quest.level > b.quest.level
        end,
    },

    -- Most complete first.
    complete = {
        compare = function(a, b)
            if a.questCompletePercent == b.questCompletePercent then
                return _CompareByLevel(a, b)
            end
            return a.questCompletePercent > b.questCompletePercent
        end,
    },

    -- Least complete first. Equally complete quests are still listed lowest level first.
    completeReversed = {
        compare = function(a, b)
            if a.questCompletePercent == b.questCompletePercent then
                return _CompareByLevel(a, b)
            end
            return a.questCompletePercent < b.questCompletePercent
        end,
    },

    proximity = {compare = _CompareByProximity, usesPlayerPosition = true},

    -- The exact mirror of proximity: quests without a known location come first.
    proximityReversed = {
        compare = function(a, b)
            return _CompareByProximity(b, a)
        end,
        usesPlayerPosition = true,
    },
}
