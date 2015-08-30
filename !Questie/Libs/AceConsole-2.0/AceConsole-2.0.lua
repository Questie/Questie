--[[
Name: AceConsole-2.0
Revision: $Rev: 15051 $
Developed by: The Ace Development Team (http://www.wowace.com/index.php/The_Ace_Development_Team)
Inspired By: Ace 1.x by Turan (turan@gryphon.com)
Website: http://www.wowace.com/
Documentation: http://www.wowace.com/index.php/AceConsole-2.0
SVN: http://svn.wowace.com/root/trunk/Ace2/AceConsole-2.0
Description: Mixin to allow for input/output capabilities. This uses the
             AceOptions data table format to determine input.
             http://wiki.wowace.com/index.php/AceOptions_data_table
Dependencies: AceLibrary, AceOO-2.0
]]

local MAJOR_VERSION = "AceConsole-2.0"
local MINOR_VERSION = "$Revision: 15051 $"

if not AceLibrary then error(MAJOR_VERSION .. " requires AceLibrary.") end
if not AceLibrary:IsNewVersion(MAJOR_VERSION, MINOR_VERSION) then return end

if not AceLibrary:HasInstance("AceOO-2.0") then error(MAJOR_VERSION .. " requires AceOO-2.0.") end

local MAP_ONOFF, USAGE, IS_CURRENTLY_SET_TO, IS_NOW_SET_TO, IS_NOT_A_VALID_OPTION_FOR, IS_NOT_A_VALID_VALUE_FOR, NO_OPTIONS_AVAILABLE, OPTION_HANDLER_NOT_FOUND, OPTION_HANDLER_NOT_VALID, OPTION_IS_DISABLED
if GetLocale() == "deDE" then
	MAP_ONOFF = { [false] = "|cffff0000Aus|r", [true] = "|cff00ff00An|r" }
	USAGE = "Benutzung"
	IS_CURRENTLY_SET_TO = "|cffffff7f%s|r steht momentan auf |cffffff7f[|r%s|cffffff7f]|r"
	IS_NOW_SET_TO = "|cffffff7f%s|r ist nun auf |cffffff7f[|r%s|cffffff7f]|r gesetzt"
	IS_NOT_A_VALID_OPTION_FOR = "[|cffffff7f%s|r] ist keine g\195\188ltige Option f\195\188r |cffffff7f%s|r"
	IS_NOT_A_VALID_VALUE_FOR = "[|cffffff7f%s|r] ist kein g\195\188ltiger Wert f\195\188r |cffffff7f%s|r"
	NO_OPTIONS_AVAILABLE = "Keine Optionen verfügbar"
	OPTION_HANDLER_NOT_FOUND = "Optionen handler |cffffff7f%q|r nicht gefunden."
	OPTION_HANDLER_NOT_VALID = "Optionen handler nicht g\195\188ltig."
	OPTION_IS_DISABLED = "Option |cffffff7f%s|r deaktiviert."
elseif GetLocale() == "frFR" then
	MAP_ONOFF = { [false] = "|cffff0000Inactif|r", [true] = "|cff00ff00Actif|r" }
	USAGE = "Utilisation"
	IS_CURRENTLY_SET_TO = "|cffffff7f%s|r est actuellement positionn\195\169 sur |cffffff7f[|r%s|cffffff7f]|r"
	IS_NOW_SET_TO = "|cffffff7f%s|r est maintenant positionn\195\169 sur |cffffff7f[|r%s|cffffff7f]|r"
	IS_NOT_A_VALID_OPTION_FOR = "[|cffffff7f%s|r] n'est pas une option valide pour |cffffff7f%s|r"
	IS_NOT_A_VALID_VALUE_FOR = "[|cffffff7f%s|r] n'est pas une valeur valide pour |cffffff7f%s|r"
	NO_OPTIONS_AVAILABLE = "Pas d'options disponibles"
	OPTION_HANDLER_NOT_FOUND = "Le gestionnaire d'option |cffffff7f%q|r n'a pas \195\169t\195\169 trouv\195\169."
	OPTION_HANDLER_NOT_VALID = "Le gestionnaire d'option n'est pas valide."
	OPTION_IS_DISABLED = "L'option |cffffff7f%s|r est d\195\169sactiv\195\169e."
elseif GetLocale() == "koKR" then
	MAP_ONOFF = { [false] = "|cffff0000끔|r", [true] = "|cff00ff00켬|r" }
	USAGE = "사용법"
	IS_CURRENTLY_SET_TO = "|cffffff7f%s|r|1은;는; 현재 상태는 |cffffff7f[|r%s|cffffff7f]|r|1으로;로; 설정되어 있습니다"
	IS_NOW_SET_TO = "|cffffff7f%s|r|1을;를; |cffffff7f[|r%s|cffffff7f]|r 상태로 변경합니다"
	IS_NOT_A_VALID_OPTION_FOR = "[|cffffff7f%s|r]|1은;는; |cffffff7f%s|r에서 사용불가능한 설정입니다"
	IS_NOT_A_VALID_VALUE_FOR = "[|cffffff7f%s|r]|1은;는; |cffffff7f%s|r에서 사용불가능한 설정값입니다"
	NO_OPTIONS_AVAILABLE = "가능한 설정이 없습니다"
	OPTION_HANDLER_NOT_FOUND = "설정 조정값인 |cffffff7f%q|r|1을;를; 찾지 못했습니다."
	OPTION_HANDLER_NOT_VALID = "설정 조정값이 올바르지 않습니다."
	OPTION_IS_DISABLED = "|cffffff7f%s|r 설정은 사용할 수 없습니다."
elseif GetLocale() == "zhCN" then
	MAP_ONOFF = { [false] = "|cffff0000\229\133\179\233\151\173|r", [true] = "|cff00ff00\229\188\128\229\144\175|r" }
	USAGE = "\231\148\168\230\179\149"
	IS_CURRENTLY_SET_TO = "|cffffff7f%s|r \229\189\147\229\137\141\232\162\171\232\174\190\231\189\174 |cffffff7f[|r%s|cffffff7f]|r"
	IS_NOW_SET_TO = "|cffffff7f%s|r \231\142\176\229\156\168\232\162\171\232\174\190\231\189\174\228\184\186 |cffffff7f[|r%s|cffffff7f]|r"
	IS_NOT_A_VALID_OPTION_FOR = "[|cffffff7f%s|r] \228\184\141\230\152\175\228\184\128\228\184\170\230\156\137\230\149\136\231\154\132\233\128\137\233\161\185 \228\184\186 |cffffff7f%s|r"
	IS_NOT_A_VALID_VALUE_FOR = "[|cffffff7f%s|r] \228\184\141\230\152\175\228\184\128\228\184\170\230\156\137\230\149\136\229\128\188 \228\184\186 |cffffff7f%s|r"
	NO_OPTIONS_AVAILABLE = "\230\178\161\230\156\137\233\128\137\233\161\185\229\143\175\231\148\168"
	OPTION_HANDLER_NOT_FOUND = "\233\128\137\233\161\185\229\164\132\231\144\134\231\168\139\229\186\143 |cffffff7f%q|r \230\178\161\230\159\165\230\137\190."
	OPTION_HANDLER_NOT_VALID = "\233\128\137\233\161\185\229\164\132\231\144\134\231\168\139\229\186\143 \230\151\160\230\149\136."
	OPTION_IS_DISABLED = "\233\128\137\233\161\185 |cffffff7f%s|r \228\184\141\229\174\140\230\149\180."
elseif GetLocale() == "zhTW" then
	MAP_ONOFF = { [false] = "|cffff0000關閉|r", [true] = "|cff00ff00開啟|r" }
	USAGE = "用法"
	IS_CURRENTLY_SET_TO = "|cffffff7f%s|r 目前的設定為 |cffffff7f[|r%s|cffffff7f]|r"
	IS_NOW_SET_TO = "|cffffff7f%s|r 現在被設定為 |cffffff7f[|r%s|cffffff7f]|r"
	IS_NOT_A_VALID_OPTION_FOR = "[|cffffff7f%s|r] 是一個不符合規定的選項，對 |cffffff7f%s|r"
	IS_NOT_A_VALID_VALUE_FOR = "[|cffffff7f%s|r] 是一個不符合規定的數值，對 |cffffff7f%s|r"
	NO_OPTIONS_AVAILABLE = "沒有可用的選項處理器。"
	OPTION_HANDLER_NOT_FOUND = "找不到 |cffffff7f%q|r 選項處理器。"
	OPTION_HANDLER_NOT_VALID = "選項處理器不符合規定。"
	OPTION_IS_DISABLED = "|cffffff7f%s|r 已被停用。"
else -- enUS
	MAP_ONOFF = { [false] = "|cffff0000Off|r", [true] = "|cff00ff00On|r" }
	USAGE = "Usage"
	IS_CURRENTLY_SET_TO = "|cffffff7f%s|r is currently set to |cffffff7f[|r%s|cffffff7f]|r"
	IS_NOW_SET_TO = "|cffffff7f%s|r is now set to |cffffff7f[|r%s|cffffff7f]|r"
	IS_NOT_A_VALID_OPTION_FOR = "[|cffffff7f%s|r] is not a valid option for |cffffff7f%s|r"
	IS_NOT_A_VALID_VALUE_FOR = "[|cffffff7f%s|r] is not a valid value for |cffffff7f%s|r"
	NO_OPTIONS_AVAILABLE = "No options available"
	OPTION_HANDLER_NOT_FOUND = "Option handler |cffffff7f%q|r not found."
	OPTION_HANDLER_NOT_VALID = "Option handler not valid."
	OPTION_IS_DISABLED = "Option |cffffff7f%s|r is disabled."
end

local NONE = NONE or "None"

local AceOO = AceLibrary("AceOO-2.0")
local AceEvent

local AceConsole = AceOO.Mixin { "Print", "PrintComma", "CustomPrint", "RegisterChatCommand" }
local Dewdrop

local _G = getfenv(0)

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

local function print(text, name, r, g, b, frame, delay)
	if not text or string.len(text) == 0 then
		text = " "
	end
	if not name or name == AceConsole then
		(frame or DEFAULT_CHAT_FRAME):AddMessage(text, r, g, b, nil, delay or 5)
	else
		(frame or DEFAULT_CHAT_FRAME):AddMessage("|cffffff78" .. tostring(name) .. ":|r " .. text, r, g, b, nil, delay or 5)
	end
end

local tmp
function AceConsole:CustomPrint(r, g, b, frame, delay, connector, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19, a20)
	a1 = tostring(a1)
	if string.find(a1, "%%") then
		print(string.format(a1, tostring(a2), tostring(a3), tostring(a4), tostring(a5), tostring(a6), tostring(a7), tostring(a8), tostring(a9), tostring(a10), tostring(a11), tostring(a12), tostring(a13), tostring(a14), tostring(a15), tostring(a16), tostring(a17), tostring(a18), tostring(a19), tostring(a20)), self, r, g, b, frame or self.printFrame, delay)
	else
		if not tmp then
			tmp = {}
		end
		tmp[1] = a1
		tmp[2] = a2
		tmp[3] = a3
		tmp[4] = a4
		tmp[5] = a5
		tmp[6] = a6
		tmp[7] = a7
		tmp[8] = a8
		tmp[9] = a9
		tmp[10] = a10
		tmp[11] = a11
		tmp[12] = a12
		tmp[13] = a13
		tmp[14] = a14
		tmp[15] = a15
		tmp[16] = a16
		tmp[17] = a17
		tmp[18] = a18
		tmp[19] = a19
		tmp[20] = a20
		local n = 20
		while tmp[n] == nil do
			n = n - 1
		end
		table_setn(tmp, n)
		for k = 1, n do
			tmp[k] = tostring(tmp[k])
		end
		print(table.concat(tmp, connector or " "), self, r, g, b, frame or self.printFrame, delay)
		for k,v in pairs(tmp) do
			tmp[k] = nil
		end
		table_setn(tmp, 0)
	end
end

function AceConsole:Print(a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19, a20)
	return AceConsole.CustomPrint(self, nil, nil, nil, nil, nil, " ", a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19, a20)
end

function AceConsole:PrintComma(a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19, a20)
	return AceConsole.CustomPrint(self, nil, nil, nil, nil, nil, ", ", a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19, a20)
end

local work
local argwork

local string_gfind = string.gmatch or string.gfind

local function findTableLevel(self, options, chat, text, index, passTable)
	if not index then
		index = 1
		if work then
			for k,v in pairs(work) do
				work[k] = nil
			end
			table_setn(work, 0)
			for k,v in pairs(argwork) do
				argwork[k] = nil
			end
			table_setn(argwork, 0)
		else
			work = {}
			argwork = {}
		end
		local len = string.len(text)
		local count
		repeat
			text, count = string.gsub(text, "(|cff%x%x%x%x%x%x|Hitem:%d-:%d-:%d-:%d-|h%[[^%]]-) (.-%]|h|r)", "%1\001%2")
		until count == 0
		text = string.gsub(text, "(%]|h|r)(|cff%x%x%x%x%x%x|Hitem:%d-:%d-:%d-:%d-|h%[)", "%1 %2")
		for token in string_gfind(text, "([^%s]+)") do
			local token = token
			local num = tonumber(token)
			if num then
				token = num
			else
				token = string.gsub(token, "\001", " ")
			end
			table.insert(work, token)
		end
	end

	local path = chat
	for i = 1, index - 1 do
		path = path .. " " .. tostring(work[i])
	end

	if type(options.args) == "table" then
		local disabled, hidden = options.disabled, options.cmdHidden or options.hidden
		if hidden then
			if type(hidden) == "function" then
				hidden = hidden()
			elseif type(hidden) == "string" then
				local handler = options.handler or self
				if type(handler[hidden]) ~= "function" then
					AceConsole:error(OPTION_HANDLER_NOT_FOUND, hidden)
				end
				hidden = handler[hidden](handler)
			end
		end
		if hidden then
			disabled = true
		elseif disabled then
			if type(disabled) == "function" then
				disabled = disabled()
			elseif type(disabled) == "string" then
				local handler = options.handler or self
				if type(handler[disabled]) ~= "function" then
					AceConsole:error(OPTION_HANDLER_NOT_FOUND, disabled)
				end
				disabled = handler[disabled](handler)
			end
		end
		if not disabled then
			local next = work[index] and string.lower(work[index])
			if next then
				for k,v in pairs(options.args) do
					local good = false
					if string.lower(k) == next then
						good = true
					elseif type(v.aliases) == "table" then
						for _,alias in ipairs(v.aliases) do
							if string.lower(alias) == next then
								good = true
								break
							end
						end
					elseif type(v.aliases) == "string" and string.lower(v.aliases) == next then
						good = true
					end
					if good then
						return findTableLevel(options.handler or self, v, chat, text, index + 1, options.pass and options or nil)
					end
				end
			end
		end
	end
	for i = index, table.getn(work) do
		table.insert(argwork, work[i])
	end
	return options, path, argwork, options.handler or self, passTable, passTable and work[index - 1]
end

local function validateOptionsMethods(self, options, position)
	if type(options) ~= "table" then
		return "Options must be a table.", position
	end
	self = options.handler or self
	if options.type == "execute" then
		if options.func and type(options.func) ~= "string" and type(options.func) ~= "function" then
			return "func must be a string or function", position
		end
		if options.func and type(options.func) == "string" and type(self[options.func]) ~= "function" then
			return string.format("%q is not a proper function", options.func), position
		end
	else
		if options.get then
			if type(options.get) ~= "string" and type(options.get) ~= "function" then
				return "get must be a string or function", position
			end
			if type(options.get) == "string" and type(self[options.get]) ~= "function" then
				return string.format("%q is not a proper function", options.get), position
			end
		end
		if options.set then
			if type(options.set) ~= "string" and type(options.set) ~= "function" then
				return "set must be a string or function", position
			end
			if type(options.set) == "string" and type(self[options.set]) ~= "function" then
				return string.format("%q is not a proper function", options.set), position
			end
		end
		if options.validate and type(options.validate) ~= "table" then
			if type(options.validate) ~= "string" and type(options.validate) ~= "function" then
				return "validate must be a string or function", position
			end
			if type(options.validate) == "string" and type(self[options.validate]) ~= "function" then
				return string.format("%q is not a proper function", options.validate), position
			end
		end
	end
	if options.disabled and type(options.disabled) == "string" and type(self[options.disabled]) ~= "function" then
		return string.format("%q is not a proper function", options.disabled), position
	end
	if options.cmdHidden and type(options.cmdHidden) == "string" and type(self[options.cmdHidden]) ~= "function" then
		return string.format("%q is not a proper function", options.cmdHidden), position
	end
	if options.guiHidden and type(options.guiHidden) == "string" and type(self[options.guiHidden]) ~= "function" then
		return string.format("%q is not a proper function", options.guiHidden), position
	end
	if options.hidden and type(options.hidden) == "string" and type(self[options.hidden]) ~= "function" then
		return string.format("%q is not a proper function", options.hidden), position
	end
	if options.type == "group" and type(options.args) == "table" then
		for k,v in pairs(options.args) do
			if type(v) == "table" then
				local newposition
				if position then
					newposition = position .. ".args." .. k
				else
					newposition = "args." .. k
				end
				local err, pos = validateOptionsMethods(self, v, newposition)
				if err then
					return err, pos
				end
			end
		end
	end
end

local function validateOptions(options, position, baseOptions, fromPass)
	if not baseOptions then
		baseOptions = options
	end
	if type(options) ~= "table" then
		return "Options must be a table.", position
	end
	local kind = options.type
	if type(kind) ~= "string" then
		return '"type" must be a string.', position
	elseif kind ~= "group" and kind ~= "range" and kind ~= "text" and kind ~= "execute" and kind ~= "toggle" and kind ~= "color" and kind ~= "header" then
		return '"type" must either be "range", "text", "group", "toggle", "execute", "color", or "header".', position
	end
	if options.aliases then
		if type(options.aliases) ~= "table" and type(options.aliases) ~= "string" then
			return '"alias" must be a table or string', position
		end
	end
	if not fromPass then
		if kind == "execute" then
			if type(options.func) ~= "string" and type(options.func) ~= "function" then
				return '"func" must be a string or function', position
			end
		elseif kind == "range" or kind == "text" or kind == "toggle" then
			if type(options.set) ~= "string" and type(options.set) ~= "function" then
				return '"set" must be a string or function', position
			end
			if kind == "text" and options.get == false then
			elseif type(options.get) ~= "string" and type(options.get) ~= "function" then
				return '"get" must be a string or function', position
			end
		elseif kind == "group" and options.pass then
			if options.pass ~= true then
				return '"pass" must be either nil, true, or false', position
			end
			if not options.func then
				if type(options.set) ~= "string" and type(options.set) ~= "function" then
					return '"set" must be a string or function', position
				end
				if type(options.get) ~= "string" and type(options.get) ~= "function" then
					return '"get" must be a string or function', position
				end
			elseif type(options.func) ~= "string" and type(options.func) ~= "function" then
				return '"func" must be a string or function', position
			end
		end
	else
		if kind == "group" then
			return 'cannot have "type" = "group" as a subgroup of a passing group', position
		end
	end
	if options ~= baseOptions then
		if kind == "header" then
		elseif type(options.desc) ~= "string" then
			return '"desc" must be a string', position
		elseif string.len(options.desc) == 0 then
			return '"desc" cannot be a 0-length string', position
		end
	end

	if options ~= baseOptions or kind == "range" or kind == "text" or kind == "toggle" or kind == "color" then
		if options.type == "header" and not options.cmdName and not options.name then
		elseif options.cmdName then
			if type(options.cmdName) ~= "string" then
				return '"cmdName" must be a string or nil', position
			elseif string.len(options.cmdName) == 0 then
				return '"cmdName" cannot be a 0-length string', position
			end
			if type(options.guiName) ~= "string" then
				if not options.guiNameIsMap then
					return '"guiName" must be a string or nil', position
				end
			elseif string.len(options.guiName) == 0 then
				return '"guiName" cannot be a 0-length string', position
			end
		else
			if type(options.name) ~= "string" then
				return '"name" must be a string', position
			elseif string.len(options.name) == 0 then
				return '"name" cannot be a 0-length string', position
			end
		end
	end
	if options.guiNameIsMap then
		if type(options.guiNameIsMap) ~= "boolean" then
			return '"guiNameIsMap" must be a boolean or nil', position
		elseif options.type ~= "toggle" then
			return 'if "guiNameIsMap" is true, then "type" must be set to \'toggle\'', position
		elseif type(options.map) ~= "table" then
			return '"map" must be a table', position
		end
	end
	if options.message and type(options.message) ~= "string" then
		return '"message" must be a string or nil', position
	end
	if options.error and type(options.error) ~= "string" then
		return '"error" must be a string or nil', position
	end
	if options.current and type(options.current) ~= "string" then
		return '"current" must be a string or nil', position
	end
	if options.order then
		if type(options.order) ~= "number" or (-1 < options.order and options.order < 0.999) then
			return '"order" must be a non-zero number or nil', position
		end
	end
	if options.disabled then
		if type(options.disabled) ~= "function" and type(options.disabled) ~= "string" and options.disabled ~= true then
			return '"disabled" must be a function, string, or boolean', position
		end
	end
	if options.cmdHidden then
		if type(options.cmdHidden) ~= "function" and type(options.cmdHidden) ~= "string" and options.cmdHidden ~= true then
			return '"cmdHidden" must be a function, string, or boolean', position
		end
	end
	if options.guiHidden then
		if type(options.guiHidden) ~= "function" and type(options.guiHidden) ~= "string" and options.guiHidden ~= true then
			return '"guiHidden" must be a function, string, or boolean', position
		end
	end
	if options.hidden then
		if type(options.hidden) ~= "function" and type(options.hidden) ~= "string" and options.hidden ~= true then
			return '"hidden" must be a function, string, or boolean', position
		end
	end
	if kind == "text" then
		if type(options.validate) == "table" then
			local t = options.validate
			local iTable = nil
			for k,v in pairs(t) do
				if type(k) == "number" then
					if iTable == nil then
						iTable = true
					elseif not iTable then
						return '"validate" must either have all keys be indexed numbers or strings', position
					elseif k < 1 or k > table.getn(t) then
						return '"validate" numeric keys must be indexed properly. >= 1 and <= table.getn', position
					end
				else
					if iTable == nil then
						iTable = false
					elseif iTable then
						return '"validate" must either have all keys be indexed numbers or strings', position
					end
				end
				if type(v) ~= "string" then
					return '"validate" values must all be strings', position
				end
			end
		else
			if type(options.usage) ~= "string" then
				return '"usage" must be a string', position
			elseif options.validate and type(options.validate) ~= "string" and type(options.validate) ~= "function" then
				return '"validate" must be a string, function, or table', position
			end
		end
	elseif kind == "range" then
		if options.min or options.max then
			if type(options.min) ~= "number" then
				return '"min" must be a number', position
			elseif type(options.max) ~= "number" then
				return '"max" must be a number', position
			elseif options.min >= options.max then
				return '"min" must be less than "max"', position
			end
		end
		if options.step then
			if type(options.step) ~= "number" then
				return '"step" must be a number', position
			elseif options.step < 0 then
				return '"step" must be nonnegative', position
			end
		end
		if options.isPercent and options.isPercent ~= true then
			return '"isPercent" must either be nil, true, or false', position
		end
	elseif kind == "toggle" then
		if options.map then
			if type(options.map) ~= "table" then
				return '"map" must be a table', position
			elseif type(options.map[true]) ~= "string" then
				return '"map[true]" must be a string', position
			elseif type(options.map[false]) ~= "string" then
				return '"map[false]" must be a string', position
			end
		end
	elseif kind == "color" then
		if options.hasAlpha and options.hasAlpha ~= true then
			return '"hasAlpha" must be nil, true, or false', position
		end
	elseif kind == "group" then
		if options.pass and options.pass ~= true then
			return '"pass" must be nil, true, or false', position
		end
		if type(options.args) ~= "table" then
			return '"args" must be a table', position
		end
		for k,v in pairs(options.args) do
			if type(k) ~= "string" then
				return '"args" keys must be strings', position
			elseif string.find(k, "%s") then
				return string.format('"args" keys must not include spaces. %q is not appropriate.', k), position
			elseif string.len(k) == 0 then
				return '"args" keys must not be 0-length strings.', position
			end
			if type(v) ~= "table" then
				return '"args" values must be tables', position and position .. "." .. k or k
			end
			local newposition
			if position then
				newposition = position .. ".args." .. k
			else
				newposition = "args." .. k
			end
			local err, pos = validateOptions(v, newposition, baseOptions, options.pass)
			if err then
				return err, pos
			end
		end
	end
end

local colorTable
local colorFunc
local colorCancelFunc

local order

local mysort_args
local mysort

local function printUsage(self, handler, realOptions, options, path, args, quiet, filter)
	if filter then
		filter = "^" .. string.gsub(filter, "([%(%)%.%*%+%-%[%]%?%^%$%%])", "%%%1")
	end
	local hidden, disabled = options.cmdHidden or options.hidden, options.disabled
	if hidden then
		if type(hidden) == "function" then
			hidden = hidden()
		elseif type(hidden) == "string" then
			if type(handler[handler]) ~= "function" then
				AceConsole:error(OPTION_HANDLER_NOT_FOUND, handler)
			end
			hidden = handler[hidden](handler)
		end
	end
	if hidden then
		disabled = true
	elseif disabled then
		if type(disabled) == "function" then
			disabled = disabled()
		elseif type(disabled) == "string" then
			if type(handler[disabled]) ~= "function" then
				AceConsole:error(OPTION_HANDLER_NOT_FOUND, disabled)
			end
			disabled = handler[disabled](handler)
		end
	end
	local kind = string.lower(options.type or "group")
	if disabled then
		print(string.format(OPTION_IS_DISABLED, path), realOptions.cmdName or realOptions.name or self)
	elseif kind == "text" then
		local var
		if passTable then
			if not passTable.get then
			elseif type(passTable.get) == "function" then
				var = passTable.get(passValue)
			else
				local handler = passTable.handler or handler
				if type(handler[passTable.get]) ~= "function" then
					AceConsole:error(OPTION_HANDLER_NOT_FOUND, passTable.get)
				end
				var = handler[passTable.get](handler, passValue)
			end
		else
			if not options.get then
			elseif type(options.get) == "function" then
				var = options.get()
			else
				local handler = options.handler or handler
				if type(handler[options.get]) ~= "function" then
					AceConsole:error(OPTION_HANDLER_NOT_FOUND, options.get)
				end
				var = handler[options.get](handler)
			end
		end

		local usage
		if type(options.validate) == "table" then
			if filter then
				if not order then
					order = {}
				end
				for k,v in pairs(options.validate) do
					if string.find(v, filter) then
						table.insert(order, v)
					end
				end
				usage = "{" .. table.concat(order, " || ") .. "}"
				for k in pairs(order) do
					order[k] = nil
				end
				table_setn(order, 0)
			else
				if not order then
					order = {}
				end
				for k,v in pairs(options.validate) do
					table.insert(order, v)
				end
				usage = "{" .. table.concat(order, " || ") .. "}"
				for k in pairs(order) do
					order[k] = nil
				end
				table_setn(order, 0)
			end
			var = options.validate[var] or var
		else
			usage = options.usage or "<value>"
		end
		if not quiet then
			print(string.format("|cffffff7f%s:|r %s %s", USAGE, path, usage), realOptions.cmdName or realOptions.name or self)
		end
		if (passTable and passTable.get) or options.get then
			print(string.format(options.current or IS_CURRENTLY_SET_TO, tostring(options.cmdName or options.name), tostring(var or NONE)))
		end
	elseif kind == "range" then
		local var
		if passTable then
			if type(passTable.get) == "function" then
				var = passTable.get(passValue)
			else
				local handler = passTable.handler or handler
				if type(handler[passTable.get]) ~= "function" then
					AceConsole:error(OPTION_HANDLER_NOT_FOUND, passTable.get)
				end
				var = handler[passTable.get](handler, passValue)
			end
		else
			if type(options.get) == "function" then
				var = options.get()
			else
				local handler = options.handler or handler
				if type(handler[options.get]) ~= "function" then
					AceConsole:error(OPTION_HANDLER_NOT_FOUND, options.get)
				end
				var = handler[options.get](handler)
			end
		end

		local usage
		local min = options.min or 0
		local max = options.max or 1
		if options.isPercent then
			min, max = min * 100, max * 100
			var = tostring(var * 100) .. "%"
		end
		local bit = "-"
		if min < 0 or max < 0 then
			bit = " - "
		end
		usage = string.format("(%s%s%s)", min, bit, max)
		if not quiet then
			print(string.format("|cffffff7f%s:|r %s %s", USAGE, path, usage), realOptions.cmdName or realOptions.name or self)
		end
		print(string.format(options.current or IS_CURRENTLY_SET_TO, tostring(options.cmdName or options.name), tostring(var or NONE)))
	elseif kind == "group" then
		local usage
		if next(options.args) then
			if not order then
				order = {}
			end
			for k,v in pairs(options.args) do
				if v.type ~= "header" then
					local hidden = v.cmdHidden or v.hidden
					if hidden then
						if type(hidden) == "function" then
							hidden = hidden()
						elseif type(hidden) == "string" then
							local handler = v.handler or handler
							if type(handler[hidden]) ~= "function" then
								AceConsole:error(OPTION_HANDLER_NOT_FOUND, hidden)
							end
							hidden = handler[hidden](handler)
						end
					end
					if not hidden then
						if filter then
							if string.find(k, filter) then
								table.insert(order, k)
							elseif type(v.aliases) == "table" then
								for _,bit in ipairs(v.aliases) do
									if string.find(v.aliases, filter) then
										table.insert(order, k)
										break
									end
								end
							elseif type(v.aliases) == "string" then
								if string.find(v.aliases, filter) then
									table.insert(order, k)
								end
							end
						else
							table.insert(order, k)
						end
					end
				end
			end
			if not mysort then
				mysort = function(a, b)
					local alpha, bravo = mysort_args[a], mysort_args[b]
					local alpha_order = alpha and alpha.order or 100
					local bravo_order = bravo and bravo.order or 100
					if alpha_order == bravo_order then
						return tostring(a) < tostring(b)
					else
						if alpha_order < 0 then
							if bravo_order > 0 then
								return false
							end
						else
							if bravo_order < 0 then
								return true
							end
						end
						if alpha_order > 0 and bravo_order > 0 then
							return tostring(a) < tostring(b)
						end
						return alpha_order < bravo_order
					end
				end
			end
			mysort_args = options.args
			table.sort(order, mysort)
			mysort_args = nil
			if not quiet then
				if options == realOptions then
					if options.desc then
						print(tostring(options.desc), realOptions.cmdName or realOptions.name or self)
						print(string.format("|cffffff7f%s:|r %s %s", USAGE, path, "{" .. table.concat(order, " || ") .. "}"))
					elseif self.description or self.notes then
						print(tostring(self.description or self.notes), realOptions.cmdName or realOptions.name or self)
						print(string.format("|cffffff7f%s:|r %s %s", USAGE, path, "{" .. table.concat(order, " || ") .. "}"))
					else
						print(string.format("|cffffff7f%s:|r %s %s", USAGE, path, "{" .. table.concat(order, " || ") .. "}"), realOptions.cmdName or realOptions.name or self)
					end
				else
					if options.desc then
						print(string.format("|cffffff7f%s:|r %s %s", USAGE, path, "{" .. table.concat(order, " || ") .. "}"), realOptions.cmdName or realOptions.name or self)
						print(tostring(options.desc))
					else
						print(string.format("|cffffff7f%s:|r %s %s", USAGE, path, "{" .. table.concat(order, " || ") .. "}"), realOptions.cmdName or realOptions.name or self)
					end
				end
			end
			for _,k in ipairs(order) do
				local v = options.args[k]
				if v then
					local disabled = v.disabled
					if disabled then
						if type(disabled) == "function" then
							disabled = disabled()
						elseif type(disabled) == "string" then
							local handler = v.handler or handler
							if type(handler[disabled]) ~= "function" then
								AceConsole:error(OPTION_HANDLER_NOT_FOUND, disabled)
							end
							disabled = handler[disabled](handler)
						end
					end
					if type(v.aliases) == "table" then
						k = k .. " || " .. table.concat(v.aliases, " || ")
					elseif type(v.aliases) == "string" then
						k = k .. " || " .. v.aliases
					end
					if v.get then
						local a1,a2,a3,a4
						if type(v.get) == "function" then
							if options.pass then
								a1,a2,a3,a4 = v.get(k)
							else
								a1,a2,a3,a4 = v.get()
							end
						else
							local handler = v.handler or handler
							if type(handler[v.get]) ~= "function" then
								AceConsole:error(OPTION_HANDLER_NOT_FOUND, v.get)
							end
							if options.pass then
								a1,a2,a3,a4 = handler[v.get](handler, k)
							else
								a1,a2,a3,a4 = handler[v.get](handler)
							end
						end
						if v.type == "color" then
							if v.hasAlpha then
								if not a1 or not a2 or not a3 or not a4 then
									s = NONE
								else
									s = string.format("|c%02x%02x%02x%02x%02x%02x%02x%02x|r", a4*255, a1*255, a2*255, a3*255, a4*255, a1*255, a2*255, a3*255)
								end
							else
								if not a1 or not a2 or not a3 then
									s = NONE
								else
									s = string.format("|cff%02x%02x%02x%02x%02x%02x|r", a1*255, a2*255, a3*255, a1*255, a2*255, a3*255)
								end
							end
						elseif v.type == "toggle" then
							if v.map then
								s = tostring(v.map[a1 and true or false] or NONE)
							else
								s = tostring(MAP_ONOFF[a1 and true or false] or NONE)
							end
						elseif v.type == "range" then
							if v.isPercent then
								s = tostring(a1 * 100) .. "%"
							else
								s = tostring(a1)
							end
						elseif v.type == "text" and type(v.validate) == "table" then
							s = tostring(v.validate[a1] or a1)
						else
							s = tostring(a1 or NONE)
						end
						if disabled then
							local s = string.gsub(s, "|cff%x%x%x%x%x%x(.-)|r", "%1")
							local desc = string.gsub(v.desc or NONE, "|cff%x%x%x%x%x%x(.-)|r", "%1")
							print(string.format("|cffcfcfcf - %s: [%s] %s|r", k, s, desc))
						else
							print(string.format(" - |cffffff7f%s: [|r%s|cffffff7f]|r %s", k, s, v.desc or NONE))
						end
					else
						if disabled then
							local desc = string.gsub(v.desc or NONE, "|cff%x%x%x%x%x%x(.-)|r", "%1")
							print(string.format("|cffcfcfcf - %s: %s", k, desc))
						else
							print(string.format(" - |cffffff7f%s:|r %s", k, v.desc or NONE))
						end
					end
				end
			end
			for k in pairs(order) do
				order[k] = nil
			end
			table_setn(order, 0)
		else
			if options.desc then
				desc = options.desc
				print(string.format("|cffffff7f%s:|r %s", USAGE, path), realOptions.cmdName or realOptions.name or self)
				print(tostring(options.desc))
			elseif options == realOptions and (self.description or self.notes) then
				print(tostring(self.description or self.notes), realOptions.cmdName or realOptions.name or self)
				print(string.format("|cffffff7f%s:|r %s", USAGE, path))
			else
				print(string.format("|cffffff7f%s:|r %s", USAGE, path), realOptions.cmdName or realOptions.name or self)
			end
			print(self, NO_OPTIONS_AVAILABLE)
		end
	end
end

local function handlerFunc(self, chat, msg, options)
	if not msg then
		msg = ""
	else
		msg = string.gsub(msg, "^%s*(.-)%s*$", "%1")
		msg = string.gsub(msg, "%s+", " ")
	end

	local realOptions = options
	local options, path, args, handler, passTable, passValue = findTableLevel(self, options, chat, msg)

	local hidden, disabled = options.cmdHidden or options.hidden, options.disabled
	if hidden then
		if type(hidden) == "function" then
			hidden = hidden()
		elseif type(hidden) == "string" then
			if type(handler[hidden]) ~= "function" then
				AceConsole:error(OPTION_HANDLER_NOT_FOUND, hidden)
			end
			hidden = handler[hidden](handler)
		end
	end
	if hidden then
		disabled = true
	elseif disabled then
		if type(disabled) == "function" then
			disabled = disabled()
		elseif type(disabled) == "string" then
			if type(handler[disabled]) ~= "function" then
				AceConsole:error(OPTION_HANDLER_NOT_FOUND, disabled)
			end
			disabled = handler[disabled](handler)
		end
	end
	local _G_this = this
	local kind = string.lower(options.type or "group")
	if disabled then
		print(string.format(OPTION_IS_DISABLED, path), realOptions.cmdName or realOptions.name or self)
	elseif kind == "text" then
		if table.getn(args) > 0 then
			if (type(options.validate) == "table" and table.getn(args) > 1) or (type(options.validate) ~= "table" and not options.input) then
				local arg = table.concat(args, " ")
				for k,v in pairs(args) do
					args[k] = nil
				end
				table_setn(args, 0)
				table.insert(args, arg)
			end
			if options.validate then
				local good
				if type(options.validate) == "function" then
					good = options.validate(unpack(args))
				elseif type(options.validate) == "table" then
					local arg = args[1]
					arg = string.lower(tostring(arg))
					for k,v in pairs(options.validate) do
						if string.lower(v) == arg then
							args[1] = type(k) == "string" and k or v
							good = true
							break
						end
					end
					if not good and type((next(options.validate))) == "string" then
						for k,v in pairs(options.validate) do
							if type(k) == "string" and string.lower(k) == arg then
								args[1] = k
								good = true
								break
							end
						end
					end
				else
					if type(handler[options.validate]) ~= "function" then
						AceConsole:error(OPTION_HANDLER_NOT_FOUND, options.validate)
					end
					good = handler[options.validate](handler, unpack(args))
				end
				if not good then
					local usage
					if type(options.validate) == "table" then
						if not order then
							order = {}
						end
						for k,v in pairs(options.validate) do
							table.insert(order, v)
						end
						usage = "{" .. table.concat(order, " || ") .. "}"
						for k in pairs(order) do
							order[k] = nil
						end
						table_setn(order, 0)
					else
						usage = options.usage or "<value>"
					end
					print(string.format(options.error or IS_NOT_A_VALID_OPTION_FOR, tostring(table.concat(args, " ")), path), realOptions.cmdName or realOptions.name or self)
					print(string.format("|cffffff7f%s:|r %s %s", USAGE, path, usage))
					return
				end
			end

			local var
			if passTable then
				if not passTable.get then
				elseif type(passTable.get) == "function" then
					var = passTable.get(passValue)
				else
					if type(handler[passTable.get]) ~= "function" then
						AceConsole:error(OPTION_HANDLER_NOT_FOUND, passTable.get)
					end
					var = handler[passTable.get](handler, passValue)
				end
			else
				if not options.get then
				elseif type(options.get) == "function" then
					var = options.get()
				else
					if type(handler[options.get]) ~= "function" then
						AceConsole:error(OPTION_HANDLER_NOT_FOUND, options.get)
					end
					var = handler[options.get](handler)
				end
			end

			if var ~= args[1] then
				if passTable then
					if type(passTable.set) == "function" then
						passTable.set(passValue, unpack(args))
					else
						if type(handler[passTable.set]) ~= "function" then
							AceConsole:error(OPTION_HANDLER_NOT_FOUND, passTable.set)
						end
						handler[passTable.set](handler, passTable.set, unpack(args))
					end
				else
					if type(options.set) == "function" then
						options.set(unpack(args))
					else
						if type(handler[options.set]) ~= "function" then
							AceConsole:error(OPTION_HANDLER_NOT_FOUND, options.set)
						end
						handler[options.set](handler, unpack(args))
					end
				end
			end
		end

		if table.getn(args) > 0 then
			local var
			if passTable then
				if not passTable.get then
				elseif type(passTable.get) == "function" then
					var = passTable.get(passValue)
				else
					if type(handler[passTable.get]) ~= "function" then
						AceConsole:error(OPTION_HANDLER_NOT_FOUND, passTable.get)
					end
					var = handler[passTable.get](handler, passValue)
				end
			else
				if not options.get then
				elseif type(options.get) == "function" then
					var = options.get()
				else
					if type(handler[options.get]) ~= "function" then
						AceConsole:error(OPTION_HANDLER_NOT_FOUND, options.get)
					end
					var = handler[options.get](handler)
				end
			end
			if type(options.validate) == "table" then
				var = options.validate[var] or var
			end
			if (passTable and passTable.get) or options.get then
				print(string.format(options.message or IS_NOW_SET_TO, tostring(options.cmdName or options.name), tostring(var or NONE)), realOptions.cmdName or realOptions.name or self)
			end
			if var == args[1] then
				return
			end
		else
			printUsage(self, handler, realOptions, options, path, args)
			return
		end
	elseif kind == "execute" then
		if passTable then
			if type(passFunc) == "function" then
				set(passValue)
			else
				if type(handler[passFunc]) ~= "function" then
					AceConsole:error(OPTION_HANDLER_NOT_FOUND, passFunc)
				end
				handler[passFunc](handler, passValue)
			end
		else
			local ret, msg
			if type(options.func) == "function" then
				options.func()
			else
				local handler = options.handler or self
				if type(handler[options.func]) ~= "function" then
					AceConsole:error(OPTION_HANDLER_NOT_FOUND, options.func)
				end
				handler[options.func](handler)
			end
		end
	elseif kind == "toggle" then
		local var
		if passTable then
			if type(passTable.get) == "function" then
				var = passTable.get(passValue)
			else
				if type(handler[passTable.get]) ~= "function" then
					AceConsole:error(OPTION_HANDLER_NOT_FOUND, passTable.get)
				end
				var = handler[passTable.get](handler, passValue)
			end
			if type(passTable.set) == "function" then
				passTable.set(passValue, not var)
			else
				if type(handler[passTable.set]) ~= "function" then
					AceConsole:error(OPTION_HANDLER_NOT_FOUND, passTable.set)
				end
				handler[passTable.set](handler, passValue, not var)
			end
			if type(passTable.get) == "function" then
				var = passTable.get(passValue)
			else
				var = handler[passTable.get](handler, passValue)
			end
		else
			local handler = options.handler or self
			if type(options.get) == "function" then
				var = options.get()
			else
				if type(handler[options.get]) ~= "function" then
					AceConsole:error(OPTION_HANDLER_NOT_FOUND, options.get)
				end
				var = handler[options.get](handler)
			end
			if type(options.set) == "function" then
				options.set(not var)
			else
				if type(handler[options.set]) ~= "function" then
					AceConsole:error(OPTION_HANDLER_NOT_FOUND, options.set)
				end
				handler[options.set](handler, not var)
			end
			if type(options.get) == "function" then
				var = options.get()
			else
				var = handler[options.get](handler)
			end
		end

		print(string.format(options.message or IS_NOW_SET_TO, tostring(options.cmdName or options.name), (options.map or MAP_ONOFF)[var and true or false] or NONE), realOptions.cmdName or realOptions.name or self)
	elseif kind == "range" then
		local arg
		if table.getn(args) <= 1 then
			arg = args[1]
		else
			arg = table.concat(args, " ")
		end

		if arg then
			local min = options.min or 0
			local max = options.max or 1
			local good = false
			if type(arg) == "number" then
				if options.isPercent then
					arg = arg / 100
				end

				if arg >= min and arg <= max then
					good = true
				end

				if good and type(options.step) == "number" and options.step > 0 then
					local step = options.step
					arg = math.floor((arg - min) / step + 0.5) * step + min
					if arg > max then
						arg = max
					elseif arg < min then
						arg = min
					end
				end
			end
			if not good then
				local usage
				local min = options.min or 0
				local max = options.max or 1
				if options.isPercent then
					min, max = min * 100, max * 100
				end
				local bit = "-"
				if min < 0 or max < 0 then
					bit = " - "
				end
				usage = string.format("(%s%s%s)", min, bit, max)
				print(string.format(options.error or IS_NOT_A_VALID_VALUE_FOR, tostring(arg), path), realOptions.cmdName or realOptions.name or self)
				print(string.format("|cffffff7f%s:|r %s %s", USAGE, path, usage))
				return
			end

			local var
			if passTable then
				if type(passTable.get) == "function" then
					var = passTable.get(passValue)
				else
					if type(handler[passTable.get]) ~= "function" then
						AceConsole:error(OPTION_HANDLER_NOT_FOUND, passTable.get)
					end
					var = handler[passTable.get](handler, passValue)
				end
			else
				if type(options.get) == "function" then
					var = options.get()
				else
					local handler = options.handler or self
					if type(handler[options.get]) ~= "function" then
						AceConsole:error(OPTION_HANDLER_NOT_FOUND, options.get)
					end
					var = handler[options.get](handler)
				end
			end

			if var ~= arg then
				if passTable then
					if type(passTable.set) == "function" then
						passTable.set(passValue, arg)
					else
						if type(handler[passTable.set]) ~= "function" then
							AceConsole:error(OPTION_HANDLER_NOT_FOUND, passTable.set)
						end
						handler[passTable.set](handler, passValue, arg)
					end
				else
					if type(options.set) == "function" then
						options.set(arg)
					else
						local handler = options.handler or self
						if type(handler[options.set]) ~= "function" then
							AceConsole:error(OPTION_HANDLER_NOT_FOUND, options.set)
						end
						handler[options.set](handler, arg)
					end
				end
			end
		end

		if arg then
			local var
			if passTable then
				if type(passTable.get) == "function" then
					var = passTable.get(passValue)
				else
					if type(handler[passTable.get]) ~= "function" then
						AceConsole:error(OPTION_HANDLER_NOT_FOUND, passTable.get)
					end
					var = handler[passTable.get](handler, passValue)
				end
			else
				if type(options.get) == "function" then
					var = options.get()
				else
					local handler = options.handler or self
					if type(handler[options.get]) ~= "function" then
						AceConsole:error(OPTION_HANDLER_NOT_FOUND, options.get)
					end
					var = handler[options.get](handler)
				end
			end

			if var and options.isPercent then
				var = tostring(var * 100) .. "%"
			end
			print(string.format(options.message or IS_NOW_SET_TO, tostring(options.cmdName or options.name), tostring(var or NONE)), realOptions.cmdName or realOptions.name or self)
			if var == arg then
				return
			end
		else
			printUsage(self, handler, realOptions, options, path, args)
			return
		end
	elseif kind == "color" then
		if table.getn(args) > 0 then
			local r,g,b,a
			if table.getn(args) == 1 then
				local arg = tostring(args[1])
				if options.hasAlpha then
					if string.len(arg) == 8 and string.find(arg, "^%x*$")  then
						r,g,b,a = tonumber(string.sub(arg, 1, 2), 16) / 255, tonumber(string.sub(arg, 3, 4), 16) / 255, tonumber(string.sub(arg, 5, 6), 16) / 255, tonumber(string.sub(arg, 7, 8), 16) / 255
					end
				else
					if string.len(arg) == 6 and string.find(arg, "^%x*$") then
						r,g,b = tonumber(string.sub(arg, 1, 2), 16) / 255, tonumber(string.sub(arg, 3, 4), 16) / 255, tonumber(string.sub(arg, 5, 6), 16) / 255
					end
				end
			elseif table.getn(args) == 4 and options.hasAlpha then
				local a1,a2,a3,a4 = args[1], args[2], args[3], args[4]
				if type(a1) == "number" and type(a2) == "number" and type(a3) == "number" and type(a4) == "number" and a1 <= 1 and a2 <= 1 and a3 <= 1 and a4 <= 1 then
					r,g,b,a = a1,a2,a3,a4
				elseif (type(a1) == "number" or string.len(a1) == 2) and string.find(a1, "^%x*$") and (type(a2) == "number" or string.len(a2) == 2) and string.find(a2, "^%x*$") and (type(a3) == "number" or string.len(a3) == 2) and string.find(a3, "^%x*$") and (type(a4) == "number" or string.len(a4) == 2) and string.find(a4, "^%x*$") then
					r,g,b,a = tonumber(a1, 16) / 255, tonumber(a2, 16) / 255, tonumber(a3, 16) / 255, tonumber(a4, 16) / 255
				end
			elseif table.getn(args) == 3 and not options.hasAlpha then
				local a1,a2,a3 = args[1], args[2], args[3]
				if type(a1) == "number" and type(a2) == "number" and type(a3) == "number" and a1 <= 1 and a2 <= 1 and a3 <= 1 then
					r,g,b = a1,a2,a3
				elseif (type(a1) == "number" or string.len(a1) == 2) and string.find(a1, "^%x*$") and (type(a2) == "number" or string.len(a2) == 2) and string.find(a2, "^%x*$") and (type(a3) == "number" or string.len(a3) == 2) and string.find(a3, "^%x*$") then
					r,g,b = tonumber(a1, 16) / 255, tonumber(a2, 16) / 255, tonumber(a3, 16) / 255
				end
			end
			if not r then
				print(string.format(options.error or IS_NOT_A_VALID_OPTION_FOR, table.concat(args, ' '), path), realOptions.cmdName or realOptions.name or self)
				print(string.format("|cffffff7f%s:|r %s {0-1} {0-1} {0-1}%s", USAGE, path, options.hasAlpha and " {0-1}" or ""))
				return
			end
			if passTable then
				if type(passTable.set) == "function" then
					passTable.set(passValue, r,g,b,a)
				else
					if type(handler[passTable.set]) ~= "function" then
						AceConsole:error(OPTION_HANDLER_NOT_FOUND, passTable.set)
					end
					handler[passTable.set](handler, passValue, r,g,b,a)
				end
			else
				if type(options.set) == "function" then
					options.set(r,g,b,a)
				else
					if type(handler[options.set]) ~= "function" then
						AceConsole:error(OPTION_HANDLER_NOT_FOUND, options.set)
					end
					handler[options.set](handler, r,g,b,a)
				end
			end

			local r,g,b,a
			if passTable then
				if type(passTable.get) == "function" then
					r,g,b,a = passTable.get(passValue)
				else
					if type(handler[passTable.get]) ~= "function" then
						AceConsole:error(OPTION_HANDLER_NOT_FOUND, passTable.get)
					end
					r,g,b,a = handler[passTable.get](handler, passValue)
				end
			else
				if type(options.get) == "function" then
					r,g,b,a = options.get()
				else
					if type(handler[options.get]) ~= "function" then
						AceConsole:error(OPTION_HANDLER_NOT_FOUND, options.get)
					end
					r,g,b,a = handler[options.get](handler)
				end
			end

			local s
			if type(r) == "number" and type(g) == "number" and type(b) == "number" then
				if options.hasAlpha and type(a) == "number" then
					s = string.format("|c%02x%02x%02x%02x%02x%02x%02x%02x|r", a*255, r*255, g*255, b*255, r*255, g*255, b*255, a*255)
				else
					s = string.format("|cff%02x%02x%02x%02x%02x%02x|r", r*255, g*255, b*255, r*255, g*255, b*255)
				end
			else
				s = NONE
			end
			print(string.format(options.message or IS_NOW_SET_TO, tostring(options.cmdName or options.name), s), realOptions.cmdName or realOptions.name or self)
		else
			local r,g,b,a
			if passTable then
				if type(passTable.get) == "function" then
					r,g,b,a = passTable.get(passValue)
				else
					if type(handler[passTable.get]) ~= "function" then
						AceConsole:error(OPTION_HANDLER_NOT_FOUND, passTable.get)
					end
					r,g,b,a = handler[passTable.get](handler, passValue)
				end
			else
				if type(options.get) == "function" then
					r,g,b,a = options.get()
				else
					if type(handler[options.get]) ~= "function" then
						AceConsole:error(OPTION_HANDLER_NOT_FOUND, options.get)
					end
					r,g,b,a = handler[options.get](handler)
				end
			end

			if not colorTable then
				colorTable = {}
				local t = colorTable

				if ColorPickerOkayButton then
					local ColorPickerOkayButton_OnClick = ColorPickerOkayButton:GetScript("OnClick")
					ColorPickerOkayButton:SetScript("OnClick", function()
						if ColorPickerOkayButton_OnClick then
							ColorPickerOkayButton_OnClick()
						end
						if t.active then
							ColorPickerFrame.cancelFunc = nil
							ColorPickerFrame.func = nil
							ColorPickerFrame.opacityFunc = nil
							local r,g,b,a
							if t.passValue then
								if type(t.get) == "function" then
									r,g,b,a = t.get(t.passValue)
								else
									if type(t.handler[t.get]) ~= "function" then
										AceConsole:error(OPTION_HANDLER_NOT_FOUND, t.get)
									end
									r,g,b,a = t.handler[t.get](t.handler, t.passValue)
								end
							else
								if type(t.get) == "function" then
									r,g,b,a = t.get()
								else
									if type(t.handler[t.get]) ~= "function" then
										AceConsole:error(OPTION_HANDLER_NOT_FOUND, t.get)
									end
									r,g,b,a = t.handler[t.get](t.handler)
								end
							end
							if r ~= t.r or g ~= t.g or b ~= t.b or (t.hasAlpha and a ~= t.a) then
								local s
								if type(r) == "number" and type(g) == "number" and type(b) == "number" then
									if t.hasAlpha and type(a) == "number" then
										s = string.format("|c%02x%02x%02x%02x%02x%02x%02x%02x|r", a*255, r*255, g*255, b*255, r*255, g*255, b*255, a*255)
									else
										s = string.format("|cff%02x%02x%02x%02x%02x%02x|r", r*255, g*255, b*255, r*255, g*255, b*255)
									end
								else
									s = NONE
								end
								print(string.format(t.message, tostring(t.name), s), t.realOptions.cmdName or t.realOptions.name or self)
							end
							for k,v in pairs(t) do
								t[k] = nil
							end
						end
					end)
				end
			else
				for k,v in pairs(colorTable) do
					colorTable[k] = nil
				end
			end

			if type(r) ~= "number" or type(g) ~= "number" or type(b) ~= "number" then
				r,g,b = 1, 1, 1
			end
			if type(a) ~= "number" then
				a = 1
			end
			local t = colorTable
			t.r = r
			t.g = g
			t.b = b
			if hasAlpha then
				t.a = a
			end
			t.realOptions = realOptions
			t.hasAlpha = options.hasAlpha
			t.handler = handler
			t.set = passTable and passTable.set or options.set
			t.get = passTable and passTable.get or options.get
			t.name = options.cmdName or options.name
			t.message = options.message or IS_NOW_SET_TO
			t.passValue = passValue
			t.active = true

			if not colorFunc then
				colorFunc = function()
					local r,g,b = ColorPickerFrame:GetColorRGB()
					if t.hasAlpha then
						local a = 1 - OpacitySliderFrame:GetValue()
						if type(t.set) == "function" then
							if t.passValue then
								t.set(t.passValue, r,g,b,a)
							else
								t.set(r,g,b,a)
							end
						else
							if type(t.handler[t.set]) ~= "function" then
								AceConsole:error(OPTION_HANDLER_NOT_FOUND, t.set)
							end
							if t.passValue then
								t.handler[t.set](t.handler, t.passValue, r,g,b,a)
							else
								t.handler[t.set](t.handler, r,g,b,a)
							end
						end
					else
						if type(t.set) == "function" then
							if t.passValue then
								t.set(t.passValue, r,g,b)
							else
								t.set(r,g,b)
							end
						else
							if type(t.handler[t.set]) ~= "function" then
								AceConsole:error(OPTION_HANDLER_NOT_FOUND, t.set)
							end
							if t.passValue then
								t.handler[t.set](t.handler, t.passValue, r,g,b)
							else
								t.handler[t.set](t.handler, r,g,b)
							end
						end
					end
				end
			end

			ColorPickerFrame.func = colorFunc
			ColorPickerFrame.hasOpacity = options.hasAlpha
			if options.hasAlpha then
				ColorPickerFrame.opacityFunc = ColorPickerFrame.func
				ColorPickerFrame.opacity = 1 - a
			end
			ColorPickerFrame:SetColorRGB(r,g,b)

			if not colorCancelFunc then
				colorCancelFunc = function()
					if t.hasAlpha then
						if type(t.set) == "function" then
							if t.passValue then
								t.set(t.passValue, t.r,t.g,t.b,t.a)
							else
								t.set(t.r,t.g,t.b,t.a)
							end
						else
							if type(t.handler[t.get]) ~= "function" then
								AceConsole:error(OPTION_HANDLER_NOT_FOUND, t.get)
							end
							if t.passValue then
								t.handler[t.set](t.handler, t.passValue, t.r,t.g,t.b,t.a)
							else
								t.handler[t.set](t.handler, t.r,t.g,t.b,t.a)
							end
						end
					else
						if type(t.set) == "function" then
							if t.passValue then
								t.set(t.passValue, t.r,t.g,t.b)
							else
								t.set(t.r,t.g,t.b)
							end
						else
							if type(t.handler[t.set]) ~= "function" then
								AceConsole:error(OPTION_HANDLER_NOT_FOUND, t.set)
							end
							if t.passValue then
								t.handler[t.set](t.handler, t.passValue, t.r,t.g,t.b)
							else
								t.handler[t.set](t.handler, t.r,t.g,t.b)
							end
						end
					end
					for k,v in pairs(t) do
						t[k] = nil
					end
					ColorPickerFrame.cancelFunc = nil
					ColorPickerFrame.func = nil
					ColorPickerFrame.opacityFunc = nil
				end
			end

			ColorPickerFrame.cancelFunc = colorCancelFunc

			ShowUIPanel(ColorPickerFrame)
		end
		return
	elseif kind == "group" then
		if table.getn(args) == 0 then
			printUsage(self, handler, realOptions, options, path, args)
		else
			-- invalid argument
			print(string.format(options.error or IS_NOT_A_VALID_OPTION_FOR, args[1], path), realOptions.cmdName or realOptions.name or self)
		end
		return
	end
	this = _G_this
	if Dewdrop then
		Dewdrop:Refresh(1)
		Dewdrop:Refresh(2)
		Dewdrop:Refresh(3)
		Dewdrop:Refresh(4)
		Dewdrop:Refresh(5)
	end
end

local external
function AceConsole:RegisterChatCommand(slashCommands, options, name)
	if type(slashCommands) ~= "table" and slashCommands ~= false then
		AceConsole:error("Bad argument #2 to `RegisterChatCommand' (expected table, got %s)", type(slashCommands))
	end
	if not slashCommands and type(name) ~= "string" then
		AceConsole:error("Bad argument #4 to `RegisterChatCommand' (expected string, got %s)", type(name))
	end
	if type(options) ~= "table" and type(options) ~= "function" and options ~= nil then
		AceConsole:error("Bad argument #3 to `RegisterChatCommand' (expected table, function, or nil, got %s)", type(options))
	end
	if name then
		if type(name) ~= "string" then
			AceConsole:error("Bad argument #4 to `RegisterChatCommand' (expected string or nil, got %s)", type(name))
		elseif not string.find(name, "^%w+$") or string.upper(name) ~= name or string.len(name) == 0 then
			AceConsole:error("Argument #4 must be an uppercase, letters-only string with at least 1 character")
		end
	end
	if slashCommands then
		if table.getn(slashCommands) == 0 then
			AceConsole:error("Argument #2 to `RegisterChatCommand' must include at least one string")
		end

		for k,v in pairs(slashCommands) do
			if type(k) ~= "number" then
				AceConsole:error("All keys in argument #2 to `RegisterChatCommand' must be numbers")
			end
			if type(v) ~= "string" then
				AceConsole:error("All values in argument #2 to `RegisterChatCommand' must be strings")
			elseif not string.find(v, "^/[A-Za-z][A-Za-z0-9_]*$") then
				AceConsole:error("All values in argument #2 to `RegisterChatCommand' must be in the form of \"/word\"")
			end
		end
	end

	if not options then
		options = {
			type = 'group',
			args = {},
			handler = self
		}
	end

	if type(options) == "table" then
		local err, position = validateOptions(options)
		if err then
			if position then
				AceConsole:error(position .. ": " .. err)
			else
				AceConsole:error(err)
			end
		end

		if not options.handler then
			options.handler = self
		end

		if options.handler == self and string.lower(options.type) == "group" and self.class then
			AceConsole:InjectAceOptionsTable(self, options)
		end
	end

	local chat
	if slashCommands then
		chat = slashCommands[1]
	else
		chat = _G["SLASH_"..name..1]
	end

	local handler
	if type(options) == "function" then
		handler = options
		for k,v in pairs(_G) do
			if handler == v then
				local k = k
				handler = function(msg)
					return _G[k](msg)
				end
			end
		end
	else
		function handler(msg)
			handlerFunc(self, chat, msg, options)
		end
	end

	if not _G.SlashCmdList then
		_G.SlashCmdList = {}
	end

	if not name then
		repeat
			name = string.char(math.random(26) + string.byte('A') - 1) .. string.char(math.random(26) + string.byte('A') - 1) .. string.char(math.random(26) + string.byte('A') - 1) .. string.char(math.random(26) + string.byte('A') - 1) .. string.char(math.random(26) + string.byte('A') - 1) .. string.char(math.random(26) + string.byte('A') - 1) .. string.char(math.random(26) + string.byte('A') - 1) .. string.char(math.random(26) + string.byte('A') - 1)
		until not _G.SlashCmdList[name]
	end

	if slashCommands then
		if _G.SlashCmdList[name] then
			local i = 0
			while true do
				i = i + 1
				if _G["SLASH_"..name..i] then
					_G["SLASH_"..name..i] = nil
				else
					break
				end
			end
		end

		local i = 0
		for _,command in ipairs(slashCommands) do
			i = i + 1
			_G["SLASH_"..name..i] = command
			if string.lower(command) ~= command then
				i = i + 1
				_G["SLASH_"..name..i] = string.lower(command)
			end
		end
	end
	_G.SlashCmdList[name] = handler
	if self ~= AceConsole and self.slashCommand == nil then
		self.slashCommand = chat
	end

	if not AceEvent and AceLibrary:HasInstance("AceEvent-2.0") then
		external(AceConsole, "AceEvent-2.0", AceLibrary("AceEvent-2.0"))
	end
	if AceEvent then
		if not AceConsole.nextAddon then
			AceConsole.nextAddon = {}
		end
		if type(options) == "table" then
			AceConsole.nextAddon[self] = options
			if not self.playerLogin then
				AceConsole:RegisterEvent("PLAYER_LOGIN", "PLAYER_LOGIN", true)
			end
		end
	end

	AceConsole.registry[name] = options
end

function AceConsole:InjectAceOptionsTable(handler, options)
	self:argCheck(handler, 2, "table")
	self:argCheck(options, 3, "table")
	if string.lower(options.type) ~= "group" then
		self:error('Cannot inject into options table argument #3 if its type is not "group"')
	end
	if options.handler ~= nil and options.handler ~= handler then
		self:error("Cannot inject into options table argument #3 if it has a different handler than argument #2")
	end
	options.handler = handler
	local class = handler.class
	if not class then
		self:error("Cannot retrieve AceOptions tables from a non-object argument #2")
	end
	while class and class ~= AceOO.Class do
		if type(class.GetAceOptionsDataTable) == "function" then
			local t = class:GetAceOptionsDataTable(handler)
			for k,v in pairs(t) do
				if type(options.args) ~= "table" then
					options.args = {}
				end
				if options.args[k] == nil then
					options.args[k] = v
				end
			end
		end
		local mixins = class.mixins
		if mixins then
			for mixin in pairs(mixins) do
				if type(mixin.GetAceOptionsDataTable) == "function" then
					local t = mixin:GetAceOptionsDataTable(handler)
					for k,v in pairs(t) do
						if type(options.args) ~= "table" then
							options.args = {}
						end
						if options.args[k] == nil then
							options.args[k] = v
						end
					end
				end
			end
		end
		class = class.super
	end
	return options
end

function AceConsole:PLAYER_LOGIN()
	self.playerLogin = true
	for addon, options in pairs(self.nextAddon) do
		local err, position = validateOptionsMethods(addon, options)
		if err then
			if position then
				error(tostring(addon) .. ": AceConsole: " .. position .. ": " .. err)
			else
				error(tostring(addon) .. ": AceConsole: " .. err)
			end
		end
		self.nextAddon[addon] = nil
	end

	self:RegisterChatCommand({ "/reload", "/rl", "/reloadui" }, ReloadUI, "RELOAD")

	local version = GetBuildInfo()
	if string.find(version, "^2%.") then
		-- 2.0.0
		self:RegisterChatCommand({ "/print" }, function(text)
			RunScript("local function func(...) local arg = {...}; for k = 1,select('#', ...) do arg[k] = tostring(arg[k]) end DEFAULT_CHAT_FRAME:AddMessage(table.concat(arg, ' ')) end func(" .. text .. ")")
		end, "PRINT")
	else
		self:RegisterChatCommand({ "/print" }, function(text)
			RunScript("local function func(...) for k = 1,table.getn(arg) do arg[k] = tostring(arg[k]) end DEFAULT_CHAT_FRAME:AddMessage(table.concat(arg, ' ')) end func(" .. text .. ")")
		end, "PRINT")
	end
end

function AceConsole:TabCompleteInfo(cmdpath)
	local _, _, cmd =  string.find(cmdpath, "(/%S+)")
	if not cmd then
		return
	end
	local path = string.sub(cmdpath, string.len(cmd) + 2)
	for name in pairs(SlashCmdList) do --global
		if AceConsole.registry[name] then
			local i = 0
			while true do
				i = i + 1
				local scmd = _G["SLASH_"..name..i]
				if not scmd then break end
				if cmd == scmd then
					return name, cmd, path
				end
			end
		end
	end
end

function external(self, major, instance)
	if major == "AceEvent-2.0" then
		if not AceEvent then
			AceEvent = instance

			AceEvent:embed(self)
		end
	elseif major == "AceTab-2.0" then
		instance:RegisterTabCompletion("AceConsole", "%/.*", function(t, cmdpath, pos)
			local ac = AceLibrary("AceConsole-2.0")
			local name, cmd, path = ac:TabCompleteInfo(string.sub(cmdpath, 1, pos))

			if not ac.registry[name] then
				return false
			else
				local validArgs = findTableLevel(ac, ac.registry[name], cmd, path or "")
				if validArgs.args then
					for arg in pairs(validArgs.args) do
						table.insert(t, arg)
					end
				end
			end
		end, function(u, matches, gcs, cmdpath)
			local ac = AceLibrary("AceConsole-2.0")
			local name, cmd, path = ac:TabCompleteInfo(cmdpath)
			if ac.registry[name] then
				local validArgs, path2, argwork = findTableLevel(ac, ac.registry[name], cmd, path)
				printUsage(ac, validArgs.handler, ac.registry[name], validArgs, path2, argwork, not gcs or gcs ~= "", gcs)
			end
		end)
	elseif major == "Dewdrop-2.0" then
		Dewdrop = instance
	end
end

local function activate(self, oldLib, oldDeactivate)
	AceConsole = self

	self.super.activate(self, oldLib, oldDeactivate)

	if oldLib then
		self.registry = oldLib.registry
		self.nextAddon = oldLib.nextAddon
	end
	if not self.registry then
		self.registry = {}
	else
		for name,options in pairs(self.registry) do
			self:RegisterChatCommand(false, options, name)
		end
	end

	if oldDeactivate then
		oldDeactivate(oldLib)
	end
end

AceLibrary:Register(AceConsole, MAJOR_VERSION, MINOR_VERSION, activate, nil, external)
AceConsole = AceLibrary(MAJOR_VERSION)
