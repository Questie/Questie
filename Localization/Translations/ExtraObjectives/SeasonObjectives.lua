---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local seasonObjectiveLocals = {
    ["Use the Rowboat to reach the eastern shore."] = { -- 79242
        ["ptBR"] = "Use o barco a remo para alcançar a margem leste.",
        ["ruRU"] = "Используйте лодку с веслами, чтобы добраться до восточного берега.",
        ["deDE"] = "Benutze das Ruderboot, um zur Ostküste zu gelangen.",
        ["koKR"] = false,
        ["esMX"] = "Usa el bote de remos para llegar a la orilla este.",
        ["enUS"] = true,
        ["frFR"] = "Utilisez la chaloupe pour atteindre la rive est.",
        ["esES"] = "Usa el bote de remos para llegar a la orilla este.",
        ["zhTW"] = false,
        ["zhCN"] = false,
    },
    ["Drink the Squall-breakers Potion and talk to Nyse."] = { -- 79366
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
    ["Defeat enough enemies to call forth the Shadowy Figure and talk to her to receive a Mote of Darkness."] = { -- 79982
        ["ptBR"] = false,
        ["ruRU"] = false,
        ["deDE"] = "Besiege genug Feinde, um die Schattenhafte Gestalt herbeizurufen und sprich mit ihr, um einen Partikel der Dunkelheit zu erhalten.",
        ["koKR"] = false,
        ["esMX"] = false,
        ["enUS"] = true,
        ["frFR"] = false,
        ["esES"] = false,
        ["zhTW"] = false,
        ["zhCN"] = false,
    },
}

for k, v in pairs(seasonObjectiveLocals) do
    l10n.translations[k] = v
end
