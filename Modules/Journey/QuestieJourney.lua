---@class QuestieJourney
local QuestieJourney = QuestieLoader:ImportModule("QuestieJourney")
local _QuestieJourney = QuestieJourney.private
-------------------------
--Import modules.
-------------------------
---@type QuestiePlayer
local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
---@type JourneyData
local JourneyData = QuestieLoader:ImportModule("JourneyData")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")
---@type Expansions
local Expansions = QuestieLoader:ImportModule("Expansions")
---@type JourneyWindow
local JourneyWindow = QuestieLoader:ImportModule("JourneyWindow")
---@type CompletedQuests
local CompletedQuests = QuestieLoader:ImportModule("CompletedQuests")

local tinsert = table.insert

QuestieJourney.continents = {}
QuestieJourney.zones = {}

_QuestieJourney.questsByZone = {}

-- These need to match with l10n.continentLookup
local questCategoryKeys = {
    EASTERN_KINGDOMS = 1,
    KALIMDOR = 2,
    OUTLAND = 3,
    NORTHREND = 4,
    CATACLYSM = 5,
    THE_MAELSTROM = 6,
    PANDARIA = 7,
    ZEPHRAS_ISLE = 8,
    DUNGEONS = 9,
    BATTLEGROUNDS = 10,
    CLASS = 11,
    PROFESSIONS = 12,
    EVENTS = 13,
    PET_BATTLES = 14,
    SCENARIOS = 15,
}
QuestieJourney.questCategoryKeys = questCategoryKeys

-- Detect character re-creation and ask user about journey reset
local function checkForCharacterRecreation()
    local guid = UnitGUID("player") -- this is unique per character
    if (not Questie.db.char.guid) then
        -- First login for this character
        Questie.db.char.guid = guid
    elseif (Questie.db.char.guid ~= guid) then
        -- Character re-created, ask user about journey reset
        Questie:Print(l10n("Character re-creation detected, resetting \"My Journey\" data."))
        Questie.db.char.journey = {}
        Questie.db.char.guid = guid
    end
end

function QuestieJourney:Initialize()
    local continents = {}
    for id, name in pairs(l10n.continentLookup) do
        if not (questCategoryKeys.OUTLAND == id and Expansions.Current < Expansions.Tbc) and
            not (questCategoryKeys.NORTHREND == id and Expansions.Current < Expansions.Wotlk) and
            not (questCategoryKeys.CATACLYSM == id and Expansions.Current < Expansions.Cata) and
            not (questCategoryKeys.THE_MAELSTROM == id and Expansions.Current < Expansions.Cata) and
            not (questCategoryKeys.PANDARIA == id and Expansions.Current < Expansions.MoP) and
            not (questCategoryKeys.ZEPHRAS_ISLE == id and not Questie.IsForever) and
            not (questCategoryKeys.PET_BATTLES == id and Expansions.Current < Expansions.MoP) and
            not (questCategoryKeys.SCENARIOS == id and Expansions.Current < Expansions.MoP)
        then
            continents[id] = l10n(name)
        end
    end
    coroutine.yield()
    -- Like the professions, not the player's class. Blizzard's text, which every supported client has (checked in GlobalStrings).
    continents[questCategoryKeys.CLASS] = CLASS

    checkForCharacterRecreation()

    coroutine.yield()
    self.continents = continents
    -- Generate once here; tabs reuse these quest groups and dropdown choices instead of rescanning the database.
    self.zoneMap, self.zones = JourneyData.Build(true)
    coroutine.yield()

    -- Pre-initialize faction data used by the "Quests by Faction" tab so it is ready on first open.
    if _QuestieJourney.questsByFaction then
        if _QuestieJourney.questsByFaction.InitializeFactionData then
            _QuestieJourney.questsByFaction:InitializeFactionData()
        end
        if _QuestieJourney.questsByFaction.InitializeFactionQuestData then
            _QuestieJourney.questsByFaction:InitializeFactionQuestData()
        end
    end

    -- Set up default keybinding for Journey window
    self:SetupKeybinding()
end

---@return boolean
function QuestieJourney:IsShown()
    return JourneyWindow.IsShown()
end

---Opens the window on a tab.
---@param tabKey string? One of "journey", "zone", "faction" and "search". The tab that was shown last when nil.
function QuestieJourney.OpenTab(tabKey)
    -- Reachable while Questie is loading, before the data for the tabs is ready
    if (not Questie.started) then
        print(Questie:Colorize(l10n("Please wait a moment for Questie to finish loading")))
        return
    end

    if not JourneyWindow.IsShown() then
        -- Some quests are completed without any quest event
        CompletedQuests.Update()
    end
    JourneyWindow.Show(tabKey)
end

---Opens the window on the quests of a zone, a faction, and so on.
---@param source string? What is listed, like "zone:40". What was shown last when nil.
function QuestieJourney.OpenSource(source)
    QuestieJourney.OpenTab("quests")
    if source and JourneyWindow.IsShown() then
        _QuestieJourney.quests.OpenSource(source)
    end
end

function QuestieJourney:ToggleJourneyWindow()
    if JourneyWindow.IsShown() then
        JourneyWindow.Hide()
    else
        QuestieJourney.OpenTab()
    end
end

function QuestieJourney:SetupKeybinding()
    _G.BINDING_NAME_QUESTIE_TOGGLE_JOURNEY = l10n("Toggle My Journey")

    -- Only ever attempt to set the default keybind once, so we never fight a user who later changes or removes their bindings
    if Questie.db.global.journeyKeybindDefaultApplied then
        return
    end
    Questie.db.global.journeyKeybindDefaultApplied = true

    local currentBinding = GetBindingKey("QUESTIE_TOGGLE_JOURNEY")
    if not currentBinding and not C_KeyBindings.GetBindingByKey(";") then
        SetBinding("SEMICOLON", "QUESTIE_TOGGLE_JOURNEY")
        Questie.Debug(Questie.DEBUG_INFO, "Set default keybind ';' for Questie Journey")
    end
end

---@param entry JourneyEntry
local function _AddEntry(entry)
    tinsert(Questie.db.char.journey, entry)
    JourneyWindow.Refresh()
end

function QuestieJourney:PlayerLevelUp(level)
    -- Complete Quest added to Journey
    ---@class JourneyEntry
    ---@field Event string?
    ---@field SubType string?
    ---@field NewLevel number?
    ---@field Level number?
    ---@field Quest number?
    ---@field Timestamp number
    local entry = {
        Event = "Level",
        NewLevel = level,
        Timestamp = time()
    }

    _AddEntry(entry)
end

function QuestieJourney:AcceptQuest(questId)
    -- Add quest accept journey note.
    ---@type JourneyEntry
    local entry = {
        Event = "Quest",
        SubType = "Accept",
        Quest = questId,
        Level = QuestiePlayer.GetPlayerLevel(),
        Timestamp = time()
    }

    _AddEntry(entry)
end

function QuestieJourney:AbandonQuest(questId)
    -- Abandon Quest added to Journey
    -- first check to see if the quest has been completed already or not
    local skipAbandon = false
    for i in ipairs(Questie.db.char.journey) do
        local entry = Questie.db.char.journey[i]
        if entry.Event == "Quest" then
            if entry.Quest == questId then
                if entry.SubType == "Complete" then
                    skipAbandon = true
                end
            end
        end
    end

    if not skipAbandon then
        ---@type JourneyEntry
        local entry = {
            Event = "Quest",
            SubType = "Abandon",
            Quest = questId,
            Level = QuestiePlayer.GetPlayerLevel(),
            Timestamp = time()
        }

        _AddEntry(entry)
    end
end

function QuestieJourney:CompleteQuest(questId)
    -- Complete Quest added to Journey
    ---@class JourneyEntry
    local entry = {
        Event = "Quest",
        SubType = "Complete",
        Quest = questId,
        Level = QuestiePlayer.GetPlayerLevel(),
        Timestamp = time()
    }

    _AddEntry(entry)
end