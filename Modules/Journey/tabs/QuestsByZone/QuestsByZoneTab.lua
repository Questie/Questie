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
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")

local AceGUI = LibStub("AceGUI-3.0")

local _CreateContinentDropdown, _CreateZoneDropdown
local _HandleContinentSelection, _HandleZoneSelection

local currentContinentId
local contDropdown, zoneDropdown, treegroup

-- function that draws the Tab for Zone Quests
function _QuestieJourney.questsByZone:DrawTab(container)
    ---@class AceSimpleGroup
    treegroup = AceGUI:Create("SimpleGroup")

    -- Header
    local header = AceGUI:Create("Heading")
    header:SetText(QuestieLocale:GetUIString('JOURNEY_SELECT_HEAD'))
    header:SetFullWidth(true)
    container:AddChild(header)

    QuestieJourneyUtils:Spacer(container)

    currentContinentId = QuestiePlayer:GetCurrentContinentId()
    contDropdown = _CreateContinentDropdown()
    contDropdown:SetValue(currentContinentId)
    container:AddChild(contDropdown)

    zoneDropdown = _CreateZoneDropdown()
    container:AddChild(zoneDropdown)

    QuestieJourneyUtils:Spacer(container)

    header = AceGUI:Create("Heading")
    header:SetText(QuestieLocale:GetUIString('JOURNEY_QUESTS'))
    header:SetFullWidth(true)
    container:AddChild(header)

    QuestieJourneyUtils:Spacer(container)

    treegroup:SetFullHeight(true)
    treegroup:SetFullWidth(true)
    treegroup:SetLayout("fill")
    container:AddChild(treegroup)
end

_CreateContinentDropdown = function()
    local dropdown = AceGUI:Create("LQDropdown")
    dropdown:SetList(QuestieJourney.continents)
    dropdown:SetText(QuestieLocale:GetUIString('JOURNEY_SELECT_CONT'))
    dropdown:SetCallback("OnValueChanged", _HandleContinentSelection)
    return dropdown
end

_CreateZoneDropdown = function()
    local dropdown = AceGUI:Create("LQDropdown")
    dropdown:SetText(QuestieLocale:GetUIString('JOURNEY_SELECT_ZONE'))

    local currentZoneId = QuestiePlayer:GetCurrentZoneId()
    if currentZoneId and currentZoneId > 0 then
        local sortedZones = QuestieJourneyUtils:GetSortedZoneKeys(QuestieJourney.zones[currentContinentId])
        dropdown:SetList(QuestieJourney.zones[currentContinentId], sortedZones)
        dropdown:SetValue(currentZoneId)

        local zoneTree = _QuestieJourney.questsByZone:CollectZoneQuests(currentZoneId)
        _QuestieJourney.questsByZone:ManageTree(treegroup, zoneTree)
    else
        dropdown:SetDisabled(true)
    end

    dropdown:SetCallback("OnValueChanged", _HandleZoneSelection)
    return dropdown
end

_HandleContinentSelection = function(key, checked)
    if (key.value == 5) then
        local _, class, _ = UnitClass("player")
        local classKey = QuestieDB:GetZoneOrSortForClass(class)
        local zoneTree = _QuestieJourney.questsByZone:CollectZoneQuests(classKey)
        _QuestieJourney.questsByZone:ManageTree(treegroup, zoneTree)
        zoneDropdown.frame:Hide()
    else
        local sortedZones = QuestieJourneyUtils:GetSortedZoneKeys(QuestieJourney.zones[key.value])
        zoneDropdown:SetList(QuestieJourney.zones[key.value], sortedZones)
        zoneDropdown:SetText(QuestieLocale:GetUIString('JOURNEY_SELECT_ZONE'))
        zoneDropdown:SetDisabled(false)
        zoneDropdown.frame:Show()
    end
end

_HandleZoneSelection = function(key, checked)
    local zoneTree = _QuestieJourney.questsByZone:CollectZoneQuests(key.value)
    _QuestieJourney.questsByZone:ManageTree(treegroup, zoneTree)
end
