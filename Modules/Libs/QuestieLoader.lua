-- The only public class except for Questie
---@class QuestieLoader
QuestieLoader = {}


local modules = {}

QuestieLoader._modules = modules -- store reference so modules can be iterated for profiling

---@generic T
---@param name `T` @Module name
---@return T|{ private: table } @Module reference
function QuestieLoader:CreateModule(name)
    if (not modules[name]) then
        modules[name] = { private = {} }
        return modules[name]
    else
        return modules[name]
    end
end

---@generic T
---@param name `T` @Module name
---@return T|{ private: table } @Module reference
function QuestieLoader:ImportModule(name)
    if (not modules[name]) then
        modules[name] = { private = {} }
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

