---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local battlegroundsLocales = {
    ["Warsong Gulch"] = {
        ["enUS"] = true,
        ["deDE"] = "Kriegshymnenschlucht",
        ["esES"] = "Garganta Grito de Guerra",
        ["esMX"] = "Garganta Grito de Guerra",
        ["frFR"] = "Goulet des Warsong",
        ["koKR"] = "전쟁노래 협곡",
        ["ptBR"] = "Ravina Brado Guerreiro",
        ["ruRU"] = "Ущелье Песни Войны",
        ["zhCN"] = "战歌峡谷",
        ["zhTW"] = "戰歌峽谷",
    },
    ["Alterac Valley"] = {
        ["enUS"] = true,
        ["deDE"] = "Alteractal",
        ["esES"] = "Valle de Alterac",
        ["esMX"] = "Valle de Alterac",
        ["frFR"] = "Vallée d'Alterac",
        ["koKR"] = "알터랙 계곡",
        ["ptBR"] = "Vale Alterac",
        ["ruRU"] = "Альтеракская долина",
        ["zhCN"] = "奥特兰克山谷",
        ["zhTW"] = "奧特蘭克山谷",
    },
    ["Arathi Basin"] = {
        ["enUS"] = true,
        ["deDE"] = "Arathibecken",
        ["esES"] = "Cuenca de Arathi",
        ["esMX"] = "Cuenca de Arathi",
        ["frFR"] = "Bassin d'Arathi",
        ["koKR"] = "아라시 분지",
        ["ptBR"] = "Bacia Arathi",
        ["ruRU"] = "Низина Арати",
        ["zhCN"] = "阿拉希盆地",
        ["zhTW"] = "阿拉希盆地",
    },
    ["Eye of the Storm"] = {
        ["enUS"] = true,
        ["deDE"] = "Auge des Sturms",
        ["esES"] = "Ojo de la Tormenta",
        ["esMX"] = "Ojo de la Tormenta",
        ["frFR"] = "L'Œil du cyclone",
        ["koKR"] = "폭풍의 눈",
        ["ptBR"] = "Olho da Tormenta",
        ["ruRU"] = "Око Бури",
        ["zhCN"] = "风暴之眼",
        ["zhTW"] = "暴風之眼",
    },
}

for k, v in pairs(battlegroundsLocales) do
    l10n.translations[k] = v
end