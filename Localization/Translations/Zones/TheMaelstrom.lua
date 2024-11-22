---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")


local maelstromLocales = {
    ["Deepholm"] = {
        ["ptBR"] = "Geodomo",
        ["ruRU"] = "Подземье",
        ["deDE"] = "Tiefenheim",
        ["koKR"] = "심원의 영지",
        ["esMX"] = "Infralar",
        ["enUS"] = true,
        ["frFR"] = "Le Tréfonds",
        ["esES"] = "Infralar",
        ["zhTW"] = "地深之源",
        ["zhCN"] = "深岩之洲",
    },
    ["The Lost Isles"] = {
        ["ptBR"] = "Ilhas Perdidas",
        ["ruRU"] = "Затерянные острова",
        ["deDE"] = "Die Verlorenen Inseln",
        ["koKR"] = "잃어버린 섬",
        ["esMX"] = "Las Islas Perdidas",
        ["enUS"] = true,
        ["frFR"] = "Les îles Perdues",
        ["esES"] = "Las Islas Perdidas",
        ["zhTW"] = "失落群島",
        ["zhCN"] = "失落群岛",
    },
    ["Kezan"] = {
        ["ptBR"] = true,
        ["ruRU"] = "Кезан",
        ["deDE"] = true,
        ["koKR"] = "케잔",
        ["esMX"] = true,
        ["enUS"] = true,
        ["frFR"] = true,
        ["esES"] = true,
        ["zhTW"] = "凱贊",
        ["zhCN"] = "科赞",
    },
}

for k, v in pairs(maelstromLocales) do
    l10n.translations[k] = v
end
