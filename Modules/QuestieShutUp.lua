local QuestieShutUp = CreateFrame("Frame");

QuestieShutUp:RegisterEvent("PLAYER_ENTERING_WORLD");
QuestieShutUp:SetScript("OnEvent", function(self, event, arg1, arg2, arg3, arg4, arg5) QuestieShutUp_OnEvent(event, arg1, arg2, arg3, arg4, arg5) end);

local Questie = _G.Questie;

function FilterFunc(self, event, msg, author, ...)
    if not Questie.db.global.questieShutUp then
        return false;
    end

    if msg:find(" Questie : ") then
        return true;
    end
end

function QuestieShutUp_OnEvent(event, arg1, arg2, arg3, arg4, arg5)
    if event == "PLAYER_ENTERING_WORLD" then
        ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY", FilterFunc);
        ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY_LEADER", FilterFunc);
    end
end
