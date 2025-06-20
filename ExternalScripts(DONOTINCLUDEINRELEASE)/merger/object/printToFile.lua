local lfs = require("lfs")
local pairsByKeys = dofile("../pairsByKeys.lua")

local function printToFile(objectData, objectKeys)
    lfs.mkdir("output")

    local file = io.open("output/merged-file.lua", "w")
    print("writing to output/merged-file.lua")

    for objId, data in pairsByKeys(objectData) do
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
end

return printToFile
