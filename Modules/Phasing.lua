---@class Phasing
local Phasing = QuestieLoader:CreateModule("Phasing")

local _Phasing = {}
local playerFaction

-- https://old.wow.tools/dbc/?dbc=phase&build=4.3.4.15595
local phases = {
    UNKNOWN = 169, -- Most Deepholm NPCs (and others) have this ID but are not phased
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

    local complete = Questie.db.char.complete

    -- We return "or false", to convert nil to false

    if (phase >= phases.LOST_ISLES_CHAPTER_1 and phase <= phases.LOST_ISLES_CHAPTER_3) or
        (phase >= phases.LOST_ISLES_CHAPTER_4 and phase <= phases.GILNEAS_CHAPTER_12) then
        if playerFaction == "Horde" then
            return _Phasing.LostIsles(phase, complete) or false
        else
            return _Phasing.Gilneas(phase, complete) or false
        end
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

    return false
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
