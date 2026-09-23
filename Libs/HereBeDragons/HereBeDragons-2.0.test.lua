dofile("setupTests.lua")

describe("HereBeDragons Classic world-map bounds", function()
    local globalNames = {"LibStub", "CreateFrame", "CreateVector2D", "C_Map", "GetBuildInfo", "IsLoggedIn",
        "WOW_PROJECT_ID", "WOW_PROJECT_CLASSIC"}
    local savedGlobals
    local library
    local oldVersion
    local rectangles
    local bounds
    local maps

    before_each(function()
        savedGlobals = {}
        for _, name in ipairs(globalNames) do
            savedGlobals[name] = _G[name]
        end
        library = {}
        oldVersion = nil
        _G.LibStub = setmetatable({NewLibrary = function() return library, oldVersion end}, {
            __call = function() return {New = function() return {} end} end,
        })
        _G.CreateFrame = function()
            return {SetScript = function() end, UnregisterAllEvents = function() end, RegisterEvent = function() end}
        end
        _G.CreateVector2D = function(x, y)
            return {GetXY = function() return x, y end}
        end
        _G.IsLoggedIn = function() return false end
        _G.WOW_PROJECT_ID = 2
        _G.WOW_PROJECT_CLASSIC = 2
        _G.GetBuildInfo = function() return "1.15.9", "test", "test", 11509 end
        maps = {
            [947] = {mapID = 947, name = "Azeroth", mapType = 1, parentMapID = 0},
            [1415] = {mapID = 1415, name = "Eastern Kingdoms", mapType = 2, parentMapID = 947},
            [1414] = {mapID = 1414, name = "Kalimdor", mapType = 2, parentMapID = 947},
        }
        -- Deliberately unlike the baked-in Classic constants: each client must use its own API geometry.
        bounds = {
            [1415] = {1000, 600, 800, 400, instance = 0},
            [1414] = {2000, 1200, 900, 700, instance = 1},
        }
        rectangles = {
            [1415] = {0.5, 1, 0.25, 0.5},
            [1414] = {-0.25, 0.75, 0, 1},
        }
        _G.C_Map = {
            GetMapInfo = function(id) return maps[id] end,
            GetMapChildrenInfo = function(id)
                if id == 946 then return {maps[947]} end
                if id == 947 then return {maps[1415], maps[1414]} end
                return {}
            end,
            GetMapGroupID = function() end,
            GetWorldPosFromMapPos = function(id, vector)
                local data = bounds[id]
                if not data then return nil end
                local x, y = vector:GetXY()
                return data.instance, CreateVector2D(data[4] - data[2] * y, data[3] - data[1] * x)
            end,
            GetMapWorldSize = function(id)
                local data = bounds[id]
                if data then return data[1], data[2] end
            end,
            GetMapRectOnMap = function(id, parent)
                assert.are.equal(947, parent)
                return unpack(rectangles[id])
            end,
        }
    end)

    after_each(function()
        for _, name in ipairs(globalNames) do
            _G[name] = savedGlobals[name]
        end
    end)

    it("derives Era bounds from its own rectangles, including out-of-range edges", function()
        dofile("Libs/HereBeDragons/HereBeDragons-2.0.lua")

        assert.are.same({2000, 2400, 1800, 1000}, library.worldMapData[0])
        assert.are.same({2000, 1200, 400, 700}, library.worldMapData[1])
        assert.are.same({0.75, 0.375}, {library:TranslateZoneCoordinates(0.5, 0.5, 1415, 947, true)})
        assert.are.same({0.5, 0.5}, {library:TranslateZoneCoordinates(0.75, 0.375, 947, 1415, true)})
        assert.are.same({0.25, 0.5}, {library:TranslateZoneCoordinates(0.5, 0.5, 1414, 947, true)})
    end)

    it("derives Forever's geometry instead of selecting the Retail fallback", function()
        _G.WOW_PROJECT_ID = 1
        _G.GetBuildInfo = function() return "1.60.1", "69913", "test", 16001 end

        dofile("Libs/HereBeDragons/HereBeDragons-2.0.lua")

        assert.are.same({2000, 2400, 1800, 1000}, library.worldMapData[0])
        assert.are.same({2000, 1200, 400, 700}, library.worldMapData[1])
        assert.are.same({}, library.transforms)
    end)

    it("leaves actual Retail's mapping policy unchanged", function()
        _G.WOW_PROJECT_ID = 1
        _G.GetBuildInfo = function() return "12.0.7", "test", "test", 120007 end

        dofile("Libs/HereBeDragons/HereBeDragons-2.0.lua")

        assert.are.same({76153.14, 50748.62, 65008.24, 23827.51}, library.worldMapData[0])
    end)

    it("retains legacy Era bounds when rectangle data is unavailable or degenerate", function()
        rectangles[1415] = {}
        rectangles[1414] = {0, 0, 0, 1}

        dofile("Libs/HereBeDragons/HereBeDragons-2.0.lua")

        assert.are.same({44688.53, 29795.11, 32601.04, 9894.93}, library.worldMapData[0])
        assert.are.same({44878.66, 29916.10, 8723.96, 14824.53}, library.worldMapData[1])
    end)

    it("rebuilds cached mappings when upgrading version 33", function()
        oldVersion = 33
        library.mapData = {[1415] = {1, 1, 1, 1}}
        library.worldMapData = {[0] = {1, 1, 1, 1}}

        dofile("Libs/HereBeDragons/HereBeDragons-2.0.lua")

        assert.are.same({2000, 2400, 1800, 1000}, library.worldMapData[0])
        assert.are.equal(1000, library.mapData[1415][1])
    end)
end)
