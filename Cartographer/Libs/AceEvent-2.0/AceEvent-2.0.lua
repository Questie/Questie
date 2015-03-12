--[[
Name: AceEvent-2.0
Revision: $Rev: 14125 $
Developed by: The Ace Development Team (http://www.wowace.com/index.php/The_Ace_Development_Team)
Inspired By: Ace 1.x by Turan (turan@gryphon.com)
Website: http://www.wowace.com/
Documentation: http://www.wowace.com/index.php/AceEvent-2.0
SVN: http://svn.wowace.com/root/trunk/Ace2/AceEvent-2.0
Description: Mixin to allow for event handling, scheduling, and inter-addon
             communication.
Dependencies: AceLibrary, AceOO-2.0
]]

local MAJOR_VERSION = "AceEvent-2.0"
local MINOR_VERSION = "$Revision: 14125 $"

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
					   }

local table_setn
do
	local version = GetBuildInfo()
	if string.find(version, "^2%.") then
		-- 2.0.0
		table_setn = function() end
	else
		table_setn = table.setn
	end
end

local weakKey = {__mode="k"}
local new, del
do
	local list = setmetatable({}, weakKey)
	function new()
		local t = next(list)
		if t then
			list[t] = nil
			return t
		else
			return {}
		end
	end

	function del(t)
		setmetatable(t, nil)
		for k in pairs(t) do
			t[k] = nil
		end
		list[t] = true
	end
end

local FAKE_NIL
local RATE

local eventsWhichHappenOnce = {
	PLAYER_LOGIN = true,
	AceEvent_FullyInitialized = true,
	VARIABLES_LOADED = true,
	PLAYER_LOGOUT = true,
}

local registeringFromAceEvent
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
			AceEvent.onceRegistry = new()
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
			AceEvent.throttleRegistry = new()
			AceEvent_throttleRegistry = AceEvent.throttleRegistry
		end
		if not AceEvent_throttleRegistry[event] then
			AceEvent_throttleRegistry[event] = new()
		end
		if AceEvent_throttleRegistry[event][self] then
			AceEvent_throttleRegistry[event][self] = del(AceEvent_throttleRegistry[event][self])
		end
		AceEvent_throttleRegistry[event][self] = setmetatable(new(), weakKey)
		local t = AceEvent_throttleRegistry[event][self]
		t[RATE] = throttleRate
	else
		if AceEvent_throttleRegistry and AceEvent_throttleRegistry[event] then
			if AceEvent_throttleRegistry[event][self] then
				AceEvent_throttleRegistry[event][self] = del(AceEvent_throttleRegistry[event][self])
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

	AceEvent_registry[ALL_EVENTS][self] = method
end

local _G = getfenv(0)
local memstack, timestack = {}, {}
local memdiff, timediff
function AceEvent:TriggerEvent(event, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19, a20)
	AceEvent:argCheck(event, 2, "string")
	local AceEvent_registry = AceEvent.registry
	if (not AceEvent_registry[event] or not next(AceEvent_registry[event])) and (not AceEvent_registry[ALL_EVENTS] or not next(AceEvent_registry[ALL_EVENTS])) then
		return
	end
	local _G_event = _G.event
	_G.event = event

	local AceEvent_onceRegistry = AceEvent.onceRegistry
	local AceEvent_debugTable = AceEvent.debugTable
	if AceEvent_onceRegistry and AceEvent_onceRegistry[event] then
		local tmp = new()
		for obj, method in pairs(AceEvent_onceRegistry[event]) do
			tmp[obj] = AceEvent_registry[event] and AceEvent_registry[event][obj] or nil
		end
		local obj = next(tmp)
		while obj do
			local mem, time
			if AceEvent_debugTable then
				if not AceEvent_debugTable[event] then
					AceEvent_debugTable[event] = new()
				end
				if not AceEvent_debugTable[event][obj] then
					AceEvent_debugTable[event][obj] = new()
					AceEvent_debugTable[event][obj].mem = 0
					AceEvent_debugTable[event][obj].time = 0
					AceEvent_debugTable[event][obj].count = 0
				end
				if memdiff then
					table.insert(memstack, memdiff)
					table.insert(timestack, timediff)
				end
				memdiff, timediff = 0, 0
				mem, time = gcinfo(), GetTime()
			end
			local method = tmp[obj]
			AceEvent.UnregisterEvent(obj, event)
			if type(method) == "string" then
				local obj_method = obj[method]
				if obj_method then
					obj_method(obj, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19, a20)
				end
			elseif method then -- function
				method(a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19, a20)
			end
			if AceEvent_debugTable then
				local dmem, dtime = memdiff, timediff
				mem, time = gcinfo() - mem - memdiff, GetTime() - time - timediff
				AceEvent_debugTable[event][obj].mem = AceEvent_debugTable[event][obj].mem + mem
				AceEvent_debugTable[event][obj].time = AceEvent_debugTable[event][obj].time + time
				AceEvent_debugTable[event][obj].count = AceEvent_debugTable[event][obj].count + 1

				memdiff, timediff = table.remove(memstack), table.remove(timestack)
				if memdiff then
					memdiff = memdiff + mem + dmem
					timediff = timediff + time + dtime
				end
			end
			tmp[obj] = nil
			obj = next(tmp)
		end
		del(tmp)
	end

	local AceEvent_throttleRegistry = AceEvent.throttleRegistry
	local throttleTable = AceEvent_throttleRegistry and AceEvent_throttleRegistry[event]
	if AceEvent_registry[event] then
		local tmp = new()
		for obj, method in pairs(AceEvent_registry[event]) do
			tmp[obj] = method
		end
		local obj = next(tmp)
		while obj do
			local method = tmp[obj]
			local continue = false
			if throttleTable and throttleTable[obj] then
				local a1 = a1
				if a1 == nil then
					a1 = FAKE_NIL
				end
				if not throttleTable[obj][a1] or GetTime() - throttleTable[obj][a1] >= throttleTable[obj][RATE] then
					throttleTable[obj][a1] = GetTime()
				else
					continue = true
				end
			end
			if not continue then
				local mem, time
				if AceEvent_debugTable then
					if not AceEvent_debugTable[event] then
						AceEvent_debugTable[event] = new()
					end
					if not AceEvent_debugTable[event][obj] then
						AceEvent_debugTable[event][obj] = new()
						AceEvent_debugTable[event][obj].mem = 0
						AceEvent_debugTable[event][obj].time = 0
						AceEvent_debugTable[event][obj].count = 0
					end
					if memdiff then
						table.insert(memstack, memdiff)
						table.insert(timestack, timediff)
					end
					memdiff, timediff = 0, 0
					mem, time = gcinfo(), GetTime()
				end
				if type(method) == "string" then
					local obj_method = obj[method]
					if obj_method then
						obj_method(obj, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19, a20)
					end
				elseif method then -- function
					method(a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19, a20)
				end
				if AceEvent_debugTable then
					local dmem, dtime = memdiff, timediff
					mem, time = gcinfo() - mem - memdiff, GetTime() - time - timediff
					AceEvent_debugTable[event][obj].mem = AceEvent_debugTable[event][obj].mem + mem
					AceEvent_debugTable[event][obj].time = AceEvent_debugTable[event][obj].time + time
					AceEvent_debugTable[event][obj].count = AceEvent_debugTable[event][obj].count + 1

					memdiff, timediff = table.remove(memstack), table.remove(timestack)
					if memdiff then
						memdiff = memdiff + mem + dmem
						timediff = timediff + time + dtime
					end
				end
			end
			tmp[obj] = nil
			obj = next(tmp)
		end
		del(tmp)
	end
	if AceEvent_registry[ALL_EVENTS] then
		local tmp = new()
		for obj, method in pairs(AceEvent_registry[ALL_EVENTS]) do
			tmp[obj] = method
		end
		local obj = next(tmp)
		while obj do
			local method = tmp[obj]
			local mem, time
			if AceEvent_debugTable then
				if not AceEvent_debugTable[event] then
					AceEvent_debugTable[event] = new()
				end
				if not AceEvent_debugTable[event][obj] then
					AceEvent_debugTable[event][obj] = new()
					AceEvent_debugTable[event][obj].mem = 0
					AceEvent_debugTable[event][obj].time = 0
					AceEvent_debugTable[event][obj].count = 0
				end
				if memdiff then
					table.insert(memstack, memdiff)
					table.insert(timestack, timediff)
				end
				memdiff, timediff = 0, 0
				mem, time = gcinfo(), GetTime()
			end
			if type(method) == "string" then
				local obj_method = obj[method]
				if obj_method then
					obj_method(obj, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19, a20)
				end
			elseif method then -- function
				method(a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19, a20)
			end
			if AceEvent_debugTable then
				local dmem, dtime = memdiff, timediff
				mem, time = gcinfo() - mem - memdiff, GetTime() - time - timediff
				AceEvent_debugTable[event][obj].mem = AceEvent_debugTable[event][obj].mem + mem
				AceEvent_debugTable[event][obj].time = AceEvent_debugTable[event][obj].time + time
				AceEvent_debugTable[event][obj].count = AceEvent_debugTable[event][obj].count + 1

				memdiff, timediff = table.remove(memstack), table.remove(timestack)
				if memdiff then
					memdiff = memdiff + mem + dmem
					timediff = timediff + time + dtime
				end
			end
			tmp[obj] = nil
			obj = next(tmp)
		end
		del(tmp)
	end
	_G.event = _G_event
end

-- local accessors
local getn = table.getn
local tinsert = table.insert
local tremove = table.remove
local floor = math.floor
local GetTime = GetTime
local next = next
local pairs = pairs
local unpack = unpack

local delayRegistry
local function OnUpdate()
	local t = GetTime()
	local k,v = next(delayRegistry)
	local last = nil
	while k do
		local v_time = v.time
		if not v_time then
			delayRegistry[k] = del(v)
		elseif v_time <= t then
			local v_repeatDelay = v.repeatDelay
			if v_repeatDelay then
				-- use the event time, not the current time, else timing inaccuracies add up over time
				v.time = v_time + v_repeatDelay
			end
			local event = v.event
			local mem, time
			if AceEvent_debugTable then
				mem, time = gcinfo(), GetTime()
			end
			if type(event) == "function" then
				event(unpack(v))
			else
				AceEvent:TriggerEvent(event, unpack(v))
			end
			if AceEvent_debugTable then
				mem, time = gcinfo() - mem, GetTime() - time
				v.mem = v.mem + mem
				v.timeSpent = v.timeSpent + time
				v.count = v.count + 1
			end
			if not v_repeatDelay then
				local x = delayRegistry[k]
				if x and x.time == v_time then -- check if it was manually reset
					delayRegistry[k] = del(v)
				end
			end
		end
		if delayRegistry[k] then
			last = k
		end
		k,v = next(delayRegistry, last)
	end
	if not next(delayRegistry) then
		AceEvent.frame:Hide()
	end
end

local function ScheduleEvent(self, repeating, event, delay, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19, a20)
	local id
	if type(event) == "string" or type(event) == "table" then
		if type(event) == "table" then
			if not delayRegistry or not delayRegistry[event] then
				AceEvent:error("Bad argument #2 to `ScheduleEvent'. Improper id table fed in.")
			end
		end
		if type(delay) ~= "number" then
			id, event, delay, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19, a20 = event, delay, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19, a20
			AceEvent:argCheck(event, 3, "string", "function", --[[ so message is right ]] "number")
			AceEvent:argCheck(delay, 4, "number")
			self:CancelScheduledEvent(id)
		end
	else
		AceEvent:argCheck(event, 2, "string", "function")
		AceEvent:argCheck(delay, 3, "number")
	end

	if not delayRegistry then
		AceEvent.delayRegistry = new()
		delayRegistry = AceEvent.delayRegistry
		AceEvent.frame:SetScript("OnUpdate", OnUpdate)
	end
	local t
	if type(id) == "table" then
		for k in pairs(id) do
			id[k] = nil
		end
		t = id
	else
		t = new()
	end
	t[1] = a1
	t[2] = a2
	t[3] = a3
	t[4] = a4
	t[5] = a5
	t[6] = a6
	t[7] = a7
	t[8] = a8
	t[9] = a9
	t[10] = a10
	t[11] = a11
	t[12] = a12
	t[13] = a13
	t[14] = a14
	t[15] = a15
	t[16] = a16
	t[17] = a17
	t[18] = a18
	t[19] = a19
	t[20] = a20
	table_setn(t, 20)
	t.event = event
	t.time = GetTime() + delay
	t.self = self
	t.id = id or t
	t.repeatDelay = repeating and delay
	if AceEvent_debugTable then
		t.mem = 0
		t.count = 0
		t.timeSpent = 0
	end
	delayRegistry[t.id] = t
	AceEvent.frame:Show()
	return t.id
end

function AceEvent:ScheduleEvent(event, delay, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19, a20)
	if type(event) == "string" or type(event) == "table" then
		if type(event) == "table" then
			if not delayRegistry or not delayRegistry[event] then
				AceEvent:error("Bad argument #2 to `ScheduleEvent'. Improper id table fed in.")
			end
		end
		if type(delay) ~= "number" then
			AceEvent:argCheck(delay, 3, "string", "function", --[[ so message is right ]] "number")
			AceEvent:argCheck(a1, 4, "number")
		end
	else
		AceEvent:argCheck(event, 2, "string", "function")
		AceEvent:argCheck(delay, 3, "number")
	end

	return ScheduleEvent(self, false, event, delay, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19, a20)
end

function AceEvent:ScheduleRepeatingEvent(event, delay, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19, a20)
	if type(event) == "string" or type(event) == "table" then
		if type(event) == "table" then
			if not delayRegistry or not delayRegistry[event] then
				AceEvent:error("Bad argument #2 to `ScheduleEvent'. Improper id table fed in.")
			end
		end
		if type(delay) ~= "number" then
			AceEvent:argCheck(delay, 3, "string", "function", --[[ so message is right ]] "number")
			AceEvent:argCheck(a1, 4, "number")
		end
	else
		AceEvent:argCheck(event, 2, "string", "function")
		AceEvent:argCheck(delay, 3, "number")
	end

	return ScheduleEvent(self, true, event, delay, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19, a20)
end

function AceEvent:CancelScheduledEvent(t)
	AceEvent:argCheck(t, 2, "string", "table")
	if delayRegistry then
		local v = delayRegistry[t]
		if v then
			delayRegistry[t] = del(v)
			if not next(delayRegistry) then
				AceEvent.frame:Hide()
			end
			return true
		end
	end
	return false
end

function AceEvent:IsEventScheduled(t)
	AceEvent:argCheck(t, 2, "string", "table")
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
			AceEvent_throttleRegistry[event][self] = del(AceEvent_throttleRegistry[event][self])
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
			error(string.format("Cannot unregister event %q. Improperly unregistering from AceEvent-2.0.", event), 2)
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
			del(AceEvent_registry[ALL_EVENTS])
			AceEvent.frame:UnregisterAllEvents()
			for k,v in pairs(AceEvent_registry) do
				if k ~= ALL_EVENTS then
					AceEvent.frame:RegisterEvent(k)
				end
			end
			AceEvent_registry[event] = nil
		end
	end
	local first = true
	for event, data in pairs(AceEvent_registry) do
		if first then
			if AceEvent_registry.AceEvent_EventUnregistered then
				event = "AceEvent_EventUnregistered"
			else
				first = false
			end
		end
		local x = data[self]
		data[self] = nil
		if x and event ~= ALL_EVENTS then
			if not next(data) then
				del(data)
				if not AceEvent_registry[ALL_EVENTS] or not next(AceEvent_registry[ALL_EVENTS]) then
					AceEvent.frame:UnregisterEvent(event)
				end
				AceEvent_registry[event] = nil
			end
			AceEvent:TriggerEvent("AceEvent_EventUnregistered", self, event)
		end
		if first then
			event = nil
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
				delayRegistry[k] = del(v)
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
		return AceEvent_registry[event] and next(AceEvent_registry[event]) and true or false
	end
	if AceEvent_registry[event] and AceEvent_registry[event][self] then
		return true, AceEvent_registry[event][self]
	end
	return false, nil
end

local bucketfunc
function AceEvent:RegisterBucketEvent(event, delay, method)
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
	if not AceEvent.buckets then
		AceEvent.buckets = new()
	end
	if not AceEvent.buckets[event] then
		AceEvent.buckets[event] = new()
	end
	if not AceEvent.buckets[event][self] then
		AceEvent.buckets[event][self] = new()
		AceEvent.buckets[event][self].current = new()
		AceEvent.buckets[event][self].self = self
	else
		AceEvent.CancelScheduledEvent(self, AceEvent.buckets[event][self].id)
	end
	local bucket = AceEvent.buckets[event][self]
	bucket.method = method

	local func = function(arg1)
		bucket.run = true
		if arg1 then
			bucket.current[arg1] = true
		end
	end
	AceEvent.buckets[event][self].func = func
	if type(event) == "string" then
		AceEvent.RegisterEvent(self, event, func)
	else
		for _,v in ipairs(event) do
			AceEvent.RegisterEvent(self, v, func)
		end
	end
	if not bucketfunc then
		bucketfunc = function(bucket)
			local current = bucket.current
			local method = bucket.method
			local self = bucket.self
			if bucket.run then
				if type(method) == "string" then
					self[method](self, current)
				elseif method then -- function
					method(current)
				end
				for k in pairs(current) do
					current[k] = nil
					k = nil
				end
				bucket.run = false
			end
		end
	end
	bucket.id = AceEvent.ScheduleRepeatingEvent(self, bucketfunc, delay, bucket)
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

	del(bucket.current)
	AceEvent.buckets[event][self] = del(AceEvent.buckets[event][self])
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

function AceEvent:OnEmbedDisable(target)
	self.UnregisterAllEvents(target)

	self.CancelAllScheduledEvents(target)

	self.UnregisterAllBucketEvents(target)
end

function AceEvent:EnableDebugging()
	if not self.debugTable then
		self.debugTable = new()

		if delayRegistry then
			for k,v in pairs(self.delayRegistry) do
				if not v.mem then
					v.mem = 0
					v.count = 0
					v.timeSpent = 0
				end
			end
		end
	end
end

function AceEvent:IsFullyInitialized()
	return self.postInit or false
end

function AceEvent:IsPostPlayerLogin()
	return self.playerLogin or false
end

function AceEvent:activate(oldLib, oldDeactivate)
	AceEvent = self

	if oldLib then
		self.onceRegistry = oldLib.onceRegistry
		self.throttleRegistry = oldLib.throttleRegistry
		self.delayRegistry = oldLib.delayRegistry
		self.buckets = oldLib.buckets
		self.registry = oldLib.registry
		self.frame = oldLib.frame
		self.debugTable = oldLib.debugTable
		self.playerLogin = oldLib.pew or DEFAULT_CHAT_FRAME and DEFAULT_CHAT_FRAME.defaultLanguage and true
		self.postInit = oldLib.postInit or self.playerLogin and ChatTypeInfo and ChatTypeInfo.WHISPER and ChatTypeInfo.WHISPER.r and true
		self.ALL_EVENTS = oldLib.ALL_EVENTS
		self.FAKE_NIL = oldLib.FAKE_NIL
		self.RATE = oldLib.RATE
	end
	if not self.registry then
		self.registry = {}
	end
	if not self.frame then
		self.frame = CreateFrame("Frame", "AceEvent20Frame")
	end
	if not self.ALL_EVENTS then
		self.ALL_EVENTS = {}
	end
	if not self.FAKE_NIL then
		self.FAKE_NIL = {}
	end
	if not self.RATE then
		self.RATE = {}
	end
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
	self.frame:SetScript("OnEvent", function()
		local event = event
		if event == "PLAYER_ENTERING_WORLD" then
			inPlw = false
		elseif event == "PLAYER_LEAVING_WORLD" then
			inPlw = true
		end
		if event and (not inPlw or not blacklist[event]) then
			self:TriggerEvent(event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9)
		end
	end)
	if self.delayRegistry then
		delayRegistry = self.delayRegistry
		self.frame:SetScript("OnUpdate", OnUpdate)
	end

	self:UnregisterAllEvents()
	self:CancelAllScheduledEvents()

	registeringFromAceEvent = true
	self:RegisterEvent("LOOT_OPENED", function()
		SendAddonMessage("LOOT_OPENED", "", "RAID")
	end)
	registeringFromAceEvent = nil

	if not self.playerLogin then
		registeringFromAceEvent = true
		self:RegisterEvent("PLAYER_LOGIN", function()
			self.playerLogin = true
		end, true)
		registeringFromAceEvent = nil
	end

	if not self.postInit then
		local isReload = true
		local function func()
			self.postInit = true
			self:TriggerEvent("AceEvent_FullyInitialized")
			if self.registry["CHAT_MSG_CHANNEL_NOTICE"] and self.registry["CHAT_MSG_CHANNEL_NOTICE"][self] then
				self:UnregisterEvent("CHAT_MSG_CHANNEL_NOTICE")
			end
			if self.registry["MEETINGSTONE_CHANGED"] and self.registry["MEETINGSTONE_CHANGED"][self] then
				self:UnregisterEvent("MEETINGSTONE_CHANGED")
			end
			if self.registry["MINIMAP_ZONE_CHANGED"] and self.registry["MINIMAP_ZONE_CHANGED"][self] then
				self:UnregisterEvent("MINIMAP_ZONE_CHANGED")
			end
			if self.registry["LANGUAGE_LIST_CHANGED"] and self.registry["LANGUAGE_LIST_CHANGED"][self] then
				self:UnregisterEvent("LANGUAGE_LIST_CHANGED")
			end
		end
		registeringFromAceEvent = true
		local f = function()
			self.playerLogin = true
			self:ScheduleEvent("AceEvent_FullyInitialized", func, 1)
		end
		self:RegisterEvent("MEETINGSTONE_CHANGED", f, true)
		self:RegisterEvent("CHAT_MSG_CHANNEL_NOTICE", function()
			self:ScheduleEvent("AceEvent_FullyInitialized", func, 0.05)
		end)
		self:RegisterEvent("LANGUAGE_LIST_CHANGED", function()
			if self.registry["MEETINGSTONE_CHANGED"] and self.registry["MEETINGSTONE_CHANGED"][self] then
				self:UnregisterEvent("MEETINGSTONE_CHANGED")
				self:RegisterEvent("MINIMAP_ZONE_CHANGED", f, true)
			end
		end)
		registeringFromAceEvent = nil
	end

	self.super.activate(self, oldLib, oldDeactivate)
	if oldLib then
		oldDeactivate(oldLib)
	end
end

AceLibrary:Register(AceEvent, MAJOR_VERSION, MINOR_VERSION, AceEvent.activate)
AceEvent = AceLibrary(MAJOR_VERSION)
