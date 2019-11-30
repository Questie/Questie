-- heightmap is a word
---@class QuestieHeightmaps
local QuestieHeightmaps = QuestieLoader:CreateModule("Heightmaps")
local _QuestieHeightmaps = QuestieHeightmaps.private
---@type QuestieStreamLib
local QuestieStreamLib = QuestieLoader:ImportModule("QuestieStreamLib")
---@type QuestieSerializer
local QuestieSerializer = QuestieLoader:ImportModule("QuestieSerializer"):Clone("raw")

local LibDeflate = LibStub:GetLibrary("LibDeflate")

QuestieHeightmaps.stream = QuestieLoader:ImportModule("QuestieStreamLib"):GetStream("raw")


-- info about the heightmap data format (each number is 1 byte)
-- [head metadata]
--    XX XX          tileSize (16 bit)
--    XX             tileResDivisor (8 bit)
--    XX XX          tileX+32760 (16bit)
--    XX XX          tileY+32760 (16bit)
--
-- [data block]
--  (1 of the following)
--    00             (reserved)
--    01 XX XX       value = XXXX  (16 bit)
--    02 XX XX       value = -XXXX (16 bit)
--    03             invert isInside
--    04 XX          next XX entries are for the current x,y location
--    05 XX          lastValue is repeated XX times
--    above 05       value = lastValue + ((value-5)-120)
--        ... (repeats until map is filled)
--
-- [foot metadata]
--    XX XX XX XX    CRC value (32 bit)


QuestieHeightmaps.rawHeightmaps = {}

-- map[index] = {3, false} or {{-33, false}, {4, true}, {76, false}}. [1] is the height value, [2] is IsInside (!IsOutdoors)
QuestieHeightmaps.loadedTiles = {}
QuestieHeightmaps.queuedToLoad = {}

QuestieHeightmaps.map = -1 -- use QuestieHeightmaps:SetMap

-- used for debugging
_QuestieHeightmaps.goodCRC = 0
_QuestieHeightmaps.badCRC = 0
_QuestieHeightmaps.badCRCList = {}

-- we need to know this value ahead of time so the index can properly be calculated
-- change this if the heightmap data has been regenerated with a different value
-- we could also do load(tiles[0]).tileResDivisor but this is fine for now
QuestieHeightmaps.tileResDivisor = 4

-- io
function _QuestieHeightmaps:DecompressTile(index)
    if (not x) or (not y) or (not QuestieHeightmaps.rawHeightmaps[x]) or not QuestieHeightmaps.rawHeightmaps[x][y] then
        return -- error?
    end
    
end
function _QuestieHeightmaps:LoadTile(index)
    if (not index) or (not QuestieHeightmaps.heightmapPointers[index]) then
        return -- error?
    end 
    local pointers = QuestieHeightmaps.heightmapPointers[index]
    QuestieHeightmaps.stream:LoadRaw(LibDeflate:DecompressDeflate(string.sub(QuestieHeightmaps.heightmapData, pointers[1], pointers[2] + pointers[1])))
    local tile, crcMatched = HM_read(QuestieHeightmaps.stream, string.len(QuestieHeightmaps.stream._bin)) -- refactor

    if crcMatched then
        _QuestieHeightmaps.goodCRC = _QuestieHeightmaps.goodCRC + 1
    else
        _QuestieHeightmaps.badCRC = _QuestieHeightmaps.badCRC + 1
        tinsert(_QuestieHeightmaps.badCRCList, tostring(tile.tileY) .. ".".. tostring(tile.tileX))
        print("BAD CRC DETECTED! " .. tostring(index) .. "(" .. tostring(tile.tileY) .. ".".. tostring(tile.tileX) .. ")")
    end

    QuestieHeightmaps.loadedTiles[index] = tile
    _QuestieHeightmaps:UnloadFarthestTile()
end

function _QuestieHeightmaps:RequestLoadTile(x, y)
    local index = _QuestieHeightmaps:TileToIndex(x, y)
    if QuestieHeightmaps.queuedToLoad[index] or QuestieHeightmaps.loadedTiles[index] then
        return
    end
    QuestieHeightmaps.queuedToLoad[index] = index
end

function _QuestieHeightmaps:UnloadFarthestTile()

end

function _QuestieHeightmaps:TileToIndex(x, y)
    return string.format("%d,%d", x, y) -- todo: convert this to a 1D numeric index (ex. index = x * width + y)
end

function _QuestieHeightmaps:WorldToTile(x, y)
    return x / QuestieHeightmaps.tileResDivisor, y / QuestieHeightmaps.tileResDivisor
end

-- called periodically while the player is moving, it doesn't need to be called very often (once every 10+ seconds)
-- this is used to update the currently loaded tiles
function QuestieHeightmaps:Update()
    local playerX, playerY, _, map = UnitPosition("Player")
    if playerX and playerY and map and map >= 0 and map < 2 then -- we only have data for kalimdor and eastern kingdoms 
        local tileX, tileY = _QuestieHeightmaps:WorldToTile(playerX, playerY)

        -- this checks if the tile is loaded (or queued for load) and if not queues them
        _QuestieHeightmaps:RequestLoadTile(tileX, tileY)
        _QuestieHeightmaps:RequestLoadTile(tileX-1, tileY-1)
        _QuestieHeightmaps:RequestLoadTile(tileX, tileY-1)
        _QuestieHeightmaps:RequestLoadTile(tileX+1, tileY-1)
        _QuestieHeightmaps:RequestLoadTile(tileX-1, tileY)
        _QuestieHeightmaps:RequestLoadTile(tileX+1, tileY)
        _QuestieHeightmaps:RequestLoadTile(tileX-1, tileY+1)
        _QuestieHeightmaps:RequestLoadTile(tileX, tileY+1)
        _QuestieHeightmaps:RequestLoadTile(tileX+1, tileY+1)
    end
end

function QuestieHeightmaps:Initialize()
    C_Timer.NewTicker(1, function() -- we need this in order to only load small chunks of data instead of everything at once
        local index = tremove(QuestieHeightmaps.queuedToLoad, 1)
        if index then
            print("Loading tile " .. index)
            _QuestieHeightmaps:LoadTile(index)
        end
    end)
end



-- tests
function _QuestieHeightmaps:VerifyNext()
    -- todo: remove
    QuestieHeightmaps.loadedTiles = {}
    C_Timer.After(0.001, function()
        _QuestieHeightmaps.verifyIndex = _QuestieHeightmaps.verifyIndex + 1
        if _QuestieHeightmaps.verifyList[_QuestieHeightmaps.verifyIndex] then
            pcall(_QHM.private.LoadTile, _QHM.private, _QuestieHeightmaps.verifyList[_QuestieHeightmaps.verifyIndex])
            HM_SetDisplay(_QuestieHeightmaps.verifyList[_QuestieHeightmaps.verifyIndex])
            _QuestieHeightmaps:VerifyNext()
        else
            print("Finished verify! .. good:" .. _QuestieHeightmaps.goodCRC .. " bad:" .. _QuestieHeightmaps.badCRC)
            Questie.db.char.badCRCList = _QuestieHeightmaps.badCRCList
        end
    end)
end
function _QuestieHeightmaps:Verify(map)
    if not map or map < 0 or map > 1 then
        return
    end
    QuestieHeightmaps:SetMap(map)
    _QuestieHeightmaps.verifyList = {}
    
    --todo: remove
    Questie.db.char.compressedHeightmaps = {}

    local index = 1
    for key in pairs(QuestieHeightmaps.heightmapPointers) do
        _QuestieHeightmaps.verifyList[index] = key
        index = index + 1
    end
    _QuestieHeightmaps.verifyIndex = 0
    _QuestieHeightmaps:VerifyNext()
end









-- testing globals (todo: REFACTOR/REMOVE!!) (see: HM_Test)
_QHM = QuestieHeightmaps
function HM_read(serial, length)
    local tileSize = serial:ReadShort()
    local tileX = serial:ReadShort() - 32760
    local tileY = serial:ReadShort() - 32760
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
    readerContext.entryCount = tileSize*tileSize
    
    local function readOne(serial, context, isSubgroup)
        local op = serial:ReadByte()
        if isSubgroup then
            isSubgroup = "(subgroup) "
        else
            isSubgroup = ""
        end
        if context.isInside then
            isSubgroup = isSubgroup .. " (Inside)"
        end
        if op == 3 then
            op = serial:ReadByte()
            --print(isSubgroup.."swapping isinside: " .. tostring(context.isInside))
            context.isInside = not context.isInside
        end
        --print(isSubgroup.."readop " .. tostring(op) .. " @ " .. context.i .. "/" .. tostring(context.entryCount) .. " (" .. tostring(serial._pointer-1) .. "/"..tostring(context.length))
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
            --print("Doing subgroup size: " .. tostring(subCount))
            local ret = {}
            while subCount > 0 do
                subCount = subCount - 1
                tinsert(ret, readOne(serial, context, true))
            end
            return ret
        elseif op == 5 then
            local rleCount = serial:ReadByte()
            --print("RLEing: " .. tostring(rleCount))
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
    while readerContext.i <= tileSize*tileSize do
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
    print("Finished reading "..tostring(tileSize*tileSize).." values with CRC: " .. tostring(readerContext.crc) .. " " .. tostring(storedCRC).. " (" .. tostring(serial._pointer-1) .. "/"..tostring(readerContext.length))
    local tile = {}
    tile.map = readerContext.map
    tile.tileX = tileX
    tile.tileY = tileY
    
    return tile, storedCRC == readerContext.crc
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
        CompressedHeightmaps = {} -- TODO: remove
        
        -- merge strings and calculate pointer map
        local map = ""
        local pointers = {}
        local pointer = 1

        for key, blob in pairs(Questie.db.char.compressedHeightmaps) do
            local size = string.len(blob)
            local pointerData = {pointer, size}
            pointers[key] = pointerData
            map = map .. blob
            
            pointer = pointer + size
        end
        
        print("Recalculating keys...");
        local minX = 999999
        local minY = 999999
        local maxX = -999999
        local maxY = -999999

        local width = 0

        for key in pairs(pointers) do
            QuestieHeightmaps.stream:LoadRaw(QuestieHeightmaps.compressedHeightmaps[key])
            local tileSize = QuestieHeightmaps.stream:ReadShort()
            local tileX = QuestieHeightmaps.stream:ReadShort() - 32760
            local tileY = QuestieHeightmaps.stream:ReadShort() - 32760
            if tileX < minX then
                minX = tileX
            end
            if tileX > maxX then
                maxX = tileX
            end
            if tileY < minY then
                minY = tileY
            end
            if tileY > maxY then
                maxY = tileY
            end
        end
        
        print("Detected ranges: " .. minX .. " -> " .. maxX)
        print("Detected ranges: " .. minY .. " -> " .. maxY)
        local offsetX = minX
        local offsetY = minY
        maxX = maxX + -minX
        minX = 0
        maxY = maxY + -minY
        minY = 0

        -- todo: make this not hardcoded
        local divisor = 4
        local res = 64

        -- fix pointers
        maxY = maxY / (res*divisor)
        local newPointers = {}
        for key, val in pairs(pointers) do
            QuestieHeightmaps.stream:LoadRaw(QuestieHeightmaps.compressedHeightmaps[key])
            local tileSize = QuestieHeightmaps.stream:ReadShort()
            local tileX = QuestieHeightmaps.stream:ReadShort() - 32760
            local tileY = QuestieHeightmaps.stream:ReadShort() - 32760
            tileX = (tileX - offsetX) / (res*divisor)
            tileY = (tileY - offsetY) / (res*divisor)
            if newPointers[tileX * maxY + tileY] then
                print("BadMathError!")
            end
            print(key .. " -> " .. tostring(tileX * maxY + tileY))
            newPointers[tileX * maxY + tileY] = val
        end
        pointers = newPointers

        CompressedHeightmaps.data = map
        CompressedHeightmaps.pointers = QuestieSerializer:Serialize(pointers)
        CompressedHeightmaps.offsetX = offsetX
        CompressedHeightmaps.offsetY = offsetY
        CompressedHeightmaps.tileResDivisor = divisor
        CompressedHeightmaps.res = res


        return
    end
    local zone = __compress_map[__compress_index]
    print("Compressing " .. zone)
    C_Timer.After(0.1, function()
        local zone = __compress_map[__compress_index]
        Questie.db.char.compressedHeightmaps[zone] = LibDeflate:CompressDeflate(QuestieHeightmaps.compressedHeightmaps[zone])
        __compress_index = __compress_index + 1
        print("   result: " .. tostring(string.len(QuestieHeightmaps.compressedHeightmaps[zone])) .. " bytes -> " .. tostring(string.len(Questie.db.char.compressedHeightmaps[zone])) .. " bytes")
        compressNext2(LibDeflate)
    end)
end

__comperss_end = 0
__compress_index = 0
__compress_map = {}
function HM_ActuallyCompress()

    --local HM_toEncode = {}

    local HM_exclude = { -- autogenerated using java tool
    }


    -- convert to strings
    local excluded = 0
    local included = 0
    for index, block in pairs(HM_toEncode) do -- HM_toEncode is set in a separate addon to keep VSCode from lagging
        local count = 0
        for index2, val in pairs(block) do
            block[index2] = string.char(val)
            count = count + 1
        end
        -- check for empty cells by CRC value
        --if (not (block[count]==5 and block[count-1]==0x15 and block[count-2]==0xE2 and block[count-3]==0x24)) and (not (block[count]==5 and block[count-1]==0x15 and block[count-2]==0x39 and block[count-3]==0x58)) then
        -- check for empty cells by file size --if count > 49 then
        -- check for empty cells by exclude
        if not HM_exclude[index] then
            HM_toEncode[index] = table.concat(block)
            included = included + 1
        else
            print("Excluded empty tile: " .. index)
            HM_toEncode[index] = nil
            excluded = excluded + 1
        end
    end

    print("Compressing " .. tostring(included) .. " tiles (excluded " .. tostring(excluded) ..")")

    QuestieHeightmaps.compressedHeightmaps = HM_toEncode


    local idx = 1
    local crc = 5381
    __compress_index = 1
    CompressedHeightmaps = {}
    for k,v in pairs(QuestieHeightmaps.compressedHeightmaps) do
        if v then
            __compress_map[idx] = k
            idx = idx + 1
        end
    end
    __comperss_end = idx - 1
    local LibDeflate = LibStub:GetLibrary("LibDeflate")
    Questie.db.char.compressedHeightmaps = {}
    compressNext2(LibDeflate)
end

function HM_Test()
    -- re-inflated string from heightmap table (test-uncompressed.lua)
    local toRead = "\000\064\000\000\000\000\004\003\127\005\255\005\255\005\255\005\255\005\255\005\255\005\255\005\255\005\007\003\002\001\244\005\255\005\255\005\255\005\255\005\255\005\255\005\255\005\255\005\007\237\056\029\005"
    local serial = QuestieLoader:ImportModule("QuestieStreamLib"):GetStream("raw")
    serial:LoadRaw(toRead)
    print("Loaded stream")
    return HM_read(serial, string.len(toRead))--print(pcall(HM_read, serial, string.len(toRead)))--HM_read(serial)
end


function HM_CreateDisplay_old(_key) -- really bad code for debugging the heightmap tiles
    local key=_key or 2805--key = "-8708,767"

    pcall(_QHM.SetMap, _QHM, 0)
    pcall(_QHM.private.LoadTile, _QHM.private, key)

    -- test data
    --local bin = nil
    
    --for i,v in pairs(bin) do
    --    bin[i] = string.char(v)
    --end
    --bin = table.concat(bin)
    --QuestieHeightmaps.stream:LoadRaw(bin)
    --local tile = HM_read(QuestieHeightmaps.stream, string.len(QuestieHeightmaps.stream._bin))
    --_QHM.loadedTiles[key] = tile

    
    local frame = CreateFrame("Frame", UIParent)
    frame:SetWidth(10)
    frame:SetHeight(10)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    local grayscale = false
    if grayscale then
        for x=1,64 do
            for y=1,64 do
                local tex = frame:CreateTexture(nil, "BACKGROUND")
                local idx = (64-y) * 64 + (x)
                local bright = 0
                local brightc = 0
                local hmcell = _QHM.loadedTiles[key].map[idx]
                
                if hmcell and type(hmcell[1]) == "table" then
                    for _, height in pairs(hmcell) do
                        bright = bright + height[1]
                        brightc = brightc + 1
                    end
                elseif hmcell then
                    bright = hmcell[1]
                    brightc = 1
                end
                bright = bright / brightc
                bright = bright / 256

                tex:SetWidth(2)
                tex:SetHeight(2)
                tex:SetPoint("CENTER", UIParent, "CENTER", x*2, y*2)
                tex:SetColorTexture(bright, bright, bright, 1)
            end
        end
    else
        for x=1,64 do
            for y=1,64 do
                local tex = frame:CreateTexture(nil, "BACKGROUND")
                local idx = (64-y) * 64 + (x)
                local bright_inside = 0
                local brightc_inside = 0
                local bright_outside = 0
                local brightc_outside = 0
                local hmcell = _QHM.loadedTiles[key].map[idx]
                
                if hmcell and type(hmcell[1]) == "table" then
                    for _, height in pairs(hmcell) do
                        if height[2] then
                            bright_inside = bright_inside + height[1]
                            brightc_inside = brightc_inside + 1
                        else
                            bright_outside = bright_outside + height[1]
                            brightc_outside = brightc_outside + 1
                        end
                    end
                elseif hmcell then
                    if hmcell[2] then
                        bright_inside = hmcell[1]
                        brightc_inside = 1
                    else
                        bright_outside = hmcell[1]
                        brightc_outside = 1
                    end
                end
                bright_outside = bright_outside / brightc_outside
                bright_outside = bright_outside / 256
                bright_inside = bright_inside / brightc_inside
                bright_inside = bright_inside / 256
                
                tex:SetWidth(2)
                tex:SetHeight(2)
                tex:SetPoint("CENTER", UIParent, "CENTER", x*2, y*2)
                tex:SetColorTexture(bright_inside, bright_outside, 0, 1)
            end
        end    
    end


    --local tex = frame:CreateTexture(nil, "BACKGROUND")
    --tex:SetWidth(5)
    ---tex:SetHeight(5)
    --tex:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    --tex:SetColorTexture(1.0, 0.0, 0.0, 0.5)

    frame:Show()
end

function HM_SetDisplay(key)
    if not _QuestieHeightmaps.debugDisplay then
        HM_CreateDisplay()
    end
    if not QuestieHeightmaps.loadedTiles[key] then
        pcall(QuestieHeightmaps.SetMap, QuestieHeightmaps, 0)
        pcall(QuestieHeightmaps.private.LoadTile, QuestieHeightmaps.private, key)
    end
    for x=1,64 do
        for y=1,64 do
            local tex = _QuestieHeightmaps.debugDisplay.textures[x*64+y]
            local idx = (64-y) * 64 + (x)
            local bright_inside = 0
            local brightc_inside = 0
            local bright_outside = 0
            local brightc_outside = 0
            local hmcell = QuestieHeightmaps.loadedTiles[key].map[idx]
            
            if hmcell and type(hmcell[1]) == "table" then
                for _, height in pairs(hmcell) do
                    if height[2] then
                        bright_inside = bright_inside + height[1]
                        brightc_inside = brightc_inside + 1
                    else
                        bright_outside = bright_outside + height[1]
                        brightc_outside = brightc_outside + 1
                    end
                end
            elseif hmcell then
                if hmcell[2] then
                    bright_inside = hmcell[1]
                    brightc_inside = 1
                else
                    bright_outside = hmcell[1]
                    brightc_outside = 1
                end
            end
            bright_outside = bright_outside / brightc_outside
            bright_outside = bright_outside / 256
            bright_inside = bright_inside / brightc_inside
            bright_inside = bright_inside / 256
            
            tex:SetColorTexture(bright_inside, bright_outside, 0, 1)
        end
    end
end

function HM_CreateDisplay() -- really bad code for debugging the heightmap tiles
    
    local frame = CreateFrame("Frame", UIParent)
    frame:SetWidth(10)
    frame:SetHeight(10)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    frame.textures = {}

    for x=1,64 do
        for y=1,64 do
            local tex = frame:CreateTexture(nil, "BACKGROUND")
            tex:SetWidth(4)
            tex:SetHeight(4)
            tex:SetPoint("CENTER", UIParent, "CENTER", x*4, y*4)
            tex:SetColorTexture(0, 0, 0, 1)
            frame.textures[x*64 + y] = tex
        end
    end

    frame:Show()
    _QuestieHeightmaps.debugDisplay = frame
end










-- api
function QuestieHeightmaps:EstimateHeight(x, y, indoors)

end

function QuestieHeightmaps:GetHeights(x, y)

end

function QuestieHeightmaps:EstimatePlayerHeight() -- this should prioritize the height value that is closest to the player's last known height value

end

function QuestieHeightmaps:SetMap(map) -- 0=eastern kingdoms, 1=kalimdor (map.dbc)
    if not map or map ~= QuestieHeightmaps.map then
        -- todo: actually implement maps (this is just elwynn test data)
        --end heightmapData
        --local pointers = QuestieHeightmaps.heightmapPointers[index]
        --azerothData=eastern kingdoms
        --kalimdorData=kalimdor
        QuestieHeightmaps.heightmapData = QuestieHeightmaps.kalimdorData.data
        QuestieHeightmaps.heightmapPointers = QuestieSerializer:Deserialize(QuestieHeightmaps.kalimdorData.pointers)
        QuestieHeightmaps.map = map
        print("Set map!")
        for key in pairs(QuestieHeightmaps.heightmapPointers) do
            print(tostring(key))
        end

    end
end

