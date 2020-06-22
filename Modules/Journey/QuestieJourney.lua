---@class QuestieJourney
local QuestieJourney = QuestieLoader:CreateModule("QuestieJourney")
local _QuestieJourney = QuestieJourney.private
-------------------------
--Import modules.
-------------------------
---@type QuestiePlayer
local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
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

local notesPopupWin = nil
local notesPopupWinIsOpen = false


function QuestieJourney:Initialize()
    self.continents = LangContinentLookup
    self.zoneMap = ZoneDB:GetZonesWithQuests()
    self.zones = ZoneDB:GetRelevantZones()

    self:BuildMainFrame()
end

function QuestieJourney:BuildMainFrame()
    if (QuestieJourney.frame == nil) then
        local frame = AceGUI:Create("Frame")
        frame:SetCallback("OnClose", function()
            isWindowShown = false
            if notesPopupWinIsOpen then
                notesPopupWin:Hide()
                notesPopupWin = nil
                notesPopupWinIsOpen = false
            end
        end)
        frame:SetTitle(QuestieLocale:GetUIString('JOURNEY_TITLE', UnitName("player")))
        frame:SetLayout("Fill")

        QuestieJourney.frame = frame

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
        tabGroup:SetCallback("OnGroupSelected", function(widget, event, group) _QuestieJourney:JourneySelectTabGroup(widget, event, group) end)
        tabGroup:SelectTab("journey")

        QuestieJourney.tabGroup = tabGroup

        QuestieJourney.frame:AddChild(QuestieJourney.tabGroup)

        QuestieJourney.frame:Hide()
        _G["QuestieJourneyFrame"] = QuestieJourney.frame
        table.insert(UISpecialFrames, "QuestieJourneyFrame")
    end
end

function QuestieJourney:IsShown()
    return isWindowShown
end

function QuestieJourney:ToggleJourneyWindow()
    if not isWindowShown then
        PlaySound(882)

        local treeGroup = _QuestieJourney:JourneySelectTabGroup(_QuestieJourney.containerCache, nil, _QuestieJourney.lastOpenWindow)
        if treeGroup then
            _QuestieJourney.treeCache = treeGroup
        end

        QuestieJourney.frame:Show()
        isWindowShown = true
    else
        QuestieJourney.frame:Hide()
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
