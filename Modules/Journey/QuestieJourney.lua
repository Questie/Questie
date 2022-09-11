---@class QuestieJourney
local QuestieJourney = QuestieLoader:CreateModule("QuestieJourney")
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

QuestieJourney.questCategoryKeys = {
    EASTERN_KINGDOMS = 1,
    KALIMDOR = 2,
    DUNGEONS = 3,
    BATTLEGROUNDS = 4,
    CLASS = 5,
    PROFESSIONS = 6,
    EVENTS = 7,
}

function QuestieJourney:Initialize()
    local continents = {}
    for id, name in pairs(l10n.continentLookup) do
        continents[id] = l10n(name)
    end
    continents[QuestieJourney.questCategoryKeys.CLASS] = QuestiePlayer:GetLocalizedClassName()

    self.continents = continents
    self.zoneMap = ZoneDB:GetZonesWithQuests()
    self.zones = ZoneDB:GetRelevantZones()

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
        journeyFrame.frame:SetMinResize(550, 400)

        local tabGroup = AceGUI:Create("TabGroup")
        tabGroup:SetLayout("Flow")
        tabGroup:SetTabs({
            {
                text = l10n('My Journey'),
                value="journey"
            },
            {
                text = l10n('Quests by Zone'),
                value="zone"
            },
            {
                text = l10n('Advanced Search'),
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
        settingsButton:SetText(l10n('Questie Options'))
        settingsButton:SetCallback("OnClick", function()
            QuestieJourney:ToggleJourneyWindow()
            QuestieOptions:OpenConfigWindow()
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
end

function QuestieJourney:PlayerLevelUp(level)
    -- Complete Quest added to Journey
    ---@type JourneyEntry
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
