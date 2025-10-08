local classic = require('data.classicNpcDB')
local tbc = require('data.tbcNpcDB')
local wotlk = require('data.wotlkNpcDB')
local cata = require('data.cataNpcDB')

local printToFile = require('printToFile')
local tbcAndWotlkZoneIds = dofile('../tbcAndWotlkZoneIds.lua')

local npcKeys = {
    ['name'] = 1, -- string
    ['minLevelHealth'] = 2, -- int
    ['maxLevelHealth'] = 3, -- int
    ['minLevel'] = 4, -- int
    ['maxLevel'] = 5, -- int
    ['rank'] = 6, -- int, see https://github.com/cmangos/issues/wiki/creature_template#rank
    ['spawns'] = 7, -- table {[zoneID(int)] = {coordPair(floatVector2D),...},...}
    ['waypoints'] = 8, -- table {[zoneID(int)] = {coordPair(floatVector2D),...},...}
    ['zoneID'] = 9, -- guess as to where this NPC is most common
    ['questStarts'] = 10, -- table {questID(int),...}
    ['questEnds'] = 11, -- table {questID(int),...}
    ['factionID'] = 12, -- int, see https://github.com/cmangos/issues/wiki/FactionTemplate.dbc
    ['friendlyToFaction'] = 13, -- string, Contains "A" and/or "H" depending on NPC being friendly towards those factions. nil if hostile to both.
    ['subName'] = 14, -- string, The title or function of the NPC, e.g. "Weapon Vendor"
    ['npcFlags'] = 15, -- int, Bitmask containing various flags about the NPCs function (Vendor, Trainer, Flight Master, etc.).
    -- For flag values see https://github.com/cmangos/mangos-classic/blob/172c005b0a69e342e908f4589b24a6f18246c95e/src/game/Entities/Unit.h#L536
}

-- generate diff of IDs which were added in TBC
local tbcIds = {}
for npcId, _ in pairs(tbc) do
    if (not classic[npcId]) then
        tbcIds[npcId] = true
    end
end

-- generate diff of IDs which were added in WotLK
local wotlkIds = {}
for npcId, _ in pairs(wotlk) do
    if (not tbc[npcId]) and (not classic[npcId]) then
        wotlkIds[npcId] = true
    end
end

-- iterate cata NPCs and replace spawn data with WotLK data if available
for npcId, data in pairs(cata) do
    if tbcIds[npcId] then
        local tbcData = tbc[npcId]
        if tbcData[npcKeys.spawns] and tbcAndWotlkZoneIds[tbcData[npcKeys.zoneID]] then
            cata[npcId][npcKeys.spawns] = tbcData[npcKeys.spawns]
            cata[npcId][npcKeys.zoneID] = tbcData[npcKeys.zoneID]
        end
        if tbcData[npcKeys.waypoints] and tbcAndWotlkZoneIds[tbcData[npcKeys.zoneID]] then
            cata[npcId][npcKeys.waypoints] = tbcData[npcKeys.waypoints]
        end
    elseif wotlkIds[npcId] then
        local wotlkData = wotlk[npcId]
        if wotlkData[npcKeys.spawns] and tbcAndWotlkZoneIds[wotlkData[npcKeys.zoneID]] then
            cata[npcId][npcKeys.spawns] = wotlkData[npcKeys.spawns]
            cata[npcId][npcKeys.zoneID] = wotlkData[npcKeys.zoneID]
        end
        if wotlkData[npcKeys.waypoints] and tbcAndWotlkZoneIds[wotlkData[npcKeys.zoneID]] then
            cata[npcId][npcKeys.waypoints] = wotlkData[npcKeys.waypoints]
        end
    end
end

printToFile(cata, npcKeys)
