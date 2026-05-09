---@meta _
---@class TabardModelBase : PlayerModel
local TabardModelBase = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_TabardModelBase_CanSaveTabardNow)
---@return boolean canSave
function TabardModelBase:CanSaveTabardNow() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_TabardModelBase_CycleVariation)
---@param variationIndex number
---@param delta number
function TabardModelBase:CycleVariation(variationIndex, delta) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_TabardModelBase_GetLowerEmblemTexture)
---@param texture SimpleTexture
function TabardModelBase:GetLowerEmblemTexture(texture) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_TabardModelBase_GetUpperEmblemTexture)
---@param texture SimpleTexture
function TabardModelBase:GetUpperEmblemTexture(texture) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_TabardModelBase_InitializeTabardColors)
function TabardModelBase:InitializeTabardColors() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_TabardModelBase_IsGuildTabard)
---@return boolean isGuildTabard
function TabardModelBase:IsGuildTabard() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_TabardModelBase_Save)
function TabardModelBase:Save() end
