local cata = require('data.cataItemDB')
local mop = require('data.mopItemDB')

-- iterate mop items and write all IDs that are not in cata to "mopItemIds.txt"
local mopIds = {}
for itemId, data in pairs(mop) do
    if not cata[itemId] then
        table.insert(mopIds, itemId)
    end
end

-- write mopIds to file
local file = io.open("output/mopItemIds.txt", "w")
for _, mopId in ipairs(mopIds) do
    file:write(mopId .. "\n")
end
file:close()

