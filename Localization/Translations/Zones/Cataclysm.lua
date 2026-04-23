---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")


local cataclysmLocales = {
    ["Elemental Bonds"] = {
        ["enUS"] = true,
        ["deDE"] = "Elementare Bande",
        ["esES"] = "Vínculos elementales",
        ["esMX"] = "Vínculos elementales",
        ["frFR"] = "Liens élémentaires",
        ["koKR"] = "정령의 속박",
        ["ptBR"] = "Prisão Elemental",
        ["ruRU"] = "Власть стихий",
        ["zhCN"] = "元素誓约",
        ["zhTW"] = "元素桎梏",
    },
    ["Firelands Invasion"] = {
        ["enUS"] = true,
        ["deDE"] = "Einmarsch in die Feuerlande",
        ["esES"] = "Invasión de las Tierras de Fuego",
        ["esMX"] = "Invasión de las Tierras de Fuego",
        ["frFR"] = "Invasion des terres de Feu",
        ["koKR"] = "불의 땅 침공",
        ["ptBR"] = "Invasão às Terras do Fogo",
        ["ruRU"] = "Вторжение на Огненные Просторы",
        ["zhCN"] = "进攻火焰之地",
        ["zhTW"] = "火源之界進軍行動",
    },
    ["The Zandalari"] = {
        ["enUS"] = true,
        ["deDE"] = "Die Zandalari",
        ["esES"] = "Los Zandalari",
        ["esMX"] = "Los Zandalari",
        ["frFR"] = "Les Zandalari",
        ["koKR"] = "잔달라 부족",
        ["ptBR"] = "Os Zandalari",
        ["ruRU"] = "Племя Зандалар",
        ["zhCN"] = "赞达拉",
        ["zhTW"] = "贊達拉",
    },
    ["Molten Front"] = {
        ["enUS"] = true,
        ["deDE"] = "Geschmolzene Front",
        ["esES"] = "Frente de Magma",
        ["esMX"] = "Frente de Magma",
        ["frFR"] = "Front du Magma",
        ["koKR"] = "녹아내린 전초지",
        ["ptBR"] = "Front Ígneo",
        ["ruRU"] = "Огненная передовая",
        ["zhCN"] = "熔火前线",
        ["zhTW"] = "熔岩前線",
    },
}

for k, v in pairs(cataclysmLocales) do
    l10n.translations[k] = v
end
