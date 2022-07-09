---@class QuestieShutUp
local QuestieShutUp = QuestieLoader:CreateModule("QuestieShutUp")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local stringFind = string.find
local pattern

function QuestieShutUp.FilterFunc(self, event, msg, author, ...)
    if stringFind(msg, pattern) then
        return true
    end
end

function QuestieShutUp:ToggleFilters(value)
    if value then
        pattern = "^"..(l10n:GetUILocale() == "ruRU" and "{звезда}" or "{rt1}").." Questie : "
        Questie:Debug(Questie.DEBUG_DEVELOP, "QuestieShutUp toggle on. Pattern:", pattern)
        ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY", QuestieShutUp.FilterFunc)
        ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY_LEADER", QuestieShutUp.FilterFunc)
        ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID", QuestieShutUp.FilterFunc)
        ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_LEADER", QuestieShutUp.FilterFunc)
    else
        Questie:Debug(Questie.DEBUG_DEVELOP, "QuestieShutUp toggle off.")
        ChatFrame_RemoveMessageEventFilter("CHAT_MSG_PARTY", QuestieShutUp.FilterFunc)
        ChatFrame_RemoveMessageEventFilter("CHAT_MSG_PARTY_LEADER", QuestieShutUp.FilterFunc)
        ChatFrame_RemoveMessageEventFilter("CHAT_MSG_RAID", QuestieShutUp.FilterFunc)
        ChatFrame_RemoveMessageEventFilter("CHAT_MSG_RAID_LEADER", QuestieShutUp.FilterFunc)
    end
end
