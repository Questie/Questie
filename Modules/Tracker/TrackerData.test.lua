dofile("setupTests.lua")

describe("TrackerData", function()
    local TrackerData, QuestieLib, QuestieDB, QuestiePlayer, QuestLogCache, compat
    local entries, cached, completion
    local originalGetNumEntries, originalGetTitle, originalGetIndex

    before_each(function()
        compat = QuestieLoader:ImportModule("QuestieCompat")
        originalGetNumEntries = compat.GetNumQuestLogEntries
        originalGetTitle = compat.GetQuestLogTitle
        originalGetIndex = compat.GetQuestLogIndexByID
        Questie.db.profile = {trimObjectiveText = true, trackerColorObjectives = "minimal"}
        entries = {
            {title = "Northshire Abbey", isHeader = true},
            {title = "Nibbled-On Book", id = 91741, level = 2},
        }
        cached = {}
        completion = 0
        compat.GetNumQuestLogEntries = function() return #entries end
        compat.GetQuestLogTitle = function(index)
            local entry = entries[index]
            if not entry then return nil end
            return entry.title, entry.level, nil, entry.isHeader, nil, entry.complete, nil, entry.id
        end
        compat.GetQuestLogIndexByID = function(id)
            for index, entry in ipairs(entries) do
                if entry.id == id then return index end
            end
        end
        QuestLogCache = QuestieLoader:ImportModule("QuestLogCache")
        QuestLogCache.TryGetQuest = function(id) return cached[id] end
        QuestLogCache.GetQuest = spy.new(function() error("Reporting getter must not be used for optional reads") end)
        QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
        QuestiePlayer.currentQuestlog = {}
        QuestiePlayer.GetPlayerLevel = function() return 2 end
        QuestieDB = QuestieLoader:ImportModule("QuestieDB")
        QuestieDB.IsComplete = function() return completion end
        QuestieDB.QueryNPCSingle = function() return "Wolf" end
        QuestieDB.QueryItemSingle = function() return "Note" end
        QuestieDB.IsPvPQuest = function() return false end
        QuestieLoader:ImportModule("QuestieEvent").IsEventQuest = function() return false end
        dofile("Localization/l10n.lua")
        dofile("Modules/Libs/QuestieLib.lua")
        QuestieLib = QuestieLoader:ImportModule("QuestieLib")
        QuestieLib.GetLoadedQuestObjectives = spy.new(function() error("Tracker must not load objectives") end)
        QuestieLib.GetLevelString = function(_, _, level) return "[" .. level .. "] " end
        dofile("Modules/Tracker/TrackerQuestieBehavior.lua")
        dofile("Modules/Tracker/TrackerData.lua")
        TrackerData = QuestieLoader:ImportModule("TrackerData")
    end)

    after_each(function()
        compat.GetNumQuestLogEntries = originalGetNumEntries
        compat.GetQuestLogTitle = originalGetTitle
        compat.GetQuestLogIndexByID = originalGetIndex
    end)

    it("builds native objective data and delegates quest completion without a temporary result", function()
        entries[2].complete = 1
        cached[91741] = {isComplete = 1, objectives = {
            [3] = {text = "Return the book.", raw_text = "Return the book.", type = "log",
                numFulfilled = 1, numRequired = 1, finished = true},
        }}
        local behavior = QuestieLoader:ImportModule("TrackerQuestieBehavior")
        behavior.Apply = spy.new(function(displayQuest, snapshot, nativeComplete)
            assert.are.equal("Nibbled-On Book", displayQuest.name)
            assert.are.equal("Northshire Abbey", displayQuest.zoneName)
            assert.is_nil(displayQuest.completionState)
            assert.is_nil(displayQuest.isComplete)
            assert.are.equal(1, nativeComplete)
            assert.are.equal("Return the book.", displayQuest.Objectives[1].Description)
            assert.are.equal(3, displayQuest.Objectives[1].NativeIndex)
            assert.are.equal(cached[91741], snapshot)
        end)
        QuestieDB.IsComplete = spy.new(function() error("Baseline must not query QuestieDB") end)
        QuestieDB.QueryNPCSingle = spy.new(function() error("Baseline must not query entities") end)

        local displayQuest = TrackerData.RefreshQuest(91741)

        assert.spy(behavior.Apply).was.called_with(displayQuest, cached[91741], 1)
        assert.spy(behavior.Apply).was.called(1)
        assert.spy(QuestieDB.IsComplete).was.not_called()
        assert.spy(QuestieDB.QueryNPCSingle).was.not_called()
    end)

    it("renders the live Nibbled-On Book objective without a database quest", function()
        cached[91741] = {objectives = {
            {text = "Return the book to Brother Paxton.", raw_text = "Return the book to Brother Paxton.",
                type = "log", numFulfilled = 1, numRequired = 1, finished = true},
        }}
        completion = 1

        local displayQuest = TrackerData.RefreshQuest(91741)

        assert.are.equal("Nibbled-On Book", displayQuest.name)
        assert.are.equal("Northshire Abbey", displayQuest.zoneName)
        assert.are.equal(2, displayQuest.level)
        assert.are.equal(1, displayQuest:IsComplete())
        assert.is_true(displayQuest.isComplete)
        assert.is_nil(displayQuest.enrichment)
        assert.are.equal("|cFFEEEEEE" .. "Return the book to Brother Paxton.", TrackerData.GetObjectiveText(displayQuest.Objectives[1]))
        assert.is_nil(QuestiePlayer.currentQuestlog[91741])
    end)

    it("keeps unfamiliar objective types readable rather than treating their numbers as counters", function()
        cached[91741] = {objectives = {{text = "Follow the apparition.", raw_text = "Follow the apparition.",
            type = "futureType", numFulfilled = 0, numRequired = 100, finished = false}}}

        local objective = TrackerData.RefreshQuest(91741).Objectives[1]

        assert.are.equal("futureType", objective.Type)
        assert.are.equal("|cFFEEEEEEFollow the apparition.", TrackerData.GetObjectiveText(objective))
    end)

    it("respects completion for unfamiliar types without interpreting their numeric fields", function()
        cached[91741] = {objectives = {{text = "Follow the apparition.", raw_text = "Follow the apparition.",
            type = "futureType", numFulfilled = 0, numRequired = 100, finished = true}}}

        local objective = TrackerData.RefreshQuest(91741).Objectives[1]

        assert.is_true(objective.Completed)
    end)

    it("uses the normalized cache instead of overwriting it with another client read", function()
        cached[91741] = {objectives = {{text = "Wolf", raw_text = "Wolf: 3/5", type = "monster", numFulfilled = 3, numRequired = 5}}}

        local objective = TrackerData.RefreshQuest(91741).Objectives[1]

        assert.are.equal(3, objective.Collected)
        assert.spy(QuestieLib.GetLoadedQuestObjectives).was.not_called()
    end)

    it("keeps objectives after omitted cache rows in native order with their original enrichment", function()
        local original = {Id = 10, Index = 3, Type = "monster", spawnList = {}}
        local otherOriginal = {Id = 20, Index = 1, Type = "monster", spawnList = {}}
        cached[91741] = {objectives = {
            [3] = {text = "Wolf", raw_text = "Wolf slain: 2/5", type = "monster", numFulfilled = 2, numRequired = 5},
            [5] = {text = "Read the book.", raw_text = "Read the book.", type = "log", finished = false},
        }}
        QuestiePlayer.currentQuestlog[91741] = {
            Objectives = {[1] = otherOriginal, [3] = original},
            ObjectiveData = {[1] = {Id = 20, Type = "monster"}, [3] = {Id = 10, Type = "monster"}},
        }

        local displayQuest = TrackerData.RefreshQuest(91741)

        assert.are.equal(2, #displayQuest.Objectives)
        assert.are.equal(1, displayQuest.Objectives[1].Index)
        assert.are.equal(3, displayQuest.Objectives[1].NativeIndex)
        assert.are.equal(original, displayQuest.Objectives[1].enrichment)
        assert.are.equal("Read the book.", displayQuest.Objectives[2].Description)
        assert.are.equal(2, displayQuest.Objectives[2].Index)
    end)

    for _, trimObjectiveText in ipairs({true, false}) do
        it("preserves native counter placement and punctuation with trimObjectiveText = " .. tostring(trimObjectiveText), function()
            Questie.db.profile.trimObjectiveText = trimObjectiveText
            cached[91741] = {objectives = {{text = "Windstone Cluster", raw_text = "9/15 Windstone Cluster.",
                type = "item", numFulfilled = 9, numRequired = 15, finished = false}}}

            local objective = TrackerData.RefreshQuest(91741).Objectives[1]

            assert.are.equal("9/15 Windstone Cluster.", objective.Description)
            assert.are.equal("|cFFEEEEEE9/15 Windstone Cluster.", TrackerData.GetObjectiveText(objective))
            assert.are.equal("Windstone Cluster", cached[91741].objectives[1].text)
        end)
    end

    it("keeps partial-progress colors without rebuilding the text from counts", function()
        Questie.db.profile.trackerColorObjectives = "redToGreen"
        cached[91741] = {objectives = {{text = "Wolf", raw_text = "Wolf slain: 1/4", type = "monster",
            numFulfilled = 1, numRequired = 4, finished = false}}}

        local objective = TrackerData.RefreshQuest(91741).Objectives[1]

        assert.are.equal("|cFFfe7f00Wolf slain: 1/4", TrackerData.GetObjectiveText(objective))
    end)

    it("uses cached completion for counted objectives even when their counts disagree", function()
        Questie.db.profile.trackerColorObjectives = "whiteAndGreen"
        cached[91741] = {objectives = {{text = "Wolf", raw_text = "Wolf slain: 3/5", type = "monster",
            numFulfilled = 3, numRequired = 5, finished = true, raw_finished = false}}}

        local objective = TrackerData.RefreshQuest(91741).Objectives[1]

        assert.is_true(objective.Completed)
        assert.are.equal("|cFF28ff28Wolf slain: 3/5", TrackerData.GetObjectiveText(objective))
    end)

    it("shows the title while the initial cache load is pending", function()
        local displayQuest = TrackerData.RefreshQuest(91741)

        assert.are.equal("Nibbled-On Book", displayQuest.name)
        assert.is_false(displayQuest.objectivesLoaded)
        assert.are.equal(0, displayQuest:IsComplete())
        assert.are.same({}, displayQuest.Objectives)
    end)

    it("uses the first cached objectives without replacing the quest record", function()
        local displayQuest = TrackerData.RefreshQuest(91741)
        cached[91741] = {objectives = {{text = "Inspect the book.", raw_text = "Inspect the book.",
            type = "event", numFulfilled = 0, numRequired = 0, finished = false}}}

        assert.are.equal(displayQuest, TrackerData.RefreshQuest(91741))
        assert.is_true(displayQuest.objectivesLoaded)
        assert.are.equal("Inspect the book.", displayQuest.Objectives[1].Description)
        assert.are.equal("|cFFEEEEEEInspect the book.", TrackerData.GetObjectiveText(displayQuest.Objectives[1]))
    end)

    it("refreshes native text and progress without replacing the display row", function()
        cached[91741] = {objectives = {{text = "Windstone Cluster", raw_text = "9/15 Windstone Cluster", type = "item",
            numFulfilled = 9, numRequired = 15, finished = false}}}
        local displayQuest = TrackerData.RefreshQuest(91741)
        local objective = displayQuest.Objectives[1]
        cached[91741].objectives[1] = {text = "Windstone Cluster", raw_text = "10/15 Windstone Cluster", type = "item",
            numFulfilled = 10, numRequired = 15, finished = false}

        TrackerData.Refresh()

        assert.are.equal(objective, displayQuest.Objectives[1])
        assert.is_true(displayQuest.objectivesLoaded)
        assert.are.equal(10, objective.Collected)
        assert.are.equal("|cFFEEEEEE10/15 Windstone Cluster", TrackerData.GetObjectiveText(objective))
    end)

    it("uses existing completion behavior rather than inferring completion from an empty list", function()
        cached[91741] = {objectives = {}}

        local displayQuest = TrackerData.RefreshQuest(91741)

        assert.is_true(displayQuest.objectivesLoaded)
        assert.are.equal(0, displayQuest:IsComplete())
        assert.is_false(displayQuest.isComplete)
    end)

    it("uses native membership even if a removed quest remains in the objective cache", function()
        cached[91741] = {objectives = {}}
        TrackerData.Refresh()
        entries = {}

        assert.is_false(TrackerData.ContainsQuest(91741))
        assert.is_nil(TrackerData.RefreshQuest(91741))
        assert.are.same({}, TrackerData.GetQuests())
    end)

    it("forgets an explicitly removed snapshot before the quest is accepted again", function()
        cached[91741] = {objectives = {{text = "Inspect the book.", raw_text = "Inspect the book.", type = "event", finished = true}}}
        local previous = TrackerData.RefreshQuest(91741)
        TrackerData.RemoveQuest(91741)
        assert.is_nil(TrackerData.GetQuest(91741))
        cached[91741] = nil

        local current = TrackerData.RefreshQuest(91741)

        assert.are_not.equal(previous, current)
        assert.is_false(current.objectivesLoaded)
        assert.are.same({}, current.Objectives)
    end)

    it("preserves Questie's additional completion boolean independently of the numeric state", function()
        cached[91741] = {objectives = {}}
        QuestiePlayer.currentQuestlog[91741] = {isComplete = true, Objectives = {}}

        local displayQuest = TrackerData.RefreshQuest(91741)

        assert.are.equal(0, displayQuest:IsComplete())
        assert.is_true(displayQuest.isComplete)
    end)

    it("gives failure precedence over the additional completion boolean", function()
        cached[91741] = {objectives = {}}
        completion = -1
        QuestiePlayer.currentQuestlog[91741] = {isComplete = true, Objectives = {}}

        local displayQuest = TrackerData.RefreshQuest(91741)

        assert.are.equal(-1, displayQuest:IsComplete())
        assert.is_false(displayQuest.isComplete)
    end)

    it("updates failure even while objectives are unavailable", function()
        entries[2].complete = -1

        local displayQuest = TrackerData.RefreshQuest(91741)

        assert.are.equal(-1, displayQuest:IsComplete())
        assert.is_false(displayQuest.isComplete)
    end)

    it("retains indexed objective enrichment without mutating its original map object", function()
        local original = {Id = 10, Type = "monster", Description = "Wolf", spawnList = {{name = "Wolf"}}}
        QuestiePlayer.currentQuestlog[91741] = {
            Objectives = {original}, ObjectiveData = {{Id = 10, Type = "monster"}}, SpecialObjectives = {},
        }
        cached[91741] = {objectives = {{text = "Wolf", raw_text = "Wolf: 2/5", type = "monster", numFulfilled = 2, numRequired = 5}}}

        local displayQuest = TrackerData.RefreshQuest(91741)
        local objective = displayQuest.Objectives[1]

        assert.are.equal(original, objective.enrichment)
        assert.are.equal(original.spawnList, objective.spawnList)
        assert.are.equal(2, objective.Collected)
        assert.is_nil(original.Collected)
        assert.are.equal("|cFFEEEEEEWolf: 2/5", TrackerData.GetObjectiveText(objective))

        dofile("Modules/Libs/DistanceUtils.lua")
        local DistanceUtils = QuestieLoader:ImportModule("DistanceUtils")
        DistanceUtils.GetNearestObjective = spy.new(function() return {10, 20}, 12, "Wolf", 100 end)

        local spawn = DistanceUtils.GetNearestSpawnForQuest(displayQuest)

        assert.are.same({10, 20}, spawn)
        assert.spy(DistanceUtils.GetNearestObjective).was.called_with(original.spawnList)
    end)

    it("keeps native wording and progress when the indexed database objective has different wording", function()
        local original = {Id = 10, Type = "monster", Description = "Database wording"}
        local metadata = {Id = 10, Type = "monster", Text = "Database wording"}
        local specialObjectives = {{Id = 99}}
        QuestiePlayer.currentQuestlog[91741] = {
            Objectives = {original}, ObjectiveData = {metadata}, SpecialObjectives = specialObjectives,
        }
        cached[91741] = {objectives = {{text = "Boar", raw_text = "Boar: 1/4", type = "monster", numFulfilled = 1, numRequired = 4}}}

        local displayQuest = TrackerData.RefreshQuest(91741)

        assert.are.equal(original, displayQuest.Objectives[1].enrichment)
        assert.are.equal(10, displayQuest.Objectives[1].Id)
        assert.are.equal(metadata, displayQuest.ObjectiveData[1])
        assert.are.equal(specialObjectives, displayQuest.SpecialObjectives)
        assert.are.equal("|cFFEEEEEEBoar: 1/4", TrackerData.GetObjectiveText(displayQuest.Objectives[1]))
    end)

    it("renders new live objectives absent from an otherwise known database quest", function()
        QuestiePlayer.currentQuestlog[91741] = {Objectives = {}, ObjectiveData = {}}
        cached[91741] = {objectives = {{text = "Read the note.", raw_text = "Read the note.", type = "log", numFulfilled = 0, numRequired = 1}}}

        local displayQuest = TrackerData.RefreshQuest(91741)

        assert.are.equal(1, #displayQuest.Objectives)
        assert.is_nil(displayQuest.Objectives[1].enrichment)
        assert.are.equal("Read the note.", displayQuest.Objectives[1].Description)
    end)

    it("preserves the existing missing-source-item synthetic objective", function()
        local original = {
            Id = 44, Type = "item", Description = "Note", FullDescription = "Verner's Note",
            Needed = 1, Collected = 0, Completed = false, spawnList = {},
        }
        QuestiePlayer.currentQuestlog[91741] = {sourceItemId = 44, Objectives = {original}}
        cached[91741] = {objectives = {}}

        local displayQuest = TrackerData.RefreshQuest(91741)

        assert.are.equal(original, displayQuest.Objectives[1].enrichment)
        assert.are.equal(1, displayQuest.Objectives[1].Index)
        assert.are.equal(91741, displayQuest.Objectives[1].questId)
        assert.is_nil(original.Index)
        assert.are.equal(original.spawnList, displayQuest.Objectives[1].spawnList)
        assert.is_false(displayQuest.Objectives[1].Completed)
        assert.are.equal("|cFFEEEEEENote: 0/1", TrackerData.GetObjectiveText(displayQuest.Objectives[1]))
    end)

    it("does not infer unfamiliar objective completion from equal numeric fields", function()
        cached[91741] = {objectives = {{text = "Follow the apparition.", raw_text = "Follow the apparition.",
            type = "futureType", numFulfilled = 1, numRequired = 1, finished = false}}}

        local objective = TrackerData.RefreshQuest(91741).Objectives[1]

        assert.is_false(objective.Completed)
        assert.are.equal("|cFFEEEEEEFollow the apparition.", TrackerData.GetObjectiveText(objective))
    end)

    it("does not let additional completion hide a live objective whose database metadata is missing", function()
        QuestiePlayer.currentQuestlog[91741] = {
            isComplete = true, Objectives = {{Id = 10, Type = "monster"}},
            ObjectiveData = {},
        }
        cached[91741] = {objectives = {{text = "Boar", raw_text = "Boar: 0/4", type = "monster", numFulfilled = 0, numRequired = 4, finished = false}}}

        local displayQuest = TrackerData.RefreshQuest(91741)

        assert.are.equal(0, displayQuest:IsComplete())
        assert.is_false(displayQuest.isComplete)
        assert.is_false(displayQuest.Objectives[1].Completed)
    end)

    it("keeps additional completion for objectives with indexed enrichment", function()
        QuestiePlayer.currentQuestlog[91741] = {
            isComplete = true, Objectives = {{Id = 10, Type = "monster"}},
            ObjectiveData = {{Id = 10, Type = "monster"}},
        }
        cached[91741] = {objectives = {{text = "Wolf", raw_text = "Wolf: 4/4", type = "monster", numFulfilled = 4, numRequired = 4, finished = true}}}

        local displayQuest = TrackerData.RefreshQuest(91741)

        assert.are.equal(0, displayQuest:IsComplete())
        assert.is_true(displayQuest.isComplete)
    end)

    it("does not report an error for an initial objective cache miss", function()
        local displayQuest = TrackerData.RefreshQuest(91741)

        assert.is_false(displayQuest.objectivesLoaded)
        assert.spy(QuestLogCache.GetQuest).was.not_called()
        assert.spy(QuestieLib.GetLoadedQuestObjectives).was.not_called()
    end)

    it("reads individual and full snapshots without fetching or checking native membership", function()
        assert.is_nil(TrackerData.GetQuest(91741)) -- A getter does not initialize a native quest.
        local snapshot = TrackerData.Refresh()
        local displayQuest = snapshot[91741]
        compat.GetNumQuestLogEntries = spy.new(function() return #entries end)
        compat.GetQuestLogTitle = spy.new(compat.GetQuestLogTitle)
        compat.GetQuestLogIndexByID = spy.new(compat.GetQuestLogIndexByID)
        QuestieDB.IsComplete = spy.new(function() return completion end)
        entries = {} -- Only an explicit refresh or lifecycle removal can change the snapshot.

        assert.are.equal(displayQuest, TrackerData.GetQuest(91741))
        assert.is_nil(TrackerData.GetQuest(123))
        assert.are.equal(snapshot, TrackerData.GetQuests())
        assert.are.equal(snapshot, TrackerData.GetQuests())
        assert.spy(compat.GetNumQuestLogEntries).was.not_called()
        assert.spy(compat.GetQuestLogTitle).was.not_called()
        assert.spy(compat.GetQuestLogIndexByID).was.not_called()
        assert.spy(QuestieLib.GetLoadedQuestObjectives).was.not_called()
        assert.spy(QuestieDB.IsComplete).was.not_called()
    end)

    it("only applies new progress and metadata when explicitly refreshed", function()
        cached[91741] = {objectives = {{text = "Wolf", raw_text = "Wolf: 1/5", type = "monster", numFulfilled = 1, numRequired = 5}}}
        local displayQuest = TrackerData.RefreshQuest(91741)
        entries[2].title = "A new chapter"
        cached[91741].objectives[1].numFulfilled = 3

        assert.are.equal(displayQuest, TrackerData.GetQuest(91741))
        assert.are.equal("Nibbled-On Book", displayQuest.name)
        assert.are.equal(1, displayQuest.Objectives[1].Collected)
        assert.are.equal(displayQuest, TrackerData.RefreshQuest(91741))
        assert.are.equal("A new chapter", displayQuest.name)
        assert.are.equal(3, displayQuest.Objectives[1].Collected)
    end)

    it("refreshes a single quest without refreshing another quest's objectives or completion", function()
        entries[3] = {title = "Another quest", id = 123, level = 2}
        cached[91741] = {objectives = {{text = "Read the book.", raw_text = "Read the book.", type = "log", finished = false}}}
        cached[123] = {objectives = {{text = "Speak to the librarian.", raw_text = "Speak to the librarian.", type = "log", finished = false}}}
        TrackerData.Refresh()
        QuestieDB.IsComplete = spy.new(function() return 0 end)
        compat.GetNumQuestLogEntries = spy.new(function() return #entries end)
        local otherObjective = TrackerData.GetQuests()[123].Objectives[1]

        TrackerData.RefreshQuest(91741)

        assert.spy(QuestieDB.IsComplete).was.called(1)
        assert.spy(QuestieDB.IsComplete).was.called_with(91741)
        assert.spy(QuestieLib.GetLoadedQuestObjectives).was.not_called()
        assert.spy(compat.GetNumQuestLogEntries).was.not_called()
        assert.are.equal(otherObjective, TrackerData.GetQuests()[123].Objectives[1])
    end)

    it("includes pending quests in a full snapshot without fetching their objectives", function()
        entries[3] = {title = "Another quest", id = 123, level = 2}

        local snapshot = TrackerData.Refresh()

        assert.is_not_nil(snapshot[91741])
        assert.is_not_nil(snapshot[123])
        assert.spy(QuestieLib.GetLoadedQuestObjectives).was.not_called()
        entries = {}
        assert.are.same({}, TrackerData.Refresh())
    end)

    it("drops stale map references when enrichment disappears but cached progress remains", function()
        local original = {Id = 10, Type = "monster", Description = "Wolf", spawnList = {{name = "Wolf"}}}
        QuestiePlayer.currentQuestlog[91741] = {
            Objectives = {original}, ObjectiveData = {{Id = 10, Type = "monster"}}, SpecialObjectives = {{Id = 99}},
        }
        cached[91741] = {objectives = {{text = "Wolf", raw_text = "Wolf: 2/5", type = "monster", numFulfilled = 2, numRequired = 5}}}
        local displayQuest = TrackerData.RefreshQuest(91741)
        QuestiePlayer.currentQuestlog[91741] = nil

        TrackerData.RefreshQuest(91741)

        assert.is_nil(displayQuest.enrichment)
        assert.is_nil(displayQuest.Objectives[1].enrichment)
        assert.are.same({}, displayQuest.Objectives[1].spawnList)
        assert.are.same({}, displayQuest.ObjectiveData)
        assert.are.same({}, displayQuest.SpecialObjectives)
        assert.are.equal("|cFFEEEEEEWolf: 2/5", TrackerData.GetObjectiveText(displayQuest.Objectives[1]))
    end)

    describe("loading through the real quest cache and event handler", function()
        local QuestEventHandler, QuestLifecycle
        local originalQuestLog, originalHaveData, originalTimer, originalTime, originalForever
        local nativeObjectives, haveData, callbacks, retryTimers, now

        before_each(function()
            originalQuestLog, originalHaveData = _G.C_QuestLog, _G.HaveQuestData
            originalTimer, originalTime, originalForever = _G.C_Timer, _G.GetTime, Questie.IsForever
            nativeObjectives, haveData, callbacks, retryTimers, now = nil, true, {}, {}, 100
            _G.C_QuestLog = {GetQuestObjectives = spy.new(function() return nativeObjectives end)}
            _G.HaveQuestData = function() return haveData end
            _G.GetTime = function() return now end
            _G.C_Timer = {
                After = function(_, callback) callbacks[#callbacks + 1] = callback end,
                NewTicker = function() return {Cancel = function() end} end,
                NewTimer = function(delay, callback)
                    local timer = {delay = delay, callback = callback, Cancel = spy.new(function() end)}
                    retryTimers[#retryTimers + 1] = timer
                    return timer
                end,
            }
            Questie.IsForever = true
            Questie.db.profile.autoAccept = {enabled = false}
            local sounds = QuestieLoader:ImportModule("Sounds")
            sounds.PlayQuestComplete = function() end
            sounds.PlayObjectiveComplete = function() end
            sounds.PlayObjectiveProgress = function() end

            dofile("Modules/Quest/QuestLogCache.lua")
            QuestLogCache = QuestieLoader:ImportModule("QuestLogCache")
            QuestieDB.IsComplete = function(id) return QuestLogCache.GetQuest(id).isComplete end
            QuestieDB.GetQuest = function() return nil end
            QuestieLib.RepairMissingItemNames = function() end
            local questModule = QuestieLoader:ImportModule("QuestieQuest")
            questModule.SetObjectivesDirty = function() end
            questModule.UpdateQuest = function() end
            QuestLifecycle = QuestieLoader:ImportModule("QuestLifecycle")
            QuestLifecycle.AcceptQuest = spy.new(function() end)
            QuestieLoader:ImportModule("QuestieJourney").AcceptQuest = function() end
            QuestieLoader:ImportModule("QuestieAnnounce").AcceptedQuest = function() end
            QuestieLoader:ImportModule("QuestieNameplate").UpdateNameplate = function() end
            QuestieLoader:ImportModule("QuestiePartyObjectives").ScheduleUpdate = function() end
            QuestieLoader:ImportModule("BreadcrumbQuests").CheckQuestBreadcrumbs = function() end
            dofile("Public/Enums.lua")
            QuestieLoader:ImportModule("QuestieAPI").PropagateQuestUpdate = function() end
            QuestieLoader:ImportModule("QuestieCombatQueue").Queue = function(_, callback) callback() end
            local tracker = QuestieLoader:ImportModule("QuestieTracker")
            tracker.Update = function() TrackerData.Refresh() end
            tracker.UpdateQuestLines = function(id) TrackerData.RefreshQuest(id) end
            dofile("Modules/EventHandler/QuestEventHandler.lua")
            QuestEventHandler = QuestieLoader:ImportModule("QuestEventHandler")
        end)

        after_each(function()
            _G.C_QuestLog, _G.HaveQuestData = originalQuestLog, originalHaveData
            _G.C_Timer, _G.GetTime, Questie.IsForever = originalTimer, originalTime, originalForever
        end)

        it("keeps Falling With Style unfinished at 1/1 until the cached finished flag changes", function()
            entries[2] = {title = "Falling With Style", id = 92474, level = 2}
            Questie.db.profile.trackerColorObjectives = "whiteAndGreen"
            nativeObjectives = {{text = "Use Walk on Air", type = "object", numFulfilled = 1, numRequired = 1, finished = false}}
            QuestLogCache.CheckForChanges(nil)

            local displayQuest = TrackerData.RefreshQuest(92474)
            local objective = displayQuest.Objectives[1]

            assert.is_false(objective.Completed)
            assert.are.equal(0, displayQuest:IsComplete())
            assert.are.equal("|cFFedededUse Walk on Air", TrackerData.GetObjectiveText(objective))
            assert.is_false(QuestLogCache.GetQuest(92474).objectives[1].finished)

            nativeObjectives[1].finished = true
            QuestLogCache.CheckForChanges(nil)
            TrackerData.RefreshQuest(92474)

            assert.are.equal(objective, displayQuest.Objectives[1])
            assert.is_true(objective.Completed)
            assert.are.equal("|cFF28ff28Use Walk on Air", TrackerData.GetObjectiveText(objective))
        end)

        it("recovers an unknown login quest without another Blizzard event", function()
            haveData = false
            local cacheMiss, _, checked = QuestLogCache.CheckForChanges(nil)
            assert.is_true(cacheMiss)
            -- Initialization records every checked quest, even when its first cache fill missed.
            QuestEventHandler.InitQuestLogStates(checked)
            local displayQuest = TrackerData.Refresh()[91741]
            assert.are.equal("Nibbled-On Book", displayQuest.name)
            assert.is_false(displayQuest.objectivesLoaded)

            QuestEventHandler.QuestWatchUpdate(91741)
            now = 130 -- Timer delivery may be late; its callback must refresh the expired marker.
            haveData = true
            nativeObjectives = {{text = " ", type = "log", numFulfilled = 0, numRequired = 1, finished = false}}
            retryTimers[1].callback()
            assert.is_false(displayQuest.objectivesLoaded)
            assert.are.equal(2, #retryTimers)

            now = 160
            nativeObjectives = {{text = "Read the book.", type = "log", numFulfilled = 0, numRequired = 1, finished = false}}
            retryTimers[2].callback()
            assert.are.equal(2, #retryTimers)

            assert.is_true(displayQuest.objectivesLoaded)
            assert.are.equal("|cFFEEEEEERead the book.", TrackerData.GetObjectiveText(displayQuest.Objectives[1]))
            assert.is_nil(displayQuest.enrichment)
            assert.is_nil(QuestiePlayer.currentQuestlog[91741])
            _G.C_QuestLog.GetQuestObjectives:clear()
            TrackerData.Refresh()
            TrackerData.RefreshQuest(91741)
            assert.spy(_G.C_QuestLog.GetQuestObjectives).was.not_called()
        end)

        it("finishes acceptance after both initial reads miss and the fallback loads the objectives", function()
            QuestEventHandler.QuestAccepted(2, 91741)
            callbacks[1]()
            local displayQuest = TrackerData.GetQuests()[91741]
            assert.is_false(displayQuest.objectivesLoaded)
            assert.spy(QuestLifecycle.AcceptQuest).was.not_called()

            now = 130
            entries[2].complete = 1
            nativeObjectives = {{text = "Return the book.", type = "log", numFulfilled = 1, numRequired = 1, finished = true}}
            retryTimers[1].callback()
            assert.are.equal(1, #retryTimers)

            assert.is_true(displayQuest.objectivesLoaded)
            assert.are.equal(1, displayQuest:IsComplete())
            assert.is_true(displayQuest.Objectives[1].Completed)
            assert.spy(QuestLifecycle.AcceptQuest).was.called(1)
            assert.is_nil(QuestiePlayer.currentQuestlog[91741])
        end)

        it("renders cached progress through unavailable responses and loading-screen regressions", function()
            nativeObjectives = {{text = "Wolf slain: 3/5", type = "monster", numFulfilled = 3, numRequired = 5, finished = false}}
            QuestLogCache.CheckForChanges(nil)
            local displayQuest = TrackerData.Refresh()[91741]
            local cachedQuest = QuestLogCache.GetQuest(91741)
            QuestLogCache.OnLoadingScreenEnabled()
            nativeObjectives = nil
            assert.is_true(QuestLogCache.CheckForChanges(nil))
            TrackerData.Refresh()
            assert.are.equal(3, displayQuest.Objectives[1].Collected)
            assert.are.equal(cachedQuest, QuestLogCache.GetQuest(91741))
            assert.are.equal("|cFFEEEEEEWolf slain: 3/5", TrackerData.GetObjectiveText(displayQuest.Objectives[1]))

            nativeObjectives = {{text = " ", type = "monster", numFulfilled = 0, numRequired = 5, finished = false}}
            assert.is_true(QuestLogCache.CheckForChanges(nil))
            TrackerData.Refresh()
            assert.are.equal(3, displayQuest.Objectives[1].Collected)

            nativeObjectives = {{text = "Wolf slain: 0/5", numFulfilled = 0, numRequired = 5, finished = false}}
            assert.is_true(QuestLogCache.CheckForChanges(nil))
            TrackerData.Refresh()
            assert.are.equal(3, displayQuest.Objectives[1].Collected)

            nativeObjectives = {{text = "Wolf slain: 0/5", type = "monster", numFulfilled = 0, numRequired = 5, finished = false}}
            assert.is_true(QuestLogCache.CheckForChanges(nil))
            TrackerData.Refresh()
            assert.are.equal(3, displayQuest.Objectives[1].Collected)
            assert.are.equal("|cFFEEEEEEWolf slain: 3/5", TrackerData.GetObjectiveText(displayQuest.Objectives[1]))

            nativeObjectives = {{text = "Wolf slain: 4/5", type = "monster", numFulfilled = 4, numRequired = 5, finished = false}}
            assert.is_false(QuestLogCache.CheckForChanges(nil))
            TrackerData.Refresh()
            assert.are.equal(4, displayQuest.Objectives[1].Collected)
            assert.are.equal("|cFFEEEEEEWolf slain: 4/5", TrackerData.GetObjectiveText(displayQuest.Objectives[1]))
        end)

        it("does not load or redisplay a pending quest removed before its retry", function()
            QuestEventHandler.QuestAccepted(2, 91741)
            QuestEventHandler.QuestRemoved(91741)
            entries = {}
            nativeObjectives = {{text = "Return the book.", type = "log", numFulfilled = 1, numRequired = 1, finished = true}}
            _G.C_QuestLog.GetQuestObjectives:clear()

            callbacks[1]()
            now = 130
            retryTimers[1].callback()

            assert.are.equal(1, #retryTimers)
            assert.is_nil(QuestLogCache.questLog_DO_NOT_MODIFY[91741])
            assert.is_nil(TrackerData.GetQuests()[91741])
            assert.spy(QuestLifecycle.AcceptQuest).was.not_called()
            assert.spy(_G.C_QuestLog.GetQuestObjectives).was.not_called()
        end)
    end)

    it("uses the player level for the native scaling-level sentinel", function()
        entries[2].level = -1
        QuestiePlayer.GetPlayerLevel = function() return 42 end

        assert.are.equal(42, TrackerData.RefreshQuest(91741).level)
    end)

    it("formats titles and chat links from the live name and level", function()
        local displayQuest = TrackerData.RefreshQuest(91741)
        Questie.db.profile.trackerShowQuestLevel = true

        assert.are.equal("|cFFFFFF00[2] Nibbled-On Book|r", TrackerData.GetColoredQuestName(displayQuest, true, false))
        assert.are.equal("[[2] Nibbled-On Book (91741)]", TrackerData.GetQuestLink(displayQuest))
    end)
end)
