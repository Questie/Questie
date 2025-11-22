---@class ChatFilter
local ChatFilter = QuestieLoader:CreateModule("ChatFilter")
---@type QuestieLink
local QuestieLink = QuestieLoader:ImportModule("QuestieLink")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")

-- Compatibility: 2.5.5+ uses ChatFrameUtil.AddMessageEventFilter instead of ChatFrame_AddMessageEventFilter
local ChatFrameAddMessageEventFilter = ChatFrameUtil and ChatFrameUtil.AddMessageEventFilter or ChatFrame_AddMessageEventFilter

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
    -- Use SafeAddMessageEventFilter to handle ChatFrameUtil initialization timing issues
    -- Party
    SafeAddMessageEventFilter("CHAT_MSG_PARTY", ChatFilter.Filter)
    SafeAddMessageEventFilter("CHAT_MSG_PARTY_LEADER", ChatFilter.Filter)

    -- Raid
    SafeAddMessageEventFilter("CHAT_MSG_RAID", ChatFilter.Filter)
    SafeAddMessageEventFilter("CHAT_MSG_RAID_LEADER", ChatFilter.Filter)
    SafeAddMessageEventFilter("CHAT_MSG_RAID_WARNING", ChatFilter.Filter)

    -- Guild
    SafeAddMessageEventFilter("CHAT_MSG_GUILD", ChatFilter.Filter)
    SafeAddMessageEventFilter("CHAT_MSG_OFFICER", ChatFilter.Filter)

    -- Battleground
    SafeAddMessageEventFilter("CHAT_MSG_INSTANCE_CHAT", ChatFilter.Filter)
    SafeAddMessageEventFilter("CHAT_MSG_INSTANCE_CHAT_LEADER", ChatFilter.Filter)

    -- Whisper
    SafeAddMessageEventFilter("CHAT_MSG_WHISPER", ChatFilter.Filter)
    SafeAddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", ChatFilter.Filter)

    -- Battle Net
    SafeAddMessageEventFilter("CHAT_MSG_BN", ChatFilter.Filter)
    SafeAddMessageEventFilter("CHAT_MSG_BN_WHISPER", ChatFilter.Filter)
    SafeAddMessageEventFilter("CHAT_MSG_BN_WHISPER_INFORM", ChatFilter.Filter)

    -- Open world
    SafeAddMessageEventFilter("CHAT_MSG_CHANNEL", ChatFilter.Filter)
    SafeAddMessageEventFilter("CHAT_MSG_SAY", ChatFilter.Filter)
    SafeAddMessageEventFilter("CHAT_MSG_YELL", ChatFilter.Filter)

    -- Emote
    SafeAddMessageEventFilter("CHAT_MSG_EMOTE", ChatFilter.Filter)
end
