---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local mapLocales = {
    ["Are you sure you want to hide the quest '%s'?\nIf this quest isn't actually available, please report it to us!"] = {
        ["enUS"] = true,
        ["deDE"] = "Bist du sicher, dass du die Quest '%s' verstecken möchtest?",
        ["esES"] = "¿Estás seguro que quieres ocultar la misión '%s'?\nSi la misión no está disponible, por favor informanos de ello!",
        ["esMX"] = "¿Estás seguro que quieres ocultar la misión '%s'?\nSi la misión no está disponible, ¡por favor informanos de ello!",
        ["frFR"] = "Êtes-vous sûr de vouloir cacher la quête « %s » ?\n Si cette quête n'est pas réellement disponible, merci de nous la signaler !",
        ["koKR"] = "정말 '%s' 퀘스트를 숨길까요?\n만약 해당 퀘스트가 수행할 수 없는 퀘스트라면, 저희에게 알려주세요!",
        ["ptBR"] = "Você tem certeza que deseja ocultar a missão '%s'?\nSe essa missão não estiver disponível, por favor informe-nos!",
        ["ruRU"] = "Вы уверены, что хотите скрыть задание '%s'?\nЕсли это задание на самом деле недоступно, то сообщите нам об этом, пожалуйста!",
        ["zhCN"] = "你确定要隐藏任务 %s 吗？\n如果此任务实际上并不存在，请向开发团队报告！",
        ["zhTW"] = "是否確定要隱藏任務 '%s'? \n如果實際上這個任務並不存在，請回報給開發團隊!",
    },
    ["You abandoned the quest '%s'.\nDo you want to hide its icon?"] = {
        ["enUS"] = true,
        ["deDE"] = "Du hast die Quest '%s' abgebrochen.\nMöchtest du ihr Icon verstecken?",
        ["esES"] = "Has abandonado la misión '%s'.\n¿Quieres ocultar su icono?",
        ["esMX"] = "Has abandonado la misión '%s'.\n¿Quieres ocultar su icono?",
        ["frFR"] = "Vous avez abandonné la quête « %s ».\nVoulez-vous cacher son icône ?",
        ["koKR"] = "'%s' 퀘스트를 포기했습니다.\n이 퀘스트의 아이콘을 숨길까요?",
        ["ptBR"] = "Você abandonou a missão '%s'.\nDeseja ocultar o ícone dela?",
        ["ruRU"] = "Вы отказались от задания '%s'.\nСкрыть его значок?",
        ["zhCN"] = "你放弃了任务 '%s'。\n是否隐藏该任务的图标？",
        ["zhTW"] = "你放棄了任務 '%s'。\n是否隱藏該任務的圖示？",
    },
    ["Unknown Zone"] = {
        ["enUS"] = true,
        ["deDE"] = "Unbekannte Zone",
        ["esES"] = "Zona desconocida",
        ["esMX"] = "Zona desconocida",
        ["frFR"] = "Zone inconnue",
        ["koKR"] = "미확인 구역",
        ["ptBR"] = "Zona desconhecida",
        ["ruRU"] = "Неизвестная зона",
        ["zhCN"] = "未知区域",
        ["zhTW"] = "未知區域",
    }
}

for k, v in pairs(mapLocales) do
    l10n.translations[k] = v
end
