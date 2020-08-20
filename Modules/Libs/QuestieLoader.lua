-- The only public class except for Questie
---@class QuestieLoader
QuestieLoader = {}

local alreadyExist = false;
if(Questie) then
  alreadyExist = true;
end

---@class Module
local module = {}

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

---@param name string @Module name
---@return Module @Module reference
function QuestieLoader:CreateModule(name)
  if (not modules[name]) then
    modules[name] = QuestieLoader:CreateBlankModule()
    return modules[name]
  else
    return modules[name]
  end
end

---@param name string @Module name
---@return Module @Module reference
function QuestieLoader:ImportModule(name)
  if (not modules[name]) then
    modules[name] = QuestieLoader:CreateBlankModule()
    return modules[name]
  else
    return modules[name]
  end
end