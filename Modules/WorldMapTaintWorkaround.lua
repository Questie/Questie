-- This must run as early as possible.
-- This should be independednt of Questie and all libraries.

local function doWorkaround()
    -- Blizzard's bugs #114 and #165
    -- HDB (and Questie fork of it) uses WorldMapFrame:AddDataProvider(  ).
    print("|cff30fc96Questie:|r |cffff0000Hiding drop-down menus on the World Map.|r This should stop taint issues spreading from World Map via drop-down menus.")
    --WorldMapZoneDropDown_Update = function() end
    --WorldMapContinentDropDown_Update = function() end
    WorldMapZoneMinimapDropDown_Update = function() end
    WorldMapZoneDropDown:Hide()
    WorldMapContinentDropDown:Hide()
    WorldMapZoneMinimapDropDown:Hide()
    --WorldMapMagnifyingGlassButton:Hide()
end

local _, finished = IsAddOnLoaded("Blizzard_WorldMap")

if finished then
    doWorkaround()
else
    local f = CreateFrame("Frame")
    local function addonLoaded(_, _, addOnName)
        if addOnName == "Blizzard_WorldMap" then
            doWorkaround()
        end
    end
    f:SetScript("OnEvent", addonLoaded)
    f:RegisterEvent("ADDON_LOADED")
end