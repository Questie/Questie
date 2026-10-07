dofile("setupTests.lua")

describe("EventHandler event dispatch", function()
    local savedGlobals
    local savedQuestieFields
    local originalQuestAccepted
    local originalExpansion
    local callbacks
    local bucketEvents
    local scheduledTimers
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
            ScheduleTimer = Questie.ScheduleTimer,
        }
        _G.ERR_QUEST_ACCEPTED_S = "Quest accepted: %s"
        _G.ERR_QUEST_COMPLETE_S = "Quest completed: %s"
        _G.GetQuestLogIndexByID = spy.new(function() return 2 end)
        _G.GetSkillLineInfo = function() end
        Questie.IsForever = false
        callbacks = {}
        bucketEvents = {}
        scheduledTimers = {}
        Questie.RegisterEvent = function(_, event, callback) callbacks[event] = callback end
        Questie.RegisterBucketEvent = function(_, event, interval, callback)
            bucketEvents[event] = {interval = interval, callback = callback}
        end
        Questie.RegisterBucketMessage = spy.new(function() end)
        Questie.SendMessage = spy.new(function() end)
        Questie.ScheduleTimer = function(_, callback, delay, ...)
            local timer = {callback = callback, delay = delay, argumentCount = select("#", ...)}
            table.insert(scheduledTimers, timer)
            return timer
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
        Questie.ScheduleTimer = savedQuestieFields.ScheduleTimer
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

    it("registers skill chat directly without a bucket or message relay", function()
        assert.is_nil(bucketEvents.CHAT_MSG_SKILL)
        assert.is_function(callbacks.CHAT_MSG_SKILL)
        assert.spy(Questie.RegisterBucketMessage).was.not_called()
        assert.spy(Questie.SendMessage).was.not_called()
        assert.are.equal(0, #scheduledTimers)
    end)

    it("batches ordinary and opaque skill chat in one fixed two-second window without forwarding arguments", function()
        -- This ordinary marker cannot reproduce native secret semantics.
        local opaqueMessage = setmetatable({}, {
            __index = function() error("Skill chat must not be read") end,
            __tostring = function() error("Skill chat must not be formatted") end,
        })

        callbacks.CHAT_MSG_SKILL("CHAT_MSG_SKILL", "Your skill in Cooking has increased to 75.", "extra argument")
        callbacks.CHAT_MSG_SKILL("CHAT_MSG_SKILL", opaqueMessage, nil, opaqueMessage)

        assert.are.equal(1, #scheduledTimers)
        assert.are.equal(2, scheduledTimers[1].delay)
        assert.are.equal(0, scheduledTimers[1].argumentCount)
        assert.spy(Questie.SendMessage).was.not_called()
        assert.spy(QuestieProfessions.Update).was.not_called()
        assert.spy(AvailableQuests.CalculateAndDrawAll).was.not_called()

        scheduledTimers[1].callback()

        assert.spy(QuestieProfessions.Update).was.called(1)
    end)

    it("rereads profession state without redrawing unchanged available quests", function()
        callbacks.CHAT_MSG_SKILL("CHAT_MSG_SKILL")
        scheduledTimers[1].callback()

        assert.spy(QuestieProfessions.Update).was.called_with(QuestieProfessions)
        assert.spy(AvailableQuests.CalculateAndDrawAll).was.not_called()
    end)

    it("redraws available quests for changed skills and newly learned professions", function()
        callbacks.CHAT_MSG_SKILL("CHAT_MSG_SKILL")
        QuestieProfessions.Update = function() return true, false end
        scheduledTimers[1].callback()

        callbacks.CHAT_MSG_SKILL("CHAT_MSG_SKILL")
        assert.are.equal(2, #scheduledTimers)
        assert.are.equal(2, scheduledTimers[2].delay)
        QuestieProfessions.Update = function() return false, true end
        scheduledTimers[2].callback()

        assert.spy(AvailableQuests.CalculateAndDrawAll).was.called(2)
    end)

    it("retains the two-second modern skill-change bucket only when the legacy skill API is absent", function()
        assert.is_nil(bucketEvents.SKILL_LINES_CHANGED)
        _G.GetSkillLineInfo = nil

        QuestieLoader:ImportModule("EventHandler"):RegisterLateEvents()

        assert.are.equal(2, bucketEvents.SKILL_LINES_CHANGED.interval)
        bucketEvents.SKILL_LINES_CHANGED.callback()

        assert.spy(QuestieProfessions.Update).was.called_with(QuestieProfessions)
        assert.spy(AvailableQuests.CalculateAndDrawAll).was.not_called()
    end)

    it("re-checks unknown quest conditions when combat ends", function()
        QuestieLoader:ImportModule("QuestieTracker").HandleCombatEnded = function() end
        local QuestieConditions = QuestieLoader:ImportModule("QuestieConditions")
        QuestieConditions.RecheckNow = spy.new(function() end)

        callbacks.PLAYER_REGEN_ENABLED()

        assert.spy(QuestieConditions.RecheckNow).was.called(1)
    end)
end)
