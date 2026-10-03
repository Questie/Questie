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

    local originalQuestPointers

    before_each(function()
        Questie.db.char = {}
        ZoneDB = QuestieLoader:ImportModule("ZoneDB")
        ZoneDB.GetDungeons = function() return {} end
        QuestieDB = QuestieLoader:ImportModule("QuestieDB")
        originalQuestPointers = QuestieDB.QuestPointers
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

    after_each(function()
        QuestieDB.QuestPointers = originalQuestPointers
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
        it("should show an eligible icon from a coroutine", function()
            local icon = {
                hidden = true, data = {QuestData = {}, ObjectiveIndex = 1},
                ShouldBeHidden = function() return false end,
                FakeShow = spy.new(function() end),
                FadeIn = spy.new(function() end),
            }
            local previous = _G.QuestieAuditIcon
            _G.QuestieAuditIcon = icon
            QuestieMap.questIdFrames = {[123] = {"QuestieAuditIcon"}}

            local success, message = coroutine.resume(coroutine.create(function()
                QuestieQuest:ShowQuestIcons()
            end))
            _G.QuestieAuditIcon = previous

            assert.is_true(success, message)
            assert.spy(icon.FakeShow).was.called_with(icon)
            assert.spy(icon.FadeIn).was.called_with(icon)
        end)

        it("should throw an error when not called from a coroutine", function()
            assert.has_error(function()
                QuestieQuest:ShowQuestIcons()
            end, "ShowQuestIcons must be called from a coroutine")
        end)
    end)

    describe("HideQuestIcons", function()
        it("should hide an eligible icon from a coroutine", function()
            local icon = {
                hidden = false, data = {QuestData = {}, ObjectiveIndex = 1},
                ShouldBeHidden = function() return true end,
                FakeHide = spy.new(function() end),
                FadeIn = spy.new(function() end),
            }
            local previous = _G.QuestieAuditIcon
            _G.QuestieAuditIcon = icon
            QuestieMap.questIdFrames = {[123] = {"QuestieAuditIcon"}}

            local success, message = coroutine.resume(coroutine.create(function()
                QuestieQuest:HideQuestIcons()
            end))
            _G.QuestieAuditIcon = previous

            assert.is_true(success, message)
            assert.spy(icon.FakeHide).was.called_with(icon)
            assert.spy(icon.FadeIn).was.called_with(icon)
        end)

        it("should throw an error when not called from a coroutine", function()
            assert.has_error(function()
                QuestieQuest:HideQuestIcons()
            end, "HideQuestIcons must be called from a coroutine")
        end)
    end)

    describe("GetAllQuestIds", function()
        it("should retain and refresh a failed logged quest from a coroutine", function()
            local quest = {IsComplete = function() return -1 end}
            QuestLogCache.questLog_DO_NOT_MODIFY = {[123] = {title = "Failed quest"}}
            QuestieDB.QuestPointers = {[123] = true}
            QuestieDB.GetQuest = function() return quest end
            QuestieQuest.UpdateQuest = spy.new(function() end)

            coroutine.wrap(function() QuestieQuest:GetAllQuestIds() end)()

            assert.are_same({[123] = quest}, QuestiePlayer.currentQuestlog)
            assert.spy(QuestieQuest.UpdateQuest).was.called_with(QuestieQuest, 123)
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
        local originalTrimObjectiveText
        local originalWarning

        before_each(function()
            originalWarning = Questie.Warning
            Questie.Warning = spy.new(function() end)
            originalGetQuest = QuestLogCache.GetQuest
            originalGetLeaderBoardDetails = QuestieQuest.GetAllLeaderBoardDetails
            originalTrimObjectiveText = Questie.db.profile.trimObjectiveText
            dofile("Modules/Libs/QuestieLib.lua")
            QuestLogCache.GetQuest = function() return {} end
            QuestieQuest.GetAllLeaderBoardDetails = function()
                return {{type = "monster", text = "Wolf", raw_text = "Wolf slain: 0/1", numFulfilled = 0, numRequired = 1}}
            end
        end)

        after_each(function()
            QuestLogCache.GetQuest = originalGetQuest
            QuestieQuest.GetAllLeaderBoardDetails = originalGetLeaderBoardDetails
            Questie.db.profile.trimObjectiveText = originalTrimObjectiveText
            Questie.Warning = originalWarning
        end)

        it("should warn with the quest ID and text when objective data is missing", function()
            local quest = {Id = 42, ObjectiveData = {}, Objectives = {}, SpecialObjectives = {}}

            QuestieQuest:PopulateQuestLogInfo(quest)

            assert.spy(Questie.Warning).was.called_with("Missing objective data for quest ", 42, " ", "Wolf")
            assert.are_same({}, quest.Objectives)
        end)

        it("should preserve conditional full descriptions when creating and updating objectives", function()
            local quest = {Id = 42, ObjectiveData = {{Id = 100}}, Objectives = {}, SpecialObjectives = {}}
            Questie.db.profile.trimObjectiveText = false

            QuestieQuest:PopulateQuestLogInfo(quest)

            local objective = quest.Objectives[1]
            assert.equals("Wolf slain", objective.FullDescription)
            assert.equals("Wolf", objective.Description)

            Questie.db.profile.trimObjectiveText = true
            objective.isUpdated = false
            objective:Update()

            assert.is_nil(objective.FullDescription)
            assert.equals("Wolf", objective.Description)
        end)
    end)

    describe("PopulateObjective", function()
        it("should unload completed objective icons from a coroutine", function()
            local icon = {}
            local pool = QuestieLoader:ImportModule("QuestieFramePool")
            pool.UnloadFrame = spy.new(function() end)
            local objective = {
                Index = 1, Description = "Wolf", Completed = true,
                Update = spy.new(function() end), spawnList = {[456] = {}},
                AlreadySpawned = {[456] = {mapRefs = {icon}, minimapRefs = {}}},
            }

            coroutine.wrap(function()
                QuestieQuest:PopulateObjective({Id = 123, ObjectiveData = {}}, 1, objective, false)
            end)()

            assert.spy(objective.Update).was.called(1)
            assert.spy(pool.UnloadFrame).was.called_with(pool, icon)
            assert.are_same({}, objective.AlreadySpawned)
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

        it("should populate and register a regular objective with a nil spawnList", function()
            local objective = {Id = 456, Type = "monster", Description = "Wolf"}
            local quest = {Id = 123, Objectives = {objective}, SpecialObjectives = {}, ObjectiveData = {}}
            QuestieQuest.private.objectiveSpawnListCallTable.monster = function() return {{TooltipKey = "m_456"}} end
            local tooltips = QuestieLoader:ImportModule("QuestieTooltips")
            local registered
            tooltips.RegisterObjectiveTooltip = spy.new(function(_, questId, key, value)
                registered = {questId, key, value}
            end)

            QuestieQuest.RegisterObjectiveTooltips(quest)

            assert.are_equal(1, objective.Index)
            assert.are_same({123, "m_456", objective}, registered)
            assert.spy(tooltips.RegisterObjectiveTooltip).was.called(1)
        end)

        it("should populate and register a special objective with a nil spawnList", function()
            local objective = {Id = 789, Type = "object", Description = "Portal"}
            local quest = {Id = 123, Objectives = {}, SpecialObjectives = {objective}, ObjectiveData = {}}
            QuestieQuest.private.objectiveSpawnListCallTable.object = function() return {{TooltipKey = "o_789"}} end
            local tooltips = QuestieLoader:ImportModule("QuestieTooltips")
            local registered
            tooltips.RegisterObjectiveTooltip = spy.new(function(_, questId, key, value)
                registered = {questId, key, value}
            end)

            QuestieQuest.RegisterObjectiveTooltips(quest)

            assert.are_equal(65, objective.Index)
            assert.are_same({123, "o_789", objective}, registered)
            assert.spy(tooltips.RegisterObjectiveTooltip).was.called(1)
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
