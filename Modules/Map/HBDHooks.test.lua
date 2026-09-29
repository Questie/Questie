dofile("setupTests.lua")

describe("HBDHooks", function()
    ---@type HBDHooks
    local HBDHooks

    local HBDPins
    local activePins
    local originalLibStub

    before_each(function()
        activePins = {{}, {}}
        HBDPins = {
            worldmapProviderPin = {},
            worldmapProvider = {
                OnMapChanged = function() end,
                GetMap = function()
                    return {
                        EnumeratePinsByTemplate = function()
                            local i = 0
                            return function()
                                i = i + 1
                                return activePins[i]
                            end
                        end,
                    }
                end,
            },
        }

        originalLibStub = _G.LibStub
        _G.LibStub = function() return HBDPins end

        dofile("Modules/Map/HBDHooks.lua")
        HBDHooks = QuestieLoader:ImportModule("HBDHooks")
    end)

    after_each(function()
        _G.LibStub = originalLibStub
        Questie.IsForever = nil
    end)

    describe("Init", function()
        it("should hide Questie world map pins from the gamepad cursor on Forever", function()
            Questie.IsForever = true

            HBDHooks:Init()

            assert.is_nil(HBDPins.worldmapProviderPin.GetCenter())
            assert.is_nil(activePins[1].GetCenter())
            assert.is_nil(activePins[2].GetCenter())
        end)

        it("should hide world map pins created after Init from the gamepad cursor on Forever", function()
            Questie.IsForever = true

            HBDHooks:Init()

            -- HereBeDragons-Pins-2.0 creates new pins via Mixin(frame, worldmapProviderPin)
            local newPin = {GetCenter = function() return 1, 1 end}
            for key, value in pairs(HBDPins.worldmapProviderPin) do
                newPin[key] = value
            end
            assert.is_nil(newPin:GetCenter())
        end)

        it("should not touch the world map pins on other flavors", function()
            Questie.IsForever = false

            HBDHooks:Init()

            assert.is_nil(HBDPins.worldmapProviderPin.GetCenter)
            assert.is_nil(activePins[1].GetCenter)
            assert.is_nil(activePins[2].GetCenter)
        end)

        it("should keep hooking OnMapChanged", function()
            local originalOnMapChanged = HBDPins.worldmapProvider.OnMapChanged

            HBDHooks:Init()

            assert.are_not.equal(originalOnMapChanged, HBDPins.worldmapProvider.OnMapChanged)
        end)
    end)
end)
