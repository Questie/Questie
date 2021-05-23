---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")

---------------------------------------------------------------------------------------------------
-- These must be loaded in order together and loaded before the hook for custom quest links
-- The Hyperlink hook is located in Link.lua
---------------------------------------------------------------------------------------------------

--- Message Event Filter which intercepts incoming linked quests and replaces them with Hyperlinks
local function QuestsFilter(chatFrame, _, msg, playerName, languageName, channelName, playerName2, specialFlags, zoneChannelID, channelIndex, channelBaseName, unused, lineID, senderGUID, bnSenderID, ...)
    if string.find(msg, "%[(..-) %((%d+)%)%]") then
        if chatFrame and chatFrame.historyBuffer and #(chatFrame.historyBuffer.elements) > 0 and chatFrame ~= _G.ChatFrame2 then
            for k in string.gmatch(msg, "%[%[?%d?..?%]?..-%]") do
                local complete, sqid, questId, questLevel, questName, realQuestName, realQuestLevel
                
                if Questie.IsTBC then
                    questName, sqid = string.match(k, "%[(..-) %((%d+)%)%]")
                else
                    _, _, questName, sqid = string.match(k, "%[(..-) %((%d+)%)%]")
                end

                if questName and sqid then
                    questId = tonumber(sqid)

                    if string.find(questName, "(%[%d+.-%]) ") ~= nil then
                        if Questie.IsTBC then
                            questLevel, questName = string.match(questName, "%[(..-)%] (.+)")
                        else
                            _, _, questLevel, questName = string.match(questName, "%[(..-)%] (.+)")
                        end
                    end

                    if QuestieDB.QueryQuest then
                        realQuestName = QuestieDB.QueryQuestSingle(questId, "name");
                        realQuestLevel, _ = QuestieLib:GetTbcLevel(questId);

                        if questName and questId then
                            complete = QuestieDB:IsComplete(questId)
                        end
                    end
                end

                if realQuestName and questId then
                    local coloredQuestName = QuestieLib:GetColoredQuestName(questId, Questie.db.global.trackerShowQuestLevel, true, false)

                    if senderGUID == nil then
                        playerName = BNGetFriendInfoByID(bnSenderID)
                        senderGUID = bnSenderID
                    end

                    local questLink = "|Hquestie:"..sqid..":"..senderGUID.."|h"..QuestieLib:PrintDifficultyColor(realQuestLevel, "[")..coloredQuestName..QuestieLib:PrintDifficultyColor(realQuestLevel, "]").."|h"

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

-- The message filter that triggers the above local function

-- Party
ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY", QuestsFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY_LEADER", QuestsFilter)

-- Raid
ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID", QuestsFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_LEADER", QuestsFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_WARNING", QuestsFilter)

-- Guild
ChatFrame_AddMessageEventFilter("CHAT_MSG_GUILD", QuestsFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_OFFICER", QuestsFilter)

-- Battleground
ChatFrame_AddMessageEventFilter("CHAT_MSG_INSTANCE_CHAT", QuestsFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_INSTANCE_CHAT_LEADER", QuestsFilter)

-- Whisper
ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", QuestsFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", QuestsFilter)

-- Battle Net
ChatFrame_AddMessageEventFilter("CHAT_MSG_BN", QuestsFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER", QuestsFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER_INFORM", QuestsFilter)

-- Open world
ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", QuestsFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", QuestsFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", QuestsFilter)

-- Emote
ChatFrame_AddMessageEventFilter("CHAT_MSG_EMOTE", QuestsFilter)
