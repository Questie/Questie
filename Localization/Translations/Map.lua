---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local mapLocales = {
    ["Are you sure you want to hide the quest '%s'?\nIf this quest isn't actually available, please report it to us!"] = {
        ["ptBR"] = "Você tem certeza que deseja ocultar a missão '%s'?\nSe essa missão não estiver disponível, por favor informe-nos!",
        ["ruRU"] = "Вы уверены, что хотите скрыть задание '%s'?\nЕсли это задание на самом деле недоступно, то сообщите нам об этом, пожалуйста!",
        ["deDE"] = "Bist du sicher, dass du die Quest '%s' verstecken möchtest?",
        ["koKR"] = "정말 '%s' 퀘스트를 숨길까요?\n만약 해당 퀘스트가 수행할 수 없는 퀘스트라면, 저희에게 알려주세요!",
        ["esMX"] = "¿Seguro que quieres ocultar la misión '%s'?\nSi la misión no está disponible, ¡por favor informanos de ello!",
        ["enUS"] = true,
        ["zhCN"] = "你确定要隐藏任务： %s吗？",
        ["zhTW"] = "是否確定要隱藏任務 '%s'? \n如果實際上這個任務並不存在，請回報給開發團隊!",
        ["esES"] = "¿Seguro que quieres ocultar la misión '%s'?\nSi la misión no está disponible, por favor informanos de ello!",
        ["frFR"] = "Êtes-vous sûr de vouloir cacher la quête '%s'?\n Si cette quête n'est pas réellement disponible, merci de nous la signaler !",
    },
    ["Unknown Zone"] = {
        ["ptBR"] = "Zona desconhecida",
        ["ruRU"] = "Неизвестная зона",
        ["deDE"] = "Unbekannte Zone",
        ["koKR"] = "미확인 구역",
        ["esMX"] = "Zona Desconocida",
        ["enUS"] = true,
        ["zhCN"] = "未知区域",
        ["zhTW"] = "未知區域",
        ["esES"] = "Zona Desconocida",
        ["frFR"] = "Zone inconnue",
    }
}

for k, v in pairs(mapLocales) do
    l10n.translations[k] = v
end
