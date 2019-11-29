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
	local tile = HM_read(QuestieHeightmaps.stream, string.len(QuestieHeightmaps.stream._bin)) -- refactor
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







-- testing globals (todo: REFACTOR/REMOVE!!) (see: HM_Test)
_QHM = QuestieHeightmaps
function HM_read(serial, length)
    local tileSize = serial:ReadShort()
	local divisor = serial:ReadByte()
	local tileX = serial:ReadShort() + 32760
	local tileY = serial:ReadShort() + 32760
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
	
	return tile
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

		CompressedHeightmaps.data = map
		CompressedHeightmaps.pointers = QuestieSerializer:Serialize(pointers)

        return
    end
    local zone = __compress_map[__compress_index]
    print("Compressing " .. zone)
    C_Timer.After(0.1, function()
        local zone = __compress_map[__compress_index]
        Questie.db.char.compressedHeightmaps[zone] = LibDeflate:CompressDeflate(QuestieHeightmaps.compressedHeightmaps[zone], configs)
        __compress_index = __compress_index + 1
        print("   result: " .. tostring(string.len(QuestieHeightmaps.compressedHeightmaps[zone])) .. " bytes -> " .. tostring(string.len(Questie.db.char.compressedHeightmaps[zone])) .. " bytes")
        compressNext2(LibDeflate)
    end)
end

__comperss_end = 0
__compress_index = 0
__compress_map = {}
function HM_ActuallyCompress()

	local HM_toEncode = {}

	-- convert to strings
	for index, block in pairs(HM_toEncode) do
		for index2, val in pairs(block) do
			block[index2] = string.char(val)
		end
		HM_toEncode[index] = table.concat(block)
	end

	QuestieHeightmaps.compressedHeightmaps = HM_toEncode


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














-- api
function QuestieHeightmaps:EstimateHeight(x, y, indoors)

end

function QuestieHeightmaps:GetHeights(x, y)

end

function QuestieHeightmaps:EstimatePlayerHeight()

end

function QuestieHeightmaps:SetMap(map) -- 0=eastern kingdoms, 1=kalimdor (map.dbc)
	if not map or map ~= QuestieHeightmaps.map then
		-- todo: actually implement maps (this is just elwynn test data)
		--end heightmapData
		--local pointers = QuestieHeightmaps.heightmapPointers[index]
		QuestieHeightmaps.heightmapData = QuestieHeightmaps.compressedHeightmaps.data
		QuestieHeightmaps.heightmapPointers = QuestieSerializer:Deserialize(QuestieHeightmaps.compressedHeightmaps.pointers)
		QuestieHeightmaps.map = map

	end
end

