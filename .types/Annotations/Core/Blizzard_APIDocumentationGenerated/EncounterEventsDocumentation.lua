---@meta _
C_EncounterEvents = {}

---Returns any custom color override applied for an encounter event.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_EncounterEvents.GetEventColor)
---@param encounterEventID number
---@return colorRGB? color
function C_EncounterEvents.GetEventColor(encounterEventID) end

---Returns information about an encounter event.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_EncounterEvents.GetEventInfo)
---@param encounterEventID number
---@return EncounterEventInfo encounterEventInfo
function C_EncounterEvents.GetEventInfo(encounterEventID) end

---Returns a list of all encounter event IDs.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_EncounterEvents.GetEventList)
---@return number[] encounterEventIDs
function C_EncounterEvents.GetEventList() end

---Returns information on a custom sound file to be played when an encounter event trigger occurs.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_EncounterEvents.GetEventSound)
---@param encounterEventID number
---@param trigger Enum.EncounterEventSoundTrigger
---@return EncounterEventSoundInfo sound
function C_EncounterEvents.GetEventSound(encounterEventID, trigger) end

---Returns true if an encounter event record with a specified ID exists.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_EncounterEvents.HasEventInfo)
---@param encounterEventID number
---@return boolean exists
function C_EncounterEvents.HasEventInfo(encounterEventID) end

---Plays any registered custom sound file for a given encounter event trigger.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_EncounterEvents.PlayEventSound)
---@param encounterEventID number
---@param trigger Enum.EncounterEventSoundTrigger
---@return SoundHandle handle
function C_EncounterEvents.PlayEventSound(encounterEventID, trigger) end

---Sets a custom color override for an encounter event. This can be used to colorize text or timer bars individually.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_EncounterEvents.SetEventColor)
---@param encounterEventID number
---@param color? colorRGB
function C_EncounterEvents.SetEventColor(encounterEventID, color) end

---Sets a custom sound file to be played when an encounter event trigger occurs.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_EncounterEvents.SetEventSound)
---@param encounterEventID number
---@param trigger Enum.EncounterEventSoundTrigger
---@param sound? EncounterEventSoundInfo
function C_EncounterEvents.SetEventSound(encounterEventID, trigger, sound) end
