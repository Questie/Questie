---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local staticPopup = {
    -------------------------------------------------------------------------------------------
    -- QuestEventHandler - StaticPopup_Show hook - "DELETE_ITEM" Static Popup
    ["Quest Item %%s might be needed for the quest %%s. \n\nAre you sure you want to delete this?"] = {
        ["ptBR"] = "O item de missão %%s pode ser necessário para a missão %%s. \n\nTem certeza de que deseja excluir isso?",
        ["ruRU"] = "Предмет %%s может понадобиться для задания %%s. \n\nВы уверены, что хотите удалить его?",
        ["deDE"] = "Questgegenstand %%s wird für die Quest %%s benötigt. \n\nMöchtest du ihn wirklich löschen?",
        ["koKR"] = "퀘스트 아이템 %%s 가 %%s 수행을 위해 필요할 수 있습니다. \n\n그래도 해당 아이템을 파괴하시겠습니까?",
        ["esMX"] = "El objeto de misión %%s podría ser necesario para la misión %%s. \n\n¿Estás seguro de que quieres eliminarlo?",
        ["enUS"] = true,
        ["zhCN"] = false,
        ["zhTW"] = "物品 %%s 可能是任務 %%s 會用到。 \n\n是否確定要刪除?",
        ["esES"] = "El objeto de misión %%s podría ser necesario para la misión %%s. \n\n¿Estás seguro de que quieres eliminarlo?",
        ["frFR"] = "L'objet de quête %%s pourrait être nécessaire pour la quête %%s. \n\nÊtes-vous sûr de vouloir supprimer cela ?",
    },
    -------------------------------------------------------------------------------------------
    -- GameVersionError - "QUESTIE_VERSION_ERROR" Static Popup
    ["You're trying to use Questie addon"] = {
        ["ptBR"] = "Você está tentando usar o addon Questie.",
        ["ruRU"] = "Вы пытаетесь использовать Questie",
        ["deDE"] = "Du versuchst das Questie Addon",
        ["koKR"] = "퀘스티 애드온을 사용 중입니다",
        ["esMX"] = "Estás intentando de utilizar el addon Questie",
        ["enUS"] = true,
        ["zhCN"] = false,
        ["zhTW"] = "你正嘗試將 Questie 插件",
        ["esES"] = "Estás intentando de utilizar el addon Questie",
        ["frFR"] = "Vous essayez d'utiliser l'add-on Questie.",
    },
    ["on an unsupported WoW game client!"] = {
        ["ptBR"] = "em um cliente de jogo do WoW não suportado!",
        ["ruRU"] = "в неподдерживаемой версии WoW!",
        ["deDE"] = "auf einem nicht unterstützten WoW-Spielclient zu verwenden!",
        ["koKR"] = "와우 게임 클라이언트와 호환 되지 않습니다!",
        ["esMX"] = "en un cliente de juego WoW no compatible!",
        ["enUS"] = true,
        ["zhCN"] = false,
        ["zhTW"] = "用在不支援的遊戲版本",
        ["esES"] = "en un cliente de juego WoW no compatible!",
        ["frFR"] = "sur un client de jeu WoW non pris en charge !",
    },
    ["WoW \"retail\" and private servers"] = {
        ["ptBR"] = "WoW \"retail\" e servidores privados",
        ["ruRU"] = "Ритейл и приватные сервера",
        ["deDE"] = "WoW \"Retail\" und private Server",
        ["koKR"] = "WoW \"Retail\" 사설 서버",
        ["esMX"] = "WoW \"retail\" y servidores privados",
        ["enUS"] = true,
        ["zhCN"] = false,
        ["zhTW"] = "魔獸世界 \"正式服\" 和私服",
        ["esES"] = "WoW \"retail\" y servidores privados",
        ["frFR"] = "WoW \"retail\" et serveurs privés",
    },
    ["are not supported."] = {
        ["ptBR"] = "não são suportados.",
        ["ruRU"] = "не поддерживаются.",
        ["deDE"] = "werden nicht unterstützt.",
        ["koKR"] = "지원되지 않습니다",
        ["esMX"] = "no son compatibles.",
        ["enUS"] = true,
        ["zhCN"] = false,
        ["zhTW"] = "都不支援。",
        ["esES"] = "no son compatibles.",
        ["frFR"] = "ne sont pas pris en charge.",
    },
    ["Questie only supports"] = {
        ["ptBR"] = "Questie suporta apenas",
        ["ruRU"] = "Questie поддерживает только",
        ["deDE"] = "Questie unterstützt nur",
        ["koKR"] = "퀘스티는 지원합니다",
        ["esMX"] = "Questie sólo soporta",
        ["enUS"] = true,
        ["zhCN"] = false,
        ["zhTW"] = "Questie 只支援",
        ["esES"] = "Questie sólo soporta",
        ["frFR"] = "Questie prend en charge uniquement",
    },
    ["WoW Classic (Era/Wrath)!"] = {
        ["ptBR"] = true,
        ["ruRU"] = "'классические' версии WoW!",
        ["deDE"] = true,
        ["koKR"] = "와우 클래식 (시대/리치왕)",
        ["esMX"] = "WoW Clásico (Era/Wrath)!",
        ["enUS"] = true,
        ["zhCN"] = false,
        ["zhTW"] = "魔獸世界經典版 (經典時期/巫妖王之怒)",
        ["esES"] = "WoW Clásico (Era/Wrath)!",
        ["frFR"] = true,
    },
    -------------------------------------------------------------------------------------------
    -- Add new Static Popup translations below. Please reference where it's located.
}

for k, v in pairs(staticPopup) do
    l10n.translations[k] = v
end
