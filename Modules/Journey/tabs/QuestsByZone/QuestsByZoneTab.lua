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
local _, playerClass, _ = UnitClass("player")

local _CreateContinentDropdown, _CreateZoneDropdown
local _HandleAllZonesSelection, _HandleContinentSelection, _HandleZoneSelection

local selectedContinentId
local contDropdown, zoneDropdown, treegroup

-- function that draws 'Quests By Zone' tab
function _QuestieJourney.questsByZone:DrawTab(container)
    ---@class AceSimpleGroup
    treegroup = AceGUI:Create("SimpleGroup")

    local header = AceGUI:Create("Heading")
    header:SetText(l10n('Select Continent and Zone'))
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

    -- This needs to happen after all children are added, otherwise it will be shown again
    if _QuestieJourney.lastZoneSelection[1] == "ALL_QUESTS" then
        contDropdown:SetValue("ALL_QUESTS")
        _HandleAllZonesSelection()
    elseif selectedContinentId == QuestieJourney.questCategoryKeys.CLASS then
        local classKey = QuestieDB:GetZoneOrSortForClass(playerClass)
        local zoneTree = _QuestieJourney.questsByZone:CollectZoneQuests(classKey)
        _QuestieJourney.questsByZone:ManageTree(treegroup, zoneTree)
        zoneDropdown.frame:Hide()
    end
end

_CreateContinentDropdown = function()
    local dropdown = AceGUI:Create("Dropdown")
    local list = {
        ["ALL_QUESTS"] = l10n("All Quests"),
        ["_SEPARATOR"] = "|cff7f7f7f----------------|r"
    }
    for id, name in pairs(QuestieJourney.continents) do
        list[id] = name
    end
    local order = { "ALL_QUESTS", "_SEPARATOR" }
    -- Sort by numeric key (questCategoryKeys order) instead of alphabetically
    local sortedKeys = {}
    for id in pairs(QuestieJourney.continents) do
        table.insert(sortedKeys, id)
    end
    table.sort(sortedKeys)
    for _, key in ipairs(sortedKeys) do
        table.insert(order, key)
    end
    dropdown:SetList(list, order)
    dropdown:SetText(l10n('All Quests'))
    dropdown:SetCallback("OnValueChanged", _HandleContinentSelection)

    local currentContinentId = QuestiePlayer:GetCurrentContinentId()

    local questCategoryKeys = QuestieJourney.questCategoryKeys
    -- This mapping translates the actual continent ID to the keys of l10n.continentLookup
    if currentContinentId == 0 then -- Eastern Kingdoms
        selectedContinentId = questCategoryKeys.EASTERN_KINGDOMS
    elseif currentContinentId == 1 then -- Kalimdor
        selectedContinentId = questCategoryKeys.KALIMDOR
    elseif currentContinentId == 530 then -- Outland
        selectedContinentId = questCategoryKeys.OUTLAND
    elseif currentContinentId == 571 then -- Northrend
        selectedContinentId = questCategoryKeys.NORTHREND
    elseif currentContinentId == 870 then -- Pandaria
        selectedContinentId = questCategoryKeys.PANDARIA
    elseif l10n.zoneLookup[currentContinentId] then -- Dungeon
        selectedContinentId = questCategoryKeys.DUNGEONS
    end

    if _QuestieJourney.lastZoneSelection[1] then
        selectedContinentId = _QuestieJourney.lastZoneSelection[1]
    end

    dropdown:SetValue(selectedContinentId)
    return dropdown
end

_CreateZoneDropdown = function()
    local dropdown = AceGUI:Create("Dropdown")

    local currentZoneId = QuestiePlayer:GetCurrentZoneId()
    if _QuestieJourney.lastZoneSelection[2] then
        currentZoneId = _QuestieJourney.lastZoneSelection[2]
    end

    local zones = QuestieJourney.zones[selectedContinentId]
    if currentZoneId == RESET and zones then
        dropdown:SetText(l10n('Select Zone'))
        local sortedZones = QuestieJourneyUtils:GetSortedZoneKeys(zones)
        dropdown:SetList(zones, sortedZones)
    elseif currentZoneId and zones then
        local sortedZones = QuestieJourneyUtils:GetSortedZoneKeys(zones)
        dropdown:SetList(zones, sortedZones)
        dropdown:SetValue(currentZoneId)

        local zoneTree = _QuestieJourney.questsByZone:CollectZoneQuests(currentZoneId)
        _QuestieJourney.questsByZone:ManageTree(treegroup, zoneTree)
    else
        dropdown:SetDisabled(true)
    end

    dropdown:SetCallback("OnValueChanged", _HandleZoneSelection)
    return dropdown
end

_HandleAllZonesSelection = function()
    local allQuestIds = {}
    local zoneMap = QuestieJourney.zoneMap or {}

    -- add all quest IDs from regular zones
    for zoneId, quests in pairs(zoneMap) do
        for questId in pairs(quests) do
            allQuestIds[questId] = true
        end
    end
    -- add all quest IDs from class quests
    local classKey = QuestieDB:GetZoneOrSortForClass(playerClass)
    local classQuests = zoneMap[classKey]
    if classQuests then
        for questId in pairs(classQuests) do
            allQuestIds[questId] = true
        end
    end
    -- add all quest IDs from profession quests (all professions, not just player's)
    local professionList = QuestieJourney.zones[QuestieJourney.questCategoryKeys.PROFESSIONS]
    if professionList then
        for profId, _ in pairs(professionList) do
            local profQuests = zoneMap[profId]
            if profQuests then
                for questId in pairs(profQuests) do
                    allQuestIds[questId] = true
                end
            end
        end
    end
    -- add all quest IDs from pet battle quests
    local petQuests = zoneMap[QuestieDB.sortKeys.PET_BATTLE]
    if petQuests then
        for questId in pairs(petQuests) do
            allQuestIds[questId] = true
        end
    end

    -- use the shared categorization function
    local allZoneTree = _QuestieJourney.questsByZone:CategorizeQuests(allQuestIds)

    _QuestieJourney.questsByZone:ManageTree(treegroup, allZoneTree)

    zoneDropdown.frame:Hide()

    _QuestieJourney.lastZoneSelection[1] = "ALL_QUESTS"
    _QuestieJourney.lastZoneSelection[2] = RESET
    _QuestieJourney.lastZoneSelection[3] = nil
end

_HandleContinentSelection = function(key, _)
    if (key.value == "_SEPARATOR") then
        contDropdown:SetValue(_QuestieJourney.lastZoneSelection[1] or selectedContinentId)
        return
    end
    if (key.value == "ALL_QUESTS") then
        _HandleAllZonesSelection()
        return
    end
    if (key.value == QuestieJourney.questCategoryKeys.CLASS) then
        local classKey = QuestieDB:GetZoneOrSortForClass(playerClass)
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
        local text = l10n('Select Profession')
        if (not next(relevantProfessions)) then
            text = l10n('No Quests found')
            zoneDropdown:SetDisabled(true)
        else
            zoneDropdown:SetDisabled(false)
        end
        zoneDropdown:SetList(relevantProfessions)
        zoneDropdown:SetText(text)
        zoneDropdown.frame:Show()
    elseif (key.value == QuestieJourney.questCategoryKeys.PET_BATTLES) then
        local zoneTree = _QuestieJourney.questsByZone:CollectZoneQuests(QuestieDB.sortKeys.PET_BATTLE)
        _QuestieJourney.questsByZone:ManageTree(treegroup, zoneTree)
        zoneDropdown.frame:Hide()
    else
        local zones = QuestieJourney.zones[key.value]
        if zones then
            local sortedZones = QuestieJourneyUtils:GetSortedZoneKeys(zones)
            zoneDropdown:SetList(zones, sortedZones)
            zoneDropdown:SetText(l10n("Select Zone"))
            zoneDropdown:SetDisabled(false)
            zoneDropdown.frame:Show()
        else
            zoneDropdown:SetDisabled(true)
            zoneDropdown.frame:Hide()
        end
    end

    _QuestieJourney.lastZoneSelection[2] = RESET
    _QuestieJourney.lastZoneSelection[1] = key.value
    _QuestieJourney.lastZoneSelection[3] = nil
end

_HandleZoneSelection = function(key, _)
    local zoneTree = _QuestieJourney.questsByZone:CollectZoneQuests(key.value)
    _QuestieJourney.questsByZone:ManageTree(treegroup, zoneTree)
    _QuestieJourney.lastZoneSelection[2] = key.value
    _QuestieJourney.lastZoneSelection[3] = nil
end
