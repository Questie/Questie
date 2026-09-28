---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")


local zephrasIsleLocales = {
    ["Zephras Isle"] = {
        ["enUS"] = true,
        ["deDE"] = "Die Insel Zephras",
        ["esES"] = "Isla de Zephras",
        ["esMX"] = "Isla Zephras",
        ["frFR"] = "Île de Zéphras",
        ["koKR"] = "제프라스 섬",
        ["ptBR"] = "Ilha de Zefras",
        ["ruRU"] = "Остров Зефрис",
        ["zhCN"] = "泽风岛",
        ["zhTW"] = "微風島",
    },
}

for k, v in pairs(zephrasIsleLocales) do
    l10n.translations[k] = v
end
