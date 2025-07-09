local trinity =  require('data.cataNpcDB-trinity')
local mangos = require('data.cataNpcDB')
local wotlk = require('data.wotlkNpcDB')

local printToFile = require('printToFile')

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

for npcId, data in pairs(mangos) do
    local tNPC = trinity[npcId]

    -- get spawns from trinity and add them to mangos
    if tNPC then
        if (not data[npcKeys.spawns]) and tNPC[npcKeys.spawns] then
            data[npcKeys.spawns] = tNPC[npcKeys.spawns]
            data[npcKeys.zoneID] = tNPC[npcKeys.zoneID]
        end
        if tNPC[npcKeys.questStarts] then
            data[npcKeys.questStarts] = tNPC[npcKeys.questStarts]
        end
        if tNPC[npcKeys.questEnds] then
            data[npcKeys.questEnds] = tNPC[npcKeys.questEnds]
        end
    end

    -- get waypoints from wotlk and add them to mangos
    if wotlk[npcId] and wotlk[npcId][npcKeys.waypoints] then
        data[npcKeys.waypoints] = wotlk[npcId][npcKeys.waypoints]
    end
end

printToFile(mangos, npcKeys)
