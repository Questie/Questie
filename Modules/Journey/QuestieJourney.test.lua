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
    -- Globals replaced by a test, with what they were before
    local stubbed

    ---@param name string
    ---@param value any
    local function Stub(name, value)
        if not stubbed[name] then
            stubbed[name] = {value = _G[name]}
        end
        _G[name] = value
    end

    before_each(function()
        stubbed = {}
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
        for name, original in pairs(stubbed) do
            _G[name] = original.value
        end
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

    -- Combat closes the window (EventHandler), and nothing opens it until combat is over
    describe("in combat", function()
        local errors

        before_each(function()
            errors = {}
            Stub("UIErrorsFrame", {AddMessage = function(_, text) table.insert(errors, text) end})
            Stub("ERR_NOT_IN_COMBAT", "You can't do that while in combat")
        end)

        for situation, enterCombat in pairs({
            ["the lockdown"] = function() Stub("InCombatLockdown", function() return true end) end,
            -- The lockdown of a combat the player logged in to only starts after the login
            ["a combat logged in to"] = function() Stub("UnitAffectingCombat", function(unit) return unit == "player" end) end,
        }) do
            for name, open in pairs({
                ToggleJourneyWindow = function() QuestieJourney:ToggleJourneyWindow() end,
                OpenTab = function() QuestieJourney.OpenTab("search") end,
                OpenSource = function() QuestieJourney.OpenSource("zone:12") end,
            }) do
                it("should not open the window with " .. name .. " during " .. situation, function()
                    enterCombat()

                    open()

                    assert.is_false(QuestieJourney:IsShown())
                    assert.are_same({}, openedTabs)
                    assert.are_same({"You can't do that while in combat"}, errors)
                end)
            end
        end
    end)

    describe("SetupKeybinding", function()
        local bindings, inCombat, waiter

        before_each(function()
            Questie.db.global.journeyKeybindDefaultApplied = nil
            Questie.Debug = function() end
            bindings, inCombat, waiter = {}, false, nil
            Stub("GetBindingKey", function(action) for key, bound in pairs(bindings) do if bound == action then return key end end end)
            Stub("C_KeyBindings", {GetBindingByKey = function() return nil end})
            Stub("SetBinding", function(key, action)
                assert.is_false(inCombat, "SetBinding is blocked in combat")
                bindings[key] = action
            end)
            Stub("InCombatLockdown", function() return inCombat end)
            Stub("CreateFrame", function()
                waiter = {events = {}}
                function waiter:RegisterEvent(event) self.events[event] = true end
                function waiter:UnregisterEvent(event) self.events[event] = nil end
                function waiter:SetScript(_, handler) self.OnEvent = handler end
                return waiter
            end)
        end)

        it("should bind ; to the Journey once", function()
            QuestieJourney:SetupKeybinding()
            assert.are_same({SEMICOLON = "QUESTIE_TOGGLE_JOURNEY"}, bindings)

            -- The player took the key away, which is left as it is
            bindings = {}
            QuestieJourney:SetupKeybinding()
            assert.are_same({}, bindings)
        end)

        it("should wait until a combat the player logged in to is over", function()
            inCombat = true
            QuestieJourney:SetupKeybinding()

            assert.are_same({}, bindings)
            -- A reload before that tries again
            assert.is_nil(Questie.db.global.journeyKeybindDefaultApplied)

            inCombat = false
            waiter:OnEvent("PLAYER_REGEN_ENABLED")

            assert.are_same({SEMICOLON = "QUESTIE_TOGGLE_JOURNEY"}, bindings)
            assert.is_true(Questie.db.global.journeyKeybindDefaultApplied)
            assert.are_same({}, waiter.events)
        end)
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
