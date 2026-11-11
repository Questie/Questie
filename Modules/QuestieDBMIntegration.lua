--DBM HudMap integration written by MysticalOS
--HUD API: https://github.com/DeadlyBossMods/DBM-HudMap
------------------------
--   Globals/Locals   --
------------------------
---@class QuestieDBMIntegration
local QuestieDBMIntegration = QuestieLoader:CreateModule("QuestieDBMIntegration");

---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

--Libs
local HBD = LibStub("HereBeDragonsQuestie-2.0")
--Local Variables
local LastInstanceMapID
local KalimdorPoints = {}--Maintains Kalimdor objective list
local EKPoints = {}--Maintains Eastern Kingdoms objective list
local OutlandPoints = {}--Maintains Outland objective list
local NorthrendPoints = {}--Maintains Northrend Kingdoms objective list
local PandariaPoints = {}--Maintains Pandaria objective list
local AddedHudIds = {}--Tracking table of all active hud markers
local AddedHudEdges = {}
local QuestieHUDEnabled = false
local HudRadius, HudShowAlert

----------------------------------------------
--   Local function used by entire module   --
----------------------------------------------
local function OnHudMarkerFreed(tableString, _, marker)
    if AddedHudIds[tableString] == marker then
        AddedHudIds[tableString] = nil
        QuestieDBMIntegration:ClearHudEdge(tableString)
    end
end

local function OnHudEdgeFreed(tableString, _, marker)
    if AddedHudEdges[tableString] == marker then
        AddedHudEdges[tableString] = nil
    end
end

local function IsHudIconEnabled(icon)
    if not Questie.db.profile.dbmHUDShowSlay and icon == Questie.ICON_TYPE_SLAY or
        not Questie.db.profile.dbmHUDShowQuest and (
            icon == Questie.ICON_TYPE_AVAILABLE or
            icon == Questie.ICON_TYPE_AVAILABLE_GRAY or
            icon == Questie.ICON_TYPE_COMPLETE or
            icon == Questie.ICON_TYPE_EVENTQUEST or
            icon == Questie.ICON_TYPE_EVENTQUEST_COMPLETE or
            icon == Questie.ICON_TYPE_INCOMPLETE or
            icon == Questie.ICON_TYPE_PVPQUEST or
            icon == Questie.ICON_TYPE_PVPQUEST_COMPLETE or
            icon == Questie.ICON_TYPE_REPEATABLE or
            icon == Questie.ICON_TYPE_REPEATABLE_COMPLETE or
            icon == Questie.ICON_TYPE_SODRUNE) or
        not Questie.db.profile.dbmHUDShowInteract and icon == Questie.ICON_TYPE_OBJECT or
        not Questie.db.profile.dbmHUDShowLoot and icon == Questie.ICON_TYPE_LOOT then
        return false
    end
    return true
end

--Adds icons to actual hud display
local function AddHudQuestIcon(tableString, icon, AreaID, x, y, r, g, b)
    if tableString and not AddedHudIds[tableString] and not IsInInstance() and UIParent:IsShown() then
        if not IsHudIconEnabled(icon) then return end
        --uniqueID, name, texture, x, y, radius, duration, r, g, b, a, blend, useLocalMap, LocalMapId
        local marker = DBM.HudMap:RegisterPositionMarker(tableString, "Questie", Questie.usedIcons[icon], x, y, Questie.db.profile.dbmHUDRadius or 3, nil, r, g, b, 1, nil, true, AreaID)
        -- New HUD versions return an inert marker when disabled or map-restricted.
        if not marker or marker.freed then return end
        marker:Appear()
        if Questie.db.profile.dbmHUDShowAlert then
            marker:RegisterForAlerts()
        end
        AddedHudIds[tableString] = marker
        marker.RegisterCallback(QuestieDBMIntegration, "Free", OnHudMarkerFreed, tableString)
        --print("Adding "..tableString)
    end
end

--Removes icons from hud display
local function RemoveHudQuestIcon(tableString)
    if tableString and AddedHudIds[tableString] then
        QuestieDBMIntegration:ClearHudEdge(tableString)
        DBM.HudMap:FreeEncounterMarkerByTarget(tableString, "Questie")
        AddedHudIds[tableString] = nil
        --print("Removing "..tableString)
    end
end

---------------------------------------
--   Event/Enable/Disable Handlers   --
---------------------------------------
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
        if keepInstance ~= 530 then
            for tableString, points in pairs(OutlandPoints) do
                RemoveHudQuestIcon(tableString)
            end
        end
       if keepInstance ~= 571 then
            for tableString, points in pairs(NorthrendPoints) do
                RemoveHudQuestIcon(tableString)
            end
        end
        for tableString, points in pairs(PandariaPoints) do
            if keepInstance ~= points.instanceID then
                RemoveHudQuestIcon(tableString)
            end
        end
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
        elseif LastInstanceMapID == 530 then--It means we are now in Outland (but weren't before)
            for tableString, points in pairs(OutlandPoints) do
                AddHudQuestIcon(tableString, points.icon, points.AreaID, points.x, points.y, points.r, points.g, points.b)
            end
        elseif LastInstanceMapID == 571 then--It means we are now in Northrend (but weren't before)
            for tableString, points in pairs(NorthrendPoints) do
                AddHudQuestIcon(tableString, points.icon, points.AreaID, points.x, points.y, points.r, points.g, points.b)
            end
        elseif LastInstanceMapID == 860 or LastInstanceMapID == 870 then--It means we are now in Pandaria (but weren't before)
            for tableString, points in pairs(PandariaPoints) do
                if LastInstanceMapID == points.instanceID then
                    AddHudQuestIcon(tableString, points.icon, points.AreaID, points.x, points.y, points.r, points.g, points.b)
                end
            end
        end
    end

    local function DelayedMapCheck()
        if not QuestieHUDEnabled then return end
        -- Only remove markers if the continent actually changes.
        local _, _, _, _, _, _, _, mapID = GetInstanceInfo()
        if not mapID then return end
        if LastInstanceMapID ~= mapID then
            Questie.Debug(Questie.DEBUG_DEVELOP, "[QuestieDBMIntegration] Continent changed", LastInstanceMapID, mapID)
            LastInstanceMapID = mapID
            if IsInInstance() then
                CleanupPoints(9999)
            else
                CleanupPoints(LastInstanceMapID)
            end
        end
        -- Also retry markers refused or freed by DBM; live markers are left intact.
        if not IsInInstance() then
            ReAddHudIcons()
        end
    end

    --Called when Hud Option in questie options is toggled to on
    function QuestieDBMIntegration:EnableHUD()
        if DBM and DBM.HudMap and not QuestieHUDEnabled then
            QuestieHUDEnabled = true
            LastInstanceMapID = nil
            HudRadius = Questie.db.profile.dbmHUDRadius or 3
            HudShowAlert = Questie.db.profile.dbmHUDShowAlert
            -- Worldwide quest pins must not drive the HUD's automatic zoom.
            DBM.HudMap:SetFixedZoom(Questie.db.profile.DBMHUDZoom or 100)
            self:ChangeRefreshRate(Questie.db.profile.DBMHUDRefresh or 0.03)
            eventFrame:RegisterEvent("LOADING_SCREEN_DISABLED")
            DelayedMapCheck()
            DBM:Unschedule(DelayedMapCheck)
            DBM:Schedule(1, DelayedMapCheck)
            if not warningShown then
                DBM:AddMsg(l10n("Questie has activated DBM HUD overlay. For more options, visit DBM HUD tab in Questie options"))
                warningShown = true
            end
        end
    end

    function QuestieDBMIntegration:SoftReset()
        -- Filter changes only remove affected markers; size/alert changes need new markers.
        if DBM and DBM.HudMap and QuestieHUDEnabled then
            local radius = Questie.db.profile.dbmHUDRadius or 3
            local showAlert = Questie.db.profile.dbmHUDShowAlert
            if HudRadius ~= radius or HudShowAlert ~= showAlert then
                Questie.Debug(Questie.DEBUG_DEVELOP, "[QuestieDBMIntegration] Rebuilding HUD for size/alert changes")
                CleanupPoints(9999)
                HudRadius, HudShowAlert = radius, showAlert
            else
                local points = LastInstanceMapID == 0 and EKPoints or LastInstanceMapID == 1 and KalimdorPoints
                    or LastInstanceMapID == 530 and OutlandPoints or LastInstanceMapID == 571 and NorthrendPoints
                    or (LastInstanceMapID == 860 or LastInstanceMapID == 870) and PandariaPoints
                if points then
                    for tableString, point in pairs(points) do
                        if not IsHudIconEnabled(point.icon) then
                            RemoveHudQuestIcon(tableString)
                        end
                    end
                end
            end
            ReAddHudIcons()
        end
    end

    function QuestieDBMIntegration:ClearAll(disable)
        --Needed for QuestieQuest:SmoothReset(), which should call QuestieDBMIntegration:ClearAll() to also wipe hud markers. Do not call disable arg
        --Hud Markers will be regenerated when questie regenerates it's own icons
        if DBM and DBM.HudMap and QuestieHUDEnabled then
            Questie.Debug(Questie.DEBUG_DEVELOP, "[QuestieDBMIntegration] Clearing HUD for reset/disable", disable)
            for tableString, points in pairs(AddedHudIds) do
                RemoveHudQuestIcon(tableString)
            end
            KalimdorPoints = {}
            EKPoints = {}
            OutlandPoints = {}
            NorthrendPoints = {}
            PandariaPoints = {}
            --Also used onClick for GUI option to turn feature off, of course, just pass disable arg
            if disable then
                QuestieHUDEnabled = false
                LastInstanceMapID = nil
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
            DBM:Unschedule(DelayedMapCheck)
            DBM:Schedule(1, DelayedMapCheck)--Well, since DBM is loaded, might as well use DBM scheduler instead of creating a ticker
        end
    end)

    if UIParent then
        UIParent:HookScript("OnHide", function()
            if QuestieHUDEnabled then
                Questie.Debug(Questie.DEBUG_DEVELOP, "[QuestieDBMIntegration] Hiding HUD with UIParent")
                CleanupPoints(9999)
            end
        end)

        UIParent:HookScript("OnShow", function()
            if QuestieHUDEnabled then
                ReAddHudIcons()
            end
        end)
    end
end

--------------------------
--   Global Functions   --
--------------------------
--Called in QuestieMap in DrawWorldIcon function right after QuestieMap:QueueDraw
--QuestieDBMIntegration:RegisterHudQuestIcon(tostring(icon), data.Icon, ZoneDB:GetUiMapIdByAreaId(AreaID), x, y, colors[1], colors[2], colors[3])
--Take note of x, y. do not /100 the coords sent to this itegration, since HudMap expects unmodified values
function QuestieDBMIntegration:RegisterHudQuestIcon(tableString, icon, AreaID, x, y, r, g, b)
    if DBM and DBM.HudMap and QuestieHUDEnabled and tableString then
        local _, _, instanceID = HBD:GetWorldCoordinatesFromZone(x / 100, y / 100, AreaID)
        local points
        if instanceID == 0 then
            points = EKPoints
        elseif instanceID == 1 then
            points = KalimdorPoints
        elseif instanceID == 530 then
            points = OutlandPoints
        elseif instanceID == 571 then
            points = NorthrendPoints
        elseif instanceID == 860 or instanceID == 870 then--Turtle island and main pandaria continent
            points = PandariaPoints
        end
        if not points then
            self:UnregisterHudQuestIcon(tableString)
            return
        end

        local previous = points[tableString]
        if not previous or previous.icon ~= icon or previous.AreaID ~= AreaID or previous.x ~= x or previous.y ~= y
            or previous.r ~= r or previous.g ~= g or previous.b ~= b or previous.instanceID ~= instanceID then
            -- A pooled frame can be reused or moved without changing its string ID.
            self:UnregisterHudQuestIcon(tableString)
            points[tableString] = {icon = icon, AreaID = AreaID, x = x, y = y, r = r, g = g, b = b, instanceID = instanceID}
        end
        if LastInstanceMapID == instanceID then
            AddHudQuestIcon(tableString, icon, AreaID, x, y, r, g, b)
        end
    end
end

--Called in QuestieFramePool in Unload right after HBDPins:RemoveWorldMapIcon. Add the below line
--QuestieDBMIntegration:UnregisterHudQuestIcon(tostring(self))
function QuestieDBMIntegration:UnregisterHudQuestIcon(tableString)
    if DBM and DBM.HudMap and QuestieHUDEnabled and tableString then
        if KalimdorPoints[tableString] then KalimdorPoints[tableString] = nil end
        if EKPoints[tableString] then EKPoints[tableString] = nil end
        if OutlandPoints[tableString] then OutlandPoints[tableString] = nil end
        if NorthrendPoints[tableString] then NorthrendPoints[tableString] = nil end
        if PandariaPoints[tableString] then PandariaPoints[tableString] = nil end
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
    if not QuestieHUDEnabled or not DBM or not DBM.HudMap or not tableString then return end
    if not AddedHudEdges[tableString] then
        --Request Marker table from DBM for specific tableString
        local marker2 = AddedHudIds[tableString]
        if marker2 then
            --Now, create a practically invisible point on player to establish edge from location
            local marker1 = DBM.HudMap:RegisterRangeMarkerOnPartyMember(tableString, "party", "player", 0.1, nil, 0, 1, 0, 1)
            if not marker1 or marker1.freed then return end
            marker1:Appear()
            marker2:EdgeTo(marker1, nil, nil, 0, 1, 0, 1)--point_or_unit_or_x, from_y, duration, r, g, b, a, w, texfile, extend
            AddedHudEdges[tableString] = marker1
            marker1.RegisterCallback(QuestieDBMIntegration, "Free", OnHudEdgeFreed, tableString)
        --else
        --    print("attempted to create an edge with an invalid target marker")
        end
    end
end

--Creates a line between player and a specific point
function QuestieDBMIntegration:ClearHudEdge(tableString)
    if DBM and DBM.HudMap and tableString then
        if AddedHudEdges[tableString] then
            AddedHudEdges[tableString] = nil
            DBM.HudMap:FreeEncounterMarkerByTarget(tableString, "player")--Wipes player marker, doing so should automatically wipe edge
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