
---@alias NpcId number


---@class RawNPC
---@field name string @string
---@field minLevelHealth number  -- int
---@field maxLevelHealth number  -- int
---@field minLevel Level  -- int
---@field maxLevel Level  -- int
---@field rank number  -- int, see https://github.com/cmangos/issues/wiki/creature_template#rank
---@field spawns table<AreaId, CoordPair[]>  -- table {[zoneID(int)] = {coordPair(floatVector2D),...},...}
---@field waypoints table<AreaId, CoordPair[]>  -- table {[zoneID(int)] = {coordPair(floatVector2D),...},...}
---@field zoneID AreaId  -- guess as to where this NPC is most common
---@field questStarts QuestId[]  -- table {questID(int),...}
---@field questEnds QuestId[]  -- table {questID(int),...}
---@field factionID FactionId  -- int, see https://github.com/cmangos/issues/wiki/FactionTemplate.dbc
---@field friendlyToFaction "A"|"H"|"AH"?  -- string, Contains "A" and/or "H" depending on NPC being friendly towards those factions. nil if hostile to both.
---@field subName string  -- string, The title or function of the NPC, e.g. "Weapon Vendor"
---@field npcFlags number  -- int, Bitmask containing various flags about the NPCs function (Vendor, Trainer, Flight Master, etc.).
                    -- For flag values see https://github.com/cmangos/mangos-classic/blob/172c005b0a69e342e908f4589b24a6f18246c95e/src/game/Entities/Unit.h#L536
