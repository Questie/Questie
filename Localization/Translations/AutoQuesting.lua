---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local autoLocales = {
    ["Automatically rejected quest %s shared by %s in battleground. Change this in Questie settings under Auto Accept."] = {
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
    ["Unknown Player"] = {
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
    ["Unknown Quest"] = {
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

for k, v in pairs(autoLocales) do
    l10n.translations[k] = v
end
