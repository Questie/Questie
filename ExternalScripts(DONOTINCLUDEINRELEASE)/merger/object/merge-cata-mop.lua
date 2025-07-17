local cata = require('data.cataObjectDB')
local mop = require('data.mopObjectDB')
local mopTrinity = require('data.mopObjectDB-trinity')
local wowhead = require('data.wowheadObjectDB')

local printToFile = require('printToFile')

local objectKeys = {
    ['name'] = 1, -- string
    ['questStarts'] = 2, -- table {questID(int),...}
    ['questEnds'] = 3, -- table {questID(int),...}
    ['spawns'] = 4, -- table {[zoneID(int)] = {coordPair(floatVector2D),...},...}
    ['zoneID'] = 5, -- guess as to where this object is most common
    ['factionID'] = 6, -- faction restriction mask (same as spawndb factionid)
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

for objId, data in pairs(mop) do
    local cataObject = cata[objId]

    if cataObject and (not startingZones[data[objectKeys.zoneID]]) then
        mop[objId] = cataObject
    else
        local trinityObject = mopTrinity[objId]
        if trinityObject then
            -- iterate objectKeys and take the values from mopTrinity if mop doesn't have them
            for _, index in pairs(objectKeys) do
                if ((not data[index]) or data[index] == "") and trinityObject[index] and trinityObject[index] ~= "" then
                    mop[objId][index] = trinityObject[index]
                end
            end

            if data[objectKeys.name] == "unk name" then
                mop[objId][objectKeys.name] = trinityObject[objectKeys.name]
            end
        end

        local wowheadObject = wowhead[objId]
        if wowheadObject then
            -- iterate objectKeys and take the values from wowhead if mop doesn't have them
            for _, index in pairs(objectKeys) do
                if ((not data[index]) or data[index] == "") and wowheadObject[index] and wowheadObject[index] ~= "" then
                    mop[objId][index] = wowheadObject[index]
                end
            end
        end

        if data[objectKeys.factionID] == 0 and cataObject and cataObject[objectKeys.factionID] ~= 0 then
            mop[objId][objectKeys.factionID] = cataObject[objectKeys.factionID]
        end
    end
end

-- add cata objects that are not in mop
for objId, data in pairs(cata) do
    if not mop[objId] then
        mop[objId] = data
    end
end

-- add wowhead objects that are not in mop
for objId, data in pairs(wowhead) do
    if not mop[objId] then
        mop[objId] = data
    end
end

printToFile(mop, objectKeys)
