-- heightmap is a word
---@class QuestieHeightmaps
local QuestieHeightmaps = QuestieLoader:CreateModule("Heightmaps")
local _QuestieHeightmaps = QuestieHeightmaps
---@type QuestieStreamLib
local QuestieStreamLib = QuestieLoader:ImportModule("QuestieStreamLib")
---@type QuestieSerializer
local _QuestieSerializer = QuestieLoader:ImportModule("QuestieSerializer")

local LibDeflate = LibStub:GetLibrary("LibDeflate")



-- info about the heightmap data format (each number is 1 byte)
-- [head metadata]
--    XX XX          chunkSize (16 bit)
--    XX             chunkResDivisor (8 bit)
--
-- [data block] 
--    00           (reserved)
--    01 XX XX     value = XXXX  (16 bit)
--    02 XX XX     value = -XXXX (16 bit)
--    03           invert isInside
--    04 XX        next XX entries are for the current x,y location
--    05 XX        lastValue is repeated XX times
--    above 05     value = lastValue + ((value-5)-120)
--        ... (repeats until map is filled)
--
-- [foot metadata]
--    XX XX XX XX    CRC value (32 bit)



local QuestieSerializer = false
--[[local function SetupSerializer() -- use :Clone("raw")
    -- copy and override stream behavior
    QuestieSerializer = {}
    for k, v in pairs(_QuestieSerializer) do
        QuestieSerializer[k] = v
    end
    QuestieSerializer.stream = nil
    function QuestieSerializer:SetupStream()
        if self.stream then
            self.stream:reset()
        else
            self.stream = QuestieStreamLib:GetStream("raw")
            self.stream.Load = self.stream.LoadRaw
        end
        QuestieSerializer.SerializerHashDB = {}
        QuestieSerializer.SerializerHashDBReversed = {}
    end
    QuestieSerializer:SetupStream()
end]]



QuestieHeightmaps.rawHeightmaps = {}
_QuestieHeightmaps.heightmapIsDecompressed = {} -- used to tell if rawHeightmap is a Deflate compressed string or a raw QuestieSerializer string

-- map[index] = {3, false} or {{-33, false}, {4, true}, {76, false}}. [1] is the height value, [2] is IsInside (!IsOutdoors)
QuestieHeightmaps.loadedTiles = {}




function QuestieHeightmaps:Test()
    local configs = {
        level = 8,
        strategy = "dynamic",
    }
    Questie.db.char.ElwyTestData = LibDeflate:CompressDeflate(QuestieHeightmaps.rawHeightmaps["Elwynn"], configs)
    local decomp = LibDeflate:DecompressDeflate(Questie.db.char.ElwyTestData)
    print("vals: " .. tostring(string.len(QuestieHeightmaps.rawHeightmaps["Elwynn"])) .. " " .. tostring(string.len(Questie.db.char.ElwyTestData)) .. " " .. tostring(string.len(decomp)))
end

function QuestieHeightmaps:Test2()
    if not QuestieSerializer then SetupSerializer() end
    --print(QuestieSerializer:Deserialize("aa"))
    --local a, err = pcall(QuestieSerializer.Deserialize, QuestieSerializer, QuestieHeightmaps.rawHeightmaps["Elwynn"])
    --print(a)
    --print(err)
    local curmap = QuestieSerializer:Deserialize(LibDeflate:DecompressDeflate(Questie.db.char.ElwyTestData))
    for k,v in pairs(curmap) do 
        print(tostring(k) .. " = " .. type(v))
    end
end

function QuestieHeightmaps:SetZone(zone) -- this should decode the heightmap progressively (1 row at a time) instead of the all rows*colums at once
    if not zone then return end
    local raw = QuestieHeightmaps.rawHeightmaps[zone]
    if raw then
        local decompressed, status = LibDeflate:DecompressDeflate(raw)
        if decompressed then
            print("Decompressed size: " .. tostring(string.len(decompressed)))
            return QuestieSerializer:Deserialize(decompressed)
        else
            print("Error decompressing!")
            print(status)
        end
    end
end

--[[
-- accepts float coordinate values (0...1)
function QuestieHeightmaps:CoordinateToIndex(x, y)
    if not QuestieHeightmaps.currentZone or not QuestieHeightmaps.currentZone.resolution then
        return
    end
    return x * QuestieHeightmaps.currentZone.resolutionSquared + y * QuestieHeightmaps.currentZone.resolution
end]]--


-- io
function _QuestieHeightmaps:DecompressTile(x, y)
    if (not x) or (not y) or (not QuestieHeightmaps.rawHeightmaps[x]) or not QuestieHeightmaps.rawHeightmaps[x][y] then
        return -- error?
    end
    QuestieHeightmaps.rawHeightmaps[x][y] = LibDeflate:DecompressDeflate(QuestieHeightmaps.rawHeightmaps[x][y])
    if not _QuestieHeightmaps.heightmapIsDecompressed[x] then
        _QuestieHeightmaps.heightmapIsDecompressed[x] = {}
    end
    _QuestieHeightmaps.heightmapIsDecompressed[x][y] = true
end
function _QuestieHeightmaps:LoadTile(x, y)
    if (not x) or (not y) or (not QuestieHeightmaps.rawHeightmaps[x]) or not QuestieHeightmaps.rawHeightmaps[x][y] then
        return -- error?
    end
    
    if (not _QuestieHeightmaps.heightmapIsDecompressed[x]) or not (_QuestieHeightmaps.heightmapIsDecompressed[x][y]) then
        _QuestieHeightmaps:DecompressTile(x, y)
    end

    if not QuestieSerializer then
        SetupSerializer()
    end

    local data = QuestieSerializer:Deserialize(QuestieHeightmaps.rawHeightmaps[x][y])
    local tile = {}
    local tilex, tiley, divisor, heightOffset = unpack(data[1])
    tile.x = tilex
    tile.y = tiley
    tile.divisor = divisor
    tile.heightOffset = heightOffset -- the average height in the tile, subtract this from the map value to get the true value (optimization)
    tile.map = data[2]
    tile.resolution = math.sqrt(#tile.map)

    tinsert(QuestieHeightmaps.loadedTiles, tile)

end

function _QuestieHeightmaps:RequestLoadTile(x, y)

end

function _QuestieHeightmaps:UnloadFarthestTile()

end




-- testing globals (todo: REFACTOR/REMOVE!!) (see: HM_Test)
function HM_read(serial, length)
    local chunkSize = serial:ReadShort()
    local divisor = serial:ReadByte()
    local map = {}
    local crc = 5381
    local lastValue = 0
    local isInside = false
    local readerContext = {}
    readerContext.crc = crc
    readerContext.map = map
    readerContext.lastValue = lastValue
    readerContext.isInside = isInside
    readerContext.length = length
    readerContext.i = 1
    readerContext.entryCount = chunkSize*chunkSize
    
    function readOne(serial, context, isSubgroup)
        local op = serial:ReadByte()
        if isSubgroup then
            isSubgroup = "(subgroup) "
        else
            isSubgroup = ""
        end
        if op == 3 then
            op = serial:ReadByte()
            print(isSubgroup.."swapping isinside: " .. tostring(context.isInside))
            context.isInside = not context.isInside
        end
        print(isSubgroup.."readop " .. tostring(op) .. " @ " .. context.i .. "/" .. tostring(context.entryCount) .. " (" .. tostring(serial._pointer-1) .. "/"..tostring(context.length))
        if op == 1 then
            context.lastValue = serial:ReadShort()
            --[[crc]]--context.crc = doCRC(context.crc, context.lastValue)
            --[[crc]]--if isInside then context.crc = doCRC(context.crc, 1) end
            return {context.lastValue, context.isInside}
        elseif op == 2 then
            context.lastValue = -serial:ReadShort()
            --[[crc]]--context.crc = doCRC(context.crc, context.lastValue)
            --[[crc]]--if isInside then context.crc = doCRC(context.crc, 1) end
            return {context.lastValue, context.isInside}
        --elseif op == 3 then
        --    print("swapping isinside: " .. tostring(context.isInside))
        --    context.isInside = not context.isInside
        --    return readOne(serial, context)
        elseif op == 4 then
            local subCount = serial:ReadByte()
            print("Doing subgroup size: " .. tostring(subCount))
            local ret = {}
            while subCount > 0 do
                subCount = subCount - 1
                tinsert(ret, readOne(serial, context, true))
            end
            return ret
        elseif op == 5 then
            local rleCount = serial:ReadByte()
            print("RLEing: " .. tostring(rleCount))
            while rleCount > 0 do
                context.map[context.i] = {context.lastValue, context.isInside}
                context.i = context.i + 1
                rleCount = rleCount - 1
            end
            return nil -- we just populated map so dont return anything
        else
            context.lastValue = context.lastValue + (op - 127)
            --[[crc]]--context.crc = doCRC(context.crc, context.lastValue)
            --[[crc]]--if isInside then context.crc = doCRC(context.crc, 1) end
            return {context.lastValue, context.isInside}
        end
    end
    while readerContext.i <= chunkSize*chunkSize do
        local val = readOne(serial, readerContext)
        if val then
            readerContext.map[readerContext.i] = val
            readerContext.i = readerContext.i + 1
        end
    end
    for _,entry in pairs(readerContext.map) do
        if type(entry[1]) == "table" then
            for _, subEntry in pairs(entry) do
                readerContext.crc = doCRC(readerContext.crc, subEntry[1])
                if subEntry[2] then readerContext.crc = doCRC(readerContext.crc, 1) end
            end
        else
            readerContext.crc = doCRC(readerContext.crc, entry[1])
            if entry[2] then readerContext.crc = doCRC(readerContext.crc, 1) end
        end
    end
    local storedCRC = serial:ReadInt()
    print("Finished reading "..tostring(chunkSize*chunkSize).." values with CRC: " .. tostring(readerContext.crc) .. " " .. tostring(storedCRC).. " (" .. tostring(serial._pointer-1) .. "/"..tostring(readerContext.length))
    return readerContext.map
end

function doCRC(crc, values)
    if type(values) == "number" then
        crc = bit.band((31 * crc + values), 4294967295)
    else
        for _,v in pairs(values) do
            crc = bit.band((31 * crc + v), 4294967295)
        end
    end
    return crc
end

local function compressNext2(LibDeflate)
    if __compress_index >= __comperss_end then
        print("Finished compressing!")
        return
    end
    local zone = __compress_map[__compress_index]
    print("Compressing " .. zone)
    C_Timer.After(2, function()
        local zone = __compress_map[__compress_index]
        Questie.db.char.compressedHeightmaps[zone] = LibDeflate:CompressDeflate(QuestieHeightmaps.compressedHeightmaps[zone], configs)
        __compress_index = __compress_index + 1
        print("   result: " .. tostring(string.len(QuestieHeightmaps.compressedHeightmaps[zone])/1024) .. "kb -> " .. tostring(string.len(CompressedHeightmaps[zone])/1024) .. "kb")
        compressNext2(LibDeflate)
    end)
end

__comperss_end = 0
__compress_index = 0
__compress_map = {}
function HM_ActuallyCompress()
    local idx = 1
    local crc = 5381
    __compress_index = 1
    CompressedHeightmaps = {}
    for k,v in pairs(QuestieHeightmaps.compressedHeightmaps) do
        __compress_map[idx] = k
        idx = idx + 1
    end
    __comperss_end = idx - 1
    local LibDeflate = LibStub:GetLibrary("LibDeflate")
    
    compressNext2(LibDeflate)
end

function HM_Test()
    -- re-inflated string from heightmap table (test-uncompressed.lua)
    local toRead = "\000\064\004\003\127\005\255\005\255\005\255\005\255\005\255\005\255\005\255\005\255\005\007\003\002\001\244\005\255\005\255\005\255\005\255\005\255\005\255\005\255\005\255\005\007\237\056\029\005"
    local serial = QuestieLoader:ImportModule("QuestieStreamLib"):GetStream("raw")
    serial:LoadRaw(toRead)
    print("Loaded stream")
    return HM_read(serial, string.len(toRead))--print(pcall(HM_read, serial, string.len(toRead)))--HM_read(serial)
end














-- api
function QuestieHeightmaps:EstimateHeight(x, y, indoors)

end

function QuestieHeightmaps:GetHeights(x, y)

end

function QuestieHeightmaps:EstimatePlayerHeight()

end
