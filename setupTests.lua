dofile("Modules/Libs/QuestieLoader.lua")

local EMTPY_FUNC = function() end

_G.bit = {band = function() return 0 end}
_G.table.getn = function(table)
    local count = 0
    for _ in pairs(table) do count = count + 1 end
    return count
end
_G.GetTime = function() return 0 end

_G.QUEST_MONSTERS_KILLED = ""
_G.QUEST_ITEMS_NEEDED = ""
_G.QUEST_OBJECTS_FOUND = ""
_G.UIParent = {GetEffectiveScale = function() return 1 end}

_G.C_QuestLog = {IsQuestFlaggedCompleted = function() return false end}
_G.GetQuestLogTitle = function() return "Test Quest" end
_G.GetQuestLogIndexByID = function() return 1 end
_G.ExpandFactionHeader = EMTPY_FUNC
_G.IsInGroup = function() return false end
_G.UnitInParty = function() return false end
_G.UnitInRaid = function() return false end
_G.UnitFactionGroup = function() return "Horde" end
_G.UnitName = function() return "Testi" end

local mockedFrames = {}
_G.CreateFrame = {
    mockedFrames = mockedFrames,
    resetMockedFrames = function()
        for k in pairs(mockedFrames) do
            mockedFrames[k] = nil
        end
    end
}
setmetatable(_G.CreateFrame, {
    __call = function()
        local mockFrame = {
            ClearAllPoints = EMTPY_FUNC,
            SetScript = EMTPY_FUNC,
            SetWidth = EMTPY_FUNC,
            SetHeight = EMTPY_FUNC,
            SetSize = EMTPY_FUNC,
            SetAlpha = EMTPY_FUNC,
            SetBackdrop = EMTPY_FUNC,
            SetBackdropColor = EMTPY_FUNC,
            SetBackdropBorderColor = EMTPY_FUNC,
            SetPoint = EMTPY_FUNC,
            GetPoint = EMTPY_FUNC,
            CreateFontString = function()
                return {
                    SetText = EMTPY_FUNC,
                    SetPoint = EMTPY_FUNC,
                    SetFont = EMTPY_FUNC,
                }
            end,
            CreateTexture = function()
                return {
                    SetTexture = EMTPY_FUNC,
                    SetSize = EMTPY_FUNC,
                    SetPoint = EMTPY_FUNC
                }
            end,
            Show = EMTPY_FUNC,
            Hide = EMTPY_FUNC,
        }
        table.insert(mockedFrames, mockFrame)
        return mockFrame
    end
})

_G.LibStub = function()
    return {
        Fetch = function() return "Font" end
    }
end

_G["Questie"] = {
    db = {
        char = {},
        profile = {},
    },
    Debug = EMTPY_FUNC,
    icons = {},
}

---@type ZoneDB
local ZoneDB = require("Database.Zones.zoneDB")
ZoneDB.zoneIDs = {
    ICECROWN = 210,
    DEEPHOLM = 5042,
    STORMWIND_CITY = 1519,
    IRONFORGE = 1537,
    TELDRASSIL = 141,
    ORGRIMMAR = 1637,
    THUNDER_BLUFF = 1638,
    UNDERCITY = 1497,
}
