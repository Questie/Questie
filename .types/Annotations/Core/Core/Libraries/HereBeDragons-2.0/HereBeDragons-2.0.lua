---@meta _

-- ----------------------------------------------------------------------------
-- HereBeDragons-2.0
-- ----------------------------------------------------------------------------

---@class HereBeDragons-2.0
---[Documentation](https://www.wowace.com/projects/herebedragons/pages/api/here-be-dragons-2-0)
local lib = {}

-- ----------------------------------------------------------------------------
-- Map Info
-- ----------------------------------------------------------------------------

--- Get a table with all known UI Map IDs
---@return number[] uiMapIDs An array-style table with all known/valid map IDs
function lib:GetAllMapIDs() end

--- Get the localized name of the map
---@param uiMapID number The ID of the map to query
---@return string mapName The localized name of the map
function lib:GetLocalizedMap(uiMapID) end

--- Get the physical size of a zone, in yards
---@param uiMapID number The ID of the map to query
---@return number width Zone Width in Yards
---@return number height Zone Height in Yards
function lib:GetZoneSize(uiMapID) end

-- ----------------------------------------------------------------------------
-- Coordinate Transformation
-- ----------------------------------------------------------------------------

--- Get the Azeroth World Map Coordinates to the specified World Coordinates, within the specified continent instance.
---@param x number X coordinates in the World Coordinate system
---@param y number Y coordinates in the World Coordinate system
---@param instance number InstanceID of the continent these coordinates belong to
---@param allowOutOfBounds? boolean If true, do not clip the coordinates into the 0-1 range if the point is outside of the current map.
---@return number x X coordinate in the Zone Coordinate system
---@return number y Y coordinate in the Zone Coordinate system
function lib:GetAzerothWorldMapCoordinatesFromWorld(x, y, instance, allowOutOfBounds) end

--- Get the World Coordinates to the specified Azeroth world map coordinates
---@param x number X coordinates in the zone coordinate system (0-1)
---@param y number Y coordinates in the zone coordinate system (0-1)
---@param instance number InstanceID of the continent these coordinates belong to
---@return number x X coordinate in the World Coordinate system
---@return number y Y coordinate in the World Coordinate system
function lib:GetWorldCoordinatesFromAzerothWorldMap(x, y, instance) end

--- Get the World Coordinates to the specified Zone Coordinates
---@param x number X coordinates in the Zone Coordinate system (0-1)
---@param y number Y coordinates in the Zone Coordinate system (0-1)
---@param zone number UIMapID of the zone
---@return number x X coordinate in the World Coordinate system
---@return number y Y coordinate in the World Coordinate system
function lib:GetWorldCoordinatesFromZone(x, y, zone) end

--- Calculate the distance between two points in the same World Coordinate system (ie. the same instance)
---@param instanceID number Instance ID of the World Coordinate system (currently unused)
---@param oX number X coordinate of the origin point
---@param oY number Y coordinate of the origin point
---@param dX number X coordinate of the destination point
---@param dY number Y coordinate of the destination point
---@return number distance Distance in yards
---@return number deltaX Delta of the X coordinate in yards
---@return number deltaY Delta of the Y coordinate in yards
function lib:GetWorldDistance(instanceID, oX, oY, dX, dY) end

--- Calculate a vector between the two points in the World Coordinate system
---@param instanceID number Instance ID of the World Coordinate system (currently unused)
---@param oX number X coordinate of the origin point
---@param oY number Y coordinate of the origin point
---@param dX number X coordinate of the destination point
---@param dY number Y coordinate of the destination point
---@return number angle The angle between the two points, in radians
---@return number distance Distance in yards
function lib:GetWorldVector(instanceID, oX, oY, dX, dY) end

--- Get the Zone Coordinates to the specified World Coordinates, within the specified zone.
---
--- Note: It is the callers responsibility to ensure the x/y coordinates are in the same instance/continent as the zone.
---@param x number X coordinates in the World Coordinate system
---@param y number Y coordinates in the World Coordinate system
---@param zone number UIMapID of the zone of the destination Zone Coordinate system
---@param allowOutOfBounds? boolean If true, do not clip the coordinates into the 0-1 range if the point is outside of the current map.
---@return number x X coordinate in the Zone Coordinate system
---@return number y Y coordinate in the Zone Coordinate system
function lib:GetZoneCoordinatesFromWorld(x, y, zone, allowOutOfBounds) end

--- Calculate the distance between two points in different zones.
---
--- Note: Both zones need to be on the same continent for this function to return valid values.
---@param oZone number UIMapID of the origin zone
---@param oX number X coordinate of the origin point
---@param oY number Y coordinate of the origin point
---@param dZone number UIMapID of the destination zone
---@param dX number X coordinate of the destination point
---@param dY number Y coordinate of the destination point
---@return number distance Distance in yards
---@return number deltaX Delta of the X coordinate in yards
---@return number deltaY Delta of the Y coordinate in yards
function lib:GetZoneDistance(oZone, oX, oY, dZone, dX, dY) end

--- Translate the coordinates between two Zone Coordinate systems
---@param x number X coordinate in the origin zone
---@param y number Y coordinate in the origin zone
---@param oZone number UIMapID of the origin zone
---@param dZone number UIMapID of the destination zone
---@param allowOutOfBounds? boolean If true, do not clip the coordinates into the 0-1 range if the point is outside of the destination map.
---@return number x X coordinate in the destination Zone Coordinate system
---@return number y Y coordinate in the destination Zone Coordinate system
function lib:TranslateZoneCoordinates(x, y, oZone, dZone, allowOutOfBounds) end

-- ----------------------------------------------------------------------------
-- Unit Position
-- ----------------------------------------------------------------------------

--- Retrieve the world position of the player.
---
--- Same as calling HBD:GetUnitWorldPosition("player")
---@return number x X coordinate of the player's position
---@return number y Y coordinate of the player's position
---@return number instance Instance ID of the World Coordinate system the player is in
function lib:GetPlayerWorldPosition() end

--- Retrieve the zone information the player is currently in.
---
--- This function does not rely on the world map to retrieve the player's current position.
---@return number currentPlayerUIMapID The UIMapID of the zone
---@return Enum.UIMapType currentPlayerUIMapType The UIMapType of the current map
function lib:GetPlayerZone() end

--- Retrieve the zone information the player is currently in.
---
--- This function does not rely on the world map to retrieve the player's current position.
---@return number x X Zone Coordinate of the player
---@return number y Y Zone Coordinate of the player
---@return number currentPlayerUIMapID The UIMapID of the zone
---@return Enum.UIMapType currentPlayerUIMapType The UIMapType of the current map
function lib:GetPlayerZonePosition() end

--- Get the world position of any unit eligible for UnitPosition
---@param unitID UnitToken Supports player, party, raid only
---@return number x X coordinate of the unit's position
---@return number y Y coordinate of the unit's position
---@return number instance Instance ID of the World Coordinate system the unit is in
function lib:GetUnitWorldPosition(unitID) end

-- ----------------------------------------------------------------------------
-- Callbacks
-- ----------------------------------------------------------------------------

---@alias HereBeDragons.EventName
---|"PlayerZoneChanged"

---@param target table The object registering to listen for the callback.
---@param eventName HereBeDragons.EventName The event to register.
---@param method string|function The method to call when the event is fired.
function lib.RegisterCallback(target, eventName, method) end

---@param target table The object unregistering to listen for the callback.
---@param eventName HereBeDragons.EventName The event to unregister.
function lib.UnregisterCallback(target, eventName) end
