dofile("setupTests.lua")

local FakeUI = dofile("cli/testData/options/FakeUI.lua")
local LoadQuestieDBMock = dofile("test/QuestieDBMock.lua")

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
    local NOTE_ICON = "Interface\\Buttons\\UI-GuildButton-PublicNote-Up"
    local ELWYNN = 12
    local GLOBALS = {
        "Questie", "GetUnitName", "UnitLevel", "UnitClassBase", "date", "time", "YES", "NO", "IsModifiedClick",
        "CALENDAR_FULLDATE_MONTH_NAMES", "ERR_QUEST_ACCEPTED_S", "ERR_QUEST_COMPLETE_S", "UnitFactionGroup", "GetRealmName",
        "CALENDAR_WEEKDAY_NAMES", "LibQuestieDB",
    }
    -- Blizzard's texts the Journey shows, in English
    local GLOBAL_STRINGS = {
        ALL = "All", BATTLEGROUNDS = "Battlegrounds", CLASS = "Class", COMBAT_XP_GAIN = "Experience", DUNGEONS = "Dungeons",
        HISTORY = "History", ITEM_MIN_LEVEL = "Requires Level %d", LFG_TYPE_DUNGEON = "Dungeon", QUEST_LOG = "Quest Log",
        QUEST_TOOLTIP_ACTIVE = "You are on this quest", QUEST_WATCH_QUEST_READY = "Ready for turn-in", REPUTATION = "Reputation",
        REWARDS = "Rewards", SEARCH = "Search", OVERVIEW = "Overview", WORLD = "World", CHARACTER = "Character", OTHER = "Other",
        BUG_CATEGORY4 = "Cities",
    }
    for name in pairs(GLOBAL_STRINGS) do table.insert(GLOBALS, name) end

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
        -- Every quest sort the Journey asks for has an ID of its own, as in the database
        local sortIds = 1000
        QuestieDB.sortKeys = setmetatable({}, {__index = function(keys, name)
            sortIds = sortIds + 1
            rawset(keys, name, -sortIds)
            return -sortIds
        end})
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
        QuestieDB.IsTrivial = function() return false end
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
        ZoneDB.GetParentZoneId = function() return nil end
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
        Import("QuestXP").GetQuestLogRewardXP = function() return 0 end
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
                char = {complete = {}, hidden = {}, journey = {}, collapsedQuests = {}, journeyWindow = {quests = {}, history = {}}},
                profile = {},
                global = {unavailableQuestsDeterminedByTalking = {}, unavailableDailyQuestsByNpc = {}},
            },
            -- Any other icon is its name
            icons = setmetatable({complete = "question mark", incomplete = "gray question mark"}, {__index = function(_, name) return name end}),
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
        _G.CALENDAR_WEEKDAY_NAMES = {"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"}
        for name, text in pairs(GLOBAL_STRINGS) do _G[name] = text end
        for month = 1, 12 do _G.CALENDAR_FULLDATE_MONTH_NAMES[month] = "Month " .. month end

        dofile("Modules/Libs/QuestieLoader.lua")
        dofile("Localization/l10n.lua")
        LoadQuestieDBMock()
        MockWhatIsNotTheJourney()
        for _, path in ipairs({
            "Libs/utf8", "Libs/ThreadLib", "Quest/ActiveQuests", "Options/QuestieOptionsUtils", "Options/QuestieOptionsWindow",
            "Options/QuestieOptionsControls",
            -- The Journey, in the order of the TOC files
            "Journey/Data/JourneyData", "Journey/Data/JourneyPrerequisites", "Journey/QuestieJourney", "Journey/Data/JourneyThread",
            "Journey/Window/JourneyWindow", "Journey/Window/JourneyPanes", "Journey/Window/JourneyScrollBox", "Journey/Window/JourneyIcon", "Journey/Details/JourneyNameColors",
            "Journey/Window/JourneyList", "Journey/Window/JourneyTree", "Journey/Details/JourneyDetails", "Journey/Details/JourneyLinks", "Journey/Details/JourneyLinkInput",
            "Journey/Details/ManualNotes", "Journey/Details/JourneyRawData", "Journey/Details/JourneyEntityDetails", "Journey/Details/JourneyItemDetails",
            "Journey/Data/JourneyQuestCategories",
            "Journey/Window/JourneyPicker", "Journey/Data/JourneyPlaces", "Journey/Data/JourneySummary", "Journey/Data/JourneyZoneLevels",
            "Journey/Data/JourneyFactions", "Journey/tabs/Quests/JourneyPage", "Journey/tabs/Quests/JourneyQuestsPage", "Journey/tabs/Quests/JourneyResultsPage",
            "Journey/tabs/Quests/JourneyOverviewRows", "Journey/tabs/Quests/JourneyOverviewPage", "Journey/tabs/Quests/JourneyTabBar", "Journey/Details/QuestieJourneyUtils",
            "Journey/Data/QuestieJourneyFactions",
            "Journey/tabs/MyJourney/History", "Journey/Details/JourneyQuestDetails", "Journey/tabs/MyJourney/Note", "Journey/tabs/MyJourney/MyJourney",
            "Journey/tabs/MyJourney/MyJourneyTab", "Journey/Data/QuestieSearch", "Journey/tabs/Quests/QuestsTab",
            "Quest/AvailableQuests/AvailableQuests", "Quest/QuestieQuest", "EventHandler/QuestEventHandler", "EventHandler/EventHandler",
        }) do
            dofile("Modules/" .. path .. ".lua")
        end

        QuestieJourney, QuestieQuest, AvailableQuests = Import("QuestieJourney"), Import("QuestieQuest"), Import("AvailableQuests")
        AvailableQuests.Initialize()
        QuestieJourney.continents = {[QuestieJourney.questCategoryKeys.EASTERN_KINGDOMS] = "Eastern Kingdoms"}
        QuestieJourney.zones = {[QuestieJourney.questCategoryKeys.EASTERN_KINGDOMS] = {[ELWYNN] = "Elwynn Forest"}}
        QuestieJourney.zoneMap = {[ELWYNN] = {[WOLVES] = true, [KOBOLDS] = true}}
        QuestieJourney.factionMap = {}
    end)

    after_each(function()
        for _, name in ipairs(GLOBALS) do _G[name] = originals[name] end
        ui.Restore()
    end)

    ---@return table list The first list of quests on screen, rather than a page of details
    local function VisibleList()
        local window = ui.FindByTemplate(UIParent, "PortraitFrameTemplate")[1]
        for _, list in ipairs(ui.FindByTemplate(window, "WowScrollBoxList")) do
            if list:IsVisible() and list.rowFrames[1] and list.rowFrames[1].Toggle then
                return list
            end
        end
    end

    ---@param tabKey string
    local function Open(tabKey)
        QuestieJourney.OpenTab(tabKey)
        ui.RunUntilIdle()
    end

    ---@param source string Like "zone:12"
    local function OpenSource(source)
        QuestieJourney.OpenSource(source)
        ui.RunUntilIdle()
    end

    local COLLAPSED = {["Interface\\Buttons\\UI-PlusButton-Up"] = true, ["common-button-dropdown-closed"] = true}

    ---Expands every category.
    ---@return string[] lines "icon text"
    local function List()
        ui.RunUntilIdle()
        for _, row in ipairs(VisibleList().rowFrames) do
            if row.Toggle:IsShown() and (COLLAPSED[row.Toggle.texture] or COLLAPSED[row.Toggle.atlas]) then
                row:Click()
                return List()
            end
        end
        local lines = {}
        for _, row in ipairs(VisibleList().rowFrames) do
            local icon = row.Icon:IsShown() and (row.Icon.atlas or row.Icon:GetTexture()) .. " " or ""
            table.insert(lines, icon .. row.Label:GetText())
        end
        return lines
    end

    ---@param text string
    local function ClickRow(text)
        for _, row in ipairs(VisibleList().rowFrames) do
            if row.Label:GetText() == text then
                return row:Click()
            end
        end
        error("There is no row " .. text)
    end

    ---@return string[]
    local function SelectedTexts()
        local texts = {}
        for _, row in ipairs(VisibleList().rowFrames) do
            if row.Background:IsShown() and row.Background.atlas == "Options_List_Active" then
                table.insert(texts, row.Label:GetText())
            end
        end
        return texts
    end

    it("should move quests that were completed, and those that can't be done anymore because of it", function()
        OpenSource("zone:" .. ELWYNN)
        assert.are_same({"Available Quests", "available Wolves", "available Kobolds"}, List())
        ClickRow("Wolves")

        Questie.db.char.complete[WOLVES] = true
        AvailableQuests.CalculateAndDrawAll()

        assert.are_same({"Completed Quests", "checkmark Wolves", "Unobtainable Quests", "cross Kobolds"}, List())
        assert.are_same({"Wolves"}, SelectedTexts())
    end)

    it("should show in the search what was completed", function()
        Open("search")
        ui.focus:SetText("wolves")
        assert.are_same({"Quests", "available Wolves"}, List())

        Questie.db.char.complete[WOLVES] = true
        AvailableQuests.CalculateAndDrawAll()

        assert.are_same({"Quests", "checkmark Wolves"}, List())
    end)

    it("should show that a quest was hidden, on the map or in its details", function()
        OpenSource("zone:" .. ELWYNN)
        List()

        QuestieQuest:HideQuest(WOLVES)
        -- Still where it was, and among the hidden ones too
        assert.are_same({
            "Available Quests", "transmog-icon-hidden Wolves", "available Kobolds", "Hidden Quests", "transmog-icon-hidden Wolves",
        }, List())

        ClickRow("Wolves")
        local button = ui.FindAll(ui.FindByTemplate(UIParent, "PortraitFrameTemplate")[1], function(frame)
            return frame.Text ~= nil and frame.Text.text == "Show on map again" and frame:IsVisible()
        end)[1]
        button:Click()
        assert.are_same({"Available Quests", "available Wolves", "available Kobolds"}, List())
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
        assert.are_same({"Quest Log", "gray question mark Wolves", "Available Quests", "available Kobolds"}, List())

        questLog[WOLVES] = 1
        QuestEventHandler.QuestWatchUpdate(WOLVES)
        QuestEventHandler.QuestLogUpdate()

        assert.are_same({"Quest Log", "question mark Wolves", "Available Quests", "available Kobolds"}, List())
    end)

    it("should list what was added to the journey, and what was deleted from it", function()
        Open("journey")
        QuestieJourney:AcceptQuest(WOLVES)
        -- Below the month and the day
        assert.are.equal("available Wolves", List()[3])

        local note = {Event = "Note", Title = "Remember", Note = "The wolves", Timestamp = os.time()}
        table.insert(Questie.db.char.journey, note)
        QuestieJourney:PlayerLevelUp(11)
        assert.are_same({"fav Level 11", NOTE_ICON .. " Remember", "available Wolves"}, {List()[3], List()[4], List()[5]})
        Import("QuestiePopup").Dialogs.QUESTIE_DELETE_NOTE_CONFIRM.OnAccept({data = note})

        assert.are_same({"fav Level 11", "available Wolves"}, {List()[3], List()[4]})
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
