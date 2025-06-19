local cata = require('cataQuestDB')
local mop = require('mopQuestDB')

-- iterate mop quests and write all IDs that are not in cata to "mop-ids.txt"
local mopIds = {}
for questId, data in pairs(mop) do
    if not cata[questId] then
        table.insert(mopIds, questId)
    end
end

-- write mopIds to file
local file = io.open("mopQuestIds.txt", "w")
for _, mopId in ipairs(mopIds) do
    file:write(mopId .. "\n")
end
file:close()
