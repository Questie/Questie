---@meta _
C_ColorOverrides = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ColorOverrides.ClearColorOverrides)
function C_ColorOverrides.ClearColorOverrides() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ColorOverrides.GetColorForQuality)
---@param quality Enum.ItemQuality
---@return colorRGBA color
function C_ColorOverrides.GetColorForQuality(quality) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ColorOverrides.GetColorOverrideInfo)
---@param overrideType Enum.ColorOverride
---@return ColorOverrideInfo? overrideInfo
function C_ColorOverrides.GetColorOverrideInfo(overrideType) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ColorOverrides.GetDefaultColorForQuality)
---@param quality Enum.ItemQuality
---@return colorRGBA color
function C_ColorOverrides.GetDefaultColorForQuality(quality) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ColorOverrides.RemoveColorOverride)
---@param overrideType Enum.ColorOverride
function C_ColorOverrides.RemoveColorOverride(overrideType) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ColorOverrides.SetColorOverride)
---@param overrideType Enum.ColorOverride
---@param color colorRGBA
function C_ColorOverrides.SetColorOverride(overrideType, color) end

---@class ColorOverrideInfo
---@field overrideType Enum.ColorOverride
---@field overrideColor colorRGB
---@field overrideColorString string
