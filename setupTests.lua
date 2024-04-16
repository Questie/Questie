dofile("Modules/Libs/QuestieLoader.lua")

_G.bit = {band = function() return 0 end}
_G.GetTime = function() return 0 end

_G.QUEST_MONSTERS_KILLED = ""
_G.QUEST_ITEMS_NEEDED = ""
_G.QUEST_OBJECTS_FOUND = ""
_G.C_QuestLog = {IsQuestFlaggedCompleted = function() return false end}
_G.ExpandFactionHeader = function() end
_G.IsInGroup = function() return false end
_G.UnitInParty = function() return false end
_G.UnitInRaid = function() return false end
_G.UnitFactionGroup = function() return "Horde" end
_G.UnitName = function() return "Testi" end

_G.LibStub = function() return {} end

_G["Questie"] = {
    db = {
        char = {},
        profile = {},
    },
    Debug = function() end,
}

---@type ZoneDB
local ZoneDB = require("Database.Zones.zoneDB")
ZoneDB.zoneIDs = {ICECROWN = 210}
