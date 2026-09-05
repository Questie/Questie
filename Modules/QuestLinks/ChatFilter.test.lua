dofile("setupTests.lua")

describe("ChatFilter", function()
    ---@type ChatFilter
    local ChatFilter

    ---@type QuestieLink
    local QuestieLink
    ---@type QuestieDB
    local QuestieDB

    before_each(function()
        Questie.started = true
        Questie.db.profile = {
            trackerShowQuestLevel = true,
        }
        Questie.db.char = {
            complete = {},
        }

        QuestieDB = QuestieLoader:ImportModule("QuestieDB")
        QuestieDB.QuestPointers = {[74] = true}
        QuestieDB.IsComplete = function() return 0 end
        QuestieDB.IsRepeatable = function() return false end
        QuestieDB.IsPvPQuest = function() return false end

        dofile("Modules/Libs/QuestieLib.lua")
        local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
        QuestieLib.GetEffectiveQuestLevel = function() return 28 end
        QuestieLib.GetLevelString = function() return "[28] " end
        QuestieLib.PrintDifficultyColor = function(_, _, ...) return "|cffffffff" end

        local QuestieEvent = QuestieLoader:ImportModule("QuestieEvent")
        QuestieEvent.IsEventQuest = function() return false end

        QuestieLink = QuestieLoader:ImportModule("QuestieLink")
        QuestieLink.GetQuestHyperLink = function(_, questId, senderGUID)
            return "|Hquestie:" .. questId .. ":" .. (senderGUID or "0") .. "|h[The Legend of Stalvan]|h"
        end

        dofile("Modules/QuestLinks/ChatFilter.lua")
        ChatFilter = QuestieLoader:ImportModule("ChatFilter")

        _G.HaveQuestData = function() return true end
        _G.C_QuestLog = {GetQuestObjectives = function() return {} end}
        _G.BNGetFriendInfoByID = function() return "TestPlayer" end
    end)

    describe("Filter", function()
        it("should replace native Blizzard quest links with Questie format", function()
            local msg = "Check out this quest: |cffffff00|Hquest:74:28|h[The Legend of Stalvan]|h|r"
            local chatFrame = {historyBuffer = {elements = {1}}}

            local _, filteredMsg = ChatFilter.Filter(chatFrame, nil, msg, "Player", "Common", "CHANNEL", nil, nil, nil, nil, nil, nil, nil, nil)

            assert.is_not_nil(filteredMsg)
            assert.is_equal("Check out this quest: |Hquestie:74:0|h[The Legend of Stalvan]|h", filteredMsg)
        end)

        it("should handle native quest links with regex magic characters in quest name", function()
            QuestieDB.QuestPointers[12345] = true
            QuestieLink.GetQuestHyperLink = function(_, questId, senderGUID)
                return "|Hquestie:12345:" .. (senderGUID or "0") .. "|h[Test [Quest] (Special?)]|h"
            end

            local msg = "Quest: |cffffff00|Hquest:12345:30|h[Test [Quest] (Special?)]|h|r"
            local chatFrame = {historyBuffer = {elements = {1}}}

            local _, filteredMsg = ChatFilter.Filter(chatFrame, nil, msg, "Player", "Common", "CHANNEL", nil, nil, nil, nil, nil, nil, nil, nil)

            assert.is_not_nil(filteredMsg)
            assert.is_equal("Quest: |Hquestie:12345:0|h[Test [Quest] (Special?)]|h", filteredMsg)
        end)

        it("should process a quest link with specific sender GUID", function()
            local msg = "Quest: |cffffff00|Hquest:74:28|h[The Legend of Stalvan]|h|r"
            local chatFrame = {historyBuffer = {elements = {1}}}
            local _, filteredMsg = ChatFilter.Filter(chatFrame, nil, msg, "Player", "Common", "CHANNEL", nil, nil, nil, nil, nil, nil, nil, nil, "TEST_GUID_123",
                nil)

            assert.is_not_nil(filteredMsg)
            assert.is_equal("Quest: |Hquestie:74:TEST_GUID_123|h[The Legend of Stalvan]|h", filteredMsg)
        end)

        it("should replace Questie bracketed links with Questie hyperlink format", function()
            local msg = "Check out this quest: [[28] The Legend of Stalvan (74)]"
            local chatFrame = {historyBuffer = {elements = {1}}}

            local _, filteredMsg = ChatFilter.Filter(chatFrame, nil, msg, "Player", "Common", "CHANNEL", nil, nil, nil, nil, nil, nil, nil, nil)

            assert.is_not_nil(filteredMsg)
            assert.is_equal("Check out this quest: |Hquestie:74:0|h[The Legend of Stalvan]|h", filteredMsg)
        end)

        it("should replace Questie bracketed links without level with Questie hyperlink format", function()
            Questie.db.profile.trackerShowQuestLevel = false
            local msg = "Check out this quest: [The Legend of Stalvan (74)]"
            local chatFrame = {historyBuffer = {elements = {1}}}

            local _, filteredMsg = ChatFilter.Filter(chatFrame, nil, msg, "Player", "Common", "CHANNEL", nil, nil, nil, nil, nil, nil, nil, nil)

            assert.is_not_nil(filteredMsg)
            assert.is_equal("Check out this quest: |Hquestie:74:0|h[The Legend of Stalvan]|h", filteredMsg)
        end)

        it("should replace multiple native quest links in one message", function()
            QuestieDB.QuestPointers[74] = true
            QuestieDB.QuestPointers[88] = true
            QuestieLink.GetQuestHyperLink = function(_, questId, senderGUID)
                if questId == 74 then
                    return "|Hquestie:74:" .. (senderGUID or "0") .. "|h[The Legend of Stalvan]|h"
                elseif questId == 88 then
                    return "|Hquestie:88:" .. (senderGUID or "0") .. "|h[Princess Must Die!]|h"
                end
                return "|Hquestie:" .. questId .. ":" .. (senderGUID or "0") .. "|h[Quest]|h"
            end

            local msg = "Quests: |cffffff00|Hquest:74:28|h[The Legend of Stalvan]|h|r and |cffffff00|Hquest:88:28|h[Princess Must Die!]|h|r"
            local chatFrame = {historyBuffer = {elements = {1}}}

            local _, filteredMsg = ChatFilter.Filter(chatFrame, nil, msg, "Player", "Common", "CHANNEL", nil, nil, nil, nil, nil, nil, nil, nil)

            assert.is_not_nil(filteredMsg)
            assert.is_equal("Quests: |Hquestie:74:0|h[The Legend of Stalvan]|h and |Hquestie:88:0|h[Princess Must Die!]|h", filteredMsg)
        end)

        it("should not replace quest links for quests not in QuestieDB", function()
            QuestieDB.QuestPointers[99999] = nil
            QuestieLink.GetQuestHyperLink = function(_, questId, senderGUID)
                return "|Hquestie:" .. questId .. ":" .. (senderGUID or "0") .. "|h[Unknown Quest]|h"
            end

            local msg = "Check out this quest: |cffffff00|Hquest:99999:28|h[Unknown Quest]|h|r"
            local chatFrame = {historyBuffer = {elements = {1}}}

            local _, filteredMsg = ChatFilter.Filter(chatFrame, nil, msg, "Player", "Common", "CHANNEL", nil, nil, nil, nil, nil, nil, nil, nil)

            assert.is_not_nil(filteredMsg)
            assert.is_equal("Check out this quest: |cffffff00|Hquest:99999:28|h[Unknown Quest]|h|r", filteredMsg)
        end)

        it("should prefetch quest data when HaveQuestData returns false", function()
            _G.HaveQuestData = function()
                return false
            end
            _G.C_QuestLog.GetQuestObjectives = spy.new(function()
                return {}
            end)

            local msg = "Check out this quest: |cffffff00|Hquest:74:28|h[The Legend of Stalvan]|h|r"
            local chatFrame = {historyBuffer = {elements = {1}}}

            local _, filteredMsg = ChatFilter.Filter(chatFrame, nil, msg, "Player", "Common", "CHANNEL", nil, nil, nil, nil, nil, nil, nil, nil)

            assert.spy(_G.C_QuestLog.GetQuestObjectives).was.called()
            assert.is_equal("Check out this quest: |Hquestie:74:0|h[The Legend of Stalvan]|h", filteredMsg)
        end)

        it("should not prefetch quest data when already prefetched", function()
            _G.HaveQuestData = function()
                return false
            end
            _G.C_QuestLog.GetQuestObjectives = spy.new(function()
                return {}
            end)

            local msg = "Check out this quest: |cffffff00|Hquest:74:28|h[The Legend of Stalvan]|h|r"
            local chatFrame = {historyBuffer = {elements = {1}}}

            ChatFilter.Filter(chatFrame, nil, msg, "Player", "Common", "CHANNEL", nil, nil, nil, nil, nil, nil, nil, nil)
            ChatFilter.Filter(chatFrame, nil, msg, "Player", "Common", "CHANNEL", nil, nil, nil, nil, nil, nil, nil, nil)

            assert.spy(_G.C_QuestLog.GetQuestObjectives).was.called(1)
        end)

        it("should use BattleNet senderGUID when senderGUID is nil", function()
            local msg = "Check out this quest: |cffffff00|Hquest:74:28|h[The Legend of Stalvan]|h|r"
            local chatFrame = {historyBuffer = {elements = {1}}}

            local _, filteredMsg = ChatFilter.Filter(chatFrame, nil, msg, "Player", "Common", "CHANNEL", nil, nil, nil, nil, nil, nil, nil, nil, "BN_SENDER_123")

            assert.is_not_nil(filteredMsg)
            assert.is_equal("Check out this quest: |Hquestie:74:BN_SENDER_123|h[The Legend of Stalvan]|h", filteredMsg)
        end)

        it("should use senderGUID when available (not BattleNet)", function()
            local msg = "Check out this quest: |cffffff00|Hquest:74:28|h[The Legend of Stalvan]|h|r"
            local chatFrame = {historyBuffer = {elements = {1}}}

            local _, filteredMsg = ChatFilter.Filter(chatFrame, nil, msg, "Player", "Common", "CHANNEL", nil, nil, nil, nil, nil, nil, nil, nil,
                "PLAYER_GUID_456", nil)

            assert.is_not_nil(filteredMsg)
            assert.is_equal("Check out this quest: |Hquestie:74:PLAYER_GUID_456|h[The Legend of Stalvan]|h", filteredMsg)
        end)

        it("should prefer senderGUID over bnSenderID when both present", function()
            local msg = "Check out this quest: |cffffff00|Hquest:74:28|h[The Legend of Stalvan]|h|r"
            local chatFrame = {historyBuffer = {elements = {1}}}

            local _, filteredMsg = ChatFilter.Filter(chatFrame, nil, msg, "Player", "Common", "CHANNEL", nil, nil, nil, nil, nil, nil, nil, nil,
                "PLAYER_GUID_456", "BN_SENDER_123")

            assert.is_not_nil(filteredMsg)
            assert.is_equal("Check out this quest: |Hquestie:74:PLAYER_GUID_456|h[The Legend of Stalvan]|h", filteredMsg)
        end)
    end)
end)
