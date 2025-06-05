---@class QuestieJourney
local QuestieJourney = QuestieLoader:ImportModule("QuestieJourney")
local _QuestieJourney = QuestieJourney.private
QuestieJourneyFrame = nil
-------------------------
--Import modules.
-------------------------
---@type QuestiePlayer
local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
---@type QuestieOptions
local QuestieOptions = QuestieLoader:ImportModule("QuestieOptions")
---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule("ZoneDB")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")
---@type QuestieCombatQueue
local QuestieCombatQueue = QuestieLoader:ImportModule("QuestieCombatQueue")
---@type Expansions
local Expansions = QuestieLoader:ImportModule("Expansions")

-- Useful doc about the AceGUI TreeGroup: https://github.com/hurricup/WoW-Ace3/blob/master/AceGUI-3.0/widgets/AceGUIContainer-TreeGroup.lua

local tinsert = table.insert

QuestieJourney.continents = {}
QuestieJourney.zones = {}
QuestieJourney.tabGroup = nil

local AceGUI = LibStub("AceGUI-3.0")

local isWindowShown = false
_QuestieJourney.lastOpenWindow = "journey"
_QuestieJourney.lastZoneSelection = {}

local notesPopupWin
local notesPopupWinIsOpen = false

-- These need to match with l10n.continentLookup
local questCategoryKeys = {
    EASTERN_KINGDOMS = 1,
    KALIMDOR = 2,
    OUTLAND = 3,
    NORTHREND = 4,
    CATACLYSM = 5,
    THE_MAELSTROM = 6,
    PANDARIA = 7,
    DUNGEONS = 8,
    BATTLEGROUNDS = 9,
    CLASS = 10,
    PROFESSIONS = 11,
    EVENTS = 12,
    PET_BATTLES = 13,
}
QuestieJourney.questCategoryKeys = questCategoryKeys


function QuestieJourney:Initialize()
    local continents = {}
    for id, name in pairs(l10n.continentLookup) do
        if not (questCategoryKeys.OUTLAND == id and Expansions.Current < Expansions.Tbc) and
            not (questCategoryKeys.NORTHREND == id and Expansions.Current < Expansions.Wotlk) and
            not (questCategoryKeys.CATACLYSM == id and Expansions.Current < Expansions.Cata) and
            not (questCategoryKeys.THE_MAELSTROM == id and Expansions.Current < Expansions.Cata) and
            not (questCategoryKeys.PANDARIA == id and Expansions.Current < Expansions.MoP) and
            not (questCategoryKeys.PET_BATTLES == id and Expansions.Current < Expansions.MoP) then
            continents[id] = l10n(name)
        end
    end
    coroutine.yield()
    continents[questCategoryKeys.CLASS] = QuestiePlayer:GetLocalizedClassName()

    coroutine.yield()
    self.continents = continents
    self.zoneMap = ZoneDB.GetZonesWithQuests(true)
    self.zones = ZoneDB.GetRelevantZones()
    coroutine.yield()
    self:BuildMainFrame()
end

function QuestieJourney:BuildMainFrame()
    if not QuestieJourneyFrame then
        local journeyFrame = AceGUI:Create("Frame")
        journeyFrame:SetCallback("OnClose", function()
            isWindowShown = false
            if notesPopupWinIsOpen then
                notesPopupWin:Hide()
                notesPopupWin = nil
                notesPopupWinIsOpen = false
            end
        end)
        journeyFrame:SetTitle(l10n("%s's Journey", UnitName("player")))
        journeyFrame:SetLayout("Fill")
        journeyFrame:EnableResize(true)
        journeyFrame:SetWidth(1000)
        journeyFrame:SetHeight(650)
        QuestieCompat.SetResizeBounds(journeyFrame.frame, 550, 400, 0, 0)

        local tabGroup = AceGUI:Create("TabGroup")
        tabGroup:SetLayout("Flow")
        tabGroup:SetTabs({
            {
                text = l10n("My Journey"),
                value="journey"
            },
            {
                text = l10n("Quests by Zone"),
                value="zone"
            },
            {
                text = l10n("Advanced Search"),
                value="search"
            }
        })
        tabGroup:SetCallback("OnGroupSelected", function(widget, _, group) _QuestieJourney:HandleTabChange(widget, group) end)
        tabGroup:SelectTab("journey")

        QuestieJourney.tabGroup = tabGroup
        journeyFrame:AddChild(QuestieJourney.tabGroup)

        local settingsButton = AceGUI:Create("Button")
        settingsButton:SetWidth(160)
        settingsButton:SetPoint("TOPRIGHT", journeyFrame.frame, "TOPRIGHT", -50, -13)
        settingsButton:SetText(l10n("Questie Options"))
        settingsButton:SetCallback("OnClick", function()
            QuestieCombatQueue:Queue(function()
                QuestieJourney:ToggleJourneyWindow()
                QuestieOptions:OpenConfigWindow()
            end)
        end)
        journeyFrame:AddChild(settingsButton)

        journeyFrame:Hide()
        QuestieJourneyFrame = journeyFrame
        table.insert(UISpecialFrames, "QuestieJourneyFrame")
    end
end

function QuestieJourney:IsShown()
    return isWindowShown
end

function QuestieJourney:ToggleJourneyWindow()
    -- There are ways to toggle this function before the frame has been created
    if QuestieJourneyFrame then
        if (not isWindowShown) then
            PlaySound(882)

            local treeGroup = _QuestieJourney:HandleTabChange(_QuestieJourney.containerCache, _QuestieJourney.lastOpenWindow)
            if treeGroup then
                _QuestieJourney.treeCache = treeGroup
            end

            QuestieJourneyFrame:Show()
            isWindowShown = true
        else
            QuestieJourneyFrame:Hide()
            isWindowShown = false
        end
    else
        Questie:Error("QuestieJourney:ToggleJourneyWindow() called before QuestieJourneyFrame was initialized!")
    end
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

    tinsert(Questie.db.char.journey, entry)
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

    tinsert(Questie.db.char.journey, entry)
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

        tinsert(Questie.db.char.journey, entry)
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

    tinsert(Questie.db.char.journey, entry)
end

return QuestieJourney
