-- Reads profession recipes tracked through Blizzard's recipe tracking (C_TradeSkillUI) for display in the tracker.
---@class TrackerRecipes
local TrackerRecipes = QuestieLoader:CreateModule("TrackerRecipes")

---@class TrackerRecipeReagent
---@field ItemId number|nil Nil for currency reagents
---@field Name string
---@field Collected number
---@field Needed number

---@class TrackerRecipe
---@field Id number Recipe spell ID
---@field Name string
---@field Reagents TrackerRecipeReagent[]

-- Items whose name was requested from the server. A tracker update is needed once they arrive.
local pendingItemIds = {}

---@return boolean
function TrackerRecipes.IsSupported()
    return C_TradeSkillUI ~= nil and C_TradeSkillUI.GetRecipesTracked ~= nil and C_TradeSkillUI.GetRecipeSchematic ~= nil
        and ItemUtil ~= nil and ItemUtil.GetCraftingReagentCount ~= nil
end

---@return boolean
function TrackerRecipes.HasTrackedRecipes()
    if (not TrackerRecipes.IsSupported()) then
        return false
    end

    return #C_TradeSkillUI.GetRecipesTracked(false) > 0
end

---@param itemId number
---@return string
local function _GetItemName(itemId)
    local name = C_Item.GetItemNameByID(itemId)
    if name then
        return name
    end

    pendingItemIds[itemId] = true
    C_Item.RequestLoadItemDataByID(itemId)
    return RETRIEVING_ITEM_INFO or ""
end

---@param reagents table CraftingReagent[] of one reagent slot
---@return number
local function _CountReagents(reagents)
    local count = 0
    for _, reagent in ipairs(reagents) do
        if reagent.itemID then
            count = count + ItemUtil.GetCraftingReagentCount(reagent.itemID)
        end
    end
    return count
end

---@param recipeId number
---@return TrackerRecipe|nil
local function _GetRecipe(recipeId)
    local schematic = C_TradeSkillUI.GetRecipeSchematic(recipeId, false)
    if (not schematic) or (not schematic.name) then
        return nil
    end

    local reagents = {}
    for _, slot in ipairs(schematic.reagentSlotSchematics or {}) do
        local firstReagent = slot.reagents and slot.reagents[1]
        if slot.required and firstReagent then
            if firstReagent.itemID then
                reagents[#reagents + 1] = {
                    ItemId = firstReagent.itemID,
                    Name = _GetItemName(firstReagent.itemID),
                    Collected = _CountReagents(slot.reagents),
                    Needed = slot.quantityRequired,
                }
            elseif firstReagent.currencyID then
                local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(firstReagent.currencyID)
                if currencyInfo then
                    reagents[#reagents + 1] = {
                        Name = currencyInfo.name,
                        Collected = currencyInfo.quantity,
                        Needed = slot.quantityRequired,
                    }
                end
            end
        end
    end

    return {
        Id = recipeId,
        Name = schematic.name,
        Reagents = reagents,
    }
end

---@return TrackerRecipe[]
function TrackerRecipes.GetTrackedRecipes()
    local recipes = {}
    if (not TrackerRecipes.IsSupported()) then
        return recipes
    end

    for _, recipeId in ipairs(C_TradeSkillUI.GetRecipesTracked(false)) do
        local recipe = _GetRecipe(recipeId)
        if recipe then
            recipes[#recipes + 1] = recipe
        end
    end
    return recipes
end

---@param recipeId number
function TrackerRecipes.Untrack(recipeId)
    C_TradeSkillUI.SetRecipeTracked(recipeId, false, false)
end

---@param recipeId number
function TrackerRecipes.OpenRecipe(recipeId)
    if C_TradeSkillUI.IsRecipeProfessionLearned(recipeId) then
        C_TradeSkillUI.OpenRecipe(recipeId)
    end
end

---@param recipeId number
---@return string|nil
function TrackerRecipes.GetLink(recipeId)
    return C_TradeSkillUI.GetRecipeLink(recipeId)
end

--- Call when GET_ITEM_INFO_RECEIVED fires.
---@param itemId number
---@return boolean @True when the item was requested for a tracked recipe, so the tracker needs an update
function TrackerRecipes.OnItemInfoReceived(itemId)
    if (not pendingItemIds[itemId]) then
        return false
    end

    pendingItemIds[itemId] = nil
    return true
end
