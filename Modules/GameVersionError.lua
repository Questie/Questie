---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

-- No timeres or other fancy stuff as 1.12 client is very limited.

-- StaticPopup has very limited width, so text is split to many lines.
local msg = {
    l10n("You're trying to use Questie addon"),
    l10n("on an unsupported WoW game client!"),

    l10n("WoW \"retail\" and private servers"),
    l10n("are not supported."),

    l10n("Questie only supports"),
    l10n("WoW Classic (Era/Wrath)!"),
}

StaticPopupDialogs["QUESTIE_VERSION_ERROR"] = {
    text = "|cffff0000ERROR|r\n" .. msg[1] .. "\n" .. msg[2] .. "\n\n" .. msg[3] .. "\n" .. msg[4] .. "\n\n" .. msg[5] .. "\n" .. msg[6],
    button2 = "OK",
    hasEditBox = false,
    whileDead = true
}

StaticPopup_Show("QUESTIE_VERSION_ERROR")

DEFAULT_CHAT_FRAME:AddMessage("---------------------------------")
DEFAULT_CHAT_FRAME:AddMessage("|cffff0000ERROR|r: |cff42f5ad" .. msg[1] .. " " .. msg[2] .. "|r")
DEFAULT_CHAT_FRAME:AddMessage("|cffff0000ERROR|r: |cff42f5ad" .. msg[3] .. " " .. msg[4] .. "|r")
DEFAULT_CHAT_FRAME:AddMessage("|cffff0000ERROR|r: |cff42f5ad" .. msg[5] .. " " .. msg[6] .. "|r")
DEFAULT_CHAT_FRAME:AddMessage("---------------------------------")
