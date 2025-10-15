---@class Moonwells
local Moonwells = QuestieLoader:CreateModule("Moonwells")

---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")
---@type QuestieMap
local QuestieMap = QuestieLoader:ImportModule("QuestieMap")

Moonwells.data = {
    -- Teldrassil Moonwells
    19549, -- Starting area moonwell in Shadowglen
    19550, -- Village moonwell in Starbreeze Village
    19551, -- Moonwell at the Pools of Arlithrien
    19552, -- Moonwell in Oracle Glade
    -- Ashenvale Moonwells
    20806, -- Sacred moonwell in central Ashenvale
    -- Darkshore Moonwells
    174795, -- Main moonwell in Auberdine
    175337, -- Secondary Auberdine moonwell
    177274, -- Darkshore moonwell
    -- Felwood Moonwells
    177275, -- Moonwell in Felwood
    177276, -- Corrupted moonwell in Felwood
    148501, -- Corrupted moonwell with spell focus
    -- Moonglade Moonwells
    177273, -- Sacred moonwell in Moonglade
    -- Feralas Moonwells
    181632, -- Moonwell at Thalanaar outpost
    -- Generic/Multi-location Moonwells
    177232, -- Generic moonwell
    177272, -- Multi-zone Moonwell
    177277, -- Ashenvale moonwell
    177278, -- Multi-zone moonwell
    177279, -- Feralas moonwell
    177280, -- Multi-zone moonwell
    177281, -- Multi-zone moonwell
    177666, -- Multi-zone Moonwell
}

function Moonwells:ShowMoonwell(objectID, icon, scale)
    icon = icon or "Interface\\Icons\\inv_fabric_moonrag_01.blp"
    scale = scale or 0.6
    local title = Questie:Colorize(l10n("Moonwell"), "white")
    QuestieMap:ShowObject(objectID, icon, scale, title, nil, true, "moonwell")
end

function Moonwells:ShowAll()
    for _, objectID in ipairs(Moonwells.data) do
        Moonwells:ShowMoonwell(objectID)
    end
end

function Moonwells:HideAll()
    for _, objectID in ipairs(Moonwells.data) do
        QuestieMap:UnloadManualFrames(objectID, "moonwell")
    end
end

return Moonwells