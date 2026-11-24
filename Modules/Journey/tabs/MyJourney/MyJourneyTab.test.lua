dofile("setupTests.lua")

local FakeUI = dofile("cli/testData/options/FakeUI.lua")

describe("My Journey", function()
    local myJourney, _QuestieJourney
    local ui
    local originalQuestie, originalGetUnitName, originalDate, originalMonthNames, originalTinsert
    local canvas, journey, popups, notesOpened

    local JANUARY, FEBRUARY, MARCH_2025 = 1767268800, 1770000000, 1741000000

    before_each(function()
        ui = FakeUI.Install()
        originalQuestie, originalGetUnitName = _G.Questie, _G.GetUnitName
        originalDate, originalMonthNames = _G.date, _G.CALENDAR_FULLDATE_MONTH_NAMES
        originalTinsert = _G.tinsert
        _G.GetUnitName = function() return "Thrall" end
        _G.date = os.date
        _G.CALENDAR_FULLDATE_MONTH_NAMES = {
            "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December",
        }
        journey = {
            {Event = "Level", NewLevel = 2, Timestamp = MARCH_2025},
            {Event = "Quest", SubType = "Accept", Quest = 7, Timestamp = JANUARY},
            {Event = "Note", Title = "Remember", Note = "The wolves\nare back.", Timestamp = JANUARY + 1},
            {Event = "Quest", SubType = "Complete", Quest = 7, Timestamp = FEBRUARY},
            {Event = "Quest", SubType = "Abandon", Quest = 404, Timestamp = FEBRUARY + 1},
            {Event = "Level", NewLevel = 3, Timestamp = FEBRUARY + 2},
        }
        _G.Questie = {
            db = {char = {journey = journey}, profile = {}},
            Colorize = function(_, text) return text end,
        }
        popups, notesOpened = {}, 0

        dofile("Modules/Libs/QuestieLoader.lua")
        dofile("Localization/l10n.lua")
        QuestieLoader:ImportModule("QuestieLib").FormatDate = function(timestamp) return "at " .. timestamp end
        local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
        QuestieDB.QueryQuestSingle = function(id) return id == 7 and "Wolves" or nil end
        QuestieDB.GetQuest = function(id) return id == 7 and {Description = {"Kill ten wolves."}} or nil end
        QuestieLoader:ImportModule("QuestiePopup").Show = function(...) table.insert(popups, {...}) end
        QuestieLoader:ImportModule("QuestieOptionsEngine").RefreshStates = function() end

        dofile("Modules/Options/QuestieOptionsUtils.lua")
        dofile("Modules/Options/QuestieOptionsControls.lua")
        dofile("Modules/Journey/JourneyPanes.lua")
        dofile("Modules/Journey/JourneyIcon.lua")
        dofile("Modules/Journey/JourneyScrollBox.lua")
        dofile("Modules/Journey/JourneyList.lua")
        dofile("Modules/Journey/JourneyTree.lua")
        dofile("Modules/Journey/JourneyDetails.lua")
        dofile("Modules/Journey/QuestieJourneyUtils.lua")
        dofile("Modules/Journey/History.lua")
        dofile("Modules/Journey/tabs/MyJourney/MyJourney.lua")
        dofile("Modules/Journey/tabs/MyJourney/MyJourneyTab.lua")
        _QuestieJourney = QuestieLoader:ImportModule("QuestieJourney").private
        _QuestieJourney.ToggleNoteWindow = function() notesOpened = notesOpened + 1 end
        myJourney = _QuestieJourney.myJourney

        canvas = CreateFrame("Frame", nil, UIParent)
        canvas:SetSize(1000, 500)
    end)

    after_each(function()
        _G.Questie, _G.GetUnitName = originalQuestie, originalGetUnitName
        _G.date, _G.CALENDAR_FULLDATE_MONTH_NAMES = originalDate, originalMonthNames
        _G.tinsert = originalTinsert
        ui.Restore()
    end)

    local function Open()
        myJourney.Build(canvas)
        myJourney.Refresh()
    end

    ---@return string[]
    local function ListTexts()
        return ui.RowTexts(canvas, 1)
    end

    ---@return string[]
    local function SelectedTexts()
        return ui.SelectedRowTexts(canvas, 1)
    end

    ---@param text string
    local function Click(text)
        ui.ClickRow(canvas, 1, text)
    end

    ---@return string[] texts
    local function Details()
        local texts = {}
        for _, row in ipairs(ui.Rows(canvas, 2)) do
            if row.elementData.text then
                table.insert(texts, row.elementData.text)
            end
        end
        return texts
    end

    ---@return string[] texts Of the box at the top
    local function RecentTexts()
        local box = ui.FindAll(canvas, function(frame)
            return frame.titleFrame ~= nil and frame.titleFrame.text == "Your Recent History"
        end)[1]
        local texts = {}
        for _, child in ipairs(box.contentArea.children) do
            if child.text ~= "" then
                table.insert(texts, child.text)
            end
        end
        return texts
    end

    it("should show the last five entries, newest first", function()
        Open()

        assert.are_same({
            "at " .. (FEBRUARY + 2) .. " Congratulations! You reached Level 3 !",
            "at " .. (FEBRUARY + 1) .. " You Abandoned the quest 404",
            "at " .. FEBRUARY .. " You Completed the quest Wolves",
            "at " .. (JANUARY + 1) .. " Note Created: Remember",
            "at " .. JANUARY .. " You Accepted the quest Wolves",
        }, RecentTexts())
    end)

    it("should encourage someone who hasn't done anything yet", function()
        Questie.db.char.journey = {}

        Open()

        assert.are_same({"It's about time you embark on your first Journey!"}, RecentTexts())
        assert.are_same({}, ListTexts())
    end)

    it("should open on the newest month", function()
        Open()

        assert.are_same({
            "2026",
            "February",
            "You Reached Level 3",
            "Quest Abandoned: no quest name",
            "Quest Completed: Wolves",
            "January",
            "2025",
        }, ListTexts())
    end)

    it("should open on the newest month of the first entries, when there weren't any before", function()
        Questie.db.char.journey = {}
        Open()

        Questie.db.char.journey[1] = {Event = "Level", NewLevel = 2, Timestamp = FEBRUARY}
        myJourney.Refresh()

        assert.are_same({"2026", "February", "You Reached Level 2"}, ListTexts())
    end)

    it("should open on the newest month of another journey that was imported", function()
        Open()
        Questie.db.char.journey = {{Event = "Level", NewLevel = 60, Timestamp = MARCH_2025}}

        myJourney.Refresh()

        assert.are_same({"2025", "March", "You Reached Level 60"}, ListTexts())
    end)

    it("should list another journey that was imported, also when it has as many entries", function()
        Open()
        Questie.db.char.journey = {}
        for level = 1, #journey do
            table.insert(Questie.db.char.journey, {Event = "Level", NewLevel = 10 + level, Timestamp = MARCH_2025})
        end

        myJourney.Refresh()

        assert.are.equal("You Reached Level " .. (10 + #journey), ListTexts()[3])
    end)

    it("should list entries that were added since it was shown", function()
        Open()
        table.insert(journey, {Event = "Level", NewLevel = 4, Timestamp = FEBRUARY + 3})

        myJourney.Refresh()

        assert.are.equal("You Reached Level 4", ListTexts()[3])
        assert.are.equal("at " .. (FEBRUARY + 3) .. " Congratulations! You reached Level 4 !", RecentTexts()[1])
    end)

    it("should only list the entries again when there are others, because there can be thousands", function()
        Open()
        local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
        local namesAsked = 0
        QuestieDB.QueryQuestSingle = function()
            namesAsked = namesAsked + 1
            return "Wolves"
        end

        myJourney.Refresh()
        assert.are.equal(0, namesAsked)

        table.remove(journey)
        myJourney.Refresh()
        assert.is_true(namesAsked > 0)
    end)

    it("should keep months open and closed as the user left them", function()
        Open()
        Click("February")
        Click("January")

        myJourney.Refresh()

        assert.are_same({"2026", "February", "January", "Note: Remember", "Quest Accepted: Wolves", "2025"}, ListTexts())
    end)

    describe("the details", function()
        before_each(function()
            Open()
            Click("January")
        end)

        it("should show a quest", function()
            Click("Quest Accepted: Wolves")

            assert.are_same({
                "Quest Accepted: Wolves",
                "Kill ten wolves.\n",
                "Quest Accepted: at " .. JANUARY,
                "Quest ID: 7",
            }, Details())
        end)

        it("should show a quest that isn't in the database", function()
            Click("Quest Abandoned: no quest name")

            assert.are_same({
                "Quest Abandoned: no quest name",
                "Quest Abandoned: at " .. (FEBRUARY + 1),
                "Quest ID: 404",
            }, Details())
        end)

        it("should show a level", function()
            Click("You Reached Level 3")

            assert.are_same({
                "You Reached Level 3",
                "Congratulations! You reached 3 !",
                "at " .. (FEBRUARY + 2),
            }, Details())
        end)

        it("should show a note as it was written, whatever is in it", function()
            table.insert(journey, {Event = "Note", Title = "50% done", Note = "Only 100% counts, %s said", Timestamp = FEBRUARY + 3})
            myJourney.Refresh()

            Click("Note: 50% done")

            assert.are.equal("Note: 50% done", Details()[1])
            assert.are.equal("Only 100% counts, %s said", Details()[2])
        end)

        it("should show a note, which can be deleted", function()
            Click("Note: Remember")

            assert.are_same({
                "Note: Remember",
                "The wolves\nare back.",
                "Note Created: at " .. (JANUARY + 1),
                "Delete Note",
            }, Details())
            local rows = ui.Rows(canvas, 2)
            rows[#rows].elementData.onClick()
            assert.are_same({{"QUESTIE_DELETE_NOTE_CONFIRM", nil, nil, journey[3]}}, popups)
        end)
    end)

    describe("the selected entry", function()
        before_each(function()
            Open()
            Click("Quest Completed: Wolves")
        end)

        it("should not be scrolled to when something was added", function()
            ui.visibleRows = 2
            myJourney.Refresh()
            ui.FindByTemplate(canvas, "WowScrollBoxList")[1]:ScrollToElementDataIndex(7)
            local textsBefore = ListTexts()
            table.insert(journey, {Event = "Level", NewLevel = 4, Timestamp = MARCH_2025})

            myJourney.Refresh()

            assert.are_same(textsBefore, ListTexts())
        end)

        it("should stay selected when something was added", function()
            table.insert(journey, {Event = "Level", NewLevel = 4, Timestamp = FEBRUARY + 3})

            myJourney.Refresh()

            assert.are_same({"Quest Completed: Wolves"}, SelectedTexts())
            assert.are.equal("Quest Completed: Wolves", Details()[1])
        end)

        it("should stay selected when an entry before it was deleted, which changes its index", function()
            table.remove(journey, 3)

            myJourney.Refresh()

            assert.are_same({"Quest Completed: Wolves"}, SelectedTexts())
            assert.are.equal("Quest Completed: Wolves", Details()[1])
        end)

        it("should not be shown anymore once it was deleted", function()
            table.remove(journey, 4)

            myJourney.Refresh()

            assert.are_same({}, SelectedTexts())
            assert.are_same({}, Details())
        end)

        it("should not be shown anymore after another journey was imported", function()
            Questie.db.char.journey = {{Event = "Level", NewLevel = 60, Timestamp = FEBRUARY}}

            myJourney.Refresh()

            assert.are_same({}, SelectedTexts())
            assert.are_same({}, Details())
            assert.are_same({"2026", "February", "You Reached Level 60"}, ListTexts())
        end)
    end)

    it("should have a button for adding a note", function()
        Open()

        local button = ui.FindAll(canvas, function(frame)
            return frame.itemData ~= nil and frame.itemData.btnLabel == "Add New Adventure Note"
        end)[1]
        button.widget:Click()

        assert.are.equal(1, notesOpened)
    end)

    it("should create nothing when it is shown again", function()
        Open()
        local frameCount = #ui.frames

        for _ = 1, 3 do myJourney.Refresh() end

        assert.are.equal(frameCount, #ui.frames)
    end)
end)
