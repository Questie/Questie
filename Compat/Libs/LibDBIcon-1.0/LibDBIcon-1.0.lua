--[[
Name: DBIcon-1.0
Revision: $Rev: 15 $
Author(s): Rabbit (rabbit.magtheridon@gmail.com)
Description: Allows addons to register to recieve a lightweight minimap icon as an alternative to more heavy LDB displays.
Dependencies: LibStub
License: GPL v2 or later.
]]

--[[
Copyright (C) 2008-2010 Rabbit

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
]]

-----------------------------------------------------------------------
-- DBIcon-1.0
--
-- Disclaimer: Most of this code was ripped from Barrel but fixed, streamlined
--             and cleaned up a lot so that it no longer sucks.
--

local DBICON10 = "LibDBIcon-1.0"
local DBICON10_MINOR = tonumber(("$Rev: 15 $"):match("(%d+)"))
if not LibStub then error(DBICON10 .. " requires LibStub.") end
local ldb = LibStub("LibDataBroker-1.1", true)
if not ldb then error(DBICON10 .. " requires LibDataBroker-1.1.") end
local lib = LibStub:NewLibrary(DBICON10, DBICON10_MINOR)
if not lib then return end

lib.disabled = lib.disabled or nil
lib.objects = lib.objects or {}
lib.callbackRegistered = lib.callbackRegistered or nil
lib.notCreated = lib.notCreated or {}

function lib:IconCallback(event, name, key, value, dataobj)
	if lib.objects[name] then
		lib.objects[name].icon:SetTexture(dataobj.icon)
	end
end
if not lib.callbackRegistered then
	ldb.RegisterCallback(lib, "LibDataBroker_AttributeChanged__icon", "IconCallback")
	lib.callbackRegistered = true
end

-- Tooltip code ripped from StatBlockCore by Funkydude
local function getAnchors(frame)
	local x, y = frame:GetCenter()
	if not x or not y then return "CENTER" end
	local hhalf = (x > UIParent:GetWidth()*2/3) and "RIGHT" or (x < UIParent:GetWidth()/3) and "LEFT" or ""
	local vhalf = (y > UIParent:GetHeight()/2) and "TOP" or "BOTTOM"
	return vhalf..hhalf, frame, (vhalf == "TOP" and "BOTTOM" or "TOP")..hhalf
end

local function onEnter(self)
	if self.isMoving then return end
	local obj = self.dataObject
	if obj.OnTooltipShow then
		GameTooltip:SetOwner(self, "ANCHOR_NONE")
		GameTooltip:SetPoint(getAnchors(self))
		obj.OnTooltipShow(GameTooltip)
		GameTooltip:Show()
	elseif obj.OnEnter then
		obj.OnEnter(self)
	end
end

local function onLeave(self)
	local obj = self.dataObject
	GameTooltip:Hide()
	if obj.OnLeave then obj.OnLeave(self) end
end

--------------------------------------------------------------------------------

local minimapShapes = {
	["ROUND"] = {true, true, true, true},
	["SQUARE"] = {false, false, false, false},
	["CORNER-TOPLEFT"] = {true, false, false, false},
	["CORNER-TOPRIGHT"] = {false, false, true, false},
	["CORNER-BOTTOMLEFT"] = {false, true, false, false},
	["CORNER-BOTTOMRIGHT"] = {false, false, false, true},
	["SIDE-LEFT"] = {true, true, false, false},
	["SIDE-RIGHT"] = {false, false, true, true},
	["SIDE-TOP"] = {true, false, true, false},
	["SIDE-BOTTOM"] = {false, true, false, true},
	["TRICORNER-TOPLEFT"] = {true, true, true, false},
	["TRICORNER-TOPRIGHT"] = {true, false, true, true},
	["TRICORNER-BOTTOMLEFT"] = {true, true, false, true},
	["TRICORNER-BOTTOMRIGHT"] = {false, true, true, true},
}

local function updatePosition(button)
	local angle = math.rad(button.db and button.db.minimapPos or button.minimapPos or 225)
	local x, y, q = math.cos(angle), math.sin(angle), 1
	if x < 0 then q = q + 1 end
	if y > 0 then q = q + 2 end
	local minimapShape = GetMinimapShape and GetMinimapShape() or "ROUND"
	local quadTable = minimapShapes[minimapShape]
	if quadTable[q] then
		x, y = x*80, y*80
	else
		local diagRadius = 103.13708498985 --math.sqrt(2*(80)^2)-10
		x = math.max(-80, math.min(x*diagRadius, 80))
		y = math.max(-80, math.min(y*diagRadius, 80))
	end
	button:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

local function onClick(self, b) if self.dataObject.OnClick then self.dataObject.OnClick(self, b) end end
local function onMouseDown(self) self.icon:SetTexCoord(0, 1, 0, 1) end
local function onMouseUp(self) self.icon:SetTexCoord(0.05, 0.95, 0.05, 0.95) end

local function onUpdate(self)
	local mx, my = Minimap:GetCenter()
	local px, py = GetCursorPosition()
	local scale = Minimap:GetEffectiveScale()
	px, py = px / scale, py / scale
	if self.db then
		self.db.minimapPos = math.deg(math.atan2(py - my, px - mx)) % 360
	else
		self.minimapPos = math.deg(math.atan2(py - my, px - mx)) % 360
	end
	updatePosition(self)
end

local function onDragStart(self)
	self:LockHighlight()
	self.icon:SetTexCoord(0, 1, 0, 1)
	self:SetScript("OnUpdate", onUpdate)
	self.isMoving = true
	GameTooltip:Hide()
end

local function onDragStop(self)
	self:SetScript("OnUpdate", nil)
	self.icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)
	self:UnlockHighlight()
	self.isMoving = nil
end

local function createButton(name, object, db)
	local button = CreateFrame("Button", "LibDBIcon10_"..name, Minimap)
	button.dataObject = object
	button.db = db
	button:SetFrameStrata("MEDIUM")
	button:SetWidth(31); button:SetHeight(31)
	button:SetFrameLevel(8)
	button:RegisterForClicks("anyUp")
	button:RegisterForDrag("LeftButton")
	button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
	local overlay = button:CreateTexture(nil, "OVERLAY")
	overlay:SetWidth(53); overlay:SetHeight(53)
	overlay:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
	overlay:SetPoint("TOPLEFT")
	local icon = button:CreateTexture(nil, "BACKGROUND")
	icon:SetWidth(20); icon:SetHeight(20)
	icon:SetTexture(object.icon)
	icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)
	icon:SetPoint("TOPLEFT", 7, -5)
	button.icon = icon

	button:SetScript("OnEnter", onEnter)
	button:SetScript("OnLeave", onLeave)
	button:SetScript("OnClick", onClick)
	button:SetScript("OnDragStart", onDragStart)
	button:SetScript("OnDragStop", onDragStop)
	button:SetScript("OnMouseDown", onMouseDown)
	button:SetScript("OnMouseUp", onMouseUp)

	lib.objects[name] = button

	if lib.loggedIn then
		updatePosition(button)
		if not db or not db.hide then button:Show()
		else button:Hide() end
	end
end

-- We could use a metatable.__index on lib.objects, but then we'd create
-- the icons when checking things like :IsRegistered, which is not necessary.
local function check(name)
	if lib.notCreated[name] then
		createButton(name, lib.notCreated[name][1], lib.notCreated[name][2])
		lib.notCreated[name] = nil
	end
end

lib.loggedIn = lib.loggedIn or false
-- Wait a bit with the initial positioning to let any GetMinimapShape addons
-- load up.
if not lib.loggedIn then
	local f = CreateFrame("Frame")
	f:SetScript("OnEvent", function()
		for _, object in pairs(lib.objects) do
			updatePosition(object)
			if not lib.disabled and (not object.db or not object.db.hide) then object:Show()
			else object:Hide() end
		end
		lib.loggedIn = true
		f:SetScript("OnEvent", nil)
		f = nil
	end)
	f:RegisterEvent("PLAYER_LOGIN")
end

function lib:Register(name, object, db)
	if lib.disabled then return end
	if not object.icon then error("Can't register LDB objects without icons set!") end
	if lib.objects[name] or lib.notCreated[name] then error("Already registered, nubcake.") end
	if not db or not db.hide then
		createButton(name, object, db)
	else
		lib.notCreated[name] = {object, db}
	end
end

function lib:Hide(name)
	if not lib.objects[name] then return end
	lib.objects[name]:Hide()
end
function lib:Show(name)
	if lib.disabled then return end
	check(name)
	lib.objects[name]:Show()
	updatePosition(lib.objects[name])
end
function lib:IsRegistered(name)
	return (lib.objects[name] or lib.notCreated[name]) and true or false
end
function lib:Refresh(name, db)
	if lib.disabled then return end
	check(name)
	local button = lib.objects[name]
	if db then button.db = db end
	updatePosition(button)
	if not db or not db.hide then
		button:Show()
	else
		button:Hide()
	end
end

function lib:EnableLibrary()
	lib.disabled = nil
	for name, object in pairs(lib.objects) do
		if not object.db or (object.db and not object.db.hide) then
			object:Show()
			updatePosition(object)
		end
	end
end

function lib:DisableLibrary()
	lib.disabled = true
	for name, object in pairs(lib.objects) do
		object:Hide()
	end
end

