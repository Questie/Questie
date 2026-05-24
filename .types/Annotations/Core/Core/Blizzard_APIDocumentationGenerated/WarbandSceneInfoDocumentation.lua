---@meta _
C_WarbandScene = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_WarbandScene.GetRandomEntryID)
---@return number warbandSceneID
function C_WarbandScene.GetRandomEntryID() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_WarbandScene.GetWarbandSceneEntry)
---@param warbandSceneID number
---@return WarbandSceneEntry warbandSceneEntry
function C_WarbandScene.GetWarbandSceneEntry(warbandSceneID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_WarbandScene.HasWarbandScene)
---@param warbandSceneID number
---@return boolean owned
function C_WarbandScene.HasWarbandScene(warbandSceneID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_WarbandScene.IsFavorite)
---@param warbandSceneID number
---@return boolean favorite
function C_WarbandScene.IsFavorite(warbandSceneID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_WarbandScene.SearchWarbandSceneEntries)
---@param searchParams WarbandSceneSearchInfo
---@return number[] matchingEntryIDs
function C_WarbandScene.SearchWarbandSceneEntries(searchParams) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_WarbandScene.SetFavorite)
---@param warbandSceneID number
---@param favorite boolean
function C_WarbandScene.SetFavorite(warbandSceneID, favorite) end

---@class WarbandSceneEntry
---@field warbandSceneID number? Default = 0
---@field name string
---@field description string
---@field source string
---@field quality number
---@field textureKit textureKit
---@field isFavorite boolean? Default = false
---@field hasFanfare boolean? Default = false
---@field sourceType number? Default = 0

---@class WarbandSceneSearchInfo
---@field ownedOnly boolean? Default = false
---@field favoritesOnly boolean? Default = false
