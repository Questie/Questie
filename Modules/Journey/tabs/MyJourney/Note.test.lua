dofile("setupTests.lua")

local FakeUI = dofile("cli/testData/options/FakeUI.lua")

describe("Adventure notes", function()
    local _QuestieJourney, Popup
    local ui
    local originalQuestie, originalTime, originalYes, originalNo, originalHook, originalChatFrameUtil
    local journey, refreshes, messages

    before_each(function()
        ui = FakeUI.Install()
        originalQuestie, originalTime, originalYes, originalNo = _G.Questie, _G.time, _G.YES, _G.NO
        journey = {
            {Event = "Note", Title = "First", Note = "One", Timestamp = 1},
            {Event = "Level", NewLevel = 2, Timestamp = 2},
            {Event = "Note", Title = "Second", Note = "Two", Timestamp = 3},
        }
        refreshes, messages = 0, {}
        _G.Questie = {
            IsForever = true,
            db = {char = {journey = journey}, profile = {}},
            Colorize = function(_, text) return text end,
            Print = function(_, message) table.insert(messages, message) end,
        }
        _G.time = function() return 1700000000 end
        _G.YES, _G.NO = "Yes", "No"

        dofile("Modules/Libs/QuestieLoader.lua")
        dofile("Localization/l10n.lua")
        Popup = QuestieLoader:ImportModule("QuestiePopup")
        Popup.Dialogs = {}
        QuestieLoader:ImportModule("JourneyWindow").Refresh = function() refreshes = refreshes + 1 end
        originalHook, originalChatFrameUtil = _G.hooksecurefunc, _G.ChatFrameUtil
        _G.ChatFrameUtil = {InsertLink = function() end}
        _G.hooksecurefunc = function(owner, name, hook) owner[name] = hook end
        dofile("Modules/Journey/JourneyLinkInput.lua")
        QuestieLoader:ImportModule("QuestieOptionsEngine").RefreshStates = function() end

        dofile("Modules/Options/QuestieOptionsUtils.lua")
        dofile("Modules/Options/QuestieOptionsControls.lua")
        dofile("Modules/Options/QuestieOptionsWindow.lua")
        dofile("Modules/Journey/tabs/MyJourney/Note.lua")
        _QuestieJourney = QuestieLoader:ImportModule("QuestieJourney").private
    end)

    after_each(function()
        _G.Questie, _G.time, _G.YES, _G.NO = originalQuestie, originalTime, originalYes, originalNo
        _G.hooksecurefunc, _G.ChatFrameUtil = originalHook, originalChatFrameUtil
        ui.Restore()
    end)

    ---@return table window
    local function Window()
        return ui.FindAll(UIParent, function(frame) return frame.name == "QuestieJourneyNoteFrame" end)[1]
    end

    ---@return table titleBox
    local function TitleBox()
        return ui.FindByTemplate(Window(), "InputBoxTemplate")[1]
    end

    ---@return table messageBox
    local function MessageBox()
        return ui.FindByTemplate(Window(), "ScrollingEditBoxTemplate")[1]
    end

    ---@param title string
    ---@param message string
    local function Fill(title, message)
        TitleBox():SetText(title)
        MessageBox():SetText(message)
    end

    local function ClickAdd()
        ui.FindAll(Window(), function(frame) return frame.itemData ~= nil and frame.itemData.btnLabel == "Add Entry" end)[1].widget:Click()
    end

    describe("the window", function()
        it("should not exist until it is opened", function()
            assert.is_nil(Window())
        end)

        it("should open ready to type a title, and close", function()
            _QuestieJourney.ToggleNoteWindow()
            assert.is_true(Window():IsShown())
            assert.is_true(TitleBox():HasFocus())

            _QuestieJourney.ToggleNoteWindow()
            assert.is_false(Window():IsShown())
        end)

        it("should be above My Journey, which is in the same strata", function()
            _QuestieJourney.ToggleNoteWindow()

            assert.are.equal("FULLSCREEN_DIALOG", Window().frameStrata)
            assert.is_true(Window():GetFrameLevel() > 510)
        end)

        it("should close with the Escape key", function()
            _QuestieJourney.ToggleNoteWindow()

            assert.are_same({"QuestieJourneyNoteFrame"}, UISpecialFrames)
        end)

        it("should keep what was typed when it is closed, but create nothing again", function()
            _QuestieJourney.ToggleNoteWindow()
            Fill("Title", "Message")
            local frameCount = #ui.frames

            _QuestieJourney.ToggleNoteWindow()
            _QuestieJourney.ToggleNoteWindow()

            assert.are_same({"Title", "Message"}, {TitleBox():GetText(), MessageBox():GetText()})
            assert.are.equal(frameCount, #ui.frames)
        end)

        for _, script in ipairs({"OnEnterPressed", "OnTabPressed"}) do
            it("should move on from the title to the message: " .. script, function()
                _QuestieJourney.ToggleNoteWindow()

                TitleBox().scripts[script](TitleBox())

                assert.is_true(MessageBox():HasFocus())
            end)
        end

        it("should move back from the message to the title", function()
            _QuestieJourney.ToggleNoteWindow()
            MessageBox():SetFocus()

            MessageBox().scripts.OnTabPressed(MessageBox())

            assert.is_true(TitleBox():HasFocus())
        end)

        it("should type the message when the box around it is clicked", function()
            _QuestieJourney.ToggleNoteWindow()

            ui.FindAll(Window(), function(frame)
                return frame.titleFrame ~= nil and frame.titleFrame.text == "Journal Entry"
            end)[1]:Click()

            assert.is_true(MessageBox():HasFocus())
        end)

        it("should take links in the box that is typed in", function()
            _QuestieJourney.ToggleNoteWindow()
            ChatFrameUtil.InsertLink("[Gnoll Paw]")
            MessageBox():SetFocus()
            ChatFrameUtil.InsertLink("[Linen Cloth]")

            assert.are_same({"[Gnoll Paw]", "[Linen Cloth]"}, {TitleBox():GetText(), MessageBox():GetText()})
        end)
    end)

    describe("adding a note", function()
        before_each(function()
            _QuestieJourney.ToggleNoteWindow()
        end)

        it("should store it, close the window and show it", function()
            Fill("Remember", "The wolves are back.")

            ClickAdd()

            assert.are_same({Event = "Note", Title = "Remember", Note = "The wolves are back.", Timestamp = 1700000000}, journey[4])
            assert.is_false(Window():IsShown())
            assert.are.equal(1, refreshes)
        end)

        it("should start empty the next time", function()
            Fill("Remember", "The wolves are back.")
            ClickAdd()

            _QuestieJourney.ToggleNoteWindow()

            assert.are_same({"", ""}, {TitleBox():GetText(), MessageBox():GetText()})
        end)

        it("should need a title", function()
            Fill("", "The wolves are back.")

            ClickAdd()

            assert.are.equal(3, #journey)
            assert.is_true(Window():IsShown())
            assert.are_same({"[Questie] No Title was entered. You must enter a title before submitting your note."}, ui.printed)
        end)

        it("should need a message", function()
            Fill("Remember", "")

            ClickAdd()

            assert.are.equal(3, #journey)
            assert.are_same({"[Questie] No Note was entered. You must enter a note before submitting."}, ui.printed)
        end)
    end)

    describe("deleting a note", function()
        ---@param note table
        ---@return table popup
        local function Confirm(note)
            local popup = {data = note, Text = CreateFrame("FontString"), SetFrameStrata = function() end, Raise = function() end}
            Popup.Dialogs.QUESTIE_DELETE_NOTE_CONFIRM.OnShow(popup)
            return popup
        end

        it("should ask for confirmation with its title", function()
            local popup = Confirm(journey[3])

            assert.are.equal("Are you sure you want to delete this note?\n\nSecond", popup.Text.text)
            assert.are.equal(3, #journey)
        end)

        it("should only delete that note", function()
            local first, level = journey[1], journey[2]
            local popup = Confirm(journey[3])

            Popup.Dialogs.QUESTIE_DELETE_NOTE_CONFIRM.OnAccept(popup)

            assert.are_same({first, level}, journey)
            assert.are_same({"Note deleted successfully"}, messages)
            assert.are.equal(1, refreshes)
        end)

        it("should leave newer entries alone", function()
            local level, second = journey[2], journey[3]

            Popup.Dialogs.QUESTIE_DELETE_NOTE_CONFIRM.OnAccept(Confirm(journey[1]))

            assert.are_same({level, second}, journey)
        end)

        it("should delete the right note when an entry before it was removed meanwhile", function()
            local popup = Confirm(journey[3])
            table.remove(journey, 1)

            Popup.Dialogs.QUESTIE_DELETE_NOTE_CONFIRM.OnAccept(popup)

            assert.are_same({{Event = "Level", NewLevel = 2, Timestamp = 2}}, journey)
        end)

        it("should delete nothing when the note is gone already", function()
            local popup = Confirm({Event = "Note", Title = "Second", Note = "Two", Timestamp = 3})

            Popup.Dialogs.QUESTIE_DELETE_NOTE_CONFIRM.OnAccept(popup)

            assert.are.equal(3, #journey)
            assert.are_same({}, messages)
        end)
    end)
end)
