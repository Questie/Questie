---@meta _
C_CreatureInfo = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CreatureInfo.GetClassInfo)
---@param classID number
---@return ClassInfo? classInfo
function C_CreatureInfo.GetClassInfo(classID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CreatureInfo.GetCreatureFamilyIDs)
---@return number[] creatureFamilyIDs
function C_CreatureInfo.GetCreatureFamilyIDs() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CreatureInfo.GetCreatureFamilyInfo)
---@param creatureFamilyID number
---@return CreatureFamilyInfo? creatureFamilyInfo
function C_CreatureInfo.GetCreatureFamilyInfo(creatureFamilyID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CreatureInfo.GetCreatureTypeIDs)
---@return number[] creatureTypeIDs
function C_CreatureInfo.GetCreatureTypeIDs() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CreatureInfo.GetCreatureTypeInfo)
---@param creatureTypeID number
---@return CreatureTypeInfo? creatureTypeInfo
function C_CreatureInfo.GetCreatureTypeInfo(creatureTypeID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CreatureInfo.GetFactionInfo)
---@param raceID number
---@return FactionInfo? factionInfo
function C_CreatureInfo.GetFactionInfo(raceID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CreatureInfo.GetRaceInfo)
---@param raceID number
---@return RaceInfo? raceInfo
function C_CreatureInfo.GetRaceInfo(raceID) end

---@class ClassInfo
---@field className string
---@field classFile string
---@field classID number

---@class CreatureFamilyInfo
---@field id number
---@field name string
---@field iconFile fileID?

---@class CreatureTypeInfo
---@field id number
---@field name string

---@class FactionInfo
---@field name string
---@field groupTag string

---@class RaceInfo
---@field raceName string
---@field clientFileString string
---@field raceID number
