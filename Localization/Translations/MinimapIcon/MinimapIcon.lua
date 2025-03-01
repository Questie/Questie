---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local minimapIconLocales = {
    ["Toggle Menu"] = {
        ["enUS"] = true,
        ["deDE"] = "Menü zeigen/verstecken",
        ["esES"] = "Mostrar menú",
        ["esMX"] = "Mostrar menú",
        ["frFR"] = "Afficher le menu",
        ["koKR"] = "메뉴 표시",
        ["ptBR"] = "Mostrar menu",
        ["ruRU"] = "Открыть меню",
        ["zhCN"] = "打开主菜单",
        ["zhTW"] = "顯示/隱藏選單",
    },
    ["Toggle Questie"] = {
        ["enUS"] = true,
        ["deDE"] = "Icons aktivieren/deaktivieren",
        ["esES"] = "Mostrar Questie",
        ["esMX"] = "Mostrar Questie",
        ["frFR"] = "Afficher Questie",
        ["koKR"] = "Questie 표시",
        ["ptBR"] = "Mostrar Questie",
        ["ruRU"] = "Показать/скрыть значки",
        ["zhCN"] = "启动Questie",
        ["zhTW"] = "顯示/隱藏任務位置提示",
    },
    ["Toggle My Journey"] = {
        ["enUS"] = true,
        ["deDE"] = "Meine Reise zeigen/verstecken",
        ["esES"] = "Mostrar mi viaje",
        ["esMX"] = "Mostrar mi viaje",
        ["frFR"] = "Afficher mon voyage",
        ["koKR"] = "나의 여정 창 열기",
        ["ptBR"] = "Mostrar minha jornada",
        ["ruRU"] = "Открыть 'Путешествие'",
        ["zhCN"] = "打开我的日志",
        ["zhTW"] = "顯示/隱藏我的冒險日記",
    },
    ["Hide Minimap Button"] = {
        ["enUS"] = true,
        ["deDE"] = "Minimap-Button verstecken",
        ["esES"] = "Ocultar botón del minimapa",
        ["esMX"] = "Ocultar botón del minimapa",
        ["frFR"] = "Cacher le bouton de la minicarte",
        ["koKR"] = "미니맵 버튼 가리기",
        ["ptBR"] = "Ocultar botão do minimapa",
        ["ruRU"] = "Скрыть кнопку у миникарты",
        ["zhCN"] = "隐藏小地图图标",
        ["zhTW"] = "隱藏小地圖按鈕",
    },
    ["Reload Questie"] = {
        ["enUS"] = true,
        ["deDE"] = "Questie neu laden",
        ["esES"] = "Recargar Questie",
        ["esMX"] = "Recargar Questie",
        ["frFR"] = "Recharger Questie",
        ["koKR"] = "Questie 리로드",
        ["ptBR"] = "Recarregar Questie",
        ["ruRU"] = "Перезагрузить аддон",
        ["zhCN"] = "重新载入Questie",
        ["zhTW"] = "重新載入任務位置提示",
    },
    ["Available Quest"] = {
        ["enUS"] = true,
        ["deDE"] = "Verfügbare Quests",
        ["esES"] = "Misión disponible",
        ["esMX"] = "Misión disponible",
        ["frFR"] = "Quêtes disponibles",
        ["koKR"] = "수행 가능한 퀘스트",
        ["ptBR"] = "Missões disponiveis",
        ["ruRU"] = "Доступные задания",
        ["zhCN"] = "可用任务",
        ["zhTW"] = "可接的任務",
    },
    ["Trivial Quest"] = {
        ["enUS"] = true,
        ["deDE"] = "Niedrigstufige Quests",
        ["esES"] = "Misión trivial",
        ["esMX"] = "Misión trivial",
        ["frFR"] = "Quêtes de bas niveau",
        ["koKR"] = "기타 퀘스트",
        ["ptBR"] = "Missões triviais",
        ["ruRU"] = "Простые задания",
        ["zhCN"] = "低等级任务",
        ["zhTW"] = "低等級任務",
    },
    ["Questie will open after combat ends."] = {
        ["enUS"] = true,
        ["deDE"] = "Questie öffnet sich nach dem Kampf.",
        ["esES"] = "Questie se abrirá cuando estés fuera de combate.",
        ["esMX"] = "Questie se abrirá cuando estés fuera de combate.",
        ["frFR"] = "La quête s'ouvrira après la fin du combat.",
        ["koKR"] = "전투 종료 후 퀘스티가 열립니다",
        ["ptBR"] = "Questie será aberta após o término do combate.",
        ["ruRU"] = "Questie откроется по завершении боя.",
        ["zhCN"] = "Questie 会在战斗结束后打开。",
        ["zhTW"] = "Questie 會在戰鬥結束後開啟。",
    },
}

for k, v in pairs(minimapIconLocales) do
    l10n.translations[k] = v
end
