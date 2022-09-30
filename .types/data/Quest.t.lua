
---@alias QuestId number
---@alias ZoneOrSort number -- >0: AreaTable.dbc ID; <0: QuestSort.dbc ID
---@alias Category string --- Used a lot in the tracker and questlog
---@alias ObjectiveIndex number --- The index of the objective in the quest

--------------------------------------------------------------------------------
-- Starters

--  ['startedBy'] = 2, -- table
--    ['creatureStart'] = 1, -- table {creature(int),...}
--    ['objectStart'] = 2, -- table {object(int),...}
--    ['itemStart'] = 3, -- table {item(int),...}

---@alias StartedBy {[1]: StartedByNpc, [2]: StartedByObject, [3]: StartedByItem}
---@alias StartedByNpc NpcId[]
---@alias StartedByObject ObjectId[]
---@alias StartedByItem ItemId[]

--------------------------------------------------------------------------------
-- Finishers

---@class Finisher
---@field Type "monster"|"object"
---@field Id NpcId|ObjectId
---@field Name Name

-- ['finishedBy'] = 3, -- table
--   ['creatureEnd'] = 1, -- table {creature(int),...}
--   ['objectEnd'] = 2, -- table {object(int),...}

---@alias FinishedBy {[1]: FinishedByNpc, [2]: FinishedByObject}
---@alias FinishedByNpc NpcId[]
---@alias FinishedByObject ObjectId[]


--------------------------------------------------------------------------------
-- Objectives
---@alias Objective NpcObjective|ObjectObjective|ItemObjective|ReputationObjective|KillObjective|TriggerEndObjective

---@class NpcObjective
---@field Type "monster"
---@field Id NpcId
---@field Text string

---@class ObjectObjective
---@field Type "object"
---@field Id ObjectId
---@field Text string

---@class ItemObjective
---@field Type "item"
---@field Id ItemId
---@field Text string

---@class ReputationObjective
---@field Type "reputation"
---@field Id FactionId
---@field RequiredRepValue number

---@class KillObjective
---@field Type "killcredit"
---@field IdList NpcId[]
---@field RootId NpcId

---@class TriggerEndObjective
---@field Type "event"
---@field Text string
---@field Coordinates table<AreaId, CoordPair[]>


---@class QuestObjective
---@field Id FactionId|ItemId|NpcId|ObjectId The relevant ID for the objective
---@field Index ObjectiveIndex The index of the objective in the quest
---@field questId QuestId The QuestId for the quest
---@field QuestData Quest Basically contains the data from QuestieDB:GetQuest
---@field _lastUpdate number UNKNOWN
---@field Description string Objective description
---@field spawnList table<NpcId, SpawnListNPC>[]|table<ObjectId, SpawnListObject>|table<NpcId, SpawnListNPC>|{ [1]: SpawnListBase }|table<ItemId, SpawnListItem> UNKOWN
---@field AlreadySpawned table UNKNOWN
---@field Update fun(self: table) Quick call for _QuestieQuest.ObjectiveUpdate
---@field Coordinates table<AreaId, CoordPair[]> @ Only used for type "event"
---@field RequiredRepValue number @ Only used for type "reputation"
---@field Type "event"|"item"|"killcredit"|"monster"|"object"|"reputation" Added in _QuestieQuest.ObjectiveUpdate
---@field isUpdated boolean Used and added in _QuestieQuest.ObjectiveUpdate
---@field Completed boolean Added in _QuestieQuest.ObjectiveUpdate
---@field Color Color Added in QuestieQuest:PopulateObjective


-- ---@alias test { [1]: TriggerEndObjective }
-- ---@type test
-- local gg = {}
-- gg][]

-- ['objectives'] = 10, -- table
--   ['creatureObjective'] = 1, -- table {{creature(int), text(string)},...}, If text is nil the default "<Name> slain x/y" is used
--   ['objectObjective'] = 2, -- table {{object(int), text(string)},...}
--   ['itemObjective'] = 3, -- table {{item(int), text(string)},...}
--   ['reputationObjective'] = 4, -- table: {faction(int), value(int)}
--   ['killCreditObjective'] = 5, -- table: {{{creature(int), ...}, baseCreatureID, baseCreatureText}, ...}

---@class RawObjectives : {[1]: RawNpcObjective[], [2]: RawObjectObjective[], [3]: RawItemObjective[], [4]: RawReputationObjective, [5]: RawKillObjective[]}
---@class RawNpcObjective : { [1]: NpcId, [2]: string }
---@class RawObjectObjective : { [1]: ObjectId, [2]: string }
---@class RawItemObjective : { [1]: ItemId, [2]: string }
---@class RawReputationObjective : { [1]: FactionId, [2]: number }
---@class RawKillObjective : { [1]: NpcId[], [2]: NpcId, [3]: string }



-- ['finishedBy'] = 3, -- table
--   ['creatureEnd'] = 1, -- table {creature(int),...}
--   ['objectEnd'] = 2, -- table {object(int),...}
-- ['requiredLevel'] = 4, -- int
-- ['questLevel'] = 5, -- int
-- ['requiredRaces'] = 6, -- bitmask
-- ['requiredClasses'] = 7, -- bitmask
-- ['objectivesText'] = 8, -- table: {string,...}, Description of the quest. Auto-complete if nil.
-- ['triggerEnd'] = 9, -- table: {text, {[zoneID] = {coordPair,...},...}}
-- ['objectives'] = 10, -- table
--   ['creatureObjective'] = 1, -- table {{creature(int), text(string)},...}, If text is nil the default "<Name> slain x/y" is used
--   ['objectObjective'] = 2, -- table {{object(int), text(string)},...}
--   ['itemObjective'] = 3, -- table {{item(int), text(string)},...}
--   ['reputationObjective'] = 4, -- table: {faction(int), value(int)}
--   ['killCreditObjective'] = 5, -- table: {{{creature(int), ...}, baseCreatureID, baseCreatureText}, ...}