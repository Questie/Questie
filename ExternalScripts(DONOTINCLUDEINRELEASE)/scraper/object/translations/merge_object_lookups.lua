local locales = {"cn", "de", "es", "fr", "ko", "pt", "ru"}
local questieLocales = {"zhCN", "deDE", "esES", "frFR", "koKR", "ptBR", "ruRU"}

for i, locale in ipairs(locales) do
    local questieLocale = questieLocales[i]
    local newNames = require("object_names_" .. locale)
    local oldNames = require("lookups." .. questieLocale)

    print("Merging " .. locale .. " into " .. questieLocale)
    for id, name in pairs(newNames) do
        oldNames[id] = name
    end

    print("Writing " .. questieLocale)
    local file = io.open("lookups/" .. questieLocale .. "_new.lua", "w")
    file:write("if GetLocale() ~= \"" .. questieLocale .. "\" then\n")
    file:write("    return\n")
    file:write("end\n")
    file:write("\n")
    file:write("---@type l10n\n")
    file:write("local l10n = QuestieLoader:ImportModule(\"l10n\")\n")
    file:write("\n")
    file:write("l10n.objectLookup[\"" .. questieLocale .. "\"] = loadstring([[return {\n")

    local sorted = {}
    for id, name in pairs(oldNames) do
        table.insert(sorted, {id = id, name = name})
    end
    table.sort(sorted, function(a, b) return a.id < b.id end)

    for _, entry in ipairs(sorted) do
        local name = entry.name:gsub("\"", "\\\"")
        file:write("[" .. entry.id .. "] = \"" .. name .. "\",\n")
    end
    file:write("}]])\n")
    file:close()
    print("Done")
end
