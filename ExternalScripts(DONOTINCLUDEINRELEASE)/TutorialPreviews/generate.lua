-- Writes the objective style popup's preview data, one file per art set in Modules/Tutorial/Previews, and the
-- map crops images.py turns into their backgrounds. See README.md.
--
-- Run from the Questie repository root, with QuestieDB's data folder and the ColorContrast tool's era and mists
-- asset folders:
--   lua "ExternalScripts(DONOTINCLUDEINRELEASE)/TutorialPreviews/generate.lua" <QuestieDB>/data <era assets> <mists assets>

local DB_DIR, ERA_ASSETS, MISTS_ASSETS = arg[1], arg[2], arg[3]
assert(DB_DIR and ERA_ASSETS and MISTS_ASSETS, "usage: generate.lua <QuestieDB data> <era assets> <mists assets>")

local CROPS_PATH = "ExternalScripts(DONOTINCLUDEINRELEASE)/TutorialPreviews/crops.tsv"
local PREVIEW_DIR = "Modules/Tutorial/Previews"
local ART_WIDTH, ART_HEIGHT = 1002, 668 -- Every zone's map art, in pixels.
local BLUE, SCARLET, YELLOW = {80, 113, 255}, {255, 38, 0}, {254, 251, 0} -- ObjectiveColors' palette.
local OBJECTIVE_FILTER_DISTANCE = 2 -- QuestieOptionsDefaults' objectiveFilterDistance, which the Questie preset restores.

-- Each art set lists where each race starts and, for each start area, two of its first quests' objectives on
-- the zone map the player sees there. Races without an area of their own preview their faction's, Northshire
-- or the Valley of Trials (ObjectivePreview), so every art set needs both. An objective counts an NPC (`npc`,
-- with its quest's kill credit NPCs) or an item (`item`, dropped by NPCs); `needed` is from the quest text.
-- Colors avoid the bans of the zone, or of the parent zone, in Modules/Quest/ObjectiveColorBans.
local ART_SETS = {
    {
        name = "Classic", db = "Classic", prefix = "classic", assets = ERA_ASSETS,
        races = {Human = "Northshire", Dwarf = "ColdridgeValley", Gnome = "ColdridgeValley", NightElf = "Shadowglen",
            Orc = "ValleyOfTrials", Troll = "ValleyOfTrials", Scourge = "Deathknell", Tauren = "CampNarache"},
        areas = {
            {name = "Northshire", zone = 12, uiMapId = 1429, colors = {BLUE, SCARLET}, objectives = {
                {quest = 7, npc = 6, needed = 10}, {quest = 33, item = 750, needed = 8}}},
            {name = "ColdridgeValley", zone = 1, uiMapId = 1426, colors = {BLUE, SCARLET}, objectives = {
                {quest = 183, npc = 708, needed = 12}, {quest = 179, item = 750, needed = 8}}},
            {name = "Shadowglen", zone = 141, uiMapId = 1438, colors = {BLUE, SCARLET}, objectives = {
                {quest = 456, npc = 2031, needed = 7}, {quest = 459, item = 3297, needed = 8}}},
            {name = "ValleyOfTrials", zone = 14, uiMapId = 1411, colors = {BLUE, YELLOW}, objectives = {
                {quest = 788, npc = 3098, needed = 10}, {quest = 789, item = 4862, needed = 10}}},
            {name = "Deathknell", zone = 85, uiMapId = 1420, colors = {BLUE, SCARLET}, objectives = {
                {quest = 364, npc = 1501, needed = 8}, {quest = 376, item = 3265, needed = 6}}},
            {name = "CampNarache", zone = 215, uiMapId = 1412, colors = {BLUE, SCARLET}, objectives = {
                {quest = 747, item = 4739, needed = 7}, {quest = 780, item = 4848, needed = 8}}},
        },
    },
    {
        -- Cataclysm gave every start area a map of its own, and moved trolls and gnomes.
        name = "Cata", db = "MoP", prefix = "mop", assets = MISTS_ASSETS,
        races = {Human = "Northshire", Dwarf = "ColdridgeValley", Gnome = "NewTinkertown", NightElf = "Shadowglen",
            Orc = "ValleyOfTrials", Troll = "EchoIsles", Scourge = "Deathknell", Tauren = "CampNarache"},
        areas = {
            {name = "Northshire", zone = 6170, uiMapId = 425, colors = {BLUE, SCARLET}, objectives = {
                {quest = 28763, npc = 49871, needed = 6}, {quest = 26389, item = 58361, needed = 8}}},
            {name = "ColdridgeValley", zone = 6176, uiMapId = 427, colors = {BLUE, SCARLET}, objectives = {
                {quest = 24469, npc = 37070, needed = 6}, {quest = 24475, item = 49748, needed = 4}}},
            {name = "NewTinkertown", zone = 6457, uiMapId = 469, colors = {BLUE, SCARLET}, objectives = {
                {quest = 26265, npc = 42185, needed = 6}, {quest = 26264, item = 57987, needed = 6}}},
            {name = "Shadowglen", zone = 6450, uiMapId = 460, colors = {BLUE, SCARLET}, objectives = {
                {quest = 28713, npc = 2031, needed = 6}, {quest = 28714, item = 3297, needed = 6}}},
            {name = "ValleyOfTrials", zone = 6451, uiMapId = 461, colors = {BLUE, YELLOW}, objectives = {
                {quest = 25126, npc = 3098, needed = 6}, {quest = 25127, item = 4862, needed = 8}}},
            {name = "EchoIsles", zone = 6453, uiMapId = 463, colors = {BLUE, YELLOW}, objectives = {
                {quest = 24624, npc = 37961, needed = 8}, {quest = 24641, item = 50222, needed = 6}}},
            {name = "Deathknell", zone = 6454, uiMapId = 465, colors = {BLUE, SCARLET}, objectives = {
                {quest = 26799, npc = 1501, needed = 6}, {quest = 26802, item = 3265, needed = 4}}},
            {name = "CampNarache", zone = 6452, uiMapId = 462, colors = {BLUE, SCARLET}, objectives = {
                {quest = 14455, npc = 36697, needed = 7}, {quest = 14456, item = 49535, needed = 7}}},
        },
    },
}

-- Loading QuestieDB's data and Questie's geometry outside the game
local modules = {}
QuestieLoader = {}
function QuestieLoader.CreateModule(_, name)
    modules[name] = modules[name] or {private = {}}
    return modules[name]
end
QuestieLoader.ImportModule = QuestieLoader.CreateModule

-- PolygonGeometry yields once a frame has spent its budget; each resume is a new frame.
local frame = 0
GetTime = function() return frame end
dofile("Modules/Map/MapGeometry.lua")
dofile("Modules/Map/Polygon/PolygonGeometry.lua")
local PolygonGeometry = modules.PolygonGeometry

local function _Build(points)
    local thread = coroutine.create(function() return PolygonGeometry.Build(points, {}) end)
    local ok, result
    repeat
        frame = frame + 1
        ok, result = coroutine.resume(thread)
        assert(ok, result)
    until coroutine.status(thread) == "dead"
    return result
end

local function _LoadDatabase(set)
    local tables = {}
    for _, kind in ipairs({"Quest", "Npc", "Item"}) do
        dofile(DB_DIR .. "/" .. set.db .. "/" .. set.prefix .. kind .. "DB.lua")
        tables[kind] = assert(loadstring(modules.QuestieDB[kind:lower() .. "Data"]))()
    end
    return tables
end

---A map's world extent in yards, as C_Map.GetWorldPosFromMapPos computes it: the UiMapAssignment row covering
---the whole map. Map x runs along world Y, map y along world X.
local function _WorldSize(assets, uiMapId)
    local file = assert(io.open(assets .. "/db2/UiMapAssignment.csv"))
    local columns = {}
    local index = 0
    for name in file:read("*l"):gmatch("[^,]+") do
        index = index + 1
        columns[name] = index
    end
    for line in file:lines() do
        local row = {}
        for value in (line .. ","):gmatch("([^,]*),") do row[#row + 1] = value end
        if tonumber(row[columns.UiMapID]) == uiMapId and tonumber(row[columns.UiMin_0]) == 0 and tonumber(row[columns.UiMin_1]) == 0
            and tonumber(row[columns.UiMax_0]) == 1 and tonumber(row[columns.UiMax_1]) == 1 then
            file:close()
            return tonumber(row[columns.Region_4]) - tonumber(row[columns.Region_1]),
                tonumber(row[columns.Region_3]) - tonumber(row[columns.Region_0])
        end
    end
    error("no world extent for UiMap " .. uiMapId)
end

-- Collecting an objective
local function _SpawnsOf(npc, zone)
    local spawns = {}
    for _, point in ipairs(npc and npc[7] and npc[7][zone] or {}) do
        if point[1] >= 0 and point[2] >= 0 then spawns[#spawns + 1] = point end
    end
    return spawns
end

---The NPCs that count for the quest's objective on `npcId`: those of its kill credit, as Questie draws them,
---or the NPC alone.
local function _CountedNpcs(quest, npcId)
    for _, credit in ipairs(quest[10] and quest[10][5] or {}) do
        if credit[2] == npcId then return credit[1] end
    end
    return {npcId}
end

---Where the player stands taking the quest: its first quest giver's first spawn in the zone, if it has one there.
local function _GiverSpot(db, quest, zone)
    for _, npcId in ipairs(quest[2] and quest[2][1] or {}) do
        local spawn = _SpawnsOf(db.Npc[npcId], zone)[1]
        if spawn then return spawn end
    end
end

-- QuestieLib.GetSpawnDistance: zone percent, with x counted 1.5 times for the maps' aspect.
local function _SpawnDistance(a, b)
    local dx, dy = (a[1] - b[1]) * 1.5, a[2] - b[2]
    return math.sqrt(dx * dx + dy * dy)
end

---The spawns Questie's icon mode draws, as QuestieQuest places them on a zone map: nearest the player first,
---skipping any closer than the filter distance to one already placed.
local function _IconSpawns(spawns, giverSpot)
    local ordered = {}
    for index, spawn in ipairs(spawns) do
        ordered[index] = {spawn = spawn, index = index, distance = giverSpot and _SpawnDistance(spawn, giverSpot) or 0}
    end
    table.sort(ordered, function(a, b)
        if a.distance ~= b.distance then return a.distance < b.distance end
        return a.index < b.index
    end)
    local placed = {}
    for _, entry in ipairs(ordered) do
        local apart = true
        for _, other in ipairs(placed) do
            if _SpawnDistance(entry.spawn, other) < OBJECTIVE_FILTER_DISTANCE then apart = false; break end
        end
        if apart then placed[#placed + 1] = entry.spawn end
    end
    return placed
end

local function _Objective(db, area, spec, colorIndex)
    local quest = assert(db.Quest[spec.quest], "missing quest " .. spec.quest)
    -- A quest nobody starts was removed from the game, such as Cataclysm's rewritten start areas' old quests.
    assert(quest[2], "quest " .. spec.quest .. " has no quest giver")
    local objective = {questId = spec.quest, quest = quest[1], level = quest[5], needed = spec.needed,
        color = area.colors[colorIndex], spawns = {}}
    local npcIds
    if spec.item then
        local item = assert(db.Item[spec.item], "missing item " .. spec.item)
        objective.icon, objective.item, objective.target, npcIds = "loot", spec.item, item[1], item[2] or {}
    else
        objective.icon, objective.npc, objective.target = "slay", spec.npc, assert(db.Npc[spec.npc], "missing NPC " .. spec.npc)[1]
        npcIds = _CountedNpcs(quest, spec.npc)
    end
    for _, npcId in ipairs(npcIds) do
        for _, point in ipairs(_SpawnsOf(db.Npc[npcId], area.zone)) do objective.spawns[#objective.spawns + 1] = point end
    end
    assert(#objective.spawns > 0, "no spawns for quest " .. spec.quest .. " in zone " .. area.zone)
    local giverSpot = _GiverSpot(db, quest, area.zone)
    if not giverSpot then print("quest " .. spec.quest .. " has no quest giver in zone " .. area.zone .. ": icons in data order") end
    objective.icons = _IconSpawns(objective.spawns, giverSpot)
    return objective
end

-- The crop: a square of art pixels around each objective's widest cluster, kept on the map
local function _Spread(cluster)
    local bounds = cluster.worldBounds
    return (bounds.maxX - bounds.minX) * (bounds.maxY - bounds.minY)
end

local function _Crop(objectives)
    local minX, minY, maxX, maxY = math.huge, math.huge, -math.huge, -math.huge
    for _, objective in ipairs(objectives) do
        local largest
        for _, cluster in ipairs(objective.clusters) do
            if not largest or _Spread(cluster) > _Spread(largest) then largest = cluster end
        end
        for _, point in ipairs(largest.outline or {{x = largest.x, y = largest.y}}) do
            minX, maxX = math.min(minX, point.x * ART_WIDTH / 100), math.max(maxX, point.x * ART_WIDTH / 100)
            minY, maxY = math.min(minY, point.y * ART_HEIGHT / 100), math.max(maxY, point.y * ART_HEIGHT / 100)
        end
    end
    local size = math.min(ART_HEIGHT, math.max(170, math.max(maxX - minX, maxY - minY) * 1.3))
    local left = math.max(0, math.min(ART_WIDTH - size, (minX + maxX - size) / 2))
    local top = math.max(0, math.min(ART_HEIGHT - size, (minY + maxY - size) / 2))
    return math.floor(left + 0.5), math.floor(top + 0.5), math.floor(size + 0.5)
end

-- Writing
local crops = {}
local function _Point(x, y) return string.format("{x = %.2f, y = %.2f}", x, y) end

---Writes one area's objectives: icons and clusters in percent of its image, leaving out what lies well outside.
local function _EmitArea(emit, set, area, objectives)
    local left, top, size = _Crop(objectives)
    local function _Local(x, y) return (x * ART_WIDTH / 100 - left) / size * 100, (y * ART_HEIGHT / 100 - top) / size * 100 end
    local function _Inside(x, y) return x >= -5 and x <= 105 and y >= -5 and y <= 105 end
    local image = area.name .. "-" .. set.name .. ".blp"
    crops[#crops + 1] = table.concat({set.name, area.uiMapId, left, top, size, PREVIEW_DIR .. "/" .. image}, "\t")

    emit("        " .. area.name .. " = function() return {")
    emit('            image = "Interface\\\\Addons\\\\Questie\\\\Modules\\\\Tutorial\\\\Previews\\\\' .. image .. '",')
    emit("            objectives = {")
    for _, objective in ipairs(objectives) do
        local color = objective.color
        emit(string.format('                {questId = %d, quest = %q, level = %d, %s = %d, target = %q, needed = %d, icon = "%s",',
            objective.questId, objective.quest, objective.level, objective.item and "item" or "npc",
            objective.item or objective.npc, objective.target, objective.needed, objective.icon))
        emit(string.format("                    color = {%d / 255, %d / 255, %d / 255},", color[1], color[2], color[3]))
        local icons = {}
        for _, spawn in ipairs(objective.icons) do
            local x, y = _Local(spawn[1], spawn[2])
            if _Inside(x, y) then icons[#icons + 1] = _Point(x, y) end
        end
        emit("                    icons = {" .. table.concat(icons, ", ") .. "},")
        emit("                    clusters = {")
        for _, cluster in ipairs(objective.clusters) do
            local x, y = _Local(cluster.x, cluster.y)
            if _Inside(x, y) then
                local outline = {}
                for _, point in ipairs(cluster.outline or {}) do outline[#outline + 1] = _Point(_Local(point.x, point.y)) end
                if #outline > 0 then
                    emit(string.format("                        {x = %.2f, y = %.2f, outline = {%s}},", x, y,
                        table.concat(outline, ", ")))
                else
                    emit(string.format("                        {x = %.2f, y = %.2f},", x, y))
                end
            end
        end
        emit("                    },")
        emit("                },")
    end
    emit("            },")
    emit("        } end,")
end

for _, set in ipairs(ART_SETS) do
    local db = _LoadDatabase(set)
    local out = {}
    local function _Emit(text) out[#out + 1] = text end
    _Emit("-- Generated by ExternalScripts(DONOTINCLUDEINRELEASE)/TutorialPreviews/generate.lua from QuestieDB and")
    _Emit("-- PolygonGeometry. Do not edit; change the generator and run it again (README.md there).")
    _Emit("-- The " .. set.name .. " art set's start areas, for the TOCs of its clients only.")
    _Emit("")
    _Emit("---@type ObjectivePreview")
    _Emit('local ObjectivePreview = QuestieLoader:ImportModule("ObjectivePreview")')
    _Emit("")
    _Emit("ObjectivePreview.startAreas = {")
    local races = {}
    for race, area in pairs(set.races) do races[#races + 1] = string.format("%s = %q", race, area) end
    table.sort(races)
    _Emit("    races = {")
    for _, race in ipairs(races) do _Emit("        " .. race .. ",") end
    _Emit("    },")
    _Emit("    areas = {")
    for _, area in ipairs(set.areas) do
        local yardsWide, yardsTall = _WorldSize(set.assets, area.uiMapId)
        local objectives = {}
        for index, spec in ipairs(area.objectives) do
            local objective = _Objective(db, area, spec, index)
            local points = {}
            for _, spawn in ipairs(objective.spawns) do
                points[#points + 1] = {x = spawn[1], y = spawn[2], worldX = spawn[1] / 100 * yardsWide,
                    worldY = spawn[2] / 100 * yardsTall, uiMapId = area.uiMapId, instanceId = 0}
            end
            objective.clusters = _Build(points)
            objectives[index] = objective
        end
        _EmitArea(_Emit, set, area, objectives)
    end
    _Emit("    },")
    _Emit("}")

    local path = PREVIEW_DIR .. "/" .. set.name .. ".lua"
    local file = assert(io.open(path, "w"))
    file:write(table.concat(out, "\n"), "\n")
    file:close()
    print("wrote " .. path)
end

local file = assert(io.open(CROPS_PATH, "w"))
file:write("# art set\tUiMapId\tleft\ttop\tsize\timage\n", table.concat(crops, "\n"), "\n")
file:close()
print("wrote " .. CROPS_PATH)
