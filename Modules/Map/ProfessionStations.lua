---@class ProfessionStations
local ProfessionStations = QuestieLoader:CreateModule("ProfessionStations")

---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")
---@type QuestieMap
local QuestieMap = QuestieLoader:ImportModule("QuestieMap")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type Expansions
local Expansions = QuestieLoader:ImportModule("Expansions")

---@type table<number, boolean>
ProfessionStations.dataClassic = {
    -- Teldrassil Moonwells
    [19549] = true, -- Shadowglen moonwell
    [19550] = true, -- Starbreeze Village moonwell
    [19551] = true, -- Pools of Arlithrien moonwell
    [19552] = true, -- Oracle Glade moonwell
    -- Ashenvale Moonwells
    [20806] = true, -- Central Ashenvale moonwell
    -- Felwood Moonwells
    [148501] = true, -- Felwood cave moonwell
    -- Darkshore Moonwells
    [174795] = true, -- Auberdine (Main moonwell)
    [175337] = true, -- Auberdine (Secondary moonwell)
    -- Moonglade Moonwells
    [400010] = true, -- Moonglade moonwell
    -- Generic/Multi-location Moonwells
    [177232] = true,
    [177272] = true,
    [177273] = true,
    [177274] = true,
    [177275] = true,
    [177276] = true,
    [177277] = true,
    [177278] = true,
    [177279] = true,
    [177280] = true,
    [177281] = true,
}

---@type table<number, boolean>
ProfessionStations.dataTBC = {
    [410021] = true, -- Cenarion Thicket moonwell
    [410022] = true, -- Evergrove moonwell
    [410023] = true, -- Ghostlands moonwell
}

-- Object IDs for profession workstations, generated from the object databases of all
-- expansions. Objects that have no spawns in the current expansion are skipped by
-- QuestieMap:ShowObject, so a single list per category covers every expansion.
---@type table<string, ObjectId[]>
ProfessionStations.data = {
    anvil = {
        1744, 1748, 1752, 1796, 1897, 2010, 2014, 2572,
        2574, 2726, 2729, 3187, 3222, 4087, 4088, 4089,
        17191, 19874, 20689, 20739, 21678, 21701, 23302, 23303,
        32570, 32571, 32572, 32573, 32574, 32578, 32580, 32581,
        32582, 32583, 32584, 32585, 32590, 32591, 32592, 32593,
        32594, 32595, 32596, 32847, 32848, 32849, 32850, 32851,
        32852, 34025, 34026, 34027, 34028, 34029, 34030, 34031,
        34032, 34033, 34034, 34035, 34036, 34037, 34038, 38492,
        38493, 38494, 38495, 40303, 50468, 51702, 51703, 51704,
        51705, 51706, 51707, 51948, 61035, 61036, 77813, 92419,
        92489, 104555, 113753, 123244, 130666, 130667, 138316, 141839,
        141840, 142077, 144132, 146441, 147036, 147037, 147038, 147039,
        147040, 147041, 147042, 147043, 147044, 147045, 147046, 147047,
        147048, 147049, 147279, 147282, 147283, 147284, 147786, 147787,
        147792, 147793, 148956, 148957, 148958, 148959, 152032, 153460,
         161489, 169966, 169968, 171713, 171714, 171715, 172911, 173065, 173066, 173094,
        175078, 175145, 175383, 175743, 175744, 175852, 176508, 178685,
        179391, 179392, 179393, 179394, 179395, 179396, 179397, 179862,
        179864, 179887, 180914, 181131, 181596, 181715, 181885, 181989,
        182055, 182118, 182269, 182279, 182315, 182316, 182317, 182861,
        182862, 182863, 182967, 182968, 182969, 182970, 182971, 182972,
        182973, 183031, 183034, 183120, 183149, 183218, 183346, 183348,
        183409, 183483, 183761, 183783, 183793, 183795, 183878, 184004,
        184285, 184313, 184558, 184559, 184616, 184686, 185602, 186137,
        186140, 186142, 186232, 186434, 186485, 186557, 186631, 186651,
        186652, 187111, 187258, 187259, 187387, 188249, 188258, 188357,
        188397, 188453, 188606, 188622, 188623, 188652, 188683, 188684,
        190456, 190496, 190525, 190766, 191001, 191002, 191003, 191004,
        191238, 191503, 191504, 191506, 191507, 191635, 191636, 191637,
        191638, 191639, 191640, 192019, 192021, 192022, 192063, 192582,
        192584, 192628, 192629, 192830, 192832, 193125, 194127, 194488,
        194778, 194802, 195108, 196880, 201293, 201392, 201415, 201416,
        201867, 202085, 202115, 202123, 202590, 202600, 202605, 202622,
        202976, 203042, 203145, 203290, 203376, 203759, 204118, 204121,
        204124, 204125, 204131, 204162, 204216, 204224, 204231, 204235,
        204251, 204268, 204413, 204452, 204460, 204677, 204691, 204814,
        204866, 204867, 204949, 204980, 204983, 204994, 204995, 204997,
        204998, 205005, 205173, 205174, 205506, 205525, 205652, 205653,
        205654, 205655, 205910, 205918, 206041, 206690, 206738, 206862,
        206864, 207081, 207085, 207211, 207213, 207583, 207584, 207586,
        207587, 207598, 207599, 207703, 207706, 208209, 208257, 208260,
        208270, 208299, 209818, 209820, 209859, 209869, 209918, 210059,
        210939, 211171, 211495, 211607, 211608, 211609, 211643, 212287,
        212441, 212447, 212649, 212652, 212773, 214894, 215042, 215047,
        215069, 215070, 215072, 215075, 215076, 215079, 215083, 215181,
        215183, 215184, 215349, 215350, 215461, 216254, 216264,
    },
    forge = {
        1685, 1743, 1745, 1749, 1797, 1896, 2015, 2573,
        2575, 2727, 2728, 3223, 4090, 17190, 19902, 20738,
        20986, 21631, 21679, 23304, 23305, 24745, 24746, 34571,
        34572, 38491, 50831, 51949, 52175, 52176, 56897, 92490,
        113754, 130668, 138317, 141838, 141841, 142078, 144133, 147285,
        148960, 152034, 152042, 152045, 153459, 161487, 169969, 171716,
         171717, 173063, 173064, 173095, 174045, 175144, 175851, 176509, 176895,
        178684, 179844, 179863, 179886, 179924, 180913, 181130, 181716,
        181884, 181990, 182056, 182117, 182270, 182278, 182860, 183121,
        183148, 183345, 183347, 183408, 183484, 183757, 183758, 183759,
        183760, 183782, 183818, 184146, 184286, 184617, 184687, 184922,
        184923, 186138, 186139, 186141, 186231, 186433, 186486, 186556,
        186630, 186653, 186654, 187112, 187256, 187388, 188250, 188257,
        188354, 188356, 188396, 188452, 188607, 188624, 188651, 188683,
        190457, 190495, 190524, 190765, 191237, 191287, 191288, 191346,
        191505, 191508, 192020, 192062, 192572, 192573, 192583, 192831,
        193126, 194128, 194468, 194487, 194777, 195107, 196879, 201393,
        201417, 201418, 201419, 201420, 201696, 201866, 202122, 202391,
        202392, 202393, 202394, 202471, 202601, 202603, 202621, 202977,
        203146, 203291, 203377, 203758, 204119, 204122, 204132, 204161,
        204217, 204223, 204230, 204234, 204250, 204269, 204412, 204438,
        204451, 204459, 204583, 204686, 204687, 204690, 204868, 204870,
        204950, 204981, 204984, 204993, 204996, 205009, 205507, 205524,
        205656, 206558, 206559, 206560, 206691, 206739, 206861, 206863,
        207080, 207084, 207212, 207585, 207588, 207704, 207705, 208259,
        208261, 208269, 208312, 208805, 209819, 209858, 209867, 209868,
        209919, 210058, 210940, 211170, 211496, 212286, 212442, 212448,
        212650, 212651, 212774, 214644, 214893, 215045, 215046, 215068,
        215071, 215073, 215074, 215077, 215078, 215084, 215182, 215348,
        215460, 216255, 216265,
    },
    alchemyLab = {
        177387, 180631, 180632, 183848, 183849, 187115, 191540, 191541,
        194466,
    },
}

local _icons = {
    moonwell = "Interface\\Icons\\inv_fabric_moonrag_01.blp",
    anvil = "Interface\\Icons\\inv_hammer_20.blp",
    forge = "Interface\\Icons\\spell_fire_flameblades.blp",
    alchemyLab = "Interface\\Icons\\inv_alchemy_endlessflask_03.blp",
}

local _titles = {
    moonwell = "Moonwell",
    anvil = "Anvil",
    forge = "Forge",
    alchemyLab = "Alchemy Lab",
}

---@type table<string, boolean>
local _genericNames = {
    ["Moonwell"] = true,
    ["Anvil"] = true,
    ["Forge"] = true,
    ["Alchemy Lab"] = true,
}

---@param category "moonwell"|"anvil"|"forge"|"alchemyLab"
---@param object Object|nil
---@return boolean
local function _IsGeneric(category, object)
    return not object or not object.name or object.name == l10n(_titles[category]) or _genericNames[object.name]
end

---@param category "moonwell"|"anvil"|"forge"|"alchemyLab"
---@param object Object|nil
---@return string
local function _GetTitle(category, object)
    if not _IsGeneric(category, object) then
        return Questie:Colorize(object.name, "white")
    end
    return Questie:Colorize(l10n(_titles[category]), "white")
end

---@param category "moonwell"|"anvil"|"forge"|"alchemyLab"
local function _GetActiveData(category)
    local data = {}
    if category == "moonwell" then
        for objectId in pairs(ProfessionStations.dataClassic) do
            data[objectId] = true
        end
        if Expansions.Current >= Expansions.Tbc then
            for objectId in pairs(ProfessionStations.dataTBC) do
                data[objectId] = true
            end
        end
    else
        for _, objectId in ipairs(ProfessionStations.data[category]) do
            data[objectId] = true
        end
    end
    return data
end

---@param coordsA CoordPair
---@param coordsB CoordPair
---@param tolerance number
---@return boolean
local function _AreClose(coordsA, coordsB, tolerance)
    return math.abs(coordsA[1] - coordsB[1]) <= tolerance and math.abs(coordsA[2] - coordsB[2]) <= tolerance
end

---@param category "moonwell"|"anvil"|"forge"|"alchemyLab"
function ProfessionStations.ShowAll(category)
    local icon = _icons[category]
    local named = {}
    local generic = {}

    for objectID in pairs(_GetActiveData(category)) do
        local object = QuestieDB:GetObject(objectID)
        if object and object.spawns then
            local entry = {id = objectID, object = object}
            if not _IsGeneric(category, object) then
                named[#named + 1] = entry
            else
                generic[#generic + 1] = entry
            end
        end
    end

    -- Spawns are deduplicated by location, preferring stations with an actual name
    -- over generic ones, so no overlapping icons are drawn for the same spot.
    local taken = {} -- [zone] = CoordPair[]
    local function _IsTaken(zone, coords)
        for _, takenCoords in ipairs(taken[zone] or {}) do
            if _AreClose(takenCoords, coords, 0.05) then
                return true
            end
        end
        return false
    end

    for _, entry in ipairs(named) do
        QuestieMap:ShowObject(entry.id, icon, 1.2, _GetTitle(category, entry.object), nil, true, category)
        for zone, spawns in pairs(entry.object.spawns) do
            taken[zone] = taken[zone] or {}
            for _, coords in ipairs(spawns) do
                table.insert(taken[zone], coords)
            end
        end
    end

    for _, entry in ipairs(generic) do
        local filteredSpawns = {}
        for zone, spawns in pairs(entry.object.spawns) do
            for _, coords in ipairs(spawns) do
                if not _IsTaken(zone, coords) then
                    filteredSpawns[zone] = filteredSpawns[zone] or {}
                    table.insert(filteredSpawns[zone], coords)
                    taken[zone] = taken[zone] or {}
                    table.insert(taken[zone], coords)
                end
            end
        end
        if next(filteredSpawns) then
            QuestieMap:ShowObject(entry.id, icon, 1.2, _GetTitle(category, entry.object), nil, true, category, filteredSpawns)
        end
    end
end

---@param category "moonwell"|"anvil"|"forge"|"alchemyLab"
function ProfessionStations.HideAll(category)
    for objectID in pairs(_GetActiveData(category)) do
        QuestieMap:UnloadManualFrames(objectID, category)
    end
end
