---@meta

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_GossipInfo.GetActiveQuests)
---@return GossipQuestUIInfo[]
function C_GossipInfo.GetActiveQuests() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_GossipInfo.GetAvailableQuests)
---@return GossipQuestUIInfo[]
function C_GossipInfo.GetAvailableQuests() end

---@class GossipQuestUIInfo
---@field title string
---@field questLevel number
---@field isTrivial boolean
---@field frequency number?
---@field repeatable boolean?
---@field isComplete boolean?
---@field isLegendary boolean
---@field isIgnored boolean
---@field questID number
---@field isImportant boolean
---@field isMeta boolean

---[Documentation](https://wowpedia.fandom.com/wiki/API_GetGossipAvailableQuests)
---@return string, number, boolean, number, boolean, boolean, boolean
function GetGossipAvailableQuests() end
