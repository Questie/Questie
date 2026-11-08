dofile("setupTests.lua")

describe("QuestiePartyObjectives", function()
    ---@type QuestiePartyObjectives
    local QuestiePartyObjectives
    ---@type QuestieComms
    local QuestieComms
    ---@type QuestieQuest
    local QuestieQuest
    ---@type QuestieDB
    local QuestieDB
    ---@type QuestieLib
    local QuestieLib
    ---@type QuestieFramePool
    local QuestieFramePool
    ---@type QuestLogCache
    local QuestLogCache
    ---@type ThreadLib
    local ThreadLib
    ---@type QuestiePlayer
    local QuestiePlayer
    ---@type CommsVisibility
    local CommsVisibility
    ---@type GamepadMapHover
    local GamepadMapHover
    ---@type MapIconTooltip
    local MapIconTooltip

    local QUEST_ID = 42
    -- Mirrors MAX_PARTY_ICONS in the module, which is a file-local constant. Keep in sync.
    local MAX_PARTY_ICONS = 500

    -- Queue thread bodies instead of running them, so a test controls when (and whether) they run.
    -- This mirrors ThreadLib.ThreadInstant, which never runs its body synchronously. A fake that
    -- runs inline cannot observe this class of bug at all.
    local pendingThreads
    local allowThreadErrors

    -- Objectives handed to PopulateObjective, in draw order, so a test can reach the frames that
    -- were produced. The module keeps them in a file-local table.
    local drawnObjectives

    -- Per draw, whether the objective arrived with a spawn list already built (i.e. from the cache).
    local spawnListPrefilled

    local function runPendingThreads()
        local queued = pendingThreads
        pendingThreads = {}
        for _, body in ipairs(queued) do
            body()
        end
    end

    -- Capture the callbacks passed to ContinueOnQuestObjectivesLoad so a test can invoke them
    -- manually when ready (simulating the async load completing or failing).
    local pendingObjectiveLoadSuccess
    local pendingObjectiveLoadFailure
    local function mockContinueOnQuestObjectivesLoad()
        return function(_, onSuccess, onFailure)
            pendingObjectiveLoadSuccess = onSuccess
            pendingObjectiveLoadFailure = onFailure
        end
    end

    ---Build one or more party quests, each drawing the given number of map and minimap icons.
    ---@param spec table<number, number> @questId -> icons drawn per objective
    local function givenPartyQuests(spec)
        QuestieComms.remoteQuestLogs = {}
        for questId in pairs(spec) do
            QuestieComms.remoteQuestLogs[questId] = {
                ["Partymember"] = {
                    [1] = {finished = false, type = "m", id = 100},
                },
            }
        end

        QuestieDB.GetQuest = function(questId)
            return {
                Id = questId,
                Color = {1, 1, 1},
                ObjectiveData = {[1] = {Type = "monster", Id = 100, Text = "Kill things"}},
                -- What the local quest draws itself: only objectives with ObjectiveData have one
                Objectives = {[1] = {Id = 100}},
                SpecialObjectives = {},
            }
        end

        -- Stand in for the real draw: populate AlreadySpawned with the frames it would have created.
        QuestieQuest.PopulateObjective = function(_, quest, _, objective)
            -- Record whether the pipeline handed us a pre-built spawn list before we overwrite it.
            spawnListPrefilled[#spawnListPrefilled + 1] = next(objective.spawnList) ~= nil
            -- The real PopulateObjective builds the spawn list when it arrives empty.
            objective.spawnList[1] = {Name = "spawn", Spawns = {}}

            local mapRefs = {}
            local minimapRefs = {}
            for i = 1, (spec[quest.Id] or 0) do
                mapRefs[i] = {data = objective}
                minimapRefs[i] = {data = objective}
            end
            objective.AlreadySpawned[1] = {data = objective, mapRefs = mapRefs, minimapRefs = minimapRefs}
            drawnObjectives[#drawnObjectives + 1] = objective
        end
    end

    -- A member finished another objective, so the quest's icons must be redrawn
    local function givenFinishedObjective(questId)
        QuestieComms.remoteQuestLogs[questId].Partymember[2] = {finished = true, type = "m", id = 101}
    end

    ---@param spawnCount number
    local function givenPartyQuest(spawnCount)
        givenPartyQuests({[QUEST_ID] = spawnCount})
    end

    -- Same DB/comms type, but the API wording can differ from the target name.
    local function givenPartyQuestWithUnloadedText()
        givenPartyQuest(1)
        QuestieLib.ContinueOnQuestObjectivesLoad = mockContinueOnQuestObjectivesLoad()
    end

    before_each(function()
        pendingThreads = {}
        drawnObjectives = {}
        spawnListPrefilled = {}
        pendingObjectiveLoadSuccess = nil
        pendingObjectiveLoadFailure = nil

        Questie.db.profile.showPartyQuestObjectives = true
        Questie.db.profile.enableObjectives = true

        _G.UnitIsConnected = function() return true end
        _G.GetNumGroupMembers = function() return 2 end
        _G.HaveQuestData = function() return true end
        -- Fire the debounce immediately so ScheduleUpdate is synchronous and a test can drive
        -- quests one at a time in a deterministic order (a full Update() clears everything first).
        _G.C_Timer = {After = function(_, callback) callback() end}

        QuestieComms = QuestieLoader:ImportModule("QuestieComms")
        QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")
        QuestieDB = QuestieLoader:ImportModule("QuestieDB")
        dofile("Modules/Libs/QuestieLib.lua")
        QuestieLib = QuestieLoader:ImportModule("QuestieLib")
        QuestieFramePool = QuestieLoader:ImportModule("QuestieFramePool")
        QuestLogCache = QuestieLoader:ImportModule("QuestLogCache")
        ThreadLib = QuestieLoader:ImportModule("ThreadLib")
        QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
        CommsVisibility = QuestieLoader:ImportModule("CommsVisibility")
        GamepadMapHover = QuestieLoader:ImportModule("GamepadMapHover")
        GamepadMapHover.RefreshQuest = spy.new(function() end)
        MapIconTooltip = QuestieLoader:ImportModule("MapIconTooltip")
        MapIconTooltip.RefreshQuest = spy.new(function() end)

        QuestiePlayer.GetGroupType = function() return "party" end
        CommsVisibility.ShouldShowPartyObjective = function() return true end
        QuestieLib.ColorWheel = function() return {1, 1, 1} end
        -- Drawing/lifetime tests do not wait on API data. Loading tests capture callbacks explicitly.
        QuestieLib.ContinueOnQuestObjectivesLoad = function(_, onSuccess)
            onSuccess({})
        end
        QuestieFramePool.UnloadFrame = spy.new(function() end)
        QuestLogCache.questLog_DO_NOT_MODIFY = {}

        -- Like the real library, a failing thread calls its error callback; unexpected failures still fail the test
        allowThreadErrors = false
        ThreadLib.Thread = function(body, _, _, _, onError)
            pendingThreads[#pendingThreads + 1] = function()
                local ok, err = pcall(body)
                if not ok then
                    if onError then
                        onError(err)
                    end
                    if not (allowThreadErrors and onError) then
                        error(err, 0)
                    end
                end
            end
        end

        dofile("Modules/Network/QuestiePartyObjectives.lua")
        QuestiePartyObjectives = QuestieLoader:ImportModule("QuestiePartyObjectives")

        QuestiePartyObjectives:Clear()
    end)

    describe("Update", function()
        it("should record what it drew so Clear can unload it", function()
            givenPartyQuest(3)

            QuestiePartyObjectives:Update()
            runPendingThreads()

            QuestiePartyObjectives:Clear()

            -- 3 map + 3 minimap frames. Previously the entry was only published after the draw
            -- threads were scheduled, when the objective list was still empty, so it was never
            -- published at all and Clear had nothing to unload.
            assert.spy(QuestieFramePool.UnloadFrame).was.called(6)
        end)

        it("should unload the previous icons when the same quest is redrawn", function()
            givenPartyQuest(2)

            QuestiePartyObjectives:Update()
            runPendingThreads()

            QuestiePartyObjectives:Update()
            runPendingThreads()

            -- A redraw clears first. With the draw unrecorded, every refresh stacked another copy
            -- of the icons instead of replacing them.
            assert.spy(QuestieFramePool.UnloadFrame).was.called(4)
        end)

        it("should draw nothing when the quest was already cleared before the thread ran", function()
            givenPartyQuest(2)

            QuestiePartyObjectives:Update()

            -- Cleared while the draw threads are still queued.
            QuestiePartyObjectives:Clear()
            runPendingThreads()

            -- The pre-draw staleness check means no frames are created, so none need releasing.
            assert.spy(QuestieFramePool.UnloadFrame).was.not_called()

            -- Nothing was adopted either, so a later Clear finds nothing.
            QuestiePartyObjectives:Clear()
            assert.spy(QuestieFramePool.UnloadFrame).was.not_called()
        end)

        it("should release icons when the quest is cleared while the draw is in progress", function()
            givenPartyQuest(2)

            -- PopulateObjective yields in production, so the quest can be cleared midway through it.
            local populate = QuestieQuest.PopulateObjective
            QuestieQuest.PopulateObjective = function(self, quest, objectiveIndex, objective, block)
                populate(self, quest, objectiveIndex, objective, block)
                QuestiePartyObjectives:Clear()
            end

            QuestiePartyObjectives:Update()
            runPendingThreads()

            -- The post-draw check must release what was drawn rather than charge it to a quest
            -- that is no longer current.
            assert.spy(QuestieFramePool.UnloadFrame).was.called(4)
        end)

        it("should not adopt icons when the group grew past the draw threshold", function()
            givenPartyQuest(2)

            QuestiePartyObjectives:Update()

            -- Party converts to a raid. GROUP_ROSTER_UPDATE schedules a refresh, but Clear only runs
            -- once the 1.5s debounce fires, so the entry is still current here: only _ShouldDraw()
            -- reveals that these icons must not be adopted.
            _G.GetNumGroupMembers = function() return 12 end

            runPendingThreads()

            QuestieFramePool.UnloadFrame = spy.new(function() end)
            QuestiePartyObjectives:Clear()
            assert.spy(QuestieFramePool.UnloadFrame).was.not_called()
        end)

        it("should reject an objective that on its own exceeds the icon budget", function()
            -- The scheduling loop can only check the budget against what is already adopted; an
            -- objective's own icon count is unknown until PopulateObjective has run.
            givenPartyQuest(MAX_PARTY_ICONS + 1)

            QuestiePartyObjectives:Update()
            runPendingThreads()

            -- Every frame it drew is released: map + minimap.
            assert.spy(QuestieFramePool.UnloadFrame).was.called((MAX_PARTY_ICONS + 1) * 2)

            -- And none of it was adopted, so there is nothing left for Clear to find.
            QuestieFramePool.UnloadFrame = spy.new(function() end)
            QuestiePartyObjectives:Clear()
            assert.spy(QuestieFramePool.UnloadFrame).was.not_called()
        end)

        it("should draw nothing at all once the icon budget is exhausted", function()
            local otherQuest = QUEST_ID + 1
            givenPartyQuests({[QUEST_ID] = MAX_PARTY_ICONS, [otherQuest] = 2})

            QuestiePartyObjectives:ScheduleUpdate(QUEST_ID)
            runPendingThreads()
            assert.is_equal(1, #drawnObjectives) -- budget now fully spent

            -- The second quest must be abandoned before anything is drawn. Reaching PopulateObjective
            -- would allocate frames only to release them, and a frame unloaded while still queued
            -- merely sets _needsUnload, so ProcessQueue publishes it to HBD for a tick first.
            QuestiePartyObjectives:ScheduleUpdate(otherQuest)
            runPendingThreads()

            assert.is_equal(1, #drawnObjectives)
        end)

        it("should not draw a quest the local player also has", function()
            givenPartyQuest(2)

            -- The local player's own pipeline draws this quest's objectives, so drawing it as a
            -- party objective too would double up on the same questIdFrames key.
            QuestLogCache.questLog_DO_NOT_MODIFY = {[QUEST_ID] = {objectives = {{finished = false}}}}

            QuestiePartyObjectives:ScheduleUpdate(QUEST_ID)
            runPendingThreads()

            assert.is_equal(0, #drawnObjectives)
        end)

        it("should count adopted icons against the budget of later quests", function()
            local otherQuest = QUEST_ID + 1
            givenPartyQuests({[QUEST_ID] = 300, [otherQuest] = 300})

            -- Drawn one at a time so the order is deterministic; a full refresh iterates a hash table.
            QuestiePartyObjectives:ScheduleUpdate(QUEST_ID)
            runPendingThreads()

            QuestiePartyObjectives:ScheduleUpdate(otherQuest)
            runPendingThreads()

            -- 300 + 300 exceeds 500, so the second quest must be refused.
            QuestieFramePool.UnloadFrame = spy.new(function() end)
            QuestiePartyObjectives:Clear()
            assert.spy(QuestieFramePool.UnloadFrame).was.called(600) -- first quest only
        end)

        it("should return a redrawn quest's icons to the budget", function()
            givenPartyQuest(300)

            QuestiePartyObjectives:ScheduleUpdate(QUEST_ID)
            runPendingThreads()

            -- An incremental redraw clears the quest through _ClearQuest, which must refund the
            -- icons it released before the redraw is charged again. Without the refund the quest
            -- prices itself out: 300 already spent + 300 requested exceeds the ceiling, so the
            -- redraw is refused and the quest silently loses its icons.
            givenFinishedObjective(QUEST_ID)
            QuestiePartyObjectives:ScheduleUpdate(QUEST_ID)
            runPendingThreads()

            QuestieFramePool.UnloadFrame = spy.new(function() end)
            QuestiePartyObjectives:Clear()
            assert.spy(QuestieFramePool.UnloadFrame).was.called(600)
        end)

        it("should skip frames that were already recycled elsewhere", function()
            givenPartyQuest(2)

            QuestiePartyObjectives:ScheduleUpdate(QUEST_ID)
            runPendingThreads()

            -- Party icons share their questIdFrames key with the local player's own quest, so a
            -- frame can be unloaded and handed out again by the main pipeline. Unload clears
            -- frame.data, so a frame whose data no longer matches is not ours to release.
            local spawn = drawnObjectives[1].AlreadySpawned[1]
            spawn.mapRefs[1].data = {someoneElse = true}

            QuestieFramePool.UnloadFrame = spy.new(function() end)
            QuestiePartyObjectives:Clear()

            -- 2 minimap + 1 remaining map frame; the reused one is left alone.
            assert.spy(QuestieFramePool.UnloadFrame).was.called(3)
        end)

        it("should cache a standard objective's spawn list and reuse it on redraw", function()
            givenPartyQuest(2)

            QuestiePartyObjectives:ScheduleUpdate(QUEST_ID)
            runPendingThreads()

            -- Nothing cached yet, so the first draw builds the spawn list itself.
            assert.same({false}, spawnListPrefilled)

            givenFinishedObjective(QUEST_ID)
            QuestiePartyObjectives:ScheduleUpdate(QUEST_ID)
            runPendingThreads()

            -- The redraw must receive the cached list rather than rebuilding it. Spawn data is
            -- static per questId + objectiveIndex, so this is the module's main redraw saving.
            assert.same({false, true}, spawnListPrefilled)
        end)

        it("should route special objectives through the same scheduling path", function()
            givenPartyQuest(1)

            -- One special objective alongside the standard one, both routed through the shared
            -- scheduling helper so the budget is applied consistently.
            QuestieDB.GetQuest = function()
                return {
                    Id = QUEST_ID,
                    Color = {1, 1, 1},
                    ObjectiveData = {[1] = {Type = "monster", Id = 100, Text = "Kill things"}},
                    SpecialObjectives = {
                        {Id = 200, Type = "object", Description = "Use the thing", spawnList = {}},
                    },
                }
            end

            QuestiePartyObjectives:Update()
            runPendingThreads()

            QuestiePartyObjectives:Clear()

            -- Both objectives adopted: 2 frames each.
            assert.spy(QuestieFramePool.UnloadFrame).was.called(4)
        end)
    end)

    describe("incremental redraw", function()
        -- A second needed objective, drawn from the database like the first one
        local function givenSecondObjective()
            QuestieComms.remoteQuestLogs[QUEST_ID].Partymember[2] = {finished = false, type = "m", id = 101}
            QuestieDB.GetQuest = function()
                return {
                    Id = QUEST_ID,
                    Color = {1, 1, 1},
                    ObjectiveData = {
                        [1] = {Type = "monster", Id = 100, Text = "Kill things"},
                        [2] = {Type = "monster", Id = 101, Text = "Kill other things"},
                    },
                    SpecialObjectives = {},
                }
            end
        end

        it("should not redraw a quest when only the progress counts changed", function()
            givenPartyQuest(2)
            QuestiePartyObjectives:ScheduleUpdate(QUEST_ID)
            runPendingThreads()

            QuestieComms.remoteQuestLogs[QUEST_ID].Partymember[1].fulfilled = 3
            QuestiePartyObjectives:ScheduleUpdate(QUEST_ID)
            runPendingThreads()

            assert.is_equal(1, #drawnObjectives)
            assert.spy(QuestieFramePool.UnloadFrame).was.not_called()
        end)

        it("should not redraw a quest when another member reports the same needed objectives", function()
            givenPartyQuest(2)
            QuestiePartyObjectives:ScheduleUpdate(QUEST_ID)
            runPendingThreads()

            QuestieComms.remoteQuestLogs[QUEST_ID]["Othermember"] = {[1] = {finished = false, type = "m", id = 100}}
            QuestiePartyObjectives:ScheduleUpdate(QUEST_ID)
            runPendingThreads()

            assert.is_equal(1, #drawnObjectives)
        end)

        it("should redraw a quest whose icons were unloaded by someone else", function()
            givenPartyQuest(2)
            QuestiePartyObjectives:ScheduleUpdate(QUEST_ID)
            runPendingThreads()

            -- QuestieMap:UnloadQuestFrames of the local player's own quest unloads every icon of the quest id
            -- and forgets the objective's spawns
            local objective = drawnObjectives[1]
            objective.AlreadySpawned[1].mapRefs[1].data = nil
            objective.AlreadySpawned = {}
            QuestiePartyObjectives:ScheduleUpdate(QUEST_ID)
            runPendingThreads()

            assert.is_equal(2, #drawnObjectives)
        end)

        it("should redraw a quest when one of its icons was unloaded by someone else", function()
            givenPartyQuest(2)
            QuestiePartyObjectives:ScheduleUpdate(QUEST_ID)
            runPendingThreads()

            drawnObjectives[1].AlreadySpawned[1].minimapRefs[2].data = nil
            QuestiePartyObjectives:ScheduleUpdate(QUEST_ID)
            runPendingThreads()

            assert.is_equal(2, #drawnObjectives)
        end)

        it("should redraw a quest whose objective text arrived while the group was too large", function()
            givenPartyQuestWithUnloadedText()
            QuestiePartyObjectives:ScheduleUpdate(QUEST_ID)
            local onLoaded = pendingObjectiveLoadSuccess
            _G.GetNumGroupMembers = function() return 12 end
            onLoaded({{text = "Wolf slain: 1/5", type = "monster"}})
            runPendingThreads()
            _G.GetNumGroupMembers = function() return 2 end
            pendingObjectiveLoadSuccess = nil

            QuestiePartyObjectives:ScheduleUpdate(QUEST_ID)

            assert.is_not_nil(pendingObjectiveLoadSuccess)
        end)

        it("should redraw a quest whose objective text timed out while the group was too large", function()
            givenPartyQuestWithUnloadedText()
            QuestiePartyObjectives:ScheduleUpdate(QUEST_ID)
            local onFailed = pendingObjectiveLoadFailure
            _G.GetNumGroupMembers = function() return 12 end
            onFailed()
            runPendingThreads()
            _G.GetNumGroupMembers = function() return 2 end
            pendingObjectiveLoadSuccess = nil

            QuestiePartyObjectives:ScheduleUpdate(QUEST_ID)

            assert.is_not_nil(pendingObjectiveLoadSuccess)
        end)

        it("should refresh open tooltips instead of redrawing when only the progress changed", function()
            givenPartyQuest(2)
            QuestiePartyObjectives:ScheduleUpdate(QUEST_ID)
            runPendingThreads()
            assert.spy(GamepadMapHover.RefreshQuest).was.not_called()
            assert.spy(MapIconTooltip.RefreshQuest).was.not_called()

            QuestieComms.remoteQuestLogs[QUEST_ID].Partymember[1].fulfilled = 3
            QuestiePartyObjectives:ScheduleUpdate(QUEST_ID)
            runPendingThreads()

            assert.spy(GamepadMapHover.RefreshQuest).was.called_with(QUEST_ID)
            assert.spy(MapIconTooltip.RefreshQuest).was.called_with(QUEST_ID)
            assert.is_equal(1, #drawnObjectives)
        end)

        it("should redraw a quest drawn while objectives were disabled once they are enabled", function()
            givenPartyQuest(2)
            -- QuestieQuest draws no icons while the objectives are disabled
            local populate = QuestieQuest.PopulateObjective
            QuestieQuest.PopulateObjective = function(...)
                if Questie.db.profile.enableObjectives then
                    populate(...)
                end
            end
            Questie.db.profile.enableObjectives = false
            QuestiePartyObjectives:ScheduleUpdate(QUEST_ID)
            runPendingThreads()
            assert.is_equal(0, #drawnObjectives)

            Questie.db.profile.enableObjectives = true
            QuestieComms.remoteQuestLogs[QUEST_ID].Partymember[1].fulfilled = 3
            QuestiePartyObjectives:ScheduleUpdate(QUEST_ID)
            runPendingThreads()

            assert.is_equal(1, #drawnObjectives)
        end)

        it("should draw every quest again when objectives were enabled and a full refresh was scheduled", function()
            givenPartyQuest(2)
            local populate = QuestieQuest.PopulateObjective
            QuestieQuest.PopulateObjective = function(...)
                if Questie.db.profile.enableObjectives then
                    populate(...)
                end
            end
            Questie.db.profile.enableObjectives = false
            QuestiePartyObjectives:ScheduleUpdate(QUEST_ID)
            runPendingThreads()

            Questie.db.profile.enableObjectives = true
            QuestiePartyObjectives:ScheduleUpdate()
            runPendingThreads()

            assert.is_equal(1, #drawnObjectives)
        end)

        it("should redraw a quest whose objective failed to draw", function()
            givenPartyQuest(2)
            local populate = QuestieQuest.PopulateObjective
            local failing = true
            QuestieQuest.PopulateObjective = function(...)
                if failing then
                    error("broken objective")
                end
                populate(...)
            end
            allowThreadErrors = true
            QuestiePartyObjectives:ScheduleUpdate(QUEST_ID)
            runPendingThreads()
            assert.is_equal(0, #drawnObjectives)

            failing = false
            QuestiePartyObjectives:ScheduleUpdate(QUEST_ID)
            runPendingThreads()

            assert.is_equal(1, #drawnObjectives)
        end)

        it("should release the icons a failing objective already drew", function()
            givenPartyQuest(2)
            local populate = QuestieQuest.PopulateObjective
            QuestieQuest.PopulateObjective = function(...)
                populate(...)
                error("broken objective")
            end
            allowThreadErrors = true

            QuestiePartyObjectives:ScheduleUpdate(QUEST_ID)
            runPendingThreads()

            -- 2 map and 2 minimap icons were drawn before it failed
            assert.spy(QuestieFramePool.UnloadFrame).was.called(4)
        end)

        it("should redraw a quest even when releasing the icons of its failed objective failed too", function()
            givenPartyQuest(2)
            local populate = QuestieQuest.PopulateObjective
            local failing = true
            QuestieQuest.PopulateObjective = function(...)
                populate(...)
                if failing then
                    error("broken objective")
                end
            end
            QuestieFramePool.UnloadFrame = function() error("broken frame") end

            QuestiePartyObjectives:ScheduleUpdate(QUEST_ID)
            pcall(runPendingThreads)
            assert.is_equal(1, #drawnObjectives)

            failing = false
            QuestieFramePool.UnloadFrame = spy.new(function() end)
            QuestiePartyObjectives:ScheduleUpdate(QUEST_ID)
            runPendingThreads()

            assert.is_equal(2, #drawnObjectives)
        end)

        it("should redraw a quest whose objectives failed to be scheduled", function()
            givenPartyQuest(2)
            local load = QuestieLib.ContinueOnQuestObjectivesLoad
            local failing = true
            QuestieLib.ContinueOnQuestObjectivesLoad = function(...)
                if failing then
                    error("broken load")
                end
                load(...)
            end
            QuestiePartyObjectives:ScheduleUpdate(QUEST_ID)
            runPendingThreads()
            assert.is_equal(0, #drawnObjectives)

            failing = false
            QuestiePartyObjectives:ScheduleUpdate(QUEST_ID)
            runPendingThreads()

            assert.is_equal(1, #drawnObjectives)
        end)

        it("should redraw a quest whose loaded objective text failed to be used", function()
            givenPartyQuestWithUnloadedText()
            QuestiePartyObjectives:ScheduleUpdate(QUEST_ID)
            local onLoaded = pendingObjectiveLoadSuccess
            local getFullText = QuestieLib.GetFullObjectiveText
            QuestieLib.GetFullObjectiveText = function() error("broken text") end
            assert.has_error(function() onLoaded({{text = "Wolf slain: 1/5", type = "monster"}}) end)
            QuestieLib.GetFullObjectiveText = getFullText
            pendingObjectiveLoadSuccess = nil

            QuestiePartyObjectives:ScheduleUpdate(QUEST_ID)

            assert.is_not_nil(pendingObjectiveLoadSuccess)
        end)

        it("should redraw a quest when an objective got finished", function()
            givenPartyQuest(2)
            givenSecondObjective()
            QuestiePartyObjectives:ScheduleUpdate(QUEST_ID)
            runPendingThreads()
            assert.is_equal(2, #drawnObjectives)

            QuestieComms.remoteQuestLogs[QUEST_ID].Partymember[2].finished = true
            QuestiePartyObjectives:ScheduleUpdate(QUEST_ID)
            runPendingThreads()

            -- Both objectives' map and minimap frames, then only the first one is drawn again
            assert.spy(QuestieFramePool.UnloadFrame).was.called(8)
            assert.is_equal(3, #drawnObjectives)
        end)

        it("should redraw a quest when an objective's target changed", function()
            givenPartyQuest(2)
            QuestiePartyObjectives:ScheduleUpdate(QUEST_ID)
            runPendingThreads()

            QuestieComms.remoteQuestLogs[QUEST_ID].Partymember[1].id = 101
            QuestiePartyObjectives:ScheduleUpdate(QUEST_ID)
            runPendingThreads()

            assert.spy(QuestieFramePool.UnloadFrame).was.called(4)
            assert.is_equal(2, #drawnObjectives)
            local redrawn = drawnObjectives[2].AlreadySpawned[1]
            assert.is_equal(2, #redrawn.mapRefs)
            assert.is_equal(2, #redrawn.minimapRefs)
        end)

        it("should clear a quest's icons when the local player accepted it", function()
            givenPartyQuest(2)
            QuestiePartyObjectives:ScheduleUpdate(QUEST_ID)
            runPendingThreads()

            QuestLogCache.questLog_DO_NOT_MODIFY = {[QUEST_ID] = {objectives = {{finished = false}}}}
            QuestiePartyObjectives:ScheduleUpdate(QUEST_ID)
            runPendingThreads()

            assert.spy(QuestieFramePool.UnloadFrame).was.called(4)
            -- The local quest draws the objective itself now
            assert.is_equal(1, #drawnObjectives)
        end)

        it("should clear a quest's icons when its only member went offline", function()
            givenPartyQuest(2)
            QuestiePartyObjectives:ScheduleUpdate(QUEST_ID)
            runPendingThreads()

            _G.UnitIsConnected = function() return false end
            QuestiePartyObjectives:ScheduleUpdate(QUEST_ID)
            runPendingThreads()

            assert.spy(QuestieFramePool.UnloadFrame).was.called(4)
        end)

        it("should retry a quest that the icon budget refused", function()
            local otherQuest = QUEST_ID + 1
            givenPartyQuests({[QUEST_ID] = MAX_PARTY_ICONS, [otherQuest] = 2})
            QuestiePartyObjectives:ScheduleUpdate(QUEST_ID)
            runPendingThreads()
            QuestiePartyObjectives:ScheduleUpdate(otherQuest)
            runPendingThreads()

            QuestieComms.remoteQuestLogs[QUEST_ID] = nil
            QuestiePartyObjectives:ScheduleUpdate(QUEST_ID)
            runPendingThreads()
            QuestiePartyObjectives:ScheduleUpdate(otherQuest)
            runPendingThreads()

            assert.is_equal(2, #drawnObjectives)
        end)

        it("should redraw a quest whose draw was cut short by the icon budget", function()
            givenPartyQuest(MAX_PARTY_ICONS)
            givenSecondObjective()
            QuestiePartyObjectives:ScheduleUpdate(QUEST_ID)
            runPendingThreads()

            QuestiePartyObjectives:ScheduleUpdate(QUEST_ID)
            runPendingThreads()

            assert.is_equal(4, #drawnObjectives)
        end)

        it("should redraw a quest whose objective text failed to load", function()
            givenPartyQuestWithUnloadedText()
            QuestiePartyObjectives:ScheduleUpdate(QUEST_ID)
            pendingObjectiveLoadFailure()
            runPendingThreads()
            pendingObjectiveLoadSuccess = nil

            QuestiePartyObjectives:ScheduleUpdate(QUEST_ID)
            assert.is_not_nil(pendingObjectiveLoadSuccess)
            pendingObjectiveLoadSuccess({{text = "Wolf slain: 1/5", type = "monster"}})
            runPendingThreads()

            assert.is_equal(2, #drawnObjectives)
            assert.is_equal("Wolf slain", drawnObjectives[2].Description)
        end)

        it("should redraw a quest whose draw was dropped while the group was too large", function()
            givenPartyQuest(2)
            QuestiePartyObjectives:ScheduleUpdate(QUEST_ID)
            _G.GetNumGroupMembers = function() return 12 end
            runPendingThreads()
            _G.GetNumGroupMembers = function() return 2 end

            QuestiePartyObjectives:ScheduleUpdate(QUEST_ID)
            runPendingThreads()

            assert.is_equal(1, #drawnObjectives)
        end)
    end)

    describe("quests the local player also has", function()
        it("should draw a party member's objective the local player already finished", function()
            givenPartyQuest(2)
            QuestLogCache.questLog_DO_NOT_MODIFY = {[QUEST_ID] = {objectives = {{finished = true}}}}

            QuestiePartyObjectives:ScheduleUpdate(QUEST_ID)
            runPendingThreads()

            assert.is_equal(1, #drawnObjectives)
        end)

        it("should not draw a party member's objective the local player still needs", function()
            givenPartyQuest(2)
            QuestLogCache.questLog_DO_NOT_MODIFY = {[QUEST_ID] = {objectives = {{finished = false}}}}

            QuestiePartyObjectives:ScheduleUpdate(QUEST_ID)
            runPendingThreads()

            assert.is_equal(0, #drawnObjectives)
        end)

        it("should draw a party member's objective the local quest has no objective for", function()
            givenPartyQuest(2)
            QuestieComms.remoteQuestLogs[QUEST_ID].Partymember[2] = {finished = false, type = "m", id = 101}
            QuestieDB.GetQuest = function()
                return {
                    Id = QUEST_ID,
                    Color = {1, 1, 1},
                    ObjectiveData = {
                        [1] = {Type = "monster", Id = 100, Text = "Kill things"},
                        [2] = {Type = "monster", Id = 101, Text = "Kill other things"},
                    },
                    Objectives = {[1] = {Id = 100}},
                    SpecialObjectives = {},
                }
            end
            QuestLogCache.questLog_DO_NOT_MODIFY = {[QUEST_ID] = {objectives = {{finished = false}}}}

            QuestiePartyObjectives:ScheduleUpdate(QUEST_ID)
            runPendingThreads()

            assert.is_equal(1, #drawnObjectives)
            assert.is_equal(2, drawnObjectives[1].Index)
        end)

        it("should draw a party member's objective the local quest has a row for but no objective data", function()
            givenPartyQuest(2)
            -- The log lists the objective, but the database does not map it, so the local quest draws nothing for it
            local quest = QuestieDB.GetQuest(QUEST_ID)
            quest.Objectives = {}
            QuestieDB.GetQuest = function() return quest end
            QuestLogCache.questLog_DO_NOT_MODIFY = {[QUEST_ID] = {objectives = {{finished = false}}}}

            QuestiePartyObjectives:ScheduleUpdate(QUEST_ID)
            runPendingThreads()

            assert.is_equal(1, #drawnObjectives)
        end)

        it("should not draw the special objectives of a sequenced quest whose visible objectives are finished", function()
            givenPartyQuest(2)
            QuestieDB.GetQuest = function()
                return {
                    Id = QUEST_ID,
                    Color = {1, 1, 1},
                    ObjectiveData = {[1] = {Type = "monster", Id = 100, Text = "Kill things"}},
                    Objectives = {[1] = {Id = 100}},
                    SpecialObjectives = {
                        {Id = 300, Type = "object", Description = "Look around", spawnList = {}},
                    },
                }
            end
            -- The next stage shows up with more objectives, which the local quest draws including its specials
            QuestLogCache.questLog_DO_NOT_MODIFY = {[QUEST_ID] = {isComplete = 0, objectives = {{finished = true}}}}
            local originalIsQuestSequenced = _G.IsQuestSequenced
            _G.IsQuestSequenced = function() return true end

            QuestiePartyObjectives:ScheduleUpdate(QUEST_ID)
            runPendingThreads()
            _G.IsQuestSequenced = originalIsQuestSequenced

            assert.is_equal(1, #drawnObjectives)
        end)

        it("should draw a special objective linked to an objective the local player finished", function()
            givenPartyQuest(2)
            QuestieDB.GetQuest = function()
                return {
                    Id = QUEST_ID,
                    Color = {1, 1, 1},
                    ObjectiveData = {[1] = {Type = "monster", Id = 100, Text = "Kill things"}},
                    SpecialObjectives = {
                        {Id = 200, Type = "object", Description = "Use the thing", spawnList = {}, RealObjectiveIndex = 1},
                        {Id = 300, Type = "object", Description = "Look around", spawnList = {}},
                    },
                }
            end
            -- The local quest still draws the unlinked special objective itself
            QuestLogCache.questLog_DO_NOT_MODIFY = {[QUEST_ID] = {objectives = {{finished = true}, {finished = false}}}}

            QuestiePartyObjectives:ScheduleUpdate(QUEST_ID)
            runPendingThreads()

            assert.is_equal(2, #drawnObjectives)
            assert.is_equal(1, drawnObjectives[1].Index)
            assert.is_equal(65, drawnObjectives[2].Index)
        end)

        it("should not draw a special objective linked to an objective the local player still needs", function()
            givenPartyQuest(2)
            QuestieDB.GetQuest = function()
                return {
                    Id = QUEST_ID,
                    Color = {1, 1, 1},
                    ObjectiveData = {[1] = {Type = "monster", Id = 100, Text = "Kill things"}},
                    Objectives = {[1] = {Id = 100}},
                    SpecialObjectives = {
                        {Id = 200, Type = "object", Description = "Use the thing", spawnList = {}, RealObjectiveIndex = 1},
                    },
                }
            end
            QuestLogCache.questLog_DO_NOT_MODIFY = {[QUEST_ID] = {objectives = {{finished = false}}}}

            QuestiePartyObjectives:ScheduleUpdate(QUEST_ID)
            runPendingThreads()

            assert.is_equal(0, #drawnObjectives)
        end)

        it("should draw the party's objectives once the local player's quest is complete", function()
            givenPartyQuest(2)
            QuestLogCache.questLog_DO_NOT_MODIFY = {[QUEST_ID] = {isComplete = 1, objectives = {}}}

            QuestiePartyObjectives:ScheduleUpdate(QUEST_ID)
            runPendingThreads()

            assert.is_equal(1, #drawnObjectives)
        end)

        it("should draw a party member's objective after the local player finished it", function()
            givenPartyQuest(2)
            local localObjective = {finished = false}
            QuestLogCache.questLog_DO_NOT_MODIFY = {[QUEST_ID] = {objectives = {localObjective}}}
            QuestiePartyObjectives:ScheduleUpdate(QUEST_ID)
            runPendingThreads()

            localObjective.finished = true
            QuestiePartyObjectives:ScheduleUpdate(QUEST_ID)
            runPendingThreads()

            assert.is_equal(1, #drawnObjectives)
        end)

        it("should draw the party's objectives when the local player's quest failed", function()
            givenPartyQuest(2)
            QuestLogCache.questLog_DO_NOT_MODIFY = {[QUEST_ID] = {isComplete = -1, objectives = {{finished = false}}}}

            QuestiePartyObjectives:ScheduleUpdate(QUEST_ID)
            runPendingThreads()

            assert.is_equal(1, #drawnObjectives)
        end)

        it("should draw special objectives once all of the local player's objectives are finished", function()
            givenPartyQuest(2)
            QuestieDB.GetQuest = function()
                return {
                    Id = QUEST_ID,
                    Color = {1, 1, 1},
                    ObjectiveData = {[1] = {Type = "monster", Id = 100, Text = "Kill things"}},
                    SpecialObjectives = {
                        {Id = 200, Type = "object", Description = "Use the thing", spawnList = {}},
                    },
                }
            end
            QuestLogCache.questLog_DO_NOT_MODIFY = {[QUEST_ID] = {isComplete = 0, objectives = {{finished = true}}}}

            QuestiePartyObjectives:ScheduleUpdate(QUEST_ID)
            runPendingThreads()

            assert.is_equal(2, #drawnObjectives)
        end)

        it("should draw special objectives only once the local player's quest is complete", function()
            givenPartyQuest(2)
            QuestieDB.GetQuest = function()
                return {
                    Id = QUEST_ID,
                    Color = {1, 1, 1},
                    ObjectiveData = {[1] = {Type = "monster", Id = 100, Text = "Kill things"}},
                    SpecialObjectives = {
                        {Id = 200, Type = "object", Description = "Use the thing", spawnList = {}},
                    },
                }
            end
            local localEntry = {objectives = {{finished = true}, {finished = false}}}
            QuestLogCache.questLog_DO_NOT_MODIFY = {[QUEST_ID] = localEntry}
            QuestiePartyObjectives:ScheduleUpdate(QUEST_ID)
            runPendingThreads()
            assert.is_equal(1, #drawnObjectives)

            localEntry.isComplete = 1
            QuestiePartyObjectives:ScheduleUpdate(QUEST_ID)
            runPendingThreads()

            assert.is_equal(3, #drawnObjectives)
        end)
    end)

    describe("unloading", function()
        local pendingTimers

        local function deferTimers()
            pendingTimers = {}
            _G.C_Timer = {After = function(_, callback) pendingTimers[#pendingTimers + 1] = callback end}
        end

        local function runNextFrame()
            local queued = pendingTimers
            pendingTimers = {}
            for _, callback in ipairs(queued) do
                callback()
            end
        end

        it("should unload the icons of a cleared group over several frames", function()
            givenPartyQuest(60)
            QuestiePartyObjectives:ScheduleUpdate(QUEST_ID)
            runPendingThreads()
            deferTimers()

            QuestiePartyObjectives:Clear()
            assert.spy(QuestieFramePool.UnloadFrame).was.not_called()

            runNextFrame()
            assert.spy(QuestieFramePool.UnloadFrame).was.called(50)

            runNextFrame()
            assert.spy(QuestieFramePool.UnloadFrame).was.called(100)

            runNextFrame()
            assert.spy(QuestieFramePool.UnloadFrame).was.called(120)
            assert.is_equal(0, #pendingTimers)
        end)

        it("should unload the icons of a redrawn quest over several frames", function()
            givenPartyQuest(60)
            QuestiePartyObjectives:ScheduleUpdate(QUEST_ID)
            runPendingThreads()
            deferTimers()

            givenFinishedObjective(QUEST_ID)
            QuestiePartyObjectives:ScheduleUpdate(QUEST_ID)
            -- The update's debounce timer
            runNextFrame()
            runNextFrame()
            assert.spy(QuestieFramePool.UnloadFrame).was.called(50)

            runNextFrame()
            runNextFrame()
            assert.spy(QuestieFramePool.UnloadFrame).was.called(120)
        end)

        it("should not unload an icon that was reused before its turn", function()
            givenPartyQuest(60)
            QuestiePartyObjectives:ScheduleUpdate(QUEST_ID)
            runPendingThreads()
            deferTimers()

            QuestiePartyObjectives:Clear()
            drawnObjectives[1].AlreadySpawned[1].minimapRefs[60].data = {someoneElse = true}
            runNextFrame()
            runNextFrame()
            runNextFrame()

            assert.spy(QuestieFramePool.UnloadFrame).was.called(119)
        end)

        it("should drop the finished queue even when its last icon failed to unload", function()
            givenPartyQuest(1)
            QuestiePartyObjectives:ScheduleUpdate(QUEST_ID)
            runPendingThreads()
            deferTimers()
            local lastIcon = drawnObjectives[1].AlreadySpawned[1].minimapRefs[1]
            local watcher = setmetatable({lastIcon}, {__mode = "v"})
            QuestieFramePool.UnloadFrame = function(_, icon)
                if icon == lastIcon then
                    error("broken frame")
                end
            end

            QuestiePartyObjectives:Clear()
            runNextFrame()
            lastIcon = nil
            drawnObjectives = {}
            collectgarbage()
            collectgarbage()

            assert.is_nil(watcher[1])
        end)

        it("should keep unloading the remaining icons after one failed", function()
            givenPartyQuest(60)
            QuestiePartyObjectives:ScheduleUpdate(QUEST_ID)
            runPendingThreads()
            deferTimers()
            local failingIcon = drawnObjectives[1].AlreadySpawned[1].mapRefs[1]
            local unloaded = 0
            QuestieFramePool.UnloadFrame = function(_, icon)
                if icon == failingIcon then
                    error("broken frame")
                end
                unloaded = unloaded + 1
            end

            QuestiePartyObjectives:Clear()
            runNextFrame()
            runNextFrame()
            runNextFrame()
            runNextFrame()

            assert.is_equal(119, unloaded)
        end)
    end)

    describe("API objective text", function()
        it("should preserve native wording and a counter-free fallback description", function()
            givenPartyQuestWithUnloadedText()

            QuestiePartyObjectives:ScheduleUpdate(QUEST_ID)
            pendingObjectiveLoadSuccess({{text = "Wolf slain: 1/1", type = "monster"}})
            runPendingThreads()

            assert.equals("Wolf slain", drawnObjectives[1].Description)
            assert.equals("Wolf slain: 1/1", drawnObjectives[1].NativeText)
        end)

        it("should use API wording for matching types and request current wording on redraw", function()
            givenPartyQuestWithUnloadedText()

            -- First draw: cache empty -> ContinueOnQuestObjectivesLoad called
            QuestiePartyObjectives:ScheduleUpdate(QUEST_ID)
            runPendingThreads()

            -- Load callback hasn't been invoked yet; no objectives drawn yet
            assert.is_equal(0, #drawnObjectives)
            assert.is_not_nil(pendingObjectiveLoadSuccess)

            -- Simulate the async load resolving with API objectives
            pendingObjectiveLoadSuccess({
                [1] = {text = "Fallen Sky Ridge Revitalized: 0/1", type = "monster"},
            })
            runPendingThreads()

            -- Now the quest should be drawn with the API text as Description (counter stripped)
            assert.is_equal(1, #drawnObjectives)
            assert.is_equal("Fallen Sky Ridge Revitalized", drawnObjectives[1].Description)
            assert.equals("Fallen Sky Ridge Revitalized: 0/1", drawnObjectives[1].NativeText)
            assert.equals("monster", drawnObjectives[1].Type)
            assert.equals(100, drawnObjectives[1].Id)

            -- The fetcher owns readiness. A ready result on redraw must not be hidden by a second cache.
            QuestieLib.ContinueOnQuestObjectivesLoad = function(_, onSuccess)
                onSuccess({{text = "Protect the ritual: 0/1", type = "monster"}})
            end
            drawnObjectives = {}
            givenFinishedObjective(QUEST_ID)
            QuestiePartyObjectives:ScheduleUpdate(QUEST_ID)
            runPendingThreads()

            assert.is_equal(1, #drawnObjectives)
            assert.is_equal("Protect the ritual", drawnObjectives[1].Description)
            assert.equals("Protect the ritual: 0/1", drawnObjectives[1].NativeText)
            -- Spawn list should be reused on second draw
            assert.same({false, true}, spawnListPrefilled)
        end)

        it("should still use API wording when DB and comms types differ", function()
            givenPartyQuestWithUnloadedText()
            QuestieComms.remoteQuestLogs[QUEST_ID].Partymember[1].type = "o"

            QuestiePartyObjectives:ScheduleUpdate(QUEST_ID)
            runPendingThreads()

            -- Before the load callback runs, nothing should be drawn
            assert.is_equal(0, #drawnObjectives)
            assert.is_not_nil(pendingObjectiveLoadSuccess)

            -- Now invoke the callback
            pendingObjectiveLoadSuccess({
                [1] = {text = "Loaded from API: 0/3", type = "monster"},
            })
            runPendingThreads()

            -- After callback, the quest is drawn
            assert.is_equal(1, #drawnObjectives)
            assert.is_equal("Loaded from API", drawnObjectives[1].Description)
        end)

        it("should not redraw if quest was cleared before load callback", function()
            givenPartyQuestWithUnloadedText()

            QuestiePartyObjectives:ScheduleUpdate(QUEST_ID)
            runPendingThreads()

            assert.is_not_nil(pendingObjectiveLoadSuccess)

            -- Clear the quest before the load resolves
            QuestiePartyObjectives:Clear()
            -- Reset the spy to track only new calls
            QuestieFramePool.UnloadFrame = spy.new(function() end)

            -- Now invoke the callback - it should detect staleness and bail out
            pendingObjectiveLoadSuccess({
                [1] = {text = "Should not be used", type = "monster"},
            })
            runPendingThreads()

            -- No new frames should have been created/adopted
            assert.spy(QuestieFramePool.UnloadFrame).was.not_called()
            -- drawnObjectives should still be empty (the old ones were cleared)
            assert.is_equal(0, #drawnObjectives)
        end)

        it("should use database wording when objective text loading times out", function()
            givenPartyQuestWithUnloadedText()

            QuestiePartyObjectives:ScheduleUpdate(QUEST_ID)
            runPendingThreads()

            assert.is_not_nil(pendingObjectiveLoadSuccess)
            assert.is_not_nil(pendingObjectiveLoadFailure)

            -- Simulate the load timing out by invoking onFailure
            pendingObjectiveLoadFailure()
            runPendingThreads()

            -- Should draw with default text (from DB, since no API text available)
            assert.is_equal(1, #drawnObjectives)
            assert.is_equal("Kill things", drawnObjectives[1].Description)
            assert.is_nil(drawnObjectives[1].NativeText)
        end)

    end)
end)
