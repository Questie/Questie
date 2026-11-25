dofile("setupTests.lua")

local LoadQuestieDBMock = dofile("test/QuestieDBMock.lua")

describe("PetFood", function()
    ---@type PetFood
    local PetFood
    ---@type QuestieDBMock
    local mock

    local WOLF, CAT = 1, 2
    local MEAT, FISH, FRUIT, RAW_MEAT = 1, 2, 6, 7
    -- Item levels and required levels are the ones these Items have in game.
    local TOUGH_JERKY, HAUNCH_OF_MEAT, ROASTED_QUAIL = 117, 2287, 8952
    local SLITHERSKIN_MACKEREL, SHINY_RED_APPLE = 787, 4536
    local NOT_IN_DATABASE = 12211

    local originals
    -- What the client knows about the pet
    local pet, stablePet
    local isHunterPet
    local playerClass, playerLevel
    -- What PetFood registered, queued and reported
    local callbacks, queued, reportedErrors
    local onUpdated

    ---@param name string
    ---@param familyId number?
    ---@param level number
    ---@param ... string Its food types in the client's language
    local function _PetOut(name, familyId, level, ...)
        pet = {name = name, familyId = familyId, level = level, foodTypeNames = {...}}
    end

    before_each(function()
        originals = {
            UnitCreatureFamily = _G.UnitCreatureFamily,
            UnitLevel = _G.UnitLevel,
            UnitClassBase = _G.UnitClassBase,
            HasPetUI = _G.HasPetUI,
            CallErrorHandler = _G.CallErrorHandler,
            RegisterEvent = Questie.RegisterEvent,
            Debug = Questie.Debug,
        }
        mock = LoadQuestieDBMock()
        local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
        local itemKeys = QuestieDB.itemKeys
        QuestieDB.QueryItemSingle = mock.lib.Item.Get
        mock.supportModules.PetFood = {
            itemIdsByFoodType = {
                [MEAT] = {TOUGH_JERKY, HAUNCH_OF_MEAT, ROASTED_QUAIL, NOT_IN_DATABASE},
                [FISH] = {SLITHERSKIN_MACKEREL},
                [FRUIT] = {SHINY_RED_APPLE},
            },
            foodTypesByFamily = {[WOLF] = {MEAT}, [CAT] = {MEAT, FISH}},
            foodTypesByName = {Meat = MEAT, Fish = FISH, Fruit = FRUIT, ["Raw Meat"] = RAW_MEAT, Fleisch = MEAT, Fisch = FISH},
        }
        mock.SetBaseRow("Item", TOUGH_JERKY, {[itemKeys.itemLevel] = 5, [itemKeys.requiredLevel] = 1})
        mock.SetBaseRow("Item", HAUNCH_OF_MEAT, {[itemKeys.itemLevel] = 15, [itemKeys.requiredLevel] = 5})
        mock.SetBaseRow("Item", ROASTED_QUAIL, {[itemKeys.itemLevel] = 55, [itemKeys.requiredLevel] = 45})
        mock.SetBaseRow("Item", SLITHERSKIN_MACKEREL, {[itemKeys.itemLevel] = 5, [itemKeys.requiredLevel] = 1})
        mock.SetBaseRow("Item", SHINY_RED_APPLE, {[itemKeys.itemLevel] = 5, [itemKeys.requiredLevel] = 1})

        pet, stablePet, isHunterPet, playerClass, playerLevel = nil, nil, true, "HUNTER", 60
        _G.UnitClassBase = function() return playerClass end
        _G.HasPetUI = function() return pet ~= nil, pet ~= nil and isHunterPet end
        _G.UnitCreatureFamily = function(unit)
            if unit == "pet" and pet then return pet.name, pet.familyId end
        end
        _G.UnitLevel = function(unit)
            if unit == "pet" then return pet and pet.level or 0 end
            return 1 -- PLAYER_LEVEL_UP fires before the client applies the new level
        end
        local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
        originals.GetPlayerLevel = QuestiePlayer.GetPlayerLevel
        QuestiePlayer.GetPlayerLevel = function() return playerLevel end
        local QuestieCompat = QuestieLoader:ImportModule("QuestieCompat")
        originals.GetPetFoodTypes = QuestieCompat.GetPetFoodTypes
        originals.GetCurrentStablePetFoodTypes = QuestieCompat.GetCurrentStablePetFoodTypes
        QuestieCompat.GetPetFoodTypes = function() return pet and pet.foodTypeNames or {} end
        QuestieCompat.GetCurrentStablePetFoodTypes = function()
            if stablePet then return stablePet.foodTypeNames, stablePet.level end
        end

        callbacks, queued, reportedErrors = {}, {}, {}
        Questie.RegisterEvent = function(_, event, callback) callbacks[event] = callback end
        Questie.Debug = spy.new(function() end)
        local QuestieCombatQueue = QuestieLoader:ImportModule("QuestieCombatQueue")
        originals.Queue = QuestieCombatQueue.Queue
        QuestieCombatQueue.Queue = function(_, callback) table.insert(queued, callback) end
        _G.CallErrorHandler = function(message) table.insert(reportedErrors, message) end
        onUpdated = spy.new(function() end)

        dofile("Modules/QuestieMenu/PetFood.lua")
        PetFood = QuestieLoader:ImportModule("PetFood")
        PetFood.RegisterEvents(function() onUpdated() end)
    end)

    after_each(function()
        for _, name in ipairs({"UnitCreatureFamily", "UnitLevel", "UnitClassBase", "HasPetUI", "CallErrorHandler"}) do
            _G[name] = originals[name]
        end
        Questie.RegisterEvent = originals.RegisterEvent
        Questie.Debug = originals.Debug
        QuestieLoader:ImportModule("QuestieCombatQueue").Queue = originals.Queue
        QuestieLoader:ImportModule("QuestiePlayer").GetPlayerLevel = originals.GetPlayerLevel
        local QuestieCompat = QuestieLoader:ImportModule("QuestieCompat")
        QuestieCompat.GetPetFoodTypes = originals.GetPetFoodTypes
        QuestieCompat.GetCurrentStablePetFoodTypes = originals.GetCurrentStablePetFoodTypes
    end)

    local function _LeaveCombat()
        local callbacksToRun = queued
        queued = {}
        for _, callback in ipairs(callbacksToRun) do callback() end
    end

    local function _UpdatePet()
        callbacks.PET_UI_UPDATE("PET_UI_UPDATE")
        _LeaveCombat()
        assert.are_same({}, reportedErrors)
    end

    ---@return ItemId[] itemIds What the pet eats after an update, ascending
    local function _Food()
        _UpdatePet()
        local itemIds = PetFood.GetItemIds()
        table.sort(itemIds)
        return itemIds
    end

    describe("IsNeeded", function()
        it("should be true for a hunter on a client with pet food", function()
            assert.is_true(PetFood.IsNeeded())
        end)

        it("should be false for other classes with a pet", function()
            playerClass = "WARLOCK"
            assert.is_false(PetFood.IsNeeded())
        end)

        it("should be false for a hunter on a client without pet happiness", function()
            mock.supportModules.PetFood = nil
            assert.is_false(PetFood.IsNeeded())
        end)
    end)

    describe("GetItemIds", function()
        it("should return only food of the pet's food types", function()
            playerLevel = 10
            _PetOut("Wolf", WOLF, 10, "Meat")
            assert.are_same({TOUGH_JERKY, HAUNCH_OF_MEAT}, _Food())

            _PetOut("Cat", CAT, 10, "Meat", "Fish")
            assert.are_same({TOUGH_JERKY, SLITHERSKIN_MACKEREL, HAUNCH_OF_MEAT}, _Food())
        end)

        it("should leave out food that is 30 or more item levels below the pet", function()
            _PetOut("Wolf", WOLF, 34, "Meat")
            assert.are_same({TOUGH_JERKY, HAUNCH_OF_MEAT, ROASTED_QUAIL}, _Food())

            pet.level = 35
            assert.are_same({HAUNCH_OF_MEAT, ROASTED_QUAIL}, _Food())
        end)

        it("should measure that from the pet's level instead of the player's", function()
            playerLevel = 60
            _PetOut("Wolf", WOLF, 10, "Meat")
            assert.are_same({TOUGH_JERKY, HAUNCH_OF_MEAT, ROASTED_QUAIL}, _Food())
        end)

        it("should leave out food the player is too low to use", function()
            _PetOut("Wolf", WOLF, 10, "Meat")
            playerLevel = 4
            assert.are_same({TOUGH_JERKY}, _Food())
            playerLevel = 5
            assert.are_same({TOUGH_JERKY, HAUNCH_OF_MEAT}, _Food())
        end)

        it("should handle a food type no Item has", function()
            playerLevel = 10
            _PetOut("Owl", 26, 10, "Meat", "Raw Meat")
            assert.are_same({TOUGH_JERKY, HAUNCH_OF_MEAT}, _Food())
        end)

        it("should return nothing before any pet is known", function()
            assert.are_same({}, _Food())
        end)

        it("should not ask the client about the pet, so that building the lists at startup cannot fail", function()
            _G.HasPetUI = function() error("no pet API") end
            _G.UnitCreatureFamily = function() error("no pet API") end

            assert.are_same({}, PetFood.GetItemIds())
        end)
    end)

    describe("an update", function()
        it("should follow the player to another pet, also to one of a lower level", function()
            _PetOut("Wolf", WOLF, 60, "Meat")
            assert.are_same({ROASTED_QUAIL}, _Food())

            _PetOut("Wolf", WOLF, 10, "Meat")
            assert.are_same({TOUGH_JERKY, HAUNCH_OF_MEAT, ROASTED_QUAIL}, _Food())

            _PetOut("Newcomer", 999, 10, "Fruit")
            assert.are_same({SHINY_RED_APPLE}, _Food())
        end)

        describe("with a pet out", function()
            it("should believe the client rather than QuestieDB's family table", function()
                _PetOut("Wolf", WOLF, 10, "Fruit")
                assert.are_same({SHINY_RED_APPLE}, _Food())
            end)

            it("should keep to the client's names when QuestieDB does not know all of them", function()
                _PetOut("Wolf", WOLF, 10, "Something new", "Fruit")
                assert.are_same({SHINY_RED_APPLE}, _Food())
            end)

            it("should understand the client's language", function()
                playerLevel = 10
                _PetOut("Katze", CAT, 10, "Fisch", "Fleisch")
                assert.are_same({TOUGH_JERKY, SLITHERSKIN_MACKEREL, HAUNCH_OF_MEAT}, _Food())
            end)

            it("should use the family table when the client gives no names", function()
                playerLevel = 10
                _PetOut("Wolf", WOLF, 10)
                assert.are_same({TOUGH_JERKY, HAUNCH_OF_MEAT}, _Food())
            end)

            it("should use the family table when QuestieDB knows none of the names", function()
                playerLevel = 10
                _PetOut("Cat", CAT, 10, "Something new")
                assert.are_same({TOUGH_JERKY, SLITHERSKIN_MACKEREL, HAUNCH_OF_MEAT}, _Food())
            end)

            it("should not need a family ID", function()
                _PetOut("Newcomer", nil, 10, "Fruit")
                assert.are_same({SHINY_RED_APPLE}, _Food())
            end)

            it("should find nothing for a pet that eats nothing, in no API", function()
                _PetOut("Newcomer", nil, 10)
                assert.are_same({}, _Food())
                _PetOut("Newcomer", 999, 10)
                assert.are_same({}, _Food())
            end)

            it("should ignore a vehicle or another creature the player controls", function()
                _PetOut("Newcomer", 999, 10, "Fruit")
                _UpdatePet()

                isHunterPet = false
                _PetOut("Frostworg", CAT, 80, "Meat", "Fish")
                assert.are_same({SHINY_RED_APPLE}, _Food())
            end)

            it("should not limit the food by a level the client does not know", function()
                _PetOut("Wolf", WOLF, 60, "Meat")
                _UpdatePet()

                pet.level = 0
                assert.are_same({TOUGH_JERKY, HAUNCH_OF_MEAT, ROASTED_QUAIL}, _Food())
            end)
        end)

        it("should report a level it cannot compare, and not limit the food by it", function()
            _PetOut("Wolf", WOLF, "60", "Meat")

            assert.are_same({TOUGH_JERKY, HAUNCH_OF_MEAT, ROASTED_QUAIL}, _Food())
            assert.spy(Questie.Debug).was.called_with(Questie.DEBUG_DEVELOP, "[PetFood] Unknown pet level:", "60")
        end)

        describe("without a pet out", function()
            it("should ask the stable for the current pet", function()
                stablePet = {foodTypeNames = {"Meat"}, level = 40}
                -- Tough Jerky is too low for a level 40 pet
                assert.are_same({HAUNCH_OF_MEAT, ROASTED_QUAIL}, _Food())
            end)

            it("should not limit the food by a level the stable does not know", function()
                stablePet = {foodTypeNames = {"Meat"}, level = nil}
                assert.are_same({TOUGH_JERKY, HAUNCH_OF_MEAT, ROASTED_QUAIL}, _Food())
            end)

            it("should prefer a pet that is out over the stable", function()
                stablePet = {foodTypeNames = {"Fruit"}, level = 10}
                _PetOut("Wolf", WOLF, 40, "Meat")
                assert.are_same({HAUNCH_OF_MEAT, ROASTED_QUAIL}, _Food())
            end)

            it("should keep the last pet and its level when no API knows one", function()
                _PetOut("Wolf", WOLF, 40, "Meat")
                _UpdatePet()

                pet = nil
                assert.are_same({HAUNCH_OF_MEAT, ROASTED_QUAIL}, _Food())
            end)

            it("should keep the pet that was out last rather than one the stable describes", function()
                stablePet = {foodTypeNames = {"Fruit"}, level = 9}
                _UpdatePet()
                _PetOut("Wolf", WOLF, 40, "Meat") -- newly tamed
                _UpdatePet()

                pet = nil
                assert.are_same({HAUNCH_OF_MEAT, ROASTED_QUAIL}, _Food())
            end)

            it("should follow the stable to another pet once it has changed, however often it did", function()
                _PetOut("Wolf", WOLF, 10, "Meat")
                _UpdatePet()

                pet = nil
                stablePet = {foodTypeNames = {"Fruit"}, level = 10}
                callbacks.PET_STABLE_UPDATE("PET_STABLE_UPDATE")
                callbacks.PET_STABLE_UPDATE("PET_STABLE_UPDATE")
                assert.are_same({SHINY_RED_APPLE}, _Food())
            end)
        end)
    end)

    describe("RegisterEvents", function()
        it("should update the pet once without any event", function()
            _LeaveCombat()
            assert.spy(onUpdated).was.called(1)
        end)

        it("should tell about an update when the food of the new pet is known", function()
            local food
            onUpdated = function() food = PetFood.GetItemIds() end
            _PetOut("Newcomer", 999, 10, "Fruit")

            _LeaveCombat()

            assert.are_same({SHINY_RED_APPLE}, food)
        end)

        for event, unit in pairs({UNIT_PET = "player", UNIT_EXITED_VEHICLE = "player", UNIT_LEVEL = "pet",
            PET_UI_UPDATE = false, PET_STABLE_UPDATE = false}) do
            it("should update the pet after the fight on " .. event, function()
                _LeaveCombat()
                onUpdated:clear()

                callbacks[event](event, unit or nil)
                assert.spy(onUpdated).was.not_called()

                _LeaveCombat()
                assert.spy(onUpdated).was.called(1)
            end)
        end

        it("should update the pet once for all events until the fight is over, and again after the next one", function()
            for fight = 1, 2 do
                callbacks.UNIT_PET("UNIT_PET", "player")
                callbacks.PET_UI_UPDATE("PET_UI_UPDATE")
                callbacks.UNIT_LEVEL("UNIT_LEVEL", "pet")
                _LeaveCombat()
                assert.spy(onUpdated).was.called(fight)
            end
        end)

        it("should ignore other units", function()
            _LeaveCombat()

            callbacks.UNIT_PET("UNIT_PET", "party1")
            callbacks.UNIT_EXITED_VEHICLE("UNIT_EXITED_VEHICLE", "party1")
            callbacks.UNIT_LEVEL("UNIT_LEVEL", "target")

            assert.are_same({}, queued)
        end)

        it("should report an error of an update and update again on the next event", function()
            onUpdated = function() error("failed update") end
            _LeaveCombat() -- An error would stop the rest of the combat queue
            assert.are_equal(1, #reportedErrors)
            assert.is_truthy(reportedErrors[1]:find("failed update", 1, true))

            onUpdated = spy.new(function() end)
            callbacks.UNIT_PET("UNIT_PET", "player")
            _LeaveCombat()
            assert.spy(onUpdated).was.called(1)
        end)

        it("should update the pet even when the client does not know an event", function()
            _LeaveCombat()
            onUpdated:clear()
            Questie.RegisterEvent = function(_, event) error("Attempt to register unknown event " .. event) end

            assert.has_error(function() PetFood.RegisterEvents(function() onUpdated() end) end)
            _LeaveCombat()

            assert.spy(onUpdated).was.called(1)
        end)
    end)
end)
