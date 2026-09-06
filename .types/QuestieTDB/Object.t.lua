---@meta _

---@class ObjectDB
---@field name fun(id: ObjectId): string? Object name.
---@field questStarts fun(id: ObjectId): QuestId[]? Quests started by this object.
---@field questEnds fun(id: ObjectId): QuestId[]? Quests finished at this object.
---@field spawns fun(id: ObjectId): QuestieTDBSpawnList? Spawn coordinates grouped by zone.
---@field zoneID fun(id: ObjectId): AreaId? Most common zone.
---@field factionID fun(id: ObjectId): number? Faction restriction mask used by spawn data.
---@field waypoints fun(id: ObjectId): QuestieTDBWaypointList? Waypoint paths grouped by zone.
---@field GetByIndex fun(id: ObjectId, fieldIndex: integer): any Read a field by positional index.
---@field Get fun(id: ObjectId, key: QuestieTDBObjectField|integer): any Read a field by canonical name or index.
---@field GetAll fun(id: ObjectId, keys: (QuestieTDBObjectField|integer)[]): QuestieTDBPackedValues? Read fields into a packed table, or nil for an unknown ID.
---@field GetRaw fun(id: ObjectId, key: QuestieTDBObjectField|integer): any Read base data without Corrections or localization.
---@field Exists fun(id: ObjectId): boolean Test the composed view.
---@field InvalidateCache fun(id?: ObjectId) Drop cached fields for one object or every object.
---@field BuildNameIndex fun() Build the Name index now (a no-op when it exists) instead of on the first IdsByName call; a full pass over every object name.
---@field IdsByName fun(name: string): ObjectId[]? Every composed object ID whose current name equals `name` exactly, ascending, or nil; shared and read-only.
ObjectDB = {}

---Returns the composed ID list, or a read-only lookup map when `hashmap` is true.
---@param hashmap? false
---@return ObjectId[] ids
---@overload fun(hashmap: true): table<ObjectId, true>
function ObjectDB.GetAllIds(hashmap) end
