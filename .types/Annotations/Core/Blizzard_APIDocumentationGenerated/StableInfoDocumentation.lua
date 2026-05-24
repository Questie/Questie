---@meta _
C_StableInfo = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_StableInfo.ClosePetStables)
function C_StableInfo.ClosePetStables() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_StableInfo.GetActivePetList)
---@return PetInfo[] activePets
function C_StableInfo.GetActivePetList() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_StableInfo.GetAvailablePetSpecInfos)
---@return PetSpecInfo[] petSpecInfos
function C_StableInfo.GetAvailablePetSpecInfos() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_StableInfo.GetNumActivePets)
---@return number numActivePets
function C_StableInfo.GetNumActivePets() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_StableInfo.GetNumStablePets)
---@return number numStablePets
function C_StableInfo.GetNumStablePets() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_StableInfo.GetStablePetFoodTypes)
---@param index number
---@return string[] foodTypes
function C_StableInfo.GetStablePetFoodTypes(index) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_StableInfo.GetStablePetInfo)
---@param index number
---@return PetInfo? petInfo
function C_StableInfo.GetStablePetInfo(index) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_StableInfo.GetStabledPetList)
---@return PetInfo[] stabledPets
function C_StableInfo.GetStabledPetList() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_StableInfo.IsAtStableMaster)
---@return boolean isAtStableMaster
function C_StableInfo.IsAtStableMaster() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_StableInfo.IsPetFavorite)
---@param slot number
---@return boolean isFavorite
function C_StableInfo.IsPetFavorite(slot) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_StableInfo.PickupStablePet)
---@param index number
function C_StableInfo.PickupStablePet(index) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_StableInfo.SetPetFavorite)
---@param slot number
---@param isFavorite boolean
function C_StableInfo.SetPetFavorite(slot, isFavorite) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_StableInfo.SetPetSlot)
---@param index number
---@param slot number
function C_StableInfo.SetPetSlot(index, slot) end

---@class PetInfo
---@field slotID number
---@field icon fileID
---@field name string
---@field level number
---@field familyName string
---@field specialization string
---@field type string
---@field petAbilities number[]
---@field specAbilities number[]
---@field displayID number
---@field isFavorite boolean
---@field isExotic boolean
---@field uiModelSceneID number? Default = 718
---@field petNumber number
---@field creatureID number
---@field specID number

---@class PetSpecInfo
---@field specID number
---@field specIndex number
---@field specializationName string
