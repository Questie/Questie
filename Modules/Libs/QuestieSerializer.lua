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
local function addHash(str)
    QuestieSerializer.SerializerHashDB[str] = QuestieSerializer:Hash(str)
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
                self.stream:WriteByte(4 + sign) -- long
                self.stream:WriteLong(value)
            else
                self.stream:WriteByte(2 + sign) -- number
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
            self.stream:WriteRawShortString(value)
        else
            self.stream:WriteByte(7)
            self.stream:WriteRawTinyString(value)
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
                QuestieSerializer:WriteKeyValuePair(tostring(key), value, depth + 1)
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
    if not QuestieSerializer.WriterTable[type(value)] then
        --print("QuestieSerializer Error: Unhandled type: " .. type(value))
    else
        if type(key) == "number" then
            local _, fract = math.modf(key)
            if fract > 0 then
                self.stream:WriteByte(4)
                self.stream:WriteInt(floatBitsToInt(key))
            elseif key > 2147483646 then
                self.stream:WriteByte(3)
                self.stream:WriteLong(key)
            else
                self.stream:WriteByte(2)
                self.stream:WriteInt(key)
            end
        else
            if QuestieSerializer.SerializerHashDB[key] and string.len(key) > 4 then -- known key
                self.stream:WriteByte(7)
                self.stream:WriteInt(QuestieSerializer.SerializerHashDB[key])
            else
                if string.len(key) > 4 then
                    --addHash(key)
                    --print("Warning: Unregistered key: " .. key)
                end
                if string.len(key) > 254 then
                    self.stream:WriteByte(6)
                    self.stream:WriteRawShortString(key)
                else
                    self.stream:WriteByte(5)
                    self.stream:WriteRawTinyString(key)
                end
            end
        end
        QuestieSerializer.WriterTable[type(value)](self, value, depth)
    end
end

function QuestieSerializer:Serialize(tab)
    if self.stream then
        self.stream._pointer = 0
        self.stream._size = 0
    else
        self.stream = QuestieStreamLib:GetStream()
    end
    self.objectCount = 0
    QuestieSerializer:WriteKeyValuePair("meta", {protocolVersion = 1, mode="base90", compression="RLE"})
    QuestieSerializer:WriteKeyValuePair("data", tab)
    return self.stream:Save()
end

function QuestieSerializer:Test()
    Questie.db.char.WriteTest = QuestieSerializer:Serialize(Questie.db)
    --Questie.db.char.HashTable = QuestieSerializer.SerializerHashDB
    print("Done!")
    --print(self.stream:Save())
end

function QuestieSerializer:Deserialize(encoded)


end