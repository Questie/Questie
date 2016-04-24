--[[
Name: AceConsole-2.0
Revision: $Rev: 1091 $
Developed by: The Ace Development Team (http://www.wowace.com/index.php/The_Ace_Development_Team)
Inspired By: Ace 1.x by Turan (turan@gryphon.com)
Website: http://www.wowace.com/
Documentation: http://www.wowace.com/index.php/AceConsole-2.0
SVN: http://svn.wowace.com/wowace/trunk/Ace2/AceConsole-2.0
Description: Mixin to allow for input/output capabilities. This uses the
             AceOptions data table format to determine input.
             http://www.wowace.com/index.php/AceOptions_data_table
Dependencies: AceLibrary, AceOO-2.0
License: LGPL v2.1
]]

local MAJOR_VERSION = "AceConsole-2.0"
local MINOR_VERSION = 90000 + tonumber(("$Revision: 1091 $"):match("(%d+)"))

if not AceLibrary then error(MAJOR_VERSION .. " requires AceLibrary.") end
if not AceLibrary:IsNewVersion(MAJOR_VERSION, MINOR_VERSION) then return end

if not AceLibrary:HasInstance("AceOO-2.0") then error(MAJOR_VERSION .. " requires AceOO-2.0.") end

local WotLK = select(4,GetBuildInfo()) >= 30000

-- #AUTODOC_NAMESPACE AceConsole

local MAP_ONOFF, USAGE, IS_CURRENTLY_SET_TO, IS_NOW_SET_TO, IS_NOT_A_VALID_OPTION_FOR, IS_NOT_A_VALID_VALUE_FOR, NO_OPTIONS_AVAILABLE, OPTION_HANDLER_NOT_FOUND, OPTION_HANDLER_NOT_VALID, OPTION_IS_DISABLED, KEYBINDING_USAGE, DEFAULT_CONFIRM_MESSAGE
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
	KEYBINDING_USAGE = "<ALT-CTRL-SHIFT-KEY>" -- fix
	DEFAULT_CONFIRM_MESSAGE = "Are you sure you want to perform `%s'?" -- fix
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
	KEYBINDING_USAGE = "<ALT-CTRL-SHIFT-KEY>" -- fix
	DEFAULT_CONFIRM_MESSAGE = "Are you sure you want to perform `%s'?" -- fix
elseif GetLocale() == "koKR" then
	MAP_ONOFF = { [false] = "|cffff0000끔|r", [true] = "|cff00ff00켬|r" }
	USAGE = "사용법"
	IS_CURRENTLY_SET_TO = "|cffffff7f%s|r|1은;는; 현재 상태는 |cffffff7f[|r%s|cffffff7f]|r|1으로;로; 설정되어 있습니다."
	IS_NOW_SET_TO = "|cffffff7f%s|r|1을;를; |cffffff7f[|r%s|cffffff7f]|r 상태로 변경합니다."
	IS_NOT_A_VALID_OPTION_FOR = "[|cffffff7f%s|r]|1은;는; |cffffff7f%s|r에서 사용 불가능한 설정입니다."
	IS_NOT_A_VALID_VALUE_FOR = "[|cffffff7f%s|r]|1은;는; |cffffff7f%s|r에서 사용 불가능한 설정 값입니다."
	NO_OPTIONS_AVAILABLE = "가능한 설정이 없습니다."
	OPTION_HANDLER_NOT_FOUND = "설정 조정 값인 |cffffff7f%q|r|1을;를; 찾지 못했습니다."
	OPTION_HANDLER_NOT_VALID = "설정 조정 값이 올바르지 않습니다."
	OPTION_IS_DISABLED = "|cffffff7f%s|r 설정은 사용할 수 없습니다."
	KEYBINDING_USAGE = "<ALT-CTRL-SHIFT-KEY>"
	DEFAULT_CONFIRM_MESSAGE = "정말 당신은 `%s'|1을;를; 하시겠습니까?"
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
	KEYBINDING_USAGE = "<ALT-CTRL-SHIFT-KEY>" -- fix
	DEFAULT_CONFIRM_MESSAGE = "Are you sure you want to perform `%s'?" -- fix
elseif GetLocale() == "zhTW" then
	MAP_ONOFF = { [false] = "|cffff0000關閉|r", [true] = "|cff00ff00開啟|r" }
	USAGE = "用法"
	IS_CURRENTLY_SET_TO = "|cffffff7f%s|r目前的設定為|cffffff7f[|r%s|cffffff7f]|r"
	IS_NOW_SET_TO = "|cffffff7f%s|r現在被設定為|cffffff7f[|r%s|cffffff7f]|r"
	IS_NOT_A_VALID_OPTION_FOR = "對於|cffffff7f%2$s|r，[|cffffff7f%1$s|r]是一個不符合規定的選項"
	IS_NOT_A_VALID_VALUE_FOR = "對於|cffffff7f%2$s|r，[|cffffff7f%1$s|r]是一個不符合規定的數值"
	NO_OPTIONS_AVAILABLE = "沒有可用的選項"
	OPTION_HANDLER_NOT_FOUND = "找不到|cffffff7f%q|r選項處理器。"
	OPTION_HANDLER_NOT_VALID = "選項處理器不符合規定。"
	OPTION_IS_DISABLED = "|cffffff7f%s|r已被停用。"
	KEYBINDING_USAGE = "<Alt-Ctrl-Shift-鍵>"
	DEFAULT_CONFIRM_MESSAGE = "是否執行「%s」?"
elseif GetLocale() == "esES" then
	MAP_ONOFF = { [false] = "|cffff0000Desactivado|r", [true] = "|cff00ff00Activado|r" }
	USAGE = "Uso"
	IS_CURRENTLY_SET_TO = "|cffffff7f%s|r est\195\161 establecido actualmente a |cffffff7f[|r%s|cffffff7f]|r"
	IS_NOW_SET_TO = "|cffffff7f%s|r se ha establecido a |cffffff7f[|r%s|cffffff7f]|r"
	IS_NOT_A_VALID_OPTION_FOR = "[|cffffff7f%s|r] no es una opci\195\179n valida para |cffffff7f%s|r"
	IS_NOT_A_VALID_VALUE_FOR = "[|cffffff7f%s|r] no es un valor v\195\161lido para |cffffff7f%s|r"
	NO_OPTIONS_AVAILABLE = "No hay opciones disponibles"
	OPTION_HANDLER_NOT_FOUND = "Gestor de opciones |cffffff7f%q|r no encontrado."
	OPTION_HANDLER_NOT_VALID = "Gestor de opciones no v\195\161lido."
	OPTION_IS_DISABLED = "La opci\195\179n |cffffff7f%s|r est\195\161 desactivada."
	KEYBINDING_USAGE = "<ALT-CTRL-SHIFT-KEY>"
	DEFAULT_CONFIRM_MESSAGE = "Are you sure you want to perform `%s'?" -- fix
elseif GetLocale() == "ruRU" then
	MAP_ONOFF = { [false] = "|cffff0000Off|r", [true] = "|cff00ff00On|r" }
	USAGE = "Используйте"
	IS_CURRENTLY_SET_TO = "|cffffff7f%s|r в настоящее время установлен на |cffffff7f[|r%s|cffffff7f]|r"
	IS_NOW_SET_TO = "|cffffff7f%s|r тереь установлен |cffffff7f[|r%s|cffffff7f]|r"
	IS_NOT_A_VALID_OPTION_FOR = "[|cffffff7f%s|r] не действительная опция для |cffffff7f%s|r"
	IS_NOT_A_VALID_VALUE_FOR = "[|cffffff7f%s|r] не действительное значение для |cffffff7f%s|r"
	NO_OPTIONS_AVAILABLE = "Нет доступных опцийe"
	OPTION_HANDLER_NOT_FOUND = "Оператор опции |cffffff7f%q|r не найден."
	OPTION_HANDLER_NOT_VALID = "Оператор опции не действительный."
	OPTION_IS_DISABLED = "Опция |cffffff7f%s|r отключена."
	KEYBINDING_USAGE = "<ALT-CTRL-SHIFT-КЛАВИША>"
	DEFAULT_CONFIRM_MESSAGE = "Вы уверены что вы хотите выполнить `%s'?"
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
	KEYBINDING_USAGE = "<ALT-CTRL-SHIFT-KEY>"
	DEFAULT_CONFIRM_MESSAGE = "Are you sure you want to perform `%s'?"
end

local NONE = NONE or "None"

local AceOO = AceLibrary("AceOO-2.0")
local AceEvent

local AceConsole = AceOO.Mixin { "Print", "PrintComma", "PrintLiteral", "CustomPrint", "RegisterChatCommand" }
local Dewdrop

local _G = getfenv(0)

local function print(text, name, r, g, b, frame, delay)
	if not text or text:len() == 0 then
		text = " "
	end
	if not name or name == AceConsole then
	else
		text = "|cffffff78" .. tostring(name) .. ":|r " .. text
	end
	local last_color
	for t in text:gmatch("[^\n]+") do
		(frame or DEFAULT_CHAT_FRAME):AddMessage(last_color and "|cff" .. last_color .. t or t, r, g, b, nil, delay or 5)
		if not last_color or t:find("|r") or t:find("|c") then
			last_color = t:match(".*|c[fF][fF](%x%x%x%x%x%x)[^|]-$")
		end
	end
	return text
end

local real_tostring = tostring

local function tostring(t)
	if type(t) == "table" then
		if type(rawget(t, 0)) == "userdata" and type(t.GetObjectType) == "function" then
			return ("<%s:%s>"):format(t:GetObjectType(), t:GetName() or "(anon)")
		end
	end
	return real_tostring(t)
end

local getkeystring

local function isList(t)
	local n = #t
	for k,v in pairs(t) do
		if type(k) ~= "number" then
			return false
		elseif k < 1 or k > n then
			return false
		end
	end
	return true
end

local findGlobal = setmetatable({}, {__index=function(self, t)
	for k,v in pairs(_G) do
		if v == t then
			k = tostring(k)
			self[v] = k
			return k
		end
	end
	self[t] = false
	return false
end})

local recurse = {}
local timeToEnd
local GetTime = GetTime
local type = type

local new, del
do
	local cache = setmetatable({},{__mode='k'})
	function new()
		local t = next(cache)
		if t then
			cache[t] = nil
			return t
		else
			return {}
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

local function ignoreCaseSort(alpha, bravo)
	if not alpha or not bravo then
		return false
	end
	return tostring(alpha):lower() < tostring(bravo):lower()
end

local function specialSort(alpha, bravo)
	if alpha == nil or bravo == nil then
		return false
	end
	local type_alpha, type_bravo = type(alpha), type(bravo)
	if type_alpha ~= type_bravo then
		return type_alpha < type_bravo
	end
	if type_alpha == "string" then
		return alpha:lower() < bravo:lower()
	elseif type_alpha == "number" then
		return alpha < bravo
	elseif type_alpha == "table" then
		return #alpha < #bravo
	elseif type_alpha == "boolean" then
		return not alpha
	else
		return false
	end
end

local function escapeChar(c)
    return ("\\%03d"):format(c:byte())
end

local function literal_tostring_prime(t, depth)
	if type(t) == "string" then
		return ("|cff00ff00%q|r"):format((t:gsub("|", "||"))):gsub("[%z\001-\009\011-\031\127-\255]", escapeChar)
	elseif type(t) == "table" then
		if t == _G then
			return "|cffffea00_G|r"
		end
		if type(rawget(t, 0)) == "userdata" and type(t.GetObjectType) == "function" then
			return ("|cffffea00<%s:%s>|r"):format(t:GetObjectType(), t:GetName() or "(anon)")
		end
		if next(t) == nil then
			local mt = getmetatable(t)
			if type(mt) == "table" and type(mt.__raw) == "table" then
				t = mt.__raw
			end
		end
		if recurse[t] then
			local g = findGlobal[t]
			if g then
				return ("|cff9f9f9f<Recursion _G[%q]>|r"):format(g)
			else
				return ("|cff9f9f9f<Recursion %s>|r"):format(real_tostring(t):gsub("|", "||"))
			end
		elseif GetTime() > timeToEnd then
			local g = findGlobal[t]
			if g then
				return ("|cff9f9f9f<Timeout _G[%q]>|r"):format(g)
			else
				return ("|cff9f9f9f<Timeout %s>|r"):format(real_tostring(t):gsub("|", "||"))
			end
		elseif depth >= 2 then
			local g = findGlobal[t]
			if g then
				return ("|cff9f9f9f<_G[%q]>|r"):format(g)
			else
				return ("|cff9f9f9f<%s>|r"):format(real_tostring(t):gsub("|", "||"))
			end
		end
		recurse[t] = true
		if next(t) == nil then
			return "{}"
		elseif next(t, (next(t))) == nil then
			local k, v = next(t)
			if k == 1 then
				return "{ " .. literal_tostring_prime(v, depth+1) .. " }"
			else
				return "{ " .. getkeystring(k, depth+1) .. " = " .. literal_tostring_prime(v, depth+1) .. " }"
			end
		end
		local s
		local g = findGlobal[t]
		if g then
			s = ("{ |cff9f9f9f-- _G[%q]|r\n"):format(g)
		else
			s = "{ |cff9f9f9f-- " .. real_tostring(t):gsub("|", "||") .. "|r\n"
		end
		if isList(t) then
			for i = 1, #t do
				s = s .. ("    "):rep(depth+1) .. literal_tostring_prime(t[i], depth+1) .. (i == #t and "\n" or ",\n")
			end
		else
			local tmp = new()
			for k in pairs(t) do
				tmp[#tmp+1] = k
			end
			table.sort(tmp, specialSort)
			for i,k in ipairs(tmp) do
				tmp[i] = nil
				local v = t[k]
				s = s .. ("    "):rep(depth+1) .. getkeystring(k, depth+1) .. " = " .. literal_tostring_prime(v, depth+1) .. (tmp[i+1] == nil and "\n" or ",\n")
			end
			tmp = del(tmp)
		end
		if g then
			s = s .. ("    "):rep(depth) .. string.format("} |cff9f9f9f-- _G[%q]|r", g)
		else
			s = s .. ("    "):rep(depth) .. "} |cff9f9f9f-- " .. real_tostring(t):gsub("|", "||")
		end
		return s
	end
	if type(t) == "number" then
		return "|cffff7fff" .. real_tostring(t) .. "|r"
	elseif type(t) == "boolean" then
		return "|cffff9100" .. real_tostring(t) .. "|r"
	elseif t == nil then
		return "|cffff7f7f" .. real_tostring(t) .. "|r"
	else
		return "|cffffea00" .. real_tostring(t) .. "|r"
	end
end

function getkeystring(t, depth)
	if type(t) == "string" then
		if t:find("^[%a_][%a%d_]*$") then
			return "|cff7fd5ff" .. t .. "|r"
		end
	end
	return "[" .. literal_tostring_prime(t, depth) .. "]"
end

local get_stringed_args
do
	local function g(value, ...)
		if select('#', ...) == 0 then
			return literal_tostring_prime(value, 1)
		end
		return literal_tostring_prime(value, 1) .. ", " .. g(...)
	end

	local function f(success, ...)
		if not success then
			return
		end
		return g(...)
	end

	function get_stringed_args(func, ...)
		return f(pcall(func, ...))
	end
end

local function literal_tostring_frame(t)
	local s = ("|cffffea00<%s:%s|r\n"):format(t:GetObjectType(), t:GetName() or "(anon)")
	local __index = getmetatable(t).__index
	local tmp, tmp2, tmp3 = new(), new(), new()
	for k in pairs(t) do
		if k ~= 0 then
			tmp3[k] = true
			tmp2[k] = true
		end
	end
	for k in pairs(__index) do
		tmp2[k] = true
	end
	for k in pairs(tmp2) do
		tmp[#tmp+1] = k
		tmp2[k] = nil
	end
	table.sort(tmp, ignoreCaseSort)
	local first = true
	for i,k in ipairs(tmp) do
		local v = t[k]
		local good = true
		if k == "GetPoint" then
			for i = 1, t:GetNumPoints() do
				if not first then
					s = s .. ",\n"
				else
					first = false
				end
				s = s .. "    " .. getkeystring(k, 1) .. "(" .. literal_tostring_prime(i, 1) .. ") => " .. get_stringed_args(v, t, i)
			end
		elseif type(v) == "function" and type(k) == "string" and (k:find("^Is") or k:find("^Get") or k:find("^Can")) then
			local q = get_stringed_args(v, t)
			if q then
				if not first then
					s = s .. ",\n"
				else
					first = false
				end
				s = s .. "    " .. getkeystring(k, 1) .. "() => " .. q
			end
		elseif type(v) ~= "function" or (type(v) == "function" and type(k) == "string" and tmp3[k]) then
			if not first then
				s = s .. ",\n"
			else
				first = false
			end
			s = s .. "    " .. getkeystring(k, 1) .. " = " .. literal_tostring_prime(v, 1)
		else
			good = false
		end
	end
	tmp, tmp2, tmp3 = del(tmp), del(tmp2), del(tmp3)
	s = s .. "\n|cffffea00>|r"
	return s
end

local function literal_tostring(t, only)
	timeToEnd = GetTime() + 0.2
	local s
	if only and type(t) == "table" and type(rawget(t, 0)) == "userdata" and type(t.GetObjectType) == "function" then
		s = literal_tostring_frame(t)
	else
		s = literal_tostring_prime(t, 0)
	end
	for k,v in pairs(recurse) do
		recurse[k] = nil
	end
	for k,v in pairs(findGlobal) do
		findGlobal[k] = nil
	end
	return s
end

local function tostring_args(a1, ...)
	if select('#', ...) < 1 then
		return tostring(a1)
	end
	return tostring(a1), tostring_args(...)
end

local function literal_tostring_args(a1, ...)
	if select('#', ...) < 1 then
		return literal_tostring(a1)
	end
	return literal_tostring(a1), literal_tostring_args(...)
end

function AceConsole:CustomPrint(r, g, b, frame, delay, connector, a1, ...)
	if connector == true then
		local s
		if select('#', ...) == 0 then
			s = literal_tostring(a1, true)
		else
			s = (", "):join(literal_tostring_args(a1, ...))
		end
		return print(s, self, r, g, b, frame or self.printFrame, delay)
	elseif tostring(a1):find("%%") and select('#', ...) >= 1 then
		local success, text = pcall(string.format, tostring_args(a1, ...))
		if success then
			return print(text, self, r, g, b, frame or self.printFrame, delay)
		end
	end
	return print((connector or " "):join(tostring_args(a1, ...)), self, r, g, b, frame or self.printFrame, delay)
end

function AceConsole:Print(...)
	return AceConsole.CustomPrint(self, nil, nil, nil, nil, nil, " ", ...)
end

function AceConsole:PrintComma(...)
	return AceConsole.CustomPrint(self, nil, nil, nil, nil, nil, ", ", ...)
end

function AceConsole:PrintLiteral(...)
	return AceConsole.CustomPrint(self, nil, nil, nil, nil, nil, true, ...)
end

local work
local argwork

local function findTableLevel(self, options, chat, text, index, passTable)
	if not index then
		index = 1
		if work then
			for k,v in pairs(work) do
				work[k] = nil
			end
			for k,v in pairs(argwork) do
				argwork[k] = nil
			end
		else
			work = {}
			argwork = {}
		end
		local len = text:len()
		local count
		repeat
			text, count = text:gsub("(|cff%x%x%x%x%x%x|Hitem:%d-:%d-:%d-:%d-|h%[[^%]]-) (.-%]|h|r)", "%1\001%2")
		until count == 0
		text = text:gsub("(%]|h|r)(|cff%x%x%x%x%x%x|Hitem:%d-:%d-:%d-:%d-|h%[)", "%1 %2")
		for token in text:gmatch("([^%s]+)") do
			local token = token
			local num = tonumber(token)
			if num then
				token = num
			else
				token = token:gsub("\001", " ")
			end
			table.insert(work, token)
		end
	end

	local path = chat
	for i = 1, index - 1 do
		path = path .. " " .. tostring(work[i])
	end

	local passValue = options.passValue or (passTable and work[index-1])
	passTable = passTable or options

	if type(options.args) == "table" then
		local disabled, hidden = options.disabled, options.cmdHidden or options.hidden
		if hidden then
			if type(hidden) == "function" then
				hidden = hidden(passValue)
			elseif type(hidden) == "string" then
				local handler = options.handler or self
				local f = hidden
				local neg = f:match("^~(.-)$")
				if neg then
					f = neg
				end
				if type(handler[f]) ~= "function" then
					AceConsole:error("%s: %s", handler, OPTION_HANDLER_NOT_FOUND:format(tostring(f)))
				end
				hidden = handler[f](handler, passValue)
				if neg then
					hidden = not hidden
				end
			end
		end
		if hidden then
			disabled = true
		elseif disabled then
			if type(disabled) == "function" then
				disabled = disabled(passValue)
			elseif type(disabled) == "string" then
				local handler = options.handler or self
				local f = disabled
				local neg = f:match("^~(.-)$")
				if neg then
					f = neg
				end
				if type(handler[f]) ~= "function" then
					AceConsole:error("%s: %s", handler, OPTION_HANDLER_NOT_FOUND:format(tostring(f)))
				end
				disabled = handler[f](handler, passValue)
				if neg then
					disabled = not disabled
				end
			end
		end
		if not disabled then
			local next = work[index] and tostring(work[index]):lower()
			local next_num = tonumber(next)
			if next then
				for k,v in pairs(options.args) do
					local good = false
					if tostring(k):gsub("%s", "-"):lower() == next then
						good = true
					elseif k == next_num then
						good = true
					elseif type(v.aliases) == "table" then
						for _,alias in ipairs(v.aliases) do
							if alias:gsub("%s", "-"):lower() == next then
								good = true
								break
							end
						end
					elseif type(v.aliases) == "string" and v.aliases:gsub("%s", "-"):lower() == next then
						good = true
					end
					if good then
						work[index] = k -- revert it back to its original form as supplied in args
						if options.pass then
							passTable = passTable or options
							if options.get and options.set then
								passTable = options
							end
						else
							passTable = nil
						end
						return findTableLevel(options.handler or self, v, chat, text, index + 1, passTable)
					end
				end
			end
		end
	end
	for i = index, #work do
		table.insert(argwork, work[i])
	end
	return options, path, argwork, options.handler or self, passTable, passValue
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
			return ("%q is not a proper function"):format(tostring(options.func)), position
		end
	else
		if options.get then
			if type(options.get) ~= "string" and type(options.get) ~= "function" then
				return "get must be a string or function", position
			end
			if type(options.get) == "string" then
				local f = options.get
				if options.type == "toggle" then
					f = f:match("^~(.-)$") or f
				end
				if type(self[f]) ~= "function" then
					return ("%q is not a proper function"):format(tostring(f)), position
				end
			end
		end
		if options.set then
			if type(options.set) ~= "string" and type(options.set) ~= "function" then
				return "set must be a string or function", position
			end
			if type(options.set) == "string" and type(self[options.set]) ~= "function" then
				return ("%q is not a proper function"):format(tostring(options.set)), position
			end
		end
		if options.validate and type(options.validate) ~= "table" and options.validate ~= "keybinding" then
			if type(options.validate) ~= "string" and type(options.validate) ~= "function" then
				return "validate must be a string or function", position
			end
			if type(options.validate) == "string" and type(self[options.validate]) ~= "function" then
				return ("%q is not a proper function"):format(tostring(options.validate)), position
			end
		end
	end
	if options.disabled and type(options.disabled) == "string" then
		local f = options.disabled
		f = f:match("^~(.-)$") or f
		if type(self[f]) ~= "function" then
			return ("%q is not a proper function"):format(tostring(f)), position
		end
	end
	if options.cmdHidden and type(options.cmdHidden) == "string" then
		local f = options.cmdHidden
		f = f:match("^~(.-)$") or f
		if type(self[f]) ~= "function" then
			return ("%q is not a proper function"):format(tostring(f)), position
		end
	end
	if options.guiHidden and type(options.guiHidden) == "string" then
		local f = options.guiHidden
		f = f:match("^~(.-)$") or f
		if type(self[f]) ~= "function" then
			return ("%q is not a proper function"):format(tostring(f)), position
		end
	end
	if options.hidden and type(options.hidden) == "string" then
		local f = options.hidden
		f = f:match("^~(.-)$") or f
		if type(self[f]) ~= "function" then
			return ("%q is not a proper function"):format(tostring(f)), position
		end
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
	end
	if options ~= baseOptions then
		if kind == "header" then
		elseif type(options.desc) ~= "string" then
			return '"desc" must be a string', position
		elseif options.desc:len() == 0 then
			return '"desc" cannot be a 0-length string', position
		end
	end

	if options ~= baseOptions or kind == "range" or kind == "text" or kind == "toggle" or kind == "color" then
		if options.type == "header" and not options.cmdName and not options.name then
		elseif options.cmdName then
			if type(options.cmdName) ~= "string" then
				return '"cmdName" must be a string or nil', position
			elseif options.cmdName:len() == 0 then
				return '"cmdName" cannot be a 0-length string', position
			end
			if type(options.guiName) ~= "string" then
				if not options.guiNameIsMap then
					return '"guiName" must be a string or nil', position
				end
			elseif options.guiName:len() == 0 then
				return '"guiName" cannot be a 0-length string', position
			end
		else
			if type(options.name) ~= "string" then
				return '"name" must be a string', position
			elseif options.name:len() == 0 then
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
					elseif k < 1 or k > #t then
						return '"validate" numeric keys must be indexed properly. >= 1 and <= #validate', position
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
			if options.multiToggle and options.multiToggle ~= true then
				return '"multiToggle" must be a boolean or nil if "validate" is a table', position
			end
		elseif options.validate == "keybinding" then

		else
			if type(options.usage) ~= "string" then
				return '"usage" must be a string', position
			elseif options.validate and type(options.validate) ~= "string" and type(options.validate) ~= "function" then
				return '"validate" must be a string, function, or table', position
			end
		end
		if options.multiToggle and type(options.validate) ~= "table" then
			return '"validate" must be a table if "multiToggle" is true', position
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
			if type(k) ~= "number" then
				if type(k) ~= "string" then
					return '"args" keys must be strings or numbers', position
				elseif k:len() == 0 then
					return '"args" keys must not be 0-length strings.', position
				end
			end
			if type(v) ~= "table" then
				if type(k) == "number" then
					return '"args" values must be tables', position and position .. "[" .. k .. "]" or "[" .. k .. "]"
				else
					return '"args" values must be tables', position and position .. "." .. k or k
				end
			end
			local newposition
			if type(k) == "number" then
				newposition = position and position .. ".args[" .. k .. "]" or "args[" .. k .. "]"
			else
				newposition = position and position .. ".args." .. k or "args." .. k
			end
			local err, pos = validateOptions(v, newposition, baseOptions, options.pass)
			if err then
				return err, pos
			end
		end
	elseif kind == "execute" then
		if type(options.confirm) ~= "string" and type(options.confirm) ~= "boolean" and type(options.confirm) ~= "nil" then
			return '"confirm" must be a string, boolean, or nil', position
		end
	end
end

local colorTable
local colorFunc
local colorCancelFunc

local function keybindingValidateFunc(text)
	if text == nil or text == "NONE" then
		return nil
	end
	text = text:upper()
	local shift, ctrl, alt
	local modifier
	while true do
		if text == "-" then
			break
		end
		modifier, text = strsplit('-', text, 2)
		if text then
			if modifier ~= "SHIFT" and modifier ~= "CTRL" and modifier ~= "ALT" then
				return false
			end
			if modifier == "SHIFT" then
				if shift then
					return false
				end
				shift = true
			end
			if modifier == "CTRL" then
				if ctrl then
					return false
				end
				ctrl = true
			end
			if modifier == "ALT" then
				if alt then
					return false
				end
				alt = true
			end
		else
			text = modifier
			break
		end
	end
	if not text:find("^F%d+$") and text ~= "CAPSLOCK" and text:len() ~= 1 and (text:byte() < 128 or text:len() > 4) and not _G["KEY_" .. text] then
		return false
	end
	local s = text
	if shift then
		s = "SHIFT-" .. s
	end
	if ctrl then
		s = "CTRL-" .. s
	end
	if alt then
		s = "ALT-" .. s
	end
	return s
end
AceConsole.keybindingValidateFunc = keybindingValidateFunc

local order

local mysort_args
local mysort

local function icaseSort(alpha, bravo)
	if type(alpha) == "number" and type(bravo) == "number" then
		return alpha < bravo
	end
	return tostring(alpha):lower() < tostring(bravo):lower()
end

local tmp = {}
local function printUsage(self, handler, realOptions, options, path, args, passValue, quiet, filter)
	if filter then
		filter = "^" .. filter:gsub("([%(%)%.%*%+%-%[%]%?%^%$%%])", "%%%1")
	end
	local hidden, disabled = options.cmdHidden or options.hidden, options.disabled
	if hidden then
		if type(hidden) == "function" then
			hidden = hidden(options.passValue)
		elseif type(hidden) == "string" then
			local f = hidden
			local neg = f:match("^~(.-)$")
			if neg then
				f = neg
			end
			if type(handler[f]) ~= "function" then
				AceConsole:error("%s: %s", handler, OPTION_HANDLER_NOT_FOUND:format(tostring(f)))
			end
			hidden = handler[f](handler, options.passValue)
			if neg then
				hidden = not hidden
			end
		end
	end
	if hidden then
		disabled = true
	elseif disabled then
		if type(disabled) == "function" then
			disabled = disabled(options.passValue)
		elseif type(disabled) == "string" then
			local f = disabled
			local neg = f:match("^~(.-)$")
			if neg then
				f = neg
			end
			if type(handler[f]) ~= "function" then
				AceConsole:error("%s: %s", handler, OPTION_HANDLER_NOT_FOUND:format(tostring(f)))
			end
			disabled = handler[f](handler, options.passValue)
			if neg then
				disabled = not disabled
			end
		end
	end
	local kind = (options.type or "group"):lower()
	if disabled then
		print(OPTION_IS_DISABLED:format(path), realOptions.cmdName or realOptions.name or self)
	elseif kind == "text" then
		local var
		local multiToggle
		for k in pairs(tmp) do
			tmp[k] = nil
		end
		if passTable then
			multiToggle = passTable.multiToggle
			if not passTable.get then
			elseif type(passTable.get) == "function" then
				if not multiToggle then
					var = passTable.get(passValue)
				else
					var = tmp
					for k,v in pairs(options.validate) do
						local val = type(k) ~= "number" and k or v
						if passValue == nil then
							var[val] = passTable.get(val) or nil
						else
							var[val] = passTable.get(passValue, val) or nil
						end
					end
				end
			else
				local handler = passTable.handler or handler
				if type(handler[passTable.get]) ~= "function" then
					AceConsole:error("%s: %s", handler, OPTION_HANDLER_NOT_FOUND:format(tostring(passTable.get)))
				end
				var = handler[passTable.get](handler, passValue)
				if not multiToggle then
					var = handler[passTable.get](handler, passValue)
				else
					var = tmp
					for k,v in pairs(options.validate) do
						local val = type(k) ~= "number" and k or v
						if passValue == nil then
							var[val] = handler[passTable.get](handler, val) or nil
						else
							var[val] = handler[passTable.get](handler, passValue, val) or nil
						end
					end
				end
			end
		else
			multiToggle = options.multiToggle
			if not options.get then
			elseif type(options.get) == "function" then
				if not multiToggle then
					var = options.get(passValue)
				else
					var = tmp
					for k,v in pairs(options.validate) do
						local val = type(k) ~= "number" and k or v
						if passValue == nil then
							var[val] = options.get(val) or nil
						else
							var[val] = options.get(passValue, val) or nil
						end
					end
				end
			else
				local handler = options.handler or handler
				if type(handler[options.get]) ~= "function" then
					AceConsole:error("%s: %s", handler, OPTION_HANDLER_NOT_FOUND:format(tostring(options.get)))
				end
				if not multiToggle then
					var = handler[options.get](handler, passValue)
				else
					var = tmp
					for k,v in pairs(options.validate) do
						local val = type(k) ~= "number" and k or v
						if passValue == nil then
							var[val] = handler[options.get](handler, val) or nil
						else
							var[val] = handler[options.get](handler, passValue, val) or nil
						end
					end
				end
			end
		end

		local usage
		if type(options.validate) == "table" then
			if filter then
				if not order then
					order = {}
				end
				for k,v in pairs(options.validate) do
					if v:find(filter) then
						table.insert(order, v)
					end
				end
				table.sort(order, icaseSort)
				usage = "{" .. table.concat(order, " || ") .. "}"
				for k in pairs(order) do
					order[k] = nil
				end
			else
				if not order then
					order = {}
				end
				for k,v in pairs(options.validate) do
					table.insert(order, v)
				end
				table.sort(order, icaseSort)
				usage = "{" .. table.concat(order, " || ") .. "}"
				for k in pairs(order) do
					order[k] = nil
				end
			end
			if multiToggle then
				if not next(var) then
					var = NONE
				else
					if not order then
						order = {}
					end
					for k in pairs(var) do
						if options.validate[k] then
							order[#order+1] = options.validate[k]
						else
							for _,v in pairs(options.validate) do
								if v == k or (type(v) == "string" and type(k) == "string" and v:lower() == k:lower()) then
									order[#order+1] = v
									break
								end
							end
						end
					end
					table.sort(order, icaseSort)
					var = table.concat(order, ", ")
					for k in pairs(order) do
						order[k] = nil
					end
				end
			else
				var = options.validate[var] or var
			end
		elseif options.validate == "keybinding" then
			usage = KEYBINDING_USAGE
		else
			usage = options.usage or "<value>"
		end
		if not quiet then
			print(("|cffffff7f%s:|r %s %s"):format(USAGE, path, usage), realOptions.cmdName or realOptions.name or self)
		end
		if (passTable and passTable.get) or options.get then
			print((options.current or IS_CURRENTLY_SET_TO):format(tostring(options.cmdName or options.name), tostring(var or NONE)))
		end
	elseif kind == "range" then
		local var
		if passTable then
			if type(passTable.get) == "function" then
				var = passTable.get(passValue)
			else
				local handler = passTable.handler or handler
				if type(handler[passTable.get]) ~= "function" then
					AceConsole:error("%s: %s", handler, OPTION_HANDLER_NOT_FOUND:format(tostring(passTable.get)))
				end
				var = handler[passTable.get](handler, passValue)
			end
		else
			if type(options.get) == "function" then
				var = options.get(passValue)
			else
				local handler = options.handler or handler
				if type(handler[options.get]) ~= "function" then
					AceConsole:error("%s: %s", handler, OPTION_HANDLER_NOT_FOUND:format(tostring(options.get)))
				end
				var = handler[options.get](handler, passValue)
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
		usage = ("(%s%s%s)"):format(min, bit, max)
		if not quiet then
			print(("|cffffff7f%s:|r %s %s"):format(USAGE, path, usage), realOptions.cmdName or realOptions.name or self)
		end
		print((options.current or IS_CURRENTLY_SET_TO):format(tostring(options.cmdName or options.name), tostring(var or NONE)))
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
							local f = hidden
							local neg = f:match("^~(.-)$")
							if neg then
								f = neg
							end
							if type(handler[f]) ~= "function" then
								AceConsole:error("%s: %s", handler, OPTION_HANDLER_NOT_FOUND:format(tostring(f)))
							end
							hidden = handler[f](handler)
							if neg then
								hidden = not hidden
							end
						end
					end
					if not hidden then
						if filter then
							if k:find(filter) then
								table.insert(order, k)
							elseif type(v.aliases) == "table" then
								for _,bit in ipairs(v.aliases) do
									if bit:find(filter) then
										table.insert(order, k)
										break
									end
								end
							elseif type(v.aliases) == "string" then
								if v.aliases:find(filter) then
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
						return tostring(a):lower() < tostring(b):lower()
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
							return tostring(a):lower() < tostring(b):lower()
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
						print(("|cffffff7f%s:|r %s %s"):format(USAGE, path, "{" .. table.concat(order, " || ") .. "}"))
					elseif self.description or self.notes then
						print(tostring(self.description or self.notes), realOptions.cmdName or realOptions.name or self)
						print(("|cffffff7f%s:|r %s %s"):format(USAGE, path, "{" .. table.concat(order, " || ") .. "}"))
					else
						print(("|cffffff7f%s:|r %s %s"):format(USAGE, path, "{" .. table.concat(order, " || ") .. "}"), realOptions.cmdName or realOptions.name or self)
					end
				else
					if options.desc then
						print(("|cffffff7f%s:|r %s %s"):format(USAGE, path, "{" .. table.concat(order, " || ") .. "}"), realOptions.cmdName or realOptions.name or self)
						print(tostring(options.desc))
					else
						print(("|cffffff7f%s:|r %s %s"):format(USAGE, path, "{" .. table.concat(order, " || ") .. "}"), realOptions.cmdName or realOptions.name or self)
					end
				end
			end
			local passTable = options.pass and options or nil
			for _,k in ipairs(order) do
				local passValue = passTable and k or nil
				local real_k = k
				local v = options.args[k]
				if v then
					local v_p = passTable or v
					if v.get and v.set then
						v_p = v
						passValue = nil
					end
					if v.passValue then
						passValue = v.passValue
					end
					local k = tostring(k):gsub("%s", "-")
					local disabled = v.disabled
					if disabled then
						if type(disabled) == "function" then
							disabled = disabled(passValue)
						elseif type(disabled) == "string" then
							local f = disabled
							local neg = f:match("^~(.-)$")
							if neg then
								f = neg
							end
							if type(handler[f]) ~= "function" then
								AceConsole:error("%s: %s", handler, OPTION_HANDLER_NOT_FOUND:format(tostring(f)))
							end
							disabled = handler[f](handler, passValue)
							if neg then
								disabled = not disabled
							end
						end
					end
					if type(v.aliases) == "table" then
						for _,s in ipairs(v.aliases) do
							k = k .. " || " .. s:gsub("%s", "-")
						end
					elseif type(v.aliases) == "string" then
						k = k .. " || " .. v.aliases:gsub("%s", "-")
					end
					if v_p.get then
						local a1,a2,a3,a4
						local multiToggle = v_p.type == "text" and v_p.multiToggle
						for k in pairs(tmp) do
							tmp[k] = nil
						end
						if type(v_p.get) == "function" then
							if multiToggle then
								a1 = tmp
								for k,v in pairs(v.validate) do
									local val = type(k) ~= "number" and k or v
									if passValue == nil then
										a1[val] = v_p.get(val) or nil
									else
										a1[val] = v_p.get(passValue, val) or nil
									end
								end
							else
								a1,a2,a3,a4 = v_p.get(passValue)
							end
						else
							local handler = v_p.handler or handler
							local f = v_p.get
							local neg
							if v.type == "toggle" then
								neg = f:match("^~(.-)$")
								if neg then
									f = neg
								end
							end
							if type(handler[f]) ~= "function" then
								AceConsole:error("%s: %s", handler, OPTION_HANDLER_NOT_FOUND:format(tostring(f)))
							end
							if multiToggle then
								a1 = tmp
								for k,v in pairs(v.validate) do
									local val = type(k) ~= "number" and k or v
									if passValue == nil then
										a1[val] = handler[f](handler, val) or nil
									else
										a1[val] = handler[f](handler, passValue, val) or nil
									end
								end
							else
								a1,a2,a3,a4 = handler[f](handler, passValue)
							end
							if neg then
								a1 = not a1
							end
						end
						local s
						if v.type == "color" then
							if v.hasAlpha then
								if not a1 or not a2 or not a3 or not a4 then
									s = NONE
								else
									s = ("|c%02x%02x%02x%02x%02x%02x%02x%02x|r"):format(a4*255, a1*255, a2*255, a3*255, a4*255, a1*255, a2*255, a3*255)
								end
							else
								if not a1 or not a2 or not a3 then
									s = NONE
								else
									s = ("|cff%02x%02x%02x%02x%02x%02x|r"):format(a1*255, a2*255, a3*255, a1*255, a2*255, a3*255)
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
							if multiToggle then
								if not next(a1) then
									s = NONE
								else
									s = ''
									for k in pairs(a1) do
										if v.validate[k] then
											if s == '' then
												s = v.validate[k]
											else
												s = s .. ', ' .. v.validate[k]
											end
										else
											for _,u in pairs(v.validate) do
												if u == k or (type(v) == "string" and type(k) == "string" and v:lower() == k:lower()) then
													if s == '' then
														s = u
													else
														s = s .. ', ' .. u
													end
													break
												end
											end
										end
									end
								end
							else
								s = tostring(v.validate[a1] or a1 or NONE)
							end
						else
							s = tostring(a1 or NONE)
						end
						if disabled then
							local s = s:gsub("|cff%x%x%x%x%x%x(.-)|r", "%1")
							local desc = (v.desc or NONE):gsub("|cff%x%x%x%x%x%x(.-)|r", "%1")
							print(("|cffcfcfcf - %s: [%s] %s|r"):format(k, s, desc))
						else
							print((" - |cffffff7f%s: [|r%s|cffffff7f]|r %s"):format(k, s, v.desc or NONE))
						end
					else
						if disabled then
							local desc = (v.desc or NONE):gsub("|cff%x%x%x%x%x%x(.-)|r", "%1")
							print(("|cffcfcfcf - %s: %s"):format(k, desc))
						else
							print((" - |cffffff7f%s:|r %s"):format(k, v.desc or NONE))
						end
					end
				end
			end
			for k in pairs(order) do
				order[k] = nil
			end
		else
			if options.desc then
				print(("|cffffff7f%s:|r %s"):format(USAGE, path), realOptions.cmdName or realOptions.name or self)
				print(tostring(options.desc))
			elseif options == realOptions and (self.description or self.notes) then
				print(tostring(self.description or self.notes), realOptions.cmdName or realOptions.name or self)
				print(("|cffffff7f%s:|r %s"):format(USAGE, path))
			else
				print(("|cffffff7f%s:|r %s"):format(USAGE, path), realOptions.cmdName or realOptions.name or self)
			end
			print(NO_OPTIONS_AVAILABLE)
		end
	end
end

local function confirmPopup(message, func, ...)
	if not StaticPopupDialogs["ACECONSOLE20_CONFIRM_DIALOG"] then
		StaticPopupDialogs["ACECONSOLE20_CONFIRM_DIALOG"] = {}
	end
	local t = StaticPopupDialogs["ACECONSOLE20_CONFIRM_DIALOG"]
	for k in pairs(t) do
		t[k] = nil
	end
	t.text = message
	t.button1 = ACCEPT or "Accept"
	t.button2 = CANCEL or "Cancel"
	t.OnAccept = function()
		func(unpack(t))
	end
	for i = 1, select('#', ...) do
		t[i] = select(i, ...)
	end
	t.timeout = 0
	t.whileDead = 1
	t.hideOnEscape = 1

	StaticPopup_Show("ACECONSOLE20_CONFIRM_DIALOG")
end

local function handlerFunc(self, chat, msg, options)
	if not msg then
		msg = ""
	else
		msg = msg:gsub("^%s*(.-)%s*$", "%1")
		msg = msg:gsub("%s+", " ")
	end

	local realOptions = options
	local options, path, args, handler, passTable, passValue = findTableLevel(self, options, chat, msg)
	if options.type == "execute" then
		if options.func then
			passTable = nil
		end
	else
		if options.get and options.set then
			passTable = nil
		end
	end
	passValue = options.passValue or passTable and passValue

	local hidden, disabled = options.cmdHidden or options.hidden, options.disabled
	if hidden then
		if type(hidden) == "function" then
			hidden = hidden(passValue)
		elseif type(hidden) == "string" then
			local f = hidden
			local neg = f:match("^~(.-)$")
			if neg then
				f = neg
			end
			if type(handler[f]) ~= "function" then
				AceConsole:error("%s: %s", handler, OPTION_HANDLER_NOT_FOUND:format(tostring(f)))
			end
			hidden = handler[f](handler, passValue)
			if neg then
				hidden = not hidden
			end
		end
	end
	if hidden then
		disabled = true
	elseif disabled then
		if type(disabled) == "function" then
			disabled = disabled(passValue)
		elseif type(disabled) == "string" then
			local f = disabled
			local neg = f:match("^~(.-)$")
			if neg then
				f = neg
			end
			if type(handler[f]) ~= "function" then
				AceConsole:error("%s: %s", handler, OPTION_HANDLER_NOT_FOUND:format(tostring(f)))
			end
			disabled = handler[f](handler, passValue)
			if neg then
				disabled = not disabled
			end
		end
	end
	local kind = (options.type or "group"):lower()
	local options_p = passTable or options
	if disabled then
		print(OPTION_IS_DISABLED:format(path), realOptions.cmdName or realOptions.name or self)
	elseif kind == "text" then
		if #args > 0 then
			if (type(options.validate) == "table" and #args > 1) or (type(options.validate) ~= "table" and not options.input) then
				local arg = table.concat(args, " ")
				for k,v in pairs(args) do
					args[k] = nil
				end
				args[1] = arg
			end
			if options.validate then
				local good
				if type(options.validate) == "function" then
					good = options.validate(unpack(args))
				elseif type(options.validate) == "table" then
					local arg = args[1]
					arg = tostring(arg):lower()
					for k,v in pairs(options.validate) do
						if v:lower() == arg then
							args[1] = type(k) == "string" and k or v
							good = true
							break
						end
					end
					if not good and type((next(options.validate))) == "string" then
						for k,v in pairs(options.validate) do
							if type(k) == "string" and k:lower() == arg then
								args[1] = k
								good = true
								break
							end
						end
					end
				elseif options.validate == "keybinding" then
					good = keybindingValidateFunc(unpack(args))
					if good ~= false then
						args[1] = good
					end
				else
					if type(handler[options.validate]) ~= "function" then
						AceConsole:error("%s: %s", handler, OPTION_HANDLER_NOT_FOUND:format(tostring(options.validate)))
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
					elseif options.validate == "keybinding" then
						usage = KEYBINDING_USAGE
					else
						usage = options.usage or "<value>"
					end
					print((options.error or IS_NOT_A_VALID_OPTION_FOR):format(tostring(table.concat(args, " ")), path), realOptions.cmdName or realOptions.name or self)
					print(("|cffffff7f%s:|r %s %s"):format(USAGE, path, usage))
					return
				end
			end

			local var
			local multiToggle
			for k in pairs(tmp) do
				tmp[k] = nil
			end
			multiToggle = options_p.multiToggle
			if not options_p.get then
			elseif type(options_p.get) == "function" then
				if multiToggle then
					var = tmp
					for k,v in pairs(options.validate) do
						local val = type(k) ~= "number" and k or v
						if passValue then
							var[val] = options_p.get(passValue, val) or nil
						else
							var[val] = options_p.get(val) or nil
						end
					end
				else
					var = options_p.get(passValue)
				end
			else
				if type(handler[options_p.get]) ~= "function" then
					AceConsole:error("%s: %s", handler, OPTION_HANDLER_NOT_FOUND:format(tostring(options_p.get)))
				end
				if multiToggle then
					var = tmp
					for k,v in pairs(options.validate) do
						local val = type(k) ~= "number" and k or v
						if passValue then
							var[val] = handler[options_p.get](handler, passValue, val) or nil
						else
							var[val] = handler[options_p.get](handler, val) or nil
						end
					end
				else
					var = handler[options_p.get](handler, passValue)
				end
			end

			if multiToggle or var ~= args[1] then
				if multiToggle then
					local current = var[args[1]]
					if current == nil and type(args[1]) == "string" then
						for k in pairs(var) do
							if type(k) == "string" and k:lower() == args[1]:lower() then
								current = true
								break
							end
						end
					end
					args[2] = not current
				end
				if type(options_p.set) == "function" then
					if passValue then
						options_p.set(passValue, unpack(args))
					else
						options_p.set(unpack(args))
					end
				else
					if type(handler[options_p.set]) ~= "function" then
						AceConsole:error("%s: %s", handler, OPTION_HANDLER_NOT_FOUND:format(tostring(options_p.set)))
					end
					if passValue then
						handler[options_p.set](handler, passValue, unpack(args))
					else
						handler[options_p.set](handler, unpack(args))
					end
				end
			end
		end

		if #args > 0 then
			local var
			local multiToggle
			for k in pairs(tmp) do
				tmp[k] = nil
			end
			multiToggle = options_p.multiToggle
			if not options_p.get then
			elseif type(options_p.get) == "function" then
				if multiToggle then
					var = tmp
					for k,v in pairs(options_p.validate) do
						local val = type(k) ~= "number" and k or v
						if passValue then
							var[val] = options_p.get(passValue, val) or nil
						else
							var[val] = options_p.get(val) or nil
						end
					end
				else
					var = options_p.get(passValue)
				end
			else
				if type(handler[options_p.get]) ~= "function" then
					AceConsole:error("%s: %s", handler, OPTION_HANDLER_NOT_FOUND:format(tostring(options_p.get)))
				end
				if multiToggle then
					var = tmp
					for k,v in pairs(options.validate) do
						local val = type(k) ~= "number" and k or v
						if passValue then
							var[val] = handler[options_p.get](handler, passValue, val) or nil
						else
							var[val] = handler[options_p.get](handler, val) or nil
						end
					end
				else
					var = handler[options_p.get](handler, passValue)
				end
			end
			if multiToggle then
				if not next(var) then
					var = NONE
				else
					if not order then
						order = {}
					end
					for k in pairs(var) do
						if options.validate[k] then
							order[#order+1] = options.validate[k]
						else
							for _,v in pairs(options.validate) do
								if v == k or (type(v) == "string" and type(k) == "string" and v:lower() == k:lower()) then
									order[#order+1] = v
									break
								end
							end
						end
					end
					table.sort(order, icaseSort)
					var = table.concat(order, ", ")
					for k in pairs(order) do
						order[k] = nil
					end
				end
			elseif type(options.validate) == "table" then
				var = options.validate[var] or var
			end
			if options_p.get then
				print((options.message or IS_NOW_SET_TO):format(tostring(options.cmdName or options.name), tostring(var or NONE)), realOptions.cmdName or realOptions.name or self)
			end
			if var == args[1] then
				return
			end
		else
			printUsage(self, handler, realOptions, options, path, args, passValue)
			return
		end
	elseif kind == "execute" then
		local confirm = options.confirm
		if confirm == true then
			confirm = DEFAULT_CONFIRM_MESSAGE:format(options.desc or options.name or UNKNOWN or "Unknown")
		end
		if type(options_p.func) == "function" then
			if confirm then
				confirmPopup(confirm, options_p.func, passValue)
			else
				options_p.func(passValue)
			end
		else
			if type(handler[options_p.func]) ~= "function" then
				AceConsole:error("%s: %s", handler, OPTION_HANDLER_NOT_FOUND:format(tostring(options_p.func)))
			end
			if confirm then
				confirmPopup(confirm, handler[options_p.func], handler, passValue)
			else
				handler[options_p.func](handler, passValue)
			end
		end
	elseif kind == "toggle" then
		local var
		if type(options_p.get) == "function" then
			var = options_p.get(passValue)
		else
			local f = options_p.get
			local neg = f:match("^~(.-)$")
			if neg then
				f = neg
			end
			if type(handler[f]) ~= "function" then
				AceConsole:error("%s: %s", handler, OPTION_HANDLER_NOT_FOUND:format(tostring(f)))
			end
			var = handler[f](handler, passValue)
			if neg then
				var = not var
			end
		end
		if type(options_p.set) == "function" then
			if passValue then
				options_p.set(passValue, not var)
			else
				options_p.set(not var)
			end
		else
			if type(handler[options_p.set]) ~= "function" then
				AceConsole:error("%s: %s", handler, OPTION_HANDLER_NOT_FOUND:format(tostring(options_p.set)))
			end
			if passValue then
				handler[options_p.set](handler, passValue, not var)
			else
				handler[options_p.set](handler, not var)
			end
		end
		if type(options_p.get) == "function" then
			var = options_p.get(passValue)
		else
			local f = options_p.get
			local neg = f:match("^~(.-)$")
			if neg then
				f = neg
			end
			var = handler[f](handler, passValue)
			if neg then
				var = not var
			end
		end

		print((options.message or IS_NOW_SET_TO):format(tostring(options.cmdName or options.name), (options.map or MAP_ONOFF)[var and true or false] or NONE), realOptions.cmdName or realOptions.name or self)
	elseif kind == "range" then
		local arg
		if #args <= 1 then
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
				usage = ("(%s%s%s)"):format(min, bit, max)
				print((options.error or IS_NOT_A_VALID_VALUE_FOR):format(tostring(arg), path), realOptions.cmdName or realOptions.name or self)
				print(("|cffffff7f%s:|r %s %s"):format(USAGE, path, usage))
				return
			end

			local var
			if type(options_p.get) == "function" then
				var = options_p.get(passValue)
			else
				if type(handler[options_p.get]) ~= "function" then
					AceConsole:error("%s: %s", handler, OPTION_HANDLER_NOT_FOUND:format(tostring(options_p.get)))
				end
				var = handler[options_p.get](handler, passValue)
			end

			if var ~= arg then
				if type(options_p.set) == "function" then
					if passValue then
						options_p.set(passValue, arg)
					else
						options_p.set(arg)
					end
				else
					if type(handler[options_p.set]) ~= "function" then
						AceConsole:error("%s: %s", handler, OPTION_HANDLER_NOT_FOUND:format(tostring(options_p.set)))
					end
					if passValue then
						handler[options_p.set](handler, passValue, arg)
					else
						handler[options_p.set](handler, arg)
					end
				end
			end
		end

		if arg then
			local var
			if type(options_p.get) == "function" then
				var = options_p.get(passValue)
			else
				if type(handler[options_p.get]) ~= "function" then
					AceConsole:error("%s: %s", handler, OPTION_HANDLER_NOT_FOUND:format(tostring(options_p.get)))
				end
				var = handler[options_p.get](handler, passValue)
			end

			if var and options.isPercent then
				var = tostring(var * 100) .. "%"
			end
			print((options.message or IS_NOW_SET_TO):format(tostring(options.cmdName or options.name), tostring(var or NONE)), realOptions.cmdName or realOptions.name or self)
			if var == arg then
				return
			end
		else
			printUsage(self, handler, realOptions, options, path, args, passValue)
			return
		end
	elseif kind == "color" then
		if #args > 0 then
			local r,g,b,a
			if #args == 1 then
				local arg = tostring(args[1])
				if options.hasAlpha then
					if arg:len() == 8 and arg:find("^%x*$")  then
						r,g,b,a = tonumber(arg:sub(1, 2), 16) / 255, tonumber(arg:sub(3, 4), 16) / 255, tonumber(arg:sub(5, 6), 16) / 255, tonumber(arg:sub(7, 8), 16) / 255
					end
				else
					if arg:len() == 6 and arg:find("^%x*$") then
						r,g,b = tonumber(arg:sub(1, 2), 16) / 255, tonumber(arg:sub(3, 4), 16) / 255, tonumber(arg:sub(5, 6), 16) / 255
					end
				end
			elseif #args == 4 and options.hasAlpha then
				local a1,a2,a3,a4 = args[1], args[2], args[3], args[4]
				if type(a1) == "number" and type(a2) == "number" and type(a3) == "number" and type(a4) == "number" and a1 <= 1 and a2 <= 1 and a3 <= 1 and a4 <= 1 then
					r,g,b,a = a1,a2,a3,a4
				elseif (type(a1) == "number" or a1:len() == 2) and a1:find("^%x*$") and (type(a2) == "number" or a2:len() == 2) and a2:find("^%x*$") and (type(a3) == "number" or a3:len() == 2) and a3:find("^%x*$") and (type(a4) == "number" or a4:len() == 2) and a4:find("^%x*$") then
					r,g,b,a = tonumber(a1, 16) / 255, tonumber(a2, 16) / 255, tonumber(a3, 16) / 255, tonumber(a4, 16) / 255
				end
			elseif #args == 3 and not options.hasAlpha then
				local a1,a2,a3 = args[1], args[2], args[3]
				if type(a1) == "number" and type(a2) == "number" and type(a3) == "number" and a1 <= 1 and a2 <= 1 and a3 <= 1 then
					r,g,b = a1,a2,a3
				elseif (type(a1) == "number" or a1:len() == 2) and a1:find("^%x*$") and (type(a2) == "number" or a2:len() == 2) and a2:find("^%x*$") and (type(a3) == "number" or a3:len() == 2) and a3:find("^%x*$") then
					r,g,b = tonumber(a1, 16) / 255, tonumber(a2, 16) / 255, tonumber(a3, 16) / 255
				end
			end
			if not r then
				print((options.error or IS_NOT_A_VALID_OPTION_FOR):format(table.concat(args, ' '), path), realOptions.cmdName or realOptions.name or self)
				print(("|cffffff7f%s:|r %s {0-1} {0-1} {0-1}%s"):format(USAGE, path, options.hasAlpha and " {0-1}" or ""))
				return
			end

			if type(options_p.set) == "function" then
				if passValue then
					options_p.set(passValue, r,g,b,a)
				else
					options_p.set(r,g,b,a)
				end
			else
				if type(handler[options_p.set]) ~= "function" then
					AceConsole:error("%s: %s", handler, OPTION_HANDLER_NOT_FOUND:format(tostring(options_p.set)))
				end
				if passValue then
					handler[options_p.set](handler, passValue, r,g,b,a)
				else
					handler[options_p.set](handler, r,g,b,a)
				end
			end

			local r,g,b,a
			if type(options_p.get) == "function" then
				r,g,b,a = options_p.get(passValue)
			else
				if type(handler[options_p.get]) ~= "function" then
					AceConsole:error("%s: %s", handler, OPTION_HANDLER_NOT_FOUND:format(tostring(options_p.get)))
				end
				r,g,b,a = handler[options_p.get](handler, passValue)
			end

			local s
			if type(r) == "number" and type(g) == "number" and type(b) == "number" then
				if options.hasAlpha and type(a) == "number" then
					s = ("|c%02x%02x%02x%02x%02x%02x%02x%02x|r"):format(a*255, r*255, g*255, b*255, r*255, g*255, b*255, a*255)
				else
					s = ("|cff%02x%02x%02x%02x%02x%02x|r"):format(r*255, g*255, b*255, r*255, g*255, b*255)
				end
			else
				s = NONE
			end
			print((options.message or IS_NOW_SET_TO):format(tostring(options.cmdName or options.name), s), realOptions.cmdName or realOptions.name or self)
		else
			local r,g,b,a
			if type(options_p.get) == "function" then
				r,g,b,a = options_p.get(passValue)
			else
				if type(handler[options_p.get]) ~= "function" then
					AceConsole:error("%s: %s", handler, OPTION_HANDLER_NOT_FOUND:format(tostring(options_p.get)))
				end
				r,g,b,a = handler[options_p.get](handler, passValue)
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
										AceConsole:error("%s: %s", handler, OPTION_HANDLER_NOT_FOUND:format(tostring(t.get)))
									end
									r,g,b,a = t.handler[t.get](t.handler, t.passValue)
								end
							else
								if type(t.get) == "function" then
									r,g,b,a = t.get()
								else
									if type(t.handler[t.get]) ~= "function" then
										AceConsole:error("%s: %s", handler, OPTION_HANDLER_NOT_FOUND:format(tostring(t.get)))
									end
									r,g,b,a = t.handler[t.get](t.handler)
								end
							end
							if r ~= t.r or g ~= t.g or b ~= t.b or (t.hasAlpha and a ~= t.a) then
								local s
								if type(r) == "number" and type(g) == "number" and type(b) == "number" then
									if t.hasAlpha and type(a) == "number" then
										s = ("|c%02x%02x%02x%02x%02x%02x%02x%02x|r"):format(a*255, r*255, g*255, b*255, r*255, g*255, b*255, a*255)
									else
										s = ("|cff%02x%02x%02x%02x%02x%02x|r"):format(r*255, g*255, b*255, r*255, g*255, b*255)
									end
								else
									s = NONE
								end
								print(t.message:format(tostring(t.name), s), t.realOptions.cmdName or t.realOptions.name or self)
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
			t.set = options_p.set
			t.get = options_p.get
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
								AceConsole:error("%s: %s", handler, OPTION_HANDLER_NOT_FOUND:format(tostring(t.set)))
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
								AceConsole:error("%s: %s", handler, OPTION_HANDLER_NOT_FOUND:format(tostring(t.set)))
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
								AceConsole:error("%s: %s", handler, OPTION_HANDLER_NOT_FOUND:format(tostring(t.get)))
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
								AceConsole:error("%s: %s", handler, OPTION_HANDLER_NOT_FOUND:format(tostring(t.set)))
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
		if #args == 0 then
			printUsage(self, handler, realOptions, options, path, args, passValue)
		else
			-- invalid argument
			print((options.error or IS_NOT_A_VALID_OPTION_FOR):format(args[1], path), realOptions.cmdName or realOptions.name or self)
		end
		return
	end
	if Dewdrop then
		Dewdrop:Refresh()
	end
end

local external
local tmp
function AceConsole:RegisterChatCommand(...) -- slashCommands, options, name
	local slashCommands, options, name
	if type((...)) == "string" then
		if not tmp then
			tmp = {}
		else
			for i in ipairs(tmp) do
				tmp[i] = nil
			end
		end
		for i = 1, select('#', ...)+1 do
			local v = select(i, ...)
			if type(v) == "string" then
				tmp[#tmp+1] = v
			else
				slashCommands = tmp
				options = v
				name = select(i+1, ...)
				break
			end
		end
	else
		slashCommands, options, name = ...
	end
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
		elseif not name:find("^%w+$") or name:upper() ~= name or name:len() == 0 then
			AceConsole:error("Argument #4 must be an uppercase, letters-only string with at least 1 character")
		end
	end
	if slashCommands then
		if #slashCommands == 0 then
			AceConsole:error("Argument #2 to `RegisterChatCommand' must include at least one string")
		end

		for k,v in pairs(slashCommands) do
			if type(k) ~= "number" then
				AceConsole:error("All keys in argument #2 to `RegisterChatCommand' must be numbers")
			end
			if type(v) ~= "string" then
				AceConsole:error("All values in argument #2 to `RegisterChatCommand' must be strings")
			elseif not v:find("^/[A-Za-z][A-Za-z0-9_]*$") then
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

		if options.handler == self and options.type:lower() == "group" and self.class then
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
				handler = function(msg, chatFrame)
					return _G[k](msg, chatFrame)
				end
				break
			end
		end
	else
		function handler(msg, chatFrame)
			handlerFunc(self, chat, msg, options)
		end
	end

	if not _G.SlashCmdList then
		_G.SlashCmdList = {}
	end

	if not name and type(slashCommands) == "table" and type(slashCommands[1]) == "string" then
		name = slashCommands[1]:gsub("%A", ""):upper()
	end

	if not name then
		local A = ('A'):byte()
		repeat
			name = string.char(math.random(26) + A - 1) .. string.char(math.random(26) + A - 1) .. string.char(math.random(26) + A - 1) .. string.char(math.random(26) + A - 1) .. string.char(math.random(26) + A - 1) .. string.char(math.random(26) + A - 1) .. string.char(math.random(26) + A - 1) .. string.char(math.random(26) + A - 1)
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
			if command:lower() ~= command then
				i = i + 1
				_G["SLASH_"..name..i] = command:lower()
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

	if slashCommands == tmp then
		for i in ipairs(tmp) do
			tmp[i] = nil
		end
	end
end

function AceConsole:InjectAceOptionsTable(handler, options)
	self:argCheck(handler, 2, "table")
	self:argCheck(options, 3, "table")
	if options.type:lower() ~= "group" then
		self:error('Cannot inject into options table argument #3 if its type is not "group"')
	end
	if options.handler ~= nil and options.handler ~= handler then
		self:error("Cannot inject into options table argument #3 if it has a different handler than argument #2")
	end
	options.handler = handler
	local class = handler.class
	if not AceLibrary:HasInstance("AceOO-2.0") or not class then
		if Rock then
			-- possible Rock object
			for mixin in Rock:IterateObjectMixins(handler) do
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
	else
		-- Ace2 object
		while class and class ~= AceLibrary("AceOO-2.0").Class do
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
	end
	
	return options
end

function AceConsole:PLAYER_LOGIN()
	self.playerLogin = true
	for addon, options in pairs(self.nextAddon) do
		local err, position = validateOptionsMethods(addon, options)
		if err then
			if position then
				geterrorhandler()(tostring(addon) .. ": AceConsole: " .. position .. ": " .. err)
			else
				geterrorhandler()(tostring(addon) .. ": AceConsole: " .. err)
			end
		end
		self.nextAddon[addon] = nil
	end
end

function AceConsole:TabCompleteInfo(cmdpath)
	local cmd =  cmdpath:match("(/%S+)")
	if not cmd then
		return
	end
	local path = cmdpath:sub(cmd:len() + 2)
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
			local name, cmd, path = self:TabCompleteInfo(cmdpath:sub(1, pos))

			if not self.registry[name] then
				return false
			else
				local validArgs, _, _, handler = findTableLevel(self, self.registry[name], cmd, path or "")
				if validArgs.args then
					for arg, v in pairs(validArgs.args) do
						local hidden = v.hidden
						local handler = v.handler or handler
						if hidden then
							if type(hidden) == "function" then
								hidden = hidden(v.passValue)
							elseif type(hidden) == "string" then
								local f = hidden
								local neg = f:match("^~(.-)$")
								if neg then
									f = neg
								end
								if type(handler[f]) ~= "function" then
									self:error("%s: %s", handler, OPTION_HANDLER_NOT_FOUND:format(tostring(f)))
								end
								hidden = handler[f](handler, v.passValue)
								if neg then
									hidden = not hidden
								end
							end
						end
						local disabled = hidden or v.disabled
						if disabled then
							if type(disabled) == "function" then
								disabled = disabled(v.passValue)
							elseif type(disabled) == "string" then
								local f = disabled
								local neg = f:match("^~(.-)$")
								if neg then
									f = neg
								end
								if type(handler[f]) ~= "function" then
									self:error("%s: %s", handler, OPTION_HANDLER_NOT_FOUND:format(tostring(f)))
								end
								disabled = handler[f](handler, v.passValue)
								if neg then
									disabled = not disabled
								end
							end
						end
						if not hidden and not disabled and v.type ~= "header" then
							table.insert(t, (tostring(arg):gsub("%s", "-")))
						end
					end
				end
			end
		end, function(u, matches, gcs, cmdpath)
			local name, cmd, path = self:TabCompleteInfo(cmdpath)
			if self.registry[name] then
				local validArgs, path2, argwork, handler = findTableLevel(self, self.registry[name], cmd, path)
				printUsage(self, validArgs.handler or handler, self.registry[name], validArgs, path2, argwork, argwork[#argwork], not gcs or gcs ~= "", gcs)
			end
		end)
	elseif major == "Dewdrop-2.0" then
		Dewdrop = instance
	end
end

local function activate(self, oldLib, oldDeactivate)
	AceConsole = self

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

	self:RegisterChatCommand("/reload", "/rl", "/reloadui", ReloadUI, "RELOAD")
	self:RegisterChatCommand("/gm", ToggleHelpFrame, "GM")
	local t = { "/print", "/echo" }
	local _,_,_,enabled,loadable = GetAddOnInfo("DevTools")
	if not enabled and not loadable then
		table.insert(t, "/dump")
	end
	self:RegisterChatCommand(t, function(text)
		text = text:trim():match("^(.-);*$")
		local f, err = loadstring("AceLibrary('AceConsole-2.0'):PrintLiteral(" .. text .. ")")
		if not f then
			self:Print("|cffff0000Error:|r", err)
		else
			f()
		end
	end, "PRINT")

	self:activate(oldLib, oldDeactivate)

	if oldDeactivate then
		oldDeactivate(oldLib)
	end
end

AceLibrary:Register(AceConsole, MAJOR_VERSION, MINOR_VERSION, activate, nil, external)
