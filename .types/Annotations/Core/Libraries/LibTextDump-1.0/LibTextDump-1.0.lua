-- ----------------------------------------------------------------------------
-- LibTextDump-1.0
-- ----------------------------------------------------------------------------
---@meta _
---@class LibTextDump-1.0
local lib = {}

---Creates an interface.
---@param frameTitle string Text to be displayed on the title bar of the display frame for the interface.
---@param width number
---@param height number
---@return LibTextDump.Interface
function lib:New(frameTitle, width, height)
end

-- ----------------------------------------------------------------------------
-- LibTextDump.Interface
-- ----------------------------------------------------------------------------
---@meta _
---@class LibTextDump.Interface
local interface = {}

---Adds a line of text to the interface's buffer.
---@param text string Text to be added to a new line.
---@param dateFormat string? Optional format parameter passed to the Lua date function. If present, prefixes text with [dateFormat].
function interface:AddLine(text, dateFormat)
end

---Clears the contents of the interface's buffer.
function interface:Clear()
end

---Shows the display frame for the interface, populated with the contents of the interface's buffer.
---@param separator string? Optional separator for concatenating the buffer's lines together. Defaults to a newline.
function interface:Display(separator)
end

---Inserts a line of text at the specified position in the interface's buffer.
---@param position number Index of insertion.
---@param text string Text to be added to a new line.
---@param dateFormat string? Optional format parameter passed to the Lua date function. If present, prefixes text with [dateFormat].
function interface:InsertLine(position, text, dateFormat)
end

---Returns the number of lines in the interface's buffer.
---@return number
function interface:Lines()
end

---Returns the string representation of the interface's buffer.
---@param separator string? Optional separator for concatenating the buffer's lines together. Defaults to a newline.
---@return string
function interface:String(separator)
end
