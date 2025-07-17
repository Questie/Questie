local cata = require('data.cataNpcDB')
local mop = require('data.mopNpcDB')
local mopTrinity = require('data.mopNpcDB-trinity')
local mopWowhead = require('data.wowheadNpcDB')

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

-- With MoP all starting zones got an actual map, so we can not use the cata data for those.
local startingZones = {
    [6170] = true, -- Northshire
    [6176] = true, -- Coldridge Valley
    [6450] = true, -- Shadowglen
    [6451] = true, -- Valley of Trials
    [6452] = true, -- Camp Narache
    [6453] = true, -- Echo Isles
    [6454] = true, -- Deathknell
    [6455] = true, -- Sunstrider Isle
    [6456] = true, -- Ammen Vale
    [6457] = true, -- New Tinkertown
}

for npcId, data in pairs(mop) do
    local cataNpc = cata[npcId]
    if cataNpc and (not startingZones[data[npcKeys.zoneID]]) then
        mop[npcId] = cataNpc
    else
        local trinityNpc = mopTrinity[npcId]
        if trinityNpc then
            -- iterate npcKeys and take the values from mopTrinity if mop doesn't have them
            for _, index in pairs(npcKeys) do
                if not data[index] and trinityNpc[index] then
                    mop[npcId][index] = trinityNpc[index]
                end
            end

            if trinityNpc[npcKeys.spawns] then
                mop[npcId][npcKeys.spawns] = {}
                for zoneId, _ in pairs(trinityNpc[npcKeys.spawns]) do
                    if zoneId ~= 0 then
                        if not mop[npcId][npcKeys.zoneID] or mop[npcId][npcKeys.zoneID] == 0 then
                            mop[npcId][npcKeys.zoneID] = zoneId
                        end
                        mop[npcId][npcKeys.spawns][zoneId] = trinityNpc[npcKeys.spawns][zoneId]
                    end
                end
            end
        end

        local wowheadNpc = mopWowhead[npcId]
        if wowheadNpc then
            mop[npcId][npcKeys.friendlyToFaction] = wowheadNpc[npcKeys.friendlyToFaction]
            if not data[npcKeys.spawns] and wowheadNpc[npcKeys.spawns] then
                mop[npcId][npcKeys.spawns] = {}
                for zoneId, _ in pairs(wowheadNpc[npcKeys.spawns]) do
                    local zoneIdOverride = zoneId
                    if zoneId == 9105 then
                        zoneIdOverride = 5840 -- retail wowhead lists 9105 as Vale of Eternal Blossoms
                    end

                    -- Filter out non-MoP zones
                    if (zoneId <= 6852 or zoneIdOverride <= 6852) or zoneId == 14288 or zoneId == 14334 or zoneId == 15306 or zoneId == 15318 then
                        if not mop[npcId][npcKeys.zoneID] or mop[npcId][npcKeys.zoneID] == 0 then
                            mop[npcId][npcKeys.zoneID] = zoneIdOverride
                        end
                        mop[npcId][npcKeys.spawns][zoneIdOverride] = wowheadNpc[npcKeys.spawns][zoneId]
                    end
                end
            end
            if not data[npcKeys.questStarts] then
                mop[npcId][npcKeys.questStarts] = wowheadNpc[npcKeys.questStarts]
            end
            if not data[npcKeys.questEnds] then
                mop[npcId][npcKeys.questEnds] = wowheadNpc[npcKeys.questEnds]
            end
        end
    end
end

-- add cata NPCs that are not in mop
for npcId, data in pairs(cata) do
    if not mop[npcId] then
        mop[npcId] = data
    end
end

-- add trinity NPCs that are not in mop
for npcId, data in pairs(mopTrinity) do
    if not mop[npcId] then
        mop[npcId] = data
    end
end

printToFile(mop, npcKeys)
