---@type AvailableQuests
local AvailableQuests = QuestieLoader:ImportModule("AvailableQuests")

local f = CreateFrame("Frame")
local function onEvent(_, event, addOnName)
    if addOnName == "Blizzard_QuestChoice" then
        -- We encountered this Blizzard addon for the first time, when choosing PvE vs PvP quests on the Isle of Thunder in phase 2.
        -- Blizzard silently completes the quests 32259, 32260 (PvE) or 32258, 32261 (PvP) depending on the players choice and
        -- does not fire any quest events other than QUEST_LOG_UPDATE for them.
        -- To work around this, we wait for this addon to load, wait for the related UI frame to close and then check if those quests were completed.

        if QuestChoiceFrame then
            QuestChoiceFrame:SetScript("OnHide", function()
                f:RegisterEvent("QUEST_LOG_UPDATE")
            end)
        end
    elseif event == "QUEST_LOG_UPDATE" then
        -- Delay the check a bit to ensure the quest log is fully updated
        C_Timer.After(0.5, function()
            -- Horde
            Questie.db.char.complete[32258] = C_QuestLog.IsQuestFlaggedCompleted(32258) and true or nil
            Questie.db.char.complete[32259] = C_QuestLog.IsQuestFlaggedCompleted(32259) and true or nil

            -- Alliance
            Questie.db.char.complete[32260] = C_QuestLog.IsQuestFlaggedCompleted(32260) and true or nil
            Questie.db.char.complete[32261] = C_QuestLog.IsQuestFlaggedCompleted(32261) and true or nil

            if Questie.db.char.complete[32258] or Questie.db.char.complete[32259] or Questie.db.char.complete[32260] or Questie.db.char.complete[32261] then
                -- One of the Isle of Thunder choice quests was completed, we need to manually trigger this because of the lack of proper events.
                AvailableQuests.CalculateAndDrawAll()
            end
        end)

        f:UnregisterEvent("QUEST_LOG_UPDATE")
    end
end
f:SetScript("OnEvent", onEvent)
f:RegisterEvent("ADDON_LOADED")
