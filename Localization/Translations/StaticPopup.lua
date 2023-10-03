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
        ["zhTW"] = "物品 %%s 可能是任務 %%s 會用到。 \n\n是否確定要刪除?",
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
        ["zhTW"] = "你正嘗試將 Questie 插件",
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
        ["zhTW"] = "用在不支援的遊戲版本",
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
        ["zhTW"] = "魔獸世界 \"正式服\" 和私服",
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
        ["zhTW"] = "都不支援。",
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
        ["zhTW"] = "Questie 只支援",
        ["esES"] = false,
        ["frFR"] = false,
    },
    ["WoW Classic (Era/Wrath/SoM)!"] = {
        ["ptBR"] = false,
        ["ruRU"] = "'классические' версии WoW!",
        ["koKR"] = false,
        ["esMX"] = false,
        ["enUS"] = true,
        ["zhCN"] = false,
        ["zhTW"] = "魔獸世界經典版 (經典時期/巫妖王之怒)",
        ["esES"] = false,
        ["frFR"] = false,
    },
    -------------------------------------------------------------------------------------------
    -- Add new Static Popup translations below. Please reference where it's located.
}

for k, v in pairs(staticPopup) do
    l10n.translations[k] = v
end
