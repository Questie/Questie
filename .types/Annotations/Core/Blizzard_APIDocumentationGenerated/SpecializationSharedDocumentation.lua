---@meta _
---[Documentation](https://warcraft.wiki.gg/wiki/API_GetSpecializationInfoForClassID)
---@param classID number
---@param index number
---@param gender? Enum.UnitSex
---@return number id
---@return string name
---@return string description
---@return fileID icon
---@return string role
---@return boolean recommended
---@return boolean allowedForBoost
---@return number? masterySpell1
---@return number? masterySpell2
function GetSpecializationInfoForClassID(classID, index, gender) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetSpecializationInfoForSpecID)
---@param specID number
---@param gender? Enum.UnitSex
---@return number id
---@return string name
---@return string description
---@return fileID icon
---@return string role
---@return boolean recommended
---@return boolean allowedForBoost
---@return number? masterySpell1
---@return number? masterySpell2
function GetSpecializationInfoForSpecID(specID, gender) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetSpecializationNameForSpecID)
---@param specID number
---@param gender? Enum.UnitSex
---@return string? name
function GetSpecializationNameForSpecID(specID, gender) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_HasLootSpecializations)
---@return boolean hasLootSpecializations
function HasLootSpecializations() end

---@class SpecializationInfoResult
---@field id number
---@field name string
---@field description string
---@field icon fileID
---@field role string
---@field recommended boolean
---@field allowedForBoost boolean
---@field masterySpell1 number?
---@field masterySpell2 number?
