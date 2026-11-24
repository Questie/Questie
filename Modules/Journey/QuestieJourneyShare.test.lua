dofile("setupTests.lua")

local FakeUI = dofile("cli/testData/options/FakeUI.lua")

describe("Importing a journey", function()
    local QuestieJourney, Popup
    local ui
    local originalQuestie, originalConfig, originalName, originalRealm, originalUnique, originalYes, originalNo
    local original, alice, bob, popup, refreshes, messages

    ---@param level number
    local function CreateJourney(level)
        return {{Event = "Level", Timestamp = 1, NewLevel = level}}
    end

    before_each(function()
        ui = FakeUI.Install()
        originalQuestie, originalConfig, originalName = _G.Questie, _G.QuestieConfig, _G.UnitNameUnmodified
        originalRealm, originalUnique = _G.GetRealmName, _G.RegionalUniqueNamesEnabled
        originalYes, originalNo = _G.YES, _G.NO
        _G.YES, _G.NO = "Yes", "No"
        original, alice, bob = CreateJourney(60), CreateJourney(2), CreateJourney(3)
        refreshes, messages = 0, {}
        _G.Questie = {
            IsForever = true,
            db = {char = {journey = original}, profile = {}},
            Print = function(_, message) table.insert(messages, message) end,
        }
        _G.QuestieConfig = {char = {
            ["Thrall - Realm"] = {journey = original},
            ["Alice - Realm"] = {journey = alice},
            ["Bob - Other Realm"] = {journey = bob},
            ["Carol - Realm"] = {journey = {}},
            ["Dave - Realm"] = {},
        }}
        _G.UnitNameUnmodified = function() return "Thrall" end
        _G.GetRealmName = function() return "Realm" end
        _G.RegionalUniqueNamesEnabled = nil

        dofile("Modules/Libs/QuestieLoader.lua")
        dofile("Localization/l10n.lua")
        Popup = QuestieLoader:ImportModule("QuestiePopup")
        Popup.Dialogs = {}
        popup = nil
        -- Opening a dialog that is open already cancels it, unless it says otherwise
        Popup.Show = function(key)
            local info = Popup.Dialogs[key]
            if popup and info.OnCancel and not info.noCancelOnReuse then
                info.OnCancel()
            end
            popup = {Text = CreateFrame("FontString"), SetFrameStrata = function() end, Raise = function() end}
            info.OnShow(popup)
        end
        QuestieLoader:ImportModule("JourneyWindow").Refresh = function() refreshes = refreshes + 1 end
        QuestieLoader:ImportModule("QuestieOptionsEngine").RefreshStates = function() end

        dofile("Modules/Options/QuestieOptionsUtils.lua")
        dofile("Modules/Options/QuestieOptionsControls.lua")
        dofile("Modules/Options/QuestieOptionsWindow.lua")
        dofile("Modules/Journey/QuestieJourneyShare.lua")
        QuestieJourney = QuestieLoader:ImportModule("QuestieJourney")
    end)

    after_each(function()
        _G.Questie, _G.QuestieConfig, _G.UnitNameUnmodified = originalQuestie, originalConfig, originalName
        _G.GetRealmName, _G.RegionalUniqueNamesEnabled = originalRealm, originalUnique
        _G.YES, _G.NO = originalYes, originalNo
        ui.Restore()
    end)

    ---@return table window
    local function Window()
        return ui.FindAll(UIParent, function(frame) return frame.name == "QuestieImportJourneyFrame" end)[1]
    end

    ---@return table dropdown
    local function Dropdown()
        return ui.FindByTemplate(Window(), "WowStyle1DropdownTemplate")[1]
    end

    ---@return string[] texts
    local function Characters()
        Dropdown():OpenMenu()
        local texts = {}
        for _, entry in ipairs(Dropdown().menuEntries) do
            table.insert(texts, entry.text)
        end
        Dropdown():CloseMenu()
        return texts
    end

    ---@param text string
    local function Choose(text)
        Dropdown():OpenMenu()
        for _, entry in ipairs(Dropdown().menuEntries) do
            if entry.text == text then
                return Dropdown():Pick(entry)
            end
        end
        error("There is no character " .. text)
    end

    ---@return table button
    local function ImportButton()
        return ui.FindAll(Window(), function(frame) return frame.itemData ~= nil and frame.itemData.btnLabel == "Import" end)[1]
    end

    local function ClickImport()
        ImportButton().widget:Click()
    end

    local function Accept()
        Popup.Dialogs.QUESTIE_JOURNEY_IMPORT_CONFIRM.OnAccept(popup)
    end

    it("should offer the other characters that have a journey", function()
        QuestieJourney:ShowCharacterBrowserFrame()

        assert.are_same({"Alice (Realm)", "Bob (Other Realm)"}, Characters())
        assert.are.equal("Alice (Realm)", Dropdown().text)
    end)

    it("should understand characters without a realm, whose names are unique", function()
        _G.RegionalUniqueNamesEnabled = function() return true end
        _G.UnitNameUnmodified = function() return "Thrall", "Doomhammer" end
        _G.QuestieConfig = {char = {["Thrall Doomhammer"] = {journey = original}, ["Alice Liddell"] = {journey = alice}}}

        QuestieJourney:ShowCharacterBrowserFrame()

        assert.are_same({"Alice Liddell"}, Characters())
    end)

    it("should only replace the journey after it was confirmed", function()
        QuestieJourney:ShowCharacterBrowserFrame()
        ClickImport()
        assert.are.equal(original, Questie.db.char.journey)

        Accept()

        assert.are.equal(alice, Questie.db.char.journey)
        assert.is_false(Window():IsShown())
        assert.are.equal(1, refreshes)
        assert.are_same({"Journey imported. Open the My Journey tab to see the changes."}, messages)
    end)

    it("should import the character that was selected last when the confirmation is opened again", function()
        QuestieJourney:ShowCharacterBrowserFrame()
        ClickImport()
        Choose("Bob (Other Realm)")
        ClickImport()

        Accept()

        assert.are.equal(bob, Questie.db.char.journey)
    end)

    it("should not import a journey when that is cancelled", function()
        QuestieJourney:ShowCharacterBrowserFrame()
        ClickImport()

        Popup.Dialogs.QUESTIE_JOURNEY_IMPORT_CONFIRM.OnCancel()

        assert.are.equal(original, Questie.db.char.journey)
        assert.are.equal(0, refreshes)
    end)

    for reason, entry in pairs({
        ["no time"] = {Event = "Level", NewLevel = 2},
        ["an unknown event"] = {Event = "Death", Timestamp = 1},
        ["a level that isn't a number"] = {Event = "Level", Timestamp = 1, NewLevel = "2"},
        ["an unknown quest event"] = {Event = "Quest", SubType = "Share", Quest = 7, Level = 2, Timestamp = 1},
        ["no quest"] = {Event = "Quest", SubType = "Accept", Level = 2, Timestamp = 1},
        ["a quest without the player's level"] = {Event = "Quest", SubType = "Accept", Quest = 7, Timestamp = 1},
        ["a note without a title"] = {Event = "Note", Note = "One", Timestamp = 1},
        ["a note without a text"] = {Event = "Note", Title = "First", Timestamp = 1},
    }) do
        it("should refuse a journey with " .. reason, function()
            alice[2] = entry
            QuestieJourney:ShowCharacterBrowserFrame()

            ClickImport()

            assert.is_nil(popup)
            assert.are.equal(1, #messages)
        end)
    end

    it("should accept every kind of entry", function()
        alice[2] = {Event = "Quest", SubType = "Accept", Quest = 7, Level = 2, Timestamp = 1}
        alice[3] = {Event = "Quest", SubType = "Complete", Quest = 7, Level = 2, Timestamp = 2}
        alice[4] = {Event = "Quest", SubType = "Abandon", Quest = 8, Level = 2, Timestamp = 3}
        alice[5] = {Event = "Note", Title = "First", Note = "One", Timestamp = 4}
        QuestieJourney:ShowCharacterBrowserFrame()

        ClickImport()
        Accept()

        assert.are.equal(alice, Questie.db.char.journey)
    end)

    it("should say so when there is nothing to import", function()
        _G.QuestieConfig = {char = {["Thrall - Realm"] = {journey = original}}}

        QuestieJourney:ShowCharacterBrowserFrame()

        local texts = ui.FindAll(Window(), function(frame)
            return frame.text == "No other characters with journey data found." and frame:IsVisible()
        end)
        assert.are.equal(1, #texts)
        assert.is_false(Dropdown():IsVisible())
        assert.is_false(ImportButton():IsVisible())
    end)

    it("should not import a character that is gone", function()
        QuestieJourney:ShowCharacterBrowserFrame()
        QuestieConfig.char["Alice - Realm"] = nil

        QuestieJourney:ShowCharacterBrowserFrame()
        assert.are.equal("Bob (Other Realm)", Dropdown().text)

        ClickImport()
        Accept()
        assert.are.equal(bob, Questie.db.char.journey)
    end)

    it("should notice when other characters have a journey meanwhile, and create nothing again", function()
        _G.QuestieConfig = {char = {}}
        QuestieJourney:ShowCharacterBrowserFrame()
        Window():Hide()
        local frameCount = #ui.frames
        _G.QuestieConfig = {char = {["Alice - Realm"] = {journey = alice}}}

        QuestieJourney:ShowCharacterBrowserFrame()

        assert.is_true(Dropdown():IsVisible())
        assert.are.equal("Alice (Realm)", Dropdown().text)
        assert.are.equal(frameCount, #ui.frames)
    end)
end)
