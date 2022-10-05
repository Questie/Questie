---@class DBCompiler
local QuestieDBCompiler = QuestieLoader:CreateModule("DBCompiler")

---@type QuestieStreamLib
local QuestieStream = QuestieLoader:ImportModule("QuestieStreamLib"):GetStream("raw")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

-- how fast to run operations (lower = slower but less lag)
local TICKS_PER_YIELD_DEBUG = 4000
local TICKS_PER_YIELD = 48

---@alias CompilerTypes
---| "u8"
---| "u16"
---| "s16"
---| "u24"
---| "u32"
---| "u12pair"
---| "u24pair"
---| "s24pair"
---| "u8string"
---| "u16string"
---| "u8u16array"
---| "u8s16pairs"
---| "u16u16array"
---| "u8s24pairs"
---| "u8u24array"
---| "u16u24array"
---| "u8u16stringarray"
---| "faction"
---| "spawnlist"
---| "trigger"
---| "questgivers"
---| "objective"
---| "objectives"
---| "reflist"
---| "extraobjective


QuestieDBCompiler.supportedTypes = {
    ["table"] = {
        ["u12pair"] = true,
        ["u24pair"] = true,
        ["s24pair"] = true,
        ["u8u16array"] = true,
        ["u16u16array"] = true,
        ["u8s16pairs"] = true,
        ["u8s24pairs"] = true,
        ["spawnlist"] = true,
        ["trigger"] = true,
        ["questgivers"] = true,
        ["objective"] = true,
        ["objectives"] = true,
        ["waypointlist"] = true,
        ["u8u16stringarray"] = true,
        ["u8u24array"] = true,
        ["u16u24array"] = true,
        ["extraobjectives"] = true,
        ["reflist"] = true
    },
    ["number"] = {
        ["s8"] = true,
        ["u8"] = true,
        ["u16"] = true,
        ["s16"] = true,
        ["u24"] = true,
        ["u32"] = true
    },
    ["string"] = {
        ["u8string"] = true,
        ["u16string"] = true,
        ["faction"] = true
    }
}

QuestieDBCompiler.refTypes = {
    "monster",
    "item",
    "object"
}

QuestieDBCompiler.refTypesReversed = {
    monster = 1,
    item = 2,
    object = 3
}

QuestieDBCompiler.readers = {
    ["s8"] = function(stream)
        return stream:ReadByte() - 127
    end,
    ["u8"] = QuestieStream.ReadByte,
    ["u16"] = QuestieStream.ReadShort,
    ["s16"] = function(stream)
        return stream:ReadShort() - 32767
    end,
    ["u24"] = QuestieStream.ReadInt24,
    ["u32"] = QuestieStream.ReadInt,
    ["u12pair"] = function(stream)
        local a,b = stream:ReadInt12Pair()
        -- bit of a hack
        if a == 0 and b == 0 then
            return nil
        end
        return {a, b}
    end,
    ["u24pair"] = function(stream)
        local a,b = stream:ReadInt24(), stream:ReadInt24()
        -- bit of a hack
        if a == 0 and b == 0 then
            return nil
        end

        return {a, b}
    end,
    ["s24pair"] = function(stream)
        local a,b = stream:ReadInt24()-8388608, stream:ReadInt24()-8388608
        -- bit of a hack
        if a == 0 and b == 0 then
            return nil
        end

        return {a, b}
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
            list[i] = stream:ReadShort()
        end
        return list
    end,
    ["u8s16pairs"] = function(stream)
        local list = {}
        local count = stream:ReadByte()
        for i = 1, count do
            list[i] = {stream:ReadShort() - 32767, stream:ReadShort() - 32767}
        end
        return list
    end,
    ["u16u16array"] = function(stream)
        local count = stream:ReadShort()

        if count == 0 then return nil end

        local list = {}
        for i = 1, count do
            list[i] = stream:ReadShort()
        end
        return list
    end,
    ["u8s24pairs"] = function(stream)
        local list = {}
        local count = stream:ReadByte()
        for i = 1, count do
            list[i] = {stream:ReadInt24()-8388608, stream:ReadInt24()-8388608}
        end
        return list
    end,
    ["u8u24array"] = function(stream)
        local count = stream:ReadByte()

        if count == 0 then return nil end

        local list = {}
        for i = 1, count do
            list[i] = stream:ReadInt24()
        end
        return list
    end,
    ["u16u24array"] = function(stream)
        local count = stream:ReadShort()

        if count == 0 then return nil end

        local list = {}
        for i = 1, count do
            list[i] = stream:ReadInt24()
        end
        return list
    end,
    ["u8u16stringarray"] = function(stream)
        local list = {}
        local count = stream:ReadByte()
        for i = 1, count do
            list[i] = stream:ReadShortString()
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
        for _ = 1, count do
            local zone = stream:ReadShort()
            local spawnCount = stream:ReadShort()
            local list = {}
            for i = 1, spawnCount do
                local x, y = stream:ReadInt12Pair()
                if x == 0 and y == 0 then
                    list[i] = {-1, -1}
                else
                    list[i] = {x / 40.90, y / 40.90}
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
        return {stream:ReadTinyStringNil(), QuestieDBCompiler.readers["spawnlist"](stream)}
    end,
    ["questgivers"] = function(stream)
        --local count = stream:ReadByte()
        --if count == 0 then return nil end
        local ret = {
            QuestieDBCompiler.readers["u8u24array"](stream),
            QuestieDBCompiler.readers["u8u24array"](stream),
            QuestieDBCompiler.readers["u8u24array"](stream)
        }

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
            ret[i] = {stream:ReadInt24(), stream:ReadTinyStringNil()}
        end
        return ret
    end,
    ["objectives"] = function(stream)
        local ret = {
            QuestieDBCompiler.readers["objective"](stream),
            QuestieDBCompiler.readers["objective"](stream),
            QuestieDBCompiler.readers["objective"](stream),
            QuestieDBCompiler.readers["u24pair"](stream),
        }

        local count = stream:ReadByte()
        if count == 0 then
            return ret
        end

        local killobjectives = {}
        for i=1, count do
            local creditCount = stream:ReadByte()
            local creditList = {}
            for j=1, creditCount do
                creditList[j] = stream:ReadInt24()
            end
            killobjectives[i] = {creditList, stream:ReadInt24(), stream:ReadTinyStringNil()}
        end
        ret[5] = killobjectives

        return ret
    end,
    ["reflist"] = function(stream)
        local count = stream:ReadByte()
        if count > 0 then
            local ret = {}
            for i=1,count do
                local type = QuestieDBCompiler.refTypes[stream:ReadByte()]
                local id = stream:ReadInt24()
                ret[i] = {type, id}
            end
            return ret
        end
    end,
    ["extraobjectives"] = function(stream)
        local count = stream:ReadByte()
        if count > 0 then
            local ret = {}
            for i=1,count do
                ret[i] = {
                    QuestieDBCompiler.readers["spawnlist"](stream),
                    stream:ReadTinyString(),
                    stream:ReadShortString(),
                    stream:ReadInt24(),
                    QuestieDBCompiler.readers["reflist"](stream)
                }
            end
            return ret
        end
        return nil
    end,
    ["waypointlist"] = function(stream)
        local count = stream:ReadByte()
        local waypointlist = {}
        for _ = 1, count do
            local lists = {}
            local zone = stream:ReadShort()
            local listCount = stream:ReadByte()
            for j = 1, listCount do
                local spawnCount = stream:ReadShort()
                local list = {}
                for i = 1, spawnCount do
                    local x, y = stream:ReadInt12Pair()
                    if x == 0 and y == 0 then
                        list[i] = {-1, -1}
                    else
                        list[i] = {x / 40.90, y / 40.90}
                    end
                end
                lists[j] = list
            end
            waypointlist[zone] = lists
        end
        return waypointlist
    end,
}

QuestieDBCompiler.writers = {
    ["s8"] = function(stream, value)
        stream:WriteByte((value or 0)+127)
    end,
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
    ["u8s16pairs"] = function(stream, value)
        if value then
            local count = 0 for _ in pairs(value) do count = count + 1 end
            stream:WriteByte(count)
            for _,v in pairs(value) do
                stream:WriteShort((v[1] or 0) + 32767)
                stream:WriteShort((v[2] or 0) + 32767)
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
            stream:WriteShort(0)
        end
    end,
    ["u8s24pairs"] = function(stream, value)
        if value then
            local count = 0 for _ in pairs(value) do count = count + 1 end
            stream:WriteByte(count)
            for _,v in pairs(value) do
                stream:WriteInt24((v[1] or 0) + 8388608)
                stream:WriteInt24((v[2] or 0) + 8388608)
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
    ["u16u24array"] = function(stream, value)
        if value then
            local count = 0 for _ in pairs(value) do count = count + 1 end
            stream:WriteShort(count)
            for _,v in pairs(value) do
                stream:WriteInt24(v)
            end
        else
            stream:WriteShort(0)
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
            --print("Missing questgivers for " .. QuestieDBCompiler.currentEntry) TODO: Reintroduce this check in any form
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

            local killobjectives = value[5]
            if type(killobjectives) == "table" and #killobjectives > 0 then
                stream:WriteByte(#killobjectives)
                for i=1, #killobjectives do -- iterate over all killobjectives
                    local killobjective = killobjectives[i]
                    local npcIds = killobjective[1]
                    assert(type(npcIds) == "table", "killobjective's npcids is not a table.")
                    assert(#npcIds > 0, "killOojective has 0 npcIDs.")
                    stream:WriteByte(#npcIds) -- write count of creatureIDs
                    for j=1, #npcIds do
                        stream:WriteInt24(npcIds[j]) -- write creatureID
                    end
                    stream:WriteInt24(killobjective[2]) -- write baseCreatureID
                    stream:WriteTinyString(killobjective[3] or "") -- write baseCreatureText
                end
            else
                stream:WriteByte(0)
            end
        else
            --print("Missing objective table for " .. QuestieDBCompiler.currentEntry)
            stream:WriteByte(0)
            stream:WriteByte(0)
            stream:WriteByte(0)
            stream:WriteInt24(0)
            stream:WriteInt24(0)
            stream:WriteByte(0)
        end
    end,
    ["reflist"] = function(stream, value)
        stream:WriteByte(#value)
        for _, v in pairs(value) do
            stream:WriteByte(QuestieDBCompiler.refTypesReversed[v[1]])
            stream:WriteInt24(v[2])
        end
    end,
    ["extraobjectives"] = function(stream, value)
        if value then
            stream:WriteByte(#value)
            for _, data in pairs(value) do
                QuestieDBCompiler.writers["spawnlist"](stream, data[1])
                stream:WriteTinyString(data[2]) -- icon
                stream:WriteShortString(data[3]) -- description
                stream:WriteInt24(data[4] or 0) -- objective index (or 0)
                QuestieDBCompiler.writers["reflist"](stream, data[5] or {})
            end
        else
            stream:WriteByte(0)
        end
    end,
    ["waypointlist"] = function(stream, value)
        if value then
            local count = 0 for _ in pairs(value) do count = count + 1 end
            stream:WriteByte(count)
            for zone, spawnlists in pairs(value) do
                stream:WriteShort(zone)
                count = 0 for _ in pairs(spawnlists) do count = count + 1 end
                stream:WriteByte(count)
                for _, spawnlist in pairs(spawnlists) do
                    count = 0 for _ in pairs(spawnlist) do count = count + 1 end
                    stream:WriteShort(count)
                    for _, spawn in pairs(spawnlist) do
                        if spawn[1] == -1 and spawn[2] == -1 then -- instance spawn
                            stream:WriteInt24(0) -- 0 instead
                        else
                            stream:WriteInt12Pair(math.floor(spawn[1] * 40.90), math.floor(spawn[2] * 40.90))
                        end
                    end
                end
            end
        else
            --print("Missing spawnlist for " .. QuestieDBCompiler.currentEntry)
            stream:WriteByte(0)
        end
    end
}

QuestieDBCompiler.skippers = {
    ["s8"] = function(stream) stream._pointer = stream._pointer + 1 end,
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
    ["u8s16pairs"] = function(stream) stream._pointer = stream:ReadByte() * 4 + stream._pointer end,
    ["u16u16array"] = function(stream) stream._pointer = stream:ReadShort() * 2 + stream._pointer end,
    ["u8s24pairs"] = function(stream) stream._pointer = stream:ReadByte() * 6 + stream._pointer end,
    ["u8u24array"] = function(stream) stream._pointer = stream:ReadByte() * 3 + stream._pointer end,
    ["u16u24array"] = function(stream) stream._pointer = stream:ReadShort() * 3 + stream._pointer end,
    ["waypointlist"]  = function(stream)
        local count = stream:ReadByte()
        for _ = 1, count do
            stream._pointer = stream._pointer + 2
            local listCount = stream:ReadByte()
            for _ = 1, listCount do
                stream._pointer = stream:ReadShort() * 3 + stream._pointer
            end
        end
    end,
    ["u8u16stringarray"] = function(stream)
        local count = stream:ReadByte()
        for _=1,count do
            stream._pointer = stream:ReadShort() + stream._pointer
        end
    end,
    ["faction"] = function(stream) stream._pointer = stream._pointer + 1 end,
    ["spawnlist"] = function(stream)
        local count = stream:ReadByte()
        for _ = 1, count do
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
        --for _ = 1, count do
        --    QuestieDBCompiler.skippers["u8u16array"](stream)
        --end
        QuestieDBCompiler.skippers["u8u24array"](stream)
        QuestieDBCompiler.skippers["u8u24array"](stream)
        QuestieDBCompiler.skippers["u8u24array"](stream)
    end,
    ["objective"] = function(stream)
        local count = stream:ReadByte()
        for _=1,count do
            stream._pointer = stream._pointer + 3
            stream._pointer = stream:ReadByte() + stream._pointer
        end
    end,
    ["objectives"] = function(stream)
        QuestieDBCompiler.skippers["objective"](stream)
        QuestieDBCompiler.skippers["objective"](stream)
        QuestieDBCompiler.skippers["objective"](stream)
        QuestieDBCompiler.skippers["u24pair"](stream)
        local count = stream:ReadByte() -- killobjectives
        if count > 0 then
            for _=1, count do
                stream._pointer = stream:ReadByte() * 3 + 3 + stream._pointer
                stream._pointer = stream:ReadByte() + stream._pointer
            end
        end
    end,
    ["reflist"] = function(stream)
        stream._pointer = stream:ReadByte() * 4 + stream._pointer
    end,
    ["extraobjectives"] = function(stream)
        local count = stream:ReadByte()
        for _=1,count do
            QuestieDBCompiler.skippers["spawnlist"](stream)
            stream._pointer = stream:ReadByte() + stream._pointer
            stream._pointer = stream:ReadShort() + stream._pointer
            stream._pointer = stream._pointer + 3
            QuestieDBCompiler.skippers["reflist"](stream)
        end
    end
}

QuestieDBCompiler.dynamics = {
    ["u8string"] = true,
    ["u16string"] = true,
    ["u8u16array"] = true,
    ["u8s16pairs"] = true,
    ["u16u16array"] = true,
    ["u8s24pairs"] = true,
    ["u8u24array"] = true,
    ["u16u24array"] = true,
    ["u8u16stringarray"] = true,
    ["spawnlist"] = true,
    ["trigger"] = true,
    ["objective"] = true,
    ["objectives"] = true,
    ["questgivers"] = true,
    ["waypointlist"] = true,
    ["extraobjectives"] = true,
    ["reflist"] = true
}

QuestieDBCompiler.statics = {
    ["u8"] = 1,
    ["s8"] = 1,
    ["u16"] = 2,
    ["s16"] = 2,
    ["u24"] = 3,
    ["u32"] = 4,
    ["faction"] = 1,
    ["u12pair"] = 3,
    ["u24pair"] = 6,
    ["s24pair"] = 6,
}

function QuestieDBCompiler:CompileNPCs()
    QuestieDBCompiler:CompileTableCoroutine(QuestieDB.npcData, QuestieDB.npcCompilerTypes, QuestieDB.npcCompilerOrder, QuestieDB.npcKeys, "npc", "NPC")
end

function QuestieDBCompiler:CompileObjects()
    QuestieDBCompiler:CompileTableCoroutine(QuestieDB.objectData, QuestieDB.objectCompilerTypes, QuestieDB.objectCompilerOrder, QuestieDB.objectKeys, "obj", "Object")
end

function QuestieDBCompiler:CompileQuests()
    QuestieDBCompiler:CompileTableCoroutine(QuestieDB.questData, QuestieDB.questCompilerTypes, QuestieDB.questCompilerOrder, QuestieDB.questKeys, "quest", "Quest", 28)
end

function QuestieDBCompiler:CompileItems()
    QuestieDBCompiler:CompileTableCoroutine(QuestieDB.itemData, QuestieDB.itemCompilerTypes, QuestieDB.itemCompilerOrder, QuestieDB.itemKeys, "item", "Item", 128)
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
            if not equals(a[k], v) then
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
    local i = 0
    while i < count do
        for _ = 1, math.min(768, count-i) do -- steps per yield
            ret[stream:ReadInt24()] = stream:ReadInt24()
        end
        i = i + 768
        coroutine.yield()
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

function QuestieDBCompiler:CompileTableCoroutine(tbl, types, order, lookup, databaseKey, kind, entriesPerTick)
    local count = 0
    local indexLookup = {};

    local max_id = 0
    for id in pairs(tbl) do
        assert(type(id) == "number", "CompileTableCoroutine: tbl id is not a number")
        if id > max_id then
            max_id = id
        end
    end
    -- iterate table tbl in numerical order to get ids in order to indexLoopup list. iterating over pairs(tbl) gives ids in non determined order
    for id=0,max_id do
        if tbl[id] then
            count = count + 1
            indexLookup[count] = id
        end
    end
    count = count + 1

    QuestieDBCompiler.index = 0

    QuestieDBCompiler.pointerMap = {}
    QuestieDBCompiler.stream = Questie.db.global.debugEnabled and QuestieStream:GetStream("raw_assert") or QuestieStream:GetStream("raw")

    while true do
        coroutine.yield()
        for _=0,Questie.db.global.debugEnabled and TICKS_PER_YIELD_DEBUG or (entriesPerTick or TICKS_PER_YIELD) do
            QuestieDBCompiler.index = QuestieDBCompiler.index + 1
            if QuestieDBCompiler.index == count then
                Questie.db.global[databaseKey.."Bin"] = QuestieDBCompiler.stream:Save()
                Questie.db.global[databaseKey.."Ptrs"] = QuestieDBCompiler:EncodePointerMap(QuestieDBCompiler.stream, QuestieDBCompiler.pointerMap)
                QuestieDBCompiler.stream:finished() -- relief memory pressure
                return
            end
            local id = indexLookup[QuestieDBCompiler.index]

            QuestieDBCompiler.currentEntry = id
            local entry = tbl[id]

            QuestieDBCompiler.pointerMap[id] = QuestieDBCompiler.stream._pointer--pointerStart
            for i=1, #order do
                local key = order[i]
                local v = entry[lookup[key]]
                local t = types[key]

                if v and not QuestieDBCompiler.supportedTypes[type(v)][t] then
                    Questie:Error("|cFFFF0000Invalid datatype!|r   " .. kind .. "s[" .. tostring(id) .. "]."..key..": \"" .. type(v) .. "\" is not compatible with type \"" .. t .."\"")
                    return
                end
                if not QuestieDBCompiler.writers[t] then
                    Questie:Error("Invalid datatype: " .. key .. " " .. tostring(t))
                end
                --print(key .. "s[" .. tostring(id) .. "]."..key..": \"" .. type(v) .. "\"")
                local result, errorMessage = pcall(QuestieDBCompiler.writers[t], QuestieDBCompiler.stream, v)
                if not result then
                    Questie:Error("There was an error when compiling data for "..kind.." " .. tostring(id) .. " \""..tostring(key).."\":")
                    Questie:Error(errorMessage)
                    error(errorMessage)
                end
            end
            tbl[id] = nil -- quicker gabage collection later
        end
    end
end

function QuestieDBCompiler:BuildSkipMap(types, order) -- skip map is used for random access, to read specific fields in an entry without reading the whole entry
    local skipmap = {}
    local indexToKey = {}
    local keyToIndex = {}
    local ptr = 0
    local haveDynamic = false
    local lastIndex
    for index = 1, #order do
        local key = order[index]
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

function QuestieDBCompiler:Compile()
    if QuestieDBCompiler._isCompiling then
        return
    end

    QuestieDBCompiler._isCompiling = true -- some unknown addon that is popular in china causes player_logged_in event to fire many times which triggers db compile multiple times

    QuestieDBCompiler.startTime = GetTime()
    QuestieDBCompiler.totalSize = 0

    print("\124cFF4DDBFF [4/7] " .. l10n("Updating NPCs") .. "...")
    QuestieDBCompiler:CompileNPCs()
    print("\124cFF4DDBFF [5/7] " .. l10n("Updating objects") .. "...")
    QuestieDBCompiler:CompileObjects()
    print("\124cFF4DDBFF [6/7] " .. l10n("Updating quests") .. "...")
    QuestieDBCompiler:CompileQuests()
    print("\124cFF4DDBFF [7/7] " .. l10n("Updating items") .. "...")
    QuestieDBCompiler:CompileItems()
    print("\124cFFAAEEFF"..l10n("Questie DB update complete!"))

    Questie.db.global.dbCompiledOnVersion = QuestieLib:GetAddonVersionString()
    Questie.db.global.dbCompiledLang = (Questie.db.global.questieLocaleDiff and Questie.db.global.questieLocale or GetLocale())
    Questie.db.global.dbIsCompiled = true
    Questie.db.global.dbCompiledCount = (Questie.db.global.dbCompiledCount or 0) + 1

    if Questie.db.global.debugEnabled then
        coroutine.yield()
        Questie:Debug(Questie.DEBUG_INFO, "Validating NPCs...")
        QuestieDBCompiler:ValidateNPCs()
        coroutine.yield()
        Questie:Debug(Questie.DEBUG_INFO, "Validating objects...")
        QuestieDBCompiler:ValidateObjects()
        coroutine.yield()
        Questie:Debug(Questie.DEBUG_INFO, "Validating items...")
        QuestieDBCompiler:ValidateItems()
        coroutine.yield()
        Questie:Debug(Questie.DEBUG_INFO, "Validating quests...")
        QuestieDBCompiler:ValidateQuests()
    end
end

function QuestieDBCompiler:ValidateNPCs()
    local validator = QuestieDBCompiler:GetDBHandle(Questie.db.global.npcBin, Questie.db.global.npcPtrs, QuestieDBCompiler:BuildSkipMap(QuestieDB.npcCompilerTypes, QuestieDB.npcCompilerOrder))

    for npcId, _ in pairs(QuestieDB.npcData) do
        local toValidate = {validator.Query(npcId, unpack(QuestieDB.npcCompilerOrder))}

        local cnt = 0 for _ in pairs(toValidate) do cnt = cnt + 1 end
        print("toValidate length: " .. cnt)
        --Questie.db.global.__toValidate = toValidate
        local validData = QuestieDB:GetNPC(npcId)
        for id, key in pairs(QuestieDB.npcCompilerOrder) do
            local a = toValidate[id]
            local b = validData[key]

            if type(a) == "number"  and math.abs(a-(b or 0)) > 0.2 then
                Questie:Error("Nonmatching at " .. key .. "  " .. tostring(a) .. " ~= " .. tostring(b))
                return
            elseif type(a) == "string" and a ~= (b or "") then
                Questie:Error("Nonmatching at " .. key .. "  " .. tostring(a) .. " ~= " .. tostring(b))
                return
            elseif type(a) == "table" then
                if not equals(a, (b or {})) then
                    Questie:Error("Nonmatching at " .. key .. "  " .. id)
                    --__nma = a
                    --__nmb = b or {}
                    return
                end
            else
                print("MATCHING: " .. key)
            end
        end
    end

    validator.stream:finished()
    Questie:Debug(Questie.DEBUG_INFO, "Finished NPCs validation without issues!")
end

function QuestieDBCompiler:ValidateObjects()
    local validator = QuestieDBCompiler:GetDBHandle(Questie.db.global.objBin, Questie.db.global.objPtrs, QuestieDBCompiler:BuildSkipMap(QuestieDB.objectCompilerTypes, QuestieDB.objectCompilerOrder))

    for objectId, _ in pairs(QuestieDB.objectData) do
        local toValidate = {validator.Query(objectId, unpack(QuestieDB.objectCompilerOrder))}

        local cnt = 0 for _ in pairs(toValidate) do cnt = cnt + 1 end
        print("toValidate length: " .. cnt)
        --Questie.db.global.__toValidate = toValidate
        local validData = QuestieDB:GetObject(objectId)
        for id, key in pairs(QuestieDB.objectCompilerOrder) do
            local a = toValidate[id]
            local b = validData[key]

            if type(a) == "number"  and math.abs(a-(b or 0)) > 0.2 then
                Questie:Error("Nonmatching at " .. key .. "  " .. tostring(a) .. " ~= " .. tostring(b))
                return
            elseif type(a) == "string" and a ~= (b or "") then
                Questie:Error("Nonmatching at " .. key .. "  " .. tostring(a) .. " ~= " .. tostring(b))
                return
            elseif type(a) == "table" then
                if not equals(a, (b or {})) then
                    Questie:Error("Nonmatching at " .. key .. "  " .. id)
                    --__nma = a
                    --__nmb = b or {}
                    return
                end
            else
                print("MATCHING: " .. key)
            end
        end
    end

    validator.stream:finished()
    Questie:Debug(Questie.DEBUG_INFO, "Finished objects validation without issues!")
end


function QuestieDBCompiler:ValidateItems()
    local validator = QuestieDBCompiler:GetDBHandle(Questie.db.global.itemBin, Questie.db.global.itemPtrs, QuestieDBCompiler:BuildSkipMap(QuestieDB.itemCompilerTypes, QuestieDB.itemCompilerOrder))
    local obj = QuestieDBCompiler:GetDBHandle(Questie.db.global.objBin, Questie.db.global.objPtrs, QuestieDBCompiler:BuildSkipMap(QuestieDB.objectCompilerTypes, QuestieDB.objectCompilerOrder))
    local npc = QuestieDBCompiler:GetDBHandle(Questie.db.global.npcBin, Questie.db.global.npcPtrs, QuestieDBCompiler:BuildSkipMap(QuestieDB.npcCompilerTypes, QuestieDB.npcCompilerOrder))

    for id, _ in pairs(validator.pointers) do
        local objDrops, npcDrops = validator.QuerySingle(id, "objectDrops"), validator.QuerySingle(id, "npcDrops")
        if objDrops then -- validate object drops
            --print("Validating objs")
            for _, oid in pairs(objDrops) do
                if not obj.QuerySingle(oid, "name") then
                    Questie:Error("Missing object " .. tostring(oid) .. " that drops " .. (validator.QuerySingle(id, "name") or "Missing item name!") .. " " .. tostring(id))
                    return
                end
            end
        end

        if npcDrops then -- validate npc drops
            for _, nid in pairs(npcDrops) do
                --print("Validating npcs")
                if not npc.QuerySingle(nid, "name") then
                    Questie:Error("Missing npc " .. tostring(nid))
                    return
                end
            end
        end

        -- todo fix this test
        --if false then
        --    local cnt = 0 for _ in pairs(toValidate) do cnt = cnt + 1 end
        --    print("toValidate length: " .. cnt)
        --    --Questie.db.global.__toValidate = toValidate
        --    local validData = QuestieDB:GetItem(id)
        --    for id,key in pairs(QuestieDB.itemCompilerOrder) do
        --        local a = toValidate[id]
        --        local b = validData[key]
        --
        --        if type(a) == "number"  and math.abs(a-(b or 0)) > 0.2 then
        --            print("Nonmatching at " .. key .. "  " .. tostring(a) .. " ~= " .. tostring(b))
        --            return
        --        elseif type(a) == "string" and a ~= (b or "") then
        --            print("Nonmatching at " .. key .. "  " .. tostring(a) .. " ~= " .. tostring(b))
        --            return
        --        elseif type(a) == "table" then
        --            if not equals(a, (b or {})) then
        --                print("Nonmatching at " .. key .. "  " .. id)
        --                --__nma = a
        --                --__nmb = b or {}
        --                return
        --            end
        --        else
        --            print("MATCHING: " .. key)
        --        end
        --    end
        --end
    end

    validator.stream:finished()
    obj.stream:finished()
    npc.stream:finished()
    Questie:Debug(Questie.DEBUG_INFO, "Finished items validation without issues!")
end

function QuestieDBCompiler:ValidateQuests()
    local validator = QuestieDBCompiler:GetDBHandle(Questie.db.global.questBin, Questie.db.global.questPtrs, QuestieDBCompiler:BuildSkipMap(QuestieDB.questCompilerTypes, QuestieDB.questCompilerOrder))

    for questId, _ in pairs(QuestieDB.questData) do
        local toValidate = {validator.Query(questId, unpack(QuestieDB.questCompilerOrder))}

        local cnt = 0 for _ in pairs(toValidate) do cnt = cnt + 1 end
        print("toValidate length: " .. cnt)
        --Questie.db.global.__toValidate = toValidate
        local validData = QuestieDB:GetQuest(questId)
        for id,key in pairs(QuestieDB.questCompilerOrder) do
            local a = toValidate[id]
            local b = validData[key]

            if type(a) == "number"  and math.abs(a-(b or 0)) > 0.2 then
                Questie:Error("Nonmatching at " .. key .. "  " .. tostring(a) .. " ~= " .. tostring(b))
                return
            elseif type(a) == "string" and a ~= (b or "") then
                Questie:Error("Nonmatching at " .. key .. "  " .. tostring(a) .. " ~= " .. tostring(b))
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

    validator.stream:finished()
    Questie:Debug(Questie.DEBUG_INFO, "Finished quests validation without issues!")
end

function QuestieDBCompiler:Initialize()
    QuestieDBCompiler.npcSkipMap = QuestieDBCompiler:BuildSkipMap(QuestieDB.npcCompilerTypes, QuestieDB.npcCompilerOrder)
end

function QuestieDBCompiler:GetDBHandle(data, pointers, skipMap, keyToRootIndex, overrides)
    local handle = {}
    local map, lastIndex, lastPtr, types, _, indexToKey, keyToIndex = unpack(skipMap)

    local stream = QuestieStream:GetStream("raw")
    coroutine.yield()
    stream:Load(pointers)
    coroutine.yield()
    pointers = QuestieDBCompiler:DecodePointerMap(stream)
    --Questie.db.global.__pointers = pointers
    coroutine.yield()
    stream:Load(data)
    handle.stream = stream

    if overrides then
        handle.QuerySingle = function(id, key)
            local override = overrides[id]
            if override then
                local kti = keyToRootIndex[key]
                if kti and override[kti] ~= nil then return override[kti] end
            end
            local typ = types[key]
            local ptr = pointers[id]
            if not ptr then
                --print("Entry not found! " .. id)
                return nil
            end
            if map[key] ~= nil then -- can skip directly
                stream._pointer = map[key] + ptr
            else -- need to skip over some variably sized data
                stream._pointer = lastPtr + ptr
                local targetIndex = keyToIndex[key]
                if not targetIndex then
                    Questie:Error("ERROR: Unhandled db key: " .. key)
                    return nil
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
            local keys = {...}
            if not ptr then
                if override then
                    local ret = {}
                    for index=1,#keys do
                        local rootIndex = keyToRootIndex[keys[index]]
                        if rootIndex and override[rootIndex] ~= nil then
                            ret[index] = override[rootIndex]
                        end
                    end
                    return ret
                end
                return nil
            end
            local ret = {}
            for index=1,#keys do
                local key = keys[index]
                local rootIndex = keyToRootIndex[key]
                if override and rootIndex and override[rootIndex] ~= nil then
                    ret[index] = override[rootIndex]
                else
                    local typ = types[key]
                    if map[key] ~= nil then -- can skip directly
                        stream._pointer = map[key] + ptr
                    else -- need to skip over some variably sized data
                        stream._pointer = lastPtr + ptr
                        local targetIndex = keyToIndex[key]
                        if not targetIndex then
                            Questie:Error("ERROR: Unhandled db key: " .. key)
                            return nil
                        end
                        for i = lastIndex, targetIndex-1 do
                            QuestieDBCompiler.readers[types[indexToKey[i]]](stream)
                        end
                    end
                    ret[index] = QuestieDBCompiler.readers[typ](stream)
                end
            end
            return ret -- do not unpack the returned table
        end
    else
        handle.QuerySingle = function(id, key)
            local typ = types[key]
            local ptr = pointers[id]
            if not ptr then
                --print("Entry not found! " .. id)
                return nil
            end
            if map[key] ~= nil then -- can skip directly
                stream._pointer = map[key] + ptr
            else -- need to skip over some variably sized data
                stream._pointer = lastPtr + ptr
                local targetIndex = keyToIndex[key]
                if not targetIndex then
                    Questie:Error("ERROR: Unhandled db key: " .. key)
                    return nil
                end
                for i = lastIndex, targetIndex-1 do
                    QuestieDBCompiler.readers[types[indexToKey[i]]](stream)
                end
            end
            return QuestieDBCompiler.readers[typ](stream)
        end

        handle.Query = function(id, ...)
            local ptr = pointers[id]
            if not ptr then
                --print("Entry not found! " .. id)
                return nil
            end
            local keys = {...}
            local ret = {}
            for index=1,#keys do
                local key = keys[index]
                local typ = types[key]
                if map[key] ~= nil then -- can skip directly
                    stream._pointer = map[key] + ptr
                else -- need to skip over some variably sized data
                    stream._pointer = lastPtr + ptr
                    local targetIndex = keyToIndex[key]
                    if not targetIndex then
                        Questie:Error("ERROR: Unhandled db key: " .. key)
                        return nil
                    end
                    for i = lastIndex, targetIndex-1 do
                        QuestieDBCompiler.readers[types[indexToKey[i]]](stream)
                    end
                end
                ret[index] = QuestieDBCompiler.readers[typ](stream)
            end
            return ret -- do not unpack the returned table
        end
    end

    handle.pointers = pointers

    return handle
end
