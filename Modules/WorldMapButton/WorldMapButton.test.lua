dofile("setupTests.lua")

describe("WorldMapButton", function()
    ---@type WorldMapButton
    local WorldMapButton

    ---@type QuestieQuest
    local QuestieQuest
    ---@type QuestieMenu
    local QuestieMenu

    local mapButton
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
        KButtonsMock = {
            Add = spy.new(function() return mapButton end),
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

        QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")
        QuestieQuest.ToggleNotes = spy.new(function() end)

        QuestieMenu = QuestieLoader:ImportModule("QuestieMenu")
        QuestieMenu.IsOpen = function() return false end
        QuestieMenu.Show = spy.new(function() end)
        QuestieMenu.Hide = spy.new(function() end)

        local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
        QuestieLib.GetAddonVersionString = function() return "test" end

        local l10n = QuestieLoader:ImportModule("l10n")
        setmetatable(l10n, {__call = function(_, key) return key end})

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

    it("should hide only world map notes on left click", function()
        QuestieWorldMapButtonMixin.OnMouseDown(nil, "LeftButton")

        assert.is_false(Questie.db.profile.enableMapIcons)
        assert.is_true(Questie.db.profile.enableMiniMapIcons)
        assert.is_true(Questie.db.profile.enabled)
        assert.spy(QuestieQuest.ToggleNotes).was.called_with(QuestieQuest, false, false)
    end)

    it("should show only world map notes on left click", function()
        Questie.db.profile.enableMapIcons = false

        QuestieWorldMapButtonMixin.OnMouseDown(nil, "LeftButton")

        assert.is_true(Questie.db.profile.enableMapIcons)
        assert.is_true(Questie.db.profile.enableMiniMapIcons)
        assert.is_true(Questie.db.profile.enabled)
        assert.spy(QuestieQuest.ToggleNotes).was.called_with(QuestieQuest, true, false)
    end)

    it("should show only world map notes when Questie icons are disabled globally", function()
        Questie.db.profile.enabled = false

        QuestieWorldMapButtonMixin.OnMouseDown(nil, "LeftButton")

        assert.is_true(Questie.db.profile.enabled)
        assert.is_true(Questie.db.profile.enableMapIcons)
        assert.is_false(Questie.db.profile.enableMiniMapIcons)
        assert.spy(QuestieQuest.ToggleNotes).was.called_with(QuestieQuest, true, false)
    end)

    it("should refresh the open options window after toggling map notes", function()
        _G.QuestieConfigFrame = {
            IsShown = function() return true end,
        }

        QuestieWorldMapButtonMixin.OnMouseDown(nil, "LeftButton")

        assert.spy(AceConfigDialogMock.Open).was.called_with(AceConfigDialogMock, "Questie", _G.QuestieConfigFrame)
    end)

    it("should describe the current world map icon action in its tooltip", function()
        QuestieWorldMapButtonMixin.OnEnter(mapButton)
        assert.are_equal("Hide Map Icons", tooltipLines[2][2])

        Questie.db.profile.enabled = false
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
