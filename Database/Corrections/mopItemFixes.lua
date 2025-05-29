---@class MopItemFixes
local MopItemFixes = QuestieLoader:CreateModule("MopItemFixes")

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")

function MopItemFixes.Load()
    local itemKeys = QuestieDB.itemKeys
    local itemClasses = QuestieDB.itemClasses

    return {
        [74160] = { -- Zin\'Jun\'s Rifle
            [itemKeys.npcDrops] = {55470,66917}
        },
        [74161] = { -- Zin\'Jun\'s Rifle
            [itemKeys.npcDrops] = {55470,66917}
        },
        [74160] = { -- Zin\'Jun\'s Rifle
            [itemKeys.npcDrops] = {55470,66917}
        },
        [74160] = { -- Zin\'Jun\'s Rifle
            [itemKeys.npcDrops] = {55470,66917}
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
        [89163] = { -- Requisitioned Firework Launcher
            [itemKeys.class] = itemClasses.QUEST,
        },
    }
end
