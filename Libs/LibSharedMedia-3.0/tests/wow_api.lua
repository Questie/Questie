local _G = getfenv(0)

local donothing = function() end

local frames = {} -- Stores globally created frames, and their internal properties.

local FrameClass = {} -- A class for creating frames.
FrameClass.methods = { "SetScript", "RegisterEvent", "UnregisterEvent", "UnregisterAllEvents", "Show", "Hide", "IsShown" }
function FrameClass:New()
	local frame = {}
	for i,method in ipairs(self.methods) do
		frame[method] = self[method]
	end
	local frameProps = {
		events = {},
		scripts = {},
		timer = GetTime(),
		isShow = true
	}
	return frame, frameProps
end
function FrameClass:SetScript(script,handler)
	frames[self].scripts[script] = handler
end
function FrameClass:RegisterEvent(event)
	frames[self].events[event] = true
end
function FrameClass:UnregisterEvent(event)
	frames[self].events[event] = nil
end
function FrameClass:UnregisterAllEvents(frame)
	for event in pairs(frames[self].events) do
		frames[self].events[event] = nil
	end
end
function FrameClass:Show()
	frames[self].isShow = true
end
function FrameClass:Hide()
	frames[self].isShow = false
end
function FrameClass:IsShown()
	return frames[self].isShow
end



function CreateFrame(kind, name, parent)
	local frame,internal = FrameClass:New()
	frames[frame] = internal
	if name then
		_G[name] = frame
	end
	return frame
end

function UnitName(unit)
	return unit
end

function GetRealmName()
	return "Realm Name"
end

function UnitClass(unit)
	return "Warrior", "WARRIOR"
end

function UnitHealthMax()
	return 100
end

function UnitHealth()
	return 50
end

function GetNumRaidMembers()
	return 1
end

function GetNumPartyMembers()
	return 1
end

FACTION_HORDE = "Horde"
FACTION_ALLIANCE = "Alliance"

function UnitFactionGroup(unit)
	return "Horde", "Horde"
end

function UnitRace(unit)
	return "Undead", "Scourge"
end


_time = 0
function GetTime()
	return _time
end

function IsAddOnLoaded() return nil end

SlashCmdList = {}

function __WOW_Input(text)
	local a,b = string.find(text, "^/%w+")
	local arg, text = string.sub(text, a,b), string.sub(text, b + 2)
	for k,handler in pairs(SlashCmdList) do
		local i = 0
		while true do
			i = i + 1
			if not _G["SLASH_" .. k .. i] then
				break
			elseif _G["SLASH_" .. k .. i] == arg then
				handler(text)
				return
			end
		end
	end;
	print("No command found:", text)
end

local ChatFrameTemplate = {
	AddMessage = function(self, text)
		print((string.gsub(text, "|c%x%x%x%x%x%x%x%x(.-)|r", "%1")))
	end
}

for i=1,7 do
	local f = {}
	for k,v in pairs(ChatFrameTemplate) do
		f[k] = v
	end
	_G["ChatFrame"..i] = f
end
DEFAULT_CHAT_FRAME = ChatFrame1

debugstack = debug.traceback
date = os.date

function GetLocale()
	return "enUS"
end

function GetAddOnInfo()
	return
end

function GetNumAddOns()
	return 0
end

function getglobal(k)
	return _G[k]
end

function setglobal(k, v)
	_G[k] = v
end

local function _errorhandler(msg)
	print("--------- geterrorhandler error -------\n"..msg.."\n-----end error-----\n")
end

function geterrorhandler() 
	return _errorhandler
end

function InCombatLockdown()
	return false
end

function IsLoggedIn()
	return false
end

function GetFramerate()
	return 60
end

time = os.clock

strmatch = string.match

function SendAddonMessage(prefix, message, distribution, target)
	assert(#prefix + #message < 255,
	       string.format("SendAddonMessage: message too long (%d bytes)",
			     #prefix + #message))
	-- CHAT_MSG_ADDON(prefix, message, distribution, sender)
	WoWAPI_FireEvent("CHAT_MSG_ADDON", prefix, message, distribution, "Sender")
end

function hooksecurefunc(func_name, post_hook_func)
	local orig_func = _G[func_name]

	_G[func_name] = function (...)
				local ret = { orig_func(...) }		-- yeahyeah wasteful, see if i care, it's a test framework
				post_hook_func(...)
				return unpack(ret)
			end
end

RED_FONT_COLOR_CODE = ""
GREEN_FONT_COLOR_CODE = ""

StaticPopupDialogs = {}

function WoWAPI_FireEvent(event,...)
	for frame, props in pairs(frames) do
		if props.events[event] then
			if props.scripts["OnEvent"] then
				for i=1,select('#',...) do
					_G["arg"..i] = select(i,...)
				end
				_G.event=event
				props.scripts["OnEvent"](frame,event,...)
			end
		end
	end
end

function WoWAPI_FireUpdate(forceNow)
	if forceNow then
		_time = forceNow
	end
	local now = GetTime()
	for frame,props in pairs(frames) do
		if props.isShow and props.scripts.OnUpdate then
			_G.arg1=now-props.timer
			props.scripts.OnUpdate(frame,now-props.timer)
			props.timer = now
		end
	end
end




-- utility function for "dumping" a number of arguments (return a string representation of them)
function dump(...)
	local t = {}
	for i=1,select("#", ...) do
		local v = select(i, ...)
		if type(v)=="string" then
			tinsert(t, string.format("%q", v))
		else
			tinsert(t, tostring(v))
		end
	end
	return "<"..table.concat(t, "> <")..">"
end
