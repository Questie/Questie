---@meta _
C_EncounterWarnings = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_EncounterWarnings.GetColorForSeverity)
---@param severity Enum.EncounterEventSeverity
---@return colorRGB color
function C_EncounterWarnings.GetColorForSeverity(severity) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_EncounterWarnings.GetEditModeWarningInfo)
---@param severity Enum.EncounterEventSeverity
---@return EncounterWarningInfo warningInfo
function C_EncounterWarnings.GetEditModeWarningInfo(severity) end

---Returns true if custom sound alerts are allowed to play for hidden warning messages.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_EncounterWarnings.GetPlayCustomSoundsWhenHidden)
---@return boolean play
function C_EncounterWarnings.GetPlayCustomSoundsWhenHidden() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_EncounterWarnings.GetSoundKitForSeverity)
---@param severity Enum.EncounterEventSeverity
---@return number soundKitID
function C_EncounterWarnings.GetSoundKitForSeverity(severity) end

---Returns true if text messages for encounter events are allowed to be shown.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_EncounterWarnings.GetWarningsShown)
---@return boolean shown
function C_EncounterWarnings.GetWarningsShown() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_EncounterWarnings.IsFeatureAvailable)
---@return boolean isAvailable
function C_EncounterWarnings.IsFeatureAvailable() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_EncounterWarnings.IsFeatureEnabled)
---@return boolean isAvailableAndEnabled
function C_EncounterWarnings.IsFeatureEnabled() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_EncounterWarnings.PlaySound)
---@param severity Enum.EncounterEventSeverity
---@return number soundHandle
function C_EncounterWarnings.PlaySound(severity) end

---Controls whether custom sound alerts for encounter events are allowed to play for warning messages that are hidden.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_EncounterWarnings.SetPlayCustomSoundsWhenHidden)
---@param play boolean
function C_EncounterWarnings.SetPlayCustomSoundsWhenHidden(play) end

---Controls whether text messages for encounter events are allowed to be shown.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_EncounterWarnings.SetWarningsShown)
---@param shown boolean
function C_EncounterWarnings.SetWarningsShown(shown) end

---@class EncounterWarningInfo
---@field text string
---@field casterGUID WOWGUID
---@field casterName string
---@field targetGUID WOWGUID
---@field targetName string
---@field iconFileID number
---@field tooltipSpellID number
---@field isDeadly boolean
---@field color colorRGB
---@field duration DurationSeconds
---@field severity Enum.EncounterEventSeverity
---@field shouldPlaySound boolean
---@field shouldShowChatMessage boolean
---@field shouldShowWarning boolean
