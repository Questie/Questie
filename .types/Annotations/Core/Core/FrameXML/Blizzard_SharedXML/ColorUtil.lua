---@meta _

---[FrameXML](https://www.townlong-yak.com/framexml/go/CreateColorFromHexString)
---@param hexColor string
---@return colorRGBA
function CreateColorFromHexString(hexColor) end

---[FrameXML](https://www.townlong-yak.com/framexml/go/CreateColorFromBytes)
---@param r number
---@param g number
---@param b number
---@param a number
---@return colorRGBA
function CreateColorFromBytes(r, g, b, a) end

---[FrameXML](https://www.townlong-yak.com/framexml/go/AreColorsEqual)
---@param left colorRGBA
---@param right colorRGBA
---@return boolean
function AreColorsEqual(left, right) end

---[FrameXML](https://www.townlong-yak.com/framexml/go/GetClassColor)
---@param classFilename ClassFile
---@return number r
---@return number g
---@return number b
---@return string colorStr
function GetClassColor(classFilename) end

---[FrameXML](https://www.townlong-yak.com/framexml/go/GetClassColorObj)
---@param classFilename string
---@return colorRGB
function GetClassColorObj(classFilename) end

---[FrameXML](https://www.townlong-yak.com/framexml/go/GetClassColoredTextForUnit)
---@param unit string
---@param text string
---@return string
function GetClassColoredTextForUnit(unit, text) end

---[FrameXML](https://www.townlong-yak.com/framexml/go/GetFactionColor)
---@param factionGroupTag string
---@return colorRGBA
function GetFactionColor(factionGroupTag) end
