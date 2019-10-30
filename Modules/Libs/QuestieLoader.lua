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

---@return Module @Module reference
function QuestieLoader:CreateBlankModule()
  return {} -- todo: copy class template
end

---@param name string @Module name
---@return Module @Module reference
function QuestieLoader:CreateModule(name)
  if (not modules[name]) then
    modules[name] = QuestieLoader:CreateBlankModule()
    return modules[name]
  elseif(modules[name]) then
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