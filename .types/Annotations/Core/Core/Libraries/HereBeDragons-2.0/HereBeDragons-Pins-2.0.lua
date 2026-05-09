-- ----------------------------------------------------------------------------
-- HereBeDragons-Pins-2.0
-- ----------------------------------------------------------------------------
---@meta _
---@class HereBeDragons-Pins-2.0
local lib = {}

-- ----------------------------------------------------------------------------
-- Minimap
-- ----------------------------------------------------------------------------

--- Add a icon to the minimap, specified by World Coordinates
---@param ref string|table Reference to track the icons under, typically a reference to your addon
---@param icon Frame The icon frame
---@param instanceID number The instance ID of the World Coordinate system
---@param x number X World Coordinate
---@param y number Y World Coordinate
---@param floatOnEdge? boolean Flag if the icon should float on the edge of the map when it goes beyond the visible area, or be hidden.
function lib:AddMinimapIconWorld(ref, icon, instanceID, x, y, floatOnEdge) end

--- Add an icon to the minimap, specified by the uiMapID and local Zone Coordinates
---@param ref string|table Reference to track the icons under, typically a reference to your addon
---@param icon Frame The icon frame
---@param uiMapID number UI Map ID of the map to place the icon on
---@param x number X position in local Zone Coordinates
---@param y number Y position in local Zone Coordinates
---@param showInParentZone? boolean Flag if the icon should be shown in the parent zone (if any) of the specified zone. If false, it'll only be shown in the specified zone.
---@param floatOnEdge? boolean Flag if the icon should float on the edge of the map when it goes beyond the visible area, or be hidden.
function lib:AddMinimapIconMap(ref, icon, uiMapID, x, y, showInParentZone, floatOnEdge) end

--- Check wether an icon is floating on the edge of the map
---@param icon Frame The icon frame
---@return boolean|nil
function lib:IsMinimapIconOnEdge(icon) end

--- Remove the specified Minimap Icon
---@param ref string|table Reference to track the icons under, typically a reference to your addon
---@param icon Frame The icon frame
function lib:RemoveMinimapIcon(ref, icon) end

--- Remove all minimap icons registered to the reference "ref"
---@param ref string|table Reference to track the icons under, typically a reference to your addon
function lib:RemoveAllMinimapIcons(ref) end

--- Set an alternative Minimap to draw icons on.
---@param minimapObject? Minimap The new minimap object, or nil to restore the default
function lib:SetMinimapObject(minimapObject) end

-- ----------------------------------------------------------------------------
-- World Map Constants
-- ----------------------------------------------------------------------------

HBD_PINS_WORLDMAP_SHOW_PARENT    = 1 --- Show pin on the specified map and zone parent maps
HBD_PINS_WORLDMAP_SHOW_CONTINENT = 2 --- Show pin on parent and the continent map
HBD_PINS_WORLDMAP_SHOW_WORLD     = 3 --- Show pin on parent, continent and the world map

---@alias HereBeDragons-Pins-2.0.WorldMapShowFlag
---|1 # HBD_PINS_WORLDMAP_SHOW_PARENT
---|2 # HBD_PINS_WORLDMAP_SHOW_CONTINENT
---|3 # HBD_PINS_WORLDMAP_SHOW_WORLD

-- ----------------------------------------------------------------------------
-- World Map
-- ----------------------------------------------------------------------------

--- Add an Icon to the World Map using World Coordinates
---@param ref string|table Reference to track the icons under, typically a reference to your addon
---@param icon Frame The icon frame
---@param instanceID number The instance ID of the World Coordinate system
---@param x number X World Coordinate
---@param y number Y World Coordinate
---@param showFlag? HereBeDragons-Pins-2.0.WorldMapShowFlag Flag where to show the pin. If no flag is specified, the pin is only shown on the specified map.
---@param frameLevelType? string Optional Frame Level type registered with the WorldMapFrame, defaults to PIN_FRAME_LEVEL_AREA_POI
function lib:AddWorldMapIconWorld(ref, icon, instanceID, x, y, showFlag, frameLevelType) end

--- Add a Icon to the World Map using uiMapID and local zone coordinates
---@param ref string|table Reference to track the icons under, typically a reference to your addon
---@param icon Frame The icon frame
---@param uiMapID number UI Map ID of the map to place the icon on
---@param x number X position in local Zone Coordinates
---@param y number Y position in local Zone Coordinates
---@param showFlag? HereBeDragons-Pins-2.0.WorldMapShowFlag Flag where to show the pin. If no flag is specified, the pin is only shown on the specified map.
---@param frameLevelType? string Optional Frame Level type registered with the WorldMapFrame, defaults to PIN_FRAME_LEVEL_AREA_POI
function lib:AddWorldMapIconMap(ref, icon, uiMapID, x, y, showFlag, frameLevelType) end

--- Remove the specified World Map Icon
---@param ref string|table Reference to track the icons under, typically a reference to your addon
---@param icon Frame The icon frame
function lib:RemoveWorldMapIcon(ref, icon) end

--- Remove all World Map icons registered to the reference "ref"
---@param ref string|table Reference to track the icons under, typically a reference to your addon
function lib:RemoveAllWorldMapIcons(ref) end

--- Compute the vector to an icon, see HereBeDragons-2.0 GetWorldVector for usage.
---@param icon Frame The icon frame
---@return number angle The angle, in radians
---@return number distance Distance in yards
function lib:GetVectorToIcon(icon) end
