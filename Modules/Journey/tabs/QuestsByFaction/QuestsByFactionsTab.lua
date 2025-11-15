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

local AceGUI = LibStub("AceGUI-3.0")

local RESET = -1000

local _CreateExpansionDropdown, _CreateFactionDropdown
local _HandleExpansionSelection, _HandleFactionSelection

local selectedExpansionKey
local expansionDropdown, factionDropdown, treegroup

local function _GetDefaultExpansion()
    local order = QuestieJourney.availableFactionExpansionOrder
    if order and #order > 0 then
        return order[1]
    end
    return nil
end

function _QuestieJourney.questsByFaction:DrawTab(container)
    _QuestieJourney.questsByFaction:InitializeFactionData()

    ---@class AceSimpleGroup
    treegroup = AceGUI:Create("SimpleGroup")

    local header = AceGUI:Create("Heading")
    header:SetText(l10n('Select Your Expansion and Faction'))
    header:SetFullWidth(true)
    container:AddChild(header)

    QuestieJourneyUtils:Spacer(container)

    expansionDropdown = _CreateExpansionDropdown()
    container:AddChild(expansionDropdown)

    factionDropdown = _CreateFactionDropdown()
    container:AddChild(factionDropdown)

    QuestieJourneyUtils:Spacer(container)

    header = AceGUI:Create("Heading")
    header:SetText(l10n('Faction Quests'))
    header:SetFullWidth(true)
    container:AddChild(header)

    QuestieJourneyUtils:Spacer(container)

    treegroup:SetFullHeight(true)
    treegroup:SetFullWidth(true)
    treegroup:SetLayout("fill")
    container:AddChild(treegroup)
end

_CreateExpansionDropdown = function()
    local dropdown = AceGUI:Create("Dropdown")
    dropdown:SetList(QuestieJourney.availableFactionExpansions, QuestieJourney.availableFactionExpansionOrder)
    dropdown:SetText(l10n('Select Your Expansion'))
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
    local dropdown = AceGUI:Create("Dropdown")

    local currentFactionId = RESET
    if not selectedExpansionKey then
        selectedExpansionKey = _GetDefaultExpansion()
    end
    local factions = selectedExpansionKey and QuestieJourney.factionsByExpansion[selectedExpansionKey]

    if _QuestieJourney.lastFactionSelection[2] then
        currentFactionId = _QuestieJourney.lastFactionSelection[2]
    else
        currentFactionId = RESET
    end

    if currentFactionId == RESET then
        dropdown:SetText(l10n('Select Your Faction'))
    end

    if factions and next(factions) then
        local sortedFactions = QuestieJourneyUtils:GetSortedZoneKeys(factions)
        dropdown:SetList(factions, sortedFactions)

        if currentFactionId ~= RESET and factions[currentFactionId] then
            dropdown:SetValue(currentFactionId)

            local factionTree = _QuestieJourney.questsByFaction:CollectFactionQuests(currentFactionId)
            if factionTree then
                _QuestieJourney.questsByFaction:ManageTree(treegroup, factionTree)
            end
        elseif currentFactionId ~= RESET then
            dropdown:SetText(l10n('Select Your Faction'))
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
    factionDropdown:SetText(l10n('Select Your Faction'))
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


