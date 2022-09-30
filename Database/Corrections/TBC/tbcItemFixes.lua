---@class QuestieTBCItemFixes
local QuestieTBCItemFixes = QuestieLoader:CreateModule("QuestieTBCItemFixes")

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")

QuestieDB.fakeTbcItemStartId = 60000

function QuestieTBCItemFixes:Load()
    local itemKeys = QuestieDB.itemKeys

    return {
        [4503] = {
            [itemKeys.npcDrops] = {2557,2556,2555,2553,2552,2558,2554},
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
        [23688] = {
            [itemKeys.objectDrops] = {181672},
        },
        [23750] = {
            [itemKeys.objectDrops] = {107047},
        },
        [23789] = {
            [itemKeys.npcDrops] = {17186,17187,17188},
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
        [23984] = {
            [itemKeys.npcDrops] = {17324,17327,17339,17342,17343,17344,17346,17347,17348,17350,17352,17353,17522,17523,17527,17588,17589,17661,17683,17322,17323,17325,17326,17328,17329,17330,17334,17336,17337,17338,17340,17341,17358,17494,17550,17604,17606,17607,17608,17609,17610,17713,17714,17715},
        },
        [23997] = {
            [itemKeys.objectDrops] = {181699},
        },
        [24156] = {
            [itemKeys.npcDrops] = {17544},
        },
        [24285] = {
            [itemKeys.npcDrops] = {16683},
        },
        [24286] = {
            [itemKeys.npcDrops] = {16611},
        },
        [24317] = {
            [itemKeys.objectDrops] = {182074},
        },
        [24502] = {
            [itemKeys.npcDrops] = {17138,18037,18064,18065},
        },
        [24573] = {
            [itemKeys.npcDrops] = {18197},
        },
        [24226] = {
            [itemKeys.npcDrops] = {17832},
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
        [25554] = {
            [itemKeys.npcDrops] = {},
        },
        [25807] = {
            [itemKeys.npcDrops] = {18476,18477},
        },
        [25852] = {
            [itemKeys.objectDrops] = {184842},
        },
        [28548] = {
            [itemKeys.npcDrops] = {18865,18881},
        },
        [29112] = {
            [itemKeys.npcDrops] = {18907},
        },
        [29162] = {
            [itemKeys.objectDrops] = {184162},
        },
        [30426] = {
            [itemKeys.npcDrops] = {19762,19768,19789},
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
        [30658] = {
            [itemKeys.npcDrops] = {21727},
        },
        [30659] = {
            [itemKeys.npcDrops] = {21725},
        },
        [30823] = {
            [itemKeys.npcDrops] = {19678},
        },
        [30890] = {
            [itemKeys.npcDrops] = {21057},
        },
        [31130] = {
            [itemKeys.npcDrops] = {21387},
        },
        [31252] = {
            [itemKeys.npcDrops] = {18733},
        },
        [31530] = {
            [itemKeys.objectDrops] = {177281},
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
        [32380] = {
            [itemKeys.npcDrops] = {20600},
        },
        [32385] = {
            [itemKeys.npcDrops] = {21174},
        },
        [32386] = {
            [itemKeys.npcDrops] = {21174},
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
        [34502] = {
            [itemKeys.objectDrops] = {400014},
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

        -- Below are fake items which can be used to show special quest "objectives" as requiredSourceItem.
        -- For example this is used for quest 10129 to show the NPC you have to talk with to start the flight

        -- TODO: Transform these items to extraObjectives. These fakeIds were introduced before extraObjectives were a thing
        [40000] = {
            [itemKeys.name] = "Speak with Wing Commander Brack",
            [itemKeys.relatedQuests] = {10129},
            [itemKeys.npcDrops] = {19401},
            [itemKeys.objectDrops] = {},
        },
        [40001] = {
            [itemKeys.name] = "Kill Bristlelimb Furbolgs to lure 'High Chief Bristlelimb'",
            [itemKeys.relatedQuests] = {9667},
            [itemKeys.npcDrops] = {40002},
            [itemKeys.objectDrops] = {},
        },
        [40002] = {
            [itemKeys.name] = "Matis the Cruel Captured",
            [itemKeys.relatedQuests] = {9711},
            [itemKeys.npcDrops] = {17664},
            [itemKeys.objectDrops] = {},
        },
    }
end
