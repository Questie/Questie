dofile("setupTests.lua")

local LoadQuestieTDBMock = dofile("test/QuestieTDBMock.lua")

describe("QuestieInit", function()
    ---@type QuestieInit
    local QuestieInit
    ---@type QuestieTDBMock
    local mock

    ---@type string[]
    local callOrder
    local externalRowsBuilt
    local externalRowsReceived

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
        externalRowsBuilt = nil
        externalRowsReceived = nil
        Questie.db.profile.enableTooltipsObjectID = false

        local l10n = QuestieLoader:ImportModule("l10n")
        l10n.InitializeUILocale = _Record("l10n.InitializeUILocale")
        l10n.GetUILocale = function() return "deDE" end

        local EntityLocale = QuestieLoader:ImportModule("EntityLocale")
        EntityLocale.ForwardProviderLocale = function(locale)
            table.insert(callOrder, "EntityLocale.ForwardProviderLocale:" .. locale)
        end
        EntityLocale.BuildExternalLocaleCorrections = function(locale)
            table.insert(callOrder, "EntityLocale.BuildExternalLocaleCorrections:" .. locale)
            externalRowsBuilt = {Item = {}, Quest = {}, Npc = {}, Object = {}}
            return externalRowsBuilt
        end

        local QuestieCorrections = QuestieLoader:ImportModule("QuestieCorrections")
        QuestieCorrections.Initialize = _Record("QuestieCorrections.Initialize")
        QuestieCorrections.InitializePolicyCorrections = function(externalLocaleCorrections)
            table.insert(callOrder, "QuestieCorrections.InitializePolicyCorrections")
            externalRowsReceived = externalLocaleCorrections
        end

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
                "EntityLocale.ForwardProviderLocale:deDE",
                "EntityLocale.BuildExternalLocaleCorrections:deDE",
                "QuestieCorrections.Initialize",
                "QuestieCorrections.InitializePolicyCorrections",
                "QuestieDB.Initialize",
                "Townsfolk.Initialize",
                "Townsfolk:BuildCharacterTownsfolk",
                "QuestieEvent.Initialize",
                "Tutorial.Initialize",
            }, callOrder)
        end)

        it("hands the external locale rows built before the initial apply to the registrar", function()
            _RunStage(1)

            assert.is_not_nil(externalRowsBuilt)
            assert.are_equal(externalRowsBuilt, externalRowsReceived)
        end)

        it("stops with the Contract error before forwarding the locale or touching Corrections", function()
            mock.minSupportedContract = 2
            mock.contractVersion = 2

            assert.has_error(function()
                _RunStage(1)
            end, "QuestieTDB contract mismatch: this consumer needs version 1, the installed QuestieTDB provides 2 " ..
                "(supporting consumers back to 2). Update whichever is older.")
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
end)
