dofile("setupTests.lua")

describe("QuestieSearch", function()
    ---@type QuestieSearch
    local QuestieSearch

    before_each(function()
        dofile("Modules/Libs/QuestieLoader.lua")
        local QuestieDB = QuestieLoader:ImportModule("QuestieDB")

        local function AddDatabase(queryName, pointersName, names, idsWithoutName)
            QuestieDB[pointersName] = {}
            for id in pairs(names) do QuestieDB[pointersName][id] = true end
            for _, id in ipairs(idsWithoutName or {}) do QuestieDB[pointersName][id] = true end
            QuestieDB[queryName] = function(id, field)
                assert.are.equal("name", field)
                return names[id]
            end
        end
        AddDatabase("QueryQuestSingle", "QuestPointers", {
            [33] = "Wolves Across the Border",
            [7] = "The wolf",
            [330] = "Wolf",
            [1033] = "Elune's Tear",
            [12] = "100% Kobold (Elite)",
        }, {99})
        AddDatabase("QueryNPCSingle", "NPCPointers", {[299] = "Young Wolf"})
        AddDatabase("QueryObjectSingle", "ObjectPointers", {[55] = "Half-eaten body"})
        AddDatabase("QueryItemSingle", "ItemPointers", {[2070] = "Wolf Meat"})

        QuestieLoader:ImportModule("JourneyThread").YieldIfNeeded = function() end

        dofile("Modules/Journey/QuestieSearch.lua")
        QuestieSearch = QuestieLoader:ImportModule("QuestieSearch")
    end)

    it("should find everything that contains the text, sorted by ID", function()
        assert.are_same({7, 330}, QuestieSearch.Search("quest", "wolf"))
        assert.are_same({7, 33, 330}, QuestieSearch.Search("quest", "wol"))
    end)

    it("should sort by ID, whatever the order of the database is", function()
        local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
        local ids = {9001, 17, 333, 4200, 76, 1000000, 52013, 8}
        QuestieDB.NPCPointers = {}
        for _, id in ipairs(ids) do QuestieDB.NPCPointers[id] = true end
        QuestieDB.QueryNPCSingle = function() return "Wolf" end
        local databaseOrder = {}
        for id in pairs(QuestieDB.NPCPointers) do table.insert(databaseOrder, id) end
        table.sort(ids)
        assert.are_not.same(ids, databaseOrder)

        assert.are_same(ids, QuestieSearch.Search("npc", "wolf"))
    end)

    it("should not find what has no name, also not by its ID", function()
        assert.are_same({}, QuestieSearch.Search("quest", "99"))
        assert.are_same({}, QuestieSearch.Search("quest", '"99"'))
    end)

    it("should not care about upper case", function()
        assert.are_same({7, 330}, QuestieSearch.Search("quest", "WOLF"))
    end)

    it("should not treat the text as a pattern", function()
        assert.are_same({12}, QuestieSearch.Search("quest", "100% kobold ("))
        assert.are_same({}, QuestieSearch.Search("quest", "w.lf"))
    end)

    it("should find nothing when there is no match", function()
        assert.are_same({}, QuestieSearch.Search("quest", "murloc"))
    end)

    for quote, name in pairs({['"'] = "double", ["'"] = "single"}) do
        it("should only find exact matches in " .. name .. " quotes", function()
            assert.are_same({330}, QuestieSearch.Search("quest", quote .. "Wolf" .. quote))
        end)
    end

    it("should not treat a lone quote or an apostrophe as quotes", function()
        assert.are_same({1033}, QuestieSearch.Search("quest", "'"))
        assert.are_same({1033}, QuestieSearch.Search("quest", "elune's"))
    end)

    it("should search for a number in the IDs", function()
        assert.are_same({33, 330, 1033}, QuestieSearch.Search("quest", "33"))
    end)

    it("should search each database", function()
        assert.are_same({299}, QuestieSearch.Search("npc", "wolf"))
        assert.are_same({55}, QuestieSearch.Search("object", "body"))
        assert.are_same({2070}, QuestieSearch.Search("item", "wolf"))
    end)

    it("should refuse an unknown database", function()
        assert.has_error(function() QuestieSearch.Search("spell", "wolf") end, "Unknown kind: spell")
    end)

    it("should spread the search over several frames, instead of freezing the game", function()
        local ui = dofile("cli/testData/options/FakeUI.lua").Install()
        dofile("Modules/Libs/ThreadLib.lua")
        dofile("Modules/Journey/JourneyThread.lua")
        dofile("Modules/Journey/QuestieSearch.lua")
        ui.clockStep = 0.003 -- Every entry takes at least this long
        local ids
        QuestieLoader:ImportModule("JourneyThread").Start("QuestieSearchTest", function()
            ids = QuestieLoader:ImportModule("QuestieSearch").Search("quest", "wolf")
        end)

        ui.RunFrame()
        local isDoneInOneFrame = ids ~= nil
        ui.RunUntilIdle()
        ui.Restore()

        assert.is_false(isDoneInOneFrame)
        assert.are_same({7, 330}, ids)
    end)

    it("should know the names", function()
        assert.are.equal("Young Wolf", QuestieSearch.GetName("npc", 299))
        assert.are.equal("Wolf Meat", QuestieSearch.GetName("item", 2070))
        assert.is_nil(QuestieSearch.GetName("quest", 99))
    end)
end)
