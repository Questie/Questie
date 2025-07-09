---@class MopItemFixes
local MopItemFixes = QuestieLoader:CreateModule("MopItemFixes")

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")

function MopItemFixes.Load()
    local itemKeys = QuestieDB.itemKeys
    local itemClasses = QuestieDB.itemClasses

    return {
        [74033] = { -- Ancient Hozen Skull
            [itemKeys.objectDrops] = {209595}
        },
        [74160] = { -- Zin\'Jun\'s Rifle
            [itemKeys.npcDrops] = {55470,66917}
        },
        [74161] = { -- Zin\'Jun\'s Left Eye
            [itemKeys.npcDrops] = {55470,66917}
        },
        [74162] = { -- Zin\'Jun\'s Right Eye
            [itemKeys.npcDrops] = {55470,66917}
        },
        [74163] = { -- Snuff\'s Corpse
            [itemKeys.npcDrops] = {55470,66917}
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
        [89163] = { -- Requisitioned Firework Launcher
            [itemKeys.class] = itemClasses.QUEST,
        },
        [89603] = { -- Encoded Captain's Log
            [itemKeys.npcDrops] = {66148},
        },
    }
end
