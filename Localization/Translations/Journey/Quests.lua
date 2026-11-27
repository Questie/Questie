---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

-- The tab of the quests of the Journey: its overview and the details of what is in it
local questsLocales = {
    ["Good for your level"] = {
        ["enUS"] = true,
        ["deDE"] = "Passend für deine Stufe", -- AI 🤖
        ["esES"] = "Adecuado para tu nivel", -- AI 🤖
        ["esMX"] = "Adecuado para tu nivel", -- AI 🤖
        ["frFR"] = "Adapté à votre niveau", -- AI 🤖
        ["koKR"] = "내 레벨에 적합", -- AI 🤖
        ["ptBR"] = "Adequado para o seu nível", -- AI 🤖
        ["ruRU"] = "Подходит для вашего уровня", -- AI 🤖
        ["zhCN"] = "适合你的等级", -- AI 🤖
        ["zhTW"] = "適合你的等級", -- AI 🤖
    },
    ["%s of %s completed"] = {
        ["enUS"] = true,
        ["deDE"] = "%s von %s abgeschlossen", -- AI 🤖
        ["esES"] = "%s de %s completadas", -- AI 🤖
        ["esMX"] = "%s de %s completadas", -- AI 🤖
        ["frFR"] = "%s sur %s terminées", -- AI 🤖
        ["koKR"] = "%s / %s 완료", -- AI 🤖
        ["ptBR"] = "%s de %s concluídas", -- AI 🤖
        ["ruRU"] = "Выполнено: %s из %s", -- AI 🤖
        ["zhCN"] = "已完成 %s / %s", -- AI 🤖
        ["zhTW"] = "已完成 %s / %s", -- AI 🤖
    },
    ["Current Zone"] = {
        ["enUS"] = true,
        ["deDE"] = "Aktuelles Gebiet", -- AI 🤖
        ["esES"] = "Zona actual", -- AI 🤖
        ["esMX"] = "Zona actual", -- AI 🤖
        ["frFR"] = "Zone actuelle", -- AI 🤖
        ["koKR"] = "현재 지역", -- AI 🤖
        ["ptBR"] = "Zona atual", -- AI 🤖
        ["ruRU"] = "Текущая зона", -- AI 🤖
        ["zhCN"] = "当前区域", -- AI 🤖
        ["zhTW"] = "目前區域", -- AI 🤖
    },
    ["Where"] = {
        ["enUS"] = true,
        ["deDE"] = "Wo", -- AI 🤖
        ["esES"] = "Dónde", -- AI 🤖
        ["esMX"] = "Dónde", -- AI 🤖
        ["frFR"] = "Où", -- AI 🤖
        ["koKR"] = "위치", -- AI 🤖
        ["ptBR"] = "Onde", -- AI 🤖
        ["ruRU"] = "Где", -- AI 🤖
        ["zhCN"] = "位置", -- AI 🤖
        ["zhTW"] = "位置", -- AI 🤖
    },
    ["With all quests you can do now: %s"] = {
        ["enUS"] = true,
        ["deDE"] = "Mit allen Quests, die du jetzt machen kannst: %s", -- AI 🤖
        ["esES"] = "Con todas las misiones que puedes hacer ahora: %s", -- AI 🤖
        ["esMX"] = "Con todas las misiones que puedes hacer ahora: %s", -- AI 🤖
        ["frFR"] = "Avec toutes les quêtes possibles maintenant : %s", -- AI 🤖
        ["koKR"] = "지금 할 수 있는 모든 퀘스트를 마치면: %s", -- AI 🤖
        ["ptBR"] = "Com todas as missões que você pode fazer agora: %s", -- AI 🤖
        ["ruRU"] = "Со всеми заданиями, доступными сейчас: %s", -- AI 🤖
        ["zhCN"] = "完成当前所有可做的任务后：%s", -- AI 🤖
        ["zhTW"] = "完成目前所有可做的任務後：%s", -- AI 🤖
    },
    ["this quest"] = {
        ["enUS"] = true,
        ["deDE"] = "diese Quest", -- AI 🤖
        ["esES"] = "esta misión", -- AI 🤖
        ["esMX"] = "esta misión", -- AI 🤖
        ["frFR"] = "cette quête", -- AI 🤖
        ["koKR"] = "이 퀘스트", -- AI 🤖
        ["ptBR"] = "esta missão", -- AI 🤖
        ["ruRU"] = "это задание", -- AI 🤖
        ["zhCN"] = "本任务", -- AI 🤖
        ["zhTW"] = "本任務", -- AI 🤖
    },
    ["start with this one"] = {
        ["enUS"] = true,
        ["deDE"] = "mit dieser beginnen", -- AI 🤖
        ["esES"] = "empieza por esta", -- AI 🤖
        ["esMX"] = "empieza con esta", -- AI 🤖
        ["frFR"] = "commencez par celle-ci", -- AI 🤖
        ["koKR"] = "이것부터 시작", -- AI 🤖
        ["ptBR"] = "comece por esta", -- AI 🤖
        ["ruRU"] = "начните с этого", -- AI 🤖
        ["zhCN"] = "从这里开始", -- AI 🤖
        ["zhTW"] = "從這裡開始", -- AI 🤖
    },
    ["Starts this quest"] = {
        ["enUS"] = true,
        ["deDE"] = "Beginnt diese Quest", -- AI 🤖
        ["esES"] = "Inicia esta misión", -- AI 🤖
        ["esMX"] = "Inicia esta misión", -- AI 🤖
        ["frFR"] = "Débute cette quête", -- AI 🤖
        ["koKR"] = "이 퀘스트를 시작합니다", -- AI 🤖
        ["ptBR"] = "Inicia esta missão", -- AI 🤖
        ["ruRU"] = "Выдает это задание", -- AI 🤖
        ["zhCN"] = "开始此任务", -- AI 🤖
        ["zhTW"] = "開始此任務", -- AI 🤖
    },
    ["Ends this quest"] = {
        ["enUS"] = true,
        ["deDE"] = "Beendet diese Quest", -- AI 🤖
        ["esES"] = "Finaliza esta misión", -- AI 🤖
        ["esMX"] = "Finaliza esta misión", -- AI 🤖
        ["frFR"] = "Termine cette quête", -- AI 🤖
        ["koKR"] = "이 퀘스트를 완료합니다", -- AI 🤖
        ["ptBR"] = "Conclui esta missão", -- AI 🤖
        ["ruRU"] = "Принимает это задание", -- AI 🤖
        ["zhCN"] = "结束此任务", -- AI 🤖
        ["zhTW"] = "結束此任務", -- AI 🤖
    },
    ["Starts and ends this quest"] = {
        ["enUS"] = true,
        ["deDE"] = "Beginnt und beendet diese Quest", -- AI 🤖
        ["esES"] = "Inicia y finaliza esta misión", -- AI 🤖
        ["esMX"] = "Inicia y finaliza esta misión", -- AI 🤖
        ["frFR"] = "Débute et termine cette quête", -- AI 🤖
        ["koKR"] = "이 퀘스트를 시작하고 완료합니다", -- AI 🤖
        ["ptBR"] = "Inicia e conclui esta missão", -- AI 🤖
        ["ruRU"] = "Выдает и принимает это задание", -- AI 🤖
        ["zhCN"] = "开始并结束此任务", -- AI 🤖
        ["zhTW"] = "開始並結束此任務", -- AI 🤖
    },
    ["Also available there"] = {
        ["enUS"] = true,
        ["deDE"] = "Dort ebenfalls verfügbar", -- AI 🤖
        ["esES"] = "También disponible allí", -- AI 🤖
        ["esMX"] = "También disponible ahí", -- AI 🤖
        ["frFR"] = "Également disponible là-bas", -- AI 🤖
        ["koKR"] = "그곳에서 함께 받을 수 있음", -- AI 🤖
        ["ptBR"] = "Também disponível lá", -- AI 🤖
        ["ruRU"] = "Там же доступно", -- AI 🤖
        ["zhCN"] = "该处也可接取", -- AI 🤖
        ["zhTW"] = "該處也可接取", -- AI 🤖
    },
    ["Show on map again"] = {
        ["enUS"] = true,
        ["deDE"] = "Wieder auf der Karte zeigen", -- AI 🤖
        ["esES"] = "Volver a mostrar en mapa", -- AI 🤖
        ["esMX"] = "Volver a mostrar en mapa", -- AI 🤖
        ["frFR"] = "Afficher de nouveau sur la carte", -- AI 🤖
        ["koKR"] = "지도에 다시 표시", -- AI 🤖
        ["ptBR"] = "Mostrar no mapa novamente", -- AI 🤖
        ["ruRU"] = "Снова показать на карте", -- AI 🤖
        ["zhCN"] = "重新在地图上显示", -- AI 🤖
        ["zhTW"] = "重新在地圖上顯示", -- AI 🤖
    },
    ["You hid it from the map"] = {
        ["enUS"] = true,
        ["deDE"] = "Du hast sie auf der Karte ausgeblendet", -- AI 🤖
        ["esES"] = "La has ocultado del mapa", -- AI 🤖
        ["esMX"] = "La ocultaste del mapa", -- AI 🤖
        ["frFR"] = "Vous l'avez masquée sur la carte", -- AI 🤖
        ["koKR"] = "지도에서 숨겼습니다", -- AI 🤖
        ["ptBR"] = "Você a ocultou do mapa", -- AI 🤖
        ["ruRU"] = "Вы скрыли его с карты", -- AI 🤖
        ["zhCN"] = "你已将其从地图上隐藏", -- AI 🤖
        ["zhTW"] = "你已將其從地圖上隱藏", -- AI 🤖
    },
    ["Chain"] = {
        ["enUS"] = true,
        ["deDE"] = "Questreihe", -- AI 🤖
        ["esES"] = "Cadena", -- AI 🤖
        ["esMX"] = "Cadena", -- AI 🤖
        ["frFR"] = "Suite de quêtes", -- AI 🤖
        ["koKR"] = "연계 퀘스트", -- AI 🤖
        ["ptBR"] = "Sequência", -- AI 🤖
        ["ruRU"] = "Цепочка", -- AI 🤖
        ["zhCN"] = "任务链", -- AI 🤖
        ["zhTW"] = "任務鏈", -- AI 🤖
    },
    ["Your history"] = {
        ["enUS"] = true,
        ["deDE"] = "Dein Verlauf", -- AI 🤖
        ["esES"] = "Tu historial", -- AI 🤖
        ["esMX"] = "Tu historial", -- AI 🤖
        ["frFR"] = "Votre historique", -- AI 🤖
        ["koKR"] = "내 기록", -- AI 🤖
        ["ptBR"] = "Seu histórico", -- AI 🤖
        ["ruRU"] = "Ваша история", -- AI 🤖
        ["zhCN"] = "你的记录", -- AI 🤖
        ["zhTW"] = "你的紀錄", -- AI 🤖
    },
    ["after %s"] = {
        ["enUS"] = true,
        ["deDE"] = "nach %s", -- AI 🤖
        ["esES"] = "después de %s", -- AI 🤖
        ["esMX"] = "después de %s", -- AI 🤖
        ["frFR"] = "après %s", -- AI 🤖
        ["koKR"] = "%s 이후", -- AI 🤖
        ["ptBR"] = "depois de %s", -- AI 🤖
        ["ruRU"] = "после «%s»", -- AI 🤖
        ["zhCN"] = "%s之后", -- AI 🤖
        ["zhTW"] = "%s之後", -- AI 🤖
    },
}

for k, v in pairs(questsLocales) do
    l10n.translations[k] = v
end
