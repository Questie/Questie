---@meta _
---[Documentation](https://warcraft.wiki.gg/wiki/API_CalculateStringEditDistance)
---@param firstString stringView
---@param secondString stringView
---@return number distance
function CalculateStringEditDistance(firstString, secondString) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ConsoleEcho)
---@param command string
---@param addToHistory? boolean Default = false
---@param prefix? string
---@return boolean result
function ConsoleEcho(command, addToHistory, prefix) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ConsoleExec)
---@param command string
---@param addToHistory? boolean Default = false
---@return boolean result
function ConsoleExec(command, addToHistory) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ConsoleGetAllCommands)
---@return ConsoleCommandInfo[] commands
function ConsoleGetAllCommands() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ConsoleGetColorFromType)
---@param colorType Enum.ConsoleColorType
---@return colorRGB color
function ConsoleGetColorFromType(colorType) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ConsoleGetFontHeight)
---@return number fontHeightInPixels
function ConsoleGetFontHeight() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ConsoleIsActive)
---@return boolean consoleIsActive
function ConsoleIsActive() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ConsolePrintAllMatchingCommands)
---@param partialCommandText string
function ConsolePrintAllMatchingCommands(partialCommandText) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_ConsoleSetFontHeight)
---@param fontHeightInPixels number
function ConsoleSetFontHeight(fontHeightInPixels) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_SetConsoleKey)
---@param keystring string
function SetConsoleKey(keystring) end

---@class ConsoleCommandInfo
---@field command string
---@field help string
---@field category Enum.ConsoleCategory
---@field commandType Enum.ConsoleCommandType
---@field scriptContents string
---@field scriptParameters string
