---@type QuestieJourney
local QuestieJourney = QuestieLoader:CreateModule("QuestieJourney")
local _QuestieJourney = QuestieJourney.private
-------------------------
--Import modules.
-------------------------
---@type JourneyQuestList
local JourneyQuestList = QuestieLoader:ImportModule("JourneyQuestList")
---@type JourneyThread
local JourneyThread = QuestieLoader:ImportModule("JourneyThread")
---@type QuestieJourneyUtils
local QuestieJourneyUtils = QuestieLoader:ImportModule("QuestieJourneyUtils")
---@type QuestieOptionsControls
local QuestieOptionsControls = QuestieLoader:ImportModule("QuestieOptionsControls")
---@type QuestiePlayer
local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule("ZoneDB")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local ALL_QUESTS = "ALL_QUESTS"
local DROPDOWN_WIDTH = 220

local playerClass = UnitClassBase("player")

-- What is shown. Whenever the tab is opened, it goes to where the player is, until they choose something.
---@type number|string|nil A key of l10n.continentLookup or ALL_QUESTS
local category
---@type number? Nil for a category that isn't divided into zones, or while none is chosen
local zoneId
local hasUserChosen = false

---@type JourneyQuestList.Instance
local list
local categoryDropdown, zoneDropdown

---The category the player is in, as a key of l10n.continentLookup.
---@return number?
local function _GetPlayerCategory()
    local questCategoryKeys = QuestieJourney.questCategoryKeys
    local continentId = QuestiePlayer:GetCurrentContinentId()
    if continentId == 0 then
        return questCategoryKeys.EASTERN_KINGDOMS
    elseif continentId == 1 then
        return questCategoryKeys.KALIMDOR
    elseif continentId == 530 then
        return questCategoryKeys.OUTLAND
    elseif continentId == 571 then
        return questCategoryKeys.NORTHREND
    elseif continentId == 870 then
        return questCategoryKeys.PANDARIA
    elseif continentId == 947 and Questie.IsForever then -- Azeroth
        return questCategoryKeys.ZEPHRAS_ISLE
    elseif l10n.zoneLookup[continentId] then
        return questCategoryKeys.DUNGEONS
    end
end

---@return number?
local function _GetPlayerZone()
    -- Replace fake IDs with manual corrections
    local subZoneToParentZoneOverride = loadstring(ZoneDB.private.subZoneToParentZoneOverride)()
    local currentZoneId = QuestiePlayer:GetCurrentZoneId()
    return subZoneToParentZoneOverride[currentZoneId] or currentZoneId
end

---The zones to choose from. Nil for a category that isn't divided into zones.
---@return table<number, string>?
local function _GetZones()
    local questCategoryKeys = QuestieJourney.questCategoryKeys
    if category == ALL_QUESTS or category == questCategoryKeys.CLASS or category == questCategoryKeys.PET_BATTLES then
        return nil
    end
    return QuestieJourney.zones[category]
end

---@return string
local function _GetZonePlaceholder()
    local questCategoryKeys = QuestieJourney.questCategoryKeys
    if category == questCategoryKeys.DUNGEONS then
        return l10n("Select Dungeon")
    elseif category == questCategoryKeys.BATTLEGROUNDS then
        return l10n("Select Battleground")
    elseif category == questCategoryKeys.EVENTS then
        return l10n("Select Event")
    elseif category == questCategoryKeys.SCENARIOS then
        return l10n("Select Scenario")
    elseif category == questCategoryKeys.PROFESSIONS then
        return l10n("Select Profession")
    end
    return l10n("Select Zone")
end

---Yields, so it runs in a thread.
---@async
---@return table<QuestId, boolean>
local function _CollectAllQuestIds()
    local allQuestIds = {}
    for _, quests in pairs(QuestieJourney.zoneMap) do
        for questId in pairs(quests) do
            allQuestIds[questId] = true
        end
        JourneyThread.YieldIfNeeded()
    end
    return allQuestIds
end

---Yields, so it runs in a thread.
---@async
---@return JourneyTreeNode[]? nodes Nil while no zone is chosen
local function _CollectQuests()
    local questCategoryKeys = QuestieJourney.questCategoryKeys
    local questsByZone = _QuestieJourney.questsByZone
    if category == ALL_QUESTS then
        return questsByZone:CategorizeQuests(_CollectAllQuestIds())
    elseif category == questCategoryKeys.CLASS then
        return questsByZone:CollectZoneQuests(QuestieDB:GetZoneOrSortForClass(playerClass)) or {}
    elseif category == questCategoryKeys.PET_BATTLES then
        return questsByZone:CollectZoneQuests(QuestieDB.sortKeys.PET_BATTLE) or {}
    end
    if zoneId then
        return questsByZone:CollectZoneQuests(zoneId) or {}
    end
end

---@param newCategory number|string
---@param newZoneId number?
local function _Choose(newCategory, newZoneId)
    category, zoneId = newCategory, newZoneId
    hasUserChosen = true
    _QuestieJourney.questsByZone.Refresh()
end

---@param questId QuestId
---@return number? questCategory Nil if the quest can't be found through the dropdowns
---@return number? questZoneId Nil for a category that isn't divided into zones
local function _FindQuest(questId)
    local function IsIn(zoneOrSort)
        local quests = QuestieJourney.zoneMap[zoneOrSort]
        return quests ~= nil and quests[questId] ~= nil
    end

    for questCategory, zones in pairs(QuestieJourney.zones) do
        if QuestieJourney.continents[questCategory] then
            for questZoneId in pairs(zones) do
                if IsIn(questZoneId) then
                    return questCategory, questZoneId
                end
            end
        end
    end
    if IsIn(QuestieDB:GetZoneOrSortForClass(playerClass)) then
        return QuestieJourney.questCategoryKeys.CLASS
    end
end

---@return table<number|string, string>
local function _GetCategories()
    local categories = {[ALL_QUESTS] = l10n("All Quests")}
    for id, name in pairs(QuestieJourney.continents) do
        categories[id] = name
    end
    return categories
end

---@return table
local function _GetCategoryOrder()
    local order = {}
    for id in pairs(QuestieJourney.continents) do
        table.insert(order, id)
    end
    table.sort(order) -- By the order of questCategoryKeys
    table.insert(order, 1, ALL_QUESTS)
    table.insert(order, 2, QuestieOptionsControls.MENU_DIVIDER)
    return order
end

---@param canvas Frame
function _QuestieJourney.questsByZone.Build(canvas)
    categoryDropdown = QuestieOptionsControls.Create(canvas, {
        type = "dropdown",
        title = l10n("Select Category"),
        options = _GetCategories,
        sortOrder = _GetCategoryOrder,
        get = function() return category end,
        set = function(newCategory) _Choose(newCategory, nil) end,
    }, DROPDOWN_WIDTH, 1)
    categoryDropdown:SetPoint("TOPLEFT", canvas, "TOPLEFT", 4, -8)

    zoneDropdown = QuestieOptionsControls.Create(canvas, {
        type = "dropdown",
        title = "",
        placeholder = _GetZonePlaceholder,
        options = function() return _GetZones() or {} end,
        sortOrder = function() return QuestieJourneyUtils:GetSortedZoneKeys(_GetZones() or {}) end,
        get = function() return zoneId end,
        set = function(newZoneId) _Choose(category, newZoneId) end,
    }, DROPDOWN_WIDTH, 1)
    zoneDropdown:SetPoint("TOPLEFT", categoryDropdown, "TOPRIGHT", 0, 0)

    list = JourneyQuestList.Create(canvas, 64)
end

function _QuestieJourney.questsByZone.OnSelected()
    if not hasUserChosen then
        category, zoneId = _GetPlayerCategory(), _GetPlayerZone()
    end
end

function _QuestieJourney.questsByZone.Refresh()
    QuestieOptionsControls.Refresh(categoryDropdown)
    QuestieOptionsControls.Refresh(zoneDropdown)
    zoneDropdown:SetShown(_GetZones() ~= nil)

    JourneyQuestList.Load(list, tostring(category) .. " " .. tostring(zoneId), _CollectQuests)
end

---Shows a quest, and the zone it is in if it isn't listed.
---@param questId QuestId
function _QuestieJourney.questsByZone.OpenQuest(questId)
    if not JourneyQuestList.Contains(list, questId) then
        local questCategory, questZoneId = _FindQuest(questId)
        if questCategory then
            _Choose(questCategory, questZoneId)
        end
    end
    JourneyQuestList.Select(list, questId)
end
