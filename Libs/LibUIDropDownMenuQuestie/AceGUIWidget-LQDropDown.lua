--[[ $Id: AceGUIWidget-DropDown.lua 1167 2017-08-29 22:08:48Z funkydude $ ]]--
-- modification for questie to use LibUiDropDownMenu to prevent taint
local AceGUI = LibStub("AceGUI-3.0")

-- Lua APIs
local min, max, floor = math.min, math.max, math.floor
local select, pairs, ipairs, type = select, pairs, ipairs, type
local tsort = table.sort

-- WoW APIs
local PlaySound = PlaySound
local UIParent, CreateFrame = UIParent, CreateFrame
local _G = _G

-- Global vars/functions that we don't upvalue since they might get hooked, or upgraded
-- List them here for Mikk's FindGlobals script
-- GLOBALS: CLOSE

local function fixlevels(parent,...)
	local i = 1
	local child = select(i, ...)
	while child do
		child:SetFrameLevel(parent:GetFrameLevel()+1)
		fixlevels(child, child:GetChildren())
		i = i + 1
		child = select(i, ...)
	end
end

local function fixstrata(strata, parent, ...)
	local i = 1
	local child = select(i, ...)
	parent:SetFrameStrata(strata)
	while child do
		fixstrata(strata, child, child:GetChildren())
		i = i + 1
		child = select(i, ...)
	end
end

do
	local widgetType = "LQDropdown"
	local widgetVersion = 1
	
	--[[ Static data ]]--
	
	--[[ UI event handler ]]--
	
	local function Control_OnEnter(this)
		this.obj.button:LockHighlight()
		this.obj:Fire("OnEnter")
	end
	
	local function Control_OnLeave(this)
		this.obj.button:UnlockHighlight()
		this.obj:Fire("OnLeave")
	end

	local function Dropdown_OnHide(this)
		local self = this.obj
		if self.open then
			self.pullout:Close()
		end
	end
	
	local function Dropdown_TogglePullout(this)
		local self = this.obj
		PlaySound(856) -- SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON
		if self.open then
			self.open = nil
			self.pullout:Close()
			AceGUI:ClearFocus()
		else
			self.open = true
			self.pullout:SetWidth(self.pulloutWidth or self.frame:GetWidth())
			self.pullout:Open("TOPLEFT", self.frame, "BOTTOMLEFT", 0, self.label:IsShown() and -2 or 0)
			AceGUI:SetFocus(self)
		end
	end
	
	local function OnPulloutOpen(this)
		local self = this.userdata.obj
		local value = self.value
		
		if not self.multiselect then
			for i, item in this:IterateItems() do
				item:SetValue(item.userdata.value == value)
			end
		end
		
		self.open = true
		self:Fire("OnOpened")
	end

	local function OnPulloutClose(this)
		local self = this.userdata.obj
		self.open = nil
		self:Fire("OnClosed")
	end
	
	local function ShowMultiText(self)
		local text
		for i, widget in self.pullout:IterateItems() do
			if widget.type == "Dropdown-Item-Toggle" then
				if widget:GetValue() then
					if text then
						text = text..", "..widget:GetText()
					else
						text = widget:GetText()
					end
				end
			end
		end
		self:SetText(text)
	end
	
	local function OnItemValueChanged(this, event, checked)
		local self = this.userdata.obj
		
		if self.multiselect then
			self:Fire("OnValueChanged", this.userdata.value, checked)
			ShowMultiText(self)
		else
			if checked then
				self:SetValue(this.userdata.value)
				self:Fire("OnValueChanged", this.userdata.value)
			else
				this:SetValue(true)
			end
			if self.open then	
				self.pullout:Close()
			end
		end
	end
	
	--[[ Exported methods ]]--
	
	-- exported, AceGUI callback
	local function OnAcquire(self)
		local pullout = AceGUI:Create("Dropdown-Pullout")
		self.pullout = pullout
		pullout.userdata.obj = self
		pullout:SetCallback("OnClose", OnPulloutClose)
		pullout:SetCallback("OnOpen", OnPulloutOpen)
		self.pullout.frame:SetFrameLevel(self.frame:GetFrameLevel() + 1)
		fixlevels(self.pullout.frame, self.pullout.frame:GetChildren())
		
		self:SetHeight(44)
		self:SetWidth(200)
		self:SetLabel()
		self:SetPulloutWidth(nil)
	end
	
	-- exported, AceGUI callback
	local function OnRelease(self)
		if self and ((not self.IsForbidden) or not self:IsForbidden()) then
			if self.open then
				self.pullout:Close()
			end
			AceGUI:Release(self.pullout)
			self.pullout = nil
			
			self:SetText("")
			self:SetDisabled(false)
			self:SetMultiselect(false)
			
			self.value = nil
			self.list = nil
			self.open = nil
			self.hasClose = nil
			
			self.frame:ClearAllPoints()
			self.frame:Hide()
		end
	end
	
	-- exported
	local function SetDisabled(self, disabled)
		self.disabled = disabled
		if disabled then
			self.text:SetTextColor(0.5,0.5,0.5)
			self.button:Disable()
			self.button_cover:Disable()
			self.label:SetTextColor(0.5,0.5,0.5)
		else
			self.button:Enable()
			self.button_cover:Enable()
			self.label:SetTextColor(1,.82,0)
			self.text:SetTextColor(1,1,1)
		end
	end
	
	-- exported
	local function ClearFocus(self)
		if self.open then
			self.pullout:Close()
		end
	end
	
	-- exported
	local function SetText(self, text)
		self.text:SetText(text or "")
	end
	
	-- exported
	local function SetLabel(self, text)
		if text and text ~= "" then
			self.label:SetText(text)
			self.label:Show()
			self.dropdown:SetPoint("TOPLEFT",self.frame,"TOPLEFT",-15,-14)
			self:SetHeight(40)
			self.alignoffset = 26
		else
			self.label:SetText("")
			self.label:Hide()
			self.dropdown:SetPoint("TOPLEFT",self.frame,"TOPLEFT",-15,0)
			self:SetHeight(26)
			self.alignoffset = 12
		end
	end
	
	-- exported
	local function SetValue(self, value)
		if self.list then
			self:SetText(self.list[value] or "")
		end
		self.value = value
	end
	
	-- exported
	local function GetValue(self)
		return self.value
	end
	
	-- exported
	local function SetItemValue(self, item, value)
		if not self.multiselect then return end
		for i, widget in self.pullout:IterateItems() do
			if widget.userdata.value == item then
				if widget.SetValue then
					widget:SetValue(value)
				end
			end
		end
		ShowMultiText(self)
	end
	
	-- exported
	local function SetItemDisabled(self, item, disabled)
		for i, widget in self.pullout:IterateItems() do
			if widget.userdata.value == item then
				widget:SetDisabled(disabled)
			end
		end
	end
	
	local function AddListItem(self, value, text, itemType)
		if not itemType then itemType = "Dropdown-Item-Toggle" end
		local exists = AceGUI:GetWidgetVersion(itemType)
		if not exists then error(("The given item type, %q, does not exist within AceGUI-3.0"):format(tostring(itemType)), 2) end

		local item = AceGUI:Create(itemType)
		item:SetText(text)
		item.userdata.obj = self
		item.userdata.value = value
		item:SetCallback("OnValueChanged", OnItemValueChanged)
		self.pullout:AddItem(item)
	end
	
	local function AddCloseButton(self)
		if not self.hasClose then
			local close = AceGUI:Create("Dropdown-Item-Execute")
			close:SetText(CLOSE)
			self.pullout:AddItem(close)
			self.hasClose = true
		end
	end
	
	-- exported
	local sortlist = {}
	local function SetList(self, list, order, itemType)
		self.list = list
		self.pullout:Clear()
		self.hasClose = nil
		if not list then return end
		
		if type(order) ~= "table" then
			for v in pairs(list) do
				sortlist[#sortlist + 1] = v
			end
			tsort(sortlist)
			
			for i, key in ipairs(sortlist) do
				AddListItem(self, key, list[key], itemType)
				sortlist[i] = nil
			end
		else
			for i, key in ipairs(order) do
				AddListItem(self, key, list[key], itemType)
			end
		end
		if self.multiselect then
			ShowMultiText(self)
			AddCloseButton(self)
		end
	end
	
	-- exported
	local function AddItem(self, value, text, itemType)
		if self.list then
			self.list[value] = text
			AddListItem(self, value, text, itemType)
		end
	end
	
	-- exported
	local function SetMultiselect(self, multi)
		self.multiselect = multi
		if multi then
			ShowMultiText(self)
			AddCloseButton(self)
		end
	end
	
	-- exported
	local function GetMultiselect(self)
		return self.multiselect
	end
	
	local function SetPulloutWidth(self, width)
		self.pulloutWidth = width
	end
	
	--[[ Constructor ]]--
	
	local function Constructor()
		local count = AceGUI:GetNextWidgetNum(widgetType)
		local frame = CreateFrame("Frame", nil, UIParent)
		local dropdown = LQuestie_Create_UIDropDownMenu("AceGUI30LQDropDown"..count, frame)--local dropdown = CreateFrame("Frame", "AceGUI30DropDown"..count, frame, "UIDropDownMenuTemplate")
		
		local self = {}
		self.type = widgetType
		self.frame = frame
		self.dropdown = dropdown
		self.count = count
		frame.obj = self
		dropdown.obj = self
		
		self.OnRelease   = OnRelease
		self.OnAcquire   = OnAcquire
		
		self.ClearFocus  = ClearFocus

		self.SetText     = SetText
		self.SetValue    = SetValue
		self.GetValue    = GetValue
		self.SetList     = SetList
		self.SetLabel    = SetLabel
		self.SetDisabled = SetDisabled
		self.AddItem     = AddItem
		self.SetMultiselect = SetMultiselect
		self.GetMultiselect = GetMultiselect
		self.SetItemValue = SetItemValue
		self.SetItemDisabled = SetItemDisabled
		self.SetPulloutWidth = SetPulloutWidth
		
		self.alignoffset = 26
		
		frame:SetScript("OnHide",Dropdown_OnHide)

		dropdown:ClearAllPoints()
		dropdown:SetPoint("TOPLEFT",frame,"TOPLEFT",-15,0)
		dropdown:SetPoint("BOTTOMRIGHT",frame,"BOTTOMRIGHT",17,0)
		dropdown:SetScript("OnHide", nil)

		local left = _G[dropdown:GetName() .. "Left"]
		local middle = _G[dropdown:GetName() .. "Middle"]
		local right = _G[dropdown:GetName() .. "Right"]
		
		middle:ClearAllPoints()
		right:ClearAllPoints()
		
		middle:SetPoint("LEFT", left, "RIGHT", 0, 0)
		middle:SetPoint("RIGHT", right, "LEFT", 0, 0)
		right:SetPoint("TOPRIGHT", dropdown, "TOPRIGHT", 0, 17)

		local button = _G[dropdown:GetName() .. "Button"]
		self.button = button
		button.obj = self
		button:SetScript("OnEnter",Control_OnEnter)
		button:SetScript("OnLeave",Control_OnLeave)
		button:SetScript("OnClick",Dropdown_TogglePullout)
		
		local button_cover = CreateFrame("BUTTON",nil,self.frame)
		self.button_cover = button_cover
		button_cover.obj = self
		button_cover:SetPoint("TOPLEFT",self.frame,"BOTTOMLEFT",0,25)
		button_cover:SetPoint("BOTTOMRIGHT",self.frame,"BOTTOMRIGHT")
		button_cover:SetScript("OnEnter",Control_OnEnter)
		button_cover:SetScript("OnLeave",Control_OnLeave)
		button_cover:SetScript("OnClick",Dropdown_TogglePullout)
		
		local text = _G[dropdown:GetName() .. "Text"]
		self.text = text
		text.obj = self
		text:ClearAllPoints()
		text:SetPoint("RIGHT", right, "RIGHT" ,-43, 2)
		text:SetPoint("LEFT", left, "LEFT", 25, 2)
		
		local label = frame:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
		label:SetPoint("TOPLEFT",frame,"TOPLEFT",0,0)
		label:SetPoint("TOPRIGHT",frame,"TOPRIGHT",0,0)
		label:SetJustifyH("LEFT")
		label:SetHeight(18)
		label:Hide()
		self.label = label

		AceGUI:RegisterAsWidget(self)
		return self
	end
	
	AceGUI:RegisterWidgetType(widgetType, Constructor, widgetVersion)
end	
