--[[
Name: Dewdrop-2.0
Revision: $Rev: 15987 $
Author(s): ckknight (ckknight@gmail.com)
Website: http://ckknight.wowinterface.com/
Documentation: http://wiki.wowace.com/index.php/Dewdrop-2.0
SVN: http://svn.wowace.com/root/trunk/DewdropLib/Dewdrop-2.0
Description: A library to provide a clean dropdown menu interface.
Dependencies: AceLibrary
]]

local MAJOR_VERSION = "Dewdrop-2.0"
local MINOR_VERSION = "$Revision: 15987 $"

if not AceLibrary then error(MAJOR_VERSION .. " requires AceLibrary") end
if not AceLibrary:IsNewVersion(MAJOR_VERSION, MINOR_VERSION) then return end

local Dewdrop = {}

local lua51 = loadstring("return function(...) return ... end") and true or false

local table_setn = lua51 and function() end or table.setn

local function new(k1, v1, k2, v2, k3, v3, k4, v4, k5, v5, k6, v6, k7, v7, k8, v8, k9, v9, k10, v10, k11, v11, k12, v12, k13, v13, k14, v14, k15, v15, k16, v16, k17, v17, k18, v18, k19, v19, k20, v20)
	local t = {}
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
	return t
end
if lua51 then
	new = loadstring("return function(...) local t = {}; for i = 1, select('#', ...), 2 do if select(i, ...) then t[select(i, ...)] = select(i+1, ...); else break; end; end; return t; end")()
end

local tmp
do
	local t = {}
	function tmp(k1, v1, k2, v2, k3, v3, k4, v4, k5, v5, k6, v6, k7, v7, k8, v8, k9, v9, k10, v10, k11, v11, k12, v12, k13, v13, k14, v14, k15, v15, k16, v16, k17, v17, k18, v18, k19, v19, k20, v20)
		for k in pairs(t) do
			t[k] = nil
		end
		if type(k1) == "table" then
			for k,v in pairs(k1) do
				t[k] = v
			end
		else
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
		end
		return t
	end
	if lua51 then
		tmp = loadstring("local t = {}; return function(...) for k in pairs(t) do t[k] = nil end; for i = 1, select('#', ...), 2 do if select(i, ...) then t[select(i, ...)] = select(i+1, ...) else break; end; end; return t; end")()
	end
end
local tmp2
do
	local t = {}
	function tmp2(k1, v1, k2, v2, k3, v3, k4, v4, k5, v5, k6, v6, k7, v7, k8, v8, k9, v9, k10, v10, k11, v11, k12, v12, k13, v13, k14, v14, k15, v15, k16, v16, k17, v17, k18, v18, k19, v19, k20, v20)
		for k in pairs(t) do
			t[k] = nil
		end
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
		return t
	end
	if lua51 then
		tmp2 = loadstring("local t = {}; return function(...) for k in pairs(t) do t[k] = nil end; for i = 1, select('#', ...), 2 do if select(i, ...) then t[select(i, ...)] = select(i+1, ...) else break; end; end; return t; end")()
	end
end
local levels
local buttons

local function GetScaledCursorPosition()
	local x, y = GetCursorPosition()
	local scale = UIParent:GetEffectiveScale()
	return x / scale, y / scale
end

local function StartCounting(self, levelNum)
	for i = levelNum, table.getn(levels) do
		if levels[i] then
			levels[i].count = 3
		end
	end
end

local function StopCounting(self, level)
	for i = level, 1, -1 do
		if levels[i] then
			levels[i].count = nil
		end
	end
end

local function OnUpdate(self, arg1)
	for _,level in ipairs(levels) do
		if level.count then
			level.count = level.count - arg1
			if level.count < 0 then
				level.count = nil
				self:Close(level.num)
			end
		end
	end
end

local function CheckDualMonitor(self, frame)
	local ratio = GetScreenWidth() / GetScreenHeight()
	if ratio >= 2.4 and frame:GetRight() > GetScreenWidth() / 2 and frame:GetLeft() < GetScreenWidth() / 2 then
		local offsetx
		if GetCursorPosition() / GetScreenHeight() * 768 < GetScreenWidth() / 2 then
			offsetx = GetScreenWidth() / 2 - frame:GetRight()
		else
			offsetx = GetScreenWidth() / 2 - frame:GetLeft()
		end
		local point, parent, relativePoint, x, y = frame:GetPoint(1)
		frame:SetPoint(point, parent, relativePoint, (x or 0) + offsetx, y or 0)
	end
end

local function CheckSize(self, level)
	if not level.buttons then
		return
	end
	local height = 20
	for _, button in ipairs(level.buttons) do
		height = height + button:GetHeight()
	end
	level:SetHeight(height)
	local width = 160
	for _, button in ipairs(level.buttons) do
		local extra = 1
		if button.hasArrow or button.hasColorSwatch then
			extra = extra + 16
		end
		if not button.notCheckable then
			extra = extra + 24
		end
		button.text:SetFont(STANDARD_TEXT_FONT, button.textHeight)
		if button.text:GetWidth() + extra > width then
			width = button.text:GetWidth() + extra
		end
	end
	level:SetWidth(width + 20)
	if level:GetLeft() and level:GetRight() and level:GetTop() and level:GetBottom() and (level:GetLeft() < 0 or level:GetRight() > GetScreenWidth() or level:GetTop() > GetScreenHeight() or level:GetBottom() < 0) then
		level:ClearAllPoints()
		if level.lastDirection == "RIGHT" then
			if level.lastVDirection == "DOWN" then
				level:SetPoint("TOPLEFT", level.parent or level:GetParent(), "TOPRIGHT", 5, 10)
			else
				level:SetPoint("BOTTOMLEFT", level.parent or level:GetParent(), "BOTTOMRIGHT", 5, -10)
			end
		else
			if level.lastVDirection == "DOWN" then
				level:SetPoint("TOPRIGHT", level.parent or level:GetParent(), "TOPLEFT", -5, 10)
			else
				level:SetPoint("BOTTOMRIGHT", level.parent or level:GetParent(), "BOTTOMLEFT", -5, -10)
			end
		end
	end
	local dirty = false
	if not level:GetRight() then
		self:Close()
		return
	end
	if level:GetRight() > GetScreenWidth() and level.lastDirection == "RIGHT" then
		level.lastDirection = "LEFT"
		dirty = true
	elseif level:GetLeft() < 0 and level.lastDirection == "LEFT" then
		level.lastDirection = "RIGHT"
		dirty = true
	end
	if level:GetTop() > GetScreenHeight() and level.lastVDirection == "UP" then
		level.lastVDirection = "DOWN"
		dirty = true
	elseif level:GetBottom() < 0 and level.lastVDirection == "DOWN" then
		level.lastVDirection = "UP"
		dirty = true
	end
	if dirty then
		level:ClearAllPoints()
		if level.lastDirection == "RIGHT" then
			if level.lastVDirection == "DOWN" then
				level:SetPoint("TOPLEFT", level.parent or level:GetParent(), "TOPRIGHT", 5, 10)
			else
				level:SetPoint("BOTTOMLEFT", level.parent or level:GetParent(), "BOTTOMRIGHT", 5, -10)
			end
		else
			if level.lastVDirection == "DOWN" then
				level:SetPoint("TOPRIGHT", level.parent or level:GetParent(), "TOPLEFT", -5, 10)
			else
				level:SetPoint("BOTTOMRIGHT", level.parent or level:GetParent(), "BOTTOMLEFT", -5, -10)
			end
		end
	end
	if level:GetTop() > GetScreenHeight() then
		local top = level:GetTop()
		local point, parent, relativePoint, x, y = level:GetPoint(1)
		level:ClearAllPoints()
		level:SetPoint(point, parent, relativePoint, x or 0, (y or 0) + GetScreenHeight() - top)
	elseif level:GetBottom() < 0 then
		local bottom = level:GetBottom()
		local point, parent, relativePoint, x, y = level:GetPoint(1)
		level:ClearAllPoints()
		level:SetPoint(point, parent, relativePoint, x or 0, (y or 0) - bottom)
	end
	CheckDualMonitor(self, level)
	if mod(level.num, 5) == 0 then
		local left, bottom = level:GetLeft(), level:GetBottom()
		level:ClearAllPoints()
		level:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", left, bottom)
	end
end

local Open
local OpenSlider
local OpenEditBox
local Refresh
local Clear
local function ReleaseButton(self, level, index)
	if not level.buttons then
		return
	end
	if not level.buttons[index] then
		return
	end
	local button = level.buttons[index]
	button:Hide()
	if button.highlight then
		button.highlight:Hide()
	end
--	button.arrow:SetVertexColor(1, 1, 1)
	button.arrow:SetHeight(16)
	button.arrow:SetWidth(16)
	table.remove(level.buttons, index)
	table.insert(buttons, button)
	for k in pairs(button) do
		if k ~= 0 and k ~= "text" and k ~= "check" and k ~= "arrow" and k ~= "colorSwatch" and k ~= "highlight" and k ~= "radioHighlight" then
			button[k] = nil
		end
	end
	return true
end

local function Scroll(self, level, down)
	if down then
		if level:GetBottom() < 0 then
			local point, parent, relativePoint, x, y = level:GetPoint(1)
			level:SetPoint(point, parent, relativePoint, x, y + 50)
			if level:GetBottom() > 0 then
				level:SetPoint(point, parent, relativePoint, x, y + 50 - level:GetBottom())
			end
		end
	else
		if level:GetTop() > GetScreenHeight() then
			local point, parent, relativePoint, x, y = level:GetPoint(1)
			level:SetPoint(point, parent, relativePoint, x, y - 50)
			if level:GetTop() < GetScreenHeight() then
				level:SetPoint(point, parent, relativePoint, x, y - 50 + GetScreenHeight() - level:GetTop())
			end
		end
	end
end

local sliderFrame
local editBoxFrame

local numButtons = 0
local function AcquireButton(self, level)
	if not levels[level] then
		return
	end
	level = levels[level]
	if not level.buttons then
		level.buttons = {}
	end
	local button
	if table.getn(buttons) == 0 then
		numButtons = numButtons + 1
		button = CreateFrame("Button", "Dewdrop20Button" .. numButtons, nil)
		button:SetFrameStrata("FULLSCREEN_DIALOG")
		button:SetHeight(16)
		local highlight = button:CreateTexture(nil, "BACKGROUND")
		highlight:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
		button.highlight = highlight
		highlight:SetBlendMode("ADD")
		highlight:SetAllPoints(button)
		highlight:Hide()
		local check = button:CreateTexture(nil, "ARTWORK")
		button.check = check
		check:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
		check:SetPoint("CENTER", button, "LEFT", 12, 0)
		check:SetWidth(24)
		check:SetHeight(24)
		local radioHighlight = button:CreateTexture(nil, "ARTWORK")
		button.radioHighlight = radioHighlight
		radioHighlight:SetTexture("Interface\\Buttons\\UI-RadioButton")
		radioHighlight:SetAllPoints(check)
		radioHighlight:SetBlendMode("ADD")
		radioHighlight:SetTexCoord(0.5, 0.75, 0, 1)
		radioHighlight:Hide()
		button:SetScript("OnEnter", function()
			local this = this
			if (sliderFrame and sliderFrame:IsShown() and sliderFrame.mouseDown and sliderFrame.level == this.level.num + 1) or (editBoxFrame and editBoxFrame:IsShown() and editBoxFrame.mouseDown and editBoxFrame.level == this.level.num + 1) then
				for i = 1, this.level.num do
					Refresh(self, levels[i])
				end
				return
			end
			self:Close(this.level.num + 1)
			if not this.disabled then
				if this.hasSlider then
					OpenSlider(self, this)
				elseif this.hasEditBox then
					OpenEditBox(self, this)
				elseif this.hasArrow then
					Open(self, this, nil, this.level.num + 1, this.value)
				end
			end
			if not this.level then -- button reclaimed
				return
			end
			StopCounting(self, this.level.num + 1)
			if not this.disabled then
				highlight:Show()
				if this.isRadio then
					button.radioHighlight:Show()
				end
			end
			if this.tooltipTitle or this.tooltipText then
				GameTooltip_SetDefaultAnchor(GameTooltip, this)
				local disabled = not this.isTitle and this.disabled
				if this.tooltipTitle then
					if disabled then
						GameTooltip:SetText(this.tooltipTitle, 0.5, 0.5, 0.5, 1)
					else
						GameTooltip:SetText(this.tooltipTitle, 1, 1, 1, 1)
					end
					if this.tooltipText then
						if disabled then
							GameTooltip:AddLine(this.tooltipText, (NORMAL_FONT_COLOR.r + 0.5) / 2, (NORMAL_FONT_COLOR.g + 0.5) / 2, (NORMAL_FONT_COLOR.b + 0.5) / 2, 1)
						else
							GameTooltip:AddLine(this.tooltipText, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1)
						end
					end
				else
					if disabled then
						GameTooltip:SetText(this.tooltipText, 0.5, 0.5, 0.5, 1)
					else
						GameTooltip:SetText(this.tooltipText, 1, 1, 1, 1)
					end
				end
				GameTooltip:Show()
			end
			if this.tooltipFunc then
				GameTooltip:SetOwner(this, "ANCHOR_NONE")
				GameTooltip:SetPoint("TOPLEFT", this, "TOPRIGHT", 5, 0)
				this.tooltipFunc(this.tooltipArg1, this.tooltipArg2, this.tooltipArg3, this.tooltipArg4)
				GameTooltip:Show()
			end
		end)
		button:SetScript("OnLeave", function()
			highlight:Hide()
			button.radioHighlight:Hide()
			if this.level then
				StartCounting(self, this.level.num)
			end
			GameTooltip:Hide()
		end)
		button:SetScript("OnClick", function()
			if not this.disabled then
				if this.hasColorSwatch then
					local func = button.colorFunc
					local a1,a2,a3,a4 = button.colorArg1, button.colorArg2, button.colorArg3, button.colorArg4
					local hasOpacity = this.hasOpacity
					ColorPickerFrame.func = function()
						if func then
							local r,g,b = ColorPickerFrame:GetColorRGB()
							local a = hasOpacity and 1 - OpacitySliderFrame:GetValue() or nil
							if a1 == nil then
								func(r, g, b, a)
							elseif a2 == nil then
								func(a1, r, g, b, a)
							elseif a3 == nil then
								func(a1, a2, r, g, b, a)
							elseif a4 == nil then
								func(a1, a2, a3, r, g, b, a)
							else
								func(a1, a2, a3, a4, r, g, b, a)
							end
						end
					end
					ColorPickerFrame.hasOpacity = this.hasOpacity
					ColorPickerFrame.opacityFunc = ColorPickerFrame.func
					ColorPickerFrame.opacity = 1 - this.opacity
					ColorPickerFrame:SetColorRGB(this.r, this.g, this.b)
					local r, g, b, a = this.r, this.g, this.b, this.opacity
					ColorPickerFrame.cancelFunc = function()
						if a1 == nil then
							func(r, g, b, a)
						elseif a2 == nil then
							func(a1, r, g, b, a)
						elseif a3 == nil then
							func(a1, a2, r, g, b, a)
						else
							func(a1, a2, a3, r, g, b, a)
						end
					end
					self:Close(1)
					ShowUIPanel(ColorPickerFrame)
				elseif this.func then
					local level = button.level
					if type(this.func) == "string" then
						self:assert(type(this.arg1[this.func]) == "function", "Cannot call method " .. this.func)
						this.arg1[this.func](this.arg1, this.arg2, this.arg3, this.arg4)
					else
						this.func(this.arg1, this.arg2, this.arg3, this.arg4)
					end
					if this.closeWhenClicked then
						self:Close()
					elseif level:IsShown() then
						for i = 1, level.num do
							Refresh(self, levels[i])
						end
					end
				elseif this.closeWhenClicked then
					self:Close()
				end
			end
		end)
		local text = button:CreateFontString(nil, "ARTWORK")
		button.text = text
		text:SetFontObject(GameFontHighlightSmall)
		button.text:SetFont(STANDARD_TEXT_FONT, UIDROPDOWNMENU_DEFAULT_TEXT_HEIGHT)
		button:SetScript("OnMouseDown", function()
			if not this.disabled and (this.func or this.colorFunc or this.closeWhenClicked) then
				text:SetPoint("LEFT", button, "LEFT", this.notCheckable and 1 or 25, -1)
			end
		end)
		button:SetScript("OnMouseUp", function()
			if not this.disabled and (this.func or this.colorFunc or this.closeWhenClicked) then
				text:SetPoint("LEFT", button, "LEFT", this.notCheckable and 0 or 24, 0)
			end
		end)
		local arrow = button:CreateTexture(nil, "ARTWORK")
		button.arrow = arrow
		arrow:SetPoint("LEFT", button, "RIGHT", -16, 0)
		arrow:SetWidth(16)
		arrow:SetHeight(16)
		arrow:SetTexture("Interface\\ChatFrame\\ChatFrameExpandArrow")
		local colorSwatch = button:CreateTexture(nil, "OVERLAY")
		button.colorSwatch = colorSwatch
		colorSwatch:SetWidth(20)
		colorSwatch:SetHeight(20)
		colorSwatch:SetTexture("Interface\\ChatFrame\\ChatFrameColorSwatch")
		local texture = button:CreateTexture(nil, "OVERLAY")
		colorSwatch.texture = texture
		texture:SetTexture(1, 1, 1)
		texture:SetWidth(11.5)
		texture:SetHeight(11.5)
		texture:Show()
		texture:SetPoint("CENTER", colorSwatch, "CENTER")
		colorSwatch:SetPoint("RIGHT", button, "RIGHT", 0, 0)
	else
		button = buttons[table.getn(buttons)]
		table.remove(buttons, table.getn(buttons))
	end
	button:ClearAllPoints()
	button:SetParent(level)
	button:SetFrameStrata(level:GetFrameStrata())
	button:SetFrameLevel(level:GetFrameLevel() + 1)
	button:SetPoint("LEFT", level, "LEFT", 10, 0)
	button:SetPoint("RIGHT", level, "RIGHT", -10, 0)
	if table.getn(level.buttons) == 0 then
		button:SetPoint("TOP", level, "TOP", 0, -10)
	else
		button:SetPoint("TOP", level.buttons[table.getn(level.buttons)], "BOTTOM", 0, 0)
	end
	button.text:SetPoint("LEFT", button, "LEFT", 24, 0)
	button:Show()
	button.level = level
	table.insert(level.buttons, button)
	if not level.parented then
		level.parented = true
		level:ClearAllPoints()
		if level.num == 1 then
			if level.parent ~= UIParent then
				level:SetPoint("TOPRIGHT", level.parent, "TOPLEFT")
			else
				level:SetPoint("CENTER", level.parent, "CENTER")
			end
		else
			if level.lastDirection == "RIGHT" then
				if level.lastVDirection == "DOWN" then
					level:SetPoint("TOPLEFT", level.parent, "TOPRIGHT", 5, 10)
				else
					level:SetPoint("BOTTOMLEFT", level.parent, "BOTTOMRIGHT", 5, -10)
				end
			else
				if level.lastVDirection == "DOWN" then
					level:SetPoint("TOPRIGHT", level.parent, "TOPLEFT", -5, 10)
				else
					level:SetPoint("BOTTOMRIGHT", level.parent, "BOTTOMLEFT", -5, -10)
				end
			end
		end
		level:SetFrameStrata("FULLSCREEN_DIALOG")
	end
	button:SetAlpha(1)
	return button
end

local numLevels = 0
local function AcquireLevel(self, level)
	if not levels[level] then
		for i = table.getn(levels) + 1, level, -1 do
			local i = i
			numLevels = numLevels + 1
			local frame = CreateFrame("Button", "Dewdrop20Level" .. numLevels, nil)
			if i == 1 then
				local old_CloseWindows = CloseWindows
				function CloseWindows(ignoreCenter)
					local found = old_CloseWindows(ignoreCenter)
					if levels[1]:IsShown() then
						self:Close()
						return 1
					end
					return found
				end
			end
			levels[i] = frame
			frame.num = i
			frame:SetParent(UIParent)
			frame:SetFrameStrata("FULLSCREEN_DIALOG")
			frame:Hide()
			frame:SetWidth(180)
			frame:SetHeight(10)
			frame:SetFrameLevel(i * 3)
			frame:SetScript("OnHide", function()
				self:Close(level + 1)
			end)
			if frame.SetTopLevel then
				frame:SetTopLevel(true)
			end
			frame:EnableMouse(true)
			frame:EnableMouseWheel(true)
			local backdrop = CreateFrame("Frame", nil, frame)
			backdrop:SetAllPoints(frame)
			backdrop:SetBackdrop(tmp(
				'bgFile', "Interface\\Tooltips\\UI-Tooltip-Background",
				'edgeFile', "Interface\\Tooltips\\UI-Tooltip-Border",
				'tile', true,
				'insets', tmp2(
					'left', 5,
					'right', 5,
					'top', 5,
					'bottom', 5
				),
				'tileSize', 16,
				'edgeSize', 16
			))
			backdrop:SetBackdropBorderColor(TOOLTIP_DEFAULT_COLOR.r, TOOLTIP_DEFAULT_COLOR.g, TOOLTIP_DEFAULT_COLOR.b)
			backdrop:SetBackdropColor(TOOLTIP_DEFAULT_BACKGROUND_COLOR.r, TOOLTIP_DEFAULT_BACKGROUND_COLOR.g, TOOLTIP_DEFAULT_BACKGROUND_COLOR.b)
			frame:SetScript("OnClick", function()
				self:Close(i)
			end)
			frame:SetScript("OnEnter", function()
				StopCounting(self, i)
			end)
			frame:SetScript("OnLeave", function()
				StartCounting(self, i)
			end)
			frame:SetScript("OnMouseWheel", function()
				Scroll(self, frame, arg1 < 0)
			end)
			if i == 1 then
				frame:SetScript("OnUpdate", function()
					OnUpdate(self, arg1)
				end)
				levels[1].lastDirection = "RIGHT"
				levels[1].lastVDirection = "DOWN"
			else
				levels[i].lastDirection = levels[i - 1].lastDirection
				levels[i].lastVDirection = levels[i - 1].lastVDirection
			end
		end
	end
	local fullscreenFrame = GetFullScreenFrame()
	local l = levels[level]
	local strata, framelevel = l:GetFrameStrata(), l:GetFrameLevel()
	if fullscreenFrame then
		l:SetParent(fullscreenFrame)
	else
		l:SetParent(UIParent)
	end
	l:SetFrameStrata(strata)
	l:SetFrameLevel(framelevel)
	l:SetAlpha(1)
	return l
end

local function checkValidate(validateFunc, func, arg1, arg2, arg3)
	local text
	if arg3 ~= nil then
		text = arg3
	elseif arg2 ~= nil then
		text = arg2
	else
		text = arg1
	end
	if not validateFunc(text) then
		DEFAULT_CHAT_FRAME:AddMessage("|cffffff7fValidation error: [|r" .. tostring(text) .. "|cffffff7f]|r")
	else
		func(arg1, arg2, arg3)
	end
end

local function validateOptions(options, position, baseOptions, fromPass)
	if not baseOptions then
		baseOptions = options
	end
	if type(options) ~= "table" then
		return "Options must be a table.", position
	end
	local kind = options.type
	if type(kind) ~= "string" then
		return '"type" must be a string.', position
	elseif kind ~= "group" and kind ~= "range" and kind ~= "text" and kind ~= "execute" and kind ~= "toggle" and kind ~= "color" and kind ~= "header" then
		return '"type" must either be "range", "text", "group", "toggle", "execute", "color", or "header".', position
	end
	if options.aliases then
		if type(options.aliases) ~= "table" and type(options.aliases) ~= "string" then
			return '"alias" must be a table or string', position
		end
	end
	if not fromPass then
		if kind == "execute" then
			if type(options.func) ~= "string" and type(options.func) ~= "function" then
				return '"func" must be a string or function', position
			end
		elseif kind == "range" or kind == "text" or kind == "toggle" then
			if type(options.set) ~= "string" and type(options.set) ~= "function" then
				return '"set" must be a string or function', position
			end
			if kind == "text" and options.get == false then
			elseif type(options.get) ~= "string" and type(options.get) ~= "function" then
				return '"get" must be a string or function', position
			end
		elseif kind == "group" and options.pass then
			if options.pass ~= true then
				return '"pass" must be either nil, true, or false', position
			end
			if not options.func then
				if type(options.set) ~= "string" and type(options.set) ~= "function" then
					return '"set" must be a string or function', position
				end
				if type(options.get) ~= "string" and type(options.get) ~= "function" then
					return '"get" must be a string or function', position
				end
			elseif type(options.func) ~= "string" and type(options.func) ~= "function" then
				return '"func" must be a string or function', position
			end
		end
	else
		if kind == "group" then
			return 'cannot have "type" = "group" as a subgroup of a passing group', position
		end
	end
	if options ~= baseOptions then
		if kind == "header" then
		elseif type(options.desc) ~= "string" then
			return '"desc" must be a string', position
		elseif string.len(options.desc) == 0 then
			return '"desc" cannot be a 0-length string', position
		end
	end
	if options ~= baseOptions or kind == "range" or kind == "text" or kind == "toggle" or kind == "color" then
		if options.type == "header" and not options.cmdName and not options.name then
		elseif options.cmdName then
			if type(options.cmdName) ~= "string" then
				return '"cmdName" must be a string or nil', position
			elseif string.len(options.cmdName) == 0 then
				return '"cmdName" cannot be a 0-length string', position
			end
			if type(options.guiName) ~= "string" then
				if not options.guiNameIsMap then
					return '"guiName" must be a string or nil', position
				end
			elseif string.len(options.guiName) == 0 then
				return '"guiName" cannot be a 0-length string', position
			end
		else
			if type(options.name) ~= "string" then
				return '"name" must be a string', position
			elseif string.len(options.name) == 0 then
				return '"name" cannot be a 0-length string', position
			end
		end
	end
	if options.guiNameIsMap then
		if type(options.guiNameIsMap) ~= "boolean" then
			return '"guiNameIsMap" must be a boolean or nil', position
		elseif options.type ~= "toggle" then
			return 'if "guiNameIsMap" is true, then "type" must be set to \'toggle\'', position
		elseif type(options.map) ~= "table" then
			return '"map" must be a table', position
		end
	end
	if options.message and type(options.message) ~= "string" then
		return '"message" must be a string or nil', position
	end
	if options.error and type(options.error) ~= "string" then
		return '"error" must be a string or nil', position
	end
	if options.current and type(options.current) ~= "string" then
		return '"current" must be a string or nil', position
	end
	if options.order then
		if type(options.order) ~= "number" or (-1 < options.order and options.order < 0.999) then
			return '"order" must be a non-zero number or nil', position
		end
	end
	if options.disabled then
		if type(options.disabled) ~= "function" and type(options.disabled) ~= "string" and options.disabled ~= true then
			return '"disabled" must be a function, string, or boolean', position
		end
	end
	if options.cmdHidden then
		if type(options.cmdHidden) ~= "function" and type(options.cmdHidden) ~= "string" and options.cmdHidden ~= true then
			return '"cmdHidden" must be a function, string, or boolean', position
		end
	end
	if options.guiHidden then
		if type(options.guiHidden) ~= "function" and type(options.guiHidden) ~= "string" and options.guiHidden ~= true then
			return '"guiHidden" must be a function, string, or boolean', position
		end
	end
	if options.hidden then
		if type(options.hidden) ~= "function" and type(options.hidden) ~= "string" and options.hidden ~= true then
			return '"hidden" must be a function, string, or boolean', position
		end
	end
	if kind == "text" then
		if type(options.validate) == "table" then
			local t = options.validate
			local iTable = nil
			for k,v in pairs(t) do
				if type(k) == "number" then
					if iTable == nil then
						iTable = true
					elseif not iTable then
						return '"validate" must either have all keys be indexed numbers or strings', position
					elseif k < 1 or k > table.getn(t) then
						return '"validate" numeric keys must be indexed properly. >= 1 and <= table.getn', position
					end
				else
					if iTable == nil then
						iTable = false
					elseif iTable then
						return '"validate" must either have all keys be indexed numbers or strings', position
					end
				end
				if type(v) ~= "string" then
					return '"validate" values must all be strings', position
				end
			end
		else
			if type(options.usage) ~= "string" then
				return '"usage" must be a string', position
			elseif options.validate and type(options.validate) ~= "string" and type(options.validate) ~= "function" then
				return '"validate" must be a string, function, or table', position
			end
		end
	elseif kind == "range" then
		if options.min or options.max then
			if type(options.min) ~= "number" then
				return '"min" must be a number', position
			elseif type(options.max) ~= "number" then
				return '"max" must be a number', position
			elseif options.min >= options.max then
				return '"min" must be less than "max"', position
			end
		end
		if options.step then
			if type(options.step) ~= "number" then
				return '"step" must be a number', position
			elseif options.step < 0 then
				return '"step" must be nonnegative', position
			end
		end
		if options.isPercent and options.isPercent ~= true then
			return '"isPercent" must either be nil, true, or false', position
		end
	elseif kind == "toggle" then
		if options.map then
			if type(options.map) ~= "table" then
				return '"map" must be a table', position
			elseif type(options.map[true]) ~= "string" then
				return '"map[true]" must be a string', position
			elseif type(options.map[false]) ~= "string" then
				return '"map[false]" must be a string', position
			end
		end
	elseif kind == "color" then
		if options.hasAlpha and options.hasAlpha ~= true then
			return '"hasAlpha" must be nil, true, or false', position
		end
	elseif kind == "group" then
		if options.pass and options.pass ~= true then
			return '"pass" must be nil, true, or false', position
		end
		if type(options.args) ~= "table" then
			return '"args" must be a table', position
		end
		for k,v in pairs(options.args) do
			if type(k) ~= "string" then
				return '"args" keys must be strings', position
			elseif string.find(k, "%s") then
				return string.format('"args" keys must not include spaces. %q is not appropriate.', k), position
			elseif string.len(k) == 0 then
				return '"args" keys must not be 0-length strings.', position
			end
			if type(v) ~= "table" then
				return '"args" values must be tables', position and position .. "." .. k or k
			end
			local newposition
			if position then
				newposition = position .. ".args." .. k
			else
				newposition = "args." .. k
			end
			local err, pos = validateOptions(v, newposition, baseOptions, options.pass)
			if err then
				return err, pos
			end
		end
	end
	if options.icon and type(options.icon) ~= "string" then
		return'"icon" must be a string', position
	end
	if options.iconWidth or options.iconHeight then
		if type(options.iconWidth) ~= "number" or type(options.iconHeight) ~= "number" then
			return '"iconHeight" and "iconWidth" must be numbers', position
		end
	end
	if options.iconCoordLeft or options.iconCoordRight or options.iconCoordTop or options.iconCoordBottom then
		if type(options.iconCoordLeft) ~= "number" or type(options.iconCoordRight) ~= "number" or type(options.iconCoordTop) ~= "number" or type(options.iconCoordBottom) ~= "number" then
			return '"iconCoordLeft", "iconCoordRight", "iconCoordTop", and "iconCoordBottom" must be numbers', position
		end
	end
end

local validatedOptions

local values
local mysort_args
local mysort
local othersort
local othersort_validate

local baseFunc, currentLevel

function Dewdrop:FeedAceOptionsTable(options, difference)
	self:argCheck(options, 2, "table")
	self:argCheck(difference, 3, "nil", "number")
	self:assert(currentLevel, "Cannot call `FeedAceOptionsTable' outside of a Dewdrop declaration")
	if not difference then
		difference = 0
	end
	if not validatedOptions then
		validatedOptions = {}
	end
	if not validatedOptions[options] then
		local err, position = validateOptions(options)

		if err then
			if position then
				Dewdrop:error(position .. ": " .. err)
			else
				Dewdrop:error(err)
			end
		end

		validatedOptions[options] = true
	end
	local level = levels[currentLevel]
	self:assert(level, "Improper level given")
	if not values then
		values = {}
	else
		for k,v in pairs(values) do
			values[k] = nil
		end
		table_setn(values, 0)
	end

	local current = level
	while current do
		if current.num == difference + 1 then
			break
		end
		table.insert(values, current.value)
		current = levels[current.num - 1]
	end

	local realOptions = options
	local handler = options.handler
	local passTable
	local passValue
	while table.getn(values) > 0 do
		passTable = options.pass and current or nil
		local value = table.remove(values)
		options = options.args and options.args[value]
		if not options then
			return
		end
		handler = options.handler or handler
		passValue = passTable and value or nil
	end

	if options.type == "group" then
		for k in pairs(options.args) do
			table.insert(values, k)
		end
		if not mysort then
			mysort = function(a, b)
				local alpha, bravo = mysort_args[a], mysort_args[b]
				local alpha_order = alpha.order or 100
				local bravo_order = bravo.order or 100
				local alpha_name = alpha.guiName or alpha.name
				local bravo_name = bravo.guiName or bravo.name
				if alpha_order == bravo_order then
					if not alpha_name then
						return true
					elseif not bravo_name then
						return false
					else
						return string.upper(alpha_name) < string.upper(bravo_name)
					end
				else
					if alpha_order < 0 then
						if bravo_order > 0 then
							return false
						end
					else
						if bravo_order < 0 then
							return true
						end
					end
					return alpha_order < bravo_order
				end
			end
		end
		mysort_args = options.args
		table.sort(values, mysort)
		mysort_args = nil
		local hasBoth = table.getn(values) >= 1 and (options.args[values[1]].order or 100) > 0 and (options.args[values[table.getn(values)]].order or 100) < 0
		local last_order = 1
		for _,k in ipairs(values) do
			local v = options.args[k]
			local handler = v.handler or handler
			if hasBoth and last_order > 0 and (v.order or 100) < 0 then
				hasBoth = false
				self:AddLine()
			end
			local hidden, disabled = v.guiHidden or v.hidden, v.disabled
			if type(hidden) == "function" then
				hidden = hidden()
			elseif type(hidden) == "string" then
				hidden = handler[hidden](handler)
			end
			if not hidden then
				if type(disabled) == "function" then
					disabled = disabled()
				elseif type(disabled) == "string" then
					disabled = handler[disabled](handler)
				end
				local name = (v.guiIconOnly and v.icon) and "" or (v.guiName or v.name)
				local desc = v.desc
				local iconHeight = v.iconHeight or 16
				local iconWidth = v.iconWidth or 16
				local iconCoordLeft = v.iconCoordLeft or 0
				local iconCoordRight = v.iconCoordRight or 1
				local iconCoordBottom = v.iconCoordBottom or 0
				local iconCoordTop = v.iconCoordTop or 1
				local tooltipTitle, tooltipText
				tooltipTitle = name
				if name ~= desc then
					tooltipText = desc
				end
				if v.type == "toggle" then
					local checked
					if type(v.get) == "function" then
						checked = v.get(passValue)
					else
						if not handler[v.get] then
							Dewdrop:error("Handler %q not available", v.get)
						end
						checked = handler[v.get](handler, passValue)
					end
					local func, arg1, arg2, arg3
					if type(v.set) == "function" then
						func = v.set
						if passValue ~= nil then
							arg1 = passValue
							arg2 = not checked
						else
							arg1 = not checked
						end
					else
						if not handler[v.set] then
							Dewdrop:error("Handler %q not available", v.set)
						end
						func = handler[v.set]
						arg1 = handler
						if passValue ~= nil then
							arg2 = passValue
							arg3 = not checked
						else
							arg2 = not checked
						end
					end
					if v.guiNameIsMap then
						checked = checked and true or false
						name = string.gsub(tostring(v.map and v.map[checked]), "|c%x%x%x%x%x%x%x%x(.-)|r", "%1")
						checked = nil
					end
					self:AddLine(
						'text', name,
						'checked', checked,
						'isRadio', v.isRadio,
						'func', func,
						'arg1', arg1,
						'arg2', arg2,
						'arg3', arg3,
						'disabled', disabled,
						'tooltipTitle', tooltipTitle,
						'tooltipText', tooltipText
					)
				elseif v.type == "execute" then
					local func, arg1, arg2
					if type(v.func) == "function" then
						func = v.func
						arg1 = passValue
					else
						if not handler[v.func] then
							Dewdrop:error("Handler %q not available", v.func)
						end
						func = handler[v.func]
						arg1 = handler
						arg2 = passValue
					end
					self:AddLine(
						'text', name,
						'checked', checked,
						'func', func,
						'arg1', arg1,
						'arg2', arg2,
						'disabled', disabled,
						'tooltipTitle', tooltipTitle,
						'tooltipText', tooltipText,
						'icon', v.icon,
						'iconHeight', iconHeight,
						'iconWidth', iconWidth,
						'iconCoordLeft', iconCoordLeft,
						'iconCoordRight', iconCoordRight,
						'iconCoordTop', iconCoordTop,
						'iconCoordBottom', iconCoordBottom
					)
				elseif v.type == "range" then
					local sliderValue
					if type(v.get) == "function" then
						sliderValue = v.get(passValue)
					else
						if not handler[v.get] then
							Dewdrop:error("Handler %q not available", v.get)
						end
						sliderValue = handler[v.get](handler, passValue)
					end
					local sliderFunc, sliderArg1, sliderArg2
					if type(v.set) == "function" then
						sliderFunc = v.set
						sliderArg1 = passValue
					else
						if not handler[v.set] then
							Dewdrop:error("Handler %q not available", v.set)
						end
						sliderFunc = handler[v.set]
						sliderArg1 = handler
						sliderArg2 = passValue
					end
					self:AddLine(
						'text', name,
						'hasArrow', true,
						'hasSlider', true,
						'sliderMin', v.min or 0,
						'sliderMax', v.max or 1,
						'sliderStep', v.step or 0,
						'sliderIsPercent', v.isPercent or false,
						'sliderValue', sliderValue,
						'sliderFunc', sliderFunc,
						'sliderArg1', sliderArg1,
						'sliderArg2', sliderArg2,
						'disabled', disabled,
						'tooltipTitle', tooltipTitle,
						'tooltipText', tooltipText,
						'icon', v.icon,
						'iconHeight', iconHeight,
						'iconWidth', iconWidth,
						'iconCoordLeft', iconCoordLeft,
						'iconCoordRight', iconCoordRight,
						'iconCoordTop', iconCoordTop,
						'iconCoordBottom', iconCoordBottom
					)
				elseif v.type == "color" then
					local r,g,b,a
					if type(v.get) == "function" then
						r,g,b,a = v.get(passValue)
					else
						if not handler[v.get] then
							Dewdrop:error("Handler %q not available", v.get)
						end
						r,g,b,a = handler[v.get](handler, passValue)
					end
					local colorFunc, colorArg1, colorArg2
					if type(v.set) == "function" then
						colorFunc = v.set
						colorArg1 = passValue
					else
						if not handler[v.set] then
							Dewdrop:error("Handler %q not available", v.set)
						end
						colorFunc = handler[v.set]
						colorArg1 = handler
						colorArg2 = passValue
					end
					self:AddLine(
						'text', name,
						'hasArrow', true,
						'hasColorSwatch', true,
						'r', r,
						'g', g,
						'b', b,
						'opacity', v.hasAlpha and a or nil,
						'hasOpacity', v.hasAlpha,
						'colorFunc', colorFunc,
						'colorArg1', colorArg1,
						'colorArg2', colorArg2,
						'disabled', disabled,
						'tooltipTitle', tooltipTitle,
						'tooltipText', tooltipText
					)
				elseif v.type == "text" then
					if type(v.validate) == "table" then
						self:AddLine(
							'text', name,
							'hasArrow', true,
							'value', k,
							'disabled', disabled,
							'tooltipTitle', tooltipTitle,
							'tooltipText', tooltipText,
							'icon', v.icon,
							'iconHeight', iconHeight,
							'iconWidth', iconWidth,
							'iconCoordLeft', iconCoordLeft,
							'iconCoordRight', iconCoordRight,
							'iconCoordTop', iconCoordTop,
							'iconCoordBottom', iconCoordBottom
						)
					else
						local editBoxText
						if type(v.get) == "function" then
							editBoxText = v.get(passValue)
						elseif v.get == false then
							editBoxText = nil
						else
							if not handler[v.get] then
								Dewdrop:error("Handler %q not available", v.get)
							end
							editBoxText = handler[v.get](handler, passValue)
						end
						local editBoxFunc, editBoxArg1, editBoxArg2
						if type(v.set) == "function" then
							editBoxFunc = v.set
							editBoxArg1 = passValue
						else
							if not handler[v.set] then
								Dewdrop:error("Handler %q not available", v.set)
							end
							editBoxFunc = handler[v.set]
							editBoxArg1 = handler
							editBoxArg2 = passValue
						end

						local editBoxValidateFunc, editBoxValidateArg1

						if v.validate then
							if type(v.validate) == "function" then
								editBoxValidateFunc = v.validate
							else
								if not handler[v.validate] then
									Dewdrop:error("Handler %q not available", v.validate)
								end
								editBoxValidateFunc = handler[v.validate]
								editBoxValidateArg1 = handler
							end
						end

						self:AddLine(
							'text', name,
							'hasArrow', true,
							'icon', v.icon,
							'iconHeight', iconHeight,
							'iconWidth', iconWidth,
							'iconCoordLeft', iconCoordLeft,
							'iconCoordRight', iconCoordRight,
							'iconCoordTop', iconCoordTop,
							'iconCoordBottom', iconCoordBottom,
							'hasEditBox', true,
							'editBoxText', editBoxText,
							'editBoxFunc', editBoxFunc,
							'editBoxArg1', editBoxArg1,
							'editBoxArg2', editBoxArg2,
							'editBoxValidateFunc', editBoxValidateFunc,
							'editBoxValidateArg1', editBoxValidateArg1,
							'disabled', disabled,
							'tooltipTitle', tooltipTitle,
							'tooltipText', tooltipText
						)
					end
				elseif v.type == "group" then
					self:AddLine(
						'text', name,
						'hasArrow', true,
						'value', k,
						'disabled', disabled,
						'tooltipTitle', tooltipTitle,
						'tooltipText', tooltipText,
						'icon', v.icon,
						'iconHeight', iconHeight,
						'iconWidth', iconWidth,
						'iconCoordLeft', iconCoordLeft,
						'iconCoordRight', iconCoordRight,
						'iconCoordTop', iconCoordTop,
						'iconCoordBottom', iconCoordBottom
					)
				elseif v.type == "header" then
					if name == "" or not name then
						self:AddLine(
							'isTitle', true,
							'icon', v.icon,
							'iconHeight', iconHeight,
							'iconWidth', iconWidth,
							'iconCoordLeft', iconCoordLeft,
							'iconCoordRight', iconCoordRight,
							'iconCoordTop', iconCoordTop,
							'iconCoordBottom', iconCoordBottom
						)
					else
						self:AddLine(
							'text', name,
							'isTitle', true,
							'icon', v.icon,
							'iconHeight', iconHeight,
							'iconWidth', iconWidth,
							'iconCoordLeft', iconCoordLeft,
							'iconCoordRight', iconCoordRight,
							'iconCoordTop', iconCoordTop,
							'iconCoordBottom', iconCoordBottom
						)
					end
				end
			end
			last_order = v.order or 100
		end
	elseif options.type == "text" and type(options.validate) == "table" then
		local current
		if type(options.get) == "function" then
			current = options.get(passValue)
		elseif options.get ~= false then
			if not handler[options.get] then
				Dewdrop:error("Handler %q not available", options.get)
			end
			current = handler[options.get](handler, passValue)
		end
		local indexed = true
		for k,v in pairs(options.validate) do
			if type(k) ~= "number" then
				indexed = false
			end
			table.insert(values, k)
		end
		if not indexed then
			if not othersort then
				othersort = function(alpha, bravo)
					return othersort_validate[alpha] < othersort_validate[bravo]
				end
			end
			othersort_validate = options.validate
			table.sort(values, othersort)
			othersort_validate = nil
		end
		for _,k in ipairs(values) do
			local v = options.validate[k]
			if type(k) == "number" then
				k = v
			end
			local func, arg1, arg2
			if type(options.set) == "function" then
				func = options.set
				if passValue ~= nil then
					arg1 = passValue
					arg2 = k
				else
					arg1 = k
				end
			else
				if not handler[options.set] then
					Dewdrop:error("Handler %q not available", options.set)
				end
				func = handler[options.set]
				arg1 = handler
				if passValue ~= nil then
					arg2 = passValue
					arg3 = k
				else
					arg2 = k
				end
			end
			local checked = (k == current or (type(k) == "string" and type(current) == "string" and string.lower(k) == string.lower(current)))
			self:AddLine(
				'text', v,
				'func', not checked and func or nil,
				'arg1', not checked and arg1 or nil,
				'arg2', not checked and arg2 or nil,
				'arg3', not checked and arg3 or nil,
				'isRadio', true,
				'checked',  checked,
				'tooltipTitle', options.guiName or options.name,
				'tooltipText', v
			)
		end
		for k in pairs(values) do
			values[k] = nil
		end
		table_setn(values, 0)
	else
		return false
	end
	return true
end

function Refresh(self, level)
	if type(level) == "number" then
		level = levels[level]
	end
	if not level then
		return
	end
	if baseFunc then
		Clear(self, level)
		currentLevel = level.num
		if type(baseFunc) == "table" then
			if currentLevel == 1 then
				local handler = baseFunc.handler
				if handler then
					local name = tostring(handler)
					if not string.find(name, '^table:') then
						name = string.gsub(name, "|c%x%x%x%x%x%x%x%x(.-)|r", "%1")
						self:AddLine(
							'text', name,
							'isTitle', true
						)
					end
				end
--			elseif level.parentText then
--				self:AddLine(
--					'text', level.parentText,
--					'tooltipTitle', level.parentTooltipTitle,
--					'tooltipText', level.parentTooltipText,
--					'tooltipFunc', level.parentTooltipFunc,
--					'isTitle', true
--				)
			end
			self:FeedAceOptionsTable(baseFunc)
			if currentLevel == 1 then
				self:AddLine(
					'text', CLOSE,
					'closeWhenClicked', true
				)
			end
		else
--			if level.parentText then
--				self:AddLine(
--					'text', level.parentText,
--					'tooltipTitle', level.parentTooltipTitle,
--					'tooltipText', level.parentTooltipText,
--					'tooltipFunc', level.parentTooltipFunc,
--					'isTitle', true
--				)
--			end
			baseFunc(currentLevel, level.value, levels[level.num - 1] and levels[level.num - 1].value, levels[level.num - 2] and levels[level.num - 2].value, levels[level.num - 3] and levels[level.num - 3].value, levels[level.num - 4] and levels[level.num - 4].value)
		end
		currentLevel = nil
		CheckSize(self, level)
	end
end

function Dewdrop:Refresh(level)
	self:argCheck(level, 2, "number")
	Refresh(self, levels[level])
end

function OpenSlider(self, parent)
	if not sliderFrame then
		sliderFrame = CreateFrame("Frame", nil, nil)
		sliderFrame:SetWidth(80)
		sliderFrame:SetHeight(170)
		sliderFrame:SetScale(UIParent:GetScale())
		sliderFrame:SetBackdrop(tmp(
			'bgFile', "Interface\\Tooltips\\UI-Tooltip-Background",
			'edgeFile', "Interface\\Tooltips\\UI-Tooltip-Border",
			'tile', true,
			'insets', tmp2(
				'left', 5,
				'right', 5,
				'top', 5,
				'bottom', 5
			),
			'tileSize', 16,
			'edgeSize', 16
		))
		sliderFrame:SetFrameStrata("FULLSCREEN_DIALOG")
		if sliderFrame.SetTopLevel then
			sliderFrame:SetTopLevel(true)
		end
		sliderFrame:SetBackdropBorderColor(TOOLTIP_DEFAULT_COLOR.r, TOOLTIP_DEFAULT_COLOR.g, TOOLTIP_DEFAULT_COLOR.b)
		sliderFrame:SetBackdropColor(TOOLTIP_DEFAULT_BACKGROUND_COLOR.r, TOOLTIP_DEFAULT_BACKGROUND_COLOR.g, TOOLTIP_DEFAULT_BACKGROUND_COLOR.b)
		sliderFrame:EnableMouse(true)
		sliderFrame:Hide()
		sliderFrame:SetPoint("CENTER", UIParent, "CENTER")
		local slider = CreateFrame("Slider", nil, sliderFrame)
		sliderFrame.slider = slider
		slider:SetOrientation("VERTICAL")
		slider:SetMinMaxValues(0, 1)
		slider:SetValueStep(0.01)
		slider:SetValue(0.5)
		slider:SetWidth(16)
		slider:SetHeight(128)
		slider:SetPoint("LEFT", sliderFrame, "LEFT", 15, 0)
		slider:SetBackdrop(tmp(
			'bgFile', "Interface\\Buttons\\UI-SliderBar-Background",
			'edgeFile', "Interface\\Buttons\\UI-SliderBar-Border",
			'tile', true,
			'edgeSize', 8,
			'tileSize', 8,
			'insets', tmp2(
				'left', 3,
				'right', 3,
				'top', 3,
				'bottom', 3
			)
		))
		local texture = slider:CreateTexture()
		slider:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Vertical")
		local text = slider:CreateFontString(nil, "ARTWORK")
		sliderFrame.topText = text
		text:SetFontObject(GameFontGreenSmall)
		text:SetText("100%")
		text:SetPoint("BOTTOM", slider, "TOP")
		local text = slider:CreateFontString(nil, "ARTWORK")
		sliderFrame.bottomText = text
		text:SetFontObject(GameFontGreenSmall)
		text:SetText("0%")
		text:SetPoint("TOP", slider, "BOTTOM")
		local text = slider:CreateFontString(nil, "ARTWORK")
		sliderFrame.currentText = text
		text:SetFontObject(GameFontHighlightSmall)
		text:SetText("50%")
		text:SetPoint("LEFT", slider, "RIGHT")
		text:SetPoint("RIGHT", sliderFrame, "RIGHT", -6, 0)
		text:SetJustifyH("CENTER")
		local changed = false
		local inside = false
		slider:SetScript("OnValueChanged", function()
			if sliderFrame.changing then
				return
			end
			changed = true
			local done = false
			if sliderFrame.parent then
				if sliderFrame.parent.sliderFunc then
					local min = sliderFrame.parent.sliderMin or 0
					local max = sliderFrame.parent.sliderMax or 1
					local step = sliderFrame.parent.sliderStep or (max - min) / 100
					local a1,a2,a3,a4 = sliderFrame.parent.sliderArg1, sliderFrame.parent.sliderArg2, sliderFrame.parent.sliderArg3, sliderFrame.parent.sliderArg4
					local value = (1 - slider:GetValue()) * (max - min) + min
					if step > 0 then
						value = math.floor((value - min) / step + 0.5) * step + min
						if value > max then
							value = max
						elseif value < min then
							value = min
						end
					end
					local text
					if a1 == nil then
						text = sliderFrame.parent.sliderFunc(value)
					elseif a2 == nil then
						text = sliderFrame.parent.sliderFunc(a1, value)
					elseif a3 == nil then
						text = sliderFrame.parent.sliderFunc(a1, a2, value)
					elseif a4 == nil then
						text = sliderFrame.parent.sliderFunc(a1, a2, a3, value)
					else
						text = sliderFrame.parent.sliderFunc(a1, a2, a3, a4, value)
					end
					if text then
						sliderFrame.currentText:SetText(text)
						done = true
					end
				end
			end
			if not done then
				local min = sliderFrame.parent.sliderMin or 0
				local max = sliderFrame.parent.sliderMax or 1
				local step = sliderFrame.parent.sliderStep or (max - min) / 100
				local value = (1 - slider:GetValue()) * (max - min) + min
				if step > 0 then
					value = math.floor((value - min) / step + 0.5) * step + min
					if value > max then
						value = max
					elseif value < min then
						value = min
					end
				end
				if sliderFrame.parent.sliderIsPercent then
					sliderFrame.currentText:SetText(string.format("%.0f%%", value * 100))
				else
					if step < 0.1 then
						sliderFrame.currentText:SetText(string.format("%.2f", value))
					elseif step < 1 then
						sliderFrame.currentText:SetText(string.format("%.1f", value))
					else
						sliderFrame.currentText:SetText(string.format("%.0f", value))
					end
				end
			end
		end)
		sliderFrame:SetScript("OnEnter", function()
			StopCounting(self, sliderFrame.level)
		end)
		sliderFrame:SetScript("OnLeave", function()
			StartCounting(self, sliderFrame.level)
		end)
		slider:SetScript("OnMouseDown", function()
			sliderFrame.mouseDown = true
		end)
		slider:SetScript("OnMouseUp", function()
			sliderFrame.mouseDown = false
			if changed and not inside then
				local parent = sliderFrame.parent
				for i = 1, sliderFrame.level - 1 do
					Refresh(self, levels[i])
				end
				OpenSlider(self, parent)
			end
		end)
		slider:SetScript("OnEnter", function()
			inside = true
			StopCounting(self, sliderFrame.level)
		end)
		slider:SetScript("OnLeave", function()
			inside = false
			StartCounting(self, sliderFrame.level)
			if changed and not sliderFrame.mouseDown then
				local parent = sliderFrame.parent
				for i = 1, sliderFrame.level - 1 do
					Refresh(self, levels[i])
				end
				OpenSlider(self, parent)
			end
		end)
	end
	sliderFrame.parent = parent
	sliderFrame.level = parent.level.num + 1
	sliderFrame.parentValue = parent.level.value
	sliderFrame:SetFrameLevel(parent.level:GetFrameLevel() + 3)
	sliderFrame.slider:SetFrameLevel(sliderFrame:GetFrameLevel() + 1)
	sliderFrame.changing = true
	if not parent.sliderMin or not parent.sliderMax then
		return
	end

	if parent.arrow then
--		parent.arrow:SetVertexColor(0.2, 0.6, 0)
		parent.arrow:SetHeight(24)
		parent.arrow:SetWidth(24)
	end

	if not parent.sliderValue then
		parent.sliderValue = (parent.sliderMin + parent.sliderMax) / 2
	end
	sliderFrame.slider:SetValue(1 - (parent.sliderValue - parent.sliderMin) / (parent.sliderMax - parent.sliderMin))
	sliderFrame.changing = false
	sliderFrame.bottomText:SetText(parent.sliderMinText or "0")
	sliderFrame.topText:SetText(parent.sliderMaxText or "1")
	local text
	if parent.sliderFunc then
		local a1,a2,a3,a4 = parent.sliderArg1, parent.sliderArg2, parent.sliderArg3, parent.sliderArg4
		if a1 == nil then
			text = parent.sliderFunc(parent.sliderValue)
		elseif a2 == nil then
			text = parent.sliderFunc(a1, parent.sliderValue)
		elseif a3 == nil then
			text = parent.sliderFunc(a1, a2, parent.sliderValue)
		elseif a4 == nil then
			text = parent.sliderFunc(a1, a2, a3, parent.sliderValue)
		else
			text = parent.sliderFunc(a1, a2, a3, a4, parent.sliderValue)
		end
	end
	if text then
		sliderFrame.currentText:SetText(text)
	elseif parent.sliderIsPercent then
		sliderFrame.currentText:SetText(string.format("%.0f%%", parent.sliderValue * 100))
	else
		sliderFrame.currentText:SetText(parent.sliderValue)
	end

	local level = parent.level
	sliderFrame:Show()
	sliderFrame:ClearAllPoints()
	if level.lastDirection == "RIGHT" then
		if level.lastVDirection == "DOWN" then
			sliderFrame:SetPoint("TOPLEFT", parent, "TOPRIGHT", 5, 10)
		else
			sliderFrame:SetPoint("BOTTOMLEFT", parent, "BOTTOMRIGHT", 5, -10)
		end
	else
		if level.lastVDirection == "DOWN" then
			sliderFrame:SetPoint("TOPRIGHT", parent, "TOPLEFT", -5, 10)
		else
			sliderFrame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMLEFT", -5, -10)
		end
	end
	local dirty
	if level.lastDirection == "RIGHT" then
		if sliderFrame:GetRight() > GetScreenWidth() then
			level.lastDirection = "LEFT"
			dirty = true
		end
	elseif sliderFrame:GetLeft() < 0 then
		level.lastDirection = "RIGHT"
		dirty = true
	end
	if level.lastVDirection == "DOWN" then
		if sliderFrame:GetBottom() < 0 then
			level.lastVDirection = "UP"
			dirty = true
		end
	elseif sliderFrame:GetTop() > GetScreenWidth() then
		level.lastVDirection = "DOWN"
		dirty = true
	end
	if dirty then
		sliderFrame:ClearAllPoints()
		if level.lastDirection == "RIGHT" then
			if level.lastVDirection == "DOWN" then
				sliderFrame:SetPoint("TOPLEFT", parent, "TOPRIGHT", 5, 10)
			else
				sliderFrame:SetPoint("BOTTOMLEFT", parent, "BOTTOMRIGHT", 5, -10)
			end
		else
			if level.lastVDirection == "DOWN" then
				sliderFrame:SetPoint("TOPRIGHT", parent, "TOPLEFT", -5, 10)
			else
				sliderFrame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMLEFT", -5, -10)
			end
		end
	end
	local left, bottom = sliderFrame:GetLeft(), sliderFrame:GetBottom()
	sliderFrame:ClearAllPoints()
	sliderFrame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", left, bottom)
	if mod(level.num, 5) == 0 then
		local left, bottom = level:GetLeft(), level:GetBottom()
		level:ClearAllPoints()
		level:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", left, bottom)
	end
end

function OpenEditBox(self, parent)
	if not editBoxFrame then
		editBoxFrame = CreateFrame("Frame", nil, nil)
		editBoxFrame:SetWidth(200)
		editBoxFrame:SetHeight(40)
		editBoxFrame:SetScale(UIParent:GetScale())
		editBoxFrame:SetBackdrop(tmp(
			'bgFile', "Interface\\Tooltips\\UI-Tooltip-Background",
			'edgeFile', "Interface\\Tooltips\\UI-Tooltip-Border",
			'tile', true,
			'insets', tmp2(
				'left', 5,
				'right', 5,
				'top', 5,
				'bottom', 5
			),
			'tileSize', 16,
			'edgeSize', 16
		))
		editBoxFrame:SetFrameStrata("FULLSCREEN_DIALOG")
		if editBoxFrame.SetTopLevel then
			editBoxFrame:SetTopLevel(true)
		end
		editBoxFrame:SetBackdropBorderColor(TOOLTIP_DEFAULT_COLOR.r, TOOLTIP_DEFAULT_COLOR.g, TOOLTIP_DEFAULT_COLOR.b)
		editBoxFrame:SetBackdropColor(TOOLTIP_DEFAULT_BACKGROUND_COLOR.r, TOOLTIP_DEFAULT_BACKGROUND_COLOR.g, TOOLTIP_DEFAULT_BACKGROUND_COLOR.b)
		editBoxFrame:EnableMouse(true)
		editBoxFrame:Hide()
		editBoxFrame:SetPoint("CENTER", UIParent, "CENTER")

		local editBox = CreateFrame("EditBox", nil, editBoxFrame)
		editBoxFrame.editBox = editBox
		editBox:SetFontObject(ChatFontNormal)
		editBox:SetWidth(160)
		editBox:SetHeight(13)
		editBox:SetPoint("CENTER", editBoxFrame, "CENTER", 0, 0)

		local left = editBox:CreateTexture(nil, "BACKGROUND")
		left:SetTexture("Interface\\ChatFrame\\UI-ChatInputBorder-Left")
		left:SetTexCoord(0, 100 / 256, 0, 1)
		left:SetWidth(100)
		left:SetHeight(32)
		left:SetPoint("LEFT", editBox, "LEFT", -10, 0)
		local right = editBox:CreateTexture(nil, "BACKGROUND")
		right:SetTexture("Interface\\ChatFrame\\UI-ChatInputBorder-Right")
		right:SetTexCoord(156/256, 1, 0, 1)
		right:SetWidth(100)
		right:SetHeight(32)
		right:SetPoint("RIGHT", editBox, "RIGHT", 10, 0)

		editBox:SetScript("OnEnterPressed", function()
			if editBoxFrame.parent and editBoxFrame.parent.editBoxValidateFunc then
				local a1,a2,a3,a4 = editBoxFrame.parent.editBoxValidateArg1, editBoxFrame.parent.editBoxValidateArg2, editBoxFrame.parent.editBoxValidateArg3, editBoxFrame.parent.editBoxValidateArg4

				local result
				if a1 == nil then
					result = editBoxFrame.parent.editBoxValidateFunc(editBox:GetText() or "")
				elseif a2 == nil then
					result = editBoxFrame.parent.editBoxValidateFunc(a1, editBox:GetText() or "")
				elseif a3 == nil then
					result = editBoxFrame.parent.editBoxValidateFunc(a1, a2, editBox:GetText() or "")
				elseif a4 == nil then
					result = editBoxFrame.parent.editBoxValidateFunc(a1, a2, a3, editBox:GetText() or "")
				else
					result = editBoxFrame.parent.editBoxValidateFunc(a1, a2, a3, a4, editBox:GetText() or "")
				end
				if not result then
					message("Validation error: [" .. tostring(text) .. "]")
					return
				end
			end
			if editBoxFrame.parent and editBoxFrame.parent.editBoxFunc then
				local a1,a2,a3,a4 = editBoxFrame.parent.editBoxArg1, editBoxFrame.parent.editBoxArg2, editBoxFrame.parent.editBoxArg3, editBoxFrame.parent.editBoxArg4
				if a1 == nil then
					editBoxFrame.parent.editBoxFunc(editBox:GetText() or "")
				elseif a2 == nil then
					editBoxFrame.parent.editBoxFunc(a1, editBox:GetText() or "")
				elseif a3 == nil then
					editBoxFrame.parent.editBoxFunc(a1, a2, editBox:GetText() or "")
				elseif a4 == nil then
					editBoxFrame.parent.editBoxFunc(a1, a2, a3, editBox:GetText() or "")
				else
					editBoxFrame.parent.editBoxFunc(a1, a2, a3, a4, editBox:GetText() or "")
				end
			end
			self:Close(editBoxFrame.level)
			for i = 1, editBoxFrame.level - 1 do
				Refresh(self, levels[i])
			end
		end)
		editBox:SetScript("OnEscapePressed", function()
			self:Close(editBoxFrame.level)
		end)
		local changing = false
		local skipNext = false

		function editBox:SpecialSetText(text)
			local oldText = editBox:GetText() or ""
			if not text then
				text = ""
			end
			if text ~= oldText then
				changing = true
				self:SetText(text)
				changing = false
				skipNext = true
			end
		end

		editBox:SetScript("OnTextChanged", function()
			if skipNext then
				skipNext = false
			elseif not changing and editBoxFrame.parent and editBoxFrame.parent.editBoxChangeFunc then
				local a1,a2,a3,a4 = editBoxFrame.parent.editBoxChangeArg1, editBoxFrame.parent.editBoxChangeArg2, editBoxFrame.parent.editBoxChangeArg3, editBoxFrame.parent.editBoxChangeArg4
				local text
				if a1 == nil then
					text = editBoxFrame.parent.editBoxChangeFunc(editBox:GetText() or "")
				elseif a2 == nil then
					text = editBoxFrame.parent.editBoxChangeFunc(a1, editBox:GetText() or "")
				elseif a3 == nil then
					text = editBoxFrame.parent.editBoxChangeFunc(a1, a2, editBox:GetText() or "")
				elseif a4 == nil then
					text = editBoxFrame.parent.editBoxChangeFunc(a1, a2, a3, editBox:GetText() or "")
				else
					text = editBoxFrame.parent.editBoxChangeFunc(a1, a2, a3, a4, editBox:GetText() or "")
				end
				if text then
					editBox:SpecialSetText(text)
				end
			end
		end)
		editBoxFrame:SetScript("OnEnter", function()
			StopCounting(self, editBoxFrame.level)
		end)
		editBoxFrame:SetScript("OnLeave", function()
			StartCounting(self, editBoxFrame.level)
		end)
		editBox:SetScript("OnEnter", function()
			StopCounting(self, editBoxFrame.level)
		end)
		editBox:SetScript("OnLeave", function()
			StartCounting(self, editBoxFrame.level)
		end)
	end
	editBoxFrame.parent = parent
	editBoxFrame.level = parent.level.num + 1
	editBoxFrame.parentValue = parent.level.value
	editBoxFrame:SetFrameLevel(parent.level:GetFrameLevel() + 3)
	editBoxFrame.editBox:SetFrameLevel(editBoxFrame:GetFrameLevel() + 1)
	editBoxFrame.editBox:SpecialSetText(parent.editBoxText)

	if parent.arrow then
--		parent.arrow:SetVertexColor(0.2, 0.6, 0)
		parent.arrow:SetHeight(24)
		parent.arrow:SetWidth(24)
	end

	local level = parent.level
	editBoxFrame:Show()
	editBoxFrame:ClearAllPoints()
	if level.lastDirection == "RIGHT" then
		if level.lastVDirection == "DOWN" then
			editBoxFrame:SetPoint("TOPLEFT", parent, "TOPRIGHT", 5, 10)
		else
			editBoxFrame:SetPoint("BOTTOMLEFT", parent, "BOTTOMRIGHT", 5, -10)
		end
	else
		if level.lastVDirection == "DOWN" then
			editBoxFrame:SetPoint("TOPRIGHT", parent, "TOPLEFT", -5, 10)
		else
			editBoxFrame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMLEFT", -5, -10)
		end
	end
	local dirty
	if level.lastDirection == "RIGHT" then
		if editBoxFrame:GetRight() > GetScreenWidth() then
			level.lastDirection = "LEFT"
			dirty = true
		end
	elseif editBoxFrame:GetLeft() < 0 then
		level.lastDirection = "RIGHT"
		dirty = true
	end
	if level.lastVDirection == "DOWN" then
		if editBoxFrame:GetBottom() < 0 then
			level.lastVDirection = "UP"
			dirty = true
		end
	elseif editBoxFrame:GetTop() > GetScreenWidth() then
		level.lastVDirection = "DOWN"
		dirty = true
	end
	if dirty then
		editBoxFrame:ClearAllPoints()
		if level.lastDirection == "RIGHT" then
			if level.lastVDirection == "DOWN" then
				editBoxFrame:SetPoint("TOPLEFT", parent, "TOPRIGHT", 5, 10)
			else
				editBoxFrame:SetPoint("BOTTOMLEFT", parent, "BOTTOMRIGHT", 5, -10)
			end
		else
			if level.lastVDirection == "DOWN" then
				editBoxFrame:SetPoint("TOPRIGHT", parent, "TOPLEFT", -5, 10)
			else
				editBoxFrame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMLEFT", -5, -10)
			end
		end
	end
	local left, bottom = editBoxFrame:GetLeft(), editBoxFrame:GetBottom()
	editBoxFrame:ClearAllPoints()
	editBoxFrame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", left, bottom)
	if mod(level.num, 5) == 0 then
		local left, bottom = level:GetLeft(), level:GetBottom()
		level:ClearAllPoints()
		level:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", left, bottom)
	end
end

function Dewdrop:IsOpen(parent)
	self:argCheck(parent, 2, "table", "nil")
	return levels[1] and levels[1]:IsShown() and (not parent or parent == levels[1].parent or parent == levels[1]:GetParent())
end

function Dewdrop:GetOpenedParent()
	return (levels[1] and levels[1]:IsShown()) and (levels[1].parent or levels[1]:GetParent())
end

function Open(self, parent, func, level, value, point, relativePoint, cursorX, cursorY)
	self:Close(level)
	if DewdropLib then
		local d = DewdropLib:GetInstance('1.0')
		local ret, val = pcall(d, IsOpen, d)
		if ret and val then
			DewdropLib:GetInstance('1.0'):Close()
		end
	end
	parent:GetCenter()
	local frame = AcquireLevel(self, level)
	if level == 1 then
		frame.lastDirection = "RIGHT"
		frame.lastVDirection = "DOWN"
	else
		frame.lastDirection = levels[level - 1].lastDirection
		frame.lastVDirection = levels[level - 1].lastVDirection
	end
	frame:SetFrameStrata("FULLSCREEN_DIALOG")
	frame:ClearAllPoints()
	frame.parent = parent
	frame:SetPoint("LEFT", UIParent, "RIGHT", 10000, 0)
	frame:Show()
	if level == 1 then
		baseFunc = func
	end
	levels[level].value = value
--	levels[level].parentText = parent.text and parent.text:GetText() or nil
--	levels[level].parentTooltipTitle = parent.tooltipTitle
--	levels[level].parentTooltipText = parent.tooltipText
--	levels[level].parentTooltipFunc = parent.tooltipFunc
	if parent.arrow then
--		parent.arrow:SetVertexColor(0.2, 0.6, 0)
		parent.arrow:SetHeight(24)
		parent.arrow:SetWidth(24)
	end
	relativePoint = relativePoint or point
	Refresh(self, levels[level])
	if point or (cursorX and cursorY) then
		frame:ClearAllPoints()
		if cursorX and cursorY then
			local curX, curY = GetScaledCursorPosition()
			if curY < GetScreenHeight() / 2 then
				point, relativePoint = "BOTTOM", "BOTTOM"
			else
				point, relativePoint = "TOP", "TOP"
			end
			if curX < GetScreenWidth() / 2 then
				point, relativePoint = point .. "LEFT", relativePoint .. "RIGHT"
			else
				point, relativePoint = point .. "RIGHT", relativePoint .. "LEFT"
			end
		end
		frame:SetPoint(point, parent, relativePoint)
		if cursorX and cursorY then
			local left = frame:GetLeft()
			local width = frame:GetWidth()
			local bottom = frame:GetBottom()
			local height = frame:GetHeight()
			local curX, curY = GetScaledCursorPosition()
			frame:ClearAllPoints()
			relativePoint = relativePoint or point
			if point == "BOTTOM" or point == "TOP" then
				if curX < GetScreenWidth() / 2 then
					point = point .. "LEFT"
				else
					point = point .. "RIGHT"
				end
			elseif point == "CENTER" then
				if curX < GetScreenWidth() / 2 then
					point = "LEFT"
				else
					point = "RIGHT"
				end
			end
			local xOffset, yOffset = 0, 0
			if curY > GetScreenHeight() / 2 then
				yOffset = -height
			end
			if curX > GetScreenWidth() / 2 then
				xOffset = -width
			end
			frame:SetPoint(point, parent, relativePoint, curX - left + xOffset, curY - bottom + yOffset)
			if level == 1 then
				frame.lastDirection = "RIGHT"
			end
		elseif cursorX then
			local left = frame:GetLeft()
			local width = frame:GetWidth()
			local curX, curY = GetScaledCursorPosition()
			frame:ClearAllPoints()
			relativePoint = relativePoint or point
			if point == "BOTTOM" or point == "TOP" then
				if curX < GetScreenWidth() / 2 then
					point = point .. "LEFT"
				else
					point = point .. "RIGHT"
				end
			elseif point == "CENTER" then
				if curX < GetScreenWidth() / 2 then
					point = "LEFT"
				else
					point = "RIGHT"
				end
			end
			frame:SetPoint(point, parent, relativePoint, curX - left - width / 2, 0)
			if level == 1 then
				frame.lastDirection = "RIGHT"
			end
		elseif cursorY then
			local bottom = frame:GetBottom()
			local height = frame:GetHeight()
			local curX, curY = GetScaledCursorPosition()
			frame:ClearAllPoints()
			relativePoint = relativePoint or point
			if point == "LEFT" or point == "RIGHT" then
				if curX < GetScreenHeight() / 2 then
					point = point .. "BOTTOM"
				else
					point = point .. "TOP"
				end
			elseif point == "CENTER" then
				if curX < GetScreenHeight() / 2 then
					point = "BOTTOM"
				else
					point = "TOP"
				end
			end
			frame:SetPoint(point, parent, relativePoint, 0, curY - bottom - height / 2)
			if level == 1 then
				frame.lastDirection = "DOWN"
			end
		end
		if (strsub(point, 1, 3) ~= strsub(relativePoint, 1, 3)) then
			if frame:GetBottom() < 0 then
				local point, parent, relativePoint, x, y = frame:GetPoint(1)
				local change = GetScreenHeight() - frame:GetTop()
				local otherChange = -frame:GetBottom()
				if otherChange < change then
					change = otherChange
				end
				frame:SetPoint(point, parent, relativePoint, x, y + change)
			elseif frame:GetTop() > GetScreenHeight() then
				local point, parent, relativePoint, x, y = frame:GetPoint(1)
				local change = GetScreenHeight() - frame:GetTop()
				local otherChange = -frame:GetBottom()
				if otherChange < change then
					change = otherChange
				end
				frame:SetPoint(point, parent, relativePoint, x, y + change)
			end
		end
	end
	CheckDualMonitor(self, frame)
	StartCounting(self, level)
end

function Dewdrop:IsRegistered(parent)
	self:argCheck(parent, 2, "table")
	return not not self.registry[parent]
end

function Dewdrop:Register(parent, k1, v1, k2, v2, k3, v3, k4, v4, k5, v5, k6, v6, k7, v7, k8, v8, k9, v9, k10, v10, k11, v11, k12, v12, k13, v13, k14, v14, k15, v15, k16, v16, k17, v17, k18, v18, k19, v19, k20, v20)
	self:argCheck(parent, 2, "table")
	if self.registry[parent] then
		self:Unregister(parent)
	end
	local info = new(k1, v1, k2, v2, k3, v3, k4, v4, k5, v5, k6, v6, k7, v7, k8, v8, k9, v9, k10, v10, k11, v11, k12, v12, k13, v13, k14, v14, k15, v15, k16, v16, k17, v17, k18, v18, k19, v19, k20, v20)
	if type(info.children) == "table" then
		local err, position = validateOptions(info.children)

		if err then
			if position then
				Dewdrop:error(position .. ": " .. err)
			else
				Dewdrop:error(err)
			end
		end
	end
	self.registry[parent] = info
	if not info.dontHook and not self.onceRegistered[parent] then
		if parent:HasScript("OnMouseUp") then
			local script = parent:GetScript("OnMouseUp")
			parent:SetScript("OnMouseUp", function()
				if script then
					script()
				end
				if arg1 == "RightButton" and self.registry[parent] then
					if self:IsOpen(parent) then
						self:Close()
					else
						self:Open(parent)
					end
				end
			end)
		end
		if parent:HasScript("OnMouseDown") then
			local script = parent:GetScript("OnMouseDown")
			parent:SetScript("OnMouseDown", function()
				if script then
					script()
				end
				if self.registry[parent] then
					self:Close()
				end
			end)
		end
	end
	self.onceRegistered[parent] = true
end

function Dewdrop:Unregister(parent)
	self:argCheck(parent, 2, "table")
	self.registry[parent] = nil
end

function Dewdrop:Open(parent, k1, v1, k2, v2, k3, v3, k4, v4, k5, v5, k6, v6, k7, v7, k8, v8, k9, v9, k10, v10, k11, v11, k12, v12, k13, v13, k14, v14, k15, v15, k16, v16, k17, v17, k18, v18, k19, v19, k20, v20)
	self:argCheck(parent, 2, "table")
	local info
	if type(k1) == "table" and k1[0] and k1.IsFrameType and self.registry[k1] then
		info = tmp()
		for k,v in pairs(self.registry[k1]) do
			info[k] = v
		end
	else
		info = tmp(k1, v1, k2, v2, k3, v3, k4, v4, k5, v5, k6, v6, k7, v7, k8, v8, k9, v9, k10, v10, k11, v11, k12, v12, k13, v13, k14, v14, k15, v15, k16, v16, k17, v17, k18, v18, k19, v19, k20, v20)
		if self.registry[parent] then
			for k,v in pairs(self.registry[parent]) do
				if info[k] == nil then
					info[k] = v
				end
			end
		end
	end
	local point = info.point
	local relativePoint = info.relativePoint
	local cursorX = info.cursorX
	local cursorY = info.cursorY
	if type(point) == "function" then
		local b
		point, b = point(parent)
		if b then
			relativePoint = b
		end
	end
	if type(relativePoint) == "function" then
		relativePoint = relativePoint(parent)
	end
	Open(self, parent, info.children, 1, nil, point, relativePoint, cursorX, cursorY)
end

function Clear(self, level)
	if level then
		if level.buttons then
			for i = table.getn(level.buttons), 1, -1 do
				ReleaseButton(self, level, i)
			end
		end
	end
end

function Dewdrop:Close(level)
	if DropDownList1:IsShown() then
		DropDownList1:Hide()
	end
	if DewdropLib then
		local d = DewdropLib:GetInstance('1.0')
		local ret, val = pcall(d, IsOpen, d)
		if ret and val then
			DewdropLib:GetInstance('1.0'):Close()
		end
	end
	self:argCheck(level, 2, "number", "nil")
	if not level then
		level = 1
	end
	if level == 1 and levels[level] then
		levels[level].parented = false
	end
	if level > 1 and levels[level-1].buttons then
		local buttons = levels[level-1].buttons
		for _,button in ipairs(buttons) do
			button.arrow:SetWidth(16)
			button.arrow:SetHeight(16)
--			button.arrow:SetVertexColor(1, 1, 1)
		end
	end
	if sliderFrame and sliderFrame.level >= level then
		sliderFrame:Hide()
	end
	if editBoxFrame and editBoxFrame.level >= level then
		editBoxFrame:Hide()
	end
	for i = level, table.getn(levels) do
		Clear(self, levels[level])
		levels[level]:Hide()
		levels[i]:ClearAllPoints()
		levels[i]:SetPoint("CENTER", UIParent, "CENTER")
	end
end

function Dewdrop:AddLine(k1, v1, k2, v2, k3, v3, k4, v4, k5, v5, k6, v6, k7, v7, k8, v8, k9, v9, k10, v10, k11, v11, k12, v12, k13, v13, k14, v14, k15, v15, k16, v16, k17, v17, k18, v18, k19, v19, k20, v20)
	local info = tmp(k1, v1, k2, v2, k3, v3, k4, v4, k5, v5, k6, v6, k7, v7, k8, v8, k9, v9, k10, v10, k11, v11, k12, v12, k13, v13, k14, v14, k15, v15, k16, v16, k17, v17, k18, v18, k19, v19, k20, v20)
	local level = info.level or currentLevel
	info.level = nil
	local button = AcquireButton(self, level)
	if not next(info) then
		info.disabled = true
	end
	button.disabled = info.isTitle or info.notClickable or info.disabled
	button.isTitle = info.isTitle
	button.notClickable = info.notClickable
	if button.isTitle then
		button.text:SetFontObject(GameFontNormalSmall)
	elseif button.notClickable then
		button.text:SetFontObject(GameFontHighlightSmall)
	elseif button.disabled then
		button.text:SetFontObject(GameFontDisableSmall)
	else
		button.text:SetFontObject(GameFontHighlightSmall)
	end
	if info.disabled then
		button.arrow:SetDesaturated(true)
		button.check:SetDesaturated(true)
	else
		button.arrow:SetDesaturated(false)
		button.check:SetDesaturated(false)
	end
	if info.textR and info.textG and info.textB then
		button.textR = info.textR
		button.textG = info.textG
		button.textB = info.textB
		button.text:SetTextColor(button.textR, button.textG, button.textB)
	else
		button.text:SetTextColor(button.text:GetFontObject():GetTextColor())
	end
	button.notCheckable = info.notCheckable
	button.text:SetPoint("LEFT", button, "LEFT", button.notCheckable and 0 or 24, 0)
	button.checked = not info.notCheckable and info.checked
	button.isRadio = not info.notCheckable and info.isRadio
	if info.isRadio then
		button.check:Show()
		button.check:SetTexture(info.checkIcon or "Interface\\Buttons\\UI-RadioButton")
		if button.checked then
			button.check:SetTexCoord(0.25, 0.5, 0, 1)
			button.check:SetVertexColor(1, 1, 1, 1)
		else
			button.check:SetTexCoord(0, 0.25, 0, 1)
			button.check:SetVertexColor(1, 1, 1, 0.5)
		end
		button.radioHighlight:SetTexture(info.checkIcon or "Interface\\Buttons\\UI-RadioButton")
		button.check:SetWidth(16)
		button.check:SetHeight(16)
	elseif info.icon then
		button.check:Show()
		button.check:SetTexture(info.icon)
		if info.iconWidth and info.iconHeight then
			button.check:SetWidth(info.iconWidth)
			button.check:SetHeight(info.iconHeight)
		else
			button.check:SetWidth(16)
			button.check:SetHeight(16)
		end
		if info.iconCoordLeft and info.iconCoordRight and info.iconCoordTop and info.iconCoordBottom then
			button.check:SetTexCoord(info.iconCoordLeft, info.iconCoordRight, info.iconCoordTop, info.iconCoordBottom)
		elseif string.find(info.checkIcon, "^Interface\\Icons\\") then
			button.check:SetTexCoord(0.05, 0.95, 0.05, 0.95)
		else
			button.check:SetTexCoord(0, 1, 0, 1)
		end
		button.check:SetVertexColor(1, 1, 1, 1)
	else
		if button.checked then
			if info.checkIcon then
				button.check:SetWidth(16)
				button.check:SetHeight(16)
				button.check:SetTexture(info.checkIcon)
				if string.find(info.checkIcon, "^Interface\\Icons\\") then
					button.check:SetTexCoord(0.05, 0.95, 0.05, 0.95)
				else
					button.check:SetTexCoord(0, 1, 0, 1)
				end
			else
				button.check:SetWidth(24)
				button.check:SetHeight(24)
				button.check:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
				button.check:SetTexCoord(0, 1, 0, 1)
			end
			button.check:SetVertexColor(1, 1, 1, 1)
		else
			button.check:SetVertexColor(1, 1, 1, 0)
		end
	end
	if not button.disabled then
		button.func = info.func
	end
	button.hasColorSwatch = info.hasColorSwatch
	if button.hasColorSwatch then
		button.colorSwatch:Show()
		button.colorSwatch.texture:Show()
		button.r = info.r or 1
		button.g = info.g or 1
		button.b = info.b or 1
		button.colorSwatch.texture:SetTexture(button.r, button.g, button.b)
		button.checked = false
		button.func = nil
		button.colorFunc = info.colorFunc
		button.colorArg1 = info.colorArg1
		button.colorArg2 = info.colorArg2
		button.colorArg3 = info.colorArg3
		button.colorArg4 = info.colorArg4
		button.hasOpacity = info.hasOpacity
		button.opacity = info.opacity or 1
	else
		button.colorSwatch:Hide()
		button.colorSwatch.texture:Hide()
	end
	button.hasArrow = not button.hasColorSwatch and (info.value or info.hasSlider or info.hasEditBox) and info.hasArrow
	if button.hasArrow then
		button.arrow:SetAlpha(1)
		if info.hasSlider then
			button.hasSlider = true
			button.sliderMin = info.sliderMin or 0
			button.sliderMax = info.sliderMax or 1
			button.sliderStep = info.sliderStep or 0
			button.sliderIsPercent = info.sliderIsPercent and true or false
			button.sliderMinText = info.sliderMinText or button.sliderIsPercent and string.format("%.0f%%", button.sliderMin * 100) or button.sliderMin
			button.sliderMaxText = info.sliderMaxText or button.sliderIsPercent and string.format("%.0f%%", button.sliderMax * 100) or button.sliderMax
			button.sliderFunc = info.sliderFunc
			button.sliderValue = info.sliderValue
			button.sliderArg1 = info.sliderArg1
			button.sliderArg2 = info.sliderArg2
			button.sliderArg3 = info.sliderArg3
			button.sliderArg4 = info.sliderArg4
		elseif info.hasEditBox then
			button.hasEditBox = true
			button.editBoxText = info.editBoxText or ""
			button.editBoxFunc = info.editBoxFunc
			button.editBoxArg1 = info.editBoxArg1
			button.editBoxArg2 = info.editBoxArg2
			button.editBoxArg3 = info.editBoxArg3
			button.editBoxArg4 = info.editBoxArg4
			button.editBoxChangeFunc = info.editBoxChangeFunc
			button.editBoxChangeArg1 = info.editBoxChangeArg1
			button.editBoxChangeArg2 = info.editBoxChangeArg2
			button.editBoxChangeArg3 = info.editBoxChangeArg3
			button.editBoxChangeArg4 = info.editBoxChangeArg4
			button.editBoxValidateFunc = info.editBoxValidateFunc
			button.editBoxValidateArg1 = info.editBoxValidateArg1
			button.editBoxValidateArg2 = info.editBoxValidateArg2
			button.editBoxValidateArg3 = info.editBoxValidateArg3
			button.editBoxValidateArg4 = info.editBoxValidateArg4
		else
			button.value = info.value
		end
	else
		button.arrow:SetAlpha(0)
	end
	button.arg1 = info.arg1
	button.arg2 = info.arg2
	button.arg3 = info.arg3
	button.arg4 = info.arg4
	button.closeWhenClicked = info.closeWhenClicked
	button.textHeight = info.textHeight or UIDROPDOWNMENU_DEFAULT_TEXT_HEIGHT or 10
	local font,_ = button.text:GetFont()
	button.text:SetFont(STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF", button.textHeight)
	button:SetHeight(button.textHeight + 6)
	button.text:SetPoint("RIGHT", button.arrow, (button.hasColorSwatch or button.hasArrow) and "LEFT" or "RIGHT")
	button.text:SetJustifyH(info.justifyH or "LEFT")
	button.text:SetText(info.text)
	button.tooltipTitle = info.tooltipTitle
	button.tooltipText = info.tooltipText
	button.tooltipFunc = info.tooltipFunc
	button.tooltipArg1 = info.tooltipArg1
	button.tooltipArg2 = info.tooltipArg2
	button.tooltipArg3 = info.tooltipArg3
	button.tooltipArg4 = info.tooltipArg4
	if not button.tooltipTitle and not button.tooltipText and not button.tooltipFunc and not info.isTitle then
		button.tooltipTitle = info.text
	end
	if type(button.func) == "string" then
		self:assert(type(button.arg1) == "table", "Cannot call method " .. button.func .. " on a non-table")
		self:assert(type(button.arg1[button.func]) == "function", "Method " .. button.func .. " nonexistant.")
	end
end

function Dewdrop:InjectAceOptionsTable(handler, options)
	self:argCheck(handler, 2, "table")
	self:argCheck(options, 3, "table")
	if string.lower(tostring(options.type)) ~= "group" then
		self:error('Cannot inject into options table argument #3 if its type is not "group"')
	end
	if options.handler ~= nil and options.handler ~= handler then
		self:error("Cannot inject into options table argument #3 if it has a different handler than argument #2")
	end
	options.handler = handler
	local class = handler.class
	if not AceLibrary:HasInstance("AceOO-2.0") or not class then
		self:error("Cannot retrieve AceOptions tables from a non-object argument #2")
	end
	while class and class ~= AceLibrary("AceOO-2.0").Class do
		if type(class.GetAceOptionsDataTable) == "function" then
			local t = class:GetAceOptionsDataTable(handler)
			for k,v in pairs(t) do
				if type(options.args) ~= "table" then
					options.args = {}
				end
				if options.args[k] == nil then
					options.args[k] = v
				end
			end
		end
		local mixins = class.mixins
		if mixins then
			for mixin in pairs(mixins) do
				if type(mixin.GetAceOptionsDataTable) == "function" then
					local t = mixin:GetAceOptionsDataTable(handler)
					for k,v in pairs(t) do
						if type(options.args) ~= "table" then
							options.args = {}
						end
						if options.args[k] == nil then
							options.args[k] = v
						end
					end
				end
			end
		end
		class = class.super
	end
	return options
end

local function activate(self, oldLib, oldDeactivate)
	Dewdrop = self
	if oldLib and oldLib.registry then
		self.registry = oldLib.registry
		self.onceRegistered = oldLib.onceRegistered
	else
		self.registry = {}
		self.onceRegistered = {}

		local WorldFrame_OnMouseDown = WorldFrame:GetScript("OnMouseDown")
		local WorldFrame_OnMouseUp = WorldFrame:GetScript("OnMouseUp")
		local oldX, oldY, clickTime
		WorldFrame:SetScript("OnMouseDown", function()
			oldX,oldY = GetCursorPosition()
			clickTime = GetTime()
			if WorldFrame_OnMouseDown then
				WorldFrame_OnMouseDown()
			end
		end)

		WorldFrame:SetScript("OnMouseUp", function()
			local x,y = GetCursorPosition()
			if not oldX or not oldY or not x or not y or not clickTime then
				self:Close()
				if WorldFrame_OnMouseUp then
					WorldFrame_OnMouseUp()
				end
				return
			end
			local d = math.abs(x - oldX) + math.abs(y - oldY)
			if d <= 5 and GetTime() - clickTime < 0.5 then
				self:Close()
			end
			if WorldFrame_OnMouseUp then
				WorldFrame_OnMouseUp()
			end
		end)

		if hooksecurefunc then
			hooksecurefunc(DropDownList1, "Show", function()
				if levels[1] and levels[1]:IsVisible() then
					self:Close()
				end
			end)
		else
			local DropDownList1_Show = DropDownList1.Show
			function DropDownList1.Show(DropDownList1)
				if levels[1] and levels[1]:IsVisible() then
					self:Close()
				end
				DropDownList1_Show(DropDownList1)
			end
		end

		if hooksecurefunc then
			hooksecurefunc("HideDropDownMenu", function()
				if levels[1] and levels[1]:IsVisible() then
					self:Close()
				end
			end)
		else
			local old_HideDropDownMenu = HideDropDownMenu
			function HideDropDownMenu(num)
				if levels[1] and levels[1]:IsVisible() then
					self:Close()
				end
				old_HideDropDownMenu(num)
			end
		end

		if hooksecurefunc then
			hooksecurefunc("CloseDropDownMenus", function()
				if levels[1] and levels[1]:IsVisible() then
					self:Close()
				end
			end)
		else
			local old_CloseDropDownMenus = CloseDropDownMenus
			function CloseDropDownMenus(num)
				if levels[1] and levels[1]:IsVisible() then
					self:Close()
				end
				old_CloseDropDownMenus(num)
			end
		end
	end
	levels = {}
	buttons = {}

	if oldDeactivate then
		oldDeactivate(oldLib)
	end
end

AceLibrary:Register(Dewdrop, MAJOR_VERSION, MINOR_VERSION, activate)
