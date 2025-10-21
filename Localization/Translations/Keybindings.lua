---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local keybindingsLocales = {
    ["Toggle Questie Journey"] = {
        ["enUS"] = true,
        ["deDE"] = false,
        ["esES"] = false,
        ["esMX"] = false,
        ["frFR"] = false,
        ["koKR"] = false,
        ["ptBR"] = false,
        ["ruRU"] = false,
        ["zhCN"] = false,
        ["zhTW"] = false,
    },
}

for k, v in pairs(keybindingsLocales) do
    l10n.translations[k] = v
end
