local QuestieShutUp = QuestieLoader:CreateModule("QuestieShutUp")

local Questie = _G.Questie

function QuestieShutUp:FilterFunc(self, event, msg, author, ...)
    if not Questie.db.global.questieShutUp then
        return false;
    end

    if msg:find(" Questie : ") then
        return true;
    end
end

function QuestieShutUp:ToggleFilters(value)
    ChatFrame1:AddMessage("Questie ShutUp! toggled on or off")
    if value then
        ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY", QuestieShutUp.FilterFunc)
        ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY_LEADER", QuestieShutUp.FilterFunc)
        ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID", QuestieShutUp.FilterFunc)
        ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_LEADER", QuestieShutUp.FilterFunc)
    else
        ChatFrame_RemoveMessageEventFilter("CHAT_MSG_PARTY", QuestieShutUp.FilterFunc)
        ChatFrame_RemoveMessageEventFilter("CHAT_MSG_PARTY_LEADER", QuestieShutUp.FilterFunc)
        ChatFrame_RemoveMessageEventFilter("CHAT_MSG_RAID", QuestieShutUp.FilterFunc)
        ChatFrame_RemoveMessageEventFilter("CHAT_MSG_RAID_LEADER", QuestieShutUp.FilterFunc)
    end
end
