---@class QuestieSerializer
local QuestieSerializer = QuestieLoader:CreateModule("QuestieSerializer");
-------------------------
--Import modules.
-------------------------
---@type QuestieStreamLib
local QuestieStreamLib = QuestieLoader:ImportModule("QuestieStreamLib");


function QuestieSerializer:Hash(value)
    if not value or type(value) ~= "string" or (string.len(value) <= 0) then
        return 0
    end
    local h = 5381
    for i=1, string.len(value) do
        h = bit.band((31 * h + string.byte(value, i)), 4294967295)
    end
    return h
end

QuestieSerializer.SerializerHashDB = {
}
QuestieSerializer.SerializerHashDBReversed = {
}

local function addHash(str)
    local hash = QuestieSerializer:Hash(str)
    if QuestieSerializer.SerializerHashDBReversed[hash] then
        -- dont add, also prevents collissions 
        return
    end
    QuestieSerializer.SerializerHashDB[str] = hash
    QuestieSerializer.SerializerHashDBReversed[hash] = str
end

local function clearHashes()
    QuestieSerializer.SerializerHashDB = {}
    QuestieSerializer.SerializerHashDBReversed = {}
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
    elseif mant == math.huge or expo > 0x80 then
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
            n = sign * math.huge
        else
            n = 0.0/0.0
        end
    else
        n = sign * ldexp(1.0 + mant / 0x800000, expo - 0x7F)
    end
    return n
end

local function _ReadObject(self)
    local typ = self.stream:ReadByte();
    if typ > 31 then -- this isnt actually a type but a number value
        return typ - 32
    end
    return QuestieSerializer.ReaderTable[typ](self);
end

local function _ReadTable(self, entryCount)
    local ret = {}
    for i=1, entryCount do
        local key = _ReadObject(self)
        if type(key) == "string" then
            addHash(key)
        end
        local value = _ReadObject(self)
        if type(value) == "string" then
            addHash(value)
        end
        ret[key] = value
    end
    return ret
end

local function _ReadArray(self, entryCount)
    local ret = {}
    for i=1, entryCount do
        local value = _ReadObject(self)
        if type(value) == "string" then
            addHash(value)
        end
        ret[i] = value
    end
    return ret
end

QuestieSerializer.ReaderTable = {
    [1] = function(self) return nil end,
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

   [16] = function(self) return false end,
   [17] = function(self) return true end,

   [18] = function(self) return nil end,
   [19] = function(self) return nil end,

   [20] = function(self) return _ReadArray(self, self.stream:ReadByte()) end,
   [21] = function(self) return _ReadArray(self, self.stream:ReadShort()) end,
   [22] = function(self) return _ReadArray(self, self.stream:ReadInt()) end,

   --up to 31

}

local function isArray(arr)
    local i = 0
    for e in pairs(arr) do
        i = i + 1
        if i ~= e then
            return false
        end
    end
    return true
end

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
            elseif value < 222 and sign == 0 then
                self.stream:WriteByte(32 + value) -- encoded in type byte
            elseif value < 255 then
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
        if QuestieSerializer.SerializerHashDB[value] and string.len(value) > 4 then
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
        for key, v in pairs(value) do -- bad
            if key and v then count = count + 1; end
        end
        if isArray(value) then
            if count > 65530 then
                self.stream:WriteByte(22) -- chungus array
                self.stream:WriteInt(count)
            elseif count > 254 then
                self.stream:WriteByte(21) -- big array
                self.stream:WriteShort(count)
            else
                self.stream:WriteByte(20) -- small array
                self.stream:WriteByte(count)
            end
            for _, v in pairs(value) do
                local t = type(v)
                if not QuestieSerializer.WriterTable[t] then
                    print("QuestieSerializer Error: Unhandled type: " .. t)
                else
                    QuestieSerializer.WriterTable[t](self, v, depth)
                    if t == "string" then
                        addHash(v)
                    end
                end
            end
        else
            if count > 254 then
                self.stream:WriteByte(11) -- big table
                self.stream:WriteShort(count)
            else
                self.stream:WriteByte(10) -- small table
                self.stream:WriteByte(count)
            end
            for key, v in pairs(value) do
                if key and v then
                    QuestieSerializer:WriteKeyValuePair(key, v, depth + 1)
                end
            end
        end
    end,
    ["boolean"] = function(self, value)
        if value then
            self.stream:WriteByte(17)
        else
            self.stream:WriteByte(16)
        end
    end,
    ["function"] = function(self, value)
        self.stream:WriteByte(1) -- nil
    end
}

function QuestieSerializer:WriteKeyValuePair(key, value, depth)
    if not value or not key then return; end
    if not depth then
        depth = 0
    end
    if self.objectCount > 8192 and false then print("[QuestieSerializer] Too many objects in input table!") return end
    self.objectCount = self.objectCount + 1
    local keyType = type(key)
    local valueType = type(value)
    local writeKey = QuestieSerializer.WriterTable[keyType]
    local writeValue = QuestieSerializer.WriterTable[valueType]
    if not writeKey or not writeValue then
        print("QuestieSerializer Error: Unhandled type: " .. keyType .. "  " .. valueType)
    else
        writeKey(self, key, depth)
        if keyType == "string" then
            addHash(key)
        end
        writeValue(self, value, depth)
        if valueType == "string" then
            addHash(value)
        end
    end
end

function QuestieSerializer:SetupStream(encoding)
    if not encoding then
        encoding = "1short"
    end
    if self.stream and self.streamEncoding == encoding then
        self.stream:reset()
    else
        self.stream = QuestieStreamLib:GetStream(encoding)
        self.streamEncoding = encoding
    end
    clearHashes()
end

function QuestieSerializer:Serialize(tab, encoding)
    QuestieSerializer:SetupStream(encoding)
    self.objectCount = 0
    --QuestieSerializer:WriteKeyValuePair("meta", {protocolVersion = 1, mode="1short"})
    QuestieSerializer:WriteKeyValuePair(1, tab)
    return self.stream:Save()
end

function QuestieSerializer:Deserialize(data, encoding)
    QuestieSerializer:SetupStream(encoding)
    self.stream:Load(data)
    --local meta = _ReadTable(self, 1)
    local retData = _ReadTable(self, 1)
    return retData[1]
end
