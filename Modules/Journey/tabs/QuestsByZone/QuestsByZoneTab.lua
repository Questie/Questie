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

local AceGUI = LibStub("AceGUI-3.0")


-- function that draws the Tab for Zone Quests
function _QuestieJourney.questsByZone:DrawTab(container)
    -- Header
    local header = AceGUI:Create("Heading")
    header:SetText(QuestieLocale:GetUIString('JOURNEY_SELECT_HEAD'))
    header:SetFullWidth(true)
    container:AddChild(header)
    QuestieJourneyUtils:Spacer(container)

    local contDropdown = AceGUI:Create("LQDropdown")
    local zoneDropdown = AceGUI:Create("LQDropdown")
    ---@class AceSimpleGroup
    local treegroup = AceGUI:Create("SimpleGroup")

    -- Dropdown for Continent
    contDropdown:SetList(QuestieJourney.continents)
    contDropdown:SetText(QuestieLocale:GetUIString('JOURNEY_SELECT_CONT'))

    local currentContinentId = QuestiePlayer:GetCurrentContinentId()
    contDropdown:SetValue(currentContinentId)

    contDropdown:SetCallback("OnValueChanged", function(key, checked)
        local sortedZones = QuestieJourneyUtils:GetSortedZoneKeys(QuestieJourney.zones[key.value])
        zoneDropdown:SetList(QuestieJourney.zones[key.value], sortedZones)
        zoneDropdown:SetText(QuestieLocale:GetUIString('JOURNEY_SELECT_ZONE'))
        zoneDropdown:SetDisabled(false)
    end)
    container:AddChild(contDropdown)

    -- Dropdown for Zone
    zoneDropdown:SetText(QuestieLocale:GetUIString('JOURNEY_SELECT_ZONE'))

    local currentZoneId = QuestiePlayer:GetCurrentZoneId()
    if currentZoneId and currentZoneId > 0 then
        local sortedZones = QuestieJourneyUtils:GetSortedZoneKeys(QuestieJourney.zones[currentContinentId])
        zoneDropdown:SetList(QuestieJourney.zones[currentContinentId], sortedZones)
        zoneDropdown:SetValue(currentZoneId)
        local zoneTree = _QuestieJourney.questsByZone:CollectZoneQuests(currentZoneId)
        -- Build Tree
        _QuestieJourney.questsByZone:ManageTree(treegroup, zoneTree)
    else
        zoneDropdown:SetDisabled(true)
    end

    zoneDropdown:SetCallback("OnValueChanged", function(key, checked)
        -- Create Tree View
        local zoneTree = _QuestieJourney.questsByZone:CollectZoneQuests(key.value)
        -- Build Tree
        _QuestieJourney.questsByZone:ManageTree(treegroup, zoneTree)
    end)
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