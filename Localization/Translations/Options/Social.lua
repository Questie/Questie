---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local socialOptionsLocales = {
    ["Social"] = {
        ["ptBR"] = nil,
        ["ruRU"] = nil,
        ["deDE"] = "Soziales", -- TODO: Improve translation
        ["koKR"] = nil,
        ["esMX"] = nil,
        ["enUS"] = true,
        ["zhCN"] = nil,
        ["zhTW"] = nil,
        ["esES"] = nil,
        ["frFR"] = nil,
    },
    ["Social Options"] = {
        ["ptBR"] = nil,
        ["ruRU"] = nil,
        ["deDE"] = "Soziale Einstellungen", -- TODO: Improve translation
        ["koKR"] = nil,
        ["esMX"] = nil,
        ["enUS"] = true,
        ["zhCN"] = nil,
        ["zhTW"] = nil,
        ["esES"] = nil,
        ["frFR"] = nil,
    },
}

for k, v in pairs(socialOptionsLocales) do
    l10n.translations[k] = v
end