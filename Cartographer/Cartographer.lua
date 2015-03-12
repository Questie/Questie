Cartographer = AceLibrary("AceAddon-2.0"):new("AceEvent-2.0", "AceDB-2.0", "AceModuleCore-2.0", "AceHook-2.1")
Cartographer.revision = tonumber(string.sub("$Revision: 18624 $", 12, -3))
Cartographer.version = "r" .. Cartographer.revision
Cartographer.date = string.sub("$Date: 2006-12-02 16:07:22 +0300 (Сб, 02 дек 2006) $", 8, 17)

local Dewdrop = AceLibrary("Dewdrop-2.0")

local L = AceLibrary("AceLocale-2.2"):new("Cartographer")
local BZ = AceLibrary("Babble-Zone-2.2")

BINDING_HEADER_CARTOGRAPHER = "Cartographer"
BINDING_NAME_CARTOGRAPHER_OPENALTERNATEMAP = "Open alternate map"

L:RegisterTranslations("enUS", function() return {
	["Active"] = true,
	["Suspend/resume this module."] = true,
	
	["Right-Click on map to zoom out"] = true,
	["Left-Click on map to zoom in"] = true,
	
	["Go to %s"] = true,
	
	["Azeroth"] = true,
	["Cosmic map"] = true,
} end)

L:RegisterTranslations("deDE", function() return {
--	["Toggle"] = true,
--	["Toggle the module on and off."] = true,
} end)

L:RegisterTranslations("frFR", function() return {
--	["Toggle"] = true,
--	["Toggle the module on and off."] = true,
} end)

L:RegisterTranslations("koKR", function() return {
	["Active"] = "활성화",
	["Suspend/resume this module."] = "모듈을 켜거나 끔니다.",
	
	["Right-Click on map to zoom out"] = "오른쪽-클릭 : 축소",
	["Left-Click on map to zoom in"] = "왼쪽-클릭 : 확대",
	
	["Go to %s"] = "%s 바로가기",
	
	["Azeroth"] = "아제로스",
	["Cosmic map"] = "세계 지도",
} end)

L:RegisterTranslations("zhCN", function() return {
--	["Toggle"] = true,
--	["Toggle the module on and off."] = true,
} end)

L:RegisterTranslations("zhTW", function() return {
--	["Toggle"] = true,
--	["Toggle the module on and off."] = true,
} end)

Cartographer:RegisterDB("CartographerDB")

Cartographer.options = {
	type = 'group',
	args = {
	},
}
Dewdrop:InjectAceOptionsTable(Cartographer, Cartographer.options)
Cartographer.options.args.standby = nil

function Cartographer:OnInitialize()
	self.gotoOptions = {
		type = 'group',
		args = {
			player = {
				name = string.format(L["Go to %s"], GetRealZoneText()),
				desc = string.format(L["Go to %s"], GetRealZoneText()),
				type = 'execute',
				func = function()
					SetMapToCurrentZone()
				end,
				order = 1
			}
		},
	}
	
	for i,continent in ipairs { GetMapContinents() } do
		local i = i
		local validate = { GetMapZones(i) }
		self.gotoOptions.args[string.gsub(continent, " ", "-")] = {
			name = continent,
			desc = continent,
			type = 'text',
			validate = validate,
			get = function() return self:GetCurrentInstance() or GetCurrentMapContinent() == i and validate[GetCurrentMapZone()] end,
			set = function(text)
				for j,v in ipairs(validate) do
					if v == text then
						SetMapZoom(i, j)
						break
					end
				end
			end,
		}
	end
	
	if not GetBindingAction("ALT-M") and not GetBindingKey("CARTOGRAPHER_OPENALTERNATEMAP") then
		SetBinding("ALT-M", "CARTOGRAPHER_OPENALTERNATEMAP")
	end
end

local magnifyingGlassTexts = { L["Right-Click on map to zoom out"], L["Left-Click on map to zoom in"] }
function Cartographer:OnEnable()
	WorldMapContinentDropDown:Hide()
	WorldMapZoneDropDown:Hide()
	
	local button = CreateFrame("Button", "CartographerOptionsButton", WorldMapFrame, "UIPanelButtonTemplate")
	button:SetText("Cartographer")
	local width = button:GetTextWidth() + 30
	if width < 110 then
		width = 110
	end
	button:SetWidth(width)
	button:SetHeight(22)
	WorldMapZoomOutButton:Hide()
	button:SetPoint("BOTTOM", WorldMapZoomOutButton, "BOTTOM", 0, 0)
	button:SetPoint("RIGHT", WorldMapDetailFrame, "RIGHT", -5, 0)
	button:SetScript("OnClick", function()
		Dewdrop:Register(this,
			'children', self.options,
			'dontHook', true,
			'point', "TOPRIGHT",
			'relativePoint', "BOTTOMRIGHT"
		)
		this:SetScript("OnClick", function()
			if Dewdrop:IsOpen(this) then
				Dewdrop:Close()
			else
				Dewdrop:Open(this)
			end
		end)
		this:GetScript("OnClick")()
	end)
	
	local CartographerGoToButton = CreateFrame("Button", "CartographerGoToButton", WorldMapFrame, "UIPanelButtonTemplate")
	CartographerGoToButton:SetText(UNKNOWN)
	local width = CartographerGoToButton:GetTextWidth() + 30
	if width < 220 then
		width = 220
	end
	CartographerGoToButton:SetWidth(width)
	CartographerGoToButton:SetHeight(22)
	CartographerGoToButton:SetPoint("BOTTOM", WorldMapZoomOutButton, "BOTTOM", 0, 0)
	CartographerGoToButton:SetPoint("LEFT", WorldMapDetailFrame, "LEFT", 5, 0)
	CartographerGoToButton:SetScript("OnClick", function()
		Dewdrop:Register(this,
			'children', self.gotoOptions,
			'dontHook', true,
			'point', "TOPRIGHT",
			'relativePoint', "BOTTOMRIGHT"
		)
		this:SetScript("OnClick", function()
			if Dewdrop:IsOpen(this) then
				Dewdrop:Close()
			else
				Dewdrop:Open(this)
			end
		end)
		this:GetScript("OnClick")()
	end)
	
	self:Hook(WorldMapFrame, "Hide", "WorldMapFrame_Hide", true)
	self:Hook(WorldMapFrame, "Show", "WorldMapFrame_Show", true)
	self:RegisterEvent("Cartographer_MapClosed")
	self:RegisterEvent("Cartographer_ChangeZone")
	self:RegisterEvent("WORLD_MAP_UPDATE")
	self:Cartographer_ChangeZone(self:GetCurrentEnglishZoneName(), self:GetCurrentLocalizedZoneName())
	
	WorldMapMagnifyingGlassButton:SetText(table.concat(magnifyingGlassTexts, "\n"))
end

function Cartographer:WorldMapFrame_Hide(this)
	local shown = WorldMapFrame:IsShown()
	self.hooks[this].Hide(this)
	if shown then
		self:TriggerEvent("Cartographer_MapClosed")
	end
end

function Cartographer:WorldMapFrame_Show(this)
	local shown = WorldMapFrame:IsShown()
	self.hooks[this].Show(this)
	if not shown then
		self:TriggerEvent("Cartographer_MapOpened")
	end
end

function Cartographer:WORLD_MAP_UPDATE()
	self:TriggerEvent("Cartographer_ChangeZone", self:GetCurrentEnglishZoneName(), self:GetCurrentLocalizedZoneName())
end

function Cartographer:Cartographer_MapClosed()
	if Dewdrop:IsOpen(CartographerGoToButton) or Dewdrop:IsOpen(CartographerOptionsButton) then
		Dewdrop:Close()
	end
	SetMapToCurrentZone()
end

local continents = { GetMapContinents() }
continents[0] = L["Azeroth"]
continents[-1] = L["Cosmic map"]

function Cartographer:Cartographer_ChangeZone(zone, localZone)
	if localZone then
		CartographerGoToButton:SetText(localZone)
		Cartographer.gotoOptions.args.player.name = string.format(L["Go to %s"], GetRealZoneText())
		Cartographer.gotoOptions.args.player.desc = Cartographer.gotoOptions.args.player.name
	else
		CartographerGoToButton:SetText(continents[GetCurrentMapContinent()] or UNKNOWN)
	end
end

function Cartographer:OnProfileEnable(alpha, bravo)
	for _,module in self:IterateModules() do
		if self:IsModuleActive(module) and type(module.OnProfileEnable) == "function" then
			module:OnProfileEnable(alpha, bravo)
		end
	end
end

function Cartographer:AddToMagnifyingGlass(text)
	for _,v in ipairs(magnifyingGlassTexts) do
		if v == text then
			error(string.format("Cannot add %q to magnifying glass, it already exists", text), 2)
		end
	end
	table.insert(magnifyingGlassTexts, text)
	WorldMapMagnifyingGlassButton:SetText(table.concat(magnifyingGlassTexts, "\n"))
end

function Cartographer:RemoveFromMagnifyingGlass(text)
	local id
	for i,v in ipairs(magnifyingGlassTexts) do
		if v == text then
			id = i
			break
		end
	end
	if not id then
		error(string.format("Cannot remove %q from magnifying glass, it does not exist", text), 2)
	end
	table.remove(magnifyingGlassTexts, id)
	
	WorldMapMagnifyingGlassButton:SetText(table.concat(magnifyingGlassTexts, "\n"))
end

local currentInstance
function Cartographer:SetCurrentInstance(zone)
	if currentInstance ~= zone then
		currentInstance = zone
		self:TriggerEvent("Cartographer_SetCurrentInstance", zone)
		self:TriggerEvent("Cartographer_ChangeZone", self:GetCurrentEnglishZoneName(), self:GetCurrentLocalizedZoneName())
	end
end

function Cartographer:GetCurrentInstance()
	return currentInstance
end

local instanceWorldMapButton
function Cartographer:RegisterInstanceWorldMapButton(frame)
	instanceWorldMapButton = frame
	self:TriggerEvent("Cartographer_RegisterInstanceWorldMapButton", frame)
end

function Cartographer:GetInstanceWorldMapButton()
	return instanceWorldMapButton
end

local mapZones = setmetatable({}, {__index = function(self, key)
	self[key] = { GetMapZones(key) }
	return self[key]
end })

function Cartographer:GetCurrentLocalizedZoneName()
	if currentInstance then
		return BZ[currentInstance]
	end
	local z = mapZones[GetCurrentMapContinent()][GetCurrentMapZone()]
	if z then
		return z
	else
		local map = GetMapInfo()
		if map == "WarsongGulch" then
			return BZ["Warsong Gulch"]
		elseif map == "ArathiBasin" then
			return BZ["Arathi Basin"]
		elseif map == "AlteracValley" then
			return BZ["Alterac Valley"]
		elseif map == "NetherstormArena" then
			return BZ["Eye of the Storm"]
		end
		return nil
	end
end

function Cartographer:GetCurrentEnglishZoneName()
	if currentInstance then
		return currentInstance
	end
	local z = mapZones[GetCurrentMapContinent()][GetCurrentMapZone()]
	if z then
		return BZ:GetReverseTranslation(z)
	else
		local map = GetMapInfo()
		if map == "WarsongGulch" then
			return "Warsong Gulch"
		elseif map == "ArathiBasin" then
			return "Arathi Basin"
		elseif map == "AlteracValley" then
			return "Alterac Valley"
		elseif map == "NetherstormArena" then
			return "Eye of the Storm"
		end
		return nil
	end
end

function Cartographer:OpenAlternateMap()
	if self:GetProfile() == "Default" or self:GetProfile() == "Alternate" then
		self:SetProfile(self:GetProfile() == "Default" and "Alternate" or "Default")
	end
	
	if not WorldMapFrame:IsShown() then
		ToggleWorldMap()
	end
end
