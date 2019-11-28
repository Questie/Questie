-- this is a small utility built on top of QuestieSerializer to provide "compressed" read-only tables.
-- table data is serialized to a string without indexes, and using a pointer map its possible to
-- dezerialize an entry from the table without deserializing the whole table
-- this is useful for large databases like the quest and NPC spawn databases.

---@class CompressedTable
local QuestieCompressedTable = QuestieLoader:CreateModule("CompressedTable")
local QuestieSerializer = QuestieLoader:ImportModule("QuestieSerializer"):Clone("raw")

function QuestieCompressedTable:Load(data, pointers)
    -- to allow for random access we need to set this manually
    local ret = {}
    ret.Get = self.Get
    local serial = QuestieSerializer:Clone("raw")
    serial.stream._bin = data
    serial.stream._pointer = 1
    ret.serial = serial
    if type(pointers) == "string" then
        print("Loading pointermap...")
        QuestieSerializer:SetupStream()
        ret.pointers = QuestieSerializer:Deserialize(pointers)
        local cnt = 0
        for k,v in pairs(ret.pointers) do
            cnt = cnt + 1
        end
        print("Loaded pointermap: " .. tostring(cnt))
        print("84: " .. tostring(ret.pointers[84]))
    else
        ret.pointers = pointers
    end

    return ret
end

function QuestieCompressedTable:Get(index)
    if (not self.pointers) or not self.pointers[index] then
        print("No pointer for " .. tostring(index))
        return nil
    end
    self.serial.stream._pointer = self.pointers[index]
    print("Getting " .. tostring(index) .. " at " .. tostring(self.serial.stream._pointer))
    if self.customIO then
        return self.customIO.read(self.serial.stream)
    else
        return self.serial:ReadObject()
    end
end

-- this is used to specify a custom object reader/writer instead QuestieSerializer
function QuestieCompressedTable:SetCustomIO(io)
    self.customIO = io
end

-- usage of is to set a savedvariable to what this returns, and copying the .lua the game generates in to the project
-- returns data, pointers
function QuestieCompressedTable:Compile(toCompile)
    self.serial.objectCount = 0
    self.serial:SetupStream()
    local pointerMap = {}

    for key, value in pairs(toCompile) do
        pointerMap[key] = self.serial.stream._pointer
        if self.customIO then
            self.customIO.write(self.serial, value)
        else
            self.serial.WriterTable[type(value)](self.serial, value)
        end
    end

    local data = self.serial.stream:Save()
    self.serial:SetupStream()
    return data, self.serial:Serialize(pointerMap)
end
