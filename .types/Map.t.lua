

---@alias ZoneName string
---@alias ContinentName string


---@alias ZoneEnum table<string, AreaId>
---@alias UiMapId number
---@alias MapId number --ContinentId
---@alias AreaId number --ZoneId
---@alias X number
---@alias Y number

---@class UiMapDetails
---@field mapID number
---@field name string
---@field mapType UIMapType
---@field parentMapID number
---@field flags number

-- X - Map Coordinate (0-100)
---@class MapX number
-- Y - Map Coordinate (0-100)
---@class MapY number
-- X - World Coordinate (0-100)
---@class WorldX number
-- Y - World Coordinate (0-100)
---@class WorldY number
-- X - Continent Coordinate (0-100)
---@class ContinentX number
-- Y - Continent Coordinate (0-100)
---@class ContinentY number

---@alias ZoneCategory number -- Category might be a better name but it's the titles in the questlog

--- CoordPairs are hard to represent in Emmy, it's basically [1]=X [2]=Y
---@class CoordPair : { [1]: X, [2]: Y }
---@class AreaCoordinate : { [1]: AreaId, [2]: X, [3]: Y }

---@class Coordinates
---@field x MapX[]
---@field y MapY[]
----@field zone AreaId

--- R, G, B
---@class Color : {[1]: number, [2]: number, [3]: number}
