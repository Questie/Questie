--[[
Name: AceLocale-2.2
Revision: $Rev: 15291 $
Developed by: The Ace Development Team (http://www.wowace.com/index.php/The_Ace_Development_Team)
Inspired By: Ace 1.x by Turan (turan@gryphon.com)
Website: http://www.wowace.com/
Documentation: http://www.wowace.com/index.php/AceLocale-2.2
SVN: http://svn.wowace.com/root/trunk/Ace2/AceLocale-2.2
Description: Localization library for addons to use to handle proper
             localization and internationalization.
Dependencies: AceLibrary
]]

local MAJOR_VERSION = "AceLocale-2.2"
local MINOR_VERSION = "$Revision: 15291 $"

if not AceLibrary then error(MAJOR_VERSION .. " requires AceLibrary.") end
if not AceLibrary:IsNewVersion(MAJOR_VERSION, MINOR_VERSION) then return end

local AceLocale = {}

local DEFAULT_LOCALE = "enUS"
local _G = getfenv(0)

local BASE_TRANSLATIONS, DEBUGGING, TRANSLATIONS, BASE_LOCALE, TRANSLATION_TABLES, REVERSE_TRANSLATIONS, STRICTNESS, DYNAMIC_LOCALES, CURRENT_LOCALE, NAME

local rawget = rawget
local rawset = rawset
local type = type

local newRegistries = {}
local scheduleClear

local lastSelf
local __index = function(self, key)
	lastSelf = self
	local value = (rawget(self, TRANSLATIONS) or AceLocale.prototype)[key]
	rawset(self, key, value)
	return value
end

local __newindex = function(self, k, v)
	if type(v) ~= "function" and type(k) ~= "table" then
		AceLocale.error(self, "Cannot change the values of an AceLocale instance.")
	end
	rawset(self, k, v)
end

local __tostring = function(self)
	if type(rawget(self, 'GetLibraryVersion')) == "function" then
		return self:GetLibraryVersion()
	else
		return "AceLocale(" .. self[NAME] .. ")"
	end
end

local function clearCache(self)
	if not rawget(self, BASE_TRANSLATIONS) then
		return
	end
	
	local cache = self[BASE_TRANSLATIONS]
	rawset(self, REVERSE_TRANSLATIONS, nil)
	
	for k in pairs(self) do
		if rawget(cache, k) ~= nil then
			self[k] = nil
		end
	end
	rawset(self, 'tmp', true)
	self.tmp = nil
end

local function refixInstance(instance)
	if getmetatable(instance) then
		setmetatable(instance, nil)
	end
	local translations = instance[TRANSLATIONS]
	if translations then
		if getmetatable(translations) then
			setmetatable(translations, nil)
		end
		local baseTranslations = instance[BASE_TRANSLATIONS]
		if getmetatable(baseTranslations) then
			setmetatable(baseTranslations, nil)
		end
		if translations == baseTranslations or instance[STRICTNESS] then
			setmetatable(instance, {
				__index = __index,
				__newindex = __newindex,
				__tostring = __tostring
			})
			
			setmetatable(translations, {
				__index = AceLocale.prototype
			})
		else
			setmetatable(instance, {
				__index = __index,
				__newindex = __newindex,
				__tostring = __tostring
			})
			
			setmetatable(translations, {
				__index = baseTranslations,
			})
			
			setmetatable(baseTranslations, {
				__index = AceLocale.prototype,
			})
		end
	else
		setmetatable(instance, {
			__index = __index,
			__newindex = __newindex,
			__tostring = __tostring,
		})
	end
	clearCache(instance)
	newRegistries[instance] = true
	scheduleClear()
	return instance
end

function AceLocale:new(name)
	self:argCheck(name, 2, "string")
	
	if self.registry[name] and type(rawget(self.registry[name], 'GetLibraryVersion')) ~= "function" then
		return self.registry[name]
	end
	
	AceLocale.registry[name] = refixInstance({
		[STRICTNESS] = false,
		[NAME] = name,
	})
	newRegistries[AceLocale.registry[name]] = true
	return AceLocale.registry[name]
end

AceLocale.prototype = { class = AceLocale }

function AceLocale.prototype:EnableDebugging()
	if rawget(self, BASE_TRANSLATIONS) then
		AceLocale.error(self, "Cannot enable debugging after a translation has been registered.")
	end
	rawset(self, DEBUGGING, true)
end

function AceLocale.prototype:EnableDynamicLocales(override)
	AceLocale.argCheck(self, override, 2, "boolean", "nil")
	if not override and rawget(self, BASE_TRANSLATIONS) then
		AceLocale.error(self, "Cannot enable dynamic locales after a translation has been registered.")
	end
	if not rawget(self, DYNAMIC_LOCALES) then
		rawset(self, DYNAMIC_LOCALES, true)
		if rawget(self, BASE_LOCALE) then
			if not rawget(self, TRANSLATION_TABLES) then
				rawset(self, TRANSLATION_TABLES, {})
			end
			self[TRANSLATION_TABLES][self[BASE_LOCALE]] = self[BASE_TRANSLATIONS]
			self[TRANSLATION_TABLES][self[CURRENT_LOCALE]] = self[TRANSLATIONS]
		end
	end
end

function AceLocale.prototype:RegisterTranslations(locale, func)
	AceLocale.argCheck(self, locale, 2, "string")
	AceLocale.argCheck(self, func, 3, "function")
	
	if locale == rawget(self, BASE_LOCALE) then
		AceLocale.error(self, "Cannot provide the same locale more than once. %q provided twice.", locale)
	end
	
	if rawget(self, BASE_TRANSLATIONS) and GetLocale() ~= locale then
		if rawget(self, DEBUGGING) or rawget(self, DYNAMIC_LOCALES) then
			if not rawget(self, TRANSLATION_TABLES) then
				rawset(self, TRANSLATION_TABLES, {})
			end
			if self[TRANSLATION_TABLES][locale] then
				AceLocale.error(self, "Cannot provide the same locale more than once. %q provided twice.", locale)
			end
			local t = func()
			func = nil
			if type(t) ~= "table" then
				AceLocale.error(self, "Bad argument #3 to `RegisterTranslations'. function did not return a table. (expected table, got %s)", type(t))
			end
			self[TRANSLATION_TABLES][locale] = t
			t = nil
		end
		func = nil
		return
	end
	local t = func()
	func = nil
	if type(t) ~= "table" then
		AceLocale.error(self, "Bad argument #3 to `RegisterTranslations'. function did not return a table. (expected table, got %s)", type(t))
	end
	
	rawset(self, TRANSLATIONS, t)
	if not rawget(self, BASE_TRANSLATIONS) then
		rawset(self, BASE_TRANSLATIONS, t)
		rawset(self, BASE_LOCALE, locale)
		for key,value in pairs(t) do
			if value == true then
				t[key] = key
			end
		end
	else
		for key, value in pairs(self[TRANSLATIONS]) do
			if not rawget(self[BASE_TRANSLATIONS], key) then
				AceLocale.error(self, "Improper translation exists. %q is likely misspelled for locale %s.", key, locale)
			end
			if value == true then
				AceLocale.error(self, "Can only accept true as a value on the base locale. %q is the base locale, %q is not.", rawget(self, BASE_LOCALE), locale)
			end
		end
	end
	rawset(self, CURRENT_LOCALE, locale)
	refixInstance(self)
	if rawget(self, DEBUGGING) or rawget(self, DYNAMIC_LOCALES) then
		if not rawget(self, TRANSLATION_TABLES) then
			rawset(self, TRANSLATION_TABLES, {})
		end
		self[TRANSLATION_TABLES][locale] = t
	end
	t = nil
end

function AceLocale.prototype:SetLocale(locale)
	AceLocale.argCheck(self, locale, 2, "string", "boolean")
	if not rawget(self, DYNAMIC_LOCALES) then
		AceLocale.error(self, "Cannot call `SetLocale' without first calling `EnableDynamicLocales'.")
	end
	if not rawget(self, TRANSLATION_TABLES) then
		AceLocale.error(self, "Cannot call `SetLocale' without first calling `RegisterTranslations'.")
	end
	if locale == true then
		locale = GetLocale()
		if not self[TRANSLATION_TABLES][locale] then
			locale = self[BASE_LOCALE]
		end
	end
	
	if self[CURRENT_LOCALE] == locale then
		return
	end
	
	if not self[TRANSLATION_TABLES][locale] then
		AceLocale.error(self, "Locale %q not registered.", locale)
	end
	
	self[TRANSLATIONS] = self[TRANSLATION_TABLES][locale]
	self[CURRENT_LOCALE] = locale
	refixInstance(self)
end

function AceLocale.prototype:GetLocale()
	if not rawget(self, TRANSLATION_TABLES) then
		AceLocale.error(self, "Cannot call `GetLocale' without first calling `RegisterTranslations'.")
	end
	return self[CURRENT_LOCALE]
end

local function iter(t, position)
	return (next(t, position))
end

function AceLocale.prototype:IterateAvailableLocales()
	if not rawget(self, DYNAMIC_LOCALES) then
		AceLocale.error(self, "Cannot call `IterateAvailableLocales' without first calling `EnableDynamicLocales'.")
	end
	if not rawget(self, TRANSLATION_TABLES) then
		AceLocale.error(self, "Cannot call `IterateAvailableLocales' without first calling `RegisterTranslations'.")
	end
	return iter, self[TRANSLATION_TABLES], nil
end

function AceLocale.prototype:HasLocale(locale)
	if not rawget(self, DYNAMIC_LOCALES) then
		AceLocale.error(self, "Cannot call `HasLocale' without first calling `EnableDynamicLocales'.")
	end
	AceLocale.argCheck(self, locale, 2, "string")
	return rawget(self, TRANSLATION_TABLES) and self[TRANSLATION_TABLES][locale] ~= nil
end

function AceLocale.prototype:SetStrictness(strict)
	AceLocale.argCheck(self, strict, 2, "boolean")
	local mt = getmetatable(self)
	if not mt then
		AceLocale.error(self, "Cannot call `SetStrictness' without a metatable.")
	end
	if not rawget(self, TRANSLATIONS) then
		AceLocale.error(self, "No translations registered.")
	end
	rawset(self, STRICTNESS, strict)
	refixInstance(self)
end

local function initReverse(self)
	rawset(self, REVERSE_TRANSLATIONS, {})
	local alpha = self[TRANSLATIONS]
	local bravo = self[REVERSE_TRANSLATIONS]
	for base, localized in pairs(alpha) do
		bravo[localized] = base
	end
end

function AceLocale.prototype:GetTranslation(text)
	AceLocale.argCheck(self, text, 1, "string", "number")
	if not rawget(self, TRANSLATIONS) then
		AceLocale.error(self, "No translations registered")
	end
	return self[text]
end

function AceLocale.prototype:GetStrictTranslation(text)
	AceLocale.argCheck(self, text, 1, "string", "number")
	local x = rawget(self, TRANSLATIONS)
	if not x then
		AceLocale.error(self, "No translations registered")
	end
	local value = rawget(x, text)
	if value == nil then
		AceLocale.error(self, "Translation %q does not exist for locale %s", text, self[CURRENT_LOCALE])
	end
	return value
end

function AceLocale.prototype:GetReverseTranslation(text)
	local x = rawget(self, REVERSE_TRANSLATIONS)
	if not x then
		if not rawget(self, TRANSLATIONS) then
			AceLocale.error(self, "No translations registered")
		end
		initReverse(self)
		x = self[REVERSE_TRANSLATIONS]
	end
	local translation = x[text]
	if not translation then
		AceLocale.error(self, "Reverse translation for %q does not exist", text)
	end
	return translation
end

function AceLocale.prototype:GetIterator()
	local x = rawget(self, TRANSLATIONS)
	if not x then
		AceLocale.error(self, "No translations registered")
	end
	return next, x, nil
end

function AceLocale.prototype:GetReverseIterator()
	local x = rawget(self, REVERSE_TRANSLATIONS)
	if not x then
		if not rawget(self, TRANSLATIONS) then
			AceLocale.error(self, "No translations registered")
		end
		initReverse(self)
		x = self[REVERSE_TRANSLATIONS]
	end
	return next, x, nil
end

function AceLocale.prototype:HasTranslation(text)
	AceLocale.argCheck(self, text, 1, "string", "number")
	local x = rawget(self, TRANSLATIONS)
	if not x then
		AceLocale.error(self, "No translations registered")
	end
	return rawget(x, text) and true
end

function AceLocale.prototype:HasReverseTranslation(text)
	local x = rawget(self, REVERSE_TRANSLATIONS)
	if not x then
		if not rawget(self, TRANSLATIONS) then
			AceLocale.error(self, "No translations registered")
		end
		initReverse(self)
		x = self[REVERSE_TRANSLATIONS]
	end
	return x[text] and true
end

function AceLocale.prototype:Debug()
	if not rawget(self, DEBUGGING) then
		return
	end
	local words = {}
	local locales = {"enUS", "deDE", "frFR", "koKR", "zhCN", "zhTW", "esES"}
	local localizations = {}
	DEFAULT_CHAT_FRAME:AddMessage("--- AceLocale Debug ---")
	for _,locale in ipairs(locales) do
		if not self[TRANSLATION_TABLES][locale] then
			DEFAULT_CHAT_FRAME:AddMessage(string.format("Locale %q not found", locale))
		else
			localizations[locale] = self[TRANSLATION_TABLES][locale]
		end
	end
	local localeDebug = {}
	for locale, localization in pairs(localizations) do
		localeDebug[locale] = {}
		for word in pairs(localization) do
			if type(localization[word]) == "table" then
				if type(words[word]) ~= "table" then
					words[word] = {}
				end
				for bit in pairs(localization[word]) do
					if type(localization[word][bit]) == "string" then
						words[word][bit] = true
					end
				end
			elseif type(localization[word]) == "string" then
				words[word] = true
			end
		end
	end
	for word in pairs(words) do
		if type(words[word]) == "table" then
			for bit in pairs(words[word]) do
				for locale, localization in pairs(localizations) do
					if not rawget(localization, word) or not localization[word][bit] then
						localeDebug[locale][word .. "::" .. bit] = true
					end
				end
			end
		else
			for locale, localization in pairs(localizations) do
				if not rawget(localization, word) then
					localeDebug[locale][word] = true
				end
			end
		end
	end
	for locale, t in pairs(localeDebug) do
		if not next(t) then
			DEFAULT_CHAT_FRAME:AddMessage(string.format("Locale %q complete", locale))
		else
			DEFAULT_CHAT_FRAME:AddMessage(string.format("Locale %q missing:", locale))
			for word in pairs(t) do
				DEFAULT_CHAT_FRAME:AddMessage(string.format("    %q", word))
			end
		end
	end
	DEFAULT_CHAT_FRAME:AddMessage("--- End AceLocale Debug ---")
end

setmetatable(AceLocale.prototype, {
	__index = function(self, k)
		if type(k) ~= "table" and k ~= 0 and k ~= "GetLibraryVersion"  and k ~= "error" and k ~= "assert" and k ~= "argCheck" and k ~= "pcall" then -- HACK: remove "GetLibraryVersion" and such later.
			AceLocale.error(lastSelf or self, "Translation %q does not exist.", k)
		end
		return nil
	end
})

local function activate(self, oldLib, oldDeactivate)
	AceLocale = self
	
	self.frame = oldLib and oldLib.frame or CreateFrame("Frame")
	self.registry = oldLib and oldLib.registry or {}
	self.BASE_TRANSLATIONS = oldLib and oldLib.BASE_TRANSLATIONS or {}
	self.DEBUGGING = oldLib and oldLib.DEBUGGING or {}
	self.TRANSLATIONS = oldLib and oldLib.TRANSLATIONS or {}
	self.BASE_LOCALE = oldLib and oldLib.BASE_LOCALE or {}
	self.TRANSLATION_TABLES = oldLib and oldLib.TRANSLATION_TABLES or {}
	self.REVERSE_TRANSLATIONS = oldLib and oldLib.REVERSE_TRANSLATIONS or {}
	self.STRICTNESS = oldLib and oldLib.STRICTNESS or {}
	self.NAME = oldLib and oldLib.NAME or {}
	self.DYNAMIC_LOCALES = oldLib and oldLib.DYNAMIC_LOCALES or {}
	self.CURRENT_LOCALE = oldLib and oldLib.CURRENT_LOCALE or {}
	
	BASE_TRANSLATIONS = self.BASE_TRANSLATIONS
	DEBUGGING = self.DEBUGGING
	TRANSLATIONS = self.TRANSLATIONS
	BASE_LOCALE = self.BASE_LOCALE
	TRANSLATION_TABLES = self.TRANSLATION_TABLES
	REVERSE_TRANSLATIONS = self.REVERSE_TRANSLATIONS
	STRICTNESS = self.STRICTNESS
	NAME = self.NAME
	DYNAMIC_LOCALES = self.DYNAMIC_LOCALES
	CURRENT_LOCALE = self.CURRENT_LOCALE
	
	
	local GetTime = GetTime
	local timeUntilClear = GetTime() + 5
	scheduleClear = function()
		if next(newRegistries) then
			self.frame:Show()
			timeUntilClear = GetTime() + 5
		end
	end
	
	if not self.registry then
		self.registry = {}
	else
		for name, instance in pairs(self.registry) do
			local name = name
			local mt = getmetatable(instance)
			setmetatable(instance, nil)
			instance[NAME] = name
			local strict
			if instance[STRICTNESS] ~= nil then
				strict = instance[STRICTNESS]
			elseif instance[TRANSLATIONS] ~= instance[BASE_TRANSLATIONS] then
				if getmetatable(instance[TRANSLATIONS]).__index == oldLib.prototype then
					strict = true
				end
			end
			instance[STRICTNESS] = strict and true or false
			refixInstance(instance)
		end
	end
	
	self.frame:SetScript("OnEvent", scheduleClear)
	self.frame:SetScript("OnUpdate", function() -- (this, elapsed)
		if timeUntilClear - GetTime() <= 0 then
			self.frame:Hide()
			for k in pairs(newRegistries) do
				clearCache(k)
				newRegistries[k] = nil
				k = nil
			end
		end
	end)
	self.frame:UnregisterAllEvents()
	self.frame:RegisterEvent("ADDON_LOADED")
	self.frame:RegisterEvent("PLAYER_ENTERING_WORLD")
	self.frame:Show()
	
	if oldDeactivate then
		oldDeactivate(oldLib)
	end
end

AceLibrary:Register(AceLocale, MAJOR_VERSION, MINOR_VERSION, activate)
