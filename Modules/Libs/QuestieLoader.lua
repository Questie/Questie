-- The only public class except for Questie
---@class QuestieLoader
QuestieLoader = {}

---@class Module
local moduleClassDefinition = {}

-- ["ModuleName"] = moduleReference
---@type table<string, Module>
local modules = {}
QuestieLoader._modules = modules -- store reference so modules can be iterated for profiling

---@return Module @Module reference
function QuestieLoader:CreateBlankModule()
    local ret = {} -- todo: copy class template
    ret.private = {} -- todo: copy class template
    return ret
end

---@generic T : Module
---@param name string @Module name
---@return T @Module reference
function QuestieLoader:CreateModule(name)
  if (not modules[name]) then
    modules[name] = QuestieLoader:CreateBlankModule()
    return modules[name]
  else
    return modules[name]
  end
end

---@generic T : Module
---@param name string @Module name
---@return T @Module reference
function QuestieLoader:ImportModule(name)
  if (not modules[name]) then
    modules[name] = QuestieLoader:CreateBlankModule()
    return modules[name]
  else
    return modules[name]
  end
end

function QuestieLoader:PopulateGlobals() -- called when debugging is enabled
  for name, module in pairs(modules) do
    _G[name] = module
  end
end

