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

---@param key string @Townsfolk menu key, e.g. "Anvil"
---@param object Object|nil
---@return string
local function _GetTitle(key, object)
    if object and object.name then
        return Questie:Colorize(object.name, "white")
    end
    return Questie:Colorize(l10n(key), "white")
end

---@param key string @Townsfolk menu key, e.g. "Anvil"
function ProfessionStations.ShowAll(key)
    local station = ProfessionStations.stations[key]
    if not station then
        return
    end

    for _, objectID in ipairs(station.objectIds) do
        local object = QuestieDB:GetObject(objectID)
        QuestieMap:ShowObject(objectID, station.icon, 1.2, _GetTitle(key, object), {}, true, key)
    end
end

---@param key string @Townsfolk menu key, e.g. "Anvil"
function ProfessionStations.HideAll(key)
    local station = ProfessionStations.stations[key]
    if not station then
        return
    end

    for _, objectID in ipairs(station.objectIds) do
        QuestieMap:UnloadManualFrames(objectID, key)
    end
end

---@param profession number
---@return boolean
local function _KnowsProfession(profession)
    local hasProfession = QuestieProfessions:HasProfessionAndSkillLevel({profession, 1})
    return hasProfession == true
end

---@class ProfessionStation
---@field icon string
---@field objectIds ObjectId[] @Filled by SetStationObjects; objects without active spawns are skipped by QuestieMap:ShowObject
---@field isAvailable fun(): boolean @True when the player needs this station
---@type table<string, ProfessionStation>
ProfessionStations.stations = {
    ["Moonwell"] = {
        icon = QuestieLib.AddonPath.."Icons\\inv_fabric_moonrag_01.png",
        objectIds = {},
        isAvailable = function()
            return _KnowsProfession(QuestieProfessions.professionKeys.TAILORING)
        end,
    },
    ["Anvil"] = {
        icon = QuestieLib.AddonPath.."Icons\\inv_hammer_20.png",
        objectIds = {},
        isAvailable = function()
            local professionKeys = QuestieProfessions.professionKeys
            -- Blacksmiths and engineers need anvils in every expansion,
            -- jewelcrafters only start needing them in Cataclysm.
            return _KnowsProfession(professionKeys.BLACKSMITHING)
                or _KnowsProfession(professionKeys.ENGINEERING)
                or (Expansions.Current >= Expansions.Cata and _KnowsProfession(professionKeys.JEWELCRAFTING))
        end,
    },
    ["Forge"] = {
        icon = QuestieLib.AddonPath.."Icons\\spell_fire_flameblades.png",
        objectIds = {},
        isAvailable = function()
            local professionKeys = QuestieProfessions.professionKeys
            -- Miners need forges in every expansion, engineers and jewelcrafters
            -- only start needing them in TBC.
            return _KnowsProfession(professionKeys.MINING)
                or (Expansions.Current >= Expansions.Tbc and (
                    _KnowsProfession(professionKeys.ENGINEERING)
                    or _KnowsProfession(professionKeys.JEWELCRAFTING)
                ))
        end,
    },
    ["Alchemy Lab"] = {
        icon = QuestieLib.AddonPath.."Icons\\ui_profession_alchemy.png",
        objectIds = {},
        isAvailable = function()
            return Expansions.Current <= Expansions.Tbc
                and _KnowsProfession(QuestieProfessions.professionKeys.ALCHEMY)
        end,
    },
}

---Replaces each station's objects. Townsfolk calls this once per login with the objects
---QuestieDB marks with the matching service, so the stations carry no ID lists of their own.
---@param objectIdsByKey table<string, ObjectId[]> @Townsfolk menu key to object IDs
function ProfessionStations.SetStationObjects(objectIdsByKey)
    for key, station in pairs(ProfessionStations.stations) do
        station.objectIds = objectIdsByKey[key] or {}
    end
end

---@param key string @Townsfolk menu key, e.g. "Anvil"
---@return boolean
function ProfessionStations.IsStationAvailable(key)
    local station = ProfessionStations.stations[key]
    return station ~= nil and station.isAvailable()
end

---Hides every enabled station whose profession requirement the player no
---longer meets, e.g. after unlearning one of their professions, and disables
---its menu toggle so it stays off when the profession is learned again.
---@return boolean removed @True if any station category had to be hidden
function ProfessionStations.HideUnlearned()
    local removed = false
    local config = Questie.db.profile.townsfolkConfig
    for townsfolkKey in pairs(ProfessionStations.stations) do
        if config and config[townsfolkKey] and not ProfessionStations.IsStationAvailable(townsfolkKey) then
            ProfessionStations.HideAll(townsfolkKey)
            config[townsfolkKey] = false
            removed = true
        end
    end
    return removed
end
