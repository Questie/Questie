dofile("YellowAfterLife.lua")
local csv = dofile("csv.lua")

dofile("objects.lua") -- load QuestieObjects
dofile("items.lua") -- load QuestieItems

function LoadItemSources()
    local f = csv.open("newItemSources.csv")
    local r = {}
    for fields in f:lines() do
        if fields[1] ~= "item_name" then
            if r[fields[1]] == nil then
                r[fields[1]] = {
                    contained = {}
                }
            end
            r[fields[1]].contained[fields[2]] = 1
        end
    end
    return r
end

function LoadObjectData()
    local f = csv.open("newObjects.csv")
    local r = {}
    for fields in f:lines() do
        if fields[1] ~= "id" then
            if r[fields[1]] == nil then
                r[fields[1]] = {
                    name = fields[2],
                    locations = {}
                }
            end
            table.insert(r[fields[1]].locations, {fields[3], fields[4], fields[5]})
        end
    end
    return r
end

function Write(table, tableName, fileName)
    local output = serialize(table, true, 0, tableName)
    local file,err = io.open(fileName, "wb")
    file:write(output)
    file:close()
end

function Main()
    local newItemSources = LoadItemSources()
    for itemName, sources in pairs(newItemSources) do
        if QuestieItems[itemName] then
            QuestieItems[itemName].locations = nil
            QuestieItems[itemName].locationCount = nil
            QuestieItems[itemName].contained = nil
            QuestieItems[itemName].contained_id = sources.contained
        else
            QuestieItems[itemName] = {
                ["contained_id"] = sources.contained
            }
        end
    end

    local newObjects = LoadObjectData()
    for objectId, objectInfo in pairs(newObjects) do
        if QuestieObjects[objectInfo.name] then
            QuestieObjects[objectInfo.name] = nil
        end
    end


    Write(QuestieItems, "QuestieItems", "outputItems.lua")
    Write(newObjects, "QuestieNewObjects", "outputNewObjects.lua")
    Write(QuestieObjects, "QuestieObjects", "outputOldObjects.lua")
end

Main()