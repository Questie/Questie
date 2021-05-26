---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local battlegroundsLocales = {
    ["Warsong Gulch"] = {
        ["ptBR"] = "Ravina Brado Guerreiro",
        ["ruRU"] = "Ущелье Песни Войны",
        ["deDE"] = "Kriegshymnenschlucht",
        ["koKR"] = "전쟁노래 협곡",
        ["esMX"] = "Garganta Grito de Guerra",
        ["enUS"] = true,
        ["frFR"] = "Goulet des Warsong",
        ["esES"] = "Garganta Grito de Guerra",
        ["zhTW"] = "戰歌峽谷",
        ["zhCN"] = "战歌峡谷",
    },
    ["Alterac Valley"] = {
        ["ptBR"] = "Vale Alterac",
        ["ruRU"] = "Альтеракская долина",
        ["deDE"] = "Alteractal",
        ["koKR"] = "알터랙 계곡",
        ["esMX"] = "Valle de Alterac",
        ["enUS"] = true,
        ["frFR"] = "Vallée d'Alterac",
        ["esES"] = "Valle de Alterac",
        ["zhTW"] = "奧特蘭克山谷",
        ["zhCN"] = "奥特兰克山谷",
    },
    ["Arathi Basin"] = {
        ["ptBR"] = "Bacia Arathi",
        ["ruRU"] = "Низина Арати",
        ["deDE"] = "Arathibecken",
        ["koKR"] = "아라시 분지",
        ["esMX"] = "Cuenca de Arathi",
        ["enUS"] = true,
        ["frFR"] = "Bassin d'Arathi",
        ["esES"] = "Cuenca de Arathi",
        ["zhTW"] = "阿拉希盆地",
        ["zhCN"] = "阿拉希盆地",
    },
    ["Eye of the Storm"] = {
        ["ptBR"] = nil,
        ["ruRU"] = nil,
        ["deDE"] = "Auge des Sturms",
        ["koKR"] = nil,
        ["esMX"] = nil,
        ["enUS"] = true,
        ["frFR"] = nil,
        ["esES"] = nil,
        ["zhTW"] = nil,
        ["zhCN"] = nil,
    },
}

for k, v in pairs(battlegroundsLocales) do
    l10n.translations[k] = v
end