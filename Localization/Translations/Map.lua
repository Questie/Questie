local mapLocales = {
    ["Are you sure you want to hide the quest '%s'?\nIf this quest isn't actually available, please report it to us!"] = {
        ["ptBR"] = "Tem certeza de que deseja ocultar a missão? Se essa missão não estiver realmente disponível, informe-nos!",
        ["ruRU"] = "Вы уверены, что хотите скрыть задание '%s'?",
        ["deDE"] = "Bist du sicher, dass du die Quest '%s' verstecken möchtest?",
        ["koKR"] = "정말 '%s' 퀘스트를 숨길까요?\n만약 해당 퀘스트가 수행할 수 없는 퀘스트라면, 저희에게 알려주세요!",
        ["esMX"] = "¿Seguro que quieres ocultar la misión '%s'?\nSi la misión no está disponible, por favor informanos de ello!",
        ["enUS"] = true,
        ["zhCN"] = "你确定要隐藏任务： %s吗？",
        ["zhTW"] = "你確定要隱藏任務： %s嗎？如果實際上這個任務並不存在，請回報給開發團隊！",
        ["esES"] = "¿Seguro que quieres ocultar la misión '%s'?\nSi la misión no está disponible, por favor informanos de ello!",
        ["frFR"] = "Êtes-vous sûr de vouloir masquer la quête '%s'?\n Si cette quête n'est pas réellement disponible, merci de nous la signaler !",
    },
    ["Unknown Zone"] = {
        ["ptBR"] = nil,
        ["ruRU"] = nil,
        ["deDE"] = "Unbekannte Zone",
        ["koKR"] = nil,
        ["esMX"] = nil,
        ["enUS"] = true,
        ["zhCN"] = nil,
        ["zhTW"] = nil,
        ["esES"] = nil,
        ["frFR"] = nil,
    }
}

for k, v in pairs(mapLocales) do
    l10n.translations[k] = v
end
