l10n = {
    questLookup = {}
}
QuestieLoader = {}
function QuestieLoader:ImportModule() return l10n end

GetLocale = function() return "deDE" end
dofile("../Localization/lookups/Classic/lookupQuests/deDE.lua")

local pairsByKeys = dofile("./merger/pairsByKeys.lua")

local quests = l10n.questLookup["deDE"]()

for _, v in pairs(quests) do
    v[2] = v[3]
    v[3] = nil
end


local file = io.open("../Localization/lookups/Classic/lookupQuests/deDE.lua", "w")
file:write("if GetLocale() ~= \"deDE\" then\
    return\
end\
\
---@type l10n\
local l10n = QuestieLoader:ImportModule(\"l10n\")\
\
l10n.questLookup[\"deDE\"] = loadstring([[return {\n")

for k, v in pairsByKeys(quests) do
    local line = "[" .. k .. "] = {"
    if v[1] == nil then
        line = line .. "nil, "
    else
        line = line .. "\"" .. v[1]:gsub("\"", "\\\"") .. "\", "
    end
    if v[2] == nil then
        line = line .. "nil},\n"
    else
        line = line .. "{"
        for _, obj in pairs(v[2]) do
            line = line .. "\"" .. obj:gsub("\"", "\\\"") .. "\","
        end
        -- remove last comma
        line = line:sub(1, -2)
        line = line .. "}},\n"
    end
    file:write(line)
end

file:write("}]])\n")
file:close()
