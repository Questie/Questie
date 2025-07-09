local cata = require('data.cataObjectDB')
local mop = require('data.mopObjectDB')

-- iterate mop quests and write all IDs that are not in cata to "mop-ids.txt"
local mopIds = {}
for objectId, data in pairs(mop) do
    if not cata[objectId] then
        table.insert(mopIds, objectId)
    end
end

-- write mopIds to file
local file = io.open("mopObjectIds.txt", "w")
for _, mopId in ipairs(mopIds) do
    file:write(mopId .. "\n")
end
file:close()
