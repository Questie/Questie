dofile("setupTests.lua")

local LoadQuestieDBMock = dofile("test/QuestieDBMock.lua")

describe("JourneyData", function()
    local JourneyData, ZoneDB, quests
    local originalQuestie, originalLibQuestieDB

    before_each(function()
        originalQuestie = _G.Questie
        originalLibQuestieDB = _G.LibQuestieDB
        _G.Questie = {db = {profile = {}}}

        -- Supply a small provider dataset, but use ZoneDB's real decoding and parent-zone lookup.
        local mock = LoadQuestieDBMock()
        mock.supportModules.ZoneDB.zoneIDs = {TELDRASSIL = 141}
        mock.supportModules.ZoneDB.private.subZoneToParentZone = "return {[6450] = 141}"
        dofile("Database/SupportValidation.lua")
        -- Full-world support-data probes are outside this grouping test's scope.
        QuestieLoader:ImportModule("SupportValidation").ValidateZones = function() return true end
        dofile("Database/Constants.lua")
        dofile("Localization/l10n.lua")
        local l10n = QuestieLoader:ImportModule("l10n")
        l10n.zoneCategoryLookup = {
            [1] = {[12] = "Elwynn Forest"},
            [2] = {[141] = "Teldrassil", [-676] = "Night Elf"},
        }

        quests = {
            [100] = {zoneOrSort = -676},
            [101] = {zoneOrSort = 141},
            [102] = {zoneOrSort = 6450}, -- Shadowglen already groups under Teldrassil.
            [103] = {zoneOrSort = -676}, -- Hidden quests must not reappear through redirects.
            [104] = {zoneOrSort = 12},
        }
        local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
        QuestieDB.QuestPointers = quests
        QuestieDB.QueryQuestSingle = function(questId, field) return quests[questId][field] end
        QuestieLoader:ImportModule("QuestieCorrections").hiddenQuests = {[103] = 2}
        QuestieLoader:ImportModule("QuestieQuestBlacklist").HIDE_ON_MAP = 1
        QuestieLoader:ImportModule("QuestieEvent").IsEventQuest = function() return false end
        local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
        QuestiePlayer.HasRequiredRace = function() return true end
        QuestiePlayer.HasRequiredClass = function() return true end

        dofile("Database/Zones/zoneDB.lua")
        ZoneDB = QuestieLoader:ImportModule("ZoneDB")
        local valid, report = ZoneDB.Initialize()
        assert.is_not_false(valid, report)
        -- Observe calls without replacing the implementations under test.
        spy.on(ZoneDB, "GetZonesWithQuests")
        spy.on(ZoneDB, "GetRelevantZones")
        dofile("Modules/Journey/JourneyData.lua")
        JourneyData = QuestieLoader:ImportModule("JourneyData")
    end)

    after_each(function()
        ZoneDB.GetZonesWithQuests:revert()
        ZoneDB.GetRelevantZones:revert()
        _G.Questie = originalQuestie
        _G.LibQuestieDB = originalLibQuestieDB
    end)

    it("merges Night Elf quests with zone and subzone quests and derives matching dropdowns from one map", function()
        local zoneMap, zones = JourneyData.Build(false)

        assert.are_same({
            [141] = {[100] = true, [101] = true, [102] = true},
            [12] = {[104] = true},
        }, zoneMap)
        assert.are_same({[1] = {[12] = "Elwynn Forest"}, [2] = {[141] = "Teldrassil"}}, zones)
        assert.are_equal(-676, quests[100].zoneOrSort)
        assert.spy(ZoneDB.GetZonesWithQuests).was.called(1)
        assert.spy(ZoneDB.GetRelevantZones).was.called(1)
        assert.spy(ZoneDB.GetRelevantZones).was.called_with(zoneMap)
    end)

    it("preserves existing zone groups when no eligible Night Elf quests exist", function()
        quests[100] = nil

        local zoneMap, zones = JourneyData.Build(false)

        assert.are_same({[141] = {[101] = true, [102] = true}, [12] = {[104] = true}}, zoneMap)
        assert.are_same({[1] = {[12] = "Elwynn Forest"}, [2] = {[141] = "Teldrassil"}}, zones)
    end)

    it("yields during real zone generation and derives dropdowns only after the completed redirects", function()
        local thread = coroutine.create(function() return JourneyData.Build(true) end)

        local success, zoneMap, zones = coroutine.resume(thread)
        assert.is_true(success, zoneMap)
        assert.are_equal("suspended", coroutine.status(thread))
        assert.spy(ZoneDB.GetRelevantZones).was.not_called()
        while coroutine.status(thread) ~= "dead" do
            success, zoneMap, zones = coroutine.resume(thread)
            assert.is_true(success, zoneMap)
        end

        assert.are_same({
            [141] = {[100] = true, [101] = true, [102] = true},
            [12] = {[104] = true},
        }, zoneMap)
        assert.are_same({[1] = {[12] = "Elwynn Forest"}, [2] = {[141] = "Teldrassil"}}, zones)
        assert.spy(ZoneDB.GetZonesWithQuests).was.called(1)
        assert.spy(ZoneDB.GetRelevantZones).was.called(1)
        assert.spy(ZoneDB.GetRelevantZones).was.called_with(zoneMap)
    end)
end)
