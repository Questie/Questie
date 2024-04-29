local db = require("cataItemDB")
local ids = require("quest_item_ids")

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
    ['teachesSpell'] = 16, -- int, spellID taught by this item upon use
}

local corrections = {}

for _, id in pairs(ids) do
    if (not db[id]) then
        print("Item " .. id .. " not found in the database")
    elseif db[id][itemKeys.class] ~= 12 then
        print("Item " .. id .. " is not a quest item:", db[id][itemKeys.class])
        table.insert(corrections, id)
    end
end

-- write to corrections.lua
local file = io.open("corrections.lua", "w")
for _, id in pairs(corrections) do
    file:write("        " .. "[" .. id .. "] = { -- " .. db[id][itemKeys.name] .. "\n")
    file:write("            [itemKeys.class] = itemClasses.QUEST,\n")
    file:write("        },\n")
end
