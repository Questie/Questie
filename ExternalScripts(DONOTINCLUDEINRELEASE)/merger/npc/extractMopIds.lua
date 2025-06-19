local cata = require('data.cataNpcDB')
local mop = require('data.mopNpcDB')

-- iterate mop NPCs and write all IDs that are not in cata to "mopNpcIds.txt"
local mopIds = {}
for npcId, data in pairs(mop) do
    if not cata[npcId] then
        table.insert(mopIds, npcId)
    end
end

-- write mopIds to file
local file = io.open("mopNpcIds.txt", "w")
for _, mopId in ipairs(mopIds) do
    file:write(mopId .. "\n")
end
file:close()
