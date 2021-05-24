-- $Id: LibUIDropDownMenuTemplates.lua 64 2020-11-18 13:13:15Z arithmandar $
-- ----------------------------------------------------------------------------
-- Localized Lua globals.
-- ----------------------------------------------------------------------------
--[[local _G = getfenv(0)
-- ----------------------------------------------------------------------------
local MAJOR_VERSION = "LibUIDropDownMenuTemplates-3.0"
local MINOR_VERSION = 90000 + tonumber(("$Rev: 64 $"):match("%d+"))

local LibStub = _G.LibStub
if not LibStub then error(MAJOR_VERSION .. " requires LibStub.") end
local Lib = LibStub:NewLibrary(MAJOR_VERSION, MINOR_VERSION)
if not Lib then return end

-- Custom dropdown buttons are instantiated by some external system.
-- When calling L_UIDropDownMenu_AddButton that system sets info.customFrame to the instance of the frame it wants to place on the menu.
-- The dropdown menu creates its button for the entry as it normally would, but hides all elements.  The custom frame is then anchored
-- to that button and assumes responsibility for all relevant dropdown menu operations.
-- The hidden button will request a size that it should become from the custom frame.

L_DropDownMenuButtonMixin = {}

function L_DropDownMenuButtonMixin:OnEnter(...)
	ExecuteFrameScript(self:GetParent(), "OnEnter", ...);
end

function L_DropDownMenuButtonMixin:OnLeave(...)
	ExecuteFrameScript(self:GetParent(), "OnLeave", ...);
end

function L_DropDownMenuButtonMixin:OnMouseDown(button)
	if self:IsEnabled() then
		L_ToggleDropDownMenu(nil, nil, self:GetParent());
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	end
end

L_LargeDropDownMenuButtonMixin = CreateFromMixins(L_DropDownMenuButtonMixin);

function L_LargeDropDownMenuButtonMixin:OnMouseDown(button)
	if self:IsEnabled() then
		local parent = self:GetParent();
		L_ToggleDropDownMenu(nil, nil, parent, parent, -8, 8);
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	end
end

L_DropDownExpandArrowMixin = {};

function L_DropDownExpandArrowMixin:OnEnter()
	local level =  self:GetParent():GetParent():GetID() + 1;

	L_CloseDropDownMenus(level);

	if self:IsEnabled() then
		local listFrame = _G["L_DropDownList"..level];
		if ( not listFrame or not listFrame:IsShown() or select(2, listFrame:GetPoint()) ~= self ) then
			L_ToggleDropDownMenu(level, self:GetParent().value, nil, nil, nil, nil, self:GetParent().menuList, self);
		end
	end
end

function L_DropDownExpandArrowMixin:OnMouseDown(button)
	if self:IsEnabled() then
		L_ToggleDropDownMenu(self:GetParent():GetParent():GetID() + 1, self:GetParent().value, nil, nil, nil, nil, self:GetParent().menuList, self);
	end
end

L_UIDropDownCustomMenuEntryMixin = {};

function L_UIDropDownCustomMenuEntryMixin:GetPreferredEntryWidth()
	-- NOTE: Only width is currently supported, dropdown menus size vertically based on how many buttons are present.
	return self:GetWidth();
end

function L_UIDropDownCustomMenuEntryMixin:OnSetOwningButton()
	-- for derived objects to implement
end

function L_UIDropDownCustomMenuEntryMixin:SetOwningButton(button)
	self:SetParent(button:GetParent());
	self.owningButton = button;
	self:OnSetOwningButton();
end

function L_UIDropDownCustomMenuEntryMixin:GetOwningDropdown()
	return self.owningButton:GetParent();
end

function L_UIDropDownCustomMenuEntryMixin:SetContextData(contextData)
	self.contextData = contextData;
end

function L_UIDropDownCustomMenuEntryMixin:GetContextData()
	return self.contextData;
end

-- //////////////////////////////////////////////////////////////
-- L_UIDropDownCustomMenuEntryTemplate
function L_Create_UIDropDownCustomMenuEntry(name, parent)
	local f = _G[name] or CreateFrame("Frame", name, parent or nil)
	f:EnableMouse(true)
	f:Hide()
	
	-- I am not 100% sure if below works for replacing the mixins
	f:SetScript("GetPreferredEntryWidth", function(self)
		return self:GetWidth()
	end)
	f:SetScript("SetOwningButton", function(self, button)
		self:SetParent(button:GetParent())
		self.owningButton = button
		self:OnSetOwningButton()
	end)
	f:SetScript("GetOwningDropdown", function(self)
		return self.owningButton:GetParent()
	end)
	f:SetScript("SetContextData", function(self, contextData)
		self.contextData = contextData
	end)
	f:SetScript("GetContextData", function(self)
		return self.contextData
	end)
	
	return f
end
]]
