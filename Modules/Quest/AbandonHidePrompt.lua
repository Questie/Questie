---@class AbandonHidePrompt
local AbandonHidePrompt = QuestieLoader:CreateModule("AbandonHidePrompt")

---@type QuestiePopup
local Popup = QuestieLoader:ImportModule("QuestiePopup")
---@type QuestieQuest
local QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestieCorrections
local QuestieCorrections = QuestieLoader:ImportModule("QuestieCorrections")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local DIALOG_KEY = "QUESTIE_ABANDON_HIDE_CONFIRM"

Popup.Dialogs[DIALOG_KEY] = {
    text = "%s",
    button1 = YES,
    button2 = NO,
    OnAccept = function(self)
        QuestieQuest:HideQuest(self.data)
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
}

---Asks whether the icon of a quest the player just abandoned should be hidden, since the quest is available again.
---@param questId QuestId
function AbandonHidePrompt.Show(questId)
    if (not Questie.db.profile.askToHideAbandonedQuests) then
        return
    end

    -- Nothing to hide: Questie draws no icon for an unknown, blacklisted or already hidden quest
    if (not QuestieDB.QuestPointers[questId]) or QuestieCorrections.hiddenQuests[questId] or Questie.db.char.hidden[questId] then
        return
    end

    local questName = QuestieLib:GetColoredQuestName(questId, Questie.db.profile.enableTooltipsQuestLevel, false)
    Popup.Show(DIALOG_KEY, l10n("You abandoned the quest '%s'.\nDo you want to hide its icon?", questName), nil, questId)
end
