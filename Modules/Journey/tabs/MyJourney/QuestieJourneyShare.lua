---@type QuestiePopup
local Popup = QuestieLoader:ImportModule("QuestiePopup")

---@type QuestieJourney
local QuestieJourney = QuestieLoader:ImportModule("QuestieJourney")
---@type JourneyWindow
local JourneyWindow = QuestieLoader:ImportModule("JourneyWindow")
---@type QuestieOptionsControls
local QuestieOptionsControls = QuestieLoader:ImportModule("QuestieOptionsControls")
---@type QuestieOptionsWindow
local QuestieOptionsWindow = QuestieLoader:ImportModule("QuestieOptionsWindow")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local WINDOW_WIDTH, WINDOW_HEIGHT = 360, 190

---Nil until the window is first opened.
---@type Frame?
local window
local characterDropdown, importButton
---@type FontString
local emptyText

---The characters whose journey can be imported, as keys of QuestieConfig.char. Brought up to date when the window opens.
---@type table<string, table>
local characters = {}
---@type string?
local selectedCharacter

local _pendingJourneyImport

---@type table<string, boolean>
local _validEvents = {Quest = true, Level = true, Note = true}
---@type table<string, boolean>
local _validSubTypes = {Accept = true, Complete = true, Abandon = true}

---Returns journey data for all other characters on this account that have journey entries
---@return table<string, table> charKey -> journeyData
local function _GetOtherCharactersWithJourney()
    -- This needs to stay in sync with the charKey that is created in Libs/AceDB-3.0/AceDB-3.0.lua
    local currentKey
    if RegionalUniqueNamesEnabled and RegionalUniqueNamesEnabled() then
		local name, surname = UnitNameUnmodified("player")
		if surname then
			currentKey = name .. " " .. tostring(surname)
		else
			currentKey = name
		end
    else
        currentKey = UnitNameUnmodified("player") .. " - " .. GetRealmName()
    end

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

---@param charKey string
---@return string
local function _GetCharacterText(charKey)
    local name, realm = charKey:match("^(.-) %- (.+)$")
    return name and (name .. " (" .. realm .. ")") or charKey -- There is no realm where names are unique
end

---@return table<string, string>
local function _GetCharacterTexts()
    local texts = {}
    for charKey in pairs(characters) do
        texts[charKey] = _GetCharacterText(charKey)
    end
    return texts
end

---@return string[] charKeys Sorted by what is shown
local function _GetCharacterOrder()
    local order = {}
    for charKey in pairs(characters) do
        table.insert(order, charKey)
    end
    table.sort(order, function(a, b) return _GetCharacterText(a) < _GetCharacterText(b) end)
    return order
end

local function _ImportSelected()
    local journey = characters[selectedCharacter]
    if not _ValidateJourneyData(journey) then
        Questie:Print(l10n("Invalid journey data - paste the full exported text."))
        return
    end
    _pendingJourneyImport = journey
    Popup.Show("QUESTIE_JOURNEY_IMPORT_CONFIRM")
end

local function _CreateWindow()
    window = QuestieOptionsWindow.Create({
        name = "QuestieImportJourneyFrame",
        title = l10n("Import Journey data"),
        strata = "FULLSCREEN_DIALOG", -- Above the settings, which it is opened from
        isPopup = true,
        width = WINDOW_WIDTH,
        height = WINDOW_HEIGHT,
    })

    local canvas = window.canvasContainer
    emptyText = canvas:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    emptyText:SetPoint("LEFT", canvas, "LEFT", 14, 0)
    emptyText:SetPoint("RIGHT", canvas, "RIGHT", -14, 0)
    emptyText:SetText(l10n("No other characters with journey data found."))

    characterDropdown = QuestieOptionsControls.Create(canvas, {
        type = "dropdown",
        title = l10n("Select a character to import"),
        options = _GetCharacterTexts,
        sortOrder = _GetCharacterOrder,
        get = function() return selectedCharacter end,
        set = function(charKey) selectedCharacter = charKey end,
    }, WINDOW_WIDTH - 40, 1)
    characterDropdown:SetPoint("TOP", canvas, "TOP", 0, -32)

    importButton = QuestieOptionsControls.Create(canvas, {
        type = "button",
        title = "",
        btnLabel = l10n("Import"),
        align = "CENTER",
        func = _ImportSelected,
    }, WINDOW_WIDTH - 40, 1)
    importButton:SetPoint("BOTTOM", canvas, "BOTTOM", 0, 4)
end

---Shows the other characters on this account that have journey data, to import it
function QuestieJourney:ShowCharacterBrowserFrame()
    characters = _GetOtherCharactersWithJourney()
    if not characters[selectedCharacter] then
        selectedCharacter = _GetCharacterOrder()[1]
    end

    if not window then
        _CreateWindow()
    end
    local hasCharacters = selectedCharacter ~= nil
    emptyText:SetShown(not hasCharacters)
    characterDropdown:SetShown(hasCharacters)
    importButton:SetShown(hasCharacters)
    QuestieOptionsControls.Refresh(characterDropdown)
    window:Show()
end

---Popup dialog for confirming journey import
---@type DialogDefinition
Popup.Dialogs["QUESTIE_JOURNEY_IMPORT_CONFIRM"] = {
    -- Reopening confirms the latest selection without cancelling its pending data.
    noCancelOnReuse = true,
    text = "",
    button1 = YES,
    button2 = NO,
    OnAccept = function()
        Questie.db.char.journey = _pendingJourneyImport
        _pendingJourneyImport = nil
        window:Hide()
        JourneyWindow.Refresh()
        Questie:Print(l10n("Journey imported. Open the My Journey tab to see the changes."))
    end,
    OnCancel = function()
        _pendingJourneyImport = nil
    end,
    OnShow = function(self)
        self.Text:SetText(l10n("Import this journey data? This will overwrite your current journey."))
        self:SetFrameStrata("FULLSCREEN_DIALOG")
        self:Raise()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
}
