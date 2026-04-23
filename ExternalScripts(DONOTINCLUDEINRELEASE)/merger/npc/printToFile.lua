local lfs = require("lfs")
local pairsByKeys = dofile("../pairsByKeys.lua")

local function printToFile(npcData, npcKeys)
    lfs.mkdir("output")

    local file = io.open("output/merged-file.lua", "w")
    print("writing to output/merged-file.lua")

    for npcId, data in pairsByKeys(npcData) do
        -- build print string with npcId and data
        local printString = "[" .. npcId .. "] = {"
        printString = printString .. "'" .. data[npcKeys.name]:gsub("'", "\\'") .. "',"
        printString = printString .. data[npcKeys.minLevelHealth] .. ","
        printString = printString .. data[npcKeys.maxLevelHealth] .. ","
        printString = printString .. data[npcKeys.minLevel] .. ","
        printString = printString .. data[npcKeys.maxLevel] .. ","
        printString = printString .. data[npcKeys.rank] .. ","
        if data[npcKeys.spawns] and next(data[npcKeys.spawns]) then
            printString = printString .. "{"
            for zoneID, coords in pairsByKeys(data[npcKeys.spawns]) do
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
        if data[npcKeys.waypoints] and next(data[npcKeys.waypoints]) then
            printString = printString .. "{"
            for zoneID, coords in pairs(data[npcKeys.waypoints]) do
                printString = printString .. "[" .. zoneID .. "]={{"
                for i, coord in pairs(coords[1]) do
                    if coords[1][i+1] then
                        printString = printString .. "{" .. coord[1] .. "," .. coord[2] .. "},"
                    else
                        printString = printString .. "{" .. coord[1] .. "," .. coord[2] .. "}"
                    end
                end
                printString = printString .. "}},"
            end
            printString = printString:sub(1, -2) -- remove trailing comma
            printString = printString .. "},"
        else
            printString = printString .. "nil,"
        end
        printString = printString .. data[npcKeys.zoneID] .. ","
        if data[npcKeys.questStarts] then
            printString = printString .. "{"
            for i, questID in ipairs(data[npcKeys.questStarts]) do
                printString = printString .. questID .. ","
            end
            if printString:sub(-1) == "," then
                printString = printString:sub(1, -2) -- remove trailing comma
            end
            printString = printString .. "},"
        else
            printString = printString .. "nil,"
        end
        if data[npcKeys.questEnds] then
            printString = printString .. "{"
            for i, questID in ipairs(data[npcKeys.questEnds]) do
                printString = printString .. questID .. ","
            end
            if printString:sub(-1) == "," then
                printString = printString:sub(1, -2) -- remove trailing comma
            end
            printString = printString .. "},"
        else
            printString = printString .. "nil,"
        end
        printString = printString .. data[npcKeys.factionID] .. ","
        if data[npcKeys.friendlyToFaction] then
            printString = printString .. "\"" .. data[npcKeys.friendlyToFaction] .. "\","
        else
            printString = printString .. "nil,"
        end
        if data[npcKeys.subName] and data[npcKeys.subName] ~= "" then
            printString = printString .. "\"" .. data[npcKeys.subName]:gsub("\"", "\\\"") .. "\","
        else
            printString = printString .. "nil,"
        end
        printString = printString .. data[npcKeys.npcFlags]
        printString = printString .. "},"
        file:write(printString .. "\n")
    end

    print("Done")
end

return printToFile
