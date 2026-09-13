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
  -- Teron Gorefiend, I am...
  [10639] = "QuestRewarded(10635) and QuestRewarded(10634) and QuestRewarded(10636)",
  -- Against the Legion
  [10641] = "(QuestRewarded(10689) or QuestRewarded(10640))",
  -- Teron Gorefiend, I am...
  [10645] = "QuestRewarded(10635) and QuestRewarded(10634) and QuestRewarded(10636)",
  -- Underworld Loam
  [10667] = "QuestRewarded(10666) and QuestRewarded(10665)",
  -- Against the Illidari
  [10668] = "(QuestRewarded(10689) or QuestRewarded(10640))",
  -- Against All Odds
  [10669] = "(QuestRewarded(10689) or QuestRewarded(10640))",
  -- Tear of the Earthmother
  [10670] = "QuestRewarded(10666) and QuestRewarded(10665)",
  -- Bane of the Illidari
  [10676] = "QuestRewarded(10670) and QuestRewarded(10667)",
  -- Surrender to the Horde
  [10862] = "not QuestInLog(10863) and not QuestInLog(10908) and QuestNone(10847)",
  -- Secrets of the Arakkoa
  [10863] = "not QuestInLog(10862) and not QuestInLog(10908) and QuestNone(10847)",
  -- The Mark of Vashj
  [10900] = "QuestRewarded(10885) and QuestRewarded(10884) and QuestRewarded(10886)",
  -- Speak with Rilak the Redeemed
  [10908] = "not QuestInLog(10862) and not QuestInLog(10863) and QuestNone(10847)",
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
  -- The Enigmatic Frost Nymphs
  [11302] = "((QuestRewarded(11269) or QuestRewarded(11329)) or (QuestRewarded(11284) or QuestRewarded(11292)))",
  -- Spawn of the Twisted Glade
  [11316] = "QuestRewarded(11315) and QuestRewarded(11314)",
  -- Seeds of the Blacksouled Keepers
  [11319] = "QuestRewarded(11315) and QuestRewarded(11314)",
  -- The Book of Runes
  [11346] = "((QuestRewarded(11269) or QuestRewarded(11329)) or (QuestRewarded(11284) or QuestRewarded(11292)))",
  -- March of the Giants
  [11355] = "((QuestRewarded(11269) or QuestRewarded(11329)) or (QuestRewarded(11284) or QuestRewarded(11292)))",
  -- Keeper Witherleaf
  [11428] = "QuestRewarded(11319) and QuestRewarded(11316)",
  -- Outpost Over Yonder...
  [11478] = "QuestInLog(11485)",
  -- Agamath, the First Gate
  [11551] = "EventActive(316)",
  -- Rohendor, the Second Gate
  [11552] = "EventActive(317)",
  -- Archonisus, the Final Gate
  [11553] = "EventActive(318)",
  -- Hellscream's Vigil
  [11585] = "QuestNone(10212)",
  -- Hellscream's Vigil
  [11586] = "QuestRewarded(10212)",
  -- The Defense of Warsong Hold
  [11595] = "QuestRewarded(7783) and (QuestRewarded(11586) or QuestRewarded(11585))",
  -- The Defense of Warsong Hold
  [11596] = "not HasAchievement(416) and QuestNone(7783) and (QuestRewarded(11586) or QuestRewarded(11585))",
  -- The Defense of Warsong Hold
  [11597] = "HasAchievement(416) and QuestNone(7783) and (QuestRewarded(11586) or QuestRewarded(11585))",
  -- Patience is a Virtue that We Don't Need
  [11606] = "((QuestRewarded(11597) or QuestRewarded(11596)) or QuestRewarded(11595))",
  -- Taken by the Scourge
  [11611] = "((QuestRewarded(11597) or QuestRewarded(11596)) or QuestRewarded(11595))",
  -- Seek Out Karuk!
  [11662] = "QuestRewarded(11661) and QuestRewarded(11656)",
  -- Gaining the Advantage
  [11875] = "((KnowsSpell(29354) or KnowsSpell(28695)) or KnowsSpell(32678))",
  -- Hellscream's Champion
  [11916] = "QuestRewarded(11705) and QuestRewarded(11652) and QuestRewarded(11722)",
  -- Striking Back
  [11917] = "HasAura(25688)",
  -- Striking Back
  [11947] = "QuestInLog(11296) and not QuestComplete(11296)",
  -- Striking Back
  [11948] = "IsLevelBelow(48) and not (QuestInLog(11296) and not QuestComplete(11296))",
  -- Striking Back
  [11952] = "IsLevelBelow(55) and IsLevel(49)",
  -- Striking Back
  [11953] = "IsLevelBelow(63) and IsLevel(56)",
  -- Striking Back
  [11954] = "IsLevel(64)",
  -- The Spinner of Summer Tales
  [11971] = "EventActive(1)",
  -- Your Presence is Required at Agmar's Hammer
  [11996] = "QuestNone(12008)",
  -- Rifle the Bodies
  [11999] = "(QuestRewarded(11996) or QuestRewarded(12034))",
  -- Message from the West
  [12033] = "QuestRewarded(11916)",
  -- Victory Nears...
  [12034] = "QuestRewarded(12008)",
  -- Black Blood of Yogg-Saron
  [12039] = "QuestRewarded(12034)",
  -- Lumber Hack
  [12050] = "QuestRewarded(12047) and QuestRewarded(12046)",
  -- Harp on This!
  [12052] = "QuestRewarded(12047) and QuestRewarded(12046)",
  -- Marked for Death: High Cultist Zangus
  [12056] = "QuestRewarded(12034)",
  -- Strength of Icemist
  [12063] = "QuestRewarded(12036)",
  -- Worm Wrangler
  [12078] = "QuestRewarded(12077)",
  -- Stomping Grounds
  [12079] = "QuestRewarded(12075)",
  -- Really Big Worm
  [12080] = "QuestRewarded(12077)",
  -- Strengthen the Ancients
  [12092] = "QuestRewarded(12065)",
  -- To Dragon's Fall
  [12095] = "QuestRewarded(12091) and QuestRewarded(12090) and QuestRewarded(12089)",
  -- Strengthen the Ancients
  [12096] = "QuestRewarded(12066)",
  -- Containing the Rot
  [12100] = "QuestRewarded(12034)",
  -- Stiff Negotiations
  [12112] = "QuestRewarded(12052) and QuestRewarded(12050)",
  -- Travel to Moa'ki Harbor
  [12117] = "(not QuestInLog(12118) or not QuestRewarded(12118))",
  -- Travel to Moa'ki Harbor
  [12118] = "(not QuestInLog(12117) or not QuestRewarded(12117))",
  -- The Power to Destroy
  [12132] = "QuestRewarded(12127) and QuestRewarded(12126) and QuestRewarded(12125)",
  -- Of Traitors and Treason
  [12171] = "(not QuestInLog(12297) or not QuestRewarded(12297)) and QuestRewarded(12157)",
  -- To Venomspite!
  [12182] = "QuestNone(12182)",
  -- Imbeciles Abound!
  [12189] = "QuestNone(12182)",
  -- Vordrassil's Fall
  [12207] = "QuestRewarded(12413)",
  -- Good Troll Hunting
  [12208] = "QuestRewarded(12412)",
  -- Troll Season!
  [12210] = "QuestRewarded(12212)",
  -- The Darkness Beneath
  [12213] = "QuestRewarded(12413)",
  -- The Kor'kron Vanguard!
  [12224] = "QuestRewarded(12072) and QuestRewarded(12140) and QuestRewarded(12221)",
  -- A Possible Link
  [12229] = "QuestRewarded(12207) and QuestRewarded(12213)",
  -- The Bear God's Offspring
  [12231] = "QuestRewarded(12207) and QuestRewarded(12213)",
  -- Naxxramas and the Fall of Wintergarde
  [12235] = "(QuestRewarded(12298) or QuestRewarded(12174))",
  -- Ursoc, the Bear God
  [12236] = "QuestRewarded(12242) and QuestRewarded(12241)",
  -- Destroy the Sapling
  [12241] = "QuestRewarded(12231) and QuestRewarded(12229)",
  -- Vordrassil's Seeds
  [12242] = "QuestRewarded(12231) and QuestRewarded(12229)",
  -- The Flamebinders' Secrets
  [12256] = "QuestRewarded(12468)",
  -- The Fate of the Dead
  [12258] = "QuestRewarded(12251)",
  -- The Thane of Voldrune
  [12259] = "QuestRewarded(12257) and QuestRewarded(12256)",
  -- No Place to Run
  [12261] = "QuestRewarded(12447)",
  -- No One to Save You
  [12262] = "QuestRewarded(12447)",
  -- The Best of Intentions
  [12263] = "QuestRewarded(12262) and QuestRewarded(12261)",
  -- Culling the Damned
  [12264] = "QuestRewarded(12263)",
  -- Defiling the Defilers
  [12265] = "QuestRewarded(12263)",
  -- The Bleeding Ore
  [12272] = "QuestRewarded(12275)",
  -- Of Traitors and Treason
  [12297] = "(not QuestRewarded(12171) or (not QuestInLog(12297) or not QuestRewarded(12297)) and QuestRewarded(12157))",
  -- My Enemy's Friend
  [12412] = "QuestRewarded(12259)",
  -- The Conquest Pit: Bear Wrestling!
  [12427] = "QuestRewarded(12178) and QuestRewarded(12422) and QuestRewarded(12413)",
  -- Eyes Above
  [12453] = "QuestRewarded(12412)",
  -- Breaking Off A Piece
  [12462] = "QuestRewarded(12326)",
  -- Return to Sender
  [12469] = "QuestNone(12044)",
  -- The High Executor Needs You
  [12488] = "QuestNone(12487)",
  -- Return To Angrathar
  [12499] = "QuestRewarded(12498)",
  -- Return To Angrathar
  [12500] = "QuestRewarded(12498)",
  -- Troll Patrol: High Standards
  [12502] = "(QuestInLog(12563) or QuestInLog(12501) or QuestInLog(12587))",
  -- Troll Patrol: Intestinal Fortitude
  [12509] = "(QuestInLog(12563) or QuestInLog(12501) or QuestInLog(12587))",
  -- Troll Patrol: Whatdya Want, a Medal?
  [12519] = "(QuestInLog(12563) or QuestInLog(12501) or QuestInLog(12587))",
  -- The Wasp Hunter's Apprentice
  [12533] = "QuestRewarded(12529) and QuestRewarded(12530)",
  -- The Sapphire Queen
  [12534] = "QuestRewarded(12529) and QuestRewarded(12530)",
  -- A Rough Ride
  [12536] = "QuestRewarded(12535) and QuestRewarded(12531)",
  -- Hoofing It
  [12539] = "QuestRewarded(12538) and QuestRewarded(12537)",
  -- Troll Patrol: The Alchemist's Apprentice
  [12541] = "(QuestInLog(12563) or QuestInLog(12501) or QuestInLog(12587))",
  -- Dreadsaber Mastery: Becoming a Predator
  [12549] = "QuestRewarded(12525) and QuestRewarded(12523)",
  -- An Issue of Trust
  [12561] = "KnowsSpell(54197)",
  -- Troll Patrol: Something for the Pain
  [12564] = "(QuestInLog(12563) or QuestInLog(12501) or QuestInLog(12587))",
  -- Troll Patrol: Done to Death
  [12568] = "(QuestInLog(12563) or QuestInLog(12501) or QuestInLog(12587))",
  -- Back So Soon?
  [12574] = "QuestRewarded(12573) and QuestRewarded(12572)",
  -- Home Time!
  [12577] = "QuestRewarded(12576) and QuestRewarded(12575)",
  -- A Hero's Burden
  [12581] = "QuestRewarded(12580) and QuestRewarded(12579)",
  -- Troll Patrol: Creature Comforts
  [12585] = "(QuestInLog(12563) or QuestInLog(12501) or QuestInLog(12587))",
  -- Troll Patrol: Can You Dig It?
  [12588] = "(QuestInLog(12563) or QuestInLog(12501) or QuestInLog(12587))",
  -- Kick, What Kick?
  [12589] = "QuestRewarded(12525) and QuestRewarded(12523)",
  -- Troll Patrol: Throwing Down
  [12591] = "(QuestInLog(12563) or QuestInLog(12501) or QuestInLog(12587))",
  -- Troll Patrol: Couldn't Care Less
  [12594] = "(QuestInLog(12563) or QuestInLog(12501) or QuestInLog(12587))",
  -- In Search of Bigger Game
  [12595] = "QuestRewarded(12556) and QuestRewarded(12569) and QuestRewarded(12558)",
  -- Sharpening Your Talons
  [12603] = "QuestRewarded(12556) and QuestRewarded(12569) and QuestRewarded(12558)",
  -- Congratulations!
  [12604] = "HasAura(51573) and (QuestRewarded(12563) or QuestRewarded(12501) or QuestRewarded(12587))",
  -- Securing the Bait
  [12605] = "QuestRewarded(12556) and QuestRewarded(12569) and QuestRewarded(12558)",
  -- A Mammoth Undertaking
  [12607] = "QuestRewarded(12605) and QuestRewarded(12603)",
  -- Some Make Lemonade, Some Make Liquor
  [12634] = "QuestRewarded(12549) and QuestRewarded(12520)",
  -- My Pet Roc
  [12658] = "QuestRewarded(12605) and QuestRewarded(12603)",
  -- Reunited
  [12663] = "QuestRewarded(12238)",
  -- Dark Horizon
  [12664] = "QuestNone(12238)",
  -- Reagent Agent
  [12681] = "QuestRewarded(12605) and QuestRewarded(12603)",
  -- Burning to Help
  [12683] = "QuestRewarded(12556) and QuestRewarded(12569) and QuestRewarded(12558)",
  -- Return of the Lich Hunter
  [12692] = "HasRep(1104, 5)",
  -- Return of the Friendly Dryskin
  [12695] = "HasRep(1105, 5)",
  -- Behind Scarlet Lines
  [12723] = "QuestRewarded(12717) and QuestRewarded(12719) and QuestRewarded(12722)",
  -- The Magical Kingdom of Dalaran
  [12791] = "QuestNone(12796)",
  -- The Magical Kingdom of Dalaran
  [12794] = "QuestNone(12796)",
  -- Taking a Stand
  [12795] = "(not QuestInLog(12503) or not QuestRewarded(12503))",
  -- The Magical Kingdom of Dalaran
  [12796] = "(QuestNone(12794) or QuestNone(12791))",
  -- Force of Nature
  [12803] = "KnowsSpell(54197)",
  -- A Steak Fit for a Hunter
  [12804] = "QuestRewarded(12520)",
  -- From Their Corpses, Rise!
  [12813] = "QuestRewarded(12807)",
  -- No Fly Zone
  [12815] = "QuestRewarded(12814)",
  -- Intelligence Gathering
  [12838] = "QuestRewarded(12807)",
  -- The Amphitheater of Anguish: Yggdras!
  [12932] = "not QuestRewarded(9977)",
  -- The Amphitheater of Anguish: Magnataur!
  [12933] = "(QuestRewarded(12954) or QuestRewarded(12932))",
  -- The Amphitheater of Anguish: Yggdras!
  [12954] = "QuestRewarded(9977)",
  -- The Champion's Call!
  [12974] = "not QuestRewarded(12954) and not QuestInLog(12954) and not QuestRewarded(12932) and not QuestInLog(12932)",
  -- If There Are Survivors...
  [13044] = "QuestRewarded(13040) and QuestRewarded(13039) and QuestRewarded(13008)",
  -- Reading the Bones
  [13093] = "QuestRewarded(13092)",
  -- Blackwatch
  [13106] = "(not QuestInLog(13117) or not QuestRewarded(13117))",
  -- The Restless Dead
  [13110] = "(QuestRewarded(13105) or QuestRewarded(13104))",
  -- The Purging Of Scourgeholme
  [13118] = "(QuestRewarded(13105) or QuestRewarded(13104))",
  -- The Scourgestone
  [13122] = "(QuestRewarded(13105) or QuestRewarded(13104))",
  -- The Air Stands Still
  [13125] = "QuestRewarded(13118) and QuestRewarded(13122)",
  -- The Stone That Started A Revolution
  [13130] = "(QuestRewarded(13105) or QuestRewarded(13104))",
  -- It Could Kill Us All
  [13135] = "(QuestRewarded(13105) or QuestRewarded(13104))",
  -- Into The Frozen Heart Of Northrend
  [13139] = "QuestRewarded(13135) and QuestRewarded(13110) and QuestRewarded(13130) and QuestRewarded(13125)",
  -- Killing Two Scourge With One Skeleton
  [13144] = "QuestRewarded(13152) and QuestRewarded(13211)",
  -- A Visit to the Doctor
  [13152] = "QuestRewarded(13138) and QuestRewarded(13140) and QuestRewarded(13134)",
  -- Vereth the Cunning
  [13155] = "QuestRewarded(13174) and QuestRewarded(13172)",
  -- The Rider of the Unholy
  [13161] = "QuestRewarded(13160) and QuestRewarded(13147) and QuestRewarded(13146)",
  -- The Rider of Frost
  [13162] = "QuestRewarded(13160) and QuestRewarded(13147) and QuestRewarded(13146)",
  -- The Rider of Blood
  [13163] = "QuestRewarded(13160) and QuestRewarded(13147) and QuestRewarded(13146)",
  -- The Fate of Bloodbane
  [13164] = "QuestRewarded(13163) and QuestRewarded(13162) and QuestRewarded(13161)",
  -- Seeds of Chaos
  [13172] = "QuestRewarded(13171) and QuestRewarded(13170) and QuestRewarded(13169)",
  -- Amidst the Confusion
  [13174] = "QuestRewarded(13171) and QuestRewarded(13170) and QuestRewarded(13169)",
  -- By Fire Be Purged
  [13211] = "QuestRewarded(13138) and QuestRewarded(13140) and QuestRewarded(13134)",
  -- The Broken Front
  [13228] = "QuestRewarded(13224)",
  -- Avenge Me!
  [13230] = "(QuestInLog(13228) or QuestRewarded(13228))",
  -- The Broken Front
  [13231] = "QuestRewarded(13225)",
  -- Finish Me!
  [13232] = "(QuestInLog(13231) or QuestRewarded(13231))",
  -- No Mercy!
  [13233] = "QuestRewarded(13231)",
  -- Make Them Pay!
  [13234] = "QuestRewarded(13228)",
  -- Good For Something?
  [13238] = "QuestRewarded(13228)",
  -- Opportunity
  [13258] = "QuestRewarded(12899) and QuestRewarded(13224)",
  -- Takes One to Know One
  [13260] = "QuestRewarded(13228)",
  -- Volatility
  [13261] = "QuestRewarded(13239)",
  -- That's Abominable!
  [13264] = "QuestRewarded(13237)",
  -- That's Abominable!
  [13276] = "QuestRewarded(13264)",
  -- Against the Giants
  [13277] = "QuestRewarded(13237)",
  -- Coprous the Defiled
  [13278] = "QuestRewarded(13277)",
  -- Neutralizing the Plague
  [13281] = "QuestRewarded(13279)",
  -- Assault by Ground
  [13284] = "QuestRewarded(13341)",
  -- ...All the Help We Can Get.
  [13286] = "QuestRewarded(13231)",
  -- That's Abominable!
  [13288] = "QuestRewarded(13287)",
  -- That's Abominable!
  [13289] = "QuestRewarded(13288)",
  -- Your Attention, Please
  [13290] = "QuestRewarded(13231)",
  -- The Solution Solution
  [13292] = "QuestRewarded(13291)",
  -- Get to Ymirheim!
  [13293] = "QuestRewarded(13224)",
  -- Against the Giants
  [13294] = "QuestRewarded(13287)",
  -- Get to Ymirheim!
  [13296] = "QuestRewarded(13225)",
  -- Neutralizing the Plague
  [13297] = "QuestRewarded(13295)",
  -- Coprous the Defiled
  [13298] = "QuestRewarded(13294)",
  -- Slaves to Saronite
  [13300] = "QuestRewarded(13225)",
  -- Assault by Ground
  [13301] = "QuestRewarded(13340)",
  -- Slaves to Saronite
  [13302] = "QuestRewarded(13224)",
  -- Raise the Barricades
  [13306] = "QuestRewarded(13366)",
  -- Bloodspattered Banners
  [13307] = "QuestRewarded(13306)",
  -- Mind Tricks
  [13308] = "(QuestRewarded(13225) or QuestRewarded(13224))",
  -- Assault by Air
  [13309] = "QuestRewarded(13341)",
  -- Assault by Air
  [13310] = "QuestRewarded(13340)",
  -- The Ironwall Rampart
  [13312] = "QuestRewarded(13367) and QuestRewarded(13306)",
  -- Blinding the Eyes in the Sky
  [13313] = "QuestRewarded(13306)",
  -- Get the Message
  [13314] = "QuestRewarded(13332)",
  -- Sneak Preview
  [13315] = "QuestRewarded(13288)",
  -- The Guardians of Corp'rethar
  [13316] = "QuestRewarded(13329)",
  -- Drag and Drop
  [13318] = "QuestRewarded(13315)",
  -- Chain of Command
  [13319] = "QuestRewarded(13315)",
  -- Cannot Reproduce
  [13320] = "QuestRewarded(13315)",
  -- Retest Now
  [13322] = "QuestRewarded(13321)",
  -- Drag and Drop
  [13323] = "QuestInLog(13145)",
  -- Shatter the Shards
  [13328] = "QuestRewarded(13329)",
  -- Before the Gate of Horror
  [13329] = "QuestRewarded(13312) and QuestRewarded(13307)",
  -- Blood of the Chosen
  [13330] = "QuestRewarded(13224)",
  -- Keeping the Alliance Blind
  [13331] = "QuestRewarded(13313)",
  -- Raise the Barricades
  [13332] = "QuestRewarded(13345)",
  -- Capture More Dispatches
  [13333] = "QuestRewarded(13314)",
  -- Bloodspattered Banners
  [13334] = "QuestRewarded(13332)",
  -- Before the Gate of Horror
  [13335] = "QuestRewarded(13337) and QuestRewarded(13334)",
  -- Blood of the Chosen
  [13336] = "QuestRewarded(13225)",
  -- The Ironwall Rampart
  [13337] = "QuestRewarded(13346) and QuestRewarded(13332)",
  -- The Guardians of Corp'rethar
  [13338] = "QuestRewarded(13335)",
  -- Shatter the Shards
  [13339] = "QuestRewarded(13335)",
  -- Joining the Assault
  [13340] = "QuestRewarded(13224)",
  -- Joining the Assault
  [13341] = "QuestRewarded(13225)",
  -- Not a Bug
  [13342] = "QuestInLog(13145)",
  -- Not a Bug
  [13344] = "QuestRewarded(13342)",
  -- Need More Info
  [13345] = "QuestInLog(13145)",
  -- No Rest For The Wicked
  [13346] = "QuestRewarded(13345)",
  -- No Rest For The Wicked
  [13350] = "QuestRewarded(13346)",
  -- Sneak Preview
  [13351] = "QuestRewarded(13264)",
  -- Drag and Drop
  [13352] = "QuestRewarded(13351)",
  -- Drag and Drop
  [13353] = "QuestRewarded(13352)",
  -- Chain of Command
  [13354] = "QuestRewarded(13351)",
  -- Cannot Reproduce
  [13355] = "QuestRewarded(13351)",
  -- Retest Now
  [13357] = "QuestRewarded(13356)",
  -- Not a Bug
  [13358] = "QuestRewarded(13352)",
  -- Where Dragons Fell
  [13359] = "QuestRewarded(13348)",
  -- Time for Answers
  [13360] = "QuestRewarded(13359)",
  -- Argent Aid
  [13363] = "QuestRewarded(13362)",
  -- Not a Bug
  [13365] = "QuestRewarded(13358)",
  -- Need More Info
  [13366] = "QuestRewarded(13352)",
  -- No Rest For The Wicked
  [13367] = "QuestRewarded(13366)",
  -- No Rest For The Wicked
  [13368] = "QuestRewarded(13367)",
  -- Total Ohmage: The Valley of Lost Hope!
  [13376] = "QuestRewarded(13373) and not QuestInLog(13406)",
  -- Green Technology
  [13379] = "QuestRewarded(13239)",
  -- Putting the Hertz: The Valley of Lost Hope
  [13382] = "QuestRewarded(13380) and not QuestInLog(13404)",
  -- Killohertz
  [13383] = "QuestRewarded(13291)",
  -- Exploiting an Opening
  [13386] = "QuestRewarded(13225) and QuestRewarded(12898)",
  -- Where Dragons Fell
  [13398] = "QuestRewarded(13396)",
  -- Time for Answers
  [13399] = "QuestRewarded(13398)",
  -- Tirion's Help
  [13402] = "QuestRewarded(13401)",
  -- Static Shock Troops: the Bombardment
  [13404] = "QuestRewarded(13380) and not QuestInLog(13382)",
  -- Riding the Wavelength: The Bombardment
  [13406] = "QuestRewarded(13373) and not QuestInLog(13376)",
  -- Trial of the Naaru: Magtheridon
  [13430] = "QuestRewarded(10885) and QuestRewarded(10884) and QuestRewarded(10886)",
  -- Let's Get Out of Here!
  [13481] = "(not QuestInLog(13229) or not QuestRewarded(13229))",
  -- Let's Get Out of Here
  [13482] = "(not QuestInLog(13221) or not QuestRewarded(13221))",
  -- A Valiant's Field Training
  [13592] = "(not QuestRewarded(13699) and QuestRewarded(13593) and IsRace(1100) or not QuestRewarded(13699) and QuestRewarded(13684) and IsRace(1))",
  -- Valiant Of Stormwind
  [13593] = "not QuestInLog(13706) and not QuestInLog(13705) and not QuestInLog(13704) and not QuestInLog(13703) and not QuestRewarded(13686)",
  -- A Worthy Weapon
  [13600] = "(not QuestRewarded(13699) and QuestRewarded(13593) and IsRace(1100) or not QuestRewarded(13699) and QuestRewarded(13684) and IsRace(1))",
  -- A Blade Fit For A Champion
  [13603] = "(not QuestRewarded(13699) and QuestRewarded(13593) and IsRace(1100) or not QuestRewarded(13699) and QuestRewarded(13684) and IsRace(1))",
  -- The Edge Of Winter
  [13616] = "(not QuestRewarded(13699) and QuestRewarded(13593) and IsRace(1100) or not QuestRewarded(13699) and QuestRewarded(13684) and IsRace(1))",
  -- The Black Knight of Westfall?
  [13633] = "QuestRewarded(13667)",
  -- The Black Knight of Silverpine?
  [13634] = "QuestRewarded(13668)",
  -- The Grand Melee
  [13665] = "(not QuestRewarded(13699) and QuestRewarded(13593) and IsRace(1100) or not QuestRewarded(13699) and QuestRewarded(13684) and IsRace(1))",
  -- The Valiant's Charge
  [13697] = "QuestRewarded(13687) and (QuestRewarded(13707) or QuestRewarded(13691)) and IsTeam(67)",
  -- Valiant Of Ironforge
  [13703] = "not QuestInLog(13706) and not QuestInLog(13705) and not QuestInLog(13704) and not QuestInLog(13593) and not QuestRewarded(13686)",
  -- Valiant Of Gnomeregan
  [13704] = "not QuestInLog(13706) and not QuestInLog(13705) and not QuestInLog(13703) and not QuestInLog(13593) and not QuestRewarded(13686)",
  -- Valiant Of The Exodar
  [13705] = "not QuestInLog(13706) and not QuestInLog(13704) and not QuestInLog(13703) and not QuestInLog(13593) and not QuestRewarded(13686)",
  -- Valiant Of Darnassus
  [13706] = "not QuestInLog(13705) and not QuestInLog(13704) and not QuestInLog(13703) and not QuestInLog(13593) and not QuestRewarded(13686)",
  -- Valiant Of Orgrimmar
  [13707] = "not QuestInLog(13711) and not QuestInLog(13710) and not QuestInLog(13709) and not QuestInLog(13708) and not QuestRewarded(13687)",
  -- Valiant Of Sen'jin
  [13708] = "not QuestInLog(13711) and not QuestInLog(13710) and not QuestInLog(13709) and not QuestInLog(13707) and not QuestRewarded(13687)",
  -- Valiant Of Thunder Bluff
  [13709] = "not QuestInLog(13711) and not QuestInLog(13710) and not QuestInLog(13708) and not QuestInLog(13707) and not QuestRewarded(13687)",
  -- Valiant Of Undercity
  [13710] = "not QuestInLog(13711) and not QuestInLog(13709) and not QuestInLog(13708) and not QuestInLog(13707) and not QuestRewarded(13687)",
  -- Valiant Of Silvermoon
  [13711] = "not QuestInLog(13710) and not QuestInLog(13709) and not QuestInLog(13708) and not QuestInLog(13707) and not QuestRewarded(13687)",
  -- The Valiant's Charge
  [13714] = "QuestRewarded(13686) and (QuestRewarded(13703) or QuestRewarded(13685)) and IsTeam(469)",
  -- The Valiant's Charge
  [13715] = "QuestRewarded(13686) and (QuestRewarded(13704) or QuestRewarded(13688)) and IsTeam(469)",
  -- The Valiant's Charge
  [13716] = "QuestRewarded(13686) and (QuestRewarded(13705) or QuestRewarded(13690)) and IsTeam(469)",
  -- The Valiant's Charge
  [13717] = "QuestRewarded(13686) and (QuestRewarded(13706) or QuestRewarded(13689)) and IsTeam(469)",
  -- The Valiant's Charge
  [13718] = "QuestRewarded(13686) and (QuestRewarded(13593) or QuestRewarded(13684)) and IsTeam(469)",
  -- The Valiant's Charge
  [13719] = "QuestRewarded(13687) and (QuestRewarded(13708) or QuestRewarded(13693)) and IsTeam(67)",
  -- The Valiant's Charge
  [13720] = "QuestRewarded(13687) and (QuestRewarded(13709) or QuestRewarded(13694)) and IsTeam(67)",
  -- The Valiant's Charge
  [13721] = "QuestRewarded(13687) and (QuestRewarded(13710) or QuestRewarded(13695)) and IsTeam(67)",
  -- The Valiant's Charge
  [13722] = "QuestRewarded(13687) and (QuestRewarded(13711) or QuestRewarded(13696)) and IsTeam(67)",
  -- A Blade Fit For A Champion
  [13741] = "(not QuestRewarded(13713) and QuestRewarded(13703) and IsRace(1097) or not QuestRewarded(13713) and QuestRewarded(13685) and IsRace(4))",
  -- A Worthy Weapon
  [13742] = "(not QuestRewarded(13713) and QuestRewarded(13703) and IsRace(1097) or not QuestRewarded(13713) and QuestRewarded(13685) and IsRace(4))",
  -- The Edge Of Winter
  [13743] = "(not QuestRewarded(13713) and QuestRewarded(13703) and IsRace(1097) or not QuestRewarded(13713) and QuestRewarded(13685) and IsRace(4))",
  -- A Valiant's Field Training
  [13744] = "(not QuestRewarded(13713) and QuestRewarded(13703) and IsRace(1097) or not QuestRewarded(13713) and QuestRewarded(13685) and IsRace(4))",
  -- The Grand Melee
  [13745] = "(not QuestRewarded(13713) and QuestRewarded(13703) and IsRace(1097) or not QuestRewarded(13713) and QuestRewarded(13685) and IsRace(4))",
  -- A Blade Fit For A Champion
  [13746] = "(not QuestRewarded(13723) and QuestRewarded(13704) and IsRace(1037) or not QuestRewarded(13723) and QuestRewarded(13688) and IsRace(64))",
  -- A Worthy Weapon
  [13747] = "(not QuestRewarded(13723) and QuestRewarded(13704) and IsRace(1037) or not QuestRewarded(13723) and QuestRewarded(13688) and IsRace(64))",
  -- The Edge Of Winter
  [13748] = "(not QuestRewarded(13723) and QuestRewarded(13704) and IsRace(1037) or not QuestRewarded(13723) and QuestRewarded(13688) and IsRace(64))",
  -- A Valiant's Field Training
  [13749] = "(not QuestRewarded(13723) and QuestRewarded(13704) and IsRace(1037) or not QuestRewarded(13723) and QuestRewarded(13688) and IsRace(64))",
  -- The Grand Melee
  [13750] = "(not QuestRewarded(13723) and QuestRewarded(13704) and IsRace(1037) or not QuestRewarded(13723) and QuestRewarded(13688) and IsRace(64))",
  -- A Blade Fit For A Champion
  [13752] = "(not QuestRewarded(13724) and QuestRewarded(13705) and IsRace(77) or not QuestRewarded(13724) and QuestRewarded(13690) and IsRace(1024))",
  -- A Worthy Weapon
  [13753] = "(not QuestRewarded(13724) and QuestRewarded(13705) and IsRace(77) or not QuestRewarded(13724) and QuestRewarded(13690) and IsRace(1024))",
  -- The Edge Of Winter
  [13754] = "(not QuestRewarded(13724) and QuestRewarded(13705) and IsRace(77) or not QuestRewarded(13724) and QuestRewarded(13690) and IsRace(1024))",
  -- A Valiant's Field Training
  [13755] = "(not QuestRewarded(13724) and QuestRewarded(13705) and IsRace(77) or not QuestRewarded(13724) and QuestRewarded(13690) and IsRace(1024))",
  -- The Grand Melee
  [13756] = "(not QuestRewarded(13724) and QuestRewarded(13705) and IsRace(77) or not QuestRewarded(13724) and QuestRewarded(13690) and IsRace(1024))",
  -- A Blade Fit For A Champion
  [13757] = "(not QuestRewarded(13725) and QuestRewarded(13706) and IsRace(1093) or not QuestRewarded(13725) and QuestRewarded(13689) and IsRace(8))",
  -- A Worthy Weapon
  [13758] = "(not QuestRewarded(13725) and QuestRewarded(13706) and IsRace(1093) or not QuestRewarded(13725) and QuestRewarded(13689) and IsRace(8))",
  -- The Edge Of Winter
  [13759] = "(not QuestRewarded(13725) and QuestRewarded(13706) and IsRace(1093) or not QuestRewarded(13725) and QuestRewarded(13689) and IsRace(8))",
  -- A Valiant's Field Training
  [13760] = "(not QuestRewarded(13725) and QuestRewarded(13706) and IsRace(1093) or not QuestRewarded(13725) and QuestRewarded(13689) and IsRace(8))",
  -- The Grand Melee
  [13761] = "(not QuestRewarded(13725) and QuestRewarded(13706) and IsRace(1093) or not QuestRewarded(13725) and QuestRewarded(13689) and IsRace(8))",
  -- A Blade Fit For A Champion
  [13762] = "(not QuestRewarded(13726) and QuestRewarded(13707) and IsRace(688) or not QuestRewarded(13726) and QuestRewarded(13691) and IsRace(2))",
  -- A Worthy Weapon
  [13763] = "(not QuestRewarded(13726) and QuestRewarded(13707) and IsRace(688) or not QuestRewarded(13726) and QuestRewarded(13691) and IsRace(2))",
  -- The Edge Of Winter
  [13764] = "(not QuestRewarded(13726) and QuestRewarded(13707) and IsRace(688) or not QuestRewarded(13726) and QuestRewarded(13691) and IsRace(2))",
  -- A Valiant's Field Training
  [13765] = "(not QuestRewarded(13726) and QuestRewarded(13707) and IsRace(688) or not QuestRewarded(13726) and QuestRewarded(13691) and IsRace(2))",
  -- The Grand Melee
  [13767] = "(not QuestRewarded(13726) and QuestRewarded(13707) and IsRace(688) or not QuestRewarded(13726) and QuestRewarded(13691) and IsRace(2))",
  -- A Blade Fit For A Champion
  [13768] = "(not QuestRewarded(13727) and QuestRewarded(13708) and IsRace(562) or not QuestRewarded(13727) and QuestRewarded(13693) and IsRace(128))",
  -- A Worthy Weapon
  [13769] = "(not QuestRewarded(13727) and QuestRewarded(13708) and IsRace(562) or not QuestRewarded(13727) and QuestRewarded(13693) and IsRace(128))",
  -- The Edge Of Winter
  [13770] = "(not QuestRewarded(13727) and QuestRewarded(13708) and IsRace(562) or not QuestRewarded(13727) and QuestRewarded(13693) and IsRace(128))",
  -- A Valiant's Field Training
  [13771] = "(not QuestRewarded(13727) and QuestRewarded(13708) and IsRace(562) or not QuestRewarded(13727) and QuestRewarded(13693) and IsRace(128))",
  -- The Grand Melee
  [13772] = "(not QuestRewarded(13727) and QuestRewarded(13708) and IsRace(562) or not QuestRewarded(13727) and QuestRewarded(13693) and IsRace(128))",
  -- A Blade Fit For A Champion
  [13773] = "(not QuestRewarded(13728) and QuestRewarded(13709) and IsRace(658) or not QuestRewarded(13728) and QuestRewarded(13694) and IsRace(32))",
  -- A Worthy Weapon
  [13774] = "(not QuestRewarded(13728) and QuestRewarded(13709) and IsRace(658) or not QuestRewarded(13728) and QuestRewarded(13694) and IsRace(32))",
  -- The Edge Of Winter
  [13775] = "(not QuestRewarded(13728) and QuestRewarded(13709) and IsRace(658) or not QuestRewarded(13728) and QuestRewarded(13694) and IsRace(32))",
  -- A Valiant's Field Training
  [13776] = "(not QuestRewarded(13728) and QuestRewarded(13709) and IsRace(658) or not QuestRewarded(13728) and QuestRewarded(13694) and IsRace(32))",
  -- The Grand Melee
  [13777] = "(not QuestRewarded(13728) and QuestRewarded(13709) and IsRace(658) or not QuestRewarded(13728) and QuestRewarded(13694) and IsRace(32))",
  -- A Blade Fit For A Champion
  [13778] = "(not QuestRewarded(13729) and QuestRewarded(13710) and IsRace(674) or not QuestRewarded(13729) and QuestRewarded(13695) and IsRace(16))",
  -- A Worthy Weapon
  [13779] = "(not QuestRewarded(13729) and QuestRewarded(13710) and IsRace(674) or not QuestRewarded(13729) and QuestRewarded(13695) and IsRace(16))",
  -- The Edge Of Winter
  [13780] = "(not QuestRewarded(13729) and QuestRewarded(13710) and IsRace(674) or not QuestRewarded(13729) and QuestRewarded(13695) and IsRace(16))",
  -- A Valiant's Field Training
  [13781] = "(not QuestRewarded(13729) and QuestRewarded(13710) and IsRace(674) or not QuestRewarded(13729) and QuestRewarded(13695) and IsRace(16))",
  -- The Grand Melee
  [13782] = "(not QuestRewarded(13729) and QuestRewarded(13710) and IsRace(674) or not QuestRewarded(13729) and QuestRewarded(13695) and IsRace(16))",
  -- A Blade Fit For A Champion
  [13783] = "(not QuestRewarded(13731) and QuestRewarded(13711) and IsRace(178) or not QuestRewarded(13731) and QuestRewarded(13696) and IsRace(512))",
  -- A Worthy Weapon
  [13784] = "(not QuestRewarded(13731) and QuestRewarded(13711) and IsRace(178) or not QuestRewarded(13731) and QuestRewarded(13696) and IsRace(512))",
  -- The Edge Of Winter
  [13785] = "(not QuestRewarded(13731) and QuestRewarded(13711) and IsRace(178) or not QuestRewarded(13731) and QuestRewarded(13696) and IsRace(512))",
  -- A Valiant's Field Training
  [13786] = "(not QuestRewarded(13731) and QuestRewarded(13711) and IsRace(178) or not QuestRewarded(13731) and QuestRewarded(13696) and IsRace(512))",
  -- The Grand Melee
  [13787] = "(not QuestRewarded(13731) and QuestRewarded(13711) and IsRace(178) or not QuestRewarded(13731) and QuestRewarded(13696) and IsRace(512))",
  -- Taking Battle To The Enemy
  [13789] = "((QuestRewarded(13725) or QuestRewarded(13731) or QuestRewarded(13729) or QuestRewarded(13726)) or (QuestRewarded(13699) or QuestRewarded(13713) or QuestRewarded(13723) or QuestRewarded(13724)) or QuestRewarded(13728) or QuestRewarded(13727))",
  -- Among the Champions
  [13790] = "((QuestRewarded(13725) or QuestRewarded(13731) or QuestRewarded(13729) or QuestRewarded(13726)) or (QuestRewarded(13699) or QuestRewarded(13713) or QuestRewarded(13723) or QuestRewarded(13724)) or QuestRewarded(13728) or QuestRewarded(13727))",
  -- Taking Battle To The Enemy
  [13791] = "((QuestRewarded(13725) or QuestRewarded(13731) or QuestRewarded(13729) or QuestRewarded(13726)) or (QuestRewarded(13699) or QuestRewarded(13713) or QuestRewarded(13723) or QuestRewarded(13724)) or QuestRewarded(13728) or QuestRewarded(13727))",
  -- Among the Champions
  [13793] = "((QuestRewarded(13725) or QuestRewarded(13731) or QuestRewarded(13729) or QuestRewarded(13726)) or (QuestRewarded(13699) or QuestRewarded(13713) or QuestRewarded(13723) or QuestRewarded(13724)) or QuestRewarded(13728) or QuestRewarded(13727))",
  -- Taking Battle To The Enemy
  [13810] = "((QuestRewarded(13725) or QuestRewarded(13731) or QuestRewarded(13729) or QuestRewarded(13726)) or (QuestRewarded(13699) or QuestRewarded(13713) or QuestRewarded(13723) or QuestRewarded(13724)) or QuestRewarded(13728) or QuestRewarded(13727))",
  -- Among the Champions
  [13811] = "((QuestRewarded(13725) or QuestRewarded(13731) or QuestRewarded(13729) or QuestRewarded(13726)) or (QuestRewarded(13699) or QuestRewarded(13713) or QuestRewarded(13723) or QuestRewarded(13724)) or QuestRewarded(13728) or QuestRewarded(13727))",
  -- Taking Battle To The Enemy
  [13813] = "((QuestRewarded(13725) or QuestRewarded(13731) or QuestRewarded(13729) or QuestRewarded(13726)) or (QuestRewarded(13699) or QuestRewarded(13713) or QuestRewarded(13723) or QuestRewarded(13724)) or QuestRewarded(13728) or QuestRewarded(13727))",
  -- Among the Champions
  [13814] = "((QuestRewarded(13725) or QuestRewarded(13731) or QuestRewarded(13729) or QuestRewarded(13726)) or (QuestRewarded(13699) or QuestRewarded(13713) or QuestRewarded(13723) or QuestRewarded(13724)) or QuestRewarded(13728) or QuestRewarded(13727))",
  -- Contributin' To The Cause
  [13846] = "((QuestRewarded(13725) or QuestRewarded(13731) or QuestRewarded(13729) or QuestRewarded(13726)) or (QuestRewarded(13699) or QuestRewarded(13713) or QuestRewarded(13723) or QuestRewarded(13724)) or QuestRewarded(13728) or QuestRewarded(13727))",
  -- At The Enemy's Gates
  [13847] = "(not QuestRewarded(13699) and QuestRewarded(13593) and IsRace(1100) or not QuestRewarded(13699) and QuestRewarded(13684) and IsRace(1))",
  -- At The Enemy's Gates
  [13851] = "(not QuestRewarded(13713) and QuestRewarded(13703) and IsRace(1097) or not QuestRewarded(13713) and QuestRewarded(13685) and IsRace(4))",
  -- At The Enemy's Gates
  [13852] = "(not QuestRewarded(13723) and QuestRewarded(13704) and IsRace(1037) or not QuestRewarded(13723) and QuestRewarded(13688) and IsRace(64))",
  -- At The Enemy's Gates
  [13854] = "(not QuestRewarded(13724) and QuestRewarded(13705) and IsRace(77) or not QuestRewarded(13724) and QuestRewarded(13690) and IsRace(1024))",
  -- At The Enemy's Gates
  [13855] = "(not QuestRewarded(13725) and QuestRewarded(13706) and IsRace(1093) or not QuestRewarded(13725) and QuestRewarded(13689) and IsRace(8))",
  -- At The Enemy's Gates
  [13856] = "(not QuestRewarded(13726) and QuestRewarded(13707) and IsRace(688) or not QuestRewarded(13726) and QuestRewarded(13691) and IsRace(2))",
  -- At The Enemy's Gates
  [13857] = "(not QuestRewarded(13727) and QuestRewarded(13708) and IsRace(562) or not QuestRewarded(13727) and QuestRewarded(13693) and IsRace(128))",
  -- At The Enemy's Gates
  [13858] = "(not QuestRewarded(13728) and QuestRewarded(13709) and IsRace(658) or not QuestRewarded(13728) and QuestRewarded(13694) and IsRace(32))",
  -- At The Enemy's Gates
  [13859] = "(not QuestRewarded(13731) and QuestRewarded(13711) and IsRace(178) or not QuestRewarded(13731) and QuestRewarded(13696) and IsRace(512))",
  -- At The Enemy's Gates
  [13860] = "(not QuestRewarded(13729) and QuestRewarded(13710) and IsRace(674) or not QuestRewarded(13729) and QuestRewarded(13695) and IsRace(16))",
  -- Battle Before The Citadel
  [13861] = "((QuestRewarded(13725) or QuestRewarded(13731) or QuestRewarded(13729) or QuestRewarded(13726)) or (QuestRewarded(13699) or QuestRewarded(13713) or QuestRewarded(13723) or QuestRewarded(13724)) or QuestRewarded(13728) or QuestRewarded(13727))",
  -- Battle Before The Citadel
  [13862] = "((QuestRewarded(13725) or QuestRewarded(13731) or QuestRewarded(13729) or QuestRewarded(13726)) or (QuestRewarded(13699) or QuestRewarded(13713) or QuestRewarded(13723) or QuestRewarded(13724)) or QuestRewarded(13728) or QuestRewarded(13727))",
  -- Battle Before The Citadel
  [13863] = "((QuestRewarded(13725) or QuestRewarded(13731) or QuestRewarded(13729) or QuestRewarded(13726)) or (QuestRewarded(13699) or QuestRewarded(13713) or QuestRewarded(13723) or QuestRewarded(13724)) or QuestRewarded(13728) or QuestRewarded(13727))",
  -- Battle Before The Citadel
  [13864] = "((QuestRewarded(13725) or QuestRewarded(13731) or QuestRewarded(13729) or QuestRewarded(13726)) or (QuestRewarded(13699) or QuestRewarded(13713) or QuestRewarded(13723) or QuestRewarded(13724)) or QuestRewarded(13728) or QuestRewarded(13727))",
  -- Drottinn Hrothgar
  [14101] = "(HasAchievement(2816) or HasAchievement(2817))",
  -- Mistcaller Yngvar
  [14102] = "(HasAchievement(2816) or HasAchievement(2817))",
  -- Ornolf The Scarred
  [14104] = "(HasAchievement(2816) or HasAchievement(2817))",
  -- Deathspeaker Kharos
  [14105] = "(HasAchievement(2816) or HasAchievement(2817))",
  -- The Fate Of The Fallen
  [14107] = "(HasAchievement(2816) or HasAchievement(2817))",
  -- Get Kraken!
  [14108] = "(HasAchievement(2816) or HasAchievement(2817))",
  -- The Call to Command
  [14349] = "QuestRewarded(6136) and QuestRewarded(6135)",
  -- Crushing the Crown
  [24638] = "IsLevelBelow(13) and IsLevel(5)",
  -- Crushing the Crown
  [24645] = "IsLevelBelow(22) and IsLevel(14)",
  -- Crushing the Crown
  [24647] = "IsLevelBelow(31) and IsLevel(23)",
  -- Crushing the Crown
  [24648] = "IsLevelBelow(40) and IsLevel(32)",
  -- Crushing the Crown
  [24649] = "IsLevelBelow(50) and IsLevel(41)",
  -- Crushing the Crown
  [24650] = "IsLevelBelow(60) and IsLevel(51)",
  -- Crushing the Crown
  [24651] = "IsLevelBelow(70) and IsLevel(61)",
  -- Crushing the Crown
  [24652] = "IsLevel(71)",
  -- Crushing the Crown
  [24658] = "IsLevelBelow(13) and IsLevel(5)",
  -- Crushing the Crown
  [24659] = "IsLevelBelow(22) and IsLevel(14)",
  -- Crushing the Crown
  [24660] = "IsLevelBelow(31) and IsLevel(23)",
  -- Crushing the Crown
  [24662] = "IsLevelBelow(40) and IsLevel(32)",
  -- Crushing the Crown
  [24663] = "IsLevelBelow(50) and IsLevel(41)",
  -- Crushing the Crown
  [24664] = "IsLevelBelow(60) and IsLevel(51)",
  -- Crushing the Crown
  [24665] = "IsLevelBelow(70) and IsLevel(61)",
  -- Crushing the Crown
  [24666] = "IsLevel(71)",
}

function GetQuestConditions()
  return conditionDB
end
