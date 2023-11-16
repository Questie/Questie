---@class QuestieTBCItemFixes
local QuestieTBCItemFixes = QuestieLoader:CreateModule("QuestieTBCItemFixes")

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")

function QuestieTBCItemFixes:Load()
    local itemKeys = QuestieDB.itemKeys

    return {
        [4503] = {
            [itemKeys.npcDrops] = {2557,2556,2555,2553,2552,2558,2554},
        },
        [5445] = {
            [itemKeys.npcDrops] = {3943},
        },
        [5959] = {
            [itemKeys.npcDrops] = {4376,4378,4379,4411,4412,4413,4414,4415,4380},
        },
        [6083] = {
            [itemKeys.npcDrops] = {},
        },
        [8073] = {
            [itemKeys.npcDrops] = {},
        },
        [12366] = {
            [itemKeys.npcDrops] = {7457,7458,7459,7460},
        },
        [20023] = {
            [itemKeys.npcDrops] = {6375,6377,6378,6379,6380,8759,8761,8762,8763,8764,8766,},
        },
        [21771] = {
            [itemKeys.npcDrops] = {15668,15669},
        },
        [22435] = {
            [itemKeys.npcDrops] = {6551,6552,6553,6554,6555,10040,10041},
        },
        [22775] = {
            [itemKeys.npcDrops] = {16442},
        },
        [22776] = {
            [itemKeys.npcDrops] = {16443},
        },
        [22777] = {
            [itemKeys.npcDrops] = {16444},
        },
        [23217] = {
            [itemKeys.npcDrops] = {16933},
        },
        [23339] = {
            [itemKeys.npcDrops] = {},
        },
        [23361] = {
            [itemKeys.class] = 12,
        },
        [23417] = {
            [itemKeys.class] = 12,
        },
        [23645] = {
            [itemKeys.class] = 12,
        },
        [23486] = {
            [itemKeys.objectDrops] = {181582},
        },
        [23552] = {
            [itemKeys.objectDrops] = {184079},
        },
        [23614] = {
            [itemKeys.objectDrops] = {181616},
        },
        [23670] = {
            [itemKeys.objectDrops] = {181632},
        },
        [23750] = {
            [itemKeys.objectDrops] = {107047},
        },
        [23789] = {
            [itemKeys.npcDrops] = {17186,17187,17188},
        },
        [23792] = {
            [itemKeys.class] = 12,
        },
        [23801] = {
            [itemKeys.class] = 12,
        },
        [23818] = {
            [itemKeys.class] = 12,
        },
        [23848] = {
            [itemKeys.npcDrops] = {3546},
        },
        [23849] = {
            [itemKeys.npcDrops] = {17190,17191,17192},
        },
        [23878] = {
            [itemKeys.objectDrops] = {181779},
        },
        [23879] = {
            [itemKeys.objectDrops] = {181780},
        },
        [23880] = {
            [itemKeys.objectDrops] = {181781},
        },
        [23894] = {
            [itemKeys.npcDrops] = {17370,17371,17377,17381,17395,17397,17398,17414,17429,17491,17624,17626,},
        },
        [23984] = {
            [itemKeys.npcDrops] = {17324,17327,17339,17342,17343,17344,17346,17347,17348,17350,17352,17353,17522,17523,17527,17588,17589,17661,17683,17322,17323,17325,17326,17328,17329,17330,17334,17336,17337,17338,17340,17341,17358,17494,17550,17604,17606,17607,17608,17609,17610,17713,17714,17715},
        },
        [24084] = {
            [itemKeys.class] = 12,
        },
        [24099] = {
            [itemKeys.class] = 12,
        },
        [24156] = {
            [itemKeys.npcDrops] = {17544},
        },
        [24278] = {
            [itemKeys.class] = 12,
        },
        [24285] = {
            [itemKeys.npcDrops] = {16683},
        },
        [24286] = {
            [itemKeys.npcDrops] = {16611},
        },
        [24289] = {
            [itemKeys.class] = 12,
        },
        [24317] = {
            [itemKeys.objectDrops] = {182074},
        },
        [24335] = {
            [itemKeys.class] = 12,
        },
        [24474] = {
            [itemKeys.class] = 12,
        },
        [24502] = {
            [itemKeys.npcDrops] = {17138,18037,18064,18065},
            [itemKeys.class] = 12,
        },
        [24573] = {
            [itemKeys.npcDrops] = {18197},
        },
        [24226] = {
            [itemKeys.npcDrops] = {17832},
        },
        [24355] = {
            [itemKeys.class] = 12,
        },
        [24467] = {
            [itemKeys.class] = 12,
        },
        [24501] = {
            [itemKeys.class] = 12,
        },
        [25460] = {
            [itemKeys.npcDrops] = {},
        },
        [25461] = {
            [itemKeys.npcDrops] = {18472},
        },
        [25462] = {
            [itemKeys.npcDrops] = {16807},
        },
        [25465] = {
            [itemKeys.class] = 12,
        },
        [25539] = {
            [itemKeys.class] = 12,
        },
        [25552] = {
            [itemKeys.class] = 12,
        },
        [25554] = {
            [itemKeys.npcDrops] = {},
        },
        [25555] = {
            [itemKeys.class] = 12,
        },
        [25642] = {
            [itemKeys.objectDrops] = {185201},
        },
        [25807] = {
            [itemKeys.npcDrops] = {18476,18477},
        },
        [25658] = {
            [itemKeys.class] = 12,
        },
        [28038] = {
            [itemKeys.class] = 12,
        },
        [28106] = {
            [itemKeys.class] = 12,
        },
        [28132] = {
            [itemKeys.class] = 12,
        },
        [28478] = {
            [itemKeys.class] = 12,
        },
        [29112] = {
            [itemKeys.npcDrops] = {18907},
        },
        [29162] = {
            [itemKeys.objectDrops] = {184162},
        },
        [29324] = {
            [itemKeys.class] = 12,
        },
        [29460] = {
            [itemKeys.class] = 12,
        },
        [29473] = {
            [itemKeys.class] = 12,
        },
        [29482] = {
            [itemKeys.class] = 12,
        },
        [29742] = {
            [itemKeys.class] = 12,
        },
        [29778] = {
            [itemKeys.class] = 12,
        },
        [29796] = {
            [itemKeys.class] = 12,
        },
        [30259] = {
            [itemKeys.class] = 12,
        },
        [30426] = {
            [itemKeys.npcDrops] = {19762,19768,19789},
            [itemKeys.class] = 12,
        },
        [30430] = {
            [itemKeys.objectDrops] = {184715},
        },
        [30435] = {
            [itemKeys.objectDrops] = {184729},
        },
        [30451] = {
            [itemKeys.npcDrops] = {19799,19800,19802,21337,21656},
        },
        [30540] = {
            [itemKeys.class] = 12,
        },
        [30639] = {
            [itemKeys.class] = 12,
        },
        [30658] = {
            [itemKeys.npcDrops] = {21727},
        },
        [30659] = {
            [itemKeys.npcDrops] = {21725},
        },
        [30672] = {
            [itemKeys.class] = 12,
        },
        [30712] = {
            [itemKeys.class] = 12,
        },
        [30719] = {
            [itemKeys.class] = 12,
        },
        [30721] = {
            [itemKeys.class] = 12,
        },
        [30743] = {
            [itemKeys.npcDrops] = {21821,20021},
        },
        [30782] = {
            [itemKeys.npcDrops] = {21817,20021},
        },
        [30783] = {
            [itemKeys.npcDrops] = {21820,20021},
        },
        [30808] = {
            [itemKeys.npcDrops] = {18667},
        },
        [30823] = {
            [itemKeys.npcDrops] = {19678},
        },
        [31121] = {
            [itemKeys.class] = 12,
        },
        [31122] = {
            [itemKeys.class] = 12,
        },
        [31130] = {
            [itemKeys.npcDrops] = {21387},
        },
        [31252] = {
            [itemKeys.npcDrops] = {18733},
        },
        [31279] = {
            [itemKeys.class] = 12,
        },
        [31316] = {
            [itemKeys.class] = 12,
        },
        [31530] = {
            [itemKeys.objectDrops] = {177281},
        },
        [31495] = {
            [itemKeys.class] = 12,
        },
        [31517] = {
            [itemKeys.class] = 12,
        },
        [31518] = {
            [itemKeys.class] = 12,
        },
        [31655] = {
            [itemKeys.class] = 12,
        },
        [31664] = {
            [itemKeys.class] = 12,
        },
        [31708] = {
            [itemKeys.objectDrops] = {185224},
        },
        [31709] = {
            [itemKeys.objectDrops] = {185226},
        },
        [31710] = {
            [itemKeys.objectDrops] = {185225},
        },
        [31716] = {
            [itemKeys.npcDrops] = {17301},
        },
        [31721] = {
            [itemKeys.npcDrops] = {17798},
        },
        [31722] = {
            [itemKeys.npcDrops] = {18708},
        },
        [31941] = {
            [itemKeys.objectDrops] = {185460},
        },
        [31951] = {
            [itemKeys.vendors] = {21643},
        },
        [31957] = {
            [itemKeys.npcDrops] = {20520},
        },
        [32364] = {
            [itemKeys.objectDrops] = {185566},
            [itemKeys.npcDrops] = {23002},
        },
        [32385] = {
            [itemKeys.npcDrops] = {21174},
        },
        [32386] = {
            [itemKeys.npcDrops] = {21174},
        },
        [32406] = {
            [itemKeys.class] = 12,
        },
        [32723] = {
            [itemKeys.npcDrops] = {},
        },
        [32971] = {
            [itemKeys.class] = 12,
        },
        [33071] = {
            [itemKeys.npcDrops] = {},
        },
        [33039] = {
            [itemKeys.npcDrops] = {},
        },
        [31813] = {
            [itemKeys.npcDrops] = {18884},
        },
        [34246] = {
            [itemKeys.npcDrops] = {},
        },
        [32742] = {
            [itemKeys.npcDrops] = {23363},
        },
        [33041] = {
            [itemKeys.objectDrops] = {186283},
        },
        [33061] = {
            [itemKeys.class] = 12,
        },
        [33086] = {
            [itemKeys.npcDrops] = {},
        },
        [33087] = {
            [itemKeys.npcDrops] = {4328,4329,4331},
        },
        [33112] = {
            [itemKeys.npcDrops] = {},
        },
        [33175] = {
            [itemKeys.npcDrops] = {},
        },
        [33814] = {
            [itemKeys.npcDrops] = {17377},
        },
        [33815] = {
            [itemKeys.npcDrops] = {16808},
        },
        [33821] = {
            [itemKeys.npcDrops] = {17942},
        },
        [33826] = {
            [itemKeys.npcDrops] = {17882},
        },
        [33827] = {
            [itemKeys.npcDrops] = {17798},
        },
        [33833] = {
            [itemKeys.npcDrops] = {17536},
        },
        [33834] = {
            [itemKeys.npcDrops] = {18473},
        },
        [33835] = {
            [itemKeys.npcDrops] = {18344},
        },
        [33836] = {
            [itemKeys.npcDrops] = {18373},
        },
        [33837] = {
            [itemKeys.npcDrops] = {18096},
        },
        [33840] = {
            [itemKeys.npcDrops] = {18708},
        },
        [33858] = {
            [itemKeys.npcDrops] = {17881},
        },
        [33859] = {
            [itemKeys.npcDrops] = {17977},
        },
        [33860] = {
            [itemKeys.npcDrops] = {19220},
        },
        [33861] = {
            [itemKeys.npcDrops] = {20912},
        },
        [34160] = {
            [itemKeys.npcDrops] = {24664},
        },
        [34338] = {
            [itemKeys.npcDrops] = {24960,24966},
        },
        [34475] = {
            [itemKeys.class] = 12,
        },
        [34477] = {
            [itemKeys.class] = 12,
        },
        [34864] = {
            [itemKeys.objectDrops] = {500004,500005,500006},
        },
        [35229] = {
            [itemKeys.objectDrops] = {400013},
        },
        [35277] = {
            [itemKeys.npcDrops] = {25866,25863,25924},
        },
        [37736] = { -- 2021 Brewfest item (Alliance)
            [itemKeys.name] = '"Brew of the Month" Club Membership Form',
            [itemKeys.startQuest] = 12420,
            [itemKeys.itemLevel] = 1,
            [itemKeys.requiredLevel] = 1,
            [itemKeys.ammoType] = 0,
            [itemKeys.class] = 12,
            [itemKeys.subClass] = 0,
            [itemKeys.vendors] = {23710,27478},
        },
        [37737] = { -- 2021 Brewfest item (Horde)
            [itemKeys.name] = '"Brew of the Month" Club Membership Form',
            [itemKeys.startQuest] = 12421,
            [itemKeys.itemLevel] = 1,
            [itemKeys.requiredLevel] = 1,
            [itemKeys.ammoType] = 0,
            [itemKeys.class] = 12,
            [itemKeys.subClass] = 0,
            [itemKeys.vendors] = {24495,27489},
        },
    }
end

-- This should allow manual fix for item availability
function QuestieTBCItemFixes:LoadFactionFixes()
    local itemKeys = QuestieDB.itemKeys

    local itemFixesHorde = {
        [30712] = {
            [itemKeys.npcDrops] = {21779},
        },
        [30713] = {
            [itemKeys.objectDrops] = {185233},
        },
    }

    local itemFixesAlliance = {
        [30712] = {
            [itemKeys.npcDrops] = {21778},
        },
        [30713] = {
            [itemKeys.objectDrops] = {184947},
        },
    }

    if UnitFactionGroup("Player") == "Horde" then
        return itemFixesHorde
    else
        return itemFixesAlliance
    end
end
