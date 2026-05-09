---@meta _
---@diagnostic disable: duplicate-doc-alias
C_Timer = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Timer.After)
---@param seconds number
---@param callback TimerCallback
function C_Timer.After(seconds, callback) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Timer.NewTicker)
---@param seconds number
---@param callback TickerCallback
---@param iterations? number
---@return FunctionContainer cbObject
function C_Timer.NewTicker(seconds, callback, iterations) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Timer.NewTimer)
---@param seconds number
---@param callback TickerCallback
---@return FunctionContainer cbObject
function C_Timer.NewTimer(seconds, callback) end

---@alias TickerCallback FunctionContainer|fun(cb: FunctionContainer)

---@alias TimerCallback FunctionContainer|fun(cb: FunctionContainer)
