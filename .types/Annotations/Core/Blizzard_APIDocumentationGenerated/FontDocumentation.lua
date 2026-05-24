---@meta _
---[Documentation](https://warcraft.wiki.gg/wiki/API_CreateFontFamily)
---@param name string
---@param members CreateFontFamilyMemberInfo[]
---@return SimpleFont fontFamily
function CreateFontFamily(name, members) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetFontInfo)
---@param fontObject SimpleFont
---@return FontScriptInfo? info
function GetFontInfo(fontObject) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_GetFonts)
---@return string[] fontNames
function GetFonts() end

---@class CreateFontFamilyMemberInfo
---@field alphabet FontAlphabet
---@field file string
---@field height uiFontHeight
---@field flags TBFFlags

---@class FontScriptInfo
---@field color colorRGBA
---@field height number
---@field outline string
---@field shadow FontScriptShadowInfo?
---@field fontObject SimpleFont
---@field canBeUserScaled boolean

---@class FontScriptShadowInfo
---@field color colorRGBA
---@field x number
---@field y number
