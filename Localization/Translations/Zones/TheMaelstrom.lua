---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")


local maelstromLocales = {
    ["Deepholm"] = {
        ["enUS"] = true,
        ["deDE"] = "Tiefenheim",
        ["esES"] = "Infralar",
        ["esMX"] = "Infralar",
        ["frFR"] = "Le Tréfonds",
        ["koKR"] = "심원의 영지",
        ["ptBR"] = "Geodomo",
        ["ruRU"] = "Подземье",
        ["zhCN"] = "深岩之洲",
        ["zhTW"] = "地深之源",
    },
    ["The Lost Isles"] = {
        ["enUS"] = true,
        ["deDE"] = "Die Verlorenen Inseln",
        ["esES"] = "Las Islas Perdidas",
        ["esMX"] = "Las Islas Perdidas",
        ["frFR"] = "Les îles Perdues",
        ["koKR"] = "잃어버린 섬",
        ["ptBR"] = "Ilhas Perdidas",
        ["ruRU"] = "Затерянные острова",
        ["zhCN"] = "失落群岛",
        ["zhTW"] = "失落群島",
    },
    ["Kezan"] = {
        ["enUS"] = true,
        ["deDE"] = true,
        ["esES"] = true,
        ["esMX"] = true,
        ["frFR"] = true,
        ["koKR"] = "케잔",
        ["ptBR"] = true,
        ["ruRU"] = "Кезан",
        ["zhCN"] = "科赞",
        ["zhTW"] = "凱贊",
    },
}

for k, v in pairs(maelstromLocales) do
    l10n.translations[k] = v
end
