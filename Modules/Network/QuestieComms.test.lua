dofile("setupTests.lua")

describe("QuestieComms", function()
    ---@type QuestieComms
    local QuestieComms

    ---@type CommsHello
    local CommsHello

    before_each(function()
        Questie.RegisterComm = spy.new(function() end)
        Questie.RegisterMessage = spy.new(function() end)
        Questie.RegisterBucketMessage = spy.new(function() end)

        dofile("Modules/Network/CommsHello.lua")
        CommsHello = QuestieLoader:ImportModule("CommsHello")
        CommsHello.RegisterLocalPrefix = spy.new(function() return true end)

        dofile("Modules/Network/QuestieComms.lua")
        QuestieComms = QuestieLoader:ImportModule("QuestieComms")
    end)

    describe("Initialize", function()
        it("marks the legacy quest sharing and reputable prefixes active after registering their receivers", function()
            QuestieComms:Initialize()

            assert.spy(Questie.RegisterComm).was.called_with(Questie, "questie", QuestieComms.private.OnCommReceived)
            assert.spy(Questie.RegisterComm).was.called_with(Questie, "REPUTABLE", QuestieLoader:ImportModule("DailyQuests").FilterDailies)
            assert.spy(CommsHello.RegisterLocalPrefix).was.called_with(CommsHello, "questie")
            assert.spy(CommsHello.RegisterLocalPrefix).was.called_with(CommsHello, "REPUTABLE")
        end)
    end)
end)
