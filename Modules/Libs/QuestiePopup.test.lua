dofile("setupTests.lua")

describe("QuestiePopup consumers", function()
    local Popup, externalPopup, visible, options, addon
    local savedGlobals, exportedGlobals
    local globalNames = {"QuestiePopup", "YES", "NO", "CLOSE", "GetLocale", "QUESTIE_LOCALES_OVERRIDE",
        "ReloadUI", "CreateFrame"}

    -- UI-only fixture: consumer definitions and callbacks are loaded from production files.
    local function Widget()
        local widget = {}
        function widget:SetText(text) self.text = text end
        function widget:GetText() return self.text end
        function widget:Hide() self.hidden = true end
        function widget:SetFocus() self.focused = true end
        function widget:HighlightText() self.highlighted = true end
        for _, method in ipairs({"SetScript", "SetPoint", "SetSize", "Show", "SetFrameStrata", "Raise"}) do
            widget[method] = function() end
        end
        return widget
    end

    before_each(function()
        savedGlobals, exportedGlobals = {}, nil
        for _, name in ipairs(globalNames) do savedGlobals[name] = _G[name] end
        dofile("setupTests.lua")
        dofile("Localization/l10n.lua")
        _G.YES, _G.NO, _G.CLOSE = "Yes", "No", "Close"
        _G.GetLocale = function() return "enUS" end
        _G.QUESTIE_LOCALES_OVERRIDE = nil
        _G.ReloadUI = spy.new(function() end)
        Questie.Colorize = function(_, text) return text end
        Questie.started = true
        visible = {}

        -- Mock the external popup API, including cancellation on reuse and data-before-OnShow.
        externalPopup = {Dialogs = {}}
        addon = { Dialog = externalPopup }
        function externalPopup.FindVisible(key) return visible[key] end
        function externalPopup.Hide(key) visible[key] = nil end
        function externalPopup.Show(key, arg1, arg2, data)
            local info = externalPopup.Dialogs[key]
            local previous = visible[key]
            if previous and info.OnCancel and not info.noCancelOnReuse then
                info.OnCancel(previous, previous.data, "override")
            end
            local frame = Widget()
            frame.data, frame.Text, frame.EditBox = data, Widget(), Widget()
            frame.Text:SetText(arg1 and string.format(info.text, arg1, arg2) or info.text)
            visible[key] = frame
            if info.OnShow then info.OnShow(frame, data) end
            return frame
        end
        assert(loadfile("Modules/Libs/QuestiePopup.lua"))("Questie", addon)
        Popup = QuestieLoader:ImportModule("QuestiePopup")

        _G.CreateFrame = Widget

        options = QuestieLoader:ImportModule("QuestieOptionsEngine")
        options.tabs = {}
        QuestieLoader:ImportModule("QuestieOptionsDefaults").Load = function()
            return {profile = {enabled = true, lowLevelStyle = "default", minimap = {hide = false}}, char = {hiddenDailies = {}}}
        end
    end)

    after_each(function()
        for name, previous in pairs(exportedGlobals or {}) do _G[name] = previous[1] end
        for _, name in ipairs(globalNames) do _G[name] = savedGlobals[name] end
    end)

    it("does not replace the library when debug globals are populated", function()
        exportedGlobals = {}
        for name in pairs(QuestieLoader._modules) do exportedGlobals[name] = {_G[name]} end
        QuestieLoader:PopulateGlobals()
        assert.equals(externalPopup, addon.Dialog)
        assert.equals(Popup, _G.QuestiePopup)
    end)

    it("shares the external registry and plain function API", function()
        assert.equals(externalPopup.Dialogs, Popup.Dialogs)
        assert.equals(externalPopup.Show, Popup.Show)
        assert.equals(externalPopup.FindVisible, Popup.FindVisible)
        assert.equals(externalPopup.Hide, Popup.Hide)
    end)

    it("lets controller B close Questie dialogs on Forever only", function()
        local originalIsForever = Questie.IsForever
        local ok, err = pcall(function()
            Questie.IsForever = false
            assert.is_false(externalPopup.UseGamePadClose())
            Questie.IsForever = true
            assert.is_true(externalPopup.UseGamePadClose())
        end)
        Questie.IsForever = originalIsForever
        assert(ok, err)
    end)

    it("runs locale reuse, cancellation and acceptance through the real dialog", function()
        local fixture = dofile("cli/testData/addonDialog/PopupUIHarness.lua")
        local _, errors, _, private = fixture.NewEnvironment()
        assert(loadfile("Modules/Libs/QuestiePopup.lua"))("Questie", private)
        dofile("Modules/Options/NativeOptions/NativeOptionsAdvanced.lua")
        local items = options.tabs.advanced:Initialize().items
        items.locale_dropdown.set("deDE")
        items.locale_dropdown.set("frFR")
        local frame = Popup.FindVisible("QUESTIE_LOCALE_CHANGE_CONFIRM_NATIVE")
        assert.is_not_nil(frame)
        frame:GetButton2():Click()
        assert.spy(ReloadUI).was.not_called()
        assert.is_nil(Questie.db.global.questieLocale)
        items.locale_dropdown.set("deDE")
        frame = Popup.FindVisible("QUESTIE_LOCALE_CHANGE_CONFIRM_NATIVE")
        frame:GetButton1():Click()
        assert.equals("deDE", Questie.db.global.questieLocale)
        assert.spy(ReloadUI).was.called(1)
        assert.same({}, errors)
    end)

    it("uses direct edit-box references and keeps styles separate between dialog purposes", function()
        local fixture = dofile("cli/testData/addonDialog/PopupUIHarness.lua")
        local _, errors, _, private = fixture.NewEnvironment()
        assert(loadfile("Modules/Libs/QuestiePopup.lua"))("Questie", private)
        dofile("Modules/Options/NativeOptions/NativeOptionsAdvanced.lua")
        options.tabs.advanced:Initialize().items.questieReset.func()
        local first = Popup.FindVisible("QUESTIE_RESET_CONFIRM_NATIVE")
        assert.equals("FULLSCREEN_DIALOG", first:GetFrameStrata())
        Popup.Hide("QUESTIE_RESET_CONFIRM_NATIVE")

        Questie.db.profile.debugEnabled = true
        QuestieLoader:ImportModule("QuestieDB").QueryQuestSingle = function(id, field)
            if id == 1 and field == "objectives" then return {nil, nil, {{17}}} end
        end
        dofile("Modules/QuestieSlash.lua")
        QuestieLoader:ImportModule("QuestieSlash").HandleCommands("itemdrop")
        local frame = Popup.FindVisible("QUESTIE_ITEMDROPOUTPUT")
        assert.is_not_nil(frame)
        assert.are_not.equal(first, frame)
        assert.equals("DIALOG", frame:GetFrameStrata())
        assert.equals("17", frame:GetEditBoxText())
        assert.is_true(frame:GetEditBox().focused)
        assert.is_true(frame:GetEditBox().highlighted)
        assert.is_nil(frame:GetName())
        assert.equals(frame:GetEditBox(), frame.EditBox)
        assert.same({}, errors)
        assert.spy(ReloadUI).was.not_called()
    end)

    it("confirms the latest locale after reopening without losing the pending selection", function()
        dofile("Modules/Options/NativeOptions/NativeOptionsAdvanced.lua")
        local items = options.tabs.advanced:Initialize().items
        items.locale_dropdown.set("deDE")
        items.locale_dropdown.set("frFR")
        assert.is_nil(Questie.db.global.questieLocale)
        assert.spy(ReloadUI).was.not_called()

        local key = "QUESTIE_LOCALE_CHANGE_CONFIRM_NATIVE"
        Popup.Dialogs[key].OnAccept(Popup.FindVisible(key))
        assert.equals("frFR", Questie.db.global.questieLocale)
        assert.is_true(Questie.db.global.questieLocaleDiff)
        assert.spy(ReloadUI).was.called(1)
    end)

    it("cancels locale changes without writing settings or reloading", function()
        dofile("Modules/Options/NativeOptions/NativeOptionsAdvanced.lua")
        options.tabs.advanced:Initialize().items.locale_dropdown.set("deDE")
        local info = Popup.Dialogs.QUESTIE_LOCALE_CHANGE_CONFIRM_NATIVE
        info.OnCancel()
        info.OnAccept()
        assert.is_nil(Questie.db.global.questieLocale)
        assert.spy(ReloadUI).was.not_called()
    end)

    it("resets settings only on acceptance and preserves localization", function()
        dofile("Modules/Options/NativeOptions/NativeOptionsAdvanced.lua")
        Questie.db.profile.enabled = false
        Questie.db.profile.migrationVersion = 42
        Questie.db.char.hidden = {123}
        Questie.db.global.questieLocale = "deDE"
        options.tabs.advanced:Initialize().items.questieReset.func()
        assert.is_false(Questie.db.profile.enabled)
        assert.spy(ReloadUI).was.not_called()
        Popup.Dialogs.QUESTIE_RESET_CONFIRM_NATIVE.OnAccept()
        assert.is_true(Questie.db.profile.enabled)
        assert.is_nil(Questie.db.profile.migrationVersion)
        assert.is_nil(Questie.db.char.hidden)
        assert.equals("deDE", Questie.db.global.questieLocale)
        assert.spy(ReloadUI).was.called(1)
    end)

    it("resets only the current character journey after acceptance", function()
        dofile("Modules/Options/NativeOptions/NativeOptionsAdvanced.lua")
        Questie.db.char.journey = {{Event = "Note"}}
        options.tabs.advanced:Initialize().items.questieJourneyReset.func()
        assert.equals(1, #Questie.db.char.journey)
        assert.spy(ReloadUI).was.not_called()
        Popup.Dialogs.QUESTIE_JOURNEY_RESET_CONFIRM_NATIVE.OnAccept()
        assert.is_nil(Questie.db.char.journey)
        assert.spy(ReloadUI).was.called(1)
    end)

    it("accepts only the current hide confirmation when its dedicated frame is reopened", function()
        local fixture = dofile("cli/testData/addonDialog/PopupUIHarness.lua")
        local _, errors, _, private = fixture.NewEnvironment()
        assert(loadfile("Modules/Libs/QuestiePopup.lua"))("Questie", private)
        dofile("Modules/FramePool/QuestieFramePool.lua")
        local quest = QuestieLoader:ImportModule("QuestieQuest")
        quest.HideQuest = spy.new(function() end)
        local first = Popup.Show("QUESTIE_CONFIRMHIDE", "First quest", nil, 123)
        local replacement = Popup.Show("QUESTIE_CONFIRMHIDE", "Second quest", nil, 456)
        assert.equals(first, replacement)
        local current = Popup.FindVisible("QUESTIE_CONFIRMHIDE")
        assert.equals(456, current.data)
        assert.equals("Second quest", current.Text:GetText())
        assert.spy(quest.HideQuest).was.not_called()
        current:GetButton1():Click()
        assert.spy(quest.HideQuest).was.called(1)
        assert.spy(quest.HideQuest).was.called_with(quest, 456)
        assert.same({}, errors)
    end)

    it("shows copyable item-drop output using the owned edit box", function()
        Questie.db.profile.debugEnabled = true
        QuestieLoader:ImportModule("QuestieDB").QueryQuestSingle = function(id, field)
            if id == 1 and field == "objectives" then return {nil, nil, {{17}, {23}, {17}}} end
            if id == 2 and field == "requiredSourceItems" then return {23, 42} end
        end
        dofile("Modules/QuestieSlash.lua")
        QuestieLoader:ImportModule("QuestieSlash").HandleCommands("itemdrop")
        local popup = Popup.FindVisible("QUESTIE_ITEMDROPOUTPUT")
        assert.equals("17,23,42", popup.EditBox.text)
        assert.is_true(popup.EditBox.focused)
        assert.is_true(popup.EditBox.highlighted)
        popup.EditBox.GetParent = function() return popup end
        Popup.Dialogs.QUESTIE_ITEMDROPOUTPUT.EditBoxOnEscapePressed(popup.EditBox)
        assert.is_true(popup.hidden)
    end)
end)
