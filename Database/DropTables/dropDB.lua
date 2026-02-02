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
---@type Expansions
local Expansions = QuestieLoader:ImportModule("Expansions")

-- To obtain final drop data rates, query QuestieDB.GetItemDroprate(ItemID,NpcID).
-- That function will query DropDB to ascertain the real value.
-- DropDB then determines which data to provide based upon current expansion level and other rules.

-- The number provided is a float; it is up to the end user to determine how to display that.
-- 100.0 would be 100%, 47.254 would be 47.254%, etc.

-- Return values are {dropRate, sourceDB}

-- This function will return nil if the DB is not loaded properly or there is no data.
-- Be sure you can handle successful nil returns!

---@param itemId ItemId
---@param npcId NpcId
---@return table<number, string>
function DropDB.GetItemDroprate(itemId, npcId)
    local dropRateTableWowhead = nil
    local dropRateTableCmangos = nil
    local dropRateTableMangos3 = nil
    local dropRate = nil

    if Questie.IsClassic then
        -- Wowhead Classic data was gathered with the SoD QuestieDB, so SoD IDs are included as well;
        -- this should not affect Era players because the Era DB will never reference those IDs
        dropRateTableWowhead = QuestieClassicItemDrops.wowheadData
        dropRateTableCmangos = QuestieClassicItemDrops.cmangosData
    elseif Questie.IsTBC then
        dropRateTableWowhead = QuestieTBCItemDrops.wowheadData
        dropRateTableCmangos = QuestieTBCItemDrops.cmangosData
    elseif Questie.IsWotlk then
        dropRateTableWowhead = QuestieWotlkItemDrops.wowheadData
        dropRateTableCmangos = QuestieWotlkItemDrops.cmangosData
    elseif Questie.IsCata then
        dropRateTableWowhead = QuestieCataItemDrops.wowheadData
        dropRateTableMangos3 = QuestieCataItemDrops.mangos3Data
    elseif Questie.IsMoP then
        dropRateTableWowhead = QuestieMopItemDrops.wowheadData
        -- we use cata mangos3 data for mop instead because mop DBs are so spotty;
        -- this means mop-only quests will use wowhead data exclusively
        dropRateTableMangos3 = QuestieCataItemDrops.mangos3Data
    else
        Questie:Debug("ItemDrops: Unknown Expansion!")
    end

    -- Corrections are loaded starting from Era; this means Era corrections are still
    -- applied to later expansions unless overridden by those expansions' corrections
    local dropRateTableCorrections = QuestieClassicItemDrops.corrections
    if Expansions.Current >= Expansions.Tbc then
        for k,v in pairs(QuestieTBCItemDrops.corrections) do dropRateTableCorrections[k] = v end
        if Expansions.Current >= Expansions.Wotlk then
            for k,v in pairs(QuestieWotlkItemDrops.corrections) do dropRateTableCorrections[k] = v end
            if Expansions.Current >= Expansions.Cata then
                for k,v in pairs(QuestieCataItemDrops.corrections) do dropRateTableCorrections[k] = v end
                if Expansions.Current >= Expansions.MoP then
                    for k,v in pairs(QuestieMopItemDrops.corrections) do dropRateTableCorrections[k] = v end
                end
            end
        end
    end

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

    -- To scrape new Wowhead data:
    -- 1. Launch WoW with the desired expansion level and Questie installed.
    -- 2. Once Questie is fully loaded ingame, run /questie itemdrop
    -- 3. Copy that list of IDs into the file Questie/ExternalScripts(DONOTINCLUDEINRELEASE)/scraper/item_drop/item_ids.py
    -- 4. Run:   python Questie/ExternalScripts(DONOTINCLUDEINRELEASE)/scraper/runner.py --item-drop -ex #      where # is the expansion level; 0 for classic, 1 for tbc, etc. also accepts strings
    -- 5. Once it's done scraping, the data will be in Questie/ExternalScripts(DONOTINCLUDEINRELEASE)/scraper/item_drop/item_drop_data.lua

    -- To extract cmangos/mangos3 data:
    -- 1. Host the relevant MySQL database locally on your machine
    -- 2. Tweak Questie/ExternalScripts(DONOTINCLUDEINRELEASE)/scraper/item_drop/cmangos_itemdrops.py for your host IP, user, password, and database ID, if necessary
    -- 3. Run:   python cmangos_itemdrops.py
    -- 4. Once it's done extracting, the data will be in Questie/ExternalScripts(DONOTINCLUDEINRELEASE)/scraper/item_drop/item_drop_data.lua
    -- (we don't need a list of IDs like for wowhead because we rely on cmangos' own data for what items are quest-only drops)

    if dropRateTableCorrections and dropRateTableCorrections[itemId] and dropRateTableCorrections[itemId][npcId] then
        return {dropRateTableCorrections[itemId][npcId],"questie"}
    elseif dropRateTableCmangos and dropRateTableCmangos[itemId] and dropRateTableCmangos[itemId][npcId] then
        return {dropRateTableCmangos[itemId][npcId],"cmangos"}
    elseif dropRateTableMangos3 and dropRateTableMangos3[itemId] and dropRateTableMangos3[itemId][npcId] then
        return {dropRateTableMangos3[itemId][npcId],"mangos3"}
    elseif dropRateTableWowhead and dropRateTableWowhead[itemId] and dropRateTableWowhead[itemId][npcId] then
        return {dropRateTableWowhead[itemId][npcId],"wowhead"}
    end
    return nil
end