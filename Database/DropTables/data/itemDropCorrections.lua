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
}

QuestieItemDropCorrections.Wotlk = {

}

QuestieItemDropCorrections.Cata = {

}

QuestieItemDropCorrections.MoP = {

}