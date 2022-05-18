---@class ChatFilter
local ChatFilter = QuestieLoader:CreateModule("ChatFilter")
---@type QuestieLink
local QuestieLink = QuestieLoader:ImportModule("QuestieLink")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")

---------------------------------------------------------------------------------------------------
-- These must be loaded in order together and loaded before the hook for custom quest links
-- The Hyperlink hook is located in Link.lua
---------------------------------------------------------------------------------------------------

--- Message Event Filter which intercepts incoming linked quests and replaces them with Hyperlinks
ChatFilter.Filter = function(chatFrame, _, msg, playerName, languageName, channelName, playerName2, specialFlags, zoneChannelID, channelIndex, channelBaseName, unused, lineID, senderGUID, bnSenderID, ...)
    if (not Questie.started) then
        return
    end

    if string.find(msg, "%[(..-) %((%d+)%)%]") then
        if chatFrame and chatFrame.historyBuffer and #(chatFrame.historyBuffer.elements) > 0 and chatFrame ~= _G.ChatFrame2 then
            for k in string.gmatch(msg, "%[%[?%d?..?%]?..-%]") do
                local sqid, questId, questLevel, questName

                questName, sqid = string.match(k, "%[(..-) %((%d+)%)%]")

                if questName and sqid then
                    questId = tonumber(sqid)

                    if string.find(questName, "(%[%d+.-%]) ") ~= nil then
                        questLevel, questName = string.match(questName, "%[(..-)%] (.+)")
                    end
                end

                if questId and QuestieDB.QuestPointers[questId] then
                    if (not senderGUID) then
                        playerName = BNGetFriendInfoByID(bnSenderID)
                        senderGUID = bnSenderID
                    end

                    local questLink = QuestieLink:GetQuestHyperLink(questId, senderGUID)

                    -- Escape the magic characters
                    local function escapeMagic(toEsc)
                        return (toEsc
                                :gsub("%%", "%%%%")
                                :gsub("^%^", "%%^")
                                :gsub("%$$", "%%$")
                                :gsub("%(", "%%(")
                                :gsub("%)", "%%)")
                                :gsub("%.", "%%.")
                                :gsub("%[", "%%[")
                                :gsub("%]", "%%]")
                                :gsub("%*", "%%*")
                                :gsub("%+", "%%+")
                                :gsub("%-", "%%-")
                                :gsub("%?", "%%?")
                                :gsub("%|", "%%|")
                        )
                    end

                    if questName then
                        questName = escapeMagic(questName)
                    end

                    if questLevel then
                        questLevel = escapeMagic(questLevel)
                    end

                    if questLevel then
                        msg = string.gsub(msg, "%[%["..questLevel.."%] "..questName.." %("..sqid.."%)%]", questLink)
                    else
                        msg = string.gsub(msg, "%["..questName.." %("..sqid.."%)%]", questLink)
                    end
                end
            end
            return false, msg, playerName, languageName, channelName, playerName2, specialFlags, zoneChannelID, channelIndex, channelBaseName, unused, lineID, senderGUID, bnSenderID, ...
        end
    end
end

function ChatFilter:RegisterEvents() -- todo: register immediately and cache calls until db is available
    -- The message filter that triggers the above local function
    -- Party
    ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY", ChatFilter.Filter)
    ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY_LEADER", ChatFilter.Filter)

    -- Raid
    ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID", ChatFilter.Filter)
    ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_LEADER", ChatFilter.Filter)
    ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_WARNING", ChatFilter.Filter)

    -- Guild
    ChatFrame_AddMessageEventFilter("CHAT_MSG_GUILD", ChatFilter.Filter)
    ChatFrame_AddMessageEventFilter("CHAT_MSG_OFFICER", ChatFilter.Filter)

    -- Battleground
    ChatFrame_AddMessageEventFilter("CHAT_MSG_INSTANCE_CHAT", ChatFilter.Filter)
    ChatFrame_AddMessageEventFilter("CHAT_MSG_INSTANCE_CHAT_LEADER", ChatFilter.Filter)

    -- Whisper
    ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", ChatFilter.Filter)
    ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", ChatFilter.Filter)

    -- Battle Net
    ChatFrame_AddMessageEventFilter("CHAT_MSG_BN", ChatFilter.Filter)
    ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER", ChatFilter.Filter)
    ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER_INFORM", ChatFilter.Filter)

    -- Open world
    ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", ChatFilter.Filter)
    ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", ChatFilter.Filter)
    ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", ChatFilter.Filter)

    -- Emote
    ChatFrame_AddMessageEventFilter("CHAT_MSG_EMOTE", ChatFilter.Filter)
end