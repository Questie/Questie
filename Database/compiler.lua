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

local type, next = type, next
local coYield = coroutine.yield
local min, floor = math.min, math.floor
local InCombatLockdown = InCombatLockdown

-- this variable defines how many operations to run (batched at a time) before yielding for a frame.
-- 1 would mean yielding every operation (so lower = slower but less lag)
-- this variable is not a hard limit when invoked, but rather a guideline;
-- each code block may put a modifier on it, for instance 10x  if the loop is lightweight
local TICKS_PER_YIELD = 60

if Questie.IsHardcore then
    -- The addon timing restrictions from the Blizzard watchdog are much higher for HC servers.
    -- Therefore we need a quite low tick rate to make sure we don't get bitten on less performant machines.
    TICKS_PER_YIELD = 30
end

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
---| "u8s24array"
---| "u16u24array"
---| "u8u16stringarray"
---| "faction"
---| "spawnlist"
---| "trigger"
---| "questgivers"
---| "objective"
---| "spellobjective"
---| "objectives"
---| "reflist"
---| "extraobjective

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
readers["u8s24array"] = function(stream)
    local count = stream:ReadByte()
    if count == 0 then return nil end

    local list = {}
    for i = 1, count do
        list[i] = stream:ReadInt24() - 8388608
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
            local phase = stream:ReadShort()
            if x == 0 and y == 0 then
                list[i] = {-1, -1}
            elseif phase == 0 then
                list[i] = {x / 40.90, y / 40.90}
            else
                list[i] = {x / 40.90, y / 40.90, phase}
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
        ret[i] = {stream:ReadInt24(), stream:ReadTinyStringNil(), stream:ReadByte()}
    end
    return ret
end
readers["spellobjective"] = function(stream)
    local count = stream:ReadByte()
    if count == 0 then return nil end

    local ret = {}
    for i = 1, count do
        ret[i] = {stream:ReadInt24(), stream:ReadTinyStringNil(), stream:ReadInt24()}
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
        ret[5] = nil
    else
        local killobjectives = {}
        for i=1, count do
            local creditCount = stream:ReadByte()
            local creditList = {}
            for j=1, creditCount do
                creditList[j] = stream:ReadInt24()
            end
            killobjectives[i] = {creditList, stream:ReadInt24(), stream:ReadTinyStringNil(), stream:ReadByte()}
        end
        ret[5] = killobjectives
    end

    ret[6] = readers["spellobjective"](stream)

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
    ["u8s24array"] = function(stream, value)
        if value then
            local count = 0 for _ in pairs(value) do count = count + 1 end
            stream:WriteByte(count)
            for _,v in pairs(value) do
                stream:WriteInt24(v + 8388608)
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
        elseif "" == value then
            stream:WriteByte(3)
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
                    stream:WriteShort(spawn[3] or 0) -- spawn phase
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
                stream:WriteByte(pair[3] or 0)
            end
        else
            stream:WriteByte(0)
        end
    end,
    ["spellobjective"] = function(stream, value)
        if value then
            local count = 0 for _ in pairs(value) do count = count + 1 end
            stream:WriteByte(count)
            for _, data in pairs(value) do
                stream:WriteInt24(data[1])
                stream:WriteTinyString(data[2] or "")
                stream:WriteInt24(data[3] or 0)
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

                    stream:WriteByte(#npcIds) -- write count of creatureIDs
                    for j=1, #npcIds do
                        stream:WriteInt24(npcIds[j]) -- write creatureID
                    end
                    stream:WriteInt24(killobjective[2]) -- write baseCreatureID
                    stream:WriteTinyString(killobjective[3] or "") -- write baseCreatureText
                    stream:WriteByte(killobjective[4] or 0) -- write icon override index
                end
            else
                stream:WriteByte(0)
            end

            QuestieDBCompiler.writers["spellobjective"](stream, value[6])
        else
            --print("Missing objective table for " .. QuestieDBCompiler.currentEntry)
            stream:WriteByte(0)
            stream:WriteByte(0)
            stream:WriteByte(0)
            stream:WriteInt24(0)
            stream:WriteInt24(0)
            stream:WriteByte(0)
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
skippers["u8s24array"] = function(stream) stream._pointer = stream:ReadByte() * 3 + stream._pointer end
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
        -- Skip over the 5 bytes of each spawn
        -- 3 bytes for the spawn-pair of 12-bit integers and 2 byte for the phase
        stream._pointer = stream:ReadShort() * 5 + stream._pointer
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
        stream._pointer = stream._pointer + 1
    end
end
skippers["spellobjective"] = function(stream)
    local count = stream:ReadByte()
    for _=1,count do
        stream._pointer = stream._pointer + 3
        stream._pointer = stream:ReadByte() + stream._pointer
        stream._pointer = stream._pointer + 3
    end
end
local objectiveSkipper = skippers["objective"]
local spellObjectiveSkipper = skippers["spellobjective"]
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
            stream._pointer = stream._pointer + 1
        end
    end
    spellObjectiveSkipper(stream)
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
    ["u8s24array"] = true,
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
    local entriesPerTick = Questie.IsHardcore and 80 or nil

    QuestieDBCompiler:CompileTableCoroutine(QuestieDB.npcData, QuestieDB.npcCompilerTypes, QuestieDB.npcCompilerOrder, QuestieDB.npcKeys, "npc", "NPC", entriesPerTick)
end

function QuestieDBCompiler:CompileObjects()
    local entriesPerTick = Questie.IsHardcore and 80 or nil

    QuestieDBCompiler:CompileTableCoroutine(QuestieDB.objectData, QuestieDB.objectCompilerTypes, QuestieDB.objectCompilerOrder, QuestieDB.objectKeys, "obj", "Object", entriesPerTick)
end

function QuestieDBCompiler:CompileQuests()
    local entriesPerTick = Questie.IsHardcore and 25 or 50
    if Questie.db.profile.debugEnabled then
        entriesPerTick = nil
    end

    QuestieDBCompiler:CompileTableCoroutine(QuestieDB.questData, QuestieDB.questCompilerTypes, QuestieDB.questCompilerOrder, QuestieDB.questKeys, "quest", "Quest", entriesPerTick)
end

function QuestieDBCompiler:CompileItems()
    local entriesPerTick = Questie.IsHardcore and 100 or 150
    if Questie.db.profile.debugEnabled then
        entriesPerTick = nil
    end

    QuestieDBCompiler:CompileTableCoroutine(QuestieDB.itemData, QuestieDB.itemCompilerTypes, QuestieDB.itemCompilerOrder, QuestieDB.itemKeys, "item", "Item", entriesPerTick)
end


function QuestieDBCompiler:EncodePointerMap(stream, pointerMap)
    stream:reset()
    stream:WriteInt24(0) -- placeholder
    local count = 0
    local yieldCount = 0
    for id, ptrs in pairs(pointerMap) do
        stream:WriteInt24(id)
        stream:WriteInt24(ptrs)
        count = count + 1
        yieldCount = yieldCount + 1
        if yieldCount >= (TICKS_PER_YIELD * 100) then
            yieldCount = 0
            coYield()
        end
    end
    stream._pointer = 1
    stream:WriteInt24(count)
    return stream:Save()
end

function QuestieDBCompiler:DecodePointerMap(stream)
    local count = stream:ReadInt24()
    local ret = {}
    local i = 0
    while i < count do
        for _ = 1, min(768, count-i) do -- steps per yield
            ret[stream:ReadInt24()] = stream:ReadInt24()
        end
        i = i + 768
        coYield()
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

    local yieldCount = 0
    for id in pairs(tbl) do
        count = count + 1
        indexLookup[count] = id
        yieldCount = yieldCount + 1
        if yieldCount >= TICKS_PER_YIELD * 100 then
            yieldCount = 0
            coYield()
        end
    end
    table.sort(indexLookup)
    count = count + 1

    local index = 0

    local pointerMap = {}
    local stream = Questie.db.profile.debugEnabled and QuestieStream:GetStream("raw_assert") or QuestieStream:GetStream("raw")

    -- Localize functions
    local writers = QuestieDBCompiler.writers

    -- Pre-compute per-field lookup keys and writers once for the entire compile run.
    -- This removes all string-keyed table lookups from the hot inner loop.
    local fieldCount = #order
    local fieldKeys = {}    -- fieldKeys[i]    = lookup[order[i]]  (raw data field index)
    local fieldWriters = {} -- fieldWriters[i] = writers[types[order[i]]]
    for i = 1, fieldCount do
        local key = order[i]
        local t = types[key]
        if not writers[t] then
            error("Invalid datatype: " .. key .. " " .. tostring(t))
        end
        fieldKeys[i] = lookup[key]
        fieldWriters[i] = writers[t]
    end

    while true do
        coYield()

        local ticks = TICKS_PER_YIELD * 10
        if entriesPerTick then
            ticks = entriesPerTick
        end

        for _ = 0, ticks do
            -- Pause compilation while in combat
            while InCombatLockdown() do
                coYield()
            end

            index = index + 1
            if index == count then
                if Questie.IsSoD then
                    Questie.db.global.sod[databaseKey.."Bin"] = stream:Save()
                    Questie.db.global.sod[databaseKey.."Ptrs"] = QuestieDBCompiler:EncodePointerMap(stream, pointerMap)
                else
                    Questie.db.global[databaseKey.."Bin"] = stream:Save()
                    Questie.db.global[databaseKey.."Ptrs"] = QuestieDBCompiler:EncodePointerMap(stream, pointerMap)
                end
                stream:finished() -- relief memory pressure
                return
            end
            local id = indexLookup[index]

            -- QuestieDBCompiler.currentEntry = id -- This was only ever used for debugging.
            local entry = tbl[id]

            pointerMap[id] = stream._pointer--pointerStart
            for i=1, fieldCount do
                -- If combat starts mid-entry, pause before processing next field
                while InCombatLockdown() do
                    coYield()
                end

                fieldWriters[i](stream, entry[fieldKeys[i]])
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

    local startTime = GetTimePreciseSec()
    QuestieDBCompiler.totalSize = 0

    print("\124cFF4DDBFF [6/9] " .. l10n("Updating NPCs") .. l10n("..."))
    QuestieDBCompiler:CompileNPCs()
    print("\124cFF4DDBFF [7/9] " .. l10n("Updating objects") .. l10n("..."))
    QuestieDBCompiler:CompileObjects()
    print("\124cFF4DDBFF [8/9] " .. l10n("Updating quests") .. l10n("..."))
    QuestieDBCompiler:CompileQuests()
    print("\124cFF4DDBFF [9/9] " .. l10n("Updating items") .. l10n("..."))
    QuestieDBCompiler:CompileItems()
    print("\124cFFAAEEFF"..l10n("Questie DB update complete!"))

    if Questie.db.profile.debugEnabled then
        print("\124cFFAAEEFF" .. "Compiling took " .. (GetTimePreciseSec() - startTime) .. " seconds")
    end

    Questie.db.global.dbCompiledExpansion = WOW_PROJECT_ID

    if Questie.IsSoD then
        Questie.db.global.sod.dbCompiledOnVersion = QuestieLib:GetAddonVersionString()
        Questie.db.global.sod.dbCompiledLang = l10n:GetUILocale()
        Questie.db.global.sod.dbIsCompiled = true
        Questie.db.global.sod.dbCompiledCount = (Questie.db.global.sod.dbCompiledCount or 0) + 1
    else
        Questie.db.global.dbCompiledOnVersion = QuestieLib:GetAddonVersionString()
        Questie.db.global.dbCompiledLang = l10n:GetUILocale()
        Questie.db.global.dbIsCompiled = true
        Questie.db.global.dbCompiledCount = (Questie.db.global.dbCompiledCount or 0) + 1
    end
end

function QuestieDBCompiler:GetDBHandle(data, pointers, skipMap, keyToRootIndex, overrides)
    local handle = {}
    local map, lastIndex, lastPtr, types, _, indexToKey, keyToIndex = unpack(skipMap)

    local stream = QuestieStream:GetStream("raw")
    coYield()
    stream:Load(pointers)
    coYield()
    pointers = QuestieDBCompiler:DecodePointerMap(stream)
    --Questie.db.global.__pointers = pointers
    coYield()
    stream:Load(data)
    handle.stream = stream

    if overrides then
        ---@param id QuestId|ObjectId|ItemId|NpcId|SpellId
        ---@param key string
        ---@return any
        handle.QuerySingle = function(id, key)
            local override = overrides[id]
            if override then
                local kti = keyToRootIndex[key]
                if kti and override[kti] ~= nil then
                    if type(override[kti]) ~= "table" or next(override[kti]) then
                        return override[kti]
                    else
                        -- We want to return nil if the table is empty, to match the compiler behavior
                        return nil
                    end
                end
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
                    Questie.Error("ERROR: Unhandled db key: " .. key)
                    return nil
                end
                for i = lastIndex, targetIndex-1 do
                    skippers[types[indexToKey[i]]](stream)
                    -- readers[types[indexToKey[i]]](stream)
                end
            end
            return readers[types[key]](stream)
        end
        ---@param id QuestId|ObjectId|ItemId|NpcId|SpellId
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
                            Questie.Error("ERROR: Unhandled db key: " .. key)
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
        ---@param id QuestId|ObjectId|ItemId|NpcId|SpellId
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
                            Questie.Error("ERROR: Unhandled db key: " .. key)
                            return nil
                        end
                        for i = lastIndex, targetIndex-1 do
                            local beforeSkipper = stream._pointer
                            skippers[types[indexToKey[i]]](stream)
                            local afterSkipper = stream._pointer
                            stream._pointer = beforeSkipper
                            readers[types[indexToKey[i]]](stream)
                            local afterReader = stream._pointer
                            if (afterSkipper ~= afterReader) then
                                Questie.Error("ERROR: Skipper and reader did not match for key: " .. key, afterSkipper, afterReader, afterReader - afterSkipper)
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
                    Questie.Error("ERROR: Unhandled db key: " .. key)
                    return nil
                end
                for i = lastIndex, targetIndex-1 do
                    skippers[types[indexToKey[i]]](stream)
                    -- readers[types[indexToKey[i]]](stream)
                end
            end
            return readers[types[key]](stream)
        end
        ---@param id QuestId|ObjectId|ItemId|NpcId|SpellId
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
                        Questie.Error("ERROR: Unhandled db key: " .. key)
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
        ---@param id QuestId|ObjectId|ItemId|NpcId|SpellId
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
                        Questie.Error("ERROR: Unhandled db key: " .. key)
                        return nil
                    end
                    for i = lastIndex, targetIndex-1 do
                        local beforeSkipper = stream._pointer
                        skippers[types[indexToKey[i]]](stream)
                        local afterSkipper = stream._pointer
                        stream._pointer = beforeSkipper
                        readers[types[indexToKey[i]]](stream)
                        local afterReader = stream._pointer
                        if (afterSkipper ~= afterReader) then
                            Questie.Error("ERROR: Skipper and reader did not match for key: " .. key, afterSkipper, afterReader, afterReader - afterSkipper)
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
