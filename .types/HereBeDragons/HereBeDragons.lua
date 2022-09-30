---@meta

---@class HereBeDragonsQuestie-2.0
local lib = {}

--- Return the localized zone name for a given uiMapID
-- @param uiMapID uiMapID of the zone
function lib:GetLocalizedMap(uiMapID) end

--- Get the size of the zone
-- @param uiMapID uiMapID of the zone
-- @return width, height of the zone, in yards
function lib:GetZoneSize(uiMapID) end

--- Get a list of all map IDs
-- @return array-style table with all known/valid map IDs
function lib:GetAllMapIDs() end

--- Convert local/point coordinates to world coordinates in yards
-- @param x X position in 0-1 point coordinates
-- @param y Y position in 0-1 point coordinates
-- @param zone uiMapID of the zone
function lib:GetWorldCoordinatesFromZone(x, y, zone) end

--- Convert local/point coordinates to world coordinates in yards. The coordinates have to come from the Azeroth World Map
-- @param x X position in 0-1 point coordinates
-- @param y Y position in 0-1 point coordinates
-- @param instance Instance to use for the world coordinates
function lib:GetWorldCoordinatesFromAzerothWorldMap(x, y, instance) end


--- Convert world coordinates to local/point zone coordinates
-- @param x Global X position
-- @param y Global Y position
-- @param zone uiMapID of the zone
-- @param allowOutOfBounds Allow coordinates to go beyond the current map (ie. outside of the 0-1 range), otherwise nil will be returned
function lib:GetZoneCoordinatesFromWorld(x, y, zone, allowOutOfBounds) end

--- Convert world coordinates to local/point zone coordinates on the azeroth world map
-- @param x Global X position
-- @param y Global Y position
-- @param instance Instance to translate coordinates from
-- @param allowOutOfBounds Allow coordinates to go beyond the current map (ie. outside of the 0-1 range), otherwise nil will be returned
function lib:GetAzerothWorldMapCoordinatesFromWorld(x, y, instance, allowOutOfBounds) end

--- Translate zone coordinates from one zone to another
-- @param x X position in 0-1 point coordinates, relative to the origin zone
-- @param y Y position in 0-1 point coordinates, relative to the origin zone
-- @param oZone Origin Zone, uiMapID
-- @param dZone Destination Zone, uiMapID
-- @param allowOutOfBounds Allow coordinates to go beyond the current map (ie. outside of the 0-1 range), otherwise nil will be returned
function lib:TranslateZoneCoordinates(x, y, oZone, dZone, allowOutOfBounds) end

--- Return the distance from an origin position to a destination position in the same instance/continent.
-- @param instanceID instance ID
-- @param oX origin X
-- @param oY origin Y
-- @param dX destination X
-- @param dY destination Y
-- @return distance, deltaX, deltaY
function lib:GetWorldDistance(instanceID, oX, oY, dX, dY) end

--- Return the distance between two points on the same continent
-- @param oZone origin zone uiMapID
-- @param oX origin X, in local zone/point coordinates
-- @param oY origin Y, in local zone/point coordinates
-- @param dZone destination zone uiMapID
-- @param dX destination X, in local zone/point coordinates
-- @param dY destination Y, in local zone/point coordinates
-- @return distance, deltaX, deltaY in yards
function lib:GetZoneDistance(oZone, oX, oY, dZone, dX, dY) end

--- Return the angle and distance from an origin position to a destination position in the same instance/continent.
-- @param instanceID instance ID
-- @param oX origin X
-- @param oY origin Y
-- @param dX destination X
-- @param dY destination Y
-- @return angle, distance where angle is in radians and distance in yards
function lib:GetWorldVector(instanceID, oX, oY, dX, dY) end

--- Get the current world position of the specified unit
-- The position is transformed to the current continent, if applicable
-- NOTE: The same restrictions as for the UnitPosition() API apply,
-- which means a very limited set of unit ids will actually work.
-- @param unitId Unit Id
-- @return x, y, instanceID
function lib:GetUnitWorldPosition(unitId) end

--- Get the current world position of the player
-- The position is transformed to the current continent, if applicable
-- @return x, y, instanceID
function lib:GetPlayerWorldPosition() end

--- Get the current zone and level of the player
-- The returned mapFile can represent a micro dungeon, if the player currently is inside one.
-- @return uiMapID, mapType
function lib:GetPlayerZone() end

--- Get the current position of the player on a zone level
-- The returned values are local point coordinates, 0-1. The mapFile can represent a micro dungeon.
-- @param allowOutOfBounds Allow coordinates to go beyond the current map (ie. outside of the 0-1 range), otherwise nil will be returned
-- @return x, y, uiMapID, mapType
function lib:GetPlayerZonePosition(allowOutOfBounds) end