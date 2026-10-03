dofile("setupTests.lua")

describe("QuestieQuest", function()
    ---@type QuestieQuest
    local QuestieQuest
    ---@type AvailableQuests
    local AvailableQuests
    ---@type ZoneDB
    local ZoneDB
    ---@type QuestieDB
    local QuestieDB
    ---@type QuestiePlayer
    local QuestiePlayer
    ---@type QuestieMap
    local QuestieMap
    ---@type QuestLogCache
    local QuestLogCache
    ---@type QuestieCombatQueue
    local QuestieCombatQueue
    ---@type CommsVisibility
    local CommsVisibility
    ---@type l10n
    local l10n

    before_each(function()
        Questie.db.char = {}
        ZoneDB = QuestieLoader:ImportModule("ZoneDB")
        ZoneDB.GetDungeons = function() return {} end
        QuestieDB = QuestieLoader:ImportModule("QuestieDB")
        QuestieDB.GetQuest = spy.new(function() return {} end)
        AvailableQuests = QuestieLoader:ImportModule("AvailableQuests")
        AvailableQuests.CalculateAndDrawAll = spy.new(function() end)
        QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
        QuestiePlayer.currentQuestlog = {}
        QuestieMap = QuestieLoader:ImportModule("QuestieMap")
        QuestLogCache = QuestieLoader:ImportModule("QuestLogCache")
        QuestieCombatQueue = QuestieLoader:ImportModule("QuestieCombatQueue")
        QuestieCombatQueue.Queue = function() end
        CommsVisibility = QuestieLoader:ImportModule("CommsVisibility")
        CommsVisibility.ScheduleSnapshot = spy.new(function() end)
        l10n = QuestieLoader:ImportModule("l10n")
        setmetatable(l10n, {__call = function(_, key, ...) return key end})

        dofile("Modules/Quest/QuestieQuest.lua")
        QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")
    end)

    describe("UnhideQuest", function()
        it("should unhide a quest", function()
            local questId = 123
            Questie.db.char = {hidden = {[questId] = true}}
            QuestieQuest.PopulateObjectiveNotes = spy.new(function() end)

            QuestieQuest:UnhideQuest(questId)

            assert.is_nil(Questie.db.char.hidden[questId])
            assert.spy(CommsVisibility.ScheduleSnapshot).was.called()
            assert.spy(AvailableQuests.CalculateAndDrawAll).was.called()
            assert.spy(QuestieDB.GetQuest).was.not_called()
            assert.spy(QuestieQuest.PopulateObjectiveNotes).was.not_called()
        end)

        it("should unhide a quest that is in the quest log", function()
            local questId = 123
            Questie.db.char = {hidden = {[questId] = true}}
            QuestiePlayer.currentQuestlog[questId] = true
            QuestieQuest.PopulateObjectiveNotes = spy.new(function() end)

            QuestieQuest:UnhideQuest(questId)

            assert.is_nil(Questie.db.char.hidden[questId])
            assert.spy(CommsVisibility.ScheduleSnapshot).was.called()
            assert.spy(AvailableQuests.CalculateAndDrawAll).was.not_called()
            assert.spy(QuestieDB.GetQuest).was.called_with(123)
            assert.spy(QuestieQuest.PopulateObjectiveNotes).was.called_with(QuestieQuest, {})
        end)
    end)

    describe("ShowQuestIcons", function()
        it("should not throw an error when called from a coroutine", function()
            QuestieMap.questIdFrames = {}

            local co = coroutine.create(function()
                QuestieQuest:ShowQuestIcons()
            end)

            assert.is_true(coroutine.resume(co))
        end)

        it("should throw an error when not called from a coroutine", function()
            assert.has_error(function()
                QuestieQuest:ShowQuestIcons()
            end, "ShowQuestIcons must be called from a coroutine")
        end)
    end)

    describe("HideQuestIcons", function()
        it("should not throw an error when called from a coroutine", function()
            QuestieMap.questIdFrames = {}

            local co = coroutine.create(function()
                QuestieQuest:HideQuestIcons()
            end)

            assert.is_true(coroutine.resume(co))
        end)

        it("should throw an error when not called from a coroutine", function()
            assert.has_error(function()
                QuestieQuest:HideQuestIcons()
            end, "HideQuestIcons must be called from a coroutine")
        end)
    end)

    describe("GetAllQuestIds", function()
        it("should not throw an error when called from a coroutine", function()
            QuestLogCache.questLog_DO_NOT_MODIFY = {}

            local co = coroutine.create(function()
                QuestieQuest:GetAllQuestIds()
            end)

            assert.is_true(coroutine.resume(co))
        end)

        it("should throw an error when not called from a coroutine", function()
            assert.has_error(function()
                QuestieQuest:GetAllQuestIds()
            end, "GetAllQuestIds must be called from a coroutine")
        end)
    end)

    describe("Missing quest warnings", function()
        local originalSessionWarnings
        local originalDebugEnabled
        local originalIsSoD
        local originalWarning
        local originalQuestPointers
        local originalQuestLog

        before_each(function()
            originalSessionWarnings = Questie._sessionWarnings
            originalDebugEnabled = Questie.db.profile.debugEnabled
            originalIsSoD = Questie.IsSoD
            originalWarning = Questie.Warning
            originalQuestPointers = QuestieDB.QuestPointers
            originalQuestLog = QuestLogCache.questLog_DO_NOT_MODIFY
            Questie._sessionWarnings = {}
            Questie.db.profile.debugEnabled = false
            Questie.IsSoD = false
            Questie.Warning = spy.new(function() end)
            QuestieDB.QuestPointers = {}
            QuestLogCache.questLog_DO_NOT_MODIFY = {[42] = {title = "Missing quest"}}
            dofile("Localization/l10n.lua")
        end)

        after_each(function()
            Questie._sessionWarnings = originalSessionWarnings
            Questie.db.profile.debugEnabled = originalDebugEnabled
            Questie.IsSoD = originalIsSoD
            Questie.Warning = originalWarning
            QuestieDB.QuestPointers = originalQuestPointers
            QuestLogCache.questLog_DO_NOT_MODIFY = originalQuestLog
        end)

        it("should not consume the once-per-session warning before debug mode is enabled", function()
            QuestieQuest:GetAllQuestIdsNoObjectives()
            coroutine.wrap(function() QuestieQuest:GetAllQuestIds() end)()

            assert.spy(Questie.Warning).was.not_called()
            assert.is_nil(Questie._sessionWarnings[42])

            Questie.db.profile.debugEnabled = true
            QuestieQuest:GetAllQuestIdsNoObjectives()
            coroutine.wrap(function() QuestieQuest:GetAllQuestIds() end)()

            assert.spy(Questie.Warning).was.called(1)
            assert.spy(Questie.Warning).was.called_with(
                "The quest 42 is missing from Questie's database. Please report this on GitHub or Discord!")
            assert.is_true(Questie._sessionWarnings[42])
        end)
    end)

    describe("PopulateQuestLogInfo", function()
        local originalGetQuest
        local originalGetLeaderBoardDetails
        local originalWarning
        local originalRemoveQuest, originalAddFinisher
        local QuestFinisher

        before_each(function()
            originalWarning = Questie.Warning
            Questie.Warning = spy.new(function() end)
            originalGetQuest = QuestLogCache.GetQuest
            originalGetLeaderBoardDetails = QuestieQuest.GetAllLeaderBoardDetails
            dofile("Modules/Libs/QuestieLib.lua")
            QuestLogCache.GetQuest = function() return {isComplete = 0} end
            originalRemoveQuest = AvailableQuests.RemoveQuest
            QuestFinisher = QuestieLoader:ImportModule("QuestFinisher")
            originalAddFinisher = QuestFinisher.AddFinisher
            AvailableQuests.RemoveQuest = spy.new(function(_, callback) callback() end)
            QuestFinisher.AddFinisher = spy.new(function() end)
            QuestieQuest.GetAllLeaderBoardDetails = function()
                return {{type = "monster", text = "Wolf slain: 0/1", numFulfilled = 0, numRequired = 1}}
            end
        end)

        after_each(function()
            QuestLogCache.GetQuest = originalGetQuest
            QuestieQuest.GetAllLeaderBoardDetails = originalGetLeaderBoardDetails
            Questie.Warning = originalWarning
            AvailableQuests.RemoveQuest = originalRemoveQuest
            QuestFinisher.AddFinisher = originalAddFinisher
        end)

        it("keeps an unfinished log objective instead of treating the quest as empty and adding its finisher", function()
            local native = {type = "log", text = "Read the note.",
                numFulfilled = 1, numRequired = 1, finished = false}
            QuestieQuest.GetAllLeaderBoardDetails = function() return {native} end
            local quest = {
                Id = 42, ObjectiveData = {{Id = 100, Type = "event"}}, Objectives = {}, SpecialObjectives = {},
                Finisher = {NPC = {123}},
            }

            QuestieQuest:PopulateQuestLogInfo(quest)

            assert.is_nil(quest.isComplete)
            assert.spy(AvailableQuests.RemoveQuest).was.not_called()
            assert.spy(QuestFinisher.AddFinisher).was.not_called()
            assert.are.equal("log", quest.Objectives[1].Type)
            assert.are.equal("Read the note.", quest.Objectives[1].Description)
            assert.is_false(quest.Objectives[1].Completed)
            assert.are.equal(0, quest.Objectives[1].Collected)
            assert.are.equal(1, native.numFulfilled)
        end)

        it("preserves native indices and special-objective completion links when a log row precedes a monster row", function()
            local native = {
                {type = "log", text = "Read the note.",
                    numFulfilled = 1, numRequired = 1, finished = false},
                {type = "monster", text = "Wolf slain: 2/5",
                    numFulfilled = 2, numRequired = 5, finished = false},
            }
            QuestieQuest.GetAllLeaderBoardDetails = function() return native end
            local special = {RealObjectiveIndex = 1}
            local quest = {
                Id = 42, ObjectiveData = {{Id = 100, Type = "event"}, {Id = 101, Type = "monster"}},
                Objectives = {}, SpecialObjectives = {special},
            }
            QuestieDB.GetQuest = function() return quest end

            QuestieQuest:PopulateQuestLogInfo(quest)

            assert.are.equal(1, quest.Objectives[1].Index)
            assert.are.equal(100, quest.Objectives[1].Id)
            assert.are.equal(2, quest.Objectives[2].Index)
            assert.are.equal(101, quest.Objectives[2].Id)
            assert.are.equal(2, quest.Objectives[2].Collected)
            assert.is_false(special.Completed)

            native[1].finished = true
            QuestieQuest:SetObjectivesDirty(42)
            quest.Objectives[1]:Update()
            special:Update()

            assert.is_true(quest.Objectives[1].Completed)
            assert.is_true(special.Completed)
            assert.is_false(quest.Objectives[2].Completed)
        end)

        it("should warn with the quest ID and text when objective data is missing", function()
            local quest = {Id = 42, ObjectiveData = {}, Objectives = {}, SpecialObjectives = {}}

            QuestieQuest:PopulateQuestLogInfo(quest)

            assert.spy(Questie.Warning).was.called_with("Missing objective data for quest ", 42, " ", "Wolf slain: 0/1")
            assert.are_same({}, quest.Objectives)
        end)

        it("keeps counter-free native wording when creating and updating shared objectives", function()
            local quest = {Id = 42, ObjectiveData = {{Id = 100}}, Objectives = {}, SpecialObjectives = {}}

            QuestieQuest:PopulateQuestLogInfo(quest)

            local objective = quest.Objectives[1]
            assert.equals("Wolf slain", objective.Description)

            QuestieQuest.GetAllLeaderBoardDetails = function()
                return {{type = "monster", text = "2/5 Timber Wolves slain", numFulfilled = 2, numRequired = 5}}
            end
            objective.isUpdated = false
            objective:Update()

            assert.equals("Timber Wolves slain", objective.Description)
            assert.are.equal(2, objective.Collected)
        end)
    end)

    describe("GetAllLeaderBoardDetails", function()
        it("announces accepted native text using the original objective index", function()
            local objectives = {[3] = {text = "Wolf slain: 2/5", numFulfilled = 2, numRequired = 5}}
            QuestLogCache.GetQuestObjectives = function() return objectives end
            local announce = QuestieLoader:ImportModule("QuestieAnnounce")
            announce.ObjectiveChanged = spy.new(function() end)

            assert.are.equal(objectives, QuestieQuest:GetAllLeaderBoardDetails(42))
            assert.spy(announce.ObjectiveChanged).was.called_with(announce, 42, 3, "Wolf slain: 2/5", 2, 5)
        end)
    end)

    describe("PopulateObjective", function()
        it("should not throw an error when called from a coroutine", function()
            local quest = {ObjectiveData = {}}
            local objective = {Description = "test"}

            local co = coroutine.create(function()
                QuestieQuest:PopulateObjective(quest, 1, objective, false)
            end)

            assert.is_true(coroutine.resume(co))
        end)

        it("should throw an error when not called from a coroutine", function()
            assert.has_error(function()
                QuestieQuest:PopulateObjective({}, 1, {Description = "test"}, false)
            end, "PopulateObjective must be called from a coroutine")
        end)
    end)

    describe("RegisterObjectiveTooltips", function()
        before_each(function()
            QuestieQuest.private.objectiveSpawnListCallTable = {}
        end)

        it("should not crash when objectives have nil spawnList (guard against nil in next())", function()
            -- The bug was that RegisterObjectiveTooltips called next(objective.spawnList) without checking if spawnList was nil first
            -- This should complete without error (not crash on "bad argument #1 to next")
            local quest = {
                Id = 123,
                Objectives = {},
                SpecialObjectives = {},
                ObjectiveData = {}
            }

            -- Should not throw an error
            QuestieQuest.RegisterObjectiveTooltips(quest)
            assert.is_true(true)
        end)

        it("should not crash when special objectives have nil spawnList", function()
            -- Same check for SpecialObjectives path
            local quest = {
                Id = 123,
                Objectives = {},
                SpecialObjectives = {},
                ObjectiveData = {}
            }

            -- Should not throw an error
            QuestieQuest.RegisterObjectiveTooltips(quest)
            assert.is_true(true)
        end)

        it("should assign Index to regular objectives if not already set", function()
            local quest = {
                Id = 123,
                Objectives = {
                    [1] = {Description = "Objective 1", spawnList = {}},
                    [5] = {Description = "Objective 5", spawnList = {}},
                },
                SpecialObjectives = {},
                ObjectiveData = {}
            }

            assert.is_nil(quest.Objectives[1].Index)
            assert.is_nil(quest.Objectives[5].Index)

            QuestieQuest.RegisterObjectiveTooltips(quest)

            assert.are_equal(1, quest.Objectives[1].Index)
            assert.are_equal(5, quest.Objectives[5].Index)
        end)

        it("should assign Index to special objectives (64 + loop index) before processing", function()
            local quest = {
                Id = 123,
                Objectives = {},
                SpecialObjectives = {
                    {Description = "Special 1", spawnList = {}},
                    {Description = "Special 2", spawnList = {}},
                },
                ObjectiveData = {}
            }

            assert.is_nil(quest.SpecialObjectives[1].Index)
            assert.is_nil(quest.SpecialObjectives[2].Index)

            QuestieQuest.RegisterObjectiveTooltips(quest)

            assert.are_equal(65, quest.SpecialObjectives[1].Index) -- 64 + 1
            assert.are_equal(66, quest.SpecialObjectives[2].Index) -- 64 + 2
        end)
    end)

    describe("IsQuestTracked", function()
        local QuestieCompat

        before_each(function()
            QuestieCompat = QuestieLoader:ImportModule("QuestieCompat")
            Questie.db.profile = Questie.db.profile or {}
            Questie.db.char.AutoUntrackedQuests = {}
            Questie.db.char.TrackedQuests = {}
        end)

        it("defers to the Blizzard watch state when the Questie tracker is disabled", function()
            Questie.db.profile.trackerEnabled = false
            QuestieCompat.GetQuestLogIndexByID = spy.new(function() return 7 end)
            QuestieCompat.IsQuestWatched = spy.new(function() return false end)

            assert.is_false(QuestieQuest:IsQuestTracked(123))
            assert.spy(QuestieCompat.GetQuestLogIndexByID).was.called_with(123)
            assert.spy(QuestieCompat.IsQuestWatched).was.called_with(7)

            QuestieCompat.IsQuestWatched = spy.new(function() return true end)
            assert.is_true(QuestieQuest:IsQuestTracked(123))
        end)

        it("normalizes a nil watch result to false when the tracker is disabled", function()
            Questie.db.profile.trackerEnabled = false
            QuestieCompat.GetQuestLogIndexByID = spy.new(function() return 0 end)
            QuestieCompat.IsQuestWatched = spy.new(function() return nil end)

            assert.is_false(QuestieQuest:IsQuestTracked(123))
        end)

        it("uses Questie's own tables and ignores the watch state when the tracker is enabled", function()
            Questie.db.profile.trackerEnabled = true
            Questie.db.profile.autoTrackQuests = true
            QuestieCompat.IsQuestWatched = spy.new(function() return false end)

            -- autoTrack on and not in AutoUntrackedQuests => tracked
            assert.is_true(QuestieQuest:IsQuestTracked(123))

            Questie.db.char.AutoUntrackedQuests[123] = true
            assert.is_false(QuestieQuest:IsQuestTracked(123))

            -- the Blizzard watch state must not be consulted while the tracker is enabled
            assert.spy(QuestieCompat.IsQuestWatched).was.not_called()
        end)
    end)
end)
