dofile("setupTests.lua")

describe("WorldMapButton", function()
    ---@type WorldMapButton
    local WorldMapButton

    ---@type MapIconVisibility
    local MapIconVisibility
    ---@type QuestieMenu
    local QuestieMenu
    ---@type QuestieOptionsEngine
    local QuestieOptionsEngine

    local mapButton, journeyButton
    local KButtonsMock
    local AceConfigDialogMock
    local tooltipLines

    before_each(function()
        Questie.db.profile = {
            enabled = true,
            enableMapIcons = true,
            enableMiniMapIcons = true,
            mapShowHideEnabled = true,
        }

        mapButton = {
            Show = spy.new(function() end),
            Hide = spy.new(function() end),
        }
        journeyButton = {
            Show = spy.new(function() end),
            Hide = spy.new(function() end),
        }
        KButtonsMock = {
            Add = spy.new(function(_, template) return template == "QuestieJourneyMapButtonTemplate" and journeyButton or mapButton end),
        }
        AceConfigDialogMock = {
            Open = spy.new(function() end),
        }

        _G.LibStub = function(name)
            if name == "Krowi_WorldMapButtons-1.4" then
                return KButtonsMock
            end

            return AceConfigDialogMock
        end

        MapIconVisibility = QuestieLoader:ImportModule("MapIconVisibility")
        MapIconVisibility.ToggleWorldMap = spy.new(function() end)
        MapIconVisibility.IsWorldMapShown = function() return true end

        QuestieMenu = QuestieLoader:ImportModule("QuestieMenu")
        QuestieMenu.IsOpen = function() return false end
        QuestieMenu.Show = spy.new(function() end)
        QuestieMenu.Hide = spy.new(function() end)

        local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
        QuestieLib.GetAddonVersionString = function() return "test" end

        QuestieOptionsEngine = QuestieLoader:ImportModule("QuestieOptionsEngine")
        QuestieOptionsEngine.RefreshStates = spy.new(function() end)

        dofile("Localization/l10n.lua")

        tooltipLines = {}
        _G.GameTooltip = {
            SetOwner = function() end,
            ClearLines = function() tooltipLines = {} end,
            SetPoint = function() end,
            AddLine = function() end,
            AddDoubleLine = function(_, left, right)
                table.insert(tooltipLines, {left, right})
            end,
            Show = function() end,
            IsShown = function() return false end,
            GetOwner = function() return nil end,
        }
        Questie.Colorize = function(_, value) return value end
        _G.QuestieConfigFrame = nil

        dofile("Modules/WorldMapButton/WorldMapButton.lua")
        WorldMapButton = QuestieLoader:ImportModule("WorldMapButton")
        WorldMapButton.Initialize()
    end)

    it("should initialize a visible map button when enabled", function()
        assert.spy(KButtonsMock.Add).was.called_with(KButtonsMock, "QuestieWorldMapButtonTemplate", "BUTTON")
        assert.spy(mapButton.Show).was.called_with(mapButton)
        assert.are_equal(mapButton, Questie.WorldMap.Button)
    end)

    it("should toggle the world map icons on left click", function()
        QuestieWorldMapButtonMixin.OnMouseDown(nil, "LeftButton")

        assert.spy(MapIconVisibility.ToggleWorldMap).was.called()
    end)

    it("should refresh the open options window after toggling map notes", function()
        QuestieWorldMapButtonMixin.OnMouseDown(nil, "LeftButton")

        assert.spy(QuestieOptionsEngine.RefreshStates).was.called()
    end)

    it("should describe the current world map icon action in its tooltip", function()
        QuestieWorldMapButtonMixin.OnEnter(mapButton)
        assert.are_equal("Hide Map Icons", tooltipLines[2][2])

        MapIconVisibility.IsWorldMapShown = function() return false end
        QuestieWorldMapButtonMixin.OnEnter(mapButton)
        assert.are_equal("Show Map Icons", tooltipLines[2][2])
    end)

    it("should initialize a hidden map button when disabled", function()
        mapButton.Show:clear()
        mapButton.Hide:clear()
        Questie.db.profile.mapShowHideEnabled = false

        WorldMapButton.Initialize()

        assert.spy(mapButton.Hide).was.called_with(mapButton)
        assert.spy(mapButton.Show).was.not_called()
    end)

    it("should show and hide the button of the Journey with Questie's", function()
        assert.spy(KButtonsMock.Add).was.called_with(KButtonsMock, "QuestieJourneyMapButtonTemplate", "BUTTON")
        assert.spy(journeyButton.Show).was.called_with(journeyButton)

        WorldMapButton.Toggle(false)

        assert.spy(journeyButton.Hide).was.called_with(journeyButton)
        assert.spy(mapButton.Hide).was.called_with(mapButton)
    end)

    it("should open the menu on right click", function()
        QuestieWorldMapButtonMixin.OnMouseDown(nil, "RightButton")

        assert.spy(QuestieMenu.Show).was.called()
        assert.spy(QuestieMenu.Hide).was.not_called()
    end)

    it("should hide the menu on right click when it is already open", function()
        QuestieMenu.IsOpen = function() return true end

        QuestieWorldMapButtonMixin.OnMouseDown(nil, "RightButton")

        assert.spy(QuestieMenu.Hide).was.called()
        assert.spy(QuestieMenu.Show).was.not_called()
    end)
end)
