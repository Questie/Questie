dofile("setupTests.lua")
local stub = require("luassert.stub")

_G.GetQuestTimers = function() return nil end

-- Real Classic Alliance Elwynn Forest quests: 11 = Riverpaw Gnoll Bounty, 112 = Collecting Kelp.
local RIVERPAW_GNOLL_BOUNTY_ID = 11
local COLLECTING_KELP_ID = 112
local COLLECTING_KELP_OBJECTIVE_INDEX = 1

describe("QuestieTracker", function()
    ---@type QuestieTracker
    local QuestieTracker
    ---@type TrackerUtils
    local TrackerUtils
    ---@type QuestieQuest
    local QuestieQuest
    ---@type QuestieCombatQueue
    local QuestieCombatQueue
    local TrackerData

    before_each(function()
        Questie.db.char = {
            collapsedQuests = {},
            AutoUntrackedQuests = {},
            TrackedQuests = {},
            isTrackerExpanded = true,
        }
        Questie.db.profile = {
            trackerEnabled = true,
            minimizeTrackerInInstances = false,
            hideTrackerInInstances = false,
        }

        TrackerData = QuestieLoader:ImportModule("TrackerData")
        TrackerData.RemoveQuest = spy.new(function() end)
        TrackerData.ContainsQuest = function() return false end
        TrackerUtils = QuestieLoader:ImportModule("TrackerUtils")
        TrackerUtils.UnFocus = spy.new(function() end)
        QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")
        QuestieQuest.ToggleNotes = spy.new(function() end)
        QuestieCombatQueue = QuestieLoader:ImportModule("QuestieCombatQueue")
        QuestieCombatQueue.Queue = function(_, callback) callback() end

        dofile("Modules/Tracker/QuestieTracker.lua")
        QuestieTracker = QuestieLoader:ImportModule("QuestieTracker")
    end)

    describe("QuestItemLooted", function()
        local getItemInfoMock, getItemCountMock, usableItemMock, afterMock, registerEventMock
        local originalTimer

        before_each(function()
            local compat = QuestieLoader:ImportModule("QuestieCompat")
            getItemInfoMock = stub(compat, "GetItemInfo")
            getItemInfoMock.returns(nil, nil, nil, nil, nil, "Quest")
            getItemCountMock = stub(compat, "GetItemCount", function() return 1 end)
            usableItemMock = stub(TrackerUtils, "IsQuestItemUsable", function() return true end)
            originalTimer = _G.C_Timer
            afterMock = spy.new(function() end)
            _G.C_Timer = {After = afterMock}
            registerEventMock = stub(Questie, "RegisterEvent")
            dofile("Modules/Tracker/QuestieTracker.lua")
        end)

        after_each(function()
            getItemInfoMock:revert()
            getItemCountMock:revert()
            usableItemMock:revert()
            _G.C_Timer = originalTimer
            registerEventMock:revert()
        end)

        it("schedules a tracker refresh when the looted quest item is already in the bag", function()
            QuestieTracker:QuestItemLooted("You receive loot: |Hitem:123|h[A Letter]|h")

            assert.spy(getItemInfoMock).was.called_with(123)
            assert.spy(getItemCountMock).was.called_with(123)
            assert.spy(afterMock).was.called(2)
            assert.equal(0.25, afterMock.calls[1].vals[1])
            assert.equal(0.5, afterMock.calls[2].vals[1])
            assert.spy(registerEventMock).was.not_called()
        end)

        it("waits for a bag update when the looted quest item is not in the bag yet", function()
            getItemCountMock.returns(0)

            QuestieTracker:QuestItemLooted("You receive loot: |Hitem:123|h[A Letter]|h")

            assert.spy(getItemCountMock).was.called_with(123)
            assert.spy(registerEventMock).was.called(1)
            assert.equal("BAG_UPDATE_DELAYED", registerEventMock.calls[1].vals[2])
            assert.spy(afterMock).was.called(1)
        end)
    end)

    describe("achievement UI integration", function()
        local loadedMock, focusMock, countMock, removeMock, timeMock, shiftMock
        local originalAchievementFrame

        before_each(function()
            local compat = QuestieLoader:ImportModule("QuestieCompat")
            loadedMock = stub(compat, "IsAddOnLoaded", function() return true end)
            focusMock = stub(compat, "GetMouseFocus")
            countMock = stub(_G, "GetNumTrackedAchievements", function() return 0 end)
            removeMock = stub(_G, "RemoveTrackedAchievement")
            timeMock = stub(_G, "GetTime", function() return 0 end)
            shiftMock = stub(_G, "IsShiftKeyDown", function() return false end)
            originalAchievementFrame = _G.AchievementFrame
            _G.AchievementFrame = {IsShown = function() return false end}
            Questie.db.char.trackedAchievementIds = {}
            Questie.db.char.collapsedZones = {}
            dofile("Modules/Tracker/QuestieTracker.lua")
            timeMock.returns(1)
        end)

        after_each(function()
            loadedMock:revert()
            focusMock:revert()
            countMock:revert()
            removeMock:revert()
            timeMock:revert()
            shiftMock:revert()
            _G.AchievementFrame = originalAchievementFrame
        end)

        it("does not inspect Blizzard's tracked checkbox when Krowi is loaded", function()
            QuestieTracker:TrackAchieve(123)

            assert.spy(loadedMock).was.called_with("Krowi_AchievementFilter")
            assert.spy(focusMock).was.not_called()
            assert.spy(removeMock).was.called_with(123, true)
        end)
    end)

    describe("IsTrackedByQuestie", function()
        it("should return false when questId is nil", function()
            assert.is_false(QuestieTracker.IsTrackedByQuestie(nil))
        end)

        it("should return true when manual tracking has the quest in TrackedQuests", function()
            Questie.db.profile.autoTrackQuests = false
            Questie.db.char.TrackedQuests[RIVERPAW_GNOLL_BOUNTY_ID] = true
            assert.is_true(QuestieTracker.IsTrackedByQuestie(RIVERPAW_GNOLL_BOUNTY_ID))
        end)

        it("should return false when manual tracking does not have the quest in TrackedQuests", function()
            Questie.db.profile.autoTrackQuests = false
            assert.is_false(QuestieTracker.IsTrackedByQuestie(RIVERPAW_GNOLL_BOUNTY_ID))
        end)

        it("should auto-track native quests without requiring database enrichment", function()
            Questie.db.profile.autoTrackQuests = true
            TrackerData.ContainsQuest = function(id) return id == 91741 end
            QuestieLoader:ImportModule("QuestiePlayer").currentQuestlog = {}
            assert.is_true(QuestieTracker.IsTrackedByQuestie(91741))
        end)

        it("should return false when auto-tracking has the quest auto-untracked", function()
            Questie.db.profile.autoTrackQuests = true
            TrackerData.ContainsQuest = function() return true end
            Questie.db.char.AutoUntrackedQuests[RIVERPAW_GNOLL_BOUNTY_ID] = true
            assert.is_false(QuestieTracker.IsTrackedByQuestie(RIVERPAW_GNOLL_BOUNTY_ID))
        end)
    end)

    describe("GetNumTrackedQuests", function()
        local countMock

        before_each(function()
            TrackerData.ContainsQuest = function() return true end
            countMock = stub(QuestieLoader:ImportModule("QuestieCompat"), "GetNumQuestLogEntries", function() return 6, 5 end)
        end)

        after_each(function()
            countMock:revert()
        end)

        it("should count TrackedQuests when auto-tracking is disabled", function()
            Questie.db.profile.autoTrackQuests = false
            Questie.db.char.TrackedQuests = {[RIVERPAW_GNOLL_BOUNTY_ID] = true, [COLLECTING_KELP_ID] = true}
            assert.are.equal(2, QuestieTracker.GetNumTrackedQuests())
        end)

        it("should subtract auto-untracked quests from the quest log count when auto-tracking is enabled", function()
            Questie.db.profile.autoTrackQuests = true
            Questie.db.char.AutoUntrackedQuests = {[RIVERPAW_GNOLL_BOUNTY_ID] = true}
            QuestieLoader:ImportModule("QuestiePlayer").currentQuestlog = {}
            assert.are.equal(4, QuestieTracker.GetNumTrackedQuests())
        end)

        it("should not subtract auto-untracked quests that are no longer in the quest log", function()
            Questie.db.profile.autoTrackQuests = true
            Questie.db.char.AutoUntrackedQuests = {[RIVERPAW_GNOLL_BOUNTY_ID] = true}
            TrackerData.ContainsQuest = function() return false end
            assert.are.equal(5, QuestieTracker.GetNumTrackedQuests())
        end)
    end)

    describe("legacy quest watch display shim", function()
        local originalIsWatched, originalCount

        before_each(function()
            originalIsWatched = _G.IsQuestWatched
            originalCount = _G.GetNumQuestWatches
            local timers = QuestieLoader:ImportModule("TrackerQuestTimers")
            timers.HideBlizzardTimer = function() end
            timers.ShowBlizzardTimer = function() end
            QuestieTracker.alreadyHooked = nil
            QuestieTracker.alreadyHookedSecure = true
            _G.GetQuestLogTitle = function() return nil, nil, nil, nil, nil, nil, nil, RIVERPAW_GNOLL_BOUNTY_ID end
        end)

        after_each(function()
            _G.IsQuestWatched = originalIsWatched
            _G.GetNumQuestWatches = originalCount
        end)

        it("should redirect IsQuestWatched to Questie's own tracking state on non-Forever clients", function()
            Questie.IsForever = false
            Questie.db.profile.autoTrackQuests = false
            Questie.db.char.TrackedQuests[RIVERPAW_GNOLL_BOUNTY_ID] = true

            QuestieTracker:HookBaseTracker()

            assert.is_true(_G.IsQuestWatched(1))
        end)

        it("should leave GetNumQuestWatches untouched so Blizzard's native watch limit still applies", function()
            Questie.IsForever = false
            local nativeCount = function() return 3 end
            _G.GetNumQuestWatches = nativeCount

            QuestieTracker:HookBaseTracker()

            assert.are.equal(nativeCount, _G.GetNumQuestWatches)
        end)

        it("should restore the original IsQuestWatched global on unhook", function()
            Questie.IsForever = false
            local nativeIsWatched = function() return true end
            _G.IsQuestWatched = nativeIsWatched

            QuestieTracker:HookBaseTracker()
            QuestieTracker:Unhook()

            assert.are.equal(nativeIsWatched, _G.IsQuestWatched)
        end)

        it("should not touch IsQuestWatched on Forever clients", function()
            Questie.IsForever = true
            local nativeIsWatched = function() return true end
            _G.IsQuestWatched = nativeIsWatched

            QuestieTracker:HookBaseTracker()

            assert.are.equal(nativeIsWatched, _G.IsQuestWatched)
        end)
    end)

    describe("RemoveQuest", function()
        it("should not unfocus when the removed quest id is only a prefix of the focused quest id", function()
            Questie.db.char.TrackerFocus = tostring(COLLECTING_KELP_ID) .. " " .. tostring(COLLECTING_KELP_OBJECTIVE_INDEX)

            QuestieTracker:RemoveQuest(RIVERPAW_GNOLL_BOUNTY_ID)

            assert.spy(TrackerUtils.UnFocus).was.not_called()
            assert.spy(QuestieQuest.ToggleNotes).was.not_called()
        end)

        it("should unfocus when the removed quest id matches the focused quest id", function()
            Questie.db.char.TrackerFocus = tostring(COLLECTING_KELP_ID) .. " " .. tostring(COLLECTING_KELP_OBJECTIVE_INDEX)

            QuestieTracker:RemoveQuest(COLLECTING_KELP_ID)

            assert.spy(TrackerUtils.UnFocus).was.called()
            assert.spy(QuestieQuest.ToggleNotes).was.called_with(QuestieQuest, true)
        end)
    end)

    describe("native-only quest tracking", function()
        local originalForever, originalQuestLog
        local titleMock, removeWatchMock, quest, QuestEventHandler

        before_each(function()
            originalForever = Questie.IsForever
            originalQuestLog = _G.C_QuestLog
            Questie.IsForever = true
            _G.C_QuestLog = {
                GetQuestWatchType = function() return 1 end,
                RemoveQuestWatch = spy.new(function() end),
            }
            Questie.db.profile.autoTrackQuests = true
            Questie.db.char.collapsedZones = {}
            QuestieLoader:ImportModule("QuestiePlayer").currentQuestlog = {}
            quest = {Id = 91741, name = "Nibbled-On Book", zoneName = "Northshire Abbey", Objectives = {}}
            QuestEventHandler = QuestieLoader:ImportModule("QuestEventHandler")
            QuestEventHandler.IsQuestAccepted = spy.new(function() return true end)
            TrackerData.RefreshQuest = spy.new(function() return quest end)
            TrackerUtils.GetQuestGroupName = function(trackerQuest) return trackerQuest.zoneName end
            QuestieLoader:ImportModule("CommsVisibility").ScheduleSnapshot = spy.new(function() end)
            removeWatchMock = stub(QuestieLoader:ImportModule("QuestieCompat"), "RemoveQuestWatch")
            titleMock = stub(QuestieLoader:ImportModule("QuestieCompat"), "GetQuestLogTitle", function()
                return "Nibbled-On Book", 2, nil, false, false, 1, nil, 91741
            end)
            QuestieTracker.Update = spy.new(function() end)
        end)

        after_each(function()
            Questie.IsForever = originalForever
            _G.C_QuestLog = originalQuestLog
            titleMock:revert()
            removeWatchMock:revert()
        end)

        it("keeps Classic's watch migration when tracking a quest without database enrichment", function()
            Questie.IsForever = false
            Questie.db.profile.autoTrackQuests = false
            QuestieTracker.last_aqw = nil

            QuestieTracker:AQW_Insert(2)

            assert.spy(removeWatchMock).was.called_with(2, true)
            assert.is_true(Questie.db.char.TrackedQuests[91741])
            assert.spy(QuestieTracker.Update).was.called()
        end)

        it("retracks and expands an unknown native quest", function()
            Questie.db.char.AutoUntrackedQuests[91741] = true
            Questie.db.char.collapsedQuests[91741] = true
            Questie.db.char.collapsedZones["Northshire Abbey"] = true

            QuestieTracker:AQW_Insert(2)

            assert.spy(QuestEventHandler.IsQuestAccepted).was.called_with(91741)
            assert.is_nil(Questie.db.char.AutoUntrackedQuests[91741])
            assert.is_nil(Questie.db.char.collapsedQuests[91741])
            assert.is_nil(Questie.db.char.collapsedZones["Northshire Abbey"])
            assert.spy(removeWatchMock).was.not_called()
            assert.spy(QuestieTracker.Update).was.called()
        end)

        it("expands the tracker group the quest is listed under on retrack", function()
            -- Non-zone sort modes list every quest under one group, not under its zone.
            TrackerUtils.GetQuestGroupName = function() return "Quests (By Level)" end
            Questie.db.char.AutoUntrackedQuests[91741] = true
            Questie.db.char.collapsedZones["Quests (By Level)"] = true

            QuestieTracker:AQW_Insert(2)

            assert.is_nil(Questie.db.char.collapsedZones["Quests (By Level)"])
        end)

        it("ignores Blizzard's auto-watch before Questie finishes accepting the quest in manual tracking", function()
            Questie.IsForever = false
            Questie.db.profile.autoTrackQuests = false
            QuestieTracker.last_aqw = nil
            -- The quest is already in the native log; only Questie's acceptance is still pending.
            TrackerData.ContainsQuest = function() return true end
            QuestEventHandler.IsQuestAccepted = function() return false end

            QuestieTracker:AQW_Insert(2)

            assert.is_nil(Questie.db.char.TrackedQuests[91741])
            assert.spy(removeWatchMock).was.not_called()
            assert.spy(QuestieTracker.Update).was.not_called()
        end)

        it("ignores a stale add after the native quest was removed", function()
            QuestEventHandler.IsQuestAccepted = function() return false end
            Questie.db.char.AutoUntrackedQuests[91741] = true

            QuestieTracker:AQW_Insert(2)

            assert.is_true(Questie.db.char.AutoUntrackedQuests[91741])
            assert.spy(TrackerData.RefreshQuest).was.not_called()
            assert.spy(QuestieTracker.Update).was.not_called()
        end)

        it("untracks the native watch without requiring a database object", function()
            QuestieTracker:UntrackQuestId(91741)

            assert.is_true(Questie.db.char.AutoUntrackedQuests[91741])
            assert.spy(_G.C_QuestLog.RemoveQuestWatch).was.called_with(91741)
            assert.spy(QuestieTracker.Update).was.called()
        end)

        it("passes refreshed data to text-only updates", function()
            local pool = QuestieLoader:ImportModule("TrackerLinePool")
            pool.UpdateQuestLines = spy.new(function() end)

            QuestieTracker.UpdateQuestLines(91741)

            assert.spy(TrackerData.RefreshQuest).was.called_with(91741)
            assert.spy(pool.UpdateQuestLines).was.called_with(91741, quest)
        end)

        it("does not update old rows after the quest leaves the native log", function()
            TrackerData.RefreshQuest = function() return nil end
            local pool = QuestieLoader:ImportModule("TrackerLinePool")
            pool.UpdateQuestLines = spy.new(function() end)

            QuestieTracker.UpdateQuestLines(91741)

            assert.spy(pool.UpdateQuestLines).was.not_called()
        end)

        it("invalidates display data when a quest is removed", function()
            QuestieTracker:RemoveQuest(91741)

            assert.spy(TrackerData.RemoveQuest).was.called_with(91741)
        end)
    end)

    describe("explicit display refresh", function()
        local now, inCombat, expansion, originalExpansion, originalTimer, originalDurability, originalBindingLabel
        local timeMock, combatMock, countMock, instanceMock, infoMock
        local header, pool, baseFrame

        before_each(function()
            now, inCombat = 0, false
            timeMock = stub(_G, "GetTime", function() return now end)
            combatMock = stub(_G, "InCombatLockdown", function() return inCombat end)
            instanceMock = stub(_G, "IsInInstance", function() return false end)
            infoMock = stub(_G, "GetInstanceInfo", function() return "Outside", "none" end)
            countMock = stub(QuestieLoader:ImportModule("QuestieCompat"), "GetNumQuestWatches", function() return 0 end)
            expansion = QuestieLoader:ImportModule("Expansions")
            originalExpansion = expansion.Current
            expansion.Current = expansion.Era
            originalTimer, originalDurability = _G.C_Timer, _G.DurabilityFrame
            originalBindingLabel = _G.BINDING_NAME_QUESTIE_TOGGLE_TRACKER
            _G.C_Timer = {After = function() end}
            _G.DurabilityFrame = {GetPoint = function() return "TOPLEFT" end}
            Questie.db.profile.trackerFontSizeZone = 12
            Questie.db.profile.trackerFontSizeQuest = 10
            Questie.db.profile.trackerFontSizeObjective = 10

            TrackerData.Refresh = spy.new(function() return {} end)
            local base = QuestieLoader:ImportModule("TrackerBaseFrame")
            base.Initialize = function()
                local frame = CreateFrame("Frame")
                frame.IsShown = function() return false end
                baseFrame = frame
                return frame
            end
            base.Update = function() end
            header = QuestieLoader:ImportModule("TrackerHeaderFrame")
            header.Initialize = function() return {GetWidth = function() return 100 end} end
            header.Update = function() assert.spy(TrackerData.Refresh).was.called(1) end
            local frame = QuestieLoader:ImportModule("TrackerQuestFrame")
            frame.Initialize = function()
                local questFrame = CreateFrame("Frame")
                questFrame.ScrollChildFrame = CreateFrame("Frame")
                return questFrame
            end
            frame.Update = function() end
            pool = QuestieLoader:ImportModule("TrackerLinePool")
            pool.Initialize = function() end
            pool.ResetLinesForChange = function() end
            pool.ResetButtonsForChange = function() end
            pool.GetLastLine = function() return nil end
            QuestieLoader:ImportModule("TrackerFadeTicker").Initialize = function() end
            TrackerUtils.IsVoiceOverLoaded = function() return false end
            TrackerUtils.GetSortedQuestIds = spy.new(function()
                assert.spy(TrackerData.Refresh).was.called(1)
                return {}, {}
            end)

            dofile("Localization/l10n.lua")
            dofile("Modules/Tracker/QuestieTracker.lua")
            QuestieTracker.started = false
            QuestieTracker.alreadyHooked = nil
            QuestieTracker.HookBaseTracker = function() end
            local initialized, err = coroutine.resume(coroutine.create(QuestieTracker.Initialize))
            assert.is_true(initialized, err)
        end)

        after_each(function()
            timeMock:revert()
            combatMock:revert()
            countMock:revert()
            instanceMock:revert()
            infoMock:revert()
            expansion.Current = originalExpansion
            _G.C_Timer, _G.DurabilityFrame = originalTimer, originalDurability
            _G.BINDING_NAME_QUESTIE_TOGGLE_TRACKER = originalBindingLabel
        end)

        it("refreshes once before layout and sorting read the snapshot", function()
            now = 1
            QuestieTracker:Update()
            QuestieTracker:Update() -- The throttled call does not rebuild the data again.

            assert.spy(TrackerData.Refresh).was.called(1)
            assert.spy(TrackerUtils.GetSortedQuestIds).was.called(1)
        end)

        it("refreshes only the affected quest for combat-safe text updates", function()
            now, inCombat = 1, true
            local quest = {Id = 91741, Objectives = {}}
            TrackerData.RefreshQuest = spy.new(function() return quest end)
            pool.UpdateQuestLines = spy.new(function() end)

            QuestieTracker:Update()
            QuestieTracker.UpdateQuestLines(91741)

            assert.spy(TrackerData.Refresh).was.not_called()
            assert.spy(TrackerData.RefreshQuest).was.called_with(91741)
            assert.spy(pool.UpdateQuestLines).was.called_with(91741, quest)
        end)

        describe("quest-log reconciliation", function()
            local callbacks, nativeTitle, quest, layout, entriesMock, widthMock, heightMock, originalQuestLog

            before_each(function()
                widthMock = stub(_G, "GetScreenWidth", function() return 2000 end)
                heightMock = stub(_G, "GetScreenHeight", function() return 1000 end)
                originalQuestLog = _G.C_QuestLog
                _G.C_QuestLog = {GetQuestTimers = function() return {} end, GetMaxNumQuestsCanAccept = function() return 25 end}
                QuestieLoader:ImportModule("QuestLogCache").GetQuestCount = function() return 1 end
                entriesMock = stub(QuestieLoader:ImportModule("QuestieCompat"), "GetNumQuestLogEntries", function() return 2, 1 end)
                callbacks, nativeTitle = {}, "Nibbled-On Book"
                _G.C_Timer.After = function(_, callback) callbacks[#callbacks + 1] = callback end
                Questie.db.profile.trackerSortObjectives = "byZone"
                Questie.db.profile.autoTrackQuests = true
                Questie.db.char.collapsedZones = {}
                quest = {Id = 91741, name = nativeTitle, level = 2, zoneName = "Northshire Abbey", Objectives = {},
                    IsComplete = function() return 0 end}
                TrackerData.Refresh = spy.new(function() quest.name = nativeTitle end)
                TrackerData.GetQuests = function() return {[91741] = quest} end
                TrackerData.GetColoredQuestName = function(displayQuest) return displayQuest.name end
                TrackerUtils.GetQuestGroupName = function(displayQuest) return displayQuest.zoneName end
                TrackerUtils.GetCompletionText = function() return nil end
                TrackerUtils.ShouldShowCompletionText = function() return true end
                TrackerUtils.GetQuestItemIds = function() return {} end
                TrackerUtils.GetSortedQuestIds = spy.new(function() return {}, {} end)
                QuestieLoader:ImportModule("TrackerQuestTimers").GetRemainingTimeByQuestId = function() return nil end
                QuestieLoader:ImportModule("QuestieLib").GetQuestTypeSuffixPriority = function() return 1 end
                dofile("Modules/Tracker/TrackerQuestLogSnapshot.lua")
                header.Update = spy.new(function() end)
                pool.ResetLinesForChange = spy.new(function() end)
                pool.GetLastLine = function() return {} end
                -- Geometry is outside this test: observe entry into layout after reconciliation and throttle decisions.
                layout = spy.new(function() end)
                QuestieTracker.UpdateFormatting = layout

                now = 1
                QuestieTracker:Update()
                now = 2
                callbacks[1]() -- Startup enables formatting and performs the first complete layout.
                callbacks = {}
                TrackerData.Refresh:clear()
                TrackerUtils.GetSortedQuestIds:clear()
                pool.ResetLinesForChange:clear()
                header.Update:clear()
                layout:clear()
            end)

            after_each(function()
                entriesMock:revert()
                widthMock:revert()
                heightMock:revert()
                _G.C_QuestLog = originalQuestLog
            end)

            it("reconciles unchanged data without resetting rows, sorting or entering layout", function()
                now = 3
                QuestieTracker:Update(true)

                assert.spy(TrackerData.Refresh).was.called(1)
                assert.spy(pool.ResetLinesForChange).was.not_called()
                assert.spy(TrackerUtils.GetSortedQuestIds).was.not_called()
                assert.spy(header.Update).was.not_called()
                assert.spy(layout).was.not_called()
            end)

            it("rebuilds once when a late native title arrives", function()
                nativeTitle, now = "The Book's True Name", 3
                QuestieTracker:Update(true)
                now = 4
                QuestieTracker:Update(true)

                assert.are.equal("The Book's True Name", quest.name)
                assert.spy(TrackerData.Refresh).was.called(2)
                assert.spy(pool.ResetLinesForChange).was.called(1)
                assert.spy(layout).was.called(1)
            end)

            it("reapplies the real automatic width limit after a screen-size change", function()
                Questie.db.profile.trackerHeaderEnabled = true
                Questie.db.profile.trackerFontSizeHeader = 12
                Questie.db.profile.trackerWidthRatio = 0.25
                Questie.db.profile.TrackerWidth = 0
                pool.GetFirstLine = function() return {label = {GetUnboundedStringWidth = function() return 100 end}} end
                QuestieTracker.UpdateFormatting = function() QuestieTracker:UpdateWidth(1000) end
                now = 3
                QuestieTracker:Update()
                assert.are.equal(500, baseFrame:GetWidth())

                widthMock.returns(1000)
                now = 4
                QuestieTracker:Update(true)

                assert.are.equal(250, baseFrame:GetWidth())
            end)

            it("acknowledges auto-collapse applied by the quest population pass", function()
                Questie.db.profile.collapseCompletedQuests = true
                Questie.db.profile.trackerShowCompleteQuests = true
                Questie.db.profile.trackerQuestPadding = 0
                Questie.db.char.minAllQuestsInZone = {}
                quest.IsComplete = function() return 1 end
                TrackerUtils.GetSortedQuestIds = function()
                    return {91741}, {[91741] = {quest = quest, zoneName = "Northshire Abbey"}}
                end
                TrackerUtils.AddQuestItemButtons = function() return true end
                QuestieLoader:ImportModule("TrackerQuestTimers").UpdateAndGetRemainingTime = function() end
                QuestieTracker.UpdateWidth = function() baseFrame:SetWidth(500) end
                local line = CreateFrame("Frame")
                line.label = CreateFrame("Frame")
                line.label:SetSize(100, 10)
                line.label.GetUnboundedStringWidth = function() return 100 end
                line.label.SetText = function() end
                line.expandZone = CreateFrame("Button")
                line.expandZone.SetMode = function() end
                line.expandQuest = CreateFrame("Button")
                line.expandQuest.SetMode = function() end
                line.playButton = {SetPlayButton = function() end}
                pool.GetZoneLine = function() return line end
                pool.GetQuestTitleLine = function() return line end

                now = 3
                QuestieTracker:Update()
                assert.is_true(Questie.db.char.collapsedQuests[91741])
                now = 4
                QuestieTracker:Update(true)

                assert.spy(layout).was.called(1)
            end)

            it("does not suppress explicit settings or UI updates", function()
                now = 3
                QuestieTracker:Update()

                assert.spy(pool.ResetLinesForChange).was.called(1)
                assert.spy(layout).was.called(1)
            end)

            it("retains one trailing check when a burst hits the throttle", function()
                nativeTitle, now = "Updated title", 2.05
                QuestieTracker:Update(true)
                QuestieTracker:Update(true)
                assert.are.equal(1, #callbacks)
                assert.spy(TrackerData.Refresh).was.not_called()

                now = 2.2
                callbacks[1]()

                assert.are.equal("Updated title", quest.name)
                assert.spy(layout).was.called(1)
            end)

            it("keeps the trailing check combat-safe and reads the latest data after combat", function()
                now = 2.05
                QuestieTracker:Update(true)
                local queued = {}
                QuestieCombatQueue.Queue = function(_, callback) queued[#queued + 1] = callback end
                now, inCombat = 2.2, true
                callbacks[1]()
                nativeTitle = "Changed during combat"
                QuestieTracker:Update(true)

                assert.are.equal(1, #callbacks)
                assert.are.equal(1, #queued)
                assert.spy(layout).was.not_called()

                now, inCombat = 3, false
                queued[1]()
                assert.are.equal("Changed during combat", quest.name)
                assert.spy(layout).was.called(1)
            end)

            it("retires a pending timer after a newer fallback layout completes", function()
                TrackerUtils.GetQuestItemIds = function() return {90001} end
                now = 2.05
                QuestieTracker:Update(true)
                now = 2.2
                QuestieTracker:Update()
                TrackerData.Refresh:clear()

                now = 2.4
                callbacks[1]()

                assert.spy(TrackerData.Refresh).was.not_called()
                assert.spy(layout).was.called(1)
            end)

            it("retires a pending retry after a newer check confirms unchanged data", function()
                now = 2.05
                QuestieTracker:Update(true)
                now = 2.2
                QuestieTracker:Update(true)
                TrackerData.Refresh:clear()
                now = 2.4
                callbacks[1]()

                assert.spy(TrackerData.Refresh).was.not_called()
                assert.spy(layout).was.not_called()
            end)

            it("keeps an earlier retry when the newer layout fails", function()
                now = 2.05
                QuestieTracker:Update(true)
                now = 2.2
                QuestieTracker.UpdateFormatting = function() error("layout failed") end
                assert.has_error(function() QuestieTracker:Update() end, "layout failed")
                QuestieTracker.UpdateFormatting = layout
                nativeTitle = "Still pending"
                now = 2.4
                callbacks[1]()

                assert.are.equal("Still pending", quest.name)
                assert.spy(layout).was.called(1)
            end)

            it("does not let an obsolete queued callback consume a newer retry", function()
                TrackerUtils.GetQuestItemIds = function() return {90001} end
                now = 2.05
                QuestieTracker:Update(true)
                local queued = {}
                QuestieCombatQueue.Queue = function(_, callback) queued[#queued + 1] = callback end
                callbacks[1]() -- The old retry is already in the combat queue.
                now = 2.2
                QuestieTracker:Update()
                now = 2.25
                QuestieTracker:Update(true) -- Owns a new retry token.
                nativeTitle = "Arrived after the newer layout"
                now = 2.4
                queued[1]()
                assert.spy(layout).was.called(1)

                callbacks[2]()
                assert.are.equal(2, #queued)
                queued[2]()
                assert.are.equal("Arrived after the newer layout", quest.name)
                assert.spy(layout).was.called(2)
            end)

            it("preserves a reentrant request that shares an older pending timer", function()
                now = 2.05
                QuestieTracker:Update(true)
                now = 2.2
                QuestieTracker.UpdateFormatting = function()
                    nativeTitle = "Changed during layout"
                    QuestieTracker:Update(true)
                end
                QuestieTracker:Update()
                QuestieTracker.UpdateFormatting = layout
                assert.are.equal(1, #callbacks)

                now = 2.4
                callbacks[1]()

                assert.are.equal("Changed during layout", quest.name)
                assert.spy(layout).was.called(1)
            end)

            it("preserves a reentrant request that shares an older queued delivery", function()
                now = 2.05
                QuestieTracker:Update(true)
                local queued = {}
                QuestieCombatQueue.Queue = function(_, callback) queued[#queued + 1] = callback end
                callbacks[1]()
                now = 2.2
                QuestieTracker.UpdateFormatting = function()
                    nativeTitle = "Changed during layout"
                    QuestieTracker:Update(true)
                end
                QuestieTracker:Update()
                QuestieTracker.UpdateFormatting = layout
                assert.are.equal(1, #callbacks)
                assert.are.equal(1, #queued)

                now = 2.4
                queued[1]()

                assert.are.equal("Changed during layout", quest.name)
                assert.spy(layout).was.called(1)
            end)

            it("preserves a retry requested during a successful layout", function()
                now = 3
                QuestieTracker.UpdateFormatting = function()
                    QuestieTracker:Update(true) -- A callback raises a request after this layout began.
                end
                QuestieTracker:Update()
                assert.are.equal(1, #callbacks)
                nativeTitle = "New data after layout"
                QuestieTracker.UpdateFormatting = layout
                now = 3.2
                callbacks[1]()

                assert.are.equal("New data after layout", quest.name)
                assert.spy(layout).was.called(1)
            end)

            it("does not let reconciliation hide a throttled explicit update", function()
                now = 2.05
                QuestieTracker:Update()
                now = 3
                QuestieTracker:Update(true)

                assert.spy(layout).was.called(1)
            end)

            it("does not retain a baseline after a failed layout", function()
                nativeTitle, now = "New title", 3
                QuestieTracker.UpdateFormatting = function() error("layout failed") end
                assert.has_error(function() QuestieTracker:Update(true) end, "layout failed")

                -- Returning to the old input must still repair the partially rebuilt frames.
                nativeTitle, now = "Nibbled-On Book", 4
                QuestieTracker.UpdateFormatting = layout
                QuestieTracker:Update(true)

                assert.spy(layout).was.called(1)
                assert.spy(pool.ResetLinesForChange).was.called(2)
            end)

            it("continues rebuilding layouts with active quest-item buttons", function()
                TrackerUtils.GetQuestItemIds = function() return {90001} end
                now = 3
                QuestieTracker:Update(true)
                now = 4
                QuestieTracker:Update(true)

                assert.spy(layout).was.called(2)
            end)

            it("rebuilds after the tracker was disabled and re-enabled", function()
                Questie.db.profile.trackerEnabled = false
                now = 3
                QuestieTracker:Update(true)
                Questie.db.profile.trackerEnabled = true
                now = 4
                QuestieTracker:Update(true)

                assert.spy(layout).was.called(1)
            end)
        end)

        describe("saved focus before the first full refresh", function()
            local original, objective

            before_each(function()
                objective = {Index = 3, HideIcons = true, spawnList = {{Spawns = {[12] = {{50, 50}}}}}}
                original = {Id = 11, HideIcons = true, Objectives = {[3] = objective}, SpecialObjectives = {}}
                QuestieLoader:ImportModule("QuestiePlayer").currentQuestlog = {[11] = original}
                QuestieLoader:ImportModule("QuestieDB").GetQuest = function() return original end
                TrackerData.RefreshQuest = spy.new(function()
                    return {Id = 11, enrichment = original, Objectives = {{enrichment = objective}},
                        SpecialObjectives = {}, IsComplete = function() return 0 end}
                end)
                dofile("Modules/Tracker/TrackerMapEligibility.lua")
                dofile("Modules/Tracker/TrackerUtils.lua")
                TrackerUtils.IsVoiceOverLoaded = function() return false end
                QuestieTracker.started = false
            end)

            it("restores quest focus through an explicit single-quest refresh", function()
                Questie.db.char.TrackerFocus = 11

                local initialized, err = coroutine.resume(coroutine.create(QuestieTracker.Initialize))

                assert.is_true(initialized, err)
                assert.spy(TrackerData.Refresh).was.not_called()
                assert.spy(TrackerData.RefreshQuest).was.called_with(11)
                assert.are.equal(11, Questie.db.char.TrackerFocus)
                assert.is_nil(original.HideIcons)
                assert.spy(QuestieQuest.ToggleNotes).was.called_with(QuestieQuest, false)
            end)

            it("restores objective focus using the original index before a full refresh", function()
                Questie.db.char.TrackerFocus = "11 3"

                local initialized, err = coroutine.resume(coroutine.create(QuestieTracker.Initialize))

                assert.is_true(initialized, err)
                assert.spy(TrackerData.Refresh).was.not_called()
                assert.spy(TrackerData.RefreshQuest).was.called_with(11)
                assert.are.equal("11 3", Questie.db.char.TrackerFocus)
                assert.is_nil(objective.HideIcons)
                assert.spy(QuestieQuest.ToggleNotes).was.called_with(QuestieQuest, false)
            end)

            it("keeps saved focus while its quest is still loading and restores it on a later update", function()
                local ready = false
                TrackerData.RefreshQuest = spy.new(function()
                    return {Id = 11, enrichment = ready and original or nil, Objectives = {{enrichment = objective}},
                        SpecialObjectives = {}, IsComplete = function() return 0 end}
                end)
                TrackerData.ContainsQuest = function() return true end
                Questie.db.char.TrackerFocus = "11 3"

                local initialized, err = coroutine.resume(coroutine.create(QuestieTracker.Initialize))

                assert.is_true(initialized, err)
                assert.are.equal("11 3", Questie.db.char.TrackerFocus)
                assert.spy(QuestieQuest.ToggleNotes).was.not_called()

                ready, now = true, 1
                TrackerUtils.GetSortedQuestIds = function() return {}, {} end
                QuestieTracker:Update()

                assert.is_nil(objective.HideIcons)
                assert.spy(QuestieQuest.ToggleNotes).was.called_with(QuestieQuest, false)
            end)

            it("clears saved focus that still cannot apply once the restore timeout passes", function()
                TrackerData.RefreshQuest = spy.new(function()
                    return {Id = 11, Objectives = {}, SpecialObjectives = {}, IsComplete = function() return 0 end}
                end)
                TrackerData.ContainsQuest = function() return true end
                TrackerUtils.GetSortedQuestIds = function() return {}, {} end
                TrackerUtils.UnFocus = spy.new(function() Questie.db.char.TrackerFocus = nil end)
                Questie.db.char.TrackerFocus = 11

                local initialized, err = coroutine.resume(coroutine.create(QuestieTracker.Initialize))
                assert.is_true(initialized, err)

                now = 30
                QuestieTracker:Update()
                assert.are.equal(11, Questie.db.char.TrackerFocus)

                now = 61
                TrackerData.Refresh:clear() -- The shared header stub asserts one refresh per update.
                QuestieTracker:Update()
                assert.spy(TrackerUtils.UnFocus).was.called(1)
                assert.is_nil(Questie.db.char.TrackerFocus)
                assert.spy(QuestieQuest.ToggleNotes).was.not_called()
            end)

            it("clears a malformed saved objective focus at startup", function()
                TrackerUtils.UnFocus = spy.new(function() Questie.db.char.TrackerFocus = nil end)
                Questie.db.char.TrackerFocus = "11 x"

                local initialized, err = coroutine.resume(coroutine.create(QuestieTracker.Initialize))

                assert.is_true(initialized, err)
                assert.spy(TrackerUtils.UnFocus).was.called(1)
                assert.spy(TrackerData.RefreshQuest).was.not_called()
            end)

            it("clears saved focus when its quest is no longer in the quest log", function()
                TrackerData.RefreshQuest = spy.new(function() return nil end)
                TrackerData.ContainsQuest = function() return false end
                TrackerUtils.UnFocus = spy.new(function() Questie.db.char.TrackerFocus = nil end)
                Questie.db.char.TrackerFocus = 11

                local initialized, err = coroutine.resume(coroutine.create(QuestieTracker.Initialize))

                assert.is_true(initialized, err)
                assert.spy(TrackerUtils.UnFocus).was.called(1)
                assert.spy(QuestieQuest.ToggleNotes).was.not_called()
            end)
        end)
    end)

    describe("ToggleTracker", function()
        it("should collapse when tracker is expanded", function()
            Questie.db.char.isTrackerExpanded = true
            QuestieTracker.Collapse = spy.new(function() end)

            QuestieTracker.ToggleTracker()

            assert.spy(QuestieTracker.Collapse).was.called()
        end)

        it("should expand when tracker is collapsed", function()
            Questie.db.char.isTrackerExpanded = false
            QuestieTracker.Expand = spy.new(function() end)

            QuestieTracker.ToggleTracker()

            assert.spy(QuestieTracker.Expand).was.called()
        end)

        it("should do nothing when tracker is disabled", function()
            Questie.db.profile.trackerEnabled = false
            QuestieTracker.Collapse = spy.new(function() end)
            QuestieTracker.Expand = spy.new(function() end)

            QuestieTracker.ToggleTracker()

            assert.spy(QuestieTracker.Collapse).was.not_called()
            assert.spy(QuestieTracker.Expand).was.not_called()
        end)
    end)

    describe("HandleZoneChanged", function()
        it("should collapse the tracker when entering an instance with minimize enabled", function()
            Questie.db.profile.minimizeTrackerInInstances = true
            _G.IsInInstance = function() return true end
            QuestieTracker.Collapse = spy.new(function() end)

            QuestieTracker.HandleZoneChanged()

            assert.spy(QuestieTracker.Collapse).was.called()
        end)

        it("should not claim ownership of an already-manually-minimized tracker when entering an instance, so it is not auto-expanded on leaving", function()
            Questie.db.profile.minimizeTrackerInInstances = true
            Questie.db.char.isTrackerExpanded = false -- manually minimized by the player before entering
            _G.IsInInstance = function() return true end
            QuestieTracker.Collapse = spy.new(function() end)

            QuestieTracker.HandleZoneChanged() -- entering the instance

            _G.IsInInstance = function() return false end
            _G.UnitIsGhost = function() return false end
            QuestieTracker.Expand = spy.new(function() end)

            QuestieTracker.HandleZoneChanged() -- leaving the instance

            assert.spy(QuestieTracker.Expand).was.not_called()
        end)

        it("should queue the collapse via QuestieCombatQueue instead of calling it directly", function()
            Questie.db.profile.minimizeTrackerInInstances = true
            _G.IsInInstance = function() return true end
            QuestieCombatQueue.Queue = spy.new(function() end)
            QuestieTracker.Collapse = spy.new(function() end)

            QuestieTracker.HandleZoneChanged()

            assert.spy(QuestieCombatQueue.Queue).was.called()
            assert.spy(QuestieTracker.Collapse).was.not_called()
        end)

        it("should hide the tracker directly when entering an instance with hide enabled", function()
            Questie.db.profile.hideTrackerInInstances = true
            _G.IsInInstance = function() return true end
            QuestieTracker.Hide = spy.new(function() end)

            QuestieTracker.HandleZoneChanged()

            assert.spy(QuestieTracker.Hide).was.called()
        end)

        it("should do nothing when the tracker is disabled, even if in an instance with minimize enabled", function()
            Questie.db.profile.trackerEnabled = false
            Questie.db.profile.minimizeTrackerInInstances = true
            _G.IsInInstance = function() return true end
            QuestieTracker.Collapse = spy.new(function() end)

            QuestieTracker.HandleZoneChanged()

            assert.spy(QuestieTracker.Collapse).was.not_called()
        end)

        it("should do nothing when leaving an instance while the tracker is disabled, even if previously minimized", function()
            Questie.db.profile.minimizeTrackerInInstances = true
            _G.IsInInstance = function() return true end
            QuestieTracker.HandleZoneChanged() -- entered instance, minimizedByInstance is now true

            Questie.db.profile.trackerEnabled = false
            _G.IsInInstance = function() return false end
            _G.UnitIsGhost = function() return false end
            Questie.db.char.isTrackerExpanded = false
            QuestieTracker.Expand = spy.new(function() end)

            QuestieTracker.HandleZoneChanged()

            assert.spy(QuestieTracker.Expand).was.not_called()
        end)

        it("should expand the tracker when leaving an instance after having been minimized", function()
            Questie.db.profile.minimizeTrackerInInstances = true
            _G.IsInInstance = function() return true end
            QuestieTracker.HandleZoneChanged() -- entered instance, minimizedByInstance is now true

            _G.IsInInstance = function() return false end
            _G.UnitIsGhost = function() return false end
            Questie.db.char.isTrackerExpanded = false
            QuestieTracker.Expand = spy.new(function() end)

            QuestieTracker.HandleZoneChanged()

            assert.spy(QuestieTracker.Expand).was.called()
        end)

        it("should show the tracker when leaving an instance after having been hidden", function()
            Questie.db.profile.hideTrackerInInstances = true
            _G.IsInInstance = function() return true end
            QuestieTracker.HandleZoneChanged() -- entered instance, hiddenByInstance is now true

            _G.IsInInstance = function() return false end
            QuestieTracker.Show = spy.new(function() end)

            QuestieTracker.HandleZoneChanged()

            assert.spy(QuestieTracker.Show).was.called()
        end)

        it("should not expand when leaving an instance if minimize was turned off in the meantime", function()
            Questie.db.profile.minimizeTrackerInInstances = true
            _G.IsInInstance = function() return true end
            QuestieTracker.HandleZoneChanged() -- entered instance, minimizedByInstance is now true

            Questie.db.profile.minimizeTrackerInInstances = false
            _G.IsInInstance = function() return false end
            _G.UnitIsGhost = function() return false end
            Questie.db.char.isTrackerExpanded = false
            QuestieTracker.Expand = spy.new(function() end)

            QuestieTracker.HandleZoneChanged()

            assert.spy(QuestieTracker.Expand).was.not_called()
        end)

        it("should not expand when leaving an instance while the player is a ghost", function()
            Questie.db.profile.minimizeTrackerInInstances = true
            _G.IsInInstance = function() return true end
            QuestieTracker.HandleZoneChanged() -- entered instance, minimizedByInstance is now true

            _G.IsInInstance = function() return false end
            _G.UnitIsGhost = function() return true end
            Questie.db.char.isTrackerExpanded = false
            QuestieTracker.Expand = spy.new(function() end)

            QuestieTracker.HandleZoneChanged()

            assert.spy(QuestieTracker.Expand).was.not_called()
        end)

        it("should not show when leaving an instance if hide was turned off in the meantime", function()
            Questie.db.profile.hideTrackerInInstances = true
            _G.IsInInstance = function() return true end
            QuestieTracker.HandleZoneChanged() -- entered instance, hiddenByInstance is now true

            Questie.db.profile.hideTrackerInInstances = false
            _G.IsInInstance = function() return false end
            QuestieTracker.Show = spy.new(function() end)

            QuestieTracker.HandleZoneChanged()

            assert.spy(QuestieTracker.Show).was.not_called()
        end)

        it("should do nothing when leaving an instance if the tracker was never minimized or hidden by it", function()
            _G.IsInInstance = function() return false end
            QuestieTracker.Expand = spy.new(function() end)
            QuestieTracker.Show = spy.new(function() end)

            QuestieTracker.HandleZoneChanged()

            assert.spy(QuestieTracker.Expand).was.not_called()
            assert.spy(QuestieTracker.Show).was.not_called()
        end)
    end)

    describe("OnMinimizeInInstancesChanged", function()
        it("should collapse the tracker when enabled while in an instance and expanded", function()
            Questie.db.char.isTrackerExpanded = true
            _G.IsInInstance = function() return true end
            QuestieTracker.Collapse = spy.new(function() end)

            QuestieTracker.OnMinimizeInInstancesChanged(true)

            assert.spy(QuestieTracker.Collapse).was.called()
        end)

        it("should not collapse the tracker when enabled while not in an instance", function()
            _G.IsInInstance = function() return false end
            QuestieTracker.Collapse = spy.new(function() end)

            QuestieTracker.OnMinimizeInInstancesChanged(true)

            assert.spy(QuestieTracker.Collapse).was.not_called()
        end)

        it("should expand the tracker when disabled after it claimed ownership of the collapse", function()
            Questie.db.char.isTrackerExpanded = true
            _G.IsInInstance = function() return true end
            QuestieTracker.OnMinimizeInInstancesChanged(true) -- claims ownership

            Questie.db.char.isTrackerExpanded = false
            QuestieTracker.Expand = spy.new(function() end)

            QuestieTracker.OnMinimizeInInstancesChanged(false)

            assert.spy(QuestieTracker.Expand).was.called()
        end)

        it("should not expand the tracker when disabled if it never claimed ownership (manually minimized)", function()
            Questie.db.char.isTrackerExpanded = false -- already manually minimized
            _G.IsInInstance = function() return true end
            QuestieTracker.OnMinimizeInInstancesChanged(true) -- does not claim ownership

            QuestieTracker.Expand = spy.new(function() end)

            QuestieTracker.OnMinimizeInInstancesChanged(false)

            assert.spy(QuestieTracker.Expand).was.not_called()
        end)
    end)

    describe("OnHideInInstancesChanged", function()
        it("should hide the tracker when enabled while in an instance", function()
            _G.IsInInstance = function() return true end
            QuestieTracker.Hide = spy.new(function() end)

            QuestieTracker.OnHideInInstancesChanged(true)

            assert.spy(QuestieTracker.Hide).was.called()
        end)

        it("should not hide the tracker when enabled while not in an instance", function()
            _G.IsInInstance = function() return false end
            QuestieTracker.Hide = spy.new(function() end)

            QuestieTracker.OnHideInInstancesChanged(true)

            assert.spy(QuestieTracker.Hide).was.not_called()
        end)

        it("should show the tracker when disabled after it claimed ownership of the hide", function()
            _G.IsInInstance = function() return true end
            QuestieTracker.OnHideInInstancesChanged(true) -- claims ownership

            QuestieTracker.Show = spy.new(function() end)

            QuestieTracker.OnHideInInstancesChanged(false)

            assert.spy(QuestieTracker.Show).was.called()
        end)

        it("should not show the tracker when disabled if it never claimed ownership", function()
            QuestieTracker.Show = spy.new(function() end)

            QuestieTracker.OnHideInInstancesChanged(false)

            assert.spy(QuestieTracker.Show).was.not_called()
        end)
    end)

    describe("HandleCombatStarted / HandleCombatEnded", function()
        it("should collapse the tracker when entering combat with minimize enabled and expanded", function()
            Questie.db.profile.minimizeTrackerInCombat = true
            Questie.db.char.isTrackerExpanded = true
            QuestieTracker.Collapse = spy.new(function() end)

            QuestieTracker.HandleCombatStarted()

            assert.spy(QuestieTracker.Collapse).was.called()
        end)

        it("should hide the tracker when entering combat with hide enabled", function()
            Questie.db.profile.hideTrackerInCombat = true
            QuestieTracker.Hide = spy.new(function() end)

            QuestieTracker.HandleCombatStarted()

            assert.spy(QuestieTracker.Hide).was.called()
        end)

        it("should re-collapse when entering combat while already in an instance with minimize enabled", function()
            Questie.db.profile.minimizeTrackerInInstances = true
            _G.IsInInstance = function() return true end
            QuestieTracker.Collapse = spy.new(function() end)

            QuestieTracker.HandleCombatStarted()

            assert.spy(QuestieTracker.Collapse).was.called()
        end)

        it("should expand the tracker when leaving combat after it was minimized due to combat", function()
            Questie.db.profile.minimizeTrackerInCombat = true
            Questie.db.char.isTrackerExpanded = true
            QuestieTracker.HandleCombatStarted() -- entered combat, claims ownership

            QuestieTracker.Expand = spy.new(function() end)

            QuestieTracker.HandleCombatEnded()

            assert.spy(QuestieTracker.Expand).was.called()
        end)

        it("should not expand when leaving combat while still in an instance that also wants it minimized", function()
            Questie.db.profile.minimizeTrackerInCombat = true
            Questie.db.profile.minimizeTrackerInInstances = true
            Questie.db.char.isTrackerExpanded = true
            _G.IsInInstance = function() return true end
            QuestieTracker.HandleCombatStarted() -- entered combat, claims ownership

            QuestieTracker.Expand = spy.new(function() end)

            QuestieTracker.HandleCombatEnded()

            assert.spy(QuestieTracker.Expand).was.not_called()
        end)

        it("should show the tracker when leaving combat after it was hidden due to combat", function()
            Questie.db.profile.hideTrackerInCombat = true
            QuestieTracker.HandleCombatStarted() -- entered combat, claims ownership

            QuestieTracker.Show = spy.new(function() end)

            QuestieTracker.HandleCombatEnded()

            assert.spy(QuestieTracker.Show).was.called()
        end)

        it("should not show when leaving combat while still in an instance that also wants it hidden", function()
            Questie.db.profile.hideTrackerInCombat = true
            Questie.db.profile.hideTrackerInInstances = true
            _G.IsInInstance = function() return true end
            QuestieTracker.HandleCombatStarted() -- entered combat, claims ownership

            QuestieTracker.Show = spy.new(function() end)

            QuestieTracker.HandleCombatEnded()

            assert.spy(QuestieTracker.Show).was.not_called()
        end)

        it("should queue an Update when leaving combat after minimize was active due to combat", function()
            Questie.db.profile.minimizeTrackerInCombat = true
            Questie.db.char.isTrackerExpanded = true
            QuestieTracker.HandleCombatStarted()

            QuestieCombatQueue.Queue = spy.new(function() end)

            QuestieTracker.HandleCombatEnded()

            assert.spy(QuestieCombatQueue.Queue).was.called()
        end)

        it(
            "should transfer minimize ownership from combat to instance when entering an instance while minimized by combat, so leaving the instance later still expands",
            function()
                Questie.db.profile.minimizeTrackerInCombat = true
                Questie.db.profile.minimizeTrackerInInstances = true
                Questie.db.char.isTrackerExpanded = true
                _G.IsInInstance = function() return false end
                QuestieTracker.Collapse = spy.new(function() Questie.db.char.isTrackerExpanded = false end)

                QuestieTracker.HandleCombatStarted() -- combat starts outside the instance, claims ownership via minimizedByCombat

                _G.IsInInstance = function() return true end
                QuestieTracker.HandleZoneChanged() -- zones into the instance while still collapsed/in combat

                QuestieTracker.HandleCombatEnded() -- combat ends while still in the instance; ownership should transfer to minimizedByInstance

                _G.IsInInstance = function() return false end
                _G.UnitIsGhost = function() return false end
                QuestieTracker.Expand = spy.new(function() end)
                QuestieTracker.HandleZoneChanged() -- leaves the instance

                assert.spy(QuestieTracker.Expand).was.called()
            end)

        it("should keep minimize ownership with instance when entering combat while minimized by instance, so leaving the instance still expands", function()
            Questie.db.profile.minimizeTrackerInCombat = true
            Questie.db.profile.minimizeTrackerInInstances = true
            Questie.db.char.isTrackerExpanded = true
            _G.IsInInstance = function() return true end
            QuestieTracker.Collapse = spy.new(function() Questie.db.char.isTrackerExpanded = false end)

            QuestieTracker.HandleZoneChanged() -- enters the instance, claims ownership via minimizedByInstance

            QuestieTracker.HandleCombatStarted() -- combat starts while already minimized by the instance

            QuestieTracker.HandleCombatEnded() -- combat ends while still in the instance

            _G.IsInInstance = function() return false end
            _G.UnitIsGhost = function() return false end
            QuestieTracker.Expand = spy.new(function() end)
            QuestieTracker.HandleZoneChanged() -- leaves the instance

            assert.spy(QuestieTracker.Expand).was.called()
        end)

        it("should transfer hide ownership from combat to instance when entering an instance while hidden by combat, so leaving the instance later still shows",
            function()
                Questie.db.profile.hideTrackerInCombat = true
                Questie.db.profile.hideTrackerInInstances = true
                _G.IsInInstance = function() return false end

                QuestieTracker.HandleCombatStarted() -- combat starts outside the instance, claims ownership via hiddenByCombat

                _G.IsInInstance = function() return true end
                QuestieTracker.HandleZoneChanged() -- zones into the instance while still hidden/in combat

                QuestieTracker.HandleCombatEnded() -- combat ends while still in the instance; ownership should transfer to hiddenByInstance

                _G.IsInInstance = function() return false end
                QuestieTracker.Show = spy.new(function() end)
                QuestieTracker.HandleZoneChanged() -- leaves the instance

                assert.spy(QuestieTracker.Show).was.called()
            end)

        it("should keep hide ownership with instance when entering combat while hidden by instance, so leaving the instance still shows", function()
            Questie.db.profile.hideTrackerInCombat = true
            Questie.db.profile.hideTrackerInInstances = true
            _G.IsInInstance = function() return true end

            QuestieTracker.HandleZoneChanged() -- enters the instance, claims ownership via hiddenByInstance

            QuestieTracker.HandleCombatStarted() -- combat starts while already hidden by the instance

            QuestieTracker.HandleCombatEnded() -- combat ends while still in the instance

            _G.IsInInstance = function() return false end
            QuestieTracker.Show = spy.new(function() end)
            QuestieTracker.HandleZoneChanged() -- leaves the instance

            assert.spy(QuestieTracker.Show).was.called()
        end)
    end)

    describe("OnMinimizeInCombatChanged", function()
        it("should collapse the tracker when enabled while in combat and expanded", function()
            Questie.db.char.isTrackerExpanded = true
            _G.InCombatLockdown = function() return true end
            QuestieTracker.Collapse = spy.new(function() end)

            QuestieTracker.OnMinimizeInCombatChanged(true)

            assert.spy(QuestieTracker.Collapse).was.called()
        end)

        it("should not collapse the tracker when enabled while not in combat", function()
            _G.InCombatLockdown = function() return false end
            QuestieTracker.Collapse = spy.new(function() end)

            QuestieTracker.OnMinimizeInCombatChanged(true)

            assert.spy(QuestieTracker.Collapse).was.not_called()
        end)

        it("should expand the tracker when disabled after it claimed ownership of the collapse", function()
            Questie.db.char.isTrackerExpanded = true
            _G.InCombatLockdown = function() return true end
            QuestieTracker.OnMinimizeInCombatChanged(true) -- claims ownership

            QuestieTracker.Expand = spy.new(function() end)

            QuestieTracker.OnMinimizeInCombatChanged(false)

            assert.spy(QuestieTracker.Expand).was.called()
        end)

        it("should not expand the tracker when disabled if it never claimed ownership (manually minimized)", function()
            Questie.db.char.isTrackerExpanded = false -- already manually minimized
            _G.InCombatLockdown = function() return true end
            QuestieTracker.OnMinimizeInCombatChanged(true) -- does not claim ownership, tracker was not expanded

            QuestieTracker.Expand = spy.new(function() end)

            QuestieTracker.OnMinimizeInCombatChanged(false)

            assert.spy(QuestieTracker.Expand).was.not_called()
        end)

        it("should not expand when disabled while still minimized for an instance, and should transfer ownership so leaving the instance still expands",
            function()
                Questie.db.profile.minimizeTrackerInCombat = true
                Questie.db.profile.minimizeTrackerInInstances = true
                Questie.db.char.isTrackerExpanded = true
                _G.InCombatLockdown = function() return true end
                _G.IsInInstance = function() return false end
                QuestieTracker.Collapse = spy.new(function() Questie.db.char.isTrackerExpanded = false end)

                QuestieTracker.OnMinimizeInCombatChanged(true) -- combat claims ownership, outside any instance

                _G.IsInInstance = function() return true end
                QuestieTracker.HandleZoneChanged() -- zones into the instance while still collapsed/in combat

                QuestieTracker.Expand = spy.new(function() end)
                QuestieTracker.OnMinimizeInCombatChanged(false) -- disables combat-minimize while still in the instance

                assert.spy(QuestieTracker.Expand).was.not_called()

                -- Ownership should have transferred to the instance: leaving it afterwards should expand.
                _G.IsInInstance = function() return false end
                _G.UnitIsGhost = function() return false end
                QuestieTracker.HandleZoneChanged()

                assert.spy(QuestieTracker.Expand).was.called()
            end)
    end)

    describe("OnHideInCombatChanged", function()
        it("should hide the tracker when enabled while in combat", function()
            _G.InCombatLockdown = function() return true end
            QuestieTracker.Hide = spy.new(function() end)

            QuestieTracker.OnHideInCombatChanged(true)

            assert.spy(QuestieTracker.Hide).was.called()
        end)

        it("should not hide the tracker when enabled while not in combat", function()
            _G.InCombatLockdown = function() return false end
            QuestieTracker.Hide = spy.new(function() end)

            QuestieTracker.OnHideInCombatChanged(true)

            assert.spy(QuestieTracker.Hide).was.not_called()
        end)

        it("should show the tracker when disabled after it claimed ownership of the hide", function()
            _G.InCombatLockdown = function() return true end
            QuestieTracker.OnHideInCombatChanged(true) -- claims ownership

            QuestieTracker.Show = spy.new(function() end)

            QuestieTracker.OnHideInCombatChanged(false)

            assert.spy(QuestieTracker.Show).was.called()
        end)

        it("should not show the tracker when disabled if it never claimed ownership", function()
            QuestieTracker.Show = spy.new(function() end)

            QuestieTracker.OnHideInCombatChanged(false)

            assert.spy(QuestieTracker.Show).was.not_called()
        end)

        it("should not clear instance-hidden state when disabling hide-in-combat while still hidden by an instance", function()
            Questie.db.profile.hideTrackerInInstances = true
            _G.IsInInstance = function() return true end
            QuestieTracker.HandleZoneChanged() -- legitimately hidden by the instance

            Questie.db.profile.hideTrackerInCombat = true
            _G.InCombatLockdown = function() return true end
            QuestieTracker.OnHideInCombatChanged(true) -- also hidden by combat now

            QuestieTracker.OnHideInCombatChanged(false) -- toggling combat-hide off mid-fight, still inside the instance

            -- The instance-hide should still be in effect: leaving the instance afterwards
            -- should still show the tracker, proving hiddenByInstance was not cleared above.
            _G.IsInInstance = function() return false end
            QuestieTracker.Show = spy.new(function() end)
            QuestieTracker.HandleZoneChanged()

            assert.spy(QuestieTracker.Show).was.called()
        end)

        it("should not show when disabled while still hidden for an instance, and should transfer ownership so leaving the instance still shows", function()
            Questie.db.profile.hideTrackerInCombat = true
            Questie.db.profile.hideTrackerInInstances = true
            _G.InCombatLockdown = function() return true end
            _G.IsInInstance = function() return false end

            QuestieTracker.OnHideInCombatChanged(true) -- combat claims ownership, outside any instance

            _G.IsInInstance = function() return true end
            QuestieTracker.HandleZoneChanged() -- zones into the instance while still hidden/in combat

            QuestieTracker.Show = spy.new(function() end)
            QuestieTracker.OnHideInCombatChanged(false) -- disables combat-hide while still in the instance

            assert.spy(QuestieTracker.Show).was.not_called()

            -- Ownership should have transferred to the instance: leaving it afterwards should show.
            _G.IsInInstance = function() return false end
            QuestieTracker.HandleZoneChanged()

            assert.spy(QuestieTracker.Show).was.called()
        end)
    end)

    describe("Collapse and Expand", function()
        it("should guard against calling when conditions are not met", function()
            -- Test that Collapse does nothing when tracker is already collapsed
            Questie.db.char.isTrackerExpanded = false
            _G.InCombatLockdown = function() return false end

            -- This should be a no-op since isTrackerExpanded is false (guard fails)
            QuestieTracker:Collapse()
            assert.is_false(Questie.db.char.isTrackerExpanded)
        end)

        it("should guard against calling when conditions are not met (expand)", function()
            -- Test that Expand does nothing when tracker is already expanded
            Questie.db.char.isTrackerExpanded = true
            _G.InCombatLockdown = function() return false end

            -- This should be a no-op since isTrackerExpanded is true (guard fails)
            QuestieTracker:Expand()
            assert.is_true(Questie.db.char.isTrackerExpanded)
        end)
    end)
end)
