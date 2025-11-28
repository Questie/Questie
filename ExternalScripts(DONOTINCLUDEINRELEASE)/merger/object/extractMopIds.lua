local cata = require('data.cataObjectDB')
local mop = require('data.mopObjectDB')
local pairsByKeys = dofile("../pairsByKeys.lua")

-- iterate mop quests and write all IDs that are not in cata to "mop-ids.txt"
local mopIds = {}
for objectId, data in pairs(mop) do
    if not cata[objectId] then
        mopIds[objectId] = true
    end
end

-- write mopIds to file
local file = io.open("output/mopObjectIds.txt", "w")
for mopId, _ in pairsByKeys(mopIds) do
    file:write(mopId .. ",\n")
end
file:close()
