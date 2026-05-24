---@meta _
C_WorldLootObject = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_WorldLootObject.DoesSlotMatchInventoryType)
---@param slot number
---@param inventoryType Enum.InventoryType
---@return boolean matches
function C_WorldLootObject.DoesSlotMatchInventoryType(slot, inventoryType) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_WorldLootObject.GetWorldLootObjectDistanceSquared)
---@param unitToken UnitToken
---@return number? distanceSquared
function C_WorldLootObject.GetWorldLootObjectDistanceSquared(unitToken) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_WorldLootObject.GetWorldLootObjectInfo)
---@param unitToken UnitToken
---@return WorldLootObjectInfo info
function C_WorldLootObject.GetWorldLootObjectInfo(unitToken) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_WorldLootObject.GetWorldLootObjectInfoByGUID)
---@param objectGUID WOWGUID
---@return WorldLootObjectInfo info
function C_WorldLootObject.GetWorldLootObjectInfoByGUID(objectGUID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_WorldLootObject.IsWorldLootObject)
---@param unitToken UnitToken
---@return boolean isWorldLootObject
function C_WorldLootObject.IsWorldLootObject(unitToken) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_WorldLootObject.IsWorldLootObjectByGUID)
---@param guid WOWGUID
---@return boolean isWorldLootObject
function C_WorldLootObject.IsWorldLootObjectByGUID(guid) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_WorldLootObject.IsWorldLootObjectInRange)
---@param unitToken UnitToken
---@return boolean isWorldLootObjectInRange
function C_WorldLootObject.IsWorldLootObjectInRange(unitToken) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_WorldLootObject.OnWorldLootObjectClick)
---@param unitToken UnitToken
---@param isLeftClick boolean
function C_WorldLootObject.OnWorldLootObjectClick(unitToken, isLeftClick) end

---@class WorldLootObjectInfo
---@field inventoryType Enum.InventoryType
---@field atMaxQuality boolean
---@field isUpgrade boolean
