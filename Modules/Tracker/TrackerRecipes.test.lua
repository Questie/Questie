dofile("setupTests.lua")

describe("TrackerRecipes", function()
    ---@type TrackerRecipes
    local TrackerRecipes

    local trackedRecipes, schematics, itemNames, itemCounts

    before_each(function()
        trackedRecipes = {}
        schematics = {}
        itemNames = {}
        itemCounts = {}

        _G.C_TradeSkillUI = {
            GetRecipesTracked = spy.new(function() return trackedRecipes end),
            GetRecipeSchematic = function(recipeId) return schematics[recipeId] end,
            SetRecipeTracked = spy.new(function() end),
            IsRecipeProfessionLearned = function() return true end,
            OpenRecipe = spy.new(function() end),
            GetRecipeLink = function(recipeId) return "link:" .. recipeId end,
        }
        _G.C_Item.GetItemNameByID = function(itemId) return itemNames[itemId] end
        _G.C_Item.RequestLoadItemDataByID = spy.new(function() end)
        _G.ItemUtil = {
            GetCraftingReagentCount = function(itemId) return itemCounts[itemId] or 0 end,
        }
        _G.RETRIEVING_ITEM_INFO = "Retrieving item information"

        dofile("Modules/Tracker/TrackerRecipes.lua")
        TrackerRecipes = QuestieLoader:ImportModule("TrackerRecipes")
    end)

    after_each(function()
        _G.C_TradeSkillUI = nil
        _G.ItemUtil = nil
        _G.C_Item.GetItemNameByID = nil
        _G.C_Item.RequestLoadItemDataByID = nil
    end)

    describe("IsSupported", function()
        it("should return true when recipe tracking API exists", function()
            assert.is_true(TrackerRecipes.IsSupported())
        end)

        it("should return false when recipe tracking API is missing", function()
            _G.C_TradeSkillUI = nil

            assert.is_false(TrackerRecipes.IsSupported())
        end)

        it("should return false when only parts of the recipe tracking API exist", function()
            C_TradeSkillUI.GetRecipeSchematic = nil

            assert.is_false(TrackerRecipes.IsSupported())
        end)

        it("should return false when reagent counting is missing", function()
            _G.ItemUtil = nil

            assert.is_false(TrackerRecipes.IsSupported())
        end)
    end)

    describe("HasTrackedRecipes", function()
        it("should return true when a recipe is tracked", function()
            trackedRecipes = {2538}

            assert.is_true(TrackerRecipes.HasTrackedRecipes())
            assert.spy(C_TradeSkillUI.GetRecipesTracked).was.called_with(false)
        end)

        it("should return false when no recipe is tracked", function()
            assert.is_false(TrackerRecipes.HasTrackedRecipes())
        end)

        it("should return false when recipe tracking is not supported", function()
            _G.C_TradeSkillUI = nil

            assert.is_false(TrackerRecipes.HasTrackedRecipes())
        end)
    end)

    describe("HasShownRecipes", function()
        it("should return true when a tracked recipe has a schematic", function()
            trackedRecipes = {1, 2}
            schematics[2] = {name = "Recipe"}

            assert.is_true(TrackerRecipes.HasShownRecipes())
        end)

        it("should return false when no tracked recipe has a schematic", function()
            trackedRecipes = {1}

            assert.is_false(TrackerRecipes.HasShownRecipes())
        end)

        it("should return false when recipe tracking is not supported", function()
            _G.C_TradeSkillUI = nil

            assert.is_false(TrackerRecipes.HasShownRecipes())
        end)
    end)

    describe("GetTrackedRecipes", function()
        it("should return tracked recipes with their required reagents", function()
            trackedRecipes = {2538}
            schematics[2538] = {
                name = "Charred Wolf Meat",
                reagentSlotSchematics = {
                    {required = true, quantityRequired = 2, reagents = {{itemID = 2672}}},
                    {required = false, quantityRequired = 1, reagents = {{itemID = 3}}},
                },
            }
            itemNames[2672] = "Stringy Wolf Meat"
            itemCounts[2672] = 1

            local recipes = TrackerRecipes.GetTrackedRecipes()

            assert.are_same({{
                Id = 2538,
                Name = "Charred Wolf Meat",
                Reagents = {{ItemId = 2672, Name = "Stringy Wolf Meat", Collected = 1, Needed = 2}},
            }}, recipes)
        end)

        it("should sum the counts of all reagents in a slot", function()
            trackedRecipes = {1}
            schematics[1] = {
                name = "Recipe",
                reagentSlotSchematics = {
                    {required = true, quantityRequired = 5, reagents = {{itemID = 10}, {itemID = 11}}},
                },
            }
            itemNames[10] = "Item"
            itemCounts[10] = 2
            itemCounts[11] = 3

            local recipes = TrackerRecipes.GetTrackedRecipes()

            assert.are_same(5, recipes[1].Reagents[1].Collected)
        end)

        it("should show currency reagents with name and quantity", function()
            trackedRecipes = {1}
            schematics[1] = {
                name = "Recipe",
                reagentSlotSchematics = {
                    {required = true, quantityRequired = 3, reagents = {{currencyID = 5}}},
                },
            }
            _G.C_CurrencyInfo = {GetCurrencyInfo = function() return {name = "Coin", quantity = 7} end}

            local recipes = TrackerRecipes.GetTrackedRecipes()

            _G.C_CurrencyInfo = nil
            assert.are_same({{Name = "Coin", Collected = 7, Needed = 3}}, recipes[1].Reagents)
        end)

        it("should skip recipes without a schematic", function()
            trackedRecipes = {1}

            assert.are_same({}, TrackerRecipes.GetTrackedRecipes())
        end)

        it("should return an empty list when recipe tracking is not supported", function()
            _G.C_TradeSkillUI = nil

            assert.are_same({}, TrackerRecipes.GetTrackedRecipes())
        end)

        it("should request item data and use a placeholder when the item name is not cached", function()
            trackedRecipes = {1}
            schematics[1] = {
                name = "Recipe",
                reagentSlotSchematics = {
                    {required = true, quantityRequired = 1, reagents = {{itemID = 10}}},
                },
            }

            local recipes = TrackerRecipes.GetTrackedRecipes()

            assert.are_same("Retrieving item information", recipes[1].Reagents[1].Name)
            assert.spy(C_Item.RequestLoadItemDataByID).was.called_with(10)
        end)
    end)

    describe("OnItemInfoReceived", function()
        it("should return true once for an item requested for a recipe", function()
            trackedRecipes = {1}
            schematics[1] = {
                name = "Recipe",
                reagentSlotSchematics = {
                    {required = true, quantityRequired = 1, reagents = {{itemID = 10}}},
                },
            }
            TrackerRecipes.GetTrackedRecipes()

            assert.is_true(TrackerRecipes.OnItemInfoReceived(10))
            assert.is_false(TrackerRecipes.OnItemInfoReceived(10))
        end)

        it("should return false for an item not requested for a recipe", function()
            assert.is_false(TrackerRecipes.OnItemInfoReceived(10))
        end)
    end)

    describe("Untrack", function()
        it("should untrack the recipe", function()
            TrackerRecipes.Untrack(2538)

            assert.spy(C_TradeSkillUI.SetRecipeTracked).was.called_with(2538, false, false)
        end)
    end)

    describe("OpenRecipe", function()
        it("should open the recipe when the profession is learned", function()
            TrackerRecipes.OpenRecipe(2538)

            assert.spy(C_TradeSkillUI.OpenRecipe).was.called_with(2538)
        end)

        it("should not open the recipe when the profession is not learned", function()
            C_TradeSkillUI.IsRecipeProfessionLearned = function() return false end

            TrackerRecipes.OpenRecipe(2538)

            assert.spy(C_TradeSkillUI.OpenRecipe).was.not_called()
        end)
    end)

    describe("GetLink", function()
        it("should return the recipe link", function()
            assert.are_same("link:2538", TrackerRecipes.GetLink(2538))
        end)
    end)
end)
