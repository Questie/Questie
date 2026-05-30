-- DBM HudMap integration written by MysticalOS (Refactored)
-- Questie integration layer for DBM HudMap

---@class QuestieDBMIntegration
local QuestieDBMIntegration = QuestieLoader:CreateModule("QuestieDBMIntegration")

---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local HBD = LibStub("HereBeDragonsQuestie-2.0")

---
-- State
local LastInstanceMapID = 9999
local AddedHudIds = {}

local playerName = UnitName("player")
local QuestieHUDEnabled = false
local UIHidden = not UIParent:IsShown()

local ZoneTables = {
    [0] = {},   -- EK
    [1] = {},   -- Kalimdor
    [530] = {}, -- Outland
    [571] = {}, -- Northrend
    [860] = {}, -- Pandaria
    [870] = {}, -- Pandaria alt
}

---
-- Helpers

local function IsIconAllowed(icon)
    local db = Questie.db.profile

    if (not db.dbmHUDShowSlay and icon == Questie.ICON_TYPE_SLAY) then return false end

    if (not db.dbmHUDShowQuest) then
        if icon == Questie.ICON_TYPE_AVAILABLE
        or icon == Questie.ICON_TYPE_AVAILABLE_GRAY
        or icon == Questie.ICON_TYPE_COMPLETE
        or icon == Questie.ICON_TYPE_EVENTQUEST
        or icon == Questie.ICON_TYPE_EVENTQUEST_COMPLETE
        or icon == Questie.ICON_TYPE_INCOMPLETE
        or icon == Questie.ICON_TYPE_PVPQUEST
        or icon == Questie.ICON_TYPE_PVPQUEST_COMPLETE
        or icon == Questie.ICON_TYPE_REPEATABLE
        or icon == Questie.ICON_TYPE_REPEATABLE_COMPLETE
        or icon == Questie.ICON_TYPE_SODRUNE then
            return false
        end
    end

    if (not db.dbmHUDShowInteract and icon == Questie.ICON_TYPE_OBJECT) then return false end
    if (not db.dbmHUDShowLoot and icon == Questie.ICON_TYPE_LOOT) then return false end

    return true
end

local function RemoveHud(tableString)
    if AddedHudIds[tableString] then
        if DBM and DBM.HudMap then
            DBM.HudMap:FreeEncounterMarkerByTarget(tableString, "Questie")
        end
        AddedHudIds[tableString] = nil
    end
end

local HudSuspended = false
local function AddHud(tableString, icon, AreaID, x, y, r, g, b)
    if HudSuspended or UIHidden then return end
    if not tableString or AddedHudIds[tableString] then return end
    if not IsIconAllowed(icon) then return end

    local db = Questie.db.profile

    if not DBM.HudMap.HUDEnabled then
        DBM.HudMap:SetFixedZoom(db.DBMHUDZoom or 100)
        QuestieDBMIntegration:ChangeRefreshRate(db.DBMHUDRefresh or 0.03)
    end

    local marker
    if db.dbmHUDShowAlert then
        marker = DBM.HudMap:RegisterPositionMarker(
            tableString, "Questie", Questie.usedIcons[icon],
            x, y, db.dbmHUDRadius or 3,
            nil, r, g, b, 1, nil, true, AreaID
        ):Appear():RegisterForAlerts()
    else
        marker = DBM.HudMap:RegisterPositionMarker(
            tableString, "Questie", Questie.usedIcons[icon],
            x, y, db.dbmHUDRadius or 3,
            nil, r, g, b, 1, nil, true, AreaID
        ):Appear()
    end

    AddedHudIds[tableString] = true
end

---

local function UpdateUIVisibility()
    -- Check if UIParent is visible (Alt+Z hides UIParent)
    local isHidden = not UIParent:IsShown()

    if isHidden == UIHidden then return end
    UIHidden = isHidden

    if not DBM or not DBM.HudMap or not QuestieHUDEnabled then return end

    if isHidden then
        HudSuspended = true
        
        -- Completely purge DBM's active marker objects instantly
        for id in pairs(AddedHudIds) do
            DBM.HudMap:FreeEncounterMarkerByTarget(id, "Questie")
        end
        wipe(AddedHudIds)
        
        if DBM.HudMap.Frame then
            DBM.HudMap.Frame:Hide()
        end
    else
        HudSuspended = false
        
        if DBM.HudMap.Frame then
            DBM.HudMap.Frame:Show()
        end
        
        -- Re-draw markers now that the UI is back
        QuestieDBMIntegration:SoftReset()
    end
end

---
-- Map Handling

local function CleanupPoints(keep)
    for id, _ in pairs(AddedHudIds) do
        RemoveHud(id)
    end

    for zone, _ in pairs(ZoneTables) do
        if zone ~= keep then
            for id in pairs(ZoneTables[zone]) do
                RemoveHud(id)
            end
        end
    end
end

local function ReAddHudIcons()
    if UIHidden or HudSuspended then return end
    local zone = LastInstanceMapID
    if ZoneTables[zone] then
        for id, data in pairs(ZoneTables[zone]) do
            AddHud(id, data.icon, data.AreaID, data.x, data.y, data.r, data.g, data.b)
        end
    end
end

local function DelayedMapCheck()
    local _, _, _, _, _, _, _, mapID = GetInstanceInfo()
    if LastInstanceMapID == mapID then return end

    LastInstanceMapID = mapID
    DBM.HudMap:ClearAllEdges()

    if IsInInstance() then
        wipe(AddedHudIds)
    else
        CleanupPoints(mapID)
        ReAddHudIcons()
    end
end

---
-- Events & Ticker (Parented to WorldFrame to survive Alt+Z)

local eventFrame = CreateFrame("Frame", "QuestieDBMIntegrationFrame", WorldFrame)

eventFrame:SetScript("OnEvent", function(_, event)
    if event == "LOADING_SCREEN_DISABLED" then
        DelayedMapCheck()
        DBM:Schedule(1, DelayedMapCheck)
    elseif event == "PLAYER_ENTERING_WORLD"
        or event == "UI_SCALE_CHANGED"
        or event == "DISPLAY_SIZE_CHANGED" then
        UpdateUIVisibility()
    end
end)

-- This ticker lives on WorldFrame and will never sleep
local totalElapsed = 0
eventFrame:SetScript("OnUpdate", function(_, elapsed)
    totalElapsed = totalElapsed + elapsed
    if totalElapsed > 0.1 then -- Crisp 100ms response time
        totalElapsed = 0
        if QuestieHUDEnabled then
            UpdateUIVisibility()
        end
    end
end)

---
-- API

function QuestieDBMIntegration:EnableHUD()
    if not DBM or not DBM.HudMap or QuestieHUDEnabled then return end

    QuestieHUDEnabled = true

    eventFrame:RegisterEvent("LOADING_SCREEN_DISABLED")
    eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    eventFrame:RegisterEvent("UI_SCALE_CHANGED")
    eventFrame:RegisterEvent("DISPLAY_SIZE_CHANGED")

    DelayedMapCheck()

    DBM:Schedule(1, DelayedMapCheck)
    DBM:AddMsg(l10n("Questie has activated DBM HUD overlay"))
end

function QuestieDBMIntegration:SoftReset()
    CleanupPoints(9999)
    ReAddHudIcons()
end

function QuestieDBMIntegration:ClearAll(disable)
    if not DBM or not DBM.HudMap then return end

    for id in pairs(AddedHudIds) do
        DBM.HudMap:FreeEncounterMarkerByTarget(id, "Questie")
    end

    wipe(AddedHudIds)

    for k in pairs(ZoneTables) do
        wipe(ZoneTables[k])
    end

    if disable then
        QuestieHUDEnabled = false
        eventFrame:UnregisterAllEvents()
        eventFrame:SetScript("OnUpdate", nil)
        DBM:Unschedule(DelayedMapCheck)
    end
end

---
-- Public API (Register/Unregister)

function QuestieDBMIntegration:RegisterHudQuestIcon(id, icon, AreaID, x, y, r, g, b)
    if not QuestieHUDEnabled or not DBM then return end

    local _, _, instanceID = HBD:GetWorldCoordinatesFromZone(x, y, AreaID)
    if not ZoneTables[instanceID] then return end

    local entry = ZoneTables[instanceID]
    entry[id] = {icon = icon, AreaID = AreaID, x = x, y = y, r = r, g = g, b = b}

    if LastInstanceMapID == instanceID and not UIHidden and not HudSuspended then
        AddHud(id, icon, AreaID, x, y, r, g, b)
    end
end

function QuestieDBMIntegration:UnregisterHudQuestIcon(id)
    for _, zone in pairs(ZoneTables) do
        zone[id] = nil
    end
    RemoveHud(id)
end

---
-- Settings

function QuestieDBMIntegration:ChangeZoomLevel(zoom)
    if DBM and DBM.HudMap and QuestieHUDEnabled then
        DBM.HudMap:SetFixedZoom(zoom)
    end
end

function QuestieDBMIntegration:ChangeRefreshRate(rate)
    if DBM and DBM.HudMap and QuestieHUDEnabled and DBM.HudMap.Version then
        DBM.HudMap:SetFixedUpdateRate(math.max(rate, 0.01))
    end
end

---
-- Edge functions

function QuestieDBMIntegration:EdgeTo(id)
    if not DBM or not DBM.HudMap or UIHidden then return end
    if AddedHudIds[id .. playerName] then return end

    local marker = DBM.HudMap:GetEncounterMarker(id .. "Questie")
    if not marker then return end

    local playerMarker = DBM.HudMap:RegisterRangeMarkerOnPartyMember(
        id, "party", playerName, 0.1, nil, 0, 1, 0, 1, nil, false
    ):Appear()

    marker:EdgeTo(playerMarker, nil, nil, 0, 1, 0, 1)
    AddedHudIds[id .. playerName] = true
end

function QuestieDBMIntegration:ClearHudEdge(id)
    if AddedHudIds[id .. playerName] then
        AddedHudIds[id .. playerName] = nil
        if DBM and DBM.HudMap then
            DBM.HudMap:FreeEncounterMarkerByTarget(id, playerName)
        end
    end
end