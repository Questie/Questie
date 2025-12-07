dofile("setupTests.lua")

describe("API", function()
    ---@type QuestieNameplate
    local QuestieNameplate

    before_each(function()
        _G.Questie.API.isReady = true

        QuestieNameplate = require("Modules.QuestieNameplate")
        QuestieNameplate.GetIcon = spy.new(function()
            return "Interface\\Addons\\Questie\\Icons\\slay.blp"
        end)

        dofile("Modules/API.lua")
    end)

    describe("GetQuestObjectiveIconForUnit", function()
        it("should return nil when Questie API is not ready", function()
            _G.Questie.API.isReady = false

            local result = _G.Questie.API.GetQuestObjectiveIconForUnit("some-guid")

            assert.is_nil(result)
        end)

        it("should return icon path when Questie API is ready", function()
            local result = _G.Questie.API.GetQuestObjectiveIconForUnit("some-guid")

            assert.is_equal("Interface\\Addons\\Questie\\Icons\\slay.blp", result)
            assert.spy(QuestieNameplate.GetIcon).was.called_with("some-guid")
        end)
    end)
end)
