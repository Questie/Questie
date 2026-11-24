dofile("setupTests.lua")

-- The game completes all versions of this quest with any of them
local CALL_OF_EARTH, CALL_OF_EARTH_TAUREN, CALL_OF_EARTH_TROLL = 1517, 1520, 1519

describe("CompletedQuests", function()
    ---@type CompletedQuests
    local CompletedQuests
    ---@type ActiveQuests
    local ActiveQuests
    ---@type AvailableQuests
    local AvailableQuests
    ---@type table<QuestId, boolean> The game's list
    local completedByTheGame
    ---@type table<QuestId, boolean> The game's quest log
    local questLog
    local removedFromMap
    local originalQuestie, originalGetQuestsCompleted, originalTimer, originalQuestLog

    before_each(function()
        originalQuestie, originalGetQuestsCompleted = _G.Questie, _G.GetQuestsCompleted
        originalTimer, originalQuestLog = _G.C_Timer, _G.C_QuestLog
        _G.Questie = {db = {char = {complete = {}}}}
        completedByTheGame, questLog, removedFromMap = {}, {}, {}
        _G.GetQuestsCompleted = function() return completedByTheGame end
        _G.C_QuestLog = {IsOnQuest = function(questId) return questLog[questId] == true end}

        dofile("Modules/Quest/ActiveQuests.lua")
        ActiveQuests = QuestieLoader:ImportModule("ActiveQuests")
        AvailableQuests = QuestieLoader:ImportModule("AvailableQuests")
        AvailableQuests.CalculateAndDrawAll = spy.new(function() end)
        AvailableQuests.RemoveQuest = function(questId) removedFromMap[questId] = true end

        dofile("Modules/Quest/CompletedQuests.lua")
        CompletedQuests = QuestieLoader:ImportModule("CompletedQuests")
    end)

    after_each(function()
        _G.Questie, _G.GetQuestsCompleted = originalQuestie, originalGetQuestsCompleted
        _G.C_Timer, _G.C_QuestLog = originalTimer, originalQuestLog
    end)

    describe("Update", function()
        it("should add every quest the game completed, and remove it from the map", function()
            Questie.db.char.complete[CALL_OF_EARTH] = true
            completedByTheGame = {[CALL_OF_EARTH] = true, [CALL_OF_EARTH_TAUREN] = true, [CALL_OF_EARTH_TROLL] = true}

            CompletedQuests.Update()

            assert.are_same({[CALL_OF_EARTH] = true, [CALL_OF_EARTH_TAUREN] = true, [CALL_OF_EARTH_TROLL] = true}, Questie.db.char.complete)
            assert.spy(AvailableQuests.CalculateAndDrawAll).was.called(1)
            -- Not the others, e.g. a daily quest that its giver offers again
            assert.are_same({[CALL_OF_EARTH_TAUREN] = true, [CALL_OF_EARTH_TROLL] = true}, removedFromMap)
        end)

        it("should do nothing when Questie knows all completed quests", function()
            Questie.db.char.complete[CALL_OF_EARTH] = true
            completedByTheGame = {[CALL_OF_EARTH] = true}

            CompletedQuests.Update()

            assert.spy(AvailableQuests.CalculateAndDrawAll).was.not_called()
        end)

        it("should keep the known quests when the game's list is empty", function()
            Questie.db.char.complete[CALL_OF_EARTH] = true

            CompletedQuests.Update()

            assert.are_same({[CALL_OF_EARTH] = true}, Questie.db.char.complete)
        end)

        it("should leave out quests in the game's log that Questie doesn't have, because they are loading or unknown", function()
            questLog[CALL_OF_EARTH] = true
            completedByTheGame = {[CALL_OF_EARTH] = true, [CALL_OF_EARTH_TAUREN] = true}

            CompletedQuests.Update()

            assert.are_same({[CALL_OF_EARTH_TAUREN] = true}, Questie.db.char.complete)
        end)

        it("should leave out quests that left the game's log, until Questie knows whether they were turned in", function()
            ActiveQuests.Add(CALL_OF_EARTH, {})
            completedByTheGame = {[CALL_OF_EARTH] = true, [CALL_OF_EARTH_TAUREN] = true}

            CompletedQuests.Update()

            assert.are_same({[CALL_OF_EARTH_TAUREN] = true}, Questie.db.char.complete)
        end)

        it("should leave quests alone that the player can do again, although the game counts them as completed", function()
            Questie.db.char.complete[CALL_OF_EARTH] = false
            completedByTheGame = {[CALL_OF_EARTH] = true}

            CompletedQuests.Update()

            assert.are_same({[CALL_OF_EARTH] = false}, Questie.db.char.complete)
            assert.spy(AvailableQuests.CalculateAndDrawAll).was.not_called()
        end)

        it("should read the game's list on clients that return it as IDs", function()
            _G.GetQuestsCompleted = nil
            _G.C_QuestLog.GetAllCompletedQuestIDs = function() return {CALL_OF_EARTH, CALL_OF_EARTH_TAUREN} end

            CompletedQuests.Update()

            assert.are_same({[CALL_OF_EARTH] = true, [CALL_OF_EARTH_TAUREN] = true}, Questie.db.char.complete)
        end)
    end)

    describe("ScheduleUpdate", function()
        local now, timers

        ---@param seconds number
        local function _Wait(seconds)
            now = now + seconds
            for _, timer in ipairs(timers) do
                if timer.time <= now and (not timer.isDone) then
                    timer.isDone = true
                    timer.callback()
                end
            end
        end

        before_each(function()
            now, timers = 0, {}
            _G.C_Timer = {
                NewTimer = function(delay, callback)
                    local timer = {time = now + delay, callback = callback, Cancel = function(self) self.isDone = true end}
                    timers[#timers + 1] = timer
                    return timer
                end
            }
            completedByTheGame = {[CALL_OF_EARTH_TAUREN] = true}
        end)

        it("should update one second later", function()
            CompletedQuests.ScheduleUpdate()

            _Wait(0.9)
            assert.are_same({}, Questie.db.char.complete)
            _Wait(0.1)
            assert.are_same({[CALL_OF_EARTH_TAUREN] = true}, Questie.db.char.complete)
        end)

        it("should update once, one second after the last call", function()
            CompletedQuests.ScheduleUpdate()
            _Wait(0.5)
            CompletedQuests.ScheduleUpdate()

            _Wait(0.5)
            assert.are_same({}, Questie.db.char.complete)
            _Wait(0.5)
            assert.are_same({[CALL_OF_EARTH_TAUREN] = true}, Questie.db.char.complete)
            assert.spy(AvailableQuests.CalculateAndDrawAll).was.called(1)
        end)

        it("should update again for a call after the update", function()
            CompletedQuests.ScheduleUpdate()
            _Wait(1)
            completedByTheGame = {[CALL_OF_EARTH] = true}

            CompletedQuests.ScheduleUpdate()
            _Wait(1)

            assert.are_same({[CALL_OF_EARTH] = true, [CALL_OF_EARTH_TAUREN] = true}, Questie.db.char.complete)
        end)
    end)
end)
