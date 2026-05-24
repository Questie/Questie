---@meta _

-- ----------------------------------------------------------------------------
-- LibSink-2.0
-- ----------------------------------------------------------------------------
---@class LibSink-2.0
local lib = {}

-- Gets or creates an AceConfig-2.0 OptionsTable
---@return table optionsTable
function lib:GetSinkAce2OptionsDataTable() end

-- Gets or creates an AceConfig-3.0 OptionsTable
---@return table optionsTable
function lib:GetSinkAce3OptionsDataTable() end

-- Sends a message to the registered sink.
---@param textOrAddon number|string|table The text to send, or an object to use as the sender. If an object is passed, the remaining arguments are shifted up internally.
---@param r number Red value of the text - should be passed as decimal values ranging from 0.0 to 1.0.
---@param g number Green value of the text - should be passed as decimal values ranging from 0.0 to 1.0.
---@param b number Blue value of the text - should be passed as decimal values ranging from 0.0 to 1.0.
---@param fontName? string The name of the font to use. Does not work for all sink types.
---@param fontSize? number The size of the font. Does not work for all sink types.
---@param outlineIndex? number The index of the outline style to use. Does not work for all sink types.
---@param isSticky? boolean Set messages from this source to appear as sticky.
---@param location? unknown Unused by the library.
---@param iconTexturePath? string The path of the icon texture to use.
function lib:Pour(textOrAddon, r, g, b, fontName, fontSize, outlineIndex, isSticky, location, iconTexturePath) end

-- Registers a sink with the library
---@param shortName string
---@param name string
---@param desc string|nil
---@param func function|string
---@param scrollAreaFunc? function|string
---@param hasSticky? boolean
function lib:RegisterSink(shortName, name, desc, func, scrollAreaFunc, hasSticky) end

-- Sets the storage location for user preferences
---@param storage table The location in the SavedVariables table
function lib:SetSinkStorage(storage) end

-- Sets a sink override for -all- addons, librarywide.
---@param override? string
function lib:SetSinkOverride(override) end
