local msg = { "You're trying to use Questie Addon on unsupported WoW Game client!", "Questie Addon is supporting WoW Classic (TBC/Era/SoM/etc) only!" }
StaticPopupDialogs["QUESTIE_VERSION_ERROR"] = {
    text = "|cffff0000ERROR|r\n"..msg[1].."\n"..msg[2],
    button2 = "OK",
    hasEditBox = false,
    whileDead = true
}
StaticPopup_Show("QUESTIE_VERSION_ERROR")

DEFAULT_CHAT_FRAME:AddMessage("---------------------------------")
DEFAULT_CHAT_FRAME:AddMessage("|cffff0000ERROR|r: |cff42f5ad"..msg[1].."|r")
DEFAULT_CHAT_FRAME:AddMessage("|cffff0000ERROR|r: |cff42f5ad"..msg[2].."|r")