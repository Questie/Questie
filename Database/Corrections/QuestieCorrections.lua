---@class QuestieCorrections
local QuestieCorrections = QuestieLoader:CreateModule("QuestieCorrections")
-------------------------
--Import modules.
-------------------------
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestieEvent
local QuestieEvent = QuestieLoader:ImportModule("QuestieEvent")
---@type QuestieQuestFixes
local QuestieQuestFixes = QuestieLoader:ImportModule("QuestieQuestFixes")
---@type QuestieQuestBlacklist
local QuestieQuestBlacklist = QuestieLoader:ImportModule("QuestieQuestBlacklist")
---@type QuestieItemFixes
local QuestieItemFixes = QuestieLoader:ImportModule("QuestieItemFixes")
---@type QuestieItemBlacklist
local QuestieItemBlacklist = QuestieLoader:ImportModule("QuestieItemBlacklist")
---@type QuestieNPCFixes
local QuestieNPCFixes = QuestieLoader:ImportModule("QuestieNPCFixes")
---@type QuestieObjectFixes
local QuestieObjectFixes = QuestieLoader:ImportModule("QuestieObjectFixes")
---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule("ZoneDB")

--[[
    This file load the corrections of the database files.

    It is a separate file so we can upstream those changes easier to cmangos and can still
    update the database files with a script.

    Most of the corrections can be done by accessing a specific key instead of copying the
    whole object over and change it.
    You can find the keys at the beginning of each file (e.g. 'questKeys' are at the beginning of 'questDB.lua').

    Further information on how to use this can be found at the wiki
    https://github.com/AeroScripts/QuestieDev/wiki/Corrections
--]]

function QuestieCorrections:Initialize()
    for id, data in pairs(QuestieItemFixes:Load()) do
        for key, value in pairs(data) do
            if not QuestieDB.itemData[id] then
                QuestieDB.itemData[id] = {}
            end
            QuestieDB.itemData[id][key] = value
        end
    end

    for id, data in pairs(QuestieItemFixes:LoadFactionFixes()) do
        for key, value in pairs(data) do
            if not QuestieDB.itemDataOverrides[id] then
                QuestieDB.itemDataOverrides[id] = {}
            end
            QuestieDB.itemDataOverrides[id][key] = value
        end
    end

    for id, data in pairs(QuestieNPCFixes:Load()) do
        for key, value in pairs(data) do
            if not QuestieDB.npcData[id] then
                QuestieDB.npcData[id] = {}
            end
            QuestieDB.npcData[id][key] = value
        end
    end

    for id, data in pairs(QuestieNPCFixes:LoadFactionFixes()) do
        for key, value in pairs(data) do
            if not QuestieDB.npcDataOverrides[id] then
                QuestieDB.npcDataOverrides[id] = {}
            end
            QuestieDB.npcDataOverrides[id][key] = value
        end
    end

    for id, data in pairs(QuestieObjectFixes:Load()) do
        for key, value in pairs(data) do
            QuestieDB.objectData[id][key] = value
        end
    end

    for id, data in pairs(QuestieObjectFixes:LoadFactionFixes()) do
        for key, value in pairs(data) do
            if not QuestieDB.objectDataOverrides[id] then
                QuestieDB.objectDataOverrides[id] = {}
            end
            QuestieDB.objectDataOverrides[id][key] = value
        end
    end

    for id, data in pairs(QuestieQuestFixes:Load()) do
        for key, value in pairs(data) do
            if QuestieDB.questData[id] then
                QuestieDB.questData[id][key] = value
            end
        end
    end

    for id, data in pairs(QuestieQuestFixes:LoadFactionFixes()) do
        for key, value in pairs(data) do
			if not QuestieDB.questDataOverrides[id] then
                QuestieDB.questDataOverrides[id] = {}
            end
            QuestieDB.questDataOverrides[id][key] = value
        end
    end

    QuestieCorrections.questItemBlacklist = QuestieItemBlacklist:Load()
    QuestieCorrections.hiddenQuests = QuestieQuestBlacklist:Load()

    if Questie.db.char.showEventQuests then
        C_Timer.After(1, function()
             -- This is done with a delay because on startup the Blizzard API seems to be
             -- very slow and therefore the date calculation in QuestieEvents isn't done
             -- correctly.
            QuestieEvent:Load()
        end)
    end
end

local WAYPOINT_MIN_DISTANCE = 1.5 -- todo: make this a config value maybe?
local ZONE_SCALES = {
    [ZoneDB.zoneIDs.STORMWIND_CITY] = 0.5,
    [ZoneDB.zoneIDs.IRONFORGE] = 0.5,
    [ZoneDB.zoneIDs.TELDRASSIL] = 0.5,

    [ZoneDB.zoneIDs.ORGRIMMAR] = 0.5,
    [ZoneDB.zoneIDs.THUNDER_BLUFF] = 0.5,
    [ZoneDB.zoneIDs.UNDERCITY] = 0.5,
}

local function euclid(x, y, i, e)
    local xd = math.abs(x - i)
    local yd = math.abs(y - e)
    return math.sqrt(xd * xd + yd * yd)
end



function QuestieCorrections:OptimizeWaypoints(waypoints)
    local newWaypointZones = {}
    for zone, waypointList in pairs(waypoints) do
        local newWaypointList = {}
        if waypointList[1] and type(waypointList[1][1]) == "number" then
            waypointList = {waypointList} -- corrections support both {{x,y}, ...} and {{{x,y}, ...}, {{x,y}, ...}, ...}
        end
        for _, waypoints in pairs(waypointList) do
            -- apply RDP algorithm
            local minDist = WAYPOINT_MIN_DISTANCE * (ZONE_SCALES[zone] or 1)
            local newWaypoints = QuestieCorrections:RamerDouglasPeucker(waypoints, 0.1, true)

            waypoints = newWaypoints
            newWaypoints = {}

            -- subdivide waypoints where needed
            -- We do this because the clickable area of waypoint lines can only be a square, so lines need to be broken up in some places
            local lastWay = nil
            for _, way in pairs(waypoints) do
                if lastWay then
                    local dist = euclid(way[1], way[2], lastWay[1], lastWay[2])
                    if dist > minDist then
                        local divs = math.ceil(dist/minDist)
                        for i=1,divs do
                            local mul0 = i/divs
                            local mul1 = 1-mul0
                            tinsert(newWaypoints, {way[1] * mul0 + lastWay[1] * mul1, way[2] * mul0 + lastWay[2] * mul1})
                        end
                    else
                        tinsert(newWaypoints, way)
                    end
                else
                    tinsert(newWaypoints, way)
                end
                
                lastWay = way
            end
            tinsert(newWaypointList, newWaypoints)
        end
        newWaypointZones[zone] = newWaypointList
    
    end
    return newWaypointZones
end

function QuestieCorrections:UpdatePetFood() -- call on change pet
    Questie.db.char.townsfolk["Pet Food"] = {}
    -- detect petfood vendors for player's pet
end

function QuestieCorrections:UpdateAmmoVendors() -- call on change weapon
    Questie.db.char.townsfolk["Ammo Vendor"] = {}
end

function QuestieCorrections:PopulateTownsfolk()
    Questie.db.global.townsfolk = {
        ["Repair"] = {
            54, 74, 78, 167, 190, 222, 225, 226, 228, 789, 793, 836, 896, 945, 954, 956, 959, 980, 981, 984, 1104, 1146, 1147, 1198, 1213, 1214, 1238, 1240, 1243, 1249, 1273, 1287, 1289, 1291, 1294, 1295, 
            1296, 1297, 1298, 1299, 1309, 1310, 1312, 1314, 1315, 1319, 1320, 1322, 1323, 1324, 1333, 1339, 1341, 1348, 1349, 1350, 1362, 1381, 1407, 1441, 1450, 1454, 1459, 1461, 1462, 1469, 1471, 1645, 
            1668, 1669, 1686, 1687, 1690, 1695, 1698, 2046, 2113, 2116, 2117, 2135, 2136, 2137, 2482, 2483, 2679, 2839, 2840, 2843, 2844, 2845, 2847, 2849, 2997, 2999, 3000, 3015, 3018, 3019, 3020, 3021, 
            3022, 3023, 3053, 3073, 3074, 3075, 3077, 3078, 3079, 3080, 3088, 3092, 3093, 3095, 3097, 3159, 3160, 3161, 3162, 3163, 3165, 3166, 3167, 3177, 3314, 3315, 3316, 3317, 3319, 3321, 3322, 3330, 
            3331, 3343, 3349, 3356, 3359, 3360, 3361, 3409, 3410, 3477, 3479, 3483, 3486, 3488, 3491, 3492, 3493, 3522, 3528, 3529, 3530, 3531, 3532, 3534, 3536, 3537, 3539, 3543, 3552, 3553, 3554, 3588, 
            3589, 3590, 3591, 3592, 3609, 3610, 3611, 3612, 3613, 3658, 3682, 3683, 3684, 3951, 3952, 3953, 4043, 4085, 4086, 4164, 4171, 4172, 4173, 4175, 4177, 4180, 4183, 4184, 4185, 4186, 4187, 4188, 
            4203, 4231, 4232, 4233, 4234, 4235, 4236, 4240, 4257, 4259, 4556, 4557, 4558, 4559, 4560, 4569, 4570, 4580, 4592, 4597, 4600, 4601, 4602, 4603, 4604, 4883, 4884, 4886, 4888, 4889, 4890, 4892, 
            5102, 5103, 5106, 5107, 5108, 5119, 5120, 5121, 5122, 5123, 5125, 5126, 5129, 5133, 5152, 5155, 5156, 5170, 5411, 5508, 5509, 5510, 5512, 5754, 5812, 5816, 5819, 5820, 5821, 6028, 6300, 7852, 
            7976, 8129, 8131, 8159, 8161, 8176, 8358, 8359, 8360, 8398, 8878, 9179, 9544, 9548, 9549, 9551, 9552, 9553, 9555, 10293, 10361, 10369, 10379, 10380, 10856, 10857, 11137, 11182, 11183, 11184, 
            11703, 12023, 12024, 12029, 12045, 12777, 12782, 12792, 12799, 12805, 12942, 13216, 13217, 13218, 13219, 14301, 14371, 14581, 14624, 14737, 14753, 14754, 14921, 15126, 15127, 15176, 15315
        },
        ["Auctioneer"] = {8661, 8669, 8670, 8671, 8672, 8673, 8674, 8719, 8720, 8721, 8722, 8723, 8724, 9856, 9857, 9858, 9859, 15659, 15675, 15676, 15677, 15678, 15679, 15681, 15682, 15683, 15684, 15686},
        ["Banker"] = {2455, 2456, 2457, 2458, 2459, 2460, 2461, 2625, 2996, 3309, 3318, 3320, 3496, 4155, 4208, 4209, 4549, 5060, 5099, 7799, 8119, 8123, 8124, 8356, 8357, 13917},
        ["Battlemaster"] = {347, 857, 907, 2302, 2804, 3890, 5118, 7410, 7427, 10360, 12197, 12198, 14942, 14981, 14982, 14990, 14991, 15006, 15007, 15008, 15102, 15103, 15105, 15106},
        ["Flight Master"] = {
            352, 523, 931, 1387, 1571, 1572, 1573, 2226, 2299, 2389, 2409, 2432, 2835, 2851, 2858, 2859, 2861, 2941, 2995, 3305, 3310, 3615, 3838, 3841, 4267, 4312, 4314, 4317, 4319, 4321, 4407, 4551, 6026, 
            6706, 6726, 7823, 7824, 8018, 8019, 8020, 8609, 8610, 10378, 10583, 10897, 11138, 11139, 11899, 11900, 11901, 12577, 12578, 12596, 12616, 12617, 12636, 12740, 13177, 15177, 15178, 16227
        },
        ["Innkeeper"] = {
            295, 1247, 1464, 2352, 2388, 3934, 5111, 5688, 5814, 6272, 6727, 6734, 6735, 6736, 6737, 6738, 6739, 6740, 6741, 6746, 6747, 6790, 6791, 6807, 6928, 6929, 6930, 7714, 7731, 7733, 7736, 
            7737, 7744, 8931, 9356, 9501, 11103, 11106, 11116, 11118, 12196, 14731, 15174, 16458
        },
        ["Reagent Vendor"] = { -- todo

        }
    }
    Questie.db.char.townsfolk = {} -- character-specific townsfolk
    local classTrainers = {
        ["MAGE"] = {331, 3047, 3048, 3049, 4568, 5144, 5145, 5497, 5498, 5882, 5883, 5885, 7311, 7312},
        ["SHAMAN"] = {3030, 3031, 3032, 3344, 3403, 13417},
        ["PRIEST"] = {376, 3045, 4091, 4092, 4607, 4608, 5142, 5143, 5484, 5489, 5994, 6014, 6018, 11401, 11406},
        ["PALADIN"] = {928, 5147, 5148, 5149, 5491, 5492},
        ["WARRIOR"] = {914, 1901, 3041, 3042, 3043, 3353, 3354, 3408, 4087, 4089, 4593, 4594, 4595, 5113, 5114, 5479, 5480, 7315},
        ["HUNTER"] = {3039, 3040, 3352, 3406, 3407, 4146, 4205, 5116, 5117, 5515, 5516},
        ["WARLOCK"] = {461, 3324, 3325, 3326, 4563, 4565, 5171, 5172, 5173, 5495, 5496},
        ["ROGUE"] = {918, 3327, 3328, 3401, 4163, 4582, 4583, 5166, 5167, 13283},
        ["DRUID"] = {3033, 3034, 3036, 4217, 4218, 4219, 5504, 5505}
    }

    local _, class = UnitClass("player")
    Questie.db.char.townsfolk["Class trainer"] = classTrainers[class]
    if class == "HUNTER" then
        Questie.db.char.townsfolk["Stable Master"] = {
            6749, 9976, 9977, 9978, 9979, 9980, 9981, 9982, 9983, 9984, 9985, 9986, 9987, 9988, 9989, 10045, 10046, 10047, 10048, 10049, 10050, 10051, 10052, 10053, 10054, 10055, 10056, 
            10057, 10058, 10059, 10060, 10061, 10062, 10063, 10085, 11069, 11104, 11105, 11117, 11119, 13616, 13617, 14741, 15131, 15722, 16094
        }
        QuestieCorrections:UpdateAmmoVendors()
        QuestieCorrections:UpdatePetFood()
    elseif class == "ROGUE" then
        -- shady dealers
    elseif class == "MAGE" then
        -- portal trainers
    end

    -- get player professions and add relevant npcs

end
function QuestieCorrections:PreCompile(callback) -- this happens only if we are about to compile the database. Run intensive preprocessing tasks here (like ramer-douglas-peucker)
    
    QuestieCorrections:PopulateTownsfolk()

    local timer = nil
    local ops = {}
    --local totalPoints = 0

    for id, data in pairs(QuestieDB.npcData) do
        local way = data[QuestieDB.npcKeys["waypoints"]]
        if way then
            tinsert(ops, {way, id})
            --for _,waypoints in pairs(way) do
            --    totalPoints = totalPoints + #waypoints
            --end
        end
    end

    timer = C_Timer.NewTicker(0.1, function()
        for i=0,72 do -- 72 operations per NewTicker
            local op = tremove(ops, 1)
            if op then
                QuestieDB.npcData[op[2]][QuestieDB.npcKeys["waypoints"]] = QuestieCorrections:OptimizeWaypoints(op[1])
            else
                --local totalPoints2 = 0
                --for id, data in pairs(QuestieDB.npcData) do
                --    local way = data[QuestieDB.npcKeys["waypoints"]]
                --    if way then
                --        for _,waypoints in pairs(way) do
                --            totalPoints2 = totalPoints2 + #waypoints
                --        end
                --    end
                --end
                --print("Before RDP: " .. tostring(totalPoints))
                --print("After RDP:" .. tostring(totalPoints2))

                timer:Cancel()
                callback()
                break
            end
        end
    end)
end


-- code after this point is Ramer-Douglas-Peucker algorithm implemented by Eryn Lynn
--[[
MIT License

Copyright (c) 2018 Eryn Lynn

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE. ]]
-- Implementation of the Ramer–Douglas–Peucker algorithm
-- readme https://github.com/evaera/RobloxLuaAlgorithms#ramerdouglaspeuckerlua
-- author: evaera

local function getSqDist(p1, p2)
    local dx = p1[1] - p2[1]
    local dy = p1[2] - p2[2]

    return dx * dx + dy * dy
end

local function getSqSegDist(p, p1, p2)
    local x = p1[1]
    local y = p1[2]
    local dx = p2[1] - x
    local dy = p2[2] - y

    if dx ~= 0 or dy ~= 0 then
        local t = ((p[1] - x) * dx + (p[2] - y) * dy) / (dx * dx + dy * dy)

        if t > 1 then
            x = p2[1]
            y = p2[2]
        elseif t > 0 then
            x = x + dx * t
            y = y + dy * t
        end
    end

    dx = p[1] - x
    dy = p[2] - y

    return dx * dx + dy * dy
end

local function simplifyRadialDist(points, sqTolerance)
    local prevPoint = points[1]
    local newPoints = {prevPoint}
    local point

    for i=2, #points do
        point = points[i]

        if getSqDist(point, prevPoint) > sqTolerance then
            table.insert(newPoints, point)
            prevPoint = point
        end
    end

    if prevPoint ~= point then
        table.insert(newPoints, point)
    end

    return newPoints
end

local function simplifyDPStep(points, first, last, sqTolerance, simplified)
    local maxSqDist = sqTolerance
    local index

    for i=first+1, last do
        local sqDist = getSqSegDist(points[i], points[first], points[last])

        if sqDist > maxSqDist then
            index = i
            maxSqDist = sqDist
        end
    end

    if maxSqDist > sqTolerance then
        if index - first > 1 then
            simplifyDPStep(points, first, index, sqTolerance, simplified)
        end

        table.insert(simplified, points[index])

        if last - index > 1 then
            simplifyDPStep(points, index, last, sqTolerance, simplified)
        end
    end
end

local function simplifyDouglasPeucker(points, sqTolerance)
    local last = #points

    local simplified={points[1]}
    simplifyDPStep(points, 1, last, sqTolerance, simplified)
    table.insert(simplified, points[last])

    return simplified
end

function QuestieCorrections:RamerDouglasPeucker(points, tolerance, highestQuality)
    if #points <= 2 then
        return points
    end

    local sqTolerance = tolerance ~= nil and tolerance^2 or 1

    points = highestQuality and points or simplifyRadialDist(points, sqTolerance)
    points = simplifyDouglasPeucker(points, sqTolerance)

    return points
end
