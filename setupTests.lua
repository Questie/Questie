dofile("Modules/Libs/QuestieLoader.lua")

_G.bit = {band = function() return 0 end}
_G.GetTime = function() return 0 end

_G.QUEST_MONSTERS_KILLED = ""
_G.QUEST_ITEMS_NEEDED = ""
_G.QUEST_OBJECTS_FOUND = ""
_G.UIParent = {GetEffectiveScale = function() return 1 end}

_G.C_QuestLog = {IsQuestFlaggedCompleted = function() return false end}
_G.GetQuestLogTitle = function() return "Test Quest" end
_G.GetQuestLogIndexByID = function() return 1 end
_G.ExpandFactionHeader = function() end
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
            ClearAllPoints = function() end,
            SetScript = function() end,
            SetWidth = function() end,
            SetHeight = function() end,
            SetSize = function() end,
            SetAlpha = function() end,
            SetBackdrop = function() end,
            SetBackdropColor = function() end,
            SetBackdropBorderColor = function() end,
            SetPoint = function() end,
            GetPoint = function() end,
            CreateFontString = function()
                return {
                    SetText = function() end,
                    SetPoint = function() end,
                    SetFont = function() end,
                }
            end,
            CreateTexture = function()
                return {
                    SetTexture = function() end,
                    SetSize = function() end,
                    SetPoint = function() end
                }
            end,
            Show = function() end,
            Hide = function() end,
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
    Debug = function() end,
    icons = {},
}

---@type ZoneDB
local ZoneDB = require("Database.Zones.zoneDB")
ZoneDB.zoneIDs = {ICECROWN = 210}
