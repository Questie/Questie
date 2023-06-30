---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local staticPopup = {
    -------------------------------------------------------------------------------------------
    -- QuestEventHandler - StaticPopup_Show hook - "DELETE_ITEM" Static Popup
    ["Quest Item %%s might be needed for the quest %%s. \n\nAre you sure you want to delete this?"] = {
        ["ptBR"] = false,
        ["ruRU"] = "Предмет %%s может понадобиться для задания %%s. \n\nВы уверены, что хотите удалить его?",
        ["deDE"] = false,
        ["koKR"] = false,
        ["esMX"] = false,
        ["enUS"] = true,
        ["zhCN"] = false,
        ["zhTW"] = false,
        ["esES"] = false,
        ["frFR"] = false,
    },
    -------------------------------------------------------------------------------------------
    -- GameVersionError - "QUESTIE_VERSION_ERROR" Static Popup
    ["You're trying to use Questie addon"] = {
        ["ptBR"] = false,
        ["ruRU"] = "Вы пытаетесь использовать Questie",
        ["deDE"] = false,
        ["koKR"] = false,
        ["esMX"] = false,
        ["enUS"] = true,
        ["zhCN"] = false,
        ["zhTW"] = false,
        ["esES"] = false,
        ["frFR"] = false,
    },
    ["on an unsupported WoW game client!"] = {
        ["ptBR"] = false,
        ["ruRU"] = "в неподдерживаемой версии WoW!",
        ["deDE"] = false,
        ["koKR"] = false,
        ["esMX"] = false,
        ["enUS"] = true,
        ["zhCN"] = false,
        ["zhTW"] = false,
        ["esES"] = false,
        ["frFR"] = false,
    },
    ["WoW \"retail\" and private servers"] = {
        ["ptBR"] = false,
        ["ruRU"] = "Ритейл и приватные сервера",
        ["deDE"] = false,
        ["koKR"] = false,
        ["esMX"] = false,
        ["enUS"] = true,
        ["zhCN"] = false,
        ["zhTW"] = false,
        ["esES"] = false,
        ["frFR"] = false,
    },
    ["are not supported."] = {
        ["ptBR"] = false,
        ["ruRU"] = "не поддерживаются.",
        ["deDE"] = false,
        ["koKR"] = false,
        ["esMX"] = false,
        ["enUS"] = true,
        ["zhCN"] = false,
        ["zhTW"] = false,
        ["esES"] = false,
        ["frFR"] = false,
    },
    ["Questie only supports"] = {
        ["ptBR"] = false,
        ["ruRU"] = "Questie поддерживает только",
        ["deDE"] = false,
        ["koKR"] = false,
        ["esMX"] = false,
        ["enUS"] = true,
        ["zhCN"] = false,
        ["zhTW"] = false,
        ["esES"] = false,
        ["frFR"] = false,
    },
    ["WoW Classic (Era/Wrath/SoM)!"] = {
        ["ptBR"] = false,
        ["ruRU"] = "'классические' версии WoW!",
        ["deDE"] = false,
        ["koKR"] = false,
        ["esMX"] = false,
        ["enUS"] = true,
        ["zhCN"] = false,
        ["zhTW"] = false,
        ["esES"] = false,
        ["frFR"] = false,
    },
    -------------------------------------------------------------------------------------------
    -- Add new Static Popup translations below. Please reference where it's located.
}

for k, v in pairs(staticPopup) do
    l10n.translations[k] = v
end
