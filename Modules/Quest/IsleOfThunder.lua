local f = CreateFrame("Frame")
local function onEvent(_, event, addOnName)
    if addOnName == "Blizzard_QuestChoice" then
        -- We encountered this Blizzard addon for the first time, when choosing PvE vs PvP quests on the Isle of Thunder in phase 2.
        -- Blizzard silently completes the quests 32259, 32260 (PvE) or 32258, 32261 (PvP) depending on the players choice and
        -- does not fire any quest events other than QUEST_LOG_UPDATE for them.
        -- To work around this, we wait for this addon to load, wait for the related UI frame to close and then check if those quests were completed.

        if QuestChoiceFrame then
            print("Hooking QuestChoiceFrame OnHide to check quest completion status...")
            QuestChoiceFrame:SetScript("OnHide", function()
                f:RegisterEvent("QUEST_LOG_UPDATE")
            end)
        else
            print("QuestChoiceFrame not loaded!")
        end
    elseif event == "QUEST_LOG_UPDATE" then
        print("QuestChoiceFrame hidden, checking quest completion status...")
        print("C_QuestLog.IsQuestFlaggedCompleted(32259)", C_QuestLog.IsQuestFlaggedCompleted(32259))
        print("C_QuestLog.IsQuestFlaggedCompleted(32260)", C_QuestLog.IsQuestFlaggedCompleted(32260))

        print("C_QuestLog.IsQuestFlaggedCompleted(32258)", C_QuestLog.IsQuestFlaggedCompleted(32258))
        print("C_QuestLog.IsQuestFlaggedCompleted(32261)", C_QuestLog.IsQuestFlaggedCompleted(32261))

        Questie.db.char.complete[32259] = C_QuestLog.IsQuestFlaggedCompleted(32259) and true or nil
        Questie.db.char.complete[32260] = C_QuestLog.IsQuestFlaggedCompleted(32260) and true or nil

        Questie.db.char.complete[32258] = C_QuestLog.IsQuestFlaggedCompleted(32258) and true or nil
        Questie.db.char.complete[32261] = C_QuestLog.IsQuestFlaggedCompleted(32261) and true or nil
        f:UnregisterEvent("QUEST_LOG_UPDATE")
    end
end
f:SetScript("OnEvent", onEvent)
f:RegisterEvent("ADDON_LOADED")
