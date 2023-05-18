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


local type = type
local abs, min, floor = math.abs, math.min, math.floor
local lshift = bit.lshift


-- how fast to run operations (lower = slower but less lag)
local TICKS_PER_YIELD = 48
local TICKS_PER_YIELD_DEBUG = TICKS_PER_YIELD * 3

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
        ["s24"] = true,
        ["u32"] = true
    },
    ["string"] = {
        ["u8string"] = true,
        ["u16string"] = true,
        ["faction"] = true
    }
}

local refTypes = {
    "monster",
    "item",
    "object"
}
QuestieDBCompiler.refTypes = refTypes

QuestieDBCompiler.refTypesReversed = {
    monster = 1,
    item = 2,
    object = 3
}

local readers = {}
local skippers = {}

readers["s8"] = function(stream)
    return stream:ReadByte() - 127
end
readers["u8"] = QuestieStream.ReadByte
readers["u16"] = QuestieStream.ReadShort
readers["s16"] = function(stream)
    return stream:ReadShort() - 32767
end
readers["u24"] = QuestieStream.ReadInt24
readers["s24"] = function(stream)
    return stream:ReadInt24() - 8388607
end
readers["u32"] = QuestieStream.ReadInt
readers["u12pair"] = function(stream)
    local a,b = stream:ReadInt12Pair()
    -- bit of a hack
    if a == 0 and b == 0 then
        return nil
    end
    return {a, b}
end
readers["u24pair"] = function(stream)
    local a,b = stream:ReadInt24(), stream:ReadInt24()
    -- bit of a hack
    if a == 0 and b == 0 then
        return nil
    end

    return {a, b}
end
readers["s24pair"] = function(stream)
    local a,b = stream:ReadInt24()-8388608, stream:ReadInt24()-8388608
    -- bit of a hack
    if a == 0 and b == 0 then
        return nil
    end

    return {a, b}
end
readers["u8string"] = function(stream)
    local ret = stream:ReadTinyString()
    if ret == "nil" then-- I hate this but we need to support both nil strings and empty strings
        return nil
    else
        return ret
    end
end
readers["u16string"] = function(stream)
    local ret = stream:ReadShortString()
    if ret == "nil" then-- I hate this but we need to support both nil strings and empty strings
        return nil
    else
        return ret
    end
end
readers["u8u16array"] = function(stream)
    local count = stream:ReadByte()

    if count == 0 then return nil end

    local list = {}

    for i = 1, count do
        list[i] = stream:ReadShort()
    end
    return list
end
readers["u8s16pairs"] = function(stream)
    local count = stream:ReadByte()
    if count == 0 then return nil end

    local list = {}
    for i = 1, count do
        list[i] = {stream:ReadShort() - 32767, stream:ReadShort() - 32767}
    end
    return list
end
readers["u16u16array"] = function(stream)
    local count = stream:ReadShort()
    if count == 0 then return nil end

    local list = {}
    for i = 1, count do
        list[i] = stream:ReadShort()
    end
    return list
end
readers["u8s24pairs"] = function(stream)
    local count = stream:ReadByte()
    if count == 0 then return nil end

    local list = {}
    for i = 1, count do
        list[i] = {stream:ReadInt24()-8388608, stream:ReadInt24()-8388608}
    end
    return list
end
readers["u8u24array"] = function(stream)
    local count = stream:ReadByte()
    if count == 0 then return nil end

    local list = {}
    for i = 1, count do
        list[i] = stream:ReadInt24()
    end
    return list
end
readers["u16u24array"] = function(stream)
    local count = stream:ReadShort()
    if count == 0 then return nil end

    local list = {}
    for i = 1, count do
        list[i] = stream:ReadInt24()
    end
    return list
end
readers["u8u16stringarray"] = function(stream)
    local count = stream:ReadByte()
    if count == 0 then return nil end

    local list = {}
    for i = 1, count do
        list[i] = stream:ReadShortString()
    end
    return list
end
readers["faction"] = function(stream)
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
end
readers["spawnlist"] = function(stream)
    local count = stream:ReadByte()
    if count == 0 then return nil end

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
end
readers["trigger"] = function(stream)
    if stream:ReadShort() == 0 then
        return nil
    else
        stream._pointer = stream._pointer - 2
    end
    return {stream:ReadTinyStringNil(), readers["spawnlist"](stream)}
end
local u8u24arrayReader = readers["u8u24array"]
readers["questgivers"] = function(stream)
    return {
        u8u24arrayReader(stream),
        u8u24arrayReader(stream),
        u8u24arrayReader(stream)
    }
end
readers["objective"] = function(stream)
    local count = stream:ReadByte()
    if count == 0 then return nil end

    local ret = {}
    for i = 1, count do
        ret[i] = {stream:ReadInt24(), stream:ReadTinyStringNil()}
    end
    return ret
end

readers["objectives"] = function(stream)
    local ret = {
        readers["objective"](stream),
        readers["objective"](stream),
        readers["objective"](stream),
        readers["u24pair"](stream),
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
end
readers["reflist"] = function(stream)
    local count = stream:ReadByte()
    if count > 0 then
        local ret = {}
        for i=1,count do
            ret[i] = {refTypes[stream:ReadByte()], stream:ReadInt24()}
        end
        return ret
    end
end
readers["extraobjectives"] = function(stream)
    local count = stream:ReadByte()
    if count > 0 then
        local ret = {}
        for i=1,count do
            ret[i] = {
                readers["spawnlist"](stream),
                stream:ReadInt24(),
                stream:ReadShortString(),
                stream:ReadInt24(),
                readers["reflist"](stream)
            }
        end
        return ret
    end
    return nil
end
readers["waypointlist"] = function(stream)
    local count = stream:ReadByte()
    if count == 0 then return nil end

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
end

QuestieDBCompiler.readers = readers

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
    ["s24"] = function(stream, value)
        stream:WriteInt24(8388607 + (value or 0))
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
                        stream:WriteInt12Pair(floor(spawn[1] * 40.90), floor(spawn[2] * 40.90))
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
                stream:WriteInt24(data[2]) -- icon
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
                            stream:WriteInt12Pair(floor(spawn[1] * 40.90), floor(spawn[2] * 40.90))
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

skippers["s8"] = function(stream) stream._pointer = stream._pointer + 1 end
skippers["u8"] = function(stream) stream._pointer = stream._pointer + 1 end
skippers["u16"] = function(stream) stream._pointer = stream._pointer + 2 end
skippers["s16"] = function(stream) stream._pointer = stream._pointer + 2 end
skippers["u24"] = function(stream) stream._pointer = stream._pointer + 3 end
skippers["s24"] = function(stream) stream._pointer = stream._pointer + 3 end
skippers["u32"] = function(stream) stream._pointer = stream._pointer + 4 end
skippers["u12pair"] = function(stream) stream._pointer = stream._pointer + 3 end
skippers["u24pair"] = function(stream) stream._pointer = stream._pointer + 6 end
skippers["s24pair"] = function(stream) stream._pointer = stream._pointer + 6 end
skippers["u8string"] = function(stream) stream._pointer = stream:ReadByte() + stream._pointer end
skippers["u16string"] = function(stream) stream._pointer = stream:ReadShort() + stream._pointer end
skippers["u8u16array"] = function(stream) stream._pointer = stream:ReadByte() * 2 + stream._pointer end
skippers["u8s16pairs"] = function(stream) stream._pointer = stream:ReadByte() * 4 + stream._pointer end
skippers["u16u16array"] = function(stream) stream._pointer = stream:ReadShort() * 2 + stream._pointer end
skippers["u8s24pairs"] = function(stream) stream._pointer = stream:ReadByte() * 6 + stream._pointer end
skippers["u8u24array"] = function(stream) stream._pointer = stream:ReadByte() * 3 + stream._pointer end
skippers["u16u24array"] = function(stream) stream._pointer = stream:ReadShort() * 3 + stream._pointer end
skippers["waypointlist"]  = function(stream)
    local count = stream:ReadByte()
    for _ = 1, count do
        stream._pointer = stream._pointer + 2
        local listCount = stream:ReadByte()
        for _ = 1, listCount do
            stream._pointer = stream:ReadShort() * 3 + stream._pointer
        end
    end
end
skippers["u8u16stringarray"] = function(stream)
    local count = stream:ReadByte()
    for _=1,count do
        stream._pointer = stream:ReadShort() + stream._pointer
    end
end
skippers["faction"] = function(stream) stream._pointer = stream._pointer + 1 end
skippers["spawnlist"] = function(stream)
    local count = stream:ReadByte()
    for _ = 1, count do
        stream._pointer = stream._pointer + 2
        stream._pointer = stream:ReadShort() * 3 + stream._pointer
    end
end
local spawnlistSkipper = skippers["spawnlist"]
skippers["trigger"] = function(stream)
    stream._pointer = stream:ReadByte() + stream._pointer
    spawnlistSkipper(stream)
end
local u8u24arraySkipper = skippers["u8u24array"]
skippers["questgivers"] = function(stream)
    u8u24arraySkipper(stream)
    u8u24arraySkipper(stream)
    u8u24arraySkipper(stream)
end
skippers["objective"] = function(stream)
    local count = stream:ReadByte()
    for _=1,count do
        stream._pointer = stream._pointer + 3
        stream._pointer = stream:ReadByte() + stream._pointer
    end
end
local objectiveSkipper = skippers["objective"]
local u24pairSkipper = skippers["u24pair"]
skippers["objectives"] = function(stream)
    objectiveSkipper(stream)
    objectiveSkipper(stream)
    objectiveSkipper(stream)
    u24pairSkipper(stream)
    local count = stream:ReadByte() -- killobjectives
    if count > 0 then
        for _=1, count do
            stream._pointer = stream:ReadByte() * 3 + 3 + stream._pointer
            stream._pointer = stream:ReadByte() + stream._pointer
        end
    end
end
skippers["reflist"] = function(stream)
    stream._pointer = stream:ReadByte() * 4 + stream._pointer
end
local reflistSkipper = skippers["reflist"]
skippers["extraobjectives"] = function(stream)
    local count = stream:ReadByte()
    for _=1,count do
        spawnlistSkipper(stream)
        stream._pointer = stream._pointer + 3
        stream._pointer = stream:ReadShort() + stream._pointer
        stream._pointer = stream._pointer + 3
        reflistSkipper(stream)
    end
end

QuestieDBCompiler.skippers = skippers

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
    ["s24"] = 3,
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
        return abs(a-b) < 0.2 -- 100/4096 is the precision of the data (From Aero)
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
        for _ = 1, min(768, count-i) do -- steps per yield
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

    local index = 0

    local pointerMap = {}
    local stream = Questie.db.global.debugEnabled and QuestieStream:GetStream("raw_assert") or QuestieStream:GetStream("raw")

    -- Localize functions
    local pcall, type = pcall, type
    local writers = QuestieDBCompiler.writers
    local supportedTypes = QuestieDBCompiler.supportedTypes

    while true do
        coroutine.yield()
        for _=0,Questie.db.global.debugEnabled and TICKS_PER_YIELD_DEBUG or (entriesPerTick or TICKS_PER_YIELD) do
            index = index + 1
            if index == count then
                Questie.db.global[databaseKey.."Bin"] = stream:Save()
                Questie.db.global[databaseKey.."Ptrs"] = QuestieDBCompiler:EncodePointerMap(stream, pointerMap)
                stream:finished() -- relief memory pressure
                return
            end
            local id = indexLookup[index]

            -- QuestieDBCompiler.currentEntry = id -- This was only ever used for debugging.
            local entry = tbl[id]

            pointerMap[id] = stream._pointer--pointerStart
            for i=1, #order do
                local key = order[i]
                local v = entry[lookup[key]]
                local t = types[key]

                if v and not supportedTypes[type(v)][t] then
                    Questie:Error("|cFFFF0000Invalid datatype!|r   " .. kind .. "s[" .. tostring(id) .. "]."..key..": \"" .. type(v) .. "\" is not compatible with type \"" .. t .."\"")
                    return
                end
                if not writers[t] then
                    Questie:Error("Invalid datatype: " .. key .. " " .. tostring(t))
                end
                --print(key .. "s[" .. tostring(id) .. "]."..key..": \"" .. type(v) .. "\"")
                local result, errorMessage = pcall(writers[t], stream, v)
                if not result then
                    Questie:Error("There was an error when compiling data for "..kind.." " .. tostring(id) .. " \""..tostring(key).."\":")
                    Questie:Error(errorMessage)
                    error(errorMessage)
                end
            end
            -- tbl[id] = nil -- quicker gabage collection later
        end
    end
    --I do not know if these assignments are actually needed but I am too scared to remove them
    -- QuestieDBCompiler.pointerMap = pointerMap
    -- QuestieDBCompiler.stream = stream
    -- QuestieDBCompiler.index = index

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

    print("\124cFF4DDBFF [6/9] " .. l10n("Updating NPCs") .. "...")
    QuestieDBCompiler:CompileNPCs()
    print("\124cFF4DDBFF [7/9] " .. l10n("Updating objects") .. "...")
    QuestieDBCompiler:CompileObjects()
    print("\124cFF4DDBFF [8/9] " .. l10n("Updating quests") .. "...")
    QuestieDBCompiler:CompileQuests()
    print("\124cFF4DDBFF [9/9] " .. l10n("Updating items") .. "...")
    QuestieDBCompiler:CompileItems()
    print("\124cFFAAEEFF"..l10n("Questie DB update complete!"))

    Questie.db.global.dbCompiledOnVersion = QuestieLib:GetAddonVersionString()
    Questie.db.global.dbCompiledLang = (Questie.db.global.questieLocaleDiff and Questie.db.global.questieLocale or GetLocale())
    Questie.db.global.dbIsCompiled = true
    Questie.db.global.dbCompiledCount = (Questie.db.global.dbCompiledCount or 0) + 1
end

function QuestieDBCompiler:ValidateNPCs()
    local validator = QuestieDBCompiler:GetDBHandle(Questie.db.global.npcBin, Questie.db.global.npcPtrs, QuestieDBCompiler:BuildSkipMap(QuestieDB.npcCompilerTypes, QuestieDB.npcCompilerOrder))

    local count = 0
    for npcId, nonCompiledData in pairs(QuestieDB.npcData) do
        local compiledData = validator.QueryValidator(npcId, QuestieDB.npcCompilerOrder)

        for id, key in pairs(QuestieDB.npcCompilerOrder) do
            local a = compiledData[id]
            local b = nonCompiledData[QuestieDB.npcKeys[key]]

            if type(a) == "number"  and abs(a-(b or 0)) > 0.2 then
                Questie:Warning("Nonmatching number at " .. key .. "  " .. tostring(a) .. " ~= " .. tostring(b) .. " for ID: ".. npcId)
                return
            elseif type(a) == "string" and a ~= (b or "") then
                Questie:Warning("Nonmatching string at " .. key .. "  " .. tostring(a) .. " ~= " .. tostring(b) .. " for ID: ".. npcId)
                return
            elseif type(a) == "table" then
                if not equals(a, (b or {})) then
                    Questie:Warning("Nonmatching table at " .. key .. "  " .. id .. " for ID: ".. npcId)
                    DevTools_Dump({
                        ["Compiled Table:"] = a,
                        ["Base Table:"] = b
                    })
                    return
                end
            end
        end

        if count == TICKS_PER_YIELD_DEBUG then
            count = 0
            coroutine.yield()
        end
        count = count + 1
    end

    validator.stream:finished()
    print(Questie.DEBUG_INFO, "Finished NPCs validation without issues!")
end

function QuestieDBCompiler:ValidateObjects()
    local validator = QuestieDBCompiler:GetDBHandle(Questie.db.global.objBin, Questie.db.global.objPtrs, QuestieDBCompiler:BuildSkipMap(QuestieDB.objectCompilerTypes, QuestieDB.objectCompilerOrder))

    local count = 0
    for objectId, nonCompiledData in pairs(QuestieDB.objectData) do
        local compiledData = validator.QueryValidator(objectId, QuestieDB.objectCompilerOrder)

        for id, key in pairs(QuestieDB.objectCompilerOrder) do
            local a = compiledData[id]
            local b = nonCompiledData[QuestieDB.objectKeys[key]]

            if type(a) == "number"  and abs(a-(b or 0)) > 0.2 then
                Questie:Warning("Nonmatching number at " .. key .. "  " .. tostring(a) .. " ~= " .. tostring(b) .. " for ID: ".. objectId)
                return
            elseif type(a) == "string" and a ~= (b or "") then
                Questie:Warning("Nonmatching string at " .. key .. "  " .. tostring(a) .. " ~= " .. tostring(b) .. " for ID: ".. objectId)
                return
            elseif type(a) == "table" then
                if not equals(a, (b or {})) then
                    Questie:Warning("Nonmatching table at " .. key .. "  " .. id  .. " for ID: ".. objectId)
                    DevTools_Dump({
                        ["Compiled Table:"] = a,
                        ["Base Table:"] = b
                    })
                    return
                end
            end
        end

        if count == TICKS_PER_YIELD_DEBUG then
            count = 0
            coroutine.yield()
        end
        count = count + 1
    end

    validator.stream:finished()
    print(Questie.DEBUG_INFO, "Finished objects validation without issues!")
end


function QuestieDBCompiler:ValidateItems()
    local validator = QuestieDBCompiler:GetDBHandle(Questie.db.global.itemBin, Questie.db.global.itemPtrs, QuestieDBCompiler:BuildSkipMap(QuestieDB.itemCompilerTypes, QuestieDB.itemCompilerOrder))
    local obj = QuestieDBCompiler:GetDBHandle(Questie.db.global.objBin, Questie.db.global.objPtrs, QuestieDBCompiler:BuildSkipMap(QuestieDB.objectCompilerTypes, QuestieDB.objectCompilerOrder))
    local npc = QuestieDBCompiler:GetDBHandle(Questie.db.global.npcBin, Questie.db.global.npcPtrs, QuestieDBCompiler:BuildSkipMap(QuestieDB.npcCompilerTypes, QuestieDB.npcCompilerOrder))

    local count = 0
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
        --        if type(a) == "number"  and abs(a-(b or 0)) > 0.2 then
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
        if count == TICKS_PER_YIELD_DEBUG then
            count = 0
            coroutine.yield()
        end
        count = count + 1
    end
    count = 0
    for itemId, nonCompiledData in pairs(QuestieDB.itemData) do
        local compiledData = validator.QueryValidator(itemId, QuestieDB.itemCompilerOrder)

        for id, key in pairs(QuestieDB.itemCompilerOrder) do
            local a = compiledData[id]
            local b = nonCompiledData[QuestieDB.itemKeys[key]]

            if type(a) == "number"  and abs(a-(b or 0)) > 0.2 then
                Questie:Warning("Nonmatching number at " .. key .. "  " .. tostring(a) .. " ~= " .. tostring(b) .. " for ID: ".. itemId)
                return
            elseif type(a) == "string" and a ~= (b or "") then
                Questie:Warning("Nonmatching string at " .. key .. "  " .. tostring(a) .. " ~= " .. tostring(b) .. " for ID: ".. itemId)
                return
            elseif type(a) == "table" then
                if not equals(a, (b or {})) then
                    Questie:Warning("Nonmatching table at " .. key .. "  " .. id  .. " for ID: ".. itemId)
                    DevTools_Dump({
                        ["Compiled Table:"] = a,
                        ["Base Table:"] = b
                    })
                    return
                end
            end
        end

        if count == TICKS_PER_YIELD_DEBUG then
            count = 0
            coroutine.yield()
        end
        count = count + 1
    end

    validator.stream:finished()
    obj.stream:finished()
    npc.stream:finished()
    print(Questie.DEBUG_INFO, "Finished items validation without issues!")
end

function QuestieDBCompiler:ValidateQuests()
    local validator = QuestieDBCompiler:GetDBHandle(Questie.db.global.questBin, Questie.db.global.questPtrs, QuestieDBCompiler:BuildSkipMap(QuestieDB.questCompilerTypes, QuestieDB.questCompilerOrder))

    local playerLevel = UnitLevel("player")

    --! IF YOU SEE THIS FUNCTION REMOVE IT AND CHANGE IT TO QUESTIELIB FUNCTION INSTEAD
    local function getTbcLevel(questLevel, requiredLevel, playerLevel)
        if (questLevel == -1) then
            local level = playerLevel
            if (requiredLevel > level) then
                questLevel = requiredLevel;
            else
                questLevel = level;
                -- We also set the requiredLevel to the player level so the quest is not hidden without "show low level quests"
                requiredLevel = level;
            end
        end
        return questLevel, requiredLevel
    end

    -- We now only compare the nonCompiled data and the compiled data without overrides, it'll have to do.
    local count = 0
    for questId, nonCompiledData in pairs(QuestieDB.questData) do
        local compiledData = validator.QueryValidator(questId, QuestieDB.questCompilerOrder)

        for id,key in pairs(QuestieDB.questCompilerOrder) do
            local a = compiledData[id]
            local b = nonCompiledData[QuestieDB.questKeys[key]]

            --Special case for questLevel
            if (Questie.IsTBC or Questie.IsWotlk) and (key == "questLevel" or key == "requiredLevel") then
                local questLevel, requiredLevel = getTbcLevel(compiledData[2], compiledData[1], playerLevel)
                if (key == "questLevel") then
                    a = questLevel
                elseif (key == "requiredLevel") then
                    a = requiredLevel
                end
                questLevel, requiredLevel = getTbcLevel(nonCompiledData[QuestieDB.questKeys["questLevel"]], nonCompiledData[QuestieDB.questKeys["requiredLevel"]], playerLevel)
                if (key == "questLevel") then
                    b = questLevel
                elseif (key == "requiredLevel") then
                    b = requiredLevel
                end
            end

            -- if key == "extraObjectives" then
            --     -- Do nothing
            -- else
            if type(a) == "number"  and abs(a-(b or 0)) > 0.2 then
                Questie:Warning("Nonmatching number at " .. key .. "  " .. tostring(a) .. " ~= " .. tostring(b) .. " for ID: ".. questId)
                return
            elseif type(a) == "string" and a ~= (b or "") then
                Questie:Warning("Nonmatching string at " .. key .. "  " .. tostring(a) .. " ~= " .. tostring(b) .. " for ID: ".. questId)
                return
            elseif type(a) == "table" then
                --? This is kind of stupid, but because the compiler always has to write a int24 it will always write 0 for empty tables
                --? So we have to emulate the same behavior here
                if key == "extraObjectives" then
                    for i = 1, #b do
                        if not b[i][4] and a[i][4] == 0 then
                            b[i][4] = 0
                        end
                    end
                end

                if not equals(a, (b or {})) then
                    Questie:Warning("Nonmatching table at " .. key .. "  " .. id .. " for ID: ".. questId)
                    DevTools_Dump({
                        ["Compiled Table:"] = a,
                        ["Base Table:"] = b
                    })
                    return
                end
            end
        end

        if count == TICKS_PER_YIELD_DEBUG then
            count = 0
            coroutine.yield()
        end
        count = count + 1
    end

    validator.stream:finished()
    print(Questie.DEBUG_INFO, "Finished quests validation without issues!")
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
        ---@param id QuestId|ObjectId|ItemId|NpcId
        ---@param key string
        ---@return any
        handle.QuerySingle = function(id, key)
            local override = overrides[id]
            if override then
                local kti = keyToRootIndex[key]
                if kti and override[kti] ~= nil then return override[kti] end
            end
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
                    skippers[types[indexToKey[i]]](stream)
                    -- readers[types[indexToKey[i]]](stream)
                end
            end
            return readers[types[key]](stream)
        end
        ---@param id QuestId|ObjectId|ItemId|NpcId
        ---@param keys string[]
        ---@return table|nil
        handle.Query = function(id, keys)
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
                            skippers[types[indexToKey[i]]](stream)
                        end
                    end
                    ret[index] = readers[types[key]](stream)
                end
            end
            return ret -- do not unpack the returned table
        end
        ---@param id QuestId|ObjectId|ItemId|NpcId
        ---@param keys string[]
        ---@return table|nil
        handle.QueryValidator = function(id, keys)
            local ptr = pointers[id]
            local override = overrides[id]
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
                            local beforeSkipper = stream._pointer
                            skippers[types[indexToKey[i]]](stream)
                            local afterSkipper = stream._pointer
                            stream._pointer = beforeSkipper
                            readers[types[indexToKey[i]]](stream)
                            local afterReader = stream._pointer
                            if(afterSkipper ~= afterReader) then
                                Questie:Error("ERROR: Skipper and reader did not match for key: " .. key, afterSkipper, afterReader, afterReader-afterSkipper)
                                return nil
                            end
                        end
                    end
                    ret[index] = readers[types[key]](stream)
                end
            end
            return ret -- do not unpack the returned table
        end
    else
        handle.QuerySingle = function(id, key)
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
                    skippers[types[indexToKey[i]]](stream)
                    -- readers[types[indexToKey[i]]](stream)
                end
            end
            return readers[types[key]](stream)
        end
        ---@param id QuestId|ObjectId|ItemId|NpcId
        ---@param keys string[]
        ---@return table|nil
        handle.Query = function(id, keys)
            local ptr = pointers[id]
            if not ptr then
                --print("Entry not found! " .. id)
                return nil
            end
            local ret = {}
            for index=1,#keys do
                local key = keys[index]
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
                        skippers[types[indexToKey[i]]](stream)
                    end
                end
                ret[index] = readers[types[key]](stream)
            end
            return ret -- do not unpack the returned table
        end
        ---@param id QuestId|ObjectId|ItemId|NpcId
        ---@param keys string[]
        ---@return table|nil
        handle.QueryValidator = function(id, keys)
            local ptr = pointers[id]
            if not ptr then
                --print("Entry not found! " .. id)
                return nil
            end
            local ret = {}
            for index=1,#keys do
                local key = keys[index]
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
                        local beforeSkipper = stream._pointer
                        skippers[types[indexToKey[i]]](stream)
                        local afterSkipper = stream._pointer
                        stream._pointer = beforeSkipper
                        readers[types[indexToKey[i]]](stream)
                        local afterReader = stream._pointer
                        if(afterSkipper ~= afterReader) then
                            Questie:Error("ERROR: Skipper and reader did not match for key: " .. key, afterSkipper, afterReader, afterReader-afterSkipper)
                            return nil
                        end
                    end
                end
                ret[index] = readers[types[key]](stream)
            end
            return ret -- do not unpack the returned table
        end
    end

    handle.pointers = pointers

    return handle
end
