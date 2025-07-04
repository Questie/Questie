---@meta _

-- ----------------------------------------------------------------------------
-- AceDBOptions-3.0
-- ----------------------------------------------------------------------------
---@class AceDBOptions-3.0
local AceDBOptions = {}

--[[ 
Get/Create a option table that you can use in your addon to control the profiles of AceDB-3.0.

Usage:

  Assuming `options` is your top-level options table and `self.db` is your database:

  `options.args.profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)`
]]
---@paramsig db, noDefaultProfiles
---@param db AceDBObject-3.0 The database object to create the options table for.
---@param noDefaultProfiles? boolean
---@return AceConfig.OptionsTable optionsTable The options table to be used in AceConfig-3.0
---[Documentation](https://www.wowace.com/projects/ace3/pages/api/ace-dboptions-3-0#title-1)
function AceDBOptions:GetOptionsTable(db, noDefaultProfiles) end
