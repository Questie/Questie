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
---@type QuestieProfessions
local QuestieProfessions = QuestieLoader:ImportModule("QuestieProfessions")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")

-- Object IDs for profession workstations, generated from the object databases of all
-- expansions. Objects that have no spawns in the current expansion are skipped by
-- QuestieMap:ShowObject, so a single list per category covers every expansion.
---@type table<string, ObjectId[]>
ProfessionStations.data = {
    moonwell = {
        -- Specific-name Moonwells (Classic)
        19549, 19550, 19551, 19552, 20806, 148501, 174795, 175337,
        -- Moonglade (correction)
        400010,
        -- Generic Moonwells (Classic)
        177232, 177272, 177273, 177274, 177275, 177276, 177277, 177278, 177279, 177280, 177281,
        -- TBC Moonwells
        410021, 410022, 410023,
    },
    anvil = {
        -- Anvils (Classic)
        1744, 1748, 1752, 1796, 1897, 2010, 2014, 2572, 2574,
        2726, 2729, 3187, 3222, 4087, 4088, 4089, 17191, 19874,
        20689, 20739, 21678, 21701, 23302, 23303, 32570, 32571,
        32572, 32573, 32574, 32578, 32580, 32581, 32582, 32583,
        32584, 32585, 32590, 32591, 32592, 32593, 32594, 32595,
        32596, 32847, 32848, 32849, 32850, 32851, 32852, 34025,
        34026, 34027, 34028, 34029, 34030, 34031, 34032, 34033,
        34034, 34035, 34036, 34037, 34038, 38492, 38493, 38494,
        38495, 40303, 50468, 50830, 51702, 51703, 51704, 51705,
        51706, 51707, 51948, 61035, 61036, 77813, 92419, 92489,
        104555, 113753, 123244, 130666, 130667, 138316, 141839,
        141840, 142077, 144132, 146441, 147036, 147037, 147038,
        147039, 147040, 147041, 147042, 147043, 147044, 147045,
        147046, 147047, 147048, 147049, 147279, 147282, 147283,
        147284, 147786, 147787, 147792, 147793, 148956, 148957,
        148958, 148959, 152032, 152033, 152041, 152046, 153240,
        153460, 161489, 169966, 169968, 171713, 171714, 171715,
        172911, 173065, 173066, 173094, 175078, 175145, 175383,
        175743, 175744, 175852, 176508, 176894, 178685, 179391,
        179392, 179393, 179394, 179395, 179396, 179397, 179862,
        179864, 179887, 180914, 181131, 181234, 181596, 181715,
        181885, 181989, 182118, 182269, 182315, 182316, 182317,
        182862, 182863, 182967, 182968, 182969, 182970, 182971,
        182972, 182973, 183031, 183034, 183120, 183149, 183346,
        183348, 183483, 183761, 184004, 184285, 184313, 184558,
        184559, 184616, 184686, 186137, 186142, 186232, 186631,
        -- Anvils (TBC)
        182055, 182279, 182861, 183218, 183409, 183783, 183793,
        183795, 183878, 185602, 186140, 187111,
        -- Anvils (Wotlk)
        186434, 186485, 186557, 186651, 186652, 187258, 187259,
        187387, 188249, 188258, 188357, 188397, 188453, 188606,
        188622, 188623, 188652, 188683, 188684, 190456, 190496,
        190525, 190766, 191001, 191002, 191003, 191004, 191238,
        191503, 191504, 191506, 191507, 191635, 191636, 191637,
        191638, 191639, 191640, 192019, 192021, 192022, 192063,
        192582, 192584, 192628, 192629, 192830, 192832, 193125,
        194127, 194488,
        -- Anvils (Cata)
        194778, 194802, 195108, 196880, 201293, 201392, 201415,
        201416, 201867, 202085, 202115, 202123, 202590, 202600,
        202605, 202622, 202976, 203042, 203145, 203290, 203376,
        203759, 204118, 204121, 204124, 204125, 204131, 204162,
        204216, 204224, 204231, 204235, 204251, 204268, 204413,
        204452, 204460, 204677, 204691, 204814, 204866, 204867,
        204949, 204980, 204983, 204994, 204995, 204997, 204998,
        205005, 205173, 205174, 205506, 205525, 205652, 205653,
        205654, 205655, 205910, 205918, 206041, 206690, 206738,
        206862, 206864, 207081, 207085, 207211, 207213, 207583,
        207584, 207586, 207587, 207598, 207599, 207703, 207706,
        208209, 208257, 208260, 208270, 208299, 209818, 209820,
        209859, 209869, 210059,
        -- Anvils (MoP)
        209918, 210939, 211171, 211495, 211607, 211608, 211609,
        211643, 212287, 212441, 212447, 212649, 212652, 212773,
        214894, 215042, 215047, 215069, 215070, 215072, 215075,
        215076, 215079, 215083, 215181, 215183, 215184, 215349,
        215350, 215461, 216254, 216264,
    },
    forge = {
        -- Forge (Classic)
        1685, 1743, 1745, 1749, 1797, 1896, 2015, 2573, 2575,
        2727, 2728, 3223, 4090, 17190, 19902, 20738, 20986,
        21631, 21679, 23304, 23305, 24745, 24746, 34571, 34572,
        38491, 50831, 50983, 50984, 50985, 51949, 52175, 52176,
        56897, 92490, 113754, 130668, 138317, 141838, 141841,
        142078, 144133, 147285, 148960, 152034, 152042, 152045,
        153459, 161487, 169969, 171716, 171717, 173063, 173064,
        173095, 174045, 175144, 175851, 176509, 176895, 178684,
        179844, 179863, 179886, 179924, 180913, 181130, 181716,
        181884, 181990, 182056, 182117, 182270, 182278, 182860,
        183121, 183148, 183345, 183347, 183484, 183818, 184286,
        184617, 184687, 186138, 186141, 186231, 186630,
        -- Forge (TBC)
        183408, 183757, 183758, 183759, 183760, 183782, 184146,
        184922, 184923, 186139, 187112,
        -- Forge (Wotlk)
        186433, 186486, 186556, 186653, 186654, 187256, 187388,
        188250, 188257, 188354, 188356, 188396, 188452, 188607,
        188624, 188651, 188683, 190457, 190495, 190524, 190765,
        191237, 191287, 191288, 191346, 191505, 191508, 192020,
        192062, 192572, 192573, 192583, 192831, 193126, 194128,
        194468, 194487, 202391, 202392, 202393, 202394,
        -- Forge (Cata)
        194777, 195107, 196879, 201393, 201417, 201418, 201419,
        201420, 201696, 201866, 202122, 202471, 202601, 202603,
        202621, 202977, 203146, 203291, 203377, 203758, 204119,
        204122, 204132, 204161, 204217, 204223, 204230, 204234,
        204250, 204269, 204412, 204438, 204451, 204459, 204583,
        204686, 204687, 204690, 204868, 204870, 204950, 204981,
        204984, 204993, 204996, 205009, 205507, 205524, 205656,
        206558, 206559, 206560, 206691, 206739, 206861, 206863,
        207080, 207084, 207212, 207585, 207588, 207704, 207705,
        208259, 208261, 208269, 208312, 208805, 209819, 209858,
        209867, 209868, 210058,
        -- Forge (MoP)
        209919, 210940, 211170, 211496, 212286, 212442, 212448,
        212650, 212651, 212774, 214644, 214893, 215045, 215046,
        215068, 215071, 215073, 215074, 215077, 215078, 215084,
        215182, 215348, 215460, 216255, 216265,
    },
    alchemyLab = {
        -- Alchemy Lab (Classic)
        177387, 180631, 180632, 187115,
        -- Alchemy Lab (TBC)
        183848, 183849,
        -- Alchemy Lab (Wotlk)
        191540, 191541, 194466,
    },
}

local _icons = {
    moonwell = "Interface\\Icons\\inv_fabric_moonrag_01.blp",
    anvil = QuestieLib.AddonPath.."Icons\\inv_hammer_20.png",
    forge = QuestieLib.AddonPath.."Icons\\spell_fire_flameblades.png",
    alchemyLab = QuestieLib.AddonPath.."Icons\\ui_profession_alchemy.png",
}

local _titles = {
    moonwell = "Moonwell",
    anvil = "Anvil",
    forge = "Forge",
    alchemyLab = "Alchemy Lab",
}

---@param category "moonwell"|"anvil"|"forge"|"alchemyLab"
---@param object Object|nil
---@return string
local function _GetTitle(category, object)
    if object and object.name then
        return Questie:Colorize(object.name, "white")
    end
    return Questie:Colorize(l10n(_titles[category]), "white")
end

---@param category "moonwell"|"anvil"|"forge"|"alchemyLab"
local function _GetActiveData(category)
    local data = {}
    for _, objectId in ipairs(ProfessionStations.data[category]) do
        data[objectId] = true
    end
    return data
end

---@param category "moonwell"|"anvil"|"forge"|"alchemyLab"
function ProfessionStations.ShowAll(category)
    local icon = _icons[category]

    for objectID in pairs(_GetActiveData(category)) do
        local object = QuestieDB:GetObject(objectID)
        if object and object.spawns then
            QuestieMap:ShowObject(objectID, icon, 1.2, _GetTitle(category, object), {}, true, category)
        end
    end
end

---@param category "moonwell"|"anvil"|"forge"|"alchemyLab"
function ProfessionStations.HideAll(category)
    for objectID in pairs(_GetActiveData(category)) do
        QuestieMap:UnloadManualFrames(objectID, category)
    end
end

---@param profession number
---@return boolean
local function _KnowsProfession(profession)
    local hasProfession = QuestieProfessions:HasProfessionAndSkillLevel({profession, 1})
    return hasProfession == true
end

local _stationTownsfolkKeys = {
    "Moonwell",
    "Anvil",
    "Forge",
    "Alchemy Lab",
}

---Whether the player meets the expansion and profession requirements to see
---the station belonging to the given townsfolk menu entry.
---@param townsfolkKey string
---@return boolean
function ProfessionStations.IsStationAvailable(townsfolkKey)
    local professionKeys = QuestieProfessions.professionKeys

    if townsfolkKey == "Moonwell" then
        return _KnowsProfession(professionKeys.TAILORING)
    elseif townsfolkKey == "Anvil" then
        -- Blacksmiths and engineers need anvils in every expansion,
        -- jewelcrafters only start needing them in Cataclysm
        if _KnowsProfession(professionKeys.BLACKSMITHING) or _KnowsProfession(professionKeys.ENGINEERING) then
            return true
        end
        if Expansions.Current < Expansions.Cata then
            return false
        end
        return _KnowsProfession(professionKeys.JEWELCRAFTING)
    elseif townsfolkKey == "Forge" then
        -- Miners need forges in every expansion, engineers and jewelcrafters
        -- only start needing them in TBC
        if _KnowsProfession(professionKeys.MINING) then
            return true
        end
        if Expansions.Current < Expansions.Tbc then
            return false
        end
        return _KnowsProfession(professionKeys.ENGINEERING) or _KnowsProfession(professionKeys.JEWELCRAFTING)
    elseif townsfolkKey == "Alchemy Lab" then
        -- Alchemy labs are only required up to and including TBC
        if Expansions.Current > Expansions.Tbc then
            return false
        end
        return _KnowsProfession(professionKeys.ALCHEMY)
    end

    return false
end

---Returns the townsfolk keys of all stations the player currently qualifies
---for, sorted alphabetically by their localized titles.
---@return string[]
function ProfessionStations.GetAvailableStationKeys()
    local available = {}
    for _, key in ipairs(_stationTownsfolkKeys) do
        if ProfessionStations.IsStationAvailable(key) then
            available[#available + 1] = key
        end
    end
    table.sort(available, function(a, b)
        return l10n(a) < l10n(b)
    end)
    return available
end

---Maps townsfolk menu keys to station categories.
---@type table<string, string>
ProfessionStations.stationCategories = {
    ["Moonwell"] = "moonwell",
    ["Anvil"] = "anvil",
    ["Forge"] = "forge",
    ["Alchemy Lab"] = "alchemyLab",
}

---Hides every enabled station whose profession requirement the player no
---longer meets, e.g. after unlearning one of their professions, and disables
---its menu toggle so it stays off when the profession is learned again.
---@return boolean removed @True if any station category had to be hidden
function ProfessionStations.HideUnlearned()
    local removed = false
    local config = Questie.db.profile.townsfolkConfig
    for townsfolkKey, category in pairs(ProfessionStations.stationCategories) do
        if config and config[townsfolkKey] and not ProfessionStations.IsStationAvailable(townsfolkKey) then
            ProfessionStations.HideAll(category)
            config[townsfolkKey] = false
            removed = true
        end
    end
    return removed
end
