---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local autoLocales = {
    ["Automatically rejected quest shared by player."] = {
        ["enUS"] = true,
        ["deDE"] = "Von Spieler geteilte Quest wurde automatisch abgelehnt.",
        ["esES"] = "Se rechazó automáticamente la misión compartida por el jugador.",
        ["esMX"] = "Se rechazó automáticamente la misión compartida por el jugador.",
        ["frFR"] = "La quête partagée par le joueur a été rejetée automatiquement.",
        ["koKR"] = false,
        ["ptBR"] = "Rejeitou-se automaticamente a missão compartilhada pelo jogador.",
        ["ruRU"] = "Задание, которым поделился другой игрок, автоматически отменено.",
        ["zhCN"] = false,
        ["zhTW"] = false,
    },
}

for k, v in pairs(autoLocales) do
    l10n.translations[k] = v
end
