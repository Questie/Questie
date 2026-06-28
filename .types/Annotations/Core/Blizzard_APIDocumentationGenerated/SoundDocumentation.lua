---@meta _
C_Sound = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Sound.GetSoundScaledVolume)
---@param soundHandle number
---@return number scaledVolume
function C_Sound.GetSoundScaledVolume(soundHandle) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Sound.IsPlaying)
---@param soundHandle number
---@return boolean isPlaying
function C_Sound.IsPlaying(soundHandle) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Sound.PlayItemSound)
---@param soundType Enum.ItemSoundType
---@param itemLocation ItemLocation
function C_Sound.PlayItemSound(soundType, itemLocation) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Sound.PlaySound)
---@param soundKitID number
---@param uiSoundSubType? UISoundSubType Default = g_defaultSI3UISoundSubTypeForLua
---@param forceNoDuplicates? boolean Default = false
---@param runFinishCallback? boolean Default = false
---@param overridePriority? number
---@return boolean success
---@return SoundHandle soundHandle
function C_Sound.PlaySound(soundKitID, uiSoundSubType, forceNoDuplicates, runFinishCallback, overridePriority) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Sound.PlayVocalErrorSound)
---@param vocalErrorSoundID Enum.Vocalerrorsounds
function C_Sound.PlayVocalErrorSound(vocalErrorSoundID) end

---@class PlaySoundParams
---@field soundKitID number
---@field uiSoundSubType UISoundSubType? Default = g_defaultSI3UISoundSubTypeForLua
---@field forceNoDuplicates boolean? Default = false
---@field runFinishCallback boolean? Default = false
---@field overridePriority number?

---@class PlaySoundResult
---@field success boolean
---@field soundHandle SoundHandle
