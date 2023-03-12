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
    header:SetText(l10n('Select Your Continent and Zone'))
    header:SetFullWidth(true)
    container:AddChild(header)

    QuestieJourneyUtils:Spacer(container)

    contDropdown = _CreateContinentDropdown()
    container:AddChild(contDropdown)

    zoneDropdown = _CreateZoneDropdown()
    container:AddChild(zoneDropdown)

    QuestieJourneyUtils:Spacer(container)

    header = AceGUI:Create("Heading")
    header:SetText(l10n('Zone Quests'))
    header:SetFullWidth(true)
    container:AddChild(header)

    QuestieJourneyUtils:Spacer(container)

    treegroup:SetFullHeight(true)
    treegroup:SetFullWidth(true)
    treegroup:SetLayout("fill")
    container:AddChild(treegroup)
end

_CreateContinentDropdown = function()
    local dropdown = AceGUI:Create("Dropdown")
    dropdown:SetList(QuestieJourney.continents)
    dropdown:SetText(l10n('Select Your Continent'))
    dropdown:SetCallback("OnValueChanged", _HandleContinentSelection)

    currentContinentId = QuestiePlayer:GetCurrentContinentId()
    if _QuestieJourney.lastZoneSelection[1] then
        currentContinentId = _QuestieJourney.lastZoneSelection[1]
    end

    dropdown:SetValue(currentContinentId)
    return dropdown
end

_CreateZoneDropdown = function()
    local dropdown = AceGUI:Create("Dropdown")

    local currentZoneId = QuestiePlayer:GetCurrentZoneId()
    if _QuestieJourney.lastZoneSelection[2] then
        currentZoneId = _QuestieJourney.lastZoneSelection[2]
    end

    local zones = QuestieJourney.zones[currentContinentId]
    if currentZoneId and currentZoneId > 0 and zones then
        local sortedZones = QuestieJourneyUtils:GetSortedZoneKeys(zones)
        dropdown:SetList(zones, sortedZones)
        dropdown:SetValue(currentZoneId)

        local zoneTree = _QuestieJourney.questsByZone:CollectZoneQuests(currentZoneId)
        _QuestieJourney.questsByZone:ManageTree(treegroup, zoneTree)
    elseif currentZoneId == RESET and zones then
        dropdown:SetText(l10n('Select Your Zone'))
        local sortedZones = QuestieJourneyUtils:GetSortedZoneKeys(zones)
        dropdown:SetList(zones, sortedZones)
    else
        dropdown:SetDisabled(true)
    end

    dropdown:SetCallback("OnValueChanged", _HandleZoneSelection)
    return dropdown
end

_HandleContinentSelection = function(key, _)
    if (key.value == QuestieJourney.questCategoryKeys.CLASS) then
        local _, class, _ = UnitClass("player")
        local classKey = QuestieDB:GetZoneOrSortForClass(class)
        local zoneTree = _QuestieJourney.questsByZone:CollectZoneQuests(classKey)
        _QuestieJourney.questsByZone:ManageTree(treegroup, zoneTree)
        zoneDropdown.frame:Hide()
    elseif (key.value == QuestieJourney.questCategoryKeys.PROFESSIONS) then
        local professionList = QuestieJourney.zones[key.value]
        local playerProfessions = QuestieProfessions:GetPlayerProfessionNames()

        local relevantProfessions = {}
        for id, possibleName in pairs(professionList) do
            for _, name in pairs(playerProfessions) do
                if possibleName == name then
                    relevantProfessions[id] = professionList[id]
                    break
                end
            end
        end
        local text = l10n('Select Your Profession')
        if (not next(relevantProfessions)) then
            text = l10n('No Quests found')
            zoneDropdown:SetDisabled(true)
        else
            zoneDropdown:SetDisabled(false)
        end
        zoneDropdown:SetList(relevantProfessions)
        zoneDropdown:SetText(text)
        zoneDropdown.frame:Show()
    else
        local sortedZones = QuestieJourneyUtils:GetSortedZoneKeys(QuestieJourney.zones[key.value])
        zoneDropdown:SetList(QuestieJourney.zones[key.value], sortedZones)
        zoneDropdown:SetText(l10n("Select Your Zone"))
        zoneDropdown:SetDisabled(false)
        zoneDropdown.frame:Show()
    end

    _QuestieJourney.lastZoneSelection[2] = RESET
    _QuestieJourney.lastZoneSelection[1] = key.value
end

_HandleZoneSelection = function(key, _)
    local zoneTree = _QuestieJourney.questsByZone:CollectZoneQuests(key.value)
    _QuestieJourney.questsByZone:ManageTree(treegroup, zoneTree)
    _QuestieJourney.lastZoneSelection[2] = key.value
end
