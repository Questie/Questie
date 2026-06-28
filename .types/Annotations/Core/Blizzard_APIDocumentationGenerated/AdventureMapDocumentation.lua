---@meta _
C_AdventureMap = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AdventureMap.GetAdventureMapTextureKit)
---@return textureKit adventureMapTextureKit
function C_AdventureMap.GetAdventureMapTextureKit() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AdventureMap.GetQuestPortraitInfo)
---@param questID number
---@return AdventureMapQuestPortraitInfo info
function C_AdventureMap.GetQuestPortraitInfo(questID) end

---@class AdventureMapQuestPortraitInfo
---@field portraitDisplayID number
---@field mountPortraitDisplayID number
---@field name string
---@field text string
---@field modelSceneID number?
