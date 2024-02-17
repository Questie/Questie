---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local seasonObjectiveLocals = {
    ["Use the Rowboat to reach the eastern shore."] = { -- 79242
        ["ptBR"] = false,
        ["ruRU"] = "Используйте лодку с веслами, чтобы добраться до восточного берега.",
        ["deDE"] = "Benutze das Ruderboot, um zur Ostküste zu gelangen.",
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
