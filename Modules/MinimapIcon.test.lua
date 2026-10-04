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
    ---@type QuestieStatus
    local QuestieStatus

    local LibDBIconMock = {Hide = spy.new(function() end)}

    local match = require("luassert.match")
    local _ = match._ -- any match

    before_each(function()
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

        QuestieStatus = QuestieLoader:ImportModule("QuestieStatus")
        QuestieStatus.Severity = {Error = 1, Warning = 2, Info = 3}

        _G.LibStub = function() return LibDBIconMock end
        dofile("Localization/l10n.lua")

        dofile("Modules/MinimapIcon.lua")
        MinimapIcon = QuestieLoader:ImportModule("MinimapIcon")
    end)

    describe("status display", function()
        local badge, button, badgeIssue, issues, dataObject, changed
        local shown, selectedIcon, textureCoords
        local originalTextureAPI, originalColorize, originalVersion
        local originalRegister, originalGetButton

        before_each(function()
            originalTextureAPI = _G.C_Texture
            originalColorize = Questie.Colorize
            originalVersion = QuestieLoader:ImportModule("QuestieLib").GetAddonVersionString
            originalRegister, originalGetButton = LibDBIconMock.Register, LibDBIconMock.GetMinimapButton
            Questie.Colorize = function(_, text) return text end
            QuestieLoader:ImportModule("QuestieLib").GetAddonVersionString = function() return "vTest" end
            _G.C_Texture = {GetAtlasInfo = function(name)
                if name == "common-icon-redx" or name == "custom-atlas" then return {} end
            end}
            shown, selectedIcon, textureCoords = false, nil, nil
            badgeIssue, issues, dataObject, changed = nil, {}, nil, nil
            badge = {
                SetSize = spy.new(function() end),
                SetPoint = spy.new(function() end),
                SetTexCoord = function(_, ...) textureCoords = {...} end,
                SetAtlas = function(_, atlas)
                    selectedIcon = {atlas = atlas}
                    textureCoords = {0.2, 0.4, 0.6, 0.8}
                end,
                SetTexture = function(_, texture)
                    selectedIcon = {texture = texture}
                    return true
                end,
                Show = function() shown = true end,
                Hide = function() shown = false end,
            }
            button = {
                icon = {ClearAllPoints = function() end, SetSize = function() end, SetPoint = function() end},
                CreateTexture = spy.new(function() return badge end),
            }
            LibDBIconMock.Register = function() end
            LibDBIconMock.GetMinimapButton = function() return button end
            _G.LibStub = function(name)
                if name == "LibDBIcon-1.0" then return LibDBIconMock end
                return {NewDataObject = function(_, _, object) dataObject = object; return object end}
            end
            QuestieStatus.GetBadgeIssue = function() return badgeIssue end
            QuestieStatus.GetIssues = function() return issues end
            QuestieStatus.SetOnChange = function(callback)
                changed = callback
                callback()
                return true
            end
        end)

        after_each(function()
            _G.C_Texture = originalTextureAPI
            Questie.Colorize = originalColorize
            QuestieLoader:ImportModule("QuestieLib").GetAddonVersionString = originalVersion
            LibDBIconMock.Register, LibDBIconMock.GetMinimapButton = originalRegister, originalGetButton
        end)

        it("adds an overlay and renders a failure recorded before the button existed", function()
            badgeIssue = {severity = QuestieStatus.Severity.Error}

            assert.is_true(MinimapIcon:Init())

            assert.spy(button.CreateTexture).was.called_with(button, nil, "OVERLAY", nil, 1)
            assert.spy(badge.SetPoint).was.called_with(badge, "TOPRIGHT", button, "TOPRIGHT", -1, -1)
            assert.are_same({atlas = "common-icon-redx"}, selectedIcon)
            assert.is_true(shown)
            assert.are_same("Interface\\Addons\\Questie\\Icons\\questie.png", dataObject.icon)
        end)

        it("resets atlas coordinates for a custom texture and hides the badge when cleared", function()
            badgeIssue = {severity = QuestieStatus.Severity.Info, icon = {atlas = "custom-atlas"}}
            MinimapIcon:Init()
            assert.are_same({atlas = "custom-atlas"}, selectedIcon)

            badgeIssue = {severity = QuestieStatus.Severity.Info, icon = {texture = "custom-texture"}}
            changed()
            assert.are_same({texture = "custom-texture"}, selectedIcon)
            assert.are_same({0, 1, 0, 1}, textureCoords)

            badgeIssue = nil
            changed()
            assert.is_false(shown)
        end)

        it("keeps the error visible when neither a custom atlas nor the modern default atlas is available", function()
            _G.C_Texture = nil
            badgeIssue = {severity = QuestieStatus.Severity.Error, icon = {atlas = "missing-atlas"}}

            assert.is_true(MinimapIcon:Init())

            assert.are_same({texture = "Interface\\RaidFrame\\ReadyCheck-NotReady"}, selectedIcon)
            assert.is_true(shown)
        end)

        it("falls back to the severity icon when a custom texture fails to load", function()
            _G.C_Texture = nil
            badgeIssue = {severity = QuestieStatus.Severity.Error, icon = {texture = "missing-texture"}}
            badge.SetTexture = function(_, texture)
                selectedIcon = {texture = texture}
                return texture ~= "missing-texture"
            end

            assert.is_true(MinimapIcon:Init())

            assert.are_same({texture = "Interface\\RaidFrame\\ReadyCheck-NotReady"}, selectedIcon)
            assert.is_true(shown)
        end)

        it("does not claim the status UI is installed when the minimap button is missing", function()
            button = nil

            assert.is_false(MinimapIcon:Init())
            assert.is_nil(changed)
        end)

        it("localizes every notice on hover and omits unusable controls before startup completes", function()
            Questie.started = false
            issues = {
                {
                    severity = QuestieStatus.Severity.Error, message = "Cannot load %s.", args = {"QuestieDB"}, action = "Try again.",
                    details = {{message = "Loaded %s (%d)", args = {"QuestieDB", 42}}, {message = "Source mode"}},
                },
                {severity = QuestieStatus.Severity.Info, message = "Source mode"},
            }
            MinimapIcon:Init()
            local l10n = QuestieLoader:ImportModule("l10n")
            l10n.translations["Error"] = {deDE = "Fehler"}
            l10n.translations["Cannot load %s."] = {deDE = "%s konnte nicht geladen werden."}
            l10n.translations["Try again."] = {deDE = "Erneut versuchen."}
            l10n.translations["Loaded %s (%d)"] = {deDE = "%s geladen (%d)"}
            l10n.translations["Source mode"] = {deDE = "Quellmodus"}
            l10n:SetUILocale("deDE")
            local lines = {}
            local tooltip = {
                AddLine = spy.new(function(_, text) lines[#lines + 1] = text end),
                AddDoubleLine = spy.new(function() end),
            }

            dataObject.OnTooltipShow(tooltip)

            assert.are_same({" ", "Fehler: QuestieDB konnte nicht geladen werden.",
                "  QuestieDB geladen (42)", "  Quellmodus", "Erneut versuchen.",
                " ", "Information: Quellmodus"}, lines)
            assert.spy(tooltip.AddLine).was.called_with(tooltip, lines[2], 1, 0.2, 0.2, true)
            assert.spy(tooltip.AddLine).was.called_with(tooltip, lines[3], 0.8, 0.8, 0.8, true)
            assert.spy(tooltip.AddLine).was.called_with(tooltip, lines[4], 0.8, 0.8, 0.8, true)
            assert.spy(tooltip.AddLine).was.called_with(tooltip, lines[5], 1, 1, 1, true)
            assert.spy(tooltip.AddDoubleLine).was.called(1)
        end)

        it("retains the normal controls after startup", function()
            MinimapIcon:Init()
            local tooltip = {AddLine = function() end, AddDoubleLine = spy.new(function() end)}

            dataObject.OnTooltipShow(tooltip)

            assert.spy(tooltip.AddDoubleLine).was.called_with(tooltip, "Left Click", "Toggle My Journey")
        end)
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

    it("should hide minimap icon on right click with CTRL key down", function()
        local button = "RightButton"
        _G.IsControlKeyDown = function() return true end

        MinimapIcon.private:OnClick(button)

        assert.is_true(Questie.db.profile.minimap.hide)
        assert.spy(LibDBIconMock.Hide).was.called_with(_, "Questie")
    end)
end)
