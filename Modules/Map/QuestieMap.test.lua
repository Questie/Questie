dofile("setupTests.lua")
local stub = require("luassert.stub")

describe("QuestieMap", function()

    ---@type QuestieMap
    local QuestieMap
    ---@type QuestieFramePool
    local QuestieFramePool

    before_each(function()
        QuestieFramePool = QuestieLoader:ImportModule("QuestieFramePool")
        QuestieFramePool.UnloadFrame = spy.new(function() end)
        dofile("Modules/Map/QuestieMap.lua")
        QuestieMap = QuestieLoader:ImportModule("QuestieMap")
        QuestieMap.questIdFrames = {}
    end)

    describe("DrawWorldIcon", function()
        local originalCMap
        local warning
        local getUiMapId
        local getParentZoneId
        local isSpawnVisible

        before_each(function()
            originalCMap = _G.C_Map
            _G.C_Map = {GetMapInfo = function() return nil end}
            ---@type ZoneDB
            local ZoneDB = QuestieLoader:ImportModule("ZoneDB")
            ---@type Phasing
            local Phasing = QuestieLoader:ImportModule("Phasing")
            warning = stub(Questie, "Warning")
            getUiMapId = stub(ZoneDB, "GetUiMapIdByAreaId", function() return nil end)
            getParentZoneId = stub(ZoneDB, "GetParentZoneId", function() return nil end)
            isSpawnVisible = stub(Phasing, "IsSpawnVisible", function() return true end)
        end)

        after_each(function()
            _G.C_Map = originalCMap
            warning:revert()
            getUiMapId:revert()
            getParentZoneId:revert()
            isSpawnVisible:revert()
        end)

        it("should warn and skip the icon when no map or parent area exists", function()
            local worldIcon, minimapIcon = QuestieMap:DrawWorldIcon({Name = "Missing location"}, 123, 50, 50)

            assert.is_nil(worldIcon)
            assert.is_nil(minimapIcon)
            assert.spy(Questie.Warning).was.called_with("No UiMapID or fitting parentAreaId for areaId : 123 - Missing location")
        end)
    end)

    describe("UnloadQuestFrames", function()
        it("should clear AlreadySpawned for objective frames on full unload", function()
            local objective = {AlreadySpawned = {[123] = {}}}
            _G.QuestieFrame1 = {data = {ObjectiveData = objective}}
            _G.QuestieFrame2 = {data = {ObjectiveData = objective}}
            QuestieMap.questIdFrames[1] = {
                QuestieFrame1 = "QuestieFrame1",
                QuestieFrame2 = "QuestieFrame2",
            }

            local thread = coroutine.create(function()
                QuestieMap:UnloadQuestFrames(1)
            end)
            coroutine.resume(thread)

            assert.are_same({}, objective.AlreadySpawned)
            assert.is_nil(QuestieMap.questIdFrames[1])
            assert.spy(QuestieFramePool.UnloadFrame).was.called_with(QuestieFramePool, _G.QuestieFrame1)
            assert.spy(QuestieFramePool.UnloadFrame).was.called_with(QuestieFramePool, _G.QuestieFrame2)

            _G.QuestieFrame1 = nil
            _G.QuestieFrame2 = nil
        end)

        it("should not throw an error when called from a coroutine", function()
            QuestieMap.questIdFrames[1] = {QuestieFrame1 = "QuestieFrame1"}

            local co = coroutine.create(function()
                QuestieMap:UnloadQuestFrames(1)
            end)

            assert.is_true(coroutine.resume(co))
        end)

        it("should throw an error when not called from a coroutine", function()
            assert.has_error(function()
                QuestieMap:UnloadQuestFrames(1)
            end, "UnloadQuestFrames must be called from a coroutine")
        end)
    end)

end)
