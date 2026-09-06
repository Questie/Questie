dofile("setupTests.lua")

local LoadQuestieTDBMock = dofile("test/QuestieTDBMock.lua")

describe("QuestieInit", function()
    ---@type QuestieInit
    local QuestieInit
    ---@type QuestieTDBMock
    local mock

    ---@type string[]
    local callOrder

    ---@param name string
    ---@return fun(): nil
    local function _Record(name)
        return function()
            table.insert(callOrder, name)
        end
    end

    ---Runs one Login Initialization stage to completion, resuming across every coroutine yield.
    ---@param stageIndex number
    ---@return nil
    local function _RunStage(stageIndex)
        local stage = coroutine.create(QuestieInit.Stages[stageIndex])
        repeat
            local ok, err = coroutine.resume(stage)
            if not ok then
                error(err, 0)
            end
        until coroutine.status(stage) == "dead"
    end

    before_each(function()
        mock = LoadQuestieTDBMock()
        callOrder = {}
        Questie.db.profile.enableTooltipsObjectID = false

        local l10n = QuestieLoader:ImportModule("l10n")
        l10n.InitializeUILocale = _Record("l10n.InitializeUILocale")
        l10n.PublishLocaleOverrideEntityNames = _Record("l10n.PublishLocaleOverrideEntityNames")
        l10n.GetUILocale = function() return "deDE" end

        -- The provider locale forward goes through the mock, so the recorded order proves it
        -- lands between the UI locale and the policy writes.
        local originalSetLocale = mock.lib.l10n.SetLocale
        mock.lib.l10n.SetLocale = function(locale)
            table.insert(callOrder, "LibQuestieDB.l10n.SetLocale:" .. locale)
            originalSetLocale(locale)
        end

        local QuestieCorrections = QuestieLoader:ImportModule("QuestieCorrections")
        QuestieCorrections.Initialize = _Record("QuestieCorrections.Initialize")

        local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
        QuestieDB.Initialize = _Record("QuestieDB.Initialize")

        local Townsfolk = QuestieLoader:ImportModule("Townsfolk")
        Townsfolk.Initialize = _Record("Townsfolk.Initialize")
        Townsfolk.BuildCharacterTownsfolk = _Record("Townsfolk:BuildCharacterTownsfolk")

        local QuestieEvent = QuestieLoader:ImportModule("QuestieEvent")
        QuestieEvent.Initialize = _Record("QuestieEvent.Initialize")

        local Tutorial = QuestieLoader:ImportModule("Tutorial")
        Tutorial.Initialize = _Record("Tutorial.Initialize")

        dofile("Modules/QuestieInit.lua")
        QuestieInit = QuestieLoader:ImportModule("QuestieInit")
    end)

    describe("Stage 1", function()
        it("runs Login Initialization in the compiler-free order", function()
            _RunStage(1)

            assert.are_same({
                "l10n.InitializeUILocale",
                "LibQuestieDB.l10n.SetLocale:deDE",
                "l10n.PublishLocaleOverrideEntityNames",
                "QuestieCorrections.Initialize",
                "QuestieDB.Initialize",
                "Townsfolk.Initialize",
                "Townsfolk:BuildCharacterTownsfolk",
                "QuestieEvent.Initialize",
                "Tutorial.Initialize",
            }, callOrder)
        end)

        it("forwards the effective locale to the provider exactly once", function()
            _RunStage(1)

            assert.are_same({"deDE"}, mock.setLocaleCalls)
        end)

        it("rejects an older contract-2 provider missing translation slots before forwarding", function()
            mock.lib.l10n.SetCorrection = nil
            assert.has_error(function() _RunStage(1) end,
                "Questie requires QuestieTDB localization corrections. Update QuestieTDB.")
            assert.are_same({"l10n.InitializeUILocale"}, callOrder)
            assert.are_same({}, mock.setLocaleCalls)
        end)

        it("stops with the Contract error before forwarding the locale or touching Corrections", function()
            mock.minSupportedContract = 1
            mock.contractVersion = 1

            assert.has_error(function()
                _RunStage(1)
            end, "QuestieTDB contract mismatch: this consumer needs version 2, the installed QuestieTDB provides 1 " ..
                "(supporting consumers back to 1). Update whichever is older.")
            assert.are_same({"l10n.InitializeUILocale"}, callOrder)
        end)
    end)

    describe("Stage 2", function()
        local originalCTimer

        before_each(function()
            local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
            QuestiePlayer.Initialize = function() end
            local QuestieJourney = QuestieLoader:ImportModule("QuestieJourney")
            QuestieJourney.Initialize = function() end
            local QuestieValidateGameCache = QuestieLoader:ImportModule("QuestieValidateGameCache")
            QuestieValidateGameCache.IsCacheGood = function() return true end
            originalCTimer = _G.C_Timer
            _G.C_Timer = {After = function() end}
        end)

        after_each(function()
            _G.C_Timer = originalCTimer
        end)

        it("warms the provider Object name index when the Object ID tooltip setting is enabled", function()
            Questie.db.profile.enableTooltipsObjectID = true

            _RunStage(2)

            assert.are_same(1, mock.nameIndexBuilds.Object)
        end)

        it("leaves the provider Object name index cold when the setting is disabled", function()
            Questie.db.profile.enableTooltipsObjectID = false

            _RunStage(2)

            assert.are_same(0, mock.nameIndexBuilds.Object)
        end)
    end)
    describe("support validation failure lifecycle", function()
        local originalError, originalHook, originalAPI, originalStarted, originalSetIcons
        local threads, errors, watchFrame

        before_each(function()
            originalError, originalHook = Questie.Error, _G.hooksecurefunc
            originalAPI, originalStarted, originalSetIcons = Questie.API, Questie.started, Questie.SetIcons
            errors = spy.new(function() end)
            Questie.Error = errors
            threads = spy.new(function() end)
            QuestieLoader:ImportModule("ThreadLib").ThreadError = threads
            watchFrame = spy.new(function() end)
            QuestieLoader:ImportModule("WatchFrameHook").Hide = watchFrame
            _G.hooksecurefunc = spy.new(function() end)
            Questie.started = false
            Questie.API = {isReady = false}
            Questie.db.profile.trackerEnabled = true
            Questie.db.profile.debugEnabled = false
            Questie.IsSoD = false
            Questie.SetIcons = _Record("SetIcons")
            QuestieLoader:ImportModule("MinimapIcon").Init = _Record("MinimapIcon")
            QuestieLoader:ImportModule("Migration").Migrate = _Record("Migration")
            QuestieLoader:ImportModule("ZoneDB").Initialize = _Record("ZoneDB")
            QuestieLoader:ImportModule("AvailableQuests").Initialize = _Record("AvailableQuests")
            QuestieLoader:ImportModule("QuestieProfessions").Init = _Record("Professions")
            QuestieLoader:ImportModule("QuestXP").Init = _Record("QuestXP")
            QuestieLoader:ImportModule("Phasing").Initialize = _Record("Phasing")
        end)

        after_each(function()
            Questie.Error, _G.hooksecurefunc = originalError, originalHook
            Questie.API, Questie.started, Questie.SetIcons = originalAPI, originalStarted, originalSetIcons
        end)

        it("stops at ZoneDB, reports once and schedules neither deferred UI nor login work", function()
            local zones = spy.new(function() return false, "zone report" end)
            QuestieLoader:ImportModule("ZoneDB").Initialize = zones
            assert.is_false(QuestieInit.OnAddonLoaded())
            assert.is_false(QuestieInit.OnAddonLoaded())
            assert.is_false(QuestieInit:Init())
            assert.are_same({"MinimapIcon", "SetIcons", "Migration"}, callOrder)
            assert.spy(zones).was.called(1)
            assert.spy(errors).was.called_with("zone report")
            assert.spy(errors).was.called(1)
            assert.spy(threads).was.not_called()
            assert.spy(watchFrame).was.not_called()
            assert.spy(_G.hooksecurefunc).was.not_called()
            assert.is_false(Questie.started)
            assert.is_false(Questie.API.isReady)
        end)

        it("stops at raw XP before phasing or any deferred thread", function()
            QuestieLoader:ImportModule("QuestXP").Init = function() return false, "XP report" end
            assert.is_false(QuestieInit.OnAddonLoaded())
            assert.is_false(QuestieInit:Init())
            assert.are_same({"MinimapIcon", "SetIcons", "Migration", "ZoneDB", "AvailableQuests", "Professions"}, callOrder)
            assert.spy(errors).was.called_with("XP report")
            assert.spy(threads).was.not_called()
            assert.spy(watchFrame).was.not_called()
        end)

        it("preserves synchronous addon-load order and schedules the same deferred UI on success", function()
            QuestieInit.OnAddonLoaded()
            assert.are_same({"MinimapIcon", "SetIcons", "Migration", "ZoneDB", "AvailableQuests", "Professions",
                "QuestXP", "Phasing"}, callOrder)
            assert.spy(threads).was.called(1)
            assert.spy(errors).was.not_called()
        end)

        it("stops stage 1 before Townsfolk and later consumer initialization", function()
            QuestieLoader:ImportModule("QuestieDB").Initialize = function() return false, "faction report" end
            _RunStage(1)
            assert.are_same({"l10n.InitializeUILocale", "LibQuestieDB.l10n.SetLocale:deDE",
                "l10n.PublishLocaleOverrideEntityNames", "QuestieCorrections.Initialize"}, callOrder)
            assert.spy(errors).was.called_with("faction report")
            assert.is_false(QuestieInit:Init())
            assert.spy(threads).was.not_called()
            assert.is_false(Questie.started)
            assert.is_false(Questie.API.isReady)
        end)

        it("keeps DropDB in stage 3 and stops before timers, tracker and readiness", function()
            QuestieLoader:ImportModule("QuestieTooltips").Initialize = _Record("Tooltips")
            QuestieLoader:ImportModule("DropDB").Initialize = function()
                table.insert(callOrder, "DropDB")
                return false, "drop report"
            end
            local timers = spy.new(function() end)
            QuestieLoader:ImportModule("TrackerQuestTimers").Initialize = timers
            _RunStage(3)
            assert.are_same({"Tooltips", "DropDB"}, callOrder)
            assert.spy(timers).was.not_called()
            assert.spy(errors).was.called_with("drop report")
            assert.is_false(Questie.started)
            assert.is_false(Questie.API.isReady)
        end)

        it("ends the stage coroutine normally on false instead of running the next stage", function()
            QuestieInit.Stages = {
                function() coroutine.yield(); return false end,
                _Record("must not run"),
            }
            local thread = coroutine.create(QuestieInit.private.StartStageCoroutine)
            assert.is_true(coroutine.resume(thread))
            local ok, result = coroutine.resume(thread)
            assert.is_true(ok)
            assert.is_false(result)
            assert.are_equal("dead", coroutine.status(thread))
            assert.are_same({}, callOrder)
        end)

        it("continues stages in their original order for nil and true success results", function()
            QuestieInit.Stages = {_Record("one"), function() table.insert(callOrder, "two"); return true end,
                _Record("three")}
            local thread = coroutine.create(QuestieInit.private.StartStageCoroutine)
            repeat
                assert.is_true(coroutine.resume(thread))
            until coroutine.status(thread) == "dead"
            assert.are_same({"one", "two", "three"}, callOrder)
            assert.spy(errors).was.not_called()
        end)
    end)

end)
