-- small binary stream library with "base 89" decoder (credit to Aero for the algorithm)

QuestieStreamLib = {}

QuestieStreamLib._buffer = {};
QuestieStreamLib._pointer = 0;
QuestieStreamLib._size = 0;

-- shift level table
QSL_dltab = {};
QSL_dltab[string.byte("x")] = 0;
QSL_dltab[string.byte("y")] = 1;
QSL_dltab[string.byte("z")] = 2;

-- translation table
QSL_dttab = {};
QSL_dttab[123] = 1;
QSL_dttab[124] = 6;
QSL_dttab[125] = 59;

QSL_ltab = {};
QSL_ttab = {};
QSL_ltab[0] = "x";
QSL_ltab[1] = "y";
QSL_ltab[2] = "z";
QSL_ttab[34] = 123;
QSL_ttab[39] = 124;
QSL_ttab[92] = 125;

local StreamPool = {}

function QuestieStreamLib:getStream() -- returns a new stream
    local stream = tremove(StreamPool)
    if stream then 
        return stream
    else
        stream = {}
    end
    for k,v in pairs(QuestieStreamLib) do -- copy functions to new object
        stream[k] = v
    end
    stream._size = 0
    stream._pointer = 0
    stream._buffer = {}
    stream.finished = function(self) -- its best to call this (not required) when done using the stream
        self._pointer = 0
        self._size = 0
        table.insert(StreamPool, self)
    end
    return stream
end


function QuestieStreamLib:setPointer(pointer)
    self._pointer = pointer;
end

function QuestieStreamLib:readByte()
    local r = self._buffer[self._pointer];
    self._pointer = self._pointer + 1;
    return r;
end

function QuestieStreamLib:readBytes(count)
    local ret = {};
    for i=1,count do
        table.insert(ret, self:readByte());
    end
    return unpack(ret)
end

function QuestieStreamLib:readShorts(count)
    local ret = {};
    for i=1,count do
        table.insert(ret, self:readShort());
    end
    return unpack(ret)
end

function QuestieStreamLib:readShort()
    return bit.lshift(self:readByte(), 8) + self:readByte();
end

function QuestieStreamLib:readInt()
    return bit.lshift(self:readByte(), 24) + bit.lshift(self:readByte(), 16) + bit.lshift(self:readByte(), 8) + self:readByte();
end

function QuestieStreamLib:readTinyString()
    local length = self:readByte();
    local ret = "";
    for i = 1, length do
        ret = ret .. string.char(self:readByte()) -- bad lua code is bad
    end
    return ret;
end

function QuestieStreamLib:readShortString()
    local length = self:readShort();
    local ret = "";
    for i = 1, length do
        ret = ret .. string.char(self:readByte()) -- bad lua code is bad
    end
    return ret;
end

function QuestieStreamLib:writeByte(val)
    --print("wbyte: " .. val);
    self._buffer[self._pointer] = mod(val, 256);
    --print("wbyte: " .. _buffer[_pointer]);
    self._pointer = self._pointer + 1;
end

function QuestieStreamLib:writeBytes(...)
    for _,val in pairs({...}) do
        self:writeByte(val)
    end
end

function QuestieStreamLib:writeShorts(...)
    for _,val in pairs({...}) do
        self:writeShort(val)
    end
end

function QuestieStreamLib:writeShort(val)
    --print("wshort: " .. val);
    self:writeByte(mod(bit.rshift(val, 8), 256));
    self:writeByte(mod(val, 256));
end

function QuestieStreamLib:writeInt(val)
    self:writeByte(mod(bit.rshift(val, 24), 256));
    self:writeByte(mod(bit.rshift(val, 16), 256));
    self:writeByte(mod(bit.rshift(val, 8), 256));
    self:writeByte(mod(val, 256));
end

function QuestieStreamLib:writeTinyString(val)
    self:writeByte(string.len(val));
    for i=1,string.len(val) do
        self:writeByte(string.byte(val, i));
    end
end

function QuestieStreamLib:writeShortString(val)
    self:writeShort(string.len(val));
    for i=1,string.len(val) do
        self:writeByte(string.byte(val, i));
    end
end

function QuestieStreamLib:save()
    local lmt = 0;
    local result = ""
    if self._size < self._pointer then
        self._size = self._pointer
    end
    for i=0,self._size do
        local e = self._buffer[i]
        if e == nil then
            return result
        end
        local level = math.floor(e / 86);
        if not (lmt == level) then
            lmt = level
            result = result .. QSL_ltab[level]
        end
        local chr = mod(e, 86) + 33
        if QSL_ttab[chr] then
            result = result .. string.char(QSL_ttab[chr])
        else
            result = result .. string.char(chr)
        end
        
    end
    return result
end

function QuestieStreamLib:savePart(limit)
    local lmt = 0;
    local result = ""
    if self._size < self._pointer then
        self._size = self._pointer
    end
	if limit > self._size then
		limit = self._size
	end
    for i=1,limit do
        local e = self:readByte()
		if not e then return result; end
        local level = math.floor(e / 86);
        if not (lmt == level) then
            lmt = level
            result = result .. QSL_ltab[level]
        end
        local chr = mod(e, 86) + 33
        if QSL_ttab[chr] then
            result = result .. string.char(QSL_ttab[chr])
        else
            result = result .. string.char(chr)
        end
        
    end
    return result
end

function QuestieStreamLib:loadPart(bin)
    local level = 0;
    for i = 1, string.len(bin) do
        local v = string.byte(bin, i);
        --print(v);
        if QSL_dltab[v] == nil then
            if QSL_dttab[v] then
                self:writeByte(level * 86 + QSL_dttab[v]);
            else
                self:writeByte(level * 86 + v - 33);
            end
        else
            level = QSL_dltab[v];
        end
    end
    self._size = self._pointer;
end

function QuestieStreamLib:load(bin)
    self._pointer = 0;
    self._size = 0;
    local level = 0;
    for i = 1, string.len(bin) do
        local v = string.byte(bin, i);
        --print(v);
        if QSL_dltab[v] == nil then
            if QSL_dttab[v] then
                self:writeByte(level * 86 + QSL_dttab[v]);
            else
                self:writeByte(level * 86 + v - 33);
            end
        else
            level = QSL_dltab[v];
        end
    end
    self._size = self._pointer;
    self._pointer = 0;
end
