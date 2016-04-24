--[[
Name: AceEvent-2.0
Revision: $Rev: 1091 $
Developed by: The Ace Development Team (http://www.wowace.com/index.php/The_Ace_Development_Team)
Inspired By: Ace 1.x by Turan (turan@gryphon.com)
Website: http://www.wowace.com/
Documentation: http://www.wowace.com/index.php/AceEvent-2.0
SVN: http://svn.wowace.com/wowace/trunk/Ace2/AceEvent-2.0
Description: Mixin to allow for event handling, scheduling, and inter-addon
             communication.
Dependencies: AceLibrary, AceOO-2.0
License: LGPL v2.1
]]

local MAJOR_VERSION = "AceEvent-2.0"
local MINOR_VERSION = 90000 + tonumber(("$Revision: 1091 $"):match("(%d+)"))

if not AceLibrary then error(MAJOR_VERSION .. " requires AceLibrary") end
if not AceLibrary:IsNewVersion(MAJOR_VERSION, MINOR_VERSION) then return end

if not AceLibrary:HasInstance("AceOO-2.0") then error(MAJOR_VERSION .. " requires AceOO-2.0") end

local AceOO = AceLibrary:GetInstance("AceOO-2.0")
local Mixin = AceOO.Mixin
local AceEvent = Mixin {
	"RegisterEvent",
	"RegisterAllEvents",
	"UnregisterEvent",
	"UnregisterAllEvents",
	"TriggerEvent",
	"ScheduleEvent",
	"ScheduleRepeatingEvent",
	"CancelScheduledEvent",
	"CancelAllScheduledEvents",
	"IsEventRegistered",
	"IsEventScheduled",
	"RegisterBucketEvent",
	"UnregisterBucketEvent",
	"UnregisterAllBucketEvents",
	"IsBucketEventRegistered",
	"ScheduleLeaveCombatAction",
	"CancelAllCombatSchedules",
}

local weakKey = {__mode="k"}

local FAKE_NIL
local RATE

local eventsWhichHappenOnce = {
	PLAYER_LOGIN = true,
	AceEvent_FullyInitialized = true,
	VARIABLES_LOADED = true,
	PLAYER_LOGOUT = true,
}
local next = next
local pairs = pairs
local pcall = pcall
local type = type
local GetTime = GetTime
local gcinfo = gcinfo
local unpack = unpack
local geterrorhandler = geterrorhandler

local new, del
do
	local cache = setmetatable({}, {__mode='k'})
	function new(...)
		local t = next(cache)
		if t then
			cache[t] = nil
			for i = 1, select('#', ...) do
				t[i] = select(i, ...)
			end
			return t
		else
			return { ... }
		end
	end
	function del(t)
		for k in pairs(t) do
			t[k] = nil
		end
		cache[t] = true
		return nil
	end
end

local registeringFromAceEvent
--[[----------------------------------------------------------------------------------
Notes:
	* Registers the addon with a Blizzard event or a custom AceEvent, which will cause the given method to be called when that is triggered.
Arguments:
	string - name of the event to register
	[optional] string or function - name of the method or function to call. Default: same name as "event".
	[optional] boolean - whether to have method called only once. Default: false
------------------------------------------------------------------------------------]]
function AceEvent:RegisterEvent(event, method, once)
	AceEvent:argCheck(event, 2, "string")
	if self == AceEvent and not registeringFromAceEvent then
		AceEvent:argCheck(method, 3, "function")
		self = method
	else
		AceEvent:argCheck(method, 3, "string", "function", "nil", "boolean", "number")
		if type(method) == "boolean" or type(method) == "number" then
			AceEvent:argCheck(once, 4, "nil")
			once, method = method, event
		end
	end
	AceEvent:argCheck(once, 4, "number", "boolean", "nil")
	if eventsWhichHappenOnce[event] then
		once = true
	end
	local throttleRate
	if type(once) == "number" then
		throttleRate, once = once
	end
	if not method then
		method = event
	end
	if type(method) == "string" and type(self[method]) ~= "function" then
		AceEvent:error("Cannot register event %q to method %q, it does not exist", event, method)
	else
		assert(type(method) == "function" or type(method) == "string")
	end

	local AceEvent_registry = AceEvent.registry
	if not AceEvent_registry[event] then
		AceEvent_registry[event] = new()
		AceEvent.frame:RegisterEvent(event)
	end

	local remember = true
	if AceEvent_registry[event][self] then
		remember = false
	end
	AceEvent_registry[event][self] = method

	local AceEvent_onceRegistry = AceEvent.onceRegistry
	if once then
		if not AceEvent_onceRegistry then
			AceEvent.onceRegistry = {}
			AceEvent_onceRegistry = AceEvent.onceRegistry
		end
		if not AceEvent_onceRegistry[event] then
			AceEvent_onceRegistry[event] = new()
		end
		AceEvent_onceRegistry[event][self] = true
	else
		if AceEvent_onceRegistry and AceEvent_onceRegistry[event] then
			AceEvent_onceRegistry[event][self] = nil
			if not next(AceEvent_onceRegistry[event]) then
				AceEvent_onceRegistry[event] = del(AceEvent_onceRegistry[event])
			end
		end
	end

	local AceEvent_throttleRegistry = AceEvent.throttleRegistry
	if throttleRate then
		if not AceEvent_throttleRegistry then
			AceEvent.throttleRegistry = {}
			AceEvent_throttleRegistry = AceEvent.throttleRegistry
		end
		if not AceEvent_throttleRegistry[event] then
			AceEvent_throttleRegistry[event] = new()
		end
		if AceEvent_throttleRegistry[event][self] then
			AceEvent_throttleRegistry[event][self] = nil
		end
		AceEvent_throttleRegistry[event][self] = setmetatable(new(), weakKey)
		local t = AceEvent_throttleRegistry[event][self]
		t[RATE] = throttleRate
	else
		if AceEvent_throttleRegistry and AceEvent_throttleRegistry[event] then
			if AceEvent_throttleRegistry[event][self] then
				AceEvent_throttleRegistry[event][self] = nil
			end
			if not next(AceEvent_throttleRegistry[event]) then
				AceEvent_throttleRegistry[event] = del(AceEvent_throttleRegistry[event])
			end
		end
	end

	if remember then
		AceEvent:TriggerEvent("AceEvent_EventRegistered", self, event)
	end
end

local ALL_EVENTS

--[[----------------------------------------------------------------------------------
Notes:
	* Registers all events to the given method
	* To access the current event, check AceEvent.currentEvent
	* To access the current event's unique identifier, check AceEvent.currentEventUID
	* This is only for debugging purposes.
Arguments:
	[optional] string or function - name of the method or function to call. Default: same name as "event".
------------------------------------------------------------------------------------]]
function AceEvent:RegisterAllEvents(method)
	if self == AceEvent then
		AceEvent:argCheck(method, 1, "function")
		self = method
	else
		AceEvent:argCheck(method, 1, "string", "function")
		if type(method) == "string" and type(self[method]) ~= "function" then
			AceEvent:error("Cannot register all events to method %q, it does not exist", method)
		end
	end
	
	local AceEvent_registry = AceEvent.registry
	if not AceEvent_registry[ALL_EVENTS] then
		AceEvent_registry[ALL_EVENTS] = new()
		AceEvent.frame:RegisterAllEvents()
	end
	
	local remember = not AceEvent_registry[ALL_EVENTS][self]
	AceEvent_registry[ALL_EVENTS][self] = method
	if remember then
		AceEvent:TriggerEvent("AceEvent_EventRegistered", self, "all")
	end
end

--[[----------------------------------------------------------------------------------
Notes:
	* Trigger a custom AceEvent.
	* This should never be called to simulate fake Blizzard events.
	* Custom events should be in the form of AddonName_SpecificEvent
Arguments:
	string - name of the event
	tuple - list of arguments to pass along
------------------------------------------------------------------------------------]]
function AceEvent:TriggerEvent(event, ...)
	AceEvent:argCheck(event, 2, "string")
	local AceEvent_registry = AceEvent.registry
	if (not AceEvent_registry[event] or not next(AceEvent_registry[event])) and (not AceEvent_registry[ALL_EVENTS] or not next(AceEvent_registry[ALL_EVENTS])) then
		return
	end
	local lastEvent = AceEvent.currentEvent
	AceEvent.currentEvent = event
	local lastEventUID = AceEvent.currentEventUID
	local uid = AceEvent.UID_NUM + 1
	AceEvent.UID_NUM = uid
	AceEvent.currentEventUID = uid

	local tmp = new()

	local AceEvent_onceRegistry = AceEvent.onceRegistry
	if AceEvent_onceRegistry and AceEvent_onceRegistry[event] then
		for obj, method in pairs(AceEvent_onceRegistry[event]) do
			tmp[obj] = AceEvent_registry[event] and AceEvent_registry[event][obj] or nil
		end
		local obj = next(tmp)
		while obj do
			local method = tmp[obj]
			AceEvent.UnregisterEvent(obj, event)
			if type(method) == "string" then
				local obj_method = obj[method]
				if obj_method then
					local success, err = pcall(obj_method, obj, ...)
					if not success then geterrorhandler()(err:find("%.lua:%d+:") and err or (debugstack():match("(.-: )in.-\n") or "") .. err) end
				end
			elseif method then -- function
				local success, err = pcall(method, ...)
				if not success then geterrorhandler()(err:find("%.lua:%d+:") and err or (debugstack():match("(.-: )in.-\n") or "") .. err) end
			end
			tmp[obj] = nil
			obj = next(tmp)
		end
	end

	local AceEvent_throttleRegistry = AceEvent.throttleRegistry
	local throttleTable = AceEvent_throttleRegistry and AceEvent_throttleRegistry[event]
	if AceEvent_registry[event] then
		for obj, method in pairs(AceEvent_registry[event]) do
			tmp[obj] = method
		end
		local obj = next(tmp)
		while obj do
			local cont = nil
			if throttleTable and throttleTable[obj] then
				local a1 = ...
				if a1 == nil then
					a1 = FAKE_NIL
				end
				if not throttleTable[obj][a1] or GetTime() - throttleTable[obj][a1] >= throttleTable[obj][RATE] then
					throttleTable[obj][a1] = GetTime()
				else
					cont = true
				end
			end
			if not cont then
				local method = tmp[obj]
				local t = type(method)
				if t == "string" then
					local obj_method = obj[method]
					if obj_method then
						local success, err = pcall(obj_method, obj, ...)
						if not success then geterrorhandler()(err:find("%.lua:%d+:") and err or (debugstack():match("(.-: )in.-\n") or "") .. err) end
					end
				elseif t == "function" then -- function
					local success, err = pcall(method, ...)
					if not success then geterrorhandler()(err:find("%.lua:%d+:") and err or (debugstack():match("(.-: )in.-\n") or "") .. err) end
				else
					AceEvent:error("Cannot trigger event %q. %q's handler, %q, is not a method or function (%s).", event, obj, method, t)
				end
			end
			tmp[obj] = nil
			obj = next(tmp)
		end
	end
	if AceEvent_registry[ALL_EVENTS] then
		for obj, method in pairs(AceEvent_registry[ALL_EVENTS]) do
			tmp[obj] = method
		end
		local obj = next(tmp)
		while obj do
			local method = tmp[obj]
			local t = type(method)
			if t == "string" then
				local obj_method = obj[method]
				if obj_method then
					local success, err = pcall(obj_method, obj, ...)
					if not success then geterrorhandler()(err:find("%.lua:%d+:") and err or (debugstack():match("(.-: )in.-\n") or "") .. err) end
				end
			elseif t == "function" then
				local success, err = pcall(method, ...)
				if not success then geterrorhandler()(err:find("%.lua:%d+:") and err or (debugstack():match("(.-: )in.-\n") or "") .. err) end
			else
				AceEvent:error("Cannot trigger event %q. %q's handler, %q, is not a method or function (%s).", event, obj, method, t)
			end
			tmp[obj] = nil
			obj = next(tmp)
		end
	end
	tmp = del(tmp)
	AceEvent.currentEvent = lastEvent
	AceEvent.currentEventUID = lastEventUID
end

local delayRegistry
local OnUpdate
do
	local tmp = {}
	OnUpdate = function()
		local t = GetTime()
		for k,v in pairs(delayRegistry) do
			tmp[k] = true
		end
		for k in pairs(tmp) do
			local v = delayRegistry[k]
			if v then
				local v_time = v.time
				if not v_time then
					delayRegistry[k] = nil
				elseif v_time <= t then
					local v_repeatDelay = v.repeatDelay
					if v_repeatDelay then
						-- use the event time, not the current time, else timing inaccuracies add up over time
						v.time = v_time + v_repeatDelay
					end
					local event = v.event
					local t = type(event)
					if t == "function" then
						local uid = AceEvent.UID_NUM + 1
						AceEvent.UID_NUM = uid
						AceEvent.currentEventUID = uid
						local success, err = pcall(event, unpack(v, 1, v.n))
						if not success then geterrorhandler()(err:find("%.lua:%d+:") and err or (debugstack():match("(.-: )in.-\n") or "") .. err) end
						AceEvent.currentEventUID = nil
					elseif t == "string" then
						AceEvent:TriggerEvent(event, unpack(v, 1, v.n))
					else
						AceEvent:error("Cannot trigger event %q, it's not a method or function (%s).", event, t)
					end
					if not v_repeatDelay then
						local x = delayRegistry[k]
						if x and x.time == v_time then -- check if it was manually reset
							if type(k) == "string" then
								del(delayRegistry[k])
							end
							delayRegistry[k] = nil
						end
					end
				end
			end
		end
		for k in pairs(tmp) do
			tmp[k] = nil
		end
		if not next(delayRegistry) then
			AceEvent.frame:Hide()
		end
	end
end

local function ScheduleEvent(self, repeating, event, delay, ...)
	local id
	if type(event) == "string" and type(delay) ~= "number" then
		id, event, delay = event, delay, ...
		AceEvent:argCheck(event, 3, "string", "function", --[[ so message is right ]] "number")
		AceEvent:argCheck(delay, 4, "number")
		self:CancelScheduledEvent(id)
	else
		AceEvent:argCheck(event, 2, "string", "function")
		AceEvent:argCheck(delay, 3, "number")
	end

	if not delayRegistry then
		AceEvent.delayRegistry = {}
		delayRegistry = AceEvent.delayRegistry
		AceEvent.frame:SetScript("OnUpdate", OnUpdate)
	end
	local t
	if id then
		t = new(select(2, ...))
		t.n = select('#', ...) - 1
	else
		t = new(...)
		t.n = select('#', ...)
	end
	t.event = event
	t.time = GetTime() + delay
	t.self = self
	t.id = id or t
	t.repeatDelay = repeating and delay
	delayRegistry[t.id] = t
	AceEvent.frame:Show()
end

--[[----------------------------------------------------------------------------------
Notes:
	* Schedule an event to fire.
	* To fire on the next frame, specify a delay of 0.
Arguments:
	string or function - name of the event to fire, or a function to call.
	number - the amount of time to wait until calling.
	tuple - a list of arguments to pass along.
------------------------------------------------------------------------------------]]
function AceEvent:ScheduleEvent(event, delay, ...)
	if type(event) == "string" and type(delay) ~= "number" then
		AceEvent:argCheck(delay, 3, "string", "function", --[[ so message is right ]] "number")
		AceEvent:argCheck(..., 4, "number")
	else
		AceEvent:argCheck(event, 2, "string", "function")
		AceEvent:argCheck(delay, 3, "number")
	end

	return ScheduleEvent(self, false, event, delay, ...)
end

function AceEvent:ScheduleRepeatingEvent(event, delay, ...)
	if type(event) == "string" and type(delay) ~= "number" then
		AceEvent:argCheck(delay, 3, "string", "function", --[[ so message is right ]] "number")
		AceEvent:argCheck(..., 4, "number")
	else
		AceEvent:argCheck(event, 2, "string", "function")
		AceEvent:argCheck(delay, 3, "number")
	end

	return ScheduleEvent(self, true, event, delay, ...)
end

function AceEvent:CancelScheduledEvent(t)
	AceEvent:argCheck(t, 2, "string")
	if delayRegistry then
		local v = delayRegistry[t]
		if v then
			if type(t) == "string" then
				del(delayRegistry[t])
			end
			delayRegistry[t] = nil
			if not next(delayRegistry) then
				AceEvent.frame:Hide()
			end
			return true
		end
	end
	return false
end

function AceEvent:IsEventScheduled(t)
	AceEvent:argCheck(t, 2, "string")
	if delayRegistry then
		local v = delayRegistry[t]
		if v then
			return true, v.time - GetTime()
		end
	end
	return false, nil
end

function AceEvent:UnregisterEvent(event)
	AceEvent:argCheck(event, 2, "string")
	local AceEvent_registry = AceEvent.registry
	if AceEvent_registry[event] and AceEvent_registry[event][self] then
		AceEvent_registry[event][self] = nil
		local AceEvent_onceRegistry = AceEvent.onceRegistry
		if AceEvent_onceRegistry and AceEvent_onceRegistry[event] and AceEvent_onceRegistry[event][self] then
			AceEvent_onceRegistry[event][self] = nil
			if not next(AceEvent_onceRegistry[event]) then
				AceEvent_onceRegistry[event] = del(AceEvent_onceRegistry[event])
			end
		end
		local AceEvent_throttleRegistry = AceEvent.throttleRegistry
		if AceEvent_throttleRegistry and AceEvent_throttleRegistry[event] and AceEvent_throttleRegistry[event][self] then
			AceEvent_throttleRegistry[event][self] = nil
			if not next(AceEvent_throttleRegistry[event]) then
				AceEvent_throttleRegistry[event] = del(AceEvent_throttleRegistry[event])
			end
		end
		if not next(AceEvent_registry[event]) then
			AceEvent_registry[event] = del(AceEvent_registry[event])
			if not AceEvent_registry[ALL_EVENTS] or not next(AceEvent_registry[ALL_EVENTS]) then
				AceEvent.frame:UnregisterEvent(event)
			end
		end
	else
		if self == AceEvent then
			error(("Cannot unregister event %q. Improperly unregistering from AceEvent-2.0."):format(event), 2)
		else
			AceEvent:error("Cannot unregister event %q. %q is not registered with it.", event, self)
		end
	end
	AceEvent:TriggerEvent("AceEvent_EventUnregistered", self, event)
end

function AceEvent:UnregisterAllEvents()
	local AceEvent_registry = AceEvent.registry
	if AceEvent_registry[ALL_EVENTS] and AceEvent_registry[ALL_EVENTS][self] then
		AceEvent_registry[ALL_EVENTS][self] = nil
		if not next(AceEvent_registry[ALL_EVENTS]) then
			AceEvent_registry[ALL_EVENTS] = del(AceEvent_registry[ALL_EVENTS])
			AceEvent.frame:UnregisterAllEvents()
			for k,v in pairs(AceEvent_registry) do
				AceEvent.frame:RegisterEvent(k)
			end
		end
	end
	if AceEvent_registry.AceEvent_EventUnregistered then
		local event, data = "AceEvent_EventUnregistered", AceEvent_registry.AceEvent_EventUnregistered
		local x = data[self]
		data[self] = nil
		if x then
			if not next(data) then
				if not AceEvent_registry[ALL_EVENTS] then
					AceEvent.frame:UnregisterEvent(event)
				end
				AceEvent_registry[event] = del(AceEvent_registry[event])
			end
			AceEvent:TriggerEvent("AceEvent_EventUnregistered", self, event)
		end
	end
	for event, data in pairs(AceEvent_registry) do
		local x = data[self]
		data[self] = nil
		if x and event ~= ALL_EVENTS then
			if not next(data) then
				if not AceEvent_registry[ALL_EVENTS] then
					AceEvent.frame:UnregisterEvent(event)
				end
				AceEvent_registry[event] = del(AceEvent_registry[event])
			end
			AceEvent:TriggerEvent("AceEvent_EventUnregistered", self, event)
		end
	end
	if AceEvent.onceRegistry then
		for event, data in pairs(AceEvent.onceRegistry) do
			data[self] = nil
		end
	end
end

function AceEvent:CancelAllScheduledEvents()
	if delayRegistry then
		for k,v in pairs(delayRegistry) do
			if v.self == self then
				if type(k) == "string" then
					del(delayRegistry[k])
				end
				delayRegistry[k] = nil
			end
		end
		if not next(delayRegistry) then
			AceEvent.frame:Hide()
		end
	end
end

function AceEvent:IsEventRegistered(event)
	AceEvent:argCheck(event, 2, "string")
	local AceEvent_registry = AceEvent.registry
	if self == AceEvent then
		return AceEvent_registry[event] and next(AceEvent_registry[event]) or AceEvent_registry[ALL_EVENTS] and next(AceEvent_registry[ALL_EVENTS]) and true or false
	end
	if AceEvent_registry[event] and AceEvent_registry[event][self] then
		return true, AceEvent_registry[event][self]
	end
	if AceEvent_registry[ALL_EVENTS] and AceEvent_registry[ALL_EVENTS][self] then
		return true, AceEvent_registry[ALL_EVENTS][self]
	end
	return false, nil
end

local UnitExists = UnitExists
local bucketfunc
function AceEvent:RegisterBucketEvent(event, delay, method, ...)
	AceEvent:argCheck(event, 2, "string", "table")
	if type(event) == "table" then
		for k,v in pairs(event) do
			if type(k) ~= "number" then
				AceEvent:error("All keys to argument #2 to `RegisterBucketEvent' must be numbers.")
			elseif type(v) ~= "string" then
				AceEvent:error("All values to argument #2 to `RegisterBucketEvent' must be strings.")
			end
		end
	end
	AceEvent:argCheck(delay, 3, "number")
	if AceEvent == self then
		AceEvent:argCheck(method, 4, "function")
		self = method
	else
		if type(event) == "string" then
			AceEvent:argCheck(method, 4, "string", "function", "nil")
			if not method then
				method = event
			end
		else
			AceEvent:argCheck(method, 4, "string", "function")
		end

		if type(method) == "string" and type(self[method]) ~= "function" then
			AceEvent:error("Cannot register event %q to method %q, it does not exist", event, method)
		end
	end
	local buckets = AceEvent.buckets
	if not buckets[event] then
		buckets[event] = new()
	end
	if not buckets[event][self] then
		local t = {}
		t.current = {}
		t.self = self
		buckets[event][self] = t
	else
		AceEvent.CancelScheduledEvent(self, buckets[event][self].id)
	end
	local bucket = buckets[event][self]
	bucket.method = method

	local n = select('#', ...)
	if n > 0 then
		for i = 1, n do
			bucket[i] = select(i, ...)
		end
	end
	bucket.n = n

	local func = function(arg1)
		bucket.run = true
		if arg1 then
			bucket.current[arg1] = true
		end
	end
	buckets[event][self].func = func
	local isUnitBucket = true
	if type(event) == "string" then
		AceEvent.RegisterEvent(self, event, func)
		if not event:find("^UNIT_") then
			isUnitBucket = nil
		end
	else
		for _,v in ipairs(event) do
			AceEvent.RegisterEvent(self, v, func)
			if isUnitBucket and not v:find("^UNIT_") then
				isUnitBucket = nil
			end
		end
	end
	bucket.unit = isUnitBucket
	if not bucketfunc then
		bucketfunc = function(bucket)
			if bucket.run then
				local current = bucket.current
				local method = bucket.method
				local self = bucket.self
				if bucket.unit then
					for unit in pairs(current) do
						if not UnitExists(unit) then
							current[unit] = nil
						end
					end
				end
				if type(method) == "string" then
					self[method](self, current, unpack(bucket, 1, bucket.n))
				elseif method then -- function
					method(current, unpack(bucket, 1, bucket.n))
				end
				for k in pairs(current) do
					current[k] = nil
					k = nil
				end
				bucket.run = nil
			end
		end
	end
	bucket.id = "AceEvent-Bucket-" .. tostring(bucket)
	AceEvent.ScheduleRepeatingEvent(self, bucket.id, bucketfunc, delay, bucket)
end

function AceEvent:IsBucketEventRegistered(event)
	AceEvent:argCheck(event, 2, "string", "table")
	return AceEvent.buckets and AceEvent.buckets[event] and AceEvent.buckets[event][self]
end

function AceEvent:UnregisterBucketEvent(event)
	AceEvent:argCheck(event, 2, "string", "table")
	if not AceEvent.buckets or not AceEvent.buckets[event] or not AceEvent.buckets[event][self] then
		AceEvent:error("Cannot unregister bucket event %q. %q is not registered with it.", event, self)
	end

	local bucket = AceEvent.buckets[event][self]

	if type(event) == "string" then
		AceEvent.UnregisterEvent(self, event)
	else
		for _,v in ipairs(event) do
			AceEvent.UnregisterEvent(self, v)
		end
	end
	AceEvent:CancelScheduledEvent(bucket.id)

	bucket.current = nil
	AceEvent.buckets[event][self] = nil
	if not next(AceEvent.buckets[event]) then
		AceEvent.buckets[event] = del(AceEvent.buckets[event])
	end
end

function AceEvent:UnregisterAllBucketEvents()
	if not AceEvent.buckets or not next(AceEvent.buckets) then
		return
	end
	for k,v in pairs(AceEvent.buckets) do
		if v == self then
			AceEvent.UnregisterBucketEvent(self, k)
			k = nil
		end
	end
end

local combatSchedules
function AceEvent:CancelAllCombatSchedules()
	local i = 0
	while true do
		i = i + 1
		if not combatSchedules[i] then
			break
		end
		local v = combatSchedules[i]
		if v.self == self then
			v = del(v)
			table.remove(combatSchedules, i)
			i = i - 1
		end
	end
end

local inCombat = false

function AceEvent:PLAYER_REGEN_DISABLED()
	inCombat = true
end

do
	local tmp = {}
	function AceEvent:PLAYER_REGEN_ENABLED()
		inCombat = false
		for i, v in ipairs(combatSchedules) do
			tmp[i] = v
			combatSchedules[i] = nil
		end
		for i, v in ipairs(tmp) do
			local func = v.func
			if func then
				local success, err = pcall(func, unpack(v, 1, v.n))
				if not success then geterrorhandler()(err:find("%.lua:%d+:") and err or (debugstack():match("(.-: )in.-\n") or "") .. err) end
			else
				local obj = v.obj or v.self
				local method = v.method
				local obj_method = obj[method]
				if obj_method then
					local success, err = pcall(obj_method, obj, unpack(v, 1, v.n))
					if not success then geterrorhandler()(err:find("%.lua:%d+:") and err or (debugstack():match("(.-: )in.-\n") or "") .. err) end
				end
			end
			tmp[i] = del(v)
		end
	end
end

function AceEvent:ScheduleLeaveCombatAction(method, ...)
	local style = type(method)
	if self == AceEvent then
		if style == "table" then
			local func = (...)
			AceEvent:argCheck(func, 3, "string")
			if type(method[func]) ~= "function" then
				AceEvent:error("Cannot schedule a combat action to method %q, it does not exist", func)
			end
		else
			AceEvent:argCheck(method, 2, "function", --[[so message is right]] "table")
		end
		self = method
	else
		AceEvent:argCheck(method, 2, "function", "string", "table")
		if style == "string" and type(self[method]) ~= "function" then
			AceEvent:error("Cannot schedule a combat action to method %q, it does not exist", method)
		elseif style == "table" then
			local func = (...)
			AceEvent:argCheck(func, 3, "string")
			if type(method[func]) ~= "function" then
				AceEvent:error("Cannot schedule a combat action to method %q, it does not exist", func)
			end
		end
	end
	
	if not inCombat then
		local success, err
		if type(method) == "function" then
			success, err = pcall(method, ...)
		elseif type(method) == "table" then
			local func = (...)
			success, err = pcall(method[func], method, select(2, ...))
		else
			success, err = pcall(self[method], self, ...)
		end
		if not success then geterrorhandler()(err:find("%.lua:%d+:") and err or (debugstack():match("(.-: )in.-\n") or "") .. err) end
		return
	end
	local t
	local n = select('#', ...)
	if style == "table" then
		t = new(select(2, ...))
		t.obj = method
		t.method = (...)
		t.n = n-1
	else
		t = new(...)
		t.n = n
		if style == "function" then
			t.func = method
		else
			t.method = method
		end
	end
	t.self = self
	table.insert(combatSchedules, t)
end

function AceEvent:OnEmbedDisable(target)
	self.UnregisterAllEvents(target)

	self.CancelAllScheduledEvents(target)

	self.UnregisterAllBucketEvents(target)

	self.CancelAllCombatSchedules(target)
end

function AceEvent:IsFullyInitialized()
	return self.postInit or false
end

local function activate(self, oldLib, oldDeactivate)
	AceEvent = self
	
	self.onceRegistry = oldLib and oldLib.onceRegistry or {}
	self.throttleRegistry = oldLib and oldLib.throttleRegistry or {}
	self.delayRegistry = oldLib and oldLib.delayRegistry or {}
	self.buckets = oldLib and oldLib.buckets or {}
	self.registry = oldLib and oldLib.registry or {}
	self.frame = oldLib and oldLib.frame or CreateFrame("Frame", "AceEvent20Frame")
	self.playerLogin = IsLoggedIn() and true
	self.postInit = oldLib and oldLib.postInit or self.playerLogin and ChatTypeInfo and ChatTypeInfo.WHISPER and ChatTypeInfo.WHISPER.r and true
	self.ALL_EVENTS = oldLib and oldLib.ALL_EVENTS or _G.newproxy()
	self.FAKE_NIL = oldLib and oldLib.FAKE_NIL or _G.newproxy()
	self.RATE = oldLib and oldLib.RATE or _G.newproxy()
	self.combatSchedules = oldLib and oldLib.combatSchedules or {}
	self.UID_NUM = oldLib and oldLib.UID_NUM or 0
	
	combatSchedules = self.combatSchedules
	ALL_EVENTS = self.ALL_EVENTS
	FAKE_NIL = self.FAKE_NIL
	RATE = self.RATE
	local inPlw = false
	local blacklist = {
		UNIT_INVENTORY_CHANGED = true,
		BAG_UPDATE = true,
		ITEM_LOCK_CHANGED = true,
		ACTIONBAR_SLOT_CHANGED = true,
	}
	self.frame:SetScript("OnEvent", function(_, event, ...)
		if event == "PLAYER_ENTERING_WORLD" then
			inPlw = false
		elseif event == "PLAYER_LEAVING_WORLD" then
			inPlw = true
		end
		if event and (not inPlw or not blacklist[event]) then
			self:TriggerEvent(event, ...)
		end
	end)
	if self.delayRegistry then
		delayRegistry = self.delayRegistry
		self.frame:SetScript("OnUpdate", OnUpdate)
	end

	self:UnregisterAllEvents()
	self:CancelAllScheduledEvents()

	local function handleFullInit()
		if not self.postInit then
			local function func()
				self.postInit = true
				self:TriggerEvent("AceEvent_FullyInitialized")
				if self.registry["CHAT_MSG_CHANNEL_NOTICE"] and self.registry["CHAT_MSG_CHANNEL_NOTICE"][self] then
					self:UnregisterEvent("CHAT_MSG_CHANNEL_NOTICE")
				end
				if self.registry["MEETINGSTONE_CHANGED"] and self.registry["MEETINGSTONE_CHANGED"][self] then
					self:UnregisterEvent("MEETINGSTONE_CHANGED")
				end
			end
			registeringFromAceEvent = true
			self:RegisterEvent("MEETINGSTONE_CHANGED", func, true)
			self:RegisterEvent("CHAT_MSG_CHANNEL_NOTICE", func, true)

			self:ScheduleEvent("AceEvent_FullyInitialized", func, 10)
			registeringFromAceEvent = nil
		end
	end
	
	if not self.playerLogin then
		registeringFromAceEvent = true
		self:RegisterEvent("PLAYER_LOGIN", function()
			self.playerLogin = true
			handleFullInit()
			handleFullInit = nil
		end, true)
		registeringFromAceEvent = nil
	else
		handleFullInit()
		handleFullInit = nil
	end

	if not AceEvent20EditBox then
	    CreateFrame("Editbox", "AceEvent20EditBox")
	end
	local editbox = AceEvent20EditBox
	function editbox:Execute(line)
		local defaulteditbox = DEFAULT_CHAT_FRAME.editBox
		self:SetAttribute("chatType", defaulteditbox:GetAttribute("chatType"))
		self:SetAttribute("tellTarget", defaulteditbox:GetAttribute("tellTarget"))
		self:SetAttribute("channelTarget", defaulteditbox:GetAttribute("channelTarget"))
		self:SetText(line)
		ChatEdit_SendText(self)
	end
	editbox:Hide()
	_G["SLASH_IN1"] = "/in"
	SlashCmdList["IN"] = function(msg)
		local seconds, command, rest = msg:match("^([^%s]+)%s+(/[^%s]+)(.*)$")
		seconds = tonumber(seconds)
		if not seconds then
			DEFAULT_CHAT_FRAME:AddMessage("Error, bad arguments to /in. Must be in the form of `/in 5 /say hi'")
			return
		end
		if IsSecureCmd(command) then
			DEFAULT_CHAT_FRAME:AddMessage(("Error, /in cannot call secure command: %s"):format(command))
			return
		end
		self:ScheduleEvent("AceEventSlashIn-" .. math.random(1, 1000000000), editbox.Execute, seconds, editbox, command .. rest)
	end

	registeringFromAceEvent = true
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	self:RegisterEvent("LOOT_OPENED", function()
		SendAddonMessage("LOOT_OPENED", "", "RAID")
	end)
	inCombat = InCombatLockdown()
	registeringFromAceEvent = nil
	
	self:activate(oldLib, oldDeactivate)
	if oldLib then
		oldDeactivate(oldLib)
	end
end

AceLibrary:Register(AceEvent, MAJOR_VERSION, MINOR_VERSION, activate)
