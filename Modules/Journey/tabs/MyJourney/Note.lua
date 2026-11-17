---@type QuestiePopup
local Popup = QuestieLoader:ImportModule("QuestiePopup")

---@type QuestieJourney
local QuestieJourney = QuestieLoader:ImportModule("QuestieJourney")
local _QuestieJourney = QuestieJourney.private
_QuestieJourney.notePopup = nil
-------------------------
--Import modules
-------------------------
---@type QuestieJourneyUtils
local QuestieJourneyUtils = QuestieLoader:ImportModule("QuestieJourneyUtils")
---@type QuestDetailsFrame
local QuestDetailsFrame = QuestieLoader:ImportModule("QuestDetailsFrame")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")
---@type QuestieOptionsControls
local QuestieOptionsControls = QuestieLoader:ImportModule("QuestieOptionsControls")
---@type QuestieOptionsWindow
local QuestieOptionsWindow = QuestieLoader:ImportModule("QuestieOptionsWindow")

--- QuestieGUI
local QuestieGUI = QuestieLoader:ImportModule("QuestieGUI")
local titleBox, messageBox

local function ApplyNoteLayerColors(container)
    if not container or not container.border then
        return
    end

    -- Use the same NineSlice container treatment as Questie Options. The
    -- editor surfaces are darker nested controls, applied separately below.
    QuestieOptionsControls.ApplyModernContainer(container.border, false, true)
end

local function ApplyNoteEditorColor(widget)
    local surface = widget and (widget.scrollBG or widget.editbox)
    if not surface or not surface.SetBackdropColor then
        return
    end

    surface:SetBackdropColor(0.08, 0.055, 0.03, 0.98)
    if surface.SetBackdropBorderColor then
        surface:SetBackdropBorderColor(0.42, 0.29, 0.12, 0.95)
    end
end

local _CreateNoteWindow, _CreateContainer, _CreateDescription, _CreateTitleBox, _CreateMessageBox
local _CreateNoteAddButton, _HandleNoteEntry, _DeleteNote


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
    local journeyFrame = QuestieJourneyFrame or UIParent
    local popupWidth = math.min(680, journeyFrame:GetWidth() - 40)
    local popupHeight = math.min(620, journeyFrame:GetHeight() - 40)
    local notePopup = QuestieOptionsWindow.Create({
        name = "QuestieJourneyNoteFrame",
        title = l10n('Add New Adventure Note'),
        portrait = "Interface\\Icons\\INV_Misc_Note_03",
        width = popupWidth,
        height = popupHeight,
        resizable = true,
        minWidth = 520,
        minHeight = 500,
    })
    notePopup:ClearAllPoints()
    notePopup:SetPoint("CENTER", journeyFrame, "CENTER")
    notePopup:Raise()

    local content = QuestieGUI:Create("SimpleGroup")
    content:SetFullHeight(true)
    content:SetFullWidth(true)
    content:SetLayout("flow")
    content.frame:SetParent(notePopup.canvasContainer)
    content.frame:SetAllPoints(notePopup.canvasContainer)
    content.frame:Show()

    QuestieOptionsControls.CreateModernDividerGroup(content, l10n('New Note'))

    local container = _CreateContainer()
    content:AddChild(container)

    local desc = _CreateDescription()
    container:AddChild(desc)

    QuestieJourneyUtils:Spacer(container)

    titleBox = _CreateTitleBox()
    container:AddChild(titleBox)

    messageBox = _CreateMessageBox()
    container:AddChild(messageBox)
    ApplyNoteEditorColor(titleBox)
    ApplyNoteEditorColor(messageBox)

    local addEntryBtn = _CreateNoteAddButton()
    container:AddChild(addEntryBtn)

    notePopup:Show()
    -- The container may restore its backdrop while laying out its children;
    -- apply the shared Journey panel treatment after the completed layout too.
    if QuestieOptionsControls and QuestieOptionsControls.ApplyModernContainer then
        QuestieOptionsControls.ApplyModernContainer(container.border)
    end
    ApplyNoteLayerColors(container)
    return notePopup
end

_CreateContainer = function ()
    local container = QuestieGUI:Create("InlineGroup")
    -- Clear any NPC portrait/item icon and
    -- shifted content anchors left by a previously displayed Journey panel.
    if QuestDetailsFrame and QuestDetailsFrame.ResetInfoGroup then
        QuestDetailsFrame:ResetInfoGroup(container)
    end
    container:SetFullHeight(true)
    container:SetFullWidth(true)
    container:SetLayout('flow')
    if QuestieOptionsControls and QuestieOptionsControls.ApplyModernContainer then
        QuestieOptionsControls.ApplyModernContainer(container.border)
    end
    ApplyNoteLayerColors(container)
    return container
end

_CreateDescription  =function ()
    local desc = QuestieGUI:Create("Label")
    desc:SetText(l10n('Create an entry in your journal to remember a specific moment. Simply supply a title and description and Questie will remember it for you!'))
    desc:SetFullWidth(true)
    return desc
end

_CreateTitleBox = function ()
    local box = QuestieGUI:Create("EditBox")
    box:SetFullWidth(true)
    box:SetLabel(l10n('Entry Title'))
    box:DisableButton(true)
    box:SetFocus()
    return box
end

_CreateMessageBox = function ()
    local box = QuestieGUI:Create("MultiLineEditBox")
    box:SetFullWidth(true)
    box:SetNumLines(24)
    box:SetLabel(l10n('Journal Entry'))
    box:DisableButton(true)
    if QuestieOptionsControls and QuestieOptionsControls.ApplyModernScrollbar then
        QuestieOptionsControls.ApplyModernScrollbar(box.scrollBar)
    end
    return box
end

_CreateNoteAddButton = function ()
    local addEntryBtn = QuestieGUI:Create("SimpleGroup")
    addEntryBtn:SetLayout("Fill")
    addEntryBtn:SetFullWidth(true)
    addEntryBtn:SetHeight(32)

    if QuestieOptionsControls and QuestieOptionsControls.CreateStyledButton then
        local nativeButton = QuestieOptionsControls.CreateStyledButton(addEntryBtn.content, 150)
        nativeButton:SetText(l10n('Add Entry'))
        nativeButton:SetPoint("LEFT", addEntryBtn.content, "LEFT", 0, 0)
        nativeButton:SetScript("OnClick", _HandleNoteEntry)
        addEntryBtn.nativeButton = nativeButton
    else
        local legacyButton = QuestieGUI:Create("Button")
        legacyButton:SetText(l10n('Add Entry'))
        legacyButton:SetWidth(150)
        legacyButton:SetHeight(32)
        legacyButton:SetCallback("OnClick", _HandleNoteEntry)
        addEntryBtn:AddChild(legacyButton)
    end

    addEntryBtn:SetCallback("OnRelease", function(widget)
        if widget.nativeButton then
            widget.nativeButton:Hide()
            widget.nativeButton = nil
        end
    end)
    return addEntryBtn
end

_HandleNoteEntry = function ()
    local error = Questie:Colorize('[Questie] ', 'lightBlue')
    if titleBox:GetText() == '' then
        print (error .. l10n('No Title was entered. You must enter a title before submitting your note.'))
        return
    elseif messageBox:GetText() == '' then
        print (error .. l10n('No Note was entered. You must enter a note before submitting.'))
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

_DeleteNote = function(noteIndex)
    local success = false
    if noteIndex and noteIndex > 0 and noteIndex <= #Questie.db.char.journey then
        local entry = Questie.db.char.journey[noteIndex]
        if entry and entry.Event == "Note" then
            table.remove(Questie.db.char.journey, noteIndex)
            success = true
            Questie:Print(l10n('Note deleted successfully'))
            if _QuestieJourney.myJourney and _QuestieJourney.treeCache then
                _QuestieJourney.myJourney:ManageTree(_QuestieJourney.treeCache)
            end
        end
    end

    return success
end


Popup.Dialogs["QUESTIE_DELETE_NOTE_CONFIRM"] = {
    text = "",
    button1 = YES,
    button2 = NO,
    OnAccept = function(self)
        local noteIndex = self.data
        _DeleteNote(noteIndex)
    end,
    OnShow = function(self)
        local noteIndex = self.data
        local confirmText = l10n("Are you sure you want to delete this note?")
        if noteIndex then
            local entry = Questie.db.char.journey[noteIndex]
            if entry and entry.Event == "Note" then
                confirmText = confirmText .. "\n\n" .. Questie:Colorize(entry.Title, 'yellow')
            end
        end
        self.Text:SetText(confirmText)
        self:SetFrameStrata("FULLSCREEN_DIALOG")
        self:Raise()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
}
