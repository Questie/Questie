local addonName, _ = ...

-- Check addon is not renamed to avoid conflicts in global name space.
if addonName ~= "Questie" then
    local msg = { "You have renamed Questie addon.", "This is restricted to avoid issues.", "Please remove '"..addonName.."'", "and reinstall the original version."}
    StaticPopupDialogs["QUESTIE_ADDON_NAME_ERROR"] = {
        text = "|cffff0000ERROR|r\n"..msg[1].."\n"..msg[2].."\n\n"..msg[3].."\n"..msg[4],
        button2 = "OK",
        hasEditBox = false,
        whileDead = true,
    }

    C_Timer.After(4, function()
        DEFAULT_CHAT_FRAME:AddMessage("---------------------------------")
        DEFAULT_CHAT_FRAME:AddMessage("|cffff0000ERROR|r: |cff42f5ad"..msg[1].."|r")
        DEFAULT_CHAT_FRAME:AddMessage("|cffff0000ERROR|r: |cff42f5ad"..msg[2].."|r")
        DEFAULT_CHAT_FRAME:AddMessage("|cffff0000ERROR|r: |cff42f5ad"..msg[3].."|r")
        DEFAULT_CHAT_FRAME:AddMessage("|cffff0000ERROR|r: |cff42f5ad"..msg[4].."|r")
        DEFAULT_CHAT_FRAME:AddMessage("---------------------------------")
        error("ERROR: "..msg[1].." "..msg[2].." "..msg[3])
    end)
    StaticPopup_Show("QUESTIE_ADDON_NAME_ERROR")
    return
end

if Questie then
    C_Timer.After(4, function()
        error("ERROR!! -> Questie already loaded! Please only have one Questie installed!")
        for _=1, 10 do
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000ERROR!!|r -> Questie already loaded! Please only have one Questie installed!")
        end
    end);
    error("ERROR!! -> Questie already loaded! Please only have one Questie installed!")
    DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000ERROR!!|r -> Questie already loaded! Please only have one Questie installed!")
    Questie = {}
    return
end

--Initialized below
---@class Questie : AceAddon, AceConsole-3.0, AceEvent-3.0, AceTimer-3.0, AceComm-3.0, AceBucket-3.0
Questie = LibStub("AceAddon-3.0"):NewAddon("Questie", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0", "AceComm-3.0", "AceBucket-3.0")

-- preinit placeholder to stop tukui crashing from literally force-removing one of our features no matter what users select in the config ui
Questie.db = {profile={minimap={hide=false}}}

-- prevent multiple warnings for the same ID, not sure the best place to put this
Questie._sessionWarnings = {}

local clientVersion = GetBuildInfo()
--- Addon is running on Classic Wotlk client
---@type boolean
Questie.IsWotlk = WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC

--- Addon is running on Classic TBC client
---@type boolean
Questie.IsTBC = WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC

--- Addon is running on Classic "Vanilla" client: Means Classic Era and its seasons like SoM
---@type boolean
Questie.IsClassic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC

--- Addon is running on Classic "Vanilla" client and on Era realm
---@type boolean
Questie.IsEra = Questie.IsClassic and (not C_Seasons.HasActiveSeason())

--- Addon is running on Classic "Vanilla" client and on Seasons of Mastery realm
---@type boolean
Questie.IsSoM = Questie.IsClassic and C_Seasons.HasActiveSeason() and (C_Seasons.GetActiveSeason() == Enum.SeasonID.SeasonOfMastery)
