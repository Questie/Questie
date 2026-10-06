dofile("setupTests.lua")

describe("Polygon fixed horizontal stacks", function()
    local Nudging

    before_each(function()
        dofile("Polygon/PolygonNudging.lua")
        Nudging = QuestieLoader:ImportModule("PolygonNudging")
    end)

    describe("original map-coordinate grouping", function()
        it("gives two identical locations symmetric slots independent of input order", function()
            local meat = {key = "317:1", uiMapId = 1426, x = 50, y = 50, width = 16}
            local ribs = {key = "384:1", uiMapId = 1426, x = 50, y = 50, width = 16}
            local offsets = Nudging.Calculate({ribs, meat})

            assert.are_near(-5.6, offsets["317:1"], 0.000001)
            assert.are_near(5.6, offsets["384:1"], 0.000001)
            assert.are.same(offsets, Nudging.Calculate({meat, ribs}))
            assert.are.same({key = "317:1", uiMapId = 1426, x = 50, y = 50, width = 16}, meat)
        end)

        it("places three related objectives on one horizontal line", function()
            local offsets = Nudging.Calculate({
                {key = "c", uiMapId = 1426, x = 50, y = 50, width = 16},
                {key = "a", uiMapId = 1426, x = 50, y = 50, width = 16},
                {key = "b", uiMapId = 1426, x = 50, y = 50, width = 16},
            })
            assert.are_near(-11.2, offsets.a, 0.000001)
            assert.are.equal(0, offsets.b)
            assert.are_near(11.2, offsets.c, 0.000001)
        end)

        it("uses a tiny map-space radius without collecting nearby screen clutter", function()
            local offsets = Nudging.Calculate({
                {key = "a", uiMapId = 1426, x = 50, y = 50, width = 16},
                {key = "b", uiMapId = 1426, x = 50.006, y = 50.008, width = 16},
                {key = "nearby", uiMapId = 1426, x = 50.02, y = 50, width = 64},
            })
            assert.are_near(-5.6, offsets.a, 0.000001)
            assert.are_near(5.6, offsets.b, 0.000001)
            assert.are.equal(0, offsets.nearby)
        end)

        it("does not combine equal coordinates from different maps", function()
            assert.are.same({a = 0, b = 0}, Nudging.Calculate({
                {key = "a", uiMapId = 1426, x = 50, y = 50, width = 16},
                {key = "b", uiMapId = 1432, x = 50, y = 50, width = 16},
            }))
        end)

        it("does not grow a group through a chain of near locations", function()
            local offsets = Nudging.Calculate({
                {key = "c", uiMapId = 1426, x = 50.015, y = 50, width = 16},
                {key = "b", uiMapId = 1426, x = 50.0075, y = 50, width = 16},
                {key = "a", uiMapId = 1426, x = 50, y = 50, width = 16},
            })
            assert.are_near(-5.6, offsets.a, 0.000001)
            assert.are_near(5.6, offsets.b, 0.000001)
            assert.are.equal(0, offsets.c)
        end)

        it("uses configured widths for fractional and differently sized markers", function()
            local offsets = Nudging.Calculate({
                {key = "large", uiMapId = 1426, x = 50, y = 50, width = 24},
                {key = "small", uiMapId = 1426, x = 50, y = 50, width = 16},
            })
            assert.are_near(-8.4, offsets.large, 0.000001)
            assert.are_near(8.4, offsets.small, 0.000001)
        end)

        it("ignores invalid original coordinates without affecting valid members", function()
            assert.are.same({valid = 0}, Nudging.Calculate({
                {key = "infinite", uiMapId = 1426, x = math.huge, y = 50, width = 16},
                {key = "outside", uiMapId = 1426, x = 101, y = 50, width = 16},
                {key = "valid", uiMapId = 1426, x = 50, y = 50, width = 16},
            }))
        end)
    end)

    describe("stored display anchors", function()
        local layout, first, second, rootScale

        local function Marker(id)
            local frame = {data = {ObjectiveIndex = 1, IconScale = 1}, UiMapID = 1426, x = 50, y = 50,
                effectiveScale = 1, anchors = 0, width = 16, height = 16}
            local parent = {pinTemplate = "HereBeDragonsPinsTemplateQuestie", icon = frame}
            frame.parent, frame.point = parent, {"CENTER", parent, "CENTER", 0, 0}
            frame.GetParent = function(self) return self.parent end
            frame.GetEffectiveScale = function(self) return self.effectiveScale end
            frame.GetPoint = function(self) return unpack(self.point) end
            frame.ClearAllPoints = function() end
            frame.SetPoint = function(self, ...)
                self.point = {...}
                self.anchors = self.anchors + 1
            end
            local marker = {frame = frame, entry = {quest = {Id = id}}}
            frame.polygonMarker = marker
            return marker
        end

        before_each(function()
            rootScale = {scale = 1, GetEffectiveScale = function(self) return self.scale end}
            layout = Nudging.New(rootScale)
            first, second = Marker(317), Marker(384)
        end)

        it("registers callbacks once and never accumulates offsets or repeats grouping for identical input", function()
            local original = Nudging.Calculate
            Nudging.Calculate = spy.new(original)
            layout:Update({second, first}, 1)
            local callback = first.frame.OnWorldMapPinUpdated
            layout:Update({first, second}, 1)

            assert.are.equal(callback, first.frame.OnWorldMapPinUpdated)
            assert.are_near(-5.6, first.frame.point[4], 0.000001)
            assert.are_near(5.6, second.frame.point[4], 0.000001)
            assert.are.equal(0, first.frame.point[5])
            assert.are.equal(1, first.frame.anchors)
            assert.spy(Nudging.Calculate).was.called(1)
            assert.are.same({50, 50, 1426}, {first.frame.x, first.frame.y, first.frame.UiMapID})
            Nudging.Calculate = original
        end)

        it("keeps physical spacing through zoom, root scale changes, and native icon animation without regrouping", function()
            local original = Nudging.Calculate
            Nudging.Calculate = spy.new(original)
            layout:Update({first, second}, 1)
            first.frame.effectiveScale, second.frame.effectiveScale = 2, 2
            first.frame.width, second.frame.width = 48, 48
            layout:Reapply()
            assert.are_near(-2.8, first.frame.point[4], 0.000001)
            assert.are_near(2.8, second.frame.point[4], 0.000001)
            assert.are_near(11.2, (second.frame.point[4] - first.frame.point[4]) * 2, 0.000001)

            rootScale.scale = 0.8
            first.frame.effectiveScale, second.frame.effectiveScale = 1.6, 1.6
            layout:Reapply()
            assert.are_near(-2.8, first.frame.point[4], 0.000001)
            assert.spy(Nudging.Calculate).was.called(1)
            Nudging.Calculate = original
        end)

        it("applies equal physical spacing with different child scales", function()
            second.frame.effectiveScale = 2
            layout:Update({first, second}, 1)
            assert.are_near(-5.6, first.frame.point[4], 0.000001)
            assert.are_near(2.8, second.frame.point[4], 0.000001)
        end)

        it("reapplies after queued acquisition and reacquisition without an OnShow event or polling", function()
            local wrapper = first.frame.parent
            first.frame.parent = {}
            layout:Update({first, second}, 1)
            assert.are.equal(0, first.frame.anchors)
            first.frame.parent = wrapper
            first.frame.point = {"CENTER", wrapper, "CENTER", 0, 0}
            first.frame:OnWorldMapPinUpdated(wrapper)
            assert.are_near(-5.6, first.frame.point[4], 0.000001)

            local replacement = {pinTemplate = "HereBeDragonsPinsTemplateQuestie", icon = first.frame}
            first.frame.parent = replacement
            first.frame.point = {"CENTER", replacement, "CENTER", 0, 0}
            first.frame:OnWorldMapPinUpdated(replacement)
            assert.are.equal(replacement, first.frame.point[2])
            assert.are_near(-5.6, first.frame.point[4], 0.000001)
            assert.are.equal(0, first.frame.point[5])
        end)

        it("keeps hidden members' slots instead of sliding the remaining icon", function()
            layout:Update({first, second}, 1)
            second.frame.hidden = true
            second.frame.texture = {a = 0}
            layout:Update({first, second}, 1)
            assert.are_near(-5.6, first.frame.point[4], 0.000001)
            assert.are_near(5.6, second.frame.point[4], 0.000001)
        end)

        it("updates configured size without relying on the native zoomed dimensions", function()
            layout:Update({first, second}, 1)
            layout:Update({first, second}, 1.5)
            assert.are_near(-8.4, first.frame.point[4], 0.000001)
            assert.are_near(8.4, second.frame.point[4], 0.000001)
            first.frame.data.IconScale = 2
            layout:Update({first, second}, 1.5)
            assert.are_near(-16.8, first.frame.point[4], 0.000001)
            assert.are_near(16.8, second.frame.point[4], 0.000001)
        end)

        it("reads current per-icon settings rather than the cached scale or animated dimensions", function()
            local configuredScale = 1
            first.frame.data.GetIconScale = function() return configuredScale end
            second.frame.data.GetIconScale = function() return configuredScale end
            layout:Update({first, second}, 1)
            assert.are_near(-5.6, first.frame.point[4], 0.000001)

            configuredScale = 2
            first.frame.width, second.frame.width = 48, 48
            layout:Update({first, second}, 1)

            assert.are_near(-11.2, first.frame.point[4], 0.000001)
            assert.are_near(11.2, second.frame.point[4], 0.000001)
            assert.are.equal(1, first.frame.data.IconScale)
        end)

        it("uses a valid cached scale when the current getter has no usable value", function()
            first.frame.data.GetIconScale = function() return 0 / 0 end
            first.frame.data.IconScale = 2
            second.frame.data.GetIconScale = function() return nil end
            layout:Update({first, second}, 1)

            assert.are_near(-11.2, first.frame.point[4], 0.000001)
            assert.are_near(11.2, second.frame.point[4], 0.000001)
        end)

        it("uses unit scale when neither current nor cached icon scales are positive finite numbers", function()
            first.frame.data.GetIconScale = function() return 0 end
            first.frame.data.IconScale = -1
            second.frame.data.GetIconScale = function() return math.huge end
            second.frame.data.IconScale = nil
            layout:Update({first, second}, 1)

            assert.are_near(-5.6, first.frame.point[4], 0.000001)
            assert.are_near(5.6, second.frame.point[4], 0.000001)
        end)

        it("releases its callback and recenters the surviving singleton after removal", function()
            layout:Update({first, second}, 1)
            layout:Remove(first.frame)
            assert.are.equal(0, first.frame.point[4])
            assert.is_nil(first.frame.OnWorldMapPinUpdated)
            first.frame.polygonMarker = nil
            layout:Update({second}, 1)
            assert.are.equal(0, second.frame.point[4])
            layout:Clear()
            assert.is_nil(second.frame.OnWorldMapPinUpdated)
            assert.are.same({}, layout.owned)
        end)

        it("suspends presentation on hide and restores the same slots on show", function()
            layout:Update({first, second}, 1)
            layout:SetEnabled(false)
            assert.are.equal(0, first.frame.point[4])
            first.frame:OnWorldMapPinUpdated(first.frame.parent)
            assert.are.equal(0, first.frame.point[4])
            layout:SetEnabled(true)
            assert.are_near(-5.6, first.frame.point[4], 0.000001)
        end)

        it("does not reanchor a recycled ordinary icon or erase a later callback", function()
            layout:Update({first, second}, 1)
            local staleCallback = first.frame.OnWorldMapPinUpdated
            local replacement = function() end
            first.frame.polygonMarker = nil
            first.frame.OnWorldMapPinUpdated = replacement
            first.frame.point = {"TOPLEFT", {}, "TOPLEFT", 55, 66}
            staleCallback(first.frame, first.frame.parent)
            layout:Clear()
            assert.are.equal("TOPLEFT", first.frame.point[1])
            assert.are.equal(55, first.frame.point[4])
            assert.are.equal(replacement, first.frame.OnWorldMapPinUpdated)
        end)

        it("removes old ownership when original coordinates become invalid", function()
            layout:Update({first, second}, 1)
            first.frame.x = -1
            layout:Update({first, second}, 1)
            assert.are.equal(0, first.frame.point[4])
            assert.is_nil(first.frame.OnWorldMapPinUpdated)
            assert.are.equal(0, second.frame.point[4])
        end)
    end)
end)
