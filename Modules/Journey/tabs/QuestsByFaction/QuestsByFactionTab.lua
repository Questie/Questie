---@type QuestieJourney
local QuestieJourney = QuestieLoader:CreateModule("QuestieJourney")
local _QuestieJourney = QuestieJourney.private
-------------------------
--Import modules.
-------------------------
---@type QuestieJourneyUtils
local QuestieJourneyUtils = QuestieLoader:ImportModule("QuestieJourneyUtils")
---@type QuestiePlayer
local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
---@type QuestieProfessions
local QuestieProfessions = QuestieLoader:ImportModule("QuestieProfessions")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local AceGUI = LibStub("AceGUI-3.0")

local RESET = -1000

local _CreateFactionDropdown, _HandleFactionSelection
local _CreateFactionGroupDropdown, _HandleFactionGroupSelection

local currentFactionGroupId, currentFactionId
local factionGroupDropdown, factionDropdown, treegroup

-- function that draws the Tab for Faction Quests
function _QuestieJourney.questsByFaction:DrawTab(container)
    ---@class AceSimpleGroup
    treegroup = AceGUI:Create("SimpleGroup")

    -- Header
    local header = AceGUI:Create("Heading")
    header:SetText(l10n('Select Your Faction'))
    header:SetFullWidth(true)
    container:AddChild(header)

    QuestieJourneyUtils:Spacer(container)

    factionGroupDropdown = _CreateFactionGroupDropdown()
    container:AddChild(factionGroupDropdown)

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

_CreateFactionGroupDropdown = function()
    local dropdown = AceGUI:Create("Dropdown")
    dropdown:SetList(QuestieJourney.factionGroups)
    dropdown:SetText(l10n('Select Your Faction Group'))
    dropdown:SetCallback("OnValueChanged", _HandleFactionGroupSelection)

    if _QuestieJourney.lastFactionSelection[1] then
        currentFactionGroupId = _QuestieJourney.lastFactionSelection[1]
    end
    dropdown:SetValue(currentFactionGroupId)

    return dropdown
end

_CreateFactionDropdown = function()
    local dropdown = AceGUI:Create("Dropdown")
   
    dropdown:SetText(l10n('Select Your Faction'))
    dropdown:SetCallback("OnValueChanged", _HandleFactionSelection)
    
    local _, _, _, _, _, localCurrentFactionId = GetWatchedFactionInfo()
    if localCurrentFactionId then
        currentFactionId = localCurrentFactionId
    end
    if _QuestieJourney.lastFactionSelection[2] then
        currentFactionId = _QuestieJourney.lastFactionSelection[2]
    end

    if currentFactionId and not currentFactionGroupId then
        currentFactionGroupId = QuestieJourney.factionIdToParentIdTable[currentFactionId]
        factionGroupDropdown:SetValue(currentFactionGroupId)
    end

    if currentFactionGroupId then
        dropdown:SetList(QuestieJourney.factions[currentFactionGroupId])
    else
        dropdown:SetDisabled(true)
    end

    if currentFactionId then
        dropdown:SetValue(currentFactionId)
        local factionTree = _QuestieJourney.questsByFaction:CollectFactionQuests(currentFactionId)
        _QuestieJourney.questsByFaction:ManageTree(treegroup, factionTree)
    end
    return dropdown
end

_HandleFactionGroupSelection = function(key, _)
    local factions = QuestieJourney.factions[key.value]
    factionDropdown:SetList(factions)
    factionDropdown:SetText(l10n("Select Your Faction"))
    factionDropdown:SetDisabled(false)
    factionDropdown.frame:Show()
    
    _QuestieJourney.lastFactionSelection[2] = RESET
    _QuestieJourney.lastFactionSelection[1] = key.value
end

_HandleFactionSelection = function(key, _)
    local factionTree = _QuestieJourney.questsByFaction:CollectFactionQuests(key.value)
    _QuestieJourney.questsByFaction:ManageTree(treegroup, factionTree)
    _QuestieJourney.lastFactionSelection[2] = key.value
end