---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local questsByFactionLocales = {
    ["Select Expansion and Faction"] = {
        ["enUS"] = true,
        ["deDE"] = "",
        ["esES"] = "",
        ["esMX"] = "",
        ["frFR"] = "",
        ["koKR"] = "",
        ["ptBR"] = "",
        ["ruRU"] = "",
        ["zhCN"] = "",
        ["zhTW"] = "",
    },
    ["Faction Quests"] = {
        ["enUS"] = true,
        ["deDE"] = "",
        ["esES"] = "",
        ["esMX"] = "",
        ["frFR"] = "",
        ["koKR"] = "",
        ["ptBR"] = "",
        ["ruRU"] = "",
        ["zhCN"] = "",
        ["zhTW"] = "",
    },
    ["Select Expansion"] = {
        ["enUS"] = true,
        ["deDE"] = "",
        ["esES"] = "",
        ["esMX"] = "",
        ["frFR"] = "",
        ["koKR"] = "",
        ["ptBR"] = "",
        ["ruRU"] = "",
        ["zhCN"] = "",
        ["zhTW"] = "",
    },
    ["Select Faction"] = {
        ["enUS"] = true,
        ["deDE"] = "",
        ["esES"] = "",
        ["esMX"] = "",
        ["frFR"] = "",
        ["koKR"] = "",
        ["ptBR"] = "",
        ["ruRU"] = "",
        ["zhCN"] = "",
        ["zhTW"] = "",
    },
}

for k, v in pairs(questsByFactionLocales) do
    l10n.translations[k] = v
end


