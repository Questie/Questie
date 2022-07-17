---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local wotlkObjectiveLocales = {
    ["Talk to Olga"] = { -- 11466
        ["ptBR"] = false,
        ["ruRU"] = false,
        ["deDE"] = false,
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