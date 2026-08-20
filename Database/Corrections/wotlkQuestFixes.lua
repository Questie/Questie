---@class QuestieWotlkQuestFixes
local QuestieWotlkQuestFixes = QuestieLoader:CreateModule("QuestieWotlkQuestFixes")
local _QuestieWotlkQuestFixes = {}

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule("ZoneDB")
---@type QuestieProfessions
local QuestieProfessions = QuestieLoader:ImportModule("QuestieProfessions")
---@type QuestieCorrections
local QuestieCorrections = QuestieLoader:ImportModule("QuestieCorrections")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")


QuestieCorrections.killCreditObjectiveFirst[11652] = true
QuestieCorrections.killCreditObjectiveFirst[12100] = true
QuestieCorrections.killCreditObjectiveFirst[12546] = true
QuestieCorrections.killCreditObjectiveFirst[12561] = true
QuestieCorrections.killCreditObjectiveFirst[12762] = true
QuestieCorrections.killCreditObjectiveFirst[12779] = true
QuestieCorrections.killCreditObjectiveFirst[12919] = true
QuestieCorrections.killCreditObjectiveFirst[13086] = true
QuestieCorrections.killCreditObjectiveFirst[13373] = true
QuestieCorrections.killCreditObjectiveFirst[13376] = true
QuestieCorrections.killCreditObjectiveFirst[13380] = true
QuestieCorrections.killCreditObjectiveFirst[13382] = true
QuestieCorrections.killCreditObjectiveFirst[13404] = true
QuestieCorrections.killCreditObjectiveFirst[13406] = true
QuestieCorrections.killCreditObjectiveFirst[24498] = true
QuestieCorrections.killCreditObjectiveFirst[24507] = true

function QuestieWotlkQuestFixes:Load()
    local questKeys = QuestieDB.questKeys
    local raceIDs = QuestieDB.raceKeys
    local classIDs = QuestieDB.classKeys
    local factionIDs = QuestieDB.factionIDs
    local zoneIDs = ZoneDB.zoneIDs
    local sortKeys = QuestieDB.sortKeys
    local profKeys = QuestieProfessions.professionKeys
    local specialFlags = QuestieDB.specialFlags
    local questFlags = QuestieDB.questFlags

    return {
        [55] = { -- Morbent Fel
            [questKeys.objectives] = {{{1200}}},
        },
        [75] = { -- The Legend of Stalvan
            [questKeys.specialFlags] = specialFlags.NONE,
        },
        [105] = { -- Alas, Andorhal
            [questKeys.reputationReward] = {{factionIDs.HORDE,350},{factionIDs.ARGENT_DAWN,700}},
        },
        [171] = { -- A Warden of the Alliance
            [questKeys.startedBy] = {{14305}},
            [questKeys.questLevel] = -1,
            [questKeys.zoneOrSort] = sortKeys.SPECIAL,
        },
        [172] = { -- Children's Week
            [questKeys.questLevel] = -1,
            [questKeys.zoneOrSort] = sortKeys.SPECIAL,
        },
        [236] = { -- Fueling the Demolishers
            [questKeys.finishedBy] = {{31108}},
            [questKeys.exclusiveTo] = {13153,13154,13156,13195,13196,13197,13198},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [254] = { -- Digging Through the Dirt
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [403] = { -- Guarded Thunderbrew Barrel
            [questKeys.startedBy] = {nil,{269}},
        },
        [434] = { -- The Attack!
            [questKeys.triggerEnd] = {"Overhear Lescovar and Marzon's Conversation", {[zoneIDs.STORMWIND_CITY]={{72.22,35.37}}}},
        },
        [508] = { -- Taretha's Gift
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [558] = { -- Jaina's Autograph
            [questKeys.questLevel] = -1,
            [questKeys.parentQuest] = 0,
            [questKeys.zoneOrSort] = sortKeys.SPECIAL,
        },
        [648] = { -- Rescue OOX-17/TN!
            [questKeys.triggerEnd] = {"Escort OOX-17/TN to safety", {[zoneIDs.TANARIS]={{61,53}}}},
        },
        [768] = { -- Gathering Leather
            [questKeys.requiredSkill] = {393,1},
        },
        [792] = { -- Vile Familiars
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [836] = { -- Rescue OOX-09/HL!
            [questKeys.triggerEnd] = {"Escort OOX-09/HL to safety", {[zoneIDs.THE_HINTERLANDS]={{57.81,50.2}}}},
        },
        [910] = { -- Down at the Docks
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.SPECIAL,
        },
        [911] = { -- Gateway to the Frontier
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.SPECIAL,
        },
        [915] = { -- You Scream, I Scream...
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.SPECIAL,
        },
        [925] = { -- Cairne's Hoofprint
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.SPECIAL,
        },
        [974] = { -- Finding the Source
            [questKeys.requiredSourceItems] = {},
        },
        [1056] = { -- Journey to Stonetalon Peak
            [questKeys.nextQuestInChain] = 1057,
        },
        [1132] = { -- Fiora Longears
            [questKeys.startedBy] = {{4455}},
            [questKeys.finishedBy] = {{4456}},
        },
        [1135] = { -- Highperch Venom
            [questKeys.startedBy] = {{4456}},
            [questKeys.finishedBy] = {{4456}},
        },
        [1198] = { -- In Search of Thaelrid
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [1252] = { -- Lieutenant Paval Reethe
            [questKeys.preQuestSingle] = {11123},
        },
        [1253] = { -- The Black Shield
            [questKeys.preQuestSingle] = {11123},
        },
        [1284] = { -- Suspicious Hoofprints
            [questKeys.preQuestSingle] = {11123},
        },
        [1361] = { -- Regthar Deathgate
            [questKeys.startedBy] = {{2229,4485,10540}},
        },
        [1468] = { -- Children's Week
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.SPECIAL,
        },
        [1479] = { -- The Bough of the Eternals
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.SPECIAL,
        },
        [1558] = { -- The Stonewrought Dam
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.SPECIAL,
        },
        [1681] = { -- Ironband's Compound
            [questKeys.nextQuestInChain] = 1682,
        },
        [1687] = { -- Spooky Lighthouse
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.SPECIAL,
        },
        [1698] = { -- Yorus Barleybrew
            [questKeys.startedBy] = {{5479,7315}},
        },
        [1712] = { -- Cyclonian
            [questKeys.requiredSourceItems] = {4480,4479,4481},
        },
        [1716] = { -- Devourer of Souls
            [questKeys.preQuestSingle] = {},
        },
        [1782] = { -- Furen's Armor
            [questKeys.requiredClasses] = classIDs.WARRIOR,
        },
        [1795] = { -- The Binding
            [questKeys.requiredSourceItems] = {},
        },
        [1800] = { -- Lordaeron Throne Room
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.SPECIAL,
        },
        [1885] = { -- Mennet Carkad
            [questKeys.nextQuestInChain] = 14420,
            [questKeys.breadcrumbForQuestId] = 14420,
        },
        [2204] = { -- Restoring the Necklace
            [questKeys.startedBy] = {nil,{112877}},
        },
        [2279] = { -- The Platinum Discs
            [questKeys.preQuestSingle] = {2278},
        },
        [2701] = { -- Heroes of Old
            [questKeys.finishedBy] = {nil,{141980}},
        },
        [2767] = { -- Rescue OOX-22/FE!
            [questKeys.triggerEnd] = {"Escort OOX-22/FE to safety", {[zoneIDs.FERALAS]={{55.63,51.35}}}},
        },
        [2879] = { -- The Stave of Equinex
            [questKeys.requiredSourceItems] = {9255,9256,9257,9258},
        },
        [2986] = { -- Call of Water
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [3161] = { -- Gahz'ridian
            [questKeys.requiredSourceItems] = {},
        },
        [3641] = { -- Show Your Work
            [questKeys.preQuestSingle] = {},
        },
        [3763] = { -- Assisting Arch Druid Staghelm
            [questKeys.startedBy] = {{6735}},
            [questKeys.exclusiveTo] = {3789,3790},
        },
        [3789] = { -- Assisting Arch Druid Staghelm
            [questKeys.startedBy] = {{6740}},
            [questKeys.exclusiveTo] = {3763,3790},
        },
        [3790] = { -- Assisting Arch Druid Staghelm
            [questKeys.startedBy] = {{5111}},
            [questKeys.exclusiveTo] = {3763,3789},
        },
        [4144] = { -- Bloodpetal Sprouts
            [questKeys.specialFlags] = specialFlags.NONE,
        },
        [4362] = { -- The Fate of the Kingdom
            [questKeys.preQuestSingle] = {4361},
        },
        [4363] = { -- The Princess's Surprise
            [questKeys.preQuestSingle] = {4362},
        },
        [4485] = { -- The Tome of Nobility
            [questKeys.startedBy] = {{6179}},
        },
        [4486] = { -- The Tome of Nobility
            [questKeys.startedBy] = {{5149}},
        },
        [4491] = { -- A Little Help From My Friends
            [questKeys.requiredSourceItems] = {},
        },
        [4740] = { -- WANTED: Murkdeep!
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [4763] = { -- The Blackwood Corrupted
            [questKeys.objectives] = {nil,nil,{{12355}}},
        },
        [4771] = { -- Dawn's Gambit
            [questKeys.preQuestSingle] = {5522},
        },
        [4822] = { -- You Scream, I Scream...
            [questKeys.questLevel] = -1,
            [questKeys.parentQuest] = 0,
            [questKeys.zoneOrSort] = sortKeys.SPECIAL,
        },
        [5057] = { -- Past Endeavors
            [questKeys.requiredRaces] = raceIDs.NONE,
        },
        [5305] = { -- Sweet Serenity
            [questKeys.requiredSpecialization] = 0,
        },
        [5306] = { -- Snakestone of the Shadow Huntress
            [questKeys.requiredSpecialization] = 0,
        },
        [5307] = { -- Corruption
            [questKeys.requiredSpecialization] = 0,
        },
        [5502] = { -- A Warden of the Horde
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.SPECIAL,
            [questKeys.preQuestGroup] = {915,925},
        },
        [5505] = { -- The Key to Scholomance
            [questKeys.startedBy] = {{11056}},
            [questKeys.finishedBy] = {{11056}},
        },
        [5531] = { -- Betina Bigglezink
            [questKeys.nextQuestInChain] = 0,
        },
        [5641] = { -- Fear Ward
            [questKeys.startedBy] = {},
        },
        [5642] = { -- Shadowguard
            [questKeys.startedBy] = {},
        },
        [5643] = { -- Shadowguard
            [questKeys.startedBy] = {},
        },
        [5644] = { -- Devouring Plague
            [questKeys.startedBy] = {},
        },
        [5645] = { -- Fear Ward
            [questKeys.startedBy] = {},
        },
        [5646] = { -- Devouring Plague
            [questKeys.startedBy] = {},
        },
        [5652] = { -- Hex of Weakness
            [questKeys.startedBy] = {},
        },
        [5654] = { -- Hex of Weakness
            [questKeys.startedBy] = {},
        },
        [5655] = { -- Hex of Weakness
            [questKeys.startedBy] = {},
        },
        [5656] = { -- Hex of Weakness
            [questKeys.startedBy] = {},
        },
        [5657] = { -- Hex of Weakness
            [questKeys.startedBy] = {},
        },
        [5658] = { -- Touch of Weakness
            [questKeys.startedBy] = {},
        },
        [5661] = { -- Touch of Weakness
            [questKeys.startedBy] = {},
        },
        [5663] = { -- Touch of Weakness
            [questKeys.startedBy] = {},
        },
        [5676] = { -- Feedback
            [questKeys.startedBy] = {},
        },
        [5679] = { -- Devouring Plague
            [questKeys.startedBy] = {},
        },
        [5680] = { -- Shadowguard
            [questKeys.startedBy] = {},
        },
        [5721] = { -- The Battle of Darrowshire
            [questKeys.extraObjectives] = {{{[zoneIDs.EASTERN_PLAGUELANDS]={{35.01,84.05}}}, Questie.ICON_TYPE_EVENT, l10n("Place the Relic Bundle in the Town Square."),}},
        },
        [6070] = { -- The Hunter's Path
            [questKeys.finishedBy] = {{3171}},
        },
        [6185] = { -- The Eastern Plagues
            [questKeys.triggerEnd] = {"The Blightcaller Uncovered", {[zoneIDs.EASTERN_PLAGUELANDS]={{23.4,67.8}}}},
        },
        [6521] = { -- An Unholy Alliance
            [questKeys.startedBy] = {{36273}},
            [questKeys.finishedBy] = {{36273}},
        },
        [6522] = { -- An Unholy Alliance
            [questKeys.finishedBy] = {{36273}},
        },
        [6622] = { -- Triage
            [questKeys.requiredSourceItems] = {},
        },
        [6624] = { -- Triage
            [questKeys.requiredSourceItems] = {},
        },
        [6963] = { -- Stolen Winter Veil Treats
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [7023] = { -- Greatfather Winter is Here!
            [questKeys.startedBy] = {{13435,23010}},
        },
        [7042] = { -- Stolen Winter Veil Treats
            [questKeys.startedBy] = {{13433}},
        },
        [7490] = { -- Victory for the Horde
            [questKeys.preQuestSingle] = {},
        },
        [7495] = { -- Victory for the Alliance
            [questKeys.preQuestSingle] = {},
        },
        [7641] = { -- The Work of Grimand Elmore
            [questKeys.preQuestSingle] = {7638,7670},
        },
        [7643] = { -- Ancient Equine Spirit
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {7642,7648},
        },
        [7704] = { -- Look at the Size of It!
            [questKeys.startedBy] = {nil,nil,{18950}},
        },
        [7781] = { -- The Lord of Blackrock
            [questKeys.preQuestSingle] = {},
        },
        [7783] = { -- The Lord of Blackrock
            [questKeys.preQuestSingle] = {},
        },
        [7838] = { -- Arena Grandmaster
            [questKeys.requiredLevel] = 1,
        },
        [8149] = { -- Honoring a Hero
            [questKeys.objectives] = {nil,{{1323}}},
            [questKeys.extraObjectives] = {},
        },
        [8150] = { -- Honoring a Hero
            [questKeys.objectives] = {nil,{{1324}}},
            [questKeys.extraObjectives] = {},
        },
        [8166] = { -- The Battle for Arathi Basin!
            [questKeys.requiredMaxLevel] = 49,
        },
        [8167] = { -- The Battle for Arathi Basin!
            [questKeys.requiredMaxLevel] = 39,
        },
        [8168] = { -- The Battle for Arathi Basin!
            [questKeys.requiredMaxLevel] = 29,
        },
        [8169] = { -- The Battle for Arathi Basin!
            [questKeys.requiredMaxLevel] = 49,
        },
        [8170] = { -- The Battle for Arathi Basin!
            [questKeys.requiredMaxLevel] = 39,
        },
        [8171] = { -- The Battle for Arathi Basin!
            [questKeys.requiredMaxLevel] = 29,
        },
        [8346] = { -- Thirst Unending
            [questKeys.objectives] = {nil,nil,nil,nil,{{{15274},15274,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [8551] = { -- The Captain's Chest
            [questKeys.requiredRaces] = raceIDs.NONE,
        },
        [8552] = { -- The Monogrammed Sash
            [questKeys.specialFlags] = specialFlags.NONE,
        },
        [8579] = { -- Mortal Champions
            [questKeys.startedBy] = {{15503}},
            [questKeys.finishedBy] = {{15503}},
        },
        [8746] = { -- Metzen the Reindeer
            [questKeys.objectives] = {{{15664,nil,Questie.ICON_TYPE_EVENT}},nil,{{21211}}},
        },
        [8762] = { -- Metzen the Reindeer
            [questKeys.objectives] = {{{15664,nil,Questie.ICON_TYPE_EVENT}},nil,{{21211}}},
        },
        [8764] = { -- The Changing of Paths - Protector No More
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [8765] = { -- The Changing of Paths - Invoker No More
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [8766] = { -- The Changing of Paths - Conqueror No More
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [8767] = { -- A Gently Shaken Gift
            [questKeys.requiredClasses] = classIDs.ROGUE + classIDs.WARRIOR + classIDs.HUNTER + classIDs.PALADIN + classIDs.DEATH_KNIGHT,
        },
        [8867] = { -- Lunar Fireworks
            [questKeys.questLevel] = -1,
        },
        [8870] = { -- The Lunar Festival
            [questKeys.questLevel] = -1,
        },
        [8871] = { -- The Lunar Festival
            [questKeys.questLevel] = -1,
        },
        [8872] = { -- The Lunar Festival
            [questKeys.questLevel] = -1,
        },
        [8873] = { -- The Lunar Festival
            [questKeys.questLevel] = -1,
        },
        [8874] = { -- The Lunar Festival
            [questKeys.questLevel] = -1,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [8875] = { -- The Lunar Festival
            [questKeys.questLevel] = -1,
        },
        [8883] = { -- Valadar Starsong
            [questKeys.questLevel] = -1,
        },
        [8888] = { -- The Magister's Apprentice
            [questKeys.exclusiveTo] = {8889},
        },
        [9078] = { -- Bonescythe Legplates
            [questKeys.requiredClasses] = classIDs.ROGUE,
        },
        [9121] = { -- The Dread Citadel - Naxxramas
            [questKeys.reputationReward] = {{factionIDs.ARGENT_DAWN,1000}},
        },
        [9122] = { -- The Dread Citadel - Naxxramas
            [questKeys.reputationReward] = {{factionIDs.ARGENT_DAWN,1000}},
        },
        [9154] = { -- Light's Hope Chapel
            [questKeys.startedBy] = {{16241,16255}},
            [questKeys.finishedBy] = {{16281}},
            [questKeys.questLevel] = -1,
        },
        [9189] = { -- Delivery to the Sepulcher
            [questKeys.requiredRaces] = raceIDs.BLOOD_ELF,
        },
        [9211] = { -- The Ice Guard
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9213] = { -- The Shadow Guard
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9221] = { -- Superior Armaments of Battle - Friend of the Dawn
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9222] = { -- Epic Armaments of Battle - Friend of the Dawn
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9223] = { -- Superior Armaments of Battle - Honored Amongst the Dawn
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9224] = { -- Epic Armaments of Battle - Honored Amongst the Dawn
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9225] = { -- Epic Armaments of Battle - Revered Amongst the Dawn
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9226] = { -- Superior Armaments of Battle - Revered Amongst the Dawn
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9227] = { -- Superior Armaments of Battle - Exalted Amongst the Dawn
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9228] = { -- Epic Armaments of Battle - Exalted Amongst the Dawn
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [9247] = { -- The Keeper's Call
            [questKeys.finishedBy] = {{16281}},
        },
        [9358] = { -- Ranger Sareyn
            [questKeys.nextQuestInChain] = 9252,
        },
        [9361] = { -- Helboar, the Other White Meat
            [questKeys.requiredSourceItems] = {23270},
        },
        [9425] = { -- Report to Tarren Mill
            [questKeys.requiredRaces] = raceIDs.BLOOD_ELF,
        },
        [9460] = { -- Combining Forces
            [questKeys.requiredRaces] = raceIDs.BLOOD_ELF,
        },
        [9461] = { -- Call of Fire
            [questKeys.requiredRaces] = raceIDs.DRAENEI,
        },
        [9491] = { -- Greed
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [9502] = { -- Call of Water
            [questKeys.requiredRaces] = raceIDs.DRAENEI,
        },
        [9532] = { -- Find Keltus Darkleaf
            [questKeys.requiredRaces] = raceIDs.BLOOD_ELF,
        },
        [9582] = { -- Strength of One
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [9618] = { -- Return the Reports
            [questKeys.requiredRaces] = raceIDs.BLOOD_ELF,
        },
        [9644] = { -- Nightbane
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Summon Nightbane"), 0, {{"object", 194092}}}},
        },
        [9645] = { -- The Master's Terrace
            [questKeys.triggerEnd] = {"Journal Entry Read", {[zoneIDs.KARAZHAN]={{-1,-1}}}},
        },
        [9681] = { -- A Study in Power
            [questKeys.startedBy] = {{17717,17718}},
        },
        [9737] = { -- True Masters of the Light
            [questKeys.startedBy] = {{25223}}, -- TBC p1/p2 offered by 17076
            [questKeys.finishedBy] = {{25223}}, -- TBC p1/p2 finished by 17076
        },
        [9876] = { -- Failed Incursion
            [questKeys.nextQuestInChain] = 9738,
        },
        [10106] = { -- Hellfire Fortifications
            [questKeys.preQuestSingle] = {13408,13410},
        },
        [10110] = { -- Hellfire Fortifications
            [questKeys.preQuestSingle] = {13409,13411},
        },
        [10137] = { -- Provoking the Warboss
            [questKeys.requiredSourceItems] = {},
        },
        [10155] = { -- Provoking the Warboss
            [questKeys.requiredSourceItems] = {},
        },
        [10173] = { -- The Archmage's Staff
            [questKeys.requiredSourceItems] = {},
        },
        [10180] = { -- Can't Stay Away
            [questKeys.nextQuestInChain] = 10097,
        },
        [10445] = { -- The Vials of Eternity
            [questKeys.startedBy] = {},
            [questKeys.exclusiveTo] = {13432},
        },
        [10460] = { -- Defender's Pledge
            [questKeys.preQuestSingle] = {10445,13432},
        },
        [10461] = { -- Restorer's Pledge
            [questKeys.preQuestSingle] = {10445,13432},
        },
        [10462] = { -- Champion's Pledge
            [questKeys.preQuestSingle] = {10445,13432},
        },
        [10463] = { -- Sage's Pledge
            [questKeys.preQuestSingle] = {10445,13432},
        },
        [10464] = { -- Sage's Vow
            [questKeys.objectives] = {nil,nil,nil,{990,9000}},
        },
        [10465] = { -- Restorer's Vow
            [questKeys.objectives] = {nil,nil,nil,{990,9000}},
        },
        [10466] = { -- Champion's Vow
            [questKeys.objectives] = {nil,nil,nil,{990,9000}},
        },
        [10467] = { -- Defender's Vow
            [questKeys.objectives] = {nil,nil,nil,{990,9000}},
        },
        [10468] = { -- Sage's Oath
            [questKeys.objectives] = {nil,nil,nil,{990,21000}},
        },
        [10469] = { -- Restorer's Oath
            [questKeys.objectives] = {nil,nil,nil,{990,21000}},
        },
        [10470] = { -- Champion's Oath
            [questKeys.objectives] = {nil,nil,nil,{990,21000}},
        },
        [10471] = { -- Defender's Oath
            [questKeys.objectives] = {nil,nil,nil,{990,21000}},
        },
        [10472] = { -- Sage's Covenant
            [questKeys.objectives] = {nil,nil,nil,{990,42000}},
        },
        [10473] = { -- Restorer's Covenant
            [questKeys.objectives] = {nil,nil,nil,{990,42000}},
        },
        [10474] = { -- Champion's Covenant
            [questKeys.objectives] = {nil,nil,nil,{990,42000}},
        },
        [10475] = { -- Defender's Covenant
            [questKeys.objectives] = {nil,nil,nil,{990,42000}},
        },
        [10548] = { -- The Sad Truth
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [10651] = { -- Varedis Must Be Stopped
            [questKeys.requiredSourceItems] = {},
        },
        [10667] = { -- Underworld Loam
            [questKeys.preQuestSingle] = {},
        },
        [10670] = { -- Tear of the Earthmother
            [questKeys.preQuestSingle] = {},
        },
        [10702] = { -- A Grunt's Work...
            [questKeys.objectives] = {nil,nil,nil,nil,{{{21864,21878,21879,23020,21978},21978}}},
        },
        [10703] = { -- Put On Yer Kneepads...
            [questKeys.objectives] = {nil,nil,nil,nil,{{{21864,21878,21879,23020,21978},21978}}},
        },
        [10725] = { -- Eminence Among the Violet Eye
            [questKeys.objectives] = {nil,nil,nil,{967,42000}},
        },
        [10726] = { -- Eminence Among the Violet Eye
            [questKeys.objectives] = {nil,nil,nil,{967,42000}},
        },
        [10727] = { -- Eminence Among the Violet Eye
            [questKeys.objectives] = {nil,nil,nil,{967,42000}},
        },
        [10728] = { -- Eminence Among the Violet Eye
            [questKeys.objectives] = {nil,nil,nil,{967,42000}},
        },
        [10729] = { -- Path of the Violet Mage
            [questKeys.nextQuestInChain] = 10733,
        },
        [10730] = { -- Path of the Violet Restorer
            [questKeys.nextQuestInChain] = 10734,
        },
        [10731] = { -- Path of the Violet Assassin
            [questKeys.nextQuestInChain] = 10735,
        },
        [10732] = { -- Path of the Violet Protector
            [questKeys.nextQuestInChain] = 10736,
        },
        [10769] = { -- Dissension Amongst the Ranks...
            [questKeys.objectives] = {{{19823}},nil,{{31108}}},
        },
        [10776] = { -- Dissension Amongst the Ranks...
            [questKeys.objectives] = {{{19823}},nil,{{31310}}},
        },
        [10842] = { -- Vengeful Souls
            [questKeys.objectives] = {{{21636}}},
        },
        [10888] = { -- Trial of the Naaru: Magtheridon
            [questKeys.exclusiveTo] = {13430},
        },
        [10900] = { -- The Mark of Vashj
            [questKeys.nextQuestInChain] = 13431,
        },
        [10901] = { -- The Cudgel of Kar'desh
            [questKeys.exclusiveTo] = {13431},
        },
        [10946] = { -- Ruse of the Ashtongue
            [questKeys.requiredSourceItems] = {},
        },
        [10958] = { -- Seek Out the Ashtongue
            [questKeys.preQuestSingle] = {10949},
        },
        [10985] = { -- A Distraction for Akama
            [questKeys.exclusiveTo] = {13429},
        },
        [11009] = { -- Ogre Heaven
            [questKeys.breadcrumbForQuestId] = 11025,
            [questKeys.nextQuestInChain] = 11025,
        },
        [11010] = { -- Bombing Run
            [questKeys.requiredClasses] = classIDs.WARLOCK + classIDs.ROGUE + classIDs.MAGE + classIDs.PRIEST + classIDs.WARRIOR + classIDs.PALADIN + classIDs.HUNTER + classIDs.SHAMAN + classIDs.DEATH_KNIGHT,
        },
        [11025] = { -- The Crystals
            [questKeys.preQuestSingle] = {11000},
            [questKeys.breadcrumbs] = {11009},
        },
        [11026] = { -- Banish the Demons
            [questKeys.preQuestSingle] = {11009},
        },
        [11117] = { -- Catch the Wild Wolpertinger!
            [questKeys.startedBy] = {{23486}},
            [questKeys.finishedBy] = {{23486}},
        },
        [11118] = { -- Pink Elekks On Parade
            [questKeys.startedBy] = {{23486}},
            [questKeys.finishedBy] = {{23486}},
        },
        [11120] = { -- Pink Elekks On Parade
            [questKeys.startedBy] = {{24657}},
            [questKeys.finishedBy] = {{24657}},
        },
        [11122] = { -- There and Back Again
            [questKeys.objectives] = {{{24468,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Grab a keg"), 0, {{"monster", 24364}}}},
        },
        [11137] = { -- Defias in Dustwallow?
            [questKeys.preQuestSingle] = {},
        },
        [11152] = { -- Peace at Last
            [questKeys.requiredSourceItems] = {},
        },
        [11153] = { -- Break the Blockade
            [questKeys.extraObjectives] = {{{[zoneIDs.HOWLING_FJORD]={{28.1,42.2}}}, Questie.ICON_TYPE_EVENT, l10n("Wait for Harrowmeiser's zeppelin to dock"),}},
            [questKeys.requiredSourceItems] = {},
        },
        [11154] = { -- Scare the Guano Out of Them!
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Throw the firecrackers up to 20 yards away underneath a darkclaw bat to scare it"), 0, {{"monster", 23959}}}},
            [questKeys.requiredSourceItems] = {},
        },
        [11157] = { -- The Clutches of Evil
            [questKeys.objectives] = {{{23777,nil,Questie.ICON_TYPE_INTERACT}},nil,nil,nil,{{{23688,23750},23688}}},
        },
        [11170] = { -- Test at Sea
            [questKeys.objectives] = {{{24120,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Talk to Bat Handler Camille"), 0, {{"monster", 23816}}}},
            [questKeys.requiredSourceItems] = {},
        },
        [11175] = { -- My Daughter
            [questKeys.exclusiveTo] = {11176},
        },
        [11188] = { -- Two Wrongs...
            [questKeys.requiredSourceItems] = {},
        },
        [11202] = { -- Mission: Eternal Flame
            [questKeys.requiredSourceItems] = {},
        },
        [11218] = { -- Danger! Explosives!
            [questKeys.requiredSourceItems] = {},
        },
        [11227] = { -- Let Them Eat Crow
            [questKeys.requiredSourceItems] = {33238},
        },
        [11232] = { -- Guide Our Sights
            [questKeys.requiredSourceItems] = {},
        },
        [11238] = { -- The Frost Wyrm and its Master
            [questKeys.sourceItemId] = 33282,
        },
        [11241] = { -- Trail of Fire
            [questKeys.triggerEnd] = {"Rescue Apothecary Hanes",{[zoneIDs.HOWLING_FJORD]={{78.72,37.23}}}},
        },
        [11245] = { -- Towers of Certain Doom
            [questKeys.requiredSourceItems] = {33311},
        },
        [11246] = { -- Gruesome, But Necessary
            [questKeys.objectives] = {nil,nil,nil,nil,{{{23661,23662,23663,23664,23665,23666,23667,23668,23669,23670},23661,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.requiredSourceItems] = {33311},
        },
        [11247] = { -- Burn Skorn, Burn!
            [questKeys.requiredSourceItems] = {33311},
        },
        [11249] = { -- Stop the Ascension!
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Present the Vrykul Scroll of Ascension"), 0, {{"object", 186586}}}},
        },
        [11252] = { -- Into Utgarde!
            [questKeys.preQuestSingle] = {},
        },
        [11253] = { -- Sniff Out the Enemy
            [questKeys.requiredSourceItems] = {},
        },
        [11257] = { -- Gruesome, But Necessary
            [questKeys.objectives] = {nil,nil,nil,nil,{{{23661,23662,23663,23664,23665,23666,23667,23668,23669,23670},23661,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.requiredSourceItems] = {33340},
        },
        [11258] = { -- Burn Skorn, Burn!
            [questKeys.requiredSourceItems] = {33340},
        },
        [11259] = { -- Towers of Certain Doom
            [questKeys.requiredSourceItems] = {33340},
        },
        [11260] = { -- Stop the Ascension!
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Present the Vrykul Scroll of Ascension"), 0, {{"object", 186586}}}},
        },
        [11267] = { -- The Frost Wyrm and its Master
            [questKeys.sourceItemId] = 33282,
        },
        [11270] = { -- War is Hell
            [questKeys.requiredSourceItems] = {},
        },
        [11279] = { -- Green Eggs and Whelps
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Spray Proto-Drake Egg"), 0, {{"monster", 23777}}}},
            [questKeys.requiredSourceItems] = {},
        },
        [11280] = { -- Draconis Gastritis
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Place Tillinghast's Plagued Meat on the ground"), 0, {{"monster", 24170}}}},
            [questKeys.requiredSourceItems] = {},
        },
        [11281] = { -- Mimicking Nature's Call
            [questKeys.objectives] = {{{24173}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use the Carved Horn"), 0, {{"object", 186599}}}},
            [questKeys.requiredSourceItems] = {},
        },
        [11282] = { -- A Lesson in Fear
            [questKeys.objectives] = {{{24161,nil,Questie.ICON_TYPE_INTERACT},{24016,nil,Questie.ICON_TYPE_INTERACT},{24162,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_SLAY, l10n("Slay Vrykul across the Forsaken blockade until they appear"), 0, {{"monster", 24015}}}},
            [questKeys.requiredSourceItems] = {},
        },
        [11285] = { -- Baleheim Must Burn!
            [questKeys.requiredSourceItems] = {},
        },
        [11286] = { -- The Artifacts of Steel Gate
            [questKeys.preQuestSingle] = {},
        },
        [11296] = { -- Rivenwood Captives
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_SLAY, l10n("Break Riven Widow Cocoons to free captives"), 0, {{"monster", 24210}}}},
        },
        [11297] = { -- Keeping Watch on the Interlopers
            [questKeys.nextQuestInChain] = 11298,
        },
        [11298] = { -- What's in That Brew?
            [questKeys.preQuestSingle] = {},
        },
        [11300] = { -- Stunning Defeat at the Ring
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_SLAY, l10n("Kill gladiators at the Ring of Judgement until Oluf the Violent appears"), 0, {{"monster", 24213},{"monster", 24214},{"monster", 24215}}},
                {nil, Questie.ICON_TYPE_SLAY, l10n("Kill Oluf the Violent"), 0, {{"monster", 23931}}},
            },
        },
        [11301] = { -- Brains! Brains! Brains!
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_LOOT, l10n("Use Grick's Bonesaw on corpses of Deranged Explorers"), 0, {{"monster", 23967}}}},
            [questKeys.requiredSourceItems] = {},
        },
        [11302] = { -- The Enigmatic Frost Nymphs
            [questKeys.preQuestSingle] = {11284},
        },
        [11306] = { -- Apply Heat and Stir
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_OBJECT, l10n("Fill the Empty Apothecary's Flask at the Cauldron of Vrykul Blood"),0,{{"object", 186656}}},
                {nil, Questie.ICON_TYPE_OBJECT, l10n("Mix the Flask of Vrykul Blood with Harris's Plague Samples"),1,{{"object", 186657}}},
            },
        },
        [11307] = { -- Field Test
            [questKeys.objectives] = {nil,nil,nil,nil,{{{23564,24198,24199},23564,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.requiredSourceItems] = {},
        },
        [11310] = { -- Warning: Some Assembly Required
            [questKeys.objectives] = {nil,nil,nil,nil,{{{23564,24198,24199},23564,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.requiredSourceItems] = {},
        },
        [11314] = { -- The Fallen Sisters
            [questKeys.objectives] = {{{23678,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.requiredSourceItems] = {},
        },
        [11317] = { -- The Cleansing
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Meditate"), 0, {{"object", 186649}}}},
        },
        [11318] = { -- Now This is Ram Racing... Almost.
            [questKeys.preQuestSingle] = {},
            [questKeys.objectives] = {{{80001,nil,Questie.ICON_TYPE_EVENT},{80002,nil,Questie.ICON_TYPE_EVENT},{80003,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [11319] = { -- Seeds of the Blacksouled Keepers
            [questKeys.objectives] = {{{23876,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.requiredSourceItems] = {},
        },
        [11322] = { -- The Cleansing
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Meditate"), 0, {{"object", 186649}}}},
        },
        [11329] = { -- I'll Try Anything!
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Search for Northern Barbfish"), 0, {{"object", 186659}}}},
        },
        [11330] = { -- Absholutely... Thish Will Work!
            [questKeys.requiredSourceItems] = {},
        },
        [11332] = { -- Mission: Plague This!
            [questKeys.sourceItemId] = 33634,
            [questKeys.preQuestSingle] = {11331},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Get a gryphon to ride and some bombs"), 0, {{"monster", 23859}}}},
        },
        [11335] = { -- Call to Arms: Arathi Basin
            [questKeys.triggerEnd] = {"Victory in Arathi Basin", {
                [zoneIDs.IRONFORGE]={{70.41,91.10}},
                [zoneIDs.SHATTRATH_CITY]={{67.41,33.86}},
                [zoneIDs.DARNASSUS]={{58.02,34.52}},
                [zoneIDs.THE_EXODAR]={{26.6,50.06}},
                [zoneIDs.STORMWIND_CITY]={{83.47,33.66}},
                [zoneIDs.DALARAN]={{29.79,75.78}},
                [zoneIDs.WINTERGRASP]={{50.02,15.16}},
                [zoneIDs.ARATHI_HIGHLANDS]={{45.6,45.8}},
            }},
            [questKeys.exclusiveTo] = {11336,11337,11338,13405,14163},
            [questKeys.questFlags] = 4226,
        },
        [11336] = { -- Call to Arms: Alterac Valley
            [questKeys.triggerEnd] = {"Victory in Alterac Valley", {
                [zoneIDs.IRONFORGE]={{70.41,91.10}},
                [zoneIDs.SHATTRATH_CITY]={{67.41,33.86}},
                [zoneIDs.DARNASSUS]={{58.02,34.52}},
                [zoneIDs.THE_EXODAR]={{26.6,50.06}},
                [zoneIDs.STORMWIND_CITY]={{83.47,33.66}},
                [zoneIDs.DALARAN]={{29.79,75.78}},
                [zoneIDs.WINTERGRASP]={{50.02,15.16}},
                [zoneIDs.ALTERAC_MOUNTAINS]={{39.4,82.2}},
            }},
            [questKeys.exclusiveTo] = {11335,11337,11338,13405,14163},
        },
        [11337] = { -- Call to Arms: Eye of the Storm
            [questKeys.triggerEnd] = {"Victory in the Eye of the Storm", {
                [zoneIDs.IRONFORGE]={{70.41,91.10}},
                [zoneIDs.SHATTRATH_CITY]={{67.41,33.86}},
                [zoneIDs.DARNASSUS]={{58.02,34.52}},
                [zoneIDs.THE_EXODAR]={{26.6,50.06}},
                [zoneIDs.STORMWIND_CITY]={{83.47,33.66}},
                [zoneIDs.DALARAN]={{29.79,75.78}},
                [zoneIDs.WINTERGRASP]={{50.02,15.16}},
            }},
            [questKeys.exclusiveTo] = {11335,11336,11338,13405,14163},
        },
        [11338] = { -- Call to Arms: Warsong Gulch
            [questKeys.triggerEnd] = {"Victory in Warsong Gulch", {
                [zoneIDs.IRONFORGE]={{70.41,91.10}},
                [zoneIDs.SHATTRATH_CITY]={{67.41,33.86}},
                [zoneIDs.DARNASSUS]={{58.02,34.52}},
                [zoneIDs.THE_EXODAR]={{26.6,50.06}},
                [zoneIDs.STORMWIND_CITY]={{83.47,33.66}},
                [zoneIDs.DALARAN]={{29.79,75.78}},
                [zoneIDs.WINTERGRASP]={{50.02,15.16}},
                [zoneIDs.ASHENVALE]={{61.8,83.8}},
            }},
            [questKeys.exclusiveTo] = {11335,11336,11337,13405,14163},
        },
        [11339] = { -- Call to Arms: Arathi Basin
            [questKeys.triggerEnd] = {"Victory in Arathi Basin", {
                [zoneIDs.ORGRIMMAR]={{80.68,30.51},{36.94,65.36}},
                [zoneIDs.THUNDER_BLUFF]={{57.8,76.4}},
                [zoneIDs.UNDERCITY]={{58.27,97.9}},
                [zoneIDs.SILVERMOON_CITY]={{97,38.3}},
                [zoneIDs.SHATTRATH_CITY]={{66.96,56.6}},
                [zoneIDs.DALARAN]={{58.19,20.59}},
                [zoneIDs.WINTERGRASP]={{50.02,15.16}},
                [zoneIDs.ARATHI_HIGHLANDS]={{73.3,30}},
            }},
            [questKeys.startedBy] = {{15350}},
            [questKeys.finishedBy] = {{15350}},
            [questKeys.exclusiveTo] = {11340,11341,11342,13407,14164},
        },
        [11340] = { -- Call to Arms: Alterac Valley
            [questKeys.triggerEnd] = {"Victory in Alterac Valley", {
                [zoneIDs.ORGRIMMAR]={{80.68,30.51},{36.94,65.36}},
                [zoneIDs.THUNDER_BLUFF]={{57.8,76.4}},
                [zoneIDs.UNDERCITY]={{58.27,97.9}},
                [zoneIDs.SILVERMOON_CITY]={{97,38.3}},
                [zoneIDs.SHATTRATH_CITY]={{66.96,56.6}},
                [zoneIDs.DALARAN]={{58.19,20.59}},
                [zoneIDs.WINTERGRASP]={{50.02,15.16}},
                [zoneIDs.ALTERAC_MOUNTAINS]={{63.3,60.2}},
            }},
            [questKeys.startedBy] = {{15350}},
            [questKeys.finishedBy] = {{15350}},
            [questKeys.exclusiveTo] = {11339,11341,11342,13407,14164},
        },
        [11341] = { -- Call to Arms: Eye of the Storm
            [questKeys.triggerEnd] = {"Victory in Eye of the Storm", {
                [zoneIDs.ORGRIMMAR]={{80.68,30.51},{36.94,65.36}},
                [zoneIDs.THUNDER_BLUFF]={{57.8,76.4}},
                [zoneIDs.UNDERCITY]={{58.27,97.9}},
                [zoneIDs.SILVERMOON_CITY]={{97,38.3}},
                [zoneIDs.SHATTRATH_CITY]={{66.96,56.6}},
                [zoneIDs.DALARAN]={{58.19,20.59}},
                [zoneIDs.WINTERGRASP]={{50.02,15.16}},
            }},
            [questKeys.startedBy] = {{15350}},
            [questKeys.finishedBy] = {{15350}},
            [questKeys.exclusiveTo] = {11339,11340,11342,13407,14164},
        },
        [11342] = { -- Call to Arms: Warsong Gulch
            [questKeys.triggerEnd] = {"Victory in Warsong Gulch", {
                [zoneIDs.ORGRIMMAR]={{80.68,30.51},{36.94,65.36}},
                [zoneIDs.THUNDER_BLUFF]={{57.8,76.4}},
                [zoneIDs.UNDERCITY]={{58.27,97.9}},
                [zoneIDs.SILVERMOON_CITY]={{97,38.3}},
                [zoneIDs.SHATTRATH_CITY]={{66.96,56.6}},
                [zoneIDs.DALARAN]={{58.19,20.59}},
                [zoneIDs.WINTERGRASP]={{50.02,15.16}},
                [zoneIDs.THE_BARRENS]={{47,9.3}},
            }},
            [questKeys.startedBy] = {{15350}},
            [questKeys.finishedBy] = {{15350}},
            [questKeys.exclusiveTo] = {11339,11340,11341,13407,14164},
        },
        [11343] = { -- The Echo of Ymiron
            [questKeys.triggerEnd] = {"Secrets of Wyrmskull Uncovered",{[zoneIDs.HOWLING_FJORD]={{60.13,50.8}}}},
            [questKeys.requiredSourceItems] = {},
        },
        [11344] = { -- Anguish of Nifflevar
            [questKeys.triggerEnd] = {"Secrets of Nifflevar Uncovered",{[zoneIDs.HOWLING_FJORD]={{69.04,54.79}}}},
            [questKeys.requiredSourceItems] = {},
        },
        [11346] = { -- The Book of Runes
            [questKeys.preQuestSingle] = {11284},
        },
        [11348] = { -- The Rune of Command
            [questKeys.objectives] = {{{23725,nil,Questie.ICON_TYPE_INTERACT},{24334}}},
            [questKeys.requiredSourceItems] = {},
        },
        [11352] = { -- The Rune of Command
            [questKeys.objectives] = {{{23725,nil,Questie.ICON_TYPE_INTERACT},{24334}}},
            [questKeys.requiredSourceItems] = {},
        },
        [11355] = { -- March of the Giants
            [questKeys.preQuestSingle] = {11284},
            [questKeys.objectives] = {{{23725,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.requiredSourceItems] = {},
        },
        [11358] = { -- The Lodestone
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use Rune Sample"), 0, {{"object", 186718},}}},
            [questKeys.requiredSourceItems] = {},
        },
        [11365] = { -- March of the Giants
            [questKeys.objectives] = {{{23725,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.requiredSourceItems] = {},
        },
        [11366] = { -- The Lodestone
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use Rune Sample"), 0, {{"object", 186718},}}},
            [questKeys.requiredSourceItems] = {},
        },
        [11372] = { -- Wanted: The Headfeathers of Ikiss
            [questKeys.zoneOrSort] = zoneIDs.AUCHINDOUN_DUNGEONS,
        },
        [11373] = { -- Wanted: Shaffar's Wondrous Pendant
            [questKeys.zoneOrSort] = zoneIDs.AUCHINDOUN_DUNGEONS,
        },
        [11374] = { -- Wanted: The Exarch's Soul Gem
            [questKeys.zoneOrSort] = zoneIDs.AUCHINDOUN_DUNGEONS,
        },
        [11375] = { -- Wanted: Murmur's Whisper
            [questKeys.zoneOrSort] = zoneIDs.AUCHINDOUN_DUNGEONS,
        },
        [11376] = { -- Wanted: Malicious Instructors
            [questKeys.zoneOrSort] = zoneIDs.AUCHINDOUN_DUNGEONS,
        },
        [11390] = { -- I've Got a Flying Machine!
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_MOUNT_UP, l10n("Mount up"), 0, {{"monster", 24418},}}},
        },
        [11391] = { -- Steel Gate Patrol
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_MOUNT_UP, l10n("Mount up"), 0, {{"monster", 24418},}}},
        },
        [11393] = { -- Where is Explorer Jaren?
            [questKeys.exclusiveTo] = {11394,},
        },
        [11394] = { -- And You Thought Murlocs Smelled Bad!
            [questKeys.preQuestSingle] = {},
        },
        [11396] = { -- Bring Down Those Shields
            [questKeys.requiredSourceItems] = {},
        },
        [11399] = { -- Bring Down Those Shields
            [questKeys.requiredSourceItems] = {},
        },
        [11409] = { -- Now This is Ram Racing... Almost.
            [questKeys.preQuestSingle] = {},
            [questKeys.objectives] = {{{80004,nil,Questie.ICON_TYPE_EVENT},{80005,nil,Questie.ICON_TYPE_EVENT},{80006,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [11410] = { -- The One That Got Away
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use Fresh Barbfish Bait"), 0, {{"object", 186770},}}},
            [questKeys.requiredSourceItems] = {},
        },
        [11412] = { -- There and Back Again
            [questKeys.objectives] = {{{24510,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Grab a keg"), 0, {{"monster", 24527}}}},
        },
        [11414] = { -- Brother Betrayers
            [questKeys.sourceItemId] = 33618,
        },
        [11415] = { -- Brother Betrayers
            [questKeys.sourceItemId] = 33618,
        },
        [11416] = { -- Eyes of the Eagle
            [questKeys.requiredSourceItems] = {33618},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Touch Talonshrike's Egg"), 0, {{"object", 186814},{"object", 190283},{"object", 190284}}}},
        },
        [11417] = { -- Eyes of the Eagle
            [questKeys.requiredSourceItems] = {33618},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Touch Talonshrike's Egg"), 0, {{"object", 186814},{"object", 190283},{"object", 190284}}}},
        },
        [11418] = { -- We Call Him Steelfeather
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use Feathered Charm on Steelfeather"), 0, {{"monster", 24514},}}},
            [questKeys.requiredSourceItems] = {},
        },
        [11420] = { -- The Path to Payback
            [questKeys.extraObjectives] = {{{[zoneIDs.HOWLING_FJORD]={{56.6,49.1}}}, Questie.ICON_TYPE_EVENT, l10n("Entrance to Utgarde Catacombs"),}},
        },
        [11421] = { -- It Goes to 11...
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Commandeer Crykul Harpoon Gun"),0,{{"object",190512}}}},
        },
        [11428] = { -- Keeper Witherleaf
            [questKeys.preQuestSingle] = {11316},
            [questKeys.preQuestGroup] = {},
        },
        [11429] = { -- Drop It then Rock It!
            [questKeys.objectives] = {nil,{{186863}},nil,nil,{{{24640},24640,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [11431] = { -- Catch the Wild Wolpertinger!
            [questKeys.startedBy] = {{24657}},
            [questKeys.finishedBy] = {{24657}},
        },
        [11436] = { -- Let's Go Surfing Now
            [questKeys.triggerEnd] = {"Go Harpoon Surfing",{[zoneIDs.HOWLING_FJORD]={{60.08,62.06}}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Go Harpoon Surfing"),0,{{"object",186894}}}},
        },
        [11443] = { -- Daggercap Divin'
            [questKeys.requiredSourceItems] = {},
        },
        [11448] = { -- The Explorers' League Outpost
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Ask McGoyver for a ride to the Explorers' League Outpost"),0,{{"monster",24040}}}},
        },
        [11451] = { -- Alicia's Poem
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [11452] = { -- The Slumbering King
            [questKeys.startedBy] = {nil,nil,{34090}},
            [questKeys.requiredSourceItems] = {},
        },
        [11453] = { -- The Slumbering King
            [questKeys.startedBy] = {nil,nil,{34091}},
            [questKeys.requiredSourceItems] = {},
        },
        [11458] = { -- Avenge Iskaal
            [questKeys.requiredSourceItems] = {},
        },
        [11460] = { -- Trust is Earned
            [questKeys.objectives] = {{{24752,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [11465] = { -- The Ransacked Caravan
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_LOOT, l10n("Send your Trained Rock Falcon after it"), 0, {{"monster", 24746}}}},
        },
        [11466] = { -- Jack Likes His Drink
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Talk to Olga"), 0, {{"monster", 24639}}}},
        },
        [11467] = { -- Dead Man's Debt
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_LOOT, l10n("Search for treasure"), 0, {{"object", 186944}}}},
        },
        [11468] = { -- Falcon Versus Hawk
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_LOOT, l10n("Send your Trained Rock Falcon after it"), 0, {{"monster", 24747}}}},
        },
        [11470] = { -- There Exists No Honor Among Birds
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Release the Trained Rock Falcon"), 0, {{"object", 190222}}}},
        },
        [11471] = { -- The Jig is Up
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_SLAY, l10n("Fight Jonah"), 0, {{"monster", 24742}}}},
        },
        [11472] = { -- The Way to His Heart...
            [questKeys.objectives] = {{{24797,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Lure Reef Bull with Tasty Reef Fish"), 0, {{"monster", 24786},{"monster", 24804}}}},
            [questKeys.reputationReward] = {{factionIDs.THE_KALUAK,500}},
            [questKeys.requiredSourceItems] = {34127},
        },
        [11475] = { -- Tools to Get the Job Done
            [questKeys.preQuestSingle] = {11244},
        },
        [11478] = { -- Outpost Over Yonder...
            [questKeys.exclusiveTo] = {11448},
        },
        [11485] = { -- Iron Rune Constructs and You: Rocket Jumping
            [questKeys.triggerEnd] = {"Rocket Jump Mastered",{[zoneIDs.HOWLING_FJORD]={{75.08,64.55}}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use the Work Bench then cast Rocket Jump standing on the rune next to it"),0,{{"object", 186958}}}},
        },
        [11489] = { -- Iron Rune Constructs and You: Collecting Data
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use the Work Bench then cast Collect Data near the blue relic near Gwendolyn's cart"),0,{{"object", 186958}}}},
        },
        [11491] = { -- Iron Rune Constructs and You: The Bluff
            [questKeys.objectives] = {{{24718,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use the Work Bench then cast Bluff on Lebronski after you've walked on his rug"),0,{{"object", 186958}}}},
        },
        [11494] = { -- Lightning Infused Relics
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Put on the Golem suit"),0,{{"object", 186958}}}},
        },
        [11495] = { -- The Delicate Sound of Thunder
            [questKeys.objectives] = {{{24847,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Put on the Golem suit"),0,{{"object", 186958}}}},
        },
        [11528] = { -- A Winter Veil Gift
            [questKeys.exclusiveTo] = {13203,13966},
        },
        [11529] = { -- Sorlof's Booty
            [questKeys.extraObjectives] = {{{[zoneIDs.HOWLING_FJORD]={{37.2,74.8}}}, Questie.ICON_TYPE_OBJECT, l10n("Use The Big Gun at the front of the ship to slay Sorlof"),0,{{"monster", 24992}}}},
        },
        [11566] = { -- Surrender... Not!
            [questKeys.requiredSourceItems] = {},
        },
        [11567] = { -- The Ancient Armor of the Kvaldir
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_TALK, l10n("Ask Alanya for transportation"),0,{{"monster", 27933}}},
                {nil, Questie.ICON_TYPE_TALK, l10n("After acquiring the Armor, get a ride back"),0,{{"monster", 28277}}},
            },
        },
        [11568] = { -- A Return to Resting
            [questKeys.requiredSourceItems] = {},
        },
        [11569] = { -- Keymaster Urmgrgl
            [questKeys.preQuestSingle] = {11571},
        },
        [11570] = { -- Escape from the Winterfin Caverns
            [questKeys.triggerEnd] = {"Escort Lurgglbr to safety",{[zoneIDs.BOREAN_TUNDRA]={{41.35,16.29}}}},
        },
        [11574] = { -- Too Close For Comfort
            [questKeys.preQuestSingle] = {11595,11596,11597},
            [questKeys.exclusiveTo] = {11587},
        },
        [11575] = { -- Nick of Time
            [questKeys.exclusiveTo] = {11587},
        },
        [11576] = { -- Monitoring the Rift: Cleftcliff Anomaly
            [questKeys.requiredSourceItems] = {},
        },
        [11582] = { -- Monitoring the Rift: Sundered Chasm
            [questKeys.requiredSourceItems] = {},
        },
        [11585] = { -- Hellscream's Vigil
            [questKeys.exclusiveTo] = {10212,11586}, -- we want to only show 11586 if you did the Nagrand quest
        },
        [11587] = { -- Prison Break
            [questKeys.preQuestSingle] = {},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Open the prison"),0,{{"object", 187561}}}},
        },
        [11590] = { -- Abduction
            [questKeys.objectives] = {{{25316,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.requiredSourceItems] = {},
        },
        [11591] = { -- Report to Steeljaw's Caravan
            [questKeys.exclusiveTo] = {11592,11593,11594,},
        },
        [11592] = { -- We Strike!
            [questKeys.triggerEnd] = {"Successfully assisted Longrunner Proudhoof's assault.",{[zoneIDs.BOREAN_TUNDRA]={{49.45,26.49}}}},
        },
        [11593] = { -- The Honored Dead
            [questKeys.requiredSourceItems] = {},
        },
        [11594] = { -- Put Them to Rest
            [questKeys.preQuestSingle] = {},
        },
        [11595] = { -- The Defense of Warsong Hold (Nefarian Variant)
            [questKeys.preQuestGroup] = {7783,11585}, -- 11585 is exclusiveTo with 11586, so we need only 1 of them to check both
            [questKeys.exclusiveTo] = {8745}, -- we use exclusiveTo for the the Scarab Lord quest, so it doesn't show when you did that one
        },
        [11596] = { -- The Defense of Warsong Hold (Normal Variant)
            [questKeys.preQuestSingle] = {11585,11586}, -- we have both here since exclusiveTo fields are ignored in preQuestSingle
            [questKeys.exclusiveTo] = {7784,8745}, -- we use exclusiveTo for the Nefarian Head quest and the Scarab Lord quests, so it doesn't show when you did either of those quests
        },
        [11597] = { -- The Defense of Warsong Hold (Scarab Lord Variant)
            [questKeys.preQuestGroup] = {8745,11585}, -- 11585 is exclusiveTo with 11586, so we need only 1 of them to check both
        },
        [11606] = { -- Patience is a Virtue that We Don't Need
            [questKeys.preQuestSingle] = {11595,11596,11597},
        },
        [11608] = { -- Bury Those Cockroaches!
            [questKeys.requiredSourceItems] = {},
        },
        [11610] = { -- Leading the Ancestors Home
            [questKeys.objectives] = {nil,{{191088},{191089},{191090}}},
            [questKeys.requiredSourceItems] = {},
        },
        [11611] = { -- Taken by the Scourge
            [questKeys.preQuestSingle] = {11595,11596,11597},
            [questKeys.objectives] = {{{25284,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [11626] = { -- The Emissary
            [questKeys.requiredSourceItems] = {},
        },
        [11631] = { -- Vision of Air
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Use Imperean's Primal on Snarlfang's Totem"),0,{{"monster", 25455}}}},
            [questKeys.requiredSourceItems] = {},
        },
        [11632] = { -- What the Cold Wind Brings...
            [questKeys.startedBy] = {nil,nil,{34777}},
        },
        [11633] = { -- Blending In
            [questKeys.requiredSourceItems] = {},
        },
        [11636] = { -- Magic Carpet Ride
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Take a ride to Garrosh's Landing"),0,{{"monster", 25459}}}},
        },
        [11637] = { -- Kaganishu
            [questKeys.sourceItemId] = 34781,
        },
        [11647] = { -- Neutralizing the Cauldrons
            [questKeys.requiredSourceItems] = {},
        },
        [11648] = { -- The Art of Persuasion
            [questKeys.requiredSourceItems] = {},
        },
        [11650] = { -- Just a Few More Things...
            [questKeys.requiredSourceItems] = {},
        },
        [11652] = { -- The Plains of Nasam
            [questKeys.objectives] = {{{25465}},nil,nil,nil,{{{27106,27107,27108,27110},27106,nil,Questie.ICON_TYPE_INTERACT},{{25332,25333,25469,},25333}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_MOUNT_UP, l10n("Drive a tank"),0,{{"monster", 25334}}}},
        },
        [11653] = { -- Hah... You're Not So Big Now!
            [questKeys.objectives] = {{{25432,nil,Questie.ICON_TYPE_INTERACT},{25434,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.requiredSourceItems] = {},
        },
        [11654] = { -- The Spire of Blood
            [questKeys.startedBy] = {nil,nil,{34815}},
            [questKeys.preQuestSingle] = {11633},
        },
        [11656] = { -- Burn in Effigy
            [questKeys.objectives] = {nil,{{188656},{188655},{188653},{188657}}},
            [questKeys.requiredSourceItems] = {},
        },
        [11661] = { -- Orabus the Helmsman
            [questKeys.requiredSourceItems] = {},
        },
        [11664] = { -- Escaping the Mist
            [questKeys.triggerEnd] = {"Mootoo Saved",{[zoneIDs.BOREAN_TUNDRA]={{31.19,54.44}}}},
        },
        [11670] = { -- It Was The Orcs, Honest!
            [questKeys.objectives] = {{{25430,nil,Questie.ICON_TYPE_INTERACT}},nil,{{34870,nil}}},
            [questKeys.requiredSourceItems] = {34869},
        },
        [11671] = { -- A Race Against Time
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_SLAY, l10n("Kill Inquisitor Salrand"), 0, {{"monster", 25584}}},
                {{[zoneIDs.BOREAN_TUNDRA]={{41.8,39.1}}}, Questie.ICON_TYPE_EVENT, l10n("Use Beryl Shield Detonator")},
            },
            [questKeys.requiredSourceItems] = {},
        },
        [11673] = { -- Get Me Outa Here!
            [questKeys.triggerEnd] = {"Bonker Togglevolt escorted to safety.",{[zoneIDs.BOREAN_TUNDRA]={{53.84,13.85}}}},
        },
        [11677] = { -- Stop the Plague
            [questKeys.objectives] = {nil,{{187879}}},
            [questKeys.requiredSourceItems] = {},
        },
        [11680] = { -- Taking Wing
            [questKeys.requiredSourceItems] = {},
        },
        [11686] = { -- The Warsong Farms
            [questKeys.objectives] = {nil,{{191697},{191698},{191699}}},
        },
        [11688] = { -- Damned Filthy Swine
            [questKeys.preQuestSingle] = {},
        },
        [11690] = { -- Bring 'Em Back Alive
            [questKeys.objectives] = {{{25596,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Bring the kodos to Farmer Torp"), 0, {{"monster", 25607}}}},
            [questKeys.requiredSourceItems] = {},
        },
        [11691] = { -- Summon Ahune
            [questKeys.requiredLevel] = 75,
        },
        [11694] = { -- There's Something Going On In Those Caves
            [questKeys.objectives] = {nil,{{187879}}},
            [questKeys.requiredSourceItems] = {},
        },
        [11696] = { -- Ahune is Here!
            [questKeys.requiredLevel] = 75,
        },
        [11704] = { -- King Mrgl-Mrgl
            [questKeys.preQuestSingle] = {11708},
        },
        [11705] = { -- Foolish Endeavors
            [questKeys.objectives] = {{{25618}}},
        },
        [11706] = { -- The Collapse
            [questKeys.objectives] = {{{25768},{25768,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use The Horn of Elemental Fury near the southern sinkhole"),0,{{"monster", 25664}}}},
        },
        [11708] = { -- The Mechagnomes
            [questKeys.preQuestSingle] = {},
            [questKeys.objectives] = {{{25590,nil,Questie.ICON_TYPE_TALK}}},
        },
        [11711] = { -- Coward Delivery... Under 30 Minutes or it's Free
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Get a new Deserter if you lose him/her"), 0, {{"monster", 25379}}}},
            [questKeys.triggerEnd] = {"Alliance Deserter Delivered",{[zoneIDs.BOREAN_TUNDRA]={{55.28,50.86}}}},
            [questKeys.requiredSourceItems] = {},
        },
        [11712] = { -- Re-Cursive
            [questKeys.objectives] = {nil,nil,nil,nil,{{{25814},25814,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.requiredSourceItems] = {},
        },
        [11713] = { -- Scouting the Sinkholes
            [questKeys.preQuestSingle] = {11796},
        },
        [11719] = { -- A Suitable Test Subject
            [questKeys.triggerEnd] = {"Bloodspore Flower Used",{[zoneIDs.BOREAN_TUNDRA]={{52.07,52.46}}}},
        },
        [11721] = { -- Gammothra the Tormentor
            [questKeys.requiredSourceItems] = {},
        },
        [11723] = { -- Deploy the Shake-n-Quake!
            [questKeys.objectives] = {{{25768},{25794,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.requiredSourceItems] = {},
        },
        [11728] = { -- Lupus Pupus
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Throw Wolf Bait"),0,{{"monster", 25791}}}},
            [questKeys.requiredSourceItems] = {},
        },
        [11730] = { -- Master and Servant
            [questKeys.objectives] = {nil,nil,nil,nil,{{{25753,25758,25752},25753,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.requiredSourceItems] = {},
        },
        [11788] = { -- Lefty Loosey, Righty Tighty
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_OBJECT, l10n("Use Valve"),1,{{"object", 187984}}},
                {nil, Questie.ICON_TYPE_OBJECT, l10n("Use Valve"),2,{{"object", 187985}}},
                {nil, Questie.ICON_TYPE_OBJECT, l10n("Use Valve"),3,{{"object", 187986}}},
                {nil, Questie.ICON_TYPE_OBJECT, l10n("Use Valve"),4,{{"object", 187987}}},
            },
        },
        [11794] = { -- The Hunt is On
            [questKeys.requiredSourceItems] = {},
        },
        [11796] = { -- Emergency Protocol: Section 8.2, Paragraph D
            [questKeys.requiredSourceItems] = {},
        },
        [11798] = { -- The Gearmaster
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Use The Gearmaster's Manual"),0,{{"object", 190334}}}},
        },
        [11855] = { -- Honor the Flame
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [11865] = { -- Unfit for Death
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Place fake fur near Caribou Traps"),0,{{"object", 187995},{"object", 187996},{"object", 187997},{"object", 187998},{"object", 187999},{"object", 188000},{"object", 188001},{"object", 188002},{"object", 188003},{"object", 188004},{"object", 188005},{"object", 188006},{"object", 188007},{"object", 188008}}}},
            [questKeys.requiredSourceItems] = {},
        },
        [11876] = { -- Help Those That Cannot Help Themselves
            [questKeys.requiredSourceItems] = {},
        },
        [11878] = { -- Khu'nok Will Know
            [questKeys.objectives] = {{{25862,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Deliver the orphan to Khu'nok"),0,{{"monster", 25861}}}},
        },
        [11879] = { -- Kaw the Mammoth Destroyer
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_MOUNT_UP, l10n("Mount Wooly Mammoth Bull to assist in killing Kaw the Mammoth Destroyer"),0,{{"monster", 25743}}},
                {nil, Questie.ICON_TYPE_SLAY, l10n("Kill Kaw the Mammoth Destroyer"), 0, {{"monster", 25802}}},
            },
        },
        [11880] = { -- The Multiphase Survey
            [questKeys.requiredRaces] = raceIDs.NONE,
        },
        [11881] = { -- Load'er Up!
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_EVENT, l10n("Use Jenny's Whistle near a crashed flying machine"),0,{{"object", 188019}}},
                {nil, Questie.ICON_TYPE_EVENT, l10n("Return Jenny to safety without losing cargo"),0,{{"monster", 25849}}},
            },
            [questKeys.requiredSourceItems] = {},
        },
        [11887] = { -- Emergency Supplies
            [questKeys.objectives] = {nil,nil,{{35276}}},
        },
        [11888] = { -- Ride to Taunka'le Village
            [questKeys.preQuestSingle] = {11595,11596,11597},
        },
        [11889] = { -- Death From Above
            [questKeys.requiredSourceItems] = {},
        },
        [11890] = { -- What Are They Up To?
            [questKeys.triggerEnd] = {"Fizzcrank Pumping Station environs inspected.",{[zoneIDs.BOREAN_TUNDRA]={{64.38,23.81}}}},
        },
        [11891] = { -- An Innocent Disguise
            [questKeys.requiredSourceItems] = {35828},
        },
        [11892] = { -- The Assassination of Harold Lane
            [questKeys.requiredSourceItems] = {},
        },
        [11893] = { -- The Power of the Elements
            [questKeys.objectives] = {{{24601}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Use Windsoul Totem to collect energy from killing Steam Ragers"),0,{{"monster", 24601}}}},
            [questKeys.requiredSourceItems] = {},
        },
        [11894] = { -- Patching Up
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use Uncured Caribou Hide"),0,{{"object", 188086}}}},
        },
        [11895] = { -- Master the Storm
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Use Storm Totem to summon Storm Tempest"),0,{{"monster", 26048}}}},
        },
        [11896] = { -- Weakness to Lightning
            [questKeys.objectives] = {nil,nil,nil,nil,{{{25752,25753,25758},26082}}},
            [questKeys.requiredSourceItems] = {},
        },
        [11897] = { -- Plug the Sinkholes
            [questKeys.requiredSourceItems] = {},
        },
        [11898] = { -- Breaking Through
            [questKeys.extraObjectives] = {
                {{[zoneIDs.BOREAN_TUNDRA]={{86.55,28.59}}}, Questie.ICON_TYPE_EVENT, l10n("Enter teleporter to access Naxxanar"),},
                {{[zoneIDs.BOREAN_TUNDRA]={{86.80,30.12}}}, Questie.ICON_TYPE_EVENT, l10n("Use Naxxanar teleporters"),},
            },
        },
        [11899] = { -- Souls of the Decursed
            [questKeys.objectives] = {{{25814,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.preQuestSingle] = {11895},
            [questKeys.requiredSourceItems] = {},
        },
        [11905] = { -- Postponing the Inevitable
            [questKeys.extraObjectives] = {{{[zoneIDs.THE_NEXUS]={{64.9,21.6},{-1,-1}}}, Questie.ICON_TYPE_EVENT, l10n("Use Interdimensional Refabricator")}},
            [questKeys.requiredSourceItems] = {},
        },
        [11906] = { -- Cleaning Up the Pools
            [questKeys.preQuestSingle] = {11895},
        },
        [11907] = { -- The Sub-Chieftains
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_OBJECT, l10n("Use Valve"),1,{{"object", 187984}}},
                {nil, Questie.ICON_TYPE_OBJECT, l10n("Use Valve"),2,{{"object", 187985}}},
                {nil, Questie.ICON_TYPE_OBJECT, l10n("Use Valve"),3,{{"object", 187986}}},
                {nil, Questie.ICON_TYPE_OBJECT, l10n("Use Valve"),4,{{"object", 187987}}},
            },
        },
        [11908] = { -- Reference Material
            [questKeys.preQuestSingle] = {11902},
        },
        [11909] = { -- Defeat the Gearmaster
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Research the Gearmaster's Manual"),0,{{"object", 190334},{"object", 190335}}}},
        },
        [11913] = { -- Take No Chances
            [questKeys.objectives] = {nil,{{188112}}},
            [questKeys.requiredSourceItems] = {},
        },
        [11919] = { -- Drake Hunt
            [questKeys.objectives] = {{{26127,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Bring the captured drake to Raelorasz"),0,{{"monster", 26117}}}},
            [questKeys.requiredSourceItems] = {},
            [questKeys.zoneOrSort] = 3537,
        },
        [11930] = { -- Across Transborea
            [questKeys.triggerEnd] = {"Secure Passage to Dragonblight",{[zoneIDs.DRAGONBLIGHT]={{10.29,53.83}}}},
        },
        [11938] = { -- Buying Some Time
            [questKeys.objectives] = {nil,nil,nil,nil,{{{25378,25383,25386,25387,25393,25609},25378}}},
            [questKeys.requiredSourceItems] = {},
        },
        [11940] = { -- Drake Hunt
            [questKeys.objectives] = {{{26127,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Bring the captured drake to Raelorasz"),0,{{"monster", 26117}}}},
            [questKeys.zoneOrSort] = 3537,
            [questKeys.requiredSourceItems] = {},
        },
        [11945] = { -- Preparing for the Worst
            [questKeys.reputationReward] = {{factionIDs.THE_KALUAK,500}},
        },
        [11946] = { -- Keristrasza
            [questKeys.sourceItemId] = 35671,
        },
        [11951] = { -- Bait and Switch
            [questKeys.requiredSourceItems] = {35671},
        },
        [11955] = { -- Ahune, the Frost Lord
            [questKeys.requiredLevel] = 75,
        },
        [11956] = { -- Finding the Phylactery
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_OBJECT, l10n("Ride Dusk"),0,{{"monster", 26191}}},
                {nil, Questie.ICON_TYPE_OBJECT, l10n("Open the phylactery"),0,{{"object", 188141}}},
            },
        },
        [11957] = { -- Saragosa's End
            [questKeys.requiredSourceItems] = {35671},
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_TALK, l10n("Talk to Keristrasza"),0,{{"monster", 26206}}},
                {{[zoneIDs.BOREAN_TUNDRA]={{22,22.6}}}, Questie.ICON_TYPE_EVENT, l10n("Use Arcane Power Focus"),},
            },
        },
        [11959] = { -- Slay Loguhn
            [questKeys.objectives] = {{{26196,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [11960] = { -- Planning for the Future
            [questKeys.reputationReward] = {{factionIDs.THE_KALUAK,500}},
        },
        [11967] = { -- Mustering the Reds
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Talk to Keristrasza"),0,{{"monster", 26206}}}},
        },
        [11969] = { -- Springing the Trap
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use Raelorasz' Spark"),0,{{"object", 194151}}}},
            [questKeys.requiredSourceItems] = {},
        },
        [11972] = { -- Shards of Ahune
            [questKeys.requiredLevel] = 75,
        },
        [11982] = { -- Raining Down Destruction
            [questKeys.objectives] = {{{26270,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.preQuestSingle] = {},
        },
        [11984] = { -- Filling the Cages
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_TALK, l10n("Enlist Budd's help"), 0, {{"monster", 26422}}},
                {nil, Questie.ICON_TYPE_EVENT, l10n("Escort Budd to the Drak'Zin Ruins"), 0, {{"monster", 32663}}},
                {nil, Questie.ICON_TYPE_OBJECT, l10n("Use Budd's Tag Troll spell to stun Drakkari trolls"), 0, {{"monster", 26425}, {"monster", 26447}}},
                {nil, Questie.ICON_TYPE_OBJECT, l10n("Capture stunned Drakkari trolls with Bounty Hunter's Cage"), 0, {{"monster", 26425}, {"monster", 26447}}},
            },
            [questKeys.requiredSourceItems] = {},
        },
        [11989] = { -- Truce?
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use the Dull Carving Knife near Drakuru"),0,{{"monster", 26423}}}},
        },
        [11991] = { -- Subject to Interpretation
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Drink Drakuru's Elixir after gathering 5 Frozen Mojo"),0,{{"object", 188287}}}},
            [questKeys.requiredSourceItems] = {35799},
        },
        [11993] = { -- The Runic Prophecies
            [questKeys.requiredSourceItems] = {},
        },
        [11995] = { -- Your Presence is Required at Stars' Rest
            [questKeys.exclusiveTo] = {12439},
        },
        [12007] = { -- Sacrifices Must be Made
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Drink Drakuru's Elixir after gathering Zim'bo's Mojo"),0,{{"object", 420033}}}},
            [questKeys.requiredSourceItems] = {35797,35836},
        },
        [12014] = { -- Steady as a Rock?
            [questKeys.sourceItemId] = 35837,
        },
        [12017] = { -- Meat on the Hook
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use Tu'u'gwar's Bait"),0,{{"object", 188370}}}},
            [questKeys.requiredSourceItems] = {},
        },
        [12019] = { -- Last Rites
            [questKeys.finishedBy] = {{26170,198875}},
            [questKeys.extraObjectives] = {
                {{[zoneIDs.BOREAN_TUNDRA]={{86.6,28.6}}}, Questie.ICON_TYPE_EVENT, l10n("Teleport to the top of Naxxanar"),},
                {nil, Questie.ICON_TYPE_TALK, l10n("Talk to Thassarian"), 0, {{"monster", 198875}}},
            },
        },
        [12020] = { -- This One Time, When I Was Drunk...
            [questKeys.preQuestSingle] = {},
        },
        [12022] = { -- Chug and Chuck!
            [questKeys.preQuestSingle] = {},
            [questKeys.requiredSourceItems] = {33096},
        },
        [12027] = { -- Mr. Floppy's Perilous Adventure
            [questKeys.triggerEnd] = {"Help Emily and Mr. Floppy return to the camp",{[zoneIDs.GRIZZLY_HILLS]={{53.81,33.33}}}},
        },
        [12028] = { -- Spiritual Insight
            [questKeys.objectives] = {nil,{{188416}}},
            [questKeys.requiredSourceItems] = {},
        },
        [12029] = { -- Seared Scourge
            [questKeys.objectives] = {nil,nil,nil,nil,{{{26458,26570,26582,26583},26612}}},
            [questKeys.requiredSourceItems] = {},
        },
        [12032] = { -- Conversing With the Depths
            [questKeys.objectives] = {{{26648,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Commune with Oacha'noa"),0,{{"object", 188422}}}},
        },
        [12033] = { -- Message from the West
            [questKeys.preQuestSingle] = {11916},
            [questKeys.objectives] = {nil,{{188423}}},
        },
        [12034] = { -- Victory Nears...
            [questKeys.preQuestSingle] = {12008},
        },
        [12035] = { -- Repurposed Technology
            [questKeys.objectives] = {{{25623,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.requiredSourceItems] = {},
        },
        [12036] = { -- From the Depths of Azjol-Nerub
            [questKeys.triggerEnd] = {"Pit of Narjun Explored",{[zoneIDs.DRAGONBLIGHT]={{26.26,50.01}}}},
        },
        [12037] = { -- Search and Rescue
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Search for Kurzel"),0,{{"monster", 27909}}}}, -- to use -1 instead of 0 when questie supports showing extraobjectives when quest complete
        },
        [12038] = { -- Seared Scourge
            [questKeys.objectives] = {nil,nil,nil,nil,{{{26458,26570,26582,26583},26612}}},
            [questKeys.requiredSourceItems] = {},
        },
        [12039] = { -- Black Blood of Yogg-Saron
            [questKeys.preQuestSingle] = {12034},
            [questKeys.requiredSourceItems] = {},
        },
        [12049] = { -- Hard to Swallow
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Throw the Explosive Charges when it opens its mouth wide"),0,{{"monster", 26293}}}},
            [questKeys.requiredSourceItems] = {},
        },
        [12050] = { -- Lumber Hack
            [questKeys.preQuestGroup] = {12046,12047},
            [questKeys.requiredSourceItems] = {},
        },
        [12052] = { -- Harp on This!
            [questKeys.preQuestGroup] = {12046,12047},
            [questKeys.requiredSourceItems] = {},
        },
        [12053] = { -- The Might of the Horde
            [questKeys.objectives] = {{{26678,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [12055] = { -- A Strange Device
            [questKeys.startedBy] = {nil,nil,{36742}},
            [questKeys.preQuestSingle] = {12000},
        },
        [12056] = { -- Marked for Death: High Cultist Zangus
            [questKeys.preQuestSingle] = {12034},
        },
        [12058] = { -- The Runic Prophecies
            [questKeys.requiredSourceItems] = {},
        },
        [12059] = { -- A Strange Device
            [questKeys.startedBy] = {nil,nil,{36746}},
            [questKeys.preQuestSingle] = {11999},
        },
        [12060] = { -- Projections and Plans
            [questKeys.requiredSourceItems] = {},
        },
        [12061] = { -- Projections and Plans
            [questKeys.requiredSourceItems] = {},
        },
        [12063] = { -- Strength of Icemist
            [questKeys.preQuestSingle] = {12036},
        },
        [12065] = { -- The Focus on the Beach
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_OBJECT, l10n("Ley line focus information retrieved"), 0, {{"object", 188445}}},
            },
        },
        [12066] = { -- The Focus on the Beach
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_OBJECT, l10n("Ley line focus information retrieved"), 0, {{"object", 188445}}},
            },
        },
        [12067] = { -- A Letter for Home
            [questKeys.startedBy] = {nil,nil,{36756}},
        },
        [12068] = { -- Voices From the Dust
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Drink Drakuru's Elixir after gathering 5 Sacred Mojo"),0,{{"object", 420049}}}},
            [questKeys.requiredSourceItems] = {35797,36758},
        },
        [12069] = { -- Return of the High Chief
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Free Roanauk Icemist"),0,{{"object", 188463}}}},
            [questKeys.requiredSourceItems] = {},
        },
        [12070] = { -- Rallying the Troops
            [questKeys.requiredSourceItems] = {},
        },
        [12072] = { -- Blightbeasts be Damned!
            [questKeys.requiredSourceItems] = {},
        },
        [12075] = { -- Slim Pickings
            [questKeys.preQuestSingle] = {},
        },
        [12076] = { -- Messy Business
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use Zort's Scraper when covered in Corrosive Spit"),0,{{"monster", 26358},{"monster", 26359}}}},
            [questKeys.requiredSourceItems] = {},
        },
        [12078] = { -- Worm Wrangler
            [questKeys.preQuestSingle] = {12077},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use the Sturdy Crates to capture the worm spawn"),0,{{"monster", 26359}}}},
            [questKeys.requiredSourceItems] = {},
        },
        [12079] = { -- Stomping Grounds
            [questKeys.preQuestSingle] = {12075},
        },
        [12080] = { -- Really Big Worm
            [questKeys.preQuestSingle] = {12076},
        },
        [12082] = { -- Dun-da-Dun-tah!
            [questKeys.triggerEnd] = {"Harrison has escorted you to safety.",{[zoneIDs.GRIZZLY_HILLS]={{73.51,24.02}}}},
        },
        [12083] = { -- Atop the Woodlands
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_OBJECT, l10n("Ley line focus information retrieved"), 0, {{"object", 188474}}},
            },
        },
        [12084] = { -- Atop the Woodlands
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_OBJECT, l10n("Ley line focus information retrieved"), 0, {{"object", 188474}}},
            },
        },
        [12085] = { -- A Letter for Home
            [questKeys.startedBy] = {nil,nil,{36780}},
        },
        [12092] = { -- Strengthen the Ancients
            [questKeys.preQuestSingle] = {12065},
        },
        [12095] = { -- To Dragon's Fall
            [questKeys.preQuestGroup] = {12089,12090,12091},
        },
        [12096] = { -- Strengthen the Ancients
            [questKeys.preQuestSingle] = {12066},
        },
        [12097] = { -- Sarathstra, Scourge of the North
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Talk to Rokhan to call down Sarathstra"), 0, {{"monster", 26859}}}},
        },
        [12099] = { -- Free at Last
            [questKeys.objectives] = {{{26417,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.requiredSourceItems] = {},
        },
        [12100] = { -- Containing the Rot
            [questKeys.preQuestSingle] = {12034},
        },
        [12105] = { -- Descent into Darkness
            [questKeys.startedBy] = {nil,nil,{36940}},
        },
        [12107] = { -- The End of the Line
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Use Ley Line Focus Control Talisman"),1,{{"object", 188491}}}},
            [questKeys.requiredSourceItems] = {},
        },
        [12110] = { -- The End of the Line
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Use Ley Line Focus Control Talisman"),1,{{"object", 188491}}}},
            [questKeys.requiredSourceItems] = {},
        },
        [12111] = { -- Where the Wild Things Roam
            [questKeys.objectives] = {{{26615},{26482}}},
            [questKeys.requiredSourceItems] = {},
        },
        [12112] = { -- Stiff Negotiations
            [questKeys.preQuestGroup] = {12050,12052},
        },
        [12117] = { -- Travel to Moa'ki Harbor
            [questKeys.nextQuestInChain] = 11958,
        },
        [12118] = { -- Travel to Moa'ki Harbor
            [questKeys.nextQuestInChain] = 11958,
        },
        [12121] = { -- See You on the Other Side
            [questKeys.objectives] = {{{27199}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Ring the gong outside Drakil'jin to summon Warlord Jin'arrak"),0,{{"object", 188510}}}},
        },
        [12124] = { -- Informing the Queen
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Take a drake to the top of the temple"),1,{{"monster", 26443}}}},
        },
        [12125] = { -- In Service of Blood
            [questKeys.objectives] = {{{26411}},nil,{{36828}}},
        },
        [12126] = { -- In Service of the Unholy
            [questKeys.objectives] = {{{26926}},nil,{{36836}}},
        },
        [12127] = { -- In Service of Frost
            [questKeys.objectives] = {{{26283}},nil,{{36846}}},
        },
        [12132] = { -- The Power to Destroy
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {12125,12126,12127},
        },
        [12137] = { -- Chill Out, Mon
            [questKeys.sourceItemId] = 36859,
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_TALK, l10n("Speak with Gan'jo to return to life"),0,{{"monster", 26924}}},
                {nil, Questie.ICON_TYPE_OBJECT, l10n("Use the Snow of Eternal Slumber on ancient Drakkari spirits"),0,{{"monster", 26811},{"monster", 26812}}},
            },
        },
        [12138] = { -- ... Or Maybe We Don't
            [questKeys.objectives] = {nil,nil,nil,nil,{{{26407,27017},26407}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_SLAY, l10n("Fight Lightning Sentries with Depleted War Golem deployed nearby"),0,{{"monster", 26407}}}},
            [questKeys.requiredSourceItems] = {},
        },
        [12140] = { -- All Hail Roanauk!
            [questKeys.requiredSourceItems] = {},
        },
        [12146] = { -- Disturbing Implications
            [questKeys.startedBy] = {nil,nil,{36855}},
        },
        [12147] = { -- Disturbing Implications
            [questKeys.startedBy] = {nil,nil,{36856}},
        },
        [12150] = { -- Reclusive Runemaster
            [questKeys.objectives] = {{{27003}}},
        },
        [12151] = { -- Wanton Warlord
            [questKeys.extraObjectives] = {{{[zoneIDs.DRAGONBLIGHT]={{57.09,76.26}}}, Questie.ICON_TYPE_EVENT, l10n("Blow the horn"),0}},
            [questKeys.requiredSourceItems] = {},
        },
        [12152] = { -- Jin'arrak's End
            [questKeys.requiredSourceItems] = {36870,37063},
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_OBJECT, l10n("Place the Infused Drakkari Offering at the gongs outside Drakil'jin"),0,{{"object", 188510}}},
            },
        },
        [12153] = { -- The Iron Thane and His Anvil
            [questKeys.requiredSourceItems] = {},
        },
        [12154] = { -- Blackout
            [questKeys.requiredSourceItems] = {},
        },
        [12157] = { -- The Lost Courier
            [questKeys.exclusiveTo] = {12171,12235,12297},
        },
        [12159] = { -- Souls at Unrest
            [questKeys.objectives] = {{{26891,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.requiredSourceItems] = {},
        },
        [12166] = { -- The Liquid Fire of Elune
            [questKeys.objectives] = {{{26616,nil,Questie.ICON_TYPE_INTERACT},{26643,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.requiredSourceItems] = {},
        },
        [12171] = { -- Of Traitors and Treason
            [questKeys.exclusiveTo] = {12235,12297},
        },
        [12172] = { -- Attunement to Dalaran
            [questKeys.requiredSourceItems] = {},
        },
        [12173] = { -- Attunement to Dalaran
            [questKeys.requiredSourceItems] = {},
        },
        [12174] = { -- High Commander Halford Wyrmbane
            [questKeys.exclusiveTo] = {12235,12298},
        },
        [12180] = { -- The Captive Prospectors
            [questKeys.preQuestSingle] = {12014},
        },
        [12181] = { -- Give it a Name
            [questKeys.exclusiveTo] = {12188},
        },
        [12182] = { -- To Venomspite!
            [questKeys.exclusiveTo] = {},
            [questKeys.nextQuestInChain] = 12188,
        },
        [12184] = { -- Cultivating an Image
            [questKeys.objectives] = {nil,nil,nil,nil,{{{26408,26409,26410,26414,27177},26408}}},
        },
        [12185] = { -- Put on Your Best Face for Loken
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Intercept the message from Loken"),1,{{"object", 188596}}}},
            [questKeys.requiredSourceItems] = {},
        },
        [12188] = { -- The Forsaken Blight and You: How Not to Die
            [questKeys.preQuestSingle] = {},
        },
        [12191] = { -- Chug and Chuck!
            [questKeys.preQuestSingle] = {},
            [questKeys.requiredSourceItems] = {33096},
        },
        [12198] = { -- ... Or Maybe We Don't
            [questKeys.objectives] = {nil,nil,nil,nil,{{{26407,27017},26407}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_SLAY, l10n("Fight Lightning Sentries with Depleted War Golem deployed nearby"),0,{{"monster", 26407}}}},
            [questKeys.requiredSourceItems] = {},
        },
        [12199] = { -- Bringing Down the Iron Thane
            [questKeys.requiredSourceItems] = {},
        },
        [12202] = { -- Cultivating an Image
            [questKeys.objectives] = {nil,nil,nil,nil,{{{26408,26409,26410,26414,27177},26408}}},
        },
        [12203] = { -- Loken's Orders
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_EVENT, l10n("Intercept the message from Loken"),1,{{"object", 188596}}},
            },
            [questKeys.requiredSourceItems] = {},
        },
        [12204] = { -- In the Name of Loken
            [questKeys.preQuestSingle] = {12099,12058},
            [questKeys.preQuestGroup] = {},
            [questKeys.objectives] = {{{26484,nil,Questie.ICON_TYPE_TALK},{26420,nil,Questie.ICON_TYPE_TALK}}},
        },
        [12206] = { -- Blighted Last Rites
            [questKeys.objectives] = {{{27349,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [12207] = { -- Vordrassil's Fall
            [questKeys.preQuestSingle] = {12413},
        },
        [12208] = { -- Good Troll Hunting
            [questKeys.preQuestSingle] = {12412},
        },
        [12210] = { -- Troll Season!
            [questKeys.preQuestSingle] = {12212},
        },
        [12211] = { -- Let Them Not Rise!
            [questKeys.objectives] = {nil,nil,nil,nil,{{{27202,27203,27206,27207,27209,27210,27211,27232,27233,27234,27235,27236,27237,27246,27247},27203,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.requiredSourceItems] = {},
        },
        [12213] = { -- The Darkness Beneath
            [questKeys.preQuestSingle] = {12413},
            [questKeys.requiredSourceItems] = {},
        },
        [12214] = { -- Fresh Remounts
            [questKeys.objectives] = {nil,nil,nil,nil,{{{27206,27213,27296,27028},27296}}},
        },
        [12218] = { -- Spread the Good Word
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_EVENT, l10n("Commandeer a Forsaken Blight Spreader"),1,{{"monster", 26523}}},
            },
        },
        [12220] = { -- A Dark Influence
            [questKeys.requiredSourceItems] = {},
        },
        [12222] = { -- Secrets of the Flamebinders
            [questKeys.preQuestSingle] = {12294},
        },
        [12223] = { -- Thinning the Ranks
            [questKeys.preQuestSingle] = {12294},
        },
        [12224] = { -- The Kor'kron Vanguard!
            [questKeys.preQuestGroup] = {12221,12140,12072},
        },
        [12229] = { -- A Possible Link
            [questKeys.preQuestGroup] = {12207,12213},
        },
        [12231] = { -- The Bear God's Offspring
            [questKeys.objectives] = {{{27274,nil,Questie.ICON_TYPE_TALK},{27275,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.preQuestGroup] = {12207,12213},
        },
        [12232] = { -- Bombard the Ballistae
            [questKeys.objectives] = {nil,{{188673}}},
            [questKeys.requiredSourceItems] = {},
        },
        [12236] = { -- Ursoc, the Bear God
            [questKeys.preQuestGroup] = {12241,12242},
            [questKeys.objectives] = {{{26633}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Talk to Tur Ragepaw to summon Ursoc"),0,{{"monster", 27328}}}},
            [questKeys.requiredSourceItems] = {},
        },
        [12237] = { -- Flight of the Wintergarde Defender
            [questKeys.objectives] = {nil,nil,nil,nil,{{{27315,27336,27345,27341},27315,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.requiredSourceItems] = {},
        },
        [12238] = { -- Cleansing Drak'Tharon
            [questKeys.requiredSourceItems] = {35797,38303},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Drink Drakuru's Elixir after gathering 5 Enduring Mojo"),0,{{"object", 190629}}}},
        },
        [12240] = { -- A Means to an End
            [questKeys.extraObjectives] = {{{[zoneIDs.DRAGONBLIGHT]={{68.29,74.29}}}, Questie.ICON_TYPE_EVENT, l10n("Release the termites"),0}},
            [questKeys.requiredSourceItems] = {},
        },
        [12241] = { -- Destroy the Sapling
            [questKeys.preQuestGroup] = {12229,12231},
            [questKeys.requiredSourceItems] = {},
        },
        [12242] = { -- Vordrassil's Seeds
            [questKeys.preQuestGroup] = {12229,12231},
        },
        [12243] = { -- Fire Upon the Waters
            [questKeys.requiredSourceItems] = {},
        },
        [12244] = { -- Shredder Repair
            [questKeys.objectives] = {{{27354}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Deliver Shredder"),0,{{"monster", 27371}}}},
        },
        [12247] = { -- Children of Ursoc
            [questKeys.objectives] = {{{27274,nil,Questie.ICON_TYPE_TALK},{27275,nil,Questie.ICON_TYPE_TALK}}},
        },
        [12248] = { -- Vordrassil's Sapling
            [questKeys.requiredSourceItems] = {},
        },
        [12249] = { -- Ursoc, the Bear God
            [questKeys.objectives] = {{{26633}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Talk to Tur Ragepaw to summon Ursoc"),0,{{"monster", 27328}}}},
            [questKeys.requiredSourceItems] = {},
        },
        [12252] = { -- Torture the Torturer
            [questKeys.objectives] = {{{27209,nil,Questie.ICON_TYPE_INTERACT},{27209}}},
            [questKeys.requiredSourceItems] = {},
        },
        [12255] = { -- The Thane of Voldrune
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Ride Flamebringer"),0,{{"monster", 27292}}}},
        },
        [12256] = { -- The Flamebinders' Secrets
            [questKeys.preQuestSingle] = {12468},
        },
        [12258] = { -- The Fate of the Dead
            [questKeys.preQuestSingle] = {12251},
        },
        [12259] = { -- The Thane of Voldrune
            [questKeys.preQuestGroup] = {12256,12257},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Ride Flamebringer"),0,{{"monster", 27292}}}},
        },
        [12260] = { -- The Perfect Dissemblance
            [questKeys.objectives] = {{{27202}}},
        },
        [12261] = { -- No Place to Run
            [questKeys.preQuestSingle] = {12447},
            [questKeys.objectives] = {{{27430}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use Destructive Ward"),0,{{"object", 188707}}}},
            [questKeys.requiredSourceItems] = {},
        },
        [12262] = { -- No One to Save You
            [questKeys.preQuestSingle] = {12447},
        },
        [12263] = { -- The Best of Intentions
            [questKeys.triggerEnd] = {"Uncover the Magmawyrm Resurrection Chamber",{[zoneIDs.DRAGONBLIGHT]={{31.76,30.46}}}},
        },
        [12264] = { -- Culling the Damned
            [questKeys.preQuestSingle] = {12263},
            [questKeys.objectives] = {{{27358},{27362},{27363}}},
        },
        [12265] = { -- Defiling the Defilers
            [questKeys.preQuestSingle] = {12263},
        },
        [12267] = { -- Neltharion's Flame
            [questKeys.requiredSourceItems] = {},
        },
        [12269] = { -- Not In Our Mine
            [questKeys.preQuestSingle] = {12275},
        },
        [12270] = { -- Shred the Alliance
            [questKeys.objectives] = {{{27354}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Deliver Shredder"),0,{{"monster", 27423}}}},
        },
        [12271] = { -- The Rod of Compulsion
            [questKeys.startedBy] = {nil,nil,{37432}},
            [questKeys.preQuestSingle] = {12245},
        },
        [12272] = { -- The Bleeding Ore
            [questKeys.preQuestSingle] = {12275},
            [questKeys.requiredSourceItems] = {},
        },
        [12273] = { -- The Denouncement
            [questKeys.objectives] = {{{27237},{27235},{27234},{27236}}},
            [questKeys.requiredSourceItems] = {},
        },
        [12274] = { -- A Fall From Grace
            [questKeys.objectives] = {nil,{{188713}},nil,nil,{{{27245},27245,nil,Questie.ICON_TYPE_TALK}}},
        },
        [12276] = { -- The Search for Slinkin
            [questKeys.requiredSourceItems] = {},
        },
        [12277] = { -- Leave Nothing to Chance
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Place the Mine Bomb here"),0,{{"object", 188711}}}},
        },
        [12279] = { -- A Bear of an Appetite
            [questKeys.requiredSourceItems] = {},
        },
        [12284] = { -- Keep 'Em on Their Heels
            [questKeys.objectives] = {nil,nil,nil,nil,{{{27475,27482,},27475}}},
        },
        [12288] = { -- Overwhelmed!
            [questKeys.objectives] = {{{27463,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.requiredSourceItems] = {},
        },
        [12289] = { -- Kick 'Em While They're Down
            [questKeys.objectives] = {nil,nil,nil,nil,{{{27456,27463},27456}}},
        },
        [12291] = { -- The Forgotten Tale
            [questKeys.objectives] = {{{27226,nil,Questie.ICON_TYPE_TALK},{27225,nil,Questie.ICON_TYPE_TALK},{27224,nil,Questie.ICON_TYPE_TALK},{27229,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.requiredSourceItems] = {},
        },
        [12296] = { -- Life or Death
            [questKeys.objectives] = {{{27482,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.requiredSourceItems] = {},
        },
        [12297] = { -- Of Traitors and Treason
            [questKeys.preQuestSingle] = {11250},
            [questKeys.exclusiveTo] = {12171,12235},
        },
        [12298] = { -- High Commander Halford Wyrmbane
            [questKeys.exclusiveTo] = {12174,12235},
        },
        [12300] = { -- Test of Mettle
            [questKeys.requiredSourceItems] = {},
        },
        [12301] = { -- The Truth Shall Set Us Free
            [questKeys.objectives] = {nil,{{189304}}},
            [questKeys.requiredSourceItems] = {},
        },
        [12307] = { -- Wolfsbane Root
            [questKeys.preQuestSingle] = {},
        },
        [12308] = { -- Escape from Silverbrook
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_MOUNT_UP, l10n("Mount up"),0,{{"monster", 27409}}}},
            [questKeys.triggerEnd] = {"Escape from Silverbrook",{[zoneIDs.GRIZZLY_HILLS]={{32.37,59.14}}}},
            [questKeys.objectives] = {},
        },
        [12316] = { -- Keep Them at Bay!
            [questKeys.objectives] = {nil,nil,nil,nil,{{{27500,27550},27550}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Get in the shredder if you have the key"),0,{{"monster", 27496}}}},
        },
        [12317] = { -- Keep Them at Bay
            [questKeys.objectives] = {nil,nil,nil,nil,{{{27501,27549},27549}}},
        },
        [12323] = { -- Smoke 'Em Out
            [questKeys.objectives] = {{{27570,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.requiredSourceItems] = {},
        },
        [12324] = { -- Smoke 'Em Out
            [questKeys.objectives] = {{{27570,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.requiredSourceItems] = {},
        },
        [12321] = { -- A Righteous Sermon
            [questKeys.objectives] = {{{27577,nil,Questie.ICON_TYPE_TALK}}},
        },
        [12325] = { -- Into Hostile Territory
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Get a ride to Thorson's Post"),0,{{"monster", 27661}}}},
        },
        [12326] = { -- Steamtank Surprise
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Get in"),0,{{"monster", 27587}}}},
            [questKeys.objectives] = {{{27607,nil,Questie.ICON_TYPE_INTERACT},{27588,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [12327] = { -- Out of Body Experience
            [questKeys.triggerEnd] = {"Vision from the Past",{[zoneIDs.SILVERPINE_FOREST]={{46.53,76.18}}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use Gossamer Potion"),0,{{"object", 189972}}}},
            [questKeys.requiredSourceItems] = {},
        },
        [12330] = { -- Anatoly Will Talk
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use Tranquilizer Dart on Tatjana"),0,{{"monster", 27627}}}},
            [questKeys.triggerEnd] = {"Tatjana Delivered",{[zoneIDs.GRIZZLY_HILLS]={{57.77,41.7}}}},
            [questKeys.requiredSourceItems] = {},
        },
        [12372] = { -- Defending Wyrmrest Temple
            [questKeys.objectivesText] = {"Devrestrasz at Wyrmrest Temple has asked you to slay 3 Azure Dragons, slay 5 Azure Drakes, and to destabilize the Azure Dragonshrine while riding a Wyrmrest Defender into battle."}, -- #4675
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_TALK, l10n("Ride a Wyrmrest Defender to defend the Temple"), 0, {{"monster", 27629}}},
            },
        },
        [12405] = { -- Candy Bucket
            [questKeys.finishedBy] = {},
        },
        [12412] = { -- My Enemy's Friend
            [questKeys.preQuestSingle] = {12259},
        },
        [12414] = { -- Mounting Up
            [questKeys.objectives] = {{{26472,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Bring the mustangs to Squire Percy"), 0, {{"monster", 26377}}}},
            [questKeys.requiredSourceItems] = {37707},
        },
        [12415] = { -- The Horse Hollerer
            [questKeys.objectives] = {{{26472}}},
            [questKeys.requiredSourceItems] = {},
        },
        [12419] = { -- The Fate of the Ruby Dragonshrine
            [questKeys.startedBy] = {nil,nil,{37833}},
        },
        [12423] = { -- Mikhail's Journal
            [questKeys.startedBy] = {nil,nil,{37830}},
        },
        [12427] = { -- The Conquest Pit: Bear Wrestling!
            [questKeys.preQuestSingle] = {12413},
            [questKeys.objectives] = {{{27715}}},
            [questKeys.nextQuestInChain] = 12428,
        },
        [12428] = { -- The Conquest Pit: Mad Furbolg Fighting
            [questKeys.objectives] = {{{27716}}},
            [questKeys.nextQuestInChain] = 12429,
        },
        [12429] = { -- The Conquest Pit: Blood and Metal
            [questKeys.objectives] = {{{27717}}},
            [questKeys.nextQuestInChain] = 12430,
        },
        [12430] = { -- The Conquest Pit: Death Is Likely
            [questKeys.objectives] = {{{27718}}},
            [questKeys.nextQuestInChain] = 12431,
        },
        [12431] = { -- The Conquest Pit: Final Showdown
            [questKeys.objectives] = {{{27727}}},
        },
        [12432] = { -- Riding the Red Rocket
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Ride the rocket!"), 0, {{"monster", 27593}}}},
        },
        [12434] = { -- Always Seeking Solvent
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.preQuestSingle] = {12433},
            [questKeys.startedBy] = {{27565}},
            [questKeys.finishedBy] = {{27565}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [12435] = { -- Report to Lord Devrestrasz
            [questKeys.name] = "Report to Lord Devrestrasz",
            [questKeys.objectivesText] = {"Speak with Lord Devrestrasz at Wyrmrest Temple."},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Take a drake to the middle of the temple"), 0, {{"monster", 26949}}}},
        },
        [12437] = { -- Riding the Red Rocket
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Ride the rocket!"), 0, {{"monster", 27593}}}},
        },
        [12439] = { -- A Disturbance In The West
            [questKeys.exclusiveTo] = {11995,12000},
        },
        [12446] = { -- Always Seeking Solvent
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.preQuestSingle] = {12443},
            [questKeys.startedBy] = {{27495}},
            [questKeys.finishedBy] = {{27495}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [12453] = { -- Eyes Above
            [questKeys.preQuestSingle] = {12412},
            [questKeys.objectives] = {{{26369}}},
            [questKeys.requiredSourceItems] = {},
        },
        [12456] = { -- The Plume of Alystros
            [questKeys.extraObjectives] = {{{[zoneIDs.DRAGONBLIGHT]={{64.6,77}}}, Questie.ICON_TYPE_EVENT, l10n("Use Skytalon Molts"),0}},
            [questKeys.requiredSourceItems] = {},
        },
        [12457] = { -- The Chain Gun And You
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Man the Chain Gun"),0,{{"monster", 27714}}}},
        },
        [12459] = { -- That Which Creates Can Also Destroy
            [questKeys.objectives] = {{{26841},{27808},{27122}}},
            [questKeys.requiredSourceItems] = {},
        },
        [12462] = { -- Breaking Off A Piece
            [questKeys.preQuestSingle] = {12326},
        },
        [12464] = { -- My Old Enemy
            [questKeys.preQuestSingle] = {},
        },
        [12467] = { -- Chasing Icestorm: Thel'zan's Phylactery
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_TALK, l10n("Talk to Wyrmbait"),0,{{"monster", 27843}}},
                {nil, Questie.ICON_TYPE_SLAY, l10n("Destroy Icestorm"),0,{{"monster", 26287}}},
            },
        },
        [12468] = { -- The Conqueror's Task
            [questKeys.preQuestSingle] = {},
        },
        [12470] = { -- Mystery of the Infinite
            [questKeys.objectives] = {{{27840,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.requiredSourceItems] = {},
        },
        [12473] = { -- An End And A Beginning
            [questKeys.objectives] = {{{27383}}},
        },
        [12478] = { -- Frostmourne Cavern
            [questKeys.objectives] = {nil,{{190191}}},
            [questKeys.requiredSourceItems] = {},
        },
        [12481] = { -- Adding Injury to Insult
            [questKeys.objectives] = {{{24238,nil,Questie.ICON_TYPE_EVENT},{24238}}},
            [questKeys.requiredSourceItems] = {},
        },
        [12484] = { -- Scourgekabob
            [questKeys.extraObjectives] = {{{[zoneIDs.GRIZZLY_HILLS]={{16.84,48.34}}}, Questie.ICON_TYPE_EVENT, l10n("Place Scourged Troll Mummy in the fire"),0}},
        },
        [12486] = { -- To Bor'gorok Outpost, Quickly!
            [questKeys.preQuestSingle] = {11595,11596,11597},
        },
        [12491] = { -- Direbrew's Dire Brew
            [questKeys.startedBy] = {nil,nil,{38280}},
            [questKeys.preQuestSingle] = {},
        },
        [12492] = { -- Direbrew's Dire Brew
            [questKeys.startedBy] = {nil,nil,{38281}},
            [questKeys.preQuestSingle] = {},
        },
        [12498] = { -- On Ruby Wings
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_SLAY, l10n("Slay Antiok's mount to make him vulnerable"),0,{{"monster", 28018}}},
                {nil, Questie.ICON_TYPE_SLAY, l10n("Slay Grand Necrolord Antiok"),0,{{"monster", 28006}}},
                {nil, Questie.ICON_TYPE_MOUNT_UP, l10n("Mount up"),0,{{"monster", 27996}}},
            },
            [questKeys.requiredSourceItems] = {},
        },
        [12500] = { -- Return To Angrathar
            [questKeys.preQuestSingle] = {12498},
        },
        [12501] = { -- Troll Patrol
            [questKeys.finishedBy] = {{28039}},
            [questKeys.objectives] = {{{28042,nil,Questie.ICON_TYPE_TALK},{28044,nil,Questie.ICON_TYPE_TALK},{28043,nil,Questie.ICON_TYPE_TALK},{28205,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.exclusiveTo] = {12563,12587},
            [questKeys.childQuests] = {12502,12509,12519,12541},
        },
        [12502] = { -- Troll Patrol: High Standards
            [questKeys.parentQuest] = 12501,
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Plant the Argent Crusade Banner"), 0, {{"object", 190522}}}},
            [questKeys.requiredSourceItems] = {},
        },
        [12503] = { -- Defend the Stand
            [questKeys.objectives] = {nil,nil,nil,nil,{{{28023,28026,28246,28669,28022},28022}}},
        },
        [12506] = { -- Trouble at the Altar of Sseratus
            [questKeys.triggerEnd] = {"Main building at the Altar of Sseratus investigated.",{[zoneIDs.ZUL_DRAK]={{40.32,39.46}}}},
        },
        [12507] = { -- Strange Mojo
            [questKeys.startedBy] = {nil,nil,{38321}},
        },
        [12509] = { -- Troll Patrol: Intestinal Fortitude
            [questKeys.parentQuest] = 12501,
            [questKeys.objectives] = {{{28090,nil,Questie.ICON_TYPE_TALK}}},
        },
        [12512] = { -- Leave No One Behind
            [questKeys.objectives] = {nil,nil,nil,nil,{{{28133,28136},28133},{{28141,28142},28141},{{28143,28148},28143}}},
            [questKeys.preQuestSingle] = {},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Escort rescued Crusaders to Dr. Rogers"), 0, {{"monster", 28125}}}},
            [questKeys.requiredSourceItems] = {},
        },
        [12516] = { -- Too Much of a Good Thing
            [questKeys.objectives] = {{{28068}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_INTERACT, l10n("Use Muddled Mojo on Prophet of Sseratus before killing it"), 0, {{"monster", 28068}}}},
            [questKeys.requiredSourceItems] = {},
        },
        [12519] = { -- Troll Patrol: Whatdya Want, a Medal?
            [questKeys.parentQuest] = 12501,
        },
        [12520] = { -- Rhino Mastery: The Test
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {12523,12525},
        },
        [12521] = { -- Where in the World is Hemet Nesingwary?
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Take a ride to Sholazar Basin"), 0, {{"monster", 28160}}}},
        },
        [12527] = { -- Gluttonous Lurkers
            [questKeys.requiredSourceItems] = {38380},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Feed with Zul'Drak Rat"), 0, {{"monster", 28145}}}},
        },
        [12528] = { -- Playing Along
            [questKeys.preQuestSingle] = {},
        },
        [12529] = { -- The Ape Hunter's Slave
            [questKeys.requiredSourceItems] = {38619},
        },
        [12530] = { -- Tormenting the Softknuckles
            [questKeys.requiredSourceItems] = {38619},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Use Softknuckle Poker on Softknuckles"), 0, {{"monster", 28127}}}},
        },
        [12531] = { -- The Underground Menace
            [questKeys.requiredSourceItems] = {38621},
        },
        [12532] = { -- Flown the Coop!
            [questKeys.requiredSourceItems] = {38621},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {12533,12534},
        },
        [12533] = { -- The Wasp Hunter's Apprentice
            [questKeys.requiredSourceItems] = {38621},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {12529,12530},
        },
        [12534] = { -- The Sapphire Queen
            [questKeys.requiredSourceItems] = {38621},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {12529,12530},
        },
        [12536] = { -- A Rough Ride
            [questKeys.requiredSourceItems] = {38512},
            [questKeys.objectives] = {{{28298,nil,Questie.ICON_TYPE_TALK}}},
        },
        [12537] = { -- Lightning Definitely Strikes Twice
            [questKeys.requiredSourceItems] = {38512},
            [questKeys.objectives] = {nil,{{190502}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Place the Skyreach Crystal Clusters"), 0, {{"object", 300213}}}},
        },
        [12538] = { -- The Mist Isn't Listening
            [questKeys.requiredSourceItems] = {38512},
        },
        [12539] = { -- Hoofing It
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {12537,12538},
            [questKeys.requiredSourceItems] = {38512},
        },
        [12540] = { -- Just Following Orders
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Talk to Injured Rainspeaker Oracle"), 0, {{"monster", 28217}}}},
        },
        [12541] = { -- Troll Patrol: The Alchemist's Apprentice
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_TALK, l10n("Start the procedure"), 0, {{"monster", 28205}}},
                {nil, Questie.ICON_TYPE_OBJECT, l10n("Toss ingredients into the cauldron"), 0, {{"object", 190499}}},
            },
            [questKeys.objectives] = {nil,{{190499}}},
        },
        [12544] = { -- The Bones of Nozronn
            [questKeys.objectives] = {{{28256,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Use Soo-rahm's Incense"), 0, {{"object", 190507}}}},
            [questKeys.requiredSourceItems] = {},
        },
        [12545] = { -- The Cleansing Of Jintha'kalar
            [questKeys.preQuestSingle] = {},
        },
        [12546] = { -- Reclamation
            [questKeys.requiredSourceItems] = {},
        },
        [12548] = { -- The Etymidian
            [questKeys.extraObjectives] = {{{[zoneIDs.SHOLAZAR_BASIN]={{40.35,83.08,}}}, Questie.ICON_TYPE_EVENT, l10n("Travel through the Waygate"),}},
        },
        [12549] = { -- Dreadsaber Mastery: Becoming a Predator
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {12523,12525},
        },
        [12551] = { -- Crocolisk Mastery: The Trial
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {12520,12549},
        },
        [12555] = { -- A Tangled Skein
            [questKeys.objectives] = {{{28274,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.requiredSourceItems] = {},
        },
        [12557] = { -- Lab Work
            [questKeys.objectives] = {nil,nil,{{38386},{38339},{38340},{38346}}},
        },
        [12561] = { -- An Issue of Trust
            [questKeys.preQuestSingle] = {},
            [questKeys.requiredSpell] = 54197,
        },
        [12563] = { -- Troll Patrol
            [questKeys.finishedBy] = {{28039}},
            [questKeys.objectives] = {{{28042,nil,Questie.ICON_TYPE_TALK},{28044,nil,Questie.ICON_TYPE_TALK},{28043,nil,Questie.ICON_TYPE_TALK},{28205,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.exclusiveTo] = {12501,12587},
            [questKeys.childQuests] = {12541,12564,12568,12585},
        },
        [12564] = { -- Troll Patrol: Something for the Pain
            [questKeys.parentQuest] = 12563,
        },
        [12568] = { -- Troll Patrol: Done to Death
            [questKeys.parentQuest] = 12563,
            [questKeys.objectives] = {nil,nil,nil,nil,{{{28260,28156},28260,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.requiredSourceItems] = {},
        },
        [12569] = { -- Crocolisk Mastery: The Ambush
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use Sandfern Disguise near the fallen log"), 0, {{"object", 190545}}}},
            [questKeys.requiredSourceItems] = {},
        },
        [12570] = { -- Fortunate Misunderstandings
            [questKeys.triggerEnd] = {"Escort the Injured Rainspeaker Oracle to Rainspaker Canopy",{[zoneIDs.SHOLAZAR_BASIN]={{52.79,59.36}}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Start the escort"), 0, {{"monster", 28217}}}},
        },
        [12571] = { -- Make the Bad Snake Go Away
            [questKeys.requiredSourceItems] = {38622},
        },
        [12572] = { -- Gods like Shiny Things
            [questKeys.requiredSourceItems] = {38622},
        },
        [12573] = { -- Making Peace
            [questKeys.requiredSourceItems] = {38622},
            [questKeys.objectives] = {{{28315,nil,Questie.ICON_TYPE_TALK}}},
        },
        [12574] = { -- Back So Soon?
            [questKeys.requiredSourceItems] = {38623},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {12572,12573},
        },
        [12575] = { -- The Lost Mistwhisper Treasure
            [questKeys.requiredSourceItems] = {38623},
        },
        [12576] = { -- Forced Hand
            [questKeys.requiredSourceItems] = {38623},
        },
        [12577] = { -- Home Time!
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {12575,12576},
        },
        [12578] = { -- The Angry Gorloc
            [questKeys.requiredSourceItems] = {38624},
            [questKeys.triggerEnd] = {"Travel to Mosswalker Village.",{[zoneIDs.SHOLAZAR_BASIN]={{75.07,51.88}}}},
        },
        [12579] = { -- Lifeblood of the Mosswalker Shrine
            [questKeys.requiredSourceItems] = {38624},
        },
        [12580] = { -- The Mosswalker Savior
            [questKeys.requiredSourceItems] = {38624},
            [questKeys.objectives] = {{{28113,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [12584] = { -- Pure Evil
            [questKeys.preQuestSingle] = {12552},
        },
        [12585] = { -- Troll Patrol: Creature Comforts
            [questKeys.parentQuest] = 12563,
        },
        [12587] = { -- Troll Patrol
            [questKeys.objectives] = {{{28042,nil,Questie.ICON_TYPE_TALK},{28044,nil,Questie.ICON_TYPE_TALK},{28043,nil,Questie.ICON_TYPE_TALK},{28205,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.exclusiveTo] = {12501,12563},
            [questKeys.childQuests] = {12541,12588,12591,12594},
        },
        [12588] = { -- Troll Patrol: Can You Dig It?
            [questKeys.objectives] = {nil,{{190550}}},
            [questKeys.requiredSourceItems] = {},
        },
        [12589] = { -- Kick, What Kick?
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {12523,12525},
            [questKeys.objectives] = {{{28054,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.requiredSourceItems] = {},
        },
        [12591] = { -- Troll Patrol: Throwing Down
            [questKeys.objectives] = {nil,{{190555}}},
            [questKeys.requiredSourceItems] = {},
        },
        [12595] = { -- In Search of Bigger Game
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {12556,12558,12569},
        },
        [12596] = { -- Pa'Troll
            [questKeys.objectives] = {{{28042,nil,Questie.ICON_TYPE_TALK},{28044,nil,Questie.ICON_TYPE_TALK},{28043,nil,Questie.ICON_TYPE_TALK},{28205,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.preQuestSingle] = {12740},
            [questKeys.preQuestGroup] = {},
        },
        [12598] = { -- Throwing Down
            [questKeys.objectives] = {nil,{{190555}}},
            [questKeys.requiredSourceItems] = {},
        },
        [12601] = { -- The Alchemist's Apprentice
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_TALK, l10n("Start the procedure"), 0, {{"monster", 28205}}},
                {nil, Questie.ICON_TYPE_OBJECT, l10n("Toss ingredients into the cauldron"), 0, {{"object", 190499}}},
            },
            [questKeys.objectives] = {nil,{{190499}}},
        },
        [12602] = { -- The Alchemist's Apprentice
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_TALK, l10n("Start the procedure"), 0, {{"monster", 28205}}},
                {nil, Questie.ICON_TYPE_OBJECT, l10n("Toss ingredients into the cauldron"), 0, {{"object", 190499}}},
            },
            [questKeys.objectives] = {nil,{{190499}}},
        },
        [12603] = { -- Sharpening Your Talons
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {12556,12558,12569},
        },
        [12604] = { -- Congratulations!
            [questKeys.preQuestSingle] = {12501,12563,12587},
        },
        [12605] = { -- Securing the Bait
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {12556,12558,12569},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_SLAY, l10n("Break the egg"), 0, {{"monster", 28408}}}},
        },
        [12606] = { -- Cocooned!
            [questKeys.objectives] = {nil,nil,nil,nil,{{{28415,28413},28415}}},
        },
        [12607] = { -- A Mammoth Undertaking
            [questKeys.objectives] = {{{28374,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.requiredSourceItems] = {},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_INTERACT, l10n("Apply the harness"), 0, {{"monster", 28379}}}},
        },
        [12611] = { -- Returned Sevenfold
            [questKeys.requiredSourceItems] = {},
        },
        [12615] = { -- The Blessing of Zim'Torga
            [questKeys.preQuestSingle] = {12516},
        },
        [12620] = { -- The Lifewarden's Wrath
            [questKeys.extraObjectives] = {{{[zoneIDs.SHOLAZAR_BASIN]={{49.64,37.41,}}}, Questie.ICON_TYPE_EVENT, l10n("Use Freya's Horn atop of the Glimmering Pillar")}},
            [questKeys.requiredSourceItems] = {},
        },
        [12621] = { -- Freya's Pact
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Listen to what the Avatar of Freya has to say"), 0, {{"monster", 27801}}}},
        },
        [12622] = { -- The Leaders at Jin'Alai
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_SLAY, l10n("Kill Jin'Alai Trolls near a totem until their leaders appear"), 0, {{"monster", 28388},{"monster", 28504},{"object", 193768},{"object", 193769},{"object", 193770}}}},
        },
        [12629] = { -- You Can Run, But You Can't Hide
            [questKeys.preQuestSingle] = {12637},
            [questKeys.preQuestGroup] = {},
            [questKeys.exclusiveTo] = {12643},
            [questKeys.nextQuestInChain] = 12648,
        },
        [12630] = { -- Kickin' Nass and Takin' Manes
            [questKeys.objectives] = {{{28519,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.requiredSourceItems] = {},
        },
        [12631] = { -- An Invitation, of Sorts...
            [questKeys.startedBy] = {nil,nil,{38660}},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {},
            [questKeys.exclusiveTo] = {12633},
            [questKeys.nextQuestInChain] = 12637,
            [questKeys.requiredSourceItems] = {},
        },
        [12632] = { -- But First My Offspring
            [questKeys.objectives] = {{{28404}}},
            [questKeys.requiredSourceItems] = {},
        },
        [12633] = { -- Darkness Calling
            [questKeys.startedBy] = {nil,nil,{38673}},
            [questKeys.preQuestSingle] = {12238},
            [questKeys.preQuestGroup] = {},
            [questKeys.exclusiveTo] = {12631},
            [questKeys.nextQuestInChain] = 12638,
            [questKeys.requiredSourceItems] = {},
        },
        [12634] = { -- Some Make Lemonade, Some Make Liquor
            [questKeys.preQuestGroup] = {12520,12549},
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_OBJECT, l10n("Pull Sturdy Vines to reveal fruit"), 0, {{"object", 190622}}},
                {nil, Questie.ICON_TYPE_EVENT, l10n("Ask for a spare fruit"), 0, {{"monster", 28604}}},
            },
        },
        [12637] = { -- Near Miss
            [questKeys.objectives] = {{{28532,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.preQuestSingle] = {12631},
            [questKeys.preQuestGroup] = {},
            [questKeys.exclusiveTo] = {12638},
            [questKeys.nextQuestInChain] = 12629,
            [questKeys.requiredSourceItems] = {},
        },
        [12638] = { -- Close Call
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {12633,12238},
            [questKeys.exclusiveTo] = {12637},
            [questKeys.nextQuestInChain] = 12643,
            [questKeys.requiredSourceItems] = {},
        },
        [12641] = { -- Death Comes From On High
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Use Eye of Acherus Control Mechanism"), 0, {{"object", 191609}}}},
            [questKeys.objectives] = {{{28525,nil,Questie.ICON_TYPE_EVENT},{28543,nil,Questie.ICON_TYPE_EVENT},{28542,nil,Questie.ICON_TYPE_EVENT},{28544,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [12643] = { -- Silver Lining
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {12638,12238},
            [questKeys.exclusiveTo] = {12629},
            [questKeys.nextQuestInChain] = 12649,
        },
        [12644] = { -- Still At It
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Begin the distillation process"), 0, {{"monster", 28566}}}},
        },
        [12645] = { -- The Taste Test
            [questKeys.objectives] = {{{27986,nil,Questie.ICON_TYPE_INTERACT},{28047,nil,Questie.ICON_TYPE_INTERACT},{28568,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.requiredSourceItems] = {},
        },
        [12648] = { -- Dressing Down
            [questKeys.preQuestSingle] = {12629},
            [questKeys.preQuestGroup] = {},
            [questKeys.exclusiveTo] = {12649},
            [questKeys.nextQuestInChain] = 12661,
        },
        [12649] = { -- Suit Up!
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {12643,12238},
            [questKeys.exclusiveTo] = {12648},
            [questKeys.nextQuestInChain] = 12661,
        },
        [12651] = { -- Lakeside Landing
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {12558,12556,12592},
            [questKeys.exclusiveTo] = {12654},
            [questKeys.nextQuestInChain] = 12654,
        },
        [12652] = { -- Feedin' Da Goolz
            [questKeys.requiredRaces] = 2047,
            [questKeys.preQuestSingle] = {12629,12643},
            [questKeys.exclusiveTo] = {12713},
            [questKeys.objectives] = {{{28565,}}},
            [questKeys.requiredSourceItems] = {},
        },
        [12659] = { -- Scalps!
            [questKeys.objectives] = {nil,nil,nil,nil,{{{28465,28600},28622}}},
            [questKeys.requiredSourceItems] = {},
        },
        [12661] = { -- Infiltrating Voltarus
            [questKeys.preQuestSingle] = {12648,12649},
            [questKeys.preQuestGroup] = {},
            [questKeys.childQuests] = {12663,12664},
            [questKeys.exclusiveTo] = {},
            [questKeys.nextQuestInChain] = 12669,
            [questKeys.requiredSourceItems] = {38699},
            [questKeys.objectives] = {{{28503,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.extraObjectives] = {{{[zoneIDs.ZUL_DRAK]={{28.38,44.85}}}, Questie.ICON_TYPE_EVENT, l10n("Infiltrate Voltarus using Ensorcelled Choker")}},
        },
        [12662] = { -- Bringing Down Heb'Jin
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Use Heb'Jin's Drum to summon Heb'Jin"), 0, {{"object", 190695}}}},
            [questKeys.requiredSourceItems] = {},
        },
        [12663] = { -- Reunited
            [questKeys.preQuestSingle] = {12649},
            [questKeys.exclusiveTo] = {12664,12648},
            [questKeys.parentQuest] = 12661,
            [questKeys.objectives] = {{{28666,nil,Questie.ICON_TYPE_TALK}}},
        },
        [12664] = { -- Dark Horizon
            [questKeys.preQuestSingle] = {12648},
            [questKeys.exclusiveTo] = {12663,12649},
            [questKeys.parentQuest] = 12661,
            [questKeys.objectives] = {{{28666,nil,Questie.ICON_TYPE_TALK}}},
        },
        [12665] = { -- I Sense a Disturbance
            [questKeys.objectives] = {{{28671,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [12668] = { -- Foundation for Revenge
            [questKeys.objectives] = {nil,nil,nil,nil,{{{28747,28748},28747}}},
        },
        [12669] = { -- So Far, So Bad
            [questKeys.objectives] = {{{28503,nil,Questie.ICON_TYPE_TALK},{28739,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.requiredSourceItems] = {38699,41390},
        },
        [12670] = { -- The Scarlet Harvest
            [questKeys.preQuestSingle] = {12850},
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_MOUNT_UP,l10n("Take the gryphon to ground level"),0,{{"monster",29488}}}},
        },
        [12671] = { -- Reconnaissance Flight
            [questKeys.triggerEnd] = {"Reconnaissance Flight",{[zoneIDs.SHOLAZAR_BASIN]={{50.04,61.43}}}},
        },
        [12673] = { -- It Rolls Downhill
            [questKeys.objectives] = {nil,{{190716}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_INTERACT, l10n("Use Scepter of Suggestion to mind control Blight Geist"), 0, {{"monster", 28750}}}},
        },
        [12674] = { -- Hell Hath a Fury
            [questKeys.objectives] = {{{28752,nil,Questie.ICON_TYPE_INTERACT},{28754,nil,Questie.ICON_TYPE_INTERACT},{28756,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.requiredSourceItems] = {},
        },
        [12676] = { -- Sabotage
            [questKeys.requiredSourceItems] = {41390,38699},
            [questKeys.objectives] = {nil,{{190731}},nil,nil,{{{28503},28503,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.triggerEnd] = {"Learn Drakuru's secret",{[zoneIDs.ZUL_DRAK]={{27.07,46.16}}}},
        },
        [12677] = { -- Hazardous Materials
            [questKeys.requiredSourceItems] = {41390,38699},
            [questKeys.objectives] = {{{28503,nil,Questie.ICON_TYPE_TALK}},nil,{{39159}}},
        },
        [12680] = { -- Grand Theft Palomino
            [questKeys.objectives] = {{{28653,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_MOUNT_UP, l10n("Mount up"), 0, {{"monster", 28605},{"monster", 28606},{"monster", 28607}}}},
        },
        [12683] = { -- Burning to Help
            [questKeys.objectives] = {{{28003,},{28003}}},
            [questKeys.preQuestSingle] = {},
        },
        [12685] = { -- You Reap What You Sow
            [questKeys.objectives] = {{{28671}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use Quetz'lun's Ritual"), 0, {{"monster", 28672}}}},
            [questKeys.requiredSourceItems] = {},
        },
        [12686] = { -- Zero Tolerance
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use Scepter of Empowerment to mind control Servant of Drakuru",Questie.ICON_TYPE_INTERACT), 0, {{"monster", 28802}}}},
            [questKeys.requiredSourceItems] = {},
        },
        [12687] = { -- Into the Realm of Shadows
            [questKeys.objectives] = {{{28788,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_SLAY, l10n("Defeat Dark Rider of Acherus and take his horse"), 0, {{"monster", 28768}}},
                {nil, Questie.ICON_TYPE_MOUNT_UP, l10n("Mount up"), 0, {{"monster", 28782}}},
            },
        },
        [12688] = { -- Engineering a Disaster
            [questKeys.triggerEnd] = {"Escort Engineer Helice out of Swindlegrin's Dig",{[zoneIDs.SHOLAZAR_BASIN]={{37.29,50.59}}}},
        },
        [12690] = { -- Fuel for the Fire
            [questKeys.exclusiveTo] = {12710},
            [questKeys.requiredSourceItems] = {38699},
            [questKeys.objectives] = {{{28844},{28873,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use Scepter of Command",Questie.ICON_TYPE_INTERACT), 0, {{"monster", 28843}}}},
        },
        [12692] = { -- Return of the Lich Hunter
            [questKeys.requiredMinRep] = {1104,9000},
        },
        [12695] = { -- Return of the Friendly Dryskin
            [questKeys.requiredMinRep] = {1105,9000},
        },
        [12697] = { -- Gothik the Harvester
            [questKeys.preQuestGroup] = {12678,12679,12687,12733,},
            [questKeys.startedBy] = {{28377}},
            [questKeys.preQuestSingle] = {},
        },
        [12698] = { -- The Gift That Keeps On Giving
            [questKeys.objectives] = {{{28845,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_EVENT, l10n("Return Scarlet Ghouls"), 0, {{"monster", 28658}}},
                {nil, Questie.ICON_TYPE_INTERACT, l10n("Use the Gift of the Harvester on it"), 0, {{"monster", 28819},{"monster", 28822},{"monster", 28891}}},
            },
            [questKeys.requiredSourceItems] = {},
        },
        [12699] = { -- An Embarassing Incident
            [questKeys.preQuestSingle] = {12523},
            [questKeys.requiredSourceItems] = {},
        },
        [12701] = { -- Massacre At Light's Point
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_OBJECT, l10n("Climb inside the Inconspicuous Mine Car"), 0, {{"object", 190767}}},
                {nil, Questie.ICON_TYPE_OBJECT, l10n("Use the Scarlet Cannon"), 0, {{"monster", 28833}}},
            },
        },
        [12702] = { -- Chicken Party!
            [questKeys.requiredMinRep] = {1104,9000},
            [questKeys.requiredSourceItems] = {},
        },
        [12703] = { -- Kartak's Rampage
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Place the blood at the Shrine of Kartak"), 0, {{"object", 190782}}}},
            [questKeys.requiredMinRep] = {1104,9000},
        },
        [12704] = { -- Appeasing the Great Rain Stone
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_TALK, l10n("Talk to High-Oracle Soo-say to retrieve a Gorloc companion"), 0, {{"monster", 28027}}},
            },
            [questKeys.requiredMinRep] = {1105,9000},
            [questKeys.requiredSourceItems] = {38622,38623,38624},
        },
        [12705] = { -- Will of the Titans
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_EVENT, l10n("Use the Tainted Crystal at the Great Lightning Stone"), 0, {{"object", 190781}}},
            },
            [questKeys.requiredMinRep] = {1105,9000},
        },
        [12706] = { -- Victory At Death's Breach!
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_MOUNT_UP, l10n("Take the gryphon to Acherus"), 0, {{"monster", 29501}}}},
        },
        [12707] = { -- Wooly Justice
            [questKeys.objectives] = {{{28861,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use Medallion of Mam'toth to calm and ride an Enraged Mammoth"),0,{{"monster", 28851}}}},
            [questKeys.requiredSourceItems] = {},
        },
        [12710] = { -- Disclosure
            [questKeys.requiredSourceItems] = {38699},
            [questKeys.objectives] = {{{28948,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_EVENT, l10n("Open the coffin"), 0, {{"object", 190948}}},
                {{[zoneIDs.ZUL_DRAK]={{28.38,44.85}}}, Questie.ICON_TYPE_EVENT, l10n("Take the teleporter to Drakuru's upper chamber")},
            },
        },
        [12712] = { -- The Key of Warlord Zol'Maz
            [questKeys.requiredSourceItems] = {39313,39314,39315,39316},
        },
        [12713] = { -- Betrayal
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_INTERACT, l10n("Use the Scepter of Domination to control it"), 0, {{"monster", 28931}}},
                {nil, Questie.ICON_TYPE_EVENT, l10n("Go on top of the ziggurat with Drakuru"), 0, {{"monster", 28503}}},
                {nil, Questie.ICON_TYPE_EVENT, l10n("Defeat Drakuru"), 0, {{"monster", 28998}}},
                {nil, Questie.ICON_TYPE_OBJECT, l10n("After defeating Drakuru, go back down using this portal"), 0, {{"object", 202357}}},
            },
            [questKeys.requiredSourceItems] = {38699,41390,43059},
        },
        [12714] = { -- The Will Of The Lich King
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_MOUNT_UP,l10n("Take the gryphon to ground level"),0,{{"monster",29488}}}},
        },
        [12720] = { -- How To Win Friends And Influence Enemies
            [questKeys.objectives] = {nil,nil,nil,nil,{{{28610,28936,28939,28940},28610,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_INTERACT, l10n("Equip Keleseth's Persuaders and persuade Scarlet Crusaders"), 0, {{"monster", 28610},{"monster", 28936},{"monster", 28939},{"monster", 28940},}}},
            [questKeys.requiredSourceItems] = {39371},
        },
        [12721] = { -- Rampage
            [questKeys.objectives] = {{{28952,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Release Akali from his chains"), 0, {{"object", 191018}}}},
            [questKeys.requiredSourceItems] = {},
        },
        [12723] = { -- Behind Scarlet Lines
            [questKeys.preQuestGroup] = {12717,12720,12722},
        },
        [12726] = { -- Song of Wind and Water
            [questKeys.requiredMinRep] = {1105,9000},
            [questKeys.objectives] = {{{28862},{28858}}},
            [questKeys.extraObjectives] = {{{[zoneIDs.SHOLAZAR_BASIN]={{26.51,35.63}}}, Questie.ICON_TYPE_EVENT, l10n("Use Drums of the Tempest at Stormwright's Shelf"),}},
            [questKeys.requiredSourceItems] = {},
        },
        [12728] = { -- Monitoring the Rift: Winterfin Cavern
            [questKeys.requiredSourceItems] = {},
        },
        [12730] = { -- Convocation at Zol'Heb
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use the Prophet of Akali Convocation"), 0, {{"object", 191123}}}},
            [questKeys.requiredSourceItems] = {},
        },
        [12732] = { -- The Heartblood's Strength
            [questKeys.requiredMinRep] = {1104,9000},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Fill Rejek's Vial"), 0, {{"object", 191122}}}},
            [questKeys.requiredSourceItems] = {39573,39576},
        },
        [12733] = { -- Death's Challenge
            [questKeys.objectives] = {nil,nil,nil,nil,{{{28391,28394,28406},28391}}},
        },
        [12734] = { -- Rejek: First Blood
            [questKeys.objectives] = {{{28086,nil,Questie.ICON_TYPE_INTERACT},{28096,nil,Questie.ICON_TYPE_INTERACT}},nil,nil,nil,{{{28109,28110},28109,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.requiredMinRep] = {1104,9000},
        },
        [12735] = { -- A Cleansing Song
            [questKeys.extraObjectives] = {
                {{[zoneIDs.SHOLAZAR_BASIN]={{43,42}}}, Questie.ICON_TYPE_EVENT, l10n("Use Chime of Cleansing to summon Spirit of Atha"), 1},
                {{[zoneIDs.SHOLAZAR_BASIN]={{49,63}}}, Questie.ICON_TYPE_EVENT, l10n("Use Chime of Cleansing to summon Spirit of Ha-Khalan"), 2},
                {{[zoneIDs.SHOLAZAR_BASIN]={{46,74}}}, Questie.ICON_TYPE_EVENT, l10n("Use Chime of Cleansing to summon Spirit of Koosu"), 3},
            },
            [questKeys.requiredMinRep] = {1105,9000},
            [questKeys.requiredSourceItems] = {},
        },
        [12736] = { -- Song of Reflection
            [questKeys.requiredMinRep] = {1105,9000},
            [questKeys.requiredSourceItems] = {},
        },
        [12737] = { -- Song of Fecundity
            [questKeys.objectives] = {nil,{{191136,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.requiredMinRep] = {1105,9000},
            [questKeys.requiredSourceItems] = {},
        },
        [12739] = { -- A Special Surprise (Tauren)
            [questKeys.preQuestSingle] = {12738}
        },
        [12740] = { -- Parachutes for the Argent Crusade
            [questKeys.objectives] = {nil,nil,nil,nil,{{{28028,28029},28028,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.requiredSourceItems] = {},
        },
        [12741] = { -- Strength of the Tempest
            [questKeys.requiredMinRep] = {1104,9000},
        },
        [12742] = { -- A Special Surprise (Human)
            [questKeys.preQuestSingle] = {12738},
            [questKeys.requiredRaces] = raceIDs.HUMAN,
        },
        [12743] = { -- A Special Surprise (Night Elf)
            [questKeys.preQuestSingle] = {12738},
        },
        [12744] = { -- A Special Surprise (Dwarf)
            [questKeys.preQuestSingle] = {12738},
            [questKeys.requiredRaces] = raceIDs.DWARF,
        },
        [12745] = { -- A Special Surprise (Gnome)
            [questKeys.preQuestSingle] = {12738},
        },
        [12746] = { -- A Special Surprise (Draenei)
            [questKeys.preQuestSingle] = {12738},
        },
        [12747] = { -- A Special Surprise (Blood Elf)
            [questKeys.preQuestSingle] = {12738},
        },
        [12748] = { -- A Special Surprise (Orc)
            [questKeys.preQuestSingle] = {12738},
            [questKeys.requiredRaces] = raceIDs.ORC,
        },
        [12749] = { -- A Special Surprise (Troll)
            [questKeys.preQuestSingle] = {12738},
            [questKeys.requiredRaces] = raceIDs.TROLL,
        },
        [12750] = { -- A Special Surprise (Undead)
            [questKeys.preQuestSingle] = {12738},
        },
        [12752] = { -- Desperate Research
            [questKeys.startedBy] = {{19169,19175,19176,19177,19178,20102}},
        },
        [12753] = { -- A Desperate Alliance
            [questKeys.startedBy] = {{18927,19148,19171,19172,19173,20102}},
        },
        [12754] = { -- Ambush At The Overlook
            [questKeys.extraObjectives] = {{{[zoneIDs.PLAGUELANDS_THE_SCARLET_ENCLAVE]={{60.9,75.5}}}, Questie.ICON_TYPE_EVENT, l10n("Use the Makeshift Cover"),}},
            [questKeys.requiredSourceItems] = {},
        },
        [12757] = { -- Scarlet Armies Approach...
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_INTERACT, l10n("Use the Portal to Acherus"),0,{{"object", 191155}}}},
        },
        [12758] = { -- A Hero's Headgear
            [questKeys.requiredMinRep] = {1104,9000},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use Venture Co. Explosive on dead Stonewatcher"),0,{{"monster", 28877}}}},
        },
        [12759] = { -- Tools of War
            [questKeys.requiredMinRep] = {1104,9000},
        },
        [12760] = { -- Secret Strength of the Frenzyheart
            [questKeys.requiredMinRep] = {1104,9000},
            [questKeys.requiredSourceItems] = {},
        },
        [12761] = { -- Mastery of the Crystals
            [questKeys.requiredMinRep] = {1105,9000},
        },
        [12762] = { -- Power of the Great Ones
            [questKeys.requiredMinRep] = {1105,9000},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Charge the Dormant Polished Crystal at the exposed Lifeblood Pillar"),2,{{"object", 300224}}}},
            [questKeys.requiredSourceItems] = {},
        },
        [12771] = { -- Ironforge
            [questKeys.preQuestSingle] = {12753},
        },
        [12772] = { -- A Desperate Alliance
            [questKeys.startedBy] = {{18927,19148,19171,19172,19173,20102}},
        },
        [12773] = { -- Darnassus
            [questKeys.preQuestSingle] = {12772},
        },
        [12774] = { -- Stormwind
            [questKeys.preQuestSingle] = {12775},
        },
        [12775] = { -- A Desperate Alliance
            [questKeys.startedBy] = {{18927,19148,19171,19172,19173,20102}},
        },
        [12776] = { -- The Exodar
            [questKeys.preQuestSingle] = {12777},
        },
        [12777] = { -- A Desperate Alliance
            [questKeys.startedBy] = {{18927,19148,19171,19172,19173,20102}},
        },
        [12778] = { -- The Scarlet Apocalypse
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_MOUNT_UP,l10n("Take the gryphon to ground level"),0,{{"monster",29488}}}},
        },
        [12779] = { -- An End To All Things...
            [questKeys.extraObjectives] = {{{[zoneIDs.PLAGUELANDS_THE_SCARLET_ENCLAVE]={{53.5,36.7}}}, Questie.ICON_TYPE_EVENT, l10n("Use the Horn of the Frostbrood"),}},
            [questKeys.startedBy] = {{29110}},
            [questKeys.requiredSourceItems] = {},
        },
        [12782] = { -- Desperate Research
            [questKeys.startedBy] = {{19169,19175,19176,19177,19178,20102}},
        },
        [12783] = { -- Desperate Research
            [questKeys.startedBy] = {{19169,19175,19176,19177,19178,20102}},
        },
        [12784] = { -- Desperate Research
            [questKeys.startedBy] = {{19169,19175,19176,19177,19178,20102}},
        },
        [12785] = { -- Orgrimmar
            [questKeys.preQuestSingle] = {12783},
        },
        [12786] = { -- Thunder Bluff
            [questKeys.preQuestSingle] = {12784},
        },
        [12787] = { -- The Undercity
            [questKeys.preQuestSingle] = {12752},
        },
        [12788] = { -- Silvermoon
            [questKeys.preQuestSingle] = {12782},
        },
        [12797] = { -- Back Through the Waygate
            [questKeys.extraObjectives] = {{{[zoneIDs.UN_GORO_CRATER]={{50.54,7.74,}}}, Questie.ICON_TYPE_EVENT, l10n("Travel through the Waygate"),}},
        },
        [12801] = { -- The Light of Dawn
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Talk to Highlord Darion Mograine"), 0, {{"monster", 29173}}}},
            [questKeys.objectives] = {nil,{{191330}}},
        },
        [12802] = { -- My Heart is in Your Hands
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Drink Drakuru's Elixir after gathering 5 Desperate Mojo"),0,{{"object", 188358}}}},
            [questKeys.requiredSourceItems] = {35797,36739,36743},
        },
        [12803] = { -- Force of Nature
            [questKeys.requiredSpell] = 54197,
        },
        [12804] = { -- A Steak Fit for a Hunter
            [questKeys.preQuestSingle] = {12520},
        },
        [12805] = { -- Salvaging Life's Strength
            [questKeys.objectives] = {{{29124}}},
            [questKeys.requiredSourceItems] = {},
        },
        [12807] = { -- The Story Thus Far...
            [questKeys.objectives] = {{{29344}}},
        },
        [12808] = { -- A Desperate Alliance
            [questKeys.startedBy] = {{18927,19148,19171,19172,19173,20102}},
        },
        [12809] = { -- Ironforge
            [questKeys.preQuestSingle] = {12808},
        },
        [12810] = { -- Blood in the Water
            [questKeys.objectives] = {{{29392}}},
            [questKeys.requiredSourceItems] = {},
        },
        [12811] = { -- Desperate Research
            [questKeys.startedBy] = {{19169,19175,19176,19177,19178,20102}},
        },
        [12812] = { -- Orgrimmar
            [questKeys.preQuestSingle] = {12811},
        },
        [12813] = { -- From Their Corpses, Rise!
            [questKeys.objectives] = {nil,nil,nil,nil,{{{29329,29330,29333,29338},29398}}},
            [questKeys.preQuestSingle] = {12807},
            [questKeys.requiredSourceItems] = {},
        },
        [12814] = { -- You'll Need a Gryphon
            [questKeys.objectives] = {nil,nil,nil,nil,{{{29406,29405},29406}}},
        },
        [12815] = { -- No Fly Zone
            [questKeys.preQuestSingle] = {12814},
            [questKeys.requiredSourceItems] = {},
        },
        [12816] = { -- Investigate the Scourge of Silvermoon
            [questKeys.triggerEnd] = {"Investigate a circle",{[zoneIDs.EVERSONG_WOODS]={{56.5,52}}}},
        },
        [12817] = { -- Investigate the Scourge of Exodar
            [questKeys.triggerEnd] = {"Investigate a circle",{[zoneIDs.AZUREMYST_ISLE]={{34.9,45.5}}}},
        },
        [12820] = { -- A Delicate Touch
            [questKeys.requiredSourceItems] = {},
        },
        [12821] = { -- Cell Block Tango
            [questKeys.name] = "Cell Block Tango",
            [questKeys.triggerEnd] = {"Garm Teleporter Activated",{[zoneIDs.STORM_PEAKS]={{50.7,81.9}}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Activate the teleporter"), 0, {{"object", 191574}}}},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {12820,12828,12832},
            [questKeys.sourceItemId] = 40731,
        },
        [12823] = { -- A Flawless Plan
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Place Hardpacked Explosive Bundle at Frostgut's Altar"), 0, {{"object", 191842}}}},
            [questKeys.requiredSourceItems] = {},
        },
        [12828] = { -- Ample Inspiration
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_OBJECT, l10n("Retrieve U.D.E.D."), 0, {{"object", 191553}}},
                {nil, Questie.ICON_TYPE_EVENT, l10n("Use U.D.E.D on Ironwool Mammoth"), 0, {{"monster", 29402}}},
            },
        },
        [12831] = { -- Only Partly Forgotten
            [questKeys.preQuestSingle] = {},
        },
        [12832] = { -- Bitter Departure
            [questKeys.triggerEnd] = {"Escort the Injured Goblin Miner to K3.",{[zoneIDs.STORM_PEAKS]={{40.2,79}}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Start the escort"), 0, {{"monster", 29434}}}},
        },
        [12833] = { -- Overstock
            [questKeys.requiredSourceItems] = {},
        },
        [12838] = { -- Intelligence Gathering
            [questKeys.preQuestSingle] = {12807},
        },
        [12839] = { -- The Grand (Admiral's) Plan
            [questKeys.preQuestSingle] = {12807},
        },
        [12842] = { -- Runeforging: Preparation For Battle
            [questKeys.objectives] = {nil,{{191746}}},
        },
        [12847] = { -- Second Chances
            [questKeys.triggerEnd] = {"Arete's Gate summoned",{[zoneIDs.ICECROWN]={{9.53,47.01}}}},
            [questKeys.requiredSourceItems] = {},
        },
        [12848] = { -- The Endless Hunger
            [questKeys.extraObjectives] = {{nil,Questie.ICON_TYPE_INTERACT,l10n("Unlock the chains"),0,{{"object",191577}}}},
            [questKeys.requiredSourceItems] = {},
        },
        [12851] = { -- Bearly Hanging On
            [questKeys.name] = "Bearly Hanging On",
            [questKeys.objectives] = {{{29358},{29351}}},
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_MOUNT_UP, l10n("Mount Icefang"), 0, {{"monster", 29598}}},
            },
        },
        [12852] = { -- The Admiral Revealed
            [questKeys.objectives] = {{{29621}}},
            [questKeys.requiredSourceItems] = {},
        },
        [12855] = { -- Sniffing Out the Perpetrator
            [questKeys.requiredSourceItems] = {40971},
            [questKeys.preQuestSingle] = {12854},
            [questKeys.extraObjectives] = {{{[zoneIDs.STORM_PEAKS]={{36.4,64.2}}}, Questie.ICON_TYPE_EVENT, l10n("Use Frosthound's Collar at the Abandoned Camp")}},
        },
        [12856] = { -- Cold Hearted
            [questKeys.objectives] = {{{29639,nil,Questie.ICON_TYPE_INTERACT},{29708,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.extraObjectives] = {
                {{[zoneIDs.STORM_PEAKS]={{62.00,59.50}}}, Questie.ICON_TYPE_EVENT, l10n("Fly freed Proto-Drakes to safety while carrying rescued Brunnhildar Prisoners"),},
            },
        },
        [12858] = { -- Pieces to the Puzzle
            [questKeys.sourceItemId] = 40971,
            [questKeys.requiredSourceItems] = {41130},
        },
        [12859] = { -- This Just In: Fire Still Hot!
            [questKeys.requiredSourceItems] = {},
        },
        [12860] = { -- Data Mining
            [questKeys.requiredSourceItems] = {40971},
            [questKeys.objectives] = {{{29746,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [12862] = { -- When All Else Fails
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Talk to Ricket for transportation"), 0, {{"monster", 29428}}}},
        },
        [12864] = { -- Missing Scouts
            [questKeys.objectives] = {{{29811,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [12865] = { -- Loyal Companions
            [questKeys.objectives] = {{{29854,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.preQuestSingle] = {12863},
        },
        [12869] = { -- Pushed Too Far
            [questKeys.preQuestGroup] = {12867,13417},
        },
        [12871] = { -- Aid from the Explorers' League
            [questKeys.preQuestSingle] = {12872},
        },
        [12872] = { -- Norgannon's Shell
            [questKeys.requiredSourceItems] = {40971},
        },
        [12874] = { -- Fervor of the Frostborn
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Talk to Fjorlin Frostbrow"), 0, {{"monster", 29732}}}},
        },
        [12876] = { -- Unwelcome Guests
            [questKeys.preQuestSingle] = {12874},
        },
        [12885] = { -- The Exiles of Ulduar
            [questKeys.preQuestSingle] = {12872},
            [questKeys.exclusiveTo] = {12930},
            [questKeys.sourceItemId] = 40971,
        },
        [12886] = { -- The Drakkensryd
            [questKeys.objectives] = {{{29694}}},
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_EVENT, l10n("Use Hyldnir Harpoon to land on nearby Proto-Drakes"), 0, {{"monster", 29625}}},
                {nil, Questie.ICON_TYPE_EVENT, l10n("Use Hyldnir Harpoon on Column Ornaments to dismount"), 0, {{"monster", 29754}}},
            },
            [questKeys.requiredSourceItems] = {},
        },
        [12887] = { -- It's All Fun and Games
            [questKeys.objectives] = {{{29747}}},
            [questKeys.requiredSourceItems] = {},
        },
        [12889] = { -- The Prototype Console
            [questKeys.requiredSkill] = {202,400},
        },
        [12892] = { -- It's All Fun and Games
            [questKeys.objectives] = {{{29747}}},
            [questKeys.requiredSourceItems] = {},
        },
        [12893] = { -- Free Your Mind
            [questKeys.objectives] = {{{29769},{29770},{29840}}},
            [questKeys.requiredSourceItems] = {},
        },
        [12896] = { -- If He Cannot Be Turned
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_OBJECT, l10n("Tamper with General's Weapon Rack to summon General Lightsbane"), 0, {{"object", 191778},{"object", 191779}}},
            },
        },
        [12897] = { -- If He Cannot Be Turned
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_OBJECT, l10n("Tamper with General's Weapon Rack to summon General Lightsbane"), 0, {{"object", 191778},{"object", 191779}}},
            },
        },
        [12906] = { -- Discipline
            [questKeys.objectives] = {{{30146,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.requiredSourceItems] = {},
        },
        [12910] = { -- Sniffing Out the Perpetrator
            [questKeys.sourceItemId] = 40971,
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_MOUNT_UP, l10n("Mount Frostbite to track scent"), 0, {{"monster", 29857}}},
            },
        },
        [12913] = { -- Speak Orcish, Man!
            [questKeys.sourceItemId] = 40971,
        },
        [12915] = { -- Mending Fences
            [questKeys.requiredSourceItems] = {41506},
        },
        [12916] = { -- Our Only Hope
            [questKeys.objectives] = {nil,{{420048}}},
            [questKeys.requiredSourceItems] = {},
        },
        [12919] = { -- The Storm King's Vengeance
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_TALK, l10n("Let Gymer know you're ready"), 0, {{"monster", 29647}}},
                {{[zoneIDs.ZUL_DRAK]={{26.71,57.29}}}, Questie.ICON_TYPE_EVENT, l10n("Slay Scourge while riding Gymer"),},
            },
        },
        [12920] = { -- Catching up with Brann
            [questKeys.preQuestSingle] = {12917},
        },
        [12924] = { -- Forging an Alliance
            [questKeys.objectives] = {{{30099,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.requiredSourceItems] = {},
        },
        [12925] = { -- Aberrations
            [questKeys.preQuestSingle] = {12905},
        },
        [12926] = { -- Pieces of the Puzzle
            [questKeys.sourceItemId] = 40971,
            [questKeys.requiredSourceItems] = {41130},
        },
        [12927] = { -- Data Mining
            [questKeys.requiredSourceItems] = {40971},
            [questKeys.objectives] = {{{29746,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [12928] = { -- Norgannon's Shell
            [questKeys.requiredSourceItems] = {40971},
        },
        [12929] = { -- The Earthen of Ulduar
            [questKeys.preQuestSingle] = {12928},
            [questKeys.exclusiveTo] = {12930},
            [questKeys.sourceItemId] = 40971,
        },
        [12930] = { -- Rare Earth
            [questKeys.requiredSourceItems] = {},
        },
        [12932] = { -- The Amphitheater of Anguish: Yggdras!
            [questKeys.objectives] = {{{30014}}},
            [questKeys.exclusiveTo] = {12954,9977}, -- This is the version of the quest you get if you have NOT completed 9977
            [questKeys.nextQuestInChain] = 12933,
        },
        [12933] = { -- The Amphitheater of Anguish: Magnataur!
            [questKeys.objectives] = {{{30017}}},
            [questKeys.preQuestSingle] = {12932,12954},
            [questKeys.nextQuestInChain] = 12934,
        },
        [12934] = { -- The Amphitheater of Anguish: From Beyond!
            [questKeys.objectives] = {nil,nil,nil,nil,{{{30019,30024,30025,30026},30019}}},
            [questKeys.nextQuestInChain] = 12935,
        },
        [12935] = { -- The Amphitheater of Anguish: Tuskarrmageddon!
            [questKeys.objectives] = {{{30020}}},
            [questKeys.nextQuestInChain] = 12936,
        },
        [12936] = { -- The Amphitheater of Anguish: Korrak the Bloodrager!
            [questKeys.objectives] = {{{30023}}},
            [questKeys.nextQuestInChain] = 12948,
        },
        [12937] = { -- Relief for the Fallen
            [questKeys.requiredSourceItems] = {},
        },
        [12939] = { -- Honor Challenge
            [questKeys.objectives] = {{{30037}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Use the Challenge Flag on sparring Mjordin Combatants"), 0, {{"monster", 30037}}}},
            [questKeys.requiredSourceItems] = {},
        },
        [12940] = { -- Candy Bucket
            [questKeys.startedBy] = {nil,{191878}},
            [questKeys.finishedBy] = {nil,{191878}},
            [questKeys.requiredRaces] = raceIDs.NONE,
        },
        [12941] = { -- Candy Bucket
            [questKeys.startedBy] = {nil,{191879}},
            [questKeys.finishedBy] = {nil,{191879}},
            [questKeys.requiredRaces] = raceIDs.NONE,
        },
        [12942] = { -- Off With Their Black Wings
            [questKeys.preQuestSingle] = {12905},
        },
        [12943] = { -- Shadow Vault Decree
            [questKeys.requiredSourceItems] = {},
        },
        [12944] = { -- Candy Bucket
            [questKeys.startedBy] = {nil,{191882}},
            [questKeys.finishedBy] = {nil,{191882}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [12945] = { -- Candy Bucket
            [questKeys.startedBy] = {nil,{191883}},
            [questKeys.finishedBy] = {nil,{191883}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [12946] = { -- Candy Bucket
            [questKeys.startedBy] = {nil,{191880}},
            [questKeys.finishedBy] = {nil,{191880}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [12947] = { -- Candy Bucket
            [questKeys.startedBy] = {nil,{191881}},
            [questKeys.finishedBy] = {nil,{191881}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [12948] = { -- The Champion of Anguish
            [questKeys.objectives] = {{{30022}}},
        },
        [12950] = { -- Candy Bucket
            [questKeys.startedBy] = {nil,{192018}},
            [questKeys.finishedBy] = {nil,{192018}},
            [questKeys.requiredRaces] = raceIDs.NONE,
        },
        [12953] = { -- Valkyrion Must Burn
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Use Harpoon Guns to burn Dry Haystacks"), 0, {{"monster", 30066}}}},
            [questKeys.requiredSourceItems] = {},
        },
        [12954] = { -- The Amphitheater of Anguish: Yggdras!
            [questKeys.objectives] = {{{30014}}},
            [questKeys.exclusiveTo] = {12932},
            [questKeys.nextQuestInChain] = 12933,
        },
        [12957] = { -- Slaves of the Stormforged
            [questKeys.objectives] = {{{29384},{29369}}},
        },
        [12966] = { -- You Can't Miss Him
            [questKeys.preQuestGroup] = {12915,12956},
            [questKeys.requiredMinRep] = {1119,0},
        },
        [12967] = { -- Battling the Elements
            [questKeys.objectives] = {{{30120}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Ride Snorri"), 0, {{"monster", 30123}}}},
        },
        [12968] = { -- Yulda's Folly
            [questKeys.preQuestSingle] = {12905},
        },
        [12970] = { -- The Hyldsmeet
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_TALK, l10n("Listen to Lok'lira's proposal"), 0, {{"monster", 29975}}},
            },
        },
        [12973] = { -- The Brothers Bronzebeard
            [questKeys.objectives] = {{{30405,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Get in Brann's Flying Machine"), 0, {{"monster", 30134}}}},
            [questKeys.preQuestSingle] = {12880},
        },
        [12974] = { -- The Champion's Call!
            [questKeys.exclusiveTo] = {12954},
            [questKeys.nextQuestInChain] = 12932,
        },
        [12975] = { -- In Memoriam
            [questKeys.preQuestSingle] = {12924},
        },
        [12977] = { -- Hodir's Call
            [questKeys.name] = "Hodir's Call",
            [questKeys.objectives] = {{{29974,nil,Questie.ICON_TYPE_INTERACT}},nil,nil,nil,{{{30144,30135},30144}}},
            [questKeys.preQuestSingle] = {12976},
            [questKeys.requiredSourceItems] = {},
        },
        [12978] = { -- Facing the Storm
            [questKeys.objectives] = {nil,nil,nil,nil,{{{29370,29374,29380},29370}}},
        },
        [12979] = { -- Armor of Darkness
            [questKeys.objectives] = {nil,nil,{{42204}}},
        },
        [12981] = { -- Hot and Cold
            [questKeys.preQuestSingle] = {12967},
        },
        [12982] = { -- Ebon Blade Prisoners
            [questKeys.objectives] = {nil,nil,nil,nil,{{{30186,30194,30195,30196},30186}}},
        },
        [12983] = { -- The Last of Her Kind
            [questKeys.requiredSourceItems] = {},
        },
        [12984] = { -- Valduran the Stormborn
            [questKeys.requiredSourceItems] = {},
        },
        [12985] = { -- Forging a Head
            [questKeys.requiredMinRep] = {1119,3000},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use Diamond Tipped Pick on the corpses of Dead Iron Giants"), 0, {{"monster", 29914},{"monster", 30163}}}},
            [questKeys.requiredSourceItems] = {},
        },
        [12986] = { -- Fate of the Titans
            [questKeys.requiredSourceItems] = {},
        },
        [12987] = { -- Placing Hodir's Helm
            [questKeys.name] = "Placing Hodir's Helm",
            [questKeys.requiredMinRep] = {1119,3000},
            [questKeys.requiredSourceItems] = {},
        },
        [12988] = { -- Destroy the Forges!
            [questKeys.requiredSourceItems] = {},
        },
        [12994] = { -- Spy Hunter
            [questKeys.requiredMinRep] = {1119,9000},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use Ethereal Worg's Fang"), 0, {{"monster", 32569}}}},
            [questKeys.requiredSourceItems] = {},
        },
        [12995] = { -- Leave Our Mark
            [questKeys.objectives] = {nil,nil,nil,nil,{{{29915,29919,30037,30243,30250,30409,30475,30483,30484,30632,30725,30751,29880},29880,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.requiredSourceItems] = {},
        },
        [12996] = { -- The Warm-Up
            [questKeys.objectives] = {{{29352}}},
            [questKeys.requiredSourceItems] = {},
        },
        [12997] = { -- Into the Pit
            [questKeys.requiredSourceItems] = {},
        },
        [12998] = { -- The Heart of the Storm
            [questKeys.objectives] = {nil,{{192181}}},
        },
        [13000] = { -- Emergency Measures
            [questKeys.requiredSourceItems] = {},
        },
        [13001] = { -- Forging Hodir's Spear
            [questKeys.name] = "Forging Hodir's Spear",
            [questKeys.requiredMinRep] = {1119,9000},
        },
        [13003] = { -- How To Slay Your Dragon
            [questKeys.name] = "How To Slay Your Dragon",
            [questKeys.objectives] = {{{30275,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.preQuestSingle] = {13001},
            [questKeys.requiredSourceItems] = {},
        },
        [13005] = { -- The Earthen Oath
            [questKeys.objectives] = {{{29984},{29978}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_SLAY, l10n("Use the Horn of the Peaks and call on the Earthen to defeat Iron Dwarves and Iron Sentinels"), 0, {{"monster", 29984},{"monster",29978}}}},
            [questKeys.preQuestSingle] = {13057},
        },
        [13006] = { -- A Viscous Cleaning
            [questKeys.name] = "A Viscous Cleaning",
            [questKeys.requiredMinRep] = {1119,3000},
            [questKeys.preQuestSingle] = {12987},
        },
        [13007] = { -- The Iron Colossus
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_MOUNT_UP, l10n("Mount Tamed Jormungar to fight Iron Colossus"),0,{{"monster", 30301},{"object", 192262}}}},
        },
        [13008] = { -- Scourge Tactics
            [questKeys.objectives] = {nil,nil,nil,nil,{{{30273,30268,30274},30273}}},
        },
        [13010] = { -- Krolmir, Hammer of Storms
            [questKeys.objectives] = {{{30105}},nil,nil,{1119,3000}},
        },
        [13011] = { -- Culling Jorcuttar
            [questKeys.name] = "Culling Jorcuttar",
            [questKeys.objectivesText] = {"King Jokkum in Dun Niffelem wants you to slay Jorcuttar in Hibernal Cavern."},
            [questKeys.requiredMinRep] = {1119,3000},
            [questKeys.requiredSourceItems] = {42733},
            [questKeys.extraObjectives] = {{{[zoneIDs.STORM_PEAKS]={{54.71,60.79}}}, Questie.ICON_TYPE_EVENT, l10n("Place Icemaw Bear Flank"), 0}},
        },
        [13012] = { -- Sardis the Elder
            [questKeys.startedBy] = {{30348}},
            [questKeys.finishedBy] = {{30348}},
        },
        [13013] = { -- Beldak the Elder
            [questKeys.startedBy] = {{30357}},
            [questKeys.finishedBy] = {{30357}},
        },
        [13014] = { -- Morthie the Elder
            [questKeys.startedBy] = {{30358}},
            [questKeys.finishedBy] = {{30358}},
        },
        [13015] = { -- Fargal the Elder
            [questKeys.startedBy] = {{30359}},
            [questKeys.finishedBy] = {{30359}},
        },
        [13016] = { -- Northal the Elder
            [questKeys.startedBy] = {{30360}},
            [questKeys.finishedBy] = {{30360}},
        },
        [13017] = { -- Jarten the Elder
            [questKeys.startedBy] = {{30531}},
            [questKeys.finishedBy] = {{30531}},
        },
        [13018] = { -- Sandrene the Elder
            [questKeys.startedBy] = {{30362}},
            [questKeys.finishedBy] = {{30362}},
        },
        [13019] = { -- Thoim the Elder
            [questKeys.startedBy] = {{30363}},
            [questKeys.finishedBy] = {{30363}},
        },
        [13020] = { -- Stonebeard the Elder
            [questKeys.startedBy] = {{30375}},
            [questKeys.finishedBy] = {{30375}},
        },
        [13021] = { -- Igasho the Elder
            [questKeys.startedBy] = {{30536}},
            [questKeys.finishedBy] = {{30536}},
        },
        [13022] = { -- Nurgen the Elder
            [questKeys.startedBy] = {{30533}},
            [questKeys.finishedBy] = {{30533}},
        },
        [13023] = { -- Kilias the Elder
            [questKeys.startedBy] = {{30534}},
            [questKeys.finishedBy] = {{30534}},
        },
        [13024] = { -- Wanikaya the Elder
            [questKeys.startedBy] = {{30365}},
            [questKeys.finishedBy] = {{30365}},
        },
        [13025] = { -- Lunaro the Elder
            [questKeys.startedBy] = {{30367}},
            [questKeys.finishedBy] = {{30367}},
        },
        [13026] = { -- Bluewolf the Elder
            [questKeys.startedBy] = {{30368}},
            [questKeys.finishedBy] = {{30368}},
        },
        [13027] = { -- Tauros the Elder
            [questKeys.startedBy] = {{30369}},
            [questKeys.finishedBy] = {{30369}},
        },
        [13028] = { -- Graymane the Elder
            [questKeys.startedBy] = {{30370}},
            [questKeys.finishedBy] = {{30370}},
        },
        [13029] = { -- Pamuya the Elder
            [questKeys.startedBy] = {{30371}},
            [questKeys.finishedBy] = {{30371}},
        },
        [13030] = { -- Whurain the Elder
            [questKeys.startedBy] = {{30372}},
            [questKeys.finishedBy] = {{30372}},
        },
        [13031] = { -- Skywarden the Elder
            [questKeys.startedBy] = {{30373}},
            [questKeys.finishedBy] = {{30373}},
        },
        [13032] = { -- Muraco the Elder
            [questKeys.startedBy] = {{30374}},
            [questKeys.finishedBy] = {{30374}},
        },
        [13033] = { -- Arp the Elder
            [questKeys.startedBy] = {{30364}},
            [questKeys.finishedBy] = {{30364}},
        },
        [13034] = { -- The Witness and the Hero
            [questKeys.preQuestSingle] = {},
        },
        [13035] = { -- Loken's Lackeys
            [questKeys.preQuestSingle] = {13057},
        },
        [13037] = { -- Memories of Stormhoof
            [questKeys.objectives] = {{{30395}}},
        },
        [13038] = { -- Distortions in Time
            [questKeys.objectives] = {{{30448}}},
            [questKeys.preQuestSingle] = {13034},
        },
        [13039] = { -- Defending The Vanguard
            [questKeys.preQuestSingle] = {13036},
        },
        [13040] = { -- Curing The Incurable
            [questKeys.preQuestSingle] = {13036},
        },
        [13042] = { -- Deep in the Bowels of The Underhalls
            [questKeys.preQuestSingle] = {12999},
            [questKeys.objectives] = {{{30409,nil,Questie.ICON_TYPE_EVENT},{30409}}},
        },
        [13043] = { -- The Sum is Greater than the Parts
            [questKeys.preQuestSingle] = {12999},
            [questKeys.startedBy] = {nil,nil,{42772}},
            [questKeys.requiredSourceItems] = {},
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_MOUNT_UP, l10n("Mount Nergeld"), 0, {{"monster", 30403}}},
            },
        },
        [13044] = { -- If There Are Survivors...
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {13008,13039,13040},
        },
        [13045] = { -- Into The Wild Green Yonder
            [questKeys.objectives] = {{{30407,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_MOUNT_UP, l10n("Mount Argent Skytalon"), 0, {{"monster", 30500}}},
                {{[zoneIDs.ICECROWN]={{86.85,76.61}}}, Questie.ICON_TYPE_EVENT, l10n("Drop Off Captured Crusader"), 0},
            },
        },
        [13046] = { -- Feeding Arngrim
            [questKeys.objectives] = {{{30422}}},
            [questKeys.requiredMinRep] = {1119,21000},
            [questKeys.requiredSourceItems] = {},
        },
        [13047] = { -- The Reckoning
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {13035,13005},
            [questKeys.objectives] = {{{30399,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [13048] = { -- Where Time Went Wrong
            [questKeys.objectives] = {{{80000}}},
            [questKeys.preQuestGroup] = {13037,13038},
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_OBJECT, l10n("Attune the Lorehammer"), 0, {{"object", 192541},{"object", 192542},{"object", 192543},{"object", 192544},{"object", 192545},{"object", 192546}}},
            },
        },
        [13049] = { -- The Hero's Arms
            [questKeys.preQuestGroup] = {13037,13038},
        },
        [13051] = { -- Territorial Trespass
            [questKeys.requiredSourceItems] = {},
        },
        [13058] = { -- Changing the Wind's Course
            [questKeys.preQuestGroup] = {13048,13049},
            [questKeys.extraObjectives] = {
                {{[zoneIDs.STORM_PEAKS]={{64.4,46.7}}}, Questie.ICON_TYPE_OBJECT, l10n("Use the Lorehammer to travel back in time"), 0},
                {nil, Questie.ICON_TYPE_OBJECT, l10n("Defeat the North Wind"), 0, {{"monster", 30474}}},
            },
        },
        [13059] = { -- Revenge for the Vargul
            [questKeys.objectives] = {nil,{{192560}},nil,nil,{{{30475},32821}}},
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_SLAY, l10n("Defeat Volgur"), 0, {{"monster", 30483}}},
                {nil, Questie.ICON_TYPE_SLAY, l10n("Defeat Brita"), 0, {{"monster", 30484}}},
            },
            [questKeys.requiredSourceItems] = {},
        },
        [13060] = { -- When All Else Fails
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_TALK, l10n("Talk to Ricket for transportation"), 0, {{"monster", 29428}}},
            },
        },
        [13064] = { -- Sibling Rivalry
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_TALK, l10n("Listen to Thorim's history"), 0, {{"monster", 29445}}},
            },
        },
        [13065] = { -- Ohanzee the Elder
            [questKeys.startedBy] = {{30537}},
            [questKeys.finishedBy] = {{30537}},
        },
        [13066] = { -- Yurauk the Elder
            [questKeys.startedBy] = {{30535}},
            [questKeys.finishedBy] = {{30535}},
        },
        [13067] = { -- Chogan'gada the Elder
            [questKeys.startedBy] = {{30538}},
            [questKeys.finishedBy] = {{30538}},
        },
        [13068] = { -- A Tale of Valor
            [questKeys.preQuestSingle] = {13141},
        },
        [13069] = { -- Shoot 'Em Up
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_MOUNT_UP, l10n("Mount up"), 0, {{"monster", 30337}}}},
        },
        [13071] = { -- Vile Like Fire!
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_MOUNT_UP, l10n("Mount up"), 0, {{"monster", 30272}}}},
        },
        [13073] = { -- The Keeper's Favor
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Speak to Arch Druid Lilliandra for transportation to Moonglade"), 0, {{"monster", 30630}}}},
        },
        [13086] = { -- The Last Line Of Defense
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_MOUNT_UP, l10n("Mount Argent Cannon"), 0, {{"monster", 30236}}},
            },
        },
        [13091] = { -- The Art of Being a Water Terror
            [questKeys.objectives] = {nil,nil,nil,nil,{{{30725,29880,30632,30243,30250},30644}}},
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_OBJECT, l10n("Possess a Water Terror"), 0, {{"object", 192774}}},
            },
        },
        [13092] = { -- Reading the Bones
            [questKeys.preQuestSingle] = {12999},
            [questKeys.specialFlags] = specialFlags.NONE,
        },
        [13093] = { -- Reading the Bones
            [questKeys.preQuestSingle] = {13092},
        },
        [13098] = { -- For Posterity
            [questKeys.preQuestSingle] = {},
        },
        [13106] = { -- Blackwatch
            [questKeys.preQuestSingle] = {12896,12897},
            [questKeys.exclusiveTo] = {13119,13120},
        },
        [13109] = { -- Diametrically Opposed
            [questKeys.preQuestSingle] = {13047},
        },
        [13110] = { -- The Restless Dead
            [questKeys.objectives] = {{{30202}}},
            [questKeys.preQuestSingle] = {13104},
            [questKeys.requiredSourceItems] = {},
        },
        [13117] = { -- Where Are They Coming From?
            [questKeys.preQuestSingle] = {},
        },
        [13118] = { -- The Purging Of Scourgeholme
            [questKeys.preQuestSingle] = {13104},
        },
        [13120] = { -- Death's Gaze
            [questKeys.requiredSourceItems] = {},
        },
        [13121] = { -- Through the Eye
            [questKeys.objectives] = {nil,{{192861}}},
        },
        [13122] = { -- The Scourgestone
            [questKeys.preQuestSingle] = {13104},
        },
        [13125] = { -- The Air Stands Still
            [questKeys.preQuestGroup] = {13122,13118},
            [questKeys.requiredSourceItems] = {},
        },
        [13129] = { -- Head Games
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Dip Kurzel's Blouse Scrap on the remains of Novos the Summoner"), 0, {{"monster", 26631}}}},
        },
        [13130] = { -- The Stone That Started A Revolution
            [questKeys.preQuestSingle] = {13104},
        },
        [13133] = { -- Find the Ancient Hero
            [questKeys.objectives] = {{{30886}}},
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_TALK, l10n("Wake Slumbering Mjordin until you find Iskalder"), 0, {{"monster", 30718}}},
                {nil, Questie.ICON_TYPE_EVENT, l10n("Iskalder delivered to The Bone Witch"), 0, {{"monster", 30232}}},
            },
            [questKeys.requiredSourceItems] = {},
        },
        [13134] = { -- Spill Their Blood
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {13119,13120},
        },
        [13135] = { -- It Could Kill Us All
            [questKeys.preQuestSingle] = {13104},
        },
        [13136] = { -- Jagged Shards
            [questKeys.startedBy] = {nil,nil,{43242}},
            [questKeys.objectives] = {nil,nil,{{43259}}},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {13119,13120},
        },
        [13137] = { -- Not-So-Honorable Combat
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_OBJECT, l10n("Use the Battlescar Signal Fire to summon Iskalder"), 0, {{"object", 193024}}},
            },
        },
        [13138] = { -- I'm Smelting... Smelting!
            [questKeys.preQuestSingle] = {13136},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Use Bag of Jagged Shards near Malykriss Furnace"), 0, {{"object", 193004}}}},
            [questKeys.requiredSourceItems] = {},
        },
        [13139] = { -- Into The Frozen Heart Of Northrend
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {13125,13130,13135},
        },
        [13140] = { -- The Runesmiths of Malykriss
            [questKeys.preQuestSingle] = {13136},
        },
        [13141] = { -- The Battle For Crusaders' Pinnacle
            [questKeys.objectives] = {{{30989,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Plant the Blessed Banner of the Crusade"), 0, {{"object", 193003}}}},
            [questKeys.requiredSourceItems] = {},
        },
        [13142] = { -- Banshee's Revenge
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_OBJECT, l10n("Blow the War Horn of Jotunheim to challenge Overthane Balargarde"), 0, {{"object", 193028}}},
            },
        },
        [13143] = { -- New Recruit
            [questKeys.objectives] = {{{30894}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Lead a subdued Lithe Stalker to the cliff above Vereth the Cunning"), 0, {{"monster", 31049}}}},
            [questKeys.requiredSourceItems] = {},
        },
        [13144] = { -- Killing Two Scourge With One Skeleton
            [questKeys.objectives] = {nil,nil,nil,nil,{{{30689,31048},30689}}},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {13152,13211},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Free Burning Skeletons to destroy Chained Abominations"), 0, {{"object", 193060}}}},
        },
        [13145] = { -- The Vile Hold
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Seize Control of a Lithe Stalker"), 0, {{"object", 193424}}}},
        },
        [13146] = { -- Generosity Abounds
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_OBJECT, l10n("Seize Control of a Lithe Stalker"), 0, {{"object", 193424}}},
                {nil, Questie.ICON_TYPE_EVENT, l10n("Drag Scourge Bombs to Lumbering Atrocities"), 0, {{"monster", 30920}}},
            },
        },
        [13147] = { -- Matchmaker
            [questKeys.objectives] = {{{30922}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Seize Control of a Lithe Stalker"), 0, {{"object", 193424}}}},
        },
        [13149] = { -- Dispelling Illusions
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Plagued Grain Crates Dispelled: 0/1"), 0, {{"object", 190094}}}},
            [questKeys.requiredSourceItems] = {},
        },
        [13151] = { -- A Royal Escort
            [questKeys.objectives] = {{{26533}}},
        },
        [13152] = { -- A Visit to the Doctor
            [questKeys.preQuestSingle]= {},
            [questKeys.preQuestGroup] = {13134,13138,13140},
            [questKeys.objectives] = {{{30993,nil,Questie.ICON_TYPE_INTERACT},{30992}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Free Patches"), 0, {{"object", 193025}}}},
        },
        [13153] = { -- Warding the Warriors
            [questKeys.startedBy] = {},
            [questKeys.exclusiveTo] = {236,13154,13156,13195,13196,13197,13198},
        },
        [13154] = { -- Bones and Arrows
            [questKeys.startedBy] = {},
            [questKeys.exclusiveTo] = {236,13153,13156,13195,13196,13197,13198},
        },
        [13155] = { -- Vereth the Cunning
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {13172,13174},
        },
        [13156] = { -- A Rare Herb
            [questKeys.startedBy] = {},
            [questKeys.exclusiveTo] = {236,13153,13154,13195,13196,13197,13198},
        },
        [13160] = { -- Stunning View
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Seize Control of a Lithe Stalker"), 0, {{"object", 193424}}}},
        },
        [13164] = { -- The Fate of Bloodbane
            [questKeys.preQuestSingle]= {},
            [questKeys.preQuestGroup] = {13161,13162,13163},
        },
        [13168] = { -- Parting Gifts
            [questKeys.triggerEnd] = {"Seize Control of an Eidolon Watcher", {[zoneIDs.ICECROWN]={{44.19,24.69}}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Use Eye of Dominion"), 0, {{"object", 193058}}}},
        },
        [13169] = { -- An Undead's Best Friend
            [questKeys.objectives] = {{{30952,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Seize Control of an Eidolon Watcher"), 0, {{"object", 193058}}}},
        },
        [13170] = { -- Honor is for the Weak
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Seize Control of an Eidolon Watcher"), 0, {{"object", 193058}}}},
        },
        [13171] = { -- From Whence They Came
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Seize Control of an Eidolon Watcher"), 0, {{"object", 193058}}}},
        },
        [13172] = { -- Seeds of Chaos
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {13169,13170,13171},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Speak to Keritose Bloodblade to secure a Skeletal Gryphon"), 0, {{"monster", 30946}}}},
        },
        [13174] = { -- Amidst the Confusion
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {13169,13170,13171},
        },
        [13177] = { -- No Mercy for the Merciless
            [questKeys.startedBy] = {},
            [questKeys.exclusiveTo] = {13179},
            [questKeys.objectives] = {nil,nil,nil,nil,{{{30739,39019},39019}}},
        },
        [13178] = { -- Slay them all!
            [questKeys.startedBy] = {},
            [questKeys.exclusiveTo] = {13180},
        },
        [13179] = { -- No Mercy for the Merciless
            [questKeys.exclusiveTo] = {13177},
            [questKeys.objectives] = {nil,nil,nil,nil,{{{30739,39019},39019}}},
        },
        [13180] = { -- Slay them all!
            [questKeys.exclusiveTo] = {13178},
        },
        [13181] = { -- Victory in Wintergrasp
            [questKeys.triggerEnd] = {"Victory in Lake Wintergrasp", {[zoneIDs.DALARAN]={{33,67.2}}}},
        },
        [13183] = { -- Victory in Wintergrasp
            [questKeys.triggerEnd] = {"Victory in Lake Wintergrasp", {[zoneIDs.DALARAN]={{58.2,25.6}}}},
        },
        [13185] = { -- Stop the Siege
            [questKeys.exclusiveTo] = {13223},
        },
        [13186] = { -- Stop the Siege
            [questKeys.exclusiveTo] = {13222},
        },
        [13188] = { -- Where Kings Walk
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_INTERACT, l10n("Go to Stormwind"), 0, {{"object", 193053}}}},
        },
        [13189] = { -- Warchief's Blessing
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_INTERACT, l10n("Go to Orgrimmar"), 0, {{"object", 193052}}}},
        },
        [13190] = { -- All Things in Good Time
            [questKeys.requiredSourceItems] = {43494},
            [questKeys.objectives] = {nil,{{193057}}},
        },
        [13191] = { -- Fueling the Demolishers
            [questKeys.startedBy] = {},
            [questKeys.finishedBy] = {{31106}},
            [questKeys.exclusiveTo] = {13192,13193,13194,13199,13200,13201,13202},
        },
        [13192] = { -- Warding the Walls
            [questKeys.exclusiveTo] = {13191,13193,13194,13199,13200,13201,13202},
        },
        [13193] = { -- Bones and Arrows
            [questKeys.startedBy] = {},
            [questKeys.exclusiveTo] = {13191,13192,13194,13199,13200,13201,13202},
        },
        [13194] = { -- Healing with Roses
            [questKeys.startedBy] = {},
            [questKeys.exclusiveTo] = {13191,13192,13193,13199,13200,13201,13202},
        },
        [13195] = { -- A Rare Herb
            [questKeys.exclusiveTo] = {236,13153,13154,13156,13196,13197,13198},
        },
        [13196] = { -- Bones and Arrows
            [questKeys.exclusiveTo] = {236,13153,13154,13156,13195,13197,13198},
        },
        [13197] = { -- Fueling the Demolishers
            [questKeys.finishedBy] = {{31108}},
            [questKeys.exclusiveTo] = {236,13153,13154,13156,13195,13196,13198},
        },
        [13198] = { -- Warding the Warriors
            [questKeys.exclusiveTo] = {236,13153,13154,13156,13195,13196,13197},
        },
        [13199] = { -- Bones and Arrows
            [questKeys.exclusiveTo] = {13191,13192,13193,13194,13200,13201,13202},
        },
        [13200] = { -- Fueling the Demolishers
            [questKeys.finishedBy] = {{31106}},
            [questKeys.exclusiveTo] = {13191,13192,13193,13194,13199,13201,13202},
        },
        [13201] = { -- Healing with Roses
            [questKeys.exclusiveTo] = {13191,13192,13193,13194,13199,13200,13202},
        },
        [13202] = { -- Jinxing the Walls
            [questKeys.exclusiveTo] = {13191,13192,13193,13194,13199,13200,13201},
        },
        [13203] = { -- A Winter Veil Gift
            [questKeys.exclusiveTo] = {11528,13966},
        },
        [13204] = { -- Funky Fungi
            [questKeys.startedBy] = {nil,nil,{43512}},
        },
        [13211] = { -- By Fire Be Purged
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {13134,13138,13140},
            [questKeys.requiredSourceItems] = {},
        },
        [13214] = { -- Battle at Valhalas: Fallen Heroes
            [questKeys.objectives] = {nil,nil,nil,nil,{{{31191,31192,31193,31194,31195,31196,},31191}}},
        },
        [13215] = { -- Battle at Valhalas: Khit'rix the Dark Master
            [questKeys.objectives] = {{{31222}}},
        },
        [13216] = { -- Battle at Valhalas: The Return of Sigrid Iceborn
            [questKeys.objectives] = {{{31242}}},
        },
        [13217] = { -- Battle at Valhalas: Carnage!
            [questKeys.objectives] = {{{31271}}},
        },
        [13218] = { -- Battle at Valhalas: Thane Deathblow
            [questKeys.objectives] = {{{31277}}},
        },
        [13219] = { -- Battle at Valhalas: Final Challenge
            [questKeys.objectives] = {{{14688}}},
        },
        [13220] = { -- Putting Olakin Back Together Again
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use Crusader Olakin's Remains at the Sanctum of Reanimation Slab"), 0, {{"object", 193090}}}},
            [questKeys.requiredSourceItems] = {43567,43568},
        },
        [13221] = { -- I'm Not Dead Yet!
            [questKeys.triggerEnd] = {"Escort Father Kamaros to safety", {[zoneIDs.ICECROWN]={{32,57.1}}}},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {13119,13120},
        },
        [13222] = { -- Defend the Siege
            [questKeys.exclusiveTo] = {13186},
        },
        [13223] = { -- Defend the Siege
            [questKeys.exclusiveTo] = {13185},
        },
        [13226] = { -- Judgment Day Comes!
            [questKeys.nextQuestInChain] = 13036,
        },
        [13227] = { -- Judgment Day Comes!
            [questKeys.nextQuestInChain] = 13036,
        },
        [13228] = { -- The Broken Front
            [questKeys.objectives] = {{{31273,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.childQuests] = {13230},
            [questKeys.preQuestSingle] = {13224},
        },
        [13229] = { -- I'm Not Dead Yet!
            [questKeys.triggerEnd] = {"Escort Father Kamaros to safety", {[zoneIDs.ICECROWN]={{32,57.1}}}},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {13119,13120},
        },
        [13230] = { -- Avenge Me!
            [questKeys.parentQuest] = 13228,
            [questKeys.preQuestSingle] = {13228},
        },
        [13231] = { -- The Broken Front
            [questKeys.objectives] = {{{31304,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.childQuests] = {13232},
            [questKeys.preQuestSingle] = {13225},
        },
        [13232] = { -- Finish Me!
            [questKeys.objectives] = {{{31304}}},
            [questKeys.parentQuest] = 13231,
            [questKeys.preQuestSingle] = {13231},
        },
        [13233] = { -- No Mercy!
            [questKeys.triggerEnd] = {"Kill horde players in Icecrown", {[zoneIDs.ICECROWN]={{60.9,41.3}}}},
            [questKeys.preQuestSingle] = {13231},
        },
        [13234] = { -- Make Them Pay!
            [questKeys.preQuestSingle] = {13228},
            [questKeys.triggerEnd] = {"Kill alliance players in Icecrown", {[zoneIDs.ICECROWN]={{60.9,41.3}}}},
        },
        [13235] = { -- The Flesh Giant Champion
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Talk to Margrave Dhakar to fight Morbidus"), 0, {{"monster", 31306}}}},
        },
        [13236] = { -- Army of the Damned
            [questKeys.objectives] = {nil,nil,nil,nil,{{{31254,32414,31276},31329}}},
        },
        [13238] = { -- Good For Something?
            [questKeys.preQuestSingle] = {13228},
        },
        [13239] = { -- Volatility
            [questKeys.preQuestSingle] = {13238},
            [questKeys.objectives] = {nil,nil,nil,nil,{{{31137,31583},31137,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.requiredSourceItems] = {43609,43610,43616},
        },
        [13240] = { -- Timear Foresees Centrifuge Constructs in your Future!
            [questKeys.startedBy] = {{31439}},
            [questKeys.finishedBy] = {{31439}},
            [questKeys.exclusiveTo] = {13241,13243,13244},
        },
        [13241] = { -- Timear Foresees Ymirjar Berserkers in your Future!
            [questKeys.startedBy] = {{31439}},
            [questKeys.finishedBy] = {{31439}},
            [questKeys.exclusiveTo] = {13240,13243,13244},
        },
        [13242] = { -- Darkness Stirs
            [questKeys.preQuestSingle] = {12500},
        },
        [13243] = { -- Timear Foresees Infinite Agents in your Future!
            [questKeys.startedBy] = {{31439}},
            [questKeys.finishedBy] = {{31439}},
            [questKeys.exclusiveTo] = {13240,13241,13244},
            [questKeys.objectives] = {nil,nil,nil,nil,{{{27744,28341},27744}}},
        },
        [13244] = { -- Timear Foresees Titanium Vanguards in your Future!
            [questKeys.startedBy] = {{31439}},
            [questKeys.finishedBy] = {{31439}},
            [questKeys.exclusiveTo] = {13240,13241,13243},
        },
        [13245] = { -- Proof of Demise: Ingvar the Plunderer
            [questKeys.startedBy] = {{20735}},
            [questKeys.finishedBy] = {{20735}},
            [questKeys.exclusiveTo] = {13246,13247,13248,13249,13250,13251,13252,13253,13254,13255,13256,14199},
        },
        [13246] = { -- Proof of Demise: Keristrasza
            [questKeys.startedBy] = {{20735}},
            [questKeys.finishedBy] = {{20735}},
            [questKeys.exclusiveTo] = {13245,13247,13248,13249,13250,13251,13252,13253,13254,13255,13256,14199},
        },
        [13247] = { -- Proof of Demise: Ley-Guardian Eregos
            [questKeys.startedBy] = {{20735}},
            [questKeys.finishedBy] = {{20735}},
            [questKeys.exclusiveTo] = {13245,13246,13248,13249,13250,13251,13252,13253,13254,13255,13256,14199},
        },
        [13248] = { -- Proof of Demise: King Ymiron
            [questKeys.startedBy] = {{20735}},
            [questKeys.finishedBy] = {{20735}},
            [questKeys.exclusiveTo] = {13245,13246,13247,13249,13250,13251,13252,13253,13254,13255,13256,14199},
        },
        [13249] = { -- Proof of Demise: The Prophet Tharon'ja
            [questKeys.startedBy] = {{20735}},
            [questKeys.finishedBy] = {{20735}},
            [questKeys.exclusiveTo] = {13245,13246,13247,13248,13250,13251,13252,13253,13254,13255,13256,14199},
        },
        [13250] = { -- Proof of Demise: Gal'darah
            [questKeys.startedBy] = {{20735}},
            [questKeys.finishedBy] = {{20735}},
            [questKeys.exclusiveTo] = {13245,13246,13247,13248,13249,13251,13252,13253,13254,13255,13256,14199},
        },
        [13251] = { -- Proof of Demise: Mal'Ganis
            [questKeys.startedBy] = {{20735}},
            [questKeys.finishedBy] = {{20735}},
            [questKeys.exclusiveTo] = {13245,13246,13247,13248,13249,13250,13252,13253,13254,13255,13256,14199},
        },
        [13252] = { -- Proof of Demise: Sjonnir The Ironshaper
            [questKeys.startedBy] = {{20735}},
            [questKeys.finishedBy] = {{20735}},
            [questKeys.exclusiveTo] = {13245,13246,13247,13248,13249,13250,13251,13253,13254,13255,13256,14199},
        },
        [13253] = { -- Proof of Demise: Loken
            [questKeys.startedBy] = {{20735}},
            [questKeys.finishedBy] = {{20735}},
            [questKeys.exclusiveTo] = {13245,13246,13247,13248,13249,13250,13251,13252,13254,13255,13256,14199},
        },
        [13254] = { -- Proof of Demise: Anub'arak
            [questKeys.startedBy] = {{20735}},
            [questKeys.finishedBy] = {{20735}},
            [questKeys.exclusiveTo] = {13245,13246,13247,13248,13249,13250,13251,13252,13253,13255,13256,14199},
        },
        [13255] = { -- Proof of Demise: Herald Volazj
            [questKeys.startedBy] = {{20735}},
            [questKeys.finishedBy] = {{20735}},
            [questKeys.exclusiveTo] = {13245,13246,13247,13248,13249,13250,13251,13252,13253,13254,13256,14199},
        },
        [13256] = { -- Proof of Demise: Cyanigosa
            [questKeys.startedBy] = {{20735}},
            [questKeys.finishedBy] = {{20735}},
            [questKeys.exclusiveTo] = {13245,13246,13247,13248,13249,13250,13251,13252,13253,13254,13255,14199},
        },
        [13258] = { -- Opportunity
            [questKeys.preQuestGroup] = {12938,13224},
        },
        [13260] = { -- Takes One to Know One
            [questKeys.preQuestSingle] = {13228},
        },
        [13261] = { -- Volatility
            [questKeys.preQuestSingle] = {13239},
            [questKeys.objectives] = {nil,nil,nil,nil,{{{31137,31583},31137,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.requiredSourceItems] = {43609,43610,43616},
        },
        [13264] = { -- That's Abominable!
            [questKeys.objectives] = {{{31142,nil,Questie.ICON_TYPE_INTERACT},{31147,nil,Questie.ICON_TYPE_INTERACT},{31205,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.preQuestSingle] = {13237},
            [questKeys.requiredSourceItems] = {43966},
        },
        [13265] = { -- Cloth Scavenging
            [questKeys.requiredSpell] = -59390,
        },
        [13267] = { -- The Battle For The Undercity
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Begin the assault!"), 0, {{"monster", 31650}}}},
        },
        [13268] = { -- Cloth Scavenging
            [questKeys.requiredSpell] = -59390,
        },
        [13269] = { -- Cloth Scavenging
            [questKeys.requiredSpell] = -59390,
        },
        [13270] = { -- Cloth Scavenging
            [questKeys.requiredSpell] = -59390,
        },
        [13272] = { -- Cloth Scavenging
            [questKeys.requiredSpell] = -59390,
        },
        [13273] = { -- Going After the Core
            [questKeys.preQuestSingle] = {12928},
            [questKeys.sourceItemId] = 40971,
        },
        [13274] = { -- The Core's Keeper
            [questKeys.sourceItemId] = 40971,
        },
        [13276] = { -- That's Abominable!
            [questKeys.objectives] = {{{31142,nil,Questie.ICON_TYPE_INTERACT},{31147,nil,Questie.ICON_TYPE_INTERACT},{31205,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.preQuestSingle] = {13264},
            [questKeys.requiredSourceItems] = {43966},
        },
        [13277] = { -- Against the Giants
            [questKeys.preQuestSingle] = {13237},
        },
        [13278] = { -- Coprous the Defiled
            [questKeys.preQuestSingle] = {13277},
        },
        [13279] = { -- Basic Chemistry
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use Pustulant Spinal Fluid"), 0, {{"monster", 31773}}}},
            [questKeys.objectives] = {{{31773,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.requiredSourceItems] = {},
        },
        [13280] = { -- King of the Mountain
            [questKeys.preQuestSingle] = {13296},
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_EVENT, l10n("Plant Alliance Battle Standard"), 0, {{"object", 193565}}},
                {nil, Questie.ICON_TYPE_EVENT, l10n("Get in the Jumpbot"), 0, {{"monster", 31736}}},
            },
        },
        [13281] = { -- Neutralizing the Plague
            [questKeys.preQuestSingle] = {13279},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use Pustulant Spinal Fluid"), 0, {{"monster", 31773}}}},
            [questKeys.objectives] = {{{31773,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [13283] = { -- King of the Mountain
            [questKeys.preQuestSingle] = {13293},
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_EVENT, l10n("Plant Horde Battle Standard"), 0, {{"object", 193565}}},
                {nil, Questie.ICON_TYPE_EVENT, l10n("Get in the Jumpbot"), 0, {{"monster", 31770}}},
            },
        },
        [13284] = { -- Assault by Ground
            [questKeys.preQuestSingle] = {13341},
            [questKeys.objectives] = {nil,nil,nil,nil,{{{31701,31737},31701,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [13285] = { -- Forging the Keystone
            [questKeys.sourceItemId] = 40971,
            [questKeys.requiredSourceItems] = {},
        },
        [13286] = { -- ...All the Help We Can Get.
            [questKeys.preQuestSingle] = {13231},
        },
        [13288] = { -- That's Abominable!
            [questKeys.objectives] = {{{31142,nil,Questie.ICON_TYPE_INTERACT},{31147,nil,Questie.ICON_TYPE_INTERACT},{31205,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.preQuestSingle] = {13287},
            [questKeys.requiredSourceItems] = {43966},
        },
        [13289] = { -- That's Abominable!
            [questKeys.objectives] = {{{31142,nil,Questie.ICON_TYPE_INTERACT},{31147,nil,Questie.ICON_TYPE_INTERACT},{31205,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.preQuestSingle] = {13288},
            [questKeys.requiredSourceItems] = {43966},
        },
        [13290] = { -- Your Attention, Please
            [questKeys.preQuestSingle] = {13231},
        },
        [13291] = { -- Borrowed Technology
            [questKeys.objectives] = {nil,nil,nil,nil,{{{31137,31583},31137,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.requiredSourceItems] = {43609,43610,43616},
        },
        [13292] = { -- The Solution Solution
            [questKeys.preQuestSingle] = {13291},
            [questKeys.objectives] = {nil,nil,nil,nil,{{{31137,31583},31137,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.requiredSourceItems] = {43609,43610,43616},
        },
        [13293] = { -- Get to Ymirheim!
            [questKeys.preQuestSingle] = {13224},
        },
        [13294] = { -- Against the Giants
            [questKeys.preQuestSingle] = {13287},
        },
        [13295] = { -- Basic Chemistry
            [questKeys.objectives] = {{{31773,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use Pustulant Spinal Fluid"), 0, {{"monster", 31773}}}},
            [questKeys.requiredSourceItems] = {},
        },
        [13296] = { -- Get to Ymirheim!
            [questKeys.preQuestSingle] = {13225},
        },
        [13297] = { -- Neutralizing the Plague
            [questKeys.preQuestSingle] = {13295},
            [questKeys.objectives] = {{{31773,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use Pustulant Spinal Fluid"), 0, {{"monster", 31773}}}},
        },
        [13298] = { -- Coprous the Defiled
            [questKeys.preQuestSingle] = {13294},
        },
        [13300] = { -- Slaves to Saronite
            [questKeys.objectives] = {{{31397,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.preQuestSingle] = {13225},
        },
        [13301] = { -- Assault by Ground
            [questKeys.preQuestSingle] = {13340},
            [questKeys.objectives] = {nil,nil,nil,nil,{{{31832,31833},31832,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [13302] = { -- Slaves to Saronite
            [questKeys.objectives] = {{{31397,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.preQuestSingle] = {13224},
        },
        [13305] = { -- Do Your Worst
            [questKeys.preQuestSingle] = {13304},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Board Refurbished Demolisher"), 0, {{"monster", 32370}}}},
        },
        [13306] = { -- Raise the Barricades
            [questKeys.preQuestSingle] = {13366},
            [questKeys.requiredSourceItems] = {},
        },
        [13307] = { -- Bloodspattered Banners
            [questKeys.preQuestSingle] = {13306},
        },
        [13308] = { -- Mind Tricks
            [questKeys.preQuestSingle] = {13224,13225},
        },
        [13309] = { -- Assault by Air
            [questKeys.preQuestSingle] = {13341},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_MOUNT_UP, l10n("Get on the turret"), 0, {{"monster", 32227}}}},
            [questKeys.objectives] = {{{32222,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [13310] = { -- Assault by Air
            [questKeys.preQuestSingle] = {13340},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_MOUNT_UP, l10n("Get on the turret"), 0, {{"monster", 31884}}}},
            [questKeys.objectives] = {{{31882,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [13312] = { -- The Ironwall Rampart
            [questKeys.preQuestGroup] = {13306,13367},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Use Rune of Distortion near Grimkor's Orb to summon Grimkor the Wicked"), 0, {{"object", 193622}}}},
            [questKeys.requiredSourceItems] = {},
        },
        [13313] = { -- Blinding the Eyes in the Sky
            [questKeys.preQuestSingle] = {13306},
            [questKeys.requiredSourceItems] = {},
        },
        [13314] = { -- Get the Message
            [questKeys.preQuestSingle] = {13332},
            [questKeys.requiredSourceItems] = {},
        },
        [13315] = { -- Sneak Preview
            [questKeys.preQuestSingle] = {13288},
            [questKeys.objectives] = {{{32195,nil,Questie.ICON_TYPE_EVENT},{32196,nil,Questie.ICON_TYPE_EVENT},{32197,nil,Questie.ICON_TYPE_EVENT},{32199,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [13316] = { -- The Guardians of Corp'rethar
            [questKeys.preQuestSingle] = {13329},
        },
        [13318] = { -- Drag and Drop
            [questKeys.objectives] = {{{32236,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.preQuestSingle] = {13315},
        },
        [13319] = { -- Chain of Command
            [questKeys.preQuestSingle] = {13315},
        },
        [13320] = { -- Cannot Reproduce
            [questKeys.preQuestSingle] = {13315},
        },
        [13321] = { -- Retest Now
            [questKeys.extraObjectives] = {{{[zoneIDs.ICECROWN]={{49.7,34.4},{49.1,34.2},{48.9,33.2}}}, Questie.ICON_TYPE_EVENT, l10n("Throw a Writhing Mass into a cauldron at Aldur'thar")}},
            [questKeys.requiredSourceItems] = {44301,44304},
        },
        [13322] = { -- Retest Now
            [questKeys.preQuestSingle] = {13321},
            [questKeys.extraObjectives] = {{{[zoneIDs.ICECROWN]={{49.7,34.4},{49.1,34.2},{48.9,33.2}}}, Questie.ICON_TYPE_EVENT, l10n("Throw a Writhing Mass into a cauldron at Aldur'thar")}},
            [questKeys.requiredSourceItems] = {44301,44304},
        },
        [13323] = { -- Drag and Drop
            [questKeys.preQuestSingle] = {13318},
            [questKeys.objectives] = {{{32236,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [13328] = { -- Shatter the Shards
            [questKeys.preQuestSingle] = {13329},
        },
        [13329] = { -- Before the Gate of Horror
            [questKeys.objectives] = {{{32467,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.preQuestGroup] = {13307,13312},
            [questKeys.requiredSourceItems] = {},
        },
        [13330] = { -- Blood of the Chosen
            [questKeys.preQuestSingle] = {13224},
        },
        [13331] = { -- Keeping the Alliance Blind
            [questKeys.preQuestSingle] = {13313},
            [questKeys.requiredSourceItems] = {},
        },
        [13332] = { -- Raise the Barricades
            [questKeys.preQuestSingle] = {13345},
            [questKeys.requiredSourceItems] = {},
        },
        [13333] = { -- Capture More Dispatches
            [questKeys.preQuestSingle] = {13314},
            [questKeys.requiredSourceItems] = {},
        },
        [13334] = { -- Bloodspattered Banners
            [questKeys.preQuestSingle] = {13332},
        },
        [13335] = { -- Before the Gate of Horror
            [questKeys.objectives] = {{{32467,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.preQuestGroup] = {13334,13337},
            [questKeys.requiredSourceItems] = {},
        },
        [13336] = { -- Blood of the Chosen
            [questKeys.preQuestSingle] = {13225},
        },
        [13337] = { -- The Ironwall Rampart
            [questKeys.preQuestGroup] = {13332,13346},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Use Rune of Distortion near Grimkor's Orb to summon Grimkor the Wicked"), 0, {{"object", 193622}}}},
            [questKeys.requiredSourceItems] = {},
        },
        [13338] = { -- The Guardians of Corp'rethar
            [questKeys.preQuestSingle] = {13335},
        },
        [13339] = { -- Shatter the Shards
            [questKeys.preQuestSingle] = {13335},
        },
        [13340] = { -- Joining the Assault
            [questKeys.preQuestSingle] = {13224},
        },
        [13341] = { -- Joining the Assault
            [questKeys.preQuestSingle] = {13225},
        },
        [13342] = { -- Not a Bug
            [questKeys.objectives] = {{{32316}}},
            [questKeys.preQuestSingle] = {13318},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Activate the Summoning Stone after collecting 5 Dark Matter"), 0, {{"object", 420001}}}},
            [questKeys.requiredSourceItems] = {44434},
        },
        [13343] = { -- Mystery of the Infinite, Redux
            [questKeys.objectives] = {{{32327,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.requiredSourceItems] = {},
        },
        [13344] = { -- Not a Bug
            [questKeys.objectives] = {{{32316}}},
            [questKeys.preQuestSingle] = {13342},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Activate the Summoning Stone after collecting 5 Dark Matter"), 0, {{"object", 420001}}}},
            [questKeys.requiredSourceItems] = {44434},
        },
        [13345] = { -- Need More Info
            [questKeys.preQuestSingle] = {13318},
        },
        [13346] = { -- No Rest For The Wicked
            [questKeys.requiredSourceItems] = {44476,44477,44478,44479,44480},
        },
        [13347] = { -- Reborn From The Ashes
            [questKeys.preQuestSingle] = {12499},
        },
        [13350] = { -- No Rest For The Wicked
            [questKeys.preQuestSingle] = {13346},
            [questKeys.objectives] = {{{32300}}},
            [questKeys.requiredSourceItems] = {44476,44477,44478,44479,44480},
        },
        [13351] = { -- Sneak Preview
            [questKeys.preQuestSingle] = {13264},
            [questKeys.objectives] = {{{32195,nil,Questie.ICON_TYPE_EVENT},{32196,nil,Questie.ICON_TYPE_EVENT},{32197,nil,Questie.ICON_TYPE_EVENT},{32199,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [13352] = { -- Drag and Drop
            [questKeys.objectives] = {{{32236,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.preQuestSingle] = {13351},
        },
        [13353] = { -- Drag and Drop
            [questKeys.objectives] = {{{32236,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.preQuestSingle] = {13352},
        },
        [13354] = { -- Chain of Command
            [questKeys.preQuestSingle] = {13351},
        },
        [13355] = { -- Cannot Reproduce
            [questKeys.preQuestSingle] = {13351},
        },
        [13356] = { -- Retest Now
            [questKeys.extraObjectives] = {{{[zoneIDs.ICECROWN]={{49.7,34.4},{49.1,34.2},{48.9,33.2}}}, Questie.ICON_TYPE_EVENT, l10n("Throw a Writhing Mass into a cauldron at Aldur'thar")}},
            [questKeys.requiredSourceItems] = {44301,44304},
        },
        [13357] = { -- Retest Now
            [questKeys.preQuestSingle] = {13356},
            [questKeys.extraObjectives] = {{{[zoneIDs.ICECROWN]={{49.7,34.4},{49.1,34.2},{48.9,33.2}}}, Questie.ICON_TYPE_EVENT, l10n("Throw a Writhing Mass into a cauldron at Aldur'thar")}},
            [questKeys.requiredSourceItems] = {44301,44304},
        },
        [13358] = { -- Not a Bug
            [questKeys.objectives] = {{{32316}}},
            [questKeys.preQuestSingle] = {13352},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Activate the Summoning Stone after collecting 5 Dark Matter"), 0, {{"object", 420001}}}},
            [questKeys.requiredSourceItems] = {44434},
        },
        [13359] = { -- Where Dragons Fell
            [questKeys.preQuestSingle] = {13348},
            [questKeys.nextQuestInChain] = 13360,
        },
        [13360] = { -- Time for Answers
            [questKeys.preQuestSingle] = {13359},
        },
        [13361] = { -- The Hunter and the Prince
            [questKeys.objectives] = {nil,nil,nil,nil,{{{31395,32587,32588},32588,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Pick it up"), 0, {{"object", 193980},{"object", 194023},{"object", 194024}}}},
        },
        [13363] = { -- Argent Aid
            [questKeys.preQuestSingle] = {13362},
        },
        [13364] = { -- Tirion's Gambit
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Talk to Tirion while wearing a Cultist Acolyte's Hood"), 0, {{"monster", 32239}}}},
        },
        [13365] = { -- Not a Bug
            [questKeys.objectives] = {{{32316}}},
            [questKeys.preQuestSingle] = {13358},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Activate the Summoning Stone after collecting 5 Dark Matter"), 0, {{"object", 420001}}}},
            [questKeys.requiredSourceItems] = {44434},
        },
        [13366] = { -- Need More Info
            [questKeys.preQuestSingle] = {13352},
        },
        [13367] = { -- No Rest For The Wicked
            [questKeys.requiredSourceItems] = {44477,44479,44478,44476,44480},
        },
        [13368] = { -- No Rest For The Wicked
            [questKeys.preQuestSingle] = {13367},
            [questKeys.requiredSourceItems] = {44477,44479,44478,44476,44480},
        },
        [13369] = { -- Fate, Up Against Your Will
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Request a portal to Orgrimmar"), 0, {{"monster", 32346}}}},
        },
        [13372] = { -- The Key to the Focusing Iris
            [questKeys.startedBy] = {nil,nil,{44569}},
        },
        [13373] = { -- Fringe Science Benefits
            [questKeys.objectives] = {{{32179},{32188}},nil,nil,nil,{{{32182,32183},32182}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Talk to Rizzy Ratchwiggle"), 0, {{"monster", 31839}}}},
        },
        [13375] = { -- The Heroic Key to the Focusing Iris
            [questKeys.startedBy] = {nil,nil,{44577}},
        },
        [13376] = { -- Total Ohmage: The Valley of Lost Hope!
            [questKeys.preQuestSingle] = {13373},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Talk to Rizzy Ratchwiggle"), 1, {{"monster", 31839}}}},
            [questKeys.objectives] = {{{32188},{32154},{31721}},nil,nil,nil,{{{32182,32183},32182}}},
        },
        [13377] = { -- The Battle For The Undercity
            [questKeys.objectives] = {{{32518,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Begin the assault!"), 0, {{"monster", 32401}}}},
        },
        [13379] = { -- Green Technology
            [questKeys.preQuestSingle] = {13239},
        },
        [13380] = { -- Leading the Charge
            [questKeys.objectives] = {{{32179},{32188}},nil,nil,nil,{{{32182,32183},32182}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Talk to Karen No"), 0, {{"monster", 31648}}}},
        },
        [13382] = { -- Putting the Hertz: The Valley of Lost Hope
            [questKeys.preQuestSingle] = {13380},
            [questKeys.objectives] = {{{32188},{32154},{31721}},nil,nil,nil,{{{32182,32183},32182}}},
        },
        [13383] = { -- Killohertz
            [questKeys.preQuestSingle] = {13291},
        },
        [13386] = { -- Exploiting an Opening
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {13225,12898},
        },
        [13390] = { -- A Voice in the Dark
            [questKeys.startedBy] = {{31237},{193195}},
        },
        [13394] = { -- Do Your Worst
            [questKeys.preQuestSingle] = {13393},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Board Refurbished Demolisher"), 0, {{"monster", 32370}}}},
        },
        [13395] = { -- Army of the Damned
            [questKeys.objectives] = {nil,nil,nil,nil,{{{31254,32414,31276},31329}}},
        },
        [13398] = { -- Where Dragons Fell
            [questKeys.preQuestSingle] = {13396},
        },
        [13400] = { -- The Hunter and the Prince
            [questKeys.objectives] = {nil,nil,nil,nil,{{{31395,32587,32588},32588,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Pick it up"), 0, {{"object", 193980},{"object", 194023},{"object", 194024}}}},
        },
        [13403] = { -- Tirion's Gambit
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Talk to Tirion while wearing a Cultist Acolyte's Hood"), 0, {{"monster", 32239}}}},
        },
        [13404] = { -- Static Shock Troops: the Bombardment
            [questKeys.preQuestSingle] = {13380},
            [questKeys.objectives] = {{{32179},{32188}},nil,nil,nil,{{{32182,32183},32182}}},
        },
        [13405] = { -- Call to Arms: Strand of the Ancients
            [questKeys.triggerEnd] = {"Victory in Strand of the Ancients", {
                [zoneIDs.IRONFORGE]={{70.41,91.10}},
                [zoneIDs.SHATTRATH_CITY]={{67.41,33.86}},
                [zoneIDs.DARNASSUS]={{58.02,34.52}},
                [zoneIDs.THE_EXODAR]={{26.6,50.06}},
                [zoneIDs.STORMWIND_CITY]={{83.47,33.66}},
                [zoneIDs.DALARAN]={{29.79,75.78}},
                [zoneIDs.WINTERGRASP]={{50.02,15.16}},
            }},
            [questKeys.exclusiveTo] = {11335,11336,11337,11338,14163},
        },
        [13406] = { -- Riding the Wavelength: The Bombardment
            [questKeys.preQuestSingle] = {13373},
            [questKeys.objectives] = {{{32179},{32188}},nil,nil,nil,{{{32182,32183},32182}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Talk to Rizzy Ratchwiggle"), 1, {{"monster", 31839}}}},
        },
        [13407] = { -- Call to Arms: Strand of the Ancients
            [questKeys.triggerEnd] = {"Victory in Strand of the Ancients", {
                [zoneIDs.ORGRIMMAR]={{80.68,30.51},{36.94,65.36}},
                [zoneIDs.THUNDER_BLUFF]={{57.8,76.4}},
                [zoneIDs.UNDERCITY]={{58.27,97.9}},
                [zoneIDs.SILVERMOON_CITY]={{97,38.3}},
                [zoneIDs.SHATTRATH_CITY]={{66.96,56.6}},
                [zoneIDs.DALARAN]={{58.19,20.59}},
                [zoneIDs.WINTERGRASP]={{50.02,15.16}},
            }},
            [questKeys.startedBy] = {{15350}},
            [questKeys.finishedBy] = {{15350}},
            [questKeys.exclusiveTo] = {11339,11340,11341,11342,14164},
        },
        [13408] = { -- Hellfire Fortifications A
            [questKeys.preQuestSingle] = {10143,10483},
            [questKeys.objectives] = {{{19028,nil,Questie.ICON_TYPE_EVENT},{19029,nil,Questie.ICON_TYPE_EVENT},{19032,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.nextQuestInChain] = 10106,
        },
        [13409] = { -- Hellfire Fortifications H
            [questKeys.preQuestSingle] = {10124,10449},
            [questKeys.objectives] = {{{19028,nil,Questie.ICON_TYPE_EVENT},{19029,nil,Questie.ICON_TYPE_EVENT},{19032,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.nextQuestInChain] = 10110,
        },
        [13410] = { -- Hellfire Fortifications A
            [questKeys.preQuestSingle] = {10143,10483},
            [questKeys.objectives] = {{{19028,nil,Questie.ICON_TYPE_EVENT},{19029,nil,Questie.ICON_TYPE_EVENT},{19032,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.nextQuestInChain] = 10106,
        },
        [13411] = { -- Hellfire Fortifications H
            [questKeys.preQuestSingle] = {10124,10449},
            [questKeys.objectives] = {{{19028,nil,Questie.ICON_TYPE_EVENT},{19029,nil,Questie.ICON_TYPE_EVENT},{19032,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.nextQuestInChain] = 10110,
        },
        [13413] = { -- Aces High!
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_MOUNT_UP, l10n("Mount up"), 1, {{"monster", 32548}}}},
        },
        [13414] = { -- Aces High!
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_MOUNT_UP, l10n("Mount up"), 1, {{"monster", 32548}}}},
        },
        [13415] = { -- The Library Console
            [questKeys.requiredSourceItems] = {40971},
        },
        [13416] = { -- The Library Console
            [questKeys.requiredSourceItems] = {40971},
        },
        [13418] = { -- Preparations for War
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Take a ride to the ship"), 1, {{"monster", 31081}}}},
        },
        [13419] = { -- Preparations for War
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Take a ride to the ship"), 1, {{"monster", 31085}}}},
        },
        [13420] = { -- Everfrost
            [questKeys.startedBy] = {nil,nil,{44725}},
            [questKeys.requiredMinRep] = {1119,3000},
            [questKeys.requiredSourceItems] = {},
        },
        [13422] = { -- Maintaining Discipline
            [questKeys.preQuestSingle] = {12906},
            [questKeys.objectives] = {{{30146,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.exclusiveTo] = {13423,13424,13425},
            [questKeys.requiredSourceItems] = {},
        },
        [13423] = { -- Defending Your Title
            [questKeys.preQuestSingle] = {12971},
            [questKeys.exclusiveTo] = {13422,13424,13425},
        },
        [13424] = { -- Back to the Pit
            [questKeys.preQuestSingle] = {12997},
            [questKeys.exclusiveTo] = {13422,13423,13425},
            [questKeys.requiredSourceItems] = {},
        },
        [13425] = { -- The Aberrations Must Die
            [questKeys.preQuestSingle] = {12925},
            [questKeys.exclusiveTo] = {13422,13423,13424},
        },
        [13426] = { -- Xarantaur, the Witness
            [questKeys.preQuestSingle] = {13285},
            [questKeys.nextQuestInChain] = 13034,
        },
        [13427] = { -- Call to Arms: Alterac Valley
            [questKeys.triggerEnd] = {"Victory in Alterac Valley", {
                [zoneIDs.IRONFORGE]={{70.41,91.10}},
                [zoneIDs.SHATTRATH_CITY]={{67.41,33.86}},
                [zoneIDs.DARNASSUS]={{58.02,34.52}},
                [zoneIDs.THE_EXODAR]={{26.6,50.06}},
                [zoneIDs.STORMWIND_CITY]={{83.47,33.66}},
                [zoneIDs.DALARAN]={{29.79,75.78}},
                [zoneIDs.WINTERGRASP]={{50.02,15.16}},
                [zoneIDs.ALTERAC_MOUNTAINS]={{39.4,82.2}},
            }},
            [questKeys.requiredMaxLevel] = 70,
            [questKeys.exclusiveTo] = {14178,14179,14180},
        },
        [13428] = { -- Call to Arms: Alterac Valley
            [questKeys.triggerEnd] = {"Victory in Alterac Valley", {
                [zoneIDs.ORGRIMMAR]={{80.68,30.51},{36.94,65.36}},
                [zoneIDs.THUNDER_BLUFF]={{57.8,76.4}},
                [zoneIDs.UNDERCITY]={{58.27,97.9}},
                [zoneIDs.SILVERMOON_CITY]={{97,38.3}},
                [zoneIDs.SHATTRATH_CITY]={{66.96,56.6}},
                [zoneIDs.DALARAN]={{58.19,20.59}},
                [zoneIDs.WINTERGRASP]={{50.02,15.16}},
                [zoneIDs.ALTERAC_MOUNTAINS]={{63.3,60.2}},
            }},
            [questKeys.startedBy] = {{15350}},
            [questKeys.finishedBy] = {{15350}},
            [questKeys.requiredMaxLevel] = 70,
            [questKeys.exclusiveTo] = {14181,14182,14183},
        },
        [13429] = { -- A Distraction for Akama
            [questKeys.triggerEnd] = {"Help Akama and Maiev enter the Black Temple.", {[zoneIDs.SHADOWMOON_VALLEY]={{71.05,46.11},{66.29,44.06}}}},
            [questKeys.exclusiveTo] = {10985},
            [questKeys.startedBy] = {{18528}},
            [questKeys.finishedBy] = {{18528}},
            [questKeys.preQuestSingle] = {10949},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Let Xi'ri know you're ready to battle"), 1, {{"monster", 18528}}}},
        },
        [13430] = { -- Trial of the Naaru: Magtheridon
            [questKeys.exclusiveTo] = {10888},
            [questKeys.preQuestGroup] = {10884,10885,10886},
        },
        [13431] = { -- The Cudgel of Kar'desh
            [questKeys.exclusiveTo] = {10901},
        },
        [13432] = { -- The Vials of Eternity
            [questKeys.exclusiveTo] = {10445},
        },
        [13433] = { -- Candy Bucket
            [questKeys.startedBy] = {nil,{194056}},
            [questKeys.finishedBy] = {nil,{194056}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [13434] = { -- Candy Bucket
            [questKeys.startedBy] = {nil,{194057}},
            [questKeys.finishedBy] = {nil,{194057}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [13435] = { -- Candy Bucket
            [questKeys.startedBy] = {nil,{194058}},
            [questKeys.finishedBy] = {nil,{194058}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [13436] = { -- Candy Bucket
            [questKeys.startedBy] = {nil,{194059}},
            [questKeys.finishedBy] = {nil,{194059}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [13437] = { -- Candy Bucket
            [questKeys.startedBy] = {nil,{194060}},
            [questKeys.finishedBy] = {nil,{194060}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [13438] = { -- Candy Bucket
            [questKeys.startedBy] = {nil,{194061}},
            [questKeys.finishedBy] = {nil,{194061}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [13439] = { -- Candy Bucket
            [questKeys.startedBy] = {nil,{194062}},
            [questKeys.finishedBy] = {nil,{194062}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [13440] = { -- Desecrate this Fire!
            [questKeys.startedBy] = {nil,{194032}},
            [questKeys.finishedBy] = {nil,{194032}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
        },
        [13441] = { -- Desecrate this Fire!
            [questKeys.startedBy] = {nil,{194033}},
            [questKeys.finishedBy] = {nil,{194033}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
        },
        [13442] = { -- Desecrate this Fire!
            [questKeys.startedBy] = {nil,{194035}},
            [questKeys.finishedBy] = {nil,{194035}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
        },
        [13443] = { -- Desecrate this Fire!
            [questKeys.startedBy] = {nil,{194036}},
            [questKeys.finishedBy] = {nil,{194036}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
        },
        [13444] = { -- Desecrate this Fire!
            [questKeys.startedBy] = {nil,{194038}},
            [questKeys.finishedBy] = {nil,{194038}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
        },
        [13445] = { -- Desecrate this Fire!
            [questKeys.startedBy] = {nil,{194040}},
            [questKeys.finishedBy] = {nil,{194040}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
        },
        [13446] = { -- Desecrate this Fire!
            [questKeys.startedBy] = {nil,{194044}},
            [questKeys.finishedBy] = {nil,{194044}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
        },
        [13447] = { -- Desecrate this Fire!
            [questKeys.startedBy] = {nil,{194045}},
            [questKeys.finishedBy] = {nil,{194045}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
        },
        [13448] = { -- Candy Bucket
            [questKeys.startedBy] = {nil,{194063}},
            [questKeys.finishedBy] = {nil,{194063}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [13449] = { -- Desecrate this Fire!
            [questKeys.startedBy] = {nil,{194049}},
            [questKeys.finishedBy] = {nil,{194049}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
        },
        [13450] = { -- Desecrate this Fire!
            [questKeys.startedBy] = {nil,{194034}},
            [questKeys.finishedBy] = {nil,{194034}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
        },
        [13451] = { -- Desecrate this Fire!
            [questKeys.startedBy] = {nil,{194037}},
            [questKeys.finishedBy] = {nil,{194037}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
        },
        [13452] = { -- Candy Bucket
            [questKeys.startedBy] = {nil,{194065}},
            [questKeys.finishedBy] = {nil,{194065}},
            [questKeys.requiredRaces] = raceIDs.NONE,
        },
        [13453] = { -- Desecrate this Fire!
            [questKeys.startedBy] = {nil,{194039}},
            [questKeys.finishedBy] = {nil,{194039}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
        },
        [13454] = { -- Desecrate this Fire!
            [questKeys.startedBy] = {nil,{194042}},
            [questKeys.finishedBy] = {nil,{194042}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
        },
        [13455] = { -- Desecrate this Fire!
            [questKeys.startedBy] = {nil,{194043}},
            [questKeys.finishedBy] = {nil,{194043}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
        },
        [13456] = { -- Candy Bucket
            [questKeys.startedBy] = {nil,{194066}},
            [questKeys.finishedBy] = {nil,{194066}},
            [questKeys.requiredRaces] = raceIDs.NONE,
        },
        [13457] = { -- Desecrate this Fire!
            [questKeys.startedBy] = {nil,{194046}},
            [questKeys.finishedBy] = {nil,{194046}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
        },
        [13458] = { -- Desecrate this Fire!
            [questKeys.startedBy] = {nil,{194048}},
            [questKeys.finishedBy] = {nil,{194048}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.MIDSUMMER,
        },
        [13459] = { -- Candy Bucket
            [questKeys.startedBy] = {nil,{194067}},
            [questKeys.finishedBy] = {nil,{194067}},
            [questKeys.requiredRaces] = raceIDs.NONE,
        },
        [13460] = { -- Candy Bucket
            [questKeys.startedBy] = {nil,{194068}},
            [questKeys.finishedBy] = {nil,{194068}},
            [questKeys.requiredRaces] = raceIDs.NONE,
        },
        [13461] = { -- Candy Bucket
            [questKeys.startedBy] = {nil,{194069}},
            [questKeys.finishedBy] = {nil,{194069}},
            [questKeys.requiredRaces] = raceIDs.NONE,
        },
        [13462] = { -- Candy Bucket
            [questKeys.startedBy] = {nil,{194070}},
            [questKeys.finishedBy] = {nil,{194070}},
            [questKeys.requiredRaces] = raceIDs.NONE,
        },
        [13464] = { -- Candy Bucket
            [questKeys.startedBy] = {nil,{194073}},
            [questKeys.finishedBy] = {nil,{194073}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [13465] = { -- Candy Bucket
            [questKeys.startedBy] = {nil,{194074}},
            [questKeys.finishedBy] = {nil,{194074}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [13466] = { -- Candy Bucket
            [questKeys.startedBy] = {nil,{194075}},
            [questKeys.finishedBy] = {nil,{194075}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [13467] = { -- Candy Bucket
            [questKeys.startedBy] = {nil,{194076}},
            [questKeys.finishedBy] = {nil,{194076}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [13468] = { -- Candy Bucket
            [questKeys.startedBy] = {nil,{194077}},
            [questKeys.finishedBy] = {nil,{194077}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [13469] = { -- Candy Bucket
            [questKeys.startedBy] = {nil,{194078}},
            [questKeys.finishedBy] = {nil,{194078}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [13470] = { -- Candy Bucket
            [questKeys.startedBy] = {nil,{194079}},
            [questKeys.finishedBy] = {nil,{194079}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [13471] = { -- Candy Bucket
            [questKeys.startedBy] = {nil,{194080}},
            [questKeys.finishedBy] = {nil,{194080}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [13473] = { -- Candy Bucket
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [13474] = { -- Candy Bucket
            [questKeys.startedBy] = {nil,{194081}},
            [questKeys.finishedBy] = {nil,{194081}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [13479] = { -- The Great Egg Hunt
            [questKeys.breadcrumbs] = {13483},
        },
        [13480] = { -- The Great Egg Hunt
            [questKeys.breadcrumbs] = {13484},
        },
        [13481] = { -- Let's Get Out of Here!
            [questKeys.triggerEnd] = {"Escort Father Kamaros to safety", {[zoneIDs.ICECROWN]={{32,57.1}}}},
        },
        [13482] = { -- Let's Get Out of Here
            [questKeys.triggerEnd] = {"Escort Father Kamaros to safety", {[zoneIDs.ICECROWN]={{32,57.1}}}},
        },
        [13483] = { -- Spring Collectors
            [questKeys.breadcrumbForQuestId] = 13479,
            [questKeys.startedBy] = {{19169,19175,19176,19177,19178,20102}},
        },
        [13484] = { -- Spring Collectors
            [questKeys.breadcrumbForQuestId] = 13480,
            [questKeys.startedBy] = {{18927,19148,19171,19172,19173,20102}},
        },
        [13485] = { -- Honor the Flame
            [questKeys.startedBy] = {{32801}},
            [questKeys.finishedBy] = {{32801}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [13486] = { -- Honor the Flame
            [questKeys.startedBy] = {{32802}},
            [questKeys.finishedBy] = {{32802}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [13487] = { -- Honor the Flame
            [questKeys.startedBy] = {{32803}},
            [questKeys.finishedBy] = {{32803}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [13488] = { -- Honor the Flame
            [questKeys.startedBy] = {{32804}},
            [questKeys.finishedBy] = {{32804}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [13489] = { -- Honor the Flame
            [questKeys.startedBy] = {{32805}},
            [questKeys.finishedBy] = {{32805}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [13490] = { -- Honor the Flame
            [questKeys.startedBy] = {{32806}},
            [questKeys.finishedBy] = {{32806}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [13491] = { -- Honor the Flame
            [questKeys.startedBy] = {{32807}},
            [questKeys.finishedBy] = {{32807}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [13492] = { -- Honor the Flame
            [questKeys.startedBy] = {{32808}},
            [questKeys.finishedBy] = {{32808}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [13493] = { -- Honor the Flame
            [questKeys.startedBy] = {{32809}},
            [questKeys.finishedBy] = {{32809}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [13494] = { -- Honor the Flame
            [questKeys.startedBy] = {{32810}},
            [questKeys.finishedBy] = {{32810}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [13495] = { -- Honor the Flame
            [questKeys.startedBy] = {{32811}},
            [questKeys.finishedBy] = {{32811}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [13496] = { -- Honor the Flame
            [questKeys.startedBy] = {{32812}},
            [questKeys.finishedBy] = {{32812}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [13497] = { -- Honor the Flame
            [questKeys.startedBy] = {{32813}},
            [questKeys.finishedBy] = {{32813}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [13498] = { -- Honor the Flame
            [questKeys.startedBy] = {{32814}},
            [questKeys.finishedBy] = {{32814}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [13499] = { -- Honor the Flame
            [questKeys.startedBy] = {{32815}},
            [questKeys.finishedBy] = {{32815}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [13500] = { -- Honor the Flame
            [questKeys.startedBy] = {{32816}},
            [questKeys.finishedBy] = {{32816}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [13501] = { -- Candy Bucket
            [questKeys.startedBy] = {nil,{194084}},
            [questKeys.finishedBy] = {nil,{194084}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [13548] = { -- Candy Bucket
            [questKeys.startedBy] = {nil,{194119}},
            [questKeys.finishedBy] = {nil,{194119}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [13549] = { -- Tails Up
            [questKeys.objectives] = {{{29327,nil,Questie.ICON_TYPE_INTERACT},{29319,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.requiredSourceItems] = {},
        },
        [13559] = { -- Hodir's Tribute
            [questKeys.preQuestSingle] = {12924},
        },
        [13592] = { -- HUMAN A Valiant's Field Training
            [questKeys.preQuestSingle] = {13684,13593},
            [questKeys.exclusiveTo] = {13699,13744,13749,13760,13755},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [13593] = { -- HUMAN Valiant Of Stormwind
            [questKeys.preQuestSingle] = {13725,13713,13723,13724},
            [questKeys.exclusiveTo] = {13684,13686},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [13600] = { -- HUMAN A Worthy Weapon
            [questKeys.preQuestSingle] = {13684,13593},
            [questKeys.exclusiveTo] = {13699,13603,13616,13741,13742,13743,13746,13747,13748,13757,13758,13759,13752,13753,13754},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Place the flower offering"), 0, {{"monster", 33273}}}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [13603] = { -- HUMAN A Blade Fit For A Champion
            [questKeys.preQuestSingle] = {13684,13593},
            [questKeys.exclusiveTo] = {13699,13600,13616,13741,13742,13743,13746,13747,13748,13757,13758,13759,13752,13753,13754},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Use Warts-B-Gone Lip Balm and /kiss a Lake Frog"), 0, {{"monster", 33224}}}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.requiredSourceItems] = {},
        },
        [13604] = { -- Archivum Data Disc
            [questKeys.startedBy] = {nil,nil,{45506}},
        },
        [13607] = { -- The Celestial Planetarium
            [questKeys.triggerEnd] = {"Entrance to Celestial Planetarium located",{[zoneIDs.THE_ARCHIVUM]={{60,46.3}},[zoneIDs.ULDUAR]={{-1,-1}}}},
            [questKeys.preQuestSingle] = {13604},
        },
        [13616] = { -- HUMAN The Edge Of Winter
            [questKeys.preQuestSingle] = {13684,13593},
            [questKeys.exclusiveTo] = {13699,13600,13603,13741,13742,13743,13746,13747,13748,13757,13758,13759,13752,13753,13754},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use Everburning Ember"), 0, {{"monster", 33303}}}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [13625] = { -- Learning The Reins
            [questKeys.objectives] = {{{33229,nil,Questie.ICON_TYPE_INTERACT},{33243,nil,Questie.ICON_TYPE_INTERACT},{33272,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.preQuestGroup] = {13828,13835,13837},
            [questKeys.exclusiveTo] = {13679},
            [questKeys.parentQuest] = 0,
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_MOUNT_UP, l10n("Mount up"), 0, {{"monster", 33843}}}},
        },
        [13627] = { -- Jack Me Some Lumber
            [questKeys.startedBy] = {},
            [questKeys.finishedBy] = {},
            [questKeys.requiredSourceItems] = {},
        },
        [13629] = { -- Val'anyr, Hammer of Ancient Kings
            [questKeys.requiredSourceItems] = {},
            [questKeys.zoneOrSort] = zoneIDs.ULDUAR,
        },
        [13631] = { -- All Is Well That Ends Well
            [questKeys.startedBy] = {nil,nil,{46052}},
        },
        [13633] = { -- The Black Knight of Westfall?
            [questKeys.preQuestSingle] = {13667},
        },
        [13634] = { -- The Black Knight of Silverpine?
            [questKeys.preQuestSingle] = {13668},
        },
        [13643] = { -- The Stories Dead Men Tell
            [questKeys.requiredSourceItems] = {},
        },
        [13662] = { -- Gaining Acceptance
            [questKeys.preQuestSingle] = {7722},
            [questKeys.requiredMinRep] = {59,3000},
            [questKeys.requiredMaxRep] = {59,9000},
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [13663] = { -- The Black Knight's Orders
            [questKeys.objectives] = {{{33513,nil,Questie.ICON_TYPE_INTERACT}},nil,{{45121},{45122}}},
            [questKeys.requiredSourceItems] = {},
        },
        [13664] = { -- The Black Knight's Fall
            [questKeys.preQuestSingle] = {13700,13701},
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_MOUNT_UP, l10n("Mount up"), 0, {{"monster", 33870}}},
                {nil, Questie.ICON_TYPE_TALK, l10n("Speak to Squire Cavin"), 0, {{"monster", 33522}}},
            },
        },
        [13665] = { -- HUMAN The Grand Melee
            [questKeys.preQuestSingle] = {13684,13593},
            [questKeys.exclusiveTo] = {13699,13745,13750,13761,13756},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_MOUNT_UP, l10n("Mount up"), 0, {{"monster", 33800}}}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [13666] = { -- A Blade Fit For A Champion
            [questKeys.preQuestGroup] = {13828,13835,13837},
            [questKeys.exclusiveTo] = {13679,13669,13670},
            [questKeys.parentQuest] = 0,
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Use Warts-B-Gone Lip Balm and /kiss a Lake Frog"), 0, {{"monster", 33224}}}},
            [questKeys.requiredSourceItems] = {},
        },
        [13669] = { -- A Worthy Weapon
            [questKeys.preQuestGroup] = {13828,13835,13837},
            [questKeys.exclusiveTo] = {13679,13666,13670},
            [questKeys.parentQuest] = 0,
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Place the flower offering"), 0, {{"monster", 33273}}}},
        },
        [13670] = { -- The Edge Of Winter
            [questKeys.preQuestGroup] = {13828,13835,13837},
            [questKeys.exclusiveTo] = {13679,13666,13669},
            [questKeys.parentQuest] = 0,
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use Everburning Ember"), 0, {{"monster", 33303}}}},
        },
        [13671] = { -- Training In The Field
            [questKeys.preQuestGroup] = {13828,13835,13837},
            [questKeys.exclusiveTo] = {13679},
            [questKeys.parentQuest] = 0,
        },
        [13672] = { -- Up To The Challenge
            [questKeys.childQuests] = {},
        },
        [13673] = { -- A Blade Fit For A Champion
            [questKeys.preQuestGroup] = {13829,13838,13839},
            [questKeys.exclusiveTo] = {13674,13675,13680},
            [questKeys.parentQuest] = 0,
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Use Warts-B-Gone Lip Balm and /kiss a Lake Frog"), 0, {{"monster", 33224}}}},
            [questKeys.requiredSourceItems] = {},
        },
        [13674] = { -- A Worthy Weapon
            [questKeys.preQuestGroup] = {13829,13838,13839},
            [questKeys.exclusiveTo] = {13673,13675,13680},
            [questKeys.parentQuest] = 0,
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Place the flower offering"), 0, {{"monster", 33273}}}},
        },
        [13675] = { -- The Edge Of Winter
            [questKeys.preQuestGroup] = {13829,13838,13839},
            [questKeys.exclusiveTo] = {13673,13674,13680},
            [questKeys.parentQuest] = 0,
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use Everburning Ember"), 0, {{"monster", 33303}}}},
        },
        [13676] = { -- Training In The Field
            [questKeys.preQuestGroup] = {13829,13838,13839},
            [questKeys.exclusiveTo] = {13680},
            [questKeys.parentQuest] = 0,
        },
        [13677] = { -- Learning The Reins
            [questKeys.objectives] = {{{33229,nil,Questie.ICON_TYPE_INTERACT},{33243,nil,Questie.ICON_TYPE_INTERACT},{33272,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.preQuestGroup] = {13829,13838,13839},
            [questKeys.exclusiveTo] = {13680},
            [questKeys.parentQuest] = 0,
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_MOUNT_UP, l10n("Mount up"), 0, {{"monster", 33842}}}},
        },
        [13678] = { -- Up To The Challenge
            [questKeys.childQuests] = {},
        },
        [13679] = { -- The Aspirant's Challenge
            [questKeys.objectives] = {{{33448}}},
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_MOUNT_UP, l10n("Mount up"), 0, {{"monster", 33843}}},
                {nil, Questie.ICON_TYPE_TALK, l10n("Speak to Squire David"), 0, {{"monster", 33447}}},
            },
        },
        [13680] = { -- The Aspirant's Challenge
            [questKeys.objectives] = {{{33448}}},
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_MOUNT_UP, l10n("Mount up"), 0, {{"monster", 33842}}},
                {nil, Questie.ICON_TYPE_TALK, l10n("Speak to Squire David"), 0, {{"monster", 33447}}},
            },
        },
        [13681] = { -- A Chip Off the Ulduar Block
            [questKeys.startedBy] = {},
            [questKeys.finishedBy] = {},
            [questKeys.requiredSourceItems] = {},
        },
        [13682] = { -- Threat From Above
            [questKeys.preQuestSingle] = {13664},
        },
        [13697] = { -- ORC The Valiant's Charge
            [questKeys.preQuestSingle] = {13691,13707},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [13699] = { -- HUMAN The Valiant's Challenge
            [questKeys.objectives] = {{{33707}}},
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_MOUNT_UP, l10n("Mount up"), 0, {{"monster", 33800}}},
                {nil, Questie.ICON_TYPE_TALK, l10n("Speak to Squire Danny"), 0, {{"monster", 33518}}},
            },
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [13703] = { -- DWARF Valiant Of Ironforge
            [questKeys.preQuestSingle] = {13699,13725,13724,13723},
            [questKeys.exclusiveTo] = {13685,13686},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [13704] = { -- GNOME Valiant Of Gnomeregan
            [questKeys.preQuestSingle] = {13699,13725,13713,13724},
            [questKeys.exclusiveTo] = {13688,13686},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [13705] = { -- DRAENEI Valiant Of The Exodar
            [questKeys.preQuestSingle] = {13699,13725,13713,13723},
            [questKeys.exclusiveTo] = {13690,13686},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [13706] = { -- NIGHT ELF Valiant Of Darnassus
            [questKeys.preQuestSingle] = {13699,13724,13713,13723},
            [questKeys.exclusiveTo] = {13689,13686},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [13707] = { -- ORC Valiant Of Orgrimmar
            [questKeys.preQuestSingle] = {13727,13728,13729,13731},
            [questKeys.exclusiveTo] = {13691,13687},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [13708] = { -- TROLL Valiant Of Sen'jin
            [questKeys.preQuestSingle] = {13726,13728,13729,13731},
            [questKeys.exclusiveTo] = {13693,13687},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [13709] = { -- TAUREN Valiant Of Thunder Bluff
            [questKeys.preQuestSingle] = {13726,13727,13729,13731},
            [questKeys.exclusiveTo] = {13694,13687},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [13710] = { -- UNDEAD Valiant Of Undercity
            [questKeys.preQuestSingle] = {13726,13727,13728,13731},
            [questKeys.exclusiveTo] = {13695,13687},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [13711] = { -- BLOOD ELF Valiant Of Silvermoon
            [questKeys.preQuestSingle] = {13726,13727,13728,13729},
            [questKeys.exclusiveTo] = {13696,13687},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [13713] = { -- DWARF The Valiant's Challenge
            [questKeys.objectives] = {{{33707}}},
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_TALK, l10n("Speak to Squire Danny"), 0, {{"monster", 33518}}},
                {nil, Questie.ICON_TYPE_MOUNT_UP, l10n("Mount up"), 0, {{"monster", 33795}}},
            },
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [13714] = { -- DWARF The Valiant's Charge
            [questKeys.preQuestSingle] = {13685,13703},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [13715] = { -- GNOME The Valiant's Charge
            [questKeys.preQuestSingle] = {13688,13704},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [13716] = { -- DRAENEI The Valiant's Charge
            [questKeys.preQuestSingle] = {13690,13705},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [13717] = { -- NIGHT ELF The Valiant's Charge
            [questKeys.preQuestSingle] = {13689,13706},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [13718] = { -- HUMAN The Valiant's Charge
            [questKeys.preQuestSingle] = {13684,13593},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [13719] = { -- TROLL The Valiant's Charge
            [questKeys.preQuestSingle] = {13693,13708},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [13720] = { -- TAUREN The Valiant's Charge
            [questKeys.preQuestSingle] = {13694,13709},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [13721] = { -- UNDEAD The Valiant's Charge
            [questKeys.preQuestSingle] = {13695,13710},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [13722] = { -- BLOOD ELF The Valiant's Charge
            [questKeys.preQuestSingle] = {13696,13711},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [13723] = { -- GNOME The Valiant's Challenge
            [questKeys.objectives] = {{{33707}}},
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_MOUNT_UP, l10n("Mount up"), 0, {{"monster", 33793}}},
                {nil, Questie.ICON_TYPE_TALK, l10n("Speak to Squire Danny"), 0, {{"monster", 33518}}},
            },
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [13724] = { -- DRAENEI The Valiant's Challenge
            [questKeys.objectives] = {{{33707}}},
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_MOUNT_UP, l10n("Mount up"), 0, {{"monster", 33790}}},
                {nil, Questie.ICON_TYPE_TALK, l10n("Speak to Squire Danny"), 0, {{"monster", 33518}}},
            },
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [13725] = { -- NIGHT ELF The Valiant's Challenge
            [questKeys.objectives] = {{{33707}}},
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_MOUNT_UP, l10n("Mount up"), 0, {{"monster", 33794}}},
                {nil, Questie.ICON_TYPE_TALK, l10n("Speak to Squire Danny"), 0, {{"monster", 33518}}},
            },
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [13726] = { -- ORC The Valiant's Challenge
            [questKeys.objectives] = {{{33707}}},
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_MOUNT_UP, l10n("Mount up"), 0, {{"monster", 33799}}},
                {nil, Questie.ICON_TYPE_TALK, l10n("Speak to Squire Danny"), 0, {{"monster", 33518}}},
            },
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [13727] = { -- TROLL The Valiant's Challenge
            [questKeys.objectives] = {{{33707}}},
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_MOUNT_UP, l10n("Mount up"), 0, {{"monster", 33796}}},
                {nil, Questie.ICON_TYPE_TALK, l10n("Speak to Squire Danny"), 0, {{"monster", 33518}}},
            },
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [13728] = { -- TAUREN The Valiant's Challenge
            [questKeys.objectives] = {{{33707}}},
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_MOUNT_UP, l10n("Mount up"), 0, {{"monster", 33792}}},
                {nil, Questie.ICON_TYPE_TALK, l10n("Speak to Squire Danny"), 0, {{"monster", 33518}}},
            },
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [13729] = { -- UNDEAD The Valiant's Challenge
            [questKeys.objectives] = {{{33707}}},
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_MOUNT_UP, l10n("Mount up"), 0, {{"monster", 33798}}},
                {nil, Questie.ICON_TYPE_TALK, l10n("Speak to Squire Danny"), 0, {{"monster", 33518}}},
            },
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [13731] = { -- BLOOD ELF The Valiant's Challenge
            [questKeys.objectives] = {{{33707}}},
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_MOUNT_UP, l10n("Mount up"), 0, {{"monster", 33791}}},
                {nil, Questie.ICON_TYPE_TALK, l10n("Speak to Squire Danny"), 0, {{"monster", 33518}}},
            },
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [13741] = { -- DWARF A Blade Fit For A Champion
            [questKeys.preQuestSingle] = {13685,13703},
            [questKeys.exclusiveTo] = {13713,13600,13603,13616,13742,13743,13746,13747,13748,13757,13758,13759,13752,13753,13754},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Use Warts-B-Gone Lip Balm and /kiss a Lake Frog"), 0, {{"monster", 33224}}}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.requiredSourceItems] = {},
        },
        [13742] = { -- DWARF A Worthy Weapon
            [questKeys.preQuestSingle] = {13685,13703},
            [questKeys.exclusiveTo] = {13713,13600,13603,13616,13741,13743,13746,13747,13748,13757,13758,13759,13752,13753,13754},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Place the flower offering"), 0, {{"monster", 33273}}}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [13743] = { -- DWARF The Edge Of Winter
            [questKeys.preQuestSingle] = {13685,13703},
            [questKeys.exclusiveTo] = {13713,13600,13603,13616,13741,13742,13746,13747,13748,13757,13758,13759,13752,13753,13754},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use Everburning Ember"), 0, {{"monster", 33303}}}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [13744] = { -- DWARF A Valiant's Field Training
            [questKeys.preQuestSingle] = {13685,13703},
            [questKeys.exclusiveTo] = {13713,13592,13749,13755,13760},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [13745] = { -- DWARF The Grand Melee
            [questKeys.preQuestSingle] = {13685,13703},
            [questKeys.exclusiveTo] = {13713,13665,13750,13761,13756},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_MOUNT_UP, l10n("Mount up"), 0, {{"monster", 33795}}}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [13746] = { -- GNOME A Blade Fit For A Champion
            [questKeys.preQuestSingle] = {13688,13704},
            [questKeys.exclusiveTo] = {13723,13600,13603,13616,13741,13742,13743,13747,13748,13757,13758,13759,13752,13753,13754},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Use Warts-B-Gone Lip Balm and /kiss a Lake Frog"), 0, {{"monster", 33224}}}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.requiredSourceItems] = {},
        },
        [13747] = { -- GNOME A Worthy Weapon
            [questKeys.preQuestSingle] = {13688,13704},
            [questKeys.exclusiveTo] = {13723,13600,13603,13616,13741,13742,13743,13746,13748,13757,13758,13759,13752,13753,13754},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Place the flower offering"), 0, {{"monster", 33273}}}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [13748] = { -- GNOME The Edge Of Winter
            [questKeys.preQuestSingle] = {13688,13704},
            [questKeys.exclusiveTo] = {13723,13600,13603,13616,13741,13742,13743,13746,13747,13757,13758,13759,13752,13753,13754},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use Everburning Ember"), 0, {{"monster", 33303}}}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [13749] = { -- GNOME A Valiant's Field Training
            [questKeys.preQuestSingle] = {13688,13704},
            [questKeys.exclusiveTo] = {13723,13592,13744,13755,13760},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [13750] = { -- GNOME The Grand Melee
            [questKeys.preQuestSingle] = {13688,13704},
            [questKeys.exclusiveTo] = {13723,13665,13745,13761,13756},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_MOUNT_UP, l10n("Mount up"), 0, {{"monster", 33793}}}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [13752] = { -- DRAENEI A Blade Fit For A Champion
            [questKeys.preQuestSingle] = {13690,13705},
            [questKeys.exclusiveTo] = {13724,13600,13603,13616,13741,13742,13743,13746,13747,13748,13757,13758,13759,13753,13754},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Use Warts-B-Gone Lip Balm and /kiss a Lake Frog"), 0, {{"monster", 33224}}}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.requiredSourceItems] = {},
        },
        [13753] = { -- DRAENEI A Worthy Weapon
            [questKeys.preQuestSingle] = {13690,13705},
            [questKeys.exclusiveTo] = {13724,13600,13603,13616,13741,13742,13743,13746,13747,13748,13757,13758,13759,13752,13754},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Place the flower offering"), 0, {{"monster", 33273}}}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [13754] = { -- DRAENEI The Edge Of Winter
            [questKeys.preQuestSingle] = {13690,13705},
            [questKeys.exclusiveTo] = {13724,13600,13603,13616,13741,13742,13743,13746,13747,13748,13757,13758,13759,13752,13753},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use Everburning Ember"), 0, {{"monster", 33303}}}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [13755] = { -- DRAENEI A Valiant's Field Training
            [questKeys.preQuestSingle] = {13690,13705},
            [questKeys.exclusiveTo] = {13724,13592,13744,13749,13760},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [13756] = { -- DRAENEI The Grand Melee
            [questKeys.preQuestSingle] = {13690,13705},
            [questKeys.exclusiveTo] = {13724,13665,13745,13750,13761},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_MOUNT_UP, l10n("Mount up"), 0, {{"monster", 33790}}}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [13757] = { -- NIGHT ELF A Blade Fit For A Champion
            [questKeys.preQuestSingle] = {13689,13706},
            [questKeys.exclusiveTo] = {13725,13600,13603,13616,13741,13742,13743,13746,13747,13748,13758,13759,13752,13753,13754},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Use Warts-B-Gone Lip Balm and /kiss a Lake Frog"), 0, {{"monster", 33224}}}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.requiredSourceItems] = {},
        },
        [13758] = { -- NIGHT ELF A Worthy Weapon
            [questKeys.preQuestSingle] = {13689,13706},
            [questKeys.exclusiveTo] = {13725,13600,13603,13616,13741,13742,13743,13746,13747,13748,13757,13759,13752,13753,13754},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Place the flower offering"), 0, {{"monster", 33273}}}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [13759] = { -- NIGHT ELF The Edge Of Winter
            [questKeys.preQuestSingle] = {13689,13706},
            [questKeys.exclusiveTo] = {13725,13600,13603,13616,13741,13742,13743,13746,13747,13748,13757,13758,13752,13753,13754},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use Everburning Ember"), 0, {{"monster", 33303}}}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [13760] = { -- NIGHT ELF A Valiant's Field Training
            [questKeys.preQuestSingle] = {13689,13706},
            [questKeys.exclusiveTo] = {13725,13592,13744,13749,13755},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [13761] = { -- NIGHT ELF The Grand Melee
            [questKeys.preQuestSingle] = {13689,13706},
            [questKeys.exclusiveTo] = {13725,13665,13745,13750,13756},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_MOUNT_UP, l10n("Mount up"), 0, {{"monster", 33794}}}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [13762] = { -- ORC A Blade Fit For A Champion
            [questKeys.preQuestSingle] = {13691,13707},
            [questKeys.exclusiveTo] = {13726,13763,13764,13768,13769,13770,13773,13774,13775,13778,13779,13780,13783,13784,13785},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Use Warts-B-Gone Lip Balm and /kiss a Lake Frog"), 0, {{"monster", 33224}}}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.requiredSourceItems] = {},
        },
        [13763] = { -- ORC A Worthy Weapon
            [questKeys.preQuestSingle] = {13691,13707},
            [questKeys.exclusiveTo] = {13726,13762,13764,13768,13769,13770,13773,13774,13775,13778,13779,13780,13783,13784,13785},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Place the flower offering"), 0, {{"monster", 33273}}}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [13764] = { -- ORC The Edge Of Winter
            [questKeys.preQuestSingle] = {13691,13707},
            [questKeys.exclusiveTo] = {13726,13762,13763,13768,13769,13770,13773,13774,13775,13778,13779,13780,13783,13784,13785},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use Everburning Ember"), 0, {{"monster", 33303}}}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [13765] = { -- ORC A Valiant's Field Training
            [questKeys.preQuestSingle] = {13691,13707},
            [questKeys.exclusiveTo] = {13726,13771,13776,13781,13786},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [13767] = { -- ORC The Grand Melee
            [questKeys.preQuestSingle] = {13691,13707},
            [questKeys.exclusiveTo] = {13726,13772,13777,13782,13787},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_MOUNT_UP, l10n("Mount up"), 0, {{"monster", 33799}}}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [13768] = { -- TROLL A Blade Fit For A Champion
            [questKeys.preQuestSingle] = {13693,13708},
            [questKeys.exclusiveTo] = {13727,13762,13763,13764,13769,13770,13773,13774,13775,13778,13779,13780,13783,13784,13785},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Use Warts-B-Gone Lip Balm and /kiss a Lake Frog"), 0, {{"monster", 33224}}}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.requiredSourceItems] = {},
        },
        [13769] = { -- TROLL A Worthy Weapon
            [questKeys.preQuestSingle] = {13693,13708},
            [questKeys.exclusiveTo] = {13727,13762,13763,13764,13768,13770,13773,13774,13775,13778,13779,13780,13783,13784,13785},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Place the flower offering"), 0, {{"monster", 33273}}}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [13770] = { -- TROLL The Edge Of Winter
            [questKeys.preQuestSingle] = {13693,13708},
            [questKeys.exclusiveTo] = {13727,13762,13763,13764,13768,13769,13773,13774,13775,13778,13779,13780,13783,13784,13785},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use Everburning Ember"), 0, {{"monster", 33303}}}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [13771] = { -- TROLL A Valiant's Field Training
            [questKeys.preQuestSingle] = {13693,13708},
            [questKeys.exclusiveTo] = {13727,13765,13776,13781,13786},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [13772] = { -- TROLL The Grand Melee
            [questKeys.preQuestSingle] = {13693,13708},
            [questKeys.exclusiveTo] = {13727,13767,13777,13782,13787},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_MOUNT_UP, l10n("Mount up"), 0, {{"monster", 33796}}}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [13773] = { -- TAUREN A Blade Fit For A Champion
            [questKeys.preQuestSingle] = {13694,13709},
            [questKeys.exclusiveTo] = {13728,13762,13763,13764,13768,13769,13770,13774,13775,13778,13779,13780,13783,13784,13785},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Use Warts-B-Gone Lip Balm and /kiss a Lake Frog"), 0, {{"monster", 33224}}}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.requiredSourceItems] = {},
        },
        [13774] = { -- TAUREN A Worthy Weapon
            [questKeys.preQuestSingle] = {13694,13709},
            [questKeys.exclusiveTo] = {13728,13762,13763,13764,13768,13769,13770,13773,13775,13778,13779,13780,13783,13784,13785},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Place the flower offering"), 0, {{"monster", 33273}}}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [13775] = { -- TAUREN The Edge Of Winter
            [questKeys.preQuestSingle] = {13694,13709},
            [questKeys.exclusiveTo] = {13728,13762,13763,13764,13768,13769,13770,13773,13774,13778,13779,13780,13783,13784,13785},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use Everburning Ember"), 0, {{"monster", 33303}}}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [13776] = { -- TAUREN A Valiant's Field Training
            [questKeys.preQuestSingle] = {13694,13709},
            [questKeys.exclusiveTo] = {13728,13765,13771,13781,13786},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [13777] = { -- TAUREN The Grand Melee
            [questKeys.preQuestSingle] = {13694,13709},
            [questKeys.exclusiveTo] = {13728,13767,13772,13782,13787},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_MOUNT_UP, l10n("Mount up"), 0, {{"monster", 33792}}}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [13778] = { -- UNDEAD A Blade Fit For A Champion
            [questKeys.preQuestSingle] = {13695,13710},
            [questKeys.exclusiveTo] = {13729,13762,13763,13764,13768,13769,13770,13773,13774,13775,13779,13780,13783,13784,13785},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Use Warts-B-Gone Lip Balm and /kiss a Lake Frog"), 0, {{"monster", 33224}}}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.requiredSourceItems] = {},
        },
        [13779] = { -- UNDEAD A Worthy Weapon
            [questKeys.preQuestSingle] = {13695,13710},
            [questKeys.exclusiveTo] = {13729,13762,13763,13764,13768,13769,13770,13773,13774,13775,13778,13780,13783,13784,13785},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Place the flower offering"), 0, {{"monster", 33273}}}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [13780] = { -- UNDEAD The Edge Of Winter
            [questKeys.preQuestSingle] = {13695,13710},
            [questKeys.exclusiveTo] = {13729,13762,13763,13764,13768,13769,13770,13773,13774,13775,13778,13779,13783,13784,13785},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use Everburning Ember"), 0, {{"monster", 33303}}}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [13781] = { -- UNDEAD A Valiant's Field Training
            [questKeys.preQuestSingle] = {13695,13710},
            [questKeys.exclusiveTo] = {13729,13765,13771,13776,13786},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [13782] = { -- UNDEAD The Grand Melee
            [questKeys.preQuestSingle] = {13695,13710},
            [questKeys.exclusiveTo] = {13729,13767,13772,13777,13787},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_MOUNT_UP, l10n("Mount up"), 0, {{"monster", 33798}}}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [13783] = { -- BLOOD ELF A Blade Fit For A Champion
            [questKeys.preQuestSingle] = {13696,13711},
            [questKeys.exclusiveTo] = {13731,13762,13763,13764,13768,13769,13770,13773,13774,13775,13778,13779,13780,13784,13785},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Use Warts-B-Gone Lip Balm and /kiss a Lake Frog"), 0, {{"monster", 33224}}}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.requiredSourceItems] = {},
        },
        [13784] = { -- BLOOD ELF A Worthy Weapon
            [questKeys.preQuestSingle] = {13696,13711},
            [questKeys.exclusiveTo] = {13731,13762,13763,13764,13768,13769,13770,13773,13774,13775,13778,13779,13780,13783,13785},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Place the flower offering"), 0, {{"monster", 33273}}}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [13785] = { -- BLOOD ELF The Edge Of Winter
            [questKeys.preQuestSingle] = {13696,13711},
            [questKeys.exclusiveTo] = {13731,13762,13763,13764,13768,13769,13770,13773,13774,13775,13778,13779,13780,13783,13784},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use Everburning Ember"), 0, {{"monster", 33303}}}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [13786] = { -- BLOOD ELF A Valiant's Field Training
            [questKeys.preQuestSingle] = {13696,13711},
            [questKeys.exclusiveTo] = {13731,13765,13771,13776,13781},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [13787] = { -- BLOOD ELF The Grand Melee
            [questKeys.preQuestSingle] = {13696,13711},
            [questKeys.exclusiveTo] = {13731,13767,13772,13777,13782},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_MOUNT_UP, l10n("Mount up"), 0, {{"monster", 33791}}}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [13788] = { -- Threat From Above
            [questKeys.preQuestSingle] = {13664},
        },
        [13789] = { -- Taking Battle To The Enemy
            [questKeys.preQuestSingle] = {13700},
        },
        [13790] = { -- Among the Champions
            [questKeys.preQuestSingle] = {13700},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_MOUNT_UP, l10n("Mount up"), 0, {{"monster", 33794},{"monster", 33800},{"monster", 33793},{"monster", 33795},{"monster", 33790}}}},
        },
        [13791] = { -- Taking Battle To The Enemy
            [questKeys.preQuestSingle] = {13700},
        },
        [13793] = { -- Among the Champions
            [questKeys.preQuestSingle] = {13700},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_MOUNT_UP, l10n("Mount up"), 0, {{"monster", 33794},{"monster", 33800},{"monster", 33793},{"monster", 33795},{"monster", 33790}}}},
        },
        [13795] = { -- The Scourgebane
            [questKeys.preQuestSingle] = {13702,13732,13733,13734,13735,13736,13737,13738,13739,13740},
        },
        [13809] = { -- Threat From Above
            [questKeys.preQuestSingle] = {13664},
        },
        [13810] = { -- Taking Battle To The Enemy
            [questKeys.preQuestSingle] = {13701},
        },
        [13811] = { -- Among the Champions
            [questKeys.preQuestSingle] = {13701},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_MOUNT_UP, l10n("Mount up"), 0, {{"monster", 33796},{"monster", 33798},{"monster", 33799},{"monster", 33791},{"monster", 33792}}}},
        },
        [13812] = { -- Threat From Above
            [questKeys.preQuestSingle] = {13664},
        },
        [13813] = { -- Taking Battle To The Enemy
            [questKeys.preQuestSingle] = {13701},
        },
        [13814] = { -- Among the Champions
            [questKeys.preQuestSingle] = {13701},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_MOUNT_UP, l10n("Mount up"), 0, {{"monster", 33796},{"monster", 33798},{"monster", 33799},{"monster", 33791},{"monster", 33792}}}},
        },
        [13816] = { -- Heroic: The Celestial Planetarium
            [questKeys.triggerEnd] = {"Entrance to Celestial Planetarium located",{[zoneIDs.THE_ARCHIVUM]={{60,46.3}},[zoneIDs.ULDUAR]={{-1,-1}}}},
            [questKeys.preQuestSingle] = {13817},
        },
        [13817] = { -- Heroic: Archivum Data Disc
            [questKeys.preQuestSingle] = {},
            [questKeys.startedBy] = {nil,nil,{45857}},
        },
        [13819] = { -- Heroic: All Is Well That Ends Well
            [questKeys.startedBy] = {nil,nil,{46053}},
        },
        [13820] = { -- The Blastbolt Brothers
            [questKeys.startedBy] = {{33817}},
            [questKeys.finishedBy] = {{33434}},
            [questKeys.exclusiveTo] = {13627},
        },
        [13825] = { -- Clamlette Surprise
            [questKeys.startedBy] = {{8125}},
            [questKeys.finishedBy] = {{8125}},
            -- [questKeys.exclusiveTo] = {6610}, -- This is not ideal. You can only do 13825 if you completed 6610 prior to Wotlk. But now with Wotlk you do 6610 and then can not do 13825
            [questKeys.requiredSkill] = {185,225},
        },
        [13826] = { -- Nat Pagle, Angler Extreme
            [questKeys.startedBy] = {{12919}},
            [questKeys.finishedBy] = {{12919}},
            -- [questKeys.exclusiveTo] = {6607}, -- This is not ideal. You can only do 13826 if you completed 6607 prior to Wotlk. But now with Wotlk you do 6607 and then can not do 13826
            [questKeys.requiredSkill] = {356,225},
        },
        [13828] = { -- Mastery Of Melee
            [questKeys.objectives] = {{{33973,nil,Questie.ICON_TYPE_TALK},{33229,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_MOUNT_UP, l10n("Mount up"), 0, {{"monster", 33843}}}},
        },
        [13829] = { -- Mastery Of Melee
            [questKeys.objectives] = {{{33973,nil,Questie.ICON_TYPE_TALK},{33229,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_MOUNT_UP, l10n("Mount up"), 0, {{"monster", 33842}}}},
        },
        [13830] = { -- The Ghostfish
            [questKeys.triggerEnd] = {"Discover the Ghostfish mystery",{[zoneIDs.SHOLAZAR_BASIN]={{48.89,62.29,}}}},
            [questKeys.extraObjectives] = {{{[zoneIDs.SHOLAZAR_BASIN]={{48.2,63.4}}}, Questie.ICON_TYPE_NODE_FISH, l10n("Fish for Phantom Ghostfish")}},
            [questKeys.requiredSourceItems] = {45902},
        },
        [13832] = { -- Jewel Of The Sewers
            [questKeys.extraObjectives] = {{{[zoneIDs.THE_UNDERBELLY]={{46,68}}}, Questie.ICON_TYPE_NODE_FISH, l10n("Fish for Corroded Jewelry")}},
        },
        [13833] = { -- Blood Is Thicker
            [questKeys.extraObjectives] = {{{[zoneIDs.BOREAN_TUNDRA]={{57.5,33.2},{62.2,64.2},{45,45}}}, Questie.ICON_TYPE_SLAY, l10n("Slay any beast, jump in any water location and fish in the Pool of Blood"), 0}},
        },
        [13834] = { -- Dangerously Delicious
            [questKeys.extraObjectives] = {{{[zoneIDs.WINTERGRASP]={{70,36},{63,60},{50,44},{37.6,36},{56,66},{42,75},{34.7,19.5}}}, Questie.ICON_TYPE_NODE_FISH, l10n("Fish for Terror Fish"), 0}},
        },
        [13835] = { -- Mastery Of The Shield-Breaker
            [questKeys.objectives] = {{{33974,nil,Questie.ICON_TYPE_TALK},{33243,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_MOUNT_UP, l10n("Mount up"), 0, {{"monster", 33843}}}},
        },
        [13836] = { -- Disarmed!
            [questKeys.extraObjectives] = {{{[zoneIDs.DALARAN]={{67.43,61.38},{62.43,70.05}}}, Questie.ICON_TYPE_NODE_FISH, l10n("Fish for Severed Arm")}},
        },
        [13837] = { -- Mastery Of The Charge
            [questKeys.objectives] = {{{33972,nil,Questie.ICON_TYPE_TALK},{33272,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_MOUNT_UP, l10n("Mount up"), 0, {{"monster", 33843}}}},
        },
        [13838] = { -- Mastery Of The Shield-Breaker
            [questKeys.objectives] = {{{33974,nil,Questie.ICON_TYPE_TALK},{33243,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_MOUNT_UP, l10n("Mount up"), 0, {{"monster", 33842}}}},
        },
        [13839] = { -- Mastery Of The Charge
            [questKeys.objectives] = {{{33972,nil,Questie.ICON_TYPE_TALK},{33272,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_MOUNT_UP, l10n("Mount up"), 0, {{"monster", 33842}}}},
        },
        [13843] = { -- The Scrapbot Construction Kit
            [questKeys.startedBy] = {nil,{191761}},
            [questKeys.finishedBy] = {nil,{191761}},
            [questKeys.preQuestSingle] = {12889},
            [questKeys.requiredSpell] = -55252,
            [questKeys.requiredSkill] = {profKeys.ENGINEERING,400},
        },
        [13846] = { -- Contributin' To The Cause
            [questKeys.preQuestSingle] = {13700,13701},
            [questKeys.requiredMaxRep] = {1106,42000},
        },
        [13847] = { -- HUMAN At The Enemy's Gates
            [questKeys.preQuestSingle] = {13684,13593},
            [questKeys.exclusiveTo] = {13699,13851,13852,13854,13855},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_MOUNT_UP, l10n("Mount up"), 0, {{"monster", 34125}}}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [13850] = { -- Toxic Tolerance
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Melee attack Venomhide Ravasaur"), 0, {{"monster", 6508}}}},
        },
        [13851] = { -- DWARF At The Enemy's Gates
            [questKeys.preQuestSingle] = {13685,13703},
            [questKeys.exclusiveTo] = {13713,13847,13852,13854,13855},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_MOUNT_UP, l10n("Mount up"), 0, {{"monster", 34125}}}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [13852] = { -- GNOME At The Enemy's Gates
            [questKeys.preQuestSingle] = {13688,13704},
            [questKeys.exclusiveTo] = {13723,13847,13851,13854,13855},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_MOUNT_UP, l10n("Mount up"), 0, {{"monster", 34125}}}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [13854] = { -- DRAENEI At The Enemy's Gates
            [questKeys.preQuestSingle] = {13690,13705},
            [questKeys.exclusiveTo] = {13724,13847,13851,13852,13855},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Mount up"), 0, {{"monster", 34125}}}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [13855] = { -- NIGHT ELF At The Enemy's Gates
            [questKeys.preQuestSingle] = {13689,13706},
            [questKeys.exclusiveTo] = {13725,13847,13851,13852,13854},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_MOUNT_UP, l10n("Mount up"), 0, {{"monster", 34125}}}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [13856] = { -- ORC At The Enemy's Gates
            [questKeys.preQuestSingle] = {13691,13707},
            [questKeys.exclusiveTo] = {13726,13857,13858,13859,13860},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_MOUNT_UP, l10n("Mount up"), 0, {{"monster", 34125}}}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [13857] = { -- TROLL At The Enemy's Gates
            [questKeys.preQuestSingle] = {13693,13708},
            [questKeys.exclusiveTo] = {13727,13856,13858,13859,13860},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_MOUNT_UP, l10n("Mount up"), 0, {{"monster", 34125}}}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [13858] = { -- TAUREN At The Enemy's Gates
            [questKeys.preQuestSingle] = {13694,13709},
            [questKeys.exclusiveTo] = {13728,13856,13857,13859,13860},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_MOUNT_UP, l10n("Mount up"), 0, {{"monster", 34125}}}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [13859] = { -- BLOOD ELF At The Enemy's Gates
            [questKeys.preQuestSingle] = {13696,13711},
            [questKeys.exclusiveTo] = {13731,13856,13857,13858,13860},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_MOUNT_UP, l10n("Mount up"), 0, {{"monster", 34125}}}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [13860] = { -- UNDEAD At The Enemy's Gates
            [questKeys.preQuestSingle] = {13695,13710},
            [questKeys.exclusiveTo] = {13729,13856,13857,13858,13859},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_MOUNT_UP, l10n("Mount up"), 0, {{"monster", 34125}}}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [13861] = { -- Battle Before The Citadel
            [questKeys.preQuestSingle] = {13700},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_MOUNT_UP, l10n("Mount up"), 0, {{"monster", 34125}}}},
        },
        [13862] = { -- Battle Before The Citadel
            [questKeys.preQuestSingle] = {13701},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_MOUNT_UP, l10n("Mount up"), 0, {{"monster", 34125}}}},
        },
        [13863] = { -- Battle Before The Citadel
            [questKeys.preQuestSingle] = {13701},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_MOUNT_UP, l10n("Mount up"), 0, {{"monster", 34125}}}},
        },
        [13864] = { -- Battle Before The Citadel
            [questKeys.preQuestSingle] = {13700},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_MOUNT_UP, l10n("Mount up"), 0, {{"monster", 34125}}}},
        },
        [13887] = { -- Venomhide Eggs
            [questKeys.preQuestSingle] = {13850},
        },
        [13906] = { -- They Grow Up So Fast
            [questKeys.preQuestSingle] = {13887},
        },
        [13929] = { -- The Biggest Tree Ever!
            [questKeys.triggerEnd] = {"Roo taken to visit Grizzlemaw", {[zoneIDs.GRIZZLY_HILLS]={{50.7,43.9}}}}, -- oracle orphan
            [questKeys.preQuestSingle] = {13926},
            [questKeys.exclusiveTo] = {13927},
        },
        [13930] = { -- Home Of The Bear-Men
            [questKeys.triggerEnd] = {"Keken taken to visit Grizzlemaw", {[zoneIDs.GRIZZLY_HILLS]={{50.7,43.9}}}}, -- wolvar orphan
            [questKeys.preQuestSingle] = {13927},
            [questKeys.exclusiveTo] = {13926},
        },
        [13931] = { -- Another Year, Another Souvenir.
            [questKeys.preQuestSingle] = {11409},
        },
        [13932] = { -- Another Year, Another Souvenir.
            [questKeys.preQuestSingle] = {11318},
        },
        [13933] = { -- The Bronze Dragonshrine
            [questKeys.triggerEnd] = {"Roo taken to visit Bronze Dragonshrine", {[zoneIDs.DRAGONBLIGHT]={{72,39}}}}, -- oracle orphan
            [questKeys.preQuestSingle] = {13926},
            [questKeys.exclusiveTo] = {13927},
        },
        [13934] = { -- The Bronze Dragonshrine
            [questKeys.triggerEnd] = {"Keken taken to visit Bronze Dragonshrine", {[zoneIDs.DRAGONBLIGHT]={{72,39}}}}, -- wolvar orphan
            [questKeys.preQuestSingle] = {13927},
            [questKeys.exclusiveTo] = {13926},
        },
        [13937] = { -- A Trip To The Wonderworks
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_LOOT, l10n("Buy a Small Paper Zeppelin"), 0, {{"monster", 29478}}}},
            [questKeys.objectives] = {{{33533,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.preQuestGroup] = {13954,13956},
            [questKeys.nextQuestInChain] = 13959,
            [questKeys.exclusiveTo] = {13927},
            [questKeys.requiredSourceItems] = {46693},
            [questKeys.sourceItemId] = 46397,
        },
        [13938] = { -- A Visit To The Wonderworks
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_LOOT, l10n("Buy a Small Paper Zeppelin"), 0, {{"monster", 29478}}}},
            [questKeys.objectives] = {{{33532,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.preQuestGroup] = {13955,13957},
            [questKeys.nextQuestInChain] = 13960,
            [questKeys.exclusiveTo] = {13926},
            [questKeys.requiredSourceItems] = {46693},
            [questKeys.sourceItemId] = 46396,
        },
        [13950] = { -- Playmates!
            [questKeys.triggerEnd] = {"Roo taken to visit Winterfin Retreat", {[zoneIDs.BOREAN_TUNDRA]={{43.5,13.6}}}}, -- oracle orphan
            [questKeys.preQuestSingle] = {13926},
            [questKeys.exclusiveTo] = {13927},
        },
        [13951] = { -- Playmates!
            [questKeys.triggerEnd] = {"Keken taken to visit Snowfall Glade", {[zoneIDs.DRAGONBLIGHT]={{46,61},{44,70}}}}, -- wolvar orphan
            [questKeys.preQuestSingle] = {13927},
            [questKeys.exclusiveTo] = {13926},
        },
        [13954] = { -- The Dragon Queen
            [questKeys.objectives] = {{{26917,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.preQuestGroup] = {13929,13933,13950},
            [questKeys.exclusiveTo] = {13927},
        },
        [13955] = { -- The Dragon Queen
            [questKeys.objectives] = {{{26917,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.preQuestGroup] = {13930,13934,13951},
            [questKeys.exclusiveTo] = {13926},
        },
        [13956] = { -- Meeting a Great One
            [questKeys.objectives] = {{{28092,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.extraObjectives] = {{{[zoneIDs.SHOLAZAR_BASIN]={{40.3,83.3}}}, Questie.ICON_TYPE_EVENT, l10n("Use the waygate to teleport to Un'goro Crater")}},
            [questKeys.preQuestGroup] = {13929,13933,13950},
            [questKeys.exclusiveTo] = {13927},
        },
        [13957] = { -- The Mighty Hemet Nesingwary
            [questKeys.objectives] = {{{27986,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.preQuestGroup] = {13930,13934,13951},
            [questKeys.exclusiveTo] = {13926},
        },
        [13959] = { -- Back To The Orphanage
            [questKeys.preQuestSingle] = {13937},
            [questKeys.exclusiveTo] = {13927},
        },
        [13960] = { -- Back To The Orphanage
            [questKeys.preQuestSingle] = {13938},
            [questKeys.exclusiveTo] = {13926},
        },
        [13966] = { -- A Winter Veil Gift
            [questKeys.exclusiveTo] = {11528,13203},
        },
        [14016] = { -- The Black Knight's Curse
            [questKeys.specialFlags] = nil,
            [questKeys.questFlags] = 128,
            [questKeys.objectives] = {{{35127}}},
        },
        [14023] = { -- Spice Bread Stuffing
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.PILGRIMS_BOUNTY,
            [questKeys.nextQuestInChain] = 14024,
        },
        [14024] = { -- Pumpkin Pie
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.PILGRIMS_BOUNTY,
            [questKeys.nextQuestInChain] = 14028,
            [questKeys.preQuestSingle] = {14023},
        },
        [14028] = { -- Cranberry Chutney
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.PILGRIMS_BOUNTY,
            [questKeys.nextQuestInChain] = 14030,
            [questKeys.preQuestSingle] = {14024},
        },
        [14030] = { -- They're Ravenous In Darnassus
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.PILGRIMS_BOUNTY,
            [questKeys.nextQuestInChain] = 14033,
            [questKeys.preQuestSingle] = {14028},
        },
        [14033] = { -- Candied Sweet Potatoes
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.PILGRIMS_BOUNTY,
            [questKeys.nextQuestInChain] = 14035,
            [questKeys.preQuestSingle] = {14030},
        },
        [14035] = { -- Slow-roasted Turkey
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.PILGRIMS_BOUNTY,
            [questKeys.preQuestSingle] = {14033},
        },
        [14037] = { -- Spice Bread Stuffing
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.PILGRIMS_BOUNTY,
            [questKeys.nextQuestInChain] = 14040,
        },
        [14040] = { -- Pumpkin Pie
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.PILGRIMS_BOUNTY,
            [questKeys.nextQuestInChain] = 14041,
            [questKeys.preQuestSingle] = {14037},
        },
        [14041] = { -- Cranberry Chutney
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.PILGRIMS_BOUNTY,
            [questKeys.nextQuestInChain] = 14043,
            [questKeys.preQuestSingle] = {14040},
        },
        [14043] = { -- Candied Sweet Potatoes
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.PILGRIMS_BOUNTY,
            [questKeys.nextQuestInChain] = 14044,
            [questKeys.preQuestSingle] = {14041},
        },
        [14044] = { -- Undersupplied in the Undercity
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.PILGRIMS_BOUNTY,
            [questKeys.nextQuestInChain] = 14047,
            [questKeys.preQuestSingle] = {14043},
        },
        [14047] = { -- Slow-roasted Turkey
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.PILGRIMS_BOUNTY,
            [questKeys.preQuestSingle] = {14044},
        },
        [14048] = { -- Can't Get Enough Turkey
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.PILGRIMS_BOUNTY,
        },
        [14051] = { -- Don't Forget The Stuffing!
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.PILGRIMS_BOUNTY,
        },
        [14053] = { -- We're Out of Cranberry Chutney Again?
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.PILGRIMS_BOUNTY,
        },
        [14054] = { -- Easy As Pie
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.PILGRIMS_BOUNTY,
        },
        [14055] = { -- She Says Potato
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.PILGRIMS_BOUNTY,
        },
        [14058] = { -- She Says Potato
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.PILGRIMS_BOUNTY,
        },
        [14059] = { -- We're Out of Cranberry Chutney Again?
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.PILGRIMS_BOUNTY,
        },
        [14060] = { -- Easy As Pie
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.PILGRIMS_BOUNTY,
        },
        [14061] = { -- Can't Get Enough Turkey
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.PILGRIMS_BOUNTY,
        },
        [14062] = { -- Don't Forget The Stuffing!
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.PILGRIMS_BOUNTY,
        },
        [14064] = { -- Sharing a Bountiful Feast
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.zoneOrSort] = sortKeys.PILGRIMS_BOUNTY,
        },
        [14065] = { -- Sharing a Bountiful Feast
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.zoneOrSort] = sortKeys.PILGRIMS_BOUNTY,
        },
        [14076] = { -- Breakfast Of Champions
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use your drum near a Mysterious Snow Mound"), 0, {{"object", 195309}}}},
            [questKeys.requiredSourceItems] = {},
        },
        [14077] = { -- The Light's Mercy
            [questKeys.objectives] = {{{34852,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [14079] = { -- Learn to Ride in Elwynn Forest
            [questKeys.requiredRaces] = raceIDs.HUMAN,
        },
        [14081] = { -- Learn to Ride in the Eversong Woods
            [questKeys.requiredRaces] = raceIDs.BLOOD_ELF,
        },
        [14082] = { -- Learn to Ride at the Exodar
            [questKeys.requiredRaces] = raceIDs.DRAENEI,
        },
        [14083] = { -- Learn to Ride in Dun Morogh
            [questKeys.requiredRaces] = raceIDs.DWARF,
        },
        [14084] = { -- Learn to Ride in Dun Morogh
            [questKeys.requiredRaces] = raceIDs.GNOME,
        },
        [14085] = { -- Learn to Ride in Darnassus
            [questKeys.requiredRaces] = raceIDs.NIGHT_ELF,
        },
        [14086] = { -- Learn to Ride in Orgrimmar
            [questKeys.requiredRaces] = raceIDs.ORC,
        },
        [14087] = { -- Learn to Ride in Mulgore
            [questKeys.requiredRaces] = raceIDs.TAUREN,
        },
        [14088] = { -- Learn to Ride in Durotar
            [questKeys.requiredRaces] = raceIDs.TROLL,
        },
        [14089] = { -- Learn to Ride in Tirisfal Glades
            [questKeys.requiredRaces] = raceIDs.UNDEAD,
        },
        [14090] = { -- Gormok Wants His Snobolds
            [questKeys.objectives] = {{{29618,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.requiredSourceItems] = {},
        },
        [14092] = { -- Breakfast Of Champions
            [questKeys.exclusiveTo] = {14141,14145},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Use your drum near a Mysterious Snow Mound"), 0, {{"object", 195309}}}},
            [questKeys.requiredSourceItems] = {},
        },
        [14101] = { -- Drottinn Hrothgar
            [questKeys.extraObjectives] = {{{[zoneIDs.HROTHGARS_LANDING]={{50.4,15.6}}}, Questie.ICON_TYPE_EVENT, l10n("Summon Drottinn Hrothgar using the Kvaldir War Horn")}},
            [questKeys.requiredSourceItems] = {},
        },
        [14102] = { -- Mistcaller Yngvar
            [questKeys.extraObjectives] = {{{[zoneIDs.HROTHGARS_LANDING]={{43.8,24.6}}}, Questie.ICON_TYPE_EVENT, l10n("Summon Mistcaller Yngvar using the Mistcaller's Charm")}},
            [questKeys.requiredSourceItems] = {},
        },
        [14103] = { -- Titanium Powder
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.startedBy] = {{28701}},
            [questKeys.finishedBy] = {{28701}},
        },
        [14104] = { -- Ornolf The Scarred
            [questKeys.extraObjectives] = {{{[zoneIDs.HROTHGARS_LANDING]={{58.59,31.72}}}, Questie.ICON_TYPE_EVENT, l10n("Provoke Ornolf the Scarred using the Captured Kvaldir Banner")}},
            [questKeys.requiredSourceItems] = {},
        },
        [14107] = { -- The Fate Of The Fallen
            [questKeys.objectives] = {nil,nil,nil,nil,{{{32149},32149,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.requiredSourceItems] = {47035},
        },
        [14108] = { -- Get Kraken!
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_MOUNT_UP, l10n("Mount up"), 0, {{"monster", 35117}}}},
            [questKeys.objectives] = {{{34925,nil,Questie.ICON_TYPE_INTERACT},{35092}}},
        },
        [14112] = { -- What Do You Feed a Yeti, Anyway?
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_LOOT, l10n("Take chum"), 0, {{"object", 195352}}}},
        },
        [14136] = { -- Rescue at Sea
            [questKeys.exclusiveTo] = {14140,14144,14143},
        },
        [14140] = { -- Stop The Aggressors
            [questKeys.exclusiveTo] = {14144,14136,14143},
        },
        [14141] = { -- Gormok Wants His Snobolds
            [questKeys.exclusiveTo] = {14092,14145},
            [questKeys.objectives] = {{{29618,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.requiredSourceItems] = {},
        },
        [14143] = { -- A Leg Up
            [questKeys.exclusiveTo] = {14136,14140,14144},
        },
        [14144] = { -- The Light's Mercy
            [questKeys.exclusiveTo] = {14136,14140,14143},
            [questKeys.objectives] = {{{34852,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [14145] = { -- What Do You Feed a Yeti, Anyway?
            [questKeys.exclusiveTo] = {14092,14141},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_LOOT, l10n("Take chum"), 0, {{"object", 195353}}}},
        },
        [14151] = { -- Cardinal Ruby
            [questKeys.objectives] = {},
            [questKeys.requiredSpell] = -66659,
            [questKeys.requiredSkill] = {171,450},
            [questKeys.triggerEnd] = {"Epic Gem Transmutes", {[zoneIDs.DALARAN]={{42.25,32.06}}}},
        },
        [14163] = { -- Call to Arms: Isle of Conquest
            [questKeys.triggerEnd] = {"Victory in the Isle of Conquest", {
                [zoneIDs.IRONFORGE]={{70.41,91.10}},
                [zoneIDs.SHATTRATH_CITY]={{67.41,33.86}},
                [zoneIDs.DARNASSUS]={{58.02,34.52}},
                [zoneIDs.THE_EXODAR]={{26.6,50.06}},
                [zoneIDs.STORMWIND_CITY]={{83.47,33.66}},
                [zoneIDs.DALARAN]={{29.79,75.78}},
                [zoneIDs.WINTERGRASP]={{50.02,15.16}},
            }},
            [questKeys.exclusiveTo] = {11335,11336,11337,11338,13405},
        },
        [14164] = { -- Call to Arms: Isle of Conquest
            [questKeys.triggerEnd] = {"Victory in the Isle of Conquest", {
                [zoneIDs.ORGRIMMAR]={{80.68,30.51},{36.94,65.36}},
                [zoneIDs.THUNDER_BLUFF]={{57.8,76.4}},
                [zoneIDs.UNDERCITY]={{58.27,97.9}},
                [zoneIDs.SILVERMOON_CITY]={{97,38.3}},
                [zoneIDs.SHATTRATH_CITY]={{66.96,56.6}},
                [zoneIDs.DALARAN]={{58.19,20.59}},
                [zoneIDs.WINTERGRASP]={{50.02,15.16}},
            }},
            [questKeys.startedBy] = {{15350}},
            [questKeys.finishedBy] = {{15350}},
            [questKeys.exclusiveTo] = {11339,11340,11341,11342,13407},
        },
        [14178] = { -- Call to Arms: Arathi Basin
            [questKeys.triggerEnd] = {"Victory in Arathi Basin", {
                [zoneIDs.IRONFORGE]={{70.41,91.10}},
                [zoneIDs.SHATTRATH_CITY]={{67.41,33.86}},
                [zoneIDs.DARNASSUS]={{58.02,34.52}},
                [zoneIDs.THE_EXODAR]={{26.6,50.06}},
                [zoneIDs.STORMWIND_CITY]={{83.47,33.66}},
                [zoneIDs.DALARAN]={{29.79,75.78}},
                [zoneIDs.WINTERGRASP]={{50.02,15.16}},
                [zoneIDs.ARATHI_HIGHLANDS]={{45.6,45.8}},
            }},
            [questKeys.requiredMaxLevel] = 70,
            [questKeys.exclusiveTo] = {14179,14180,13427},
        },
        [14179] = { -- Call to Arms: Eye of the Storm
            [questKeys.triggerEnd] = {"Victory in the Eye of the Storm", {
                [zoneIDs.IRONFORGE]={{70.41,91.10}},
                [zoneIDs.SHATTRATH_CITY]={{67.41,33.86}},
                [zoneIDs.DARNASSUS]={{58.02,34.52}},
                [zoneIDs.THE_EXODAR]={{26.6,50.06}},
                [zoneIDs.STORMWIND_CITY]={{83.47,33.66}},
                [zoneIDs.DALARAN]={{29.79,75.78}},
                [zoneIDs.WINTERGRASP]={{50.02,15.16}},
            }},
            [questKeys.requiredMaxLevel] = 70,
            [questKeys.exclusiveTo] = {14178,14179,13427},
        },
        [14180] = { -- Call to Arms: Warsong Gulch
            [questKeys.triggerEnd] = {"Victory in Warsong Gulch", {
                [zoneIDs.IRONFORGE]={{70.41,91.10}},
                [zoneIDs.SHATTRATH_CITY]={{67.41,33.86}},
                [zoneIDs.DARNASSUS]={{58.02,34.52}},
                [zoneIDs.THE_EXODAR]={{26.6,50.06}},
                [zoneIDs.STORMWIND_CITY]={{83.47,33.66}},
                [zoneIDs.DALARAN]={{29.79,75.78}},
                [zoneIDs.WINTERGRASP]={{50.02,15.16}},
                [zoneIDs.ASHENVALE]={{61.8,83.8}},
            }},
            [questKeys.requiredMaxLevel] = 70,
            [questKeys.exclusiveTo] = {14178,14179,13427},
        },
        [14181] = { -- Call to Arms: Arathi Basin
            [questKeys.triggerEnd] = {"Victory in Arathi Basin", {
                [zoneIDs.ORGRIMMAR]={{80.68,30.51},{36.94,65.36}},
                [zoneIDs.THUNDER_BLUFF]={{57.8,76.4}},
                [zoneIDs.UNDERCITY]={{58.27,97.9}},
                [zoneIDs.SILVERMOON_CITY]={{97,38.3}},
                [zoneIDs.SHATTRATH_CITY]={{66.96,56.6}},
                [zoneIDs.DALARAN]={{58.19,20.59}},
                [zoneIDs.WINTERGRASP]={{50.02,15.16}},
                [zoneIDs.ARATHI_HIGHLANDS]={{73.3,30}},
            }},
            [questKeys.startedBy] = {{15350}},
            [questKeys.finishedBy] = {{15350}},
            [questKeys.requiredMaxLevel] = 70,
            [questKeys.exclusiveTo] = {13428,14182,14183},
        },
        [14182] = { -- Call to Arms: Eye of the Storm
            [questKeys.triggerEnd] = {"Victory in Eye of the Storm", {
                [zoneIDs.ORGRIMMAR]={{80.68,30.51},{36.94,65.36}},
                [zoneIDs.THUNDER_BLUFF]={{57.8,76.4}},
                [zoneIDs.UNDERCITY]={{58.27,97.9}},
                [zoneIDs.SILVERMOON_CITY]={{97,38.3}},
                [zoneIDs.SHATTRATH_CITY]={{66.96,56.6}},
                [zoneIDs.DALARAN]={{58.19,20.59}},
                [zoneIDs.WINTERGRASP]={{50.02,15.16}},
            }},
            [questKeys.startedBy] = {{15350}},
            [questKeys.finishedBy] = {{15350}},
            [questKeys.requiredMaxLevel] = 70,
            [questKeys.exclusiveTo] = {13428,14181,14183},
        },
        [14183] = { -- Call to Arms: Warsong Gulch
            [questKeys.triggerEnd] = {"Victory in Warsong Gulch", {
                [zoneIDs.ORGRIMMAR]={{80.68,30.51},{36.94,65.36}},
                [zoneIDs.THUNDER_BLUFF]={{57.8,76.4}},
                [zoneIDs.UNDERCITY]={{58.27,97.9}},
                [zoneIDs.SILVERMOON_CITY]={{97,38.3}},
                [zoneIDs.SHATTRATH_CITY]={{66.96,56.6}},
                [zoneIDs.DALARAN]={{58.19,20.59}},
                [zoneIDs.WINTERGRASP]={{50.02,15.16}},
                [zoneIDs.THE_BARRENS]={{47,9.3}},
            }},
            [questKeys.startedBy] = {{15350}},
            [questKeys.finishedBy] = {{15350}},
            [questKeys.requiredMaxLevel] = 70,
            [questKeys.exclusiveTo] = {13428,14181,14182},
        },
        [14199] = { -- Proof of Demise: The Black Knight
            [questKeys.startedBy] = {{20735}},
            [questKeys.finishedBy] = {{20735}},
            [questKeys.exclusiveTo] = {13245,13246,13247,13248,13249,13250,13251,13252,13253,13254,13255,13256},
        },
        [14352] = { -- An Unholy Alliance
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [14349] = { -- The Call to Command
            [questKeys.preQuestGroup] = {6022,6042,6133,6135,6136},
        },
        [14418] = { -- The Deathstalkers
            [questKeys.requiredRaces] = raceIDs.UNDEAD,
        },
        [14419] = { -- The Deathstalkers
            [questKeys.requiredRaces] = raceIDs.UNDEAD,
        },
        [14420] = { -- The Deathstalkers
            [questKeys.requiredRaces] = raceIDs.UNDEAD,
            [questKeys.breadcrumbs] = {1885},
        },
        [14421] = { -- The Deathstalkers
            [questKeys.requiredRaces] = raceIDs.UNDEAD,
        },
        [14444] = { -- What The Dragons Know
            [questKeys.objectives] = {{{27990,nil,Questie.ICON_TYPE_TALK}}},
        },
        [14483] = { -- Something is in the Air (and it Ain't Love)
            [questKeys.startedBy] = {nil,nil,{49641}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [20438] = { -- A Suitable Disguise
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Ask Shandy Glossgleam to lend you a tabard"), 0, {{"monster", 36856}}}},
        },
        [24216] = { -- Call to Arms: Warsong Gulch
            [questKeys.triggerEnd] = {"Victory in Warsong Gulch", {
                [zoneIDs.ORGRIMMAR]={{80.68,30.51},{36.94,65.36}},
                [zoneIDs.THUNDER_BLUFF]={{57.8,76.4}},
                [zoneIDs.UNDERCITY]={{58.27,97.9}},
                [zoneIDs.SILVERMOON_CITY]={{97,38.3}},
                [zoneIDs.SHATTRATH_CITY]={{66.96,56.6}},
                [zoneIDs.DALARAN]={{58.19,20.59}},
                [zoneIDs.WINTERGRASP]={{50.02,15.16}},
                [zoneIDs.THE_BARRENS]={{47,9.3}},
            }},
            [questKeys.startedBy] = {{15350}},
            [questKeys.finishedBy] = {{15350}},
            [questKeys.requiredMaxLevel] = 50,
            [questKeys.exclusiveTo] = {24221},
        },
        [24217] = { -- Call to Arms: Warsong Gulch
            [questKeys.triggerEnd] = {"Victory in Warsong Gulch", {
                [zoneIDs.ORGRIMMAR]={{80.68,30.51},{36.94,65.36}},
                [zoneIDs.THUNDER_BLUFF]={{57.8,76.4}},
                [zoneIDs.UNDERCITY]={{58.27,97.9}},
                [zoneIDs.SILVERMOON_CITY]={{97,38.3}},
                [zoneIDs.SHATTRATH_CITY]={{66.96,56.6}},
                [zoneIDs.DALARAN]={{58.19,20.59}},
                [zoneIDs.WINTERGRASP]={{50.02,15.16}},
                [zoneIDs.THE_BARRENS]={{47,9.3}},
            }},
            [questKeys.startedBy] = {{15350}},
            [questKeys.finishedBy] = {{15350}},
            [questKeys.requiredMaxLevel] = 20,
        },
        [24218] = { -- Call to Arms: Warsong Gulch
            [questKeys.triggerEnd] = {"Victory in Warsong Gulch", {
                [zoneIDs.IRONFORGE]={{70.41,91.10}},
                [zoneIDs.SHATTRATH_CITY]={{67.41,33.86}},
                [zoneIDs.DARNASSUS]={{58.02,34.52}},
                [zoneIDs.THE_EXODAR]={{26.6,50.06}},
                [zoneIDs.STORMWIND_CITY]={{83.47,33.66}},
                [zoneIDs.DALARAN]={{29.79,75.78}},
                [zoneIDs.WINTERGRASP]={{50.02,15.16}},
                [zoneIDs.ASHENVALE]={{61.8,83.8}},
            }},
            [questKeys.startedBy] = {{15351}},
            [questKeys.finishedBy] = {{15351}},
            [questKeys.requiredMaxLevel] = 50,
            [questKeys.exclusiveTo] = {24220},
        },
        [24219] = { -- Call to Arms: Warsong Gulch
            [questKeys.triggerEnd] = {"Victory in Warsong Gulch", {
                [zoneIDs.IRONFORGE]={{70.41,91.10}},
                [zoneIDs.SHATTRATH_CITY]={{67.41,33.86}},
                [zoneIDs.DARNASSUS]={{58.02,34.52}},
                [zoneIDs.THE_EXODAR]={{26.6,50.06}},
                [zoneIDs.STORMWIND_CITY]={{83.47,33.66}},
                [zoneIDs.DALARAN]={{29.79,75.78}},
                [zoneIDs.WINTERGRASP]={{50.02,15.16}},
                [zoneIDs.ASHENVALE]={{61.8,83.8}},
            }},
            [questKeys.startedBy] = {{15351}},
            [questKeys.finishedBy] = {{15351}},
            [questKeys.requiredMaxLevel] = 20,
        },
        [24220] = { -- Call to Arms: Arathi Basin
            [questKeys.triggerEnd] = {"Victory in Arathi Basin", {
                [zoneIDs.IRONFORGE]={{70.41,91.10}},
                [zoneIDs.SHATTRATH_CITY]={{67.41,33.86}},
                [zoneIDs.DARNASSUS]={{58.02,34.52}},
                [zoneIDs.THE_EXODAR]={{26.6,50.06}},
                [zoneIDs.STORMWIND_CITY]={{83.47,33.66}},
                [zoneIDs.DALARAN]={{29.79,75.78}},
                [zoneIDs.WINTERGRASP]={{50.02,15.16}},
                [zoneIDs.ARATHI_HIGHLANDS]={{45.6,45.8}},
            }},
            [questKeys.startedBy] = {{15351}},
            [questKeys.finishedBy] = {{15351}},
            [questKeys.requiredMaxLevel] = 50,
            [questKeys.exclusiveTo] = {24218},
        },
        [24221] = { -- Call to Arms: Arathi Basin
            [questKeys.triggerEnd] = {"Victory in Arathi Basin", {
                [zoneIDs.ORGRIMMAR]={{80.68,30.51},{36.94,65.36}},
                [zoneIDs.THUNDER_BLUFF]={{57.8,76.4}},
                [zoneIDs.UNDERCITY]={{58.27,97.9}},
                [zoneIDs.SILVERMOON_CITY]={{97,38.3}},
                [zoneIDs.SHATTRATH_CITY]={{66.96,56.6}},
                [zoneIDs.DALARAN]={{58.19,20.59}},
                [zoneIDs.WINTERGRASP]={{50.02,15.16}},
                [zoneIDs.ARATHI_HIGHLANDS]={{73.3,30}},
            }},
            [questKeys.startedBy] = {{15350}},
            [questKeys.finishedBy] = {{15350}},
            [questKeys.requiredMaxLevel] = 50,
            [questKeys.exclusiveTo] = {24216},
        },
        [24223] = { -- Call to Arms: Arathi Basin
            [questKeys.triggerEnd] = {"Victory in Arathi Basin", {
                [zoneIDs.IRONFORGE]={{70.41,91.10}},
                [zoneIDs.SHATTRATH_CITY]={{67.41,33.86}},
                [zoneIDs.DARNASSUS]={{58.02,34.52}},
                [zoneIDs.THE_EXODAR]={{26.6,50.06}},
                [zoneIDs.STORMWIND_CITY]={{83.47,33.66}},
                [zoneIDs.DALARAN]={{29.79,75.78}},
                [zoneIDs.WINTERGRASP]={{50.02,15.16}},
                [zoneIDs.ARATHI_HIGHLANDS]={{45.6,45.8}},
            }},
            [questKeys.startedBy] = {{15351}},
            [questKeys.finishedBy] = {{15351}},
            [questKeys.requiredMaxLevel] = 60,
            [questKeys.exclusiveTo] = {24224,24427},
        },
        [24224] = { -- Call to Arms: Warsong Gulch
            [questKeys.triggerEnd] = {"Victory in Warsong Gulch", {
                [zoneIDs.IRONFORGE]={{70.41,91.10}},
                [zoneIDs.SHATTRATH_CITY]={{67.41,33.86}},
                [zoneIDs.DARNASSUS]={{58.02,34.52}},
                [zoneIDs.THE_EXODAR]={{26.6,50.06}},
                [zoneIDs.STORMWIND_CITY]={{83.47,33.66}},
                [zoneIDs.DALARAN]={{29.79,75.78}},
                [zoneIDs.WINTERGRASP]={{50.02,15.16}},
                [zoneIDs.ASHENVALE]={{61.8,83.8}},
            }},
            [questKeys.startedBy] = {{15351}},
            [questKeys.finishedBy] = {{15351}},
            [questKeys.requiredMaxLevel] = 60,
            [questKeys.exclusiveTo] = {24223,24427},
        },
        [24225] = { -- Call to Arms: Warsong Gulch
            [questKeys.triggerEnd] = {"Victory in Warsong Gulch", {
                [zoneIDs.ORGRIMMAR]={{80.68,30.51},{36.94,65.36}},
                [zoneIDs.THUNDER_BLUFF]={{57.8,76.4}},
                [zoneIDs.UNDERCITY]={{58.27,97.9}},
                [zoneIDs.SILVERMOON_CITY]={{97,38.3}},
                [zoneIDs.SHATTRATH_CITY]={{66.96,56.6}},
                [zoneIDs.DALARAN]={{58.19,20.59}},
                [zoneIDs.WINTERGRASP]={{50.02,15.16}},
                [zoneIDs.THE_BARRENS]={{47,9.3}},
            }},
            [questKeys.startedBy] = {{15350}},
            [questKeys.finishedBy] = {{15350}},
            [questKeys.requiredMaxLevel] = 60,
            [questKeys.exclusiveTo] = {24226,24426},
        },
        [24226] = { -- Call to Arms: Arathi Basin
            [questKeys.triggerEnd] = {"Victory in Arathi Basin", {
                [zoneIDs.ORGRIMMAR]={{80.68,30.51},{36.94,65.36}},
                [zoneIDs.THUNDER_BLUFF]={{57.8,76.4}},
                [zoneIDs.UNDERCITY]={{58.27,97.9}},
                [zoneIDs.SILVERMOON_CITY]={{97,38.3}},
                [zoneIDs.SHATTRATH_CITY]={{66.96,56.6}},
                [zoneIDs.DALARAN]={{58.19,20.59}},
                [zoneIDs.WINTERGRASP]={{50.02,15.16}},
                [zoneIDs.ARATHI_HIGHLANDS]={{73.3,30}},
            }},
            [questKeys.startedBy] = {{15350}},
            [questKeys.finishedBy] = {{15350}},
            [questKeys.requiredMaxLevel] = 60,
            [questKeys.exclusiveTo] = {24225,24426},
        },
        [24426] = { -- Call to Arms: Alterac Valley
            [questKeys.triggerEnd] = {"Victory in Alterac Valley", {
                [zoneIDs.ORGRIMMAR]={{80.68,30.51},{36.94,65.36}},
                [zoneIDs.THUNDER_BLUFF]={{57.8,76.4}},
                [zoneIDs.UNDERCITY]={{58.27,97.9}},
                [zoneIDs.SILVERMOON_CITY]={{97,38.3}},
                [zoneIDs.SHATTRATH_CITY]={{66.96,56.6}},
                [zoneIDs.DALARAN]={{58.19,20.59}},
                [zoneIDs.WINTERGRASP]={{50.02,15.16}},
                [zoneIDs.ALTERAC_MOUNTAINS]={{63.3,60.2}},
            }},
            [questKeys.startedBy] = {{15350}},
            [questKeys.finishedBy] = {{15350}},
            [questKeys.requiredMaxLevel] = 60,
            [questKeys.exclusiveTo] = {24225,24226},
        },
        [24427] = { -- Call to Arms: Alterac Valley
            [questKeys.triggerEnd] = {"Victory in Alterac Valley", {
                [zoneIDs.IRONFORGE]={{70.41,91.10}},
                [zoneIDs.SHATTRATH_CITY]={{67.41,33.86}},
                [zoneIDs.DARNASSUS]={{58.02,34.52}},
                [zoneIDs.THE_EXODAR]={{26.6,50.06}},
                [zoneIDs.STORMWIND_CITY]={{83.47,33.66}},
                [zoneIDs.DALARAN]={{29.79,75.78}},
                [zoneIDs.WINTERGRASP]={{50.02,15.16}},
                [zoneIDs.ALTERAC_MOUNTAINS]={{39.4,82.2}},
            }},
            [questKeys.startedBy] = {{15351}},
            [questKeys.finishedBy] = {{15351}},
            [questKeys.requiredMaxLevel] = 60,
            [questKeys.exclusiveTo] = {24223,24224},
        },
        [24428] = { -- A Most Puzzling Circumstance
            [questKeys.startedBy] = {nil,nil,{49644}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [24429] = { -- A Most Puzzling Circumstance
            [questKeys.startedBy] = {nil,nil,{49643}},
        },
        [24431] = { -- Waterlogged Recipe
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [24442] = { -- Battle Plans Of The Kvaldir
            [questKeys.startedBy] = {nil,nil,{49676}},
        },
        [24461] = { -- Reforging The Sword
            [questKeys.requiredSourceItems] = {49718,49723},
        },
        [24476] = { -- Tempering The Blade
            [questKeys.requiredSourceItems] = {},
        },
        [24480] = { -- The Halls Of Reflection
            [questKeys.requiredSourceItems] = {},
        },
        [24498] = { -- The Path to the Citadel
            [questKeys.objectives] = {{{36494}},nil,nil,nil,{{{36764,36765,36766,36767},36764,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.preQuestSingle] = {24683},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Free the slave"), 1, {{"object", 202168}}}},
        },
        [24499] = { -- Echoes of Tortured Souls
            [questKeys.objectives] = {{{36497},{36502}}},
        },
        [24500] = { -- Wrath of the Lich King
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.finishedBy] = {{36955}},
            [questKeys.objectives] = {{{36955,nil,Questie.ICON_TYPE_EVENT},{36954,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [24507] = { -- The Path to the Citadel
            [questKeys.objectives] = {{{36494}},nil,nil,nil,{{{36770,36771,36772,36773},36770,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Free the slave"), 1, {{"object", 202168}}}},
        },
        [24510] = { -- Inside the Frozen Citadel
            [questKeys.reputationReward] = {{1050,25}},
        },
        [24511] = { -- Echoes of Tortured Souls
            [questKeys.objectives] = {{{36497},{36502}}},
        },
        [24535] = { -- Thalorien Dawnseeker
            [questKeys.objectives] = {{{37205,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Examine the remains"), 0, {{"monster", 37552}}}},
        },
        [24536] = { -- Something Stinks
            [questKeys.objectives] = {{{3296,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Use Snagglebolt's Air Analyzer on perfumed guards"), 0, {{"monster", 3296}}}},
            [questKeys.requiredSourceItems] = {},
        },
        [24541] = { -- Pilfering Perfume
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Grab the package"), 0, {{"monster", 37671}}}},
            [questKeys.sourceItemId] = 49867,
        },
        [24545] = { -- The Sacred and the Corrupt
            [questKeys.requiredClasses] = classIDs.WARRIOR + classIDs.PALADIN + classIDs.DEATH_KNIGHT,
            [questKeys.startedBy] = {{37120}},
            [questKeys.finishedBy] = {nil,{201742}},
            [questKeys.nextQuestInChain] = 24743,
            [questKeys.requiredMinRep] = {1156,3000},
        },
        [24547] = { -- A Feast of Souls
            [questKeys.startedBy] = {{37120}},
            [questKeys.finishedBy] = {{37120}},
            [questKeys.preQuestSingle] = {24743},
        },
        [24548] = { -- The Splintered Throne
            [questKeys.startedBy] = {{37120}},
            [questKeys.finishedBy] = {{37120}},
            [questKeys.preQuestSingle] = {24757},
            [questKeys.nextQuestInChain] = 24912,
        },
        [24549] = { -- Shadowmourne...
            [questKeys.startedBy] = {{37120}},
            [questKeys.finishedBy] = {{37120}},
            [questKeys.preQuestSingle] = {24912},
            [questKeys.nextQuestInChain] = 24748,
        },
        [24553] = { -- The Purification of Quel'Delar
            [questKeys.requiredClasses] = classIDs.WARRIOR + classIDs.PALADIN + classIDs.ROGUE + classIDs.HUNTER + classIDs.DEATH_KNIGHT + classIDs.MAGE + classIDs.WARLOCK,
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_TALK, l10n("Ask the warden to take you to the Sunwell"), 0, {{"monster", 37523}}},
                {nil, Questie.ICON_TYPE_EVENT, l10n("After restoring Quel'Delar, go back to Dalaran"), 0, {{"object", 194481}}},
            },
        },
        [24555] = { -- What The Dragons Know
            [questKeys.objectives] = {{{27990,nil,Questie.ICON_TYPE_TALK}}},
        },
        [24556] = { -- A Suitable Disguise
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Ask Shandy Glossgleam to lend you a tabard"), 0, {{"monster", 36856}}}},
        },
        [24559] = { -- Reforging The Sword
            [questKeys.requiredSourceItems] = {49718,49723},
        },
        [24560] = { -- Tempering The Blade
            [questKeys.requiredSourceItems] = {},
        },
        [24561] = { -- The Halls Of Reflection
            [questKeys.requiredSourceItems] = {},
        },
        [24563] = { -- Thalorien Dawnseeker
            [questKeys.objectives] = {{{37205,nil,Questie.ICON_TYPE_TALK}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Examine the remains"), 0, {{"monster", 37552}}}},
        },
        [24564] = { -- The Purification of Quel'Delar
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE - raceIDs.BLOOD_ELF,
            [questKeys.requiredClasses] = classIDs.WARRIOR + classIDs.PALADIN + classIDs.ROGUE + classIDs.HUNTER + classIDs.DEATH_KNIGHT + classIDs.MAGE + classIDs.WARLOCK,
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_TALK, l10n("Ask the warden to take you to the Sunwell"), 0, {{"monster", 37523}}},
                {nil, Questie.ICON_TYPE_EVENT, l10n("After restoring Quel'Delar, go back to Dalaran"), 0, {{"object", 194481}}},
            },
            [questKeys.requiredSourceItems] = {},
        },
        [24579] = { -- Sartharion Must Die!
            [questKeys.exclusiveTo] = {24580,24581,24582,24583,24584,24585,24586,24587,24588,24589,24590},
        },
        [24580] = { -- Anub'Rekhan Must Die!
            [questKeys.exclusiveTo] = {24579,24581,24582,24583,24584,24585,24586,24587,24588,24589,24590},
        },
        [24581] = { -- Noth the Plaguebringer Must Die!
            [questKeys.exclusiveTo] = {24579,24580,24582,24583,24584,24585,24586,24587,24588,24589,24590},
        },
        [24582] = { -- Instructor Razuvious Must Die!
            [questKeys.exclusiveTo] = {24579,24580,24581,24583,24584,24585,24586,24587,24588,24589,24590},
        },
        [24583] = { -- Patchwerk Must Die!
            [questKeys.exclusiveTo] = {24579,24580,24581,24582,24584,24585,24586,24587,24588,24589,24590},
        },
        [24584] = { -- Malygos Must Die!
            [questKeys.exclusiveTo] = {24579,24580,24581,24582,24583,24585,24586,24587,24588,24589,24590},
        },
        [24585] = { -- Flame Leviathan Must Die!
            [questKeys.exclusiveTo] = {24579,24580,24581,24582,24583,24584,24586,24587,24588,24589,24590},
        },
        [24586] = { -- Razorscale Must Die!
            [questKeys.exclusiveTo] = {24579,24580,24581,24582,24583,24584,24585,24587,24588,24589,24590},
        },
        [24587] = { -- Ignis the Furnace Master Must Die!
            [questKeys.exclusiveTo] = {24579,24580,24581,24582,24583,24584,24585,24586,24588,24589,24590},
        },
        [24588] = { -- XT-002 Deconstructor Must Die!
            [questKeys.exclusiveTo] = {24579,24580,24581,24582,24583,24584,24585,24586,24587,24589,24590},
        },
        [24589] = { -- Lord Jaraxxus Must Die!
            [questKeys.exclusiveTo] = {24579,24580,24581,24582,24583,24584,24585,24586,24587,24588,24590},
        },
        [24590] = { -- Lord Marrowgar Must Die!
            [questKeys.exclusiveTo] = {24579,24580,24581,24582,24583,24584,24585,24586,24587,24588,24589},
        },
        [24594] = { -- The Purification of Quel'Delar
            [questKeys.requiredRaces] = raceIDs.BLOOD_ELF,
            [questKeys.requiredClasses] = classIDs.WARRIOR + classIDs.PALADIN + classIDs.ROGUE + classIDs.HUNTER + classIDs.DEATH_KNIGHT + classIDs.MAGE + classIDs.WARLOCK,
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_TALK, l10n("Ask the warden to take you to the Sunwell"), 0, {{"monster", 37523}}},
                {nil, Questie.ICON_TYPE_EVENT, l10n("After restoring Quel'Delar, go back to Dalaran"), 0, {{"object", 194481}}},
            },
            [questKeys.requiredSourceItems] = {},
        },
        [24595] = { -- The Purification of Quel'Delar
            [questKeys.requiredClasses] = classIDs.DRUID + classIDs.PRIEST + classIDs.SHAMAN,
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_TALK, l10n("Ask the warden to take you to the Sunwell"), 0, {{"monster", 37523}}},
                {nil, Questie.ICON_TYPE_EVENT, l10n("After restoring Quel'Delar, go back to Dalaran"), 0, {{"object", 194481}}},
            },
        },
        [24596] = { -- The Purification of Quel'Delar
            [questKeys.requiredRaces] = raceIDs.BLOOD_ELF,
            [questKeys.requiredClasses] = classIDs.DRUID + classIDs.PRIEST + classIDs.SHAMAN,
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_TALK, l10n("Ask the warden to take you to the Sunwell"), 0, {{"monster", 37523}}},
                {nil, Questie.ICON_TYPE_EVENT, l10n("After restoring Quel'Delar, go back to Dalaran"), 0, {{"object", 194481}}},
            },
            [questKeys.requiredSourceItems] = {},
        },
        [24597] = { -- A Gift for the King of Stormwind
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [24598] = { -- The Purification of Quel'Delar
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE - raceIDs.BLOOD_ELF,
            [questKeys.requiredClasses] = classIDs.DRUID + classIDs.PRIEST + classIDs.SHAMAN,
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_TALK, l10n("Ask the warden to take you to the Sunwell"), 0, {{"monster", 37523}}},
                {nil, Questie.ICON_TYPE_EVENT, l10n("After restoring Quel'Delar, go back to Dalaran"), 0, {{"object", 194481}}},
            },
            [questKeys.requiredSourceItems] = {},
        },
        [24609] = { -- A Gift for the Lord of Ironforge
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [24610] = { -- A Gift for the High Priestess of Elune
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [24611] = { -- A Gift for the Prophet
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [24612] = { -- A Gift for the Warchief
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [24613] = { -- A Gift for the Banshee Queen
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [24614] = { -- A Gift for the High Chieftain
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [24615] = { -- A Gift for the Regent Lord of Quel'Thalas
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [24629] = { -- A Perfect Puff of Perfume
            [questKeys.exclusiveTo] = {24635, 24636},
            [questKeys.requiredSourceItems] = {},
        },
        [24635] = { -- A Cloudlet of Classy Cologne
            [questKeys.exclusiveTo] = {24629, 24636},
            [questKeys.requiredSourceItems] = {},
        },
        [24636] = { -- Bonbon Blitz
            [questKeys.exclusiveTo] = {24629, 24635},
            [questKeys.requiredSourceItems] = {},
        },
        [24638] = { -- Crushing the Crown
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.preQuestSingle] = {24576},
            [questKeys.startedBy] = {{37172}},
            [questKeys.finishedBy] = {{37172}},
            [questKeys.exclusiveTo] = {24645, 24647, 24648, 24649, 24650, 24651, 24652},
            [questKeys.objectives] = {nil,{{420034}},nil,nil,{{{37214},37214}}},
            [questKeys.requiredMaxLevel] = 13,
            [questKeys.requiredSourceItems] = {},
        },
        [24645] = { -- Crushing the Crown
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.preQuestSingle] = {24576},
            [questKeys.startedBy] = {{37172}},
            [questKeys.finishedBy] = {{37172}},
            [questKeys.exclusiveTo] = {24638, 24647, 24648, 24649, 24650, 24651, 24652},
            [questKeys.objectives] = {nil,{{420035}},nil,nil,{{{37917},37917}}},
            [questKeys.requiredMaxLevel] = 22,
            [questKeys.requiredSourceItems] = {},
        },
        [24647] = { -- Crushing the Crown
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.preQuestSingle] = {24576},
            [questKeys.startedBy] = {{37172}},
            [questKeys.finishedBy] = {{37172}},
            [questKeys.exclusiveTo] = {24638, 24645, 24648, 24649, 24650, 24651, 24652},
            [questKeys.objectives] = {nil,{{420038}},nil,nil,{{{37984},37984}}},
            [questKeys.requiredMaxLevel] = 31,
            [questKeys.requiredSourceItems] = {},
        },
        [24648] = { -- Crushing the Crown
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.preQuestSingle] = {24576},
            [questKeys.startedBy] = {{37172}},
            [questKeys.finishedBy] = {{37172}},
            [questKeys.exclusiveTo] = {24638, 24645, 24647, 24649, 24650, 24651, 24652},
            [questKeys.objectives] = {nil,{{420039}},nil,nil,{{{38006},38006}}},
            [questKeys.requiredMaxLevel] = 40,
            [questKeys.requiredSourceItems] = {},
        },
        [24649] = { -- Crushing the Crown
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.preQuestSingle] = {24576},
            [questKeys.startedBy] = {{37172}},
            [questKeys.finishedBy] = {{37172}},
            [questKeys.exclusiveTo] = {24638, 24645, 24647, 24648, 24650, 24651, 24652},
            [questKeys.objectives] = {nil,{{420040}},nil,nil,{{{38016},38016}}},
            [questKeys.requiredMaxLevel] = 50,
            [questKeys.requiredSourceItems] = {},
        },
        [24650] = { -- Crushing the Crown
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.preQuestSingle] = {24576},
            [questKeys.startedBy] = {{37172}},
            [questKeys.finishedBy] = {{37172}},
            [questKeys.exclusiveTo] = {24638, 24645, 24647, 24648, 24649, 24651, 24652},
            [questKeys.objectives] = {nil,{{420041}},nil,nil,{{{38023},38023}}},
            [questKeys.requiredMaxLevel] = 60,
            [questKeys.requiredSourceItems] = {},
        },
        [24651] = { -- Crushing the Crown
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.preQuestSingle] = {24576},
            [questKeys.startedBy] = {{37172}},
            [questKeys.finishedBy] = {{37172}},
            [questKeys.exclusiveTo] = {24638, 24645, 24647, 24648, 24649, 24650, 24652},
            [questKeys.objectives] = {nil,{{420042}},nil,nil,{{{38030},38030}}},
            [questKeys.requiredMaxLevel] = 70,
            [questKeys.requiredSourceItems] = {},
        },
        [24652] = { -- Crushing the Crown
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.preQuestSingle] = {24576},
            [questKeys.startedBy] = {{37172}},
            [questKeys.finishedBy] = {{37172}},
            [questKeys.exclusiveTo] = {24638, 24645, 24647, 24648, 24649, 24650, 24651},
            [questKeys.objectives] = {nil,{{420043}},nil,nil,{{{38032},38032}}},
            [questKeys.requiredMaxLevel] = 80,
            [questKeys.requiredSourceItems] = {},
        },
        [24655] = { -- Something Stinks
            [questKeys.objectives] = {nil,nil,nil,nil,{{{68,1976},1976,nil,Questie.ICON_TYPE_INTERACT}}},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Use Snagglebolt's Air Analyzer on perfumed guards"), 0, {{"monster", 68},{"monster", 1976}}}},
            [questKeys.requiredSourceItems] = {},
        },
        [24656] = { -- Pilfering Perfume
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_OBJECT, l10n("Grab the package"), 0, {{"monster", 38065}}}},
            [questKeys.sourceItemId] = 49867,
        },
        [24658] = { -- Crushing the Crown
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.preQuestSingle] = {24657},
            [questKeys.startedBy] = {{38066}},
            [questKeys.finishedBy] = {{38066}},
            [questKeys.exclusiveTo] = {24659, 24660, 24662, 24663, 24664, 24665, 24666},
            [questKeys.objectives] = {nil,{{420036}},nil,nil,{{{37214},37214}}},
            [questKeys.requiredMaxLevel] = 13,
            [questKeys.requiredSourceItems] = {},
        },
        [24659] = { -- Crushing the Crown
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.preQuestSingle] = {24657},
            [questKeys.startedBy] = {{38066}},
            [questKeys.finishedBy] = {{38066}},
            [questKeys.exclusiveTo] = {24658, 24660, 24662, 24663, 24664, 24665, 24666},
            [questKeys.objectives] = {nil,{{420037}},nil,nil,{{{37917},37917}}},
            [questKeys.requiredMaxLevel] = 22,
            [questKeys.requiredSourceItems] = {},
        },
        [24660] = { -- Crushing the Crown
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.preQuestSingle] = {24657},
            [questKeys.startedBy] = {{38066}},
            [questKeys.finishedBy] = {{38066}},
            [questKeys.exclusiveTo] = {24658, 24659, 24662, 24663, 24664, 24665, 24666},
            [questKeys.objectives] = {nil,{{420038}},nil,nil,{{{37984},37984}}},
            [questKeys.requiredMaxLevel] = 31,
            [questKeys.requiredSourceItems] = {},
        },
        [24662] = { -- Crushing the Crown
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.preQuestSingle] = {24657},
            [questKeys.startedBy] = {{38066}},
            [questKeys.finishedBy] = {{38066}},
            [questKeys.exclusiveTo] = {24658, 24659, 24660, 24663, 24664, 24665, 24666},
            [questKeys.objectives] = {nil,{{420039}},nil,nil,{{{38006},38006}}},
            [questKeys.requiredMaxLevel] = 40,
            [questKeys.requiredSourceItems] = {},
        },
        [24663] = { -- Crushing the Crown
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.preQuestSingle] = {24657},
            [questKeys.startedBy] = {{38066}},
            [questKeys.finishedBy] = {{38066}},
            [questKeys.exclusiveTo] = {24658, 24659, 24660, 24662, 24664, 24665, 24666},
            [questKeys.objectives] = {nil,{{420040}},nil,nil,{{{38016},38016}}},
            [questKeys.requiredMaxLevel] = 50,
            [questKeys.requiredSourceItems] = {},
        },
        [24664] = { -- Crushing the Crown
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.preQuestSingle] = {24657},
            [questKeys.startedBy] = {{38066}},
            [questKeys.finishedBy] = {{38066}},
            [questKeys.exclusiveTo] = {24658, 24659, 24660, 24662, 24663, 24665, 24666},
            [questKeys.objectives] = {nil,{{420041}},nil,nil,{{{38023},38023}}},
            [questKeys.requiredMaxLevel] = 60,
            [questKeys.requiredSourceItems] = {},
        },
        [24665] = { -- Crushing the Crown
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.preQuestSingle] = {24657},
            [questKeys.startedBy] = {{38066}},
            [questKeys.finishedBy] = {{38066}},
            [questKeys.exclusiveTo] = {24658, 24659, 24660, 24662, 24663, 24664, 24666},
            [questKeys.objectives] = {nil,{{420042}},nil,nil,{{{38030},38030}}},
            [questKeys.requiredMaxLevel] = 70,
            [questKeys.requiredSourceItems] = {},
        },
        [24666] = { -- Crushing the Crown
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.preQuestSingle] = {24657},
            [questKeys.startedBy] = {{38066}},
            [questKeys.finishedBy] = {{38066}},
            [questKeys.exclusiveTo] = {24658, 24659, 24660, 24662, 24663, 24664, 24665},
            [questKeys.objectives] = {nil,{{420043}},nil,nil,{{{38032},38032}}},
            [questKeys.requiredMaxLevel] = 80,
            [questKeys.requiredSourceItems] = {},
        },
        [24683] = { -- The Pit of Saron
            [questKeys.preQuestSingle] = {24499},
        },
        [24710] = { -- Deliverance from the Pit
            [questKeys.preQuestSingle] = {24498},
        },
        [24711] = { -- Frostmourne
            [questKeys.preQuestSingle] = {24710},
        },
        [24743] = { -- Shadow's Edge
            [questKeys.startedBy] = {{37120}},
            [questKeys.finishedBy] = {{37120}},
            [questKeys.preQuestSingle] = {24545},
            [questKeys.nextQuestInChain] = 24547,
        },
        [24745] = { -- Something is in the Air (and it Ain't Love)
            [questKeys.startedBy] = {nil,nil,{50320}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
        },
        [24748] = { -- The Lich King's Last Stand
            [questKeys.startedBy] = {{37120}},
            [questKeys.finishedBy] = {{37120}},
            [questKeys.preQuestSingle] = {24549},
            [questKeys.objectives] = {{{36597}}},
        },
        [24749] = { -- Unholy Infusion
            [questKeys.preQuestSingle] = {24547},
            [questKeys.startedBy] = {{37120}},
            [questKeys.finishedBy] = {{37120}},
            [questKeys.objectives] = {{{36678}}},
        },
        [24756] = { -- Blood Infusion
            [questKeys.preQuestSingle] = {24749},
            [questKeys.startedBy] = {{37120}},
            [questKeys.finishedBy] = {{37120}},
            [questKeys.objectives] = {{{37955}}},
        },
        [24757] = { -- Frost Infusion
            [questKeys.preQuestSingle] = {24756},
            [questKeys.nextQuestInChain] = 24548,
            [questKeys.startedBy] = {{37120}},
            [questKeys.finishedBy] = {{37120}},
            [questKeys.objectives] = {{{36853}}},
        },
        [24792] = { -- Man on the Inside
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.preQuestSingle] = {24657},
        },
        [24793] = { -- Man on the Inside
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.preQuestSingle] = {24576},
        },
        [24795] = { -- A Victory For The Silver Covenant
            [questKeys.requiredClasses] = classIDs.DRUID + classIDs.PRIEST + classIDs.SHAMAN,
        },
        [24796] = { -- A Victory For The Silver Covenant
            [questKeys.requiredClasses] = classIDs.WARRIOR + classIDs.PALADIN + classIDs.ROGUE + classIDs.HUNTER + classIDs.DEATH_KNIGHT + classIDs.MAGE + classIDs.WARLOCK,
        },
        [24798] = { -- A Victory For The Sunreavers
            [questKeys.requiredRaces] = raceIDs.BLOOD_ELF,
            [questKeys.requiredClasses] = classIDs.DRUID + classIDs.PRIEST + classIDs.SHAMAN,
        },
        [24799] = { -- A Victory For The Sunreavers
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE - raceIDs.BLOOD_ELF,
            [questKeys.requiredClasses] = classIDs.DRUID + classIDs.PRIEST + classIDs.SHAMAN,
        },
        [24800] = { -- A Victory For The Sunreavers
            [questKeys.requiredRaces] = raceIDs.BLOOD_ELF,
            [questKeys.requiredClasses] = classIDs.WARRIOR + classIDs.PALADIN + classIDs.ROGUE + classIDs.HUNTER + classIDs.DEATH_KNIGHT + classIDs.MAGE + classIDs.WARLOCK,
        },
        [24801] = { -- A Victory For The Sunreavers
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE - raceIDs.BLOOD_ELF,
            [questKeys.requiredClasses] = classIDs.WARRIOR + classIDs.PALADIN + classIDs.ROGUE + classIDs.HUNTER + classIDs.DEATH_KNIGHT + classIDs.MAGE + classIDs.WARLOCK,
        },
        [24802] = { -- Wrath of the Lich King
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.finishedBy] = {{37554}},
            [questKeys.objectives] = {{{37554,nil,Questie.ICON_TYPE_EVENT},{36954,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [24803] = { -- Kalu'ak Fishing Derby
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
        },
        [24815] = { -- Choose Your Path
            [questKeys.requiredMinRep] = {1156,3000},
        },
        [24819] = { -- A Change of Heart - Destruction friendly - ormus
            [questKeys.startedBy] = {{38316}},
            [questKeys.finishedBy] = {{38316}},
            [questKeys.requiredMinRep] = {1156,3000},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {24815,24811},
            [questKeys.exclusiveTo] = {24825,24826,24827,24828,25239},
        },
        [24820] = { -- A Change of Heart - Vengeance friendly - ormus
            [questKeys.startedBy] = {{38316}},
            [questKeys.finishedBy] = {{38316}},
            [questKeys.requiredMinRep] = {1156,3000},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {24815,24810},
            [questKeys.exclusiveTo] = {24825,24826,24827,24828,25239},
        },
        [24821] = { -- A Change of Heart - Courage friendly - ormus
            [questKeys.startedBy] = {{38316}},
            [questKeys.finishedBy] = {{38316}},
            [questKeys.requiredMinRep] = {1156,3000},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {24815,24808},
            [questKeys.exclusiveTo] = {24825,24826,24827,24828,25239},
        },
        [24822] = { -- A Change of Heart - Wisdom friendly - ormus
            [questKeys.startedBy] = {{38316}},
            [questKeys.finishedBy] = {{38316}},
            [questKeys.requiredMinRep] = {1156,3000},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {24815,24809},
            [questKeys.exclusiveTo] = {24825,24826,24827,24828,25239},
        },
        [24823] = { -- Path of Destruction - honored to revered
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {24828,24811},
        },
        [24825] = { -- Path of Wisdom - friendly to honored
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {24815,24809},
        },
        [24826] = { -- Path of Vengeance - friendly to honored
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {24815,24810},
        },
        [24827] = { -- Path of Courage - friendly to honored
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {24815,24808},
        },
        [24828] = { -- Path of Destruction - friendly to honored
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {24815,24811},
        },
        [24829] = { -- Path of Destruction - revered to exalted
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {24823,24811},
        },
        [24830] = { -- Path of Wisdom - honored to revered
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {24825,24809},
        },
        [24831] = { -- Path of Wisdom - revered to exalted
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {24830,24809},
        },
        [24832] = { -- Path of Vengeance - honored to revered
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {24826,24810},
        },
        [24833] = { -- Path of Vengeance - revered to exalted
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {24832,24810},
        },
        [24834] = { -- Path of Courage - honored to revered
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {24827,24808},
        },
        [24835] = { -- Path of Courage - revered to exalted
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {24834,24808},
        },
        [24836] = { -- A Change of Heart - Destruction honored - ormus
            [questKeys.startedBy] = {{38316}},
            [questKeys.finishedBy] = {{38316}},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {24828,24811},
            [questKeys.exclusiveTo] = {24823,24830,24832,24834,25240},
        },
        [24837] = { -- A Change of Heart - wisdom honored - ormus
            [questKeys.startedBy] = {{38316}},
            [questKeys.finishedBy] = {{38316}},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {24825,24809},
            [questKeys.exclusiveTo] = {24823,24830,24832,24834,25240},
        },
        [24838] = { -- A Change of Heart - vengeance honored - ormus
            [questKeys.startedBy] = {{38316}},
            [questKeys.finishedBy] = {{38316}},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {24826,24810},
            [questKeys.exclusiveTo] = {24823,24830,24832,24834,25240},
        },
        [24839] = { -- A Change of Heart - courage honored - ormus
            [questKeys.startedBy] = {{38316}},
            [questKeys.finishedBy] = {{38316}},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {24827,24808},
            [questKeys.exclusiveTo] = {24823,24830,24832,24834,25240},
        },
        [24840] = { -- A Change of Heart - Destruction revered - ormus
            [questKeys.startedBy] = {{38316}},
            [questKeys.finishedBy] = {{38316}},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {24823,24811},
            [questKeys.exclusiveTo] = {24829,24831,24833,24835,25242},
        },
        [24841] = { -- A Change of Heart - Wisdom revered - ormus
            [questKeys.startedBy] = {{38316}},
            [questKeys.finishedBy] = {{38316}},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {24830,24809},
            [questKeys.exclusiveTo] = {24829,24831,24833,24835,25242},
        },
        [24842] = { -- A Change of Heart - Vengeance revered - ormus
            [questKeys.startedBy] = {{38316}},
            [questKeys.finishedBy] = {{38316}},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {24832,24810},
            [questKeys.exclusiveTo] = {24829,24831,24833,24835,25242},
        },
        [24843] = { -- A Change of Heart - Courage revered - ormus
            [questKeys.startedBy] = {{38316}},
            [questKeys.finishedBy] = {{38316}},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {24834,24808},
            [questKeys.exclusiveTo] = {24829,24831,24833,24835,25242},
        },
        [24844] = { -- A Change of Heart - Destruction exalted - ormus
            [questKeys.startedBy] = {{38316}},
            [questKeys.finishedBy] = {{38316}},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {24829,24811},
        },
        [24845] = { -- A Change of Heart - Wisdom exalted - ormus
            [questKeys.startedBy] = {{38316}},
            [questKeys.finishedBy] = {{38316}},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {24831,24809},
        },
        [24846] = { -- A Change of Heart - Vengeance exalted - ormus
            [questKeys.startedBy] = {{38316}},
            [questKeys.finishedBy] = {{38316}},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {24833,24810},
        },
        [24847] = { -- A Change of Heart - Courage exalted - ormus
            [questKeys.startedBy] = {{38316}},
            [questKeys.finishedBy] = {{38316}},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {24835,24808},
        },
        [24849] = { -- Hot On The Trail
            [questKeys.objectives] = {{{38340,nil,Questie.ICON_TYPE_EVENT},{38341,nil,Questie.ICON_TYPE_EVENT},{38342,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [24851] = { -- Hot On The Trail
            [questKeys.objectives] = {{{38340,nil,Questie.ICON_TYPE_EVENT},{38341,nil,Questie.ICON_TYPE_EVENT},{38342,nil,Questie.ICON_TYPE_EVENT}}},
        },
        [24857] = { -- Attack on Camp Narache
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
        },
        [24869] = { -- 10man
            [questKeys.startedBy] = {{38471}},
            [questKeys.finishedBy] = {{38471}},
            [questKeys.exclusiveTo] = {24870,24871,24872,24873,24874},
        },
        [24870] = { -- 10man
            [questKeys.startedBy] = {{38491}},
            [questKeys.finishedBy] = {{38491}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.exclusiveTo] = {24869,24872,24873,24874},
        },
        [24871] = { -- 10man
            [questKeys.startedBy] = {{38492}},
            [questKeys.finishedBy] = {{38492}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.exclusiveTo] = {24869,24872,24873,24874},
        },
        [24872] = { -- 10man
            [questKeys.startedBy] = {{38589}},
            [questKeys.finishedBy] = {{38017}},
            [questKeys.exclusiveTo] = {24869,24870,24871,24873,24874},
            [questKeys.requiredSourceItems] = {},
        },
        [24873] = { -- 10man
            [questKeys.startedBy] = {{38501}},
            [questKeys.finishedBy] = {{38501}},
            [questKeys.objectives] = {{{38501,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_EVENT, l10n("Get hit by Slime Spray to get the Green Blight strain"), 0, {{"monster", 36627}}},
                {nil, Questie.ICON_TYPE_EVENT, l10n("Get hit by Gaseous Blight to get the Orange Blight strain"), 0, {{"monster", 36626}}},
            },
            [questKeys.exclusiveTo] = {24869,24870,24871,24872,24874},
        },
        [24874] = { -- 10man
            [questKeys.startedBy] = {{38551}},
            [questKeys.finishedBy] = {{38558}},
            [questKeys.exclusiveTo] = {24869,24870,24871,24872,24873},
        },
        [24875] = { -- 25man
            [questKeys.startedBy] = {{38471}},
            [questKeys.finishedBy] = {{38471}},
            [questKeys.exclusiveTo] = {24876,24877,24878,24879,24880},
        },
        [24876] = { -- 25man
            [questKeys.startedBy] = {{38492}},
            [questKeys.finishedBy] = {{38492}},
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.exclusiveTo] = {24875,24878,24879,24880},
        },
        [24877] = { -- 25man
            [questKeys.startedBy] = {{38491}},
            [questKeys.finishedBy] = {{38491}},
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.exclusiveTo] = {24875,24878,24879,24880},
        },
        [24878] = { -- 25man
            [questKeys.startedBy] = {{38501}},
            [questKeys.finishedBy] = {{38501}},
            [questKeys.objectives] = {{{38501,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.extraObjectives] = {
                {nil, Questie.ICON_TYPE_EVENT, l10n("Get hit by Slime Spray to get the Green Blight strain"), 0, {{"monster", 36627}}},
                {nil, Questie.ICON_TYPE_EVENT, l10n("Get hit by Gaseous Blight to get the Orange Blight strain"), 0, {{"monster", 36626}}},
            },
            [questKeys.exclusiveTo] = {24875,24876,24877,24879,24880},
        },
        [24879] = { -- 25man
            [questKeys.startedBy] = {{38551}},
            [questKeys.finishedBy] = {{38558}},
            [questKeys.exclusiveTo] = {24875,24876,24877,24878,24880},
        },
        [24880] = { -- 25man
            [questKeys.startedBy] = {{38589}},
            [questKeys.finishedBy] = {{38017}},
            [questKeys.exclusiveTo] = {24875,24876,24877,24878,24879},
            [questKeys.requiredSourceItems] = {},
        },
        [24912] = { -- Empowerment
            [questKeys.startedBy] = {{37120}},
            [questKeys.finishedBy] = {{37120}},
            [questKeys.preQuestSingle] = {24548},
            [questKeys.nextQuestInChain] = 24549,
        },
        [24914] = { -- Personal Property
            [questKeys.startedBy] = {nil,nil,{51315}},
            [questKeys.preQuestSingle] = {24549},
            [questKeys.requiredSourceItems] = {},
        },
        [24915] = { -- Mograine's Reunion
            [questKeys.startedBy] = {{37120}},
            [questKeys.finishedBy] = {{37120}},
            [questKeys.preQuestSingle] = {24914},
        },
        [24916] = { -- Jaina's Locket
            [questKeys.startedBy] = {{38606}},
            [questKeys.finishedBy] = {{38606}},
            [questKeys.preQuestSingle] = {24914},
        },
        [24917] = { -- Muradin's Lament
            [questKeys.startedBy] = {{38607}},
            [questKeys.finishedBy] = {{38607}},
            [questKeys.preQuestSingle] = {24914},
        },
        [24918] = { -- Sylvanas' Vengeance
            [questKeys.startedBy] = {{38609}},
            [questKeys.finishedBy] = {{38609}},
            [questKeys.preQuestSingle] = {24914},
        },
        [24919] = { -- The Lightbringer's Redemption
            [questKeys.startedBy] = {{38608}},
            [questKeys.finishedBy] = {{38608}},
            [questKeys.preQuestSingle] = {24914},
        },
        [25199] = { -- Basic Orders
            [questKeys.preQuestSingle] = {25229},
            [questKeys.startedBy] = {{39675}},
            [questKeys.finishedBy] = {{39675}},
            [questKeys.objectives] = {{{39368,nil,Questie.ICON_TYPE_INTERACT},{39368,nil,Questie.ICON_TYPE_INTERACT},{39368,nil,Questie.ICON_TYPE_INTERACT},{39368,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [25212] = { -- Vent Horizon
            [questKeys.startedBy] = {{39386}},
            [questKeys.finishedBy] = {{39386}},
            [questKeys.preQuestSingle] = {25199},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Board the Flying Machine"), 0, {{"monster", 39396}}}},
            [questKeys.requiredSourceItems] = {},
        },
        [25229] = { -- A Few Good Gnomes
            [questKeys.requiredLevel] = 1,
            [questKeys.objectives] = {nil,nil,nil,nil,{{{39253,39623},39623,nil,Questie.ICON_TYPE_INTERACT},{{39624,39466,39675},39466,nil,Questie.ICON_TYPE_EVENT}}},
            [questKeys.requiredSourceItems] = {},
        },
        [25239] = { -- Path of Might - friendly to honored
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {24815,25238},
        },
        [25240] = { -- Path of Might - honored to revered
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {25239,25238},
        },
        [25242] = { -- Path of Might - revered to exalted
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {25240,25238},
        },
        [25246] = { -- A Change of Heart - might exalted - aronen
            [questKeys.preQuestGroup] = {25242,25238},
        },
        [25247] = { -- A Change of Heart - might friendly - aronen
            [questKeys.preQuestGroup] = {24815,25238},
            [questKeys.requiredMinRep] = {1156,3000},
            [questKeys.exclusiveTo] = {24825,24826,24827,24828,25239},
        },
        [25248] = { -- A Change of Heart - might honored - aronen
            [questKeys.preQuestGroup] = {25238,25239},
            [questKeys.exclusiveTo] = {24823,24830,24832,24834,25240},
        },
        [25249] = { -- A Change of Heart - might revered - aronen
            [questKeys.preQuestGroup] = {25240,25238},
            [questKeys.exclusiveTo] = {24823,24830,24832,24834,25240},
        },
        [25283] = { -- Prepping the Speech
            [questKeys.startedBy] = {{39678}},
            [questKeys.finishedBy] = {{39678}},
            [questKeys.preQuestSingle] = {},
            [questKeys.preQuestGroup] = {25212,25295},
            [questKeys.nextQuestInChain] = 25500,
            [questKeys.requiredSourceItems] = {},
        },
        [25285] = { -- In and Out
            [questKeys.startedBy] = {{39675}},
            [questKeys.finishedBy] = {{39675}},
            [questKeys.preQuestSingle] = {25199},
            [questKeys.nextQuestInChain] = 25289,
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_MOUNT_UP, l10n("Get in"), 0, {{"monster", 39715}}}},
            [questKeys.objectives] = {nil,nil,nil,nil,{{{39682,39715},39715,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [25286] = { -- Words for Delivery
            [questKeys.preQuestSingle] = {25283},
            [questKeys.exclusiveTo] = {25500},
            [questKeys.questLevel] = -1,
        },
        [25287] = { -- Words for Delivery
            [questKeys.questLevel] = -1,
        },
        [25289] = { -- One Step Forward...
            [questKeys.startedBy] = {{39675}},
            [questKeys.finishedBy] = {{39675}},
            [questKeys.preQuestSingle] = {25285},
            [questKeys.nextQuestInChain] = 25295,
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_MOUNT_UP, l10n("Get in"), 0, {{"monster", 39716}}}},
            [questKeys.objectives] = {nil,nil,nil,nil,{{{39713,39716},39716,nil,Questie.ICON_TYPE_INTERACT},{{39713,39716},39716,nil,Questie.ICON_TYPE_INTERACT},{{39713,39716},39716,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [25295] = { -- Press Fire
            [questKeys.startedBy] = {{39675}},
            [questKeys.finishedBy] = {{39675}},
            [questKeys.preQuestSingle] = {25289},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_MOUNT_UP, l10n("Get in"), 0, {{"monster", 39717}}}},
            [questKeys.objectives] = {{{39711,nil,Questie.ICON_TYPE_INTERACT}}},
        },
        [25393] = { -- Operation: Gnomeregan
            [questKeys.requiredLevel] = 75,
            [questKeys.questLevel] = -1,
        },
        [25444] = { -- Da Perfect Spies
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_EVENT, l10n("Attune a Captured Frog"), 0, {{"monster", 40187}}}},
        },
        [25445] = { -- Zalazane's Fall
            [questKeys.objectives] = {{{40502}}},
            [questKeys.requiredLevel] = 75,
            [questKeys.questLevel] = -1,
        },
        [25446] = { -- Frogs Away!
            [questKeys.nextQuestInChain] = 25461,
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Talk to Handler Marnlek and deploy the frogs on the white smoke"), 0, {{"monster", 40204}}}},
            [questKeys.requiredSourceItems] = {},
        },
        [25461] = { -- Trollin' For Volunteers
            [questKeys.preQuestSingle] = {25446},
            [questKeys.nextQuestInChain] = 25470,
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Talk to Handler Marnlek for a ride"), 0, {{"monster", 40204}}}},
            [questKeys.requiredSourceItems] = {},
        },
        [25470] = { -- Lady Of Da Tigers
            [questKeys.preQuestSingle] = {25461},
        },
        [25480] = { -- Dance Of De Spirits
            [questKeys.nextQuestInChain] = 25495,
            [questKeys.objectives] = {{{40352,nil,Questie.ICON_TYPE_TALK}}},
        },
        [25495] = { -- Preparin' For Battle
            [questKeys.preQuestSingle] = {25480},
            [questKeys.extraObjectives] = {{nil, Questie.ICON_TYPE_TALK, l10n("Talk to Handler Marnlek for a ride"), 0, {{"monster", 40204}}}},
        },
        [25500] = { -- Words for Delivery
            [questKeys.preQuestSingle] = {25283},
            [questKeys.requiredMaxLevel] = 74,
            [questKeys.exclusiveTo] = {25286},
            [questKeys.nextQuestInChain] = 25287,
        },
        [26012] = { -- Trouble at Wyrmrest
            [questKeys.exclusiveTo] = {26013},
        },
        [26013] = { -- Assault on the Sanctum
            [questKeys.preQuestSingle] = {},
        },
        [26034] = { -- The Twilight Destroyer
            [questKeys.preQuestSingle] = {26013},
        },
        [64845] = { -- Alliance War Effort
            [questKeys.triggerEnd] = {"Victory in a battleground match", {
                [zoneIDs.ALTERAC_MOUNTAINS] = {{39.4,82.2}},
                [zoneIDs.ARATHI_HIGHLANDS] = {{45.6,45.8}},
                [zoneIDs.ASHENVALE] = {{61.8,83.8}},
                [zoneIDs.DALARAN]={{29.79,75.78}},
                [zoneIDs.DARNASSUS]={{58.02,34.52}},
                [zoneIDs.IRONFORGE]={{70.41,91.10}},
                [zoneIDs.SHATTRATH_CITY]={{67.41,33.86}},
                [zoneIDs.STORMWIND_CITY]={{83.47,33.66}},
                [zoneIDs.THE_EXODAR]={{26.6,50.06}},
                [zoneIDs.WINTERGRASP]={{50.02,15.16}},
            }},
        },

        ----- Boosted character quests -----
        [70395] = { -- A New Beginning
            [questKeys.name] = "A New Beginning",
            [questKeys.startedBy] = {}, -- This quest is auto accept
            [questKeys.finishedBy] = {{376,914,928,5495,5497,5505,5515,13283,20407}},
            [questKeys.requiredLevel] = 70,
            [questKeys.questLevel] = 70,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.objectivesText] = {"Meet with your class trainer in Stormwind."},
            [questKeys.zoneOrSort] = 1519,
        },
        [70396] = { -- A New Beginning
            [questKeys.name] = "A New Beginning",
            [questKeys.startedBy] = {}, -- This quest is auto accept
            [questKeys.finishedBy] = {{3324,3328,3344,3353,3406,5885,5994,23128}},
            [questKeys.requiredLevel] = 70,
            [questKeys.questLevel] = 70,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.objectivesText] = {"Meet with your class trainer in Orgrimmar."},
            [questKeys.zoneOrSort] = 1637,
        },
        [70397] = { -- Tools for Survival
            [questKeys.name] = "Tools for Survival",
            [questKeys.startedBy] = {{376,914,928,5495,5497,5505,5515,13283,20407}},
            [questKeys.finishedBy] = {{376,914,928,5495,5497,5505,5515,13283,20407}},
            [questKeys.requiredLevel] = 70,
            [questKeys.questLevel] = 70,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.objectivesText] = {"Open the survival kit and equip a weapon."},
            [questKeys.objectives] = {nil,{{410010}, {410011}}},
            [questKeys.zoneOrSort] = 1519,
        },
        [70398] = { -- Combat Training
            [questKeys.name] = "Combat Training",
            [questKeys.startedBy] = {{376,914,928,5495,5497,5505,5515,13283,20407}},
            [questKeys.finishedBy] = {{376,914,928,5495,5497,5505,5515,13283,20407}},
            [questKeys.requiredLevel] = 70,
            [questKeys.questLevel] = 70,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.objectivesText] = {"Train a spell by speaking to your class trainer."},
            [questKeys.objectives] = {nil,{{410012}}},
            [questKeys.zoneOrSort] = 1519,
        },
        [70401] = { -- Talented
            [questKeys.name] = "Talented",
            [questKeys.startedBy] = {{376,914,928,5495,5497,5505,5515,13283,20407}},
            [questKeys.finishedBy] = {{376,914,928,5495,5497,5505,5515,13283,20407}},
            [questKeys.requiredLevel] = 70,
            [questKeys.questLevel] = 70,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.objectivesText] = {"Activate the Talents interface and allocate 5 Talent Points."},
            [questKeys.objectives] = {nil,{{410013}}},
            [questKeys.zoneOrSort] = 1519,
        },
        [70411] = { -- To the Dockmaster
            [questKeys.name] = "To the Dockmaster",
            [questKeys.startedBy] = {{376,914,928,5495,5497,5505,5515,13283,20407}},
            [questKeys.finishedBy] = {{26546,26548}},
            [questKeys.requiredLevel] = 70,
            [questKeys.questLevel] = 70,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.objectivesText] = {"Use a scroll of teleportation from your inventory to reach the harbor and speak to the dock master."},
            [questKeys.requiredSourceItems] = {199335,199336},
            [questKeys.zoneOrSort] = 150,
        },
        [70734] = { -- Tools for Survival
            [questKeys.name] = "Tools for Survival",
            [questKeys.startedBy] = {{3324,3328,3344,3353,3406,5885,5994,23128}},
            [questKeys.finishedBy] = {{3324,3328,3344,3353,3406,5885,5994,23128}},
            [questKeys.requiredLevel] = 70,
            [questKeys.questLevel] = 70,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.objectivesText] = {"Open the survival kit and equip a weapon."},
            [questKeys.objectives] = {nil,{{410002}, {410003}}},
            [questKeys.zoneOrSort] = 1637,
        },
        [70735] = { -- Combat Training
            [questKeys.name] = "Combat Training",
            [questKeys.startedBy] = {{3324,3328,3344,3353,3406,5885,5994,23128}},
            [questKeys.finishedBy] = {{3324,3328,3344,3353,3406,5885,5994,23128}},
            [questKeys.requiredLevel] = 70,
            [questKeys.questLevel] = 70,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.objectivesText] = {"Train a spell by speaking to your class trainer."},
            [questKeys.objectives] = {nil,{{410006}}},
            [questKeys.zoneOrSort] = 1637,
        },
        [70736] = { -- Talented
            [questKeys.name] = "Talented",
            [questKeys.startedBy] = {{3324,3328,3344,3353,3406,5885,5994,23128}},
            [questKeys.finishedBy] = {{3324,3328,3344,3353,3406,5885,5994,23128}},
            [questKeys.requiredLevel] = 70,
            [questKeys.questLevel] = 70,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.objectivesText] = {"Activate the Talents interface and allocate 5 Talent Points."},
            [questKeys.objectives] = {nil,{{410008}}},
            [questKeys.zoneOrSort] = 1637,
        },
        [70737] = { -- To the Zeppelin Master
            [questKeys.name] = "To the Zeppelin Master",
            [questKeys.startedBy] = {{3324,3328,3344,3353,3406,5885,5994,23128}},
            [questKeys.finishedBy] = {{26537,26539}},
            [questKeys.requiredLevel] = 70,
            [questKeys.questLevel] = 70,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.objectivesText] = {"Use a scroll of teleportation from your inventory to reach the zeppelin tower and speak to the zeppelin master."},
            [questKeys.requiredSourceItems] = {199777,199778},
            [questKeys.zoneOrSort] = 1637,
        },
        [70761] = { -- Tools for Survival
            [questKeys.name] = "Tools for Survival",
            [questKeys.startedBy] = {{3036}},
            [questKeys.finishedBy] = {{3036}},
            [questKeys.requiredLevel] = 70,
            [questKeys.questLevel] = 70,
            [questKeys.requiredRaces] = raceIDs.TAUREN,
            [questKeys.requiredClasses] = classIDs.DRUID,
            [questKeys.objectivesText] = {"Open the survival kit and equip a weapon."},
            [questKeys.objectives] = {nil,{{410004}, {410005}}},
            [questKeys.zoneOrSort] = 1638,
        },
        [70762] = { -- A New Beginning
            [questKeys.name] = "A New Beginning",
            [questKeys.startedBy] = {}, -- This quest is auto accept
            [questKeys.finishedBy] = {{3036}},
            [questKeys.requiredLevel] = 70,
            [questKeys.questLevel] = 70,
            [questKeys.requiredRaces] = raceIDs.TAUREN,
            [questKeys.requiredClasses] = classIDs.DRUID,
            [questKeys.objectivesText] = {"Meet with your Druid trainer in Thunder Bluff."},
            [questKeys.zoneOrSort] = 1638,
        },
        [70764] = { -- Combat Training
            [questKeys.name] = "Combat Training",
            [questKeys.startedBy] = {{3036}},
            [questKeys.finishedBy] = {{3036}},
            [questKeys.requiredLevel] = 70,
            [questKeys.questLevel] = 70,
            [questKeys.requiredRaces] = raceIDs.TAUREN,
            [questKeys.requiredClasses] = classIDs.DRUID,
            [questKeys.objectivesText] = {"Train a spell by speaking to your class trainer."},
            [questKeys.objectives] = {nil,{{410007}}},
            [questKeys.zoneOrSort] = 1638,
        },
        [70765] = { -- Talented
            [questKeys.name] = "Talented",
            [questKeys.startedBy] = {{3036}},
            [questKeys.finishedBy] = {{3036}},
            [questKeys.requiredLevel] = 70,
            [questKeys.questLevel] = 70,
            [questKeys.requiredRaces] = raceIDs.TAUREN,
            [questKeys.requiredClasses] = classIDs.DRUID,
            [questKeys.objectivesText] = {"Activate the Talents interface and allocate 5 Talent Points."},
            [questKeys.objectives] = {nil,{{410009}}},
            [questKeys.zoneOrSort] = 1638,
        },
        [70865] = { -- To Shattrath City
            [questKeys.name] = "To Shattrath City",
            [questKeys.startedBy] = {{376,914,928,3036,3324,3328,3344,3406,5495,5497,5505,5515,5885,5994,13283,20407,23128}},
            [questKeys.finishedBy] = {{19684}},
            [questKeys.requiredLevel] = 70,
            [questKeys.questLevel] = 70,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.objectivesText] = {"Use the scroll of teleportation from your inventory to reach Shattrath City and speak to the mysterious Haggard War Veteran."},
            [questKeys.requiredSourceItems] = {200068},
            [questKeys.zoneOrSort] = 3897,
        },
        [70869] = { -- Talented
            [questKeys.name] = "Talented",
            [questKeys.startedBy] = {{3324,3328,3344,3353,3406,5885,5994,23128}},
            [questKeys.finishedBy] = {{3324,3328,3344,3353,3406,5885,5994,23128}},
            [questKeys.requiredLevel] = 70,
            [questKeys.questLevel] = 70,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.objectivesText] = {"Activate the Talents interface and allocate 5 Talent Points."},
            [questKeys.objectives] = {nil,{{410008}}},
            [questKeys.zoneOrSort] = 1637,
        },
        [70870] = { -- Talented
            [questKeys.name] = "Talented",
            [questKeys.startedBy] = {{376,914,928,5495,5497,5505,5515,13283,20407}},
            [questKeys.finishedBy] = {{376,914,928,5495,5497,5505,5515,13283,20407}},
            [questKeys.requiredLevel] = 70,
            [questKeys.questLevel] = 70,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.objectivesText] = {"Activate the Talents interface and allocate 5 Talent Points."},
            [questKeys.objectives] = {nil,{{410013}}},
            [questKeys.zoneOrSort] = 1519,
        },
        [78136] = { -- A New Beginning
            [questKeys.name] = "A New Beginning",
            [questKeys.startedBy] = {}, -- This quest is auto accept
            [questKeys.finishedBy] = {{376,914,928,5495,5497,5505,5515,13283,20407}},
            [questKeys.requiredLevel] = 80,
            [questKeys.questLevel] = 80,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.objectivesText] = {"Meet with your class trainer in Stormwind."},
            [questKeys.zoneOrSort] = 1519,
        },
        [78137] = { -- A New Beginning
            [questKeys.name] = "A New Beginning",
            [questKeys.startedBy] = {}, -- This quest is auto accept
            [questKeys.finishedBy] = {{3324,3328,3344,3353,3406,5885,5994,23128}},
            [questKeys.requiredLevel] = 80,
            [questKeys.questLevel] = 80,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.objectivesText] = {"Meet with your class trainer in Orgrimmar."},
            [questKeys.zoneOrSort] = 1637,
        },
        [78138] = { -- A New Beginning
            [questKeys.name] = "A New Beginning",
            [questKeys.startedBy] = {}, -- This quest is auto accept
            [questKeys.finishedBy] = {{3036}},
            [questKeys.requiredLevel] = 80,
            [questKeys.questLevel] = 80,
            [questKeys.requiredRaces] = raceIDs.TAUREN,
            [questKeys.requiredClasses] = classIDs.DRUID,
            [questKeys.objectivesText] = {"Meet with your Druid trainer in Thunder Bluff."},
            [questKeys.zoneOrSort] = 1638,
        },
        [78140] = { -- Tools for Survival
            [questKeys.name] = "Tools for Survival",
            [questKeys.startedBy] = {{376,914,928,5495,5497,5505,5515,13283,20407}},
            [questKeys.finishedBy] = {{376,914,928,5495,5497,5505,5515,13283,20407}},
            [questKeys.requiredLevel] = 80,
            [questKeys.questLevel] = 80,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.objectivesText] = {"Open the survival kit and equip a weapon."},
            [questKeys.objectives] = {nil,{{410010}, {410011}}},
            [questKeys.zoneOrSort] = 1519,
        },
        [78151] = { -- Tools for Survival
            [questKeys.name] = "Tools for Survival",
            [questKeys.startedBy] = {{3036}},
            [questKeys.finishedBy] = {{3036}},
            [questKeys.requiredLevel] = 80,
            [questKeys.questLevel] = 80,
            [questKeys.requiredRaces] = raceIDs.TAUREN,
            [questKeys.objectivesText] = {"Open the survival kit and equip a weapon."},
            [questKeys.objectives] = {nil,{{410004}, {410005}}},
            [questKeys.zoneOrSort] = 1637,
        },
        [78157] = { -- Combat Training
            [questKeys.name] = "Combat Training",
            [questKeys.startedBy] = {{376,914,928,5495,5497,5505,5515,13283,20407}},
            [questKeys.finishedBy] = {{376,914,928,5495,5497,5505,5515,13283,20407}},
            [questKeys.requiredLevel] = 80,
            [questKeys.questLevel] = 80,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.objectivesText] = {"Train a spell by speaking to your class trainer."},
            [questKeys.objectives] = {nil,{{410012}}},
            [questKeys.zoneOrSort] = 1519,
        },
        [78158] = { -- Combat Training
            [questKeys.name] = "Combat Training",
            [questKeys.startedBy] = {{3036}},
            [questKeys.finishedBy] = {{3036}},
            [questKeys.requiredLevel] = 80,
            [questKeys.questLevel] = 80,
            [questKeys.requiredRaces] = raceIDs.TAUREN,
            [questKeys.requiredClasses] = classIDs.DRUID,
            [questKeys.objectivesText] = {"Train a spell by speaking to your class trainer."},
            [questKeys.objectives] = {nil,{{410007}}},
            [questKeys.zoneOrSort] = 1638,
        },
        [78164] = { -- Talented
            [questKeys.name] = "Talented",
            [questKeys.startedBy] = {{376,914,928,5495,5497,5505,5515,13283,20407}},
            [questKeys.finishedBy] = {{376,914,928,5495,5497,5505,5515,13283,20407}},
            [questKeys.requiredLevel] = 80,
            [questKeys.questLevel] = 80,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.objectivesText] = {"Activate the Talents interface and allocate 5 Talent Points."},
            [questKeys.objectives] = {nil,{{410013}}},
            [questKeys.zoneOrSort] = 1519,
        },
        [78166] = { -- To Northrend
            [questKeys.name] = "To Northrend",
            [questKeys.startedBy] = {{376,914,928,5495,5497,5505,5515,13283,20407}},
            [questKeys.finishedBy] = {{26673}},
            [questKeys.requiredLevel] = 80,
            [questKeys.questLevel] = 80,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.objectivesText] = {"Use the scroll of teleportation from your inventory to reach Northrend and speak to the Image of Archmage Modera."},
            [questKeys.requiredSourceItems] = {210046,210047},
            [questKeys.zoneOrSort] = 65,
        },
        [78167] = { -- Talented
            [questKeys.name] = "Talented",
            [questKeys.startedBy] = {{3036,3324,3328,3344,3353,3406,5885,5994,23128}},
            [questKeys.finishedBy] = {{3036,3324,3328,3344,3353,3406,5885,5994,23128}},
            [questKeys.requiredLevel] = 80,
            [questKeys.questLevel] = 80,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.objectivesText] = {"Activate the Talents interface and allocate 5 Talent Points."},
            [questKeys.objectives] = {nil,{{410008}}},
            [questKeys.zoneOrSort] = 1637,
        },
        [78168] = { -- To Northrend
            [questKeys.name] = "To Northrend",
            [questKeys.startedBy] = {{3036,3324,3328,3344,3353,3406,5885,5994,23128}},
            [questKeys.finishedBy] = {{26471}},
            [questKeys.requiredLevel] = 80,
            [questKeys.questLevel] = 80,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.objectivesText] = {"Use the scroll of teleportation from your inventory to reach Northrend and speak to the Image of Archmage Aethas Sunreaver."},
            [questKeys.requiredSourceItems] = {210046,210047},
            [questKeys.zoneOrSort] = 65,
        },
        [78219] = { -- A New Beginning
            [questKeys.name] = "A New Beginning",
            [questKeys.startedBy] = {}, -- This quest is auto accept
            [questKeys.finishedBy] = {{28471,28472,28474}},
            [questKeys.requiredLevel] = 80,
            [questKeys.questLevel] = 80,
            [questKeys.requiredClasses] = classIDs.DEATH_KNIGHT,
            [questKeys.objectivesText] = {"Meet with your Death Knight trainer in Acherus: The Ebon Hold."},
            [questKeys.zoneOrSort] = 4281,
        },
        [78220] = { -- Tools for Survival
            [questKeys.name] = "Tools for Survival",
            [questKeys.startedBy] = {{28471,28472,28474}},
            [questKeys.finishedBy] = {{28471,28472,28474}},
            [questKeys.requiredLevel] = 80,
            [questKeys.questLevel] = 80,
            [questKeys.requiredClasses] = classIDs.DEATH_KNIGHT,
            [questKeys.objectivesText] = {"Open the survival kit and equip a weapon."},
            [questKeys.objectives] = {nil,{{420045}, {420046}}},
            [questKeys.zoneOrSort] = 4281,
        },
        [78221] = { -- Combat Training
            [questKeys.name] = "Combat Training",
            [questKeys.startedBy] = {{28471,28472,28474}},
            [questKeys.finishedBy] = {{28471,28472,28474}},
            [questKeys.requiredLevel] = 80,
            [questKeys.questLevel] = 80,
            [questKeys.requiredClasses] = classIDs.DEATH_KNIGHT,
            [questKeys.objectivesText] = {"Train a spell by speaking to your class trainer."},
            [questKeys.objectives] = {nil,{{420047}}},
            [questKeys.zoneOrSort] = 4281,
        },
        [78222] = { -- Talented
            [questKeys.name] = "Talented",
            [questKeys.startedBy] = {{28471,28472,28474}},
            [questKeys.finishedBy] = {{28471,28472,28474}},
            [questKeys.requiredLevel] = 80,
            [questKeys.questLevel] = 80,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.requiredClasses] = classIDs.DEATH_KNIGHT,
            [questKeys.objectivesText] = {"Activate the Talents interface and allocate 5 Talent Points."},
            [questKeys.objectives] = {nil,{{420044}}},
            [questKeys.zoneOrSort] = 4281,
        },
        [78223] = { -- To Northrend
            [questKeys.name] = "To Northrend",
            [questKeys.startedBy] = {{28471,28472,28474}},
            [questKeys.finishedBy] = {{26673}},
            [questKeys.requiredLevel] = 80,
            [questKeys.questLevel] = 80,
            [questKeys.requiredRaces] = raceIDs.ALL_ALLIANCE,
            [questKeys.requiredClasses] = classIDs.DEATH_KNIGHT,
            [questKeys.objectivesText] = {"Use the scroll of teleportation from your inventory to reach Northrend and speak to the Image of Archmage Modera."},
            [questKeys.requiredSourceItems] = {210046,210047},
            [questKeys.zoneOrSort] = 65,
        },
        [78224] = { -- Talented
            [questKeys.name] = "Talented",
            [questKeys.startedBy] = {{28471,28472,28474}},
            [questKeys.finishedBy] = {{28471,28472,28474}},
            [questKeys.requiredLevel] = 80,
            [questKeys.questLevel] = 80,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.requiredClasses] = classIDs.DEATH_KNIGHT,
            [questKeys.objectivesText] = {"Activate the Talents interface and allocate 5 Talent Points."},
            [questKeys.objectives] = {nil,{{420044}}},
            [questKeys.zoneOrSort] = 4281,
        },
        [78225] = { -- To Northrend
            [questKeys.name] = "To Northrend",
            [questKeys.startedBy] = {{28471,28472,28474}},
            [questKeys.finishedBy] = {{26471}},
            [questKeys.requiredLevel] = 80,
            [questKeys.questLevel] = 80,
            [questKeys.requiredRaces] = raceIDs.ALL_HORDE,
            [questKeys.requiredClasses] = classIDs.DEATH_KNIGHT,
            [questKeys.objectivesText] = {"Use the scroll of teleportation from your inventory to reach Northrend and speak to the Image of Archmage Aethas Sunreaver."},
            [questKeys.requiredSourceItems] = {210046,210047},
            [questKeys.zoneOrSort] = 65,
        },
        [78752] = { -- Proof of Demise: Titan Rune Protocol Gamma
            [questKeys.name] = "Proof of Demise: Titan Rune Protocol Gamma",
            [questKeys.startedBy] = {{20735}},
            [questKeys.finishedBy] = {{20735}},
            [questKeys.requiredLevel] = 80,
            [questKeys.questLevel] = 80,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.objectivesText] = {"Archmage Lan\'dalock in Dalaran wants you to return with the Defiler\'s Medallion from any final dungeon boss.","","This quest may only be completed on any Titan Rune Protocol Gamma dungeon difficulty."},
            [questKeys.objectives] = {nil,nil,{{211206}}},
            [questKeys.zoneOrSort] = 4395,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.reputationReward] = {{factionIDs.KIRIN_TOR,75}},
        },
        [78753] = { -- Proof of Demise: Threats to Azeroth
            [questKeys.name] = "Proof of Demise: Threats to Azeroth",
            [questKeys.startedBy] = {{20735}},
            [questKeys.finishedBy] = {{20735}},
            [questKeys.requiredLevel] = 80,
            [questKeys.questLevel] = 80,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.objectivesText] = {"Archmage Lan\'dalock in Dalaran wants you to return with the Mysterious Artifact from any final dungeon boss.","","This quest may only be completed on any Heroic dungeon difficulty."},
            [questKeys.objectives] = {nil,nil,{{211207}}},
            [questKeys.zoneOrSort] = 4395,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.reputationReward] = {{factionIDs.KIRIN_TOR,75}},
        },
        [83713] = { -- Proof of Demise: Titan Rune Protocol Alpha
            [questKeys.name] = "Proof of Demise: Titan Rune Protocol Alpha",
            [questKeys.startedBy] = {{20735}},
            [questKeys.finishedBy] = {{20735}},
            [questKeys.requiredLevel] = 80,
            [questKeys.questLevel] = 80,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.objectivesText] = {"Archmage Lan\'dalock in Dalaran wants you to return with the Defiler\'s Medallion from any final dungeon boss.","","This quest may only be completed on any Titan Rune Protocol Alpha dungeon difficulty."},
            [questKeys.objectives] = {nil,nil,{{211206}}},
            [questKeys.zoneOrSort] = 4395,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.reputationReward] = {{factionIDs.KIRIN_TOR,75}},
        },
        [83714] = { -- Proof of Demise: Threats to Azeroth
            [questKeys.name] = "Proof of Demise: Threats to Azeroth",
            [questKeys.startedBy] = {{20735}},
            [questKeys.finishedBy] = {{20735}},
            [questKeys.requiredLevel] = 80,
            [questKeys.questLevel] = 80,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.objectivesText] = {"Archmage Lan\'dalock in Dalaran wants you to return with the Mysterious Artifact from any final dungeon boss.","","This quest may only be completed on any Heroic dungeon difficulty."},
            [questKeys.objectives] = {nil,nil,{{211207}}},
            [questKeys.zoneOrSort] = 4395,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.reputationReward] = {{factionIDs.KIRIN_TOR,75}},
        },
        [83717] = { -- Proof of Demise: Titan Rune Protocol Beta
            [questKeys.name] = "Proof of Demise: Titan Rune Protocol Beta",
            [questKeys.startedBy] = {{20735}},
            [questKeys.finishedBy] = {{20735}},
            [questKeys.requiredLevel] = 80,
            [questKeys.questLevel] = 80,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.objectivesText] = {"Archmage Lan\'dalock in Dalaran wants you to return with the Defiler\'s Medallion from any final dungeon boss.","","This quest may only be completed on any Titan Rune Protocol Beta dungeon difficulty."},
            [questKeys.objectives] = {nil,nil,{{211206}}},
            [questKeys.zoneOrSort] = 4395,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.reputationReward] = {{factionIDs.KIRIN_TOR,75}},
        },
        [87379] = { -- Proof of Demise: Threats to Azeroth
            [questKeys.name] = "Proof of Demise: Threats to Azeroth",
            [questKeys.startedBy] = {{20735}},
            [questKeys.finishedBy] = {{20735}},
            [questKeys.requiredLevel] = 80,
            [questKeys.questLevel] = 80,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.objectivesText] = {"Archmage Lan\'dalock in Dalaran wants you to return with the Mysterious Artifact from any final dungeon boss.","","This quest may only be completed on any Heroic dungeon difficulty."},
            [questKeys.objectives] = {nil,nil,{{211207}}},
            [questKeys.zoneOrSort] = 4395,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.questFlags] = questFlags.DAILY,
            [questKeys.reputationReward] = {{factionIDs.KIRIN_TOR,75}},
        },
        [93950] = { -- A Message From The Stars -- only present on titan reforged
            [questKeys.name] = "A Message From The Stars",
            [questKeys.startedBy] = {{257012}},
            [questKeys.finishedBy] = {{257012}},
            [questKeys.requiredLevel] = 1,
            [questKeys.questLevel] = 80,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.objectivesText] = {"Accept Algalon's Gift."},
            [questKeys.zoneOrSort] = sortKeys.TITAN_REFORGED_REALM,
            [questKeys.specialFlags] = specialFlags.NONE,
            [questKeys.questFlags] = questFlags.NONE,
        },
        [93975] = { -- Ragnaros Must Die! -- only present on titan reforged
            [questKeys.name] = "Ragnaros Must Die!",
            [questKeys.startedBy] = {{20735}},
            [questKeys.finishedBy] = {{20735}},
            [questKeys.requiredLevel] = 80,
            [questKeys.questLevel] = 80,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.objectivesText] = {"Kill Ragnaros."},
            [questKeys.objectives] = {{{11502}}},
            [questKeys.zoneOrSort] = zoneIDs.MOLTEN_CORE,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.questFlags] = questFlags.WEEKLY,
            [questKeys.exclusiveTo] = {94577,94579,95037,96312,96315,96318},
            [questKeys.reputationReward] = {{factionIDs.KIRIN_TOR,75}},
        },
        [94376] = { -- Titanic Power -- only present on titan reforged
            [questKeys.name] = "Titanic Power",
            [questKeys.startedBy] = {{257403}},
            [questKeys.finishedBy] = {{257403}},
            [questKeys.requiredLevel] = 69,
            [questKeys.questLevel] = 80,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.objectivesText] = {"Speak to Algalon and learn about Titanic Embers."},
            [questKeys.zoneOrSort] = zoneIDs.STORM_PEAKS,
            [questKeys.specialFlags] = specialFlags.NONE,
            [questKeys.questFlags] = questFlags.NONE,
        },
        [94576] = { -- Find a New Way -- only present on titan reforged
            [questKeys.name] = "Find a New Way",
            [questKeys.startedBy] = {{31136}},
            [questKeys.finishedBy] = {{31136}},
            [questKeys.requiredLevel] = 80,
            [questKeys.questLevel] = 80,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.objectivesText] = {"Find a way to power the Wind - Kissed Blade, then return to High Warlord Uro in the sewers of Dalaran."},
            [questKeys.zoneOrSort] = sortKeys.LEGENDARY,
            [questKeys.specialFlags] = specialFlags.NONE,
            [questKeys.questFlags] = questFlags.NONE,
            [questKeys.preQuestSingle] = {7787},
        },
        [94577] = { -- Kael'thas Must Die! -- only present on titan reforged
            [questKeys.name] = "Kael'thas Must Die!",
            [questKeys.startedBy] = {{20735}},
            [questKeys.finishedBy] = {{20735}},
            [questKeys.requiredLevel] = 80,
            [questKeys.questLevel] = 80,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.objectivesText] = {"Kill Kael'thas Sunstrider in Tempest Keep."},
            [questKeys.objectives] = {{{19622}}},
            [questKeys.zoneOrSort] = zoneIDs.TEMPEST_KEEP,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.questFlags] = questFlags.WEEKLY,
            [questKeys.exclusiveTo] = {93975,94579,95037,96312,96315,96318},
            [questKeys.reputationReward] = {{factionIDs.KIRIN_TOR,75}},
        },
        [94579] = { -- Patchwerk Must Die! -- only present on titan reforged
            [questKeys.name] = "Patchwerk Must Die!",
            [questKeys.startedBy] = {{20735}},
            [questKeys.finishedBy] = {{20735}},
            [questKeys.requiredLevel] = 80,
            [questKeys.questLevel] = 80,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.objectivesText] = {"Kill Patchwerk."},
            [questKeys.objectives] = {{{16028}}},
            [questKeys.zoneOrSort] = zoneIDs.NAXXRAMAS,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.questFlags] = questFlags.WEEKLY,
            [questKeys.exclusiveTo] = {93975,94577,95037,96312,96315,96318},
            [questKeys.reputationReward] = {{factionIDs.KIRIN_TOR,75}},
        },
        [95037] = { -- Lord Jaraxxus Must Die! -- only present on titan reforged
            [questKeys.name] = "Lord Jaraxxus Must Die!",
            [questKeys.startedBy] = {{20735}},
            [questKeys.finishedBy] = {{20735}},
            [questKeys.requiredLevel] = 80,
            [questKeys.questLevel] = 80,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.objectivesText] = {"Kill Lord Jaraxxus."},
            [questKeys.objectives] = {{{34780}}},
            [questKeys.zoneOrSort] = zoneIDs.TRIAL_OF_THE_CRUSADER,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.questFlags] = questFlags.WEEKLY,
            [questKeys.exclusiveTo] = {93975,94577,94579,96312,96315,96318},
            [questKeys.reputationReward] = {{factionIDs.KIRIN_TOR,75}},
        },
        [95072] = { -- Hoodoo Embodiment
            [questKeys.name] = "Hoodoo Embodiment",
            [questKeys.startedBy] = {{15042}},
            [questKeys.finishedBy] = {{15042}},
            [questKeys.requiredLevel] = 80,
            [questKeys.questLevel] = 80,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.requiredClasses] = classIDs.WARLOCK,
            [questKeys.objectives] = {nil,nil,{{274994},{19819}}},
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMinRep] = {factionIDs.ZANDALAR_TRIBE,3000},
            [questKeys.reputationReward] = {{factionIDs.ZANDALAR_TRIBE,250}},
        },
        [95074] = { -- Falcon's Prophecy
            [questKeys.name] = "Falcon's Prophecy",
            [questKeys.startedBy] = {{15042}},
            [questKeys.finishedBy] = {{15042}},
            [questKeys.requiredLevel] = 80,
            [questKeys.questLevel] = 80,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.requiredClasses] = classIDs.HUNTER,
            [questKeys.objectives] = {nil,nil,{{274994},{19816}}},
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMinRep] = {factionIDs.ZANDALAR_TRIBE,3000},
            [questKeys.reputationReward] = {{factionIDs.ZANDALAR_TRIBE,250}},
        },
        [95075] = { -- Destructive Prophecy
            [questKeys.name] = "Destructive Prophecy",
            [questKeys.startedBy] = {{15042}},
            [questKeys.finishedBy] = {{15042}},
            [questKeys.requiredLevel] = 80,
            [questKeys.questLevel] = 80,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.requiredClasses] = classIDs.PRIEST,
            [questKeys.objectives] = {nil,nil,{{274994},{19820}}},
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMinRep] = {factionIDs.ZANDALAR_TRIBE,3000},
            [questKeys.reputationReward] = {{factionIDs.ZANDALAR_TRIBE,250}},
        },
        [95076] = { -- Divine Prophecy
            [questKeys.name] = "Divine Prophecy",
            [questKeys.startedBy] = {{15042}},
            [questKeys.finishedBy] = {{15042}},
            [questKeys.requiredLevel] = 80,
            [questKeys.questLevel] = 80,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.requiredClasses] = classIDs.PALADIN,
            [questKeys.objectives] = {nil,nil,{{274994},{19815}}},
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMinRep] = {factionIDs.ZANDALAR_TRIBE,3000},
            [questKeys.reputationReward] = {{factionIDs.ZANDALAR_TRIBE,250}},
        },
        [95077] = { -- Redeemer's Prophecy
            [questKeys.name] = "Redeemer's Prophecy",
            [questKeys.startedBy] = {{15042}},
            [questKeys.finishedBy] = {{15042}},
            [questKeys.requiredLevel] = 80,
            [questKeys.questLevel] = 80,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.requiredClasses] = classIDs.PALADIN,
            [questKeys.objectives] = {nil,nil,{{274994},{19815}}},
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMinRep] = {factionIDs.ZANDALAR_TRIBE,3000},
            [questKeys.reputationReward] = {{factionIDs.ZANDALAR_TRIBE,250}},
        },
        [95078] = { -- Prophecy of Protection
            [questKeys.name] = "Prophecy of Protection",
            [questKeys.startedBy] = {{15042}},
            [questKeys.finishedBy] = {{15042}},
            [questKeys.requiredLevel] = 80,
            [questKeys.questLevel] = 80,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.requiredClasses] = classIDs.WARRIOR,
            [questKeys.objectives] = {nil,nil,{{274994},{19813}}},
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMinRep] = {factionIDs.ZANDALAR_TRIBE,3000},
            [questKeys.reputationReward] = {{factionIDs.ZANDALAR_TRIBE,250}},
        },
        [95079] = { -- Stormcaller's Prophecy
            [questKeys.name] = "Stormcaller's Prophecy",
            [questKeys.startedBy] = {{15042}},
            [questKeys.finishedBy] = {{15042}},
            [questKeys.requiredLevel] = 80,
            [questKeys.questLevel] = 80,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.requiredClasses] = classIDs.SHAMAN,
            [questKeys.objectives] = {nil,nil,{{274994},{19817}}},
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMinRep] = {factionIDs.ZANDALAR_TRIBE,3000},
            [questKeys.reputationReward] = {{factionIDs.ZANDALAR_TRIBE,250}},
        },
        [95080] = { -- Witchdoctor's Prophecy
            [questKeys.name] = "Witchdoctor's Prophecy",
            [questKeys.startedBy] = {{15042}},
            [questKeys.finishedBy] = {{15042}},
            [questKeys.requiredLevel] = 80,
            [questKeys.questLevel] = 80,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.requiredClasses] = classIDs.SHAMAN,
            [questKeys.objectives] = {nil,nil,{{274994},{19817}}},
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMinRep] = {factionIDs.ZANDALAR_TRIBE,3000},
            [questKeys.reputationReward] = {{factionIDs.ZANDALAR_TRIBE,250}},
        },
        [95081] = { -- Guardian's Prophecy
            [questKeys.name] = "Guardian's Prophecy",
            [questKeys.startedBy] = {{15042}},
            [questKeys.finishedBy] = {{15042}},
            [questKeys.requiredLevel] = 80,
            [questKeys.questLevel] = 80,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.requiredClasses] = classIDs.DRUID,
            [questKeys.objectives] = {nil,nil,{{274994},{19821}}},
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMinRep] = {factionIDs.ZANDALAR_TRIBE,3000},
            [questKeys.reputationReward] = {{factionIDs.ZANDALAR_TRIBE,250}},
        },
        [95082] = { -- Lunar Prophecy
            [questKeys.name] = "Lunar Prophecy",
            [questKeys.startedBy] = {{15042}},
            [questKeys.finishedBy] = {{15042}},
            [questKeys.requiredLevel] = 80,
            [questKeys.questLevel] = 80,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.requiredClasses] = classIDs.DRUID,
            [questKeys.objectives] = {nil,nil,{{274994},{19821}}},
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMinRep] = {factionIDs.ZANDALAR_TRIBE,3000},
            [questKeys.reputationReward] = {{factionIDs.ZANDALAR_TRIBE,250}},
        },
        [95083] = { -- Naturalist's Prophecy
            [questKeys.name] = "Naturalist's Prophecy",
            [questKeys.startedBy] = {{15042}},
            [questKeys.finishedBy] = {{15042}},
            [questKeys.requiredLevel] = 80,
            [questKeys.questLevel] = 80,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.requiredClasses] = classIDs.DRUID,
            [questKeys.objectives] = {nil,nil,{{274994},{19821}}},
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMinRep] = {factionIDs.ZANDALAR_TRIBE,3000},
            [questKeys.reputationReward] = {{factionIDs.ZANDALAR_TRIBE,250}},
        },
        [95084] = { -- Dread Prophecy
            [questKeys.name] = "Dread Prophecy",
            [questKeys.startedBy] = {{15042}},
            [questKeys.finishedBy] = {{15042}},
            [questKeys.requiredLevel] = 80,
            [questKeys.questLevel] = 80,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.requiredClasses] = classIDs.DEATH_KNIGHT,
            [questKeys.objectives] = {nil,nil,{{274994},{268145}}},
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMinRep] = {factionIDs.ZANDALAR_TRIBE,3000},
            [questKeys.reputationReward] = {{factionIDs.ZANDALAR_TRIBE,250}},
        },
        [95085] = { -- Desecrator's Prophecy
            [questKeys.name] = "Desecrator's Prophecy",
            [questKeys.startedBy] = {{15042}},
            [questKeys.finishedBy] = {{15042}},
            [questKeys.requiredLevel] = 80,
            [questKeys.questLevel] = 80,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.requiredClasses] = classIDs.DEATH_KNIGHT,
            [questKeys.objectives] = {nil,nil,{{274994},{268145}}},
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMinRep] = {factionIDs.ZANDALAR_TRIBE,3000},
            [questKeys.reputationReward] = {{factionIDs.ZANDALAR_TRIBE,250}},
        },
        [95088] = { -- Death's Embodiment
            [questKeys.name] = "Death's Embodiment",
            [questKeys.startedBy] = {{15042}},
            [questKeys.finishedBy] = {{15042}},
            [questKeys.requiredLevel] = 80,
            [questKeys.questLevel] = 80,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.requiredClasses] = classIDs.ROGUE,
            [questKeys.objectives] = {nil,nil,{{274994},{19814}}},
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMinRep] = {factionIDs.ZANDALAR_TRIBE,3000},
            [questKeys.reputationReward] = {{factionIDs.ZANDALAR_TRIBE,250}},
        },
        [95089] = { -- Arcanist's Embodiment
            [questKeys.name] = "Arcanist's Embodiment",
            [questKeys.startedBy] = {{15042}},
            [questKeys.finishedBy] = {{15042}},
            [questKeys.requiredLevel] = 80,
            [questKeys.questLevel] = 80,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.requiredClasses] = classIDs.MAGE,
            [questKeys.objectives] = {nil,nil,{{274994},{19818}}},
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMinRep] = {factionIDs.ZANDALAR_TRIBE,3000},
            [questKeys.reputationReward] = {{factionIDs.ZANDALAR_TRIBE,250}},
        },
        [95090] = { -- Embodiment of Desecration
            [questKeys.name] = "Embodiment of Desecration",
            [questKeys.startedBy] = {{15042}},
            [questKeys.finishedBy] = {{15042}},
            [questKeys.requiredLevel] = 80,
            [questKeys.questLevel] = 80,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.requiredClasses] = classIDs.DEATH_KNIGHT,
            [questKeys.objectives] = {nil,nil,{{274994},{268145}}},
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMinRep] = {factionIDs.ZANDALAR_TRIBE,3000},
            [questKeys.reputationReward] = {{factionIDs.ZANDALAR_TRIBE,250}},
        },
        [95092] = { -- Embodiment of Dread
            [questKeys.name] = "Embodiment of Dread",
            [questKeys.startedBy] = {{15042}},
            [questKeys.finishedBy] = {{15042}},
            [questKeys.requiredLevel] = 80,
            [questKeys.questLevel] = 80,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.requiredClasses] = classIDs.DEATH_KNIGHT,
            [questKeys.objectives] = {nil,nil,{{274994},{268145}}},
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMinRep] = {factionIDs.ZANDALAR_TRIBE,3000},
            [questKeys.reputationReward] = {{factionIDs.ZANDALAR_TRIBE,250}},
        },
        [95093] = { -- Embodiment of Protection
            [questKeys.name] = "Embodiment of Protection",
            [questKeys.startedBy] = {{15042}},
            [questKeys.finishedBy] = {{15042}},
            [questKeys.requiredLevel] = 80,
            [questKeys.questLevel] = 80,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.requiredClasses] = classIDs.WARRIOR,
            [questKeys.objectives] = {nil,nil,{{274994},{19813}}},
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMinRep] = {factionIDs.ZANDALAR_TRIBE,3000},
            [questKeys.reputationReward] = {{factionIDs.ZANDALAR_TRIBE,250}},
        },
        [95094] = { -- Embodiment of Wrath
            [questKeys.name] = "Embodiment of Wrath",
            [questKeys.startedBy] = {{15042}},
            [questKeys.finishedBy] = {{15042}},
            [questKeys.requiredLevel] = 80,
            [questKeys.questLevel] = 80,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.requiredClasses] = classIDs.WARRIOR,
            [questKeys.objectives] = {nil,nil,{{274994},{19813}}},
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMinRep] = {factionIDs.ZANDALAR_TRIBE,3000},
            [questKeys.reputationReward] = {{factionIDs.ZANDALAR_TRIBE,250}},
        },
        [95095] = { -- Auratic Embodiment
            [questKeys.name] = "Auratic Embodiment",
            [questKeys.startedBy] = {{15042}},
            [questKeys.finishedBy] = {{15042}},
            [questKeys.requiredLevel] = 80,
            [questKeys.questLevel] = 80,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.requiredClasses] = classIDs.PRIEST,
            [questKeys.objectives] = {nil,nil,{{274994},{19820}}},
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMinRep] = {factionIDs.ZANDALAR_TRIBE,3000},
            [questKeys.reputationReward] = {{factionIDs.ZANDALAR_TRIBE,250}},
        },
        [95096] = { -- Destructive Embodiment
            [questKeys.name] = "Destructive Embodiment",
            [questKeys.startedBy] = {{15042}},
            [questKeys.finishedBy] = {{15042}},
            [questKeys.requiredLevel] = 80,
            [questKeys.questLevel] = 80,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.requiredClasses] = classIDs.PRIEST,
            [questKeys.objectives] = {nil,nil,{{274994},{19820}}},
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMinRep] = {factionIDs.ZANDALAR_TRIBE,3000},
            [questKeys.reputationReward] = {{factionIDs.ZANDALAR_TRIBE,250}},
        },
        [95097] = { -- Syncretist's Embodiment
            [questKeys.name] = "Syncretist's Embodiment",
            [questKeys.startedBy] = {{15042}},
            [questKeys.finishedBy] = {{15042}},
            [questKeys.requiredLevel] = 80,
            [questKeys.questLevel] = 80,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.requiredClasses] = classIDs.PALADIN,
            [questKeys.objectives] = {nil,nil,{{274994},{19815}}},
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMinRep] = {factionIDs.ZANDALAR_TRIBE,3000},
            [questKeys.reputationReward] = {{factionIDs.ZANDALAR_TRIBE,250}},
        },
        [95098] = { -- Divine Embodiment
            [questKeys.name] = "Divine Embodiment",
            [questKeys.startedBy] = {{15042}},
            [questKeys.finishedBy] = {{15042}},
            [questKeys.requiredLevel] = 80,
            [questKeys.questLevel] = 80,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.requiredClasses] = classIDs.PALADIN,
            [questKeys.objectives] = {nil,nil,{{274994},{19815}}},
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMinRep] = {factionIDs.ZANDALAR_TRIBE,3000},
            [questKeys.reputationReward] = {{factionIDs.ZANDALAR_TRIBE,250}},
        },
        [95099] = { -- Redeemer's Embodiment
            [questKeys.name] = "Redeemer's Embodiment",
            [questKeys.startedBy] = {{15042}},
            [questKeys.finishedBy] = {{15042}},
            [questKeys.requiredLevel] = 80,
            [questKeys.questLevel] = 80,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.requiredClasses] = classIDs.PALADIN,
            [questKeys.objectives] = {nil,nil,{{274994},{19815}}},
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMinRep] = {factionIDs.ZANDALAR_TRIBE,3000},
            [questKeys.reputationReward] = {{factionIDs.ZANDALAR_TRIBE,250}},
        },
        [95100] = { -- Witchdoctor's Embodiment
            [questKeys.name] = "Witchdoctor's Embodiment",
            [questKeys.startedBy] = {{15042}},
            [questKeys.finishedBy] = {{15042}},
            [questKeys.requiredLevel] = 80,
            [questKeys.questLevel] = 80,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.requiredClasses] = classIDs.SHAMAN,
            [questKeys.objectives] = {nil,nil,{{274994},{19817}}},
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMinRep] = {factionIDs.ZANDALAR_TRIBE,3000},
            [questKeys.reputationReward] = {{factionIDs.ZANDALAR_TRIBE,250}},
        },
        [95101] = { -- Vodouisant's Embodiment
            [questKeys.name] = "Vodouisant's Embodiment",
            [questKeys.startedBy] = {{15042}},
            [questKeys.finishedBy] = {{15042}},
            [questKeys.requiredLevel] = 80,
            [questKeys.questLevel] = 80,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.requiredClasses] = classIDs.SHAMAN,
            [questKeys.objectives] = {nil,nil,{{274994},{19817}}},
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMinRep] = {factionIDs.ZANDALAR_TRIBE,3000},
            [questKeys.reputationReward] = {{factionIDs.ZANDALAR_TRIBE,250}},
        },
        [95102] = { -- Stormcaller's Embodiment
            [questKeys.name] = "Stormcaller's Embodiment",
            [questKeys.startedBy] = {{15042}},
            [questKeys.finishedBy] = {{15042}},
            [questKeys.requiredLevel] = 80,
            [questKeys.questLevel] = 80,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.requiredClasses] = classIDs.SHAMAN,
            [questKeys.objectives] = {nil,nil,{{274994},{19817}}},
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMinRep] = {factionIDs.ZANDALAR_TRIBE,3000},
            [questKeys.reputationReward] = {{factionIDs.ZANDALAR_TRIBE,250}},
        },
        [95103] = { -- Guardian's Embodiment
            [questKeys.name] = "Guardian's Embodiment",
            [questKeys.startedBy] = {{15042}},
            [questKeys.finishedBy] = {{15042}},
            [questKeys.requiredLevel] = 80,
            [questKeys.questLevel] = 80,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.requiredClasses] = classIDs.DRUID,
            [questKeys.objectives] = {nil,nil,{{274994},{19821}}},
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMinRep] = {factionIDs.ZANDALAR_TRIBE,3000},
            [questKeys.reputationReward] = {{factionIDs.ZANDALAR_TRIBE,250}},
        },
        [95104] = { -- Animist's Embodiment
            [questKeys.name] = "Animist's Embodiment",
            [questKeys.startedBy] = {{15042}},
            [questKeys.finishedBy] = {{15042}},
            [questKeys.requiredLevel] = 80,
            [questKeys.questLevel] = 80,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.requiredClasses] = classIDs.DRUID,
            [questKeys.objectives] = {nil,nil,{{274994},{19821}}},
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMinRep] = {factionIDs.ZANDALAR_TRIBE,3000},
            [questKeys.reputationReward] = {{factionIDs.ZANDALAR_TRIBE,250}},
        },
        [95105] = { -- Lunar Embodiment
            [questKeys.name] = "Lunar Embodiment",
            [questKeys.startedBy] = {{15042}},
            [questKeys.finishedBy] = {{15042}},
            [questKeys.requiredLevel] = 80,
            [questKeys.questLevel] = 80,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.requiredClasses] = classIDs.DRUID,
            [questKeys.objectives] = {nil,nil,{{274994},{19821}}},
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMinRep] = {factionIDs.ZANDALAR_TRIBE,3000},
            [questKeys.reputationReward] = {{factionIDs.ZANDALAR_TRIBE,250}},
        },
        [95106] = { -- Naturalist's Embodiment
            [questKeys.name] = "Naturalist's Embodiment",
            [questKeys.startedBy] = {{15042}},
            [questKeys.finishedBy] = {{15042}},
            [questKeys.requiredLevel] = 80,
            [questKeys.questLevel] = 80,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.requiredClasses] = classIDs.DRUID,
            [questKeys.objectives] = {nil,nil,{{274994},{19821}}},
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.requiredMinRep] = {factionIDs.ZANDALAR_TRIBE,3000},
            [questKeys.reputationReward] = {{factionIDs.ZANDALAR_TRIBE,250}},
        },
        [95205] = { -- Greater Inscrptions of the Zandalar -- only present on titan reforged
            [questKeys.name] = "Greater Inscrptions of the Zandalar",
            [questKeys.startedBy] = {{14921}},
            [questKeys.finishedBy] = {{14921}},
            [questKeys.requiredLevel] = 80,
            [questKeys.questLevel] = 80,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.objectivesText] = {},
            [questKeys.objectives] = {nil,nil,{{19858},{43127}},{270,42000}}, -- TO FIX: need to do {item - rep - item} objective format
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.questFlags] = questFlags.NONE,
            [questKeys.requiredMinRep] = {factionIDs.ZANDALAR_TRIBE,42000},
            [questKeys.requiredSkill] = {profKeys.INSCRIPTION,450},
        },
        [95705] = { -- Gobb's Grand Opening! -- only present on titan reforged
            [questKeys.name] = "Gobb's Grand Opening!",
            [questKeys.startedBy] = {{262258}},
            [questKeys.finishedBy] = {{262258}},
            [questKeys.requiredLevel] = 80,
            [questKeys.questLevel] = 80,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.objectivesText] = {"Boss Gobb Goldnick wants you to purchase one Greedy Chest from his black-market stash to prove you're a paying customer worth fleec-- err, serving."},
            [questKeys.zoneOrSort] = sortKeys.SPECIAL,
            [questKeys.specialFlags] = specialFlags.NONE,
            [questKeys.questFlags] = questFlags.NONE,
            [questKeys.nextQuestInChain] = 95706,
        },
        [95706] = { -- Gobb's Weekly Greed Deal -- only present on titan reforged
            [questKeys.name] = "Gobb's Weekly Greed Deal",
            [questKeys.startedBy] = {{262258}},
            [questKeys.finishedBy] = {{262258}},
            [questKeys.requiredLevel] = 80,
            [questKeys.questLevel] = 80,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.objectivesText] = {"Purchase a weekly Greedy Chest from Boss Gobb Goldnick's limited stock. Supplies reset every week. If you miss out, tough luck!"},
            [questKeys.zoneOrSort] = sortKeys.SPECIAL,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.questFlags] = questFlags.NONE,
            [questKeys.preQuestSingle] = {95705},
        },
        [95844] = { -- Gobb's Grand Tank Temptation -- only present on titan reforged
            [questKeys.name] = "Gobb's Grand Tank Temptation",
            [questKeys.startedBy] = {{262258}},
            [questKeys.finishedBy] = {{262258}},
            [questKeys.requiredLevel] = 80,
            [questKeys.questLevel] = 80,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.objectivesText] = {"Purchase a weekly Black Qiraji Chest from Boss Gobb Goldnick's limited stock. Supplies reset every week. If you miss out, tough luck!"},
            [questKeys.zoneOrSort] = sortKeys.SPECIAL,
            [questKeys.specialFlags] = specialFlags.NONE,
            [questKeys.questFlags] = questFlags.NONE,
            [questKeys.nextQuestInChain] = 95845,
        },
        [95845] = { -- Another Shot at the Scarab -- only present on titan reforged
            [questKeys.name] = "Another Shot at the Scarab",
            [questKeys.startedBy] = {{262258}},
            [questKeys.finishedBy] = {{262258}},
            [questKeys.requiredLevel] = 80,
            [questKeys.questLevel] = 80,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.objectivesText] = {"Purchase a weekly Black Qiraji Chest from Boss Gobb Goldnick's limited stock. Supplies reset every week. If you miss out, tough luck!"},
            [questKeys.zoneOrSort] = sortKeys.SPECIAL,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.questFlags] = questFlags.NONE,
            [questKeys.preQuestSingle] = {95844},
        },
        [96211] = { -- Heart of the Eredar -- only present on titan reforged
            [questKeys.name] = "Heart of the Eredar",
            [questKeys.startedBy] = {nil,nil,{272955}},
            [questKeys.finishedBy] = {{80007}},
            [questKeys.sourceItemId] = 272955,
            [questKeys.requiredLevel] = 80,
            [questKeys.questLevel] = 80,
            [questKeys.requiredClasses] = classIDs.WARRIOR + classIDs.HUNTER + classIDs.ROGUE + classIDs.SHAMAN,
            [questKeys.objectivesText] = {"Find a suitable purpose for the Eredar Heart."},
            [questKeys.objectives] = {nil,{{420002}}},
            [questKeys.zoneOrSort] = sortKeys.LEGENDARY,
            [questKeys.specialFlags] = specialFlags.NONE,
            [questKeys.questFlags] = questFlags.NONE,
        },
        [96312] = { -- Brutallus Must Die! -- only present on titan reforged
            [questKeys.name] = "Brutallus Must Die!",
            [questKeys.startedBy] = {{20735}},
            [questKeys.finishedBy] = {{20735}},
            [questKeys.requiredLevel] = 80,
            [questKeys.questLevel] = 80,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.objectivesText] = {"Kill Brutallus."},
            [questKeys.objectives] = {{{24882}}},
            [questKeys.zoneOrSort] = zoneIDs.SUNWELL_PLATEAU,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.questFlags] = questFlags.WEEKLY,
            [questKeys.exclusiveTo] = {93975,94577,94579,95037,96315,96318},
            [questKeys.reputationReward] = {{factionIDs.KIRIN_TOR,75}},
        },
        [96315] = { -- XT-002 Deconstructor Must Die! -- only present on titan reforged
            [questKeys.name] = "XT-002 Deconstructor Must Die!",
            [questKeys.startedBy] = {{20735}},
            [questKeys.finishedBy] = {{20735}},
            [questKeys.requiredLevel] = 80,
            [questKeys.questLevel] = 80,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.objectivesText] = {"Kill XT-002 Deconstructor."},
            [questKeys.objectives] = {{{33293}}},
            [questKeys.zoneOrSort] = zoneIDs.ULDUAR,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.questFlags] = questFlags.WEEKLY,
            [questKeys.exclusiveTo] = {93975,94577,94579,95037,96312,96318},
            [questKeys.reputationReward] = {{factionIDs.KIRIN_TOR,75}},
        },
        [96318] = { -- Shade of Aran Must Die!-- only present on titan reforged
            [questKeys.name] = "Shade of Aran Must Die!",
            [questKeys.startedBy] = {{20735}},
            [questKeys.finishedBy] = {{20735}},
            [questKeys.requiredLevel] = 80,
            [questKeys.questLevel] = 80,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.objectivesText] = {"Kill Shade of Aran."},
            [questKeys.objectives] = {{{16524}}},
            [questKeys.zoneOrSort] = zoneIDs.KARAZHAN,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.questFlags] = questFlags.WEEKLY,
            [questKeys.exclusiveTo] = {93975,94577,94579,95037,96312,96315},
            [questKeys.reputationReward] = {{factionIDs.KIRIN_TOR,75}},
        },
        [98183] = { -- A Ritual Renewed -- only present on titan reforged
            [questKeys.name] = "A Ritual Renewed",
            [questKeys.startedBy] = {{14910}},
            [questKeys.finishedBy] = {{14910}},
            [questKeys.requiredLevel] = 80,
            [questKeys.questLevel] = 80,
            [questKeys.requiredRaces] = raceIDs.NONE,
            [questKeys.objectivesText] = {"Accept The Empowered Zandalari Bijou."},
            [questKeys.zoneOrSort] = zoneIDs.ZUL_GURUB,
            [questKeys.specialFlags] = specialFlags.REPEATABLE,
            [questKeys.questFlags] = questFlags.WEEKLY,
        },
    }
end

function QuestieWotlkQuestFixes:LoadFactionFixes()
    local questKeys = QuestieDB.questKeys
    local factionIDs = QuestieDB.factionIDs

    local questFixesHorde = {
        [13012] = { -- Sardis the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE,75}},
        },
        [13013] = { -- Beldak the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE,75}},
        },
        [13014] = { -- Morthie the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE,75}},
        },
        [13015] = { -- Fargal the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE,75}},
        },
        [13016] = { -- Northal the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE,75}},
        },
        [13017] = { -- Jarten the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE,75}},
        },
        [13018] = { -- Sandrene the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE,75}},
        },
        [13019] = { -- Thoim the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE,75}},
        },
        [13020] = { -- Stonebeard the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE,75}},
        },
        [13021] = { -- Igasho the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE,75}},
        },
        [13022] = { -- Nurgen the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE,75}},
        },
        [13023] = { -- Kilias the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE,75}},
        },
        [13024] = { -- Wanikaya the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE,75}},
        },
        [13025] = { -- Lunaro the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE,75}},
        },
        [13026] = { -- Bluewolf the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE,75}},
        },
        [13027] = { -- Tauros the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE,75}},
        },
        [13028] = { -- Graymane the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE,75}},
        },
        [13029] = { -- Pamuya the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE,75}},
        },
        [13030] = { -- Whurain the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE,75}},
        },
        [13031] = { -- Skywarden the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE,75}},
        },
        [13032] = { -- Muraco the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE,75}},
        },
        [13033] = { -- Arp the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE,75}},
        },
        [13065] = { -- Ohanzee the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE,75}},
        },
        [13066] = { -- Yurauk the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE,75}},
        },
        [13067] = { -- Chogan'gada the Elder
            [questKeys.reputationReward] = {{factionIDs.HORDE,75}},
        },
    }

    local questFixesAlliance = {
        [13012] = { -- Sardis the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,75}},
        },
        [13013] = { -- Beldak the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,75}},
        },
        [13014] = { -- Morthie the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,75}},
        },
        [13015] = { -- Fargal the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,75}},
        },
        [13016] = { -- Northal the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,75}},
        },
        [13017] = { -- Jarten the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,75}},
        },
        [13018] = { -- Sandrene the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,75}},
        },
        [13019] = { -- Thoim the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,75}},
        },
        [13020] = { -- Stonebeard the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,75}},
        },
        [13021] = { -- Igasho the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,75}},
        },
        [13022] = { -- Nurgen the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,75}},
        },
        [13023] = { -- Kilias the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,75}},
        },
        [13024] = { -- Wanikaya the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,75}},
        },
        [13025] = { -- Lunaro the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,75}},
        },
        [13026] = { -- Bluewolf the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,75}},
        },
        [13027] = { -- Tauros the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,75}},
        },
        [13028] = { -- Graymane the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,75}},
        },
        [13029] = { -- Pamuya the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,75}},
        },
        [13030] = { -- Whurain the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,75}},
        },
        [13031] = { -- Skywarden the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,75}},
        },
        [13032] = { -- Muraco the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,75}},
        },
        [13033] = { -- Arp the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,75}},
        },
        [13065] = { -- Ohanzee the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,75}},
        },
        [13066] = { -- Yurauk the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,75}},
        },
        [13067] = { -- Chogan'gada the Elder
            [questKeys.reputationReward] = {{factionIDs.ALLIANCE,75}},
        },
    }

    if UnitFactionGroup("Player") == "Horde" then
        return questFixesHorde
    else
        return questFixesAlliance
    end
end

function QuestieWotlkQuestFixes:LoadTitanReforgedFixes()
    local questKeys = QuestieDB.questKeys
    local classIDs = QuestieDB.classKeys

    return {
        [6805] = { -- Greater Stormers and Rumblers
            [questKeys.name] = "Greater Stormers and Rumblers",
            [questKeys.questLevel] = 80,
            [questKeys.requiredLevel] = 80,
            [questKeys.objectivesText] = {"Kill 15 Greater Dust Stormers and 15 Greater Desert Rumblers and then return to Duke Hydraxis in Azshara."},
            [questKeys.objectives] = {{{256887},{256889}}},
            [questKeys.nextQuestInChain] = 6822,
        },
        [6822] = { -- The Molten Core
            [questKeys.questLevel] = 80,
            [questKeys.requiredLevel] = 80,
            [questKeys.preQuestSingle] = {6805},
        },
        [6823] = { -- Agent of Hydraxis
            [questKeys.questLevel] = 80,
            [questKeys.requiredLevel] = 80,
        },
        [6824] = { -- Hands of the Enemy
            [questKeys.questLevel] = 80,
            [questKeys.requiredLevel] = 80,
        },
        [7486] = { -- A Hero's Reward
            [questKeys.questLevel] = 80,
            [questKeys.requiredLevel] = 80,
        },
        [7787] = { -- Rise, Thunderfury!
            [questKeys.name] = "Legend of the Past",
            [questKeys.questLevel] = 80,
            [questKeys.requiredLevel] = 80,
            [questKeys.finishedBy] = {{31136}},
            [questKeys.objectivesText] = {"Look for someone who has knowledge about the Dormant Blade."},
            [questKeys.preQuestSingle] = {},
            [questKeys.nextQuestInChain] = 94576,
        },
        [8183] = { -- The Heart of Hakkar
            [questKeys.questLevel] = 80,
            [questKeys.requiredLevel] = 80,
        },
        [8184] = { -- Prophecy of Wrath
            [questKeys.name] = "Prophecy of Wrath",
            [questKeys.questLevel] = 80,
            [questKeys.requiredLevel] = 80,
            [questKeys.objectives] = {nil,nil,{{274994},{19813}}},
        },
        [8185] = { -- Syncretist's Prophecy
            [questKeys.name] = "Syncretist's Prophecy",
            [questKeys.questLevel] = 80,
            [questKeys.requiredLevel] = 80,
            [questKeys.objectives] = {nil,nil,{{274994},{19815}}},
        },
        [8186] = { -- Death's Prophecy
            [questKeys.name] = "Death's Prophecy",
            [questKeys.questLevel] = 80,
            [questKeys.requiredLevel] = 80,
            [questKeys.objectives] = {nil,nil,{{274994},{19814}}},
        },
        [8187] = { -- Falcon's Embodiment
            [questKeys.name] = "Falcon's Embodiment",
            [questKeys.questLevel] = 80,
            [questKeys.requiredLevel] = 80,
            [questKeys.objectives] = {nil,nil,{{274994},{19816}}},
        },
        [8188] = { -- Vodouisant's Prophecy
            [questKeys.name] = "Vodouisant's Prophecy",
            [questKeys.questLevel] = 80,
            [questKeys.requiredLevel] = 80,
            [questKeys.objectives] = {nil,nil,{{274994},{19817}}},
        },
        [8189] = { -- Arcanist's Prophecy
            [questKeys.name] = "Arcanist's Prophecy",
            [questKeys.questLevel] = 80,
            [questKeys.requiredLevel] = 80,
            [questKeys.objectives] = {nil,nil,{{274994},{19818}}},
        },
        [8190] = { -- Hoodoo Prophecy
            [questKeys.name] = "Hoodoo Prophecy",
            [questKeys.questLevel] = 80,
            [questKeys.requiredLevel] = 80,
            [questKeys.objectives] = {nil,nil,{{274994},{19819}}},
        },
        [8191] = { -- Auratic Prophecy
            [questKeys.name] = "Auratic Prophecy",
            [questKeys.questLevel] = 80,
            [questKeys.requiredLevel] = 80,
            [questKeys.objectives] = {nil,nil,{{274994},{19820}}},
        },
        [8192] = { -- Animist's Prophecy
            [questKeys.name] = "Animist's Prophecy",
            [questKeys.questLevel] = 80,
            [questKeys.requiredLevel] = 80,
            [questKeys.objectives] = {nil,nil,{{274994},{19821}}},
        },
        [8195] = { -- Zulian, Razzashi, and Hakkari Coins
            [questKeys.questLevel] = 80,
            [questKeys.requiredLevel] = 80,
        },
        [8196] = { -- Essence Mangoes
            [questKeys.questLevel] = 80,
            [questKeys.requiredLevel] = 80,
        },
        [8201] = { -- A Collection of Heads
            [questKeys.questLevel] = 80,
            [questKeys.requiredLevel] = 80,
        },
        [8227] = { -- Nat's Measuring Tape
            [questKeys.questLevel] = 80,
            [questKeys.requiredLevel] = 80,
        },
        [8238] = { -- Gurubashi, Vilebranch, and Witherbark Coins
            [questKeys.questLevel] = 80,
            [questKeys.requiredLevel] = 80,
        },
        [8239] = { -- Sandfury, Skullsplitter, and Bloodscalp Coins
            [questKeys.questLevel] = 80,
            [questKeys.requiredLevel] = 80,
        },
        [8240] = { -- A Bijou for Zanza
            [questKeys.questLevel] = 80,
            [questKeys.requiredLevel] = 80,
        },
        [8243] = { -- Zanza's Potent Potables
            [questKeys.questLevel] = 80,
            [questKeys.requiredLevel] = 80,
        },
        [8246] = { -- Signets of the Zandalar
            [questKeys.questLevel] = 80,
            [questKeys.requiredLevel] = 80,
        },
        [9250] = { -- Frame of Atiesh
            [questKeys.questLevel] = 80,
            [questKeys.requiredLevel] = 80,
            [questKeys.requiredClasses] = classIDs.SHAMAN + classIDs.MAGE + classIDs.WARLOCK + classIDs.PRIEST + classIDs.DRUID,
        },
        [9251] = { -- Atiesh, the Befouled Greatstaff
            [questKeys.questLevel] = 80,
            [questKeys.requiredLevel] = 80,
            [questKeys.requiredClasses] = classIDs.SHAMAN + classIDs.MAGE + classIDs.WARLOCK + classIDs.PRIEST + classIDs.DRUID,
        },
        [9269] = { -- Atiesh, Greatstaff of the Guardian
            [questKeys.questLevel] = 80,
            [questKeys.requiredLevel] = 80,
            [questKeys.requiredClasses] = classIDs.SHAMAN + classIDs.MAGE + classIDs.WARLOCK + classIDs.PRIEST + classIDs.DRUID,
        },
        [11007] = { -- Kael'thas and the Verdant Sphere
            [questKeys.questLevel] = 80,
            [questKeys.requiredLevel] = 80,
        },
        [11132] = { -- Promises, Promises...
            [questKeys.questLevel] = 80,
            [questKeys.requiredLevel] = 80,
        },
        [11163] = { -- Undercover Sister
            [questKeys.questLevel] = 80,
            [questKeys.requiredLevel] = 80,
        },
        [11164] = { -- Tuskin' Raiders
            [questKeys.questLevel] = 80,
            [questKeys.requiredLevel] = 80,
        },
        [11165] = { -- A Troll Among Trolls
            [questKeys.questLevel] = 80,
            [questKeys.requiredLevel] = 80,
        },
        [11166] = { -- X Marks... Your Doom!
            [questKeys.questLevel] = 80,
            [questKeys.requiredLevel] = 80,
        },
        [11171] = { -- Hex Lord? Hah!
            [questKeys.questLevel] = 80,
            [questKeys.requiredLevel] = 80,
        },
        [11178] = { -- Blood of the Warlord
            [questKeys.questLevel] = 80,
            [questKeys.requiredLevel] = 80,
        },
        [13432] = { -- The Vials of Eternity
            [questKeys.questLevel] = 80,
            [questKeys.requiredLevel] = 80,
        },
    }
end
