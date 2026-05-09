---@meta _
C_PetBattles = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PetBattles.GetBreedQuality)
---@param petOwner Enum.BattlePetOwner
---@param slot number
---@return Enum.BattlePetBreedQuality quality
function C_PetBattles.GetBreedQuality(petOwner, slot) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PetBattles.GetIcon)
---@param petOwner Enum.BattlePetOwner
---@param slot number
---@return fileID iconFileID
function C_PetBattles.GetIcon(petOwner, slot) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PetBattles.GetName)
---@param petOwner Enum.BattlePetOwner
---@param slot number
---@return string customName
---@return string speciesName
function C_PetBattles.GetName(petOwner, slot) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PetBattles.IsPlayerNPC)
---@return boolean isPlayerNPC
function C_PetBattles.IsPlayerNPC() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_PetBattles.IsWildBattle)
---@return boolean isWildBattle
function C_PetBattles.IsWildBattle() end
