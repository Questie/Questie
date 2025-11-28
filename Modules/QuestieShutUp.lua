---@class QuestieShutUp
local QuestieShutUp = QuestieLoader:CreateModule("QuestieShutUp")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

-- Compatibility: 2.5.5+ uses ChatFrameUtil.AddMessageEventFilter/RemoveMessageEventFilter instead of ChatFrame_AddMessageEventFilter/RemoveMessageEventFilter
local ChatFrameAddMessageEventFilter = ChatFrameUtil and ChatFrameUtil.AddMessageEventFilter or ChatFrame_AddMessageEventFilter
local ChatFrameRemoveMessageEventFilter = ChatFrameUtil and ChatFrameUtil.RemoveMessageEventFilter or ChatFrame_RemoveMessageEventFilter

-- Safe wrapper for ChatFrameAddMessageEventFilter that handles initialization timing issues
local function SafeAddMessageEventFilter(event, filter)
    local success, err = pcall(function()
        ChatFrameAddMessageEventFilter(event, filter)
    end)
    if not success then
        -- If ChatFrameUtil isn't ready yet, retry after a short delay
        if err and string.find(err, "CreateSecureFiltersArray") then
            C_Timer.After(0.1, function()
                SafeAddMessageEventFilter(event, filter)
            end)
        else
            Questie:Error("Failed to register chat filter for", event, ":", err)
        end
    end
end

-- Safe wrapper for ChatFrameRemoveMessageEventFilter
local function SafeRemoveMessageEventFilter(event, filter)
    local success, err = pcall(function()
        ChatFrameRemoveMessageEventFilter(event, filter)
    end)
    if not success then
        -- If ChatFrameUtil isn't ready yet, retry after a short delay
        if err and string.find(err, "CreateSecureFiltersArray") then
            C_Timer.After(0.1, function()
                SafeRemoveMessageEventFilter(event, filter)
            end)
        else
            Questie:Error("Failed to remove chat filter for", event, ":", err)
        end
    end
end

local stringFind = string.find
local pattern

function QuestieShutUp.FilterFunc(self, event, msg, author, ...)
    if stringFind(msg, pattern) then
        return true
    end
end

function QuestieShutUp:ToggleFilters(value)
    if value then
        -- In French a blank is added before the colon, so we need to account for that (%s?)
        pattern = "^"..(l10n:GetUILocale() == "ruRU" and "{звезда}" or "{rt1}").." Questie%s?: "
        Questie:Debug(Questie.DEBUG_DEVELOP, "QuestieShutUp toggle on. Pattern:", pattern)
        SafeAddMessageEventFilter("CHAT_MSG_PARTY", QuestieShutUp.FilterFunc)
        SafeAddMessageEventFilter("CHAT_MSG_PARTY_LEADER", QuestieShutUp.FilterFunc)
        SafeAddMessageEventFilter("CHAT_MSG_RAID", QuestieShutUp.FilterFunc)
        SafeAddMessageEventFilter("CHAT_MSG_RAID_LEADER", QuestieShutUp.FilterFunc)
        SafeAddMessageEventFilter("CHAT_MSG_INSTANCE_CHAT", QuestieShutUp.FilterFunc)
        SafeAddMessageEventFilter("CHAT_MSG_INSTANCE_CHAT_LEADER", QuestieShutUp.FilterFunc)
    else
        Questie:Debug(Questie.DEBUG_DEVELOP, "QuestieShutUp toggle off.")
        SafeRemoveMessageEventFilter("CHAT_MSG_PARTY", QuestieShutUp.FilterFunc)
        SafeRemoveMessageEventFilter("CHAT_MSG_PARTY_LEADER", QuestieShutUp.FilterFunc)
        SafeRemoveMessageEventFilter("CHAT_MSG_RAID", QuestieShutUp.FilterFunc)
        SafeRemoveMessageEventFilter("CHAT_MSG_RAID_LEADER", QuestieShutUp.FilterFunc)
        SafeRemoveMessageEventFilter("CHAT_MSG_INSTANCE_CHAT", QuestieShutUp.FilterFunc)
        SafeRemoveMessageEventFilter("CHAT_MSG_INSTANCE_CHAT_LEADER", QuestieShutUp.FilterFunc)
    end
end
