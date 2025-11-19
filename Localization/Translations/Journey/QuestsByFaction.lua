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
        ["zhCN"] = "",
        ["zhTW"] = "",
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
        ["zhCN"] = "",
        ["zhTW"] = "",
    },
    ["Faction Quests"] = {
        ["enUS"] = true,
        ["deDE"] = "",
        ["esES"] = "Misiones de facción",
        ["esMX"] = "Missiones de facción",
        ["frFR"] = "Quêtes de faction",
        ["koKR"] = "",
        ["ptBR"] = "Missões de facção",
        ["ruRU"] = "",
        ["zhCN"] = "",
        ["zhTW"] = "",
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
        ["zhCN"] = "",
        ["zhTW"] = "",
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
        ["zhCN"] = "",
        ["zhTW"] = "",
    },
}

for k, v in pairs(questsByFactionLocales) do
    l10n.translations[k] = v
end


