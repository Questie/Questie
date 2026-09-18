---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local locales = {
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
    ["Anvil"] = {
        ["enUS"] = true,
        ["deDE"] = "Amboss",
        ["esES"] = "Yunque",
        ["esMX"] = "Yunque",
        ["frFR"] = "Enclume",
        ["koKR"] = "모루",
        ["ptBR"] = "Bigorna",
        ["ruRU"] = "Наковальня",
        ["zhCN"] = "铁砧",
        ["zhTW"] = "鐵砧",
    },
    ["Forge"] = {
        ["enUS"] = true,
        ["deDE"] = "Schmiede",
        ["esES"] = "Forja",
        ["esMX"] = "Forja",
        ["frFR"] = "Forge",
        ["koKR"] = "가열로",
        ["ptBR"] = "Forja",
        ["ruRU"] = "Горн",
        ["zhCN"] = "熔炉",
        ["zhTW"] = "熔爐",
    },
    ["Alchemy Lab"] = {
        ["enUS"] = true,
        ["deDE"] = "Alchemielabor",
        ["esES"] = "Laboratorio de alquimia",
        ["esMX"] = "Laboratorio de alquimia",
        ["frFR"] = "Laboratoire d'alchimie",
        ["koKR"] = "연금술 실험대",
        ["ptBR"] = "Laboratório de Alquimia",
        ["ruRU"] = "Алхимическая лаборатория",
        ["zhCN"] = "炼金台",
        ["zhTW"] = "鍊金實驗室",
    },
}

for k, v in pairs(locales) do
    l10n.translations[k] = v
end
