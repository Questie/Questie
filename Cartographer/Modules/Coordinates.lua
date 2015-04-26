local revision = tonumber(string.sub("$Revision: 18625 $", 12, -3))
if revision > Cartographer.revision then
	Cartographer.version = "r" .. revision
	Cartographer.revision = revision
	Cartographer.date = string.sub("$Date: 2006-12-02 16:13:35 +0300 (Сб, 02 дек 2006) $", 8, 17)
end

local L = AceLibrary("AceLocale-2.2"):new("Cartographer-Coordinates")

L:RegisterTranslations("enUS", function() return {
	["Coordinates"] = true,
	["Module to add coordinates to the bottom of the world map of the player and the cursor."] = true,
	
	["Cursor:"] = true,
	["Player:"] = true,
} end)

L:RegisterTranslations("deDE", function() return {
--	["Coordinates"] = true,
--	["Module to add coordinates to the bottom of the world map of the player and the cursor."] = true,
	
	["Cursor:"] = "Cursor:",
	["Player:"] = "Spieler:",
} end)

L:RegisterTranslations("frFR", function() return {
--	["Coordinates"] = true,
--	["Module to add coordinates to the bottom of the world map of the player and the cursor."] = true,
	
	["Cursor:"] = "Curseur ",
	["Player:"] = "Joueur ",
} end)

L:RegisterTranslations("koKR", function() return {
	["Coordinates"] = "좌표",
	["Module to add coordinates to the bottom of the world map of the player and the cursor."] = "플레이어와 커서의 좌표를 세계 지도 밑에 보여줍니다.",
	
	["Cursor:"] = "커서:",
	["Player:"] = "플레이어:",
} end)

L:RegisterTranslations("zhTW", function() return {
--	["Coordinates"] = true,
--	["Module to add coordinates to the bottom of the world map of the player and the cursor."] = true,
	
	["Cursor:"] = "指標:",
	["Player:"] = "玩家:",
} end)

Cartographer_Coordinates = Cartographer:NewModule("Coordinates")

function Cartographer_Coordinates:OnInitialize()
	Cartographer.options.args.Coordinates = {
		name = L["Coordinates"],
		desc = L["Module to add coordinates to the bottom of the world map of the player and the cursor."],
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
	
end

function Cartographer_Coordinates:OnEnable()
	if not self.frame then
		self.frame = CreateFrame("Frame", "CartographerCoordinates", WorldMapFrame)
		self.frame:SetScript("OnUpdate", self.OnUpdate)
		
		self.frame.cursorCoords = self.frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		self.frame.cursorCoords:SetPoint("RIGHT", WorldMapFrame, "CENTER", -80, -367)
		
		self.frame.playerCoords = self.frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		self.frame.playerCoords:SetPoint("LEFT", WorldMapFrame, "CENTER", 80, -367)
	end
	self.frame:Show()
end

function Cartographer_Coordinates:OnDisable()
	self.frame:Hide()
end

function Cartographer_Coordinates.OnUpdate()
	local self = Cartographer_Coordinates
	local x, y = GetCursorPosition()
	
	local px, py = GetPlayerMapPosition("player")
	local left, top = WorldMapDetailFrame:GetLeft(), WorldMapDetailFrame:GetTop()
	local width = WorldMapDetailFrame:GetWidth()
	local height = WorldMapDetailFrame:GetHeight()
	local scale = WorldMapDetailFrame:GetEffectiveScale()
	local cx = (x/scale - left) / width
	local cy = (top - y/scale) / height
	
	self.frame.cursorCoords:SetText(string.format("%s: %.1f, %.1f", L["Cursor:"], 100 * cx, 100 * cy))
	if px == 0 or py == 0 or IsInInstance() or Cartographer:GetCurrentInstance() then
		self.frame.playerCoords:SetText("")
	else
		self.frame.playerCoords:SetText(string.format("%s: %.1f, %.1f", L["Player:"], 100 * px, 100 * py))
	end
end
