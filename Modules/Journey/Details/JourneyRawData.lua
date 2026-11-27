---Everything the database knows about something, as text. Shown in the details while debugging is enabled.
---@class JourneyRawData
local JourneyRawData = QuestieLoader:CreateModule("JourneyRawData")

---@param value any
---@param indent string
---@return string
local function _Format(value, indent)
    if type(value) ~= "table" then
        return tostring(value)
    end
    local lines = {"{"}
    for key, entry in pairs(value) do
        table.insert(lines, indent .. "    [" .. tostring(key) .. "]=" .. _Format(entry, indent .. "    "))
    end
    table.insert(lines, indent .. "}")
    return table.concat(lines, "\n")
end

---@param rows JourneyDetails.Row[]
---@param data table
---@param keys table<string, number>
function JourneyRawData.AddRows(rows, data, keys)
    if not Questie.db.profile.debugEnabled then
        return
    end

    table.insert(rows, {type = "gap", height = 10})
    table.insert(rows, {type = "text", text = Questie:Colorize("Raw data (shown because debug is enabled):", "red")})
    for key in pairs(keys) do
        table.insert(rows, {type = "text", text = Questie:Colorize(key, "yellow") .. ": " .. _Format(data[key], "")})
    end
end

return JourneyRawData
