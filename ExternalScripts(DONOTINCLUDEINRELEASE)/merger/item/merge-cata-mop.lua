local cata = require('data.cataItemDB')
local mop = require('data.mopItemDB')

local printToFile = require('printToFile')

local itemKeys = {
    ['name'] = 1, -- string
    ['npcDrops'] = 2, -- table or nil, NPC IDs
    ['objectDrops'] = 3, -- table or nil, object IDs
    ['itemDrops'] = 4, -- table or nil, item IDs
    ['startQuest'] = 5, -- int or nil, ID of the quest started by this item
    ['questRewards'] = 6, -- table or nil, quest IDs
    ['flags'] = 7, -- int or nil, see: https://github.com/cmangos/issues/wiki/Item_template#flags
    ['foodType'] = 8, -- int or nil, see https://github.com/cmangos/issues/wiki/Item_template#foodtype
    ['itemLevel'] = 9, -- int, the level of this item
    ['requiredLevel'] = 10, -- int, the level required to equip/use this item
    ['ammoType'] = 11, -- int,
    ['class'] = 12, -- int,
    ['subClass'] = 13, -- int,
    ['vendors'] = 14, -- table or nil, NPC IDs
    ['relatedQuests'] = 15, -- table or nil, IDs of quests that are related to this item
}

for itemId, data in pairs(mop) do
    -- Override mop entry with cata, since the data is better
    local cataItem = cata[itemId]
    if cataItem then
        mop[itemId] = cataItem
    end
end

-- add cata items that are not in mop
for itemId, data in pairs(cata) do
    if not mop[itemId] then
        mop[itemId] = data
    end
end

printToFile(mop, itemKeys)
