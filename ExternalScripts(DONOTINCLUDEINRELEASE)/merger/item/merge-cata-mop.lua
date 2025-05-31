local cata = require('cataItemDB')
local mop = require('mopItemDB')

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

local function pairsByKeys (t, f)
    local a = {}
    for n in pairs(t) do table.insert(a, n) end
    table.sort(a, f)
    local i = 0      -- iterator variable
    local iter = function ()   -- iterator function
        i = i + 1
        if a[i] == nil then return nil
        else return a[i], t[a[i]]
        end
    end
    return iter
end

-- print to "merged-file.lua"
local file = io.open("merged-file.lua", "w")
print("writing to merged-file.lua")
for itemId, data in pairsByKeys(mop) do
    -- build print string with npcId and data
    local printString = "[" .. itemId .. "] = {"
    printString = printString .. "'" .. data[itemKeys.name]:gsub("'", "\\'") .. "',"
    if data[itemKeys.npcDrops] then
        printString = printString .. "{"
        for _, npcId in ipairs(data[itemKeys.npcDrops]) do
            printString = printString .. npcId .. ","
        end
        printString = printString:sub(1, -2) -- remove trailing comma
        printString = printString .. "},"
    else
        printString = printString .. "nil,"
    end
    if data[itemKeys.objectDrops] then
        printString = printString .. "{"
        for _, objectId in ipairs(data[itemKeys.objectDrops]) do
            printString = printString .. objectId .. ","
        end
        printString = printString:sub(1, -2) -- remove trailing comma
        printString = printString .. "},"
    else
        printString = printString .. "nil,"
    end
    if data[itemKeys.itemDrops] then
        printString = printString .. "{"
        for _, itemId in ipairs(data[itemKeys.itemDrops]) do
            printString = printString .. itemId .. ","
        end
        printString = printString:sub(1, -2) -- remove trailing comma
        printString = printString .. "},"
    else
        printString = printString .. "nil,"
    end
    if data[itemKeys.startQuest] then
        printString = printString .. data[itemKeys.startQuest] .. ","
    else
        printString = printString .. "nil,"
    end
    if data[itemKeys.questRewards] then
        printString = printString .. "{"
        for _, questId in ipairs(data[itemKeys.questRewards]) do
            printString = printString .. questId .. ","
        end
        printString = printString:sub(1, -2) -- remove trailing comma
        printString = printString .. "},"
    else
        printString = printString .. "nil,"
    end
    if data[itemKeys.flags] then
        printString = printString .. data[itemKeys.flags] .. ","
    else
        printString = printString .. "nil,"
    end
    if data[itemKeys.foodType] then
        printString = printString .. data[itemKeys.foodType] .. ","
    else
        printString = printString .. "nil,"
    end
    printString = printString .. data[itemKeys.itemLevel] .. ","
    printString = printString .. data[itemKeys.requiredLevel] .. ","
    printString = printString .. data[itemKeys.ammoType] .. ","
    printString = printString .. data[itemKeys.class] .. ","
    printString = printString .. data[itemKeys.subClass] .. ","
    if data[itemKeys.vendors] then
        printString = printString .. "{"
        for _, npcId in ipairs(data[itemKeys.vendors]) do
            printString = printString .. npcId .. ","
        end
        printString = printString:sub(1, -2) -- remove trailing comma
        printString = printString .. "},"
    else
        printString = printString .. "nil,"
    end
    if data[itemKeys.relatedQuests] then
        printString = printString .. "{"
        for _, questId in ipairs(data[itemKeys.relatedQuests]) do
            printString = printString .. questId .. ","
        end
        printString = printString:sub(1, -2) -- remove trailing comma
        printString = printString .. "},"
    else
        printString = printString .. "nil,"
    end
    -- remove trailing 'nil,' from relatedQuests
    if printString:sub(-4) == "nil," then
        printString = printString:sub(1, -5)
    end
    -- remove trailing 'nil,' from vendors
    if printString:sub(-4) == "nil," then
        printString = printString:sub(1, -5)
    end
    -- remove trailing comma
    printString = printString:sub(1, -2)
    printString = printString .. "},"

    file:write(printString .. "\n")
end
print("Done")
