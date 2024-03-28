---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local cataObjectiveLocales = {
    ["Talk to Torben Zapblast."] = {
        ["ptBR"] = "Converse com Toninho Despachante.",
        ["ruRU"] = "Поговорите с Торбен Взрывошок.",
        ["deDE"] = "Sprich mit Torben Knallschock.",
        ["koKR"] = false,
        ["esMX"] = "Habla con Torben Pumzas.",
        ["enUS"] = true,
        ["frFR"] = "Parlez à Torben Zoupépaf.",
        ["esES"] = "Habla con Torben Pumzas.",
        ["zhTW"] = false,
        ["zhCN"] = false,
    },
}

for k, v in pairs(cataObjectiveLocales) do
    l10n.translations[k] = v
end
