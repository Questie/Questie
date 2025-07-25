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
                AddLine = spy.new(function() end),
                Show = spy.new(function() end)
            }

            _QuestieTooltips.AddObjectDataToTooltip(name)

            assert.spy(GameTooltip.AddLine).was.called(3)
            assert.spy(GameTooltip.AddLine).was.called_with(GameTooltip, "Quest Name")
            assert.spy(GameTooltip.AddLine).was.called_with(GameTooltip, "0/1 Test Objective")
            assert.spy(GameTooltip.AddLine).was.called_with(GameTooltip, "0/1 Other Objective")
            assert.spy(GameTooltip.Show).was.called()
            assert.spy(QuestieTooltips.GetTooltip).was.called_with("o_" .. objectId)
        end)

        it("should add list of quest names", function()
            local name = "test"
            l10n.objectNameLookup[name] = {1, 2}

            QuestieTooltips.GetTooltip = spy.new(function(id)
                if id == "o_1" then
                    return {"Quest Name"}
                elseif id == "o_2" then
                    return {"Quest Name", "Quest Name 2"}
                end
            end)

            _G.GameTooltip = {
                AddLine = spy.new(function() end),
                Show = spy.new(function() end)
            }

            _QuestieTooltips.AddObjectDataToTooltip(name)

            assert.spy(GameTooltip.AddLine).was.called(2)
            assert.spy(GameTooltip.AddLine).was.called_with(GameTooltip, "Quest Name")
            assert.spy(GameTooltip.AddLine).was.called_with(GameTooltip, "Quest Name 2")
            assert.spy(GameTooltip.Show).was.called()
            assert.spy(QuestieTooltips.GetTooltip).was.called_with("o_1")
            assert.spy(QuestieTooltips.GetTooltip).was.called_with("o_2")
        end)

        it("should add object IDs", function()
            local name = "test"
            local objectId = 1
            l10n.objectNameLookup[name] = {objectId}

            QuestieTooltips.GetTooltip = spy.new(function() end)

            _G.GameTooltip = {
                AddDoubleLine = spy.new(function() end),
                Show = spy.new(function() end)
            }

            _G.Questie.db.profile.enableTooltipsObjectID = true

            _QuestieTooltips.AddObjectDataToTooltip(name)

            assert.spy(GameTooltip.AddDoubleLine).was_called_with(GameTooltip, "Object ID", "|cFFFFFFFF" .. objectId .. "|r")
        end)

        it("should add multiple object IDs", function()
            local name = "test"
            l10n.objectNameLookup[name] = {1, 2}

            QuestieTooltips.GetTooltip = spy.new(function() end)

            _G.GameTooltip = {
                AddDoubleLine = spy.new(function() end),
                Show = spy.new(function() end)
            }

            _G.Questie.db.profile.enableTooltipsObjectID = true

            _QuestieTooltips.AddObjectDataToTooltip(name)

            assert.spy(GameTooltip.AddDoubleLine).was_called_with(GameTooltip, "Object ID", "|cFFFFFFFF1 (2)|r")
        end)

        it("should stop counting after 10", function()
            local name = "test"
            l10n.objectNameLookup[name] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11}

            QuestieTooltips.GetTooltip = spy.new(function() return {""} end)

            _G.GameTooltip = {
                AddLine = spy.new(function() end),
                AddDoubleLine = spy.new(function() end),
                Show = spy.new(function() end)
            }

            _G.Questie.db.profile.enableTooltipsObjectID = true

            _QuestieTooltips.AddObjectDataToTooltip(name)

            assert.spy(GameTooltip.AddDoubleLine).was.called_with(GameTooltip, "Object ID", "|cFFFFFFFF1 (10+)|r")
            assert.spy(QuestieTooltips.GetTooltip).was.called(10)
            assert.spy(QuestieTooltips.GetTooltip).was_not_called_with("o_11")
        end)
    end)
end)
