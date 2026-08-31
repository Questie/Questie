---@class ChatFilter
local ChatFilter = QuestieLoader:CreateModule("ChatFilter")
---@type QuestieLink
local QuestieLink = QuestieLoader:ImportModule("QuestieLink")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")

-- Compatibility: 2.5.5+ uses ChatFrameUtil.AddMessageEventFilter instead of ChatFrame_AddMessageEventFilter
local ChatFrameAddMessageEventFilter = ChatFrameUtil and ChatFrameUtil.AddMessageEventFilter or ChatFrame_AddMessageEventFilter

-- Tracks quest IDs for which we have already triggered a data prefetch, to avoid spamming the server
---@type table<QuestId, boolean>
local prefetchedQuestIds = {}

---------------------------------------------------------------------------------------------------
-- These must be loaded in order together and loaded before the hook for custom quest links
-- The Hyperlink hook is located in Link.lua
---------------------------------------------------------------------------------------------------

-- Escape the magic characters for gsub
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

local nativeQuestPattern = "|cff%x%x%x%x%x%x%x?%x?|Hquest:(%d+):%d+|h%[(.-)%]|h|r"

---@param message string
---@param questId number
---@param sender string
---@param searchPattern string -- The exact pattern to search for in the message
---@return string
local function processQuestLink(message, questId, sender, searchPattern)
    if not (questId and QuestieDB.QuestPointers[questId]) then
        return message
    end

    if (not prefetchedQuestIds[questId]) and (not HaveQuestData(questId)) then
        prefetchedQuestIds[questId] = true
        C_QuestLog.GetQuestObjectives(questId)
    end

    local questLink = QuestieLink:GetQuestHyperLink(questId, sender)
    return string.gsub(message, searchPattern, questLink)
end

---@param message string
---@param sender string
---@return string
local function replaceNativeQuestLinks(message, sender)
    local result = message
    for questIdStr, questName in string.gmatch(message, nativeQuestPattern) do
        local questId = tonumber(questIdStr)
        -- Build the exact pattern to match this specific native link
        local escapedQuestName = escapeMagic(questName)
        local searchPattern = "|cff%x%x%x%x%x%x%x?%x?|Hquest:" .. questIdStr .. ":%d+|h%[" .. escapedQuestName .. "%]|h|r"
        result = processQuestLink(result, questId, sender, searchPattern)
    end
    return result
end

--- Message Event Filter which intercepts incoming linked quests and replaces them with Hyperlinks
ChatFilter.Filter = function(chatFrame, _, msg, playerName, languageName, channelName, playerName2, specialFlags, zoneChannelID, channelIndex, channelBaseName,
    unused, lineID, senderGUID, bnSenderID, ...)
    if (not Questie.started) then
        return
    end

    local sender = senderGUID or bnSenderID or "0"
    msg = replaceNativeQuestLinks(msg, sender)

    -- Existing bracketed link handling
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
                    local linkSender = senderGUID or bnSenderID or "0"

                    if (not prefetchedQuestIds[questId]) and (not HaveQuestData(questId)) then
                        prefetchedQuestIds[questId] = true
                        C_QuestLog.GetQuestObjectives(questId)
                    end

                    if questName then
                        questName = escapeMagic(questName)
                    end

                    if questLevel then
                        questLevel = escapeMagic(questLevel)
                    end

                    local searchPattern
                    if questLevel then
                        searchPattern = "%[%[" .. questLevel .. "%] " .. questName .. " %(" .. sqid .. "%)%]"
                    else
                        searchPattern = "%[" .. questName .. " %(" .. sqid .. "%)%]"
                    end

                    msg = processQuestLink(msg, questId, linkSender, searchPattern)
                end
            end
            return false, msg, playerName, languageName, channelName, playerName2, specialFlags, zoneChannelID, channelIndex, channelBaseName, unused, lineID,
                senderGUID, bnSenderID, ...
        end
    end
    -- Return modified message even if only native links were replaced
    return false, msg, playerName, languageName, channelName, playerName2, specialFlags, zoneChannelID, channelIndex, channelBaseName, unused, lineID, senderGUID,
        bnSenderID, ...
end

function ChatFilter:RegisterEvents() -- todo: register immediately and cache calls until db is available
    -- Party
    ChatFrameAddMessageEventFilter("CHAT_MSG_PARTY", ChatFilter.Filter)
    ChatFrameAddMessageEventFilter("CHAT_MSG_PARTY_LEADER", ChatFilter.Filter)

    -- Raid
    ChatFrameAddMessageEventFilter("CHAT_MSG_RAID", ChatFilter.Filter)
    ChatFrameAddMessageEventFilter("CHAT_MSG_RAID_LEADER", ChatFilter.Filter)
    ChatFrameAddMessageEventFilter("CHAT_MSG_RAID_WARNING", ChatFilter.Filter)

    -- Guild
    ChatFrameAddMessageEventFilter("CHAT_MSG_GUILD", ChatFilter.Filter)
    ChatFrameAddMessageEventFilter("CHAT_MSG_OFFICER", ChatFilter.Filter)

    -- Battleground
    ChatFrameAddMessageEventFilter("CHAT_MSG_INSTANCE_CHAT", ChatFilter.Filter)
    ChatFrameAddMessageEventFilter("CHAT_MSG_INSTANCE_CHAT_LEADER", ChatFilter.Filter)

    -- Whisper
    ChatFrameAddMessageEventFilter("CHAT_MSG_WHISPER", ChatFilter.Filter)
    ChatFrameAddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", ChatFilter.Filter)

    -- Battle Net
    ChatFrameAddMessageEventFilter("CHAT_MSG_BN", ChatFilter.Filter)
    ChatFrameAddMessageEventFilter("CHAT_MSG_BN_WHISPER", ChatFilter.Filter)
    ChatFrameAddMessageEventFilter("CHAT_MSG_BN_WHISPER_INFORM", ChatFilter.Filter)

    -- Open world
    ChatFrameAddMessageEventFilter("CHAT_MSG_CHANNEL", ChatFilter.Filter)
    ChatFrameAddMessageEventFilter("CHAT_MSG_SAY", ChatFilter.Filter)
    ChatFrameAddMessageEventFilter("CHAT_MSG_YELL", ChatFilter.Filter)

    -- Emote
    ChatFrameAddMessageEventFilter("CHAT_MSG_EMOTE", ChatFilter.Filter)
end
