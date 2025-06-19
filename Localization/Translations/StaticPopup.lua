---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local staticPopup = {
    -------------------------------------------------------------------------------------------
    -- QuestEventHandler - StaticPopup_Show hook - "DELETE_ITEM" Static Popup
    ["Quest Item %%s might be needed for the quest %%s. \n\nAre you sure you want to delete this?"] = {
        ["enUS"] = true,
        ["deDE"] = "Questgegenstand %%s wird für die Quest %%s benötigt. \n\nMöchtest du ihn wirklich löschen?",
        ["esES"] = "El objeto de misión %%s podría ser necesario para la misión %%s. \n\n¿Estás seguro de que quieres eliminarlo?",
        ["esMX"] = "El objeto de misión %%s podría ser necesario para la misión %%s. \n\n¿Estás seguro de que quieres eliminarlo?",
        ["frFR"] = "L'objet de quête %%s pourrait être nécessaire pour la quête %%s. \n\nÊtes-vous sûr de vouloir supprimer cela ?",
        ["koKR"] = "퀘스트 아이템 %%s 가 %%s 수행을 위해 필요할 수 있습니다. \n\n그래도 해당 아이템을 파괴하시겠습니까?",
        ["ptBR"] = "O item de missão %%s pode ser necessário para a missão %%s. \n\nTem certeza de que deseja excluir isso?",
        ["ruRU"] = "Предмет %%s может понадобиться для задания %%s. \n\nВы уверены, что хотите удалить его?",
        ["zhCN"] = "任务物品 %%s 可能是任务 %%s 所必需的。 \n\n你确定要删除这个吗？",
        ["zhTW"] = "物品 %%s 可能是任務 %%s 會用到。 \n\n是否確定要刪除?",
    },
    -------------------------------------------------------------------------------------------
    -- GameVersionError - "QUESTIE_VERSION_ERROR" Static Popup
    ["You're trying to use Questie addon"] = {
        ["enUS"] = true,
        ["deDE"] = "Du versuchst das Questie Addon",
        ["esES"] = "Estás intentando de utilizar el addon Questie",
        ["esMX"] = "Estás intentando de utilizar el addon Questie",
        ["frFR"] = "Vous essayez d'utiliser l'add-on Questie.",
        ["koKR"] = "퀘스티 애드온을 사용 중입니다",
        ["ptBR"] = "Você está tentando usar o addon Questie.",
        ["ruRU"] = "Вы пытаетесь использовать Questie",
        ["zhCN"] = "你正在尝试使用 Questie 插件",
        ["zhTW"] = "你正嘗試將 Questie 插件",
    },
    ["on an unsupported WoW game client!"] = {
        ["enUS"] = true,
        ["deDE"] = "auf einem nicht unterstützten WoW-Spielclient zu verwenden!",
        ["esES"] = "en un cliente de juego WoW no compatible!",
        ["esMX"] = "en un cliente de juego WoW no compatible!",
        ["frFR"] = "sur un client de jeu WoW non pris en charge !",
        ["koKR"] = "와우 게임 클라이언트와 호환 되지 않습니다!",
        ["ptBR"] = "em um cliente de jogo do WoW não suportado!",
        ["ruRU"] = "в неподдерживаемой версии WoW!",
        ["zhCN"] = "在未受支持的魔兽世界游戏客户端上！",
        ["zhTW"] = "用在不支援的遊戲版本",
    },
    ["WoW \"retail\" and private servers"] = {
        ["enUS"] = true,
        ["deDE"] = "WoW \"Retail\" und private Server",
        ["esES"] = "WoW \"retail\" y servidores privados",
        ["esMX"] = "WoW \"retail\" y servidores privados",
        ["frFR"] = "WoW \"retail\" et serveurs privés",
        ["koKR"] = "WoW \"Retail\" 사설 서버",
        ["ptBR"] = "WoW \"retail\" e servidores privados",
        ["ruRU"] = "Ритейл и приватные сервера",
        ["zhCN"] = "魔兽世界“零售”版及私服",
        ["zhTW"] = "魔獸世界 \"正式服\" 和私服",
    },
    ["are not supported."] = {
        ["enUS"] = true,
        ["deDE"] = "werden nicht unterstützt.",
        ["esES"] = "no son compatibles.",
        ["esMX"] = "no son compatibles.",
        ["frFR"] = "ne sont pas pris en charge.",
        ["koKR"] = "지원되지 않습니다",
        ["ptBR"] = "não são suportados.",
        ["ruRU"] = "не поддерживаются.",
        ["zhCN"] = "不受支持。",
        ["zhTW"] = "都不支援。",
    },
    ["Questie only supports"] = {
        ["enUS"] = true,
        ["deDE"] = "Questie unterstützt nur",
        ["esES"] = "Questie solo soporta",
        ["esMX"] = "Questie solo soporta",
        ["frFR"] = "Questie prend en charge uniquement",
        ["koKR"] = "퀘스티는 지원합니다",
        ["ptBR"] = "Questie suporta apenas",
        ["ruRU"] = "Questie поддерживает только",
        ["zhCN"] = "Questie 只支持",
        ["zhTW"] = "Questie 只支援",
    },
    ["WoW Classic (Era/Cataclysm)!"] = {
        ["enUS"] = true,
        ["deDE"] = true,
        ["esES"] = "WoW Clásico (Era/Cataclysm)!",
        ["esMX"] = "WoW Clásico (Era/Cataclysm)!",
        ["frFR"] = true,
        ["koKR"] = "와우 클래식 (시대/리치왕)",
        ["ptBR"] = true,
        ["ruRU"] = "'классические' версии WoW!",
        ["zhCN"] = "魔兽世界怀旧服（旧世经典/大地的裂变）！",
        ["zhTW"] = "魔獸世界經典版 (經典時期/浩劫與重生)!",
    },
    -------------------------------------------------------------------------------------------
    -- Add new Static Popup translations below. Please reference where it's located.
}

for k, v in pairs(staticPopup) do
    l10n.translations[k] = v
end
