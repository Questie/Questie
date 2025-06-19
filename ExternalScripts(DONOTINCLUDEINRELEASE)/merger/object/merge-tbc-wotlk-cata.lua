local classic = require('classicObjectDB')
local tbc = require('tbcObjectDB')
local wotlk = require('wotlkObjectDB')
local cata = require('cataObjectDB')

local printToFile = require('printToFile')

local objectKeys = {
    ['name'] = 1, -- string
    ['questStarts'] = 2, -- table {questID(int),...}
    ['questEnds'] = 3, -- table {questID(int),...}
    ['spawns'] = 4, -- table {[zoneID(int)] = {coordPair(floatVector2D),...},...}
    ['zoneID'] = 5, -- guess as to where this object is most common
    ['factionID'] = 6, -- faction restriction mask (same as spawndb factionid)
}

-- generate diff of IDs which were added in TBC
local tbcIds = {}
for objectId, _ in pairs(tbc) do
    if (not classic[objectId]) then
        tbcIds[objectId] = true
    end
end

-- generate diff of IDs which were added in WotLK
local wotlkIds = {}
for objectId, _ in pairs(wotlk) do
    if (not tbc[objectId]) and (not classic[objectId]) then
        wotlkIds[objectId] = true
    end
end

-- iterate cata objects and replace spawn data with WotLK data if available
for objectId, data in pairs(cata) do
    if tbcIds[objectId] then
        local tbcData = tbc[objectId]
        if tbcData[objectKeys.spawns] then
            cata[objectId][objectKeys.spawns] = tbcData[objectKeys.spawns]
            cata[objectId][objectKeys.zoneID] = tbcData[objectKeys.zoneID]
        end
    elseif wotlkIds[objectId] then
        local wotlkData = wotlk[objectId]
        if wotlkData[objectKeys.spawns] then
            cata[objectId][objectKeys.spawns] = wotlkData[objectKeys.spawns]
            cata[objectId][objectKeys.zoneID] = wotlkData[objectKeys.zoneID]
        end
    end
end

printToFile(cata, objectKeys)
