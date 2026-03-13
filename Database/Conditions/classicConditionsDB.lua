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
  -- Jaina's Autograph
  [558] = "QuestRewarded(1687) and QuestRewarded(1558) and QuestRewarded(1479)",
  -- You Scream, I Scream...
  [915] = "QuestRewarded(911) and QuestRewarded(910) and QuestRewarded(1800)",
  -- Cairne's Hoofprint
  [925] = "QuestRewarded(911) and QuestRewarded(910) and QuestRewarded(1800)",
  -- Zamek's Distraction
  [1191] = "(QuestAvailable(1194) or QuestInLog(1190))",
  -- Unfinished Gordok Business
  [1318] = "HasAura(22799)",
  -- The Tome of Divinity
  [1641] = "QuestNone(1642)",
  -- The Tome of Divinity
  [1645] = "QuestNone(1646)",
  -- The Symbol of Life
  [1789] = "(QuestInLog(1783) or QuestInLog(1784))",
  -- The Symbol of Life
  [1790] = "(QuestInLog(1786) or QuestInLog(1787))",
  -- Natural Materials
  [3128] = "QuestRewarded(3122)",
  -- Replacement Phial
  [3375] = "not QuestRewarded(2204) and (QuestInLog(2200) or QuestRewarded(2200)) and not HasItemOrBank(7667)",
  -- An Easy Pickup
  [3450] = "(QuestInLog(3449) or QuestRewarded(3449))",
  -- You Scream, I Scream...
  [4822] = "QuestRewarded(1687) and QuestRewarded(1558) and QuestRewarded(1479)",
  -- The Completed Orb of Dar'Orahil
  [4964] = "QuestRewarded(4963) and QuestRewarded(4976)",
  -- The Completed Orb of Noh'Orahil
  [4975] = "QuestRewarded(4962) and QuestRewarded(4976)",
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
  -- The Changing of Paths - Protector No More
  [8764] = "(QuestRewarded(8761) or (QuestRewarded(8751) or QuestRewarded(8756)))",
  -- The Changing of Paths - Invoker No More
  [8765] = "(QuestRewarded(8761) or (QuestRewarded(8751) or QuestRewarded(8756)))",
  -- The Changing of Paths - Conqueror No More
  [8766] = "(QuestRewarded(8761) or (QuestRewarded(8751) or QuestRewarded(8756)))",
}

function GetQuestConditions()
  return conditionDB
end
