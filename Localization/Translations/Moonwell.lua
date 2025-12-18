---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local moonwellLocales = {
    ["Moonwell"] = {
        ["enUS"] = true,
        ["deDE"] = "Mondbrunnen",
        ["esES"] = "Poza de la Luna",
        ["esMX"] = "Poza de la Luna",
        ["frFR"] = "Puits de lune",
        ["koKR"] = "달샘",
        ["ptBR"] = "Poço Lunar",
        ["ruRU"] = "Лунный колодец",
        ["zhCN"] = "月亮井",
        ["zhTW"] = "月井",
    },
}

for k, v in pairs(moonwellLocales) do
    l10n.translations[k] = v
end