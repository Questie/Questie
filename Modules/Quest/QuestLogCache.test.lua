dofile("setupTests.lua")

describe("QuestLogCache", function()
    ---@type QuestLogCache
    local QuestLogCache
    ---@type Sounds
    local Sounds

    local QUEST_ID = 1234

    local questLogTitles = {}
    local questObjectives = {}
    local originalHaveQuestData, originalGetQuestLogTitle, originalQuestLog

    before_each(function()
        originalHaveQuestData, originalGetQuestLogTitle, originalQuestLog = _G.HaveQuestData, _G.GetQuestLogTitle, _G.C_QuestLog
        questLogTitles = {}
        questObjectives = {}

        _G.HaveQuestData = function() return true end
        _G.GetQuestLogTitle = function(index)
            local entry = questLogTitles[index]
            if entry then
                return table.unpack(entry)
            end
            return nil
        end
        _G.C_QuestLog = {
            GetQuestObjectives = function(questId)
                return questObjectives[questId]
            end
        }

        dofile("Modules/Libs/QuestieLib.lua")

        Sounds = QuestieLoader:ImportModule("Sounds")
        Sounds.PlayQuestComplete = spy.new(function() end)
        Sounds.PlayObjectiveComplete = spy.new(function() end)
        Sounds.PlayObjectiveProgress = spy.new(function() end)

        dofile("Modules/Quest/QuestLogCache.lua")
        QuestLogCache = QuestieLoader:ImportModule("QuestLogCache")
    end)

    after_each(function()
        _G.HaveQuestData, _G.GetQuestLogTitle, _G.C_QuestLog = originalHaveQuestData, originalGetQuestLogTitle, originalQuestLog
    end)

    describe("TryGetQuest", function()
        local originalPrint, originalError

        before_each(function()
            originalPrint, originalError = Questie.Print, Questie.Error
            Questie.Print = spy.new(function() end)
            Questie.Error = spy.new(function() end)
            _G.HaveQuestData = spy.new(function() return true end)
            _G.C_QuestLog.GetQuestObjectives = spy.new(_G.C_QuestLog.GetQuestObjectives)
            -- The cache captures the client function at load time.
            dofile("Modules/Quest/QuestLogCache.lua")
            QuestLogCache = QuestieLoader:ImportModule("QuestLogCache")
        end)

        after_each(function()
            Questie.Print, Questie.Error = originalPrint, originalError
        end)

        it("returns nil silently without requesting missing quest data", function()
            assert.is_nil(QuestLogCache.TryGetQuest(QUEST_ID))

            assert.spy(Questie.Print).was.not_called()
            assert.spy(Questie.Error).was.not_called()
            assert.spy(_G.HaveQuestData).was.not_called()
            assert.spy(_G.C_QuestLog.GetQuestObjectives).was.not_called()
            assert.are.equal(0, QuestLogCache.GetQuestCount())
        end)

        it("returns the same accepted snapshot as GetQuest without refreshing it", function()
            questLogTitles[1] = {"Collect Items", 2, nil, false, false, nil, nil, QUEST_ID}
            questObjectives[QUEST_ID] = {{text = "Item: 2/5", type = "item", numFulfilled = 2, numRequired = 5, finished = false}}
            QuestLogCache.CheckForChanges(nil)
            local accepted = QuestLogCache.GetQuest(QUEST_ID)
            questObjectives[QUEST_ID][1].text = "Item: 3/5"
            questObjectives[QUEST_ID][1].numFulfilled = 3
            _G.C_QuestLog.GetQuestObjectives:clear()
            _G.HaveQuestData:clear()

            local result = QuestLogCache.TryGetQuest(QUEST_ID)

            assert.are.equal(accepted, result)
            assert.are.equal("Item: 2/5", result.objectives[1].raw_text)
            assert.are.equal(2, result.objectives[1].numFulfilled)
            assert.spy(_G.C_QuestLog.GetQuestObjectives).was.not_called()
            assert.spy(_G.HaveQuestData).was.not_called()
            assert.spy(Questie.Print).was.not_called()
            assert.spy(Questie.Error).was.not_called()
        end)
    end)

    describe("client objective placeholders", function()
        local originalItemsNeeded, originalMonstersKilled
        local cases = {
            {name = "Classic item", itemFormat = "%s: %d/%d", monsterFormat = "%s slain: %d/%d",
                type = "item", missing = " : 0/8", loaded = "item: 0/8", progress = "item: 2/8", expected = "item"},
            {name = "Forever item", itemFormat = "%2$d/%3$d %1$s", monsterFormat = "%2$d/%3$d %1$s slain",
                type = "item", missing = "0/8  ", loaded = "0/8 item", progress = "2/8 item", expected = "item"},
            {name = "Forever monster", itemFormat = "%2$d/%3$d %1$s", monsterFormat = "%2$d/%3$d %1$s slain",
                type = "monster", missing = "0/8   slain", loaded = "0/8 Wolf slain", progress = "2/8 Wolf slain", expected = "Wolf"},
            -- Constructed unknown-suffix fixtures exercise the literal spacing check, not the localized parser.
            {name = "unknown English suffix", itemFormat = "%2$d/%3$d %1$s", monsterFormat = "%2$d/%3$d %1$s slain",
                type = "monster", missing = "0/8   destroyed", loaded = "0/8 Roiling Winds destroyed",
                progress = "2/8 Roiling Winds destroyed", expected = "0/8 Roiling Winds destroyed"},
            {name = "unknown UTF-8 suffix", itemFormat = "%2$d/%3$d %1$s", monsterFormat = "%2$d/%3$d %1$s slain",
                type = "monster", missing = "0/8   已摧毁", loaded = "0/8 烈风已摧毁",
                progress = "2/8 烈风已摧毁", expected = "0/8 烈风已摧毁"},
        }

        before_each(function()
            originalItemsNeeded, originalMonstersKilled = _G.QUEST_ITEMS_NEEDED, _G.QUEST_MONSTERS_KILLED
        end)

        after_each(function()
            _G.QUEST_ITEMS_NEEDED, _G.QUEST_MONSTERS_KILLED = originalItemsNeeded, originalMonstersKilled
        end)

        for _, case in ipairs(cases) do
            it("does not cache missing " .. case.name .. " names and retains loaded rows until the client recovers", function()
                _G.QUEST_ITEMS_NEEDED, _G.QUEST_MONSTERS_KILLED = case.itemFormat, case.monsterFormat
                dofile("Modules/Libs/QuestieLib.lua")
                questLogTitles[1] = {"Collect Items", 60, nil, false, false, nil, nil, QUEST_ID}
                -- Missing names are a single space: two spaces after the item counter, three before "slain".
                questObjectives[QUEST_ID] = {
                    {text = case.missing, type = case.type, numFulfilled = 0, numRequired = 8, finished = false},
                }
                local cacheMiss, changes = QuestLogCache.CheckForChanges(nil)
                assert.is_true(cacheMiss)
                assert.are.same({}, changes)
                assert.are.equal(0, QuestLogCache.GetQuestCount())
                assert.is_false(QuestLogCache.TestGameCache())

                questObjectives[QUEST_ID][1].text = case.loaded
                cacheMiss, changes = QuestLogCache.CheckForChanges(nil)
                assert.is_false(cacheMiss)
                assert.are.same({[QUEST_ID] = {1}}, changes)
                local previous = QuestLogCache.GetQuest(QUEST_ID)
                assert.are.equal(case.expected, previous.objectives[1].text)
                assert.are.equal(case.loaded, previous.objectives[1].raw_text)
                assert.are.equal(0, previous.isComplete)
                assert.is_true(QuestLogCache.TestGameCache())

                -- HaveQuestData stays true and counters stay valid while the client loses the name.
                questObjectives[QUEST_ID][1].text = case.missing
                for _ = 1, 2 do
                    cacheMiss, changes = QuestLogCache.CheckForChanges(nil)
                    assert.is_true(cacheMiss)
                    assert.are.same({}, changes)
                    assert.are.equal(previous, QuestLogCache.GetQuest(QUEST_ID))
                    assert.is_false(QuestLogCache.TestGameCache())
                end
                questObjectives[QUEST_ID][1].text = case.loaded
                cacheMiss, changes = QuestLogCache.CheckForChanges(nil)
                assert.is_false(cacheMiss)
                assert.are.same({}, changes)
                assert.spy(Sounds.PlayObjectiveProgress).was.not_called()
                assert.spy(Sounds.PlayObjectiveComplete).was.not_called()
                assert.spy(Sounds.PlayQuestComplete).was.not_called()

                questObjectives[QUEST_ID][1].text = case.progress
                questObjectives[QUEST_ID][1].numFulfilled = 2
                cacheMiss, changes = QuestLogCache.CheckForChanges(nil)
                assert.is_false(cacheMiss)
                assert.are.same({[QUEST_ID] = {1}}, changes)
                assert.are.equal(2, QuestLogCache.GetQuest(QUEST_ID).objectives[1].numFulfilled)
                assert.are.equal(case.progress, QuestLogCache.GetQuest(QUEST_ID).objectives[1].raw_text)
                assert.spy(Sounds.PlayObjectiveProgress).was.called(1)
            end)
        end
    end)

    describe("CheckForChanges", function()
        it("retries a nil objective response without publishing an empty completed quest", function()
            questLogTitles[1] = {"Return the book", 2, nil, false, false, nil, nil, QUEST_ID}

            local cacheMiss, changes, checked = QuestLogCache.CheckForChanges(nil)

            assert.is_true(cacheMiss)
            assert.are.same({}, changes)
            assert.are.same({[QUEST_ID] = true}, checked)
            assert.is_nil(QuestLogCache.questLog_DO_NOT_MODIFY[QUEST_ID])

            questObjectives[QUEST_ID] = {{text = "Return the book.", type = "log", numFulfilled = 0, numRequired = 1, finished = false}}
            cacheMiss, changes = QuestLogCache.CheckForChanges(nil)

            assert.is_false(cacheMiss)
            assert.are.same({[QUEST_ID] = {1}}, changes)
            assert.are.equal(0, QuestLogCache.GetQuest(QUEST_ID).isComplete)
        end)

        it("retains the last valid snapshot when a row loses its type and publishes it when ready", function()
            questLogTitles[1] = {"Collect Items", 2, nil, false, false, nil, nil, QUEST_ID}
            questObjectives[QUEST_ID] = {{text = "Item: 2/5", type = "item", numFulfilled = 2, numRequired = 5, finished = false}}
            QuestLogCache.CheckForChanges(nil)
            local previous = QuestLogCache.GetQuest(QUEST_ID)
            questObjectives[QUEST_ID] = {{text = "Item: 3/5", numFulfilled = 3, numRequired = 5, finished = false}}

            local cacheMiss, changes = QuestLogCache.CheckForChanges(nil)

            assert.is_true(cacheMiss)
            assert.are.same({}, changes)
            assert.are.equal(previous, QuestLogCache.GetQuest(QUEST_ID))
            assert.are.equal(2, previous.objectives[1].numFulfilled)
            assert.spy(Sounds.PlayObjectiveProgress).was.not_called()

            questObjectives[QUEST_ID][1].type = "item"
            cacheMiss, changes = QuestLogCache.CheckForChanges(nil)

            assert.is_false(cacheMiss)
            assert.are.same({[QUEST_ID] = {1}}, changes)
            assert.are.equal(3, QuestLogCache.GetQuest(QUEST_ID).objectives[1].numFulfilled)
        end)

        it("does not play progress sounds when a later objective is missing its type", function()
            questLogTitles[1] = {"Collect Items", 2, nil, false, false, nil, nil, QUEST_ID}
            questObjectives[QUEST_ID] = {
                {text = "Item: 2/5", type = "item", numFulfilled = 2, numRequired = 5, finished = false},
                {text = "Wolf slain: 0/3", type = "monster", numFulfilled = 0, numRequired = 3, finished = false},
            }
            QuestLogCache.CheckForChanges(nil)
            local previous = QuestLogCache.GetQuest(QUEST_ID)
            questObjectives[QUEST_ID][1].text = "Item: 3/5"
            questObjectives[QUEST_ID][1].numFulfilled = 3
            questObjectives[QUEST_ID][2].type = nil

            assert.is_true(QuestLogCache.CheckForChanges(nil))
            assert.is_true(QuestLogCache.CheckForChanges(nil))
            assert.are.equal(previous, QuestLogCache.GetQuest(QUEST_ID))
            assert.spy(Sounds.PlayObjectiveProgress).was.not_called()
            assert.spy(Sounds.PlayObjectiveComplete).was.not_called()

            questObjectives[QUEST_ID][2].type = "monster"
            assert.is_false(QuestLogCache.CheckForChanges(nil))
            assert.are.equal(3, QuestLogCache.GetQuest(QUEST_ID).objectives[1].numFulfilled)
            assert.spy(Sounds.PlayObjectiveProgress).was.called(1)
        end)

        it("should add a new quest to the cache on first scan without playing any sounds", function()
            questLogTitles = {
                [1] = {"Kill the Boss", 60, nil, false, false, nil, nil, QUEST_ID},
            }
            questObjectives = {
                [QUEST_ID] = {{
                    type = "monster",
                    numRequired = 3,
                    text = "Boss slain: 0/3",
                    finished = false,
                    numFulfilled = 0,
                }}
            }

            local cacheMiss, changes = QuestLogCache.CheckForChanges(nil)

            assert.is_false(cacheMiss)
            assert.is_not_nil(changes[QUEST_ID])
            assert.is_not_nil(QuestLogCache.questLog_DO_NOT_MODIFY[QUEST_ID])
            assert.is_equal(0, QuestLogCache.questLog_DO_NOT_MODIFY[QUEST_ID].isComplete)
            assert.spy(Sounds.PlayQuestComplete).was.not_called()
            assert.spy(Sounds.PlayObjectiveComplete).was.not_called()
            assert.spy(Sounds.PlayObjectiveProgress).was.not_called()
        end)

        it("should play PlayQuestComplete when quest transitions from incomplete to complete", function()
            questLogTitles = {
                [1] = {"Kill the Boss", 60, nil, false, false, nil, nil, QUEST_ID},
            }
            questObjectives = {
                [QUEST_ID] = {{
                    type = "monster",
                    numRequired = 1,
                    text = "Boss slain: 0/1",
                    finished = false,
                    numFulfilled = 0,
                }}
            }

            -- Step 1: Initial scan — quest enters cache as isComplete=0
            QuestLogCache.CheckForChanges(nil)
            assert.spy(Sounds.PlayQuestComplete).was.not_called()
            assert.spy(Sounds.PlayObjectiveProgress).was.not_called()
            assert.spy(Sounds.PlayObjectiveComplete).was.not_called()

            -- Step 2: Quest completes
            questLogTitles[1] = {"Kill the Boss", 60, nil, false, false, 1, nil, QUEST_ID}
            questObjectives[QUEST_ID] = {{
                type = "monster",
                numRequired = 1,
                text = "Boss slain: 1/1",
                finished = true,
                numFulfilled = 1,
            }}

            local cacheMiss, changes = QuestLogCache.CheckForChanges(nil)

            assert.is_false(cacheMiss)
            assert.is_not_nil(changes[QUEST_ID])
            assert.is_equal(1, QuestLogCache.questLog_DO_NOT_MODIFY[QUEST_ID].isComplete)
            assert.spy(Sounds.PlayQuestComplete).was.called(1)
            assert.spy(Sounds.PlayObjectiveComplete).was.called(1)
            assert.spy(Sounds.PlayObjectiveProgress).was.not_called()
        end)

        it("should play PlayObjectiveProgress when an objective partially progresses", function()
            questLogTitles = {
                [1] = {"Collect Items", 60, nil, false, false, nil, nil, QUEST_ID},
            }
            questObjectives = {
                [QUEST_ID] = {{
                    type = "item",
                    numRequired = 5,
                    text = "Item: 0/5",
                    finished = false,
                    numFulfilled = 0,
                }}
            }

            -- Step 1: Initial scan
            QuestLogCache.CheckForChanges(nil)

            -- Step 2: Partial progress
            questObjectives[QUEST_ID] = {{
                type = "item",
                numRequired = 5,
                text = "Item: 3/5",
                finished = false,
                numFulfilled = 3,
            }}

            local cacheMiss, changes = QuestLogCache.CheckForChanges(nil)

            assert.is_false(cacheMiss)
            assert.is_not_nil(changes[QUEST_ID])
            assert.spy(Sounds.PlayObjectiveProgress).was.called(1)
            assert.spy(Sounds.PlayObjectiveComplete).was.not_called()
            assert.spy(Sounds.PlayQuestComplete).was.not_called()
        end)

        it("should play PlayObjectiveComplete when an objective reaches its required count and quest is still incomplete", function()
            questLogTitles = {
                [1] = {"Collect Items", 60, nil, false, false, nil, nil, QUEST_ID},
            }
            questObjectives = {
                [QUEST_ID] = {
                    {
                        type = "item",
                        numRequired = 5,
                        text = "Item: 0/5",
                        finished = false,
                        numFulfilled = 0,
                    },
                    {
                        type = "monster",
                        numRequired = 3,
                        text = "Enemy slain: 0/3",
                        finished = false,
                        numFulfilled = 0,
                    },
                }
            }

            -- Step 1: Initial scan
            QuestLogCache.CheckForChanges(nil)

            -- Step 2: First objective finishes, second still incomplete
            questObjectives[QUEST_ID] = {
                {
                    type = "item",
                    numRequired = 5,
                    text = "Item: 5/5",
                    finished = true,
                    numFulfilled = 5,
                },
                {
                    type = "monster",
                    numRequired = 3,
                    text = "Enemy slain: 0/3",
                    finished = false,
                    numFulfilled = 0,
                },
            }

            local cacheMiss, changes = QuestLogCache.CheckForChanges(nil)

            assert.is_false(cacheMiss)
            assert.is_not_nil(changes[QUEST_ID])
            assert.spy(Sounds.PlayObjectiveComplete).was.called(1)
            assert.spy(Sounds.PlayObjectiveProgress).was.not_called()
            assert.spy(Sounds.PlayQuestComplete).was.not_called()
        end)

        it("should return cacheMiss=true and no changes when HaveQuestData returns false", function()
            questLogTitles = {
                [1] = {"Kill the Boss", 60, nil, false, false, nil, nil, QUEST_ID},
            }
            _G.HaveQuestData = function() return false end

            local cacheMiss, changes = QuestLogCache.CheckForChanges(nil)

            assert.is_true(cacheMiss)
            assert.is_nil(changes[QUEST_ID])
            assert.spy(Sounds.PlayQuestComplete).was.not_called()
            assert.spy(Sounds.PlayObjectiveComplete).was.not_called()
            assert.spy(Sounds.PlayObjectiveProgress).was.not_called()
        end)

        it("should skip header entries", function()
            questLogTitles = {
                [1] = {"Zone Header", 0, nil, true, false, nil, nil, 0},
                [2] = {"Kill the Boss", 60, nil, false, false, nil, nil, QUEST_ID},
            }
            questObjectives = {
                [QUEST_ID] = {}
            }

            local cacheMiss, changes = QuestLogCache.CheckForChanges(nil)

            assert.is_false(cacheMiss)
            assert.is_nil(changes[0])
            assert.is_not_nil(changes[QUEST_ID])
        end)

        it("should only process quests listed in questIdsToCheck", function()
            local OTHER_QUEST_ID = 5678
            questLogTitles = {
                [1] = {"Kill the Boss", 60, nil, false, false, nil, nil, QUEST_ID},
                [2] = {"Collect Items", 60, nil, false, false, nil, nil, OTHER_QUEST_ID},
            }
            questObjectives = {
                [QUEST_ID] = {},
                [OTHER_QUEST_ID] = {},
            }

            local cacheMiss, changes = QuestLogCache.CheckForChanges({[QUEST_ID] = true})

            assert.is_false(cacheMiss)
            assert.is_not_nil(changes[QUEST_ID])
            assert.is_nil(changes[OTHER_QUEST_ID])
        end)

        it("should not re-trigger PlayQuestComplete when isCompleteAccordingToBlizzard temporarily returns nil", function()
            -- title, level, questTag, isHeader, isCollapsed, isComplete, frequency, questId
            questLogTitles = {
                [1] = {"Kill the Boss", 60, "Dungeon", false, false, 1, nil, QUEST_ID},
            }
            questObjectives = {
                [QUEST_ID] = {{
                    type = "monster",
                    numRequired = 1,
                    text = "Boss killed",
                    finished = true,
                    numFulfilled = 1,
                }}
            }

            -- Step 1: Normal completion scan — quest enters cache as isComplete=1
            local cacheMiss, changes = QuestLogCache.CheckForChanges(nil)
            assert.is_false(cacheMiss)
            assert.is_not_nil(changes[QUEST_ID])
            assert.is_equal(1, QuestLogCache.questLog_DO_NOT_MODIFY[QUEST_ID].isComplete)
            assert.spy(Sounds.PlayQuestComplete).was.not_called()
            assert.spy(Sounds.PlayObjectiveComplete).was.not_called()
            assert.spy(Sounds.PlayObjectiveProgress).was.not_called()

            -- Step 2: Zone transition — Blizzard incorrectly returns nil for isComplete
            questLogTitles[1] = {"Kill the Boss", 60, "Dungeon", false, false, nil, nil, QUEST_ID}
            questObjectives[QUEST_ID] = {{
                type = "monster",
                numRequired = 1,
                text = "Boss killed",
                finished = false,   -- Blizzard reports event objectives as unfinished when uncached
                numFulfilled = 0,
            }}

            cacheMiss, changes = QuestLogCache.CheckForChanges(nil)
            assert.is_true(cacheMiss)
            assert.is_equal(0, #changes)
            -- isComplete must NOT be downgraded to 0
            assert.is_equal(1, QuestLogCache.questLog_DO_NOT_MODIFY[QUEST_ID].isComplete)
            assert.spy(Sounds.PlayQuestComplete).was.not_called()
            assert.spy(Sounds.PlayObjectiveComplete).was.not_called()
            assert.spy(Sounds.PlayObjectiveProgress).was.not_called()

            -- Step 3: Blizzard restores isComplete=1 — must NOT be treated as a fresh completion
            questLogTitles[1] = {"Kill the Boss", 60, "Dungeon", false, false, 1, nil, QUEST_ID}
            questObjectives[QUEST_ID] = {{
                type = "monster",
                numRequired = 1,
                text = "Boss killed",
                finished = true,
                numFulfilled = 1,
            }}

            cacheMiss, changes = QuestLogCache.CheckForChanges(nil)
            assert.is_false(cacheMiss)
            assert.is_equal(0, #changes)
            assert.is_equal(1, QuestLogCache.questLog_DO_NOT_MODIFY[QUEST_ID].isComplete)
            assert.spy(Sounds.PlayQuestComplete).was.not_called()
            assert.spy(Sounds.PlayObjectiveComplete).was.not_called()
            assert.spy(Sounds.PlayObjectiveProgress).was.not_called()
        end)

        it("should not play sounds when objective numFulfilled regresses during zone transition", function()
            questLogTitles = {
                [1] = {"Collect Items", 60, nil, false, false, nil, nil, QUEST_ID},
            }
            questObjectives = {
                [QUEST_ID] = {{
                    type = "item",
                    numRequired = 5,
                    text = "Item: 3/5",
                    finished = false,
                    numFulfilled = 3,
                }}
            }

            -- Step 1: Initial scan — objective cached at 3/5
            QuestLogCache.CheckForChanges(nil)
            assert.is_equal(3, QuestLogCache.questLog_DO_NOT_MODIFY[QUEST_ID].objectives[1].raw_numFulfilled)

            -- Step 2: Zone transition — Blizzard returns stale 0/5 (first QUEST_LOG_UPDATE)
            QuestLogCache.OnLoadingScreenEnabled()
            questObjectives[QUEST_ID] = {{
                type = "item",
                numRequired = 5,
                text = "Item: 0/5",
                finished = false,
                numFulfilled = 0,
            }}

            local cacheMiss, changes = QuestLogCache.CheckForChanges(nil)
            assert.is_true(cacheMiss)
            assert.is_nil(changes[QUEST_ID])
            assert.is_equal(3, QuestLogCache.questLog_DO_NOT_MODIFY[QUEST_ID].objectives[1].raw_numFulfilled)
            assert.spy(Sounds.PlayObjectiveProgress).was.not_called()
            assert.spy(Sounds.PlayObjectiveComplete).was.not_called()
            assert.spy(Sounds.PlayQuestComplete).was.not_called()

            -- Step 3: Second QUEST_LOG_UPDATE still stale — must NOT be accepted
            cacheMiss, changes = QuestLogCache.CheckForChanges(nil)
            assert.is_true(cacheMiss)
            assert.is_nil(changes[QUEST_ID])
            assert.is_equal(3, QuestLogCache.questLog_DO_NOT_MODIFY[QUEST_ID].objectives[1].raw_numFulfilled)
            assert.spy(Sounds.PlayObjectiveProgress).was.not_called()
            assert.spy(Sounds.PlayObjectiveComplete).was.not_called()
            assert.spy(Sounds.PlayQuestComplete).was.not_called()

            -- Step 4: Blizzard restores 3/5 — must not look like forward progress
            questObjectives[QUEST_ID] = {{
                type = "item",
                numRequired = 5,
                text = "Item: 3/5",
                finished = false,
                numFulfilled = 3,
            }}

            cacheMiss, changes = QuestLogCache.CheckForChanges(nil)
            assert.is_false(cacheMiss)
            assert.is_nil(changes[QUEST_ID])
            assert.is_equal(3, QuestLogCache.questLog_DO_NOT_MODIFY[QUEST_ID].objectives[1].raw_numFulfilled)
            assert.spy(Sounds.PlayObjectiveProgress).was.not_called()
            assert.spy(Sounds.PlayObjectiveComplete).was.not_called()
            assert.spy(Sounds.PlayQuestComplete).was.not_called()
        end)

        it("accepts a recovered quest's item decrease after another quest was unavailable", function()
            local OTHER_QUEST_ID = 5678
            questLogTitles = {
                [1] = {"Collect Items", 60, nil, false, false, nil, nil, QUEST_ID},
                [2] = {"Collect Other Items", 60, nil, false, false, nil, nil, OTHER_QUEST_ID},
            }
            questObjectives = {
                [QUEST_ID] = {{text = "Item: 5/10", type = "item", numFulfilled = 5, numRequired = 10, finished = false}},
                [OTHER_QUEST_ID] = {{text = "Other Item: 2/10", type = "item", numFulfilled = 2, numRequired = 10, finished = false}},
            }
            QuestLogCache.CheckForChanges(nil)
            QuestLogCache.OnLoadingScreenEnabled()

            _G.HaveQuestData = function(questId) return questId ~= OTHER_QUEST_ID end
            local cacheMiss, changes = QuestLogCache.CheckForChanges(nil)
            assert.is_true(cacheMiss)
            assert.are.same({}, changes)

            questObjectives[QUEST_ID][1].text = "Item: 4/10"
            questObjectives[QUEST_ID][1].numFulfilled = 4

            cacheMiss, changes = QuestLogCache.CheckForChanges(nil)
            assert.is_true(cacheMiss)
            assert.are.same({[QUEST_ID] = {1}}, changes)
            assert.are.equal(4, QuestLogCache.GetQuest(QUEST_ID).objectives[1].numFulfilled)

            _G.HaveQuestData = function() return true end
            cacheMiss, changes = QuestLogCache.CheckForChanges(nil)
            assert.is_false(cacheMiss)
            assert.are.same({}, changes)
            assert.spy(Sounds.PlayObjectiveProgress).was.not_called()
            assert.spy(Sounds.PlayObjectiveComplete).was.not_called()
            assert.spy(Sounds.PlayQuestComplete).was.not_called()
        end)

        it("keeps a partially recovered quest protected until all objective rows recover", function()
            questLogTitles[1] = {"Collect Items", 60, nil, false, false, nil, nil, QUEST_ID}
            local validObjectives = {
                {text = "Item: 5/10", type = "item", numFulfilled = 5, numRequired = 10, finished = false},
                {text = "Other Item: 2/10", type = "item", numFulfilled = 2, numRequired = 10, finished = false},
            }
            questObjectives[QUEST_ID] = validObjectives
            QuestLogCache.CheckForChanges(nil)
            QuestLogCache.OnLoadingScreenEnabled()

            questObjectives[QUEST_ID] = {
                validObjectives[1],
                {text = " ", type = "item", numFulfilled = 0, numRequired = 10, finished = false},
            }
            local cacheMiss, changes = QuestLogCache.CheckForChanges(nil)
            assert.is_true(cacheMiss)
            assert.are.same({}, changes)
            assert.are.equal(2, QuestLogCache.GetQuest(QUEST_ID).objectives[2].numFulfilled)

            questObjectives[QUEST_ID] = {
                {text = "Item: 0/10", type = "item", numFulfilled = 0, numRequired = 10, finished = false},
                {text = "Other Item: 0/10", type = "item", numFulfilled = 0, numRequired = 10, finished = false},
            }
            cacheMiss, changes = QuestLogCache.CheckForChanges(nil)
            assert.is_true(cacheMiss)
            assert.are.same({}, changes)
            local cached = QuestLogCache.GetQuest(QUEST_ID)
            assert.are.equal(5, cached.objectives[1].numFulfilled)
            assert.are.equal(2, cached.objectives[2].numFulfilled)

            questObjectives[QUEST_ID] = validObjectives
            cacheMiss, changes = QuestLogCache.CheckForChanges(nil)
            assert.is_false(cacheMiss)
            assert.are.same({}, changes)
            assert.spy(Sounds.PlayObjectiveProgress).was.not_called()
            assert.spy(Sounds.PlayObjectiveComplete).was.not_called()
            assert.spy(Sounds.PlayQuestComplete).was.not_called()

            questObjectives[QUEST_ID] = {
                {text = "Item: 4/10", type = "item", numFulfilled = 4, numRequired = 10, finished = false},
                validObjectives[2],
            }
            cacheMiss, changes = QuestLogCache.CheckForChanges(nil)
            assert.is_false(cacheMiss)
            assert.are.same({[QUEST_ID] = {1}}, changes)
            assert.are.equal(4, QuestLogCache.GetQuest(QUEST_ID).objectives[1].numFulfilled)
        end)

        for _, missingResponse in ipairs({"quest data", "nil objectives", "placeholder text", "missing type"}) do
            it("keeps an unrecovered quest protected after " .. missingResponse .. " and a successful restricted scan", function()
                local OTHER_QUEST_ID = 5678
                questLogTitles = {
                    [1] = {"Collect Items", 60, nil, false, false, nil, nil, QUEST_ID},
                    [2] = {"Collect Other Items", 60, nil, false, false, nil, nil, OTHER_QUEST_ID},
                }
                local validObjectives = {
                    {text = "Item: 5/10", type = "item", numFulfilled = 5, numRequired = 10, finished = false},
                }
                questObjectives = {
                    [QUEST_ID] = validObjectives,
                    [OTHER_QUEST_ID] = {{text = "Other Item: 2/10", type = "item", numFulfilled = 2,
                        numRequired = 10, finished = false}},
                }
                QuestLogCache.CheckForChanges(nil)
                QuestLogCache.OnLoadingScreenEnabled()

                if missingResponse == "quest data" then
                    _G.HaveQuestData = function(questId) return questId ~= QUEST_ID end
                elseif missingResponse == "nil objectives" then
                    questObjectives[QUEST_ID] = nil
                elseif missingResponse == "placeholder text" then
                    questObjectives[QUEST_ID] = {{text = " ", type = "item", numFulfilled = 0,
                        numRequired = 10, finished = false}}
                else
                    questObjectives[QUEST_ID] = {{text = "Item: 5/10", numFulfilled = 5, numRequired = 10, finished = false}}
                end
                assert.is_true(QuestLogCache.CheckForChanges(nil))

                -- A successful scan of B must not establish recovery for A.
                assert.is_false(QuestLogCache.CheckForChanges({[OTHER_QUEST_ID] = true}))
                _G.HaveQuestData = function() return true end
                questObjectives[QUEST_ID] = {{text = "Item: 0/10", type = "item", numFulfilled = 0,
                    numRequired = 10, finished = false}}
                local cacheMiss, changes = QuestLogCache.CheckForChanges(nil)
                assert.is_true(cacheMiss)
                assert.are.same({}, changes)
                assert.are.equal(5, QuestLogCache.GetQuest(QUEST_ID).objectives[1].numFulfilled)

                questObjectives[QUEST_ID] = validObjectives
                assert.is_false(QuestLogCache.CheckForChanges(nil))
                assert.spy(Sounds.PlayObjectiveProgress).was.not_called()
                assert.spy(Sounds.PlayObjectiveComplete).was.not_called()
                assert.spy(Sounds.PlayQuestComplete).was.not_called()

                questObjectives[QUEST_ID] = {{text = "Item: 4/10", type = "item", numFulfilled = 4,
                    numRequired = 10, finished = false}}
                cacheMiss, changes = QuestLogCache.CheckForChanges(nil)
                assert.is_false(cacheMiss)
                assert.are.same({[QUEST_ID] = {1}}, changes)
                assert.are.equal(4, QuestLogCache.GetQuest(QUEST_ID).objectives[1].numFulfilled)
            end)
        end

        it("should not play sounds on second zone transition when no objective progress was made", function()
            questLogTitles = {
                [1] = {"Collect Items", 60, nil, false, false, nil, nil, QUEST_ID},
            }
            questObjectives = {
                [QUEST_ID] = {{
                    type = "item",
                    numRequired = 5,
                    text = "Item: 3/5",
                    finished = false,
                    numFulfilled = 3,
                }}
            }

            -- Step 1: Initial scan — objective cached at 3/5
            QuestLogCache.CheckForChanges(nil)

            -- Step 2: First zone transition (enter dungeon) — Blizzard returns stale 0/5
            QuestLogCache.OnLoadingScreenEnabled()
            questObjectives[QUEST_ID] = {{
                type = "item",
                numRequired = 5,
                text = "Item: 0/5",
                finished = false,
                numFulfilled = 0,
            }}
            local cacheMiss = QuestLogCache.CheckForChanges(nil)
            assert.is_true(cacheMiss)

            -- Step 3: Blizzard restores 3/5 — objective unchanged, no sounds
            questObjectives[QUEST_ID] = {{
                type = "item",
                numRequired = 5,
                text = "Item: 3/5",
                finished = false,
                numFulfilled = 3,
            }}
            QuestLogCache.CheckForChanges(nil)
            assert.spy(Sounds.PlayObjectiveProgress).was.not_called()

            -- Step 4: Second zone transition (leave dungeon) — stale 0/5 again
            QuestLogCache.OnLoadingScreenEnabled()
            questObjectives[QUEST_ID] = {{
                type = "item",
                numRequired = 5,
                text = "Item: 0/5",
                finished = false,
                numFulfilled = 0,
            }}
            cacheMiss = QuestLogCache.CheckForChanges(nil)

            assert.is_true(cacheMiss)
            assert.is_equal(3, QuestLogCache.questLog_DO_NOT_MODIFY[QUEST_ID].objectives[1].raw_numFulfilled)
            assert.spy(Sounds.PlayObjectiveProgress).was.not_called()
            assert.spy(Sounds.PlayObjectiveComplete).was.not_called()
            assert.spy(Sounds.PlayQuestComplete).was.not_called()
        end)

        it("should accept a regression outside of zone transition (e.g. item deletion)", function()
            questLogTitles = {
                [1] = {"Collect Items", 60, nil, false, false, nil, nil, QUEST_ID},
            }
            questObjectives = {
                [QUEST_ID] = {{
                    type = "item",
                    numRequired = 5,
                    text = "Item: 3/5",
                    finished = false,
                    numFulfilled = 3,
                }}
            }

            -- Step 1: Initial scan — objective cached at 3/5
            QuestLogCache.CheckForChanges(nil)

            -- Step 2: Player deletes items; no loading-screen recovery is pending.
            questObjectives[QUEST_ID] = {{
                type = "item",
                numRequired = 5,
                text = "Item: 1/5",
                finished = false,
                numFulfilled = 1,
            }}

            local cacheMiss, changes = QuestLogCache.CheckForChanges(nil)

            assert.is_false(cacheMiss)
            assert.is_not_nil(changes[QUEST_ID])
            assert.is_equal(1, QuestLogCache.questLog_DO_NOT_MODIFY[QUEST_ID].objectives[1].raw_numFulfilled)
            assert.spy(Sounds.PlayObjectiveProgress).was.not_called()
            assert.spy(Sounds.PlayObjectiveComplete).was.not_called()
            assert.spy(Sounds.PlayQuestComplete).was.not_called()
        end)

        it("should not accept a regression during zone transition even on repeated scans", function()
            questLogTitles = {
                [1] = {"Collect Items", 60, nil, false, false, nil, nil, QUEST_ID},
            }
            questObjectives = {
                [QUEST_ID] = {{
                    type = "item",
                    numRequired = 5,
                    text = "Item: 3/5",
                    finished = false,
                    numFulfilled = 3,
                }}
            }

            -- Step 1: Initial scan — objective cached at 3/5
            QuestLogCache.CheckForChanges(nil)

            QuestLogCache.OnLoadingScreenEnabled()
            questObjectives[QUEST_ID] = {{
                type = "item",
                numRequired = 5,
                text = "Item: 0/5",
                finished = false,
                numFulfilled = 0,
            }}

            -- Repeated stale scans — all must be cache misses
            for _ = 1, 5 do
                local cacheMiss, changes = QuestLogCache.CheckForChanges(nil)
                assert.is_true(cacheMiss)
                assert.is_nil(changes[QUEST_ID])
                assert.is_equal(3, QuestLogCache.questLog_DO_NOT_MODIFY[QUEST_ID].objectives[1].raw_numFulfilled)
            end
            assert.spy(Sounds.PlayObjectiveProgress).was.not_called()
            assert.spy(Sounds.PlayObjectiveComplete).was.not_called()
            assert.spy(Sounds.PlayQuestComplete).was.not_called()
        end)

        it("should update isComplete to -1 when quest fails after being complete with incomplete inbetween", function()
            -- Sequence: accepted -> 1 -> fails -> nil -> 1 -> -1 -> -1
            questLogTitles = {
                [1] = {"Kill the Boss", 60, nil, false, false, 1, nil, QUEST_ID},
            }
            questObjectives = {
                [QUEST_ID] = {{
                    type = "monster",
                    numRequired = 1,
                    text = "Boss slain: 1/1",
                    finished = true,
                    numFulfilled = 1,
                }}
            }

            -- Step 1: Quest is complete — enters cache as isComplete=1
            local cacheMiss, changes = QuestLogCache.CheckForChanges(nil)
            assert.is_false(cacheMiss)
            assert.is_not_nil(changes[QUEST_ID])
            assert.is_equal(1, QuestLogCache.questLog_DO_NOT_MODIFY[QUEST_ID].isComplete)

            -- Step 2: Quest fails — Blizzard temporarily returns nil, objectives unchanged
            questLogTitles[1] = {"Kill the Boss", 60, nil, false, false, nil, nil, QUEST_ID}

            cacheMiss, changes = QuestLogCache.CheckForChanges(nil)
            assert.is_true(cacheMiss)
            assert.is_nil(changes[QUEST_ID])
            assert.is_equal(1, QuestLogCache.questLog_DO_NOT_MODIFY[QUEST_ID].isComplete)

            -- Step 3: Blizzard returns 1 briefly before settling on -1, objectives still unchanged
            questLogTitles[1] = {"Kill the Boss", 60, nil, false, false, 1, nil, QUEST_ID}

            cacheMiss, changes = QuestLogCache.CheckForChanges(nil)
            assert.is_false(cacheMiss)
            assert.is_nil(changes[QUEST_ID])
            assert.is_equal(1, QuestLogCache.questLog_DO_NOT_MODIFY[QUEST_ID].isComplete)

            -- Step 4: Blizzard settles on -1 (failed), objectives still unchanged
            questLogTitles[1] = {"Kill the Boss", 60, nil, false, false, -1, nil, QUEST_ID}

            cacheMiss, changes = QuestLogCache.CheckForChanges(nil)
            assert.is_false(cacheMiss)
            assert.is_not_nil(changes[QUEST_ID])
            assert.is_equal(-1, QuestLogCache.questLog_DO_NOT_MODIFY[QUEST_ID].isComplete)
        end)

        it("should update isComplete to -1 when quest fails after being complete", function()
            -- Sequence: accepted -> 1 -> fails -> -1 -> -1
            questLogTitles = {
                [1] = {"Kill the Boss", 60, nil, false, false, 1, nil, QUEST_ID},
            }
            questObjectives = {
                [QUEST_ID] = {{
                    type = "monster",
                    numRequired = 1,
                    text = "Boss slain: 1/1",
                    finished = true,
                    numFulfilled = 1,
                }}
            }

            -- Step 1: Quest is complete — enters cache as isComplete=1
            local cacheMiss, changes = QuestLogCache.CheckForChanges(nil)
            assert.is_false(cacheMiss)
            assert.is_not_nil(changes[QUEST_ID])
            assert.is_equal(1, QuestLogCache.questLog_DO_NOT_MODIFY[QUEST_ID].isComplete)

            -- Step 2: Quest fails — Blizzard directly settles on -1 (failed)
            questLogTitles[1] = {"Kill the Boss", 60, nil, false, false, -1, nil, QUEST_ID}

            cacheMiss, changes = QuestLogCache.CheckForChanges(nil)
            assert.is_false(cacheMiss)
            assert.is_not_nil(changes[QUEST_ID])
            assert.is_equal(-1, QuestLogCache.questLog_DO_NOT_MODIFY[QUEST_ID].isComplete)
        end)

        it("should update isComplete to -1 when quest with no objectives fails after being complete", function()
            questLogTitles = {
                [1] = {"Kill the Boss", 60, nil, false, false, 1, nil, QUEST_ID},
            }
            questObjectives = {
                [QUEST_ID] = {}
            }

            -- Step 1: Quest is complete — enters cache as isComplete=1
            local cacheMiss, changes = QuestLogCache.CheckForChanges(nil)
            assert.is_false(cacheMiss)
            assert.is_not_nil(changes[QUEST_ID])
            assert.is_equal(1, QuestLogCache.questLog_DO_NOT_MODIFY[QUEST_ID].isComplete)

            -- Step 2: Quest fails — Blizzard temporarily returns nil
            questLogTitles[1] = {"Kill the Boss", 60, nil, false, false, nil, nil, QUEST_ID}

            cacheMiss, changes = QuestLogCache.CheckForChanges(nil)
            assert.is_true(cacheMiss)
            assert.is_nil(changes[QUEST_ID])
            assert.is_equal(1, QuestLogCache.questLog_DO_NOT_MODIFY[QUEST_ID].isComplete)

            -- Step 3: Blizzard briefly returns 1
            questLogTitles[1] = {"Kill the Boss", 60, nil, false, false, 1, nil, QUEST_ID}

            cacheMiss, changes = QuestLogCache.CheckForChanges(nil)
            assert.is_false(cacheMiss)
            assert.is_nil(changes[QUEST_ID])
            assert.is_equal(1, QuestLogCache.questLog_DO_NOT_MODIFY[QUEST_ID].isComplete)

            -- Step 4: Blizzard settles on -1 (failed)
            questLogTitles[1] = {"Kill the Boss", 60, nil, false, false, -1, nil, QUEST_ID}

            cacheMiss, changes = QuestLogCache.CheckForChanges(nil)
            assert.is_false(cacheMiss)
            assert.is_not_nil(changes[QUEST_ID])
            assert.is_equal(-1, QuestLogCache.questLog_DO_NOT_MODIFY[QUEST_ID].isComplete)
        end)
    end)
end)
