---@meta _

---@class ObjectDB
---@field name fun(id: ObjectId): string? Object name.
---@field questStarts fun(id: ObjectId): QuestId[]? Quests started by this object.
---@field questEnds fun(id: ObjectId): QuestId[]? Quests finished at this object.
---@field spawns fun(id: ObjectId): QuestieDBSpawnList? Spawn coordinates grouped by zone.
---@field zoneID fun(id: ObjectId): AreaId? Most common zone.
---@field factionID fun(id: ObjectId): number? Deprecated. Returns placeholder `0` for a known object and reports the calling addon in chat once; use `requiredFaction`.
---@field waypoints fun(id: ObjectId): QuestieDBWaypointList? Waypoint paths grouped by zone.
---@field services fun(id: ObjectId): integer[]? Services the object provides, as `Enum.serviceKeys` values; nil when it has none.
---@field requiredFaction fun(id: ObjectId): "A"|"H"? The only faction that can use the object; nil means no restriction.
---@field GetByIndex fun(id: ObjectId, fieldIndex: integer): any Read a field by positional index.
---@field Get fun(id: ObjectId, key: QuestieDBObjectField|integer): any Read a field by canonical name or index.
---@field GetAll fun(id: ObjectId, keys: (QuestieDBObjectField|integer)[]): QuestieDBPackedValues? Read fields into a packed table, or nil for an unknown ID.
---@field GetRaw fun(id: ObjectId, key: QuestieDBObjectField|integer): any Read base data without Corrections or localization.
---@field Exists fun(id: ObjectId): boolean Test the composed view.
---@field InvalidateCache fun(id?: ObjectId) Drop cached fields for one object or every object.
---@field BuildNameIndex fun() Build the Name index now (a no-op when it exists) instead of on the first IdsByName call; a full pass over every object name.
---@field BuildNameIndexAsync fun(iterationsPerCycle?: integer) Build the complete Name index inside a caller-owned coroutine; yield between positive-sized ID batches (default 250), restart after invalidation, return when ready.
---@field IdsByName fun(name: string): ObjectId[]? Every composed object ID whose current name equals `name` exactly, ascending, or nil; shared and read-only.
---@field HasServices fun(id: ObjectId, wanted: table<integer, boolean>): boolean Whether the object provides any service that is a key of `wanted`; allocates nothing per call.
---@field GetServices fun(id: ObjectId): table<integer, true>? The object's services as a fresh lookup set, or nil when it has none; prefer `HasServices` when scanning.
---@field HasAny fun(id: ObjectId, key: QuestieDBObjectField|integer, wanted: table<any, boolean>): boolean Whether a list field holds any value that is a key of `wanted`; false for an unknown ID or a scalar field. Allocates nothing per call.
ObjectDB = {}

---Returns the composed ID list, or a read-only lookup map when `hashmap` is true.
---@param hashmap? false
---@return ObjectId[] ids
---@overload fun(hashmap: true): table<ObjectId, true>
function ObjectDB.GetAllIds(hashmap) end
