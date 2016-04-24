--[[
Name: AceDB-2.0
Revision: $Rev: 1091 $
Developed by: The Ace Development Team (http://www.wowace.com/index.php/The_Ace_Development_Team)
Inspired By: Ace 1.x by Turan (turan@gryphon.com)
Website: http://www.wowace.com/
Documentation: http://www.wowace.com/index.php/AceDB-2.0
SVN: http://svn.wowace.com/wowace/trunk/Ace2/AceDB-2.0
Description: Mixin to allow for fast, clean, and featureful saved variable
             access.
Dependencies: AceLibrary, AceOO-2.0, AceEvent-2.0
License: LGPL v2.1
]]

local MAJOR_VERSION = "AceDB-2.0"
local MINOR_VERSION = 90000 + tonumber(("$Revision: 1091 $"):match("(%d+)"))

if not AceLibrary then error(MAJOR_VERSION .. " requires AceLibrary") end
if not AceLibrary:IsNewVersion(MAJOR_VERSION, MINOR_VERSION) then return end

if not AceLibrary:HasInstance("AceOO-2.0") then error(MAJOR_VERSION .. " requires AceOO-2.0") end

local function safecall(func,...)
	local success, err = pcall(func,...)
	if not success then geterrorhandler()(err) end
end

local ACTIVE, ENABLED, STATE, TOGGLE_ACTIVE, MAP_ACTIVESUSPENDED, SET_PROFILE, SET_PROFILE_USAGE, PROFILE, PLAYER_OF_REALM, CHOOSE_PROFILE_DESC, CHOOSE_PROFILE_GUI, COPY_PROFILE_DESC, COPY_PROFILE_GUI, OTHER_PROFILE_DESC, OTHER_PROFILE_GUI, OTHER_PROFILE_USAGE, RESET_PROFILE, RESET_PROFILE_DESC, CHARACTER_COLON, REALM_COLON, CLASS_COLON, DEFAULT, ALTERNATIVE

-- Move these into "enUS" when they've been translated in all other locales
local DELETE_PROFILE = "Delete"
local DELETE_PROFILE_DESC = "Deletes a profile. Note that no check is made whether this profile is in use by other characters or not."
local DELETE_PROFILE_USAGE = "<profile name>"

if GetLocale() == "deDE" then
	DELETE_PROFILE = "L\195\182schen"
	DELETE_PROFILE_DESC = "L\195\182scht ein Profil. Beachte das nicht \195\188berpr\195\188ft wird ob das zu l\195\182schende Profil von anderen Charakteren genutzt wird oder nicht."
	DELETE_PROFILE_USAGE = "<profil name>"

	ACTIVE = "Aktiv"
	ENABLED = "Aktiviert"
	STATE = "Status"
	TOGGLE_ACTIVE = "Stoppt/Aktiviert dieses Addon."
	MAP_ACTIVESUSPENDED = { [true] = "|cff00ff00Aktiv|r", [false] = "|cffff0000Gestoppt|r" }
	SET_PROFILE = "Setzt das Profil f\195\188r dieses Addon."
	SET_PROFILE_USAGE = "{Charakter || Klasse || Realm || <Profilname>}"
	PROFILE = "Profil"
	PLAYER_OF_REALM = "%s von %s"
	CHOOSE_PROFILE_DESC = "W\195\164hle ein Profil."
	CHOOSE_PROFILE_GUI = "W\195\164hle"
	COPY_PROFILE_DESC = "Kopiert Einstellungen von einem anderem Profil."
	COPY_PROFILE_GUI = "Kopiere von"
	OTHER_PROFILE_DESC = "W\195\164hle ein anderes Profil."
	OTHER_PROFILE_GUI = "Anderes"
	OTHER_PROFILE_USAGE = "<Profilname>"
	RESET_PROFILE = "Resette das Profil"
	RESET_PROFILE_DESC = "Entfernt alle Einstellungen des gegenw\195\164rtigen Profils."

	CHARACTER_COLON = "Charakter: "
	REALM_COLON = "Realm: "
	CLASS_COLON = "Klasse: "

	DEFAULT = "Vorgabe"
	ALTERNATIVE = "Alternativ"
elseif GetLocale() == "frFR" then
	ACTIVE = "Actif"
	ENABLED = "Activ\195\169"
	STATE = "Etat"
	TOGGLE_ACTIVE = "Suspend/active cet addon."
	MAP_ACTIVESUSPENDED = { [true] = "|cff00ff00Actif|r", [false] = "|cffff0000Suspendu|r" }
	SET_PROFILE = "S\195\169lectionne le profil pour cet addon."
	SET_PROFILE_USAGE = "{perso || classe || royaume || <nom de profil>}"
	PROFILE = "Profil"
	PLAYER_OF_REALM = "%s de %s"
	CHOOSE_PROFILE_DESC = "Choisissez un profil."
	CHOOSE_PROFILE_GUI = "Choix"
	COPY_PROFILE_DESC = "Copier les param\195\168tres d'un autre profil."
	COPY_PROFILE_GUI = "Copier \195\160 partir de"
	OTHER_PROFILE_DESC = "Choisissez un autre profil."
	OTHER_PROFILE_GUI = "Autre"
	OTHER_PROFILE_USAGE = "<nom de profil>"
	RESET_PROFILE = "Reset profile" -- fix
	RESET_PROFILE_DESC = "Clear all settings of the current profile." -- fix

	CHARACTER_COLON = "Personnage: "
	REALM_COLON = "Royaume: "
	CLASS_COLON = "Classe: "

	DEFAULT = "Default" -- fix
	ALTERNATIVE = "Alternative" -- fix
elseif GetLocale() == "koKR" then
	DELETE_PROFILE = "삭제"
	DELETE_PROFILE_DESC = "프로필을 삭제합니다."
	DELETE_PROFILE_USAGE = "<프로필명>"

	ACTIVE = "사용"
	ENABLED = "사용"
	STATE = "상태"
	TOGGLE_ACTIVE = "이 애드온 중지/다시 시작"
	MAP_ACTIVESUSPENDED = { [true] = "|cff00ff00사용|r", [false] = "|cffff0000중지|r" }
	SET_PROFILE = "이 애드온에 프로필 설정"
	SET_PROFILE_USAGE = "{캐릭터명 || 직업 || 서버명 || <프로필명>}"
	PROFILE = "프로필"
	PLAYER_OF_REALM = "%s (%s 서버)"
	CHOOSE_PROFILE_DESC = "프로필을 선택합니다."
	CHOOSE_PROFILE_GUI = "선택"
	COPY_PROFILE_DESC = "다른 프로필 설정을 복사합니다."
	COPY_PROFILE_GUI = "복사"
	OTHER_PROFILE_DESC = "다른 프로필을 선택합니다."
	OTHER_PROFILE_GUI = "기타"
	OTHER_PROFILE_USAGE = "<프로필명>"
	RESET_PROFILE = "프로필 초기화"
	RESET_PROFILE_DESC = "모든 세팅에서 현재 프로필을 초기화 합니다."

	CHARACTER_COLON = "캐릭터: "
	REALM_COLON = "서버: "
	CLASS_COLON = "직업: "

	DEFAULT = "기본값"
	ALTERNATIVE = "대체"
elseif GetLocale() == "zhTW" then
	DELETE_PROFILE = "刪除"
	DELETE_PROFILE_DESC = "刪除記錄檔。注意，有可能別的角色也使用這個記錄檔。"
	DELETE_PROFILE_USAGE = "<記錄檔名稱>"

	ACTIVE = "啟動"
	ENABLED = "啟用"
	STATE = "狀態"
	TOGGLE_ACTIVE = "暫停/繼續使用這個插件。"
	MAP_ACTIVESUSPENDED = { [true] = "|cff00ff00啟動|r", [false] = "|cffff0000已暫停|r" }
	SET_PROFILE = "設定這插件的記錄檔。"
	SET_PROFILE_USAGE = "{角色 || 職業 || 伺服器 || <記錄檔名稱>}"
	PROFILE = "記錄檔"
	PLAYER_OF_REALM = "%s - %s"
	CHOOSE_PROFILE_DESC = "選擇一個記錄檔。"
	CHOOSE_PROFILE_GUI = "選擇"
	COPY_PROFILE_DESC = "由其他記錄檔複製設定。"
	COPY_PROFILE_GUI = "複製自"
	OTHER_PROFILE_DESC = "選擇其他記錄檔。"
	OTHER_PROFILE_GUI = "其他"
	OTHER_PROFILE_USAGE = "<記錄檔名稱>"
	RESET_PROFILE = "重設記錄檔"
	RESET_PROFILE_DESC = "清除目前的記錄檔上的所有設定。"

	CHARACTER_COLON = "角色: "
	REALM_COLON = "伺服器: "
	CLASS_COLON = "職業: "

	DEFAULT = "預設"
	ALTERNATIVE = "替代"
elseif GetLocale() == "zhCN" then
	ACTIVE = "\230\156\137\230\149\136"
	ENABLED = "\229\144\175\231\148\168"
	STATE = "\231\138\182\230\128\129"
	TOGGLE_ACTIVE = "\230\154\130\229\129\156/\230\129\162\229\164\141 \230\173\164\230\143\146\228\187\182."
	MAP_ACTIVESUSPENDED = { [true] = "|cff00ff00\230\156\137\230\149\136|r", [false] = "|cffff0000\230\154\130\229\129\156|r" }
	SET_PROFILE = "\232\174\190\231\189\174\233\133\141\231\189\174\230\150\135\228\187\182\228\184\186\232\191\153\230\143\146\228\187\182."
	SET_PROFILE_USAGE = "{\229\173\151\231\172\166 || \233\128\137\228\187\182\231\177\187 || \229\159\159 || <\233\133\141\231\189\174\230\150\135\228\187\182\229\144\141\229\173\151>}"
	PROFILE = "\233\133\141\231\189\174\230\150\135\228\187\182"
	PLAYER_OF_REALM = "%s \231\154\132 %s"
	CHOOSE_PROFILE_DESC = "\233\128\137\230\139\169\233\133\141\231\189\174\230\150\135\228\187\182."
	CHOOSE_PROFILE_GUI = "\233\128\137\230\139\169"
	COPY_PROFILE_DESC = "\229\164\141\229\136\182\232\174\190\231\189\174\228\187\142\229\143\166\228\184\128\228\184\170\233\133\141\231\189\174\230\150\135\228\187\182."
	COPY_PROFILE_GUI = "\229\164\141\229\136\182\228\187\142"
	OTHER_PROFILE_DESC = "\233\128\137\230\139\169\229\143\166\228\184\128\228\184\170\233\133\141\231\189\174\230\150\135\228\187\182."
	OTHER_PROFILE_GUI = "\229\133\182\228\187\150"
	OTHER_PROFILE_USAGE = "<\233\133\141\231\189\174\230\150\135\228\187\182\229\144\141\229\173\151>"
	RESET_PROFILE = "Reset profile" -- fix
	RESET_PROFILE_DESC = "Clear all settings of the current profile." -- fix

	CHARACTER_COLON = "\229\173\151\231\172\166: "
	REALM_COLON = "\229\159\159: "
	CLASS_COLON = "\233\128\137\228\187\182\231\177\187: "

	DEFAULT = "Default" -- fix
	ALTERNATIVE = "Alternative" -- fix
elseif GetLocale() == "esES" then
	ACTIVE = "Activo"
	ENABLED = "Activado"
	STATE = "Estado"
	TOGGLE_ACTIVE = "Parar/Continuar este accesorio"
	MAP_ACTIVESUSPENDED = { [true] = "|cff00ff00Activo|r", [false] = "|cffff0000Parado|r" }
	SET_PROFILE = "Selecciona el perfil para este accesorio."
	SET_PROFILE_USAGE = "{perso || clase || reino || <nombre del perfil>}"
	PROFILE = "Perfil"
	PLAYER_OF_REALM = "%s de %s"
	CHOOSE_PROFILE_DESC = "Elige un perfil."
	CHOOSE_PROFILE_GUI = "Elige"
	COPY_PROFILE_DESC = "Copiar de un perfil a otro"
	COPY_PROFILE_GUI = "Copiar desde"
	OTHER_PROFILE_DESC = "Elige otro perfil."
	OTHER_PROFILE_GUI = "Otro"
	OTHER_PROFILE_USAGE = "<nombre del perfil>"
	RESET_PROFILE = "Reset profile" -- fix
	RESET_PROFILE_DESC = "Clear all settings of the current profile." -- fix

	CHARACTER_COLON = "Personaje: "
	REALM_COLON = "Reino: "
	CLASS_COLON = "Clase: "

	DEFAULT = "Por defecto"
	ALTERNATIVE = "Alternativo"
elseif GetLocale() == "ruRU" then
	DELETE_PROFILE = "Удалить"
	DELETE_PROFILE_DESC = "Удалить профиль. Изначально проверьте не используется ли этот профиль другими персонажами, чтобы не натворить себе неудобств."
	DELETE_PROFILE_USAGE = "<название профиляe>"

	ACTIVE = "Активный"
	ENABLED = "Включён"
	STATE = "Состояние"
	TOGGLE_ACTIVE = "Отключить/Запустить аддон."
	MAP_ACTIVESUSPENDED = { [true] = "|cff00ff00Активный|r", [false] = "|cffff0000Suspended|r" }
	SET_PROFILE = "Установить профиль для этого аддона."
	SET_PROFILE_USAGE = "{чар || класс || сервер || <название профиля>}"
	PROFILE = "Профиль"
	PLAYER_OF_REALM = "%s из %s"
	CHOOSE_PROFILE_DESC = "Выберите профиль."
	CHOOSE_PROFILE_GUI = "Выбор"
	COPY_PROFILE_DESC = "Скопировать настройки с другого профиля."
	COPY_PROFILE_GUI = "Скопировать с"
	OTHER_PROFILE_DESC = "Выбрать другой профиль."
	OTHER_PROFILE_GUI = "Другое"
	OTHER_PROFILE_USAGE = "<название профиля>"
	RESET_PROFILE = "Сброс профиля"
	RESET_PROFILE_DESC = "Очистить все настройки для текущего профиля."

	CHARACTER_COLON = "Персонаж: "
	REALM_COLON = "Сервер: "
	CLASS_COLON = "Класс: "

	DEFAULT = "По умолчанию"
	ALTERNATIVE = "Альтернатива"
else -- enUS
	ACTIVE = "Active"
	ENABLED = "Enabled"
	STATE = "State"
	TOGGLE_ACTIVE = "Suspend/resume this addon."
	MAP_ACTIVESUSPENDED = { [true] = "|cff00ff00Active|r", [false] = "|cffff0000Suspended|r" }
	SET_PROFILE = "Set profile for this addon."
	SET_PROFILE_USAGE = "{char || class || realm || <profile name>}"
	PROFILE = "Profile"
	PLAYER_OF_REALM = "%s of %s"
	CHOOSE_PROFILE_DESC = "Choose a profile."
	CHOOSE_PROFILE_GUI = "Choose"
	COPY_PROFILE_DESC = "Copy settings from another profile."
	COPY_PROFILE_GUI = "Copy from"
	OTHER_PROFILE_DESC = "Choose another profile."
	OTHER_PROFILE_GUI = "Other"
	OTHER_PROFILE_USAGE = "<profile name>"
	RESET_PROFILE = "Reset profile"
	RESET_PROFILE_DESC = "Clear all settings of the current profile."

	CHARACTER_COLON = "Character: "
	REALM_COLON = "Realm: "
	CLASS_COLON = "Class: "

	DEFAULT = "Default"
	ALTERNATIVE = "Alternative"
end
local convertFromOldCharID
do
	local matchStr = "^" .. PLAYER_OF_REALM:gsub("([%(%)%.%*%+%-%[%]%?%^%$%%])", "%%%1"):gsub("%%s", "(.+)") .. "$"
	function convertFromOldCharID(str)
		local player, realm = str:match(matchStr)
		if not player then
			return str
		end
		return player .. " - " .. realm
	end
end

local AceOO = AceLibrary("AceOO-2.0")
local AceEvent
local Mixin = AceOO.Mixin
local AceDB = Mixin {
						"RegisterDB",
						"RegisterDefaults",
						"ResetDB",
						"SetProfile",
						"GetProfile",
						"CopyProfileFrom",
						"DeleteProfile",
						"ToggleActive",
						"IsActive",
						"AcquireDBNamespace",
					}
local Dewdrop = AceLibrary:HasInstance("Dewdrop-2.0") and AceLibrary("Dewdrop-2.0")

local _G = getfenv(0)

local function inheritDefaults(t, defaults)
	if not defaults then
		return t
	end
	for k,v in pairs(defaults) do
		if k == "*" or k == "**" then
			local v = v
			if type(v) == "table" then
				setmetatable(t, {
					__index = function(self, key)
						if key == nil then
							return nil
						end
						self[key] = {}
						inheritDefaults(self[key], v)
						return self[key]
					end
				} )
			else
				setmetatable(t, {
					__index = function(self, key)
						if key == nil then
							return nil
						end
						self[key] = v
						return self[key]
					end
				} )
			end
			for key in pairs(t) do
				if (defaults[key] == nil or key == k) and type(t[key]) == "table" then
					inheritDefaults(t[key], v)
				end
			end
		else
			if type(v) == "table" then
				if type(rawget(t, k)) ~= "table" then
					t[k] = {}
				end
				inheritDefaults(t[k], v)
				if defaults["**"] then
					inheritDefaults(t[k], defaults["**"])
				end
			elseif rawget(t, k) == nil then
				t[k] = v
			end
		end
	end
	return t
end

local _,race = UnitRace("player")
local faction
if race == "Orc" or race == "Scourge" or race == "Troll" or race == "Tauren" or race == "BloodElf" then
	faction = FACTION_HORDE
else
	faction = FACTION_ALLIANCE
end
local server = GetRealmName():trim()
local charID = UnitName("player") .. " - " .. server
local realmID = server .. " - " .. faction
local classID = UnitClass("player")

AceDB.CHAR_ID = charID
AceDB.REALM_ID = realmID
AceDB.CLASS_ID = classID

AceDB.FACTION = faction
AceDB.REALM = server
AceDB.NAME = UnitName("player")

local new, del
do
	local list = setmetatable({}, {__mode="k"})
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

local caseInsensitive_mt = {
	__index = function(self, key)
		if type(key) ~= "string" then
			return nil
		end
		local lowerKey = key:lower()
		for k,v in pairs(self) do
			if k:lower() == lowerKey then
				return self[k]
			end
		end
	end,
	__newindex = function(self, key, value)
		if type(key) ~= "string" then
			return error("table index is nil", 2)
		end
		local lowerKey = key:lower()
		for k in pairs(self) do
			if k:lower() == lowerKey then
				rawset(self, k, nil)
				rawset(self, key, value)
				return
			end
		end
		rawset(self, key, value)
	end
}

local db_mt = { __index = function(db, key)
	if key == "char" then
		if db.charName then
			if type(_G[db.charName]) ~= "table" then
				_G[db.charName] = {}
			end
			if type(_G[db.charName].global) ~= "table" then
				_G[db.charName].global = {}
			end
			rawset(db, 'char', _G[db.charName].global)
		else
			if type(db.raw.chars) ~= "table" then
				db.raw.chars = {}
			end
			local id = charID
			if type(db.raw.chars[id]) ~= "table" then
				db.raw.chars[id] = {}
			end
			rawset(db, 'char', db.raw.chars[id])
		end
		if db.defaults and db.defaults.char then
			inheritDefaults(db.char, db.defaults.char)
		end
		return db.char
	elseif key == "realm" then
		if type(db.raw.realms) ~= "table" then
			db.raw.realms = {}
		end
		local id = realmID
		if type(db.raw.realms[id]) ~= "table" then
			db.raw.realms[id] = {}
		end
		rawset(db, 'realm', db.raw.realms[id])
		if db.defaults and db.defaults.realm then
			inheritDefaults(db.realm, db.defaults.realm)
		end
		return db.realm
	elseif key == "server" then
		if type(db.raw.servers) ~= "table" then
			db.raw.servers = {}
		end
		local id = server
		if type(db.raw.servers[id]) ~= "table" then
			db.raw.servers[id] = {}
		end
		rawset(db, 'server', db.raw.servers[id])
		if db.defaults and db.defaults.server then
			inheritDefaults(db.server, db.defaults.server)
		end
		return db.server
	elseif key == "account" then
		if type(db.raw.account) ~= "table" then
			db.raw.account = {}
		end
		rawset(db, 'account', db.raw.account)
		if db.defaults and db.defaults.account then
			inheritDefaults(db.account, db.defaults.account)
		end
		return db.account
	elseif key == "faction" then
		if type(db.raw.factions) ~= "table" then
			db.raw.factions = {}
		end
		local id = faction
		if type(db.raw.factions[id]) ~= "table" then
			db.raw.factions[id] = {}
		end
		rawset(db, 'faction', db.raw.factions[id])
		if db.defaults and db.defaults.faction then
			inheritDefaults(db.faction, db.defaults.faction)
		end
		return db.faction
	elseif key == "class" then
		if type(db.raw.classes) ~= "table" then
			db.raw.classes = {}
		end
		local id = classID
		if type(db.raw.classes[id]) ~= "table" then
			db.raw.classes[id] = {}
		end
		rawset(db, 'class', db.raw.classes[id])
		if db.defaults and db.defaults.class then
			inheritDefaults(db.class, db.defaults.class)
		end
		return db.class
	elseif key == "profile" then
		if type(db.raw.profiles) ~= "table" then
			db.raw.profiles = setmetatable({}, caseInsensitive_mt)
		else
			setmetatable(db.raw.profiles, caseInsensitive_mt)
		end
		local id = db.raw.currentProfile[charID]
		if id == "char" then
			id = "char/" .. charID
		elseif id == "class" then
			id = "class/" .. classID
		elseif id == "realm" then
			id = "realm/" .. realmID
		end
		if type(db.raw.profiles[id]) ~= "table" then
			db.raw.profiles[id] = {}
		end
		rawset(db, 'profile', db.raw.profiles[id])
		if db.defaults and db.defaults.profile then
			inheritDefaults(db.profile, db.defaults.profile)
		end
		return db.profile
	elseif key == "raw" or key == "defaults" or key == "name" or key == "charName" or key == "namespaces" then
		return nil
	end
	error(("Cannot access key %q in db table. You may want to use db.profile[%q]"):format(tostring(key), tostring(key)), 2)
end, __newindex = function(db, key, value)
	error(("Cannot access key %q in db table. You may want to use db.profile[%q]"):format(tostring(key), tostring(key)), 2)
end }

local function RecalculateAceDBCopyFromList(target)
	local db = target.db
	local t = target['acedb-profile-copylist']
	for k,v in pairs(t) do
		t[k] = nil
	end
	local _,currentProfile = AceDB.GetProfile(target)
	if db and db.raw then
		if db.raw.profiles then
			for k in pairs(db.raw.profiles) do
				if currentProfile ~= k then
					if k:find("^char/") then
						local name = k:sub(6)
						local player, realm = name:match("^(.*) %- (.*)$")
						if player then
							name = PLAYER_OF_REALM:format(player, realm)
						end
						t[k] = CHARACTER_COLON .. name
					elseif k:find("^realm/") then
						local name = k:sub(7)
						t[k] = REALM_COLON .. name
					elseif k:find("^class/") then
						local name = k:sub(7)
						t[k] = CLASS_COLON .. name
					else
						t[k] = k
					end
				end
			end
		end
		if db.raw.namespaces then
			for _,n in pairs(db.raw.namespaces) do
				if n.profiles then
					for k in pairs(n.profiles) do
						if currentProfile ~= k then
							if k:find('^char/') then
								local name = k:sub(6)
								local player, realm = name:match("^(.*) %- (.*)$")
								if player then
									name = PLAYER_OF_REALM:format(player, realm)
								end
								t[k] = CHARACTER_COLON .. name
							elseif k:find('^realm/') then
								local name = k:sub(7)
								t[k] = REALM_COLON .. name
							elseif k:find('^class/') then
								local name = k:sub(7)
								t[k] = CLASS_COLON .. name
							else
								t[k] = k
							end
						end
					end
				end
			end
		end
	end
	if t.Default then
		t.Default = DEFAULT
	end
	if t.Alternative then
		t.Alternative = ALTERNATIVE
	end
end

local function RecalculateAceDBProfileList(target)
	local t = target['acedb-profile-list']
	for k,v in pairs(t) do
		t[k] = nil
	end
	t.char = CHARACTER_COLON .. PLAYER_OF_REALM:format(UnitName("player"), server)
	t.realm = REALM_COLON .. realmID
	t.class = CLASS_COLON .. classID
	t.Default = DEFAULT
	local db = target.db
	if db and db.raw then
		if db.raw.profiles then
			for k in pairs(db.raw.profiles) do
				if not k:find("^char/") and not k:find("^realm/") and not k:find("^class/") then
					t[k] = k
				end
			end
		end
		if db.raw.namespaces then
			for _,n in pairs(db.raw.namespaces) do
				if n.profiles then
					for k in pairs(n.profiles) do
						if not k:find("^char/") and not k:find("^realm/") and not k:find("^class/") then
							t[k] = k
						end
					end
				end
			end
		end
		local curr = db.raw.currentProfile and db.raw.currentProfile[charID]
		if curr and not t[curr] then
			t[curr] = curr
		end
	end
	if t.Alternative then
		t.Alternative = ALTERNATIVE
	end
end

local CrawlForSerialization
local CrawlForDeserialization

local function SerializeObject(o)
	local t = { o:Serialize() }
	CrawlForSerialization(t)
	t[0] = o.class:GetLibraryVersion()
	return t
end

local function DeserializeObject(t)
	CrawlForDeserialization(t)
	local className = t[0]
	t[0] = nil
	return AceLibrary(className):Deserialize(unpack(t))
end

local function IsSerializable(t)
	return AceOO.inherits(t, AceOO.Class) and t.class and type(t.class.Deserialize) == "function" and type(t.Serialize) == "function" and type(t.class.GetLibraryVersion) == "function"
end

function CrawlForSerialization(t)
	local tmp = new()
	for k,v in pairs(t) do
		tmp[k] = v
	end
	for k,v in pairs(tmp) do
		if type(v) == "table" and type(rawget(v, 0)) ~= "userdata" then
			if IsSerializable(v) then
				v = SerializeObject(v)
				t[k] = v
			else
				CrawlForSerialization(v)
			end
		end
		if type(k) == "table" and type(rawget(k, 0)) ~= "userdata" then
			if IsSerializable(k) then
				t[k] = nil
				t[SerializeObject(k)] = v
			else
				CrawlForSerialization(k)
			end
		end
		tmp[k] = nil
		k = nil
	end
	tmp = del(tmp)
end

local function IsDeserializable(t)
	return type(rawget(t, 0)) == "string" and AceLibrary:HasInstance(rawget(t, 0))
end

function CrawlForDeserialization(t)
	local tmp = new()
	for k,v in pairs(t) do
		tmp[k] = v
	end
	for k,v in pairs(tmp) do
		if type(v) == "table" then
			if IsDeserializable(v) then
				t[k] = DeserializeObject(v)
				del(v)
				v = t[k]
			elseif type(rawget(v, 0)) ~= "userdata" then
				CrawlForDeserialization(v)
			end
		end
		if type(k) == "table" then
			if IsDeserializable(k) then
				t[k] = nil
				t[DeserializeObject(k)] = v
				del(k)
			elseif type(rawget(k, 0)) ~= "userdata" then
				CrawlForDeserialization(k)
			end
		end
		tmp[k] = nil
		k = nil
	end
	tmp = del(tmp)
end

local namespace_mt = { __index = function(namespace, key)
	local db = namespace.db
	local name = namespace.name
	if key == "char" then
		if db.charName then
			if type(_G[db.charName]) ~= "table" then
				_G[db.charName] = {}
			end
			if type(_G[db.charName].namespaces) ~= "table" then
				_G[db.charName].namespaces = {}
			end
			if type(_G[db.charName].namespaces[name]) ~= "table" then
				_G[db.charName].namespaces[name] = {}
			end
			rawset(namespace, 'char', _G[db.charName].namespaces[name])
		else
			if type(db.raw.namespaces) ~= "table" then
				db.raw.namespaces = {}
			end
			if type(db.raw.namespaces[name]) ~= "table" then
				db.raw.namespaces[name] = {}
			end
			if type(db.raw.namespaces[name].chars) ~= "table" then
				db.raw.namespaces[name].chars = {}
			end
			local id = charID
			if type(db.raw.namespaces[name].chars[id]) ~= "table" then
				db.raw.namespaces[name].chars[id] = {}
			end
			rawset(namespace, 'char', db.raw.namespaces[name].chars[id])
		end
		if namespace.defaults and namespace.defaults.char then
			inheritDefaults(namespace.char, namespace.defaults.char)
		end
		return namespace.char
	elseif key == "realm" then
		if type(db.raw.namespaces) ~= "table" then
			db.raw.namespaces = {}
		end
		if type(db.raw.namespaces[name]) ~= "table" then
			db.raw.namespaces[name] = {}
		end
		if type(db.raw.namespaces[name].realms) ~= "table" then
			db.raw.namespaces[name].realms = {}
		end
		local id = realmID
		if type(db.raw.namespaces[name].realms[id]) ~= "table" then
			db.raw.namespaces[name].realms[id] = {}
		end
		rawset(namespace, 'realm', db.raw.namespaces[name].realms[id])
		if namespace.defaults and namespace.defaults.realm then
			inheritDefaults(namespace.realm, namespace.defaults.realm)
		end
		return namespace.realm
	elseif key == "server" then
		if type(db.raw.namespaces) ~= "table" then
			db.raw.namespaces = {}
		end
		if type(db.raw.namespaces[name]) ~= "table" then
			db.raw.namespaces[name] = {}
		end
		if type(db.raw.namespaces[name].servers) ~= "table" then
			db.raw.namespaces[name].servers = {}
		end
		local id = server
		if type(db.raw.namespaces[name].servers[id]) ~= "table" then
			db.raw.namespaces[name].servers[id] = {}
		end
		rawset(namespace, 'server', db.raw.namespaces[name].servers[id])
		if namespace.defaults and namespace.defaults.server then
			inheritDefaults(namespace.server, namespace.defaults.server)
		end
		return namespace.server
	elseif key == "account" then
		if type(db.raw.namespaces) ~= "table" then
			db.raw.namespaces = {}
		end
		if type(db.raw.namespaces[name]) ~= "table" then
			db.raw.namespaces[name] = {}
		end
		if type(db.raw.namespaces[name].account) ~= "table" then
			db.raw.namespaces[name].account = {}
		end
		rawset(namespace, 'account', db.raw.namespaces[name].account)
		if namespace.defaults and namespace.defaults.account then
			inheritDefaults(namespace.account, namespace.defaults.account)
		end
		return namespace.account
	elseif key == "faction" then
		if type(db.raw.namespaces) ~= "table" then
			db.raw.namespaces = {}
		end
		if type(db.raw.namespaces[name]) ~= "table" then
			db.raw.namespaces[name] = {}
		end
		if type(db.raw.namespaces[name].factions) ~= "table" then
			db.raw.namespaces[name].factions = {}
		end
		local id = faction
		if type(db.raw.namespaces[name].factions[id]) ~= "table" then
			db.raw.namespaces[name].factions[id] = {}
		end
		rawset(namespace, 'faction', db.raw.namespaces[name].factions[id])
		if namespace.defaults and namespace.defaults.faction then
			inheritDefaults(namespace.faction, namespace.defaults.faction)
		end
		return namespace.faction
	elseif key == "class" then
		if type(db.raw.namespaces) ~= "table" then
			db.raw.namespaces = {}
		end
		if type(db.raw.namespaces[name]) ~= "table" then
			db.raw.namespaces[name] = {}
		end
		if type(db.raw.namespaces[name].classes) ~= "table" then
			db.raw.namespaces[name].classes = {}
		end
		local id = classID
		if type(db.raw.namespaces[name].classes[id]) ~= "table" then
			db.raw.namespaces[name].classes[id] = {}
		end
		rawset(namespace, 'class', db.raw.namespaces[name].classes[id])
		if namespace.defaults and namespace.defaults.class then
			inheritDefaults(namespace.class, namespace.defaults.class)
		end
		return namespace.class
	elseif key == "profile" then
		if type(db.raw.namespaces) ~= "table" then
			db.raw.namespaces = {}
		end
		if type(db.raw.namespaces[name]) ~= "table" then
			db.raw.namespaces[name] = {}
		end
		if type(db.raw.namespaces[name].profiles) ~= "table" then
			db.raw.namespaces[name].profiles = setmetatable({}, caseInsensitive_mt)
		else
			setmetatable(db.raw.namespaces[name].profiles, caseInsensitive_mt)
		end
		local id = db.raw.currentProfile[charID]
		if id == "char" then
			id = "char/" .. charID
		elseif id == "class" then
			id = "class/" .. classID
		elseif id == "realm" then
			id = "realm/" .. realmID
		end
		if type(db.raw.namespaces[name].profiles[id]) ~= "table" then
			db.raw.namespaces[name].profiles[id] = {}
		end
		rawset(namespace, 'profile', db.raw.namespaces[name].profiles[id])
		if namespace.defaults and namespace.defaults.profile then
			inheritDefaults(namespace.profile, namespace.defaults.profile)
		end
		return namespace.profile
	elseif key == "defaults" or key == "name" or key == "db" then
		return nil
	end
	error(("Cannot access key %q in db table. You may want to use db.profile[%q]"):format(tostring(key), tostring(key)), 2)
end, __newindex = function(db, key, value)
	error(("Cannot access key %q in db table. You may want to use db.profile[%q]"):format(tostring(key), tostring(key)), 2)
end }

local tmp = {}
function AceDB:InitializeDB(addonName)
	local db = self.db

	if not db then
		if addonName then
			AceDB.addonsLoaded[addonName] = true
		end
		return
	end

	if db.raw then
		-- someone manually initialized
		return
	end

	if type(_G[db.name]) ~= "table" then
		_G[db.name] = {}
	else
		CrawlForDeserialization(_G[db.name])
	end
	if db.charName then
		if type(_G[db.charName]) ~= "table" then
			_G[db.charName] = {}
		else
			CrawlForDeserialization(_G[db.charName])
		end
	end
	rawset(db, 'raw', _G[db.name])
	if not db.raw.currentProfile then
		db.raw.currentProfile = {}
	else
		for k,v in pairs(db.raw.currentProfile) do
			tmp[convertFromOldCharID(k)] = v
			db.raw.currentProfile[k] = nil
		end
		for k,v in pairs(tmp) do
			db.raw.currentProfile[k] = v
			tmp[k] = nil
		end
	end
	if not db.raw.currentProfile[charID] then
		db.raw.currentProfile[charID] = AceDB.registry[self] or "Default"
	end
	if db.raw.profiles then
		for k,v in pairs(db.raw.profiles) do
			local new_k = k
			if k:find("^char/") then
				new_k = "char/" .. convertFromOldCharID(k:sub(6))
			end
			tmp[new_k] = v
			db.raw.profiles[k] = nil
		end
		for k,v in pairs(tmp) do
			db.raw.profiles[k] = v
			tmp[k] = nil
		end
	end
	if db.raw.disabledModules then -- AceModuleCore-2.0
		for k,v in pairs(db.raw.disabledModules) do
			local new_k = k
			if k:find("^char/") then
				new_k = "char/" .. convertFromOldCharID(k:sub(6))
			end
			tmp[new_k] = v
			db.raw.disabledModules[k] = nil
		end
		for k,v in pairs(tmp) do
			db.raw.disabledModules[k] = v
			tmp[k] = nil
		end
	end
	if db.raw.chars then
		for k,v in pairs(db.raw.chars) do
			tmp[convertFromOldCharID(k)] = v
			db.raw.chars[k] = nil
		end
		for k,v in pairs(tmp) do
			db.raw.chars[k] = v
			tmp[k] = nil
		end
	end
	if db.raw.namespaces then
		for l,u in pairs(db.raw.namespaces) do
			if u.chars then
				for k,v in pairs(u.chars) do
					tmp[convertFromOldCharID(k)] = v
					u.chars[k] = nil
				end
				for k,v in pairs(tmp) do
					u.chars[k] = v
					tmp[k] = nil
				end
			end
		end
	end
	if db.raw.disabled then
		setmetatable(db.raw.disabled, caseInsensitive_mt)
	end
	if self['acedb-profile-copylist'] then
		RecalculateAceDBCopyFromList(self)
	end
	if self['acedb-profile-list'] then
		RecalculateAceDBProfileList(self)
	end
	setmetatable(db, db_mt)
end

function AceDB:OnEmbedInitialize(target, name)
	if name then
		self:ADDON_LOADED(name)
	end
	self.InitializeDB(target, name)
end

function AceDB:RegisterDB(name, charName, defaultProfile)
	AceDB:argCheck(name, 2, "string")
	AceDB:argCheck(charName, 3, "string", "nil")
	AceDB:argCheck(defaultProfile, 4, "string", "nil")
	if self.db then
		AceDB:error("Cannot call \"RegisterDB\" if self.db is set.")
	end
	local stack = debugstack()
	local addonName = stack:gsub(".-\n.-\\AddOns\\(.-)\\.*", "%1")
	self.db = {
		name = name,
		charName = charName
	}
	AceDB.registry[self] = defaultProfile or "Default"
	if AceDB.addonsLoaded[addonName] then
		AceDB.InitializeDB(self, addonName)
	else
		AceDB.addonsToBeInitialized[self] = addonName
	end
end

function AceDB:RegisterDefaults(kind, defaults, a3)
	local name
	if a3 then
		name, kind, defaults = kind, defaults, a3
		AceDB:argCheck(name, 2, "string")
		AceDB:argCheck(kind, 3, "string")
		AceDB:argCheck(defaults, 4, "table")
	else
		AceDB:argCheck(kind, 2, "string")
		AceDB:argCheck(defaults, 3, "table")
	end
	if kind ~= "char" and kind ~= "class" and kind ~= "profile" and kind ~= "account" and kind ~= "realm" and kind ~= "faction" and kind ~= "server" then
		AceDB:error("Bad argument #%d to `RegisterDefaults' (\"char\", \"class\", \"profile\", \"account\", \"realm\", \"server\", or \"faction\" expected, got %q)", a3 and 3 or 2, kind)
	end
	if type(self.db) ~= "table" or type(self.db.name) ~= "string" then
		AceDB:error("Cannot call \"RegisterDefaults\" unless \"RegisterDB\" has been previously called.")
	end
	local db
	if name then
		local namespace = self:AcquireDBNamespace(name)
		if namespace.defaults and namespace.defaults[kind] then
			AceDB:error("\"RegisterDefaults\" has already been called for %q::%q.", name, kind)
		end
		db = namespace
	else
		if self.db.defaults and self.db.defaults[kind] then
			AceDB:error("\"RegisterDefaults\" has already been called for %q.", kind)
		end
		db = self.db
	end
	if not db.defaults then
		rawset(db, 'defaults', {})
	end
	db.defaults[kind] = defaults
	if rawget(db, kind) then
		inheritDefaults(db[kind], defaults)
	end
end

function AceDB:ResetDB(kind, a2)
	local name
	if a2 then
		name, kind = kind, a2
		AceDB:argCheck(name, 2, "nil", "string")
		AceDB:argCheck(kind, 3, "nil", "string")
	else
		AceDB:argCheck(kind, 2, "nil", "string")
		if kind ~= "char" and kind ~= "class" and kind ~= "profile" and kind ~= "account" and kind ~= "realm" and kind ~= "faction" and kind ~= "server" then
			name, kind = kind, nil
		end
	end
	if not self.db or not self.db.raw then
		AceDB:error("Cannot call \"ResetDB\" before \"RegisterDB\" has been called and before \"ADDON_LOADED\" has been fired.")
	end
	local db = self.db
	if not kind then
		if not name then
			if db.charName then
				_G[db.charName] = nil
			end
			_G[db.name] = nil
			rawset(db, 'raw', nil)
			AceDB.InitializeDB(self)
			if db.namespaces then
				for name,v in pairs(db.namespaces) do
					rawset(v, 'account', nil)
					rawset(v, 'char', nil)
					rawset(v, 'class', nil)
					rawset(v, 'profile', nil)
					rawset(v, 'realm', nil)
					rawset(v, 'server', nil)
					rawset(v, 'faction', nil)
				end
			end
		else
			if db.raw.namespaces then
				db.raw.namespaces[name] = nil
			end
			if db.namespaces then
				local v = db.namespaces[name]
				if v then
					rawset(v, 'account', nil)
					rawset(v, 'char', nil)
					rawset(v, 'class', nil)
					rawset(v, 'profile', nil)
					rawset(v, 'realm', nil)
					rawset(v, 'server', nil)
					rawset(v, 'faction', nil)
				end
			end
		end
	elseif kind == "account" then
		if name then
			db.raw.account = nil
			rawset(db, 'account', nil)
			if db.raw.namespaces then
				for name,v in pairs(db.raw.namespaces) do
					v.account = nil
				end
			end
			if db.namespaces then
				for name,v in pairs(db.namespaces) do
					rawset(v, 'account', nil)
				end
			end
		else
			if db.raw.namespaces and db.raw.namespaces[name] then
				db.raw.namespaces[name].account = nil
			end
			if db.namespaces then
				local v = db.namespaces[name]
				if v then
					rawset(v, 'account', nil)
				end
			end
		end
	elseif kind == "char" then
		if name then
			if db.charName then
				_G[db.charName] = nil
			else
				if db.raw.chars then
					db.raw.chars[charID] = nil
				end
				if db.raw.namespaces then
					for name,v in pairs(db.raw.namespaces) do
						if v.chars then
							v.chars[charID] = nil
						end
					end
				end
			end
			rawset(db, 'char', nil)
			if db.namespaces then
				for name,v in pairs(db.namespaces) do
					rawset(v, 'char', nil)
				end
			end
		else
			if db.charName then
				local x = _G[db.charName]
				if x.namespaces then
					x.namespaces[name] = nil
				end
			else
				if db.raw.namespaces then
					local v = db.namespaces[name]
					if v and v.chars then
						v.chars[charID] = nil
					end
				end
			end
			if db.namespaces then
				local v = db.namespaces[name]
				if v then
					rawset(v, 'char', nil)
				end
			end
		end
	elseif kind == "realm" then
		if not name then
			if db.raw.realms then
				db.raw.realms[realmID] = nil
			end
			rawset(db, 'realm', nil)
			if db.raw.namespaces then
				for name,v in pairs(db.raw.namespaces) do
					if v.realms then
						v.realms[realmID] = nil
					end
				end
			end
			if db.namespaces then
				for name,v in pairs(db.namespaces) do
					rawset(v, 'realm', nil)
				end
			end
		else
			if db.raw.namespaces then
				local v = db.raw.namespaces[name]
				if v and v.realms then
					v.realms[realmID] = nil
				end
			end
			if db.namespaces then
				local v = db.namespaces[name]
				if v then
					rawset(v, 'realm', nil)
				end
			end
		end
	elseif kind == "server" then
		if not name then
			if db.raw.servers then
				db.raw.servers[server] = nil
			end
			rawset(db, 'server', nil)
			if db.raw.namespaces then
				for name,v in pairs(db.raw.namespaces) do
					if v.servers then
						v.servers[server] = nil
					end
				end
			end
			if db.namespaces then
				for name,v in pairs(db.namespaces) do
					rawset(v, 'server', nil)
				end
			end
		else
			if db.raw.namespaces then
				local v = db.raw.namespaces[name]
				if v and v.servers then
					v.servers[server] = nil
				end
			end
			if db.namespaces then
				local v = db.namespaces[name]
				if v then
					rawset(v, 'server', nil)
				end
			end
		end
	elseif kind == "faction" then
		if not name then
			if db.raw.factions then
				db.raw.factions[faction] = nil
			end
			rawset(db, 'faction', nil)
			if db.raw.namespaces then
				for name,v in pairs(db.raw.namespaces) do
					if v.factions then
						v.factions[faction] = nil
					end
				end
			end
			if db.namespaces then
				for name,v in pairs(db.namespaces) do
					rawset(v, 'faction', nil)
				end
			end
		else
			if db.raw.namespaces then
				local v = db.raw.namespaces[name]
				if v and v.factions then
					v.factions[faction] = nil
				end
			end
			if db.namespaces then
				local v = db.namespaces[name]
				if v then
					rawset(v, 'faction', nil)
				end
			end
		end
	elseif kind == "class" then
		if not name then
			if db.raw.realms then
				db.raw.realms[classID] = nil
			end
			rawset(db, 'class', nil)
			if db.raw.namespaces then
				for name,v in pairs(db.raw.namespaces) do
					if v.classes then
						v.classes[classID] = nil
					end
				end
			end
			if db.namespaces then
				for name,v in pairs(db.namespaces) do
					rawset(v, 'class', nil)
				end
			end
		else
			if db.raw.namespaces then
				local v = db.raw.namespaces[name]
				if v and v.classes then
					v.classes[classID] = nil
				end
			end
			if db.namespaces then
				local v = db.namespaces[name]
				if v then
					rawset(v, 'class', nil)
				end
			end
		end
	elseif kind == "profile" then
		local id = db.raw.currentProfile and db.raw.currentProfile[charID] or AceDB.registry[self] or "Default"
		if id == "char" then
			id = "char/" .. charID
		elseif id == "class" then
			id = "class/" .. classID
		elseif id == "realm" then
			id = "realm/" .. realmID
		end

		local current = self.class
		while current and current ~= AceOO.Class do
			if current.mixins then
				for mixin in pairs(current.mixins) do
					if type(mixin.OnEmbedProfileDisable) == "function" then
						safecall(mixin.OnEmbedProfileDisable, mixin, self, id)
					end
				end
			end
			current = current.super
		end
		if type(self.OnProfileDisable) == "function" then
			safecall(self.OnProfileDisable, self, id)
		end
		local active = self:IsActive()

		if not name then
			if db.raw.profiles then
				db.raw.profiles[id] = nil
			end
			rawset(db, 'profile', nil)
			if db.raw.namespaces then
				for name,v in pairs(db.raw.namespaces) do
					if v.profiles then
						v.profiles[id] = nil
					end
				end
			end
			if db.namespaces then
				for name,v in pairs(db.namespaces) do
					rawset(v, 'profile', nil)
				end
			end
		else
			if db.raw.namespaces then
				local v = db.raw.namespaces[name]
				if v and v.profiles then
					v.profiles[id] = nil
				end
			end
			if db.namespaces then
				local v = db.namespaces[name]
				if v then
					rawset(v, 'profile', nil)
				end
			end
		end

		local current = self.class
		while current and current ~= AceOO.Class do
			if current.mixins then
				for mixin in pairs(current.mixins) do
					if type(mixin.OnEmbedProfileEnable) == "function" then
						safecall(mixin.OnEmbedProfileEnable, mixin, self, id)
					end
				end
			end
			current = current.super
		end
		if type(self.OnProfileEnable) == "function" then
			safecall(self.OnProfileEnable, self, id)
		end
		local newactive = self:IsActive()
		if active ~= newactive then
			if newactive then
				local first = nil
				if AceOO.inherits(self, "AceAddon-2.0") then
					local AceAddon = AceLibrary("AceAddon-2.0")
					if not AceAddon.addonsStarted[self] then
						return
					end
					if AceAddon.addonsEnabled and not AceAddon.addonsEnabled[self] then
						AceAddon.addonsEnabled[self] = true
						first = true
					end
				end
				local current = self.class
				while current and current ~= AceOO.Class do
					if current.mixins then
						for mixin in pairs(current.mixins) do
							if type(mixin.OnEmbedEnable) == "function" then
								safecall(mixin.OnEmbedEnable, mixin, self, first)
							end
						end
					end
					current = current.super
				end
				if type(self.OnEnable) == "function" then
					safecall(self.OnEnable, self, first)
				end
				if AceEvent then
					AceEvent:TriggerEvent("Ace2_AddonEnabled", self, first)
				end
			else
				local current = self.class
				while current and current ~= AceOO.Class do
					if current.mixins then
						for mixin in pairs(current.mixins) do
							if type(mixin.OnEmbedDisable) == "function" then
								safecall(mixin.OnEmbedDisable, mixin, self)
							end
						end
					end
					current = current.super
				end
				if type(self.OnDisable) == "function" then
					safecall(self.OnDisable, self)
				end
				if AceEvent then
					AceEvent:TriggerEvent("Ace2_AddonDisabled", self)
				end
			end
		end
	else
		return -- skip event
	end
	if AceEvent then
		AceEvent:TriggerEvent("AceDB20_ResetDB", self, self.db.name, kind)
	end
end

local function cleanDefaults(t, defaults, blocker)
	if defaults then
		for k,v in pairs(t) do
			if (not blocker or (blocker[k] == nil and blocker['*'] == nil and blocker['**'] == nil)) and (defaults[k] ~= nil or defaults['*'] ~= nil or defaults['**'] ~= nil) then
				local u = defaults[k]
				if u == nil then
					u = defaults['*']
					if u == nil then
						u = defaults['**']
					end
				end
				if v == u then
					t[k] = nil
				elseif type(v) == "table" and type(u) == "table" then
					if cleanDefaults(v, u) then
						t[k] = nil
					else
						local w = defaults['**']
						if w ~= u then
							if cleanDefaults(v, w, u) then
								t[k] = nil
							end
						end
					end
				end
			end
		end
	end
	return t and next(t) == nil
end

function AceDB:GetProfile()
	if not self.db or not self.db.raw then
		return nil
	end
	if not self.db.raw.currentProfile then
		self.db.raw.currentProfile = {}
	end
	if not self.db.raw.currentProfile[charID] then
		self.db.raw.currentProfile[charID] = AceDB.registry[self] or "Default"
	end
	local profile = self.db.raw.currentProfile[charID]
	if profile == "char" then
		return "char", "char/" .. charID
	elseif profile == "class" then
		return "class", "class/" .. classID
	elseif profile == "realm" then
		return "realm", "realm/" .. realmID
	end
	return profile, profile
end

local function copyTable(to, from)
	setmetatable(to, nil)
	for k,v in pairs(from) do
		if type(k) == "table" then
			k = copyTable({}, k)
		end
		if type(v) == "table" then
			v = copyTable({}, v)
		end
		to[k] = v
	end
	setmetatable(to, from)
	return to
end

function AceDB:SetProfile(name)
	AceDB:argCheck(name, 2, "string")
	if not self.db or not self.db.raw then
		AceDB:error("Cannot call \"SetProfile\" before \"RegisterDB\" has been called and before \"ADDON_LOADED\" has been fired.")
	end
	local db = self.db
	local lowerName = name:lower()
	if lowerName:find("^char/") or lowerName:find("^realm/") or lowerName:find("^class/") then
		if lowerName:find("^char/") then
			name = "char"
		else
			name = lowerName:sub(1, 5)
		end
		lowerName = name:lower()
	end
	local oldName = db.raw.currentProfile[charID]
	if oldName:lower() == name:lower() then
		return
	end
	local oldProfileData = db.profile
	local realName = name
	if lowerName == "char" then
		realName = name .. "/" .. charID
	elseif lowerName == "realm" then
		realName = name .. "/" .. realmID
	elseif lowerName == "class" then
		realName = name .. "/" .. classID
	end
	local current = self.class
	while current and current ~= AceOO.Class do
		if current.mixins then
			for mixin in pairs(current.mixins) do
				if type(mixin.OnEmbedProfileDisable) == "function" then
					safecall(mixin.OnEmbedProfileDisable, mixin, self, realName)
				end
			end
		end
		current = current.super
	end
	if type(self.OnProfileDisable) == "function" then
		safecall(self.OnProfileDisable, self, realName)
	end
	local active = self:IsActive()
	db.raw.currentProfile[charID] = name
	rawset(db, 'profile', nil)
	if db.namespaces then
		for k,v in pairs(db.namespaces) do
			rawset(v, 'profile', nil)
		end
	end
	local current = self.class
	while current and current ~= AceOO.Class do
		if current.mixins then
			for mixin in pairs(current.mixins) do
				if type(mixin.OnEmbedProfileEnable) == "function" then
					safecall(mixin.OnEmbedProfileEnable, mixin, self, oldName, oldProfileData)
				end
			end
		end
		current = current.super
	end
	if type(self.OnProfileEnable) == "function" then
		safecall(self.OnProfileEnable, self, oldName, oldProfileData)
	end
	if cleanDefaults(oldProfileData, db.defaults and db.defaults.profile) then
		db.raw.profiles[oldName] = nil
		if not next(db.raw.profiles) then
			db.raw.profiles = nil
		end
	end
	local newactive = self:IsActive()
	if active ~= newactive then
		local first = nil
		if AceOO.inherits(self, "AceAddon-2.0") then
			local AceAddon = AceLibrary("AceAddon-2.0")
			if not AceAddon.addonsStarted[self] then
				return
			end
			if AceAddon.addonsEnabled and not AceAddon.addonsEnabled[self] then
				first = true
			end
		end
		if newactive then
			local current = self.class
			while current and current ~= AceOO.Class do
				if current.mixins then
					for mixin in pairs(current.mixins) do
						if type(mixin.OnEmbedEnable) == "function" then
							safecall(mixin.OnEmbedEnable, mixin, self, first)
						end
					end
				end
				current = current.super
			end
			if type(self.OnEnable) == "function" then
				safecall(self.OnEnable, self, first)
			end
			if AceEvent then
				AceEvent:TriggerEvent("Ace2_AddonEnabled", self, first)
			end
		else
			local current = self.class
			while current and current ~= AceOO.Class do
				if current.mixins then
					for mixin in pairs(current.mixins) do
						if type(mixin.OnEmbedDisable) == "function" then
							safecall(mixin.OnEmbedDisable, mixin, self)
						end
					end
				end
				current = current.super
			end
			if type(self.OnDisable) == "function" then
				safecall(self.OnDisable, self)
			end
			if AceEvent then
				AceEvent:TriggerEvent("Ace2_AddonDisabled", self)
			end
		end
	end
	if self['acedb-profile-list'] then
		RecalculateAceDBProfileList(self)
	end
	if self['acedb-profile-copylist'] then
		RecalculateAceDBCopyFromList(self)
	end
	if Dewdrop then
		Dewdrop:Refresh()
	end
end

function AceDB:CopyProfileFrom(copyFrom)
	AceDB:argCheck(copyFrom, 2, "string")
	if not self.db or not self.db.raw then
		AceDB:error("Cannot call \"CopyProfileFrom\" before \"RegisterDB\" has been called and before \"ADDON_LOADED\" has been fired.")
	end
	local db = self.db
	local lowerCopyFrom = copyFrom:lower()
	if not db.raw.profiles or not db.raw.profiles[copyFrom] then
		local good = false
		if db.raw.namespaces then
			for _,n in pairs(db.raw.namespaces) do
				if n.profiles and n.profiles[copyFrom] then
					good = true
					break
				end
			end
		end
		if not good then
			AceDB:error("Cannot copy from profile %q, it does not exist.", copyFrom)
		end
	end
	local currentProfile = db.raw.currentProfile[charID]
	if currentProfile:lower() == lowerCopyFrom then
		AceDB:error("Cannot copy from profile %q, it is currently in use.", copyFrom)
	end
	local oldProfileData = db.profile
	local current = self.class
	while current and current ~= AceOO.Class do
		if current.mixins then
			for mixin in pairs(current.mixins) do
				if type(mixin.OnEmbedProfileDisable) == "function" then
					safecall(mixin.OnEmbedProfileDisable, mixin, self, currentProfile)
				end
			end
		end
		current = current.super
	end
	if type(self.OnProfileDisable) == "function" then
		safecall(self.OnProfileDisable, self, realName)
	end
	local active = self:IsActive()
	for k,v in pairs(db.profile) do
		db.profile[k] = nil
	end
	if db.raw.profiles[copyFrom] then
		copyTable(db.profile, db.raw.profiles[copyFrom])
	end
	inheritDefaults(db.profile, db.defaults and db.defaults.profile)
	if db.namespaces then
		for l,u in pairs(db.namespaces) do
			for k,v in pairs(u.profile) do
				u.profile[k] = nil
			end
			if db.raw.namespaces[l].profiles[copyFrom] then
				copyTable(u.profile, db.raw.namespaces[l].profiles[copyFrom])
			end
			inheritDefaults(u.profile, u.defaults and u.defaults.profile)
		end
	end
	local current = self.class
	while current and current ~= AceOO.Class do
		if current.mixins then
			for mixin in pairs(current.mixins) do
				if type(mixin.OnEmbedProfileEnable) == "function" then
					safecall(mixin.OnEmbedProfileEnable, mixin, self, copyFrom, oldProfileData, copyFrom)
				end
			end
		end
		current = current.super
	end
	if type(self.OnProfileEnable) == "function" then
		safecall(self.OnProfileEnable, self, copyFrom, oldProfileData, copyFrom)
	end
	local newactive = self:IsActive()
	if active ~= newactive then
		if AceOO.inherits(self, "AceAddon-2.0") then
			local AceAddon = AceLibrary("AceAddon-2.0")
			if not AceAddon.addonsStarted[self] then
				return
			end
		end
		if newactive then
			local current = self.class
			while current and current ~= AceOO.Class do
				if current.mixins then
					for mixin in pairs(current.mixins) do
						if type(mixin.OnEmbedEnable) == "function" then
							safecall(mixin.OnEmbedEnable, mixin, self)
						end
					end
				end
				current = current.super
			end
			if type(self.OnEnable) == "function" then
				safecall(self.OnEnable, self)
			end
			if AceEvent then
				AceEvent:TriggerEvent("Ace2_AddonEnabled", self)
			end
		else
			local current = self.class
			while current and current ~= AceOO.Class do
				if current.mixins then
					for mixin in pairs(current.mixins) do
						if type(mixin.OnEmbedDisable) == "function" then
							safecall(mixin.OnEmbedDisable, mixin, self)
						end
					end
				end
				current = current.super
			end
			if type(self.OnDisable) == "function" then
				safecall(self.OnDisable, self)
			end
			if AceEvent then
				AceEvent:TriggerEvent("Ace2_AddonDisabled", self)
			end
		end
	end
	if self['acedb-profile-list'] then
		RecalculateAceDBProfileList(self)
	end
	if self['acedb-profile-copylist'] then
		RecalculateAceDBCopyFromList(self)
	end
	if Dewdrop then
		Dewdrop:Refresh()
	end
end

function AceDB:DeleteProfile(profile, noconfirm)
	AceDB:argCheck(profile , 2, "string")
	if not self.db or not self.db.raw then
		AceDB:error("Cannot call \"DeleteProfile\" before \"RegisterDB\" has been called and before \"ADDON_LOADED\" has been fired.")
	end
	local db = self.db

	local currentProfile = db.raw.currentProfile[charID]
	if currentProfile:lower() == profile:lower() then
		AceDB:error("Cannot delete profile %q, it is currently in use.", profile)
	end

	if not (noconfirm or IsShiftKeyDown()) then
		if not StaticPopupDialogs["ACEDB20_CONFIRM_DELETE_DIALOG"] then
			StaticPopupDialogs["ACEDB20_CONFIRM_DELETE_DIALOG"] = {}
		end
		local t = StaticPopupDialogs["ACEDB20_CONFIRM_DELETE_DIALOG"]
		t.text = format("%s: %s?", DELETE_PROFILE, profile)
		t.button1 = DELETE_PROFILE
		t.button2 = CANCEL or "Cancel"
		t.OnAccept = function()
			self:DeleteProfile(profile, true)
		end
		t.timeout = 0
		t.whileDead = 1
		t.hideOnEscape = 1

		StaticPopup_Show("ACEDB20_CONFIRM_DELETE_DIALOG")
		return;
	end

	local good = false
	if db.raw.profiles and db.raw.profiles[profile] then
		good = true;
		db.raw.profiles[profile] = nil;
	end

	if db.raw.namespaces then
		for _,n in pairs(db.raw.namespaces) do
			if n.profiles and n.profiles[profile] then
				n.profiles[profile] = nil;
				good = true
			end
		end
	end

	if not good then
		AceDB:error("Cannot delete profile %q, it does not exist.", profile)
	end

	if self['acedb-profile-list'] then
		RecalculateAceDBProfileList(self)
	end
	if self['acedb-profile-copylist'] then
		RecalculateAceDBCopyFromList(self)
	end

	if Dewdrop then
		Dewdrop:Refresh()
	end
end

function AceDB:IsActive()
	return not self.db or not self.db.raw or not self.db.raw.disabled or not self.db.raw.disabled[self.db.raw.currentProfile[charID]]
end

function AceDB:ToggleActive(state)
	AceDB:argCheck(state, 2, "boolean", "nil")
	if not self.db or not self.db.raw then
		AceDB:error("Cannot call \"ToggleActive\" before \"RegisterDB\" has been called and before \"ADDON_LOADED\" has been fired.")
	end
	local db = self.db
	if not db.raw.disabled then
		db.raw.disabled = setmetatable({}, caseInsensitive_mt)
	end
	local profile = db.raw.currentProfile[charID]
	local disable
	if state == nil then
		disable = not db.raw.disabled[profile]
	else
		disable = not state
		if disable == db.raw.disabled[profile] then
			return
		end
	end
	db.raw.disabled[profile] = disable or nil
	if AceOO.inherits(self, "AceAddon-2.0") then
		local AceAddon = AceLibrary("AceAddon-2.0")
		if not AceAddon.addonsStarted[self] then
			return
		end
	end
	if not disable then
		local current = self.class
		while current and current ~= AceOO.Class do
			if current.mixins then
				for mixin in pairs(current.mixins) do
					if type(mixin.OnEmbedEnable) == "function" then
						safecall(mixin.OnEmbedEnable, mixin, self)
					end
				end
			end
			current = current.super
		end
		if type(self.OnEnable) == "function" then
			safecall(self.OnEnable, self)
		end
		if AceEvent then
			AceEvent:TriggerEvent("Ace2_AddonEnabled", self)
		end
	else
		local current = self.class
		while current and current ~= AceOO.Class do
			if current.mixins then
				for mixin in pairs(current.mixins) do
					if type(mixin.OnEmbedDisable) == "function" then
						safecall(mixin.OnEmbedDisable, mixin, self)
					end
				end
			end
			current = current.super
		end
		if type(self.OnDisable) == "function" then
			safecall(self.OnDisable, self)
		end
		if AceEvent then
			AceEvent:TriggerEvent("Ace2_AddonDisabled", self)
		end
	end
	return not disable
end

function AceDB:embed(target)
	self.super.embed(self, target)
	if not AceEvent then
		AceDB:error(MAJOR_VERSION .. " requires AceEvent-2.0")
	end
end

function AceDB:ADDON_LOADED(name)
	AceDB.addonsLoaded[name] = true
	for addon, addonName in pairs(AceDB.addonsToBeInitialized) do
		if name == addonName then
			AceDB.InitializeDB(addon, name)
			AceDB.addonsToBeInitialized[addon] = nil
		end
	end
end

function AceDB:PLAYER_LOGOUT()
	for addon, defaultProfile in pairs(AceDB.registry) do
		local db = addon.db
		if db then
			if type(addon.OnDatabaseCleanup) == "function" then
				safecall(addon.OnDatabaseCleanup, addon)
			end
			setmetatable(db, nil)
			CrawlForSerialization(db.raw)
			if type(_G[db.charName]) == "table" then
				CrawlForSerialization(_G[db.charName])
			end
			if db.char and cleanDefaults(db.char, db.defaults and db.defaults.char) then
				if db.charName and _G[db.charName] and _G[db.charName].global == db.char then
					_G[db.charName].global = nil
					if not next(_G[db.charName]) then
						_G[db.charName] = nil
					end
				else
					if db.raw.chars then
						db.raw.chars[charID] = nil
						if not next(db.raw.chars) then
							db.raw.chars = nil
						end
					end
				end
			end
			if db.realm and cleanDefaults(db.realm, db.defaults and db.defaults.realm) then
				if db.raw.realms then
					db.raw.realms[realmID] = nil
					if not next(db.raw.realms) then
						db.raw.realms = nil
					end
				end
			end
			if db.server and cleanDefaults(db.server, db.defaults and db.defaults.server) then
				if db.raw.servers then
					db.raw.servers[server] = nil
					if not next(db.raw.servers) then
						db.raw.servers = nil
					end
				end
			end
			if db.faction and cleanDefaults(db.faction, db.defaults and db.defaults.faction) then
				if db.raw.factions then
					db.raw.factions[faction] = nil
					if not next(db.raw.factions) then
						db.raw.factions = nil
					end
				end
			end
			if db.class and cleanDefaults(db.class, db.defaults and db.defaults.class) then
				if db.raw.classes then
					db.raw.classes[classID] = nil
					if not next(db.raw.classes) then
						db.raw.classes = nil
					end
				end
			end
			if db.account and cleanDefaults(db.account, db.defaults and db.defaults.account) then
				db.raw.account = nil
			end
			if db.profile and cleanDefaults(db.profile, db.defaults and db.defaults.profile) then
				if db.raw.profiles then
					db.raw.profiles[db.raw.currentProfile and db.raw.currentProfile[charID] or defaultProfile or "Default"] = nil
					if not next(db.raw.profiles) then
						db.raw.profiles = nil
					end
				end
			end
			if db.namespaces and db.raw.namespaces then
				for name,v in pairs(db.namespaces) do
					if db.raw.namespaces[name] then
						setmetatable(v, nil)
						if v.char and cleanDefaults(v.char, v.defaults and v.defaults.char) then
							if db.charName and _G[db.charName] and _G[db.charName].namespaces and _G[db.charName].namespaces[name] == v then
								_G[db.charName].namespaces[name] = nil
								if not next(_G[db.charName].namespaces) then
									_G[db.charName].namespaces = nil
									if not next(_G[db.charName]) then
										_G[db.charName] = nil
									end
								end
							else
								if db.raw.namespaces[name].chars then
									db.raw.namespaces[name].chars[charID] = nil
									if not next(db.raw.namespaces[name].chars) then
										db.raw.namespaces[name].chars = nil
									end
								end
							end
						end
						if v.realm and cleanDefaults(v.realm, v.defaults and v.defaults.realm) then
							if db.raw.namespaces[name].realms then
								db.raw.namespaces[name].realms[realmID] = nil
								if not next(db.raw.namespaces[name].realms) then
									db.raw.namespaces[name].realms = nil
								end
							end
						end
						if v.server and cleanDefaults(v.server, v.defaults and v.defaults.server) then
							if db.raw.namespaces[name].servers then
								db.raw.namespaces[name].servers[server] = nil
								if not next(db.raw.namespaces[name].servers) then
									db.raw.namespaces[name].servers = nil
								end
							end
						end
						if v.faction and cleanDefaults(v.faction, v.defaults and v.defaults.faction) then
							if db.raw.namespaces[name].factions then
								db.raw.namespaces[name].factions[faction] = nil
								if not next(db.raw.namespaces[name].factions) then
									db.raw.namespaces[name].factions = nil
								end
							end
						end
						if v.class and cleanDefaults(v.class, v.defaults and v.defaults.class) then
							if db.raw.namespaces[name].classes then
								db.raw.namespaces[name].classes[classID] = nil
								if not next(db.raw.namespaces[name].classes) then
									db.raw.namespaces[name].classes = nil
								end
							end
						end
						if v.account and cleanDefaults(v.account, v.defaults and v.defaults.account) then
							db.raw.namespaces[name].account = nil
						end
						if v.profile and cleanDefaults(v.profile, v.defaults and v.defaults.profile) then
							if db.raw.namespaces[name].profiles then
								db.raw.namespaces[name].profiles[db.raw.currentProfile and db.raw.currentProfile[charID] or defaultProfile or "Default"] = nil
								if not next(db.raw.namespaces[name].profiles) then
									db.raw.namespaces[name].profiles = nil
								end
							end
						end
						if not next(db.raw.namespaces[name]) then
							db.raw.namespaces[name] = nil
						end
					end
				end
				if not next(db.raw.namespaces) then
					db.raw.namespaces = nil
				end
			end
			if db.raw.disabled and not next(db.raw.disabled) then
				db.raw.disabled = nil
			end
			if db.raw.currentProfile then
				for k,v in pairs(db.raw.currentProfile) do
					if v:lower() == (defaultProfile or "Default"):lower() then
						db.raw.currentProfile[k] = nil
					end
				end
				if not next(db.raw.currentProfile) then
					db.raw.currentProfile = nil
				end
			end
			if _G[db.name] and not next(_G[db.name]) then
				_G[db.name] = nil
			end
		end
	end
end

function AceDB:AcquireDBNamespace(name)
	AceDB:argCheck(name, 2, "string")
	local db = self.db
	if not db then
		AceDB:error("Cannot call `AcquireDBNamespace' before `RegisterDB' has been called.", 2)
	end
	if not db.namespaces then
		rawset(db, 'namespaces', {})
	end
	if not db.namespaces[name] then
		local namespace = {}
		db.namespaces[name] = namespace
		namespace.db = db
		namespace.name = name
		setmetatable(namespace, namespace_mt)
	end
	return db.namespaces[name]
end

function AceDB:GetAceOptionsDataTable(target)
	if not target['acedb-profile-list'] then
		target['acedb-profile-list'] = setmetatable({}, caseInsensitive_mt)
		RecalculateAceDBProfileList(target)
	end
	if not target['acedb-profile-copylist'] then
		target['acedb-profile-copylist'] = setmetatable({}, caseInsensitive_mt)
		RecalculateAceDBCopyFromList(target)
	end
	return {
		standby = {
			cmdName = STATE,
			guiName = ENABLED,
			name = ACTIVE,
			desc = TOGGLE_ACTIVE,
			type = "toggle",
			get = "IsActive",
			set = "ToggleActive",
			map = MAP_ACTIVESUSPENDED,
			order = -3,
		},
		profile = {
			type = 'group',
			name = PROFILE,
			desc = SET_PROFILE,
			order = -3.5,
			get = "GetProfile",
			args = {
				choose = {
					guiName = CHOOSE_PROFILE_GUI,
					cmdName = PROFILE,
					desc = CHOOSE_PROFILE_DESC,
					type = 'text',
					get = "GetProfile",
					set = "SetProfile",
					validate = target['acedb-profile-list']
				},
				copy = {
					guiName = COPY_PROFILE_GUI,
					cmdName = PROFILE,
					desc = COPY_PROFILE_DESC,
					type = 'text',
					get = false,
					set = "CopyProfileFrom",
					validate = target['acedb-profile-copylist'],
					disabled = function()
						return not next(target['acedb-profile-copylist'])
					end,
				},
				other = {
					guiName = OTHER_PROFILE_GUI,
					cmdName = PROFILE,
					desc = OTHER_PROFILE_DESC,
					usage = OTHER_PROFILE_USAGE,
					type = 'text',
					get = "GetProfile",
					set = "SetProfile",
				},
				delete = {
					name = DELETE_PROFILE,
					desc = DELETE_PROFILE_DESC,
					usage = DELETE_PROFILE_USAGE,
					type = 'text',
					set = "DeleteProfile",
					get = false,
					validate = target['acedb-profile-copylist'],
					disabled = function()
						return not next(target['acedb-profile-copylist'])
					end,
				},
				reset = {
					name = RESET_PROFILE,
					desc = RESET_PROFILE_DESC,
					type = 'execute',
					func = function()
						target:ResetDB('profile')
					end,
					confirm = true,
				}
			}
		},
	}
end

local function activate(self, oldLib, oldDeactivate)
	AceDB = self
	AceEvent = AceLibrary:HasInstance("AceEvent-2.0") and AceLibrary("AceEvent-2.0")

	self.addonsToBeInitialized = oldLib and oldLib.addonsToBeInitialized or {}
	self.addonsLoaded = oldLib and oldLib.addonsLoaded or {}
	self.registry = oldLib and oldLib.registry or {}
	for k, v in pairs(self.registry) do
		if v == true then
			self.registry[k] = "Default"
		end
	end

	self:activate(oldLib, oldDeactivate)

	for t in pairs(self.embedList) do
		if t.db then
			rawset(t.db, 'char', nil)
			rawset(t.db, 'realm', nil)
			rawset(t.db, 'class', nil)
			rawset(t.db, 'account', nil)
			rawset(t.db, 'server', nil)
			rawset(t.db, 'faction', nil)
			rawset(t.db, 'profile', nil)
			setmetatable(t.db, db_mt)
		end
	end

	if oldLib then
		oldDeactivate(oldLib)
	end
end

local function external(self, major, instance)
	if major == "AceEvent-2.0" then
		AceEvent = instance

		AceEvent:embed(self)

		self:RegisterEvent("ADDON_LOADED")
		self:RegisterEvent("PLAYER_LOGOUT")
	elseif major == "Dewdrop-2.0" then
		Dewdrop = instance
	end
end

AceLibrary:Register(AceDB, MAJOR_VERSION, MINOR_VERSION, activate, nil, external)
AceDB = AceLibrary(MAJOR_VERSION)
