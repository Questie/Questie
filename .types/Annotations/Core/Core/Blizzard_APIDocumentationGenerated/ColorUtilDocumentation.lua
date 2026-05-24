---@meta _
C_ColorUtil = {}

---Converts an unpacked HSL color to HSV.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ColorUtil.ConvertHSLToHSV)
---@param hslH number
---@param hslS number
---@param hslL number
---@return number hsvH
---@return number hsvS
---@return number hsvV
function C_ColorUtil.ConvertHSLToHSV(hslH, hslS, hslL) end

---Converts an unpacked HSV color to HSL.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ColorUtil.ConvertHSVToHSL)
---@param hsvH number
---@param hsvS number
---@param hsvV number
---@return number hslH
---@return number hslS
---@return number hslL
function C_ColorUtil.ConvertHSVToHSL(hsvH, hsvS, hsvV) end

---Converts an unpacked HSV color to RGB.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ColorUtil.ConvertHSVToRGB)
---@param hsvH number
---@param hsvS number
---@param hsvV number
---@return number rgbR
---@return number rgbG
---@return number rgbB
function C_ColorUtil.ConvertHSVToRGB(hsvH, hsvS, hsvV) end

---Converts an unpacked RGB color to HSV. For achromatic inputs, the returned hue will be -1.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ColorUtil.ConvertRGBToHSV)
---@param rgbR number
---@param rgbG number
---@param rgbB number
---@return number hsvH
---@return number hsvS
---@return number hsvV
function C_ColorUtil.ConvertRGBToHSV(rgbR, rgbG, rgbB) end

---Generates a hex color code suitable for use in text color code markup.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ColorUtil.GenerateTextColorCode)
---@param color colorRGB
---@return string textColorCode
function C_ColorUtil.GenerateTextColorCode(color) end

---Wraps a given string with color code markup.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ColorUtil.WrapTextInColor)
---@param text string
---@param color colorRGB
---@return string coloredText
function C_ColorUtil.WrapTextInColor(text, color) end

---Wraps a given string with color code markup.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_ColorUtil.WrapTextInColorCode)
---@param text string
---@param textColorCode string
---@return string coloredText
function C_ColorUtil.WrapTextInColorCode(text, textColorCode) end
