---@meta _
C_DurationUtil = {}

---Creates a zero duration container that can represent a time span.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_DurationUtil.CreateDuration)
---@return LuaDurationObject duration
function C_DurationUtil.CreateDuration() end

---Returns the current time used by duration objects. Equivalent to GetTime() in public builds.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_DurationUtil.GetCurrentTime)
---@return FrameTime currentTime
function C_DurationUtil.GetCurrentTime() end
