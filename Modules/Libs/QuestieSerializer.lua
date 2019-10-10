QuestieSerializer = {}

function QuestieSerializer:Hash(value)
    if not value or type(value) ~= "string" or (string.len(value) <= 0) then
        return 0
    end
    local h = 5381
    for i=1,string.len(value) do
        h = bit.band((31 * h + string.byte(value, i)), 4294967295)
    end
    return h
end

QuestieSerializer.SerializerHashDB = { -- todo: move this to a savedvariable
}
QuestieSerializer.SerializerHashDBReversed = {
}

local function addHash(str)
    local hash = QuestieSerializer:Hash(str)
    QuestieSerializer.SerializerHashDB[str] = hash
    QuestieSerializer.SerializerHashDBReversed[hash] = str
end


local function _pack(a, b, c, d)
    return bit.lshift(a, 24) + bit.lshift(b, 16) + bit.lshift(c, 8) + d
end
local function _unpack(val)
    return (mod(bit.rshift(val, 24), 256)),
    (mod(bit.rshift(val, 16), 256)),
    (mod(bit.rshift(val, 8), 256)),
    (mod(val, 256));
end

-- code taken from lua-MessagePack (modified)
local function floatBitsToInt(n)
    local sign = 0
    if n < 0.0 then
        sign = 0x80
        n = -n
    end
    local mant, expo = frexp(n)
    if mant ~= mant then
        return _pack(0xFF, 0x88, 0x00, 0x00) -- nan
    elseif mant == huge or expo > 0x80 then
        if sign == 0 then
            return _pack(0x7F, 0x80, 0x00, 0x00) -- inf
        else
            return _pack(0xFF, 0x80, 0x00, 0x00) -- -inf
        end
    elseif (mant == 0.0 and expo == 0) or expo < -0x7E then
        return _pack(sign, 0x00, 0x00, 0x00)-- zero
    else
        expo = expo + 0x7E
        mant = floor((mant * 2.0 - 1.0) * ldexp(0.5, 24))
        return _pack(sign + floor(expo / 0x2), (expo % 0x2) * 0x80 + floor(mant / 0x10000), floor(mant / 0x100) % 0x100, mant % 0x100)
    end
end
local function intBitsToFloat(int)
    local b1, b2, b3, b4 = _unpack(int)
    local sign = b1 > 0x7F
    local expo = (b1 % 0x80) * 0x2 + floor(b2 / 0x80)
    local mant = ((b2 % 0x80) * 0x100 + b3) * 0x100 + b4
    if sign then
        sign = -1
    else
        sign = 1
    end
    local n
    if mant == 0 and expo == 0 then
        n = sign * 0.0
    elseif expo == 0xFF then
        if mant == 0 then
            n = sign * huge
        else
            n = 0.0/0.0
        end
    else
        n = sign * ldexp(1.0 + mant / 0x800000, expo - 0x7F)
    end
    return n
end

local function _ReadTable(self, entryCount)
    local ret = {}
    for i=1,entryCount do
        local key = QuestieSerializer.ReaderTable[self.stream:ReadByte()](self)
        local value = QuestieSerializer.ReaderTable[self.stream:ReadByte()](self)
        ret[key] = value
    end
    return ret
end

QuestieSerializer.ReaderTable = {
    [2] = function(self) return self.stream:ReadInt() end,
    [3] = function(self) return -self.stream:ReadInt() end,
    [4] = function(self) return self.stream:ReadLong() end,
    [5] = function(self) return -self.stream:ReadLong() end,
    [6] = function(self) return intBitsToFloat(self.stream:ReadInt()) end,
    
    [7] = function(self) return self.stream:ReadTinyString() end,
    [8] = function(self) return self.stream:ReadShortString() end,
    [9] = function(self) return QuestieSerializer.SerializerHashDBReversed[self.stream:ReadInt()] end,
    
   [10] = function(self) return _ReadTable(self, self.stream:ReadByte()) end,
   [11] = function(self) return _ReadTable(self, self.stream:ReadShort()) end,
   
   [12] = function(self) return self.stream:ReadByte() end,
   [13] = function(self) return -self.stream:ReadByte() end,
   [14] = function(self) return self.stream:ReadShort() end,
   [15] = function(self) return -self.stream:ReadShort() end,
}

QuestieSerializer.WriterTable = {
    ["number"] = function(self, value)
        local _, fract = math.modf(value)
        if fract > 0 then
            QuestieSerializer.WriterTable["float"](self, value)
        else
            local sign = 0
            if value < 0 then
                value = math.abs(value)
                sign = 1
            end
            if value > 2147483646 then
                self.stream:WriteByte(4 + sign) 
                self.stream:WriteLong(value)
            elseif value < 250 then
                self.stream:WriteByte(12 + sign) 
                self.stream:WriteByte(value)
            elseif value < 65530 then
                self.stream:WriteByte(14 + sign) 
                self.stream:WriteShort(value)
            else
                self.stream:WriteByte(2 + sign) 
                self.stream:WriteInt(value)
            end
        end
    end,
    ["float"] = function(self, value) 
        self.stream:WriteByte(6)
        self.stream:WriteInt(floatBitsToInt(value))
    end,
    ["string"] = function(self, value)
        if QuestieSerializer.SerializerHashDB[value] then
            self.stream:WriteByte(9)
            self.stream:WriteInt(QuestieSerializer.SerializerHashDB[value])
        elseif string.len(value) > 254 then
            self.stream:WriteByte(8)
            self.stream:WriteShortString(value)
        else
            self.stream:WriteByte(7)
            self.stream:WriteTinyString(value)
        end
    end,
    ["table"] = function(self, value, depth)
        local count = 0
        if not depth then depth = 0; end
        if depth > 100 then return; end
        for key, value in pairs(value) do -- bad
            if key and value then count = count + 1; end
        end
        if count > 254 then
            self.stream:WriteByte(10) -- small table
            self.stream:WriteByte(count)
        else
            self.stream:WriteByte(11) -- big table
            self.stream:WriteShort(count)
        end
        for key, value in pairs(value) do
            if key and value then
                QuestieSerializer:WriteKeyValuePair(key, value, depth + 1)
            end
        end
    end,
    ["boolean"] = function(self, value)
        self.stream:WriteByte(12)
        if value then
            self.stream:WriteByte(1)
        else
            self.stream:WriteByte(0)
        end
    end
}

function QuestieSerializer:WriteKeyValuePair(key, value, depth)
    if not value or not key then return; end
    if not depth then
        depth = 0
    end
    if self.objectCount > 8192 then print("[QuestieSerializer] Too many objects in input table!") return end
    self.objectCount = self.objectCount + 1
    if not QuestieSerializer.WriterTable[type(value)] or not QuestieSerializer.WriterTable[type(key)] then
        --print("QuestieSerializer Error: Unhandled type: " .. type(value))
    else
        QuestieSerializer.WriterTable[type(key)](self, key, depth)
        QuestieSerializer.WriterTable[type(value)](self, value, depth)
    end
end

function QuestieSerializer:SetupStream()
    if self.stream then
        self.stream:reset()
    else
        self.stream = QuestieStreamLib:GetStream("1short")
    end
end

function QuestieSerializer:Serialize(tab)
    QuestieSerializer:SetupStream()
    self.objectCount = 0
    --QuestieSerializer:WriteKeyValuePair("meta", {protocolVersion = 1, mode="1short"})
    QuestieSerializer:WriteKeyValuePair(1, tab)
    return self.stream:Save()
end

function QuestieSerializer:Deserialize(data)
    QuestieSerializer:SetupStream()
    self.stream:Load(data)
    --local meta = _ReadTable(self, 1)
    local data = _ReadTable(self, 1)
    return data[1]
end
local _libAS = LibStub("AceSerializer-3.0")
local _libCP = LibStub("LibCompress")
function QuestieSerializer:Test()
    --Questie.db.char.HashTable = QuestieSerializer.SerializerHashDB
    --self.stream = QuestieStreamLib:GetStream("1short")
    local testtable = {}
    local rawQuestList = {}
        -- Maybe this should be its own function in QuestieQuest...
    local numEntries, numQuests = GetNumQuestLogEntries();
    for index = 1, numEntries do
        local _, _, _, isHeader, _, _, _, questId, _, _, _, _, _, _, _, _, _ = GetQuestLogTitle(index)
        if(not isHeader) then
            -- The id is not needed due to it being used as a key, but send it anyway to keep the same structure.
            local quest = {};
            quest.id = questId;
            quest.objectives = QuestieQuest:GetAllLeaderBoardDetails(questId);

            rawQuestList[quest.id] = quest;
        end
    end
    testtable = rawQuestList
    local serQ = QuestieSerializer:Serialize(testtable)
    local serA = _libAS:Serialize({[1]=testtable});
    
    Questie.db.char.WriteTest = serQ
    
    print("QuestieCompress:")
    QuestieSerializer:PrintChunk(serQ)
    print("  len: " .. string.len(serQ));
    print("  lenCompressedHuffman: " .. string.len(_libCP:CompressHuffman(serQ)));
    print("  lenCompressedLZW: " .. string.len(_libCP:CompressLZW(serQ)));
    print("  lenCompressed: " .. string.len(_libCP:Compress(serQ)));
    print(" ")
    
    
    print("AceCompress:")
    QuestieSerializer:PrintChunk(serA)
    print("  len: " .. string.len(serA))
    print("  lenCompressedHuffman: " .. string.len(_libCP:CompressHuffman(serA)));
    print("  lenCompressedLZW: " .. string.len(_libCP:CompressLZW(serA)));
    print("  lenCompressed: " .. string.len(_libCP:Compress(serA)));
    --self.stream = QuestieStreamLib:GetStream("b89")
    --print(self.stream:Save())
end

local _testfloats = nil

function QuestieSerializer:SendTestMessage(player)
    if player then
        local testtable = {["test"] = "testing"}
        testtable.testfloats = {}
        for i=1,10 do
            testtable.testfloats[i] = math.random()
        end
        _testfloats = testtable.testfloats
        C_ChatInfo.SendAddonMessage("questie", QuestieSerializer:Serialize(testtable), "WHISPER", player)
    end
end

function QuestieSerializer:MessageReceivedTest(channel, msg)
    if channel == "questie" then
        print("Message received! ")
        QuestieSerializer:PrintChunk(msg)
        Questie.db.char.WriteRecv = QuestieSerializer:Deserialize(msg)
        local totalDrift = 0
        for i=1,10 do
            print("  " .. tostring(_testfloats[i]) .. " " .. tostring(Questie.db.char.WriteRecv.testfloats[i]))
            totalDrift = totalDrift + math.abs(_testfloats[i] - Questie.db.char.WriteRecv.testfloats[i])
        end
        print("total drift for testfloats: " .. string.format("%.6f", totalDrift))
    end
end

function QuestieSerializer:PrintChunk(data)
    local idx = 0
    while idx + 70 < string.len(data) do
        print(string.sub(data, idx, idx+69))
        idx = idx + 70
    end
    print(string.sub(data, idx))
end