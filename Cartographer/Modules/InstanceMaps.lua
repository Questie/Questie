local revision = tonumber(string.sub("$Revision: 18625 $", 12, -3))
if revision > Cartographer.revision then
	Cartographer.version = "r" .. revision
	Cartographer.revision = revision
	Cartographer.date = string.sub("$Date: 2006-12-02 16:13:35 +0300 (Сб, 02 дек 2006) $", 8, 17)
end

local L = AceLibrary("AceLocale-2.2"):new("Cartographer-InstanceMaps")

L:RegisterTranslations("enUS", function() return {
	["Instance Maps"] = true,
	["Module which provides maps of instances."] = true,
	
	["Instances"] = true,
} end)

L:RegisterTranslations("deDE", function() return {
--	["Instance Maps"] = true,
--	["Module which provides maps of instances."] = true,
} end)

L:RegisterTranslations("frFR", function() return {
--	["Instance Maps"] = true,
--	["Module which provides maps of instances."] = true,
} end)

L:RegisterTranslations("koKR", function() return {
	["Instance Maps"] = "인스턴스 던전",
	["Module which provides maps of instances."] = "인스턴스 던전을 보여줍니다.",
	
	["Instances"] = "인스턴스",
} end)

L:RegisterTranslations("zhTW", function() return {
--	["Instance Maps"] = true,
--	["Module which provides maps of instances."] = true,
} end)

L:RegisterTranslations("zhCN", function() return {
--	["Instance Maps"] = true,
--	["Module which provides maps of instances."] = true,
} end)

Cartographer_InstanceMaps = Cartographer:NewModule("InstanceMaps", "AceHook-2.1")

local lua51 = loadstring("return function(...) return ... end") and true or false
local BZ = AceLibrary("Babble-Zone-2.2")
local Tourist = AceLibrary("Tourist-2.0")

UIDropDownMenu_CreateInfo = UIDropDownMenu_CreateInfo or loadstring("local t = {} return function() for k in pairs(t) do t[k] = nil end return t end")()

local instanceToTexture = {
	["Ahn'Qiraj"] = "TempleofAhnQiraj",
	["Blackfathom Deeps"] = "BlackfathomDeeps",
	["Blackrock Depths"] = "BlackrockDepths",
	["Blackwing Lair"] = "BlackwingLair",
	["Dire Maul"] = "DireMaul",
	["Dire Maul (East)"] = "DireMaulEast",
	["Dire Maul (North)"] = "DireMaulNorth",
	["Dire Maul (West)"] = "DireMaulWest",
	["Gnomeregan"] = "Gnomeregan",
	["Lower Blackrock Spire"] = "BlackrockSpireLower",
	["Maraudon"] = "Maraudon",
	["Molten Core"] = "MoltenCore",
	["Naxxramas"] = "Naxxramas",
	["Onyxia's Lair"] = "OnyxiasLair",
	["Ragefire Chasm"] = "RagefireChasm",
	["Razorfen Downs"] = "RazorfenDowns",
	["Razorfen Kraul"] = "RazorfenKraul",
	["Ruins of Ahn'Qiraj"] = "RuinsofAhnQiraj",
	["Scarlet Monastery"] = "ScarletMonastery",
	["Scholomance"] = "Scholomance",
	["Shadowfang Keep"] = "ShadowfangKeep",
	["Stratholme"] = "Stratholme",
	["The Deadmines"] = "TheDeadmines",
	["The Stockade"] = "TheStockades",
	["The Temple of Atal'Hakkar"] = "TheSunkenTemple",
	["Uldaman"] = "Uldaman",
	["Upper Blackrock Spire"] = "BlackrockSpireUpper",
	["Wailing Caverns"] = "WailingCaverns",
	["Zul'Farrak"] = "ZulFarrak",
	["Zul'Gurub"] = "ZulGurub",
}

function Cartographer_InstanceMaps:OnInitialize()
	self.name = L["Instance Maps"]
	self.title = L["Instance Maps"]
	Cartographer.options.args.InstanceMaps = {
		name = L["Instance Maps"],
		desc = L["Module which provides maps of instances."],
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
	
	local validate = {}
	for k,v in pairs(instanceToTexture) do
		validate[k] = BZ[k]
	end
	
	Cartographer.gotoOptions.args.Instances = {
		name = L["Instances"],
		desc = L["Instances"],
		type = 'text',
		get = function()
			return Cartographer:GetCurrentInstance()
		end,
		set = "ShowInstance",
		validate = validate,
		handler = self,
		hidden = function() return not Cartographer:IsModuleActive(self) end
	}
end

local CartographerInstanceFrame
function Cartographer_InstanceMaps:OnEnable()
	self:Hook("WorldMapFrame_LoadContinents", true)
	self:Hook("WorldMapFrame_LoadZones", true)
	self:SecureHook("SetMapZoom")
	self:Hook("SetMapToCurrentZone", true)
end

function Cartographer_InstanceMaps:OnDisable()
	self:HideInstanceFrame()
end

function Cartographer_InstanceMaps:SetMapToCurrentZone()
	local zoneText = GetRealZoneText()
	if zoneText == BZ["Blackrock Spire"] then
		zoneText = BZ["Upper Blackrock Spire"]
	end
	if IsInInstance() and BZ:HasReverseTranslation(zoneText) and instanceToTexture[BZ:GetReverseTranslation(zoneText)] then
		self:ShowInstance(BZ:GetReverseTranslation(zoneText))
	else
		self:HideInstanceFrame()
		return self.hooks.SetMapToCurrentZone()
	end
end

function Cartographer_InstanceMaps:ShowInstanceFrame()
	if not CartographerInstanceFrame then
		CartographerInstanceFrame = CreateFrame("Button", "CartographerInstanceFrame", WorldMapFrame)
		CartographerInstanceFrame:SetPoint("CENTER", WorldMapButton, "CENTER")
		CartographerInstanceFrame:SetWidth(WorldMapButton:GetWidth())
		CartographerInstanceFrame:SetHeight(WorldMapButton:GetHeight())
		CartographerInstanceFrame:Hide()
		CartographerInstanceFrame:RegisterForClicks("LeftButtonUp", "RightButtonUp")
		CartographerInstanceFrame:SetScript("OnClick", function()
			if arg1 == "RightButton" then
				local zone = BZ[Cartographer:GetCurrentInstance()]
				if Tourist:IsInKalimdor(zone) then
					SetMapZoom(1)
				elseif Tourist:IsInEasternKingdoms(zone) then
					SetMapZoom(2)
				elseif Tourist:IsInOutland(zone) then
					SetMapZoom(3)
				else
					SetMapZoom(0)
				end
			end
		end)
		local bgf = CreateFrame("Frame", nil, WorldMapFrame)
		local bg = bgf:CreateTexture(nil, "BACKGROUND")
		CartographerInstanceFrame.backgroundframe = bgf
		bgf:Hide()
		CartographerInstanceFrame.background = bg
		bg:SetTexture(0,0,0)
		bg:SetPoint("CENTER", CartographerInstanceFrame, "CENTER")
		bg:SetWidth(CartographerInstanceFrame:GetWidth())
		bg:SetHeight(CartographerInstanceFrame:GetHeight())
		local texture = CartographerInstanceFrame:CreateTexture(nil, "ARTWORK")
		CartographerInstanceFrame.texture = texture
		texture:SetPoint("CENTER", CartographerInstanceFrame, "CENTER")
		Cartographer:RegisterInstanceWorldMapButton(CartographerInstanceFrame)
	end
	if CartographerInstanceFrame:IsShown() then
		return
	end
	CartographerInstanceFrame:Show()
	CartographerInstanceFrame.backgroundframe:Show()
	WorldMapDetailFrame:Hide()
	WorldMapButton:Hide()
	ShowWorldMapArrowFrame(nil)
end

function Cartographer_InstanceMaps:HideInstanceFrame()
	Cartographer:SetCurrentInstance(nil)
	if not CartographerInstanceFrame or not CartographerInstanceFrame:IsShown() then
		return
	end
	CartographerInstanceFrame:Hide()
	CartographerInstanceFrame.backgroundframe:Hide()
	WorldMapDetailFrame:Show()
	WorldMapButton:Show()
	ShowWorldMapArrowFrame(1)
end

function Cartographer_InstanceMaps.instance_func()
	Cartographer_InstanceMaps.instances_id = this and this:GetID() or 0
	UIDropDownMenu_SetSelectedID(WorldMapContinentDropDown, Cartographer_InstanceMaps.instances_id)
	UIDropDownMenu_SetSelectedID(WorldMapZoneDropDown, 0)
	UIDropDownMenu_SetText("", WorldMapZoneDropDown)
end

Cartographer_InstanceMaps.WorldMapFrame_LoadContinents = lua51 and loadstring([[local L = AceLibrary("AceLocale-2.2"):new("Cartographer-InstanceMaps"); return function(self, ...)
	self.hooks.WorldMapFrame_LoadContinents(...)
	local info = UIDropDownMenu_CreateInfo()
	info.text = L["Instances"]
	info.func = Cartographer_InstanceMaps.instance_func
	info.checked = nil
	UIDropDownMenu_AddButton(info)
end]])() or loadstring([[local L = AceLibrary("AceLocale-2.2"):new("Cartographer-InstanceMaps"); return function(self, ...)
	while arg[arg.n] == nil do
		arg.n = arg.n - 1
	end
	self.hooks.WorldMapFrame_LoadContinents(unpack(arg))
	local info = UIDropDownMenu_CreateInfo()
	info.text = L["Instances"]
	info.func = Cartographer_InstanceMaps.instance_func
	info.checked = nil
	UIDropDownMenu_AddButton(info)
end]])()

Cartographer_InstanceMaps.WorldMapFrame_LoadZones = lua51 and loadstring([[return function(self, ...)
	if UIDropDownMenu_GetSelectedID(WorldMapContinentDropDown) ~= self.instances_id then
		return self.hooks.WorldMapFrame_LoadZones(...)
	end
	self:LoadInstancesToDropDown()
end]])() or loadstring([[return function(self, ...)
	if UIDropDownMenu_GetSelectedID(WorldMapContinentDropDown) ~= self.instances_id then
		return self.hooks.WorldMapFrame_LoadZones(unpack(arg))
	end
	self:LoadInstancesToDropDown()
end]])()

function Cartographer_InstanceMaps:ShowInstance(realZone)
	if not instanceToTexture[realZone] then
		return
	end
	local id = this and this:GetID() or 0
	local zone = BZ[realZone]
	if Tourist:IsInKalimdor(zone) then
		SetMapZoom(1, 1)
	elseif Tourist:IsInEasternKingdoms(zone) then
		SetMapZoom(2, 1)
	elseif Tourist:IsInOutland(zone) then
		SetMapZoom(3, 1)
	else
		SetMapZoom(0)
	end
	Cartographer_InstanceMaps:ShowInstanceFrame()
	UIDropDownMenu_SetSelectedID(WorldMapContinentDropDown, self.instances_id)
	UIDropDownMenu_SetText(L["Instances"], WorldMapContinentDropDown)
	UIDropDownMenu_SetSelectedID(WorldMapZoneDropDown, id)
	UIDropDownMenu_SetText(zone, WorldMapZoneDropDown)
	Cartographer:SetCurrentInstance(realZone)
	CartographerInstanceFrame.texture:SetWidth(0)
	CartographerInstanceFrame.texture:SetHeight(0)
	CartographerInstanceFrame.texture:SetTexture("Interface\\AddOns\\Cartographer\\Instances\\" .. instanceToTexture[realZone])
	local currWidth, currHeight = CartographerInstanceFrame.texture:GetWidth(), CartographerInstanceFrame.texture:GetHeight()
	if currWidth == 0 then
		currWidth, currHeight = 512, 512
	end
	local newHeight = CartographerInstanceFrame:GetHeight()/CartographerInstanceFrame:GetScale() * 0.95
	local newWidth = currWidth*newHeight/currHeight
	CartographerInstanceFrame.texture:SetWidth(newWidth)
	CartographerInstanceFrame.texture:SetHeight(newHeight)
end

local t
function Cartographer_InstanceMaps:LoadInstancesToDropDown()
	if not t then
		t = {}
		for k in pairs(instanceToTexture) do
			table.insert(t, BZ[k])
		end
		table.sort(t)
		for i,v in ipairs(t) do
			t[i] = BZ:GetReverseTranslation(v)
		end
	end
	local info = UIDropDownMenu_CreateInfo()
	info.arg1 = self
	info.func = self.ShowInstance
	for i,v in pairs(t) do
		info.text = BZ[v]
		info.arg2 = v
		info.checked = nil
		UIDropDownMenu_AddButton(info)
	end
end

function Cartographer_InstanceMaps:SetMapZoom()
	self:HideInstanceFrame()
	if GetCurrentMapZone() == 0 then
		UIDropDownMenu_SetText("", WorldMapZoneDropDown)
	end
end
