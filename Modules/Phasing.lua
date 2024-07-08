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
}
Phasing.phases = phases

function Phasing.Initialize()
    playerFaction = UnitFactionGroup("player")
end

---@param phase number|nil @The phase belonging to a spawn of an NPC
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
        return (not complete[25966]) and (not complete[25755]) and (complete[26191] or complete[25750]) or false
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

    if phase == phases.VASHJIR_ERANUK_AT_CAVERN then
        return (not complete[25988]) or complete[26143] or false
    end

    if phase == phases.VASHJIR_ERANUK_AT_PROMONTORY_POINT then
        return (complete[25988] and (not complete[26143])) or false
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
        return complete[27509] and (not complete[27576]) or false
    end

    if phase == phases.TWILIGHT_CARAVAN_AMBUSH_ALLIANCE then
        return complete[27509] and (not complete[28101]) or false
    end

    if phase == phases.GRIM_BATOL_ATTACK_HORDE then
        return complete[28090] and complete[28091] or false
    end

    if phase == phases.GRIM_BATOL_ATTACK_ALLIANCE then
        return complete[28103] and complete[28104] or false
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
        return (not complete[28715]) and (not questLog[28715])
    end

    if phase == phases.ILTHALAINE_AT_ROAD then
        return (complete[28715] or questLog[28715] and true) or false
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
        return (not complete[12684])
    end

    if phase == phases.HAR_KOA_AT_ZIM_TORGA then
        return complete[12684] or false
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
        return complete[26441] or (not complete[26440]) or false
    end

    if phase == phases.PEBBLE_AT_CRYSTALS then
        return (complete[26440] and not complete[26441]) or (questLog[26440] and questLog[26440].isComplete == 1) or false
    end

    if phase == phases.TERRATH_AT_AEOSERA then
        return complete[26659] or (questLog[26659] and questLog[26659].isComplete == 1) or false
    end

    if phase == phases.NPCS_AT_THERAZANES_THRONE then
        return complete[26659] and complete[26584] and complete[26585] or false
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
