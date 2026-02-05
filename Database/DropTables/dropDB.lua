---@class DropDB
local DropDB = QuestieLoader:CreateModule("DropDB")

-------------------------
--Import modules.
-------------------------
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")
---@type Expansions
local Expansions = QuestieLoader:ImportModule("Expansions")

---@type QuestieItemDropCorrections
local QuestieItemDropCorrections = QuestieLoader:ImportModule("QuestieItemDropCorrections")
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

DropDB.dropRateTableWowhead = nil
DropDB.dropRateTableCmangos = nil
DropDB.dropRateTableMangos3 = nil
DropDB.dropRateTableCorrections = nil

function DropDB:Initialize()
    if Questie.IsClassic then
        -- Wowhead Classic data was gathered with the SoD QuestieDB, so SoD IDs are included as well;
        -- this should not affect Era players because the Era DB will never reference those IDs
        DropDB.dropRateTableWowhead = loadstring(QuestieClassicItemDrops.wowheadData)()
        DropDB.dropRateTableCmangos = loadstring(QuestieClassicItemDrops.cmangosData)()
    elseif Questie.IsTBC then
        DropDB.dropRateTableWowhead = loadstring(QuestieTBCItemDrops.wowheadData)()
        DropDB.dropRateTableCmangos = loadstring(QuestieTBCItemDrops.cmangosData)()
    elseif Questie.IsWotlk then
        DropDB.dropRateTableWowhead = loadstring(QuestieWotlkItemDrops.wowheadData)()
        DropDB.dropRateTableCmangos = loadstring(QuestieWotlkItemDrops.cmangosData)()
    elseif Questie.IsCata then
        DropDB.dropRateTableWowhead = loadstring(QuestieCataItemDrops.wowheadData)()
        DropDB.dropRateTableMangos3 = loadstring(QuestieCataItemDrops.mangos3Data)()
    elseif Questie.IsMoP then
        DropDB.dropRateTableWowhead = loadstring(QuestieMopItemDrops.wowheadData)()
        DropDB.dropRateTableMangos3 = loadstring(QuestieCataItemDrops.mangos3Data)()
        -- we use cata mangos3 data for mop instead because mop DBs are so spotty;
        -- this means mop-only quests will use wowhead data exclusively
    else
        Questie:Error("ItemDrops: Unknown Expansion!")
    end

    -- Corrections are loaded starting from Era; this means Era corrections are still
    -- applied to later expansions unless overridden by those expansions' corrections
    DropDB.dropRateTableCorrections = QuestieItemDropCorrections.Era
    if Expansions.Current >= Expansions.Tbc then
        for k,v in pairs(QuestieItemDropCorrections.Tbc) do DropDB.dropRateTableCorrections[k] = v end
        if Expansions.Current >= Expansions.Wotlk then
            for k,v in pairs(QuestieItemDropCorrections.Wotlk) do DropDB.dropRateTableCorrections[k] = v end
            if Expansions.Current >= Expansions.Cata then
                for k,v in pairs(QuestieItemDropCorrections.Cata) do DropDB.dropRateTableCorrections[k] = v end
                if Expansions.Current >= Expansions.MoP then
                    for k,v in pairs(QuestieItemDropCorrections.MoP) do DropDB.dropRateTableCorrections[k] = v end
                end
            end
        end
    end
end

-- To obtain final drop rate data, query QuestieDB.GetItemDroprate(ItemID,NpcID).
-- That function will query DropDB to ascertain the real value.
-- DropDB then determines which data to provide based upon current expansion level and other rules.

-- The number provided is a float; it is up to the end user to determine how to display that.
-- 100.0 would be 100%, 47.254 would be 47.254%, etc.

-- Return values are {dropRate, sourceDB} as {float, str}

-- This function will return nil if the DB is not loaded properly or there is no data match.
-- Be sure you can handle successful nil returns!

---@param itemId ItemId
---@param npcId NpcId
---@return table<number, string>
function DropDB.GetItemDroprate(itemId, npcId)

    -- The hierarchy for drop rate data is as follows:
    -- 1. Manual Corrections > 2. Cmangos Data > 3. Mangos3 Data > 4. Wowhead Data
    -- We check each database in order for item:npc matches, and we report the first match we find.

    -- Wowhead data consists of the full drop rates (every NPC listed on wowhead for an item), for all items
    -- contained in either item objectives or RequiredSourceItems for all quests in that expansion's compiled Questie DB.

    -- Cmangos/Mangos3 data only consists of items that those databases believe drop only while on a quest (internally specified with a negative drop value).

    -- Wowhead's crowdsourced drop data is likely more accurate for items that always drop, but unfortunately, while their looter addon does
    -- record active quests when reporting data, item drop rates are not filtered on Wowhead's site to show data only from those on the quest.

    -- While some private server data might be wrong for quest items, it is generally far more accurate than Wowhead for quest-only items.
    -- For eggregious outliers, we can make manual corrections that take full priority.

    -- It is worth noting that in Questie, we only display item drop data on NPCs that QuestieDB itself believes actually drops the item.
    -- So if we've manually excluded an NPC from dropping the item in QuestieDB corrections (like for a rare mob), then even if that drop
    -- data exists in our drop data DB, it won't ever actually be shown on NPC tooltips, because Questie itself doesn't think it should.
    -- This function will still return data for those NPCs in case external addons request it, Questie simply won't ever ask this function to.

    if DropDB.dropRateTableCorrections and DropDB.dropRateTableCorrections[itemId] and DropDB.dropRateTableCorrections[itemId][npcId] then
        return {DropDB.dropRateTableCorrections[itemId][npcId],"questie"}
    elseif DropDB.dropRateTableCmangos and DropDB.dropRateTableCmangos[itemId] and DropDB.dropRateTableCmangos[itemId][npcId] then
        return {DropDB.dropRateTableCmangos[itemId][npcId],"cmangos"}
    elseif DropDB.dropRateTableMangos3 and DropDB.dropRateTableMangos3[itemId] and DropDB.dropRateTableMangos3[itemId][npcId] then
        return {DropDB.dropRateTableMangos3[itemId][npcId],"mangos3"}
    elseif DropDB.dropRateTableWowhead and DropDB.dropRateTableWowhead[itemId] and DropDB.dropRateTableWowhead[itemId][npcId] then
        return {DropDB.dropRateTableWowhead[itemId][npcId],"wowhead"}
    end
    return nil
end