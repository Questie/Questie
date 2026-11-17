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
        it("should mark monsters dropping the item hostile, and vendors selling it and objects holding it not", function()
            QuestieDB.GetItem = function()
                return {Id = 10, Sources = {{Type = "monster", Id = 1}, {Type = "monster", Id = 3, Vendor = true}, {Type = "object", Id = 2}}}
            end
            QuestieDB.QueryNPCSingle = function(_, key) return key == "name" and "Kobold" or nil end
            QuestieDB.QueryObjectSingle = function(_, key) return key == "name" and "Crate" or nil end

            local spawnList = _QuestieQuest.objectiveSpawnListCallTable.item(10, {Description = "Candles"})

            assert.is_true(spawnList[1].Hostile)
            assert.is_nil(spawnList[3].Hostile)
            assert.is_nil(spawnList[2].Hostile)
        end)

        it("should not mark a vendor hostile that is also listed as dropping the item", function()
            QuestieDB.GetItem = function() return {Id = 10, Sources = {{Type = "monster", Id = 1}, {Type = "monster", Id = 1, Vendor = true}}} end
            QuestieDB.QueryNPCSingle = function(_, key) return key == "name" and "Innkeeper" or nil end

            local spawnList = _QuestieQuest.objectiveSpawnListCallTable.item(10, {Description = "Malt"})

            assert.is_nil(spawnList[1].Hostile)
        end)

        it("should keep a creature and an object with the same ID as separate sources", function()
            QuestieDB.GetItem = function()
                return {Id = 10, Sources = {{Type = "monster", Id = 5}, {Type = "object", Id = 5}}}
            end
            QuestieDB.QueryNPCSingle = function(_, key) return key == "name" and "Kobold" or nil end
            QuestieDB.QueryObjectSingle = function(_, key) return key == "name" and "Crate" or nil end

            local spawnList = _QuestieQuest.objectiveSpawnListCallTable.item(10, {Description = "Candles"})

            local sources = {}
            for _, source in pairs(spawnList) do
                sources[source.TooltipKey] = source
            end
            assert.is_not_nil(sources.m_5)
            assert.is_not_nil(sources.o_5)
            assert.are_same("Kobold", sources.m_5.Name)
            assert.are_same(Questie.ICON_TYPE_LOOT, sources.m_5.Icon)
            assert.are_same("Crate", sources.o_5.Name)
            assert.are_same(Questie.ICON_TYPE_OBJECT, sources.o_5.Icon)
        end)
    end)
end)
