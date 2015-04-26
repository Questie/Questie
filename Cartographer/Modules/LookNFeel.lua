local revision = tonumber(string.sub("$Revision: 18625 $", 12, -3))
if revision > Cartographer.revision then
	Cartographer.version = "r" .. revision
	Cartographer.revision = revision
	Cartographer.date = string.sub("$Date: 2006-12-02 16:13:35 +0300 (Сб, 02 дек 2006) $", 8, 17)
end

local L = AceLibrary("AceLocale-2.2"):new("Cartographer-LookNFeel")

L:RegisterTranslations("enUS", function() return {
	["Look 'n' Feel"] = true,
	["Module which allows you to change the transparency, position, and scale of the world map."] = true,
	
	["Transparency"] = true,
	["Transparency of the World Map"] = true,
	
	["Overlay transparency"] = true,
	["Transparency of World Map overlays"] = true,
	
	["Scale"] = true,
	["Scale of the World Map"] = true,
	
	["Tooltip scale"] = true,
	["Scale of the World Map tooltip"] = true,
	
	["Shift-MouseWheel to change transparency"] = true,
	["Ctrl-MouseWheel to change scale"] = true,
	
	["Lock the World Map"] = true,
	
	["Close with escape"] = true,
	["Close the World Map when pressing the escape button"] = true,
	
	["Large player arrow"] = true,
	["Make the player's arrow on the World Map 1.5 times larger than normal"] = true,
} end)

L:RegisterTranslations("koKR", function() return {
	["Look 'n' Feel"] = "모양",
	["Module which allows you to change the transparency, position, and scale of the world map."] = "세계 지도의 투명도, 위치 그리고 크기등을 변경합니다.",
	
	["Transparency"] = "투명도",
	["Transparency of the World Map"] = "세계 지도의 투명도를 설정합니다.",
	
	["Overlay transparency"] = "오버레이 투명도",
	["Transparency of World Map overlays"] = "세계 지도 오버레이의 투명도를 설정합니다.",
	
	["Scale"] = "크기",
	["Scale of the World Map"] = "세계 지도의 크기를 설정합니다.",
	
	["Tooltip scale"] = "툴팁 크기",
	["Scale of the World Map tooltip"] = "세계 지도의 툴팁 크기를 설정합니다.",
	
	["Shift-MouseWheel to change transparency"] = "Shift-스크롤 : 투명도 변경",
	["Ctrl-MouseWheel to change scale"] = "Ctrl-스크롤 : 크기 변경",
	
	["Lock the World Map"] = "세계 지도의 위치를 잠금니다.",
	
	["Close with escape"] = "Esc 닫기",
	["Close the World Map when pressing the escape button"] = "Esc 버튼을 누루면 세계 지도를 닫습니다.",
	
	["Large player arrow"] = "플레이어 위치 크게",
	["Make the player's arrow on the World Map 1.5 times larger than normal"] = "1.5배 정도 플레이어 위치를 좀더 크게 표시합니다.",
} end)

Cartographer_LookNFeel = Cartographer:NewModule("LookNFeel", "AceEvent-2.0", "AceHook-2.1")

local _G = getfenv(0)
local lua51 = loadstring("return function(...) return ... end") and true or false
local math_mod = lua51 and math.fmod or math.mod

local fake_ipairs = lua51 and loadstring([[local tmp = {}; return function(...)
	for k in pairs(tmp) do
		tmp[k] = nil
	end
	for i = 1, select('#', ...) do
		tmp[i] = select(i, ...)
	end
	return ipairs(tmp)
end]])() or loadstring([[local tmp = {}; return function(a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16,a17,a18,a19,a20)
	for k in pairs(tmp) do
		tmp[k] = nil
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
	tmp.n = 20
	while tmp[tmp.n] == nil do
		tmp.n = tmp.n - 1
	end
	return ipairs(tmp)
end]])()

function Cartographer_LookNFeel:OnInitialize()
	self.db = Cartographer:AcquireDBNamespace("LookNFeel")
	self.name = L["Look 'n' Feel"]
	self.title = L["Look 'n' Feel"]
	
	Cartographer:RegisterDefaults("LookNFeel", "profile", {
		alpha = 0.8,
		overlayAlpha = 1,
		scale = 0.75,
		ttScale = 1,
		locked = false,
		useEscape = true,
		largePlayer = true,
	})
	
	Cartographer.options.args.LookNFeel = {
		name = L["Look 'n' Feel"],
		desc = L["Module which allows you to change the transparency, position, and scale of the world map."],
		type = 'group',
		args = {
			alpha = {
				name = L["Transparency"],
				desc = L["Transparency of the World Map"],
				type = 'range',
				min = 0,
				max = 1,
				step = 0.05,
				isPercent = true,
				get = "GetAlpha",
				set = "SetAlpha",
			},
			overlayAlpha = {
				name = L["Overlay transparency"],
				desc = L["Transparency of World Map overlays"],
				type = 'range',
				min = 0.25,
				max = 1,
				step = 0.05,
				isPercent = true,
				get = "GetOverlayAlpha",
				set = "SetOverlayAlpha",
			},
			scale = {
				name = L["Scale"],
				desc = L["Scale of the World Map"],
				type = 'range',
				min = 0.2,
				max = 1,
				step = 0.05,
				isPercent = true,
				get = "GetScale",
				set = "SetScale",
			},
			ttScale = {
				name = L["Tooltip scale"],
				desc = L["Scale of the World Map tooltip"],
				type = 'range',
				min = 0.2,
				max = 2,
				step = 0.05,
				isPercent = true,
				get = "GetTooltipScale",
				set = "SetTooltipScale",
			},
			lock = {
				name = LOCK or "Lock",
				desc = L["Lock the World Map"],
				type = 'toggle',
				get = "IsLocked",
				set = "ToggleLocked",
			},
			useEscape = {
				name = L["Close with escape"],
				desc = L["Close the World Map when pressing the escape button"],
				type = 'toggle',
				get = "IsUsingEscape",
				set = "ToggleUsingEscape",
			},
			largePlayer = {
				name = L["Large player arrow"],
				desc = L["Make the player's arrow on the World Map 1.5 times larger than normal"],
				type = 'toggle',
				get = "IsLargePlayerPOI",
				set = "ToggleLargePlayerPOI",
			},
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
	
	local orig = WorldMapFrame:GetScript("OnShow") or function() end
	WorldMapFrame:SetScript("OnShow", function()
		orig(this)
		
		if Cartographer:IsModuleActive(self) then
			this:SetScale(self.db.profile.scale)
			WorldMapTooltip:SetScale(self.db.profile.ttScale / self.db.profile.scale)
			this:SetWidth(1024)
			this:SetHeight(768)
		end
	end)
	
	for i = 1, 12 do
		local tex = _G["WorldMapDetailTile" .. i]
		local x = tex:GetLeft() - WorldMapDetailFrame:GetLeft()
		local y = tex:GetTop() - WorldMapDetailFrame:GetTop()
		tex:ClearAllPoints()
		tex:SetPoint("TOPLEFT", WorldMapDetailFrame, "TOPLEFT", x, y)
	end
end

local cities = {
	["ThunderBluff"] = true,
	["Ogrimmar"] = true,
	["TheExodar"] = true,
	["Darnassis"] = true,
	["Undercity"] = true,
	["Ironforge"] = true,
	["Stormwind"] = true,
	["SilvermoonCity"] = true,
	["ShattrathCity"] = true,
}

function Cartographer_LookNFeel:OnEnable()
	Cartographer:AddToMagnifyingGlass(L["Shift-MouseWheel to change transparency"])
	Cartographer:AddToMagnifyingGlass(L["Ctrl-MouseWheel to change scale"])
	UIPanelWindows["WorldMapFrame"] = nil
	WorldMapFrame:SetFrameStrata("HIGH")
	WorldMapFrame:EnableMouse(not self.db.profile.locked)
	WorldMapFrame:EnableMouseWheel(not self.db.profile.locked)
	WorldMapButton:EnableMouse(not self.db.profile.locked)
	WorldMapMagnifyingGlassButton:EnableMouse(not self.db.profile.locked)
	WorldMapFrame:SetMovable(true)
	WorldMapFrame:RegisterForDrag("LeftButton")
	WorldMapFrame:SetScript("OnDragStart", function()
		this:SetWidth(1024)
		this:SetHeight(768)
		this:StartMoving()
	end)
	WorldMapFrame:SetScript("OnDragStop", function()
		this:StopMovingOrSizing()
		
		this:SetWidth(1024)
		this:SetHeight(768)
		local x,y = this:GetCenter()
		local z = UIParent:GetEffectiveScale() / 2 / this:GetScale()
		x = x - GetScreenWidth() * z
		y = y - GetScreenHeight() * z
		self.db.profile.x = x
		self.db.profile.y = y
		this:ClearAllPoints()
		this:SetPoint("CENTER", "UIParent", "CENTER", x, y)
	end)
	WorldMapFrame:SetScript("OnMouseWheel", function()
		local up = (arg1 == 1)
		
		if IsControlKeyDown() then
			local scale = self:GetScale()
			if up then
				scale = scale + 0.1
				if scale > 1 then
					scale = 1
				end
			else
				scale = scale - 0.1
				if scale < 0.2 then
					scale = 0.2
				end
			end
			self:SetScale(scale)
		elseif IsShiftKeyDown() then
			local alpha = self:GetAlpha()
			if up then
				alpha = alpha + 0.1
				if alpha > 1 then
					alpha = 1
				end
			else
				alpha = alpha - 0.1
				if alpha < 0 then
					alpha = 0
				end
			end
			self:SetAlpha(alpha)
		end
	end)
	WorldMapFrame:SetResizable(true)
	WorldMapFrame:SetAlpha(self.db.profile.alpha)
	WorldMapFrame:SetScale(self.db.profile.scale)
	WorldMapTooltip:SetScale(self.db.profile.ttScale / self.db.profile.scale)
	WorldMapFrame:SetWidth(1024)
	WorldMapFrame:SetHeight(768)
	self.old_WorldMapFrame_OnKeyDown = WorldMapFrame:GetScript("OnKeyDown")
	WorldMapFrame:SetScript("OnKeyDown", nil)
	WorldMapFrame:StartMoving()
	WorldMapFrame:StopMovingOrSizing()
	WorldMapFrame:ClearAllPoints()
	WorldMapFrame:SetPoint("CENTER", UIParent, "CENTER", self.db.profile.x or 0, self.db.profile.y or 0)
	BlackoutWorld:Hide()
	WorldMapTooltip:SetFrameLevel(WorldMapFrame:GetFrameLevel() + 3)
	self:SecureHook(WorldMapDetailFrame, "CreateTexture", "WorldMapDetailFrame_CreateTexture")
	self:RegisterEvent("Cartographer_ChangeZone")
	self:RegisterEvent("MODIFIER_STATE_CHANGED")
	self:SecureHook("WorldMapButton_OnUpdate")
	self:Hook(lua51 and "CloseSpecialWindows" or "CloseWindows", true)
	if not self.overlayHolder then
		self.overlayHolder = CreateFrame("Frame", "CartographerLookNFeelOverlayHolder", WorldMapDetailFrame)
		self.overlayHolder:SetPoint("TOPLEFT", WorldMapDetailFrame, "TOPLEFT")
		self.overlayHolder:SetPoint("BOTTOMRIGHT", WorldMapDetailFrame, "BOTTOMRIGHT")
		self.overlayHolder:SetFrameLevel(WorldMapDetailFrame:GetFrameLevel())
	end
	self.overlayHolder:Show()
	
	self.overlayHolder:SetAlpha(self.db.profile.overlayAlpha)
	WorldMapButton:SetAlpha(self.db.profile.overlayAlpha)
	for i,v in fake_ipairs(WorldMapFrame:GetChildren()) do
		if v:GetName() and string.find(v:GetName(), "^Cartographer") then
			v:SetAlpha(self.db.profile.overlayAlpha)
		end
	end
	if not self.playerModel then
		for _,v in fake_ipairs(WorldMapFrame:GetChildren()) do
			if v:GetFrameType() == "Model" and not v:GetName() then
				self.playerModel = v
				break
			end
		end
	end
	self.playerModel:SetAlpha(self.db.profile.overlayAlpha)
	
	if (GetCurrentMapZone() == 0 or cities[GetMapInfo()]) and self.db.profile.overlayAlpha > self.db.profile.alpha then
		WorldMapDetailFrame:SetAlpha(self.db.profile.overlayAlpha)
	else
		WorldMapDetailFrame:SetAlpha(self.db.profile.alpha)
	end
	
	for i = 1, 1000 do
		local texture = _G["WorldMapOverlay" .. i]
		if not texture then
			break
		end
		texture:SetParent(self.overlayHolder)
	end
	
	WorldMapButton:SetScript("OnEnter", function()
		WorldMapFrameAreaLabel:Show()
	end)
	local function f()
		if MouseIsOver(WorldMapButton) and not Cartographer:GetCurrentInstance() then
			WorldMapFrameAreaLabel:Show()
			self:ScheduleEvent("Cartographer-LookNFeel-WorldMapButton-OnLeave", f, 0.25)
			return
		end
		WorldMapFrameAreaLabel:Hide()
	end
	WorldMapButton:SetScript("OnLeave", f)
	if MouseIsOver(WorldMapButton) and not Cartographer:GetCurrentInstance() then
		WorldMapFrameAreaLabel:Show()
	else
		WorldMapFrameAreaLabel:Hide()
	end
	
	self.playerModel:SetModelScale(self.db.profile.largePlayer and 1.5 or 1)
	
	if WorldMapFrame:IsShown() then
		ToggleWorldMap()
		ToggleWorldMap()
	end
end

function Cartographer_LookNFeel:OnDisable()
	Cartographer:RemoveFromMagnifyingGlass(L["Shift-MouseWheel to change transparency"])
	Cartographer:RemoveFromMagnifyingGlass(L["Ctrl-MouseWheel to change scale"])
	UIPanelWindows["WorldMapFrame"] = { whileDead=1, area="full", pushable=0 }
	WorldMapFrame:SetFrameStrata("FULLSCREEN")
	WorldMapFrame:EnableMouse(false)
	WorldMapFrame:EnableMouseWheel(false)
	WorldMapButton:EnableMouse(true)
	WorldMapMagnifyingGlassButton:EnableMouse(true)
	WorldMapFrame:SetScript("OnDragStart", nil)
	WorldMapFrame:SetScript("OnDragStop", nil)
	WorldMapFrame:SetScript("OnMouseWheel", nil)
	WorldMapFrame:StartMoving()
	WorldMapFrame:StopMovingOrSizing()
	WorldMapFrame:SetScale(1)
	WorldMapFrame:SetAlpha(1)
	WorldMapTooltip:SetScale(1)
	WorldMapFrame:StartMoving()
	WorldMapFrame:StopMovingOrSizing()
	WorldMapFrame:ClearAllPoints()
	WorldMapFrame:SetAllPoints(UIParent)
	WorldMapFrame:SetScript("OnKeyDown", self.old_WorldMapFrame_OnKeyDown)
	WorldMapFrame:EnableMouse(false)
	WorldMapFrame:SetMovable(false)
	WorldMapFrame:SetResizable(false)
	self.old_WorldMapFrame_OnKeyDown = nil
	for i = 1, 1000 do
		local texture = _G["WorldMapOverlay" .. i]
		if not texture then
			break
		end
		texture:SetParent(WorldMapDetailFrame)
	end
	self.overlayHolder:Hide()
	BlackoutWorld:Show()
	WorldMapTooltip:SetFrameLevel(WorldMapFrame:GetFrameLevel() + 2)
	WorldMapFrameAreaLabel:Show()
	WorldMapButton:SetScript("OnEnter", nil)
	WorldMapButton:SetScript("OnLeave", nil)
	self.playerModel:SetModelScale(1)
	if WorldMapFrame:IsShown() then
		ToggleWorldMap()
		ToggleWorldMap()
	end
end

function Cartographer_LookNFeel:MODIFIER_STATE_CHANGED()
	if self.db.profile.locked then
		if IsAltKeyDown() then
			WorldMapFrame:EnableMouse(true)
			WorldMapFrame:EnableMouseWheel(true)
			WorldMapButton:EnableMouse(true)
			WorldMapMagnifyingGlassButton:EnableMouse(true)
		else
			WorldMapFrame:EnableMouse(false)
			WorldMapFrame:EnableMouseWheel(false)
			WorldMapButton:EnableMouse(false)
			WorldMapMagnifyingGlassButton:EnableMouse(false)
		end
	end
end

function Cartographer_LookNFeel:ShowWorldMapArrowFrame()
	--return self.hooks.ShowWorldMapArrowFrame(nil)
end

function Cartographer_LookNFeel:WorldMapButton_OnUpdate()
	WorldMapPlayer:SetScale(1)
end

if lua51 then
	function Cartographer_LookNFeel:CloseSpecialWindows()
		local found = self.hooks.CloseSpecialWindows()
		if self.db.profile.useEscape then
			if WorldMapFrame:IsShown() then
				ToggleWorldMap()
				return 1
			end
		end
		return found
	end
else
	function Cartographer_LookNFeel:CloseWindows()
		local found = self.hooks.CloseWindows()
		if self.db.profile.useEscape then
			if WorldMapFrame:IsShown() then
				ToggleWorldMap()
				return 1
			end
		end
		return found
	end
end

function Cartographer_LookNFeel:WorldMapDetailFrame_CreateTexture(WorldMapDetailFrame, name, layer)
	if name and string.find(name, "^WorldMapOverlay%d+$") then
		local frame = _G[name]
		
		frame:SetParent(self.overlayHolder)
	end
end

local newTexture, clearTextures
do
	local cache = {}
	local num = 12
	function newTexture()
		local texture = next(cache)
		if texture then
			cache[texture] = nil
			texture:SetWidth(256)
			texture:SetHeight(256)
			texture:SetTexCoord(0, 1, 0, 1)
			texture:Show()
			return texture
		end
		num = num + 1
		texture = WorldMapDetailFrame:CreateTexture("WorldMapDetailTile" .. num, "BACKGROUND")
		texture:SetWidth(256)
		texture:SetHeight(256)
		return texture
	end
	function clearTextures()
		for i = 13, num do
			local tex = _G["WorldMapDetailTile" .. i]
			if tex:IsShown() then
				cache[tex] = true
				tex:Hide()
			end
		end
	end
end

local dirty = true
function Cartographer_LookNFeel:Cartographer_ChangeZone(zone)
	if dirty then
		for i = 1, 12 do
			local tex = _G["WorldMapDetailTile" .. i]
			local x = math_mod(i-1, 4) * 256
			local y = -math.floor((i-1)/4) * 256
			tex:ClearAllPoints()
			tex:SetWidth(256)
			tex:SetHeight(256)
			tex:SetTexCoord(0, 1, 0, 1)
			tex:Show()
			tex:SetPoint("TOPLEFT", WorldMapDetailFrame, "TOPLEFT", x, y)
		end
		clearTextures()
		dirty = false
	end
	if zone == "Warsong Gulch" then
		WorldMapDetailTile1:Hide()
		WorldMapDetailTile4:Hide()
		WorldMapDetailTile5:Hide()
		WorldMapDetailTile8:Hide()
		WorldMapDetailTile9:Hide()
		WorldMapDetailTile12:Hide()
		local tex = newTexture()
		tex:SetPoint(WorldMapDetailTile1:GetPoint(1))
		tex:SetTexture(WorldMapDetailTile1:GetTexture())
		local tex = newTexture()
		tex:SetPoint(WorldMapDetailTile4:GetPoint(1))
		tex:SetTexture(WorldMapDetailTile4:GetTexture())
		local tex = newTexture()
		tex:SetPoint(WorldMapDetailTile5:GetPoint(1))
		tex:SetTexture(WorldMapDetailTile5:GetTexture())
		local tex = newTexture()
		tex:SetPoint(WorldMapDetailTile8:GetPoint(1))
		tex:SetTexture(WorldMapDetailTile8:GetTexture())
		local tex = newTexture()
		tex:SetPoint(WorldMapDetailTile9:GetPoint(1))
		tex:SetTexture(WorldMapDetailTile9:GetTexture())
		local tex = newTexture()
		tex:SetPoint(WorldMapDetailTile12:GetPoint(1))
		tex:SetTexture(WorldMapDetailTile12:GetTexture())
		dirty = true
	elseif zone == "Arathi Basin" then
		WorldMapDetailTile1:Hide()
		WorldMapDetailTile4:Hide()
		WorldMapDetailTile5:Hide()
		WorldMapDetailTile8:Hide()
		WorldMapDetailTile9:Hide()
		WorldMapDetailTile10:Hide()
		WorldMapDetailTile11:Hide()
		WorldMapDetailTile12:Hide()
		local tex = newTexture()
		tex:SetPoint(WorldMapDetailTile1:GetPoint(1))
		tex:SetTexture(WorldMapDetailTile1:GetTexture())
		local tex = newTexture()
		tex:SetPoint(WorldMapDetailTile4:GetPoint(1))
		tex:SetTexture(WorldMapDetailTile4:GetTexture())
		local tex = newTexture()
		tex:SetPoint(WorldMapDetailTile5:GetPoint(1))
		tex:SetTexture(WorldMapDetailTile5:GetTexture())
		local tex = newTexture()
		tex:SetPoint(WorldMapDetailTile8:GetPoint(1))
		tex:SetTexture(WorldMapDetailTile8:GetTexture())
		local tex = newTexture()
		tex:SetPoint(WorldMapDetailTile9:GetPoint(1))
		tex:SetTexture(WorldMapDetailTile9:GetTexture())
		local tex = newTexture()
		tex:SetPoint(WorldMapDetailTile10:GetPoint(1))
		tex:SetTexture(WorldMapDetailTile10:GetTexture())
		local tex = newTexture()
		tex:SetPoint(WorldMapDetailTile11:GetPoint(1))
		tex:SetTexture(WorldMapDetailTile11:GetTexture())
		local tex = newTexture()
		tex:SetPoint(WorldMapDetailTile12:GetPoint(1))
		tex:SetTexture(WorldMapDetailTile12:GetTexture())
		dirty = true
	elseif zone == "Alterac Valley" then
		WorldMapDetailTile1:Hide()
		WorldMapDetailTile4:Hide()
		WorldMapDetailTile5:Hide()
		WorldMapDetailTile8:Hide()
		WorldMapDetailTile9:Hide()
		WorldMapDetailTile12:Hide()
		local tex = newTexture()
		tex:SetPoint(WorldMapDetailTile1:GetPoint(1))
		tex:SetTexture(WorldMapDetailTile1:GetTexture())
		local tex = newTexture()
		tex:SetPoint(WorldMapDetailTile4:GetPoint(1))
		tex:SetTexture(WorldMapDetailTile4:GetTexture())
		local tex = newTexture()
		tex:SetPoint(WorldMapDetailTile5:GetPoint(1))
		tex:SetTexture(WorldMapDetailTile5:GetTexture())
		local tex = newTexture()
		tex:SetPoint(WorldMapDetailTile8:GetPoint(1))
		tex:SetTexture(WorldMapDetailTile8:GetTexture())
		local tex = newTexture()
		tex:SetPoint(WorldMapDetailTile9:GetPoint(1))
		tex:SetTexture(WorldMapDetailTile9:GetTexture())
		local tex = newTexture()
		tex:SetPoint(WorldMapDetailTile12:GetPoint(1))
		tex:SetTexture(WorldMapDetailTile12:GetTexture())
		
		WorldMapDetailTile2:SetWidth(156)
		WorldMapDetailTile2:SetTexCoord(100/256, 1, 0, 1)
		WorldMapDetailTile2:SetPoint("TOPLEFT", WorldMapDetailFrame, "TOPLEFT", 356, 0)
		local tex = newTexture()
		tex:SetWidth(100)
		tex:SetTexCoord(0, 100/256, 0, 1)
		tex:SetPoint("TOPLEFT", WorldMapDetailFrame, "TOPLEFT", 256, 0)
		tex:SetTexture(WorldMapDetailTile2:GetTexture())
		WorldMapDetailTile6:SetWidth(156)
		WorldMapDetailTile6:SetTexCoord(100/256, 1, 0, 1)
		WorldMapDetailTile6:SetPoint("TOPLEFT", WorldMapDetailFrame, "TOPLEFT", 356, -256)
		local tex = newTexture()
		tex:SetWidth(100)
		tex:SetTexCoord(0, 100/256, 0, 1)
		tex:SetPoint("TOPLEFT", WorldMapDetailFrame, "TOPLEFT", 256, -256)
		tex:SetTexture(WorldMapDetailTile6:GetTexture())
		WorldMapDetailTile10:SetWidth(156)
		WorldMapDetailTile10:SetTexCoord(100/256, 1, 0, 1)
		WorldMapDetailTile10:SetPoint("TOPLEFT", WorldMapDetailFrame, "TOPLEFT", 356, -512)
		local tex = newTexture()
		tex:SetWidth(100)
		tex:SetTexCoord(0, 100/256, 0, 1)
		tex:SetPoint("TOPLEFT", WorldMapDetailFrame, "TOPLEFT", 256, -512)
		tex:SetTexture(WorldMapDetailTile10:GetTexture())
		
		WorldMapDetailTile3:SetWidth(100)
		WorldMapDetailTile3:SetTexCoord(0, 100/256, 0, 1)
		WorldMapDetailTile3:SetPoint("TOPLEFT", WorldMapDetailFrame, "TOPLEFT", 512, 0)
		local tex = newTexture()
		tex:SetWidth(156)
		tex:SetTexCoord(100/256, 1, 0, 1)
		tex:SetPoint("TOPLEFT", WorldMapDetailFrame, "TOPLEFT", 612, 0)
		tex:SetTexture(WorldMapDetailTile3:GetTexture())
		WorldMapDetailTile7:SetWidth(100)
		WorldMapDetailTile7:SetTexCoord(0, 100/256, 0, 1)
		WorldMapDetailTile7:SetPoint("TOPLEFT", WorldMapDetailFrame, "TOPLEFT", 512, -256)
		local tex = newTexture()
		tex:SetWidth(156)
		tex:SetTexCoord(100/256, 1, 0, 1)
		tex:SetPoint("TOPLEFT", WorldMapDetailFrame, "TOPLEFT", 612, -256)
		tex:SetTexture(WorldMapDetailTile7:GetTexture())
		WorldMapDetailTile11:SetWidth(100)
		WorldMapDetailTile11:SetTexCoord(0, 100/256, 0, 1)
		WorldMapDetailTile11:SetPoint("TOPLEFT", WorldMapDetailFrame, "TOPLEFT", 512, -512)
		local tex = newTexture()
		tex:SetWidth(156)
		tex:SetTexCoord(100/256, 1, 0, 1)
		tex:SetPoint("TOPLEFT", WorldMapDetailFrame, "TOPLEFT", 612, -512)
		tex:SetTexture(WorldMapDetailTile11:GetTexture())
		
		dirty = true
	elseif zone == "Eye of the Storm" then
		WorldMapDetailTile1:Hide()
		WorldMapDetailTile4:Hide()
		WorldMapDetailTile5:Hide()
		WorldMapDetailTile8:Hide()
		WorldMapDetailTile9:Hide()
		WorldMapDetailTile12:Hide()
		local tex = newTexture()
		tex:SetPoint(WorldMapDetailTile1:GetPoint(1))
		tex:SetTexture(WorldMapDetailTile1:GetTexture())
		local tex = newTexture()
		tex:SetPoint(WorldMapDetailTile4:GetPoint(1))
		tex:SetTexture(WorldMapDetailTile4:GetTexture())
		local tex = newTexture()
		tex:SetPoint(WorldMapDetailTile5:GetPoint(1))
		tex:SetTexture(WorldMapDetailTile5:GetTexture())
		local tex = newTexture()
		tex:SetPoint(WorldMapDetailTile8:GetPoint(1))
		tex:SetTexture(WorldMapDetailTile8:GetTexture())
		local tex = newTexture()
		tex:SetPoint(WorldMapDetailTile9:GetPoint(1))
		tex:SetTexture(WorldMapDetailTile9:GetTexture())
		local tex = newTexture()
		tex:SetPoint(WorldMapDetailTile12:GetPoint(1))
		tex:SetTexture(WorldMapDetailTile12:GetTexture())
		
		WorldMapDetailTile2:SetHeight(156)
		WorldMapDetailTile2:SetWidth(156)
		WorldMapDetailTile2:SetTexCoord(100/256, 1, 100/256, 1)
		WorldMapDetailTile2:SetPoint("TOPLEFT", WorldMapDetailFrame, "TOPLEFT", 356, -100)
		local tex = newTexture()
		tex:SetHeight(100)
		tex:SetWidth(156)
		tex:SetTexCoord(100/256, 1, 0, 100/256)
		tex:SetPoint("TOPLEFT", WorldMapDetailFrame, "TOPLEFT", 356, 0)
		tex:SetTexture(WorldMapDetailTile2:GetTexture())
		local tex = newTexture()
		tex:SetWidth(100)
		tex:SetTexCoord(0, 100/256, 0, 1)
		tex:SetPoint("TOPLEFT", WorldMapDetailFrame, "TOPLEFT", 256, 0)
		tex:SetTexture(WorldMapDetailTile2:GetTexture())
		WorldMapDetailTile6:SetWidth(156)
		WorldMapDetailTile6:SetTexCoord(100/256, 1, 0, 1)
		WorldMapDetailTile6:SetPoint("TOPLEFT", WorldMapDetailFrame, "TOPLEFT", 356, -256)
		local tex = newTexture()
		tex:SetWidth(100)
		tex:SetTexCoord(0, 100/256, 0, 1)
		tex:SetPoint("TOPLEFT", WorldMapDetailFrame, "TOPLEFT", 256, -256)
		tex:SetTexture(WorldMapDetailTile6:GetTexture())
		WorldMapDetailTile10:SetWidth(156)
		WorldMapDetailTile10:SetHeight(32)
		WorldMapDetailTile10:SetTexCoord(100/256, 1, 0, 32/256)
		WorldMapDetailTile10:SetPoint("TOPLEFT", WorldMapDetailFrame, "TOPLEFT", 356, -512)
		local tex = newTexture()
		tex:SetWidth(100)
		tex:SetTexCoord(0, 100/256, 0, 1)
		tex:SetPoint("TOPLEFT", WorldMapDetailFrame, "TOPLEFT", 256, -512)
		tex:SetTexture(WorldMapDetailTile10:GetTexture())
		local tex = newTexture()
		tex:SetWidth(156)
		tex:SetHeight(244)
		tex:SetTexCoord(100/256, 1, 32/256, 1)
		tex:SetPoint("TOPLEFT", WorldMapDetailFrame, "TOPLEFT", 356, -544)
		tex:SetTexture(WorldMapDetailTile10:GetTexture())
		
		
		WorldMapDetailTile3:SetHeight(156)
		WorldMapDetailTile3:SetWidth(100)
		WorldMapDetailTile3:SetTexCoord(0, 100/256, 100/256, 1)
		WorldMapDetailTile3:SetPoint("TOPLEFT", WorldMapDetailFrame, "TOPLEFT", 512, -100)
		local tex = newTexture()
		tex:SetHeight(100)
		tex:SetWidth(100)
		tex:SetTexCoord(0, 100/256, 0, 100/256)
		tex:SetPoint("TOPLEFT", WorldMapDetailFrame, "TOPLEFT", 512, 0)
		tex:SetTexture(WorldMapDetailTile3:GetTexture())
		local tex = newTexture()
		tex:SetWidth(156)
		tex:SetTexCoord(100/256, 1, 0, 1)
		tex:SetPoint("TOPLEFT", WorldMapDetailFrame, "TOPLEFT", 612, 0)
		tex:SetTexture(WorldMapDetailTile3:GetTexture())
		WorldMapDetailTile7:SetWidth(100)
		WorldMapDetailTile7:SetTexCoord(0, 100/256, 0, 1)
		WorldMapDetailTile7:SetPoint("TOPLEFT", WorldMapDetailFrame, "TOPLEFT", 512, -256)
		local tex = newTexture()
		tex:SetWidth(156)
		tex:SetTexCoord(100/256, 1, 0, 1)
		tex:SetPoint("TOPLEFT", WorldMapDetailFrame, "TOPLEFT", 612, -256)
		tex:SetTexture(WorldMapDetailTile7:GetTexture())
		WorldMapDetailTile11:SetWidth(100)
		WorldMapDetailTile11:SetHeight(32)
		WorldMapDetailTile11:SetTexCoord(0, 100/256, 0, 32/256)
		WorldMapDetailTile11:SetPoint("TOPLEFT", WorldMapDetailFrame, "TOPLEFT", 512, -512)
		local tex = newTexture()
		tex:SetPoint("TOPLEFT", WorldMapDetailFrame, "TOPLEFT", 612, -512)
		tex:SetTexture(WorldMapDetailTile11:GetTexture())
		tex:SetWidth(156)
		tex:SetTexCoord(100/256, 1, 0, 1)
		local tex = newTexture()
		tex:SetPoint("TOPLEFT", WorldMapDetailFrame, "TOPLEFT", 512, -544)
		tex:SetTexture(WorldMapDetailTile11:GetTexture())
		tex:SetWidth(100)
		tex:SetHeight(224)
		tex:SetTexCoord(0, 100/256, 32/256, 1)
		
		dirty = true
	end
	self:SetAlpha(self:GetAlpha())
end

function Cartographer_LookNFeel:GetAlpha()
	return self.db.profile.alpha
end

function Cartographer_LookNFeel:SetAlpha(value)
	self.db.profile.alpha = value
	if Cartographer:IsModuleActive(self) then
		WorldMapFrame:SetAlpha(1)
		WorldMapFrame:SetAlpha(value)
		if (GetCurrentMapZone() == 0 or cities[GetMapInfo()]) and self.db.profile.overlayAlpha > value then
			WorldMapDetailFrame:SetAlpha(self.db.profile.overlayAlpha)
		else
			WorldMapDetailFrame:SetAlpha(value)
		end
		for i = 13, 1000 do
			local tex = _G["WorldMapDetailTile" .. i]
			if tex then
				tex:SetAlpha(value)
			else
				break
			end
		end
		
		self.overlayHolder:SetAlpha(self.db.profile.overlayAlpha)
		for i,v in fake_ipairs(WorldMapFrame:GetChildren()) do
			if v:GetName() and string.find(v:GetName(), "^Cartographer") then
				v:SetAlpha(self.db.profile.overlayAlpha)
			end
		end
		WorldMapButton:SetAlpha(self.db.profile.overlayAlpha)
		self.playerModel:SetAlpha(self.db.profile.overlayAlpha)
	end
end

function Cartographer_LookNFeel:GetOverlayAlpha()
	return self.db.profile.overlayAlpha
end

function Cartographer_LookNFeel:SetOverlayAlpha(value)
	self.db.profile.overlayAlpha = value
	if Cartographer:IsModuleActive(self) then
		if (GetCurrentMapZone() == 0 or cities[GetMapInfo()]) and value > self.db.profile.alpha then
			WorldMapDetailFrame:SetAlpha(value)
		else
			WorldMapDetailFrame:SetAlpha(self.db.profile.alpha)
		end
		for i = 13, 1000 do
			local tex = _G["WorldMapDetailTile" .. i]
			if tex then
				tex:SetAlpha(self.db.profile.alpha)
			else
				break
			end
		end
		self.overlayHolder:SetAlpha(value)
		for i,v in fake_ipairs(WorldMapFrame:GetChildren()) do
			if v:GetName() and string.find(v:GetName(), "^Cartographer") then
				v:SetAlpha(value)
			end
		end
		WorldMapButton:SetAlpha(value)
		self.playerModel:SetAlpha(value)
	end
end

function Cartographer_LookNFeel:GetScale()
	return self.db.profile.scale
end

function Cartographer_LookNFeel:SetScale(value)
	self.db.profile.scale = value
	
	if Cartographer:IsModuleActive(self) then
		WorldMapFrame:SetScale(value)
		WorldMapTooltip:SetScale(self.db.profile.ttScale / value)
	end
end

function Cartographer_LookNFeel:GetTooltipScale()
	return self.db.profile.ttScale
end

function Cartographer_LookNFeel:SetTooltipScale(value)
	self.db.profile.ttScale = value
	
	if Cartographer:IsModuleActive(self) then
		WorldMapTooltip:SetScale(value / self.db.profile.scale)
	end
end

function Cartographer_LookNFeel:IsLocked()
	return self.db.profile.locked
end

function Cartographer_LookNFeel:ToggleLocked(value)
	if value == nil then
		value = not self.db.profile.locked
	end
	self.db.profile.locked = value
	if Cartographer:IsModuleActive(self) then
		WorldMapFrame:EnableMouse(not value)
		WorldMapFrame:EnableMouseWheel(not value)
		WorldMapButton:EnableMouse(not value)
		WorldMapMagnifyingGlassButton:EnableMouse(not value)
	end
end

function Cartographer_LookNFeel:IsUsingEscape()
	return self.db.profile.useEscape
end

function Cartographer_LookNFeel:ToggleUsingEscape(value)
	if value == nil then
		value = not self.db.profile.useEscape
	end
	self.db.profile.useEscape = value
end

function Cartographer_LookNFeel:GetRealTooltipScale()
	return self.db.profile.ttScale / self.db.profile.scale
end

function Cartographer_LookNFeel:IsLargePlayerPOI()
	return self.db.profile.largePlayer
end

function Cartographer_LookNFeel:ToggleLargePlayerPOI(value)
	if value == nil then
		value = not self.db.profile.useEscape
	end
	self.db.profile.largePlayer = value
	
	self.playerModel:SetModelScale(value and 1.5 or 1)
end

function Cartographer_LookNFeel:OnProfileEnable()
	WorldMapFrame:SetPoint("CENTER", "UIParent", "CENTER", self.db.profile.x or 0, self.db.profile.y or 0)
	self:SetScale(self:GetScale())
	self:SetAlpha(self:GetAlpha())
	self:SetOverlayAlpha(self:GetOverlayAlpha())
	self:SetTooltipScale(self:GetTooltipScale())
	self:ToggleLocked(self:IsLocked())
	self:ToggleLargePlayerPOI(self:IsLargePlayerPOI())
end
