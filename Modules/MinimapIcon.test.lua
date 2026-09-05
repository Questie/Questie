dofile("setupTests.lua")

describe("MinimapIcon", function()
    ---@type MinimapIcon
    local MinimapIcon

    ---@type QuestieJourney
    local QuestieJourney
    ---@type QuestieMenu
    local QuestieMenu
    ---@type QuestieQuest
    local QuestieQuest
    ---@type QuestieOptions
    local QuestieOptions
    ---@type QuestieCombatQueue
    local QuestieCombatQueue
    ---@type QuestieLib
    local QuestieLib

    local LibDBIconMock = {}
    local dataBrokerObject
    local minimapButtonMock
    local minimapOnEnter

    local match = require("luassert.match")
    local _ = match._ -- any match

    before_each(function()
        Questie.started = true
        Questie.db.profile.enabled = true
        Questie.db.profile.enableMapIcons = true
        Questie.db.profile.enableMiniMapIcons = true
        Questie.db.profile.minimap = {hide = false}

        dataBrokerObject = nil
        minimapOnEnter = spy.new(function() end)
        minimapButtonMock = {
            IsMouseOver = function() return true end,
            GetScript = function(_, scriptName)
                if scriptName == "OnEnter" then
                    return minimapOnEnter
                end
            end,
            icon = {
                ClearAllPoints = function() end,
                SetSize = function() end,
                SetPoint = function() end,
            },
        }
        LibDBIconMock.Hide = spy.new(function() end)
        LibDBIconMock.Show = spy.new(function() end)
        LibDBIconMock.Register = spy.new(function() end)
        LibDBIconMock.GetMinimapButton = function() return minimapButtonMock end
        LibDBIconMock.NewDataObject = function(_, _, data)
            dataBrokerObject = data
            return data
        end

        _G.IsControlKeyDown = function() return false end
        _G.IsShiftKeyDown = function() return false end

        QuestieJourney = QuestieLoader:ImportModule("QuestieJourney")
        QuestieJourney.ToggleJourneyWindow = spy.new(function() end)

        QuestieLoader:ImportModule("QuestieProfessions")
        QuestieLib = QuestieLoader:ImportModule("QuestieLib")
        QuestieLib.GetAddonVersionString = function() return "test" end

        QuestieMenu = QuestieLoader:ImportModule("QuestieMenu")
        QuestieMenu.Show = spy.new(function() end)
        QuestieMenu.Hide = spy.new(function() end)

        QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")
        QuestieQuest.SmoothReset = spy.new(function() end)
        QuestieQuest.ToggleNotes = spy.new(function() end)

        QuestieOptions = QuestieLoader:ImportModule("QuestieOptions")
        QuestieOptions.HideFrame = spy.new(function() end)
        QuestieOptions.ToggleConfigWindow = spy.new(function() end)

        QuestieCombatQueue = QuestieLoader:ImportModule("QuestieCombatQueue")
        QuestieCombatQueue.Queue = function(_, callback) callback() end

        _G.LibStub = function() return LibDBIconMock end
        _G.GameTooltip = {Hide = spy.new(function() end)}
        Questie.Colorize = function(_, value) return value end
        dofile("Localization/l10n.lua")

        dofile("Modules/MinimapIcon.lua")
        MinimapIcon = QuestieLoader:ImportModule("MinimapIcon")
    end)

    it("should not do anything when Questie is not started yet", function()
        Questie.started = false
        local button = "LeftButton"

        MinimapIcon.private:OnClick(button)

        assert.spy(QuestieJourney.ToggleJourneyWindow).was.not_called()
        assert.spy(QuestieMenu.Show).was.not_called()
        assert.spy(QuestieQuest.SmoothReset).was.not_called()
        assert.spy(QuestieQuest.ToggleNotes).was.not_called()
        assert.spy(QuestieOptions.HideFrame).was.not_called()
        assert.spy(QuestieOptions.ToggleConfigWindow).was.not_called()
    end)

    it("should open My Journey on left click", function()
        local button = "LeftButton"

        MinimapIcon.private:OnClick(button)

        assert.spy(QuestieJourney.ToggleJourneyWindow).was.called()
    end)

    it("should open Questie on left click with Shift key down", function()
        local button = "LeftButton"
        _G.IsShiftKeyDown = function() return true end

        MinimapIcon.private:OnClick(button)

        assert.spy(QuestieOptions.ToggleConfigWindow).was.called()
    end)

    it("should open Questie on left click with Shift key down after combat", function()
        local button = "LeftButton"
        _G.IsShiftKeyDown = function() return true end
        _G.InCombatLockdown = function() return true end

        MinimapIcon.private:OnClick(button)

        assert.spy(QuestieOptions.ToggleConfigWindow).was.called()
    end)

    it("should reset Questie on left click with CTRL key down", function()
        local button = "LeftButton"
        _G.IsControlKeyDown = function() return true end

        MinimapIcon.private:OnClick(button)

        assert.spy(QuestieQuest.SmoothReset).was.called()
    end)

    it("should toggle notes on left click with CTRL and Shift key down", function()
        local button = "LeftButton"
        _G.IsControlKeyDown = function() return true end
        _G.IsShiftKeyDown = function() return true end

        MinimapIcon.private:OnClick(button)

        assert.is_false(Questie.db.profile.enabled)
        assert.spy(QuestieQuest.ToggleNotes).was.called_with(_, false)
        assert.spy(QuestieOptions.HideFrame).was.called()
    end)

    it("should open drop down menu on right click", function()
        QuestieMenu.IsOpen = function() return false end
        local button = "RightButton"

        MinimapIcon.private:OnClick(button)

        assert.spy(QuestieMenu.Show).was.called()
        assert.spy(QuestieMenu.Hide).was.not_called()
    end)

    it("should hide drop down menu on right click when it is already shown", function()
        QuestieMenu.IsOpen = function() return true end
        local button = "RightButton"

        MinimapIcon.private:OnClick(button)

        assert.spy(QuestieMenu.Hide).was.called()
        assert.spy(QuestieMenu.Show).was.not_called()
    end)

    it("should hide minimap notes on right click with CTRL key down", function()
        local button = "RightButton"
        _G.IsControlKeyDown = function() return true end

        MinimapIcon.private:OnClick(button)

        assert.is_false(Questie.db.profile.enableMiniMapIcons)
        assert.is_true(Questie.db.profile.enableMapIcons)
        assert.is_true(Questie.db.profile.enabled)
        assert.is_false(Questie.db.profile.minimap.hide)
        assert.spy(QuestieQuest.ToggleNotes).was.called_with(_, false, true)
        assert.spy(QuestieOptions.HideFrame).was.called()
        assert.spy(LibDBIconMock.Hide).was.not_called()
    end)

    it("should show minimap notes on right click with CTRL key down", function()
        Questie.db.profile.enableMiniMapIcons = false
        local button = "RightButton"
        _G.IsControlKeyDown = function() return true end

        MinimapIcon.private:OnClick(button)

        assert.is_true(Questie.db.profile.enableMiniMapIcons)
        assert.is_true(Questie.db.profile.enableMapIcons)
        assert.is_true(Questie.db.profile.enabled)
        assert.is_false(Questie.db.profile.minimap.hide)
        assert.spy(QuestieQuest.ToggleNotes).was.called_with(_, true, true)
        assert.spy(QuestieOptions.HideFrame).was.called()
        assert.spy(LibDBIconMock.Hide).was.not_called()
    end)

    it("should show only minimap notes when Questie icons are disabled globally", function()
        Questie.db.profile.enabled = false
        local button = "RightButton"
        _G.IsControlKeyDown = function() return true end

        MinimapIcon.private:OnClick(button)

        assert.is_true(Questie.db.profile.enabled)
        assert.is_true(Questie.db.profile.enableMiniMapIcons)
        assert.is_false(Questie.db.profile.enableMapIcons)
        assert.spy(QuestieQuest.ToggleNotes).was.called_with(_, true, true)
    end)

    it("should refresh the tooltip after toggling minimap notes", function()
        MinimapIcon:Init()
        _G.IsControlKeyDown = function() return true end

        MinimapIcon.private:OnClick("RightButton")

        assert.spy(GameTooltip.Hide).was.called()
        assert.spy(minimapOnEnter).was.called_with(minimapButtonMock)
    end)

    it("should describe the effective minimap icon action in its tooltip", function()
        MinimapIcon:Init()
        local tooltipLines = {}
        local tooltip = {
            AddLine = function() end,
            AddDoubleLine = function(_, left, right)
                table.insert(tooltipLines, {left, right})
            end,
        }

        dataBrokerObject.OnTooltipShow(tooltip)
        assert.are_equal("Hide Minimap Icons", tooltipLines[6][2])

        Questie.db.profile.enabled = false
        dataBrokerObject.OnTooltipShow(tooltip)
        assert.are_equal("Show Minimap Icons", tooltipLines[13][2])
    end)
end)
