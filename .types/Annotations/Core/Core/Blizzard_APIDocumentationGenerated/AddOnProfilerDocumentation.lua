---@meta _
C_AddOnProfiler = {}

---Adds a measured event to any ongoing measured calls. If no such calls are currently taking place, this function does nothing.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AddOnProfiler.AddMeasuredCallEvent)
---@param name stringView
function C_AddOnProfiler.AddMeasuredCallEvent(name) end

---Internal API for telemetry.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AddOnProfiler.AddPerformanceMessageShown)
---@param msg AddOnPerformanceMessage
function C_AddOnProfiler.AddPerformanceMessageShown(msg) end

---Optimized check for determining if AddOns are severely impacting UI performance.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AddOnProfiler.CheckForPerformanceMessage)
---@return AddOnPerformanceMessage msg
function C_AddOnProfiler.CheckForPerformanceMessage() end

---Gets an AddOn profiler value - all times returned are in milliseconds.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AddOnProfiler.GetAddOnMetric)
---@param name string
---@param metric Enum.AddOnProfilerMetric
---@return number result
function C_AddOnProfiler.GetAddOnMetric(name, metric) end

---Overall profiling data for the entire application (not just the UI)
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AddOnProfiler.GetApplicationMetric)
---@param metric Enum.AddOnProfilerMetric
---@return number result
function C_AddOnProfiler.GetApplicationMetric(metric) end

---Overall profiling data for all addons
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AddOnProfiler.GetOverallMetric)
---@param metric Enum.AddOnProfilerMetric
---@return number result
function C_AddOnProfiler.GetOverallMetric(metric) end

---Returns the number of profiling clock ticks that occur within a single real-time second.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AddOnProfiler.GetTicksPerSecond)
---@return BigInteger frequency
function C_AddOnProfiler.GetTicksPerSecond() end

---Gets top K AddOns for a given metric.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AddOnProfiler.GetTopKAddOnsForMetric)
---@param metric Enum.AddOnProfilerMetric
---@param k number
---@return AddOnProfilerResult[] results
function C_AddOnProfiler.GetTopKAddOnsForMetric(metric, k) end

---AddOn profiler will be enabled for all users, but this will return false if it ever isn't
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AddOnProfiler.IsEnabled)
---@return boolean enabled
function C_AddOnProfiler.IsEnabled() end

---Performs a profiled measurement of a single function call with any supplied arguments.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_AddOnProfiler.MeasureCall)
---@param func LuaValueVariant
---@param ... LuaValueVariant arguments
---@return AddOnProfilerCallResults results
---@return LuaValueVariant ... returns
function C_AddOnProfiler.MeasureCall(func, ...) end

---@class AddOnPerformanceMessage
---@field type Enum.AddOnPerformanceMessageType
---@field metric Enum.AddOnProfilerMetric
---@field addOnName string?
---@field metricValue number
---@field thresholdValue number

---@class AddOnProfilerCallEvent
---@field name string
---@field allocatedBytes BigUInteger
---@field deallocatedBytes BigUInteger
---@field elapsedMilliseconds number
---@field elapsedTicks BigInteger

---@class AddOnProfilerCallResults
---@field elapsedMilliseconds number
---@field elapsedTicks BigInteger
---@field allocatedBytes BigUInteger
---@field deallocatedBytes BigUInteger
---@field events AddOnProfilerCallEvent[]

---@class AddOnProfilerResult
---@field addOnName string
---@field metricValue number
