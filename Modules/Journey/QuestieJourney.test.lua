dofile("setupTests.lua")

local LOADING_MESSAGE = "Please wait a moment for Questie to finish loading"

describe("QuestieJourney", function()
    ---@type QuestieJourney
    local QuestieJourney
    ---@type JourneyWindow
    local JourneyWindow
    ---@type CompletedQuests
    local CompletedQuests
    local originalQuestie, originalPrint
    local isShown, openedTabs, printed

    before_each(function()
        originalQuestie, originalPrint = _G.Questie, _G.print
        _G.Questie = {
            started = true,
            db = {char = {guid = "Player-1"}, global = {journeyKeybindDefaultApplied = true}, profile = {}},
            Colorize = function(_, text) return text end,
        }
        printed = {}
        _G.print = function(text) table.insert(printed, text) end

        dofile("Modules/Libs/QuestieLoader.lua")
        dofile("Modules/Expansions.lua")
        dofile("Localization/l10n.lua")
        CompletedQuests = QuestieLoader:ImportModule("CompletedQuests")
        CompletedQuests.Update = spy.new(function() end)

        isShown, openedTabs = false, {}
        JourneyWindow = QuestieLoader:ImportModule("JourneyWindow")
        JourneyWindow.Show = function(tabKey)
            isShown = true
            table.insert(openedTabs, tabKey or "the last one")
        end
        JourneyWindow.Hide = function() isShown = false end
        JourneyWindow.IsShown = function() return isShown end

        dofile("Modules/Journey/QuestieJourney.lua")
        QuestieJourney = QuestieLoader:ImportModule("QuestieJourney")
    end)

    after_each(function()
        _G.Questie, _G.print = originalQuestie, originalPrint
    end)

    describe("ToggleJourneyWindow", function()
        it("should open the window on the last tab, and close it again", function()
            QuestieJourney:ToggleJourneyWindow()
            assert.is_true(QuestieJourney:IsShown())
            assert.are_same({"the last one"}, openedTabs)

            QuestieJourney:ToggleJourneyWindow()
            assert.is_false(QuestieJourney:IsShown())
            assert.are_same({"the last one"}, openedTabs)
        end)

        it("should look for quests the game completed before it shows the window", function()
            local wasUpdatedBeforeShowing
            local show = JourneyWindow.Show
            JourneyWindow.Show = function(tabKey)
                wasUpdatedBeforeShowing = #CompletedQuests.Update.calls == 1
                show(tabKey)
            end

            QuestieJourney:ToggleJourneyWindow()

            assert.is_true(wasUpdatedBeforeShowing)
        end)

        it("should not look for them when it closes the window, or shows another tab of it", function()
            QuestieJourney:ToggleJourneyWindow()
            QuestieJourney.OpenTab("journey")
            QuestieJourney:ToggleJourneyWindow()

            assert.spy(CompletedQuests.Update).was.called(1)
        end)
    end)

    -- The binding and the menus work before the data for the tabs is ready
    describe("while Questie is loading", function()
        before_each(function()
            Questie.started = false
        end)

        for name, open in pairs({
            ToggleJourneyWindow = function() QuestieJourney:ToggleJourneyWindow() end,
            OpenTab = function() QuestieJourney.OpenTab("search") end,
        }) do
            it("should ask to wait instead of opening the window with " .. name, function()
                open()

                assert.is_false(QuestieJourney:IsShown())
                assert.are_same({LOADING_MESSAGE}, printed)
            end)
        end
    end)

    describe("what happens", function()
        local entriesAtRefresh

        before_each(function()
            _G.time = os.time
            Questie.db.char.journey = {}
            QuestieLoader:ImportModule("QuestiePlayer").GetPlayerLevel = function() return 10 end
            entriesAtRefresh = {}
            JourneyWindow.Refresh = function()
                local entry = Questie.db.char.journey[#Questie.db.char.journey]
                table.insert(entriesAtRefresh, entry.SubType or entry.Event)
            end
        end)

        it("should show in the open window right away", function()
            QuestieJourney:AcceptQuest(7)
            QuestieJourney:AbandonQuest(7)
            QuestieJourney:CompleteQuest(7)
            QuestieJourney:PlayerLevelUp(11)

            assert.are_same({"Accept", "Abandon", "Complete", "Level"}, entriesAtRefresh)
        end)
    end)

    describe("Initialize", function()
        it("should prepare the data without opening the window", function()
            _G.UnitGUID = function() return "Player-1" end
            _G.CLASS = "Class"
            QuestieLoader:ImportModule("l10n").continentLookup = {}
            QuestieLoader:ImportModule("QuestiePlayer").GetLocalizedClassName = function() return "Warrior" end
            local zoneMap, zones = {[12] = {[1] = true}}, {[1] = {[12] = "Elwynn Forest"}}
            QuestieLoader:ImportModule("JourneyData").Build = function() return zoneMap, zones end
            local prepared = {}
            QuestieJourney.private.questsByFaction = {
                InitializeFactionData = function() table.insert(prepared, "factions") end,
                InitializeFactionQuestData = function() table.insert(prepared, "quests of factions") end,
            }

            local thread = coroutine.create(function() QuestieJourney:Initialize() end)
            while coroutine.status(thread) ~= "dead" do
                assert(coroutine.resume(thread))
            end

            -- The group of class quests is called like the others, not after the player's class
            assert.are.equal("Class", QuestieJourney.continents[QuestieJourney.questCategoryKeys.CLASS])
            assert.are.equal(zoneMap, QuestieJourney.zoneMap)
            assert.are.equal(zones, QuestieJourney.zones)
            assert.are_same({"factions", "quests of factions"}, prepared)
            assert.are_same({}, openedTabs)
        end)
    end)
end)
