dofile("setupTests.lua")

describe("QuestLogCache", function()
    ---@type QuestLogCache
    local QuestLogCache
    ---@type Sounds
    local Sounds

    local QUEST_ID = 1234

    local questLogTitles = {}
    local questObjectives = {}

    before_each(function()
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
                return questObjectives[questId] or {}
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

    describe("CheckForChanges", function()
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

            -- Step 2: Player deletes items — regression accepted because blizzardQuestCacheStale is false
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
