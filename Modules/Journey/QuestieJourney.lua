
---@class QuestieJourney
local QuestieJourney = QuestieLoader:CreateModule("QuestieJourney")
local _QuestieJourney = QuestieJourney.private
-------------------------
--Import modules.
-------------------------
---@type QuestieJourneyUtils
local QuestieJourneyUtils = QuestieLoader:ImportModule("QuestieJourneyUtils")
---@type QuestieSearchResults
local QuestieSearchResults = QuestieLoader:ImportModule("QuestieSearchResults")
---@type QuestiePlayer
local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")

-- Useful doc about the AceGUI TreeGroup: https://github.com/hurricup/WoW-Ace3/blob/master/AceGUI-3.0/widgets/AceGUIContainer-TreeGroup.lua

local tinsert = table.insert

QuestieJourney.continents = {}
QuestieJourney.zones = {}

local AceGUI = LibStub("AceGUI-3.0")

local journeyFrame = {}
local isWindowShown = false
_QuestieJourney.lastOpenWindow = "journey"

function JumpToQuest(button)
    QuestieSearchResults:JumpToQuest(button)
    _QuestieJourney:HideJourneyTooltip()
 end

local notesPopupWin = nil
local notesPopupWinIsOpen = false
function NotePopup()
    if not notesPopupWin then
        notesPopupWin = AceGUI:Create("Window")
        notesPopupWin:Show()
        notesPopupWin:SetTitle(QuestieLocale:GetUIString('JOURNEY_NOTE_BTN'))
        notesPopupWin:SetWidth(400)
        notesPopupWin:SetHeight(400)
        notesPopupWin:EnableResize(false)
        notesPopupWin.frame:SetFrameStrata("HIGH")

        journeyFrame.frame.frame:SetFrameStrata("MEDIUM")

        notesPopupWinIsOpen = true
        _G["QuestieJourneyFrame"] = notesPopupWin.frame

        notesPopupWin:SetCallback("OnClose", function()
            notesPopupWin = nil
            notesPopupWinIsOpen = false
            journeyFrame.frame.frame:SetFrameStrata("FULLSCREEN_DIALOG")

            _G["QuestieJourneyFrame"] = journeyFrame.frame.frame
        end)

        -- Setup Note Taking
        local day = CALENDAR_WEEKDAY_NAMES[ tonumber(date('%w', time())) + 1]
        local month = CALENDAR_FULLDATE_MONTH_NAMES[ tonumber(date('%m', time())) ]
        local today = date(day ..', '.. month ..' %d', time())
        local frame = AceGUI:Create("InlineGroup")
        frame:SetFullHeight(true)
        frame:SetFullWidth(true)
        frame:SetLayout('flow')
        frame:SetTitle(QuestieLocale:GetUIString('JOURNEY_NOTE_TITLE', today))
        notesPopupWin:AddChild(frame)

        local desc = AceGUI:Create("Label")
        desc:SetText( Questie:Colorize(QuestieLocale:GetUIString('JOURNEY_NOTE_DESC'), 'yellow')  )
        desc:SetFullWidth(true)
        frame:AddChild(desc)

        QuestieJourneyUtils:Spacer(frame)


        local titleBox = AceGUI:Create("EditBox")
        titleBox:SetFullWidth(true)
        titleBox:SetLabel(QuestieLocale:GetUIString('JOURNEY_NOTE_ENTRY_TITLE'))
        titleBox:DisableButton(true)
        titleBox:SetFocus()
        frame:AddChild(titleBox)

        local messageBox = AceGUI:Create("MultiLineEditBox")
        messageBox:SetFullWidth(true)
        messageBox:SetNumLines(12)
        messageBox:SetLabel(QuestieLocale:GetUIString('JOUNREY_NOTE_ENTRY_BODY'))
        messageBox:DisableButton(true)
        frame:AddChild(messageBox)

        local addEntryBtn = AceGUI:Create("Button")
        addEntryBtn:SetText(QuestieLocale:GetUIString('JOURNEY_NOTE_SUBMIT_BTN'))
        addEntryBtn:SetCallback("OnClick", function()
            local err = Questie:Colorize('[Questie] ', 'blue')
            if titleBox:GetText() == '' then
                print (err .. QuestieLocale:GetUIString('JOURNEY_ERR_NOTITLE'))
                return
            elseif messageBox:GetText() == '' then
                print (err .. QuestieLocale:GetUIString('JOURNEY_ERR_NONOTE'))
                return
            end

            local data = {}
            data.Event = "Note"
            data.Note = messageBox:GetText()
            data.Title = titleBox:GetText()
            data.Timestamp = time()
            data.Party = QuestiePlayer:GetPartyMembers()

            tinsert(Questie.db.char.journey, data)

            _QuestieJourney.myJourney:ManageTree(_QuestieJourney.treeCache)

            notesPopupWin:Hide()
            notesPopupWin = nil
            notesPopupWinIsOpen = false

        end)
        frame:AddChild(addEntryBtn)

    else
        notesPopupWin:Hide()
        notesPopupWin = nil
        notesPopupWinIsOpen = false
    end
end

function ShowJourneyTooltip(button)
    if GameTooltip:IsShown() then
        return
    end

    local qid = button:GetUserData('id')
    local quest = QuestieDB:GetQuest(tonumber(qid))
    if quest then
        GameTooltip:SetOwner(_G["QuestieJourneyFrame"], "ANCHOR_CURSOR")
        GameTooltip:AddLine("[".. quest.level .."] ".. quest.name)
        GameTooltip:AddLine("|cFFFFFFFF" .. _QuestieJourney:CreateObjectiveText(quest.Description))
        GameTooltip:SetFrameStrata("TOOLTIP")
        GameTooltip:Show()
    end
end

QuestieJourney.tabGroup = nil
function QuestieJourney:Initialize()
    QuestieJourney.continents = LangContinentLookup
    QuestieJourney.zones = LangZoneLookup
    journeyFrame.frame = AceGUI:Create("Frame")

    journeyFrame.frame:SetTitle(QuestieLocale:GetUIString('JOURNEY_TITLE', UnitName("player")))
    journeyFrame.frame:SetLayout("Fill")

    QuestieJourney.tabGroup = AceGUI:Create("TabGroup")
    QuestieJourney.tabGroup:SetLayout("Flow")
    QuestieJourney.tabGroup:SetTabs({
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
    QuestieJourney.tabGroup:SetCallback("OnGroupSelected", function(widget, event, group) _QuestieJourney:JourneySelectTabGroup(widget, event, group) end)
    QuestieJourney.tabGroup:SelectTab("journey")

    journeyFrame.frame:AddChild(QuestieJourney.tabGroup)

    journeyFrame.frame:SetCallback("OnClose", function()
        isWindowShown = false
        if notesPopupWinIsOpen then
            notesPopupWin:Hide()
            notesPopupWin = nil
            notesPopupWinIsOpen = false
        end
    end)

    journeyFrame.frame:Hide()

    _G["QuestieJourneyFrame"] = journeyFrame.frame.frame
    tinsert(UISpecialFrames, "QuestieJourneyFrame")
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

        journeyFrame.frame:Show()
        isWindowShown = true
    else
        journeyFrame.frame:Hide()
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
    entry.Party = QuestiePlayer:GetPartyMembers()

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
    entry.Party = QuestiePlayer:GetPartyMembers()

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
        entry.Party = QuestiePlayer:GetPartyMembers()

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
    entry.Party = QuestiePlayer:GetPartyMembers()

    tinsert(Questie.db.char.journey, entry)
end
