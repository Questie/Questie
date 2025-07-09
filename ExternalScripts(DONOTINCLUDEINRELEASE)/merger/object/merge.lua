local trinity =  require('data.cataObjectDB-trinity')
local mangos = require('data.cataObjectDB')
local wotlk = require('data.wotlkObjectDB')

local printToFile = require('printToFile')

local objectKeys = {
    ['name'] = 1, -- string
    ['questStarts'] = 2, -- table {questID(int),...}
    ['questEnds'] = 3, -- table {questID(int),...}
    ['spawns'] = 4, -- table {[zoneID(int)] = {coordPair(floatVector2D),...},...}
    ['zoneID'] = 5, -- guess as to where this object is most common
    ['factionID'] = 6, -- faction restriction mask (same as spawndb factionid)
}

for objId, data in pairs(mangos) do
    local tObj = trinity[objId]

    -- get spawns from trinity and add them to mangos
    if tObj then
        data[objectKeys.questStarts] = tObj[objectKeys.questStarts]
        data[objectKeys.questEnds] = tObj[objectKeys.questEnds]
        if (not data[objectKeys.spawns]) and tObj[objectKeys.spawns] then
            data[objectKeys.spawns] = tObj[objectKeys.spawns]
            data[objectKeys.zoneID] = tObj[objectKeys.zoneID]
        end
    end
end

mangos[186336] = wotlk[186336] -- Entrance to Onyxia's Lair

-- Some objects are missing entirely in mangos
-- But if they have good data it doesn't hurt to add them
print("checking for good data in trinity DB...")
for objId, data in pairs(trinity) do
    if not mangos[objId] and data[objectKeys.name] and data[objectKeys.spawns] then
        print("Mangos is missing the following object: " .. objId .. " " .. data[objectKeys.name])
        mangos[objId] = data
    end
end

print("checking for good data in wotlk DB...")
for objId, data in pairs(wotlk) do
    if not mangos[objId] and data[objectKeys.name] and data[objectKeys.spawns] then
        print("Mangos is missing the following object: " .. objId .. " " .. data[objectKeys.name])
        mangos[objId] = data
    end

    if mangos[objId] and (not mangos[objId][objectKeys.spawns]) and data[objectKeys.spawns] then
        mangos[objId][objectKeys.spawns] = data[objectKeys.spawns]
        mangos[objId][objectKeys.zoneID] = data[objectKeys.zoneID]
    end
end

printToFile(mangos)
