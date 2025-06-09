---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local mopObjectiveLocales = {
    ["Use the Firework Launcher"] = {
        ["enUS"] = true,
        ["deDE"] = "Benutze die Raketenzünder",
        ["esES"] = false,
        ["esMX"] = false,
        ["frFR"] = false,
        ["koKR"] = false,
        ["ptBR"] = false,
        ["ruRU"] = false,
        ["zhCN"] = false,
        ["zhTW"] = false,
    },
}

for k, v in pairs(mopObjectiveLocales) do
    l10n.translations[k] = v
end
