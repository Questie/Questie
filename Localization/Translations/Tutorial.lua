---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local tutorialLocals = {
    ["Welcome to Questie"] = {
        ["ptBR"] = nil,
        ["ruRU"] = "Добро пожаловать в Questie",
        ["deDE"] = "Willkommen bei Questie",
        ["koKR"] = nil,
        ["esMX"] = nil,
        ["enUS"] = true,
        ["zhCN"] = nil,
        ["zhTW"] = nil,
        ["esES"] = nil,
        ["frFR"] = "Bienvenue sur Questie",
    },
    ["With WotLK Phase 4 Blizzard introduced their own quest objective system.\n\nPlease choose the objective style you want to use:"] = {
        ["ptBR"] = nil,
        ["ruRU"] = "В 4-й фазе Гнева Короля Лича разработчики Blizzard представили их собственную систему целей заданий.\n\nПожалуйста, выберите стиль целей, который вы будете использовать:",
        ["deDE"] = "Mit der Phase 4 von WotLK hat Blizzard sein eigenes Questziel-System eingeführt.\n\nBitte wähle den Stil den du nutzen möchtest:",
        ["koKR"] = nil,
        ["esMX"] = nil,
        ["enUS"] = true,
        ["zhCN"] = nil,
        ["zhTW"] = nil,
        ["esES"] = nil,
        ["frFR"] = "Avec WotLK Phase 4, Blizzard a introduit son propre système d'objectifs de quête.\n\nVeuillez choisir le style d'objectif que vous souhaitez utiliser :",
    },
    ["Questie Objectives"] = {
        ["ptBR"] = nil,
        ["ruRU"] = "Цели Questie",
        ["deDE"] = "Questie Questziele",
        ["koKR"] = nil,
        ["esMX"] = nil,
        ["enUS"] = true,
        ["zhCN"] = nil,
        ["zhTW"] = nil,
        ["esES"] = nil,
        ["frFR"] = "Objectifs de Questie",
    },
    ["pfQuest Objectives"] = {
        ["ptBR"] = nil,
        ["ruRU"] = "Цели pfQuest",
        ["deDE"] = "pdfQuest Questziele",
        ["koKR"] = nil,
        ["esMX"] = nil,
        ["enUS"] = true,
        ["zhCN"] = nil,
        ["zhTW"] = nil,
        ["esES"] = nil,
        ["frFR"] = "Objectifs de pfQuest",
    },
    ["Blizzard Objectives"] = {
        ["ptBR"] = nil,
        ["ruRU"] = "Цели Blizzard",
        ["deDE"] = "Blizzard Questziele",
        ["koKR"] = nil,
        ["esMX"] = nil,
        ["enUS"] = true,
        ["zhCN"] = nil,
        ["zhTW"] = nil,
        ["esES"] = nil,
        ["frFR"] = "Objectifs de Blizzard",
    }
}

for k, v in pairs(tutorialLocals) do
    l10n.translations[k] = v
end
