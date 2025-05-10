---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule("ZoneDB")

-- https://wowpedia.fandom.com/wiki/InstanceID --> Classic
ZoneDB.instanceIdToUiMapId = {
    [33] = ZoneDB.zoneIDs.SHADOWFANG_KEEP,
    [36] = ZoneDB.zoneIDs.THE_DEADMINES,
    [43] = ZoneDB.zoneIDs.WAILING_CAVERNS,
    [47] = ZoneDB.zoneIDs.RAZORFEN_KRAUL,
    [48] = ZoneDB.zoneIDs.BLACKFATHOM_DEEPS,
    [70] = ZoneDB.zoneIDs.ULDAMAN,
    [90] = ZoneDB.zoneIDs.GNOMEREGAN,
    [109] = ZoneDB.zoneIDs.THE_TEMPLE_OF_ATAL_HAKKAR,
    [129] = ZoneDB.zoneIDs.RAZORFEN_DOWNS,
    [189] = ZoneDB.zoneIDs.SCARLET_MONASTERY,
    [209] = ZoneDB.zoneIDs.ZUL_FARRAK,
    [229] = ZoneDB.zoneIDs.BLACKROCK_SPIRE,
    [230] = ZoneDB.zoneIDs.BLACKROCK_DEPTHS,
    [249] = ZoneDB.zoneIDs.ONYXIAS_LAIR,
    [289] = ZoneDB.zoneIDs.SCHOLOMANCE,
    [309] = ZoneDB.zoneIDs.ZUL_GURUB,
    [329] = ZoneDB.zoneIDs.STRATHOLME,
    [349] = ZoneDB.zoneIDs.MARAUDON,
    [389] = ZoneDB.zoneIDs.RAGEFIRE_CHASM,
    [409] = ZoneDB.zoneIDs.MOLTEN_CORE,
    [429] = ZoneDB.zoneIDs.DIRE_MAUL,
    [469] = ZoneDB.zoneIDs.BLACKWING_LAIR,
    [509] = ZoneDB.zoneIDs.RUINS_OF_AHN_QIRAJ,
    [531] = ZoneDB.zoneIDs.AHN_QIRAJ,
    [533] = ZoneDB.zoneIDs.NAXXRAMAS,
    [2856] = ZoneDB.zoneIDs.SCARLET_ENCLAVE,
}
