---@type QuestieJourney
local QuestieJourney = QuestieLoader:ImportModule("QuestieJourney")
local _QuestieJourney = QuestieJourney.private
-------------------------
--Import modules
-------------------------
---@type JourneyLinkInput
local JourneyLinkInput = QuestieLoader:ImportModule("JourneyLinkInput")
---@type JourneyWindow
local JourneyWindow = QuestieLoader:ImportModule("JourneyWindow")
---@type QuestieOptionsControls
local QuestieOptionsControls = QuestieLoader:ImportModule("QuestieOptionsControls")
---@type QuestieOptionsWindow
local QuestieOptionsWindow = QuestieLoader:ImportModule("QuestieOptionsWindow")
---@type QuestiePopup
local Popup = QuestieLoader:ImportModule("QuestiePopup")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local WINDOW_WIDTH, WINDOW_HEIGHT = 420, 440

---Nil until the window is first opened.
---@type Frame?
local window

---@type EditBox
local titleBox

---@type Frame A ScrollingEditBoxTemplate
local messageBox

---@param text string
local function _PrintError(text)
    print(Questie:Colorize("[Questie] ", "lightBlue") .. text)
end

local function _AddNote()
    if titleBox:GetText() == "" then
        _PrintError(l10n("No Title was entered. You must enter a title before submitting your note."))
        return
    elseif messageBox:GetInputText() == "" then
        _PrintError(l10n("No Note was entered. You must enter a note before submitting."))
        return
    end

    table.insert(Questie.db.char.journey, {
        Event = "Note",
        Note = messageBox:GetInputText(),
        Title = titleBox:GetText(),
        Timestamp = time(),
    })

    titleBox:SetText("")
    messageBox:ClearText()
    window:Hide()
    JourneyWindow.Refresh()
end

---@param canvas Frame
---@return EditBox
local function _CreateTitleBox(canvas)
    local label = canvas:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    label:SetPoint("TOPLEFT", canvas, "TOPLEFT", 14, -64)
    label:SetText(l10n("Entry Title"))

    local editBox = CreateFrame("EditBox", nil, canvas, "InputBoxTemplate")
    editBox:SetPoint("TOPLEFT", canvas, "TOPLEFT", 18, -80)
    editBox:SetPoint("TOPRIGHT", canvas, "TOPRIGHT", -12, -80)
    editBox:SetHeight(22)
    editBox:SetAutoFocus(false)
    editBox:SetFontObject("ChatFontNormal")
    JourneyLinkInput.Enable(editBox)
    return editBox
end

---@param canvas Frame
---@return Frame
local function _CreateMessageBox(canvas)
    local box = QuestieOptionsControls.Create(canvas, {type = "container", title = l10n("Journal Entry")}, 200, 3)
    box:SetPoint("TOPLEFT", canvas, "TOPLEFT", 14, -132)
    box:SetPoint("BOTTOMRIGHT", canvas, "BOTTOMRIGHT", -12, 54)

    local scrollBar = CreateFrame("EventFrame", nil, box.contentArea, "MinimalScrollBar")
    scrollBar:SetPoint("TOPRIGHT", box.contentArea, "TOPRIGHT", -10, -8)
    scrollBar:SetPoint("BOTTOMRIGHT", box.contentArea, "BOTTOMRIGHT", -10, 4)

    local message = CreateFrame("Frame", nil, box.contentArea, "ScrollingEditBoxTemplate")
    message:SetPoint("TOPLEFT", box.contentArea, "TOPLEFT", 10, -8)
    message:SetPoint("BOTTOMRIGHT", box.contentArea, "BOTTOMRIGHT", -26, 2)
    ScrollUtil.RegisterScrollBoxWithScrollBar(message:GetScrollBox(), scrollBar)
    ScrollUtil.AddManagedScrollBarVisibilityBehavior(message:GetScrollBox(), scrollBar)

    box:SetScript("OnClick", function() message:SetFocus() end)
    JourneyLinkInput.Enable(message:GetEditBox())
    return message
end

local function _CreateWindow()
    window = QuestieOptionsWindow.Create({
        name = "QuestieJourneyNoteFrame",
        title = l10n("Add New Adventure Note"),
        strata = "FULLSCREEN_DIALOG", -- Like My Journey
        isPopup = true,
        width = WINDOW_WIDTH,
        height = WINDOW_HEIGHT,
    })

    local canvas = window.canvasContainer
    local description = canvas:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    description:SetPoint("TOPLEFT", canvas, "TOPLEFT", QuestieOptionsWindow.HEADER_INSET, -8)
    description:SetPoint("TOPRIGHT", canvas, "TOPRIGHT", -12, -8)
    description:SetJustifyH("LEFT")
    description:SetText(l10n("Create an entry in your journal to remember a specific moment. Simply supply a title and description and Questie will remember it for you!"))

    titleBox = _CreateTitleBox(canvas)
    messageBox = _CreateMessageBox(canvas)
    titleBox:SetScript("OnTabPressed", function() messageBox:SetFocus() end)
    titleBox:SetScript("OnEnterPressed", function() messageBox:SetFocus() end)
    messageBox:GetEditBox():HookScript("OnTabPressed", function() titleBox:SetFocus() end)

    local addButton = QuestieOptionsControls.Create(canvas, {
        type = "button",
        title = "",
        btnLabel = l10n("Add Entry"),
        align = "RIGHT",
        func = _AddNote,
    }, 200, 1)
    addButton:SetPoint("BOTTOMRIGHT", canvas, "BOTTOMRIGHT", -8, 4)
end

---Opens the window for writing a note, or closes it. What was typed is kept until the note is added.
function _QuestieJourney.ToggleNoteWindow()
    if not window then
        _CreateWindow()
    end
    if window:IsShown() then
        window:Hide()
        return
    end

    window:Show()
    titleBox:SetFocus()
end

---@param note JourneyEntry
local function _DeleteNote(note)
    for index, entry in ipairs(Questie.db.char.journey) do
        if entry == note then
            table.remove(Questie.db.char.journey, index)
            Questie:Print(l10n("Note deleted successfully"))
            JourneyWindow.Refresh()
            return
        end
    end
end

Popup.Dialogs["QUESTIE_DELETE_NOTE_CONFIRM"] = {
    text = "",
    button1 = YES,
    button2 = NO,
    OnAccept = function(self)
        _DeleteNote(self.data)
    end,
    OnShow = function(self)
        local confirmText = l10n("Are you sure you want to delete this note?")
        self.Text:SetText(confirmText .. "\n\n" .. Questie:Colorize(self.data.Title, "yellow"))
        self:SetFrameStrata("FULLSCREEN_DIALOG")
        self:Raise()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
}
