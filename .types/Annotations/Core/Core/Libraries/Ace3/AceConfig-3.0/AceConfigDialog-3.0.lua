---@meta _
---@class AceConfigDialog-3.0
---@field OpenFrames table<string, table>
---@field Status table<string, table>
---@field tooltip GameTooltip
local AceConfigDialog = {}

---@class AceConfigDialog-3.0.frame : Frame
---@field apps table
---@field closing table
---@field closeAllOverride table
AceConfigDialog.frame = {}

---@paramsig appName, name, parent, ...
--- Add an option table into the Blizzard Interface Options panel
---@param appName string The application name as given to `:RegisterOptionsTable()`
---@param name? string A descriptive name to display in the options tree. Defaults to appName
---@param parent? string The parent to use in the interface options tree
---@param ...? string The path in the options table to feed into the interface options panel
---@return any # The reference to the frame registered into the Interface Options.
---@return any # The registered category ID
---[Documentation](https://www.wowace.com/projects/ace3/pages/api/ace-config-dialog-3-0#title-1)
function AceConfigDialog:AddToBlizOptions(appName, name, parent, ...) end

---@paramsig appName
--- Close a specific options window
---@param appName string The application name as given to `:RegisterOptionsTable()`
---[Documentation](https://www.wowace.com/projects/ace3/pages/api/ace-config-dialog-3-0#title-2)
function AceConfigDialog:Close(appName) end

--- Close all open options windows
---[Documentation](https://www.wowace.com/projects/ace3/pages/api/ace-config-dialog-3-0#title-3)
function AceConfigDialog:CloseAll() end

---@paramsig appName, container, ...
---Open an option winddow at the specified path, if any
---@param appName string The application name as given to `:RegisterOptionsTable()`
---@param container? table
---@param ...? string The path to open after creating the options window (see `:SelectGroup` for details)
---[Documentation](https://www.wowace.com/projects/ace3/pages/api/ace-config-dialog-3-0#title-4)
function AceConfigDialog:Open(appName, container, ...) end

---@paramsig appName, ...
--- Selects the specified path in the options window.
--- The path specified has to match the keys of the groups in the table.
---@param appName string The application name as given to `:RegisterOptionsTable()`
---@param ... string The path to the key that should be selected
---[Documentation](https://www.wowace.com/projects/ace3/pages/api/ace-config-dialog-3-0#title-5)
function AceConfigDialog:SelectGroup(appName, ...) end

---@paramsig appName, width, height
--- Sets the default size of the options window for a specific application.
---@param appName any The application name as given to `:RegisterOptionsTable()`
---@param width number The default width
---@param height number The default height
---[Documentation](https://www.wowace.com/projects/ace3/pages/api/ace-config-dialog-3-0#title-6)
function AceConfigDialog:SetDefaultSize(appName, width, height) end
