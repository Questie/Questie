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
---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule("ZoneDB")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")
---@type QuestieOptionsControls
local QuestieOptionsControls = QuestieLoader:ImportModule("QuestieOptionsControls")

--- QuestieGUI
local QuestieGUI = QuestieLoader:ImportModule("QuestieGUI")

local RESET = -1000
local playerClass = UnitClassBase("player")

local _CreateContinentDropdown, _CreateZoneDropdown
local _HandleAllZonesSelection, _HandleContinentSelection, _HandleZoneSelection

local selectedContinentId
local contDropdown, zoneDropdown, treegroup

local function ApplyModernDropdown(dropdown, width)
    if QuestieOptionsControls and QuestieOptionsControls.ApplyModernDropdown then
        QuestieOptionsControls.ApplyModernDropdown(dropdown, width)
    end
end

-- function that draws 'Quests By Zone' tab
function _QuestieJourney.questsByZone:DrawTab(container)
    -- The Journey canvas releases its children when switching tabs, but the
    -- zone tab's module-local tree reference can outlive that widget. Clear it
    -- before rebuilding so returning from Advanced Search gets fresh callbacks.
    if _QuestieJourney.questsByZone.ResetTree then
        _QuestieJourney.questsByZone:ResetTree()
    end

    ---@class AceSimpleGroup
    treegroup = QuestieGUI:Create("SimpleGroup")

    QuestieOptionsControls.CreateModernDividerGroup(container, l10n("Select Category"))

    QuestieJourneyUtils:Spacer(container)

    contDropdown = _CreateContinentDropdown()
    container:AddChild(contDropdown)

    zoneDropdown = _CreateZoneDropdown()
    container:AddChild(zoneDropdown)

    QuestieJourneyUtils:Spacer(container)

    QuestieOptionsControls.CreateModernDividerGroup(container, l10n("Quests"))

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
    local dropdown = QuestieGUI:Create("Dropdown")
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
    ApplyModernDropdown(dropdown, 200)
    dropdown:SetList(list, order)
    dropdown:SetText(l10n("All Quests"))
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
    elseif currentContinentId == 947 and Questie.IsForever then -- Azeroth
        selectedContinentId = questCategoryKeys.ZEPHRAS_ISLE
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
    local dropdown = QuestieGUI:Create("Dropdown")
    dropdown:SetWidth(200)
    ApplyModernDropdown(dropdown, 200)
    local currentZoneId = QuestiePlayer:GetCurrentZoneId()
    if _QuestieJourney.lastZoneSelection[2] then
        currentZoneId = _QuestieJourney.lastZoneSelection[2]
    end

    local zones = QuestieJourney.zones[selectedContinentId]
    if currentZoneId == RESET and zones then
        dropdown:SetText(l10n("Select Zone"))
        local sortedZones = QuestieJourneyUtils:GetSortedZoneKeys(zones)
        dropdown:SetList(zones, sortedZones)
    elseif currentZoneId and zones then
        -- Replace fake IDs with manual corrections
        local subZoneToParentZoneOverride = loadstring(ZoneDB.private.subZoneToParentZoneOverride)()
        currentZoneId = subZoneToParentZoneOverride[currentZoneId] or currentZoneId

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
    elseif (key.value == QuestieJourney.questCategoryKeys.DUNGEONS) then
        local text = l10n("Select Dungeon")
        local dungeonZones = QuestieJourney.zones[QuestieJourney.questCategoryKeys.DUNGEONS] or {}
        local sortedDungeons = QuestieJourneyUtils:GetSortedZoneKeys(dungeonZones)
        zoneDropdown:SetList(dungeonZones, sortedDungeons)
        zoneDropdown:SetDisabled(false)
        zoneDropdown:SetText(text)
        zoneDropdown.frame:Show()
    elseif (key.value == QuestieJourney.questCategoryKeys.BATTLEGROUNDS) then
        local text = l10n("Select Battleground")
        local bgZones = QuestieJourney.zones[QuestieJourney.questCategoryKeys.BATTLEGROUNDS] or {}
        local sortedBGs = QuestieJourneyUtils:GetSortedZoneKeys(bgZones)
        zoneDropdown:SetList(bgZones, sortedBGs)
        zoneDropdown:SetDisabled(false)
        zoneDropdown:SetText(text)
        zoneDropdown.frame:Show()
    elseif (key.value == QuestieJourney.questCategoryKeys.EVENTS) then
        local text = l10n("Select Event")
        local eventZones = QuestieJourney.zones[QuestieJourney.questCategoryKeys.EVENTS] or {}
        local sortedEvents = QuestieJourneyUtils:GetSortedZoneKeys(eventZones)
        zoneDropdown:SetList(eventZones, sortedEvents)
        zoneDropdown:SetDisabled(false)
        zoneDropdown:SetText(text)
        zoneDropdown.frame:Show()
    elseif (key.value == QuestieJourney.questCategoryKeys.SCENARIOS) then
        local text = l10n("Select Scenario")
        local scenarioZones = QuestieJourney.zones[QuestieJourney.questCategoryKeys.SCENARIOS] or {}
        local sortedScenarios = QuestieJourneyUtils:GetSortedZoneKeys(scenarioZones)
        zoneDropdown:SetList(scenarioZones, sortedScenarios)
        zoneDropdown:SetDisabled(false)
        zoneDropdown:SetText(text)
        zoneDropdown.frame:Show()
    elseif (key.value == QuestieJourney.questCategoryKeys.PROFESSIONS) then
        local text = l10n("Select Profession")
        local professionZones = QuestieJourney.zones[QuestieJourney.questCategoryKeys.PROFESSIONS] or {}
        local sortedProfessions = QuestieJourneyUtils:GetSortedZoneKeys(professionZones)
        zoneDropdown:SetList(professionZones, sortedProfessions)
        zoneDropdown:SetDisabled(false)
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

local function FindQuestZoneLocation(questId)
    local zoneMap = QuestieJourney.zoneMap or {}
    local zonesByCategory = QuestieJourney.zones or {}
    local quest = QuestieDB.GetQuest(questId)
    local preferredZoneOrSort = quest and quest.zoneOrSort

    -- Prefer the quest's own zoneOrSort so dungeon and special-category quests
    -- open in their canonical dropdown rather than an arbitrary duplicate.
    if preferredZoneOrSort and zoneMap[preferredZoneOrSort] and zoneMap[preferredZoneOrSort][questId] then
        for categoryId, zones in pairs(zonesByCategory) do
            if zones[preferredZoneOrSort] then
                return categoryId, preferredZoneOrSort
            end
        end
    end

    for categoryId, zones in pairs(zonesByCategory) do
        for zoneId in pairs(zones) do
            if zoneMap[zoneId] and zoneMap[zoneId][questId] then
                return categoryId, zoneId
            end
        end
    end

    return nil, nil
end

---Select the quest's real category/zone and open it in the zone tree.
---@param questId QuestId
---@return boolean opened
function _QuestieJourney.questsByZone:OpenQuestInLocation(questId)
    if not contDropdown or not zoneDropdown or not treegroup then
        return false
    end

    local categoryId, zoneId = FindQuestZoneLocation(questId)
    if not categoryId then
        return false
    end

    -- Rebuild the zone list/tree for the target category. SetValue updates the
    -- visible dropdown without relying on the widget to fire its callback.
    contDropdown:SetValue(categoryId)
    _HandleContinentSelection({value = categoryId})

    if zoneDropdown.frame:IsShown() and zoneId then
        zoneDropdown:SetValue(zoneId)
        _HandleZoneSelection({value = zoneId})
    end

    if _QuestieJourney.questsByZone.OpenQuest then
        return _QuestieJourney.questsByZone:OpenQuest(questId)
    end

    return false
end

function QuestieJourney:OpenQuestInZone(questId)
    return _QuestieJourney.questsByZone:OpenQuestInLocation(questId)
end
