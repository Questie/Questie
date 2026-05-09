---@meta _
C_DamageMeter = {}

---Returns a list of combat sessions currently being tracked.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_DamageMeter.GetAvailableCombatSessions)
---@return DamageMeterAvailableCombatSession[] availableSessions
function C_DamageMeter.GetAvailableCombatSessions() end

---Returns the data for the player's combat session with the specified ID.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_DamageMeter.GetCombatSessionFromID)
---@param sessionID number
---@param type Enum.DamageMeterType
---@return DamageMeterCombatSession session
function C_DamageMeter.GetCombatSessionFromID(sessionID, type) end

---Returns the data for the player's current combat session.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_DamageMeter.GetCombatSessionFromType)
---@param sessionType Enum.DamageMeterSessionType
---@param type Enum.DamageMeterType
---@return DamageMeterCombatSession session
function C_DamageMeter.GetCombatSessionFromType(sessionType, type) end

---Returns the data for a single source (unit) in the player's current combat session with the specified ID.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_DamageMeter.GetCombatSessionSourceFromID)
---@param sessionID number
---@param type Enum.DamageMeterType
---@param sourceGUID? WOWGUID
---@param sourceCreatureID? number
---@return DamageMeterCombatSessionSource sessionSource
function C_DamageMeter.GetCombatSessionSourceFromID(sessionID, type, sourceGUID, sourceCreatureID) end

---Returns the data for a single source (unit) in the player's current combat session.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_DamageMeter.GetCombatSessionSourceFromType)
---@param sessionType Enum.DamageMeterSessionType
---@param type Enum.DamageMeterType
---@param sourceGUID? WOWGUID
---@param sourceCreatureID? number
---@return DamageMeterCombatSessionSource sessionSource
function C_DamageMeter.GetCombatSessionSourceFromType(sessionType, type, sourceGUID, sourceCreatureID) end

---Returns the amount of time a combat session has lasted
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_DamageMeter.GetSessionDurationSeconds)
---@param sessionType Enum.DamageMeterSessionType
---@return number? durationSeconds
function C_DamageMeter.GetSessionDurationSeconds(sessionType) end

---Returns whether the player can enable and use the Damage Meter.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_DamageMeter.IsDamageMeterAvailable)
---@return boolean isAvailable
---@return string failureReason
function C_DamageMeter.IsDamageMeterAvailable() end

---Clears the data for all the player's combat sessions.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_DamageMeter.ResetAllCombatSessions)
function C_DamageMeter.ResetAllCombatSessions() end

---@class DamageMeterAvailableCombatSession
---@field sessionID number
---@field name string
---@field durationSeconds number?

---@class DamageMeterCombatSession
---@field combatSources DamageMeterCombatSource[]
---@field maxAmount number? Default = 0
---@field totalAmount number? Default = 0
---@field durationSeconds number?

---@class DamageMeterCombatSessionSource
---@field combatSpells DamageMeterCombatSpell[]
---@field maxAmount number? Default = 0
---@field totalAmount number? Default = 0

---@class DamageMeterCombatSource
---@field sourceGUID WOWGUID?
---@field sourceCreatureID number?
---@field name string
---@field classFilename string
---@field specIconID fileID
---@field totalAmount number
---@field amountPerSecond number
---@field isLocalPlayer boolean
---@field deathRecapID number
---@field deathTimeSeconds number
---@field classification string

---@class DamageMeterCombatSpell
---@field spellID number
---@field totalAmount number
---@field amountPerSecond number
---@field creatureName string
---@field overkillAmount number
---@field isAvoidable boolean
---@field isDeadly boolean
---@field combatSpellDetails DamageMeterCombatSpellUnitDetails

---@class DamageMeterCombatSpellUnitDetails
---@field unitName string
---@field unitClassFilename string
---@field classification string
---@field isPet boolean
---@field isMob boolean
---@field amount number
---@field specIconID fileID
