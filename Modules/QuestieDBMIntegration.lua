--DBM HudMap integration written by MysticalOS
--All code here executes functions from https://github.com/DeadlyBossMods/DBM-Classic/blob/master/DBM-Core/DBM-HudMap.lua
----------------------
--  Globals/Locals  --
----------------------
---@class QuestieDBMIntegration
local QuestieDBMIntegration = QuestieLoader:CreateModule("QuestieDBMIntegration");

--Libs
local HBD = LibStub("HereBeDragonsQuestie-2.0")
--Local Variables
local LastInstanceMapID = 9999--Just making sure to set initial zone ID to a number (that isn't an actual zone)
local KalimdorPoints = {}--Maintains Kalimdor objective list
local EKPoints = {}--Maintains Eastern Kingdoms objective list
--local OutlandPoints = {}--Maintains Outland objective list
--local NorthrendPoints = {}--Maintains Northrend Kingdoms objective list
local AddedHudIds = {}--Tracking table of all active hud markers
local playerName = UnitName("player")
local QuestieHUDEnabled = false

--------------------------------------------
--  Local function used by entire module  --
--------------------------------------------
--Adds icons to actual hud display
local function AddHudQuestIcon(tableString, icon, AreaID, x, y, r, g, b)
    if tableString and not AddedHudIds[tableString] then
        --Icon based filters, if icon is disabled, return without adding
        if not Questie.db.global.dbmHUDShowSlay and icon:find("slay") or not Questie.db.global.dbmHUDShowQuest and (icon:find("complete") or icon:find("available")) or not Questie.db.global.dbmHUDShowInteract and icon:find("object") or not Questie.db.global.dbmHUDShowLoot and icon:find("loot") then return end
        if not DBM.HudMap.HUDEnabled then
            --Force a fixed zoom, if one is not set, hudmap tries to zoom out until all registered icons fit, that's no good for world wide quest icons
            DBM.HudMap:SetFixedZoom(Questie.db.global.DBMHUDZoom or 100)
            QuestieDBMIntegration:ChangeRefreshRate(Questie.db.global.DBMHUDRefresh or 0.03)
        end
        --uniqueID, name, texture, x, y, radius, duration, r, g, b, a, blend, useLocalMap, LocalMapId
        if Questie.db.global.dbmHUDShowAlert then
            DBM.HudMap:RegisterPositionMarker(tableString, "Questie", icon, x, y, Questie.db.global.dbmHUDRadius or 3, nil, r, g, b, 1, nil, true, AreaID):Appear():RegisterForAlerts()
        else
            DBM.HudMap:RegisterPositionMarker(tableString, "Questie", icon, x, y, Questie.db.global.dbmHUDRadius or 3, nil, r, g, b, 1, nil, true, AreaID):Appear()
        end
        AddedHudIds[tableString] = true
        --print("Adding "..tableString)
    end
end

--Removes icons from hud display
local function RemoveHudQuestIcon(tableString)
    if tableString and AddedHudIds[tableString] then
        DBM.HudMap:FreeEncounterMarkerByTarget(tableString, "Questie")
        AddedHudIds[tableString] = nil
        --print("Removing "..tableString)
    end
end

-------------------------------------
--  Event/Enable/Disable Handlers  --
-------------------------------------
do
    local eventFrame = CreateFrame("frame", "QuestieDBMIntegration", UIParent)
    local GetInstanceInfo, IsInInstance = GetInstanceInfo, IsInInstance
    local warningShown = false
        
    local function CleanupPoints(keepInstance)
        if keepInstance ~= 0 then
            for tableString, points in pairs(EKPoints) do
                RemoveHudQuestIcon(tableString)
            end
        end
        if keepInstance ~= 1 then
            for tableString, points in pairs(KalimdorPoints) do
                RemoveHudQuestIcon(tableString)
            end
        end
        --Future Proofing
        --[[if keepInstance ~= 530 then
            for tableString, points in pairs(OutlandPoints) do
                RemoveHudQuestIcon(tableString)
            end
        end
        if keepInstance ~= 571 then
            for tableString, points in pairs(NorthrendPoints) do
                RemoveHudQuestIcon(tableString)
            end
        end--]]
    end

    local function ReAddHudIcons()
        if LastInstanceMapID == 0 then--It means we are now in Eastern Kingdoms (but weren't before)
            for tableString, points in pairs(EKPoints) do
                AddHudQuestIcon(tableString, points.icon, points.AreaID, points.x, points.y, points.r, points.g, points.b)
            end
        elseif LastInstanceMapID == 1 then--It means we are now in Kalimdor (but weren't before)
            for tableString, points in pairs(KalimdorPoints) do
                AddHudQuestIcon(tableString, points.icon, points.AreaID, points.x, points.y, points.r, points.g, points.b)
            end
        end
    end

    local function DelayedMapCheck()
        --Only run stuff if map actually changes
        local _, _, _, _, _, _, _, mapID = GetInstanceInfo()
        if LastInstanceMapID ~= mapID then
            LastInstanceMapID = mapID
            DBM.HudMap:ClearAllEdges()--Wipe out any edges, they wouldn't work cross continent anyways
            if IsInInstance() then--We've entered an instance, DBM itself will already wiped/disabled hud for entering a map restricted area, but locally we need to wipe AddedHudIds
                AddedHudIds = {}
            else
                CleanupPoints(LastInstanceMapID)
                ReAddHudIcons()
            end
        --else
            --print("No action taken because mapID hasn't changed since last check")
        end
    end

    --Called when Hud Option in questie options is toggled to on
    function QuestieDBMIntegration:EnableHUD()
        if DBM and DBM.HudMap and not QuestieHUDEnabled then
            QuestieHUDEnabled = true
            eventFrame:RegisterEvent("LOADING_SCREEN_DISABLED")
            DelayedMapCheck()
            DBM:Schedule(1, DelayedMapCheck)
            if not warningShown then
                DBM:AddMsg("Questie has activated DBM HUD overlay. For more options, visit DBM HUD tab in Questie options")
                warningShown = true
            end
        end
    end

    function QuestieDBMIntegration:SoftReset()
        --Needed for when Icon sizes, or icon filters are changed
        if DBM and DBM.HudMap and QuestieHUDEnabled then
            CleanupPoints(9999)--Wipes all the added markers
            ReAddHudIcons()--Re-Add all icons
        end
    end

    function QuestieDBMIntegration:ClearAll(disable)
        --Needed for QuestieQuest:SmoothReset(), which should call QuestieDBMIntegration:ClearAll() to also wipe hud markers. Do not call disable arg
        --Hud Markers will be regenerated when questie regenerates it's own icons
        if DBM and DBM.HudMap and QuestieHUDEnabled then
            for tableString, points in pairs(AddedHudIds) do
                DBM.HudMap:FreeEncounterMarkerByTarget(tableString, "Questie")
                AddedHudIds[tableString] = nil
            end
            KalimdorPoints = {}
            EKPoints = {}
            --Also used onClick for GUI option to turn feature off, of course, just pass disable arg
            if disable then
                QuestieHUDEnabled = false
                if eventFrame then
                    eventFrame:UnregisterEvent("LOADING_SCREEN_DISABLED")
                end
                DBM:Unschedule(DelayedMapCheck)
            end
        end
    end

    eventFrame:SetScript("OnEvent", function(self, event, ...)
        if event == "LOADING_SCREEN_DISABLED"  then
            DelayedMapCheck()
            --In rare cases, the incorrect Id is given when checked immediately, for users who have very slow popin after loading screen, this checks again for good measure
            DBM:Schedule(1, DelayedMapCheck)--Well, since DBM is loaded, might as well use DBM scheduler instead of creating a ticker
        end
    end)
end

------------------------
--  Global Functions  --
------------------------
--Called in QuestieMap in DrawWorldIcon function right after QuestieMap:QueueDraw
--QuestieDBMIntegration:RegisterHudQuestIcon(tostring(icon), data.Icon, ZoneDB:GetUiMapIdByAreaId(AreaID), x, y, colors[1], colors[2], colors[3])
--Take note of x, y. do not /100 the coords sent to this itegration, since HudMap expects unmodified values
function QuestieDBMIntegration:RegisterHudQuestIcon(tableString, icon, AreaID, x, y, r, g, b)
    if DBM and DBM.HudMap and QuestieHUDEnabled and tableString then
        local _, _, instanceID = HBD:GetWorldCoordinatesFromZone(x, y, AreaID)--Used to transform mapid to instance ID, DBM will transform the coords more reliably later
        --Eastern Kingdoms: Instance 0, Map 1415. Kalimdor: Instance 1, Map 1414
        if instanceID == 0 then
            --Build an Eastern Kingdoms Points Table
            if not EKPoints[tableString] then
                EKPoints[tableString] = {}
                EKPoints[tableString].icon = icon
                EKPoints[tableString].AreaID = AreaID
                EKPoints[tableString].x = x
                EKPoints[tableString].y = y
                EKPoints[tableString].r = r
                EKPoints[tableString].g = g
                EKPoints[tableString].b = b
            end
            --Object being registered is in continent we currently reside, add to hud
            if LastInstanceMapID == 0 then
                AddHudQuestIcon(tableString, icon, AreaID, x, y, r, g, b)
            --else
                --print("Rejecting point for being on a different continent")
            end
        elseif instanceID == 1 then
            --Build a Kalimdor Points Table
            if not KalimdorPoints[tableString] then
                KalimdorPoints[tableString] = {}
                KalimdorPoints[tableString].icon = icon
                KalimdorPoints[tableString].AreaID = AreaID
                KalimdorPoints[tableString].x = x
                KalimdorPoints[tableString].y = y
                KalimdorPoints[tableString].r = r
                KalimdorPoints[tableString].g = g
                KalimdorPoints[tableString].b = b
            end
            --Object being reistered is in continent we currently reside, add to hud
            if LastInstanceMapID == 1 then
                AddHudQuestIcon(tableString, icon, AreaID, x, y, r, g, b)
            --else
                --print("Rejecting point for being on a different continent")
            end
        end
    end
end

--Called in QuestieFramePool in Unload right after HBDPins:RemoveWorldMapIcon. Add the below line
--QuestieDBMIntegration:UnregisterHudQuestIcon(tostring(self))
function QuestieDBMIntegration:UnregisterHudQuestIcon(tableString)
    if DBM and DBM.HudMap and QuestieHUDEnabled and tableString then
        if KalimdorPoints[tableString] then KalimdorPoints[tableString] = nil end
        if EKPoints[tableString] then EKPoints[tableString] = nil end
        if AddedHudIds[tableString] then
            RemoveHudQuestIcon(tableString)
        end
    end
end

function QuestieDBMIntegration:ChangeZoomLevel(zoom)
    if DBM and DBM.HudMap and QuestieHUDEnabled then
        DBM.HudMap:SetFixedZoom(zoom)
    end
end

function QuestieDBMIntegration:ChangeRefreshRate(rate)
    if DBM and DBM.HudMap and QuestieHUDEnabled and DBM.HudMap.Version then
        if rate < 0.01 then rate = 0.01 end--just to protect against a user who might try to hack their config file
        DBM.HudMap:SetFixedUpdateRate(rate)
    end
end

--Creates a line between player and a specific point
function QuestieDBMIntegration:EdgeTo(tableString)
    if DBM and DBM.HudMap and tableString then
        if not AddedHudIds[tableString.."edge"] then
            --Request Marker table from DBM for specific tableString
            local marker2 = DBM.HudMap:GetEncounterMarker(tableString.."Questie")
            if marker2 and type(marker2) == "table" then
                --Now, create a practically invisible point on player to establish edge from location
                local marker1 = DBM.HudMap:RegisterRangeMarkerOnPartyMember(tableString, "party", playerName, 0.1, nil, 0, 1, 0, 1, nil, false):Appear()--objectId, texture, person, radius, duration, r, g, b, a, blend, canFilterSelf
                marker2:EdgeTo(marker1, nil, hudDuration, 0, 1, 0, 1)--point_or_unit_or_x, from_y, duration, r, g, b, a, w, texfile, extend
                AddedHudIds[tableString..playerName] = true
            --else
            --    print("attempted to create an edge with an invalid target marker")
            end
        end
    end
end

--Creates a line between player and a specific point
function QuestieDBMIntegration:ClearHudEdge(tableString)
    if DBM and DBM.HudMap and tableString then
        if AddedHudIds[tableString..playerName] then
            AddedHudIds[tableString..playerName] = nil
            DBM.HudMap:FreeEncounterMarkerByTarget(tableString, playerName)--Wipes player marker, doing so should automatically wipe edge
        end
    end
end

--TODO
----HUD
--more fancy functions similar to drawing lines/arrows to objectives. Current edge code works, but there are still more cool things HUD can do
--possibly pulsing or other icon effects for specific objectives to make specific things stand out more, such as a click/interact objective in middle of a bunch of loot/kill ones
--Much more memory efficient table management? (especially since I'm just REALLY bad at tables). Maybe a way to just pull info from existing map Pins from questie or HBD instead of literally storing local tables of all objects here as well
--Move a bunch of this to DBM-Core's HUDMAP module and expand api to support more mods such as handynotes, gathermate, etc
----ARROW?
--Arrow functions?, since DBM also has a regular waypoint arrow as well. DBM arrow api is https://github.com/DeadlyBossMods/DBM-Classic/blob/master/DBM-Core/DBM-Arrow.lua
