--[[
Name: LibSharedMedia-3.0
Revision: $Revision: 58 $
Author: Elkano (elkano@gmx.de)
Inspired By: SurfaceLib by Haste/Otravi (troeks@gmail.com)
Website: http://www.wowace.com/projects/libsharedmedia-3-0/
Description: Shared handling of media data (fonts, sounds, textures, ...) between addons.
Dependencies: LibStub, CallbackHandler-1.0
License: LGPL v2.1
]]

local MAJOR, MINOR = "LibSharedMedia-3.0", 90000 + tonumber(("$Revision: 58 $"):match("(%d+)"))
local lib = LibStub:NewLibrary(MAJOR, MINOR)

if not lib then return end

local _G = getfenv(0)

local pairs		= _G.pairs
local type		= _G.type

local band			= _G.bit.band

local table_insert	= _G.table.insert
local table_sort	= _G.table.sort

local locale = GetLocale()
local locale_is_western
local LOCALE_MASK = 0
lib.LOCALE_BIT_koKR		= 1
lib.LOCALE_BIT_ruRU		= 2
lib.LOCALE_BIT_zhCN		= 4
lib.LOCALE_BIT_zhTW		= 8
lib.LOCALE_BIT_western	= 128

local CallbackHandler = LibStub:GetLibrary("CallbackHandler-1.0")

lib.callbacks		= lib.callbacks			or CallbackHandler:New(lib)

lib.DefaultMedia	= lib.DefaultMedia		or {}
lib.MediaList		= lib.MediaList			or {}
lib.MediaTable		= lib.MediaTable		or {}
lib.MediaType		= lib.MediaType			or {}
lib.OverrideMedia	= lib.OverrideMedia		or {}

local defaultMedia = lib.DefaultMedia
local mediaList = lib.MediaList
local mediaTable = lib.MediaTable
local overrideMedia = lib.OverrideMedia


-- create mediatype constants
lib.MediaType.BACKGROUND	= "background"			-- background textures
lib.MediaType.BORDER		= "border"				-- border textures
lib.MediaType.FONT			= "font"				-- fonts
lib.MediaType.STATUSBAR		= "statusbar"			-- statusbar textures
lib.MediaType.SOUND			= "sound"				-- sound files

-- populate lib with default Blizzard data
-- BACKGROUND
if not lib.MediaTable.background then lib.MediaTable.background = {} end
lib.MediaTable.background["Blizzard Dialog Background"]		= [[Interface\DialogFrame\UI-DialogBox-Background]]
lib.MediaTable.background["Blizzard Low Health"]			= [[Interface\FullScreenTextures\LowHealth]]
lib.MediaTable.background["Blizzard Out of Control"]		= [[Interface\FullScreenTextures\OutOfControl]]
lib.MediaTable.background["Blizzard Parchment"]				= [[Interface\AchievementFrame\UI-Achievement-Parchment-Horizontal]]
lib.MediaTable.background["Blizzard Parchment 2"]			= [[Interface\AchievementFrame\UI-Achievement-Parchment]]
lib.MediaTable.background["Blizzard Tabard Background"]		= [[Interface\TabardFrame\TabardFrameBackground]]
lib.MediaTable.background["Blizzard Tooltip"]				= [[Interface\Tooltips\UI-Tooltip-Background]]
lib.MediaTable.background["Solid"]							= [[Interface\Buttons\WHITE8X8]]

-- BORDER
if not lib.MediaTable.border then lib.MediaTable.border = {} end
lib.MediaTable.border["None"]								= [[Interface\None]]
lib.MediaTable.border["Blizzard Achievement Wood"]			= [[Interface\AchievementFrame\UI-Achievement-WoodBorder]]
lib.MediaTable.border["Blizzard Chat Bubble"]				= [[Interface\Tooltips\ChatBubble-Backdrop]]
lib.MediaTable.border["Blizzard Dialog"]					= [[Interface\DialogFrame\UI-DialogBox-Border]]
lib.MediaTable.border["Blizzard Dialog Gold"]				= [[Interface\DialogFrame\UI-DialogBox-Gold-Border]]
lib.MediaTable.border["Blizzard Party"]						= [[Interface\CHARACTERFRAME\UI-Party-Border]]
lib.MediaTable.border["Blizzard Tooltip"]					= [[Interface\Tooltips\UI-Tooltip-Border]]

-- FONT
if not lib.MediaTable.font then lib.MediaTable.font = {} end
local SML_MT_font = lib.MediaTable.font
if locale == "koKR" then
	LOCALE_MASK = lib.LOCALE_BIT_koKR
--
	SML_MT_font["굵은 글꼴"]		= [[Fonts\2002B.TTF]]
	SML_MT_font["기본 글꼴"]		= [[Fonts\2002.TTF]]
	SML_MT_font["데미지 글꼴"]		= [[Fonts\K_Damage.TTF]]
	SML_MT_font["퀘스트 글꼴"]		= [[Fonts\K_Pagetext.TTF]]
--
	lib.DefaultMedia["font"] = "기본 글꼴" -- someone from koKR please adjust if needed
--
elseif locale == "zhCN" then
	LOCALE_MASK = lib.LOCALE_BIT_zhCN
--
	SML_MT_font["伤害数字"]		= [[Fonts\ZYKai_C.ttf]]
	SML_MT_font["默认"]			= [[Fonts\ZYKai_T.ttf]]
	SML_MT_font["聊天"]			= [[Fonts\ZYHei.ttf]]
--
	lib.DefaultMedia["font"] = "默认" -- someone from zhCN please adjust if needed
--
elseif locale == "zhTW" then
	LOCALE_MASK = lib.LOCALE_BIT_zhTW
--
	SML_MT_font["提示訊息"]		= [[Fonts\bHEI00M.ttf]]
	SML_MT_font["聊天"]			= [[Fonts\bHEI01B.ttf]]
	SML_MT_font["傷害數字"]		= [[Fonts\bKAI00M.ttf]]
	SML_MT_font["預設"]			= [[Fonts\bLEI00D.ttf]]
--
	lib.DefaultMedia["font"] = "預設" -- someone from zhTW please adjust if needed

elseif locale == "ruRU" then
	LOCALE_MASK = lib.LOCALE_BIT_ruRU
--
	SML_MT_font["Arial Narrow"]			= [[Fonts\ARIALN.TTF]]
	SML_MT_font["Friz Quadrata TT"]		= [[Fonts\FRIZQT__.TTF]]
	SML_MT_font["Morpheus"]				= [[Fonts\MORPHEUS.TTF]]
	SML_MT_font["Nimrod MT"]			= [[Fonts\NIM_____.ttf]]
	SML_MT_font["Skurri"]				= [[Fonts\SKURRI.TTF]]
--
	lib.DefaultMedia.font = "Friz Quadrata TT"
--
else
	LOCALE_MASK = lib.LOCALE_BIT_western
	locale_is_western = true
--
	SML_MT_font["Arial Narrow"]			= [[Fonts\ARIALN.TTF]]
	SML_MT_font["Friz Quadrata TT"]		= [[Fonts\FRIZQT__.TTF]]
	SML_MT_font["Morpheus"]				= [[Fonts\MORPHEUS.TTF]]
	SML_MT_font["Skurri"]				= [[Fonts\SKURRI.TTF]]
--
	lib.DefaultMedia.font = "Friz Quadrata TT"
--
end

-- STATUSBAR
if not lib.MediaTable.statusbar then lib.MediaTable.statusbar = {} end
lib.MediaTable.statusbar["Blizzard"]						= [[Interface\TargetingFrame\UI-StatusBar]]
lib.DefaultMedia.statusbar = "Blizzard"

-- SOUND
if not lib.MediaTable.sound then lib.MediaTable.sound = {} end
lib.MediaTable.sound["None"]								= [[Interface\Quiet.mp3]]	-- Relies on the fact that PlaySound[File] doesn't error on non-existing input.
lib.DefaultMedia.sound = "None"

local function rebuildMediaList(mediatype)
	local mtable = mediaTable[mediatype]
	if not mtable then return end
	if not mediaList[mediatype] then mediaList[mediatype] = {} end
	local mlist = mediaList[mediatype]
	-- list can only get larger, so simply overwrite it
	local i = 0
	for k in pairs(mtable) do
		i = i + 1
		mlist[i] = k
	end
	table_sort(mlist)
end

function lib:Register(mediatype, key, data, langmask)
	if type(mediatype) ~= "string" then
		error(MAJOR..":Register(mediatype, key, data, langmask) - mediatype must be string, got "..type(mediatype))
	end
	if type(key) ~= "string" then
		error(MAJOR..":Register(mediatype, key, data, langmask) - key must be string, got "..type(key))
	end
	if mediatype == lib.MediaType.FONT  and ((langmask and band(langmask, LOCALE_MASK) == 0) or not (langmask or locale_is_western)) then return false end
	mediatype = mediatype:lower()
	if not mediaTable[mediatype] then mediaTable[mediatype] = {} end
	local mtable = mediaTable[mediatype]
	if mtable[key] then return false end
	
	mtable[key] = data
	rebuildMediaList(mediatype)
	self.callbacks:Fire("LibSharedMedia_Registered", mediatype, key)
	return true
end

function lib:Fetch(mediatype, key, noDefault)
	local mtt = mediaTable[mediatype]
	local overridekey = overrideMedia[mediatype]
	local result = mtt and ((overridekey and mtt[overridekey] or mtt[key]) or (not noDefault and defaultMedia[mediatype] and mtt[defaultMedia[mediatype]])) or nil

	return result
end

function lib:IsValid(mediatype, key)
	return mediaTable[mediatype] and (not key or mediaTable[mediatype][key]) and true or false
end

function lib:HashTable(mediatype)
	return mediaTable[mediatype]
end

function lib:List(mediatype)
	if not mediaTable[mediatype] then
		return nil
	end
	if not mediaList[mediatype] then
		rebuildMediaList(mediatype)
	end
	return mediaList[mediatype]
end

function lib:GetGlobal(mediatype)
	return overrideMedia[mediatype]
end

function lib:SetGlobal(mediatype, key)
	if not mediaTable[mediatype] then
		return false
	end
	overrideMedia[mediatype] = (key and mediaTable[mediatype][key]) and key or nil
	self.callbacks:Fire("LibSharedMedia_SetGlobal", mediatype, overrideMedia[mediatype])
	return true
end

function lib:GetDefault(mediatype)
	return defaultMedia[mediatype]
end

function lib:SetDefault(mediatype, key)
	if mediaTable[mediatype] and mediaTable[mediatype][key] and not defaultMedia[mediatype] then
		defaultMedia[mediatype] = key
		return true
	else
		return false
	end
end
