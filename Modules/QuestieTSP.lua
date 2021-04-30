---@class QuestieTSP
local QuestieTSP = QuestieLoader:CreateModule("QuestieTSP")

---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule("ZoneDB")

---@type QuestieMap
local QuestieMap = QuestieLoader:ImportModule("QuestieMap")

---@Class QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")

---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")

---@type QuestiePlayer
local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")

---@type QuestieSerializer
local QuestieSerializer = QuestieLoader:ImportModule("QuestieSerializer")

---@type QuestieFramePool
local QuestieFramePool = QuestieLoader:ImportModule("QuestieFramePool")

local l10n = QuestieLoader:ImportModule("l10n")

local HBD = LibStub("HereBeDragonsQuestie-2.0")
local HBDPins = LibStub("HereBeDragonsQuestie-Pins-2.0")

-- TaxiNodes.dbc



-- cant be linked easily








-- TaxiPath.dbc

-- built from TaxiPathNodes.dbc

--AddWorldMapIconWorld
local PORTALS = { -- flight paths, zeppelins, boats. "portals" that teleport the player to another part of the map with a reduced walk cost

}


-- iterate through current objective spawns
-- group objectives together. Shared objectives are automatically grouped to the same polygon
-- iterate through all groups with TSP


-- reuse line frames
local linePool = {}

-- reuse start/end frames
local pointPool = {}

function QuestieTSP:CalculateOptimalRoute() 
    -- scan through current quest log and generate a route, while making use of flight paths
end

local function GetPlayerMapPosition()
    local uiMapId = GetPlayerZoneFixed()--C_Map.GetBestMapForUnit("player");

    if (not uiMapId) then
        return 0,0;
    end

    local mapPosition = C_Map.GetPlayerMapPosition(uiMapId, "player");
    if (not mapPosition) or (not mapPosition.x) then
        return 0,0
    end
    return mapPosition.x, mapPosition.y
end

local function hex(color)
    local num = tonumber(color, 16)
    return {bit.band(bit.rshift(num, 16), 255) / 255, bit.band(bit.rshift(num, 8), 255) / 255, bit.band(num, 255) / 255}
end

local skittles = {
    {1,0.25,0.5},
    {1,0.75,0.25},
    {0.25,1,0.5},
    {0.25,0.75,1},
    {0.5,1,0.25},
    {0.5,0.75,1},
    {0.75,1,0.25},
    {0.75,0.5,1},
    {0,1,0.25},
    {0,0.5,1},
    {1,0.25,0.75},
    {1,0.75,0.5},
    {0.25,1,0.75},
    {0.25,0.75,0.5},
    {0.5,1,0.75},
    {0.5,0.75,0.25},
    {0.75,1,0.5},
    {0.75,0.5,0.25},
    {0,1,0.5},
    {0,0.5,0.25},
    {1,0.25,0},
    {1,0.75,0},
    {0.25,1,0},
    {0.25,0.75,0},
    {0.5,1,0},
    {0.5,0.75,0},
    {0.75,1,0},
    {0.75,0.5,0},
    {0,1,0.75},
    {0,0.5,0.75},
    {1,0.5,0.25},
    {1,0,0.25},
    {0.25,0.5,1},
    {0.25,0,1},
    {0.5,0.25,1},
    {0.5,0,1},
    {0.75,0.25,1},
    {0.75,0,1},
    {0,0.25,1},
    {0,0.75,1},
    {1,0.5,0.75},
    {1,0,0.5},
    {0.25,0.5,0.75},
    {0.25,0,0.5},
    {0.5,0.25,0.75},
    {0.5,0,0.25},
    {0.75,0.25,0.5},
    {0.75,0,0.25},
    {0,0.25,0.5},
    {0,0.75,0.25},
    {1,0.5,0},
    {1,0,0.75},
    {0.25,0.5,0},
    {0.25,0,0.75},
    {0.5,0.25,0},
    {0.5,0,0.75},
    {0.75,0.25,0},
    {0.75,0,0.5},
    {0,0.25,0.75},
    {0,0.75,0.5},
}


QuestieTSP.entryScore = {
    ["monster"] = {},
    ["object"] = {},
    ["item"] = {},
    ["event"] = {},
    ["finisher"] = {}
}

QuestieTSP.playerScores = { -- same format as entryScore only in a subtable where the key is the player name. Used to update entryScore

}


QuestieTSP.logs = {} -- each log is an array of quest ids, key being the player name

-- C_Map.GetBestMapForUnit and HBD:GetPlayerZone are both broken
-- with certain sub-zones and return the continent uimapid instead
function GetPlayerZoneFixed()
    if not l10n.zoneLookup[3] then -- too early: not yet populated
        return C_Map.GetBestMapForUnit("Player")
    end

    local bad = {} -- build a list of dungeons to check RealZoneText
    for k,v in pairs(ZoneDB.private.dungeons) do
        local tin = l10n.zoneLookup[3][k] or l10n.zoneLookup[4][k] or l10n.zoneLookup[2][k] or l10n.zoneLookup[1][k]
        if tin then
            bad[tin] = ZoneDB.private.areaIdToUiMapId[v[3]]
        end
    end

    local fix = bad[GetRealZoneText()]
    if fix then
        return fix
    end
    return HBD:GetPlayerZone()
end

local function isComplete(objectiveList)
    for _, o in pairs(objectiveList) do
        if (o.needed or 0) ~= (o.collected or 0) then
            return false
        end
    end
    return true 
end

local function getOrCreate(table, ...)
    local val = table
    for _, key in pairs({...}) do
        if not val[key] then
            val[key] = {}
        end
        val = val[key]
    end
    return val
end

function QuestieTSP:StartSocialComms()
    Questie:RegisterComm("questiesocial", function(distribution, message, channel, sender)
        --print("Received packets")
       -- print(message)
        --print(distribution)
        --print(sender)
        QuestieTSP:ReadSocialPacket(message, sender)
    end)
end

function QuestieTSP:ReadSocialPacket(packet, player)
    packet = QuestieSerializer:Deserialize(packet)
    __PKT = packet
    local typeMap = {
        [1] = "monster",
        [2] = "object",
        [3] = "item",
        [4] = "event",
        [5] = "finisher"
    }

    if not QuestieTSP.playerScores[player] then
        QuestieTSP.playerScores[player] = {
            ["monster"] = {},
            ["object"] = {},
            ["item"] = {},
            ["event"] = {},
            ["finisher"] = {}
        }
    end

    local scoreNow = {
        ["monster"] = {},
        ["object"] = {},
        ["item"] = {},
        ["event"] = {},
        ["finisher"] = {}
    }

    local log = {}

    local uimapid = packet[1]

    --print("ReadSocialPacket " .. tostring(packet[1]))

    local index = 2

    
    while index < #packet do
        local questID = packet[index]; index = index + 1
        if not log[questID] then
            log[questID] = {}
        end
        local objectiveCount = packet[index]; index = index + 1
        for i=1,objectiveCount do
            local needed = packet[index]; index = index + 1
            local collected = packet[index]; index = index + 1
            local type = packet[index]; index = index + 1
            local id = packet[index]; index = index + 1
            tinsert(log[questID], {["needed"] = needed, ["collected"] = collected,  ["type"] = type, ["id"] = id})
            if id and type and (needed > collected) and type then
                --print(type)
                --print(typeMap[type])
                --print(id)
                scoreNow[typeMap[type]][id] = (scoreNow[typeMap[type]][id] or 0) + 1
            end
            
        end
    end
    --print("Updating score table")
    -- update shared score table
    for type,scoreMap in pairs(scoreNow) do
        for id, score in pairs(scoreMap) do
            local diff = score - (QuestieTSP.playerScores[player][type][id] or 0)
            QuestieTSP.entryScore[type][id] = (QuestieTSP.entryScore[type][id] or 0) + diff
        end
    end

    local shouldPlaySound = nil

    if QuestieTSP.logs[uimapid] and QuestieTSP.logs[uimapid][player] then
        for questId, data in pairs(QuestieTSP.logs[uimapid][player]) do
            if log[questId] then
                if not shouldPlaySound then
                    for index, objective in pairs(data) do
                        local compare = log[questId][index]
                        if objective.needed ~= objective.collected and compare.needed == compare.collected then
                            shouldPlaySound = "sound/interface/iquestupdate.ogg"
                        end
                    end
                end
                if (not isComplete(data)) and isComplete(log[questId]) then
                    shouldPlaySound = "sound/creature/peon/peonbuildingcomplete1.ogg"
                end
            end
        end
    end

    if shouldPlaySound then
        PlaySoundFile(shouldPlaySound)
    end

    QuestieTSP.playerScores[player] = scoreNow
    getOrCreate(QuestieTSP.logs, uimapid)[player] = log

    --QuestieLoader:ImportModule("QuestieTrackerNew"):Update() -- todo

end

function __TEST_SOCIAL()
    QuestieTSP:ReadSocialPacket(QuestieTSP:BuildSocialPacket(), UnitName("Player"))
    return QuestieTSP.entryScore
end

local typeMap = {
    ["monster"] = 1,
    ["object"] = 2,
    ["item"] = 3,
    ["event"] = 4,
    ["finisher"] = 5
}

-- varargs is questIds to add
function QuestieTSP:AddDebugLog(playerName, uimapid, ...)
    local log = {}
    for _, questId in pairs({...}) do
        local data = QuestieDB:GetQuest(questId)
        

        if data then
            local progress = {}
            for _, data in pairs(data.ObjectiveData) do
                tinsert(progress, {["needed"]=10,["collected"]=0,["id"]=data.Id,["type"]=typeMap[data.Type]})
            end
            log[questId] = progress
        end
    end

    getOrCreate(QuestieTSP.logs, uimapid)[playerName] = log
end

function QuestieTSP:BuildSocialPacket(uimapid)
    local packet = {}--{GetPlayerZoneFixed()}

    --tinsert(packet, GetPlayerZoneFixed())
    __CPKT = packet

    local index = 0

    index=index+1;packet[index] = uimapid or GetPlayerZoneFixed()
    
    --print("Social packet[1] = " .. tostring(packet[1]))
    --print("Social packet[1] should be " .. tostring(GetPlayerZoneFixed()))

    --packet[1] = {} -- current quest ids
    --packet[2] = {} -- needed npcs
    --packet[3] = {} -- needed objects
    --packet[4] = {} -- needed items
    local playerZone = ZoneDB:GetAreaIdByUiMapId(uimapid or GetPlayerZoneFixed())

    for id, quest in pairs(QuestiePlayer.currentQuestlog) do
        --tinsert(packet[1], id)
        if quest.Objectives then
            --packet[id] = {}
            local questData = QuestieDB:GetQuest(id)

            local validForThisZone = quest.zoneOrSort and quest.zoneOrSort > 0 and ZoneDB:GetUiMapIdByAreaId(quest.zoneOrSort) == uimapid

            local eventSpawn = nil

            for _, objective in pairs(quest.Objectives) do
                if objective.spawnList then
                    for id, spawn in pairs(objective.spawnList) do
                        if spawn.Spawns then
                            if spawn.Spawns[playerZone] then
                                validForThisZone = true
                                if objective.Type == "event" then
                                    eventSpawn = QuestieTSP:CoordToID(spawn.Spawns[playerZone][1][1]/100.0, spawn.Spawns[playerZone][1][2] / 100.0)
                                    --print("EVTS " .. tostring(eventSpawn))
                                    --print("EVTSP " .. tostring(spawn.Spawns[playerZone][1][1]) .. " " .. tostring(spawn.Spawns[playerZone][1][2]))
                                end
                                break
                            end
                        end
                    end
                    if validForThisZone then
                        break
                    end
                end
            end

            if #quest.Objectives == 0 or quest.isComplete then
                local finisherSpawns = nil
                local finisherName = nil
                if quest.Finisher ~= nil then
                    if quest.Finisher.Type == "monster" then
                        --finisher = QuestieDB:GetNPC(quest.Finisher.Id)
                        finisherSpawns, finisherName = unpack(QuestieDB.QueryNPC(quest.Finisher.Id, "spawns", "name"))
                    elseif quest.Finisher.Type == "object" then
                        --finisher = QuestieDB:GetObject(quest.Finisher.Id)
                        --print("Object finisher!")
                        finisherSpawns, finisherName = unpack(QuestieDB.QueryObject(quest.Finisher.Id, "spawns", "name"))
                    else
                        --print("Unhandled finisher type: " .. v.Finisher.Type )
                    end
                else
                    --print("Quest has no finisher: " .. tostring(k))
                end
                if finisherSpawns then -- redundant code
                    validForThisZone = validForThisZone or finisherSpawns[playerZone]

                end
            end

            if validForThisZone then
                index=index+1;packet[index] = id
                index=index+1;packet[index] = #quest.Objectives
                for _, objective in pairs(quest.Objectives) do
                    --print("  " .. objective.Type .. " " .. tostring(objective.Id) .. " " .. tostring(objective.Needed) .. " " .. tostring(objective.Collected)) 
                    index=index+1;packet[index] = objective.Needed or 0
                    index=index+1;packet[index] = objective.Collected or 0
                    index=index+1;packet[index] = typeMap[objective.Type]
                    index=index+1;packet[index] = objective.Id or eventSpawn or 0
                    --print("  C: " .. tostring(objective.Id or eventSpawn or 0))
                    --print("  C: " .. tostring(typeMap[objective.Type]))
                    --print("  C: " .. tostring(objective.Type))

                    --tinsert(packet[id], {objective.Needed, objective.Collected, typeMap[objective.Type], objective.Id})
                end
            end
        end

        --[[if questData.objectives[1] then -- creature
            for _,data in pairs(questData.objectives[1]) do
                tinsert(packet[2], data[1])
            end
        end
        if questData.objectives[2] then -- creature
            for _,data in pairs(questData.objectives[2]) do
                tinsert(packet[3], data[1])
            end
        end
        if questData.objectives[3] then -- creature
            for _,data in pairs(questData.objectives[3]) do
                local npcDrops, objectDrops = unpack(QuestieDB.QueryItem(data[1], "npcDrops", "objectDrops"))
                tinsert(packet[4], data[1])
                if npcDrops then
                    for _,data in pairs(npcDrops) do
                        tinsert(packet[2], data)
                    end
                end
                if objectDrops then
                    for _,data in pairs(objectDrops) do
                        tinsert(packet[3], data)
                    end
                end
            end
        end]]
    end
    
    return QuestieSerializer:Serialize(packet)
end

-- pass in iterator function, return nil when no more spawns are available
-- logs are expected to be in the format {{playerName, {questid, questid, ...}}, ...}
function QuestieTSP:GetSpawns(id, targetMap, disableYield)
    local uimapid = ZoneDB:GetUiMapIdByAreaId(targetMap)
    local questData = QuestieDB:GetQuest(id)
    local you = UnitName("Player")
    --print("GS " .. tostring(id))
    local shouldAddFinisher = false
    local shouldAddObjectives = false
    local eventSpawns = {}
    local validObjectiveIDs = {}

    local eventPlayers = {}
    local finisherPlayers = {}
    --print("Getting Spawns " .. tostring(id))
    -- check for event spawns
    for player, log in pairs(QuestieTSP.logs[uimapid] or {}) do
        if QuestieTSP.socialMode or player == you then
            if log[id] then
                if isComplete(log[id]) then
                    shouldAddFinisher = true
                    finisherPlayers[player] = true
                else
                    for _, objective in pairs(log[id]) do
                        if objective.type == 4 and objective.id ~= 0 then -- event
                            if objective.needed ~= objective.collected then
                                eventPlayers[player] = true
                            end
                            if not shouldAddObjectives then
                                local x, y = QuestieTSP:IDToCoord(objective.id)
                                tinsert(eventSpawns, {["x"]=x, ["y"]=y, ["score"]=QuestieTSP.entryScore["event"][objective.id], ["id"]=objective.id, ["objectiveId"]=objective.id, ["questId"]=id, ["type"] = 4, ["name"]="event", ["players"]=eventPlayers})
                            end
                        end
                        if objective.needed ~= objective.collected then
                            validObjectiveIDs[objective.id] = true
                        end
                    end
                    shouldAddObjectives = true
                end
            end
        end
    end
    local spawns = {}

    local function addSpawns(spawnList, score, entryId, type, name, isFinisher, objectiveId)
        --print("addSpawns  " .. tostring(objectiveId))
        local playerList = isFinisher and finisherPlayers or {}
        if not isFinisher then
            for player, log in pairs(QuestieTSP.logs[uimapid] or {}) do
                if QuestieTSP.socialMode or player == you then
                    if log[id] then
                        for _, objective in pairs(log[id]) do
                            if objective.needed ~= objective.collected and (objective.id == entryId or objective.id == objectiveId) then
                                playerList[player] = true
                            end
                        end
                    end
                end
            end
        end
        for map, spawnList in pairs(spawnList) do
            if map == targetMap then
                for _, spawn in pairs(spawnList) do
                    tinsert(spawns, {["x"]=spawn[1]/100.0, ["y"]=spawn[2]/100.0, ["score"]=score, ["id"]=entryId, ["type"] = type, ["name"] = name, ["questId"]=id, ["players"]=playerList, ["objectiveId"]=objectiveId})
                end
            end
        end
        if not disableYield then coroutine.yield() end
    end

    if shouldAddObjectives then
        --print("QN")
        if questData.objectives[1] then -- creature
            for _,data in pairs(questData.objectives[1]) do
                if validObjectiveIDs[data[1]] then
                    addSpawns(QuestieDB.QueryNPCSingle(data[1], "spawns"), QuestieTSP.entryScore["monster"][data[1]] or 0, data[1], 1, QuestieDB.QueryNPCSingle(data[1], "name"), false, data[1])
                end
            end
        end
        --print("QO")
        if questData.objectives[2] then -- creature
            for _,data in pairs(questData.objectives[2]) do
                if validObjectiveIDs[data[1]] then
                    addSpawns(QuestieDB.QueryObjectSingle(data[1], "spawns"), QuestieTSP.entryScore["object"][data[1]] or 0, data[1], 2, QuestieDB.QueryObjectSingle(data[1], "name"), false, data[1])
                end
            end
        end
        --print("QI")
        if questData.objectives[3] then -- creature
            for _,data in pairs(questData.objectives[3]) do
                if validObjectiveIDs[data[1]] then
                    --local npcDrops, objectDrops, name = unpack(QuestieDB.QueryItem(data[1], "npcDrops", "objectDrops", "name"))
                    local itemId = data[1]
                    local npcDrops = QuestieDB.QueryItemSingle(itemId, "npcDrops")
                    local objectDrops = QuestieDB.QueryItemSingle(itemId, "objectDrops")
                    local name = QuestieDB.QueryItemSingle(itemId, "name")


                    name = name or ("NAME MISSING (" .. tostring(itemId) .. ")")
                    local itemScore = QuestieTSP.entryScore["item"][itemId] or 0
                    if npcDrops then
                        for _,data in pairs(npcDrops) do
                            addSpawns(QuestieDB.QueryNPCSingle(data, "spawns"), itemScore + (QuestieTSP.entryScore["monster"][data] or 0), data, 3, QuestieDB.QueryNPCSingle(data, "name"), false, itemId)
                        end
                    end
                    if objectDrops then
                        for _,data in pairs(objectDrops) do
                            addSpawns(QuestieDB.QueryObjectSingle(data, "spawns"), itemScore + (QuestieTSP.entryScore["object"][data] or 0), data, 3, QuestieDB.QueryObjectSingle(data, "name"), false, itemId)
                        end
                    end
                end
            end
        end
    end
    --print("AF")
    if shouldAddFinisher then
        --print("Adding finisher...")
        local finisherSpawns = nil
        local finisherName = nil
        local quest = QuestieDB:GetQuest(id)

        if quest.Finisher ~= nil then
            if quest.Finisher.Type == "monster" then
                --finisher = QuestieDB:GetNPC(quest.Finisher.Id)
                finisherSpawns, finisherName = unpack(QuestieDB.QueryNPC(quest.Finisher.Id, "spawns", "name"))
            elseif quest.Finisher.Type == "object" then
                --finisher = QuestieDB:GetObject(quest.Finisher.Id)
                --print("Object finisher!")
                finisherSpawns, finisherName = unpack(QuestieDB.QueryObject(quest.Finisher.Id, "spawns", "name"))
            else
                --print("Unhandled finisher type: " .. v.Finisher.Type )
            end
        else
            --print("Quest has no finisher: " .. tostring(k))
        end
        if finisherSpawns then -- redundant code
            addSpawns(finisherSpawns, (QuestieTSP.entryScore["finisher"][id] or 0), id, 5, finisherName, true, id)
        end
    end
    --print("GR " .. tostring(#spawns))
    --__ls = spawns
    return spawns
end

function QuestieTSP:GetZoneEntryPoint(uimapid) -- assume flight path  /dump QuestieTSP:GetZoneEntryPoint(C_Map.GetBestMapForUnit("Player"))
    if IsInGroup() then
        local validGroupCount = 0
        local gx, gy = 0, 0
        for i=1,4 do
            local player = UnitName('party'..i)
            if player then
                local map = C_Map.GetBestMapForUnit(player)
                if map == uimapid then
                    local data = C_Map.GetPlayerMapPosition(map, player)
                    if data then
                        local x, y = data:GetXY()--tinsert(plist,(UnitName('party'..i)))
                        gx = gx + x
                        gy = gy + y
                        validGroupCount = validGroupCount + 1
                    end
                end
            end
        end

        if validGroupCount > 0 then
            validGroupCount = validGroupCount + 1
            
            local px, py = GetPlayerMapPosition()
            gx = gx + px
            gy = gy + py

            gx = gx / validGroupCount
            gy = gy / validGroupCount
            return gx, gy -- average point of all group members
        end
    else
        if uimapid == GetPlayerZoneFixed() then
            return GetPlayerMapPosition()
        end
    end

    local ep = Questie.db.char.zoneEntryPoints[ZoneDB:GetAreaIdByUiMapId(uimapid)]
    if ep then
        return unpack(ep)
    end
    return 0.5, 0.5
end

function QuestieTSP:BuildTaskList()
    --print("BTL")
    local uimapid = QuestieTSP.uimapid
    --print("BuildTaskList " .. tostring(uimapid))
    --local playerZone = GetPlayerZoneFixed() -- update this to target zone
    
    --local px, py = nil, nil

    --if playerZone == uimapid then
    --    px, py = GetPlayerMapPosition()
    --    playerZone = ZoneDB:GetAreaIdByUiMapId(playerZone)
    --else
    --    px, py = QuestieTSP:GetZoneEntryPoint(uimapid)
    --    playerZone = ZoneDB:GetAreaIdByUiMapId(uimapid)
    --end
    px, py = QuestieTSP:GetZoneEntryPoint(uimapid)
    playerZone = ZoneDB:GetAreaIdByUiMapId(uimapid)

    
    local tasklist = {{["x"]=px, ["y"]=py, ["icon"]="entryPoint", ["color"]={0,0,0}}} -- first entry is always the player location (or the zone entry point like a flight path)
    local heatmap = {}
    --print("BTL 1")
    -- configurable params
    local heatmapResolution = 32
    local socialBeta = 0.1 -- higher values makes shared objectives valued higher

    local colorID = 1
    local colorMap = {}

    local typeTable = {
        [1] = "skull.blp",
        [2] = "gear.blp",
        [3] = "crate.blp",
        [4] = "eye.blp",
        [5] = "complete.blp"
    }

    for i=1,heatmapResolution do
        if not heatmap[i] then
            heatmap[i] = {}
        end
        for e=1,heatmapResolution do
            heatmap[i][e] = {}
        end
    end
    --print("BTL2")
    -- build heatmap
    local checked = {}
    local you = UnitName("Player")
    for player, log in pairs(QuestieTSP.logs[uimapid] or {}) do
        --print("Building " .. player .. " heatmap")
        if QuestieTSP.socialMode or player == you then
            for questID, data in pairs(log) do
                if (not checked[questID]) and not QuestieDB:IsDungeonQuest(questID) then
                    checked[questID] = true
                    local spawns = QuestieTSP:GetSpawns(questID, playerZone)
                    --print("Got " .. tostring(#spawns) .. " spawns for " .. QuestieDB.QueryQuestSingle(questID, "name"))
                    coroutine.yield()
                    local maxStep = 15
                    for _, spawn in pairs(spawns) do
                        local x, y = math.ceil(spawn.x * heatmapResolution), math.ceil(spawn.y * heatmapResolution)
                        for i=1,heatmapResolution do
                            for j=1,heatmapResolution do
                                local dx = math.abs(i-x)
                                local dy = math.abs(j-y)
                                if not heatmap[i][j][spawn.objectiveId] then
                                    heatmap[i][j][spawn.objectiveId] = 0
                                end

                                heatmap[i][j][spawn.objectiveId] = heatmap[i][j][spawn.objectiveId] + (((heatmapResolution*2) - (dx^2+dy^2)^0.5) * ((1+socialBeta) * (1+spawn.score)) * 0.0000001)
                            end
                        end
                        maxStep = maxStep - 1
                        if maxStep == 0 then
                            coroutine.yield()
                            maxStep = 15
                        end
                    end
                end
            end
        end
    end

    -- find optimal spawn for each objective by checking heatmap
    local bestTasks = {}
    checked = {}
    for player, log in pairs(QuestieTSP.logs[uimapid] or {}) do
        --print("Building " .. player .. " tasklist")
        if QuestieTSP.socialMode or player == you then
            for questID, data in pairs(log) do
                if not colorMap[questID] then
                    colorMap[questID] = skittles[colorID%#skittles]
                    colorID = colorID + 1
                end
                --print(questID)
                if (not checked[questID]) and not QuestieDB:IsDungeonQuest(questID) then
                    checked[questID] = true
                    local spawns = QuestieTSP:GetSpawns(questID, playerZone)
                    if #spawns > 0 then
                        --print("Got " .. tostring(#spawns) .. " spawns")
                        coroutine.yield()
                        --print("Spawncount: " .. tostring(#spawns))
                        local best = {}
                        local bestSpawn = {}
                        local maxStep = 25
                        for _, spawn in pairs(spawns) do
                            ___SPAWN = spawn
                            local x, y = math.ceil(spawn.x * heatmapResolution), math.ceil(spawn.y * heatmapResolution)
                            if (heatmap[x][y][spawn.objectiveId] or 0) > (best[spawn.objectiveId] or 0) then
                                best[spawn.objectiveId] = heatmap[x][y][spawn.objectiveId]
                                bestSpawn[spawn.objectiveId] = spawn
                            end
                            maxStep = maxStep - 1
                            if maxStep == 0 then
                                coroutine.yield()
                                maxStep = 25
                            end
                        end
                        for _, spawn in pairs(bestSpawn) do
                            spawn.heatValue = best
                            --tinsert(tasklist, bestSpawn)
                            tinsert(tasklist, {["x"]=spawn.x, ["y"]=spawn.y, ["icon"]=typeTable[spawn.type], ["color"]=colorMap[questID], ["spawn"]=spawn}) --skittles[(1+#tasklist)%#skittles], ["spawn"]=spawn})
                        end 
                    end
                end
            end
        end
    end
    --print("Running routes...")


    __INTASK = tasklist
    ___HM = heatmap
    --print("TestRoutesTSP! " .. tostring(uimapid))
    QuestieTSP:TestRoutesTSP(tasklist, uimapid)--callback(tasklist)
    --return tasklist
end


-- function for getting all spawns for quest id
-- function for getting all quest ids for player
-- process 1 quest at a time

local lastMapID = 0

function QuestieTSP:BuildHotspots(uimapid)
    -- update local player
    
    if QuestieTSP.running then return false end
    --print("BuildHotspots " .. tostring(uimapid))
    QuestieTSP.running = true
    if lastMapID ~= uimapid then
        lastMapID = uimapid
        --print("Building hotspots for " .. C_Map.GetMapInfo(uimapid).name)
    end
    QuestieTSP:ReadSocialPacket(QuestieTSP:BuildSocialPacket(uimapid), UnitName("Player"))

    QuestieTSP.uimapid = uimapid

    local routine = coroutine.create(QuestieTSP.BuildTaskList)

    local ticker = nil
    ticker = C_Timer.NewTicker(0.01, function()
    	local status, err = coroutine.resume(routine)
        if status then -- 
            if coroutine.status(routine) == "dead" then
                ticker:Cancel()
                if not QuestieTSP.TSP:IsTSPRunning() then
                    QuestieTSP.running = nil
                end
            end
        else
            print("Coroutine error!")
            print(err)
            ticker:Cancel()
            QuestieTSP.running = nil
        end
        --print("COR")
    end)

    return true

end

function QuestieTSP:PopulateAllZones()
    --print("QuestieTSP PopulateAllZones...")
    if #QuestieTSP.zonesToCheck > 0 then
        --print("no zones!")
        return
    end
    local duplicates = {}
    local context = {}

    for id, quest in pairs(QuestiePlayer.currentQuestlog) do
        --tinsert(packet[1], id)
        if quest.Objectives and #quest.Objectives > 0 then
            for _, objective in pairs(quest.Objectives) do
                if objective.spawnList then
                    for id, spawn in pairs(objective.spawnList) do
                        if spawn.Spawns then
                            for zone in pairs(spawn.Spawns) do
                                if not duplicates[zone] and not ZoneDB:IsDungeonZone(zone) then
                                    --print("ZTC1 " .. tostring(zone))
                                    tinsert(QuestieTSP.zonesToCheck, zone)
                                    duplicates[zone] = true
                                end
                            end
                        end
                    end
                end
            end
        else -- todo: fix logic like this in the other places (check complete if Objectives is nil)
            local finisherSpawns = nil
            local finisherName = nil
            if quest.Finisher ~= nil then
                if quest.Finisher.Type == "monster" then
                    finisherSpawns, finisherName = unpack(QuestieDB.QueryNPC(quest.Finisher.Id, "spawns", "name"))
                elseif quest.Finisher.Type == "object" then
                    finisherSpawns, finisherName = unpack(QuestieDB.QueryObject(quest.Finisher.Id, "spawns", "name"))
                end
            end
            if finisherSpawns then -- redundant code
                for zone in pairs(finisherSpawns) do
                    if not duplicates[zone] and not ZoneDB:IsDungeonZone(zone)then
                        --print("ZTC2 " .. tostring(zone))
                        tinsert(QuestieTSP.zonesToCheck, zone)
                        duplicates[zone] = true
                    end
                end
            end
        end
    end
    for zone in pairs(QuestieTSP.logs) do
        zone = ZoneDB:GetAreaIdByUiMapId(zone)
        if not duplicates[zone] and not ZoneDB:IsDungeonZone(zone) then
            --print("ZTC3 " .. tostring(zone))
            tinsert(QuestieTSP.zonesToCheck, zone)
        end
    end
end

function TEST_QUESTIE_ROUTES()
    --print("QuestieTSP init...")
    if QuestieTSP._started then return end
    QuestieTSP._started = true
    QuestieTSP:StartSocialComms()

    QuestieTSP.zonesToCheck = {}
    --local zonesToCheck = {}
    --local duplicates = {}
    local context = {}
    --[[
    for id, quest in pairs(QuestiePlayer.currentQuestlog) do
        --tinsert(packet[1], id)
        if quest.Objectives and #quest.Objectives > 0 then
            for _, objective in pairs(quest.Objectives) do
                if objective.spawnList then
                    for id, spawn in pairs(objective.spawnList) do
                        if spawn.Spawns then
                            for zone in pairs(spawn.Spawns) do
                                if not duplicates[zone] then
                                    tinsert(zonesToCheck, zone)
                                    duplicates[zone] = true
                                end
                            end
                        end
                    end
                end
            end
        else -- todo: fix logic like this in the other places (check complete if Objectives is nil)
            local finisherSpawns = nil
            local finisherName = nil
            if quest.Finisher ~= nil then
                if quest.Finisher.Type == "monster" then
                    finisherSpawns, finisherName = unpack(QuestieDB.QueryNPC(quest.Finisher.Id, "spawns", "name"))
                elseif quest.Finisher.Type == "object" then
                    finisherSpawns, finisherName = unpack(QuestieDB.QueryObject(quest.Finisher.Id, "spawns", "name"))
                end
            end
            if finisherSpawns then -- redundant code
                for zone in pairs(finisherSpawns) do
                    if not duplicates[zone] then
                        tinsert(zonesToCheck, zone)
                        duplicates[zone] = true
                    end
                end
            end
        end
    end]]

    --print("Iterating all zones...")

    QuestieTSP:BuildHotspots(GetPlayerZoneFixed())


    QuestieTSP:PopulateAllZones()

    C_Timer.NewTicker(0.2, function()
        if context.zone then
            --print("pop " .. tostring(context.zone))
            if QuestieTSP:BuildHotspots(ZoneDB:GetUiMapIdByAreaId(context.zone)) then
                context.zone = tremove(QuestieTSP.zonesToCheck)
            end
        else
            context.zone = tremove(QuestieTSP.zonesToCheck)
            QuestieTSP:BuildHotspots(GetPlayerZoneFixed())
        end
    end)

    C_Timer.NewTicker(25, function()
        QuestieTSP:PopulateAllZones()
    end)

    --[[context.zone = tremove(zonesToCheck)
    --print("Building hotspots for " .. tostring(context.zone))
    local startTicker = nil
    if context.zone then
        startTicker = C_Timer.NewTicker(0.1, function()
            -- first pass: all zones

            if QuestieTSP:BuildHotspots(ZoneDB:GetUiMapIdByAreaId(context.zone)) then
                context.zone = tremove(zonesToCheck)
                --print("Building hotspots for " .. tostring(context.zone))
                if not context.zone then
                    startTicker:Cancel()
                    --print("Finished first pass of hotspots")
                    -- continue polling current zone
                    C_Timer.NewTicker(0.2, function() QuestieTSP:BuildHotspots(GetPlayerZoneFixed()) end)
                end
            end

        end)
    else
        C_Timer.NewTicker(0.2, function() QuestieTSP:BuildHotspots(GetPlayerZoneFixed()) end)
    end]]

    -- hack
    C_Timer.NewTicker(5, function()
        --print("Sending social message")
        --print("Iterating all zones...")
        C_ChatInfo.SendAddonMessage("questiesocial", QuestieTSP:BuildSocialPacket(), "PARTY")
    end)
end

function createDottedLineSegment(map, x0, y0, x1, y1)
    local start = CreateFrame("Button")
    local finish = CreateFrame("Button")

    local segment = tremove(linePool) or start:CreateLine()

    local line = {}

    line.start = start
    line.finish = finish
    line.segment = segment
    line.Update = function(line)
        line.segment:SetStartPoint(unpack(line.start:GetPoint()))
        line.segment:SetEndPoint(unpack(line.finish:GetPoint()))
        print("updated line segment")
    end


    --line:Update()

    return line
end


local function renderDottedLine(context)

end

function QuestieTSP:RenderRoute(route)
    QuestieTSP:ClearRoute()
end

function QuestieTSP:ClearRoute()

end














-- aero's implementation of the Lin-Kernigan Heuristic
-- based on the java implementation by Rodolfo Pichardo found here https://github.com/RodolfoPichardo/LinKernighanTSP/

-- this is to support both nil and java's null-style behavior, bit of a quirk to this port. Rework later
local NULL = "null"

local function List(a)
    local ret = {}
    ret.buffer = {}
    --ret.count = 0
    ret.Add = function(self, v, v2)
        if v2 then
            tinsert(self.buffer, v+1, v2)
        else
            tinsert(self.buffer, v)
        end
        
        if ret._size_cache then
            ret._size_cache = ret._size_cache + 1
        end
    end
    ret.Set = function(self, k, v)
        if self._size_cache and k+1 > self._size_cache then
            self._size_cache = nil
        end
        self.buffer[k+1] = v
    end
    ret.Get = function(self, v)
        return self.buffer[v+1]
    end
    ret.Size = function(self)
        if self._size_cache then
            return self._size_cache
        end
        local size = 0
        for _ in pairs(self.buffer) do
            size = size + 1
        end
        self._size_cache = size
        return size--self.count
    end
    ret.SubList = function(self, start, finish)
        local sub = List()
        for i=start,finish-1 do
            sub:Add(self:Get(i))
        end
        return sub
    end
    if a then
        if type(a) == "number" then
            for i=0,a-1 do
                ret:Set(i, 0)
            end
        else
            for k,v in pairs(a.buffer or a) do
                ret.buffer[k] = v
            end
        end
    end
    return ret
end

local function Edge(a, b)
    local ret = {}
    ret.endPoint1 = (a>b) and a or b
    ret.endPoint2 = (a>b) and b or a
    ret.Equals = function(self, a)
        return a and a ~= NULL and a.endPoint1 == self.endPoint1 and a.endPoint2 == self.endPoint2
    end
    return ret
end

local function Point(x, y)
    local rx, ry = x, y
    if x and not y then
        ry = x[2]
        rx = x[1]
    end
    local ret = {}
    ret.x = rx
    ret.y = ry
    return ret
end

LKH = QuestieLoader:CreateModule("LKH")

LKH.ids = List()
LKH.coordinates = List()
LKH.size = 0
LKH.tour = List()
LKH.distanceTable = {}

function LKH:InitSimple(coordinates)
    local c = List()
    local i = List()
    local id = 1
    for k, v in pairs(coordinates) do
        c:Add(Point(v))
        i:Add(id)
        id = id + 1
    end
    LKH:Init(c, i)
end

function LKH:Init(coordinates, ids)
    self.ids = ids
    self.coordinates = coordinates
    self.size = ids:Size()
    self.distanceTable = self:InitDistanceTable()
    self.tour = self:CreateRandomTour()
    --print("initial distance: " .. tostring(LKH:GetDistance()))
end

function LKH:CreateRandomTour()
    --print("CRT")
    local best = nil
    local bestD = 0
    for i = 0, 16 do
        local array = List()

        for i=0,self.size-1 do
            array:Set(i, i)
        end

        for i=1,self.size-1 do
            local index = math.floor((random() * (i+1)))
            while index == 0 do
                index = math.floor((random() * (i+1))) -- ensure start of route is always 0 (player location)
            end
            local a = array:Get(index)--array[index]
            array:Set(index, i)--array[index] = array[i]
            array:Set(i, a)--array[i] = a
        end
        self.tour = array
        local d = LKH:GetDistance()
        self.tour = nil
        if not best or bestD > d then
            bestD = d
            best = array
        end
    end

    return best
end

function LKH:InitDistanceTable()
    local res = {}
    for i=0,self.size-2 do
        for j=i+1,self.size-1 do
            local p1 = self.coordinates:Get(i)
            local p2 = self.coordinates:Get(j)

            if not res[i] then res[i] = {} res[i][i] = 0 end
            if not res[j] then res[j] = {} res[j][j] = 0 end

            res[i][j] = math.sqrt(
                math.pow(p2.x - p1.x, 2) + 
                math.pow(p2.y - p1.y, 2)
            )

            res[j][i] = res[i][j]
        end
    end
    return res
end

function LKH:GetDistance(a, b)
    if a and b then
        return self.distanceTable[self.tour:Get(a)][self.tour:Get(b)]
    end
    local sum = 0
    for i=0,self.size-1 do
        local a = self.tour:Get(i)
        local b = self.tour:Get(mod(i+1, self.size))

        sum = sum + self.distanceTable[a][b]
    end
    return sum
end

function LKH:RunAlgorithmTicking(callback) -- QuestieTSP:BuildHotspots
    local oldDistance = self:GetDistance()
    local newDistance = oldDistance
    local startDistance = oldDistance
    local ticker = nil
    local maxSteps = 1000
    local improveSteps = self.size
    local step = 0
    ticker = C_Timer.NewTicker(0.05, function()

        if step == improveSteps then
            newDistance = LKH:GetDistance()
            print("Improved " .. tostring(startDistance) .. " -> " .. tostring(newDistance))
            maxSteps = maxSteps - 1
            if newDistance >= oldDistance or maxSteps < 0 then
                print("Finished ticker")
                ticker:Cancel()
                callback()
                return
            end
            step = 0
            oldDistance = newDistance
        else
            self:Improve(step)
            step = step + 1
        end
    end)
end

function LKH:RunAlgorithm()
    local oldDistance = 0
    local newDistance = self:GetDistance()
    local maxSteps = 1000
    local i = 0

    repeat
        oldDistance = newDistance
        self:Improve()
        newDistance = self:GetDistance()
        print("["..tostring(i).."]Improved " .. tostring(oldDistance) .. " -> " .. tostring(newDistance))
        maxSteps = maxSteps - 1
        i = i + 1
    until newDistance >= oldDistance or maxSteps < 0
end

function LKH:Improve(t1, previous)
    if t1 then
        local t2 = previous and (t1 == 0 and (self.size-1) or (t1-1)) or mod(t1+1, self.size)
        local t3 = self:GetNearestNeighbor(t2)
        if t3 ~= -1 and self:GetDistance(t2, t3) < self:GetDistance(t1, t2) then
            self:StartAlgorithm(t1, t2, t3)
        elseif not previous then
            self:Improve(t1, true)
        end
    else
        for i=0,self.size-1 do
            self:Improve(i)
        end
    end
end

function LKH:GetNearestNeighbor(index)
    local minDistance = 9999999999 -- some high number
    local nearestNode = -1
    local actualNode = self.tour:Get(index)
    for i=0,self.size-1 do
        if i ~= actualNode then
            local distance = self.distanceTable[i][actualNode]
            if distance < minDistance then
                nearestNode = self:GetIndex(i)
                minDistance = distance
            end
        end
    end
    return nearestNode
end

function LKH:StartAlgorithm(t1, t2, t3)
    local tIndex = List()
    tIndex:Add(0, -1)
    tIndex:Add(1, t1)
    tIndex:Add(2, t2)
    tIndex:Add(3, t3)

    local initialGain = self:GetDistance(t2, t1) - self:GetDistance(t3, t2)
    local GStar = 0
    local Gi = initialGain

    local k = 3
    local i = 4
    local maxSteps = 1000
    while maxSteps > 0 do
        maxSteps = maxSteps - 1
        local newT = self:SelectNewT(tIndex)
        if newT == -1 then
            break
        end

        tIndex:Add(i, newT)

        local tiplus1 = self:GetNextPossibleY(tIndex)
        if tiplus1 == -1 then
            break
        end

        Gi = Gi + self:GetDistance(tIndex:Get(tIndex:Size() - 2), newT)

        if Gi - self:GetDistance(newT, t1) > GStar then
            GStar = Gi - self:GetDistance(newT, t1)
            k = i
        end

        tIndex:Add(tiplus1)
        Gi = Gi - self:GetDistance(newT, tiplus1)

        i = i + 2
    end

    if GStar > 0 then
        tIndex:Set(k+1, tIndex:Get(1))
        print("Updating tour")
        self.tour = self:GetTPrime(tIndex, k)
    end

end

function LKH:GetNextPossibleY(tIndex)
    local ti = tIndex:Get(tIndex:Size() - 1)
    local ys = List()
    for i=0,self.size-1 do
        if not self:IsDisjunctive(tIndex, i, ti) then
            --continue
        elseif not self:IsPositiveGain(tIndex, i) then
            --continue
        elseif not self:NextXPossible(tIndex, i) then
            -- continuie
        else
            ys:Add(i)
        end
    end
    local minDistance = 9999999999 -- some high number
    local minNode = -1
    for _, i in pairs(ys.buffer) do
        local d = self:GetDistance(ti, i)
        if d < minDistance then
            minNode = i
            minDistance = d
        end
    end
    return minNode
end

function LKH:NextXPossible(tIndex, i)
    return self:IsConnected(tIndex, i, mod(i+1, self.size)) or self:IsConnected(tIndex, i, (i == 0 and (self.size-1) or (i-1)))
end

function LKH:IsConnected(tIndex, x, y)
    if x == y then return false end
    local i = 1
    while i < tIndex:Size() -1 do
        local a = tIndex:Get(i)
        local b = tIndex:Get(i+1)
        if a == x and b == y then return false end
        if a == y and b == x then return false end
        i = i + 2
    end
    return true
end

function LKH:IsPositiveGain(tIndex, ti)
    local gain = 0
    local limit = tIndex:Size()-3
    for i=1,limit do
        
        local t1 = tIndex:Get(i)
        local t2 = tIndex:Get(i+1)
        local t3 = (i == limit) and ti or tIndex:Get(i+2)
        t1 = self.tour:Get(t1)--distanceTable[self.tour:Get(a)][self.tour:Get(b)]
        t2 = self.tour:Get(t2)
        t3 = self.tour:Get(t3)

        gain = gain + self.distanceTable[t2][t3] - self.distanceTable[t1][t2]
    end
    return gain > 0
end

function LKH:SelectNewT(tIndex)
    local o = tIndex:Get(tIndex:Size()-1)
    local option1 = (o == 0 and (self.size-1) or (o-1))
    local option2 = mod(o+1, self.size)

    local tour1 = self:ConstructNewTour(self.tour, tIndex, option1)

    if self:IsTour(tour1) then
        return option1
    else
        local tour2 = self:ConstructNewTour(self.tour, tIndex, option2)
        if self:IsTour(tour2) then
            return option2
        else
        end
    end
    return -1
end

function LKH:ConstructNewTour(tour2, tIndex, newItem)
    if newItem then
        local changes = List(tIndex)

        changes:Add(newItem)
        changes:Add(changes:Get(1))

        return LKH:ConstructNewTour(tour2, changes)
    else
        local tour, changes = tour2, tIndex
        local currentEdges = self:DeriveEdgesFromTour(tour)

        local X = self:DeriveX(changes)
        local Y = self:DeriveY(changes)
        local s = currentEdges:Size()

        local start_size = currentEdges:Size()

        local rx = 0
        local ay = 0

        for _, e in pairs(X.buffer) do
            if e and e ~= NULL then
                for j, m in pairs(currentEdges.buffer) do
                    if m and m ~= NULL and m.endPoint2 == e.endPoint2 and m.endPoint1 == e.endPoint1 then
                        s = s - 1
                        rx = rx + 1
                        currentEdges.buffer[j] = NULL
                        break
                    end
                end
            end
        end
        local between = currentEdges:Size()
        for _, e in pairs(Y.buffer) do
            s = s + 1
            ay = ay + 1
            currentEdges:Add(e)
        end
        return self:CreateTourFromEdges(currentEdges, s)
    end
end

function LKH:IsTour(tour)
    if tour:Size() ~= self.size then
        return false
    end

    --if tour:Get(0) ~= 0 then
    --    return false
    --end

    for i=0,self.size-2 do
        for j=i+1,self.size-1 do
            if tour:Get(i) == tour:Get(j) then
                return false
            end
        end
    end
    return true
end

function LKH:GetTPrime(tIndex, k)
    local al2 = List(tIndex:SubList(0, k + 2))
    return self:ConstructNewTour(self.tour, al2)
end

function LKH:CreateTourFromEdges(currentEdges, s)
    local tour = List(s)
    local i = 0
    local last = -1
    local initialCount = tour:Size()

    while i < currentEdges:Size() do
        local e = currentEdges:Get(i)
        if e and e ~= NULL then
            tour:Set(0, currentEdges:Get(i).endPoint1)
            tour:Set(1, currentEdges:Get(i).endPoint2)
            last = tour:Get(1)
            break
        end
        i = i + 1
    end

    currentEdges:Set(i, NULL)

    local k = 2
    while true do
        local j = 0
        while j < currentEdges:Size() do
            local e = currentEdges:Get(j)
            if e and e ~= NULL and e.endPoint1 == last then
                last = e.endPoint2
                break
            elseif e and e ~= NULL and e.endPoint2 == last then
                last = e.endPoint1
                break
            end
            j = j + 1
        end
        if j == currentEdges:Size() then break end
        currentEdges:Set(j, NULL)
        if k >= s then break end
        tour:Set(k, last)
        k = k + 1
    end
    return tour
end

function LKH:DeriveX(changes)
    local es = List()
    local i = 1
    while i < changes:Size() - 2 do
        e = Edge(self.tour:Get(changes:Get(i)), self.tour:Get(changes:Get(i+1)))
        es:Add(e)
        i = i + 2
    end
    return es
end

function LKH:DeriveY(changes) -- might be wrong
    local es = List()
    local i = 2
    while i < changes:Size() - 1 do
        e = Edge(self.tour:Get(changes:Get(i)), self.tour:Get(changes:Get(i+1)))
        es:Add(e)
        i = i + 2
    end
    return es
end

function LKH:DeriveEdgesFromTour(tour)
    local es = List()
    for i=0,tour:Size()-1 do
        local e = Edge(tour:Get(i), tour:Get(mod(i+1, tour:Size())))
        es:Add(e)
    end
    return es
end

function LKH:IsDisjunctive(tIndex, x, y)
    if x == y then return false end
    for i=0,tIndex:Size()-2 do
        local a = tIndex:Get(i)
        local b = tIndex:Get(i+1)
        if a == x and b == y then return false end
        if a == y and b == x then return false end
    end
    return true
end

function LKH:GetIndex(node)
    local i = 0
    for _, t in pairs(self.tour.buffer) do
        if node == t then 
            return i
        end
        i = i + 1
    end
    return -1
end






local lshift = bit.lshift
local rshift = bit.rshift
local band = bit.band

local function coordToID(x, y)
    x = math.floor(x * 4095)
    y = math.floor(y * 4095)
    return lshift(band(rshift(x, 8), 15) + lshift(band(rshift(y, 8), 15), 4), 16)
         + lshift(mod(x, 256), 8)
         + mod(y, 256)
end

local function IDToCoords(id)
    local a = mod(rshift(id, 16), 256)
    return (mod(rshift(id, 8), 256) + lshift(band(a, 15), 8)) / 4095, (mod(id, 256) + lshift(band(a, 240), 4)) / 4095
end



function QuestieTSP:CoordToID(x, y)
    return coordToID(x, y)--return floor(x * 10000 + 0.5) * 10000 + floor(y * 10000 + 0.5)
end

function QuestieTSP:IDToCoord(id)
    return IDToCoords(id)--return floor(id / 10000) / 10000, (id % 10000) / 10000
end

QuestieTSP.glowIcons = {}

function QuestieTSP:TooltipEntered(id, size, uimapid, data, icon)
    local hitPoints = {}
    local sizeX, sizeY = HBD:GetZoneSize(uimapid) --todo: zone id
    local x, y = QuestieTSP:IDToCoord(id)
    x = x * sizeX
    y = y * sizeY
    for _, val in pairs(QuestieTSP.paths[uimapid]) do
        local xh, yh = QuestieTSP:IDToCoord(val)
        xh = xh * sizeX
        yh = yh * sizeY
        
        xh = abs(xh - x)
        yh = abs(yh - y)
        
        local d = (xh^2+yh^2)^0.5

        if d < size * 2.5 then
            tinsert(hitPoints, val)
        end
    end
    --print("Mouseover hit " .. tostring(#hitPoints) .. " " .. tostring(id))

    local tooltip = {}
    --local spawns = 

    for _, icon in pairs(QuestieTSP.glowIcons) do
        HBDPins:RemoveWorldMapIcon(Questie, icon)
    end
    QuestieTSP.glowIcons = {}

    --GameTooltip:AddLine("Complete Quests",0.9,0.9,0.9)
    for _, point in pairs(hitPoints) do
        if QuestieTSP.metadata[uimapid][point].spawn then
            local id = QuestieTSP.metadata[uimapid][point].spawn.questId
            if not tooltip[id] then
                tooltip[id] = {}
            end

            tinsert(tooltip[id], QuestieTSP.metadata[uimapid][point].spawn)

            --print("Hit " .. tostring(QuestieTSP.metadata[uimapid][point].spawn.id))

            local spawns = QuestieTSP:GetSpawns(id, ZoneDB:GetAreaIdByUiMapId(uimapid), true)

            for _, spawn in pairs(spawns) do
                --print("hitspawn")
                local icon = CreateFrame("Button")
                --icon.texture:SetTexture("")

                local size = 32
                icon:SetFrameStrata("FULLSCREEN")
                icon:SetWidth(size)
                icon:SetHeight(size)
                icon:SetPoint("CENTER", -size/2, -size/2)

                icon.texture = icon.texture or icon:CreateTexture(nil, "OVERLAY", nil, 2)
                icon.texture:SetAllPoints(icon)
                icon.texture:SetTexture(QuestieLib.AddonPath.."Icons\\glow.blp")
                --icon.texture:SetTexCoord(0.015625, 0.3125, 0.03125, 0.59375)
                icon.texture:SetTexelSnappingBias(0)
                icon.texture:SetSnapToPixelGrid(false)

                color = data[point].color

                icon.texture:SetVertexColor(color[1], color[2], color[3] ,0.3)

                icon.isRouteGraphic = true
                icon.routeIndex = index

                HBDPins:AddWorldMapIconMap(Questie, icon, uimapid, spawn.x, spawn.y, HBD_PINS_WORLDMAP_SHOW_CURRENT)
                tinsert(QuestieTSP.glowIcons, icon)
            end

            --local quest = QuestieDB:GetQuest(QuestieTSP.metadata[point][5].questId)
            --GameTooltip:AddLine("   "..quest:GetColoredQuestName() .. " (" .. tostring(GetQuestLogRewardXP(quest.Id)).."xp)")
            --if quest then
                --GameTooltip:AddDoubleLine("   "..QuestieDB:GetColoredQuestName(quest.Id, true, true), "(" .. tostring(GetQuestLogRewardXP(quest.Id)).."xp)")
            --end
            --GameTooltip:AddLine(" ")
        end
    end



    --GameTooltip:SetOwner(UIParent, "ANCHOR_CURSOR")
    --[[icon.routeTooltipData = {}
    local first = true
    for questId, objectives in pairs(tooltip) do
        --print("Toolt " .. tostring(questId))
        --if first then
        --    first = false
        --else
            --GameTooltip:AddLine(" ")
        --end

        --local quest = QuestieDB:GetQuest(questId)
        --local xp = GetQuestLogRewardXP(quest.Id)

        --if xp > 0 then
        --    GameTooltip:AddDoubleLine(QuestieDB:GetColoredQuestName(quest.Id, true, true), "(" .. tostring(xp).."xp)")
        --else
        --    GameTooltip:AddLine(QuestieDB:GetColoredQuestName(quest.Id, true, true))
        --end

        local key = QuestieDB:GetColoredQuestName(questId, true, true)
        local data = {}

        icon.routeTooltipData[key] = data


        
        for _, objective in pairs(objectives) do
            --print(objective.name)
            --GameTooltip:AddLine(objective.name)
            tinsert(data, objective.name)
            for player in pairs(objective.players) do
                local progress = nil -- todo: optimize this with table when .logs is populated
                if QuestieTSP.logs[uimapid] and QuestieTSP.logs[uimapid][player] then
                    for _, p in pairs(QuestieTSP.logs[uimapid][player][questId] or {}) do
                        if p.id == objective.objectiveId then
                            progress = p
                            break
                        end
                    end
                end

                if progress then
                    print("Progress for " .. objective.name)
                    --GameTooltip:AddLine("   " .. tostring(progress.collected) .. "/" .. tostring(progress.needed) .. " " .. objective.name ..  " (|cFFFFFFFF" .. player .. "|r)" ,0.8,0.8,0.8)
                    tinsert(data, "   " .. tostring(progress.collected) .. "/" .. tostring(progress.needed) .. " " .. objective.name ..  " (|cFFFFFFFF" .. player .. "|r)")
                else
                    print("No progress for " .. objective.name)
                end
            end 
        end 
    end]]

    
    --GameTooltip:Show()


    --[[GameTooltip:AddLine(" ")
    GameTooltip:AddLine("Complete Quests (Party)",0.9,0.9,0.9)
    GameTooltip:AddLine("   "..QuestieDB:GetQuest(1531):GetColoredQuestName())

    GameTooltip:AddLine(" ")]]

    --GameTooltip:AddLine("Questie: |cFFFFFFFFHold Shift|r to show spawn points")

    QuestieFramePool.private.QuestieTooltip(icon)
    

    __HIT = QuestieTSP.metadata[uimapid][id]
    __HITMAP = tooltip
end

QuestieTSP.buttonCache = {}
QuestieTSP.antCache = {}

QuestieTSP.buttons = {}
QuestieTSP.ants = {}

QuestieTSP.paths = {}

QuestieTSP.socialMode = true

function QuestieTSP:PopulateTooltip(id)
    local quest = QuestieDB:GetQuest(id)
    GameTooltip:SetOwner(UIParent, "ANCHOR_CURSOR")
    GameTooltip:AddLine(QuestieLib:GetColoredQuestName(id, true, true, true))
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine("Questie: |cFFFFFFFFHold Shift|r to show spawn points")
    GameTooltip:Show()
end

QuestieTSP.metadata = {}

function QuestieTSP:TestRoutesTSP(sa, uimapid) --adz
    local nodes = {}
    local path = {}
    local params = {
        initial_pheromone  = 0.1,   -- Initial pheromone trail value
        alpha              = 1,     -- Likelihood of ants to follow pheromone trails (larger value == more likely)
        beta               = 6,     -- Likelihood of ants to choose closer nodes (larger value == more likely)
        local_decay        = 0.2,   -- Governs local trail decay rate [0, 1]
        local_update       = 0.4,   -- Amount of pheromone to reinforce local trail update by
        global_decay       = 0.2,   -- Governs global trail decay rate [0, 1]
        twoopt_passes      = 3,     -- Number of times to perform 2-opt passes
        two_point_five_opt = false, -- Perform optimized 2-opt pass
        entryPoint         = {QuestieTSP:GetZoneEntryPoint(uimapid)}--uimapid == GetPlayerZoneFixed() and {GetPlayerMapPosition()} or {QuestieTSP:GetZoneEntryPoint(uimapid)} -- the desired entry point of the route (should also be included in the route node list)
    }

    local lookupTable = {}

    if not QuestieTSP.metadata[uimapid] then
        QuestieTSP.metadata[uimapid] = {}
    end

    for _, v in pairs(sa) do
        local id = QuestieTSP:CoordToID(v.x, v.y)
        lookupTable[id] = v--{v[3], v[4]}
        
        QuestieTSP.metadata[uimapid][id] = v
        tinsert(nodes, id)
    end
    QuestieTSP.TSP:SetStatusFunction(function(a, b, c)
        --print(a)
        --print(b)
        --print(c)
    end)
    
    local function tcopy(t)
        local ret = {}
        for k,v in pairs(t) do
            ret[k] = v
        end
        return ret
    end

    if not QuestieTSP._animation_step then
        QuestieTSP._animation_step = 0
        local animationTicker = CreateFrame("Button")
        animationTicker:SetScript("OnUpdate", function()
            QuestieTSP._animation_step = mod(QuestieTSP._animation_step + (0.4 * (60 / GetFramerate())), 20)
        end)
        animationTicker:Show()
    end

    QuestieTSP.TSP:SetFinishFunction(function(path, meta, shortestPathLength, count, timetaken)
        --print("TSP finished!")
        if not uimapid then
            print("No UiMapID!")
            return
        end

        if uimapid == GetPlayerZoneFixed() then -- replace with player location
            local player = coordToID(GetPlayerMapPosition())
            QuestieTSP.metadata[uimapid][player] = QuestieTSP.metadata[uimapid][path[1]]
            path[1] = player
        end

        --print("Finish function")
        if QuestieTSP.paths[uimapid] then
            local same = #QuestieTSP.paths[uimapid] == #path
            if same then
                for k,v in pairs(path) do
                    if QuestieTSP.paths[uimapid][k] ~= v then
                        same = false
                        break
                    end
                end
            end
            if same then
                QuestieTSP.running = nil
                return -- no need to update
            end
        end
        QuestieTSP.paths[uimapid] = tcopy(path) -- used to check if the path has changed
        for _, v in pairs(path) do
            v = QuestieTSP.metadata[uimapid][v]
            --print("   " .. (v.spawn and QuestieDB:GetColoredQuestName(v.spawn.questId) or " NO SPAWN!"))
        end
        for _, v in pairs(QuestieTSP.buttons[uimapid] or {}) do
            v:Hide()
            --v.Show = function() end
            v:EnableMouse(false)
            HBDPins:RemoveWorldMapIcon(Questie, v)
            --HBDPins:RemoveMinimapIcon(Questie, v)
            --v.removeFromMap(HBDPins, Questie, v)
            tinsert(QuestieTSP.buttonCache, v)
        end
        QuestieTSP.buttons[uimapid] = {}

        for _, v in pairs(QuestieTSP.ants[uimapid] or {}) do
            v:Hide()
            v:EnableMouse(false)
            v:SetScript("OnUpdate", nil)
            --v:SetScript("OnShow", nil)
            HBDPins:RemoveWorldMapIcon(Questie, v)
            tinsert(QuestieTSP.antCache, v)
        end
        QuestieTSP.ants[uimapid] = {}


        local lx = -1
        local ly = -1
        local count = #path


        --/dump HBD:GetZoneSize(GetPlayerZoneFixed())

        --local sizeX, sizeY = HBD:GetZoneSize(GetPlayerZoneFixed())
        --local zoneRad = (sizeX^2+sizeY^2)^0.5

        --local zoneFactor = zoneRad / 12179.135790801 -- barrens rad
        local sizeX, sizeY = HBD:GetZoneSize(uimapid) --todo: zone id

        --local mapFunctions = {{HBDPins.AddWorldMapIconMap, HBDPins.RemoveWorldMapIcon}, {HBDPins.AddMinimapIconMap, HBDPins.RemoveMinimapIcon}}
        local mapTypes = {"world"}--{"world", "mini"}
        --print("ren")
        for index, v in pairs(path) do
            local x, y = QuestieTSP:IDToCoord(v)
            local data = lookupTable[v]
            --print("Path: " .. tostring(x) .. " " .. tostring(y))
            --QuestieMap:ShowDebug(nil, 0.5, "Route Test - Step " .. tostring(index), {}, "test", ZoneDB:GetAreaIdByUiMapId(GetPlayerZoneFixed()), x*100, y*100)
            
            --icon.texture:SetTexture("")

            if lx ~= -1 then -- exclude the first icon, its the player
                
                local size = 28
                local lastIcon = false--index == count and count > 6 -- dont fade final objective if the route is too short

                if not lastIcon then -- fade last icon
                    if data.icon ~= "entryPoint" then

                        for _, mapType in pairs(mapTypes) do
                            --local addToMap, removeFromMap = unpack(fn)
                            local icon = tremove(QuestieTSP.buttonCache) or CreateFrame("Button")
                            icon:SetFrameStrata("FULLSCREEN")
                            icon:SetWidth(size)
                            icon:SetHeight(size)
                            icon:SetPoint("CENTER", -size/2, -size/2)

                            icon:EnableMouse(true)
                            icon:SetScript("OnEnter", function(self)
                                QuestieTSP:TooltipEntered(v, size, uimapid, lookupTable, self)
                            end)
                            icon:SetScript("OnLeave", function(self)
                                for _, icon in pairs(QuestieTSP.glowIcons) do
                                    HBDPins:RemoveWorldMapIcon(Questie, icon)
                                end
                                QuestieTSP.glowIcons = {}
                                QuestieFramePool.Qframe.OnLeave(self)
                            end)
                            
                            icon:RegisterForClicks("RightButtonUp")

                            icon:SetScript("OnClick", function(self, button)
                                QuestieFramePool.Qframe.OnClick(self, button)
                            end)

                            icon.texture = icon.texture or icon:CreateTexture(nil, "OVERLAY", nil, 4)
                            icon.texture:SetAllPoints(icon)
                            --icon.texture:SetTexture("Interface/Minimap/ObjectIconsAtlas")
                            --icon.texture:SetTexCoord(0.0625, 0.125, 0.859375, 0.921875)
                            icon.texture:SetTexture(QuestieLib.AddonPath .. "Icons\\oval.blp", "CLAMP", "CLAMP", "TRILINEAR")
                            --icon.texture:SetVertexColor(index/#path,index/#path,index/#path,1)
                            icon.texture:SetVertexColor(data.color[1],data.color[2],data.color[3],1)
                            icon.texture:SetTexelSnappingBias(0)
                            icon.texture:SetSnapToPixelGrid(false)

                            local inset = 5

                            icon.texture2 = icon.texture2 or icon:CreateTexture(nil, "OVERLAY", nil, 5)
                            icon.texture2:SetPoint("TOPLEFT", icon ,"TOPLEFT", inset, -inset)
                            icon.texture2:SetPoint("BOTTOMRIGHT", icon ,"BOTTOMRIGHT", -inset, inset)
                            --icon.texture:SetTexture("Interface/Minimap/ObjectIconsAtlas")
                            --icon.texture:SetTexCoord(0.0625, 0.125, 0.859375, 0.921875)
                            --print(lookupTable[v][1])
                            icon.texture2:SetTexture(QuestieLib.AddonPath .. "Icons\\" .. data.icon, "CLAMP", "CLAMP", "TRILINEAR")
                            icon.texture2:SetVertexColor(1,1,1,1)
                            icon.texture2:SetTexelSnappingBias(0)
                            icon.texture2:SetSnapToPixelGrid(false)

                            local val = 0--math.floor(random()*5)
                            if val > 1 then
                                icon.texture3 = icon.texture3 or icon:CreateTexture(nil, "OVERLAY", nil, 5)
                                inset = 7
                                icon.texture3:SetPoint("TOPLEFT", icon ,"TOPLEFT", (15+inset), -(inset-11))
                                icon.texture3:SetPoint("BOTTOMRIGHT", icon ,"BOTTOMRIGHT", -(inset-15), inset+11)
                                icon.texture3:SetTexture(QuestieLib.AddonPath .. "Icons\\group.blp")
                                --icon.texture3:SetTexCoord(0.015625, 0.3125, 0.03125, 0.59375)
                                icon.texture3:SetTexelSnappingBias(0)
                                icon.texture3:SetSnapToPixelGrid(true)
                            else
                                if icon.texture3 then
                                    icon.texture3:Hide()
                                end
                            end

                            icon.isRoutePoint = true
                            icon.routeIndex = index

                            icon.data = {
                                ["Id"] = data.spawn.id,
                                ["Type"] = "Route",
                                ["populate"] = function(self, tbl)
                                    --local questId = data.spawn.questId

                                    --local quest = QuestieDB:GetQuest(questId)
                                    --local xp = GetQuestLogRewardXP(questId)
                            
                                    --if xp > 0 then
                                    --    GameTooltip:AddDoubleLine(QuestieDB:GetColoredQuestName(quest.Id, true, true), "(" .. tostring(xp).."xp)")
                                -- else
                                    --    GameTooltip:AddLine(QuestieDB:GetColoredQuestName(quest.Id, true, true))
                                    --end
                                
                                    if not icon.routeTooltipData then
                                        icon.buildTooltip()
                                        --print("Built tooltip!")
                                    end
                                    icon.buildTooltip()
                                    --print("copied tooltip!")
                                    --___TT = icon.routeTooltipData

                                    for k, v in pairs(icon.routeTooltipData) do
                                        tbl[k] = v
                                    end

                                    --tbl[QuestieDB:GetColoredQuestName(questId, true, true)] = {"Test!"}
                                end
                            }
                            icon.x = x * 100.0
                            icon.y = y * 100.0
                            icon.AreaID = ZoneDB:GetAreaIdByUiMapId(uimapid)
                            icon.UiMapID = uimapid

                            tinsert(QuestieTSP.buttons[uimapid], icon)
                        
                            icon:Hide()

                            if mapType == "world" then
                                local frameLevel = WorldMapFrame:GetFrameLevel() + 7
                                local frameStrata = WorldMapFrame:GetFrameStrata()
                                icon:SetParent(WorldMapFrame)
                                icon:SetFrameStrata(frameStrata)
                                icon:SetFrameLevel(frameLevel)
                                
                                HBDPins:AddWorldMapIconMap(Questie, icon, uimapid, x, y, HBD_PINS_WORLDMAP_SHOW_CURRENT)
                            else
                                local frameLevel = Minimap:GetFrameLevel() + 7
                                local frameStrata = Minimap:GetFrameStrata()
                                icon:SetParent(Minimap)
                                icon:SetFrameStrata(frameStrata)
                                icon:SetFrameLevel(frameLevel)
                                HBDPins:AddMinimapIconMap(Questie, icon, uimapid, x, y, true, true)
                            end
                        --HBDPins:AddWorldMapIconMap(Questie, icon, uimapid, x, y, HBD_PINS_WORLDMAP_SHOW_CURRENT)
                        --HBDPins:AddMinimapIconMap(Questie, icon, uimapid, x, y, true, true)
                            --addToMap(HBDPins, Questie, icon, uimapid, x, y, HBD_PINS_WORLDMAP_SHOW_CURRENT)
                            --icon.removeFromMap = removeFromMap



                            icon.buildTooltip = function()
                                local hitPoints = {}
                                local tooltip = {}
                                icon.hitPoints = hitPoints
                                local x, y = QuestieTSP:IDToCoord(v)
                                x = x * sizeX
                                y = y * sizeY
                                for _, val in pairs(QuestieTSP.paths[uimapid]) do
                                    --print("Checking " .. tostring(val) .. " against " .. tostring(v))
                                    local xh, yh = QuestieTSP:IDToCoord(val)
                                    xh = xh * sizeX
                                    yh = yh * sizeY
                                    
                                    xh = abs(xh - x)
                                    yh = abs(yh - y)
                                    
                                    local d = (xh^2+yh^2)^0.5

                                    if d < size * 2.5 then
                                        tinsert(hitPoints, val)
                                        --print("AlsoHit " .. tostring(val))
                                    end
                                end

                                for _, point in pairs(hitPoints) do
                                    if QuestieTSP.metadata[uimapid][point].spawn then
                                        local id = QuestieTSP.metadata[uimapid][point].spawn.questId
                                        if not tooltip[id] then
                                            tooltip[id] = {}
                                        end
                            
                                        tinsert(tooltip[id], QuestieTSP.metadata[uimapid][point].spawn)
                                    end
                                end

                                icon.routeTooltipData = {}
                                local first = true
                                for questId, objectives in pairs(tooltip) do
                            
                                    local key = QuestieLib:GetColoredQuestName(questId, true, true, true)
                                    local data = {}
                            
                                    icon.routeTooltipData[key] = data

                                    for _, objective in pairs(objectives) do
                                        --print(objective.name)
                                        --GameTooltip:AddLine(objective.name)
                                        tinsert(data, {["shift"]=true, ["text"]="  "..objective.name})
                                        for player in pairs(objective.players) do
                                            local progress = nil -- todo: optimize this with table when .logs is populated
                                            if QuestieTSP.logs[uimapid] and QuestieTSP.logs[uimapid][player] then
                                                for _, p in pairs(QuestieTSP.logs[uimapid][player][questId] or {}) do
                                                    if p.id == objective.objectiveId then
                                                        progress = p
                                                        break
                                                    end
                                                end
                                            end
                            
                                            if progress then
                                                --print("Progress for " .. objective.name)
                                                --GameTooltip:AddLine("   " .. tostring(progress.collected) .. "/" .. tostring(progress.needed) .. " " .. objective.name ..  " (|cFFFFFFFF" .. player .. "|r)" ,0.8,0.8,0.8)
                                                tinsert(data, {["text"]="    " .. tostring(progress.collected) .. "/" .. tostring(progress.needed) .. " " .. objective.name ..  " (|cFFFFFFFF" .. player .. "|r)"})
                                            else
                                                --print("No progress for " .. objective.name)
                                            end
                                        end 
                                    end 
                                end
                            end
                        end
                    end
                end

                --local zoneW, zoneH = HBD:GetZoneSize(GetPlayerZoneFixed())
                local distx = abs(lx-x) * 10133-- * zoneW
                local disty = abs(ly-y) * 6756-- * zoneH

                local nx = abs(lx-x) > lx-x and -1 or 1
                local ny = abs(ly-y) > ly-y and -1 or 1

                local dist = floor(sqrt((distx*distx) + (disty*disty)))
                --print("dist: " .. tostring(dist))

                local ratiox = (distx / dist)--distx / disty
                local ratioy = (disty / dist)

                dist = dist / 160

                --if lastIcon then
                --    dist = 16 -- consistent fading 
                --end

                for e=1,dist do
                    local icon = tremove(QuestieTSP.antCache) or CreateFrame("Frame")
                    --icon.texture:SetTexture("")

                    local size = 6
                    icon:SetFrameStrata("FULLSCREEN")
                    icon:SetWidth(size)
                    icon:SetHeight(size)
                    icon:SetPoint("CENTER", -size/2, -size/2)

                    icon.texture = icon.texture or icon:CreateTexture(nil, "OVERLAY", nil, 2)
                    icon.texture:SetAllPoints(icon)
                    icon.texture:SetTexture("Interface/Minimap/PartyRaidBlipsV2")
                    icon.texture:SetTexCoord(0.015625, 0.3125, 0.03125, 0.59375)
                    icon.texture:SetTexelSnappingBias(0)
                    icon.texture:SetSnapToPixelGrid(false)

                    if lastIcon then
                        icon.texture:SetVertexColor(0,0,0,0.5 * e/dist)
                    else
                        icon.texture:SetVertexColor(0,0,0,0.5)
                    end

                    icon.isRouteGraphic = true
                    icon.routeIndex = index

                    local f = (e+0.5) / dist -- 0.5 makes the dots centered, so the animation doesn't clip at the start or finish

                    --icon.step = icon.step or 0 -- prevents animation from skipping when changing the path

                    local function animation(self)
                        self:SetPoint(self:GetPoint())
                    end

                    if not icon._SetPoint then
                        icon._SetPoint = icon.SetPoint
                    end

                    -- I hook SetPoint to offset it immediately, to prevent animation glitches when updating ant trails
                    icon.SetPoint = function(self, ...)
                        local point = {...}
                        point[4] = -(nx * (QuestieTSP._animation_step * ratiox) / 1.3)
                        point[5] = (ny * (QuestieTSP._animation_step * ratioy) / 1.3)
                        self:_SetPoint(unpack(point))
                    end

                    icon:SetScript("OnUpdate", animation)
                    --icon:SetScript("OnShow", animation)
                    --animation(icon)

                    tinsert(QuestieTSP.ants[uimapid], icon)
                    HBDPins:AddWorldMapIconMap(Questie, icon, uimapid, x + (lx-x)*f, y + (ly-y)*f, HBD_PINS_WORLDMAP_SHOW_CURRENT)
                end
            end

            lx = x
            ly = y
        end
        QuestieTSP.running = nil
    end)
    QuestieTSP.TSP:SolveTSPBackground(nodes, nil, {}, uimapid, params, path)
end


local function deleteFrame(f)
    f:Hide()
    local globalName = f:GetName()
    for k,v in pairs(f) do
        f[k] = nil
    end
    if globalName then
        _G[globalName] = nil
    end
end

function TEST_DELETE()
    local count = 0
    C_Timer.NewTicker(0.001, function()
        for i=0,1000 do
            local frame = CreateFrame("Frame")
            frame:Show()
            deleteFrame(frame)
            count = count + 1
            print(count)
        end
        collectgarbage()
    end)
end





















































































































-- Modified by Aero for Questie
-- Changes I have made:
--  - Ensure the route always starts near the player (or another desired location, like a flight path)
--  - Ensure the route always ends near a one of a set of desired points (flight paths or boats)
--  - Modify logic to generate most efficient non-looping path possible. The original Routes implementation
--     was built for gathering nodes, and thus designed to build paths that are in a loop
--  - change coordinate system to use a 24bit integer, which increases precision and speed
--  - implement seeded random number generator to produce more consistent results across calls
--  - change error messages to work with questie
-- 

-- Original license:
----------------------------------
--[[
Ant Colony Optimization (ACO) for Travelling Salesman Problem (TSP)
for Routes (a World of Warcraft addon)

Copyright (C) 2011 Xinhuan

This program is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation; either version 2 of the License, or (at your option) any later
version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
this program; if not, write to the Free Software Foundation, Inc., 51 Franklin
Street, Fifth Floor, Boston, MA  02110-1301, USA.
]]

---------------------------------
--[[
Ant Colony Optimization and the Travelling Salesman Problem

The Travelling Salesman Problem (TSP) consists of finding the shortest tour
between n cities visiting each once only and ending at the starting point. Let
d(i,j) be the distance between cities i and j and t(i,j) the amount of pheromone
on the edge that connects i and j. t(i,j) is initially set to a small value
t(0), the same for all edges (i,j). The algorithm consists of a series of
iterations.

One iteration of the simplest ACO algorithm applied to the TSP can be summarized
as follows: (1) a set of m artificial ants are initially located at randomly
selected cities; (2) each ant, denoted by k, constructs a complete tour,
visiting each city exactly once, always maintaining a list J(k) of cities that
remain to be visited; (3) an ant located at city i hops to a city j, selected
among the cities that have not yet been visited, according to probability
p(k,i,j) = (t(i,j)^a * d(i,j)^-b) / sum(t(i,l)^a * d(i,l)^-b, all l in J(k))
where a and b are two positive parameters which govern the respective influences
of pheromone and distance; (4) when every ant has completed a tour, pheromone
trails are updated: t(i,j) = (1-p) * t(i,j) + D(t(i,j)), where p is the
evaporation rate and D(t(i,j)) is the amount of reinforcement received by edge
(i,j). D(t(i,j)) is proportional to the quality of the solutions in which (i,j)
was used by one ant or more. More precisely, if L(k) is the length of the tour
T(k) constructed by ant k, then D(t(i,j)) = sum(D(t(k,i,j)), 1 to m) with
D(t(k,i,j)) = Q / L(k) if (i,j) is in T(k) and D(t(k,i,j)) = 0 otherwise, where
Q is a positive parameter. This reinforcement procedure reflects the idea that
pheromone density should be lower on a longer path because a longer trail is
more difficult to maintain.

Steps (1) to (4) are repeated either a predefined number of times or until a
satisfactory solution has been found. The algorithm works by reinforcing
portions of solutions that belong to good solutions and by applying a
dissipation mechanism, pheromone evaporation, which ensures that the system does
not converge early toward a poor solution. When a = 0, the algorithm implements
a probabilistic greedy search, whereby the next city is selected solely on the
basis of its distance from the current city. When b = 0, only the pheromone is
used to guide the search, which would react the way the ants do it. However, the
explicit use of distance as a criterion for path selection appears to improve
the algorithm's performance. In all other optimization applications also, an
improvement in the algorithm's performance is observed when a local measure of
greed, similar to the inverse of distance for the TSP, is included into the
local selection of portions of solution by the agents. Typical parameter values
are: m = n, a = 1, b = 5, p = 0.5, t(0) = 1e-6.

-- Inspiration for optimization from social insect behaviour
-- by E. Bonabeau, M. Dorigo & G. Theraulaz
-- NATURE, VOL 406, 6 JULY 2000, www.nature.com
]]

-- Note:
-- The functions in this file are written specifically for use with Questie
-- in mind and is not a general TSP library.

----------------------------------
-- Localize some globals
local ipairs, pairs, type = ipairs, pairs, type
local random = random
local floor, ceil = floor, ceil
local coroutine = coroutine
local tinsert, tremove = tinsert, tremove
local debugprofilestop = debugprofilestop
local inf = math.huge

local pathR = {}
local lastpath
local TSP = {}
QuestieTSP.TSP = TSP


--------------------------------
-- Background execution

local nextYield = 0
local function yield()
	local t = debugprofilestop()
	if t > nextYield then
		nextYield = t + 30
		coroutine.yield()
	elseif t < nextYield then
		-- Someone called debugprofilestart(), we need to reset our timer, yield anyway
		nextYield = t + 30
		coroutine.yield()
	end
end


-----------------------------------------------------
-- Function to get the intersection point of 2 lines (x1,y1)-(x2,y2) and (sx,sy)-(ex,ey)
--[[ Unused function, its inlined in SolveTSP()
function TSP:GetIntersection(x1, y1, x2, y2, sx, sy, ex, ey)
	local dx = x2-x1
	local dy = y2-y1
	local numer = dx*(sy-y1) - dy*(sx-x1)
	local demon = dx*(sy-ey) + dy*(ex-sx)
	if demon == 0 or dx == 0 then
		return false
	else
		local u = numer / demon
		local t = (sx + (ex-sx)*u - x1)/dx
		if u >= 0 and u <= 1 and t >= 0 and t <= 1 then
			--return sx + (ex-sx)*u, sy + (ey-sy)*u -- coordinate of intersection
			return true
		end
	end
end]]


-----------------------------------------------------
-- Coroutine code to allow background pathing

local TSPUpdateFrame = CreateFrame("Frame")
TSPUpdateFrame.running = false

function TSPUpdateFrame:OnUpdate(elapsed)
	local status, path, meta, shortestPathLength, count, timetaken = coroutine.resume(self.co)
	if status then
		if coroutine.status(self.co) == "dead" then
			-- Function finished, return results
			self:SetScript("OnUpdate", nil)
            self.running = false
            ___path = path
            --self.finishFunc(path, meta, shortestPathLength, count, timetaken)
            local ok, err = pcall(self.finishFunc, path, meta, shortestPathLength, count, timetaken)
            if not ok then
                print(err)
            end


			self.finishFunc = nil
			self.statusFunc = nil
			self.co = nil
			self.nodes = nil
		end
	else
		-- An error occured in the coroutine, abort and print the error
		self:SetScript("OnUpdate", nil)
		self.running = false
		self.co = nil
		self.finishFunc = nil
		self.statusFunc = nil
		self.nodes = nil
		print("Questie encounted an error while generating a route, please report this on GitHub or Discord:")
		print(path)
	end
end

function TSP:IsTSPRunning()
	return TSPUpdateFrame.running, TSPUpdateFrame.nodes
end

local _random_state = 0
local function random(max)
    _random_state = (_random_state * 214013 + 2531011) % 2^32
    local rand = math.floor(_random_state / 2^16) % 2^15
    if max then
        return 1 + math.floor(rand / 0x7fff * max)
    else
        return rand / 0x7fff
    end
end

-- Same arguments as TSP:SolveTSP(), without the "nonblocking" argument
function TSP:SolveTSPBackground(nodes, metadata, taboos, zoneID, parameters, path)
    --print("Solve TSP Background!")
    _random_state = 0
	if not TSPUpdateFrame.running then
		TSPUpdateFrame.co = coroutine.create(TSP.SolveTSP)
		TSPUpdateFrame:SetScript("OnUpdate", TSPUpdateFrame.OnUpdate)
		TSPUpdateFrame.running = true
		TSPUpdateFrame.nodes = nodes
		local status, err = coroutine.resume(TSPUpdateFrame.co, TSP, nodes, metadata, taboos, zoneID, parameters, path, true)
		if status then
			-- Do nothing, path isn't complete because at least 1 yield() is called.
			return 1
		else
			-- An error occured in the coroutine, abort and return the error message.
			TSPUpdateFrame.running = false
			TSPUpdateFrame:SetScript("OnUpdate", nil)
            TSPUpdateFrame.co = nil
            print("Coroutine error!")
            print(err)
            ___path = err
			return 3, err
		end
	else
		-- There is already a TSP running
		return 2
	end
end

function TSP:SetFinishFunction(func)
	assert(type(func) == "function", "SetFinishFunction() expected function in 1st argument, got "..type(func).." instead.")
	TSPUpdateFrame.finishFunc = func
end

function TSP:SetStatusFunction(func)
	assert(type(func) == "function", "SetStatusFunction() expected function in 1st argument, got "..type(func).." instead.")
	TSPUpdateFrame.statusFunc = func
end


-----------------------------------
-- TSP:SolveTSP(nodes, metadata, zoneID, parameters, path, nonblocking)
-- Arguments
--   nodes       - The table containing a list of Routes node IDs to path
--                 This list should only contain nodes on the same map. This
--                 table should be indexed numerically from nodes[1] to nodes[n].
--   metadata    - The table containing the cluster metadata, if available
--   taboos      - A table containing a table of taboo regions to use.
--   zoneID      - The map area ID of the map that the route is to be generated on.
--   parameters  - The table containing the ACO parameters to use.
--   path        - An optional input table that is used to supply the result
--                 table. If this is nil, the function returns a new table.
--   nonblocking - A boolean to indicate whether the function should yield() regularly.
-- Returns
--   path        - The result TSP path is a table indexed numerically from path[1]
--                 to path[n], a list of Routes node IDs.
--   metadata    - The table containing the cluster metadata, if available
--   length      - The length in yards of the path returned.
--   iteration   - Number of interations taken.
--   timeTaken   - Number of seconds used.
-- Notes: A new nodes[] and metadata[] table is returned. The original tables
--        sent in are unmodified.
function TSP:SolveTSP(nodes, metadata, taboos, zoneID, parameters, path, nonblocking)
	-- Notes: Some of these code might look convoluted, with seemingly unnecessary use of too many locals
    -- and make the code look longer. But they are for speed optimization.
    --print("SolveTSP0")
	assert(type(nodes) == "table", "SolveTSP() expected table in 1st argument, got "..type(nodes).." instead.")
	assert(type(taboos) == "table", "SolveTSP() expected table in 3rd argument, got "..type(taboos).." instead.")
    assert(type(parameters) == "table", "SolveTSP() expected table in 5th argument, got "..type(parameters).." instead.")
    --print("SolveTSP2")
	if type(path) == "table" then
		wipe(path)
	else
		path = {}
	end

	if nonblocking then
        -- Ensure that at least 1 yield() is called in a nonblocking call
        --print("Yielding[1]")
		coroutine.yield()
    end

    local firstNode = nodes[1]

	-- Check for trivial problem of 3 or less nodes
	local numNodes = #nodes
	if numNodes < 3 then
		-- Trivial solution for an input size of 3 or less nodes
		for i = 1, numNodes do
			path[i] = nodes[i]
		end
		-- Create a copy of the metadata[] table too, if there is one
		local metadata2
		if metadata then
			metadata2 = {}
			for i = 1, numNodes do
				metadata2[i] = {}
				for j = 1, #metadata[i] do
					metadata2[i][j] = metadata[i][j]
				end
			end
        end
        --print("Returning[1]")
		return path, metadata2, TSP:PathLength(path, zoneID), 0, 0
    end
    
    nodes = TSP:DecrossRoute(nodes) -- pre-optimize nodes

	-- Create a copy of the nodes[] table and use this instead of the original because data could get changed
	local nodes2 = {}
	for i = 1, numNodes do
		nodes2[i] = nodes[i]
	end
	local nodes = nodes2
	-- Create a copy of the metadata[] table too, if there is one
	local metadata2
	if metadata then
		metadata2 = {}
		for i = 1, numNodes do
			metadata2[i] = {}
			for j = 1, #metadata[i] do
				metadata2[i][j] = metadata[i][j]
			end
		end
	end
	local metadata = metadata2
	
	-- Setup ACO parameters
	local startTime
	if nonblocking then
		startTime = GetTime()
	else
		startTime = debugprofilestop()
	end
	local zoneW, zoneH	= HBD:GetZoneSize(zoneID)

	local INITIAL_PHEROMONE = parameters.initial_pheromone or 0.1   -- Parameter: Initial pheromone trail value
	local ALPHA             = parameters.alpha or 1                 -- Parameter: Likelihood of ants to follow pheromone trails (larger value == more likely)
	local BETA              = parameters.beta or 6                  -- Parameter: Likelihood of ants to choose closer nodes (larger value == more likely)
	local LOCALDECAY        = parameters.local_decay or 0.2         -- Parameter: Governs local trail decay rate [0, 1]
	local LOCALUPDATE       = parameters.local_update or 0.4        -- Parameter: Amount of pheromone to reinforce local trail update by
	local GLOBALDECAY       = parameters.global_decay or 0.2        -- Parameter: Governs global trail decay rate [0, 1]
	local TWOOPTPASSES      = parameters.twoopt_passes or 3         -- Parameter: Number of times to perform 2-opt passes
	local TWOPOINTFIVEOPT   = parameters.two_point_five_opt or false-- Parameter: Run improved 2-opt pass?
	local QUALITY           = 2 * zoneH                             -- Parameter: Tunable parameter that should be somewhat close to 1/4 to 1/2 (distance) of a good solution
	local numAnts           = ceil(2 * numNodes ^ 0.5)              -- Parameter: Number of ants.
	local LOCALDECAYUPDATE  = LOCALDECAY * LOCALUPDATE              -- Just a constant.
	-- If ALPHA = 0, the closest cities are more likely to be selected.
	-- If BETA = 0, only pheromone amplifications is at work.
	-- The number of ants will directly determine the speed of the algorithm proportionally. More ants will get more optimal results, but don't use more ants than the number of nodes.
	-- You need more ants when there are more nodes to have more chances to find a good path quickly. The usual default is numAnts = numNodes, but this takes too long in WoW.
	local PRUNEDIST         = zoneW * 0.30                          -- Another constant for our own pruning

	local shortestPathLength = math.huge
	local shortestPath = {}

	-- Step 1	- Initialize and generate the weight matrix, the pheromone matrix and the ants
    local weight = {}
    local playerWeight = {}
	local phero = {}
	local ants = {}
	local prune = {}
	local antprob = {}
	for i = 1, numNodes do
		prune[i] = {}
	end

    local px, py = unpack(parameters.entryPoint)--GetPlayerMapPosition()--HBD:GetPlayerWorldPosition()
    --print("Entry Point: " .. tostring(px) .. " " .. tostring(py))
 
	for i = 1, numNodes do
		local x1, y1 = IDToCoords(nodes[i])--floor(nodes[i] / 10000) / 10000, (nodes[i] % 10000) / 10000
		local u = i*numNodes-i
        weight[u] = 0
        playerWeight[i] = (((px - x1)*zoneW)^2 + ((py - y1)*zoneH)^2)^0.5
		phero[u] = INITIAL_PHEROMONE
		for j = i+1, numNodes do
			local x2, y2 = IDToCoords(nodes[j])--floor(nodes[j] / 10000) / 10000, (nodes[j] % 10000) / 10000
			local u, v = i*numNodes-j, j*numNodes-i
            weight[u] = (((x2 - x1)*zoneW)^2 + ((y2 - y1)*zoneH)^2)^0.5 -- Calc distance between each node pair
            
			weight[v] = weight[u]
			phero[u] = INITIAL_PHEROMONE -- All pheromone trails start
            phero[v] = INITIAL_PHEROMONE -- with a initial small value


            --playerWeight[u] = (((px - x1)*zoneW)^2 + ((py - y1)*zoneH)^2)^0.5
            --playerWeight[v] = (((px - x2)*zoneW)^2 + ((py - y2)*zoneH)^2)^0.5
            
            -- account for distance to player
            --phero[u] = INITIAL_PHEROMONE + (((x2 - px)*zoneW)^2 + ((y2 - py)*zoneH)^2) + (((x1 - px)*zoneW)^2 + ((y1 - py)*zoneH)^2)
            --phero[v] = phero[u]

			-- Table containing data for 2-opt pruning operations. This is just a list of nodes that are near each node.
			if weight[u] < PRUNEDIST then
				tinsert(prune[i], j)
				tinsert(prune[j], i)
			end
			-- For taboo regions
			local flag = false
			for m = 1, #taboos do -- loop over every taboo
				local taboo_data = taboos[m].route
				local last_point = taboo_data[ #taboo_data ]
				local sx, sy = IDToCoords(last_point)--floor(last_point / 10000) / 10000, (last_point % 10000) / 10000
				for n = 1, #taboo_data do
					local point = taboo_data[n]
					local ex, ey =IDToCoords(point) --floor(point / 10000) / 10000, (point % 10000) / 10000
					-- inlined the intersection check so that it is faster
					local dx = x2-x1
					local dy = y2-y1
					local numer = dx*(sy-y1) - dy*(sx-x1)
					local demon = dx*(sy-ey) + dy*(ex-sx)
					if demon ~= 0 and dx ~= 0 then
						local u = numer / demon
						local t = (sx + (ex-sx)*u - x1)/dx
						if u >= 0 and u <= 1 and t >= 0 and t <= 1 then
							flag = true
							break
						end
					end
					sx, sy = ex, ey
					last_point = point
				end
				if flag then break end
			end
			if flag then -- we increase/bias the weight by a constant factor and by the zone width, since it passes thru a taboo region
				weight[u] = weight[u] * 2 + zoneW
				weight[v] = weight[u]
			end

			-- Initialize the probability table of travelling from city i to j
			antprob[u] = phero[u] ^ ALPHA / weight[u] ^ BETA
			antprob[v] = antprob[u]
		end
	end
	for k = 1, numAnts do
		ants[k] = {}
		local antpath = ants[k] -- This table will stores both the partially constructed path (from 1 to j) and the remainder unvisited nodes (from j+1 to N)
		for j = 1, numNodes do
			antpath[j] = j
		end
	end
    --print("solvetsp")
	-- Step 2	- Loop until path has small to no changes over the last MAXUNCHANGEDINTERATION iterations
	local nochanges = 0
	local count = 0
	local MAXUNCHANGEDINTERATION = 3
	if numAnts >= 25 then
		MAXUNCHANGEDINTERATION = 2
	end
	while nochanges < MAXUNCHANGEDINTERATION do
		nochanges = nochanges + 1
		count = count + 1
		
		-- Step 3	- Each ant k starts at a randomly selected node
		for k = 1, numAnts do
			local antpath = ants[k]
			local p = random(numNodes)
			antpath[1], antpath[p] = antpath[p], antpath[1]
		end

		-- Step 4	- Construct/path the next N-1 nodes...
		for j = 1, numNodes-1 do
			-- Step 5	- ...for each ant k
			for k = 1, numAnts do
				-- Step 6	- Calculate the probability of visiting each remainder node, and the total probability
				local antpath = ants[k]
				local curnode = antpath[j] -- j is the "current node" index in the path
				local totalprob = 0
				for i = j+1, numNodes do
					local u = curnode*numNodes-antpath[i]
					totalprob = totalprob + antprob[u]
				end
				-- Step 7	- Now randomly choose one of these nodes to go to based on the calculated probabilities
				local p = totalprob * random()
				totalprob = 0
				for i = j+1, numNodes do
					local u = curnode*numNodes-antpath[i]
					totalprob = totalprob + antprob[u]
					if p <= totalprob then
						antpath[j+1], antpath[i] = antpath[i], antpath[j+1]
						phero[u] = (1 - LOCALDECAY) * phero[u] + LOCALDECAYUPDATE -- Perform local pheromone update
						antprob[u] = phero[u] ^ ALPHA / weight[u] ^ BETA -- Update the probability
						break
					end
				end
			end
            if nonblocking then
                --print("Yielding[2]")
				yield()
			end
		end

		for k = 1, numAnts do
			-- Send out status update if requested  (this loop is the one that actually takes lots of time)
			if nonblocking and TSPUpdateFrame.statusFunc then
				TSPUpdateFrame.statusFunc(count, (k-1)/numAnts)
			end
			-- Step 8	-- Perform local pheromone update on the path from the last node to the first node for each ant k
			local antpath = ants[k]
			local curnode = antpath[numNodes]
			local nextnode = antpath[1]
			local u = curnode*numNodes-nextnode
			phero[u] = (1 - LOCALDECAY) * phero[u] + LOCALDECAYUPDATE
			antprob[u] = phero[u] ^ ALPHA / weight[u] ^ BETA

            -- Step 9	-- Perform 2-opt on the path to improve it
            -- was disabled(questie)
			for i = 1, TWOOPTPASSES do
				if nonblocking then
					yield()
				end
				if TSP:TwoOpt(antpath, weight, prune) == 0 then
					break
				end
			end
			while TSP:TwoOpt(antpath, weight, prune, TWOPOINTFIVEOPT, nonblocking) > 0 do
				-- Cycle the last 3 nodes so that the 2-opt algorithm will work on the last
				-- 3 nodes in the path that got missed (the loop goes from 1 to N-3)
				tinsert(antpath, tremove(antpath, 1))
				tinsert(antpath, tremove(antpath, 1))
				tinsert(antpath, tremove(antpath, 1))
				if nonblocking then
					yield()
				end
			end

			-- Step 10	-- At the same time, we also calculate the length of each ant's tour
            local pathLength = 0
            
            -- account for player location
            pathLength = playerWeight[antpath[1]]
            

            -- we dont want a loop forced (questie)

			curnode = nil--antpath[numNodes]
			for i = 1, numNodes do
                nextnode = antpath[i]
                if curnode then
                    pathLength = pathLength + weight[curnode*numNodes-nextnode]
                end
				curnode = nextnode
			end

			-- Step 11	-- If this ant's path is shorter than the global shortest known solution, copy it
			if pathLength < shortestPathLength then
				shortestPathLength = pathLength
				for i = 1, numNodes do
					shortestPath[i] = antpath[i]
				end
				nochanges = 0 -- There were changes, so reset nochanges counter to 0
			end
		
		end
			
		-- Step 12	- Perform global pheromone trail update on the best known solution
		local curnode = shortestPath[numNodes]
		local tempConstant = GLOBALDECAY * QUALITY / shortestPathLength
		for i = 1, numNodes do
			local nextnode = shortestPath[i]
			local u = curnode*numNodes-nextnode
			phero[u] = (1 - GLOBALDECAY) * phero[u] + tempConstant
			antprob[u] = phero[u] ^ ALPHA / weight[u] ^ BETA -- Update the probability
			curnode = nextnode
		end
		
		-- report how long path this round found (with progress==1)
		if nonblocking and TSPUpdateFrame.statusFunc then
            TSPUpdateFrame.statusFunc(count, 1, shortestPathLength)
            --print("Yielding[3]")
			yield()
		end
	end
    if false then -- since quests don't work like gathering routes, we dont need this
        do
            -- Perform a non-pruned 2-opt on the final path so that there is absolutely no criss-cross
            local noprune = {}
            for i = 1, numNodes do
                noprune[i] = {}
            end
            for i = 1, numNodes do
                for j = i+1, numNodes do
                    tinsert(noprune[i], j)
                    tinsert(noprune[j], i)
                end
            end
            while TSP:TwoOpt(shortestPath, weight, noprune, TWOPOINTFIVEOPT, nonblocking) > 0 do
                tinsert(shortestPath, tremove(shortestPath, 1))
                tinsert(shortestPath, tremove(shortestPath, 1))
                tinsert(shortestPath, tremove(shortestPath, 1))
                if nonblocking then
                    print("Yielding[4]")
                    yield()
                end
            end
            
            -- Recompute the path length
            shortestPathLength = 0
            
            -- account for player location
            shortestPathLength = playerWeight[shortestPath[1]]

            local curnode = nil--shortestPath[numNodes] (questie)
            for i = 1, numNodes do
                local nextnode = shortestPath[i]
                if curNode then
                    shortestPathLength = shortestPathLength + weight[curnode*numNodes-nextnode]
                end
                curnode = nextnode
            end
        end
    end

	-- Step 13	-- Check the length of the original tour that was sent in in nodes[]
	local pathLength = playerWeight[1]
	for i = 2, numNodes do
		pathLength = pathLength + weight[(i-1)*numNodes-i]
    end
    
    -- we dont need a loop (questie)
	--pathLength = pathLength + weight[numNodes*numNodes-1]

	-- Step 14	-- Check solution with original that was sent in
	if pathLength < shortestPathLength then
		-- TSP didn't find a shorter solution, so copy the input to the output
		for i = 1, numNodes do
			path[i] = nodes[i]
		end
		shortestPathLength = pathLength
	else
		-- TSP found a shorter path than the original, convert our shortest path to the output format wanted
		local meta
		if metadata then
			meta = {}
		end
		for i = 1, numNodes do
			path[i] = nodes[shortestPath[i]]
			if metadata then
				meta[i] = metadata[shortestPath[i]]
			end
		end
		metadata = meta -- prev metadata[] not recycled here, will go out of scope at function end and get GCed
	end

	lastpath = nil

	-- This step is necessary because our pathlength above is calculated from biased data from taboos
	shortestPathLength = TSP:PathLength(path, zoneID)

	if nonblocking then
		startTime = GetTime() - startTime
	else
		startTime = debugprofilestop() - startTime
		startTime = startTime / 1000
    end
    --print("Returning[2]"..tostring(GetTime()))
    --print("Shortest path: " .. tostring(shortestPathLength))


    -- force player node to start of path
    local fixedPath = {}
    tinsert(fixedPath, firstNode)
    for _, v in pairs(path) do
        if v ~= firstNode then
            tinsert(fixedPath, v)
        end
    end


	return fixedPath, metadata, shortestPathLength, count, startTime
end

-- TSP:TwoOpt(path, weight)
-- Arguments
--   path   - The table containing a TSP path to improve. Input must have node IDs 1-N, numerically indexed.
--   weight - The table containing the NxN weight matrix.
--   prune  - The table containing the list of neighbouring nodes for each node.
--   twoPointFiveOpt - A boolean indicating whether to perform 2.5-opt.
--   nonblocking - A boolean indicating whether the function should yield() regularly.
-- Returns
--   count  - The number of 2-opt replacements made to path[]
--[[
Typically TSP tour refinement takes place by "flipping" edges. For example, if
the tour contains the edges (v1, w1) and (w2, v2) in that order, then these two
edges can always be flipped to create (v1, w2) and (w1, v2). This sort of step
forms the basis of the 2-opt algorithm which is a steepest descent approach,
repeatedly flipping pairs of edges if they improve the tour quality until it
reaches a local minimum of the objective function and no more such flips exist.

In a similar vein, the 3-opt algorithm exchanges 3 edges at a time. These are
more specific versions of the Lin-Kernighan (LK) algorithm or better known as
the N-opt or variable-opt algorithm.

-- A Multilevel Lin-Kernighan-Helsgaun Algorithm for the Travelling Salesman Problem
-- Chris Walshaw, September 27, 2001.
]]
function TSP:TwoOpt(path, weight, prune, twoPointFiveOpt, nonblocking)
	local count = 0
	local numNodes = #path
	local pathR = pathR

	-- Generate reverse lookup table
	if lastpath ~= path then
		for i = 1, numNodes do
			pathR[path[i]] = i
		end
	end

	-- Perform normal 2-opt
	for i = 1, numNodes-3 do
		local a, b = path[i], path[i+1]
		local z = weight[a*numNodes-b]
		--for j = i+2, numNodes-1 do
		for m = 1, #prune[a] do
			local j = pathR[prune[a][m]]
			if j > i+1 and j ~= numNodes then
				local c, d = path[j], path[j+1]
				local currW = z + weight[c*numNodes-d]
				local newW = weight[a*numNodes-c] + weight[b*numNodes-d]
				if newW < currW then
					-- Swap these 2 edges to get a shorter path
					-- This is done by reversing the node order between i+1 to j
					local left = i+1
					local right = j
					while left < right do
						local L, R = path[right], path[left]
						path[left], path[right] = L, R
						pathR[L], pathR[R] = left, right
						left = left + 1
						right = right - 1
					end
					b = path[i+1]
					z = weight[a*numNodes-b]
					count = count + 1
				end
			end
		end
	end

	-- Then perform 2.5-opt
	if twoPointFiveOpt then
		if nonblocking then
			yield()
		end
		for i = 1, numNodes-4 do
			local a, b, c = path[i], path[i+1], path[i+2]
			local z = weight[a*numNodes-b] + weight[b*numNodes-c]
			for m = 1, #prune[a] do
				local j = pathR[prune[a][m]]
				if j > i+2 and j ~= numNodes then
					local d, e = path[j], path[j+1]
					local currW = z + weight[d*numNodes-e]
					local newW = weight[a*numNodes-c] + weight[d*numNodes-b] + weight[b*numNodes-e]
					if newW < currW then
						-- Remove node b from the path, then reinsert it between d and e
						for q = i+1, j-1 do
							path[q] = path[q+1]
							pathR[path[q]] = q
						end
						path[j] = b
						pathR[b] = j
						b, c = path[i+1], path[i+2]
						z = weight[a*numNodes-b] + weight[b*numNodes-c]
						count = count + 1
					end
				end
			end
		end
	end

	lastpath = path
	return count
end

-- Helper function for TSP:InsertNode()
-- Tries to insert node into an existing cluster
-- Returns true if successful, false otherwise
local function tryInsert(nodes, metadata, insertPoint, nodeID, radius, zoneW, zoneH)
	local x, y = IDToCoords(nodeID)--floor(nodeID / 10000) / 10000, (nodeID % 10000) / 10000
	local x2, y2 = IDToCoords(nodes[insertPoint])--floor(nodes[insertPoint] / 10000) / 10000, (nodes[insertPoint] % 10000) / 10000
	-- Calculate the new centroid and coord
	local num = #metadata[insertPoint]
	x2, y2 = (x2*num+x)/(num+1), (y2*num+y)/(num+1)
	local coord = coordToID(x2, y2)--floor(x2 * 10000 + 0.5) * 10000 + floor(y2 * 10000 + 0.5)
	x2, y2 = IDToCoords(coord)--floor(coord / 10000) / 10000, (coord % 10000) / 10000 -- to round off the coordinate
	-- Check that the merged point is valid
	for i = 1, num do
		local coord = metadata[insertPoint][i]
		local x, y = IDToCoords(coord)--floor(coord / 10000) / 10000, (coord % 10000) / 10000
		local t = (((x2 - x)*zoneW)^2 + ((y2 - y)*zoneH)^2)^0.5
		if t > radius then
			return false
		end
	end
	tinsert(metadata[insertPoint], nodeID)
	nodes[insertPoint] = coord
	return true
end

-- TSP:InsertNode(nodes, zoneID, nodeID, twoOpt, path)
--   Inserts a node into an existing route.
-- Arguments
--   nodes       - The table containing a list of Routes node IDs to path
--                 This list should only contain nodes on the same map. This
--                 table should be indexed numerically from nodes[1] to nodes[n].
--   metadata    - The table containing the cluster metadata, if available
--   zoneID      - The map area ID of the map that the route is on.
--   nodeID      - The Routes node ID to insert into the route.
-- Returns
--   pathLength  - The length of the route in yards.
-- Notes: This function modifies the original nodes[] and metadata[] tables
--        directly
function TSP:InsertNode(nodes, metadata, zoneID, nodeID, radius)
	assert(type(nodes) == "table", "InsertNode() expected table in 1st argument, got "..type(nodes).." instead.")

	-- Check for trivial problem of 2 or less nodes
	local numNodes = #nodes
	if numNodes < 3 then
		-- Trivial solution for an input size of 2 or less nodes
		nodes[numNodes+1] = nodeID
		if metadata then
			metadata[numNodes+1] = {nodeID}
		end
		return TSP:PathLength(nodes, zoneID)
	end

	-- Insert the node to be added at the end of the list.
	tinsert(nodes, nodeID)
	numNodes = #nodes

	-- Step 1	- Initialize and generate the weight matrix, and prune matrix if doing 2-opt
	local zoneW, zoneH = HBD:GetZoneSize(zoneID)
	local weight = {}

	-- Not doing a twoopt means we only need to generate O(2n) entries in the weight table
	local x, y, x2, y2
	for i = 1, numNodes-2 do
		-- for every node i, calculate its distance to node i+1
		x, y = IDToCoords(nodes[i])--floor(nodes[i] / 10000) / 10000, (nodes[i] % 10000) / 10000
		x2, y2 = IDToCoords(nodes[i+1])--floor(nodes[i+1] / 10000) / 10000, (nodes[i+1] % 10000) / 10000
		weight[i*numNodes-(i+1)] = (((x2 - x)*zoneW)^2 + ((y2 - y)*zoneH)^2)^0.5 -- Calc distance
	end
	-- do looparound node
	x, y = IDToCoords(nodes[numNodes-1])--floor(nodes[numNodes-1] / 10000) / 10000, (nodes[numNodes-1] % 10000) / 10000
	x2, y2 = IDToCoords(nodes[1])--floor(nodes[1] / 10000) / 10000, (nodes[1] % 10000) / 10000
	weight[(numNodes-1)*numNodes-1] = (((x2 - x)*zoneW)^2 + ((y2 - y)*zoneH)^2)^0.5 -- Calc distance
	-- calc distance for every node to the node to be inserted
	x2, y2 = IDToCoords(nodes[numNodes])--floor(nodes[numNodes] / 10000) / 10000, (nodes[numNodes] % 10000) / 10000
	for i = 1, numNodes-1 do
		x, y = IDToCoords(nodes[i])--floor(nodes[i] / 10000) / 10000, (nodes[i] % 10000) / 10000
		local u, v = i*numNodes-numNodes, numNodes*numNodes-i
		weight[u] = (((x2 - x)*zoneW)^2 + ((y2 - y)*zoneH)^2)^0.5 -- Calc distance
		weight[v] = weight[u]
	end

	-- Step 2	- Find the best place to insert the node
	local shortestPathLength = math.huge -- Some large value
	local insertPoint
	for i = 1, numNodes-2 do
		local z = weight[i*numNodes-numNodes] + weight[numNodes*numNodes-(i+1)] - weight[i*numNodes-(i+1)]
		if z < shortestPathLength then
			shortestPathLength = z
			insertPoint = i + 1
		end
	end
	if weight[(numNodes-1)*numNodes-numNodes] + weight[numNodes*numNodes-1] - weight[(numNodes-1)*numNodes-1] < shortestPathLength then
		-- Do nothing, inserting the node at the last place is the best, already inserted here.
		if metadata then
			tremove(nodes)
			local try1, try2 = numNodes-1, 1
			if weight[(numNodes-1)*numNodes-numNodes] > weight[numNodes*numNodes-1] then
				try1, try2 = try2, try1 -- try the closer node first
			end
			local flag = tryInsert(nodes, metadata, try1, nodeID, radius, zoneW, zoneH)
			if not flag then
				flag = tryInsert(nodes, metadata, try2, nodeID, radius, zoneW, zoneH)
			end
			if not flag then -- both clusters failed, so insert a new cluster
				tinsert(nodes, nodeID)
				tinsert(metadata, {nodeID})
			end
		end
	else
		-- Remove it from the last place in the path and insert it at the best place found.
		tremove(nodes)
		if metadata then
			local try1, try2 = insertPoint-1, insertPoint
			if weight[(insertPoint-1)*numNodes-numNodes] > weight[numNodes*numNodes-insertPoint] then
				try1, try2 = try2, try1
			end
			local flag = tryInsert(nodes, metadata, try1, nodeID, radius, zoneW, zoneH)
			if not flag then
				flag = tryInsert(nodes, metadata, try2, nodeID, radius, zoneW, zoneH)
			end
			if not flag then
				tinsert(nodes, insertPoint, nodeID)
				tinsert(metadata, insertPoint, {nodeID})
			end
		else
			tinsert(nodes, insertPoint, nodeID)
		end
	end

	return TSP:PathLength(nodes, zoneID)
end


-- TSP:PathLength(nodes, zoneID)
--   Returns how long a given route is in yards.
-- Arguments
--   nodes      - The table containing a list of Routes node IDs to path
--                This list should only contain nodes on the same map. This
--                table should be indexed numerically from nodes[1] to nodes[n].
--   zoneID     - The map area ID of the map that the route is on.
-- Returns
--   pathLength - The length of the route in yards.
function TSP:PathLength(nodes, zoneID)
	assert(type(nodes) == "table", "PathLength() expected table in 1st argument, got "..type(nodes).." instead.")
	local zoneW, zoneH = HBD:GetZoneSize(zoneID)
	local numNodes = #nodes
	local pathLength = 0

	-- Check for trivial problem of 1 or less nodes
	if numNodes <= 1 then
		return 0
	end

	-- Get coordinate of last node
	local x2, y2 = IDToCoords(nodes[numNodes])--floor(nodes[numNodes] / 10000) / 10000, (nodes[numNodes] % 10000) / 10000
	for i = 1, #nodes do
		local x, y = IDToCoords(nodes[i])--floor(nodes[i] / 10000) / 10000, (nodes[i] % 10000) / 10000
		pathLength = pathLength + (((x2 - x)*zoneW)^2 + ((y2 - y)*zoneH)^2)^0.5
		x2, y2 = x, y
	end

	return pathLength
end

-- TSP:ClusterRoute(nodes, zoneID, radius)
-- Arguments
--   nodes    - The table containing a list of Routes node IDs to path
--              This list should only contain nodes on the same map. This
--              table should be indexed numerically from nodes[1] to nodes[n].
--   zoneID   - The map area ID the route is in
--   radius   - The radius in yards to cluster
-- Returns
--   path     - The result TSP path is a table indexed numerically from path[1]
--              to path[n], a list of Routes node IDs. n is usually smaller than
--              the original input
--   metadata - The metadata table for path[] containing the original nodes
--              clustered
--   length   - The length of the new route in yards
-- Notes: The original table sent in is unmodified. New tables are returned.
--[[
Hierarchical Agglomerative Clustering

Data clustering algorithms can be hierarchical or partitional. Hierarchical
algorithms find successive clusters using previously established clusters,
whereas partitional algorithms determine all clusters at once. Hierarchical
algorithms can be agglomerative ("bottom-up") or divisive ("top-down").
Agglomerative algorithms begin with each element as a separate cluster and
merge them into successively larger clusters. Divisive algorithms begin with
the whole set and proceed to divide it into successively smaller clusters.

This method (Agglomerative) builds the hierarchy from the individual elements
by progressively merging clusters. The first step is to determine which
elements to merge in a cluster. Usually, we want to take the two closest
elements, according to the chosen distance.

Optionally, one can also construct a distance matrix at this stage, where the
number in the i-th row j-th column is the distance between the i-th and j-th
elements. Then, as clustering progresses, rows and columns are merged as the
clusters are merged and the distances updated. This is a common way to
implement this type of clustering, and has the benefit of catching distances
between clusters.

-- From Wikipedia, Cluster analysis
-- http://en.wikipedia.org/wiki/Cluster_analysis
-- 25 January 2008
]]
function TSP:ClusterRoute(nodes, zoneID, radius)
	local weight = {} -- weight matrix
	local metadata = {} -- metadata after clustering

	local numNodes = #nodes
	local zoneW, zoneH = HBD:GetZoneSize(zoneID)
	local diameter = radius * 2
	--local taboo = 0

	-- Create a copy of the nodes[] table and use this instead of the original because we want to modify this table
	local nodes2 = {}
	for i = 1, numNodes do
		nodes2[i] = nodes[i]
		weight[i] = {} -- make weight[] a 2-dimensional table
	end
	local nodes = nodes2

	-- Step 1: Generate the weight table
	for i = 1, numNodes do
		local coord = nodes[i]
		local x, y = IDToCoords(coord)--floor(coord / 10000) / 10000, (coord % 10000) / 10000
		local w = weight[i]
		w[i] = 0
		for j = i+1, numNodes do
			local coord = nodes[j]
			local x2, y2 = IDToCoords(coord)--floor(coord / 10000) / 10000, (coord % 10000) / 10000
			w[j] = (((x2 - x)*zoneW)^2 + ((y2 - y)*zoneH)^2)^0.5 -- Calc distance between each node pair
			weight[j][i] = true -- dummy value just to fill the lower half of the table so that tremove() will work on it
		end
	end

	-- Step 2: Generate the initial metadata tables
	for i = 1, numNodes do
		metadata[i] = {}
		metadata[i][1] = nodes[i]
	end

	-- Step 5: ...and loop until there is no such pair of nodes
	while true do
		-- Step 3: Find the closest pair of nodes within the merge radius
		local smallestDist = inf
		local node1, node2
		for i = 1, numNodes-1 do
			local w = weight[i]
			for j = i+1, numNodes do
				local w2 = w[j]
				if w2 <= diameter and w2 < smallestDist then
					smallestDist = w2
					node1 = i
					node2 = j
				end
			end
		end
		-- Step 4: Merge node2 into node1...
		if node1 then
			local m1, m2 = metadata[node1], metadata[node2]
			local node1num, node2num = #m1, #m2
			local totalnum = node1num + node2num
			-- Calculate the new centroid of node1
            local n1, n2 = nodes[node1], nodes[node2]
            
            local n1x, n1y = IDToCoords(n1)
            local n2x, n2y = IDToCoords(n2)

            local node1x = (n1x * node1num + n2y * node2num) / totalnum
            local node1y = (n1y * node1num + n2x * node2num) / totalnum

			--local node1x = ( floor(n1 / 10000) / 10000 * node1num + floor(n2 / 10000) / 10000 * node2num ) / totalnum
			--local node1y = ( (n1 % 10000) / 10000 * node1num + (n2 % 10000) / 10000 * node2num ) / totalnum
			-- Calculate the new coord from the new (x,y)
			local coord = coordToID(node1x, node1y)--floor(node1x * 10000 + 0.5) * 10000 + floor(node1y * 10000 + 0.5)
			node1x, node1y = IDToCoords(coord)--floor(coord / 10000) / 10000, (coord % 10000) / 10000 -- to round off the coordinate
			-- Check that the merged point is valid
			for i = 1, node1num do
				local coord = m1[i]
				local x, y = IDToCoords(coord)--floor(coord / 10000) / 10000, (coord % 10000) / 10000
				local t = (((node1x - x)*zoneW)^2 + ((node1y - y)*zoneH)^2)^0.5
				if t > radius then
					-- Merging this node will cause the merged point to be too far away
					-- from an original point, so taboo it by making the weight infinity
					-- And store a backup in the lower half of the table
					weight[node2][node1] = weight[node1][node2]
					weight[node1][node2] = inf
					--taboo = taboo + 1
					break
				end
			end
			if weight[node1][node2] ~= inf then
				for i = 1, node2num do
					local coord = m2[i]
					local x, y = IDToCoords(coord)--floor(coord / 10000) / 10000, (coord % 10000) / 10000
					local t = (((node1x - x)*zoneW)^2 + ((node1y - y)*zoneH)^2)^0.5
					if t > radius then
						weight[node2][node1] = weight[node1][node2]
						weight[node1][node2] = inf
						--taboo = taboo + 1
						break
					end
				end
			end
			if weight[node1][node2] ~= inf then
				-- Merge the metadata of node2 into node1
				for i = 1, node2num do
					tinsert(m1, m2[i])
				end
				-- Set the new coord of node1
				nodes[node1] = coord
				-- Delete node2 from metadata[]
				tremove(metadata, node2)
				-- Delete node2 from nodes[]
				tremove(nodes, node2)
				-- Remove node2 from the weight table
				for i = 1, numNodes do
					tremove(weight[i], node2) -- remove column
				end
				tremove(weight, node2) -- remove row
				-- Update number of nodes
				numNodes = numNodes - 1
				-- Update the weight table for all nodes relating to node1, this can untaboo nodes
				for i = 1, node1-1 do
					local coord = nodes[i]
					local x, y = IDToCoords(coord)--floor(coord / 10000) / 10000, (coord % 10000) / 10000
					weight[i][node1] = (((node1x - x)*zoneW)^2 + ((node1y - y)*zoneH)^2)^0.5
				end
				for i = node1+1, numNodes do
					local coord = nodes[i]
					local x, y = IDToCoords(coord)--floor(coord / 10000) / 10000, (coord % 10000) / 10000
					weight[node1][i] = (((node1x - x)*zoneW)^2 + ((node1y - y)*zoneH)^2)^0.5
				end
			end
		else
			break -- loop termination
		end
	end

	-- Get the new pathLength
	local pathLength = weight[1][numNodes]
	pathLength = pathLength == inf and weight[numNodes][1] or pathLength
	for i = 1, numNodes-1 do
		local w = weight[i][i+1]
		pathLength = pathLength + (w == inf and weight[i+1][i] or w) -- use the backup in the lower half of the triangle if it was tabooed
	end

	--ChatFrame1:AddMessage(taboo.." tabooed")
	return nodes, metadata, pathLength
end



-- TSP:DecrossRoute(nodes)
-- Arguments
--   nodes    - The table containing a list of Routes node IDs to path
--              This list should only contain nodes on the same map. This
--              table should be indexed numerically from nodes[1] to nodes[n].
-- Returns nothing
-- Notes: The original table sent in is modified directly
-- 
-- This function is contributed by Polarina for quickly solving a TSP in
-- O(n log n). The method merely calculates a centroid, and compares the angle
-- of every node with the centroid and sorts it that way, resulting in a tour
-- that doesn't cross itself, but obviously not ideal. Used for initial route
-- creation to get an initial quality value.

function __TEST_DROPS()
    local tc = 0
    GogoLoot_Config.____DROPS = ""
    for e=1,65000 do
        local item = QuestieDB:GetItem(e)
        if item and item.objectDrops and item.npcDrops then
            if #item.objectDrops > 0 and #item.npcDrops > 0 then
                print(e)
                tc = tc + 1
                GogoLoot_Config.____DROPS = GogoLoot_Config.____DROPS .. ", " .. tostring(e)
            end
        end
    end
    print("Total potential bad items: " .. tostring(tc))
end


function TSP:DecrossRoute(nodes)
	local numNodes = #nodes
	local math_atan2 = math.atan2

	-- Find the nodes centroid
	local x, y = 0, 0
    for index, value in ipairs(nodes) do
        local tx, ty = IDToCoords(value)
		x = x + tx
		y = y + ty
	end
	x = x / numNodes
	y = y / numNodes

	-- From the middle, link all nodes in a circle
    table.sort(nodes, function(a, b)
        local aX, aY = IDToCoords(a)
        local bX, bY = IDToCoords(b)
		--local aX = floor(a / 1e4)
		--local aY = a % 1e4
		--local bX = floor(b / 1e4)
		--local bY = b % 1e4
		return math_atan2(aY - y, aX - x) < math_atan2(bY - y, bX - x)
	end)

	--[[
	local weight = {}
	local path = {}
	local prune = {}
	for i = 1, numNodes do
		prune[i] = {}
	end

	for i = 1, numNodes do
		local x1, y1 = floor(nodes[i] / 10000) / 10000, (nodes[i] % 10000) / 10000
		local u = i*numNodes-i
		weight[u] = 0
		for j = i+1, numNodes do
			local x2, y2 = floor(nodes[j] / 10000) / 10000, (nodes[j] % 10000) / 10000
			local u, v = i*numNodes-j, j*numNodes-i
			weight[u] = ((x2 - x1)^2 + (y2 - y1)^2)^0.5 -- Calc distance between each node pair
			weight[v] = weight[u]
			--if weight[u] < 0.4 then
				tinsert(prune[i], j)
				tinsert(prune[j], i)
			--end
		end
		path[i] = i
	end

	while TSP:TwoOpt(path, weight, prune, false, false) > 0 do end

	local newpath = {}
	for i = 1, numNodes do
		newpath[i] = nodes[ path[i] ]
	end

	return newpath]]

	return nodes
end

-- vim: ts=4 noexpandtab


function getZoneSummary(zone)
    --print("Getting summary for " .. tostring(zone))
    print("Available Quests:")
    local availables = Questie.db.char.availablePerZone[zone]
    if availables then
        for _, q in pairs(availables) do
            print("   " .. QuestieLib:GetColoredQuestName(q, true, true, true))
        end
    end
end

function ZONE_SUMMARY()
    getZoneSummary(ZoneDB:GetAreaIdByUiMapId(GetPlayerZoneFixed()))
end




function TEST_QUEST_SUMMARY(id) -- run TEST_QUEST_SUMMARY(5722)

    local quest = QuestieDB:GetQuest(id)

    local AceGUI = LibStub("AceGUI-3.0")
    local frame = AceGUI:Create("Frame")
    frame.frame:SetFrameStrata("DIALOG")

    frame:SetTitle(nil)
    frame:SetLayout("Fill")
    frame:SetWidth(465)
    frame:SetHeight(550)

    local function labelLarge(widget, text, width)
        local label = AceGUI:Create("Label")
        label:SetFontObject(GameFontHighlight)
        label:SetText(text)
        label:SetFontObject(GameFontHighlightLarge)
        if width then
            label:SetWidth(width)
        else
            label:SetFullWidth(true)
        end
        widget:AddChild(label)
    end

    local function label(widget, text, width)
        local label = AceGUI:Create("Label")
        label:SetFontObject(GameFontHighlight)
        label:SetText(text)
        label:SetFontObject(GameFontHighlightLarge)
        if width then
            label:SetWidth(width)
        else
            label:SetFullWidth(true)
        end
        widget:AddChild(label)
    end

    labelLarge(frame, QuestieLib:GetColoredQuestName(id, true, true, true), 100)


end


function TEST_RENDER_QUESTGIVER(id)
    local mdl = CreateFrame("PlayerModel", "SilreuModel", UIParent)
    mdl:SetSize(100, 100)
    mdl:SetPoint("LEFT", 50)
    mdl:SetDisplayInfo(373)
    local r = 0
    C_Timer.NewTicker(0.01, function()
        r = (r + 0.02) % (3.14159*2)
        mdl:SetFacing(r)
        
    end)
    return mdl
end







--/run for k in pairs(_G) do if strfind(k, "Elv") and (not strfind(k, "ElvUI_")) and (not strfind(k, "ElvUF_")) and strfind(k, "Config") then print(k) end end
-- /run _SCAN_ELV(ElvUI)
local scanned = {}
function _SCAN_ELV(e, name)
    if not name then
        name = "ElvUI"
    end
    if type(e) == "table" and not scanned[e] then
        scanned[e] = true
        for k, v in pairs(e) do
            _SCAN_ELV(v, name .."."..tostring(k))
        end
    elseif type(e) == "number" then
        if e == 0.64 then
            print(name .. " = " .. tostring(e))
        end
    end
end
