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

if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE and false then
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

if GetAddOnMetadata("Questie", "Version") ~= "6.5.1" then
    StaticPopupDialogs["QUESTIE_NOT_RESTARTED"] = {
        text = "You just updated Questie but forgot to restart the WoW client. Questie will not work properly if you don't restart!",
        button2 = "Okay, I will restart",
        hasEditBox = false,
        whileDead = true
    }
    StaticPopup_Show("QUESTIE_NOT_RESTARTED")
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

--Initialized below
---@class Questie
Questie = LibStub("AceAddon-3.0"):NewAddon("Questie", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0", "AceComm-3.0", "AceSerializer-3.0", "AceBucket-3.0")

-- preinit placeholder to stop tukui crashing from literally force-removing one of our features no matter what users select in the config ui
Questie.db = {profile={minimap={hide=false}}}

-- prevent multiple warnings for the same ID, not sure the best place to put this
Questie._sessionWarnings = {}

Questie.IsTBC = WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC
Questie.IsClassic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
