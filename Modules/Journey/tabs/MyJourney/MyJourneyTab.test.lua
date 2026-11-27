dofile("setupTests.lua")

local FakeUI = dofile("cli/testData/options/FakeUI.lua")

describe("My Journey", function()
    local myJourney, _QuestieJourney
    local ui
    local originals
    local canvas, journey, popups, notesOpened

    -- At noon of the local time, so the day and the weekday don't depend on the time zone of the test
    local MARCH_2025 = os.time({year = 2025, month = 3, day = 3, hour = 12}) -- A Monday
    local JANUARY = os.time({year = 2026, month = 1, day = 1, hour = 12}) -- A Thursday
    local FEBRUARY = os.time({year = 2026, month = 2, day = 2, hour = 12}) -- A Monday

    before_each(function()
        ui = FakeUI.Install()
        originals = {}
        for _, name in ipairs({"Questie", "GetUnitName", "date", "CALENDAR_FULLDATE_MONTH_NAMES", "CALENDAR_WEEKDAY_NAMES", "tinsert"}) do
            originals[name] = {value = _G[name]}
        end
        _G.GetUnitName = function() return "Thrall" end
        _G.date = os.date
        _G.CALENDAR_FULLDATE_MONTH_NAMES = {
            "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December",
        }
        _G.CALENDAR_WEEKDAY_NAMES = {"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"}
        journey = {
            {Event = "Level", NewLevel = 2, Timestamp = MARCH_2025},
            {Event = "Quest", SubType = "Accept", Quest = 7, Timestamp = JANUARY},
            {Event = "Note", Title = "Remember", Note = "The wolves\nare back.", Timestamp = JANUARY + 60},
            {Event = "Quest", SubType = "Complete", Quest = 7, Timestamp = FEBRUARY},
            {Event = "Quest", SubType = "Abandon", Quest = 404, Timestamp = FEBRUARY + 60},
            {Event = "Level", NewLevel = 3, Timestamp = FEBRUARY + 120},
        }
        _G.Questie = {
            db = {char = {journey = journey, journeyWindow = {quests = {}, history = {}}}, profile = {}},
            icons = {fav = "fav", available = "available", checkmark = "checkmark", cross = "cross"},
            Colorize = function(_, text) return text end,
        }
        popups, notesOpened = {}, 0

        dofile("Modules/Libs/QuestieLoader.lua")
        dofile("Localization/l10n.lua")
        local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
        QuestieLib.FormatDate = function(timestamp) return "day " .. timestamp .. " at 12:00" end
        QuestieLib.GetColoredQuestName = function(_, id) return "Quest " .. id end
        local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
        QuestieDB.QuestPointers = {[7] = true}
        QuestieDB.QueryQuestSingle = function(id) return id == 7 and "Wolves" or nil end
        QuestieDB.GetQuest = function(id) return id == 7 and {Id = 7, Description = {"Kill ten wolves."}} or nil end
        QuestieLoader:ImportModule("QuestiePlayer").GetPlayerLevel = function() return 3 end
        QuestieLoader:ImportModule("QuestiePopup").Show = function(...) table.insert(popups, {...}) end
        QuestieLoader:ImportModule("QuestieOptionsEngine").RefreshStates = function() end
        -- The details of quests are tested with JourneyQuestDetails
        QuestieLoader:ImportModule("JourneyQuestDetails").GetRows = function(quest)
            return {{type = "text", text = "The details of quest " .. quest.Id}}
        end

        dofile("Modules/Options/QuestieOptionsUtils.lua")
        dofile("Modules/Options/QuestieOptionsControls.lua")
        dofile("Modules/Journey/Window/JourneyPanes.lua")
        dofile("Modules/Journey/Window/JourneyIcon.lua")
        dofile("Modules/Journey/Window/JourneyScrollBox.lua")
        dofile("Modules/Journey/Window/JourneyList.lua")
        dofile("Modules/Journey/Window/JourneyTree.lua")
        dofile("Modules/Journey/Window/JourneyPicker.lua")
        dofile("Modules/Journey/Details/JourneyDetails.lua")
        dofile("Modules/Journey/Details/QuestieJourneyUtils.lua")
        dofile("Modules/Journey/tabs/MyJourney/History.lua")
        dofile("Modules/Journey/tabs/MyJourney/MyJourney.lua")
        dofile("Modules/Journey/tabs/MyJourney/MyJourneyTab.lua")
        _QuestieJourney = QuestieLoader:ImportModule("QuestieJourney").private
        _QuestieJourney.ToggleNoteWindow = function() notesOpened = notesOpened + 1 end
        myJourney = _QuestieJourney.myJourney

        canvas = CreateFrame("Frame", nil, UIParent)
        canvas:SetSize(1000, 500)
    end)

    after_each(function()
        for name, original in pairs(originals) do
            _G[name] = original.value
        end
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

    ---@return string text Of the line beside the filter
    local function Summary()
        for _, child in ipairs(canvas.children) do
            if child.frameType == "FontString" then
                return child.text
            end
        end
    end

    ---@param text string
    local function Filter(text)
        local picker = ui.FindAll(canvas, function(frame) return frame.menuGenerator ~= nil end)[1]
        picker:OpenMenu()
        for _, entry in ipairs(picker.menuEntries) do
            if entry.text == text then
                entry.select()
                return picker
            end
        end
        error("There is no filter " .. text)
    end

    it("should list the journey by month and day, newest first, with the newest day open", function()
        Open()

        assert.are_same({
            "February 2026",
            "Monday, February 2",
            "Level 3",
            "404",
            "Quest 7",
            "January 2026",
            "March 2025",
        }, ListTexts())
    end)

    it("should open the two newest days, which are often today and yesterday", function()
        table.insert(journey, {Event = "Level", NewLevel = 4, Timestamp = FEBRUARY + 86400})
        table.insert(journey, {Event = "Level", NewLevel = 5, Timestamp = FEBRUARY + 2 * 86400})

        Open()

        assert.are_same({
            "February 2026",
            "Wednesday, February 4", "Level 5",
            "Tuesday, February 3", "Level 4",
            "Monday, February 2",
            "January 2026",
            "March 2025",
        }, ListTexts())
    end)

    it("should sum up the journey", function()
        Open()

        assert.are.equal("1 quests completed, level 3, since day " .. MARCH_2025, Summary())
    end)

    it("should encourage someone who hasn't done anything yet", function()
        Questie.db.char.journey = {}

        Open()

        assert.are.equal("It's about time you embark on your first Journey!", Summary())
        assert.are_same({}, ListTexts())
    end)

    it("should only list what is filtered, with every day open", function()
        Open()

        local picker = Filter("Level ups")

        assert.are.equal("Level ups", picker.text)
        assert.are_same({
            "February 2026", "Monday, February 2", "Level 3",
            "March 2025", "Monday, March 3", "Level 2",
        }, ListTexts())
    end)

    it("should open on the newest month of the first entries, when there weren't any before", function()
        Questie.db.char.journey = {}
        Open()

        Questie.db.char.journey[1] = {Event = "Level", NewLevel = 2, Timestamp = FEBRUARY}
        myJourney.Refresh()

        assert.are_same({"February 2026", "Monday, February 2", "Level 2"}, ListTexts())
    end)

    it("should open on the newest month of another journey that was imported", function()
        Open()
        Questie.db.char.journey = {{Event = "Level", NewLevel = 60, Timestamp = MARCH_2025}}

        myJourney.Refresh()

        assert.are_same({"March 2025", "Monday, March 3", "Level 60"}, ListTexts())
    end)

    it("should list another journey that was imported, also when it has as many entries", function()
        Open()
        Questie.db.char.journey = {}
        for level = 1, #journey do
            table.insert(Questie.db.char.journey, {Event = "Level", NewLevel = 10 + level, Timestamp = MARCH_2025 + level})
        end

        myJourney.Refresh()

        assert.are.equal("Level " .. (10 + #journey), ListTexts()[3])
    end)

    it("should list entries that were added since it was shown", function()
        Open()
        table.insert(journey, {Event = "Level", NewLevel = 4, Timestamp = FEBRUARY + 180})

        myJourney.Refresh()

        assert.are.equal("Level 4", ListTexts()[3])
    end)

    it("should only list the entries again when there are others, because there can be thousands", function()
        Open()
        local listed = 0
        _G.CALENDAR_FULLDATE_MONTH_NAMES = setmetatable({}, {__index = function()
            listed = listed + 1
            return "Month"
        end})

        myJourney.Refresh()
        assert.are.equal(0, listed)

        table.remove(journey)
        myJourney.Refresh()
        assert.is_true(listed > 0)
    end)

    it("should keep months open and closed as the user left them", function()
        Open()
        Click("February 2026")
        Click("January 2026")

        myJourney.Refresh()

        assert.are_same({"February 2026", "January 2026", "Thursday, January 1", "March 2025"}, ListTexts())
    end)

    describe("the details", function()
        before_each(function()
            Open()
        end)

        it("should show the newest entry first", function()
            assert.are_same({"Level 3"}, SelectedTexts())
            assert.are.equal("Level 3", Details()[1])
        end)

        it("should show a quest", function()
            Click("Quest 7")

            assert.are_same({"The details of quest 7"}, Details())
        end)

        it("should show a quest that isn't in the database", function()
            Click("404")

            assert.are_same({
                "Quest Abandoned: no quest name",
                "Quest Abandoned: day " .. (FEBRUARY + 60) .. " at 12:00",
                "Quest ID: 404",
            }, Details())
        end)

        it("should show a note, which can be deleted", function()
            Click("January 2026")
            Click("Thursday, January 1")
            Click("Remember")

            assert.are_same({
                "Note: Remember",
                "The wolves\nare back.",
                "Note Created: day " .. (JANUARY + 60) .. " at 12:00",
                "Delete Note",
            }, Details())
            local rows = ui.Rows(canvas, 2)
            rows[#rows].elementData.onClick()
            assert.are_same({{"QUESTIE_DELETE_NOTE_CONFIRM", nil, nil, journey[3]}}, popups)
        end)

        it("should show a note as it was written, whatever is in it", function()
            table.insert(journey, {Event = "Note", Title = "50% done", Note = "Only 100% counts, %s said", Timestamp = FEBRUARY + 180})
            myJourney.Refresh()

            Click("50% done")

            assert.are.equal("Note: 50% done", Details()[1])
            assert.are.equal("Only 100% counts, %s said", Details()[2])
        end)
    end)

    describe("a level", function()
        it("should show when it was reached, how long after the one before, and the quests completed on the way", function()
            Questie.db.char.journey = {
                {Event = "Level", NewLevel = 2, Timestamp = FEBRUARY},
                {Event = "Quest", SubType = "Complete", Quest = 7, Timestamp = FEBRUARY + 3600},
                {Event = "Quest", SubType = "Complete", Quest = 404, Timestamp = FEBRUARY + 7200},
                {Event = "Level", NewLevel = 3, Timestamp = FEBRUARY + 5.5 * 3600},
            }

            Open()

            assert.are_same({
                "Level 3",
                "day " .. (FEBRUARY + 5.5 * 3600) .. " at 12:00",
                "5.5 hours after level 2",
                "Quests completed on the way   2",
                "404",
                "Quest 7",
            }, Details())
        end)

        it("should count days once it took two of them", function()
            Questie.db.char.journey = {
                {Event = "Level", NewLevel = 2, Timestamp = JANUARY},
                {Event = "Level", NewLevel = 3, Timestamp = FEBRUARY},
            }

            Open()

            assert.are.equal("32 days after level 2", Details()[3])
        end)

        it("should lead to the quests completed on the way", function()
            local opened = {}
            QuestieLoader:ImportModule("JourneyWindow").OpenLink = function(kind, id) table.insert(opened, {kind, id}) end
            Questie.db.char.journey = {
                {Event = "Quest", SubType = "Complete", Quest = 7, Timestamp = FEBRUARY},
                {Event = "Level", NewLevel = 3, Timestamp = FEBRUARY + 60},
            }
            Open()

            local rows = ui.Rows(canvas, 2)
            rows[#rows].elementData.onClick()

            assert.are_same({{"quest", 7}}, opened)
        end)
    end)

    describe("the selected entry", function()
        before_each(function()
            Open()
            Click("Quest 7")
        end)

        it("should not be scrolled to when something was added", function()
            ui.visibleRows = 2
            myJourney.Refresh()
            local list = ui.FindByTemplate(canvas, "WowScrollBoxList")[1]
            list:ScrollToElementDataIndex(5)
            assert.are_same({"404", "Quest 7"}, ListTexts())
            table.insert(journey, {Event = "Level", NewLevel = 4, Timestamp = FEBRUARY + 180})

            myJourney.Refresh()

            -- The list stays where it was scrolled to, while the selected entry moves down out of sight
            assert.are.equal(4, list.firstIndex)
            assert.are_same({"Level 3", "404"}, ListTexts())
        end)

        it("should stay selected when something was added", function()
            table.insert(journey, {Event = "Level", NewLevel = 4, Timestamp = FEBRUARY + 180})

            myJourney.Refresh()

            assert.are_same({"Quest 7"}, SelectedTexts())
            assert.are_same({"The details of quest 7"}, Details())
        end)

        it("should stay selected when an entry before it was deleted, which changes its index", function()
            table.remove(journey, 3)

            myJourney.Refresh()

            assert.are_same({"Quest 7"}, SelectedTexts())
            assert.are_same({"The details of quest 7"}, Details())
        end)

        it("should be replaced by the newest entry once it was deleted", function()
            table.remove(journey, 4)

            myJourney.Refresh()

            assert.are_same({"Level 3"}, SelectedTexts())
            assert.are.equal("Level 3", Details()[1])
        end)

        it("should be replaced by the newest entry of another journey that was imported", function()
            Questie.db.char.journey = {{Event = "Level", NewLevel = 60, Timestamp = FEBRUARY}}

            myJourney.Refresh()

            assert.are_same({"Level 60"}, SelectedTexts())
            assert.are_same({"February 2026", "Monday, February 2", "Level 60"}, ListTexts())
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
