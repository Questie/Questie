dofile("setupTests.lua")

describe("IconHighlight", function()
    ---@type IconHighlight
    local IconHighlight
    local pins, enumerations, savedLibStub

    -- A texture keeping its color as QuestieFrame's own SetVertexColor does, and its anchors.
    local function Texture(alpha)
        local texture = {r = 1, g = 1, b = 1, a = alpha}
        function texture:SetVertexColor(r, g, b, a) self.r, self.g, self.b, self.a = r, g, b, a end
        function texture:ClearAllPoints() self.points = {} end
        function texture:SetPoint(point, relativeTo, relativePoint) self.points[#self.points + 1] = {point, relativeTo, relativePoint} end
        function texture:SetAllPoints(frame) self.points = {{"all", frame}} end
        function texture:SetSize(width, height) self.width, self.height = width, height end
        return texture
    end

    local function MapIcon(data, alpha)
        local icon = {data = data, texture = Texture(alpha), glowTexture = Texture(alpha), width = 10, height = 10}
        icon.texture.points = {{"all", icon}}
        function icon:GetWidth() return self.width end
        function icon:GetHeight() return self.height end
        function icon:GlowUpdate() end
        return icon
    end

    ---The picture's size, or nil while it fills the icon.
    local function Size(icon)
        local points = icon.texture.points
        if #points == 1 and points[1][1] == "all" and points[1][2] == icon then return nil end
        assert.are.same({{"CENTER", icon, "CENTER"}}, points)
        return icon.texture.width
    end

    before_each(function()
        pins, enumerations = {}, 0
        savedLibStub = _G.LibStub
        _G.LibStub = function()
            return {worldmapProvider = {GetMap = function()
                return {EnumeratePinsByTemplate = function()
                    enumerations = enumerations + 1
                    local i = 0
                    return function()
                        i = i + 1
                        return pins[i] and {icon = pins[i]}
                    end
                end}
            end}}
        end
        dofile("Modules/Map/IconHighlight.lua")
        IconHighlight = QuestieLoader:ImportModule("IconHighlight")
    end)

    after_each(function()
        _G.LibStub = savedLibStub
    end)

    describe("hovering an icon", function()
        it("grows it, lights up its quest's world map icons and dims all others, then puts them back", function()
            local data = {Id = 123, Type = "monster"}
            local icon = MapIcon(data, 1)
            -- Faded by the tracker's focus.
            local sibling = MapIcon({Id = 123, Type = "item"}, 0.3)
            sibling.faded = true
            local giver = MapIcon({Id = 123, Type = "available"}, 1)
            local hidden = MapIcon({Id = 123, Type = "item"}, 1)
            hidden.hidden = true
            local otherQuest = MapIcon({Id = 456, Type = "monster"}, 1)
            local fadedOther = MapIcon({Id = 456, Type = "item"}, 0.3)
            local note = MapIcon({Type = "manual"}, 1)
            pins = {icon, sibling, giver, hidden, otherQuest, fadedOther, note}

            IconHighlight.StartHover(icon)

            assert.are.equal(13.5, Size(icon))
            assert.is_nil(Size(sibling))
            -- The quest's icons show fully opaque with their glow ring grown.
            assert.are.same({1, 1.5}, {icon.texture.a, icon.glowScale})
            assert.are.same({1, 1, 1.5}, {sibling.texture.a, sibling.glowTexture.a, sibling.glowScale})
            -- Its giver and turn-in, and hidden icons, stay as they are.
            assert.are.same({1, nil}, {giver.texture.a, giver.glowScale})
            assert.are.equal(1, hidden.texture.a)
            -- All others dim, the glow ring with the icon, and none brightens.
            assert.are.same({0.5, 0.5, nil}, {otherQuest.texture.a, otherQuest.glowTexture.a, otherQuest.glowScale})
            assert.are.equal(0.3, fadedOther.texture.a)
            assert.are.equal(0.5, note.texture.a)

            IconHighlight.EndHover(icon, data)

            assert.is_nil(Size(icon))
            assert.are.same({1, nil}, {icon.texture.a, icon.glowScale})
            assert.are.same({0.3, 0.3, nil}, {sibling.texture.a, sibling.glowTexture.a, sibling.glowScale})
            assert.are.same({1, 1}, {otherQuest.texture.a, otherQuest.glowTexture.a})
            assert.are.equal(0.3, fadedOther.texture.a)
            assert.are.equal(1, note.texture.a)
        end)

        it("only grows a quest giver, turn-in, note or minimap icon: they put no quest in the spotlight", function()
            local other = MapIcon({Id = 456, Type = "monster"}, 1)
            local giver = MapIcon({Id = 123, Type = "available"}, 1)
            local minimapIcon = MapIcon({Id = 123, Type = "monster"}, 0.6)
            minimapIcon.miniMapIcon = true
            pins = {giver, other}

            for _, icon in ipairs({giver, MapIcon({Id = 123, Type = "complete"}, 1), MapIcon({Type = "manual"}, 1), minimapIcon}) do
                IconHighlight.StartHover(icon)
                assert.are.equal(13.5, Size(icon))
                IconHighlight.EndHover(icon, icon.data)
            end

            assert.are.equal(0, enumerations)
            assert.are.equal(1, other.texture.a)
            -- A minimap icon's own opacity, its distance fade, stays.
            assert.are.equal(0.6, minimapIcon.texture.a)
        end)

        it("keeps the spotlight for as long as any hover of its quest lasts", function()
            local first, second = {Id = 123, Type = "monster"}, {Id = 123, Type = "item"}
            local icon, sibling, other = MapIcon(first, 1), MapIcon(second, 1), MapIcon({Id = 456, Type = "item"}, 1)
            pins = {icon, sibling, other}

            -- A path's hover starts the icon's hover, then the cursor reaches the icon with no end between;
            -- the gamepad's hover still shows for a moment as the mouse starts another.
            IconHighlight.StartHover(icon)
            IconHighlight.StartHover(icon)
            IconHighlight.StartHover(sibling)
            assert.are.equal(1, enumerations)

            IconHighlight.EndHover(icon, first)
            assert.is_nil(Size(icon))
            assert.are.equal(13.5, Size(sibling))
            assert.are.equal(0.5, other.texture.a)
            IconHighlight.EndHover(sibling, second)
            assert.are.equal(1, other.texture.a)
        end)

        it("puts one quest's icons back before another quest's spotlight starts", function()
            local data, otherData = {Id = 123, Type = "monster"}, {Id = 456, Type = "item"}
            local icon, otherQuest = MapIcon(data, 1), MapIcon(otherData, 0.3)
            otherQuest.faded = true
            pins = {icon, otherQuest}

            IconHighlight.StartHover(icon)
            IconHighlight.StartHover(otherQuest)
            assert.are.same({1, 1.5}, {otherQuest.texture.a, otherQuest.glowScale})
            -- Dimmed with the rest, though still grown until its own hover ends.
            assert.are.same({0.5, 13.5}, {icon.texture.a, Size(icon)})

            -- The first hover ending late changes nothing of the other quest's spotlight.
            IconHighlight.EndHover(icon, data)
            assert.are.same({0.5, nil, nil}, {icon.texture.a, Size(icon), icon.glowScale})
            IconHighlight.EndHover(otherQuest, otherData)
            assert.are.equal(1, icon.texture.a)
            assert.are.equal(0.3, otherQuest.texture.a)
        end)

        it("keeps a fade, a redraw or another data's look made during the spotlight", function()
            local data = {Id = 123, Type = "monster"}
            local icon, sibling = MapIcon(data, 1), MapIcon({Id = 123, Type = "item"}, 1)
            -- Faded by the tracker's focus, at a fade level of 0.8.
            local other, recycled = MapIcon({Id = 456, Type = "item"}, 0.8), MapIcon({Id = 789, Type = "item"}, 1)
            other.faded = true
            pins = {icon, sibling, other, recycled}
            IconHighlight.StartHover(icon)

            -- The tracker's focus fades the sibling; a progress update draws the other icon anew; the
            -- pool hands the last out for other data.
            sibling.faded = true
            sibling.texture:SetVertexColor(1, 1, 1, 0.3)
            other.texture:SetVertexColor(1, 1, 1, 1)
            recycled.data = {Id = 7, Type = "complete"}
            recycled.texture:SetVertexColor(1, 1, 1, 0.5)
            IconHighlight.EndHover(icon, data)

            assert.are.equal(0.3, sibling.texture.a)
            assert.are.equal(1, other.texture.a)
            assert.are.equal(0.5, recycled.texture.a)
        end)
    end)

    describe("Mark", function()
        it("grows one icon for as long as any mark holds it, its own hover's included, keeping its opacity", function()
            local data = {Id = 123, Type = "monster"}
            local icon, sibling = MapIcon(data, 0.6), MapIcon({Id = 123, Type = "item"}, 1)
            icon.miniMapIcon = true
            local area = {}

            -- A quest area's hover grows its marker alone.
            IconHighlight.Mark(icon, area)
            assert.are.same({13.5, 0.6, 1.5}, {Size(icon), icon.texture.a, icon.glowScale})
            assert.is_nil(Size(sibling))
            -- The cursor reaches the marker, and then the area's hover ends.
            IconHighlight.StartHover(icon)
            IconHighlight.Unmark(icon, area)
            assert.are.equal(13.5, Size(icon))
            IconHighlight.EndHover(icon, data)
            assert.are.same({nil, 0.6, nil}, {Size(icon), icon.texture.a, icon.glowScale})
        end)

        it("follows a resize when marked again, and leaves an icon the pool handed out to its new marks", function()
            local icon = MapIcon({Id = 123, Type = "monster"}, 1)
            local area, other = {}, {}
            IconHighlight.Mark(icon, area)
            icon.width, icon.height = 20, 20 -- The map zooms.
            IconHighlight.Mark(icon, area)
            assert.are.equal(27, Size(icon))

            -- The area's mark was for the icon's old data: it no longer holds the icon.
            icon.data = {Id = 7, Type = "item"}
            IconHighlight.Mark(icon, other)
            IconHighlight.Unmark(icon, other)
            assert.is_nil(Size(icon))
            IconHighlight.Unmark(icon, area)
            assert.is_nil(Size(icon))
        end)
    end)

    describe("Forget", function()
        it("shrinks an unloading icon back at once, though its hover and marks have not ended", function()
            local icon, marker = MapIcon({Id = 123, Type = "monster"}, 1), MapIcon({Id = 456, Type = "item"}, 1)
            pins = {icon, marker}
            IconHighlight.StartHover(icon)
            IconHighlight.Mark(marker, {})

            IconHighlight.Forget(icon)
            IconHighlight.Forget(marker)

            assert.are.same({nil, nil}, {Size(icon), icon.glowScale})
            assert.are.same({nil, nil}, {Size(marker), marker.glowScale})
        end)
    end)
end)
