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
---@type QuestieNPCBlacklist
local QuestieNPCBlacklist = QuestieLoader:ImportModule("QuestieNPCBlacklist")
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
---@type QuestieProfessions
local QuestieProfessions = QuestieLoader:ImportModule("QuestieProfessions")

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
    QuestieCorrections.questNPCBlacklist = QuestieNPCBlacklist:Load()
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

function QuestieCorrections:PopulateTownsfolkType(mask) -- populate the table with all npc ids based on the given bitmask
    local tbl = {}
    for id, data in pairs(QuestieDB.npcData) do
        flags = data[QuestieDB.npcKeys.npcFlags]
        if flags and bit.band(flags, mask) == mask then
            tinsert(tbl, id)
        end
    end
    return tbl
end

function QuestieCorrections:PopulateTownsfolk()
    Questie.db.global.townsfolk = {
        ["Repair"] = QuestieCorrections:PopulateTownsfolkType(16384), 
        ["Auctioneer"] = QuestieCorrections:PopulateTownsfolkType(4096),
        ["Banker"] = QuestieCorrections:PopulateTownsfolkType(256),
        ["Battlemaster"] = QuestieCorrections:PopulateTownsfolkType(2048),
        ["Flight Master"] = QuestieCorrections:PopulateTownsfolkType(8),
        ["Innkeeper"] = QuestieCorrections:PopulateTownsfolkType(128),
        ["Weapon Master"] = {}, -- populated below
        ["Reagents"] = { -- todo

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

    local validTrainers = { -- SELECT entry FROM creature_template WHERE TrainerType=2 (do this again with tbc DB)
        223,383,514,812,908,957,1103,1215,1218,1241,1246,1292,1300,1317,1346,1355,1382,1383,1385,1386,1430,1458,1466,1470,1473,1632,
        1651,1676,1680,1681,1683,1699,1700,1701,1702,1703,2114,2132,2326,2327,2329,2367,2390,2391,2397,2399,2626,2627,2664,2704,2737,
        2798,2801,2802,2806,2818,2834,2836,2837,2842,2855,2856,2857,2998,3001,3004,3007,3008,3009,3011,3013,3026,3028,3067,3069,3087,
        3136,3137,3174,3175,3178,3179,3181,3184,3185,3290,3332,3345,3347,3355,3357,3363,3365,3373,3399,3404,3412,3478,3484,3494,3497,
        3523,3530,3531,3549,3555,3557,3572,3603,3604,3605,3606,3607,3703,3704,3964,3965,3967,4156,4159,4160,4193,4204,4210,4211,4212,
        4213,4254,4258,4305,4307,4552,4573,4576,4578,4586,4588,4591,4596,4598,4605,4609,4611,4614,4616,4894,4898,4900,5081,5127,5137,
        5150,5153,5157,5159,5161,5164,5174,5177,5392,5482,5493,5499,5500,5502,5511,5513,5518,5519,5564,5566,5567,5690,5695,5748,5759,
        5784,5811,5847,5938,5939,5941,5943,6094,6286,6287,6288,6289,6290,6291,6292,6295,6297,6299,6306,6387,6777,7087,7088,7089,7230,
        7231,7232,7406,7853,7866,7867,7868,7869,7870,7871,7944,7946,7948,7949,8126,8128,8137,8144,8146,8153,8306,8736,8738,9584,10266,
        10276,10277,10278,10993,11017,11025,11026,11028,11029,11031,11037,11041,11042,11044,11046,11047,11048,11049,11050,11051,11052,
        11065,11066,11067,11068,11070,11071,11072,11073,11074,11081,11083,11084,11096,11097,11098,11146,11177,11178,11865,11866,11867,
        11868,11869,11870,11874,12025,12030,12032,12807,12920,12939,12961,13084,14401,14740,14742,14743,15176
    }

    local professionTrainers = {
        [QuestieProfessions.professionKeys.FIRST_AID] = {},
        [QuestieProfessions.professionKeys.BLACKSMITHING] = {},
        [QuestieProfessions.professionKeys.LEATHERWORKING] = {},
        [QuestieProfessions.professionKeys.ALCHEMY] = {},
        [QuestieProfessions.professionKeys.HERBALISM] = {},
        [QuestieProfessions.professionKeys.COOKING] = {},
        [QuestieProfessions.professionKeys.MINING] = {},
        [QuestieProfessions.professionKeys.TAILORING] = {},
        [QuestieProfessions.professionKeys.ENGINEERING] = {},
        [QuestieProfessions.professionKeys.ENCHANTING] = {},
        [QuestieProfessions.professionKeys.FISHING] = {},
        [QuestieProfessions.professionKeys.SKINNING] = {}
    }

    for _, id in pairs(validTrainers) do
        local subName = QuestieDB.npcData[id][QuestieDB.npcKeys.subName]
        if subName then
            if Questie.db.global.townsfolk[subName] then -- weapon master, 
                tinsert(Questie.db.global.townsfolk[subName], id)
            else
                for k, professionId in pairs(QuestieProfessions.professionTable) do
                    if string.match(subName, k) then
                        tinsert(professionTrainers[professionId], id)
                    end
                end
            end
        end
    end

    Questie.db.global.professionTrainers = professionTrainers

    -- todo: specialized trainer types (leatherworkers, engineers, etc)

    local _, class = UnitClass("player")
    Questie.db.char.townsfolk["Class Trainer"] = classTrainers[class]
    if class == "HUNTER" then
        Questie.db.char.townsfolk["Stable Master"] = QuestieCorrections:PopulateTownsfolkType(8192)
        QuestieCorrections:UpdateAmmoVendors()
        QuestieCorrections:UpdatePetFood()
    elseif class == "ROGUE" then
        -- shady dealers
    elseif class == "MAGE" then
        -- portal trainers
    end


    Questie.db.char.townsfolk["Mailbox"] = {}

    local faction = UnitFactionGroup("Player")

    for _, id in pairs({
        32349,142075,142089,142093,142094,142095,142102,142103,142109,142110,142111,142117,142119,143981,143982,143983,
        143984,143985,143986,143987,143988,143989,143990,144011,144112,144125,144126,144127,144128,144129,144131,153578,
        153716,157637,163313,163645,164618,164840,171556,171699,171752,173047,173221,176319,176324,176404,177044,178864,
        179895,179896,180451,181236,181639,187260,188123
    }) do
        local factionID = QuestieDB.objectData[id][QuestieDB.objectKeys.factionID]
        if (factionID == 0 
                or (faction == "Horde" and bit.band(QuestieDB.factionTemplate[factionID][5], 12) == 0) 
                or (faction == "Alliance" and bit.band(QuestieDB.factionTemplate[factionID][5], 10) == 0)) then
            -- friendly to the player
            tinsert(Questie.db.char.townsfolk["Mailbox"], id)
        end
    end

    Questie.db.char.townsfolk["Spirit Healer"] = {}

    -- get player professions and add relevant npcs
    --Questie.db.char.townsfolk["Profession Trainer"] = {}

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
