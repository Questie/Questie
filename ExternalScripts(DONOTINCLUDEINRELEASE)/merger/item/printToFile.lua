local lfs = require("lfs")
local pairsByKeys = dofile("../pairsByKeys.lua")

local function printToFile(itemData, itemKeys)
    lfs.mkdir("output")

    local file = io.open("output/merged-file.lua", "w")
    print("writing to output/merged-file.lua")

    for itemId, data in pairsByKeys(itemData) do
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
end

return printToFile
