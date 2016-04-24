--[[
Name: AstrolabeMapMonitor
Revision: $Rev: 44 $
$Date: 2007-03-30 11:56:21 -0700 (Fri, 30 Mar 2007) $
Author(s): Esamynn (esamynn@wowinterface.com)
Inspired By: Gatherer by Norganna
             MapLibrary by Kristofer Karlsson (krka@kth.se)
Website: http://esamynn.wowinterface.com/
Documentation: http://www.esamynn.org/wiki/Astrolabe/World_Map_Monitor
SVN: http://esamynn.org/svn/astrolabe/
Description:
	This is a small stub library to support the main Astrolabe
	library.  It's purpose is to monitor the visibility of 
	various World Map frames, so that Astrolabe can modify its
	behaviour accordingly.  

Copyright (C) 2007 James Carrothers

License:
	This library is free software; you can redistribute it and/or
	modify it under the terms of the GNU Lesser General Public
	License as published by the Free Software Foundation; either
	version 2.1 of the License, or (at your option) any later version.

	This library is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
	Lesser General Public License for more details.

	You should have received a copy of the GNU Lesser General Public
	License along with this library; if not, write to the Free Software
	Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

Note:
	This library's source code is specifically designed to work with
	World of Warcraft's interpreted AddOn system.  You have an implicit
	licence to use this library with these facilities since that is its
	designated purpose as per:
	http://www.fsf.org/licensing/licenses/gpl-faq.html#InterpreterIncompat
]]

-- WARNING!!!
-- DO NOT MAKE CHANGES TO THIS LIBRARY WITHOUT FIRST CHANGING THE LIBRARY_VERSION_MAJOR
-- STRING (to something unique) OR ELSE YOU MAY BREAK OTHER ADDONS THAT USE THIS LIBRARY!!!
local LIBRARY_VERSION_MAJOR = "AstrolabeMapMonitor"
local LIBRARY_VERSION_MINOR = tonumber(string.match("$Revision: 44 $", "(%d+)") or 1)

if not DongleStub then error(LIBRARY_VERSION_MAJOR .. " requires DongleStub.") end
if not DongleStub:IsNewerVersion(LIBRARY_VERSION_MAJOR, LIBRARY_VERSION_MINOR) then return end

local AstrolabeMapMonitor = {};

function AstrolabeMapMonitor:GetVersion()
	return LIBRARY_VERSION_MAJOR, LIBRARY_VERSION_MINOR;
end


--------------------------------------------------------------------------------------------------------------
-- Global World Map Frame Registration Table
--------------------------------------------------------------------------------------------------------------

if ( type(WorldMapDisplayFrames) ~= "table" ) then
	WorldMapDisplayFrames = { WorldMapFrame };
else
	local worldMapFound = false;
	for k, v in pairs(WorldMapDisplayFrames) do
		if ( v == WorldMapFrame ) then
			worldMapFound = true;
			break;
		end
	end
	if not ( worldMapFound ) then
		table.insert(WorldMapDisplayFrames, WorldMapFrame);
	end
end


--------------------------------------------------------------------------------------------------------------
-- Working Tables and Config Constants
--------------------------------------------------------------------------------------------------------------

AstrolabeMapMonitor.TrackedWorldMaps = {};
AstrolabeMapMonitor.AstrolabeLibrarys = {};

AstrolabeMapMonitor.NumVisibleWorldMaps = 0;


--------------------------------------------------------------------------------------------------------------
-- Monitor Frame Script Handlers
--------------------------------------------------------------------------------------------------------------

local function onShow( frame )
	AstrolabeMapMonitor.NumVisibleWorldMaps = AstrolabeMapMonitor.NumVisibleWorldMaps + 1;
	AstrolabeMapMonitor:Update()
end

local function onHide( frame )
	AstrolabeMapMonitor.NumVisibleWorldMaps = AstrolabeMapMonitor.NumVisibleWorldMaps - 1;
	AstrolabeMapMonitor:Update()
end

local function setScripts( monitorFrame )
	monitorFrame:SetScript("OnShow", onShow);
	monitorFrame:SetScript("OnHide", onHide);
end


--------------------------------------------------------------------------------------------------------------
-- Internal Utility Functions
--------------------------------------------------------------------------------------------------------------

local function assert(level,condition,message)
	if not condition then
		error(message,level)
	end
end

local function argcheck(value, num, ...)
	assert(1, type(num) == "number",
		"Bad argument #2 to 'argcheck' (number expected, got " .. type(level) .. ")")

	for i=1,select("#", ...) do
		if type(value) == select(i, ...) then return end
	end

	local types = strjoin(", ", ...)
	local name = string.match(debugstack(2,2,0), ": in function [`<](.-)['>]")
	error(string.format("Bad argument #%d to 'AstrolabeMapMonitor.%s' (%s expected, got %s)", num, name, types, type(value)), 3)
end


--------------------------------------------------------------------------------------------------------------
-- Public API
--------------------------------------------------------------------------------------------------------------

function AstrolabeMapMonitor:MonitorWorldMap( worldMapFrame )
	-- check argument types
	argcheck(worldMapFrame, 2, "table");
	assert((worldMapFrame.SetParent), "Usage Message");
	
	local TrackedWorldMaps = self.TrackedWorldMaps;
	if ( TrackedWorldMaps[worldMapFrame] ) then
		return 1;
	end
	local monitorFrame = CreateFrame("Frame", nil, worldMapFrame);
	TrackedWorldMaps[worldMapFrame] = monitorFrame;
	setScripts(monitorFrame);
	self:ForceUpdate();
	return 0;
end

function AstrolabeMapMonitor:LookForMapsToRegister()
	for k, frame in pairs(WorldMapDisplayFrames) do
		if ( type(frame) == "table" and frame.SetParent ) then
			self:MonitorWorldMap(frame);
		end
	end
end

function AstrolabeMapMonitor:Update()
	local visibleMap = false;
	if ( (self.NumVisibleWorldMaps) > 0 ) then
		visibleMap = true;
	end
	for lib, versionString in pairs(self.AstrolabeLibrarys) do
		lib.WorldMapVisible = visibleMap;
		if ( (not visibleMap) and lib.AllWorldMapsHidden ) then
			lib:AllWorldMapsHidden();
		end
	end
	return visibleMap;
end

function AstrolabeMapMonitor:ForceUpdate()
	self.NumVisibleWorldMaps = 0;
	for worldMap, monitorFrame in pairs(self.TrackedWorldMaps) do
		if ( worldMap:IsVisible() ) then
			self.NumVisibleWorldMaps = self.NumVisibleWorldMaps + 1;
		end
	end
	return self:Update();
end

function AstrolabeMapMonitor:RegisterAstrolabeLibrary( lib, majorVersionString )
	-- check argument types
	argcheck(lib, 2, "table");
	argcheck(majorVersionString, 3, "string");
	
	self.AstrolabeLibrarys[lib] = majorVersionString;
	self:Update();
end


--------------------------------------------------------------------------------------------------------------
-- Handler Scripts
--------------------------------------------------------------------------------------------------------------

function AstrolabeMapMonitor:OnEvent( frame, event )
	if ( event == "ADDON_LOADED" ) then
		self:LookForMapsToRegister();
		self:ForceUpdate();
	end
end


--------------------------------------------------------------------------------------------------------------
-- Library Registration
--------------------------------------------------------------------------------------------------------------

local function activate( newInstance, oldInstance )
	if ( oldInstance ) then -- this is an upgrade activate
		for k, v in pairs(oldInstance) do
			if ( type(v) ~= "function" ) then
				newInstance[k] = v;
			end
		end
		AstrolabeMapMonitor = oldInstance;
	else
		AstrolabeMapMonitor.eventFrame = CreateFrame("Frame");
	end
	for worldMap, monitorFrame in pairs(AstrolabeMapMonitor.TrackedWorldMaps) do
		setScripts(monitorFrame);
	end
	local frame = AstrolabeMapMonitor.eventFrame;
	frame:Hide();
	frame:UnregisterAllEvents();
	frame:RegisterEvent("ADDON_LOADED");
	frame:SetScript("OnEvent",
		function( frame, event, ... )
			AstrolabeMapMonitor:OnEvent(frame, event, ...);
		end
	);
end

DongleStub:Register(AstrolabeMapMonitor, activate)
