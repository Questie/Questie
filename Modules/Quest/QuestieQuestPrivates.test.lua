dofile("setupTests.lua")

describe("QuestieQuestPrivates", function()
    ---@type QuestieDB
    local QuestieDB
    ---@type QuestieQuestPrivate
    local _QuestieQuest

    before_each(function()
        QuestieDB = QuestieLoader:ImportModule("QuestieDB")
        QuestieLoader:ImportModule("QuestieCorrections").questNPCBlacklist = {}
        dofile("Modules/Quest/QuestieQuestPrivates.lua")
        _QuestieQuest = QuestieLoader:ImportModule("QuestieQuest").private
    end)

    describe("item", function()
        it("should mark monsters dropping the item hostile, and objects holding it not", function()
            QuestieDB.GetItem = function() return {Id = 10, Sources = {{Type = "monster", Id = 1}, {Type = "object", Id = 2}}} end
            QuestieDB.QueryNPCSingle = function(_, key) return key == "name" and "Kobold" or nil end
            QuestieDB.QueryObjectSingle = function(_, key) return key == "name" and "Crate" or nil end

            local spawnList = _QuestieQuest.objectiveSpawnListCallTable.item(10, {Description = "Candles"})

            assert.is_true(spawnList[1].Hostile)
            assert.is_nil(spawnList[2].Hostile)
        end)
    end)
end)
