---@class QuestieItemDropCorrections
local QuestieItemDropCorrections = QuestieLoader:CreateModule("QuestieItemDropCorrections")
-------------------------
--Import modules.
-------------------------
---@type DropDB
local DropDB = QuestieLoader:ImportModule("DropDB")

local DropKeys = DropDB.correctionKeys

  -- These tables contain manual drop corrections.
  --
  -- Use the following format:
  -- [itemID] = { -- Item Name
  --    [npcID] = 80.0,
  -- }
  --
  -- This example would be an 80% drop rate.
  --
  -- Corrections propagate up to the current expansion. For instance, if you make a correction in Era, that
  -- correction will be loaded in MoP unless an expansion after Era made a different correction for the same ID.
  --
  -- This is the same way our normal database corrections system behaves as well.
  --
  -- You can also use reference corrections. For instance:
  --
  -- [itemID] = { -- Item Name
  --    [npcID] = DropDB.correctionKeys.WOWHEAD,
  -- }
  --
  -- will point to the currently loaded Wowhead data for that item:NPC pair, if it exists.
  -- Using a reference correction in an earlier expansion will propagate to later ones, pointing to their own DBs.
  -- For instance, if you put the above example into Era corrections, but loaded up MoP, it would show MoP Wowhead data,
  -- regardless of whatever data exists in the MoP pserver DB.

QuestieItemDropCorrections.Era = {
    [884] = { -- Ghoul Rib
        [3] = DropKeys.WOWHEAD,
        [210] = DropKeys.WOWHEAD,
        [570] = DropKeys.WOWHEAD,
        [604] = DropKeys.WOWHEAD,
        [948] = DropKeys.WOWHEAD,
    },
    [1129] = { -- Ghoul Fang
        [3] = DropKeys.WOWHEAD,
        [210] = DropKeys.WOWHEAD,
        [570] = DropKeys.WOWHEAD,
        [604] = DropKeys.WOWHEAD,
        [948] = DropKeys.WOWHEAD,
        [1270] = DropKeys.WOWHEAD,
    },
    [1130] = { -- Vial of Spider Venom
        [217] = DropKeys.WOWHEAD,
        [539] = DropKeys.WOWHEAD,
        [569] = DropKeys.WOWHEAD,
        [574] = DropKeys.WOWHEAD,
        [930] = DropKeys.WOWHEAD,
        [949] = DropKeys.WOWHEAD,
    },
    [1519] = { -- Bloodscalp Ear
        [587] = DropKeys.WOWHEAD,
        [588] = DropKeys.WOWHEAD,
        [595] = DropKeys.WOWHEAD,
        [597] = DropKeys.WOWHEAD,
        [660] = DropKeys.WOWHEAD,
        [671] = DropKeys.WOWHEAD,
        [694] = DropKeys.WOWHEAD,
        [697] = DropKeys.WOWHEAD,
        [699] = DropKeys.WOWHEAD,
        [701] = DropKeys.WOWHEAD,
        [702] = DropKeys.WOWHEAD,
    },
    [1598] = { -- Rot Blossom
        [202] = DropKeys.WOWHEAD,
        [531] = DropKeys.WOWHEAD,
    },
    [2378] = { -- Skeleton Finger
        [48] = DropKeys.WOWHEAD,
        [202] = DropKeys.WOWHEAD,
        [203] = DropKeys.WOWHEAD,
        [531] = DropKeys.WOWHEAD,
        [785] = DropKeys.WOWHEAD,
        [787] = DropKeys.WOWHEAD,
        [1110] = DropKeys.WOWHEAD,
    },
    [3297] = { -- Fel Moss
        [1988] = DropKeys.WOWHEAD,
        [1989] = 100,
    },
    [3348] = { -- Giant Crocolisk Skin
        [2089] = 100,
    },
    [3476] = { -- Gray Bear Tongue
        [2351] = DropKeys.WOWHEAD,
        [2354] = DropKeys.WOWHEAD,
        [2356] = DropKeys.WOWHEAD,
        [14280] = DropKeys.WOWHEAD,
    },
    [3477] = { -- Creeper Ichor
        [2348] = DropKeys.WOWHEAD,
        [2349] = DropKeys.WOWHEAD,
        [2350] = DropKeys.WOWHEAD,
        [14279] = DropKeys.WOWHEAD,
    },
    [3692] = { -- Hillsbrad Human Skull
        [232] = DropKeys.WOWHEAD,
        [2244] = DropKeys.WOWHEAD,
        [2260] = DropKeys.WOWHEAD,
        [2261] = DropKeys.WOWHEAD,
        [2264] = DropKeys.WOWHEAD,
        [2265] = DropKeys.WOWHEAD,
        [2266] = DropKeys.WOWHEAD,
        [2267] = DropKeys.WOWHEAD,
        [2268] = DropKeys.WOWHEAD,
        [2269] = DropKeys.WOWHEAD,
        [2270] = DropKeys.WOWHEAD,
        [2305] = DropKeys.WOWHEAD,
        [2335] = DropKeys.WOWHEAD,
        [2360] = DropKeys.WOWHEAD,
        [2387] = DropKeys.WOWHEAD,
        [2403] = DropKeys.WOWHEAD,
        [2404] = DropKeys.WOWHEAD,
        [2427] = DropKeys.WOWHEAD,
        [2428] = DropKeys.WOWHEAD,
        [2448] = DropKeys.WOWHEAD,
        [2449] = DropKeys.WOWHEAD,
        [2450] = DropKeys.WOWHEAD,
        [2451] = DropKeys.WOWHEAD,
        [2503] = DropKeys.WOWHEAD,
    },
    [3917] = { -- Singing Blue Crystal
        [674] = DropKeys.WOWHEAD,
        [675] = DropKeys.WOWHEAD,
        [676] = DropKeys.WOWHEAD,
        [677] = DropKeys.WOWHEAD,
        [4723] = DropKeys.WOWHEAD,
        [14492] = DropKeys.WOWHEAD,
    },
    [3918] = { -- Singing Crystal Shard
        [688] = DropKeys.WOWHEAD,
        [689] = DropKeys.WOWHEAD,
        [690] = DropKeys.WOWHEAD,
        [1550] = DropKeys.WOWHEAD,
        [1551] = DropKeys.WOWHEAD,
    },
    [5085] = { -- Bristleback Quilboar Tusk
        [3258] = 100,
        [3260] = 100,
        [3261] = 100,
        [3263] = 100,
    },
    [5233] = { -- Stone of Relu
        [1020] = 1.5,
        [1021] = 1.5,
        [1022] = 1.5,
        [1023] = 1.5,
    },
    [7267] = { -- Pristine Spider Silk
        [930] = 18,
        [949] = 100,
    },
    [10639] = { -- Hyacinth Mushroom
        [1988] = 80,
    },
    [15852] = { -- Kodo Horn
        [3234] = 100,
        [3236] = 100,
    },
}

QuestieItemDropCorrections.Tbc = {
    [22934] = { -- Lasher Sample
        [16517] = 76,
    },
    [23336] = { -- Helboar Blood Sample
        [16880] = DropKeys.WOWHEAD,
    },
    [23614] = { -- Red Snapper
        [17102] = 100,
    },
    [23676] = { -- Moongraze Stag Tenderloin
        [17200] = 100,
        [17201] = 100,
    },
    [23706] = { -- Arcane Fragment
        [16339] = 100,
    },
    [23849] = { -- Stillpine Grain
        [17190] = DropKeys.WOWHEAD,
        [17191] = DropKeys.WOWHEAD,
        [17192] = DropKeys.WOWHEAD,
        [17475] = DropKeys.WOWHEAD,
    },
    [24372] = { -- Diaphanous Wing
        [18132] = DropKeys.WOWHEAD,
        [18133] = DropKeys.WOWHEAD,
        [18283] = DropKeys.WOWHEAD,
        [20197] = DropKeys.WOWHEAD,
        [20198] = DropKeys.WOWHEAD,
    },
    [24426] = { -- Sporebat Eye
        [18128] = DropKeys.WOWHEAD,
        [18129] = DropKeys.WOWHEAD,
        [18280] = DropKeys.WOWHEAD,
        [20387] = DropKeys.WOWHEAD,
    },
    [24427] = { -- Fen Strider Tentacle
        [18134] = DropKeys.WOWHEAD,
        [18281] = DropKeys.WOWHEAD,
    },
    [24485] = { -- Marshlight Bleeder Venom
        [18133] = DropKeys.WOWHEAD,
        [20198] = DropKeys.WOWHEAD,
    },
    [25891] = { -- Pristine Shimmerscale Eel
        [18750] = DropKeys.WOWHEAD,
    },
    [28668] = { -- Aged Clefthoof Blubber
        [17133] = DropKeys.WOWHEAD,
    },
    [29161] = { -- Void Ridge Soul Shard
        [17014] = 100,
        [19527] = 100,
    },
    [29480] = { -- Parched Hydra Sample
        [20324] = DropKeys.WOWHEAD,
    },
    [29481] = { -- Withered Bog Lord Sample
        [19402] = DropKeys.WOWHEAD,
    },
    [30327] = { -- Bonechewer Blood
        [16876] = DropKeys.WOWHEAD,
        [16925] = DropKeys.WOWHEAD,
        [18952] = DropKeys.WOWHEAD,
        [19701] = DropKeys.WOWHEAD,
    },
    [31812] = { -- Doom Skull
        [21242] = DropKeys.WOWHEAD,
        [21285] = DropKeys.WOWHEAD,
    },
}

QuestieItemDropCorrections.Wotlk = {

}

QuestieItemDropCorrections.Cata = {

}

QuestieItemDropCorrections.MoP = {

}