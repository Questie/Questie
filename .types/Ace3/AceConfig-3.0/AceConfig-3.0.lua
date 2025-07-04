---@meta _

-- ----------------------------------------------------------------------------
-- AceConfig-3.0
-- ----------------------------------------------------------------------------
---@class AceConfig-3.0
local AceConfig = {}

---@paramsig appName, options [, slashcmd]
---@param appName string The application name for the config table.
---@param options table|function|AceConfig.OptionsTable The option table (or a function to generate one on demand). [Options table documentation](http://www.wowace.com/addons/ace3/pages/ace-config-3-0-options-tables/)
---@param slashcmd? string|table A slash command to register for the option table, or a table of slash commands.
---[Documentation](https://www.wowace.com/projects/ace3/pages/api/ace-config-3-0#title-1)
function AceConfig:RegisterOptionsTable(appName, options, slashcmd)
end

-- ----------------------------------------------------------------------------
-- AceConfig.OptionsTable
-- ----------------------------------------------------------------------------

---@alias AceConfig.OptionsTable.ChildGroup
---|"select"
---|"tab"
---|"tree"

---@alias AceConfig.OptionsTable.DescStyle
---|"inline"
---|"tooltip"

---@alias AceConfig.OptionsTable.Type
---|"color"
---|"description"
---|"execute"
---|"group"
---|"header"
---|"input"
---|"keybinding"
---|"multiselect"
---|"range"
---|"select"
---|"toggle"

---@alias AceConfig.OptionsTable.Width
---|"double"
---|"full"
---|"half"
---|"normal"
---|number

---@class AceConfig.OptionsTable
---@field args? table<string, AceConfig.OptionsTable> a table containing a list of options
---@field childGroups? AceConfig.OptionsTable.ChildGroup decides how children groups of this group are displayed
---@field cmdHidden? boolean hide this from commandline
---@field confirm? string|function|boolean prompt for confirmation before changing a value if true display "name - desc", or contents of .confirmText if supplied.
---@field confirmText? string text to display in the confirmation dialog
---@field desc? string|function description for the option (or nil for a self-describing name)
---@field descStyle? AceConfig.OptionsTable.DescStyle "inline" if you want the description to show below the option in a GUI (rather than as a tooltip). Currently only supported by AceGUI "Toggle".
---@field dialogHidden? boolean hide this from dialog UIs
---@field disabled? string|function|boolean disabled but visible
---@field dropdownHidden? boolean hide this from dropdown UIs
---@field func? function function to execute
---@field get? string|function getter function
---@field guiHidden? boolean hide this from graphical UIs (dialog, dropdown)
---@field handler? table object on which getter/setter functions are called if they are declared as strings rather than function references
---@field hidden? string|function|boolean hidden (but usable if you can get to it, i.e. via commandline)
---@field icon? string|function path to icon texture
---@field iconCoords? table|string|function arguments to pass to SetTexCoord, e.g. {0.1,0.9,0.1,0.9}.
---@field name string|function Display name for the option
---@field order? number|string|function relative position of item (default = 100, 0=first, -1=last)
---@field set? string|function setter function
---@field type AceConfig.OptionsTable.Type Type of the option
---@field validate? string|function|false validate the input/value before setting it. return a string (error message) to indicate error.
---@field width? AceConfig.OptionsTable.Width If a number multiplier of the default width, ie. 0.5 equals "half", 2.0 equals "double"
---[Documentation](http://www.wowace.com/addons/ace3/pages/ace-config-3-0-options-tables/)
local OptionsTable = {}
