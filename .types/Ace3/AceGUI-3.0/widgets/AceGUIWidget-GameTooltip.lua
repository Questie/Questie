---@meta _
---@class AceGUIGameTooltipWidget : AceGUIWidget
local AceGUIGameTooltipWidget = {}

---@param ownerFrame Frame
---@param anchorPoint string
---@param offsetX? number
---@param offsetY? number
function AceGUIGameTooltipWidget:SetOwner(ownerFrame, anchorPoint, offsetX, offsetY) end

---@param hyperlink string
function AceGUIGameTooltipWidget:SetHyperlink(hyperlink) end

---@param itemID number
function AceGUIGameTooltipWidget:SetItemByID(itemID) end

---@param unitToken string
function AceGUIGameTooltipWidget:SetUnit(unitToken) end

---@param spellID number
function AceGUIGameTooltipWidget:SetSpellByID(spellID) end

---@param text string
---@param r? number
---@param g? number
---@param b? number
---@param wrapText? boolean
function AceGUIGameTooltipWidget:AddLine(text, r, g, b, wrapText) end

---@param textLeft string
---@param textRight string
---@param rL? number
---@param gL? number
---@param bL? number
---@param rR? number
---@param gR? number
---@param bR? number
function AceGUIGameTooltipWidget:AddDoubleLine(textLeft, textRight, rL, gL, bL, rR, gR, bR) end

function AceGUIGameTooltipWidget:ClearLines() end

function AceGUIGameTooltipWidget:ShowTooltip() end

function AceGUIGameTooltipWidget:HideTooltip() end

---@param scale number
function AceGUIGameTooltipWidget:SetTooltipScale(scale) end

---@param ownerFrame Frame
---@param anchorPoint string
---@param offsetX? number
---@param offsetY? number
function AceGUIGameTooltipWidget:SetTooltipOwner(ownerFrame, anchorPoint, offsetX, offsetY) end

---@param right number
---@param bottom number
---@param left number
---@param top number
function AceGUIGameTooltipWidget:SetPadding(right, bottom, left, top) end