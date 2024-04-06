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
        [219444] = {
            [itemKeys.name] = "Dreamroot",
            [itemKeys.npcDrops] = nil,
            [itemKeys.objectDrops] = {439627},
            [itemKeys.itemDrops] = nil,
            [itemKeys.vendors] = nil,
            [itemKeys.startQuest] = nil,
        },
        [219445] = {
            [itemKeys.name] = "Fool's Gold Dust",
            [itemKeys.npcDrops] = nil,
            [itemKeys.objectDrops] = {439628},
            [itemKeys.itemDrops] = nil,
            [itemKeys.vendors] = nil,
            [itemKeys.startQuest] = nil,
        },
        [219446] = {
            [itemKeys.name] = "Dream-Infused Dragonscale",
            [itemKeys.npcDrops] = {221259,221260,221265},
            [itemKeys.objectDrops] = nil,
            [itemKeys.itemDrops] = nil,
            [itemKeys.vendors] = nil,
            [itemKeys.startQuest] = nil,
        },
        [219447] = {
            [itemKeys.name] = "Dream-Touched Dragon Egg",
            [itemKeys.npcDrops] = nil,
            [itemKeys.objectDrops] = {441124},
            [itemKeys.itemDrops] = nil,
            [itemKeys.vendors] = nil,
            [itemKeys.startQuest] = nil,
        },
        [219448] = {
            [itemKeys.name] = "Dreamengine",
            [itemKeys.npcDrops] = nil,
            [itemKeys.objectDrops] = {441128},
            [itemKeys.itemDrops] = nil,
            [itemKeys.vendors] = nil,
            [itemKeys.startQuest] = nil,
        },
        [219449] = {
            [itemKeys.name] = "Azsharan Prophecy",
            [itemKeys.npcDrops] = nil,
            [itemKeys.objectDrops] = {441129},
            [itemKeys.itemDrops] = nil,
            [itemKeys.vendors] = nil,
            [itemKeys.startQuest] = nil,
        },
        [219770] = {
            [itemKeys.name] = "Gemeron's Field Report",
            [itemKeys.npcDrops] = {221482},
            [itemKeys.objectDrops] = nil,
            [itemKeys.itemDrops] = nil,
            [itemKeys.vendors] = nil,
            [itemKeys.startQuest] = nil,
        },
        [219773] = {
            [itemKeys.name] = "Mission Brief: Ashenvale",
            [itemKeys.npcDrops] = nil,
            [itemKeys.objectDrops] = nil,
            [itemKeys.itemDrops] = nil,
            [itemKeys.vendors] = nil,
            [itemKeys.startQuest] = nil,
        },
        [219924] = {
            [itemKeys.name] = "Intelligence Report: Forest Song",
            [itemKeys.npcDrops] = {221271},
            [itemKeys.objectDrops] = nil,
            [itemKeys.itemDrops] = nil,
            [itemKeys.vendors] = nil,
            [itemKeys.startQuest] = nil,
        },
        [219925] = {
            [itemKeys.name] = "Intelligence Report: Satyrnaar",
            [itemKeys.npcDrops] = {221272},
            [itemKeys.objectDrops] = nil,
            [itemKeys.itemDrops] = nil,
            [itemKeys.vendors] = nil,
            [itemKeys.startQuest] = nil,
        },
        [219926] = {
            [itemKeys.name] = "Intelligence Report: Warsong Lumber Camp",
            [itemKeys.npcDrops] = {221273},
            [itemKeys.objectDrops] = nil,
            [itemKeys.itemDrops] = nil,
            [itemKeys.vendors] = nil,
            [itemKeys.startQuest] = nil,
        },
        [219999] = {
            [itemKeys.name] = "Nightmare Incursions: Ashenvale Mission I",
            [itemKeys.npcDrops] = nil,
            [itemKeys.objectDrops] = nil,
            [itemKeys.itemDrops] = {219773},
            [itemKeys.vendors] = nil,
            [itemKeys.startQuest] = 81768,
        },
        [220000] = {
            [itemKeys.name] = "Nightmare Incursions: Ashenvale Mission II",
            [itemKeys.npcDrops] = nil,
            [itemKeys.objectDrops] = nil,
            [itemKeys.itemDrops] = {219773},
            [itemKeys.vendors] = nil,
            [itemKeys.startQuest] = 81769,
        },
        [220001] = {
            [itemKeys.name] = "Nightmare Incursions: Ashenvale Mission III",
            [itemKeys.npcDrops] = nil,
            [itemKeys.objectDrops] = nil,
            [itemKeys.itemDrops] = {219773},
            [itemKeys.vendors] = nil,
            [itemKeys.startQuest] = 81770,
        },
        [220002] = {
            [itemKeys.name] = "Nightmare Incursions: Ashenvale Mission IV",
            [itemKeys.npcDrops] = nil,
            [itemKeys.objectDrops] = nil,
            [itemKeys.itemDrops] = {219773},
            [itemKeys.vendors] = nil,
            [itemKeys.startQuest] = 81771,
        },
        [220003] = {
            [itemKeys.name] = "Nightmare Incursions: Ashenvale Mission V",
            [itemKeys.npcDrops] = nil,
            [itemKeys.objectDrops] = nil,
            [itemKeys.itemDrops] = {219773},
            [itemKeys.vendors] = nil,
            [itemKeys.startQuest] = 81772,
        },
        [220004] = {
            [itemKeys.name] = "Nightmare Incursions: Ashenvale Mission VI",
            [itemKeys.npcDrops] = nil,
            [itemKeys.objectDrops] = nil,
            [itemKeys.itemDrops] = {219773},
            [itemKeys.vendors] = nil,
            [itemKeys.startQuest] = 81773,
        },
        [220005] = {
            [itemKeys.name] = "Nightmare Incursions: Ashenvale Mission VII",
            [itemKeys.npcDrops] = nil,
            [itemKeys.objectDrops] = nil,
            [itemKeys.itemDrops] = {219773},
            [itemKeys.vendors] = nil,
            [itemKeys.startQuest] = 81774,
        },
        [220006] = {
            [itemKeys.name] = "Nightmare Incursions: Ashenvale Mission VIII",
            [itemKeys.npcDrops] = nil,
            [itemKeys.objectDrops] = nil,
            [itemKeys.itemDrops] = {219773},
            [itemKeys.vendors] = nil,
            [itemKeys.startQuest] = 81775,
        },
        [220007] = {
            [itemKeys.name] = "Nightmare Incursions: Ashenvale Mission IX",
            [itemKeys.npcDrops] = nil,
            [itemKeys.objectDrops] = nil,
            [itemKeys.itemDrops] = {219773},
            [itemKeys.vendors] = nil,
            [itemKeys.startQuest] = 81776,
        },
        [220008] = {
            [itemKeys.name] = "Nightmare Incursions: Ashenvale Mission X",
            [itemKeys.npcDrops] = nil,
            [itemKeys.objectDrops] = nil,
            [itemKeys.itemDrops] = {219773},
            [itemKeys.vendors] = nil,
            [itemKeys.startQuest] = 81777,
        },
        [220009] = {
            [itemKeys.name] = "Nightmare Incursions: Ashenvale Mission XI",
            [itemKeys.npcDrops] = nil,
            [itemKeys.objectDrops] = nil,
            [itemKeys.itemDrops] = {219773},
            [itemKeys.vendors] = nil,
            [itemKeys.startQuest] = 81778,
        },
        [220010] = {
            [itemKeys.name] = "Nightmare Incursions: Ashenvale Mission XII",
            [itemKeys.npcDrops] = nil,
            [itemKeys.objectDrops] = nil,
            [itemKeys.itemDrops] = {219773},
            [itemKeys.vendors] = nil,
            [itemKeys.startQuest] = 81779,
        },
        [220011] = {
            [itemKeys.name] = "Nightmare Incursions: Ashenvale Mission XIII",
            [itemKeys.npcDrops] = nil,
            [itemKeys.objectDrops] = nil,
            [itemKeys.itemDrops] = {219773},
            [itemKeys.vendors] = nil,
            [itemKeys.startQuest] = 81780,
        },
        [220012] = {
            [itemKeys.name] = "Nightmare Incursions: Ashenvale Mission XIV",
            [itemKeys.npcDrops] = nil,
            [itemKeys.objectDrops] = nil,
            [itemKeys.itemDrops] = {219773},
            [itemKeys.vendors] = nil,
            [itemKeys.startQuest] = 81781,
        },
        [220013] = {
            [itemKeys.name] = "Nightmare Incursions: Ashenvale Mission XV",
            [itemKeys.npcDrops] = nil,
            [itemKeys.objectDrops] = nil,
            [itemKeys.itemDrops] = {219773},
            [itemKeys.vendors] = nil,
            [itemKeys.startQuest] = 81782,
        },
        [220014] = {
            [itemKeys.name] = "Nightmare Incursions: Ashenvale Mission XVI",
            [itemKeys.npcDrops] = nil,
            [itemKeys.objectDrops] = nil,
            [itemKeys.itemDrops] = {219773},
            [itemKeys.vendors] = nil,
            [itemKeys.startQuest] = 81783,
        },
        [220015] = {
            [itemKeys.name] = "Nightmare Incursions: Ashenvale Mission XVII",
            [itemKeys.npcDrops] = nil,
            [itemKeys.objectDrops] = nil,
            [itemKeys.itemDrops] = {219773},
            [itemKeys.vendors] = nil,
            [itemKeys.startQuest] = 81784,
        },
        [220016] = {
            [itemKeys.name] = "Nightmare Incursions: Ashenvale Mission XVIII",
            [itemKeys.npcDrops] = nil,
            [itemKeys.objectDrops] = nil,
            [itemKeys.itemDrops] = {219773},
            [itemKeys.vendors] = nil,
            [itemKeys.startQuest] = 81785,
        },
        [220053] = {
            [itemKeys.name] = "Deputization Authorization: Ashenvale Mission I",
            [itemKeys.npcDrops] = nil,
            [itemKeys.objectDrops] = nil,
            [itemKeys.itemDrops] = {219773},
            [itemKeys.vendors] = nil,
            [itemKeys.startQuest] = nil,
        },
        [220054] = {
            [itemKeys.name] = "Deputization Authorization: Ashenvale Mission II",
            [itemKeys.npcDrops] = nil,
            [itemKeys.objectDrops] = nil,
            [itemKeys.itemDrops] = {219773},
            [itemKeys.vendors] = nil,
            [itemKeys.startQuest] = nil,
        },
        [220055] = {
            [itemKeys.name] = "Deputization Authorization: Ashenvale Mission III",
            [itemKeys.npcDrops] = nil,
            [itemKeys.objectDrops] = nil,
            [itemKeys.itemDrops] = {219773},
            [itemKeys.vendors] = nil,
            [itemKeys.startQuest] = nil,
        },
        [220056] = {
            [itemKeys.name] = "Deputization Authorization: Ashenvale Mission IV",
            [itemKeys.npcDrops] = nil,
            [itemKeys.objectDrops] = nil,
            [itemKeys.itemDrops] = {219773},
            [itemKeys.vendors] = nil,
            [itemKeys.startQuest] = nil,
        },
        [220057] = {
            [itemKeys.name] = "Deputization Authorization: Ashenvale Mission V",
            [itemKeys.npcDrops] = nil,
            [itemKeys.objectDrops] = nil,
            [itemKeys.itemDrops] = {219773},
            [itemKeys.vendors] = nil,
            [itemKeys.startQuest] = nil,
        },
        [220058] = {
            [itemKeys.name] = "Deputization Authorization: Ashenvale Mission VI",
            [itemKeys.npcDrops] = nil,
            [itemKeys.objectDrops] = nil,
            [itemKeys.itemDrops] = {219773},
            [itemKeys.vendors] = nil,
            [itemKeys.startQuest] = nil,
        },
        [220059] = {
            [itemKeys.name] = "Deputization Authorization: Ashenvale Mission VII",
            [itemKeys.npcDrops] = nil,
            [itemKeys.objectDrops] = nil,
            [itemKeys.itemDrops] = {219773},
            [itemKeys.vendors] = nil,
            [itemKeys.startQuest] = nil,
        },
        [220060] = {
            [itemKeys.name] = "Deputization Authorization: Ashenvale Mission VIII",
            [itemKeys.npcDrops] = nil,
            [itemKeys.objectDrops] = nil,
            [itemKeys.itemDrops] = {219773},
            [itemKeys.vendors] = nil,
            [itemKeys.startQuest] = nil,
        },
        [220061] = {
            [itemKeys.name] = "Deputization Authorization: Ashenvale Mission IX",
            [itemKeys.npcDrops] = nil,
            [itemKeys.objectDrops] = nil,
            [itemKeys.itemDrops] = {219773},
            [itemKeys.vendors] = nil,
            [itemKeys.startQuest] = nil,
        },
        [220062] = {
            [itemKeys.name] = "Deputization Authorization: Ashenvale Mission X",
            [itemKeys.npcDrops] = nil,
            [itemKeys.objectDrops] = nil,
            [itemKeys.itemDrops] = {219773},
            [itemKeys.vendors] = nil,
            [itemKeys.startQuest] = nil,
        },
        [220063] = {
            [itemKeys.name] = "Deputization Authorization: Ashenvale Mission XI",
            [itemKeys.npcDrops] = nil,
            [itemKeys.objectDrops] = nil,
            [itemKeys.itemDrops] = {219773},
            [itemKeys.vendors] = nil,
            [itemKeys.startQuest] = nil,
        },
        [220064] = {
            [itemKeys.name] = "Deputization Authorization: Ashenvale Mission XII",
            [itemKeys.npcDrops] = nil,
            [itemKeys.objectDrops] = nil,
            [itemKeys.itemDrops] = {219773},
            [itemKeys.vendors] = nil,
            [itemKeys.startQuest] = nil,
        },
        [220065] = {
            [itemKeys.name] = "Deputization Authorization: Ashenvale Mission XIII",
            [itemKeys.npcDrops] = nil,
            [itemKeys.objectDrops] = nil,
            [itemKeys.itemDrops] = {219773},
            [itemKeys.vendors] = nil,
            [itemKeys.startQuest] = nil,
        },
        [220066] = {
            [itemKeys.name] = "Deputization Authorization: Ashenvale Mission XIV",
            [itemKeys.npcDrops] = nil,
            [itemKeys.objectDrops] = nil,
            [itemKeys.itemDrops] = {219773},
            [itemKeys.vendors] = nil,
            [itemKeys.startQuest] = nil,
        },
        [220067] = {
            [itemKeys.name] = "Deputization Authorization: Ashenvale Mission XV",
            [itemKeys.npcDrops] = nil,
            [itemKeys.objectDrops] = nil,
            [itemKeys.itemDrops] = {219773},
            [itemKeys.vendors] = nil,
            [itemKeys.startQuest] = nil,
        },
        [220068] = {
            [itemKeys.name] = "Deputization Authorization: Ashenvale Mission XVI",
            [itemKeys.npcDrops] = nil,
            [itemKeys.objectDrops] = nil,
            [itemKeys.itemDrops] = {219773},
            [itemKeys.vendors] = nil,
            [itemKeys.startQuest] = nil,
        },
        [220069] = {
            [itemKeys.name] = "Deputization Authorization: Ashenvale Mission XVII",
            [itemKeys.npcDrops] = nil,
            [itemKeys.objectDrops] = nil,
            [itemKeys.itemDrops] = {219773},
            [itemKeys.vendors] = nil,
            [itemKeys.startQuest] = nil,
        },
        [220070] = {
            [itemKeys.name] = "Deputization Authorization: Ashenvale Mission XVIII",
            [itemKeys.npcDrops] = nil,
            [itemKeys.objectDrops] = nil,
            [itemKeys.itemDrops] = {219773},
            [itemKeys.vendors] = nil,
            [itemKeys.startQuest] = nil,
        },
    }
end
