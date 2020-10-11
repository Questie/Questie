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

-- Useful doc about the AceGUI TreeGroup: https://github.com/hurricup/WoW-Ace3/blob/master/AceGUI-3.0/widgets/AceGUIContainer-TreeGroup.lua

local tinsert = table.insert

QuestieJourney.continents = {}
QuestieJourney.zones = {}
QuestieJourney.tabGroup = nil

local AceGUI = LibStub("AceGUI-3.0")

local isWindowShown = false
_QuestieJourney.lastOpenWindow = "journey"
_QuestieJourney.lastZoneSelection = {}

local notesPopupWin = nil
local notesPopupWinIsOpen = false


function QuestieJourney:Initialize()
    self.continents = LangContinentLookup
    self.continents[QuestieLocale.questCategoryKeys.CLASS] = QuestiePlayer:GetLocalizedClassName()
    self.zoneMap = ZoneDB:GetZonesWithQuests()
    self.zones = ZoneDB:GetRelevantZones()

    self:BuildMainFrame()
end

function QuestieJourney:BuildMainFrame()
    if (QuestieJourneyFrame == nil) then
        local journeyFrame = AceGUI:Create("Frame")
        journeyFrame:SetCallback("OnClose", function()
            isWindowShown = false
            if notesPopupWinIsOpen then
                notesPopupWin:Hide()
                notesPopupWin = nil
                notesPopupWinIsOpen = false
            end
        end)
        journeyFrame:SetTitle(QuestieLocale:GetUIString('JOURNEY_TITLE', UnitName("player")))
        journeyFrame:SetLayout("Fill")
        journeyFrame.frame:SetMinResize(550, 400)

        local tabGroup = AceGUI:Create("TabGroup")
        tabGroup:SetLayout("Flow")
        tabGroup:SetTabs({
            {
                text = QuestieLocale:GetUIString('JOUNREY_TAB'),
                value="journey"
            },
            {
                text = QuestieLocale:GetUIString('JOURNEY_ZONE_TAB'),
                value="zone"
            },
            {
                text = QuestieLocale:GetUIString('JOURNEY_SEARCH_TAB'),
                value="search"
            }
        })
        tabGroup:SetCallback("OnGroupSelected", function(widget, event, group) _QuestieJourney:HandleTabChange(widget, event, group) end)
        tabGroup:SelectTab("journey")

        QuestieJourney.tabGroup = tabGroup
        journeyFrame:AddChild(QuestieJourney.tabGroup)

        local settingsButton = AceGUI:Create("Button")
        settingsButton:SetWidth(160)
        settingsButton:SetPoint("TOPRIGHT", journeyFrame.frame, "TOPRIGHT", -50, -13)
        settingsButton:SetText(QuestieLocale:GetUIString('Questie Options'))
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
    if not isWindowShown then
        PlaySound(882)

        local treeGroup = _QuestieJourney:HandleTabChange(_QuestieJourney.containerCache, nil, _QuestieJourney.lastOpenWindow)
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
    local entry = {}
    entry.Event = "Level"
    entry.NewLevel = level
    entry.Timestamp = time()

    tinsert(Questie.db.char.journey, entry)
end

function QuestieJourney:AcceptQuest(questId)
    -- Add quest accept journey note.
    ---@type JourneyEntry
    local entry = {}
    entry.Event = "Quest"
    entry.SubType = "Accept"
    entry.Quest = questId
    entry.Level = QuestiePlayer:GetPlayerLevel()
    entry.Timestamp = time()

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
        local entry = {}
        entry.Event = "Quest"
        entry.SubType = "Abandon"
        entry.Quest = questId
        entry.Level = QuestiePlayer:GetPlayerLevel()
        entry.Timestamp = time()

        tinsert(Questie.db.char.journey, entry)
    end
end

function QuestieJourney:CompleteQuest(questId)
    -- Complete Quest added to Journey
    ---@class JourneyEntry
    local entry = {}
    entry.Event = "Quest"
    entry.SubType = "Complete"
    entry.Quest = questId
    entry.Level = QuestiePlayer:GetPlayerLevel()
    entry.Timestamp = time()

    tinsert(Questie.db.char.journey, entry)
end
