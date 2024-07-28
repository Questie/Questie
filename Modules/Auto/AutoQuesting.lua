---@class AutoQuesting
local AutoQuesting = QuestieLoader:CreateModule("AutoQuesting")

function AutoQuesting.HandleGossipShow()
    if (not Questie.db.profile.autoaccept) then
        return
    end

    local availableQuests = { QuestieCompat.GetAvailableQuests() }

    if #availableQuests > 0 then
        QuestieCompat.SelectAvailableQuest(1)
    end
end

return AutoQuesting
