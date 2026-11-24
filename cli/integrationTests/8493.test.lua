dofile("setupTests.lua")

local FakeUI = dofile("cli/testData/options/FakeUI.lua")

-- Issue references:
-- https://github.com/Questie/Questie/issues/8493

-- Runs the Journey's window, its zone, search and My Journey tabs, and what tells them what changed, without mocking any of
-- their functions. The unit tests do, so they don't notice when one of those isn't there anymore.
describe("Issue 8493 - The open Journey shows what changed", function()
    local ui, originals
    ---@type QuestieJourney
    local QuestieJourney
    ---@type QuestieQuest
    local QuestieQuest
    ---@type AvailableQuests
    local AvailableQuests
    ---@type QuestieCorrections
    local QuestieCorrections
    local events, questLog

    local WOLVES, KOBOLDS = 7, 8 -- Only one of them can be done
    local ELWYNN = 12
    local GLOBALS = {
        "Questie", "GetUnitName", "UnitLevel", "UnitClassBase", "date", "time", "YES", "NO", "IsModifiedClick",
        "CALENDAR_FULLDATE_MONTH_NAMES", "ERR_QUEST_ACCEPTED_S", "ERR_QUEST_COMPLETE_S", "UnitFactionGroup", "GetRealmName",
    }

    ---@param name string
    ---@return table module
    local function Import(name)
        return QuestieLoader:ImportModule(name)
    end

    local function MockWhatIsNotTheJourney()
        local QuestieDB = Import("QuestieDB")
        QuestieDB.DoableStates = {AVAILABLE = 1, COMPLETED = 2, QUEST_LOG = 3, EXCLUSIVE_COMPLETED = 4}
        QuestieDB.QuestPointers = {[WOLVES] = true, [KOBOLDS] = true}
        QuestieDB.NPCPointers, QuestieDB.ObjectPointers, QuestieDB.ItemPointers = {}, {}, {}
        QuestieDB.questKeys, QuestieDB.raceKeys, QuestieDB.autoBlacklist = {}, {ALL_ALLIANCE = 77, ALL_HORDE = 178}, {}
        QuestieDB.sortKeys = {}
        local names = {[WOLVES] = "Wolves", [KOBOLDS] = "Kobolds"}
        local fields = {requiredLevel = 8, questLevel = 10}
        QuestieDB.QueryQuestSingle = function(id, field) return field == "name" and names[id] or fields[field] end
        QuestieDB.QueryQuest = function() return {0} end
        QuestieDB.GetQuest = function(id)
            return {Id = id, name = names[id], Description = {"Kill them."}, IsComplete = function() return 0 end}
        end
        QuestieDB.GetZoneOrSortForClass = function() return -161 end
        QuestieDB.IsComplete = function(id) return questLog[id] end
        for _, name in ipairs({"IsRepeatable", "IsDailyQuest", "IsWeeklyQuest", "IsPvPQuest", "IsDungeonQuest", "IsRaidQuest", "IsActiveEventQuest"}) do
            QuestieDB[name] = function() return false end
        end
        QuestieDB.IsDoable = function() return false end
        QuestieDB.IsDoableVerbose = function(id)
            local complete = Questie.db.char.complete
            local state = complete[id] and "COMPLETED" or questLog[id] and "QUEST_LOG"
                or id == KOBOLDS and complete[WOLVES] and "EXCLUSIVE_COMPLETED" or "AVAILABLE"
            return "", false, QuestieDB.DoableStates[state]
        end

        QuestieCorrections = Import("QuestieCorrections")
        QuestieCorrections.hiddenQuests, QuestieCorrections.questItemBlacklist = {}, {}
        Import("QuestieQuestBlacklist").AQWarEffortQuests = {}
        Import("IsleOfQuelDanas").quests = {}
        Import("QuestieCompat").GetQuestGreenRange = function() return 5 end
        local QuestiePlayer = Import("QuestiePlayer")
        QuestiePlayer.HasRequiredRace = function() return true end
        QuestiePlayer.GetPlayerLevel = function() return 10 end
        QuestiePlayer.GetCurrentContinentId = function() return 0 end
        QuestiePlayer.GetCurrentZoneId = function() return ELWYNN end
        local ZoneDB = Import("ZoneDB")
        ZoneDB.private.subZoneToParentZoneOverride = "return {}"
        ZoneDB.GetDungeons = function() return {} end
        local QuestieLib = Import("QuestieLib")
        QuestieLib.GetColoredQuestName = function(_, id) return names[id] end
        QuestieLib.DidDailyResetHappenSinceLastLogin = function() return false end
        QuestieLib.FormatDate = function() return "today" end
        QuestieLib.GetEffectiveQuestLevel = function() return 10 end
        QuestieLib.GetRaceString = function() return "" end
        QuestieLib.GetClassString = function() return "" end
        QuestieLib.SortQuestIDsByLevel = function(_, quests)
            local sorted = {}
            for id in pairs(quests) do table.insert(sorted, {10, id}) end
            table.sort(sorted, function(a, b) return a[2] < b[2] end)
            return sorted
        end
        Import("QuestieReputation").GetReputationReward = function() end
        Import("AvailableQuests").IsLevelRequirementsFulfilled = function() return false end -- Nothing is drawn on the map
        Import("QuestieMap").GetFramesForQuest = function() return {} end
        Import("QuestieMap").UnloadQuestFrames = function() end
        Import("QuestieMap").questIdFrames = {}
        Import("QuestieTooltips").RemoveQuest = function() end
        Import("CommsVisibility").ScheduleSnapshot = function() end
        Import("QuestieOptionsEngine").RefreshStates = function() end
        Import("QuestiePopup").Dialogs = {}
        Import("QuestieEvent").IsEventQuest = function() return false end
        Import("CompletedQuests").Update = function() end
        Import("PetFood").IsNeeded = function() return false end
        Import("DailyQuests").ShouldBeHidden = function() return false end
        Import("QuestieCompat").IsSuperTrackingSupported = function() return false end
        Import("TrackerRecipes").IsSupported = function() return false end
        local Expansions = Import("Expansions")
        Expansions.Era, Expansions.Tbc, Expansions.Wotlk, Expansions.Cata, Expansions.MoP, Expansions.Current = 1, 2, 3, 4, 5, 1
    end

    before_each(function()
        ui = FakeUI.Install()
        originals = {}
        for _, name in ipairs(GLOBALS) do originals[name] = _G[name] end

        questLog, events = {}, {}
        _G.Questie = {
            started = true,
            db = {
                char = {complete = {}, hidden = {}, journey = {}, collapsedQuests = {}},
                profile = {},
                global = {unavailableQuestsDeterminedByTalking = {}, unavailableDailyQuestsByNpc = {}},
            },
            icons = {checkmark = "checkmark", cross = "cross", complete = "question mark", incomplete = "gray question mark"},
            Colorize = function(_, text) return text end,
            Debug = function() end,
            Error = function(_, message) error(message) end,
            Print = function() end,
            RegisterEvent = function(_, event, callback) events[event] = callback end,
            RegisterBucketEvent = function() end,
            RegisterMessage = function() end,
            RegisterBucketMessage = function() end,
            SendMessage = function() end,
        }
        _G.GetUnitName = function() return "Thrall" end
        _G.UnitLevel = function() return 10 end
        _G.UnitClassBase = function() return "MAGE" end
        _G.UnitFactionGroup, _G.GetRealmName = function() return "Horde" end, function() return "Realm" end
        _G.date, _G.time = os.date, os.time
        _G.YES, _G.NO = "Yes", "No"
        _G.IsModifiedClick = function() return false end
        _G.ERR_QUEST_ACCEPTED_S, _G.ERR_QUEST_COMPLETE_S = "Quest accepted: %s", "Quest completed: %s"
        _G.CALENDAR_FULLDATE_MONTH_NAMES = {}
        for month = 1, 12 do _G.CALENDAR_FULLDATE_MONTH_NAMES[month] = "Month " .. month end

        dofile("Modules/Libs/QuestieLoader.lua")
        dofile("Localization/l10n.lua")
        MockWhatIsNotTheJourney()
        for _, path in ipairs({
            "Libs/utf8", "Libs/ThreadLib", "Quest/ActiveQuests", "Options/QuestieOptionsUtils", "Options/QuestieOptionsWindow",
            "Options/QuestieOptionsControls", "Journey/QuestieJourney", "Journey/JourneyThread", "Journey/JourneyWindow",
            "Journey/JourneyPanes", "Journey/JourneyScrollBox", "Journey/JourneyIcon", "Journey/JourneyList", "Journey/JourneyTree",
            "Journey/JourneyResultList", "Journey/JourneyDetails", "Journey/JourneyLinks", "Journey/JourneyLinkInput",
            "Journey/ManualNotes", "Journey/JourneyRawData", "Journey/JourneyEntityDetails", "Journey/JourneyQuestList",
            "Journey/QuestieJourneyUtils", "Journey/History", "Journey/JourneyPrerequisites", "Journey/JourneyQuestDetails",
            "Journey/tabs/MyJourney/Note", "Journey/tabs/MyJourney/MyJourney", "Journey/tabs/MyJourney/MyJourneyTab",
            "Journey/tabs/QuestsByZone/QuestsByZone", "Journey/tabs/QuestsByZone/QuestsByZoneTab", "Journey/QuestieSearch",
            "Journey/tabs/Search/SearchTab", "Quest/AvailableQuests/AvailableQuests", "Quest/QuestieQuest",
            "EventHandler/QuestEventHandler", "EventHandler/EventHandler",
        }) do
            dofile("Modules/" .. path .. ".lua")
        end

        QuestieJourney, QuestieQuest, AvailableQuests = Import("QuestieJourney"), Import("QuestieQuest"), Import("AvailableQuests")
        AvailableQuests.Initialize()
        QuestieJourney.continents = {[QuestieJourney.questCategoryKeys.EASTERN_KINGDOMS] = "Eastern Kingdoms"}
        QuestieJourney.zones = {[QuestieJourney.questCategoryKeys.EASTERN_KINGDOMS] = {[ELWYNN] = "Elwynn Forest"}}
        QuestieJourney.zoneMap = {[ELWYNN] = {[WOLVES] = true, [KOBOLDS] = true}}
    end)

    after_each(function()
        for _, name in ipairs(GLOBALS) do _G[name] = originals[name] end
        ui.Restore()
    end)

    ---@return table canvas Of the tab that is shown
    local function Canvas()
        local window = ui.FindByTemplate(UIParent, "PortraitFrameTemplate")[1]
        for _, canvas in ipairs(window.canvasContainer.children) do
            if canvas:IsVisible() and #ui.FindByTemplate(canvas, "WowScrollBoxList") > 0 then
                return canvas
            end
        end
    end

    ---@param tabKey string
    local function Open(tabKey)
        QuestieJourney.OpenTab(tabKey)
        ui.RunUntilIdle()
    end

    ---Expands every category.
    ---@return string[] lines "icon text"
    local function List()
        ui.RunUntilIdle()
        for _, row in ipairs(ui.Rows(Canvas(), 1)) do
            if row.Toggle:IsShown() and row.Toggle.atlas == "common-button-dropdown-closed" then
                row:Click()
                return List()
            end
        end
        local lines = {}
        for _, row in ipairs(ui.Rows(Canvas(), 1)) do
            local icon = row.Icon:IsShown() and (row.Icon.atlas or row.Icon:GetTexture()) .. " " or ""
            table.insert(lines, icon .. row.Label:GetText())
        end
        return lines
    end

    it("should move quests that were completed, and those that can't be done anymore because of it", function()
        Open("zone")
        assert.are_same({"Available Quests [ 2/2 ]", "Wolves", "Kobolds"}, List())
        ui.ClickRow(Canvas(), 1, "Wolves")

        Questie.db.char.complete[WOLVES] = true
        AvailableQuests.CalculateAndDrawAll()

        assert.are_same({"Completed Quests [ 1/1 ]", "checkmark Wolves", "Unobtainable Quests [ 1 ]", "Kobolds"}, List())
        assert.are_same({"Wolves"}, ui.SelectedRowTexts(Canvas(), 1))
    end)

    it("should show in the search what was completed", function()
        Open("search")
        ui.focus:SetText("wolves")
        assert.are_same({"Wolves"}, List())

        Questie.db.char.complete[WOLVES] = true
        AvailableQuests.CalculateAndDrawAll()

        assert.are_same({"checkmark Wolves"}, List())
    end)

    it("should show that a quest was hidden, on the map or in its details", function()
        Open("zone")
        List()

        QuestieQuest:HideQuest(WOLVES)
        assert.are_same({
            "Available Quests [ 2/2 ]", "transmog-icon-hidden Wolves", "Kobolds", "Hidden Quests [ 1 ]", "transmog-icon-hidden Wolves",
        }, List())

        ui.ClickRow(Canvas(), 1, "Wolves")
        local checkbox = ui.FindAll(Canvas(), function(frame)
            return frame.titleFrame ~= nil and frame.titleFrame.text == "Hide from map" and frame:IsVisible()
        end)[1].widget
        assert.is_true(checkbox:GetChecked())
        checkbox:Click()
        assert.are_same({"Available Quests [ 2/2 ]", "Wolves", "Kobolds"}, List())
    end)

    it("should show that a quest is ready to turn in", function()
        local QuestEventHandler, QuestLogCache = Import("QuestEventHandler"), Import("QuestLogCache")
        Import("ActiveQuests").Add(WOLVES, {})
        questLog[WOLVES] = 0
        QuestLogCache.CheckForChanges = function() return false, {[WOLVES] = {}} end
        QuestieQuest.SetObjectivesDirty = function() end
        Import("QuestLifecycle").UpdateQuest = function() end
        Import("QuestieNameplate").UpdateNameplate = function() end
        Import("QuestieTracker").UpdateQuestLines = function() end
        Import("QuestiePartyObjectives").ScheduleUpdate = function() end
        Import("QuestieAPI").Enums = {QuestUpdateTriggerReason = {}}
        Import("QuestieAPI").PropagateQuestUpdate = function() end
        Import("QuestieCombatQueue").Queue = function() end
        Open("zone")
        assert.are_same({"Available Quests [ 2/2 ]", "gray question mark Wolves", "Kobolds"}, List())

        questLog[WOLVES] = 1
        QuestEventHandler.QuestWatchUpdate(WOLVES)
        QuestEventHandler.QuestLogUpdate()

        assert.are_same({"Available Quests [ 2/2 ]", "question mark Wolves", "Kobolds"}, List())
    end)

    it("should list what was added to the journey, and what was deleted from it", function()
        Open("journey")
        QuestieJourney:AcceptQuest(WOLVES)
        assert.are.equal("Quest Accepted: Wolves", List()[3])

        local note = {Event = "Note", Title = "Remember", Note = "The wolves", Timestamp = os.time()}
        table.insert(Questie.db.char.journey, note)
        QuestieJourney:PlayerLevelUp(11)
        assert.are.equal("Note: Remember", List()[4])
        Import("QuestiePopup").Dialogs.QUESTIE_DELETE_NOTE_CONFIRM.OnAccept({data = note})

        assert.are_same({"You Reached Level 11", "Quest Accepted: Wolves"}, {List()[3], List()[4]})
    end)

    it("should come back after combat as it was", function()
        local QuestieTracker = Import("QuestieTracker")
        QuestieTracker.HandleCombatStarted, QuestieTracker.HandleCombatEnded = function() end, function() end
        Import("EventHandler"):RegisterLateEvents()
        Open("search")
        ui.focus:ClearFocus()

        events.PLAYER_REGEN_DISABLED()
        assert.is_false(QuestieJourney:IsShown())

        events.PLAYER_REGEN_ENABLED()
        assert.is_true(QuestieJourney:IsShown())
        assert.is_nil(ui.focus)
    end)
end)
