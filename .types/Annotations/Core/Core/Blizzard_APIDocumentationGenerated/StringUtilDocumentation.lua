---@meta _
C_StringUtil = {}

---Returns a string with Lua format string tokens ('%') escaped.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_StringUtil.EscapeLuaFormatString)
---@param text string
---@return stringView escapedText
function C_StringUtil.EscapeLuaFormatString(text) end

---Returns a string with all Lua pattern characters escaped.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_StringUtil.EscapeLuaPatterns)
---@param text stringView
---@return string escapedText
function C_StringUtil.EscapeLuaPatterns(text) end

---Returns a string with all quoted code sequences ('|' characters) escaped.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_StringUtil.EscapeQuotedCodes)
---@param text string
---@return stringView escaped
function C_StringUtil.EscapeQuotedCodes(text) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_StringUtil.FloorToNearestString)
---@param number number
---@return string text
function C_StringUtil.FloorToNearestString(number) end

---Returns a string with all contiguous occurrences of ASCII space characters truncated.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_StringUtil.RemoveContiguousSpaces)
---@param text stringView
---@param maxAllowedSpaces number
---@return string trimmedText
function C_StringUtil.RemoveContiguousSpaces(text, maxAllowedSpaces) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_StringUtil.RoundToNearestString)
---@param number number
---@return string text
function C_StringUtil.RoundToNearestString(number) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_StringUtil.StripHyperlinks)
---@param text string
---@param maintainColor? boolean Default = false
---@param maintainBrackets? boolean Default = false
---@param stripNewlines? boolean Default = false
---@param maintainAtlases? boolean Default = false
---@param maintainTextures? boolean Default = false
---@return stringView stripped
function C_StringUtil.StripHyperlinks(text, maintainColor, maintainBrackets, stripNewlines, maintainAtlases, maintainTextures) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_StringUtil.StripTextureMarkupForLooseFiles)
---@param text string
---@return stringView stripped
function C_StringUtil.StripTextureMarkupForLooseFiles(text) end

---Returns a string with all bytes in the 'characters' set removed from the start and end.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_StringUtil.trim)
---@param str stringView
---@param characters? stringView Default =  \r\n\t
---@return stringView trimmed
function C_StringUtil.trim(str, characters) end

---Formats the given number to a string as an integer (rounding down). If the integer is zero, returns an empty string.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_StringUtil.TruncateWhenZero)
---@param number number
---@return string text
function C_StringUtil.TruncateWhenZero(number) end

---Returns a string with 'prefix' and 'suffix' joined to 'infix' iif 'infix' is not an empty string. Else, an empty string is returned.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_StringUtil.WrapString)
---@param infix stringView
---@param prefix? stringView
---@param suffix? stringView
---@return string text
function C_StringUtil.WrapString(infix, prefix, suffix) end

---@class StripHyperlinkOptions
---@field maintainColor boolean? Default = false
---@field maintainBrackets boolean? Default = false
---@field stripNewlines boolean? Default = false
---@field maintainAtlases boolean? Default = false
---@field maintainTextures boolean? Default = false
