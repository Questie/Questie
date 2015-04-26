local revision = tonumber(string.sub("$Revision: 18625 $", 12, -3))
if revision > Cartographer.revision then
	Cartographer.version = "r" .. revision
	Cartographer.revision = revision
	Cartographer.date = string.sub("$Date: 2006-12-02 16:13:35 +0300 (Сб, 02 дек 2006) $", 8, 17)
end

local L = AceLibrary("AceLocale-2.2"):new("Cartographer-ZoneInfo")

L:RegisterTranslations("enUS", function() return {
	["Zone Info"] = true,
	["Module which on hovering over a zone, will show the levels of the zone, the instances in the zone, their levels, and the number of men the instance is made for (e.g. 5-man, 40-man)."] = true,
	
	["Instances"] = true,
	["%d-man"] = true,
} end)

L:RegisterTranslations("koKR", function() return {
	["Zone Info"] = "지역 정보",
	["Module which on hovering over a zone, will show the levels of the zone, the instances in the zone, their levels, and the number of men the instance is made for (e.g. 5-man, 40-man)."] = "해당 지역에 위치한 인던 및 참여할 수 있는 인원(예. 5명, 40명)등을 보여줍니다.",
	
	["Instances"] = "인스턴스",
	["%d-man"] = "%d명",
} end)

local Tourist = AceLibrary("Tourist-2.0")

Cartographer_ZoneInfo = Cartographer:NewModule("ZoneInfo")

local lua51 = loadstring("return function(...) return ... end") and true or false

local table_setn = lua51 and function() end or table.setn

function Cartographer_ZoneInfo:OnInitialize()
	self.name = L["Zone Info"]
	self.title = L["Zone Info"]
	Cartographer.options.args.ZoneInfo = {
		name = L["Zone Info"],
		desc = L["Module which on hovering over a zone, will show the levels of the zone, the instances in the zone, their levels, and the number of men the instance is made for (e.g. 5-man, 40-man)."],
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

function Cartographer_ZoneInfo:OnEnable()
	if not self.frame then
		self.frame = CreateFrame("Frame", "CartographerZoneInfo", WorldMapFrame)
		self.frame:SetScript("OnUpdate", self.OnUpdate)
		
		self.frame.text = WorldMapFrameAreaFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
		local text = self.frame.text
		local font, size = GameFontHighlightLarge:GetFont()
		text:SetFont(font, size, "OUTLINE")
		text:SetPoint("TOP", WorldMapFrameAreaDescription, "BOTTOM", 0, -5)
		text:SetWidth(1024)
	end
	self.frame:Show()
end

function Cartographer_ZoneInfo:OnDisable()
	self.frame:Hide()
	WorldMapFrameAreaLabel:SetTextColor(1, 1, 1)
end

local lastZone
local t = {}
function Cartographer_ZoneInfo.OnUpdate()
	local self = Cartographer_ZoneInfo
	if not WorldMapDetailFrame:IsShown() or not WorldMapFrameAreaLabel:IsShown() then
		self.frame.text:SetText("")
		lastZone = nil
		return
	end
	
	local underAttack = false
	local zone = WorldMapFrameAreaLabel:GetText()
	if zone then
		zone = string.gsub(WorldMapFrameAreaLabel:GetText(), " |cff.+$", "")
		if WorldMapFrameAreaDescription:GetText() then
			underAttack = true
			zone = string.gsub(WorldMapFrameAreaDescription:GetText(), " |cff.+$", "")
		end
	end
	if GetCurrentMapContinent() == 0 then
		local c1, c2 = GetMapContinents()
		if zone == c1 or zone == c2 then
			WorldMapFrameAreaLabel:SetTextColor(1, 1, 1)
			self.frame.text:SetText("")
			return
		end
	end
	if not zone or not Tourist:IsZoneOrInstance(zone) then
		zone = WorldMapFrame.areaName
	end
	WorldMapFrameAreaLabel:SetTextColor(1, 1, 1)
	if zone and (Tourist:IsZoneOrInstance(zone) or Tourist:DoesZoneHaveInstances(zone)) then
		if not underAttack then
			WorldMapFrameAreaLabel:SetTextColor(Tourist:GetFactionColor(zone))
			WorldMapFrameAreaDescription:SetTextColor(1, 1, 1)
		else
			WorldMapFrameAreaLabel:SetTextColor(1, 1, 1)
			WorldMapFrameAreaDescription:SetTextColor(Tourist:GetFactionColor(zone))
		end
		local low, high = Tourist:GetLevel(zone)
		if low > 0 and high > 0 then
			local r, g, b = Tourist:GetLevelColor(zone)
			local levelText
			if low == high then
				levelText = string.format(" |cff%02x%02x%02x[%d]|r", r * 255, g * 255, b * 255, high)
			else
				levelText = string.format(" |cff%02x%02x%02x[%d-%d]|r", r * 255, g * 255, b * 255, low, high)
			end
			local groupSize = Tourist:GetInstanceGroupSize(zone)
			local sizeText = ""
			if groupSize > 0 then
				sizeText = " " .. string.format(L["%d-man"], groupSize)
			end
			if not underAttack then
				WorldMapFrameAreaLabel:SetText(string.gsub(WorldMapFrameAreaLabel:GetText(), " |cff.+$", "") .. levelText .. sizeText)
			else
				WorldMapFrameAreaDescription:SetText(string.gsub(WorldMapFrameAreaDescription:GetText(), " |cff.+$", "") .. levelText .. sizeText)
			end
		end
		
		if Tourist:DoesZoneHaveInstances(zone) then
			if lastZone ~= zone then
				lastZone = zone
				table.insert(t, string.format("|cffffff00%s:|r", L["Instances"]))
				for instance in Tourist:IterateZoneInstances(zone) do
					local low, high = Tourist:GetLevel(instance)
					local r1, g1, b1 = Tourist:GetFactionColor(instance)
					local r2, g2, b2 = Tourist:GetLevelColor(instance)
					local groupSize = Tourist:GetInstanceGroupSize(instance)
					if low == high then
						if groupSize > 0 then
							table.insert(t, string.format("|cff%02x%02x%02x%s|r |cff%02x%02x%02x[%d]|r " .. L["%d-man"], r1 * 255, g1 * 255, b1 * 255, instance, r2 * 255, g2 * 255, b2 * 255, high, groupSize))
						else
							table.insert(t, string.format("|cff%02x%02x%02x%s|r |cff%02x%02x%02x[%d]|r", r1 * 255, g1 * 255, b1 * 255, instance, r2 * 255, g2 * 255, b2 * 255, high))
						end
					else
						if groupSize > 0 then
							table.insert(t, string.format("|cff%02x%02x%02x%s|r |cff%02x%02x%02x[%d-%d]|r " .. L["%d-man"], r1 * 255, g1 * 255, b1 * 255, instance, r2 * 255, g2 * 255, b2 * 255, low, high, groupSize))
						else
							table.insert(t, string.format("|cff%02x%02x%02x%s|r |cff%02x%02x%02x[%d-%d]|r", r1 * 255, g1 * 255, b1 * 255, instance, r2 * 255, g2 * 255, b2 * 255, low, high))
						end
					end
				end
				self.frame.text:SetText(table.concat(t, "\n"))
				for k in pairs(t) do
					t[k] = nil
				end
				table_setn(t, 0)
			end
		else
			lastZone = nil
			self.frame.text:SetText("")
		end
	elseif not zone then
		lastZone = nil
		self.frame.text:SetText("")
	end
end
