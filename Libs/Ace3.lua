
-- This file is only there in standalone Ace3 and provides handy dev tool stuff I guess
-- for now only /rl to reload your UI :)
-- note the complete overkill use of AceAddon and console, ain't it cool?

-- GLOBALS: next, loadstring, ReloadUI, geterrorhandler
-- GLOBALS: BINDING_HEADER_ACE3, BINDING_NAME_RELOADUI, Ace3, LibStub

-- BINDINGs labels
BINDING_HEADER_ACE3 = "Ace3"
BINDING_NAME_RELOADUI = "ReloadUI"
--

local gui = LibStub("AceGUI-3.0")
local reg = LibStub("AceConfigRegistry-3.0")
local dialog = LibStub("AceConfigDialog-3.0")

Ace3 = LibStub("AceAddon-3.0"):NewAddon("Ace3", "AceConsole-3.0")
local Ace3 = Ace3

local selectedgroup
local frame
local select
local status = {}
local configs = {}

local function frameOnClose()
	gui:Release(frame)
	frame = nil
end

local function RefreshConfigs()
	for name in reg:IterateOptionsTables() do
		configs[name] = name
	end
end

local function ConfigSelected(widget, event, value)
	selectedgroup = value
	dialog:Open(value, widget)
end

local old_CloseSpecialWindows

-- GLOBALS: CloseSpecialWindows, next
function Ace3:Open()
	if not old_CloseSpecialWindows then
		old_CloseSpecialWindows = CloseSpecialWindows
		CloseSpecialWindows = function()
			local found = old_CloseSpecialWindows()
			if frame then
				frame:Hide()
				return true
			end
			return found
		end
	end
	RefreshConfigs()
	if next(configs) == nil then
		self:Print("No Configs are Registered")
		return
	end
	
	if not frame then
		frame = gui:Create("Frame")
		frame:ReleaseChildren()
		frame:SetTitle("Ace3 Options")
		frame:SetLayout("FILL")
		frame:SetCallback("OnClose", frameOnClose)
	
		select = gui:Create("DropdownGroup")
		select:SetGroupList(configs)
		select:SetCallback("OnGroupSelected", ConfigSelected)
		frame:AddChild(select)
	end
	if not selectedgroup then
		selectedgroup = next(configs)
	end
	select:SetGroup(selectedgroup)
	frame:Show()
end

local function RefreshOnUpdate(this)
	select:SetGroup(selectedgroup)
	this:SetScript("OnUpdate", nil)
end

function Ace3:ConfigTableChanged(event, appName)
	if selectedgroup == appName and frame then
		frame.frame:SetScript("OnUpdate", RefreshOnUpdate)
	end
end

reg.RegisterCallback(Ace3, "ConfigTableChange", "ConfigTableChanged")

function Ace3:PrintCmd(input)
	input = input:trim():match("^(.-);*$")
	local func, err = loadstring("LibStub(\"AceConsole-3.0\"):Print(" .. input .. ")")
	if not func then
		LibStub("AceConsole-3.0"):Print("Error: " .. err)
	else
		func()
	end
end

function Ace3:OnInitialize()
	self:RegisterChatCommand("ace3", function() self:Open() end)
	self:RegisterChatCommand("rl", function() ReloadUI() end)
	self:RegisterChatCommand("print", "PrintCmd")
end
