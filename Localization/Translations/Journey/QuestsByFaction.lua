---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local questsByFactionLocales = {
    ["Quests by Faction"] = {
        ["enUS"] = true,
        ["deDE"] = "Quests pro Fraktion",
        ["esES"] = "Misiones por facción",
        ["esMX"] = "Misiones por facción",
        ["frFR"] = "Quêtes par faction",
        ["koKR"] = "진영별 퀘스트",
        ["ptBR"] = "Missões por facção",
        ["ruRU"] = "Задания по фракциям",
        ["zhCN"] = "按阵营查寻",
        ["zhTW"] = "依陣營查看",
    },
    ["Select Expansion and Faction"] = {
        ["enUS"] = true,
        ["deDE"] = "Erweiterung und Fraktion wählen",
        ["esES"] = "Seleccionar expansión y facción",
        ["esMX"] = "Seleccionar expansión y facción",
        ["frFR"] = "Sélectionner l’extension et la faction",
        ["koKR"] = "확장팩 및 진영 선택",
        ["ptBR"] = "Selecionar expansão e facção",
        ["ruRU"] = "Выберите дополнение и фракцию",
        ["zhCN"] = "选择资料片和阵营",
        ["zhTW"] = "選擇資料片和陣營",
    },
    ["Faction Quests"] = {
        ["enUS"] = true,
        ["deDE"] = "Fraktions-Quests",
        ["esES"] = "Misiones de facción",
        ["esMX"] = "Misiones de facción",
        ["frFR"] = "Quêtes de faction",
        ["koKR"] = "진영 퀘스트",
        ["ptBR"] = "Missões de facção",
        ["ruRU"] = "Фракционные задания",
        ["zhCN"] = "阵营任务",
        ["zhTW"] = "陣營任務",
    },
    ["Select Faction"] = {
        ["enUS"] = true,
        ["deDE"] = "Fraktion wählen",
        ["esES"] = "Seleccionar facción",
        ["esMX"] = "Seleccionar facción",
        ["frFR"] = "Sélectionner la faction",
        ["koKR"] = "진영 선택",
        ["ptBR"] = "Selecionar facção",
        ["ruRU"] = "Выберите фракцию",
        ["zhCN"] = "选择阵营",
        ["zhTW"] = "選擇陣營",
    },
    ["Reputation Reward: "] = {
        ["enUS"] = true,
        ["deDE"] = "Rufbelohnung: ",
        ["esES"] = "Recompensa de reputación: ",
        ["esMX"] = "Recompensa de reputación: ",
        ["frFR"] = "Récompense de réputation : ",
        ["koKR"] = "관계 보상: ",
        ["ptBR"] = "Recompensa de reputação: ",
        ["ruRU"] = "Награда за репутацию: ",
        ["zhCN"] = "关系奖励: ",
        ["zhTW"] = "關係獎勵: ",
    },
}

for k, v in pairs(questsByFactionLocales) do
    l10n.translations[k] = v
end


