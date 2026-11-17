---@type QuestieCompat
local QuestieCompat = QuestieLoader:ImportModule("QuestieCompat")

---@type QuestieJourney
local QuestieJourney = QuestieLoader:CreateModule("QuestieJourney")
local _QuestieJourney = QuestieJourney.private
-------------------------
--Import modules.
-------------------------
---@type QuestieJourneyUtils
local QuestieJourneyUtils = QuestieLoader:ImportModule("QuestieJourneyUtils")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")
---@type QuestieOptionsControls
local QuestieOptionsControls = QuestieLoader:ImportModule("QuestieOptionsControls")

--- QuestieGUI
local QuestieGUI = QuestieLoader:ImportModule("QuestieGUI")

local ExpandFactionHeader, GetNumFactions, GetFactionInfo = QuestieCompat.ExpandFactionHeader, QuestieCompat.GetNumFactions, QuestieCompat.GetFactionInfo

local RESET = -1000

local _CreateExpansionDropdown, _CreateFactionDropdown
local _HandleExpansionSelection, _HandleFactionSelection
local _GetWatchedFactionId

local selectedExpansionKey
local expansionDropdown, factionDropdown, treegroup

local function ApplyModernDropdown(dropdown, width)
    if QuestieOptionsControls and QuestieOptionsControls.ApplyModernDropdown then
        QuestieOptionsControls.ApplyModernDropdown(dropdown, width)
    end
end

local function _GetDefaultExpansion()
    local watchedFactionId = _GetWatchedFactionId and _GetWatchedFactionId()
    if watchedFactionId and QuestieJourney.factionsByExpansion and QuestieJourney.availableFactionExpansionOrder then
        for _, expansionKey in ipairs(QuestieJourney.availableFactionExpansionOrder) do
            local factions = QuestieJourney.factionsByExpansion[expansionKey]
            if factions and factions[watchedFactionId] then
                return expansionKey
            end
        end
    end

    local order = QuestieJourney.availableFactionExpansionOrder
    if order and #order > 0 then
        return order[1]
    end
    return nil
end

function _QuestieJourney.questsByFaction:DrawTab(container)
    _QuestieJourney.questsByFaction:InitializeFactionData()

    ---@class AceSimpleGroup
    treegroup = QuestieGUI:Create("SimpleGroup")

    QuestieOptionsControls.CreateModernDividerGroup(container, l10n('Select Expansion and Faction'))

    QuestieJourneyUtils:Spacer(container)

    expansionDropdown = _CreateExpansionDropdown()
    factionDropdown = _CreateFactionDropdown()

    local dropdownRow = QuestieGUI:Create("SimpleGroup")
    dropdownRow:SetLayout("Flow")
    dropdownRow:SetFullWidth(true)
    dropdownRow:SetHeight(48)
    dropdownRow:AddChild(expansionDropdown)
    dropdownRow:AddChild(factionDropdown)
    container:AddChild(dropdownRow)

    QuestieJourneyUtils:Spacer(container)

    QuestieOptionsControls.CreateModernDividerGroup(container, l10n('Quests'))

    QuestieJourneyUtils:Spacer(container)

    treegroup:SetFullHeight(true)
    treegroup:SetFullWidth(true)
    treegroup:SetLayout("fill")
    container:AddChild(treegroup)
end

_GetWatchedFactionId = function()
    ExpandFactionHeader(0)

    for i = 1, GetNumFactions() do
        local _, _, _, _, _, _, _, _, isHeader, _, _, isWatched, _, factionID = GetFactionInfo(i)
        if not isHeader and isWatched and factionID then
            return factionID
        end
    end

    return nil
end

_CreateExpansionDropdown = function()
    local dropdown = QuestieGUI:Create("Dropdown")
    ApplyModernDropdown(dropdown, 200)
    dropdown:SetList(QuestieJourney.availableFactionExpansions, QuestieJourney.availableFactionExpansionOrder)
    dropdown:SetCallback("OnValueChanged", _HandleExpansionSelection)

    local lastExpansion = _QuestieJourney.lastFactionSelection[1]
    if not lastExpansion or not QuestieJourney.availableFactionExpansions[lastExpansion] then
        lastExpansion = _GetDefaultExpansion()
    end

    selectedExpansionKey = lastExpansion
    if selectedExpansionKey then
        dropdown:SetValue(selectedExpansionKey)
    else
        dropdown:SetDisabled(true)
    end

    return dropdown
end

_CreateFactionDropdown = function()
    local dropdown = QuestieGUI:Create("Dropdown")
    dropdown:SetWidth(205)
    ApplyModernDropdown(dropdown, 200)
    if not selectedExpansionKey then
        selectedExpansionKey = _GetDefaultExpansion()
    end
    local factions = selectedExpansionKey and QuestieJourney.factionsByExpansion[selectedExpansionKey]

    local currentFactionId = RESET
    if _QuestieJourney.lastFactionSelection[2] then
        currentFactionId = _QuestieJourney.lastFactionSelection[2]
    end

    if currentFactionId == RESET then
        dropdown:SetText(l10n('Select Faction'))
    end

    if factions and next(factions) then
        local sortedFactions = QuestieJourneyUtils:GetSortedZoneKeys(factions)
        dropdown:SetList(factions, sortedFactions)

        if currentFactionId == RESET then
            local watchedFactionId = _GetWatchedFactionId and _GetWatchedFactionId()
            if watchedFactionId and factions[watchedFactionId] then
                currentFactionId = watchedFactionId
                _QuestieJourney.lastFactionSelection[2] = currentFactionId
            end
        end

        if currentFactionId ~= RESET and factions[currentFactionId] then
            dropdown:SetValue(currentFactionId)

            local factionTree = _QuestieJourney.questsByFaction:CollectFactionQuests(currentFactionId)
            if factionTree then
                _QuestieJourney.questsByFaction:ManageTree(treegroup, factionTree)
            end
        elseif currentFactionId ~= RESET then
            dropdown:SetText(l10n('Select Faction'))
        end
    else
        dropdown:SetDisabled(true)
    end

    dropdown:SetCallback("OnValueChanged", _HandleFactionSelection)
    return dropdown
end

_HandleExpansionSelection = function(widget, _)
    selectedExpansionKey = widget.value

    factionDropdown:SetDisabled(false)
    factionDropdown:SetText(l10n('Select Faction'))
    local factions = QuestieJourney.factionsByExpansion[selectedExpansionKey]

    if factions and next(factions) then
        local sortedFactions = QuestieJourneyUtils:GetSortedZoneKeys(factions)
        factionDropdown:SetList(factions, sortedFactions)
    else
        factionDropdown:SetList({})
        factionDropdown:SetDisabled(true)
    end

    _QuestieJourney.lastFactionSelection[2] = RESET
    _QuestieJourney.lastFactionSelection[1] = selectedExpansionKey
end

_HandleFactionSelection = function(widget, _)
    local factionId = widget.value

    local factionTree = _QuestieJourney.questsByFaction:CollectFactionQuests(factionId)
    if factionTree then
        _QuestieJourney.questsByFaction:ManageTree(treegroup, factionTree)
        _QuestieJourney.lastFactionSelection[2] = factionId
    end
end


