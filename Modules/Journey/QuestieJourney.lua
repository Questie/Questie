
---@class QuestieJourney
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
---@type QuestieDBZone
local QuestieDBZone = QuestieLoader:ImportModule("QuestieDBZone")

-- Useful doc about the AceGUI TreeGroup: https://github.com/hurricup/WoW-Ace3/blob/master/AceGUI-3.0/widgets/AceGUIContainer-TreeGroup.lua

local tinsert = table.insert

QuestieJourney.continents = {}
QuestieJourney.zones = {}
QuestieJourney.tabGroup = nil

local AceGUI = LibStub("AceGUI-3.0")

local isWindowShown = false
_QuestieJourney.lastOpenWindow = "journey"

local notesPopupWin = nil
local notesPopupWinIsOpen = false

-- forward declaration
local _BuildZoneMapCache, _GetRelevantZones, _SetZonesForNPCs, _SetZonesForObjects


function QuestieJourney:Initialize()
    self.continents = LangContinentLookup

    if (not Questie.db.global.zoneMapCache) then
        _BuildZoneMapCache()
    else
        self.zoneMap = Questie.db.global.zoneMapCache
    end

    self.zones = _GetRelevantZones()

    self:BuildMainFrame()
end

_BuildZoneMapCache = function()
    local zoneMap = {} -- todo: move this into a library function
    for questId in pairs(QuestieDB.QuestPointers) do
        local queryResult = QuestieDB.QueryQuest(questId, "startedBy", "finishedBy", "requiredRaces", "requiredClasses", "zoneOrSort")
        local startedBy, finishedBy, requiredRaces, requiredClasses, zoneOrSort = unpack(queryResult)

        if QuestiePlayer:HasRequiredRace(requiredRaces) and QuestiePlayer:HasRequiredClass(requiredClasses) then
            if zoneOrSort > 0 then
                local parentZoneId = QuestieDBZone:GetParentZoneId(zoneOrSort)

                if parentZoneId then
                    if (not zoneMap[parentZoneId]) then
                        zoneMap[parentZoneId] = {}
                    end
                    zoneMap[parentZoneId][questId] = true
                else
                    if (not zoneMap[zoneOrSort]) then
                        zoneMap[zoneOrSort] = {}
                    end
                    zoneMap[zoneOrSort][questId] = true
                end
            else
                if startedBy then
                    zoneMap = _SetZonesForNPCs(zoneMap, startedBy[1])
                    zoneMap = _SetZonesForObjects(zoneMap, startedBy[2])
                end

                if finishedBy then
                    zoneMap = _SetZonesForNPCs(zoneMap, finishedBy[1])
                    zoneMap = _SetZonesForObjects(zoneMap, finishedBy[2])
                end
            end
        end
    end

    QuestieJourney.zoneMap = zoneMap
    Questie.db.global.zoneMapCache = zoneMap -- todo: put this data in the db somewhere instead? shouldnt be put on a savedvar. But this was by far
                                             -- the heaviest hitting thing on player login
                                             -- https://cdn.discordapp.com/attachments/599156810603298816/717288298669670470/unknown.png
end

_SetZonesForNPCs = function(zoneMap, npcSpawns)
    if (not npcSpawns) then
        return zoneMap
    end

    for npcId in pairs(npcSpawns) do
        local spawns = QuestieDB.QueryNPCSingle(npcId, "spawns")
        if spawns then
            for zone in pairs(spawns) do
                if not zoneMap[zone] then zoneMap[zone] = {} end
                zoneMap[zone][npcId] = true
            end
        end
    end

    return zoneMap
end

_SetZonesForObjects = function(zoneMap, objectSpawns)
    if (not objectSpawns) then
        return zoneMap
    end

    for objectId in pairs(objectSpawns) do
        local spawns = QuestieDB.QueryNPCSingle(objectId, "spawns")
        if spawns then
            for zone in pairs(spawns) do
                if not zoneMap[zone] then zoneMap[zone] = {} end
                zoneMap[zone][objectId] = true
            end
        end
    end

    return zoneMap
end

_GetRelevantZones = function()
    local zones = {}
    for cont, zone in pairs(LangZoneCategoryLookup) do
        zones[cont] = {}
        for zoneId, zoneName in pairs(zone) do
            local zoneQuests = QuestieJourney.zoneMap[zoneId]
            if (not zoneQuests) then
                zones[cont][zoneId] = nil
            else
                zones[cont][zoneId] = zoneName
            end
        end
    end

    return zones
end

function QuestieJourney:BuildMainFrame()
    if (QuestieJourney.frame == nil) then
        local frame = AceGUI:Create("Frame")
        frame:SetCallback("OnClose", function()
            isWindowShown = false
            if notesPopupWinIsOpen then
                notesPopupWin:Hide()
                notesPopupWin = nil
                notesPopupWinIsOpen = false
            end
        end)
        frame:SetTitle(QuestieLocale:GetUIString('JOURNEY_TITLE', UnitName("player")))
        frame:SetLayout("Fill")

        QuestieJourney.frame = frame

        local tabGroup = AceGUI:Create("TabGroup")
        tabGroup:SetLayout("Flow")
        tabGroup:SetTabs({
            {
                text = QuestieLocale:GetUIString('JOUNREY_TAB'),
                value="journey"
            },
            {
                text = QuestieLocale:GetUIString('JOURNEY_ZONE_TAB'),
                value="zone"
            },
            {
                text = QuestieLocale:GetUIString('JOURNEY_SEARCH_TAB'),
                value="search"
            }
        })
        tabGroup:SetCallback("OnGroupSelected", function(widget, event, group) _QuestieJourney:JourneySelectTabGroup(widget, event, group) end)
        tabGroup:SelectTab("journey")

        QuestieJourney.tabGroup = tabGroup

        QuestieJourney.frame:AddChild(QuestieJourney.tabGroup)

        QuestieJourney.frame:Hide()
        _G["QuestieJourneyFrame"] = QuestieJourney.frame
        table.insert(UISpecialFrames, "QuestieJourneyFrame")
    end
end

function QuestieJourney:IsShown()
    return isWindowShown
end

function QuestieJourney:ToggleJourneyWindow()
    if not isWindowShown then
        PlaySound(882)

        local treeGroup = _QuestieJourney:JourneySelectTabGroup(_QuestieJourney.containerCache, nil, _QuestieJourney.lastOpenWindow)
        if treeGroup then
            _QuestieJourney.treeCache = treeGroup
        end

        QuestieJourney.frame:Show()
        isWindowShown = true
    else
        QuestieJourney.frame:Hide()
        isWindowShown = false
    end
end

function QuestieJourney:PlayerLevelUp(level)
    -- Complete Quest added to Journey
    ---@type JourneyEntry
    local entry = {}
    entry.Event = "Level"
    entry.NewLevel = level
    entry.Timestamp = time()

    tinsert(Questie.db.char.journey, entry)
end

function QuestieJourney:AcceptQuest(questId)
    -- Add quest accept journey note.
    ---@type JourneyEntry
    local entry = {}
    entry.Event = "Quest"
    entry.SubType = "Accept"
    entry.Quest = questId
    entry.Level = QuestiePlayer:GetPlayerLevel()
    entry.Timestamp = time()

    tinsert(Questie.db.char.journey, entry)
end

function QuestieJourney:AbandonQuest(questId)
    -- Abandon Quest added to Journey
    -- first check to see if the quest has been completed already or not
    local skipAbandon = false
    for i in ipairs(Questie.db.char.journey) do

        local entry = Questie.db.char.journey[i]
        if entry.Event == "Quest" then
            if entry.Quest == questId then
                if entry.SubType == "Complete" then
                    skipAbandon = true
                end
            end
        end
    end

    if not skipAbandon then
        ---@type JourneyEntry
        local entry = {}
        entry.Event = "Quest"
        entry.SubType = "Abandon"
        entry.Quest = questId
        entry.Level = QuestiePlayer:GetPlayerLevel()
        entry.Timestamp = time()

        tinsert(Questie.db.char.journey, entry)
    end
end

function QuestieJourney:CompleteQuest(questId)
    -- Complete Quest added to Journey
    ---@class JourneyEntry
    local entry = {}
    entry.Event = "Quest"
    entry.SubType = "Complete"
    entry.Quest = questId
    entry.Level = QuestiePlayer:GetPlayerLevel()
    entry.Timestamp = time()

    tinsert(Questie.db.char.journey, entry)
end
