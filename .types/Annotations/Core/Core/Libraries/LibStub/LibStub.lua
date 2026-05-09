---@meta _
---[Documentation](https://www.wowace.com/projects/libstub)
LibStub = {}

---@generic T
---@param major `T`
---@param minor number
---@return table|T library
---@return number? oldMinor
function LibStub:NewLibrary(major, minor) end

---@generic T
---@param major `T`
---@param silent? boolean
---@return table|T library
function LibStub:GetLibrary(major, silent) end

---@return function iter
---@return table invariant
function LibStub:IterateLibraries() end

-- not sure how to annotate this
--setmetatable(LibStub, { __call = LibStub.GetLibrary })

---@generic T
---@param major `T`
---@param silent? boolean
---@return table|T library
function LibStub(major, silent) end
