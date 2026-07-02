dofile("setupTests.lua")

describe("QuestieComms", function()
    ---@type QuestieComms
    local QuestieComms

    ---@type CommsPrefixRegistry
    local CommsPrefixRegistry

    ---@type CommsVisibility
    local CommsVisibility

    before_each(function()
        Questie.RegisterComm = spy.new(function() end)
        Questie.RegisterMessage = spy.new(function() end)
        Questie.RegisterBucketMessage = spy.new(function() end)

        dofile("Modules/Network/CommsPrefixRegistry.lua")
        CommsPrefixRegistry = QuestieLoader:ImportModule("CommsPrefixRegistry")
        CommsPrefixRegistry.RegisterLocalPrefix = spy.new(function() return true end)

        CommsVisibility = QuestieLoader:ImportModule("CommsVisibility")
        CommsVisibility.ScheduleSnapshot = spy.new(function() end)

        dofile("Modules/Network/QuestieComms.lua")
        QuestieComms = QuestieLoader:ImportModule("QuestieComms")
    end)

    describe("Initialize", function()
        it("marks the legacy quest sharing and reputable prefixes active after registering their receivers", function()
            QuestieComms:Initialize()

            assert.spy(Questie.RegisterComm).was.called_with(Questie, "questie", QuestieComms.private.OnCommReceived)
            assert.spy(Questie.RegisterComm).was.called_with(Questie, "REPUTABLE", QuestieLoader:ImportModule("DailyQuests").FilterDailies)
            assert.spy(CommsPrefixRegistry.RegisterLocalPrefix).was.called_with(CommsPrefixRegistry, "questie")
            assert.spy(CommsPrefixRegistry.RegisterLocalPrefix).was.called_with(CommsPrefixRegistry, "REPUTABLE")
        end)
    end)

    describe("full quest-list requests", function()
        it("schedules a visibility snapshot when responding to another player's full quest-list request", function()
            _G.UnitName = function() return "Player" end
            _G.strsplit = function(_, value) return value:match("^(%d+)%.(%d+)%.(%d+)$") end
            QuestieComms.private.BroadcastQuestLogV2 = spy.new(function() end)

            QuestieComms.private.packets[11].read({
                playerName = "Friend-Realm",
                ver = "6.0.0",
            })

            assert.spy(QuestieComms.private.BroadcastQuestLogV2).was.called_with(QuestieComms.private, "QC_ID_BROADCAST_FULL_QUESTLIST", "WHISPER", "Friend-Realm")
            assert.spy(CommsVisibility.ScheduleSnapshot).was.called_with(CommsVisibility, "QC_ID_REQUEST_FULL_QUESTLIST")
        end)

        it("does not schedule a visibility snapshot for our own full quest-list request echo", function()
            _G.UnitName = function() return "Player" end

            QuestieComms.private.packets[11].read({
                playerName = "Player",
                ver = "6.0.0",
            })

            assert.spy(CommsVisibility.ScheduleSnapshot).was.not_called()
        end)
    end)
end)
