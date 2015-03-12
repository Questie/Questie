local revision = tonumber(string.sub("$Revision: 18625 $", 12, -3))
if revision > Cartographer.revision then
	Cartographer.version = "r" .. revision
	Cartographer.revision = revision
	Cartographer.date = string.sub("$Date: 2006-12-02 16:13:35 +0300 (Сб, 02 дек 2006) $", 8, 17)
end

local L = AceLibrary("AceLocale-2.2"):new("Cartographer-GroupColors")

L:RegisterTranslations("enUS", function() return {
	["Group Colors"] = true,
	["Module which turns all your party's and your raid's POIs into circles colored based on class, and shows a number on them based on their raid group."] = true,
} end)

L:RegisterTranslations("deDE", function() return {
--	["Group Colors"] = true,
--	["Module which turns all your party's and your raid's POIs into circles colored based on class, and shows a number on them based on their raid group."] = true,
} end)

L:RegisterTranslations("frFR", function() return {
--	["Group Colors"] = true,
--	["Module which turns all your party's and your raid's POIs into circles colored based on class, and shows a number on them based on their raid group."] = true,
} end)

L:RegisterTranslations("koKR", function() return {
	["Group Colors"] = "그룹 색상",
	["Module which turns all your party's and your raid's POIs into circles colored based on class, and shows a number on them based on their raid group."] = "모든 당신의 파티 및 공격대원들의 위치를 직업에 따른 서클과 숫자를 통해 보여줍니다.",
} end)

L:RegisterTranslations("zhCN", function() return {
--	["Group Colors"] = true,
--	["Module which turns all your party's and your raid's POIs into circles colored based on class, and shows a number on them based on their raid group."] = true,
} end)

L:RegisterTranslations("zhTW", function() return {
--	["Group Colors"] = true,
--	["Module which turns all your party's and your raid's POIs into circles colored based on class, and shows a number on them based on their raid group."] = true,
} end)

Cartographer_GroupColors = Cartographer:NewModule("GroupColors", "AceEvent-2.0")

local _G = getfenv(0)

function Cartographer_GroupColors:OnInitialize()
	self.name = L["Group Colors"]
	self.title = L["Group Colors"]
	Cartographer.options.args.GroupColors = {
		name = L["Group Colors"],
		desc = L["Module which turns all your party's and your raid's POIs into circles colored based on class, and shows a number on them based on their raid group."],
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

function Cartographer_GroupColors:OnEnable()
	self:RegisterEvent("PARTY_MEMBERS_UPDATE", "Update")
	self:RegisterEvent("RAID_ROSTER_UPDATE", "Update")
	self:RegisterEvent("WORLD_MAP_UPDATE", function()
		if GetNumRaidMembers() > 0 then
			self:ScheduleRepeatingEvent("Cartographer_GroupColors", self.Update, 0.5, self)
		else
			self:Update()
		end
	end)
	self:Update()
	for i = 1, 4 do
		_G["WorldMapParty" .. i .. "Icon"]:SetTexture("Interface\\AddOns\\Cartographer\\GroupColorsArtwork\\Normal")
	end
end

function Cartographer_GroupColors:OnDisable()
	for i = 1, 4 do
		_G["WorldMapParty" .. i .. "Icon"]:SetVertexColor(1, 1, 1)
		_G["WorldMapParty" .. i .. "Icon"]:SetTexture("Interface\\WorldMap\\WorldMapPartyIcon")
	end
	for i = 1, 40 do
		_G["WorldMapRaid" .. i .. "Icon"]:SetVertexColor(1, 1, 1)
		_G["WorldMapRaid" .. i .. "Icon"]:SetTexture("Interface\\WorldMap\\WorldMapPartyIcon")
	end
end

function Cartographer_GroupColors:Update()
	if not WorldMapFrame:IsShown() then
		self:CancelScheduledEvent("Cartographer_GroupColors")
		return
	end
	if GetNumRaidMembers() > 0 then
		for i = 1, GetNumRaidMembers() do
			local unit = _G["WorldMapRaid" .. i].unit
			if not unit then
				break
			end
			local _, _, subgroup, _, _, fileName = GetRaidRosterInfo(string.sub(unit, 5)+0)
			if subgroup and fileName then
				local tex = _G["WorldMapRaid" .. i .. "Icon"]
				tex:SetTexture("Interface\\AddOns\\Cartographer\\GroupColorsArtwork\\Group" .. subgroup)
				local t = RAID_CLASS_COLORS[fileName]
				if t then
					tex:SetVertexColor(t.r, t.g, t.b)
				else
					tex:SetVertexColor(0.8, 0.8, 0.8)
				end
			end
		end
	else
		for i = 1, GetNumPartyMembers() do
			local _,fileName = UnitClass("party" .. i)
			local tex = _G["WorldMapParty" .. i .. "Icon"]
			local t = RAID_CLASS_COLORS[fileName]
			tex:SetVertexColor(t.r, t.g, t.b)
		end
	end
end
