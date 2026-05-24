---@meta _
C_TooltipComparison = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TooltipComparison.GetItemComparisonDelta)
---@param comparisonItem TooltipComparisonItem
---@param equippedItem TooltipComparisonItem
---@param pairedItem? TooltipComparisonItem
---@param addPairedStats? boolean
---@return string[] lines
function C_TooltipComparison.GetItemComparisonDelta(comparisonItem, equippedItem, pairedItem, addPairedStats) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TooltipComparison.GetItemComparisonInfo)
---@param comparisonItem TooltipComparisonItem
---@return TooltipItemComparisonInfo info
function C_TooltipComparison.GetItemComparisonInfo(comparisonItem) end

---@class TooltipItemComparisonInfo
---@field method Enum.TooltipComparisonMethod? Default = Single
---@field item TooltipComparisonItem
---@field additionalItems TooltipComparisonItem[]
