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
local conditionFixes = {
    -- Earth Sapta (Tauren chain: 1516 -> 1517 -> 1518)
    [1463] = "QuestRewarded(1517) and not QuestRewarded(1518)",
    -- Earth Sapta (Orc/Troll chain: 1519 -> 1520 -> 1521)
    [1462] = "QuestRewarded(1520) and not QuestRewarded(1521)",
    -- Fire Sapta (chain: 1524 -> 1525 -> 1526 -> 1527)
    [1464] = "QuestRewarded(1526) and not QuestRewarded(1527)",
    -- Water Sapta (UNSURE: ExclusiveGroup=96 with quest 96 may already handle this in Questie)
    -- [972] = "QuestRewarded(100) and not QuestRewarded(96)",
}

function GetQuestConditionsFixes()
    return conditionFixes
end
