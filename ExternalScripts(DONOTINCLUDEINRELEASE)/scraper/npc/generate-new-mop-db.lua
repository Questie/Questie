local db = io.open("../../../Database/MoP/mopNpcDB.lua")
local scrapedDataFile = io.open("npc_data_db.lua")

local outputFile = io.open("mopNpcDB.lua", "w")

-- Read all lines from the current DB file
local currentDB = {}
for line in db:lines() do
    currentDB[#currentDB + 1] = line
end
db:close()

-- Read all lines from the new fixes file
local newFixes = {}
for line in scrapedDataFile:lines() do
    newFixes[#newFixes + 1] = line
end
scrapedDataFile:close()

local newFixesLineIndex = 1
-- Iterate through the current DB and merge with new fixes
for _, currentLine in ipairs(currentDB) do
    local newFixesLine = newFixes[newFixesLineIndex]
    -- If the new fixes line is nil, we have reached the end of the new fixes
    if (not newFixesLine) then
        outputFile:write(currentLine .. "\n")
    elseif currentLine == newFixesLine then
        -- If the current line matches the new fixes line, write it to the output
        outputFile:write(currentLine .. "\n")
        newFixesLineIndex = newFixesLineIndex + 1
    else
        -- Search for the ID in the current line
        local currentId = currentLine:match("%[(%d+)%]")
        local newFixesId = newFixes[newFixesLineIndex]:match("%[(%d+)%]")

        print("----")
        print("currentId", currentId)
        print("newFixesId", newFixesId)
        if (not currentId) or (not tonumber(currentId)) then
            outputFile:write(currentLine .. "\n")
        elseif currentId and newFixesId then
            if tonumber(currentId) < tonumber(newFixesId) then
                outputFile:write(currentLine .. "\n")
            elseif tonumber(currentId) > tonumber(newFixesId) then
                -- If the new fixes ID is smaller, write the new fix line
                while tonumber(currentId) > tonumber(newFixesId) do
                    outputFile:write(newFixes[newFixesLineIndex] .. "\n")
                    newFixesLineIndex = newFixesLineIndex + 1
                    if newFixesLineIndex > #newFixes then
                        outputFile:write(currentLine .. "\n")
                        break
                    end
                    newFixesId = newFixes[newFixesLineIndex]:match("%[(%d+)%]")
                    print("newFixesId", newFixesId)
                end
            else
                outputFile:write(currentLine .. "\n")
                newFixesLineIndex = newFixesLineIndex + 1
            end
        end
    end
end
