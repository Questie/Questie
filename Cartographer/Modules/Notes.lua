local revision = tonumber(string.sub("$Revision: 18701 $", 12, -3))
if revision > Cartographer.revision then
	Cartographer.version = "r" .. revision
	Cartographer.revision = revision
	Cartographer.date = string.sub("$Date: 2006-12-03 12:55:33 +0300 (Вс, 03 дек 2006) $", 8, 17)
end

local L = AceLibrary("AceLocale-2.2"):new("Cartographer-Notes")

L:RegisterTranslations("enUS", function() return {
	["Notes"] = true,
	["Module which allows you to put notes on the map."] = true,
	
	["White"] = true,
	["Gray"] = true,
	["Red"] = true,
	["Pink"] = true,
	["Yellow"] = true,
	["Orange"] = true,
	["Green"] = true,
	["Lime"] = true,
	["Blue"] = true,
	["Pale blue"] = true,
	["Cyan"] = true,
	["Purple"] = true,
	
	["Unknown"] = true,
	["Custom icon"] = true,
	
	["Create a new note"] = true,
	["New note"] = true,
	["Delete note"] = true,
	["Edit note"] = true,
	["Send note"] = true,
	["Send to party"] = true,
	["Send to raid"] = true,
	["Send to guild"] = true,
	["Send to player"] = true,
	
	["Note: This may be blocked by Blizzard's spam filter and cause problems. It is recommended to send to your party/raid/guild instead."] = true,
	
	["X position"] = true,
	["Y position"] = true,
	["Title"] = true,
	["Info line 1 (optional)"] = true,
	["Info line 2 (optional)"] = true,
	["Creator (optional)"] = true,
	
	["Ctrl-Right-Click on map to add a note"] = true,
	
	["%s from Guild"] = true,
	["%s from Raid"] = true,
	["%s from Party"] = true,
	
	["Error: %s sent you a note with an unknown zone: %q"] = true,
	["Error: %s sent you a note at %q : %.1f, %.1f with the title %q created by %q, but you already have a note at this location."] = true,
	["%s sent you a note at %q : %.1f, %.1f with the title %q created by %q."] = true,

	["Created by"] = true,
	
	["Show note creator"] = true,
	["Show the `Created By:' line in notes"] = true,
	
	["Icon size"] = true,
	["Size of the icons on the map"] = true,
} end)

L:RegisterTranslations("koKR", function() return {
	["Notes"] = "노트",
	["Module which allows you to put notes on the map."] = "지도에 노트를 작성합니다.",
	
	["White"] = "흰색",
	["Gray"] = "회색",
	["Red"] = "빨강색",
	["Pink"] = "분홍색",
	["Yellow"] = "노랑색",
	["Orange"] = "주황색",
	["Green"] = "녹색",
	["Lime"] = "라임색",
	["Blue"] = "파랑색",
	["Pale blue"] = "연한 파랑색",
	["Cyan"] = "청색",
	["Purple"] = "심홍색",
	
	["Unknown"] = "알수없음",
	["Custom icon"] = "사용자 아이콘",
	
	["Create a new note"] = "노트 작성",
	["New note"] = "신규 노트",
	["Delete note"] = "노트 삭제",
	["Edit note"] = "노트 편집",
	["Send note"] = "노트 발송",
	["Send to party"] = "파티에 보냄",
	["Send to raid"] = "공격대에 보냄",
	["Send to guild"] = "길드에 보냄",
	["Send to player"] = "플레이어에게 보냄",
	
--	["Note: This may be blocked by Blizzard's spam filter and cause problems. It is recommended to send to your party/raid/guild instead."] = true,
    
	["X position"] = "X 위치",
	["Y position"] = "Y 위치",
	["Title"] = "제목",
	["Info line 1 (optional)"] = "정보 라인 1 (선택)",
	["Info line 2 (optional)"] = "정보 라인 2 (선택)",
	["Creator (optional)"] = "신규 (선택)",
	
	["Ctrl-Right-Click on map to add a note"] = "Ctrl-오른쪽-클릭 : 맵 노트 추가",
	
	["%s from Guild"] = "길드로부터 %s 받음",
	["%s from Raid"] = "공격대로부터 %s 받음",
	["%s from Party"] = "파티로부터 %s 받음",
	
	["Error: %s sent you a note with an unknown zone: %q"] = "오류: %s|1이;가; 알려지지 않은 지역 노트를 보냈습니다: %q",
--	["Error: %s sent you a note at %q : %.1f, %.1f with the title %q created by %q, but you already have a note at this location."] = true,
--	["%s sent you a note at %q : %.1f, %.1f with the title %q created by %q."] = true,

	["Created by"] = "작성자",
	
	["Show note creator"] = "작성자 보기",
	["Show the `Created By:' line in notes"] = "노트에 '작성자:' 를 표시합니다.",

	["Icon size"] = "아이콘 크기",
	["Size of the icons on the map"] = "노트의 아이콘 크기를 변경합니다.",
} end)

local icons = {}
local function getIconTitle(icon)
	if icons[icon] then
		return icons[icon].text
	elseif string.find(icon, "^Interface\\") then
		return L["Custom icon"]
	else
		return icon
	end
end

Cartographer_Notes = Cartographer:NewModule("Notes", "AceHook-2.1", "AceEvent-2.0", "AceComm-2.0", "AceConsole-2.0")
local self = Cartographer_Notes

local Dewdrop = AceLibrary("Dewdrop-2.0")
local Tablet = AceLibrary("Tablet-2.0")
local BZ = AceLibrary("Babble-Zone-2.2")

local _G = getfenv(0)
local math_mod = math.fmod or math.mod
local lua51 = loadstring("return function(...) return ... end") and true or false
local table_setn = lua51 and function() end or table.setn

local function round(num, digits)
    -- banker's rounding
	local mantissa = 10^digits
	local norm = num*mantissa
	norm = norm + 0.5
	local norm_f = math.floor(norm)
	if norm == norm_f and math_mod(norm_f, 2) ~= 0 then
		return (norm_f-1)/mantissa
	end
	return norm_f/mantissa
end

local function GetCursorMapLocation(button)
	local x, y = GetCursorPosition()
	local left, top = button:GetLeft(), button:GetTop()
	local width = button:GetWidth()
	local height = button:GetHeight()
	local scale = button:GetEffectiveScale()
	
	return (x/scale - left) / width, (top - y/scale) / height
end

local function getID(x, y)
    return round(x*1000, 0) + round(y*1000, 0)*1001
end

local function getXY(id)
	return math_mod(id, 1001)/1000, math.floor(id / 1001)/1000
end

local function getrawpoi(zone, id)
	for k,v in pairs(self.externalDBs) do
		if rawget(v, zone) and rawget(v[zone], id) then
			return v[zone][id], k
		end
	end
	if rawget(Cartographer_Notes.db.account.pois, zone) then
		local t = rawget(Cartographer_Notes.db.account.pois[zone], id)
		if t then
			return t, nil
		end
	end
end

local function getpoi(zone, id)
	for k,v in pairs(self.externalDBs) do
		if v[zone] and v[zone][id] then
			return v[zone][id], k
		end
	end
	local t = Cartographer_Notes.db.account.pois[zone][id]
	return t, nil
end

function Cartographer_Notes:RegisterIcon(name, data)
	AceLibrary.argCheck(self, name, 2, "string")
	AceLibrary.argCheck(self, data, 3, "table")
	if icons[name] then
		error(string.format("Icon %q already registered", name), 2)
	end
	if type(data.text) ~= "string" then
		error("text in data table must be a string", 2)
	end
	if type(data.path) ~= "string" then
		error("path in data table must be a string", 2)
	end
	if not data.cLeft then
		if string.find(data.path, "^Interface\\Icons\\") then
			data.cLeft = 0.05
			data.cRight = 0.95
			data.cTop = 0.05
			data.cBottom = 0.95
		else
			data.cLeft = 0
			data.cRight = 1
			data.cTop = 0
			data.cBottom = 1
		end
	end
	if not data.alpha then
		data.alpha = 1
	end
	if not data.width then
		data.width = 16
	end
	if not data.height then
		data.height = 16
	end
	icons[name] = data
	self:RefreshMap(false)
end

function Cartographer_Notes:UnregisterIcon(name)
	AceLibrary.argCheck(self, name, 2, "string")
	if not icons[name] then
		error(string.format("Icon %q not registered", name), 2)
	end
	icons[name] = nil
	self:RefreshMap(false)
end

function Cartographer_Notes:OnInitialize()
	self:SetCommPrefix("Cartographer-Notes")
	self.externalDBs = {}
	self.handlers = {}
	local memoizations = {
		"NOTE", "title", "titleR", "titleG", "titleB", "info", "infoR", "infoG", "infoB", "info2", "info2R", "info2G", "info2B", "creator", "manual", "icon",
		-- icon names
		"Star", "Circle", "Diamond", "Triangle", "Moon", "Square", "Cross", "Skull",
	}
	for zone in BZ:GetIterator() do
		table.insert(memoizations, zone)
	end
	self:RegisterMemoizations(memoizations)
	memoizations = nil
	
	do
		local x = { "Star", "Circle", "Diamond", "Triangle", "Moon", "Square", "Cross", "Skull" }
		
		for i = 1, 8 do
			local t = UnitPopupButtons["RAID_TARGET_" .. i]
			self:RegisterIcon(x[i], {
				text = t.text,
				r = t.color.r,
				g = t.color.g,
				b = t.color.b,
				path = "Interface\\TargetingFrame\\UI-RaidTargetingIcons",
				cLeft = t.tCoordLeft,
				cRight = t.tCoordRight,
				cTop = t.tCoordTop,
				cBottom = t.tCoordBottom,
				showToUser = true,
			})
		end
		
		self:RegisterIcon("Unknown", {
			text = L["Unknown"],
			path = "Interface\\Icons\\INV_Misc_QuestionMark",
		})
	end
	
	self.db = Cartographer:AcquireDBNamespace("Notes")
	Cartographer:RegisterDefaults("Notes", "account", {
		pois = {
			['*'] = { -- zones
				['*'] = {
					creator = "",
					manual = true,
				}
			}
		}
	})
	Cartographer:RegisterDefaults("Notes", "profile", {
		showCreator = true,
		iconSize = 1,
	})
	
	-- REMOVE IN A FEW DAYS (2006-11-23) --
	for k,zone in pairs(self.db.account.pois) do
		for _,u in pairs(zone) do
			if type(u) == "table" then
				u.x = nil
				u.y = nil
			end
		end
	end
	-- REMOVE IN A FEW DAYS (2006-11-23) --
	
	-- REMOVE IN A FEW DAYS (2006-11-26) --
	for k,zone in pairs(self.db.account.pois) do
		for _,u in pairs(zone) do
			if type(u) == "table" then
				if u.title == getIconTitle(u.icon) then
					u.title = nil
				end
				if u.titleR == 1 then
					u.titleR = nil
				end
				if u.titleG == 1 then
					u.titleG = nil
				end
				if u.titleB == 1 then
					u.titleB = nil
				end
				if u.info == "" then
					u.info = nil
				end
				if u.infoR == 1 then
					u.infoR = nil
				end
				if u.infoG == 1 then
					u.infoG = nil
				end
				if u.infoB == 1 then
					u.infoB = nil
				end
				if u.info2 == "" then
					u.info2 = nil
				end
				if u.info2R == 1 then
					u.info2R = nil
				end
				if u.info2G == 1 then
					u.info2G = nil
				end
				if u.info2B == 1 then
					u.info2B = nil
				end
			end
		end
	end
	-- REMOVE IN A FEW DAYS (2006-11-26) --
	
	Cartographer.options.args.Notes = {
		name = L["Notes"],
		desc = L["Module which allows you to put notes on the map."],
		type = 'group',
		args = {
			showCreator = {
				name = L["Show note creator"],
				desc = L["Show the `Created By:' line in notes"],
				type = 'toggle',
				get = "IsShowingCreator",
				set = "ToggleShowingCreator",
			},
			size = {
				name = L["Icon size"],
				desc = L["Size of the icons on the map"],
				type = 'range',
				min = 0.5,
				max = 2,
				step = 0.05,
				isPercent = true,
				get = "GetIconSize",
				set = "SetIconSize",
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
end

local oldWorldMapMagnifyingGlassButtonText
function Cartographer_Notes:OnEnable()
	Cartographer:AddToMagnifyingGlass(L["Ctrl-Right-Click on map to add a note"])
	if self.developing then
		Cartographer:AddToMagnifyingGlass(string.format("Alt-Right-Click on map to add a default note to %q", self.developing))
	end
	self:Hook("WorldMapButton_OnClick", true)
	self:Hook("ToggleWorldMap", true)
	self:RegisterEvent("WORLD_MAP_UPDATE", function() self:RefreshMap(false) end)
	self:RegisterEvent("Cartographer_SetCurrentInstance", function() self:RefreshMap(false) end)
	if Cartographer:GetInstanceWorldMapButton() then
		self:HookScript(Cartographer:GetInstanceWorldMapButton(), "OnClick", "InstanceWorldMapButton_OnClick")
	else
		self:RegisterEvent("Cartographer_RegisterInstanceWorldMapButton", function(frame)
			self:HookScript(frame, "OnClick", "InstanceWorldMapButton_OnClick")
		end)
	end
	if WorldMapFrame:IsShown() then
		self:RefreshMap(false)
	end
	
	local func = function()
		self:WorldMapButton_OnClick(arg1, WorldMapButton)
	end
	WorldMapPlayer:SetScript("OnMouseUp", func)
	for i = 1, 4 do
		_G["WorldMapParty" .. i]:SetScript("OnMouseUp", func)
	end
	for i = 1, 40 do
		_G["WorldMapRaid" .. i]:SetScript("OnMouseUp", func)
	end
	WorldMapFlag1:SetScript("OnMouseUp", func)
	WorldMapFlag2:SetScript("OnMouseUp", func)
	WorldMapCorpse:SetScript("OnMouseUp", func)
	if lua51 then
		WorldMapDeathRelease:SetScript("OnMouseUp", func)
	end
	
	self:RegisterComm(self.commPrefix, "WHISPER")
	self:RegisterComm(self.commPrefix, "GUILD")
	self:RegisterComm(self.commPrefix, "PARTY")
	self:RegisterComm(self.commPrefix, "RAID")
end
function Cartographer_Notes:OnDisable()
	Cartographer:RemoveFromMagnifyingGlass(L["Ctrl-Right-Click on map to add a note"])
	if self.developing then
		Cartographer:RemoveFromMagnifyingGlass(string.format("Alt-Right-Click on map to add a default note to %q", self.developing))
	end
	self:ClearMap()
	WorldMapPlayer:SetScript("OnMouseUp", nil)
	for i = 1, 4 do
		_G["WorldMapParty" .. i]:SetScript("OnMouseUp", nil)
	end
	for i = 1, 40 do
		_G["WorldMapRaid" .. i]:SetScript("OnMouseUp", nil)
	end
	WorldMapFlag1:SetScript("OnMouseUp", nil)
	WorldMapFlag2:SetScript("OnMouseUp", nil)
	WorldMapCorpse:SetScript("OnMouseUp", nil)
	if lua51 then
		WorldMapDeathRelease:SetScript("OnMouseUp", nil)
	end
end

Cartographer_Notes.OnCommReceive = {
	NOTE = function(self, prefix, sender, distribution, zone, x, y, creator, data)
		if type(zone) ~= "string" or type(x) ~= "number" or x < 0 or x > 1000 or type(y) ~= "number" or y < 0 or y > 1000 or (type(creator) ~= "string" and creator ~= nil) or (type(data) ~= "table" and type(data) ~= "string") or (type(data) == "table" and type(data.icon) ~= "string") then
			-- bad data
			return
		end
		
		if not BZ:HasTranslation(zone) then
			self:Print(L["Error: %s sent you a note with an unknown zone: %q"], fullSender, zone)
			return
		end
		
		local usingDB = self.externalDBs[creator] and creator or nil
		if creator and not usingDB and type(data) == "string" then
			data = {
				icon = data,
				manual = false,
				creator = creator
			}
		end
		
		local fullSender = distribution == "GUILD" and string.format(L["%s from Guild"], sender) or distribution == "RAID" and string.format(L["%s from Raid"], sender) or distribution == "PARTY" and string.format(L["%s from Party"], sender) or sender
		x, y = x/1000, y/1000
		local id = getID(x, y)
		local poi_data, db = getrawpoi(zone, id)
		if poi_data and (db or poi_data.creator or "") ~= (creator or type(data) == "table" and data.creator or "") then
			self:Print(L["Error: %s sent you a note at %q : %.1f, %.1f with the title %q created by %q, but you already have a note at this location."], fullSender, BZ[zone], x*100, y*100, type(data) == "table" and data.title or getIconTitle(type(data) == "string" and data or data.icon) or UNKNOWN, creator or type(data) == "table" and data.creator or UNKNOWN)
			return
		end
		if self:SetNote(zone, x, y, type(data) == "string" and data or data.icon, (creator or type(data) == "table" and data.creator or ""), type(data) == "table" and data or nil) then
			-- if changed
			self:Print(L["%s sent you a note at %q : %.1f, %.1f with the title %q created by %q."], fullSender, BZ[zone], x*100, y*100, type(data) == "table" and data.title or getIconTitle(type(data) == "string" and data or data.icon), creator or type(data) == "table" and data.creator or UNKNOWN)
		end
	end
}

function Cartographer_Notes:InstanceWorldMapButton_OnClick(frame, a1)
	if mouseButton ~= "RightButton" or (not IsControlKeyDown() and (not self.developing or not IsAltKeyDown())) then
		return self.hooks[frame].OnClick(frame, a1)
	end
	
	if not Cartographer:GetCurrentEnglishZoneName() then
		return
	end
	
	return self:MapButton_OnClick(arg1, frame)
end

function Cartographer_Notes:WorldMapButton_OnClick(mouseButton, button)
	if mouseButton ~= "RightButton" or (not IsControlKeyDown() and (not self.developing or not IsAltKeyDown())) then
		return self.hooks.WorldMapButton_OnClick(mouseButton, button)
	end
	
	if not Cartographer:GetCurrentEnglishZoneName() then
		return
	end
	
	if not button then
		button = this
	end
	
	return self:MapButton_OnClick(mouseButton, button)
end

local lastCursorX, lastCursorY
function Cartographer_Notes:MapButton_OnClick(mouseButton, button)
	if IsControlKeyDown() then
		if not Dewdrop:IsRegistered(WorldMapFrame) then
			local newNoteFunc = function(creator)
				self:OpenNewNoteFrame(lastCursorX, lastCursorY, creator)
				Dewdrop:Close()
			end
			local closeFunc = function()
				Dewdrop:Close()
			end
			Dewdrop:Register(button,
				'children', function()
					Dewdrop:AddLine(
						'text', L["Create a new note"],
						'func', newNoteFunc
					)
					if self.developing then
						Dewdrop:AddLine(
							'text', string.format(L["Create a new note for %q"], self.developing),
							'func', newNoteFunc,
							'arg1', self.developing
						)
					end
					Dewdrop:AddLine()
					Dewdrop:AddLine(
						'text', CANCEL,
						'func', closeFunc
					)
				end,
				'dontHook', true,
				'cursorX', true,
				'cursorY', true
			)
		end
		lastCursorX, lastCursorY = GetCursorMapLocation(button)
		if button == WorldMapFrame then
			Dewdrop:Open(button)
		else
			Dewdrop:Open(button, WorldMapFrame)
		end
	else
		local x, y = GetCursorMapLocation(button)
		self:SetNote(Cartographer:GetCurrentEnglishZoneName(), x, y, "Triangle", self.developing)
	end
end

local frame
local function GetNoteDialog()
	if frame then
		return frame
	end
	
	frame = CreateFrame("Frame", "CartographerNotesNewNoteFrame", WorldMapFrame)
	frame:SetPoint("CENTER", WorldMapFrame, "CENTER")
	frame:SetWidth(500)
	frame:SetHeight(330)
	frame:SetFrameLevel(9)
	frame:EnableMouse(true)
	frame:SetMovable(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetScript("OnDragStart", function()
		this:StartMoving()
	end)
	frame:SetScript("OnDragStop", function()
		this:StopMovingOrSizing()
	end)
	frame:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
		tile = true,
		insets = {
			left = 11,
			right = 12,
			top = 12,
			bottom = 11
		},
		'tileSize', 32,
		'edgeSize', 32
	})
	
	local texture = frame:CreateTexture(nil, "ARTWORK")
	texture:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header")
	texture:SetWidth(256)
	texture:SetHeight(64)
	texture:SetPoint("TOP", frame, "TOP", 0, 12)
	
	local header = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	frame.header = header
	header:SetText(L["New note"])
	header:SetPoint("TOP", texture, "TOP", 0, -14)
	
	local okayButton = CreateFrame("Button", "CartographerNotesNewNoteFrameOkay", frame, "UIPanelButtonTemplate2")
	okayButton:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 20, 20)
	okayButton:SetText(OKAY or 'Okay')
	okayButton:SetWidth(frame:GetWidth()/2 - 25)
	
	local cancelButton = CreateFrame("Button", "CartographerNotesNewNoteFrameCancel", frame, "UIPanelButtonTemplate2")
	cancelButton:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -20, 20)
	cancelButton:SetText(CANCEL or 'Cancel')
	cancelButton:SetWidth(frame:GetWidth()/2 - 25)
	cancelButton:SetScript("OnClick", function()
		frame:Hide()
	end)
	
	local last
	local isGood
	
	local OnEscapePressed = function()
		this:ClearFocus()
	end
	
	local OnTextChanged = function()
		if isGood() then
			okayButton:Enable()
		else
			okayButton:Disable()
		end
	end
	
	local function make(text, colorful)
		local editBox = CreateFrame("EditBox", nil, frame)
		editBox:SetFontObject(ChatFontNormal)
		editBox:SetWidth(colorful and 210 or 240)
		editBox:SetHeight(13)
		if not last then
			editBox:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -25, -35)
		else
			editBox:SetPoint("TOPLEFT", last, "BOTTOMLEFT", 0, -20)
		end
		last = editBox
		editBox:SetAutoFocus(false)
		editBox:SetScript("OnEscapePressed", OnEscapePressed)
		editBox:SetScript("OnTextChanged", OnTextChanged)

		local left = editBox:CreateTexture(nil, "BACKGROUND")
		left:SetTexture("Interface\\ChatFrame\\UI-ChatInputBorder-Left")
		left:SetTexCoord(0, 100 / 256, 0, 1)
		left:SetWidth(colorful and 125 or 140)
		left:SetHeight(32)
		left:SetPoint("LEFT", editBox, "LEFT", -10, 0)
		local right = editBox:CreateTexture(nil, "BACKGROUND")
		right:SetTexture("Interface\\ChatFrame\\UI-ChatInputBorder-Right")
		right:SetTexCoord(156/256, 1, 0, 1)
		right:SetWidth(colorful and 125 or 140)
		right:SetHeight(32)
		right:SetPoint("RIGHT", editBox, "RIGHT", 10, 0)
		
		local label = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		label:SetPoint("RIGHT", editBox, "LEFT", -20, 0)
		label:SetPoint("LEFT", frame, "LEFT", 20, 0)
		label:SetPoint("TOP", editBox, "TOP")
		label:SetPoint("BOTTOM", editBox, "BOTTOM")
		label:SetJustifyH("RIGHT")
		label:SetText(text)
		
		if colorful then
			local button = CreateFrame("Button", nil, editBox)
			button:SetPoint("LEFT", editBox, "RIGHT", 20, 0)
			button:SetWidth(16)
			button:SetHeight(16)
			local texture = button:CreateTexture("ARTWORK")
			texture:SetAllPoints(button)
			texture:SetTexture(1, 1, 1)
			local function changeColor(r, g, b)
				texture:SetTexture(r, g, b)
				editBox:SetTextColor(r, g, b)
				Dewdrop:Close()
			end
			function editBox.resetColor(r, g, b)
				if not r then
					r, g, b = 1, 1, 1
				end
				texture:SetTexture(r, g, b)
				editBox:SetTextColor(r, g, b)
			end
			button:SetScript("OnClick", function()
				Dewdrop:Register(button,
					'children', function()
						Dewdrop:AddLine(
							'text', L["White"],
							'textR', 1,
							'textG', 1,
							'textB', 1,
							'func', changeColor,
							'arg1', 1,
							'arg2', 1,
							'arg3', 1
						)
						Dewdrop:AddLine(
							'text', L["Gray"],
							'textR', 0.8,
							'textG', 0.8,
							'textB', 0.8,
							'func', changeColor,
							'arg1', 0.8,
							'arg2', 0.8,
							'arg3', 0.8
						)
						Dewdrop:AddLine(
							'text', L["Pink"],
							'textR', 1,
							'textG', 0.62,
							'textB', 0.59,
							'func', changeColor,
							'arg1', 1,
							'arg2', 0.62,
							'arg3', 0.59
						)
						Dewdrop:AddLine(
							'text', L["Red"],
							'textR', 1,
							'textG', 0.24,
							'textB', 0.17,
							'func', changeColor,
							'arg1', 1,
							'arg2', 0.24,
							'arg3', 0.17
						)
						Dewdrop:AddLine(
							'text', L["Orange"],
							'textR', 0.98,
							'textG', 0.57,
							'textB', 0,
							'func', changeColor,
							'arg1', 0.98,
							'arg2', 0.57,
							'arg3', 0
						)
						Dewdrop:AddLine(
							'text', L["Yellow"],
							'textR', 1,
							'textG', 0.92,
							'textB', 0,
							'func', changeColor,
							'arg1', 1,
							'arg2', 0.92,
							'arg3', 0
						)
						Dewdrop:AddLine(
							'text', L["Green"],
							'textR', 0,
							'textG', 0.7,
							'textB', 0,
							'func', changeColor,
							'arg1', 0,
							'arg2', 0.7,
							'arg3', 0
						)
						Dewdrop:AddLine(
							'text', L["Lime"],
							'textR', 0.04,
							'textG', 0.95,
							'textB', 0,
							'func', changeColor,
							'arg1', 0.04,
							'arg2', 0.95,
							'arg3', 0
						)
						Dewdrop:AddLine(
							'text', L["Cyan"],
							'textR', 0,
							'textG', 1,
							'textB', 1,
							'func', changeColor,
							'arg1', 0,
							'arg2', 1,
							'arg3', 1
						)
						Dewdrop:AddLine(
							'text', L["Blue"],
							'textR', 0,
							'textG', 0.71,
							'textB', 1,
							'func', changeColor,
							'arg1', 0,
							'arg2', 0.71,
							'arg3', 1
						)
						Dewdrop:AddLine(
							'text', L["Pale blue"],
							'textR', 0.7,
							'textG', 0.82,
							'textB', 0.88,
							'func', changeColor,
							'arg1', 0.7,
							'arg2', 0.82,
							'arg3', 0.88
						)
						Dewdrop:AddLine(
							'text', L["Purple"],
							'textR', 0.83,
							'textG', 0.22,
							'textB', 0.9,
							'func', changeColor,
							'arg1', 0.83,
							'arg2', 0.22,
							'arg3', 0.9
						)
					end,
					'dontHook', true,
					'point', "TOPRIGHT",
					'relativePoint', "BOTTOMRIGHT"
				)
				button:SetScript("OnClick", function()
					if Dewdrop:IsOpen(button) then
						Dewdrop:Close()
					else
						Dewdrop:Open(button)
					end
					PlaySound("igMainMenuOptionCheckBoxOn")
				end)
				button:GetScript("OnClick")()
			end)
		end
		
		return editBox
	end
	
	frame.xEditBox = make(L["X position"])
	frame.yEditBox = make(L["Y position"])
	frame.zone = make(ZONE or "Zone")
	frame.zone:SetScript("OnEditFocusGained", function()
		this:ClearFocus()
	end)
	frame.title = make(L["Title"], true)
	frame.info1 = make(L["Info line 1 (optional)"], true)
	frame.info2 = make(L["Info line 2 (optional)"], true)
	frame.creator = make(L["Creator (optional)"])
	
	frame.xEditBox:SetScript("OnTabPressed", function()
		this:ClearFocus()
		frame.yEditBox:SetFocus()
	end)
	frame.yEditBox:SetScript("OnTabPressed", function()
		this:ClearFocus()
		frame.title:SetFocus()
	end)
	frame.zone:SetScript("OnTabPressed", frame.yEditBox:GetScript("OnTabPressed"))
	frame.title:SetScript("OnTabPressed", function()
		this:ClearFocus()
		frame.info1:SetFocus()
	end)
	frame.info1:SetScript("OnTabPressed", function()
		this:ClearFocus()
		frame.info2:SetFocus()
	end)
	frame.info2:SetScript("OnTabPressed", function()
		this:ClearFocus()
		frame.creator:SetFocus()
	end)
	frame.creator:SetScript("OnTabPressed", function()
		this:ClearFocus()
	end)
	function isGood()
		if frame.title:GetText() == "" then
			return false
		end
		local x = tonumber(frame.xEditBox:GetText())
		if not x then
			return false
		elseif x < 0 or x > 100 then
			return false
		end
		local y = tonumber(frame.yEditBox:GetText())
		if not y then
			return false
		elseif y < 0 or y > 100 then
			return false
		end
		return true
	end
	
	local icon = CreateFrame("Frame", "CartographerNotesNewNoteFrameIcon", frame)
	frame.icon = icon
	icon:SetPoint("TOPLEFT", frame.creator, "BOTTOMLEFT", -20, -10)
	icon:SetWidth(frame:GetWidth()/2 - 25)
	icon:SetHeight(30)
	
	local texture = icon:CreateTexture(nil, "ARTWORK")
	texture:SetTexture("Interface\\Glues\\CharacterCreate\\CharacterCreate-LabelFrame")
	texture:SetWidth(25)
	texture:SetHeight(64)
	texture:SetPoint("TOPLEFT", icon, "TOPLEFT", 0, 17)
	texture:SetTexCoord(0, 0.1953125, 0, 1)
	
	local texture2 = icon:CreateTexture(nil, "ARTWORK")
	texture2:SetTexture("Interface\\Glues\\CharacterCreate\\CharacterCreate-LabelFrame")
	texture2:SetWidth(115)
	texture2:SetHeight(64)
	texture2:SetPoint("LEFT", texture, "RIGHT")
	texture2:SetTexCoord(0.1953125, 0.8046875, 0, 1)
	
	local texture3 = icon:CreateTexture(nil, "ARTWORK")
	texture3:SetTexture("Interface\\Glues\\CharacterCreate\\CharacterCreate-LabelFrame")
	texture3:SetWidth(25)
	texture3:SetHeight(64)
	texture3:SetPoint("LEFT", texture2, "RIGHT")
	texture3:SetTexCoord(0.8046875, 1, 0, 1)
	
	local fontstring = icon:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	fontstring:SetJustifyH("RIGHT")
	fontstring:SetWidth(0)
	fontstring:SetHeight(10)
	fontstring:SetPoint("RIGHT", texture3, "RIGHT", -43, 2)
	
	local image = icon:CreateTexture(nil, "OVERLAY")
	image:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
	image:SetWidth(16)
	image:SetHeight(16)
	image:SetTexCoord(0, 0.25, 0, 0.25)
	image:SetPoint("LEFT", texture, "LEFT", 20, 0)
	
	local button = CreateFrame("Button", "CartographerNotesNewNoteFrameIconButton", icon)
	button:SetWidth(24)
	button:SetHeight(24)
	button:SetPoint("TOPRIGHT", texture3, "TOPRIGHT", -16, -18)
	button:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Up")
	button:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Down")
	button:SetDisabledTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Disabled")
	button:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")
	local iconSelector = function(k)
		icon.value = k
		local t = icons[k]
		if string.find(k, "^Interface\\") then
			if frame.title:GetText() == fontstring:GetText() then
				frame.title:SetText(L["Custom icon"])
			end
			fontstring:SetText(L["Custom icon"])
			fontstring:SetTextColor(1, 1, 1)
			image:SetTexture(k)
			if string.find(k, "^Interface\\Icons\\") then
				image:SetTexCoord(0.05, 0.95, 0.05, 0.95)
			else
				image:SetTexCoord(0, 1, 0, 1)
			end
			Dewdrop:Close()
			return
		end
		if not t then
			t = icons.Unknown
		end
		if frame.title:GetText() == fontstring:GetText() then
			frame.title:SetText(t.text)
		end
		fontstring:SetText(t.text)
		fontstring:SetTextColor(t.r or 1, t.g or 1, t.b or 1)
		image:SetTexture(t.path)
		image:SetTexCoord(t.cLeft or 0, t.cRight or 1, t.cTop or 0, t.cBottom or 1)
		Dewdrop:Close()
	end
	frame.iconSelector = iconSelector
	button:SetScript("OnClick", function()
		local t = {}
		local mysort = function(alpha, bravo)
			if not alpha or not bravo then
				return false
			end
			local alpha_text = icons[alpha].text or alpha
			local bravo_text = icons[bravo].text or alpha
			return alpha_text < bravo_text
		end
		Dewdrop:Register(icon,
			'children', function()
				for k, v in pairs(icons) do
					if v.showToUser then
						table.insert(t, k)
					end
				end
				table.sort(t, mysort)
				for _, k in ipairs(t) do
					local v = icons[k]
					Dewdrop:AddLine(
						'text', v.text or k,
						'textR', v.r or 1,
						'textG', v.g or 1,
						'textB', v.b or 1,
						'icon', v.path,
						'iconCoordLeft', v.cLeft or 0,
						'iconCoordRight', v.cRight or 1,
						'iconCoordTop', v.cTop or 0,
						'iconCoordBottom', v.cBottom or 1,
						'func', iconSelector,
						'arg1', k
					)
				end
				for i = 1, table.getn(t) do
					t[i] = nil
				end
				table_setn(t, 0)
			end,
			'dontHook', true,
			'point', "TOPLEFT",
			'relativePoint', "BOTTOMLEFT"
		)
		button:SetScript("OnClick", function()
			if Dewdrop:IsOpen(icon) then
				Dewdrop:Close()
			else
				Dewdrop:Open(icon)
			end
			PlaySound("igMainMenuOptionCheckBoxOn")
		end)
		button:GetScript("OnClick")()
	end)
	icon:SetScript("OnHide", function()
		if Dewdrop:IsOpen(icon) then
			Dewdrop:Close()
		end
	end)
	
	okayButton:SetScript("OnClick", function()
		local r,g,b = frame.title:GetTextColor()
		local r2,g2,b2 = frame.info1:GetTextColor()
		local r3,g3,b3 = frame.info2:GetTextColor()
		local x, y = tonumber(frame.xEditBox:GetText())/100, tonumber(frame.yEditBox:GetText())/100
		x,y,r,g,b,r2,g2,b2,r3,g3,b3 = round(x, 3),round(y, 3),round(r, 2),round(g, 2),round(b, 2),round(r2, 2),round(g2, 2),round(b2, 2),round(r3, 2),round(g3, 2),round(b3, 2)
		self:SetNote(frame.zonename, x, y, frame.icon.value, frame.creator:GetText(),
			'title', frame.title:GetText(),
			'titleR', r,
			'titleG', g,
			'titleB', b,
			'info', frame.info1:GetText(),
			'infoR', r2,
			'infoG', g2,
			'infoB', b2,
			'info2', frame.info2:GetText(),
			'info2R', r3,
			'info2G', g3,
			'info2B', b3,
			'manual', true,
			'oldId', frame.id)
		frame:Hide()
	end)
	
	return frame
end

local possibleIcons
function Cartographer_Notes:OpenNewNoteFrame(x, y, creator)
	if not Cartographer:GetCurrentEnglishZoneName() then
		return
	end
	AceLibrary.argCheck(self, x, 2, "number")
	AceLibrary.argCheck(self, y, 3, "number")
	AceLibrary.argCheck(self, creator, 4, "string", "nil")
	if x < 0 or x > 1 then
		error(string.format("Argument #3 is expected to be [0, 1], got %s", x), 2)
	end
	if y < 0 or y > 1 then
		error(string.format("Argument #4 is expected to be [0, 1], got %s", y), 2)
	end
	
	local frame = GetNoteDialog()
	frame.header:SetText(L["New note"])
	frame.id = nil
	frame.xEditBox:SetText(string.format("%.1f", x*100))
	frame.yEditBox:SetText(string.format("%.1f", y*100))
	frame.zone:SetText(Cartographer:GetCurrentLocalizedZoneName())
	frame.title:SetText("")
	frame.title.resetColor()
	frame.info1:SetText("")
	frame.info1.resetColor()
	frame.info2:SetText("")
	frame.info2.resetColor()
	frame.creator:SetText(creator or UnitName("player"))
	frame:Show()
	frame.title:SetFocus()
	if not possibleIcons then
		possibleIcons = {}
	end
	for k in pairs(possibleIcons) do
		possibleIcons[k] = nil
	end
	table_setn(possibleIcons, 0)
	for k,v in pairs(icons) do
		if v.showToUser then
			table.insert(possibleIcons, k)
		end
	end
	frame.iconSelector(possibleIcons[math.random(1, table.getn(possibleIcons))])
	frame.zonename = Cartographer:GetCurrentEnglishZoneName()
end

function Cartographer_Notes:ShowEditDialog(zone, x, y)
	AceLibrary.argCheck(self, zone, 2, "string")
	local id
	if not y then
		id = x
		AceLibrary.argCheck(self, x, 3, "number")
	else
		AceLibrary.argCheck(self, x, 3, "number")
		AceLibrary.argCheck(self, y, 4, "number")
		if x < 0 or x > 1 then
			error(string.format("Argument #4 is expected to be [0, 1], got %s", x), 2)
		end
		if y < 0 or y > 1 then
			error(string.format("Argument #5 is expected to be [0, 1], got %s", y), 2)
		end
		id = getID(x, y)
	end
	
	local data, db = getrawpoi(zone, id)
	if not data then
		return
	end
	local frame = GetNoteDialog()
	frame.header:SetText(L["Edit note"])
	frame.id = id
	local x, y = getXY(id)
	frame.xEditBox:SetText(string.format("%.1f", x*100))
	frame.yEditBox:SetText(string.format("%.1f", y*100))
	frame.zone:SetText(BZ[zone])
	if type(data) == "table" then
		frame.title:SetText(data.title or getIconTitle(data.icon))
		frame.title.resetColor(data.titleR or 1, data.titleG or 1, data.titleB or 1)
		frame.info1:SetText(data.info or "")
		frame.info1.resetColor(data.infoR or 1, data.infoG or 1, data.infoB or 1)
		frame.info2:SetText(data.info2 or "")
		frame.info2.resetColor(data.info2R or 1, data.info2G or 1, data.info2B or 1)
		frame.creator:SetText(db or data.creator or "")
		frame.iconSelector(data.icon)
	else
		frame.title:SetText(getIconTitle(data))
		frame.title.resetColor(1, 1, 1)
		frame.info1:SetText("")
		frame.info1.resetColor(1, 1, 1)
		frame.info2:SetText("")
		frame.info2.resetColor(1, 1, 1)
		frame.creator:SetText(db)
		frame.iconSelector(data)
	end
	frame:Show()
	frame.title:SetFocus()
	frame.zonename = zone
end

local pois
do
	local cache = {}
	
	local num_pois = 0
	
	local OnMouseDown, OnMouseUp, OnEnter, OnLeave, OnClick
	
	local dummy
	local function newpoi()
		local x = next(cache)
		if x then
			cache[x] = nil
			x:Show()
			return x
		end
		
		num_pois = num_pois + 1
		
		local frame = CreateFrame("Button", "CartographerNotesPOI" .. num_pois, WorldMapButton)
		
		frame:EnableMouse(true)
		frame:SetMovable(true)
		frame:SetWidth(16)
		frame:SetHeight(16)
		frame:SetPoint("CENTER", WorldMapButton, "CENTER")
		
		local texture = frame:CreateTexture(nil, "OVERLAY")
		frame.texture = texture
		texture:SetAllPoints(frame)
		texture:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
		texture:SetTexCoord(0, 0.25, 0, 0.25)
		
		frame:SetFrameLevel(frame:GetFrameLevel()+3)
		frame:RegisterForClicks("LeftButtonUp", "RightButtonUp")
		if not OnMouseDown then
			OnMouseDown = function()
				if arg1 == "LeftButton" and IsAltKeyDown() then
					if this.manual then
						this.isMoving = true
						this:StartMoving()
					end
				end
			end
		end
		frame:SetScript("OnMouseDown", OnMouseDown)
		
		if not OnMouseUp then
			OnMouseUp = function()
        if not Dewdrop:IsOpen(this) then
          local this = this
          if arg1 == "LeftButton" then
            if this.isMoving then
              this:StopMovingOrSizing()
              this.isMoving = nil
              local x, y = this:GetCenter()
              local parent = this:GetParent()
              local left, top = parent:GetLeft(), parent:GetTop()
              local width = parent:GetWidth()
              local height = parent:GetHeight()
              x = (x - left) / width
              y = (top - y) / height
              
              x, y = round(x, 3), round(y, 3)
              if x > 1 then
                x = 1
              end
              if x < 0 then
                x = 0
              end
              if y > 1 then
                y = 1
              end
              if y < 0 then
                y = 0
              end
              local id = getID(x, y)
              if id ~= this.id then
                pois[id] = pois[this.id]
                pois[this.id] = nil
                local t, db = getpoi(this.zone, this.id)
                if db then
                  local v = self.externalDBs[db]
                  v[this.zone][id] = t
                  v[this.zone][this.id] = nil
                  self:ShowNote(this.zone, id, db)
                else
                  self.db.account.pois[this.zone][id] = t
                  self.db.account.pois[this.zone][this.id] = nil
                  self:ShowNote(this.zone, id, t.creator or "")
                end
              end
            end
          end
        end
			end
		end
		frame:SetScript("OnMouseUp", OnMouseUp)
		
		if not OnEnter then
			local dummy
			local currentFrame
			OnEnter = function()
        local this = this
				local WorldMapTooltip = WorldMapTooltip
				local x, y = this:GetCenter()
				local x2, y2 = WorldMapButton:GetCenter()
				local anchor = ""
				if x > x2 then
					anchor = "ANCHOR_LEFT"
				else
					anchor = "ANCHOR_RIGHT"
				end
				
				WorldMapTooltip:SetOwner(this, anchor)
				WorldMapTooltip:SetText(this.title, this.titleR, this.titleG, this.titleB)
				if this.info then
					WorldMapTooltip:AddLine(this.info, this.infoR, this.infoG, this.infoB)
				end
				if this.info2 then
					WorldMapTooltip:AddLine(this.info2, this.info2R, this.info2G, this.info2B)
				end
				if this.creator then
					WorldMapTooltip:AddDoubleLine("Created by", this.creator)
				end
				WorldMapTooltip:Show()
			end
		end
		frame:SetScript("OnEnter", OnEnter)
		
		if not OnLeave then
			OnLeave = function()
				WorldMapTooltip:Hide()
				GameTooltip:Hide()
			end
		end
		frame:SetScript("OnLeave", OnLeave)
		
		if not OnClick then
			local poi
			OnClick = function()
				if arg1 == "LeftButton" then
					if self.handlers[this.creator] and type(self.handlers[this.creator].OnNoteClick) == "function" then
						self.handlers[this.creator]:OnNoteClick(this.zone, this.id)
					end
				elseif arg1 == "RightButton" then
					if not dummy then
						dummy = CreateFrame("Frame")
						local function editNoteFunc()
							self:ShowEditDialog(poi.zone, poi.id)
							Dewdrop:Close()
						end
						local function deleteNoteFunc()
							self:DeleteNote(poi.zone, poi.id)
							Dewdrop:Close()
						end
						local function closeFunc()
							Dewdrop:Close()
						end
						local function sendNoteToPartyFunc()
							self:SendNoteToParty(poi.zone, getXY(poi.id))
						end
						local function sendNoteToRaidFunc()
							self:SendNoteToRaid(poi.zone, getXY(poi.id))
						end
						local function sendNoteToGuildFunc()
							self:SendNoteToGuild(poi.zone, getXY(poi.id))
						end
						local function sendNoteToPlayerFunc(player)
							local x, y = getXY(poi.id)
							self:SendNoteToPlayer(poi.zone, x, y, player)
						end
						local function sendNoteToPlayerValidate(player)
							return string.find(player, "^[A-Za-z][A-Za-z]+$")
						end
						Dewdrop:Register(dummy,
							'children', function(level, value, level2, level3, level4)
								if self.handlers[poi.creator] and type(self.handlers[poi.creator].OnNoteMenuRequest) == "function" then
									self.handlers[poi.creator]:OnNoteMenuRequest(poi.zone, poi.id, level, value, level2, level3, level4)
								else
									if level == 1 then
										if poi.manual then
											Dewdrop:AddLine(
												'text', L["Edit note"],
												'func', editNoteFunc
											)
										end
										Dewdrop:AddLine(
											'text', L["Delete note"],
											'func', deleteNoteFunc
										)
										Dewdrop:AddLine()
										Dewdrop:AddLine(
											'text', L["Send note"],
											'hasArrow', true,
											'value', 'send'
										)
										Dewdrop:AddLine()
										Dewdrop:AddLine(
											'text', CANCEL,
											'func', closeFunc
										)
									elseif level == 2 then
										if value == 'send' then
											local bit = false
											if GetNumPartyMembers() > 0 then
												Dewdrop:AddLine(
													'text', L["Send to party"],
													'func', sendNoteToPartyFunc
												)
												bit = true
											end
											if GetNumRaidMembers() > 0 then
												Dewdrop:AddLine(
													'text', L["Send to raid"],
													'func', sendNoteToRaidFunc
												)
												bit = true
											end
											if IsInGuild() then
												Dewdrop:AddLine(
													'text', L["Send to guild"],
													'func', sendNoteToGuildFunc
												)
												bit = true
											end
											
											if bit then
												Dewdrop:AddLine()
											end
											
											Dewdrop:AddLine(
												'text', L["Send to player"],
												'tooltipTitle', L["Send to player"],
												'tooltipText', L["Note: This may be blocked by Blizzard's spam filter and cause problems. It is recommended to send to your party/raid/guild instead."],
												'hasArrow', true,
												'hasEditBox', true,
												'editBoxText', UnitExists("target") and UnitIsPlayer("target") and UnitIsFriendly("target") and UnitName("target") or nil,
												'editBoxFunc', sendNoteToPlayerFunc,
												'editBoxValidateFunc', sendNoteToPlayerValidate
											)
										end
									end
								end
							end,
							'dontHook', true
						)
					end
					poi = this
					if Dewdrop:IsOpen(poi) then
						Dewdrop:Close()
						poi:GetScript("OnEnter")(poi)
					else
						Dewdrop:Open(poi, dummy)
						Tablet:Close()
					end
				end
			end
		end
		frame:SetScript("OnClick", OnClick)
		
		return frame
	end
	
	local function delpoi(x)
		x:Hide()
		cache[x] = true
		return nil
	end
	
	pois = setmetatable({ del = function(self, id)
		if id == 'del' then
			return
		end
		local x = rawget(self, id)
		rawset(self, id, nil)
		if x then
			delpoi(x)
		end
	end }, { __index = function(self, id)
		local frame = newpoi()
		rawset(self, id, frame)
		return frame
	end })
end

local cache = {}
function Cartographer_Notes:SetNote(zone, x, y, icon, creator, k1, v1, k2, v2, k3, v3, k4, v4, k5, v5, k6, v6, k7, v7, k8, v8, k9, v9, k10, v10, k11, v11, k12, v12, k13, v13, k14, v14, k15, v15, k16, v16, k17, v17, k18, v18, k19, v19, k20, v20)
	AceLibrary.argCheck(self, zone, 2, "string")
	AceLibrary.argCheck(self, x, 3, "number")
	AceLibrary.argCheck(self, y, 4, "number")
	AceLibrary.argCheck(self, icon, 5, "string")
	AceLibrary.argCheck(self, creator, 6, "string")
	if not BZ:HasTranslation(zone) then
		if BZ:HasReverseTranslation(zone) then
			zone = BZ:GetReverseTranslation(zone)
		else
			error(string.format("Trying to set a note with an unknown zone: %q", zone), 2)
		end
	end
	if x < 0 or x > 1 then
		error(string.format("Argument #3 is expected to be [0, 1], got %s", x), 2)
	end
	if y < 0 or y > 1 then
		error(string.format("Argument #4 is expected to be [0, 1], got %s", y), 2)
	end
	
	local usingDB = self.externalDBs[creator] and creator or nil
	
	local id = getID(x, y)
	
	if usingDB and not self.externalDBs[creator][zone] then
		self.externalDBs[creator][zone] = {}
	end
	local zoneData = usingDB and self.externalDBs[creator][zone] or self.db.account.pois[zone]
	local oldData = rawget(zoneData, id)
	if type(oldData) == "table" then
		local tmp = oldData
		oldData = cache
		for k,v in pairs(tmp) do
			oldData[k] = v
		end
	end
	if not k1 and usingDB then
		zoneData[id] = icon
	else
		local t
		if not zoneData[id] then
			zoneData[id] = {}
		end
		t = zoneData[id]
		for k,v in pairs(t) do
			t[k] = nil
		end
		if type(k1) ~= "table" then
			if k1 then t[k1] = v1
			if k2 then t[k2] = v2
			if k3 then t[k3] = v3
			if k4 then t[k4] = v4
			if k5 then t[k5] = v5
			if k6 then t[k6] = v6
			if k7 then t[k7] = v7
			if k8 then t[k8] = v8
			if k9 then t[k9] = v9
			if k10 then t[k10] = v10
			if k11 then t[k11] = v11
			if k12 then t[k12] = v12
			if k13 then t[k13] = v13
			if k14 then t[k14] = v14
			if k15 then t[k15] = v15
			if k16 then t[k16] = v16
			if k17 then t[k17] = v17
			if k18 then t[k18] = v18
			if k19 then t[k19] = v19
			if k20 then t[k20] = v20
			end end end end end end end end end end end end end end end end end end end end
		else
			for k,v in pairs(k1) do
				t[k] = v
			end
		end
		t.icon = icon
		if not usingDB then
			t.creator = creator
		end
		local oldId = t.oldId
		t.oldId = nil
		if oldId and oldId ~= id then
			local oldicon
			if rawget(zoneData, oldId) then
				oldicon = zoneData[oldId]
				zoneData[oldId] = nil
				if type(oldicon) == "table" then
					oldicon = oldicon.icon
				end
			end
			if zone == Cartographer:GetCurrentEnglishZoneName() then
				pois[id] = pois[oldId]
				pois[oldId] = nil
			end
			if oldicon then
				local oldx, oldy = getXY(oldId)
				self:TriggerEvent("CartographerNotes_NoteDeleted", zone, oldx, oldy, oldicon, usingDB)
			end
		end
		if t.title == getIconTitle(icon) then
			t.title = nil
		end
		if t.titleR == 1 then
			t.titleR = nil
		end
		if t.titleG == 1 then
			t.titleG = nil
		end
		if t.titleB == 1 then
			t.titleB = nil
		end
		if t.info == "" then
			t.info = nil
		end
		if t.infoR == 1 then
			t.infoR = nil
		end
		if t.infoG == 1 then
			t.infoG = nil
		end
		if t.infoB == 1 then
			t.infoB = nil
		end
		if t.info2 == "" then
			t.info2 = nil
		end
		if t.info2R == 1 then
			t.info2R = nil
		end
		if t.info2G == 1 then
			t.info2G = nil
		end
		if t.info2B == 1 then
			t.info2B = nil
		end
		if usingDB then
			t.creator = nil
			t.manual = nil
		end
		if creator == "" then
			t.creator = nil
		end
		if next(t) == 'icon' and next(t, 'icon') == nil then
			zoneData[id] = t.icon
		end
	end
	local different = false
	local newData = zoneData[id]
	if type(oldData) ~= type(newData) then
		different = true
	elseif type(oldData) ~= "table" then
		different = oldData ~= newData
	else
		for k,v in pairs(oldData) do
			if newData[k] ~= v then
				different = true
				break
			end
		end
		if not different then
			for k,v in pairs(newData) do
				if oldData[k] ~= v then
					different = true
					break
				end
			end
		end
	end
	for k,v in pairs(cache) do
		cache[k] = nil
	end
	if not different then
		return false
	end
	self:TriggerEvent("CartographerNotes_NoteSet", zone, x, y, icon, creator)
	if zone ~= Cartographer:GetCurrentEnglishZoneName() then
		return true
	end
	self:ShowNote(zone, id, creator)
	return true
end
local d = tonumber(date("%Y%m%d"))
if d < 20061204 then
	Cartographer_Notes.SetCustomNote = Cartographer_Notes.SetNote
else
	function Cartographer_Notes:SetCustomNote(zone, x, y, icon, creator, k1, v1, k2, v2, k3, v3, k4, v4, k5, v5, k6, v6, k7, v7, k8, v8, k9, v9, k10, v10, k11, v11, k12, v12, k13, v13, k14, v14, k15, v15, k16, v16, k17, v17, k18, v18, k19, v19, k20, v20)
		local error = error
		if d < 20061211 then
			error = geterrorhandler()
		end
		error("`Cartographer_Notes:SetCustomNote(...)' has been deprecated. Use `Cartographer_Notes:SetNote(...)' instead.", 2)
		return self:SetNote(zone, x, y, icon, creator, k1, v1, k2, v2, k3, v3, k4, v4, k5, v5, k6, v6, k7, v7, k8, v8, k9, v9, k10, v10, k11, v11, k12, v12, k13, v13, k14, v14, k15, v15, k16, v16, k17, v17, k18, v18, k19, v19, k20, v20)
	end
end

function Cartographer_Notes:GetNote(zone, x, y)
	AceLibrary.argCheck(self, zone, 2, "string")
	AceLibrary.argCheck(self, x, 3, "number")
	AceLibrary.argCheck(self, y, 4, "number")
	if not BZ:HasTranslation(zone) then
		if BZ:HasReverseTranslation(zone) then
			zone = BZ:GetReverseTranslation(zone)
		else
			error(string.format("Trying to get a note with an unknown zone: %q", zone), 2)
		end
	end
	if x < 0 or x > 1 then
		error(string.format("Argument #3 is expected to be [0, 1], got %s", x), 2)
	end
	if y < 0 or y > 1 then
		error(string.format("Argument #4 is expected to be [0, 1], got %s", y), 2)
	end
	local id = getID(x, y)
	local data, db = getrawpoi(zone, id)
	if not data then
		return
	end
	
	return zone, x, y, type(data) == "string" and data or data.icon, db
end

function Cartographer_Notes:DeleteNote(zone, x, y)
	AceLibrary.argCheck(self, zone, 2, "string")
	AceLibrary.argCheck(self, x, 3, "number")
	AceLibrary.argCheck(self, y, 4, "nil", "number")
	if not BZ:HasTranslation(zone) then
		if BZ:HasReverseTranslation(zone) then
			zone = BZ:GetReverseTranslation(zone)
		else
			error(string.format("Trying to destroy a note with an unknown zone: %q", zone), 2)
		end
	end
	if y then
		if x < 0 or x > 1 then
			error(string.format("Argument #3 is expected to be [0, 1], got %s", x), 2)
		end
		if y < 0 or y > 1 then
			error(string.format("Argument #4 is expected to be [0, 1], got %s", y), 2)
		end
	end
	local id
	if not y then
		id = x
	else
		id = getID(x, y)
	end
	local t, db = getrawpoi(zone, id)
	if not t then
		error(string.format("Cannot destroy note %q at %q if it does not exist", id, zone), 2)
	end
	if db then
		self.externalDBs[db][zone][id] = nil
	else
		self.db.account.pois[zone][id] = nil
	end
	local icon = t
	if type(icon) == "table" then
		icon = icon.icon
	end
	self:TriggerEvent("CartographerNotes_NoteDeleted", zone, x, y, icon, db)
	if zone == Cartographer:GetCurrentEnglishZoneName() then
		pois:del(id)
	end
end

function Cartographer_Notes:ShowNote(zone, id, creator)
	if zone ~= Cartographer:GetCurrentEnglishZoneName() or not Cartographer:IsActive(self) then
		return
	end
	if creator then
		local handler = self.handlers[creator]
		if handler and handler.IsNoteHidden and handler:IsNoteHidden(zone, id) then
			return
		end
	end
	local data, db = getpoi(zone, id)
	local poi = pois[id]
	poi.zone = zone
	local icon
	local creator = db or data.creator or ""
	if type(data) == "string" then
		poi.title = getIconTitle(data)
		poi.titleR = 1
		poi.titleG = 1
		poi.titleB = 1
		poi.info = ""
		poi.infoR = 1
		poi.infoG = 1
		poi.infoB = 1
		poi.info2 = ""
		poi.info2R = 1
		poi.info2G = 1
		poi.info2B = 1
		poi.icon = data
		poi.manual = false
		icon = data
	else
		poi.title = data.title or getIconTitle(data.icon)
		poi.titleR = data.titleR or 1
		poi.titleG = data.titleG or 1
		poi.titleB = data.titleB or 1
		poi.info = data.info or ""
		poi.infoR = data.infoR or 1
		poi.infoG = data.infoG or 1
		poi.infoB = data.infoB or 1
		poi.info2 = data.info2 or ""
		poi.info2R = data.info2R or 1
		poi.info2G = data.info2G or 1
		poi.info2B = data.info2B or 1
		poi.icon = data.icon
		poi.manual = data.manual or false
		icon = data.icon
	end
	poi.creator = creator
	poi.id = id
	if self.developing == creator then
		poi.manual = true
	end
	
	local button = zone == Cartographer:GetCurrentInstance() and Cartographer:GetInstanceWorldMapButton() or WorldMapButton
	
	poi:SetParent(button)
	if string.find(icon, "^Interface\\") then
		poi:SetWidth(16*self.db.profile.iconSize)
		poi:SetHeight(16*self.db.profile.iconSize)
		poi:SetAlpha(1)
		poi.texture:SetTexture(icon)
		if string.find(icon, "^Interface\\Icons\\") then
			poi.texture:SetTexCoord(0.05, 0.95, 0.05, 0.95)
		else
			poi.texture:SetTexCoord(0, 1, 0, 1)
		end
	else
		local t = icons[icon]
		if not t then
			t = icons.Unknown
		end
		poi:SetWidth(t.width*self.db.profile.iconSize)
		poi:SetHeight(t.height*self.db.profile.iconSize)
		poi:SetAlpha(t.alpha)
		poi.texture:SetTexture(t.path)
		poi.texture:SetTexCoord(t.cLeft, t.cRight, t.cTop, t.cBottom)
	end
	poi:Show()
	
	poi:ClearAllPoints()
	local x, y = getXY(id)
	poi:SetPoint("CENTER", button, "TOPLEFT", x * button:GetWidth(), -y * button:GetHeight())
end

local lastMap = nil
function Cartographer_Notes:ClearMap()
	for k,v in pairs(pois) do
		pois:del(k)
	end
	lastMap = nil
end

local function RefreshMap(value)
	local zone = Cartographer:GetCurrentEnglishZoneName()
	if not zone or not Cartographer:IsModuleActive(self) then
		self:ClearMap()
		return
	end
	if zone == lastMap and value == false then
		return
	end
	self:ClearMap()
	if rawget(self.db.account.pois, zone) then
		for id in pairs(self.db.account.pois[zone]) do
			self:ShowNote(zone, id, false)
		end
	end
	for k,v in pairs(self.externalDBs) do
		if rawget(v, zone) then
			for id in pairs(v[zone]) do
				self:ShowNote(zone, id, k)
			end
		end
	end
	lastMap = zone
end

function Cartographer_Notes:RefreshMap(value)
	self:ScheduleEvent("CartographerNotes_RefreshMap", RefreshMap, 0, value)
end

function Cartographer_Notes:ToggleWorldMap()
	self.hooks.ToggleWorldMap()
	if CartographerNotesNewNoteFrame then
		CartographerNotesNewNoteFrame:Hide()
	end
	if not WorldMapFrame:IsShown() then
		self:ClearMap()
	end
end

function Cartographer_Notes:RegisterNotesDatabase(name, db, handler)
	AceLibrary.argCheck(self, name, 2, "string")
	AceLibrary.argCheck(self, db, 3, "table")
	AceLibrary.argCheck(self, handler, 4, "table", "nil")
	if self.externalDBs[name] then
		error("Cannot register a database already registered.", 2)
	end
	
	-- REMOVE IN A FEW DAYS (2006-11-23) --
	for k,zone in pairs(db) do
		for _,u in pairs(zone) do
			if type(u) == "table" then
				u.x = nil
				u.y = nil
			end
		end
	end
	-- REMOVE IN A FEW DAYS (2006-11-23) --
	
	-- REMOVE IN A FEW DAYS (2006-11-26) --
	for k,zone in pairs(db) do
		for l,u in pairs(zone) do
			if type(u) == "table" then
				if u.title == getIconTitle(u.icon) then
					u.title = nil
				end
				if u.titleR == 1 then
					u.titleR = nil
				end
				if u.titleG == 1 then
					u.titleG = nil
				end
				if u.titleB == 1 then
					u.titleB = nil
				end
				if u.info == "" then
					u.info = nil
				end
				if u.infoR == 1 then
					u.infoR = nil
				end
				if u.infoG == 1 then
					u.infoG = nil
				end
				if u.infoB == 1 then
					u.infoB = nil
				end
				if u.info2 == "" then
					u.info2 = nil
				end
				if u.info2R == 1 then
					u.info2R = nil
				end
				if u.info2G == 1 then
					u.info2G = nil
				end
				if u.info2B == 1 then
					u.info2B = nil
				end
				u.manual = nil
				if next(u) == "icon" and next(u, "icon") == nil then
					zone[l] = u.icon
				end
			end
		end
	end
	-- REMOVE IN A FEW DAYS (2006-11-26) --
	
	self.externalDBs[name] = db
	self.handlers[name] = handler
	
	if WorldMapFrame:IsShown() then
		local zone = Cartographer:GetCurrentEnglishZoneName()
		if rawget(db, zone) then
			for id in pairs(db[zone]) do
				self:ShowNote(zone, id, name)
			end
		end
	end
end

function Cartographer_Notes:UnregisterNotesDatabase(name)
	AceLibrary.argCheck(self, name, 2, "string")
	if not self.externalDBs[name] then
		error("Cannot unregister a database not registered.", 2)
	end
	local t = self.externalDBs[name]
	self.externalDBs[name] = nil
	self.handlers[name] = nil
	local zone = Cartographer:GetCurrentEnglishZoneName()
	if rawget(t, zone) then
		for id in pairs(t[zone]) do
			pois:del(id)
		end
	end
end

function Cartographer_Notes:EnableDevelopment(database)
	if self.developing then
		error("Cannot enable development on two databases.", 2)
	end
	AceLibrary.argCheck(self, database, 2, "string")
	self.developing = database
	
	if Cartographer:IsActive(self) then
		Cartographer:AddToMagnifyingGlass(string.format("Alt-Right-Click on map to add a default note to %q", database))
		
		self:RefreshMap()
	end
end

function Cartographer_Notes:SendNoteToPlayer(zone, x, y, player)
	AceLibrary.argCheck(self, zone, 2, "string")
	AceLibrary.argCheck(self, x, 3, "number")
	AceLibrary.argCheck(self, y, 4, "number")
	AceLibrary.argCheck(self, player, 5, "string")
	if not BZ:HasTranslation(zone) then
		if BZ:HasReverseTranslation(zone) then
			zone = BZ:GetReverseTranslation(zone)
		else
			error(string.format("Trying to set a note with an unknown zone: %q", zone), 2)
		end
	end
	if x < 0 or x > 1 then
		error(string.format("Argument #3 is expected to be [0, 1], got %s", x), 2)
	end
	if y < 0 or y > 1 then
		error(string.format("Argument #4 is expected to be [0, 1], got %s", y), 2)
	end
	if not string.find(player, "^%a%a+$") then
		error(string.format("Argument #5 in the wrong format, got %q", player), 2)
	end
	
	local data, db = getrawpoi(zone, getID(x, y))
	
	if not data then
		AceLibrary.error(self, "Cannot send note %q(%s,%s). Does not exist", zone, x*100, y*100)
	end
	
	self:SendCommMessage("WHISPER", player, "NOTE", zone, round(x*1000, 0), round(y*1000, 0), db, data)
	return true
end

local function sendNote(distribution, zone, x, y)
	local data, db = getrawpoi(zone, getID(x, y))
	
	if not data then
		AceLibrary.error("Cannot send note %q(%s,%s). Does not exist", zone, x*100, y*100)
	end
	
	self:SendCommMessage(distribution, "NOTE", zone, round(x*1000, 0), round(y*1000, 0), db, data)
	return true
end

function Cartographer_Notes:SendNoteToGuild(zone, x, y)
	AceLibrary.argCheck(self, zone, 2, "string")
	AceLibrary.argCheck(self, x, 3, "number")
	AceLibrary.argCheck(self, y, 4, "number")
	if not BZ:HasTranslation(zone) then
		if BZ:HasReverseTranslation(zone) then
			zone = BZ:GetReverseTranslation(zone)
		else
			error(string.format("Trying to set a note with an unknown zone: %q", zone), 2)
		end
	end
	if x < 0 or x > 1 then
		error(string.format("Argument #3 is expected to be [0, 1], got %s", x), 2)
	end
	if y < 0 or y > 1 then
		error(string.format("Argument #4 is expected to be [0, 1], got %s", y), 2)
	end
	if not IsInGuild() then
		return false
	end
	return sendNote("GUILD", zone, x, y)
end

function Cartographer_Notes:SendNoteToParty(zone, x, y)
	AceLibrary.argCheck(self, zone, 2, "string")
	AceLibrary.argCheck(self, x, 3, "number")
	AceLibrary.argCheck(self, y, 4, "number")
	if not BZ:HasTranslation(zone) then
		if BZ:HasReverseTranslation(zone) then
			zone = BZ:GetReverseTranslation(zone)
		else
			error(string.format("Trying to set a note with an unknown zone: %q", zone), 2)
		end
	end
	if x < 0 or x > 1 then
		error(string.format("Argument #3 is expected to be [0, 1], got %s", x), 2)
	end
	if y < 0 or y > 1 then
		error(string.format("Argument #4 is expected to be [0, 1], got %s", y), 2)
	end
	if GetNumPartyMembers() == 0 then
		return false
	end
	return sendNote("PARTY", zone, x, y)
end

function Cartographer_Notes:SendNoteToRaid(zone, x, y)
	AceLibrary.argCheck(self, zone, 2, "string")
	AceLibrary.argCheck(self, x, 3, "number")
	AceLibrary.argCheck(self, y, 4, "number")
	if not BZ:HasTranslation(zone) then
		if BZ:HasReverseTranslation(zone) then
			zone = BZ:GetReverseTranslation(zone)
		else
			error(string.format("Trying to set a note with an unknown zone: %q", zone), 2)
		end
	end
	if x < 0 or x > 1 then
		error(string.format("Argument #3 is expected to be [0, 1], got %s", x), 2)
	end
	if y < 0 or y > 1 then
		error(string.format("Argument #4 is expected to be [0, 1], got %s", y), 2)
	end
	if GetNumRaidMembers() == 0 then
		return false
	end
	return sendNote("RAID", zone, x, y)
end

function Cartographer_Notes:SendNoteToGroup(zone, x, y)
	AceLibrary.argCheck(self, zone, 2, "string")
	AceLibrary.argCheck(self, x, 3, "number")
	AceLibrary.argCheck(self, y, 4, "number")
	if not BZ:HasTranslation(zone) then
		if BZ:HasReverseTranslation(zone) then
			zone = BZ:GetReverseTranslation(zone)
		else
			error(string.format("Trying to set a note with an unknown zone: %q", zone), 2)
		end
	end
	if x < 0 or x > 1 then
		error(string.format("Argument #3 is expected to be [0, 1], got %s", x), 2)
	end
	if y < 0 or y > 1 then
		error(string.format("Argument #4 is expected to be [0, 1], got %s", y), 2)
	end
	if GetNumRaidMembers() > 0 then
		return self:SendNoteToRaid(zone, x, y)
	elseif GetNumPartyMembers() > 0 then
		return self:SendNoteToParty(zone, x, y)
	end
	return false
end

function Cartographer_Notes:IsShowingCreator()
	return self.db.profile.showCreator
end

function Cartographer_Notes:ToggleShowingCreator(value)
	if value == nil then
		value = not self.db.profile.showCreator
	end
	self.db.profile.showCreator = value
end

function Cartographer_Notes:GetIconSize()
	return self.db.profile.iconSize
end

function Cartographer_Notes:SetIconSize(value)
	self.db.profile.iconSize = value
	self:RefreshMap()
end

local cache = {}
local function iter(t)
	t.id = t.id + 1
	
	local notes = t.notes
	
	local id = notes[t.id]
	if id then
		local data = t.zoneData[id]
		
		local x, y = getXY(id)
		
		return t.zone, x, y, type(data) == "string" and data or data.icon, t.creator
	end
	
	cache[t] = true
	for k in pairs(t) do
		t[k] = nil
	end
	cache[notes] = true
	for k in pairs(notes) do
		notes[k] = nil
	end
	table_setn(notes, 0)
	return nil
end

local function retNil()
	return nil
end

local current_x, current_y
local function my_sort(alpha, bravo)
	if not alpha or not bravo then
		return false
	end
	local a_x, a_y = getXY(alpha)
	local b_x, b_y = getXY(bravo)
	a_x, a_y = a_x - current_x, a_y - current_y
	b_x, b_y = b_x - current_x, b_y - current_y
	return a_x^2 + a_y^2 < b_x^2 + b_y^2
end

function Cartographer_Notes:IterateNearbyNotes(zone, x, y, radius, creator, max_notes)
	AceLibrary.argCheck(self, zone, 2, "string")
	AceLibrary.argCheck(self, x, 3, "number")
	AceLibrary.argCheck(self, y, 4, "number")
	AceLibrary.argCheck(self, radius, 5, "number", "nil")
	AceLibrary.argCheck(self, creator, 6, "string", "nil")
	AceLibrary.argCheck(self, max_notes, 7, "number", "nil")
	
	if not BZ:HasTranslation(zone) then
		if BZ:HasReverseTranslation(zone) then
			zone = BZ:GetReverseTranslation(zone)
		else
			error(string.format("Trying to set a note with an unknown zone: %q", zone), 2)
		end
	end
	if x < 0 or x > 1 then
		error(string.format("Argument #3 is expected to be [0, 1], got %s", x), 2)
	end
	if y < 0 or y > 1 then
		error(string.format("Argument #4 is expected to be [0, 1], got %s", y), 2)
	end
	if not radius then
		radius = 2
	end
	if radius < 0 or radius > 2 then
		error(string.format("Argument #5 is expected to be [0, 2], got %s", radius), 2)
	end
	if creator and not self.externalDBs[creator] then
		error(string.format("Database %q not registered.", creator), 2)
	end
	
	local zoneData = creator and rawget(self.externalDBs[creator], zone) or rawget(self.db.account.pois, zone)
	if not zoneData or not next(zoneData) then
		return retNil
	end
	
	local radius_2 = radius^2
	
	local notes = next(cache) or {}
	cache[notes] = nil
	for i, data in pairs(zoneData) do
		local x_p, y_p = getXY(i)
		if x_p^2 + y_p^2 <= radius_2 then
			table.insert(notes, i)
		end
	end
	
	current_x, current_y = x, y
	table.sort(notes, my_sort)
	current_x, current_y = nil, nil
	
	if max_notes and max_notes > table.getn(notes) then
		for i = max_notes + 1, table.getn(notes) do
			notes[i] = nil
		end
		table_setn(notes, max_notes)
	end
	
	local t = next(cache) or {}
	cache[t] = nil
	
	t.zoneData = zoneData
	t.zone = zone
	t.creator = creator
	t.notes = notes
	t.id = 0
	
	return iter, t, nil
end

function Cartographer_Notes:GetNearbyNote(zone, x, y, radius, creator)
	AceLibrary.argCheck(self, zone, 2, "string")
	AceLibrary.argCheck(self, x, 3, "number")
	AceLibrary.argCheck(self, y, 4, "number")
	AceLibrary.argCheck(self, radius, 5, "number", "nil")
	AceLibrary.argCheck(self, creator, 6, "string", "nil")
	
	if not BZ:HasTranslation(zone) then
		if BZ:HasReverseTranslation(zone) then
			zone = BZ:GetReverseTranslation(zone)
		else
			error(string.format("Trying to set a note with an unknown zone: %q", zone), 2)
		end
	end
	if x < 0 or x > 1 then
		error(string.format("Argument #3 is expected to be [0, 1], got %s", x), 2)
	end
	if y < 0 or y > 1 then
		error(string.format("Argument #4 is expected to be [0, 1], got %s", y), 2)
	end
	if not radius then
		radius = 2
	end
	if radius < 0 or radius > 2 then
		error(string.format("Argument #5 is expected to be [0, 2], got %s", radius), 2)
	end
	if creator and not self.externalDBs[creator] then
		error(string.format("Database %q not registered.", creator), 2)
	end
	
	local zoneData = creator and rawget(self.externalDBs[creator], zone) or rawget(self.db.account.pois, zone)
	if not zoneData or not next(zoneData) then
		return
	end
	local radius_2 = radius^2
	
	local close_distance = 2
	local close_id
	
	for id, data in pairs(zoneData) do
		local x_p, y_p = getXY(id)
		
		local x_d, y_d = x_p - x, y_p - y
		
		local d_2 = x_d^2 + y_d^2
		
		if d_2 <= radius_2 and d_2 < close_distance then
			close_distance = d_2
			close_id = id
		end
	end
	if not close_id then
		return
	end
	local x_p, y_p = getXY(close_id)
	local data = zoneData[close_id]
	return zone, x_p, y_p, type(data) == "string" and data or data.icon, creator
end

function Cartographer_Notes:OnProfileEnable()
	self:RefreshMap()
end
