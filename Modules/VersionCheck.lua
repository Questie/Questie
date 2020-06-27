if GetBuildInfo() <= '1.13' then
    StaticPopupDialogs["VERSION_ERROR"] = {
        text = "|cffff0000ERROR|r\nYou're trying to use Questie on vanilla WoW!\nQuestie is supporting WoW Classic only!\n\nYou should come and join the real WoW",
        button2 = "Okay, maybe I will",
        hasEditBox = false,
        whileDead = true
    }
    StaticPopup_Show("VERSION_ERROR")

    DEFAULT_CHAT_FRAME:AddMessage("---------------------------------")
    DEFAULT_CHAT_FRAME:AddMessage("|cffff0000ERROR|r: |cff42f5adYou're trying to use Questie on vanilla WoW!|r")
    DEFAULT_CHAT_FRAME:AddMessage("|cffff0000ERROR|r: |cff42f5adThis version of Questie supports WoW Classic only!")
    return
end

if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
    StaticPopupDialogs["RETAIL_ERROR"] = {
        text = "|cffff0000ERROR|r\nYou're trying to use Questie on retail WoW!\nQuestie is supporting WoW Classic only!\n\nYou should come and join the real WoW",
        button2 = "Okay, maybe I will",
        hasEditBox = false,
        whileDead = true
    }

    C_Timer.After(4, function()
        DEFAULT_CHAT_FRAME:AddMessage("---------------------------------")
        DEFAULT_CHAT_FRAME:AddMessage("|cffff0000ERROR|r: |cff42f5adYou're trying to use Questie on retail WoW!|r")
        DEFAULT_CHAT_FRAME:AddMessage("|cffff0000ERROR|r: |cff42f5adQuestie is supporting WoW Classic only!")
        DEFAULT_CHAT_FRAME:AddMessage("---------------------------------")
        error("ERROR: You're trying to use Questie on retail WoW. Questie is supporting WoW Classic only!")
    end)
    StaticPopup_Show("RETAIL_ERROR")
    return
end

if Questie then
    C_Timer.After(4, function()
        error("ERROR!! -> Questie already loaded! Please only have one Questie installed!")
        for i=1, 10 do
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000ERROR!!|r -> Questie already loaded! Please only have one Questie installed!")
        end
    end);
    error("ERROR!! -> Questie already loaded! Please only have one Questie installed!")
    DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000ERROR!!|r -> Questie already loaded! Please only have one Questie installed!")
    Questie = {}
    return
end
