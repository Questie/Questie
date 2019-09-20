QuestieComms = {...};
local _QuestieComms = {...};
-- Addon message prefix
_QuestieComms.prefix = "questie";
-- List of all players questlog private to prevent modification from the outside.
_QuestieComms.remoteQuestLogs = {};

--Channel types
_QuestieComms.QC_WRITE_ALLGUILD = "GUILD"
_QuestieComms.QC_WRITE_ALLGROUP = "PARTY"
_QuestieComms.QC_WRITE_ALLRAID = "RAID"
_QuestieComms.QC_WRITE_WHISPER = "WHISPER"
_QuestieComms.QC_WRITE_CHANNEL = "CHANNEL"

--Message types.
_QuestieComms.QC_ID_BROADCAST_QUEST_UPDATE = 1 -- send quest_log_update status to party/raid members
-- NYI ->
_QuestieComms.QC_ID_BROADCAST_QUESTIE_GETVERSION = 2 -- ask anyone for the newest questie version
_QuestieComms.QC_ID_BROADCAST_QUESTIE_VERSION = 3 -- broadcast the current questie version
_QuestieComms.QC_ID_ASK_CHANGELOG = 4 -- ask a player for the changelog
_QuestieComms.QC_ID_SEND_CHANGELOG = 5
_QuestieComms.QC_ID_ASK_QUESTS = 6 -- ask a player for their quest progress on specific quests
_QuestieComms.QC_ID_SEND_QUESTS = 7
_QuestieComms.QC_ID_ASK_QUESTSLIST = 8 -- ask a player for their current quest log as a list of quest IDs
_QuestieComms.QC_ID_SEND_QUESTSLIST = 9
-- <-- NYI
_QuestieComms.QC_ID_BROADCAST_FULL_QUESTLIST = 10

--- Global Functions --


--Move to Questie.lua after QuestieOptions move.
function Questie:GetAddonVersionInfo()  -- todo: better place
    local _, title, _, _, _, reason = GetAddOnInfo("QuestieDev-master");
    if(reason == "MISSING") then
      _, title = GetAddOnInfo("Questie");
    end
    local major, minor, patch = string.match(title, "v(%d+)\.(%d+)\.(%d+)");
    return tonumber(major), tonumber(minor), tonumber(patch);
end


-- THIS SHOULD NOT BE HERE
function QuestieQuest:ConvertDescription(description)
  -- stub, return a converted datastream.
end


---------
-- Fetch quest information about a specific player.
-- Params:
--  playerName (string)
--  questId (int)
-- Return:
--  Similar object as QuestieQuest:GetRawLeaderBoardDetails()
--  Quest.(Id|level|isComplete) --title is trimmed to save space
--  Quest.Objectives[index].(description|objectiveType|isCompleted)
---------
function QuestieComms:GetQuest(playerName, questId)
  if(_QuestieComms.remoteQuestLogs[playerName]) then
    if(_QuestieComms.remoteQuestLogs[playerName][questId]) then
      -- Create a copy of the object, other side should never be able to edit the underlying object.
      local quest = {};
      for key,value in pairs(_QuestieComms.remoteQuestLogs[playerName][questId]) do
        if(key ~= "title" and key ~= "compareString") then --Trim title and compareString string, felt good, might add more late idk UwU.
          quest[key] = value;
        end
      end
      return quest;
    end
  end
  return nil;
end

function QuestieComms:Initialize()
  -- Lets us send any length of message. Also implements ChatThrottleLib to not get disconnected.
  Questie:RegisterComm(_QuestieComms.prefix, _QuestieComms.OnCommReceived);

  -- Events to be used to broadcast updates to other people
  Questie:RegisterEvent("QC_ID_BROADCAST_QUEST_UPDATE", _QuestieComms.BroadcastQuestUpdate);
  Questie:RegisterEvent("QC_ID_BROADCAST_FULL_QUESTLIST", _QuestieComms.BroadcastQuestLog);
end

-- Local Functions --

function _QuestieComms:BroadcastQuestUpdate(eventName, quest) -- broadcast quest update to group or raid
  if(quest) then
    local raid = UnitInRaid("player")
    local party = UnitInParty("player")
    if raid or party then
      --Do we really need to make this?
      local questPacket = _QuestieComms:createPacket(_QuestieComms.QC_ID_BROADCAST_QUEST_UPDATE)
      --Trim these
      quest.compareString = nil;
      quest.title = nil;

      questPacket.data.quest = quest
      questPacket.data.priority = "NORMAL";
      if raid then
        questPacket.data.writeMode = _QuestieComms.QC_WRITE_ALLRAID
      else
        questPacket.data.writeMode = _QuestieComms.QC_WRITE_ALLGROUP
      end
      questPacket:write()
    end
  end
end

function _QuestieComms:BroadcastQuestLog(eventName) -- broadcast quest update to group or raid
  local raid = UnitInRaid("player")
  local party = UnitInParty("player")
  if raid or party then
    local rawQuestList = {}
    -- Maybe this should be its own function in QuestieQuest...
    local numEntries, numQuests = GetNumQuestLogEntries();
    for index = 1, numEntries do
      local title, level, _, isHeader, _, isComplete, _, questId, _, displayQuestId, _, _, _, _, _, _, _ = GetQuestLogTitle(index)
      if(not isHeader) then
        local quest = QuestieQuest:GetRawLeaderBoardDetails(index);
        --Trim these
        quest.compareString = nil;
        quest.title = nil;

        rawQuestList[quest.Id] = quest;
      end
    end

    --Do we really need to make this?
    local questPacket = _QuestieComms:createPacket(_QuestieComms.QC_ID_BROADCAST_FULL_QUESTLIST);
    questPacket.data.rawQuestList = rawQuestList;

    -- We might aswell send the current version to the party member.
    questPacket.data.version = table.pack(Questie:GetAddonVersionInfo());
    if raid then
      questPacket.data.writeMode = _QuestieComms.QC_WRITE_ALLRAID;
      questPacket.data.priority = "BULK";
    else
      questPacket.data.writeMode = _QuestieComms.QC_WRITE_ALLGROUP;
      questPacket.data.priority = "NORMAL";
    end
    questPacket:write();
  end
end

_QuestieComms.packets = {
  [_QuestieComms.QC_ID_BROADCAST_QUEST_UPDATE] = {
      write = function(self)
          self.data.playerName = UnitName("player");
          _QuestieComms:broadcast(self.data);
      end,
      read = function(self, remoteQuestPacket)
        --These are not strictly needed but helps readability.
        local playerName = remoteQuestPacket.playerName;
        local quest = remoteQuestPacket.quest;
        if quest then
          -- Create empty player.
          if not _QuestieComms.remoteQuestLogs[playerName] then
              _QuestieComms.remoteQuestLogs[playerName] = {}
          end
          -- Create empty quests.
          if not _QuestieComms.remoteQuestLogs[playerName][quest.Id] then
              _QuestieComms.remoteQuestLogs[playerName][quest.Id] = {}
          end
          _QuestieComms.remoteQuestLogs[playerName][quest.Id] = quest;
        end
      end
  },
  [_QuestieComms.QC_ID_BROADCAST_FULL_QUESTLIST] = {
      write = function(self)
          self.data.playerName = UnitName("player");
          _QuestieComms:broadcast(self.data);
      end,
      read = function(self, remoteQuestPacket)
        --These are not strictly needed but helps readability.
        local playerName = remoteQuestPacket.playerName;
        local quest = remoteQuestPacket.quest;
        
        -- Maybe we shouldn't send this here?
        local major, minor, patch = table.unpack(remoteQuestPacket.version);
        if quest then
          -- Create empty player.
          if not _QuestieComms.remoteQuestLogs[playerName] then
              _QuestieComms.remoteQuestLogs[playerName] = {}
          end
          -- Create empty quests.
          if not _QuestieComms.remoteQuestLogs[playerName][quest.Id] then
              _QuestieComms.remoteQuestLogs[playerName][quest.Id] = {}
          end
          _QuestieComms.remoteQuestLogs[playerName][quest.Id] = quest;
        end
      end
  },
}

-- Renamed Write function
function _QuestieComms:broadcast(packet)
    -- If the priority is not set, it must not be very important
    if(not packet.priority) then
      packet.priority = "BULK";
    end
    local compressedData = QuestieCompress:Compress(packet);
    if packet.writeMode == _QuestieComms.QC_WRITE_WHISPER then
        Questie:Debug(DEBUG_DEVELOP,"send(|cFFFF2222" .. compressedData .. "|r)")
        Questie:SendCommMessage(_QuestieComms.prefix, compressedData, packet.writeMode, packet.target, packet.priority)
    elseif packet.writeMode == _QuestieComms.QC_WRITE_CHANNEL then
        Questie:Debug(DEBUG_DEVELOP,"send(|cFFFF2222" .. compressedData .. "|r)")
        -- Always do channel messages as BULK priority
        Questie:SendCommMessage(_QuestieComms.prefix, compressedData, packet.writeMode, GetChannelName("questiecom"), "BULK")
        --OLD: C_ChatInfo.SendAddonMessage("questie", compressedData, "CHANNEL", GetChannelName("questiecom"))
    else
        Questie:Debug(DEBUG_DEVELOP, "send(|cFFFF2222" .. compressedData .. "|r)")
        Questie:SendCommMessage(_QuestieComms.prefix, compressedData, packet.writeMode, nil, packet.priority)
        --OLD: C_ChatInfo.SendAddonMessage("questie", compressedData, packet.writeMode)
    end
end

function _QuestieComms:OnCommReceived(prefix, message, distribution, sender)
    Questie:Debug(DEBUG_DEVELOP, "recv(|cFF22FF22" .. message .. "|r)")
    if prefix == _QuestieComms.prefix and sender then
      local decompressedData = QuestieCompress:Decompress(message);
      QuestieComms.packets[message.messageId].read(decompressedData);
    end
end

-- Copied: Is this really needed? Can't we just optimize away this?
function _QuestieComms:createPacket(messageId)
    -- Duplicate the object.
    local pkt = {};
    for k,v in pairs(QuestieComms.packets[messageId]) do
        pkt[k] = v
    end
    -- Set messageId
    pkt.data.messageId = messageId
    -- Some messages initialize
    if pkt.init then
        pkt:init()
    end
    return pkt
end



-- NOT USED
function QuestieComms:MessageReceived(channel, message, type, source) -- pcall this
    Questie:Debug(DEBUG_DEVELOP, "recv(|cFF22FF22" .. message .. "|r)")
    if channel == "questie" and source then
      local decompressedData = QuestieCompress:decompress(message);
      QuestieComms.packets[message.messageId].read(decompressedData);
    end
end

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

QuestieComms.packets = {
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
            for i=1,count do
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
            for i=1,count do
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
            for i=1,count do
                local quest = QuestieDB:GetQuest(self.stream:ReadShort())
                if not quest.RemoteObjectives then
                    quest.RemoteObjectives = {}
                end
                if not quest.RemoteObjectives[self.player] then
                    quest.RemoteObjectives[self.player] = {}
                end
                local cnt = self.stream:ReadByte()
                for i=1,cnt do
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
            for _ in pairs(qCurrentQuestlog) do count = count + 1; end -- why does lua suck
            self.stream:WriteByte(count)
            for id,_ in pairs(qCurrentQuestlog) do
                self.stream:WriteShort(id)
            end
        end,
        read = function(self)
            local count = self.stream:ReadByte()
            qRemoteQuestLogs[self.player] = {self.stream:ReadShorts(count)}
            local toAsk = {}
            for _,id in pairs(qRemoteQuestLogs[self.player]) do
                if qCurrentQuestlog[id] then
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
    local packetProcessor = QuestieComms.packets[stream:ReadByte()];
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
    for k,v in pairs(QuestieComms.packets[id]) do
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
    for i=1,count do
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
            for i=1,count do
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