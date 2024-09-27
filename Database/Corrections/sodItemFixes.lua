---@type SeasonOfDiscovery
local SeasonOfDiscovery = QuestieLoader:ImportModule("SeasonOfDiscovery")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")

function SeasonOfDiscovery:LoadItems()
    local itemKeys = QuestieDB.itemKeys
    local itemClasses = QuestieDB.itemClasses

    return {
        [5359] = { -- Lorgalis Manuscript
            [itemKeys.relatedQuests] = {78923}, -- SoD Knowledge in the Deeps
        },
        [5881] = { -- Head of Kelris
            [itemKeys.relatedQuests] = {78921,78922}, -- SoD Blackfathom Villainy A,H
            [itemKeys.npcDrops] = {209678}, -- now drops from raid version of npc
        },
        [5952] = { -- Corrupted Brain Stem
            [itemKeys.relatedQuests] = {78926}, -- SoD Researching the Corruption
            [itemKeys.npcDrops] = {216660, 4788, 4789, 4803, 4802, 4805, 4807, 4799, 4798, 204645, 216662, 4831, 216659, 216661, 204068}, -- now drops from raid version of npc
        },
        [204806] = { -- Rune of Victory Rush
            [itemKeys.npcDrops] = {706,946,1986},
        },
        [205944] = { -- Reciprocal Epiphany
            [itemKeys.npcDrops] = {204937},
        },
        [206157] = { -- Seaforium Mining Charge
            [itemKeys.objectDrops] = {403041},
        },
        [206170] = { -- Windfury Cone
            [itemKeys.objectDrops] = {403105},
        },
        [206264] = { -- Rune of Inspiration
            [itemKeys.npcDrops] = {204937},
        },
        [206469] = { -- Prairie Flower
            [itemKeys.objectDrops] = {403718},
        },
        [208085] = { -- Scarlet Lieutenant Signet Ring
            [itemKeys.npcDrops] = {1662,1664,1665},
        },
        [208609] = { -- Glade Flower
            [itemKeys.objectDrops] = {407247},
        },
        [208612] = { -- Severed Spider Head
            [itemKeys.npcDrops] = {1998,1999,2000,2001},
        },
        [208689] = { -- Ferocious Idol
            [itemKeys.npcDrops] = {98,117,500,1972,6788},
        },
        [208771] = { -- Rune of Blade Dance
            [itemKeys.objectDrops] = {407453,408718,414532},
        },
        [208772] = { -- Rune of Saber Slash
            [itemKeys.objectDrops] = {407457,407731,409131,414624},
        },
        [209693] = { -- Alliance Blackfathom Pearl
            [itemKeys.relatedQuests] = {78916},
            [itemKeys.startQuest] = 78916,
        },
        [209846] = { -- Secrets of the Dreamers
            [itemKeys.objectDrops] = {409692},
        },
        [210026] = { -- Symbol of the Third Owl
            [itemKeys.objectDrops] = {409942,409949},
        },
        [210044] = { -- Symbol of the First Owl
            [itemKeys.objectDrops] = {410220},
        },
        [210055] = { -- Hillsbrad Human Bones
            [itemKeys.npcDrops] = {2265,2266,2267,2268,2360,2387},
        },
        [210195] = { -- Unbalanced Idol
            [itemKeys.npcDrops] = {1769,1770,1779},
        },
        [210589] = { -- Echo of the Ancestors
            [itemKeys.npcDrops] = {204937},
        },
        [210955] = { -- Scarlet Initiate's Uniform
            [itemKeys.objectDrops] = {412147},
        },
        [211452] = { -- Horde Blackfathom Pearl
            [itemKeys.relatedQuests] = {78917},
            [itemKeys.startQuest] = 78917,
        },
        [211454] = { -- Horde Strange Water Globe (starts Baron Aquanis)
            [itemKeys.relatedQuests] = {78920},
            [itemKeys.startQuest] = 78920,
        },
        [211818] = { -- Alliance Strange Water Globe (required for but does not start Baron Aquanis)
            [itemKeys.relatedQuests] = {79099},
            [itemKeys.startQuest] = nil,
        },
        [212347] = { -- Illari's Key
            [itemKeys.npcDrops] = {215655},
        },
        [213446] = { -- Tarnished Prayer Bead III
            [itemKeys.npcDrops] = {2552,2553,2554,2555,2556,2557,2562,2564,2566,2569,2570,2572,2573,2574,2575,2586,2587,2588,2589,2590,2618,2619,4062},
        },
        [215376] = { -- Crusader's Mace
            [itemKeys.npcDrops] = {4281,4283,4286,4287,4288,4289,4290,4291,4292,4293,4294,4295,4296,4297,4298,4299,4300,4301,4302,4303,4306,4540},
        },
        [216635] = { -- Spent Voidcore
            [itemKeys.npcDrops] = {5335,5336,5337},
        },
        [216946] = { -- Glittering Dalaran Relic
            [itemKeys.npcDrops] = {900000},
        },
        [216947] = { -- Whirring Dalaran Relic
            [itemKeys.npcDrops] = {900001},
        },
        [216948] = { -- Odd Dalaran Relic
            [itemKeys.npcDrops] = {900002},
        },
        [216949] = { -- Heavy Dalaran Relic
            [itemKeys.npcDrops] = {900003},
        },
        [216950] = { -- Creepy Dalaran Relic
            [itemKeys.npcDrops] = {900004},
        },
        [216951] = { -- Slippery Dalaran Relic
            [itemKeys.npcDrops] = {900005},
        },
        [219759] = { -- Charla's Field Report
            [itemKeys.npcDrops] = {221472},
        },
        [219770] = { -- Gemeron's Field Report
            [itemKeys.npcDrops] = {221482},
        },
        [219771] = { -- Thandros' Field Report
            [itemKeys.npcDrops] = {221484},
        },
        [219772] = { -- Fallia's Field Report
            [itemKeys.npcDrops] = {221483},
        },
        [219776] = { -- Intelligence Report: Vul'gol Ogre Mound
            [itemKeys.npcDrops] = {221222},
        },
        [219778] = { -- Intelligence Report: Rotting Orchard
            [itemKeys.npcDrops] = {221221},
        },
        [219803] = { -- Intelligence Report: Yorgen Farmstead
            [itemKeys.npcDrops] = {221220},
        },
        [219924] = { -- Intelligence Report: Forest Song
            [itemKeys.npcDrops] = {221271},
        },
        [219925] = { -- Intelligence Report: Satyrnaar
            [itemKeys.npcDrops] = {221272},
        },
        [219926] = { -- Intelligence Report: Warsong Lumber Camp
            [itemKeys.npcDrops] = {221273},
        },
        [219928] = { -- Intelligence Report: Agol'watha
            [itemKeys.npcDrops] = {221353},
        },
        [219937] = { -- Intelligence Report: Shaol'watha
            [itemKeys.npcDrops] = {221352},
        },
        [219938] = { -- Intelligence Report: Skulk Rock
            [itemKeys.npcDrops] = {221351},
        },
        [219957] = { -- Intelligence Report: Oneiros
            [itemKeys.npcDrops] = {221401},
        },
        [219958] = { -- Intelligence Report: Twin Colossals
            [itemKeys.npcDrops] = {221402},
        },
        [219959] = { -- Intelligence Report: Ruins of Ravenwind
            [itemKeys.npcDrops] = {221404},
        },
        [220345] = { -- Sanguine Sorcery
            [itemKeys.objectDrops] = {441247},
        },
        [220349] = { -- Stonewrought Design
            [itemKeys.objectDrops] = {441251},
        },
        [221326] = { -- Sacred Stag Heart
            [itemKeys.class] = itemClasses.QUEST,
        },
        [226122] = { -- Dalton's Horn
            [itemKeys.class] = itemClasses.QUEST,
        },
        [226523] = { -- Dalton's Horn
            [itemKeys.class] = itemClasses.QUEST,
        },
        [226545] = { -- Dalton's Horn
            [itemKeys.class] = itemClasses.QUEST,
        },
        [227768] = { -- Dreamjuice
            [itemKeys.class] = itemClasses.QUEST,
        },
        [228141] = { -- Necromancy 101
            [itemKeys.objectDrops] = {463211},
        },
        [229416] = { -- Warm Fur
            [itemKeys.npcDrops] = {7445},
        },
    }
end
