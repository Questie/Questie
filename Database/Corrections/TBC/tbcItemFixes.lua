---@class QuestieTBCItemFixes
local QuestieTBCItemFixes = QuestieLoader:CreateModule("QuestieTBCItemFixes")

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")

QuestieDB.fakeTbcItemStartId = 40000

function QuestieTBCItemFixes:Load()
    local itemKeys = QuestieDB.itemKeys

    return {
        [4503] = {
            [itemKeys.npcDrops] = {2557,2556,2555,2553,2552,2558,2554,},
        },
        [5959] = {
            [itemKeys.npcDrops] = {4376,4378,4379,4411,4412,4413,4414,4415,4380,},
        },
        [21771] = {
            [itemKeys.npcDrops] = {15668,15669,},
        },
        [22435] = {
            [itemKeys.npcDrops] = {6551,6552,6553,6554,6555,10040,10041,},
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
        [23442] = {
            [itemKeys.npcDrops] = {16975},
        },
        [23486] = {
            [itemKeys.objectDrops] = {181582},
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
            [itemKeys.npcDrops] = {17186,17187,17188,},
        },
        [23848] = {
            [itemKeys.npcDrops] = {3546},
        },
        [23849] = {
            [itemKeys.npcDrops] = {17190,17191,17192,},
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
            [itemKeys.npcDrops] = {17324,17327,17339,17342,17343,17344,17346,17347,17348,17350,17352,17353,17522,17523,17527,17588,17589,17661,17683,17322,17323,17325,17326,17328,17329,17330,17334,17336,17337,17338,17340,17341,17358,17494,17550,17604,17606,17607,17608,17609,17610,17713,17714,17715,},
        },
        [23997] = {
            [itemKeys.objectDrops] = {181699},
        },
        [24156] = {
            [itemKeys.npcDrops] = {17544},
        },
        [24317] = {
            [itemKeys.objectDrops] = {182074},
        },
        [24502] = {
            [itemKeys.npcDrops] = {17138,18037,18064,18065,},
        },
        [24573] = {
            [itemKeys.npcDrops] = {18197},
        },
        [24226] = {
            [itemKeys.npcDrops] = {17832},
        },
        [25852] = {
            [itemKeys.objectDrops] = {184842},
        },
        [28548] = {
            [itemKeys.npcDrops] = {18865,18881,},
        },
        [29112] = {
            [itemKeys.npcDrops] = {18907},
        },
        [29162] = {
            [itemKeys.objectDrops] = {184162},
        },
        [30430] = {
            [itemKeys.objectDrops] = {184715},
        },
        [30435] = {
            [itemKeys.objectDrops] = {184729},
        },
        [30451] = {
            [itemKeys.npcDrops] = {19799,19800,19802,21337,21656,},
        },
        [30658] = {
            [itemKeys.npcDrops] = {21727},
        },
        [30890] = {
            [itemKeys.npcDrops] = {21057},
        },
        [31130] = {
            [itemKeys.npcDrops] = {21387},
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
        [32742] = {
            [itemKeys.npcDrops] = {23363}
        },
        [33086] = {
            [itemKeys.npcDrops] = {},
        },
        [33087] = {
            [itemKeys.npcDrops] = {4328,4329,4331},
        },
        [33175] = {
            [itemKeys.npcDrops] = {},
        },

        -- Below are fake items which can be used to show special quest "objectives" as requiredSourceItem.
        -- For example this is used for quest 10129 to show the NPC you have to talk with to start the flight

        [40000] = {
            [itemKeys.name] = "Speak with Wing Commander Brack",
            [itemKeys.relatedQuests] = {10129,},
            [itemKeys.npcDrops] = {19401},
            [itemKeys.objectDrops] = {},
        },
        [40001] = {
            [itemKeys.name] = "Kill Bristlelimb Furbolgs to lure 'High Chief Bristlelimb'",
            [itemKeys.relatedQuests] = {9667,},
            [itemKeys.npcDrops] = {40002},
            [itemKeys.objectDrops] = {},
        },
        [40002] = {
            [itemKeys.name] = "Matis the Cruel Captured",
            [itemKeys.relatedQuests] = {9711,},
            [itemKeys.npcDrops] = {17664},
            [itemKeys.objectDrops] = {},
        },
    }
end
