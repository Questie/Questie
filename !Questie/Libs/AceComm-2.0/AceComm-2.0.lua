--[[
Name: AceComm-2.0
Revision: $Rev: 1091 $
Developed by: The Ace Development Team (http://www.wowace.com/index.php/The_Ace_Development_Team)
Inspired By: Ace 1.x by Turan (turan@gryphon.com)
Website: http://www.wowace.com/
Documentation: http://www.wowace.com/index.php/AceComm-2.0
SVN: http://svn.wowace.com/wowace/trunk/Ace2/AceComm-2.0
Description: Mixin to allow for inter-player addon communications.
Dependencies: AceLibrary, AceOO-2.0, AceEvent-2.0,
              ChatThrottleLib by Mikk (included)
License: LGPL v2.1
]]

local MAJOR_VERSION = "AceComm-2.0"
local MINOR_VERSION = 90000 + tonumber(("$Revision: 1091 $"):match("(%d+)"))

if not AceLibrary then error(MAJOR_VERSION .. " requires AceLibrary") end
if not AceLibrary:IsNewVersion(MAJOR_VERSION, MINOR_VERSION) then return end

if not AceLibrary:HasInstance("AceOO-2.0") then error(MAJOR_VERSION .. " requires AceOO-2.0") end

local WotLK = select(4,GetBuildInfo()) >= 30000

local AceOO = AceLibrary("AceOO-2.0")
local AceComm = AceOO.Mixin {
	"SendCommMessage",
	"SendPrioritizedCommMessage",
	"RegisterComm",
	"UnregisterComm",
	"UnregisterAllComms",
	"IsCommRegistered",
	"SetDefaultCommPriority",
	"SetCommPrefix",
	"RegisterMemoizations",
	"IsUserInChannel",
}

AceComm.hooks = {}

local AceEvent

local byte_a = ("a"):byte()
local byte_z = ("z"):byte()
local byte_A = ("A"):byte()
local byte_Z = ("Z"):byte()
local byte_deg = ("\176"):byte()

local byte_b = ("b"):byte()
local byte_B = ("B"):byte()
local byte_nil = ("/"):byte()
local byte_plus = ("+"):byte()
local byte_minus = ("-"):byte()
local byte_d = ("d"):byte()
local byte_D = ("D"):byte()
local byte_e = ("e"):byte()
local byte_E = ("E"):byte()
local byte_m = ("m"):byte()
local byte_s = ("s"):byte()
local byte_S = ("S"):byte()
local byte_o = ("o"):byte()
local byte_O = ("O"):byte()
local byte_t = ("t"):byte()
local byte_T = ("T"):byte()
local byte_u = ("u"):byte()
local byte_U = ("U"):byte()
local byte_v = ("v"):byte()
local byte_V = ("V"):byte()
local byte_i = ("i"):byte()
local byte_I = ("I"):byte()
local byte_inf = ("@"):byte()
local byte_ninf = ("$"):byte()
local byte_nan = ("!"):byte()

local fake_nil = {}

local inf = 1/0
local nan = 0/0

local _G = getfenv(0)

local ChatThrottleLib = _G.ChatThrottleLib

local math_floor = _G.math.floor
local string_char = _G.string.char
local math_min = _G.math.min
local table_concat = _G.table.concat
local type = _G.type
local unpack = _G.unpack
local pairs = _G.pairs
local next = _G.next
local select = _G.select
local setmetatable = _G.setmetatable
local GetTime = _G.GetTime
local AceLibrary = _G.AceLibrary
local GetChannelName = _G.GetChannelName
local LeaveChannelByName = _G.LeaveChannelByName
local JoinChannelByName = _G.JoinChannelByName
local GetRealZoneText = _G.GetRealZoneText
local GetChannelList = _G.GetChannelList
local tostring = _G.tostring
local ListChannelByName = _G.ListChannelByName
local tonumber = _G.tonumber
local math_frexp = _G.math.frexp
local math_ldexp = _G.math.ldexp
local GetItemInfo = _G.GetItemInfo
local error = _G.error
local pcall = _G.pcall
local GetNumRaidMembers = _G.GetNumRaidMembers
local GetNumPartyMembers = _G.GetNumPartyMembers
local UnitInRaid = _G.UnitInRaid
local IsInGuild = _G.IsInGuild
local GetCVar = _G.GetCVar
local SetCVar = _G.SetCVar
local IsResting = _G.IsResting
local rawget = _G.rawget
local GetAddOnMetadata = _G.GetAddOnMetadata
local IsAddOnLoaded = _G.IsAddOnLoaded
local geterrorhandler = _G.geterrorhandler
local hooksecurefunc = _G.hooksecurefunc
local GetFramerate = _G.GetFramerate
local IsInInstance = _G.IsInInstance

local player = UnitName("player")

local new, del
do
	local list = setmetatable({},{__mode='k'})
	function new(...)
		local t = next(list)
		if t then
			list[t] = nil
			for i = 1, select('#', ...) do
				t[i] = select(i, ...)
			end
			return t
		else
			return {...}
		end
	end
	function del(t)
		for k in pairs(t) do
			t[k] = nil
		end
		t[''] = true
		t[''] = nil
		list[t] = true
		return nil
	end
end

local NumericCheckSum, HexCheckSum
local TailoredNumericCheckSum, TailoredBinaryCheckSum
do
	function NumericCheckSum(text)
		local counter = 1
		local len = text:len()
		for i = 1, len, 3 do
			counter = (counter*8257 % 16777259) +
				(text:byte(i)) +
				((text:byte(i+1) or 1)*127) +
				((text:byte(i+2) or 2)*16383)
		end
		return counter % 16777213
	end
	
	function HexCheckSum(text)
		return ("%06x"):format(NumericCheckSum(text))
	end
	
	function TailoredNumericCheckSum(text)
		local hash = NumericCheckSum(text)
		local a = math_floor(hash / 256^2)
		local b = math_floor(hash / 256) % 256
		local c = hash % 256
		-- \000, \n, |, \176, s, S, \015, \020
		if a == 0 or a == 10 or a == 124 or a == 176 or a == 115 or a == 83 or a == 15 or a == 20 or a == 37 then
			a = a + 1
		-- \t, \255
		elseif a == 9 or a == 255 then
			a = a - 1
		end
		if b == 0 or b == 10 or b == 124 or b == 176 or b == 115 or b == 83 or b == 15 or b == 20 or b == 37 then
			b = b + 1
		elseif b == 9 or b == 255 then
			b = b - 1
		end
		if c == 0 or c == 10 or c == 124 or c == 176 or c == 115 or c == 83 or c == 15 or c == 20 or c == 37 then
			c = c + 1
		elseif c == 9 or c == 255 then
			c = c - 1
		end
		return a * 256^2 + b * 256 + c
	end
	
	function TailoredBinaryCheckSum(text)
		local num = TailoredNumericCheckSum(text)
		return string_char(math_floor(num / 256^2), math_floor(num / 256) % 256, num % 256)
	end
end

local function IsInChannel(chan)
	return GetChannelName(chan) ~= 0
end

local Encode, EncodeByte, EncodeBytes
do
	local drunkHelper_t = {
		[29] = "\029\030",
		[31] = "\029\032",
		[20] = "\029\021",
		[15] = "\029\016",
		[("S"):byte()] = "\020", -- change S and s to a different set of character bytes.
		[("s"):byte()] = "\015",
		[127] = "\029\126", -- \127 (this is here because \000 is more common)
		[0] = "\127", -- \000
		[10] = "\029\011", -- \n
		[124] = "\029\125", -- |
		[("%"):byte()] = "\029\038", -- %
	}
	for c = 128, 255 do
		local num = c
		num = num - 127
		if num >= 9 then
			num = num + 2
		end
		if num >= 29 then
			num = num + 2
		end
		if num >= 128 then
			drunkHelper_t[c] = string_char(29, num - 127) -- 1, 2, 3, 4, 5
		else
			drunkHelper_t[c] = string_char(31, num)
		end
	end
	local function drunkHelper(char)
		return drunkHelper_t[char:byte()]
	end
	local soberHelper_t = {
		[176] = "\176\177",
		[255] = "\176\254", -- \255 (this is here because \000 is more common)
		[0] = "\255", -- \000
		[10] = "\176\011", -- \n
		[124] = "\176\125", -- |
		[("%"):byte()] = "\176\038", -- %
	}
	local function soberHelper(char)
		return soberHelper_t[char:byte()]
	end
	-- Package a message for transmission
	function Encode(text, drunk)
		if drunk then
			return text:gsub("([\010\015\020\029%%\031Ss\124\127-\255])", drunkHelper)
		else
			if not text then
				DEFAULT_CHAT_FRAME:AddMessage(debugstack())
			end
			return text:gsub("([\176\255%z\010\124%%])", soberHelper)
		end
	end
	
	function EncodeByte(num, drunk)
		local t
		if drunk then
			t = drunkHelper_t
		else
			t = soberHelper_t
		end
		
		local value = t[num]
		if value then
			return value
		else
			return string_char(num)
		end
	end
	
	local function EncodeBytes_helper(drunk, ...)
		local n = select('#', ...)
		if n == 0 then
			return
		end
		local t
		if drunk then
			t = drunkHelper_t
		else
			t = soberHelper_t
		end
		local num = (...)
		local value = t[num]
		if not value then
			return num, EncodeBytes_helper(drunk, select(2, ...))
		else
			local len = #value
			if len == 1 then
				return value:byte(1), EncodeBytes_helper(drunk, select(2, ...))
			else -- 2
				local a, b = value:byte(1, 2)
				return a, b, EncodeBytes_helper(drunk, select(2, ...))
			end
		end
	end
	function EncodeBytes(drunk, ...)
		return string_char(EncodeBytes_helper(drunk, ...))
	end
end

local Decode
do
	local t = {
		["\177"] = "\176",
		["\254"] = "\255",
		["\011"] = "\010",
		["\125"] = "\124",
		["\038"] = "\037",
	}
	local function soberHelper(text)
		return t[text]
	end
	
	local t = {
		["\127"] = "\000",
		["\015"] = "s",
		["\020"] = "S",
	}
	local function drunkHelper1(text)
		return t[text]
	end
	
	local t = setmetatable({}, {__index=function(self, c)
		local num = c:byte()
		if num >= 29 then
			num = num - 2
		end
		if num >= 9 then
			num = num - 2
		end
		num = num + 127
		self[c] = string_char(num)
		return self[c]
	end})
	local function drunkHelper2(text)
		return t[text]
	end

	local t = {
		["\038"] = "%",
		["\125"] = "\124",
		["\011"] = "\010",
		["\126"] = "\127",
		["\016"] = "\015",
		["\021"] = "\020",
		["\001"] = "\251",
		["\002"] = "\252",
		["\003"] = "\253",
		["\004"] = "\254",
		["\005"] = "\255",
		["\032"] = "\031",
		["\030"] = "\029",
	}
	local function drunkHelper3(text)
		return t[text]
	end
	
	-- Clean a received message
	function Decode(text, drunk)
		if drunk then
			text = text:gsub("^(.*)\029.-$", "%1")
			-- get rid of " ...hic!"
			
			text = text:gsub("([\127\015\020])", drunkHelper1)
			text = text:gsub("\031(.)", drunkHelper2)
			text = text:gsub("\029([\038\125\011\126\016\021\001\002\003\004\005\032\030])", drunkHelper3)
		else
			text = text:gsub("\255", "\000")
		
			text = text:gsub("\176([\177\254\011\125\038])", soberHelper)
		end
		-- remove the hidden character and refix the prohibited characters.
		return text
	end
end

local lastChannelJoined

function AceComm.hooks:JoinChannelByName(orig, channel, ...)
	lastChannelJoined = channel
	return orig(channel, ...)
end

local function JoinChannel(channel)
	if not IsInChannel(channel) then
		LeaveChannelByName(channel)
		AceComm:ScheduleEvent("AceComm-JoinChannelByName-" .. channel, JoinChannelByName, 0, channel)
	end
end

local function LeaveChannel(channel)
	if IsInChannel(channel) then
		LeaveChannelByName(channel)
	end
end

local switches = {}

local function SwitchChannel(former, latter)
	if IsInChannel(former) then
		LeaveChannelByName(former)
		local t = new()
		t.former = former
		t.latter = latter
		switches[t] = true
		return
	end
	if not IsInChannel(latter) then
		JoinChannelByName(latter)
	end
end

local shutdown = false

local zoneCache
local function GetCurrentZoneChannel()
	if not zoneCache then
		zoneCache = "AceCommZone" .. HexCheckSum(GetRealZoneText())
	end
	return zoneCache
end

local AceComm_registry

local function SupposedToBeInChannel(chan)
	if not chan:find("^AceComm") then
		return true
	elseif shutdown or not AceEvent:IsFullyInitialized() then
		return false
	end
	
	if chan == "AceComm" then
		return AceComm_registry.GLOBAL and next(AceComm_registry.GLOBAL) and true or false
	elseif chan:find("^AceCommZone%x%x%x%x%x%x$") then
		if chan == GetCurrentZoneChannel() then
			return AceComm_registry.ZONE and next(AceComm_registry.ZONE) and true or false
		else
			return false
		end
	else
		return AceComm_registry.CUSTOM and AceComm_registry.CUSTOM[chan] and next(AceComm_registry.CUSTOM[chan]) and true or false
	end
end

local function checkChannelList(...)
	for i = 2, select("#", ...), 2 do
		local c = select(i, ...)
		if c and not SupposedToBeInChannel(c) then
			LeaveChannelByName(c)
		end
	end
end
local function LeaveAceCommChannels(noShutdown)
	if not noShutdown then
		shutdown = true
	end
	checkChannelList(GetChannelList())
end

local lastRefix = 0
local function RefixAceCommChannelsAndEvents()
	if GetTime() - lastRefix <= 5 then
		AceComm:ScheduleEvent("AceComm-RefixAceCommChannelsAndEvents", RefixAceCommChannelsAndEvents, GetTime() - lastRefix)
		return
	end
	lastRefix = GetTime()
	LeaveAceCommChannels(true)
	
	local channel = false
	if SupposedToBeInChannel("AceComm") then
		JoinChannel("AceComm")
		channel = true
	end
	if SupposedToBeInChannel(GetCurrentZoneChannel()) then
		JoinChannel(GetCurrentZoneChannel())
		channel = true
	end
	if AceComm_registry.CUSTOM then
		for k,v in pairs(AceComm_registry.CUSTOM) do
			if next(v) and SupposedToBeInChannel(k) then
				JoinChannel(k)
				channel = true
			end
		end
	end
	if AceComm_registry.WHISPER or AceComm_registry.GROUP or AceComm_registry.PARTY or AceComm_registry.RAID or AceComm_registry.BATTLEGROUND or AceComm_registry.GUILD then
		if not AceComm:IsEventRegistered("CHAT_MSG_ADDON") then
			AceComm:RegisterEvent("CHAT_MSG_ADDON")
		end
	else
		if AceComm:IsEventRegistered("CHAT_MSG_ADDON") then
			AceComm:UnregisterEvent("CHAT_MSG_ADDON")
		end
	end
	
	if channel then
		if not AceComm:IsEventRegistered("CHAT_MSG_CHANNEL") then
			AceComm:RegisterEvent("CHAT_MSG_CHANNEL")
		end
		if not AceComm:IsEventRegistered("CHAT_MSG_CHANNEL_LIST") then
			AceComm:RegisterEvent("CHAT_MSG_CHANNEL_LIST")
		end
		if not AceComm:IsEventRegistered("CHAT_MSG_CHANNEL_JOIN") then
			AceComm:RegisterEvent("CHAT_MSG_CHANNEL_JOIN")
		end
		if not AceComm:IsEventRegistered("CHAT_MSG_CHANNEL_LEAVE") then
			AceComm:RegisterEvent("CHAT_MSG_CHANNEL_LEAVE")
		end
	else
		if AceComm:IsEventRegistered("CHAT_MSG_CHANNEL") then
			AceComm:UnregisterEvent("CHAT_MSG_CHANNEL")
		end
		if AceComm:IsEventRegistered("CHAT_MSG_CHANNEL_LIST") then
			AceComm:UnregisterEvent("CHAT_MSG_CHANNEL_LIST")
		end
		if AceComm:IsEventRegistered("CHAT_MSG_CHANNEL_JOIN") then
			AceComm:UnregisterEvent("CHAT_MSG_CHANNEL_JOIN")
		end
		if AceComm:IsEventRegistered("CHAT_MSG_CHANNEL_LEAVE") then
			AceComm:UnregisterEvent("CHAT_MSG_CHANNEL_LEAVE")
		end
	end
end


do
	local myFunc = function(k)
		if not IsInChannel(k.latter) then
			JoinChannelByName(k.latter)
		end
		switches[k] = del(k)
	end
	
	function AceComm:CHAT_MSG_CHANNEL_NOTICE(kind, _, _, deadName, _, _, _, num, channel)
		if kind == "YOU_LEFT" then
			if not channel:find("^AceComm") then
				return
			end
			for k in pairs(switches) do
				if k.former == channel then
					self:ScheduleEvent("AceComm-Join-" .. k.latter, myFunc, 0, k)
				end
			end
			if channel == "AceComm" then
				self:TriggerEvent("AceComm_LeftChannel", "GLOBAL")
			elseif channel == GetCurrentZoneChannel() then
				self:TriggerEvent("AceComm_LeftChannel", "ZONE")
			else
				self:TriggerEvent("AceComm_LeftChannel", "CUSTOM", channel:sub(8))
			end
			if SupposedToBeInChannel(channel) then
				self:ScheduleEvent("AceComm-JoinChannel-" .. channel, JoinChannel, 0, channel)
			end
			if self.userRegistry[channel] then
				self.userRegistry[channel] = del(self.userRegistry[channel])
			end
		elseif kind == "YOU_JOINED" then
			if not (num == 0 and deadName or channel):find("^AceComm") then
				return
			end
			if num == 0 then
				self:ScheduleEvent("AceComm-LeaveChannelByName-" .. deadName, LeaveChannelByName, 0, deadName)
				local t = new()
				t.former = deadName
				t.latter = deadName
				switches[t] = true
			elseif channel == "AceComm" then
				self:TriggerEvent("AceComm_JoinedChannel", "GLOBAL")
			elseif channel == GetCurrentZoneChannel() then
				self:TriggerEvent("AceComm_JoinedChannel", "ZONE")
			else
				self:TriggerEvent("AceComm_JoinedChannel", "CUSTOM", channel:sub(8))
			end
			if num ~= 0 then
				if not SupposedToBeInChannel(channel) then
					LeaveChannel(channel)
				else
					ListChannelByName(channel)
				end
			end
		end
	end
end

local SerializeAndEncode
do
	local recurse = {}
	local function _Serialize(v, textToHash, sb, drunk)
		local kind = type(v)
		-- Note that the ordering of these if/elseif's matters, don't
		-- change it unless you know what you're doing.
		if kind == "boolean" then
			if v then
				sb[#sb+1] = "B" -- true
				return 1
			else
				sb[#sb+1] = "b" -- false
				return 1
			end
		elseif not v or v == fake_nil then
			sb[#sb+1] = "/" -- nil
			return 1
		elseif kind == "number" then
			-- v == math_floor(v) will also return true if
			-- v is 1/0 or -1/0, so we need to check that first.
			-- Thanks to Xinhuan for finding the problem.
			if v == inf then
				sb[#sb+1] = "@"
				return 1
			elseif v == -inf then
				sb[#sb+1] = "$"
				return 1
			elseif v == math_floor(v) then
				if v <= 2^7-1 and v >= -2^7 then
					if v < 0 then
						v = v + 256
					end
					sb[#sb+1] = "d"
					sb[#sb+1] = EncodeByte(v, drunk)
					return 2
				elseif v <= 2^15-1 and v >= -2^15 then
					if v < 0 then
						v = v + 256^2
					end
					sb[#sb+1] = "D"
					sb[#sb+1] = EncodeBytes(drunk, math_floor(v / 256), v % 256)
					return 3
				elseif v <= 2^31-1 and v >= -2^31 then
					if v < 0 then
						v = v + 256^4
					end
					sb[#sb+1] = "e"
					sb[#sb+1] = EncodeBytes(drunk, math_floor(v / 256^3), math_floor(v / 256^2) % 256, math_floor(v / 256) % 256, v % 256)
					return 5
				elseif v <= 2^63-1 and v >= -2^63 then
					if v < 0 then
						v = v + 256^8
					end
					sb[#sb+1] = "E"
					sb[#sb+1] = EncodeBytes(drunk, math_floor(v / 256^7), math_floor(v / 256^6) % 256, math_floor(v / 256^5) % 256, math_floor(v / 256^4) % 256, math_floor(v / 256^3) % 256, math_floor(v / 256^2) % 256, math_floor(v / 256) % 256, v % 256)
					return 9
				end
			elseif v ~= v then -- not a number
				sb[#sb+1] = "!"
				return 1
			end
			local sign = v < 0 or v == 0 and tostring(v) == "-0"
			if sign then
				v = -v
			end
			local m, exp = math_frexp(v)
			m = m * 2^53
			local x = exp + 1023
			local b = m % 256
			local c = math_floor(m / 256) % 256
			m = math_floor(m / 256^2)
			m = m + x * 2^37
			sb[#sb+1] = sign and "-" or "+"
			sb[#sb+1] = EncodeBytes(drunk, math_floor(m / 256^5) % 256, math_floor(m / 256^4) % 256, math_floor(m / 256^3) % 256, math_floor(m / 256^2) % 256, math_floor(m / 256) % 256, m % 256, c, b)
			return 9
		elseif kind == "string" then
			local hash = textToHash and textToHash[v]
			if hash then
				sb[#sb+1] = "m"
				sb[#sb+1] = EncodeBytes(drunk, math_floor(hash / 256^2), math_floor(hash / 256) % 256, hash % 256)
				return 4
			end
			local r,g,b,A,B,C,D,E,F,G,H,name = v:match("^|cff(%x%x)(%x%x)(%x%x)|Hitem:(%d+):(%d+):(%d+):(%d+):(%d+):(%d+):(%-?%d+):(%d+)|h%[(.+)%]|h|r$")
			if A then
				-- item link
				
				A = A+0 -- convert to number
				B = B+0
				C = C+0
				D = D+0
				E = E+0
				F = F+0
				G = G+0
				H = H+0
				r = tonumber(r, 16)
				g = tonumber(g, 16)
				b = tonumber(b, 16)
				
				-- (1-35000):(1-3093):(1-3093):(1-3093):(1-3093):(?):(-57 to 2164):(0-4294967295)
				
				F = nil -- don't care
				if G < 0 then
					G = G + 256^2 -- handle negatives
				end
				
				H = H % 256^2 -- only lower 16 bits matter
				
				sb[#sb+1] = "I"
				sb[#sb+1] = EncodeBytes(drunk, r, g, b, math_floor(A / 256) % 256, A % 256, math_floor(B / 256) % 256, B % 256, math_floor(C / 256) % 256, C % 256, math_floor(D / 256) % 256, D % 256, math_floor(E / 256) % 256, E % 256, math_floor(G / 256) % 256, G % 256, math_floor(H / 256) % 256, H % 256, math_min(name:len(), 255))
				sb[#sb+1] = Encode(name:sub(1, 255), drunk)
				return 19 + math_min(name:len(), 255)
			else
				-- normal string
				local len = v:len()
				if len <= 255 then
					sb[#sb+1] = "s"
					sb[#sb+1] = EncodeByte(len, drunk)
					sb[#sb+1] = Encode(v, drunk)
					return 2 + len
				else
					sb[#sb+1] = "S"
					sb[#sb+1] = EncodeBytes(drunk, math_floor(len / 256), len % 256)
					sb[#sb+1] = Encode(v, drunk)
					return 3 + len
				end
			end
		elseif kind == "function" then
			AceComm:error("Cannot serialize a function")
		elseif kind == "table" then
			if recurse[v] then
				for k in pairs(recurse) do
					recurse[k] = nil
				end
				AceComm:error("Cannot serialize a recursive table")
				return 0
			end
			recurse[v] = true
			if AceOO.inherits(v, AceOO.Class) then
				if not v.class then
					AceComm:error("Cannot serialize an AceOO class, can only serialize objects")
				elseif type(v.Serialize) ~= "function" then
					AceComm:error("Cannot serialize an AceOO object without the `Serialize' method.")
				elseif type(v.class.Deserialize) ~= "function" then
					AceComm:error("Cannot serialize an AceOO object without the `Deserialize' static method.")
				elseif type(v.class.GetLibraryVersion) ~= "function" or not AceLibrary:HasInstance(v.class:GetLibraryVersion()) then
					AceComm:error("Cannot serialize an AceOO object if the class is not registered with AceLibrary.")
				end
				local classHash = TailoredBinaryCheckSum(v.class:GetLibraryVersion())
				local t = new(classHash, v:Serialize())
				local sb_id = #sb+1
				sb[#sb+1] = "" -- dummy
				sb[#sb+1] = "" -- dummy
				local len = 0
				local num = 0
				for i = 2, #t do
					len = len + _Serialize(t[i], textToHash, sb, drunk)
					num = num + 1
				end
				t = del(t)
				for k in pairs(recurse) do
					recurse[k] = nil
				end
				if num <= 255 then
					sb[sb_id] = "o"
					sb[sb_id+1] = EncodeByte(num, drunk)
					return 2 + len
				else
					sb[sb_id] = "O"
					sb[sb_id+1] = EncodeBytes(drunk, math_floor(num / 256), num % 256)
					return 3 + len
				end
			end
			local islist = false
			local n = #v
			if n >= 1 then
				islist = true
				for k,u in pairs(v) do
					if type(k) ~= "number" or k < 1 or k > n then
						islist = false
						break
					end
				end
			end
			local isset = true
			for k, v in pairs(v) do
				if v ~= true then
					isset = false
					break
				end
			end
			local sb_id = #sb+1
			sb[#sb+1] = "" -- dummy
			sb[#sb+1] = "" -- dummy
			local len = 0
			local num = 0
			if islist then
				num = n
				for i = 1, n do
					len = len + _Serialize(v[i], textToHash, sb, drunk)
				end
			elseif isset then
				for k in pairs(v) do
					len = len + _Serialize(k, textToHash, sb, drunk)
					num = num + 1
				end
			else
				for k,u in pairs(v) do
					len = len + _Serialize(k, textToHash, sb, drunk)
					len = len + _Serialize(u, textToHash, sb, drunk)
					num = num + 1
				end
			end
			for k in pairs(recurse) do
				recurse[k] = nil
			end
			if islist then
				if num <= 255 then
					sb[sb_id] = "u"
					sb[sb_id+1] = EncodeByte(num, drunk)
					return 2 + len
				else
					sb[sb_id] = "U"
					sb[sb_id+1] = EncodeBytes(drunk, math_floor(num / 256), num % 256)
					return 3 + len
				end
			elseif isset then
				if num <= 255 then
					sb[sb_id] = "v"
					sb[sb_id+1] = EncodeByte(num, drunk)
					return 2 + len
				else
					sb[sb_id] = "V"
					sb[sb_id+1] = EncodeBytes(drunk, math_floor(num / 256), num % 256)
					return 3 + len
				end
			else
				if num <= 255 then
					sb[sb_id] = "t"
					sb[sb_id+1] = EncodeByte(num, drunk)
					return 2 + len
				else
					sb[sb_id] = "T"
					sb[sb_id+1] = EncodeBytes(drunk, math_floor(num / 256), num % 256)
					return 3 + len
				end
			end	
		end
	end
	
	function SerializeAndEncode(value, textToHash, drunk)
		local sb = new()
		sb[1] = ""
		sb[2] = ""
		_Serialize(value, textToHash, sb, drunk)
		-- expect a table, chop off the initial byte.
		for i = 1, #sb do
			if #sb[i] > 0 then
				sb[i] = sb[i]:sub(2)
				break
			end
		end
		local len = 0
		for i = 1, #sb do
			len = len + #sb[i]
		end
		for k in pairs(recurse) do
			recurse[k] = nil
		end
		return sb, len
	end
end

local Deserialize
do
	local function _Deserialize(value, position, hashToText)
		if not position then
			position = 1
		end
		local x = value:byte(position)
		if x == byte_b then
			-- false
			return false, position
		elseif x == byte_B then
			-- true
			return true, position
		elseif x == byte_nil then
			-- nil
			return nil, position
		elseif x == byte_i then
			-- 14-byte item link
			local a1, a2, b1, b2, c1, c2, d1, d2, e1, e2, g1, g2, h1, h2 = value:byte(position + 1, position + 14)
			local A = a1 * 256 + a2
			local B = b1 * 256 + b2
			local C = c1 * 256 + c2
			local D = d1 * 256 + d2
			local E = e1 * 256 + e2
			local G = g1 * 256 + g2
			local H = h1 * 256 + h2
			if G >= 2^15 then
				G = G - 256^2
			end
			local s = ("item:%d:%d:%d:%d:%d:%d:%d:%d"):format(A, B, C, D, E, 0, G, H)
			local _, link = GetItemInfo(s)
			return link, position + 14
		elseif x == byte_I then
			-- long item link
			local r, g, b, a1, a2, b1, b2, c1, c2, d1, d2, e1, e2, g1, g2, h1, h2, len = value:byte(position + 1, position + 18)
			local A = a1 * 256 + a2
			local B = b1 * 256 + b2
			local C = c1 * 256 + c2
			local D = d1 * 256 + d2
			local E = e1 * 256 + e2
			local G = g1 * 256 + g2
			local H = h1 * 256 + h2
			if G >= 2^15 then
				G = G - 256^2
			end
			local s = ("item:%d:%d:%d:%d:%d:%d:%d:%d"):format(A, B, C, D, E, 0, G, H)
			local _, link = GetItemInfo(s)
			if not link then
				local name = value:sub(position + 19, position + 18 + len)
				
				link = ("|cff%02x%02x%02x|Hitem:%d:%d:%d:%d:%d:%d:%d:%d|h[%s]|h|r"):format(r, g, b, A, B, C, D, E, 0, G, H, name)
			end
			return link, position + 18 + len
		elseif x == byte_m then
			local a, b, c = value:byte(position + 1, position + 3)
			local hash = a * 256^2 + b * 256 + c
			return hashToText[hash], position + 3
		elseif x == byte_s then
			-- 0-255-byte string
			local len = value:byte(position + 1)
			return value:sub(position + 2, position + 1 + len), position + 1 + len
		elseif x == byte_S then
			-- 256-65535-byte string
			local a, b = value:byte(position + 1, position + 2)
			local len = a * 256 + b
			return value:sub(position + 3, position + 2 + len), position + 2 + len
		elseif x == 64 --[[byte_inf]] then
			return inf, position
		elseif x == 36 --[[byte_ninf]] then
			return -inf, position
		elseif x == 33 --[[byte_nan]] then
			return nan, position
		elseif x == byte_d then
			-- 1-byte integer
			local a = value:byte(position + 1)
			if a >= 128 then
				a = a - 256
			end
			return a, position + 1
		elseif x == byte_D then
			-- 2-byte integer
			local a, b = value:byte(position + 1, position + 2)
			local N = a * 256 + b
			if N >= 2^15 then
				N = N - 256^2
			end
			return N, position + 2
		elseif x == byte_e then
			-- 4-byte integer
			local a, b, c, d = value:byte(position + 1, position + 4)
			local N = a * 256^3 + b * 256^2 + c * 256 + d
			if N >= 2^31 then
				N = N - 256^4
			end
			return N, position + 4
		elseif x == byte_E then
			-- 8-byte integer
			local a, b, c, d, e, f, g, h = value:byte(position + 1, position + 8)
			local N = a * 256^7 + b * 256^6 + c * 256^5 + d * 256^4 + e * 256^3 + f * 256^2 + g * 256 + h
			if N >= 2^63 then
				N = N - 2^64
			end
			return N, position + 8
		elseif x == byte_plus or x == byte_minus then	
			local a, b, c, d, e, f, g, h = value:byte(position + 1, position + 8)
			local N = a * 256^5 + b * 256^4 + c * 256^3 + d * 256^2 + e * 256 + f
			local sign = x
			local x = math_floor(N / 2^37)
			local m = (N % 2^37) * 256^2 + g * 256 + h
			local mantissa = m / 2^53
			local exp = x - 1023
			local val = math_ldexp(mantissa, exp)
			if sign == byte_minus then
				return -val, position + 8
			end
			return val, position + 8
		elseif x == byte_u or x == byte_U then
			-- numerically-indexed table
			-- byte #2 is element-length, not byte-length
			local start
			local num
			if x == byte_u then
				num = value:byte(position + 1)
				start = position + 2
			else
				local a, b = value:byte(position + 1, position + 2)
				num = a * 256 + b
				start = position + 3
			end
			local t = new()
			local curr = start - 1
			for i = 1, num do
				local v
				v, curr = _Deserialize(value, curr + 1, hashToText)
				t[i] = v
			end
			return t, curr
		elseif x == byte_v or x == byte_V then
			-- set-style table
			local start
			local num
			if x == byte_v then
				num = value:byte(position + 1)
				start = position + 2
			else
				local a, b = value:byte(position + 1, position + 2)
				num = a * 256 + b
				start = position + 3
			end
			local t = new()
			local curr = start - 1
			for i = 1, num do
				local v
				v, curr = _Deserialize(value, curr + 1, hashToText)
				t[v] = true
			end
			return t, curr
		elseif x == byte_o or x == byte_O then
			-- numerically-indexed table
			-- byte #2 is element-length, not byte-length
			local start
			local num
			if x == byte_o then
				num = value:byte(position + 1)
				start = position + 2
			else
				local a, b = value:byte(position + 1, position + 2)
				num = a * 256 + b
				start = position + 3
			end
			local a, b, c = value:byte(start, start + 3)
			local hash = a * 256^2 + b * 256 + c
			local curr = start + 2
			local class = AceComm.classes[hash]
			local tmp = new()
			for i = 1, num do
				local v
				v, curr = _Deserialize(value, curr + 1, hashToText)
				tmp[i] = v
			end
			local object
			if class and type(class.Deserialize) == "function" and type(class.prototype.Serialize) == "function" then
				object = class:Deserialize(unpack(tmp, 1, num))
			end
			tmp = del(tmp)
			return object, curr+1
		elseif x == byte_t or x == byte_T then
			-- table
			-- byte #2 is element-length, not byte-length
			local start
			local num
			if x == byte_t then
				num = value:byte(position + 1)
				start = position + 2
			else
				local a, b = value:byte(position + 1, position + 2)
				num = a * 256 + b
				start = position + 3
			end
			local t = new()
			local curr = start - 1
			for i = 1, num do
				local key, val
				key, curr = _Deserialize(value, curr + 1, hashToText)
				val, curr = _Deserialize(value, curr + 1, hashToText)
				t[key] = val
			end
			return t, curr
		else
			error(("Improper serialized value provided: %s"):format(x))
		end
	end

	function Deserialize(value, hashToText)
		-- prefix the table byte
		value = "u" .. value
		local ret,msg = pcall(_Deserialize, value, nil, hashToText)
		if ret then
			return msg
		end
	end
end

local function GetCurrentGroupDistribution()
	if select(2, IsInInstance()) == "pvp" or select(2, IsInInstance()) == "arena" then
		return "BATTLEGROUND"
	elseif UnitInRaid("player") then
		return "RAID"
	else
		return "PARTY"
	end
end

local function IsInDistribution(dist, customChannel)
	if dist == "GROUP" then
		return not not GetCurrentGroupDistribution()
	elseif dist == "BATTLEGROUND" then
		return select(2, IsInInstance()) == "pvp" or select(2, IsInInstance()) == "arena"
	elseif dist == "RAID" then
		return GetNumRaidMembers() > 0
	elseif dist == "PARTY" then
		return GetNumPartyMembers() > 0
	elseif dist == "GUILD" then
		return not not IsInGuild()
	elseif dist == "GLOBAL" then
		return IsInChannel("AceComm")
	elseif dist == "ZONE" then
		return IsInChannel(GetCurrentZoneChannel())
	elseif dist == "WHISPER" then
		return true
	elseif dist == "CUSTOM" then
		return IsInChannel(customChannel)
	end
	error("unknown distribution: " .. tostring(dist), 2)
end

function AceComm:RegisterComm(prefix, distribution, method, a4)
	AceComm:argCheck(prefix, 2, "string")
	AceComm:argCheck(distribution, 3, "string")
	if distribution ~= "GLOBAL" and distribution ~= "WHISPER" and distribution ~= "PARTY" and distribution ~= "RAID" and distribution ~= "GUILD" and distribution ~= "BATTLEGROUND" and distribution ~= "GROUP" and distribution ~= "ZONE" and distribution ~= "CUSTOM" then
		AceComm:error('Argument #3 to `RegisterComm\' must be either "GLOBAL", "ZONE", "WHISPER", "PARTY", "RAID", "GUILD", "BATTLEGROUND", "GROUP", or "CUSTOM". %q is not appropriate', distribution)
	end
	local customChannel
	if distribution == "CUSTOM" then
		customChannel, method = method, a4
		AceComm:argCheck(customChannel, 4, "string")
		if customChannel:len() == 0 then
			AceComm:error('Argument #4 to `RegisterComm\' must be a non-zero-length string.')
		elseif customChannel:find("%s") then
			AceComm:error('Argument #4 to `RegisterComm\' must not have spaces.')
		end
	end
	if self == AceComm then
		AceComm:argCheck(method, customChannel and 5 or 4, "function", "table")
		self = method
	else
		AceComm:argCheck(method, customChannel and 5 or 4, "string", "function", "table", "nil")
	end
	if not method then
		method = "OnCommReceive"
	end
	if type(method) == "string" and type(self[method]) ~= "function" and type(self[method]) ~= "table" then
		AceComm:error("Cannot register comm %q to method %q, it does not exist", prefix, method)
	end
	
	local registry = AceComm_registry
	if not registry[distribution] then
		registry[distribution] = new()
	end
	if customChannel then
		customChannel = "AceComm" .. customChannel
		if not registry[distribution][customChannel] then
			registry[distribution][customChannel] = new()
		end
		if not registry[distribution][customChannel][prefix] then
			registry[distribution][customChannel][prefix] = new()
		end
		registry[distribution][customChannel][prefix][self] = method
	else
		if not registry[distribution][prefix] then
			registry[distribution][prefix] = new()
		end
		registry[distribution][prefix][self] = method
	end
	
	RefixAceCommChannelsAndEvents()
end

function AceComm:UnregisterComm(prefix, distribution, customChannel)
	AceComm:argCheck(prefix, 2, "string")
	AceComm:argCheck(distribution, 3, "string", "nil")
	if distribution and distribution ~= "GLOBAL" and distribution ~= "WHISPER" and distribution ~= "PARTY" and distribution ~= "RAID" and distribution ~= "GUILD" and distribution ~= "BATTLEGROUND" and distribution ~= "GROUP" and distribution ~= "ZONE" and distribution ~= "CUSTOM" then
		AceComm:error('Argument #3 to `UnregisterComm\' must be either nil, "GLOBAL", "WHISPER", "PARTY", "RAID", "GUILD", "BATTLEGROUND", "GROUP", "ZONE", or "CUSTOM". %q is not appropriate', distribution)
	end
	if distribution == "CUSTOM" then
		AceComm:argCheck(customChannel, 3, "string")
		if customChannel:len() == 0 then
			AceComm:error('Argument #3 to `UnregisterComm\' must be a non-zero-length string.')
		end
	else
		AceComm:argCheck(customChannel, 3, "nil")
	end
	
	local registry = AceComm_registry
	if not distribution then
		for k,v in pairs(registry) do
			if k == "CUSTOM" then
				for l,u in pairs(v) do
					if u[prefix] and u[prefix][self] then
						AceComm.UnregisterComm(self, prefix, k, l:sub(8))
						if not registry[k] then
							break
						end
					end
				end
			else
				if v[prefix] and v[prefix][self] then
					AceComm.UnregisterComm(self, prefix, k)
				end
			end
		end
		return
	end
	if self == AceComm then
		if distribution == "CUSTOM" then
			error(("Cannot unregister comm %q::%q. Improperly unregistering from AceComm-2.0."):format(distribution, customChannel), 2)
		else
			error(("Cannot unregister comm %q. Improperly unregistering from AceComm-2.0."):format(distribution), 2)
		end
	end
	if distribution == "CUSTOM" then
		customChannel = "AceComm" .. customChannel
		if not registry[distribution] or not registry[distribution][customChannel] or not registry[distribution][customChannel][prefix] or not registry[distribution][customChannel][prefix][self] then
			AceComm:error("Cannot unregister comm %q. %q is not registered with it.", distribution, self)
		end
		registry[distribution][customChannel][prefix][self] = nil
		
		if not next(registry[distribution][customChannel][prefix]) then
			registry[distribution][customChannel][prefix] = del(registry[distribution][customChannel][prefix])
		end
		
		if not next(registry[distribution][customChannel]) then
			registry[distribution][customChannel] = del(registry[distribution][customChannel])
		end
	else
		if not registry[distribution] or not registry[distribution][prefix] or not registry[distribution][prefix][self] then
			AceComm:error("Cannot unregister comm %q. %q is not registered with it.", distribution, self)
		end
		registry[distribution][prefix][self] = nil
		
		if not next(registry[distribution][prefix]) then
			registry[distribution][prefix] = del(registry[distribution][prefix])
		end
	end
	
	if not next(registry[distribution]) then
		registry[distribution] = del(registry[distribution])
	end
	
	RefixAceCommChannelsAndEvents()
end

function AceComm:UnregisterAllComms()
	local registry = AceComm_registry
	for k, distribution in pairs(registry) do
		if k == "CUSTOM" then
			for l, channel in pairs(distribution) do
				local j = next(channel)
				while j ~= nil do
					local prefix = channel[j]
					if prefix[self] then
						AceComm.UnregisterComm(self, j)
						if distribution[l] and registry[k] then
							j = next(channel)
						else
							l = nil
							k = nil
							break
						end
					else
						j = next(channel, j)
					end
				end
				if k == nil then
					break
				end
			end
		else
			local j = next(distribution)
			while j ~= nil do
				local prefix = distribution[j]
				if prefix[self] then
					AceComm.UnregisterComm(self, j)
					if registry[k] then
						j = next(distribution)
					else
						k = nil
						break
					end
				else
					j = next(distribution, j)
				end
			end
		end
	end
end

function AceComm:IsCommRegistered(prefix, distribution, customChannel)
	AceComm:argCheck(prefix, 2, "string")
	AceComm:argCheck(distribution, 3, "string", "nil")
	if distribution and distribution ~= "GLOBAL" and distribution ~= "WHISPER" and distribution ~= "PARTY" and distribution ~= "RAID" and distribution ~= "GUILD" and distribution ~= "BATTLEGROUND" and distribution ~= "GROUP" and distribution ~= "ZONE" and distribution ~= "CUSTOM" then
		AceComm:error('Argument #3 to `IsCommRegistered\' must be either "GLOBAL", "WHISPER", "PARTY", "RAID", "GUILD", "BATTLEGROUND", "GROUP", "ZONE", or "CUSTOM". %q is not appropriate', distribution)
	end
	if distribution == "CUSTOM" then
		AceComm:argCheck(customChannel, 4, "nil", "string")
		if customChannel == "" then
			AceComm:error('Argument #4 to `IsCommRegistered\' must be a non-zero-length string or nil.')
		end
	else
		AceComm:argCheck(customChannel, 4, "nil")
	end
	local registry = AceComm_registry
	if not distribution then
		for k,v in pairs(registry) do
			if k == "CUSTOM" then
				for l,u in pairs(v) do
					if u[prefix] and u[prefix][self] then
						return true
					end
				end
			else
				if v[prefix] and v[prefix][self] then
					return true
				end
			end
		end
		return false
	elseif distribution == "CUSTOM" and not customChannel then
		if not registry[distribution] then
			return false
		end
		for l,u in pairs(registry[distribution]) do
			if u[prefix] and u[prefix][self] then
				return true
			end
		end
		return false
	elseif distribution == "CUSTOM" then
		customChannel = "AceComm" .. customChannel
		return registry[distribution] and registry[distribution][customChannel] and registry[distribution][customChannel][prefix] and registry[distribution][customChannel][prefix][self] and true or false
	end
	return registry[distribution] and registry[distribution][prefix] and registry[distribution][prefix][self] and true or false
end

function AceComm:OnEmbedDisable(target)
	self.UnregisterAllComms(target)
end

local id = byte_Z

local recentGuildMessage = 0
local firstGuildMessage = true
local stopGuildMessages = false

function AceComm:PLAYER_GUILD_UPDATE(arg1)
	if arg1 and arg1 ~= "player" then return end
	
	recentGuildMessage = 0
	firstGuildMessage = true
	stopGuildMessages = false
end

local function SendMessage(prefix, priority, distribution, person, message, textToHash)
	if distribution == "CUSTOM" then
		person = "AceComm" .. person
	end
	if not IsInDistribution(distribution, person) then
		return false
	end
	if distribution == "GROUP" then
		distribution = GetCurrentGroupDistribution()
	end
	if distribution == "GUILD" and stopGuildMessages then
		return false
	end
	if id == byte_Z then
		id = byte_a
	elseif id == byte_z then
		id = byte_A
	else
		id = id + 1
	end
	if id == byte_s or id == byte_S then
		id = id + 1
	end
	local drunk = distribution == "GLOBAL" or distribution == "ZONE" or distribution == "CUSTOM"
	prefix = Encode(prefix, drunk)
	local sb, messageLen = SerializeAndEncode(message, textToHash, drunk)
	local headerLen = prefix:len() + 6
	local max = math_floor(messageLen / (240 - headerLen) + 1)
	if max > 1 then
		local segment = math_floor(messageLen / max + 0.5)
		local last = 0
		local message = table_concat(sb)
		sb = del(sb)
		for i = 1, max do
			local bit
			if i == max then
				bit = message:sub(last + 1)
			else
				local next = segment * i
				if message:byte(next) == byte_deg then
					next = next + 1
				end
				bit = message:sub(last + 1, next)
				last = next
			end
			if distribution == "GLOBAL" or distribution == "ZONE" or distribution == "CUSTOM" then
				local channel
				if distribution == "GLOBAL" then
					channel = "AceComm"
				elseif distribution == "ZONE" then
					channel = GetCurrentZoneChannel()
				elseif distribution == "CUSTOM" then
					channel = person
				end
				local index = GetChannelName(channel)
				if index and index > 0 then
					local point
					if i == 1 then
						point = "b"
					elseif i == max then
						point = "d"
					else
						point = "c"
					end
					
					bit = prefix .. string_char(9 --[[\t]], id) .. point .. "-" .. bit .. "\029"
					ChatThrottleLib:SendChatMessage(priority, prefix, bit, "CHANNEL", nil, index)
				else
					return false
				end
			else
				local point
				if i == 1 then
					point = "b"
				elseif i == max then
					point = "d"
				else
					point = "c"
				end
				
				bit = string_char(id) .. point .. "-" .. bit
				ChatThrottleLib:SendAddonMessage(priority, prefix, bit, distribution, person)
			end
		end
		return true
	else
		if distribution == "GLOBAL" or distribution == "ZONE" or distribution == "CUSTOM" then
			local channel
			if distribution == "GLOBAL" then
				channel = "AceComm"
			elseif distribution == "ZONE" then
				channel = GetCurrentZoneChannel()
			elseif distribution == "CUSTOM" then
				channel = person
			end
			local index = GetChannelName(channel)
			if index and index > 0 then
				sb[1] = prefix
				sb[2] = string_char(9 --[[\t]], id, byte_a, byte_minus)
				sb[#sb+1] = "\029"
				local message = table_concat(sb)
				sb = del(sb)
				ChatThrottleLib:SendChatMessage(priority, prefix, message, "CHANNEL", nil, index)
				return true
			end
			sb = del(sb)
		else
			if distribution == "GUILD" and firstGuildMessage then
				firstGuildMessage = false
				if GetCVar("Sound_EnableErrorSpeech") == "1" then
					SetCVar("Sound_EnableErrorSpeech", "0")
					AceEvent:ScheduleEvent("AceComm-EnableErrorSpeech", SetCVar, 10, "Sound_EnableErrorSpeech", "1")
				end
				recentGuildMessage = GetTime() + 10
			end
			sb[1] = string_char(id, byte_a, byte_minus)
			local message = table_concat(sb)
			sb = del(sb)
			ChatThrottleLib:SendAddonMessage(priority, prefix, message, distribution, person)
			return true
		end
	end
	return false
end

function AceComm:SendPrioritizedCommMessage(priority, distribution, person, ...)
	AceComm:argCheck(priority, 2, "string")
	if priority ~= "NORMAL" and priority ~= "BULK" and priority ~= "ALERT" then
		AceComm:error('Priority for `Send[Prioritized]CommMessage\' must be either "NORMAL", "BULK", or "ALERT"')
	end
	AceComm:argCheck(distribution, 3, "string")
	local includePerson = true
	if distribution == "WHISPER" or distribution == "CUSTOM" then
		includePerson = false
		AceComm:argCheck(person, 4, "string")
		if person:len() == 0 then
			AceComm:error("Person for `Send[Prioritized]CommMessage' must be a non-zero-length string")
		end
	end
	if self == AceComm then
		AceComm:error("Cannot send a comm message from AceComm directly.")
	end
	if distribution and distribution ~= "GLOBAL" and distribution ~= "WHISPER" and distribution ~= "PARTY" and distribution ~= "RAID" and distribution ~= "GUILD" and distribution ~= "BATTLEGROUND" and distribution ~= "GROUP" and distribution ~= "ZONE" and distribution ~= "CUSTOM" then
		AceComm:error('Distribution for `Send[Prioritized]CommMessage\' must be either nil, "GLOBAL", "ZONE", "WHISPER", "PARTY", "RAID", "GUILD", "BATTLEGROUND", "GROUP", or "CUSTOM". %q is not appropriate', distribution)
	end
	
	local prefix = AceComm.commPrefixes[self]
	if type(prefix) ~= "string" then
		AceComm:error("`SetCommPrefix' must be called before sending a message.")
	end

	local message = new()
	if includePerson then message[1] = person end
	for i = 1, select('#', ...) do
		local x = select(i, ...)
		if type(x) == "nil" then x = fake_nil end
		message[includePerson and i + 1 or i] = x
	end
	if includePerson then person = nil end
	local ret = SendMessage(AceComm.prefixTextToHash[prefix], priority, distribution, person, message, self.commMemoTextToHash)
	message = del(message)
	return ret
end

function AceComm:SendCommMessage(...)
	return AceComm.SendPrioritizedCommMessage(self, self.commPriority or "NORMAL", ...)
end

function AceComm:SetDefaultCommPriority(priority)
	AceComm:argCheck(priority, 2, "string")
	if priority ~= "NORMAL" and priority ~= "BULK" and priority ~= "ALERT" then
		AceComm:error('Argument #2 must be either "NORMAL", "BULK", or "ALERT"')
	end
	
	self.commPriority = priority
end

function AceComm:SetCommPrefix(prefix)
	AceComm:argCheck(prefix, 2, "string")
	
	if AceComm.commPrefixes[self] then
		AceComm:error("Cannot call `SetCommPrefix' more than once.")
	end
	
	if AceComm.prefixes[prefix] then
		AceComm:error("Cannot set prefix to %q, it is already in use.", prefix)
	end
	
	local hash
	if prefix:len() == 3 then
		hash = prefix
	else
		hash = TailoredBinaryCheckSum(prefix)
	end
	if AceComm.prefixHashToText[hash] then
		AceComm:error("Cannot set prefix to %q, its hash is used by another prefix: %q", prefix, AceComm.prefixHashToText[hash])
	end
	
	AceComm.prefixes[prefix] = true
	self.commPrefix = prefix
	AceComm.commPrefixes[self] = prefix
	AceComm.prefixHashToText[hash] = prefix
	AceComm.prefixTextToHash[prefix] = hash
end

function AceComm:RegisterMemoizations(values, ...)
	AceComm:argCheck(values, 2, "table", "string")
	if type(values) == "string" then
		values = {values, ...}
		for i,v in ipairs(values) do
			if type(v) ~= "string" then
				AceComm:error("Bad argument #%d to `RegisterMemoizations'. Expected %q, got %q.", i+1, "string", type(v))
			end
		end
	else
		for k,v in pairs(values) do
			if type(k) ~= "number" then
				AceComm:error("Bad argument #2 to `RegisterMemoizations'. All keys must be numbers")
			elseif type(v) ~= "string" then
				AceComm:error("Bad argument #2 to `RegisterMemoizations'. All values must be strings")
			end
		end
	end
	if self.commMemoHashToText or self.commMemoTextToHash then
		AceComm:error("You can only call `RegisterMemoizations' once.")
	elseif not AceComm.commPrefixes[self] then
		AceComm:error("You can only call `SetCommPrefix' before calling `RegisterMemoizations'.")
	elseif AceComm.prefixMemoizations[AceComm.commPrefixes[self]] then
		AceComm:error("Another addon with prefix %q has already registered memoizations.", AceComm.commPrefixes[self])
	end
	local hashToText = new()
	local textToHash = new()
	for _,text in ipairs(values) do
		local hash = TailoredNumericCheckSum(text)
		if hashToText[hash] then
			AceComm:error("%q and %q have the same checksum. You must remove one of them for memoization to work properly", hashToText[hash], text)
		else
			textToHash[text] = hash
			hashToText[hash] = text
		end
	end
	values = nil
	self.commMemoHashToText = hashToText
	self.commMemoTextToHash = textToHash
	AceComm.prefixMemoizations[AceComm.commPrefixes[self]] = hashToText
end

local lastCheck = GetTime()
local function CheckRefix()
	if GetTime() - lastCheck >= 120 then
		lastCheck = GetTime()
		RefixAceCommChannelsAndEvents()
	end
end

local function reallyHandleTableMessage(handlers, prefix, sender, distribution, message, custom)
	local n = #message * 4
	if n < 40 then n = 40 end
	while message[n] == nil and n > 0 do
		n = n - 1
	end
	for k, v in pairs(handlers) do
		local type_v = type(v)
		if type_v == "string" then
			local f = k[v]
			if type(f) == "table" then
				local i = 1
				local g = f[message[i]]
				while g do
					if type(g) ~= "table" then -- function
						if custom then
							g(k, prefix, sender, distribution, custom, unpack(message, i+1, n))
						else
							g(k, prefix, sender, distribution, unpack(message, i+1, n))
						end
						break
					else
						i = i + 1
						g = g[message[i]]
					end
				end
			else -- function
				if custom then
					f(k, prefix, sender, distribution, custom, unpack(message, 1, n))
				else
					f(k, prefix, sender, distribution, unpack(message, 1, n))
				end
			end
		elseif type_v == "table" then
			local i = 1
			local g = v[message[i]]
			while g do
				if type(g) ~= "table" then -- function
					if custom then
						g(prefix, sender, distribution, custom, unpack(message, i+1, n))
					else
						g(prefix, sender, distribution, unpack(message, i+1, n))
					end
					break
				else
					i = i + 1
					g = g[message[i]]
				end
			end
		else -- function
			if custom then
				v(prefix, sender, distribution, custom, unpack(message, 1, n))
			else
				v(prefix, sender, distribution, unpack(message, 1, n))
			end
		end
	end
end

local function reallyHandleNonTableMessage(handlers, prefix, sender, distribution, message, custom)
	for k, v in pairs(handlers) do
		local type_v = type(v)
		if type_v == "string" then
			local f = k[v]
			if type(f) == "table" then
				local g = f[message]
				if g and type(g) == "function" then
					if custom then
						g(k, prefix, sender, distribution, custom)
					else
						g(k, prefix, sender, distribution)
					end
				end
			else -- function
				if custom then
					f(k, prefix, sender, distribution, custom, message)
				else
					f(k, prefix, sender, distribution, message)
				end
			end
		elseif type_v == "table" then
			local g = v[message]
			if g and type(g) == "function" then
				if custom then
					g(k, prefix, sender, distribution, custom)
				else
					g(k, prefix, sender, distribution)
				end
			end
		else -- function
			if custom then
				v(prefix, sender, distribution, custom, message)
			else
				v(prefix, sender, distribution, message)
			end
		end
	end
end

local function HandleMessage(prefix, message, distribution, sender, customChannel)
	local isGroup = GetCurrentGroupDistribution() == distribution
	local isCustom = distribution == "CUSTOM"
	if (not AceComm_registry[distribution] and (not isGroup or not AceComm_registry.GROUP)) or (isCustom and not AceComm_registry.CUSTOM[customChannel]) then
		return CheckRefix()
	end
	local id, point
	if not message then
		local tmpPrefix
		tmpPrefix, id, point, message = prefix:match("^(...)\t(.)(.)%-(.*)$")
		if not tmpPrefix then
			local current, max
			tmpPrefix, id, current, max, message = prefix:match("^(...)\t(.)(.)(.)\t(.*)$")
			if not tmpPrefix then
				return
			end
			if current == max then
				if current == "\001" then
					point = 'a'
				else
					point = 'd'
				end
			elseif current == "\001" then
				point = 'b'
			else
				point = 'c'
			end
		end
		prefix = AceComm.prefixHashToText[tmpPrefix]
		if not prefix then
			return CheckRefix()
		end
		if isCustom then
			if not AceComm_registry.CUSTOM[customChannel][prefix] then
				return CheckRefix()
			end
		else
			if (not AceComm_registry[distribution] or not AceComm_registry[distribution][prefix]) and (not isGroup or not AceComm_registry.GROUP or not AceComm_registry.GROUP[prefix]) then
				return CheckRefix()
			end
		end
	else
		local tmpMessage
		id, point, tmpMessage = message:match("^(.)(.)%-(.*)$")
		if not id then
			local current, max
			id, current, max, tmpMessage = message:match("^(.)(.)(.)\t(.*)$")
			if not id then
				return
			end
			if current == max then
				if current == "\001" then
					point = 'a'
				else
					point = 'd'
				end
			elseif current == "\001" then
				point = 'b'
			else
				point = 'c'
			end
		end
		message = tmpMessage
	end
	if not message then
		return
	end
	if point ~= 'a' then
		local queue = AceComm.recvQueue
		local x
		if distribution == "CUSTOM" then
			x = prefix .. ":" .. sender .. distribution .. customChannel .. id
		else
			x = prefix .. ":" .. sender .. distribution .. id
		end
		if not queue[x] then
			if point ~= 'b' then
				return
			end
			queue[x] = new()
		end
		local chunk = queue[x]
		chunk.time = GetTime()
		chunk[#chunk+1] = message
		if point == 'd' then
			local success
			success, message = pcall(table_concat, chunk)
			if not success then
				return
			end
			queue[x] = del(queue[x])
		else
			return
		end
	end
	message = Deserialize(message, AceComm.prefixMemoizations[prefix])
	local isTable = type(message) == "table"
	local f = isTable and reallyHandleTableMessage or reallyHandleNonTableMessage
	if AceComm_registry[distribution] then
		if isCustom and AceComm_registry.CUSTOM[customChannel][prefix] then
			f(AceComm_registry.CUSTOM[customChannel][prefix], prefix, sender, distribution, message, customChannel and customChannel:sub(8))
		elseif not isCustom and AceComm_registry[distribution][prefix] then
			f(AceComm_registry[distribution][prefix], prefix, sender, distribution, message)
		end
	end
	if isGroup and AceComm_registry.GROUP and AceComm_registry.GROUP[prefix] then
		f(AceComm_registry.GROUP[prefix], prefix, sender, "GROUP", message)
	end
	if isTable then
		message = del(message)
	end
end

function AceComm:CHAT_MSG_ADDON(prefix, message, distribution, sender)
	if sender == player and not self.enableLoopback and distribution ~= "WHISPER" then
		return
	end
	if message == "" then
		return
	end
	prefix = self.prefixHashToText[prefix]
	if not prefix then
		return CheckRefix()
	end
	local isGroup = GetCurrentGroupDistribution() == distribution
	if not AceComm_registry[distribution] and (not isGroup or not AceComm_registry.GROUP) then
		return CheckRefix()
	end
	prefix = Decode(prefix)
	if (not AceComm_registry[distribution] or not AceComm_registry[distribution][prefix]) and (not isGroup or not AceComm_registry.GROUP or not AceComm_registry.GROUP[prefix]) then
		return CheckRefix()
	end
	message = Decode(message)
	return HandleMessage(prefix, message, distribution, sender)
end

function AceComm:CHAT_MSG_CHANNEL(text, sender, _, _, _, _, _, _, channel)
	if text == "" or sender == player or not channel:find("^AceComm") then
		return
	end
	text = Decode(text, true)
	local distribution
	local customChannel
	if channel == "AceComm" then
		distribution = "GLOBAL"
	elseif channel == GetCurrentZoneChannel() then
		distribution = "ZONE"
	else
		distribution = "CUSTOM"
		customChannel = channel
	end
	return HandleMessage(text, nil, distribution, sender, customChannel)
end

function AceComm:IsUserInChannel(userName, distribution, customChannel)
	AceComm:argCheck(userName, 2, "string", "nil")
	if not userName then
		userName = player
	end
	AceComm:argCheck(distribution, 3, "string")
	local channel
	if distribution == "GLOBAL" then
		channel = "AceComm"
	elseif distribution == "ZONE" then
		channel = GetCurrentZoneChannel()
	elseif distribution == "CUSTOM" then
		AceComm:argCheck(customChannel, 4, "string")
		channel = "AceComm" .. customChannel
	else
		AceComm:error('Argument #3 to `IsUserInChannel\' must be "GLOBAL", "CUSTOM", or "ZONE"')
	end
	
	return AceComm.userRegistry[channel] and AceComm.userRegistry[channel][userName] or false
end

function AceComm:CHAT_MSG_CHANNEL_LIST(text, _, _, _, _, _, _, _, channel)
	if not channel:find("^AceComm") then
		return
	end
	
	if not self.userRegistry[channel] then
		self.userRegistry[channel] = new()
	end
	local t = self.userRegistry[channel]
	for k in text:gmatch("[^, @%*#]+") do
		t[k] = true
	end
end

function AceComm:CHAT_MSG_CHANNEL_JOIN(_, user, _, _, _, _, _, _, channel)
	if not channel:find("^AceComm") then
		return
	end
	
	if not self.userRegistry[channel] then
		self.userRegistry[channel] = new()
	end
	local t = self.userRegistry[channel]
	t[user] = true
end

function AceComm:CHAT_MSG_CHANNEL_LEAVE(_, user, _, _, _, _, _, _, channel)
	if not channel:find("^AceComm") then
		return
	end
	
	if not self.userRegistry[channel] then
		self.userRegistry[channel] = new()
	end
	local t = self.userRegistry[channel]
	if t[user] then
		t[user] = nil
	end
end

function AceComm:ZONE_CHANGED_NEW_AREA()
	local lastZone = zoneCache
	zoneCache = nil
	local newZone = GetCurrentZoneChannel()
	if self.registry.ZONE and next(self.registry.ZONE) then
		if lastZone then
			SwitchChannel(lastZone, newZone)
		else
			JoinChannel(newZone)
		end
	end
end

function AceComm:embed(target)
	self.super.embed(self, target)
	if not AceEvent then
		AceComm:error(MAJOR_VERSION .. " requires AceEvent-2.0")
	end
end

local recentNotSeen = {}
local notSeenString = '^' .. _G.ERR_CHAT_PLAYER_NOT_FOUND_S:gsub("%%s", "(.-)"):gsub("%%1%$s", "(.-)") .. '$'
local ambiguousString = '^' .. _G.ERR_CHAT_PLAYER_AMBIGUOUS_S:gsub("%%s", "(.-)"):gsub("%%1%$s", "(.-)") .. '$'
local ERR_GUILD_PERMISSIONS = _G.ERR_GUILD_PERMISSIONS
if WotLK then
	function AceComm.hooks:ChatFrame_MessageEventHandler(orig, hookSelf, event, ...)
		if (event == "CHAT_MSG_CHANNEL" or event == "CHAT_MSG_CHANNEL_LIST") and select(9, ...):find("^AceComm") then
			return
		elseif event == "CHAT_MSG_SYSTEM" then
			local arg1 = ...
			if arg1 == ERR_GUILD_PERMISSIONS then
				if recentGuildMessage > GetTime() then
					stopGuildMessages = true
					return
				end
			else
				local player = arg1:match(notSeenString) or arg1:match(ambiguousString)
				if player then
					local t = GetTime()
					if recentNotSeen[player] and recentNotSeen[player] > t then
						recentNotSeen[player] = t + 10
						return
					else
						recentNotSeen[player] = t + 10
					end
				end
			end
		end
		return orig(hookSelf, event, ...)
	end
else
	function AceComm.hooks:ChatFrame_MessageEventHandler(orig, event)
		if (event == "CHAT_MSG_CHANNEL" or event == "CHAT_MSG_CHANNEL_LIST") and _G.arg9:find("^AceComm") then
			return
		elseif event == "CHAT_MSG_SYSTEM" then
			local arg1 = _G.arg1
			if arg1 == ERR_GUILD_PERMISSIONS then
				if recentGuildMessage > GetTime() then
					stopGuildMessages = true
					return
				end
			else
				local player = arg1:match(notSeenString) or arg1:match(ambiguousString)
				if player then
					local t = GetTime()
					if recentNotSeen[player] and recentNotSeen[player] > t then
						recentNotSeen[player] = t + 10
						return
					else
						recentNotSeen[player] = t + 10
					end
				end
			end
		end
		return orig(event)
	end
end

function AceComm.hooks:Logout(orig)
	if IsResting() then
		LeaveAceCommChannels()
	else
		self:ScheduleEvent("AceComm-LeaveAceCommChannels", LeaveAceCommChannels, 15)
	end
	return orig()
end

function AceComm.hooks:CancelLogout(orig)
	shutdown = false
	self:CancelScheduledEvent("AceComm-LeaveAceCommChannels")
	RefixAceCommChannelsAndEvents()
	return orig()
end

function AceComm.hooks:Quit(orig)
	if IsResting() then
		LeaveAceCommChannels()
	else
		self:ScheduleEvent("AceComm-LeaveAceCommChannels", LeaveAceCommChannels, 15)
	end
	return orig()
end

local function filterAceComm(k, v, ...)
	if not k or not v then
		return
	end
	if v:find("^AceComm") then
		return filterAceComm(...)
	else
		return k, v, filterAceComm(...)
	end
end
function AceComm.hooks:FCFDropDown_LoadChannels(orig, ...)
	return orig(filterAceComm(...))
end

function AceComm:CHAT_MSG_SYSTEM(text)
	if text ~= _G.ERR_TOO_MANY_CHAT_CHANNELS then
		return
	end
	if not lastChannelJoined or not lastChannelJoined:find("^AceComm") then
		return
	end
	
	local text
	if lastChannelJoined == "AceComm" then
		local addon = AceComm_registry.GLOBAL and next(AceComm_registry.GLOBAL)
		if not addon then
			return
		end
		addon = tostring(addon)
		text = ("%s has tried to join the AceComm global channel, but there are not enough channels available. %s may not work because of this."):format(addon, addon)
	elseif lastChannelJoined == GetCurrentZoneChannel() then
		local addon = AceComm_registry.ZONE and next(AceComm_registry.ZONE)
		if not addon then
			return
		end
		addon = tostring(addon)
		text = ("%s has tried to join the AceComm zone channel, but there are not enough channels available. %s may not work because of this."):format(addon, addon)
	else
		local addon = AceComm_registry.CUSTOM and AceComm_registry.CUSTOM[lastChannelJoined] and next(AceComm_registry.CUSTOM[lastChannelJoined])
		if not addon then
			return
		end
		addon = tostring(addon)
		text = ("%s has tried to join the AceComm custom channel %s, but there are not enough channels available. %s may not work because of this."):format(addon, lastChannelJoined, addon)
	end
	
	_G.StaticPopupDialogs["ACECOMM_TOO_MANY_CHANNELS"] = {
		text = text,
		button1 = _G.CLOSE,
		timeout = 0,
		whileDead = 1,
		hideOnEscape = 1,
	}
	_G.StaticPopup_Show("ACECOMM_TOO_MANY_CHANNELS")
end

function AceComm:QueryAddonVersion(addon, distribution, player)
	AceComm:argCheck(addon, 2, "string")
	AceComm:argCheck(distribution, 3, "string")
	if distribution ~= "WHISPER" and distribution ~= "PARTY" and distribution ~= "RAID" and distribution ~= "GUILD" and distribution ~= "BATTLEGROUND" and distribution ~= "GROUP" then
		AceComm:error('Argument #3 to `QueryAddonVersion\' must be either "WHISPER", "PARTY", "RAID", "GUILD", "BATTLEGROUND", or "GROUP". %q is not appropriate', distribution)
	end
	if distribution == "WHISPER" then
		AceComm:argCheck(player, 4, "string")
	elseif distribution == "GROUP" then
		distribution = GetCurrentGroupDistribution()
	end
	if not IsInDistribution(distribution) then
		return
	end
	if distribution == "WHISPER" then
		self.addonVersionPinger:SendCommMessage("WHISPER", player, "PING", addon)
	else
		self.addonVersionPinger:SendCommMessage(distribution, "PING", addon)
	end
end

function AceComm:RegisterAddonVersionReceptor(obj, method)
	self:argCheck(obj, 2, "function", "table")
	if type(obj) == "function" then
		method = true
	else
		self:argCheck(method, 3, "string")
		if type(obj[method]) ~= "function" then
			self:error("Handler provided to `RegisterAddonVersionReceptor', %q, not a function", method)
		end
	end
	self.addonVersionPinger.receptors[obj] = method
end

local function activate(self, oldLib, oldDeactivate)
	AceComm = self
	
	if not oldLib or not oldLib.hooks or not oldLib.hooks.ChatFrame_MessageEventHandler then
		local old_ChatFrame_MessageEventHandler = _G.ChatFrame_MessageEventHandler
		function _G.ChatFrame_MessageEventHandler(...)
			if self.hooks.ChatFrame_MessageEventHandler then
				return self.hooks.ChatFrame_MessageEventHandler(self, old_ChatFrame_MessageEventHandler, ...)
			else
				return old_ChatFrame_MessageEventHandler(...)
			end
		end
	end
	if not oldLib or not oldLib.hooks or not oldLib.hooks.Logout then
		local old_Logout = _G.Logout
		function _G.Logout(...)
			if self.hooks.Logout then
				return self.hooks.Logout(self, old_Logout, ...)
			else
				return old_Logout(...)
			end
		end
	end
	if not oldLib or not oldLib.hooks or not oldLib.hooks.CancelLogout then
		local old_CancelLogout = _G.CancelLogout
		function _G.CancelLogout(...)
			if self.hooks.CancelLogout then
				return self.hooks.CancelLogout(self, old_CancelLogout, ...)
			else
				return old_CancelLogout(...)
			end
		end
	end
	if not oldLib or not oldLib.hooks or not oldLib.hooks.Quit then
		local old_Quit = _G.Quit
		function _G.Quit(...)
			if self.hooks.Quit then
				return self.hooks.Quit(self, old_Quit, ...)
			else
				return old_Quit(...)
			end
		end
	end
	if not oldLib or not oldLib.hooks or not oldLib.hooks.FCFDropDown_LoadChannels then
		local old_FCFDropDown_LoadChannels = _G.FCFDropDown_LoadChannels
		function _G.FCFDropDown_LoadChannels(...)
			if self.hooks.FCFDropDown_LoadChannels then
				return self.hooks.FCFDropDown_LoadChannels(self, old_FCFDropDown_LoadChannels, ...)
			else
				return old_FCFDropDown_LoadChannels(...)
			end
		end
	end
	if not oldLib or not oldLib.hooks or not oldLib.hooks.JoinChannelByName then
		local old_JoinChannelByName = _G.JoinChannelByName
		function _G.JoinChannelByName(...)
			if self.hooks.JoinChannelByName then
				return self.hooks.JoinChannelByName(self, old_JoinChannelByName, ...)
			else
				return old_JoinChannelByName(...)
			end
		end
	end
	
	self.recvQueue = oldLib and oldLib.recvQueue or {}
	self.registry = oldLib and oldLib.registry or {}
	self.channels = oldLib and oldLib.channels or {}
	self.prefixes = oldLib and oldLib.prefixes or {}
	self.classes = oldLib and oldLib.classes or {}
	self.prefixMemoizations = oldLib and oldLib.prefixMemoizations or {}
	self.prefixHashToText = oldLib and oldLib.prefixHashToText or {}
	self.prefixTextToHash = oldLib and oldLib.prefixTextToHash or {}
	self.userRegistry = oldLib and oldLib.userRegistry or {}
	self.commPrefixes = oldLib and oldLib.commPrefixes or {}
	self.addonVersionPinger = oldLib and oldLib.addonVersionPinger
	AceComm_registry = self.registry
	for k in pairs(self.classes) do
		self.classes[k] = nil
	end
	
	self:activate(oldLib, oldDeactivate)
	
	if oldLib and not oldLib.commPrefixes then
		for t in pairs(self.embedList) do
			if t.commPrefix and not self.commPrefixes[t] then
				self.commPrefixes[t] = t.commPrefix
			end
		end
	end
	
	if oldDeactivate then
		oldDeactivate(oldLib)
	end
end

local function external(self, major, instance)
	if major == "AceEvent-2.0" then
		AceEvent = instance
		
		AceEvent:embed(self)
		
		self:UnregisterAllEvents()
		self:CancelAllScheduledEvents()
		
		if AceEvent:IsFullyInitialized() then
			RefixAceCommChannelsAndEvents()
		else
			self:RegisterEvent("AceEvent_FullyInitialized", RefixAceCommChannelsAndEvents, true)
		end
		
		self:RegisterEvent("PLAYER_LOGOUT", LeaveAceCommChannels)
		self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
		self:RegisterEvent("CHAT_MSG_CHANNEL_NOTICE")
		self:RegisterEvent("CHAT_MSG_SYSTEM")
		self:RegisterEvent("PLAYER_GUILD_UPDATE")
		
		if not self.addonVersionPinger then
			self.addonVersionPinger = {}
			self:embed(self.addonVersionPinger)
			self.addonVersionPinger:SetCommPrefix("Version")
			self.addonVersionPinger.receptors = {}
		else
			self.addonVersionPinger:UnregisterAllComms()
		end
		self.addonVersionPinger.OnCommReceive = {
			PING = function(self, prefix, sender, distribution, addon)
				local version = ""
				if AceLibrary:HasInstance(addon, false) then
					local lib = AceLibrary(addon)
					if lib.GetLibraryVersion then
						local revision
						version, revision = lib:GetLibraryVersion()
						version = version .. "-" .. revision
					end
				elseif LibStub(addon, true) then
					local _, revision = LibStub(addon, true)
					version = addon .. "-" .. revision
				else
					local revision
					local _G_addon = _G[addon]
					if not _G_addon then
						_G_addon = _G[addon:match("^[^_]+_(.*)$")]
					end
					if type(_G_addon) == "table" then
						if rawget(_G_addon, "version") then version = _G_addon.version
						elseif rawget(_G_addon, "Version") then version = _G_addon.Version
						elseif rawget(_G_addon, "VERSION") then version = _G_addon.VERSION
						end
						if type(version) == "function" then version = tostring(select(2, pcall(version()))) end
						local revision = nil
						if rawget(_G_addon, "revision") then revision = _G_addon.revision
						elseif rawget(_G_addon, "Revision") then revision = _G_addon.Revision
						elseif rawget(_G_addon, "REVISION") then revision = _G_addon.REVISION
						elseif rawget(_G_addon, "rev") then revision = _G_addon.rev
						elseif rawget(_G_addon, "Rev") then revision = _G_addon.Rev
						elseif rawget(_G_addon, "REV") then revision = _G_addon.REV
						end
						if type(revision) == "function" then revision = tostring(select(2, pcall(revision()))) end

						if version then version = tostring(version) end
						if revision then revision = tostring(revision) end
						if type(revision) == "string" and type(version) == "string" and version:len() > 0 and not version:find(revision) then
							version = version .. "." .. revision
						end

						if not version and revision then version = revision end
					end

					if _G[addon:upper().."_VERSION"] then
						version = _G[addon:upper() .. "_VERSION"]
					end
					if _G[addon:upper().."_REVISION"] or _G[addon:upper().."_REV"] then
						local revision = _G[addon:upper() .. "_REVISION"] or _G[addon:upper().."_REV"]
						if type(revision) == "string" and type(version) == "string" and version:len() > 0 and not version:find(revision) then
							version = version .. "." .. revision
						end
						if (not version or version == "") and revision then version = revision end
					end

					if not version or version == "" then
						version = GetAddOnMetadata(addon, "Version")
						if version and version ~= "" and not IsAddOnLoaded(addon) then
							local enabled, loadable = select(4, GetAddOnInfo(addon))  
							version = enabled and loadable and version .. " (LoD)" or version .. " (Off)"
						end
					end
					if not version or version == "" then
						local enabled, loadable = select(4, GetAddOnInfo(addon))  
						version = IsAddOnLoaded(addon) and true or enabled and loadable and "(LoD)" or false
					end
				end
				self:SendCommMessage("WHISPER", sender, "PONG", addon, version)
			end,
			PONG = function(self, prefix, sender, distribution, addon, version)
				for obj, method in pairs(self.receptors) do
					if type(obj) == "function" then
						local success, err = pcall(obj, sender, addon, version)
						if not success then
							geterrorhandler()(err)
						end
					else
						local obj_method = obj[method]
						local success, err = pcall(obj_method, obj, sender, addon, version)
						if not success then
							geterrorhandler()(err)
						end
					end
				end
			end
		}
		self.addonVersionPinger:RegisterComm("Version", "WHISPER")
		self.addonVersionPinger:RegisterComm("Version", "GUILD")
		self.addonVersionPinger:RegisterComm("Version", "RAID")
		self.addonVersionPinger:RegisterComm("Version", "PARTY")
		self.addonVersionPinger:RegisterComm("Version", "BATTLEGROUND")
	elseif AceOO.inherits(instance, AceOO.Class) and not instance.class then
		self.classes[TailoredNumericCheckSum(major)] = instance
	end
end

AceLibrary:Register(AceComm, MAJOR_VERSION, MINOR_VERSION, activate, nil, external)




--
-- ChatThrottleLib by Mikk
--
-- Manages AddOn chat output to keep player from getting kicked off.
--
-- ChatThrottleLib.SendChatMessage/.SendAddonMessage functions that accept 
-- a Priority ("BULK", "NORMAL", "ALERT") as well as prefix for SendChatMessage.
--
-- Priorities get an equal share of available bandwidth when fully loaded.
-- Communication channels are separated on extension+chattype+destination and
-- get round-robinned. (Destination only matters for whispers and channels,
-- obviously)
--
-- Will install hooks for SendChatMessage and SendAdd[Oo]nMessage to measure
-- bandwidth bypassing the library and use less bandwidth itself.
--
--
-- Fully embeddable library. Just copy this file into your addon directory,
-- add it to the .toc, and it's done.
--
-- Can run as a standalone addon also, but, really, just embed it! :-)
--

local CTL_VERSION = 19

if _G.ChatThrottleLib and _G.ChatThrottleLib.version >= CTL_VERSION then
	-- There's already a newer (or same) version loaded. Buh-bye.
	return
end

if not _G.ChatThrottleLib then
	_G.ChatThrottleLib = {}
end

ChatThrottleLib = _G.ChatThrottleLib  -- in case some addon does "local ChatThrottleLib" above use and we're copypasted (AceComm, sigh)
local ChatThrottleLib = _G.ChatThrottleLib

------------------ TWEAKABLES -----------------

ChatThrottleLib.MAX_CPS = 800			  -- 2000 seems to be safe if NOTHING ELSE is happening. let's call it 800.
ChatThrottleLib.MSG_OVERHEAD = 40		-- Guesstimate overhead for sending a message; source+dest+chattype+protocolstuff

ChatThrottleLib.BURST = 4000				-- WoW's server buffer seems to be about 32KB. 8KB should be safe, but seen disconnects on _some_ servers. Using 4KB now.

ChatThrottleLib.MIN_FPS = 20				-- Reduce output CPS to half (and don't burst) if FPS drops below this value


local setmetatable = setmetatable
local table_remove = table.remove
local tostring = tostring
local GetTime = GetTime
local math_min = math.min
local math_max = math.max
local next = next
local strlen = string.len

ChatThrottleLib.version = CTL_VERSION


-----------------------------------------------------------------------
-- Double-linked ring implementation

local Ring = {}
local RingMeta = { __index = Ring }

function Ring:New()
	local ret = {}
	setmetatable(ret, RingMeta)
	return ret
end

function Ring:Add(obj)	-- Append at the "far end" of the ring (aka just before the current position)
	if self.pos then
		obj.prev = self.pos.prev
		obj.prev.next = obj
		obj.next = self.pos
		obj.next.prev = obj
	else
		obj.next = obj
		obj.prev = obj
		self.pos = obj
	end
end

function Ring:Remove(obj)
	obj.next.prev = obj.prev
	obj.prev.next = obj.next
	if self.pos == obj then
		self.pos = obj.next
		if self.pos == obj then
			self.pos = nil
		end
	end
end



-----------------------------------------------------------------------
-- Recycling bin for pipes 
-- A pipe is a plain integer-indexed queue, which also happens to be a ring member

ChatThrottleLib.PipeBin = nil -- pre-v19, drastically different
local PipeBin = setmetatable({}, {__mode="k"})

local function DelPipe(pipe)
	for i = #pipe, 1, -1 do
		pipe[i] = nil
	end
	pipe.prev = nil
	pipe.next = nil
	
	PipeBin[pipe] = true
end

local function NewPipe()
	local pipe = next(PipeBin)
	if pipe then
		PipeBin[pipe] = nil
		return pipe
	end
	return {}
end




-----------------------------------------------------------------------
-- Recycling bin for messages

ChatThrottleLib.MsgBin = nil -- pre-v19, drastically different
local MsgBin = setmetatable({}, {__mode="k"})

local function DelMsg(msg)
	msg[1] = nil
	-- there's more parameters, but they're very repetetive so the string pool doesn't suffer really, and it's faster to just not delete them.
	MsgBin[msg] = true
end

local function NewMsg()
	local msg = next(MsgBin)
	if msg then
		MsgBin[msg] = nil
		return msg
	end
	return {}
end


-----------------------------------------------------------------------
-- ChatThrottleLib:Init
-- Initialize queues, set up frame for OnUpdate, etc


function ChatThrottleLib:Init()	
	
	-- Set up queues
	if not self.Prio then
		self.Prio = {}
		self.Prio["ALERT"] = { ByName = {}, Ring = Ring:New(), avail = 0 }
		self.Prio["NORMAL"] = { ByName = {}, Ring = Ring:New(), avail = 0 }
		self.Prio["BULK"] = { ByName = {}, Ring = Ring:New(), avail = 0 }
	end
	
	-- v4: total send counters per priority
	for _, Prio in pairs(self.Prio) do
		Prio.nTotalSent = Prio.nTotalSent or 0
	end
	
	if not self.avail then
		self.avail = 0 -- v5
	end
	if not self.nTotalSent then
		self.nTotalSent = 0 -- v5
	end

	
	-- Set up a frame to get OnUpdate events
	if not self.Frame then
		self.Frame = CreateFrame("Frame")
		self.Frame:Hide()
	end
	self.Frame:SetScript("OnUpdate", self.OnUpdate)
	self.Frame:SetScript("OnEvent", self.OnEvent)	-- v11: Monitor P_E_W so we can throttle hard for a few seconds
	self.Frame:RegisterEvent("PLAYER_ENTERING_WORLD")
	self.OnUpdateDelay = 0
	self.LastAvailUpdate = GetTime()
	self.HardThrottlingBeginTime = GetTime()	-- v11: Throttle hard for a few seconds after startup
	
	-- Hook SendChatMessage and SendAddonMessage so we can measure unpiped traffic and avoid overloads (v7)
	if not self.ORIG_SendChatMessage then
		-- use secure hooks instead of insecure hooks (v16)
		self.securelyHooked = true
		--SendChatMessage
		self.ORIG_SendChatMessage = SendChatMessage
		hooksecurefunc("SendChatMessage", function(...)
			return ChatThrottleLib.Hook_SendChatMessage(...)
		end)
		self.ORIG_SendAddonMessage = SendAddonMessage
		--SendAddonMessage
		hooksecurefunc("SendAddonMessage", function(...)
			return ChatThrottleLib.Hook_SendAddonMessage(...)
		end)
	end
	self.nBypass = 0
end


-----------------------------------------------------------------------
-- ChatThrottleLib.Hook_SendChatMessage / .Hook_SendAddonMessage
function ChatThrottleLib.Hook_SendChatMessage(text, chattype, language, destination, ...)
	local self = ChatThrottleLib
	local size = strlen(tostring(text or "")) + strlen(tostring(destination or "")) + self.MSG_OVERHEAD
	self.avail = self.avail - size
	self.nBypass = self.nBypass + size	-- just a statistic
	if not self.securelyHooked then
		self.ORIG_SendChatMessage(text, chattype, language, destination, ...)
	end
end
function ChatThrottleLib.Hook_SendAddonMessage(prefix, text, chattype, destination, ...)
	local self = ChatThrottleLib
	local size = tostring(text or ""):len() + tostring(prefix or ""):len();
	size = size + tostring(destination or ""):len() + self.MSG_OVERHEAD
	self.avail = self.avail - size
	self.nBypass = self.nBypass + size	-- just a statistic
	if not self.securelyHooked then
		self.ORIG_SendAddonMessage(prefix, text, chattype, destination, ...)
	end
end



-----------------------------------------------------------------------
-- ChatThrottleLib:UpdateAvail
-- Update self.avail with how much bandwidth is currently available

function ChatThrottleLib:UpdateAvail()
	local now = GetTime()
	local MAX_CPS = self.MAX_CPS;
	local newavail = MAX_CPS * (now - self.LastAvailUpdate)
	local avail = self.avail

	if now - self.HardThrottlingBeginTime < 5 then
		-- First 5 seconds after startup/zoning: VERY hard clamping to avoid irritating the server rate limiter, it seems very cranky then
		avail = math_min(avail + (newavail*0.1), MAX_CPS*0.5)
		self.bChoking = true
	elseif GetFramerate() < self.MIN_FPS then		-- GetFrameRate call takes ~0.002 secs
		avail = math_min(MAX_CPS, avail + newavail*0.5)
		self.bChoking = true		-- just a statistic
	else
		avail = math_min(self.BURST, avail + newavail)
		self.bChoking = false
	end
	
	avail = math_max(avail, 0-(MAX_CPS*2))	-- Can go negative when someone is eating bandwidth past the lib. but we refuse to stay silent for more than 2 seconds; if they can do it, we can.
	
	self.avail = avail
	self.LastAvailUpdate = now
	
	return avail
end


-----------------------------------------------------------------------
-- Despooling logic

function ChatThrottleLib:Despool(Prio)
	local ring = Prio.Ring
	while ring.pos and Prio.avail > ring.pos[1].nSize do
		local msg = table_remove(Prio.Ring.pos, 1)
		if not Prio.Ring.pos[1] then
			local pipe = Prio.Ring.pos
			Prio.Ring:Remove(pipe)
			Prio.ByName[pipe.name] = nil
			DelPipe(pipe)
		else
			Prio.Ring.pos = Prio.Ring.pos.next
		end
		Prio.avail = Prio.avail - msg.nSize
		msg.f(unpack(msg, 1, msg.n))
		Prio.nTotalSent = Prio.nTotalSent + msg.nSize
		DelMsg(msg)
	end
end


function ChatThrottleLib.OnEvent(this,event)
	-- v11: We know that the rate limiter is touchy after login. Assume that it's touch after zoning, too.
	local self = ChatThrottleLib
	if event == "PLAYER_ENTERING_WORLD" then
		self.HardThrottlingBeginTime = GetTime()	-- Throttle hard for a few seconds after zoning
		self.avail = 0
	end
end


function ChatThrottleLib.OnUpdate(this,delay)
	local self = ChatThrottleLib
	
	self.OnUpdateDelay = self.OnUpdateDelay + delay
	if self.OnUpdateDelay < 0.08 then
		return
	end
	self.OnUpdateDelay = 0
	
	self:UpdateAvail()
	
	if self.avail < 0  then
		return -- argh. some bastard is spewing stuff past the lib. just bail early to save cpu.
	end

	-- See how many of our priorities have queued messages
	local n = 0
	for prioname,Prio in pairs(self.Prio) do
		if Prio.Ring.pos or Prio.avail < 0 then 
			n = n + 1 
		end
	end
	
	-- Anything queued still?
	if n<1 then
		-- Nope. Move spillover bandwidth to global availability gauge and clear self.bQueueing
		for prioname, Prio in pairs(self.Prio) do
			self.avail = self.avail + Prio.avail
			Prio.avail = 0
		end
		self.bQueueing = false
		self.Frame:Hide()
		return
	end
	
	-- There's stuff queued. Hand out available bandwidth to priorities as needed and despool their queues
	local avail = self.avail/n
	self.avail = 0
	
	for prioname, Prio in pairs(self.Prio) do
		if Prio.Ring.pos or Prio.avail < 0 then
			Prio.avail = Prio.avail + avail
			if Prio.Ring.pos and Prio.avail > Prio.Ring.pos[1].nSize then
				self:Despool(Prio)
			end
		end
	end

end




-----------------------------------------------------------------------
-- Spooling logic


function ChatThrottleLib:Enqueue(prioname, pipename, msg)
	local Prio = self.Prio[prioname]
	local pipe = Prio.ByName[pipename]
	if not pipe then
		self.Frame:Show()
		pipe = NewPipe()
		pipe.name = pipename
		Prio.ByName[pipename] = pipe
		Prio.Ring:Add(pipe)
	end
	
	pipe[#pipe + 1] = msg
	
	self.bQueueing = true
end



function ChatThrottleLib:SendChatMessage(prio, prefix,   text, chattype, language, destination, queueName)
	if not self or not prio or not text or not self.Prio[prio] then
		error('Usage: ChatThrottleLib:SendChatMessage("{BULK||NORMAL||ALERT}", "prefix" or nil, "text"[, "chattype"[, "language"[, "destination"]]]', 2)
	end
	
	prefix = prefix or tostring(this)		-- each frame gets its own queue if prefix is not given
	
	local nSize = text:len()
	
	assert(nSize<=255, "text length cannot exceed 255 bytes");
	
	nSize = nSize + self.MSG_OVERHEAD
	
	-- Check if there's room in the global available bandwidth gauge to send directly
	if not self.bQueueing and nSize < self:UpdateAvail() then
		self.avail = self.avail - nSize
		self.ORIG_SendChatMessage(text, chattype, language, destination)
		self.Prio[prio].nTotalSent = self.Prio[prio].nTotalSent + nSize
		return
	end
	
	-- Message needs to be queued
	local msg = NewMsg()
	msg.f = self.ORIG_SendChatMessage
	msg[1] = text
	msg[2] = chattype or "SAY"
	msg[3] = language
	msg[4] = destination
	msg.n = 4
	msg.nSize = nSize

	self:Enqueue(prio, queueName or (prefix..(chattype or "SAY")..(destination or "")), msg)
end


function ChatThrottleLib:SendAddonMessage(prio, prefix, text, chattype, target, queueName)
	if not self or not prio or not prefix or not text or not chattype or not self.Prio[prio] then
		error('Usage: ChatThrottleLib:SendAddonMessage("{BULK||NORMAL||ALERT}", "prefix", "text", "chattype"[, "target"])', 0)
	end
	
	local nSize = prefix:len() + 1 + text:len();
	
	assert(nSize<=255, "prefix + text length cannot exceed 254 bytes");
	
	nSize = nSize + self.MSG_OVERHEAD;
	
	-- Check if there's room in the global available bandwidth gauge to send directly
	if not self.bQueueing and nSize < self:UpdateAvail() then
		self.avail = self.avail - nSize
		self.ORIG_SendAddonMessage(prefix, text, chattype, target)
		self.Prio[prio].nTotalSent = self.Prio[prio].nTotalSent + nSize
		return
	end
	
	-- Message needs to be queued
	local msg = NewMsg()
	msg.f = self.ORIG_SendAddonMessage
	msg[1] = prefix
	msg[2] = text
	msg[3] = chattype
	msg[4] = target
	msg.n = (target~=nil) and 4 or 3;
	msg.nSize = nSize
	
	self:Enqueue(prio, queueName or (prefix..chattype..(target or "")), msg)
end




-----------------------------------------------------------------------
-- Get the ball rolling!

ChatThrottleLib:Init()

--[[ WoWBench debugging snippet
if(WOWB_VER) then
	local function SayTimer()
		print("SAY: "..GetTime().." "..arg1)
	end
	ChatThrottleLib.Frame:SetScript("OnEvent", SayTimer)
	ChatThrottleLib.Frame:RegisterEvent("CHAT_MSG_SAY")
end
]]

