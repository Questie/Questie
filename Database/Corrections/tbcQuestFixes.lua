---@class QuestieTBCQuestFixes
local QuestieTBCQuestFixes = QuestieLoader:CreateModule("QuestieTBCQuestFixes")
local _QuestieTBCQuestFixes = {}

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type ContentPhases
local ContentPhases = QuestieLoader:ImportModule("ContentPhases")
---@type Expansions
local Expansions = QuestieLoader:ImportModule("Expansions")
---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule("ZoneDB")
---@type QuestieProfessions
local QuestieProfessions = QuestieLoader:ImportModule("QuestieProfessions")
---@type QuestieCorrections
local QuestieCorrections = QuestieLoader:ImportModule("QuestieCorrections")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")


QuestieCorrections.killCreditObjectiveFirst[10503] = true -- The Bladespire Threat


function QuestieTBCQuestFixes:Load()
    local questKeys = QuestieDB.questKeys
    local raceIDs = QuestieDB.raceKeys
    local classIDs = QuestieDB.classKeys
    local factionIDs = QuestieDB.factionIDs
    local zoneIDs = ZoneDB.zoneIDs
    local sortKeys = QuestieDB.sortKeys
    local questFlags = QuestieDB.questFlags
    local specialFlags = QuestieDB.specialFlags
    local profKeys = QuestieProfessions.professionKeys
    local rankKeys = QuestieProfessions.rankNames

    return {
        [32] = { -- Rise of the Silithid
            [questKeys.reputationReward] = {{factionIDs.GADGETZAN,350},{factionIDs.HORDE,350}},
        },
        [54] = { -- Report to Goldshire
            [questKeys.requiredLevel] = 1,
        },
        [62] = { -- The Fargodeep Mine
            [questKeys.triggerEnd] = {"Scout through the Fargodeep Mine", {[zoneIDs.ELWYNN_FOREST] = {{40.01,81.42}}}},
        },
        [76] = { -- The Jasperlode Mine
            [questKeys.triggerEnd] = {"Scout through the Jasperlode Mine", {[zoneIDs.ELWYNN_FOREST] = {{60.53,50.18}}}},
        },
        [77] = { -- A Sticky Situation
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [100] = { -- Call of Water
            [questKeys.childQuests] = {},
        },
        [123] = { -- The Collector
            [questKeys.nextQuestInChain] = 147,
        },
        [162] = { -- Rise of the Silithid
            [questKeys.reputationReward] = {{factionIDs.GADGETZAN,150},{factionIDs.ALLIANCE,150}},
        },
        [171] = { -- A Warden of the Alliance
            [questKeys.questLevel] = -1,
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,500}},
        },
        [172] = { -- Children's Week
            [questKeys.questLevel] = -1,
            [questKeys.reputationReward] = {{factionIDs.HORDE,10}},
        },
        [176] = { -- Wanted:  "Hogger"
            [questKeys.startedBy] = {nil,{68,156561}},
            [questKeys.requiredLevel] = 5,
        },
        [201] = { -- Investigate the Camp
            [questKeys.triggerEnd] = {"Locate the hunters' camp", {[zoneIDs.STRANGLETHORN_VALE] = {{35.73,10.82}}}},
        },
        [211] = { -- Alas, Andorhal
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,350},{factionIDs.ARGENT_DAWN,700}},
        },
        [233] = { -- Coldridge Valley Mail Delivery
            [questKeys.preQuestSingle] = {179},
        },
        [225] = { -- The Weathered Grave
            [questKeys.requiredLevel] = 25,
        },
        [253] = { -- Bride of the Embalmer
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,500}},
        },
        [254] = { -- Digging Through the Dirt
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [275] = { -- Blisters on The Land
            [questKeys.objectivesText] = {"Kill 8 Fen Creepers, then return to Rethiel the Greenwarden in the Wetlands."}, -- override classic correction
        },
        [281] = { -- Reclaiming Goods
            [questKeys.reputationReward] = {{factionIDs.STORMWIND,25}},
        },
        [287] = { -- Frostmane Hold
            [questKeys.triggerEnd] = {"Fully explore Frostmane Hold", {[zoneIDs.DUN_MOROGH] = {{21.47,52.2}}}},
        },
        [310] = { -- Bitter Rivals
            [questKeys.childQuests] = {308},
        },
        [349] = { -- Stranglethorn Fever
            [questKeys.objectivesText] = {"Speak with Witch Doctor Unbagwa.",},
        },
        [364] = { -- The Mindless Ones
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [403] = { -- Guarded Thunderbrew Barrel
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [415] = { -- Rejold's New Brew
            [questKeys.startedBy] = {{1378,1872}},
        },
        [455] = { -- The Algaz Gauntlet
            [questKeys.triggerEnd] = {"Traverse Dun Algaz", {[zoneIDs.WETLANDS] = {{53.49,70.36}}}},
        },
        [460] = { -- Resting in Pieces
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [504] = { -- Crushridge Warmongers
            [questKeys.objectivesText] = {"Slay 10 Crushridge Warmongers, then return to Marshal Redpath in Southshore."},
        },
        [510] = { -- Foreboding Plans
            [questKeys.startedBy] = {nil,{1740,186420}}, -- in TBC, 1738 and 1739 are removed, but 186420 is added to a nearby camp
        },
        [511] = { -- Encrypted Letter
            [questKeys.startedBy] = {nil,{1740,186420}}, -- in TBC, 1738 and 1739 are removed, but 186420 is added to a nearby camp
        },
        [512] = { -- Noble Deaths
            [questKeys.reputationReward] = {{factionIDs.STORMWIND,250}},
        },
        [532] = { -- Battle of Hillsbrad
            [questKeys.objectivesText] = {"Kill Magistrate Burnside and 4 Hillsbrad Councilmen. Destroy the Hillsbrad Proclamation. Steal the Hillsbrad Town Registry. Report back to Darthalia in Tarren Mill afterwards."},
        },
        [542] = { -- Return to Milton
            [questKeys.reputationReward] = {{factionIDs.STORMWIND,350}},
        },
        [549] = { -- WANTED: Syndicate Personnel
            [questKeys.requiredLevel] = 17,
        },
        [558] = { -- Jaina's Autograph
            [questKeys.questLevel] = -1,
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,150}},
        },
        [561] = { -- Farren's Proof
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [566] = { -- WANTED: Baron Vardus
            [questKeys.requiredLevel] = 17,
        },
        [578] = { -- The Stone of the Tides
            [questKeys.triggerEnd] = {"Locate the haunted island", {[zoneIDs.STRANGLETHORN_VALE] = {{21.56,21.98}}}},
        },
        [663] = { -- Land Ho!
            [questKeys.requiredLevel] = 35,
        },
        [729] = { -- The Absent Minded Prospector
            [questKeys.requiredLevel] = 15,
        },
        [748] = { -- Poison Water
            [questKeys.requiredRaces] = raceIDs.TAUREN,
        },
        [756] = { -- Thunderhorn Totem
            [questKeys.requiredRaces] = raceIDs.TAUREN,
        },
        [759] = { -- Wildmane Totem
            [questKeys.requiredRaces] = raceIDs.TAUREN,
        },
        [787] = { -- The New Horde
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [794] = { -- Burning Blade Medallion
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [870] = { -- The Forgotten Pools
            [questKeys.triggerEnd] = {"Explore the waters of the Forgotten Pools", {[zoneIDs.THE_BARRENS] = {{45.06,22.56}}}},
        },
        [891] = { -- The Guns of Northwatch
            [questKeys.reputationReward] = {{factionIDs.RATCHET,250},{factionIDs.HORDE,75}},
        },
        [910] = { -- Down at the Docks
            [questKeys.questLevel] = -1,
            [questKeys.reputationReward] = {{factionIDs.HORDE,75}},
        },
        [911] = { -- Down at the Docks
            [questKeys.questLevel] = -1,
            [questKeys.reputationReward] = {{factionIDs.HORDE,75}},
        },
        [915] = { -- You Scream, I Scream...
            [questKeys.questLevel] = -1,
            [questKeys.preQuestGroup] = {910,911,1800},
            [questKeys.reputationReward] = {{factionIDs.HORDE,150}},
        },
        [925] = { -- Cairne's Hoofprint
            [questKeys.questLevel] = -1,
            [questKeys.reputationReward] = {{factionIDs.HORDE,150}},
        },
        [926] = { -- Flawed Power Stone
            [questKeys.startedBy] = {nil,{5619,5620,5621}},
            [questKeys.finishedBy] = {nil,{5619,5620,5621}},
        },
        [927] = { -- The Moss-twined Heart
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [930] = { -- The Glowing Fruit
            [questKeys.requiredLevel] = 4,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [931] = { -- The Shimmering Frond
            [questKeys.requiredLevel] = 4,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [949] = { -- The Twilight Camp
            [questKeys.requiredLevel] = 12,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [950] = { -- Return to Onu
            [questKeys.requiredLevel] = 12,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [968] = { -- The Powers Below
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [990] = { -- Trek to Ashenvale
            [questKeys.exclusiveTo] = {}, -- starting with tbc only, exclusivity is present in classic
        },
        [1001] = { -- Buzzbox 411
            [questKeys.requiredLevel] = 7,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [1002] = { -- Buzzbox 323
            [questKeys.requiredLevel] = 7,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [1003] = { -- Buzzbox 525
            [questKeys.requiredLevel] = 7,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [1046] = { -- Raene's Cleansing
            [questKeys.objectives] = {nil,nil,{{5388},{5462}}},
        },
        [1048] = { -- Into The Scarlet Monastery
            [questKeys.requiredLevel] = 30,
        },
        [1049] = { -- Compendium of the Fallen
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE - raceIDs.UNDEAD,
        },
        [1081] = { -- Reception from Tyrande
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,500}},
        },
        [1090] = { -- Gerenzo's Orders
            [questKeys.requiredRaces] = raceIDs.NONE,
        },
        [1092] = { -- Gerenzo's Orders
            [questKeys.requiredRaces] = raceIDs.NONE,
        },
        [1093] = { -- Super Reaper 6000
            [questKeys.requiredRaces] = raceIDs.NONE,
        },
        [1094] = { -- Further Instructions
            [questKeys.requiredRaces] = raceIDs.NONE,
        },
        [1096] = { -- Gerenzo Wrenchwhistle
            [questKeys.requiredRaces] = raceIDs.NONE,
        },
        [1109] = { -- Going, Going, Guano!
            [questKeys.requiredLevel] = 22,
            [questKeys.questLevel] = 26,
        },
        [1133] = { -- Journey to Astranaar
            [questKeys.zoneOrSort] = zoneIDs.DARKSHORE,
        },
        [1135] = { -- Highperch Venom
            [questKeys.startedBy] = {{4456}},
            [questKeys.zoneOrSort] = zoneIDs.DARKSHORE,
        },
        [1177] = { -- Hungry!
            [questKeys.objectivesText] = {"Mudcrush Durtfeet in northern Dustwallow wants 8 Mirefin Heads."},
        },
        [1206] = { -- Jarl Needs Eyes
            [questKeys.objectivesText] = {"Bring 20 Unpopped Darkmist Eyes to \"Swamp Eye\" Jarl at the Swamplight Manor.",},
        },
        [1218] = { -- Marsh Frog Legs
            [questKeys.breadcrumbs] = {11177},
        },
        [1220] = { -- Captain Vimes
            [questKeys.startedBy] = {{23951}},
        },
        [1252] = { -- Lieutenant Paval Reethe
            [questKeys.preQuestSingle] = {11123},
        },
        [1253] = { -- The Black Shield
            [questKeys.preQuestSingle] = {11123},
        },
        [1267] = { -- The Missing Diplomat
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,500}},
        },
        [1268] = { -- Suspicious Hoofprints
            [questKeys.startedBy] = {nil,{187273}},
        },
        [1282] = { -- They Call Him Smiling Jim
            [questKeys.breadcrumbForQuestId] = 11123,
        },
        [1284] = { -- Suspicious Hoofprints
            [questKeys.startedBy] = {nil,{187273}},
            [questKeys.preQuestSingle] = {11123},
        },
        [1322] = { -- The Black Shield
            [questKeys.objectivesText] = {"Acquire 5 Acidic Venom Sacs for Do'gol in Brackenwall Village."},
        },
        [1361] = { -- Regthar Deathgate
            [questKeys.startedBy] = {{2229,4485,10540}},
        },
        [1367] = { -- Magram Alliance
            [questKeys.reputationReward] = {{factionIDs.GELKIS_CLAN_CENTAUR,-250},{factionIDs.MAGRAM_CLAN_CENTAUR,250}},
        },
        [1368] = { -- Gelkis Alliance
            [questKeys.reputationReward] = {{factionIDs.MAGRAM_CLAN_CENTAUR,-250},{factionIDs.GELKIS_CLAN_CENTAUR,250}},
        },
        [1382] = { -- Strange Alliance
            [questKeys.reputationReward] = {{factionIDs.MAGRAM_CLAN_CENTAUR,-500},{factionIDs.GELKIS_CLAN_CENTAUR,250}},
        },
        [1385] = { -- Brutal Politics
            [questKeys.reputationReward] = {{factionIDs.GELKIS_CLAN_CENTAUR,-500},{factionIDs.MAGRAM_CLAN_CENTAUR,250}},
        },
        [1394] = { -- Final Passage
            [questKeys.reputationReward] = {{factionIDs.HORDE,500}},
        },
        [1396] = { -- Encroaching Wildlife
            [questKeys.breadcrumbs] = {9609},
        },
        [1437] = { -- Vahlarriel's Search
            [questKeys.triggerEnd] = {"Find and search Tyranis and Dalinda Malem's wagon", {[zoneIDs.DESOLACE] = {{56.52,17.84}}}},
        },
        [1468] = { -- Children's Week
            [questKeys.questLevel] = -1,
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,10}},
        },
        [1470] = { -- Piercing the Veil
            [questKeys.exclusiveTo] = {1485,8344},
        },
        [1473] = { -- Creature of the Void
            [questKeys.breadcrumbs] = {1478,10789},
        },
        [1478] = { -- Halgar's Summons
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.exclusiveTo] = {},
        },
        [1479] = { -- The Bough of the Eternals
            [questKeys.questLevel] = -1,
        },
        [1485] = { -- Vile Familiars
            [questKeys.exclusiveTo] = {1470,8344},
        },
        [1486] = { -- Deviate Hides
            [questKeys.requiredRaces] = raceIDs.NONE,
        },
        [1488] = { -- The Corrupter
            [questKeys.reputationReward] = {{factionIDs.HORDE,350}},
        },
        [1499] = { -- Vile Familiars
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.preQuestSingle] = {1470,1485,8344},
        },
        [1501] = { -- Creature of the Void
            [questKeys.breadcrumbs] = {1506,10790},
        },
        [1506] = { -- Gan'rul's Summons
            [questKeys.exclusiveTo] = {},
            [questKeys.breadcrumbForQuestId] = 1501,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [1508] = { -- Blind Cazul
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [1516] = { -- Call of Earth
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [1517] = { -- Call of Earth
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [1518] = { -- Call of Earth
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [1520] = { -- Call of Earth
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [1521] = { -- Call of Earth
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [1528] = { -- Call of Water
            [questKeys.exclusiveTo] = {1529,2985,2986},
        },
        [1529] = { -- Call of Water
            [questKeys.exclusiveTo] = {1528,2985,2986},
        },
        [1558] = { -- The Stonewrought Dam
            [questKeys.questLevel] = -1,
        },
        [1598] = { -- The Stolen Tome
            [questKeys.requiredRaces] = raceIDs.HUMAN + raceIDs.GNOME,
        },
        [1599] = { -- Beginnings
            [questKeys.requiredRaces] = raceIDs.HUMAN + raceIDs.GNOME,
        },
        [1638] = { -- A Warrior's Training
            [questKeys.startedBy] = {{913,5480}},
            [questKeys.exclusiveTo] = {
                1678,1683, -- not available once you turn in these main quests
                1639, -- "follow up" quest from same NPC. NOT breadcrumb
                9582, -- not available once you pick this draenei main quest -- TBC+
            },
        },
        [1639] = { -- Bartleby the Drunk
            [questKeys.exclusiveTo] = {1678,1683,9582},
        },
        [1640] = { -- Beat Bartleby
            [questKeys.preQuestSingle] = {1639,1678,1683,9582},
        },
        [1656] = { -- A Task Unfinished
            [questKeys.requiredLevel] = 1,
        },
        [1657] = { -- Stinking Up Southshore
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [1658] = { -- Crashing the Wickerman Festival
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,250}},
        },
        [1661] = { -- The Tome of Nobility
            [questKeys.name] = "The Tome of Nobility",
            [questKeys.startedBy] = {{6171}},
            [questKeys.finishedBy] = {{6171}},
            [questKeys.preQuestSingle] = {4485,4486},
        },
        [1678] = { -- Vejrek
            [questKeys.questLevel] = -1,
            [questKeys.exclusiveTo] = {1639,1683,9582},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE, -- TBC+
        },
        [1679] = { -- Muren Stormpike
            [questKeys.exclusiveTo] = {
                1639,1683, -- not available once you turn in these main quests
                9582, -- not available once you pick this draenei main quest -- TBC+
            },
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE, -- TBC+
        },
        [1680] = { -- Tormus Deepforge
            [questKeys.preQuestSingle] = {1683,1678,1639,9582},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE, -- TBC+
        },
        [1681] = { -- Ironband's Compound
            [questKeys.preQuestSingle] = {1683,1678,1639,9582},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE, -- TBC+
        },
        [1682] = { -- Grey Iron Weapons
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE, -- TBC+
        },
        [1683] = { -- Vorlus Vilehoof
            [questKeys.exclusiveTo] = {1639,1678,9582},
        },
        [1684] = { -- Elanaria
            [questKeys.exclusiveTo] = {
                1639,1678, -- not available once you pick these main quests
                1683, -- "follow up" quest from same NPC. NOT breadcrumb
                9582, -- not available once you pick this draenei main quest
            },
        },
        [1686] = { -- The Shade of Elura
            [questKeys.preQuestSingle] = {1683,1678,1639,9582},
        },
        [1687] = { -- Spooky Lighthouse
            [questKeys.questLevel] = -1,
        },
        [1698] = { -- Yorus Barleybrew
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.exclusiveTo] = {10371},
        },
        [1699] = { -- The Rethban Gauntlet
            [questKeys.triggerEnd] = {"Enter the Rethban Caverns", {[zoneIDs.REDRIDGE_MOUNTAINS] = {{19.22,25.25}}}},
            [questKeys.breadcrumbs] = {1698,10371},
        },
        [1703] = { -- Mathiel
            [questKeys.requiredRaces] = raceIDs.NIGHT_ELF,
        },
        [1704] = { -- Klockmort Spannerspan
            [questKeys.requiredRaces] = raceIDs.GNOME + raceIDs.DWARF,
        },
        [1716] = { -- Devourer of Souls
            [questKeys.preQuestSingle] = {},
        },
        [1718] = { -- The Islander
            [questKeys.startedBy] = {{3041,3354,4595,5113,5479,16771}},
        },
        [1719] = { -- The Affray
            [questKeys.triggerEnd] = {"Step on the grate to begin the Affray", {[zoneIDs.THE_BARRENS] = {{68.61,48.72}}}},
        },
        [1782] = { -- Furen's Armor
            [questKeys.zoneOrSort] = sortKeys.WARRIOR,
        },
        [1800] = { -- Lordaeron Throne Room
            [questKeys.questLevel] = -1,
            [questKeys.reputationReward] = {{factionIDs.HORDE,75}},
        },
        [1801] = { -- Tome of the Cabal
            [questKeys.requiredRaces] = raceIDs.ORC + raceIDs.UNDEAD + raceIDs.BLOOD_ELF,
        },
        [1803] = { -- Tome of the Cabal
            [questKeys.requiredRaces] = raceIDs.ORC + raceIDs.UNDEAD + raceIDs.BLOOD_ELF,
        },
        [1805] = { -- Tome of the Cabal
            [questKeys.requiredRaces] = raceIDs.ORC + raceIDs.UNDEAD + raceIDs.BLOOD_ELF,
        },
        [1821] = { -- Agamand Heirlooms
            [questKeys.nextQuestInChain] = 1822,
        },
        [1858] = { -- The Shattered Hand
            [questKeys.requiredRaces] = raceIDs.ORC + raceIDs.TROLL,
        },
        [1859] = { -- Therzok
            [questKeys.requiredRaces] = raceIDs.ORC,
        },
        [1860] = { -- Speak with Jennea
            [questKeys.exclusiveTo] = {1880,9595},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [1861] = { -- Mirror Lake
            [questKeys.exclusiveTo] = {1880,9595},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [1879] = { -- Speak with Bink
            [questKeys.exclusiveTo] = {1861,9595},
        },
        [1880] = { -- Mage-tastic Gizmonitor
            [questKeys.exclusiveTo] = {1861,9595},
        },
        [1881] = { -- Speak with Anastasia
            [questKeys.exclusiveTo] = {1884,9402},
        },
        [1882] = { -- The Balnir Farmstead
            [questKeys.exclusiveTo] = {1884,9402},
        },
        [1883] = { -- Speak with Un'thuwa
            [questKeys.exclusiveTo] = {1882,9402},
        },
        [1884] = { -- Ju-Ju Heaps
            [questKeys.exclusiveTo] = {1882,9402},
        },
        [1885] = { -- Mennet Carkad
            [questKeys.requiredRaces] = raceIDs.UNDEAD,
        },
        [1886] = { -- The Deathstalkers
            [questKeys.requiredRaces] = raceIDs.UNDEAD,
        },
        [1898] = { -- The Deathstalkers
            [questKeys.requiredRaces] = raceIDs.UNDEAD,
        },
        [1899] = { -- The Deathstalkers
            [questKeys.requiredRaces] = raceIDs.UNDEAD,
        },
        [1939] = { -- High Sorcerer Andromath
            [questKeys.startedBy] = {{5144,5497,17513}},
        },
        [1943] = { -- Speak with Deino
            [questKeys.startedBy] = {{4568,16652}},
        },
        [1947] = { -- Journey to the Marsh
            [questKeys.startedBy] = {{3048,4568,5885,16652,5144,5497,17513}}, -- further split in faction fixes below
        },
        [1953] = { -- Return to the Marsh
            [questKeys.startedBy] = {{5144,5497,3048,4568,5885,16652,17513}}, -- further split in faction fixes below
        },
        [1963] = { -- The Shattered Hand
            [questKeys.requiredRaces] = raceIDs.ORC + raceIDs.TROLL,
        },
        [1978] = { -- The Deathstalkers
            [questKeys.requiredRaces] = raceIDs.UNDEAD,
        },
        [1998] = { -- Fenwick Thatros
            [questKeys.requiredRaces] = raceIDs.UNDEAD,
        },
        [1999] = { -- Tools of the Trade
            [questKeys.requiredRaces] = raceIDs.UNDEAD,
        },
        [2040] = { -- Underground Assault
            [questKeys.reputationReward] = {{factionIDs.STORMWIND,500},{factionIDs.GNOMEREGAN_EXILES,500}},
        },
        [2205] = { -- Seek out SI: 7
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [2206] = { -- Snatch and Grab
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [2218] = { -- Road to Salvation
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [2238] = { -- Simple Subterfugin'
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [2239] = { -- Onin's Report
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [2279] = { -- The Platinum Discs
            [questKeys.requiredLevel] = 40,
        },
        [2280] = { -- The Platinum Discs
            [questKeys.requiredLevel] = 40,
        },
        [2284] = { -- Necklace Recovery, Take 2
            [questKeys.requiredLevel] = 37,
        },
        [2298] = { -- Kingly Shakedown
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [2299] = { -- To Hulfdan!
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [2338] = { -- Translating the Journal
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [2358] = { -- Horns of Nez'ra
            [questKeys.name] = "Horns of Nez'ra",
            [questKeys.startedBy] = {{7009}},
        },
        [2379] = { -- Zando'zan
            [questKeys.exclusiveTo] = {9491},
        },
        [2381] = { -- Plundering the Plunderers
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [2382] = { -- Wrenix of Ratchet
            [questKeys.preQuestSingle] = {2379,9491},
        },
        [2399] = { -- The Sprouted Fronds
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [2438] = { -- The Emerald Dreamcatcher
            [questKeys.questFlags] = 8,
        },
        [2460] = { -- The Shattered Salute
            [questKeys.breadcrumbs] = {10794},
        },
        [2501] = { -- Badlands Reagent Run II
            [questKeys.zoneOrSort] = sortKeys.ALCHEMY,
        },
        [2861] = { -- Tabetha's Task
            [questKeys.startedBy] = {{4568,5144,5497,5885,16651,17514}}
        },
        [2880] = { -- Troll Necklace Bounty
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [2881] = { -- Troll Necklace Bounty
            [questKeys.startedBy] = {{7884}},
            [questKeys.finishedBy] = {{7884}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.preQuestSingle] = {2880},
        },
        [2985] = { -- Call of Water
            [questKeys.exclusiveTo] = {1528,1529,2986},
        },
        [2986] = { -- Call of Water
            [questKeys.exclusiveTo] = {1528,1529,2985},
        },
        [2989] = { -- The Altar of Zul
            [questKeys.triggerEnd] = {"Search the Altar of Zul", {[zoneIDs.THE_HINTERLANDS] = {{48.86,68.42}}}},
        },
        [2996] = { -- Seeking Strahad
            [questKeys.requiredRaces] = raceIDs.ORC + raceIDs.UNDEAD + raceIDs.BLOOD_ELF,
        },
        [3001] = { -- Seeking Strahad
            [questKeys.startedBy] = {{5675,16646}},
            [questKeys.requiredRaces] = raceIDs.ORC + raceIDs.UNDEAD + raceIDs.BLOOD_ELF,
        },
        [3088] = { -- Encrypted Parchment
            [questKeys.requiredRaces] = raceIDs.ORC,
        },
        [3090] = { -- Tainted Parchment
            [questKeys.requiredRaces] = raceIDs.ORC,
        },
        [3091] = { -- Simple Note
            [questKeys.requiredRaces] = raceIDs.TAUREN,
        },
        [3092] = { -- Etched Note
            [questKeys.requiredRaces] = raceIDs.TAUREN,
        },
        [3093] = { -- Rune-Inscribed Note
            [questKeys.requiredRaces] = raceIDs.TAUREN,
        },
        [3094] = { -- Verdant Note
            [questKeys.requiredRaces] = raceIDs.TAUREN,
        },
        [3095] = { -- Simple Scroll
            [questKeys.requiredRaces] = raceIDs.UNDEAD,
        },
        [3096] = { -- Encrypted Scroll
            [questKeys.requiredRaces] = raceIDs.UNDEAD,
        },
        [3097] = { -- Hallowed Scroll
            [questKeys.requiredRaces] = raceIDs.UNDEAD,
        },
        [3098] = { -- Glyphic Scroll
            [questKeys.requiredRaces] = raceIDs.UNDEAD,
        },
        [3099] = { -- Tainted Scroll
            [questKeys.requiredRaces] = raceIDs.UNDEAD,
        },
        [3116] = { -- Simple Sigil
            [questKeys.requiredRaces] = raceIDs.NIGHT_ELF,
        },
        [3117] = { -- Etched Sigil
            [questKeys.requiredRaces] = raceIDs.NIGHT_ELF,
        },
        [3118] = { -- Encrypted Sigil
            [questKeys.requiredRaces] = raceIDs.NIGHT_ELF,
        },
        [3119] = { -- Hallowed Sigil
            [questKeys.requiredRaces] = raceIDs.NIGHT_ELF,
        },
        [3120] = { -- Verdant Sigil
            [questKeys.requiredRaces] = raceIDs.NIGHT_ELF,
        },
        [3505] = { -- Betrayed
            [questKeys.triggerEnd] = {"Find Magus Rimtori's camp", {[zoneIDs.AZSHARA] = {{59.29,31.21}}}},
        },
        [3570] = { -- Seeping Corruption
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [3631] = { -- Summon Felsteed
            [questKeys.name] = "Summon Felsteed",
            [questKeys.startedBy] = {{3326}},
            [questKeys.finishedBy] = {{6251}},
            [questKeys.requiredRaces] = raceIDs.ORC + raceIDs.UNDEAD + raceIDs.BLOOD_ELF,
            [questKeys.exclusiveTo] = {4487,4488,4489},
        },
        [3741] = { -- Hilary's Necklace
            [questKeys.requiredRaces] = raceIDs.NONE,
        },
        [3763] = { -- Assisting Arch Druid Staghelm
            [questKeys.exclusiveTo] = {3789,3790,10520},
        },
        [3764] = { -- Un'Goro Soil
            [questKeys.breadcrumbs] = {3763,3789,3790,10520},
        },
        [3787] = { -- Jonespyre's Request
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [3789] = { -- Assisting Arch Druid Staghelm
            [questKeys.exclusiveTo] = {3763,3790,10520},
        },
        [3790] = { -- Assisting Arch Druid Staghelm
            [questKeys.exclusiveTo] = {3763,3789,10520},
        },
        [3803] = { -- Morrowgrain to Darnassus
            [questKeys.startedBy] = {{4217}},
        },
        [3921] = { -- Wenikee Boltbucket
            [questKeys.reputationReward] = {{factionIDs.RATCHET,75},{factionIDs.HORDE,25}},
        },
        [3922] = { -- Nugget Slugs
            [questKeys.reputationReward] = {{factionIDs.RATCHET,250},{factionIDs.HORDE,75}},
        },
        [3923] = { -- Rilli Greasygob
            [questKeys.reputationReward] = {{factionIDs.RATCHET,25},{factionIDs.HORDE,10}},
        },
        [3924] = { -- Samophlange Manual
            [questKeys.reputationReward] = {{factionIDs.RATCHET,350},{factionIDs.HORDE,150}},
        },
        [4004] = { -- The Princess Saved?
            [questKeys.reputationReward] = {{factionIDs.HORDE,500}},
        },
        [4021] = { -- Counterattack!
            [questKeys.extraObjectives] = {{{[zoneIDs.THE_BARRENS] = {{44.7,28.1}}}, Questie.ICON_TYPE_EVENT, l10n("Defeat Centaur to summon Warlord Krom'zar"), 0}},
        },
        [4134] = { -- Lost Thunderbrew Recipe
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [4146] = { -- Zapper Fuel
            [questKeys.zoneOrSort] = zoneIDs.SUNKEN_TEMPLE,
        },
        [4266] = { -- A Hero's Welcome
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,500}},
        },
        [4485] = { -- The Tome of Nobility
            [questKeys.nextQuestInChain] = 1661,
        },
        [4486] = { -- The Tome of Nobility
            [questKeys.nextQuestInChain] = 1661,
        },
        [4487] = { -- Summon Felsteed
            [questKeys.name] = "Summon Felsteed",
            [questKeys.startedBy] = {{5172}},
            [questKeys.finishedBy] = {{6251}},
            [questKeys.exclusiveTo] = {3631,4488,4489},
        },
        [4488] = { -- Summon Felsteed
            [questKeys.name] = "Summon Felsteed",
            [questKeys.startedBy] = {{461}},
            [questKeys.finishedBy] = {{6251}},
            [questKeys.exclusiveTo] = {3631,4487,4489},
        },
        [4489] = { -- Summon Felsteed
            [questKeys.name] = "Summon Felsteed",
            [questKeys.startedBy] = {{4563}},
            [questKeys.finishedBy] = {{6251}},
            [questKeys.requiredRaces] = raceIDs.ORC + raceIDs.UNDEAD + raceIDs.BLOOD_ELF,
            [questKeys.exclusiveTo] = {3631,4487,4488},
        },
        [4490] = { -- Summon Felsteed
            [questKeys.name] = "Summon Felsteed",
            [questKeys.startedBy] = {{6251}},
            [questKeys.finishedBy] = {{6251}},
            [questKeys.requiredRaces] = raceIDs.NONE,
        },
        [4510] = { -- Calm Before the Storm
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,500}},
        },
        [4511] = { -- Calm Before the Storm
            [questKeys.reputationReward] = {{factionIDs.HORDE,500}},
        },
        [4726] = { -- Broodling Essence
            [questKeys.reputationReward] = {{factionIDs.STEAMWHEEDLE_CARTEL,250}},
        },
        [4734] = { -- Egg Freezing
            [questKeys.reputationReward] = {{factionIDs.STEAMWHEEDLE_CARTEL,500}},
        },
        [4735] = { -- Egg Collection
            [questKeys.reputationReward] = {{factionIDs.STEAMWHEEDLE_CARTEL,500}},
        },
        [4738] = { -- In Search of Menara Voidrender
            [questKeys.startedBy] = {{461,16646}},
            [questKeys.requiredRaces] = raceIDs.HUMAN + raceIDs.GNOME + raceIDs.ORC + raceIDs.UNDEAD + raceIDs.BLOOD_ELF, -- was available for orc + blood elf, safe to assume also available for undead
        },
        [4740] = { -- WANTED: Murkdeep!
            [questKeys.requiredLevel] = 9,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [4813] = { -- The Fragments Within
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [4822] = { -- You Scream, I Scream...
            [questKeys.questLevel] = -1,
            [questKeys.preQuestGroup] = {1479,1558,1687},
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,150}},
        },
        [4842] = { -- Strange Sources
            [questKeys.triggerEnd] = {"Discover Darkwhisper Gorge", {[zoneIDs.WINTERSPRING] = {{60.1,73.44}}}},
        },
        [4902] = { -- Wildkin of Elune
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,250}},
        },
        [4968] = { -- Knowledge of the Orb of Orahil
            [questKeys.startedBy] = {{461,16646}},
            [questKeys.requiredRaces] = raceIDs.HUMAN + raceIDs.GNOME + raceIDs.ORC + raceIDs.UNDEAD + raceIDs.BLOOD_ELF, -- was available for orc + blood elf, safe to assume also available for undead
        },
        [4983] = { -- Bijou's Reconnaissance Report
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [5002] = { -- Message to Maxwell
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [5054] = { -- Ursius of the Shardtooth
            [questKeys.requiredRaces] = raceIDs.NONE,
        },
        [5055] = { -- Brumeran of the Chillwind
            [questKeys.requiredRaces] = raceIDs.NONE,
        },
        [5056] = { -- Shy-Rotam
            [questKeys.requiredRaces] = raceIDs.NONE,
        },
        [5057] = { -- Past Endeavors
            [questKeys.requiredRaces] = raceIDs.NONE,
        },
        [5066] = { -- A Call to Arms: The Plaguelands!
            [questKeys.exclusiveTo] = {5090,5091,10373},
        },
        [5090] = { -- A Call to Arms: The Plaguelands!
            [questKeys.exclusiveTo] = {5066,5091,10373},
        },
        [5091] = { -- A Call to Arms: The Plaguelands!
            [questKeys.exclusiveTo] = {5066,5090,10373},
        },
        [5092] = { -- Clear the Way
            [questKeys.breadcrumbs] = {5066,5090,5091,10373},
        },
        [5093] = { -- A Call to Arms: The Plaguelands!
            [questKeys.exclusiveTo] = {5094,5095,10374},
        },
        [5094] = { -- A Call to Arms: The Plaguelands!
            [questKeys.exclusiveTo] = {5093,5095,10374},
        },
        [5095] = { -- A Call to Arms: The Plaguelands!
            [questKeys.exclusiveTo] = {5093,5094,10374},
        },
        [5096] = { -- Scarlet Diversions
            [questKeys.breadcrumbs] = {5093,5094,5095,10374},
        },
        [5097] = { -- All Along the Watchtowers
            [questKeys.reputationReward] = {{factionIDs.STORMWIND,250}},
        },
        [5102] = { -- General Drakkisath's Demise
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,500}},
        },
        [5149] = { -- Pamela's Doll
            [questKeys.reputationReward] = {},
        },
        [5168] = { -- Heroes of Darrowshire
            [questKeys.preQuestSingle] = {5210},
        },
        [5216] = { -- Target: Felstone Field
            [questKeys.reputationReward] = {{factionIDs.STORMWIND,250},{factionIDs.ARGENT_DAWN,250}},
        },
        [5217] = { -- Return to Chillwind Camp
            [questKeys.reputationReward] = {{factionIDs.STORMWIND,75},{factionIDs.ARGENT_DAWN,75}},
        },
        [5219] = { -- Target: Dalson's Tears
            [questKeys.reputationReward] = {{factionIDs.STORMWIND,250},{factionIDs.ARGENT_DAWN,250}},
        },
        [5220] = { -- Return to Chillwind Camp
            [questKeys.reputationReward] = {{factionIDs.STORMWIND,75},{factionIDs.ARGENT_DAWN,75}},
        },
        [5222] = { -- Target: Writhing Haunt
            [questKeys.reputationReward] = {{factionIDs.STORMWIND,250},{factionIDs.ARGENT_DAWN,250}},
        },
        [5223] = { -- Return to Chillwind Camp
            [questKeys.reputationReward] = {{factionIDs.STORMWIND,75},{factionIDs.ARGENT_DAWN,75}},
        },
        [5225] = { -- Target: Gahrron's Withering
            [questKeys.reputationReward] = {{factionIDs.STORMWIND,250},{factionIDs.ARGENT_DAWN,250}},
        },
        [5226] = { -- Return to Chillwind Camp
            [questKeys.reputationReward] = {{factionIDs.STORMWIND,75},{factionIDs.ARGENT_DAWN,75}},
        },
        [5237] = { -- Mission Accomplished!
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,500},{factionIDs.ARGENT_DAWN,1000}},
        },
        [5238] = { -- Mission Accomplished!
            [questKeys.reputationReward] = {{factionIDs.HORDE,500},{factionIDs.ARGENT_DAWN,1000}},
        },
        [5245] = { -- Troubled Spirits of Kel'Theril
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,25}},
        },
        [5246] = { -- Fragments of the Past
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,25}},
        },
        [5247] = { -- Fragments of the Past
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,250}},
            [questKeys.nextQuestInChain] = 5248,
        },
        [5248] = { -- Tormented By the Past
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,25}},
        },
        [5252] = { -- Remorseful Highborne
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,25}},
        },
        [5253] = { -- The Crystal of Zin-Malor
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,250}},
        },
        [5401] = { -- Argent Dawn Commission
            [questKeys.exclusiveTo] = {5405,5503},
        },
        [5402] = { -- Minion's Scourgestones
            [questKeys.startedBy] = {{10840}},
            [questKeys.finishedBy] = {{10840}},
        },
        [5403] = { -- Invader's Scourgestones
            [questKeys.startedBy] = {{10840}},
            [questKeys.finishedBy] = {{10840}},
        },
        [5405] = { -- Argent Dawn Commission
            [questKeys.startedBy] = {{10839}},
            [questKeys.finishedBy] = {{10839}},
            [questKeys.exclusiveTo] = {5401,5503},
        },
        [5407] = { -- Invader's Scourgestones
            [questKeys.startedBy] = {{10839}},
            [questKeys.finishedBy] = {{10839}},
        },
        [5408] = { -- Minion's Scourgestones
            [questKeys.startedBy] = {{10839}},
            [questKeys.finishedBy] = {{10839}},
        },
        [5502] = { -- A Warden of the Horde
            [questKeys.questLevel] = -1,
            [questKeys.reputationReward] = {{factionIDs.HORDE,500}},
        },
        [5503] = { -- Argent Dawn Commission
            [questKeys.startedBy] = {{11039}},
            [questKeys.finishedBy] = {{11039}},
            [questKeys.exclusiveTo] = {5401,5405},
        },
        [5518] = { -- The Gordok Ogre Suit
            [questKeys.reputationReward] = {{factionIDs.STEAMWHEEDLE_CARTEL,250}},
        },
        [5519] = { -- The Gordok Ogre Suit
            [questKeys.reputationReward] = {{factionIDs.STEAMWHEEDLE_CARTEL,75}},
        },
        [5621] = { -- Garments of the Moon
            [questKeys.requiredLevel] = 5,
        },
        [5622] = { -- In Favor of Elune
            [questKeys.requiredLevel] = 5,
        },
        [5627] = { -- Stars of Elune (Darnassus)
            [questKeys.name] = "Stars of Elune",
            [questKeys.startedBy] = {{11401}},
            [questKeys.finishedBy] = {{11401}},
        },
        [5628] = { -- Returning Home (Elwynn Forest)
            [questKeys.questLevel] = -1,
        },
        [5629] = { -- Returning Home (Teldrassil)
            [questKeys.questLevel] = -1,
        },
        [5630] = { -- Returning Home (Dun Morogh)
            [questKeys.questLevel] = -1,
        },
        [5631] = { -- Returning Home (Stormwind City)
            [questKeys.questLevel] = -1,
        },
        [5632] = { -- Returning Home (Stormwind City)
            [questKeys.questLevel] = -1,
            [questKeys.finishedBy] = {{11401}},
        },
        [5633] = { -- Returning Home (Ironforge)
            [questKeys.questLevel] = -1,
            [questKeys.finishedBy] = {{11401}},
        },
        [5634] = { -- Desperate Prayer (Stormwind City)
            [questKeys.questLevel] = -1,
        },
        [5635] = { -- Desperate Prayer (Elwynn Forest)
            [questKeys.questLevel] = -1,
        },
        [5636] = { -- Desperate Prayer (Teldrassil)
            [questKeys.questLevel] = -1,
        },
        [5637] = { -- Desperate Prayer (Dun Morogh)
            [questKeys.questLevel] = -1,
        },
        [5638] = { -- Desperate Prayer (Stormwind City)
            [questKeys.questLevel] = -1,
        },
        [5639] = { -- Desperate Prayer (Ironforge)
            [questKeys.questLevel] = -1,
        },
        [5640] = { -- Desperate Prayer (Darnassus)
            [questKeys.questLevel] = -1,
        },
        [5641] = { -- A Lack of Fear (Ironforge)
            [questKeys.name] = "A Lack of Fear",
            [questKeys.finishedBy] = {{11406}},
            [questKeys.requiredRaces] = raceIDs.DWARF,
            [questKeys.exclusiveTo] = {5645,5647},
        },
        [5642] = { -- Shadowguard (Thunder Bluff)
            [questKeys.questLevel] = -1,
            [questKeys.exclusiveTo] = {5643,5680},
        },
        [5643] = { -- Shadowguard (Undercity)
            [questKeys.questLevel] = -1,
            [questKeys.exclusiveTo] = {5642,5680},
        },
        [5644] = { -- Devouring Plague (Thunder Bluff)
            [questKeys.questLevel] = -1,
            [questKeys.exclusiveTo] = {5646,5679},
        },
        [5645] = { -- A Lack of Fear (Stormwind City)
            [questKeys.name] = "A Lack of Fear",
            [questKeys.finishedBy] = {{11406}},
            [questKeys.requiredRaces] = raceIDs.DWARF,
            [questKeys.exclusiveTo] = {5641,5647},
        },
        [5646] = { -- Devouring Plague (Orgrimmar)
            [questKeys.questLevel] = -1,
            [questKeys.exclusiveTo] = {5644,5679},
        },
        [5647] = { -- A Lack of Fear (Darnassus)
            [questKeys.name] = "A Lack of Fear",
            [questKeys.finishedBy] = {{11406}},
            [questKeys.requiredRaces] = raceIDs.DWARF,
            [questKeys.exclusiveTo] = {5641,5645},
        },
        [5648] = { -- Garments of Spirituality
            [questKeys.requiredLevel] = 5,
        },
        [5649] = { -- In Favor of Spirituality
            [questKeys.requiredLevel] = 5,
        },
        [5650] = { -- Garments of Darkness
            [questKeys.requiredLevel] = 5,
        },
        [5651] = { -- In Favor of Darkness
            [questKeys.requiredLevel] = 5,
        },
        [5652] = { -- Hex of Weakness (Orgrimmar)
            [questKeys.questLevel] = -1,
            [questKeys.exclusiveTo] = {5654,5655,5656,5657},
        },
        [5654] = { -- Hex of Weakness (Durotar)
            [questKeys.questLevel] = -1,
            [questKeys.exclusiveTo] = {5652,5655,5656,5657},
        },
        [5655] = { -- Hex of Weakness (Mulgore)
            [questKeys.finishedBy] = {{6018}},
            [questKeys.questLevel] = -1,
            [questKeys.exclusiveTo] = {5652,5654,5656,5657},
        },
        [5656] = { -- Hex of Weakness (Thunder Bluff)
            [questKeys.questLevel] = -1,
            [questKeys.exclusiveTo] = {5652,5654,5655,5657},
        },
        [5657] = { -- Hex of Weakness (Undercity)
            [questKeys.questLevel] = -1,
            [questKeys.exclusiveTo] = {5652,5654,5655,5656},
        },
        [5658] = { -- Touch of Weakness (Undercity)
            [questKeys.questLevel] = -1,
            [questKeys.exclusiveTo] = {5660,5661,5662,5663},
        },
        [5660] = { -- Touch of Weakness (Durotar)
            [questKeys.questLevel] = -1,
            [questKeys.exclusiveTo] = {5658,5661,5662,5663},
        },
        [5661] = { -- Touch of Weakness (Mulgore)
            [questKeys.questLevel] = -1,
            [questKeys.exclusiveTo] = {5658,5660,5662,5663},
        },
        [5662] = { -- Touch of Weakness (Orgrimmar)
            [questKeys.questLevel] = -1,
            [questKeys.exclusiveTo] = {5658,5660,5661,5663},
        },
        [5663] = { -- Touch of Weakness (Thunder Bluff)
            [questKeys.questLevel] = -1,
            [questKeys.exclusiveTo] = {5658,5660,5661,5662},
        },
        [5672] = { -- Elune's Grace (Darnassus)
            [questKeys.questLevel] = -1,
            [questKeys.exclusiveTo] = {5673,5674,5675},
        },
        [5673] = { -- Elune's Grace (Stormwind City)
            [questKeys.questLevel] = -1,
            [questKeys.exclusiveTo] = {5672,5674,5675},
        },
        [5674] = { -- Elune's Grace (Stormwind City)
            [questKeys.finishedBy] = {{11401}},
            [questKeys.questLevel] = -1,
            [questKeys.exclusiveTo] = {5672,5673,5675},
        },
        [5675] = { -- Elune's Grace (Ironforge)
            [questKeys.questLevel] = -1,
            [questKeys.exclusiveTo] = {5672,5673,5674},
        },
        [5676] = { -- Arcane Feedback (Stormwind City)
            [questKeys.questLevel] = -1,
        },
        [5677] = { -- Arcane Feedback (Ironforge)
            [questKeys.questLevel] = -1,
        },
        [5678] = { -- Arcane Feedback (Darnassus)
            [questKeys.questLevel] = -1,
        },
        [5679] = { -- Devouring Plague (Undercity)
            [questKeys.questLevel] = -1,
            [questKeys.exclusiveTo] = {5644,5646},
        },
        [5680] = { -- Shadowguard (Orgrimmar)
            [questKeys.questLevel] = -1,
            [questKeys.exclusiveTo] = {5642,5643},
        },
        [5726] = { -- Hidden Enemies
            [questKeys.nextQuestInChain] = 5727,
        },
        [5924] = { -- Heeding the Call
            [questKeys.startedBy] = {{5505,16721}},
        },
        [5961] = { -- The Champion of the Banshee Queen
            [questKeys.requiredLevel] = 54,
        },
        [6025] = { -- Unfinished Business
            [questKeys.triggerEnd] = {"Overlook Hearthglen from a high vantage point", {[zoneIDs.WESTERN_PLAGUELANDS] = {{45.7,18.5}}}},
        },
        [6126] = { -- Lessons Anew
            [questKeys.preQuestSingle] = {},
            [questKeys.questLevel] = -1,
        },
        [6185] = { -- The Eastern Plagues
            [questKeys.triggerEnd] = {"The Blightcaller Uncovered", {[zoneIDs.EASTERN_PLAGUELANDS] = {{27.4,75.14}}}},
        },
        [6341] = { -- The Bounty of Teldrassil
            [questKeys.requiredRaces] = raceIDs.NIGHT_ELF,
        },
        [6342] = { -- Flight to Auberdine
            [questKeys.requiredRaces] = raceIDs.NIGHT_ELF,
        },
        [6343] = { -- Return to Nessa
            [questKeys.requiredRaces] = raceIDs.NIGHT_ELF,
        },
        [6344] = { -- Nessa Shadowsong
            [questKeys.requiredRaces] = raceIDs.NIGHT_ELF,
        },
        [6403] = { -- The Great Masquerade
            [questKeys.reputationReward] = {{factionIDs.STORMWIND,500}},
        },
        [6421] = { -- Boulderslide Ravine
            [questKeys.triggerEnd] = {"Investigate Cave in Boulderslide Ravine", {[zoneIDs.STONETALON_MOUNTAINS] = {{58.96,90.16}}}},
        },
        [6761] = { -- The New Frontier
            [questKeys.preQuestSingle] = {1015,1019,1047},
        },
        [6962] = { -- Treats for Great-father Winter
            [questKeys.reputationReward] = {{factionIDs.STEAMWHEEDLE_CARTEL,25}},
        },
        [6963] = { -- Stolen Winter Veil Treats
            [questKeys.reputationReward] = {{factionIDs.STEAMWHEEDLE_CARTEL,75}},
        },
        [6983] = { -- You're a Mean One...
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [6984] = { -- A Smokywood Pastures' Thank You!
            [questKeys.reputationReward] = {{factionIDs.STEAMWHEEDLE_CARTEL,250}},
        },
        [7003] = { -- Zapped Giants
            [questKeys.reputationReward] = {{factionIDs.STEAMWHEEDLE_CARTEL,350}},
        },
        [7025] = { -- Treats for Greatfather Winter
            [questKeys.reputationReward] = {{factionIDs.STEAMWHEEDLE_CARTEL,25}},
        },
        [7045] = { -- A Smokywood Pastures' Thank You!
            [questKeys.reputationReward] = {{factionIDs.STEAMWHEEDLE_CARTEL,250}},
        },
        [7282] = { -- Brotherly Love
            [questKeys.reputationReward] = {{factionIDs.STORMPIKE_GUARD,250},{factionIDs.IRONFORGE,250},{factionIDs.STORMWIND,250}},
        },
        [7483] = { -- Libram of Rapidity
            [questKeys.reputationReward] = {{factionIDs.SHEN_DRALAR,500}},
        },
        [7484] = { -- Libram of Focus
            [questKeys.reputationReward] = {{factionIDs.SHEN_DRALAR,500}},
        },
        [7485] = { -- Libram of Protection
            [questKeys.reputationReward] = {{factionIDs.SHEN_DRALAR,500}},
        },
        [7488] = { -- Lethtendris's Web
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,500}},
        },
        [7489] = { -- Lethtendris's Web
            [questKeys.reputationReward] = {{factionIDs.HORDE,500}},
        },
        [7508] = { -- The Forging of Quel'Serrar
            [questKeys.requiredLevel] = 60,
        },
        [7583] = { -- Suppression
            [questKeys.preQuestGroup] = {7581,7582},
        },
        [7623] = { -- Lord Banehollow
            [questKeys.preQuestSingle] = {},
        },
        [7642] = { -- Collection of Goods
            [questKeys.reputationReward] = {{factionIDs.IRONFORGE,500}},
        },
        [7667] = { -- Material Assistance
            [questKeys.reputationReward] = {{factionIDs.HORDE,350}},
        },
        [7668] = { -- The Darkreaver Menace
            [questKeys.reputationReward] = {{factionIDs.HORDE,500}},
        },
        [7670] = { -- Lord Grayson Shadowbreaker
            [questKeys.startedBy] = {{5149,17509}},
        },
        [7721] = { -- Fuel for the Zapping
            [questKeys.reputationReward] = {{factionIDs.STEAMWHEEDLE_CARTEL,350}},
        },
        [7725] = { -- Again With the Zapped Giants
            [questKeys.reputationReward] = {{factionIDs.STEAMWHEEDLE_CARTEL,25}},
        },
        [7726] = { -- Refuel for the Zapping
            [questKeys.reputationReward] = {{factionIDs.STEAMWHEEDLE_CARTEL,25}},
        },
        [7730] = { -- Zukk'ash Infestation
            [questKeys.reputationReward] = {{factionIDs.HORDE,250}},
        },
        [7731] = { -- Stinglasher
            [questKeys.reputationReward] = {{factionIDs.HORDE,350}},
        },
        [7732] = { -- Zukk'ash Report
            [questKeys.reputationReward] = {{factionIDs.HORDE,75}},
        },
        [7792] = { -- A Donation of Wool
            [questKeys.startedBy] = {{20604}},
            [questKeys.finishedBy] = {{20604}},
            [questKeys.reputationReward] = {{factionIDs.EXODAR,350}},
        },
        [7795] = { -- A Donation of Runecloth
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {7791,7793,7794},
        },
        [7798] = { -- A Donation of Silk
            [questKeys.startedBy] = {{20604}},
            [questKeys.finishedBy] = {{20604}},
            [questKeys.reputationReward] = {{factionIDs.EXODAR,350}},
        },
        [7800] = { -- A Donation of Runecloth
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {7799,10352,10354},
        },
        [7805] = { -- A Donation of Runecloth
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {7802,7803,7804},
        },
        [7811] = { -- A Donation of Runecloth
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {7807,7808,7809},
        },
        [7818] = { -- A Donation of Runecloth
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {7813,7814,7817},
        },
        [7823] = { -- A Donation of Runecloth
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {7820,7821,7822},
        },
        [7824] = { -- A Donation of Runecloth
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {7826,7827,7831},
        },
        [7836] = { -- A Donation of Runecloth
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {7833,7834,7835},
        },
        [7863] = { -- Sentinel Basic Care Package
            [questKeys.requiredMinRep] = {890,3000},
        },
        [7864] = { -- Sentinel Standard Care Package
            [questKeys.requiredMinRep] = {890,9000},
        },
        [7865] = { -- Sentinel Advanced Care Package
            [questKeys.requiredMinRep] = {890,21000},
        },
        [7866] = { -- Outrider Basic Care Package
            [questKeys.requiredMinRep] = {889,3000},
        },
        [7867] = { -- Outrider Standard Care Package
            [questKeys.requiredMinRep] = {889,9000},
        },
        [7868] = { -- Outrider Advanced Care Package
            [questKeys.requiredMinRep] = {889,21000},
        },
        [7946] = { -- Spawn of Jubjub
            [questKeys.questLevel] = -1,
        },
        [8114] = { -- Control Four Bases
            [questKeys.triggerEnd] = {"Take Four Bases in Arathi Basin", {[zoneIDs.ARATHI_HIGHLANDS] = {{45.9,45.8}}}},
        },
        [8115] = { -- Control Five Bases
            [questKeys.triggerEnd] = {"Take Five Bases in Arathi Basin", {[zoneIDs.ARATHI_HIGHLANDS] = {{45.9,45.8}}}},
        },
        [8121] = { -- Take Four Bases
            [questKeys.triggerEnd] = {"Hold Four Bases in Arathi Basin", {[zoneIDs.ARATHI_HIGHLANDS] = {{73.2,30}}}},
        },
        [8122] = { -- Take Five Bases
            [questKeys.triggerEnd] = {"Hold Five Bases in Arathi Basin", {[zoneIDs.ARATHI_HIGHLANDS] = {{73.2,30}}}},
        },
        [8149] = { -- Honoring a Hero
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,500}},
        },
        [8150] = { -- Honoring a Hero
            [questKeys.reputationReward] = {{factionIDs.HORDE,500}},
        },
        [8151] = { -- The Hunter's Charm
            [questKeys.startedBy] = {{3039,3352,4205,5116,5516,16673,17505}},
        },
        [8193] = { -- Master Angler
            [questKeys.questLevel] = -1,
        },
        [8194] = { -- Apprentice Angler
            [questKeys.questLevel] = -1,
        },
        [8221] = { -- Rare Fish - Keefer's Angelfish
            [questKeys.questLevel] = -1,
        },
        [8224] = { -- Rare Fish - Dezian Queenfish
            [questKeys.questLevel] = -1,
        },
        [8225] = { -- Rare Fish - Brownell's Blue Striped Racer
            [questKeys.questLevel] = -1,
        },
        [8228] = { -- Could I get a Fishing Flier?
            [questKeys.questLevel] = -1,
            [questKeys.zoneOrSort] = sortKeys.FISHING,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [8229] = { -- Could I get a Fishing Flier?
            [questKeys.questLevel] = -1,
            [questKeys.zoneOrSort] = sortKeys.FISHING,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [8233] = { -- A Simple Request
            [questKeys.startedBy] = {{918,3328,4163,4583,5165,5167,16684}},
            [questKeys.requiredRaces] = raceIDs.NONE,
        },
        [8249] = { -- Junkboxes Needed
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [8250] = { -- Magecraft
            [questKeys.startedBy] = {{331,3047,4567,7311,7312,16652,17513}},
        },
        [8254] = { -- Cenarion Aid
            [questKeys.startedBy] = {{3045,5489,6018,11406,16658,16756}},
        },
        [8258] = { -- The Darkreaver Menace
            [questKeys.reputationReward] = {{factionIDs.HORDE,500}},
        },
        [8259] = { -- A More Fitting Reward
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.preQuestSingle] = {8258},
        },
        [8311] = { -- Hallow's End Treats for Jesper!
            [questKeys.requiredLevel] = 10,
            [questKeys.questLevel] = -1,
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,250}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [8312] = { -- Hallow's End Treats for Spoops!
            [questKeys.requiredLevel] = 10,
            [questKeys.reputationReward] = {{factionIDs.HORDE,250}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [8322] = { -- Rotten Eggs
            [questKeys.reputationReward] = {{factionIDs.HORDE,25}},
        },
        [8325] = { -- Reclaiming Sunstrider Isle
            [questKeys.requiredRaces] = raceIDs.BLOOD_ELF,
        },
        [8326] = { -- Unfortunate Measures
            [questKeys.requiredRaces] = raceIDs.BLOOD_ELF,
        },
        [8327] = { -- Report to Lanthan Perilon
            [questKeys.nextQuestInChain] = 0,
            [questKeys.requiredRaces] = raceIDs.BLOOD_ELF,
        },
        [8328] = { -- Mage Training
            [questKeys.requiredRaces] = raceIDs.BLOOD_ELF,
        },
        [8330] = { -- Solanian's Belongings
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {10068,10069,10070,10071,10072,10073},
            [questKeys.requiredRaces] = raceIDs.BLOOD_ELF,
        },
        [8334] = { -- Aggression
            [questKeys.requiredRaces] = raceIDs.BLOOD_ELF,
            [questKeys.preQuestSingle] = {8326},
        },
        [8335] = { -- Felendren the Banished
            [questKeys.requiredRaces] = raceIDs.BLOOD_ELF,
        },
        [8336] = { -- A Fistful of Slivers
            [questKeys.requiredRaces] = raceIDs.BLOOD_ELF,
        },
        [8338] = { -- Tainted Arcane Sliver
            [questKeys.requiredRaces] = raceIDs.BLOOD_ELF,
        },
        [8344] = { -- Windows to the Source
            [questKeys.requiredRaces] = raceIDs.BLOOD_ELF,
            [questKeys.exclusiveTo] = {1470,1485},
        },
        [8345] = { -- The Shrine of Dath'Remar
            [questKeys.requiredRaces] = raceIDs.BLOOD_ELF,
        },
        [8346] = { -- Thirst Unending
            [questKeys.objectives] = {nil,nil,nil,nil,{{{15294,15274},15274,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [8347] = { -- Aiding the Outrunners
            [questKeys.breadcrumbForQuestId] = 9704,
            [questKeys.requiredRaces] = raceIDs.BLOOD_ELF,
        },
        [8353] = { -- Chicken Clucking for a Mint
            [questKeys.requiredLevel] = 10,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [8354] = { -- Chicken Clucking for a Mint
            [questKeys.requiredLevel] = 10,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [8355] = { -- Incoming Gumdrop
            [questKeys.requiredLevel] = 10,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [8356] = { -- Flexing for Nougat
            [questKeys.requiredLevel] = 10,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [8357] = { -- Dancing for Marzipan
            [questKeys.requiredLevel] = 10,
            [questKeys.questLevel] = -1,
        },
        [8358] = { -- Incoming Gumdrop
            [questKeys.requiredLevel] = 10,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [8359] = { -- Flexing for Nougat
            [questKeys.requiredLevel] = 10,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [8360] = { -- Dancing for Marzipan
            [questKeys.requiredLevel] = 10,
            [questKeys.questLevel] = -1,
        },
        [8367] = { -- For Great Honor
            [questKeys.requiredLevel] = 61,
        },
        [8371] = { -- Concerted Efforts
            [questKeys.requiredLevel] = 61,
        },
        [8373] = { -- The Power of Pine
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,250}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [8381] = { -- Armaments of War
            [questKeys.requiredClasses] = classIDs.MAGE + classIDs.WARLOCK,
        },
        [8385] = { -- Concerted Efforts
            [questKeys.requiredLevel] = 61,
        },
        [8388] = { -- For Great Honor
            [questKeys.requiredLevel] = 61,
        },
        [8409] = { -- Ruined Kegs
            [questKeys.reputationReward] = {{factionIDs.HORDE,250}},
        },
        [8410] = { -- Elemental Mastery
            [questKeys.startedBy] = {{3032,13417,17219,20407,23127}},
        },
        [8411] = { -- Mastering the Elements
            [questKeys.name] = "Mastering the Elements",
            [questKeys.requiredRaces] = raceIDs.NONE,
        },
        [8412] = { -- Spirit Totem
            [questKeys.requiredRaces] = raceIDs.NONE,
        },
        [8413] = { -- Da Voodoo
            [questKeys.requiredRaces] = raceIDs.NONE,
        },
        [8417] = { -- A Troubled Spirit
            [questKeys.startedBy] = {{3041,3354,4593,5113,5479,7315,17120}},
        },
        [8419] = { -- An Imp's Request
            [questKeys.startedBy] = {{461,3326,4563,5172,16647}},
        },
        [8423] = { -- Warrior Kinship
            [questKeys.preQuestSingle] = {},
        },
        [8465] = { -- Speak to Salfa
            [questKeys.preQuestSingle] = {8461},
        },
        [8473] = { -- A Somber Task
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {9258},
        },
        [8474] = { -- Old Whitebark's Pendant
            [questKeys.startedBy] = {nil,nil,{23228}},
        },
        [8476] = { -- Amani Encroachment
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {9359},
        },
        [8482] = { -- Incriminating Documents
            [questKeys.startedBy] = {nil,nil,{20765}},
        },
        [8484] = { -- The Brokering of Peace
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,500}},
        },
        [8485] = { -- The Brokering of Peace
            [questKeys.reputationReward] = {{factionIDs.HORDE,500}},
        },
        [8487] = { -- Corrupted Soil
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {9254},
            [questKeys.nextQuestInChain] = 8488,
        },
        [8488] = { -- Unexpected Results
            [questKeys.objectives] = {{{15958}}},
        },
        [8490] = { -- Powering our Defenses
            [questKeys.preQuestSingle] = {},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Place the Infused Crystal and protect it from the Scourge for 1 minute"), 0, {{"object", 181164}}}},
            [questKeys.objectives] = {{{16364,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.requiredSourceItems] = {},
            [questKeys.breadcrumbs] = {9253},
        },
        [8544] = { -- Conqueror's Spaulders
            [questKeys.preQuestSingle] = {8579},
        },
        [8548] = { -- Volunteer's Battlegear
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [8551] = { -- The Captain's Chest
            [questKeys.questLevel] = 42,
        },
        [8553] = { -- The Captain's Cutlass
            [questKeys.requiredRaces] = raceIDs.NONE,
        },
        [8554] = { -- Facing Negolash
            [questKeys.requiredRaces] = raceIDs.NONE,
        },
        [8559] = { -- Conqueror's Greaves
            [questKeys.preQuestSingle] = {8579},
        },
        [8560] = { -- Conqueror's Legguards
            [questKeys.preQuestSingle] = {8579},
        },
        [8561] = { -- Conqueror's Crown
            [questKeys.preQuestSingle] = {8579},
        },
        [8562] = { -- Conqueror's Breastplate
            [questKeys.preQuestSingle] = {8579},
        },
        [8563] = { -- Warlock Training
            [questKeys.requiredRaces] = raceIDs.BLOOD_ELF,
        },
        [8564] = { -- Priest Training
            [questKeys.requiredRaces] = raceIDs.BLOOD_ELF,
        },
        [8572] = { -- Veteran's Battlegear
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [8573] = { -- Champion's Battlegear
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [8574] = { -- Stalwart's Battlegear
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [8579] = { -- Mortal Champions
            [questKeys.specialFlags] = specialFlags.NONE,
        },
        [8592] = { -- Tiara of the Oracle
            [questKeys.preQuestSingle] = {8579},
        },
        [8593] = { -- Trousers of the Oracle
            [questKeys.preQuestSingle] = {8579},
        },
        [8594] = { -- Mantle of the Oracle
            [questKeys.preQuestSingle] = {8579},
        },
        [8595] = { -- Mortal Champions
            [questKeys.preQuestSingle] = {8579},
        },
        [8596] = { -- Footwraps of the Oracle
            [questKeys.preQuestSingle] = {8579},
        },
        [8602] = { -- Stormcaller's Pauldrons
            [questKeys.preQuestSingle] = {8579},
        },
        [8603] = { -- Vestments of the Oracle
            [questKeys.preQuestSingle] = {8579},
        },
        [8619] = { -- Morndeep the Elder
            [questKeys.questLevel] = -1,
        },
        [8621] = { -- Stormcaller's Footguards
            [questKeys.preQuestSingle] = {8579},
        },
        [8622] = { -- Stormcaller's Hauberk
            [questKeys.preQuestSingle] = {8579},
        },
        [8623] = { -- Stormcaller's Diadem
            [questKeys.preQuestSingle] = {8579},
        },
        [8624] = { -- Stormcaller's Leggings
            [questKeys.preQuestSingle] = {8579},
        },
        [8625] = { -- Enigma Shoulderpads
            [questKeys.preQuestSingle] = {8579},
        },
        [8626] = { -- Striker's Footguards
            [questKeys.preQuestSingle] = {8579},
        },
        [8627] = { -- Avenger's Breastplate
            [questKeys.preQuestSingle] = {8579},
        },
        [8628] = { -- Avenger's Crown
            [questKeys.preQuestSingle] = {8579},
        },
        [8629] = { -- Avenger's Legguards
            [questKeys.preQuestSingle] = {8579},
        },
        [8630] = { -- Avenger's Pauldrons
            [questKeys.preQuestSingle] = {8579},
        },
        [8631] = { -- Enigma Leggings
            [questKeys.preQuestSingle] = {8579},
        },
        [8632] = { -- Enigma Circlet
            [questKeys.preQuestSingle] = {8579},
        },
        [8633] = { -- Enigma Robes
            [questKeys.preQuestSingle] = {8579},
        },
        [8634] = { -- Enigma Boots
            [questKeys.preQuestSingle] = {8579},
        },
        [8635] = { -- Splitrock the Elder
            [questKeys.questLevel] = -1,
        },
        [8636] = { -- Rumblerock the Elder
            [questKeys.questLevel] = -1,
        },
        [8637] = { -- Deathdealer's Boots
            [questKeys.preQuestSingle] = {8579},
        },
        [8638] = { -- Deathdealer's Vest
            [questKeys.preQuestSingle] = {8579},
        },
        [8639] = { -- Deathdealer's Helm
            [questKeys.preQuestSingle] = {8579},
        },
        [8640] = { -- Deathdealer's Leggings
            [questKeys.preQuestSingle] = {8579},
        },
        [8641] = { -- Deathdealer's Spaulders
            [questKeys.preQuestSingle] = {8579},
        },
        [8642] = { -- Silvervein the Elder
            [questKeys.questLevel] = -1,
        },
        [8643] = { -- Highpeak the Elder
            [questKeys.questLevel] = -1,
        },
        [8644] = { -- Stonefort the Elder
            [questKeys.questLevel] = -1,
        },
        [8645] = { -- Obsidian the Elder
            [questKeys.questLevel] = -1,
        },
        [8646] = { -- Hammershout the Elder
            [questKeys.questLevel] = -1,
        },
        [8647] = { -- Bellowrage the Elder
            [questKeys.questLevel] = -1,
        },
        [8648] = { -- Darkcore the Elder
            [questKeys.questLevel] = -1,
        },
        [8649] = { -- Stormbrow the Elder
            [questKeys.questLevel] = -1,
        },
        [8650] = { -- Snowcrown the Elder
            [questKeys.questLevel] = -1,
        },
        [8651] = { -- Ironband the Elder
            [questKeys.questLevel] = -1,
        },
        [8652] = { -- Graveborn the Elder
            [questKeys.questLevel] = -1,
        },
        [8653] = { -- Goldwell the Elder
            [questKeys.questLevel] = -1,
        },
        [8654] = { -- Primestone the Elder
            [questKeys.questLevel] = -1,
        },
        [8655] = { -- Avenger's Greaves
            [questKeys.preQuestSingle] = {8579},
        },
        [8656] = { -- Striker's Hauberk
            [questKeys.preQuestSingle] = {8579},
        },
        [8657] = { -- Striker's Diadem
            [questKeys.preQuestSingle] = {8579},
        },
        [8658] = { -- Striker's Leggings
            [questKeys.preQuestSingle] = {8579},
        },
        [8659] = { -- Striker's Pauldrons
            [questKeys.preQuestSingle] = {8579},
        },
        [8660] = { -- Doomcaller's Footwraps
            [questKeys.preQuestSingle] = {8579},
        },
        [8661] = { -- Doomcaller's Robes
            [questKeys.preQuestSingle] = {8579},
        },
        [8662] = { -- Doomcaller's Circlet
            [questKeys.preQuestSingle] = {8579},
        },
        [8663] = { -- Doomcaller's Trousers
            [questKeys.preQuestSingle] = {8579},
        },
        [8664] = { -- Doomcaller's Mantle
            [questKeys.preQuestSingle] = {8579},
        },
        [8665] = { -- Genesis Boots
            [questKeys.preQuestSingle] = {8579},
        },
        [8666] = { -- Genesis Vest
            [questKeys.preQuestSingle] = {8579},
        },
        [8667] = { -- Genesis Helm
            [questKeys.preQuestSingle] = {8579},
        },
        [8668] = { -- Genesis Trousers
            [questKeys.preQuestSingle] = {8579},
        },
        [8669] = { -- Genesis Shoulderpads
            [questKeys.preQuestSingle] = {8579},
        },
        [8670] = { -- Runetotem the Elder
            [questKeys.questLevel] = -1,
        },
        [8671] = { -- Ragetotem the Elder
            [questKeys.questLevel] = -1,
        },
        [8672] = { -- Stonespire the Elder
            [questKeys.questLevel] = -1,
        },
        [8673] = { -- Bloodhoof the Elder
            [questKeys.questLevel] = -1,
        },
        [8674] = { -- Winterhoof the Elder
            [questKeys.questLevel] = -1,
        },
        [8675] = { -- Skychaser the Elder
            [questKeys.questLevel] = -1,
        },
        [8676] = { -- Wildmane the Elder
            [questKeys.questLevel] = -1,
        },
        [8677] = { -- Darkhorn the Elder
            [questKeys.questLevel] = -1,
        },
        [8678] = { -- Proudhorn the Elder
            [questKeys.questLevel] = -1,
        },
        [8679] = { -- Grimtotem the Elder
            [questKeys.questLevel] = -1,
        },
        [8680] = { -- Windtotem the Elder
            [questKeys.questLevel] = -1,
        },
        [8681] = { -- Thunderhorn the Elder
            [questKeys.questLevel] = -1,
        },
        [8682] = { -- Skyseer the Elder
            [questKeys.questLevel] = -1,
        },
        [8683] = { -- Dawnstrider the Elder
            [questKeys.questLevel] = -1,
        },
        [8684] = { -- Dreamseer the Elder
            [questKeys.questLevel] = -1,
        },
        [8685] = { -- Mistwalker the Elder
            [questKeys.questLevel] = -1,
        },
        [8686] = { -- High Mountain the Elder
            [questKeys.questLevel] = -1,
        },
        [8688] = { -- Windrun the Elder
            [questKeys.questLevel] = -1,
        },
        [8713] = { -- Starsong the Elder
            [questKeys.questLevel] = -1,
        },
        [8714] = { -- Moonstrike the Elder
            [questKeys.questLevel] = -1,
        },
        [8715] = { -- Bladeleaf the Elder
            [questKeys.questLevel] = -1,
        },
        [8716] = { -- Starglade the Elder
            [questKeys.questLevel] = -1,
        },
        [8717] = { -- Moonwarden the Elder
            [questKeys.questLevel] = -1,
        },
        [8718] = { -- Bladeswift the Elder
            [questKeys.questLevel] = -1,
        },
        [8719] = { -- Bladesing the Elder
            [questKeys.questLevel] = -1,
        },
        [8720] = { -- Skygleam the Elder
            [questKeys.questLevel] = -1,
        },
        [8721] = { -- Starweave the Elder
            [questKeys.questLevel] = -1,
        },
        [8722] = { -- Meadowrun the Elder
            [questKeys.questLevel] = -1,
        },
        [8723] = { -- Nightwind the Elder
            [questKeys.questLevel] = -1,
        },
        [8724] = { -- Morningdew the Elder
            [questKeys.questLevel] = -1,
        },
        [8725] = { -- Riversong the Elder
            [questKeys.questLevel] = -1,
        },
        [8726] = { -- Brightspear the Elder
            [questKeys.questLevel] = -1,
        },
        [8727] = { -- Farwhisper the Elder
            [questKeys.questLevel] = -1,
        },
        [8767] = { -- A Gently Shaken Gift
            [questKeys.questLevel] = -1,
        },
        [8788] = { -- A Gently Shaken Gift
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = -1,
        },
        [8851] = { -- Five Signets for War Supplies
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [8852] = { -- Ten Signets for War Supplies
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [8853] = { -- Fifteen Signets for War Supplies
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [8854] = { -- Twenty Signets for War Supplies
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [8855] = { -- Thirty Signets for War Supplies
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [8860] = { -- New Year Celebrations!
            [questKeys.questLevel] = -1,
        },
        [8861] = { -- New Year Celebrations!
            [questKeys.questLevel] = -1,
        },
        [8862] = { -- Elune's Candle
            [questKeys.requiredLevel] = 10,
        },
        [8863] = { -- Festival Dumplings
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = -1,
        },
        [8866] = { -- Bronzebeard the Elder
            [questKeys.questLevel] = -1,
        },
        [8867] = { -- Lunar Fireworks
            [questKeys.questLevel] = 70,
        },
        [8870] = { -- The Lunar Festival
            [questKeys.questLevel] = 70,
        },
        [8871] = { -- The Lunar Festival
            [questKeys.questLevel] = 70,
        },
        [8872] = { -- The Lunar Festival
            [questKeys.questLevel] = 70,
        },
        [8873] = { -- The Lunar Festival
            [questKeys.questLevel] = 70,
        },
        [8874] = { -- The Lunar Festival
            [questKeys.questLevel] = 70,
        },
        [8875] = { -- The Lunar Festival
            [questKeys.questLevel] = 70,
        },
        [8876] = { -- Small Rockets
            [questKeys.requiredLevel] = 25,
        },
        [8883] = { -- Valadar Starsong
            [questKeys.questLevel] = 70,
        },
        [8887] = { -- Captain Kelisendra's Lost Rutters
            [questKeys.startedBy] = {nil,nil,{21776}},
        },
        [8888] = { -- The Magister's Apprentice
            [questKeys.breadcrumbForQuestId] = 8889,
        },
        [8889] = { -- Deactivating the Spire
            [questKeys.breadcrumbs] = {8888},
        },
        [8892] = { -- Situation at Sunsail Anchorage
            [questKeys.preQuestSingle] = {}, -- TO DO: double check
            [questKeys.breadcrumbs] = {9256},
        },
        [8894] = { -- Cleaning up the Grounds
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {9394},
        },
        [8897] = { -- Dearest Colara,
            [questKeys.questLevel] = -1,
        },
        [8898] = { -- Dearest Colara,
            [questKeys.questLevel] = -1,
        },
        [8899] = { -- Dearest Colara,
            [questKeys.questLevel] = -1,
        },
        [8900] = { -- Dearest Elenia,
            [questKeys.questLevel] = -1,
            [questKeys.nextQuestInChain] = 0, -- no followup in TBC
        },
        [8901] = { -- Dearest Elenia,
            [questKeys.questLevel] = -1,
            [questKeys.nextQuestInChain] = 0, -- no followup in TBC
        },
        [8902] = { -- Dearest Elenia,
            [questKeys.questLevel] = -1,
            [questKeys.nextQuestInChain] = 0, -- no followup in TBC
        },
        [8903] = { -- Dangerous Love
            [questKeys.questLevel] = -1,
        },
        [8904] = { -- Dangerous Love
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = -1,
            [questKeys.nextQuestInChain] = 0, -- no followup in TBC
        },
        [8962] = { -- Components of Importance
            [questKeys.requiredClasses] = classIDs.NONE,
        },
        [8963] = { -- Components of Importance
            [questKeys.requiredClasses] = classIDs.NONE,
        },
        [8964] = { -- Components of Importance
            [questKeys.requiredClasses] = classIDs.NONE,
        },
        [8965] = { -- Components of Importance
            [questKeys.requiredClasses] = classIDs.NONE,
        },
        [8966] = { -- The Left Piece of Lord Valthalak's Amulet
            [questKeys.requiredClasses] = classIDs.NONE,
        },
        [8967] = { -- The Left Piece of Lord Valthalak's Amulet
            [questKeys.requiredClasses] = classIDs.NONE,
        },
        [8968] = { -- The Left Piece of Lord Valthalak's Amulet
            [questKeys.requiredClasses] = classIDs.NONE,
        },
        [8969] = { -- The Left Piece of Lord Valthalak's Amulet
            [questKeys.requiredClasses] = classIDs.NONE,
        },
        [8979] = { -- Fenstad's Hunch
            [questKeys.questLevel] = -1,
            [questKeys.preQuestSingle] = {11558},
        },
        [8980] = { -- Zinge's Assessment
            [questKeys.startedBy] = {{5204}},
            [questKeys.questLevel] = -1,
            [questKeys.preQuestSingle] = {8979},
        },
        [8981] = { -- Gift Giving
            [questKeys.questLevel] = -1,
        },
        [8982] = { -- Tracing the Source
            [questKeys.questLevel] = -1,
        },
        [8983] = { -- Tracing the Source
            [questKeys.questLevel] = -1,
            [questKeys.startedBy] = {{6741}},
            [questKeys.preQuestSingle] = {8982},
        },
        [8984] = { -- The Source Revealed
            [questKeys.questLevel] = -1,
        },
        [8985] = { -- More Components of Importance
            [questKeys.requiredClasses] = classIDs.NONE,
        },
        [8986] = { -- More Components of Importance
            [questKeys.requiredClasses] = classIDs.NONE,
        },
        [8987] = { -- More Components of Importance
            [questKeys.requiredClasses] = classIDs.NONE,
        },
        [8988] = { -- More Components of Importance
            [questKeys.requiredClasses] = classIDs.NONE,
        },
        [8989] = { -- The Right Piece of Lord Valthalak's Amulet
            [questKeys.requiredClasses] = classIDs.NONE,
        },
        [8990] = { -- The Right Piece of Lord Valthalak's Amulet
            [questKeys.requiredClasses] = classIDs.NONE,
        },
        [8991] = { -- The Right Piece of Lord Valthalak's Amulet
            [questKeys.requiredClasses] = classIDs.NONE,
        },
        [8992] = { -- The Right Piece of Lord Valthalak's Amulet
            [questKeys.requiredClasses] = classIDs.NONE,
        },
        [8993] = { -- Gift Giving
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [9024] = { -- Aristan's Hunch
            [questKeys.questLevel] = -1,
        },
        [9025] = { -- Morgan's Discovery
            [questKeys.startedBy] = {{279}},
            [questKeys.questLevel] = -1,
            [questKeys.preQuestSingle] = {9024},
        },
        [9026] = { -- Tracing the Source
            [questKeys.questLevel] = -1,
        },
        [9027] = { -- Tracing the Source
            [questKeys.startedBy] = {{6740}},
            [questKeys.questLevel] = -1,
            [questKeys.preQuestSingle] = {9026},
        },
        [9028] = { -- The Source Revealed
            [questKeys.questLevel] = -1,
        },
        [9029] = { -- A Bubbling Cauldron
            [questKeys.zoneOrSort] = sortKeys.SEASONAL,
        },
        [9035] = { -- Roadside Ambush
            [questKeys.breadcrumbForQuestId] = 9062,
        },
        [9062] = { -- Soaked Pages
            [questKeys.breadcrumbs] = {9035},
        },
        [9063] = { -- Torwa Pathfinder
            [questKeys.startedBy] = {{3033,4217,5505,12042,16655,16721}},
        },
        [9066] = { -- Swift Discipline
            [questKeys.objectives] = {{{15945,nil,Questie.ICON_TYPE_INTERACT},{15941,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [9067] = { -- The Party Never Ends
            [questKeys.breadcrumbs] = {9395},
        },
        [9094] = { -- Argent Dawn Gloves
            [questKeys.zoneOrSort] = sortKeys.INVASION,
        },
        [9130] = { -- Goods from Silvermoon City
            [questKeys.requiredMinRep] = {},
        },
        [9143] = { -- Dealing with Zeb'Sora
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {9145},
        },
        [9144] = { -- Missing in the Ghostlands
            [questKeys.requiredLevel] = 10,
            [questKeys.nextQuestInChain] = 9147,
            [questKeys.breadcrumbForQuestId] = 9147,
        },
        [9145] = { -- Help Ranger Valanna!
            [questKeys.requiredMinRep] = {922,3000},
            [questKeys.breadcrumbForQuestId] = 9143,
        },
        [9147] = { -- The Fallen Courier
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {9144},
        },
        [9149] = { -- The Plagued Coast
            [questKeys.preQuestSingle] = {9327,9329},
        },
        [9151] = { -- The Sanctum of the Sun
            [questKeys.breadcrumbForQuestId] = 9220,
        },
        [9152] = { -- Tomber's Supplies
            [questKeys.preQuestSingle] = {9327,9329},
        },
        [9160] = { -- Investigate An'daroth
            [questKeys.triggerEnd] = {"Investigate An'daroth", {[zoneIDs.GHOSTLANDS] = {{37.13,16.15}}}},
        },
        [9161] = { -- The Traitor's Shadow
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {9282},
        },
        [9164] = { -- Captives at Deatholme
            [questKeys.objectives] = {{{16208,nil,Questie.ICON_TYPE_TALK},{16206,nil,Questie.ICON_TYPE_TALK},{16209,nil,Questie.ICON_TYPE_TALK}}},
        },
        [9174] = { -- Vanquishing Aquantion
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Use the Bundle of Medallions"), 0, {{"object", 181157}}}},
        },
        [9177] = { -- Journey to Undercity
            [questKeys.startedBy] = {{16252}},
            [questKeys.finishedBy] = {{10181}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE - raceIDs.BLOOD_ELF, -- 9180 is the blood elf version of this quest
            [questKeys.preQuestSingle] = {9175},
        },
        [9180] = { -- Journey to Undercity
            [questKeys.requiredRaces] = raceIDs.BLOOD_ELF,
        },
        [9181] = { -- Craftsman's Writ - Volcanic Hammer
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9189] = { -- Delivery to the Sepulcher
            [questKeys.requiredRaces] = raceIDs.BLOOD_ELF
        },
        [9190] = { -- Craftsman's Writ - Runecloth Boots
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9193] = { -- Investigate the Amani Catacombs
            [questKeys.triggerEnd] = {"Investigate the Amani Catacombs", {[zoneIDs.GHOSTLANDS] = {{62.91,30.98}}}},
        },
        [9195] = { -- Craftsman's Writ - Goblin Sapper Charge
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9205] = { -- Craftsman's Writ - Plated Armorfish
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9206] = { -- Craftsman's Writ - Lightning Eel
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9207] = { -- Underlight Ore Samples
            [questKeys.requiredMinRep] = {922,3000},
        },
        [9212] = { -- Escape from the Catacombs
            [questKeys.triggerEnd] = {"Escort Ranger Lilatha back to the Farstrider Enclave", {[zoneIDs.GHOSTLANDS] = {{72.24,30.21}}}},
        },
        [9220] = { -- War on Deatholme
            [questKeys.breadcrumbs] = {9151},
        },
        [9252] = { -- Defending Fairbreeze Village
            [questKeys.breadcrumbs] = {9358},
        },
        [9253] = { -- Runewarden Deryan
            [questKeys.breadcrumbForQuestId] = 8490,
        },
        [9254] = { -- The Wayward Apprentice
            [questKeys.breadcrumbForQuestId] = 8487,
        },
        [9256] = { -- Fairbreeze Village
            [questKeys.breadcrumbForQuestId] = 8892,
        },
        [9258] = { -- The Scorched Grove
            [questKeys.breadcrumbForQuestId] = 8473,
        },
        [9267] = { -- Mending Old Wounds
            [questKeys.requiredLevel] = 15,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9272] = { -- Dressing the Part
            [questKeys.reputationReward] = {{factionIDs.BLOODSAIL_BUCCANEERS,10},{factionIDs.BOOTY_BAY,-250}},
        },
        [9279] = { -- You Survived!
            [questKeys.breadcrumbForQuestId] = 9280,
        },
        [9280] = { -- Replenishing the Healing Crystals
            [questKeys.breadcrumbs] = {9279},
            [questKeys.preQuestSingle] = {},
        },
        [9282] = { -- The Farstrider Enclave
            [questKeys.breadcrumbForQuestId] = 9161,
        },
        [9283] = { -- Rescue the Survivors!
            [questKeys.objectives] = {{{16483,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [9287] = { -- Paladin Training
            [questKeys.preQuestSingle] = {9280},
        },
        [9288] = { -- Hunter Training
            [questKeys.requiredRaces] = raceIDs.DRAENEI,
            [questKeys.preQuestSingle] = {9280},
        },
        [9289] = { -- Warrior Training
            [questKeys.preQuestSingle] = {9280},
            [questKeys.requiredRaces] = raceIDs.DRAENEI,
        },
        [9290] = { -- Mage Training
            [questKeys.startedBy] = {{16500}},
            [questKeys.finishedBy] = {{16500}},
            [questKeys.preQuestSingle] = {9280},
            [questKeys.requiredRaces] = raceIDs.DRAENEI,
        },
        [9291] = { -- Priest Training
            [questKeys.startedBy] = {{16502}},
            [questKeys.finishedBy] = {{16502}},
            [questKeys.requiredRaces] = raceIDs.DRAENEI,
            [questKeys.preQuestSingle] = {9280},
        },
        [9303] = { -- Inoculation
            [questKeys.breadcrumbs] = {10304},
            [questKeys.objectives] = {{{16518,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [9312] = { -- The Emitter
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {9305,9311},
        },
        [9314] = { -- Word from Azure Watch
            [questKeys.requiredLevel] = 1,
        },
        [9317] = { -- Consecrated Sharpening Stones
            [questKeys.zoneOrSort] = sortKeys.INVASION,
        },
        [9318] = { -- Blessed Wizard Oil
            [questKeys.zoneOrSort] = sortKeys.INVASION,
        },
        [9320] = { -- Major Mana Potion
            [questKeys.zoneOrSort] = sortKeys.INVASION,
        },
        [9333] = { -- Argent Dawn Gloves
            [questKeys.zoneOrSort] = sortKeys.INVASION,
        },
        [9334] = { -- Blessed Wizard Oil
            [questKeys.zoneOrSort] = sortKeys.INVASION,
        },
        [9335] = { -- Consecrated Sharpening Stones
            [questKeys.zoneOrSort] = sortKeys.INVASION,
        },
        [9336] = { -- Major Healing Potion
            [questKeys.zoneOrSort] = sortKeys.INVASION,
        },
        [9337] = { -- Major Mana Potion
            [questKeys.zoneOrSort] = sortKeys.INVASION,
        },
        [9340] = { -- The Great Fissure
            [questKeys.breadcrumbs] = {9498,9499},
        },
        [9355] = { -- A Job for an Intelligent Man
            [questKeys.preQuestSingle] = {10143,10483},
        },
        [9358] = { -- Ranger Sareyn
            [questKeys.breadcrumbForQuestId] = 9252,
        },
        [9359] = { -- Farstrider Retreat
            [questKeys.breadcrumbForQuestId] = 8476,
        },
        [9360] = { -- Amani Invasion
            [questKeys.startedBy] = {nil,nil,{23249}},
        },
        [9370] = { -- The Cleansing Must Be Stopped
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Place the Signaling Gem"), 0, {{"object", 181449}}}},
        },
        [9371] = { -- Botanist Taerix
            [questKeys.breadcrumbForQuestId] = 10302,
        },
        [9372] = { -- Demonic Contamination
            [questKeys.breadcrumbs] = {10442,10443},
        },
        [9374] = { -- Arelion's Journal
            [questKeys.requiredSourceItems] = {31955},
        },
        [9375] = { -- The Road to Falcon Watch
            [questKeys.triggerEnd] = {"Escort Wounded Blood Elf Pilgrim to Falcon Watch", {[zoneIDs.HELLFIRE_PENINSULA] = {{27.09,61.92}}}},
        },
        [9383] = { -- An Ambitious Plan
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_LOOT, l10n("Use the Sanctified Crystal against a wounded Uncontrolled Voidwalker"), 0, {{"monster", 16975}}}},
        },
        [9392] = { -- Rogue Training
            [questKeys.requiredRaces] = raceIDs.BLOOD_ELF,
        },
        [9393] = { -- Hunter Training
            [questKeys.requiredRaces] = raceIDs.BLOOD_ELF,
        },
        [9394] = { -- Where's Wyllithen?
            [questKeys.breadcrumbForQuestId] = 8894,
        },
        [9395] = { -- Saltheril's Haven
            [questKeys.breadcrumbForQuestId] = 9067,
        },
        [9397] = { -- Birds of a Feather
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Disturb the nest"), 0, {{"object", 181582}}}},
        },
        [9400] = { -- The Assassin
            [questKeys.preQuestSingle] = {10124,10449},
            [questKeys.triggerEnd] = nil,
            [questKeys.objectives] = {{{17062,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [9402] = { -- Fetch!
            [questKeys.exclusiveTo] = {1882,1884},
        },
        [9403] = { -- The Purest Water
            [questKeys.preQuestSingle] = {1882,1884,9402},
        },
        [9407] = { -- Through the Dark Portal
            [questKeys.breadcrumbForQuestId] = 10120,
        },
        [9410] = { -- A Spirit Guide
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use the Wolf Totem at the location where you found Krun Spinebreaker's body and follow the Ancestral Spirit Wolf."), 0, {{"monster", 17062}}}},
        },
        [9415] = { -- Report to Marshal Bluewall
            [questKeys.availableUntilCompleted] = 9419,
            [questKeys.requiredLevel] = 55,
        },
        [9416] = { -- Report to General Kirika
            [questKeys.availableUntilCompleted] = 9422,
            [questKeys.requiredLevel] = 55,
        },
        [9417] = { -- The Arakkoa Threat
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {9558},
        },
        [9418] = { -- Avruu's Orb
            [questKeys.startedBy] = {nil,nil,{23580}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Take Avruu's Orb to the Haal'eshi Altar"), 0, {{"object", 181606}}}},
        },
        [9419] = { -- Scouring the Desert
            [questKeys.requiredLevel] = 55,
        },
        [9421] = { -- Shaman Training
            [questKeys.preQuestSingle] = {9280,9369},
        },
        [9422] = { -- Scouring the Desert
            [questKeys.requiredLevel] = 55,
        },
        [9423] = { -- Return to Obadei
            [questKeys.nextQuestInChain] = 9424,
        },
        [9424] = { -- Makuru's Vengeance
            [questKeys.nextQuestInChain] = 9543,
        },
        [9425] = { -- Report to Tarren Mill
            [questKeys.requiredRaces] = raceIDs.BLOOD_ELF,
        },
        [9428] = { -- Report to Splintertree Post
            [questKeys.requiredRaces] = raceIDs.BLOOD_ELF,
        },
        [9429] = { -- Travel to Darkshire
            [questKeys.requiredRaces] = raceIDs.DRAENEI,
        },
        [9433] = { -- A Dip in the Moonwell
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use the Robotron Control near the Concealed Command Console hidden in a small cluster of bushes"), 0, {{"object", 181825}}}},
        },
        [9437] = { -- Twilight of the Dawn Runner
            [questKeys.objectives] = {{{17119,nil,Questie.ICON_TYPE_TALK}},nil,{{23657}}},
        },
        [9438] = { -- Messenger to Thrall
            [questKeys.nextQuestInChain] = 9441,
        },
        [9441] = { -- Envoy to the Mag'har
            [questKeys.nextQuestInChain] = 9442,
        },
        [9446] = { -- Tomb of the Lightbringer
            [questKeys.triggerEnd] = {"Escort Anchorite Truuen to Uther's Tomb", {[zoneIDs.WESTERN_PLAGUELANDS] = {{52.06,83.26}}}},
        },
        [9447] = { -- Administering the Salve
            [questKeys.objectives] = {{{16847,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [9454] = { -- The Great Moongraze Hunt
            [questKeys.preQuestSingle] = {},
            [questKeys.disabledByQuest] = 9453,
        },
        [9455] = { -- Strange Findings
            [questKeys.startedBy] = {nil,nil,{23678}},
        },
        [9457] = { -- An Unusual Patron
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use the Gift of Naias near the Altar of Naias"), 0, {{"object", 181636}}}},
        },
        [9460] = { -- Combining Forces
            [questKeys.objectives] = {nil,nil,{{23686,nil,Questie.ICON_TYPE_INTERACT}}}, -- has to be pickpocketed, using interact icon
        },
        [9462] = { -- Call of Fire
            [questKeys.startedBy] = {{17219,23127}},
            [questKeys.breadcrumbForQuestId] = 9464,
            [questKeys.requiredRaces] = raceIDs.DRAENEI,
        },
        [9464] = { -- Call of Fire
            [questKeys.breadcrumbs] = {9462},
            [questKeys.requiredRaces] = raceIDs.DRAENEI,
        },
        [9465] = { -- Call of Fire
            [questKeys.requiredRaces] = raceIDs.DRAENEI,
        },
        [9467] = { -- Call of Fire
            [questKeys.requiredSourceItems] = {24335},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Summon Hauteur using the Ritual Torch"), 0, {{"object", 181672}}}},
            [questKeys.requiredRaces] = raceIDs.DRAENEI,
            [questKeys.nextQuestInChain] = 9468,
        },
        [9468] = { -- Call of Fire
            [questKeys.requiredRaces] = raceIDs.DRAENEI,
        },
        [9472] = { -- Arelion's Mistress
            [questKeys.requiredSourceItems] = {29112},
            [questKeys.objectives] = {{{17226,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [9484] = { -- Taming the Beast
            [questKeys.breadcrumbs] = {9617,10530},
            [questKeys.objectives] = {{{15650,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [9485] = { -- Taming the Beast
            [questKeys.objectives] = {{{16353,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [9486] = { -- Taming the Beast
            [questKeys.objectives] = {{{15652,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [9487] = { -- Arcane Reavers
            [questKeys.requiredRaces] = raceIDs.BLOOD_ELF,
        },
        [9488] = { -- A Simple Robe
            [questKeys.requiredRaces] = raceIDs.BLOOD_ELF,
        },
        [9489] = { -- Cleansing the Scar
            [questKeys.requiredRaces] = raceIDs.BLOOD_ELF,
            [questKeys.objectives] = {{{15938,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [9491] = { -- Greed
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {10372},
            [questKeys.exclusiveTo] = {2379},
        },
        [9492] = { -- Turning the Tide
            [questKeys.zoneOrSort] = zoneIDs.HELLFIRE_CITADEL,
        },
        [9493] = { -- Pride of the Fel Horde
            [questKeys.zoneOrSort] = zoneIDs.HELLFIRE_CITADEL,
        },
        [9494] = { -- Fel Embers
            [questKeys.zoneOrSort] = zoneIDs.HELLFIRE_CITADEL,
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Gather a Fel Ember using Grand Warlock's Amulet"), 0, {{"object", 181679}}}},
        },
        [9495] = { -- The Will of the Warchief
            [questKeys.zoneOrSort] = zoneIDs.HELLFIRE_CITADEL,
        },
        [9496] = { -- Pride of the Fel Horde
            [questKeys.zoneOrSort] = zoneIDs.HELLFIRE_CITADEL,
        },
        [9498] = { -- Falcon Watch
            [questKeys.preQuestSingle] = {10124,10449},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE - raceIDs.BLOOD_ELF,
            [questKeys.breadcrumbForQuestId] = 9340,
        },
        [9499] = { -- Falcon Watch
            [questKeys.preQuestSingle] = {10124,10449},
            [questKeys.requiredRaces] = raceIDs.BLOOD_ELF,
            [questKeys.breadcrumbForQuestId] = 9340,
        },
        [9500] = { -- Call of Water
            [questKeys.startedBy] = {{17212}},
            [questKeys.questLevel] = -1,
            [questKeys.exclusiveTo] = {9502,10490},
            [questKeys.breadcrumbForQuestId] = 9501,
        },
        [9501] = { -- Call of Water
            [questKeys.questLevel] = -1,
            [questKeys.breadcrumbs] = {9500,9502,10490},
        },
        [9502] = { -- Call of Water
            [questKeys.startedBy] = {{17219,23127}},
            [questKeys.exclusiveTo] = {9500,10490},
            [questKeys.breadcrumbForQuestId] = 9501,
        },
        [9503] = { -- Call of Water
            [questKeys.questLevel] = -1,
        },
        [9504] = { -- Call of Water
            [questKeys.questLevel] = -1,
        },
        [9505] = { -- The Prophecy of Velen
            [questKeys.breadcrumbForQuestId] = 9506,
        },
        [9506] = { -- A Small Start
            [questKeys.breadcrumbs] = {9505},
        },
        [9508] = { -- Call of Water
            [questKeys.questLevel] = -1,
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Destroy the barrel using the Skin of Purest Water"), 0, {{"object", 181699}}}},
        },
        [9509] = { -- Call of Water
            [questKeys.questLevel] = -1,
        },
        [9514] = { -- Rune Covered Tablet
            [questKeys.preQuestSingle] = {9506},
            [questKeys.startedBy] = {nil,nil,{23759}},
        },
        [9523] = { -- Precious and Fragile Things Need Special Handling
            [questKeys.preQuestSingle] = {9506,9512},
        },
        [9524] = { -- Imprisoned in the Citadel
            [questKeys.zoneOrSort] = zoneIDs.HELLFIRE_CITADEL,
            [questKeys.objectives] = {{{17290,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [9525] = { -- Imprisoned in the Citadel
            [questKeys.zoneOrSort] = zoneIDs.HELLFIRE_CITADEL,
            [questKeys.objectives] = {{{17296,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.reputationReward] = {{factionIDs.THRALLMAR,500}},
        },
        [9527] = { -- All That Remains
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {10428},
        },
        [9528] = { -- A Cry For Help
            [questKeys.triggerEnd] = {"Magwin Escorted to Safety", {[zoneIDs.AZUREMYST_ISLE] = {{16.38,94.14}}}},
        },
        [9529] = { -- The Stone
            [questKeys.breadcrumbs] = {10788},
        },
        [9531] = { -- Tree's Company
            [questKeys.objectives] = {nil,{{181694}}},
        },
        [9534] = { -- Destroy the Legion
            [questKeys.requiredLevel] = 27,
        },
        [9538] = { -- Learning the Language
            [questKeys.triggerEnd] = {"Stillpine Furbolg Language Primer Read", {[zoneIDs.AZUREMYST_ISLE] = {{49.29,51.07}}}},
        },
        [9544] = { -- The Prophecy of Akida
            [questKeys.requiredSourceItems] = {23801},
            [questKeys.objectives] = {{{17375,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_OBJECT,l10n("Open the cage"),0,{{"object",410019}}}},
        },
        [9545] = { -- The Seer's Relic
            [questKeys.objectives] = {{{16852,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [9547] = { -- Call of Air
            [questKeys.startedBy] = {{17212}},
            [questKeys.breadcrumbForQuestId] = 9552,
        },
        [9549] = { -- Artifacts of the Blacksilt
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {10063},
            [questKeys.nextQuestInChain] = 9550,
        },
        [9551] = { -- Call of Air
            [questKeys.startedBy] = {{17219,23127}},
            [questKeys.breadcrumbForQuestId] = 9552,
        },
        [9552] = { -- Call of Air
            [questKeys.breadcrumbs] = {9547,9551,10491},
        },
        [9555] = { -- Call of Fire
            [questKeys.requiredRaces] = raceIDs.DRAENEI,
        },
        [9557] = { -- Deciphering the Book
            [questKeys.nextQuestInChain] = 9561,
        },
        [9558] = { -- The Longbeards
            [questKeys.preQuestSingle] = {10143,10483},
            [questKeys.breadcrumbForQuestId] = 9417,
        },
        [9560] = { -- Beasts of the Apocalypse!
            [questKeys.preQuestSingle] = {9544},
        },
        [9562] = { -- Murlocs... Why Here? Why Now?
            [questKeys.preQuestSingle] = {9544},
        },
        [9564] = { -- Gurf's Dignity
            [questKeys.preQuestSingle] = {9559},
            [questKeys.availableStartingWith] = 9562,
        },
        [9565] = { -- Search Stillpine Hold
            [questKeys.preQuestGroup] = {},
            [questKeys.preQuestSingle] = {9560,9562}, -- without 9564
        },
        [9567] = { -- Know Thine Enemy
            [questKeys.nextQuestInChain] = 9569,
        },
        [9570] = { -- The Kurken is Lurkin'
            [questKeys.preQuestSingle] = {9565,9573},
        },
        [9572] = { -- Weaken the Ramparts
            [questKeys.zoneOrSort] = zoneIDs.HELLFIRE_CITADEL,
            [questKeys.preQuestSingle] = {10124,10449},
        },
        [9573] = { -- Chieftain Oomooroo
            [questKeys.preQuestSingle] = {9560,9562}, -- without 9564
        },
        [9575] = { -- Weaken the Ramparts
            [questKeys.zoneOrSort] = zoneIDs.HELLFIRE_CITADEL,
            [questKeys.preQuestSingle] = {10143,10483},
        },
        [9576] = { -- Cruelfin's Necklace
            [questKeys.startedBy] = {nil,nil,{23870}},
        },
        [9582] = { -- Strength of One
            [questKeys.requiredSourceItems] = {},
            [questKeys.exclusiveTo] = {1678,1683,1639},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Open the cage"), 0, {{"object", 181849}}}},
        },
        [9586] = { -- Help Tavara
            [questKeys.objectives] = {{{17551,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [9587] = { -- Dark Tidings
            [questKeys.nextQuestInChain] = 9589,
        },
        [9588] = { -- Dark Tidings
            [questKeys.nextQuestInChain] = 9590,
        },
        [9589] = { -- The Blood is Life
            [questKeys.zoneOrSort] = zoneIDs.HELLFIRE_CITADEL,
        },
        [9590] = { -- The Blood is Life
            [questKeys.zoneOrSort] = zoneIDs.HELLFIRE_CITADEL,
        },
        [9591] = { -- Taming the Beast
            [questKeys.breadcrumbs] = {9757},
            [questKeys.objectives] = {{{17217,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [9592] = { -- Taming the Beast
            [questKeys.objectives] = {{{17374,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [9593] = { -- Taming the Beast
            [questKeys.objectives] = {{{17203,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [9594] = { -- Signs of the Legion
            [questKeys.startedBy] = {nil,nil,{23900}},
        },
        [9595] = { -- Control
            [questKeys.exclusiveTo] = {1861,1880},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_SLAY, l10n("Kill Siltfin Murlocs to summon a Quel'dorei Magewrath"), 0, {{"monster", 17190},{"monster", 17191},{"monster", 17192}}}},
        },
        [9598] = { -- Redemption
            [questKeys.breadcrumbs] = {10366},
        },
        [9600] = { -- Redemption
            [questKeys.objectives] = {{{17542,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [9601] = { -- To The Bulwark
            [questKeys.requiredLevel] = 50,
            [questKeys.startedBy] = {{16681,20406}},
            [questKeys.breadcrumbForQuestId] = 10590,
        },
        [9607] = { -- Heart of Rage
            [questKeys.zoneOrSort] = zoneIDs.HELLFIRE_CITADEL,
            [questKeys.triggerEnd] = {"Fully Investigate The Blood Furnace", {[zoneIDs.HELLFIRE_PENINSULA] = {{45.89,51.93}}}},
        },
        [9608] = { -- Heart of Rage
            [questKeys.zoneOrSort] = zoneIDs.HELLFIRE_CITADEL,
            [questKeys.triggerEnd] = {"Fully Investigate The Blood Furnace", {[zoneIDs.HELLFIRE_PENINSULA] = {{45.89,51.93}}}},
        },
        [9609] = { -- Help Watcher Biggs
            [questKeys.breadcrumbForQuestId] = 1396,
        },
        [9616] = { -- Bandits!
            [questKeys.startedBy] = {nil,nil,{23910}},
        },
        [9617] = { -- Seek the Farstriders
            [questKeys.startedBy] = {{3038,3171,3407,16673}},
            [questKeys.breadcrumbForQuestId] = 9484,
        },
        [9619] = { -- The Rune of Summoning
            [questKeys.requiredSourceItems] = {},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Summon the Voidwalker"), 0, {{"object", 181670}}}},
        },
        [9622] = { -- Warn Your People
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {9566,9570},
        },
        [9625] = { -- Elekks Are Serious Business
            [questKeys.nextQuestInChain] = 0,
        },
        [9629] = { -- Catch and Release
            [questKeys.objectives] = {{{17326,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [9630] = { -- Medivh's Journal
            [questKeys.zoneOrSort] = zoneIDs.KARAZHAN,
        },
        [9634] = { -- Alien Predators
            [questKeys.preQuestSingle] = {},
            [questKeys.disabledByQuest] = 9625,
        },
        [9635] = { -- The Zapthrottle Mote Extractor!
            [questKeys.requiredSkill] = {202,305},
        },
        [9636] = { -- The Zapthrottle Mote Extractor!
            [questKeys.requiredSkill] = {202,305},
        },
        [9637] = { -- Kalynna's Request
            [questKeys.zoneOrSort] = zoneIDs.KARAZHAN,
        },
        [9638] = { -- In Good Hands
            [questKeys.zoneOrSort] = zoneIDs.KARAZHAN,
        },
        [9639] = { -- Kamsis
            [questKeys.zoneOrSort] = zoneIDs.KARAZHAN,
        },
        [9640] = { -- The Shade of Aran
            [questKeys.zoneOrSort] = zoneIDs.KARAZHAN,
        },
        [9641] = { -- Irradiated Crystal Shards
            [questKeys.nextQuestInChain] = 9642,
        },
        [9644] = { -- Nightbane
            [questKeys.zoneOrSort] = zoneIDs.KARAZHAN,
        },
        [9645] = { -- The Master's Terrace
            [questKeys.triggerEnd] = {"Journal Entry Read", {[3457] = {{-1,-1}}}},
            [questKeys.zoneOrSort] = zoneIDs.KARAZHAN,
        },
        [9647] = { -- Culling the Flutterers
            [questKeys.preQuestSingle] = {9580,9643}, -- check if 9643 is correct
        },
        [9648] = { -- Mac'Aree Mushroom Menagerie
            [questKeys.name] = "Maatparm Mushroom Menagerie",
            [questKeys.objectivesText] = {"Maatparm at Blood Watch wants 1 Aquatic Stinkhorn, 1 Blood Mushroom, 1 Ruinous Polyspore, and 1 Fel Cone Fungus."},
            [questKeys.nextQuestInChain] = 9649,
        },
        [9649] = { -- Ysera's Tears
            [questKeys.objectivesText] = {"Maatparm at Blood Watch wants 2 Ysera's Tears."},
        },
        [9663] = { -- The Kessel Run
            [questKeys.objectives] = {{{17440,nil,Questie.ICON_TYPE_TALK},{17116,nil,Questie.ICON_TYPE_TALK},{17240,nil,Questie.ICON_TYPE_TALK}}},
        },
        [9666] = { -- Declaration of Power
            [questKeys.objectives] = {{{17701},{17701,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [9667] = { -- Saving Princess Stillpine
            [questKeys.preQuestSingle] = {9559},
            [questKeys.extraObjectives] = {
                {nil,Questie.ICON_TYPE_SLAY, l10n("Kill Bristlelimb Furbolgs to lure High Chief Bristlelimb"), 0, {{"monster", 17320}, {"monster", 17321}}},
                {nil,Questie.ICON_TYPE_OBJECT,l10n("Open the cage"),0,{{"object",181928}}},
            },
            [questKeys.objectives] = {{{17682,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [9669] = { -- The Missing Expedition
            [questKeys.requiredLevel] = 16,
        },
        [9670] = { -- They're Alive! Maybe...
            [questKeys.objectives] = {nil,nil,nil,nil,{{{17681,17680},17681,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [9671] = { -- Urgent Delivery
            [questKeys.requiredLevel] = 15,
        },
        [9677] = { -- Summons from Knight-Lord Bloodvalor
            [questKeys.breadcrumbForQuestId] = 9678,
        },
        [9678] = { -- The First Trial
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Light the brazier"), 0, {{"object", 181956}}}},
            [questKeys.breadcrumbs] = {9677},
        },
        [9683] = { -- Ending the Bloodcurse
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Defile the Statue of Queen Azshara"), 0, {{"object", 181964}}}},
        },
        [9685] = { -- Redeeming the Dead
            [questKeys.startedBy] = {{17717,178420}}, -- TO DO phase-based quest corrections (178420 won't be present in SWP patch)
            [questKeys.preQuestSingle] = {9684,63866},
            [questKeys.objectives] = {{{17768,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [9686] = { -- The Second Trial
            [questKeys.objectives] = {nil,nil,nil,nil,{{{17809,17810,17811,17812},17809}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Start the event"), 0, {{"object", 182052}}}},
        },
        [9688] = { -- Into the Dream
            [questKeys.nextQuestInChain] = 9689,
        },
        [9689] = { -- Razormaw
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Place the Bundle of Dragon Bones at the Ever-burning Pyre"), 0, {{"object", 181988}}}},
        },
        [9692] = { -- The Path of the Adept
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Open it"), 3, {{"object", 182024}}}},
        },
        [9693] = { -- What Argus Means to Me
            [questKeys.disabledByQuest] = 9668,
        },
        [9694] = { -- Blood Watch
            [questKeys.nextQuestInChain] = 9779,
        },
        [9697] = { -- Watcher Leesa'oh
            [questKeys.requiredMinRep] = {942,3000},
            [questKeys.breadcrumbForQuestId] = 9701,
        },
        [9700] = { -- I Shoot Magic Into the Darkness
            [questKeys.triggerEnd] = {"Sun Portal Site Confirmed", {[zoneIDs.BLOODMYST_ISLE] = {{52.92,22.32}}}},
            [questKeys.nextQuestInChain] = 9703,
        },
        [9701] = { -- Observing the Sporelings
            [questKeys.preQuestSingle] = {},
            [questKeys.triggerEnd] = {"Investigate the Spawning Glen", {[zoneIDs.ZANGARMARSH] = {{15.1,61.21}}}},
            [questKeys.requiredLevel] = 61,
            [questKeys.breadcrumbs] = {9697},
        },
        [9703] = { -- The Cryo-Core
            [questKeys.nextQuestInChain] = 9748,
        },
        [9706] = { -- Galaen's Journal - The Fate of Vindicator Saruan
            [questKeys.nextQuestInChain] = 9711,
        },
        [9704] = { -- Slain by the Wretched
            [questKeys.breadcrumbs] = {8347},
            [questKeys.preQuestSingle] = {},
        },
        [9711] = { -- Matis the Cruel
            [questKeys.objectives] = {{{17664,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Call for help from Trackers of the Hand"), 0, {{"monster", 17664}}}},
        },
        [9715] = { -- Bring Me A Shrubbery!
            [questKeys.nextQuestInChain] = 9714,
        },
        [9716] = { -- Disturbance at Umbrafen Lake
            [questKeys.triggerEnd] = {"Umbrafen Lake Investigated", {[zoneIDs.ZANGARMARSH] = {{70.89,80.51}}}},
        },
        [9718] = { -- As the Crow Flies
            [questKeys.triggerEnd] = {"Use the Stormcrow Amulet and explore the lakes of Zangarmarsh", {[zoneIDs.ZANGARMARSH] = {{78.4,62.02}}}},
        },
        [9720] = { -- Balance Must Be Preserved
            [questKeys.objectives] = {{{17998,nil,Questie.ICON_TYPE_EVENT},{18002,nil,Questie.ICON_TYPE_EVENT},{18000,nil,Questie.ICON_TYPE_EVENT},{17999,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [9721] = { -- A Summons from Lord Solanar
            [questKeys.exclusiveTo] = {64139},
        },
        [9722] = { -- The Master's Path
            [questKeys.exclusiveTo] = {64140},
        },
        [9723] = { -- A Gesture of Commitment
            [questKeys.exclusiveTo] = {64141},
        },
        [9725] = { -- A Demonstration of Loyalty
            [questKeys.exclusiveTo] = {64142},
        },
        [9728] = { -- A Warm Welcome
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {9778},
        },
        [9729] = { -- Fhwoor Smash!
            [questKeys.triggerEnd] = {"Ark of Ssslith safely returned to Sporeggar", {[zoneIDs.ZANGARMARSH] = {{19.71,50.72}}}},
        },
        [9731] = { -- Drain Schematics
            [questKeys.triggerEnd] = {"Drain Located", {[zoneIDs.ZANGARMARSH] = {{50.44,40.91}}}},
            [questKeys.preQuestSingle] = {9718}, -- confirmed dropping after this quest. check if drops after 9716
            [questKeys.nextQuestInChain] = 9724,
        },
        [9735] = { -- True Masters of the Light
            [questKeys.exclusiveTo] = {64143},
        },
        [9736] = { -- True Masters of the Light
            [questKeys.exclusiveTo] = {64144},
        },
        [9737] = { -- True Masters of the Light
            [questKeys.startedBy] = {{17076,25223}}, -- p1/p2 offered by 17076
            [questKeys.finishedBy] = {{17076,25223}}, -- p1/p2 finished by 17076
            [questKeys.objectives] = {nil,nil,nil,nil,{{{17910,17911,17912,17913,17914},17910}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Use the Extinguishing Mixture near the eternal flame"), 0, {{"object", 182068}}}},
            [questKeys.exclusiveTo] = {64145}, -- not sure when this one gets introduced in classic
            [questKeys.preQuestSingle] = {9736,64144},
        },
        [9738] = { -- Lost in Action
            [questKeys.preQuestSingle] = {},
            [questKeys.objectives] = {{{17885,nil,Questie.ICON_TYPE_INTERACT},{17893,nil,Questie.ICON_TYPE_INTERACT},{17890,nil,Questie.ICON_TYPE_INTERACT},{17827,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.zoneOrSort] = zoneIDs.COILFANG_RESERVOIR,
            [questKeys.breadcrumbs] = {9876},
        },
        [9739] = { -- The Sporelings' Plight
            [questKeys.requiredMinRep] = {},
            [questKeys.requiredMaxRep] = {},
            [questKeys.nextQuestInChain] = 9742,
        },
        [9740] = { -- The Sun Gate
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Destroy all 4 Sunhawk Portal Controller"), 0, {{"object", 184850}}}},
        },
        [9743] = { -- Natural Enemies
            [questKeys.requiredMinRep] = {},
            [questKeys.requiredMaxRep] = {},
            [questKeys.nextQuestInChain] = 9744,
        },
        [9752] = { -- Escape from Umbrafen
            [questKeys.triggerEnd] = {"Escort Kayra Longmane to safety", {[zoneIDs.ZANGARMARSH] = {{79.76,71.09}}}},
        },
        [9753] = { -- What We Know...
            [questKeys.preQuestSingle] = {},
        },
        [9756] = { -- What We Don't Know...
            [questKeys.objectives] = {{{17824,nil,Questie.ICON_TYPE_TALK}}},
        },
        [9757] = { -- Seek Huntress Kella Nightbow
            [questKeys.requiredRaces] = raceIDs.DRAENEI,
            [questKeys.breadcrumbForQuestId] = 9591,
        },
        [9759] = { -- Ending Their World
            [questKeys.preQuestSingle] = {9756},
            [questKeys.triggerEnd] = {"Vector Coil Destroyed and Sironas Slain", {[zoneIDs.BLOODMYST_ISLE] = {{14.86,54.84}}}},
        },
        [9760] = { -- Vindicator's Rest
            [questKeys.exclusiveTo] = {9759},
        },
        [9765] = { -- Preparing for War
            [questKeys.nextQuestInChain] = 9766,
        },
        [9778] = { -- Warden Hamoot
            [questKeys.breadcrumbForQuestId] = 9728,
        },
        [9785] = { -- Blessings of the Ancients
            [questKeys.objectives] = {{{17900,nil,Questie.ICON_TYPE_TALK},{17901,nil,Questie.ICON_TYPE_TALK}}},
        },
        [9786] = { -- The Boha'mu Ruins
            [questKeys.triggerEnd] = {"Explore the Boha'mu Ruins", {[zoneIDs.ZANGARMARSH] = {{44.13,68.97}}}},
        },
        [9789] = { -- Clefthoof Mastery
            [questKeys.breadcrumbs] = {10113},
        },
        [9796] = { -- News from Zangarmarsh
            [questKeys.requiredLevel] = 62,
            [questKeys.exclusiveTo] = {10105},
        },
        [9798] = { -- Blood Elf Plans
            [questKeys.startedBy] = {nil,nil,{24414}},
            [questKeys.preQuestSingle] = {9309},
        },
        [9802] = { -- Plants of Zangarmarsh
            [questKeys.requiredMaxRep] = {},
        },
        [9805] = { -- Blessing of Incineratus
            [questKeys.objectives] = {{{18110,nil,Questie.ICON_TYPE_EVENT},{18142,nil,Questie.ICON_TYPE_EVENT},{18143,nil,Questie.ICON_TYPE_EVENT},{18144,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [9806] = { -- Fertile Spores
            [questKeys.nextQuestInChain] = 9807,
        },
        [9808] = { -- Glowcap Mushrooms
            [questKeys.requiredMinRep] = {970,0},
            [questKeys.nextQuestInChain] = 9809,
        },
        [9816] = { -- Have You Ever Seen One of These?
            [questKeys.objectives] = {nil,{{182164,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [9824] = { -- Arcane Disturbances
            [questKeys.objectives] = {{{18161,nil,Questie.ICON_TYPE_EVENT},{18162,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.zoneOrSort] = zoneIDs.KARAZHAN,
        },
        [9825] = { -- Restless Activity
            [questKeys.zoneOrSort] = zoneIDs.KARAZHAN,
            [questKeys.breadcrumbs] = {11216},
        },
        [9830] = { -- Stinger Venom
            [questKeys.requiredMinRep] = {978,0},
        },
        [9831] = { -- Entry Into Karazhan
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Open the container"), 0, {{"object", 182196}}}},
        },
        [9832] = { -- The Second and Third Fragments
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_OBJECT, l10n("Open the container"), 1, {{"object", 182197}}},
                {nil, Questie.ICON_TYPE_OBJECT, l10n("Open the container"), 2, {{"object", 182198}}},
            },
            [questKeys.nextQuestInChain] = 9836,
        },
        [9833] = { -- Lines of Communication
            [questKeys.requiredMinRep] = {978,0},
        },
        [9834] = { -- Natural Armor
            [questKeys.requiredMinRep] = {978,0},
        },
        [9836] = { -- The Master's Touch
            [questKeys.objectives] = {{{15608,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [9838] = { -- The Violet Eye
            [questKeys.zoneOrSort] = zoneIDs.KARAZHAN,
        },
        [9840] = { -- Assessing the Situation
            [questKeys.zoneOrSort] = zoneIDs.KARAZHAN,
        },
        [9843] = { -- Keanna's Log
            [questKeys.zoneOrSort] = zoneIDs.KARAZHAN,
        },
        [9844] = { -- A Demonic Presence
            [questKeys.zoneOrSort] = zoneIDs.KARAZHAN,
        },
        [9847] = { -- A Spirit Ally?
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Plant the Feralfen Totem on the ground"), 0, {{"object", 182176}}}},
        },
        [9849] = { -- Shattering the Veil
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use Gordawg's Boulder to shatter Shattered Rumblers into Minions of Gurok"), 0, {{"monster", 17157}}}},
        },
        [9853] = { -- Gurok the Usurper
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use 7 Warmaul Skulls to summon Gurok the Usurper"), 0, {{"object", 182182}}}},
        },
        [9854] = { -- Windroc Mastery
            [questKeys.breadcrumbs] = {10114},
        },
        [9863] = { -- Vile Idolatry
            [questKeys.requiredMinRep] = {941,0},
        },
        [9864] = { -- The Missing War Party
            [questKeys.requiredMinRep] = {941,0},
        },
        [9867] = { -- Murkblood Leaders...
            [questKeys.requiredMinRep] = {941,0},
        },
        [9868] = { -- The Totem of Kar'dash
            [questKeys.triggerEnd] = {"Free the Mag'har Captive", {[zoneIDs.NAGRAND] = {{31.77,38.78}}}},
            [questKeys.requiredMinRep] = {941,0},
        },
        [9869] = { -- The Throne of the Elements
            [questKeys.requiredMinRep] = {978,0},
        },
        [9870] = { -- The Throne of the Elements
            [questKeys.requiredMinRep] = {941,0},
        },
        [9871] = { -- Murkblood Invaders
            [questKeys.startedBy] = {nil,nil,{24559}},
        },
        [9872] = { -- Murkblood Invaders
            [questKeys.startedBy] = {nil,nil,{24558}},
        },
        [9874] = { -- Stopping the Spread
            [questKeys.requiredMinRep] = {978,0},
            [questKeys.objectives] = {{{18240,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [9876] = { -- Failed Incursion
            [questKeys.breadcrumbForQuestId] = 9738,
            [questKeys.nextQuestInChain] = 9738,
        },
        [9878] = { -- Solving the Problem
            [questKeys.requiredMinRep] = {978,0},
        },
        [9879] = { -- The Totem of Kar'dash
            [questKeys.requiredMinRep] = {978,0},
            [questKeys.triggerEnd] = {"Free the Kurenai Captive", {[zoneIDs.NAGRAND] = {{31.57,38.78}}}},
        },
        [9882] = { -- Stealing from Thieves
            [questKeys.breadcrumbs] = {9913},
            [questKeys.nextQuestInChain] = 9883,
        },
        [9884] = { -- Membership Benefits
            [questKeys.questFlags] = questFlags.MONTHLY,
        },
        [9885] = { -- Membership Benefits
            [questKeys.questFlags] = questFlags.MONTHLY,
        },
        [9886] = { -- Membership Benefits
            [questKeys.questFlags] = questFlags.MONTHLY,
        },
        [9887] = { -- Membership Benefits
            [questKeys.questFlags] = questFlags.MONTHLY,
        },
        [9889] = { -- Don't Kill the Fat One
            [questKeys.objectives] = {{{18260},{18262}}},
        },
        [9893] = { -- Obsidian Warbeads
            [questKeys.nextQuestInChain] = 9892,
        },
        [9898] = { -- The Respect of Another
            [questKeys.name] = "The Respect of Another",
        },
        [9902] = { -- The Terror of Marshlight Lake
            [questKeys.requiredMinRep] = {978,0},
        },
        [9905] = { -- Maktu's Revenge
            [questKeys.requiredMinRep] = {978,0},
        },
        [9910] = { -- Standards and Practices
            [questKeys.objectives] = {nil,{{182261},{182264},{182262}}},
        },
        [9911] = { -- The Count of the Marshes
            [questKeys.startedBy] = {nil,nil,{25459}},
        },
        [9913] = { -- The Consortium Needs You!
            [questKeys.breadcrumbForQuestId] = 9882,
            [questKeys.nextQuestInChain] = 9882,
        },
        [9914] = { -- A Head Full of Ivory
            [questKeys.nextQuestInChain] = 9915,
        },
        [9918] = { -- Not On My Watch!
            [questKeys.objectives] = {{{18351,nil,Questie.ICON_TYPE_TALK}}},
        },
        [9923] = { -- HELP!
            [questKeys.requiredMinRep] = {978,0},
            [questKeys.requiredSourceItems] = {25490},
            [questKeys.objectives] = {{{18369,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_OBJECT,l10n("Open the cage"),0,{{"object",182349}}}},
        },
        [9924] = { -- Corki's Gone Missing Again!
            [questKeys.requiredSourceItems] = {25509},
            [questKeys.objectives] = {{{20812,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_OBJECT,l10n("Open the cage"),0,{{"object",182350}}}},
        },
        [9927] = { -- Ruthless Cunning
            [questKeys.objectives] = {nil,nil,nil,nil,{{{17146,17147,17148},17147,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.preQuestSingle] = {10107,10108},
        },
        [9928] = { -- Armaments for Deception
            [questKeys.preQuestSingle] = {10107,10108},
        },
        [9931] = { -- Returning the Favor
            [questKeys.objectives] = {nil,nil,nil,nil,{{{17138,18064},17138,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.preQuestGroup] = {9927,9928},
        },
        [9932] = { -- Body of Evidence
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Make smoke signals"), 0, {{"object", 182369}}}},
            [questKeys.objectives] = {{{18395,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.preQuestGroup] = {9927,9928},
        },
        [9933] = { -- Message to Telaar
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {9931,9932},
        },
        [9934] = { -- Message to Garadar
            [questKeys.preQuestGroup] = {9931,9932},
        },
        [9935] = { -- Wanted: Giselda the Crone
            [questKeys.requiredMinRep] = {941,0},
            [questKeys.objectives] = {{{18391}},nil,nil,nil,{{{17146,17147,17148,18658,21276},21276}}},
        },
        [9936] = { -- Wanted: Giselda the Crone
            [questKeys.requiredMinRep] = {978,0},
            [questKeys.objectives] = {{{18391}},nil,nil,nil,{{{17146,17147,17148,18658,21276},21276}}},
        },
        [9939] = { -- Wanted: Zorbo the Advisor
            [questKeys.requiredMinRep] = {941,0},
        },
        [9940] = { -- Wanted: Zorbo the Advisor
            [questKeys.requiredMinRep] = {978,0},
        },
        [9944] = { -- Missing Mag'hari Procession
            [questKeys.requiredMinRep] = {941,0},
            [questKeys.breadcrumbForQuestId] = 9945,
        },
        [9945] = { -- War on the Warmaul
            [questKeys.requiredMinRep] = {941,0},
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {9944},
        },
        [9948] = { -- Finding the Survivors
            [questKeys.requiredMinRep] = {941,0},
            [questKeys.objectives] = {{{18428,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_OBJECT,l10n("Open the cage"),0,{{"object",182484}}}},
        },
        [9955] = { -- Cho'war the Pillager
            [questKeys.requiredSourceItems] = {25648},
            [questKeys.objectives] = {{{18445,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_OBJECT,l10n("Open the cage"),0,{{"object",182521}}}},
        },
        [9956] = { -- The Ravaged Caravan
            [questKeys.requiredMinRep] = {978,0},
        },
        [9957] = { -- What's Wrong at Cenarion Thicket?
            [questKeys.requiredMinRep] = {942,3000},
            [questKeys.breadcrumbForQuestId] = 9968,
        },
        [9960] = { -- What's Wrong at Cenarion Thicket?
            [questKeys.breadcrumbForQuestId] = 9968, -- TODO check if it has minimum reputation required like 9957
        },
        [9961] = { -- What's Wrong at Cenarion Thicket?
            [questKeys.breadcrumbForQuestId] = 9968, -- TODO check if it has minimum reputation required like 9957
        },
        [9962] = { -- The Ring of Blood: Brokentoe
            [questKeys.nextQuestInChain] = 9967,
        },
        [9967] = { -- The Ring of Blood: The Blue Brothers
            [questKeys.nextQuestInChain] = 9970,
        },
        [9968] = { -- Strange Energy
            [questKeys.breadcrumbs] = {9957,9960,9961},
        },
        [9970] = { -- The Ring of Blood: Rokdar the Sundered Lord
            [questKeys.nextQuestInChain] = 9972,
        },
        [9972] = { -- The Ring of Blood: Skra'gath
            [questKeys.nextQuestInChain] = 9973,
        },
        [9973] = { -- The Ring of Blood: The Warmaul Champion
            [questKeys.nextQuestInChain] = 9977,
        },
        [9978] = { -- By Any Means Necessary
            [questKeys.nextQuestInChain] = 9979,
        },
        [9982] = { -- He Called Himself Altruis...
            [questKeys.requiredMinRep] = {978,0},
            [questKeys.nextQuestInChain] = 9991,
            [questKeys.breadcrumbForQuestId] = 9991,
        },
        [9983] = { -- He Called Himself Altruis...
            [questKeys.requiredMinRep] = {941,0},
            [questKeys.nextQuestInChain] = 9991,
            [questKeys.breadcrumbForQuestId] = 9991,
        },
        [9991] = { -- Survey the Land
            [questKeys.breadcrumbs] = {9982,9983},
            [questKeys.triggerEnd] = {"Forge Camps Surveyed", {[zoneIDs.NAGRAND] = {{27.22,43.05}}}},
            [questKeys.preQuestSingle] = {},
        },
        [10000] = { -- An Unwelcome Presence
            [questKeys.requiredLevel] = 62,
            [questKeys.nextQuestInChain] = 10003,
        },
        [10004] = { -- Patience and Understanding
            [questKeys.objectives] = {{{18584}}},
        },
        [10008] = { -- What Happens in Terokkar Stays in Terokkar
            [questKeys.preQuestSingle] = {},
        },
        [10012] = { -- Fel Orc Plans
            [questKeys.preQuestSingle] = {9998,10000},
        },
        [10013] = { -- An Unseen Hand
            [questKeys.preQuestSingle] = {9998,10000},
        },
        [10017] = { -- Strained Supplies
            [questKeys.preQuestSingle] = {10211},
            [questKeys.requiredMaxRep] = {932,0},
            [questKeys.nextQuestInChain] = 10019,
        },
        [10019] = { -- More Venom Sacs
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {10211,10017},
            [questKeys.requiredMaxRep] = {932,0},
        },
        [10020] = { -- A Cure for Zahlia
            [questKeys.preQuestSingle] = {10551},
        },
        [10021] = { -- Restoring the Light
            [questKeys.preQuestSingle] = {10551},
            [questKeys.requiredMinRep] = {932,0},
        },
        [10024] = { -- Voren'thal's Visions
            [questKeys.preQuestSingle] = {10211},
            [questKeys.requiredMaxRep] = {934,0},
            [questKeys.nextQuestInChain] = 10025,
        },
        [10025] = { -- More Basilisk Eyes
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {10211,10024},
            [questKeys.requiredMaxRep] = {934,0},
        },
        [10035] = { -- Torgos!
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Place the carcass"), 0, {{"object", 184842}}}},
        },
        [10036] = { -- Torgos!
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Place the carcass"), 0, {{"object", 184842}}}},
        },
        [10039] = { -- Speak with Scout Neftis
            [questKeys.requiredLevel] = 62,
        },
        [10040] = { -- Who Are They?
            [questKeys.objectives] = {{{18716,nil,Questie.ICON_TYPE_TALK},{18717,nil,Questie.ICON_TYPE_TALK},{18719,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Get a disguise"), 0, {{"monster", 18715}}}},
        },
        [10041] = { -- Who Are They?
            [questKeys.objectives] = {{{18716,nil,Questie.ICON_TYPE_TALK},{18717,nil,Questie.ICON_TYPE_TALK},{18719,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Get a disguise"), 0, {{"monster", 18714}}}},
        },
        [10044] = { -- A Visit With the Greatmother
            [questKeys.objectives] = {{{18141,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.preQuestGroup] = {9934,9868,10011},
            [questKeys.preQuestSingle] = {},
        },
        [10047] = { -- The Path of Glory
            [questKeys.preQuestSingle] = {10143,10483},
        },
        [10050] = { -- Unyielding Souls
            [questKeys.preQuestSingle] = {10143,10483},
        },
        [10051] = { -- Escape from Firewing Point!
            [questKeys.triggerEnd] = {"Escort Isla Starmane to safety", {[zoneIDs.TEROKKAR_FOREST] = {{67.51,37.28}}}},
        },
        [10052] = { -- Escape from Firewing Point!
            [questKeys.triggerEnd] = {"Escort Isla Starmane to safety", {[zoneIDs.TEROKKAR_FOREST] = {{67.51,37.28}}}},
        },
        [10058] = { -- An Old Gift
            [questKeys.preQuestSingle] = {10143,10483},
        },
        [10063] = { -- Explorers' League, Is That Something for Gnomes?
            [questKeys.breadcrumbForQuestId] = 9549,
            [questKeys.nextQuestInChain] = 9549,
        },
        [10066] = { -- Oh, the Tangled Webs They Weave
            [questKeys.startedBy] = {{17986,18020,18024}},
        },
        [10067] = { -- Fouled Water Spirits
            [questKeys.startedBy] = {{17986,18020,18024}},
        },
        [10068] = { -- Well Watcher Solanian
            [questKeys.startedBy] = {{15279}},
            [questKeys.breadcrumbForQuestId] = 8330,
            [questKeys.preQuestSingle] = {8328},
            [questKeys.requiredRaces] = raceIDs.BLOOD_ELF,
            [questKeys.requiredClasses] = classIDs.MAGE,
        },
        [10069] = { -- Well Watcher Solanian
            [questKeys.startedBy] = {{15280}},
            [questKeys.breadcrumbForQuestId] = 8330,
            [questKeys.preQuestSingle] = {9676},
            [questKeys.requiredRaces] = raceIDs.BLOOD_ELF,
            [questKeys.requiredClasses] = classIDs.PALADIN,
        },
        [10070] = { -- Well Watcher Solanian
            [questKeys.startedBy] = {{15513}},
            [questKeys.breadcrumbForQuestId] = 8330,
            [questKeys.preQuestSingle] = {9393},
            [questKeys.requiredRaces] = raceIDs.BLOOD_ELF,
            [questKeys.requiredClasses] = classIDs.HUNTER,
        },
        [10071] = { -- Well Watcher Solanian
            [questKeys.breadcrumbForQuestId] = 8330,
            [questKeys.requiredRaces] = raceIDs.BLOOD_ELF,
            [questKeys.requiredClasses] = classIDs.ROGUE,
        },
        [10072] = { -- Well Watcher Solanian
            [questKeys.startedBy] = {{15284}},
            [questKeys.breadcrumbForQuestId] = 8330,
            [questKeys.preQuestSingle] = {8564},
            [questKeys.requiredRaces] = raceIDs.BLOOD_ELF,
            [questKeys.requiredClasses] = classIDs.PRIEST,
        },
        [10073] = { -- Well Watcher Solanian
            [questKeys.breadcrumbForQuestId] = 8330,
            [questKeys.requiredRaces] = raceIDs.BLOOD_ELF,
            [questKeys.requiredClasses] = classIDs.WARLOCK,
        },
        [10074] = { -- Oshu'gun Crystal Powder
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.nextQuestInChain] = 10075,
        },
        [10075] = { -- Oshu'gun Crystal Powder
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [10076] = { -- Oshu'gun Crystal Powder
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.nextQuestInChain] = 10077,
        },
        [10077] = { -- Oshu'gun Crystal Powder
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [10078] = { -- Laying Waste to the Unwanted
            [questKeys.objectives] = {{{18818,nil,Questie.ICON_TYPE_EVENT},{21237,nil,Questie.ICON_TYPE_EVENT},{19009,nil,Questie.ICON_TYPE_EVENT},{21236,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [10079] = { -- When This Mine's a-Rockin'
            [questKeys.preQuestSingle] = {10143,10483},
        },
        [10085] = { -- A Visit With The Ancestors
            [questKeys.objectives] = {{{18840,nil,Questie.ICON_TYPE_EVENT},{18841,nil,Questie.ICON_TYPE_EVENT},{18842,nil,Questie.ICON_TYPE_EVENT},{18843,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [10087] = { -- Burn It Up... For the Horde!
            [questKeys.objectives] = {{{18849,nil,Questie.ICON_TYPE_EVENT},{19008,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [10091] = { -- The Soul Devices
            [questKeys.preQuestSingle] = {10178},
            [questKeys.zoneOrSort] = zoneIDs.AUCHINDOUN_DUNGEONS,
        },
        [10094] = { -- The Codex of Blood
            [questKeys.zoneOrSort] = zoneIDs.AUCHINDOUN_DUNGEONS,
            [questKeys.breadcrumbs] = {10177},
        },
        [10095] = { -- Into the Heart of the Labyrinth
            [questKeys.zoneOrSort] = zoneIDs.AUCHINDOUN_DUNGEONS,
            [questKeys.preQuestSingle] = {10094},
        },
        [10097] = { -- Brother Against Brother
            [questKeys.zoneOrSort] = zoneIDs.AUCHINDOUN_DUNGEONS,
            [questKeys.breadcrumbs] = {10180},
        },
        [10098] = { -- Terokk's Legacy
            [questKeys.zoneOrSort] = zoneIDs.AUCHINDOUN_DUNGEONS,
        },
        [10105] = { -- News for Rakoria
            [questKeys.exclusiveTo] = {9796},
        },
        [10106] = { -- Hellfire Fortifications A
            [questKeys.questLevel] = -1,
            [questKeys.preQuestSingle] = {10143,10483},
            [questKeys.requiredMaxRep] = {},
            [questKeys.objectives] = {{{19028,nil,Questie.ICON_TYPE_EVENT},{19029,nil,Questie.ICON_TYPE_EVENT},{19032,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [10107] = { -- Diplomatic Measures
            [questKeys.objectives] = {{{18261,nil,Questie.ICON_TYPE_TALK}}},
        },
        [10108] = { -- Diplomatic Measures
            [questKeys.objectives] = {{{18261,nil,Questie.ICON_TYPE_TALK}}},
        },
        [10110] = { -- Hellfire Fortifications H
            [questKeys.questLevel] = -1,
            [questKeys.preQuestSingle] = {10124,10449},
            [questKeys.requiredMaxRep] = {},
            [questKeys.objectives] = {{{19028,nil,Questie.ICON_TYPE_EVENT},{19029,nil,Questie.ICON_TYPE_EVENT},{19032,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [10111] = { -- Bring Me The Egg!
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Jump!"), 0, {{"object", 183146}}}},
        },
        [10113] = { -- The Nesingwary Safari
            [questKeys.breadcrumbForQuestId] = 9789,
            [questKeys.nextQuestInChain] = 9789,
            [questKeys.requiredLevel] = 64,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [10114] = { -- The Nesingwary Safari
            [questKeys.breadcrumbForQuestId] = 9854,
            [questKeys.nextQuestInChain] = 9854,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [10119] = { -- Through the Dark Portal
            [questKeys.breadcrumbForQuestId] = 10288,
        },
        [10120] = { -- Arrival in Outland
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {9407},
        },
        [10121] = { -- Eradicate the Burning Legion
            [questKeys.preQuestSingle] = {},
        },
        [10129] = { -- Mission: Gateways Murketh and Shaadraz
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Speak with Wing Commander Brack"), 0, {{"monster", 19401}}}},
            [questKeys.objectives] = {nil,{{183350},{183351}}},
        },
        [10144] = { -- Disrupt Their Reinforcements
            [questKeys.nextQuestInChain] = 10146,
            [questKeys.objectives] = {nil,{{184414},{184415}}},
        },
        [10146] = { -- Mission: The Murketh and Shaadraz Gateways
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Speak with Wing Commander Dabir'ee"), 0, {{"monster", 19409}}}},
            [questKeys.objectives] = {nil,{{183350},{183351}}},
        },
        [10160] = { -- Know your Enemy
            [questKeys.breadcrumbForQuestId] = 10482,
        },
        [10162] = { -- Mission: The Abyssal Shelf
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Speak with Wing Commander Brack"), 0, {{"monster", 19401}}}},
            [questKeys.nextQuestInChain] = 10347,
        },
        [10163] = { -- Mission: The Abyssal Shelf
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Speak with Gryphoneer Windbellow"), 0, {{"monster", 20235}}}},
            [questKeys.preQuestSingle] = {10146},
            [questKeys.breadcrumbs] = {10344},
            [questKeys.nextQuestInChain] = 10382,
        },
        [10168] = { -- What the Soul Sees
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use the Soul Mirror near Ancient Orc Ancestors to summon Darkened Spirits."), 0, {{"monster", 18688}}}},
        },
        [10172] = { -- There Is No Hope
            [questKeys.objectives] = {{{18141,nil,Questie.ICON_TYPE_TALK}}},
        },
        [10176] = { -- Ar'kelos the Guardian
            [questKeys.nextQuestInChain] = 10256,
        },
        [10177] = { -- Trouble at Auchindoun
            [questKeys.breadcrumbForQuestId] = 10094,
            [questKeys.zoneOrSort] = zoneIDs.AUCHINDOUN_DUNGEONS,
        },
        [10178] = { -- Find Spy To'gun
            [questKeys.zoneOrSort] = zoneIDs.AUCHINDOUN_DUNGEONS,
        },
        [10180] = { -- Can't Stay Away
            [questKeys.breadcrumbForQuestId] = 10097,
        },
        [10182] = { -- Battle-Mage Dathric
            [questKeys.objectives] = {nil,{{183269}}},
        },
        [10183] = { -- Off To Area 52
            [questKeys.breadcrumbForQuestId] = 10186,
            [questKeys.exclusiveTo] = {11036,11037,11038,11039,11040,11042},
        },
        [10184] = { -- Malevolent Remnants
            [questKeys.preQuestSingle] = {10300},
        },
        [10186] = { -- You're Hired!
            [questKeys.breadcrumbs] = {10183,11036,11037,11040,11042},
        },
        [10189] = { -- Manaforge B'naar
            [questKeys.preQuestSingle] = {10551,10552},
            [questKeys.requiredMinRep] = {934,3000},
            [questKeys.breadcrumbs] = {11039},
        },
        [10190] = { -- Recharging the Batteries
            [questKeys.objectives] = {{{18879,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [10191] = { -- Mark V is Alive!
            [questKeys.triggerEnd] = {"Escort the Maxx A. Million Mk. V safely through the Ruins of Enkaat", {[zoneIDs.NETHERSTORM] = {{31.54,56.47}}}},
        },
        [10198] = { -- Information Gathering
            [questKeys.triggerEnd] = {"Information Gathering", {[zoneIDs.NETHERSTORM] = {{48.18,84.08}}}},
        },
        [10200] = { -- Return to Thalodien
            [questKeys.requiredMinRep] = {934,3000},
        },
        [10201] = { -- And Now, the Moment of Truth
            [questKeys.objectives] = {{{19606,nil,Questie.ICON_TYPE_TALK}}},
        },
        [10203] = { -- Invaluable Asset Zapping
            [questKeys.nextQuestInChain] = 10221,
        },
        [10204] = { -- Bloodgem Crystals
            [questKeys.triggerEnd] = {"Siphon Bloodgem Crystal", {[zoneIDs.NETHERSTORM] = {{25.42,66.51},{22.37,65.73}}}},
            [questKeys.requiredSourceItems] = {28452},
        },
        [10210] = { -- A'dal
            [questKeys.nextQuestInChain] = 10211,
        },
        [10211] = { -- City of Light
            [questKeys.triggerEnd] = {"City of Light", {[zoneIDs.SHATTRATH_CITY] = {{50.45,42.93}}}},
        },
        [10216] = { -- Safety Is Job One
            [questKeys.nextQuestInChain] = 10218,
        },
        [10218] = { -- Someone Else's Hard Work Pays Off
            [questKeys.triggerEnd] = {"Escort Cryo-Engineer Sha'heen", {[zoneIDs.MANA_TOMBS] = {{-1,-1}}}},
        },
        [10222] = { -- The Sunfury Garrison
            [questKeys.preQuestSingle] = {10188},
        },
        [10226] = { -- Elemental Power Extraction
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_SLAY, l10n("Use the Elemental Power Extractor before killing it"), 0, {{"monster", 18865},{"monster", 18881}}}},
        },
        [10231] = { -- What Book? I Don't See Any Book.
            [questKeys.objectives] = {{{19720}}},
        },
        [10234] = { -- One Demon's Trash...
            [questKeys.breadcrumbs] = {10333},
            [questKeys.preQuestSingle] = {10206},
        },
        [10240] = { -- Building a Perimeter
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Activate the rune"), 0, {{"object", 183947}}}},
            [questKeys.objectives] = {{{19866,nil, Questie.ICON_TYPE_EVENT},{19867,nil, Questie.ICON_TYPE_EVENT},{19868,nil, Questie.ICON_TYPE_EVENT}}},
        },
        [10241] = { -- Distraction at Manaforge B'naar
            [questKeys.breadcrumbs] = {11038},
        },
        [10242] = { -- Spinebreaker Post
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Take a ride to Spinebreaker Post"), 0, {{"monster", 19401}}}},
            [questKeys.nextQuestInChain] = 10538,
        },
        [10243] = { -- Naaru Technology
            [questKeys.preQuestSingle] = {10241},
        },
        [10246] = { -- Attack on Manaforge Coruu
            [questKeys.preQuestSingle] = {10299},
        },
        [10248] = { -- You, Robot
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Take control of the Scrap Reaver X6000."), 0, {{"monster", 19849}}}},
        },
        [10250] = { -- Bloody Vengeance
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Blow the Unyielding Battle Horn near the Alliance Banner"), 0, {{"object", 184005}}}},
        },
        [10253] = { -- Levixus the Soul Caller
            [questKeys.nextQuestInChain] = 10164,
        },
        [10255] = { -- Testing the Antidote
            [questKeys.objectives] = {{{16880,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [10256] = { -- Finding the Keymaster
            [questKeys.objectives] = {{{19938,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Use Apex's Crystal Focus near Archmage Vargoth's Orb"), 0, {{"object", 183507}}}},
        },
        [10262] = { -- A Heap of Ethereals
            [questKeys.nextQuestInChain] = 10205,
        },
        [10263] = { -- Assisting the Consortium
            [questKeys.preQuestGroup] = {10551,10186},
            [questKeys.requiredMinRep] = {932,3000},
            [questKeys.breadcrumbForQuestId] = 10265,
        },
        [10264] = { -- Assisting the Consortium
            [questKeys.preQuestGroup] = {10552,10186},
            [questKeys.requiredMinRep] = {934,3000},
            [questKeys.breadcrumbForQuestId] = 10265,
        },
        [10265] = { -- Consortium Crystal Collection
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {10263,10264},
        },
        [10269] = { -- Triangulation Point One
            [questKeys.triggerEnd] = {"First triangulation point discovered", {[zoneIDs.NETHERSTORM] = {{66.67,33.85}}}},
        },
        [10270] = { -- A Not-So-Modest Proposal
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Communicate with Wind Trader Marid"), 0, {{"object", 184073}}}},
        },
        [10274] = { -- Securing the Celestial Ridge
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use the Challenge of the Blue Fight to challenge Veraku"), 0, {{"object", 184108}}}},
        },
        [10275] = { -- Triangulation Point Two
            [questKeys.triggerEnd] = {"Second triangulation point discovered", {[zoneIDs.NETHERSTORM] = {{28.92,41.25}}}},
        },
        [10277] = { -- The Caverns of Time
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {10279},
            [questKeys.triggerEnd] = {"Caverns of Time Explained", {[zoneIDs.TANARIS] = {{58.87,54.3}}}},
            [questKeys.nextQuestInChain] = 10282,
        },
        [10279] = { -- To The Master's Lair
            [questKeys.breadcrumbForQuestId] = 10277,
        },
        [10283] = { -- Taretha's Diversion
            [questKeys.objectives] = {nil,{{182589}}},
        },
        [10285] = { -- Return to Andormu
            [questKeys.nextQuestInChain] = 10296,
        },
        [10288] = { -- Arrival in Outland
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {10119},
        },
        [10289] = { -- Journey to Thrallmar
            [questKeys.breadcrumbForQuestId] = 10291,
        },
        [10291] = { -- Report to Nazgrel
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {10289},
            [questKeys.nextQuestInChain] = 0,
        },
        [10296] = { -- The Black Morass
            [questKeys.startedBy] = {{20130}},
        },
        [10297] = { -- The Opening of the Dark Portal
            [questKeys.objectives] = {{{15608,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [10299] = { -- Shutting Down Manaforge B'naar
            [questKeys.objectives] = {nil,{{183770}},{{29366}}},
        },
        [10302] = { -- Volatile Mutations
            [questKeys.breadcrumbs] = {9371},
            [questKeys.preQuestSingle] = {},
        },
        [10304] = { -- Vindicator Aldar
            [questKeys.breadcrumbForQuestId] = 9303,
        },
        [10305] = { -- Abjurist Belmara
            [questKeys.objectives] = {nil,{{183268}}},
        },
        [10306] = { -- Conjurer Luminrath
            [questKeys.objectives] = {nil,{{183267}}},
        },
        [10307] = { -- Cohlien Frostweaver
            [questKeys.objectives] = {nil,{{183266}}},
        },
        [10308] = { -- Another Heap of Ethereals
            [questKeys.requiredMinRep] = {933,0},
        },
        [10310] = { -- Sabotage the Warp-Gate!
            [questKeys.preQuestSingle] = {},
            [questKeys.triggerEnd] = {"Burning Legion warp-gate sabotaged", {[zoneIDs.NETHERSTORM] = {{48.14,63.38}}}},
            [questKeys.breadcrumbs] = {10311},
        },
        [10311] = { -- Drijya Needs Your Help
            [questKeys.breadcrumbForQuestId] = 10310,
        },
        [10313] = { -- Measuring Warp Energies
            [questKeys.objectives] = {{{20333,nil,Questie.ICON_TYPE_EVENT},{20336,nil,Questie.ICON_TYPE_EVENT},{20337,nil,Questie.ICON_TYPE_EVENT},{20338,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [10321] = { -- Shutting Down Manaforge Coruu
            [questKeys.objectives] = {nil,{{183956}},{{29396}}},
        },
        [10322] = { -- Shutting Down Manaforge Duro
            [questKeys.objectives] = {nil,{{184311}},{{29397}}},
        },
        [10323] = { -- Shutting Down Manaforge Ara
            [questKeys.objectives] = {nil,{{184312}},{{29411}}},
        },
        [10325] = { -- Marks of Kil'jaeden
            [questKeys.requiredMaxRep] = {},
            [questKeys.preQuestSingle] = {10551,10552},
        },
        [10326] = { -- More Marks of Kil'jaeden
            [questKeys.requiredMaxRep] = {932,9000},
            [questKeys.preQuestGroup] = {10551,10325},
            [questKeys.preQuestSingle] = {},
        },
        [10327] = { -- Single Mark of Kil'jaeden
            [questKeys.requiredMaxRep] = {932,9000},
            [questKeys.preQuestGroup] = {10551,10325},
            [questKeys.preQuestSingle] = {},
        },
        [10329] = { -- Shutting Down Manaforge B'naar
            [questKeys.objectives] = {nil,{{183770}},{{29366}}},
        },
        [10330] = { -- Shutting Down Manaforge Coruu
            [questKeys.objectives] = {nil,{{183956}},{{29396}}},
        },
        [10333] = { -- Help Mama Wheeler
            [questKeys.breadcrumbForQuestId] = 10234,
        },
        [10334] = { -- Needs More Cowbell
            [questKeys.nextQuestInChain] = 10337,
        },
        [10335] = { -- Surveying the Ruins
            [questKeys.objectives] = {{{20473,nil,Questie.ICON_TYPE_EVENT},{20475,nil,Questie.ICON_TYPE_EVENT},{20476,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [10337] = { -- When the Cows Come Home
            [questKeys.triggerEnd] = {"Escort Bessy on her way home.", {[zoneIDs.NETHERSTORM] = {{57.71,84.97}}}},
        },
        [10338] = { -- Shutting Down Manaforge Duro
            [questKeys.objectives] = {nil,{{184311}},{{29397}}},
        },
        [10339] = { -- The Ethereum
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Communicate with Commander Ameer"), 0, {{"object", 410018}}}},
        },
        [10340] = { -- Shatter Point
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Speak with Wing Commander Dabir'ee"), 0, {{"monster", 19409}}}},
        },
        [10344] = { -- Wing Commander Gryphongar
            [questKeys.breadcrumbForQuestId] = 10163,
            [questKeys.nextQuestInChain] = 10163,
        },
        [10345] = { -- The Flesh Lies...
            [questKeys.objectives] = {{{20561,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [10349] = { -- The Earthbinder
            [questKeys.nextQuestInChain] = 10351,
        },
        [10350] = { -- Behomat
            [questKeys.preQuestSingle] = {1639,1678,1683,9582},
        },
        [10352] = { -- A Donation of Wool
            [questKeys.startedBy] = {{14725}},
            [questKeys.finishedBy] = {{14725}},
            [questKeys.reputationReward] = {{factionIDs.DARNASSUS,350}},
        },
        [10354] = { -- A Donation of Silk
            [questKeys.startedBy] = {{14725}},
            [questKeys.finishedBy] = {{14725}},
            [questKeys.reputationReward] = {{factionIDs.DARNASSUS,350}},
        },
        [10357] = { -- A Donation of Runecloth
            [questKeys.preQuestGroup] = {7792,7798,10356},
            [questKeys.nextQuestInChain] = 10358,
        },
        [10362] = { -- A Donation of Runecloth
            [questKeys.preQuestGroup] = {10359,10360,10361},
            [questKeys.nextQuestInChain] = 10363,
        },
        [10365] = { -- Shutting Down Manaforge Ara
            [questKeys.objectives] = {nil,{{184312}},{{29411}}},
        },
        [10366] = { -- Jol
            [questKeys.breadcrumbForQuestId] = 9598,
            [questKeys.requiredRaces] = raceIDs.DRAENEI + raceIDs.HUMAN + raceIDs.DWARF,
        },
        [10367] = { -- A Traitor Among Us
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {10403},
        },
        [10368] = { -- The Dreghood Elders
            [questKeys.objectives] = {{{20677,nil,Questie.ICON_TYPE_TALK},{20678,nil,Questie.ICON_TYPE_TALK},{20679,nil,Questie.ICON_TYPE_TALK}}},
        },
        [10369] = { -- Arzeth's Demise
            [questKeys.objectives] = {{{19354}}},
        },
        [10371] = { -- Yorus Barleybrew
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.exclusiveTo] = {1698},
            [questKeys.breadcrumbForQuestId] = 1699,
        },
        [10372] = { -- A Discreet Inquiry
            [questKeys.requiredLevel] = 16,
            [questKeys.breadcrumbForQuestId] = 9491,
        },
        [10373] = { -- A Call to Arms: The Plaguelands!
            [questKeys.exclusiveTo] = {5066,5090,5091},
            [questKeys.breadcrumbForQuestId] = 5092,
        },
        [10374] = { -- A Call to Arms: The Plaguelands!
            [questKeys.exclusiveTo] = {5093,5094,5095},
            [questKeys.breadcrumbForQuestId] = 5096,
        },
        [10381] = { -- Aldor No More
            [questKeys.nextQuestInChain] = 10407,
        },
        [10382] = { -- Go to the Front
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Speak with Gryphoneer Windbellow"), 0, {{"monster", 20235}}}},
        },
        [10384] = { -- Ethereum Data
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Communicate with Commander Ameer"), 0, {{"object", 410018}}}},
        },
        [10385] = { -- Potential for Brain Damage = High
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Communicate with Commander Ameer"), 0, {{"object", 410018}}}},
        },
        [10388] = { -- Return to Thrallmar
            [questKeys.startedBy] = {{16576,19273}},
            [questKeys.preQuestSingle] = {10129},
        },
        [10389] = { -- The Agony and the Darkness
            [questKeys.preQuestSingle] = {10392},
        },
        [10392] = { -- Doorway to the Abyss
            [questKeys.nextQuestInChain] = 10136,
        },
        [10403] = { -- Naladu
            [questKeys.startedBy] = {{20677,20678,20679}},
            [questKeys.breadcrumbForQuestId] = 10367,
        },
        [10405] = { -- S-A-B-O-T-A-G-E
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Communicate with Commander Ameer"), 0, {{"object", 410018}}}},
        },
        [10406] = { -- Delivering the Message
            [questKeys.triggerEnd] = {"Ethereum Conduit Sabotaged", {[zoneIDs.NETHERSTORM] = {{56.42,42.66}}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Communicate with Commander Ameer"), 0, {{"object", 410018}}}},
        },
        [10408] = { -- Nexus-King Salhadaar
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Communicate with Commander Ameer"), 0, {{"object", 410018}}}},
        },
        [10409] = { -- Deathblow to the Legion
            [questKeys.objectives] = {{{20132}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Take the portal to Socrethar's Seat"), 0, {{"object", 410016}}},
                                           {nil, Questie.ICON_TYPE_OBJECT, l10n("Take the portal back to Invasion Point: Overlord"), 0, {{"object", 410017}}},
                                           {nil, Questie.ICON_TYPE_TALK, l10n("When at Socrethar's Seat, ask for his help against Socrethar"), 0, {{"monster", 18537}}},
                                           {{[zoneIDs.NETHERSTORM] = {{36.44,18.35}}}, Questie.ICON_TYPE_EVENT, l10n("Open a portal to Socrethar's Seat with Socrethar's Teleporting Stone")},
                                           {{[zoneIDs.NETHERSTORM] = {{30.56,17.69}}}, Questie.ICON_TYPE_EVENT, l10n("After defeating Socrethar, you can open a portal back")},
            },
        },
        [10411] = { -- Electro-Shock Goodness!
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_SLAY, l10n("Use Navuud's Concoction before attacking Seeping Sludges"), 1, {{"monster", 20501}}},
                                           {nil, Questie.ICON_TYPE_SLAY, l10n("Use Navuud's Concoction before attacking Void Wastes"), 2, {{"monster", 20778}}},
            },
        },
        [10412] = { -- Firewing Signets
            [questKeys.requiredMaxRep] = {},
            [questKeys.preQuestSingle] = {10551,10552},
        },
        [10414] = { -- Single Firewing Signet
            [questKeys.requiredMaxRep] = {934,9000},
            [questKeys.preQuestGroup] = {10412,10552},
            [questKeys.preQuestSingle] = {},
        },
        [10415] = { -- More Firewing Signets
            [questKeys.requiredMaxRep] = {934,9000},
            [questKeys.preQuestGroup] = {10412,10552},
            [questKeys.preQuestSingle] = {},
        },
        [10416] = { -- Synthesis of Power
            [questKeys.nextQuestInChain] = 10419,
        },
        [10420] = { -- A Cleansing Light
            [questKeys.nextQuestInChain] = 10421,
        },
        [10422] = { -- Captain Tyralius
            [questKeys.requiredSourceItems] = {29742},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Open the prison"), 0, {{"object", 184588}}}},
            [questKeys.objectives] = {nil,nil,nil,nil,{{{20787,20825},20787,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [10425] = { -- Escape from the Staging Grounds
            [questKeys.triggerEnd] = {"Captured Protectorate Vanguard Escorted", {[zoneIDs.NETHERSTORM] = {{58.9,32.43}}}},
        },
        [10426] = { -- Flora of the Eco-Domes
            [questKeys.objectives] = {{{20774,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [10427] = { -- Creatures of the Eco-Domes
            [questKeys.objectives] = {nil,nil,nil,nil,{{{20610,20777},20777,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [10428] = { -- The Missing Fisherman
            [questKeys.breadcrumbForQuestId] = 9527,
        },
        [10436] = { -- All Clear!
            [questKeys.nextQuestInChain] = 10440,
        },
        [10438] = { -- On Nethery Wings
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Mount up"), 0, {{"monster", 20903}}}},
        },
        [10439] = { -- Dimensius the All-Devouring
            [questKeys.objectives] = {{{19554},{20985,nil,Questie.ICON_TYPE_TALK}}},
        },
        [10442] = { -- Helping the Cenarion Post
            [questKeys.breadcrumbForQuestId] = 9372,
        },
        [10443] = { -- Helping the Cenarion Post
            [questKeys.breadcrumbForQuestId] = 9372,
        },
        [10445] = { -- The Vials of Eternity
            [questKeys.startedBy] = {{19935,19936}},
        },
        [10446] = { -- The Final Code
            [questKeys.objectives] = {nil,{{184725,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.nextQuestInChain] = 10005,
        },
        [10447] = { -- The Final Code
            [questKeys.objectives] = {nil,{{184725,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.nextQuestInChain] = 10006,
        },
        [10449] = { -- Apothecary Zelana
            [questKeys.nextQuestInChain] = 10242,
        },
        [10451] = { -- Escape from Coilskar Cistern
            [questKeys.triggerEnd] = {"Earthmender Wilda Escorted to Safety", {[zoneIDs.SHADOWMOON_VALLEY] = {{53.14,25.17}}}},
        },
        [10458] = { -- Enraged Spirits of Fire and Earth
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {10680,10681},
            [questKeys.objectives] = {{{21050},{21061}}},
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_EVENT, l10n("Use the Totem of Spirits on Enraged Earth and Fiery Spirits"), 1, {{"monster", 21050}}},
                {nil, Questie.ICON_TYPE_EVENT, l10n("Use the Totem of Spirits on Enraged Earth and Fiery Spirits"), 2, {{"monster", 21061}}},
            },
        },
        [10460] = { -- Defender's Pledge
            [questKeys.startedBy] = {{19935,19936}},
            [questKeys.nextQuestInChain] = 10467,
            [questKeys.preQuestSingle] = {10445},
        },
        [10461] = { -- Restorer's Pledge
            [questKeys.startedBy] = {{19935,19936}},
            [questKeys.nextQuestInChain] = 10465,
            [questKeys.preQuestSingle] = {10445},
        },
        [10462] = { -- Champion's Pledge
            [questKeys.startedBy] = {{19935,19936}},
            [questKeys.nextQuestInChain] = 10466,
            [questKeys.preQuestSingle] = {10445},
        },
        [10463] = { -- Sage's Pledge
            [questKeys.startedBy] = {{19935,19936}},
            [questKeys.nextQuestInChain] = 10464,
            [questKeys.preQuestSingle] = {10445},
        },
        [10464] = { -- Sage's Vow
            [questKeys.startedBy] = {{19935,19936}},
            [questKeys.exclusiveTo] = {10460,10461,10462},
        },
        [10465] = { -- Restorer's Vow
            [questKeys.startedBy] = {{19935,19936}},
            [questKeys.requiredMinRep] = {990,3000},
            [questKeys.exclusiveTo] = {10460,10462,10463},
        },
        [10466] = { -- Champion's Vow
            [questKeys.startedBy] = {{19935,19936}},
            [questKeys.requiredMinRep] = {990,3000},
            [questKeys.exclusiveTo] = {10460,10461,10463},
        },
        [10467] = { -- Defender's Vow
            [questKeys.startedBy] = {{19935,19936}},
            [questKeys.requiredMinRep] = {990,3000},
            [questKeys.exclusiveTo] = {10461,10462,10463},
        },
        [10468] = { -- Sage's Oath
            [questKeys.startedBy] = {{19935,19936}},
            [questKeys.exclusiveTo] = {10460,10461,10462},
        },
        [10469] = { -- Restorer's Oath
            [questKeys.startedBy] = {{19935,19936}},
            [questKeys.exclusiveTo] = {10460,10462,10463},
        },
        [10470] = { -- Champion's Oath
            [questKeys.startedBy] = {{19935,19936}},
            [questKeys.requiredMinRep] = {990,9000},
            [questKeys.exclusiveTo] = {10460,10461,10463},
        },
        [10471] = { -- Defender's Oath
            [questKeys.startedBy] = {{19935,19936}},
            [questKeys.requiredMinRep] = {990,9000},
            [questKeys.exclusiveTo] = {10461,10462,10463},
        },
        [10472] = { -- Sage's Covenant
            [questKeys.startedBy] = {{19935,19936}},
            [questKeys.nextQuestInChain] = 11103,
            [questKeys.exclusiveTo] = {10460,10461,10462},
        },
        [10473] = { -- Restorer's Covenant
            [questKeys.startedBy] = {{19935,19936}},
            [questKeys.nextQuestInChain] = 11104,
            [questKeys.exclusiveTo] = {10460,10462,10463},
        },
        [10474] = { -- Champion's Covenant
            [questKeys.startedBy] = {{19935,19936}},
            [questKeys.requiredMinRep] = {990,21000},
            [questKeys.nextQuestInChain] = 11105,
            [questKeys.exclusiveTo] = {10460,10461,10463},
        },
        [10475] = { -- Defender's Covenant
            [questKeys.startedBy] = {{19935,19936}},
            [questKeys.nextQuestInChain] = 11106,
            [questKeys.exclusiveTo] = {10461,10462,10463},
        },
        [10476] = { -- Fierce Enemies
            [questKeys.requiredMinRep] = {978,0},
            [questKeys.nextQuestInChain] = 10477,
        },
        [10479] = { -- Proving Your Strength
            [questKeys.requiredMinRep] = {941,0},
            [questKeys.nextQuestInChain] = 10478,
        },
        [10480] = { -- Enraged Spirits of Water
            [questKeys.objectives] = {{{21059}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use the Totem of Spirits on Enraged Water Spirits"), 0, {{"monster", 21059}}}},
        },
        [10481] = { -- Enraged Spirits of Air
            [questKeys.objectives] = {{{21060}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use the Totem of Spirits on Enraged Air Spirits"), 0, {{"monster", 21060}}}},
        },
        [10482] = { -- Fel Orc Scavengers
            [questKeys.breadcrumbs] = {10160},
        },
        [10483] = { -- Ill Omens
            [questKeys.nextQuestInChain] = 10484,
        },
        [10488] = { -- Protecting Our Own
            [questKeys.objectives] = {{{20748,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [10490] = { -- Call of Water
            [questKeys.exclusiveTo] = {9500,9502},
            [questKeys.breadcrumbForQuestId] = 9501,
        },
        [10491] = { -- Call of Air
            [questKeys.breadcrumbForQuestId] = 9552,
        },
        [10492] = { -- An Earnest Proposition
            [questKeys.nextQuestInChain] = 8922,
        },
        [10493] = { -- An Earnest Proposition
            [questKeys.nextQuestInChain] = 8923,
        },
        [10506] = { -- A Dire Situation
            [questKeys.objectives] = {{{20058,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [10507] = { -- Turning Point
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Take the portal to Socrethar's Seat"), 0, {{"object", 410016}}},
                                           {nil, Questie.ICON_TYPE_OBJECT, l10n("Take the portal back to Invasion Point: Overlord"), 0, {{"object", 410017}}},
                                           {{[zoneIDs.NETHERSTORM] = {{36.44,18.35}}}, Questie.ICON_TYPE_EVENT, l10n("Open a portal to Socrethar's Seat with Socrethar's Teleporting Stone")},
                                           {{[zoneIDs.NETHERSTORM] = {{30.56,17.69}}}, Questie.ICON_TYPE_EVENT, l10n("After defeating Socrethar, you can open a portal back")},
            },
        },
        [10511] = { -- Strange Brew
            [questKeys.nextQuestInChain] = 10512,
        },
        [10512] = { -- Getting the Bladespire Tanked
            [questKeys.objectives] = {nil,nil,nil,nil,{{{19998,20334,20723,20726,20730,20731,20732,21296,21975,19995},19995,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [10514] = { -- I Was A Lot Of Things...
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use Oronok's Boar Whistle to dig up a Shadowmoon Tuber"), 0, {{"object", 184701}}}},
        },
        [10518] = { -- Planting the Banner
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Place the Bladespire Banner atop the Northmaul Tower"), 0, {{"object", 184704}}}},
        },
        [10519] = { -- The Cipher of Damnation - Truth and History
            [questKeys.objectives] = {{{21183,nil,Questie.ICON_TYPE_TALK}}},
        },
        [10520] = { -- Assisting Arch Druid Staghelm
            [questKeys.requiredLevel] = 47,
            [questKeys.exclusiveTo] = {3763,3789,3790},
            [questKeys.breadcrumbForQuestId] = 3764,
        },
        [10522] = { -- The Cipher of Damnation - Grom'tor's Charge
            [questKeys.requiredSourceItems] = {30426},
        },
        [10525] = { -- Vision Guide
            [questKeys.triggerEnd] = {"Final Thunderlord artifact discovered", {[zoneIDs.BLADES_EDGE_MOUNTAINS] = {{52.76,58.89}}}},
        },
        [10526] = { -- The Thunderspike
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Attempt to loot The Thunderspike"), 0, {{"object", 184729}}}},
            [questKeys.nextQuestInChain] = 10718,
        },
        [10528] = { -- Demonic Crystal Prisons
            [questKeys.nextQuestInChain] = 10537,
        },
        [10530] = { -- The Hunter's Path
            [questKeys.breadcrumbForQuestId] = 9484,
            [questKeys.requiredLevel] = 10,
        },
        [10540] = { -- The Cipher of Damnation - Ar'tor's Charge
            [questKeys.extraObjectives] = {{{[zoneIDs.SHADOWMOON_VALLEY] = {{30,57}}}, Questie.ICON_TYPE_EVENT, l10n("Walk with your Spirit Hunter")}},
        },
        [10545] = { -- Bladespire Kegger
            [questKeys.objectives] = {nil,nil,nil,nil,{{{19998,20334,20723,20726,20730,20731,20732,21296,21975,19995},19995,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [10548] = { -- The Sad Truth
            [questKeys.preQuestSingle] = {2379,9491},
        },
        [10551] = { -- Allegiance to the Aldor
            [questKeys.nextQuestInChain] = 10554,
        },
        [10552] = { -- Allegiance to the Scryers
            [questKeys.nextQuestInChain] = 10553,
        },
        [10553] = { -- Voren'thal the Seer
            [questKeys.preQuestSingle] = {10551,10552},
            [questKeys.requiredMinRep] = {934,0},
        },
        [10554] = { -- Ishanah
            [questKeys.preQuestSingle] = {10551,10552},
            [questKeys.requiredMinRep] = {932,0},
        },
        [10556] = { -- Scratches
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use the Fistful of Feathers on the Lashh'an Spell Circle and get back to Daranelle"), 0, {{"object", 184826}, {"monster", 21469}}}},
        },
        [10557] = { -- Test Flight: The Zephyrium Capacitorium
            [questKeys.triggerEnd] = {"Test Tally's Experiment", {[zoneIDs.BLADES_EDGE_MOUNTAINS] = {{60.17,68.8}}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Speak with Rally Zapnabber and use the Zephyrium Capacitorium"), 0, {{"monster", 21461}}}},
        },
        [10562] = { -- Besieged!
            [questKeys.breadcrumbs] = {11044},
        },
        [10563] = { -- To Legion Hold
            [questKeys.objectives] = {nil,{{184833}}},
        },
        [10564] = { -- Blast the Infernals!
            [questKeys.objectives] = {{{21512,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [10565] = { -- The Stones of Vekh'nir
            [questKeys.extraObjectives] = {{{[zoneIDs.BLADES_EDGE_MOUNTAINS] = {{77.81,74.67}}}, Questie.ICON_TYPE_EVENT, l10n("Charge the Vekh'nir Crystal")}},
            [questKeys.nextQuestInChain] = 10566,
        },
        [10566] = { -- Trial and Error
            [questKeys.objectives] = {{{21254,nil,Questie.ICON_TYPE_INTERACT},{21254,nil,Questie.ICON_TYPE_INTERACT},{21254,nil,Questie.ICON_TYPE_INTERACT},{21254,nil,Questie.ICON_TYPE_INTERACT}}}, -- Yes, this is correct. The quest requires you to use four wands on the same NPC.
            [questKeys.requiredSourceItems] = {30651,30652,30653,30654,30655},
        },
        [10567] = { -- Creating the Pendant
            [questKeys.disabledByQuest] = 10615,
            [questKeys.extraObjectives] = {{{[zoneIDs.BLADES_EDGE_MOUNTAINS] = {{64.48,33.11}}}, Questie.ICON_TYPE_EVENT, l10n("Use 6 Ruuan'ok Claws to summon a Harbinger of the Raven")}},
        },
        [10570] = { -- To Catch A Thistlehead
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Place the Bundle of Bloodthistle at the end of the bridge"), 0, {{"object", 184841}}}},
        },
        [10571] = { -- Oronu the Elder
            [questKeys.exclusiveTo] = {10684},
        },
        [10574] = { -- The Ashtongue Corruptors
            [questKeys.exclusiveTo] = {10685},
        },
        [10575] = { -- The Warden's Cage
            [questKeys.exclusiveTo] = {10686},
        },
        [10577] = { -- What Illidan Wants, Illidan Gets...
            [questKeys.objectives] = {{{20563,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use the Blood Elf Disguise before talking to him"), 0, {{"monster", 20563}}}},
        },
        [10580] = { -- Where Did Those Darn Gnomes Go?
            [questKeys.exclusiveTo] = {10584},
        },
        [10583] = { -- The Fate of Flanis
            [questKeys.objectives] = {nil,nil,{{30658,nil,Questie.ICON_TYPE_TALK}}},
        },
        [10584] = { -- Picking Up Some Power Converters
            [questKeys.objectives] = {{{21729,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.preQuestSingle] = {},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Open the Power Converters and encase what is inside with the Protovoltaic Magneto Collector"), 0, {{"object", 184906}}}},
        },
        [10585] = { -- The Summoning Chamber
            [questKeys.extraObjectives] = {{{[zoneIDs.SHADOWMOON_VALLEY] = {{37,38}}}, Questie.ICON_TYPE_EVENT, l10n("Use the Elemental Displacer to disrupt the ritual in the summoning chamber"), 0}},
        },
        [10588] = { -- The Cipher of Damnation
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use The Cipher of Damnation at Altar of Damnation"), 0, {{"object", 184907}}},
                                           {nil, Questie.ICON_TYPE_TALK, l10n("Let him know when you are ready for Cyrukh"), 0, {{"monster", 21685}}},
            },
        },
        [10590] = { -- Prove Your Hatred
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {9601},
        },
        [10594] = { -- Gauging the Resonant Frequency
            [questKeys.triggerEnd] = {"Singing crystal resonant frequency gauged", {[zoneIDs.BLADES_EDGE_MOUNTAINS] = {{59.77,73.83}}}},
        },
        [10595] = { -- Besieged!
            [questKeys.breadcrumbs] = {11048},
        },
        [10596] = { -- To Legion Hold
            [questKeys.objectives] = {nil,{{184833}}},
        },
        [10598] = { -- Blast the Infernals!
            [questKeys.objectives] = {{{21512,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [10601] = { -- The Fate of Kagrosh
            [questKeys.objectives] = {nil,nil,{{30659,nil,Questie.ICON_TYPE_TALK}}},
        },
        [10605] = { -- Carendin Summons
            [questKeys.nextQuestInChain] = 0,
        },
        [10606] = { -- The Art of Fel Reaver Maintenance
            [questKeys.objectives] = {nil,nil,{{30713},{30712}}},
            [questKeys.requiredSourceItems] = {},
        },
        [10607] = { -- Whispers of the Raven God
            [questKeys.objectives] = {nil,{{184950},{184967},{184968},{184969}}},
        },
        [10609] = { -- What Came First, the Drake or the Egg?
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Open Nether Drake Eggs and use the Temporal Phase Modulator on whatever hatches"), 0, {{"object", 184867}}},
                                           {nil, Questie.ICON_TYPE_SLAY, l10n("Use the Temporal Phase Modulator"), 0, {{"monster", 20021}}},
            },
        },
        [10611] = { -- The Art of Fel Reaver Maintenance
            [questKeys.objectives] = {nil,nil,{{30713},{30712}}},
            [questKeys.requiredSourceItems] = {},
        },
        [10612] = { -- The Fel and the Furious
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use a Fel Reaver Control Console to take control of a Fel Reaver Sentinel"), 0, {{"object", 185057}}}},
            [questKeys.objectives] = {nil,{{184979}}},
        },
        [10613] = { -- The Fel and the Furious
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use a Fel Reaver Control Console to take control of a Fel Reaver Sentinel"), 0, {{"object", 185059}}}},
            [questKeys.objectives] = {nil,{{184979}}},
        },
        [10620] = { -- Ridgespine Menace
            [questKeys.nextQuestInChain] = 10671,
        },
        [10624] = { -- A Haunted History
            [questKeys.breadcrumbs] = {11046},
        },
        [10627] = { -- Capture the Weapons
            [questKeys.nextQuestInChain] = 10663,
        },
        [10629] = { -- Shizz Work
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_SLAY, l10n("Kill some Deranged Helboars"), 0, {{"monster", 16863}}},
                                           {nil, Questie.ICON_TYPE_EVENT, l10n("Use the Felhound Whistle"), 0, {{"monster", 16915}}},
            },
        },
        [10634] = { -- Divination: Gorefiend's Armor
            [questKeys.preQuestSingle] = {10633,10644},
        },
        [10635] = { -- Divination: Gorefiend's Cloak
            [questKeys.preQuestSingle] = {10633,10644},
        },
        [10636] = { -- Divination: Gorefiend's Truncheon
            [questKeys.preQuestSingle] = {10633,10644},
        },
        [10637] = { -- A Necessary Distraction
            [questKeys.objectives] = {{{21506,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [10639] = { -- Teron Gorefiend, I am...
            [questKeys.preQuestGroup] = {10634,10635,10636},
        },
        [10641] = { -- Against the Legion
            [questKeys.preQuestSingle] = {10640,10689},
        },
        [10642] = { -- A Ghost in the Machine
            [questKeys.breadcrumbs] = {11045},
        },
        [10645] = { -- Teron Gorefiend, I am...
            [questKeys.preQuestGroup] = {10634,10635,10636},
        },
        [10646] = { -- Illidan's Pupil
            [questKeys.objectives] = {{{18417,nil,Questie.ICON_TYPE_TALK}}},
        },
        [10649] = { -- The Book of Fel Names
            [questKeys.zoneOrSort] = zoneIDs.AUCHINDOUN_DUNGEONS,
            [questKeys.nextQuestInChain] = 10650,
        },
        [10652] = { -- Behind Enemy Lines
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_TALK,l10n("Take a ride"),0,{{"monster",20162}}}},
        },
        [10653] = { -- Marks of Sargeras
            [questKeys.requiredMaxRep] = {},
            [questKeys.preQuestSingle] = {10551,10552},
            [questKeys.exclusiveTo] = {10826},
        },
        [10654] = { -- More Marks of Sargeras
            [questKeys.requiredMaxRep] = {},
            [questKeys.preQuestGroup] = {10551,10653},
            [questKeys.preQuestSingle] = {},
        },
        [10655] = { -- Single Mark of Sargeras
            [questKeys.requiredMaxRep] = {},
            [questKeys.preQuestGroup] = {10551,10653},
            [questKeys.preQuestSingle] = {},
        },
        [10656] = { -- Sunfury Signets
            [questKeys.requiredMaxRep] = {},
            [questKeys.preQuestSingle] = {10551,10552},
            [questKeys.exclusiveTo] = {10824},
        },
        [10657] = { -- Ride the Lightning
            [questKeys.objectives] = {{{20749,nil,Questie.ICON_TYPE_INTERACT}},nil,{{30849}}},
        },
        [10658] = { -- More Sunfury Signets
            [questKeys.requiredMaxRep] = {},
            [questKeys.preQuestGroup] = {10656,10552},
            [questKeys.preQuestSingle] = {},
        },
        [10659] = { -- Single Sunfury Signet
            [questKeys.requiredMaxRep] = {},
            [questKeys.preQuestGroup] = {10656,10552},
            [questKeys.preQuestSingle] = {},
        },
        [10668] = { -- Against the Illidari
            [questKeys.preQuestSingle] = {10640,10689},
        },
        [10669] = { -- Against All Odds
            [questKeys.preQuestSingle] = {10640,10689},
            [questKeys.extraObjectives] = {{{[zoneIDs.ZANGARMARSH] = {{15.9,40.5}}}, Questie.ICON_TYPE_EVENT, l10n("Use the Imbued Silver Spear at Portal Clearing near Marshlight Lake to awake Xeleth")}},
        },
        [10672] = { -- Frankly, It Makes No Sense...
            [questKeys.objectives] = {{{21462,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use a Arcano Control Unit and then swim in the lava to tag the Greater Felfire Diemetradon"), 0, {{"object", 185008},{"object", 185009},{"object", 185010}}}},
        },
        [10674] = { -- Trapping the Light Fantastic
            [questKeys.objectives] = {{{20635,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [10675] = { -- Show Them Gnome Mercy!
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_SLAY, l10n("Kill Razaani ethereals to lure Nexus-Prince Razaan out"), 0, {{"monster", 20601}, {"monster", 20609}, {"monster", 20614}}},
                                           {nil, Questie.ICON_TYPE_SLAY, l10n("Kill Nexus-Prince Razaan to spawn the Collection of Souls"), 0, {{"monster", 21057}}},
            },
        },
        [10680] = { -- The Hand of Gul'dan
            [questKeys.breadcrumbForQuestId] = 10458,
        },
        [10681] = { -- The Hand of Gul'dan
            [questKeys.breadcrumbForQuestId] = 10458,
        },
        [10682] = { -- A Time for Negotiation...
            [questKeys.objectives] = {{{21981,nil,Questie.ICON_TYPE_TALK}}},
        },
        [10683] = { -- Tablets of Baa'ri
            [questKeys.preQuestSingle] = {10552},
        },
        [10684] = { -- Oronu the Elder
            [questKeys.exclusiveTo] = {10571},
        },
        [10685] = { -- The Ashtongue Corruptors
            [questKeys.exclusiveTo] = {10574},
        },
        [10686] = { -- The Warden's Cage
            [questKeys.exclusiveTo] = {10575},
        },
        [10687] = { -- Karabor Training Grounds
            [questKeys.preQuestSingle] = {10552},
        },
        [10688] = { -- A Necessary Distraction
            [questKeys.objectives] = {{{21506,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [10707] = { -- The Ata'mal Terrace
            [questKeys.objectivesText] = {"Go to the top of the Ata'mal Terrace in Shadowmoon Valley and obtain the Heart of Fury. Return to Akama at the Warden's Cage in Shadowmoon Valley when you've completed this task."},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Kill the 3 Shadowmoon Soulstealers to force Shadowlord Deathwail to land"), 0, {{"object", 185125}}}},
            [questKeys.nextQuestInChain] = 11052,
        },
        [10708] = { -- Akama's Promise
            [questKeys.exclusiveTo] = {11052},
            [questKeys.requiredLevel] = 68,
            [questKeys.nextQuestInChain] = 10944,
        },
        [10710] = { -- Test Flight: The Singing Ridge
            [questKeys.triggerEnd] = {"Test Tally's Experiment", {[zoneIDs.BLADES_EDGE_MOUNTAINS] = {{60.17,68.8}}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Sign Tally's Waiver, then speak with Rally Zapnabber to use the Zephyrium Capacitorium"), 0, {{"monster", 21461}}}},
            [questKeys.requiredSourceItems] = {30539},
        },
        [10711] = { -- Test Flight: Razaan's Landing
            [questKeys.triggerEnd] = {"Test Tally's Experiment", {[zoneIDs.BLADES_EDGE_MOUNTAINS] = {{60.17,68.8}}}},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {10710, 10657},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Speak with Rally Zapnabber to use the Zephyrium Capacitorium"), 0, {{"monster", 21461}}}},
        },
        [10712] = { -- Test Flight: Ruuan Weald
            [questKeys.triggerEnd] = {"Test Tally's Experiment", {[zoneIDs.BLADES_EDGE_MOUNTAINS] = {{60.17,68.8}}}},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {10711, 10675},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Speak with Rally Zapnabber to use the Zephyrium Capacitorium and spin the Nether-weather Vane while flying"), 0, {{"monster", 21461}}}},
        },
        [10714] = { -- On Spirit's Wings
            [questKeys.objectives] = {nil,nil,nil,nil,{{{22160,22384},22160,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [10715] = { -- Into the Churning Gulch
            [questKeys.nextQuestInChain] = 10749,
        },
        [10719] = { -- Did You Get The Note?
            [questKeys.preQuestSingle] = {10682},
            [questKeys.nextQuestInChain] = 10894,
        },
        [10720] = { -- The Smallest Creatures
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_INTERACT, l10n("Control the Marmot"), 0, {{"monster", 22480}}}},
            [questKeys.objectives] = {nil,{{185206},{185213},{185214}}},
        },
        [10721] = { -- A Boaring Time for Grulloc
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Blow the whistle and have Grulloc run after the boar"), 0, {{"monster", 20216}}}},
        },
        [10722] = { -- Meeting at the Blackwing Coven
            [questKeys.objectives] = {{{22019,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.requiredSourceItems] = {31121,31122},
        },
        [10723] = { -- Gorgrom the Dragon-Eater
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use Sablemane's Trap at Gorgrom's Altar"), 0, {{"object", 185234}}}},
            [questKeys.objectives] = {{{21514,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [10724] = { -- Prisoner of the Bladespire
            [questKeys.objectives] = {{{22268,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [10725] = { -- Eminence Among the Violet Eye
            [questKeys.exclusiveTo] = {10726,10727,10728},
            [questKeys.nextQuestInChain] = 11031,
            [questKeys.zoneOrSort] = zoneIDs.KARAZHAN,
        },
        [10726] = { -- Eminence Among the Violet Eye
            [questKeys.exclusiveTo] = {10725,10727,10728},
            [questKeys.nextQuestInChain] = 11034,
            [questKeys.zoneOrSort] = zoneIDs.KARAZHAN,
        },
        [10727] = { -- Eminence Among the Violet Eye
            [questKeys.exclusiveTo] = {10725,10726,10728},
            [questKeys.nextQuestInChain] = 11033,
            [questKeys.zoneOrSort] = zoneIDs.KARAZHAN,
        },
        [10728] = { -- Eminence Among the Violet Eye
            [questKeys.exclusiveTo] = {10725,10726,10727},
            [questKeys.nextQuestInChain] = 11032,
            [questKeys.zoneOrSort] = zoneIDs.KARAZHAN,
        },
        [10729] = { -- Path of the Violet Mage
            [questKeys.zoneOrSort] = zoneIDs.KARAZHAN,
        },
        [10730] = { -- Path of the Violet Restorer
            [questKeys.zoneOrSort] = zoneIDs.KARAZHAN,
        },
        [10731] = { -- Path of the Violet Assassin
            [questKeys.zoneOrSort] = zoneIDs.KARAZHAN,
        },
        [10732] = { -- Path of the Violet Protector
            [questKeys.zoneOrSort] = zoneIDs.KARAZHAN,
        },
        [10733] = { -- Down the Violet Path
            [questKeys.exclusiveTo] = {10734,10735,10736},
            [questKeys.zoneOrSort] = zoneIDs.KARAZHAN,
        },
        [10734] = { -- Down the Violet Path
            [questKeys.exclusiveTo] = {10733,10735,10736},
            [questKeys.zoneOrSort] = zoneIDs.KARAZHAN,
        },
        [10735] = { -- Down the Violet Path
            [questKeys.exclusiveTo] = {10733,10734,10736},
            [questKeys.zoneOrSort] = zoneIDs.KARAZHAN,
        },
        [10736] = { -- Down the Violet Path
            [questKeys.exclusiveTo] = {10733,10734,10735},
            [questKeys.zoneOrSort] = zoneIDs.KARAZHAN,
        },
        [10738] = { -- Distinguished Service
            [questKeys.exclusiveTo] = {10739,10740,10741},
            [questKeys.zoneOrSort] = zoneIDs.KARAZHAN,
        },
        [10739] = { -- Distinguished Service
            [questKeys.exclusiveTo] = {10738,10740,10741},
            [questKeys.zoneOrSort] = zoneIDs.KARAZHAN,
        },
        [10740] = { -- Distinguished Service
            [questKeys.exclusiveTo] = {10738,10739,10741},
            [questKeys.zoneOrSort] = zoneIDs.KARAZHAN,
        },
        [10741] = { -- Distinguished Service
            [questKeys.exclusiveTo] = {10738,10739,10740},
            [questKeys.zoneOrSort] = zoneIDs.KARAZHAN,
        },
        [10742] = { -- Showdown
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use Rexxar's Battle Horn at the Altar of Goc"), 0, {{"object", 185309}}}},
        },
        [10747] = { -- Whelps of the Wyrmcult
            [questKeys.objectives] = {nil,nil,{{31130,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [10750] = { -- The Path of Conquest
            [questKeys.triggerEnd] = {"The Path of Conquest Discovered", {[zoneIDs.SHADOWMOON_VALLEY] = {{51.23,62.75},{52.45,59.19}}}},
        },
        [10751] = { -- Breaching the Path
            [questKeys.sourceItemId] = 31108,
        },
        [10752] = { -- Onward to Ashenvale
            [questKeys.exclusiveTo] = {},
            [questKeys.nextQuestInChain] = 0,
        },
        [10754] = { -- Entry Into the Citadel
            [questKeys.startedBy] = {{22037}},
        },
        [10755] = { -- Entry Into the Citadel
            [questKeys.startedBy] = {{22037}},
        },
        [10758] = { -- Hotter than Hell
            [questKeys.objectives] = {nil,nil,{{31252,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [10764] = { -- Hotter than Hell
            [questKeys.objectives] = {nil,nil,{{31252,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [10765] = { -- When Worlds Collide...
            [questKeys.sourceItemId] = 31108,
        },
        [10768] = { -- Tabards of the Illidari
            [questKeys.sourceItemId] = 31108,
        },
        [10772] = { -- The Path of Conquest
            [questKeys.triggerEnd] = {"The Path of Conquest Discovered", {[zoneIDs.SHADOWMOON_VALLEY] = {{51.23,62.75},{52.45,59.19}}}},
        },
        [10773] = { -- Breaching the Path
            [questKeys.sourceItemId] = 31310,
        },
        [10774] = { -- Blood Elf + Giant = ???
            [questKeys.sourceItemId] = 31310,
        },
        [10775] = { -- Tabards of the Illidari
            [questKeys.sourceItemId] = 31310,
        },
        [10781] = { -- Battle of the Crimson Watch
            [questKeys.triggerEnd] = {"Crimson Sigil Forces Annihilated", {[zoneIDs.SHADOWMOON_VALLEY] = {{51.75,72.79}}}},
        },
        [10782] = { -- Imbuing the Headpiece
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Equip the Unfinished Headpiece, travel to the Altar of Damnation, and use it while standing near Gul'dan."), 0, {{"monster", 17008}}}},
        },
        [10788] = { -- Return to Talionia
            [questKeys.startedBy] = {{5675,5875}},
            [questKeys.breadcrumbForQuestId] = 9529,
        },
        [10789] = { -- Return to Carendin Halgar
            [questKeys.startedBy] = {{5875,16647}},
            [questKeys.breadcrumbForQuestId] = 1473,
        },
        [10790] = { -- Return to Gan'rul Bloodeye
            [questKeys.startedBy] = {{5675,16647}},
            [questKeys.breadcrumbForQuestId] = 1501,
        },
        [10791] = { -- Welcoming the Wolf Spirit
            [questKeys.objectives] = {{{18384,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [10792] = { -- Zeth'Gor Must Burn!
            [questKeys.requiredSourceItems] = {31347,31346},
            [questKeys.objectives] = {{{20813,nil, Questie.ICON_TYPE_EVENT},{20815,nil, Questie.ICON_TYPE_EVENT},{20816,nil, Questie.ICON_TYPE_EVENT},{20814,nil, Questie.ICON_TYPE_EVENT}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Light the torches"), 0, {{"object", 185144}}}},
        },
        [10793] = { -- The Journal of Val'zareq: Portends of War
            [questKeys.startedBy] = {nil,nil,{31345}},
        },
        [10794] = { -- Rogues of the Shattered Hand
            [questKeys.breadcrumbForQuestId] = 2460,
        },
        [10797] = { -- Favor of the Gronn
            [questKeys.startedBy] = {{20753}},
            [questKeys.preQuestSingle] = {},
        },
        [10800] = { -- Goodnight, Gronn
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Put Grulloc to sleep using Sablemane's Sleeping Powder"), 0, {{"monster", 20216}}}},
        },
        [10802] = { -- Gorgrom the Dragon-Eater
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use Sablemane's Trap at Gorgrom's Altar"), 0, {{"object", 185234}}}},
            [questKeys.objectives] = {{{21514,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [10804] = { -- Kindness
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_LOOT, l10n("Kill flayers and take their carcasses. Place a carcass in the field"), 0, {{"monster", 21477}, {"monster", 21478}}}},
            [questKeys.requiredSourceItems] = {31372,31373},
            [questKeys.objectives] = {{{21648,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [10806] = { -- Showdown
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use Sablemane's Signet at the Altar of Goc"), 0, {{"object", 185309}}}},
        },
        [10807] = { -- The Ashtongue Broken
            [questKeys.preQuestSingle] = {10552},
        },
        [10808] = { -- Thwart the Dark Conclave
            [questKeys.objectives] = {{{22137,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_SLAY, l10n("Kill the Ritualists"), 0, {{"monster", 22138}}}},
        },
        [10809] = { -- Wanted: Worg Master Kruush
            [questKeys.nextQuestInChain] = 10792,
        },
        [10813] = { -- The Eyes of Grillok
            [questKeys.objectives] = {nil,nil,nil,nil,{{{19440,22177},22177,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [10814] = { -- Neltharaku's Tale
            [questKeys.objectives] = {{{21657,nil,Questie.ICON_TYPE_TALK}}},
        },
        [10821] = { -- You're Fired!
            [questKeys.requiredSourceItems] = {31536},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Retrieve five Camp Anger Keys and activate the five Legion obelisks. The obelisks have a short duration, so make sure they are all activated at the same time."), 0, {{"object", 185193},{"object", 185195},{"object", 185196},{"object", 185197},{"object", 185198}}}},
        },
        [10822] = { -- Single Sunfury Signet
            [questKeys.requiredMaxRep] = {},
            [questKeys.preQuestSingle] = {},
            [questKeys.zoneOrSort] = zoneIDs.SHADOWMOON_VALLEY,
            [questKeys.preQuestGroup] = {10552,10824},
        },
        [10823] = { -- More Sunfury Signets
            [questKeys.requiredMaxRep] = {},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {10552,10824},
        },
        [10824] = { -- Sunfury Signets
            [questKeys.requiredMaxRep] = {},
            [questKeys.preQuestSingle] = {10551,10552},
            [questKeys.exclusiveTo] = {10656},
        },
        [10825] = { -- Treebole Must Know
            [questKeys.nextQuestInChain] = 10829,
        },
        [10826] = { -- Marks of Sargeras
            [questKeys.requiredMaxRep] = {},
            [questKeys.preQuestSingle] = {10551,10552},
            [questKeys.exclusiveTo] = {10653},
        },
        [10827] = { -- More Marks of Sargeras
            [questKeys.requiredMaxRep] = {},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {10551,10826},
        },
        [10828] = { -- Single Mark of Sargeras
            [questKeys.requiredMaxRep] = {},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {10551,10826},
        },
        [10830] = { -- Exorcising the Trees
            [questKeys.requiredSourceItems] = {31517,31495,31518},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_INTERACT, l10n("Use Exorcism Feathers to summon Koi-Koi Spirits"), 0, {{"monster", 21326}}}},
        },
        [10831] = { -- Becoming a Mooncloth Tailor
            [questKeys.requiredSkill] = {197,350},
        },
        [10832] = { -- Becoming a Spellfire Tailor
            [questKeys.requiredSkill] = {197,350},
        },
        [10833] = { -- Becoming a Shadoweave Tailor
            [questKeys.requiredSkill] = {197,350},
        },
        [10838] = { -- The Demoniac Scryer
            [questKeys.objectives] = {nil,nil,{{31607,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.extraObjectives] = {{{[3483] = {{44,51}}}, Questie.ICON_TYPE_EVENT, l10n("Use the Demoniac Scryer")}},
        },
        [10839] = { -- Veil Skith: Darkstone of Terokk
            [questKeys.objectives] = {nil,{{185191}}},
        },
        [10840] = { -- The Tomb of Lights
            [questKeys.preQuestSingle] = {10915,10852},
            [questKeys.nextQuestInChain] = 10030,
        },
        [10842] = { -- The Vengeful Harbinger
            [questKeys.preQuestSingle] = {10915,10852},
            [questKeys.objectives] = {{{21638}}},
        },
        [10847] = { -- The Eyes of Skettis
            [questKeys.breadcrumbs] = {10862,10863,10908},
        },
        [10852] = { -- Missing Friends
            [questKeys.objectives] = {{{22314,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_OBJECT,l10n("Open the cage"),0,{{"object",185202}}}},
            [questKeys.requiredSourceItems] = {31655},
        },
        [10854] = { -- The Force of Neltharaku
            [questKeys.objectives] = {{{21722,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_INTERACT, l10n("Use Enchanted Nethervine Crystal on Enslaved Netherwing Drake"), 0, {{"monster", 21722}}}},
        },
        [10855] = { -- Fel Reavers, No Thanks!
            [questKeys.objectives] = {{{22293,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [10857] = { -- Teleport This!
            [questKeys.objectives] = {{{22348,nil,Questie.ICON_TYPE_EVENT},{22350,nil,Questie.ICON_TYPE_EVENT},{22351,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_INTERACT, l10n("Use the Mental Interference Rod on the Mo'arg and use their Detonate Teleporter ability"), 0, {{"monster", 16943},{"monster", 20928}}}},
        },
        [10859] = { -- Gather the Orbs
            [questKeys.objectives] = {{{20635,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [10861] = { -- Veil Lithic: Preemptive Strike
            [questKeys.objectives] = {nil,{{185210}},nil,nil,{{{22337},22337}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Collect Cursed Eggs to spawn a Hatchling"), 0, {{"object", 185210}}}},
        },
        [10862] = { -- Surrender to the Horde
            [questKeys.exclusiveTo] = {10863},
            [questKeys.breadcrumbForQuestId] = 10847,
        },
        [10863] = { -- Secrets of the Arakkoa
            [questKeys.exclusiveTo] = {10862},
            [questKeys.breadcrumbForQuestId] = 10847,
        },
        [10865] = { -- There Can Be Only One Response
            [questKeys.nextQuestInChain] = 10867,
        },
        [10866] = { -- Zuluhed the Whacked
            [questKeys.objectives] = {nil,{{185156}},nil,nil,{{{11980},11980}}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE + raceIDs.ALL_ALLIANCE - raceIDs.HUMAN,
        },
        [10867] = { -- There Can Be Only One Response
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_SLAY, l10n("Kill Razaani ethereals to lure Nexus-Prince Razaan out"), 0, {{"monster", 20601}, {"monster", 20609}, {"monster", 20614}}},
                                           {nil, Questie.ICON_TYPE_SLAY, l10n("Kill Nexus-Prince Razaan to spawn the Collection of Souls"), 0, {{"monster", 21057}}},
            },
        },
        [10870] = { -- Ally of the Netherwing
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE + raceIDs.ALL_ALLIANCE - raceIDs.HUMAN,
            [questKeys.nextQuestInChain] = 11012,
        },
        [10871] = { -- Ally of the Netherwing
            [questKeys.name] = "Ally of the Netherwing",
            [questKeys.startedBy] = {{22112}},
            [questKeys.finishedBy] = {{22113}},
            [questKeys.preQuestSingle] = {10872},
            [questKeys.requiredRaces] = raceIDs.HUMAN,
            [questKeys.reputationReward] = {{factionIDs.NETHERWING,42000}},
            [questKeys.nextQuestInChain] = 11012,
        },
        [10872] = { -- Zuluhed the Whacked
            [questKeys.name] = "Zuluhed the Whacked",
            [questKeys.startedBy] = {{22112}},
            [questKeys.finishedBy] = {{22112}},
            [questKeys.preQuestSingle] = {10858},
            [questKeys.objectives] = {nil,{{185156}},nil,nil,{{{11980},11980}}},
            [questKeys.requiredRaces] = raceIDs.HUMAN,
            [questKeys.requiredSourceItems] = {31664},
        },
        [10873] = { -- Taken in the Night
            [questKeys.objectives] = {nil,nil,nil,nil,{{{22459,22355},22459,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [10876] = { -- The Foot of the Citadel
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_SLAY, l10n("Kill Force Commander Gorax and place the Challenge From the Horde upon his corpse"), 0, {{"monster", 19264}}}},
        },
        [10879] = { -- The Skettis Offensive
            [questKeys.triggerEnd] = {"Attack thwarted", {[zoneIDs.SHATTRATH_CITY] = {{51.62,20.69}}}},
        },
        [10886] = { -- Trial of the Naaru: Tenacity
            [questKeys.triggerEnd] = {"Millhouse Manastorm Rescued", {[zoneIDs.THE_ARCATRAZ] = {{-1,-1}}}},
            [questKeys.reputationReward] = {{factionIDs.THE_SHATAR,500}},
        },
        [10887] = { -- Escaping the Tomb
            [questKeys.extraObjectives] = {{{[zoneIDs.TEROKKAR_FOREST] = {{33.77,51.61}}}, Questie.ICON_TYPE_EVENT, l10n("Help Akuno find his way to the Refugee Caravan in Terokkar Forest.")}},
        },
        [10889] = { -- Return to Shattrath
            [questKeys.nextQuestInChain] = 10879,
        },
        [10891] = { -- Imperial Plate Armor
            [questKeys.requiredSpell] = -16663,
            [questKeys.exclusiveTo] = {7652},
        },
        [10892] = { -- Imperial Plate Armor
            [questKeys.requiredSpell] = -16663,
            [questKeys.exclusiveTo] = {7652},
        },
        [10896] = { -- The Infested Protectors
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_SLAY, l10n("Kill Rotting Forest-Ragers and Infested Root-Walkers to spawn Wood Mites"), 0, {{"monster", 22307}, {"monster", 22095}}}},
        },
        [10897] = { -- Master of Potions
            [questKeys.preQuestSingle] = {},
        },
        [10898] = { -- Skywing
            [questKeys.triggerEnd] = {"Escort Skywing", {[zoneIDs.TEROKKAR_FOREST] = {{55.66,69.49}}}},
        },
        [10899] = { -- Master of Transmutation
            [questKeys.preQuestSingle] = {},
        },
        [10900] = { -- The Mark of Vashj
            [questKeys.nextQuestInChain] = 10901,
            [questKeys.requiredMaxLevel] = 70,
        },
        [10902] = { -- Master of Elixirs
            [questKeys.preQuestSingle] = {},
        },
        [10905] = { -- Master of Potions
            [questKeys.exclusiveTo] = {10899,10902,10906,10907},
        },
        [10906] = { -- Master of Elixirs
            [questKeys.exclusiveTo] = {10897,10899,10905,10907},
        },
        [10907] = { -- Master of Transmutation
            [questKeys.exclusiveTo] = {10897,10902,10905,10906},
        },
        [10908] = { -- Speak with Rilak the Redeemed
            [questKeys.exclusiveTo] = {},
            [questKeys.breadcrumbForQuestId] = 10847,
        },
        [10909] = { -- Fel Spirits
            [questKeys.extraObjectives] = {{{[zoneIDs.HELLFIRE_PENINSULA] = {{45,74.4}}}, Questie.ICON_TYPE_EVENT, l10n("Place the Achorite Relic")},
                                           {nil, Questie.ICON_TYPE_OBJECT, l10n("Slay Shattered Hand Berserkers near it"), 0, {{"object", 185298}}},
            },
            [questKeys.nextQuestInChain] = 10935,
        },
        [10911] = { -- Fire At Will!
            [questKeys.objectives] = {{{22472,nil,Questie.ICON_TYPE_EVENT},{22471,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use the Naturalized Ammunition to take control of the Death's Door Fel Cannon"), 0, {{"object", 185306}}}},
        },
        [10913] = { -- An Improper Burial
            [questKeys.objectives] = {{{21859,nil,Questie.ICON_TYPE_EVENT},{21846,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [10915] = { -- The Fallen Exarch
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Open the coffin and kill its contents"), 0, {{"object", 184999}}}},
        },
        [10917] = { -- The Outcast's Plight
            [questKeys.requiredMaxRep] = {},
            [questKeys.nextQuestInChain] = 10918,
        },
        [10922] = { -- Digging Through Bones
            [questKeys.triggerEnd] = {"Protect the Explorers", {[zoneIDs.TEROKKAR_FOREST] = {{30.12,70.9}}}},
        },
        [10923] = { -- Evil Draws Near
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use Dread Relic with 20 Doom Skulls near the Writhing Mound Summoning Circle to call Teribus the Cursed"), 0, {{"object", 185311}}}},
        },
        [10929] = { -- Fumping
            [questKeys.extraObjectives] = {{{[zoneIDs.TEROKKAR_FOREST] = {{31.9,76.3}}}, Questie.ICON_TYPE_EVENT, l10n("Use the Fumper to lure Mature Bone Sifter"), 0}},
        },
        [10930] = { -- The Big Bone Worm
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_SLAY, l10n("Kill Decrepit Clefthoofs and use the Fumper on their corpses"), 0, {{"monster", 22105}}}},
        },
        [10935] = { -- The Exorcism of Colonel Jules
            [questKeys.objectives] = {{{22432,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Perform the exorcism"), 0, {{"monster", 22431}}}},
            [questKeys.nextQuestInChain] = 10936,
        },
        [10938] = { -- Darkmoon Blessings Deck
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [10939] = { -- Darkmoon Storms Deck
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [10942] = { -- Children's Week
            [questKeys.questLevel] = -1,
            [questKeys.zoneOrSort] = sortKeys.SPECIAL,
            [questKeys.finishedBy] = {{22817}},
        },
        [10943] = { -- Children's Week
            [questKeys.questLevel] = -1,
            [questKeys.zoneOrSort] = sortKeys.SPECIAL,
        },
        [10944] = { -- The Secret Compromised
            [questKeys.preQuestSingle] = {10708,11052},
        },
        [10945] = { -- Hch'uu and the Mushroom People
            [questKeys.finishedBy] = {{22823}},
            [questKeys.questLevel] = -1,
            [questKeys.triggerEnd] = {"Salandria taken to Sporeggar", {[zoneIDs.ZANGARMARSH] = {{19.22,51.23}}}},
            [questKeys.zoneOrSort] = sortKeys.SPECIAL,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.preQuestSingle] = {10942},
            [questKeys.requiredSourceItems] = {31880},
        },
        [10946] = { -- Ruse of the Ashtongue
            [questKeys.objectives] = {{{19514}}},
        },
        [10950] = { -- Auchindoun and the Ring of Observance
            [questKeys.questLevel] = -1,
            [questKeys.triggerEnd] = {"Dornaa taken to the Ring of Observance", {[zoneIDs.TEROKKAR_FOREST] = {{39.71,64.6}}}},
            [questKeys.zoneOrSort] = sortKeys.SPECIAL,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.preQuestSingle] = {10943},
            [questKeys.requiredSourceItems] = {31881},
        },
        [10951] = { -- A Trip to the Dark Portal
            [questKeys.questLevel] = -1,
            [questKeys.triggerEnd] = {"Salandria taken to the Dark Portal", {[zoneIDs.HELLFIRE_PENINSULA] = {{88.33,50.19}}}},
            [questKeys.zoneOrSort] = sortKeys.SPECIAL,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.preQuestSingle] = {10942},
            [questKeys.requiredSourceItems] = {31880},
        },
        [10952] = { -- A Trip to the Dark Portal
            [questKeys.questLevel] = -1,
            [questKeys.triggerEnd] = {"Dornaa taken to the Dark Portal", {[zoneIDs.HELLFIRE_PENINSULA] = {{88.26,50.32}}}},
            [questKeys.zoneOrSort] = sortKeys.SPECIAL,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.preQuestSingle] = {10943},
            [questKeys.requiredSourceItems] = {31881},
        },
        [10953] = { -- Visit the Throne of the Elements
            [questKeys.finishedBy] = {{18072}},
            [questKeys.questLevel] = -1,
            [questKeys.triggerEnd] = {"Salandria taken to the Throne of the Elements", {[zoneIDs.NAGRAND] = {{60.5,22.7}}}},
            [questKeys.zoneOrSort] = sortKeys.SPECIAL,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.preQuestSingle] = {10942},
            [questKeys.requiredSourceItems] = {31880},
        },
        [10954] = { -- Jheel is at Aeris Landing!
            [questKeys.finishedBy] = {{22836}},
            [questKeys.questLevel] = -1,
            [questKeys.triggerEnd] = {"Dornaa taken to Aeris Landing", {[zoneIDs.NAGRAND] = {{31.47,57.45}}}},
            [questKeys.zoneOrSort] = sortKeys.SPECIAL,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.preQuestSingle] = {10943},
            [questKeys.requiredSourceItems] = {31881},
        },
        [10956] = { -- The Seat of the Naaru
            [questKeys.finishedBy] = {{17538}},
            [questKeys.questLevel] = -1,
            [questKeys.preQuestGroup] = {10950,10952,10954},
            [questKeys.triggerEnd] = {"Dornaa taken to the Seat of the Naaru", {[zoneIDs.THE_EXODAR] = {{56.65,40.73}}}},
            [questKeys.zoneOrSort] = sortKeys.SPECIAL,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.requiredSourceItems] = {31881},
            [questKeys.nextQuestInChain] = 10968,
        },
        [10960] = { -- When I Grow Up...
            [questKeys.requiredLevel] = 60,
            [questKeys.questLevel] = -1,
            [questKeys.zoneOrSort] = sortKeys.SPECIAL,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.requiredSourceItems] = {31880},
        },
        [10962] = { -- Time to Visit the Caverns
            [questKeys.questLevel] = -1,
            [questKeys.preQuestGroup] = {10950,10952,10954},
            [questKeys.triggerEnd] = {"Dornaa taken to the Caverns of Time", {[zoneIDs.TANARIS] = {{60.52,57.74}}}},
            [questKeys.zoneOrSort] = sortKeys.SPECIAL,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.requiredSourceItems] = {31881},
        },
        [10963] = { -- Time to Visit the Caverns
            [questKeys.questLevel] = -1,
            [questKeys.triggerEnd] = {"Salandria taken to the Caverns of Time", {[zoneIDs.TANARIS] = {{60.53,57.72}}}},
            [questKeys.preQuestGroup] = {10945,10951,10953},
            [questKeys.zoneOrSort] = sortKeys.SPECIAL,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.requiredSourceItems] = {31880},
        },
        [10966] = { -- Back to the Orphanage
            [questKeys.questLevel] = -1,
            [questKeys.zoneOrSort] = sortKeys.SPECIAL,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.preQuestGroup] = {10962,10968},
            [questKeys.preQuestSingle] = {},
        },
        [10967] = { -- Back to the Orphanage
            [questKeys.questLevel] = -1,
            [questKeys.zoneOrSort] = sortKeys.SPECIAL,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.preQuestGroup] = {10963,11975},
        },
        [10968] = { -- Call on the Farseer
            [questKeys.startedBy] = {{17538}},
            [questKeys.finishedBy] = {{17204}},
            [questKeys.requiredLevel] = 60,
            [questKeys.questLevel] = -1,
            [questKeys.objectives] = {{{17204,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.zoneOrSort] = sortKeys.SPECIAL,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.preQuestGroup] = {},
            [questKeys.preQuestSingle] = {10956},
            [questKeys.requiredSourceItems] = {31881},
        },
        [10969] = { -- Seek Out Ameer
            [questKeys.breadcrumbForQuestId] = 10970,
        },
        [10970] = { -- A Mission of Mercy
            [questKeys.breadcrumbs] = {10969},
            [questKeys.nextQuestInChain] = 10971,
        },
        [10971] = { -- Ethereum Secrets
            [questKeys.requiredSourceItems] = {29460},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Open the prison"), 0, {{"object", 184418},{"object", 184419},{"object", 184420},{"object", 184421},{"object", 184422},{"object", 184423},{"object", 184424},{"object", 184425},{"object", 184426},{"object", 184427},{"object", 184428},{"object", 184429},{"object", 184430},{"object", 184431}}}},
            [questKeys.nextQuestInChain] = 10973,
        },
        [10974] = { -- Stasis Chambers of Bash'ir
            [questKeys.requiredMinRep] = {933,21000},
            [questKeys.nextQuestInChain] = 10976,
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Open the prison"), 0, {{"object", 185512}}}},
        },
        [10975] = { -- Purging the Chambers of Bash'ir
            [questKeys.requiredMinRep] = {933,21000},
        },
        [10976] = { -- The Mark of the Nexus-King
            [questKeys.requiredMinRep] = {933,21000},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Open the prison"), 0, {{"object", 184595},{"object", 185461},{"object", 185462},{"object", 185463},{"object", 185464},{"object", 185465},{"object", 185466},{"object", 185467}}}},
            [questKeys.nextQuestInChain] = 10977,
        },
        [10977] = { -- Stasis Chambers of the Mana-Tombs
            [questKeys.objectives] = {nil,{{185519}}},
            [questKeys.requiredMinRep] = {933,21000},
            [questKeys.nextQuestInChain] = 10982,
        },
        [10981] = { -- Nexus-Prince Shaffar's Personal Chamber
            [questKeys.requiredMaxRep] = {},
            [questKeys.exclusiveTo] = {10982},
        },
        [10983] = { -- Mog'dorg the Wizened
            [questKeys.breadcrumbs] = {10984},
        },
        [10984] = { -- Speak with the Ogre
            [questKeys.nextQuestInChain] = 10983,
            [questKeys.breadcrumbForQuestId] = 10983,
        },
        [10985] = { -- A Distraction for Akama
            [questKeys.triggerEnd] = {"Help Akama and Maiev enter the Black Temple.", {[zoneIDs.SHADOWMOON_VALLEY] = {{71.05,46.11},{66.29,44.06}}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Let Xi'ri know you're ready to battle"), 1, {{"monster", 18528}}}},
        },
        [10987] = { -- To Catch A Sparrowhawk
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_LOOT, l10n("Use the Sparrowhawk Net to capture a Wild Sparrowhawk"), 0, {{"monster", 22979}}}},
        },
        [10990] = { -- The Eagle's Essence
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_SLAY, l10n("Defeat the Guardian of the Eagle and obtain the Essence of the Eagle"), 0, {{"object", 185547}}}},
        },
        [10991] = { -- The Falcon's Essence
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_SLAY, l10n("Defeat the Guardian of the Falcon and obtain the Essence of the Falcon"), 0, {{"object", 185553}}}},
        },
        [10992] = { -- The Hawk's Essence
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_SLAY, l10n("Defeat the Guardian of the Hawk and obtain the Essence of the Hawk"), 0, {{"object", 185551}}}},
        },
        [10995] = { -- Grulloc Has Two Skulls
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_SLAY, l10n("Defeat him so he spawns Grulloc's Dragon Skull"), 0, {{"monster", 20216}}}},
        },
        [10996] = { -- Maggoc's Treasure Chest
            [questKeys.preQuestSingle] = {10983,10989,11057},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_SLAY, l10n("Defeat him so he spawns Maggoc's Treasure Chest"), 0, {{"monster", 20600}}}},
        },
        [10997] = { -- Even Gronn Have Standards
            [questKeys.preQuestSingle] = {10983,10989,11057},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_SLAY, l10n("Defeat him so he spawns Slaag's Standard"), 0, {{"monster", 22199}}}},
        },
        [10998] = { -- Grim(oire) Business
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Step into fire rings to summon Vim'gol"), 0, {{"monster", 22911}}},
                                           {nil, Questie.ICON_TYPE_SLAY, l10n("Defeat him so he spawns Vim'gol's Vile Grimoire"), 0, {{"monster", 22911}}},
            },
        },
        [11000] = { -- Into the Soulgrinder
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use Vim'gol's Grimoire at Soulgrinder's Altar"), 0, {{"object", 185880}}},
                                           {nil, Questie.ICON_TYPE_SLAY, l10n("Defeat him so he spawns Skulloc's Soul"), 0, {{"monster", 22910}}},
            },
        },
        [11004] = { -- World of Shadows
            [questKeys.nextQuestInChain] = 11006,
        },
        [11005] = { -- Secrets of the Talonpriests
            [questKeys.requiredLevel] = 70,
        },
        [11008] = { -- Fires Over Skettis
            [questKeys.objectives] = {nil,{{185549}}},
            [questKeys.requiredLevel] = 70,
        },
        [11009] = { -- Ogre Heaven
            [questKeys.breadcrumbs] = {11022},
        },
        [11010] = { -- Bombing Run
            [questKeys.requiredLevel] = 70,
            [questKeys.requiredClasses] = classIDs.ALL_CLASSES - classIDs.DRUID,
            [questKeys.objectives] = {nil,{{185861}}},
        },
        [11011] = { -- Eternal Vigilance
            [questKeys.requiredLevel] = 70,
        },
        [11012] = { -- Blood Oath of the Netherwing
            [questKeys.preQuestSingle] = {10870,10871},
        },
        [11013] = { -- In Service of the Illidari
            [questKeys.requiredRaces] = raceIDs.NONE,
        },
        [11014] = { -- Enter the Taskmaster
            [questKeys.requiredRaces] = raceIDs.NONE,
        },
        [11015] = { -- Netherwing Crystals
            [questKeys.requiredRaces] = raceIDs.NONE,
        },
        [11016] = { -- Nethermine Flayer Hide
            [questKeys.requiredRaces] = raceIDs.NONE,
        },
        [11017] = { -- Netherdust Pollen
            [questKeys.requiredRaces] = raceIDs.NONE,
        },
        [11018] = { -- Nethercite Ore
            [questKeys.requiredRaces] = raceIDs.NONE,
        },
        [11019] = { -- Your Friend On The Inside
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.preQuestSingle] = {11013},
        },
        [11020] = { -- A Slow Death
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.requiredSourceItems] = {},
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_SLAY, l10n("Kill any wildlife in Shadowmoon Valley to collect Fel Gland"), 0, {{"monster", 21408},{"monster", 21901},{"monster", 21462},{"monster", 21878},{"monster", 21879}}},
                {nil, Questie.ICON_TYPE_EVENT, l10n("Use Yarzill's Mutton together with the Fel Gland to poison Dragonmaw Peons"), 0, {{"monster", 22252}}},
            },
        },
        [11021] = { -- Ishaal's Almanac
            [questKeys.preQuestSingle] = {11004},
            [questKeys.startedBy] = {nil,nil,{32523}},
        },
        [11022] = { -- Speak with Mog'dorg
            [questKeys.breadcrumbForQuestId] = 11009,
        },
        [11023] = { -- Bomb Them Again!
            [questKeys.requiredLevel] = 70,
            [questKeys.preQuestSingle] = {11010,11102},
            [questKeys.objectives] = {nil,{{185861}}},
        },
        [11025] = { -- The Crystals
            [questKeys.preQuestSingle] = {11009},
        },
        [11026] = { -- Banish the Demons
            [questKeys.preQuestSingle] = {11025},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_SLAY, l10n("Use the Banishing Crystal and slay demons near the summoned portal"), 0, {{"monster", 20557},{"monster", 22195},{"monster", 22291},{"monster", 19973},{"monster", 22204},{"monster", 22304},{"monster", 23174}}}},
            [questKeys.objectives] = {nil,nil,nil,nil,{{{20557,22195,22291,19973,22204,22304,23174},20557}}},
            [questKeys.nextQuestInChain] = 11051,
            [questKeys.requiredLevel] = 70,
        },
        [11027] = { -- Yous Have Da Darkrune?
            [questKeys.requiredLevel] = 70,
        },
        [11028] = { -- Countdown to Doom
            [questKeys.nextQuestInChain] = 11056,
        },
        [11029] = { -- A Shabby Disguise
            [questKeys.requiredLevel] = 70,
        },
        [11030] = { -- Our Boy Wants To Be A Skyguard Ranger
            [questKeys.requiredLevel] = 70,
        },
        [11031] = { -- Archmage No More
            [questKeys.preQuestSingle] = {10725},
            [questKeys.exclusiveTo] = {10726,10727,10728},
            [questKeys.zoneOrSort] = zoneIDs.KARAZHAN,
        },
        [11032] = { -- Protector No More
            [questKeys.preQuestSingle] = {10728},
            [questKeys.exclusiveTo] = {10725,10726,10727},
            [questKeys.zoneOrSort] = zoneIDs.KARAZHAN,
        },
        [11033] = { -- Assassin No More
            [questKeys.preQuestSingle] = {10727},
            [questKeys.exclusiveTo] = {10725,10726,10728},
            [questKeys.zoneOrSort] = zoneIDs.KARAZHAN,
        },
        [11034] = { -- Restorer No More
            [questKeys.preQuestSingle] = {10726},
            [questKeys.exclusiveTo] = {10725,10727,10728},
            [questKeys.zoneOrSort] = zoneIDs.KARAZHAN,
        },
        [11035] = { -- The Not-So-Friendly Skies...
            [questKeys.requiredRaces] = raceIDs.NONE,
        },
        [11036] = { -- Out of This World Produce!
            [questKeys.breadcrumbForQuestId] = 10186,
            [questKeys.exclusiveTo] = {10183,11037,11038,11039,11040,11042},
        },
        [11037] = { -- A Strange Vision
            [questKeys.breadcrumbForQuestId] = 10186,
            [questKeys.exclusiveTo] = {10183,11036,11038,11039,11040,11042},
            [questKeys.requiredMinRep] = {941,0},
        },
        [11038] = { -- Assist Exarch Orelis
            [questKeys.startedBy] = {{23270,23271}},
            [questKeys.exclusiveTo] = {10183,11036,11037,11039,11040,11042},
            [questKeys.preQuestSingle] = {10551,10552},
            [questKeys.breadcrumbForQuestId] = 10241,
        },
        [11039] = { -- Report to Spymaster Thalodien
            [questKeys.startedBy] = {{23272,23273}},
            [questKeys.preQuestSingle] = {10551,10552},
            [questKeys.exclusiveTo] = {10183,11036,11037,11038,11040,11042},
            [questKeys.requiredMinRep] = {934,3000},
            [questKeys.breadcrumbForQuestId] = 10189,
        },
        [11040] = { -- Parts for the Rocket-Chief
            [questKeys.requiredLevel] = 67,
            [questKeys.exclusiveTo] = {10183,11036,11037,11038,11039,11042},
            [questKeys.breadcrumbForQuestId] = 10186,
        },
        [11041] = { -- A Job Unfinished...
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.startedBy] = {nil,nil,{32621}},
        },
        [11042] = { -- A Mystifying Vision
            [questKeys.requiredLevel] = 67,
            [questKeys.exclusiveTo] = {10183,11036,11037,11038,11039,11040},
            [questKeys.requiredMinRep] = {978,0},
            [questKeys.breadcrumbForQuestId] = 10186,
        },
        [11043] = { -- Building a Better Gryphon
            [questKeys.requiredLevel] = 67,
            [questKeys.exclusiveTo] = {11044,11045},
        },
        [11044] = { -- Visions of Destruction
            [questKeys.requiredLevel] = 67,
            [questKeys.exclusiveTo] = {11043,11045},
            [questKeys.requiredMinRep] = {978,0},
            [questKeys.breadcrumbForQuestId] = 10562,
        },
        [11045] = { -- Zorus the Judicator
            [questKeys.exclusiveTo] = {11043,11044},
            [questKeys.breadcrumbForQuestId] = 10642,
        },
        [11046] = { -- Chief Apothecary Hildagard
            [questKeys.exclusiveTo] = {11047,11048},
            [questKeys.breadcrumbForQuestId] = 10624,
        },
        [11047] = { -- The Apprentice's Request
            [questKeys.exclusiveTo] = {11046,11048},
        },
        [11048] = { -- Kroghan's Report
            [questKeys.exclusiveTo] = {11046,11047},
            [questKeys.breadcrumbForQuestId] = 10595,
        },
        [11049] = { -- The Great Netherwing Egg Hunt
            [questKeys.requiredRaces] = raceIDs.NONE,
        },
        [11050] = { -- Accepting All Eggs
            [questKeys.requiredRaces] = raceIDs.NONE,
        },
        [11051] = { -- Banish More Demons
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_SLAY, l10n("Use the Banishing Crystal and slay demons near the summoned portal"), 0, {{"monster", 20557},{"monster", 22195},{"monster", 22291},{"monster", 19973},{"monster", 22204},{"monster", 22304},{"monster", 23174}}}},
            [questKeys.objectives] = {nil,nil,nil,nil,{{{20557,22195,22291,19973,22204,22304,23174},20557}}},
            [questKeys.requiredLevel] = 70,
        },
        [11052] = { -- Akama's Promise
            [questKeys.name] = "Akama's Promise",
            [questKeys.startedBy] = {{21700}},
            [questKeys.finishedBy] = {{18481}},
            [questKeys.requiredLevel] = 68,
            [questKeys.preQuestSingle] = {10707},
            [questKeys.exclusiveTo] = {10708},
            [questKeys.nextQuestInChain] = 10944,
        },
        [11056] = { -- Hazzik's Bargain
            [questKeys.requiredLevel] = 70,
        },
        [11057] = { -- The Trouble Below
            [questKeys.requiredLevel] = 70,
        },
        [11058] = { -- An Apexis Relic
            [questKeys.objectives] = {nil,{{185890}}},
        },
        [11059] = { -- Guardian of the Monument
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use 35 Apexis Shards to activate Apexis Monument. Apexis Guardian will spawn after six rounds"), 0, {{"object", 185944}}}},
            [questKeys.requiredLevel] = 70,
        },
        [11060] = { -- A Crystalforged Darkrune
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredLevel] = 70,
        },
        [11061] = { -- A Father's Duty
            [questKeys.requiredLevel] = 70,
        },
        [11062] = { -- The Skyguard Outpost
            [questKeys.requiredLevel] = 70,
        },
        [11063] = { -- Earning Your Wings...
            [questKeys.requiredRaces] = raceIDs.NONE,
        },
        [11064] = { -- Dragonmaw Race: The Ballad of Oldie McOld
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.objectives] = {{{23340,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [11065] = { -- Wrangle Some Aether Rays!
            [questKeys.requiredLevel] = 70,
            [questKeys.preQuestSingle] = {11010, 11102},
            [questKeys.objectives] = {{{22181,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [11066] = { -- Wrangle More Aether Rays!
            [questKeys.requiredLevel] = 70,
            [questKeys.objectives] = {{{22181,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [11067] = { -- Dragonmaw Race: Trope the Filth-Belcher
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.objectives] = {{{23342,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [11068] = { -- Dragonmaw Race: Corlok the Vet
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.objectives] = {{{23344,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [11069] = { -- Dragonmaw Race: Wing Commander Ichman
            [questKeys.startedBy] = {{23345}},
            [questKeys.objectives] = {{{23345,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [11070] = { -- Dragonmaw Race: Wing Commander Mulverick
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.objectives] = {{{23346,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [11071] = { -- Dragonmaw Race: Captain Skyshatter
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.objectives] = {{{23348,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [11072] = { -- Adversarial Blood
            [questKeys.name] = "Adversarial Blood",
            [questKeys.requiredLevel] = 70,
        },
        [11073] = { -- Terokk's Downfall
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use a Time-Lost offering to summon Terokk"), 0, {{"object", 185928}}}},
        },
        [11077] = { -- Dragons are the Least of Our Problems
            [questKeys.requiredRaces] = raceIDs.NONE,
        },
        [11078] = { -- To Rule The Skies
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use 35 Apexis Shards to open Furywing's Egg"), 0, {{"object", 185937}}},
                                           {nil, Questie.ICON_TYPE_EVENT, l10n("Use 35 Apexis Shards to open Insidion's Egg"), 0, {{"object", 185938}}},
                                           {nil, Questie.ICON_TYPE_EVENT, l10n("Use 35 Apexis Shards to open Rivendark's Egg"), 0, {{"object", 185936}}},
                                           {nil, Questie.ICON_TYPE_EVENT, l10n("Use 35 Apexis Shards to open Obsidia's Egg"), 0, {{"object", 185932}}},
            },
            [questKeys.requiredLevel] = 70,
        },
        [11079] = { -- A Fel Whip For Gahk
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use 35 Apexis Shards to activate Fel Crystal Prism"), 0, {{"object", 185927}}}},
            [questKeys.requiredLevel] = 70,
        },
        [11080] = { -- The Relic's Emanation
            [questKeys.objectives] = {nil,{{185890}}},
        },
        [11081] = { -- The Great Murkblood Revolt
            [questKeys.requiredRaces] = raceIDs.NONE,
        },
        [11082] = { -- Seeker of Truth
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.triggerEnd] = {"Murkblood Information Gathered", {[zoneIDs.SHADOWMOON_VALLEY] = {{73.06,82.26},{68.63,79.81}}}},
        },
        [11083] = { -- Crazed and Confused
            [questKeys.requiredRaces] = raceIDs.NONE,
        },
        [11085] = { -- Escape from Skettis
            [questKeys.preQuestSingle] = {},
            [questKeys.triggerEnd] = {"Rescue the Skyguard Prisoner.", {[zoneIDs.TEROKKAR_FOREST] = {{69.77,75.98},{62.41,73.85},{73.94,88.3}}}},
            [questKeys.requiredLevel] = 70,
        },
        [11086] = { -- Disrupting the Twilight Portal
            [questKeys.requiredRaces] = raceIDs.NONE,
        },
        [11089] = { -- The Soul Cannon of Reth'hedron
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Speak with Sar'this for his help hunting a Flawless Arcane Elemental"), 4, {{"monster", 23093}}}},
        },
        [11090] = { -- Subdue the Subduer
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.objectives] = {{{22357,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [11093] = { -- Hungry Nether Rays
            [questKeys.objectives] = {{{23219}}},
            [questKeys.preQuestSingle] = {},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_SLAY, l10n("Use the Nether Ray Cage and slay Blackwind Warp Chasers near the Hungry Nether Ray"), 0, {{"monster", 23219}}}},
            [questKeys.requiredLevel] = 70,
        },
        [11094] = { -- Kill Them All!
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {10211,11092},
            [questKeys.requiredMaxRep] = {932,0},
        },
        [11095] = { -- Commander Hobb
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {10211,11094},
            [questKeys.requiredMaxRep] = {932,0},
        },
        [11097] = { -- The Deadliest Trap Ever Laid
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {10211,11095},
            [questKeys.requiredMaxRep] = {932,0},
            [questKeys.triggerEnd] = {"Dragonmaw Forces Defeated", {[zoneIDs.SHADOWMOON_VALLEY] = {{56.87,58.18},{64.27,31.01}}}},
        },
        [11098] = { -- To Skettis!
            [questKeys.nextQuestInChain] = 11008,
        },
        [11099] = { -- Kill Them All!
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {10211,11092},
            [questKeys.requiredMaxRep] = {934,0},
        },
        [11100] = { -- Commander Arcus
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {10211,11099},
            [questKeys.requiredMaxRep] = {934,0},
        },
        [11101] = { -- The Deadliest Trap Ever Laid
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {10211,11100},
            [questKeys.requiredMaxRep] = {934,0},
            [questKeys.triggerEnd] = {"Dragonmaw Forces Defeated", {[zoneIDs.SHADOWMOON_VALLEY] = {{56.87,58.18},{64.27,31.01}}}},
        },
        [11102] = { -- Bombing Run
            [questKeys.requiredLevel] = 70,
            [questKeys.objectives] = {nil,{{185861}}},
        },
        [11103] = { -- Sage No More
            [questKeys.startedBy] = {{19935,19936}},
            [questKeys.finishedBy] = {{19935,19936}},
            [questKeys.preQuestSingle] = {10472},
            [questKeys.exclusiveTo] = {10460,10461,10462},
        },
        [11104] = { -- Restorer No More
            [questKeys.startedBy] = {{19935,19936}},
            [questKeys.finishedBy] = {{19935,19936}},
            [questKeys.preQuestSingle] = {10473},
            [questKeys.exclusiveTo] = {10460,10462,10463},
        },
        [11105] = { -- Champion No More
            [questKeys.startedBy] = {{19935,19936}},
            [questKeys.finishedBy] = {{19935,19936}},
            [questKeys.preQuestSingle] = {10474},
            [questKeys.exclusiveTo] = {10460,10461,10463},
        },
        [11106] = { -- Defender No More
            [questKeys.startedBy] = {{19935,19936}},
            [questKeys.finishedBy] = {{19935,19936}},
            [questKeys.preQuestSingle] = {10475},
            [questKeys.exclusiveTo] = {10461,10462,10463},
        },
        [11108] = { -- Lord Illidan Stormrage
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.triggerEnd] = {"Meeting with Illidan Stormrage", {[zoneIDs.SHADOWMOON_VALLEY] = {{65.93,86.15}}}},
        },
        [11119] = { -- Assault on Bash'ir Landing!
            [questKeys.preQuestSingle] = {11102,11010},
            [questKeys.requiredLevel] = 70,
        },
        [11123] = { -- Inspecting the Ruins
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {1282},
        },
        [11126] = { -- Traitors Among Us
            [questKeys.objectives] = {{{23602,nil,Questie.ICON_TYPE_TALK}}},
        },
        [11128] = { -- Propaganda War
            [questKeys.nextQuestInChain] = 11133,
        },
        [11129] = { -- Kyle's Gone Missing!
            [questKeys.objectives] = {{{23616,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [11131] = { -- Stop the Fires!
            [questKeys.triggerEnd] = {"Put Out the Fires", {[zoneIDs.DUN_MOROGH] = {{44.8,52.1},{47.5,51.6}},[zoneIDs.ELWYNN_FOREST] = {{41.3,65.2},{43.6,65.8}},[zoneIDs.AZUREMYST_ISLE] = {{49.8,52.3},{48.8,50}}}},
            [questKeys.requiredSourceItems] = {32971},
            [questKeys.exclusiveTo] = {12133},
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [11133] = { -- Discrediting the Deserters
            [questKeys.objectives] = {{{4979,nil,Questie.ICON_TYPE_TALK}}},
        },
        [11134] = { -- The End of the Deserters
            [questKeys.nextQuestInChain] = 11136,
        },
        [11135] = { -- The Headless Horseman
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE, -- most likely breadcrumb
        },
        [11136] = { -- A Disturbing Development
            [questKeys.breadcrumbForQuestId] = 11137,
            [questKeys.preQuestSingle] = {11134,11198}, -- double check 11198
        },
        [11137] = { -- Defias in Dustwallow?
            [questKeys.breadcrumbs] = {11136},
        },
        [11140] = { -- Recover the Cargo!
            [questKeys.requiredSourceItems] = {33040},
            [questKeys.nextQuestInChain] = 11141,
        },
        [11142] = { -- Survey Alcaz Island
            [questKeys.objectives] = {{{23704,nil,Questie.ICON_TYPE_TALK}}},
        },
        [11143] = { -- A Grim Connection
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {1284,1287,1320},
        },
        [11145] = { -- Prisoners of the Grimtotems
            [questKeys.requiredSourceItems] = {33061},
            [questKeys.objectives] = {{{23720,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_OBJECT,l10n("Open the cage"),0,{{"object",410020}}}},
        },
        [11146] = { -- Raptor Captor
            [questKeys.objectives] = {nil,nil,nil,nil,{{{4351,4352},4351,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [11147] = { -- Unleash the Raptors
            [questKeys.objectives] = {{{23727,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [11149] = { -- Tabetha's Assistance
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {11144,11148},
        },
        [11150] = { -- Raze Direhorn Post!
            [questKeys.objectives] = {{{23751,nil,Questie.ICON_TYPE_EVENT},{23752,nil,Questie.ICON_TYPE_EVENT},{23753,nil,Questie.ICON_TYPE_EVENT}}}
        },
        [11152] = { -- Peace at Last
            [questKeys.objectives] = {nil,{{186322,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [11159] = { -- Spirits of Stonemaul Hold
            [questKeys.preQuestSingle] = {11161},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Redeem Remains"), 0, {{"object", 186332}}}},
        },
        [11161] = { -- The Essence of Enmity
            [questKeys.nextQuestInChain] = 11159,
        },
        [11162] = { -- Challenge to the Black Flight
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Plant the Stonemaul Banner"), 0, {{"object", 186336}}}},
        },
        [11164] = { -- Tuskin' Raiders
            [questKeys.preQuestSingle] = {11132},
        },
        [11169] = { -- The Grimtotem Weapon
            [questKeys.objectives] = {nil,nil,nil,nil,{{{4344,4345},4344}}},
        },
        [11172] = { -- The Zeppelin Crash
            [questKeys.nextQuestInChain] = 11174,
            [questKeys.breadcrumbForQuestId] = 11174,
        },
        [11174] = { -- Corrosion Prevention
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {11172},
            [questKeys.objectives] = {nil,nil,nil,nil,{{{4392,4393,4394},4392,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [11177] = { -- The Hermit of Swamplight Manor
            [questKeys.nextQuestInChain] = 1218,
            [questKeys.breadcrumbForQuestId] = 1218,
            [questKeys.preQuestSingle] = {11134,11198}, -- double check 11198
        },
        [11180] = { -- What's Haunting Witch Hill?
            [questKeys.objectives] = {nil,nil,nil,nil,{{{23554,23555,23861},23861}}},
        },
        [11183] = { -- Cleansing Witch Hill
            [questKeys.extraObjectives] = {{{[zoneIDs.DUSTWALLOW_MARSH] = {{55.2,26.6}}}, Questie.ICON_TYPE_EVENT, l10n("Plant the torch at the end of the dock")}},
        },
        [11185] = { -- The Apothecary's Letter
            [questKeys.startedBy] = {{23881}},
        },
        [11186] = { -- Signs of Treachery?
            [questKeys.startedBy] = {{23881}},
        },
        [11198] = { -- Take Down Tethyr!
            [questKeys.objectives] = {{{23899}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Use the cannon"), 0, {{"object",186432}}}},
        },
        [11203] = { -- Seek Out Tabetha
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {11200,11201},
        },
        [11209] = { -- Nat's Bargain
            [questKeys.extraObjectives] = {{{[zoneIDs.DUSTWALLOW_MARSH] = {{56.38,62.42}}}, Questie.ICON_TYPE_EVENT, l10n("Smear the Fish Paste on yourself and swim to the ship wreck")}},
        },
        [11211] = { -- Help for Mudsprocket
            [questKeys.exclusiveTo] = {11158,11214,11215},
        },
        [11213] = { -- Check Up on Tabetha
            [questKeys.requiredLevel] = 37,
        },
        [11214] = { -- Mission to Mudsprocket
            [questKeys.exclusiveTo] = {11158,11211,11215},
        },
        [11215] = { -- Help Mudsprocket
            [questKeys.exclusiveTo] = {11158,11211,11214},
        },
        [11216] = { -- Archmage Alturus
            [questKeys.nextQuestInChain] = 9825,
            [questKeys.breadcrumbForQuestId] = 9825,
            [questKeys.zoneOrSort] = zoneIDs.KARAZHAN,
            [questKeys.reputationReward] = {{factionIDs.THE_VIOLET_EYE,5}},
        },
        [11219] = { -- Stop the Fires!
            [questKeys.triggerEnd] = {"Put Out the Fires", {[zoneIDs.DUROTAR] = {{52.12,43.59},{53.21,42.56},{51.58,42.08}},[zoneIDs.TIRISFAL_GLADES] = {{60.32,53.29},{61.11,51.25},{61.64,51.97}},[zoneIDs.EVERSONG_WOODS] = {{47.76,47.3},{48.21,46.16}}}},
            [questKeys.requiredSourceItems] = {32971},
            [questKeys.exclusiveTo] = {12155},
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [11220] = { -- The Headless Horseman
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE, -- most likely breadcrumb
        },
        [11222] = { -- Warn Bolvar!
            [questKeys.nextQuestInChain] = 11223,
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Talk to Jaina"), 0, {{"monster",4968}}}},
        },
        [11225] = { -- The Hermit of Witch Hill
            [questKeys.requiredLevel] = 32,
        },
        [11242] = { -- Free at Last!
            [questKeys.startedBy] = {{23904}},
            [questKeys.finishedBy] = {{24519}},
            [questKeys.requiredLevel] = 65,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.preQuestSingle] = {11135},
        },
        [11318] = { -- Now This is Ram Racing... Almost.
            [questKeys.requiredLevel] = 1,
        },
        [11335] = { -- Call to Arms: Arathi Basin
            [questKeys.objectives] = {nil,nil,nil,nil,{{{857,907,15008,19855,20120,20273},857,nil,Questie.ICON_TYPE_TALK}}},
        },
        [11336] = { -- Call to Arms: Alterac Valley
            [questKeys.objectives] = {nil,nil,nil,nil,{{{5118,7410,12197,19907,20119,20271},5118,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [11337] = { -- Call to Arms: Eye of the Storm
            [questKeys.objectives] = {nil,nil,nil,nil,{{{20362,20374,20381,20382,20383},20362,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [11338] = { -- Call to Arms: Warsong Gulch
            [questKeys.objectives] = {nil,nil,nil,nil,{{{2302,14981,14982,19908,20118,20272},2302,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [11339] = { -- Call to Arms: Arathi Basin
            [questKeys.objectives] = {nil,nil,nil,nil,{{{12198,15006,15007,16694,19905,20274},12198,nil,Questie.ICON_TYPE_TALK}}},
        },
        [11340] = { -- Call to Arms: Alterac Valley
            [questKeys.objectives] = {nil,nil,nil,nil,{{{347,7427,14942,16695,19906,20276},347,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [11341] = { -- Call to Arms: Eye of the Storm
            [questKeys.objectives] = {nil,nil,nil,nil,{{{20384,20385,20386,20388,20390},20384,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [11342] = { -- Call to Arms: Warsong Gulch
            [questKeys.objectives] = {nil,nil,nil,nil,{{{2804,3890,10360,16696,19910,20269},2804,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [11356] = { -- Costumed Orphan Matron
            [questKeys.exclusiveTo] = {11360,11439,11440},
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [11357] = { -- Masked Orphan Matron
            [questKeys.exclusiveTo] = {11361,11449,11450},
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [11360] = { -- Fire Brigade Practice
            [questKeys.exclusiveTo] = {11439,11440},
            [questKeys.requiredSourceItems] = {32971},
            [questKeys.objectives] = {{{23537,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [11361] = { -- Fire Training
            [questKeys.questLevel] = -1,
            [questKeys.exclusiveTo] = {11449,11450},
            [questKeys.requiredSourceItems] = {32971},
            [questKeys.objectives] = {{{23537,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [11379] = { -- Super Hot Stew
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Cook Demon Broiled Surprise in the remains of a Abyssal Flamebringer in Blade's Edge Mountains"), 0, {{"monster", 19973}}}},
        },
        [11381] = { -- Soup for the Soul
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Cook Spiritual Soup at the Ancestral Grounds in Nagrand"), 0, {{"object", 184317}}}},
        },
        [11383] = { -- Wanted: Rift Lords
            [questKeys.objectives] = {nil,nil,nil,nil,{{{17839,21140},17839}}},
        },
        [11392] = { -- Call the Headless Horseman
            [questKeys.startedBy] = {nil,{186267}}, -- alliance/horde? what about 11404/11405, probably phase specific?
            [questKeys.finishedBy] = {nil,{186314}},
            [questKeys.questLevel] = -1,
        },
        [11401] = { -- Call the Headless Horseman
            [questKeys.startedBy] = {nil,{186267}}, -- alliance/horde? should this one be not repeatable? what about 11404/11405, probably phase specific?
            [questKeys.finishedBy] = {nil,{186314}},
            [questKeys.preQuestSingle] = {11135,11220},
        },
        [11403] = { -- Free at Last!
            [questKeys.startedBy] = {{23904}},
            [questKeys.finishedBy] = {{23973}},
            [questKeys.requiredLevel] = 65,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.preQuestSingle] = {11220},
        },
        [11439] = { -- Fire Brigade Practice
            [questKeys.startedBy] = {},
            [questKeys.exclusiveTo] = {11360,11440},
            [questKeys.requiredSourceItems] = {32971},
            [questKeys.objectives] = {{{23537,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [11440] = { -- Fire Brigade Practice
            [questKeys.startedBy] = {},
            [questKeys.exclusiveTo] = {11360,11439},
            [questKeys.requiredSourceItems] = {32971},
            [questKeys.objectives] = {{{23537,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [11441] = { -- Brewfest!
            [questKeys.startedBy] = {{18927,19148,19171,19172,19173,20102}},
            [questKeys.exclusiveTo] = {11442},
        },
        [11442] = { -- Welcome to Brewfest!
            [questKeys.exclusiveTo] = {11441},
            [questKeys.objectivesText] = {},
            [questKeys.startedBy] = {{24710}},
            [questKeys.finishedBy] = {{24710}},
        },
        [11446] = { -- Brewfest!
            [questKeys.startedBy] = {{19169,19175,19176,19177,19178,20102}},
            [questKeys.exclusiveTo] = {11447},
        },
        [11447] = { -- Welcome to Brewfest!
            [questKeys.exclusiveTo] = {11446},
            [questKeys.objectivesText] = {},
            [questKeys.startedBy] = {{24711}},
            [questKeys.finishedBy] = {{24711}},
        },
        [11449] = { -- Fire Training
            [questKeys.startedBy] = {},
            [questKeys.exclusiveTo] = {11361,11450},
            [questKeys.requiredSourceItems] = {32971},
            [questKeys.objectives] = {{{23537,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [11450] = { -- Fire Training
            [questKeys.startedBy] = {},
            [questKeys.exclusiveTo] = {11361,11449},
            [questKeys.requiredSourceItems] = {32971},
            [questKeys.objectives] = {{{23537,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [11481] = { -- Crisis at the Sunwell
            [questKeys.requiredMinRep] = {932,0},
            [questKeys.exclusiveTo] = {11482},
        },
        [11482] = { -- Duty Calls
            [questKeys.requiredMinRep] = {934,0},
            [questKeys.exclusiveTo] = {11481},
        },
        [11490] = { -- The Scryer's Scryer
            [questKeys.objectives] = {nil,{{187578}}},
        },
        [11496] = { -- The Sanctum Wards
            [questKeys.objectives] = {nil,{{187078}}},
        },
        [11497] = { -- Learning to Fly
            [questKeys.requiredRanks] = {{profKeys.RIDING,-rankKeys.EXPERT},{profKeys.RIDING,-rankKeys.ARTISAN},{profKeys.RIDING,-rankKeys.MASTER}}, -- TODO not sure about artisan or master
        },
        [11498] = { -- Learning to Fly
            [questKeys.requiredRanks] = {{profKeys.RIDING,-rankKeys.EXPERT},{profKeys.RIDING,-rankKeys.ARTISAN},{profKeys.RIDING,-rankKeys.MASTER}}, -- TODO not sure about artisan or master
        },
        [11502] = { -- In Defense of Halaa
            [questKeys.requiredMinRep] = {978,0},
            [questKeys.extraObjectives] = {{{[zoneIDs.NAGRAND] = {{42.3,45.5}}}, Questie.ICON_TYPE_EVENT, l10n("Defeat enemy players")}},
        },
        [11503] = { -- Enemies, Old and New
            [questKeys.requiredMinRep] = {941,0},
            [questKeys.extraObjectives] = {{{[zoneIDs.NAGRAND] = {{42.3,45.5}}}, Questie.ICON_TYPE_EVENT, l10n("Defeat enemy players")}},
        },
        [11505] = { -- Spirits of Auchindoun
            [questKeys.triggerEnd] = {"Secure a Spirit Tower", {[zoneIDs.TEROKKAR_FOREST] = {{42.49,54},{32.47,57.86},{48.98,60.29},{47.2,72.29},{40.48,77.99}}}},
        },
        [11506] = { -- Spirits of Auchindoun
            [questKeys.triggerEnd] = {"Secure a Spirit Tower", {[zoneIDs.TEROKKAR_FOREST] = {{42.49,54},{32.47,57.86},{48.98,60.29},{47.2,72.29},{40.48,77.99}}}},
        },
        [11513] = { -- Intercepting the Mana Cells
            [questKeys.preQuestSingle] = {},
        },
        [11514] = { -- Maintaining the Sunwell Portal
            [questKeys.preQuestSingle] = {},
        },
        [11515] = { -- Blood for Blood
            [questKeys.objectives] = {{{24918}}},
            [questKeys.requiredSourceItems] = {34259},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_SLAY, l10n("Use Fel Siphon and then kill the weakened Felblood Initiate"), 0, {{"monster", 24918}}}},
        },
        [11516] = { -- Blast the Gateway
            [questKeys.triggerEnd] = {"Legion Gateway Destroyed", {[zoneIDs.HELLFIRE_PENINSULA] = {{58.51,18.5}}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_SLAY, l10n("Kill Incandescent Fel Sparks after summoning your Living Flare"), 0, {{"monster", 22323}}}},
        },
        [11517] = { -- Report to Nasuun
            [questKeys.exclusiveTo] = {11513,11514},
        },
        [11520] = { -- Discovering Your Roots
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_EVENT, l10n("Use Razorthorn Flayer Gland on Razorthorn Ravager to tame it"), 0, {{"monster", 24922}}},
                {nil, Questie.ICON_TYPE_OBJECT, l10n("Use Expose Razorthorn Root of your tamed Razorthorn Ravager to expose Razorthorn Root"), 0, {{"object", 187073}}},
            },
        },
        [11521] = { -- Rediscovering Your Roots
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_EVENT, l10n("Use Razorthorn Flayer Gland on Razorthorn Ravager to tame it"), 0, {{"monster", 24922}}},
                {nil, Questie.ICON_TYPE_OBJECT, l10n("Use Expose Razorthorn Root of your tamed Razorthorn Ravager to expose Razorthorn Root"), 0, {{"object", 187073}}},
            },
        },
        [11523] = { -- Arm the Wards!
            [questKeys.objectives] = {nil,{{187078}}},
        },
        [11524] = { -- Erratic Behavior
            [questKeys.objectives] = {{{24972,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [11525] = { -- Further Conversions
            [questKeys.objectives] = {{{24972,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [11526] = { -- The Missing Magistrix
            [questKeys.preQuestSingle] = {},
        },
        [11531] = { -- Strange Engine Part
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [11532] = { -- Distraction at the Dead Scar
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Speak to Ayren Cloudbreaker"), 0, {{"monster", 25059}}}},
        },
        [11533] = { -- The Air Strikes Must Continue
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Speak to Ayren Cloudbreaker"), 0, {{"monster", 25059}}}},
        },
        [11534] = { -- Report to Nasuun
            [questKeys.exclusiveTo] = {11513,11514},
        },
        [11537] = { -- The Battle Must Go On
            [questKeys.objectives] = {{{25003,nil,Questie.ICON_TYPE_INTERACT}},nil,nil,nil,{{{24999,25001,25002,25008,25068},25068}}},
        },
        [11538] = { -- The Battle for the Sun's Reach Armory
            [questKeys.objectives] = {{{25003,nil,Questie.ICON_TYPE_INTERACT}},nil,nil,nil,{{{24999,25001,25002,25008,25068},25068}}},
        },
        [11541] = { -- Disrupt the Greengill Coast
            [questKeys.objectives] = {{{25084,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.requiredSourceItems] = {34483},
        },
        [11542] = { -- Intercept the Reinforcements
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Speak to Ayren Cloudbreaker"), 0, {{"monster", 25059}}},
                                           {nil, Questie.ICON_TYPE_TALK, l10n("Take a ride back to the isle"), 0, {{"monster", 25236}}},
            },
        },
        [11543] = { -- Keeping the Enemy at Bay
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Speak to Ayren Cloudbreaker"), 0, {{"monster", 25059}}},
                                           {nil, Questie.ICON_TYPE_TALK, l10n("Take a ride back to the isle"), 0, {{"monster", 25236}}},
            },
        },
        [11544] = { -- Ata'mal Armaments
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Break down Ata'mal Metal on the anvil to cleanse it"), 0, {{"object", 187111}}}},
        },
        [11545] = { -- A Charitable Donation
            [questKeys.requiredMaxRep] = {1077,42000},
        },
        [11549] = { -- A Magnanimous Benefactor
            [questKeys.objectivesText] = {"Anchorite Kairthos wants you to donate 1000 gold to aid in Anchorite Ayuri's efforts. You will be known as <Name> of the Shattered Sun if you complete this quest."},
        },
        [11558] = { -- Dangerous Love
            [questKeys.requiredSourceItems] = {21815,21829,22163},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [11580] = { -- Desecrate this Fire!
            [questKeys.startedBy] = {nil,{187559}},
            [questKeys.finishedBy] = {nil,{187559}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11581] = { -- Desecrate this Fire!
            [questKeys.startedBy] = {nil,{187564}},
            [questKeys.finishedBy] = {nil,{187564}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11583] = { -- Honor the Flame
            [questKeys.startedBy] = {{25910}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11584] = { -- Honor the Flame
            [questKeys.startedBy] = {{25939}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11657] = { -- Torch Catching
            [questKeys.startedBy] = {{25975}},
            [questKeys.finishedBy] = {{25975}},
            [questKeys.preQuestSingle] = {11731},
            [questKeys.triggerEnd] = {"Catch 4 torches in a row.", {
                [zoneIDs.ORGRIMMAR] = {{47.02,36.83}},
                [zoneIDs.THUNDER_BLUFF] = {{21.95,26.74}},
                [zoneIDs.STORMWIND_CITY] = {{37.65,59.98}},
                [zoneIDs.IRONFORGE] = {{62.15,27.58}},
                [zoneIDs.UNDERCITY] = {{64.58,8.08}},
            }},
            [questKeys.requiredLevel] = 1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [11665] = { -- Crocolisks in the City
            [questKeys.extraObjectives] = {
                {{[zoneIDs.ORGRIMMAR] = {{70.4,28.3},{67.8,33.7},{64.8,26},{35.2,78.6},{37.6,81.7},{33.3,84.4},{36.3,86}}}, Questie.ICON_TYPE_NODE_FISH, l10n("Fish for Baby Crocolisk")},
                {{[zoneIDs.STORMWIND_CITY] = {{48.5,67.9},{45.7,60.5},{45.4,53.3},{35.7,45.6},{34.3,59},{51.8,47.1},{60.2,46.6},{65.2,53.7},{61.1,37},{65.6,32},{55.9,33.5},{50.9,23.8}}}, Questie.ICON_TYPE_NODE_FISH, l10n("Fish for Baby Crocolisk")},
            },
        },
        [11666] = { -- Bait Bandits
            [questKeys.extraObjectives] = {{{[zoneIDs.TEROKKAR_FOREST] = {{51.9,34.7},{55.3,44.1},{60.2,53.9}}}, Questie.ICON_TYPE_NODE_FISH, l10n("Fish here for Blackfin Darter")}},
        },
        [11667] = { -- The One That Got Away
            [questKeys.extraObjectives] = {{{[zoneIDs.NAGRAND] = {{62,35}}}, Questie.ICON_TYPE_NODE_FISH, l10n("Fish here for World's Largest Mudfish")}},
        },
        [11668] = { -- Shrimpin' Ain't Easy
            [questKeys.extraObjectives] = {{{[zoneIDs.ZANGARMARSH] = {{75.6,82.9}}}, Questie.ICON_TYPE_NODE_FISH, l10n("Fish here for Bloated Barbed Gill Trout")}},
        },
        [11669] = { -- Felblood Fillet
            [questKeys.extraObjectives] = {{{[zoneIDs.HELLFIRE_PENINSULA] = {{39.4,43}},[zoneIDs.SHADOWMOON_VALLEY] = {{24,32.5},{31.9,29.9},{40.1,60.1}}}, Questie.ICON_TYPE_NODE_FISH, l10n("Fish here for Monstrous Felblood Snapper")}},
        },
        [11691] = { -- Summon Ahune
            [questKeys.requiredLevel] = 65,
            [questKeys.preQuestSingle] = {},
            [questKeys.breadcrumbs] = {11696},
        },
        [11696] = { -- Ahune is Here!
            [questKeys.requiredLevel] = 65,
            [questKeys.breadcrumbForQuestId] = 11691,
        },
        [11731] = { -- Torch Tossing
            [questKeys.startedBy] = {{25975}},
            [questKeys.finishedBy] = {{25975}},
            [questKeys.triggerEnd] = {"Hit 8 braziers.", {
                [zoneIDs.TELDRASSIL] = {{56.59,92.06}},
                [zoneIDs.ORGRIMMAR] = {{46.65,38.17}},
                [zoneIDs.STORMWIND_CITY] = {{39.21,61.71}},
                [zoneIDs.IRONFORGE] = {{65,23.73}},
                [zoneIDs.UNDERCITY] = {{68.58,7.88}},
            }},
            [questKeys.requiredLevel] = 1,
        },
        [11732] = { -- Desecrate this Fire!
            [questKeys.startedBy] = {nil,{187914}},
            [questKeys.finishedBy] = {nil,{187914}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11734] = { -- Desecrate this Fire!
            [questKeys.startedBy] = {nil,{187916}},
            [questKeys.finishedBy] = {nil,{187916}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11735] = { -- Desecrate this Fire!
            [questKeys.startedBy] = {nil,{187917}},
            [questKeys.finishedBy] = {nil,{187917}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11736] = { -- Desecrate this Fire!
            [questKeys.startedBy] = {nil,{187919}},
            [questKeys.finishedBy] = {nil,{187919}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11737] = { -- Desecrate this Fire!
            [questKeys.startedBy] = {nil,{187920}},
            [questKeys.finishedBy] = {nil,{187920}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11738] = { -- Desecrate this Fire!
            [questKeys.startedBy] = {nil,{187921}},
            [questKeys.finishedBy] = {nil,{187921}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11739] = { -- Desecrate this Fire!
            [questKeys.startedBy] = {nil,{187922}},
            [questKeys.finishedBy] = {nil,{187922}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11740] = { -- Desecrate this Fire!
            [questKeys.startedBy] = {nil,{187923}},
            [questKeys.finishedBy] = {nil,{187923}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11741] = { -- Desecrate this Fire!
            [questKeys.startedBy] = {nil,{187924}},
            [questKeys.finishedBy] = {nil,{187924}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11742] = { -- Desecrate this Fire!
            [questKeys.startedBy] = {nil,{187925}},
            [questKeys.finishedBy] = {nil,{187925}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11743] = { -- Desecrate this Fire!
            [questKeys.startedBy] = {nil,{187926}},
            [questKeys.finishedBy] = {nil,{187926}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11744] = { -- Desecrate this Fire!
            [questKeys.startedBy] = {nil,{187927}},
            [questKeys.finishedBy] = {nil,{187927}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11745] = { -- Desecrate this Fire!
            [questKeys.startedBy] = {nil,{187928}},
            [questKeys.finishedBy] = {nil,{187928}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11746] = { -- Desecrate this Fire!
            [questKeys.startedBy] = {nil,{187929}},
            [questKeys.finishedBy] = {nil,{187929}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11747] = { -- Desecrate this Fire!
            [questKeys.startedBy] = {nil,{187930}},
            [questKeys.finishedBy] = {nil,{187930}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11748] = { -- Desecrate this Fire!
            [questKeys.startedBy] = {nil,{187931}},
            [questKeys.finishedBy] = {nil,{187931}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11749] = { -- Desecrate this Fire!
            [questKeys.startedBy] = {nil,{187932}},
            [questKeys.finishedBy] = {nil,{187932}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11750] = { -- Desecrate this Fire!
            [questKeys.startedBy] = {nil,{187933}},
            [questKeys.finishedBy] = {nil,{187933}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11751] = { -- Desecrate this Fire!
            [questKeys.startedBy] = {nil,{187934}},
            [questKeys.finishedBy] = {nil,{187934}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11752] = { -- Desecrate this Fire!
            [questKeys.startedBy] = {nil,{187935}},
            [questKeys.finishedBy] = {nil,{187935}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11753] = { -- Desecrate this Fire!
            [questKeys.startedBy] = {nil,{187936}},
            [questKeys.finishedBy] = {nil,{187936}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11754] = { -- Desecrate this Fire!
            [questKeys.startedBy] = {nil,{187937}},
            [questKeys.finishedBy] = {nil,{187937}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11755] = { -- Desecrate this Fire!
            [questKeys.startedBy] = {nil,{187938}},
            [questKeys.finishedBy] = {nil,{187938}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11756] = { -- Desecrate this Fire!
            [questKeys.startedBy] = {nil,{187939}},
            [questKeys.finishedBy] = {nil,{187939}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11757] = { -- Desecrate this Fire!
            [questKeys.startedBy] = {nil,{187940}},
            [questKeys.finishedBy] = {nil,{187940}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11758] = { -- Desecrate this Fire!
            [questKeys.startedBy] = {nil,{187941}},
            [questKeys.finishedBy] = {nil,{187941}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11759] = { -- Desecrate this Fire!
            [questKeys.startedBy] = {nil,{187942}},
            [questKeys.finishedBy] = {nil,{187942}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11760] = { -- Desecrate this Fire!
            [questKeys.startedBy] = {nil,{187943}},
            [questKeys.finishedBy] = {nil,{187943}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11761] = { -- Desecrate this Fire!
            [questKeys.startedBy] = {nil,{187944}},
            [questKeys.finishedBy] = {nil,{187944}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11762] = { -- Desecrate this Fire!
            [questKeys.startedBy] = {nil,{187945}},
            [questKeys.finishedBy] = {nil,{187945}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11763] = { -- Desecrate this Fire!
            [questKeys.startedBy] = {nil,{187946}},
            [questKeys.finishedBy] = {nil,{187946}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11764] = { -- Desecrate this Fire!
            [questKeys.startedBy] = {nil,{187947}},
            [questKeys.finishedBy] = {nil,{187947}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11765] = { -- Desecrate this Fire!
            [questKeys.startedBy] = {nil,{187948}},
            [questKeys.finishedBy] = {nil,{187948}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11766] = { -- Desecrate this Fire!
            [questKeys.startedBy] = {nil,{187954}},
            [questKeys.finishedBy] = {nil,{187954}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11767] = { -- Desecrate this Fire!
            [questKeys.startedBy] = {nil,{187955}},
            [questKeys.finishedBy] = {nil,{187955}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11768] = { -- Desecrate this Fire!
            [questKeys.startedBy] = {nil,{187956}},
            [questKeys.finishedBy] = {nil,{187956}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11769] = { -- Desecrate this Fire!
            [questKeys.startedBy] = {nil,{187957}},
            [questKeys.finishedBy] = {nil,{187957}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11770] = { -- Desecrate this Fire!
            [questKeys.startedBy] = {nil,{187958}},
            [questKeys.finishedBy] = {nil,{187958}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11771] = { -- Desecrate this Fire!
            [questKeys.startedBy] = {nil,{187959}},
            [questKeys.finishedBy] = {nil,{187959}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11772] = { -- Desecrate this Fire!
            [questKeys.startedBy] = {nil,{187960}},
            [questKeys.finishedBy] = {nil,{187960}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11773] = { -- Desecrate this Fire!
            [questKeys.startedBy] = {nil,{187961}},
            [questKeys.finishedBy] = {nil,{187961}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11774] = { -- Desecrate this Fire!
            [questKeys.startedBy] = {nil,{187962}},
            [questKeys.finishedBy] = {nil,{187962}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11775] = { -- Desecrate this Fire!
            [questKeys.startedBy] = {nil,{187963}},
            [questKeys.finishedBy] = {nil,{187963}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11776] = { -- Desecrate this Fire!
            [questKeys.startedBy] = {nil,{187964}},
            [questKeys.finishedBy] = {nil,{187964}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11777] = { -- Desecrate this Fire!
            [questKeys.startedBy] = {nil,{187965}},
            [questKeys.finishedBy] = {nil,{187965}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11778] = { -- Desecrate this Fire!
            [questKeys.startedBy] = {nil,{187966}},
            [questKeys.finishedBy] = {nil,{187966}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11779] = { -- Desecrate this Fire!
            [questKeys.startedBy] = {nil,{187967}},
            [questKeys.finishedBy] = {nil,{187967}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11780] = { -- Desecrate this Fire!
            [questKeys.startedBy] = {nil,{187968}},
            [questKeys.finishedBy] = {nil,{187968}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11781] = { -- Desecrate this Fire!
            [questKeys.startedBy] = {nil,{187969}},
            [questKeys.finishedBy] = {nil,{187969}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11782] = { -- Desecrate this Fire!
            [questKeys.startedBy] = {nil,{187970}},
            [questKeys.finishedBy] = {nil,{187970}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11783] = { -- Desecrate this Fire!
            [questKeys.startedBy] = {nil,{187971}},
            [questKeys.finishedBy] = {nil,{187971}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11784] = { -- Desecrate this Fire!
            [questKeys.startedBy] = {nil,{187972}},
            [questKeys.finishedBy] = {nil,{187972}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11785] = { -- Desecrate this Fire!
            [questKeys.startedBy] = {nil,{187973}},
            [questKeys.finishedBy] = {nil,{187973}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11786] = { -- Desecrate this Fire!
            [questKeys.startedBy] = {nil,{187974}},
            [questKeys.finishedBy] = {nil,{187974}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11787] = { -- Desecrate this Fire!
            [questKeys.startedBy] = {nil,{187975}},
            [questKeys.finishedBy] = {nil,{187975}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11799] = { -- Desecrate this Fire!
            [questKeys.startedBy] = {nil,{187949}},
            [questKeys.finishedBy] = {nil,{187949}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11800] = { -- Desecrate this Fire!
            [questKeys.startedBy] = {nil,{187950}},
            [questKeys.finishedBy] = {nil,{187950}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11801] = { -- Desecrate this Fire!
            [questKeys.startedBy] = {nil,{187951}},
            [questKeys.finishedBy] = {nil,{187951}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11802] = { -- Desecrate this Fire!
            [questKeys.startedBy] = {nil,{187952}},
            [questKeys.finishedBy] = {nil,{187952}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11803] = { -- Desecrate this Fire!
            [questKeys.startedBy] = {nil,{187953}},
            [questKeys.finishedBy] = {nil,{187953}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11804] = { -- Honor the Flame
            [questKeys.startedBy] = {{25887}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11805] = { -- Honor the Flame
            [questKeys.startedBy] = {{25883}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11806] = { -- Honor the Flame
            [questKeys.startedBy] = {{25888}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11807] = { -- Honor the Flame
            [questKeys.startedBy] = {{25889}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11808] = { -- Honor the Flame
            [questKeys.startedBy] = {{25890}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11809] = { -- Honor the Flame
            [questKeys.startedBy] = {{25891}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11810] = { -- Honor the Flame
            [questKeys.startedBy] = {{25892}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11811] = { -- Honor the Flame
            [questKeys.startedBy] = {{25893}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11812] = { -- Honor the Flame
            [questKeys.startedBy] = {{25894}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11813] = { -- Honor the Flame
            [questKeys.startedBy] = {{25895}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11814] = { -- Honor the Flame
            [questKeys.startedBy] = {{25896}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11815] = { -- Honor the Flame
            [questKeys.startedBy] = {{25897}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11816] = { -- Honor the Flame
            [questKeys.startedBy] = {{25898}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11817] = { -- Honor the Flame
            [questKeys.startedBy] = {{25899}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11818] = { -- Honor the Flame
            [questKeys.startedBy] = {{25900}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11819] = { -- Honor the Flame
            [questKeys.startedBy] = {{25901}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11820] = { -- Honor the Flame
            [questKeys.startedBy] = {{25902}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11821] = { -- Honor the Flame
            [questKeys.startedBy] = {{25903}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11822] = { -- Honor the Flame
            [questKeys.startedBy] = {{25904}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11823] = { -- Honor the Flame
            [questKeys.startedBy] = {{25905}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11824] = { -- Honor the Flame
            [questKeys.startedBy] = {{25906}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11825] = { -- Honor the Flame
            [questKeys.startedBy] = {{25907}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11826] = { -- Honor the Flame
            [questKeys.startedBy] = {{25908}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11827] = { -- Honor the Flame
            [questKeys.startedBy] = {{25909}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11828] = { -- Honor the Flame
            [questKeys.startedBy] = {{25911}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11829] = { -- Honor the Flame
            [questKeys.startedBy] = {{25912}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11830] = { -- Honor the Flame
            [questKeys.startedBy] = {{25913}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11831] = { -- Honor the Flame
            [questKeys.startedBy] = {{25914}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11832] = { -- Honor the Flame
            [questKeys.startedBy] = {{25915}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11833] = { -- Honor the Flame
            [questKeys.startedBy] = {{25916}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11834] = { -- Honor the Flame
            [questKeys.startedBy] = {{25917}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11835] = { -- Honor the Flame
            [questKeys.startedBy] = {{25918}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11836] = { -- Honor the Flame
            [questKeys.startedBy] = {{25919}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11837] = { -- Honor the Flame
            [questKeys.startedBy] = {{25920}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11838] = { -- Honor the Flame
            [questKeys.startedBy] = {{25921}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11839] = { -- Honor the Flame
            [questKeys.startedBy] = {{25922}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11840] = { -- Honor the Flame
            [questKeys.startedBy] = {{25923}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11841] = { -- Honor the Flame
            [questKeys.startedBy] = {{25884}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11842] = { -- Honor the Flame
            [questKeys.startedBy] = {{25925}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11843] = { -- Honor the Flame
            [questKeys.startedBy] = {{25926}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11844] = { -- Honor the Flame
            [questKeys.startedBy] = {{25927}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11845] = { -- Honor the Flame
            [questKeys.startedBy] = {{25928}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11846] = { -- Honor the Flame
            [questKeys.startedBy] = {{25929}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11847] = { -- Honor the Flame
            [questKeys.startedBy] = {{25930}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11848] = { -- Honor the Flame
            [questKeys.startedBy] = {{25931}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11849] = { -- Honor the Flame
            [questKeys.startedBy] = {{25932}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11850] = { -- Honor the Flame
            [questKeys.startedBy] = {{25933}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11851] = { -- Honor the Flame
            [questKeys.startedBy] = {{25934}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11852] = { -- Honor the Flame
            [questKeys.startedBy] = {{25936}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11853] = { -- Honor the Flame
            [questKeys.startedBy] = {{25935}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11854] = { -- Honor the Flame
            [questKeys.startedBy] = {{25937}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11855] = { -- Honor the Flame
            [questKeys.startedBy] = {{25938}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11856] = { -- Honor the Flame
            [questKeys.startedBy] = {{25940}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11857] = { -- Honor the Flame
            [questKeys.startedBy] = {{25941}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11858] = { -- Honor the Flame
            [questKeys.startedBy] = {{25942}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11859] = { -- Honor the Flame
            [questKeys.startedBy] = {{25943}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11860] = { -- Honor the Flame
            [questKeys.startedBy] = {{25944}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11861] = { -- Honor the Flame
            [questKeys.startedBy] = {{25945}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11862] = { -- Honor the Flame
            [questKeys.startedBy] = {{25946}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11863] = { -- Honor the Flame
            [questKeys.startedBy] = {{25947}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
            [questKeys.requiredLevel] = 1,
        },
        [11875] = { -- Gaining the Advantage
            [questKeys.preQuestSingle] = {},
            [questKeys.requiredRanks] = {{profKeys.HERBALISM,rankKeys.ARTISAN},{profKeys.SKINNING,rankKeys.ARTISAN},{profKeys.MINING,rankKeys.ARTISAN}},
        },
        [11877] = { -- Sunfury Attack Plans
            [questKeys.preQuestSingle] = {},
        },
        [11880] = { -- The Multiphase Survey
            [questKeys.preQuestSingle] = {},
        },
        [11882] = { -- Playing with Fire
            [questKeys.startedBy] = {{25962}},
            [questKeys.finishedBy] = {{25975}},
        },
        [11885] = { -- Adversarial Blood
            [questKeys.objectives] = {{{23161},{23165},{23163},{23162}}},
            [questKeys.requiredSourceItems] = {32620},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Summon and defeat each of the descendants by using 10 Time-Lost Scrolls"), 0, {{"object", 185913}}}},
            [questKeys.nextQuestInChain] = 11073,
        },
        [11886] = { -- Unusual Activity
            [questKeys.finishedBy] = {{25324}},
            [questKeys.requiredLevel] = 16,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.objectives] = {nil,nil,{{35277}}},
            [questKeys.requiredSourceItems] = {35828},
        },
        [11891] = { -- An Innocent Disguise
            [questKeys.startedBy] = {{25324}},
            [questKeys.finishedBy] = {{25324}},
            [questKeys.requiredLevel] = 16,
            [questKeys.sourceItemId] = 35237,
            [questKeys.preQuestSingle] = {11886},
            [questKeys.triggerEnd] = {"Listen to the plan of the Twilight Cultists", {[zoneIDs.ASHENVALE] = {{9.15,12.41}}}},
        },
        [11915] = { -- Playing with Fire
            [questKeys.startedBy] = {{25994}},
        },
        [11917] = { -- Striking Back
            [questKeys.startedBy] = {{26221}},
            [questKeys.finishedBy] = {{26221}},
            [questKeys.preQuestSingle] = {12012},
            [questKeys.specialFlags] = specialFlags.NONE,
            [questKeys.requiredLevel] = 16,
            [questKeys.requiredMaxLevel] = 28,
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_OBJECT,l10n("Summon one of Ahune's lieutenants"),0,{{"object",188049},{"object",188137},{"object",188138}}}},
        },
        [11921] = { -- More Torch Tossing
            [questKeys.startedBy] = {{25975}},
            [questKeys.finishedBy] = {{25975}},
            [questKeys.preQuestSingle] = {11657},
            [questKeys.specialFlags] = specialFlags.NONE,
            [questKeys.triggerEnd] = {"Hit 20 braziers.", {
                [zoneIDs.STORMWIND_CITY] = {{39.2,61.72}},
                [zoneIDs.IRONFORGE] = {{65,23.68}},
            }},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.requiredLevel] = 1,
        },
        [11922] = { -- Torch Tossing
            [questKeys.startedBy] = {{26113}},
            [questKeys.finishedBy] = {{26113}},
            [questKeys.triggerEnd] = {"Hit 8 braziers.", {
                [zoneIDs.TELDRASSIL] = {{56.59,92.06}},
                [zoneIDs.STORMWIND_CITY] = {{39.21,61.71}},
                [zoneIDs.IRONFORGE] = {{65,23.73}},
            }},
            [questKeys.requiredLevel] = 1,
        },
        [11923] = { -- Torch Catching
            [questKeys.startedBy] = {{26113}},
            [questKeys.finishedBy] = {{26113}},
            [questKeys.preQuestSingle] = {11922},
            [questKeys.triggerEnd] = {"Catch 4 torches in a row.", {
                [zoneIDs.ORGRIMMAR] = {{47.02,36.83}},
                [zoneIDs.THUNDER_BLUFF] = {{21.95,26.74}},
                [zoneIDs.UNDERCITY] = {{64.58,8.08}},
            }},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.requiredLevel] = 1,
        },
        [11924] = { -- More Torch Catching
            [questKeys.startedBy] = {{25975}},
            [questKeys.finishedBy] = {{25975}},
            [questKeys.specialFlags] = specialFlags.NONE,
            [questKeys.preQuestSingle] = {11657},
            [questKeys.triggerEnd] = {"Catch 10 torches in a row.", {
                [zoneIDs.THE_EXODAR] = {{41.63,22.55}},
                [zoneIDs.STORMWIND_CITY] = {{37.5,59.8}},
                [zoneIDs.IRONFORGE] = {{62.04,27.83}},
            }},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.requiredLevel] = 1,
        },
        [11925] = { -- More Torch Catching
            [questKeys.startedBy] = {{26113}},
            [questKeys.finishedBy] = {{26113}},
            [questKeys.specialFlags] = specialFlags.NONE,
            [questKeys.preQuestSingle] = {11923},
            [questKeys.triggerEnd] = {"Catch 10 torches in a row.", {
                [zoneIDs.ORGRIMMAR] = {{47.11,36.69}},
                [zoneIDs.THUNDER_BLUFF] = {{22.17,26.94}},
            }},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.requiredLevel] = 1,
        },
        [11926] = { -- More Torch Tossing
            [questKeys.startedBy] = {{26113}},
            [questKeys.finishedBy] = {{26113}},
            [questKeys.specialFlags] = specialFlags.NONE,
            [questKeys.preQuestSingle] = {11923},
            [questKeys.triggerEnd] = {"Hit 20 braziers.", {
                [zoneIDs.ORGRIMMAR] = {{46.67,38.13}},
                [zoneIDs.THUNDER_BLUFF] = {{20.99,26.46}},
                [zoneIDs.UNDERCITY] = {{68.62,8.01}},
            }},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.requiredLevel] = 1,
        },
        [11933] = { -- Stealing the Exodar's Flame
            [questKeys.startedBy] = {nil,nil,{35569}},
        },
        [11935] = { -- Stealing Silvermoon's Flame
            [questKeys.startedBy] = {nil,nil,{35568}},
        },
        [11947] = { -- Striking Back
            [questKeys.startedBy] = {{26221}},
            [questKeys.finishedBy] = {{26221}},
            [questKeys.preQuestSingle] = {12012},
            [questKeys.specialFlags] = specialFlags.NONE,
            [questKeys.requiredLevel] = 29,
            [questKeys.requiredMaxLevel] = 38,
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_OBJECT,l10n("Summon one of Ahune's lieutenants"),0,{{"object",188130},{"object",188134},{"object",188135}}}},
        },
        [11948] = { -- Striking Back
            [questKeys.startedBy] = {{26221}},
            [questKeys.finishedBy] = {{26221}},
            [questKeys.preQuestSingle] = {12012},
            [questKeys.specialFlags] = specialFlags.NONE,
            [questKeys.requiredLevel] = 39,
            [questKeys.requiredMaxLevel] = 48,
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_OBJECT,l10n("Summon one of Ahune's lieutenants"),0,{{"object",188139},{"object",188143},{"object",188144}}}},
        },
        [11952] = { -- Striking Back
            [questKeys.startedBy] = {{26221}},
            [questKeys.finishedBy] = {{26221}},
            [questKeys.preQuestSingle] = {12012},
            [questKeys.specialFlags] = specialFlags.NONE,
            [questKeys.requiredLevel] = 49,
            [questKeys.requiredMaxLevel] = 55,
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_OBJECT,l10n("Summon one of Ahune's lieutenants"),0,{{"object",188145},{"object",188146},{"object",188147}}}},
        },
        [11953] = { -- Striking Back
            [questKeys.startedBy] = {{26221}},
            [questKeys.finishedBy] = {{26221}},
            [questKeys.preQuestSingle] = {12012},
            [questKeys.specialFlags] = specialFlags.NONE,
            [questKeys.requiredLevel] = 56,
            [questKeys.requiredMaxLevel] = 63,
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_OBJECT,l10n("Summon one of Ahune's lieutenants"),0,{{"object",188148},{"object",188149},{"object",188150}}}},
        },
        [11954] = { -- Striking Back
            [questKeys.startedBy] = {{26221}},
            [questKeys.finishedBy] = {{26221}},
            [questKeys.preQuestSingle] = {12012},
            [questKeys.requiredLevel] = 64,
            [questKeys.specialFlags] = specialFlags.NONE,
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_OBJECT,l10n("Summon one of Ahune's templars"),0,{{"object",188151},{"object",188152},{"object",188153},{"object",188154}}}},
        },
        [11955] = { -- Ahune, the Frost Lord
            [questKeys.startedBy] = {{26221}},
            [questKeys.finishedBy] = {{25710}},
            [questKeys.preQuestSingle] = {12012},
            [questKeys.requiredLevel] = 65,
        },
        [11970] = { -- The Master of Summer Lore
            [questKeys.startedBy] = {{18927,19148,19171,19172,19173,20102}}, -- it's one random quest starter per layer (probably)
        },
        [11971] = { -- The Spinner of Summer Tales
            [questKeys.startedBy] = {{19169,19175,19176,19177,19178,20102}}, -- it's one random quest starter per layer (probably)
        },
        [11972] = { -- Shards of Ahune
            [questKeys.startedBy] = {nil,nil,{35723}},
            [questKeys.finishedBy] = {{25697}},
            [questKeys.requiredLevel] = 65,
        },
        [11975] = { -- Now, When I Grow Up...
            [questKeys.requiredLevel] = 60,
            [questKeys.questLevel] = -1,
            [questKeys.triggerEnd] = {"Take Salandria to visit the Elite Tauren Chieftain in Silvermoon City.", {[zoneIDs.SILVERMOON_CITY] = {{76.6,81.2}}}},
            [questKeys.preQuestGroup] = {10945,10951,10953},
            [questKeys.zoneOrSort] = sortKeys.SPECIAL,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.requiredSourceItems] = {31880},
        },
        [12012] = { -- Inform the Elder
            [questKeys.startedBy] = {{25324}},
            [questKeys.finishedBy] = {{26221}},
            [questKeys.requiredLevel] = 16,
            [questKeys.questLevel] = -1,
            [questKeys.objectives] = {nil,nil,{{35828}}},
            [questKeys.preQuestSingle] = {11891},
            [questKeys.requiredSourceItems] = {},
        },
        [12020] = { -- This One Time, When I Was Drunk...
            [questKeys.preQuestSingle] = {},
        },
        [12062] = { -- Insult Coren Direbrew
            [questKeys.preQuestSingle] = {},
        },
        [12133] = { -- Smash the Pumpkin
            [questKeys.name] = "Smash the Pumpkin",
            [questKeys.startedBy] = {nil,{186887}},
            [questKeys.finishedBy] = {{24519}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.objectivesText] = {"Give the Scorched Holy Symbol to the Costumed Orphan Matron.",},
            [questKeys.sourceItemId] = 36876,
            [questKeys.zoneOrSort] = sortKeys.SEASONAL,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.questFlags] = 4224,
        },
        [12135] = { -- "Let the Fires Come!"
            [questKeys.name] = "\"Let the Fires Come!\"",
            [questKeys.startedBy] = {{24519}},
            [questKeys.finishedBy] = {{24519}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.objectivesText] = {"The Costumed Orphan Matron wants you to help put out all the village fires after the Headless Horseman lights them. When they are out, speak again to the Costumed Orphan Matron.",},
            [questKeys.triggerEnd] = {"Put Out the Fires", {[zoneIDs.DUN_MOROGH] = {{44.8,52.1},{47.5,51.6}},[zoneIDs.ELWYNN_FOREST] = {{41.3,65.2},{43.6,65.8}},[zoneIDs.AZUREMYST_ISLE] = {{49.8,52.3},{48.8,50}}}},
            [questKeys.preQuestSingle] = {11360,11439,11440},
            [questKeys.zoneOrSort] = sortKeys.SEASONAL,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredSourceItems] = {32971},
            [questKeys.questFlags] = 4224,
            [questKeys.exclusiveTo] = {12133},
        },
        [12139] = { -- "Let the Fires Come!"
            [questKeys.name] = "\"Let the Fires Come!\"",
            [questKeys.startedBy] = {{23973}},
            [questKeys.finishedBy] = {{23973}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.objectivesText] = {"The Masked Orphan Matron wants you to help put out all the village fires. When they are out, speak again to the Masked Orphan Matron in town.",},
            [questKeys.triggerEnd] = {"Put Out the Fires", {[zoneIDs.DUROTAR] = {{52.12,43.59},{53.21,42.56},{51.58,42.08}},[zoneIDs.TIRISFAL_GLADES] = {{60.32,53.29},{61.11,51.25},{61.64,51.97}},[zoneIDs.EVERSONG_WOODS] = {{47.76,47.3},{48.21,46.16}}}},
            [questKeys.preQuestSingle] = {11361,11449,11450},
            [questKeys.zoneOrSort] = sortKeys.SEASONAL,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredSourceItems] = {32971},
            [questKeys.questFlags] = 4224,
            [questKeys.exclusiveTo] = {12155},
        },
        [12155] = { -- Smash the Pumpkin
            [questKeys.name] = "Smash the Pumpkin",
            [questKeys.startedBy] = {nil,{186887}},
            [questKeys.finishedBy] = {{23973}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.objectivesText] = {"Give the Scorched Holy Symbol to the Masked Orphan Matron.",},
            [questKeys.sourceItemId] = 36876,
            [questKeys.zoneOrSort] = sortKeys.SEASONAL,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.questFlags] = 4224,
        },
        [12192] = { -- This One Time, When I Was Drunk...
            [questKeys.name] = "This One Time, When I Was Drunk...",
            [questKeys.startedBy] = {nil,{189990}},
            [questKeys.finishedBy] = {{27216}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.objectivesText] = {"Talk to Bizzle Quicklift in the Brewfest camp.",},
            [questKeys.zoneOrSort] = sortKeys.BREWFEST,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.questFlags] = 4096,
        },
        [12194] = { -- Say, There Wouldn't Happen to be a Souvenir This Year, Would There?
            [questKeys.preQuestSingle] = {11409},
        },
        [12286] = { -- Candy Bucket
            [questKeys.name] = "Candy Bucket",
            [questKeys.startedBy] = {nil,{189303}},
            [questKeys.finishedBy] = {nil,{189303}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.SEASONAL,
        },
        [12318] = { -- Save Brewfest!
            [questKeys.startedBy] = {{27584,28329}},
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.preQuestSingle] = {},
        },
        [12331] = { -- Candy Bucket
            [questKeys.name] = "Candy Bucket",
            [questKeys.startedBy] = {nil,{190034}},
            [questKeys.finishedBy] = {nil,{190034}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.SEASONAL,
        },
        [12332] = { -- Candy Bucket
            [questKeys.name] = "Candy Bucket",
            [questKeys.startedBy] = {nil,{190036}},
            [questKeys.finishedBy] = {nil,{190036}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.SEASONAL,
        },
        [12333] = { -- Candy Bucket
            [questKeys.name] = "Candy Bucket",
            [questKeys.startedBy] = {nil,{190037}},
            [questKeys.finishedBy] = {nil,{190037}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.SEASONAL,
        },
        [12334] = { -- Candy Bucket
            [questKeys.name] = "Candy Bucket",
            [questKeys.startedBy] = {nil,{190038}},
            [questKeys.finishedBy] = {nil,{190038}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.SEASONAL,
        },
        [12335] = { -- Candy Bucket
            [questKeys.name] = "Candy Bucket",
            [questKeys.startedBy] = {nil,{190039}},
            [questKeys.finishedBy] = {nil,{190039}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.SEASONAL,
        },
        [12336] = { -- Candy Bucket
            [questKeys.name] = "Candy Bucket",
            [questKeys.startedBy] = {nil,{190040}},
            [questKeys.finishedBy] = {nil,{190040}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.SEASONAL,
        },
        [12337] = { -- Candy Bucket
            [questKeys.name] = "Candy Bucket",
            [questKeys.startedBy] = {nil,{190041}},
            [questKeys.finishedBy] = {nil,{190041}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.SEASONAL,
        },
        [12338] = { -- Candy Bucket
            [questKeys.name] = "Candy Bucket",
            [questKeys.startedBy] = {nil,{190042}},
            [questKeys.finishedBy] = {nil,{190042}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.SEASONAL,
        },
        [12339] = { -- Candy Bucket
            [questKeys.name] = "Candy Bucket",
            [questKeys.startedBy] = {nil,{190043}},
            [questKeys.finishedBy] = {nil,{190043}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.SEASONAL,
        },
        [12340] = { -- Candy Bucket
            [questKeys.name] = "Candy Bucket",
            [questKeys.startedBy] = {nil,{190047}},
            [questKeys.finishedBy] = {nil,{190047}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.SEASONAL,
        },
        [12341] = { -- Candy Bucket
            [questKeys.name] = "Candy Bucket",
            [questKeys.startedBy] = {nil,{190045}},
            [questKeys.finishedBy] = {nil,{190045}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.SEASONAL,
        },
        [12342] = { -- Candy Bucket
            [questKeys.name] = "Candy Bucket",
            [questKeys.startedBy] = {nil,{190046}},
            [questKeys.finishedBy] = {nil,{190046}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.SEASONAL,
        },
        [12343] = { -- Candy Bucket
            [questKeys.name] = "Candy Bucket",
            [questKeys.startedBy] = {nil,{190044}},
            [questKeys.finishedBy] = {nil,{190044}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.SEASONAL,
        },
        [12344] = { -- Candy Bucket
            [questKeys.name] = "Candy Bucket",
            [questKeys.startedBy] = {nil,{190048}},
            [questKeys.finishedBy] = {nil,{190048}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.SEASONAL,
        },
        [12345] = { -- Candy Bucket
            [questKeys.name] = "Candy Bucket",
            [questKeys.startedBy] = {nil,{190035}},
            [questKeys.finishedBy] = {nil,{190035}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.SEASONAL,
        },
        [12346] = { -- Candy Bucket
            [questKeys.name] = "Candy Bucket",
            [questKeys.startedBy] = {nil,{190049}},
            [questKeys.finishedBy] = {nil,{190049}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.SEASONAL,
        },
        [12347] = { -- Candy Bucket
            [questKeys.name] = "Candy Bucket",
            [questKeys.startedBy] = {nil,{190050}},
            [questKeys.finishedBy] = {nil,{190050}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.SEASONAL,
        },
        [12348] = { -- Candy Bucket
            [questKeys.name] = "Candy Bucket",
            [questKeys.startedBy] = {nil,{190051}},
            [questKeys.finishedBy] = {nil,{190051}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.SEASONAL,
        },
        [12349] = { -- Candy Bucket
            [questKeys.name] = "Candy Bucket",
            [questKeys.startedBy] = {nil,{190052}},
            [questKeys.finishedBy] = {nil,{190052}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.SEASONAL,
        },
        [12350] = { -- Candy Bucket
            [questKeys.name] = "Candy Bucket",
            [questKeys.startedBy] = {nil,{190053}},
            [questKeys.finishedBy] = {nil,{190053}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.SEASONAL,
        },
        [12351] = { -- Candy Bucket
            [questKeys.name] = "Candy Bucket",
            [questKeys.startedBy] = {nil,{190054}},
            [questKeys.finishedBy] = {nil,{190054}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.SEASONAL,
        },
        [12352] = { -- Candy Bucket
            [questKeys.name] = "Candy Bucket",
            [questKeys.startedBy] = {nil,{190055}},
            [questKeys.finishedBy] = {nil,{190055}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.SEASONAL,
        },
        [12353] = { -- Candy Bucket
            [questKeys.name] = "Candy Bucket",
            [questKeys.startedBy] = {nil,{190056}},
            [questKeys.finishedBy] = {nil,{190056}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.SEASONAL,
        },
        [12354] = { -- Candy Bucket
            [questKeys.name] = "Candy Bucket",
            [questKeys.startedBy] = {nil,{190057}},
            [questKeys.finishedBy] = {nil,{190057}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.SEASONAL,
        },
        [12355] = { -- Candy Bucket
            [questKeys.name] = "Candy Bucket",
            [questKeys.startedBy] = {nil,{190058}},
            [questKeys.finishedBy] = {nil,{190058}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.SEASONAL,
        },
        [12356] = { -- Candy Bucket
            [questKeys.name] = "Candy Bucket",
            [questKeys.startedBy] = {nil,{190059}},
            [questKeys.finishedBy] = {nil,{190059}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.SEASONAL,
        },
        [12357] = { -- Candy Bucket
            [questKeys.name] = "Candy Bucket",
            [questKeys.startedBy] = {nil,{190060}},
            [questKeys.finishedBy] = {nil,{190060}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.SEASONAL,
        },
        [12358] = { -- Candy Bucket
            [questKeys.name] = "Candy Bucket",
            [questKeys.startedBy] = {nil,{190061}},
            [questKeys.finishedBy] = {nil,{190061}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.SEASONAL,
        },
        [12359] = { -- Candy Bucket
            [questKeys.name] = "Candy Bucket",
            [questKeys.startedBy] = {nil,{190062}},
            [questKeys.finishedBy] = {nil,{190062}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.SEASONAL,
        },
        [12360] = { -- Candy Bucket
            [questKeys.name] = "Candy Bucket",
            [questKeys.startedBy] = {nil,{190063}},
            [questKeys.finishedBy] = {nil,{190063}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.SEASONAL,
        },
        [12361] = { -- Candy Bucket
            [questKeys.name] = "Candy Bucket",
            [questKeys.startedBy] = {nil,{190064}},
            [questKeys.finishedBy] = {nil,{190064}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.SEASONAL,
        },
        [12362] = { -- Candy Bucket
            [questKeys.name] = "Candy Bucket",
            [questKeys.startedBy] = {nil,{190065}},
            [questKeys.finishedBy] = {nil,{190065}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.SEASONAL,
        },
        [12363] = { -- Candy Bucket
            [questKeys.name] = "Candy Bucket",
            [questKeys.startedBy] = {nil,{190066}},
            [questKeys.finishedBy] = {nil,{190066}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.SEASONAL,
        },
        [12364] = { -- Candy Bucket
            [questKeys.name] = "Candy Bucket",
            [questKeys.startedBy] = {nil,{190067}},
            [questKeys.finishedBy] = {nil,{190067}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.SEASONAL,
        },
        [12365] = { -- Candy Bucket
            [questKeys.name] = "Candy Bucket",
            [questKeys.startedBy] = {nil,{190068}},
            [questKeys.finishedBy] = {nil,{190068}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.SEASONAL,
        },
        [12366] = { -- Candy Bucket
            [questKeys.name] = "Candy Bucket",
            [questKeys.startedBy] = {nil,{190069}},
            [questKeys.finishedBy] = {nil,{190069}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.SEASONAL,
        },
        [12367] = { -- Candy Bucket
            [questKeys.name] = "Candy Bucket",
            [questKeys.startedBy] = {nil,{190070}},
            [questKeys.finishedBy] = {nil,{190070}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.SEASONAL,
        },
        [12368] = { -- Candy Bucket
            [questKeys.name] = "Candy Bucket",
            [questKeys.startedBy] = {nil,{190071}},
            [questKeys.finishedBy] = {nil,{190071}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.SEASONAL,
        },
        [12369] = { -- Candy Bucket
            [questKeys.name] = "Candy Bucket",
            [questKeys.startedBy] = {nil,{190072}},
            [questKeys.finishedBy] = {nil,{190072}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.SEASONAL,
        },
        [12370] = { -- Candy Bucket
            [questKeys.name] = "Candy Bucket",
            [questKeys.startedBy] = {nil,{190073}},
            [questKeys.finishedBy] = {nil,{190073}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.SEASONAL,
        },
        [12371] = { -- Candy Bucket
            [questKeys.name] = "Candy Bucket",
            [questKeys.startedBy] = {nil,{190074}},
            [questKeys.finishedBy] = {nil,{190074}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.SEASONAL,
        },
        [12373] = { -- Candy Bucket
            [questKeys.name] = "Candy Bucket",
            [questKeys.startedBy] = {nil,{190075}},
            [questKeys.finishedBy] = {nil,{190075}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.SEASONAL,
        },
        [12374] = { -- Candy Bucket
            [questKeys.name] = "Candy Bucket",
            [questKeys.startedBy] = {nil,{190076}},
            [questKeys.finishedBy] = {nil,{190076}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.SEASONAL,
        },
        [12375] = { -- Candy Bucket
            [questKeys.name] = "Candy Bucket",
            [questKeys.startedBy] = {nil,{190077}},
            [questKeys.finishedBy] = {nil,{190077}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.SEASONAL,
        },
        [12376] = { -- Candy Bucket
            [questKeys.name] = "Candy Bucket",
            [questKeys.startedBy] = {nil,{190078}},
            [questKeys.finishedBy] = {nil,{190078}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.SEASONAL,
        },
        [12377] = { -- Candy Bucket
            [questKeys.name] = "Candy Bucket",
            [questKeys.startedBy] = {nil,{190079}},
            [questKeys.finishedBy] = {nil,{190079}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.SEASONAL,
        },
        [12378] = { -- Candy Bucket
            [questKeys.name] = "Candy Bucket",
            [questKeys.startedBy] = {nil,{190080}},
            [questKeys.finishedBy] = {nil,{190080}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.SEASONAL,
        },
        [12379] = { -- Candy Bucket
            [questKeys.name] = "Candy Bucket",
            [questKeys.startedBy] = {nil,{190081}},
            [questKeys.finishedBy] = {nil,{190081}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.SEASONAL,
        },
        [12380] = { -- Candy Bucket
            [questKeys.name] = "Candy Bucket",
            [questKeys.startedBy] = {nil,{190082}},
            [questKeys.finishedBy] = {nil,{190082}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.SEASONAL,
        },
        [12381] = { -- Candy Bucket
            [questKeys.name] = "Candy Bucket",
            [questKeys.startedBy] = {nil,{190083}},
            [questKeys.finishedBy] = {nil,{190083}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.SEASONAL,
        },
        [12382] = { -- Candy Bucket
            [questKeys.name] = "Candy Bucket",
            [questKeys.startedBy] = {nil,{190084}},
            [questKeys.finishedBy] = {nil,{190084}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.SEASONAL,
        },
        [12383] = { -- Candy Bucket
            [questKeys.name] = "Candy Bucket",
            [questKeys.startedBy] = {nil,{190085}},
            [questKeys.finishedBy] = {nil,{190085}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.SEASONAL,
        },
        [12384] = { -- Candy Bucket
            [questKeys.name] = "Candy Bucket",
            [questKeys.startedBy] = {nil,{190086}},
            [questKeys.finishedBy] = {nil,{190086}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.SEASONAL,
        },
        [12385] = { -- Candy Bucket
            [questKeys.name] = "Candy Bucket",
            [questKeys.startedBy] = {nil,{190087}},
            [questKeys.finishedBy] = {nil,{190087}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.SEASONAL,
        },
        [12386] = { -- Candy Bucket
            [questKeys.name] = "Candy Bucket",
            [questKeys.startedBy] = {nil,{190088}},
            [questKeys.finishedBy] = {nil,{190088}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.SEASONAL,
        },
        [12387] = { -- Candy Bucket
            [questKeys.name] = "Candy Bucket",
            [questKeys.startedBy] = {nil,{190089}},
            [questKeys.finishedBy] = {nil,{190089}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.SEASONAL,
        },
        [12388] = { -- Candy Bucket
            [questKeys.name] = "Candy Bucket",
            [questKeys.startedBy] = {nil,{190090}},
            [questKeys.finishedBy] = {nil,{190090}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.SEASONAL,
        },
        [12389] = { -- Candy Bucket
            [questKeys.name] = "Candy Bucket",
            [questKeys.startedBy] = {nil,{190091}},
            [questKeys.finishedBy] = {nil,{190091}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.SEASONAL,
        },
        [12390] = { -- Candy Bucket
            [questKeys.name] = "Candy Bucket",
            [questKeys.startedBy] = {nil,{190096}},
            [questKeys.finishedBy] = {nil,{190096}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.SEASONAL,
        },
        [12391] = { -- Candy Bucket
            [questKeys.name] = "Candy Bucket",
            [questKeys.startedBy] = {nil,{190097}},
            [questKeys.finishedBy] = {nil,{190097}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.SEASONAL,
        },
        [12392] = { -- Candy Bucket
            [questKeys.name] = "Candy Bucket",
            [questKeys.startedBy] = {nil,{190098}},
            [questKeys.finishedBy] = {nil,{190098}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.SEASONAL,
        },
        [12393] = { -- Candy Bucket
            [questKeys.name] = "Candy Bucket",
            [questKeys.startedBy] = {nil,{190099}},
            [questKeys.finishedBy] = {nil,{190099}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.SEASONAL,
        },
        [12394] = { -- Candy Bucket
            [questKeys.name] = "Candy Bucket",
            [questKeys.startedBy] = {nil,{190100}},
            [questKeys.finishedBy] = {nil,{190100}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.SEASONAL,
        },
        [12395] = { -- Candy Bucket
            [questKeys.name] = "Candy Bucket",
            [questKeys.startedBy] = {nil,{190101}},
            [questKeys.finishedBy] = {nil,{190101}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.SEASONAL,
        },
        [12396] = { -- Candy Bucket
            [questKeys.name] = "Candy Bucket",
            [questKeys.startedBy] = {nil,{190102}},
            [questKeys.finishedBy] = {nil,{190102}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.zoneOrSort] = sortKeys.SEASONAL,
        },
        [12397] = { -- Candy Bucket
            [questKeys.name] = "Candy Bucket",
            [questKeys.startedBy] = {nil,{190103}},
            [questKeys.finishedBy] = {nil,{190103}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.zoneOrSort] = sortKeys.SEASONAL,
        },
        [12398] = { -- Candy Bucket
            [questKeys.name] = "Candy Bucket",
            [questKeys.startedBy] = {nil,{190104}},
            [questKeys.finishedBy] = {nil,{190104}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.zoneOrSort] = sortKeys.SEASONAL,
        },
        [12399] = { -- Candy Bucket
            [questKeys.name] = "Candy Bucket",
            [questKeys.startedBy] = {nil,{190105}},
            [questKeys.finishedBy] = {nil,{190105}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.zoneOrSort] = sortKeys.SEASONAL,
        },
        [12400] = { -- Candy Bucket
            [questKeys.name] = "Candy Bucket",
            [questKeys.startedBy] = {nil,{190106}},
            [questKeys.finishedBy] = {nil,{190106}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.zoneOrSort] = sortKeys.SEASONAL,
        },
        [12401] = { -- Candy Bucket
            [questKeys.name] = "Candy Bucket",
            [questKeys.startedBy] = {nil,{190107}},
            [questKeys.finishedBy] = {nil,{190107}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.zoneOrSort] = sortKeys.SEASONAL,
        },
        [12402] = { -- Candy Bucket
            [questKeys.name] = "Candy Bucket",
            [questKeys.startedBy] = {nil,{190108}},
            [questKeys.finishedBy] = {nil,{190108}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.zoneOrSort] = sortKeys.SEASONAL,
        },
        [12403] = { -- Candy Bucket
            [questKeys.name] = "Candy Bucket",
            [questKeys.startedBy] = {nil,{190109}},
            [questKeys.finishedBy] = {nil,{190109}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.zoneOrSort] = sortKeys.SEASONAL,
        },
        [12404] = { -- Candy Bucket
            [questKeys.name] = "Candy Bucket",
            [questKeys.startedBy] = {nil,{190110,190111}},
            [questKeys.finishedBy] = {nil,{190110,190111}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.zoneOrSort] = sortKeys.SEASONAL,
        },
        [12406] = { -- Candy Bucket
            [questKeys.name] = "Candy Bucket",
            [questKeys.startedBy] = {nil,{190112}},
            [questKeys.finishedBy] = {nil,{190112}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.zoneOrSort] = sortKeys.SEASONAL,
        },
        [12407] = { -- Candy Bucket
            [questKeys.name] = "Candy Bucket",
            [questKeys.startedBy] = {nil,{190113}},
            [questKeys.finishedBy] = {nil,{190113}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.zoneOrSort] = sortKeys.SEASONAL,
        },
        [12408] = { -- Candy Bucket
            [questKeys.name] = "Candy Bucket",
            [questKeys.startedBy] = {nil,{190114}},
            [questKeys.finishedBy] = {nil,{190114}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.zoneOrSort] = sortKeys.SEASONAL,
        },
        [12409] = { -- Candy Bucket
            [questKeys.name] = "Candy Bucket",
            [questKeys.startedBy] = {nil,{190115,190116}},
            [questKeys.finishedBy] = {nil,{190115,190116}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.zoneOrSort] = sortKeys.SEASONAL,
        },
        [12420] = { -- Brew of the Month Club
            [questKeys.name] = "Brew of the Month Club",
            [questKeys.startedBy] = {nil,nil,{37736}},
            [questKeys.finishedBy] = {{27478}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.objectivesText] = {"Bring the \"Brew of the Month\" club membership form to Larkin Thunderbrew in the Stonefire Tavern in Ironforge."},
            [questKeys.sourceItemId] = 37736,
            [questKeys.zoneOrSort] = sortKeys.BREWFEST,
        },
        [12421] = { -- Brew of the Month Club
            [questKeys.name] = "Brew of the Month Club",
            [questKeys.startedBy] = {nil,nil,{37737}},
            [questKeys.finishedBy] = {{27489}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.objectivesText] = {"Bring the \"Brew of the Month\" club membership form to Ray'ma in the Darkbriar Lodge in Orgrimmar's Valley of Spirits."},
            [questKeys.sourceItemId] = 37737,
            [questKeys.zoneOrSort] = sortKeys.BREWFEST,
        },
        [12513] = { -- Nice Hat...
            [questKeys.zoneOrSort] = zoneIDs.CAVERNS_OF_TIME,
            [questKeys.exclusiveTo] = {12515},
            [questKeys.requiredRaces] = raceIDs.GNOME + raceIDs.HUMAN + raceIDs.DWARF,
        },
        [12515] = { -- Nice Hat...
            [questKeys.zoneOrSort] = zoneIDs.CAVERNS_OF_TIME,
            [questKeys.exclusiveTo] = {12513},
            [questKeys.startedBy] = {{28126}},
            [questKeys.finishedBy] = {{28126}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE + raceIDs.ALL_ALLIANCE - raceIDs.GNOME - raceIDs.HUMAN - raceIDs.DWARF, -- future proof
        },

        -- Below are quests that were not originally in TBC or in a different form

        -- Deluxe promotion quests
        [63448] = { -- A Deluxe Delivery
            [questKeys.name] = "A Deluxe Delivery",
            [questKeys.startedBy] = {{5111,6735,6740,6741,6746,6929,16618,16739,17630,19046,19232}},
            [questKeys.finishedBy] = {{5111,6735,6740,6741,6746,6929,16618,16739,17630,19046,19232}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = 70,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.requiredClasses] = classIDs.NONE,
            [questKeys.objectivesText] = {},
            [questKeys.objectives] = {},
            [questKeys.zoneOrSort] = sortKeys.SPECIAL,
        },
        [63450] = { -- A Deluxe Delivery
            [questKeys.name] = "A Deluxe Delivery",
            [questKeys.startedBy] = {{17249}},
            [questKeys.finishedBy] = {{17249}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = 70,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.requiredClasses] = classIDs.NONE,
            [questKeys.objectivesText] = {},
            [questKeys.objectives] = {},
            [questKeys.zoneOrSort] = sortKeys.SPECIAL,
        },
        [63767] = { -- Imp in a Ball
            [questKeys.name] = "Imp in a Ball",
            [questKeys.startedBy] = {{5111,6735,6740,6741,6746,6929,16618,16739,17630,19046,19232}},
            [questKeys.finishedBy] = {{5111,6735,6740,6741,6746,6929,16618,16739,17630,19046,19232}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = 70,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.requiredClasses] = classIDs.NONE,
            [questKeys.objectivesText] = {},
            [questKeys.objectives] = {},
            [questKeys.zoneOrSort] = sortKeys.SPECIAL,
        },
        [63768] = { -- Imp in a Ball
            [questKeys.name] = "Imp in a Ball",
            [questKeys.startedBy] = {{17249}},
            [questKeys.finishedBy] = {{17249}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = 70,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.requiredClasses] = classIDs.NONE,
            [questKeys.objectivesText] = {},
            [questKeys.objectives] = {},
            [questKeys.zoneOrSort] = sortKeys.SPECIAL,
        },
        [65284] = { -- Goblin Gumbo Kettle
            [questKeys.name] = "Goblin Gumbo Kettle",
            [questKeys.startedBy] = {{5111,6735,6740,6741,6746,6929,16618,16739,17630,19046,19232}},
            [questKeys.finishedBy] = {{5111,6735,6740,6741,6746,6929,16618,16739,17630,19046,19232}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = 70,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.requiredClasses] = classIDs.NONE,
            [questKeys.objectivesText] = {},
            [questKeys.objectives] = {},
            [questKeys.zoneOrSort] = sortKeys.SPECIAL,
        },
        [65285] = { -- Goblin Gumbo Kettle
            [questKeys.name] = "Goblin Gumbo Kettle",
            [questKeys.startedBy] = {{17249}},
            [questKeys.finishedBy] = {{17249}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = 70,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.requiredClasses] = classIDs.NONE,
            [questKeys.objectivesText] = {},
            [questKeys.objectives] = {},
            [questKeys.zoneOrSort] = sortKeys.SPECIAL,
        },
        [65561] = { -- Tabard of Flame
            [questKeys.name] = "Tabard of Flame",
            [questKeys.startedBy] = {{5111,6735,6740,6741,6746,6929,16618,16739,17630,19046,19232}},
            [questKeys.finishedBy] = {{5111,6735,6740,6741,6746,6929,16618,16739,17630,19046,19232}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = 70,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.requiredClasses] = classIDs.NONE,
            [questKeys.objectivesText] = {},
            [questKeys.objectives] = {},
            [questKeys.zoneOrSort] = sortKeys.SPECIAL,
        },
        [65562] = { -- Tabard of Flame
            [questKeys.name] = "Tabard of Flame",
            [questKeys.startedBy] = {{17249}},
            [questKeys.finishedBy] = {{17249}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = 70,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.requiredClasses] = classIDs.NONE,
            [questKeys.objectivesText] = {},
            [questKeys.objectives] = {},
            [questKeys.zoneOrSort] = sortKeys.SPECIAL,
        },
        [93823] = { -- A Grand Delivery
            [questKeys.name] = "A Grand Delivery",
            [questKeys.startedBy] = {{5111,6735,6740,6741,6746,6929,16618,16739,17630,19046,19232}},
            [questKeys.finishedBy] = {{5111,6735,6740,6741,6746,6929,16618,16739,17630,19046,19232}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = 70,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.requiredClasses] = classIDs.NONE,
            [questKeys.objectivesText] = {},
            [questKeys.objectives] = {},
            [questKeys.zoneOrSort] = sortKeys.SPECIAL,
        },
        [93824] = { -- A Grand Delivery
            [questKeys.name] = "A Grand Delivery",
            [questKeys.startedBy] = {{17249}},
            [questKeys.finishedBy] = {{17249}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = 70,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.requiredClasses] = classIDs.NONE,
            [questKeys.objectivesText] = {},
            [questKeys.objectives] = {},
            [questKeys.zoneOrSort] = sortKeys.SPECIAL,
        },
        [96253] = { -- An Unexpected Delivery
            [questKeys.name] = "An Unexpected Delivery",
            [questKeys.startedBy] = {{5111,6735,6740,6741,6746,6929,16618,16739,17630,19046,19232}},
            [questKeys.finishedBy] = {{5111,6735,6740,6741,6746,6929,16618,16739,17630,19046,19232}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = 70,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.requiredClasses] = classIDs.NONE,
            [questKeys.objectivesText] = {},
            [questKeys.objectives] = {},
            [questKeys.zoneOrSort] = sortKeys.SPECIAL,
        },
        [96254] = { -- An Unexpected Delivery
            [questKeys.name] = "An Unexpected Delivery",
            [questKeys.startedBy] = {{17249}},
            [questKeys.finishedBy] = {{17249}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = 70,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.requiredClasses] = classIDs.NONE,
            [questKeys.objectivesText] = {},
            [questKeys.objectives] = {},
            [questKeys.zoneOrSort] = sortKeys.SPECIAL,
        },
        -- Alliance only BG encouragement quest
        [64845] = { -- Alliance War Effort
            [questKeys.name] = "Alliance War Effort",
            [questKeys.startedBy] = {{15351}},
            [questKeys.finishedBy] = {{15351}},
            [questKeys.requiredLevel] = 70,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.objectivesText] = {"Win a battleground match and return to an Alliance Brigadier General at any Alliance capital city or Shattrath."},
            [questKeys.triggerEnd] = {"Victory in a battleground match", {
                [zoneIDs.SHATTRATH_CITY] = {{67.41,33.86}},
                [zoneIDs.IRONFORGE] = {{69.8,90.6}},
                [zoneIDs.DARNASSUS] = {{58,34.4}},
                [zoneIDs.STORMWIND_CITY] = {{79.4,18.0}},
                [zoneIDs.ALTERAC_MOUNTAINS] = {{39.4,82.2}},
                [zoneIDs.ARATHI_HIGHLANDS] = {{45.6,45.8}},
                [zoneIDs.ASHENVALE] = {{61.8,83.8}},
                [zoneIDs.THE_EXODAR] = {{26.6,50.1}},
            }},
            [questKeys.zoneOrSort] = sortKeys.BATTLEGROUNDS,
            [questKeys.questFlags] = questFlags.RAID,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        -- Blood Elf Paladin Epic Mount quest
        [63866] = { -- Claiming the Light
            [questKeys.name] = "Claiming the Light",
            [questKeys.startedBy] = {{178420}},
            [questKeys.finishedBy] = {{17717}},
            [questKeys.requiredLevel] = 12,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.BLOOD_ELF,
            [questKeys.requiredClasses] = classIDs.PALADIN,
            [questKeys.objectivesText] = {"Use the Shimmering Vessel on M'uru to fill it and return to Knight-Lord Bloodvalor in Silvermoon City."},
            [questKeys.objectives] = {nil,nil,{{24156}}},
            [questKeys.sourceItemId] = 185956,
            [questKeys.preQuestSingle] = {9681,64319},
            [questKeys.zoneOrSort] = sortKeys.PALADIN,
            [questKeys.nextQuestInChain] = 9685,
            [questKeys.questFlags] = 128,
        },
        [64139] = { -- A Summons from Lady Liadrin
            [questKeys.name] = "A Summons from Lady Liadrin",
            [questKeys.startedBy] = {{17717}},
            [questKeys.finishedBy] = {{17076}},
            [questKeys.requiredLevel] = 60,
            [questKeys.questLevel] = 60,
            [questKeys.requiredRaces] = raceIDs.BLOOD_ELF,
            [questKeys.requiredClasses] = classIDs.PALADIN,
            [questKeys.objectivesText] = {"Speak with Lady Liadrin in Silvermoon City."},
            [questKeys.zoneOrSort] = sortKeys.PALADIN,
            [questKeys.nextQuestInChain] = 64140,
            [questKeys.questFlags] = 136,
            [questKeys.exclusiveTo] = {9721},
        },
        [64140] = { -- The Master's Path
            [questKeys.name] = "The Master's Path",
            [questKeys.startedBy] = {{17076}},
            [questKeys.finishedBy] = {{17076}},
            [questKeys.requiredLevel] = 60,
            [questKeys.questLevel] = 60,
            [questKeys.requiredRaces] = raceIDs.BLOOD_ELF,
            [questKeys.requiredClasses] = classIDs.PALADIN,
            [questKeys.objectivesText] = {"Speak with Lady Liadrin again to accept her offer of sponsorship."},
            [questKeys.preQuestSingle] = {64139},
            [questKeys.zoneOrSort] = sortKeys.PALADIN,
            [questKeys.nextQuestInChain] = 64141,
            [questKeys.questFlags] = 136,
            [questKeys.exclusiveTo] = {9722},
        },
        [64141] = { -- A Gesture of Commitment
            [questKeys.name] = "A Gesture of Commitment",
            [questKeys.startedBy] = {{17076}},
            [questKeys.finishedBy] = {{17076}},
            [questKeys.requiredLevel] = 60,
            [questKeys.questLevel] = 60,
            [questKeys.requiredRaces] = raceIDs.BLOOD_ELF,
            [questKeys.requiredClasses] = classIDs.PALADIN,
            [questKeys.objectivesText] = {"Bring 40 Runecloth, 6 Arcanite Bars, 10 Sungrass, 5 Dark Runes, and 150 Gold to Lady Liadrin in Silvermoon City. "},
            [questKeys.objectives] = {nil,nil,{{14047},{12360},{8838},{20520}}},
            [questKeys.sourceItemId] = 24277,
            [questKeys.preQuestSingle] = {64140},
            [questKeys.zoneOrSort] = sortKeys.PALADIN,
            [questKeys.nextQuestInChain] = 64142,
            [questKeys.questFlags] = 128,
            [questKeys.exclusiveTo] = {9723},
        },
        [64142] = { -- A Demonstration of Loyalty
            [questKeys.name] = "A Demonstration of Loyalty",
            [questKeys.startedBy] = {{17076}},
            [questKeys.finishedBy] = {{17076}},
            [questKeys.requiredLevel] = 60,
            [questKeys.questLevel] = 60,
            [questKeys.requiredRaces] = raceIDs.BLOOD_ELF,
            [questKeys.requiredClasses] = classIDs.PALADIN,
            [questKeys.objectivesText] = {"Lady Liadrin in Silvermoon City wants you to destroy 3 Scourge Meat Wagons and kill 15 Scourge Siege Engineers. "},
            [questKeys.objectives] = {{{17878}},{{182058}}},
            [questKeys.preQuestSingle] = {64141},
            [questKeys.zoneOrSort] = sortKeys.PALADIN,
            [questKeys.nextQuestInChain] = 64143,
            [questKeys.questFlags] = 136,
            [questKeys.exclusiveTo] = {9725},
        },
        [64143] = { -- True Masters of the Light
            [questKeys.name] = "True Masters of the Light",
            [questKeys.startedBy] = {{17076}},
            [questKeys.finishedBy] = {{17076}},
            [questKeys.requiredLevel] = 60,
            [questKeys.questLevel] = 60,
            [questKeys.requiredRaces] = raceIDs.BLOOD_ELF,
            [questKeys.requiredClasses] = classIDs.PALADIN,
            [questKeys.objectivesText] = {"Lady Liadrin in Silvermoon City wants you to bring her a vial of Tyr's Hand Holy Water. "},
            [questKeys.objectives] = {nil,nil,{{24284}}},
            [questKeys.preQuestSingle] = {64142},
            [questKeys.zoneOrSort] = sortKeys.PALADIN,
            [questKeys.nextQuestInChain] = 64144,
            [questKeys.questFlags] = 136,
            [questKeys.exclusiveTo] = {9735},
        },
        [64144] = { -- True Masters of the Light
            [questKeys.name] = "True Masters of the Light",
            [questKeys.startedBy] = {{17076}},
            [questKeys.finishedBy] = {{17076}},
            [questKeys.requiredLevel] = 60,
            [questKeys.questLevel] = 60,
            [questKeys.requiredRaces] = raceIDs.BLOOD_ELF,
            [questKeys.requiredClasses] = classIDs.PALADIN,
            [questKeys.objectivesText] = {"Lady Liadrin in Silvermoon City wants you to bring her 1 Arcane Catalyst, 1 Crepuscular Powder, 1 Azerothian Diamond, and 1 Pristine Black Diamond."},
            [questKeys.objectives] = {nil,nil,{{24286},{24285},{12800},{18335}}},
            [questKeys.preQuestSingle] = {64143},
            [questKeys.zoneOrSort] = sortKeys.PALADIN,
            [questKeys.nextQuestInChain] = 9737, -- 64145 not offered in p1/p2
            [questKeys.questFlags] = 136,
            [questKeys.exclusiveTo] = {9736},
        },
        [64145] = { -- True Masters of the Light
            [questKeys.name] = "True Masters of the Light",
            [questKeys.startedBy] = {{17076}},
            [questKeys.finishedBy] = {{17076}},
            [questKeys.requiredLevel] = 60,
            [questKeys.questLevel] = 60,
            [questKeys.requiredRaces] = raceIDs.BLOOD_ELF,
            [questKeys.requiredClasses] = classIDs.PALADIN,
            [questKeys.objectivesText] = {"Use the Extinguishing Mixture near the eternal flame in the Alonsus Chapel to remove the Light's protection. Be prepared to fight anyone who may attempt to defend the chapel."},
            [questKeys.objectives] = {nil,nil,nil,nil,{{{17910,17911,17912,17913,17914},17910}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Use the Extinguishing Mixture near the eternal flame"), 0, {{"object", 182068}}}},
            [questKeys.sourceItemId] = 24287,
            [questKeys.preQuestSingle] = {64144},
            [questKeys.zoneOrSort] = sortKeys.PALADIN,
            [questKeys.questFlags] = 128,
            [questKeys.exclusiveTo] = {9737},
        },
        -------------
        [64319] = { -- A Study in Power
            [questKeys.name] = "A Study in Power",
            [questKeys.startedBy] = {{17717,178420}},
            [questKeys.finishedBy] = {{178420}},
            [questKeys.requiredLevel] = 12,
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.BLOOD_ELF,
            [questKeys.requiredClasses] = classIDs.PALADIN,
            [questKeys.objectivesText] = {"Speak with Magister Astalor Bloodsworn in the hidden chamber beneath Blood Knight headquarters."},
            [questKeys.objectives] = {},
            [questKeys.preQuestSingle] = {9678},
            [questKeys.zoneOrSort] = sortKeys.PALADIN,
            [questKeys.nextQuestInChain] = 63866,
            [questKeys.questFlags] = 136,
        },

        ----- Boosted character quests -----
        [64028] = { -- A New Beginning
            [questKeys.name] = "A New Beginning",
            [questKeys.startedBy] = {}, -- This quest is auto accept
            [questKeys.finishedBy] = {{376,914,928,5495,5497,5505,5515,13283}},
            [questKeys.requiredLevel] = 58,
            [questKeys.questLevel] = 58,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.objectivesText] = {"Meet with your class trainer in Stormwind."},
            [questKeys.zoneOrSort] = zoneIDs.STORMWIND_CITY,
        },
        [64031] = { -- Tools for Survival
            [questKeys.name] = "Tools for Survival",
            [questKeys.startedBy] = {{376,914,928,5495,5497,5505,5515,13283}},
            [questKeys.finishedBy] = {{376,914,928,5495,5497,5505,5515,13283}},
            [questKeys.requiredLevel] = 58,
            [questKeys.questLevel] = 58,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.objectivesText] = {"Open the survival kit and equip a weapon."},
            [questKeys.objectives] = {nil,{{410010}, {410011}}},
            [questKeys.preQuestSingle] = {64028},
            [questKeys.zoneOrSort] = zoneIDs.STORMWIND_CITY,
        },
        [64034] = { -- Combat Training
            [questKeys.name] = "Combat Training",
            [questKeys.startedBy] = {{376,914,928,5495,5497,5505,5515,13283}},
            [questKeys.finishedBy] = {{376,914,928,5495,5497,5505,5515,13283}},
            [questKeys.requiredLevel] = 58,
            [questKeys.questLevel] = 58,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.objectivesText] = {"Train a spell by speaking to your class trainer."},
            [questKeys.objectives] = {nil,{{410012}}},
            [questKeys.preQuestSingle] = {64031},
            [questKeys.zoneOrSort] = zoneIDs.STORMWIND_CITY,
        },
        [64035] = { -- Talented
            [questKeys.name] = "Talented",
            [questKeys.startedBy] = {{376,914,928,5495,5497,5505,5515,13283}},
            [questKeys.finishedBy] = {{376,914,928,5495,5497,5505,5515,13283}},
            [questKeys.requiredLevel] = 58,
            [questKeys.questLevel] = 58,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.objectivesText] = {"Activate the Talents interface and allocate a Talent Point."},
            [questKeys.objectives] = {nil,{{410013}}},
            [questKeys.preQuestSingle] = {64034},
            [questKeys.zoneOrSort] = zoneIDs.STORMWIND_CITY,
        },
        [64037] = { -- Eastern Plaguelands
            [questKeys.name] = "Eastern Plaguelands",
            [questKeys.startedBy] = {{376,914,928,5495,5497,5505,5515,13283}},
            [questKeys.finishedBy] = {{11036}},
            [questKeys.requiredLevel] = 58,
            [questKeys.questLevel] = 58,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.objectivesText] = {"Travel to the Eastern Plaguelands and find Leonid Barthalomew. He awaits your arrival at Light's Hope Chapel. "},
            [questKeys.objectives] = {{{352,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.preQuestSingle] = {64035},
            [questKeys.exclusiveTo] = {64038},
            [questKeys.zoneOrSort] = zoneIDs.EASTERN_PLAGUELANDS,
        },
        [64038] = { -- The Dark Portal
            [questKeys.name] = "The Dark Portal",
            [questKeys.startedBy] = {{331,376,914,928,5495,5497,5505,5515,13283}},
            [questKeys.finishedBy] = {{16841}},
            [questKeys.requiredLevel] = 58,
            [questKeys.questLevel] = 58,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.objectivesText] = {"Find Watch Commander Relthorn Netherwane at the Blasted Lands. He awaits your arrival before the Dark Portal."},
            [questKeys.objectives] = {{{352,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.preQuestSingle] = {64035},
            [questKeys.zoneOrSort] = zoneIDs.BLASTED_LANDS,
        },
        [64046] = { -- A New Beginning
            [questKeys.name] = "A New Beginning",
            [questKeys.startedBy] = {}, -- This quest is auto accept
            [questKeys.finishedBy] = {{3324,3328,3344,3353,3406,5885,5994}},
            [questKeys.requiredLevel] = 58,
            [questKeys.questLevel] = 58,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.objectivesText] = {"Meet with your class trainer in Orgrimmar."},
            [questKeys.zoneOrSort] = zoneIDs.ORGRIMMAR,
        },
        [64047] = { -- A New Beginning
            [questKeys.name] = "A New Beginning",
            [questKeys.startedBy] = {}, -- This quest is auto accept
            [questKeys.finishedBy] = {{3036}},
            [questKeys.requiredLevel] = 58,
            [questKeys.questLevel] = 58,
            [questKeys.requiredRaces] = raceIDs.TAUREN,
            [questKeys.requiredClasses] = classIDs.DRUID,
            [questKeys.objectivesText] = {"Meet with your Druid trainer in Thunder Bluff."},
            [questKeys.zoneOrSort] = zoneIDs.THUNDER_BLUFF,
        },
        [64048] = { -- Tools for Survival
            [questKeys.name] = "Tools for Survival",
            [questKeys.startedBy] = {{3324,3328,3344,3353,3406,5885,5994}},
            [questKeys.finishedBy] = {{3324,3328,3344,3353,3406,5885,5994}},
            [questKeys.requiredLevel] = 58,
            [questKeys.questLevel] = 58,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.objectivesText] = {"Open the survival kit and equip a weapon."},
            [questKeys.objectives] = {nil,{{410002}, {410003}}},
            [questKeys.preQuestSingle] = {64046},
            [questKeys.zoneOrSort] = zoneIDs.ORGRIMMAR,
        },
        [64049] = { -- Tools for Survival
            [questKeys.name] = "Tools for Survival",
            [questKeys.startedBy] = {{3036}},
            [questKeys.finishedBy] = {{3036}},
            [questKeys.requiredLevel] = 58,
            [questKeys.questLevel] = 58,
            [questKeys.requiredRaces] = raceIDs.TAUREN,
            [questKeys.requiredClasses] = classIDs.DRUID,
            [questKeys.objectivesText] = {"Open the survival kit and equip a weapon."},
            [questKeys.objectives] = {nil,{{410004}, {410005}}},
            [questKeys.preQuestSingle] = {64047},
            [questKeys.zoneOrSort] = zoneIDs.THUNDER_BLUFF,
        },
        [64050] = { -- Combat Training
            [questKeys.name] = "Combat Training",
            [questKeys.startedBy] = {{3324,3328,3344,3353,3406,5885,5994}},
            [questKeys.finishedBy] = {{3324,3328,3344,3353,3406,5885,5994}},
            [questKeys.requiredLevel] = 58,
            [questKeys.questLevel] = 58,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.objectivesText] = {"Train a spell by speaking to your class trainer."},
            [questKeys.objectives] = {nil,{{410006}}},
            [questKeys.preQuestSingle] = {64048},
            [questKeys.zoneOrSort] = zoneIDs.ORGRIMMAR,
        },
        [64051] = { -- Combat Training
            [questKeys.name] = "Combat Training",
            [questKeys.startedBy] = {{3036}},
            [questKeys.finishedBy] = {{3036}},
            [questKeys.requiredLevel] = 58,
            [questKeys.questLevel] = 58,
            [questKeys.requiredRaces] = raceIDs.TAUREN,
            [questKeys.requiredClasses] = classIDs.DRUID,
            [questKeys.objectivesText] = {"Train a spell by speaking to your Druid trainer."},
            [questKeys.objectives] = {nil,{{410007}}},
            [questKeys.preQuestSingle] = {64049},
            [questKeys.zoneOrSort] = zoneIDs.THUNDER_BLUFF,
        },
        [64052] = { -- Talented
            [questKeys.name] = "Talented",
            [questKeys.startedBy] = {{3324,3328,3344,3353,3406,5885,5994}},
            [questKeys.finishedBy] = {{3324,3328,3344,3353,3406,5885,5994}},
            [questKeys.requiredLevel] = 58,
            [questKeys.questLevel] = 58,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.objectivesText] = {"Activate the Talents interface and allocate five Talent Points."},
            [questKeys.objectives] = {nil,{{410008}}},
            [questKeys.preQuestSingle] = {64050},
            [questKeys.zoneOrSort] = zoneIDs.ORGRIMMAR,
        },
        [64053] = { -- Talented
            [questKeys.name] = "Talented",
            [questKeys.startedBy] = {{3036}},
            [questKeys.finishedBy] = {{3036}},
            [questKeys.requiredLevel] = 58,
            [questKeys.questLevel] = 58,
            [questKeys.requiredRaces] = raceIDs.TAUREN,
            [questKeys.requiredClasses] = classIDs.DRUID,
            [questKeys.objectivesText] = {"Activate the Talents interface and allocate five Talent Points."},
            [questKeys.objectives] = {nil,{{410009}}},
            [questKeys.preQuestSingle] = {64051},
            [questKeys.zoneOrSort] = zoneIDs.THUNDER_BLUFF,
        },
        [64063] = { -- The Dark Portal
            [questKeys.name] = "The Dark Portal",
            [questKeys.startedBy] = {{3324,3328,3344,3353,3406,5885,5994}},
            [questKeys.finishedBy] = {{19254}},
            [questKeys.requiredLevel] = 58,
            [questKeys.questLevel] = 58,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.objectivesText] = {"Find Watch Warlord Dar'toon at the Blasted Lands. He awaits your arrival before the Dark Portal."},
            [questKeys.objectives] = {{{12136,nil,Questie.ICON_TYPE_INTERACT},{1387,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.preQuestSingle] = {64052},
            [questKeys.exclusiveTo] = {64217},
            [questKeys.zoneOrSort] = zoneIDs.BLASTED_LANDS,
        },
        [64064] = { -- Eastern Plaguelands
            [questKeys.name] = "Eastern Plaguelands",
            [questKeys.startedBy] = {{3324,3328,3344,3353,3406,5885,5994}},
            [questKeys.finishedBy] = {{11036}},
            [questKeys.requiredLevel] = 58,
            [questKeys.questLevel] = 58,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.objectivesText] = {"Travel to the Eastern Plaguelands and find Leonid Barthalomew. He awaits your arrival at Light's Hope Chapel. "},
            [questKeys.objectives] = {{{9564,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.preQuestSingle] = {64052},
            [questKeys.exclusiveTo] = {64063,64217,64128},
            [questKeys.zoneOrSort] = zoneIDs.EASTERN_PLAGUELANDS,
        },
        [64128] = { -- Eastern Plaguelands
            [questKeys.name] = "Eastern Plaguelands",
            [questKeys.startedBy] = {{3036}},
            [questKeys.finishedBy] = {{11036}},
            [questKeys.requiredLevel] = 58,
            [questKeys.questLevel] = 58,
            [questKeys.requiredRaces] = raceIDs.TAUREN,
            [questKeys.requiredClasses] = classIDs.DRUID,
            [questKeys.objectivesText] = {"Travel to the Eastern Plaguelands and find Leonid Barthalomew. He awaits your arrival at Light's Hope Chapel. "},
            [questKeys.objectives] = {{{9564,nil,Questie.ICON_TYPE_TALK},{9564,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.preQuestSingle] = {64053},
            [questKeys.exclusiveTo] = {64063,64064,64217},
            [questKeys.zoneOrSort] = zoneIDs.EASTERN_PLAGUELANDS,
        },
        [64217] = { -- The Dark Portal
            [questKeys.name] = "The Dark Portal",
            [questKeys.startedBy] = {{3036}},
            [questKeys.finishedBy] = {{19254}},
            [questKeys.requiredLevel] = 58,
            [questKeys.questLevel] = 58,
            [questKeys.requiredRaces] = raceIDs.TAUREN,
            [questKeys.objectivesText] = {"Find Watch Warlord Dar'toon at the Blasted Lands. He awaits your arrival before the Dark Portal."},
            [questKeys.objectives] = {{{12136,nil,Questie.ICON_TYPE_INTERACT},{1387,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.preQuestSingle] = {64053},
            [questKeys.exclusiveTo] = {64063,64064,64128},
            [questKeys.zoneOrSort] = zoneIDs.BLASTED_LANDS,
        },
        ----- TBC Anniversary quests -----
        [95158] = { -- Reset Current Rating - 2v2
            [questKeys.name] = "Reset Current Rating - 2v2",
            [questKeys.startedBy] = {{18897,19856}},
            [questKeys.finishedBy] = {{18897,19856}},
            [questKeys.requiredLevel] = 70,
            [questKeys.questLevel] = 70,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.objectivesText] = {"Pay 40 gold to an Arena Organizer to reset Current 2v2 Arena Rating back to 1500."},
            [questKeys.zoneOrSort] = zoneIDs.THE_RING_OF_TRIALS,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.questFlags] = questFlags.WEEKLY,
        },
        [95251] = { -- Reset Current Rating - 3v3
            [questKeys.name] = "Reset Current Rating - 3v3",
            [questKeys.startedBy] = {{18897,19856}},
            [questKeys.finishedBy] = {{18897,19856}},
            [questKeys.requiredLevel] = 70,
            [questKeys.questLevel] = 70,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.objectivesText] = {"Pay 40 gold to an Arena Organizer to reset Current 3v3 Arena Rating back to 1500."},
            [questKeys.zoneOrSort] = zoneIDs.THE_RING_OF_TRIALS,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.questFlags] = questFlags.WEEKLY,
        },
        [95252] = { -- Reset Current Rating - 5v5
            [questKeys.name] = "Reset Current Rating - 5v5",
            [questKeys.startedBy] = {{18897,19856}},
            [questKeys.finishedBy] = {{18897,19856}},
            [questKeys.requiredLevel] = 70,
            [questKeys.questLevel] = 70,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.objectivesText] = {"Pay 40 gold to an Arena Organizer to reset Current 5v5 Arena Rating back to 1500."},
            [questKeys.zoneOrSort] = zoneIDs.THE_RING_OF_TRIALS,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.questFlags] = questFlags.WEEKLY,
        },
        [95455] = { -- Concerted Efforts
            [questKeys.name] = "Concerted Efforts",
            [questKeys.startedBy] = {{15351}},
            [questKeys.finishedBy] = {{15351}},
            [questKeys.requiredLevel] = 51,
            [questKeys.questLevel] = 60,
            [questKeys.requiredMaxLevel] = 60,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.objectivesText] = {"Bring 1 Alterac Valley Mark of Honor, 1 Arathi Basin Mark of Honor, 1 Warsong Gulch Mark of Honor and 1 Eye of the Storm Mark of Honor to an Alliance Brigadier General in any Alliance Capital City or Shattrath."},
            [questKeys.objectives] = {nil,nil,{{20560},{20559},{20558}}},
            [questKeys.zoneOrSort] = sortKeys.BATTLEGROUNDS,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        --[[[95456] = { -- Concerted Efforts
            [questKeys.name] = "Concerted Efforts",
            [questKeys.startedBy] = {{15351}},
            [questKeys.finishedBy] = {{15351}},
            [questKeys.requiredLevel] = 51,
            [questKeys.questLevel] = 60,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.objectivesText] = nil,
            [questKeys.objectives] = {nil,nil,{{20560},{20559},{20558}}},
            [questKeys.zoneOrSort] = sortKeys.BATTLEGROUNDS,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },]]
        [95457] = { -- For Great Honor
            [questKeys.name] = "For Great Honor",
            [questKeys.startedBy] = {{15350}},
            [questKeys.finishedBy] = {{15350}},
            [questKeys.requiredLevel] = 51,
            [questKeys.questLevel] = 60,
            [questKeys.requiredMaxLevel] = 60,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.objectivesText] = {"Bring 1 Alterac Valley Mark of Honor, 1 Arathi Basin Mark of Honor, 1 Warsong Gulch Mark of Honor and 1 Eye of the Storm Mark of Honor to a Horde Warbringer in any Horde capital city or Shattrath."},
            [questKeys.objectives] = {nil,nil,{{20560},{20559},{20558}}},
            [questKeys.zoneOrSort] = sortKeys.BATTLEGROUNDS,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        --[[[95458] = { -- For Great Honor
            [questKeys.name] = "For Great Honor",
            [questKeys.startedBy] = {{15350}},
            [questKeys.finishedBy] = {{15350}},
            [questKeys.requiredLevel] = 51,
            [questKeys.questLevel] = 60,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.objectivesText] = nil,
            [questKeys.objectives] = {nil,nil,{{20560},{20559},{20558}}},
            [questKeys.zoneOrSort] = sortKeys.BATTLEGROUNDS,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },]]
    }
end

function QuestieTBCQuestFixes:LoadFactionFixes()
    local questKeys = QuestieDB.questKeys
    local raceIDs = QuestieDB.raceKeys
    local playerClass = UnitClassBase("player")
    local playerRace = select(2, UnitRace("player"))
    local factionIDs = QuestieDB.factionIDs

    local questFixesHorde = {
        [1393] = { -- Galen's Escape
            [questKeys.reputationReward] = {{factionIDs.HORDE,75}},
        },
        [1718] = { -- The Islander
            [questKeys.startedBy] = {{3041,3354,4595}},
        },
        [1947] = { -- Journey to the Marsh
            [questKeys.startedBy] = {{3048,4568,5885,16652}},
        },
        [1953] = { -- Return to the Marsh
            [questKeys.startedBy] = {{3048,4568,5885,16652}},
        },
        [2861] = { -- Tabetha's Task
            [questKeys.startedBy] = {{4568,5885,16651}}
        },
        [4738] = { -- In Search of Menara Voidrender
            [questKeys.startedBy] = {{16646}},
        },
        [8151] = { -- The Hunter's Charm
            [questKeys.startedBy] = {{3039,3352,16673}},
        },
        [8233] = { -- A Simple Request
            [questKeys.startedBy] = {{3328,4583,16684}},
        },
        [8250] = { -- Magecraft
            [questKeys.startedBy] = {{3047,4567,7311,16652}},
        },
        [8254] = { -- Cenarion Aid
            [questKeys.startedBy] = {{3045,6018,16658}},
        },
        [8410] = { -- Elemental Mastery
            [questKeys.startedBy] = {{3032,13417}},
        },
        [8417] = { -- A Troubled Spirit
            [questKeys.startedBy] = {{3041,3354,4593}},
        },
        [8419] = { -- An Imp's Request
            [questKeys.startedBy] = {{3326,4563,16647}},
        },
        [8619] = { -- Morndeep the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE,75}},
        },
        [8635] = { -- Splitrock the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE,75}},
        },
        [8636] = { -- Rumblerock the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE,75}},
        },
        [8642] = { -- Silvervein the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE,75}},
        },
        [8643] = { -- Highpeak the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE,75}},
        },
        [8644] = { -- Stonefort the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE,75}},
        },
        [8645] = { -- Obsidian the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE,75}},
        },
        [8646] = { -- Hammershout the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE,75}},
        },
        [8647] = { -- Bellowrage the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE,75}},
        },
        [8648] = { -- Darkcore the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE,75}},
        },
        [8649] = { -- Stormbrow the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE,75}},
        },
        [8650] = { -- Snowcrown the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE,75}},
        },
        [8651] = { -- Ironband the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE,75}},
        },
        [8652] = { -- Graveborn the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE,75}},
        },
        [8653] = { -- Goldwell the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE,75}},
        },
        [8654] = { -- Primestone the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE,75}},
        },
        [8670] = { -- Runetotem the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE,75}},
        },
        [8671] = { -- Ragetotem the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE,75}},
        },
        [8672] = { -- Stonespire the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE,75}},
        },
        [8673] = { -- Bloodhoof the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE,75}},
        },
        [8674] = { -- Winterhoof the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE,75}},
        },
        [8675] = { -- Skychaser the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE,75}},
        },
        [8676] = { -- Wildmane the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE,75}},
        },
        [8677] = { -- Darkhorn the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE,75}},
        },
        [8678] = { -- Proudhorn the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE,75}},
        },
        [8679] = { -- Grimtotem the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE,75}},
        },
        [8680] = { -- Windtotem the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE,75}},
        },
        [8681] = { -- Thunderhorn the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE,75}},
        },
        [8682] = { -- Skyseer the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE,75}},
        },
        [8683] = { -- Dawnstrider the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE,75}},
        },
        [8684] = { -- Dreamseer the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE,75}},
        },
        [8685] = { -- Mistwalker the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE,75}},
        },
        [8686] = { -- High Mountain the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE,75}},
        },
        [8688] = { -- Windrun the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE,75}},
        },
        [8713] = { -- Starsong the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE,75}},
        },
        [8714] = { -- Moonstrike the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE,75}},
        },
        [8715] = { -- Bladeleaf the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE,75}},
        },
        [8716] = { -- Starglade the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE,75}},
        },
        [8717] = { -- Moonwarden the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE,75}},
        },
        [8718] = { -- Bladeswift the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE,75}},
        },
        [8719] = { -- Bladesing the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE,75}},
        },
        [8720] = { -- Skygleam the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE,75}},
        },
        [8721] = { -- Starweave the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE,75}},
        },
        [8722] = { -- Meadowrun the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE,75}},
        },
        [8723] = { -- Nightwind the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE,75}},
        },
        [8724] = { -- Morningdew the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE,75}},
        },
        [8725] = { -- Riversong the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE,75}},
        },
        [8726] = { -- Brightspear the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE,75}},
        },
        [8727] = { -- Farwhisper the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE,75}},
        },
        [8866] = { -- Bronzebeard the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE,75}},
        },
        [8978] = { -- Return to Mokvar
            [questKeys.nextQuestInChain] = ({
                ["DRUID"]   = 8927,
                ["HUNTER"]  = 8938,
                ["MAGE"]    = 8939,
                ["PALADIN"] = 10495,
                ["PRIEST"]  = 8940,
                ["ROGUE"]   = 8941,
                ["SHAMAN"]  = 8942,
                ["WARLOCK"] = 8943,
                ["WARRIOR"] = 8944,
            })[playerClass],
        },
        [8998] = { -- Back to the Beginning
            [questKeys.nextQuestInChain] = ({
                ["DRUID"]   = 9007,
                ["HUNTER"]  = 9008,
                ["MAGE"]    = 9014,
                ["PALADIN"] = 10499,
                ["PRIEST"]  = 9009,
                ["ROGUE"]   = 9010,
                ["SHAMAN"]  = 9011,
                ["WARLOCK"] = 9012,
                ["WARRIOR"] = 9013,
            })[playerClass],
        },
        [9015] = { -- The Challenge
            [questKeys.nextQuestInChain] = ({
                ["DRUID"]   = 9016,
                ["HUNTER"]  = 9017,
                ["MAGE"]    = 9018,
                ["PALADIN"] = 10497,
                ["PRIEST"]  = 9019,
                ["ROGUE"]   = 9020,
                ["SHAMAN"]  = 8957,
                ["WARLOCK"] = 9021,
                ["WARRIOR"] = 9022,
            })[playerClass],
        },
        [9063] = { -- Torwa Pathfinder
            [questKeys.startedBy] = {{3033,12042,16655}},
        },
        [9990] = { -- Investigate Tuurem
            [questKeys.nextQuestInChain] = 9995,
        },
        [10858] = { -- Karynaku
            [questKeys.nextQuestInChain] = 10866,
        },
    }

    local questFixesAlliance = {
        [1393] = { -- Galen's Escape
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,75}},
        },
        [1718] = { -- The Islander
            [questKeys.startedBy] = {{5113,5479,16771}},
        },
        [1947] = { -- Journey to the Marsh
            [questKeys.startedBy] = {{5144,5497,17513}},
        },
        [1953] = { -- Return to the Marsh
            [questKeys.startedBy] = {{5144,5497,17513}},
        },
        [2861] = { -- Tabetha's Task
            [questKeys.startedBy] = {{5144,5497,17514}}
        },
        [4738] = { -- In Search of Menara Voidrender
            [questKeys.startedBy] = {{461}},
        },
        [5054] = { -- Ursius of the Shardtooth
            [questKeys.reputationReward] = {},
        },
        [5057] = { -- Past Endeavors
            [questKeys.reputationReward] = {},
        },
        [8151] = { -- The Hunter's Charm
            [questKeys.startedBy] = {{4205,5116,5516,17505}},
        },
        [8250] = { -- Magecraft
            [questKeys.startedBy] = {{331,7312,17513}},
        },
        [8254] = { -- Cenarion Aid
            [questKeys.startedBy] = {{5489,11406,16756}},
        },
        [8410] = { -- Elemental Mastery
            [questKeys.startedBy] = {{17219,20407,23127}},
        },
        [8417] = { -- A Troubled Spirit
            [questKeys.startedBy] = {{5113,5479,7315,17120}},
        },
        [8419] = { -- An Imp's Request
            [questKeys.startedBy] = {{461,5172}},
        },
        [8619] = { -- Morndeep the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,75}},
        },
        [8635] = { -- Splitrock the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,75}},
        },
        [8636] = { -- Rumblerock the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,75}},
        },
        [8642] = { -- Silvervein the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,75}},
        },
        [8643] = { -- Highpeak the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,75}},
        },
        [8644] = { -- Stonefort the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,75}},
        },
        [8645] = { -- Obsidian the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,75}},
        },
        [8646] = { -- Hammershout the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,75}},
        },
        [8647] = { -- Bellowrage the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,75}},
        },
        [8648] = { -- Darkcore the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,75}},
        },
        [8649] = { -- Stormbrow the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,75}},
        },
        [8650] = { -- Snowcrown the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,75}},
        },
        [8651] = { -- Ironband the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,75}},
        },
        [8652] = { -- Graveborn the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,75}},
        },
        [8653] = { -- Goldwell the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,75}},
        },
        [8654] = { -- Primestone the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,75}},
        },
        [8670] = { -- Runetotem the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,75}},
        },
        [8671] = { -- Ragetotem the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,75}},
        },
        [8672] = { -- Stonespire the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,75}},
        },
        [8673] = { -- Bloodhoof the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,75}},
        },
        [8674] = { -- Winterhoof the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,75}},
        },
        [8675] = { -- Skychaser the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,75}},
        },
        [8676] = { -- Wildmane the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,75}},
        },
        [8677] = { -- Darkhorn the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,75}},
        },
        [8678] = { -- Proudhorn the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,75}},
        },
        [8679] = { -- Grimtotem the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,75}},
        },
        [8680] = { -- Windtotem the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,75}},
        },
        [8681] = { -- Thunderhorn the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,75}},
        },
        [8682] = { -- Skyseer the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,75}},
        },
        [8683] = { -- Dawnstrider the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,75}},
        },
        [8684] = { -- Dreamseer the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,75}},
        },
        [8685] = { -- Mistwalker the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,75}},
        },
        [8686] = { -- High Mountain the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,75}},
        },
        [8688] = { -- Windrun the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,75}},
        },
        [8713] = { -- Starsong the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,75}},
        },
        [8714] = { -- Moonstrike the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,75}},
        },
        [8715] = { -- Bladeleaf the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,75}},
        },
        [8716] = { -- Starglade the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,75}},
        },
        [8717] = { -- Moonwarden the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,75}},
        },
        [8718] = { -- Bladeswift the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,75}},
        },
        [8719] = { -- Bladesing the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,75}},
        },
        [8720] = { -- Skygleam the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,75}},
        },
        [8721] = { -- Starweave the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,75}},
        },
        [8722] = { -- Meadowrun the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,75}},
        },
        [8723] = { -- Nightwind the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,75}},
        },
        [8724] = { -- Morningdew the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,75}},
        },
        [8725] = { -- Riversong the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,75}},
        },
        [8726] = { -- Brightspear the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,75}},
        },
        [8727] = { -- Farwhisper the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,75}},
        },
        [8866] = { -- Bronzebeard the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,75}},
        },
        [8977] = { -- Return to Deliana
            [questKeys.nextQuestInChain] = ({
                ["DRUID"]   = 8926,
                ["HUNTER"]  = 8931,
                ["MAGE"]    = 8932,
                ["PALADIN"] = 8933,
                ["PRIEST"]  = 8934,
                ["ROGUE"]   = 8935,
                ["SHAMAN"]  = 10494,
                ["WARLOCK"] = 8936,
                ["WARRIOR"] = 8937,
            })[playerClass],
        },
        [8997] = { -- Back to the Beginning
            [questKeys.nextQuestInChain] = ({
                ["DRUID"]   = 8999,
                ["HUNTER"]  = 9000,
                ["MAGE"]    = 9001,
                ["PALADIN"] = 9002,
                ["PRIEST"]  = 9003,
                ["ROGUE"]   = 9004,
                ["SHAMAN"]  = 10498,
                ["WARLOCK"] = 9005,
                ["WARRIOR"] = 9006,
            })[playerClass],
        },
        [9015] = { -- The Challenge
            [questKeys.nextQuestInChain] = ({
                ["DRUID"]   = 8951,
                ["HUNTER"]  = 8952,
                ["MAGE"]    = 8953,
                ["PALADIN"] = 8954,
                ["PRIEST"]  = 8955,
                ["ROGUE"]   = 8956,
                ["SHAMAN"]  = 10496,
                ["WARLOCK"] = 8958,
                ["WARRIOR"] = 8959,
            })[playerClass],
        },
        [9063] = { -- Torwa Pathfinder
            [questKeys.startedBy] = {{4217,5505,12042,16721}},
        },
        [9990] = { -- Investigate Tuurem
            [questKeys.nextQuestInChain] = 9994,
        },
        [10858] = { -- Karynaku
            [questKeys.nextQuestInChain] = playerRace == "Human" and 10872 or 10866,
        },
    }

    if UnitFactionGroup("Player") == "Horde" then
        return questFixesHorde
    else
        return questFixesAlliance
    end
end

-- Use ContentPhases to apply corrections specific to the current content phase
function QuestieTBCQuestFixes:LoadContentPhaseFixes()
    local questKeys = QuestieDB.questKeys
    return {
        [10944] = { -- The Secret Compromised
            [questKeys.preQuestGroup] = Expansions.Current == Expansions.Tbc and ContentPhases.activePhases.TBC < 3 and {10901,11052} or {}, -- SSC + TK attunements removed in P3
            [questKeys.preQuestSingle] = Expansions.Current == Expansions.Tbc and ContentPhases.activePhases.TBC < 3 and {} or {10708,11052}, -- SSC + TK attunements removed in P3
        },
        [11007] = { -- Kael'thas and the Verdant Sphere
            [questKeys.preQuestSingle] = Expansions.Current == Expansions.Tbc and ContentPhases.activePhases.TBC < 3 and {10888} or {}, -- SSC + TK attunements removed in P3
        },
    }
end
