---@meta _

---@class NpcDB
---@field name fun(id: NpcId): string? NPC name.
---@field minLevelHealth fun(id: NpcId): number? Deprecated. Returns placeholder `0` for a known NPC; health is no longer stored.
---@field maxLevelHealth fun(id: NpcId): number? Deprecated. Returns placeholder `1` for a known NPC; health is no longer stored.
---@field minLevel fun(id: NpcId): number? Minimum NPC level.
---@field maxLevel fun(id: NpcId): number? Maximum NPC level.
---@field rank fun(id: NpcId): number? NPC rank.
---@field spawns fun(id: NpcId): QuestieTDBSpawnList? Spawn coordinates grouped by zone.
---@field waypoints fun(id: NpcId): QuestieTDBWaypointList? Waypoint paths grouped by zone.
---@field zoneID fun(id: NpcId): AreaId? Most common zone.
---@field questStarts fun(id: NpcId): QuestId[]? Quests started by this NPC.
---@field questEnds fun(id: NpcId): QuestId[]? Quests finished at this NPC.
---@field factionID fun(id: NpcId): FactionId? Faction ID.
---@field friendlyToFaction fun(id: NpcId): "A"|"H"|"AH"? Friendly player factions.
---@field subName fun(id: NpcId): string? NPC subname.
---@field npcFlags fun(id: NpcId): number? NPC flag bitmask.
---@field GetByIndex fun(id: NpcId, fieldIndex: integer): any Read a field by positional index.
---@field Get fun(id: NpcId, key: QuestieTDBNpcField|integer): any Read a field by canonical name or index.
---@field GetAll fun(id: NpcId, keys: (QuestieTDBNpcField|integer)[]): QuestieTDBPackedValues? Read fields into a packed table, or nil for an unknown ID.
---@field GetRaw fun(id: NpcId, key: QuestieTDBNpcField|integer): any Read base data without Corrections or localization.
---@field Exists fun(id: NpcId): boolean Test the composed view.
---@field InvalidateCache fun(id?: NpcId) Drop cached fields for one NPC or every NPC.
---@field BuildNameIndex fun() Build the Name index now (a no-op when it exists) instead of on the first IdsByName call; a full pass over every NPC name.
---@field IdsByName fun(name: string): NpcId[]? Every composed NPC ID whose current name equals `name` exactly, ascending, or nil; shared and read-only.
NpcDB = {}

---Deprecated compatibility getter. Health is no longer stored.
---@deprecated
---@param id NpcId
---@return number? health Placeholder `0` for a known NPC; `nil` for an unknown ID.
function NpcDB.minLevelHealth(id) end

---Deprecated compatibility getter. Health is no longer stored.
---@deprecated
---@param id NpcId
---@return number? health Placeholder `1` for a known NPC; `nil` for an unknown ID.
function NpcDB.maxLevelHealth(id) end

---Returns the composed ID list, or a read-only lookup map when `hashmap` is true.
---@param hashmap? false
---@return NpcId[] ids
---@overload fun(hashmap: true): table<NpcId, true>
function NpcDB.GetAllIds(hashmap) end
