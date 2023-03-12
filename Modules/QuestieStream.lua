-- small binary stream library with "base 89" decoder (credit to Aero for the algorithm)
---@class QuestieStreamLib
local QuestieStreamLib = QuestieLoader:CreateModule("QuestieStreamLib");

local tinsert = table.insert

local unpack_limit = 4096 -- wow api limits unpack to somewhere between 7000-8000

-- reduce cpu time by less global space lookups
local band = bit.band
local lshift = bit.lshift
local rshift = bit.rshift
local stringchar = string.char
local stringbyte = string.byte
local stringsub = string.sub

-- shift level table
local QSL_dltab = {};
QSL_dltab[stringbyte("x")] = 0;
QSL_dltab[stringbyte("y")] = 1;
QSL_dltab[stringbyte("z")] = 2;

-- translation table
local QSL_dttab = {};
QSL_dttab[123] = 1;
QSL_dttab[124] = 6;
QSL_dttab[125] = 59;

local QSL_ltab = {};
local QSL_ttab = {};
QSL_ltab[0] = string.byte("x");
QSL_ltab[1] = string.byte("y");
QSL_ltab[2] = string.byte("z");
QSL_ttab[34] = 123;
QSL_ttab[39] = 124;
QSL_ttab[92] = 125;

local StreamPool = {}

local function _StreamReset(self)
    self._pointer = 1
    self._bin = {}
    self._level = 0
end

local function _StreamFinished(self)
    self:reset()
    tinsert(StreamPool, self)
end

function QuestieStreamLib:GetStream(mode) -- returns a new stream
    if not mode then
        Questie:Error("QuestieStreamLib: Stream encoding mode is not defined.")
        error("Stream encoding mode is not defined.")
    end

    local stream = tremove(StreamPool)
    if stream and stream._mode == mode then
        return stream
    else
        stream = {}
    end
    for k,v in pairs(QuestieStreamLib) do -- copy functions to new object
        stream[k] = v
    end
    stream.reset = _StreamReset
    stream.finished = _StreamFinished -- its best to call this (not required) when done using the stream

    stream:reset()
    stream._mode = mode

    if mode == "raw" or mode == "raw_assert" then
        stream.ReadByte = QuestieStreamLib._ReadByte_raw
        stream.ReadShort = QuestieStreamLib._ReadShort_raw
        stream.ReadInt24 = QuestieStreamLib._ReadInt24_raw
        stream.ReadInt = QuestieStreamLib._ReadInt_raw
        stream.ReadInt12Pair = QuestieStreamLib._ReadInt12Pair_raw
        stream.ReadTinyString = QuestieStreamLib._ReadTinyString_raw
        stream.ReadShortString = QuestieStreamLib._ReadShortString_raw
        stream.ReadTinyStringNil = QuestieStreamLib._ReadTinyStringNil_raw

        if mode == "raw" then
            stream.WriteByte = QuestieStreamLib._writeByte
            stream.WriteShort = QuestieStreamLib._WriteShort
            stream.WriteInt = QuestieStreamLib._WriteInt
            stream.WriteInt24 = QuestieStreamLib._WriteInt24
            stream.WriteInt12Pair = QuestieStreamLib._WriteInt12Pair
            stream.WriteLong = QuestieStreamLib._WriteLong
        else
            stream.WriteByte = QuestieStreamLib._writeByte_assert
            stream.WriteShort = QuestieStreamLib._WriteShort_assert
            stream.WriteInt = QuestieStreamLib._WriteInt_assert
            stream.WriteInt24 = QuestieStreamLib._WriteInt24_assert
            stream.WriteInt12Pair = QuestieStreamLib._WriteInt12Pair_assert
            stream.WriteLong = QuestieStreamLib._WriteLong_assert
        end
        stream.WriteTinyString = QuestieStreamLib._WriteTinyString
    else
        if mode == "1short" then
            stream.ReadByte = QuestieStreamLib._ReadByte_1short
            stream.ReadTinyString = QuestieStreamLib._ReadTinyString
            stream.WriteByte = QuestieStreamLib._WriteByte_1short
            stream.WriteTinyString = QuestieStreamLib._WriteTinyString
        else
            stream.ReadByte = QuestieStreamLib._ReadByte_b89
            stream.ReadTinyString = QuestieStreamLib._ReadTinyString_b89
            stream.WriteByte = QuestieStreamLib._WriteByte_b89
            stream.WriteTinyString = QuestieStreamLib._WriteTinyString_b89
        end
        stream.ReadShort = QuestieStreamLib._ReadShort
        stream.ReadInt24 = QuestieStreamLib._ReadInt24
        stream.ReadInt = QuestieStreamLib._ReadInt
        stream.ReadInt12Pair = QuestieStreamLib._ReadInt12Pair
        stream.ReadTinyString = QuestieStreamLib._ReadTinyString
        stream.ReadShortString = QuestieStreamLib._ReadShortString
        stream.ReadTinyStringNil = QuestieStreamLib._ReadTinyStringNil

        stream.WriteShort = QuestieStreamLib._WriteShort
        stream.WriteInt = QuestieStreamLib._WriteInt
        stream.WriteInt24 = QuestieStreamLib._WriteInt24
        stream.WriteInt12Pair = QuestieStreamLib._WriteInt12Pair
        stream.WriteLong = QuestieStreamLib._WriteLong
    end

    return stream
end

function QuestieStreamLib:_writeByte(val)
    --print("Writing " .. val .. " at " .. self._pointer)
    self._bin[self._pointer] = stringchar(val)
    --if val > 255 or val < 0 then
    --    stringchar(val) -- error
    --end
    self._pointer = self._pointer + 1
end

function QuestieStreamLib:_writeByte_assert(val)
    assert(type(val) == "number", "Not a number")
    assert(val >= 0, "Underflow")
    assert(val <= 255, "Overflow") -- 8 bits
    self:_writeByte(val)
end

function QuestieStreamLib:_readByte()
    self._pointer = self._pointer + 1
    return self._bin[self._pointer-1]
end

function QuestieStreamLib:SetPointer(pointer)
    self._pointer = pointer;
end

function QuestieStreamLib:_ReadByte_b89()
    local v = self:_readByte()
    if QSL_dltab[v] then
        self._level = QSL_dltab[v];
        v = self:_readByte()
    end
    if QSL_dttab[v] then
        return self._level * 86 + QSL_dttab[v];
    else
        return self._level * 86 + v - 33;
    end
end

function QuestieStreamLib:_WriteByte_b89(e)
    if not e then return end
    local level = math.floor(e / 86);
    if self._level ~= level then
        self._level = level
        self:_writeByte(QSL_ltab[level])
    end
    local chr = (e % 86) + 33
    if QSL_ttab[chr] then
        self:_writeByte(QSL_ttab[chr])
    else
        self:_writeByte(chr)
    end
end

local _1short_control = 237
local _1short_zero = 238

local _1short_control_table = {
    _1short_control, _1short_zero
}

local _1short_control_table_reversed = {};
for k,v in pairs(_1short_control_table) do _1short_control_table_reversed[v] = k end

function QuestieStreamLib:_WriteByte_1short(e)
    if _1short_control_table_reversed[e] then
        self:_writeByte(_1short_control)
        self:_writeByte(_1short_control_table_reversed[e])
    elseif e == 0 then
        self:_writeByte(_1short_zero)
    else
        self:_writeByte(e)
    end
end

function QuestieStreamLib:_ReadByte_1short()
    local v = self:_readByte()
    if v == _1short_zero then
        return 0
    elseif v == _1short_control then
        v = self:_readByte()
        return _1short_control_table[v]
    end

    return v
end

function QuestieStreamLib:_ReadByte_raw()
    local p = self._pointer
    self._pointer = p + 1
    return stringbyte(self._bin, p)
end

function QuestieStreamLib:ReadBytes(count)
    local ret = {};
    for i=1, count do
        tinsert(ret, self:ReadByte());
    end
    return unpack(ret)
end

function QuestieStreamLib:ReadShorts(count)
    local ret = {};
    for i=1, count do
        tinsert(ret, self:ReadShort());
    end
    return unpack(ret)
end

function QuestieStreamLib:_ReadShort()
    return lshift(self:ReadByte(), 8) + self:ReadByte();
end

function QuestieStreamLib:_ReadShort_raw()
    local p = self._pointer
    self._pointer = p + 2
    local a,b = stringbyte(self._bin, p, p+1)
    return a*256 + b
end

function QuestieStreamLib:_ReadInt12Pair()
    local a = self:ReadByte()
    return self:ReadByte() + lshift(band(a, 15), 8), self:ReadByte() + lshift(band(a, 240), 4)
end

function QuestieStreamLib:_ReadInt12Pair_raw()
    local p = self._pointer
    self._pointer = p + 3
    local a,b,c = stringbyte(self._bin, p, p+2)
    local low4bit = a % 16
    return low4bit * 256 + b, (a - low4bit) * 16 + c
end

function QuestieStreamLib:_ReadInt24()
    return lshift(self:ReadByte(), 16) + lshift(self:ReadByte(), 8) + self:ReadByte();
end

function QuestieStreamLib:_ReadInt24_raw()
    local p = self._pointer
    self._pointer = p + 3
    local a,b,c = stringbyte(self._bin, p, p+2)
    return a*65536 + b*256 + c
end

function QuestieStreamLib:_ReadInt()
    return lshift(self:ReadByte(), 24) + lshift(self:ReadByte(), 16) + lshift(self:ReadByte(), 8) + self:ReadByte();
end

function QuestieStreamLib:_ReadInt_raw()
    local p = self._pointer
    self._pointer = p + 4
    local a,b,c,d = stringbyte(self._bin, p, p+3)
    return a*16777216 + b*65536 + c*256 + d
end

function QuestieStreamLib:ReadLong()
    return lshift(self:ReadByte(), 56) +lshift(self:ReadByte(), 48) +lshift(self:ReadByte(), 40) +lshift(self:ReadByte(), 32) +lshift(self:ReadByte(), 24) + lshift(self:ReadByte(), 16) + lshift(self:ReadByte(), 8) + self:ReadByte();
end

function QuestieStreamLib:_ReadTinyString()
    local length = self:ReadByte()
    local ret = {};
    for i = 1, length do
        tinsert(ret, self:ReadByte()) -- slightly better lua code is slightly better
    end
    return stringchar(unpack(ret))
end

function QuestieStreamLib:_ReadTinyString_b89()
    local length = self:ReadByte()
    local ret = {};
    for i = 1, length do
        tinsert(ret, self:_readByte()) -- slightly better lua code is slightly better
    end
    return stringchar(unpack(ret))
end

function QuestieStreamLib:_ReadTinyString_raw()
    local p = self._pointer
    local length = stringbyte(self._bin, p)
    p = p + 1
    self._pointer = p + length
    return stringsub(self._bin, p, p+length-1)
end

function QuestieStreamLib:_ReadTinyStringNil_raw()
    local p = self._pointer
    local length = stringbyte(self._bin, p)
    p = p + 1
    if length == 0 then
        self._pointer = p
        return nil
    end
    self._pointer = p + length
    return stringsub(self._bin, p, p+length-1)
end

function QuestieStreamLib:_ReadTinyStringNil()
    local length = self:ReadByte()
    if length == 0 then return nil end
    local ret = {};
    for i = 1, length do
        tinsert(ret, self:ReadByte()) -- slightly better lua code is slightly better
    end
    return stringchar(unpack(ret))
end

function QuestieStreamLib:_ReadShortString()
    local length = self:ReadShort()
    local ret = {};
    if length > unpack_limit then
        for i = 1, length do
            tinsert(ret, stringchar(self:ReadByte()))
        end
        return table.concat(ret)
    else
        for i = 1, length do
            tinsert(ret, self:ReadByte()) -- slightly better lua code is slightly better
        end
        return stringchar(unpack(ret))
    end
end

function QuestieStreamLib:_ReadShortString_raw()
    local p = self._pointer
    local a,b = stringbyte(self._bin, p, p+1)
    local length = a*256 + b
    p = p + 2
    self._pointer = p + length
    return stringsub(self._bin, p, p+length-1)
end

function QuestieStreamLib:_WriteShort(val)
    --print("wshort: " .. val);
    self:WriteByte(rshift(val, 8) % 256);
    self:WriteByte(val % 256);
end

function QuestieStreamLib:_WriteShort_assert(val)
    assert(type(val) == "number", "Not a number")
    assert(val >= 0, "Underflow")
    assert(val <= 65535, "Overflow") -- 16 bits
    self:_WriteShort(val)
end

function QuestieStreamLib:_WriteInt(val)
    self:WriteByte(rshift(val, 24) % 256);
    self:WriteByte(rshift(val, 16) % 256);
    self:WriteByte(rshift(val, 8) % 256);
    self:WriteByte(val % 256);
end

function QuestieStreamLib:_WriteInt_assert(val)
    assert(type(val) == "number", "Not a number")
    assert(val >= 0, "Underflow")
    assert(val <= 4294967295, "Overflow") -- 32 bits
    self:_WriteInt(val)
end

function QuestieStreamLib:_WriteInt24(val)
    --print("wi24: " .. val);
    self:WriteByte(rshift(val, 16) % 256);
    self:WriteByte(rshift(val, 8) % 256);
    self:WriteByte(val % 256);
end

function QuestieStreamLib:_WriteInt24_assert(val)
    assert(type(val) == "number", "Not a number")
    assert(val >= 0, "Underflow")
    assert(val <= 16777215, "Overflow") -- 24 bits
    self:_WriteInt24(val)
end

function QuestieStreamLib:_WriteInt12Pair(val1, val2)
    self:WriteByte(band(rshift(val1, 8), 15) + lshift(band(rshift(val2, 8), 15), 4))
    self:WriteByte(val1 % 256)
    self:WriteByte(val2 % 256)
end

function QuestieStreamLib:_WriteInt12Pair_assert(val1, val2)
    assert(type(val1) == "number", "Not a number")
    assert(val1 >= 0, "Underflow")
    assert(val1 <= 4095, "Overflow") -- 12 bits

    assert(type(val2) == "number", "Not a number")
    assert(val2 >= 0, "Underflow")
    assert(val2 <= 4095, "Overflow") -- 12 bits

    self:_WriteInt12Pair(val1, val2)
end

function QuestieStreamLib:_WriteLong(val)
    self:WriteByte(rshift(val, 56) % 256);
    self:WriteByte(rshift(val, 48) % 256);
    self:WriteByte(rshift(val, 40) % 256);
    self:WriteByte(rshift(val, 32) % 256);
    self:WriteByte(rshift(val, 24) % 256);
    self:WriteByte(rshift(val, 16) % 256);
    self:WriteByte(rshift(val, 8) % 256);
    self:WriteByte(val % 256);
end

function QuestieStreamLib:_WriteLong_assert(val)
    assert(type(val) == "number", "Not a number")
    assert(val >= 0, "Underflow")
    assert(val <= 18446744073709551615, "Overflow") -- 64 bits

    self:_WriteLong(val)
end

function QuestieStreamLib:_WriteTinyString(val)
    local length = string.len(val)
    self:WriteByte(length);
    for i=1, length do
        self:WriteByte(stringbyte(val, i));
    end
end

function QuestieStreamLib:_WriteTinyString_b89(val)
    local length = string.len(val)
    self:WriteByte(length);
    for i=1, length do
        self:_writeByte(stringbyte(val, i));
    end
end

function QuestieStreamLib:WriteShortString(val)
    local length = string.len(val)
    self:WriteShort(length);
    for i=1, length do
        self:WriteByte(stringbyte(val, i));
    end
end



function QuestieStreamLib:Save()
    --if self._pointer-1 > unpack_limit then
        --for i=1,self._pointer-1 do
            --print(self._bin[i])
        --    self._bin[i] = stringchar(self._bin[i])
        --end
        --return table.concat(self._bin)
    --end
    --return stringchar(unpack(self._bin))
    return table.concat(self._bin)
end

function QuestieStreamLib:Load(bin)
    self._pointer = 1
    if self._mode == "raw" or self._mode == "raw_assert" then
        self._bin = bin
    else
        self._bin = {stringbyte(bin, 1, -1)}
    end
    self._level = 0
end
