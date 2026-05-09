---@meta _

---@class ColorRGBData
---@field r number
---@field g number
---@field b number
---@field colorStr? string

---@class ColorRGBAData : ColorRGBData
---@field a number

---@class colorRGB : ColorRGBData, ColorMixin
---@class colorRGBA : ColorRGBAData, colorRGB

---[FrameXML](https://www.townlong-yak.com/framexml/go/ColorMixin)
---@class ColorMixin
ColorMixin = {}

---[FrameXML](https://www.townlong-yak.com/framexml/go/CreateColor)
---@param r number
---@param g number
---@param b number
---@param a? number
---@return colorRGBA
function CreateColor(r, g, b, a) end

---[FrameXML](https://www.townlong-yak.com/framexml/go/ColorMixin:IsEqualTo)
---@param otherColor colorRGBA
---@return boolean
function ColorMixin:IsEqualTo(otherColor) end

---[FrameXML](https://www.townlong-yak.com/framexml/go/ColorMixin:GetRGB)
---@return number r
---@return number g
---@return number b
function ColorMixin:GetRGB() end

---[FrameXML](https://www.townlong-yak.com/framexml/go/ColorMixin:GetRGBAsBytes)
---@return number r
---@return number g
---@return number b
function ColorMixin:GetRGBAsBytes() end

---[FrameXML](https://www.townlong-yak.com/framexml/go/ColorMixin:GetRGBA)
---@return number r
---@return number g
---@return number b
---@return number? a
function ColorMixin:GetRGBA() end

---[FrameXML](https://www.townlong-yak.com/framexml/go/ColorMixin:GetRGBAAsBytes)
---@return number r
---@return number g
---@return number b
---@return number? a
function ColorMixin:GetRGBAAsBytes() end

---[FrameXML](https://www.townlong-yak.com/framexml/go/ColorMixin:SetRGBA)
---@param r number
---@param g number
---@param b number
---@param a? number
function ColorMixin:SetRGBA(r, g, b, a) end

---[FrameXML](https://www.townlong-yak.com/framexml/go/ColorMixin:SetRGB)
---@param r number
---@param g number
---@param b number
function ColorMixin:SetRGB(r, g, b) end

---[FrameXML](https://www.townlong-yak.com/framexml/go/ColorMixin:GenerateHexColor)
---@return string
function ColorMixin:GenerateHexColor() end

---[FrameXML](https://www.townlong-yak.com/framexml/go/ColorMixin:GenerateHexColorMarkup)
---@return string
function ColorMixin:GenerateHexColorMarkup() end

---[FrameXML](https://www.townlong-yak.com/framexml/go/ColorMixin:WrapTextInColorCode)
---@param text string
---@return string
function ColorMixin:WrapTextInColorCode(text) end

---[FrameXML](https://www.townlong-yak.com/framexml/go/WrapTextInColorCode)
---@param text string
---@param colorHexString string
---@return string
function WrapTextInColorCode(text, colorHexString) end
