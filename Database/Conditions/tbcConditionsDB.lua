--[[
Quest Condition Expressions

Each entry maps a quest ID to a Lua expression string that can be
evaluated with loadstring to determine quest availability.

Usage:
  local expr = conditionDB[questId]
  if expr then
    local fn = loadstring('return ' .. expr)
    setfenv(fn, QuestieConditionEnv)
    local available = fn()
  end

Condition functions:
  HasAura(spellId)              - player has aura/buff/debuff
  HasItem(itemId[, count])       - player has item in inventory
  HasItemOrBank(itemId[, cnt])   - player has item (incl. bank)
  HasItemEquipped(itemId)        - player has item equipped
  QuestRewarded(questId)         - quest has been turned in
  QuestInLog(questId)            - quest is in quest log
  QuestComplete(questId)         - quest objectives are complete
  QuestNone(questId)             - quest not taken and not rewarded
  QuestAvailable(questId)        - quest is available to accept
  HasSkill(skillId, level)       - player has profession at level
  KnowsSpell(spellId)           - player has learned spell
  HasRep(factionId, rank)        - reputation >= rank (0-7)
  RepBelow(factionId, rank)      - reputation <= rank (0-7)
  IsTeam(teamId)                - 469=Alliance, 67=Horde
  IsRace(raceMask)              - race bitmask check
  IsClass(classMask)            - class bitmask check
  IsRaceClass(raceMask, clsMask) - race+class bitmask check
  IsLevel(level)                - player level >= level
  IsLevelExact(level)            - player level == level
  IsLevelBelow(level)            - player level <= level
  EventActive(eventId)          - game event is active
  HolidayActive(holidayId)      - holiday is active
  HasAchievement(achieveId)     - player has achievement
  WorldState(stateId, value)    - server worldstate check
]]
-- Auto-generated quest condition expressions

---@type table<number, string>
local conditionDB = {
  -- Kurzen's Mystery
  [207] = "QuestRewarded(203) and QuestRewarded(204)",
  -- Distracting Jarven
  [308] = "QuestInLog(310)",
  -- Jaina's Autograph
  [558] = "QuestRewarded(1687) and QuestRewarded(1558) and QuestRewarded(1479)",
  -- You Scream, I Scream...
  [915] = "QuestRewarded(911) and QuestRewarded(910) and QuestRewarded(1800)",
  -- Cairne's Hoofprint
  [925] = "QuestRewarded(911) and QuestRewarded(910) and QuestRewarded(1800)",
  -- The Glowing Fruit
  [930] = "QuestRewarded(919) and QuestRewarded(918)",
  -- Onu is meditating
  [960] = "not QuestRewarded(949)",
  -- Onu is meditating
  [961] = "not QuestRewarded(950)",
  -- Zamek's Distraction
  [1191] = "(QuestAvailable(1194) or QuestInLog(1190))",
  -- Unfinished Gordok Business
  [1318] = "HasAura(22799)",
  -- The Tome of Divinity
  [1641] = "not HasItemOrBank(6775) and QuestNone(1642)",
  -- The Tome of Divinity
  [1645] = "not HasItemOrBank(6916) and QuestNone(1646)",
  -- The Symbol of Life
  [1789] = "(QuestInLog(1783) or QuestInLog(1784))",
  -- The Symbol of Life
  [1790] = "(QuestInLog(1786) or QuestInLog(1787))",
  -- Galvan's Finest Pupil
  [2764] = "QuestRewarded(2763) and QuestRewarded(2762) and QuestRewarded(2761)",
  -- Natural Materials
  [3128] = "QuestRewarded(3122)",
  -- Did You Lose This?
  [3321] = "QuestRewarded(2773) and QuestRewarded(2772) and QuestRewarded(2771)",
  -- Replacement Phial
  [3375] = "not QuestRewarded(2204) and (QuestInLog(2200) or QuestRewarded(2200)) and not HasItemOrBank(7667)",
  -- An Easy Pickup
  [3450] = "(QuestInLog(3449) or QuestRewarded(3449))",
  -- Signal for Pickup
  [3483] = "not QuestRewarded(3461)",
  -- March of the Silithid
  [4493] = "(QuestRewarded(162) or QuestRewarded(4267))",
  -- March of the Silithid
  [4494] = "(QuestRewarded(32) or QuestRewarded(7732))",
  -- Bungle in the Jungle
  [4496] = "(QuestRewarded(4493) or QuestRewarded(4494))",
  -- You Scream, I Scream...
  [4822] = "QuestRewarded(1687) and QuestRewarded(1558) and QuestRewarded(1479)",
  -- The Completed Orb of Dar'Orahil
  [4964] = "QuestRewarded(4963) and QuestRewarded(4976)",
  -- The Completed Orb of Noh'Orahil
  [4975] = "QuestRewarded(4962) and QuestRewarded(4976)",
  -- Minion's Scourgestones
  [5402] = "(QuestRewarded(5401) or QuestRewarded(5405) or QuestRewarded(5503))",
  -- Invader's Scourgestones
  [5403] = "(QuestRewarded(5401) or QuestRewarded(5405) or QuestRewarded(5503))",
  -- Corruptor's Scourgestones
  [5404] = "(QuestRewarded(5401) or QuestRewarded(5405) or QuestRewarded(5503))",
  -- Corruptor's Scourgestones
  [5406] = "(QuestRewarded(5401) or QuestRewarded(5405) or QuestRewarded(5503))",
  -- Invader's Scourgestones
  [5407] = "(QuestRewarded(5401) or QuestRewarded(5405) or QuestRewarded(5503))",
  -- Minion's Scourgestones
  [5408] = "(QuestRewarded(5401) or QuestRewarded(5405) or QuestRewarded(5503))",
  -- Corruptor's Scourgestones
  [5508] = "(QuestRewarded(5401) or QuestRewarded(5405) or QuestRewarded(5503))",
  -- Invader's Scourgestones
  [5509] = "(QuestRewarded(5401) or QuestRewarded(5405) or QuestRewarded(5503))",
  -- Minion's Scourgestones
  [5510] = "(QuestRewarded(5401) or QuestRewarded(5405) or QuestRewarded(5503))",
  -- Duskwing, Oh How I Hate Thee...
  [6135] = "QuestRewarded(6042) and QuestRewarded(6022) and QuestRewarded(6133)",
  -- The Corpulent One
  [6136] = "QuestRewarded(6042) and QuestRewarded(6022) and QuestRewarded(6133)",
  -- The Call to Command
  [6144] = "QuestRewarded(6136) and QuestRewarded(6135)",
  -- Ramstein
  [6163] = "QuestRewarded(6136) and QuestRewarded(6135)",
  -- Libram of Rapidity
  [7483] = "(QuestRewarded(7482) or QuestRewarded(7481))",
  -- Libram of Focus
  [7484] = "(QuestRewarded(7482) or QuestRewarded(7481))",
  -- Libram of Protection
  [7485] = "(QuestRewarded(7482) or QuestRewarded(7481))",
  -- Unfinished Gordok Business
  [7703] = "HasAura(22799)",
  -- The Good News and The Bad News
  [8728] = "QuestRewarded(8620) and QuestRewarded(8587) and QuestRewarded(8578)",
  -- The Might of Kalimdor
  [8742] = "QuestRewarded(8729) and QuestRewarded(8741) and QuestRewarded(8730)",
  -- The Changing of Paths - Protector No More
  [8764] = "(QuestRewarded(8761) or (QuestRewarded(8751) or QuestRewarded(8756)))",
  -- The Changing of Paths - Invoker No More
  [8765] = "(QuestRewarded(8761) or (QuestRewarded(8751) or QuestRewarded(8756)))",
  -- The Changing of Paths - Conqueror No More
  [8766] = "(QuestRewarded(8761) or (QuestRewarded(8751) or QuestRewarded(8756)))",
  -- Help Ranger Valanna!
  [9145] = "QuestNone(9143)",
  -- The Sanctum of the Sun
  [9151] = "QuestNone(9220)",
  -- Tomber's Supplies
  [9152] = "(QuestRewarded(9329) or QuestRewarded(9327))",
  -- Culinary Crunch
  [9171] = "(QuestRewarded(9329) or QuestRewarded(9327))",
  -- Ruthless Cunning
  [9927] = "(QuestRewarded(10107) or QuestRewarded(10108))",
  -- Armaments for Deception
  [9928] = "(QuestRewarded(10107) or QuestRewarded(10108))",
  -- Returning the Favor
  [9931] = "QuestRewarded(9927) and QuestRewarded(9928)",
  -- Body of Evidence
  [9932] = "QuestRewarded(9927) and QuestRewarded(9928)",
  -- Message to Telaar
  [9933] = "QuestRewarded(9931) and QuestRewarded(9932)",
  -- Message to Garadar
  [9934] = "QuestRewarded(9931) and QuestRewarded(9932)",
  -- What's Wrong at Cenarion Thicket?
  [9957] = "QuestNone(9968)",
  -- What's Wrong at Cenarion Thicket?
  [9960] = "QuestNone(9968)",
  -- What's Wrong at Cenarion Thicket?
  [9961] = "QuestNone(9968)",
  -- Divination: Gorefiend's Armor
  [10634] = "(QuestRewarded(10633) or QuestRewarded(10644))",
  -- Divination: Gorefiend's Cloak
  [10635] = "(QuestRewarded(10633) or QuestRewarded(10644))",
  -- Divination: Gorefiend's Truncheon
  [10636] = "(QuestRewarded(10633) or QuestRewarded(10644))",
  -- Teron Gorefiend, I am...
  [10639] = "QuestRewarded(10635) and QuestRewarded(10634) and QuestRewarded(10636)",
  -- Against the Legion
  [10641] = "(QuestRewarded(10689) or QuestRewarded(10640))",
  -- Teron Gorefiend, I am...
  [10645] = "QuestRewarded(10635) and QuestRewarded(10634) and QuestRewarded(10636)",
  -- Against the Illidari
  [10668] = "(QuestRewarded(10689) or QuestRewarded(10640))",
  -- Against All Odds
  [10669] = "(QuestRewarded(10689) or QuestRewarded(10640))",
  -- Surrender to the Horde
  [10862] = "not QuestInLog(10863) and not QuestInLog(10908) and QuestNone(10847)",
  -- Secrets of the Arakkoa
  [10863] = "not QuestInLog(10862) and not QuestInLog(10908) and QuestNone(10847)",
  -- Speak with Rilak the Redeemed
  [10908] = "not QuestInLog(10862) and not QuestInLog(10863) and QuestNone(10847)",
  -- The Seat of the Naaru
  [10956] = "QuestRewarded(10950) and QuestRewarded(10954) and QuestRewarded(10952)",
  -- Time to Visit the Caverns
  [10962] = "QuestRewarded(10950) and QuestRewarded(10954) and QuestRewarded(10952)",
  -- Time to Visit the Caverns
  [10963] = "QuestRewarded(10945) and QuestRewarded(10953) and QuestRewarded(10951)",
  -- Speak with the Ogre
  [10984] = "QuestNone(10989) and QuestNone(10983) and QuestNone(11057)",
  -- Mog'dorg the Wizened
  [10989] = "not QuestInLog(10984)",
  -- Grulloc Has Two Skulls
  [10995] = "(QuestRewarded(10989) or (QuestRewarded(10983) or QuestRewarded(11057)))",
  -- Maggoc's Treasure Chest
  [10996] = "(QuestRewarded(10989) or (QuestRewarded(10983) or QuestRewarded(11057)))",
  -- Even Gronn Have Standards
  [10997] = "(QuestRewarded(10989) or (QuestRewarded(10983) or QuestRewarded(11057)))",
  -- Speak with Mog'dorg
  [11022] = "QuestNone(11009)",
  -- Bomb Them Again!
  [11023] = "(QuestRewarded(11010) or QuestRewarded(11102))",
  -- Archmage No More
  [11031] = "HasItem(29287)",
  -- Protector No More
  [11032] = "HasItem(29279)",
  -- Assassin No More
  [11033] = "HasItem(29283)",
  -- Restorer No More
  [11034] = "HasItem(29290)",
  -- The Trouble Below
  [11057] = "not QuestInLog(10984)",
  -- Wrangle Some Aether Rays!
  [11065] = "(QuestRewarded(11010) or QuestRewarded(11102))",
  -- Assault on Bash'ir Landing!
  [11119] = "(QuestRewarded(11010) or QuestRewarded(11102))",
  -- Agamath, the First Gate
  [11551] = "EventActive(316)",
  -- Rohendor, the Second Gate
  [11552] = "EventActive(317)",
  -- Archonisus, the Final Gate
  [11553] = "EventActive(318)",
  -- Gaining the Advantage
  [11875] = "((KnowsSpell(29354) or KnowsSpell(28695)) or KnowsSpell(32678))",
  -- Striking Back
  [11917] = "IsLevelBelow(28) and IsLevel(22)",
  -- Striking Back
  [11947] = "IsLevelBelow(38) and IsLevel(29)",
  -- Striking Back
  [11948] = "IsLevelBelow(48) and IsLevel(39)",
  -- Striking Back
  [11952] = "IsLevelBelow(55) and IsLevel(49)",
  -- Striking Back
  [11953] = "IsLevelBelow(63) and IsLevel(56)",
  -- Striking Back
  [11954] = "IsLevel(64)",
  -- The Spinner of Summer Tales
  [11971] = "EventActive(1)",
  -- Now, When I Grow Up...
  [11975] = "QuestRewarded(10945) and QuestRewarded(10953) and QuestRewarded(10951)",
}

function GetQuestConditions()
  return conditionDB
end
