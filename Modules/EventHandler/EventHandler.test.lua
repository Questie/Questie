dofile("setupTests.lua")

describe("EventHandler event dispatch", function()
    local savedGlobals
    local savedQuestieFields
    local originalQuestAccepted
    local originalExpansion
    local callbacks
    local bucketEvents
    local bucketMessages
    local sentMessages
    local QuestEventHandler
    local Expansions
    local QuestieProfessions
    local AvailableQuests
    local savedSkillCallbacks

    before_each(function()
        savedGlobals = {
            ERR_QUEST_ACCEPTED_S = _G.ERR_QUEST_ACCEPTED_S,
            ERR_QUEST_COMPLETE_S = _G.ERR_QUEST_COMPLETE_S,
            GetQuestLogIndexByID = _G.GetQuestLogIndexByID,
            GetSkillLineInfo = _G.GetSkillLineInfo,
        }
        savedQuestieFields = {
            IsForever = Questie.IsForever,
            RegisterEvent = Questie.RegisterEvent,
            RegisterBucketEvent = Questie.RegisterBucketEvent,
            RegisterBucketMessage = Questie.RegisterBucketMessage,
            SendMessage = Questie.SendMessage,
        }
        _G.ERR_QUEST_ACCEPTED_S = "Quest accepted: %s"
        _G.ERR_QUEST_COMPLETE_S = "Quest completed: %s"
        _G.GetQuestLogIndexByID = spy.new(function() return 2 end)
        _G.GetSkillLineInfo = function() end
        Questie.IsForever = false
        callbacks = {}
        bucketEvents = {}
        bucketMessages = {}
        sentMessages = {}
        Questie.RegisterEvent = function(_, event, callback) callbacks[event] = callback end
        Questie.RegisterBucketEvent = function(_, event, interval, callback)
            bucketEvents[event] = {interval = interval, callback = callback}
        end
        Questie.RegisterBucketMessage = function(_, message, interval, callback)
            bucketMessages[message] = {interval = interval, callback = callback}
        end
        Questie.SendMessage = function(_, message, ...)
            table.insert(sentMessages, {message = message, argumentCount = select("#", ...)})
        end

        QuestEventHandler = QuestieLoader:ImportModule("QuestEventHandler")
        originalQuestAccepted = QuestEventHandler.QuestAccepted
        QuestEventHandler.QuestAccepted = spy.new(function() end)
        Expansions = QuestieLoader:ImportModule("Expansions")
        originalExpansion = Expansions.Current
        Expansions.Current = Expansions.Era
        QuestieProfessions = QuestieLoader:ImportModule("QuestieProfessions")
        AvailableQuests = QuestieLoader:ImportModule("AvailableQuests")
        savedSkillCallbacks = {
            Update = QuestieProfessions.Update,
            CalculateAndDrawAll = AvailableQuests.CalculateAndDrawAll,
        }
        QuestieProfessions.Update = spy.new(function() return false, false end)
        AvailableQuests.CalculateAndDrawAll = spy.new(function() end)

        dofile("Modules/EventHandler/EventHandler.lua")
        QuestieLoader:ImportModule("EventHandler"):RegisterLateEvents()
    end)

    after_each(function()
        _G.ERR_QUEST_ACCEPTED_S = savedGlobals.ERR_QUEST_ACCEPTED_S
        _G.ERR_QUEST_COMPLETE_S = savedGlobals.ERR_QUEST_COMPLETE_S
        _G.GetQuestLogIndexByID = savedGlobals.GetQuestLogIndexByID
        _G.GetSkillLineInfo = savedGlobals.GetSkillLineInfo
        Questie.IsForever = savedQuestieFields.IsForever
        Questie.RegisterEvent = savedQuestieFields.RegisterEvent
        Questie.RegisterBucketEvent = savedQuestieFields.RegisterBucketEvent
        Questie.RegisterBucketMessage = savedQuestieFields.RegisterBucketMessage
        Questie.SendMessage = savedQuestieFields.SendMessage
        QuestEventHandler.QuestAccepted = originalQuestAccepted
        Expansions.Current = originalExpansion
        QuestieProfessions.Update = savedSkillCallbacks.Update
        AvailableQuests.CalculateAndDrawAll = savedSkillCallbacks.CalculateAndDrawAll
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

    it("buckets skill notifications for two seconds without bucketing native chat arguments", function()
        assert.is_nil(bucketEvents.CHAT_MSG_SKILL)
        assert.is_function(callbacks.CHAT_MSG_SKILL)
        assert.is_table(bucketMessages.QUESTIE_SKILL_UPDATE)
        assert.are.equal(2, bucketMessages.QUESTIE_SKILL_UPDATE.interval)
    end)

    it("omits ordinary and opaque skill chat arguments from the internal message", function()
        -- An opaque marker checks argument omission; offline Lua cannot create a native secret value.
        local opaqueMessage = {}
        assert.is_function(callbacks.CHAT_MSG_SKILL)

        callbacks.CHAT_MSG_SKILL("CHAT_MSG_SKILL", "Your skill in Cooking has increased to 75.", "extra argument")
        callbacks.CHAT_MSG_SKILL("CHAT_MSG_SKILL", opaqueMessage, nil, opaqueMessage)

        assert.are.same({
            {message = "QUESTIE_SKILL_UPDATE", argumentCount = 0},
            {message = "QUESTIE_SKILL_UPDATE", argumentCount = 0},
        }, sentMessages)
        assert.spy(QuestieProfessions.Update).was.not_called()
        assert.spy(AvailableQuests.CalculateAndDrawAll).was.not_called()
    end)

    it("rereads profession state without redrawing unchanged available quests", function()
        assert.is_table(bucketMessages.QUESTIE_SKILL_UPDATE)

        bucketMessages.QUESTIE_SKILL_UPDATE.callback()

        assert.spy(QuestieProfessions.Update).was.called_with(QuestieProfessions)
        assert.spy(AvailableQuests.CalculateAndDrawAll).was.not_called()
    end)

    it("redraws available quests for changed skills and newly learned professions", function()
        assert.is_table(bucketMessages.QUESTIE_SKILL_UPDATE)

        QuestieProfessions.Update = function() return true, false end
        bucketMessages.QUESTIE_SKILL_UPDATE.callback()
        QuestieProfessions.Update = function() return false, true end
        bucketMessages.QUESTIE_SKILL_UPDATE.callback()

        assert.spy(AvailableQuests.CalculateAndDrawAll).was.called(2)
    end)

    it("retains the two-second modern skill-change bucket only when the legacy skill API is absent", function()
        assert.is_nil(bucketEvents.SKILL_LINES_CHANGED)
        _G.GetSkillLineInfo = nil

        QuestieLoader:ImportModule("EventHandler"):RegisterLateEvents()

        assert.is_table(bucketMessages.QUESTIE_SKILL_UPDATE)
        assert.are.equal(2, bucketEvents.SKILL_LINES_CHANGED.interval)
        assert.are.equal(bucketMessages.QUESTIE_SKILL_UPDATE.callback, bucketEvents.SKILL_LINES_CHANGED.callback)
    end)
end)
