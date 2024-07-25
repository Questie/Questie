---@diagnostic disable: undefined-global
--[[
	Krowi's World Map Buttons License
		Copyright ©2020 The contents of this library, excluding third-party resources, are
		copyrighted to their authors with all rights reserved.

		This library is free to use and the authors hereby grants you the following rights:

		1. 	You may make modifications to this library for private use only, you
			may not publicize any portion of this library. The only exception being you may
			upload to the github website.

		2. 	Do not modify the name of this library, including the library folders.

		3. 	This copyright notice shall be included in all copies or substantial
			portions of the Software.

		All rights not explicitly addressed in this license are reserved by
		the copyright holders.
]]

local lib = LibStub:NewLibrary('Krowi_WorldMapButtons-1.4', 5);

if not lib then
	return;
end

local version = (GetBuildInfo());
local major = string.match(version, "(%d+)%.(%d+)%.(%d+)(%w?)");
lib.IsClassic = major == "1";
lib.IsTbcClassic = major == "2";
lib.IsWrathClassic = major == "3";
lib.IsDragonflightRetail = major == "10";
lib.HasNoOverlay = lib.IsClassic or lib.IsTbcClassic or lib.IsWrathClassic;

local AddButton;
local function Fix1_3_1Buttons()
	local old = LibStub("Krowi_WorldMapButtons-1.3", true);
	if old then
		local children = { WorldMapFrame:GetChildren() };
		for i, child in ipairs(children) do
			local p, _, rp, x, y = child:GetPoint(1);
			if x and y and x <= -68 and y == -2 and child:GetName() == nil then
				AddButton(child);
			end
		end
	end

	Fix1_3_1Buttons = function() end;
end

local function Fix1_4_3Buttons()
	if lib.HasNoOverlay then
		for _, button in next, lib.Buttons do
			button:SetParent(WorldMapFrame.ScrollContainer);
			button:SetFrameStrata("TOOLTIP");
		end
	end

	Fix1_4_3Buttons = function() end;
end

lib.XOffset, lib.YOffset = 4, -2;
function lib:SetOffsets(xOffset, yOffset)
	self.XOffset = xOffset or self.XOffset;
	self.YOffset = yOffset or self.YOffset;
end

function lib.SetPoints()
	Fix1_3_1Buttons();
	Fix1_4_3Buttons();

	local xOffset = lib.XOffset;
	for _, button in next, lib.Buttons do
		if button:IsShown() then
			button:SetPoint("TOPRIGHT", button.relativeFrame, -xOffset, lib.YOffset);
			xOffset = xOffset + 32;
		end
	end
end

local function HookDefaultButtons()
	if WorldMapFrame.overlayFrames == nil then
		lib.HookedDefaultButtons = true;
		return;
	end

	for _, f in next, WorldMapFrame.overlayFrames do
        if WorldMapTrackingOptionsButtonMixin and f.OnLoad == WorldMapTrackingOptionsButtonMixin.OnLoad then
			f.KrowiWorldMapButtonsIndex = #lib.Buttons;
			tinsert(lib.Buttons, f);
        end
        if WorldMapTrackingPinButtonMixin and f.OnLoad == WorldMapTrackingPinButtonMixin.OnLoad then
			f.KrowiWorldMapButtonsIndex = #lib.Buttons;
			tinsert(lib.Buttons, f);
        end
    end

	lib.HookedDefaultButtons = true;
end

local function PatchWrathClassic()
	if lib.HasNoOverlay and WorldMapFrame.RefreshOverlayFrames == nil then
		WorldMapFrame.RefreshOverlayFrames = function()
		end
	end

	PatchWrathClassic = function() end;
end

function AddButton(button)
	local xOffset = 4 + lib.NumButtons * 32;
	button:SetPoint("TOPRIGHT", WorldMapFrame:GetCanvasContainer(), "TOPRIGHT", -xOffset, -2);
	button.relativeFrame = WorldMapFrame:GetCanvasContainer();
	hooksecurefunc(WorldMapFrame, lib.HasNoOverlay and "OnMapChanged" or "RefreshOverlayFrames", function()
		button:Refresh();
		lib.SetPoints();
	end);

	tinsert(lib.Buttons, button);

	return button;
end

function lib:Add(templateName, templateType)
	if self.Buttons == nil then
		self.Buttons = self.buttons or {}; -- 'Krowi_WorldMapButtons-1.4', 1 compatibility
		if NumKrowi_WorldMapButtons then
			NumKrowi_WorldMapButtons = NumKrowi_WorldMapButtons - 1; -- 'Krowi_WorldMapButtons-1.4', 1 compatibility
		end
		self.NumButtons = NumKrowi_WorldMapButtons or 0; -- 'Krowi_WorldMapButtons-1.4', 1 compatibility
	end

	if not self.HookedDefaultButtons then
		HookDefaultButtons();
	end

	PatchWrathClassic();

	self.NumButtons = self.NumButtons + 1;
	local button = CreateFrame(templateType, "Krowi_WorldMapButtons" .. self.NumButtons, lib.HasNoOverlay and WorldMapFrame.ScrollContainer or WorldMapFrame, templateName);

	if lib.HasNoOverlay then
		button:SetFrameStrata("TOOLTIP");
	end

	return AddButton(button);
end