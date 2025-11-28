---@class Moonwell
local Moonwell = QuestieLoader:CreateModule("Moonwell")

---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")
---@type QuestieMap
local QuestieMap = QuestieLoader:ImportModule("QuestieMap")

Moonwell.data = {
    -- Teldrassil Moonwells
    [19549] = true, -- Starting area moonwell in Shadowglen
    [19550] = true, -- Village moonwell in Starbreeze Village
    [19551] = true, -- Moonwell at the Pools of Arlithrien
    [19552] = true, -- Moonwell in Oracle Glade
    -- Ashenvale Moonwells
    [20806] = true, -- Sacred moonwell in central Ashenvale
    -- Darkshore Moonwells
    [174795] = true, -- Main moonwell in Auberdine
    [175337] = true, -- Secondary Auberdine moonwell
    [177274] = true, -- Darkshore moonwell
    -- Felwood Moonwells
    [177275] = true, -- Moonwell in Felwood
    [177276] = true, -- Corrupted moonwell in Felwood
    [148501] = true, -- Corrupted moonwell with spell focus
    -- Moonglade Moonwells
    [177273] = true, -- Sacred moonwell in Moonglade
    -- Feralas Moonwells
    [181632] = true, -- Moonwell at Thalanaar outpost
    -- Generic/Multi-location Moonwells
    [177232] = true, -- Generic moonwell
    [177272] = true, -- Multi-zone Moonwell
    [177277] = true, -- Ashenvale moonwell
    [177278] = true, -- Multi-zone moonwell
    [177279] = true, -- Feralas moonwell
    [177280] = true, -- Multi-zone moonwell
    [177281] = true, -- Multi-zone moonwell
    [177666] = true, -- Multi-zone Moonwell
}

function Moonwell:ShowMoonwell(objectID, icon, scale)
    icon = icon or "Interface\\Icons\\inv_fabric_moonrag_01.blp"
    scale = scale or 0.6
    local title = Questie:Colorize(l10n("Moonwell"), "white")
    QuestieMap:ShowObject(objectID, icon, scale, title, nil, true, "moonwell")
end

function Moonwell:ShowAll()
    for objectID in pairs(Moonwell.data) do
        Moonwell:ShowMoonwell(objectID)
    end
end

function Moonwell:HideAll()
    for objectID in pairs(Moonwell.data) do
        QuestieMap:UnloadManualFrames(objectID, "moonwell")
    end
end

return Moonwell