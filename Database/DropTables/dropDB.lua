---@class DropDB
local DropDB = QuestieLoader:CreateModule("DropDB")

-------------------------
--Import modules.
-------------------------
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

---@type QuestieClassicItemDrops
local QuestieClassicItemDrops = QuestieLoader:ImportModule("QuestieClassicItemDrops")
---@type QuestieTBCItemDrops
local QuestieTBCItemDrops = QuestieLoader:ImportModule("QuestieTBCItemDrops")
---@type QuestieWotlkItemDrops
local QuestieWotlkItemDrops = QuestieLoader:ImportModule("QuestieWotlkItemDrops")
---@type QuestieCataItemDrops
local QuestieCataItemDrops = QuestieLoader:ImportModule("QuestieCataItemDrops")
---@type QuestieMopItemDrops
local QuestieMopItemDrops = QuestieLoader:ImportModule("QuestieMopItemDrops")

-- To obtain final drop data rates, query QuestieDB.GetItemDroprate(ItemID,NpcID).
-- That function will query DropDB to ascertain the real value.
-- DropDB then determines which data to provide based upon current expansion level and other rules.
-- The number provided is a float; it is up to the end user to determine how to display that.
-- 100.0 would be 100%, 47.254 would be 47.254%, etc.
-- This function will return nil if the DB is not loaded properly or there is no data.
-- Be sure you can handle successful nil returns!

---@param itemId ItemId
---@param npcId NpcId
---@return number
function DropDB.GetItemDroprate(itemId, npcId)
    local dropRateTable = nil
    local dropRate = nil

    if Questie.IsClassic then
        dropRateTable = QuestieTBCItemDrops.data
    elseif Questie.IsTBC then
        dropRateTable = QuestieTBCItemDrops.data
    elseif Questie.IsWotlk then
        dropRateTable = QuestieWotlkItemDrops.data
    elseif Questie.IsCata then
        dropRateTable = QuestieCataItemDrops.data
    elseif Questie.IsMoP then
        dropRateTable = QuestieMopItemDrops.data
    else
        Questie:Debug("ItemDrops: Unknown Expansion!")
    end
    --DevTools_Dump(dropRateTable)
    if dropRateTable and dropRateTable[itemId] and dropRateTable[itemId][npcId] then
        dropRate = dropRateTable[itemId][npcId]
    end
    return dropRate
end