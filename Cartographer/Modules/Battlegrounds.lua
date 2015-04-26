local revision = tonumber(string.sub("$Revision: 18625 $", 12, -3))
if revision > Cartographer.revision then
	Cartographer.version = "r" .. revision
	Cartographer.revision = revision
	Cartographer.date = string.sub("$Date: 2006-12-02 16:13:35 +0300 (Сб, 02 дек 2006) $", 8, 17)
end

local L = AceLibrary("AceLocale-2.2"):new("Cartographer-Battlegrounds")

L:RegisterTranslations("enUS", function() return {
	["Battlegrounds"] = true,
	["Module which provides maps of battlegrounds."] = true,
} end)

L:RegisterTranslations("deDE", function() return {
--	["Battlegrounds"] = true,
--	["Module which provides maps of battlegrounds."] = true,
} end)

L:RegisterTranslations("frFR", function() return {
--	["Battlegrounds"] = true,
--	["Module which provides maps of battlegrounds."] = true,
} end)

L:RegisterTranslations("koKR", function() return {
	["Battlegrounds"] = "전장",
	["Module which provides maps of battlegrounds."] = "전장 지도 모듈을 제공합니다.",
} end)

L:RegisterTranslations("zhTW", function() return {
--	["Battlegrounds"] = true,
--	["Module which provides maps of battlegrounds."] = true,
} end)

L:RegisterTranslations("zhCN", function() return {
--	["Battlegrounds"] = true,
--	["Module which provides maps of battlegrounds."] = true,
} end)

Cartographer_Battlegrounds = Cartographer:NewModule("Battlegrounds", "AceHook-2.1", "AceEvent-2.0")

local lua51 = loadstring("return function(...) return ... end") and true or false
local BZ = AceLibrary("Babble-Zone-2.2")
local Tourist = AceLibrary("Tourist-2.0")

function Cartographer_Battlegrounds:OnInitialize()
	self.name = L["Battlegrounds"]
	self.title = L["Battlegrounds"]
	Cartographer.options.args.Battlegrounds = {
		name = L["Battlegrounds"],
		desc = L["Module which provides maps of battlegrounds."],
		type = 'group',
		args = {
			toggle = {
				name = AceLibrary("AceLocale-2.2"):new("Cartographer")["Active"],
				desc = AceLibrary("AceLocale-2.2"):new("Cartographer")["Suspend/resume this module."],
				type = "toggle",
				order = -1,
				get = function() return Cartographer:IsModuleActive(self) end,
				set = function() Cartographer:ToggleModuleActive(self) end
			},
		},
		handler = self,
	}
	
	local validate = {
		["Warsong Gulch"] = BZ["Warsong Gulch"],
		["Arathi Basin"] = BZ["Arathi Basin"],
		["Alterac Valley"] = BZ["Alterac Valley"],
		["Eye of the Storm"] = lua51 and BZ["Eye of the Storm"] or nil,
	}
	
	Cartographer.gotoOptions.args.Battlegrounds = {
		name = L["Battlegrounds"],
		desc = L["Battlegrounds"],
		type = 'text',
		get = function()
			return Cartographer:GetCurrentEnglishZoneName()
		end,
		set = "ShowBattleground",
		validate = validate,
		handler = self,
		hidden = function() return not Cartographer:IsModuleActive(self) end
	}
end

function Cartographer_Battlegrounds:OnEnable()
	self:Hook("SetMapZoom", true)
	self:Hook("SetMapToCurrentZone", true)
	self:Hook("GetMapInfo", true)
	self:RegisterEvent("Cartographer_ChangeZone")
	self:Hook("WorldMapZoomOutButton_OnClick", true)
end

local currentBG = nil
function Cartographer_Battlegrounds:ShowBattleground(name)
	local current = GetRealZoneText()
	current = BZ:HasReverseTranslation(current) and BZ:GetReverseTranslation(current)
	if current == name then
		currentBG = nil
		SetMapToCurrentZone()
		return
	end
	local realName = name
	if name == "Warsong Gulch" then
		name = "WarsongGulch"
	elseif name == "Arathi Basin" then
		name = "ArathiBasin"
	elseif name == "Alterac Valley" then
		name = "AlteracValley"
	elseif lua51 and name == "Eye of the Storm" then
		name = "NetherstormArena"
	else
		error(string.format("Cannot show unknown battleground %q", name), 2)
	end
	self.hooks.SetMapZoom(-1, nil)
	currentBG = name
	WorldMapFrame_Update()
	WorldMapZoomOutButton:Enable()
	self:TriggerEvent("Cartographer_ChangeZone", realName, BZ[realName])
	currentBG = name
end

function Cartographer_Battlegrounds:Cartographer_ChangeZone(zone)
	currentBG = nil
end

function Cartographer_Battlegrounds:SetMapZoom(a, b)
	currentBG = nil
	return self.hooks.SetMapZoom(a, b)
end

function Cartographer_Battlegrounds:SetMapToCurrentZone()
	currentBG = nil
	return self.hooks.SetMapToCurrentZone()
end

function Cartographer_Battlegrounds:GetMapInfo()
	if currentBG then
		return currentBG
	end
	return self.hooks.GetMapInfo()
end

function Cartographer_Battlegrounds:WorldMapZoomOutButton_OnClick()
	if not currentBG then
		return self.hooks.WorldMapZoomOutButton_OnClick()
	end
	currentBG = nil
	self.hooks.SetMapZoom(0)
end
