local cata = require('data.cataNpcDB')
local mop = require('data.mopNpcDB')
local pairsByKeys = dofile("../pairsByKeys.lua")

-- iterate mop NPCs and write all IDs that are not in cata to "mopNpcIds.txt"
local mopIds = {}
for npcId, data in pairs(mop) do
    if not cata[npcId] then
        mopIds[npcId] = true
    end
end

-- write mopIds to file
local file = io.open("output/mopNpcIds.txt", "w")
for mopId, _ in pairsByKeys(mopIds) do
    file:write(mopId .. ",\n")
end
file:close()
