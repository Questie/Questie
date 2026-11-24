---@type QuestieCompat
local QuestieCompat = QuestieLoader:ImportModule("QuestieCompat")

---@class Townsfolk
local Townsfolk = QuestieLoader:CreateModule("Townsfolk")

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestieProfessions
local QuestieProfessions = QuestieLoader:ImportModule("QuestieProfessions")
---@type Expansions
local Expansions = QuestieLoader:ImportModule("Expansions")
---@type ProfessionStations
local ProfessionStations = QuestieLoader:ImportModule("ProfessionStations")

local playerClass = UnitClassBase("player")
local playerFaction = UnitFactionGroup("player")

local tinsert, sort = table.insert, table.sort
local sub = string.sub

local professionKeys = QuestieProfessions.professionKeys
local serviceKeys = QuestieDB.serviceKeys

-- Townsfolk lookups, rebuilt from composed reads on every login by `Initialize`. They live on
-- the module rather than in SavedVariables because nothing is meant to survive a session;
-- QuestieMenu reads them to build the townsfolk and profession menus.
---@type table<string, NpcId[]> Category name to NPC IDs, both factions
Townsfolk.townsfolk = {}
---@type table<ProfessionKey, NpcId[]>
Townsfolk.professionTrainers = {}
---@type table<string, table<string, NpcId[]>> Class file name to category to NPC IDs
Townsfolk.classSpecificTownsfolk = {}
---@type table<string, table<string, NpcId[]>> Faction name to category to NPC IDs
Townsfolk.factionSpecificTownsfolk = {}
---@type table<string, ItemId[]> Pet food category to Item IDs; the lists stay empty for non-hunters
Townsfolk.petFoodVendorTypes = {}

-- QuestieDB states what each NPC and object provides in its `services` field. The tables below
-- only say which menu category a service belongs to.

-- Categories every character sees. They exist even when empty, so their menu rows always resolve.
---@type table<integer, string> Service to category name
local sharedNpcCategories = {
    [serviceKeys.REPAIR] = "Repair",
    [serviceKeys.AUCTIONEER] = "Auctioneer",
    [serviceKeys.BANKER] = "Banker",
    [serviceKeys.BATTLEMASTER] = "Battlemaster",
    [serviceKeys.FLIGHT_MASTER] = "Flight Master",
    [serviceKeys.INNKEEPER] = "Innkeeper",
}

-- Categories that exist only in flavors whose data has such NPCs.
---@type table<integer, string> Service to category name
local optionalNpcCategories = {
    [serviceKeys.WEAPON_MASTER] = "Weapon Master",
    [serviceKeys.BARBER] = "Barber",
    [serviceKeys.ARCANE_REFORGER] = "Arcane Reforger",
    [serviceKeys.TRANSMOGRIFIER] = "Transmogrifier",
    [serviceKeys.BATTLE_PET_TRAINER] = "Battle Pet Trainer",
}

-- Pet and demon trainers are listed with the class trainers of the class they serve.
---@type table<integer, boolean>
local classTrainerServices = {
    [serviceKeys.CLASS_TRAINER] = true,
    [serviceKeys.PET_TRAINER] = true,
    [serviceKeys.DEMON_TRAINER] = true,
}

-- `trainerClass` holds a client class ID; the per-class lists are keyed by class file name.
---@type table<integer, string>
local classFileById = {
    "WARRIOR", "PALADIN", "HUNTER", "ROGUE", "PRIEST", "DEATHKNIGHT", "SHAMAN", "MAGE", "WARLOCK", "MONK", "DRUID",
}

---@type table<integer, string> Object service to profession station menu key
local stationKeyByService = {
    [serviceKeys.ANVIL] = "Anvil",
    [serviceKeys.FORGE] = "Forge",
    [serviceKeys.ALCHEMY_LAB] = "Alchemy Lab",
    [serviceKeys.MOONWELL] = "Moonwell",
}

local vendorService = QuestieDB.ServiceSet(serviceKeys.VENDOR)

local function _reformatVendors(lst, existingTable)
    local newList = existingTable or {}
    for k in pairs(lst) do
        tinsert(newList, k)
    end
    return newList
end

---Sorts every list of a category table, so results do not depend on ID map iteration order.
---@param categories table<any, number[]>
local function _SortLists(categories)
    for _, ids in pairs(categories) do
        sort(ids)
    end
end

---The profession trainer categories this flavor has, each starting empty.
---@return table<ProfessionEnum, NpcId[]>
local function _NewProfessionTrainers()
    ---@type table<ProfessionEnum, NpcId[]>
    local professionTrainers = {
        [professionKeys.FIRST_AID] = {},
        [professionKeys.BLACKSMITHING] = {},
        [professionKeys.LEATHERWORKING] = {},
        [professionKeys.ALCHEMY] = {},
        [professionKeys.HERBALISM] = {},
        [professionKeys.COOKING] = {},
        [professionKeys.MINING] = {},
        [professionKeys.TAILORING] = {},
        [professionKeys.ENGINEERING] = {},
        [professionKeys.ENCHANTING] = {},
        [professionKeys.FISHING] = {},
        [professionKeys.SKINNING] = {},
        [professionKeys.RIDING] = {}
    }

    if Expansions.Current >= Expansions.Tbc then
        professionTrainers[professionKeys.JEWELCRAFTING] = {}
    end

    if Expansions.Current >= Expansions.Wotlk then
        professionTrainers[professionKeys.INSCRIPTION] = {}
    end

    if Expansions.Current >= Expansions.Cata then
        professionTrainers[professionKeys.ARCHAEOLOGY] = {}
    end

    return professionTrainers
end

function Townsfolk.Initialize()
    local townfolk = {}
    for _, category in pairs(sharedNpcCategories) do
        townfolk[category] = {}
    end
    local stableMasters, spiritHealers, portalTrainers = {}, {}, {}
    local professionTrainers = _NewProfessionTrainers()

    local classSpecificTownsfolk = {}
    for _, classFile in pairs(classFileById) do
        classSpecificTownsfolk[classFile] = {["Class Trainer"] = {}}
    end

    -- One pass over every NPC. Most carry no services, and reading the absent list is cheap.
    local count = 0
    for id in pairs(QuestieDB.NPCPointers) do
        local services = QuestieDB.QueryNPCSingle(id, "services")
        if services then
            local npcName = QuestieDB.QueryNPCSingle(id, "name")
            if npcName and sub(npcName, 1, 5) ~= "[DND]" then
                for i = 1, #services do
                    local service = services[i]
                    local category = sharedNpcCategories[service]
                    if category then
                        tinsert(townfolk[category], id)
                    elseif optionalNpcCategories[service] then
                        category = optionalNpcCategories[service]
                        townfolk[category] = townfolk[category] or {}
                        tinsert(townfolk[category], id)
                    elseif service == serviceKeys.STABLE_MASTER then
                        tinsert(stableMasters, id)
                    elseif service == serviceKeys.SPIRIT_HEALER then
                        tinsert(spiritHealers, id)
                    elseif service == serviceKeys.PORTAL_TRAINER then
                        tinsert(portalTrainers, id)
                    elseif classTrainerServices[service] then
                        local classFile = classFileById[QuestieDB.QueryNPCSingle(id, "trainerClass")]
                        if classFile then
                            tinsert(classSpecificTownsfolk[classFile]["Class Trainer"], id)
                        end
                    end
                end

                local trainerSkills = QuestieDB.QueryNPCSingle(id, "trainerSkills")
                if trainerSkills then
                    for i = 1, #trainerSkills do
                        local trainers = professionTrainers[trainerSkills[i]]
                        if trainers then
                            tinsert(trainers, id)
                        end
                    end
                end
            end
        end
        if count > 700 then -- 700 seems like a good number
            count = 0
            coroutine.yield()
        end
        count = count + 1
    end

    -- Objects: mailboxes, meeting stones and profession stations.
    local allianceMailboxes, hordeMailboxes, meetingStones = {}, {}, {}
    local stationObjects = {}
    for _, key in pairs(stationKeyByService) do
        stationObjects[key] = {}
    end
    count = 0
    for id in pairs(QuestieDB.ObjectPointers) do
        local services = QuestieDB.QueryObjectSingle(id, "services")
        if services then
            for i = 1, #services do
                local service = services[i]
                if service == serviceKeys.MAILBOX then
                    -- A mailbox without a faction restriction serves both factions.
                    local requiredFaction = QuestieDB.QueryObjectSingle(id, "requiredFaction")
                    if requiredFaction ~= "H" then
                        tinsert(allianceMailboxes, id)
                    end
                    if requiredFaction ~= "A" then
                        tinsert(hordeMailboxes, id)
                    end
                elseif service == serviceKeys.MEETING_STONE then
                    tinsert(meetingStones, id)
                elseif stationKeyByService[service] then
                    tinsert(stationObjects[stationKeyByService[service]], id)
                end
            end
        end
        if count > 700 then
            count = 0
            coroutine.yield()
        end
        count = count + 1
    end

    if #meetingStones > 0 then
        townfolk["Meeting Stones"] = meetingStones
    end

    local factionSpecificTownsfolk = {["Horde"] = {}, ["Alliance"] = {}, ["Neutral"] = {}}
    factionSpecificTownsfolk["Horde"]["Spirit Healer"] = spiritHealers
    factionSpecificTownsfolk["Alliance"]["Spirit Healer"] = spiritHealers
    factionSpecificTownsfolk["Horde"]["Mailbox"] = hordeMailboxes
    factionSpecificTownsfolk["Alliance"]["Mailbox"] = allianceMailboxes

    -- From MoP every class can stable pets; before that only hunters have a use for stable masters.
    -- Class lists are filtered later, when the player class does not match.
    if Expansions.Current >= Expansions.MoP then
        townfolk["Stable Master"] = stableMasters
    else
        classSpecificTownsfolk["HUNTER"]["Stable Master"] = stableMasters
    end
    classSpecificTownsfolk["MAGE"]["Portal Trainer"] = portalTrainers

    _SortLists(townfolk)
    _SortLists(professionTrainers)
    _SortLists(stationObjects)
    for _, categories in pairs(classSpecificTownsfolk) do
        _SortLists(categories)
    end
    for _, categories in pairs(factionSpecificTownsfolk) do
        _SortLists(categories)
    end

    ProfessionStations.SetStationObjects(stationObjects)

    local petFoodVendorTypes = {["Meat"] = {},["Fish"]={},["Cheese"]={},["Bread"]={},["Fungus"]={},["Fruit"]={},["Raw Meat"]={},["Raw Fish"]={}}
    local petFoodIndexes = {"Meat","Fish","Cheese","Bread","Fungus","Fruit","Raw Meat","Raw Fish"}

    -- Only hunters get a "Pet Food" vendor list (UpdatePlayerVendors), so other classes skip
    -- this scan over every Item and keep the categories empty.
    if playerClass == "HUNTER" then
        count = 0
        for id in pairs(QuestieDB.ItemPointers) do
            -- Number fields read 0 for Items without a food type; only food types 1-8 name a pet food category.
            local petFoodCategory = petFoodIndexes[QuestieDB.QueryItemSingle(id, "foodType")]
            if petFoodCategory then
                tinsert(petFoodVendorTypes[petFoodCategory], id)
            end
            if count > 300 then -- Yield every 300 iterations, 300 is just a madeup number, is pretty fast.
                count = 0
                coroutine.yield()
            end
            count = count + 1
        end
    end

    coroutine.yield()

    Townsfolk.townsfolk = townfolk
    Townsfolk.professionTrainers = professionTrainers
    Townsfolk.classSpecificTownsfolk = classSpecificTownsfolk
    Townsfolk.factionSpecificTownsfolk = factionSpecificTownsfolk
    Townsfolk.petFoodVendorTypes = petFoodVendorTypes
end

function Townsfolk.PostBoot() -- post DB boot (use queries here)
    local reagents = {
        17031, 17032, 17020, -- MAGE
        17030, -- SHAMAN
        17029, 17028, -- PRIEST
        21177, 17033, -- PALADIN
        37201, -- DEATHKNIGHT
        5565, 16583, -- WARLOCK
        17034, 17026, 17035, 17021, 17038, 17036, 17037, -- DRUID
    }

    if Questie.IsSoD then
        table.insert(reagents, 212160) -- In SoD the Chronoboon Displacer is sold by reagent vendors
    end

    -- populate vendor IDs from db
    if #reagents > 0 then
        Questie.db.char.vendorList["Reagents"] = _reformatVendors(Townsfolk:PopulateVendors(reagents))
    end

    if Expansions.Current < Expansions.MoP then
        -- Beginning with WotLK, all poison vendors sell all ranks of poison, so Rank 1 of one poison is enough here
        local poisons = Expansions.Current >= Expansions.Wotlk and {2892} or {5140,2928,8924,5173,2930,8923}
        Questie.db.char.vendorList["Poisons"] = _reformatVendors(Townsfolk:PopulateVendors(poisons))
    end

    Questie.db.char.vendorList["Trade Goods"] = _reformatVendors(Townsfolk:PopulateVendors({
        14256,12810,13463,8845,8846,4234,3713,8170,14341,4389,3357,2453,13464,
        3355,3356,3358,4371,4304,5060,2319,18256,8925,3857,10940,2321,785,4404,2692,
        2605,3372,2320,6217,2449,4399,4364,10938,18567,4382,4289,765,3466,3371,2447,2880,
        2928,4361,10647,10648,4291,4357,8924,8343,4363,2678,5173,4400,2930,4342,2325,4340,
        6261,8923,2324,2604,6260,4378,10290,17194,4341,
        22012,21992,21993,16084,16112,16113,16085,19442,6454,8547,23689, -- First Aid skill books
        27532,16082,16083, -- Fishing skill books
        27736,16072,16073, -- Cooking skill books
    }))
    Questie.db.char.vendorList["Bags"] = _reformatVendors(Townsfolk:PopulateVendors({4496, 4497, 4498, 4499, (Expansions.Current >= Expansions.Tbc) and 30744 or nil}))
    Questie.db.char.vendorList["Potions"] = _reformatVendors(Townsfolk:PopulateVendors({
        118, 858, 929, 1710, 3928, 13446, 18839, (Expansions.Current >= Expansions.Tbc) and 22829 or nil, (Expansions.Current >= Expansions.Tbc) and 32947 or nil, (Expansions.Current >= Expansions.Wotlk) and 33447 or nil, (Expansions.Current >= Expansions.Cata) and 57191 or nil, -- Healing Potions
        2455, 3385, 3827, 6149, 13443, 13444, 18841, (Expansions.Current >= Expansions.Tbc) and 22832 or nil, (Expansions.Current >= Expansions.Tbc) and 32948 or nil, (Expansions.Current >= Expansions.Wotlk) and 33448 or nil, (Expansions.Current >= Expansions.Cata) and 57192 or nil, -- Mana Potions
    }))
    Townsfolk:UpdatePlayerVendors()
end

function Townsfolk:BuildCharacterTownsfolk()
    Questie.db.char.townsfolk = {}
    Questie.db.char.vendorList = {}
    Questie.db.char.townsfolkClass = UnitClassBase("player")

    for key, npcs in pairs(Townsfolk.factionSpecificTownsfolk[playerFaction]) do
        Questie.db.char.townsfolk[key] = npcs
    end

    for key, npcs in pairs(Townsfolk.classSpecificTownsfolk[playerClass]) do
        Questie.db.char.townsfolk[key] = npcs
    end
end

local function _UpdatePetFood() -- call on change pet
    Questie.db.char.vendorList["Pet Food"] = {}
    -- detect petfood vendors for player's pet
    for _, key in pairs({QuestieCompat.GetStablePetFoodTypes(0)}) do
        if Townsfolk.petFoodVendorTypes[key] then
            Townsfolk:PopulateVendors(Townsfolk.petFoodVendorTypes[key], Questie.db.char.vendorList["Pet Food"], true)
        end
    end
    Questie.db.char.vendorList["Pet Food"] = _reformatVendors(Questie.db.char.vendorList["Pet Food"])
end

local function _UpdateAmmoVendors() -- call on change weapon
    if Expansions.Current >= Expansions.Cata then
        return
    end

    Questie.db.char.vendorList["Ammo"] = _reformatVendors(Townsfolk:PopulateVendors({11285,3030,19316,2515,2512,11284,19317,2519,2516,3033,28056,28053,28061,28060}, {}, true))
end

local function _UpdateFoodDrink()
    local drink = {159,8766,1179,1708,1645,1205,17404,19300,19299,27860,28399,29395,29454,33042,32453,32455} -- water item ids -- TO DO: update this?
    local food = { -- food item ids (from wowhead) -- TO DO: update this?
        8932,4536,8952,19301,13724,8953,3927,11109,8957,4608,4599,4593,4592,117,3770,3771,4539,8950,8948,7228,
        2287,4601,422,16166,4537,4602,4542,4594,1707,4540,414,4538,4607,17119,19225,2070,21552,787,4544,18632,16167,4606,16170,
        4541,4605,17408,17406,11444,21033,22324,18635,21030,17407,19305,18633,4604,21031,16168,19306,16169,19304,17344,19224,19223,
        27857,27854,20857,27858,27856,29448,27855,29451,30355,28486,29450,29393,29394,29449,29452
    }

    Questie.db.char.vendorList["Food"] = _reformatVendors(Townsfolk:PopulateVendors(food, {}, true))
    Questie.db.char.vendorList["Drink"] = _reformatVendors(Townsfolk:PopulateVendors(drink, {}, true))
end

function Townsfolk:UpdatePlayerVendors() -- call on levelup
    _UpdateFoodDrink()
    _UpdateAmmoVendors()

    if playerClass == "HUNTER" then
        _UpdatePetFood()
    end
end

function Townsfolk:PopulateVendors(itemList, existingTable, restrictLevel)
    local factionKey = playerFaction == "Alliance" and "A" or "H"
    local tbl = existingTable or {}
    -- Create a cache to minimize db calls
    local factionCache = {}

    local playerLevel = restrictLevel and UnitLevel("Player") or 0
    for _, id in pairs(itemList) do
        --print(id)
        local valid = true
        if restrictLevel then
            local requiredLevel = QuestieDB.QueryItemSingle(id, "requiredLevel")
            valid = (not requiredLevel) or (requiredLevel and requiredLevel <= playerLevel and requiredLevel >= playerLevel - 20)
        end
        if valid then
            local vendors = QuestieDB.QueryItemSingle(id, "vendors")
            if vendors then
                for i=1, #vendors do
                    local vendorId = vendors[i]
                    --print(vendorId)
                    local friendlyToFaction = factionCache[vendorId] or QuestieDB.QueryNPCSingle(vendorId, "friendlyToFaction")
                    if not factionCache[vendorId] then
                        factionCache[vendorId] = friendlyToFaction
                    end
                    if (not friendlyToFaction) or friendlyToFaction == "AH" or friendlyToFaction == factionKey then
                        if QuestieDB.NpcHasServices(vendorId, vendorService) then
                            tbl[vendorId] = true
                        end
                    end
                end
            end
        end
    end
    return tbl
end
