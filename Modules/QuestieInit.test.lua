dofile("setupTests.lua")

local LoadQuestieDBMock = dofile("test/QuestieDBMock.lua")

describe("QuestieInit", function()
    ---@type QuestieInit
    local QuestieInit
    ---@type QuestieDBMock
    local mock

    ---@type string[]
    local callOrder
    local originalGetMetadata, originalGetBuildInfo
    local QuestieStatus
    local originalStarted, originalReady, originalProvider, originalProfile, originalIsSoD

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
        originalStarted, originalReady = Questie.started, Questie.API.isReady
        originalProvider, originalProfile, originalIsSoD = LibQuestieDB, Questie.db.profile, Questie.IsSoD
        Questie.db.profile = {}
        dofile("Modules/Status/QuestieStatus.lua")
        QuestieStatus = QuestieLoader:ImportModule("QuestieStatus")
        originalGetMetadata = C_AddOns.GetAddOnMetadata
        originalGetBuildInfo = _G.GetBuildInfo
        C_AddOns.GetAddOnMetadata = function(addon, field)
            if addon == "Questie" and field == "X-QuestieDB-Contract" then return "3" end
            if addon == "QuestieDB" and field == "Version" then return "1.1.1" end
        end
        dofile("Modules/VersionCheckDB.lua")
        mock = LoadQuestieDBMock()
        callOrder = {}
        Questie.db.profile.enableTooltipsObjectID = false

        dofile("Localization/l10n.lua")
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

        dofile("Modules/Status/SourceModeStatus.lua")
        dofile("Modules/QuestieInit.lua")
        QuestieInit = QuestieLoader:ImportModule("QuestieInit")
    end)

    after_each(function()
        C_AddOns.GetAddOnMetadata = originalGetMetadata
        _G.GetBuildInfo = originalGetBuildInfo
        Questie.started, Questie.API.isReady = originalStarted, originalReady
        _G.LibQuestieDB, Questie.db.profile, Questie.IsSoD = originalProvider, originalProfile, originalIsSoD
    end)

    local function _AssertFatalIssue(id, report)
        assert.are_same({{
            id = id,
            severity = QuestieStatus.Severity.Error,
            message = "Questie could not start: %s",
            args = {report},
            action = "Update Questie and QuestieDB, then reload the UI.",
        }}, QuestieStatus.GetIssues())
        assert.is_false(Questie.started)
        assert.is_false(Questie.API.isReady)
    end

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
            }, callOrder)
        end)

        it("forwards the effective locale to the provider exactly once", function()
            _RunStage(1)

            assert.are_same({"deDE"}, mock.setLocaleCalls)
        end)

        it("uses the TOC requirement instead of a hardcoded contract", function()
            C_AddOns.GetAddOnMetadata = function(addon, field)
                if addon == "Questie" and field == "X-QuestieDB-Contract" then return "4" end
                if addon == "QuestieDB" and field == "Version" then return "1.1.1" end
            end

            assert.has_error(function() _RunStage(1) end,
                "Questie requires QuestieDB contract 4; installed QuestieDB version: 1.1.1. " ..
                "QuestieDB contract mismatch: this consumer needs version 4, the installed QuestieDB provides 3 " ..
                "(supporting consumers back to 1). Update whichever is older.")
            assert.are_same({}, mock.setLocaleCalls)
        end)

        it("stops before provider work when the TOC requirement is missing", function()
            C_AddOns.GetAddOnMetadata = function() return nil end

            assert.has_error(function() _RunStage(1) end,
                "Questie's TOC has a missing or invalid X-QuestieDB-Contract. Reinstall Questie.")
            assert.are_same({"l10n.InitializeUILocale"}, callOrder)
            _AssertFatalIssue("startup.provider-contract",
                "Questie's TOC has a missing or invalid X-QuestieDB-Contract. Reinstall Questie.")
        end)

        it("stops with an actionable error when the provider contract API is unavailable", function()
            mock.lib.RequireContract = nil

            assert.has_error(function() _RunStage(1) end,
                "Questie requires QuestieDB contract 3; installed QuestieDB version: 1.1.1. " ..
                "The provider contract API is unavailable. Install or update QuestieDB and reload.")
            assert.are_same({"l10n.InitializeUILocale"}, callOrder)
        end)

        it("rejects a provider without race-ID mappings before forwarding or publishing corrections", function()
            mock.lib.Enum.raceMaskById = nil

            assert.has_error(function() _RunStage(1) end,
                "Questie requires QuestieDB contract 3; installed QuestieDB version: 1.1.1. " ..
                "The provider race-ID mapping is unavailable. Update QuestieDB and reload.")
            assert.are_same({"l10n.InitializeUILocale"}, callOrder)
            assert.are_same({}, mock.setLocaleCalls)
        end)

        it("rejects missing faction masks before forwarding or publishing corrections", function()
            mock.lib.Enum.factionRaceMasks = nil

            assert.has_error(function() _RunStage(1) end,
                "Questie requires QuestieDB contract 3; installed QuestieDB version: 1.1.1. " ..
                "The provider faction race masks are unavailable. Update QuestieDB and reload.")
            assert.are_same({"l10n.InitializeUILocale"}, callOrder)
            assert.are_same({}, mock.setLocaleCalls)
        end)

        it("rejects an incomplete faction mask table before forwarding or publishing corrections", function()
            mock.lib.Enum.factionRaceMasks.Horde = nil

            assert.has_error(function() _RunStage(1) end,
                "Questie requires QuestieDB contract 3; installed QuestieDB version: 1.1.1. " ..
                "The provider faction race masks are unavailable. Update QuestieDB and reload.")
            assert.are_same({"l10n.InitializeUILocale"}, callOrder)
            assert.are_same({}, mock.setLocaleCalls)
        end)

        it("rejects a malformed provider missing translation slots before forwarding", function()
            mock.lib.l10n.SetCorrection = nil
            Questie.started, Questie.API.isReady = true, true
            assert.has_error(function() _RunStage(1) end,
                "Questie requires QuestieDB localization corrections. Update QuestieDB.")
            _AssertFatalIssue("startup.provider-localization",
                "Questie requires QuestieDB localization corrections. Update QuestieDB.")
            assert.are_same({"l10n.InitializeUILocale"}, callOrder)
            assert.are_same({}, mock.setLocaleCalls)
        end)

        it("rejects a contract-2 provider before forwarding the locale or touching Corrections", function()
            mock.minSupportedContract = 1
            mock.contractVersion = 2

            assert.has_error(function()
                _RunStage(1)
            end, "Questie requires QuestieDB contract 3; installed QuestieDB version: 1.1.1. " ..
                "QuestieDB contract mismatch: this consumer needs version 3, the installed QuestieDB provides 2 " ..
                "(supporting consumers back to 1). Update whichever is older.")
            assert.are_same({"l10n.InitializeUILocale"}, callOrder)
        end)
    end)

    describe("Stage 2", function()
        local originalCTimer, originalIsHardcore

        before_each(function()
            originalIsHardcore = Questie.IsHardcore
            Questie.IsHardcore = false
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
            Questie.IsHardcore = originalIsHardcore
        end)

        it("uses 1000-ID batches outside Hardcore and waits for the index before initializing the player", function()
            QuestieLoader:ImportModule("QuestiePlayer").Initialize = _Record("QuestiePlayer.Initialize")
            ---@async
            ---@param iterationsPerCycle integer?
            ---@return nil
            mock.lib.Object.BuildNameIndexAsync = function(iterationsPerCycle)
                assert.are_equal(1000, iterationsPerCycle)
                table.insert(callOrder, "index started")
                coroutine.yield()
                table.insert(callOrder, "index resumed")
                coroutine.yield()
                table.insert(callOrder, "index complete")
            end

            local stage = coroutine.create(QuestieInit.Stages[2])
            assert.is_true(coroutine.resume(stage))
            assert.are_equal("suspended", coroutine.status(stage))
            assert.are_same({"index started"}, callOrder)

            assert.is_true(coroutine.resume(stage))
            assert.are_equal("suspended", coroutine.status(stage))
            assert.are_same({"index started", "index resumed"}, callOrder)

            assert.is_true(coroutine.resume(stage))
            assert.are_same({"index started", "index resumed", "index complete", "QuestiePlayer.Initialize"}, callOrder)
            assert.is_true(coroutine.resume(stage))
            assert.are_equal("dead", coroutine.status(stage))
        end)

        it("uses 250-ID batches on Hardcore without calling the synchronous builder", function()
            Questie.IsHardcore = true
            local asyncBuild = spy.new(function() end)
            ---@param iterationsPerCycle integer?
            ---@return nil
            mock.lib.Object.BuildNameIndexAsync = function(iterationsPerCycle)
                asyncBuild(iterationsPerCycle)
            end
            mock.lib.Object.BuildNameIndex = spy.new(function() end)

            _RunStage(2)

            assert.spy(asyncBuild).was.called_with(250)
            assert.spy(asyncBuild).was.called(1)
            assert.spy(mock.lib.Object.BuildNameIndex).was.not_called()
        end)

        for _, isHardcore in ipairs({false, true}) do
            it("requires asynchronous indexing on " .. (isHardcore and "Hardcore" or "other clients"), function()
                Questie.IsHardcore = isHardcore
                mock.lib.Object.BuildNameIndexAsync = nil
                mock.lib.Object.BuildNameIndex = spy.new(_Record("index complete"))
                QuestieLoader:ImportModule("QuestiePlayer").Initialize = _Record("QuestiePlayer.Initialize")

                assert.has_error(function() _RunStage(2) end,
                    "Questie requires QuestieDB asynchronous Object name indexing. Update QuestieDB.")
                _AssertFatalIssue("startup.provider-object-index",
                    "Questie requires QuestieDB asynchronous Object name indexing. Update QuestieDB.")
                assert.spy(mock.lib.Object.BuildNameIndex).was.not_called()
                assert.are_same({}, callOrder)
            end)
        end

        it("reports the required API when the Object provider is unavailable", function()
            mock.lib.Object = nil
            QuestieLoader:ImportModule("QuestiePlayer").Initialize = _Record("QuestiePlayer.Initialize")

            assert.has_error(function() _RunStage(2) end,
                "Questie requires QuestieDB asynchronous Object name indexing. Update QuestieDB.")
            assert.are_same({}, callOrder)
        end)

        it("warms the provider Object name index when the Object ID tooltip setting is enabled", function()
            Questie.db.profile.enableTooltipsObjectID = true

            _RunStage(2)

            assert.are_same(1, mock.nameIndexBuilds.Object)
        end)

        it("warms the provider Object name index for zone filtering even when Object IDs are hidden", function()
            Questie.db.profile.enableTooltipsObjectID = false

            _RunStage(2)

            assert.are_same(1, mock.nameIndexBuilds.Object)
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
            QuestieLoader:ImportModule("ThreadLib").Thread = threads
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

        it("hands the source banner over only after status UI registration", function()
            mock.lib.readMode = "source"
            mock.lib.ModeIndicator = {Hide = _Record("Hide banner")}
            QuestieLoader:ImportModule("MinimapIcon").Init = function()
                assert.are_same({}, callOrder)
                local issues = QuestieStatus.GetIssues()
                assert.are_same(2, #issues)
                assert.are_same("questiedb.source-mode", issues[1].id)
                assert.are_same("questiedb.source-load", issues[2].id)
                assert.are_same("Client: %s (build %s, %s)", issues[1].details[1].message)
                assert.are_same("Interface\\AddOns\\Questie\\Icons\\green_plus.png", QuestieStatus.GetBadgeIssue().icon.texture)
                table.insert(callOrder, "UI registered")
                return true
            end
            QuestieInit.OnAddonLoaded()
            assert.are_equal("UI registered", callOrder[1])
            assert.are_equal("Hide banner", callOrder[2])
        end)

        it("keeps the source banner when the status UI is unavailable", function()
            mock.lib.readMode = "source"
            mock.lib.ModeIndicator = {Hide = spy.new(function() end)}
            QuestieLoader:ImportModule("MinimapIcon").Init = function() return false end
            QuestieInit.OnAddonLoaded()
            assert.spy(mock.lib.ModeIndicator.Hide).was.not_called()
            assert.are_equal("questiedb.source-mode", QuestieStatus.GetBadgeIssue().id)
        end)

        it("accepts a source provider without the optional Hide API", function()
            mock.lib.readMode = "source"
            mock.lib.ModeIndicator = {}
            QuestieLoader:ImportModule("MinimapIcon").Init = function() return true end
            QuestieInit.OnAddonLoaded()
            assert.are_equal("questiedb.source-mode", QuestieStatus.GetBadgeIssue().id)
            assert.spy(threads).was.called(1)
        end)

        it("creates the status UI and continues startup when client diagnostics fail", function()
            mock.lib.readMode = "source"
            _G.GetBuildInfo = function() error("client API failed", 0) end

            QuestieInit.OnAddonLoaded()

            assert.are_same("MinimapIcon", callOrder[1])
            assert.spy(threads).was.called(1)
            assert.are_same({{message = "Client diagnostics unavailable: %s", args = {"client API failed"}}},
                QuestieStatus.GetIssues()[1].details)
        end)

        it("clears the source notice without hiding the banner in Baked mode", function()
            mock.lib.readMode = "source"
            QuestieInit.OnAddonLoaded()
            mock.lib.readMode = "baked"
            mock.lib.ModeIndicator = {Hide = spy.new(function() end)}
            QuestieLoader:ImportModule("MinimapIcon").Init = function() return true end
            QuestieInit.OnAddonLoaded()
            assert.are_same({}, QuestieStatus.GetIssues())
            assert.spy(mock.lib.ModeIndicator.Hide).was.not_called()
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
            _AssertFatalIssue("startup.support-validation", "zone report")
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
            _AssertFatalIssue("startup.support-validation", "XP report")
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
            _AssertFatalIssue("startup.support-validation", "faction report")
            assert.is_false(QuestieInit:Init())
            assert.spy(threads).was.not_called()
            assert.is_false(Questie.started)
            assert.is_false(Questie.API.isReady)
        end)

        it("keeps DropDB in stage 3 and stops before timers, tracker and readiness", function()
            QuestieLoader:ImportModule("QuestieTooltips").Initialize = _Record("Tooltips")
            QuestieLoader:ImportModule("QuestieLink").Initialize = _Record("QuestieLink")
            QuestieLoader:ImportModule("DropDB").Initialize = function()
                table.insert(callOrder, "DropDB")
                return false, "drop report"
            end
            local timers = spy.new(function() end)
            QuestieLoader:ImportModule("TrackerQuestTimers").Initialize = timers
            _RunStage(3)
            assert.are_same({"Tooltips", "QuestieLink", "DropDB"}, callOrder)
            assert.spy(timers).was.not_called()
            assert.spy(errors).was.called_with("drop report")
            _AssertFatalIssue("startup.support-validation", "drop report")
            assert.is_false(Questie.started)
            assert.is_false(Questie.API.isReady)
        end)

        describe("real startup thread failures", function()
            local originalCTimer, originalDebugstack, originalThread
            local tickers

            local function _TickUntilDrawing()
                for _ = 1, 40 do
                    if Questie.started then return end
                    assert.is_false(tickers[2].cancelled)
                    tickers[2].callback()
                end
                error("Login did not reach available-quest drawing")
            end

            before_each(function()
                originalCTimer, originalDebugstack = _G.C_Timer, _G.debugstack
                originalThread = QuestieLoader:ImportModule("ThreadLib").Thread
                tickers = {}
                _G.C_Timer = {
                    After = function() end,
                    NewTicker = function(_, callback)
                        local ticker = {callback = callback, cancelled = false}
                        function ticker:Cancel() self.cancelled = true end
                        table.insert(tickers, ticker)
                        return ticker
                    end,
                }
                _G.debugstack = function() return "startup stack" end
                dofile("Modules/Libs/ThreadLib.lua")
                Questie.db.profile.trackerEnabled = false
                Questie.IsSoD = true
                QuestieLoader:ImportModule("SeasonOfDiscovery").Initialize = function() end

                -- Keep the real final stage and scheduler; stub unrelated consumers, not readiness transitions.
                QuestieInit.Stages = {QuestieInit.Stages[3]}
                local consumers = {
                    QuestieTooltips = "Initialize", QuestieLink = "Initialize", DropDB = "Initialize",
                    TrackerQuestTimers = "Initialize", ChallengeModeTimer = "Initialize", QuestieMap = "InitializeQueue",
                    QuestieCombatQueue = "Initialize", QuestieTracker = "Initialize", Hooks = "HookQuestLogTitle",
                    BreadcrumbQuests = "CheckAllQuestBreadcrumbs", CommsEncoding = "Init", CommsVisibility = "Initialize",
                    QuestieComms = "Initialize", WorldMapButton = "Initialize", Townsfolk = "PostBoot",
                    QuestieAnnounce = "InitializeLogoFilter", ChatFilter = "RegisterEvents", QuestieMenu = "OnLogin",
                    DailyQuests = "Initialize", QuestieLib = "UpdateLastKnownDailyReset",
                }
                for module, method in pairs(consumers) do
                    QuestieLoader:ImportModule(module)[method] = function() end
                end
                local quests = QuestieLoader:ImportModule("QuestieQuest")
                quests.Initialize, quests.GetAllQuestIds = function() end, function() end
                local events = QuestieLoader:ImportModule("QuestEventHandler")
                events.Initialize, events.InitQuestLogStates = function() end, function() end
                QuestieLoader:ImportModule("EventHandler").RegisterLateEvents = function() end
                local dailies = QuestieLoader:ImportModule("DailyQuestComms")
                dailies.Initialize, dailies.RequestUnavailableDailyQuests = function() end, function() end
                QuestieLoader:ImportModule("QuestLogCache").CheckForChanges = function() return false, nil, {} end
                QuestieLoader:ImportModule("QuestieAPI").PropagateOnReady = spy.new(function() end)
            end)

            after_each(function()
                _G.C_Timer, _G.debugstack = originalCTimer, originalDebugstack
                QuestieLoader:ImportModule("ThreadLib").Thread = originalThread
            end)

            it("keeps a nil Lua error renderable in the status tooltip", function()
                QuestieLoader:ImportModule("HBDHooks").Init = function() error(nil, 0) end
                QuestieInit.OnAddonLoaded()

                tickers[1].callback()

                local issue = QuestieStatus.GetBadgeIssue()
                dofile("Localization/l10n.lua")
                local l10n = QuestieLoader:ImportModule("l10n")
                assert.are_same("Questie could not start: nil", l10n(issue.message, unpack(issue.args)))
                assert.is_false(Questie.started)
                assert.is_true(tickers[1].cancelled)
            end)

            it("captures a non-string Lua error as stable tooltip text", function()
                local report = setmetatable({message = "structured error"}, {
                    __tostring = function(value) return value.message end,
                })
                QuestieLoader:ImportModule("HBDHooks").Init = function() error(report, 0) end
                QuestieInit.OnAddonLoaded()

                tickers[1].callback()
                report.message = "later mutation"

                local issue = QuestieStatus.GetBadgeIssue()
                dofile("Localization/l10n.lua")
                local l10n = QuestieLoader:ImportModule("l10n")
                assert.are_same("Questie could not start: structured error", l10n(issue.message, unpack(issue.args)))
            end)

            it("revokes already-announced readiness when deferred UI fails afterwards", function()
                QuestieLoader:ImportModule("HBDHooks").Init = function()
                    coroutine.yield()
                    error("deferred UI failed after login", 0)
                end
                QuestieLoader:ImportModule("AvailableQuests").CalculateAndDrawAll = function() end
                QuestieInit.OnAddonLoaded()
                QuestieInit:Init()
                tickers[1].callback()
                _TickUntilDrawing()
                assert.is_true(Questie.started)
                assert.is_true(Questie.API.isReady)
                assert.spy(QuestieLoader:ImportModule("QuestieAPI").PropagateOnReady).was.called(1)

                tickers[1].callback()

                assert.is_false(Questie.started)
                assert.is_false(Questie.API.isReady)
                assert.is_true(tickers[2].cancelled)
                assert.are_same("startup.addon-loaded", QuestieStatus.GetBadgeIssue().id)
                assert.is_false(QuestieInit:Init())
                assert.spy(QuestieLoader:ImportModule("QuestieAPI").PropagateOnReady).was.called(1)
            end)

            it("revokes late login readiness when the yielding addon-loaded job fails and cancels login", function()
                QuestieLoader:ImportModule("HBDHooks").Init = function()
                    coroutine.yield()
                    error("deferred UI failed", 0)
                end
                local drawingFinished = spy.new(function() end)
                QuestieLoader:ImportModule("AvailableQuests").CalculateAndDrawAll = function()
                    coroutine.yield()
                    drawingFinished()
                end
                QuestieInit.OnAddonLoaded()
                QuestieInit:Init()
                tickers[1].callback()
                _TickUntilDrawing()
                assert.is_true(Questie.started)
                assert.is_false(Questie.API.isReady)

                tickers[1].callback()

                assert.are_same({{
                    id = "startup.addon-loaded", severity = QuestieStatus.Severity.Error,
                    message = "Questie could not start: %s", args = {"deferred UI failed"},
                    action = "Reload the UI. If the problem persists, report this error.",
                }}, QuestieStatus.GetIssues())
                assert.is_false(Questie.started)
                assert.is_false(Questie.API.isReady)
                assert.is_true(tickers[1].cancelled)
                assert.is_true(tickers[2].cancelled)
                assert.spy(drawingFinished).was.not_called()
                assert.spy(QuestieLoader:ImportModule("QuestieAPI").PropagateOnReady).was.not_called()
                assert.spy(errors).was.called(1)
                assert.is_false(QuestieInit:Init())
                assert.is_false(QuestieInit.OnAddonLoaded())
            end)

            it("revokes started on a yielding late login failure and cancels deferred UI", function()
                local uiFinished = spy.new(function() end)
                QuestieLoader:ImportModule("HBDHooks").Init = function()
                    coroutine.yield()
                    uiFinished()
                end
                QuestieLoader:ImportModule("AvailableQuests").CalculateAndDrawAll = function()
                    coroutine.yield()
                    error("available quests failed", 0)
                end
                QuestieInit.OnAddonLoaded()
                QuestieInit:Init()
                tickers[1].callback()
                _TickUntilDrawing()
                assert.is_true(Questie.started)
                tickers[2].callback()

                assert.are_same({{
                    id = "startup.login", severity = QuestieStatus.Severity.Error,
                    message = "Questie could not start: %s", args = {"available quests failed"},
                    action = "Reload the UI. If the problem persists, report this error.",
                }}, QuestieStatus.GetIssues())
                assert.is_false(Questie.started)
                assert.is_false(Questie.API.isReady)
                assert.is_true(tickers[1].cancelled)
                assert.is_true(tickers[2].cancelled)
                assert.spy(uiFinished).was.not_called()
                assert.spy(QuestieLoader:ImportModule("QuestieAPI").PropagateOnReady).was.not_called()
                assert.spy(errors).was.called(1)
            end)

            it("retains the classified provider error without adding a generic login error", function()
                dofile("Modules/QuestieInit.lua")
                QuestieInit = QuestieLoader:ImportModule("QuestieInit")
                C_AddOns.GetAddOnMetadata = function() return nil end
                QuestieInit:Init()
                tickers[1].callback()
                _AssertFatalIssue("startup.provider-contract",
                    "Questie's TOC has a missing or invalid X-QuestieDB-Contract. Reinstall Questie.")
                assert.spy(errors).was.called(1)
                assert.is_true(tickers[1].cancelled)
            end)
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
