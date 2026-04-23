---@diagnostic disable: param-type-mismatch
dofile("setupTests.lua")

describe("GetQuestObjectiveIconForUnit", function()
    ---@type QuestieNameplate
    local QuestieNameplate

    before_each(function()
        _G.Questie.API.isReady = true

        QuestieNameplate = require("Modules.QuestieNameplate")
        ---@diagnostic disable-next-line: assign-type-mismatch
        QuestieNameplate.GetIcon = spy.new(function()
            return "Interface\\Addons\\Questie\\Icons\\slay.blp"
        end)

        dofile("Public/GetQuestObjectiveIconForUnit.lua")
    end)

    it("should return nil when Questie API is not ready", function()
        _G.Questie.API.isReady = false

        local result = _G.Questie.API.GetQuestObjectiveIconForUnit("some-guid")

        assert.is_nil(result)
    end)

    it("should return error when guid is not a string", function()
        assert.has_error(function()
            _G.Questie.API.GetQuestObjectiveIconForUnit(nil)
        end)
        assert.has_error(function()
            _G.Questie.API.GetQuestObjectiveIconForUnit(123)
        end)
        assert.has_error(function()
            _G.Questie.API.GetQuestObjectiveIconForUnit(true)
        end)
        assert.has_error(function()
            _G.Questie.API.GetQuestObjectiveIconForUnit({})
        end)
    end)

    it("should return icon path when Questie API is ready", function()
        local result = _G.Questie.API.GetQuestObjectiveIconForUnit("some-guid")

        assert.is_equal("Interface\\Addons\\Questie\\Icons\\slay.blp", result)
        assert.spy(QuestieNameplate.GetIcon).was.called_with("some-guid")
    end)
end)
