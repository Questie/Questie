---@class QuestieItemBlacklist
local QuestieItemBlacklist = QuestieLoader:CreateModule("QuestieItemBlacklist")

---@return table<ItemId, boolean>
function QuestieItemBlacklist:Load()
    return {
        [765] = true, -- silverleaf
        [774] = true, -- malachite
        [785] = true, -- mageroyal
        [929] = true, -- Healing Potion
        [1206] = true, -- moss agate
        [1210] = true, -- shadowgem
        [1529] = true, -- jade
        [1705] = true, -- lesser moonstone
        [2447] = true, -- peacebloom
        [2449] = true, -- earthroot
        [2450] = true, -- briarthorn
        [2452] = true, -- swiftthistle
        [2453] = true, -- bruiseweed
        [2455] = true, -- Minor Mana Potion
        [2589] = true, -- linen cloth
        [2592] = true, -- wool cloth
        [2842] = true, -- Silver Bar
        [2997] = true, -- bolt of wool
        [3355] = true, -- wild steelbloom
        [3356] = true, -- kingsblood
        [3357] = true, -- liferoot
        [3358] = true, -- khadgar's whisker
        [3369] = true, -- grave moss
        [3818] = true, -- fadeleaf
        [3819] = true, -- wintersbite
        [3820] = true, -- stranglekelp
        [3821] = true, -- goldthorn
        [3864] = true, -- citrine
        [4306] = true, -- silk cloth
        [4338] = true, -- mageweave
        [4625] = true, -- firebloom
        [5056] = true, -- root sample
        [7079] = true, -- globe of water
        [7909] = true, -- aquamarine
        [7910] = true, -- star ruby
        [8153] = true, -- wildvine
        [8244] = true, -- flawless-draenethyst-sphere
        [8831] = true, -- purple lotus
        [8836] = true, -- arthas tears
        [8838] = true, -- sungrass
        [8839] = true, -- blindweed
        [8845] = true, -- ghost mushroom
        [8846] = true, -- gromsblood
        [8932] = true, -- Alterac Swiss
        [10561] = true, -- Mithril Casing
        [10593] = true, -- imperfect-draenethyst-fragment
        [12207] = true, -- giant egg
        [12361] = true, -- blue sapphire
        [12363] = true, -- arcane crystal
        [12364] = true, -- huge emerald
        [12799] = true, -- large opal
        [12800] = true, -- azerothian diamond
        [13422] = true, -- stonescale-eel
        [13444] = true, -- major mana potion
        [13446] = true, -- Major Healing Potion
        [13463] = true, -- dreamfoil
        [13464] = true, -- golden sansam
        [13465] = true, -- mountain silversage
        [13466] = true, -- plaguebloom
        [13467] = true, -- icecap
        [13468] = true, -- black lotus
        [14047] = true, -- runecloth
        [14048] = true, -- bolt of runecloth
        [14344] = true, -- large brilliant shard
        [18335] = true, -- Pristine Black Diamond

        -- stranglethorn pages
        [2725] = true,
        [2728] = true,
        [2730] = true,
        [2732] = true,
        [2734] = true,
        [2735] = true,
        [2738] = true,
        [2740] = true,
        [2742] = true,
        [2744] = true,
        [2745] = true,
        [2748] = true,
        [2749] = true,
        [2750] = true,
        [2751] = true,

        -- shredder operating manual
        [16645] = true,
        [16646] = true,
        [16647] = true,
        [16648] = true,
        [16649] = true,
        [16650] = true,
        [16651] = true,
        [16652] = true,
        [16653] = true,
        [16654] = true,
        [16655] = true,
        [16656] = true,

        --zul'gurub coins and bijous
        [19698] = true,
        [19699] = true,
        [19700] = true,
        [19701] = true,
        [19702] = true,
        [19703] = true,
        [19704] = true,
        [19705] = true,
        [19706] = true,
        [19707] = true,
        [19708] = true,
        [19709] = true,
        [19710] = true,
        [19711] = true,
        [19712] = true,
        [19713] = true,
        [19714] = true,
        [19715] = true,

        --ahn'qiraj scarabs and idols
        [20858] = true,
        [20859] = true,
        [20860] = true,
        [20861] = true,
        [20862] = true,
        [20863] = true,
        [20864] = true,
        [20865] = true,
        [20866] = true,
        [20867] = true,
        [20868] = true,
        [20869] = true,
        [20870] = true,
        [20871] = true,
        [20872] = true,
        [20873] = true,
        [20874] = true,
        [20875] = true,
        [20876] = true,
        [20877] = true,
        [20878] = true,
        [20879] = true,
        [20889] = true,

        --Tier 0.5 & Phase 5
        [4265] = true, -- Heavy Armour Kit
        [15564] = true, -- Rugged Armour Kit
        [20520] = true, -- Dark Rune
        [8464] = true, -- Wildheart Belt, Druid Tier 0.5
        [235250] = true, -- Wildheart Gloves, Druid Tier 0.5
        [248320] = true, -- Wildheart Bracers, Druid Tier 0.5
        [8636] = true, -- Beaststalker's Gloves, Hunter Tier 0.5
        [69159] = true, -- Beaststalker's Belt, Hunter Tier 0.5
        [210164] = true, -- Beaststalker's Bindings, Hunter Tier 0.5
        [8516] = true, -- Malefic Bracers, Mage Tier 0.5
        [50953] = true, -- Magister's Belt, Mage Tier 0.5
        [68436] = true, -- Magister's Gloves, Mage Tier 0.5
        [21287] = true, -- Lightforge Belt, Paladin Tier 0.5
        [89142] = true, -- Lightforge Gauntlets, Paladin Tier 0.5
        [89144] = true, -- Lightforge Bracers, Paladin Tier 0.5
        [13005] = true, -- Devout Bracers, Priest Tier 0.5
        [67995] = true, -- Devout Belt, Priest Tier 0.5
        [177441] = true, -- Devout Gloves, Priest Tier 0.5
        [9672] = true, -- Shadowcraft Bracers, Rogue Tier 0.5
        [56369] = true, -- Shadowcraft Belt, Rogue Tier 0.5
        [902488] = true, -- Shadowcraft Gloves, Rogue Tier 0.5
        [9805] = true, -- Gauntlets of Elements, Shaman Tier 0.5
        [57474] = true, -- Bindings of Elements, Shaman Tier 0.5
        [89415] = true, -- Cord of Elements, Shaman Tier 0.5
        [8641] = true, -- Dreadmist Belt, , Warlock Tier 0.5
        [9814] = true, -- Dreadmist Wraps, , Warlock Tier 0.5
        [60468] = true, -- Dreadmist Bracers, Warlock Tier 0.5
        [7849] = true, -- Belt of Valor, , Warrior Tier 0.5
        [8371] = true, -- Gauntlets of Valor, Warrior Tier 0.5
        [68435] = true, -- Bracers of Valor, Warrior Tier 0.5

        -- Phase 6
        [12811] = true, -- righteous orb
        [22525] = true, -- crypt fiend parts
        [22526] = true, -- bone fragments
        [22527] = true, -- core of elements
        [22528] = true, -- dark iron scraps
        [22529] = true, -- savage frond

        -- TBC Phase 1
        [21887] = true, -- Knothide Leather
        [22445] = true, -- Arcane Dust
        [22572] = true, -- Mote of Air
        [22573] = true, -- Mote of Earth
        [22574] = true, -- Mote of Fire
        [22575] = true, -- Mote of Life
        [22576] = true, -- Mote of Mana
        [22577] = true, -- Mote of Shadow
        [22578] = true, -- Mote of Water
        [22786] = true, -- Dreaming Glory
        [22790] = true, -- Ancient Lichen
        [22829] = true, -- Super Healing Potion
        [22832] = true, -- Super Mana Potion
        [23445] = true, -- Fel Iron Bar
        [23793] = true, -- Heavy Knothide Leather
        [24246] = true, -- Sanguine Hibiscus
        [24368] = true, -- Coilfang Armaments
        [24401] = true, -- Unidentified Plant Parts
        [26042] = true, -- Oshu'gun Crystal Powder Sample
        [26043] = true, -- Oshu'gun Crystal Powder Sample
        [29425] = true, -- Mark of Kiljaeden
        [29426] = true, -- Firewing Signet
        [29739] = true, -- Arcane Tome
        [29740] = true, -- Fel Armament
        [30809] = true, -- Mark of Sargeras
        [30810] = true, -- Sunfury Signet
        [32569] = true, -- Apexis Shard
    }
end
