dofile("setupTests.lua")

describe("TrackerData", function()
    local TrackerData, QuestieLib, QuestieDB, QuestiePlayer, QuestLogCache, compat
    local entries, cached, loaded, completion
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
        loaded = nil
        completion = 0
        compat.GetNumQuestLogEntries = function() return #entries end
        compat.GetQuestLogTitle = function(index)
            local entry = entries[index]
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
        QuestieLib.GetLoadedQuestObjectives = function() return loaded end
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
        loaded = {{text = "Follow the apparition.", type = "futureType", numFulfilled = 0, numRequired = 100, finished = false}}

        local objective = TrackerData.GetQuest(91741).Objectives[1]

        assert.are.equal("futureType", objective.Type)
        assert.are.equal("|cFFEEEEEEFollow the apparition", TrackerData.GetObjectiveText(objective))
    end)

    it("respects completion for unfamiliar types without interpreting their numeric fields", function()
        loaded = {{text = "Follow the apparition.", type = "futureType", numFulfilled = 0, numRequired = 100, finished = true}}

        local objective = TrackerData.GetQuest(91741).Objectives[1]

        assert.is_true(objective.Completed)
    end)

    it("uses the normalized cache instead of overwriting it with another client read", function()
        cached[91741] = {objectives = {{text = "Wolf", raw_text = "Wolf: 3/5", type = "monster", numFulfilled = 3, numRequired = 5}}}
        loaded = {{text = "Wolf: 0/5", type = "monster", numFulfilled = 0, numRequired = 5}}

        local objective = TrackerData.GetQuest(91741).Objectives[1]

        assert.are.equal(3, objective.Collected)
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

    it("shows the title while the first objective read is incomplete", function()
        loaded = {{text = " ", type = "monster"}}

        local quest = TrackerData.GetQuest(91741)

        assert.are.equal("Nibbled-On Book", quest.name)
        assert.is_false(quest.objectivesLoaded)
        assert.are.equal(0, quest:IsComplete())
        assert.are.same({}, quest.Objectives)
    end)

    it("recovers from a placeholder without replacing the quest record", function()
        local quest = TrackerData.GetQuest(91741)
        loaded = {{text = "Inspect the book.", type = "event", numFulfilled = 0, numRequired = 0, finished = false}}

        assert.are.equal(quest, TrackerData.GetQuest(91741))
        assert.is_true(quest.objectivesLoaded)
        assert.are.equal("Inspect the book.", quest.Objectives[1].Description)
        assert.are.equal("|cFFEEEEEEInspect the book", TrackerData.GetObjectiveText(quest.Objectives[1]))
    end)

    it("retains the last valid objective snapshot during a temporary cache miss", function()
        loaded = {{text = "Inspect the book.", type = "event", numFulfilled = 0, numRequired = 0, finished = false}}
        local quest = TrackerData.GetQuest(91741)
        local objective = quest.Objectives[1]
        loaded = nil

        TrackerData.Refresh()

        assert.are.equal(objective, quest.Objectives[1])
        assert.is_true(quest.objectivesLoaded)
    end)

    it("does not equate a loaded empty objective list with quest completion", function()
        loaded = {}

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
        loaded = {{text = "Inspect the book.", type = "event", finished = true}}
        local previous = TrackerData.GetQuest(91741)
        TrackerData.RemoveQuest(91741)
        loaded = nil

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
    end)

    it("does not attach an old same-type database objective to new live wording", function()
        QuestiePlayer.currentQuestlog[91741] = {
            Objectives = {{Id = 10, Type = "monster"}}, ObjectiveData = {{Id = 10, Type = "monster"}},
            SpecialObjectives = {{Id = 99}},
        }
        loaded = {{text = "Boar", type = "monster", numFulfilled = 1, numRequired = 4}}

        local quest = TrackerData.GetQuest(91741)

        assert.is_nil(quest.Objectives[1].enrichment)
        assert.is_nil(quest.Objectives[1].Id)
        assert.are.same({}, quest.SpecialObjectives)
        assert.are.equal("|cFFEEEEEEBoar: 1/4", TrackerData.GetObjectiveText(quest.Objectives[1]))
    end)

    it("renders new live objectives absent from an otherwise known database quest", function()
        QuestiePlayer.currentQuestlog[91741] = {Objectives = {}, ObjectiveData = {}}
        loaded = {{text = "Read the note.", type = "log", numFulfilled = 0, numRequired = 1}}

        local quest = TrackerData.GetQuest(91741)

        assert.are.equal(1, #quest.Objectives)
        assert.is_nil(quest.Objectives[1].enrichment)
        assert.are.equal("Read the note.", quest.Objectives[1].Description)
    end)

    it("preserves the existing missing-source-item synthetic objective", function()
        local original = {Id = 44, Type = "item", Description = "Note", Needed = 1, Collected = 0, Completed = false}
        QuestiePlayer.currentQuestlog[91741] = {sourceItemId = 44, Objectives = {original}}
        cached[91741] = {objectives = {}}

        local quest = TrackerData.GetQuest(91741)

        assert.are.equal(original, quest.Objectives[1].enrichment)
        assert.are.equal(1, quest.Objectives[1].Index)
        assert.are.equal(91741, quest.Objectives[1].questId)
        assert.is_nil(original.Index)
        assert.are.equal("|cFFEEEEEENote: 0/1", TrackerData.GetObjectiveText(quest.Objectives[1]))
    end)

    it("does not infer unfamiliar objective completion from equal numeric fields", function()
        loaded = {{text = "Follow the apparition.", type = "futureType", numFulfilled = 1, numRequired = 1, finished = false}}

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
    end)

    it("reads the current snapshot without rescanning client data", function()
        local snapshot = TrackerData.Refresh()
        compat.GetNumQuestLogEntries = spy.new(function() return #entries end)
        compat.GetQuestLogTitle = spy.new(compat.GetQuestLogTitle)
        QuestieLib.GetLoadedQuestObjectives = spy.new(function() return loaded end)
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
        loaded = {{text = "Read the book.", type = "log", finished = false}}
        TrackerData.Refresh()
        cached[91741] = {objectives = loaded}
        cached[123] = {objectives = loaded}
        QuestieDB.IsComplete = spy.new(function() return 0 end)
        QuestieLib.GetLoadedQuestObjectives = spy.new(function() return loaded end)
        compat.GetNumQuestLogEntries = spy.new(function() return #entries end)
        local otherObjective = TrackerData.GetQuests()[123].Objectives[1]

        TrackerData.GetQuest(91741)

        assert.spy(QuestieDB.IsComplete).was.called(1)
        assert.spy(QuestieDB.IsComplete).was.called_with(91741)
        assert.spy(QuestieLib.GetLoadedQuestObjectives).was.not_called()
        assert.spy(compat.GetNumQuestLogEntries).was.not_called()
        assert.are.equal(otherObjective, TrackerData.GetQuests()[123].Objectives[1])
    end)

    it("refreshes each quest once in a full snapshot", function()
        entries[3] = {title = "Another quest", id = 123, level = 2}
        QuestieLib.GetLoadedQuestObjectives = spy.new(function() return {} end)

        local snapshot = TrackerData.Refresh()

        assert.is_not_nil(snapshot[91741])
        assert.is_not_nil(snapshot[123])
        assert.spy(QuestieLib.GetLoadedQuestObjectives).was.called(2)
        assert.spy(QuestieLib.GetLoadedQuestObjectives).was.called_with(91741)
        assert.spy(QuestieLib.GetLoadedQuestObjectives).was.called_with(123)
        entries = {}
        assert.are.same({}, TrackerData.Refresh())
    end)

    it("drops stale map references but retains readable progress when enrichment disappears during a miss", function()
        local original = {Id = 10, Type = "monster", Description = "Wolf", spawnList = {{name = "Wolf"}}}
        QuestiePlayer.currentQuestlog[91741] = {
            Objectives = {original}, ObjectiveData = {{Id = 10, Type = "monster"}}, SpecialObjectives = {{Id = 99}},
        }
        loaded = {{text = "Wolf", type = "monster", numFulfilled = 2, numRequired = 5}}
        local quest = TrackerData.GetQuest(91741)
        loaded = nil
        QuestiePlayer.currentQuestlog[91741] = nil

        TrackerData.GetQuest(91741)

        assert.is_nil(quest.enrichment)
        assert.is_nil(quest.Objectives[1].enrichment)
        assert.are.same({}, quest.Objectives[1].spawnList)
        assert.are.same({}, quest.ObjectiveData)
        assert.are.same({}, quest.SpecialObjectives)
        assert.are.equal("|cFFEEEEEEWolf: 2/5", TrackerData.GetObjectiveText(quest.Objectives[1]))
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
