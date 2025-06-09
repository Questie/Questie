---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local mopObjectiveLocales = {
    ["Use the Wind Stone"] = {
        ["enUS"] = true,
        ["deDE"] = "Benutze den Windstein",
        ["esES"] = false,
        ["esMX"] = false,
        ["frFR"] = false,
        ["koKR"] = false,
        ["ptBR"] = false,
        ["ruRU"] = false,
        ["zhCN"] = false,
        ["zhTW"] = false,
    },
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
    ["Bring the Injured Sailor to Delora Lionheart"] = {
        ["enUS"] = true,
        ["deDE"] = "Bringe den verletzten Matrosen zu Delora Löwenherz",
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
