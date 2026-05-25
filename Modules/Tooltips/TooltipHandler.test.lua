dofile("setupTests.lua")

local PLAYER_ZONE = 440

-- Ensure GameTooltip mock is set before requiring modules
_G.GameTooltip = {
    AddLine = spy.new(function() end),
    AddDoubleLine = spy.new(function() end),
    Show = spy.new(function() end)
}

-- Now require modules
local l10n = require("Localization.l10n")
local QuestieTooltips = require("Modules.Tooltips.Tooltip")
local _QuestieTooltips = require("Modules.Tooltips.TooltipHandler")

describe("TooltipHandler", function()
    before_each(function()
        _G.Questie.db.profile.enableTooltips = true
        -- Reset spies
        _G.GameTooltip.AddLine:clear()
        _G.GameTooltip.AddDoubleLine:clear()
        _G.GameTooltip.Show:clear()
    end)

    describe("AddObjectDataToTooltip", function()
        it("should show a quest title with objective", function()
            local name = "test"
            local objectId = 1
            l10n.objectNameLookup[name] = {objectId}

            QuestieTooltips.GetTooltip = spy.new(function()
                return {"|cFF00FF00Quest Name|r", "|cFFFFFF000/1 Test Objective|r", "|cFFFFFF000/1 Other Objective|r"}
            end)

            _G.GameTooltip = {
                AddLine = spy.new(function() end),
                AddDoubleLine = spy.new(function() end),
                Show = spy.new(function() end)
            }

            _QuestieTooltips.AddObjectDataToTooltip(name, PLAYER_ZONE)

            assert.spy(GameTooltip.AddLine).was.called(3)
            assert.spy(GameTooltip.AddLine).was.called_with(GameTooltip, "|cFF00FF00Quest Name|r")
            assert.spy(GameTooltip.AddLine).was.called_with(GameTooltip, "|cFFFFFF000/1 Test Objective|r")
            assert.spy(GameTooltip.AddLine).was.called_with(GameTooltip, "|cFFFFFF000/1 Other Objective|r")
            assert.spy(GameTooltip.Show).was.called()
            assert.spy(QuestieTooltips.GetTooltip).was.called_with("o_" .. objectId, PLAYER_ZONE)
        end)

        it("should add list of quest names", function()
            local name = "test"
            l10n.objectNameLookup[name] = {1, 2}

            QuestieTooltips.GetTooltip = spy.new(function(id)
                if id == "o_1" then
                    return {"|cFF00FF00Quest Name|r"}
                elseif id == "o_2" then
                    return {"|cFF00FF00Quest Name|r", "|cFF00FF00Quest Name 2|r"}
                end
            end)

            _G.GameTooltip = {
                AddLine = spy.new(function() end),
                AddDoubleLine = spy.new(function() end),
                Show = spy.new(function() end)
            }

            _QuestieTooltips.AddObjectDataToTooltip(name, PLAYER_ZONE)

            assert.spy(GameTooltip.AddLine).was.called(2)
            assert.spy(GameTooltip.AddLine).was.called_with(GameTooltip, "|cFF00FF00Quest Name|r")
            assert.spy(GameTooltip.AddLine).was.called_with(GameTooltip, "|cFF00FF00Quest Name 2|r")

            assert.spy(GameTooltip.Show).was.called()
            assert.spy(QuestieTooltips.GetTooltip).was.called_with("o_1", PLAYER_ZONE)
            assert.spy(QuestieTooltips.GetTooltip).was.called_with("o_2", PLAYER_ZONE)
        end)

        it("should ignore non-colorized quest lines", function()
            local name = "test"
            l10n.objectNameLookup[name] = {1}

            QuestieTooltips.GetTooltip = spy.new(function()
                return {"Quest Name", "Quest Name 2"}
            end)

            _G.GameTooltip = {
                AddLine = spy.new(function() end),
                AddDoubleLine = spy.new(function() end),
                Show = spy.new(function() end)
            }

            _QuestieTooltips.AddObjectDataToTooltip(name, PLAYER_ZONE)

            assert.spy(GameTooltip.AddLine).was_not_called()
            assert.spy(GameTooltip.Show).was.called()
        end)

        it("should add object IDs", function()
            local name = "test"
            local objectId = 1
            l10n.objectNameLookup[name] = {objectId}

            QuestieTooltips.GetTooltip = spy.new(function() end)

            _G.GameTooltip = {
                AddLine = spy.new(function() end),
                AddDoubleLine = spy.new(function() end),
                Show = spy.new(function() end)
            }

            _G.Questie.db.profile.enableTooltipsObjectID = true

            _QuestieTooltips.AddObjectDataToTooltip(name, PLAYER_ZONE)

            assert.spy(GameTooltip.AddDoubleLine).was_called_with(GameTooltip, l10n("Object ID"), "|cFFFFFFFF" .. objectId .. "|r")
        end)

        it("should add multiple object IDs", function()
            local name = "test"
            l10n.objectNameLookup[name] = {1, 2}

            QuestieTooltips.GetTooltip = spy.new(function() end)

            _G.GameTooltip = {
                AddLine = spy.new(function() end),
                AddDoubleLine = spy.new(function() end),
                Show = spy.new(function() end)
            }

            _G.Questie.db.profile.enableTooltipsObjectID = true

            _QuestieTooltips.AddObjectDataToTooltip(name, PLAYER_ZONE)

            assert.spy(GameTooltip.AddDoubleLine).was_called_with(GameTooltip, l10n("Object ID"), "|cFFFFFFFF1 (2)|r")
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

            _QuestieTooltips.AddObjectDataToTooltip(name, PLAYER_ZONE)

            assert.spy(GameTooltip.AddDoubleLine).was.called_with(GameTooltip, l10n("Object ID"), "|cFFFFFFFF1 (10+)|r")
            assert.spy(QuestieTooltips.GetTooltip).was.called(10, PLAYER_ZONE)
            assert.spy(QuestieTooltips.GetTooltip).was_not_called_with("o_11", PLAYER_ZONE)
        end)
    end)
end)
