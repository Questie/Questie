-- this is a small utility built on top of QuestieSerializer to provide "compressed" read-only tables.
-- table data is serialized to a string without indexes, and using a pointer map its possible to
-- dezerialize an entry from the table without deserializing the whole table
-- this is useful for large databases like the quest and NPC spawn databases.


---@class CompressedTable
local QuestieCompressedTable = QuestieLoader:CreateModule("CompressedTable")
local QuestieSerializer = QuestieLoader:ImportModule("QuestieSerializer"):Clone("raw")

function QuestieCompressedTable:Load(data, pointers)
    local ret = {}
    local serial = QuestieSerializer:Clone("raw")
    serial.stream._bin = data
    serial.stream._pointer = 1
    ret.serial = serial
    ret.stream = serial.stream
    if type(pointers) == "string" then
        QuestieSerializer:SetupStream()
        ret.pointers = QuestieSerializer:Deserialize(pointers)
        local cnt = 0
        for k,v in pairs(ret.pointers) do
            cnt = cnt + 1
        end
    else
        ret.pointers = pointers
    end
    ret.data = data

    ret.GetTable = function(self)
        local meta = setmetatable({}, {
            __index = function(table, key) 
                if not key then return nil end
                if self.pointers[key] then 
                    self.stream._pointer = self.pointers[key]
                    local val = self.serial:ReadObject()
                    rawset(table, key, val)
                    return val
                else 
                    return nil
                end
            end
        })
        
        return meta
    end
    return ret
end



function QuestieCompressedTable:Compile(toCompile)
    local serial = QuestieSerializer:Clone("raw")
    serial.objectCount = 0 
    serial:SetupStream()
    local pointerMap = {}

    for key, value in pairs(toCompile) do
        pointerMap[key] = serial.stream._pointer
        serial.WriterTable[type(value)](serial, value)
    end

    local data = serial.stream:Save()
    serial:SetupStream()
    return data, serial:Serialize(pointerMap)
end


local function table_eq(table1, table2, nmtm)
    if not nmtm then nmtm = "Nonmatching table at " end
    if (not table1) and (not table2) then return true end
    if (not table1) or not table2 then 
        local cnt = 0
        if not table1 then 
            for k,v in pairs(table2) do 
                print(tostring(k) .. " = " .. tostring(v))
                cnt = cnt + 1
            end
        else
            for k,v in pairs(table1) do 
                print(tostring(k) .. " = " .. tostring(v))
                cnt = cnt + 1
            end
        end
        if cnt == 0 then return true end
        return false 
    end
    for k,v in pairs(table1) do
        if type(v) == "number"  and math.abs(v-table2[k]) > 0.2 then print("Nonmatching at " .. k .. "  " .. tostring(v) .. " ~= " .. tostring(table2[k]))return false 
        elseif type(v) == "string" and v ~= table2[k] then print("Nonmatching at " .. k .. "  " .. tostring(v) .. " ~= " .. tostring(table2[k]))return false
        elseif type(v) == "table" then if not table_eq(v, table2[k], "Child " .. nmtm) then print(nmtm .. k)return false end end
    end
    return true  
end 

function __test_serial()
    --local data, pointers = QuestieCompressedTable:Compile(npcData) -- serializer
    local data, pointers = QuestieCompressedTable:CompileNPCs(npcData)
    local decoded = QuestieCompressedTable:Load(data, pointers)
    CompressedHeightmaps = {}
    CompressedHeightmaps.npc = {}
    CompressedHeightmaps.npc.data = data
    CompressedHeightmaps.npc.pointers = pointers
    local count = 0
    for _ in pairs(npcData) do count = count + 1 end
    local function DynamicHashTableSize(entries)
        if (entries == 0) then
          return 36;
        else
          return math.pow(2, math.ceil(math.log(entries) / math.log(2))) * 40 + 36;
        end
    end
    print("Pointermap size: " .. tostring(DynamicHashTableSize(count)))

    print("Data size: " .. tostring(string.len(data)))
    print("Total size: " .. tostring(DynamicHashTableSize(count)+string.len(data)))
    
    decoded.GetTable = QuestieCompressedTable.GetNPCsTable
    decoded = decoded:GetTable()

    for key, value in pairs(npcData) do
        local decVal = decoded[key]
        local result = table_eq(value, decVal)
        if not result then
            print("Checked " .. tostring(key) .. " " .. tostring(result))
        end
    end
end



-- custom io functions for questie db efficiency
function QuestieCompressedTable:CompileNPCs(toCompile)
    local serial = QuestieSerializer:Clone("raw")
    serial.objectCount = 0 
    serial:SetupStream()
    local pointerMap = {}

    local npcKeys = {
        ['name'] = 1, -- string
        ['minLevelHealth'] = 2, -- int
        ['maxLevelHealth'] = 3, -- int
        ['minLevel'] = 4, -- int
        ['maxLevel'] = 5, -- int
        ['rank'] = 6, -- int, see https://github.com/cmangos/issues/wiki/creature_template#rank
        ['spawns'] = 7, -- table {[zoneID(int)] = {coordPair(floatVector2D),...},...}
        ['waypoints'] = 8, -- table {[zoneID(int)] = {coordPair(floatVector2D),...},...}
        ['zoneID'] = 9, -- guess as to where this NPC is most common
        ['questStarts'] = 10, -- table {questID(int),...}
        ['questEnds'] = 11, -- table {questID(int),...}
        ['factionID'] = 12, -- int, see https://github.com/cmangos/issues/wiki/FactionTemplate.dbc
        ['friendlyToFaction'] = 13, -- string, Contains "A" and/or "H" depending on NPC being friendly towards those factions. nil if hostile to both.
    }

    local write = function(stream, value) -- I tried to make the code for this as clean as possible but honestly to be efficient it needs to be a little redundant
        stream:WriteShort(value[npcKeys['factionID']])
        local friendly = value[npcKeys['friendlyToFaction']]
        if friendly then
            if "A" == friendly then
                friendly = 1
            elseif "H" == friendly then
                friendly = 2
            else -- assume AH/neutral
                friendly = 3
            end
        else
            friendly = 0
        end
        stream:WriteByte(friendly)
        stream:WriteShort(value[npcKeys['zoneID']])
        stream:WriteByte(value[npcKeys['minLevel']])
        stream:WriteByte(value[npcKeys['maxLevel']])
        stream:WriteByte(value[npcKeys['rank']])
        stream:WriteInt24(value[npcKeys['minLevelHealth']])
        stream:WriteInt24(value[npcKeys['maxLevelHealth']])
        stream:WriteTinyString(value[npcKeys['name']] or "")
        local questList = value[npcKeys['questStarts']]
        if questList then
            local count = 0 for _ in pairs(questList) do count = count + 1 end
            stream:WriteByte(count)
            for _, value in pairs(questList) do
                stream:WriteShort(value)
            end
        else
            stream:WriteByte(0)
        end
        questList = value[npcKeys['questEnds']]
        if questList then
            local count = 0 for _ in pairs(questList) do count = count + 1 end
            stream:WriteByte(count)
            for _, value in pairs(questList) do
                stream:WriteShort(value)
            end
        else
            stream:WriteByte(0)
        end
        local spawns = value[npcKeys['spawns']]
        if spawns then
    
            -- prune spawns
            for index, spawn in pairs(spawns) do
                if spawn[1][1] == -1 then
                    spawns[index] = nil
                end
            end
    
            local count = 0 for _ in pairs(spawns) do count = count + 1 end
            stream:WriteByte(count)
            for zone, list in pairs(spawns) do
                local listCount = 0 for _ in pairs(list) do listCount = listCount + 1 end
                stream:WriteShort(listCount)
                for _, spawn in pairs(list) do
                    stream:WriteInt12Pair(math.floor(spawn[1] * 40.90), math.floor(spawn[2] * 40.90))
                    --stream:WriteShort(math.floor(spawn[1] * 655.30))
                    --stream:WriteShort(math.floor(spawn[2] * 655.30))
                end
                stream:WriteShort(zone)
            end
        else
            stream:WriteByte(0)
        end
        spawns = value[npcKeys['waypoints']]
        if spawns then
            -- prune spawns
            for index, spawn in pairs(spawns) do
                if spawn[1][1] == -1 then
                    spawns[index] = nil
                end
            end
            local count = 0 for _ in pairs(spawns) do count = count + 1 end
            stream:WriteByte(count)
            for zone, list in pairs(spawns) do
                local listCount = 0 for _ in pairs(list) do listCount = listCount + 1 end
                stream:WriteShort(listCount)
                for _, spawn in pairs(list) do
                    stream:WriteInt12Pair(math.floor(spawn[1] * 40.90), math.floor(spawn[2] * 40.90))
                    --stream:WriteShort(math.floor(spawn[1] * 655.30))
                    --stream:WriteShort(math.floor(spawn[2] * 655.30))
                end
                stream:WriteShort(zone)
            end
        else
            stream:WriteByte(0)
        end
    end

    for key, value in pairs(toCompile) do
        pointerMap[key] = serial.stream._pointer
        write(serial.stream, value)
    end

    local data = serial.stream:Save()
    serial:SetupStream()
    return data, serial:Serialize(pointerMap)
end




function QuestieCompressedTable:GetNPCsTable()
    local npcKeys = {
        ['name'] = 1, -- string
        ['minLevelHealth'] = 2, -- int
        ['maxLevelHealth'] = 3, -- int
        ['minLevel'] = 4, -- int
        ['maxLevel'] = 5, -- int
        ['rank'] = 6, -- int, see https://github.com/cmangos/issues/wiki/creature_template#rank
        ['spawns'] = 7, -- table {[zoneID(int)] = {coordPair(floatVector2D),...},...}
        ['waypoints'] = 8, -- table {[zoneID(int)] = {coordPair(floatVector2D),...},...}
        ['zoneID'] = 9, -- guess as to where this NPC is most common
        ['questStarts'] = 10, -- table {questID(int),...}
        ['questEnds'] = 11, -- table {questID(int),...}
        ['factionID'] = 12, -- int, see https://github.com/cmangos/issues/wiki/FactionTemplate.dbc
        ['friendlyToFaction'] = 13, -- string, Contains "A" and/or "H" depending on NPC being friendly towards those factions. nil if hostile to both.
    }
    local addressTable = {
        [npcKeys['factionID']] = 0,
        [npcKeys['friendlyToFaction']] = 2,
        [npcKeys['zoneID']] = 3, 
        [npcKeys['minLevel']] = 5, 
        [npcKeys['maxLevel']] = 6, 
        [npcKeys['rank']] = 7, 
        [npcKeys['minLevelHealth']] = 8,
        [npcKeys['maxLevelHealth']] = 11,
    }
    local table16bit = {
        [npcKeys['factionID']] = true,
        [npcKeys['zoneID']] = true, 
    }
    local table24bit = {
        [npcKeys['minLevelHealth']] = true,
        [npcKeys['maxLevelHealth']] = true,
    }
    local readVal = function(self, index)
        -- skip ahead to the right address
        local stream = self.stream
        local toskip = addressTable[index]
        if index == npcKeys['friendlyToFaction'] then 
            stream._pointer = stream._pointer + toskip
            local val = stream:ReadByte()
            if val == 3 then
                return "AH"
            elseif val == 2 then 
                return "H"
            elseif val == 1 then 
                return "A"
            else
                return nil
            end
        elseif toskip then
            stream._pointer = stream._pointer + toskip
            if table24bit[index] then
                return stream:ReadInt24()
            elseif table16bit[index] then
                return stream:ReadShort()
            else
                return stream:ReadByte()
            end
        else
            -- varible size data section
            stream._pointer = stream._pointer + 14
            if index == npcKeys["name"] then
                return stream:ReadTinyString()
            elseif index == npcKeys["questStarts"] then
                toskip = stream:ReadByte() -- length of name
                stream._pointer = stream._pointer + toskip
    
                local questTable = {}
                local count = stream:ReadByte() 
                if count == 0 then return nil end
                for i=1,count do 
                    tinsert(questTable, stream:ReadShort())
                end
                return questTable
            elseif index == npcKeys["questEnds"] then
                toskip = stream:ReadByte() -- length of name
                stream._pointer = stream._pointer + toskip
    
                toskip = stream:ReadByte() -- length of questStarts
                stream._pointer = stream._pointer + toskip * 2
    
                local questTable = {}
                local count = stream:ReadByte() 
                if count == 0 then return nil end
                for i=1,count do 
                    tinsert(questTable, stream:ReadShort())
                end
                return questTable
            elseif index == npcKeys["spawns"] then
                toskip = stream:ReadByte() -- length of name
                stream._pointer = stream._pointer + toskip
    
                toskip = stream:ReadByte() -- length of questStarts
                stream._pointer = stream._pointer + toskip * 2
    
                toskip = stream:ReadByte() -- length of questEnds
                stream._pointer = stream._pointer + toskip * 2
    
                local spawnCount = stream:ReadByte()
                if spawnCount == 0 then return nil end
                local spawnTable = {}
                for i=1,spawnCount do
                    local list = {}
                    local listCount = stream:ReadShort()
                    for e=1,listCount do
                        local x, y = stream:ReadInt12Pair()
                        tinsert(list, {x/40.90, y / 40.90})--tinsert(list, {stream:ReadShort()/655.30, stream:ReadShort() / 655.30})
                    end
                    spawnTable[stream:ReadShort()] = list
                end
                return spawnTable
            elseif index == npcKeys["waypoints"] then
                toskip = stream:ReadByte() -- skip past name
                stream._pointer = stream._pointer + toskip
    
                toskip = stream:ReadByte() -- length of questStarts
                stream._pointer = stream._pointer + toskip * 2
    
                toskip = stream:ReadByte() -- length of questEnds
                stream._pointer = stream._pointer + toskip * 2
    
                toskip = stream:ReadByte() -- skip past spawns
                for i=1,toskip do
                    local listCount = stream:ReadShort()
                    stream._pointer = stream._pointer + listCount*3 + 2
                end
    
                local spawnCount = stream:ReadByte()
                if spawnCount == 0 then return nil end
                local spawnTable = {}
                for i=1,spawnCount do
                    local list = {}
                    local listCount = stream:ReadShort()
                    for e=1,listCount do
                        local x, y = stream:ReadInt12Pair()
                        tinsert(list, {x/40.90, y / 40.90})--tinsert(list, {stream:ReadShort()/655.30, stream:ReadShort() / 655.30})
                    end
                    spawnTable[stream:ReadShort()] = list
                end
                return spawnTable
            end
        end
    end
    --UIParentLoadAddOn("Blizzard_DebugTools")
    local meta = setmetatable({}, {
        -- "This is a very commonly used and versatile metamethod, it lets you run a custom function or use a "fallback" table if a 
        --   key in a table doesn't exist. If a function is used, its first parameter will be the table that the lookup failed on, 
        --   and the second parameter will be the key. If a fallback table is used, remember that it can trigger an 
        --   __index metamethod on it if it has one, so you can create long chains of fallback tables."
        __index = function(table, key) 
            if not key then return nil end
            if self.pointers[key] then 
                local ret = setmetatable({}, {
                    __index = function(subTable, subKey)
                        self.stream._pointer = self.pointers[key]
                        local val = readVal(self, subKey)
                        if type(val) == "table" then 
                            --print("Got " .. subKey .. ": " )
                            --___DEBUG_GLOBAL = val
                            --DevTools_DumpCommand("___DEBUG_GLOBAL")
                        else
                            --print("Got " .. subKey .. ": " .. tostring(val))
                        end
                        
                        rawset(subTable, subKey, val)
                        return val
                    end
                })
                rawset(table, key, ret)
                return ret
            else 
                return nil
            end
        end
    })
    
    return meta
end






