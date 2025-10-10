---@class Phasing
local Phasing = QuestieLoader:CreateModule("Phasing")
---@type QuestLogCache
local QuestLogCache = QuestieLoader:ImportModule("QuestLogCache")

local _Phasing = {}
local playerFaction

-- https://old.wow.tools/dbc/?dbc=phase&build=4.3.4.15595
local phases = {
    UNKNOWN = 169, -- Most Deepholm NPCs (and others) have this ID but are not phased
    CUSTOM_EVENT_3 = 177, -- Looks like only certain WotLK NPCs use this phase
    -- The Lost Isles and Gilneas share the same phase IDs
    LOST_ISLES_CHAPTER_1 = 170,
    LOST_ISLES_CHAPTER_2 = 171,
    LOST_ISLES_CHAPTER_3 = 172,
    LOST_ISLES_CHAPTER_4 = 179,
    LOST_ISLES_CHAPTER_5 = 180,
    LOST_ISLES_CHAPTER_6 = 181,
    LOST_ISLES_CHAPTER_7 = 182,
    LOST_ISLES_CHAPTER_8 = 183,
    LOST_ISLES_CHAPTER_9 = 184,
    LOST_ISLES_CHAPTER_10 = 185,
    GILNEAS_CHAPTER_1 = 170,
    GILNEAS_CHAPTER_2 = 171,
    GILNEAS_CHAPTER_3 = 172,
    GILNEAS_CHAPTER_4 = 179,
    GILNEAS_CHAPTER_5 = 181,
    GILNEAS_CHAPTER_6 = 182,
    GILNEAS_CHAPTER_7 = 183,
    GILNEAS_CHAPTER_8 = 184,
    GILNEAS_CHAPTER_9 = 186,
    GILNEAS_CHAPTER_10 = 187,
    GILNEAS_CHAPTER_11 = 188,
    GILNEAS_CHAPTER_12 = 189,

    -- You start with these phases available in Hyjal, which changes once you completed specific quests
    HYJAL_TWILIGHT_CHAPTER = 170,
    HYJAL_DAILY = 191,
    HYJAL_CHAPTER_1 = 194,
    HYJAL_CHAPTER_2 = 195,

    -- Horde starting area in Twilight Highlands
    DRAGONMAW_PORT_CHAPTER_1 = 229,
    DRAGONMAW_PORT_CHAPTER_2 = 238,
    DRAGONMAW_PORT_CHAPTER_3 = 247,

    -- Deepholm
    THE_STONE_MARCH = 252,
    TEMPLE_OF_EARTH_CHAPTER_1 = 253,
    TEMPLE_OF_EARTH_CHAPTER_2 = 254,
    -- It looks like 255 and 256 are not used
    TEMPLE_OF_EARTH_CHAPTER_3 = 257,

    TWILIGHT_GATE_PRE_INVASION = 283,
    TWILIGHT_GATE = 285,
    TWILIGHT_CARAVAN_AMBUSH_HORDE = 318,
    GRIM_BATOL_ATTACK_HORDE = 319,
    TWILIGHT_CARAVAN_AMBUSH_ALLIANCE = 320,
    GRIM_BATOL_ATTACK_ALLIANCE = 321,
    ISORATH_NIGHTMARE = 327,

    KEZAN_CHAPTER_1 = 378,
    KEZAN_CHAPTER_2 = 379,
    KEZAN_CHAPTER_3 = 380, -- Not handled explicitly because the spawns are the same as chapter 2
    KEZAN_CHAPTER_4 = 381, -- Not handled explicitly because the spawns are the same as chapter 2
    KEZAN_CHAPTER_5 = 382,
    KEZAN_CHAPTER_6 = 383,
    KEZAN_CHAPTER_7 = 384,

    -- Fake phases - looks like Blizzard is using the same phase ID for different areas - this is a nightmare...
    HYJAL_IAN_AND_TARIK_NOT_IN_CAGE = 1000,
    HYJAL_HAMUUL_RUNETOTEM_AT_SANCTUARY = 1001,
    HYJAL_HAMUUL_RUNETOTEM_AT_GROVE = 1002,
    HYJAL_THISALEE_AT_SHRINE = 1003,
    HYJAL_THISALEE_AT_SETHRIAS_ROOST = 1004,
    CORITHRAS_AT_DOLANAAR = 1005,
    CORITHRAS_AT_CROSSROAD = 1006,
    CERELLEAN_NEAR_EDGE = 1007,
    CERELLEAN_NEAR_TREE = 1008,
    VASHJIR_LEGIONS_REST = 1009, -- Also the Alliance cave Tranquil Wash
    VASHJIR_NORTHERN_GARDEN = 1010,
    ILTHALAINE_AT_BENCH = 1011,
    ILTHALAINE_AT_ROAD = 1012,
    VASHJIR_NAR_SHOLA_TERRACE = 1013,
    VASHJIR_NAR_SHOLA_TERRACE_WEST = 1014,
    VASHJIR_LADY_NAZ_JAR_AT_TEMPLE = 1015,
    VASHJIR_LADY_NAZ_JAR_AT_BRIDGE = 1016,
    VASHJIR_ERANUK_AT_CAVERN = 1017,
    VASHJIR_ERANUK_AT_PROMONTORY_POINT = 1018,
    KEZAN_SASSY_IN_HQ = 1019,
    KEZAN_SASSY_OUTSIDE_HQ = 1020,
    KEZAN_GALLYWIX_AT_HQ = 1021,
    KEZAN_GALLYWIX_ON_BOAT = 1022,
    AGTOR_GRABBIT_OUTSIDE_ATTACK = 1023,
    AGTOR_GRABBIT_DURING_ATTACK = 1024,
    MOLOTOV_AT_RUINS = 1025,
    MOLOTOV_AT_HARBOR = 1026,
    SORATA_AT_EXCHANGE = 1027,
    SORATA_AT_HARBOR = 1028,
    SCARLET_ENCLAVE_ENTRACE = 1029,
    SCARLET_ENCLAVE = 1030,
    SIRA_KESS_AT_GARDEN = 1031,
    SIRA_KESS_AT_NAR_SHOLA_TERRACE = 1032,
    WAVESPEAKER_AT_RUINS = 1033,
    HAR_KOA_AT_ALTAR = 1034,
    HAR_KOA_AT_ZIM_TORGA = 1035,
    EARTHEN_GUIDE_BFD = 1036,
    EARTHEN_GUIDE_SHORE = 1037,
    JAROD_NEAR_PORTAL = 1038,
    JAROD_MIDDLE_ISLAND = 1039,
    PEBBLE_AT_KOR = 1040,
    PEBBLE_AT_CRYSTALS = 1041,
    TERRATH_AT_AEOSERA = 1042,
    NPCS_AT_THERAZANES_THRONE = 1043,
    FARGO_AT_CATAPULTS = 1044,
    FARGO_AT_DOCKS = 1045,
    THORDUN_AT_TREE = 1046,
    THORDUN_IN_KEEP = 1047,
    TORUNSCAR_START = 1048,
    TORUNSCAR_END = 1049,
    THERAZANE_AT_TEMPLE = 1050,
    THERAZANE_AT_THRONE_BEFORE_MARCH = 1051,
    VOLJIN_BOOTY_BAY = 1052,
    MOUNT_HYJAL_INVASION_START = 1053,
    MOUNT_HYJAL_INVASION_SANCTUARY_ATTACK = 1054,
    MOUNT_HYJAL_INVASION_SANCTUARY = 1055,
    MOUNT_HYJAL_VISION_YSERA_1 = 1056,
    MOUNT_HYJAL_VISION_YSERA_2 = 1057,
    VASHJIR_LADY_NAZ_JAR_AT_RIDGE = 1058,
    GRYAN_TOWER = 1059,
    GRYAN_FP = 1060,
    MOLTEN_FRONT_CAMP = 1061,
    MOLTEN_FRONT_DRUIDS = 1062,
    MOLTEN_FRONT_WARDENS = 1063,
    MARRIS_BRIDGE = 1064,
    MARRIS_STABLES = 1065,
    RAMBO_TEAM_CANYON = 1066,
    RAMBO_TEAM_POST = 1067,
    SVEN_YORGEN_VISIBLE = 1068,
    AGGRA_THRONE = 1069,
    AGGRA_PRECIPICE = 1070,
    THRALL_AGGRA_PROPOSAL = 1071,
    THURMAN_AT_CHILLWIND = 1072,
    THURMAN_AT_WRITHING = 1073,
    THASSARIAN_WPL_TOWER = 1074,
    THASSARIAN_WPL_FP = 1075,
    CARAVAN_THONDRORIL = 1076,
    CARAVAN_CROWNGUARD = 1077,
    CARAVAN_LIGHTS_SHIELD = 1078,
    CARAVAN_EASTWALL = 1079,
    CARAVAN_NORTHPASS = 1080,
    CARAVAN_LIGHTS_HOPE = 1081,
    VEXTUL_SPAWN = 1082,
    VEXTUL_FIONA = 1083,
    TARENAR_NORTHPASS = 1084,
    TARENAR_PLAGUEWOOD = 1085,
    TARENAR_SAVED_GIDWIN = 1086,
    TARENAR_GIDWIN_LHC = 1087,
    RHEA_LETHLOR_RAVINE = 1088,
    RHEA_DRAGONS_MOUTH = 1089,
    RHEA_NEW_KARGATH = 1090,
    RHEA_HIDDEN_CLUTCH = 1091,
    DEATHWING_TELDURIN = 1092,
    DEATHWING_MARTEK = 1093,
    SEARING_GORGE_NPCS_TOWERS = 1094,
    SEARING_GORGE_CAVE_ASSAULT = 1095,
    LUNK_IRON_SUMMIT = 1096,
    LUNK_THORIUM_POINT = 1097,
    HORATIO_JANSEN_STEAD = 1098,
    HORATIO_SENTINEL_HILL = 1099,
    BS_PRE_ASSAULT = 1100,
    BS_POST_ASSAULT = 1101,
    SETHMAN_VISIBLE = 1102,
    LASHTAIL_VISIBLE = 1103,
    BERRIN_EMERINE_OSBORN_CAGE = 1104,
    BERRIN_EMERINE_OSBORN_RESCUED = 1105,
    BOOTY_BAY_REGULAR = 1106,
    BOOTY_BAY_ATTACK = 1107,
    HOLLEE_RUINS = 1108,
    HOLLEE_CAMP = 1109,
    SERENDIA_FP = 1110,
    SERENDIA_INN = 1111,
    GRIMCLAW_THICKET = 1112,
    GRIMCLAW_INN = 1113,
    BARGE_AT_PEACE = 1114,
    BARGE_UNDER_ATTACK = 1115,
    KELSEY_AT_COVE = 1116,
    HORATIO_IRONCLAD_COVE = 1117,
    DEADMINES_HOGGER_ALIVE = 1118,
    DEADMINES_HOGGER_DEAD = 1119,
    SILVERPINE_FOREST_HIGH_COMMAND = 1120,
    SILVERPINE_FOREST_SEPULCHER = 1121,
    SILVERPINE_FOREST_FORSAKEN_FRONT = 1122,
    SILVERPINE_FOREST_FORSAKEN_FRONT_2 = 1123,
    SILVERPINE_FOREST_BATTLEFRONT = 1124,
    RUINS_OF_GILNEAS_FFC = 1125,
    RUINS_OF_GILNEAS_EMBERSTONE = 1126,
    RUINS_OF_GILNEAS_TEMPESTS_REACH = 1127,
    SHADOWFANG_KEEP_ENTRANCE_A = 1128,
    SHADOWFANG_KEEP_ASHBURY_DEAD_A = 1129,
    SHADOWFANG_KEEP_SPRINGVALE_DEAD_A = 1130,
    SHADOWFANG_KEEP_WALDEN_DEAD_A = 1131,
    SHADOWFANG_KEEP_GODFREY_DEAD_A = 1132,
    SHADOWFANG_KEEP_ENTRANCE_H = 1133,
    SHADOWFANG_KEEP_ASHBURY_DEAD_H = 1134,
    SHADOWFANG_KEEP_SPRINGVALE_DEAD_H = 1135,
    SHADOWFANG_KEEP_WALDEN_DEAD_H = 1136,
    SHADOWFANG_KEEP_GODFREY_DEAD_H = 1137,
    LYDON_AWESOME_CAGE = 1138,
    LYDON_AWESOME_MAIN_BUILDING = 1139,
    ORKUS_IN_WATER = 1140,
    ORKUS_ON_LAND = 1141,
    ET_MUROZOND_DEAD = 1142,
    WILLIX_IN_TENT = 1143,
    WILLIX_AT_EXIT = 1144,
    WOT_NOZDORMU_1 = 1145,
    WOT_NOZDORMU_2 = 1146,
    WOT_NOZDORMU_3 = 1147,
    KAMMAH_STONE = 1148,
    KAMMAH_TENT = 1149,
    BALNAZZAR_DEAD = 1150,
    RIVENDARE_DEAD = 1151,
    KARGATH_DEAD = 1152,
    CAYDEN_START_AMBUSH = 1153,
    CAYDEN_FINISH_AMBUSH = 1154,
    OHF_THRALL_PRISON = 1155,
    OHF_THRALL_DESTINY = 1156,
    LINDSAY_WPL_TREE = 1157,
    LINDSAY_WPL_TENT = 1158,
    LINDSAY_WPL_INN = 1159,
    MGT_KT_DEAD = 1160,
    THE_BARRENS_KADRAK_MORSHAN = 1161,
    ZAZZO_GILNEAS = 1162,
    ZAZZO_DEADWIND = 1163,
    KALEC_TERMINUS = 1164,
    STONETALON_CLIFFWALKER_JUSTICE = 1165,
    STONETALON_CLIFFWALKER_RAMP = 1166,
    STONETALON_CLIFFWALKER_GARROSH = 1167,
    SHANG_XI_BENCH = 1168,
    SHANG_XI_DOORWAY = 1169,
    SHANG_XI_BRIDGE = 1170,
    DRIVER_NOT_RESCUED = 1171,
    DRIVER_RESCUED = 1172,
    SHANG_XI_TEMPLE_NORTH = 1173,
    SHANG_XI_TEMPLE_SOUTH = 1174,
    AYSA_LIANG_POOL_HOUSE = 1175,
    AYSA_LIANG_BRIDGE = 1176,
    AYSA_LIANG_LAKE = 1177,
    AYSA_ROPE = 1178,
    AYSA_CAVE = 1179,
    SKYFIRE_STORMWIND = 1180,
    SKYFIRE_JADE_FOREST = 1181,
    SULLY_BELOW_SKYFIRE = 1182,
    SULLY_TWINSPIRE_KEEP = 1183,
    RELL_ON_BARRELS = 1184,
    RELL_ON_DOCKS = 1185,
    RELL_ON_DOCKS_2 = 1186,
    RELL_PAWDON_VILLAGE = 1187,
    RELL_TWINSPIRE_KEEP = 1188,
    ADMIRAL_ROGERS_PAWDON_VILLAGE = 1189,
    SASHA_AT_DUSKHOWL_DEN = 1190,
    SASHA_AT_BLOODMOON_ISLE = 1191,
    FUSELAGE_ROCKET = 1192,
    FUSELAGE_CITY_SAVED = 1193,
    HOODED_CRUSADER_ATHENAEUM_31 = 1194,
    HOODED_CRUSADER_ATHENAEUM_90 = 1195,
    TALKING_SKULL_BRIDGE_43 = 1196,
    TALKING_SKULL_STUDY_43 = 1197,
    TALKING_SKULL_BRIDGE_90 = 1198,
    TALKING_SKULL_STUDY_90 = 1199,
    RAGEFIRE_CHASM_GORDOTH_DEAD = 1200,
    RIVETT_CLUTCHPOP_NOOK_OF_KONK = 1201,
    RIVETT_CLUTCHPOP_STROGARM_AIRSTRIP = 1202,
    RIVETT_CLUTCHPOP_NEXT_TO_NAZGRIM = 1203,
    RIVETT_CLUTCHPOP_GROOKIN_HILL_SOUTH_END = 1204,
    HIGH_ELDER_CLOUDFALL_AT_TOWER = 1205,
    HIGH_ELDER_CLOUDFALL_AT_BANQUET = 1206,
    MALIK_AT_PILLAR = 1207,
    MALIK_NEXT_TO_ZIKK = 1208,
    KIL_RUK_AT_PILLAR_1 = 1209,
    KIL_RUK_NEXT_TO_ZIKK = 1210,
    SOGGY_IN_HUT = 1211,
    SOGGY_OUTSIDE = 1212,
    SOGGY_AT_DOCK = 1213,
    ARIE_AT_DOCK = 1214,
    JU_LIEN_AT_COAST = 1215,
    JU_LIEN_IN_TOWN = 1216,
    CHEN_AT_FEAR_CLUTCH = 1217,
    CHEN_AT_BREWGARDEN = 1218,
    CHEN_62779_AT_BREWGARDEN = 1219,
    CHEN_62779_INSIDE_KOR_VESS = 1220,
    SAP_MASTERS_AT_BREWGARDEN = 1221,
    SAP_MASTERS_AT_RIKKITUN = 1222,
    SAP_MASTERS_AT_BREWGARDEN_CENTER = 1223,
    SKEER_IN_CAVE = 1224,
    SKEER_AT_KLAXXI_VESS = 1225,
    SHANG_THUNDERFOOT_AT_THUNDERFOOT_FIELDS = 1226,
    SHANG_THUNDERFOOT_SOUTH_OF_THUNDERFOOT_FIELDS = 1227,
    CLEVER_ASHYO_AT_POOLS_OF_PURITY = 1228,
    CLEVER_ASHYO_AT_NEW_CIFERA = 1229,
    ADMIRAL_TAYLOR_IN_TENT = 1230,
    ADMIRAL_TAYLOR_OUTSIDE_TENT = 1231,
    KOR_AT_THUNDER_CLEFT = 1232,
    KOR_AT_DAWNCHASER_RETREAT = 1233,
    DEZCO_AT_THUNDER_CLEFT = 1234,
    DEZCO_AT_SHATTERED_CONVOY = 1235,
    DEZCO_AT_DAWNCHASER_RETREAT = 1236,
    LIN_TENDERPAW_AT_PAOQUAN_HOLLOW = 1237,
    LIN_TENDERPAW_EAST_OF_STONEPLOW = 1238,
    HEMETS_AT_CAMP = 1239,
    HEMETS_OUTSIDE_CAMP = 1240,
    WU_PENG_ALONE = 1241,
    WU_PENG_REUNITED = 1242,
    ORBISS_AT_SUMPRUSH = 1243,
    ORBISS_AT_BORROW = 1244,
    KU_MO_AT_BRIDGE = 1245,
    KU_MO_AT_TEMPLE = 1246,
    SUNA_AT_OUTPOST = 1247,
    SUNA_AT_CAMP_OSUL = 1248,
    BAN_AT_OUTPOST = 1249,
    BAN_AT_CAMP_OSUL = 1250,
    BEFORE_MANTID_INVASION = 1251,
    AFTER_MANTID_INVASION = 1252,
    BLUESADDLE_TEMPLE = 1253,
    BLUESADDLE_LAKE = 1254,
    BROTHER_YAKSHOE_AT_BURLAP_WAYSTATION = 1255,
    BROTHER_YAKSHOE_AT_KNUCKLETHUMP_HOLE = 1256,
    BROTHER_YAKSHOE_AT_THE_DOOKER_DOME = 1257,
    LUSSHAN_TOP_STAIRS = 1258,
    LUSSHAN_PUDDLE = 1259,
    CHO_NEAR_BEER_TABLE = 1260,
    CHO_NEAR_PAGODAS = 1261,
    AN_WINDFUR_DAWNS_BLOSSOM_GATE = 1262,
    AN_WINDFUR_DAWNS_BLOSSOM_UP = 1263,
    AN_WINDFUR_DAWNS_BLOSSOM_JADE_HOUSE = 1264,
    AN_WINDFUR_FOREST_HEART = 1265,
    SHEEPIE_FIRST_TIME = 1266,
    SHEEPIE_SECOND_TIME = 1267,
    FARM_HAS_8_SLOTS = 1268,
    FARM_HAS_12_SLOTS = 1269,
    FARM_HAS_16_SLOTS = 1270,
    ZIN_AT_AXE_OF_THUNDER_KING = 1271,
    KILRUK_REVEALED = 1272,
    SHADO_PAN_GARRISON_NORMAL = 1273,
    SHADO_PAN_GARRISON_SURPRISE_ATTACK = 1274,
    XUEN_START = 1275,
    XUEN_AFTER_FIRST_FIGHT = 1276,
    XUEN_AFTER_SECOND_FIGHT = 1277,
    XUEN_AFTER_THIRD_FIGHT = 1278,
    XUEN_AFTER_FOURTH_FIGHT = 1279,
    ZIN_AT_PAGODA = 1280,
    PAGODA_UNDER_ATTACK = 1281,
    PAGODA_NOT_UNDER_ATTACK = 1282,
    DEZCO_AT_THUNDER_CLEFT_TENT = 1283,
    OLD_HILLPAW_NORMAL = 1284,
    OLD_HILLPAW_FARM = 1285,
    OLD_HILLPAW_MARKET = 1286,
    TINA_MUDCLAW_NORMAL = 1287,
    TINA_MUDCLAW_FARM = 1288,
    TINA_MUDCLAW_MARKET = 1289,
    FARMER_FUNG_NORMAL = 1290,
    FARMER_FUNG_FARM = 1291,
    FARMER_FUNG_MARKET = 1292,
    HAOHAN_MUDCLAW_NORMAL = 1293,
    HAOHAN_MUDCLAW_FARM = 1294,
    HAOHAN_MUDCLAW_MARKET = 1295,
    SHO_NORMAL = 1296,
    SHO_FARM = 1297,
    SHO_MARKET = 1298,
    ELLA_NORMAL = 1299,
    ELLA_FARM = 1300,
    ELLA_MARKET = 1301,
    FISH_FELLREED_NORMAL = 1302,
    FISH_FELLREED_FARM = 1303,
    FISH_FELLREED_MARKET = 1304,
    CHEE_CHEE_NORMAL = 1305,
    CHEE_CHEE_FARM = 1306,
    CHEE_CHEE_MARKET = 1307,
    FARMER_YOON_FARM = 1308,
    FARMER_YOON_MARKET = 1309,
    GINA_MUDCLAW_FARM = 1310,
    GINA_MUDCLAW_MARKET = 1311,
    JOGU_THE_DRUNK_FARM = 1312,
    JOGU_THE_DRUNK_MARKET = 1313,
    RIKKAL_AT_ZANVESS = 1314,
    HE_SOFTFOOT_DAILY = 1315,
    HE_SOFTFOOT_NOT_DAILY = 1316,
    GOLDEN_LOTUS_DAILY_LOCKED = 1317,
    GOLDEN_LOTUS_DAILY_UNLOCKED = 1318,
    CHEN_AT_EAST_BRIDGE = 1319,
    CHEN_AT_PANGS_STEAD = 1320,
    CHEN_AT_SHANGS_STEAD = 1321,
    CHEN_AT_MUDMUGS_PLACE = 1322,
    CHEN_AT_MUDMUGS_PLACE_LEGACY = 1323,
    CHEN_AT_HALFHILL = 1324,
    CHEN_AT_HALFHILL_BREWED = 1325,
    CHEN_AT_STORMSTOUT_BREWERY_DOOR = 1326,
    CHEN_AT_STORMSTOUT_BREWERY_HOZEN = 1327,
    MUDMUG_AT_STORMSTOUT_BREWERY_HOZEN = 1328,
    LI_LI_AT_STORMSTOUT_BREWERY_HOZEN = 1329,
    CHEN_AT_STORMSTOUT_BREWERY_SIDE = 1330,
    MUDMUG_AT_STORMSTOUT_BREWERY_SIDE = 1331,
    LI_LI_AT_STORMSTOUT_BREWERY_SIDE = 1332,
    CHEN_AT_STORMSTOUT_BREWERY_CLEANED_HOUSE = 1333,
    FARMER_YOON_HOUSE = 1334,
    FARM_HAS_4_SLOTS = 1335,
    KANG_AT_THE_INCURSION_OUTSIDE = 1336,
    KANG_AT_THE_INCURSION_INSIDE = 1337,
    VAELDRIN_AT_THE_INCURSION = 1338,
    VAELDRIN_SHATTERED_CONVOY = 1339,
    VAELDRIN_AT_SENTINEL_BASECAMP = 1340,
    MUDMUG_AT_STONEPLOW = 1341,
    BO_TSULAN_YAUNGOL_ROAD = 1342,
    BO_TSULAN_WESTWIND_REST_1 = 1343,
    BO_TSULAN_WESTWIND_REST_2 = 1344,
    GORAI_EDGE = 1345,
    GORAI_LIGHTPOLE = 1346,
    GORAI_RITUAL = 1347,
    GOLDEN_LOTUS_RUINS_PEACE = 1348,
    GOLDEN_LOTUS_RUINS_ATTACK = 1349,
    BAN_BEARHEART_AT_WINTERS_BLOSSOM = 1350,
    BAN_BEARHEART_ON_THE_GROUND = 1351,
    BAN_BEARHEART_AT_SHADO_PAN_MONASTERY = 1352,
    SUNA_SILENTSTRIKE_AT_THE_WALL = 1353,
    SUNA_SILENTSTRIKE_ON_THE_GROUND = 1354,
    BROTHER_RABBITSFOOT_AT_BURLAP_WAYSTATION = 1355,
    BROTHER_YAKSHOE_AT_BURLAP_WAYSTATION_2 = 1356,
    CHO_SEEKERS_POINT_1 = 1357,
    CHO_SEEKERS_POINT_2 = 1358,
    BURBERRY_IN_CAVE = 1359,
    BURBERRY_AT_CAMP = 1360,
    TARAN_ZHU_WATCHPOST_1 = 1361,
    TARAN_ZHU_WATCHPOST_2 = 1362,
    TAI_HO_AT_GARRISON = 1363,
    TAI_HO_IN_CATACOMBS = 1364,
    LUSSHAN_PEARLS = 1365,
    KIL_RUK_AT_PILLAR_2 = 1366,
    KAZTIK_AT_THE_BRINY_MUCK = 1367,
    KAZTIK_AT_KLAXXIVESS = 1368,
    RIKKAL_AT_KLAXXIVESS = 1369,
    XARIL_AT_HEART_OF_FEAR = 1370,
    XARIL_AT_KLAXXIVESS = 1371,
    FARM_HAS_2_SLOTS = 1372,
    RAIGONN_ALIVE = 1373,
    RAIGONN_DEAD = 1374,
    BOOF_IN_VEILED_STAIR = 1375,
    BOOF_AT_BINAN_VILLAGE = 1376,
    GOLDEN_LOTUS_GARRISON_ACTIVE = 1377,
    GOLDEN_LOTUS_LEVEN_AT_PAGODA = 1378,
    SHIAO_AND_KO_ON_YAUNGOL_ADVANCE = 1379,
    SHIAO_AND_KO_IN_FRONT_OF_CAMP = 1380,
    SHIAO_AND_KO_IN_CAMP = 1381,
    GENERAL_NAZGRIM_IN_TENT = 1382,
    GENERAL_NAZGRIM_OUTSIDE_TENT = 1383,
    GENERAL_NAZGRIM_NEAR_SPEARS = 1384,
    GENERAL_NAZGRIM_NEAR_ANDUINN = 1385,
    THRALL_VALLEY_OF_TRIALS = 1386,
    THRALL_ECHO_ISLES_1 = 1387,
    THRALL_ECHO_ISLES_2 = 1388,
    SARANNHA_AT_MOGUJIA = 1389,
    SARANNHA_AT_RUINS_OF_KORUNE = 1390,
    JAINA_IN_DARNASSUS = 1391,
    JAINA_IN_TELDRASSIL = 1392,
    ANDUIN_ENTRANCE_OF_TOMB = 1393,
    ANDUIN_AT_LIONS_LANDING = 1394,
    GARROSH_TOP_FLOOR_WEST = 1395,
    GARROSH_TOP_FLOOR_EAST = 1396,
    BAINE_IN_SHRINE = 1397,
    BAINE_AT_GARROSHAR_ADVANCE = 1398,
}
Phasing.phases = phases

function Phasing.Initialize()
    playerFaction = UnitFactionGroup("player")
end

---@param phase number? @The phase belonging to a spawn of an NPC
---@return boolean @true if the spawn is visible, false otherwise
function Phasing.IsSpawnVisible(phase)
    if (not phase) or phase == phases.UNKNOWN then
        return true
    end

    local questLog = QuestLogCache.questLog_DO_NOT_MODIFY
    if phase == phases.CUSTOM_EVENT_3 or phase == phases.HYJAL_DAILY then
        return _Phasing.CheckQuestLog(questLog)
    end

    local complete = Questie.db.char.complete

    -- We return "or false", to convert nil to false

    if (phase >= phases.LOST_ISLES_CHAPTER_1 and phase <= phases.LOST_ISLES_CHAPTER_3) or
        (phase >= phases.LOST_ISLES_CHAPTER_4 and phase <= phases.GILNEAS_CHAPTER_12) then

        if phase == phases.HYJAL_TWILIGHT_CHAPTER and (questLog[25274] or complete[25274]) and (not complete[25531]) then
            -- Blizzard re-used the phase ID for the Hyjal quest line about the Twilight's Hammer
            return true
        end

        if playerFaction == "Horde" then
            return _Phasing.LostIsles(phase, complete) or false
        else
            return _Phasing.Gilneas(phase, complete) or false
        end
    end

    if phase == phases.HYJAL_CHAPTER_1 then
        return (not complete[25372])
    end

    if phase == phases.HYJAL_CHAPTER_2 then
        return (not complete[25272]) and (not complete[25273])
    end

    if phase == phases.HYJAL_IAN_AND_TARIK_NOT_IN_CAGE then
        return complete[25272] or complete[25273] or false
    end

    if phase == phases.VASHJIR_LEGIONS_REST then
        return complete[25966] or complete[25755] or ((not complete[25958]) and (not complete[25747]) and (not questLog[25958]) and (not questLog[25747])) or false
    end

    if phase == phases.VASHJIR_NORTHERN_GARDEN then
        return (not complete[25966]) and (not complete[25755]) and ((complete[25958] or complete[25747] or questLog[25958] or questLog[25747]) and true) or false
    end

    if phase == phases.VASHJIR_NAR_SHOLA_TERRACE_WEST then
        return (not complete[25967]) and (not complete[25892]) and (complete[26191] or complete[25750]) or false
    end

    if phase == phases.VASHJIR_NAR_SHOLA_TERRACE then
        return (not complete[25966]) and (not complete[26191]) and
            ((complete[25959] and complete[25960] and complete[25962]) or
                (complete[25748] and complete[25749] and complete[25751])) or false
    end

    if phase == phases.VASHJIR_LADY_NAZ_JAR_AT_TEMPLE then
        return (not complete[25629]) or (not complete[25896])
    end

    if phase == phases.VASHJIR_LADY_NAZ_JAR_AT_BRIDGE then
        return (complete[25629] and complete[25896]) or false
    end

    if phase == phases.VASHJIR_LADY_NAZ_JAR_AT_RIDGE then
        return complete[25859] or false
    end

    if phase == phases.VASHJIR_ERANUK_AT_CAVERN then
        return (not complete[25987] and not complete[25988]) or complete[26143] or false
    end

    if phase == phases.VASHJIR_ERANUK_AT_PROMONTORY_POINT then
        return ((complete[25987] or complete[25988]) and (not complete[26143])) or false
    end

    if phase == phases.SIRA_KESS_AT_GARDEN then
        return ((not complete[25658]) and (not questLog[25658])) or false
    end

    if phase == phases.SIRA_KESS_AT_NAR_SHOLA_TERRACE then
        return (complete[25658] or questLog[25658]) and true or false
    end

    if phase == phases.WAVESPEAKER_AT_RUINS then
        return ((questLog[25957] and questLog[25957].isComplete == 1) or (questLog[25760] and questLog[25760].isComplete == 1)) or false
    end

    if phase >= phases.DRAGONMAW_PORT_CHAPTER_1 and phase <= phases.DRAGONMAW_PORT_CHAPTER_3 then
        return _Phasing.DragonmawPort(phase, complete) or false
    end

    if phase >= phases.THE_STONE_MARCH and phase <= phases.TEMPLE_OF_EARTH_CHAPTER_3 then
        return _Phasing.TempleOfEarth(phase, complete) or false
    end

    if phase == phases.TWILIGHT_GATE_PRE_INVASION and (not complete[27301]) then
        return complete[28249] or false
    end

    if phase == phases.TWILIGHT_GATE then
        return complete[27301] or false
    end

    if phase == phases.TWILIGHT_CARAVAN_AMBUSH_HORDE then
        return ((not complete[28092]) and (not questLog[28092])) and ((not complete[28094]) and (not questLog[28094])) or false
    end

    if phase == phases.TWILIGHT_CARAVAN_AMBUSH_ALLIANCE then
        return complete[27509] and (not complete[28101]) or false
    end

    if phase == phases.GRIM_BATOL_ATTACK_HORDE then
        return (complete[28092] or (questLog[28092] and questLog[28092].isComplete == 1)) or (complete[28094] or (questLog[28094] and questLog[28094].isComplete == 1)) or false
    end

    if phase == phases.GRIM_BATOL_ATTACK_ALLIANCE then
        return (complete[28103] or (questLog[28103] and questLog[28103].isComplete == 1)) or (complete[28104] or (questLog[28104] and questLog[28104].isComplete == 1)) or false
    end

    if phase == phases.ISORATH_NIGHTMARE then
        return complete[27303] or false
    end

    if phase >= phases.KEZAN_CHAPTER_1 and phase <= phases.KEZAN_CHAPTER_7 then
        return _Phasing.Kezan(phase, complete) or false
    end

    if phase == phases.HYJAL_HAMUUL_RUNETOTEM_AT_SANCTUARY then
        return (not (complete[25520] and complete[25502]))
    end

    if phase == phases.HYJAL_HAMUUL_RUNETOTEM_AT_GROVE then
        return complete[25520] and complete[25502] or false
    end

    if phase == phases.HYJAL_THISALEE_AT_SHRINE then
        return complete[25807] or ((not complete[25740]) and (not questLog[25740]))
    end

    if phase == phases.HYJAL_THISALEE_AT_SETHRIAS_ROOST then
        return (not complete[25807]) and (complete[25740] or (questLog[25740] and true) or false)
    end

    if phase == phases.CORITHRAS_AT_DOLANAAR then
        return (not complete[7383]) and (not questLog[7383])
    end

    if phase == phases.CORITHRAS_AT_CROSSROAD then
        return (complete[7383] or questLog[7383] and true) or false
    end

    if phase == phases.CERELLEAN_NEAR_EDGE then
        return (not complete[13515])
    end

    if phase == phases.CERELLEAN_NEAR_TREE then
        return complete[13515] or false
    end

    if phase == phases.ILTHALAINE_AT_BENCH then
        return not complete[28713]
    end

    if phase == phases.ILTHALAINE_AT_ROAD then
        return complete[28713] or false
    end

    if phase == phases.KEZAN_SASSY_IN_HQ then
        return (not complete[14116])
    end

    if phase == phases.KEZAN_SASSY_OUTSIDE_HQ then
        return complete[14116] or false
    end

    if phase == phases.KEZAN_GALLYWIX_AT_HQ then
        return (not complete[14120])
    end

    if phase == phases.KEZAN_GALLYWIX_ON_BOAT then
        return complete[14120] or false
    end

    if phase == phases.AGTOR_GRABBIT_OUTSIDE_ATTACK then
        return complete[14155] or (not complete[14135]) or (questLog[14155] and questLog[14155].isComplete == 1) or false
    end

    if phase == phases.AGTOR_GRABBIT_DURING_ATTACK then
        return questLog[14155] and questLog[14155].isComplete ~= 1 and true or false
    end

    if phase == phases.MOLOTOV_AT_RUINS then
        return (not complete[24453])
    end

    if phase == phases.MOLOTOV_AT_HARBOR then
        return complete[24453] or false
    end

    if phase == phases.SORATA_AT_EXCHANGE then
        return (not complete[14340])
    end

    if phase == phases.SORATA_AT_HARBOR then
        return complete[14340] or false
    end

    if phase == phases.SCARLET_ENCLAVE_ENTRACE then
        return (not complete[27460])
    end

    if phase == phases.SCARLET_ENCLAVE then
        return complete[27460] or false
    end

    if phase == phases.HAR_KOA_AT_ALTAR then
        return (not complete[12685])
    end

    if phase == phases.HAR_KOA_AT_ZIM_TORGA then
        return complete[12685] or false
    end

    if phase == phases.EARTHEN_GUIDE_BFD then
        return (not complete[11891]) and (not questLog[11891])
    end

    if phase == phases.EARTHEN_GUIDE_SHORE then
        return (complete[11891] or questLog[11891] and true) or false
    end

    if phase == phases.JAROD_NEAR_PORTAL then
        return (not complete[25608])
    end

    if phase == phases.JAROD_MIDDLE_ISLAND then
        return complete[25608] or false
    end

    if phase == phases.PEBBLE_AT_KOR then
        return complete[26441] or ((not complete[26440]) and (not questLog[26440])) or false
    end

    if phase == phases.PEBBLE_AT_CRYSTALS then
        return (complete[26440] and not complete[26441]) or (questLog[26440] and questLog[26440].isComplete == 1) or false
    end

    if phase == phases.TERRATH_AT_AEOSERA then
        return complete[26659] or (questLog[26659] and questLog[26659].isComplete == 1) or false
    end

    if phase == phases.NPCS_AT_THERAZANES_THRONE then
        return (complete[26659] and complete[26584] and complete[26585] and not complete[26827]) or complete[26971] or false
    end

    if phase == phases.FARGO_AT_CATAPULTS then
        return (not complete[27106])
    end

    if phase == phases.FARGO_AT_DOCKS then
        return complete[27106] or false
    end

    if phase == phases.THORDUN_AT_TREE then
        return (not complete[27516])
    end

    if phase == phases.THORDUN_IN_KEEP then
        return complete[27516] or false
    end

    if phase == phases.TORUNSCAR_START then
        return (not complete[26971]) and (not questLog[26971])
    end

    if phase == phases.TORUNSCAR_END then
        return complete[26971] or (questLog[26971] and questLog[26971].isComplete == 1) or false
    end

    if phase == phases.THERAZANE_AT_TEMPLE then
        return (complete[26971] and (not complete[26709])) or (questLog[26971]) or false
    end

    if phase == phases.THERAZANE_AT_THRONE_BEFORE_MARCH then
        return (complete[26871] and (not complete[26750])) or false
    end

    if phase == phases.VOLJIN_BOOTY_BAY then
        return complete[29152] or questLog[29152] or complete[29250] or questLog[29250] or false
    end

    if phase == phases.MOUNT_HYJAL_INVASION_START then
        return (not complete[29196])
    end

    if phase == phases.MOUNT_HYJAL_INVASION_SANCTUARY_ATTACK then
        return complete[29196] and (not complete[29198]) and (not questLog[29198] or (questLog[29198] and questLog[29198].isComplete == 0)) or false
    end

    if phase == phases.MOUNT_HYJAL_INVASION_SANCTUARY then
        return complete[29198] or (questLog[29198] and (questLog[29198].isComplete == 1)) or false
    end

    if phase == phases.MOUNT_HYJAL_VISION_YSERA_1 then
        return complete[25611] or false
    end

    if phase == phases.MOUNT_HYJAL_VISION_YSERA_2 then
        return (complete[25502] and complete[25520] and (not complete[25830])) or false
    end

    if phase == phases.GRYAN_TOWER then
        return (not complete[26322])
    end

    if phase == phases.GRYAN_FP then
        return complete[26322] or false
    end

    if phase == phases.MOLTEN_FRONT_DRUIDS then
        return complete[29206] and ((not questLog[29273] and not questLog[29274]) or ((questLog[29273] and (questLog[29273].isComplete == 0)) or (questLog[29274] and (questLog[29274].isComplete == 0)))) or false
    end

    if phase == phases.MOLTEN_FRONT_WARDENS then
        return complete[29205] and ((not questLog[29275] and not questLog[29276]) or ((questLog[29275] and (questLog[29275].isComplete == 0)) or (questLog[29276] and (questLog[29276].isComplete == 0)))) or false
    end

    if phase == phases.MOLTEN_FRONT_CAMP then
        return (questLog[29273] and questLog[29273].isComplete == 1) or (questLog[29274] and questLog[29274].isComplete == 1) or (questLog[29275] and questLog[29275].isComplete == 1) or (questLog[29276] and questLog[29276].isComplete == 1) or false
    end

    if phase == phases.MARRIS_BRIDGE then
        return (not complete[26513])
    end

    if phase == phases.MARRIS_STABLES then
        return complete[26513] or false
    end

    if phase == phases.RAMBO_TEAM_CANYON then
        return (not complete[26708]) and ((not questLog[26708]) or (questLog[26708] and questLog[26708].isComplete == 0)) or false
    end

    if phase == phases.RAMBO_TEAM_POST then
        return complete[26708] or (questLog[26708] and (questLog[26708].isComplete == 1)) or false
    end

    if phase == phases.SVEN_YORGEN_VISIBLE then
        return complete[26760] or (questLog[26760] and (questLog[26760].isComplete == 1)) or false
    end

    if phase == phases.AGGRA_THRONE then
        return (not complete[29329]) and ((not questLog[29329]) or (questLog[29329] and questLog[29329].isComplete == 0)) or false
    end

    if phase == phases.AGGRA_PRECIPICE then
        return complete[29329] or (questLog[29329] and questLog[29329].isComplete == 1) or false
    end

    if phase == phases.THRALL_AGGRA_PROPOSAL then
        return (not complete[29331])
    end

    if phase == phases.THURMAN_AT_CHILLWIND then
        return (not complete[27170])
    end

    if phase == phases.THURMAN_AT_WRITHING then
        return (complete[27170] and (not complete[27197] or questLog[27197])) or false
    end

    if phase == phases.THASSARIAN_WPL_TOWER then
        return (not complete[27174])
    end

    if phase == phases.THASSARIAN_WPL_FP then
        return complete[27174] or false
    end

    if phase == phases.CARAVAN_THONDRORIL then
        return (not complete[27373]) and ((not questLog[27373]) or (questLog[27373] and questLog[27373].isComplete == 0)) or false
    end

    if phase == phases.CARAVAN_CROWNGUARD then
        return ((complete[27373]) or (questLog[27373] and questLog[27373].isComplete == 1)) and (not complete[27448]) and ((not questLog[27448]) or (questLog[27448] and questLog[27448].isComplete == 0)) or false
    end

    if phase == phases.CARAVAN_LIGHTS_SHIELD then
        return ((complete[27448]) or (questLog[27448] and questLog[27448].isComplete == 1)) and (not complete[27465]) or false
    end

    if phase == phases.CARAVAN_EASTWALL then
        return (complete[27465]) and (not complete[27489]) and ((not questLog[27489]) or (questLog[27489] and questLog[27489].isComplete == 0)) or false
    end

    if phase == phases.CARAVAN_NORTHPASS then
        return ((complete[27489]) or (questLog[27489] and questLog[27489].isComplete == 1)) and (not complete[27526]) or false
    end

    if phase == phases.CARAVAN_LIGHTS_HOPE then
        return complete[27526] or false
    end

    if phase == phases.VEXTUL_SPAWN then
        return (not complete[27449])
    end

    if phase == phases.VEXTUL_FIONA then
        return complete[27449] and (not complete[27465]) or false
    end

    if phase == phases.TARENAR_NORTHPASS then
        return (not complete[27522]) and ((complete[27489]) or (questLog[27489] and questLog[27489].isComplete == 1)) or false
    end

    if phase == phases.TARENAR_PLAGUEWOOD then
        return complete[27522] and ((not complete[27526]) and ((not questLog[27526]) or (questLog[27526] and questLog[27526].isComplete == 0))) or false
    end

    if phase == phases.TARENAR_SAVED_GIDWIN then
        return (not complete[27527]) and (complete[27526] or (questLog[27526] and questLog[27526].isComplete == 1)) or false
    end

    if phase == phases.TARENAR_GIDWIN_LHC then
        return complete[27527] or false
    end

    if phase == phases.RHEA_LETHLOR_RAVINE then
        return (not complete[27769])
    end

    if phase == phases.RHEA_NEW_KARGATH then
        return complete[27888] and (not complete[27897]) and (not questLog[27897]) or false
    end

    if phase == phases.RHEA_DRAGONS_MOUTH then
        return complete[27794] and ((not complete[27832]) and ((not questLog[27832]) or (questLog[27832] and questLog[27832].isComplete == 0))) or false
    end

    if phase == phases.RHEA_HIDDEN_CLUTCH then
        return (complete[27832] or questLog[27832] or complete[27897] or questLog[27897]) and true or false
    end

    if phase == phases.DEATHWING_TELDURIN then
        return (not complete[27713])
    end

    if phase == phases.DEATHWING_MARTEK then
        return complete[27713] or false
    end

    if phase == phases.SEARING_GORGE_NPCS_TOWERS then
        return ((not complete[28052]) and (not questLog[28052])) or complete[28062]
    end

    if phase == phases.SEARING_GORGE_CAVE_ASSAULT then
        return (complete[28052] or questLog[28052]) and (not complete[28062]) or false
    end

    if phase == phases.LUNK_IRON_SUMMIT then
        return (not complete[28062])
    end

    if phase == phases.LUNK_THORIUM_POINT then
        return complete[28062] or false
    end

    if phase == phases.HORATIO_JANSEN_STEAD then
        return (not complete[26270])
    end

    if phase == phases.HORATIO_SENTINEL_HILL then
        return (complete[26270] and (not complete[26322])) or false
    end

    if phase == phases.BS_PRE_ASSAULT then
        return (not complete[28320])
    end

    if phase == phases.BS_POST_ASSAULT then
        return complete[28320] or false
    end

    if phase == phases.SETHMAN_VISIBLE then
        return (complete[26732] or (questLog[26732] and questLog[26732].isComplete == 1)) or false
    end

    if phase == phases.LASHTAIL_VISIBLE then
        return complete[26739] or false
    end

    if phase == phases.BERRIN_EMERINE_OSBORN_CAGE then
        return (not complete[26736])
    end

    if phase == phases.BERRIN_EMERINE_OSBORN_RESCUED then
        return complete[26736] or false
    end

    if phase == phases.BOOTY_BAY_REGULAR then
        return (not complete[26678]) or complete[26703] or false
    end

    if phase == phases.BOOTY_BAY_ATTACK then
        return complete[26678] and (not complete[26703]) or false
    end

    if phase == phases.HOLLEE_RUINS then
        return not complete[13605]
    end

    if phase == phases.HOLLEE_CAMP then
        return complete[13605] or false
    end

    if phase == phases.SERENDIA_FP then
        return not complete[13518] and not complete[13522]
    end

    if phase == phases.SERENDIA_INN then
        return complete[13518] and complete[13522] or false
    end

    if phase == phases.GRIMCLAW_THICKET then
        return not complete[13599]
    end

    if phase == phases.GRIMCLAW_INN then
        return complete[13599] or false
    end

    if phase == phases.BARGE_AT_PEACE then
        return (((not complete[25515]) and (not complete[25517]) and (not complete[25524])) or ((not complete[25516]) and (not complete[25518]) and (not complete[25526]))) or complete[25542] or complete[25543] or complete[25561] or complete[25562] or false
    end

    if phase == phases.BARGE_UNDER_ATTACK then
        return (complete[25515] and complete[25517] and complete[25524] and (not complete[25542]) and (not complete[25561])) or (complete[25516] and complete[25518] and complete[25526] and (not complete[25543]) and (not complete[25562])) or false
    end

    if phase == phases.KELSEY_AT_COVE then
        return not complete[26889]
    end

    if phase == phases.HORATIO_IRONCLAD_COVE then
        return complete[27790] or complete[27850] or (questLog[27790] and questLog[27790].isComplete == 1) or (questLog[27850] and questLog[27850].isComplete == 1) or false
    end

    if phase == phases.DEADMINES_HOGGER_ALIVE then
        return not questLog[27739]
    end

    if phase == phases.DEADMINES_HOGGER_DEAD then
        return (questLog[27739] and questLog[27739].isComplete == 1) or false
    end

    if phase == phases.SILVERPINE_FOREST_HIGH_COMMAND then
        return not complete[27098] and (not questLog[27098] or (questLog[27098] and questLog[27098].isComplete == 0)) or false
    end

    if phase == phases.SILVERPINE_FOREST_SEPULCHER then
        return (complete[27098] or (questLog[27098] and questLog[27098].isComplete == 1)) and (not complete[27438]) or false
    end

    if phase == phases.SILVERPINE_FOREST_FORSAKEN_FRONT then
        return complete[27438] and (not complete[27472] and (not questLog[27472] or (questLog[27472] and questLog[27472].isComplete == 0))) or false
    end

    if phase == phases.SILVERPINE_FOREST_FORSAKEN_FRONT_2 then
        return (complete[27472] or (questLog[27472] and questLog[27472].isComplete == 1)) and (not complete[27601] and (not questLog[27601] or (questLog[27601] and questLog[27601].isComplete == 0))) or false
    end

    if phase == phases.SILVERPINE_FOREST_BATTLEFRONT then
        return complete[27601] or (questLog[27601] and questLog[27601].isComplete == 1) or false
    end

    if phase == phases.RUINS_OF_GILNEAS_FFC then
        return not complete[27401]
    end

    if phase == phases.RUINS_OF_GILNEAS_EMBERSTONE then
        return complete[27401] and (not complete[27406]) and (not complete[27423]) or false
    end

    if phase == phases.RUINS_OF_GILNEAS_TEMPESTS_REACH then
        return complete[27406] and complete[27423] and (not complete[27438]) or false
    end

    if phase == phases.SHADOWFANG_KEEP_ENTRANCE_A then
        return (not complete[27917]) and (not questLog[27917] or (questLog[27917] and questLog[27917].isComplete == 0)) or false
    end

    if phase == phases.SHADOWFANG_KEEP_ENTRANCE_H then
        return (not complete[27974]) and (not questLog[27974] or (questLog[27974] and questLog[27974].isComplete == 0)) or false
    end

    if phase == phases.SHADOWFANG_KEEP_ASHBURY_DEAD_A then
        return (complete[27917] or (questLog[27917] and questLog[27917].isComplete == 1)) and ((not complete[27920]) and (not questLog[27920] or (questLog[27920] and questLog[27920].isComplete == 0))) or false
    end

    if phase == phases.SHADOWFANG_KEEP_ASHBURY_DEAD_H then
        return (complete[27974] or (questLog[27974] and questLog[27974].isComplete == 1)) and ((not complete[27988]) and (not questLog[27988] or (questLog[27988] and questLog[27988].isComplete == 0))) or false
    end

    if phase == phases.SHADOWFANG_KEEP_SPRINGVALE_DEAD_A then
        return (complete[27920] or (questLog[27920] and questLog[27920].isComplete == 1)) and ((not complete[27921]) and (not questLog[27921] or (questLog[27921] and questLog[27921].isComplete == 0))) or false
    end

    if phase == phases.SHADOWFANG_KEEP_SPRINGVALE_DEAD_H then
        return (complete[27988] or (questLog[27988] and questLog[27988].isComplete == 1)) and ((not complete[27996]) and (not questLog[27996] or (questLog[27996] and questLog[27996].isComplete == 0))) or false
    end

    if phase == phases.SHADOWFANG_KEEP_WALDEN_DEAD_A then
        return (complete[27921] or (questLog[27921] and questLog[27921].isComplete == 1)) and ((not complete[27968]) and (not questLog[27968] or (questLog[27968] and questLog[27968].isComplete == 0))) or false
    end

    if phase == phases.SHADOWFANG_KEEP_WALDEN_DEAD_H then
        return (complete[27996] or (questLog[27996] and questLog[27996].isComplete == 1)) and ((not complete[27998]) and (not questLog[27998] or (questLog[27998] and questLog[27998].isComplete == 0))) or false
    end

    if phase == phases.SHADOWFANG_KEEP_GODFREY_DEAD_A then
        return (complete[27968] or (questLog[27968] and questLog[27968].isComplete == 1)) or false
    end

    if phase == phases.SHADOWFANG_KEEP_GODFREY_DEAD_H then
        return (complete[27998] or (questLog[27998] and questLog[27998].isComplete == 1)) or false
    end

    if phase == phases.LYDON_AWESOME_CAGE then
        return not complete[28235]
    end

    if phase == phases.LYDON_AWESOME_MAIN_BUILDING then
        return complete[28235] or false
    end

    if phase == phases.ORKUS_IN_WATER then
        return (not complete[28345]) and (not questLog[28345] or (questLog[28345] and questLog[28345].isComplete == 0)) or false
    end

    if phase == phases.ORKUS_ON_LAND then
        return (complete[28345] or (questLog[28345] and questLog[28345].isComplete == 1)) or false
    end

    if phase == phases.ET_MUROZOND_DEAD then
        return complete[30096] or (questLog[30096] and questLog[30096].isComplete == 1) or false
    end

    if phase == phases.WILLIX_IN_TENT then
        return not questLog[26903]
    end

    if phase == phases.WILLIX_AT_EXIT then
        return questLog[26903]
    end

    if phase == phases.WOT_NOZDORMU_1 then
        return false
    end

    if phase == phases.WOT_NOZDORMU_2 then
        return false
    end

    if phase == phases.WOT_NOZDORMU_3 then
        return false
    end

    if phase == phases.KAMMAH_STONE then
        return not complete[14325] and (not questLog[14325] or (questLog[14325] and questLog[14325].isComplete == 0)) or false
    end

    if phase == phases.KAMMAH_TENT then
        return complete[14325] or (questLog[14325] and questLog[14325].isComplete == 1) or false
    end

    if phase == phases.BALNAZZAR_DEAD then
        return complete[27208] or (questLog[27208] and questLog[27208].isComplete == 1) or false
    end

    if phase == phases.RIVENDARE_DEAD then
        return complete[27227] or (questLog[27227] and questLog[27227].isComplete == 1) or false
    end

    if phase == phases.KARGATH_DEAD then
        return complete[29653] or (questLog[29653] and questLog[29653].isComplete == 1) or complete[29654] or (questLog[29654] and questLog[29654].isComplete == 1) or false
    end

    if phase == phases.CAYDEN_START_AMBUSH then
        return not complete[27648] and (not questLog[27648] or (questLog[27648] and questLog[27648].isComplete == 0)) or false
    end

    if phase == phases.CAYDEN_FINISH_AMBUSH then
        return complete[27648] or (questLog[27648] and questLog[27648].isComplete == 1) or false
    end

    if phase == phases.OHF_THRALL_PRISON then
        return not complete[29599] and (not questLog[29599] or (questLog[29599] and questLog[29599].isComplete == 0)) or false
    end

    if phase == phases.OHF_THRALL_DESTINY then
        return complete[29599] or (questLog[29599] and questLog[29599].isComplete == 1) or false
    end

    if phase == phases.LINDSAY_WPL_TREE then
        return not complete[26936] or false
    end

    if phase == phases.LINDSAY_WPL_TENT then
        return (complete[26936] and not complete[27083]) or false
    end

    if phase == phases.LINDSAY_WPL_INN then
        return complete[27083] or false
    end

    if phase == phases.MGT_KT_DEAD then
        return complete[29685] or (questLog[29685] and questLog[29685].isComplete == 1) or false
    end

    if phase == phases.THE_BARRENS_KADRAK_MORSHAN then
        return not complete[13712] and (not questLog[13712] or (questLog[13712] and questLog[13712].isComplete == 0)) or false
    end

    if phase == phases.ZAZZO_GILNEAS then
        return not complete[30107] or false
    end

    if phase == phases.ZAZZO_DEADWIND then
        return complete[30107] or false
    end

    if phase == phases.KALEC_TERMINUS then
        return complete[14391] or (questLog[14391] and questLog[14391].isComplete == 1) or false
    end

    if phase == phases.STONETALON_CLIFFWALKER_JUSTICE then
        return not complete[26099] or false
    end

    if phase == phases.STONETALON_CLIFFWALKER_RAMP then
        return complete[26099] and not complete[26115] or false
    end

    if phase == phases.STONETALON_CLIFFWALKER_GARROSH then
        return complete[26115] or false
    end

    if phase == phases.SHANG_XI_BENCH then
        return  not complete[29524] and (not questLog[29524] or (questLog[29524] and questLog[29524].isComplete == 0)) or false
    end

    if phase == phases.SHANG_XI_DOORWAY then
        return (complete[29524] or (questLog[29524] and questLog[29524].isComplete == 1)) and (not complete[29409] and (not questLog[29409] or (questLog[29409] and questLog[29409].isComplete == 0))) or false
    end

    if phase == phases.SHANG_XI_BRIDGE then
        return (complete[29409] or (questLog[29409] and questLog[29409].isComplete == 1)) or false
    end

    if phase == phases.DRIVER_NOT_RESCUED then
        return not complete[29419] and (not questLog[29419] or (questLog[29419] and questLog[29419].isComplete == 0)) or false
    end

    if phase == phases.DRIVER_RESCUED then
        return (complete[29419] or (questLog[29419] and questLog[29419].isComplete == 1)) or false
    end

    if phase == phases.SHANG_XI_TEMPLE_NORTH then
        return not complete[29774] or false
    end

    if phase == phases.SHANG_XI_TEMPLE_SOUTH then
        return complete[29774] or false
    end

    if phase == phases.AYSA_LIANG_POOL_HOUSE then
        return not complete[29676] or false
    end

    if phase == phases.AYSA_LIANG_BRIDGE then
        return complete[29676] and (not complete[29678] and (not questLog[29678] or (questLog[29678] and questLog[29678].isComplete == 0))) or false
    end

    if phase == phases.AYSA_LIANG_LAKE then
        return complete[29678] or (questLog[29678] and questLog[29678].isComplete == 1) or false
    end

    if phase == phases.AYSA_ROPE then
        return not complete[29785] or false
    end

    if phase == phases.AYSA_CAVE then
        return complete[29785] or false
    end

    if phase == phases.SKYFIRE_STORMWIND then
        return not complete[29548] and (not questLog[29548] or (questLog[29548] and questLog[29548].isComplete == 0)) or false
    end

    if phase == phases.SKYFIRE_JADE_FOREST then
        return (complete[29548] or (questLog[29548] and questLog[29548].isComplete == 1)) and not complete[30070] or false
    end

    if phase == phases.RELL_ON_BARRELS then
        return not complete[31735] and (not questLog[31735] or (questLog[31735] and questLog[31735].isComplete == 0)) or false
    end

    if phase == phases.RELL_ON_DOCKS then
        return (questLog[31735] and questLog[31735].isComplete == 1) or false
    end

    if phase == phases.RELL_ON_DOCKS_2 then
        return (complete[31735] and (not (complete[31736] and complete[31737]))) or false
    end

    if phase == phases.RELL_PAWDON_VILLAGE then
        return complete[31736] and complete[31737] and not complete[30070] and (not questLog[30070] or (questLog[30070] and questLog[30070].isComplete == 0)) or false
    end

    if phase == phases.RELL_TWINSPIRE_KEEP then
        return complete[30070] or (questLog[30070] and questLog[30070].isComplete == 1) or false
    end

    if phase == phases.ADMIRAL_ROGERS_PAWDON_VILLAGE then
        return complete[30070] or false
    end

    if phase == phases.SASHA_AT_DUSKHOWL_DEN then
        return complete[12411] and (not complete[12164]) and ((not questLog[12164]) or questLog[12164].isComplete == 0) or false
    end

    if phase == phases.SASHA_AT_BLOODMOON_ISLE then
        return complete[12164] or (questLog[12164] and questLog[12164].isComplete == 1) or false
    end

    if phase == phases.FUSELAGE_ROCKET then
        return not complete[10248]
    end

    if phase == phases.FUSELAGE_CITY_SAVED then
        return complete[10248] or false
    end

    if phase == phases.HOODED_CRUSADER_ATHENAEUM_31 then
        return complete[31493] or (questLog[31493] and questLog[31493].isComplete == 1) or false
    end

    if phase == phases.HOODED_CRUSADER_ATHENAEUM_90 then
        return complete[31497] or (questLog[31497] and questLog[31497].isComplete == 1) or false
    end

    if phase == phases.TALKING_SKULL_BRIDGE_43 then
        return not complete[31447] and (not questLog[31447] or (questLog[31447] and questLog[31447].isComplete == 0)) or false
    end

    if phase == phases.TALKING_SKULL_STUDY_43 then
        return complete[31447] or (questLog[31447] and questLog[31447].isComplete == 1) or false
    end

    if phase == phases.TALKING_SKULL_BRIDGE_90 then
        return not complete[31448] and (not questLog[31448] or (questLog[31448] and questLog[31448].isComplete == 0)) or false
    end

    if phase == phases.TALKING_SKULL_STUDY_90 then
        return complete[31448] or (questLog[31448] and questLog[31448].isComplete == 1) or false
    end

    if phase == phases.RAGEFIRE_CHASM_GORDOTH_DEAD then
        return complete[30983] or complete[30996] or (questLog[30983] and questLog[30983].isComplete == 1) or (questLog[30996] and questLog[30996].isComplete == 1) or false
    end

    if phase == phases.RIVETT_CLUTCHPOP_NOOK_OF_KONK then
        return (not complete[31779]) and ((not questLog[31779] or questLog[31779].isComplete == 0)) or false
    end

    if phase == phases.RIVETT_CLUTCHPOP_STROGARM_AIRSTRIP then
        return complete[31779] or (questLog[31779] and questLog[31779].isComplete == 1) or false
    end

    if phase == phases.RIVETT_CLUTCHPOP_NEXT_TO_NAZGRIM then
        return (not complete[29937]) and ((not questLog[29937] or questLog[29937].isComplete == 0)) or false
    end

    if phase == phases.RIVETT_CLUTCHPOP_GROOKIN_HILL_SOUTH_END then
        return complete[29937] or (questLog[29937] and questLog[29937].isComplete == 1) or false
    end

    if phase == phases.HIGH_ELDER_CLOUDFALL_AT_TOWER then
        return (complete[29639] or complete[29646] or complete[29647]) or (complete[29620] or (not questLog[29620]) and (not (complete[29624] and complete[29628] and complete[29629] and complete[29630] and complete[29637]))) or false
    end

    if phase == phases.HIGH_ELDER_CLOUDFALL_AT_BANQUET then
        return (not (complete[29639] or complete[29646] or complete[29647])) and (complete[29624] and complete[29628] and complete[29629] and complete[29630] and complete[29637]) or questLog[29620] and true or false
    end

    if phase == phases.MALIK_AT_PILLAR then
        return (not complete[31010]) or false
    end

    if phase == phases.MALIK_NEXT_TO_ZIKK then
        return complete[31010] and true or false
    end

    if phase == phases.KIL_RUK_AT_PILLAR_1 then
        return not complete[31006] or false
    end

    if phase == phases.KIL_RUK_AT_PILLAR_2 then
        return complete[31006] and (not complete[31066]) and (not questLog[31066] or questLog[31066].isComplete == 0) or false
    end

    if phase == phases.KIL_RUK_NEXT_TO_ZIKK then
        return complete[31066] or (questLog[31066] and questLog[31066].isComplete == 1) and true or false
    end

    if phase == phases.SOGGY_IN_HUT then
        return (not complete[31189]) and (not questLog[31189] or questLog[31189].isComplete == 0) or false
    end

    if phase == phases.SOGGY_OUTSIDE then
        return (complete[31189] or (questLog[31189] and questLog[31189].isComplete == 1)) and ((not complete[31190]) and (not questLog[31190] or questLog[31190].isComplete == 0)) and true or false
    end

    if phase == phases.SOGGY_AT_DOCK then
        return complete[31190] or (questLog[31190] and questLog[31190].isComplete == 1) and true or false
    end

    if phase == phases.ARIE_AT_DOCK then
        return (complete[31190] or (questLog[31190] and questLog[31190].isComplete == 1)) and not complete[30354] or false
    end

    if phase == phases.JU_LIEN_AT_COAST then
        return complete[31354] or ((not complete[31189]) and ((not questLog[31189]) or questLog[31189].isComplete == 0)) and true or false
    end

    if phase == phases.JU_LIEN_IN_TOWN then
        return (not complete[31354]) and (complete[31189] or (questLog[31189] and questLog[31189].isComplete == 1)) and true or false
    end

    if phase == phases.CHEN_AT_FEAR_CLUTCH then
        return (not complete[31077]) and (not questLog[31077]) or false
    end

    if phase == phases.CHEN_AT_BREWGARDEN then
        return complete[31077] or questLog[31077] and true or false
    end

    if phase == phases.CHEN_62779_AT_BREWGARDEN then
        return not complete[31078] and not questLog[31078] or false
    end

    if phase == phases.CHEN_62779_INSIDE_KOR_VESS then
        return (not complete[31078]) and questLog[31078] and true or false
    end

    if phase == phases.SAP_MASTERS_AT_BREWGARDEN then
        return (not complete[31085]) and (not complete[31075]) and (not questLog[31075]) or false
    end

    if phase == phases.SAP_MASTERS_AT_RIKKITUN then
        return (not complete[31085]) and ((not questLog[31085]) or questLog[31085].isComplete == 0) and complete[31075] or questLog[31075] and true or false
    end

    if phase == phases.SAP_MASTERS_AT_BREWGARDEN_CENTER then
        return complete[31085] or (questLog[31085] and questLog[31085].isComplete == 1) or false
    end

    if phase == phases.SKEER_IN_CAVE then
        return (not complete[31179]) and ((not questLog[31179] or questLog[31179].isComplete == 0)) and true or false
    end

    if phase == phases.SKEER_AT_KLAXXI_VESS then
        return complete[31179] or (questLog[31179] and questLog[31179].isComplete == 1) or false
    end

    if phase == phases.SHANG_THUNDERFOOT_AT_THUNDERFOOT_FIELDS then
        return (not complete[29918]) and (not questLog[29918]) or false
    end

    if phase == phases.SHANG_THUNDERFOOT_SOUTH_OF_THUNDERFOOT_FIELDS then
        return complete[29918] or questLog[29918] and true or false
    end

    if phase == phases.CLEVER_ASHYO_AT_POOLS_OF_PURITY then
        return complete[29577] or questLog[29577] and true or false
    end

    if phase == phases.CLEVER_ASHYO_AT_NEW_CIFERA then
        return not (complete[29577] or questLog[29577]) or false
    end

    if phase == phases.KOR_AT_THUNDER_CLEFT then
        return (not complete[30132]) and ((not questLog[30132]) or questLog[30132].isComplete == 0) or false
    end

    if phase == phases.KOR_AT_DAWNCHASER_RETREAT then
        return complete[30132] or (questLog[30132] and questLog[30132].isComplete == 1) or false
    end

    if phase == phases.DEZCO_AT_THUNDER_CLEFT then
        return not complete[30131] and (not questLog[30131] or questLog[30131].isComplete == 0) or false
    end

    if phase == phases.DEZCO_AT_THUNDER_CLEFT_TENT then
        return complete[30131] or (questLog[30131] and questLog[30131].isComplete == 1) or false
    end

    if phase == phases.DEZCO_AT_SHATTERED_CONVOY then
        return complete[30132] and not (complete[30174] or (questLog[30174] and questLog[30174].isComplete == 1)) or false
    end

    if phase == phases.DEZCO_AT_DAWNCHASER_RETREAT then
        return complete[30174] or (questLog[30174] and questLog[30174].isComplete == 1) or false
    end

    if phase == phases.LIN_TENDERPAW_EAST_OF_STONEPLOW then
        return (not complete[29984]) or false
    end

    if phase == phases.LIN_TENDERPAW_AT_PAOQUAN_HOLLOW then
        return complete[29984] or false
    end

    if phase == phases.HEMETS_AT_CAMP then
        return ((not complete[30185]) and (not questLog[30185])) or complete[30186] or (questLog[30186] and questLog[30186].isComplete == 1) or false
    end

    if phase == phases.HEMETS_OUTSIDE_CAMP then
        return (not complete[30186]) and (questLog[30185] or (complete[30185] and ((not questLog[30186]) or questLog[30186].isComplete == 0))) and true or false
    end

    if phase == phases.WU_PENG_ALONE then
        return ((not complete[30834]) and (not questLog[30834])) or false
    end

    if phase == phases.WU_PENG_REUNITED then
        return ((complete[30834]) or (questLog[30834])) or false
    end

    if phase == phases.ORBISS_AT_SUMPRUSH then
        return (not complete[30793]) and (not questLog[30793]) or false
    end

    if phase == phases.ORBISS_AT_BORROW then
        return (complete[30793] or questLog[30793]) and true or false
    end

    if phase == phases.KU_MO_AT_BRIDGE then
        return (not complete[30932]) and (not questLog[30932]) or false
    end

    if phase == phases.KU_MO_AT_TEMPLE then
        return (complete[30932] or questLog[30932]) and true or false
    end

    if phase == phases.SUNA_AT_OUTPOST then
        return (not complete[30769]) and (not questLog[30769]) or false
    end

    if phase == phases.SUNA_AT_CAMP_OSUL then
        return (complete[30769] or questLog[30769]) and true or false
    end

    if phase == phases.BAN_AT_OUTPOST then
        return complete[30776] or (questLog[30776] and questLog[30776].isComplete == 1) or false
    end

    if phase == phases.BAN_AT_CAMP_OSUL then
        return not (complete[30776] or (questLog[30776] and questLog[30776].isComplete == 1)) or false
    end

    if phase == phases.BEFORE_MANTID_INVASION then
        return ((not complete[30241]) and (not complete[30360]) and (not complete[30376])) or false
    end

    if phase == phases.AFTER_MANTID_INVASION then
        return ((complete[30241]) or (complete[30360]) or (complete[30376])) or false
    end

    if phase == phases.BLUESADDLE_TEMPLE then
        return (not complete[30929]) or false
    end

    if phase == phases.BLUESADDLE_LAKE then
        return (complete[30929]) or false
    end

    if phase == phases.BROTHER_YAKSHOE_AT_KNUCKLETHUMP_HOLE then
        return not (complete[30607] or (questLog[30607] and questLog[30607].isComplete == 1)) or false
    end

    if phase == phases.BROTHER_YAKSHOE_AT_BURLAP_WAYSTATION then
        return ((complete[30607] or (questLog[30607] and questLog[30607].isComplete == 1)) and not (complete[30610] or (questLog[30610] and questLog[30610].isComplete == 1))) or false
    end

    if phase == phases.BROTHER_YAKSHOE_AT_THE_DOOKER_DOME then
        return (complete[30610] or (questLog[30610] and questLog[30610].isComplete == 1)) and not (complete[30612] or (questLog[30612] and questLog[30612].isComplete == 1)) or false
    end

    if phase == phases.BROTHER_YAKSHOE_AT_BURLAP_WAYSTATION_2 then
        return complete[30612] or (questLog[30612] and questLog[30612].isComplete == 1) or false
    end

    if phase == phases.SULLY_BELOW_SKYFIRE then
        return (not complete[31735]) or false
    end

    if phase == phases.SULLY_TWINSPIRE_KEEP then
        return complete[31735] or false
    end

    if phase == phases.LUSSHAN_TOP_STAIRS then
        return not complete[29887] or (complete[29894] and not(complete[29905] and complete[29906]) and not (questLog[29905] and questLog[29905].isComplete == 1) and not (questLog[29906] and questLog[29906].isComplete == 1)) or false
    end

    if phase == phases.LUSSHAN_PUDDLE then
        return (complete[29887] and not complete[29894]) or false
    end

    if phase == phases.LUSSHAN_PEARLS then
        return (complete[29905] and complete[29906]) or ((questLog[29905] and questLog[29905].isComplete == 1) and (questLog[29906] and questLog[29906].isComplete == 1)) or false
    end

    if phase == phases.CHO_NEAR_BEER_TABLE then
        return not complete[31130] or false
    end

    if phase == phases.CHO_NEAR_PAGODAS then
        return complete[31130] or false
    end

    if phase == phases.AN_WINDFUR_DAWNS_BLOSSOM_GATE then
        return (not complete[29723]) and ((not questLog[29723]) or questLog[29723].isComplete == 0) or false
    end

    if phase == phases.AN_WINDFUR_DAWNS_BLOSSOM_UP then
        return complete[29723] or (questLog[29723] and questLog[29723].isComplete == 1) or false
    end

    if phase == phases.AN_WINDFUR_DAWNS_BLOSSOM_JADE_HOUSE then
        return (questLog[29723] and questLog[29723].isComplete == 0) or false
    end

    if phase == phases.AN_WINDFUR_FOREST_HEART then
        return (not complete[29723]) and ((not questLog[29723]) or questLog[29723].isComplete == 0) or complete[29723] or false
    end

    if phase == phases.SHEEPIE_FIRST_TIME then
        return not complete[31338] or false
    end

    if phase == phases.SHEEPIE_SECOND_TIME then
        return complete[31338] or false
    end

    if phase == phases.FARM_HAS_2_SLOTS then
        return complete[30535] or (questLog[30535] and questLog[30535].isComplete == 1) or false
    end

    if phase == phases.FARM_HAS_4_SLOTS then
        return complete[30256] or false
    end

    if phase == phases.FARM_HAS_8_SLOTS then
        return complete[30516] or false
    end

    if phase == phases.FARM_HAS_12_SLOTS then
        return complete[30524] or false
    end

    if phase == phases.FARM_HAS_16_SLOTS then
        return complete[30529] or false
    end

    if phase == phases.ZIN_AT_AXE_OF_THUNDER_KING then
        return complete[30642] or (questLog[30642] and questLog[30642].isComplete == 1) or false
    end

    if phase == phases.KILRUK_REVEALED then
        return (questLog[31612] and questLog[31612].isComplete == 1) or false
    end

    if phase == phases.SHADO_PAN_GARRISON_NORMAL then
        return not (questLog[31277] and questLog[31277].isComplete == 1) or false
    end

    if phase == phases.SHADO_PAN_GARRISON_SURPRISE_ATTACK then
        return (questLog[31277] and questLog[31277].isComplete == 1) or false
    end

    if phase == phases.XUEN_START then
        return not (complete[30879] or (questLog[30879] and questLog[30879].isComplete == 1)) and not (complete[30880] or (questLog[30880] and questLog[30880].isComplete == 1)) or false
    end

    if phase == phases.XUEN_AFTER_FIRST_FIGHT then
        return (complete[30879] or (questLog[30879] and questLog[30879].isComplete == 1)) and not (complete[30881] or (questLog[30881] and questLog[30881].isComplete == 1)) or 
               (complete[30880] or (questLog[30880] and questLog[30880].isComplete == 1)) and not (complete[30882] or (questLog[30882] and questLog[30882].isComplete == 1)) or false
    end

    if phase == phases.XUEN_AFTER_SECOND_FIGHT then
        return (complete[30881] or (questLog[30881] and questLog[30881].isComplete == 1)) and not (complete[30883] or (questLog[30883] and questLog[30883].isComplete == 1)) or 
               (complete[30882] or (questLog[30882] and questLog[30882].isComplete == 1)) and not (complete[30885] or (questLog[30885] and questLog[30885].isComplete == 1)) or false
    end

    if phase == phases.XUEN_AFTER_THIRD_FIGHT then
        return (complete[30883] or (questLog[30883] and questLog[30883].isComplete == 1)) and not (complete[30907] or (questLog[30907] and questLog[30907].isComplete == 1)) or 
               (complete[30885] or (questLog[30885] and questLog[30885].isComplete == 1)) and not (complete[30902] or (questLog[30902] and questLog[30902].isComplete == 1)) or false
    end

    if phase == phases.XUEN_AFTER_FOURTH_FIGHT then
        return (complete[30902] or (questLog[30902] and questLog[30902].isComplete == 1)) or (complete[30907] or (questLog[30907] and questLog[30907].isComplete == 1)) or false
    end

    if phase == phases.ZIN_AT_PAGODA then
        return complete[30638] and not complete[30642] or false
    end

    if phase == phases.PAGODA_UNDER_ATTACK then
        return (complete[30644] and (not complete[30646] and (not questLog[30646] or questLog[30646].isComplete == 0))) or false
    end

    if phase == phases.PAGODA_NOT_UNDER_ATTACK then
        return not (complete[30644] and (not complete[30646] and (not questLog[30646] or questLog[30646].isComplete == 0))) or false
    end

    if phase == phases.OLD_HILLPAW_NORMAL then
        return not complete[30368] and not (complete[30318] or questLog[30318]) or false
    end

    if phase == phases.OLD_HILLPAW_FARM then
        return complete[30368] and not (complete[30318] or questLog[30318]) or false
    end

    if phase == phases.OLD_HILLPAW_MARKET then
        return complete[30318] or questLog[30318] or false
    end

    if phase == phases.TINA_MUDCLAW_NORMAL then
        return not complete[30371] and not (complete[30323] or questLog[30323]) or false
    end

    if phase == phases.TINA_MUDCLAW_FARM then
        return complete[30371] and not (complete[30323] or questLog[30323]) or false
    end

    if phase == phases.TINA_MUDCLAW_MARKET then
        return complete[30323] or questLog[30323] or false
    end

    if phase == phases.FARMER_FUNG_NORMAL then
        return not complete[30370] and not (complete[30317] or questLog[30317]) or false
    end

    if phase == phases.FARMER_FUNG_FARM then
        return complete[30370] and not (complete[30317] or questLog[30317]) or false
    end

    if phase == phases.FARMER_FUNG_MARKET then
        return complete[30317] or questLog[30317] or false
    end

    if phase == phases.HAOHAN_MUDCLAW_NORMAL then
        return not complete[30369] and not (complete[30319] or questLog[30319]) or false
    end

    if phase == phases.HAOHAN_MUDCLAW_FARM then
        return complete[30369] and not (complete[30319] or questLog[30319]) or false
    end

    if phase == phases.HAOHAN_MUDCLAW_MARKET then
        return complete[30319] or questLog[30319] or false
    end

    if phase == phases.SHO_NORMAL then
        return not complete[30367] and not (complete[30325] or questLog[30325]) or false
    end

    if phase == phases.SHO_FARM then
        return complete[30367] and not (complete[30325] or questLog[30325]) or false
    end

    if phase == phases.SHO_MARKET then
        return complete[30325] or questLog[30325] or false
    end

    if phase == phases.ELLA_NORMAL then
        return not complete[30366] and not (complete[30327] or questLog[30327]) or false
    end

    if phase == phases.ELLA_FARM then
        return complete[30366] and not (complete[30327] or questLog[30327]) or false
    end

    if phase == phases.ELLA_MARKET then
        return complete[30327] or questLog[30327] or false
    end

    if phase == phases.FISH_FELLREED_NORMAL then
        return not complete[30372] and not (complete[30326] or questLog[30326]) or false
    end

    if phase == phases.FISH_FELLREED_FARM then
        return complete[30372] and not (complete[30326] or questLog[30326]) or false
    end

    if phase == phases.FISH_FELLREED_MARKET then
        return complete[30326] or questLog[30326] or false
    end

    if phase == phases.CHEE_CHEE_NORMAL then
        return not complete[30365] and not (complete[30324] or questLog[30324]) or false
    end

    if phase == phases.CHEE_CHEE_FARM then
        return complete[30365] and not (complete[30324] or questLog[30324]) or false
    end

    if phase == phases.CHEE_CHEE_MARKET then
        return complete[30324] or questLog[30324] or false
    end

    if phase == phases.GINA_MUDCLAW_FARM then
        return complete[30374] and not (complete[30322] or questLog[30322]) or false
    end

    if phase == phases.GINA_MUDCLAW_MARKET then
        return not complete[30374] or false
    end

    if phase == phases.JOGU_THE_DRUNK_FARM then
        return complete[30373] and not (complete[30321] or questLog[30321]) or false
    end

    if phase == phases.JOGU_THE_DRUNK_MARKET then
        return not complete[30373] or false
    end

    if phase == phases.RIKKAL_AT_ZANVESS then
        return not complete[31606] and questLog[31606] or false
    end

    if phase == phases.RIKKAL_AT_KLAXXIVESS then
        return complete[31606] or questLog[31606] or false
    end

    if phase == phases.HE_SOFTFOOT_DAILY then
        return complete[31131] or questLog[31131] or false
    end

    if phase == phases.HE_SOFTFOOT_NOT_DAILY then
        return not complete[31131] and not questLog[31131] or false
    end

    if phase == phases.GOLDEN_LOTUS_DAILY_LOCKED then
        return not complete[30638] or false
    end

    if phase == phases.GOLDEN_LOTUS_DAILY_UNLOCKED then
        return complete[30638] or false
    end

    if phase == phases.CHEN_AT_EAST_BRIDGE then
        return not (complete[29907] or questLog[29907]) or false
    end

    if phase == phases.CHEN_AT_PANGS_STEAD then
        return (complete[29907] or questLog[29907])and not complete[29918] or false
    end

    if phase == phases.CHEN_AT_SHANGS_STEAD then
        return complete[29918] and not (complete[29919] or (questLog[29919] and questLog[29919].isComplete == 1)) or false
    end

    if phase == phases.CHEN_AT_MUDMUGS_PLACE then
        return (complete[29919] or (questLog[29919] and questLog[29919].isComplete == 1)) and not (complete[29949] or questLog[29949]) or false
    end

    if phase == phases.CHEN_AT_MUDMUGS_PLACE_LEGACY then
        return (complete[29949] or questLog[29949]) and not (complete[30046] or questLog[30046]) or false
    end

    if phase == phases.CHEN_AT_HALFHILL then
        return ((complete[30046] or questLog[30046]) and not (complete[30073] or (questLog[30073] and questLog[30073].isComplete == 1))) or false
    end

    if phase == phases.CHEN_AT_HALFHILL_BREWED then
        return (complete[30073] or (questLog[30073] and questLog[30073].isComplete == 1)) and not questLog[30074] and not complete[30074] or false
    end

    if phase == phases.CHEN_AT_STORMSTOUT_BREWERY_DOOR then
        return questLog[30074] and not complete[30074] or false
    end

    if phase == phases.CHEN_AT_STORMSTOUT_BREWERY_HOZEN then
        return complete[30074] and not (complete[30075] or (questLog[30075] and questLog[30075].isComplete == 1)) or false
    end

    if phase == phases.MUDMUG_AT_STORMSTOUT_BREWERY_HOZEN then
        return complete[30074] and not (complete[30076] or (questLog[30076] and questLog[30076].isComplete == 1)) or false
    end

    if phase == phases.LI_LI_AT_STORMSTOUT_BREWERY_HOZEN then
        return complete[30074] and not (complete[30077] or (questLog[30077] and questLog[30077].isComplete == 1)) or false
    end

    if phase == phases.CHEN_AT_STORMSTOUT_BREWERY_SIDE then
        return (complete[30075] or (questLog[30075] and questLog[30075].isComplete == 1)) and not (complete[30078] or (questLog[30078] and questLog[30078].isComplete == 1)) or false
    end

    if phase == phases.MUDMUG_AT_STORMSTOUT_BREWERY_SIDE then
        return (complete[30076] or (questLog[30076] and questLog[30076].isComplete == 1)) and not (complete[30078] or (questLog[30078] and questLog[30078].isComplete == 1)) or false
    end

    if phase == phases.LI_LI_AT_STORMSTOUT_BREWERY_SIDE then
        return (complete[30077] or (questLog[30077] and questLog[30077].isComplete == 1)) and not (complete[30078] or (questLog[30078] and questLog[30078].isComplete == 1)) or false
    end

    if phase == phases.CHEN_AT_STORMSTOUT_BREWERY_CLEANED_HOUSE then
        return (complete[30078] or (questLog[30078] and questLog[30078].isComplete == 1)) or false
    end

    if phase == phases.FARMER_YOON_HOUSE then
        return questLog[30252] or false
    end

    if phase == phases.FARMER_YOON_FARM then
        return complete[30252] and not complete[32682] or false
    end

    if phase == phases.FARMER_YOON_MARKET then
        return complete[32682] or false
    end

    if phase == phases.KANG_AT_THE_INCURSION_OUTSIDE then
        return (questLog[30274] and questLog[30274].isComplete == 0) or false
    end

    if phase == phases.KANG_AT_THE_INCURSION_INSIDE then
        return complete[30274] and not complete[30363] or false
    end

    if phase == phases.VAELDRIN_AT_THE_INCURSION then
        return not complete[30363] or false
    end

    if phase == phases.VAELDRIN_SHATTERED_CONVOY then
        return complete[30363] and not (complete[30359] or (questLog[30359] and questLog[30359].isComplete == 1))or false
    end

    if phase == phases.VAELDRIN_AT_SENTINEL_BASECAMP then
        return complete[30359] or (questLog[30359] and questLog[30359].isComplete == 1) or false
    end

    if phase == phases.MUDMUG_AT_STONEPLOW then
        return complete[30360] or complete[30376] or false
    end

    if phase == phases.BO_TSULAN_YAUNGOL_ROAD then
        return (complete[30506] or complete[30507] or complete[30508]) and (not complete[30512]) or false
    end

    if phase == phases.BO_TSULAN_WESTWIND_REST_1 then
        return complete[30512] and (not complete[30514]) or false
    end

    if phase == phases.BO_TSULAN_WESTWIND_REST_2 then
        return complete[30514] or false
    end

    if phase == phases.GORAI_EDGE then
        return not complete[30496] and not (questLog[30496] and questLog[30496].isComplete == 1) or false
    end

    if phase == phases.GORAI_LIGHTPOLE then
        return (complete[30496] or (questLog[30496] and questLog[30496].isComplete == 1)) and not (complete[30480] or (questLog[30480] and questLog[30480].isComplete == 1)) or false
    end

    if phase == phases.GORAI_RITUAL then
        return complete[30480] or (questLog[30480] and questLog[30480].isComplete == 1) or false
    end

    if phase == phases.GOLDEN_LOTUS_RUINS_PEACE then
        return complete[31240] or complete[31248] or complete[31294] or complete[31296] or questLog[31240] or questLog[31248] or questLog[31294] or questLog[31296] or false
    end

    if phase == phases.GOLDEN_LOTUS_RUINS_ATTACK then
        return complete[31244] or complete[31295] or questLog[31244] or questLog[31295] or false
    end

    if phase == phases.BAN_BEARHEART_AT_WINTERS_BLOSSOM then
        return not complete[30715] or false
    end

    if phase == phases.BAN_BEARHEART_ON_THE_GROUND then
        return complete[30715] and (not questLog[30993] or questLog[30993].isComplete == 0) and not complete[30993] or false
    end

    if phase == phases.BAN_BEARHEART_AT_SHADO_PAN_MONASTERY then
        return complete[30993] or (questLog[30993] and questLog[30993].isComplete == 1) or false
    end

    if phase == phases.SUNA_SILENTSTRIKE_AT_THE_WALL then
        return not (complete[30994] or (questLog[30994] and questLog[30994].isComplete == 1)) or false
    end

    if phase == phases.SUNA_SILENTSTRIKE_ON_THE_GROUND then
        return complete[30994] or (questLog[30994] and questLog[30994].isComplete == 1) or false
    end

    if phase == phases.BROTHER_RABBITSFOOT_AT_BURLAP_WAYSTATION then
        return (complete[30602] or (questLog[30602] and questLog[30602].isComplete == 1)) and not (complete[30610] or (questLog[30610] and questLog[30610].isComplete == 1)) or false
    end

    if phase == phases.CHO_SEEKERS_POINT_1 then
        return not (complete[30829] or (questLog[30829] and questLog[30829].isComplete == 1)) or false
    end

    if phase == phases.CHO_SEEKERS_POINT_2 then
        return complete[30829] or (questLog[30829] and questLog[30829].isComplete == 1) or false
    end

    if phase == phases.BURBERRY_IN_CAVE then
        return not complete[30746] or false
    end

    if phase == phases.BURBERRY_AT_CAMP then
        return complete[30746] or false
    end

    if phase == phases.TARAN_ZHU_WATCHPOST_1 then
        return not complete[30979] or false
    end

    if phase == phases.TARAN_ZHU_WATCHPOST_2 then
        return complete[30979] or false
    end

    if phase == phases.TAI_HO_AT_GARRISON then
        return not (complete[30924] or questLog[30924]) or false
    end

    if phase == phases.TAI_HO_IN_CATACOMBS then
        return complete[30924] or questLog[30924] or false
    end

    if phase == phases.KAZTIK_AT_THE_BRINY_MUCK then
        return not (questLog[31092] and questLog[31359]) and not complete[31092] and not complete[31359] or false
    end

    if phase == phases.KAZTIK_AT_KLAXXIVESS then
        return (questLog[31092] and questLog[31359]) or complete[31092] or complete[31359] or false
    end

    if phase == phases.XARIL_AT_HEART_OF_FEAR then
        return not (complete[31211] or (questLog[31211] and questLog[31211].isComplete == 1)) or false
    end

    if phase == phases.XARIL_AT_KLAXXIVESS then
        return complete[31211] or (questLog[31211] and questLog[31211].isComplete == 1) or false
    end

    if phase == phases.RAIGONN_ALIVE then
        return not (complete[31364] or (questLog[31364] and questLog[31364].isComplete == 1)) or false
    end

    if phase == phases.RAIGONN_DEAD then
        return complete[31364] or (questLog[31364] and questLog[31364].isComplete == 1) or false
    end

    if phase == phases.BOOF_IN_VEILED_STAIR then
        return not (complete[31254] or complete[31255] or (questLog[31254] and questLog[31254].isComplete == 1) or (questLog[31255] and questLog[31255].isComplete == 1)) or false
    end

    if phase == phases.BOOF_AT_BINAN_VILLAGE then
        return complete[31254] or complete[31255] or (questLog[31254] and questLog[31254].isComplete == 1) or (questLog[31255] and questLog[31255].isComplete == 1) or false
    end

    if phase == phases.GOLDEN_LOTUS_GARRISON_ACTIVE then
        return complete[31247] or complete[31297] or complete[31250] or complete[30385] or questLog[31247] or questLog[31297] or questLog[31250] or questLog[30385] or false
    end

    if phase == phases.GOLDEN_LOTUS_LEVEN_AT_PAGODA then
        return not (complete[31244] or complete[31295] or questLog[31244] or questLog[31295] or complete[31247] or complete[31297] or complete[31250] or complete[30385] or questLog[31247] or questLog[31297] or questLog[31250] or questLog[30385]) or false
    end

    if phase == phases.SHIAO_AND_KO_ON_YAUNGOL_ADVANCE then
        return (complete[30509] or complete[30510] or complete[30511]) and (not complete[30513]) or false
    end

    if phase == phases.SHIAO_AND_KO_IN_FRONT_OF_CAMP then
        return complete[30513] and (not complete[30515]) or false
    end

    if phase == phases.SHIAO_AND_KO_IN_CAMP then
        return complete[30515] or false
    end

    if phase == phases.GENERAL_NAZGRIM_IN_TENT then
        return (not complete[30655]) and ((not questLog[30655]) or questLog[30655].isComplete == 0) or false
    end

    if phase == phases.GENERAL_NAZGRIM_OUTSIDE_TENT then
        return complete[30655] or (questLog[30655] and questLog[30655].isComplete == 1) or false
    end

    if phase == phases.GENERAL_NAZGRIM_NEAR_SPEARS then
        return not complete[29824] or false
    end

    if phase == phases.GENERAL_NAZGRIM_NEAR_ANDUINN then
        return complete[29824] or false
    end

    if phase == phases.ADMIRAL_TAYLOR_IN_TENT then
        return (not complete[30650]) and ((not questLog[30650]) or questLog[30650].isComplete == 0) or false
    end

    if phase == phases.ADMIRAL_TAYLOR_OUTSIDE_TENT then
        return complete[30650] or (questLog[30650] and questLog[30650].isComplete == 1) or false
    end

    if phase == phases.THRALL_VALLEY_OF_TRIALS then
        return not (complete[32320] or (questLog[32320] and questLog[32320].isComplete == 1)) or false
    end

    if phase == phases.THRALL_ECHO_ISLES_1 then
        return (complete[32320] or (questLog[32320] and questLog[32320].isComplete == 1)) and not (complete[32372] or (questLog[32372] and questLog[32372].isComplete == 1)) or false
    end

    if phase == phases.THRALL_ECHO_ISLES_2 then
        return complete[32372] or (questLog[32372] and questLog[32372].isComplete == 1) or false
    end

    if phase == phases.SARANNHA_AT_MOGUJIA then
        return not complete[32371] or false
    end

    if phase == phases.SARANNHA_AT_RUINS_OF_KORUNE then
        return complete[32371] or false
    end

    if phase == phases.JAINA_IN_DARNASSUS then
        return not (complete[32460] or (questLog[32460] and questLog[32460].isComplete == 1)) or false
    end

    if phase == phases.JAINA_IN_TELDRASSIL then
        return complete[32460] or (questLog[32460] and questLog[32460].isComplete == 1) or false
    end

    if phase == phases.ANDUIN_ENTRANCE_OF_TOMB then
        return not complete[32321] or false
    end

    if phase == phases.ANDUIN_AT_LIONS_LANDING then
        return complete[32321] or false
    end

    if phase == phases.GARROSH_TOP_FLOOR_WEST then
        return not complete[32384] or false
    end

    if phase == phases.GARROSH_TOP_FLOOR_EAST then
        return complete[32384] or false
    end

    if phase == phases.BAINE_IN_SHRINE then
        return not complete[32330] or false
    end

    if phase == phases.BAINE_AT_GARROSHAR_ADVANCE then
        return complete[32330] or false
    end

    return false
end

_Phasing.CheckQuestLog = function(questLog)
    return (
        questLog[13847] or
        questLog[13851] or
        questLog[13852] or
        questLog[13854] or
        questLog[13855] or
        questLog[13856] or
        questLog[13857] or
        questLog[13858] or
        questLog[13859] or
        questLog[13860] or
        questLog[13861] or
        questLog[13862] or
        questLog[13863] or
        questLog[13864] or
        questLog[25560]
    ) and true or false
end

_Phasing.LostIsles = function(phase, complete)
    if phase == phases.LOST_ISLES_CHAPTER_1 and (not complete[14303]) and (not complete[14240]) then
        return complete[14126]
    end

    if phase == phases.LOST_ISLES_CHAPTER_2 and (not complete[14240]) then
        return complete[14303]
    end

    if phase == phases.LOST_ISLES_CHAPTER_3 and (not complete[14242]) then
        return complete[14240]
    end

    if phase == phases.LOST_ISLES_CHAPTER_4 and (not complete[14244]) then
        return complete[14242]
    end

    if phase == phases.LOST_ISLES_CHAPTER_5 and (not complete[24868]) then
        return complete[14244]
    end

    if phase == phases.LOST_ISLES_CHAPTER_6 and (not complete[24925]) and (not complete[24929]) then
        return complete[24868]
    end

    if phase == phases.LOST_ISLES_CHAPTER_7 and (not complete[24958]) then
        return complete[24925] and complete[24929]
    end

    if phase == phases.LOST_ISLES_CHAPTER_8 and (not complete[25125]) then
        return complete[24958]
    end

    if phase == phases.LOST_ISLES_CHAPTER_9 and (not complete[25251]) then
        return complete[25125]
    end

    if phase == phases.LOST_ISLES_CHAPTER_10 then
        return complete[25251]
    end

    return false
end

_Phasing.Gilneas = function(phase, complete)
    if phase == phases.LOST_ISLES_CHAPTER_1 and (not complete[14159]) then
        return complete[14078]
    end

    if phase == phases.LOST_ISLES_CHAPTER_2 and (not complete[14293]) then
        return complete[14159]
    end

    if phase == phases.LOST_ISLES_CHAPTER_3 and (not complete[14221]) then
        return complete[14293]
    end

    if phase == phases.LOST_ISLES_CHAPTER_4 and (not complete[14375]) then
        return complete[14221]
    end

    if phase == phases.GILNEAS_CHAPTER_5 and (not complete[14321]) then
        return complete[14375]
    end

    if phase == phases.GILNEAS_CHAPTER_6 and (not complete[14386]) then
        return complete[14321]
    end

    if phase == phases.GILNEAS_CHAPTER_7 and (not complete[14402]) and (not complete[14405]) and (not complete[14463]) then
        return complete[14386]
    end

    if phase == phases.GILNEAS_CHAPTER_8 and (not complete[14467]) then
        return complete[14402] or complete[14405] or complete[14463]
    end

    if phase == phases.GILNEAS_CHAPTER_9 and (not complete[24676]) then
        return complete[14467]
    end

    if phase == phases.GILNEAS_CHAPTER_10 and (not complete[24902]) then
        return complete[24676]
    end

    if phase == phases.GILNEAS_CHAPTER_11 and (not complete[24679]) then
        return complete[24902]
    end

    if phase == phases.GILNEAS_CHAPTER_12 then
        return complete[24679]
    end

    return false
end

_Phasing.TempleOfEarth = function(phase, complete)
    if phase == phases.THE_STONE_MARCH and (not complete[26829]) and (not complete[26831]) and (not complete[26832]) then
        return complete[26827]
    end

    if phase == phases.TEMPLE_OF_EARTH_CHAPTER_1 and (not complete[26875]) then
        return complete[26829] and complete[26831] and complete[26832]
    end

    if phase == phases.TEMPLE_OF_EARTH_CHAPTER_2 and (not complete[26971]) then
        return complete[26875]
    end

    if phase == phases.TEMPLE_OF_EARTH_CHAPTER_3 and (not complete[26709]) then
        return complete[26971]
    end

    return false
end

_Phasing.DragonmawPort = function(phase, complete)
    if phase == phases.DRAGONMAW_PORT_CHAPTER_1 and (not complete[26608]) then
        return true
    end

    if phase == phases.DRAGONMAW_PORT_CHAPTER_2 and (not complete[26622]) then
        return complete[26608]
    end

    if phase == phases.DRAGONMAW_PORT_CHAPTER_3 then
        return complete[26622] and (not complete[26830])
    end

    return false
end

_Phasing.Kezan = function(phase, complete)
    local isChapter5Available = complete[14115]
    local isChapter6Available = complete[14121] and complete[14122] and complete[14123] and complete[14124]
    local isChapter7Available = complete[14125]
    if phase == phases.KEZAN_CHAPTER_1 and (isChapter5Available or isChapter6Available or isChapter7Available) then
        return false
    elseif phase == phases.KEZAN_CHAPTER_1 then
        return true
    end
    if phase == phases.KEZAN_CHAPTER_5 and isChapter5Available and (not (isChapter6Available or isChapter7Available)) then
        return true
    end
    if phase == phases.KEZAN_CHAPTER_6 and isChapter6Available and (not isChapter7Available) then
        return true
    end
    if phase == phases.KEZAN_CHAPTER_7 and isChapter7Available then
        return true
    end

    return false
end

return Phasing
