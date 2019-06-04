QuestieComms = {};

QC_WRITE_ALLGUILD = 1
QC_WRITE_ALLGROUP = 2
QC_WRITE_ALLRAID = 3
QC_WRITE_WHISPER = 4
QC_WRITE_CHANNEL = 5

ID_BROADCAST_QUEST_UPDATE = 1

QuestieComms.packets = {
    [ID_BROADCAST_QUEST_UPDATE] = {
        write = function(self)
            self.stream:setPointer(0) -- reset stream
            self.stream:writeByte(ID_BROADCAST_QUEST_UPDATE)
            self.stream:writeShort(self.Quest.Id)
            self.stream:writeByte(#self.Quest.Objectives)
            for _,objective in pairs(self.Quest.Objectives) do
                self.stream:writeByte(objective.Index)
                self.stream:writeByte(objective.Needed)
                self.stream:writeByte(objective.Collected)
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
            
            -- run functions in QuestieQuest to update group quest data from remoteQuestData here
        end
    },
    ["BroadcastQuests"] = {
    
    },
    ["AskQuest"] = {
        write = function(self)
        
        end,
        read = function(self)
        
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

function QuestieComms:write(packet)
    if not packet.write then
        -- packet has no writer, error or something
        return
    end
    packet:write()
    if packet.writeMode == QC_WRITE_ALLGUILD then
    
    elseif packet.writeMode == QC_WRITE_ALLGROUP then
    
    elseif packet.writeMode == QC_WRITE_ALLRAID then
    
    elseif packet.writeMode == QC_WRITE_WHISPER then
    
    elseif packet.writeMode == QC_WRITE_CHANNEL then
    
    end
end