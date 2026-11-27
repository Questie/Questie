dofile("setupTests.lua")

describe("AbandonHidePrompt", function()
    ---@type AbandonHidePrompt
    local AbandonHidePrompt

    ---@type QuestiePopup
    local Popup
    ---@type QuestieQuest
    local QuestieQuest
    ---@type QuestieLib
    local QuestieLib
    ---@type QuestieDB
    local QuestieDB
    ---@type QuestieCorrections
    local QuestieCorrections

    local QUEST_ID = 123
    local DIALOG_KEY = "QUESTIE_ABANDON_HIDE_CONFIRM"

    before_each(function()
        dofile("setupTests.lua")
        dofile("Localization/l10n.lua")
        _G.YES, _G.NO = "Yes", "No"

        Questie.db.profile.askToHideAbandonedQuests = true
        Questie.db.profile.enableTooltipsQuestLevel = true
        Questie.db.char.hidden = {}

        Popup = QuestieLoader:ImportModule("QuestiePopup")
        Popup.Dialogs = {}
        Popup.Show = spy.new(function() end)
        QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")
        QuestieQuest.HideQuest = spy.new(function() end)
        QuestieLib = QuestieLoader:ImportModule("QuestieLib")
        QuestieLib.GetColoredQuestName = spy.new(function() return "[10] Test Quest" end)
        QuestieDB = QuestieLoader:ImportModule("QuestieDB")
        QuestieDB.QuestPointers = {[QUEST_ID] = 1}
        QuestieCorrections = QuestieLoader:ImportModule("QuestieCorrections")
        QuestieCorrections.hiddenQuests = {}

        dofile("Modules/Quest/AbandonHidePrompt.lua")
        AbandonHidePrompt = QuestieLoader:ImportModule("AbandonHidePrompt")
    end)

    describe("Show", function()
        it("should ask whether to hide the abandoned quest", function()
            AbandonHidePrompt.Show(QUEST_ID)

            assert.spy(QuestieLib.GetColoredQuestName).was.called_with(QuestieLib, QUEST_ID, true, false)
            assert.spy(Popup.Show).was.called_with(
                DIALOG_KEY, "You abandoned the quest '[10] Test Quest'.\nDo you want to hide its icon?", nil, QUEST_ID
            )
            assert.spy(QuestieQuest.HideQuest).was.not_called()
        end)

        it("should not ask when the setting is disabled", function()
            Questie.db.profile.askToHideAbandonedQuests = false

            AbandonHidePrompt.Show(QUEST_ID)

            assert.spy(Popup.Show).was.not_called()
        end)

        it("should not ask for a quest that is already hidden by the player", function()
            Questie.db.char.hidden[QUEST_ID] = true

            AbandonHidePrompt.Show(QUEST_ID)

            assert.spy(Popup.Show).was.not_called()
        end)

        it("should not ask for a quest that is hidden by Questie", function()
            QuestieCorrections.hiddenQuests[QUEST_ID] = true

            AbandonHidePrompt.Show(QUEST_ID)

            assert.spy(Popup.Show).was.not_called()
        end)

        it("should not ask for a quest that is not in the database", function()
            QuestieDB.QuestPointers = {}

            AbandonHidePrompt.Show(QUEST_ID)

            assert.spy(Popup.Show).was.not_called()
        end)
    end)

    describe("dialog", function()
        it("should hide the quest when accepted", function()
            local dialog = Popup.Dialogs[DIALOG_KEY]

            assert.are_same("Yes", dialog.button1)
            assert.are_same("No", dialog.button2)
            assert.is_nil(dialog.OnCancel)

            dialog.OnAccept({data = QUEST_ID})

            assert.spy(QuestieQuest.HideQuest).was.called_with(QuestieQuest, QUEST_ID)
        end)
    end)
end)
