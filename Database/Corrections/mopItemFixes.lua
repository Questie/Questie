---@class MopItemFixes
local MopItemFixes = QuestieLoader:CreateModule("MopItemFixes")

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")

function MopItemFixes.Load()
    local itemKeys = QuestieDB.itemKeys
    local itemClasses = QuestieDB.itemClasses

    return {
        [10641] = { -- Moonpetal Lily
            [itemKeys.objectDrops] = {207346},
        },
        [71635] = { -- Imbued Crystal
            [itemKeys.npcDrops] = {4832,9018,10264,10813,11496,12201,12258,17377,17977,18344,24664,26794,28923,36658,39732},
        },
        [71637] = { -- Mysterious Grimoire
            [itemKeys.npcDrops] = {3671,4421,5710,7795,9019,18373,18732,19220,26530,26631,29310,39425,46964,54938},
        },
        [71638] = { -- Ornate Weapon
            [itemKeys.npcDrops] = {2748,4420,7800,9568,10363,11486,12236,27975,29306,29308,39698,40177,44577,45412,46383,54968},
        },
        [74033] = { -- Ancient Hozen Skull
            [itemKeys.objectDrops] = {209595},
        },
        [74160] = { -- Zin\'Jun\'s Rifle
            [itemKeys.npcDrops] = {55470,66917},
        },
        [74161] = { -- Zin\'Jun\'s Left Eye
            [itemKeys.npcDrops] = {55470,66917},
        },
        [74162] = { -- Zin\'Jun\'s Right Eye
            [itemKeys.npcDrops] = {55470,66917},
        },
        [74163] = { -- Snuff\'s Corpse
            [itemKeys.npcDrops] = {55470,66917},
        },
        [74260] = { -- Bamboo Key
            [itemKeys.class] = itemClasses.QUEST,
        },
        [74296] = { -- Stolen Carrot
            [itemKeys.npcDrops] = {55504},
        },
        [74615] = { -- Paint Soaked Brush
            [itemKeys.npcDrops] = {55601},
            [itemKeys.objectDrops] = {},
        },
        [74621] = { -- Viscous Chlorophyll
            [itemKeys.npcDrops] = {55610},
        },
        [74623] = { -- Emergency Supplies
            [itemKeys.npcDrops] = {62930},
        },
        [75202] = { -- Speckled Trout
            [itemKeys.npcDrops] = {56180},
        },
        [75208] = { -- Rancher's Lariat
            [itemKeys.class] = itemClasses.QUEST,
        },
        [75271] = { -- Jian
            [itemKeys.npcDrops] = {56253},
        },
        [75272] = { -- Ling
            [itemKeys.npcDrops] = {56254},
        },
        [75273] = { -- Smelly
            [itemKeys.npcDrops] = {56255},
        },
        [75275] = { -- Mushan Shoulder Steak
            [itemKeys.npcDrops] = {56239},
        },
        [75276] = { -- Turtle Meat Scrap
            [itemKeys.npcDrops] = {56256},
        },
        [76173] = { -- Bug Leg
            [itemKeys.npcDrops] = {56283},
        },
        [76225] = { -- Fistful of Bird Guts
            [itemKeys.npcDrops] = {56396},
        },
        [76260] = { -- Exploded Slicky
            [itemKeys.objectDrops] = {209877},
        },
        [76297] = { -- Stolen Turnip
            [itemKeys.objectDrops] = {209891},
        },
        [76334] = { -- Meadow Marigold
            [itemKeys.objectDrops] = {209907},
        },
        [76335] = { -- Vial of Animal Blood
            [itemKeys.npcDrops] = {56523,56524,56531,56532},
        },
        [76337] = { -- Stolen Sack of Hops
            [itemKeys.objectDrops] = {211696},
        },
        [76362] = { -- Mudmug's Vial
            [itemKeys.class] = itemClasses.QUEST,
        },
        [76370] = { -- Orange-Painted Turnip
            [itemKeys.class] = itemClasses.QUEST,
        },
        [76420] = { -- Snapper Steak
            [itemKeys.npcDrops] = {56447},
        },
        [76499] = { -- Jademoon Leaf
            [itemKeys.objectDrops] = {209952},
        },
        [76501] = { -- Emperor Tern Egg
            [itemKeys.objectDrops] = {209953},
        },
        [76503] = { -- Whitefisher Crane Egg
            [itemKeys.objectDrops] = {209954},
        },
        [76516] = { -- Hornbill Strider Egg
            [itemKeys.objectDrops] = {209955},
        },
        [76973] = { -- Sprig of Dreamleaf
            [itemKeys.objectDrops] = {209987},
        },
        [77033] = { -- Sack of Grain
            [itemKeys.objectDrops] = {210001},
        },
        [77034] = { -- Malted Cave Barley
            [itemKeys.objectDrops] = {210037},
        },
        [77455] = { -- Mulberry Leaves
            [itemKeys.objectDrops] = {210080},
        },
        [77456] = { -- Raw Silk
            [itemKeys.objectDrops] = {210088},
        },
        [79058] = { -- Darkhide's Head
            [itemKeys.npcDrops] = {58435},
        },
        [79059] = { -- Intact Tortoise Shell
            [itemKeys.npcDrops] = {58431},
        },
        [79104] = { -- Rusty Watering Can
            [itemKeys.class] = itemClasses.QUEST,
        },
        [79197] = { -- Glade Glimmer
            [itemKeys.npcDrops] = {57301},
        },
        [79269] = { -- Marsh Lily
            [itemKeys.objectDrops] = {210565},
        },
        [79824] = { -- Stolen Vegetable
            [itemKeys.objectDrops] = {210763},
        },
        [79827] = { -- Authentic Valley Stir Fry
            [itemKeys.npcDrops] = {59124},
        },
        [80213] = { -- Spicemaster Jin Jao\'s Payment
            [itemKeys.npcDrops] = {59581},
        },
        [80214] = { -- Trader Jambeezi\'s Payment
            [itemKeys.npcDrops] = {59583},
        },
        [80215] = { -- Innkeeper Lei Lan\'s Payment
            [itemKeys.npcDrops] = {59582},
        },
        [80216] = { -- Lolo Lio\'s Payment
            [itemKeys.npcDrops] = {59585},
        },
        [80302] = { -- EZ-Gro Green Cabbage Seeds
            [itemKeys.class] = itemClasses.QUEST,
        },
        [80314] = { -- EZ-Gro Green Cabbage
            [itemKeys.npcDrops] = {59833},
        },
        [85783] = { -- Captain Jack\'s Head
            [itemKeys.npcDrops] = {63809},
            [itemKeys.startQuest] = 31261,
        },
        [85784] = { -- Alliance Service Medallion
            [itemKeys.npcDrops] = {63764,63782},
        },
        [86404] = { -- Old Map
            [itemKeys.npcDrops] = {59639},
        },
        [87282] = { -- Blade of the Anointed
            [itemKeys.objectDrops] = {214284},
        },
        [87389] = { -- Blade of the Anointed
            [itemKeys.objectDrops] = {214284},
        },
        [89163] = { -- Requisitioned Firework Launcher
            [itemKeys.class] = itemClasses.QUEST,
        },
        [89603] = { -- Encoded Captain's Log
            [itemKeys.npcDrops] = {66148},
        },
    }
end
