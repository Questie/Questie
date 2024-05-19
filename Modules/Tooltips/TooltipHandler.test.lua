dofile("setupTests.lua")

describe("TooltipHandler", function()
    ---@type l10n
    local l10n
    ---@type QuestieTooltips
    local QuestieTooltips
    local _QuestieTooltips

    before_each(function()
        _G.Questie.db.profile.enableTooltips = true

        l10n = require("Localization.l10n")
        QuestieTooltips = require("Modules.Tooltips.Tooltip")
        _QuestieTooltips = require("Modules.Tooltips.TooltipHandler")
    end)

    describe("AddObjectDataToTooltip", function()
        it("should show a quest title with objective", function()
            local name = "test"
            local objectId = 1
            l10n.objectNameLookup[name] = {objectId}

            QuestieTooltips.GetTooltip = spy.new(function()
                return {"Quest Name", "0/1 Test Objective", "0/1 Other Objective"}
            end)

            _G.GameTooltip = {
                AddLine = spy.new(),
                Show = spy.new()
            }

            _QuestieTooltips:AddObjectDataToTooltip(name)

            assert.spy(GameTooltip.AddLine).was_called(3)
            assert.spy(GameTooltip.AddLine).was_called_with(GameTooltip, "Quest Name")
            assert.spy(GameTooltip.AddLine).was_called_with(GameTooltip, "0/1 Test Objective")
            assert.spy(GameTooltip.AddLine).was_called_with(GameTooltip, "0/1 Other Objective")
            assert.spy(GameTooltip.Show).was_called()
            assert.spy(QuestieTooltips.GetTooltip).was_called_with("o_" .. objectId)
        end)
    end)
end)
