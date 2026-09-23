dofile("setupTests.lua")

describe("EventHandler quest acceptance dispatch", function()
    local savedGlobals
    local savedQuestieFields
    local originalQuestAccepted
    local originalExpansion
    local callbacks
    local QuestEventHandler
    local Expansions

    before_each(function()
        savedGlobals = {
            ERR_QUEST_ACCEPTED_S = _G.ERR_QUEST_ACCEPTED_S,
            ERR_QUEST_COMPLETE_S = _G.ERR_QUEST_COMPLETE_S,
            GetQuestLogIndexByID = _G.GetQuestLogIndexByID,
        }
        savedQuestieFields = {
            IsForever = Questie.IsForever,
            RegisterEvent = Questie.RegisterEvent,
            RegisterBucketEvent = Questie.RegisterBucketEvent,
        }
        _G.ERR_QUEST_ACCEPTED_S = "Quest accepted: %s"
        _G.ERR_QUEST_COMPLETE_S = "Quest completed: %s"
        _G.GetQuestLogIndexByID = spy.new(function() return 2 end)
        Questie.IsForever = false
        callbacks = {}
        Questie.RegisterEvent = function(_, event, callback) callbacks[event] = callback end
        Questie.RegisterBucketEvent = function() end

        QuestEventHandler = QuestieLoader:ImportModule("QuestEventHandler")
        originalQuestAccepted = QuestEventHandler.QuestAccepted
        QuestEventHandler.QuestAccepted = spy.new(function() end)
        Expansions = QuestieLoader:ImportModule("Expansions")
        originalExpansion = Expansions.Current
        Expansions.Current = Expansions.Era

        dofile("Modules/EventHandler/EventHandler.lua")
        QuestieLoader:ImportModule("EventHandler"):RegisterLateEvents()
    end)

    after_each(function()
        _G.ERR_QUEST_ACCEPTED_S = savedGlobals.ERR_QUEST_ACCEPTED_S
        _G.ERR_QUEST_COMPLETE_S = savedGlobals.ERR_QUEST_COMPLETE_S
        _G.GetQuestLogIndexByID = savedGlobals.GetQuestLogIndexByID
        Questie.IsForever = savedQuestieFields.IsForever
        Questie.RegisterEvent = savedQuestieFields.RegisterEvent
        Questie.RegisterBucketEvent = savedQuestieFields.RegisterBucketEvent
        QuestEventHandler.QuestAccepted = originalQuestAccepted
        Expansions.Current = originalExpansion
    end)

    it("preserves Classic's explicit log index and quest ID", function()
        callbacks.QUEST_ACCEPTED("QUEST_ACCEPTED", 7, 783)

        assert.spy(QuestEventHandler.QuestAccepted).was.called_with(7, 783)
        assert.spy(GetQuestLogIndexByID).was.not_called()
    end)

    it("resolves Forever's single quest ID without treating it as a log index", function()
        Questie.IsForever = true

        callbacks.QUEST_ACCEPTED("QUEST_ACCEPTED", 783)

        assert.spy(GetQuestLogIndexByID).was.called_with(783)
        assert.spy(QuestEventHandler.QuestAccepted).was.called_with(2, 783)
    end)
end)
