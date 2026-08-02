dofile("setupTests.lua")

describe("SpawnListBuilders", function()
    ---@type SpawnListBuilders
    local SpawnListBuilders
    ---@type QuestieDB
    local QuestieDB
    ---@type QuestieCorrections
    local QuestieCorrections

    local function makeObjective(overrides)
        local o = {
            Id = 10,
            Index = 1,
            Type = "monster",
            Description = "Kill things",
            Completed = false,
            spawnList = {},
            AlreadySpawned = {},
        }
        for k, v in pairs(overrides or {}) do o[k] = v end
        return o
    end

    before_each(function()
        Questie.db.profile = {
            monsterScale = 1,
            objectScale = 1,
            eventScale = 1.35,
            lootScale = 1,
        }
        Questie.ICON_TYPE_SLAY = "slay"
        Questie.ICON_TYPE_OBJECT = "object"
        Questie.ICON_TYPE_EVENT = "event"
        Questie.ICON_TYPE_LOOT = "loot"

        QuestieDB = QuestieLoader:ImportModule("QuestieDB")
        QuestieDB.QueryNPCSingle = function() return nil end
        QuestieDB.QueryObjectSingle = function() return nil end
        QuestieDB.GetItem = function() return nil end

        QuestieCorrections = QuestieLoader:ImportModule("QuestieCorrections")
        QuestieCorrections.questNPCBlacklist = {}

        dofile("Modules/Quest/SpawnListBuilders.lua")
        SpawnListBuilders = QuestieLoader:ImportModule("SpawnListBuilders")
    end)

    -- -------------------------------------------------------------------------
    -- monster
    -- -------------------------------------------------------------------------
    describe("builders.monster", function()
        it("should return a spawn list entry for a valid NPC", function()
            QuestieDB.QueryNPCSingle = function(npcId, key)
                if key == "name" then return "Boar" end
                if key == "spawns" then return {[1] = {{10, 20}}} end
                return nil
            end

            local result = SpawnListBuilders.builders["monster"](5, makeObjective())

            assert.is_not_nil(result)
            assert.is_not_nil(result[5])
            assert.are_equal("Boar", result[5].Name)
            assert.are_equal("m_5", result[5].TooltipKey)
        end)

        it("should return nil and log an error when npcId is nil", function()
            local errorCalled = false
            Questie.Error = function() errorCalled = true end

            local result = SpawnListBuilders.builders["monster"](nil, makeObjective())

            assert.is_nil(result)
            assert.is_true(errorCalled)
        end)

        it("should return nil and log an error when name is missing", function()
            local errorCalled = false
            Questie.Error = function() errorCalled = true end
            QuestieDB.QueryNPCSingle = function() return nil end

            local result = SpawnListBuilders.builders["monster"](99, makeObjective())

            assert.is_nil(result)
            assert.is_true(errorCalled)
        end)

        it("should not include spawns for blacklisted NPCs", function()
            QuestieDB.QueryNPCSingle = function(npcId, key)
                if key == "name" then return "BlacklistedMob" end
                if key == "spawns" then return {[1] = {{10, 20}}} end
                return nil
            end
            QuestieCorrections.questNPCBlacklist = {[7] = true}

            local result = SpawnListBuilders.builders["monster"](7, makeObjective())

            assert.are_same({}, result[7].Spawns)
        end)

        it("should use ICON_TYPE_SLAY when objective has no icon", function()
            QuestieDB.QueryNPCSingle = function(_, key)
                if key == "name" then return "Mob" end
                return nil
            end

            local result = SpawnListBuilders.builders["monster"](5, makeObjective())

            assert.are_equal("slay", result[5].Icon)
        end)
    end)

    -- -------------------------------------------------------------------------
    -- object
    -- -------------------------------------------------------------------------
    describe("builders.object", function()
        it("should return a spawn list entry for a valid object", function()
            QuestieDB.QueryObjectSingle = function(objectId, key)
                if key == "name" then return "Chest" end
                if key == "spawns" then return {[2] = {{30, 40}}} end
                return nil
            end

            local result = SpawnListBuilders.builders["object"](8, makeObjective())

            assert.is_not_nil(result[8])
            assert.are_equal("Chest", result[8].Name)
            assert.are_equal("o_8", result[8].TooltipKey)
        end)

        it("should return nil and log an error when objectId is nil", function()
            local errorCalled = false
            Questie.Error = function() errorCalled = true end

            local result = SpawnListBuilders.builders["object"](nil, makeObjective())

            assert.is_nil(result)
            assert.is_true(errorCalled)
        end)

        it("should return nil and log an error when name is missing", function()
            local errorCalled = false
            Questie.Error = function() errorCalled = true end
            QuestieDB.QueryObjectSingle = function() return nil end

            local result = SpawnListBuilders.builders["object"](99, makeObjective())

            assert.is_nil(result)
            assert.is_true(errorCalled)
        end)
    end)

    -- -------------------------------------------------------------------------
    -- event
    -- -------------------------------------------------------------------------
    describe("builders.event", function()
        it("should return a spawn list entry using objective.Coordinates as spawns", function()
            local coords = {[3] = {{55, 65}}}
            local objective = makeObjective({Coordinates = coords})

            local result = SpawnListBuilders.builders["event"](0, objective)

            assert.is_not_nil(result[1])
            assert.are_equal(coords, result[1].Spawns)
            assert.are_equal("event", result[1].Icon)
        end)

        it("should log an error and use empty spawns when Coordinates is nil", function()
            local errorCalled = false
            Questie.Error = function() errorCalled = true end

            local result = SpawnListBuilders.builders["event"](0, makeObjective())

            assert.is_not_nil(result[1])
            assert.is_true(errorCalled)
            assert.are_same({}, result[1].Spawns)
        end)
    end)

    -- -------------------------------------------------------------------------
    -- item
    -- -------------------------------------------------------------------------
    describe("builders.item", function()
        it("should return nil and log an error when itemId is nil", function()
            local errorCalled = false
            Questie.Error = function() errorCalled = true end

            local result = SpawnListBuilders.builders["item"](nil, makeObjective())

            assert.is_nil(result)
            assert.is_true(errorCalled)
        end)

        it("should return empty table when item has no Sources", function()
            QuestieDB.GetItem = function() return {Id = 1, Sources = nil, Hidden = false} end

            local result = SpawnListBuilders.builders["item"](1, makeObjective())

            assert.are_same({}, result)
        end)

        it("should return empty table when item is hidden", function()
            QuestieDB.GetItem = function() return {Id = 1, Sources = {{Type = "monster", Id = 5}}, Hidden = true} end

            local result = SpawnListBuilders.builders["item"](1, makeObjective())

            assert.are_same({}, result)
        end)

        it("should aggregate spawns from a monster source", function()
            QuestieDB.GetItem = function()
                return {Id = 50, Sources = {{Type = "monster", Id = 5}}, Hidden = false}
            end
            QuestieDB.QueryNPCSingle = function(npcId, key)
                if key == "name" then return "DropMob" end
                if key == "spawns" then return {[10] = {{25, 35}}} end
                return nil
            end

            local result = SpawnListBuilders.builders["item"](50, makeObjective())

            assert.is_not_nil(result[5])
            assert.are_equal(50, result[5].ItemId)
            assert.is_not_nil(result[5].Spawns[10])
        end)
    end)

    -- -------------------------------------------------------------------------
    -- spell
    -- -------------------------------------------------------------------------
    describe("builders.spell", function()
        it("should return nil and log an error when spellId is nil", function()
            local errorCalled = false
            Questie.Error = function() errorCalled = true end

            local result = SpawnListBuilders.builders["spell"](nil, makeObjective(), {})

            assert.is_nil(result)
            assert.is_true(errorCalled)
        end)

        it("should delegate to the item builder using objectiveData.ItemSourceId", function()
            QuestieDB.GetItem = function() return nil end

            -- spell delegates to item; item with no DB entry returns {}
            local result = SpawnListBuilders.builders["spell"](99, makeObjective(), {ItemSourceId = 42})

            assert.are_same({}, result)
        end)
    end)

    -- -------------------------------------------------------------------------
    -- killcredit
    -- -------------------------------------------------------------------------
    describe("builders.killcredit", function()
        it("should return merged entries from monster builder for each id in IdList", function()
            QuestieDB.QueryNPCSingle = function(npcId, key)
                if key == "name" then return "KillCreditMob_" .. npcId end
                return nil
            end

            local objectiveData = {IdList = {10, 11}}
            local result = SpawnListBuilders.builders["killcredit"](0, makeObjective(), objectiveData)

            assert.is_not_nil(result[10])
            assert.is_not_nil(result[11])
            assert.are_equal("KillCreditMob_10", result[10].Name)
            assert.are_equal("KillCreditMob_11", result[11].Name)
        end)
    end)
end)
