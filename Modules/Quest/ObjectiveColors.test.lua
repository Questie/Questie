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

    -- Palette names in rotation order, read from the module: expectations about rotation follow the palette.
    local NAMES
    local zoneOrSort, parentZones, givers, repeatable

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
        saved[questId][objectiveIndex] = {color = name, zone = uiMapId, real = real}
    end

    -- A quest in the log, as QuestLogCache holds it.
    local function InLog(questId, finished, isComplete)
        local objectives = {}
        for index, isFinished in pairs(finished or {}) do
            objectives[index] = {finished = isFinished}
        end
        QuestLogCache.questLog_DO_NOT_MODIFY[questId] = {objectives = objectives, isComplete = isComplete or 0}
    end

    local function ColorOf(questId, perZone, objectiveIndex)
        return NameOf(ObjectiveColors.Get({Id = questId}, Objective(perZone), objectiveIndex or 1))
    end

    before_each(function()
        Questie.db.char.objectiveColors = {}
        Questie.db.char.complete = {}
        zoneOrSort, parentZones, givers, repeatable = {}, {}, {}, {}

        -- Mocks answer only what the real modules would: the asked key, the passed givers, nil for unknown areas.
        QuestieDB = QuestieLoader:ImportModule("QuestieDB")
        QuestieDB.QueryQuestSingle = function(questId, key)
            if key == "zoneOrSort" then
                return zoneOrSort[questId]
            end
        end
        QuestieDB.IsRepeatable = function(questId) return repeatable[questId] == "repeatable" end
        QuestieDB.IsDailyQuest = function(questId) return repeatable[questId] == "daily" end
        QuestieDB.IsWeeklyQuest = function(questId) return repeatable[questId] == "weekly" end
        QuestieDB.IsMonthlyQuest = function(questId) return repeatable[questId] == "monthly" end
        QuestieLoader:ImportModule("QuestieEvent").IsEventQuest = function(questId) return repeatable[questId] == "holiday" end
        ZoneDB = QuestieLoader:ImportModule("ZoneDB")
        ZoneDB.GetParentZoneId = function(_, areaId) return parentZones[areaId] end
        ZoneDB.GetUiMapIdByAreaId = function(_, areaId) return areaId < 900 and 1000 + areaId or nil end
        DistanceUtils = QuestieLoader:ImportModule("DistanceUtils")
        DistanceUtils.GetNearestFinisherOrStarter = function(starts) return nil, givers[starts] end
        QuestLogCache = QuestieLoader:ImportModule("QuestLogCache")
        QuestLogCache.questLog_DO_NOT_MODIFY = {}

        dofile("Modules/Quest/ObjectiveColors.lua")
        ObjectiveColors = QuestieLoader:ImportModule("ObjectiveColors")
        NAMES = select(2, ObjectiveColors.GetPalette())
    end)

    describe("GetPalette", function()
        it("names every color once, since saved colors and bans refer to them by name", function()
            local colors, names = ObjectiveColors.GetPalette()
            local seen = {}
            for index, name in ipairs(names) do
                assert.is_nil(seen[name], name)
                seen[name] = true
                for channel = 1, 3 do
                    assert.is_true(colors[index][channel] >= 0 and colors[index][channel] <= 1)
                end
            end
            assert.are.equal(#colors, #names)
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
            zoneOrSort[20] = 537 -- given in a capital, done outside it
            local starts = {NPC = {1}}
            givers[starts] = 1
            assert.are.equal(1001, ObjectiveColors.PrimaryZone(20, starts, Spawns({[1] = 10, [38] = 50})))
        end)

        it("maps a quest giver standing in a sub-zone to its parent zone", function()
            zoneOrSort[21] = -304
            local starts = {NPC = {1}}
            givers[starts] = 585 -- a sub-zone of 584
            parentZones[585] = 584
            assert.are.equal(1584, ObjectiveColors.PrimaryZone(21, starts, Spawns({[584] = 2, [38] = 50})))
        end)

        it("falls back to the zone with the most spawns for category quests", function()
            zoneOrSort[30] = -304 -- Cooking
            local starts = {NPC = {1}}
            givers[starts] = 99 -- no spawns there
            assert.are.equal(1040, ObjectiveColors.PrimaryZone(30, starts, Spawns({[12] = 5, [40] = 9})))
        end)

        it("uses the quest's zone without spawns, and no zone for a category quest without spawns", function()
            zoneOrSort[40], zoneOrSort[41] = 12, -304
            assert.are.equal(1012, ObjectiveColors.PrimaryZone(40, nil, {}))
            assert.is_nil(ObjectiveColors.PrimaryZone(41, nil, {}))
        end)

        it("counts spawns under an alternative dungeon AreaId as the dungeon's", function()
            zoneOrSort[50] = 581
            parentZones[781] = 581 -- the dungeon's alternative AreaId
            assert.are.equal(1581, ObjectiveColors.PrimaryZone(50, nil, Spawns({[781] = 3, [40] = 9})))
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
                assigned[questId] = ColorOf(questId, {[questId] = 1})
            end
            local expected = {unpack(NAMES)}
            expected[#NAMES + 1] = NAMES[1]
            assert.are.same(expected, assigned)
        end)

        it("never picks a color banned in the objective's primary zone, and rotates on after the pick", function()
            ObjectiveColors.AddBans({byUiMapId = {[1001] = {NAMES[1], NAMES[2]}}})
            zoneOrSort[317] = 1

            assert.are.equal(NAMES[3], ColorOf(317, {[1] = 4}))
            assert.are.same({color = NAMES[3], zone = 1001}, Questie.db.char.objectiveColors[317][1])
            zoneOrSort[318] = 2
            assert.are.equal(NAMES[4], ColorOf(318, {[2] = 1}))
        end)

        it("combines the bans of every source that names a zone, skipping names no longer in the palette", function()
            ObjectiveColors.AddBans({byUiMapId = {[1001] = {NAMES[1], "Medium Purple"}}})
            ObjectiveColors.AddBans({byUiMapId = {[1001] = {NAMES[2]}}})
            zoneOrSort[317] = 1
            assert.are.equal(NAMES[3], ColorOf(317, {[1] = 4}))
        end)

        it("still gives a color in a zone that bans every color", function()
            ObjectiveColors.AddBans({byUiMapId = {[1001] = {unpack(NAMES)}}})
            zoneOrSort[317] = 1
            assert.are.equal(NAMES[1], ColorOf(317, {[1] = 4}))
        end)

        it("places a capital-given quest by its quest giver", function()
            zoneOrSort[20] = 537
            local quest = {Id = 20, Starts = {NPC = {1}}}
            givers[quest.Starts] = 1
            ObjectiveColors.Get(quest, Objective({[1] = 10, [38] = 50}), 1)
            assert.are.equal(1001, Questie.db.char.objectiveColors[20][1].zone)
        end)

        it("still gives a color when a spawn zone has no map", function()
            zoneOrSort[317] = 1
            assert.are.equal(NAMES[1], ColorOf(317, {[1] = 4, [950] = 2}))
            assert.are.equal(1001, Questie.db.char.objectiveColors[317][1].zone)
        end)

        it("picks the color farthest from the other objectives in the same primary zone", function()
            -- Expected values from an independent Python implementation of the same OKLab and vision simulations.
            zoneOrSort[317] = 1
            InLog(100, {[1] = false})
            Saved(100, 1, "Lime", 1001)
            assert.are.equal("Navy Blue", ColorOf(317, {[1] = 4}))

            InLog(101, {[1] = false})
            Saved(101, 1, "Navy Blue", 1001)
            Questie.db.char.objectiveColors[317] = nil
            assert.are.equal("Vine Green", ColorOf(317, {[1] = 4}))
        end)

        it("keeps colors apart for colorblind players too", function()
            -- Under normal vision alone the farthest from Slimy Green is Pink Flamingo; for deuteranopes the pair
            -- Slimy Green and Scarlet is nearly the same color.
            zoneOrSort[317] = 1
            InLog(100, {[1] = false})
            Saved(100, 1, "Slimy Green", 1001)
            assert.are.equal("Navy Blue", ColorOf(317, {[1] = 4}))
        end)

        it("ignores colors of finished objectives, quests out of the log, and other primary zones", function()
            zoneOrSort[317] = 1
            InLog(100, {[1] = true})
            Saved(100, 1, NAMES[1], 1001) -- finished
            Saved(101, 1, NAMES[1], 1001) -- quest no longer in the log
            InLog(102, {[1] = false})
            Saved(102, 1, NAMES[1], 1012) -- worked on in Elwynn
            InLog(103, {}, 1)
            Saved(103, 65, NAMES[1], 1001) -- special objective of a completed quest

            -- With no neighbor left, the rotation starts at the first color.
            assert.are.equal(NAMES[1], ColorOf(317, {[1] = 4}))
        end)

        it("skips neighbor entries that are not color records", function()
            zoneOrSort[317] = 1
            InLog(600, {[1] = false, [2] = false})
            Questie.db.char.objectiveColors[600] = {[1] = 3, [2] = {color = "Medium Purple", zone = 1001}}
            assert.are.equal(NAMES[1], ColorOf(317, {[1] = 4}))
        end)

        it("counts special objectives of unfinished quests as neighbors", function()
            zoneOrSort[317] = 1
            InLog(103, {}, 0)
            Saved(103, 65, "Lime", 1001)
            assert.are.equal("Navy Blue", ColorOf(317, {[1] = 4}))
        end)

        it("counts a special objective tied to a real one until that one finishes", function()
            zoneOrSort[317] = 1
            InLog(103, {[1] = false}, 0)
            Saved(103, 65, "Lime", 1001, 1)
            assert.are.equal("Navy Blue", ColorOf(317, {[1] = 4}))

            -- Once it hides, nothing is in use, so the rotation continues past Navy Blue.
            QuestLogCache.questLog_DO_NOT_MODIFY[103].objectives[1].finished = true
            Questie.db.char.objectiveColors[317] = nil
            local navy
            for index, name in ipairs(NAMES) do
                navy = name == "Navy Blue" and index or navy
            end
            assert.are.equal(NAMES[navy % #NAMES + 1], ColorOf(317, {[1] = 4}))
        end)

        it("saves which real objective a special objective follows, only when that objective exists", function()
            zoneOrSort[317] = 1
            local quest = {Id = 317, Objectives = {[1] = {}, [2] = {}}}
            local tied, loose = Objective({[1] = 4}), Objective({[1] = 4})
            tied.RealObjectiveIndex, loose.RealObjectiveIndex = 2, 0
            ObjectiveColors.Get(quest, tied, 65)
            ObjectiveColors.Get(quest, loose, 66)
            assert.are.equal(2, Questie.db.char.objectiveColors[317][65].real)
            assert.is_nil(Questie.db.char.objectiveColors[317][66].real)
        end)

        it("keeps two new objectives of one quest apart before the quest log cache has the quest", function()
            zoneOrSort[317] = 1
            assert.are.equal("Blizzard Polygon-blue", ColorOf(317, {[1] = 4}, 1))
            -- The farthest color from the first, not merely the next in rotation.
            assert.are.equal("Yellow", ColorOf(317, {[1] = 2}, 2))
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
            assert.are.equal("Yellow", ColorOf(317, {[1] = 4}))
        end)

        it("prefers colors its secondary zones allow when the primary zone leaves a tie", function()
            local exceptAqua = {}
            for _, name in ipairs(NAMES) do
                if name ~= "Aqua" then
                    exceptAqua[#exceptAqua + 1] = name
                end
            end
            ObjectiveColors.AddBans({byUiMapId = {[1012] = exceptAqua}})
            zoneOrSort[317] = 1
            assert.are.equal("Aqua", ColorOf(317, {[1] = 4, [12] = 1}))
        end)

        it("prefers the color the fewest secondary zones ban", function()
            -- Every color is banned in both secondary zones except Aqua, banned in one.
            ObjectiveColors.AddBans({byUiMapId = {[1012] = {unpack(NAMES)}}})
            local exceptAqua = {}
            for _, name in ipairs(NAMES) do
                if name ~= "Aqua" then
                    exceptAqua[#exceptAqua + 1] = name
                end
            end
            ObjectiveColors.AddBans({byUiMapId = {[1013] = exceptAqua}})
            zoneOrSort[317] = 1
            assert.are.equal("Aqua", ColorOf(317, {[1] = 4, [12] = 1, [13] = 1}))
        end)

        it("returns a saved color without picking again, even one banned since", function()
            ObjectiveColors.AddBans({byUiMapId = {[1001] = {"Yellow"}}})
            zoneOrSort[317] = 1
            Saved(317, 1, "Yellow", 1001)
            assert.are.equal("Yellow", ColorOf(317, {[1] = 4}))
        end)

        it("replaces saved entries that are not color records", function()
            -- A bare palette index, a retired color's name, and an index where a name belongs.
            zoneOrSort[500] = 1
            Questie.db.char.objectiveColors[500] = {[1] = 3, [2] = {color = "Medium Purple"}, [3] = {color = 2}}
            local returned = {}
            for objectiveIndex = 1, 3 do
                returned[objectiveIndex] = NameOf(ObjectiveColors.Get({Id = 500}, Objective({[1] = 1}), objectiveIndex))
            end
            for objectiveIndex = 1, 3 do
                assert.are.same({color = returned[objectiveIndex], zone = 1001},
                    Questie.db.char.objectiveColors[500][objectiveIndex])
            end
            assert.is_not_nil(returned[1])
        end)

        it("initializes missing storage", function()
            Questie.db.char.objectiveColors = nil
            ObjectiveColors.Get({Id = 1}, Objective({}), 1)
            assert.are.same({[1] = {[1] = {color = NAMES[1]}}}, Questie.db.char.objectiveColors)
        end)

        it("drops saved colors of quests done for good on the first pick, keeping quests that can return", function()
            Questie.db.char.complete = {[10] = true, [11] = true, [12] = true, [13] = true, [14] = true, [15] = true,
                [17] = true}
            repeatable[11], repeatable[12], repeatable[13] = "repeatable", "daily", "weekly"
            repeatable[14], repeatable[15] = "monthly", "holiday"
            InLog(17, {[1] = false}) -- in the log, though marked complete
            for questId = 10, 17 do
                Saved(questId, 1, "Lime", 1001)
            end
            ObjectiveColors.Get({Id = 1}, Objective({}), 1)
            local saved = Questie.db.char.objectiveColors
            assert.is_nil(saved[10])
            for questId = 11, 17 do -- 16 is not completed, such as an abandoned quest
                assert.is_not_nil(saved[questId], questId)
            end
        end)
    end)

    describe("party objectives", function()
        local function Party(perZone)
            local objective = Objective(perZone)
            objective.IsPartyObjective = true
            return objective
        end

        it("keeps a party member's pick for the session without saving it", function()
            zoneOrSort[317] = 1
            local party = Party({[1] = 4})
            local first = ObjectiveColors.Get({Id = 317}, party, 1)
            assert.are.equal(first, ObjectiveColors.Get({Id = 317}, party, 1))
            assert.is_nil(Questie.db.char.objectiveColors[317])

            -- Accepting the quest picks the player's own color, knowing the player's neighbors.
            InLog(100, {[1] = false})
            Saved(100, 1, "Lime", 1001)
            assert.are.equal("Navy Blue", ColorOf(317, {[1] = 4}))
            assert.are.equal("Navy Blue", Questie.db.char.objectiveColors[317][1].color)
        end)

        it("uses the player's saved color for a quest the player had before", function()
            zoneOrSort[317] = 1
            Saved(317, 1, "Scarlet", 1001)
            assert.are.equal("Scarlet", NameOf(ObjectiveColors.Get({Id = 317}, Party({[1] = 4}), 1)))
        end)
    end)

    describe("shipped Forever ban data", function()
        local data

        before_each(function()
            ObjectiveColors.AddBans = function(added) data = added end
            dofile("Modules/Quest/ObjectiveColorBans/Forever.lua")
        end)

        it("was measured with today's palette colors and blob opacity", function()
            local colors, names = ObjectiveColors.GetPalette()
            for index, name in ipairs(names) do
                local rgb = colors[index]
                assert.are.same({math.floor(rgb[1] * 255 + 0.5), math.floor(rgb[2] * 255 + 0.5),
                    math.floor(rgb[3] * 255 + 0.5)}, data.measuredColors[name], name)
            end
            local source = io.open("Modules/Map/Polygon/PolygonMinimap.lua"):read("*a")
            local fill, border = source:match("local FILL_ALPHA, BORDER_ALPHA = ([%d.]+), ([%d.]+)")
            assert.are.same({tonumber(fill), tonumber(border)}, data.measuredOpacity)
            for _, banned in pairs(data.byUiMapId) do
                for _, name in ipairs(banned) do
                    assert.is_not_nil(data.measuredColors[name], name)
                end
            end
        end)

        it("is loaded by exactly the TOCs it names", function()
            local expected = {}
            for _, toc in ipairs(data.tocs) do
                expected[toc] = true
            end
            for _, toc in ipairs({"Questie_Vanilla.toc", "Questie_TBC.toc", "Questie_Wrath.toc", "Questie_Cata.toc",
                "Questie_Mists.toc", "Questie_Camelot.toc"}) do
                local lists = io.open(toc):read("*a"):find("Modules\\Quest\\ObjectiveColorBans\\Forever.lua", 1, true)
                assert.are.equal(expected[toc] == true, lists ~= nil, toc)
            end
        end)
    end)
end)
