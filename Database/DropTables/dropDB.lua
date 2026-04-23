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

DropDB.tableWowhead = nil
DropDB.tablePserver = nil
DropDB.tableCorrections = nil
DropDB.sourcePserver = "" -- this tracks which pserv DB is loaded so we can display the correct icon in debug mode

DropDB.correctionKeys = { -- all keys must be negative or they'll be parsed as real data
    WOWHEAD = -1,
    PSERVER = -2,
}

function DropDB:Initialize()
    if Questie.IsClassic then
        -- Wowhead Classic data was gathered with the SoD QuestieDB, so SoD IDs are included as well;
        -- this should not affect Era players because the Era DB will never reference those IDs
        DropDB.tableWowhead = loadstring(QuestieClassicItemDrops.wowheadData)()
        DropDB.tablePserver = loadstring(QuestieClassicItemDrops.cmangosData)()
        DropDB.sourcePserver = "cmangos"
    elseif Questie.IsTBC then
        DropDB.tableWowhead = loadstring(QuestieTBCItemDrops.wowheadData)()
        DropDB.tablePserver = loadstring(QuestieTBCItemDrops.cmangosData)()
        DropDB.sourcePserver = "cmangos"
    elseif Questie.IsWotlk then
        DropDB.tableWowhead = loadstring(QuestieWotlkItemDrops.wowheadData)()
        DropDB.tablePserver = loadstring(QuestieWotlkItemDrops.cmangosData)()
        DropDB.sourcePserver = "cmangos"
    elseif Questie.IsCata then
        DropDB.tableWowhead = loadstring(QuestieCataItemDrops.wowheadData)()
        DropDB.tablePserver = loadstring(QuestieCataItemDrops.mangos3Data)()
        DropDB.sourcePserver = "mangos3"
    elseif Questie.IsMoP then
        DropDB.tableWowhead = loadstring(QuestieMopItemDrops.wowheadData)()
        DropDB.tablePserver = loadstring(QuestieCataItemDrops.mangos3Data)()
        DropDB.sourcePserver = "mangos3"
        -- we use cata mangos3 data for mop instead because mop DBs are so spotty;
        -- this means mop-only quests will use wowhead data exclusively
    else
        Questie:Error("ItemDrops: Unknown Expansion!")
    end

    -- Corrections are loaded starting from Era; this means Era corrections are still
    -- applied to later expansions unless overridden by later expansions' corrections
    DropDB.tableCorrections = QuestieItemDropCorrections.Era
    if Expansions.Current >= Expansions.Tbc then
        for k,v in pairs(QuestieItemDropCorrections.Tbc) do DropDB.tableCorrections[k] = v end
        if Expansions.Current >= Expansions.Wotlk then
            for k,v in pairs(QuestieItemDropCorrections.Wotlk) do DropDB.tableCorrections[k] = v end
            if Expansions.Current >= Expansions.Cata then
                for k,v in pairs(QuestieItemDropCorrections.Cata) do DropDB.tableCorrections[k] = v end
                if Expansions.Current >= Expansions.MoP then
                    for k,v in pairs(QuestieItemDropCorrections.MoP) do DropDB.tableCorrections[k] = v end
                end
            end
        end
    end
end

-- To obtain final drop rate data, query QuestieDB.GetItemDroprate(ItemID,NpcID)
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
    -- 1. Manual Corrections > 2. Pserver Data > 3. Wowhead Data
    -- We check each database in order for item:npc matches, and we report the first match we find.

    -- Wowhead data consists of the full drop rates (every NPC listed on wowhead for an item), for all items
    -- contained in either item objectives or RequiredSourceItems for all quests in that expansion's compiled Questie DB.

    -- Pserver (Cmangos/Mangos3) data only consists of items that those databases believe drop only while on a quest (internally specified with a negative drop value).

    -- Wowhead's crowdsourced drop data is likely more accurate for items that always drop, but unfortunately, while their looter addon does
    -- record active quests when reporting data, item drop rates are not filtered on Wowhead's site to show data only from those on the quest.

    -- While some private server data might be wrong for quest items, it is generally far more accurate than Wowhead for quest-only items.
    -- For eggregious outliers, we can make manual corrections that take full priority.

    -- It is worth noting that in Questie, we only display item drop data on NPCs that QuestieDB itself believes actually drops the item.
    -- So if we've manually excluded an NPC from dropping the item in QuestieDB corrections (like for a rare mob), then even if that drop
    -- data exists in our drop data DB, it won't ever actually be shown on NPC tooltips, because Questie itself doesn't think it should.
    -- This function will still return data for those NPCs in case external addons request it, Questie simply won't ever ask this function to.

    if DropDB.tableCorrections and DropDB.tableCorrections[itemId] and DropDB.tableCorrections[itemId][npcId] then
        if DropDB.tableCorrections[itemId][npcId] >= 0 then -- If the correction is not a reference, use its value
            return {DropDB.tableCorrections[itemId][npcId],"questie"}
        end

        -- If the correction is a reference to a different DB, use data from that DB instead
        if DropDB.tableCorrections[itemId][npcId] == DropDB.correctionKeys.WOWHEAD and DropDB.tableWowhead and DropDB.tableWowhead[itemId] and DropDB.tableWowhead[itemId][npcId] then
            return {DropDB.tableWowhead[itemId][npcId],"wowhead"}
        elseif DropDB.tableCorrections[itemId][npcId] == DropDB.correctionKeys.PSERVER and DropDB.tablePserver and DropDB.tablePserver[itemId] and DropDB.tablePserver[itemId][npcId] then
            return {DropDB.tablePserver[itemId][npcId],DropDB.sourcePserver}
        end

        Questie:Debug(Questie.DEBUG_CRITICAL, "ItemDrops: Correction data for item " .. tostring(itemId) .. " dropped by NPC " .. tostring(npcId) .. " was invalid!")
    end

    -- Rather than these being elseif, they're separate, so that if we find a correction but it's invalid for whatever reason,
    -- we still have a chance to fall back rather than returning nil. This may happen for instance if we have a correction
    -- that points to Wowhead, but the loaded Wowhead DB doesn't have data for that item:npc pair.
    if DropDB.tablePserver and DropDB.tablePserver[itemId] and DropDB.tablePserver[itemId][npcId] then
        return {DropDB.tablePserver[itemId][npcId],DropDB.sourcePserver}
    elseif DropDB.tableWowhead and DropDB.tableWowhead[itemId] and DropDB.tableWowhead[itemId][npcId] then
        return {DropDB.tableWowhead[itemId][npcId],"wowhead"}
    end

    return nil
end