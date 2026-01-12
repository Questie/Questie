---@meta

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

---@class Point : { [1]: number, [2]: number }

--- R, G, B
---@class Color : {[1]: number, [2]: number, [3]: number}

---@enum Enum.QuestIcon
local QuestIconEnum = {
    ICON_TYPE_SLAY = 1,
    ICON_TYPE_LOOT = 2,
    ICON_TYPE_EVENT = 3,
    ICON_TYPE_OBJECT = 4,
    ICON_TYPE_TALK = 5,
    ICON_TYPE_AVAILABLE = 6,
    ICON_TYPE_AVAILABLE_GRAY = 7,
    ICON_TYPE_COMPLETE = 8,
    ICON_TYPE_GLOW = 9,
    ICON_TYPE_REPEATABLE = 10,
    ICON_TYPE_REPEATABLE_COMPLETE = 11,
    ICON_TYPE_INCOMPLETE = 12,
    ICON_TYPE_EVENTQUEST = 13,
    ICON_TYPE_EVENTQUEST_COMPLETE = 14,
    ICON_TYPE_PVPQUEST = 15,
    ICON_TYPE_PVPQUEST_COMPLETE = 16,
    ICON_TYPE_INTERACT = 17,
    ICON_TYPE_SODRUNE = 18,
    ICON_TYPE_MOUNT_UP = 19,
    ICON_TYPE_NODE_FISH = 20,
    ICON_TYPE_NODE_HERB = 21,
    ICON_TYPE_NODE_ORE = 22,
    ICON_TYPE_CHEST = 23,
    ICON_TYPE_PET_BATTLE = 24,
  }