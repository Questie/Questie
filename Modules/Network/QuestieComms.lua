---@class QuestieComms
local QuestieComms = QuestieLoader:CreateModule("QuestieComms");
local _QuestieComms = QuestieComms.private
-------------------------
--Import modules.
-------------------------
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
---@type QuestLogCache
local QuestLogCache = QuestieLoader:ImportModule("QuestLogCache")

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

    -- TODO: replace with getting data over own comms in properly throttled manner
    -- see: https://github.com/Questie/Questie/issues/3540
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
    Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieComms:BroadcastQuestUpdate] Questid", questId)
    if(questId) then
        local partyType = QuestiePlayer:GetGroupType()
        Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieComms:BroadcastQuestUpdate] partyType", tostring(partyType))
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
    Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieComms:BroadcastQuestRemove] QuestId:", questId, "partyType:", tostring(partyType))
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

    local count = 0

    local rawObjectives = QuestLogCache.GetQuestObjectives(questId) -- DO NOT MODIFY THE RETURNED TABLE
    if (not rawObjectives) then return offset, count end

    if questObject and next(questObject.Objectives) then
        quest[offset] = questId
        local countOffset = offset+1

        offset = offset + 2
        for objectiveIndex, objective in pairs(rawObjectives) do -- DO NOT MODIFY THE RETURNED TABLE
            quest[offset] = questObject.Objectives[objectiveIndex].Id
            quest[offset + 1] = string.byte(string.sub(objective.type, 1, 1))
            quest[offset + 2] = objective.numFulfilled
            quest[offset + 3] = objective.numRequired
            offset = offset + 4
            count = count + 1
        end
        
        quest[countOffset] = count
    end


    Questie:Debug(Questie.DEBUG_SPAM, "[QuestieComms] questPacket made: Objectivetable:", quest)

    return offset, count
end

function QuestieComms:PopulateQuestDataPacketV2(questId, quest, offset)
    local questObject = QuestieDB:GetQuest(questId);

    local count = 0

    local rawObjectives = QuestLogCache.GetQuestObjectives(questId) -- DO NOT MODIFY THE RETURNED TABLE
    if (not rawObjectives) then return offset, count end

    if questObject and next(questObject.Objectives) then
        quest[offset] = questId
        local countOffset = offset+1
        local _, classFilename = UnitClass("player")
        quest[offset+2] = _classToIndex[classFilename]

        offset = offset + 3
        for objectiveIndex, objective in pairs(rawObjectives) do -- DO NOT MODIFY THE RETURNED TABLE
            quest[offset] = questObject.Objectives[objectiveIndex].Id
            quest[offset + 1] = string.byte(string.sub(objective.type, 1, 1))
            quest[offset + 2] = objective.numFulfilled
            quest[offset + 3] = objective.numRequired
            offset = offset + 4
            count = count + 1
        end
        
        quest[countOffset] = count
    end


    Questie:Debug(Questie.DEBUG_SPAM, "[QuestieComms] questPacket made: Objectivetable:", quest)

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
    Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieComms] Message", eventName, "partyType:", tostring(partyType))
    if partyType then
        local sorted = {}

        for questId, data in pairs(QuestLogCache.questLog_DO_NOT_MODIFY) do -- DO NOT MODIFY THE RETURNED TABLE
            if (not QuestieDB.QuestPointers[questId]) then
                if not Questie._sessionWarnings[questId] then
                    Questie:Error(l10n("The quest %s is missing from Questie's database, Please report this on GitHub or Discord!", tostring(questId)))
                    Questie._sessionWarnings[questId] = true
                end
            else
                local questType = data.questTag
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
    Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieComms] Message", eventName, "partyType:", tostring(partyType))
    if partyType then
        local sorted = {}

        for questId, data in pairs(QuestLogCache.questLog_DO_NOT_MODIFY) do -- DO NOT MODIFY THE RETURNED TABLE
            if (not QuestieDB.QuestPointers[questId]) then
                if not Questie._sessionWarnings[questId] then
                    Questie:Error(l10n("The quest %s is missing from Questie's database, Please report this on GitHub or Discord!", tostring(questId)))
                    Questie._sessionWarnings[questId] = true
                end
            else
                local questType = data.questTag
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
    Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieComms] Message", eventName, "partyType:", tostring(partyType))
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
    local quest = {
        id = questId,
        objectives = {},
    }

    local rawObjectives = QuestLogCache.GetQuestObjectives(questId) -- DO NOT MODIFY THE RETURNED TABLE
    if (not rawObjectives) then return quest end

    if questObject and next(questObject.Objectives) then
        for objectiveIndex, objective in pairs(rawObjectives) do -- DO NOT MODIFY THE RETURNED TABLE
            if questObject.Objectives[objectiveIndex] then
                quest.objectives[objectiveIndex] = {};
                quest.objectives[objectiveIndex].id = questObject.Objectives[objectiveIndex].Id;--[_QuestieComms.idLookup["id"]] = questObject.Objectives[objectiveIndex].Id;
                quest.objectives[objectiveIndex].typ = string.sub(objective.type, 1, 1);-- Get the first char only.--[_QuestieComms.idLookup["type"]] = string.sub(objective.type, 1, 1);-- Get the first char only.
                quest.objectives[objectiveIndex].fin = objective.finished;--[_QuestieComms.idLookup["finished"]] = objective.finished;
                quest.objectives[objectiveIndex].ful = objective.numFulfilled;--[_QuestieComms.idLookup["fulfilled"]] = objective.numFulfilled;
                quest.objectives[objectiveIndex].req = objective.numRequired;--[_QuestieComms.idLookup["required"]] = objective.numRequired;
            else
                Questie:Error("Missing objective data for quest " .. tostring(questId) .. " " .. tostring(objectiveIndex))
            end
        end
    end
    Questie:Debug(Questie.DEBUG_SPAM, "[QuestieComms] questPacket made: Objectivetable:", quest.objectives)
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
            Questie:Debug(Questie.DEBUG_INFO, "[QuestieComms] Sending: QC_ID_BROADCAST_QUEST_UPDATE")
            _QuestieComms:Broadcast(self.data);
        end,
        read = function(remoteQuestPacket)
            if not remoteQuestPacket then
                Questie:Error("[QuestieComms] QC_ID_BROADCAST_QUEST_UPDATE no remoteQuestPacket")
            end
            --These are not strictly needed but helps readability.
            local playerName = remoteQuestPacket.playerName;
            local quest = remoteQuestPacket.quest;

            Questie:Debug(Questie.DEBUG_INFO, "[QuestieComms] Received: QC_ID_BROADCAST_QUEST_UPDATE Player:", playerName)

            QuestieComms:InsertQuestDataPacket(quest, playerName);
        end
    },
    [_QuestieComms.QC_ID_BROADCAST_QUEST_REMOVE] = { --2
      write = function(self)
        Questie:Debug(Questie.DEBUG_INFO, "[QuestieComms] Sending: QC_ID_BROADCAST_QUEST_REMOVE")
        _QuestieComms:Broadcast(self.data);
      end,
      read = function(remoteQuestPacket)
        if not remoteQuestPacket then
            Questie:Error("[QuestieComms] QC_ID_BROADCAST_QUEST_REMOVE no remoteQuestPacket")
        end
        Questie:Debug(Questie.DEBUG_DEVELOP, "[QuestieComms] Received: QC_ID_BROADCAST_QUEST_REMOVE")

        local playerName = remoteQuestPacket.playerName;
        local questId = remoteQuestPacket.id;

        if(QuestieComms.remoteQuestLogs[questId] and QuestieComms.remoteQuestLogs[questId][playerName]) then
            Questie:Debug(Questie.DEBUG_INFO, "[QuestieComms] Removed quest:", questId, "for player:", playerName);
            QuestieComms.remoteQuestLogs[questId][playerName] = nil;
        end
        QuestieComms.data:RemoveQuestFromPlayer(questId, playerName);
      end
    },
    [_QuestieComms.QC_ID_BROADCAST_FULL_QUESTLIST] = { --10
        write = function(self)
            Questie:Debug(Questie.DEBUG_INFO, "[QuestieComms] Sending: QC_ID_BROADCAST_FULL_QUESTLIST")
            _QuestieComms:Broadcast(self.data);
        end,
        read = function(remoteQuestList)
            if not remoteQuestList then
                Questie:Error("[QuestieComms] QC_ID_BROADCAST_FULL_QUESTLIST no remoteQuestList")
            end
            --These are not strictly needed but helps readability.
            local playerName = remoteQuestList.playerName;
            local questList = remoteQuestList.rawQuestList;

            Questie:Debug(Questie.DEBUG_INFO, "[QuestieComms] Received: QC_ID_BROADCAST_FULL_QUESTLIST Player:", playerName, questList)

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
            Questie:Debug(Questie.DEBUG_INFO, "[QuestieComms] Sending: QC_ID_REQUEST_FULL_QUESTLIST")
            _QuestieComms:Broadcast(self.data);
        end,
        read = function(self)
            Questie:Debug(Questie.DEBUG_INFO, "[QuestieComms] Received: QC_ID_REQUEST_FULL_QUESTLIST")
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
            Questie:Debug(Questie.DEBUG_INFO, "[QuestieComms] Sending: QC_ID_REQUEST_FULL_QUESTLISTV2")
            _QuestieComms:Broadcast(self.data);
        end,
        read = function(self)
            Questie:Debug(Questie.DEBUG_INFO, "[QuestieComms] Received: QC_ID_REQUEST_FULL_QUESTLISTV2")
            local offset = 2
            local count = self[1][1]
            for _= 1, count do
                offset = QuestieComms:InsertQuestDataPacketV2_noclass_RenameMe(self[1], self.playerName, offset, false)
            end
        end
    },
    [_QuestieComms.QC_ID_YELL_PROGRESS] = { --13
        write = function(self)
            Questie:Debug(Questie.DEBUG_INFO, "[QuestieComms] Sending: QC_ID_YELL_PROGRESS")
            if not badYellLocations[C_Map.GetBestMapForUnit("player")] then
               _QuestieComms:Broadcast(self.data);
            end
        end,
        read = function(self)
            Questie:Debug(Questie.DEBUG_INFO, "[QuestieComms] Received: QC_ID_YELL_PROGRESS")
            if not Questie.db.global.disableYellComms and not badYellLocations[C_Map.GetBestMapForUnit("player")] then
                QuestieComms.remotePlayerTimes[self.playerName] = GetTime()
                QuestieComms:InsertQuestDataPacketV2(self[1], self.playerName, 1, true)
                QuestieComms:SortRemotePlayers()
            end
        end
    },
    [_QuestieComms.QC_ID_BROADCAST_QUEST_UPDATEV2] = { -- 14
        write = function(self)
            Questie:Debug(Questie.DEBUG_INFO, "[QuestieComms] Sending: QC_ID_BROADCAST_QUEST_UPDATEV2")
            _QuestieComms:Broadcast(self.data);
        end,
        read = function(self)
            Questie:Debug(Questie.DEBUG_INFO, "[QuestieComms] Received: QC_ID_BROADCAST_QUEST_UPDATEV2")
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
        Questie:Debug(Questie.DEBUG_DEVELOP,"send(|cFFFF2222", string.len(compressedData), "|r)")
        Questie:SendCommMessage(_QuestieComms.prefix, compressedData, packetWriteMode, packetTarget, packetPriority)
    elseif packetWriteMode == _QuestieComms.QC_WRITE_CHANNEL then
        local compressedData = QuestieSerializer:Serialize(packet);
        Questie:Debug(Questie.DEBUG_DEVELOP,"send(|cFFFF2222", string.len(compressedData), "|r)")
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
        Questie:Debug(Questie.DEBUG_DEVELOP, "send(|cFFFF2222", string.len(compressedData), "|r)")
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
