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
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
---@type QuestieReputation
local QuestieReputation = QuestieLoader:ImportModule("QuestieReputation")
---@type QuestieCorrections
local QuestieCorrections = QuestieLoader:ImportModule("QuestieCorrections")
---@type QuestieEvent
local QuestieEvent = QuestieLoader:ImportModule("QuestieEvent")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local AceGUI = LibStub("AceGUI-3.0")

local RESET = -1000
local _, playerClass, _ = UnitClass("player")

local _CreateAllZoneDropdown, _CreateContinentDropdown, _CreateZoneDropdown
local _HandleAllZonesSelection, _HandleByContinentSelection, _HandleContinentSelection, _HandleZoneSelection

local selectedContinentId
local allZonesDropdown, contDropdown, zoneDropdown, treegroup

-- function that draws 'Quests By Zone' tab
function _QuestieJourney.questsByZone:DrawTab(container)
    ---@class AceSimpleGroup
    treegroup = AceGUI:Create("SimpleGroup")

    local header = AceGUI:Create("Heading")
    header:SetText(l10n('Select Your Continent and Zone'))
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
    dropdown:SetText(l10n('Select Your Continent'))
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
        dropdown:SetText(l10n('Select Your Zone'))
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

    local allQuestIds = {}

    -- add all quest IDs from regular zones
    for zoneId, quests in pairs(QuestieJourney.zoneMap or {}) do
        for questId in pairs(quests) do
            allQuestIds[questId] = true
        end
    end
    -- add all quest IDs from class quests
    local classKey = QuestieDB:GetZoneOrSortForClass(playerClass)
    local classQuests = QuestieJourney.zoneMap[classKey]
    if classQuests then
        for questId in pairs(classQuests) do
            allQuestIds[questId] = true
        end
    end
    -- add all quest IDs from profession quests
    for profId, _ in pairs(QuestieJourney.zones[QuestieJourney.questCategoryKeys.PROFESSIONS] or {}) do
        local profQuests = QuestieJourney.zoneMap[profId]
        if profQuests then
            for questId in pairs(profQuests) do
                allQuestIds[questId] = true
            end
        end
    end
    -- add all quest IDs from pet battle quests
    local petQuests = QuestieJourney.zoneMap[QuestieDB.sortKeys.PET_BATTLE]
    if petQuests then
        for questId in pairs(petQuests) do
            allQuestIds[questId] = true
        end
    end

    -- sort all quest IDs
    local sortedQuestByLevel = QuestieLib:SortQuestIDsByLevel(allQuestIds)

    local availableCounter = 0
    local prequestMissingCounter = 0
    local completedCounter = 0
    local repeatableCounter = 0
    local unobtainableCounter = 0

    for _, levelAndQuest in pairs(sortedQuestByLevel) do
        local questId = levelAndQuest[2]

        if QuestieCorrections.hiddenQuests and ((not QuestieCorrections.hiddenQuests[questId]) or QuestieEvent:IsEventQuest(questId)) and QuestieDB.QuestPointers[questId] then
            local temp = {}
            temp.value = questId
            temp.text = QuestieLib:GetColoredQuestName(questId, Questie.db.profile.enableTooltipsQuestLevel, false)

            if Questie.db.char.complete[questId] then
                table.insert(allZoneTree[3].children, temp)
                completedCounter = completedCounter + 1
            else
                local queryResult = QuestieDB.QueryQuest(
                        questId,
                        {
                        "exclusiveTo",
                        "nextQuestInChain",
                        "parentQuest",
                        "preQuestSingle",
                        "preQuestGroup",
                        "requiredMinRep",
                        "requiredMaxRep",
                        "requiredSpell"
                        }
                ) or {}
                local exclusiveTo = queryResult[1]
                local nextQuestInChain = queryResult[2]
                local parentQuest = queryResult[3]
                local preQuestSingle = queryResult[4]
                local preQuestGroup = queryResult[5]
                local requiredMinRep = queryResult[6]
                local requiredMaxRep = queryResult[7]
                local requiredSpell = queryResult[8]

                -- exclusive quests will never be available since another quests permanently blocks them
                -- marking them as complete should be the most satisfying solution for user
                if (nextQuestInChain and Questie.db.char.complete[nextQuestInChain]) or (exclusiveTo and QuestieDB:IsExclusiveQuestInQuestLogOrComplete(exclusiveTo)) then
                    table.insert(allZoneTree[3].children, temp)
                    completedCounter = completedCounter + 1
                -- the parent quest has been completed
                elseif parentQuest and Questie.db.char.complete[parentQuest] then
                    table.insert(allZoneTree[3].children, temp)
                    completedCounter = completedCounter + 1
                -- unobtainable reputation quests
                elseif not QuestieReputation.HasReputation(requiredMinRep, requiredMaxRep) then
                    table.insert(allZoneTree[5].children, temp)
                    unobtainableCounter = unobtainableCounter + 1
                -- a single pre quest is missing
                elseif not QuestieDB:IsPreQuestSingleFulfilled(preQuestSingle) then
                    table.insert(allZoneTree[2].children, temp)
                    prequestMissingCounter = prequestMissingCounter + 1
                -- multiple pre quests are missing
                elseif not QuestieDB:IsPreQuestGroupFulfilled(preQuestGroup) then
                    table.insert(allZoneTree[2].children, temp)
                    prequestMissingCounter = prequestMissingCounter + 1
                -- repeatable quests
                elseif QuestieDB.IsRepeatable(questId) then
                    table.insert(allZoneTree[4].children, temp)
                    repeatableCounter = repeatableCounter + 1
                -- quests which require you to NOT have learned a spell (most likely a fake quest for SoD runes)
                elseif requiredSpell and requiredSpell < 0 and (IsSpellKnownOrOverridesKnown(requiredSpell) or IsPlayerSpell(requiredSpell)) then
                    table.insert(allZoneTree[3].children, temp)
                    completedCounter = completedCounter + 1
                -- available quests
                else
                    table.insert(allZoneTree[1].children, temp)
                    availableCounter = availableCounter + 1
                end
            end
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

_HandleByContinentSelection = function()
    contDropdown.frame:Show()
    zoneDropdown.frame:Show()

    _QuestieJourney.lastZoneSelection[3] = nil

    if selectedContinentId then
        contDropdown:SetValue(selectedContinentId)
        _HandleContinentSelection({value = selectedContinentId})
    end
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
        zoneDropdown:SetText(l10n("Select Your Zone"))
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