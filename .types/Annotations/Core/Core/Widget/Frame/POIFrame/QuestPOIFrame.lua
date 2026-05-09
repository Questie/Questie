---@meta _
---[Documentation](https://warcraft.wiki.gg/wiki/UIOBJECT_QuestPOIFrame)
---@class QuestPOIFrame : Blob
local QuestPOIFrame = {}
---@class questpoiframe : QuestPOIFrame
---@class QUESTPOIFRAME : QuestPOIFrame

---[Documentation](https://warcraft.wiki.gg/wiki/API_QuestPOIFrame_GetNumTooltips)
---@return number numObjectives
function QuestPOIFrame:GetNumTooltips() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_QuestPOIFrame_GetTooltipIndex)
---@param index number
---@return number objectiveIndex
function QuestPOIFrame:GetTooltipIndex(index) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_QuestPOIFrame_UpdateMouseOverTooltip)
---@param x number
---@param y number
---@return number? questID
---@return number? numObjectives
function QuestPOIFrame:UpdateMouseOverTooltip(x, y) end
