QuestieComms = {};

QC_WRITE_ALLGUILD = 1
QC_WRITE_ALLGROUP = 2
QC_WRITE_ALLRAID = 3
QC_WRITE_WHISPER = 4
QC_WRITE_CHANNEL = 5

QC_ID_BROADCAST_QUEST_UPDATE = 1 -- send quest_log_update status to party/raid members
QC_ID_BROADCAST_QUESTIE_GETVERSION = 2 -- ask anyone for the newest questie version
QC_ID_BROADCAST_QUESTIE_VERSION = 3 -- broadcast the current questie version
QC_ID_ASK_CHANGELOG = 4
QC_ID_SEND_CHANGELOG = 5
QC_ID_ASK_QUEST = 6
QC_ID_SEND_QUEST = 7
QC_ID_ASK_QUESTLIST = 8
QC_ID_SEND_QUESTLIST = 9

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
			self.stream:writeShort(self.Quest.Id)
			self.stream:writeByte(#self.Quest.Objectives)
			for _,objective in pairs(self.Quest.Objectives) do
				self.stream:writeBytes(objective.Index, objective.Needed, objective.Collected)
			end
		end,
		read = function(self)
			local remoteQuestData = {};
			remoteQuestData.Objectives = {};
			remoteQuestData.Id = stream:readShort()
			local count = stream:readByte()
			for i=1,count do
				local index = stream:readByte()
				remoteQuestData.Objectives[index] = {}
				remoteQuestData.Objectives[index].Needed = stream:readByte()
				remoteQuestData.Objectives[index].Collected = stream:readByte()
			end
		end
	},
	[QC_ID_BROADCAST_QUESTIE_VERSION] = {
		write = function(self)
			local major, minor, patch = QuestieGetVersionInfo()
			self.stream:writeBytes(major, minor, patch)
		end,
		read = function(self)
			if not __QUESTIE_ALREADY_UPDATE_MSG then -- hack to prevent saying there is an update twice
				local major, minor, patch = self.stream:readBytes(3)
				local majorNow, minorNow, patchNow = QuestieGetVersionInfo()
				
				if major > majorNow or (major == majorNow and minor > minorNow) or (major == majorNow and minor == minorNow and patch > patchNow) then
					DEFAULT_CHAT_FRAME:AddMessage("Questie has updated! New version: |cFF22FF22v" .. tostring(major) .. "." .. tostring(minor) .. "." .. tostring(patch)) -- todo: make this better
					__QUESTIE_ALREADY_UPDATE_MSG = true
					-- ask for changelog
					local clg = QuestieComms:getPacket(QC_ID_ASK_CHANGELOG)
					clg.player = self.player
					clg.writeMode = QC_WRITE_WHISPER
					QuestieComms:write(clg)
					clg.stream:finished()
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
			self.stream:writeBytes(major, minor, patch)
		end,
		read = function(self)
			local sendChangelog = QuestieComms:getPacket(QC_ID_SEND_CHANGELOG)
			sendChangelog.player = self.player
			sendChangelog.writeMode = QC_WRITE_WHISPER
			QuestieComms:write(sendChangelog)
			sendChangelog.stream:finished()
		end
	},
	[QC_ID_SEND_CHANGELOG] = {
		write = function(self)
			local version = QuestieGetVersionString()
			local latest = _QuestieChangeLog[version]
			local count = 0;
			for _,_ in pairs(latest) do count = count + 1; end -- why does lua suck
			self.stream:writeBytes(count)
			self.stream:writeShortString(version)
			for _,change in pairs(latest) do
				self.stream:writeShortString(change)
			end
			for _,v in pairs(_makeSegments(self)) do
				--DEFAULT_CHAT_FRAME:AddMessage("lol" .. _ .. "  ".. v)
			end
		end,
		read = function(self)
			local count = self.stream:readByte()
			local ver = self.stream:readShortString()
			local changes = {}
			for i=1,count do
				local str = self.stream:readShortString()
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
    [QC_ID_ASK_QUEST] = {
        write = function(self)
			self.stream:writeShort(self.questId)
        end,
        read = function(self)
			local qid = self.stream:readShort()
			local quest = QuestieDB:GetQuest(qid)
			
			if quest and quest.Objectives then
				local pkt = QuestieComms:getPacket(QC_ID_SEND_QUEST)
				pkt.player = self.player
				pkt.writeMode = QC_WRITE_WHISPER
				pkt.quest = quest
				QuestieComms:write(pkt)
				pkt.stream:finished()
			end
        end
    },
	[QC_ID_SEND_QUEST] = {
		write = function(self)
			self.stream:writeShort(self.quest.Id)
			local count = 0;
			for _,_ in pairs(self.quest.Objectives) do count = count + 1; end -- why does lua suck
			self.stream:writeByte(count)
			for index,v in pairs(self.quest.Objectives) do
				self.stream:writeBytes(index, v.Needed, v.Collected)
			end
		end,
		read = function(self)
			local quest = QuestieDB:GetQuest(self.stream:readShort())
			if not Quest.RemoteObjectives then
				Quest.RemoteObjectives = {}
			end
			if not Quest.RemoteObjectives[self.player] then
				Quest.RemoteObjectives[self.player] = {}
			end
			local cnt = self.stream:readByte()
			for i=1,cnt do
				local index, needed, collected = self.stream:readBytes(3)
				Quest.RemoteObjectives[self.player][index].Needed = needed
				Quest.RemoteObjectives[self.player][index].Connected = collected
			end
		end
	}
}

function QuestieComms:read(rawPacket, sourceType, source)
    local stream = QuestieStreamLib:getStream()
    stream:load(rawPacket)
    local packetProcessor = QuestieComms.packets[stream:readByte()];
    if (not packetProcessor) or (not packetProcessor.read) then
        -- invalid packet id, error or something
        return
    end
    
    local context = {};
    context.stream = stream
    context.type = sourceType
    context.source = source
    packetProcessor.read(context)
    
    stream:finished() -- add back to stream pool (optional, will be garbage collected otherwise)
end

function QuestieComms:getPacket(id)
	local pkt = {};
	for k,v in pairs(QuestieComms.packets[id]) do
		pkt[k] = v
	end
	pkt.stream = QuestieStreamLib:getStream()
	pkt.id = id
	if pkt.init then
		pkt:init()
	end
	return pkt
end

function _makeSegments(packet)
	local metaStream = QuestieStreamLib:getStream()
	if packet.stream._size < packet.stream._pointer then
        packet.stream._size = packet.stream._pointer
    end
	if packet.stream._size < 128 then
		metaStream:writeByte(packet.id)
		metaStream:writeByte(1) -- only 1 chunk
		metaStream:writeByte(1) -- chunk id
		local meta = metaStream:save()
		metaStream:finished()
		return {meta .. ' ' .. packet.stream:save()}
	end
	local ret = {};
	local count = math.ceil(packet.stream._size / 128.0)
	packet.stream:setPointer(0)
	for i=1,count do
		metaStream:setPointer(0)
		metaStream:writeByte(packet.id)
		metaStream:writeByte(count)
		metaStream:writeByte(i)
		local dat = metaStream:save()
		table.insert(ret, dat .. ' ' .. packet.stream:savePart(128))
	end
	metaStream:finished()
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
	packet.stream:setPointer(0)
    if packet.writeMode == QC_WRITE_ALLGUILD then
		for _,segment in pairs(_makeSegments(packet)) do
			DEFAULT_CHAT_FRAME:AddMessage("send(|cFFFF2222" .. segment .. "|r)")
			C_ChatInfo.SendAddonMessage("questie", segment, "GUILD")
		end
    elseif packet.writeMode == QC_WRITE_ALLGROUP then
		for _,segment in pairs(_makeSegments(packet)) do
			DEFAULT_CHAT_FRAME:AddMessage("send(|cFFFF2222" .. segment .. "|r)")
			C_ChatInfo.SendAddonMessage("questie", segment, "PARTY")
		end
    elseif packet.writeMode == QC_WRITE_ALLRAID then
		for _,segment in pairs(_makeSegments(packet)) do
			DEFAULT_CHAT_FRAME:AddMessage("send(|cFFFF2222" .. segment .. "|r)")
			C_ChatInfo.SendAddonMessage("questie", segment, "RAID")
		end
    elseif packet.writeMode == QC_WRITE_WHISPER then
		for _,segment in pairs(_makeSegments(packet)) do
			DEFAULT_CHAT_FRAME:AddMessage("send(|cFFFF2222" .. segment .. "|r)")
			C_ChatInfo.SendAddonMessage("questie", segment, "WHISPER", packet.player)
		end
    elseif packet.writeMode == QC_WRITE_CHANNEL then
		for _,segment in pairs(_makeSegments(packet)) do
			DEFAULT_CHAT_FRAME:AddMessage("send(|cFFFF2222" .. segment .. "|r)")
			C_ChatInfo.SendAddonMessage("questie", segment, "CHANNEL", GetChannelName("questiecom"))
		end
    end
end

QuestieComms.parserStream = QuestieStreamLib:getStream()
QuestieComms.packetReadQueue = {}

function QuestieComms:MessageReceived(channel, message, type, source) -- pcall this
	DEFAULT_CHAT_FRAME:AddMessage("recv(|cFF22FF22" .. message .. "|r)")
	if channel == "questie" and source then
		QuestieComms.parserStream:load(string.sub(message, 0, string.find(message, " ")-1))
		local packetid, count, index = QuestieComms.parserStream:readBytes(3)
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
			local pkt = QuestieComms:getPacket(packetid)
			pkt.stream:setPointer(0)
			for i=1,count do
				pkt.stream:loadPart(QuestieComms.packetReadQueue[source][packetid][i])
			end
			pkt.stream._pointer = 0;
			pkt.player = source
			pkt:read()
			QuestieComms.packetReadQueue[source][packetid] = nil
		end
	end
end