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
        [206469] = { -- Prairie Flower
            [itemKeys.objectDrops] = {403718},
        },
        [208609] = { -- Glade Flower
            [itemKeys.objectDrops] = {407247},
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
            [itemKeys.npcDrops] = {2265,2266,2267,2268,2360},
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
    }
end
