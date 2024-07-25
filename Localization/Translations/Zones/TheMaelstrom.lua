---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")


local maelstromLocales = {
    ["Deepholm"] = {
        ["ptBR"] = false,
        ["ruRU"] = "Подземье",
        ["deDE"] = false,
        ["koKR"] = false,
        ["esMX"] = false,
        ["enUS"] = true,
        ["frFR"] = false,
        ["esES"] = false,
        ["zhTW"] = false,
        ["zhCN"] = false,
    },
    ["The Lost Isles"] = {
        ["ptBR"] = false,
        ["ruRU"] = "Затерянные острова",
        ["deDE"] = false,
        ["koKR"] = false,
        ["esMX"] = false,
        ["enUS"] = true,
        ["frFR"] = false,
        ["esES"] = false,
        ["zhTW"] = false,
        ["zhCN"] = false,
    },
    ["Kezan"] = {
        ["ptBR"] = false,
        ["ruRU"] = "Кезан",
        ["deDE"] = false,
        ["koKR"] = false,
        ["esMX"] = false,
        ["enUS"] = true,
        ["frFR"] = false,
        ["esES"] = false,
        ["zhTW"] = false,
        ["zhCN"] = false,
    },
}

for k, v in pairs(maelstromLocales) do
    l10n.translations[k] = v
end
