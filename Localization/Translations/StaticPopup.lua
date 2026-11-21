---@type QuestieLoader
local QuestieLoader = select(2, ...).QuestieLoader

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
    -- Add new Static Popup translations below. Please reference where it's located.
}

for k, v in pairs(staticPopup) do
    l10n.translations[k] = v
end
