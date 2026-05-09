---@meta _
C_ConsoleScriptCollection = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ConsoleScriptCollection.GetCollectionDataByID)
---@param collectionID number
---@return ConsoleScriptCollectionData? data
function C_ConsoleScriptCollection.GetCollectionDataByID(collectionID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ConsoleScriptCollection.GetCollectionDataByTag)
---@param collectionTag string
---@return ConsoleScriptCollectionData? data
function C_ConsoleScriptCollection.GetCollectionDataByTag(collectionTag) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ConsoleScriptCollection.GetElements)
---@param collectionID number
---@return ConsoleScriptCollectionElementData[] elementIDs
function C_ConsoleScriptCollection.GetElements(collectionID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ConsoleScriptCollection.GetScriptData)
---@param consoleScriptID number
---@return ConsoleScriptData data
function C_ConsoleScriptCollection.GetScriptData(consoleScriptID) end

---@class ConsoleScriptCollectionData
---@field ID number
---@field name string

---@class ConsoleScriptCollectionElementData
---@field collectionID number?
---@field consoleScriptID number?

---@class ConsoleScriptData
---@field ID number
---@field name string
---@field help string
---@field script string
---@field params string
---@field isLuaScript boolean

---@class ConsoleScriptParameter
---@field name string
---@field description string
