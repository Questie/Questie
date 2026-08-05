---@meta _
C_TableUtil = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TableUtil.count)
---@param table LuaValueReference
---@return number numTableNodes
---@return number numArrayNodes
---@return number maxArrayIndex
function C_TableUtil.count(table) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TableUtil.create)
---@param arraySizeHint number
---@param nodeSizeHint? number Default = 0
---@return LuaValueReference table
function C_TableUtil.create(arraySizeHint, nodeSizeHint) end

---Given two tables, finds the first index in the range (1, #t1) and (1, #t2) where two elements compare as inequal, or nil if no such elements are found.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TableUtil.FindIndexedMismatch)
---@param t1 LuaValueReference
---@param t2 LuaValueReference
---@return number? index
function C_TableUtil.FindIndexedMismatch(t1, t2) end

---Marks a supplied table as frozen, preventing any modifications to its contents, or replacement of its metatable. If the table has a pre-existing metatable with a '__newindex' table or function, assignments will pass through without raising errors. For tainted code, only tables created by the same addon making this function call are permitted to be frozen.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TableUtil.freeze)
---@param table LuaValueReference
function C_TableUtil.freeze(table) end

---Returns true if a table has been marked as frozen.
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_TableUtil.isfrozen)
---@param table LuaValueReference
---@return boolean frozen
function C_TableUtil.isfrozen(table) end
