---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")


local cataclysmLocales = {
    ["Elemental Bonds"] = {
        ["ptBR"] = "Prisão Elemental",
        ["ruRU"] = "Власть стихий",
        ["deDE"] = "Elementare Bande",
        ["koKR"] = "정령의 속박",
        ["esMX"] = "Vínculos elementales",
        ["enUS"] = true,
        ["frFR"] = "Liens élémentaires",
        ["esES"] = "Vínculos elementales",
        ["zhTW"] = "元素桎梏",
        ["zhCN"] = "元素誓约",
    },
    ["Firelands Invasion"] = {
        ["ptBR"] = "Invasão às Terras do Fogo",
        ["ruRU"] = "Вторжение на Огненные Просторы",
        ["deDE"] = "Einmarsch in die Feuerlande",
        ["koKR"] = "불의 땅 침공",
        ["esMX"] = "Invasión de las Tierras de Fuego",
        ["enUS"] = true,
        ["frFR"] = "Invasion des terres de Feu",
        ["esES"] = "Invasión de las Tierras de Fuego",
        ["zhTW"] = "火源之界進軍行動",
        ["zhCN"] = "进攻火焰之地",
    },
    ["The Zandalari"] = {
        ["ptBR"] = "Os Zandalari",
        ["ruRU"] = "Племя Зандалар",
        ["deDE"] = "Die Zandalari",
        ["koKR"] = "잔달라 부족",
        ["esMX"] = "Los Zandalari",
        ["enUS"] = true,
        ["frFR"] = "Les Zandalari",
        ["esES"] = "Los Zandalari",
        ["zhTW"] = "贊達拉",
        ["zhCN"] = "赞达拉",
    },
    ["Molten Front"] = {
        ["ptBR"] = "Front Ígneo",
        ["ruRU"] = "Огненная передовая",
        ["deDE"] = "Geschmolzene Front",
        ["koKR"] = "녹아내린 전초지",
        ["esMX"] = "Frente de Magma",
        ["enUS"] = true,
        ["frFR"] = "Front du Magma",
        ["esES"] = "Frente de Magma",
        ["zhTW"] = "熔岩前線",
        ["zhCN"] = "熔火前线",
    },
}

for k, v in pairs(cataclysmLocales) do
    l10n.translations[k] = v
end
