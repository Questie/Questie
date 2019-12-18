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

    local CDropdown = AceGUI:Create("LQDropdown")
    local zDropdown = AceGUI:Create("LQDropdown")
    local treegroup = AceGUI:Create("SimpleGroup")

    -- Dropdown for Continent
    CDropdown:SetList(QuestieJourney.continents)
    CDropdown:SetText(QuestieLocale:GetUIString('JOURNEY_SELECT_CONT'))

    local currentContinentId = QuestiePlayer:GetCurrentContinentId()
    CDropdown:SetValue(currentContinentId)

    CDropdown:SetCallback("OnValueChanged", function(key, checked)
        local sortedZones = QuestieJourneyUtils:GetSortedZoneKeys(QuestieJourney.zones[key.value])
        zDropdown:SetList(QuestieJourney.zones[key.value], sortedZones)
        zDropdown:SetText(QuestieLocale:GetUIString('JOURNEY_SELECT_ZONE'))
        zDropdown:SetDisabled(false)
    end)
    container:AddChild(CDropdown)

    -- Dropdown for Zone
    zDropdown:SetText(QuestieLocale:GetUIString('JOURNEY_SELECT_ZONE'))

    local currentZoneId = QuestiePlayer:GetCurrentZoneId()
    if currentZoneId > 0 then
        local sortedZones = QuestieJourneyUtils:GetSortedZoneKeys(QuestieJourney.zones[currentContinentId])
        zDropdown:SetList(QuestieJourney.zones[currentContinentId], sortedZones)
        zDropdown:SetValue(currentZoneId)
        local zoneTree = _QuestieJourney.questsByZone:CollectZoneQuests(currentZoneId)
        -- Build Tree
        _QuestieJourney.questsByZone:ManageTree(treegroup, zoneTree)
    else
        zDropdown:SetDisabled(true)
    end

    zDropdown:SetCallback("OnValueChanged", function(key, checked)
        -- Create Tree View
        local zoneTree = _QuestieJourney.questsByZone:CollectZoneQuests(key.value)
        -- Build Tree
        _QuestieJourney.questsByZone:ManageTree(treegroup, zoneTree)
    end)
    container:AddChild(zDropdown)

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