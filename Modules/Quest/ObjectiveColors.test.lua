dofile("setupTests.lua")

describe("ObjectiveColors", function()
    ---@type ObjectiveColors
    local ObjectiveColors
    ---@type QuestieDB
    local QuestieDB
    ---@type ZoneDB
    local ZoneDB
    ---@type DistanceUtils
    local DistanceUtils
    ---@type QuestLogCache
    local QuestLogCache

    -- The legacy QuestieDev-Master sequence without the retired colors. Saved records index this order, so it
    -- must never change silently.
    local PALETTE = {
        {80, 113, 255, "Blizzard Polygon-blue"}, {149, 229, 14, "Inch Worm"}, {0, 166, 152, "Persian Green"},
        {0, 250, 140, "Spring Green"}, {181, 28, 122, "Medium Violet Red"}, {149, 55, 255, "Light Slate Blue"},
        {218, 55, 147, "Deep Cerise"}, {255, 64, 255, "Pink Flamingo"}, {254, 251, 0, "Yellow"},
        {255, 255, 255, "White"}, {41, 167, 0, "Slimy Green"}, {0, 169, 255, "Deep Sky Blue"},
        {0, 150, 0, "Vine Green"}, {1, 74, 255, "Navy Blue"}, {0, 249, 0, "Lime"}, {0, 252, 255, "Aqua"},
        {255, 38, 0, "Scarlet"},
    }
    local NAMES = {}
    for index, entry in ipairs(PALETTE) do
        NAMES[index] = entry[4]
    end

    local zoneOrSort, parentZones, giverZone

    local function Index(name)
        for index, entryName in ipairs(NAMES) do
            if entryName == name then
                return index
            end
        end
        error("no palette color " .. name)
    end

    local function NameOf(color)
        local colors, names = ObjectiveColors.GetPalette()
        for index, entry in ipairs(colors) do
            if entry == color then
                return names[index]
            end
        end
    end

    -- A spawn list with the given number of spawns per AreaId, shaped like objective.spawnList.
    local function Spawns(perZone)
        local spawns = {}
        for areaId, count in pairs(perZone) do
            spawns[areaId] = {}
            for i = 1, count do
                spawns[areaId][i] = {50, 50}
            end
        end
        return {[1] = {Spawns = spawns}}
    end

    local function Objective(perZone)
        return {spawnList = Spawns(perZone)}
    end

    -- An objective already colored for a zone, as a saved record.
    local function Saved(questId, objectiveIndex, name, uiMapId, real)
        local saved = Questie.db.char.objectiveColors
        saved[questId] = saved[questId] or {}
        saved[questId][objectiveIndex] = {color = Index(name), zone = uiMapId, real = real}
    end

    -- A quest in the log, as QuestLogCache holds it.
    local function InLog(questId, finished, isComplete)
        local objectives = {}
        for index, isFinished in pairs(finished or {}) do
            objectives[index] = {finished = isFinished}
        end
        QuestLogCache.questLog_DO_NOT_MODIFY[questId] = {objectives = objectives, isComplete = isComplete or 0}
    end

    before_each(function()
        Questie.db.char.objectiveColors = {}
        zoneOrSort, parentZones, giverZone = {}, {}, nil

        QuestieDB = QuestieLoader:ImportModule("QuestieDB")
        QuestieDB.QueryQuestSingle = function(questId) return zoneOrSort[questId] end
        ZoneDB = QuestieLoader:ImportModule("ZoneDB")
        ZoneDB.GetParentZoneId = function(_, areaId) return parentZones[areaId] end
        ZoneDB.GetUiMapIdByAreaId = function(_, areaId) return 1000 + areaId end
        DistanceUtils = QuestieLoader:ImportModule("DistanceUtils")
        DistanceUtils.GetNearestFinisherOrStarter = function() return nil, giverZone end
        QuestLogCache = QuestieLoader:ImportModule("QuestLogCache")
        QuestLogCache.questLog_DO_NOT_MODIFY = {}

        dofile("Modules/Quest/ObjectiveColors.lua")
        ObjectiveColors = QuestieLoader:ImportModule("ObjectiveColors")
    end)

    describe("GetPalette", function()
        it("keeps the pinned palette order and values", function()
            local colors, names = ObjectiveColors.GetPalette()
            assert.are.same(NAMES, names)
            for index, entry in ipairs(PALETTE) do
                local rgb = colors[index]
                assert.are.same({entry[1], entry[2], entry[3]},
                    {math.floor(rgb[1] * 255 + 0.5), math.floor(rgb[2] * 255 + 0.5), math.floor(rgb[3] * 255 + 0.5)})
            end
        end)
    end)

    describe("PrimaryZone", function()
        it("picks the quest's zone when the objective spawns there, whatever spawns elsewhere", function()
            -- Stocking Jetsteam: Chunk of Boar Meat drops in Durotar (14) more than in Dun Morogh (1).
            zoneOrSort[317] = 1
            local primary, secondary = ObjectiveColors.PrimaryZone(317, nil, Spawns({[14] = 315, [1] = 236, [12] = 153}))
            table.sort(secondary)
            assert.are.equal(1001, primary)
            assert.are.same({1012, 1014}, secondary)
        end)

        it("maps a sub-zone quest zone to its parent zone", function()
            zoneOrSort[10] = 131
            parentZones[131] = 1
            assert.are.equal(1001, ObjectiveColors.PrimaryZone(10, nil, Spawns({[1] = 5, [38] = 9})))
        end)

        it("falls back to the quest giver's zone when the quest's zone has no spawns", function()
            zoneOrSort[20] = 1537 -- given in Ironforge, done outside it
            giverZone = 1
            assert.are.equal(1001, ObjectiveColors.PrimaryZone(20, {NPC = {1}}, Spawns({[1] = 10, [38] = 50})))
        end)

        it("falls back to the zone with the most spawns for category quests", function()
            zoneOrSort[30] = -304 -- Cooking
            giverZone = 99 -- no spawns there
            assert.are.equal(1040, ObjectiveColors.PrimaryZone(30, {NPC = {1}}, Spawns({[12] = 5, [40] = 9})))
        end)

        it("uses the quest's zone without spawns, and no zone for a category quest without spawns", function()
            zoneOrSort[40], zoneOrSort[41] = 12, -304
            assert.are.equal(1012, ObjectiveColors.PrimaryZone(40, nil, {}))
            assert.is_nil(ObjectiveColors.PrimaryZone(41, nil, {}))
        end)

        it("counts spawns under an alternative dungeon AreaId as the dungeon's", function()
            zoneOrSort[50] = 1581
            parentZones[9581] = 1581 -- the dungeon's alternative AreaId
            assert.are.equal(2581, ObjectiveColors.PrimaryZone(50, nil, Spawns({[9581] = 3, [40] = 9})))
        end)

        it("breaks a tie for the most spawns toward the lowest AreaId", function()
            zoneOrSort[30] = -304
            assert.are.equal(1012, ObjectiveColors.PrimaryZone(30, nil, Spawns({[40] = 5, [12] = 5, [38] = 2})))
        end)

        it("lists each secondary zone once and never the primary zone", function()
            zoneOrSort[317] = 1
            -- AreaIds 1 and 2 share a map, as do 12 and 13.
            ZoneDB.GetUiMapIdByAreaId = function(_, areaId) return ({[1] = 1426, [2] = 1426, [12] = 1429, [13] = 1429})[areaId] end
            local primary, secondary = ObjectiveColors.PrimaryZone(317, nil, Spawns({[1] = 4, [2] = 1, [12] = 3, [13] = 3}))
            assert.are.equal(1426, primary)
            assert.are.same({1429}, secondary)
        end)
    end)

    describe("Get", function()
        it("assigns palette order to objectives in different zones, then wraps", function()
            local assigned = {}
            for questId = 1, #NAMES + 1 do
                zoneOrSort[questId] = questId
                assigned[questId] = NameOf(ObjectiveColors.Get({Id = questId}, Objective({[questId] = 1}), 1))
            end
            local expected = {unpack(NAMES)}
            expected[#NAMES + 1] = NAMES[1]
            assert.are.same(expected, assigned)
        end)

        it("never picks a color banned in the objective's primary zone", function()
            ObjectiveColors.AddBans("Test", {paletteNames = NAMES,
                byUiMapId = {[1001] = {Index("Blizzard Polygon-blue"), Index("Inch Worm")}}})
            zoneOrSort[317] = 1

            local color = ObjectiveColors.Get({Id = 317}, Objective({[1] = 4}), 1)

            assert.are.equal("Persian Green", NameOf(color))
            assert.are.same({color = Index("Persian Green"), zone = 1001}, Questie.db.char.objectiveColors[317][1])
            -- The rotation continues after the pick, not after the color it would have picked.
            zoneOrSort[318] = 2
            assert.are.equal("Spring Green", NameOf(ObjectiveColors.Get({Id = 318}, Objective({[2] = 1}), 1)))
        end)

        it("combines the bans of every source that names a zone", function()
            ObjectiveColors.AddBans("First", {paletteNames = NAMES, byUiMapId = {[1001] = {Index("Blizzard Polygon-blue")}}})
            ObjectiveColors.AddBans("Second", {paletteNames = NAMES, byUiMapId = {[1001] = {Index("Inch Worm")}}})
            zoneOrSort[317] = 1
            assert.are.equal("Persian Green", NameOf(ObjectiveColors.Get({Id = 317}, Objective({[1] = 4}), 1)))
        end)

        it("still gives a color in a zone that bans every color", function()
            local all = {}
            for index in ipairs(NAMES) do all[index] = index end
            ObjectiveColors.AddBans("Test", {paletteNames = NAMES, byUiMapId = {[1001] = all}})
            zoneOrSort[317] = 1
            assert.are.equal("Blizzard Polygon-blue", NameOf(ObjectiveColors.Get({Id = 317}, Objective({[1] = 4}), 1)))
        end)

        it("picks the color farthest from the other objectives in the same primary zone", function()
            -- Expected values from the contrast tool's OKLab, an implementation independent of this module.
            zoneOrSort[317] = 1
            InLog(100, {[1] = false})
            Saved(100, 1, "Lime", 1001)
            assert.are.equal("Light Slate Blue", NameOf(ObjectiveColors.Get({Id = 317}, Objective({[1] = 4}), 1)))

            InLog(101, {[1] = false})
            Saved(101, 1, "Navy Blue", 1001)
            Questie.db.char.objectiveColors[317] = nil
            assert.are.equal("Scarlet", NameOf(ObjectiveColors.Get({Id = 317}, Objective({[1] = 4}), 1)))
        end)

        it("ignores colors of finished objectives, quests out of the log, and other primary zones", function()
            zoneOrSort[317] = 1
            InLog(100, {[1] = true})
            Saved(100, 1, "Blizzard Polygon-blue", 1001) -- finished
            Saved(101, 1, "Blizzard Polygon-blue", 1001) -- quest no longer in the log
            InLog(102, {[1] = false})
            Saved(102, 1, "Blizzard Polygon-blue", 1012) -- worked on in Elwynn
            InLog(103, {}, 1)
            Saved(103, 65, "Blizzard Polygon-blue", 1001) -- special objective of a completed quest

            -- With no neighbor left, the rotation starts at the first color.
            assert.are.equal("Blizzard Polygon-blue", NameOf(ObjectiveColors.Get({Id = 317}, Objective({[1] = 4}), 1)))
        end)

        it("counts special objectives of unfinished quests as neighbors", function()
            zoneOrSort[317] = 1
            InLog(103, {}, 0)
            Saved(103, 65, "Lime", 1001)
            assert.are.equal("Light Slate Blue", NameOf(ObjectiveColors.Get({Id = 317}, Objective({[1] = 4}), 1)))
        end)

        it("drops a special objective tied to a real one once that one finishes", function()
            zoneOrSort[317] = 1
            InLog(103, {[1] = true}, 0)
            Saved(103, 65, "Blizzard Polygon-blue", 1001, 1)
            assert.are.equal("Blizzard Polygon-blue", NameOf(ObjectiveColors.Get({Id = 317}, Objective({[1] = 4}), 1)))
        end)

        it("saves which real objective a special objective follows", function()
            zoneOrSort[317] = 1
            local special = Objective({[1] = 4})
            special.RealObjectiveIndex = 2
            ObjectiveColors.Get({Id = 317}, special, 65)
            assert.are.equal(2, Questie.db.char.objectiveColors[317][65].real)
        end)

        it("keeps a party member's pick for the session without saving it", function()
            zoneOrSort[317] = 1
            local party = Objective({[1] = 4})
            party.IsPartyObjective = true
            local first = ObjectiveColors.Get({Id = 317}, party, 1)
            assert.are.equal(first, ObjectiveColors.Get({Id = 317}, party, 1))
            assert.is_nil(Questie.db.char.objectiveColors[317])

            -- Accepting the quest picks the player's own color, now knowing the player's neighbors.
            InLog(100, {[1] = false})
            Saved(100, 1, "Lime", 1001)
            assert.are.equal("Light Slate Blue", NameOf(ObjectiveColors.Get({Id = 317}, Objective({[1] = 4}), 1)))
            assert.are.equal(Index("Light Slate Blue"), Questie.db.char.objectiveColors[317][1].color)
        end)

        it("keeps two new objectives of one quest apart before the quest log cache has the quest", function()
            zoneOrSort[317] = 1
            assert.are.equal("Blizzard Polygon-blue", NameOf(ObjectiveColors.Get({Id = 317}, Objective({[1] = 4}), 1)))
            -- The farthest color from the first, not merely the next in rotation (Inch Worm).
            assert.are.equal("Yellow", NameOf(ObjectiveColors.Get({Id = 317}, Objective({[1] = 2}), 2)))
        end)

        it("repeats colors as rarely as possible in a zone using every allowed color", function()
            zoneOrSort[317] = 1
            for index, name in ipairs(NAMES) do
                InLog(200 + index, {[1] = false, [2] = false})
                Saved(200 + index, 1, name, 1001)
                if name ~= "Yellow" then
                    Saved(200 + index, 2, name, 1001) -- every color twice, Yellow once
                end
            end
            assert.are.equal("Yellow", NameOf(ObjectiveColors.Get({Id = 317}, Objective({[1] = 4}), 1)))
        end)

        it("prefers colors its secondary zones allow when the primary zone leaves a tie", function()
            local bannedInElwynn = {}
            for index, name in ipairs(NAMES) do
                if name ~= "Aqua" then
                    bannedInElwynn[#bannedInElwynn + 1] = index
                end
            end
            ObjectiveColors.AddBans("Test", {paletteNames = NAMES, byUiMapId = {[1012] = bannedInElwynn}})
            zoneOrSort[317] = 1
            assert.are.equal("Aqua", NameOf(ObjectiveColors.Get({Id = 317}, Objective({[1] = 4, [12] = 1}), 1)))
        end)

        it("returns a saved color without picking again, also after a reload", function()
            ObjectiveColors.AddBans("Test", {paletteNames = NAMES, byUiMapId = {[1001] = {Index("Yellow")}}})
            zoneOrSort[317] = 1
            Saved(317, 1, "Yellow", 1001) -- banned since it was saved: saved colors still never change

            assert.are.equal("Yellow", NameOf(ObjectiveColors.Get({Id = 317}, Objective({[1] = 4}), 1)))
            dofile("Modules/Quest/ObjectiveColors.lua") -- a reload: fresh module state, same saved variables
            ObjectiveColors.AddBans("Test", {paletteNames = NAMES, byUiMapId = {[1001] = {Index("Yellow")}}})
            assert.are.equal("Yellow", NameOf(ObjectiveColors.Get({Id = 317}, Objective({[1] = 4}), 1)))
        end)

        it("replaces saved entries that are not color records", function()
            zoneOrSort[500] = 1
            Questie.db.char.objectiveColors[500] = {[1] = 3, [2] = {color = #NAMES + 1}, [3] = {color = "2"}}
            for objectiveIndex = 1, 3 do
                ObjectiveColors.Get({Id = 500}, Objective({[1] = 1}), objectiveIndex)
                local record = Questie.db.char.objectiveColors[500][objectiveIndex]
                assert.is_true(type(record.color) == "number" and record.color >= 1 and record.color <= #NAMES)
                assert.are.equal(1001, record.zone)
            end
        end)

        it("initializes missing storage", function()
            Questie.db.char.objectiveColors = nil
            ObjectiveColors.Get({Id = 1}, Objective({}), 1)
            assert.are.same({[1] = {[1] = {color = 1}}}, Questie.db.char.objectiveColors)
        end)
    end)

    describe("AddBans", function()
        it("ignores ban data measured against another palette, warning on the first pick", function()
            local stale = {unpack(NAMES)}
            stale[1], stale[2] = stale[2], stale[1]
            -- Data files load before Questie.lua defines Questie.Warning.
            local warn = Questie.Warning
            Questie.Warning = nil
            local added = ObjectiveColors.AddBans("Stale", {paletteNames = stale, byUiMapId = {[1001] = {1}}})
            Questie.Warning = warn
            assert.is_false(added)

            local warning = spy.on(Questie, "Warning")
            zoneOrSort[317] = 1
            assert.are.equal("Blizzard Polygon-blue", NameOf(ObjectiveColors.Get({Id = 317}, Objective({[1] = 4}), 1)))
            ObjectiveColors.Get({Id = 318}, Objective({[1] = 4}), 1)
            assert.spy(warning).was.called(1)
            warning:revert()
        end)

        it("ships Forever ban data that matches the palette", function()
            local added
            ObjectiveColors.AddBans = function(source, data) added = {source = source, data = data} end
            dofile("Modules/Quest/ObjectiveColorBans/Forever.lua")

            assert.are.equal("Forever", added.source)
            assert.are.same(NAMES, added.data.paletteNames)
            for _, indexes in pairs(added.data.byUiMapId) do
                assert.is_true(#indexes > 0)
                for _, index in ipairs(indexes) do
                    assert.is_true(NAMES[index] ~= nil)
                end
            end
        end)
    end)
end)
