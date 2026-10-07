dofile("setupTests.lua")

local LoadQuestieDBMock = dofile("test/QuestieDBMock.lua")

describe("QuestieConditions", function()
    ---@type QuestieDBMock
    local mock
    ---@type QuestieConditions
    local QuestieConditions

    local timers, recalculations, originalTimer

    before_each(function()
        mock = LoadQuestieDBMock()
        timers = {}
        originalTimer = _G.C_Timer
        _G.C_Timer = {After = function(delay, callback) table.insert(timers, {delay = delay, callback = callback}) end}
        local AvailableQuests = QuestieLoader:ImportModule("AvailableQuests")
        recalculations = 0
        AvailableQuests.CalculateAndDrawAll = function() recalculations = recalculations + 1 end
        QuestieConditions = dofile("Modules/Quest/Conditions/QuestieConditions.lua")
    end)

    after_each(function()
        _G.C_Timer = originalTimer
    end)

    ---Run the next scheduled re-check, as the client timer would.
    local function fireTimer()
        table.remove(timers, 1).callback()
    end

    describe("IsFulfilled", function()
        it("keeps the last determinate answer while the condition is unknown", function()
            local result = false
            mock.lib.Conditions.EvaluateQuest = function() return result end
            assert.is_false(QuestieConditions.IsFulfilled(5))
            assert.are_same({}, timers)

            result = nil
            assert.is_false(QuestieConditions.IsFulfilled(5))
            assert.are_equal(1, #timers)
        end)

        it("allows a quest whose condition has never been readable", function()
            mock.lib.Conditions.EvaluateQuest = function() return nil end

            assert.is_true(QuestieConditions.IsFulfilled(6))
        end)
    end)

    describe("re-checking unknown conditions", function()
        local results

        before_each(function()
            results = {}
            mock.lib.Conditions.EvaluateQuest = function(questId) return results[questId] end
        end)

        it("keeps re-checking while the condition stays unknown, then stops once it resolves", function()
            QuestieConditions.IsFulfilled(5)
            QuestieConditions.IsFulfilled(6)
            assert.are_equal(1, #timers, "unknown quests share one scheduled re-check")

            fireTimer()
            assert.are_equal(1, #timers, "an unresolved quest is checked again")

            results[5], results[6] = true, true
            fireTimer()
            assert.are_same({}, timers)
            assert.are_equal(0, recalculations, "unchanged answers do not redraw")
        end)

        it("recalculates available quests once when resolved answers differ from those shown", function()
            QuestieConditions.IsFulfilled(5)
            QuestieConditions.IsFulfilled(6)

            results[5], results[6] = false, false
            QuestieConditions.RecheckNow()

            assert.are_equal(1, recalculations)
            results[5] = nil
            assert.is_false(QuestieConditions.IsFulfilled(5), "the re-check remembered the resolved answer")
        end)

        it("redraws when another query resolves a pending quest to a different answer", function()
            assert.is_true(QuestieConditions.IsFulfilled(5), "an unreadable quest is shown")
            QuestieConditions.IsFulfilled(6)

            results[5], results[6] = false, true
            assert.is_false(QuestieConditions.IsFulfilled(5), "a Journey query resolves it first")
            assert.is_true(QuestieConditions.IsFulfilled(6))
            fireTimer()

            assert.are_equal(1, recalculations)
            assert.are_same({}, timers)
        end)

        it("does not redraw when another query resolves a pending quest to the answer shown", function()
            QuestieConditions.IsFulfilled(5)

            results[5] = true
            QuestieConditions.IsFulfilled(5)
            fireTimer()

            assert.are_equal(0, recalculations)
        end)

        it("counts a pending quest resolved by another quest's re-check", function()
            QuestieConditions.IsFulfilled(5)
            QuestieConditions.IsFulfilled(6)
            mock.lib.Conditions.EvaluateQuest = function(questId)
                -- Quest 5's condition asks about quest 6 through QuestAvailable.
                if questId == 5 then QuestieConditions.IsFulfilled(6) return true end
                return false
            end

            fireTimer()

            assert.are_equal(1, recalculations)
            assert.are_same({}, timers)
        end)

        it("re-checks every second at first, then slows down during a long secret state", function()
            QuestieConditions.IsFulfilled(5)
            assert.are_equal(1, timers[1].delay)
            for _ = 1, 29 do fireTimer() end
            assert.are_equal(1, timers[1].delay, "the 30th re-check is still fast")

            fireTimer()
            assert.are_equal(5, timers[1].delay)
        end)

        it("starts fast again for the next secret state after one resolves", function()
            QuestieConditions.IsFulfilled(5)
            for _ = 1, 30 do fireTimer() end
            results[5] = true
            fireTimer()
            assert.are_same({}, timers)

            results[5] = nil
            QuestieConditions.IsFulfilled(5)
            assert.are_equal(1, timers[1].delay)
        end)

        it("does nothing when no condition is unknown", function()
            QuestieConditions.RecheckNow()

            assert.are_same({}, timers)
            assert.are_equal(0, recalculations)
        end)
    end)

    describe("Initialize", function()
        local QuestieDB, QuestiePlayer

        before_each(function()
            QuestieDB = QuestieLoader:ImportModule("QuestieDB")
            QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
            QuestiePlayer.currentQuestlog = {}
            QuestiePlayer.GetPlayerLevel = function() return 30 end
            QuestieConditions.Initialize()
        end)

        describe("QuestAvailable", function()
            local levels, doableCalls

            before_each(function()
                levels = {}
                doableCalls = {}
                QuestieDB.QueryQuestSingle = function(questId, key) return (levels[questId] or {})[key] end
                QuestieDB.IsDoable = function(questId, debugPrint, ignoreManualHide)
                    table.insert(doableCalls, {questId, debugPrint, ignoreManualHide})
                    return true
                end
            end)

            it("asks IsDoable while ignoring the player's manually hidden quests", function()
                assert.is_true(mock.conditionFunctions.Questie.QuestAvailable(1))
                assert.are_same({{1, false, true}}, doableCalls)
            end)

            it("passes the quest's own unknown or false condition through without a kept answer", function()
                local results = {[1] = nil, [2] = false}
                mock.lib.Conditions.EvaluateQuest = function(questId) return results[questId] end

                assert.is_nil(mock.conditionFunctions.Questie.QuestAvailable(1))
                assert.is_false(mock.conditionFunctions.Questie.QuestAvailable(2))
                assert.are_same({}, doableCalls)
            end)

            it("rejects a quest already in the log", function()
                QuestiePlayer.currentQuestlog[1] = {}

                assert.is_false(mock.conditionFunctions.Questie.QuestAvailable(1))
            end)

            it("applies the quest's own level limits", function()
                levels[1] = {requiredLevel = 31}
                levels[2] = {requiredLevel = 20, requiredMaxLevel = 29}
                levels[3] = {requiredLevel = 30, requiredMaxLevel = 30}

                assert.is_false(mock.conditionFunctions.Questie.QuestAvailable(1))
                assert.is_false(mock.conditionFunctions.Questie.QuestAvailable(2))
                assert.is_true(mock.conditionFunctions.Questie.QuestAvailable(3))
            end)
        end)

        it("counts QuestComplete only for a quest in the log with its objectives complete", function()
            local completion = {[1] = 1, [2] = 0, [3] = -1}
            QuestieDB.IsComplete = function(questId) return completion[questId] end
            QuestiePlayer.currentQuestlog = {[1] = {}, [2] = {}, [3] = {}}

            assert.is_true(mock.conditionFunctions.Questie.QuestComplete(1))
            assert.is_false(mock.conditionFunctions.Questie.QuestComplete(2))
            assert.is_false(mock.conditionFunctions.Questie.QuestComplete(3), "a failed quest is not complete")
            completion[4] = 1
            assert.is_false(mock.conditionFunctions.Questie.QuestComplete(4), "a quest outside the log is not complete")
        end)

        it("maps HasSkill to Questie's profession IDs with a default level of 1", function()
            local requested
            QuestieLoader:ImportModule("QuestieProfessions").HasProfessionAndSkillLevel = function(_, requiredSkill)
                requested = requiredSkill
                return true, requiredSkill[2] <= 150
            end

            assert.is_true(mock.conditionFunctions.Questie.HasSkill(129))
            assert.are_same({129, 1}, requested)
            assert.is_false(mock.conditionFunctions.Questie.HasSkill(129, 225))
        end)
    end)
end)
