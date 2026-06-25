dofile("setupTests.lua")

describe("QuestieMap", function()

    ---@type QuestieMap
    local QuestieMap
    ---@type QuestieLib
    local QuestieLib

    local match = require("luassert.match")
    local _ = match._ -- any match

    before_each(function()
        QuestieLib = require("Modules.Libs.QuestieLib")
        QuestieMap = require("Modules.Map.QuestieMap")
        QuestieMap.questIdFrames = {}
    end)

    describe("UnloadQuestFrames", function()
        it("should clear AlreadySpawned for objective frames on full unload", function()
            local objective = {AlreadySpawned = {[123] = {}}}
            local unloadFrame1 = spy.new(function(self)
                self.data = nil
            end)
            local unloadFrame2 = spy.new(function(self)
                self.data = nil
            end)
            _G.QuestieFrame1 = {data = {ObjectiveData = objective}, Unload = unloadFrame1}
            _G.QuestieFrame2 = {data = {ObjectiveData = objective}, Unload = unloadFrame2}
            QuestieMap.questIdFrames[1] = {
                QuestieFrame1 = "QuestieFrame1",
                QuestieFrame2 = "QuestieFrame2",
            }

            QuestieMap:UnloadQuestFrames(1)

            assert.spy(unloadFrame1).was_called()
            assert.spy(unloadFrame2).was_called()
            assert.is_nil(_G.QuestieFrame1.data)
            assert.is_nil(_G.QuestieFrame2.data)
            assert.are.same({}, objective.AlreadySpawned)
            assert.is_nil(QuestieMap.questIdFrames[1])

            _G.QuestieFrame1 = nil
            _G.QuestieFrame2 = nil
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

            assert.spy(UpdateTextureMock).was_called(2)
            assert.spy(UpdateTextureMock).was_called_with(_, 11)
        end)

        it("should do nothing when no frames are found", function()
            QuestieMap.GetFramesForQuest = function() return {} end
            QuestieLib.GetQuestIcon = spy.new(function() end)

            QuestieMap.UpdateDrawnIcons(1)

            assert.spy(QuestieLib.GetQuestIcon).was_not_called()
        end)
    end)
end)
