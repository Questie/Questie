---@meta _
-- ----------------------------------------------------------------------------
-- AceConfigCmd-3.0
-- ----------------------------------------------------------------------------
---@class AceConfigCmd-3.0
local lib = {}

--- Utility function to create a slash command handler. 
---
--- Also registers tab completion with AceTab
---@param slashcmd string The slash command WITHOUT leading slash (only used for error output)
---@param appName string The application name as given to `:RegisterOptionsTable()`
function lib:CreateChatCommand(slashcmd, appName) end

--- Utility function that returns the options table that belongs to a slashcommand. 
---
--- Designed to be used for the AceTab interface.
---@param slashcmd string The slash command WITHOUT leading slash (only used for error output)
---@return table|nil optionsTable The options table associated with the slash command (or nil if the slash command was not registered)
function lib:GetChatCommandOptions(slashcmd) end

--- Handle the chat command. 
---
--- This is usually called from a chat command handler to parse the command input as operations on an aceoptions table.
---
--- AceConfigCmd uses this function internally when a slash command is registered with `:CreateChatCommand`
---@param slashcmd string The slash command WITHOUT leading slash (only used for error output)
---@param appName string The application name as given to `:RegisterOptionsTable()`
---@param input string The commandline input (as given by the WoW handler, i.e. without the command itself)
function lib:HandleCommand(slashcmd, appName, input) end

