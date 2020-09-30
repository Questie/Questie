---@type QuestieJourney
local QuestieJourney = QuestieLoader:CreateModule("QuestieJourney")
local _QuestieJourney = QuestieJourney.private
_QuestieJourney.notePopup = nil
-------------------------
--Import modules
-------------------------
---@type QuestieJourneyUtils
local QuestieJourneyUtils = QuestieLoader:ImportModule("QuestieJourneyUtils")

local AceGUI = LibStub("AceGUI-3.0")
local titleBox, messageBox

local _CreateNoteWindow, _CreateContainer, _CreateDescription, _CreateTitleBox, _CreateMessageBox
local _CreateNoteAddButton, _HandleNoteEntry


function _QuestieJourney:ShowNotePopup()
    if (not _QuestieJourney.notePopup) then
        _QuestieJourney.notePopup = _CreateNoteWindow()
    elseif (not _QuestieJourney.notePopup:IsShown()) then
        _QuestieJourney.notePopup:Show()
    else
        _QuestieJourney.notePopup:Hide()
    end
end

_CreateNoteWindow = function ()
    local notePopup = AceGUI:Create("Window")
    notePopup:Show()
    notePopup:SetTitle(QuestieLocale:GetUIString('JOURNEY_NOTE_BTN'))
    notePopup:SetWidth(400)
    notePopup:SetHeight(400)
    notePopup:EnableResize(false)
    notePopup.frame:SetFrameStrata(_QuestieJourney.containerCache.frame:GetFrameStrata())
    notePopup.frame:SetFrameLevel(_QuestieJourney.containerCache.frame:GetFrameLevel())
    notePopup.frame:Raise()
    notePopup:SetCallback("OnClose", function()
        notePopup:Hide()
    end)

    local container = _CreateContainer()
    notePopup:AddChild(container)

    local desc = _CreateDescription()
    container:AddChild(desc)

    QuestieJourneyUtils:Spacer(container)

    titleBox = _CreateTitleBox()
    container:AddChild(titleBox)

    messageBox = _CreateMessageBox()
    container:AddChild(messageBox)

    local addEntryBtn = _CreateNoteAddButton()
    container:AddChild(addEntryBtn)

    return notePopup
end

_CreateContainer = function ()
    -- Setup Note Taking
    local day = CALENDAR_WEEKDAY_NAMES[tonumber(date('%w', time())) + 1]
    local month = CALENDAR_FULLDATE_MONTH_NAMES[tonumber(date('%m', time()))]
    local today = date(day ..', '.. month ..' %d', time())
    local container = AceGUI:Create("InlineGroup")
    container:SetFullHeight(true)
    container:SetFullWidth(true)
    container:SetLayout('flow')
    container:SetTitle(QuestieLocale:GetUIString('JOURNEY_NOTE_TITLE', today))
    return container
end

_CreateDescription  =function ()
    local desc = AceGUI:Create("Label")
    desc:SetText(Questie:Colorize(QuestieLocale:GetUIString('JOURNEY_NOTE_DESC'), 'yellow'))
    desc:SetFullWidth(true)
    return desc
end

_CreateTitleBox = function ()
    local box = AceGUI:Create("EditBox")
    box:SetFullWidth(true)
    box:SetLabel(QuestieLocale:GetUIString('JOURNEY_NOTE_ENTRY_TITLE'))
    box:DisableButton(true)
    box:SetFocus()
    return box
end

_CreateMessageBox = function ()
    local box = AceGUI:Create("MultiLineEditBox")
    box:SetFullWidth(true)
    box:SetNumLines(12)
    box:SetLabel(QuestieLocale:GetUIString('JOURNEY_NOTE_ENTRY_BODY'))
    box:DisableButton(true)
    return box
end

_CreateNoteAddButton = function ()
    local addEntryBtn = AceGUI:Create("Button")
    addEntryBtn:SetText(QuestieLocale:GetUIString('JOURNEY_NOTE_SUBMIT_BTN'))
    addEntryBtn:SetCallback("OnClick", _HandleNoteEntry)
    return addEntryBtn
end

_HandleNoteEntry = function ()
    local error = Questie:Colorize('[Questie] ', 'blue')
    if titleBox:GetText() == '' then
        print (error .. QuestieLocale:GetUIString('JOURNEY_ERR_NOTITLE'))
        return
    elseif messageBox:GetText() == '' then
        print (error .. QuestieLocale:GetUIString('JOURNEY_ERR_NONOTE'))
        return
    end
    local data = {}
    data.Event = "Note"
    data.Note = messageBox:GetText()
    data.Title = titleBox:GetText()
    data.Timestamp = time()

    tinsert(Questie.db.char.journey, data)

    _QuestieJourney.myJourney:ManageTree(_QuestieJourney.treeCache)
    _QuestieJourney.notePopup:Hide()
end
