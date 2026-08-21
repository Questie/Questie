---@meta _
C_SpellDiminish = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_SpellDiminish.GetAllSpellDiminishCategories)
---@param ruleset? Enum.SpellDiminishRuleset
---@return SpellDiminishCategoryInfo[] categories
function C_SpellDiminish.GetAllSpellDiminishCategories(ruleset) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_SpellDiminish.GetSpellDiminishCategoryInfo)
---@param category Enum.SpellDiminishCategory
---@return SpellDiminishCategoryInfo? categoryInfo
function C_SpellDiminish.GetSpellDiminishCategoryInfo(category) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_SpellDiminish.IsSystemSupported)
---@return boolean isSystemSupported
function C_SpellDiminish.IsSystemSupported() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_SpellDiminish.ShouldTrackSpellDiminishCategory)
---@param category Enum.SpellDiminishCategory
---@param ruleset Enum.SpellDiminishRuleset
---@return boolean isTracked
function C_SpellDiminish.ShouldTrackSpellDiminishCategory(category, ruleset) end

---@class SpellDiminishCategoryInfo
---@field category Enum.SpellDiminishCategory
---@field name string
---@field icon fileID?

---@class SpellDiminishTrackerInfo
---@field category Enum.SpellDiminishCategory
---@field startTime number
---@field duration number
---@field showCountdown boolean
---@field isImmune boolean
