dofile("setupTests.lua")

describe("QuestiePopup consumers", function()
    local Popup, externalPopup, visible, widgets, nativeButtons, options, addon
    local savedGlobals, exportedGlobals
    local globalNames = {"QuestiePopup", "YES", "NO", "CLOSE", "GetLocale", "QUESTIE_LOCALES_OVERRIDE",
        "ReloadUI", "UISpecialFrames", "LibStub", "CreateFrame", "QuestieConfig"}

    -- UI-only fixture: consumer definitions and callbacks are loaded from production files.
    local function Widget()
        local widget = {callbacks = {}, children = {}}
        widget.frame = widget
        widget.treeframe = widget
        function widget:SetCallback(event, callback) self.callbacks[event] = callback end
        function widget:SetScript(event, callback) self.callbacks[event] = callback end
        function widget:AddChild(child) self.children[#self.children + 1] = child end
        function widget:SetText(text) self.text = text end
        function widget:GetText() return self.text end
        function widget:GetChildren() return unpack(self.children) end
        function widget:Hide() self.hidden = true end
        function widget:SetFocus() self.focused = true end
        function widget:HighlightText() self.highlighted = true end
        for _, method in ipairs({"SetTitle", "SetLayout", "SetWidth", "SetHeight", "SetSize", "SetPoint",
            "EnableResize", "SetFullWidth", "SetFullHeight", "EnableButtonTooltips", "SetTree", "SelectByPath",
            "SetLabel", "SetList", "SetValue", "Show", "SetFrameStrata", "Raise", "ReleaseChildren"}) do
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
        _G.UISpecialFrames = {}
        Questie.Colorize = function(_, text) return text end
        Questie.started = true
        visible, widgets, nativeButtons = {}, {}, {}

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

        local aceGUI = {}
        function aceGUI:Create(kind)
            local widget = Widget()
            widgets[kind] = widget
            return widget
        end
        function aceGUI:Release() end
        _G.LibStub = function() return aceGUI end
        _G.CreateFrame = function(kind)
            local frame = Widget()
            if kind == "Button" then nativeButtons[#nativeButtons + 1] = frame end
            return frame
        end

        options = QuestieLoader:ImportModule("QuestieOptions")
        options.tabs = {}
        QuestieLoader:ImportModule("QuestieOptionsDefaults").Load = function()
            return {profile = {enabled = true, lowLevelStyle = "default", minimap = {hide = false}}, char = {hiddenDailies = {}}}
        end
        QuestieLoader:ImportModule("QuestieOptionsUtils").Spacer = function() return {} end
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

    it("runs locale reuse, cancellation and acceptance through the real dialog", function()
        local fixture = dofile("cli/testData/addonDialog/PopupUIHarness.lua")
        local _, errors, _, private = fixture.NewEnvironment()
        assert(loadfile("Modules/Libs/QuestiePopup.lua"))("Questie", private)
        dofile("Modules/Options/AdvancedTab/QuestieOptionsAdvanced.lua")
        local args = options.tabs.advanced:Initialize().args
        args.locale_dropdown.set(nil, "deDE")
        args.locale_dropdown.set(nil, "frFR")
        local frame = Popup.FindVisible("QUESTIE_LOCALE_CHANGE_CONFIRM")
        assert.is_not_nil(frame)
        frame:GetButton2():Click()
        assert.spy(ReloadUI).was.not_called()
        assert.is_nil(Questie.db.global.questieLocale)
        args.locale_dropdown.set(nil, "deDE")
        frame = Popup.FindVisible("QUESTIE_LOCALE_CHANGE_CONFIRM")
        frame:GetButton1():Click()
        assert.equals("deDE", Questie.db.global.questieLocale)
        assert.spy(ReloadUI).was.called(1)
        assert.same({}, errors)
    end)

    it("uses direct edit-box references and keeps styles separate between dialog purposes", function()
        local fixture = dofile("cli/testData/addonDialog/PopupUIHarness.lua")
        local _, errors, _, private = fixture.NewEnvironment()
        assert(loadfile("Modules/Libs/QuestiePopup.lua"))("Questie", private)
        dofile("Modules/Options/AdvancedTab/QuestieOptionsAdvanced.lua")
        options.tabs.advanced:Initialize().args.questieReset.func()
        local first = Popup.FindVisible("QUESTIE_RESET_CONFIRM")
        assert.equals("FULLSCREEN_DIALOG", first:GetFrameStrata())
        Popup.Hide("QUESTIE_RESET_CONFIRM")

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
        dofile("Modules/Options/AdvancedTab/QuestieOptionsAdvanced.lua")
        local args = options.tabs.advanced:Initialize().args
        args.locale_dropdown.set(nil, "deDE")
        args.locale_dropdown.set(nil, "frFR")
        assert.is_nil(Questie.db.global.questieLocale)
        assert.spy(ReloadUI).was.not_called()

        local key = "QUESTIE_LOCALE_CHANGE_CONFIRM"
        Popup.Dialogs[key].OnAccept(Popup.FindVisible(key))
        assert.equals("frFR", Questie.db.global.questieLocale)
        assert.is_true(Questie.db.global.questieLocaleDiff)
        assert.spy(ReloadUI).was.called(1)
    end)

    it("cancels locale changes without writing settings or reloading", function()
        dofile("Modules/Options/AdvancedTab/QuestieOptionsAdvanced.lua")
        options.tabs.advanced:Initialize().args.locale_dropdown.set(nil, "deDE")
        local info = Popup.Dialogs.QUESTIE_LOCALE_CHANGE_CONFIRM
        info.OnCancel()
        info.OnAccept()
        assert.is_nil(Questie.db.global.questieLocale)
        assert.spy(ReloadUI).was.not_called()
    end)

    it("resets settings only on acceptance and preserves localization", function()
        dofile("Modules/Options/AdvancedTab/QuestieOptionsAdvanced.lua")
        Questie.db.profile.enabled = false
        Questie.db.profile.migrationVersion = 42
        Questie.db.char.hidden = {123}
        Questie.db.global.questieLocale = "deDE"
        options.tabs.advanced:Initialize().args.questieReset.func()
        assert.is_false(Questie.db.profile.enabled)
        assert.spy(ReloadUI).was.not_called()
        Popup.Dialogs.QUESTIE_RESET_CONFIRM.OnAccept()
        assert.is_true(Questie.db.profile.enabled)
        assert.is_nil(Questie.db.profile.migrationVersion)
        assert.is_nil(Questie.db.char.hidden)
        assert.equals("deDE", Questie.db.global.questieLocale)
        assert.spy(ReloadUI).was.called(1)
    end)

    it("resets only the current character journey after acceptance", function()
        dofile("Modules/Options/AdvancedTab/QuestieOptionsAdvanced.lua")
        Questie.db.char.journey = {{Event = "Note"}}
        options.tabs.advanced:Initialize().args.questieJourneyReset.func()
        assert.equals(1, #Questie.db.char.journey)
        assert.spy(ReloadUI).was.not_called()
        Popup.Dialogs.QUESTIE_JOURNEY_RESET_CONFIRM.OnAccept()
        assert.is_nil(Questie.db.char.journey)
        assert.spy(ReloadUI).was.called(1)
    end)

    it("imports the latest selected journey when the confirmation is reopened", function()
        local first = {{Event = "Level", Timestamp = 1, NewLevel = 2}}
        local second = {{Event = "Level", Timestamp = 2, NewLevel = 3}}
        _G.QuestieConfig = {char = {["Alice - Realm"] = {journey = first}, ["Bob - Realm"] = {journey = second}}}
        Questie.db.char.journey = {}
        dofile("Modules/Journey/QuestieJourneyShare.lua")
        QuestieLoader:ImportModule("QuestieJourney"):ShowCharacterBrowserFrame()
        nativeButtons[1].callbacks.OnClick()
        widgets.Dropdown.callbacks.OnValueChanged(nil, nil, "Bob - Realm")
        nativeButtons[1].callbacks.OnClick()
        assert.same({}, Questie.db.char.journey)
        Popup.Dialogs.QUESTIE_JOURNEY_IMPORT_CONFIRM.OnAccept()
        assert.equals(second, Questie.db.char.journey)
        assert.is_true(widgets.Frame.hidden)
        assert.spy(ReloadUI).was.not_called()
    end)

    it("does not import a journey when cancelled or dismissed programmatically", function()
        local original = {{Event = "Level", Timestamp = 1, NewLevel = 2}}
        _G.QuestieConfig = {char = {["Alice - Realm"] = {journey = {{Event = "Level", Timestamp = 2, NewLevel = 3}}}}}
        Questie.db.char.journey = original
        dofile("Modules/Journey/QuestieJourneyShare.lua")
        QuestieLoader:ImportModule("QuestieJourney"):ShowCharacterBrowserFrame()
        nativeButtons[1].callbacks.OnClick()
        Popup.Dialogs.QUESTIE_JOURNEY_IMPORT_CONFIRM.OnCancel()
        assert.equals(original, Questie.db.char.journey)
        nativeButtons[1].callbacks.OnClick()
        Popup.Hide("QUESTIE_JOURNEY_IMPORT_CONFIRM")
        assert.equals(original, Questie.db.char.journey)
    end)

    it("shows the selected note title before acceptance and deletes that note", function()
        Questie.db.char.journey = {
            {Event = "Note", Timestamp = 1, Title = "First", Note = "One"},
            {Event = "Note", Timestamp = 2, Title = "Second", Note = "Two"},
        }
        QuestieLoader:ImportModule("QuestieLib").FormatDate = function() return "Today" end
        QuestieLoader:ImportModule("QuestieJourneyUtils").Spacer = function() end
        local journey = QuestieLoader:ImportModule("QuestieJourney").private
        journey.GetHistory = function() return {} end
        journey.GetJourneyEntries = function() return {} end
        dofile("Modules/Journey/tabs/MyJourney/MyJourney.lua")
        dofile("Modules/Journey/tabs/MyJourney/Note.lua")
        journey.myJourney:ManageTree(Widget())
        local tree = widgets.TreeGroup
        tree.localstatus = {selected = "2026\0013\0012"}
        tree.frame = {obj = Widget()}
        tree.callbacks.OnGroupSelected(tree)
        widgets.Button.callbacks.OnClick()
        local popup = Popup.FindVisible("QUESTIE_DELETE_NOTE_CONFIRM")
        assert.equals(2, popup.data)
        assert.equals("Are you sure you want to delete this note?\n\nSecond", popup.Text.text)
        assert.equals(2, #Questie.db.char.journey)
        Popup.Dialogs.QUESTIE_DELETE_NOTE_CONFIRM.OnAccept(popup)
        assert.equals(1, #Questie.db.char.journey)
        assert.equals("First", Questie.db.char.journey[1].Title)
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
