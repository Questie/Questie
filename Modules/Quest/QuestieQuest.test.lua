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
        local Polygon = QuestieLoader:ImportModule("QuestiePolygon")
        Polygon.Reset = spy.new(function() end)
        Polygon.IsChosen = function() return Questie.db.profile.enableQuestiePolygons == true end
        Polygon.IsEnabled = function()
            return Questie.db.profile.enableQuestiePolygons == true and Questie.db.profile.enableObjectives ~= false
                and Questie.db.profile.enabled ~= false
        end
        Polygon.RemoveObjective = spy.new(function() end)
        Polygon.UpdateObjective = spy.new(function() return nil, {} end)
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
        QuestLogCache.TryGetQuest = function() end
        QuestieCombatQueue = QuestieLoader:ImportModule("QuestieCombatQueue")
        QuestieCombatQueue.Queue = function() end
        CommsVisibility = QuestieLoader:ImportModule("CommsVisibility")
        CommsVisibility.ScheduleSnapshot = spy.new(function() end)
        l10n = QuestieLoader:ImportModule("l10n")
        setmetatable(l10n, {__call = function(_, key, ...) return key end})

        dofile("Modules/Quest/QuestieQuest.lua")
        QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")
    end)

    describe("polygon reset ownership", function()
        it("cancels polygon work before a repeated SmoothReset is deferred", function()
            QuestieQuest._isResetting = true
            QuestieQuest:SmoothReset()
            assert.spy(QuestieLoader:ImportModule("QuestiePolygon").Reset).was.called(1)
            assert.is_true(QuestieQuest._resetAgain)
            QuestieQuest._isResetting, QuestieQuest._resetAgain = nil, nil
        end)

        it("clears polygon ownership even when there are no normal notes to remove", function()
            QuestieMap.questIdFrames = {}
            QuestieQuest:ClearAllNotes()
            assert.spy(QuestieLoader:ImportModule("QuestiePolygon").Reset).was.called(1)
        end)
    end)

    describe("sequenced completion overrides", function()
        local quest, compat, originalIsSequenced, finisher
        local originalSendMessage, originalThreadCallback

        before_each(function()
            compat = QuestieLoader:ImportModule("QuestieCompat")
            originalIsSequenced = compat.IsQuestSequenced
            compat.IsQuestSequenced = function() return true end
            Questie.db.char.complete = {}
            quest = {
                Id = 93927, sourceItemId = 0, Objectives = {{Completed = true}},
                ObjectiveData = {}, SpecialObjectives = {}, Finisher = {NPC = {100}},
                IsComplete = function() return 0 end,
            }
            QuestieDB.GetQuest = function() return quest end
            finisher = QuestieLoader:ImportModule("QuestFinisher")
            finisher.AddFinisher = spy.new(function() end)
            AvailableQuests.RemoveQuest = spy.new(function(_, callback) if callback then callback() end end)
            originalThreadCallback = QuestieLoader:ImportModule("ThreadLib").ThreadCallbackInstant
            QuestieLoader:ImportModule("ThreadLib").ThreadCallbackInstant = function(work, callback)
                work()
                callback()
            end
            QuestieMap.UnloadQuestFrames = function() end
            originalSendMessage = Questie.SendMessage
            Questie.SendMessage = spy.new(function() end)
            QuestieQuest.UpdateObjectiveNotes = spy.new(function() end)
            QuestieQuest.ShouldShowQuestNotes = function() return true end
        end)

        after_each(function()
            compat.IsQuestSequenced = originalIsSequenced
            Questie.SendMessage = originalSendMessage
            QuestieLoader:ImportModule("ThreadLib").ThreadCallbackInstant = originalThreadCallback
        end)

        it("updates a finished visible stage without promoting the whole quest to complete", function()
            QuestieQuest.PopulateQuestLogInfo = function() end

            QuestieQuest:UpdateQuest(93927)

            assert.is_nil(quest.isComplete)
            assert.is_nil(quest.WasComplete)
            assert.spy(finisher.AddFinisher).was.not_called()
            assert.spy(QuestieQuest.UpdateObjectiveNotes).was.called_with(QuestieQuest, quest)
        end)

        it("keeps the legacy all-objectives-complete workaround for unclassified quests", function()
            compat.IsQuestSequenced = function() return false end
            QuestieQuest.PopulateQuestLogInfo = function() end

            QuestieQuest:UpdateQuest(93927)

            assert.is_true(quest.isComplete)
            assert.is_true(quest.WasComplete)
            assert.spy(finisher.AddFinisher).was.called_with(quest)
        end)

        it("does not infer completion from mapped objectives while an unmapped native row is unfinished", function()
            compat.IsQuestSequenced = function() return false end
            QuestieQuest.PopulateQuestLogInfo = function() end
            -- Unending Torment (97291): the database maps 1 of the client's 3 item rows.
            QuestLogCache.TryGetQuest = function()
                return {objectives = {{finished = true}, {finished = true}, {finished = false}}}
            end

            QuestieQuest:UpdateQuest(93927)

            assert.is_nil(quest.isComplete)
            assert.is_nil(quest.WasComplete)
            assert.spy(finisher.AddFinisher).was.not_called()
        end)

        it("shows the finisher when the accepted quest state is complete", function()
            QuestieQuest.PopulateQuestLogInfo = function() end
            QuestieQuest.RegisterObjectiveTooltips = function() end
            quest.IsComplete = function() return 1 end

            QuestieQuest:UpdateQuest(93927)

            assert.is_true(quest.WasComplete)
            assert.spy(finisher.AddFinisher).was.called_with(quest)
        end)

        it("does not infer completion from absent objective mappings even when a finisher exists", function()
            quest.Objectives = {}
            QuestLogCache.GetQuest = function() return {isComplete = 0} end
            QuestieQuest.GetAllLeaderBoardDetails = function()
                return {{type = "item", text = "Read note: 0/1"}}
            end

            QuestieQuest:PopulateQuestLogInfo(quest)

            assert.is_nil(quest.isComplete)
            assert.spy(finisher.AddFinisher).was.not_called()
        end)

        it("does not infer completion from absent objective mappings while a native row is unfinished", function()
            compat.IsQuestSequenced = function() return false end
            quest.Objectives = {}
            QuestLogCache.GetQuest = function() return {isComplete = 0} end
            -- Destruction in Deadmines (92753): the database has no objectives, the client one unfinished row.
            QuestieQuest.GetAllLeaderBoardDetails = function()
                return {{type = "monster", text = "0/1 Explosives placed", finished = false}}
            end

            QuestieQuest:PopulateQuestLogInfo(quest)

            assert.is_nil(quest.isComplete)
            assert.spy(finisher.AddFinisher).was.not_called()
        end)

        it("does not infer completion from an empty stage or a trigger-end location", function()
            quest.Objectives = {}
            quest.triggerEnd = {1}
            QuestLogCache.GetQuest = function() return {isComplete = 0} end
            QuestieQuest.GetAllLeaderBoardDetails = function() return {} end

            QuestieQuest:PopulateQuestLogInfo(quest)

            assert.is_nil(quest.isComplete)
            assert.spy(finisher.AddFinisher).was.not_called()
        end)

        -- The cache infers completion for a quest the client lists no rows for, though Blizzard reports it incomplete.
        -- Each finisher request draws a full set of icons, so a second one stacks copies on the turn-in.
        it("requests the finisher of a complete quest without objectives once", function()
            quest.Objectives = {}
            quest.IsComplete = function() return 1 end
            QuestLogCache.GetQuest = function() return {isComplete = 1} end
            QuestieQuest.GetAllLeaderBoardDetails = function() return {} end
            QuestieQuest.RegisterObjectiveTooltips = function() end

            QuestieQuest:UpdateQuest(93927)

            assert.is_true(quest.isComplete)
            assert.spy(finisher.AddFinisher).was.called(1)
            assert.spy(finisher.AddFinisher).was.called_with(quest)
        end)

        it("gives a failed quest without objective mappings no finisher", function()
            compat.IsQuestSequenced = function() return false end
            quest.Objectives = {}
            QuestLogCache.GetQuest = function() return {isComplete = -1} end
            QuestieQuest.GetAllLeaderBoardDetails = function() return {} end

            QuestieQuest:PopulateQuestLogInfo(quest)

            assert.is_nil(quest.isComplete)
            assert.spy(finisher.AddFinisher).was.not_called()
        end)

        it("still requests source-item reconstruction without promoting a sequenced quest", function()
            quest.sourceItemId = 254871
            QuestLogCache.GetQuest = function() return {isComplete = 0} end
            QuestieQuest.GetAllLeaderBoardDetails = function() return {} end
            QuestieQuest.CheckQuestSourceItem = spy.new(function() return false end)
            QuestieQuest.PopulateObjectiveNotes = spy.new(function() end)

            QuestieQuest:UpdateQuest(93927)

            assert.spy(QuestieQuest.CheckQuestSourceItem).was.called_with(QuestieQuest, 93927, true)
            assert.spy(QuestieQuest.PopulateObjectiveNotes).was.called_with(QuestieQuest, quest)
            assert.is_nil(quest.isComplete)
            assert.is_nil(quest.WasComplete)
            assert.spy(finisher.AddFinisher).was.not_called()
        end)

        it("preserves accepted completion when no database objectives exist", function()
            quest.Objectives = {}
            QuestLogCache.GetQuest = function() return {isComplete = 1} end
            QuestieQuest.GetAllLeaderBoardDetails = function() return {} end

            QuestieQuest:PopulateQuestLogInfo(quest)

            assert.is_true(quest.isComplete)
        end)
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

    describe("AddToQuestLog", function()
        before_each(function()
            QuestieQuest.UpdateQuest = spy.new(function() end)
            QuestieQuest.CheckQuestSourceItem = spy.new(function() end)
            QuestieQuest.PopulateQuestLogInfo = spy.new(function() end)
            QuestieQuest.ShouldShowQuestNotes = function() return true end
            QuestieQuest.PopulateObjectiveNotes = spy.new(function() end)
        end)

        it("leaves a failed quest to UpdateQuest, which draws it as available again", function()
            local quest = {Id = 5, IsComplete = function() return -1 end}

            QuestieQuest:AddToQuestLog(quest)

            assert.are.equal(quest, QuestiePlayer.currentQuestlog[5])
            assert.spy(QuestieQuest.UpdateQuest).was.called_with(QuestieQuest, 5)
            assert.spy(QuestieQuest.PopulateObjectiveNotes).was.not_called()
        end)

        it("hides the icons the tracker hid before drawing the quest's notes", function()
            Questie.db.char.TrackerHiddenQuests = {[5] = true}
            Questie.db.char.TrackerHiddenObjectives = {["5 2"] = true}
            local quest = {Id = 5, IsComplete = function() return 0 end, Objectives = {{Index = 1}, {Index = 2}}, SpecialObjectives = {}}
            local hiddenWhenDrawn
            QuestieQuest.PopulateObjectiveNotes = spy.new(function()
                hiddenWhenDrawn = {quest.HideIcons, quest.Objectives[1].HideIcons, quest.Objectives[2].HideIcons}
            end)

            QuestieQuest:AddToQuestLog(quest)

            assert.are.equal(quest, QuestiePlayer.currentQuestlog[5])
            assert.spy(QuestieQuest.CheckQuestSourceItem).was.called_with(QuestieQuest, 5, true)
            assert.are.same({true, nil, true}, hiddenWhenDrawn)
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

        it("does not warn for a log objective with no objective data table", function()
            QuestieQuest.GetAllLeaderBoardDetails = function()
                return {{type = "log", text = "Read the note."}}
            end
            local quest = {Id = 42, Objectives = {}, SpecialObjectives = {}}

            QuestieQuest:PopulateQuestLogInfo(quest)

            assert.spy(Questie.Warning).was.not_called()
            assert.are_same({}, quest.Objectives)
        end)

        it("does not warn for a log objective with no mapped objective data entry", function()
            QuestieQuest.GetAllLeaderBoardDetails = function()
                return {{type = "log", text = "Read the note."}}
            end
            local quest = {Id = 42, ObjectiveData = {}, Objectives = {}, SpecialObjectives = {}}

            QuestieQuest:PopulateQuestLogInfo(quest)

            assert.spy(Questie.Warning).was.not_called()
            assert.are_same({}, quest.Objectives)
        end)

        it("warns with the quest ID and text when non-log objective data is missing", function()
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
        local originalLibStub
        before_each(function()
            originalLibStub = _G.LibStub
            _G.LibStub = function()
                return {GetWorldCoordinatesFromZone = function(_, x, y) return x, y, 1 end}
            end
            dofile("Modules/Quest/QuestieQuest.lua")
            QuestieQuest.private.objectiveSpawnListCallTable = {}
        end)
        after_each(function() _G.LibStub = originalLibStub end)

        it("leaves both maps to the polygon cluster markers, drawing no ordinary objective icons", function()
            Questie.db.profile = {enableQuestiePolygons = true, enableObjectives = true, objectiveFilterDistance = 0}
            local Phasing = QuestieLoader:ImportModule("Phasing")
            Phasing.IsSpawnVisible = function() return true end
            ZoneDB.GetUiMapIdByAreaId = function() return 10 end
            ZoneDB.GetDungeonLocation = function() return nil end
            QuestieLoader:ImportModule("QuestieLib").Euclid = function() return 0 end
            QuestieMap.DrawWorldIcon = spy.new(function() return nil, {name = "minimap"} end)
            local Polygon = QuestieLoader:ImportModule("QuestiePolygon")
            local objective = {Index = 1, Description = "Wolves", Type = "monster", Update = function() end,
                Color = {1, 1, 1}, AlreadySpawned = {}, spawnList = {[123] = {Id = 123, Name = "Wolf", Icon = 1,
                    GetIconScale = function() return 1 end, Spawns = {[1] = {{10, 20}}}}}}
            local quest = {Id = 42, Color = {1, 1, 1}, ObjectiveData = {objective}}
            QuestieLoader:ImportModule("QuestieTooltips").RegisterObjectiveTooltip = function() end
            local thread = coroutine.create(function() QuestieQuest:PopulateObjective(quest, 1, objective, false) end)

            local ok, err = coroutine.resume(thread)
            assert.is_true(ok, err)
            assert.spy(QuestieMap.DrawWorldIcon).was.not_called()
            assert.are.same({}, objective.AlreadySpawned)
            -- Nameplates still read the objective's icon.
            assert.are.equal(1, objective.Icon)
            assert.spy(Polygon.UpdateObjective).was.called_with(quest, objective, 1)
        end)

        it("draws no ordinary objective icons in polygon mode while Questie or its objectives are off", function()
            QuestieLoader:ImportModule("Phasing").IsSpawnVisible = function() return true end
            ZoneDB.GetUiMapIdByAreaId = function() return 10 end
            ZoneDB.GetDungeonLocation = function() return nil end
            QuestieLoader:ImportModule("QuestieLib").Euclid = function() return 0 end
            QuestieLoader:ImportModule("QuestieTooltips").RegisterObjectiveTooltip = function() end
            local Polygon = QuestieLoader:ImportModule("QuestiePolygon")
            -- Switching Questie or its objectives off and on again repopulates every objective. Ordinary
            -- icons drawn while off would show beside the areas once on again.
            for _, switchedOff in ipairs({{enabled = false}, {enableObjectives = false}}) do
                Questie.db.profile = {enableQuestiePolygons = true, enableObjectives = true, objectiveFilterDistance = 0}
                for key, value in pairs(switchedOff) do Questie.db.profile[key] = value end
                QuestieMap.DrawWorldIcon = spy.new(function() return {name = "map"}, {name = "minimap"} end)
                Polygon.UpdateObjective:clear()
                local objective = {Index = 1, Description = "Wolves", Type = "monster", Update = function() end,
                    Color = {1, 1, 1}, AlreadySpawned = {}, spawnList = {[123] = {Id = 123, Name = "Wolf", Icon = 1,
                        GetIconScale = function() return 1 end, Spawns = {[1] = {{10, 20}}}}}}
                local quest = {Id = 42, Color = {1, 1, 1}, ObjectiveData = {objective}}
                local thread = coroutine.create(function() QuestieQuest:PopulateObjective(quest, 1, objective, false) end)

                local ok, err = coroutine.resume(thread)
                assert.is_true(ok, err)
                assert.spy(QuestieMap.DrawWorldIcon).was.not_called()
                assert.are.same({}, objective.AlreadySpawned)
                -- The polygon path itself draws nothing while switched off.
                assert.spy(Polygon.UpdateObjective).was.called_with(quest, objective, 1)
            end
        end)

        it("retains paired ordinary icons for party objectives even in polygon mode", function()
            Questie.db.profile = {enableQuestiePolygons = true, enableObjectives = true, objectiveFilterDistance = 0}
            QuestieLoader:ImportModule("Phasing").IsSpawnVisible = function() return true end
            ZoneDB.GetUiMapIdByAreaId = function() return 10 end
            ZoneDB.GetDungeonLocation = function() return nil end
            QuestieLoader:ImportModule("QuestieLib").Euclid = function() return 0 end
            QuestieMap.DrawWorldIcon = spy.new(function() return {name = "map"}, {name = "minimap"} end)
            local objective = {Index = 1, Description = "Wolves", Type = "monster", IsPartyObjective = true,
                Update = function() end, Color = {1, 1, 1}, AlreadySpawned = {}, spawnList = {[123] = {Id = 123,
                    Name = "Wolf", Icon = 1, GetIconScale = function() return 1 end, Spawns = {[1] = {{10, 20}}}}}}
            local quest = {Id = 42, Color = {1, 1, 1}, ObjectiveData = {objective}}
            QuestieLoader:ImportModule("QuestieTooltips").RegisterObjectiveTooltip = function() end
            local thread = coroutine.create(function() QuestieQuest:PopulateObjective(quest, 1, objective, false) end)

            local ok, err = coroutine.resume(thread)
            assert.is_true(ok, err)
            assert.is_nil(QuestieMap.DrawWorldIcon.calls[1].vals[8])
            assert.are.equal(1, #objective.AlreadySpawned[123].mapRefs)
            assert.are.equal(1, #objective.AlreadySpawned[123].minimapRefs)
            assert.spy(QuestieLoader:ImportModule("QuestiePolygon").UpdateObjective).was.not_called()
        end)

        it("draws each patrol for the NPC's icon in its zone, adding an icon where none is", function()
            Questie.db.profile = {enableQuestiePolygons = false, enableObjectives = true, objectiveFilterDistance = 0}
            QuestieLoader:ImportModule("Phasing").IsSpawnVisible = function() return true end
            ZoneDB.GetUiMapIdByAreaId = function(_, areaId) return areaId * 10 end
            ZoneDB.GetDungeonLocation = function() return nil end
            QuestieLoader:ImportModule("QuestieLib").Euclid = function() return 0 end
            QuestieLoader:ImportModule("QuestieTooltips").RegisterObjectiveTooltip = function() end
            local mapFrames = {}
            QuestieMap.DrawWorldIcon = spy.new(function(_, data, areaId, x, y)
                local mapFrame = {data = data, AreaID = areaId, x = x, y = y}
                mapFrames[#mapFrames + 1] = mapFrame
                return mapFrame, {data = data, AreaID = areaId, miniMapIcon = true}
            end)
            QuestieMap.DrawWaypoints = spy.new(function() end)
            local objective = {Index = 1, Description = "Wolves", Type = "monster", Update = function() end,
                Color = {1, 1, 1}, AlreadySpawned = {}, spawnList = {[123] = {Id = 123, Name = "Wolf", Icon = 1,
                    GetIconScale = function() return 1 end, Spawns = {[1] = {{10, 20}}}, TooltipKey = "m_123",
                    Hostile = true, Waypoints = {[2] = {{{30, 40}, {40, 50}}}}}}}
            local quest = {Id = 42, Color = {1, 1, 1}, ObjectiveData = {objective}}
            local thread = coroutine.create(function() QuestieQuest:PopulateObjective(quest, 1, objective, false) end)
            while coroutine.status(thread) ~= "dead" do
                local ok, err = coroutine.resume(thread)
                assert.is_true(ok, err)
            end

            -- The wolf's icon in zone 1, and a pair in zone 2, which only its patrol reaches.
            assert.are.equal(2, #mapFrames)
            assert.are.same({2, 30, 40}, {mapFrames[2].AreaID, mapFrames[2].x, mapFrames[2].y})
            assert.are.same({2, 2}, {#objective.AlreadySpawned[123].mapRefs, #objective.AlreadySpawned[123].minimapRefs})
            assert.spy(QuestieMap.DrawWaypoints).was.called(1)
            local call = QuestieMap.DrawWaypoints.calls[1]
            assert.are.equal(mapFrames[2], call.refs[2])
            assert.are.same({"m_123", 2, true}, {call.refs[3], call.refs[5], call.refs[6]})
            assert.spy(QuestieLoader:ImportModule("QuestiePolygon").UpdateObjective).was.not_called()
        end)

        it("removes completed special-objective polygons using the canonical objective index", function()
            local objective = {Index = 65, Description = "Special", Type = "event", Completed = true,
                Update = function() end, spawnList = {}, AlreadySpawned = {}}
            local thread = coroutine.create(function()
                QuestieQuest:PopulateObjective({Id = 42, ObjectiveData = {}}, 0, objective, false)
            end)
            assert.is_true(coroutine.resume(thread))
            assert.spy(QuestieLoader:ImportModule("QuestiePolygon").RemoveObjective).was.called_with(42, 65)
        end)

        it("colors special objectives by their canonical index, not the shared index 0", function()
            local ObjectiveColors = QuestieLoader:ImportModule("ObjectiveColors")
            local originalGet = ObjectiveColors.Get
            local color = {0.1, 0.2, 0.3}
            local getColor = spy.new(function() return color end)
            ObjectiveColors.Get = getColor
            local objective = {Index = 65, Description = "Special", Type = "event", Completed = false,
                Update = function() end, spawnList = {}, AlreadySpawned = {}}
            local quest = {Id = 42, ObjectiveData = {}}
            local thread = coroutine.create(function()
                QuestieQuest:PopulateObjective(quest, 0, objective, false)
            end)
            local ok, err = coroutine.resume(thread)
            ObjectiveColors.Get = originalGet
            assert.is_true(ok, err)
            assert.spy(getColor).was.called(1)
            -- The spy keeps copies made at call time, before PopulateObjective stored the color.
            local args = getColor.calls[1].vals
            assert.are.same({42, 65, 65}, {args[1].Id, args[2].Index, args[3]})
            assert.are.equal(color, objective.Color)
        end)

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

    describe("no-map dungeon objectives", function()
        local entrances, draws, replacements

        local function replace(owner, key, value)
            replacements[#replacements + 1] = {owner, key, owner[key]}
            owner[key] = value
        end

        before_each(function()
            replacements, draws = {}, {}
            entrances = {{1537, 27.63, 47.83}} -- The Hall of Thanes -> Ironforge
            replace(_G, "LibStub", function() return {GetWorldCoordinatesFromZone = function() end} end)
            replace(Questie, "Warning", spy.new(function() end))
            replace(Questie.db, "profile", {enableObjectives = true, objectiveFilterDistance = 0})
            replace(ZoneDB, "GetUiMapIdByAreaId", function(_, area) if area == 1537 then return 1455 end end)
            replace(ZoneDB, "GetDungeonLocation", function() return entrances end)
            replace(QuestieLoader:ImportModule("Phasing"), "IsSpawnVisible", function() return true end)
            replace(QuestieLoader:ImportModule("QuestieTooltips"), "RegisterObjectiveTooltip", function() end)
            replace(QuestieLoader:ImportModule("QuestieLib"), "Euclid", function() return 0 end)
            replace(QuestieMap, "DrawWorldIcon", function(_, data, area, x, y)
                draws[#draws + 1] = {area, x, y, data.ObjectiveTargetId}
                return {}, {}
            end)
            dofile("Modules/Quest/QuestieQuest.lua")
            QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")
        end)

        after_each(function()
            for index = #replacements, 1, -1 do
                local entry = replacements[index]
                entry[1][entry[2]] = entry[3]
            end
        end)

        local function populate()
            local objective = {
                Id = 673474, Index = 1, Type = "object", Description = "Treaty of Understanding",
                Update = function() end, Color = {}, AlreadySpawned = {},
                spawnList = {[673474] = {
                    Id = 673474, Name = "Treaty of Understanding", Spawns = {[16919] = {{-1, -1}}},
                    GetIconScale = function() return 1 end,
                }},
            }
            local quest = {Id = 96403, ObjectiveData = {objective}, Color = {}}
            coroutine.wrap(function() QuestieQuest:PopulateObjective(quest, 1, objective, false) end)()
            return objective
        end

        it("draws the entrance without a dungeon UiMap or a 0 override", function()
            local objective = populate()

            assert.are.same({{1537, 27.63, 47.83, 673474}}, draws)
            assert.are.equal(1, #objective.AlreadySpawned[673474].mapRefs)
            assert.spy(Questie.Warning).was.not_called()
        end)

        it("keeps both entrances and their frame references", function()
            entrances[2] = {1537, 40, 50}
            local objective = populate()

            assert.are.same({{1537, 40, 50, 673474}, {1537, 27.63, 47.83, 673474}}, draws)
            assert.are.equal(2, #objective.AlreadySpawned[673474].mapRefs)
            assert.are.equal(2, #objective.AlreadySpawned[673474].minimapRefs)
        end)

        it("reports a missing entrance instead of indexing by nil", function()
            entrances = nil
            populate()

            assert.are.same({}, draws)
            assert.spy(Questie.Warning).was.called_with("[QuestieQuest] Cannot draw quest", 96403, "target", 673474,
                "area", 16919, "missing dungeon entrance or UiMap mapping")
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

    describe("objective spawn lists", function()
        local saved, Corrections

        before_each(function()
            Corrections = QuestieLoader:ImportModule("QuestieCorrections")
            saved = {QueryObjectSingle = QuestieDB.QueryObjectSingle, QueryNPCSingle = QuestieDB.QueryNPCSingle,
                GetItem = QuestieDB.GetItem, blacklist = Corrections.questNPCBlacklist}
            Questie.db.profile = {}
            Corrections.questNPCBlacklist = {}
            QuestieDB.QueryObjectSingle = function(_, field) return ({name = "Crate", spawns = {[1] = {{30, 40}}}})[field] end
            QuestieDB.QueryNPCSingle = function(_, field) return ({name = "Wolf", spawns = {[1] = {{10, 20}}}, rank = 0})[field] end
            QuestieDB.GetItem = function()
                return {Id = 7, Sources = {{Type = "object", Id = 456}, {Type = "monster", Id = 123}}}
            end
            dofile("Modules/Quest/QuestieQuestPrivates.lua")
        end)

        after_each(function()
            QuestieDB.QueryObjectSingle, QuestieDB.QueryNPCSingle, QuestieDB.GetItem = saved.QueryObjectSingle,
                saved.QueryNPCSingle, saved.GetItem
            Corrections.questNPCBlacklist = saved.blacklist
        end)

        it("marks game objects, directly and as item sources, but never creatures", function()
            local build, objective = QuestieQuest.private.objectiveSpawnListCallTable, {Description = "Crates"}
            assert.is_true(build.object(456, objective)[456].IsObject)
            local itemSources = build.item(7, objective)
            assert.is_true(itemSources[456].IsObject)
            assert.is_nil(itemSources[123].IsObject)
            assert.is_nil(build.monster(123, objective)[123].IsObject)
        end)
    end)
end)
