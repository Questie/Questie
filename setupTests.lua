-- TODO: Remove me!
Questie = {
    TBC = false
}
dofile("Modules/Libs/QuestieLoader.lua")
dofile("Modules/Expansions.lua")

dofile("Database/itemDB.lua")
dofile("Database/questDB.lua")
dofile("Database/Zones/data/zoneIds.lua")
dofile("Database/Corrections/ContentPhases/ContentPhases.lua")

local EMTPY_FUNC = function() end

local bit = require("bit32")
_G.bit = bit
_G.table.getn = function(table)
    local count = 0
    for _ in pairs(table) do count = count + 1 end
    return count
end
_G.tContains = function(tab, val)
    for _, value in ipairs(tab) do
        if value == val then
            return true
        end
    end
    return false
end
_G.strsplit = function(delimiter, str)
    local results = {}
    for match in (str .. delimiter):gmatch("(.-)" .. delimiter) do
        table.insert(results, match)
    end
    return unpack(results)
end
_G.date = os.date
_G.string.trim = function(str)
    return str:gsub("^%s*(.-)%s*$", "%1")
end
_G.strlen = string.len
_G.hooksecurefunc = EMTPY_FUNC
_G.GetTime = function() return 0 end
_G.GetCurrentRegion = function() return 3 end

_G.Enum = {ItemQuality = {Poor = 0, Standard = 1}}

_G.QUEST_MONSTERS_KILLED = ""
_G.QUEST_ITEMS_NEEDED = ""
_G.QUEST_OBJECTS_FOUND = ""
_G.UIParent = {GetEffectiveScale = function() return 1 end}

_G.C_AddOns = {
    IsAddOnLoaded = function()
        return false, true
    end
}
_G.C_QuestLog = {IsQuestFlaggedCompleted = {}}
setmetatable(_G.C_QuestLog.IsQuestFlaggedCompleted, {
    mockedReturnValue = false,
    __call = function(_, ...) return _.mockedReturnValue end}
)
_G.DurabilityFrame = {
    GetPoint = function() return nil end
}
_G.QuestLogListScrollFrame = {
    ScrollBar = {}
}
_G.C_Item = {
    GetItemCount = function() return 0 end,
    GetItemSpell = function() return nil end,
}
_G.GetNumQuestWatches = function() return 0 end
_G.GetQuestLogTitle = function() return "Test Quest" end
_G.GetQuestLogIndexByID = function() return 1 end
_G.ExpandFactionHeader = EMTPY_FUNC
_G.InCombatLockdown = function() return false end
_G.IsControlKeyDown = function() return false end
_G.IsEquippableItem = function() return false end
_G.IsInGroup = function() return false end
_G.IsShiftKeyDown = function() return false end
_G.UnitClass = function() return "Druid", "DRUID", 11 end
_G.UnitFactionGroup = function() return "Horde", "Horde" end
_G.UnitInParty = function() return false end
_G.UnitInRaid = function() return false end
_G.UnitFactionGroup = function() return "Horde" end
_G.UnitName = function() return "Testi" end
_G.QUEST_MONSTERS_KILLED = "%s slain: %d/%d"
_G.QUEST_ITEMS_NEEDED = "%s: %d/%d"
_G.QUEST_OBJECTS_FOUND = "%s: %d/%d"

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
                return unpack(point)
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
    Print = EMTPY_FUNC,
    Debug = EMTPY_FUNC,
    Warning = function(_, text)
        print("|cffffff00[WARNING]|r", text)
    end,
    icons = {},
    RegisterEvent = function(_, eventName, callback)
        registeredEvents[eventName] = callback
    end,
    UnregisterEvent = function(_, eventName)
        registeredEvents[eventName] = nil
    end,
    SendMessage = EMTPY_FUNC,
    IsMoP = true,
}

---@class TestUtils
local TestUtils = {
    resetEvents = function()
        registeredEvents = {}
    end,
    ---@param eventName string
    triggerMockEvent = function(eventName, ...)
        if registeredEvents[eventName] then
            registeredEvents[eventName](eventName, ...)
        end
    end,
    ---@param eventName string
    ---@return boolean
    isEventRegistered = function(eventName)
        return registeredEvents[eventName] ~= nil
    end,
}

return TestUtils
