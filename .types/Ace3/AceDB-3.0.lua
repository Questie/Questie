---@meta _

-- ----------------------------------------------------------------------------
-- AceDB-3.0
-- ----------------------------------------------------------------------------
---@class AceDB-3.0
local AceDB = {}

-- Creates a new database object that can be used to handle database settings and profiles.
-- By default, an empty DB is created, using a character specific profile.
--
-- You can override the default profile used by passing any profile name as the third argument, or by passing true as the third argument to use a globally shared profile called "Default".
--
-- Note that there is no token replacement in the default profile name, passing a defaultProfile as "char" will use a profile named "char", and not a character-specific profile.
---@param tbl string|table The name of variable, or table to use for the database
---@param defaults? AceDB.Schema A table of database defaults
---@param defaultProfile? string|true The name of the default profile. If not set, a character specific profile will be used as the default. You can also pass true to use a shared global profile called "Default".
---@return AceDBObject-3.0 DB
--- ---
---[Documentation](https://www.wowace.com/projects/ace3/pages/api/ace-db-3-0#title-2)
function AceDB:New(tbl, defaults, defaultProfile) end

-- ----------------------------------------------------------------------------
-- AceDBObject-3.0
-- ----------------------------------------------------------------------------
---@class AceDBObject-3.0: AceDB.Schema
---@field keys table
---@field sv table
---@field defaults AceDB.Schema Cache of defaults
---@field parent table
local DBObjectLib = {}

-- Copies a named profile into the current profile, overwriting any conflicting settings.
---@param name string The name of the profile to be copied into the current profile
---@param silent? boolean If true, do not raise an error when the profile does not exist
--- ---
---[Documentation](https://www.wowace.com/projects/ace3/pages/api/ace-db-3-0#title-3)
function DBObjectLib:CopyProfile(name, silent) end

-- Deletes a named profile.
--
-- This profile must not be the active profile.
---@param name string The name of the profile to be deleted
---@param silent? boolean If true, do not raise an error when the profile does not exist
--- ---
---[Documentation](https://www.wowace.com/projects/ace3/pages/api/ace-db-3-0#title-4)
function DBObjectLib:DeleteProfile(name, silent) end

-- Returns the current profile name used by the database
---@return string profileName
--- ---
---[Documentation](https://www.wowace.com/projects/ace3/pages/api/ace-db-3-0#title-5)
function DBObjectLib:GetCurrentProfile() end

-- Returns an already existing namespace from the database object.
---@param name string The name of the existing namespace
---@param silent? boolean if true, the addon is optional, silently return nil if its not found
---@return table|nil namespace the namespace object if found
--- ---
---[Documentation](https://www.wowace.com/projects/ace3/pages/api/ace-db-3-0#title-6)
function DBObjectLib:GetNamespace(name, silent) end

-- Returns a table with the names of the existing profiles in the database.
--
-- You can optionally supply a table to re-use for this purpose.
---@param tbl? table A table to store the profile names in
---@return table profiles Contains the names of the existing profiles in the database.
--- ---
---[Documentation](https://www.wowace.com/projects/ace3/pages/api/ace-db-3-0#title-7)
function DBObjectLib:GetProfiles(tbl) end

---@param target table The object registering to listen for the callback.
---@param eventName AceDB.EventName The name of the event triggering the callback
---@param method string|function The method to call when the event is fired.
--- ---
---[Documentation](https://www.wowace.com/projects/ace3/pages/ace-db-3-0-tutorial#title-5)
function DBObjectLib.RegisterCallback(target, eventName, method) end

--Sets the defaults table for the given database object by clearing any that are currently set, and then setting the new defaults.
---@param defaults AceDB.Schema A table of defaults for this database
--- ---
---[Documentation](https://www.wowace.com/projects/ace3/pages/api/ace-db-3-0#title-8)
function DBObjectLib:RegisterDefaults(defaults) end

-- Creates a new database namespace, directly tied to the database.
--
-- This is a full scale database in it's own rights other than the fact that it cannot control its profile individually
---@param name string The name of the new namespace
---@param defaults? AceDB.Schema A table of values to use as defaults
---@return AceDBObject-3.0 namespace The created database namespace
--- ---
---[Documentation](https://www.wowace.com/projects/ace3/pages/api/ace-db-3-0#title-9)
function DBObjectLib:RegisterNamespace(name, defaults) end

-- Resets the entire database, using the string defaultProfile as the new default profile.
---@param defaultProfile? string The profile name to use as the default
--- ---
---[Documentation](https://www.wowace.com/projects/ace3/pages/api/ace-db-3-0#title-10)
function DBObjectLib:ResetDB(defaultProfile) end

-- Resets the current profile to the default values (if specified).
---@param noChildren? boolean if set to true, the reset will not be populated to the child namespaces of this DB object
---@param noCallbacks? boolean if set to true, won't fire the OnProfileReset callback
--- ---
---[Documentation](https://www.wowace.com/projects/ace3/pages/api/ace-db-3-0#title-11)
function DBObjectLib:ResetProfile(noChildren, noCallbacks) end

-- Changes the profile of the database and all of it's namespaces to the supplied named profile
--
-- Callback parameters: "OnProfileChanged", database, newProfileKey
---@param name string The name of the profile to set as the current profile
--- ---
---[Documentation](https://www.wowace.com/projects/ace3/pages/api/ace-db-3-0#title-12)
function DBObjectLib:SetProfile(name) end

---@param target table The object unregistering to listen for callbacks.
function DBObjectLib.UnregisterAllCallbacks(target) end

---@param target table The object unregistering to listen for the callback.
---@param eventName AceDB.EventName The event to unregister.
function DBObjectLib.UnregisterCallback(target, eventName) end

-- ----------------------------------------------------------------------------
-- Types
-- ----------------------------------------------------------------------------

---@alias AceDB.EventName
---|"OnDatabaseReset"
---|"OnDatabaseShutdown"
---|"OnNewProfile"
---|"OnProfileChanged"
---|"OnProfileCopied"
---|"OnProfileDeleted"
---|"OnProfileReset"
---|"OnProfileShutdown"

---@class AceDB.Schema
---@field char? table Character-specific data. Every character has its own database.
---@field realm? table Realm-specific data. All of the players characters on the same realm share this database.
---@field class? table Class-specific data. All of the players characters of the same class share this database.
---@field race? table Race-specific data. All of the players characters of the same race share this database.
---@field faction? table Faction-specific data. All of the players characters of the same faction share this database.
---@field factionrealm? table Faction and realm specific data. All of the players characters on the same realm and of the same faction share this database.
---@field factionrealmregion? table Faction, realm and region specific data. All of the players characters on the same realm, of the same faction and in the same region share this database.
---@field locale? table Locale specific data, based on the locale of the players game client.
---@field global? table Global Data. All characters on the same account share this database.
---@field profile? table Profile-specific data. All characters using the same profile share this database. The user can control which profile should be used.
---@field profiles? table Contains all profiles
