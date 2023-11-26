---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local tutorialLocals = {
    ["Welcome to Questie"] = {
        ["ptBR"] = false,
        ["ruRU"] = "Добро пожаловать в Questie",
        ["deDE"] = "Willkommen bei Questie",
        ["koKR"] = false,
        ["esMX"] = "Bienvenidos a Questie",
        ["enUS"] = true,
        ["zhCN"] = "欢迎来到 Questie",
        ["zhTW"] = false,
        ["esES"] = "Bienvenidos a Questie",
        ["frFR"] = "Bienvenue sur Questie",
    },
    ["With WotLK Phase 4 Blizzard introduced their own quest objective system.\n\nPlease choose the objective style you want to use:"] = {
        ["ptBR"] = false,
        ["ruRU"] = "В 4-й фазе Гнева Короля Лича разработчики Blizzard представили их собственную систему целей заданий.\n\nПожалуйста, выберите стиль целей, который вы будете использовать:",
        ["deDE"] = "Mit der Phase 4 von WotLK hat Blizzard sein eigenes Questziel-System eingeführt.\n\nBitte wähle den Stil den du nutzen möchtest:",
        ["koKR"] = false,
        ["esMX"] = "Con la Fase 4 de WoTLK, Blizzard introdujo su propio sistema de objetivos de misiones.\n\nElija el estilo objetivo que deseas utilizar:",
        ["enUS"] = true,
        ["zhCN"] = "随着WLK的第4阶段开启，暴雪引入了自己的任务提示系统。\n\n请选择要使用的目标样式：",
        ["zhTW"] = false,
        ["esES"] = "Con la Fase 4 de WoTLK, Blizzard introdujo su propio sistema de objetivos de misiones.\n\nElija el estilo objetivo que deseas utilizar:",
        ["frFR"] = "Avec WotLK Phase 4, Blizzard a introduit son propre système d'objectifs de quête.\n\nVeuillez choisir le style d'objectif que vous souhaitez utiliser :",
    },
    ["Questie Objectives"] = {
        ["ptBR"] = false,
        ["ruRU"] = "Цели Questie",
        ["deDE"] = "Questie Questziele",
        ["koKR"] = false,
        ["esMX"] = "Objetivos de Questie",
        ["enUS"] = true,
        ["zhCN"] = "Questie 提示",
        ["zhTW"] = false,
        ["esES"] = "Objetivos de Questie",
        ["frFR"] = "Objectifs de Questie",
    },
    ["pfQuest Objectives"] = {
        ["ptBR"] = false,
        ["ruRU"] = "Цели pfQuest",
        ["deDE"] = "pfQuest Questziele",
        ["koKR"] = false,
        ["esMX"] = "Objetivos de pfQuest",
        ["enUS"] = true,
        ["zhCN"] = "pfQuest 提示",
        ["zhTW"] = false,
        ["esES"] = "Objetivos de pfQuest",
        ["frFR"] = "Objectifs de pfQuest",
    },
    ["Blizzard Objectives"] = {
        ["ptBR"] = false,
        ["ruRU"] = "Цели Blizzard",
        ["deDE"] = "Blizzard Questziele",
        ["koKR"] = false,
        ["esMX"] = "Objetivos de Blizzard",
        ["enUS"] = true,
        ["zhCN"] = "暴雪自带提示",
        ["zhTW"] = false,
        ["esES"] = "Objetivos de Blizzard",
        ["frFR"] = "Objectifs de Blizzard",
    }
}

for k, v in pairs(tutorialLocals) do
    l10n.translations[k] = v
end
