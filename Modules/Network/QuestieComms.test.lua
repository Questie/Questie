dofile("setupTests.lua")

describe("QuestieComms", function()
    ---@type QuestieComms
    local QuestieComms
    ---@type QuestieDB
    local QuestieDB
    ---@type QuestLogCache
    local QuestLogCache
    ---@type QuestiePartyObjectives
    local QuestiePartyObjectives

    -- A killcredit/event objective has no ObjectiveData.Id, so questObject.Objectives[i].Id is nil.
    -- The quest with the nil id is sent first; a second quest follows it in the same V2 block.
    local KILLCREDIT_QUEST = 11051
    local FOLLOWING_QUEST = 11066

    before_each(function()
        Questie.RegisterComm = function() end
        Questie.RegisterMessage = function() end
        Questie.RegisterBucketMessage = function() end

        QuestieDB = QuestieLoader:ImportModule("QuestieDB")
        QuestieDB.GetQuest = function(questId)
            if questId == KILLCREDIT_QUEST then
                return { Objectives = { [1] = {} } } -- killcredit: no Id
            else
                return { Objectives = { [1] = { Id = 22181 } } }
            end
        end

        QuestLogCache = QuestieLoader:ImportModule("QuestLogCache")
        QuestLogCache.GetQuestObjectives = function(questId)
            local required = questId == KILLCREDIT_QUEST and 15 or 5
            return { [1] = { type = "monster", finished = false, numFulfilled = 0, numRequired = required } }
        end

        QuestiePartyObjectives = QuestieLoader:ImportModule("QuestiePartyObjectives")
        QuestiePartyObjectives.ScheduleUpdate = function() end

        QuestieComms = require("Modules.Network.QuestieComms")
        QuestieComms.remoteQuestLogs = {}
        QuestieComms.data = { RegisterTooltip = function() end }
    end)

    describe("V2 full quest list round trip", function()
        it("should not drop a quest packed after one with a nil objective id", function()
            -- Build one block holding both quests, exactly as BroadcastQuestLogV2 does.
            local block = {}
            local offset = 2
            offset = QuestieComms:PopulateQuestDataPacketV2_noclass_renameme(KILLCREDIT_QUEST, block, offset)
            offset = QuestieComms:PopulateQuestDataPacketV2_noclass_renameme(FOLLOWING_QUEST, block, offset)
            block[1] = 2 -- entry count

            -- Receive the block, mirroring the QC_ID_BROADCAST_FULL_QUESTLISTV2 read handler.
            local readOffset = 2
            for _ = 1, block[1] do
                readOffset = QuestieComms:InsertQuestDataPacketV2_noclass_RenameMe(block, "Bob", readOffset, false)
            end

            assert.is_not_nil(QuestieComms.remoteQuestLogs[KILLCREDIT_QUEST] and QuestieComms.remoteQuestLogs[KILLCREDIT_QUEST]["Bob"])
            assert.is_not_nil(QuestieComms.remoteQuestLogs[FOLLOWING_QUEST] and QuestieComms.remoteQuestLogs[FOLLOWING_QUEST]["Bob"])
            -- The killcredit quest's objective is kept, with a 0 placeholder id (not nil).
            assert.equals(0, QuestieComms.remoteQuestLogs[KILLCREDIT_QUEST]["Bob"][1].id)
        end)
    end)
end)
