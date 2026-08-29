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

    local QUEST_ID = 42
    -- Mirrors MAX_PARTY_ICONS in the module, which is a file-local constant. Keep in sync.
    local MAX_PARTY_ICONS = 500

    -- Queue thread bodies instead of running them, so a test controls when (and whether) they run.
    -- This mirrors ThreadLib.ThreadInstant, which never runs its body synchronously. A fake that
    -- runs inline cannot observe this class of bug at all.
    local pendingThreads

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

    ---@param spawnCount number
    local function givenPartyQuest(spawnCount)
        givenPartyQuests({[QUEST_ID] = spawnCount})
    end

    before_each(function()
        pendingThreads = {}
        drawnObjectives = {}
        spawnListPrefilled = {}

        Questie.db.profile.showPartyQuestObjectives = true
        Questie.db.profile.trimObjectiveText = false

        _G.UnitIsConnected = function() return true end
        _G.GetNumGroupMembers = function() return 2 end
        _G.HaveQuestData = function() return true end
        -- Fire the debounce immediately so ScheduleUpdate is synchronous and a test can drive
        -- quests one at a time in a deterministic order (a full Update() clears everything first).
        _G.C_Timer = {After = function(_, callback) callback() end}

        QuestieComms = QuestieLoader:ImportModule("QuestieComms")
        QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")
        QuestieDB = QuestieLoader:ImportModule("QuestieDB")
        QuestieLib = QuestieLoader:ImportModule("QuestieLib")
        QuestieFramePool = QuestieLoader:ImportModule("QuestieFramePool")
        QuestLogCache = QuestieLoader:ImportModule("QuestLogCache")
        ThreadLib = QuestieLoader:ImportModule("ThreadLib")
        QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
        CommsVisibility = QuestieLoader:ImportModule("CommsVisibility")

        QuestiePlayer.GetGroupType = function() return "party" end
        CommsVisibility.ShouldShowPartyObjective = function() return true end
        QuestieLib.ColorWheel = function() return {1, 1, 1} end
        QuestieLib.GetFullObjectiveText = function(text) return text end
        QuestieFramePool.UnloadFrame = spy.new(function() end)
        QuestLogCache.questLog_DO_NOT_MODIFY = {}

        ThreadLib.ThreadInstant = function(body)
            pendingThreads[#pendingThreads + 1] = body
        end

        dofile("Modules/Network/QuestiePartyObjectives.lua")
        QuestiePartyObjectives = QuestieLoader:ImportModule("QuestiePartyObjectives")

        QuestiePartyObjectives:Clear()
    end)

    describe("Update", function()
        it("should not draw objectives suppressed by the remote player's visibility snapshot", function()
            givenPartyQuest(2)
            CommsVisibility.ShouldShowPartyObjective = function() return false end

            QuestiePartyObjectives:Update()
            runPendingThreads()

            assert.equals(0, #drawnObjectives)
        end)

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
            assert.spy(QuestieFramePool.UnloadFrame).was_not.called()

            -- Nothing was adopted either, so a later Clear finds nothing.
            QuestiePartyObjectives:Clear()
            assert.spy(QuestieFramePool.UnloadFrame).was_not.called()
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
            assert.spy(QuestieFramePool.UnloadFrame).was_not.called()
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
            assert.spy(QuestieFramePool.UnloadFrame).was_not.called()
        end)

        it("should draw nothing at all once the icon budget is exhausted", function()
            local otherQuest = QUEST_ID + 1
            givenPartyQuests({[QUEST_ID] = MAX_PARTY_ICONS, [otherQuest] = 2})

            QuestiePartyObjectives:ScheduleUpdate(QUEST_ID)
            runPendingThreads()
            assert.equals(1, #drawnObjectives) -- budget now fully spent

            -- The second quest must be abandoned before anything is drawn. Reaching PopulateObjective
            -- would allocate frames only to release them, and a frame unloaded while still queued
            -- merely sets _needsUnload, so ProcessQueue publishes it to HBD for a tick first.
            QuestiePartyObjectives:ScheduleUpdate(otherQuest)
            runPendingThreads()

            assert.equals(1, #drawnObjectives)
        end)

        it("should not draw a quest the local player also has", function()
            givenPartyQuest(2)

            -- The local player's own pipeline draws this quest's objectives, so drawing it as a
            -- party objective too would double up on the same questIdFrames key.
            QuestLogCache.questLog_DO_NOT_MODIFY = {[QUEST_ID] = {}}

            QuestiePartyObjectives:ScheduleUpdate(QUEST_ID)
            runPendingThreads()

            assert.equals(0, #drawnObjectives)
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
end)
