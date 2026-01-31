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

local ExpandFactionHeader, GetNumFactions, GetFactionInfo = ExpandFactionHeader, GetNumFactions, GetFactionInfo

local RESET = -1000

local _CreateExpansionDropdown, _CreateFactionDropdown
local _HandleExpansionSelection, _HandleFactionSelection
local _GetWatchedFactionId

local selectedExpansionKey
local expansionDropdown, factionDropdown, treegroup

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
    treegroup = AceGUI:Create("SimpleGroup")

    local header = AceGUI:Create("Heading")
    header:SetText(l10n('Select Expansion and Faction'))
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

_GetWatchedFactionId = function()
    if not GetNumFactions or not GetFactionInfo then
        return nil
    end

    if ExpandFactionHeader then
        ExpandFactionHeader(0)
    end

    for i = 1, GetNumFactions() do
        local _, _, _, _, _, _, _, _, isHeader, _, _, isWatched, _, factionID = GetFactionInfo(i)
        if not isHeader and isWatched and factionID then
            return factionID
        end
    end

    return nil
end

_CreateExpansionDropdown = function()
    local dropdown = AceGUI:Create("Dropdown")
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
    local dropdown = AceGUI:Create("Dropdown")

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


