dofile("Modules/Libs/QuestieLoader.lua")

dofile("Database/itemDB.lua")

local EMTPY_FUNC = function() end

_G.bit = {band = function() return 0 end}
_G.table.getn = function(table)
    local count = 0
    for _ in pairs(table) do count = count + 1 end
    return count
end
_G.hooksecurefunc = EMTPY_FUNC
_G.GetTime = function() return 0 end

_G.QUEST_MONSTERS_KILLED = ""
_G.QUEST_ITEMS_NEEDED = ""
_G.QUEST_OBJECTS_FOUND = ""
_G.UIParent = {GetEffectiveScale = function() return 1 end}

_G.C_QuestLog = {IsQuestFlaggedCompleted = function() return false end}
_G.DurabilityFrame = {
    GetPoint = function() return nil end
}
_G.QuestLogListScrollFrame = {
    ScrollBar = {}
}
_G.GetItemCount = function() return 0 end
_G.GetNumQuestWatches = function() return 0 end
_G.GetQuestLogTitle = function() return "Test Quest" end
_G.GetQuestLogIndexByID = function() return 1 end
_G.ExpandFactionHeader = EMTPY_FUNC
_G.IsEquippableItem = function() return false end
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
    __call = function(_, frameType, frameName)
        local alpha = 1
        local width, height
        local point
        local normalTexture
        local pushedTexture
        local highlightTexture
        local scripts = {}
        local attributes = {}
        local isShown = true

        local mockFrame = {
            ClearAllPoints = EMTPY_FUNC,
            SetScript = function(_, name, callback)
                scripts[name] = callback
            end,
            SetHeight = function(_, value)
                height = value
            end,
            GetHeight = function()
                return height
            end,
            SetWidth = function(_, value)
                width = value
            end,
            GetWidth = function()
                return width
            end,
            SetSize = function(_, w, h)
                width = w
                height = h
            end,
            GetSize = function()
                return width, height
            end,
            SetAlpha = function(_, value)
                alpha = value
            end,
            GetAlpha = function()
                return alpha
            end,
            SetBackdrop = EMTPY_FUNC,
            SetBackdropColor = EMTPY_FUNC,
            SetBackdropBorderColor = EMTPY_FUNC,
            SetPoint = function(_, l, x, y)
                point = {l, nil, nil, x, y}
            end,
            GetPoint = function()
                return table.unpack(point)
            end,
            SetParent = EMTPY_FUNC,
            CreateFontString = function()
                return {
                    SetText = EMTPY_FUNC,
                    SetPoint = EMTPY_FUNC,
                    SetFont = EMTPY_FUNC,
                    Hide = EMTPY_FUNC,
                    Show = EMTPY_FUNC,
                }
            end,
            CreateTexture = function()
                return {
                    SetTexture = EMTPY_FUNC,
                    SetSize = EMTPY_FUNC,
                    SetPoint = EMTPY_FUNC
                }
            end,
            SetNormalTexture = function(_, texture)
                normalTexture = {
                    GetTexture = function()
                        return texture
                    end
                }
            end,
            GetNormalTexture = function()
                return normalTexture
            end,
            SetPushedTexture = function(_, texture)
                pushedTexture = {
                    GetTexture = function()
                        return texture
                    end
                }
            end,
            GetPushedTexture = function()
                return pushedTexture
            end,
            SetHighlightTexture = function(_, texture)
                highlightTexture = {
                    GetTexture = function()
                        return texture
                    end
                }
            end,
            GetHighlightTexture = function()
                return highlightTexture
            end,
            GetName = function()
                return frameName
            end,
            GetObjectType = function()
                return frameType
            end,
            RegisterForClicks = EMTPY_FUNC,
            SetAttribute = function(_, key, value)
                attributes[key] = value
            end,
            Show = function()
                isShown = true
            end,
            Hide = function()
                isShown = false
            end,
            IsVisible = function()
                return isShown
            end,
            RegisterEvent = EMTPY_FUNC,
            HookScript = EMTPY_FUNC,
            scripts = scripts,
            attributes = attributes,
        }
        table.insert(mockedFrames, mockFrame)
        return mockFrame
    end
})

_G.LibStub = {
    GetLibrary = function() return {} end
}

setmetatable(_G.LibStub, {
    __call = function()
        return {
            Fetch = function() return "Font" end
        }
    end
})

local registeredEvents = {}
_G["Questie"] = {
    db = {
        char = {},
        profile = {},
        global = {},
    },
    Debug = EMTPY_FUNC,
    icons = {},
    RegisterEvent = function(_, eventName, callback)
        registeredEvents[eventName] = callback
    end,
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

---@class TestUtils
local TestUtils = {
    resetEvents = function()
        registeredEvents = {}
    end,
    triggerMockEvent = function(eventName, ...)
        if registeredEvents[eventName] then
            registeredEvents[eventName](eventName, ...)
        end
    end
}

return TestUtils
