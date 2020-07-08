---@class DBCompiler
local QuestieDBCompiler = QuestieLoader:CreateModule("DBCompiler")
---@type CompressedTable
local QuestieCompressedTable = QuestieLoader:ImportModule("CompressedTable")
---@type QuestieStreamLib
local QuestieStream = QuestieLoader:ImportModule("QuestieStreamLib"):GetStream("raw")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestieSerializer
local serial = QuestieLoader:ImportModule("QuestieSerializer")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")

serial.enableObjectLimit = false

QuestieDBCompiler.readers = {
    ["u8"] = QuestieStream.ReadByte,
    ["u16"] = QuestieStream.ReadShort,
    ["s16"] = function(stream)
        return stream:ReadShort() - 32767
    end,
    ["u24"] = QuestieStream.ReadInt24,
    ["u32"] = QuestieStream.ReadInt,
    ["u12pair"] = function(stream)
        local ret = {stream:ReadInt12Pair()}
        -- bit of a hack
        if ret[1] == 0 and ret[2] == 0 then
            return nil
        end
        return ret
    end,
    ["u24pair"] = function(stream)
        local ret = {stream:ReadInt24(), stream:ReadInt24()}
        -- bit of a hack
        if ret[1] == 0 and ret[2] == 0 then
            return nil
        end

        return ret
    end,
    ["s24pair"] = function(stream)
        local ret = {stream:ReadInt24()-8388608, stream:ReadInt24()-8388608}
        -- bit of a hack
        if ret[1] == 0 and ret[2] == 0 then
            return nil
        end

        return ret
    end,
    ["u8string"] = function(stream)
        local ret = stream:ReadTinyString()
        if ret == "nil" then-- I hate this but we need to support both nil strings and empty strings
            return nil
        else
            return ret
        end
    end,
    ["u16string"] = function(stream)
        local ret = stream:ReadShortString()
        if ret == "nil" then-- I hate this but we need to support both nil strings and empty strings
            return nil
        else
            return ret
        end
    end,
    ["u8u16array"] = function(stream)
        local count = stream:ReadByte()

        if count == 0 then return nil end

        local list = {}

        for i = 1, count do
            tinsert(list, stream:ReadShort())
        end
        return list
    end,
    ["u16u16array"] = function(stream)
        local list = {}
        local count = stream:ReadShort()
        for i = 1, count do
            tinsert(list, stream:ReadShort())
        end
        return list
    end,
    ["u8u24array"] = function(stream)
        local count = stream:ReadByte()

        if count == 0 then return nil end

        local list = {}
        for i = 1, count do
            tinsert(list, stream:ReadInt24())
        end
        return list
    end,
    ["u8u16stringarray"] = function(stream)
        local list = {}
        local count = stream:ReadByte()
        for i = 1, count do
            tinsert(list, stream:ReadShortString())
        end
        return list
    end,
    ["faction"] = function(stream)
        local val = stream:ReadByte()
        if val == 3 then
            return nil
        elseif val == 2 then
            return "AH"
        elseif val == 1 then
            return "H"
        else
            return "A"
        end
    end,
    ["spawnlist"] = function(stream)
        local count = stream:ReadByte()
        local spawnlist = {}
        for i = 1, count do
            local zone = stream:ReadShort()
            local spawnCount = stream:ReadShort()
            local list = {}
            for e = 1, spawnCount do
                local x, y = stream:ReadInt12Pair()
                if x == 0 and y == 0 then
                    tinsert(list, {-1, -1})
                else
                    tinsert(list, {x / 40.90, y / 40.90}) 
                end
            end
            spawnlist[zone] = list
        end
        return spawnlist
    end,
    ["trigger"] = function(stream)
        if stream:ReadShort() == 0 then
            return nil
        else
            stream._pointer = stream._pointer - 2
        end
        local ret = {}
        tinsert(ret, stream:ReadTinyStringNil())
        tinsert(ret, QuestieDBCompiler.readers["spawnlist"](stream))
        return ret
    end,
    ["questgivers"] = function(stream)
        --local count = stream:ReadByte()
        --if count == 0 then return nil end
        local ret = {}
        ret[1] = QuestieDBCompiler.readers["u8u24array"](stream)
        ret[2] = QuestieDBCompiler.readers["u8u24array"](stream)
        ret[3] = QuestieDBCompiler.readers["u8u24array"](stream)

        --for i = 1, count do
        --    tinsert(ret, QuestieDBCompiler.readers["u8u16array"](stream))
        --end

        return ret
    end,
    ["objective"] = function(stream)
        local count = stream:ReadByte()
        if count == 0 then
            return nil
        end

        local ret = {}

        for i = 1, count do
            tinsert(ret, {stream:ReadInt24(), stream:ReadTinyStringNil()})
        end
        return ret
    end,
    ["objectives"] = function(stream)
        local ret = {}

        ret[1] = QuestieDBCompiler.readers["objective"](stream)
        ret[2] = QuestieDBCompiler.readers["objective"](stream)
        ret[3] = QuestieDBCompiler.readers["objective"](stream)
        ret[4] = QuestieDBCompiler.readers["u24pair"](stream)

        return ret
    end,
}

QuestieDBCompiler.writers = {
    ["u8"] = function(stream, value)
        stream:WriteByte(value or 0)
    end,
    ["u16"] = function(stream, value)
        stream:WriteShort(value or 0)
    end,
    ["s16"] = function(stream, value)
        stream:WriteShort(32767 + (value or 0))
    end,
    ["u24"] = function(stream, value)
        stream:WriteInt24(value or 0)
    end,
    ["u32"] = function(stream, value)
        stream:WriteInt(value or 0)
    end,
    ["u12pair"] = function(stream, value)
        if value then
            stream:WriteInt12Pair(value[1] or 0, value[2] or 0)
        else
            stream:WriteInt24(0)
        end
    end,
    ["u24pair"] = function(stream, value)
        if value then
            stream:WriteInt24(value[1] or 0)
            stream:WriteInt24(value[2] or 0)
        else
            stream:WriteInt24(0)
            stream:WriteInt24(0)
        end
    end,
    ["s24pair"] = function(stream, value)
        if value then
            stream:WriteInt24((value[1] or 0) + 8388608)
            stream:WriteInt24((value[2] or 0) + 8388608)
        else
            stream:WriteInt24(8388608)
            stream:WriteInt24(8388608)
        end
    end,
    ["u8string"] = function(stream, value)

        stream:WriteTinyString(value or "nil") -- I hate this but we need to support both nil strings and empty strings

        --if value then
        --    stream:WriteTinyString(value)
        --else
        --    stream:WriteByte(0)
        --end 
    end,
    ["u16string"] = function(stream, value)
        --if value then
        --    stream:WriteShortString(value)
        --else
        --    stream:WriteShort(0)
        --end
        stream:WriteShortString(value or "nil")
    end,
    ["u8u16array"] = function(stream, value)
        if value then
            local count = 0 for _ in pairs(value) do count = count + 1 end
            stream:WriteByte(count)
            for _,v in pairs(value) do
                stream:WriteShort(v)
            end
        else
            stream:WriteByte(0)
        end
    end,
    ["u16u16array"] = function(stream, value)
        if value then
            local count = 0 for _ in pairs(value) do count = count + 1 end
            stream:WriteShort(count)
            for _,v in pairs(value) do
                stream:WriteShort(v)
            end
        else
            stream:WriteByte(0)
        end
    end,
    ["u8u24array"] = function(stream, value)
        if value then
            local count = 0 for _ in pairs(value) do count = count + 1 end
            stream:WriteByte(count)
            for _,v in pairs(value) do
                stream:WriteInt24(v)
            end
        else
            stream:WriteByte(0)
        end
    end,
    ["u8u16stringarray"] = function(stream, value)
        if value then
            local count = 0 for _ in pairs(value) do count = count + 1 end
            stream:WriteByte(count)
            for _,v in pairs(value) do
                stream:WriteShortString(v or "nil")
            end
        else
            --print("Missing u8u16stringarray for " .. QuestieDBCompiler.currentEntry)
            stream:WriteByte(0)
        end
    end,
    ["faction"] = function(stream, value)
        if value == nil then
            stream:WriteByte(3)
        elseif "A" == value then
            stream:WriteByte(0)
        elseif "H" == value then
            stream:WriteByte(1)
        else
            stream:WriteByte(2)
        end
    end,
    ["spawnlist"] = function(stream, value)
        if value then
            local count = 0 for _ in pairs(value) do count = count + 1 end
            stream:WriteByte(count)
            for zone, spawnlist in pairs(value) do
                count = 0 for _ in pairs(spawnlist) do count = count + 1 end
                stream:WriteShort(zone)
                stream:WriteShort(count)
                for _, spawn in pairs(spawnlist) do
                    if spawn[1] == -1 and spawn[2] == -1 then -- instance spawn
                        stream:WriteInt24(0) -- 0 instead
                    else
                        stream:WriteInt12Pair(math.floor(spawn[1] * 40.90), math.floor(spawn[2] * 40.90))
                    end
                end
            end
        else
            --print("Missing spawnlist for " .. QuestieDBCompiler.currentEntry)
            stream:WriteByte(0)
        end
    end,
    ["trigger"] = function(stream, value)
        if value then
            stream:WriteTinyString(value[1])
            QuestieDBCompiler.writers["spawnlist"](stream, value[2])
        else
            stream:WriteByte(0)
            stream:WriteByte(0)
        end
    end,
    ["questgivers"] = function(stream, value)
        if value then
            QuestieDBCompiler.writers["u8u24array"](stream, value[1])
            QuestieDBCompiler.writers["u8u24array"](stream, value[2])
            QuestieDBCompiler.writers["u8u24array"](stream, value[3])
        else
            print("Missing questgivers for " .. QuestieDBCompiler.currentEntry)
            stream:WriteByte(0)
            stream:WriteByte(0)
            stream:WriteByte(0)
        end
    end,
    ["objective"] = function(stream, value)
        if value then
            local count = 0 for _ in pairs(value) do count = count + 1 end
            stream:WriteByte(count)
            for _, pair in pairs(value) do
                stream:WriteInt24(pair[1])
                stream:WriteTinyString(pair[2] or "")
            end
        else
            stream:WriteByte(0)
        end
    end,
    ["objectives"] = function(stream, value)
        if value then
            QuestieDBCompiler.writers["objective"](stream, value[1])
            QuestieDBCompiler.writers["objective"](stream, value[2])
            QuestieDBCompiler.writers["objective"](stream, value[3])
            QuestieDBCompiler.writers["u24pair"](stream, value[4])
        else
            --print("Missing objective table for " .. QuestieDBCompiler.currentEntry)
            stream:WriteByte(0)
            stream:WriteByte(0)
            stream:WriteByte(0)
            stream:WriteInt24(0)
            stream:WriteInt24(0)
        end
    end
}

QuestieDBCompiler.skippers = {
    ["u8"] = function(stream) stream._pointer = stream._pointer + 1 end,
    ["u16"] = function(stream) stream._pointer = stream._pointer + 2 end,
    ["s16"] = function(stream) stream._pointer = stream._pointer + 2 end,
    ["u24"] = function(stream) stream._pointer = stream._pointer + 3 end,
    ["u32"] = function(stream) stream._pointer = stream._pointer + 4 end,
    ["u12pair"] = function(stream) stream._pointer = stream._pointer + 3 end,
    ["u24pair"] = function(stream) stream._pointer = stream._pointer + 6 end,
    ["s24pair"] = function(stream) stream._pointer = stream._pointer + 6 end,
    ["u8string"] = function(stream) stream._pointer = stream:ReadByte() + stream._pointer end,
    ["u16string"] = function(stream) stream._pointer = stream:ReadShort() + stream._pointer end,
    ["u8u16array"] = function(stream) stream._pointer = stream:ReadByte() * 2 + stream._pointer end,
    ["u16u16array"] = function(stream) stream._pointer = stream:ReadShort() * 2 + stream._pointer end,
    ["u8u24array"] = function(stream) stream._pointer = stream:ReadByte() * 3 + stream._pointer end,
    ["u8u16stringarray"] = function(stream) 
        local count = stream:ReadByte()
        for i=1,count do
            stream._pointer = stream:ReadShort() + stream._pointer
        end
    end,
    ["faction"] = function(stream) stream._pointer = stream._pointer + 1 end,
    ["spawnlist"] = function(stream)
        local count = stream:ReadByte()
        for i = 1, count do
            stream._pointer = stream._pointer + 2
            stream._pointer = stream:ReadShort() * 3 + stream._pointer
        end
    end,
    ["trigger"] = function(stream) 
        stream._pointer = stream:ReadByte() + stream._pointer
        QuestieDBCompiler.skippers["spawnlist"](stream)
    end,
    ["questgivers"] = function(stream)
        --local count = stream:ReadByte()
        --for i = 1, count do
        --    QuestieDBCompiler.skippers["u8u16array"](stream)
        --end
        QuestieDBCompiler.skippers["u8u24array"](stream)
        QuestieDBCompiler.skippers["u8u24array"](stream)
        QuestieDBCompiler.skippers["u8u24array"](stream)
    end,
    ["objective"] = function(stream)
        local count = stream:ReadByte()
        for i=1,count do
            stream._pointer = stream._pointer + 3
            stream._pointer = stream:ReadByte() + stream._pointer
        end
    end,
    ["objectives"] = function(stream)
        QuestieDBCompiler.skippers["objective"](stream)
        QuestieDBCompiler.skippers["objective"](stream)
        QuestieDBCompiler.skippers["objective"](stream)
        QuestieDBCompiler.skippers["u24pair"](stream)
    end
}

QuestieDBCompiler.dynamics = {
    ["u8string"] = true,
    ["u16string"] = true,
    ["u8u16array"] = true,
    ["u16u16array"] = true,
    ["u8u24array"] = true,
    ["u8u16stringarray"] = true,
    ["spawnlist"] = true,
    ["trigger"] = true, 
    ["objective"] = true,
    ["objectives"] = true,
    ["questgivers"] = true
}

QuestieDBCompiler.statics = {
    ["u8"] = 1,
    ["u16"] = 2,
    ["s16"] = 2,
    ["u24"] = 3,
    ["u32"] = 4,
    ["faction"] = 1,
    ["u12pair"] = 3,
    ["u24pair"] = 6,
    ["s24pair"] = 6,
}

function QuestieDBCompiler:CompileNPCs(func)
    QuestieDBCompiler:CompileTableTicking(QuestieDB.npcData, QuestieDB.npcCompilerTypes, QuestieDB.npcCompilerOrder, QuestieDB.npcKeys, func)
end

function QuestieDBCompiler:CompileObjects(func)
    QuestieDBCompiler:CompileTableTicking(QuestieDB.objectData, QuestieDB.objectCompilerTypes, QuestieDB.objectCompilerOrder, QuestieDB.objectKeys, func)
end

function QuestieDBCompiler:CompileQuests(func)
    QuestieDBCompiler:CompileTableTicking(QuestieDB.questData, QuestieDB.questCompilerTypes, QuestieDB.questCompilerOrder, QuestieDB.questKeys, func)
end

function QuestieDBCompiler:CompileItems(func)
    QuestieDBCompiler:CompileTableTicking(QuestieDB.itemData, QuestieDB.itemCompilerTypes, QuestieDB.itemCompilerOrder, QuestieDB.itemKeys, func)
end

local function equals(a, b)
    if a == nil and b == nil then return true end
    if a == nil or b == nil then return false end
    local ta = type(a)
    local tb = type(b)
    if ta ~= tb then return false end

    if ta == "number" then
        return math.abs(a-b) < 0.2
    elseif ta == "table" then
        for k,v in pairs(a) do
            if not equals(b[k], v) then
                return false
            end
        end
        for k,v in pairs(b) do
            if not equals(b[k], v) then
                return false
            end
        end
        return true
    else
        return a == b
    end

end

function QuestieDBCompiler:EncodePointerMap(stream, pointerMap)
    stream:reset()
    stream:WriteShort(0) -- placeholder
    local count = 0
    for id, ptrs in pairs(pointerMap) do
        stream:WriteInt24(id)
        stream:WriteInt24(ptrs)
        count = count + 1
    end
    stream._pointer = 1
    stream:WriteShort(count)
    return stream:Save()
end

function QuestieDBCompiler:DecodePointerMap(stream)
    local count = stream:ReadShort()
    local ret = {}
    for i = 1, count do 
        ret[stream:ReadInt24()] = stream:ReadInt24()
    end
    return ret
end

function QuestieDBCompiler:CompileTable(tbl, types, order, lookup)
    local pointerMap = {}
    local stream = QuestieStream:GetStream("raw")
    for id, entry in pairs(tbl) do
        pointerMap[id] = stream._pointer
        for _, key in pairs(order) do
            QuestieDBCompiler.writers[types[key]](stream, entry[lookup[key]])
        end
    end
    return stream:Save(), QuestieDBCompiler:EncodePointerMap(stream, pointerMap)
end

function QuestieDBCompiler:CompileTableTicking(tbl, types, order, lookup, after)
    local count = 0
    local indexLookup = {};
    for id in pairs(tbl) do
        count = count + 1
        indexLookup[count] = id
    end
    count = count + 1
    QuestieDBCompiler.index = 0

    QuestieDBCompiler.pointerMap = {}
    QuestieDBCompiler.stream = QuestieStream:GetStream("raw")

    QuestieDBCompiler.ticker = C_Timer.NewTicker(0.01, function()
        for i=0,48 do
            QuestieDBCompiler.index = QuestieDBCompiler.index + 1
            if QuestieDBCompiler.index == count then
                QuestieDBCompiler.ticker:Cancel()
                --print("Finalizing: " .. QuestieDBCompiler.index)
                after(QuestieDBCompiler.stream:Save(), QuestieDBCompiler:EncodePointerMap(QuestieDBCompiler.stream, QuestieDBCompiler.pointerMap))
                break
            end
            local id = indexLookup[QuestieDBCompiler.index]
            QuestieDBCompiler.currentEntry = id
            local entry = tbl[id]
            --local pointerStart = QuestieDBCompiler.stream._pointer
            QuestieDBCompiler.pointerMap[id] = QuestieDBCompiler.stream._pointer--pointerStart
            for _, key in pairs(order) do
                QuestieDBCompiler.writers[types[key]](QuestieDBCompiler.stream, entry[lookup[key]])
            end
        end
    end)
end

function QuestieDBCompiler:BuildSkipMap(types, order) -- skip map is used for random access, to read specific fields in an entry without reading the whole entry
    local skipmap = {}
    local indexToKey = {}
    local keyToIndex = {}
    local ptr = 0
    local haveDynamic = false
    local endIndex = nil
    local lastIndex = nil
    for index, key in pairs(order) do
        local typ = types[key]
        indexToKey[index] = key
        keyToIndex[key] = index
        if not haveDynamic then
            skipmap[key] = ptr
        end
        if QuestieDBCompiler.dynamics[typ] then
            if not haveDynamic then
                lastIndex = index
            end
            haveDynamic = true
        else
            --print("static: " .. typ)
            ptr = ptr + QuestieDBCompiler.statics[typ]
        end
    end
    skipmap = {skipmap, lastIndex, ptr, types, order, indexToKey, keyToIndex}
    return skipmap
end

function QuestieDBCompiler:Compile(finalize)
    --print("Compiling NPCs...")

    local function DynamicHashTableSize(entries)
        if (entries == 0) then
          return 36;
        else
          return math.pow(2, math.ceil(math.log(entries) / math.log(2))) * 40 + 36;
        end
    end
    QuestieDBCompiler.startTime = GetTime()
    QuestieDBCompiler.totalSize = 0
    print(QuestieLocale:GetUIString("\124cFFAAEEFFQuestie DB has updated!\124r\124cFFFF6F22 Data is being processed, this may take a few moments and cause some lag..."))
    print(QuestieLocale:GetUIString("\124cFF4DDBFF [1/4] Updating NPCs..."))
    QuestieDBCompiler:CompileNPCs(function(bin, ptrs)
        QuestieConfig.npcBin = bin 
        QuestieConfig.npcPtrs = ptrs
        QuestieDBCompiler.totalSize = QuestieDBCompiler.totalSize + string.len(bin) + DynamicHashTableSize(QuestieDBCompiler.index)
        --print("NPCs size: bin:" .. math.floor(string.len(bin)/1024) .. "K ptr:" .. math.floor(DynamicHashTableSize(QuestieDBCompiler.index)/1024) .. "K")
        --print("\124cFF4DDBFF [1/4] Finished updating NPCs")
        print(QuestieLocale:GetUIString("\124cFF4DDBFF [2/4] Updating objects..."))
        --print("Compiling Objects...")
        QuestieDBCompiler:CompileObjects(function(bin, ptrs)
            QuestieConfig.objBin = bin 
            QuestieConfig.objPtrs = ptrs
            QuestieDBCompiler.totalSize = QuestieDBCompiler.totalSize + string.len(bin) + DynamicHashTableSize(QuestieDBCompiler.index)
            --print("Objects size: bin:" .. math.floor(string.len(bin)/1024) .. "K ptr:" .. math.floor(DynamicHashTableSize(QuestieDBCompiler.index)/1024) .. "K")
            --print("\124cFF4DDBFF [2/4] Finished updating objects")
            print(QuestieLocale:GetUIString("\124cFF4DDBFF [3/4] Updating quests..."))
            --print("Compiling Quests...")
            QuestieDBCompiler:CompileQuests(function(bin, ptrs)
                QuestieConfig.questBin = bin 
                QuestieConfig.questPtrs = ptrs
                QuestieDBCompiler.totalSize = QuestieDBCompiler.totalSize + string.len(bin) + DynamicHashTableSize(QuestieDBCompiler.index)
                --print("Quests size: bin:" .. math.floor(string.len(bin)/1024) .. "K ptr:" .. math.floor(DynamicHashTableSize(QuestieDBCompiler.index)/1024) .. "K")
                --print("\124cFF4DDBFF [3/4] Finished updating quests")
                print(QuestieLocale:GetUIString("\124cFF4DDBFF [4/4] Updating items..."))
                --print("Compiling items...")
                QuestieDBCompiler:CompileItems(function(bin, ptrs)
                    QuestieConfig.itemBin = bin 
                    QuestieConfig.itemPtrs = ptrs
                    QuestieConfig.dbCompiledOnVersion = QuestieLib:GetAddonVersionString()
                    QuestieConfig.dbCompiledLang = (Questie.db.global.questieLocaleDiff and Questie.db.global.questieLocale or GetLocale())
                    QuestieConfig.dbIsCompiled = true
                    --print("\124cFF4DDBFF [4/4] Finished updating items")
                    --print("Items size: bin:" .. math.floor(string.len(bin)/1024) .. "K ptr:" .. math.floor(DynamicHashTableSize(QuestieDBCompiler.index)/1024) .. "K")
                    QuestieDBCompiler.totalSize = QuestieDBCompiler.totalSize + string.len(bin) + DynamicHashTableSize(QuestieDBCompiler.index)
                    --print("Compiled DB total memory size: " .. math.floor(QuestieDBCompiler.totalSize/1024) .. "K")
                    --print("Finished! Please /reload to reduce memory usage") -- no need to reload
                    print(QuestieLocale:GetUIString("\124cFFAAEEFFQuestie DB update complete!"))

                    if finalize then finalize() end
                end)
            end)
        end)
    end)
end

function QuestieDBCompiler:ValidateNPCs()
    local validator = QuestieDBCompiler:GetDBHandle(QuestieConfig.npcBin, QuestieConfig.npcPtrs, QuestieDBCompiler:BuildSkipMap(QuestieDB.npcCompilerTypes, QuestieDB.npcCompilerOrder))

    for id,tab in pairs(QuestieDB.npcData) do
        local toValidate = {validator.Query(id, unpack(QuestieDB.npcCompilerOrder))}

        local cnt = 0 for _ in pairs(toValidate) do cnt = cnt + 1 end
        print("toValidate length: " .. cnt)
        --QuestieConfig.__toValidate = toValidate
        local validData = QuestieDB:GetNPC(id)
        for id,key in pairs(QuestieDB.npcCompilerOrder) do
            local a = toValidate[id]
            local b = validData[key]

            if type(a) == "number"  and math.abs(a-(b or 0)) > 0.2 then 
                print("Nonmatching at " .. key .. "  " .. tostring(a) .. " ~= " .. tostring(b))
                return
            elseif type(a) == "string" and a ~= (b or "") then 
                print("Nonmatching at " .. key .. "  " .. tostring(a) .. " ~= " .. tostring(b))
                return
            elseif type(a) == "table" then 
                if not equals(a, (b or {})) then 
                    print("Nonmatching at " .. key .. "  " .. id)
                    --__nma = a
                    --__nmb = b or {}
                    return
                end
            else
                print("MATCHING: " .. key)
            end
        end
    end
    print("Finished validation without issues!")

end

function QuestieDBCompiler:Validate()
    local validator = QuestieDBCompiler:GetDBHandle(QuestieConfig.objBin, QuestieConfig.objPtrs, QuestieDBCompiler:BuildSkipMap(QuestieDB.objectCompilerTypes, QuestieDB.objectCompilerOrder))

    for id, tab in pairs(QuestieDB.objectData) do
        local toValidate = {validator.Query(id, unpack(QuestieDB.objectCompilerOrder))}

        local cnt = 0 for _ in pairs(toValidate) do cnt = cnt + 1 end
        print("toValidate length: " .. cnt)
        --QuestieConfig.__toValidate = toValidate
        local validData = QuestieDB:GetObject(id)
        for id, key in pairs(QuestieDB.objectCompilerOrder) do
            local a = toValidate[id]
            local b = validData[key]

            if type(a) == "number"  and math.abs(a-(b or 0)) > 0.2 then 
                print("Nonmatching at " .. key .. "  " .. tostring(a) .. " ~= " .. tostring(b))
                return
            elseif type(a) == "string" and a ~= (b or "") then 
                print("Nonmatching at " .. key .. "  " .. tostring(a) .. " ~= " .. tostring(b))
                return
            elseif type(a) == "table" then 
                if not equals(a, (b or {})) then 
                    print("Nonmatching at " .. key .. "  " .. id)
                    --__nma = a
                    --__nmb = b or {}
                    return
                end
            else
                print("MATCHING: " .. key)
            end
        end
    end
    print("Finished validation without issues!")

end


function QuestieDBCompiler:ValidateItems()
    local validator = QuestieDBCompiler:GetDBHandle(QuestieConfig.itemBin, QuestieConfig.itemPtrs, QuestieDBCompiler:BuildSkipMap(QuestieDB.itemCompilerTypes, QuestieDB.itemCompilerOrder))

    for id,tab in pairs(QuestieDB.itemData) do
        local toValidate = {validator.Query(id, unpack(QuestieDB.itemCompilerOrder))}

        local cnt = 0 for _ in pairs(toValidate) do cnt = cnt + 1 end
        print("toValidate length: " .. cnt)
        --QuestieConfig.__toValidate = toValidate
        local validData = QuestieDB:GetItem(id)
        for id,key in pairs(QuestieDB.itemCompilerOrder) do
            local a = toValidate[id]
            local b = validData[key]

            if type(a) == "number"  and math.abs(a-(b or 0)) > 0.2 then 
                print("Nonmatching at " .. key .. "  " .. tostring(a) .. " ~= " .. tostring(b))
                return
            elseif type(a) == "string" and a ~= (b or "") then 
                print("Nonmatching at " .. key .. "  " .. tostring(a) .. " ~= " .. tostring(b))
                return
            elseif type(a) == "table" then 
                if not equals(a, (b or {})) then 
                    print("Nonmatching at " .. key .. "  " .. id)
                    --__nma = a
                    --__nmb = b or {}
                    return
                end
            else
                print("MATCHING: " .. key)
            end
        end
    end
    print("Finished validation without issues!")
end

function QuestieDBCompiler:ValidateQuests()
    local validator = QuestieDBCompiler:GetDBHandle(QuestieConfig.questBin, QuestieConfig.questPtrs, QuestieDBCompiler:BuildSkipMap(QuestieDB.questCompilerTypes, QuestieDB.questCompilerOrder))

    for id,tab in pairs(QuestieDB.questData) do
        local toValidate = {validator.Query(id, unpack(QuestieDB.questCompilerOrder))}

        local cnt = 0 for _ in pairs(toValidate) do cnt = cnt + 1 end
        print("toValidate length: " .. cnt)
        --QuestieConfig.__toValidate = toValidate
        local validData = QuestieDB:GetQuest(id)
        for id,key in pairs(QuestieDB.questCompilerOrder) do
            local a = toValidate[id]
            local b = validData[key]

            if type(a) == "number"  and math.abs(a-(b or 0)) > 0.2 then 
                print("Nonmatching at " .. key .. "  " .. tostring(a) .. " ~= " .. tostring(b))
                return
            elseif type(a) == "string" and a ~= (b or "") then 
                print("Nonmatching at " .. key .. "  " .. tostring(a) .. " ~= " .. tostring(b))
                return
            elseif type(a) == "table" then 
                if not equals(a, (b or {})) then 
                    print("Nonmatching at " .. key .. "  " .. id)
                    --__nma = a
                    --__nmb = b or {}
                    return
                end
            else
                print("MATCHING: " .. key)
            end
        end
    end
    print("Finished validation without issues!")
end

function QuestieDBCompiler:Initialize()
    QuestieDBCompiler.npcSkipMap = QuestieDBCompiler:BuildSkipMap(QuestieDB.npcCompilerTypes, QuestieDB.npcCompilerOrder)
end

function QuestieDBCompiler:BuildCompileUI() -- probably wont be used, I was thinking of making something with a progress bar since it takes ~ 30 seconds to compile the db
                                            -- but this would be too intrusive. Maybe a small progress bar that attaches to the tracker?
    local base = CreateFrame("Frame", nil, UIParent)
    base:SetBackdrop( { 
        bgFile="Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border", 
        tile = true, tileSize = 32, edgeSize = 32, 
        insets = { left = 11, right = 11, top = 11, bottom = 11 }
    });
    base:SetSize(420, 120)
    base:SetPoint("Center",UIParent)

    base.title = base:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    base.title:SetJustifyH("LEFT")
    base.title:SetPoint("CENTER", base, 0, 120/2-22)
    base.title:SetText("Questie DB has updated!")
    base.title:SetFont(base.title:GetFont(), 18)
    base.title:Show()

    base.desc = base:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    base.desc:SetJustifyH("LEFT")
    base.desc:SetPoint("CENTER", base, 0, 120/2-46)
    base.desc:SetText("The new database needs to be compiled, press start to begin.")
    --base.desc:SetFont(base.desc:GetFont(), 18)
    base.desc:Show()

    local button = CreateFrame("Button", nil, base)
    button:SetPoint("CENTER", base, "CENTER", 0, 24-120/2)
    button:SetWidth(80)
    button:SetHeight(20)

    button:SetText("Start")
    button:SetNormalFontObject("GameFontNormal")

    local function buildTexture(str)
        local tex = button:CreateTexture()
        tex:SetTexture(str)
        tex:SetTexCoord(0, 0.625, 0, 0.6875)
        tex:SetAllPoints()
        return tex
    end

    button:SetNormalTexture(buildTexture("Interface/Buttons/UI-Panel-Button-Up"))
    button:SetHighlightTexture(buildTexture("Interface/Buttons/UI-Panel-Button-Highlight"))
    button:SetPushedTexture(buildTexture("Interface/Buttons/UI-Panel-Button-Down"))
    button:SetScript("OnClick", function(...) print("clicked") end)

    base:Show()
end

function QuestieDBCompiler:GetDBHandle(data, pointers, skipmap, keyToRootIndex, overrides)
    local handle = {}
    local skipmap, lastIndex, lastPtr, types, order, indexToKey, keyToIndex = unpack(skipmap)

    local stream = QuestieStream:GetStream("raw")
    stream:Load(pointers)
    pointers = QuestieDBCompiler:DecodePointerMap(stream)
    --QuestieConfig.__pointers = pointers
    stream:Load(data)

    if overrides then
        handle.QuerySingle = function(id, key)
            local override = overrides[id]
            if override then
                local kti = keyToRootIndex[key]
                if kti and override[kti] ~= nil then return override[kti] end
            end
            local typ = types[key]
            local ptr = pointers[id]
            if ptr == nil then
                --print("Entry not found! " .. id)
                return nil
            end
            if skipmap[key] ~= nil then -- can skip directly
                stream._pointer = skipmap[key] + ptr
            else -- need to skip over some variably sized data
                stream._pointer = lastPtr + ptr
                local targetIndex = keyToIndex[key]
                if targetIndex == nil then
                    print("ERROR: Unhandled db key: " .. key)
                end
                for i = lastIndex, targetIndex-1 do
                    QuestieDBCompiler.readers[types[indexToKey[i]]](stream)
                end
            end
            return QuestieDBCompiler.readers[typ](stream)
        end
        handle.Query = function(id, ...)
            --if overrides[id] then
            --    local ret = {}
            --    for index,key in pairs({...}) do
            --        local kti = keyToIndex[key]
            --        if kti then
            --            ret[index] = overrides[id][kti]
            --        end
            --    end
            --    return ret
            --end
            local ptr = pointers[id]
            local override = overrides[id]
            if ptr == nil then
                if override then
                    local ret = {}
                    for index,key in pairs({...}) do
                        local rootIndex = keyToRootIndex[key]
                        if override and rootIndex and override[rootIndex] ~= nil then
                            ret[index] = override[rootIndex]
                        end
                    end
                    return ret
                end
                return nil
            end
            local ret = {}
            for index,key in pairs({...}) do
                local rootIndex = keyToRootIndex[key]
                if override and rootIndex and override[rootIndex] ~= nil then
                    ret[index] = override[rootIndex]
                else
                    local typ = types[key]
                    if skipmap[key] ~= nil then -- can skip directly
                        stream._pointer = skipmap[key] + ptr
                    else -- need to skip over some variably sized data
                        stream._pointer = lastPtr + ptr
                        local targetIndex = keyToIndex[key]
                        if targetIndex == nil then
                            print("ERROR: Unhandled db key: " .. key)
                        end
                        for i = lastIndex, targetIndex-1 do
                            QuestieDBCompiler.readers[types[indexToKey[i]]](stream)
                        end
                    end
                    local res = QuestieDBCompiler.readers[typ](stream)
                    ret[index] = res
                end
            end
            return ret--unpack(ret)
        end
    else
        handle.QuerySingle = function(id, key)
            local typ = types[key]
            local ptr = pointers[id]
            if ptr == nil then
                --print("Entry not found! " .. id)
                return nil
            end
            if skipmap[key] ~= nil then -- can skip directly
                stream._pointer = skipmap[key] + ptr
            else -- need to skip over some variably sized data
                stream._pointer = lastPtr + ptr
                local targetIndex = keyToIndex[key]
                if targetIndex == nil then
                    print("ERROR: Unhandled db key: " .. key)
                end
                for i = lastIndex, targetIndex-1 do
                    QuestieDBCompiler.readers[types[indexToKey[i]]](stream)
                end
            end
            return QuestieDBCompiler.readers[typ](stream)
        end

        handle.Query = function(id, ...)
            local ptr = pointers[id]
            if ptr == nil then
                --print("Entry not found! " .. id)
                return nil
            end
            local ret = {}
            for index,key in pairs({...}) do
                local typ = types[key]
                if skipmap[key] ~= nil then -- can skip directly
                    stream._pointer = skipmap[key] + ptr
                else -- need to skip over some variably sized data
                    stream._pointer = lastPtr + ptr
                    local targetIndex = keyToIndex[key]
                    if targetIndex == nil then
                        print("ERROR: Unhandled db key: " .. key)
                    end
                    for i = lastIndex, targetIndex-1 do
                        QuestieDBCompiler.readers[types[indexToKey[i]]](stream)
                    end
                end
                local res = QuestieDBCompiler.readers[typ](stream)
                ret[index] = res
            end
            return ret--unpack(ret)
        end
    end

    handle.pointers = pointers

    return handle
end
