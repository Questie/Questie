---@class QuestieCorrections
local QuestieCorrections = QuestieLoader:CreateModule("QuestieCorrections")
-------------------------
--Import modules.
-------------------------
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestieEvent
local QuestieEvent = QuestieLoader:ImportModule("QuestieEvent")
---@type QuestieQuestFixes
local QuestieQuestFixes = QuestieLoader:ImportModule("QuestieQuestFixes")
---@type QuestieQuestBlacklist
local QuestieQuestBlacklist = QuestieLoader:ImportModule("QuestieQuestBlacklist")
---@type QuestieNPCBlacklist
local QuestieNPCBlacklist = QuestieLoader:ImportModule("QuestieNPCBlacklist")
---@type QuestieItemFixes
local QuestieItemFixes = QuestieLoader:ImportModule("QuestieItemFixes")
---@type QuestieItemBlacklist
local QuestieItemBlacklist = QuestieLoader:ImportModule("QuestieItemBlacklist")
---@type QuestieNPCFixes
local QuestieNPCFixes = QuestieLoader:ImportModule("QuestieNPCFixes")
---@type QuestieObjectFixes
local QuestieObjectFixes = QuestieLoader:ImportModule("QuestieObjectFixes")
---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule("ZoneDB")
---@type QuestieProfessions
local QuestieProfessions = QuestieLoader:ImportModule("QuestieProfessions")

--[[
    This file load the corrections of the database files.

    It is a separate file so we can upstream those changes easier to cmangos and can still
    update the database files with a script.

    Most of the corrections can be done by accessing a specific key instead of copying the
    whole object over and change it.
    You can find the keys at the beginning of each file (e.g. 'questKeys' are at the beginning of 'questDB.lua').

    Further information on how to use this can be found at the wiki
    https://github.com/AeroScripts/QuestieDev/wiki/Corrections
--]]

function QuestieCorrections:MinimalInit() -- db already compiled
    for id, data in pairs(QuestieItemFixes:LoadFactionFixes()) do
        for key, value in pairs(data) do
            if not QuestieDB.itemDataOverrides[id] then
                QuestieDB.itemDataOverrides[id] = {}
            end
            QuestieDB.itemDataOverrides[id][key] = value
        end
    end

    for id, data in pairs(QuestieNPCFixes:LoadFactionFixes()) do
        for key, value in pairs(data) do
            if not QuestieDB.npcDataOverrides[id] then
                QuestieDB.npcDataOverrides[id] = {}
            end
            QuestieDB.npcDataOverrides[id][key] = value
        end
    end

    for id, data in pairs(QuestieObjectFixes:LoadFactionFixes()) do
        for key, value in pairs(data) do
            if not QuestieDB.objectDataOverrides[id] then
                QuestieDB.objectDataOverrides[id] = {}
            end
            QuestieDB.objectDataOverrides[id][key] = value
        end
    end

    for id, data in pairs(QuestieQuestFixes:LoadFactionFixes()) do
        for key, value in pairs(data) do
			if not QuestieDB.questDataOverrides[id] then
                QuestieDB.questDataOverrides[id] = {}
            end
            QuestieDB.questDataOverrides[id][key] = value
        end
    end

    QuestieCorrections.questItemBlacklist = QuestieItemBlacklist:Load()
    QuestieCorrections.questNPCBlacklist = QuestieNPCBlacklist:Load()
    QuestieCorrections.hiddenQuests = QuestieQuestBlacklist:Load()

    if Questie.db.char.showEventQuests then
        C_Timer.After(1, function()
             -- This is done with a delay because on startup the Blizzard API seems to be
             -- very slow and therefore the date calculation in QuestieEvents isn't done
             -- correctly.
            QuestieEvent:Load()
        end)
    end

end

function QuestieCorrections:Initialize() -- db needs to be compiled

    QuestieCorrections:PruneWaypoints()

    for id, data in pairs(QuestieItemFixes:Load()) do
        for key, value in pairs(data) do
            if not QuestieDB.itemData[id] then
                QuestieDB.itemData[id] = {}
            end
            QuestieDB.itemData[id][key] = value
        end
    end

    for id, data in pairs(QuestieNPCFixes:Load()) do
        for key, value in pairs(data) do
            if not QuestieDB.npcData[id] then
                QuestieDB.npcData[id] = {}
            end
            if key == QuestieDB.npcKeys.npcFlags and QuestieDB.npcData[id][key] and type(value) == "table" then -- modify existing flags
                QuestieDB.npcData[id][key] = QuestieDB.npcData[id][key] + value[1]
            else
                QuestieDB.npcData[id][key] = value
            end
        end
    end

    for id, data in pairs(QuestieObjectFixes:Load()) do
        for key, value in pairs(data) do
            QuestieDB.objectData[id][key] = value
        end
    end

    for id, data in pairs(QuestieQuestFixes:Load()) do
        for key, value in pairs(data) do
            if QuestieDB.questData[id] then
                if key == QuestieDB.questKeys.questFlags and QuestieDB.questData[id][key] and type(value) == "table" then -- modify existing flags
                    QuestieDB.questData[id][key] = QuestieDB.questData[id][key] + value[1]
                else
                    QuestieDB.questData[id][key] = value
                end
            end
        end
    end

    QuestieCorrections:MinimalInit()

end

local WAYPOINT_MIN_DISTANCE = 1.5 -- todo: make this a config value maybe?
local ZONE_SCALES = {
    [ZoneDB.zoneIDs.STORMWIND_CITY] = 0.5,
    [ZoneDB.zoneIDs.IRONFORGE] = 0.5,
    [ZoneDB.zoneIDs.TELDRASSIL] = 0.5,

    [ZoneDB.zoneIDs.ORGRIMMAR] = 0.5,
    [ZoneDB.zoneIDs.THUNDER_BLUFF] = 0.5,
    [ZoneDB.zoneIDs.UNDERCITY] = 0.5,
}

local function euclid(x, y, i, e)
    local xd = math.abs(x - i)
    local yd = math.abs(y - e)
    return math.sqrt(xd * xd + yd * yd)
end

local _validMultispawnWaypoints = { -- SELECT entry, Name FROM creature_template WHERE entry IN (SELECT id FROM pool_creature_template WHERE pool_entry IN (SELECT entry FROM pool_template WHERE max_limit=1))
    [61]=1,[79]=1,[99]=1,[100]=1,[462]=1,[471]=1,[472]=1,[503]=1,[506]=1,[507]=1,[519]=1,[520]=1,[521]=1,[534]=1,[572]=1,[573]=1,[574]=1,[584]=1,[616]=1,
    [763]=1,[771]=1,[947]=1,[1037]=1,[1063]=1,[1106]=1,[1112]=1,[1119]=1,[1130]=1,[1132]=1,[1137]=1,[1140]=1,[1260]=1,[1398]=1,[1399]=1,[1424]=1,[1425]=1,
    [1533]=1,[1552]=1,[1837]=1,[1838]=1,[1839]=1,[1841]=1,[1843]=1,[1844]=1,[1847]=1,[1848]=1,[1850]=1,[1851]=1,[1885]=1,[1910]=1,[1911]=1,[1920]=1,[1936]=1,
    [1944]=1,[1948]=1,[2090]=1,[2108]=1,[2258]=1,[2283]=1,[2447]=1,[2452]=1,[2453]=1,[2476]=1,[2541]=1,[2598]=1,[2600]=1,[2601]=1,[2602]=1,[2603]=1,[2604]=1,
    [2605]=1,[2606]=1,[2609]=1,[2744]=1,[2749]=1,[2751]=1,[2752]=1,[2753]=1,[2754]=1,[2773]=1,[2779]=1,[2850]=1,[2931]=1,[3581]=1,[5400]=1,[6652]=1,[7846]=1,
    [8210]=1,[8211]=1,[8212]=1,[8213]=1,[8214]=1,[8215]=1,[8216]=1,[8217]=1,[8218]=1,[8219]=1,[8277]=1,[8278]=1,[8279]=1,[8280]=1,[8281]=1,[8282]=1,[8283]=1,
    [8296]=1,[8297]=1,[8298]=1,[8299]=1,[8300]=1,[8301]=1,[8302]=1,[8303]=1,[8304]=1,[8503]=1,[8976]=1,[8978]=1,[8979]=1,[8981]=1,[9602]=1,[9604]=1,[10077]=1,
    [10078]=1,[10119]=1,[10356]=1,[10357]=1,[10358]=1,[10359]=1,[10559]=1,[10647]=1,[10817]=1,[10821]=1,[10822]=1,[10823]=1,[10824]=1,[10825]=1,[10826]=1,
    [10827]=1,[10828]=1,[11383]=1,[12431]=1,[12432]=1,[12433]=1,[13602]=1,[14221]=1,[14222]=1,[14223]=1,[14224]=1,[14237]=1,[14266]=1,[14267]=1,[14268]=1,
    [14269]=1,[14270]=1,[14271]=1,[14272]=1,[14273]=1,[14275]=1,[14276]=1,[14277]=1,[14278]=1,[14279]=1,[14280]=1,[14281]=1,[14344]=1,[14424]=1,[14425]=1,
    [14433]=1,[14445]=1,[14446]=1,[14447]=1,[14448]=1,[14487]=1,[14488]=1,[14490]=1,[14492]=1,[16184]=1,[2186]=1,[10196]=1,[14479]=1,[7017]=1,[14339]=1,
    [3056]=1,[5823]=1,[815]=1,[2038]=1,[3735]=1,[7319]=1,

    -- manually added
    [3476]=1,--isha awak
    [391]=1,--old murk-eye
    [2714]=1,--forsaken courier
    [10182]=1,--rexxar
}

function QuestieCorrections:PruneWaypoints()
    --Questie.db.char.pruned = ""
    for id,data in pairs(QuestieDB.npcData) do
        local spawnCount = 0
        if data[QuestieDB.npcKeys.waypoints] then
            for zone, ways in pairs(data[QuestieDB.npcKeys.waypoints]) do
                for _ in pairs(ways) do
                    spawnCount = spawnCount + 1
                end
            end
        end
        if spawnCount > 1 and not _validMultispawnWaypoints[id] and bit.band(data[QuestieDB.npcKeys.npcFlags], QuestieDB.npcFlags.QUEST_GIVER) ~= QuestieDB.npcFlags.QUEST_GIVER then -- we dont want waypoints for this mob, it can have more than 1 spawn at a time
            data[QuestieDB.npcKeys.waypoints] = nil
            --Questie.db.char.pruned = Questie.db.char.pruned .. "\\n" .. tostring(id) .. " " .. data[QuestieDB.npcKeys.name]
        end
    end
end

function QuestieCorrections:OptimizeWaypoints(waypoints)
    local newWaypointZones = {}
    for zone, waypointList in pairs(waypoints) do
        local newWaypointList = {}
        if waypointList[1] and type(waypointList[1][1]) == "number" then
            waypointList = {waypointList} -- corrections support both {{x,y}, ...} and {{{x,y}, ...}, {{x,y}, ...}, ...}
        end
        for _, waypoints in pairs(waypointList) do
            -- apply RDP algorithm
            local minDist = WAYPOINT_MIN_DISTANCE * (ZONE_SCALES[zone] or 1)
            local newWaypoints = QuestieCorrections:RamerDouglasPeucker(waypoints, 0.1, true)

            waypoints = newWaypoints
            newWaypoints = {}

            -- subdivide waypoints where needed
            -- We do this because the clickable area of waypoint lines can only be a square, so lines need to be broken up in some places
            local lastWay = nil
            for _, way in pairs(waypoints) do
                if lastWay then
                    local dist = euclid(way[1], way[2], lastWay[1], lastWay[2])
                    if dist > minDist then
                        local divs = math.ceil(dist/minDist)
                        for i=1,divs do
                            local mul0 = i/divs
                            local mul1 = 1-mul0
                            tinsert(newWaypoints, {way[1] * mul0 + lastWay[1] * mul1, way[2] * mul0 + lastWay[2] * mul1})
                        end
                    else
                        tinsert(newWaypoints, way)
                    end
                else
                    tinsert(newWaypoints, way)
                end
                
                lastWay = way
            end
            tinsert(newWaypointList, newWaypoints)
        end
        newWaypointZones[zone] = newWaypointList
    
    end
    return newWaypointZones
end

function _reformatVendors(lst)
    local newList = {}
    for k in pairs(lst) do
        tinsert(newList, k)
    end
    return newList
end


function QuestieCorrections:UpdatePetFood() -- call on change pet
    Questie.db.char.vendorList["Pet Food"] = {}
    -- detect petfood vendors for player's pet
    for _, key in pairs({GetStablePetFoodTypes(0)}) do
        if Questie.db.global.petFoodVendorTypes[key] then
            QuestieCorrections:PopulateVendors(Questie.db.global.petFoodVendorTypes[key], Questie.db.char.vendorList["Pet Food"], true)
        end
    end
    Questie.db.char.vendorList["Pet Food"] = _reformatVendors(Questie.db.char.vendorList["Pet Food"])
end

function QuestieCorrections:UpdateAmmoVendors() -- call on change weapon
    Questie.db.char.vendorList["Ammo"] = {}

    -- get current weapon ammo type
    local weaponID = GetInventoryItemID("player", 18)
    if weaponID then
        local class, subClass = unpack(QuestieDB.QueryItem(weaponID, "class", "subClass"))
        local isBow = (2 == class and (2 == subClass or 18 == subClass))
        if isBow then
            Questie.db.char.vendorList["Ammo"] = _reformatVendors(QuestieCorrections:PopulateVendors({11285,3030,19316,2515,2512}, {}, true))
        else
            Questie.db.char.vendorList["Ammo"] = _reformatVendors(QuestieCorrections:PopulateVendors({11284,19317,2519,2516,3033}, {}, true))
        end
    end
end

function QuestieCorrections:UpdateFoodDrink()
    local drink = {159,8766,1179,1708,1645,1205,17404,19300,19299} -- water item ids
    local food = { -- food item ids (from wowhead)
        8932,4536,8952,19301,13724,8953,3927,11109,8957,4608,4599,4593,4592,117,3770,3771,4539,8950,8948,7228,
        2287,4601,422,16166,4537,4602,4542,4594,1707,4540,414,4538,4607,17119,19225,2070,21552,787,4544,18632,16167,4606,16170,
        4541,4605,17408,17406,11444,21033,22324,18635,21030,17407,19305,18633,4604,21031,16168,19306,16169,19304,17344,19224,19223
    }

    Questie.db.char.vendorList["Food"] = _reformatVendors(QuestieCorrections:PopulateVendors(food, {}, true))
    Questie.db.char.vendorList["Drink"] = _reformatVendors(QuestieCorrections:PopulateVendors(drink, {}, true))
end

function QuestieCorrections:UpdatePlayerVendors() -- call on levelup
    QuestieCorrections:UpdateFoodDrink()
    local _, class = UnitClass("player")
    if class == "HUNTER" then
        QuestieCorrections:UpdatePetFood()
        QuestieCorrections:UpdateAmmoVendors()
    elseif class == "ROGUE" or class == "WARRIOR" then
        QuestieCorrections:UpdateAmmoVendors()
    end

end

function QuestieCorrections:PopulateTownsfolkType(mask) -- populate the table with all npc ids based on the given bitmask
    local tbl = {}
    for id, data in pairs(QuestieDB.npcData) do
        flags = data[QuestieDB.npcKeys.npcFlags]
        if flags and bit.band(flags, mask) == mask then
            tinsert(tbl, id)
        end
    end
    return tbl
end

function QuestieCorrections:PopulateVendors(itemList, existingTable, restrictLevel)
    local factionKey = UnitFactionGroup("Player") == "Alliance" and "A" or "H"
    local tbl = existingTable or {}
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
                for _, vendorId in pairs(vendors) do
                    --print(vendorId)
                    local friendlyToFaction = QuestieDB.QueryNPCSingle(vendorId, "friendlyToFaction")
                    if (not friendlyToFaction) or friendlyToFaction == "AH" or friendlyToFaction == factionKey then
                        local flags = QuestieDB.QueryNPCSingle(vendorId, "npcFlags")
                        if bit.band(flags, QuestieDB.npcFlags.VENDOR) == QuestieDB.npcFlags.VENDOR then
                            tbl[vendorId] = true
                        end
                    end
                end
            end
        end
    end
    return tbl
end

function QuestieCorrections:PopulateTownsfolkPostBoot() -- post DB boot (use queries here)
    -- item ids for class-specific reagents
    local reagents = {
        ["MAGE"] = {17031, 17032, 17020},
        ["SHAMAN"] = {17030},
        ["PRIEST"] = {17029,17028},
        ["PALADIN"] = {21177,17033},
        ["WARRIOR"] = {},
        ["HUNTER"] = {},
        ["WARLOCK"] = {5565,16583},
        ["ROGUE"] = {5140,2928,8924,5173,2930,8923},
        ["DRUID"] = {17034,17026,17035,17021,17038,17036,17037}
    }
    reagents = reagents[select(2, UnitClass("player"))]

    -- populate vendor IDs from db
    if #reagents > 0 then
        Questie.db.char.townsfolk["Reagents"] = _reformatVendors(QuestieCorrections:PopulateVendors(reagents))
    end
    Questie.db.char.vendorList["Trade Goods"] = _reformatVendors(QuestieCorrections:PopulateVendors({ -- item ids from wowhead for trade goods   (temporarily disabled)
        14256,12810,13463,8845,8846,4234,3713,8170,14341,4389,3357,2453,13464,
        3355,3356,3358,4371,4304,5060,2319,18256,8925,3857,10940,2321,785,4404,2692,
        2605,3372,2320,6217,2449,4399,4364,10938,18567,4382,4289,765,3466,3371,2447,2880,
        2928,4361,10647,10648,4291,4357,8924,8343,4363,2678,5173,4400,2930,4342,2325,4340,
        6261,8923,2324,2604,6260,4378,10290,17194,4341
    }))
    Questie.db.char.vendorList["Bags"] = _reformatVendors(QuestieCorrections:PopulateVendors({4496, 4497, 4498, 4499}))
    QuestieCorrections:UpdatePlayerVendors()
end

function QuestieCorrections:PopulateTownsfolk()
    Questie.db.global.townsfolk = {
        ["Repair"] = QuestieCorrections:PopulateTownsfolkType(QuestieDB.npcFlags.REPAIR), 
        ["Auctioneer"] = QuestieCorrections:PopulateTownsfolkType(QuestieDB.npcFlags.AUCTIONEER),
        ["Banker"] = QuestieCorrections:PopulateTownsfolkType(QuestieDB.npcFlags.BANKER),
        ["Battlemaster"] = QuestieCorrections:PopulateTownsfolkType(QuestieDB.npcFlags.BATTLEMASTER),
        ["Flight Master"] = QuestieCorrections:PopulateTownsfolkType(QuestieDB.npcFlags.FLIGHT_MASTER),
        ["Innkeeper"] = QuestieCorrections:PopulateTownsfolkType(QuestieDB.npcFlags.INNKEEPER),
        ["Weapon Master"] = {}, -- populated below
    }
    Questie.db.char.townsfolk = {} -- character-specific townsfolk
    Questie.db.char.vendorList = {} -- character-specific vendors
    local classTrainers = { -- SELECT entry FROM creature_template WHERE trainertype=0 AND trainerclass=
        ["MAGE"] = {198,313,328,331,944,1228,2124,2128,3047,3048,3049,4566,4567,4568,5144,5145,5146,5497,5498,5880,5882,5883,5884,5885,7311,7312},
        ["SHAMAN"] = {986,3030,3031,3032,3062,3066,3157,3173,3344,3403,13417},
        ["PRIEST"] = {375,376,377,837,1226,2123,2129,3044,3045,3046,3595,3600,3706,3707,4090,4091,4092,4606,4607,4608,5141,5142,5143,5484,5489,5994,6014,6018,11397,11401,11406},
        ["PALADIN"] = {925,926,927,928,1232,5147,5148,5149,5491,5492,8140},
        ["WARRIOR"] = {911,912,913,914,985,1229,1901,2119,2131,3041,3042,3043,3059,3063,3153,3169,3353,3354,3408,3593,3598,4087,4089,4593,4594,4595,5113,5114,5479,5480,7315,8141,16387},
        ["HUNTER"] = {895,987,1231,1404,3038,3039,3040,3061,3065,3154,3171,3352,3406,3407,3596,3601,3963,4138,4146,4205,5115,5116,5117,5501,5515,5516,5517,8308,10930},
        ["WARLOCK"] = {459,460,461,906,988,2126,2127,3156,3172,3324,3325,3326,4563,4564,4565,5171,5172,5173,5495,5496,5612},
        ["ROGUE"] = {915,916,917,918,1234,1411,2122,2130,3155,3170,3327,3328,3401,3594,3599,4163,4214,4215,4582,4583,4584,5165,5166,5167,13283},
        ["DRUID"] = {3033,3034,3036,3060,3064,3597,3602,4217,4218,4219,5504,5505,5506,8142,9465,12042}
    }

    local validTrainers = { -- SELECT Entry FROM creature_template WHERE NpcFlags & 16 = 16 AND TrainerType=2 (do this again with tbc DB)
        223,514,812,908,957,1103,1215,1218,1241,1246,1292,1300,1317,1346,1355,1382,1383,1385,1386,1430,1458,1466,1470,1473,1632,1651,
        1676,1680,1681,1683,1699,1700,1701,1702,1703,2114,2132,2326,2327,2329,2367,2390,2391,2399,2627,2704,2737,2798,2818,2834,2836,
        2837,2855,2856,2857,2998,3001,3004,3007,3008,3009,3011,3013,3026,3028,3067,3069,3087,3136,3137,3174,3175,3179,3181,3184,3185,
        3290,3332,3345,3347,3355,3357,3363,3365,3373,3399,3404,3412,3478,3484,3494,3523,3530,3531,3549,3555,3557,3603,3604,3605,3606,
        3607,3703,3704,3964,3965,3967,4156,4159,4160,4193,4204,4210,4211,4212,4213,4254,4258,4552,4573,4576,4578,4586,4588,4591,4596,
        4598,4605,4609,4611,4614,4616,4898,4900,5127,5137,5150,5153,5157,5159,5161,5164,5174,5177,5392,5482,5493,5499,5500,5502,5511,
        5513,5518,5564,5566,5567,5690,5695,5759,5784,5811,5938,5939,5941,5943,6094,6286,6287,6288,6289,6290,6291,6292,6295,6297,6299,
        6306,6387,7087,7088,7089,7230,7231,7232,7406,7866,7867,7868,7869,7870,7871,7944,7946,7948,7949,8126,8128,8144,8146,8153,8306,
        8736,8738,9584,10266,10276,10277,10278,10993,11017,11025,11026,11028,11029,11031,11037,11041,11042,11044,11046,11047,11048,
        11049,11050,11051,11052,11065,11066,11067,11068,11070,11071,11072,11073,11074,11081,11083,11084,11096,11097,11098,11146,
        11177,11178,11865,11866,11867,11868,11869,11870,12025,12030,12032,12920,12939,12961,13084,14401,14740
    }

    local professionTrainers = {
        [QuestieProfessions.professionKeys.FIRST_AID] = {},
        [QuestieProfessions.professionKeys.BLACKSMITHING] = {},
        [QuestieProfessions.professionKeys.LEATHERWORKING] = {},
        [QuestieProfessions.professionKeys.ALCHEMY] = {},
        [QuestieProfessions.professionKeys.HERBALISM] = {},
        [QuestieProfessions.professionKeys.COOKING] = {},
        [QuestieProfessions.professionKeys.MINING] = {},
        [QuestieProfessions.professionKeys.TAILORING] = {},
        [QuestieProfessions.professionKeys.ENGINEERING] = {},
        [QuestieProfessions.professionKeys.ENCHANTING] = {},
        [QuestieProfessions.professionKeys.FISHING] = {},
        [QuestieProfessions.professionKeys.SKINNING] = {}
    }

    for _, id in pairs(validTrainers) do
        local subName = QuestieDB.npcData[id][QuestieDB.npcKeys.subName]
        if subName then
            if Questie.db.global.townsfolk[subName] then -- weapon master, 
                tinsert(Questie.db.global.townsfolk[subName], id)
            else
                for k, professionId in pairs(QuestieProfessions.professionTable) do
                    if string.match(subName, k) then
                        tinsert(professionTrainers[professionId], id)
                    end
                end
            end
        end
    end

    Questie.db.global.professionTrainers = professionTrainers
    local faction = UnitFactionGroup("Player")
    local _, class = UnitClass("player")

    -- todo: specialized trainer types (leatherworkers, engineers, etc)

    Questie.db.char.townsfolk["Class Trainer"] = classTrainers[class]
    if class == "HUNTER" then
        Questie.db.char.townsfolk["Stable Master"] = QuestieCorrections:PopulateTownsfolkType(QuestieDB.npcFlags.STABLEMASTER)
    elseif class == "MAGE" then
        Questie.db.char.townsfolk["Portal Trainer"] = {4165,2485,2489,5958,5957,2492}
    end

    Questie.db.char.townsfolk["Mailbox"] = {}

    for _, id in pairs({ -- mailbox list
        32349,142075,142089,142093,142094,142095,142102,142103,142109,142110,142111,142117,142119,143981,143982,143983,
        143984,143985,143986,143987,143988,143989,143990,144011,144112,144125,144126,144127,144128,144129,144131,153578,
        153716,157637,163313,163645,164618,164840,171556,171699,171752,173047,173221,176319,176324,176404,177044,178864,
        179895,179896,180451,181236,181639,187260,188123
    }) do
        local factionID = QuestieDB.objectData[id][QuestieDB.objectKeys.factionID]
        if (factionID == 0 
                or (faction == "Horde" and bit.band(QuestieDB.factionTemplate[factionID][5], 12) == 0) 
                or (faction == "Alliance" and bit.band(QuestieDB.factionTemplate[factionID][5], 10) == 0)) then
            -- friendly to the player
            tinsert(Questie.db.char.townsfolk["Mailbox"], id)
        end
    end

    Questie.db.char.townsfolk["Spirit Healer"] = {}

    for e=19199, 19283 do
        if QuestieDB.npcData[e] then
            tinsert(Questie.db.char.townsfolk["Spirit Healer"], e)
        end
    end

    Questie.db.global.petFoodVendorTypes = {["Meat"] = {},["Fish"]={},["Cheese"]={},["Bread"]={},["Fungus"]={},["Fruit"]={},["Raw Meat"]={},["Raw Fish"]={}}
    local petFoodIndexes = {"Meat","Fish","Cheese","Bread","Fungus","Fruit","Raw Meat","Raw Fish"}

    for id, data in pairs(QuestieDB.itemData) do
        local foodType = data[QuestieDB.itemKeys.foodType]
        if foodType then
            tinsert(Questie.db.global.petFoodVendorTypes[petFoodIndexes[foodType]], id)
        end
    end

    -- get player professions and add relevant npcs
    --Questie.db.char.townsfolk["Profession Trainer"] = {}

end
function QuestieCorrections:PreCompile(callback) -- this happens only if we are about to compile the database. Run intensive preprocessing tasks here (like ramer-douglas-peucker)

    local timer = nil
    local ops = {}
    --local totalPoints = 0

    for id, data in pairs(QuestieDB.npcData) do
        local way = data[QuestieDB.npcKeys["waypoints"]]
        if way then
            tinsert(ops, {way, id})
            --for _,waypoints in pairs(way) do
            --    totalPoints = totalPoints + #waypoints
            --end
        end
    end

    timer = C_Timer.NewTicker(0.1, function()
        for i=0,Questie.db.global.debugEnabled and 4000 or 72 do -- 72 operations per NewTicker
            local op = tremove(ops, 1)
            if op then
                QuestieDB.npcData[op[2]][QuestieDB.npcKeys["waypoints"]] = QuestieCorrections:OptimizeWaypoints(op[1])
            else
                --local totalPoints2 = 0
                --for id, data in pairs(QuestieDB.npcData) do
                --    local way = data[QuestieDB.npcKeys["waypoints"]]
                --    if way then
                --        for _,waypoints in pairs(way) do
                --            totalPoints2 = totalPoints2 + #waypoints
                --        end
                --    end
                --end
                --print("Before RDP: " .. tostring(totalPoints))
                --print("After RDP:" .. tostring(totalPoints2))

                timer:Cancel()
                callback()
                break
            end
        end
    end)
end


-- code after this point is Ramer-Douglas-Peucker algorithm implemented by Eryn Lynn
--[[
MIT License

Copyright (c) 2018 Eryn Lynn

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE. ]]
-- Implementation of the Ramer–Douglas–Peucker algorithm
-- readme https://github.com/evaera/RobloxLuaAlgorithms#ramerdouglaspeuckerlua
-- author: evaera

local function getSqDist(p1, p2)
    local dx = p1[1] - p2[1]
    local dy = p1[2] - p2[2]

    return dx * dx + dy * dy
end

local function getSqSegDist(p, p1, p2)
    local x = p1[1]
    local y = p1[2]
    local dx = p2[1] - x
    local dy = p2[2] - y

    if dx ~= 0 or dy ~= 0 then
        local t = ((p[1] - x) * dx + (p[2] - y) * dy) / (dx * dx + dy * dy)

        if t > 1 then
            x = p2[1]
            y = p2[2]
        elseif t > 0 then
            x = x + dx * t
            y = y + dy * t
        end
    end

    dx = p[1] - x
    dy = p[2] - y

    return dx * dx + dy * dy
end

local function simplifyRadialDist(points, sqTolerance)
    local prevPoint = points[1]
    local newPoints = {prevPoint}
    local point

    for i=2, #points do
        point = points[i]

        if getSqDist(point, prevPoint) > sqTolerance then
            table.insert(newPoints, point)
            prevPoint = point
        end
    end

    if prevPoint ~= point then
        table.insert(newPoints, point)
    end

    return newPoints
end

local function simplifyDPStep(points, first, last, sqTolerance, simplified)
    local maxSqDist = sqTolerance
    local index

    for i=first+1, last do
        local sqDist = getSqSegDist(points[i], points[first], points[last])

        if sqDist > maxSqDist then
            index = i
            maxSqDist = sqDist
        end
    end

    if maxSqDist > sqTolerance then
        if index - first > 1 then
            simplifyDPStep(points, first, index, sqTolerance, simplified)
        end

        table.insert(simplified, points[index])

        if last - index > 1 then
            simplifyDPStep(points, index, last, sqTolerance, simplified)
        end
    end
end

local function simplifyDouglasPeucker(points, sqTolerance)
    local last = #points

    local simplified={points[1]}
    simplifyDPStep(points, 1, last, sqTolerance, simplified)
    table.insert(simplified, points[last])

    return simplified
end

function QuestieCorrections:RamerDouglasPeucker(points, tolerance, highestQuality)
    if #points <= 2 then
        return points
    end

    local sqTolerance = tolerance ~= nil and tolerance^2 or 1

    points = highestQuality and points or simplifyRadialDist(points, sqTolerance)
    points = simplifyDouglasPeucker(points, sqTolerance)

    return points
end
