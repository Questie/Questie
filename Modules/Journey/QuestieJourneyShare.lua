---@type QuestieJourney
local QuestieJourney = QuestieLoader:ImportModule("QuestieJourney")
local _QuestieJourney = QuestieJourney.private
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local AceGUI = LibStub("AceGUI-3.0")

local _journeyExportFrame
local _journeyImportFrame
local _journeyCharacterBrowserFrame
local _pendingJourneyImport

---@type table<string, boolean>
local _validEvents = {Quest = true, Level = true, Note = true}
---@type table<string, boolean>
local _validSubTypes = {Accept = true, Complete = true, Abandon = true}

---Returns journey data for all other characters on this account that have journey entries
---@return table<string, table> charKey -> journeyData
local function _GetOtherCharactersWithJourney()
    local currentKey = UnitName("player") .. " - " .. GetRealmName()
    local results = {}
    for charKey, charData in pairs((QuestieConfig and QuestieConfig.char) or {}) do
        if charKey ~= currentKey and charData.journey and #charData.journey > 0 then
            results[charKey] = charData.journey
        end
    end
    return results
end

---Validates deserialised journey data to ensure it matches expected format
---@param data any
---@return boolean
local function _ValidateJourneyData(data)
    if type(data) ~= "table" then return false end
    for _, entry in ipairs(data) do
        if type(entry) ~= "table" then return false end
        if type(entry.Timestamp) ~= "number" then return false end
        if not _validEvents[entry.Event] then return false end
        if entry.Event == "Quest" then
            if not _validSubTypes[entry.SubType] then return false end
            if type(entry.Quest) ~= "number" then return false end
            if type(entry.Level) ~= "number" then return false end
        elseif entry.Event == "Level" then
            if type(entry.NewLevel) ~= "number" then return false end
        elseif entry.Event == "Note" then
            if type(entry.Title) ~= "string" then return false end
            if type(entry.Note) ~= "string" then return false end
        end
    end
    return true
end

---Shows the export frame for the journey data
---@return void
function _QuestieJourney:ShowExportFrame()
    if _journeyExportFrame then
        _journeyExportFrame:Show()
        return
    end
    local frame = AceGUI:Create("Frame")
    _journeyExportFrame = frame
    frame:SetTitle(l10n("Export Journey Data"))
    frame:SetLayout("Flow")
    frame:SetWidth(600)
    frame:SetHeight(400)
    frame:SetCallback("OnClose", function(widget)
        AceGUI:Release(widget)
        _journeyExportFrame = nil
    end)
    local editBox = AceGUI:Create("MultiLineEditBox")
    editBox:SetLabel(l10n("Copy this text, then paste it into the Import box on another character:"))
    editBox:SetFullWidth(true)
    editBox:SetNumLines(20)
    editBox:DisableButton(true)
    editBox:SetMaxLetters(0)
    editBox:SetText(Questie:Serialize(Questie.db.char.journey))
    frame:AddChild(editBox)
    frame:Show()
    editBox:SetFocus()
    editBox:HighlightText()
end

---Shows the import frame for the journey data
---@return void
function _QuestieJourney:ShowImportFrame()
    if _journeyImportFrame then
        _journeyImportFrame:Show()
        return
    end
    local frame = AceGUI:Create("Frame")
    _journeyImportFrame = frame
    frame:SetTitle(l10n("Import Journey Data"))
    frame:SetLayout("Flow")
    frame:SetWidth(600)
    frame:SetHeight(450)
    frame:SetCallback("OnClose", function(widget)
        AceGUI:Release(widget)
        _journeyImportFrame = nil
    end)
    local editBox = AceGUI:Create("MultiLineEditBox")
    editBox:SetLabel(l10n("Paste exported journey data here, then click Import:"))
    editBox:SetFullWidth(true)
    editBox:SetNumLines(15)
    editBox:DisableButton(true)
    editBox:SetMaxLetters(0)
    local importBtn = AceGUI:Create("Button")
    importBtn:SetText(l10n("Import"))
    importBtn:SetFullWidth(true)
    importBtn:SetCallback("OnClick", function()
        local text = editBox:GetText()
        local ok, data = Questie:Deserialize(text)
        if not ok or not _ValidateJourneyData(data) then
            Questie:Print(l10n("Invalid journey data - paste the full exported text."))
            return
        end
        _pendingJourneyImport = data
        StaticPopup_Show("QUESTIE_JOURNEY_IMPORT_CONFIRM")
    end)
    frame:AddChild(editBox)
    frame:AddChild(importBtn)
    frame:Show()
    editBox:SetFocus()
end

---Shows a frame listing other characters on this account that have journey data, allowing import
---@return void
function _QuestieJourney:ShowCharacterBrowserFrame()
    if _journeyCharacterBrowserFrame then
        _journeyCharacterBrowserFrame:Show()
        return
    end

    local characters = _GetOtherCharactersWithJourney()

    local frame = AceGUI:Create("Frame")
    _journeyCharacterBrowserFrame = frame
    frame:SetTitle(l10n("Import from Character"))
    frame:SetLayout("Flow")
    frame:SetWidth(500)
    frame:SetCallback("OnClose", function(widget)
        AceGUI:Release(widget)
        _journeyCharacterBrowserFrame = nil
    end)

    if not next(characters) then
        frame:SetHeight(150)
        local label = AceGUI:Create("Label")
        label:SetText(l10n("No other characters with journey data found."))
        label:SetFullWidth(true)
        frame:AddChild(label)
        frame:Show()
        return
    end

    frame:SetHeight(230)

    local dropdownList = {}
    local dropdownOrder = {}
    for charKey in pairs(characters) do
        local charName, realm = charKey:match("^(.-) %- (.+)$")
        dropdownList[charKey] = (charName and realm) and (charName .. " (" .. realm .. ")") or charKey
        dropdownOrder[#dropdownOrder + 1] = charKey
    end
    table.sort(dropdownOrder, function(a, b) return dropdownList[a] < dropdownList[b] end)

    local selectedKey = dropdownOrder[1]

    local dropdown = AceGUI:Create("Dropdown")
    dropdown:SetLabel(l10n("Select a character to import:"))
    dropdown:SetFullWidth(true)
    dropdown:SetList(dropdownList, dropdownOrder)
    dropdown:SetValue(selectedKey)

    dropdown:SetCallback("OnValueChanged", function(_, _, value)
        selectedKey = value
    end)

    local importBtn = AceGUI:Create("Button")
    importBtn:SetText(l10n("Import"))
    importBtn:SetFullWidth(true)
    importBtn:SetCallback("OnClick", function()
        local journey = QuestieConfig.char[selectedKey] and QuestieConfig.char[selectedKey].journey
        if not journey or not _ValidateJourneyData(journey) then
            Questie:Print(l10n("Invalid journey data - paste the full exported text."))
            return
        end
        Questie.db.char.journey = journey
        frame:Hide()
        Questie:Print(l10n("Journey imported. Open the My Journey tab to see the changes."))
    end)

    frame:AddChild(dropdown)
    frame:AddChild(importBtn)
    frame:Show()
end

---Popup dialog for confirming journey import
---@type StaticPopupDialog
StaticPopupDialogs["QUESTIE_JOURNEY_IMPORT_CONFIRM"] = {
    text = "",
    button1 = YES,
    button2 = NO,
    OnAccept = function()
        Questie.db.char.journey = _pendingJourneyImport
        _pendingJourneyImport = nil
        if _journeyImportFrame then
            _journeyImportFrame:Hide()
        end
        Questie:Print(l10n("Journey imported. Open the My Journey tab to see the changes."))
    end,
    OnCancel = function()
        _pendingJourneyImport = nil
    end,
    OnShow = function(self)
        self.Text:SetText(l10n("Import this journey data? This will overwrite your current journey and reload the UI."))
        self:SetFrameStrata("FULLSCREEN_DIALOG")
        self:Raise()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}
