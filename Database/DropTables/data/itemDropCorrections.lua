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
    [725] = { -- Gnoll Paw
        [98] = DropKeys.WOWHEAD,
        [117] = DropKeys.WOWHEAD,
        [123] = DropKeys.WOWHEAD,
        [124] = DropKeys.WOWHEAD,
        [125] = DropKeys.WOWHEAD,
        [452] = DropKeys.WOWHEAD,
        [453] = DropKeys.WOWHEAD,
        [500] = DropKeys.WOWHEAD,
        [501] = DropKeys.WOWHEAD,
        [506] = DropKeys.WOWHEAD,
        [1065] = DropKeys.WOWHEAD,
        [1426] = DropKeys.WOWHEAD,
    },
    [829] = { -- Red Leather Bandana
        [95] = DropKeys.WOWHEAD,
        [502] = DropKeys.WOWHEAD,
        [504] = DropKeys.WOWHEAD,
        [589] = DropKeys.WOWHEAD,
        [590] = DropKeys.WOWHEAD,
    },
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
    [1468] = { -- Murloc Fin
        [422] = DropKeys.WOWHEAD,
        [544] = DropKeys.WOWHEAD,
        [545] = DropKeys.WOWHEAD,
        [548] = DropKeys.WOWHEAD,
        [578] = DropKeys.WOWHEAD,
        [1024] = DropKeys.WOWHEAD,
        [1025] = DropKeys.WOWHEAD,
        [1026] = DropKeys.WOWHEAD,
        [1027] = DropKeys.WOWHEAD,
        [1028] = DropKeys.WOWHEAD,
        [1029] = DropKeys.WOWHEAD,
        [1083] = DropKeys.WOWHEAD,
        [1259] = DropKeys.WOWHEAD,
        [1418] = DropKeys.WOWHEAD,
        [3654] = DropKeys.WOWHEAD,
        [3737] = DropKeys.WOWHEAD,
        [3739] = DropKeys.WOWHEAD,
        [3740] = DropKeys.WOWHEAD,
        [3742] = DropKeys.WOWHEAD,
        [4818] = DropKeys.WOWHEAD,
        [4819] = DropKeys.WOWHEAD,
        [4820] = DropKeys.WOWHEAD,
        [6243] = DropKeys.WOWHEAD,
        [10643] = DropKeys.WOWHEAD,
        [14270] = DropKeys.WOWHEAD,
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
    [1894] = { -- Miners' Union Card
        [623] = DropKeys.WOWHEAD,
        [624] = DropKeys.WOWHEAD,
        [625] = DropKeys.WOWHEAD,
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
    [2676] = { -- Shimmerweed
        [1397] = DropKeys.WOWHEAD,
    },
    [3297] = { -- Fel Moss
        [1988] = DropKeys.WOWHEAD,
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
    [5026] = { -- Fire Tar
        [3267] = 75,
        [3268] = 75,
        [3269] = 75,
        [3271] = 75,
    },
    [5055] = { -- Intact Raptor Horn
        [3256] = DropKeys.WOWHEAD,
        [3257] = DropKeys.WOWHEAD,
        [5842] = DropKeys.WOWHEAD,
    },
    [5085] = { -- Bristleback Quilboar Tusk
        [3258] = 100,
        [3260] = 100,
        [3261] = 100,
        [3263] = 100,
    },
    [5170] = { -- Mossy Tumor
        [2027] = DropKeys.WOWHEAD,
        [2029] = DropKeys.WOWHEAD,
        [2030] = DropKeys.WOWHEAD,
    },
    [5233] = { -- Stone of Relu
        [1020] = 1.5,
        [1021] = 1.5,
        [1022] = 1.5,
        [1023] = 1.5,
    },
    [5366] = { -- Glowing Soul Gem
        [3725] = DropKeys.WOWHEAD,
        [3727] = DropKeys.WOWHEAD,
        [3728] = DropKeys.WOWHEAD,
        [3730] = DropKeys.WOWHEAD,
        [3879] = DropKeys.WOWHEAD,
    },
    [5669] = { -- Dust Devil Debris
        [832] = 50.0, -- not 100%, not 5%. Could be more than 50%
    },
    [6443] = { -- Deviate Hide
        [3630] = DropKeys.WOWHEAD,
        [3631] = DropKeys.WOWHEAD,
        [3632] = DropKeys.WOWHEAD,
        [3633] = DropKeys.WOWHEAD,
        [3634] = DropKeys.WOWHEAD,
        [3636] = DropKeys.WOWHEAD,
        [3637] = DropKeys.WOWHEAD,
        [3641] = DropKeys.WOWHEAD,
        [3653] = DropKeys.WOWHEAD,
        [3654] = DropKeys.WOWHEAD,
        [3674] = DropKeys.WOWHEAD,
        [5048] = DropKeys.WOWHEAD,
        [5053] = DropKeys.WOWHEAD,
        [5056] = DropKeys.WOWHEAD,
        [5755] = DropKeys.WOWHEAD,
        [5756] = DropKeys.WOWHEAD,
        [5761] = DropKeys.WOWHEAD,
        [5762] = DropKeys.WOWHEAD,
        [5775] = DropKeys.WOWHEAD,
        [5912] = DropKeys.WOWHEAD,
        [8886] = DropKeys.WOWHEAD,
    },
    [6652] = { -- Reagent Pouch
        [3199] = 75,
    },
    [6915] = { -- Large Soran'ruk Fragment
        [3855] = 20, -- empyrical value
    },
    [7267] = { -- Pristine Spider Silk
        [930] = 18,
        [949] = 100,
    },
    [7291] = { -- Infernal Orb
        [4668] = 100,
    },
    [10639] = { -- Hyacinth Mushroom
        [1988] = 80,
    },
    [11479] = { -- Un'Goro Stomper Pelt
        [6513] = DropKeys.WOWHEAD,
    },
    [11829] = { -- Un'Goro Ash
        [6520] = 100.0,
        [6521] = 100.0,
        [9376] = 10.0,
        [14460] = 100.0,
        [14461] = 10.0,
    },
    [15852] = { -- Kodo Horn
        [3234] = 100,
        [3236] = 100,
    },
    [20373] = { -- Stonelash Scorpid Stinger
        [11735] = DropKeys.WOWHEAD,
    },
    [20374] = { -- Stonelash Pincer Stinger
        [11736] = DropKeys.WOWHEAD,
    },
    [20375] = { -- Stonelash Flayer Stinger
        [11737] = DropKeys.WOWHEAD,
    },
    [20376] = { -- Sand Skitterer Fang
        [11738] = DropKeys.WOWHEAD,
    },
    [20377] = { -- Rock Stalker Fang
        [11739] = DropKeys.WOWHEAD,
    },
    [21108] = { -- Draconic for Dummies (Chapter VI)
        [10184] = 100,
    },
    [21110] = { -- Draconic for Dummies (Chapter VIII)
        [11502] = 100,
    },
    [190232] = { -- Withered Scarf
        [3782] = 5, -- super bad drop rate, wowhead shows 3%. it's somewhere between 5-10%
        [3784] = 5, -- super bad drop rate, wowhead shows 3%. it's somewhere between 5-10%
    },
}

QuestieItemDropCorrections.Tbc = {
    [6487] = { -- Vile Familiar Head
        [3101] = 100,
    },
    [20934] = { -- Wraith Essence
        [15273] = 100,
    },
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
    [23733] = { -- Ritual Torch
        [17189] = 80,
    },
    [23849] = { -- Stillpine Grain
        [17190] = DropKeys.WOWHEAD,
        [17191] = DropKeys.WOWHEAD,
        [17192] = DropKeys.WOWHEAD,
        [17475] = DropKeys.WOWHEAD,
    },
    [24279] = { -- Vicious Teromoth Sample
        [18437] = DropKeys.WOWHEAD,
    },
    [24372] = { -- Diaphanous Wing
        [18132] = DropKeys.WOWHEAD,
        [18133] = DropKeys.WOWHEAD,
        [18283] = DropKeys.WOWHEAD,
        [20197] = DropKeys.WOWHEAD,
        [20198] = DropKeys.WOWHEAD,
    },
    [24374] = { -- Eel Filet
        [18138] = DropKeys.WOWHEAD,
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
    [24473] = { -- Enraged Crusher Core
        [18062] = 100,
    },
    [24485] = { -- Marshlight Bleeder Venom
        [18133] = DropKeys.WOWHEAD,
        [20198] = DropKeys.WOWHEAD,
    },
    [25461] = { -- Book of Forgotten Names
        [18472] = 100,
    },
    [25462] = { -- Tome of Dusk
        [16807] = 100,
    },
    [25463] = { -- Pair of Ivory Tusks
        [18334] = 100,
    },
    [25891] = { -- Pristine Shimmerscale Eel
        [18750] = DropKeys.WOWHEAD,
    },
    [28667] = { -- Flawless Greater Windroc Beak
        [17129] = DropKeys.WOWHEAD,
    },
    [28668] = { -- Aged Clefthoof Blubber
        [17133] = DropKeys.WOWHEAD,
    },
    [29161] = { -- Void Ridge Soul Shard
        [17014] = 100,
        [19527] = 100,
    },
    [29163] = { -- Raw Farahlite
        [18885] = 100,
        [18886] = 100,
        [20202] = 100,
    },
    [29480] = { -- Parched Hydra Sample
        [20324] = DropKeys.WOWHEAD,
    },
    [29481] = { -- Withered Bog Lord Sample
        [19402] = DropKeys.WOWHEAD,
    },
    [29591] = { -- Prepared Ethereum Wrapping
        [20458] = DropKeys.WOWHEAD,
        [20459] = DropKeys.WOWHEAD,
    },
    [30184] = { -- Thunderlord Dire Wolf Tail
        [20748] = 100,
    },
    [30327] = { -- Bonechewer Blood
        [16876] = DropKeys.WOWHEAD,
        [16925] = DropKeys.WOWHEAD,
        [18952] = DropKeys.WOWHEAD,
        [19701] = DropKeys.WOWHEAD,
    },
    [30743] = { -- Proto-Nether Drake Essence
        [20021] = 100,
    },
    [30782] = { -- Adolescent Nether Drake Essence
        [20021] = 100,
    },
    [30783] = { -- Mature Nether Drake Essence
        [20021] = 100,
    },
    [30798] = { -- Extra Sharp Daggermaw Tooth
        [20751] = DropKeys.WOWHEAD,
    },
    [30819] = { -- Felfire Spleen
        [21408] = DropKeys.WOWHEAD,
    },
    [30867] = { -- Overdeveloped Felfire Gizzard
        [21462] = DropKeys.WOWHEAD,
    },
    [31119] = { -- Wyrmcult Net
        [21809] = DropKeys.WOWHEAD,
    },
    [31132] = { -- Crust Burster Venom Gland
        [21380] = DropKeys.WOWHEAD,
        [21381] = DropKeys.WOWHEAD,
        [21849] = DropKeys.WOWHEAD,
        [22466] = DropKeys.WOWHEAD,
    },
    [31316] = { -- Lianthe's Key
        [19792] = DropKeys.WOWHEAD,
        [19796] = DropKeys.WOWHEAD,
        [19806] = DropKeys.WOWHEAD,
    },
    [31812] = { -- Doom Skull
        [21242] = DropKeys.WOWHEAD,
        [21285] = DropKeys.WOWHEAD,
    },
    [31814] = { -- Mature Bone Sifter Carcass
        [22482] = 100,
    },
}

QuestieItemDropCorrections.Wotlk = {

}

QuestieItemDropCorrections.Cata = {

}

QuestieItemDropCorrections.MoP = {
    [97530] = { -- Kor'kron Lumber
        [70997] = 100,
        [70998] = 100,
        [70999] = 100,
        [71001] = 100,
    },
    [97543] = { -- Kor'kron Stone
        [71007] = 100,
        [71009] = 100,
        [71187] = 100,
        [71188] = 100,
    },
    [97544] = { -- Kor'kron Oil
        [71000] = 100,
        [71002] = 100,
        [71005] = 100,
        [71006] = 100,
    },
    [97545] = { -- Kor'kron Meat
        [71010] = 100,
        [71011] = 100,
        [71012] = 100,
        [73590] = 100,
    },

}