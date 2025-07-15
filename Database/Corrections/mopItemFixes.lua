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
        [75271] = { -- Jian
            [itemKeys.npcDrops] = {56253},
        },
        [75272] = { -- Ling
            [itemKeys.npcDrops] = {56254},
        },
        [75273] = { -- Smelly
            [itemKeys.npcDrops] = {56255},
        },
        [76173] = { -- Bug Leg
            [itemKeys.npcDrops] = {56283},
        },
        [76225] = { -- Fistful of Bird Guts
            [itemKeys.npcDrops] = {56396},
        },
        [76297] = { -- Stolen Turnip
            [itemKeys.objectDrops] = {209891},
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
