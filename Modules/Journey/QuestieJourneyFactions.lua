---@class QuestieJourneyFactions
local QuestieJourneyFactions = QuestieLoader:CreateModule("QuestieJourneyFactions")

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")

local factionIDs = QuestieDB.factionIDs

---Per-expansion faction lists for the Journey "Quests by Faction" tab.
---@type table<string, FactionId[]>
QuestieJourneyFactions.expansionFactionCandidates = {
    classic = {
        factionIDs.BOOTY_BAY,
        factionIDs.IRONFORGE,
        factionIDs.GNOMEREGAN,
        factionIDs.THORIUM_BROTHERHOOD,
        factionIDs.HORDE,
        factionIDs.UNDERCITY,
        factionIDs.DARNASSUS,
        factionIDs.SYNDICATE,
        factionIDs.STORMWIND,
        factionIDs.ORGRIMMAR,
        factionIDs.THUNDER_BLUFF,
        factionIDs.GELKIS_CLAN_CENTAUR,
        factionIDs.MAGRAM_CLAN_CENTAUR,
        factionIDs.STEAMWHEEDLE_CARTEL,
        factionIDs.ZANDALAR_TRIBE,
        factionIDs.RAVENHOLDT,
        factionIDs.GADGETZAN,
        factionIDs.ALLIANCE,
        factionIDs.RATCHET,
        factionIDs.THE_LEAGUE_OF_ARATHOR,
        factionIDs.THE_DEFILERS,
        factionIDs.ARGENT_DAWN,
        factionIDs.DARKSPEAR_TROLLS,
        factionIDs.TIMBERMAW_HOLD,
        factionIDs.EVERLOOK,
        factionIDs.WINTERSABER_TRAINERS,
        factionIDs.CENARION_CIRCLE,
        factionIDs.FROSTWOLF_CLAN,
        factionIDs.STORMPIKE_GUARD,
        factionIDs.HYDRAXIAN_WATERLORDS,
        factionIDs.SHEN_DRALAR,
        factionIDs.WARSONG_OUTRIDERS,
        factionIDs.SILVERWING_SENTINELS,
        factionIDs.ALLIANCE_FORCES,
        factionIDs.HORDE_FORCES,
        factionIDs.DARKMOON_FAIRE,
        factionIDs.BROOD_OF_NOZDORMU,
    },
    tbc = {
        factionIDs.SILVERMOON_CITY,
        factionIDs.TRANQUILLIEN,
        factionIDs.EXODAR,
        factionIDs.THE_ALDOR,
        factionIDs.THE_CONSORTIUM,
        factionIDs.THE_SCRYERS,
        factionIDs.THE_SHA_TAR,
        factionIDs.SHATTRATH_CITY,
        factionIDs.THE_MAGHAR,
        factionIDs.CENARION_EXPEDITION,
        factionIDs.HONOR_HOLD,
        factionIDs.THRALLMAR,
        factionIDs.THE_VIOLET_EYE,
        factionIDs.SPOREGGAR,
        factionIDs.KURENAI,
        factionIDs.THE_BURNING_CRUSADE,
        factionIDs.KEEPERS_OF_TIME,
        factionIDs.THE_SCALE_OF_THE_SANDS,
        factionIDs.LOWER_CITY,
        factionIDs.ASHTONGUE_DEATHSWORN,
        factionIDs.NETHERWING,
        factionIDs.SHA_TARI_SKYGUARD,
        factionIDs.OGRILA,
        factionIDs.SHATTERED_SUN_OFFENSIVE,
    },
    wotlk = {
        factionIDs.ALLIANCE_VANGUARD,
        factionIDs.VALIANCE_EXPEDITION,
        factionIDs.HORDE_EXPEDITION,
        factionIDs.THE_TAUNKA,
        factionIDs.THE_HAND_OF_VENGEANCE,
        factionIDs.EXPLORERS_LEAGUE,
        factionIDs.THE_KALUAK,
        factionIDs.WARSONG_OFFENSIVE,
        factionIDs.KIRIN_TOR,
        factionIDs.THE_WYRMREST_ACCORD,
        factionIDs.THE_SILVER_COVENANT,
        factionIDs.WRATH_OF_THE_LICH_KING,
        factionIDs.KNIGHTS_OF_THE_EBON_BLADE,
        factionIDs.FRENZYHEART_TRIBE,
        factionIDs.THE_ORACLES,
        factionIDs.ARGENT_CRUSADE,
        factionIDs.SHOLAZAR_BASIN,
        factionIDs.THE_SONS_OF_HODIR,
        factionIDs.THE_SUNREAVERS,
        factionIDs.THE_FROSTBORN,
        factionIDs.THE_ASHEN_VERDICT,
    },
    cata = {
        factionIDs.BILGEWATER_CARTEL,
        factionIDs.GILNEAS,
        factionIDs.THE_EARTHEN_RING,
        factionIDs.GUARDIANS_OF_HYJAL,
        factionIDs.THERAZANE,
        factionIDs.DRAGONMAW_CLAN,
        factionIDs.RAMKAHEN,
        factionIDs.WILDHAMMER_CLAN,
        factionIDs.BARADINS_WARDENS,
        factionIDs.HELLSCREAMS_REACH,
        factionIDs.AVENGERS_OF_HYJAL,
    },
    mop = {
        factionIDs.SHANG_XIS_ACADEMY,
        factionIDs.FOREST_HOZEN,
        factionIDs.PEARLFIN_JINYU,
        factionIDs.GOLDEN_LOTUS,
        factionIDs.SHADO_PAN,
        factionIDs.ORDER_OF_THE_CLOUD_SERPENT,
        factionIDs.THE_TILLERS,
        factionIDs.JOGU_THE_DRUNK,
        factionIDs.ELLA,
        factionIDs.OLD_HILLPAW,
        factionIDs.CHEE_CHEE,
        factionIDs.SHO,
        factionIDs.HAOHAN_MUDCLAW,
        factionIDs.TINA_MUDCLAW,
        factionIDs.GINA_MUDCLAW,
        factionIDs.FISH_FELLREED,
        factionIDs.FARMER_FUNG,
        factionIDs.THE_ANGLERS,
        factionIDs.THE_KLAXXI,
        factionIDs.THE_AUGUST_CELESTIALS,
        factionIDs.THE_LOREWALKERS,
        factionIDs.THE_BREWMASTERS,
        factionIDs.HUOJIN_PANDAREN,
        factionIDs.TUSHUI_PANDAREN,
        factionIDs.NOMI,
        factionIDs.NAT_PAGLE,
        factionIDs.THE_BLACK_PRINCE,
        factionIDs.BRAWLGAR_ARENA_SEASON_1,
        factionIDs.DOMINANCE_OFFENSIVE,
        factionIDs.OPERATION_SHIELDWALL,
        factionIDs.KIRIN_TOR_OFFENSIVE,
        factionIDs.SUNREAVER_ONSLAUGHT,
        factionIDs.AKAMAS_TRUST,
        factionIDs.BIZMOS_BRAWLPUB_SEASON_1,
        factionIDs.SHADO_PAN_ASSAULT,
        factionIDs.DARKSPEAR_REBELLION,
    },
}

---Builds a map of factionId -> expansion order index using the provided expansion order lookup.
---@param expansionOrderByKey table<string, number>
---@return table<FactionId, number>
function QuestieJourneyFactions.BuildFactionIntroductionOrder(expansionOrderByKey)
    local orderMap = {}

    for expansionKey, factionList in pairs(QuestieJourneyFactions.expansionFactionCandidates) do
        local order = expansionOrderByKey[expansionKey]
        if order then
            for _, factionId in ipairs(factionList) do
                orderMap[factionId] = order
            end
        end
    end

    return orderMap
end

return QuestieJourneyFactions


