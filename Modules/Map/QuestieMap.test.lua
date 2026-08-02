dofile("setupTests.lua")

describe("QuestieMap", function()

    ---@type QuestieMap
    local QuestieMap
    ---@type QuestieLib
    local QuestieLib
    ---@type QuestieFramePool
    local QuestieFramePool

    local match = require("luassert.match")
    local _ = match._ -- any match

    before_each(function()
        QuestieLib = QuestieLoader:ImportModule("QuestieLib")
        QuestieFramePool = QuestieLoader:ImportModule("QuestieFramePool")
        QuestieFramePool.UnloadFrame = spy.new(function() end)
        dofile("Modules/Map/QuestieMap.lua")
        QuestieMap = QuestieLoader:ImportModule("QuestieMap")
        QuestieMap.questIdFrames = {}
    end)

    describe("UnloadAllQuestFrames", function()
        it("should unload all frames for a quest", function()
            local objective = {AlreadySpawned = {[123] = {}}}
            _G.QuestieFrame1 = {data = {ObjectiveData = objective}}
            _G.QuestieFrame2 = {data = {ObjectiveData = objective}}
            _G.QuestieFrame3 = {data = {Type = "available"}}
            QuestieMap.questIdFrames[1] = {
                QuestieFrame1 = "QuestieFrame1",
                QuestieFrame2 = "QuestieFrame2",
                QuestieFrame3 = "QuestieFrame3",
            }

            local thread = coroutine.create(function()
                QuestieMap:UnloadAllQuestFrames(1)
            end)
            coroutine.resume(thread)

            assert.are_same({}, objective.AlreadySpawned)
            assert.is_nil(QuestieMap.questIdFrames[1])
            -- Verify UnloadFrame was called 3 times (once per frame)
            assert.spy(QuestieFramePool.UnloadFrame).was.called(3)

            _G.QuestieFrame1 = nil
            _G.QuestieFrame2 = nil
            _G.QuestieFrame3 = nil
        end)

        it("should not throw an error when called from a coroutine", function()
            QuestieMap.questIdFrames[1] = {QuestieFrame1 = "QuestieFrame1"}

            local co = coroutine.create(function()
                QuestieMap:UnloadAllQuestFrames(1)
            end)

            assert.is_true(coroutine.resume(co))
        end)

        it("should throw an error when not called from a coroutine", function()
            assert.has_error(function()
                QuestieMap:UnloadAllQuestFrames(1)
            end, "UnloadAllQuestFrames must be called from a coroutine")
        end)
    end)

    describe("UnloadObjectiveFrames", function()
        it("should unload only objective frames", function()
            local objective = {AlreadySpawned = {[123] = {}}}
            _G.QuestieFrame1 = {data = {ObjectiveData = objective}}
            _G.QuestieFrame2 = {data = {ObjectiveData = objective}}
            _G.QuestieFrame3 = {data = {Type = "available"}}
            QuestieMap.questIdFrames[1] = {
                QuestieFrame1 = "QuestieFrame1",
                QuestieFrame2 = "QuestieFrame2",
                QuestieFrame3 = "QuestieFrame3",
            }

            local thread = coroutine.create(function()
                QuestieMap:UnloadObjectiveFrames(1)
            end)
            coroutine.resume(thread)

            assert.are_same({}, objective.AlreadySpawned)
            -- Quest entry should still exist since not all frames were unloaded
            assert.is_not_nil(QuestieMap.questIdFrames[1])
            assert.is_nil(QuestieMap.questIdFrames[1].QuestieFrame1)
            assert.is_nil(QuestieMap.questIdFrames[1].QuestieFrame2)
            assert.is_not_nil(QuestieMap.questIdFrames[1].QuestieFrame3)
            -- Verify UnloadFrame was called 2 times (for the objective frames)
            assert.spy(QuestieFramePool.UnloadFrame).was.called(2)

            _G.QuestieFrame1 = nil
            _G.QuestieFrame2 = nil
            _G.QuestieFrame3 = nil
        end)

        it("should throw an error when not called from a coroutine", function()
            assert.has_error(function()
                QuestieMap:UnloadObjectiveFrames(1)
            end, "UnloadObjectiveFrames must be called from a coroutine")
        end)
    end)

    describe("UnloadStarterOrFinisherFrames", function()
        it("should unload only starter/finisher frames", function()
            local objective = {AlreadySpawned = {[123] = {}}}
            _G.QuestieFrame1 = {data = {ObjectiveData = objective}}
            _G.QuestieFrame2 = {data = {ObjectiveData = objective}}
            _G.QuestieFrame3 = {data = {Type = "available"}}
            QuestieMap.questIdFrames[1] = {
                QuestieFrame1 = "QuestieFrame1",
                QuestieFrame2 = "QuestieFrame2",
                QuestieFrame3 = "QuestieFrame3",
            }

            local thread = coroutine.create(function()
                QuestieMap:UnloadStarterOrFinisherFrames(1)
            end)
            coroutine.resume(thread)

            -- Quest entry should still exist since not all frames were unloaded
            assert.is_not_nil(QuestieMap.questIdFrames[1])
            assert.is_not_nil(QuestieMap.questIdFrames[1].QuestieFrame1)
            assert.is_not_nil(QuestieMap.questIdFrames[1].QuestieFrame2)
            assert.is_nil(QuestieMap.questIdFrames[1].QuestieFrame3)
            -- Verify UnloadFrame was called 1 time (for the starter/finisher frame)
            assert.spy(QuestieFramePool.UnloadFrame).was.called(1)

            _G.QuestieFrame1 = nil
            _G.QuestieFrame2 = nil
            _G.QuestieFrame3 = nil
        end)

        it("should throw an error when not called from a coroutine", function()
            assert.has_error(function()
                QuestieMap:UnloadStarterOrFinisherFrames(1)
            end, "UnloadStarterOrFinisherFrames must be called from a coroutine")
        end)
    end)

    describe("UpdateDrawnIcons", function()
        it("should update icons for found frames", function()
            _G.Questie.usedIcons = {[123] = 11}
            local UpdateTextureMock = spy.new(function() end)
            QuestieMap.GetFramesForQuest = function()
                return {
                    QuestieFrame1 = {data={QuestData={Id=1}}, UpdateTexture = UpdateTextureMock},
                    QuestieFrame2 = {data={QuestData={Id=1}}, UpdateTexture = UpdateTextureMock}
                }
            end
            QuestieLib.GetQuestIcon = function()
                return 123
            end

            QuestieMap.UpdateDrawnIcons(1)

            assert.spy(UpdateTextureMock).was.called(2)
            assert.spy(UpdateTextureMock).was.called_with(_, 11)
        end)

        it("should do nothing when no frames are found", function()
            QuestieMap.GetFramesForQuest = function() return {} end
            QuestieLib.GetQuestIcon = spy.new(function() end)

            QuestieMap.UpdateDrawnIcons(1)

            assert.spy(QuestieLib.GetQuestIcon).was.not_called()
        end)
    end)
end)
