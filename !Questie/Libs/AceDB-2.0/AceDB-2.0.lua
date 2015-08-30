--[[
Name: AceDB-2.0
Revision: $Rev: 15896 $
Developed by: The Ace Development Team (http://www.wowace.com/index.php/The_Ace_Development_Team)
Inspired By: Ace 1.x by Turan (turan@gryphon.com)
Website: http://www.wowace.com/
Documentation: http://www.wowace.com/index.php/AceDB-2.0
SVN: http://svn.wowace.com/root/trunk/Ace2/AceDB-2.0
Description: Mixin to allow for fast, clean, and featureful saved variable
             access.
Dependencies: AceLibrary, AceOO-2.0, AceEvent-2.0
]]

local MAJOR_VERSION = "AceDB-2.0"
local MINOR_VERSION = "$Revision: 15896 $"

if not AceLibrary then error(MAJOR_VERSION .. " requires AceLibrary") end
if not AceLibrary:IsNewVersion(MAJOR_VERSION, MINOR_VERSION) then return end

if not AceLibrary:HasInstance("AceOO-2.0") then error(MAJOR_VERSION .. " requires AceOO-2.0") end

local ACTIVE, ENABLED, STATE, TOGGLE_ACTIVE, MAP_ACTIVESUSPENDED, SET_PROFILE, SET_PROFILE_USAGE, PROFILE, PLAYER_OF_REALM, CHOOSE_PROFILE_DESC, CHOOSE_PROFILE_GUI, COPY_PROFILE_DESC, COPY_PROFILE_GUI, OTHER_PROFILE_DESC, OTHER_PROFILE_GUI, OTHER_PROFILE_USAGE, CHARACTER, REALM, CLASS

if GetLocale() == "deDE" then
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

	CHARACTER = "Charakter: "
	REALM = "Realm: "
	CLASS = "Klasse: "
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

	CHARACTER = "Personnage: "
	REALM = "Royaume: "
	CLASS = "Classe: "
elseif GetLocale() == "koKR" then
	ACTIVE = "활성화"
	ENABLED = "활성화"
	STATE = "상태"
	TOGGLE_ACTIVE = "이 애드온 중지/계속 실행"
	MAP_ACTIVESUSPENDED = { [true] = "|cff00ff00활성화|r", [false] = "|cffff0000중지됨|r" }
	SET_PROFILE = "이 애드온에 프로필 설정"
	SET_PROFILE_USAGE = "{캐릭터명 || 직업 || 서버명 || <프로필명>}"
	PROFILE = "프로필"
	PLAYER_OF_REALM = "%s (%s 서버)"
	CHOOSE_PROFILE_DESC = "프로파일을 선택합니다."
	CHOOSE_PROFILE_GUI = "선택"
	COPY_PROFILE_DESC = "다른 프로파일에서 설정을 복사합니다."
	COPY_PROFILE_GUI = "복사"
	OTHER_PROFILE_DESC = "다른 프로파일을 선택합니다."
	OTHER_PROFILE_GUI = "기타"
	OTHER_PROFILE_USAGE = "<프로파일명>"

	CHARACTER = "캐릭터: "
	REALM = "서버: "
	CLASS = "직업: "
elseif GetLocale() == "zhTW" then
	ACTIVE = "啟動"
	ENABLED = "啟用"
	STATE = "狀態"
	TOGGLE_ACTIVE = "暫停/重啟這個插件。"
	MAP_ACTIVESUSPENDED = { [true] = "|cff00ff00啟動|r", [false] = "|cffff0000已暫停|r" }
	SET_PROFILE = "設定這插件的記錄檔。"
	SET_PROFILE_USAGE = "{角色 || 聯業 || 伺服器 || <記錄檔名稱>}"
	PROFILE = "記錄檔"
	PLAYER_OF_REALM = "%s 於 %s"
	CHOOSE_PROFILE_DESC = "選擇一個記錄檔"
	CHOOSE_PROFILE_GUI = "選擇"
	COPY_PROFILE_DESC = "由其他記錄檔複製設定。"
	COPY_PROFILE_GUI = "複製由"
	OTHER_PROFILE_DESC = "選擇其他記錄檔。"
	OTHER_PROFILE_GUI = "其他"
	OTHER_PROFILE_USAGE = "<記錄檔名稱>"

	CHARACTER = "角色："
	REALM = "伺服器："
	CLASS = "聯業："
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

	CHARACTER = "\229\173\151\231\172\166: "
	REALM = "\229\159\159: "
	CLASS = "\233\128\137\228\187\182\231\177\187: "
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

	CHARACTER = "Character: "
	REALM = "Realm: "
	CLASS = "Class: "
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
						"ToggleActive",
						"IsActive",
						"AcquireDBNamespace",
					}
local Dewdrop = AceLibrary:HasInstance("Dewdrop-2.0") and AceLibrary("Dewdrop-2.0")

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

local function inheritDefaults(t, defaults)
	if not defaults then
		return t
	end
	for k,v in pairs(defaults) do
		if k == "*" then
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
				if (defaults[key] == nil or key == "*") and type(t[key]) == "table" then
					inheritDefaults(t[key], v)
				end
			end
		else
			if type(v) == "table" then
				if type(t[k]) ~= "table" then
					t[k] = {}
				end
				inheritDefaults(t[k], v)
			elseif t[k] == nil then
				t[k] = v
			end
		end
	end
	return t
end

local _,race = UnitRace("player")
local faction
if race == "Orc" or race == "Scourge" or race == "Troll" or race == "Tauren" then
	faction = FACTION_HORDE
else
	faction = FACTION_ALLIANCE
end
local charID = string.format(PLAYER_OF_REALM, UnitName("player"), (string.gsub(GetRealmName(), "^%s*(.-)%s*$", "%1")))
local realm = string.gsub(GetRealmName(), "^%s*(.-)%s*$", "%1")
local realmID = realm .. " - " .. faction
local classID = UnitClass("player")

AceDB.CHAR_ID = charID
AceDB.REALM_ID = realmID
AceDB.CLASS_ID = classID

AceDB.FACTION = faction
AceDB.REALM = realm
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
		table_setn(t, 0)
		list[t] = true
	end
end

local caseInsensitive_mt = {
	__index = function(self, key)
		if type(key) ~= "string" then
			return nil
		end
		local lowerKey = string.lower(key)
		for k,v in pairs(self) do
			if string.lower(k) == lowerKey then
				return self[k]
			end
		end
	end,
	__newindex = function(self, key, value)
		if type(key) ~= "string" then
			return error("table index is nil", 2)
		end
		local lowerKey = string.lower(key)
		for k in pairs(self) do
			if string.lower(k) == lowerKey then
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
	elseif key == "account" then
		if type(db.raw.account) ~= "table" then
			db.raw.account = {}
		end
		rawset(db, 'account', db.raw.account)
		if db.defaults and db.defaults.account then
			inheritDefaults(db.account, db.defaults.account)
		end
		return db.account
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
	error(string.format('Cannot access key %q in db table. You may want to use db.profile[%q]', tostring(key), tostring(key)), 2)
end, __newindex = function(db, key, value)
	error(string.format('Cannot access key %q in db table. You may want to use db.profile[%q]', tostring(key), tostring(key)), 2)
end }

local CrawlForSerialization
local CrawlForDeserialization

local function SerializeObject(o)
	local t = { o:Serialize() }
	t[0] = o.class:GetLibraryVersion()
	CrawlForSerialization(t)
	return t
end

local function DeserializeObject(t)
	CrawlForDeserialization(t)
	local className = t[0]
	for i = 20, 1, -1 do
		if t[i] then
			table_setn(t, i)
			break
		end
	end
	local o = AceLibrary(className):Deserialize(unpack(t))
	table_setn(t, 0)
	return o
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
		if type(v) == "table" and type(v[0]) ~= "userdata" then
			if IsSerializable(v) then
				v = SerializeObject(v)
				t[k] = v
			else
				CrawlForSerialization(v)
			end
		end
		if type(k) == "table" and type(k[0]) ~= "userdata" then
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
	return type(t[0]) == "string" and AceLibrary:HasInstance(t[0])
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
			elseif type(v[0]) ~= "userdata" then
				CrawlForDeserialization(v)
			end
		end
		if type(k) == "table" then
			if IsDeserializable(k) then
				t[k] = nil
				t[DeserializeObject(k)] = v
				del(k)
			elseif type(k[0]) ~= "userdata" then
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
	error(string.format('Cannot access key %q in db table. You may want to use db.profile[%q]', tostring(key), tostring(key)), 2)
end, __newindex = function(db, key, value)
	error(string.format('Cannot access key %q in db table. You may want to use db.profile[%q]', tostring(key), tostring(key)), 2)
end }

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
	if type(_G[db.charName]) == "table" then
		CrawlForDeserialization(_G[db.charName])
	end
	rawset(db, 'raw', _G[db.name])
	if not db.raw.currentProfile then
		db.raw.currentProfile = {}
	end
	if not db.raw.currentProfile[charID] then
		db.raw.currentProfile[charID] = "Default"
	end
	if db.raw.disabled then
		setmetatable(db.raw.disabled, caseInsensitive_mt)
	end
	if self['acedb-profile-copylist'] then
		local t = self['acedb-profile-copylist']
		for k,v in pairs(t) do
			t[k] = nil
		end
		if db.raw.profiles then
			for k in pairs(db.raw.profiles) do
				if string.find(k, '^char/') then
					local name = string.sub(k, 6)
					if name ~= charID then
						t[k] =  CHARACTER .. name
					end
				elseif string.find(k, '^realm/') then
					local name = string.sub(k, 7)
					if name ~= realmID then
						t[k] =  REALM .. name
					end
				elseif string.find(k, '^class/') then
					local name = string.sub(k, 7)
					if name ~= classID then
						t[k] =  CLASS .. name
					end
				end
			end
		end
	end
	if self['acedb-profile-list'] then
		local t = self['acedb-profile-list']
		for k,v in pairs(t) do
			t[k] = nil
		end
		t.char = CHARACTER .. charID
		t.realm = REALM .. realmID
		t.class = CLASS .. classID
		t.Default = "Default"
		if db.raw.profiles then
			for k in pairs(db.raw.profiles) do
				if not string.find(k, '^char/') and not string.find(k, '^realm/') and not string.find(k, '^class/') then
					t[k] = k
				end
			end
		end
	end
	setmetatable(db, db_mt)
end

function AceDB:OnEmbedInitialize(target, name)
	if name then
		self:ADDON_LOADED(name)
	end
	self.InitializeDB(target, name)
end

function AceDB:RegisterDB(name, charName)
	AceDB:argCheck(name, 2, "string")
	AceDB:argCheck(charName, 3, "string", "nil")
	if self.db then
		AceDB:error("Cannot call \"RegisterDB\" if self.db is set.")
	end
	local stack = debugstack()
	local addonName = string.gsub(stack, ".-\n.-\\AddOns\\(.-)\\.*", "%1")
	self.db = {
		name = name,
		charName = charName
	}
	if AceDB.addonsLoaded[addonName] then
		AceDB.InitializeDB(self, addonName)
	else
		AceDB.addonsToBeInitialized[self] = addonName
	end
	AceDB.registry[self] = true
end

function AceDB:RegisterDefaults(kind, defaults, a3)
	local name
	if a3 then
		name, kind, defaults = kind, defaults, a3
		AceDB:argCheck(name, 2, "string")
		AceDB:argCheck(kind, 3, "string")
		AceDB:argCheck(defaults, 4, "table")
		if kind ~= "char" and kind ~= "class" and kind ~= "profile" and kind ~= "account" and kind ~= "realm" then
			AceDB:error("Bad argument #3 to `RegisterDefaults' (\"char\", \"class\", \"profile\", \"account\", or \"realm\" expected, got %q)", kind)
		end
	else
		AceDB:argCheck(kind, 2, "string")
		AceDB:argCheck(defaults, 3, "table")
		if kind ~= "char" and kind ~= "class" and kind ~= "profile" and kind ~= "account" and kind ~= "realm" then
			AceDB:error("Bad argument #2 to `RegisterDefaults' (\"char\", \"class\", \"profile\", \"account\", or \"realm\" expected, got %q)", kind)
		end
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

function AceDB:ResetDB(kind)
	AceDB:argCheck(kind, 2, "nil", "string")
	if not self.db or not self.db.raw then
		AceDB:error("Cannot call \"ResetDB\" before \"RegisterDB\" has been called and before \"ADDON_LOADED\" has been fired.")
	end
	local db = self.db
	if kind == nil then
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
			end
		end
	elseif kind == "account" then
		db.raw.account = nil
		rawset(db, 'account', nil)
		if db.namespaces then
			for name,v in pairs(db.namespaces) do
				rawset(v, 'account', nil)
			end
		end
	elseif kind == "char" then
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
	elseif kind == "realm" then
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
	elseif kind == "class" then
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
	elseif kind == "profile" then
		local id = db.raw.currentProfile and db.raw.currentProfile[charID] or "Default"
		if id == "char" then
			id = "char/" .. charID
		elseif id == "class" then
			id = "class/" .. classID
		elseif id == "realm" then
			id = "realm/" .. realmID
		end
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
	end
end

local function cleanDefaults(t, defaults)
	if defaults then
		for k,v in pairs(defaults) do
			if k == "*" then
				if type(v) == "table" then
					for k in pairs(t) do
						if (defaults[k] == nil or k == "*") and type(t[k]) == "table" then
							if cleanDefaults(t[k], v) then
								t[k] = nil
							end
						end
					end
				else
					for k in pairs(t) do
						if (defaults[k] == nil or k == "*") and t[k] == v then
							t[k] = nil
						end
					end
				end
			else
				if type(v) == "table" then
					if type(t[k]) == "table" then
						if cleanDefaults(t[k], v) then
							t[k] = nil
						end
					end
				elseif t[k] == v then
					t[k] = nil
				end
			end
		end
	end
	return t and not next(t)
end

function AceDB:GetProfile()
	if not self.db or not self.db.raw then
		return nil
	end
	if not self.db.raw.currentProfile then
		self.db.raw.currentProfile = {}
	end
	if not self.db.raw.currentProfile[charID] then
		self.db.raw.currentProfile[charID] = "Default"
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
	table_setn(to, table.getn(from))
	setmetatable(to, from)
	return to
end

function AceDB:SetProfile(name, copyFrom)
	AceDB:argCheck(name, 2, "string")
	AceDB:argCheck(copyFrom, 3, "string", "nil")
	if not self.db or not self.db.raw then
		AceDB:error("Cannot call \"SetProfile\" before \"RegisterDB\" has been called and before \"ADDON_LOADED\" has been fired.")
	end
	local db = self.db
	local copy = false
	local lowerName = string.lower(name)
	local lowerCopyFrom = copyFrom and string.lower(copyFrom)
	if string.sub(lowerName, 1, 5) == "char/" or string.sub(lowerName, 1, 6) == "realm/" or string.sub(lowerName, 1, 6) == "class/" then
		if string.sub(lowerName, 1, 5) == "char/" then
			name, copyFrom = "char", name
		else
			name, copyFrom = string.sub(lowerName, 1, 5), name
		end
		lowerName = string.lower(name)
		lowerCopyFrom = string.lower(copyFrom)
	end
	if copyFrom then
		if string.sub(lowerCopyFrom, 1, 5) == "char/" then
			AceDB:assert(lowerName == "char", "If argument #3 starts with `char/', argument #2 must be `char'")
		elseif string.sub(lowerCopyFrom, 1, 6) == "realm/" then
			AceDB:assert(lowerName == "realm", "If argument #3 starts with `realm/', argument #2 must be `realm'")
		elseif string.sub(lowerCopyFrom, 1, 6) == "class/" then
			AceDB:assert(lowerName == "class", "If argument #3 starts with `class/', argument #2 must be `class'")
		else
			AceDB:assert(lowerName ~= "char" and lowerName ~= "realm" and lowerName ~= "class", "If argument #3 does not start with a special prefix, that prefix cannot be copied to.")
		end
		if not db.raw.profiles or not db.raw.profiles[copyFrom] then
			AceDB:error("Cannot copy profile %q, it does not exist.", copyFrom)
		elseif (string.sub(lowerName, 1, 5) == "char/" and string.sub(lowerName, 6) == string.lower(charID)) or (string.sub(lowerName, 1, 6) == "realm/" and string.sub(lowerName, 7) == string.lower(realmID)) or (string.sub(lowerName, 1, 6) == "class/" and string.sub(lowerName, 7) == string.lower(classID)) then
			AceDB:error("Cannot copy profile %q, it is currently in use.", name)
		end
	end
	local oldName = db.raw.currentProfile[charID]
	if string.lower(oldName) == string.lower(name) then
		return
	end
	local current = self.class
	while current and current ~= AceOO.Class do
		if current.mixins then
			for mixin in pairs(current.mixins) do
				if type(mixin.OnEmbedProfileDisable) == "function" then
					mixin:OnEmbedProfileDisable(self)
				end
			end
		end
		current = current.super
	end
	if type(self.OnProfileDisable) == "function" then
		self:OnProfileDisable()
	end
	local oldProfileData = db.profile
	local realName = name
	if lowerName == "char" then
		realName = name .. "/" .. charID
	elseif lowerName == "realm/" then
		realName = name .. "/" .. realmID
	elseif lowerName == "class/" then
		realName = name .. "/" .. classID
	end
	local active = self:IsActive()
	db.raw.currentProfile[charID] = name
	rawset(db, 'profile', nil)
	if db.namespaces then
		for k,v in pairs(db.namespaces) do
			rawset(v, 'profile', nil)
		end
	end
	if copyFrom then
		for k,v in pairs(db.profile) do
			db.profile[k] = nil
		end
		copyTable(db.profile, db.raw.profiles[copyFrom])
		inheritDefaults(db.profile, db.defaults and db.defaults.profile)
		if db.namespaces then
			for l,u in pairs(db.namespaces) do
				for k,v in pairs(u.profile) do
					u.profile[k] = nil
				end
				copyTable(u.profile, db.raw.namespaces[l].profiles[copyFrom])
				inheritDefaults(u.profile, u.defaults and u.defaults.profile)
			end
		end
	end
	local current = self.class
	while current and current ~= AceOO.Class do
		if current.mixins then
			for mixin in pairs(current.mixins) do
				if type(mixin.OnEmbedProfileEnable) == "function" then
					mixin:OnEmbedProfileEnable(self, oldName, oldProfileData, copyFrom)
				end
			end
		end
		current = current.super
	end
	if type(self.OnProfileEnable) == "function" then
		self:OnProfileEnable(oldName, oldProfileData, copyFrom)
	end
	if cleanDefaults(oldProfileData, db.defaults and db.defaults.profile) then
		db.raw.profiles[oldName] = nil
		if not next(db.raw.profiles) then
			db.raw.profiles = nil
		end
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
							mixin:OnEmbedEnable(self)
						end
					end
				end
				current = current.super
			end
			if type(self.OnEnable) == "function" then
				self:OnEnable()
			end
		else
			local current = self.class
			while current and current ~= AceOO.Class do
				if current.mixins then
					for mixin in pairs(current.mixins) do
						if type(mixin.OnEmbedDisable) == "function" then
							mixin:OnEmbedDisable(self)
						end
					end
				end
				current = current.super
			end
			if type(self.OnDisable) == "function" then
				self:OnDisable()
			end
		end
	end
	if self['acedb-profile-list'] then
		if not self['acedb-profile-list'][name] then
			self['acedb-profile-list'][name] = name
		end
	end
	if Dewdrop then
		Dewdrop:Refresh(1)
		Dewdrop:Refresh(2)
		Dewdrop:Refresh(3)
		Dewdrop:Refresh(4)
		Dewdrop:Refresh(5)
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
						mixin:OnEmbedEnable(self)
					end
				end
			end
			current = current.super
		end
		if type(self.OnEnable) == "function" then
			self:OnEnable()
		end
	else
		local current = self.class
		while current and current ~= AceOO.Class do
			if current.mixins then
				for mixin in pairs(current.mixins) do
					if type(mixin.OnEmbedDisable) == "function" then
						mixin:OnEmbedDisable(self)
					end
				end
			end
			current = current.super
		end
		if type(self.OnDisable) == "function" then
			self:OnDisable()
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
	for addon in pairs(AceDB.registry) do
		local db = addon.db
		if db then
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
					db.raw.profiles[db.raw.currentProfile and db.raw.currentProfile[charID] or "Default"] = nil
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
								db.raw.namespaces[name].profiles[db.raw.currentProfile and db.raw.currentProfile[charID] or "Default"] = nil
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
					if string.lower(v) == "default" then
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
		local t = target['acedb-profile-list']
		for k,v in pairs(t) do
			t[k] = nil
		end
		t.char = CHARACTER .. charID
		t.realm = REALM .. realmID
		t.class = CLASS .. classID
		t.Default = "Default"
		if target.db and target.db.raw then
			local db = target.db
			if db.raw.profiles then
				for k in pairs(db.raw.profiles) do
					if not string.find(k, '^char/') and not string.find(k, '^realm/') and not string.find(k, '^class/') then
						t[k] = k
					end
				end
			end
		end
	end
	if not target['acedb-profile-copylist'] then
		target['acedb-profile-copylist'] = setmetatable({}, caseInsensitive_mt)
		if target.db and target.db.raw then
			local t = target['acedb-profile-copylist']
			local db = target.db

			if db.raw.profiles then
				for k in pairs(db.raw.profiles) do
					if string.find(k, '^char/') then
						local name = string.sub(k, 6)
						if name ~= charID then
							t[k] =  CHARACTER .. name
						end
					elseif string.find(k, '^realm/') then
						local name = string.sub(k, 7)
						if name ~= realmID then
							t[k] =  REALM .. name
						end
					elseif string.find(k, '^class/') then
						local name = string.sub(k, 7)
						if name ~= classID then
							t[k] =  CLASS .. name
						end
					end
				end
			end
		end
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
					get = "GetProfile",
					set = "SetProfile",
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
				}
			}
		},
	}
end

local function activate(self, oldLib, oldDeactivate)
	AceDB = self
	AceEvent = AceLibrary:HasInstance("AceEvent-2.0") and AceLibrary("AceEvent-2.0")

	self.super.activate(self, oldLib, oldDeactivate)

	for t in pairs(self.embedList) do
		if t.db then
			rawset(t.db, 'char', nil)
			rawset(t.db, 'realm', nil)
			rawset(t.db, 'class', nil)
			rawset(t.db, 'account', nil)
			rawset(t.db, 'profile', nil)
			setmetatable(t.db, db_mt)
		end
	end

	if oldLib then
		self.addonsToBeInitialized = oldLib.addonsToBeInitialized
		self.addonsLoaded = oldLib.addonsLoaded
		self.registry = oldLib.registry
	end
	if not self.addonsToBeInitialized then
		self.addonsToBeInitialized = {}
	end
	if not self.addonsLoaded then
		self.addonsLoaded = {}
	end
	if not self.registry then
		self.registry = {}
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
