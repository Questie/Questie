dofile("setupTests.lua")

describe("QuestChain", function()
    local QuestChain, QuestieDB, records, hidden

    before_each(function()
        records, hidden = {}, {}
        QuestieDB = QuestieLoader:ImportModule("QuestieDB")
        QuestieDB.QuestPointers = {}
        QuestieDB.QueryQuestSingle = function(id, field)
            if field == "name" then return records[id] and "Quest " .. id end
            return records[id] and records[id][field]
        end
        QuestieLoader:ImportModule("QuestieCorrections").hiddenQuests = hidden
        dofile("Modules/Journey/QuestChain.lua")
        QuestChain = QuestieLoader:ImportModule("QuestChain")
    end)

    local function SetRecords(data)
        records = data
        QuestieDB.QuestPointers = {}
        for id in pairs(data) do QuestieDB.QuestPointers[id] = true end
    end

    it("finds the same full chain from its start, middle, and end with one-sided links", function()
        SetRecords({[30] = {nextQuestInChain = 20}, [20] = {}, [10] = {preQuestSingle = {20}}})
        for _, id in ipairs({10, 20, 30}) do
            assert.same({30, 20, 10}, QuestChain.GetQuestIds(id))
        end
    end)

    it("orders branching prerequisites before their shared follow-up without duplicates", function()
        SetRecords({[1] = {}, [2] = {preQuestSingle = {1}}, [3] = {preQuestSingle = {1}},
            [4] = {preQuestGroup = {-2, 3}, nextQuestInChain = 5}, [5] = {preQuestSingle = {4}}})
        assert.same({1, 2, 3, 4, 5}, QuestChain.GetQuestIds(3))
    end)

    it("traverses hidden steps and breadcrumb links even when the next link is missing", function()
        SetRecords({[1] = {breadcrumbForQuestId = 2}, [2] = {nextQuestInChain = 3}, [3] = {}})
        hidden[2] = true
        assert.same({1, 3}, QuestChain.GetQuestIds(3))
    end)

    it("ignores missing IDs, zero links, and self-links", function()
        SetRecords({[1] = {preQuestGroup = {99}, nextQuestInChain = 1, breadcrumbForQuestId = 0}})
        assert.same({1}, QuestChain.GetQuestIds(1))
    end)

    it("terminates cycles and includes each quest once", function()
        SetRecords({[1] = {nextQuestInChain = 2}, [2] = {nextQuestInChain = 1}, [3] = {preQuestSingle = {2}}})
        assert.same({1, 2, 3}, QuestChain.GetQuestIds(2))
    end)

    it("keeps unrelated quests outside the chain", function()
        SetRecords({[1] = {}, [2] = {}})
        assert.same({1}, QuestChain.GetQuestIds(1))
    end)

    it("rebuilds the index when the database pointers are refreshed", function()
        SetRecords({[1] = {}})
        assert.same({1}, QuestChain.GetQuestIds(1))
        SetRecords({[1] = {}, [2] = {preQuestSingle = {1}}})
        assert.same({1, 2}, QuestChain.GetQuestIds(1))
    end)
end)
