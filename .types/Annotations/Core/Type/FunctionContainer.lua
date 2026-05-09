---@meta _

---@class FunctionContainer
local FunctionContainer = {}

function FunctionContainer:Cancel() end

---@return boolean
function FunctionContainer:IsCancelled() end

function FunctionContainer:Invoke() end
