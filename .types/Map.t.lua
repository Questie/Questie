

---@alias ZoneName string
---@alias ContinentName string


---@alias ZoneEnum table<string, AreaId>
---@alias UiMapId number
---@alias MapId number --ContinentId
---@alias AreaId number --ZoneId
---@alias X number
---@alias Y number

---@alias ZoneCategory number -- Category might be a better name but it's the titles in the questlog

--- CoordPairs are hard to represent in Emmy, it's basically [1]=X [2]=Y
---@class CoordPair : { [1]: X, [2]: Y }
---@class AreaCoordinate : { [1]: AreaId, [2]: X, [3]: Y }

---@class Coordinates
---@field x X[]
---@field y Y[]
---@field zone AreaId

--- R, G, B
---@class Color : {[1]: number, [2]: number, [3]: number}
