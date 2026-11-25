---@class PetFood
local PetFood = QuestieLoader:CreateModule("PetFood")

---@type QuestieCombatQueue
local QuestieCombatQueue = QuestieLoader:ImportModule("QuestieCombatQueue")
---@type QuestieCompat
local QuestieCompat = QuestieLoader:ImportModule("QuestieCompat")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestiePlayer
local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")

local tinsert = table.insert

-- A pet refuses food whose item level is this much below the pet's level. No Blizzard source states the number: the addon
-- Feed-O-Matic and TrinityCore's current source use 30, older server emulators use 15 and call it a guess.
local REFUSED_LEVELS_BELOW_PET = 30

-- The food types and the level of the last known pet. They stay while no API knows a pet, so its food vendors stay on the
-- map. Level 0 is unknown and limits nothing.
---@type number[]
local lastFoodTypes = {}
local lastPetLevel = 0
-- Whether the stable may answer while no pet is out. The pet that was out last is the current one until the stable changes,
-- so the stable is asked only before a pet was out and after it changed.
local canAskStable = true

---Pet food only matters to hunters, and only on clients with pet happiness. QuestieDB publishes no pet food for the others.
---@return boolean
function PetFood.IsNeeded()
    return UnitClassBase("player") == "HUNTER" and LibQuestieDB.Support.Get("PetFood") ~= nil
end

---@param petFood QuestieDBPetFood
---@param names string[]? Food type names in the client's language
---@return number[] foodTypes Without the names QuestieDB does not know
local function _ToFoodTypes(petFood, names)
    local foodTypes = {}
    for _, name in ipairs(names or {}) do
        local foodType = petFood.foodTypesByName[name]
        if foodType then
            tinsert(foodTypes, foodType)
        else
            Questie.Debug(Questie.DEBUG_DEVELOP, "[PetFood] Unknown food type:", name)
        end
    end
    return foodTypes
end

---@param petFood QuestieDBPetFood
---@return number[] foodTypes Empty when no hunter pet is out, or nothing says what it eats
---@return number level 0 when unknown
local function _ReadActivePet(petFood)
    -- "pet" can also be a vehicle or a creature the player controls. Blizzard's pet happiness icon makes the same check:
    -- PetFrame.lua on 1.15.9, 2.5.6 and 3.80.2, PetHappiness.lua on 1.60.1.
    local _, isHunterPet = HasPetUI()
    if not isHunterPet then
        return {}, 0
    end

    -- The client knows best what its pet eats. QuestieDB's family table only helps out when that gives nothing.
    local foodTypes = _ToFoodTypes(petFood, QuestieCompat.GetPetFoodTypes())
    if not foodTypes[1] then
        -- 1.15.9, 2.5.6, 3.80.2 and 1.60.1 return the family ID. On Forever it can be a secret value, which addons must not
        -- compare, but not for a unit the player controls (SecretWhenUnitIdentityRestricted in its API documentation).
        local _, familyId = UnitCreatureFamily("pet")
        foodTypes = petFood.foodTypesByFamily[familyId] or {}
    end
    return foodTypes, UnitLevel("pet")
end

---The stable also knows the current pet while it is dismissed.
---@param petFood QuestieDBPetFood
---@return number[] foodTypes Empty when the stable knows no current pet
---@return number? level
local function _ReadStablePet(petFood)
    local names, level = QuestieCompat.GetCurrentStablePetFoodTypes()
    return _ToFoodTypes(petFood, names), level
end

---Asks the client what the player's pet eats.
local function _UpdatePet()
    local petFood = LibQuestieDB.Support.Get("PetFood")
    local foodTypes, level = _ReadActivePet(petFood)
    if foodTypes[1] then
        canAskStable = false
    elseif canAskStable then
        foodTypes, level = _ReadStablePet(petFood)
    end

    if foodTypes[1] then
        lastFoodTypes = foodTypes
        lastPetLevel = level
        -- GetItemIds compares the level whenever the vendor lists are rebuilt, so an answer it cannot compare must not stay
        if type(level) ~= "number" then
            Questie.Debug(Questie.DEBUG_DEVELOP, "[PetFood] Unknown pet level:", level)
            lastPetLevel = 0
        end
    end
end

---Updates the pet now and whenever it may have changed, always outside of fights. Call this only when pet food IsNeeded.
---@param onUpdated fun() Called after every update
function PetFood.RegisterEvents(onUpdated)
    -- One update is enough for everything that happens until the combat queue runs, which is after the fight
    local updatePending = false
    local function _QueueUpdate()
        if updatePending then
            return
        end

        updatePending = true
        QuestieCombatQueue:Queue(function()
            updatePending = false
            -- An error is reported but must not stop the rest of the combat queue
            xpcall(function()
                _UpdatePet()
                onUpdated()
            end, CallErrorHandler)
        end)
    end
    local function _QueueUpdateForPlayer(_, unit)
        if unit == "player" then
            _QueueUpdate()
        end
    end

    _QueueUpdate() -- The first update needs none of the events

    -- None of these events is known to fire for every way a pet can change, so each one leads to an update.
    -- All of them are in the API documentation of 1.15.9, 2.5.6, 3.80.2 and 1.60.1.
    Questie:RegisterEvent("UNIT_PET", _QueueUpdateForPlayer)
    Questie:RegisterEvent("UNIT_EXITED_VEHICLE", _QueueUpdateForPlayer)
    Questie:RegisterEvent("UNIT_LEVEL", function(_, unit)
        if unit == "pet" then
            _QueueUpdate()
        end
    end)
    Questie:RegisterEvent("PET_UI_UPDATE", _QueueUpdate)
    Questie:RegisterEvent("PET_STABLE_UPDATE", function()
        canAskStable = true
        _QueueUpdate()
    end)
end

---Call this only when pet food IsNeeded.
---@return ItemId[] itemIds Food the last known pet eats and that suits its and the player's level
function PetFood.GetItemIds()
    ---@type QuestieDBPetFood
    local petFood = LibQuestieDB.Support.Get("PetFood")
    local playerLevel = QuestiePlayer.GetPlayerLevel()

    local itemIds = {}
    for _, foodType in ipairs(lastFoodTypes) do
        for _, itemId in ipairs(petFood.itemIdsByFoodType[foodType] or {}) do
            -- The lists hold every food of the client, also Items QuestieDB does not have. Number fields are nil only for those,
            -- so checking one of them covers requiredLevel too.
            local itemLevel = QuestieDB.QueryItemSingle(itemId, "itemLevel")
            if itemLevel and itemLevel + REFUSED_LEVELS_BELOW_PET > lastPetLevel
                and QuestieDB.QueryItemSingle(itemId, "requiredLevel") <= playerLevel then
                tinsert(itemIds, itemId)
            end
        end
    end
    return itemIds
end
