local trinity =  require('cataObjectDB-trinity')
local mangos = require('cataObjectDB')
local wotlk = require('wotlkObjectDB')

local objectKeys = {
    ['name'] = 1, -- string
    ['questStarts'] = 2, -- table {questID(int),...}
    ['questEnds'] = 3, -- table {questID(int),...}
    ['spawns'] = 4, -- table {[zoneID(int)] = {coordPair(floatVector2D),...},...}
    ['zoneID'] = 5, -- guess as to where this object is most common
    ['factionID'] = 6, -- faction restriction mask (same as spawndb factionid)
}

for objId, data in pairs(mangos) do
    local tObj = trinity[objId]

    -- get spawns from trinity and add them to mangos
    if tObj then
        data[objectKeys.questStarts] = tObj[objectKeys.questStarts]
        data[objectKeys.questEnds] = tObj[objectKeys.questEnds]
        if (not data[objectKeys.spawns]) and tObj[objectKeys.spawns] then
            data[objectKeys.spawns] = tObj[objectKeys.spawns]
            data[objectKeys.zoneID] = tObj[objectKeys.zoneID]
        end
    end
end

mangos[186336] = wotlk[186336] -- Entrance to Onyxia's Lair

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

-- Some objects are missing entirely in mangos
-- But if they have good data it doesn't hurt to add them
print("checking for good data in trinity DB...")
for objId, data in pairsByKeys(trinity) do
    if not mangos[objId] and data[objectKeys.name] and data[objectKeys.spawns] then
        print("Mangos is missing the following object: " .. objId .. " " .. data[objectKeys.name])
        mangos[objId] = data
    end
end

print("checking for good data in wotlk DB...")
for objId, data in pairsByKeys(wotlk) do
    if not mangos[objId] and data[objectKeys.name] and data[objectKeys.spawns] then
        print("Mangos is missing the following object: " .. objId .. " " .. data[objectKeys.name])
        mangos[objId] = data
    end

    if mangos[objId] and (not mangos[objId][objectKeys.spawns]) and data[objectKeys.spawns] then
        mangos[objId][objectKeys.spawns] = data[objectKeys.spawns]
        mangos[objId][objectKeys.zoneID] = data[objectKeys.zoneID]
    end
end

-- print to "merged-file.lua"
local file = io.open("merged-file.lua", "w")
print("writing to merged-file.lua")
for objId, data in pairsByKeys(mangos) do
    -- build print string with npcId and data
    local printString = "[" .. objId .. "] = {"
    printString = printString .. "\"" .. data[objectKeys.name]:gsub("\"", "\\\"") .. "\","
    if data[objectKeys.questStarts] then
        printString = printString .. "{"
        for i, questID in ipairs(data[objectKeys.questStarts]) do
            printString = printString .. questID .. ","
        end
        printString = printString:sub(1, -2) -- remove trailing comma
        printString = printString .. "},"
    else
        printString = printString .. "nil,"
    end
    if data[objectKeys.questEnds] then
        printString = printString .. "{"
        for i, questID in ipairs(data[objectKeys.questEnds]) do
            printString = printString .. questID .. ","
        end
        printString = printString:sub(1, -2) -- remove trailing comma
        printString = printString .. "},"
    else
        printString = printString .. "nil,"
    end
    if data[objectKeys.spawns] then
        printString = printString .. "{"
        for zoneID, coords in pairsByKeys(data[objectKeys.spawns]) do
            printString = printString .. "[" .. zoneID .. "]={"
            for i, coord in ipairs(coords) do
                if coords[i+1] then
                    if coord[3] then
                        printString = printString .. "{" .. coord[1] .. "," .. coord[2] .. "," .. coord[3] .. "},"
                    else
                        printString = printString .. "{" .. coord[1] .. "," .. coord[2] .. "},"
                    end
                else
                    if coord[3] then
                        printString = printString .. "{" .. coord[1] .. "," .. coord[2] .. "," .. coord[3] .. "}"
                    else
                        printString = printString .. "{" .. coord[1] .. "," .. coord[2] .. "}"
                    end
                end
            end
            printString = printString .. "},"
        end
        printString = printString:sub(1, -2) -- remove trailing comma
        printString = printString .. "},"
    else
        printString = printString .. "nil,"
    end
    printString = printString .. data[objectKeys.zoneID]
    if data[objectKeys.factionID] then
        printString = printString .. "," .. data[objectKeys.factionID]
    end
    printString = printString .. "},"
    file:write(printString .. "\n")
end
print("Done")
