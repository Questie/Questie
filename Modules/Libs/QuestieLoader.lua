-- The only public class except for Questie
---@class QuestieLoader|Module
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

---@param name string @Module name
---@param newModule Module @Module reference
function QuestieLoader:AddModule(name, newModule)
  if(not modules[name] and not alreadyExist) then
    modules[name] = newModule;
    return newModule
  elseif(modules[name] and modules[name].isBlank) then -- fill in the blank
    for refName, ref in pairs(newModule) do
      modules[name][refName] = ref
    end
    modules[name].isBlank = nil
    return modules[name]
  else
    Questie:Error("Trying to load a module already loaded! Please only have one questie installed!");
    error("Trying to load a module already loaded! Please only have one questie installed!");
    return modules[name]
  end
end

---@param name string @Module name
---@return Module @Module reference
function QuestieLoader:ImportModule(name)
  if(not modules[name]) then
    ---@type Module
    local blank = {}
    blank.isBlank = true
    modules[name] = blank
    return blank
  else
    return modules[name];
  end
end