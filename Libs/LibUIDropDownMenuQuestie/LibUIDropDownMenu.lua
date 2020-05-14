-- $Id: LibUIDropDownMenu.lua 43 2019-09-02 14:14:50Z arith $
-- ----------------------------------------------------------------------------
-- Localized Lua globals.
-- ----------------------------------------------------------------------------
local _G = getfenv(0)
local tonumber, type, string, table = _G.tonumber, _G.type, _G.string, _G.table
local strsub, strlen, strmatch, gsub = _G.strsub, _G.strlen, _G.strmatch, _G.gsub
local max, match = _G.max, _G.match
local securecall, issecure = _G.securecall, _G.issecure
local wipe = table.wipe
-- WoW
local CreateFrame, GetCursorPosition, GetCVar, GetScreenHeight, GetScreenWidth, PlaySound = _G.CreateFrame, _G.GetCursorPosition, _G.GetCVar, _G.GetScreenHeight, _G.GetScreenWidth, _G.PlaySound

-- ----------------------------------------------------------------------------
local MAJOR_VERSION = "LibUIDropDownMenuQuestie-2.0"
local MINOR_VERSION = 90000 + tonumber(("$Rev: 43 $"):match("%d+"))

local LibStub = _G.LibStub
if not LibStub then error(MAJOR_VERSION .. " requires LibStub.") end
local lib = LibStub:NewLibrary(MAJOR_VERSION, MINOR_VERSION)
if not lib then return end

-- //////////////////////////////////////////////////////////////
LQuestie_UIDROPDOWNMENU_MAXBUTTONS = 1;
LQuestie_UIDROPDOWNMENU_MAXLEVELS = 2;
LQuestie_UIDROPDOWNMENU_BUTTON_HEIGHT = 16;
LQuestie_UIDROPDOWNMENU_BORDER_HEIGHT = 15;
-- The current open menu
LQuestie_UIDROPDOWNMENU_OPEN_MENU = nil;
-- The current menu being initialized
LQuestie_UIDROPDOWNMENU_INIT_MENU = nil;
-- Current level shown of the open menu
LQuestie_UIDROPDOWNMENU_MENU_LEVEL = 1;
-- Current value of the open menu
LQuestie_UIDROPDOWNMENU_MENU_VALUE = nil;
-- Time to wait to hide the menu
LQuestie_UIDROPDOWNMENU_SHOW_TIME = 2;
-- Default dropdown text height
LQuestie_UIDROPDOWNMENU_DEFAULT_TEXT_HEIGHT = nil;
-- List of open menus
LQuestie_OPEN_DROPDOWNMENUS = {};

local LQuestie_UIDropDownMenuDelegate = CreateFrame("FRAME");

function LQuestie_UIDropDownMenuDelegate_OnAttributeChanged (self, attribute, value)
	if ( attribute == "createframes" and value == true ) then
		LQuestie_UIDropDownMenu_CreateFrames(self:GetAttribute("createframes-level"), self:GetAttribute("createframes-index"));
	elseif ( attribute == "initmenu" ) then
		LQuestie_UIDROPDOWNMENU_INIT_MENU = value;
	elseif ( attribute == "openmenu" ) then
		LQuestie_UIDROPDOWNMENU_OPEN_MENU = value;
	end
end

LQuestie_UIDropDownMenuDelegate:SetScript("OnAttributeChanged", LQuestie_UIDropDownMenuDelegate_OnAttributeChanged);

function LQuestie_UIDropDownMenu_InitializeHelper (frame)
	-- This deals with the potentially tainted stuff!
	if ( frame ~= LQuestie_UIDROPDOWNMENU_OPEN_MENU ) then
		LQuestie_UIDROPDOWNMENU_MENU_LEVEL = 1;
	end

	-- Set the frame that's being intialized
	LQuestie_UIDropDownMenuDelegate:SetAttribute("initmenu", frame);

	-- Hide all the buttons
	local button, dropDownList;
	for i = 1, LQuestie_UIDROPDOWNMENU_MAXLEVELS, 1 do
		dropDownList = _G["LQuestie_DropDownList"..i];
		if ( i >= LQuestie_UIDROPDOWNMENU_MENU_LEVEL or frame ~= LQuestie_UIDROPDOWNMENU_OPEN_MENU ) then
			dropDownList.numButtons = 0;
			dropDownList.maxWidth = 0;
			for j=1, LQuestie_UIDROPDOWNMENU_MAXBUTTONS, 1 do
				button = _G["LQuestie_DropDownList"..i.."Button"..j];
				button:Hide();
			end
			dropDownList:Hide();
		end
	end
	frame:SetHeight(LQuestie_UIDROPDOWNMENU_BUTTON_HEIGHT * 2);
end

-- //////////////////////////////////////////////////////////////
-- LQuestie_UIDropDownMenuButtonTemplate
local function create_UIDropDownMenuButton(name, parent)
	local f = CreateFrame("Button", name, parent or nil)
    f:SetWidth(100)
    f:SetHeight(16)
    f:SetFrameLevel(f:GetParent():GetFrameLevel()+2)

	f.Highlight = f:CreateTexture(name.."Highlight", "BACKGROUND")
	f.Highlight:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
	f.Highlight:SetBlendMode("ADD")
	f.Highlight:SetAllPoints()
	f.Highlight:Hide()
	
	f.Check = f:CreateTexture(name.."Check", "ARTWORK")
	f.Check:SetTexture("Interface\\Common\\UI-DropDownRadioChecks")
	f.Check:SetSize(16, 16)
	f.Check:SetPoint("LEFT", f, 0, 0)
	f.Check:SetTexCoord(0, 0.5, 0.5, 1)

	f.UnCheck = f:CreateTexture(name.."UnCheck", "ARTWORK")
	f.UnCheck:SetTexture("Interface\\Common\\UI-DropDownRadioChecks")
	f.UnCheck:SetSize(16, 16)
	f.UnCheck:SetPoint("LEFT", f, 0, 0)
	f.UnCheck:SetTexCoord(0.5, 1, 0.5, 1)
	
	f.Icon = f:CreateTexture(name.."Icon", "ARTWORK")
	f.Icon:SetSize(16, 16)
	f.Icon:SetPoint("RIGHT", f, 0, 0)
	f.Icon:Hide()
	
	-- ColorSwatch
	local fcw = CreateFrame("Button", name.."ColorSwatch", f)
	fcw:SetSize(16, 16)
	fcw:SetPoint("RIGHT", f, -6, 0)
	fcw:Hide()
	fcw.SwatchBg = fcw:CreateTexture(name.."ColorSwatchSwatchBg", "BACKGROUND")
	fcw.SwatchBg:SetVertexColor(1, 1, 1)
	fcw.SwatchBg:SetWidth(14)
	fcw.SwatchBg:SetHeight(14)
	fcw.SwatchBg:SetPoint("CENTER", fcw, 0, 0)
	local button1NormalTexture = fcw:CreateTexture(name.."ColorSwatchNormalTexture")
	button1NormalTexture:SetTexture("Interface\\ChatFrame\\ChatFrameColorSwatch")
	button1NormalTexture:SetAllPoints()
	fcw:SetNormalTexture(button1NormalTexture)
	fcw:SetScript("OnClick", function(self, button, down)
		CloseMenus()
		LQuestie_UIDropDownMenuButton_OpenColorPicker(self:GetParent())
	end)
	fcw:SetScript("OnEnter", function(self, motion)
		LQuestie_CloseDropDownMenus(self:GetParent():GetParent():GetID() + 1)
		_G[self:GetName().."SwatchBg"]:SetVertexColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
		LQuestie_UIDropDownMenu_StopCounting(self:GetParent():GetParent())
	end)
	fcw:SetScript("OnLeave", function(self, motion)
		_G[self:GetName().."SwatchBg"]:SetVertexColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
		LQuestie_UIDropDownMenu_StartCounting(self:GetParent():GetParent())
	end)
	f.ColorSwatch = fcw
	
	-- ExpandArrow
	local fea = CreateFrame("Button", name.."ExpandArrow", f)
	fea:SetSize(16, 16)
	fea:SetPoint("RIGHT", f, 0, 0)
	fea:Hide()
	local button2NormalTexture = fea:CreateTexture(name.."ExpandArrowNormalTexture")
	button2NormalTexture:SetTexture("Interface\\ChatFrame\\ChatFrameExpandArrow")
	button2NormalTexture:SetAllPoints()
	fea:SetNormalTexture(button2NormalTexture)
	fea:SetScript("OnClick", function(self, button, down)
		LQuestie_ToggleDropDownMenu(self:GetParent():GetParent():GetID() + 1, self:GetParent().value, nil, nil, nil, nil, self:GetParent().menuList, self)
	end)
	fea:SetScript("OnEnter", function(self, motion)
		local level =  self:GetParent():GetParent():GetID() + 1
		LQuestie_CloseDropDownMenus(level)
		if self:IsEnabled() then
			local listFrame = _G["LQuestie_DropDownList"..level];
			if ( not listFrame or not listFrame:IsShown() or select(2, listFrame:GetPoint()) ~= self ) then
				LQuestie_ToggleDropDownMenu(level, self:GetParent().value, nil, nil, nil, nil, self:GetParent().menuList, self)
			end
		end
		LQuestie_UIDropDownMenu_StopCounting(self:GetParent():GetParent())
	end)
	fea:SetScript("OnLeave", function(self, motion)
		LQuestie_UIDropDownMenu_StartCounting(self:GetParent():GetParent())
	end)
	f.ExpandArrow = fea

	-- InvisibleButton
	local fib = CreateFrame("Button", name.."InvisibleButton", f)
	fib:Hide()
	fib:SetPoint("TOPLEFT", f, 0, 0)
	fib:SetPoint("BOTTOMLEFT", f, 0, 0)
	fib:SetPoint("RIGHT", fcw, "LEFT", 0, 0)
	fib:SetScript("OnEnter", function(self, motion)
		LQuestie_UIDropDownMenuButtonInvisibleButton_OnEnter(self)
	end)
	fib:SetScript("OnLeave", function(self, motion)
		LQuestie_UIDropDownMenuButtonInvisibleButton_OnLeave(self)
	end)
	f.invisibleButton = fib

	-- UIDropDownMenuButton Scripts
	f:SetScript("OnClick", function(self, button, down)
		LQuestie_UIDropDownMenuButton_OnClick(self, button, down)
	end)
	f:SetScript("OnEnter", function(self, motion)
		LQuestie_UIDropDownMenuButton_OnEnter(self)
	end)
	f:SetScript("OnLeave", function(self, motion)
		LQuestie_UIDropDownMenuButton_OnLeave(self)
	end)
	f:SetScript("OnEnable", function(self)
		self.invisibleButton:Hide()
	end)
	f:SetScript("OnDisable", function(self)
		self.invisibleButton:Show()
	end)

	local text1 = f:CreateFontString(name.."NormalText")
	f:SetFontString(text1)
	text1:SetPoint("LEFT", f, -5, 0)
	f:SetNormalFontObject("GameFontHighlightSmallLeft")
	f:SetHighlightFontObject("GameFontHighlightSmallLeft")
	f:SetDisabledFontObject("GameFontDisableSmallLeft")

	return f
end

-- //////////////////////////////////////////////////////////////
-- LQuestie_UIDropDownListTemplate
local function creatre_UIDropDownList(name, parent)
	local f = _G[name] or CreateFrame("Button", name)
	f:SetParent(parent or nil)
	f:Hide()
	f:SetFrameStrata("DIALOG")
	f:EnableMouse(true)
	
	f.Backdrop = _G[name.."Backdrop"] or CreateFrame("Frame", name.."Backdrop", f)
	f.Backdrop:SetAllPoints()
	f.Backdrop:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
		tile = true,
		tileSize = 32,
		edgeSize = 32,
		insets = { left = 11, right = 12, top = 12, bottom = 9, },
	})
	
	f.MenuBackdrop= _G[name.."MenuBackdrop"] or CreateFrame("Frame", name.."MenuBackdrop", f)
	f.MenuBackdrop:SetAllPoints()
	f.MenuBackdrop:SetBackdrop({
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true,
		tileSize = 16,
		edgeSize = 16,
		insets = { left = 5, right = 4, top = 4, bottom = 4, },
	})
	f.MenuBackdrop:SetBackdropBorderColor(TOOLTIP_DEFAULT_COLOR.r, TOOLTIP_DEFAULT_COLOR.g, TOOLTIP_DEFAULT_COLOR.b)
	f.MenuBackdrop:SetBackdropColor(TOOLTIP_DEFAULT_BACKGROUND_COLOR.r, TOOLTIP_DEFAULT_BACKGROUND_COLOR.g, TOOLTIP_DEFAULT_BACKGROUND_COLOR.b)
	
	f.Button1 = _G[name.."Button1"] or create_UIDropDownMenuButton(name.."Button1", f)
	f.Button1:SetID(1)
	
	f:SetScript("OnClick", function(self)
		self:Hide()
	end)
	f:SetScript("OnEnter", function(self, motion)
		LQuestie_UIDropDownMenu_StopCounting(self, motion)
	end)
	f:SetScript("OnLeave", function(self, motion)
		LQuestie_UIDropDownMenu_StartCounting(self, motion)
	end)
	f:SetScript("OnUpdate", function(self, elapsed)
		LQuestie_UIDropDownMenu_OnUpdate(self, elapsed)
	end)
	f:SetScript("OnShow", function(self)
		for i=1, LQuestie_UIDROPDOWNMENU_MAXBUTTONS do
			if (not self.noResize) then
				_G[self:GetName().."Button"..i]:SetWidth(self.maxWidth);
			end
		end
		if (not self.noResize) then
			self:SetWidth(self.maxWidth+25);
		end
		self.showTimer = nil;
		if ( self:GetID() > 1 ) then
			self.parent = _G["LQuestie_DropDownList"..(self:GetID() - 1)];
		end
	end)
	f:SetScript("OnHide", function(self)
		LQuestie_UIDropDownMenu_OnHide(self)
	end)
	
	return f
end

-- //////////////////////////////////////////////////////////////
-- LQuestie_UIDropDownMenuTemplate
local function create_UIDropDownMenu(name, parent)
	local f
	if type(name) == "table" then
		f = name
		name = f:GetName()
	else
		f = CreateFrame("Frame", name, parent or nil)
	end
	f:SetSize(40, 32)
	
	f.Left = f:CreateTexture(name.."Left", "ARTWORK")
	f.Left:SetTexture("Interface\\Glues\\CharacterCreate\\CharacterCreate-LabelFrame")
	f.Left:SetSize(25, 64)
	f.Left:SetPoint("TOPLEFT", f, 0, 17)
	f.Left:SetTexCoord(0, 0.1953125, 0, 1)
	
	f.Middle = f:CreateTexture(name.."Middle", "ARTWORK")
	f.Middle:SetTexture("Interface\\Glues\\CharacterCreate\\CharacterCreate-LabelFrame")
	f.Middle:SetSize(115, 64)
	f.Middle:SetPoint("LEFT", f.Left, "RIGHT")
	f.Middle:SetTexCoord(0.1953125, 0.8046875, 0, 1)
	
	f.Right = f:CreateTexture(name.."Right", "ARTWORK")
	f.Right:SetTexture("Interface\\Glues\\CharacterCreate\\CharacterCreate-LabelFrame")
	f.Right:SetSize(25, 64)
	f.Right:SetPoint("LEFT", f.Middle, "RIGHT")
	f.Right:SetTexCoord(0.8046875, 1, 0, 1)
	
	f.Text = f:CreateFontString(name.."Text", "ARTWORK", "GameFontHighlightSmall")
	f.Text:SetWordWrap(false)
	f.Text:SetJustifyH("RIGHT")
	f.Text:SetSize(0, 10)
	f.Text:SetPoint("RIGHT", f.Right, -43, 2)
	
	f.Icon = f:CreateTexture(name.."Icon", "OVERLAY")
	f.Icon:Hide()
	f.Icon:SetSize(16, 16)
	f.Icon:SetPoint("LEFT", 30, 2)
	
	f.Button = CreateFrame("Button", name.."Button", f)
	f.Button:SetMotionScriptsWhileDisabled(true)
	f.Button:SetSize(24, 24)
	f.Button:SetPoint("TOPRIGHT", f.Right, -16, -18)
	
	f.Button.NormalTexture = f.Button:CreateTexture(name.."NormalTexture")
	f.Button.NormalTexture:SetTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Up")
	f.Button.NormalTexture:SetSize(24, 24)
	f.Button.NormalTexture:SetPoint("RIGHT", f.Button, 0, 0)
	f.Button:SetNormalTexture(f.Button.NormalTexture)
	
	f.Button.PushedTexture = f.Button:CreateTexture(name.."PushedTexture")
	f.Button.PushedTexture:SetTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Down")
	f.Button.PushedTexture:SetSize(24, 24)
	f.Button.PushedTexture:SetPoint("RIGHT", f.Button, 0, 0)
	f.Button:SetPushedTexture(f.Button.PushedTexture)
	
	f.Button.DisabledTexture = f.Button:CreateTexture(name.."DisabledTexture")
	f.Button.DisabledTexture:SetTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Disabled")
	f.Button.DisabledTexture:SetSize(24, 24)
	f.Button.DisabledTexture:SetPoint("RIGHT", f.Button, 0, 0)
	f.Button:SetDisabledTexture(f.Button.DisabledTexture)
	
	f.Button.HighlightTexture = f.Button:CreateTexture(name.."HighlightTexture")
	f.Button.HighlightTexture:SetTexture("Interface\\Buttons\\UI-Common-MouseHilight")
	f.Button.HighlightTexture:SetSize(24, 24)
	f.Button.HighlightTexture:SetPoint("RIGHT", f.Button, 0, 0)
	f.Button.HighlightTexture:SetBlendMode("ADD")
	f.Button:SetHighlightTexture(f.Button.HighlightTexture)
	
	-- Button Script
	f.Button:SetScript("OnEnter", function(self, motion)
		local parent = self:GetParent()
		local myscript = parent:GetScript("OnEnter")
		if(myscript ~= nil) then
			myscript(parent)
		end
	end)
	f.Button:SetScript("OnLeave", function(self, motion)
		local parent = self:GetParent()
		local myscript = parent:GetScript("OnLeave")
		if(myscript ~= nil) then
			myscript(parent)
		end
	end)
	f.Button:SetScript("OnClick", function(self, button, down)
		LQuestie_ToggleDropDownMenu(nil, nil, self:GetParent())
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
	end)
	
	-- UIDropDownMenu Script
	f:SetScript("OnHide", function(self)
		LQuestie_CloseDropDownMenus()
	end)
	
	return f
end
-- End of frame templates
-- //////////////////////////////////////////////////////////////

-- //////////////////////////////////////////////////////////////
-- Handling two frames from LibUIDropDownMenu.xml
local LQuestie_DropDownList1, LQuestie_DropDownList2
do
	LQuestie_DropDownList1 = creatre_UIDropDownList("LQuestie_DropDownList1")
	LQuestie_DropDownList1:SetToplevel(true)
	LQuestie_DropDownList1:SetFrameStrata("FULLSCREEN_DIALOG")
	LQuestie_DropDownList1:Hide()
	LQuestie_DropDownList1:SetID(1)
	LQuestie_DropDownList1:SetSize(180, 10)
	local fontName, fontHeight, fontFlags = _G["LQuestie_DropDownList1Button1NormalText"]:GetFont()
	LQuestie_UIDROPDOWNMENU_DEFAULT_TEXT_HEIGHT = fontHeight
	
	LQuestie_DropDownList2 = creatre_UIDropDownList("LQuestie_DropDownList2")
	LQuestie_DropDownList2:SetToplevel(true)
	LQuestie_DropDownList2:SetFrameStrata("FULLSCREEN_DIALOG")
	LQuestie_DropDownList2:Hide()
	LQuestie_DropDownList2:SetID(2)
	LQuestie_DropDownList2:SetSize(180, 10)
end

-- //////////////////////////////////////////////////////////////
-- Global function to replace LQuestie_UIDropDownMenuTemplate
function LQuestie_Create_UIDropDownMenu(name, parent)
    return create_UIDropDownMenu(name, parent)
end

local function GetChild(frame, name, key)
	if (frame[key]) then
		return frame[key];
	else
		return _G[name..key];
	end
end

function LQuestie_UIDropDownMenu_Initialize(frame, initFunction, displayMode, level, menuList)
	frame.menuList = menuList;

	securecall("LQuestie_UIDropDownMenu_InitializeHelper", frame);

	-- Set the initialize function and call it.  The initFunction populates the dropdown list.
	if ( initFunction ) then
		LQuestie_UIDropDownMenu_SetInitializeFunction(frame, initFunction);
		initFunction(frame, level, frame.menuList);
	end

	--master frame
	if(level == nil) then
		level = 1;
	end

	local dropDownList = _G["LQuestie_DropDownList"..level];
	dropDownList.dropdown = frame;
	dropDownList.shouldRefresh = true;

	LQuestie_UIDropDownMenu_SetDisplayMode(frame, displayMode);
end

function LQuestie_UIDropDownMenu_SetInitializeFunction(frame, initFunction)
	frame.initialize = initFunction;
end

function LQuestie_UIDropDownMenu_SetDisplayMode(frame, displayMode)
	-- Change appearance based on the displayMode
	-- Note: this is a one time change based on previous behavior.
	if ( displayMode == "MENU" ) then
		local name = frame:GetName();
		GetChild(frame, name, "Left"):Hide();
		GetChild(frame, name, "Middle"):Hide();
		GetChild(frame, name, "Right"):Hide();
		local button = GetChild(frame, name, "Button");
		local buttonName = button:GetName();
		GetChild(button, buttonName, "NormalTexture"):SetTexture(nil);
		GetChild(button, buttonName, "DisabledTexture"):SetTexture(nil);
		GetChild(button, buttonName, "PushedTexture"):SetTexture(nil);
		GetChild(button, buttonName, "HighlightTexture"):SetTexture(nil);
		local text = GetChild(frame, name, "Text");

		button:ClearAllPoints();
		button:SetPoint("LEFT", text, "LEFT", -9, 0);
		button:SetPoint("RIGHT", text, "RIGHT", 6, 0);
		frame.displayMode = "MENU";
	end
end

function LQuestie_UIDropDownMenu_RefreshDropDownSize(self)
	self.maxWidth = LQuestie_UIDropDownMenu_GetMaxButtonWidth(self);
	self:SetWidth(self.maxWidth + 25);

	for i=1, LQuestie_UIDROPDOWNMENU_MAXBUTTONS, 1 do
		local icon = _G[self:GetName().."Button"..i.."Icon"];

		if ( icon.tFitDropDownSizeX ) then
			icon:SetWidth(self.maxWidth - 5);
		end
	end
end

-- If dropdown is visible then see if its timer has expired, if so hide the frame
function LQuestie_UIDropDownMenu_OnUpdate(self, elapsed)
	if ( self.shouldRefresh ) then
		LQuestie_UIDropDownMenu_RefreshDropDownSize(self);
		self.shouldRefresh = false;
	end

	if ( not self.showTimer or not self.isCounting ) then
		return;
	elseif ( self.showTimer < 0 ) then
		self:Hide();
		self.showTimer = nil;
		self.isCounting = nil;
	else
		self.showTimer = self.showTimer - elapsed;
	end
end

-- Start the countdown on a frame
function LQuestie_UIDropDownMenu_StartCounting(frame)
	if ( frame.parent ) then
		LQuestie_UIDropDownMenu_StartCounting(frame.parent);
	else
		frame.showTimer = LQuestie_UIDROPDOWNMENU_SHOW_TIME;
		frame.isCounting = 1;
	end
end

-- Stop the countdown on a frame
function LQuestie_UIDropDownMenu_StopCounting(frame)
	if ( frame.parent ) then
		LQuestie_UIDropDownMenu_StopCounting(frame.parent);
	else
		frame.isCounting = nil;
	end
end

function LQuestie_UIDropDownMenuButtonInvisibleButton_OnEnter(self)
	LQuestie_UIDropDownMenu_StopCounting(self:GetParent():GetParent());
	LQuestie_CloseDropDownMenus(self:GetParent():GetParent():GetID() + 1);
	local parent = self:GetParent();
	if ( parent.tooltipTitle and parent.tooltipWhileDisabled) then
		if ( parent.tooltipOnButton ) then
			GameTooltip:SetOwner(parent, "ANCHOR_RIGHT");
			GameTooltip_SetTitle(GameTooltip, parent.tooltipTitle);
			if parent.tooltipInstruction then
				GameTooltip_AddInstructionLine(GameTooltip, parent.tooltipInstruction);
			end
			if parent.tooltipText then
				GameTooltip_AddNormalLine(GameTooltip, parent.tooltipText, true);
			end
			if parent.tooltipWarning then
				GameTooltip_AddColoredLine(GameTooltip, parent.tooltipWarning, RED_FONT_COLOR, true);
			end
			GameTooltip:Show();
		else
			GameTooltip_AddNewbieTip(parent, parent.tooltipTitle, 1.0, 1.0, 1.0, parent.tooltipText, 1);
		end
	end
end

function LQuestie_UIDropDownMenuButtonInvisibleButton_OnLeave(self)
	LQuestie_UIDropDownMenu_StartCounting(self:GetParent():GetParent());
	GameTooltip:Hide();
end

function LQuestie_UIDropDownMenuButton_OnEnter(self)
	if ( self.hasArrow and self.ExpandArrow ) then
		self.ExpandArrow:GetScript("OnEnter")(self.ExpandArrow)
	else
		LQuestie_CloseDropDownMenus(self:GetParent():GetID() + 1);
	end
	self.Highlight:Show();
	LQuestie_UIDropDownMenu_StopCounting(self:GetParent());
	if ( self.tooltipTitle and not self.noTooltipWhileEnabled ) then
		if ( self.tooltipOnButton ) then
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
			GameTooltip_SetTitle(GameTooltip, self.tooltipTitle);
			if self.tooltipText then
				GameTooltip_AddNormalLine(GameTooltip, self.tooltipText, true);
			end
			GameTooltip:Show();
		else
			GameTooltip_AddNewbieTip(self, self.tooltipTitle, 1.0, 1.0, 1.0, self.tooltipText, 1);
		end
	end
				
	if ( self.mouseOverIcon ~= nil ) then
		self.Icon:SetTexture(self.mouseOverIcon);
		self.Icon:Show();
	end
end

function LQuestie_UIDropDownMenuButton_OnLeave(self)
	self.Highlight:Hide();
	LQuestie_UIDropDownMenu_StartCounting(self:GetParent());
	GameTooltip:Hide();
				
	if ( self.mouseOverIcon ~= nil ) then
		if ( self.icon ~= nil ) then
			self.Icon:SetTexture(self.icon);
		else
			self.Icon:Hide();
		end
	end
end

--[[
List of button attributes
======================================================
info.text = [STRING]  --  The text of the button
info.value = [ANYTHING]  --  The value that L_UIDROPDOWNMENU_MENU_VALUE is set to when the button is clicked
info.func = [function()]  --  The function that is called when you click the button
info.checked = [nil, true, function]  --  Check the button if true or function returns true
info.isNotRadio = [nil, true]  --  Check the button uses radial image if false check box image if true
info.isTitle = [nil, true]  --  If it's a title the button is disabled and the font color is set to yellow
info.disabled = [nil, true]  --  Disable the button and show an invisible button that still traps the mouseover event so menu doesn't time out
info.tooltipWhileDisabled = [nil, 1] -- Show the tooltip, even when the button is disabled.
info.hasArrow = [nil, true]  --  Show the expand arrow for multilevel menus
info.hasColorSwatch = [nil, true]  --  Show color swatch or not, for color selection
info.r = [1 - 255]  --  Red color value of the color swatch
info.g = [1 - 255]  --  Green color value of the color swatch
info.b = [1 - 255]  --  Blue color value of the color swatch
info.colorCode = [STRING] -- "|cAARRGGBB" embedded hex value of the button text color. Only used when button is enabled
info.swatchFunc = [function()]  --  Function called by the color picker on color change
info.hasOpacity = [nil, 1]  --  Show the opacity slider on the colorpicker frame
info.opacity = [0.0 - 1.0]  --  Percentatge of the opacity, 1.0 is fully shown, 0 is transparent
info.opacityFunc = [function()]  --  Function called by the opacity slider when you change its value
info.cancelFunc = [function(previousValues)] -- Function called by the colorpicker when you click the cancel button (it takes the previous values as its argument)
info.notClickable = [nil, 1]  --  Disable the button and color the font white
info.notCheckable = [nil, 1]  --  Shrink the size of the buttons and don't display a check box
info.owner = [Frame]  --  Dropdown frame that "owns" the current dropdownlist
info.keepShownOnClick = [nil, 1]  --  Don't hide the dropdownlist after a button is clicked
info.tooltipTitle = [nil, STRING] -- Title of the tooltip shown on mouseover
info.tooltipText = [nil, STRING] -- Text of the tooltip shown on mouseover
info.tooltipOnButton = [nil, 1] -- Show the tooltip attached to the button instead of as a Newbie tooltip.
info.justifyH = [nil, "CENTER"] -- Justify button text
info.arg1 = [ANYTHING] -- This is the first argument used by info.func
info.arg2 = [ANYTHING] -- This is the second argument used by info.func
info.fontObject = [FONT] -- font object replacement for Normal and Highlight
info.menuTable = [TABLE] -- This contains an array of info tables to be displayed as a child menu
info.noClickSound = [nil, 1]  --  Set to 1 to suppress the sound when clicking the button. The sound only plays if .func is set.
info.padding = [nil, NUMBER] -- Number of pixels to pad the text on the right side
info.leftPadding = [nil, NUMBER] -- Number of pixels to pad the button on the left side
info.minWidth = [nil, NUMBER] -- Minimum width for this line
info.customFrame = frame -- Allows this button to be a completely custom frame, should inherit from L_UIDropDownCustomMenuEntryTemplate and override appropriate methods.
info.icon = [TEXTURE] -- An icon for the button.
info.mouseOverIcon = [TEXTURE] -- An override icon when a button is moused over.
]]

function LQuestie_UIDropDownMenu_CreateInfo()
	return {};
end

function LQuestie_UIDropDownMenu_CreateFrames(level, index)
	while ( level > LQuestie_UIDROPDOWNMENU_MAXLEVELS ) do
		LQuestie_UIDROPDOWNMENU_MAXLEVELS = LQuestie_UIDROPDOWNMENU_MAXLEVELS + 1;
		--local newList = CreateFrame("Button", "LQuestie_DropDownList"..LQuestie_UIDROPDOWNMENU_MAXLEVELS, nil, "LQuestie_UIDropDownListTemplate");
		local newList = creatre_UIDropDownList("LQuestie_DropDownList"..LQuestie_UIDROPDOWNMENU_MAXLEVELS)
		newList:SetFrameStrata("FULLSCREEN_DIALOG");
		newList:SetToplevel(true);
		newList:Hide();
		newList:SetID(LQuestie_UIDROPDOWNMENU_MAXLEVELS);
		newList:SetWidth(180)
		newList:SetHeight(10)
		for i=1, LQuestie_UIDROPDOWNMENU_MAXBUTTONS do
			--local newButton = CreateFrame("Button", "LQuestie_DropDownList"..LQuestie_UIDROPDOWNMENU_MAXLEVELS.."Button"..i, newList, "LQuestie_UIDropDownMenuButtonTemplate");
			local newButton = create_UIDropDownMenuButton("LQuestie_DropDownList"..LQuestie_UIDROPDOWNMENU_MAXLEVELS.."Button"..i, newList)
			newButton:SetID(i);
		end
	end

	while ( index > LQuestie_UIDROPDOWNMENU_MAXBUTTONS ) do
		LQuestie_UIDROPDOWNMENU_MAXBUTTONS = LQuestie_UIDROPDOWNMENU_MAXBUTTONS + 1;
		for i=1, LQuestie_UIDROPDOWNMENU_MAXLEVELS do
			--local newButton = CreateFrame("Button", "LQuestie_DropDownList"..i.."Button"..LQuestie_UIDROPDOWNMENU_MAXBUTTONS, _G["LQuestie_DropDownList"..i], "LQuestie_UIDropDownMenuButtonTemplate");
			local newButton = create_UIDropDownMenuButton("LQuestie_DropDownList"..i.."Button"..LQuestie_UIDROPDOWNMENU_MAXBUTTONS, _G["LQuestie_DropDownList"..i])
			newButton:SetID(LQuestie_UIDROPDOWNMENU_MAXBUTTONS);
		end
	end
end

function LQuestie_UIDropDownMenu_AddSeparator(level)
	local separatorInfo = {
		hasArrow = false;
		dist = 0;
		isTitle = true;
		isUninteractable = true;
		notCheckable = true;
		iconOnly = true;
		icon = "Interface\\Common\\UI-TooltipDivider-Transparent";
		tCoordLeft = 0;
		tCoordRight = 1;
		tCoordTop = 0;
		tCoordBottom = 1;
		tSizeX = 0;
		tSizeY = 8;
		tFitDropDownSizeX = true;
		iconInfo = {
			tCoordLeft = 0,
			tCoordRight = 1,
			tCoordTop = 0,
			tCoordBottom = 1,
			tSizeX = 0,
			tSizeY = 8,
			tFitDropDownSizeX = true
		},
	};

	LQuestie_UIDropDownMenu_AddButton(separatorInfo, level);
end

function LQuestie_UIDropDownMenu_AddButton(info, level)
	--[[
	Might to uncomment this if there are performance issues
	if ( not LQuestie_UIDROPDOWNMENU_OPEN_MENU ) then
		return;
	end
	]]
	if ( not level ) then
		level = 1;
	end

	local listFrame = _G["LQuestie_DropDownList"..level];
	local index = listFrame and (listFrame.numButtons + 1) or 1;
	local width;

	LQuestie_UIDropDownMenuDelegate:SetAttribute("createframes-level", level);
	LQuestie_UIDropDownMenuDelegate:SetAttribute("createframes-index", index);
	LQuestie_UIDropDownMenuDelegate:SetAttribute("createframes", true);

	listFrame = listFrame or _G["LQuestie_DropDownList"..level];
	local listFrameName = listFrame:GetName();

	-- Set the number of buttons in the listframe
	listFrame.numButtons = index;

	local button = _G[listFrameName.."Button"..index];
	local normalText = _G[button:GetName().."NormalText"];
	local icon = _G[button:GetName().."Icon"];
	-- This button is used to capture the mouse OnEnter/OnLeave events if the dropdown button is disabled, since a disabled button doesn't receive any events
	-- This is used specifically for drop down menu time outs
	local invisibleButton = _G[button:GetName().."InvisibleButton"];

	-- Default settings
	button:SetDisabledFontObject(GameFontDisableSmallLeft);
	invisibleButton:Hide();
	button:Enable();

	-- If not clickable then disable the button and set it white
	if ( info.notClickable ) then
		info.disabled = true;
		button:SetDisabledFontObject(GameFontHighlightSmallLeft);
	end

	-- Set the text color and disable it if its a title
	if ( info.isTitle ) then
		info.disabled = true;
		button:SetDisabledFontObject(GameFontNormalSmallLeft);
	end

	-- Disable the button if disabled and turn off the color code
	if ( info.disabled ) then
		button:Disable();
		invisibleButton:Show();
		info.colorCode = nil;
	end

	-- If there is a color for a disabled line, set it
	if( info.disablecolor ) then
		info.colorCode = info.disablecolor;
	end

	-- Configure button
	if ( info.text ) then
		-- look for inline color code this is only if the button is enabled
		if ( info.colorCode ) then
			button:SetText(info.colorCode..info.text.."|r");
		else
			button:SetText(info.text);
		end

		-- Set icon
		if ( info.icon or info.mouseOverIcon ) then
			icon:SetSize(16,16);
			icon:SetTexture(info.icon);
			icon:ClearAllPoints();
			icon:SetPoint("RIGHT");

			if ( info.tCoordLeft ) then
				icon:SetTexCoord(info.tCoordLeft, info.tCoordRight, info.tCoordTop, info.tCoordBottom);
			else
				icon:SetTexCoord(0, 1, 0, 1);
			end
			icon:Show();
		else
			icon:Hide();
		end

		-- Check to see if there is a replacement font
		if ( info.fontObject ) then
			button:SetNormalFontObject(info.fontObject);
			button:SetHighlightFontObject(info.fontObject);
		else
			button:SetNormalFontObject(GameFontHighlightSmallLeft);
			button:SetHighlightFontObject(GameFontHighlightSmallLeft);
		end
	else
		button:SetText("");
		icon:Hide();
	end

	button.iconOnly = nil;
	button.icon = nil;
	button.iconInfo = nil;

	if (info.iconInfo) then
		icon.tFitDropDownSizeX = info.iconInfo.tFitDropDownSizeX;
	else
		icon.tFitDropDownSizeX = nil;
	end
	if (info.iconOnly and info.icon) then
		button.iconOnly = true;
		button.icon = info.icon;
		button.iconInfo = info.iconInfo;

		LQuestie_UIDropDownMenu_SetIconImage(icon, info.icon, info.iconInfo);
		icon:ClearAllPoints();
		icon:SetPoint("LEFT");
	end

	-- Pass through attributes
	button.func = info.func;
	button.owner = info.owner;
	button.hasOpacity = info.hasOpacity;
	button.opacity = info.opacity;
	button.opacityFunc = info.opacityFunc;
	button.cancelFunc = info.cancelFunc;
	button.swatchFunc = info.swatchFunc;
	button.keepShownOnClick = info.keepShownOnClick;
	button.tooltipTitle = info.tooltipTitle;
	button.tooltipText = info.tooltipText;
	button.tooltipInstruction = info.tooltipInstruction;
	button.tooltipWarning = info.tooltipWarning;
	button.arg1 = info.arg1;
	button.arg2 = info.arg2;
	button.hasArrow = info.hasArrow;
	button.hasColorSwatch = info.hasColorSwatch;
	button.notCheckable = info.notCheckable;
	button.menuList = info.menuList;
	button.tooltipWhileDisabled = info.tooltipWhileDisabled;
	button.noTooltipWhileEnabled = info.noTooltipWhileEnabled;
	button.tooltipOnButton = info.tooltipOnButton;
	button.noClickSound = info.noClickSound;
	button.padding = info.padding;
	button.icon = info.icon;
	button.mouseOverIcon = info.mouseOverIcon;

	if ( info.value ) then
		button.value = info.value;
	elseif ( info.text ) then
		button.value = info.text;
	else
		button.value = nil;
	end

	local expandArrow = _G[listFrameName.."Button"..index.."ExpandArrow"];
	expandArrow:SetShown(info.hasArrow);
	expandArrow:SetEnabled(not info.disabled);

	-- If not checkable move everything over to the left to fill in the gap where the check would be
	local xPos = 5;
	local yPos = -((button:GetID() - 1) * LQuestie_UIDROPDOWNMENU_BUTTON_HEIGHT) - LQuestie_UIDROPDOWNMENU_BORDER_HEIGHT;
	local displayInfo = normalText;
	if (info.iconOnly) then
		displayInfo = icon;
	end

	displayInfo:ClearAllPoints();
	if ( info.notCheckable ) then
		if ( info.justifyH and info.justifyH == "CENTER" ) then
			displayInfo:SetPoint("CENTER", button, "CENTER", -7, 0);
		else
			displayInfo:SetPoint("LEFT", button, "LEFT", 0, 0);
		end
		xPos = xPos + 10;

	else
		xPos = xPos + 12;
		displayInfo:SetPoint("LEFT", button, "LEFT", 20, 0);
	end

	-- Adjust offset if displayMode is menu
	local frame = LQuestie_UIDROPDOWNMENU_OPEN_MENU;
	if ( frame and frame.displayMode == "MENU" ) then
		if ( not info.notCheckable ) then
			xPos = xPos - 6;
		end
	end

	-- If no open frame then set the frame to the currently initialized frame
	frame = frame or LQuestie_UIDROPDOWNMENU_INIT_MENU;

	if ( info.leftPadding ) then
		xPos = xPos + info.leftPadding;
	end
	button:SetPoint("TOPLEFT", button:GetParent(), "TOPLEFT", xPos, yPos);

	-- See if button is selected by id or name
	if ( frame ) then
		if ( LQuestie_UIDropDownMenu_GetSelectedName(frame) ) then
			if ( button:GetText() == LQuestie_UIDropDownMenu_GetSelectedName(frame) ) then
				info.checked = 1;
			end
		elseif ( LQuestie_UIDropDownMenu_GetSelectedID(frame) ) then
			if ( button:GetID() == LQuestie_UIDropDownMenu_GetSelectedID(frame) ) then
				info.checked = 1;
			end
		elseif ( LQuestie_UIDropDownMenu_GetSelectedValue(frame) ) then
			if ( button.value == LQuestie_UIDropDownMenu_GetSelectedValue(frame) ) then
				info.checked = 1;
			end
		end
	end

	if not info.notCheckable then 
		local check = _G[listFrameName.."Button"..index.."Check"];
		local uncheck = _G[listFrameName.."Button"..index.."UnCheck"];
		if ( info.disabled ) then
			check:SetDesaturated(true);
			check:SetAlpha(0.5);
			uncheck:SetDesaturated(true);
			uncheck:SetAlpha(0.5);
		else
			check:SetDesaturated(false);
			check:SetAlpha(1);
			uncheck:SetDesaturated(false);
			uncheck:SetAlpha(1);
		end
		
		if info.customCheckIconAtlas or info.customCheckIconTexture then
			check:SetTexCoord(0, 1, 0, 1);
			uncheck:SetTexCoord(0, 1, 0, 1);
			
			if info.customCheckIconAtlas then
				check:SetAtlas(info.customCheckIconAtlas);
				uncheck:SetAtlas(info.customUncheckIconAtlas or info.customCheckIconAtlas);
			else
				check:SetTexture(info.customCheckIconTexture);
				uncheck:SetTexture(info.customUncheckIconTexture or info.customCheckIconTexture);
			end
		elseif info.isNotRadio then
			check:SetTexCoord(0.0, 0.5, 0.0, 0.5);
			check:SetTexture("Interface\\Common\\UI-DropDownRadioChecks");
			uncheck:SetTexCoord(0.5, 1.0, 0.0, 0.5);
			uncheck:SetTexture("Interface\\Common\\UI-DropDownRadioChecks");
		else
			check:SetTexCoord(0.0, 0.5, 0.5, 1.0);
			check:SetTexture("Interface\\Common\\UI-DropDownRadioChecks");
			uncheck:SetTexCoord(0.5, 1.0, 0.5, 1.0);
			uncheck:SetTexture("Interface\\Common\\UI-DropDownRadioChecks");
		end

		-- Checked can be a function now
		local checked = info.checked;
		if ( type(checked) == "function" ) then
			checked = checked(button);
		end

		-- Show the check if checked
		if ( checked ) then
			button:LockHighlight();
			check:Show();
			uncheck:Hide();
		else
			button:UnlockHighlight();
			check:Hide();
			uncheck:Show();
		end
	else
		_G[listFrameName.."Button"..index.."Check"]:Hide();
		_G[listFrameName.."Button"..index.."UnCheck"]:Hide();
	end
	button.checked = info.checked;

	-- If has a colorswatch, show it and vertex color it
	local colorSwatch = _G[listFrameName.."Button"..index.."ColorSwatch"];
	if ( info.hasColorSwatch ) then
		_G["LQuestie_DropDownList"..level.."Button"..index.."ColorSwatch".."NormalTexture"]:SetVertexColor(info.r, info.g, info.b);
		button.r = info.r;
		button.g = info.g;
		button.b = info.b;
		colorSwatch:Show();
	else
		colorSwatch:Hide();
	end

	LQuestie_UIDropDownMenu_CheckAddCustomFrame(listFrame, button, info);

	button:SetShown(button.customFrame == nil);

	button.minWidth = info.minWidth;

	width = max(LQuestie_UIDropDownMenu_GetButtonWidth(button), info.minWidth or 0);
	--Set maximum button width
	if ( width > listFrame.maxWidth ) then
		listFrame.maxWidth = width;
	end

	-- Set the height of the listframe
	listFrame:SetHeight((index * LQuestie_UIDROPDOWNMENU_BUTTON_HEIGHT) + (LQuestie_UIDROPDOWNMENU_BORDER_HEIGHT * 2));
end

function LQuestie_UIDropDownMenu_CheckAddCustomFrame(self, button, info)
	local customFrame = info.customFrame;
	button.customFrame = customFrame;
	if customFrame then
		customFrame:SetOwningButton(button);
		customFrame:ClearAllPoints();
		customFrame:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0);
		customFrame:Show();

		LQuestie_UIDropDownMenu_RegisterCustomFrame(self, customFrame);
	end
end

function LQuestie_UIDropDownMenu_RegisterCustomFrame(self, customFrame)
	self.customFrames = self.customFrames or {}
	table.insert(self.customFrames, customFrame);
end

function LQuestie_UIDropDownMenu_GetMaxButtonWidth(self)
	local maxWidth = 0;
	for i=1, self.numButtons do
		local button = _G[self:GetName().."Button"..i];
		local width = LQuestie_UIDropDownMenu_GetButtonWidth(button);
		if ( width > maxWidth ) then
			maxWidth = width;
		end
	end
	return maxWidth;
end

function LQuestie_UIDropDownMenu_GetButtonWidth(button)
	local minWidth = button.minWidth or 0;
	if button.customFrame and button.customFrame:IsShown() then
		return math.max(minWidth, button.customFrame:GetPreferredEntryWidth());
	end

	if not button:IsShown() then
		return 0;
	end

	local width;
	local buttonName = button:GetName();
	local icon = _G[buttonName.."Icon"];
	local normalText = _G[buttonName.."NormalText"];

	if ( button.iconOnly and icon ) then
		width = icon:GetWidth();
	elseif ( normalText and normalText:GetText() ) then
		width = normalText:GetWidth() + 40;

		if ( button.icon ) then
			-- Add padding for the icon
			width = width + 10;
		end
	else
		return minWidth;
	end

	-- Add padding if has and expand arrow or color swatch
	if ( button.hasArrow or button.hasColorSwatch ) then
		width = width + 10;
	end
	if ( button.notCheckable ) then
		width = width - 30;
	end
	if ( button.padding ) then
		width = width + button.padding;
	end

	return math.max(minWidth, width);
end

function LQuestie_UIDropDownMenu_Refresh(frame, useValue, dropdownLevel)
	local maxWidth = 0;
	local somethingChecked = nil; 
	if ( not dropdownLevel ) then
		dropdownLevel = LQuestie_UIDROPDOWNMENU_MENU_LEVEL;
	end

	local listFrame = _G["LQuestie_DropDownList"..dropdownLevel];
	listFrame.numButtons = listFrame.numButtons or 0;
	-- Just redraws the existing menu
	for i=1, LQuestie_UIDROPDOWNMENU_MAXBUTTONS do
		local button = _G["LQuestie_DropDownList"..dropdownLevel.."Button"..i];
		local checked = nil;

		if(i <= listFrame.numButtons) then
			-- See if checked or not
			if ( LQuestie_UIDropDownMenu_GetSelectedName(frame) ) then
				if ( button:GetText() == LQuestie_UIDropDownMenu_GetSelectedName(frame) ) then
					checked = 1;
				end
			elseif ( LQuestie_UIDropDownMenu_GetSelectedID(frame) ) then
				if ( button:GetID() == LQuestie_UIDropDownMenu_GetSelectedID(frame) ) then
					checked = 1;
				end
			elseif ( LQuestie_UIDropDownMenu_GetSelectedValue(frame) ) then
				if ( button.value == LQuestie_UIDropDownMenu_GetSelectedValue(frame) ) then
					checked = 1;
				end
			end
		end
		if (button.checked and type(button.checked) == "function") then
			checked = button.checked(button);
		end

		if not button.notCheckable and button:IsShown() then
			-- If checked show check image
			local checkImage = _G["LQuestie_DropDownList"..dropdownLevel.."Button"..i.."Check"];
			local uncheckImage = _G["LQuestie_DropDownList"..dropdownLevel.."Button"..i.."UnCheck"];
			if ( checked ) then
				somethingChecked = true;
				local icon = GetChild(frame, frame:GetName(), "Icon");
				if (button.iconOnly and icon and button.icon) then
					LQuestie_UIDropDownMenu_SetIconImage(icon, button.icon, button.iconInfo);
				elseif ( useValue ) then
					LQuestie_UIDropDownMenu_SetText(frame, button.value);
					icon:Hide();
				else
					LQuestie_UIDropDownMenu_SetText(frame, button:GetText());
					icon:Hide();
				end
				button:LockHighlight();
				checkImage:Show();
				uncheckImage:Hide();
			else
				button:UnlockHighlight();
				checkImage:Hide();
				uncheckImage:Show();
			end
		end

		if ( button:IsShown() ) then
			local width = LQuestie_UIDropDownMenu_GetButtonWidth(button);
			if ( width > maxWidth ) then
				maxWidth = width;
			end
		end
	end
	if(somethingChecked == nil) then
		LQuestie_UIDropDownMenu_SetText(frame, VIDEO_QUALITY_LABEL6);
	end
	if (not frame.noResize) then
		for i=1, LQuestie_UIDROPDOWNMENU_MAXBUTTONS do
			local button = _G["LQuestie_DropDownList"..dropdownLevel.."Button"..i];
			button:SetWidth(maxWidth);
		end
		LQuestie_UIDropDownMenu_RefreshDropDownSize(_G["LQuestie_DropDownList"..dropdownLevel]);
	end
end

function LQuestie_UIDropDownMenu_RefreshAll(frame, useValue)
	for dropdownLevel = LQuestie_UIDROPDOWNMENU_MENU_LEVEL, 2, -1 do
		local listFrame = _G["LQuestie_DropDownList"..dropdownLevel];
		if ( listFrame:IsShown() ) then
			LQuestie_UIDropDownMenu_Refresh(frame, nil, dropdownLevel);
		end
	end
	-- useValue is the text on the dropdown, only needs to be set once
	LQuestie_UIDropDownMenu_Refresh(frame, useValue, 1);
end

function LQuestie_UIDropDownMenu_SetIconImage(icon, texture, info)
	icon:SetTexture(texture);
	if ( info.tCoordLeft ) then
		icon:SetTexCoord(info.tCoordLeft, info.tCoordRight, info.tCoordTop, info.tCoordBottom);
	else
		icon:SetTexCoord(0, 1, 0, 1);
	end
	if ( info.tSizeX ) then
		icon:SetWidth(info.tSizeX);
	else
		icon:SetWidth(16);
	end
	if ( info.tSizeY ) then
		icon:SetHeight(info.tSizeY);
	else
		icon:SetHeight(16);
	end
	icon:Show();
end

function LQuestie_UIDropDownMenu_SetSelectedName(frame, name, useValue)
	frame.selectedName = name;
	frame.selectedID = nil;
	frame.selectedValue = nil;
	LQuestie_UIDropDownMenu_Refresh(frame, useValue);
end

function LQuestie_UIDropDownMenu_SetSelectedValue(frame, value, useValue)
	-- useValue will set the value as the text, not the name
	frame.selectedName = nil;
	frame.selectedID = nil;
	frame.selectedValue = value;
	LQuestie_UIDropDownMenu_Refresh(frame, useValue);
end

function LQuestie_UIDropDownMenu_SetSelectedID(frame, id, useValue)
	frame.selectedID = id;
	frame.selectedName = nil;
	frame.selectedValue = nil;
	LQuestie_UIDropDownMenu_Refresh(frame, useValue);
end

function LQuestie_UIDropDownMenu_GetSelectedName(frame)
	return frame.selectedName;
end

function LQuestie_UIDropDownMenu_GetSelectedID(frame)
	if ( frame.selectedID ) then
		return frame.selectedID;
	else
		-- If no explicit selectedID then try to send the id of a selected value or name
		local listFrame = _G["LQuestie_DropDownList"..LQuestie_UIDROPDOWNMENU_MENU_LEVEL];
		for i=1, listFrame.numButtons do
			local button = _G["LQuestie_DropDownList"..LQuestie_UIDROPDOWNMENU_MENU_LEVEL.."Button"..i];
			-- See if checked or not
			if ( LQuestie_UIDropDownMenu_GetSelectedName(frame) ) then
				if ( button:GetText() == LQuestie_UIDropDownMenu_GetSelectedName(frame) ) then
					return i;
				end
			elseif ( LQuestie_UIDropDownMenu_GetSelectedValue(frame) ) then
				if ( button.value == LQuestie_UIDropDownMenu_GetSelectedValue(frame) ) then
					return i;
				end
			end
		end
	end
end

function LQuestie_UIDropDownMenu_GetSelectedValue(frame)
	return frame.selectedValue;
end

function LQuestie_UIDropDownMenuButton_OnClick(self)
	local checked = self.checked;
	if ( type (checked) == "function" ) then
		checked = checked(self);
	end


	if ( self.keepShownOnClick ) then
		if not self.notCheckable then
			if ( checked ) then
				_G[self:GetName().."Check"]:Hide();
				_G[self:GetName().."UnCheck"]:Show();
				checked = false;
			else
				_G[self:GetName().."Check"]:Show();
				_G[self:GetName().."UnCheck"]:Hide();
				checked = true;
			end
		end
	else
		self:GetParent():Hide();
	end

	if ( type (self.checked) ~= "function" ) then
		self.checked = checked;
	end

	-- saving this here because func might use a dropdown, changing this self's attributes
	local playSound = true;
	if ( self.noClickSound ) then
		playSound = false;
	end

	local func = self.func;
	if ( func ) then
		func(self, self.arg1, self.arg2, checked);
	else
		return;
	end

	if ( playSound ) then
		PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON);
	end
end

function LQuestie_HideDropDownMenu(level)
	local listFrame = _G["LQuestie_DropDownList"..level];
	listFrame:Hide();
end

function LQuestie_ToggleDropDownMenu(level, value, dropDownFrame, anchorName, xOffset, yOffset, menuList, button, autoHideDelay)
	if ( not level ) then
		level = 1;
	end
	LQuestie_UIDropDownMenuDelegate:SetAttribute("createframes-level", level);
	LQuestie_UIDropDownMenuDelegate:SetAttribute("createframes-index", 0);
	LQuestie_UIDropDownMenuDelegate:SetAttribute("createframes", true);
	LQuestie_UIDROPDOWNMENU_MENU_LEVEL = level;
	LQuestie_UIDROPDOWNMENU_MENU_VALUE = value;
	local listFrameName = "LQuestie_DropDownList"..level;
	local listFrame = _G[listFrameName];
	local tempFrame;
	local point, relativePoint, relativeTo;
	if ( not dropDownFrame ) then
		tempFrame = button:GetParent();
	else
		tempFrame = dropDownFrame;
	end
	if ( listFrame:IsShown() and (LQuestie_UIDROPDOWNMENU_OPEN_MENU == tempFrame) ) then
		listFrame:Hide();
	else
		-- Set the dropdownframe scale
		local uiScale;
		local uiParentScale = UIParent:GetScale();
		if ( GetCVar("useUIScale") == "1" ) then
			uiScale = tonumber(GetCVar("uiscale"));
			if ( uiParentScale < uiScale ) then
				uiScale = uiParentScale;
			end
		else
			uiScale = uiParentScale;
		end
		listFrame:SetScale(uiScale);

		-- Hide the listframe anyways since it is redrawn OnShow()
		listFrame:Hide();

		-- Frame to anchor the dropdown menu to
		local anchorFrame;

		-- Display stuff
		-- Level specific stuff
		if ( level == 1 ) then
			LQuestie_UIDropDownMenuDelegate:SetAttribute("openmenu", dropDownFrame);
			listFrame:ClearAllPoints();
			-- If there's no specified anchorName then use left side of the dropdown menu
			if ( not anchorName ) then
				-- See if the anchor was set manually using setanchor
				if ( dropDownFrame.xOffset ) then
					xOffset = dropDownFrame.xOffset;
				end
				if ( dropDownFrame.yOffset ) then
					yOffset = dropDownFrame.yOffset;
				end
				if ( dropDownFrame.point ) then
					point = dropDownFrame.point;
				end
				if ( dropDownFrame.relativeTo ) then
					relativeTo = dropDownFrame.relativeTo;
				else
					relativeTo = GetChild(LQuestie_UIDROPDOWNMENU_OPEN_MENU, LQuestie_UIDROPDOWNMENU_OPEN_MENU:GetName(), "Left");
				end
				if ( dropDownFrame.relativePoint ) then
					relativePoint = dropDownFrame.relativePoint;
				end
			elseif ( anchorName == "cursor" ) then
				relativeTo = nil;
				local cursorX, cursorY = GetCursorPosition();
				cursorX = cursorX/uiScale;
				cursorY =  cursorY/uiScale;

				if ( not xOffset ) then
					xOffset = 0;
				end
				if ( not yOffset ) then
					yOffset = 0;
				end
				xOffset = cursorX + xOffset;
				yOffset = cursorY + yOffset;
			else
				-- See if the anchor was set manually using setanchor
				if ( dropDownFrame.xOffset ) then
					xOffset = dropDownFrame.xOffset;
				end
				if ( dropDownFrame.yOffset ) then
					yOffset = dropDownFrame.yOffset;
				end
				if ( dropDownFrame.point ) then
					point = dropDownFrame.point;
				end
				if ( dropDownFrame.relativeTo ) then
					relativeTo = dropDownFrame.relativeTo;
				else
					relativeTo = anchorName;
				end
				if ( dropDownFrame.relativePoint ) then
					relativePoint = dropDownFrame.relativePoint;
				end
			end
			if ( not xOffset or not yOffset ) then
				xOffset = 8;
				yOffset = 22;
			end
			if ( not point ) then
				point = "TOPLEFT";
			end
			if ( not relativePoint ) then
				relativePoint = "BOTTOMLEFT";
			end
			listFrame:SetPoint(point, relativeTo, relativePoint, xOffset, yOffset);
		else
			if ( not dropDownFrame ) then
				dropDownFrame = LQuestie_UIDROPDOWNMENU_OPEN_MENU;
			end
			listFrame:ClearAllPoints();
			-- If this is a dropdown button, not the arrow anchor it to itself
			if ( strsub(button:GetParent():GetName(), 0,14) == "LQuestie_DropDownList" and strlen(button:GetParent():GetName()) == 15 ) then
				anchorFrame = button;
			else
				anchorFrame = button:GetParent();
			end
			point = "TOPLEFT";
			relativePoint = "TOPRIGHT";
			listFrame:SetPoint(point, anchorFrame, relativePoint, 0, 0);
		end

		-- Change list box appearance depending on display mode
		if ( dropDownFrame and dropDownFrame.displayMode == "MENU" ) then
			_G[listFrameName.."Backdrop"]:Hide();
			_G[listFrameName.."MenuBackdrop"]:Show();
		else
			_G[listFrameName.."Backdrop"]:Show();
			_G[listFrameName.."MenuBackdrop"]:Hide();
		end
		dropDownFrame.menuList = menuList;
		LQuestie_UIDropDownMenu_Initialize(dropDownFrame, dropDownFrame.initialize, nil, level, menuList);
		-- If no items in the drop down don't show it
		if ( listFrame.numButtons == 0 ) then
			return;
		end

		-- Check to see if the dropdownlist is off the screen, if it is anchor it to the top of the dropdown button
		listFrame:Show();
		-- Hack since GetCenter() is returning coords relative to 1024x768
		local x, y = listFrame:GetCenter();
		-- Hack will fix this in next revision of dropdowns
		if ( not x or not y ) then
			listFrame:Hide();
			return;
		end

		listFrame.onHide = dropDownFrame.onHide;


		--  We just move level 1 enough to keep it on the screen. We don't necessarily change the anchors.
		if ( level == 1 ) then
			local offLeft = listFrame:GetLeft()/uiScale;
			local offRight = (GetScreenWidth() - listFrame:GetRight())/uiScale;
			local offTop = (GetScreenHeight() - listFrame:GetTop())/uiScale;
			local offBottom = listFrame:GetBottom()/uiScale;

			local xAddOffset, yAddOffset = 0, 0;
			if ( offLeft < 0 ) then
				xAddOffset = -offLeft;
			elseif ( offRight < 0 ) then
				xAddOffset = offRight;
			end

			if ( offTop < 0 ) then
				yAddOffset = offTop;
			elseif ( offBottom < 0 ) then
				yAddOffset = -offBottom;
			end

			listFrame:ClearAllPoints();
			if ( anchorName == "cursor" ) then
				listFrame:SetPoint(point, relativeTo, relativePoint, xOffset + xAddOffset, yOffset + yAddOffset);
			else
				listFrame:SetPoint(point, relativeTo, relativePoint, xOffset + xAddOffset, yOffset + yAddOffset);
			end
		else
			-- Determine whether the menu is off the screen or not
			local offscreenY, offscreenX;
			if ( (y - listFrame:GetHeight()/2) < 0 ) then
				offscreenY = 1;
			end
			if ( listFrame:GetRight() > GetScreenWidth() ) then
				offscreenX = 1;
			end
			if ( offscreenY and offscreenX ) then
				point = gsub(point, "TOP(.*)", "BOTTOM%1");
				point = gsub(point, "(.*)LEFT", "%1RIGHT");
				relativePoint = gsub(relativePoint, "TOP(.*)", "BOTTOM%1");
				relativePoint = gsub(relativePoint, "(.*)RIGHT", "%1LEFT");
				xOffset = 0;
				yOffset = -14;
			elseif ( offscreenY ) then
				point = gsub(point, "TOP(.*)", "BOTTOM%1");
				relativePoint = gsub(relativePoint, "TOP(.*)", "BOTTOM%1");
				xOffset = 0;
				yOffset = -14;
			elseif ( offscreenX ) then
				point = gsub(point, "(.*)LEFT", "%1RIGHT");
				relativePoint = gsub(relativePoint, "(.*)RIGHT", "%1LEFT");
				xOffset = 0;
				yOffset = 14;
			else
				xOffset = 0;
				yOffset = 14;
			end

			listFrame:ClearAllPoints();
			listFrame.parentLevel = tonumber(strmatch(anchorFrame:GetName(), "LQuestie_DropDownList(%d+)"));
			listFrame.parentID = anchorFrame:GetID();
			listFrame:SetPoint(point, anchorFrame, relativePoint, xOffset, yOffset);
		end

		if ( autoHideDelay and tonumber(autoHideDelay)) then
			listFrame.showTimer = autoHideDelay;
			listFrame.isCounting = 1;
		end
	end
end

function LQuestie_CloseDropDownMenus(level)
	if ( not level ) then
		level = 1;
	end
	for i=level, LQuestie_UIDROPDOWNMENU_MAXLEVELS do
		_G["LQuestie_DropDownList"..i]:Hide();
	end
end

function LQuestie_UIDropDownMenu_OnHide(self)
	local id = self:GetID()
	if ( self.onHide ) then
		self.onHide(id+1);
		self.onHide = nil;
	end
	LQuestie_CloseDropDownMenus(id+1);
	LQuestie_OPEN_DROPDOWNMENUS[id] = nil;
	if (id == 1) then
		LQuestie_UIDROPDOWNMENU_OPEN_MENU = nil;
	end

	if self.customFrames then
		for index, frame in ipairs(self.customFrames) do
			frame:Hide();
		end

		self.customFrames = nil;
	end
end

function LQuestie_UIDropDownMenu_SetWidth(frame, width, padding)
	local frameName = frame:GetName();
	GetChild(frame, frameName, "Middle"):SetWidth(width);
	local defaultPadding = 25;
	if ( padding ) then
		frame:SetWidth(width + padding);
	else
		frame:SetWidth(width + defaultPadding + defaultPadding);
	end
	if ( padding ) then
		GetChild(frame, frameName, "Text"):SetWidth(width);
	else
		GetChild(frame, frameName, "Text"):SetWidth(width - defaultPadding);
	end
	frame.noResize = 1;
end

function LQuestie_UIDropDownMenu_SetButtonWidth(frame, width)
	local frameName = frame:GetName();
	if ( width == "TEXT" ) then
		width = GetChild(frame, frameName, "Text"):GetWidth();
	end

	GetChild(frame, frameName, "Button"):SetWidth(width);
	frame.noResize = 1;
end

function LQuestie_UIDropDownMenu_SetText(frame, text)
	local frameName = frame:GetName();
	GetChild(frame, frameName, "Text"):SetText(text);
end

function LQuestie_UIDropDownMenu_GetText(frame)
	local frameName = frame:GetName();
	return GetChild(frame, frameName, "Text"):GetText();
end

function LQuestie_UIDropDownMenu_ClearAll(frame)
	-- Previous code refreshed the menu quite often and was a performance bottleneck
	frame.selectedID = nil;
	frame.selectedName = nil;
	frame.selectedValue = nil;
	LQuestie_UIDropDownMenu_SetText(frame, "");

	local button, checkImage, uncheckImage;
	for i=1, LQuestie_UIDROPDOWNMENU_MAXBUTTONS do
		button = _G["LQuestie_DropDownList"..LQuestie_UIDROPDOWNMENU_MENU_LEVEL.."Button"..i];
		button:UnlockHighlight();

		checkImage = _G["LQuestie_DropDownList"..LQuestie_UIDROPDOWNMENU_MENU_LEVEL.."Button"..i.."Check"];
		checkImage:Hide();
		uncheckImage = _G["LQuestie_DropDownList"..LQuestie_UIDROPDOWNMENU_MENU_LEVEL.."Button"..i.."UnCheck"];
		uncheckImage:Hide();
	end
end

function LQuestie_UIDropDownMenu_JustifyText(frame, justification)
	local frameName = frame:GetName();
	local text = GetChild(frame, frameName, "Text");
	text:ClearAllPoints();
	if ( justification == "LEFT" ) then
		text:SetPoint("LEFT", GetChild(frame, frameName, "Left"), "LEFT", 27, 2);
		text:SetJustifyH("LEFT");
	elseif ( justification == "RIGHT" ) then
		text:SetPoint("RIGHT", GetChild(frame, frameName, "Right"), "RIGHT", -43, 2);
		text:SetJustifyH("RIGHT");
	elseif ( justification == "CENTER" ) then
		text:SetPoint("CENTER", GetChild(frame, frameName, "Middle"), "CENTER", -5, 2);
		text:SetJustifyH("CENTER");
	end
end

function LQuestie_UIDropDownMenu_SetAnchor(dropdown, xOffset, yOffset, point, relativeTo, relativePoint)
	dropdown.xOffset = xOffset;
	dropdown.yOffset = yOffset;
	dropdown.point = point;
	dropdown.relativeTo = relativeTo;
	dropdown.relativePoint = relativePoint;
end

function LQuestie_UIDropDownMenu_GetCurrentDropDown()
	if ( LQuestie_UIDROPDOWNMENU_OPEN_MENU ) then
		return LQuestie_UIDROPDOWNMENU_OPEN_MENU;
	elseif ( LQuestie_UIDROPDOWNMENU_INIT_MENU ) then
		return LQuestie_UIDROPDOWNMENU_INIT_MENU;
	end
end

function LQuestie_UIDropDownMenuButton_GetChecked(self)
	return _G[self:GetName().."Check"]:IsShown();
end

function LQuestie_UIDropDownMenuButton_GetName(self)
	return _G[self:GetName().."NormalText"]:GetText();
end

function LQuestie_UIDropDownMenuButton_OpenColorPicker(self, button)
	securecall("CloseMenus");
	if ( not button ) then
		button = self;
	end
	LQuestie_UIDROPDOWNMENU_MENU_VALUE = button.value;
	LQuestie_OpenColorPicker(button); 
end

function LQuestie_UIDropDownMenu_DisableButton(level, id)
	_G["LQuestie_DropDownList"..level.."Button"..id]:Disable();
end

function LQuestie_UIDropDownMenu_EnableButton(level, id)
	_G["LQuestie_DropDownList"..level.."Button"..id]:Enable();
end

function LQuestie_UIDropDownMenu_SetButtonText(level, id, text, colorCode)
	local button = _G["LQuestie_DropDownList"..level.."Button"..id];
	if ( colorCode) then
		button:SetText(colorCode..text.."|r");
	else
		button:SetText(text);
	end
end

function LQuestie_UIDropDownMenu_SetButtonNotClickable(level, id)
	_G["LQuestie_DropDownList"..level.."Button"..id]:SetDisabledFontObject(GameFontHighlightSmallLeft);
end

function LQuestie_UIDropDownMenu_SetButtonClickable(level, id)
	_G["LQuestie_DropDownList"..level.."Button"..id]:SetDisabledFontObject(GameFontDisableSmallLeft);
end

function LQuestie_UIDropDownMenu_DisableDropDown(dropDown)
	local dropDownName = dropDown:GetName();
	local label = GetChild(dropDown, dropDownName, "Label");
	if ( label ) then
		label:SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
	end
	GetChild(dropDown, dropDownName, "Text"):SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
	GetChild(dropDown, dropDownName, "Button"):Disable();
	dropDown.isDisabled = 1;
end

function LQuestie_UIDropDownMenu_EnableDropDown(dropDown)
	local dropDownName = dropDown:GetName();
	local label = GetChild(dropDown, dropDownName, "Label");
	if ( label ) then
		label:SetVertexColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	end
	GetChild(dropDown, dropDownName, "Text"):SetVertexColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	GetChild(dropDown, dropDownName, "Button"):Enable();
	dropDown.isDisabled = nil;
end

function LQuestie_UIDropDownMenu_IsEnabled(dropDown)
	return not dropDown.isDisabled;
end

function LQuestie_UIDropDownMenu_GetValue(id)
	--Only works if the dropdown has just been initialized, lame, I know =(
	local button = _G["LQuestie_DropDownList1Button"..id];
	if ( button ) then
		return _G["LQuestie_DropDownList1Button"..id].value;
	else
		return nil;
	end
end

function LQuestie_OpenColorPicker(info)
	ColorPickerFrame.func = info.swatchFunc;
	ColorPickerFrame.hasOpacity = info.hasOpacity;
	ColorPickerFrame.opacityFunc = info.opacityFunc;
	ColorPickerFrame.opacity = info.opacity;
	ColorPickerFrame.previousValues = {r = info.r, g = info.g, b = info.b, opacity = info.opacity};
	ColorPickerFrame.cancelFunc = info.cancelFunc;
	ColorPickerFrame.extraInfo = info.extraInfo;
	-- This must come last, since it triggers a call to ColorPickerFrame.func()
	ColorPickerFrame:SetColorRGB(info.r, info.g, info.b);
	ShowUIPanel(ColorPickerFrame);
end

function LQuestie_ColorPicker_GetPreviousValues()
	return ColorPickerFrame.previousValues.r, ColorPickerFrame.previousValues.g, ColorPickerFrame.previousValues.b;
end
