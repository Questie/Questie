---@class QuestieJourney
local QuestieJourney = QuestieLoader:ImportModule("QuestieJourney")
local _QuestieJourney = QuestieJourney.private
QuestieJourneyFrame = nil
-------------------------
--Import modules.
-------------------------
---@type QuestiePlayer
local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
---@type JourneyData
local JourneyData = QuestieLoader:ImportModule("JourneyData")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")
---@type QuestieCombatQueue
local QuestieCombatQueue = QuestieLoader:ImportModule("QuestieCombatQueue")
---@type Expansions
local Expansions = QuestieLoader:ImportModule("Expansions")
---@type QuestieOptionsEngine
local QuestieOptionsEngine = QuestieLoader:ImportModule("QuestieOptionsEngine")
---@type QuestieOptionsWindow
local QuestieOptionsWindow = QuestieLoader:ImportModule("QuestieOptionsWindow")
---@type QuestieOptionsControls
local QuestieOptionsControls = QuestieLoader:ImportModule("QuestieOptionsControls")

local tinsert = table.insert

QuestieJourney.continents = {}
QuestieJourney.zones = {}
QuestieJourney.tabGroup = nil

--- QuestieGUI
local QuestieGUI = QuestieLoader:ImportModule("QuestieGUI")

local isWindowShown = false
_QuestieJourney.lastOpenWindow = "journey"
_QuestieJourney.lastZoneSelection = {}
_QuestieJourney.lastFactionSelection = {}
_QuestieJourney.questsByZone = {}

local notesPopupWin
local notesPopupWinIsOpen = false

local journeyTabs = {
    {key = "journey", title = "My Journey", subtitle = "Your character's history", icon = "Interface\\Icons\\INV_Misc_Map02"},
    {key = "zone", title = "Quests by Zone", subtitle = "Explore quests by zone", icon = "Interface\\AddOns\\Questie\\Icons\\azeroth.tga"},
    {key = "faction", title = "Quests by Faction", subtitle = "Explore quests by faction", icon = "Interface\\Icons\\Achievement_Reputation_01"},
    {key = "search", title = "Advanced Search", subtitle = "Find quests and objectives", icon = "Interface\\Icons\\INV_Misc_Spyglass_03"},
}

local journeyCanvases = {}
local journeySideTabs = {}

local function CreateJourneyCanvas(parent)
    local canvas = QuestieGUI:Create("SimpleGroup")
    canvas:SetLayout("Flow")
    canvas:SetFullWidth(true)
    canvas:SetFullHeight(true)
    canvas.frame:SetParent(parent)
    canvas.frame:SetAllPoints(parent)
    if QuestieOptionsControls and QuestieOptionsControls.ApplyModernContainer then
        QuestieOptionsControls.ApplyModernContainer(canvas.border, false, false)
    end
    canvas.frame:Hide()
    return canvas
end

local function SelectJourneyTab(group)
    local canvas = journeyCanvases[group]
    if not canvas then
        return
    end

    for _, tab in ipairs(journeyTabs) do
        local selected = tab.key == group
        journeyCanvases[tab.key].frame:SetShown(selected)
        QuestieOptionsWindow.SetSideTabSelected(journeySideTabs[tab.key], selected)
    end

    local treeGroup = _QuestieJourney:HandleTabChange(canvas, group)
    if treeGroup then
        _QuestieJourney.treeCache = treeGroup
    end
end

-- These need to match with l10n.continentLookup
local questCategoryKeys = {
    EASTERN_KINGDOMS = 1,
    KALIMDOR = 2,
    OUTLAND = 3,
    NORTHREND = 4,
    CATACLYSM = 5,
    THE_MAELSTROM = 6,
    PANDARIA = 7,
    ZEPHRAS_ISLE = 8,
    DUNGEONS = 9,
    BATTLEGROUNDS = 10,
    CLASS = 11,
    PROFESSIONS = 12,
    EVENTS = 13,
    PET_BATTLES = 14,
    SCENARIOS = 15,
}
QuestieJourney.questCategoryKeys = questCategoryKeys

-- Detect character re-creation and ask user about journey reset
local function checkForCharacterRecreation()
    local guid = UnitGUID("player") -- this is unique per character
    if (not Questie.db.char.guid) then
        -- First login for this character
        Questie.db.char.guid = guid
    elseif (Questie.db.char.guid ~= guid) then
        -- Character re-created, ask user about journey reset
        Questie:Print(l10n("Character re-creation detected, resetting \"My Journey\" data."))
        Questie.db.char.journey = {}
        Questie.db.char.guid = guid
    end
end

function QuestieJourney:Initialize()
    local continents = {}
    for id, name in pairs(l10n.continentLookup) do
        if not (questCategoryKeys.OUTLAND == id and Expansions.Current < Expansions.Tbc) and
            not (questCategoryKeys.NORTHREND == id and Expansions.Current < Expansions.Wotlk) and
            not (questCategoryKeys.CATACLYSM == id and Expansions.Current < Expansions.Cata) and
            not (questCategoryKeys.THE_MAELSTROM == id and Expansions.Current < Expansions.Cata) and
            not (questCategoryKeys.PANDARIA == id and Expansions.Current < Expansions.MoP) and
            not (questCategoryKeys.ZEPHRAS_ISLE == id and not Questie.IsForever) and
            not (questCategoryKeys.PET_BATTLES == id and Expansions.Current < Expansions.MoP) and
            not (questCategoryKeys.SCENARIOS == id and Expansions.Current < Expansions.MoP)
        then
            continents[id] = l10n(name)
        end
    end
    coroutine.yield()
    continents[questCategoryKeys.CLASS] = QuestiePlayer:GetLocalizedClassName()

    checkForCharacterRecreation()

    coroutine.yield()
    self.continents = continents
    -- Generate once here; tabs reuse these quest groups and dropdown choices instead of rescanning the database.
    self.zoneMap, self.zones = JourneyData.Build(true)
    coroutine.yield()

    -- Pre-initialize faction data used by the "Quests by Faction" tab so it is ready on first open.
    if _QuestieJourney.questsByFaction then
        if _QuestieJourney.questsByFaction.InitializeFactionData then
            _QuestieJourney.questsByFaction:InitializeFactionData()
        end
        if _QuestieJourney.questsByFaction.InitializeFactionQuestData then
            _QuestieJourney.questsByFaction:InitializeFactionQuestData()
        end
    end

    coroutine.yield()
    self:BuildMainFrame()

    -- Set up default keybinding for Journey window
    self:SetupKeybinding()
end

function QuestieJourney:BuildMainFrame()
    if (not QuestieJourneyFrame) then
        local journeyFrame = QuestieOptionsWindow.Create({
            name = "QuestieJourneyFrame",
            title = l10n("%s's Journey", GetUnitName("player", true)),
            width = 1000,
            height = 650,
            resizable = true,
            minWidth = 760,
            minHeight = 480,
        })
        journeyFrame:HookScript("OnHide", function()
            isWindowShown = false
            if notesPopupWinIsOpen then
                notesPopupWin:Hide()
                notesPopupWin = nil
                notesPopupWinIsOpen = false
            end
        end)
        local previousSideTab
        for _, tab in ipairs(journeyTabs) do
            journeyCanvases[tab.key] = CreateJourneyCanvas(journeyFrame.canvasContainer)
            journeySideTabs[tab.key] = QuestieOptionsWindow.CreateSideTab(
                journeyFrame, tab.key, tab, previousSideTab, SelectJourneyTab)
            previousSideTab = journeySideTabs[tab.key]
        end

        local settingsButton
        if QuestieOptionsControls and QuestieOptionsControls.CreateStyledButton then
            settingsButton = QuestieOptionsControls.CreateStyledButton(journeyFrame, 150)
        else
            settingsButton = CreateFrame("Button", nil, journeyFrame)
            settingsButton:SetSize(150, 32)
        end
        settingsButton:SetPoint("TOPRIGHT", journeyFrame, "TOPRIGHT", -20, -52)
        settingsButton:SetFrameLevel(journeyFrame:GetFrameLevel() + 1)
        settingsButton:SetText(l10n("Questie Options"))
        settingsButton:SetScript("OnClick", function()
            QuestieCombatQueue:Queue(function()
                QuestieJourney:ToggleJourneyWindow()
                QuestieOptionsEngine:ToggleConfigWindow()
            end)
        end)
        journeyFrame.SettingsButton = settingsButton

        -- Keep the public tab-group contract used by the minimap menu and quest links.
        QuestieJourney.tabGroup = {
            SelectTab = function(_, group)
                SelectJourneyTab(group)
            end,
        }

        journeyFrame:Hide()
        QuestieJourneyFrame = journeyFrame
        SelectJourneyTab("journey")
    end
end

function QuestieJourney:IsShown()
    return isWindowShown
end

---Open a quest in the active Journey tree when it is available there.
---@param questId QuestId
---@return boolean opened
function QuestieJourney:OpenQuestInCurrentView(questId)
    if _QuestieJourney.lastOpenWindow == "zone"
        and _QuestieJourney.questsByZone
        and _QuestieJourney.questsByZone.OpenQuest then
        return _QuestieJourney.questsByZone:OpenQuest(questId)
    elseif _QuestieJourney.lastOpenWindow == "faction"
        and _QuestieJourney.questsByFaction
        and _QuestieJourney.questsByFaction.OpenQuest then
        return _QuestieJourney.questsByFaction:OpenQuest(questId)
    end

    return false
end

---Open quest details in the active Zone/Faction pane when no tree row exists.
---@param questId QuestId
---@return boolean opened
function QuestieJourney:OpenQuestDetailsInCurrentView(questId)
    if _QuestieJourney.lastOpenWindow == "zone"
        and _QuestieJourney.questsByZone
        and _QuestieJourney.questsByZone.OpenQuestDetails then
        return _QuestieJourney.questsByZone:OpenQuestDetails(questId)
    elseif _QuestieJourney.lastOpenWindow == "faction"
        and _QuestieJourney.questsByFaction
        and _QuestieJourney.questsByFaction.OpenQuestDetails then
        return _QuestieJourney.questsByFaction:OpenQuestDetails(questId)
    end

    return false
end

-- There are ways to toggle this function before the frame has been created
function QuestieJourney:ToggleJourneyWindow()
    if (not Questie.started) then
        print(Questie:Colorize(l10n("Please wait a moment for Questie to finish loading")))
        return
    end

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

function QuestieJourney:SetupKeybinding()
    _G.BINDING_NAME_QUESTIE_TOGGLE_JOURNEY = l10n("Toggle My Journey")

    -- Only ever attempt to set the default keybind once, so we never fight a user who later changes or removes their bindings
    if Questie.db.global.journeyKeybindDefaultApplied then
        return
    end
    Questie.db.global.journeyKeybindDefaultApplied = true

    local currentBinding = GetBindingKey("QUESTIE_TOGGLE_JOURNEY")
    if not currentBinding and not C_KeyBindings.GetBindingByKey(";") then
        SetBinding("SEMICOLON", "QUESTIE_TOGGLE_JOURNEY")
        Questie.Debug(Questie.DEBUG_INFO, "Set default keybind ';' for Questie Journey")
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
