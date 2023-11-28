---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local staticPopup = {
    -------------------------------------------------------------------------------------------
    -- QuestEventHandler - StaticPopup_Show hook - "DELETE_ITEM" Static Popup
    ["Quest Item %%s might be needed for the quest %%s. \n\nAre you sure you want to delete this?"] = {
        ["ptBR"] = false,
        ["ruRU"] = "Предмет %%s может понадобиться для задания %%s. \n\nВы уверены, что хотите удалить его?",
        ["deDE"] = "Questgegenstand %%s wird für die Quest %%s benötigt. \n\nMöchtest du ihn wirklich löschen?",
        ["koKR"] = false,
        ["esMX"] = "El objeto de misión %%s podría ser necesario para la misión %%s. \n\n¿Estás seguro de que quieres eliminarlo?",
        ["enUS"] = true,
        ["zhCN"] = false,
        ["zhTW"] = "物品 %%s 可能是任務 %%s 會用到。 \n\n是否確定要刪除?",
        ["esES"] = "El objeto de misión %%s podría ser necesario para la misión %%s. \n\n¿Estás seguro de que quieres eliminarlo?",
        ["frFR"] = false,
    },
    -------------------------------------------------------------------------------------------
    -- GameVersionError - "QUESTIE_VERSION_ERROR" Static Popup
    ["You're trying to use Questie addon"] = {
        ["ptBR"] = false,
        ["ruRU"] = "Вы пытаетесь использовать Questie",
        ["deDE"] = "Du versuchst das Questie Addon",
        ["koKR"] = false,
        ["esMX"] = "Estás intentando utilizar el complemento Questie",
        ["enUS"] = true,
        ["zhCN"] = false,
        ["zhTW"] = "你正嘗試將 Questie 插件",
        ["esES"] = "Estás intentando utilizar el complemento Questie",
        ["frFR"] = false,
    },
    ["on an unsupported WoW game client!"] = {
        ["ptBR"] = false,
        ["ruRU"] = "в неподдерживаемой версии WoW!",
        ["deDE"] = "auf einem nicht unterstützten WoW-Spielclient zu verwenden!",
        ["koKR"] = false,
        ["esMX"] = "en un cliente de juego WoW no compatible!",
        ["enUS"] = true,
        ["zhCN"] = false,
        ["zhTW"] = "用在不支援的遊戲版本",
        ["esES"] = "en un cliente de juego WoW no compatible!",
        ["frFR"] = false,
    },
    ["WoW \"retail\" and private servers"] = {
        ["ptBR"] = false,
        ["ruRU"] = "Ритейл и приватные сервера",
        ["deDE"] = "WoW \"Retail\" und private Server",
        ["koKR"] = false,
        ["esMX"] = "WoW \"moderno\" y servidores privados",
        ["enUS"] = true,
        ["zhCN"] = false,
        ["zhTW"] = "魔獸世界 \"正式服\" 和私服",
        ["esES"] = "WoW \"moderno\" y servidores privados",
        ["frFR"] = false,
    },
    ["are not supported."] = {
        ["ptBR"] = false,
        ["ruRU"] = "не поддерживаются.",
        ["deDE"] = "werden nicht unterstützt.",
        ["koKR"] = false,
        ["esMX"] = "no son compatibles.",
        ["enUS"] = true,
        ["zhCN"] = false,
        ["zhTW"] = "都不支援。",
        ["esES"] = "no son compatibles.",
        ["frFR"] = false,
    },
    ["Questie only supports"] = {
        ["ptBR"] = false,
        ["ruRU"] = "Questie поддерживает только",
        ["deDE"] = "Questie unterstützt nur",
        ["koKR"] = false,
        ["esMX"] = "Questie sólo soporta",
        ["enUS"] = true,
        ["zhCN"] = false,
        ["zhTW"] = "Questie 只支援",
        ["esES"] = "Questie sólo soporta",
        ["frFR"] = false,
    },
    ["WoW Classic (Era/Wrath)!"] = {
        ["ptBR"] = false,
        ["ruRU"] = "'классические' версии WoW!",
        ["deDE"] = true,
        ["koKR"] = false,
        ["esMX"] = "WoW Clásico (Era/Wrath)!",
        ["enUS"] = true,
        ["zhCN"] = false,
        ["zhTW"] = "魔獸世界經典版 (經典時期/巫妖王之怒)",
        ["esES"] = "WoW Clásico (Era/Wrath)!",
        ["frFR"] = false,
    },
    -------------------------------------------------------------------------------------------
    -- Add new Static Popup translations below. Please reference where it's located.
}

for k, v in pairs(staticPopup) do
    l10n.translations[k] = v
end
