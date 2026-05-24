---@meta _
C_CinematicList = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CinematicList.GetUICinematicList)
---@return UICinematic[] cinematics
function C_CinematicList.GetUICinematicList() end

---@class UICinematic
---@field expansion number
---@field movieIDs number[]
---@field buttonUpAtlas textureAtlas
---@field buttonDownAtlas textureAtlas
---@field title string?
---@field disableAutoPlay boolean
---@field orderID number
