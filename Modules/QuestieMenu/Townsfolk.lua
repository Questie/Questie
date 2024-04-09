---@class Townsfolk
local Townsfolk = QuestieLoader:CreateModule("Townsfolk")

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestieProfessions
local QuestieProfessions = QuestieLoader:ImportModule("QuestieProfessions")

local _, playerClass = UnitClass("player")
local playerFaction = UnitFactionGroup("player")

local tinsert = tinsert
local sub, bitband, strlen = string.sub, bit.band, string.len

local professionKeys = QuestieProfessions.professionKeys


local function _reformatVendors(lst, existingTable)
    local newList = existingTable or {}
    for k in pairs(lst) do
        tinsert(newList, k)
    end
    return newList
end

---Uses a table to fetch multiple townfolk types at the same time.
---@param folkTypes table<string, {mask: NpcFlags|integer, requireSubname: boolean, data: NpcId[]}>
local function _PopulateTownsfolkTypes(folkTypes) -- populate the table with all npc ids based on the given bitmask
    local count = 0
    for id, npcData in pairs(QuestieDB.npcData) do
        local flags = npcData[QuestieDB.npcKeys.npcFlags]
        for name, folkType in pairs(folkTypes) do
            if flags and bitband(flags, folkType.mask) == folkType.mask then
                local npcName = npcData[QuestieDB.npcKeys.name]
                local subName = npcData[QuestieDB.npcKeys.subName]
                if npcName and sub(npcName, 1, 5) ~= "[DND]" then
                    if (not folkType.requireSubname) or (subName and strlen(subName) > 1) then
                        folkType.data[#folkType.data+1] = id
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
    return folkTypes
end


function Townsfolk.Initialize()

    --? This datastructure is used in PopulateTownsfolkTypes to fetch multiple townfolk data in the same npc loop cycle
    ---@type table<string, {mask: NpcFlags|integer, requireSubname: boolean, data: NpcId[]}>
    local townsfolkData = {
        ["Repair"] = {
            mask = QuestieDB.npcFlags.REPAIR,
            requireSubname = true,
            data = {}
        },
        ["Auctioneer"] = {
            mask = QuestieDB.npcFlags.AUCTIONEER,
            requireSubname = false,
            data = {}
        },
        ["Banker"] = {
            mask = QuestieDB.npcFlags.BANKER,
            requireSubname = true,
            data = {}
        },
        ["Battlemaster"] = {
            mask = QuestieDB.npcFlags.BATTLEMASTER,
            requireSubname = true,
            data = {}
        },
        ["Flight Master"] = {
            mask = QuestieDB.npcFlags.FLIGHT_MASTER,
            requireSubname = false,
            data = {}
        },
        ["Innkeeper"] = {
            mask = QuestieDB.npcFlags.INNKEEPER,
            requireSubname = true,
            data = {}
        },
        ["Stable Master"] = { -- Used further down by hunters.
            mask = QuestieDB.npcFlags.STABLEMASTER,
            requireSubname = false,
            data = {}
        },
        ["Spirit Healer"] = {-- Used further down
            mask = QuestieDB.npcFlags.SPIRIT_HEALER,
            requireSubname = false,
            data = {}
        }
    }
    _PopulateTownsfolkTypes(townsfolkData)

    local townfolk = {
        ["Repair"] = townsfolkData["Repair"].data,
        ["Auctioneer"] = townsfolkData["Auctioneer"].data,
        ["Banker"] = townsfolkData["Banker"].data,
        ["Battlemaster"] = townsfolkData["Battlemaster"].data,
        ["Flight Master"] = townsfolkData["Flight Master"].data,
        ["Innkeeper"] = townsfolkData["Innkeeper"].data,
        ["Weapon Master"] = {}, -- populated below
    }

    ---@type table<ProfessionEnum, NpcId[]>
    local professionTrainers = {
        [professionKeys.FIRST_AID] = {},
        [professionKeys.BLACKSMITHING] = {},
        [professionKeys.LEATHERWORKING] = {},
        [professionKeys.ALCHEMY] = {},
        [professionKeys.HERBALISM] = {},
        [professionKeys.COOKING] = {
            19186, -- Kylene <Barmaid> (this is an edge case)
        },
        [professionKeys.MINING] = {},
        [professionKeys.TAILORING] = {},
        [professionKeys.ENGINEERING] = {},
        [professionKeys.ENCHANTING] = {},
        [professionKeys.FISHING] = {},
        [professionKeys.SKINNING] = {}
    }

    if Questie.IsTBC or Questie.IsWotlk then
        professionTrainers[professionKeys.JEWELCRAFTING] = {}
    end

    if Questie.IsWotlk then
        professionTrainers[professionKeys.INSCRIPTION] = {}
    end

    local count = 0
    local validProfessionTrainers = Townsfolk.GetProfessionTrainers()
    for i=1, #validProfessionTrainers do
        local id = validProfessionTrainers[i]
        if QuestieDB.npcData[id] then
            local subName = QuestieDB.npcData[id][QuestieDB.npcKeys.subName]
            if subName then
                if townfolk[subName] then -- weapon master,
                    tinsert(townfolk[subName], id)
                else
                    for k, professionId in pairs(QuestieProfessions.professionTable) do
                        if string.match(subName, k) then
                            tinsert(professionTrainers[professionId], id)
                        end
                    end
                end
            end
        end

        if count > 10 then -- Yield every 10 iterations, 10 is just a madeup number, is pretty fast.
            count = 0
            coroutine.yield()
        end
        count = count + 1
    end

    -- Fix NPC Gubber Blump (10216) can train fishing profession
    tinsert(professionTrainers[professionKeys.FISHING], 10216)
    -- Fix NPC Aresella (18991) can train first aid profession
    if Questie.IsTBC or Questie.IsWotlk then
        tinsert(professionTrainers[professionKeys.FIRST_AID], 18991)
    end

    if Questie.IsClassic then
        -- Vendors selling "Expert First Aid - Under Wraps"
        tinsert(professionTrainers[professionKeys.FIRST_AID], 2805)
        tinsert(professionTrainers[professionKeys.FIRST_AID], 13476)
    end

    if Questie.IsWotlk or Questie.IsTBC then
        local meetingStones = Townsfolk.GetMeetingStones()

        townfolk["Meeting Stones"] = {}
        for _, id in pairs(meetingStones) do
            tinsert(townfolk["Meeting Stones"], id)
        end
    end

    -- todo: specialized trainer types (leatherworkers, engineers, etc)

    local classSpecificTownsfolk = {}
    local factionSpecificTownsfolk = {["Horde"] = {}, ["Alliance"] = {}}

    local classTrainers = Townsfolk.GetClassTrainers()
    for class, trainers in pairs(classTrainers) do
        local newTrainers = {}
        for _, trainer in pairs(trainers) do
            if QuestieDB.npcData[trainer] then
                local subName = QuestieDB.npcData[trainer][QuestieDB.npcKeys.subName]
                if subName and string.len(subName) > 0 then
                    tinsert(newTrainers, trainer)
                end
            end
        end
        classSpecificTownsfolk[class] = {}
        classSpecificTownsfolk[class]["Class Trainer"] = newTrainers
    end

    -- These are filtered later, when the player class does not match
    classSpecificTownsfolk["HUNTER"]["Stable Master"] = townsfolkData["Stable Master"].data
    classSpecificTownsfolk["MAGE"]["Portal Trainer"] = {4165,2485,2489,5958,5957,2492,16654,16755,19340,20791,27703,27705}

    factionSpecificTownsfolk["Horde"]["Spirit Healer"]  = townsfolkData["Spirit Healer"].data
    factionSpecificTownsfolk["Alliance"]["Spirit Healer"]  = townsfolkData["Spirit Healer"].data

    factionSpecificTownsfolk["Horde"]["Mailbox"] = {}
    factionSpecificTownsfolk["Alliance"]["Mailbox"] = {}

    local mailboxes = Townsfolk.GetMailboxes()
    for i=1, #mailboxes do
        local id = mailboxes[i]
        if QuestieDB.objectData[id] then
            local factionID = QuestieDB.objectData[id][QuestieDB.objectKeys.factionID]

            if factionID == 0 then
                tinsert(factionSpecificTownsfolk["Horde"]["Mailbox"], id)
                tinsert(factionSpecificTownsfolk["Alliance"]["Mailbox"], id)
            elseif QuestieDB.factionTemplate[factionID] and bitband(QuestieDB.factionTemplate[factionID], 12) == 0 and bitband(QuestieDB.factionTemplate[factionID], 10) == 0 then
                tinsert(factionSpecificTownsfolk["Horde"]["Mailbox"], id)
                tinsert(factionSpecificTownsfolk["Alliance"]["Mailbox"], id)
            elseif QuestieDB.factionTemplate[factionID] and bitband(QuestieDB.factionTemplate[factionID], 12) == 0 then
                tinsert(factionSpecificTownsfolk["Horde"]["Mailbox"], id)
            elseif QuestieDB.factionTemplate[factionID] and bitband(QuestieDB.factionTemplate[factionID], 10) == 0 then
                tinsert(factionSpecificTownsfolk["Alliance"]["Mailbox"], id)
            else
                tinsert(factionSpecificTownsfolk["Horde"]["Mailbox"], id)
                tinsert(factionSpecificTownsfolk["Alliance"]["Mailbox"], id)
            end
        else
            Questie:Debug(Questie.DEBUG_DEVELOP, "Missing mailbox:", tostring(id))
        end
    end

    local petFoodVendorTypes = {["Meat"] = {},["Fish"]={},["Cheese"]={},["Bread"]={},["Fungus"]={},["Fruit"]={},["Raw Meat"]={},["Raw Fish"]={}}
    local petFoodIndexes = {"Meat","Fish","Cheese","Bread","Fungus","Fruit","Raw Meat","Raw Fish"}

    count = 0
    for id, data in pairs(QuestieDB.itemData) do
        local foodType = data[QuestieDB.itemKeys.foodType]
        if foodType then
            tinsert(petFoodVendorTypes[petFoodIndexes[foodType]], id)
        end
        if count > 300 then -- Yield every 300 iterations, 300 is just a madeup number, is pretty fast.
            count = 0
            coroutine.yield()
        end
        count = count + 1
    end

    coroutine.yield()

    --- Set the globals
    Questie.db.global.townsfolk = townfolk
    Questie.db.global.townsfolkNeedsUpdatedGlobalVendors = true

    Questie.db.global.professionTrainers = professionTrainers
    Questie.db.global.classSpecificTownsfolk = classSpecificTownsfolk
    Questie.db.global.factionSpecificTownsfolk = factionSpecificTownsfolk
    Questie.db.global.petFoodVendorTypes = petFoodVendorTypes
end

function Townsfolk.PostBoot() -- post DB boot (use queries here)

    if Questie.db.global.townsfolkNeedsUpdatedGlobalVendors then
        Questie.db.global.townsfolkNeedsUpdatedGlobalVendors = nil
        -- insert item-based profession vendors
        _reformatVendors(Townsfolk:PopulateVendors({22012, 21992, 21993, 16084, 16112, 16113, 16085, 19442, 6454, 8547, 23689}), Questie.db.global.professionTrainers[professionKeys.FIRST_AID])
        _reformatVendors(Townsfolk:PopulateVendors({27532, 16082, 16083}), Questie.db.global.professionTrainers[professionKeys.FISHING])
        _reformatVendors(Townsfolk:PopulateVendors({27736, 16072, 16073}), Questie.db.global.professionTrainers[professionKeys.COOKING])
    end

    -- item ids for class-specific reagents
    local reagents = {
        ["MAGE"] = {17031, 17032, 17020},
        ["SHAMAN"] = {17030},
        ["PRIEST"] = {17029,17028},
        ["PALADIN"] = {21177,17033},
        ["WARRIOR"] = {},
        ["HUNTER"] = {},
        ["DEATHKNIGHT"] = {37201},
        ["WARLOCK"] = {5565,16583},
        ["ROGUE"] = Questie.IsWotlk and {2892} -- All poison vendors sell all ranks of poison, so Rank 1 of one poison is enough here
            or {5140,2928,8924,5173,2930,8923},
        ["DRUID"] = {17034,17026,17035,17021,17038,17036,17037}
    }
    reagents = reagents[playerClass]
    if Questie.IsSoD then
        table.insert(reagents, 212160) -- In SoD the Chronoboon Displacer is sold by reagent vendors
    end

    -- populate vendor IDs from db
    if #reagents > 0 then
        Questie.db.char.vendorList["Reagents"] = _reformatVendors(Townsfolk:PopulateVendors(reagents))
    end
    Questie.db.char.vendorList["Trade Goods"] = _reformatVendors(Townsfolk:PopulateVendors({ -- item ids from wowhead for trade goods   (temporarily disabled)
        14256,12810,13463,8845,8846,4234,3713,8170,14341,4389,3357,2453,13464,
        3355,3356,3358,4371,4304,5060,2319,18256,8925,3857,10940,2321,785,4404,2692,
        2605,3372,2320,6217,2449,4399,4364,10938,18567,4382,4289,765,3466,3371,2447,2880,
        2928,4361,10647,10648,4291,4357,8924,8343,4363,2678,5173,4400,2930,4342,2325,4340,
        6261,8923,2324,2604,6260,4378,10290,17194,4341
    }))
    Questie.db.char.vendorList["Bags"] = _reformatVendors(Townsfolk:PopulateVendors({4496, 4497, 4498, 4499, (Questie.IsTBC or Questie.IsWotlk) and 30744 or nil}))
    Questie.db.char.vendorList["Potions"] = _reformatVendors(Townsfolk:PopulateVendors({
        118, 858, 929, 1710, 3928, 13446, 18839, (Questie.IsTBC or Questie.IsWotlk) and 22829 or nil, (Questie.IsTBC or Questie.IsWotlk) and 32947 or nil, (Questie.IsWotlk) and 33447 or nil, -- Healing Potions
        2455, 3385, 3827, 6149, 13443, 13444, 18841, (Questie.IsTBC or Questie.IsWotlk) and 22832 or nil, (Questie.IsTBC or Questie.IsWotlk) and 32948 or nil, (Questie.IsWotlk) and 33448 or nil, -- Mana Potions
    }))
    Townsfolk:UpdatePlayerVendors()
end

function Townsfolk:BuildCharacterTownsfolk()
    Questie.db.char.townsfolk = {}
    Questie.db.char.vendorList = {}
    Questie.db.char.townsfolkClass = UnitClass("player")

    for key, npcs in pairs(Questie.db.global.factionSpecificTownsfolk[playerFaction]) do
        Questie.db.char.townsfolk[key] = npcs
    end

    for key, npcs in pairs(Questie.db.global.classSpecificTownsfolk[playerClass]) do
        Questie.db.char.townsfolk[key] = npcs
    end
end

local function _UpdatePetFood() -- call on change pet
    Questie.db.char.vendorList["Pet Food"] = {}
    -- detect petfood vendors for player's pet
    for _, key in pairs({GetStablePetFoodTypes(0)}) do
        if Questie.db.global.petFoodVendorTypes[key] then
            Townsfolk:PopulateVendors(Questie.db.global.petFoodVendorTypes[key], Questie.db.char.vendorList["Pet Food"], true)
        end
    end
    Questie.db.char.vendorList["Pet Food"] = _reformatVendors(Questie.db.char.vendorList["Pet Food"])
end

local function _UpdateAmmoVendors() -- call on change weapon
    Questie.db.char.vendorList["Ammo"] = _reformatVendors(Townsfolk:PopulateVendors({11285,3030,19316,2515,2512,11284,19317,2519,2516,3033,28056,28053,28061,28060}, {}, true))
end

local function _UpdateFoodDrink()
    local drink = {159,8766,1179,1708,1645,1205,17404,19300,19299,27860,28399,29395,29454,33042,32453,32455} -- water item ids
    local food = { -- food item ids (from wowhead)
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
    if playerClass == "HUNTER" then
        _UpdatePetFood()
        _UpdateAmmoVendors()
    elseif playerClass == "ROGUE" or playerClass == "WARRIOR" then
        _UpdateAmmoVendors()
    end
end

function Townsfolk:PopulateVendors(itemList, existingTable, restrictLevel)
    local factionKey = playerFaction == "Alliance" and "A" or "H"
    local tbl = existingTable or {}
    -- Create a cache to minimize db calls
    local factionCache = {}
    local flagCache = {}

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
                        local flags = flagCache[vendorId] or QuestieDB.QueryNPCSingle(vendorId, "npcFlags")
                        if not flagCache[vendorId] then
                            flagCache[vendorId] = flags
                        end
                        if bitband(flags, QuestieDB.npcFlags.VENDOR) == QuestieDB.npcFlags.VENDOR then
                            tbl[vendorId] = true
                        end
                    end
                end
            end
        end
    end
    return tbl
end
