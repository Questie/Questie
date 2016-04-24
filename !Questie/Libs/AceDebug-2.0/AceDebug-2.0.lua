--[[
Name: AceDebug-2.0
Revision: $Rev: 1091 $
Developed by: The Ace Development Team (http://www.wowace.com/index.php/The_Ace_Development_Team)
Inspired By: Ace 1.x by Turan (turan@gryphon.com)
Website: http://www.wowace.com/
Documentation: http://www.wowace.com/index.php/AceDebug-2.0
SVN: http://svn.wowace.com/wowace/trunk/Ace2/AceDebug-2.0
Description: Mixin to allow for simple debugging capabilities.
Dependencies: AceLibrary, AceOO-2.0
License: LGPL v2.1
]]

local MAJOR_VERSION = "AceDebug-2.0"
local MINOR_VERSION = 90000 + tonumber(("$Revision: 1091 $"):match("(%d+)"))

if not AceLibrary then error(MAJOR_VERSION .. " requires AceLibrary") end
if not AceLibrary:IsNewVersion(MAJOR_VERSION, MINOR_VERSION) then return end

if not AceLibrary:HasInstance("AceOO-2.0") then error(MAJOR_VERSION .. " requires AceOO-2.0") end 

local function safecall(func,...)
	local success, err = pcall(func,...)
	if not success then geterrorhandler()(err:find("%.lua:%d+:") and err or (debugstack():match("\n(.-: )in.-\n") or "") .. err) end
end

local DEBUGGING, TOGGLE_DEBUGGING
if GetLocale() == "frFR" then
	DEBUGGING = "D\195\169boguage"
	TOGGLE_DEBUGGING = "Activer/d\195\169sactiver le d\195\169boguage"
elseif GetLocale() == "deDE" then
	DEBUGGING = "Debuggen"
	TOGGLE_DEBUGGING = "Aktiviert/Deaktiviert Debugging."
elseif GetLocale() == "koKR" then
	DEBUGGING = "디버깅"
	TOGGLE_DEBUGGING = "디버깅 기능 사용함/사용안함"
elseif GetLocale() == "zhTW" then
	DEBUGGING = "除錯"
	TOGGLE_DEBUGGING = "啟用/停用除錯功能。"
elseif GetLocale() == "zhCN" then
	DEBUGGING = "\232\176\131\232\175\149"
	TOGGLE_DEBUGGING = "\229\144\175\231\148\168/\231\166\129\231\148\168 \232\176\131\232\175\149."
elseif GetLocale() == "esES" then
	DEBUGGING = "Debugging"
	TOGGLE_DEBUGGING = "Activar/desactivar Debugging."
elseif GetLocale() == "ruRU" then
	DEBUGGING = "Отладка"
	TOGGLE_DEBUGGING = "Вкл/Выкл отладку для этого аддона."
else -- enUS
	DEBUGGING = "Debugging"
	TOGGLE_DEBUGGING = "Toggle debugging for this addon."
end

local AceOO = AceLibrary:GetInstance("AceOO-2.0")
local AceDebug = AceOO.Mixin {
	"Debug",
	"CustomDebug",
	"IsDebugging",
	"SetDebugging",
	"SetDebugLevel",
	"LevelDebug",
	"CustomLevelDebug",
	"GetDebugLevel",
	"GetDebugPrefix",
}

local function print(text, r, g, b, frame, delay)
	(frame or DEFAULT_CHAT_FRAME):AddMessage(text, r, g, b, 1, delay or 5)
end

local tmp = {}

function AceDebug:CustomDebug(r, g, b, frame, delay, a1, ...)
	if not self.debugging then
		return
	end

	local output = self:GetDebugPrefix()
	
	a1 = tostring(a1)
	if a1:find("%%") and select('#', ...) >= 1 then
		for i = 1, select('#', ...) do
			tmp[i] = tostring((select(i, ...)))
		end
		output = output .. " " .. a1:format(unpack(tmp))
		for i = 1, select('#', ...) do
			tmp[i] = nil
		end
	else
		-- This block dynamically rebuilds the tmp array stopping on the first nil.
		tmp[1] = output
		tmp[2] = a1
		for i = 1, select('#', ...) do
			tmp[i+2] = tostring((select(i, ...)))
		end
		
		output = table.concat(tmp, " ")
		
		for i = 1, select('#', ...) + 2 do
			tmp[i] = nil
		end
	end

	print(output, r, g, b, frame or self.debugFrame, delay)
end

function AceDebug:Debug(...)
	AceDebug.CustomDebug(self, nil, nil, nil, nil, nil, ...)
end

function AceDebug:IsDebugging()
	return self.debugging
end

function AceDebug:SetDebugging(debugging)
	if debugging then
		self.debugging = debugging
		if type(self.OnDebugEnable) == "function" then
			safecall(self.OnDebugEnable, self)
		end
	else
		if type(self.OnDebugDisable) == "function" then
			safecall(self.OnDebugDisable, self)
		end
		self.debugging = debugging		
	end
end

-- Takes a number 1-3
-- Level 1: Critical messages that every user should receive
-- Level 2: Should be used for local debugging (function calls, etc)
-- Level 3: Very verbose debugging, will dump everything and anything
-- If set to nil, you will receive no debug information
function AceDebug:SetDebugLevel(level)
	AceDebug:argCheck(level, 1, "number", "nil")
	if not level then
		self.debuglevel = nil
		return
	end
	if level < 1 or level > 3 then
		AceDebug:error("Bad argument #1 to `SetDebugLevel`, must be a number 1-3")
	end
	self.debuglevel = level
end

function AceDebug:GetDebugPrefix()
	return ("|cff7fff7f(DEBUG) %s:[%s.%3d]|r"):format( tostring(self), date("%H:%M:%S"), (GetTime() % 1) * 1000)
end

function AceDebug:GetDebugLevel()
	return self.debuglevel
end

function AceDebug:CustomLevelDebug(level, r, g, b, frame, delay, a1, ...)
	if not self.debugging or not self.debuglevel then return end
	AceDebug:argCheck(level, 1, "number")
	if level < 1 or level > 3 then
		AceDebug:error("Bad argument #1 to `LevelDebug`, must be a number 1-3")
	end
	if level > self.debuglevel then return end

	local output = self:GetDebugPrefix()

	a1 = tostring(a1)
	if a1:find("%%") and select('#', ...) >= 1 then
		for i = 1, select('#', ...) do
			tmp[i] = tostring((select(i, ...)))
		end
		output = output .. " " .. a1:format(unpack(tmp))
		for i = 1, select('#', ...) do
			tmp[i] = nil
		end
	else
		-- This block dynamically rebuilds the tmp array stopping on the first nil.
		tmp[1] = output
		tmp[2] = a1
		for i = 1, select('#', ...) do
			tmp[i+2] = tostring((select(i, ...)))
		end
		
		output = table.concat(tmp, " ")
		
		for i = 1, select('#', ...) + 2 do
			tmp[i] = nil
		end
	end

	print(output, r, g, b, frame or self.debugFrame, delay)
end

function AceDebug:LevelDebug(level, ...)
	if not self.debugging or not self.debuglevel then return end
	AceDebug:argCheck(level, 1, "number")
	if level < 1 or level > 3 then
		AceDebug:error("Bad argument #1 to `LevelDebug`, must be a number 1-3")
	end
	if level > self.debuglevel then return end

	AceDebug.CustomLevelDebug(self, level, nil, nil, nil, nil, nil, ...)
end


local options
function AceDebug:GetAceOptionsDataTable(target)
	if not options then
		options = {
			debug = {
				name = DEBUGGING,
				desc = TOGGLE_DEBUGGING,
				type = "toggle",
				get = "IsDebugging",
				set = "SetDebugging",
				order = -2,
			}
		}
	end
	return options
end

AceLibrary:Register(AceDebug, MAJOR_VERSION, MINOR_VERSION, AceDebug.activate)
AceDebug = AceLibrary(MAJOR_VERSION)

