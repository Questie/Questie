---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local wotlkObjectiveLocales = {
    ["Talk to Olga"] = { -- 11466
        ["ptBR"] = false,
        ["ruRU"] = false,
        ["deDE"] = "Sprich mit Olga",
        ["koKR"] = false,
        ["esMX"] = false,
        ["enUS"] = true,
        ["frFR"] = false,
        ["esES"] = false,
        ["zhTW"] = false,
        ["zhCN"] = false,
    },
    ["Fight Jonah"] = { -- 11471
        ["ptBR"] = false,
        ["ruRU"] = false,
        ["deDE"] = "Kämpfe gegen Jonah",
        ["koKR"] = false,
        ["esMX"] = false,
        ["enUS"] = true,
        ["frFR"] = false,
        ["esES"] = false,
        ["zhTW"] = false,
        ["zhCN"] = false,
    },
}

for k, v in pairs(wotlkObjectiveLocales) do
    l10n.translations[k] = v
end