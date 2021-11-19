---@class QuestieComms
local QuestieComms = QuestieLoader:CreateModule("QuestieComms");
local _QuestieComms = QuestieComms.private
-------------------------
--Import modules.
-------------------------
---@type QuestieQuest
local QuestieQuest = QuestieLoader:ImportModule("QuestieQuest");
---@type QuestieSerializer
local QuestieSerializer = QuestieLoader:ImportModule("QuestieSerializer");
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib");
---@type QuestiePlayer
local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer");
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB");
---@type DailyQuests
local DailyQuests = QuestieLoader:ImportModule("DailyQuests");
---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule("ZoneDB")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local HBD = LibStub("HereBeDragonsQuestie-2.0")

-- Addon message prefix
_QuestieComms.prefix = "questie";
-- List of all players questlog private to prevent modification from the outside.
QuestieComms.remoteQuestLogs = {}
QuestieComms.remotePlayerClasses = {}
QuestieComms.remotePlayerEnabled = {}
QuestieComms.remotePlayerTimes = {}

-- The idea here is that all messages with the same "base number" are compatible
-- New message versions increase the number by 0.1, and if the message becomes "incompatible" you increase with 1
-- Say if the message is 1.5 it is valid as long as it is < 2. If it is 2.5 it is not compatible for example.
local commMessageVersion = 5.0;

local warnedUpdate = false;
local suggestUpdate = true;

-- forward declaration
local _DoYell

--Not used, contains a list of hashes for quest, used to compare change.
--_QuestieComms.questHashes = {};

--Channel types
_QuestieComms.QC_WRITE_ALLGUILD = "GUILD"
_QuestieComms.QC_WRITE_ALLGROUP = "PARTY"
_QuestieComms.QC_WRITE_ALLRAID = "RAID"
_QuestieComms.QC_WRITE_WHISPER = "WHISPER"
_QuestieComms.QC_WRITE_CHANNEL = "CHANNEL"
_QuestieComms.QC_WRITE_YELL = "YELL"

--Message types.
_QuestieComms.QC_ID_BROADCAST_QUEST_UPDATE = 1 -- send quest_log_update status to party/raid members
_QuestieComms.QC_ID_BROADCAST_QUEST_REMOVE = 2 -- send quest remove status to party/raid members
-- NYI ->
--[[
  _QuestieComms.QC_ID_BROADCAST_QUESTIE_GETVERSION = 2 -- ask anyone for the newest questie version
_QuestieComms.QC_ID_BROADCAST_QUESTIE_VERSION = 3 -- broadcast the current questie version
_QuestieComms.QC_ID_ASK_CHANGELOG = 4 -- ask a player for the changelog
_QuestieComms.QC_ID_SEND_CHANGELOG = 5
_QuestieComms.QC_ID_ASK_QUESTS = 6 -- ask a player for their quest progress on specific quests
_QuestieComms.QC_ID_SEND_QUESTS = 7
_QuestieComms.QC_ID_ASK_QUESTSLIST = 8 -- ask a player for their current quest log as a list of quest IDs
_QuestieComms.QC_ID_SEND_QUESTSLIST = 9

        quest.objectives[objectiveIndex].id = questObject.Objectives[objectiveIndex].Id;
        quest.objectives[objectiveIndex].typ = objective.type;
        quest.objectives[objectiveIndex].fin = objective.finished;
        quest.objectives[objectiveIndex].ful = objective.numFulfilled;
        quest.objectives[objectiveIndex].req = objective.numRequired;
]]--
-- <-- NYI
_QuestieComms.QC_ID_BROADCAST_FULL_QUESTLIST = 10
_QuestieComms.QC_ID_REQUEST_FULL_QUESTLIST = 11
_QuestieComms.QC_ID_BROADCAST_FULL_QUESTLISTV2 = 12
_QuestieComms.QC_ID_YELL_PROGRESS = 13
_QuestieComms.QC_ID_BROADCAST_QUEST_UPDATEV2 = 14 -- v2 (future use)

-- NOT USED
-- stringLookup it built from idLookup!
_QuestieComms.stringLookup = {}
_QuestieComms.idLookup = {
    ["id"] = 1,
    ["type"] = 2,
    ["finished"] = 3,
    ["fulfilled"] = 4,
    ["required"] = 5,
}
for string, int in pairs(_QuestieComms.idLookup) do
    _QuestieComms.stringLookup[int] = string;
end
-- !NOT USED

local badYellLocations = {
  -- Alliance
  [1453] = true, -- Stormwind
  [1455] = true, -- Ironforge
  [1457] = true, -- Darnassus
  [1947] = true, -- Exodar
  -- Horde
  [1454] = true, -- Orgrimmar
  [1456] = true, -- Thunder Bluff
  [1458] = true, -- Undercity
  [1954] = true, -- Silvermoon
  -- Both
  [1955] = true, -- Shattrath
  -- Battlegrounds
  [1459] = true, -- Alterac Valley
  [1460] = true, -- Warsong Gulch
  [1461] = true, -- Arathi Basin
  [1957] = true, -- Eye of the Storm
}

--- Global Functions --


---------
-- Fetch quest information about a specific player.
-- Params:
--  questId (int)
--  playerName (string) OPTIONAL
-- Return:
--  Similar object as QuestieQuest:GetRawLeaderBoardDetails()
--  Quest.(Id|level|isComplete) --title is trimmed to save space
--  Quest.Objectives[index].(description|objectiveType|isCompleted)
---------
--Only questid gets all players with that quest and their progress
--Both name and questid returns a specific players progress if one exist.
function QuestieComms:GetQuest(questId, playerName)
    if(QuestieComms.remoteQuestLogs[questId]) then
        if(playerName) then
            if(QuestieComms.remoteQuestLogs[questId][playerName]) then
                -- Create a copy of the object, other side should never be able to edit the underlying object.
                local quest = {};
                for key, value in pairs(QuestieComms.remoteQuestLogs[questId][playerName]) do
                    quest[key] = value;
                end
                return quest;
            end
        else
            -- Create a copy of the object, other side should never be able to edit the underlying object.
            local quest = {};
            for pName, objectivesData in pairs(QuestieComms.remoteQuestLogs[questId]) do
                quest[pName] = objectivesData;
            end
            return quest;
        end
    end
    return nil;
end


function QuestieComms:Initialize()
    -- Lets us send any length of message. Also implements ChatThrottleLib to not get disconnected.
    Questie:RegisterComm(_QuestieComms.prefix, _QuestieComms.OnCommReceived);

    Questie:RegisterComm("REPUTABLE", DailyQuests.FilterDailies);

    -- Events to be used to broadcast updates to other people
    Questie:RegisterMessage("QC_ID_BROADCAST_QUEST_UPDATE", _QuestieComms.BroadcastQuestUpdate);
    Questie:RegisterMessage("QC_ID_BROADCAST_QUEST_REMOVE", _QuestieComms.BroadcastQuestRemove);

    -- Bucket for 2 seconds to prevent spamming.
    Questie:RegisterBucketMessage("QC_ID_BROADCAST_FULL_QUESTLIST", 2, _QuestieComms.BroadcastQuestLog);

    -- Responds to the "hi" event from others.
    Questie:RegisterMessage("QC_ID_REQUEST_FULL_QUESTLIST", _QuestieComms.RequestQuestLog);

    if not Questie.db.global.disableYellComms then
        C_Timer.NewTicker(60, QuestieComms.SortRemotePlayers) -- periodically check for old players and remove them.
    end

end

-- Local Functions --

function _QuestieComms:BroadcastQuestUpdate(questId) -- broadcast quest update to group or raid
    Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieComms] Questid", questId, tostring(questId));
    if(questId) then
        local partyType = QuestiePlayer:GetGroupType()
        Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieComms] partyType", tostring(partyType));
        if partyType then
            if partyType ~= "raid" then
                QuestieComms:YellProgress(questId)
            end
            --Do we really need to make this?
            local questPacket = _QuestieComms:CreatePacket(_QuestieComms.QC_ID_BROADCAST_QUEST_UPDATE)

            local quest = QuestieComms:CreateQuestDataPacket(questId);

            questPacket.data.quest = quest
            questPacket.data.priority = "NORMAL";
            if partyType == "raid" then
                questPacket.data.writeMode = _QuestieComms.QC_WRITE_ALLRAID
            else
                questPacket.data.writeMode = _QuestieComms.QC_WRITE_ALLGROUP
            end
            questPacket:write()
        else
            QuestieComms:YellProgress(questId)
        end
    end
end

-- Removes the quest from everyones external quest-log
function _QuestieComms:BroadcastQuestRemove(questId) -- broadcast quest update to group or raid
    local partyType = QuestiePlayer:GetGroupType()
    Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieComms] QuestId:", questId, "partyType:", tostring(partyType));
    if partyType then
        --Do we really need to make this?
        local questPacket = _QuestieComms:CreatePacket(_QuestieComms.QC_ID_BROADCAST_QUEST_REMOVE);

        questPacket.data.id = questId;

        --This is important!
        questPacket.data.priority = "ALERT";
        if partyType == "raid" then
            questPacket.data.writeMode = _QuestieComms.QC_WRITE_ALLRAID;
        else
            questPacket.data.writeMode = _QuestieComms.QC_WRITE_ALLGROUP;
        end
        questPacket:write();
    end
end

local _classToIndex = {
    ["DRUID"] = 1,
    ["HUNTER"] = 2,
    ["MAGE"] = 3,
    ["PRIEST"] = 4,
    ["ROGUE"] = 5,
    ["SHAMAN"] = 6,
    ["WARLOCK"] = 7,
    ["WARRIOR"] = 8
}
local _indexToClass = {}
for class, index in pairs(_classToIndex) do
    _indexToClass[index] = class
end


function QuestieComms:PopulateQuestDataPacketV2_noclass_renameme(questId, quest, offset)
    local questObject = QuestieDB:GetQuest(questId);

    local rawObjectives = QuestieQuest:GetAllLeaderBoardDetails(questId);

    local count = 0

    if questObject and next(questObject.Objectives) then
        quest[offset] = questId
        local countOffset = offset+1

        offset = offset + 2
        for objectiveIndex, objective in pairs(rawObjectives) do
            quest[offset] = questObject.Objectives[objectiveIndex].Id
            quest[offset + 1] = string.byte(string.sub(objective.type, 1, 1))
            quest[offset + 2] = objective.numFulfilled
            quest[offset + 3] = objective.numRequired
            offset = offset + 4
            count = count + 1
        end
        
        quest[countOffset] = count
    end


    Questie:Debug(Questie.DEBUG_SPAM, "[QuestieComms] questPacket made: Objectivetable:", quest);

    return offset, count
end

function QuestieComms:PopulateQuestDataPacketV2(questId, quest, offset)
    local questObject = QuestieDB:GetQuest(questId);

    local rawObjectives = QuestieQuest:GetAllLeaderBoardDetails(questId);

    local count = 0

    if questObject and next(questObject.Objectives) then
        quest[offset] = questId
        local countOffset = offset+1
        local _, classFilename = UnitClass("player")
        quest[offset+2] = _classToIndex[classFilename]

        offset = offset + 3
        for objectiveIndex, objective in pairs(rawObjectives) do
            quest[offset] = questObject.Objectives[objectiveIndex].Id
            quest[offset + 1] = string.byte(string.sub(objective.type, 1, 1))
            quest[offset + 2] = objective.numFulfilled
            quest[offset + 3] = objective.numRequired
            offset = offset + 4
            count = count + 1
        end
        
        quest[countOffset] = count
    end


    Questie:Debug(Questie.DEBUG_SPAM, "[QuestieComms] questPacket made: Objectivetable:", quest);

    return offset, count
end


-- temporary function: refactor in 6.0.1
function QuestieComms:InsertQuestDataPacketV2_noclass_RenameMe(questPacket, playerName, offset, disableCompleteQuests)
    --We don't want to insert our own quest data.
    local allDone = true
    if questPacket then
        --Does it contain id and objectives?
        if(questPacket[1 + offset]) then
            -- Create empty quest.
            local questPacketid = questPacket[offset]
            local objectiveCount = questPacket[offset+1]

            local objectives = {}
            offset = offset + 2
            local objectiveIndex = 0
            while objectiveIndex < objectiveCount and questPacket[offset] do
                objectiveIndex = objectiveIndex + 1
                objectives[objectiveIndex] = {};
                objectives[objectiveIndex].index = objectiveIndex;
                
                objectives[objectiveIndex].id = questPacket[offset]
                objectives[objectiveIndex].type = string.char(questPacket[offset+1])--[_QuestieComms.idLookup["type"]];
                objectives[objectiveIndex].fulfilled = questPacket[offset+2]--[_QuestieComms.idLookup["fulfilled"]];
                objectives[objectiveIndex].required = questPacket[offset+3]--[_QuestieComms.idLookup["required"]];
                objectives[objectiveIndex].finished = objectives[objectiveIndex].fulfilled == objectives[objectiveIndex].required--[_QuestieComms.idLookup["finished"]];
                
                allDone = allDone and objectives[objectiveIndex].finished

                offset = offset + 4
            end
            if not (allDone and disableCompleteQuests) then
                if not QuestieComms.remoteQuestLogs[questPacketid] then
                    QuestieComms.remoteQuestLogs[questPacketid] = {}
                end
                -- Create empty player.
                if not QuestieComms.remoteQuestLogs[questPacketid][playerName] then
                    QuestieComms.remoteQuestLogs[questPacketid][playerName] = {}
                end

                QuestieComms.remoteQuestLogs[questPacketid][playerName] = objectives

                --Write to tooltip data
                QuestieComms.data:RegisterTooltip(questPacketid, playerName, objectives)
            end
        end
    end
    return offset, allDone
end

function QuestieComms:InsertQuestDataPacketV2(questPacket, playerName, offset, disableCompleteQuests)
    --We don't want to insert our own quest data.
    local allDone = true
    if questPacket then
        --Does it contain id and objectives?
        if(questPacket[2 + offset]) then
            -- Create empty quest.
            local questPacketid = questPacket[offset]
            local objectiveCount = questPacket[offset+1]
            local class = _indexToClass[questPacket[offset+2]]

            local objectives = {}
            offset = offset + 3
            local objectiveIndex = 0
            while objectiveIndex < objectiveCount and questPacket[offset] do
                objectiveIndex = objectiveIndex + 1
                objectives[objectiveIndex] = {};
                objectives[objectiveIndex].index = objectiveIndex;
                
                objectives[objectiveIndex].id = questPacket[offset]
                objectives[objectiveIndex].type = string.char(questPacket[offset+1])--[_QuestieComms.idLookup["type"]];
                objectives[objectiveIndex].fulfilled = questPacket[offset+2]--[_QuestieComms.idLookup["fulfilled"]];
                objectives[objectiveIndex].required = questPacket[offset+3]--[_QuestieComms.idLookup["required"]];
                objectives[objectiveIndex].finished = objectives[objectiveIndex].fulfilled == objectives[objectiveIndex].required--[_QuestieComms.idLookup["finished"]];
                
                allDone = allDone and objectives[objectiveIndex].finished

                offset = offset + 4
            end
            if not (allDone and disableCompleteQuests) then
                if not QuestieComms.remoteQuestLogs[questPacketid] then
                    QuestieComms.remoteQuestLogs[questPacketid] = {}
                end
                -- Create empty player.
                if not QuestieComms.remoteQuestLogs[questPacketid][playerName] then
                    QuestieComms.remoteQuestLogs[questPacketid][playerName] = {}
                end

                QuestieComms.remoteQuestLogs[questPacketid][playerName] = objectives
                QuestieComms.remotePlayerClasses[playerName] = class

                --Write to tooltip data
                QuestieComms.data:RegisterTooltip(questPacketid, playerName, objectives)
            elseif disableCompleteQuests then
                -- remove player if they exist
                if QuestieComms.remoteQuestLogs[questPacketid] and QuestieComms.remoteQuestLogs[questPacketid][playerName] then
                    QuestieComms.remoteQuestLogs[questPacketid][playerName] = nil
                end
            end
        end
    end
    return offset, allDone
end

function QuestieComms:CheckInGroup(name)
    return IsInRaid() and UnitInRaid(name) or UnitInParty(name)
end

function QuestieComms:RemoveAllRemotePlayers()
    for name in pairs(QuestieComms.remotePlayerTimes) do
        QuestieComms:RemoveRemotePlayer(name)
    end
end

function QuestieComms:RemoveRemotePlayer(name)
    QuestieComms.remotePlayerTimes[name] = nil
    QuestieComms.remotePlayerEnabled[name] = nil
    QuestieComms.remotePlayerClasses[name] = nil
    if not QuestieComms:CheckInGroup(name) then
        for _, players in pairs(QuestieComms.remoteQuestLogs) do
            players[name] = nil
        end
    end
end

function QuestieComms:SortRemotePlayers()
    local now = GetTime()
    local current = {}
    for name, time in pairs(QuestieComms.remotePlayerTimes) do
        if now - time > 60 * 4 then -- not seen in the last 4 minutes
            QuestieComms:RemoveRemotePlayer(name)
        else
            tinsert(current, name)
        end
    end
    table.sort(current, function(a, b)
        return QuestieComms.remotePlayerTimes[a] < QuestieComms.remotePlayerTimes[b]
    end)
    for index,name in pairs(current) do
        if index < 4 then
            QuestieComms.remotePlayerEnabled[name] = true
        else
            QuestieComms.remotePlayerEnabled[name] = false
        end
    end
end

QuestieComms._yellWaitingQuests = {}
QuestieComms._yellQueue = {}
QuestieComms._isYelling = false

local _loadupTime_removeme = GetTime() -- this will be removed in 6.0.1 or 6.1, when we can figure out a proper way to prevent
-- yelling quests on login. Not enough time to make and test a proper fix

function QuestieComms:YellProgress(questId)
    if Questie.db.global.disableYellComms or badYellLocations[C_Map.GetBestMapForUnit("player")] or GetNumGroupMembers() > 4 or GetTime() - _loadupTime_removeme < 8 then
        return
    end
    if not QuestieComms._yellWaitingQuests[questId] then
        QuestieComms._yellWaitingQuests[questId] = true
        if QuestieComms._isYelling then
            tinsert(QuestieComms._yellQueue, questId)
        else
            QuestieComms._isYelling = true
            C_Timer.After(2, function()
                _DoYell(questId)
            end)
        end
    end
end

_DoYell = function(questId)
    --[[local data = {}
    local _, count = QuestieComms:PopulateQuestDataPacketV2(questId, data, 1)
    if count > 0 then -- dont send quests with no objectives
        local packet = _QuestieComms:CreatePacket(_QuestieComms.QC_ID_YELL_PROGRESS);
        packet.data[1] = data;
        packet.data.priority = "BULK"
        packet.data.writeMode = _QuestieComms.QC_WRITE_YELL

        packet:write();
        QuestieComms._yellWaitingQuests[questId] = nil
    end
    local nextQuest = tremove(QuestieComms._yellQueue, 1)
    if nextQuest then
        C_Timer.After(2, function()
            _DoYell(nextQuest)
        end)
    else
        QuestieComms._isYelling = false
    end]]
end

_QuestieComms._isBroadcasting = false
_QuestieComms._needsNewBroadcast = false
_QuestieComms._nextBroadcastData = {}

function _QuestieComms:BroadcastQuestLog(eventName, sendMode, targetPlayer) -- broadcast quest update to group or raid
    if _QuestieComms._isBroadcasting then
        tinsert(_QuestieComms._nextBroadcastData, {eventName, sendMode, targetPlayer})
        return
    end
    local partyType = QuestiePlayer:GetGroupType()
    Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieComms] Message", eventName, "partyType:", tostring(partyType));
    if partyType then
        local rawQuestList = {}
        -- Maybe this should be its own function in QuestieQuest...
        local numEntries, _ = GetNumQuestLogEntries();

        local sorted = {}
        for index = 1, numEntries do
            local _, _, questType, isHeader, _, _, _, questId, _, _, _, _, _, _, _, _, _ = GetQuestLogTitle(index)
            if (not isHeader) and (not QuestieDB.QuestPointers[questId]) then
                if not Questie._sessionWarnings[questId] then
                    Questie:Error(l10n("The quest %s is missing from Questie's database, Please report this on GitHub or Discord!", tostring(questId)))
                    Questie._sessionWarnings[questId] = true
                end
            elseif not isHeader then
                local entry = {}
                entry.questId = questId
                entry.questType = questType
                entry.zoneOrSort = QuestieDB.QueryQuestSingle(questId, "zoneOrSort")
                entry.isSoloQuest = not (questType == "Dungeon" or questType == "Raid" or questType == "Group" or questType == "Elite" or questType == "PVP")
                

                if entry.zoneOrSort > 0 then
                    entry.UiMapId = ZoneDB:GetUiMapIdByAreaId(entry.zoneOrSort)
                    entry.zoneDistance = HBD:GetZoneDistance(entry.UiMapId, 0.5, 0.5, HBD:GetPlayerZone(), 0.5, 0.5) or 99999999
                else
                    entry.zoneDistance = 99999999 -- some high number (class quests etc)
                end
                if partyType ~= "raid" or (not entry.isSoloQuest) then
                    tinsert(sorted, entry)
                end
            end
        end

        table.sort(sorted, function(a, b)
            if a.isSoloQuest and not b.isSoloQuest then
                return false
            elseif b.isSoloQuest and not a.isSoloQuest then
                return true
            else--if a.isSoloQuest == b.isSoloQuest then
                if a.zoneDistance > b.zoneDistance then
                    return false
                elseif a.zoneDistance < b.zoneDistance then
                    return true
                else
                    return false -- 0
                end
            end
        end)

        local blocks = {}
        local entryCount = 0
        local blockCount = 2 -- the extra tick allows checking tremove() == nil to set _isBroadcasting=false
        for _, entry in pairs(sorted) do
            local quest = QuestieComms:CreateQuestDataPacket(entry.questId);
            --print("[CommsSendOrder][Block " .. (blockCount - 1) .. "] " .. QuestieDB.QueryQuestSingle(entry.questId, "name"))
            entryCount = entryCount + 1
            rawQuestList[quest.id] = quest;
            if string.len(QuestieSerializer:Serialize(rawQuestList)) > 200 then--extra space for packet metadata and CTL stuff
                rawQuestList[quest.id] = nil
                tinsert(blocks, rawQuestList)
                rawQuestList = {}
                rawQuestList[quest.id] = quest
                entryCount = 1
                blockCount = blockCount + 1
            end
        end

        if entryCount ~= 0 then
            tinsert(blocks, rawQuestList) -- add the last block
            _QuestieComms._isBroadcasting = true
            -- hopefully reduce server load by staggering responses
            C_Timer.After(random() * 3, function()
                C_Timer.NewTicker(3, function()
                    local block = tremove(blocks, 1)
                    if block then
                        -- send the block
                        local questPacket = _QuestieComms:CreatePacket(_QuestieComms.QC_ID_BROADCAST_FULL_QUESTLIST);
                        questPacket.data.rawQuestList = block;
                        if "WHISPER" == sendMode then
                            questPacket.data.writeMode = _QuestieComms.QC_WRITE_WHISPER
                            questPacket.data.target = targetPlayer
                            questPacket.data.priority = "NORMAL"
                        else
                            if partyType == "raid" then
                                questPacket.data.writeMode = _QuestieComms.QC_WRITE_ALLRAID
                                questPacket.data.priority = "BULK"
                            else
                                questPacket.data.writeMode = _QuestieComms.QC_WRITE_ALLGROUP
                                questPacket.data.priority = "NORMAL"
                            end
                        end
                        questPacket:write();
                    else
                        _QuestieComms._isBroadcasting = false
                        local nextBroadcast = tremove(_QuestieComms._nextBroadcastData, 1)
                        if nextBroadcast then
                            _QuestieComms:BroadcastQuestLog(unpack(nextBroadcast))
                        end
                    end
                end, blockCount)
            end)
        end
    end
end

_QuestieComms._isBroadcastingV2 = false
_QuestieComms._nextBroadcastDataV2 = {}

function _QuestieComms:BroadcastQuestLogV2(eventName, sendMode, targetPlayer) -- broadcast quest update to group or raid
    if _QuestieComms._isBroadcastingV2 then
        tinsert(_QuestieComms._nextBroadcastDataV2, {eventName, sendMode, targetPlayer})
        return
    end
    local partyType = QuestiePlayer:GetGroupType()
    Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieComms] Message", eventName, "partyType:", tostring(partyType));
    if partyType then
        
        -- Maybe this should be its own function in QuestieQuest...
        local numEntries, _ = GetNumQuestLogEntries();

        local sorted = {}
        for index = 1, numEntries do
            local _, _, questType, isHeader, _, _, _, questId, _, _, _, _, _, _, _, _, _ = GetQuestLogTitle(index)
            if (not isHeader) and (not QuestieDB.QuestPointers[questId]) then
                if not Questie._sessionWarnings[questId] then
                    Questie:Error(l10n("The quest %s is missing from Questie's database, Please report this on GitHub or Discord!", tostring(questId)))
                    Questie._sessionWarnings[questId] = true
                end
            elseif not isHeader then
                local entry = {}
                entry.questId = questId
                entry.questType = questType
                entry.zoneOrSort = QuestieDB.QueryQuestSingle(questId, "zoneOrSort")
                entry.isSoloQuest = not (questType == "Dungeon" or questType == "Raid" or questType == "Group" or questType == "Elite" or questType == "PVP")
                

                if entry.zoneOrSort > 0 then
                    entry.UiMapId = ZoneDB:GetUiMapIdByAreaId(entry.zoneOrSort)
                    entry.zoneDistance = HBD:GetZoneDistance(entry.UiMapId, 0.5, 0.5, HBD:GetPlayerZone(), 0.5, 0.5) or 99999999
                else
                    entry.zoneDistance = 99999999 -- some high number (class quests etc)
                end
                if partyType ~= "raid" or (not entry.isSoloQuest) then
                    tinsert(sorted, entry)
                end
            end
        end

        table.sort(sorted, function(a, b)
            if a.isSoloQuest and not b.isSoloQuest then
                return false
            elseif b.isSoloQuest and not a.isSoloQuest then
                return true
            else--if a.isSoloQuest == b.isSoloQuest then
                if a.zoneDistance > b.zoneDistance then
                    return false
                elseif a.zoneDistance < b.zoneDistance then
                    return true
                else
                    return false -- 0
                end
            end
        end)

        local rawQuestList = {}
        local blocks = {}
        local entryCount = 0
        local blockCount = 2 -- the extra tick allows checking tremove() == nil to set _isBroadcasting=false
        local offset = 2
        

        for _, entry in pairs(sorted) do
            --print("[CommsSendOrder][Block " .. (blockCount - 1) .. "] " .. QuestieDB.QueryQuestSingle(entry.questId, "name"))
            entryCount = entryCount + 1

            offset = QuestieComms:PopulateQuestDataPacketV2_noclass_renameme(entry.questId, rawQuestList, offset)

            if string.len(QuestieSerializer:Serialize(rawQuestList)) > 200 then--extra space for packet metadata and CTL stuff
                rawQuestList[1] = entryCount
                tinsert(blocks, rawQuestList)
                rawQuestList = {}
                entryCount = 0
                blockCount = blockCount + 1
                offset = 2
            end
        end

        if entryCount ~= 0 or blockCount ~= 2 then
            rawQuestList[1] = entryCount
            tinsert(blocks, rawQuestList) -- add the last block
            _QuestieComms._isBroadcastingV2 = true
            -- hopefully reduce server load by staggering responses
            C_Timer.After(random() * 3, function()
                C_Timer.NewTicker(3, function()
                    local block = tremove(blocks, 1)
                    if block then
                        -- send the block
                        local questPacket = _QuestieComms:CreatePacket(_QuestieComms.QC_ID_BROADCAST_FULL_QUESTLISTV2);
                        questPacket.data[1] = block;
                        if "WHISPER" == sendMode then
                            questPacket.data.writeMode = _QuestieComms.QC_WRITE_WHISPER
                            questPacket.data.target = targetPlayer
                            questPacket.data.priority = "NORMAL"
                        else
                            if partyType == "raid" then
                                questPacket.data.writeMode = _QuestieComms.QC_WRITE_ALLRAID
                                questPacket.data.priority = "BULK"
                            else
                                questPacket.data.writeMode = _QuestieComms.QC_WRITE_ALLGROUP
                                questPacket.data.priority = "NORMAL"
                            end
                        end
                        questPacket:write();
                    else
                        _QuestieComms._isBroadcastingV2 = false
                        local nextBroadcast = tremove(_QuestieComms._nextBroadcastDataV2, 1)
                        if nextBroadcast then
                            _QuestieComms:BroadcastQuestLogV2(unpack(nextBroadcast))
                        end
                    end
                end, blockCount)
            end)
        end
    end
end

-- The "Hi" of questie, request others to send their questlog.
function _QuestieComms:RequestQuestLog(eventName) -- broadcast quest update to group or raid
    local partyType = QuestiePlayer:GetGroupType()
    Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieComms] Message", eventName, "partyType:", tostring(partyType));
    if partyType then
        --Do we really need to make this?
        local questPacket = _QuestieComms:CreatePacket(_QuestieComms.QC_ID_REQUEST_FULL_QUESTLIST);

        if partyType == "raid" then
            questPacket.data.writeMode = _QuestieComms.QC_WRITE_ALLRAID;
            questPacket.data.priority = "NORMAL";
        else
            questPacket.data.writeMode = _QuestieComms.QC_WRITE_ALLGROUP;
            questPacket.data.priority = "NORMAL";
        end
        questPacket:write();
    end
end

---@param questId number
---@return QuestPacket
function QuestieComms:CreateQuestDataPacket(questId)
    local questObject = QuestieDB:GetQuest(questId);

    ---@class QuestPacket
    local quest = {};
    quest.id = questId;
    local rawObjectives = QuestieQuest:GetAllLeaderBoardDetails(questId);
    quest.objectives = {}
    if questObject and next(questObject.Objectives) then
        for objectiveIndex, objective in pairs(rawObjectives) do
            if questObject.Objectives[objectiveIndex] then
                quest.objectives[objectiveIndex] = {};
                quest.objectives[objectiveIndex].id = questObject.Objectives[objectiveIndex].Id;--[_QuestieComms.idLookup["id"]] = questObject.Objectives[objectiveIndex].Id;
                quest.objectives[objectiveIndex].typ = string.sub(objective.type, 1, 1);-- Get the first char only.--[_QuestieComms.idLookup["type"]] = string.sub(objective.type, 1, 1);-- Get the first char only.
                quest.objectives[objectiveIndex].fin = objective.finished;--[_QuestieComms.idLookup["finished"]] = objective.finished;
                quest.objectives[objectiveIndex].ful = objective.numFulfilled;--[_QuestieComms.idLookup["fulfilled"]] = objective.numFulfilled;
                quest.objectives[objectiveIndex].req = objective.numRequired;--[_QuestieComms.idLookup["required"]] = objective.numRequired;
            else
                Questie:Error(Questie.TBC_BETA_BUILD_VERSION_SHORTHAND.."Missing objective data for quest " .. tostring(questId) .. " " .. tostring(objectiveIndex))
            end
        end
    end
    Questie:Debug(Questie.DEBUG_SPAM, "[QuestieComms] questPacket made: Objectivetable:", quest.objectives);
    return quest;
end

---@param questPacket QuestPacket @A packet created from the CreateQuestDataPacket function
---@param playerName string @The player said package should be added to.
function QuestieComms:InsertQuestDataPacket(questPacket, playerName)
    --We don't want to insert our own quest data.
    if questPacket and playerName ~= UnitName("player") then
        --Does it contain id and objectives?
        if(questPacket.objectives and questPacket.id) then
            -- Create empty quest.
            if not QuestieComms.remoteQuestLogs[questPacket.id] then
                QuestieComms.remoteQuestLogs[questPacket.id] = {}
            end
            -- Create empty player.
            if not QuestieComms.remoteQuestLogs[questPacket.id][playerName] then
                QuestieComms.remoteQuestLogs[questPacket.id][playerName] = {}
            end
            local objectives = {}
            for objectiveIndex, objectiveData in pairs(questPacket.objectives) do
                --This is to check that all the data we require exist.
                objectives[objectiveIndex] = {};
                objectives[objectiveIndex].index = objectiveIndex;
                objectives[objectiveIndex].id = objectiveData.id--[_QuestieComms.idLookup["id"]];
                objectives[objectiveIndex].type = objectiveData.typ--[_QuestieComms.idLookup["type"]];
                objectives[objectiveIndex].finished = objectiveData.fin--[_QuestieComms.idLookup["finished"]];
                objectives[objectiveIndex].fulfilled = objectiveData.ful--[_QuestieComms.idLookup["fulfilled"]];
                objectives[objectiveIndex].required = objectiveData.req--[_QuestieComms.idLookup["required"]];
            end
            QuestieComms.remoteQuestLogs[questPacket.id][playerName] = objectives;


            --Write to tooltip data
            QuestieComms.data:RegisterTooltip(questPacket.id, playerName, objectives);
        end
    end
end

_QuestieComms.packets = {
    [_QuestieComms.QC_ID_BROADCAST_QUEST_UPDATE] = { --1
        write = function(self)
            Questie:Debug(Questie.DEBUG_INFO, "[QuestieComms]", "Sending: QC_ID_BROADCAST_QUEST_UPDATE")
            _QuestieComms:Broadcast(self.data);
        end,
        read = function(remoteQuestPacket)
            if(remoteQuestPacket == nil) then
                Questie:Error("[QuestieComms]", "QC_ID_BROADCAST_QUEST_UPDATE", "remoteQuestPacket = nil");
            end
            --These are not strictly needed but helps readability.
            local playerName = remoteQuestPacket.playerName;
            local quest = remoteQuestPacket.quest;

            Questie:Debug(Questie.DEBUG_INFO, "[QuestieComms]", "Received: QC_ID_BROADCAST_QUEST_UPDATE", "Player:", playerName)

            QuestieComms:InsertQuestDataPacket(quest, playerName);
        end
    },
    [_QuestieComms.QC_ID_BROADCAST_QUEST_REMOVE] = { --2
      write = function(self)
        Questie:Debug(Questie.DEBUG_INFO, "[QuestieComms]", "Sending: QC_ID_BROADCAST_QUEST_REMOVE")
        _QuestieComms:Broadcast(self.data);
      end,
      read = function(remoteQuestPacket)
        if(remoteQuestPacket == nil) then
            Questie:Error("[QuestieComms]", "QC_ID_BROADCAST_QUEST_REMOVE", "remoteQuestPacket = nil");
        end
        Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieComms]", "Received: QC_ID_BROADCAST_QUEST_REMOVE")

        local playerName = remoteQuestPacket.playerName;
        local questId = remoteQuestPacket.id;

        if(QuestieComms.remoteQuestLogs[questId] and QuestieComms.remoteQuestLogs[questId][playerName]) then
            Questie:Debug(Questie.DEBUG_INFO, "[QuestieComms]", "Removed quest:", questId, "for player:", playerName);
            QuestieComms.remoteQuestLogs[questId][playerName] = nil;
        end
        QuestieComms.data:RemoveQuestFromPlayer(questId, playerName);
      end
    },
    [_QuestieComms.QC_ID_BROADCAST_FULL_QUESTLIST] = { --10
        write = function(self)
            Questie:Debug(Questie.DEBUG_INFO, "[QuestieComms]", "Sending: QC_ID_BROADCAST_FULL_QUESTLIST")
            _QuestieComms:Broadcast(self.data);
        end,
        read = function(remoteQuestList)
            if(remoteQuestList == nil) then
                Questie:Error("[QuestieComms]", "QC_ID_BROADCAST_FULL_QUESTLIST", "remoteQuestList = nil");
            end
            --These are not strictly needed but helps readability.
            local playerName = remoteQuestList.playerName;
            local questList = remoteQuestList.rawQuestList;

            Questie:Debug(Questie.DEBUG_INFO, "[QuestieComms]", "Received: QC_ID_BROADCAST_FULL_QUESTLIST", "Player:", playerName, questList)

            --Don't save our own quests.
            if questList then
                for _, questData in pairs(questList) do
                    QuestieComms:InsertQuestDataPacket(questData, playerName);
                end
            end
        end
    },
    [_QuestieComms.QC_ID_REQUEST_FULL_QUESTLIST] = { --11
        write = function(self)
            Questie:Debug(Questie.DEBUG_INFO, "[QuestieComms]", "Sending: QC_ID_REQUEST_FULL_QUESTLIST")
            _QuestieComms:Broadcast(self.data);
        end,
        read = function(self)
            Questie:Debug(Questie.DEBUG_INFO, "[QuestieComms]", "Received: QC_ID_REQUEST_FULL_QUESTLIST")
            --Questie:SendMessage("QC_ID_BROADCAST_FULL_QUESTLIST");
            --if tonumber(major) > 5 then
            --    QuestieComms:BroadcastQuestLogV2(self.playerName, "WHISPER")--Questie:SendMessage("QC_ID_BROADCAST_FULL_QUESTLISTV2");
            --else
            --    QuestieComms:BroadcastQuestLogV2(self.playerName, "WHISPER") -- player doesnt have new questie, use old packet
            --end
            if UnitName("Player") ~= self.playerName then
                local major, _, _ = strsplit(".", self.ver)
                if tonumber(major) > 5 then
                    _QuestieComms:BroadcastQuestLogV2("QC_ID_BROADCAST_FULL_QUESTLIST", "WHISPER", self.playerName)
                else
                    _QuestieComms:BroadcastQuestLog("QC_ID_BROADCAST_FULL_QUESTLIST", "WHISPER", self.playerName)
                end
            end
        end
    },
    [_QuestieComms.QC_ID_BROADCAST_FULL_QUESTLISTV2] = {-- 12
        write = function(self)
            Questie:Debug(Questie.DEBUG_INFO, "[QuestieComms]", "Sending: QC_ID_REQUEST_FULL_QUESTLISTV2")
            _QuestieComms:Broadcast(self.data);
        end,
        read = function(self)
            Questie:Debug(Questie.DEBUG_INFO, "[QuestieComms]", "Received: QC_ID_REQUEST_FULL_QUESTLISTV2")
            local offset = 2
            local count = self[1][1]
            for _= 1, count do
                offset = QuestieComms:InsertQuestDataPacketV2_noclass_RenameMe(self[1], self.playerName, offset, false)
            end
        end
    },
    [_QuestieComms.QC_ID_YELL_PROGRESS] = { --13
        write = function(self)
            Questie:Debug(Questie.DEBUG_INFO, "[QuestieComms]", "Sending: QC_ID_YELL_PROGRESS")
            if not badYellLocations[C_Map.GetBestMapForUnit("player")] then
               _QuestieComms:Broadcast(self.data);
            end
        end,
        read = function(self)
            Questie:Debug(Questie.DEBUG_INFO, "[QuestieComms]", "Received: QC_ID_YELL_PROGRESS")
            if not Questie.db.global.disableYellComms and not badYellLocations[C_Map.GetBestMapForUnit("player")] then
                QuestieComms.remotePlayerTimes[self.playerName] = GetTime()
                QuestieComms:InsertQuestDataPacketV2(self[1], self.playerName, 1, true)
                QuestieComms:SortRemotePlayers()
            end
        end
    },
    [_QuestieComms.QC_ID_BROADCAST_QUEST_UPDATEV2] = { -- 14
        write = function(self)
            Questie:Debug(Questie.DEBUG_INFO, "[QuestieComms]", "Sending: QC_ID_BROADCAST_QUEST_UPDATEV2")
            _QuestieComms:Broadcast(self.data);
        end,
        read = function(self)
            Questie:Debug(Questie.DEBUG_INFO, "[QuestieComms]", "Received: QC_ID_BROADCAST_QUEST_UPDATEV2")
            QuestieComms:InsertQuestDataPacketV2_noclass_RenameMe(self[1], self.playerName, 1, false)
        end
    }
}

-- Renamed Write function
function _QuestieComms:Broadcast(packet)
    -- If the priority is not set, it must not be very important
    if packet.writeMode ~= _QuestieComms.QC_WRITE_WHISPER and (GetNumGroupMembers() > 15 or UnitInBattleground("Player")) then
        -- dont broadcast to large raids
        return
    end
    if(not packet.priority) then
      packet.priority = "BULK";
    end
    local packetPriority = packet.priority
    local packetWriteMode = packet.writeMode
    local packetTarget = packet.target
    packet.priority = nil
    packet.target = nil
    packet.writeMode = nil -- we dont need to include these in the packet data
    if packetWriteMode == _QuestieComms.QC_WRITE_WHISPER then
        local compressedData = QuestieSerializer:Serialize(packet);
        Questie:Debug(Questie.DEBUG_DEVELOP,"send(|cFFFF2222" ..string.len(compressedData) .. "|r)")
        Questie:SendCommMessage(_QuestieComms.prefix, compressedData, packetWriteMode, packetTarget, packetPriority)
    elseif packetWriteMode == _QuestieComms.QC_WRITE_CHANNEL then
        local compressedData = QuestieSerializer:Serialize(packet);
        Questie:Debug(Questie.DEBUG_DEVELOP,"send(|cFFFF2222" ..string.len(compressedData) .. "|r)")
        -- Always do channel messages as BULK priority
        Questie:SendCommMessage(_QuestieComms.prefix, compressedData, packetWriteMode, GetChannelName("questiecom"), "BULK")
        --OLD: C_ChatInfo.SendAddonMessage("questie", compressedData, "CHANNEL", GetChannelName("questiecom"))
    elseif packetWriteMode == _QuestieComms.QC_WRITE_YELL then
        packet.msgVer = nil
        --packet.ver = nil
        local compressedData = QuestieSerializer:Serialize(packet, "b89");
        --print("Yelling progress: " .. compressedData)
        Questie:SendCommMessage(_QuestieComms.prefix, compressedData, packetWriteMode, "BULK")
    else
        local compressedData = QuestieSerializer:Serialize(packet);
        Questie:Debug(Questie.DEBUG_DEVELOP, "send(|cFFFF2222" ..string.len(compressedData) .. "|r)")
        Questie:SendCommMessage(_QuestieComms.prefix, compressedData, packetWriteMode, nil, packetPriority)
        --OLD: C_ChatInfo.SendAddonMessage("questie", compressedData, packet.writeMode)
    end
end

function _QuestieComms:OnCommReceived(message, distribution, sender)
    pcall(_QuestieComms.OnCommReceived_unsafe, _QuestieComms, message, distribution, sender)
end

function _QuestieComms:OnCommReceived_unsafe(message, distribution, sender)
    --print("[" .. distribution .."][" .. sender .. "] " .. message)
    Questie:Debug(Questie.DEBUG_DEVELOP, "|cFF22FF22", "sender:", "|r", sender, "distribution:", distribution, "Packet length:",string.len(message))
    if message and sender and sender ~= UnitName("player") then
        local decompressedData
        if distribution == "YELL" then
            --print("Decompressing YELL data")
            decompressedData = QuestieSerializer:Deserialize(message, "b89")
        else
            --print("Decompressing normal data")
            decompressedData = QuestieSerializer:Deserialize(message)
        end

        --Check if the message version is the same base value
        if distribution == "YELL" and decompressedData.msgId and _QuestieComms.packets[decompressedData.msgId] then
            decompressedData.playerName = sender;
            Questie:Debug(Questie.DEBUG_DEVELOP, "Executing message ID: ", decompressedData.msgId, "From: ", sender)
            _QuestieComms.packets[decompressedData.msgId].read(decompressedData)
        elseif(decompressedData and decompressedData.msgVer and floor(decompressedData.msgVer) == floor(commMessageVersion)) then
            if(decompressedData and decompressedData.msgId and _QuestieComms.packets[decompressedData.msgId]) then

                --If a new version exist, tell them!
                if(suggestUpdate) then
                    local major, minor, patch = strsplit(".", decompressedData.ver);
                    local majorOwn, minorOwn, patchOwn = QuestieLib:GetAddonVersionInfo();
                    if(majorOwn < tonumber(major) or (majorOwn == tonumber(major) and minorOwn < tonumber(minor)) or (majorOwn == tonumber(major) and minorOwn == tonumber(minor) and patchOwn < tonumber(patch)) and (not UnitAffectingCombat("player"))) then
                        suggestUpdate = false;
                        if(majorOwn < tonumber(major)) then
                            Questie:Print("|cffff0000A Major patch for Questie exists!|r");
                            Questie:Print("|cffff0000Please update as soon as possible!|r");
                        else
                            Questie:Print("|cffff0000You have an outdated version of Questie!|r");
                            Questie:Print("|cffff0000Please consider updating!|r");
                        end
                    end
                end

                decompressedData.playerName = sender;
                Questie:Debug(Questie.DEBUG_DEVELOP, "Executing message ID: ", decompressedData.msgId, "From: ", sender, "MessageVersion:", decompressedData.msgVer)

                _QuestieComms.packets[decompressedData.msgId].read(decompressedData);
            else
                Questie:Debug(Questie.DEBUG_INFO, "[QuestieComms]", decompressedData, decompressedData.msgId, _QuestieComms.packets[decompressedData.msgId])
                Questie:Error("Error reading QuestieComm message (If it persist try updating) Player:", sender, "PacketLength:", string.len(message));
            end
        elseif(decompressedData and not warnedUpdate and decompressedData.msgVer) then
            -- We want to know who actually is the one with the mismatched version!
            if(floor(commMessageVersion) < floor(decompressedData.msgVer)) then
                Questie:Error("You have an incompatible QuestieComms message! Please update!", "  Yours: v", commMessageVersion, sender..": v", decompressedData.msgVer);
            elseif(floor(commMessageVersion) > floor(decompressedData.msgVer)) then
                Questie:Print("|cFFFF0000WARNING!|r", sender, "has an incompatible Questie version, QuestieComms won't work!", " Yours:", commMessageVersion, sender..":", decompressedData.msgVer)
            end
            warnedUpdate = true;
        end
    end
end

-- Copied: Is this really needed? Can't we just optimize away this?
function _QuestieComms:CreatePacket(messageId)
    -- Duplicate the object.
    local pkt = {};
    for k,v in pairs(_QuestieComms.packets[messageId]) do
        pkt[k] = v
    end
    pkt.data = {}
    -- Set messageId
    local major, minor, patch = QuestieLib:GetAddonVersionInfo();
    pkt.data.ver = major.."."..minor.."."..patch;
    pkt.data.msgVer = commMessageVersion;
    pkt.data.msgId = messageId
    -- Some messages initialize
    if pkt.init then
        pkt:init()
    end
    return pkt
end

function QuestieComms:ResetAll()
    QuestieComms.data:ResetAll()
    QuestieComms.remoteQuestLogs = {}
end

--[[ not used!
function _QuestieComms:isNewHash(questData)
    if(questData.id) then
        if(_QuestieComms.questHashes[questData.id]) then
            local hash = libC:fcs32init();
            hash = libC:fcs32update(hash, libS:Serialize(objectives));
            hash = libC:fcs32final(hash);
            if(hash == _QuestieComms.questHashes[questData.id]) then
                return nil;
            else
                --Update old hash to new one.
                _QuestieComms.questHashes[questData.id] = hash;
                return true;
            end
        else
            --Previous data did not even exist, return true
            return true;
        end
    end
end]]--



--[[ NOT USED
function QuestieComms:MessageReceived(channel, message, type, source) -- pcall this
    Questie:Debug(Questie.DEBUG_DEVELOP, "recv(|cFF22FF22" .. message .. "|r)")
    if channel == "questie" and source then
      local decompressedData = QuestieCompress:decompress(message);
      _QuestieComms.packets[message.msgId].read(decompressedData);
    end
end
]]--
--AeroScripts comms module, do not remove!!! Everything is still a WIP!!!
--[[QuestieComms = {};

QC_WRITE_ALLGUILD = 1
QC_WRITE_ALLGROUP = 2
QC_WRITE_ALLRAID = 3
QC_WRITE_WHISPER = 4
QC_WRITE_CHANNEL = 5

QC_ID_BROADCAST_QUEST_UPDATE = 1 -- send quest_log_update status to party/raid members
QC_ID_BROADCAST_QUESTIE_GETVERSION = 2 -- ask anyone for the newest questie version
QC_ID_BROADCAST_QUESTIE_VERSION = 3 -- broadcast the current questie version
QC_ID_ASK_CHANGELOG = 4 -- ask a player for the changelog
QC_ID_SEND_CHANGELOG = 5
QC_ID_ASK_QUESTS = 6 -- ask a player for their quest progress on specific quests
QC_ID_SEND_QUESTS = 7
QC_ID_ASK_QUESTSLIST = 8 -- ask a player for their current quest log as a list of quest IDs
QC_ID_SEND_QUESTSLIST = 9

function QuestieGetVersionString() -- todo: better place
    local _,ver = GetAddOnInfo("QuestieDev-master")
    -- todo: better regex for this
    ver = string.sub(ver, 32)
    ver = string.sub(ver, 0, string.find(ver, "|")-1)
    return ver
end

function QuestieGetVersionInfo() -- todo: better place
    local ver = QuestieGetVersionString()
    local major, minor, patch = strsplit(".", ver)
    return tonumber(major), tonumber(minor), tonumber(patch)
end

_QuestieComms.packets = {
    [QC_ID_BROADCAST_QUEST_UPDATE] = {
        write = function(self)
            local count = 0;
            for _ in pairs(self.quest.Objectives) do count = count + 1; end -- why does lua suck

            self.stream:WriteShort(self.quest.Id)
            self.stream:WriteByte(count)

            for _,objective in pairs(self.quest.Objectives) do
                self.stream:WriteBytes(objective.Index, objective.Needed, objective.Collected)
            end
        end,
        read = function(self)
            local quest = QuestieDB:GetQuest(self.stream:ReadShort())
            local count = self.stream:ReadByte()
            if quest then
                if not quest.RemoteObjectives[self.player] then
                    quest.RemoteObjectives[self.player] = {}
                end
                local index = self.stream:ReadByte()
                if not quest.RemoteObjectives[self.player][index] then
                    quest.RemoteObjectives[self.player][index] = {}
                end
                quest.RemoteObjectives[self.player][index].Needed = self.stream:ReadByte()
                quest.RemoteObjectives[self.player][index].Connected = self.stream:ReadByte()
            end
        end
    },
    [QC_ID_BROADCAST_QUESTIE_VERSION] = {
        write = function(self)
            local major, minor, patch = QuestieGetVersionInfo()
            self.stream:WriteBytes(major, minor, patch)
        end,
        read = function(self)
            if not __QUESTIE_ALREADY_UPDATE_MSG then -- hack to prevent saying there is an update twice
                local major, minor, patch = self.stream:ReadBytes(3)
                local majorNow, minorNow, patchNow = QuestieGetVersionInfo()

                if major > majorNow or (major == majorNow and minor > minorNow) or (major == majorNow and minor == minorNow and patch > patchNow) then
                    DEFAULT_CHAT_FRAME:AddMessage("Questie has updated! New version: |cFF22FF22v" .. tostring(major) .. "." .. tostring(minor) .. "." .. tostring(patch)) -- todo: make this better
                    __QUESTIE_ALREADY_UPDATE_MSG = true
                    -- ask for changelog
                    local clg = QuestieComms:GetPacket(QC_ID_ASK_CHANGELOG)
                    clg.player = self.player
                    clg.writeMode = QC_WRITE_WHISPER
                    QuestieComms:write(clg)
                    clg.stream:Finished()
                end
            end
        end,
        init = function(self)
            self.writeMode = QC_WRITE_CHANNEL
        end
    },
    [QC_ID_ASK_CHANGELOG] = {
        write = function(self)
            local major, minor, patch = QuestieGetVersionInfo()
            self.stream:WriteBytes(major, minor, patch)
        end,
        read = function(self)
            local sendChangelog = QuestieComms:GetPacket(QC_ID_SEND_CHANGELOG)
            sendChangelog.player = self.player
            sendChangelog.writeMode = QC_WRITE_WHISPER
            QuestieComms:write(sendChangelog)
            sendChangelog.stream:Finished()
        end
    },
    [QC_ID_SEND_CHANGELOG] = {
        write = function(self)
            local version = QuestieGetVersionString()
            local latest = _QuestieChangeLog[version]
            local count = 0;
            for _ in pairs(latest) do count = count + 1; end -- why does lua suck
            self.stream:WriteBytes(count)
            self.stream:WriteShortString(version)
            for _,change in pairs(latest) do
                self.stream:WriteShortString(change)
            end
            for _,v in pairs(_MakeSegments(self)) do
                --DEFAULT_CHAT_FRAME:AddMessage("lol" .. _ .. "  ".. v)
            end
        end,
        read = function(self)
            local count = self.stream:ReadByte()
            local ver = self.stream:ReadShortString()
            local changes = {}
            for i=1, count do
                local str = self.stream:ReadShortString()
                DEFAULT_CHAT_FRAME:AddMessage(str)
                table.insert(changes, str)
            end
        end
    },
    ["BroadcastQuests"] = {
        write = function(self)

        end,
        read = function(self)

        end
    },
    [QC_ID_ASK_QUESTS] = {
        write = function(self)
            local count = 0;
            for _ in pairs(self.quests) do count = count + 1; end -- why does lua suck
            self.stream:WriteByte(count)
            for _,id in pairs(self.quests) do
                self.stream:WriteShort(id)
            end
        end,
        read = function(self)
            local count = self.stream:ReadByte()
            local quests = {};
            for i=1, count do
                local qid = self.stream:ReadShort()
                local quest = QuestieDB:GetQuest(qid)
                if quest and quest.Objectives then
                    table.insert(quests, quest)
                end
            end
            local pkt = QuestieComms:GetPacket(QC_ID_SEND_QUESTS)
            pkt.player = self.player
            pkt.writeMode = QC_WRITE_WHISPER
            pkt.quests = quests
            QuestieComms:write(pkt)
            pkt.stream:Finished()
        end
    },
    [QC_ID_SEND_QUESTS] = {
        write = function(self)
            local count = 0;
            for _ in pairs(self.quests) do count = count + 1; end -- why does lua suck
            self.stream:WriteByte(count)
            for _,quest in pairs(self.quests) do
                self.stream:WriteShort(quest.Id)
                local count = 0;
                for _ in pairs(quest.Objectives) do count = count + 1; end -- why does lua suck
                self.stream:WriteByte(count)
                for index,v in pairs(quest.Objectives) do
                    self.stream:WriteBytes(index, v.Needed, v.Collected)
                end
            end
        end,
        read = function(self)
            local count = self.stream:ReadByte()
            for i=1, count do
                local quest = QuestieDB:GetQuest(self.stream:ReadShort())
                if not quest.RemoteObjectives then
                    quest.RemoteObjectives = {}
                end
                if not quest.RemoteObjectives[self.player] then
                    quest.RemoteObjectives[self.player] = {}
                end
                local cnt = self.stream:ReadByte()
                for i=1, cnt do
                    local index, needed, collected = self.stream:ReadBytes(3)
                    if not quest.RemoteObjectives[self.player][index] then
                        quest.RemoteObjectives[self.player][index] = {}
                    end
                    quest.RemoteObjectives[self.player][index].Needed = needed
                    quest.RemoteObjectives[self.player][index].Connected = collected
                end
            end
        end
    },
    [QC_ID_ASK_QUESTSLIST] = {
        write = function(self)
            -- no need to write anything, packet ID is enough
        end,
        read = function(self)
            local pkt = QuestieComms:GetPacket(QC_ID_SEND_QUESTSLIST)
            pkt.player = self.player
            pkt.writeMode = QC_WRITE_WHISPER
            QuestieComms:write(pkt)
            pkt.stream:Finished()
        end
    },
    [QC_ID_SEND_QUESTSLIST] = {
        write = function(self)
            local count = 0;
            for _ in pairs(QuestiePlayer.currentQuestlog) do count = count + 1; end -- why does lua suck
            self.stream:WriteByte(count)
            for id,_ in pairs(QuestiePlayer.currentQuestlog) do
                self.stream:WriteShort(id)
            end
        end,
        read = function(self)
            local count = self.stream:ReadByte()
            qRemoteQuestLogs[self.player] = {self.stream:ReadShorts(count)}
            local toAsk = {}
            for _,id in pairs(qRemoteQuestLogs[self.player]) do
                if QuestiePlayer.currentQuestlog[id] then
                    table.insert(toAsk, id)
                end
            end
            local pkt = QuestieComms:GetPacket(QC_ID_ASK_QUESTS)
            pkt.player = self.player
            pkt.writeMode = QC_WRITE_WHISPER
            pkt.quests = toAsk
            QuestieComms:write(pkt)
            pkt.stream:Finished()
        end
    }
}

function QuestieComms:TestGetQuestInfo(player)
    local pkt = QuestieComms:GetPacket(QC_ID_ASK_QUESTSLIST)
    pkt.writeMode = QC_WRITE_WHISPER
    pkt.player = player
    QuestieComms:write(pkt)
    pkt.stream:Finished()
end

function QuestieComms:read(rawPacket, sourceType, source)
    local stream = QuestieStreamLib:GetStream()
    stream:Load(rawPacket)
    local packetProcessor = _QuestieComms.packets[stream:ReadByte()];
    if (not packetProcessor) or (not packetProcessor.read) then
        -- invalid packet id, error or something
        return
    end

    local context = {};
    context.stream = stream
    context.type = sourceType
    context.source = source
    packetProcessor.read(context)

    stream:Finished() -- add back to stream pool (optional, will be garbage collected otherwise)
end

function QuestieComms:GetPacket(id)
    local pkt = {};
    for k,v in pairs(_QuestieComms.packets[id]) do
        pkt[k] = v
    end
    pkt.stream = QuestieStreamLib:GetStream()
    pkt.id = id
    if pkt.init then
        pkt:init()
    end
    return pkt
end

function _MakeSegments(packet)
    local metaStream = QuestieStreamLib:GetStream()
    if packet.stream._size < packet.stream._pointer then
        packet.stream._size = packet.stream._pointer
    end
    if packet.stream._size < 128 then
        metaStream:WriteByte(packet.id)
        metaStream:WriteByte(1) -- only 1 chunk
        metaStream:WriteByte(1) -- chunk id
        local meta = metaStream:Save()
        metaStream:Finished()
        return {meta .. ' ' .. packet.stream:Save()}
    end
    local ret = {};
    local count = math.ceil(packet.stream._size / 128.0)
    packet.stream:SetPointer(0)
    for i=1, count do
        metaStream:SetPointer(0)
        metaStream:WriteByte(packet.id)
        metaStream:WriteByte(count)
        metaStream:WriteByte(i)
        local dat = metaStream:Save()
        table.insert(ret, dat .. ' ' .. packet.stream:SavePart(128))
    end
    metaStream:Finished()
    return ret
end

function QuestieComms:write(packet)
    if not packet.write then
        DEFAULT_CHAT_FRAME:AddMessage("no writer!")
        -- packet has no writer, error or something
        return
    end
    --DEFAULT_CHAT_FRAME:AddMessage("QCWrite")
    packet:write()
    packet.stream._size = packet.stream._pointer
    packet.stream:SetPointer(0)
    if packet.writeMode == QC_WRITE_ALLGUILD then
        for _,segment in pairs(_MakeSegments(packet)) do
            DEFAULT_CHAT_FRAME:AddMessage("send(|cFFFF2222" .. segment .. "|r)")
            C_ChatInfo.SendAddonMessage("questie", segment, "GUILD")
        end
    elseif packet.writeMode == QC_WRITE_ALLGROUP then
        for _,segment in pairs(_MakeSegments(packet)) do
            DEFAULT_CHAT_FRAME:AddMessage("send(|cFFFF2222" .. segment .. "|r)")
            C_ChatInfo.SendAddonMessage("questie", segment, "PARTY")
        end
    elseif packet.writeMode == QC_WRITE_ALLRAID then
        for _,segment in pairs(_MakeSegments(packet)) do
            DEFAULT_CHAT_FRAME:AddMessage("send(|cFFFF2222" .. segment .. "|r)")
            C_ChatInfo.SendAddonMessage("questie", segment, "RAID")
        end
    elseif packet.writeMode == QC_WRITE_WHISPER then
        for _,segment in pairs(_MakeSegments(packet)) do
            DEFAULT_CHAT_FRAME:AddMessage("send(|cFFFF2222" .. segment .. "|r)")
            C_ChatInfo.SendAddonMessage("questie", segment, "WHISPER", packet.player)
        end
    elseif packet.writeMode == QC_WRITE_CHANNEL then
        for _,segment in pairs(_MakeSegments(packet)) do
            DEFAULT_CHAT_FRAME:AddMessage("send(|cFFFF2222" .. segment .. "|r)")
            C_ChatInfo.SendAddonMessage("questie", segment, "CHANNEL", GetChannelName("questiecom"))
        end
    end
end

QuestieComms.parserStream = QuestieStreamLib:GetStream()
QuestieComms.packetReadQueue = {}

function QuestieComms:MessageReceived(channel, message, type, source) -- pcall this
    DEFAULT_CHAT_FRAME:AddMessage("recv(|cFF22FF22" .. message .. "|r)")
    if channel == "questie" and source then
        QuestieComms.parserStream:load(string.sub(message, 0, string.find(message, " ")-1))
        local packetid, count, index = QuestieComms.parserStream:ReadBytes(3)
        if not QuestieComms.packetReadQueue[source] then
            QuestieComms.packetReadQueue[source] = {}
        end
        if not QuestieComms.packetReadQueue[source][packetid] then
            QuestieComms.packetReadQueue[source][packetid] = {}
            QuestieComms.packetReadQueue[source][packetid].count = count
            QuestieComms.packetReadQueue[source][packetid].have = 0
        end
        QuestieComms.packetReadQueue[source][packetid][index] = string.sub(message, string.find(message, " ")+1)
        QuestieComms.packetReadQueue[source][packetid].have = QuestieComms.packetReadQueue[source][packetid].have + 1
        if QuestieComms.packetReadQueue[source][packetid].have == count then
            -- process packet
            --DEFAULT_CHAT_FRAME:AddMessage("Process packet!")
            local pkt = QuestieComms:GetPacket(packetid)
            pkt.stream:SetPointer(0)
            for i=1, count do
                pkt.stream:LoadPart(QuestieComms.packetReadQueue[source][packetid][i])
            end
            pkt.stream._pointer = 0;
            pkt.player = source
            pkt:read()
            QuestieComms.packetReadQueue[source][packetid] = nil
        end
    end
end

function QuestieComms:BroadcastQuestUpdate(quest) -- broadcast quest update to group or raid
    local raid = UnitInRaid("player")
    local party = UnitInParty("player")
    if raid or party then
        local pkt = QuestieComms:GetPacket(QC_ID_BROADCAST_QUEST_UPDATE)
        pkt.quest = quest
        if raid then
            raid.writeMode = QC_WRITE_ALLRAID
        else
            raid.writeMode = QC_WRITE_ALLGROUP
        end
        QuestieComms:write(pkt)
        pkt.stream:Finished()
    end
end
]]--
