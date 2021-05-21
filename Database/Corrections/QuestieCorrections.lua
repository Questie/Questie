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
---@type QuestieTBCQuestFixes
local QuestieTBCQuestFixes = QuestieLoader:ImportModule("QuestieTBCQuestFixes")
---@type QuestieTBCNpcFixes
local QuestieTBCNpcFixes = QuestieLoader:ImportModule("QuestieTBCNpcFixes")
---@type QuestieTBCItemFixes
local QuestieTBCItemFixes = QuestieLoader:ImportModule("QuestieTBCItemFixes")
---@type QuestieTBCObjectFixes
local QuestieTBCObjectFixes = QuestieLoader:ImportModule("QuestieTBCObjectFixes")

--[[
    This file load the corrections of the database files.

    It is a separate file so we can upstream those changes easier to cmangos and can still
    update the database files with a script.

    Most of the corrections can be done by accessing a specific key instead of copying the
    whole object over and change it.
    You can find the keys at the beginning of each file (e.g. 'questKeys' are at the beginning of 'questDB.lua').

    Further information on how to use this can be found at the wiki
    https://github.com/Questie/Questie/wiki/Corrections
--]]

-- flags that can be used in corrections (currently only blacklists)
QuestieCorrections.TBC_ONLY = 1
QuestieCorrections.CLASSIC_ONLY = 2
-- this function filters a table of values, if the value is TBC_ONLY or CLASSIC_ONLY, set it to true or nil if that case is met
local function filterExpansion(values)
    local isTBC = Questie.IsTBC
    for k, v in pairs(values) do
        if v == QuestieCorrections.TBC_ONLY then
            if isTBC then
                values[k] = true
            else
                values[k] = nil
            end
        elseif v == QuestieCorrections.CLASSIC_ONLY then
            if isTBC then
                values[k] = nil
            else
                values[k] = true
            end
        end
    end
    return values
end

function QuestieCorrections:MinimalInit() -- db already compiled
    for id, data in pairs(QuestieItemFixes:LoadFactionFixes()) do
        for key, value in pairs(data) do
            if not QuestieDB.itemDataOverrides[id] then
                QuestieDB.itemDataOverrides[id] = {}
            end
            QuestieDB.itemDataOverrides[id][key] = value
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

    for id, data in pairs(QuestieObjectFixes:LoadFactionFixes()) do
        for key, value in pairs(data) do
            if not QuestieDB.objectDataOverrides[id] then
                QuestieDB.objectDataOverrides[id] = {}
            end
            QuestieDB.objectDataOverrides[id][key] = value
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

    QuestieCorrections.questItemBlacklist = filterExpansion(QuestieItemBlacklist:Load())
    QuestieCorrections.questNPCBlacklist = filterExpansion(QuestieNPCBlacklist:Load())
    QuestieCorrections.hiddenQuests = filterExpansion(QuestieQuestBlacklist:Load())

    if Questie.db.char.showEventQuests then
        C_Timer.After(1, function()
             -- This is done with a delay because on startup the Blizzard API seems to be
             -- very slow and therefore the date calculation in QuestieEvents isn't done
             -- correctly.
            QuestieEvent:Load()
        end)
    end

end

local function equals(a, b) -- todo move to a library file somewhere
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

function QuestieCorrections:Initialize(doValidation) -- db needs to be compiled
    for id, data in pairs(QuestieItemFixes:Load()) do
        for key, value in pairs(data) do
            if not QuestieDB.itemData[id] then
                QuestieDB.itemData[id] = {}
            end
            if doValidation then
                if value and equals(QuestieDB.itemData[id][key], value) and doValidation.itemData[id] and equals(doValidation.itemData[id][key], value) then
                    Questie:Warning("Correction of item " .. tostring(id) .. "." .. QuestieDB.itemKeysReversed[key] .. " matches base DB! Value:" .. tostring(value))
                end
            end
            QuestieDB.itemData[id][key] = value
        end
    end

    for id, data in pairs(QuestieNPCFixes:Load()) do
        for key, value in pairs(data) do
            if not QuestieDB.npcData[id] then
                QuestieDB.npcData[id] = {}
            end
            if key == QuestieDB.npcKeys.npcFlags and QuestieDB.npcData[id][key] and type(value) == "table" then -- modify existing flags
                QuestieDB.npcData[id][key] = QuestieDB.npcData[id][key] + value[1]
            else
                if doValidation then
                    if value and equals(QuestieDB.npcData[id][key], value) and doValidation.npcData[id] and equals(doValidation.npcData[id][key], value)  then
                        Questie:Warning("Correction of npc " .. tostring(id) .. "." .. QuestieDB.npcKeysReversed[key] .. " matches base DB! Value:" .. tostring(value))
                    end
                end
                QuestieDB.npcData[id][key] = value
            end
        end
    end

    for id, data in pairs(QuestieObjectFixes:Load()) do
        for key, value in pairs(data) do
            if not QuestieDB.objectData[id] then
                Questie:Debug(DEBUG_CRITICAL, "Attempt to correct missing object " .. tostring(id))
            else
                if doValidation then
                    if value and equals(QuestieDB.objectData[id][key], value) and doValidation.objectData[id] and equals(doValidation.objectData[id][key], value) then
                        Questie:Warning("Correction of object " .. tostring(id) .. "." .. QuestieDB.objectKeysReversed[key] .. " matches base DB! Value:" .. tostring(value))
                    end
                end
                QuestieDB.objectData[id][key] = value
            end
        end
    end

    for id, data in pairs(QuestieQuestFixes:Load()) do
        for key, value in pairs(data) do
            if QuestieDB.questData[id] then
                if key == QuestieDB.questKeys.questFlags and QuestieDB.questData[id][key] and type(value) == "table" then -- modify existing flags
                    QuestieDB.questData[id][key] = QuestieDB.questData[id][key] + value[1]
                else
                    if doValidation then
                        if value and equals(QuestieDB.questData[id][key], value) and doValidation.questData[id] and equals(doValidation.questData[id][key], value) then
                            Questie:Warning("Correction of quest " .. tostring(id) .. "." .. QuestieDB.questKeysReversed[key] .. " matches base DB! Value:" .. tostring(value))
                        end
                    end
                    QuestieDB.questData[id][key] = value
                end
            end
        end
    end

    if Questie.IsTBC then
        for id, data in pairs(QuestieTBCQuestFixes:Load()) do
            for key, value in pairs(data) do
                if QuestieDB.questData[id] then
                    if key == QuestieDB.questKeys.questFlags and QuestieDB.questData[id][key] and type(value) == "table" then -- modify existing flags
                        QuestieDB.questData[id][key] = QuestieDB.questData[id][key] + value[1]
                    else
                        if doValidation then
                            if value and equals(QuestieDB.questData[id][key], value) and doValidation.questData[id] and equals(doValidation.questData[id][key], value) then
                                Questie:Warning("TBC-only Correction of quest " .. tostring(id) .. "." .. QuestieDB.questKeysReversed[key] .. " matches base DB! Value:" .. tostring(value))
                            end
                        end
                        QuestieDB.questData[id][key] = value
                    end
                end
            end
        end

        for id, data in pairs(QuestieTBCNpcFixes:Load()) do
            for key, value in pairs(data) do
                if not QuestieDB.npcData[id] then
                    QuestieDB.npcData[id] = {}
                end
                if key == QuestieDB.npcKeys.npcFlags and QuestieDB.npcData[id][key] and type(value) == "table" then -- modify existing flags
                    QuestieDB.npcData[id][key] = QuestieDB.npcData[id][key] + value[1]
                else
                    if doValidation then
                        if value and equals(QuestieDB.npcData[id][key], value) and doValidation.npcData[id] and equals(doValidation.npcData[id][key], value) then
                            Questie:Warning("TBC-only Correction of npc " .. tostring(id) .. "." .. QuestieDB.npcKeysReversed[key] .. " matches base DB! Value:" .. tostring(value))
                        end
                    end
                    QuestieDB.npcData[id][key] = value
                end
            end
        end

        for id, data in pairs(QuestieTBCObjectFixes:Load()) do
            for key, value in pairs(data) do
                if not QuestieDB.objectData[id] then
                    Questie:Debug(DEBUG_CRITICAL, "Attempt to correct missing object " .. tostring(id))
                else
                    if doValidation then
                        if value and equals(QuestieDB.objectData[id][key], value) and doValidation.objectData[id] and equals(doValidation.objectData[id][key], value) then
                            Questie:Warning("TBC-only Correction of object " .. tostring(id) .. "." .. QuestieDB.objectKeysReversed[key] .. " matches base DB! Value:" .. tostring(value))
                        end
                    end
                    QuestieDB.objectData[id][key] = value
                end
            end
        end

        for id, data in pairs(QuestieTBCItemFixes:Load()) do
            for key, value in pairs(data) do
                if not QuestieDB.itemData[id] then
                    QuestieDB.itemData[id] = {}
                end
                if doValidation then
                    if value and equals(QuestieDB.itemData[id][key], value) and doValidation.itemData[id] and equals(doValidation.itemData[id][key], value) then
                        Questie:Warning("TBC-only Correction of item " .. tostring(id) .. "." .. QuestieDB.itemKeysReversed[key] .. " matches base DB! Value:" .. tostring(value))
                    end
                end
                QuestieDB.itemData[id][key] = value
            end
        end
    end

    local patchCount = 0
    for _, quest in pairs(QuestieDB.questData) do
        if (not quest[QuestieDB.questKeys.requiredRaces]) or quest[QuestieDB.questKeys.requiredRaces] == 0 then
            -- check against questgiver
            local canHorde = false
            local canAlliance = false
            local starts = quest[QuestieDB.questKeys.startedBy]
            if starts then
                starts = starts[1]
                if starts then
                    for _, id in pairs(starts) do
                        local npc = QuestieDB.npcData[id]
                        if npc then
                            local friendly = npc[QuestieDB.npcKeys.friendlyToFaction]
                            if friendly then
                                if friendly == "H" then
                                    canHorde = true
                                elseif friendly == "A" then
                                    canAlliance = true
                                elseif friendly == "AH" then
                                    canAlliance = true
                                    canHorde = true
                                end
                            end
                        end
                    end
                end
                if canAlliance ~= canHorde then
                    patchCount = patchCount + 1
                    if canAlliance then
                        quest[QuestieDB.questKeys.requiredRaces] = QuestieDB.raceKeys.ALL_ALLIANCE
                    else
                        quest[QuestieDB.questKeys.requiredRaces] = QuestieDB.raceKeys.ALL_HORDE
                    end
                end
            end
        end
    end

    QuestieCorrections:MinimalInit()

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

local _validMultispawnWaypoints = { -- SELECT entry, Name FROM creature_template WHERE entry IN (SELECT id FROM pool_creature_template WHERE pool_entry IN (SELECT entry FROM pool_template WHERE max_limit=1)) ORDER BY entry
    [61]=1,[79]=1,[99]=1,[100]=1,[462]=1,[471]=1,[472]=1,[503]=1,[506]=1,[507]=1,[519]=1,[520]=1,[521]=1,[534]=1,[572]=1,[573]=1,[574]=1,[584]=1,[616]=1,
    [763]=1,[771]=1,[947]=1,[1037]=1,[1063]=1,[1106]=1,[1112]=1,[1119]=1,[1130]=1,[1132]=1,[1137]=1,[1140]=1,[1260]=1,[1398]=1,[1399]=1,[1424]=1,[1425]=1,
    [1533]=1,[1552]=1,[1837]=1,[1838]=1,[1839]=1,[1841]=1,[1843]=1,[1844]=1,[1847]=1,[1848]=1,[1850]=1,[1851]=1,[1885]=1,[1910]=1,[1911]=1,[1920]=1,[1936]=1,
    [1944]=1,[1948]=1,[2090]=1,[2108]=1,[2258]=1,[2283]=1,[2447]=1,[2452]=1,[2453]=1,[2476]=1,[2541]=1,[2598]=1,[2600]=1,[2601]=1,[2602]=1,[2603]=1,[2604]=1,
    [2605]=1,[2606]=1,[2609]=1,[2744]=1,[2749]=1,[2751]=1,[2752]=1,[2753]=1,[2754]=1,[2773]=1,[2779]=1,[2850]=1,[2931]=1,[3581]=1,[5400]=1,[6652]=1,[7846]=1,
    [8210]=1,[8211]=1,[8212]=1,[8213]=1,[8214]=1,[8215]=1,[8216]=1,[8217]=1,[8218]=1,[8219]=1,[8277]=1,[8278]=1,[8279]=1,[8280]=1,[8281]=1,[8282]=1,[8283]=1,
    [8296]=1,[8297]=1,[8298]=1,[8299]=1,[8300]=1,[8301]=1,[8302]=1,[8303]=1,[8304]=1,[8503]=1,[8976]=1,[8978]=1,[8979]=1,[8981]=1,[9602]=1,[9604]=1,[10077]=1,
    [10078]=1,[10119]=1,[10356]=1,[10357]=1,[10358]=1,[10359]=1,[10559]=1,[10647]=1,[10817]=1,[10821]=1,[10822]=1,[10823]=1,[10824]=1,[10825]=1,[10826]=1,
    [10827]=1,[10828]=1,[11383]=1,[12431]=1,[12432]=1,[12433]=1,[13602]=1,[14221]=1,[14222]=1,[14223]=1,[14224]=1,[14237]=1,[14266]=1,[14267]=1,[14268]=1,
    [14269]=1,[14270]=1,[14271]=1,[14272]=1,[14273]=1,[14275]=1,[14276]=1,[14277]=1,[14278]=1,[14279]=1,[14280]=1,[14281]=1,[14344]=1,[14424]=1,[14425]=1,
    [14433]=1,[14445]=1,[14446]=1,[14447]=1,[14448]=1,[14487]=1,[14488]=1,[14490]=1,[14492]=1,[16184]=1,[2186]=1,[10196]=1,[14479]=1,[7017]=1,[14339]=1,
    [3056]=1,[5823]=1,[815]=1,[2038]=1,[3735]=1,[7319]=1,

    -- tbc data
    [16249]=1,[16854]=1,[16855]=1,[17144]=1,[17587]=1,[17591]=1,[18677]=1,[18678]=1,[18679]=1,[18680]=1,[18681]=1,[18682]=1,[18683]=1,[18684]=1,[18685]=1,
    [18686]=1,[18689]=1,[18693]=1,[18694]=1,[18695]=1,[18696]=1,[18697]=1,[18698]=1,[20932]=1,[21730]=1,[22060]=1,[22062]=1,

    -- manually added
    [3476]=1,--isha awak
    [391]=1,--old murk-eye
    [2714]=1,--forsaken courier
    [10182]=1,--rexxar
}

function QuestieCorrections:OptimizeWaypoints(waypointData)
    local newWaypointZones = {}
    for zone, waypointList in pairs(waypointData) do
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
            local lastWay
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

function QuestieCorrections:PreCompile(callback) -- this happens only if we are about to compile the database. Run intensive preprocessing tasks here (like ramer-douglas-peucker)

    local timer
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
        for _=0,Questie.db.global.debugEnabled and 4000 or 72 do -- 72 operations per NewTicker
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
