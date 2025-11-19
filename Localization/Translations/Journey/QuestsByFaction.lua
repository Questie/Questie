---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local questsByFactionLocales = {
    ["Quests by Faction"] = {
        ["enUS"] = true,
        ["deDE"] = "",
        ["esES"] = "Misiones por facción",
        ["esMX"] = "Misiones por facción",
        ["frFR"] = "Quêtes par faction",
        ["koKR"] = "",
        ["ptBR"] = "Missões por facçao",
        ["ruRU"] = "",
        ["zhCN"] = "按阵营查寻",
        ["zhTW"] = "依陣營查看",
    },
    ["Select Expansion and Faction"] = {
        ["enUS"] = true,
        ["deDE"] = "",
        ["esES"] = "Seleccionar expansión y facción",
        ["esMX"] = "Seleccionar expansión y facción",
        ["frFR"] = "Sélectionner l’extension et la faction",
        ["koKR"] = "",
        ["ptBR"] = "Selecionar expansão e facção",
        ["ruRU"] = "",
        ["zhCN"] = "选择资料片和阵营",
        ["zhTW"] = "選擇資料片和陣營",
    },
    ["Faction Quests"] = {
        ["enUS"] = true,
        ["deDE"] = "",
        ["esES"] = "Misiones de facción",
        ["esMX"] = "Misiones de facción",
        ["frFR"] = "Quêtes de faction",
        ["koKR"] = "",
        ["ptBR"] = "Missões de facção",
        ["ruRU"] = "",
        ["zhCN"] = "阵营任务",
        ["zhTW"] = "陣營任務",
    },
    ["Select Faction"] = {
        ["enUS"] = true,
        ["deDE"] = "",
        ["esES"] = "Seleccionar facción",
        ["esMX"] = "Seleccionar facción",
        ["frFR"] = "Sélectionner la faction",
        ["koKR"] = "",
        ["ptBR"] = "Selecionar facção",
        ["ruRU"] = "",
        ["zhCN"] = "选择阵营",
        ["zhTW"] = "選擇陣營",
    },
    ["Reputation Reward: "] = {
        ["enUS"] = true,
        ["deDE"] = "",
        ["esES"] = "Recompensa de reputación: ",
        ["esMX"] = "Recompensa de reputación: ",
        ["frFR"] = "Récompense de réputation : ",
        ["koKR"] = "",
        ["ptBR"] = "Recompensa de reputação: ",
        ["ruRU"] = "",
        ["zhCN"] = "关系奖励: ",
        ["zhTW"] = "關係獎勵: ",
    },
}

for k, v in pairs(questsByFactionLocales) do
    l10n.translations[k] = v
end


