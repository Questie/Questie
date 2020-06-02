
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

local AceGUI = LibStub("AceGUI-3.0")

local journeyFrame = {}
local isWindowShown = false
_QuestieJourney.lastOpenWindow = "journey"


local notesPopupWin = nil
local notesPopupWinIsOpen = false
function NotePopup()
end

QuestieJourney.tabGroup = nil
function QuestieJourney:Initialize()
    QuestieJourney.continents = LangContinentLookup
    --[[for cont, zone in pairs(LangZoneLookup) do
        QuestieJourney.zones[cont] = {}
        for zoneId, zoneName in pairs(zone) do
            local areQuestsInZone = QuestieDB:ZoneHasQuests(zoneId)--_QuestieJourney.questsByZone:CollectZoneQuests(zoneId)
            if areQuestsInZone == false then
                QuestieJourney.zones[cont][zoneId] = nil
            else
                QuestieJourney.zones[cont][zoneId] = zoneName
            end
        end
    end]]--
    if not Questie.db.global.zoneMapCache then
        local zoneMap = {} -- todo: move this into a library function
        for id in pairs(QuestieDB.QuestPointers) do 
            local zoneOrSort, startedBy, finishedBy = unpack(QuestieDB.QueryQuest(id, "zoneOrSort", "startedBy", "finishedBy"))
            if zoneOrSort > 0 then
                local alternativeZoneID = QuestieDBZone:GetAlternativeZoneId(zoneOrSort)
                if not zoneMap[zoneOrSort] then zoneMap[zoneOrSort] = {} end
                zoneMap[zoneOrSort][id] = true
                if alternativeZoneID then
                    if not zoneMap[alternativeZoneID] then zoneMap[alternativeZoneID] = {} end
                    zoneMap[alternativeZoneID][id] = true
                end
            else
                if startedBy then
                    if startedBy[1] then
                        for id in pairs(startedBy[1]) do
                            local spawns = QuestieDB.QueryNPCSingle(id, "spawns")
                            if spawns then
                                for zone in pairs(spawns) do
                                    if not zoneMap[zone] then zoneMap[zone] = {} end
                                    zoneMap[zone][id] = true
                                end
                            end
                        end
                    end
                    if startedBy[2] then
                        for id in pairs(startedBy[2]) do
                            local spawns = QuestieDB.QueryObjectSingle(id, "spawns")
                            if spawns then
                                for zone in pairs(spawns) do
                                    if not zoneMap[zone] then zoneMap[zone] = {} end
                                    zoneMap[zone][id] = true
                                end
                            end
                        end
                    end
                end
                
                if finishedBy then
                    if finishedBy[1] then
                        for id in pairs(finishedBy[1]) do
                            local spawns = QuestieDB.QueryNPCSingle(id, "spawns")
                            if spawns then
                                for zone in pairs(spawns) do
                                    if not zoneMap[zone] then zoneMap[zone] = {} end
                                    zoneMap[zone][id] = true
                                end
                            end
                        end
                    end
                    if finishedBy[2] then
                        for id in pairs(finishedBy[2]) do
                            local spawns = QuestieDB.QueryObjectSingle(id, "spawns")
                            if spawns then
                                for zone in pairs(spawns) do
                                    if not zoneMap[zone] then zoneMap[zone] = {} end
                                    zoneMap[zone][id] = true
                                end
                            end
                        end
                    end
                end
            end
        end

        QuestieJourney.zoneMap = zoneMap
        Questie.db.global.zoneMapCache = zoneMap -- todo: put this data in the db somewhere instead? shouldnt be put on a savedvar. But this was by far
                                                 -- the heaviest hitting thing on player login
                                                 -- https://cdn.discordapp.com/attachments/599156810603298816/717288298669670470/unknown.png
    else
        QuestieJourney.zoneMap = Questie.db.global.zoneMapCache
    end
  
    for cont, zone in pairs(LangZoneLookup) do
        QuestieJourney.zones[cont] = {}
        for zoneId, zoneName in pairs(zone) do
            local areQuestsInZone = QuestieJourney.zoneMap[zoneId]
            if areQuestsInZone == false then
                QuestieJourney.zones[cont][zoneId] = nil
            else
                QuestieJourney.zones[cont][zoneId] = zoneName
            end
        end
    end
    
    QuestieJourney:BuildMainFrame()
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
    entry.Party = QuestiePlayer:GetPartyMembers()

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
    entry.Party = QuestiePlayer:GetPartyMembers()

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
        entry.Party = QuestiePlayer:GetPartyMembers()

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
    entry.Party = QuestiePlayer:GetPartyMembers()

    tinsert(Questie.db.char.journey, entry)
end
