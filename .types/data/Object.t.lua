
---@alias ObjectId number

---@class RawObject
---@field name string -- string
---@field questStarts QuestId[] -- table {questID(int),...}
---@field questEnds QuestId[] -- table {questID(int),...}
---@field spawns table<AreaId, CoordPair[]> -- table {[zoneID(int)] = {coordPair(floatVector2D),...},...}
---@field zoneID AreaId -- guess as to where this object is most common
---@field factionID FactionId -- faction restriction mask (same as spawndb factionid)
