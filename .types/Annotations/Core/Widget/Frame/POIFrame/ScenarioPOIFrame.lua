---@meta _
---[Documentation](https://warcraft.wiki.gg/wiki/UIOBJECT_ScenarioPOIFrame)
---@class ScenarioPOIFrame : Blob
local ScenarioPOIFrame = {}
---@class scenariopoiframe : ScenarioPOIFrame
---@class SCENARIOPOIFRAME : ScenarioPOIFrame

---[Documentation](https://warcraft.wiki.gg/wiki/API_ScenarioPOIFrame_GetScenarioTooltipText)
---@return string? tooltipText
function ScenarioPOIFrame:GetScenarioTooltipText() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ScenarioPOIFrame_UpdateMouseOverTooltip)
---@param x number
---@param y number
---@return boolean hasTooltip
function ScenarioPOIFrame:UpdateMouseOverTooltip(x, y) end
