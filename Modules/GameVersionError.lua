-- No timeres or other fancy stuff as 1.12 client is very limited.

-- StaticPopup has very limited width, so text is split to many lines.
local msg = {
    "You're trying to use Questie addon",
    "on an unsupported WoW game client!",

    "WoW \"retail\" and private servers",
    "are not supported.",

    "Questie only supports",
    "WoW Classic (TBC/Era/SoM)!",
}
StaticPopupDialogs["QUESTIE_VERSION_ERROR"] = {
    text = "|cffff0000ERROR|r\n"..msg[1].."\n"..msg[2].."\n\n"..msg[3].."\n"..msg[4].."\n\n"..msg[5].."\n"..msg[6],
    button2 = "OK",
    hasEditBox = false,
    whileDead = true
}
StaticPopup_Show("QUESTIE_VERSION_ERROR")

DEFAULT_CHAT_FRAME:AddMessage("---------------------------------")
DEFAULT_CHAT_FRAME:AddMessage("|cffff0000ERROR|r: |cff42f5ad"..msg[1].." "..msg[2].."|r")
DEFAULT_CHAT_FRAME:AddMessage("|cffff0000ERROR|r: |cff42f5ad"..msg[3].." "..msg[4].."|r")
DEFAULT_CHAT_FRAME:AddMessage("|cffff0000ERROR|r: |cff42f5ad"..msg[5].." "..msg[6].."|r")
DEFAULT_CHAT_FRAME:AddMessage("---------------------------------")
