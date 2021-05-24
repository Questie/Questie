--[[-----------------------------------------------------------------------------
TabGroup Container
Container that uses tabs on top to switch between groups.
-------------------------------------------------------------------------------]]
local Type, Version = "TabGroup", 37
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

-- Lua APIs
local pairs, ipairs, assert, type, wipe = pairs, ipairs, assert, type, wipe

-- WoW APIs
local PlaySound = PlaySound
local CreateFrame, UIParent = CreateFrame, UIParent
local _G = _G

-- Global vars/functions that we don't upvalue since they might get hooked, or upgraded
-- List them here for Mikk's FindGlobals script
-- GLOBALS: PanelTemplates_TabResize, PanelTemplates_SetDisabledTabState, PanelTemplates_SelectTab, PanelTemplates_DeselectTab

-- local upvalue storage used by BuildTabs
local widths = {}
local rowwidths = {}
local rowends = {}

--[[-----------------------------------------------------------------------------
Support functions
-------------------------------------------------------------------------------]]
local function UpdateTabLook(frame)
	if frame.disabled then
		PanelTemplates_SetDisabledTabState(frame)
	elseif frame.selected then
		PanelTemplates_SelectTab(frame)
	else
		PanelTemplates_DeselectTab(frame)
	end
end

local function Tab_SetText(frame, text)
	frame:_SetText(text)
	local width = frame.obj.frame.width or frame.obj.frame:GetWidth() or 0
	PanelTemplates_TabResize(frame, 0, nil, nil, width, frame:GetFontString():GetStringWidth())
end

local function Tab_SetSelected(frame, selected)
	frame.selected = selected
	UpdateTabLook(frame)
end

local function Tab_SetDisabled(frame, disabled)
	frame.disabled = disabled
	UpdateTabLook(frame)
end

local function BuildTabsOnUpdate(frame)
	local self = frame.obj
	self:BuildTabs()
	frame:SetScript("OnUpdate", nil)
end

--[[-----------------------------------------------------------------------------
Scripts
-------------------------------------------------------------------------------]]
local function Tab_OnClick(frame)
	if not (frame.selected or frame.disabled) then
		PlaySound(841) -- SOUNDKIT.IG_CHARACTER_INFO_TAB
		frame.obj:SelectTab(frame.value)
	end
end

local function Tab_OnEnter(frame)
	local self = frame.obj
	self:Fire("OnTabEnter", self.tabs[frame.id].value, frame)
end

local function Tab_OnLeave(frame)
	local self = frame.obj
	self:Fire("OnTabLeave", self.tabs[frame.id].value, frame)
end

local function Tab_OnShow(frame)
	_G[frame:GetName().."HighlightTexture"]:SetWidth(frame:GetTextWidth() + 30)
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
local methods = {
	["OnAcquire"] = function(self)
		self:SetTitle()
	end,

	["OnRelease"] = function(self)
		self.status = nil
		for k in pairs(self.localstatus) do
			self.localstatus[k] = nil
		end
		self.tablist = nil
		for _, tab in pairs(self.tabs) do
			tab:Hide()
		end
	end,

	["CreateTab"] = function(self, id)
		local tabname = ("AceGUITabGroup%dTab%d"):format(self.num, id)
		local tab = CreateFrame("Button", tabname, self.border, "OptionsFrameTabButtonTemplate")
		tab.obj = self
		tab.id = id

		tab.text = _G[tabname .. "Text"]
		tab.text:ClearAllPoints()
		tab.text:SetPoint("LEFT", 14, -3)
		tab.text:SetPoint("RIGHT", -12, -3)

		tab:SetScript("OnClick", Tab_OnClick)
		tab:SetScript("OnEnter", Tab_OnEnter)
		tab:SetScript("OnLeave", Tab_OnLeave)
		tab:SetScript("OnShow", Tab_OnShow)

		tab._SetText = tab.SetText
		tab.SetText = Tab_SetText
		tab.SetSelected = Tab_SetSelected
		tab.SetDisabled = Tab_SetDisabled

		return tab
	end,

	["SetTitle"] = function(self, text)
		self.titletext:SetText(text or "")
		if text and text ~= "" then
			self.alignoffset = 25
		else
			self.alignoffset = 18
		end
		self:BuildTabs()
	end,

	["SetStatusTable"] = function(self, status)
		assert(type(status) == "table")
		self.status = status
	end,

	["SelectTab"] = function(self, value)
		local status = self.status or self.localstatus
		local found
		for i, v in ipairs(self.tabs) do
			if v.value == value then
				v:SetSelected(true)
				found = true
			else
				v:SetSelected(false)
			end
		end
		status.selected = value
		if found then
			self:Fire("OnGroupSelected",value)
		end
	end,

	["SetTabs"] = function(self, tabs)
		self.tablist = tabs
		self:BuildTabs()
	end,


	["BuildTabs"] = function(self)
		local hastitle = (self.titletext:GetText() and self.titletext:GetText() ~= "")
		local tablist = self.tablist
		local tabs = self.tabs

		if not tablist then return end

		local width = self.frame.width or self.frame:GetWidth() or 0

		wipe(widths)
		wipe(rowwidths)
		wipe(rowends)

		--Place Text into tabs and get thier initial width
		for i, v in ipairs(tablist) do
			local tab = tabs[i]
			if not tab then
				tab = self:CreateTab(i)
				tabs[i] = tab
			end

			tab:Show()
			tab:SetText(v.text)
			tab:SetDisabled(v.disabled)
			tab.value = v.value

			widths[i] = tab:GetWidth() - 6 --tabs are anchored 10 pixels from the right side of the previous one to reduce spacing, but add a fixed 4px padding for the text
		end

		for i = (#tablist)+1, #tabs, 1 do
			tabs[i]:Hide()
		end

		--First pass, find the minimum number of rows needed to hold all tabs and the initial tab layout
		local numtabs = #tablist
		local numrows = 1
		local usedwidth = 0

		for i = 1, #tablist do
			--If this is not the first tab of a row and there isn't room for it
			if usedwidth ~= 0 and (width - usedwidth - widths[i]) < 0 then
				rowwidths[numrows] = usedwidth + 10 --first tab in each row takes up an extra 10px
				rowends[numrows] = i - 1
				numrows = numrows + 1
				usedwidth = 0
			end
			usedwidth = usedwidth + widths[i]
		end
		rowwidths[numrows] = usedwidth + 10 --first tab in each row takes up an extra 10px
		rowends[numrows] = #tablist

		--Fix for single tabs being left on the last row, move a tab from the row above if applicable
		if numrows > 1 then
			--if the last row has only one tab
			if rowends[numrows-1] == numtabs-1 then
				--if there are more than 2 tabs in the 2nd last row
				if (numrows == 2 and rowends[numrows-1] > 2) or (rowends[numrows] - rowends[numrows-1] > 2) then
					--move 1 tab from the second last row to the last, if there is enough space
					if (rowwidths[numrows] + widths[numtabs-1]) <= width then
						rowends[numrows-1] = rowends[numrows-1] - 1
						rowwidths[numrows] = rowwidths[numrows] + widths[numtabs-1]
						rowwidths[numrows-1] = rowwidths[numrows-1] - widths[numtabs-1]
					end
				end
			end
		end

		--anchor the rows as defined and resize tabs to fill thier row
		local starttab = 1
		for row, endtab in ipairs(rowends) do
			local first = true
			for tabno = starttab, endtab do
				local tab = tabs[tabno]
				tab:ClearAllPoints()
				if first then
					tab:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 0, -(hastitle and 14 or 7)-(row-1)*20 )
					first = false
				else
					tab:SetPoint("LEFT", tabs[tabno-1], "RIGHT", -10, 0)
				end
			end

			-- equal padding for each tab to fill the available width,
			-- if the used space is above 75% already
			-- the 18 pixel is the typical width of a scrollbar, so we can have a tab group inside a scrolling frame,
			-- and not have the tabs jump around funny when switching between tabs that need scrolling and those that don't
			local padding = 0
			if not (numrows == 1 and rowwidths[1] < width*0.75 - 18) then
				padding = (width - rowwidths[row]) / (endtab - starttab+1)
			end

			for i = starttab, endtab do
				PanelTemplates_TabResize(tabs[i], padding + 4, nil, nil, width, tabs[i]:GetFontString():GetStringWidth())
			end
			starttab = endtab + 1
		end

		self.borderoffset = (hastitle and 17 or 10)+((numrows)*20)
		self.border:SetPoint("TOPLEFT", 1, -self.borderoffset)
	end,

	["OnWidthSet"] = function(self, width)
		local content = self.content
		local contentwidth = width - 60
		if contentwidth < 0 then
			contentwidth = 0
		end
		content:SetWidth(contentwidth)
		content.width = contentwidth
		self:BuildTabs(self)
		self.frame:SetScript("OnUpdate", BuildTabsOnUpdate)
	end,

	["OnHeightSet"] = function(self, height)
		local content = self.content
		local contentheight = height - (self.borderoffset + 23)
		if contentheight < 0 then
			contentheight = 0
		end
		content:SetHeight(contentheight)
		content.height = contentheight
	end,

	["LayoutFinished"] = function(self, width, height)
		if self.noAutoHeight then return end
		self:SetHeight((height or 0) + (self.borderoffset + 23))
	end
}

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]
local PaneBackdrop  = {
	bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	tile = true, tileSize = 16, edgeSize = 16,
	insets = { left = 3, right = 3, top = 5, bottom = 3 }
}

local function Constructor()
	local num = AceGUI:GetNextWidgetNum(Type)
	local frame = CreateFrame("Frame",nil,UIParent)
	frame:SetHeight(100)
	frame:SetWidth(100)
	frame:SetFrameStrata("FULLSCREEN_DIALOG")

	local titletext = frame:CreateFontString(nil,"OVERLAY","GameFontNormal")
	titletext:SetPoint("TOPLEFT", 14, 0)
	titletext:SetPoint("TOPRIGHT", -14, 0)
	titletext:SetJustifyH("LEFT")
	titletext:SetHeight(18)
	titletext:SetText("")

	local border = CreateFrame("Frame", nil, frame, BackdropTemplateMixin and "BackdropTemplate" or nil)
	border:SetPoint("TOPLEFT", 1, -27)
	border:SetPoint("BOTTOMRIGHT", -1, 3)
	border:SetBackdrop(PaneBackdrop)
	border:SetBackdropColor(0.1, 0.1, 0.1, 0.5)
	border:SetBackdropBorderColor(0.4, 0.4, 0.4)

	local content = CreateFrame("Frame", nil, border)
	content:SetPoint("TOPLEFT", 10, -7)
	content:SetPoint("BOTTOMRIGHT", -10, 7)

	local widget = {
		num          = num,
		frame        = frame,
		localstatus  = {},
		alignoffset  = 18,
		titletext    = titletext,
		border       = border,
		borderoffset = 27,
		tabs         = {},
		content      = content,
		type         = Type
	}
	for method, func in pairs(methods) do
		widget[method] = func
	end

	return AceGUI:RegisterAsContainer(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
