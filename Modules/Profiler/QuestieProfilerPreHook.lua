---@class QuestieProfilerPreHook
local QuestieProfilerPreHook = QuestieLoader:CreateModule("ProfilerPreHook")

-- The profiler reaches a function by owning the table slot it lives in, which works only for calls that read
-- that slot. A file that writes `local IsDoable = QuestieDB.IsDoable` at its top captures the function object
-- itself, so replacing the slot afterwards reaches nothing - and the profiler loads near the end of every TOC,
-- by which point every such alias already holds the real function. Measured on Era, three aliases in
-- AvailableQuests hid 40% of a CalculateAndDrawAll pass and inflated that pass's own self time by the same
-- amount, which is a wrong number rather than a missing one.
--
-- This file puts a stable indirection in every module function slot as the addon loads, so whatever a later
-- file captures is something the profiler can still redirect. QuestieLoader drives it: each module
-- registration is the top of some file, at which point every file above it has finished, so anything it
-- defined is wrappable before anything below it can alias it.
--
-- It is listed immediately after QuestieLoader, and that is a constraint rather than a convenience. Modules
-- that already exist when this loads are wrapped by the seed at the bottom, but a file *above* this one has
-- already run, so an alias it captured holds the implementation and nothing afterwards can reach it - wrapping
-- the slot later cannot help, because the alias is a copy, which is the whole problem being solved. Moving
-- this line down the TOC therefore blinds everything between the loader and its new position, silently.
-- Nothing but QuestieLoader is above it, and nothing should be.
--
-- The indirection is one Lua call, and it stays for the session because an alias that captured it cannot give
-- it back. Measured in-client that is 0.073us against roughly 3.7us for a measured call - about 2% while
-- profiling, and the only state where it costs anything on its own is between Stop and a reload. Nothing is
-- installed at all unless startup profiling is enabled.

---@class ProfilerPreHookTarget
---@field moduleName string
---@field functionName string
---@field original function @The real implementation
---@field wrapper function @What an aliasing file captures
---@field slot table @A stand-in table the profiler hooks through, reading and writing the wrapper's target

---@type ProfilerPreHookTarget[]
local targets = {}
QuestieProfilerPreHook.targets = targets

-- Every wrapper this file has made, so a second pass recognises its own work rather than wrapping a wrapper.
-- Weak keys because a module may replace a function outright, and nothing here should keep the old one alive.
---@type table<function, true>
local ownWrappers = setmetatable({}, {__mode = "k"})

-- Modules whose functions must keep their real identity.
--
-- The three profiler modules measure; wrapping them would measure the measuring. ThreadLib is the scheduler
-- the profiler drives, and it also hands its own callback functions to the profiler at file scope, so
-- redirecting those would put an indirection inside every resume boundary.
--
-- The rest mirror PROFILING_DISALLOWED_PATHS in QuestieProfiler.lua, which excludes them because they run
-- thousands of times inside a single useful high-level measurement and would otherwise dominate every result.
-- That list cannot be imported here - this file loads long before it - so it is repeated, and the two must be
-- changed together.
local EXCLUDED_MODULES = {
    Profiler = true,
    ProfilerUI = true,
    ProfilerReport = true,
    ProfilerPreHook = true,
    ThreadLib = true,
    QuestieStreamLib = true,
    DBCompiler = true,
    QuestieSerializer = true,
}

-- Same reasoning, for slots rather than whole modules: QuestieDB's generated query primitives.
local EXCLUDED_PREFIXES = {"QueryNPC", "QueryQuest", "QueryObject", "QueryItem", "_Query"}

---Whether this file refuses to wrap a slot. Exposed so QuestieProfiler can check that everything it refuses
---to measure is also refused here - see the note above EXCLUDED_MODULES for why the two lists are separate.
---@param moduleName string
---@param functionName string
---@return boolean
local function IsExcluded(moduleName, functionName)
    if EXCLUDED_MODULES[moduleName] then
        return true
    end
    if moduleName == "QuestieDB" then
        for index = 1, #EXCLUDED_PREFIXES do
            local prefix = EXCLUDED_PREFIXES[index]
            if string.sub(functionName, 1, string.len(prefix)) == prefix then
                return true
            end
        end
    end
    return false
end

---@param module table
---@param moduleName string
---@param functionName string
---@param original function
local function Install(module, moduleName, functionName, original)
    -- `current` is the whole mechanism. The wrapper never changes, so an alias may capture it safely, and a
    -- session redirects the call by swapping this one upvalue. No branch is needed: with nothing measuring,
    -- `current` is the implementation and the only cost is this frame.
    local current = original
    local wrapper = function(...)
        return current(...)
    end

    -- A table that reads and writes `current`, so QuestieProfiler:HookFunction can treat it as an ordinary
    -- parent table. Naming, row registration, caller edges and Unhook's ownership check then all work
    -- unchanged - and because the wrapper is stable and only `current` moves, a second session can hook it
    -- again, which a plain hook on the module slot could not survive.
    local slot = setmetatable({}, {
        __index = function()
            return current
        end,
        __newindex = function(_, _, value)
            current = value
        end,
    })

    ownWrappers[wrapper] = true
    module[functionName] = wrapper
    targets[#targets + 1] = {
        moduleName = moduleName,
        functionName = functionName,
        original = original,
        wrapper = wrapper,
        slot = slot,
    }
end

-- Modules that may have gained functions since they were last looked at: the ones some file has named. A
-- module nobody has mentioned cannot have grown, so re-reading it finds nothing - and re-reading all of them
-- on every loader call is what made the first version of this cost 175ms of load, inspecting 571,720 slots to
-- install 626 wrappers.
---@type table<string, true>
local dirty = {}

---Wraps every not-yet-wrapped function of one module.
---
---Replacing the value of a key that already exists is defined behaviour in Lua while traversing with `pairs`;
---no key is added here.
---@param moduleName string
local function SweepModule(moduleName)
    if EXCLUDED_MODULES[moduleName] then
        return
    end
    local module = QuestieLoader._modules[moduleName]
    if type(module) ~= "table" then
        return
    end

    for functionName, value in pairs(module) do
        if type(functionName) == "string"
            and type(value) == "function"
            and not ownWrappers[value]
            and not IsExcluded(moduleName, functionName) then
            Install(module, moduleName, functionName, value)
        end
    end
end

---Sweeps everything, for the cases where there is no name to go on.
local function SweepAll()
    for moduleName in pairs(QuestieLoader._modules) do
        SweepModule(moduleName)
    end
end

---Runs at each module registration.
---
---A file's own functions are defined after its loader calls, so they are picked up at the next call - which is
---either later in the same file or the top of the next one, and in both cases before anything below can alias
---them. The module being named now is marked instead of swept, because it is about to be filled.
---@param moduleName string
local function OnModuleCall(moduleName)
    for name in pairs(dirty) do
        SweepModule(name)
        dirty[name] = nil
    end
    dirty[moduleName] = true
end

QuestieProfilerPreHook.IsExcluded = IsExcluded

QuestieProfilerPreHook.installed = false

---Stops wrapping. Everything already installed stays; this only ends the per-loader-call sweep.
function QuestieProfilerPreHook.Finish()
    QuestieLoader:SetModuleCallObserver(nil)
    -- A full pass, not just the dirty set: this is the last chance, so correctness beats the saved scan.
    SweepAll()
end

-- Read at load from the same plain saved variable the loader reads: every TOC declares
-- LoadSavedVariablesFirst, so it is already populated. A player who never profiles builds no wrappers at all.
if QuestieProfilerEnabled == true then
    -- Modules registered before this file loaded were never announced, so nothing would mark them dirty.
    -- This wraps their slots; it cannot repair an alias a file above already captured, which is why the
    -- note at the top insists on this file's position.
    for moduleName in pairs(QuestieLoader._modules) do
        dirty[moduleName] = true
    end
    QuestieLoader:SetModuleCallObserver(OnModuleCall)
    QuestieProfilerPreHook.installed = true

    -- Addon load is over, so no further file can capture anything; stop sweeping on every loader call.
    if CreateFrame then
        local finishFrame = CreateFrame("Frame")
        finishFrame:RegisterEvent("ADDON_LOADED")
        finishFrame:SetScript("OnEvent", function(self, _, addonName)
            if addonName ~= "Questie" then
                return
            end
            self:UnregisterEvent("ADDON_LOADED")
            QuestieProfilerPreHook.Finish()
        end)
    end
end
