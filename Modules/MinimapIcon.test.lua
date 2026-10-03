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

    local LibDBIconMock = {Hide = spy.new(function() end)}

    local match = require("luassert.match")
    local _ = match._ -- any match

    local originalStarted, originalEnabled, originalMinimap
    local savedGlobals
    local globalNames = {"IsControlKeyDown", "IsShiftKeyDown", "InCombatLockdown", "LibStub"}

    before_each(function()
        savedGlobals = {}
        for _, name in ipairs(globalNames) do
            savedGlobals[name] = _G[name]
        end
        originalStarted = Questie.started
        originalEnabled, originalMinimap = Questie.db.profile.enabled, Questie.db.profile.minimap
        LibDBIconMock.Hide:clear()
        _G.InCombatLockdown = function() return false end
        Questie.started = true
        Questie.db.profile.enabled = true
        Questie.db.profile.minimap = {hide = false}

        _G.IsControlKeyDown = function() return false end
        _G.IsShiftKeyDown = function() return false end

        QuestieJourney = QuestieLoader:ImportModule("QuestieJourney")
        QuestieJourney.ToggleJourneyWindow = spy.new(function() end)

        QuestieLoader:ImportModule("QuestieProfessions")
        QuestieLoader:ImportModule("QuestieLib")

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
        dofile("Localization/l10n.lua")

        dofile("Modules/MinimapIcon.lua")
        MinimapIcon = QuestieLoader:ImportModule("MinimapIcon")
    end)

    after_each(function()
        Questie.started = originalStarted
        Questie.db.profile.enabled, Questie.db.profile.minimap = originalEnabled, originalMinimap
        for _, name in ipairs(globalNames) do
            _G[name] = savedGlobals[name]
        end
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
        local queuedCallback
        QuestieCombatQueue.Queue = spy.new(function(_, callback) queuedCallback = callback end)

        MinimapIcon.private:OnClick(button)

        assert.spy(QuestieOptions.ToggleConfigWindow).was.not_called()
        assert.spy(QuestieCombatQueue.Queue).was.called(1)
        assert.is_function(queuedCallback)
        _G.InCombatLockdown = function() return false end
        queuedCallback()
        assert.spy(QuestieOptions.ToggleConfigWindow).was.called(1)
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

    it("should hide minimap icon on right click with CTRL key down", function()
        local button = "RightButton"
        _G.IsControlKeyDown = function() return true end

        MinimapIcon.private:OnClick(button)

        assert.is_true(Questie.db.profile.minimap.hide)
        assert.spy(LibDBIconMock.Hide).was.called_with(_, "Questie")
    end)
end)
