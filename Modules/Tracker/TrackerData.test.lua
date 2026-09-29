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
        QuestLogCache.questLog_DO_NOT_MODIFY = cached
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
        dofile("Modules/Tracker/TrackerData.lua")
        TrackerData = QuestieLoader:ImportModule("TrackerData")
    end)

    after_each(function()
        compat.GetNumQuestLogEntries = originalGetNumEntries
        compat.GetQuestLogTitle = originalGetTitle
        compat.GetQuestLogIndexByID = originalGetIndex
    end)

    it("renders the live Nibbled-On Book objective without a database quest", function()
        cached[91741] = {objectives = {
            {text = "Return the book to Brother Paxton.", raw_text = "Return the book to Brother Paxton.",
                type = "log", numFulfilled = 1, numRequired = 1, finished = true},
        }}
        completion = 1

        local quest = TrackerData.GetQuest(91741)

        assert.are.equal("Nibbled-On Book", quest.name)
        assert.are.equal("Northshire Abbey", quest.zoneName)
        assert.are.equal(2, quest.level)
        assert.are.equal(1, quest:IsComplete())
        assert.is_true(quest.isComplete)
        assert.is_nil(quest.enrichment)
        assert.are.equal("|cFFEEEEEE" .. "Return the book to Brother Paxton", TrackerData.GetObjectiveText(quest.Objectives[1]))
        assert.is_nil(QuestiePlayer.currentQuestlog[91741])
    end)

    it("keeps unfamiliar objective types readable rather than treating their numbers as counters", function()
        cached[91741] = {objectives = {{text = "Follow the apparition.", type = "futureType", numFulfilled = 0, numRequired = 100, finished = false}}}

        local objective = TrackerData.GetQuest(91741).Objectives[1]

        assert.are.equal("futureType", objective.Type)
        assert.are.equal("|cFFEEEEEEFollow the apparition", TrackerData.GetObjectiveText(objective))
    end)

    it("respects completion for unfamiliar types without interpreting their numeric fields", function()
        cached[91741] = {objectives = {{text = "Follow the apparition.", type = "futureType", numFulfilled = 0, numRequired = 100, finished = true}}}

        local objective = TrackerData.GetQuest(91741).Objectives[1]

        assert.is_true(objective.Completed)
    end)

    it("uses the normalized cache instead of overwriting it with another client read", function()
        cached[91741] = {objectives = {{text = "Wolf", raw_text = "Wolf: 3/5", type = "monster", numFulfilled = 3, numRequired = 5}}}

        local objective = TrackerData.GetQuest(91741).Objectives[1]

        assert.are.equal(3, objective.Collected)
        assert.spy(QuestieLib.GetLoadedQuestObjectives).was.not_called()
    end)

    it("keeps objectives after omitted cache rows in native order with their original enrichment", function()
        local original = {Id = 10, Index = 3, Type = "monster", spawnList = {}}
        cached[91741] = {objectives = {
            [3] = {text = "Wolf", type = "monster", numFulfilled = 2, numRequired = 5},
            [5] = {text = "Read the book.", type = "log", finished = false},
        }}
        QuestiePlayer.currentQuestlog[91741] = {
            Objectives = {[3] = original}, ObjectiveData = {[3] = {Id = 10, Type = "monster"}},
        }

        local quest = TrackerData.GetQuest(91741)

        assert.are.equal(2, #quest.Objectives)
        assert.are.equal(1, quest.Objectives[1].Index)
        assert.are.equal(3, quest.Objectives[1].NativeIndex)
        assert.are.equal(original, quest.Objectives[1].enrichment)
        assert.are.equal("Read the book.", quest.Objectives[2].Description)
        assert.are.equal(2, quest.Objectives[2].Index)
    end)

    it("shows full wording when objective trimming is disabled", function()
        Questie.db.profile.trimObjectiveText = false
        cached[91741] = {objectives = {{text = "Wolf", raw_text = "Wolf slain: 3/5", type = "monster", numFulfilled = 3, numRequired = 5}}}

        local objective = TrackerData.GetQuest(91741).Objectives[1]

        assert.are.equal("|cFFEEEEEEWolf slain: 3/5", TrackerData.GetObjectiveText(objective))
    end)

    it("shows the title while the initial cache load is pending", function()
        local quest = TrackerData.GetQuest(91741)

        assert.are.equal("Nibbled-On Book", quest.name)
        assert.is_false(quest.objectivesLoaded)
        assert.are.equal(0, quest:IsComplete())
        assert.are.same({}, quest.Objectives)
    end)

    it("uses the first cached objectives without replacing the quest record", function()
        local quest = TrackerData.GetQuest(91741)
        cached[91741] = {objectives = {{text = "Inspect the book.", type = "event", numFulfilled = 0, numRequired = 0, finished = false}}}

        assert.are.equal(quest, TrackerData.GetQuest(91741))
        assert.is_true(quest.objectivesLoaded)
        assert.are.equal("Inspect the book.", quest.Objectives[1].Description)
        assert.are.equal("|cFFEEEEEEInspect the book", TrackerData.GetObjectiveText(quest.Objectives[1]))
    end)

    it("preserves row identity when refreshing the same cached objective", function()
        cached[91741] = {objectives = {{text = "Inspect the book.", type = "event", numFulfilled = 0, numRequired = 0, finished = false}}}
        local quest = TrackerData.GetQuest(91741)
        local objective = quest.Objectives[1]

        TrackerData.Refresh()

        assert.are.equal(objective, quest.Objectives[1])
        assert.is_true(quest.objectivesLoaded)
    end)

    it("uses existing completion behavior rather than inferring completion from an empty list", function()
        cached[91741] = {objectives = {}}

        local quest = TrackerData.GetQuest(91741)

        assert.is_true(quest.objectivesLoaded)
        assert.are.equal(0, quest:IsComplete())
        assert.is_false(quest.isComplete)
    end)

    it("uses native membership even if a removed quest remains in the objective cache", function()
        cached[91741] = {objectives = {}}
        TrackerData.Refresh()
        entries = {}

        assert.is_false(TrackerData.ContainsQuest(91741))
        assert.is_nil(TrackerData.GetQuest(91741))
        assert.are.same({}, TrackerData.GetQuests())
    end)

    it("forgets an explicitly removed snapshot before the quest is accepted again", function()
        cached[91741] = {objectives = {{text = "Inspect the book.", type = "event", finished = true}}}
        local previous = TrackerData.GetQuest(91741)
        TrackerData.RemoveQuest(91741)
        cached[91741] = nil

        local current = TrackerData.GetQuest(91741)

        assert.are_not.equal(previous, current)
        assert.is_false(current.objectivesLoaded)
        assert.are.same({}, current.Objectives)
    end)

    it("preserves Questie's additional completion boolean independently of the numeric state", function()
        cached[91741] = {objectives = {}}
        QuestiePlayer.currentQuestlog[91741] = {isComplete = true, Objectives = {}}

        local quest = TrackerData.GetQuest(91741)

        assert.are.equal(0, quest:IsComplete())
        assert.is_true(quest.isComplete)
    end)

    it("gives failure precedence over the additional completion boolean", function()
        cached[91741] = {objectives = {}}
        completion = -1
        QuestiePlayer.currentQuestlog[91741] = {isComplete = true, Objectives = {}}

        local quest = TrackerData.GetQuest(91741)

        assert.are.equal(-1, quest:IsComplete())
        assert.is_false(quest.isComplete)
    end)

    it("updates failure even while objectives are unavailable", function()
        entries[2].complete = -1

        local quest = TrackerData.GetQuest(91741)

        assert.are.equal(-1, quest:IsComplete())
        assert.is_false(quest.isComplete)
    end)

    it("retains verified objective enrichment without mutating its original map object", function()
        local original = {Id = 10, Type = "monster", Description = "Wolf", spawnList = {{name = "Wolf"}}}
        QuestiePlayer.currentQuestlog[91741] = {
            Objectives = {original}, ObjectiveData = {{Id = 10, Type = "monster"}}, SpecialObjectives = {},
        }
        cached[91741] = {objectives = {{text = "Wolf", raw_text = "Wolf: 2/5", type = "monster", numFulfilled = 2, numRequired = 5}}}

        local quest = TrackerData.GetQuest(91741)
        local objective = quest.Objectives[1]

        assert.are.equal(original, objective.enrichment)
        assert.are.equal(original.spawnList, objective.spawnList)
        assert.are.equal(2, objective.Collected)
        assert.is_nil(original.Collected)
        assert.are.equal("|cFFEEEEEEWolf: 2/5", TrackerData.GetObjectiveText(objective))

        dofile("Modules/Libs/DistanceUtils.lua")
        local DistanceUtils = QuestieLoader:ImportModule("DistanceUtils")
        DistanceUtils.GetNearestObjective = spy.new(function() return {10, 20}, 12, "Wolf", 100 end)

        local spawn = DistanceUtils.GetNearestSpawnForQuest(quest)

        assert.are.same({10, 20}, spawn)
        assert.spy(DistanceUtils.GetNearestObjective).was.called_with(original.spawnList)
    end)

    it("does not attach an old same-type database objective to new live wording", function()
        QuestiePlayer.currentQuestlog[91741] = {
            Objectives = {{Id = 10, Type = "monster"}}, ObjectiveData = {{Id = 10, Type = "monster"}},
            SpecialObjectives = {{Id = 99}},
        }
        cached[91741] = {objectives = {{text = "Boar", type = "monster", numFulfilled = 1, numRequired = 4}}}

        local quest = TrackerData.GetQuest(91741)

        assert.is_nil(quest.Objectives[1].enrichment)
        assert.is_nil(quest.Objectives[1].Id)
        assert.are.same({}, quest.SpecialObjectives)
        assert.are.equal("|cFFEEEEEEBoar: 1/4", TrackerData.GetObjectiveText(quest.Objectives[1]))
    end)

    it("renders new live objectives absent from an otherwise known database quest", function()
        QuestiePlayer.currentQuestlog[91741] = {Objectives = {}, ObjectiveData = {}}
        cached[91741] = {objectives = {{text = "Read the note.", type = "log", numFulfilled = 0, numRequired = 1}}}

        local quest = TrackerData.GetQuest(91741)

        assert.are.equal(1, #quest.Objectives)
        assert.is_nil(quest.Objectives[1].enrichment)
        assert.are.equal("Read the note.", quest.Objectives[1].Description)
    end)

    it("preserves the existing missing-source-item synthetic objective", function()
        local original = {
            Id = 44, Type = "item", Description = "Note", FullDescription = "Verner's Note",
            Needed = 1, Collected = 0, Completed = false, spawnList = {},
        }
        QuestiePlayer.currentQuestlog[91741] = {sourceItemId = 44, Objectives = {original}}
        cached[91741] = {objectives = {}}

        local quest = TrackerData.GetQuest(91741)

        assert.are.equal(original, quest.Objectives[1].enrichment)
        assert.are.equal(1, quest.Objectives[1].Index)
        assert.are.equal(91741, quest.Objectives[1].questId)
        assert.is_nil(original.Index)
        assert.are.equal(original.spawnList, quest.Objectives[1].spawnList)
        assert.is_false(quest.Objectives[1].Completed)
        assert.are.equal("|cFFEEEEEEVerner's Note: 0/1", TrackerData.GetObjectiveText(quest.Objectives[1]))
    end)

    it("does not infer unfamiliar objective completion from equal numeric fields", function()
        cached[91741] = {objectives = {{text = "Follow the apparition.", type = "futureType", numFulfilled = 1, numRequired = 1, finished = false}}}

        local objective = TrackerData.GetQuest(91741).Objectives[1]

        assert.is_false(objective.Completed)
        assert.are.equal("|cFFEEEEEEFollow the apparition", TrackerData.GetObjectiveText(objective))
    end)

    it("does not let stale additional completion hide a changed live objective", function()
        QuestiePlayer.currentQuestlog[91741] = {
            isComplete = true, Objectives = {{Id = 10, Type = "monster"}},
            ObjectiveData = {{Id = 10, Type = "monster"}},
        }
        cached[91741] = {objectives = {{text = "Boar", type = "monster", numFulfilled = 0, numRequired = 4, finished = false}}}

        local quest = TrackerData.GetQuest(91741)

        assert.are.equal(0, quest:IsComplete())
        assert.is_false(quest.isComplete)
        assert.is_false(quest.Objectives[1].Completed)
    end)

    it("keeps additional completion for objectives with verified enrichment", function()
        QuestiePlayer.currentQuestlog[91741] = {
            isComplete = true, Objectives = {{Id = 10, Type = "monster"}},
            ObjectiveData = {{Id = 10, Type = "monster"}},
        }
        cached[91741] = {objectives = {{text = "Wolf", type = "monster", numFulfilled = 4, numRequired = 4, finished = true}}}

        local quest = TrackerData.GetQuest(91741)

        assert.are.equal(0, quest:IsComplete())
        assert.is_true(quest.isComplete)
    end)

    it("does not report an error for an initial objective cache miss", function()
        local quest = TrackerData.GetQuest(91741)

        assert.is_false(quest.objectivesLoaded)
        assert.spy(QuestLogCache.GetQuest).was.not_called()
        assert.spy(QuestieLib.GetLoadedQuestObjectives).was.not_called()
    end)

    it("reads the current snapshot without rescanning client data", function()
        local snapshot = TrackerData.Refresh()
        compat.GetNumQuestLogEntries = spy.new(function() return #entries end)
        compat.GetQuestLogTitle = spy.new(compat.GetQuestLogTitle)
        QuestieDB.IsComplete = spy.new(function() return completion end)

        assert.are.equal(snapshot, TrackerData.GetQuests())
        assert.are.equal(snapshot, TrackerData.GetQuests())
        assert.spy(compat.GetNumQuestLogEntries).was.not_called()
        assert.spy(compat.GetQuestLogTitle).was.not_called()
        assert.spy(QuestieLib.GetLoadedQuestObjectives).was.not_called()
        assert.spy(QuestieDB.IsComplete).was.not_called()
    end)

    it("refreshes a single quest without refreshing another quest's objectives or completion", function()
        entries[3] = {title = "Another quest", id = 123, level = 2}
        cached[91741] = {objectives = {{text = "Read the book.", type = "log", finished = false}}}
        cached[123] = {objectives = {{text = "Speak to the librarian.", type = "log", finished = false}}}
        TrackerData.Refresh()
        QuestieDB.IsComplete = spy.new(function() return 0 end)
        compat.GetNumQuestLogEntries = spy.new(function() return #entries end)
        local otherObjective = TrackerData.GetQuests()[123].Objectives[1]

        TrackerData.GetQuest(91741)

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
        cached[91741] = {objectives = {{text = "Wolf", type = "monster", numFulfilled = 2, numRequired = 5}}}
        local quest = TrackerData.GetQuest(91741)
        QuestiePlayer.currentQuestlog[91741] = nil

        TrackerData.GetQuest(91741)

        assert.is_nil(quest.enrichment)
        assert.is_nil(quest.Objectives[1].enrichment)
        assert.are.same({}, quest.Objectives[1].spawnList)
        assert.are.same({}, quest.ObjectiveData)
        assert.are.same({}, quest.SpecialObjectives)
        assert.are.equal("|cFFEEEEEEWolf: 2/5", TrackerData.GetObjectiveText(quest.Objectives[1]))
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
            tracker.UpdateQuestLines = function(id) TrackerData.GetQuest(id) end
            dofile("Modules/EventHandler/QuestEventHandler.lua")
            QuestEventHandler = QuestieLoader:ImportModule("QuestEventHandler")
        end)

        after_each(function()
            _G.C_QuestLog, _G.HaveQuestData = originalQuestLog, originalHaveData
            _G.C_Timer, _G.GetTime, Questie.IsForever = originalTimer, originalTime, originalForever
        end)

        it("recovers an unknown login quest without another Blizzard event", function()
            haveData = false
            local cacheMiss, _, checked = QuestLogCache.CheckForChanges(nil)
            assert.is_true(cacheMiss)
            -- Initialization records every checked quest, even when its first cache fill missed.
            QuestEventHandler.InitQuestLogStates(checked)
            local quest = TrackerData.Refresh()[91741]
            assert.are.equal("Nibbled-On Book", quest.name)
            assert.is_false(quest.objectivesLoaded)

            QuestEventHandler.QuestWatchUpdate(91741)
            now = 130 -- Timer delivery may be late; its callback must refresh the expired marker.
            haveData = true
            nativeObjectives = {{text = " ", type = "log", numFulfilled = 0, numRequired = 1, finished = false}}
            retryTimers[1].callback()
            assert.is_false(quest.objectivesLoaded)
            assert.are.equal(2, #retryTimers)

            now = 160
            nativeObjectives = {{text = "Read the book.", type = "log", numFulfilled = 0, numRequired = 1, finished = false}}
            retryTimers[2].callback()
            assert.are.equal(2, #retryTimers)

            assert.is_true(quest.objectivesLoaded)
            assert.are.equal("|cFFEEEEEERead the book", TrackerData.GetObjectiveText(quest.Objectives[1]))
            assert.is_nil(quest.enrichment)
            assert.is_nil(QuestiePlayer.currentQuestlog[91741])
            _G.C_QuestLog.GetQuestObjectives:clear()
            TrackerData.Refresh()
            TrackerData.GetQuest(91741)
            assert.spy(_G.C_QuestLog.GetQuestObjectives).was.not_called()
        end)

        it("finishes acceptance after both initial reads miss and the fallback loads the objectives", function()
            QuestEventHandler.QuestAccepted(2, 91741)
            callbacks[1]()
            local quest = TrackerData.GetQuests()[91741]
            assert.is_false(quest.objectivesLoaded)
            assert.spy(QuestLifecycle.AcceptQuest).was.not_called()

            now = 130
            entries[2].complete = 1
            nativeObjectives = {{text = "Return the book.", type = "log", numFulfilled = 1, numRequired = 1, finished = true}}
            retryTimers[1].callback()
            assert.are.equal(1, #retryTimers)

            assert.is_true(quest.objectivesLoaded)
            assert.are.equal(1, quest:IsComplete())
            assert.is_true(quest.Objectives[1].Completed)
            assert.spy(QuestLifecycle.AcceptQuest).was.called(1)
            assert.is_nil(QuestiePlayer.currentQuestlog[91741])
        end)

        it("renders cached progress through unavailable responses and loading-screen regressions", function()
            nativeObjectives = {{text = "Wolf slain: 3/5", type = "monster", numFulfilled = 3, numRequired = 5, finished = false}}
            QuestLogCache.CheckForChanges(nil)
            local quest = TrackerData.Refresh()[91741]
            local cachedQuest = QuestLogCache.GetQuest(91741)
            QuestLogCache.OnLoadingScreenEnabled()
            nativeObjectives = nil
            assert.is_true(QuestLogCache.CheckForChanges(nil))
            TrackerData.Refresh()
            assert.are.equal(3, quest.Objectives[1].Collected)
            assert.are.equal(cachedQuest, QuestLogCache.GetQuest(91741))

            nativeObjectives = {{text = " ", type = "monster", numFulfilled = 0, numRequired = 5, finished = false}}
            assert.is_true(QuestLogCache.CheckForChanges(nil))
            TrackerData.Refresh()
            assert.are.equal(3, quest.Objectives[1].Collected)

            nativeObjectives = {{text = "Wolf slain: 0/5", numFulfilled = 0, numRequired = 5, finished = false}}
            assert.is_true(QuestLogCache.CheckForChanges(nil))
            TrackerData.Refresh()
            assert.are.equal(3, quest.Objectives[1].Collected)

            nativeObjectives = {{text = "Wolf slain: 0/5", type = "monster", numFulfilled = 0, numRequired = 5, finished = false}}
            assert.is_true(QuestLogCache.CheckForChanges(nil))
            TrackerData.Refresh()
            assert.are.equal(3, quest.Objectives[1].Collected)

            nativeObjectives = {{text = "Wolf slain: 4/5", type = "monster", numFulfilled = 4, numRequired = 5, finished = false}}
            assert.is_false(QuestLogCache.CheckForChanges(nil))
            TrackerData.Refresh()
            assert.are.equal(4, quest.Objectives[1].Collected)
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

        assert.are.equal(42, TrackerData.GetQuest(91741).level)
    end)

    it("formats titles and chat links from the live name and level", function()
        local quest = TrackerData.GetQuest(91741)
        Questie.db.profile.trackerShowQuestLevel = true

        assert.are.equal("|cFFFFFF00[2] Nibbled-On Book|r", TrackerData.GetColoredQuestName(quest, true, false))
        assert.are.equal("[[2] Nibbled-On Book (91741)]", TrackerData.GetQuestLink(quest))
    end)
end)
