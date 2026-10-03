-- This library is forked for Questie into different names to avoid using
-- versions modified by other addons.
-- For searching string/name to replace, still lot of falses:
-- (?<!(Questie)|(Lib:UI)|(Lib:Close)|(Lib:Toggle)|(\\UI-))dropdown(?!.*Questie)
-- Have to edit also string length values in matching
-- $Id: LibUIDropDownMenu.lua 145 2026-09-28 09:02:03Z arithmandar $
-- ----------------------------------------------------------------------------
-- Localized Lua globals.
-- ----------------------------------------------------------------------------
local envTable = GetCurrentEnvironment();

local tonumber, type, table, string = _G.tonumber, _G.type, _G.table, _G.string
local strsub, strlen, strmatch, gsub = string.sub, string.len, string.match, string.gsub
local math = _G.math
local max = math.max
local securecall = _G.securecall
-- WoW
local CreateFrame, GetCursorPosition, GetCVar, GetScreenHeight, GetScreenWidth, PlaySound = _G.CreateFrame, _G.GetCursorPosition, _G.GetCVar, _G.GetScreenHeight, _G.GetScreenWidth, _G.PlaySound
local GetBuildInfo = _G.GetBuildInfo
local GameTooltip, GetAppropriateTooltip = _G.GameTooltip, _G.GetAppropriateTooltip
local tooltip, GetValueOrCallFunction
tooltip = GetAppropriateTooltip()
local CloseMenus, ShowUIPanel = _G.CloseMenus, _G.ShowUIPanel
local GameTooltip_SetTitle, GameTooltip_AddInstructionLine, GameTooltip_AddNormalLine, GameTooltip_AddColoredLine = _G.GameTooltip_SetTitle, _G.GameTooltip_AddInstructionLine, _G.GameTooltip_AddNormalLine, _G.GameTooltip_AddColoredLine
local securecallfunction = securecallfunction;

-- ----------------------------------------------------------------------------
local MAJOR_VERSION = "LibUIDropDownMenuQuestie-4.0"
local MINOR_VERSION = 90000 + tonumber(("$Rev: 145 $"):match("%d+"))


local LibStub = _G.LibStub
if not LibStub then error(MAJOR_VERSION .. " requires LibStub.") end
local lib = LibStub:NewLibrary(MAJOR_VERSION, MINOR_VERSION)
if not lib then return end

local _, _, _, interfaceVersion = GetBuildInfo()
local projectID = WOW_PROJECT_ID

local PROJECT_MAINLINE = WOW_PROJECT_MAINLINE
local PROJECT_CLASSIC = WOW_PROJECT_CLASSIC
local PROJECT_TBC = WOW_PROJECT_BURNING_CRUSADE_CLASSIC
local PROJECT_CATA = WOW_PROJECT_CATACLYSM_CLASSIC
local PROJECT_MISTS = WOW_PROJECT_MISTS_CLASSIC

-- Beta-only fallback:
-- Replace these bounds with values verified from the actual Forever client.
local isForeverBeta = projectID == PROJECT_MAINLINE and interfaceVersion >= 10000 and interfaceVersion < 20000

local isRetail = projectID == PROJECT_MAINLINE and not isForeverBeta
local isClassicEra = projectID == PROJECT_CLASSIC
local isAnniversaryTBC = PROJECT_TBC ~= nil and projectID == PROJECT_TBC
local isCataclysmClassic = PROJECT_CATA ~= nil and projectID == PROJECT_CATA
local isMistsClassic = PROJECT_MISTS ~= nil and projectID == PROJECT_MISTS
local isProgressionClassic = isCataclysmClassic or isMistsClassic
local isClassicForever = isForeverBeta
local isAnyClassic = isClassicEra or isAnniversaryTBC or isProgressionClassic

if isRetail or isClassicForever then
	GetValueOrCallFunction = _G.GetValueOrCallFunction
end

-- //////////////////////////////////////////////////////////////
L_UIDROPDOWNMENUQUESTIE_MINBUTTONS = 8; -- classic only
L_UIDROPDOWNMENUQUESTIE_MAXBUTTONS = isAnyClassic and 8 or 1;
L_UIDROPDOWNMENUQUESTIE_MAXLEVELS = isAnyClassic and 2 or 3;
L_UIDROPDOWNMENUQUESTIE_BUTTON_HEIGHT = 16;
L_UIDROPDOWNMENUQUESTIE_BORDER_HEIGHT = 15;
-- The current open menu
L_UIDROPDOWNMENUQUESTIE_OPEN_MENU = nil;
-- The current menu being initialized
L_UIDROPDOWNMENUQUESTIE_INIT_MENU = nil;
-- Current level shown of the open menu
L_UIDROPDOWNMENUQUESTIE_MENU_LEVEL = 1;
-- Current value of the open menu
L_UIDROPDOWNMENUQUESTIE_MENU_VALUE = nil;
-- Time to wait to hide the menu
L_UIDROPDOWNMENUQUESTIE_SHOW_TIME = 2;
-- Default dropdown text height
L_UIDROPDOWNMENUQUESTIE_DEFAULT_TEXT_HEIGHT = nil;
-- For Classic checkmarks, this is the additional padding that we give to the button text.
L_UIDROPDOWNMENUQUESTIE_CLASSIC_CHECK_PADDING = 4;
-- Default dropdown width padding
L_UIDROPDOWNMENUQUESTIE_DEFAULT_WIDTH_PADDING = 25;
-- List of open menus
L_OPEN_QUESTIEDROPDOWNMENUS = {};

local L_DropDownListQuestie1, L_DropDownListQuestie2, L_DropDownListQuestie3

local delegateFrame = CreateFrame("FRAME");
delegateFrame:SetScript("OnAttributeChanged", function(self, attribute, value)
	if ( attribute == "createframes" and value == true ) then
		lib:UIDropDownMenu_CreateFrames(self:GetAttribute("createframes-level"), self:GetAttribute("createframes-index"));
	elseif ( attribute == "initmenu" ) then
		L_UIDROPDOWNMENUQUESTIE_INIT_MENU = value;
	elseif ( attribute == "openmenu" ) then
		L_UIDROPDOWNMENUQUESTIE_OPEN_MENU = value;
	end
end);

function lib:UIDropDownMenu_InitializeHelper(frame)
	-- This deals with the potentially tainted stuff!
	if ( frame ~= L_UIDROPDOWNMENUQUESTIE_OPEN_MENU ) then
		L_UIDROPDOWNMENUQUESTIE_MENU_LEVEL = 1;
	end

	-- Set the frame that's being intialized
	delegateFrame:SetAttribute("initmenu", frame);

	-- Hide all the buttons
	local button, dropDownList;
	for i = 1, L_UIDROPDOWNMENUQUESTIE_MAXLEVELS, 1 do
		dropDownList = envTable["L_DropDownListQuestie"..i];
		if ( i >= L_UIDROPDOWNMENUQUESTIE_MENU_LEVEL or frame ~= L_UIDROPDOWNMENUQUESTIE_OPEN_MENU ) then
			dropDownList.numButtons = 0;
			dropDownList.maxWidth = 0;
			for j=1, L_UIDROPDOWNMENUQUESTIE_MAXBUTTONS, 1 do
				button = envTable["L_DropDownListQuestie"..i.."Button"..j];
				button:Hide();
			end
			dropDownList:Hide();
		end
	end
	frame:SetHeight(L_UIDROPDOWNMENUQUESTIE_BUTTON_HEIGHT * 2);
end

--Questie addition, to know when menus are showing
function lib:getOpen()
	return L_UIDROPDOWNMENUQUESTIE_OPEN_MENU ~= nil
end

function lib:UIDropDownMenuButton_ShouldShowIconTooltip(self)
	if self.Icon and (self.iconTooltipTitle or self.iconTooltipText) and (self.icon or self.mouseOverIcon) then
		return self.Icon:IsMouseMotionFocus();
	end
	return false;
end


-- //////////////////////////////////////////////////////////////
-- L_UIDropDownMenuButtonTemplate
local function create_MenuButton(name, parent)
	-- UIDropDownMenuButton Scripts BEGIN
	local function button_OnEnter(self)
		if ( self.hasArrow ) then
			local level =  self:GetParent():GetID() + 1;
			local listFrame = envTable["L_DropDownListQuestie"..level];
			if ( not listFrame or not listFrame:IsShown() or select(2, listFrame:GetPoint(1)) ~= self ) then
				lib:ToggleDropDownMenu(self:GetParent():GetID() + 1, self.value, nil, nil, nil, nil, self.menuList, self, nil, self.menuListDisplayMode);
			end
		else
			lib:CloseDropDownMenus(self:GetParent():GetID() + 1);
		end
		self.Highlight:Show();
		if (isAnyClassic) then
	    		lib:UIDropDownMenu_StopCounting(self:GetParent());
		end
		-- To check: do we need special handle for classic since there is no UIDropDownMenuButton_ShouldShowIconTooltip()?
		-- if ( self.tooltipTitle and not self.noTooltipWhileEnabled ) then
		if ( self.tooltipTitle and not self.noTooltipWhileEnabled and not lib:UIDropDownMenuButton_ShouldShowIconTooltip(self)) then
			if ( self.tooltipOnButton ) then
				tooltip:SetOwner(self, self.tooltipAnchor or "ANCHOR_RIGHT");
				GameTooltip_SetTitle(tooltip, self.tooltipTitle);
				if self.tooltipInstruction then
					GameTooltip_AddInstructionLine(tooltip, self.tooltipInstruction);
				end
				if self.tooltipText then
					GameTooltip_AddNormalLine(tooltip, self.tooltipText, true);
				end
				if self.tooltipWarning then
					GameTooltip_AddColoredLine(tooltip, self.tooltipWarning, RED_FONT_COLOR, true);
				end
				if self.tooltipBackdropStyle then
					SharedTooltip_SetBackdropStyle(tooltip, self.tooltipBackdropStyle);
				end
				tooltip:Show();
			end
		end
					
		if ( self.mouseOverIcon ~= nil ) then
			self.Icon:SetTexture(self.mouseOverIcon);
			self.Icon:Show();
		end
		if (isRetail or isClassicForever) then
			GetValueOrCallFunction(self, "funcOnEnter", self);
			if self.NewFeature then
				self.NewFeature:Hide();
			end
		end
	end

	local function button_OnLeave(self)
		self.Highlight:Hide();
		if (isAnyClassic) then
			lib:UIDropDownMenu_StartCounting(self:GetParent());
		end

		GetAppropriateTooltip():Hide();
					
		if ( self.mouseOverIcon ~= nil ) then
			if ( self.icon ~= nil ) then
				self.Icon:SetTexture(self.icon);
			else
				self.Icon:Hide();
			end
		end

		if (isRetail or isClassicForever) then
			GetValueOrCallFunction(self, "funcOnLeave", self);
		end
	end

	local function button_OnClick(self, button)
		local checked = self.checked;
		if ( type (checked) == "function" ) then
			checked = checked(self);
		end

		if ( self.keepShownOnClick ) then
			if not self.notCheckable then
				if ( checked ) then
					envTable[self:GetName().."Check"]:Hide();
					envTable[self:GetName().."UnCheck"]:Show();
					checked = false;
				else
					envTable[self:GetName().."Check"]:Show();
					envTable[self:GetName().."UnCheck"]:Hide();
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
			func(self, self.arg1, self.arg2, checked, button);
		else
			return;
		end

		if ( playSound ) then
			PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON);
		end
	end
	-- UIDropDownMenuButton Scripts END
	
	-- UIDropDownMenuButtonIcon Script BEGIN
	local function icon_OnClick(self, button)
		local buttonParent = self:GetParent()
		if not buttonParent then
			return
		end
		button_OnClick(buttonParent, button)
	end
	
	local function icon_OnEnter(self)
		local button = self:GetParent();
		if not button then
			return;
		end

		local shouldShowIconTooltip = lib:UIDropDownMenuButton_ShouldShowIconTooltip(button);

		if shouldShowIconTooltip then
			tooltip:SetOwner(button, "ANCHOR_RIGHT");
			if button.iconTooltipTitle then
				GameTooltip_SetTitle(tooltip, button.iconTooltipTitle);
			end
			if button.iconTooltipText then
				GameTooltip_AddNormalLine(tooltip, button.iconTooltipText, true);
			end
			if button.iconTooltipBackdropStyle then
				SharedTooltip_SetBackdropStyle(tooltip, button.iconTooltipBackdropStyle);
			end
			tooltip:Show();
		end
		button_OnEnter(button);
	end
	
	local function icon_OnLeave(self)
		local button = self:GetParent();
		if not button then
			return;
		end
		
		button_OnLeave(button);
	end
	
	local function icon_OnMouseUp(self, button)
		if ( button == "LeftButton" ) then
			icon_OnClick(self, button)
		end
	end
	-- UIDropDownMenuButtonIcon Script END
	
	-- Button Frame
	local f = CreateFrame("Button", name, parent or nil)
    f:SetWidth(100)
    f:SetHeight(16)
    f:SetFrameLevel(f:GetParent():GetFrameLevel()+2)

	f.Highlight = f:CreateTexture( name and (name.."Highlight") or nil, "BACKGROUND")
	f.Highlight:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
	f.Highlight:SetBlendMode("ADD")
	f.Highlight:SetAllPoints()
	f.Highlight:Hide()
	
	f.Check = f:CreateTexture( name and (name.."Check") or nil, "ARTWORK")
	f.Check:SetTexture("Interface\\Common\\UI-DropDownRadioChecks")
	f.Check:SetSize(16, 16)
	f.Check:SetPoint("LEFT", f, 0, 0)
	f.Check:SetTexCoord(0, 0.5, 0.5, 1)

	f.UnCheck = f:CreateTexture( name and (name.."UnCheck") or nil, "ARTWORK")
	f.UnCheck:SetTexture("Interface\\Common\\UI-DropDownRadioChecks")
	f.UnCheck:SetSize(16, 16)
	f.UnCheck:SetPoint("LEFT", f, 0, 0)
	f.UnCheck:SetTexCoord(0.5, 1, 0.5, 1)
	
	-- Icon Texture
	local fIcon
	fIcon = f:CreateTexture( name and (name.."Icon") or nil, "ARTWORK")
	fIcon:SetSize(16, 16)
	fIcon:SetPoint("RIGHT", f, 0, 0)
	fIcon:Hide()
	if (isRetail or isClassicForever) then
		fIcon:SetScript("OnEnter", function(self)
			icon_OnEnter(self)
		end)
		fIcon:SetScript("OnLeave", function(self)
			icon_OnLeave(self)
		end)
		fIcon:SetScript("OnMouseUp", function(self, button)
			icon_OnMouseUp(self, button)
		end)
	end
	f.Icon = fIcon
	
	-- ColorSwatch
	local fcw
	fcw = CreateFrame("Button", name and (name.."ColorSwatch") or nil, f, BackdropTemplateMixin and DropDownMenuButtonMixin and "BackdropTemplate,ColorSwatchTemplate" or BackdropTemplateMixin and "BackdropTemplate" or nil)
	fcw:SetPoint("RIGHT", f, -6, 0)
	fcw:Hide()
	if not DropDownMenuButtonMixin then
		fcw:SetSize(16, 16)
		fcw.SwatchBg = fcw:CreateTexture( name and (name.."ColorSwatchSwatchBg") or nil, "BACKGROUND")
		fcw.SwatchBg:SetVertexColor(1, 1, 1)
		fcw.SwatchBg:SetWidth(14)
		fcw.SwatchBg:SetHeight(14)
		fcw.SwatchBg:SetPoint("CENTER", fcw, 0, 0)
		local button1NormalTexture = fcw:CreateTexture( name and (name.."ColorSwatchNormalTexture") or nil)
		button1NormalTexture:SetTexture("Interface\\ChatFrame\\ChatFrameColorSwatch")
		button1NormalTexture:SetAllPoints()
		fcw:SetNormalTexture(button1NormalTexture)
	end
	fcw:SetScript("OnClick", function(self, button, down)
		CloseMenus()
		lib:UIDropDownMenuButton_OpenColorPicker(self:GetParent())
	end)
	fcw:SetScript("OnEnter", function(self, motion)
		lib:CloseDropDownMenus(self:GetParent():GetParent():GetID() + 1)
		envTable[self:GetName().."SwatchBg"]:SetVertexColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
		lib:UIDropDownMenu_StopCounting(self:GetParent():GetParent())
	end)
	fcw:SetScript("OnLeave", function(self, motion)
		envTable[self:GetName().."SwatchBg"]:SetVertexColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
		lib:UIDropDownMenu_StartCounting(self:GetParent():GetParent())
	end)
	f.ColorSwatch = fcw
	
	-- ExpandArrow
	local fea = CreateFrame("Button", name and (name.."ExpandArrow") or nil, f)
	fea:SetSize(16, 16)
	fea:SetPoint("RIGHT", f, 0, 0)
	fea:Hide()
	local button2NormalTexture = fea:CreateTexture( name and (name.."ExpandArrowNormalTexture") or nil)
	button2NormalTexture:SetTexture("Interface\\ChatFrame\\ChatFrameExpandArrow")
	button2NormalTexture:SetAllPoints()
	fea:SetNormalTexture(button2NormalTexture)
	fea:SetScript("OnMouseDown", function(self, button)
		if self:IsEnabled() then
			lib:ToggleDropDownMenu(self:GetParent():GetParent():GetID() + 1, self:GetParent().value, nil, nil, nil, nil, self:GetParent().menuList, self);
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
		end
	end)
	fea:SetScript("OnEnter", function(self, motion)
		local level =  self:GetParent():GetParent():GetID() + 1
		lib:CloseDropDownMenus(level)
		if self:IsEnabled() then
			local listFrame = envTable["L_DropDownListQuestie"..level];
			if ( not listFrame or not listFrame:IsShown() or select(2, listFrame:GetPoint()) ~= self ) then
				lib:ToggleDropDownMenu(level, self:GetParent().value, nil, nil, nil, nil, self:GetParent().menuList, self)
			end
		end
		lib:UIDropDownMenu_StopCounting(self:GetParent():GetParent())
	end)
	fea:SetScript("OnLeave", function(self, motion)
		lib:UIDropDownMenu_StartCounting(self:GetParent():GetParent())
	end)
	f.ExpandArrow = fea

	-- InvisibleButton
	local fib = CreateFrame("Button", name and (name.."InvisibleButton") or nil, f)
	fib:Hide()
	fib:SetPoint("TOPLEFT", f, 0, 0)
	fib:SetPoint("BOTTOMLEFT", f, 0, 0)
	fib:SetPoint("RIGHT", fcw, "LEFT", 0, 0)
	fib:SetScript("OnEnter", function(self, motion)
		if (isAnyClassic) then
			lib:UIDropDownMenu_StopCounting(self:GetParent():GetParent());
		end
		lib:CloseDropDownMenus(self:GetParent():GetParent():GetID() + 1);
		local parent = self:GetParent();
		if ( parent.tooltipTitle and parent.tooltipWhileDisabled) then
			if ( parent.tooltipOnButton ) then
				tooltip:SetOwner(parent, "ANCHOR_RIGHT");
				GameTooltip_SetTitle(tooltip, parent.tooltipTitle);
				if parent.tooltipInstruction then
					GameTooltip_AddInstructionLine(tooltip, parent.tooltipInstruction);
				end
				if parent.tooltipText then
					GameTooltip_AddNormalLine(tooltip, parent.tooltipText, true);
				end
				if parent.tooltipWarning then
					GameTooltip_AddColoredLine(tooltip, parent.tooltipWarning, RED_FONT_COLOR, true);
				end
				if parent.tooltipBackdropStyle then
					SharedTooltip_SetBackdropStyle(tooltip, parent.tooltipBackdropStyle);
				end
				tooltip:Show();
			end
		end
	end)
	fib:SetScript("OnLeave", function(self, motion)
		if (isAnyClassic) then
			lib:UIDropDownMenu_StartCounting(self:GetParent():GetParent());
		end
		tooltip:Hide();
	end)
	f.invisibleButton = fib
	
	-- NewFeature
	if (isRetail or isClassicForever) then
		local fnf = CreateFrame("Frame", name and (name.."NewFeature") or nil, f, "NewFeatureLabelTemplate");
		fnf:SetFrameStrata("HIGH");
		fnf:SetScale(0.8);
		fnf:SetFrameLevel(100);
		fnf:SetSize(1, 1);
		fnf:Hide();
		
		f.NewFeature = fnf;
	end

	-- MenuButton scripts
	f:SetScript("OnClick", function(self, button)
		button_OnClick(self, button)
	end)
	f:SetScript("OnEnter", function(self, motion)
		button_OnEnter(self)
	end)
	f:SetScript("OnLeave", function(self, motion)
		button_OnLeave(self)
	end)
	f:SetScript("OnEnable", function(self)
		self.invisibleButton:Hide()
	end)
	f:SetScript("OnDisable", function(self)
		self.invisibleButton:Show()
	end)

	local text1 = f:CreateFontString( name and (name.."NormalText") or nil)
	f:SetFontString(text1)
	text1:SetPoint("LEFT", f, -5, 0)
	f:SetNormalFontObject("GameFontHighlightSmallLeft")
	f:SetHighlightFontObject("GameFontHighlightSmallLeft")
	f:SetDisabledFontObject("GameFontDisableSmallLeft")

	return f
end

-- //////////////////////////////////////////////////////////////
-- L_UIDropDownListTemplate
local function creatre_DropDownList(name, parent)
	-- This has been removed from Backdrop.lua, so we added the definition here.
	local BACKDROP_DIALOG_DARK = {
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
		tile = true,
		tileEdge = true,
		tileSize = 32,
		edgeSize = 32,
		insets = { left = 11, right = 12, top = 12, bottom = 11, },
	}
	local BACKDROP_TOOLTIP_16_16_5555 = {
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true,
		tileEdge = true,
		tileSize = 16,
		edgeSize = 16,
		insets = { left = 5, right = 5, top = 5, bottom = 5 },
	}
	
	local f = name and envTable[name] or CreateFrame("Button", name)
	f:SetParent(parent or nil)
	f:Hide()
	f:SetFrameStrata("DIALOG")
	f:EnableMouse(true)
	
	local fbd = name and envTable[name.."Backdrop"] or CreateFrame("Frame", name and (name.."Backdrop") or nil, f, BackdropTemplateMixin and "DialogBorderDarkTemplate" or nil)
	fbd:SetAllPoints()
	fbd.backdropInfo = BACKDROP_DIALOG_DARK
	f.Backdrop = fbd
	
	local fmb = name and envTable[name.."MenuBackdrop"] or CreateFrame("Frame", name and (name.."MenuBackdrop") or nil, f, TooltipBackdropTemplateMixin and "TooltipBackdropTemplate" or nil)
	fmb:SetAllPoints()
	fmb.backdropInfo = BACKDROP_TOOLTIP_16_16_5555
	fmb:SetBackdropBorderColor(TOOLTIP_DEFAULT_COLOR.r, TOOLTIP_DEFAULT_COLOR.g, TOOLTIP_DEFAULT_COLOR.b)
	fmb:SetBackdropColor(TOOLTIP_DEFAULT_BACKGROUND_COLOR.r, TOOLTIP_DEFAULT_BACKGROUND_COLOR.g, TOOLTIP_DEFAULT_BACKGROUND_COLOR.b)
	f.MenuBackdrop = fmb
	
	f.Button1 = name and envTable[name.."Button1"] or create_MenuButton(name and (name.."Button1") or nil, f) -- to replace the inherits of "UIDropDownMenuButtonTemplate"
	f.Button1:SetID(1)
	for index = 2, L_UIDROPDOWNMENUQUESTIE_MAXBUTTONS do
		local button = name and envTable[name.."Button"..index] or create_MenuButton(name and (name.."Button"..index) or nil, f)
		button:SetID(index)
	end

	-- Checking if NewFeature exists or not
	if (isRetail or isClassicForever) then
		if not f.Button1.NewFeature then
			local fnf = CreateFrame("Frame", name and (name.."NewFeature") or nil, f, "NewFeatureLabelTemplate");
			fnf:SetFrameStrata("HIGH");
			fnf:SetScale(0.8);
			fnf:SetFrameLevel(100);
			fnf:SetSize(1, 1);
			fnf:Hide();
			
			f.Button1.NewFeature = fnf;
		end
	end
	
	
	f:SetScript("OnClick", function(self)
		self:Hide()
	end)
	f:SetScript("OnEnter", function(self)
		if (isAnyClassic) then
			lib:UIDropDownMenu_StopCounting(self)
		end
	end)
	f:SetScript("OnLeave", function(self)
		if (isAnyClassic) then
			lib:UIDropDownMenu_StartCounting(self)
		end
	end)
	-- If dropdown is visible then see if its timer has expired, if so hide the frame
	f:SetScript("OnUpdate", function(self, elapsed)
		if ( self.shouldRefresh ) then
			lib:UIDropDownMenu_RefreshDropDownSize(self);
			self.shouldRefresh = false;
		end
		if (isAnyClassic) then
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
	end)
	f:SetScript("OnShow", function(self)
		if ( self.onShow ) then
			self.onShow();
			self.onShow = nil;
		end

		for i=1, L_UIDROPDOWNMENUQUESTIE_MAXBUTTONS do
			if (not self.noResize) then
				envTable[self:GetName().."Button"..i]:SetWidth(self.maxWidth);
			end
		end

		if (not self.noResize) then
			self:SetWidth(self.maxWidth+25);
		end
		if (isAnyClassic) then
			self.showTimer = nil;
		end
		if ( self:GetID() > 1 ) then
			self.parent = envTable["L_DropDownListQuestie"..(self:GetID() - 1)];
		end
		EventRegistry:TriggerEvent("UIDropDownMenu.Show", self);
	end)
	f:SetScript("OnHide", function(self)
		local id = self:GetID()
		if ( self.onHide ) then
			self.onHide(id+1);
			self.onHide = nil;
		end
		if ( self.baseFrameStrata ) then
			self:SetFrameStrata(self.baseFrameStrata);
			self.baseFrameStrata = nil;
		end
		lib:CloseDropDownMenus(id+1);
		L_OPEN_QUESTIEDROPDOWNMENUS[id] = nil;
		if (id == 1) then
			L_UIDROPDOWNMENUQUESTIE_OPEN_MENU = nil;
		end

		lib:UIDropDownMenu_ClearCustomFrames(self);
		EventRegistry:TriggerEvent("UIDropDownMenu.Hide");
	end)
	
	return f
end

-- //////////////////////////////////////////////////////////////
-- L_UIDropDownMenuTemplate
local function create_DropDownMenu(name, parent)
	local f
	if type(name) == "table" then
		f = name
		name = f:GetName()
	else
		f = CreateFrame("Frame", name, parent or nil)
	end
	
	--if not name then name = "" end
	
	f:SetSize(40, 32)
	
	f.Left = f:CreateTexture( name and (name.."Left") or nil, "ARTWORK")
	f.Left:SetTexture("Interface\\Glues\\CharacterCreate\\CharacterCreate-LabelFrame")
	f.Left:SetSize(25, 64)
	f.Left:SetPoint("TOPLEFT", f, 0, 17)
	f.Left:SetTexCoord(0, 0.1953125, 0, 1)
	
	f.Middle = f:CreateTexture( name and (name.."Middle") or nil, "ARTWORK")
	f.Middle:SetTexture("Interface\\Glues\\CharacterCreate\\CharacterCreate-LabelFrame")
	f.Middle:SetSize(115, 64)
	f.Middle:SetPoint("LEFT", f.Left, "RIGHT")
	f.Middle:SetTexCoord(0.1953125, 0.8046875, 0, 1)
	
	f.Right = f:CreateTexture( name and (name.."Right") or nil, "ARTWORK")
	f.Right:SetTexture("Interface\\Glues\\CharacterCreate\\CharacterCreate-LabelFrame")
	f.Right:SetSize(25, 64)
	f.Right:SetPoint("LEFT", f.Middle, "RIGHT")
	f.Right:SetTexCoord(0.8046875, 1, 0, 1)
	
	f.Text = f:CreateFontString( name and (name.."Text") or nil, "ARTWORK", "GameFontHighlightSmall")
	f.Text:SetWordWrap(false)
	f.Text:SetJustifyH("RIGHT")
	f.Text:SetSize(0, 10)
	f.Text:SetPoint("RIGHT", f.Right, -43, 2)
	
	f.Icon = f:CreateTexture( name and (name.."Icon") or nil, "OVERLAY")
	f.Icon:Hide()
	f.Icon:SetSize(16, 16)
	f.Icon:SetPoint("LEFT", 30, 2)
	
	-- // UIDropDownMenuButtonScriptTemplate
	f.Button = CreateFrame("Button", name and (name.."Button") or nil, f)
	f.Button:SetMotionScriptsWhileDisabled(true)
	f.Button:SetSize(24, 24)
	f.Button:SetPoint("TOPRIGHT", f.Right, -16, -18)
	
	f.Button.NormalTexture = f.Button:CreateTexture( name and (name.."NormalTexture") or nil)
	f.Button.NormalTexture:SetTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Up")
	f.Button.NormalTexture:SetSize(24, 24)
	f.Button.NormalTexture:SetPoint("RIGHT", f.Button, 0, 0)
	f.Button:SetNormalTexture(f.Button.NormalTexture)
	
	f.Button.PushedTexture = f.Button:CreateTexture( name and (name.."PushedTexture") or nil)
	f.Button.PushedTexture:SetTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Down")
	f.Button.PushedTexture:SetSize(24, 24)
	f.Button.PushedTexture:SetPoint("RIGHT", f.Button, 0, 0)
	f.Button:SetPushedTexture(f.Button.PushedTexture)
	
	f.Button.DisabledTexture = f.Button:CreateTexture( name and (name.."DisabledTexture") or nil)
	f.Button.DisabledTexture:SetTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Disabled")
	f.Button.DisabledTexture:SetSize(24, 24)
	f.Button.DisabledTexture:SetPoint("RIGHT", f.Button, 0, 0)
	f.Button:SetDisabledTexture(f.Button.DisabledTexture)
	
	f.Button.HighlightTexture = f.Button:CreateTexture( name and (name.."HighlightTexture") or nil)
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
	f.Button:SetScript("OnMouseDown", function(self, button)
		if self:IsEnabled() then
			local parent = self:GetParent()
			lib:ToggleDropDownMenu(nil, nil, parent)
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
		end
	end)
	
	-- UIDropDownMenu Script
	f:SetScript("OnHide", function(self)
		lib:CloseDropDownMenus()
	end)
	
	return f
end
-- End of frame templates
-- //////////////////////////////////////////////////////////////

-- //////////////////////////////////////////////////////////////
-- Handling two frames from LibUIDropDownMenu.xml
local function create_DropDownButtons()
	L_DropDownListQuestie1 = creatre_DropDownList("L_DropDownListQuestie1")
	L_DropDownListQuestie1:SetToplevel(true)
	L_DropDownListQuestie1:SetFrameStrata("FULLSCREEN_DIALOG")
	L_DropDownListQuestie1:Hide()
	L_DropDownListQuestie1:SetID(1)
	L_DropDownListQuestie1:SetSize(180, 10)
	local _, fontHeight, _ = envTable["L_DropDownListQuestie1Button1NormalText"]:GetFont()
	L_UIDROPDOWNMENUQUESTIE_DEFAULT_TEXT_HEIGHT = fontHeight
	
	L_DropDownListQuestie2 = creatre_DropDownList("L_DropDownListQuestie2")
	L_DropDownListQuestie2:SetToplevel(true)
	L_DropDownListQuestie2:SetFrameStrata("FULLSCREEN_DIALOG")
	L_DropDownListQuestie2:Hide()
	L_DropDownListQuestie2:SetID(2)
	L_DropDownListQuestie2:SetSize(180, 10)

	L_DropDownListQuestie3 = creatre_DropDownList("L_DropDownListQuestie3")
	L_DropDownListQuestie3:SetToplevel(true)
	L_DropDownListQuestie3:SetFrameStrata("FULLSCREEN_DIALOG")
	L_DropDownListQuestie3:Hide()
	L_DropDownListQuestie3:SetID(3)
	L_DropDownListQuestie3:SetSize(180, 10)

	-- UIParent integration; since we customize the name of DropDownList, we need to add it to golbal UIMenus table.
	--tinsert(UIMenus, "L_DropDownListQuestie1");
	--tinsert(UIMenus, "L_DropDownListQuestie2");
	--tinsert(UIMenus, "L_DropDownListQuestie3");
	
	-- Alternative by Dahk Celes (DDC) that avoids tainting UIMenus and CloseMenus()
	hooksecurefunc("CloseMenus", function()
		L_DropDownListQuestie1:Hide()
		L_DropDownListQuestie2:Hide()
		L_DropDownListQuestie3:Hide()
	end)
end

do
	if lib then 
		create_DropDownButtons()
	end
end

-- //////////////////////////////////////////////////////////////
-- Global function to replace L_UIDropDownMenuTemplate
function lib:Create_UIDropDownMenu(name, parent)
    return create_DropDownMenu(name, parent)
end

local function GetChild(frame, name, key)
	if (frame[key]) then
		return frame[key];
	elseif name then
		return envTable[name..key];
	end

	return nil;
end

function lib:UIDropDownMenu_Initialize(frame, initFunction, displayMode, level, menuList)
	frame.menuList = menuList;

	--securecall("initializeHelper", frame);
	lib:UIDropDownMenu_InitializeHelper(frame)

	-- Set the initialize function and call it.  The initFunction populates the dropdown list.
	if ( initFunction ) then
		lib:UIDropDownMenu_SetInitializeFunction(frame, initFunction);
		initFunction(frame, level, frame.menuList);
	end

	--master frame
	if(level == nil) then
		level = 1;
	end

	local dropDownList = envTable["L_DropDownListQuestie"..level];
	dropDownList.dropdown = frame;
	dropDownList.shouldRefresh = true;
	if (isRetail or isClassicForever) then
		dropDownList:SetWindow(frame:GetWindow());
	end

	lib:UIDropDownMenu_SetDisplayMode(frame, displayMode);
end

function lib:UIDropDownMenu_SetInitializeFunction(frame, initFunction)
	frame.initialize = initFunction;
end

function lib:UIDropDownMenu_SetDisplayMode(frame, displayMode)
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

function lib:UIDropDownMenu_SetFrameStrata(frame, frameStrata)
	frame.listFrameStrata = frameStrata;
end

function lib:UIDropDownMenu_RefreshDropDownSize(self)
	self.maxWidth = lib:UIDropDownMenu_GetMaxButtonWidth(self);
	self:SetWidth(self.maxWidth + 25);

	for i=1, L_UIDROPDOWNMENUQUESTIE_MAXBUTTONS, 1 do
		local icon = envTable[self:GetName().."Button"..i.."Icon"];

		if ( icon.tFitDropDownSizeX ) then
			icon:SetWidth(self.maxWidth - 5);
		end
	end
end

-- Start the countdown on a frame
function lib:UIDropDownMenu_StartCounting(frame)
	if ( frame.parent ) then
		lib:UIDropDownMenu_StartCounting(frame.parent);
	else
		frame.showTimer = L_UIDROPDOWNMENUQUESTIE_SHOW_TIME;
		frame.isCounting = 1;
	end
end

-- Stop the countdown on a frame
function lib:UIDropDownMenu_StopCounting(frame)
	if ( frame.parent ) then
		lib:UIDropDownMenu_StopCounting(frame.parent);
	else
		frame.isCounting = nil;
	end
end


--[[
List of button attributes
======================================================
info.text = [STRING]  --  The text of the button
info.value = [ANYTHING]  --  The value that L_UIDROPDOWNMENUQUESTIE_MENU_VALUE is set to when the button is clicked
info.func = [function()]  --  The function that is called when you click the button
info.checked = [nil, true, function]  --  Check the button if true or function returns true
info.isNotRadio = [nil, true]  --  Check the button uses radial image if false check box image if true
info.isTitle = [nil, true]  --  If it's a title the button is disabled and the font color is set to yellow
info.disabled = [nil, true]  --  Disable the button and show an invisible button that still traps the mouseover event so menu doesn't time out
info.tooltipWhileDisabled = [nil, 1] -- Show the tooltip, even when the button is disabled.
info.hasArrow = [nil, true]  --  Show the expand arrow for multilevel menus
info.arrowXOffset = [nil, NUMBER] -- Number of pixels to shift the button's icon to the left or right (positive numbers shift right, negative numbers shift left).
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
info.tooltipWarning = [nil, STRING] -- Warning-style text of the tooltip shown on mouseover
info.tooltipInstruction = [nil, STRING] -- Instruction-style text of the tooltip shown on mouseover
info.tooltipOnButton = [nil, 1] -- Show the tooltip attached to the button instead of as a Newbie tooltip.
info.tooltipBackdropStyle = [nil, TABLE] -- Optional Backdrop style of the tooltip shown on mouseover
info.tooltipAnchor = [nil, STRING] -- Pass a custom tooltip anchor (Default is "ANCHOR_RIGHT")
info.justifyH = [nil, "CENTER"] -- Justify button text
info.arg1 = [ANYTHING] -- This is the first argument used by info.func
info.arg2 = [ANYTHING] -- This is the second argument used by info.func
info.fontObject = [FONT] -- font object replacement for Normal and Highlight
info.menuList = [TABLE] -- This contains an array of info tables to be displayed as a child menu
info.menuListDisplayMode = [nil, "MENU"] -- If menuList is set, show the sub drop down with an override display mode.
info.noClickSound = [nil, 1]  --  Set to 1 to suppress the sound when clicking the button. The sound only plays if .func is set.
info.padding = [nil, NUMBER] -- Number of pixels to pad the text on the right side
info.topPadding = [nil, NUMBER] -- Extra spacing between buttons.
info.leftPadding = [nil, NUMBER] -- Number of pixels to pad the button on the left side
info.minWidth = [nil, NUMBER] -- Minimum width for this line
info.customFrame = frame -- Allows this button to be a completely custom frame, should inherit from UIDropDownCustomMenuEntryTemplate and override appropriate methods.
info.icon = [TEXTURE] -- An icon for the button.
info.iconXOffset = [nil, NUMBER] -- Number of pixels to shift the button's icon to the left or right (positive numbers shift right, negative numbers shift left).
info.iconTooltipTitle = [nil, STRING] -- Title of the tooltip shown on icon mouseover
info.iconTooltipText = [nil, STRING] -- Text of the tooltip shown on icon mouseover
info.iconTooltipBackdropStyle = [nil, TABLE] -- Optional Backdrop style of the tooltip shown on icon mouseover
info.mouseOverIcon = [TEXTURE] -- An override icon when a button is moused over.
info.ignoreAsMenuSelection [nil, true] -- Never set the menu text/icon to this, even when this button is checked
info.registerForRightClick [nil, true] -- Register dropdown buttons for right clicks
info.registerForAnyClick [nil, true] -- Register dropdown buttons for any clicks
info.showNewLabel
]]

-- Create (return) empty table
function lib:UIDropDownMenu_CreateInfo()
	return {};
end

function lib:UIDropDownMenu_CreateFrames(level, index)
	while ( level > L_UIDROPDOWNMENUQUESTIE_MAXLEVELS ) do
		L_UIDROPDOWNMENUQUESTIE_MAXLEVELS = L_UIDROPDOWNMENUQUESTIE_MAXLEVELS + 1;
		--local newList = CreateFrame("Button", "L_DropDownListQuestie"..L_UIDROPDOWNMENUQUESTIE_MAXLEVELS, nil, "L_UIDropDownListTemplate");
		local newList = creatre_DropDownList("L_DropDownListQuestie"..L_UIDROPDOWNMENUQUESTIE_MAXLEVELS)
		newList:SetFrameStrata("FULLSCREEN_DIALOG");
		newList:SetToplevel(true);
		newList:Hide();
		newList:SetID(L_UIDROPDOWNMENUQUESTIE_MAXLEVELS);
		newList:SetWidth(180)
		newList:SetHeight(10)
--		for i = WoWRetail and 1 or (L_UIDROPDOWNMENUQUESTIE_MINBUTTONS+1), L_UIDROPDOWNMENUQUESTIE_MAXBUTTONS do
		for i=1, L_UIDROPDOWNMENUQUESTIE_MAXBUTTONS do
			--local newButton = CreateFrame("Button", "L_DropDownListQuestie"..L_UIDROPDOWNMENUQUESTIE_MAXLEVELS.."Button"..i, newList, "L_UIDropDownMenuButtonTemplate");
			local newButton = create_MenuButton("L_DropDownListQuestie"..L_UIDROPDOWNMENUQUESTIE_MAXLEVELS.."Button"..i, newList)
			newButton:SetID(i);
		end
	end

	while ( index > L_UIDROPDOWNMENUQUESTIE_MAXBUTTONS ) do
		L_UIDROPDOWNMENUQUESTIE_MAXBUTTONS = L_UIDROPDOWNMENUQUESTIE_MAXBUTTONS + 1;
		for i=1, L_UIDROPDOWNMENUQUESTIE_MAXLEVELS do
			--local newButton = CreateFrame("Button", "L_DropDownListQuestie"..i.."Button"..L_UIDROPDOWNMENUQUESTIE_MAXBUTTONS, envTable["L_DropDownListQuestie"..i], "L_UIDropDownMenuButtonTemplate");
			local newButton = create_MenuButton("L_DropDownListQuestie"..i.."Button"..L_UIDROPDOWNMENUQUESTIE_MAXBUTTONS, envTable["L_DropDownListQuestie"..i])
			newButton:SetID(L_UIDROPDOWNMENUQUESTIE_MAXBUTTONS);
		end
	end
end

function lib:UIDropDownMenu_AddSeparator(level)
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

	lib:UIDropDownMenu_AddButton(separatorInfo, level);
end

function lib:UIDropDownMenu_AddSpace(level)
	local spaceInfo = {
		hasArrow = false,
		dist = 0,
		isTitle = true,
		isUninteractable = true,
		notCheckable = true,
	};

	lib:UIDropDownMenu_AddButton(spaceInfo, level);
end

local function L_UIDropDownMenu_IsDisplayModeMenu()
	local frame = L_UIDROPDOWNMENUQUESTIE_OPEN_MENU;
	return frame and frame.displayMode == "MENU";
end
function lib:UIDropDownMenu_AddButton(info, level)
	--[[
	Might to uncomment this if there are performance issues
	if ( not L_UIDROPDOWNMENUQUESTIE_OPEN_MENU ) then
		return;
	end
	]]
	if ( not level ) then
		level = 1;
	end

	local listFrame = envTable["L_DropDownListQuestie"..level];
	local index;
	if (listFrame) then
		index = listFrame.numButtons and (listFrame.numButtons + 1) or 1
	else
		index = 0
	end
	--local index = listFrame and (listFrame.numButtons + 1) or 1;
	local width;

	delegateFrame:SetAttribute("createframes-level", level);
	delegateFrame:SetAttribute("createframes-index", index);
	delegateFrame:SetAttribute("createframes", true);

	listFrame = listFrame or envTable["L_DropDownListQuestie"..level];
	local listFrameName = listFrame:GetName();

	-- Set the number of buttons in the listframe
	listFrame.numButtons = index;

	local button = envTable[listFrameName.."Button"..index];
	local normalText = envTable[button:GetName().."NormalText"];
	local icon = envTable[button:GetName().."Icon"];
	-- This button is used to capture the mouse OnEnter/OnLeave events if the dropdown button is disabled, since a disabled button doesn't receive any events
	-- This is used specifically for drop down menu time outs
	local invisibleButton = envTable[button:GetName().."InvisibleButton"];

	-- Default settings
	button:SetDisabledFontObject(GameFontDisableSmallLeft);
	invisibleButton:Hide();
	button:Enable();

	if ( info.registerForAnyClick ) then
		button:RegisterForClicks("AnyUp");
	elseif ( info.registerForRightClick ) then
		button:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	else
		button:RegisterForClicks("LeftButtonUp");
	end

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
			if (isRetail or isClassicForever) then
				if(info.icon and C_Texture.GetAtlasInfo(info.icon)) then
					icon:SetAtlas(info.icon);
				else
					icon:SetTexture(info.icon);
				end
				icon:ClearAllPoints();
				icon:SetPoint("RIGHT", info.iconXOffset or 0, 0);
			else
				icon:SetTexture(info.icon);
				icon:ClearAllPoints();
				icon:SetPoint("RIGHT");
			end

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

		lib:UIDropDownMenu_SetIconImage(icon, info.icon, info.iconInfo);
		icon:ClearAllPoints();
		icon:SetPoint("LEFT");
	end

	-- Pass through attributes
	button.func = info.func;
	button.funcOnEnter = info.funcOnEnter;
	button.funcOnLeave = info.funcOnLeave;
	if (isRetail or isClassicForever) then
		button.iconXOffset = info.iconXOffset;
		button.ignoreAsMenuSelection = info.ignoreAsMenuSelection;
		button.showNewLabel = info.showNewLabel;
	else
		button.classicChecks = info.classicChecks;
	end
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
	-- button.tooltipBackdropStyle = info.tooltipBackdropStyle;
	button.tooltipAnchor = info.tooltipAnchor;
	button.arg1 = info.arg1;
	button.arg2 = info.arg2;
	button.hasArrow = info.hasArrow;
	button.arrowXOffset = info.arrowXOffset;
	button.hasColorSwatch = info.hasColorSwatch;
	button.notCheckable = info.notCheckable;
	button.menuList = info.menuList;
	button.menuListDisplayMode = info.menuListDisplayMode;
	button.tooltipWhileDisabled = info.tooltipWhileDisabled;
	button.noTooltipWhileEnabled = info.noTooltipWhileEnabled;
	button.tooltipOnButton = info.tooltipOnButton;
	button.noClickSound = info.noClickSound;
	button.padding = info.padding;
	button.icon = info.icon;
	button.mouseOverIcon = info.mouseOverIcon;
	if (isRetail or isClassicForever) then
		button.tooltipBackdropStyle = info.tooltipBackdropStyle;
		button.iconTooltipTitle = info.iconTooltipTitle;
		button.iconTooltipText = info.iconTooltipText;
		button.iconTooltipBackdropStyle = info.iconTooltipBackdropStyle;
		button.iconXOffset = info.iconXOffset;
		button.ignoreAsMenuSelection = info.ignoreAsMenuSelection;
	else
		button.classicChecks = info.classicChecks;
	end

	if ( info.value ~= nil ) then
		button.value = info.value;
	elseif ( info.text ) then
		button.value = info.text;
	else
		button.value = nil;
	end

	local expandArrow = envTable[listFrameName.."Button"..index.."ExpandArrow"];
	expandArrow:SetPoint("RIGHT", info.arrowXOffset or 0, 0);
	expandArrow:SetShown(info.hasArrow);
	expandArrow:SetEnabled(not info.disabled);

	-- If not checkable move everything over to the left to fill in the gap where the check would be
	local xPos = 5;
	local buttonHeight = (info.topPadding or 0) + L_UIDROPDOWNMENUQUESTIE_BUTTON_HEIGHT;
	local yPos = -((button:GetID() - 1) * buttonHeight) - L_UIDROPDOWNMENUQUESTIE_BORDER_HEIGHT;
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
	if ( not info.notCheckable and securecallfunction(L_UIDropDownMenu_IsDisplayModeMenu) )then
		xPos = xPos - 6;
	end

	-- If no open frame then set the frame to the currently initialized frame
	local frame = frame or L_UIDROPDOWNMENUQUESTIE_INIT_MENU;

	if ( info.leftPadding ) then
		xPos = xPos + info.leftPadding;
	end
	button:SetPoint("TOPLEFT", button:GetParent(), "TOPLEFT", xPos, yPos);

	-- See if button is selected by id or name
	if ( frame ) then
		if ( lib:UIDropDownMenu_GetSelectedName(frame) ) then
			if ( button:GetText() == lib:UIDropDownMenu_GetSelectedName(frame) ) then
				info.checked = 1;
			end
		elseif ( lib:UIDropDownMenu_GetSelectedID(frame) ) then
			if ( button:GetID() == lib:UIDropDownMenu_GetSelectedID(frame) ) then
				info.checked = 1;
			end
		elseif ( lib:UIDropDownMenu_GetSelectedValue(frame) ~= nil ) then
			if ( button.value == lib:UIDropDownMenu_GetSelectedValue(frame) ) then
				info.checked = 1;
			end
		end
	end

	if not info.notCheckable then 
		local check = envTable[listFrameName.."Button"..index.."Check"];
		local uncheck = envTable[listFrameName.."Button"..index.."UnCheck"];
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
		if (isAnyClassic) then
			check:SetSize(16,16);
			uncheck:SetSize(16,16);
			normalText:SetPoint("LEFT", check, "RIGHT", 0, 0);
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
		elseif info.classicChecks then
			check:SetTexCoord(0, 1, 0, 1);
			uncheck:SetTexCoord(0, 1, 0, 1);

			check:SetSize(24,24);
			uncheck:SetSize(24,24);

			check:SetTexture("Interface\\Buttons\\UI-CheckBox-Check");
			uncheck:SetTexture("");

			normalText:SetPoint("LEFT", check, "RIGHT", L_UIDROPDOWNMENUQUESTIE_CLASSIC_CHECK_PADDING, 0);
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
		envTable[listFrameName.."Button"..index.."Check"]:Hide();
		envTable[listFrameName.."Button"..index.."UnCheck"]:Hide();
	end
	button.checked = info.checked;
	if ((isRetail or isClassicForever) and button.NewFeature) then
		button.NewFeature:SetShown(button.showNewLabel);
	end
	
	-- If has a colorswatch, show it and vertex color it
	local colorSwatch = envTable[listFrameName.."Button"..index.."ColorSwatch"];
	if ( info.hasColorSwatch ) then
		if (isAnyClassic) then
			envTable["L_DropDownListQuestie"..level.."Button"..index.."ColorSwatch".."NormalTexture"]:SetVertexColor(info.r, info.g, info.b);
		else
			envTable["L_DropDownListQuestie"..level.."Button"..index.."ColorSwatch"].Color:SetVertexColor(info.r, info.g, info.b);
		end
		button.r = info.r;
		button.g = info.g;
		button.b = info.b;
		colorSwatch:Show();
	else
		colorSwatch:Hide();
	end

	lib:UIDropDownMenu_CheckAddCustomFrame(listFrame, button, info);

	button:SetShown(button.customFrame == nil);

	button.minWidth = info.minWidth;

	width = max(lib:UIDropDownMenu_GetButtonWidth(button), info.minWidth or 0);
	--Set maximum button width
	if ( width > (listFrame and listFrame.maxWidth or 0) ) then
		listFrame.maxWidth = width;
	end

	if (isRetail or isClassicForever) then
		local customFrameCount = listFrame.customFrames and #listFrame.customFrames or 0;
		local height = ((index - customFrameCount) * buttonHeight) + (L_UIDROPDOWNMENUQUESTIE_BORDER_HEIGHT * 2);
		for frameIndex = 1, customFrameCount do
			frame = listFrame.customFrames[frameIndex];
			height = height + frame:GetPreferredEntryHeight();
		end
		
		-- Set the height of the listframe
		listFrame:SetHeight(height);
	else
		-- Set the height of the listframe
		listFrame:SetHeight((index * L_UIDROPDOWNMENUQUESTIE_BUTTON_HEIGHT) + (L_UIDROPDOWNMENUQUESTIE_BORDER_HEIGHT * 2));	
	end

	return button;
end

function lib:UIDropDownMenu_CheckAddCustomFrame(self, button, info)
	local customFrame = info.customFrame;
	button.customFrame = customFrame;
	if customFrame then
		customFrame:SetOwningButton(button);
		customFrame:ClearAllPoints();
		customFrame:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0);
		customFrame:Show();

		lib:UIDropDownMenu_RegisterCustomFrame(self, customFrame);
	end
end

function lib:UIDropDownMenu_RegisterCustomFrame(self, customFrame)
	self.customFrames = self.customFrames or {}
	table.insert(self.customFrames, customFrame);
end

function lib:UIDropDownMenu_GetMaxButtonWidth(self)
	local maxWidth = 0;
	for i=1, self.numButtons do
		local button = envTable[self:GetName().."Button"..i];
		local width = lib:UIDropDownMenu_GetButtonWidth(button);
		if ( width > maxWidth ) then
			maxWidth = width;
		end
	end
	return maxWidth;
end

function lib:UIDropDownMenu_GetButtonWidth(button)
	local minWidth = button.minWidth or 0;
	if button.customFrame and button.customFrame:IsShown() then
		return math.max(minWidth, button.customFrame:GetPreferredEntryWidth());
	end

	if not button:IsShown() then
		return 0;
	end

	local width;
	local buttonName = button:GetName();
	local icon = envTable[buttonName.."Icon"];
	local normalText = envTable[buttonName.."NormalText"];

	if ( button.iconOnly and icon ) then
		width = icon:GetWidth();
	elseif ( normalText and normalText:GetText() ) then
		width = normalText:GetWidth() + 40;

		if ( button.icon ) then
			-- Add padding for the icon
			width = width + 10;
		end
		if ( button.classicChecks ) then
			width = width + L_UIDROPDOWNMENUQUESTIE_CLASSIC_CHECK_PADDING;
		end
	else
		return minWidth;
	end

	-- Add padding if has and expand arrow or color swatch
	if ( button.hasArrow or button.hasColorSwatch ) then
		width = width + 10;
	end
	if ((isRetail or isClassicForever) and button.showNewLabel and button.NewFeature) then
		width = width + button.NewFeature.Label:GetUnboundedStringWidth();
	end
	if ( button.notCheckable ) then
		width = width - 30;
	end
	if ( button.padding ) then
		width = width + button.padding;
	end

	return math.max(minWidth, width);
end

function lib:UIDropDownMenu_Refresh(frame, useValue, dropdownLevel)
	local maxWidth = 0;
	local somethingChecked = nil; 
	if ( not dropdownLevel ) then
		dropdownLevel = L_UIDROPDOWNMENUQUESTIE_MENU_LEVEL;
	end

	local listFrame = envTable["L_DropDownListQuestie"..dropdownLevel];
	listFrame.numButtons = listFrame.numButtons or 0;
	-- Just redraws the existing menu
	for i=1, L_UIDROPDOWNMENUQUESTIE_MAXBUTTONS do
		local button = envTable["L_DropDownListQuestie"..dropdownLevel.."Button"..i];
		local checked = nil;

		if(i <= listFrame.numButtons) then
			-- See if checked or not
			if ( lib:UIDropDownMenu_GetSelectedName(frame) ) then
				if ( button:GetText() == lib:UIDropDownMenu_GetSelectedName(frame) ) then
					checked = 1;
				end
			elseif ( lib:UIDropDownMenu_GetSelectedID(frame) ) then
				if ( button:GetID() == lib:UIDropDownMenu_GetSelectedID(frame) ) then
					checked = 1;
				end
			elseif ( lib:UIDropDownMenu_GetSelectedValue(frame) ) then
				if ( button.value == lib:UIDropDownMenu_GetSelectedValue(frame) ) then
					checked = 1;
				end
			end
		end
		if (button.checked and type(button.checked) == "function") then
			checked = button.checked(button);
		end

		if not button.notCheckable and button:IsShown() then
			-- If checked show check image
			local checkImage = envTable["L_DropDownListQuestie"..dropdownLevel.."Button"..i.."Check"];
			local uncheckImage = envTable["L_DropDownListQuestie"..dropdownLevel.."Button"..i.."UnCheck"];
			if ( checked ) then
				if not button.ignoreAsMenuSelection then
					somethingChecked = true;
					local icon = GetChild(frame, frame:GetName(), "Icon");
					if (button.iconOnly and icon and button.icon) then
						lib:UIDropDownMenu_SetIconImage(icon, button.icon, button.iconInfo);
					elseif ( useValue ) then
						lib:UIDropDownMenu_SetText(frame, button.value);
						icon:Hide();
					else
						lib:UIDropDownMenu_SetText(frame, button:GetText());
						icon:Hide();
					end
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

		if ((isRetail or isClassicForever) and button.NewFeature) then
			local normalText = envTable[button:GetName().."NormalText"];
			button.NewFeature:SetShown(button.showNewLabel);
			button.NewFeature:SetPoint("LEFT", normalText, "RIGHT", 20, 0);
		end

		if ( button:IsShown() ) then
			local width = lib:UIDropDownMenu_GetButtonWidth(button);
			if ( width > maxWidth ) then
				maxWidth = width;
			end
		end
	end
	if(somethingChecked == nil) then
		lib:UIDropDownMenu_SetText(frame, VIDEO_QUALITY_LABEL6);
		local icon = GetChild(frame, frame:GetName(), "Icon");
		icon:Hide();
	end
	if (not frame.noResize) then
		for i=1, L_UIDROPDOWNMENUQUESTIE_MAXBUTTONS do
			local button = envTable["L_DropDownListQuestie"..dropdownLevel.."Button"..i];
			button:SetWidth(maxWidth);
		end
		lib:UIDropDownMenu_RefreshDropDownSize(envTable["L_DropDownListQuestie"..dropdownLevel]);
	end
end

function lib:UIDropDownMenu_RefreshAll(frame, useValue)
	for dropdownLevel = L_UIDROPDOWNMENUQUESTIE_MENU_LEVEL, 2, -1 do
		local listFrame = envTable["L_DropDownListQuestie"..dropdownLevel];
		if ( listFrame:IsShown() ) then
			lib:UIDropDownMenu_Refresh(frame, nil, dropdownLevel);
		end
	end
	-- useValue is the text on the dropdown, only needs to be set once
	lib:UIDropDownMenu_Refresh(frame, useValue, 1);
end

function lib:UIDropDownMenu_SetIconImage(icon, texture, info)
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

function lib:UIDropDownMenu_SetSelectedName(frame, name, useValue)
	frame.selectedName = name;
	frame.selectedID = nil;
	frame.selectedValue = nil;
	lib:UIDropDownMenu_Refresh(frame, useValue);
end

function lib:UIDropDownMenu_SetSelectedValue(frame, value, useValue)
	-- useValue will set the value as the text, not the name
	frame.selectedName = nil;
	frame.selectedID = nil;
	frame.selectedValue = value;
	lib:UIDropDownMenu_Refresh(frame, useValue);
end

function lib:UIDropDownMenu_SetSelectedID(frame, id, useValue)
	frame.selectedID = id;
	frame.selectedName = nil;
	frame.selectedValue = nil;
	lib:UIDropDownMenu_Refresh(frame, useValue);
end

function lib:UIDropDownMenu_GetSelectedName(frame)
	return frame.selectedName;
end

function lib:UIDropDownMenu_GetSelectedID(frame)
	if ( frame.selectedID ) then
		return frame.selectedID;
	else
		local selectedName = lib:UIDropDownMenu_GetSelectedName(frame);
		local selectedValue = lib:UIDropDownMenu_GetSelectedValue(frame);
		if ( not selectedName and not selectedValue ) then
			return nil;
		end
		-- If no explicit selectedID then try to send the id of a selected value or name
--[[		local maxNum;
		if (isAnyClassic) then
			maxNum = L_UIDROPDOWNMENUQUESTIE_MAXBUTTONS
		else
			local listFrame = envTable["L_DropDownListQuestie"..L_UIDROPDOWNMENUQUESTIE_MENU_LEVEL];
			maxNum = listFrame.numButtons
		end
		for i=1, maxNum do]]
		local listFrame = envTable["L_DropDownListQuestie"..L_UIDROPDOWNMENUQUESTIE_MENU_LEVEL];
		for i=1, listFrame.numButtons do
			local button = envTable["L_DropDownListQuestie"..L_UIDROPDOWNMENUQUESTIE_MENU_LEVEL.."Button"..i];
			-- See if checked or not
			if ( selectedName ) then
				if ( button:GetText() == selectedName ) then
					return i;
				end
			elseif ( selectedValue ) then
				if ( button.value == selectedValue ) then
					return i;
				end
			end
		end
	end
end

function lib:UIDropDownMenu_GetSelectedValue(frame)
	return frame.selectedValue;
end

function lib:HideDropDownMenu(level)
	local listFrame = envTable["L_DropDownListQuestie"..level];
	listFrame:Hide();
end

function lib:ToggleDropDownMenu(level, value, dropDownFrame, anchorName, xOffset, yOffset, menuList, button, autoHideDelay, overrideDisplayMode)
	if ( not level ) then
		level = 1;
	end
	delegateFrame:SetAttribute("createframes-level", level);
	delegateFrame:SetAttribute("createframes-index", 0);
	delegateFrame:SetAttribute("createframes", true);
	L_UIDROPDOWNMENUQUESTIE_MENU_LEVEL = level;
	L_UIDROPDOWNMENUQUESTIE_MENU_VALUE = value;
	local listFrameName = "L_DropDownListQuestie"..level;
	local listFrame = envTable[listFrameName];
	if (isRetail or isClassicForever) then
		lib:UIDropDownMenu_ClearCustomFrames(listFrame);
	end
	
	local tempFrame;
	local point, relativePoint, relativeTo;
	if ( not dropDownFrame ) then
		tempFrame = button:GetParent();
	else
		tempFrame = dropDownFrame;
	end
	if ( listFrame:IsShown() and (L_UIDROPDOWNMENUQUESTIE_OPEN_MENU == tempFrame) ) then
		listFrame:Hide();
		return false;
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
			delegateFrame:SetAttribute("openmenu", dropDownFrame);
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
					relativeTo = GetChild(L_UIDROPDOWNMENUQUESTIE_OPEN_MENU, L_UIDROPDOWNMENUQUESTIE_OPEN_MENU:GetName(), "Left");
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
				dropDownFrame = L_UIDROPDOWNMENUQUESTIE_OPEN_MENU;
			end
			listFrame:ClearAllPoints();
			-- If this is a dropdown button, not the arrow anchor it to itself
			if ( strsub(button:GetParent():GetName(), 1,21) == "L_DropDownListQuestie" and strlen(button:GetParent():GetName()) == 22 ) then
				anchorFrame = button;
			else
				anchorFrame = button:GetParent();
			end
			point = "TOPLEFT";
			relativePoint = "TOPRIGHT";
			listFrame:SetPoint(point, anchorFrame, relativePoint, 0, 0);
		end

		if dropDownFrame.hideBackdrops then
			envTable[listFrameName.."Backdrop"]:Hide();
			envTable[listFrameName.."MenuBackdrop"]:Hide();
		else
			-- Change list box appearance depending on display mode
			local displayMode = overrideDisplayMode or (dropDownFrame and dropDownFrame.displayMode) or nil;
			if ( displayMode == "MENU" ) then
				envTable[listFrameName.."Backdrop"]:Hide();
				envTable[listFrameName.."MenuBackdrop"]:Show();
			else
				envTable[listFrameName.."Backdrop"]:Show();
				envTable[listFrameName.."MenuBackdrop"]:Hide();
			end
		end
		if (isAnyClassic) then
			dropDownFrame.menuList = menuList;
		end

		lib:UIDropDownMenu_Initialize(dropDownFrame, dropDownFrame.initialize, nil, level, menuList);
		-- If no items in the drop down don't show it
		if ( listFrame.numButtons == 0 ) then
			return false;
		end

		if (isRetail or isClassicForever) then
			listFrame.onShow = dropDownFrame.listFrameOnShow;
		end

		-- Check to see if the dropdownlist is off the screen, if it is anchor it to the top of the dropdown button
		listFrame:Show();
		-- Hack since GetCenter() is returning coords relative to 1024x768
		local x, y = listFrame:GetCenter();
		-- Hack will fix this in next revision of dropdowns
		if ( not x or not y ) then
			listFrame:Hide();
			return false;
		end

		listFrame.onHide = dropDownFrame.onHide;

		-- Set the listframe frameStrata
		if dropDownFrame.listFrameStrata then
			listFrame.baseFrameStrata = listFrame:GetFrameStrata();
			listFrame:SetFrameStrata(dropDownFrame.listFrameStrata);
		end

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
				xOffset = -11;
				yOffset = -14;
			elseif ( offscreenY ) then
				point = gsub(point, "TOP(.*)", "BOTTOM%1");
				relativePoint = gsub(relativePoint, "TOP(.*)", "BOTTOM%1");
				xOffset = 0;
				yOffset = -14;
			elseif ( offscreenX ) then
				point = gsub(point, "(.*)LEFT", "%1RIGHT");
				relativePoint = gsub(relativePoint, "(.*)RIGHT", "%1LEFT");
				xOffset = -11;
				yOffset = 14;
			else
				xOffset = 0;
				yOffset = 14;
			end

			listFrame:ClearAllPoints();
			listFrame.parentLevel = tonumber(strmatch(anchorFrame:GetName(), "L_DropDownListQuestie(%d+)"));
			listFrame.parentID = anchorFrame:GetID();
			listFrame:SetPoint(point, anchorFrame, relativePoint, xOffset, yOffset);
		end

		if (isAnyClassic) then
			if ( autoHideDelay and tonumber(autoHideDelay)) then
				listFrame.showTimer = autoHideDelay;
				listFrame.isCounting = 1;
			end
		end
		return true;
	end
end

function lib:CloseDropDownMenus(level)
	if ( not level ) then
		level = 1;
	end
	for i=level, L_UIDROPDOWNMENUQUESTIE_MAXLEVELS do
		envTable["L_DropDownListQuestie"..i]:Hide();
	end
	-- yes, we also want to close the menus which created by built-in UIDropDownMenus
	for i=level, UIDROPDOWNMENU_MAXLEVELS do
		envTable["DropDownList"..i]:Hide();
	end
end

local function containsMouse()
	local result = false
	
	for i = 1, L_UIDROPDOWNMENUQUESTIE_MAXLEVELS do
		local dropdown = envTable["L_DropDownListQuestie"..i];
		if dropdown:IsShown() and dropdown:IsMouseOver() then
			result = true;
		end
	end
	for i = 1, UIDROPDOWNMENU_MAXLEVELS do
		local dropdown = envTable["DropDownList"..i];
		if dropdown:IsShown() and dropdown:IsMouseOver() then
			result = true;
		end
	end
	-- TeeloJubeithos: 
	--   If the menu is open, and you click the button to close it, 
	--   the Global Mouse Down triggers to close it, but then the MouseDown for the button triggers to open it back up again.
	--   I fixed this by adding a filter to the global mouse down check, don't count it if the mouse is still over the DropDownMenu's Button
	if L_UIDROPDOWNMENUQUESTIE_OPEN_MENU and L_UIDROPDOWNMENUQUESTIE_OPEN_MENU.Button:IsMouseOver() then
		result = true;
	end

	return result;
end

function lib:containsMouse()
	containsMouse()
end

-- GLOBAL_MOUSE_DOWN event is only available in retail, not classic
function lib:UIDropDownMenu_HandleGlobalMouseEvent(button, event)
	if event == "GLOBAL_MOUSE_DOWN" and (button == "LeftButton" or button == "RightButton") then
		if not containsMouse() then
			lib:CloseDropDownMenus();
		end
	end
end

-- hooking UIDropDownMenu_HandleGlobalMouseEvent
do
	if lib and (isRetail or isClassicForever) then
		hooksecurefunc("UIDropDownMenu_HandleGlobalMouseEvent", function(button, event) 
			lib:UIDropDownMenu_HandleGlobalMouseEvent(button, event) 
		end)

	end
end

function lib:UIDropDownMenu_ClearCustomFrames(self)
	if self.customFrames then
		for index, frame in ipairs(self.customFrames) do
			frame:Hide();
		end

		self.customFrames = nil;
	end
end

function lib:UIDropDownMenu_MatchTextWidth(frame, minWidth, maxWidth)
	local frameName = frame:GetName();
	local newWidth = GetChild(frame, frameName, "Text"):GetUnboundedStringWidth() + L_UIDROPDOWNMENUQUESTIE_DEFAULT_WIDTH_PADDING;
	
	if minWidth or maxWidth then
		newWidth = Clamp(newWidth, minWidth or newWidth, maxWidth or newWidth);
	end

	lib:UIDropDownMenu_SetWidth(frame, newWidth);
end

function lib:UIDropDownMenu_SetWidth(frame, width, padding)
	local frameName = frame:GetName();
	GetChild(frame, frameName, "Middle"):SetWidth(width);
	if ( padding ) then
		frame:SetWidth(width + padding);
	else
		frame:SetWidth(width + L_UIDROPDOWNMENUQUESTIE_DEFAULT_WIDTH_PADDING + L_UIDROPDOWNMENUQUESTIE_DEFAULT_WIDTH_PADDING);
	end
	if ( padding ) then
		GetChild(frame, frameName, "Text"):SetWidth(width);
	else
		GetChild(frame, frameName, "Text"):SetWidth(width - L_UIDROPDOWNMENUQUESTIE_DEFAULT_WIDTH_PADDING);
	end
	frame.noResize = 1;
end

function lib:UIDropDownMenu_SetButtonWidth(frame, width)
	local frameName = frame:GetName();
	if ( width == "TEXT" ) then
		width = GetChild(frame, frameName, "Text"):GetWidth();
	end

	GetChild(frame, frameName, "Button"):SetWidth(width);
	frame.noResize = 1;
end

function lib:UIDropDownMenu_SetText(frame, text)
	local frameName = frame:GetName();
	GetChild(frame, frameName, "Text"):SetText(text);
end

function lib:UIDropDownMenu_GetText(frame)
	local frameName = frame:GetName();
	return GetChild(frame, frameName, "Text"):GetText();
end

function lib:UIDropDownMenu_ClearAll(frame)
	-- Previous code refreshed the menu quite often and was a performance bottleneck
	frame.selectedID = nil;
	frame.selectedName = nil;
	frame.selectedValue = nil;
	lib:UIDropDownMenu_SetText(frame, "");

	local button, checkImage, uncheckImage;
	for i=1, L_UIDROPDOWNMENUQUESTIE_MAXBUTTONS do
		button = envTable["L_DropDownListQuestie"..L_UIDROPDOWNMENUQUESTIE_MENU_LEVEL.."Button"..i];
		button:UnlockHighlight();

		checkImage = envTable["L_DropDownListQuestie"..L_UIDROPDOWNMENUQUESTIE_MENU_LEVEL.."Button"..i.."Check"];
		checkImage:Hide();
		uncheckImage = envTable["L_DropDownListQuestie"..L_UIDROPDOWNMENUQUESTIE_MENU_LEVEL.."Button"..i.."UnCheck"];
		uncheckImage:Hide();
	end
end

function lib:UIDropDownMenu_JustifyText(frame, justification, customXOffset, customYOffset)
	local frameName = frame:GetName();
	local text = GetChild(frame, frameName, "Text");
	text:ClearAllPoints();
	if ( justification == "LEFT" ) then
		text:SetPoint("LEFT", GetChild(frame, frameName, "Left"), "LEFT", customXOffset or 27, customYOffset or 2);
		text:SetJustifyH("LEFT");
	elseif ( justification == "RIGHT" ) then
		text:SetPoint("RIGHT", GetChild(frame, frameName, "Right"), "RIGHT", customXOffset or -43, customYOffset or 2);
		text:SetJustifyH("RIGHT");
	elseif ( justification == "CENTER" ) then
		text:SetPoint("CENTER", GetChild(frame, frameName, "Middle"), "CENTER", customXOffset or -5, customYOffset or 2);
		text:SetJustifyH("CENTER");
	end
end

function lib:UIDropDownMenu_SetAnchor(dropdown, xOffset, yOffset, point, relativeTo, relativePoint)
	dropdown.xOffset = xOffset;
	dropdown.yOffset = yOffset;
	dropdown.point = point;
	dropdown.relativeTo = relativeTo;
	dropdown.relativePoint = relativePoint;
end

function lib:UIDropDownMenu_GetCurrentDropDown()
	if ( L_UIDROPDOWNMENUQUESTIE_OPEN_MENU ) then
		return L_UIDROPDOWNMENUQUESTIE_OPEN_MENU;
	elseif ( L_UIDROPDOWNMENUQUESTIE_INIT_MENU ) then
		return L_UIDROPDOWNMENUQUESTIE_INIT_MENU;
	end
end

function lib:UIDropDownMenuButton_GetChecked(self)
	return envTable[self:GetName().."Check"]:IsShown();
end

function lib:UIDropDownMenuButton_GetName(self)
	return envTable[self:GetName().."NormalText"]:GetText();
end

function lib:UIDropDownMenuButton_OpenColorPicker(self, button)
	securecall("CloseMenus");
	if ( not button ) then
		button = self;
	end
	L_UIDROPDOWNMENUQUESTIE_MENU_VALUE = button.value;
	if (isRetail or isClassicForever or isProgressionClassic) then
		ColorPickerFrame:SetupColorPickerAndShow(button);
	else
		lib:OpenColorPicker(button); 
	end
end

function lib:UIDropDownMenu_DisableButton(level, id)
	lib:UIDropDownMenu_SetDropdownButtonEnabled(envTable["DropDownList"..level.."Button"..id], false);
end

function lib:UIDropDownMenu_EnableButton(level, id)
	lib:UIDropDownMenu_SetDropdownButtonEnabled(envTable["DropDownList"..level.."Button"..id], true);
end

function lib:UIDropDownMenu_SetDropdownButtonEnabled(button, enabled)
	if enabled then
		button:Enable();
	else
		button:Disable();
	end
end

function lib:UIDropDownMenu_SetButtonText(level, id, text, colorCode)
	local button = envTable["L_DropDownListQuestie"..level.."Button"..id];
	if ( colorCode) then
		button:SetText(colorCode..text.."|r");
	else
		button:SetText(text);
	end
end

function lib:UIDropDownMenu_SetButtonNotClickable(level, id)
	envTable["L_DropDownListQuestie"..level.."Button"..id]:SetDisabledFontObject(GameFontHighlightSmallLeft);
end

function lib:UIDropDownMenu_SetButtonClickable(level, id)
	envTable["L_DropDownListQuestie"..level.."Button"..id]:SetDisabledFontObject(GameFontDisableSmallLeft);
end


function lib:UIDropDownMenu_DisableDropDown(dropDown)
	lib:UIDropDownMenu_SetDropDownEnabled(dropDown, false, disabledtooltip);
end

function lib:UIDropDownMenu_EnableDropDown(dropDown)
	lib:UIDropDownMenu_SetDropDownEnabled(dropDown, true);
end

function lib:UIDropDownMenu_SetDropDownEnabled(dropDown, enabled, disabledtooltip)
	local dropDownName = dropDown:GetName();
	local label = GetChild(dropDown, dropDownName, "Label");
	if label then
		label:SetVertexColor((enabled and NORMAL_FONT_COLOR or GRAY_FONT_COLOR):GetRGB());
	end

	local icon = GetChild(dropDown, dropDownName, "Icon");
	if icon then
		icon:SetVertexColor((enabled and HIGHLIGHT_FONT_COLOR or GRAY_FONT_COLOR):GetRGB());
	end

	local text = GetChild(dropDown, dropDownName, "Text");
	if text then
		text:SetVertexColor((enabled and HIGHLIGHT_FONT_COLOR or GRAY_FONT_COLOR):GetRGB());
	end

	local button = GetChild(dropDown, dropDownName, "Button");
	if button then
		button:SetEnabled(enabled);

		-- Clear any previously set disabledTooltip (it will be reset below if needed).
		if button:GetMotionScriptsWhileDisabled() then
			button:SetMotionScriptsWhileDisabled(false);
			button:SetScript("OnEnter", nil);
			button:SetScript("OnLeave", nil);
		end
	end

	if enabled then
		dropDown.isDisabled = nil;
	else
		dropDown.isDisabled = 1;

		if button then
			if disabledTooltip then
				button:SetMotionScriptsWhileDisabled(true);
				button:SetScript("OnEnter", function()
					GameTooltip:SetOwner(button, "ANCHOR_RIGHT");
					GameTooltip_AddErrorLine(GameTooltip, disabledTooltip);
					GameTooltip:Show();
				end);

				button:SetScript("OnLeave", GameTooltip_Hide);
			end
		end
	end
end

function lib:UIDropDownMenu_IsEnabled(dropDown)
	return not dropDown.isDisabled;
end

function lib:UIDropDownMenu_GetValue(id)
	--Only works if the dropdown has just been initialized, lame, I know =(
	local button = envTable["L_DropDownListQuestie1Button"..id];
	if ( button ) then
		return envTable["L_DropDownListQuestie1Button"..id].value;
	else
		return nil;
	end
end

function lib:OpenColorPicker(info)
	if (isRetail or isClassicForever or isProgressionClassic) then
		ColorPickerFrame:SetupColorPickerAndShow(info);
	else
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
end

function lib:ColorPicker_GetPreviousValues()
	if (isRetail or isClassicForever or isProgressionClassic) then
		local r, g, b = ColorPickerFrame:GetPreviousValues();
		return r, g, b;
	else
		return ColorPickerFrame.previousValues.r, ColorPickerFrame.previousValues.g, ColorPickerFrame.previousValues.b;
	end
end

-- //////////////////////////////////////////////////////////////
-- LibUIDropDownMenuTemplates
-- //////////////////////////////////////////////////////////////

-- Custom dropdown buttons are instantiated by some external system.
-- When calling L_UIDropDownMenu_AddButton that system sets info.customFrame to the instance of the frame it wants to place on the menu.
-- The dropdown menu creates its button for the entry as it normally would, but hides all elements.  The custom frame is then anchored
-- to that button and assumes responsibility for all relevant dropdown menu operations.
-- The hidden button will request a size that it should become from the custom frame.

lib.DropDownMenuButtonMixin = {}

function lib.DropDownMenuButtonMixin:OnEnter(...)
	ExecuteFrameScript(self:GetParent(), "OnEnter", ...);
end

function lib.DropDownMenuButtonMixin:OnLeave(...)
	ExecuteFrameScript(self:GetParent(), "OnLeave", ...);
end

function lib.DropDownMenuButtonMixin:OnMouseDown(button)
	if self:IsEnabled() then
		lib:ToggleDropDownMenu(nil, nil, self:GetParent());
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	end
end

lib.LargeDropDownMenuButtonMixin = CreateFromMixins(lib.DropDownMenuButtonMixin);

function lib.LargeDropDownMenuButtonMixin:OnMouseDown(button)
	if self:IsEnabled() then
		local parent = self:GetParent();
		lib:ToggleDropDownMenu(nil, nil, parent, parent, -8, 8);
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	end
end

lib.DropDownExpandArrowMixin = {};

function lib.DropDownExpandArrowMixin:OnEnter()
	local level =  self:GetParent():GetParent():GetID() + 1;

	lib:CloseDropDownMenus(level);

	if self:IsEnabled() then
		local listFrame = envTable["L_DropDownListQuestie"..level];
		if ( not listFrame or not listFrame:IsShown() or select(2, listFrame:GetPoint()) ~= self ) then
			lib:ToggleDropDownMenu(level, self:GetParent().value, nil, nil, nil, nil, self:GetParent().menuList, self, nil, self:GetParent().menuListDisplayMode);
		end
	end
end

function lib.DropDownExpandArrowMixin:OnMouseDown(button)
	if self:IsEnabled() then
		lib:ToggleDropDownMenu(self:GetParent():GetParent():GetID() + 1, self:GetParent().value, nil, nil, nil, nil, self:GetParent().menuList, self, nil, self:GetParent().menuListDisplayMode);
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	end
end

lib.UIDropDownCustomMenuEntryMixin = {};

function lib.UIDropDownCustomMenuEntryMixin:GetPreferredEntryWidth()
	return self:GetWidth();
end

function lib.UIDropDownCustomMenuEntryMixin:GetPreferredEntryHeight()
	return self:GetHeight();
end

function lib.UIDropDownCustomMenuEntryMixin:OnSetOwningButton()
	-- for derived objects to implement
end

function lib.UIDropDownCustomMenuEntryMixin:SetOwningButton(button)
	self:SetParent(button:GetParent());
	self.owningButton = button;
	self:OnSetOwningButton();
end

function lib.UIDropDownCustomMenuEntryMixin:GetOwningDropdown()
	return self.owningButton:GetParent();
end

function lib.UIDropDownCustomMenuEntryMixin:SetContextData(contextData)
	self.contextData = contextData;
end

function lib.UIDropDownCustomMenuEntryMixin:GetContextData()
	return self.contextData;
end


lib.ColorSwatchMixin = {}

function lib.ColorSwatchMixin:SetColor(color)
	self.Color:SetVertexColor(color:GetRGB());
end

-- //////////////////////////////////////////////////////////////
-- L_UIDropDownCustomMenuEntryTemplate
function lib:Create_UIDropDownCustomMenuEntry(name, parent)
	local f = envTable[name] or CreateFrame("Frame", name, parent or nil)
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

-- //////////////////////////////////////////////////////////////
-- UIDropDownMenuButtonScriptTemplate
--
-- TBD
--

-- //////////////////////////////////////////////////////////////
-- LargeUIDropDownMenuTemplate
--
-- TBD
--

-- //////////////////////////////////////////////////////////////
-- EasyMenu
-- Simplified Menu Display System
--	This is a basic system for displaying a menu from a structure table.
--
--	Args:
--		menuList - menu table
--		menuFrame - the UI frame to populate
--		anchor - where to anchor the frame (e.g. CURSOR)
--		x - x offset
--		y - y offset
--		displayMode - border type
--		autoHideDelay - how long until the menu disappears
local function easyMenu_Initialize( frame, level, menuList )
	for index = 1, #menuList do
		local value = menuList[index]
		if (value.text) then
			value.index = index;
			lib:UIDropDownMenu_AddButton( value, level );
		end
	end
end

function lib:EasyMenu(menuList, menuFrame, anchor, x, y, displayMode, autoHideDelay )
	if ( displayMode == "MENU" ) then
		menuFrame.displayMode = displayMode;
	end
	lib:UIDropDownMenu_Initialize(menuFrame, easyMenu_Initialize, displayMode, nil, menuList);
	lib:ToggleDropDownMenu(1, nil, menuFrame, anchor, x, y, menuList, nil, autoHideDelay);
end

function lib:EasyMenu_Initialize( frame, level, menuList )
	easyMenu_Initialize( frame, level, menuList )
end

