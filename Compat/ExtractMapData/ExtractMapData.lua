-- This is a map data extraction script for WotLK 3.3.5
-- The original script can be found at https://github.com/Nevcairiel/HereBeDragons-Scripts

-- continent lookup table (MapID -> uiMapID)
local Continents = {
	[0] = 13, -- EK
	[1] = 12, -- Kalimdor
	[530] = 101, -- Outlands
	[571] = 113, -- Northrend
	[870] = 424, -- Pandaria
	[1116] = 572, -- Draenor
	[1220] = 619, -- Broken Isles
	[1642] = 875, -- Zandalar
	[1643] = 876, -- Kul Tiras
	[2364] = 1550, -- Shadowlands
}

-- uiMapID -> MapID
local ContinentUIMapIDs = {
	[12] = 1, -- Kalimdor
	[13] = 0, -- Eastern Kingdoms
	[101] = 530, -- Outlands
	[113] = 571, -- Northrend
	[424] = 870, -- Pandaria
	[572] = 1116, -- Draenor
	[619] = 1220, -- Broken Isles
	[875] = 1642, -- Zandalar
	[876] = 1643, -- Kul Tiras
	[1550] = 2364, -- Shadowlands

	-- Classic/BC
	[1414] = 1, -- Kalimdor
	[1415] = 0, -- EK
	[1945] = 530, -- Outlands
}

local function printerr(pattern, ...)
	io.stderr:write(string.format(pattern .. "\n", ...))
end

local csv = require("csv")

-- https://wago.tools/db2/UiMapAssignment?build=3.4.3.53622
local UiMapAssignment = csv.open("UiMapAssignment.csv", {header=true})

local T = {}
local W = {}
local C = {}
for t in UiMapAssignment:lines() do
	for k,v in pairs(t) do t[k] = tonumber(v) end

	local UiMapID = tonumber(t.UiMapID)
	local Order = tonumber(t.OrderIndex)
	if t.UiMin_0 ~= 0 or t.UiMin_1 ~= 0 or t.UiMax_0 ~= 1 or t.UiMax_1 ~= 1 then
		printerr("Skipping entry %d/%d", UiMapID, Order)
	elseif T[UiMapID] then
		if T[UiMapID][1] ~= t.MapID or T[UiMapID][2] ~= t.Region_0 or T[UiMapID][3] ~= t.Region_1 or T[UiMapID][4] ~= t.Region_3 or T[UiMapID][5] ~= t.Region_4 then
			printerr("Map %d Order %d does not match first order seen (have: %d %d %d %d %d, new: %d %d %d %d %d)", UiMapID, Order, T[UiMapID][1],T[UiMapID][2],T[UiMapID][3],T[UiMapID][4],T[UiMapID][5], t.MapID, t.Region_0, t.Region_1, t.Region_3, t.Region_4)
		end
	else
		T[UiMapID] = { t.MapID, t.Region_0, t.Region_1, t.Region_3, t.Region_4 }
	end
	-- azeroth world map
	if UiMapID == 947 then
		table.insert(W, t)
	end
	if ContinentUIMapIDs[UiMapID] and Order > 0 and t.AreaID == 0 then
		print(UiMapID, t.MapID)
		table.insert(C, t)
	end
end

local function ppf(f,p)
	if not p then p = 4 end
	return string.format("%." .. p .. "f", f):gsub("%.?0+$", "")
end

local db2MapData = {}
local S = { "local db2MapData = { " }
for id, t in pairs(T) do
	db2MapData[id] = {t[1], t[2], t[3], t[4], t[5]}
	table.insert(S, string.format("[%d]={%d,%s,%s,%s,%s},", id, t[1], ppf(t[2]), ppf(t[3]), ppf(t[4]), ppf(t[5])))
end
table.insert(S, "}")
local str = table.concat(S)
-- uncomment to print db2 map data
-- print(str)

local function MapIDSorter(a,b) return a.MapID < b.MapID end

table.sort(W, MapIDSorter)
table.sort(C, MapIDSorter)

local worldMapData = {} -- table { width, height, left, top }
print()
print("WorldMapData follows")
print("-------------------------------")
for _, k in pairs(W) do
	if k.MapID and Continents[k.MapID] then
		local w = k.Region_4 - k.Region_1
		local h = k.Region_3 - k.Region_0
		local w_ui = k.UiMax_0 - k.UiMin_0
		local h_ui = k.UiMax_1 - k.UiMin_1
		local w2 = w / w_ui
		local h2 = h / h_ui
		local l2 = k.Region_4 + w2 * k.UiMin_0
		local t2 = k.Region_3 + h2 * k.UiMin_1
		print(string.format("        worldMapData[%d] = { %s, %s, %s, %s }", k.MapID, ppf(w2, 2), ppf(h2, 2), ppf(l2, 2), ppf(t2, 2)))

		worldMapData[k.MapID] = {w2, h2, l2, t2}
		if k.MapID == 571 then
			db2MapData[k.UiMapID] = {k.MapID, l2-w2, t2-h2, l2, t2}
		end
	end
end

local transformData = {{ 609, 0, -10000, 10000, -10000, 10000, 0, 0 },}
print()
print("Transform Data follows")
print("-------------------------------")
print("    local transformData = {")
for _, k in pairs(C) do
	if k.MapID and k.MapID ~= T[k.UiMapID][1] then
		local w = k.Region_4 - k.Region_1
		local h = k.Region_3 - k.Region_0
		local w_ui = k.UiMax_0 - k.UiMin_0
		local h_ui = k.UiMax_1 - k.UiMin_1
		local w2 = w / w_ui
		local h2 = h / h_ui
		local l2 = k.Region_4 + w2 * k.UiMin_0
		local t2 = k.Region_3 + h2 * k.UiMin_1
		local offsetX = T[k.UiMapID][5] - l2
		local offsetY = T[k.UiMapID][4] - t2
		if math.abs(offsetX) > 0.1 or math.abs(offsetY) > 0.1 then
			--print(k.UiMapID,k.OrderIndex,k.MapID, T[k.UiMapID][1], offsetY, offsetX)
			print(string.format("        { %d, %d, %s, %s, %s, %s, %s, %s },",
			                     k.MapID, T[k.UiMapID][1], ppf(k.Region_0, 2), ppf(k.Region_3, 2), ppf(k.Region_1, 2), ppf(k.Region_4, 2), ppf(offsetY, 1), ppf(offsetX, 1)))
			table.insert(transformData, {k.MapID, T[k.UiMapID][1], k.Region_0, k.Region_3, k.Region_1, k.Region_4, offsetY,offsetX})
		end
	end
end
print("    }")

local transforms = {}
local function processTransforms()
    for _, transform in pairs(transformData) do
        local instanceID, newInstanceID, minY, maxY, minX, maxX, offsetY, offsetX = table.unpack(transform)
        if not transforms[instanceID] then
            transforms[instanceID] = {}
        end
        table.insert(transforms[instanceID], { newInstanceID = newInstanceID, minY = minY, maxY = maxY, minX = minX, maxX = maxX, offsetY = offsetY, offsetX = offsetX })
    end
end
processTransforms()

local function applyMapTransforms(instanceID, left, right, top, bottom)
    if transforms[instanceID] then
        for _, data in ipairs(transforms[instanceID]) do
            if left <= data.maxX and right >= data.minX and top <= data.maxY and bottom >= data.minY then
                instanceID = data.newInstanceID
                left   = left   + data.offsetX
                right  = right  + data.offsetX
                top    = top    + data.offsetY
                bottom = bottom + data.offsetY
                break
            end
        end
    end
    return instanceID, left, right, top, bottom
end

local mapData = {} -- table { width, height, left, top, .instance, .name, .mapType }
local function processMap(id, data, parent)
	if not id or not data or mapData[id] then return end

    if data.parentMapID and data.parentMapID ~= 0 then
        parent = data.parentMapID
    elseif not parent then
        parent = 0
    end

	if db2MapData[id] then
		local instance, bottom, right, top, left = db2MapData[id][1], db2MapData[id][2], db2MapData[id][3], db2MapData[id][4], db2MapData[id][5]

        instance, left, right, top, bottom = applyMapTransforms(instance, left, right, top, bottom)
        mapData[id] = {left - right, top - bottom, left, top, instance = instance, name = data.name, mapType = data.mapType, parentMapID = parent }
    else
        mapData[id] = {0, 0, 0, 0, instance = instance or -1, name = data.name, mapType = data.mapType, parentMapID = parent }
    end
end

-- https://wowpedia.fandom.com/wiki/WorldMapAreaID
-- [UiMapID] = GetCurrentMapAreaID() + GetCurrentMapDungeonLevel()/10
local WorldMapAreaID = {
	[113] = 486,
	[114] = 487,
	[115] = 489,
	[116] = 491,
	[117] = 492,
	[118] = 493,
	[119] = 494,
	[120] = 496,
	[121] = 497,
	[123] = 502,
	[124] = 503,
	[125] = 505.1,
	[126] = 505.2,
	[127] = 511,
	[128] = 513,
	[129] = 521.1,
	[130] = 522.1,
	[131] = 522.2,
	[132] = 523.1,
	[133] = 524.1,
	[134] = 524.2,
	[135] = 524.3,
	[136] = 525.1,
	[137] = 525.2,
	[138] = 526.1,
	[139] = 526.2,
	[140] = 527.1,
	[141] = 528.1,
	[143] = 529.1,
	[144] = 529.2,
	[145] = 529.3,
	[146] = 529.4,
	[147] = 530.1,
	[148] = 530.2,
	[149] = 530.3,
	[150] = 530.4,
	[151] = 530.5,
	[152] = 530.6,
	[154] = 531.1,
	[155] = 532,
	[156] = 533.1,
	[157] = 534.1,
	[158] = 534.2,
	[159] = 534.3,
	[160] = 535.1,
	[161] = 535.2,
	[162] = 536.1,
	[163] = 536.2,
	[164] = 536.3,
	[165] = 536.4,
	[166] = 536.5,
	[167] = 536.6,
	[168] = 537.1,
	[169] = 541,
	[170] = 542,
	[171] = 543.1,
	[172] = 544.1,
	[173] = 544.2,
	[183] = 602.1,
	[184] = 603,
	[185] = 604.1,
	[186] = 605.1,
	[187] = 605.2,
	[188] = 605.3,
	[189] = 605.4,
	[190] = 605.5,
	[191] = 605.6,
	[192] = 605.7,
	[193] = 605.8,
	[200] = 610,
	[946] = -1,
	[947] = 0,
	[1411] = 5,
	[1412] = 10,
	[1413] = 12,
	[1414] = 14,
	[1415] = 15,
	[1416] = 16,
	[1417] = 17,
	[1418] = 18,
	[1419] = 20,
	[1420] = 21,
	[1421] = 22,
	[1422] = 23,
	[1423] = 24,
	[1424] = 25,
	[1425] = 27,
	[1426] = 28,
	[1427] = 29,
	[1428] = 30,
	[1429] = 31,
	[1430] = 33,
	[1431] = 35,
	[1432] = 36,
	[1433] = 37,
	[1434] = 38,
	[1435] = 39,
	[1436] = 40,
	[1437] = 41,
	[1438] = 42,
	[1439] = 43,
	[1440] = 44,
	[1441] = 62,
	[1442] = 82,
	[1443] = 102,
	[1444] = 122,
	[1445] = 142,
	[1446] = 162,
	[1447] = 182,
	[1448] = 183,
	[1449] = 202,
	[1450] = 242,
	[1451] = 262,
	[1452] = 282,
	[1453] = 302,
	[1454] = 322,
	[1455] = 342,
	[1456] = 363,
	[1457] = 382,
	[1458] = 383,
	[1459] = 402,
	[1460] = 444,
	[1461] = 462,
	[1941] = 463,
	[1942] = 464,
	[1943] = 465,
	[1944] = 466,
	[1945] = 467,
	[1946] = 468,
	[1947] = 472,
	[1948] = 474,
	[1949] = 476,
	[1950] = 477,
	[1951] = 478,
	[1952] = 479,
	[1953] = 480,
	[1954] = 481,
	[1955] = 482,
	[1956] = 483,
	[1957] = 500,
}

-- https://wago.tools/db2/UiMap?build=3.4.3.53622
local UiMap = csv.open("UiMap.csv", {header=true})

for t in UiMap:lines() do
	local UiMapID = tonumber(t.ID)
	if WorldMapAreaID[UiMapID] then
		processMap(UiMapID, {
			name = t.Name_lang,
			parentMapID = tonumber(t.ParentUiMapID),
			mapType = tonumber(t.Type),
		})
		mapData[UiMapID].mapID = WorldMapAreaID[UiMapID]
	end
end

dofile("printTable.lua")
printTable(mapData, "..\\UiMapData.lua", "QuestieCompat.UiMapData")