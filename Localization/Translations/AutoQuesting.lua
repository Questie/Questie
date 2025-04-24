---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local autoLocales = {
    ["Automatically rejected quest shared by player."] = {
        ["enUS"] = true,
        ["deDE"] = "Von Spieler geteilte Quest wurde automatisch abgelehnt.",
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

for k, v in pairs(autoLocales) do
    l10n.translations[k] = v
end
