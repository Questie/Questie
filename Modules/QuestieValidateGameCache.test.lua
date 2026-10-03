dofile("setupTests.lua")

describe("QuestieValidateGameCache", function()
    local Validator, compat, objectives, onEvent
    local originalCreateFrame, originalHaveQuestData, originalQuestLog
    local originalGetTitle, originalGetNumEntries, originalError

    before_each(function()
        compat = QuestieLoader:ImportModule("QuestieCompat")
        originalGetTitle, originalGetNumEntries = compat.GetQuestLogTitle, compat.GetNumQuestLogEntries
        originalCreateFrame, originalHaveQuestData, originalQuestLog = _G.CreateFrame, _G.HaveQuestData, _G.C_QuestLog
        originalError = Questie.Error
        Questie.Error = spy.new(function() end)
        objectives = {}
        onEvent = nil
        compat.GetQuestLogTitle = function(index)
            if index == 1 then
                return "Agitators", 3, nil, false, false, nil, nil, 92409
            end
        end
        compat.GetNumQuestLogEntries = function() return 1, 1 end
        _G.HaveQuestData = function() return true end
        _G.C_QuestLog = {GetQuestObjectives = function() return objectives end}
        _G.CreateFrame = function()
            return {
                SetScript = function(_, _, callback) onEvent = callback end,
                RegisterEvent = function() end,
                UnregisterAllEvents = function() end,
                SetParent = function() end,
            }
        end
        dofile("Modules/Libs/QuestieLib.lua")
        dofile("Modules/QuestieValidateGameCache.lua")
        Validator = QuestieLoader:ImportModule("QuestieValidateGameCache")
    end)

    after_each(function()
        Questie.Error = originalError
        compat.GetQuestLogTitle, compat.GetNumQuestLogEntries = originalGetTitle, originalGetNumEntries
        _G.CreateFrame, _G.HaveQuestData, _G.C_QuestLog = originalCreateFrame, originalHaveQuestData, originalQuestLog
    end)

    it("waits for a missing objective type even when the wording has loaded", function()
        objectives = {{text = "Read the book."}}
        Validator.StartCheck()
        onEvent(nil, "PLAYER_ENTERING_WORLD", false, true)
        onEvent(nil, "QUEST_LOG_UPDATE")
        assert.is_false(Validator.IsCacheGood())

        objectives[1].type = "log"
        onEvent(nil, "QUEST_LOG_UPDATE")
        assert.is_true(Validator.IsCacheGood())
    end)

    it("waits for an unavailable objective array rather than announcing readiness", function()
        objectives = nil
        Validator.StartCheck()
        onEvent(nil, "PLAYER_ENTERING_WORLD", false, true)
        onEvent(nil, "QUEST_LOG_UPDATE")
        assert.is_false(Validator.IsCacheGood())

        objectives = {}
        onEvent(nil, "QUEST_LOG_UPDATE")
        assert.is_true(Validator.IsCacheGood())
    end)

    it("does not let permanently empty rows block startup even without types", function()
        objectives = {{text = ""}, {text = "Read the book.", type = "log"}}
        Validator.StartCheck()
        onEvent(nil, "PLAYER_ENTERING_WORLD", false, true)
        onEvent(nil, "QUEST_LOG_UPDATE")

        assert.is_true(Validator.IsCacheGood())
    end)

    local cases = {
        {name = "unknown English suffix", missing = "0/6   destroyed", loaded = "4/6 Roiling Winds destroyed"},
        {name = "unknown UTF-8 suffix", missing = "0/6   已摧毁", loaded = "4/6 烈风已摧毁"},
        {name = "trailing-space placeholder", missing = "0/6  ", loaded = "4/6 Roiling Winds destroyed"},
        {name = "leading-space placeholder", missing = "  slain: 0/6", loaded = "Roiling Winds slain: 4/6"},
    }
    for _, case in ipairs(cases) do
        it("delays startup callbacks for " .. case.name .. " until the name loads", function()
            objectives = {{text = case.missing, type = "monster"}}
            local callback = spy.new(function() end)
            Validator.AddCallback(callback, 92409)
            Validator.StartCheck()
            onEvent(nil, "PLAYER_ENTERING_WORLD", false, true)

            onEvent(nil, "QUEST_LOG_UPDATE")

            assert.is_false(Validator.IsCacheGood())
            assert.spy(callback).was.not_called()

            objectives[1].text = case.loaded
            onEvent(nil, "QUEST_LOG_UPDATE")

            assert.is_true(Validator.IsCacheGood())
            assert.spy(callback).was.called(1)
            assert.spy(callback).was.called_with(92409)
            assert.are.equal(case.loaded, objectives[1].text)
        end)
    end
end)
