local print = print

-- WoW addon namespace
local addonName = "Questie"
local addonTable = {}

local function loadTOC(file)
    local rfile = io.open(file, "r")
    for line in rfile:lines() do
        if string.len(line) > 1 and string.byte(line, 1) ~= 35 and (not string.find(line, ".xml")) then
            line = line:gsub("\\", "/")
            line = line:gsub("%s+", "")
            local pcallResult, errorMessage
            local chunck = loadfile(line)
            if chunck then
                pcallResult, errorMessage = pcall(chunck, addonName, addonTable)
            end
            if (not pcallResult) then
                if errorMessage then
                    print("Error loading " .. line .. ": " .. errorMessage)
                else
                    print("Error loading " .. line .. " - No errorMessage")
                end
            end
        end
    end
end

return loadTOC
