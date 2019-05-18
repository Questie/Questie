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


function QuestieStreamLib:setPointer(pointer)
    self._pointer = pointer;
end

function QuestieStreamLib:readByte()
    local r = self._buffer[self._pointer];
    self._pointer = self._pointer + 1;
    return r;
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
    for i=1,length do
        ret = ret .. string.char(self:readByte())  -- bad lua code is bad
    end
    return ret;
end

function QuestieStreamLib:readShortString()
    local length = self:readShort();
    local ret = "";
    for i=1,length do
        ret = ret .. string.char(self:readByte())  -- bad lua code is bad
    end
    return ret;
end

function QuestieStreamLib:writeByte(val)
    --print("wbyte: " .. val);
    self._buffer[self._pointer] = mod(val, 256);
    --print("wbyte: " .. _buffer[_pointer]);
    self._pointer = self._pointer + 1;
end

function QuestieStreamLib:load(bin)
    self._pointer = 0;
    self._size = 0;
    local level = 0;
    for i=1,string.len(bin) do
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
