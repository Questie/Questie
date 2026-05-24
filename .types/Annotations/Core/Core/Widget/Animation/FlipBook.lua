---@meta _
---[Documentation](https://warcraft.wiki.gg/wiki/UIOBJECT_FlipBook)
---@class FlipBook : Animation
local FlipBook = {}
---@class flipbook : FlipBook
---@class FLIPBOOK : FlipBook

---[Documentation](https://warcraft.wiki.gg/wiki/API_FlipBook_GetFlipBookColumns)
---@return number columns
function FlipBook:GetFlipBookColumns() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_FlipBook_GetFlipBookFrameHeight)
---@return number height
function FlipBook:GetFlipBookFrameHeight() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_FlipBook_GetFlipBookFrameWidth)
---@return number width
function FlipBook:GetFlipBookFrameWidth() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_FlipBook_GetFlipBookFrames)
---@return number frames
function FlipBook:GetFlipBookFrames() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_FlipBook_GetFlipBookRows)
---@return number rows
function FlipBook:GetFlipBookRows() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_FlipBook_SetFlipBookColumns)
---@param columns number
function FlipBook:SetFlipBookColumns(columns) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_FlipBook_SetFlipBookFrameHeight)
---@param height number
function FlipBook:SetFlipBookFrameHeight(height) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_FlipBook_SetFlipBookFrameWidth)
---@param width number
function FlipBook:SetFlipBookFrameWidth(width) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_FlipBook_SetFlipBookFrames)
---@param frames number
function FlipBook:SetFlipBookFrames(frames) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_FlipBook_SetFlipBookRows)
---@param rows number
function FlipBook:SetFlipBookRows(rows) end
