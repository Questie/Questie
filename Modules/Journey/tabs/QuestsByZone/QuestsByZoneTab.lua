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

local _CreateAllZoneDropdown, _CreateContinentDropdown, _CreateZoneDropdown
local _HandleAllZonesSelection, _HandleContinentSelection, _HandleZoneSelection, _HandleByContinentSelection

local selectedContinentId
local allZonesDropdown, contDropdown, zoneDropdown, treegroup

-- function that draws 'Quests By Zone' tab
function _QuestieJourney.questsByZone:DrawTab(container)
    ---@class AceSimpleGroup
    treegroup = AceGUI:Create("SimpleGroup")

    local header = AceGUI:Create("Heading")
    header:SetText(l10n('Select Continent and Zone'))
    header:SetFullWidth(true)
    container:AddChild(header)

    QuestieJourneyUtils:Spacer(container)

    allZonesDropdown = _CreateAllZoneDropdown()
    container:AddChild(allZonesDropdown)

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
    if _QuestieJourney.lastZoneSelection[1] == "ALL_ZONES" then
        allZonesDropdown:SetValue("ALL_ZONES")
        _HandleAllZonesSelection()
    elseif selectedContinentId == QuestieJourney.questCategoryKeys.CLASS then
        local classKey = QuestieDB:GetZoneOrSortForClass(playerClass)
        local zoneTree = _QuestieJourney.questsByZone:CollectZoneQuests(classKey)
        _QuestieJourney.questsByZone:ManageTree(treegroup, zoneTree)
        zoneDropdown.frame:Hide()
    end
end

_CreateAllZoneDropdown = function()
    local dropdown = AceGUI:Create("Dropdown")

    dropdown:SetList({
        ["ALL_ZONES"] = l10n("All Zones"),
        ["BY_CONTINENT"] = l10n("By Continent")
    })
    dropdown:SetText(l10n("Zone Scope"))
    dropdown:SetValue("BY_CONTINENT")
    dropdown:SetCallback("OnValueChanged", function(widget, event, key)
        if key == "ALL_ZONES" then
            _HandleAllZonesSelection()
        else
            _HandleByContinentSelection()
        end
    end)

    return dropdown
end

_CreateContinentDropdown = function()
    local dropdown = AceGUI:Create("Dropdown")
    dropdown:SetList(QuestieJourney.continents)
    dropdown:SetText(l10n('Select Continent'))
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
    local allZoneTree = {
        [1] = {
            value = "a",
            text = l10n('Available Quests'),
            children = {}
        },
        [2] = {
            value = "p",
            text = l10n('Missing Pre Quest'),
            children = {}
        },
        [3] = {
            value = "c",
            text = l10n('Completed Quests'),
            children = {}
        },
        [4] = {
            value = "r",
            text = l10n('Repeatable Quests'),
            children = {}
        },
        [5] = {
            value = "u",
            text = l10n('Unobtainable Quests'),
            children = {}
        }
    }

    local availableCounter = 0
    local prequestMissingCounter = 0
    local completedCounter = 0
    local repeatableCounter = 0
    local unobtainableCounter = 0

    for zoneId, _ in pairs(QuestieJourney.zoneMap or {}) do
        local zoneTree = _QuestieJourney.questsByZone:CollectZoneQuests(zoneId)
        if zoneTree then
            -- merge each category
            for i = 1, 5 do
                if zoneTree[i] and zoneTree[i].children then
                    for _, quest in pairs(zoneTree[i].children) do
                        table.insert(allZoneTree[i].children, quest)
                    end
                end
            end
        end
    end

    -- also add class/professions/pet battles
    local classKey = QuestieDB:GetZoneOrSortForClass(playerClass)
    local classTree = _QuestieJourney.questsByZone:CollectZoneQuests(classKey)
    if classTree then
        for i = 1, 5 do
            if classTree[i] and classTree[i].children then
                for _, quest in pairs(classTree[i].children) do
                    table.insert(allZoneTree[i].children, quest)
                end
            end
        end
    end
    for profId, _ in pairs(QuestieJourney.zones[QuestieJourney.questCategoryKeys.PROFESSIONS] or {}) do
        local profTree = _QuestieJourney.questsByZone:CollectZoneQuests(profId)
        if profTree then
            for i = 1, 5 do
                if profTree[i] and profTree[i].children then
                    for _, quest in pairs(profTree[i].children) do
                        table.insert(allZoneTree[i].children, quest)
                    end
                end
            end
        end
    end
    local petTree = _QuestieJourney.questsByZone:CollectZoneQuests(QuestieDB.sortKeys.PET_BATTLE)
    if petTree then
        for i = 1, 5 do
            if petTree[i] and petTree[i].children then
                for _, quest in pairs(petTree[i].children) do
                    table.insert(allZoneTree[i].children, quest)
                end
            end
        end
    end

    for i = 1, 5 do
        local count = #allZoneTree[i].children
        if i == 1 then
            availableCounter = count
        elseif i == 2 then
            prequestMissingCounter = count
        elseif i == 3 then
            completedCounter = count
        elseif i == 4 then
            repeatableCounter = count
        elseif i == 5 then
            unobtainableCounter = count
        end
    end

    local totalCounter = availableCounter + completedCounter + prequestMissingCounter
    allZoneTree[1].text = allZoneTree[1].text .. ' [ '..  availableCounter ..'/'.. totalCounter ..' ]'
    allZoneTree[2].text = allZoneTree[2].text .. ' [ '..  prequestMissingCounter ..'/'.. totalCounter ..' ]'
    allZoneTree[3].text = allZoneTree[3].text .. ' [ '..  completedCounter ..'/'.. totalCounter ..' ]'
    allZoneTree[4].text = allZoneTree[4].text .. ' [ '..  repeatableCounter ..' ]'
    allZoneTree[5].text = allZoneTree[5].text .. ' [ '..  unobtainableCounter ..' ]'

    _QuestieJourney.questsByZone:ManageTree(treegroup, allZoneTree)

    contDropdown.frame:Hide()
    zoneDropdown.frame:Hide()

    _QuestieJourney.lastZoneSelection[1] = "ALL_ZONES"
    _QuestieJourney.lastZoneSelection[2] = RESET
    _QuestieJourney.lastZoneSelection[3] = nil
end

_HandleContinentSelection = function(key, _)
    local text
    
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
        local sortedZones = QuestieJourneyUtils:GetSortedZoneKeys(QuestieJourney.zones[key.value])
        zoneDropdown:SetList(QuestieJourney.zones[key.value], sortedZones)
        zoneDropdown:SetText(l10n("Select Zone"))
        zoneDropdown:SetDisabled(false)
        zoneDropdown.frame:Show()
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

_HandleByContinentSelection = function()
    contDropdown.frame:Show()
    zoneDropdown.frame:Show()

    _QuestieJourney.lastZoneSelection[3] = nil

    if selectedContinentId then
        contDropdown:SetValue(selectedContinentId)
        _HandleContinentSelection({value = selectedContinentId})
    end
end