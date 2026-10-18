dofile("setupTests.lua")

describe("IconHighlight", function()
    ---@type IconHighlight
    local IconHighlight
    local pins, enumerations, savedLibStub

    -- A world map icon whose texture keeps its color, as QuestieFrame's own SetVertexColor does.
    local function MapIcon(data, color)
        local texture = {r = color[1], g = color[2], b = color[3], a = color[4]}
        function texture:SetVertexColor(r, g, b, a) self.r, self.g, self.b, self.a = r, g, b, a end
        return {data = data, texture = texture}
    end

    local function Color(icon)
        return {icon.texture.r, icon.texture.g, icon.texture.b, icon.texture.a}
    end

    before_each(function()
        Questie.db.profile = {}
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

    describe("Spotlight", function()
        it("lights up the hovered quest's world map icons, not its givers, turn-ins, hidden icons or other quests", function()
            local data = {Id = 123, Type = "monster"}
            local icon = MapIcon(data, {1, 0.5, 0, 1})
            local sibling = MapIcon({Id = 123, Type = "item"}, {0, 1, 0, 1})
            local giver = MapIcon({Id = 123, Type = "available"}, {1, 1, 0, 1})
            local hidden = MapIcon({Id = 123, Type = "item"}, {0, 0, 1, 1})
            hidden.hidden = true
            local otherQuest = MapIcon({Id = 456, Type = "monster"}, {1, 0, 0, 1})
            pins = {icon, sibling, giver, hidden, otherQuest}

            IconHighlight.Spotlight(icon)

            -- Without objective colors, lit icons turn blueish.
            assert.are.same({0.6, 1, 1, 1}, Color(icon))
            assert.are.same({0.6, 1, 1, 1}, Color(sibling))
            assert.are.same({1, 1, 0, 1}, Color(giver))
            assert.are.same({0, 0, 1, 1}, Color(hidden))
            assert.are.same({1, 0, 0, 1}, Color(otherQuest))
            IconHighlight.EndSpotlight(data)
            assert.are.same({1, 0.5, 0, 1}, Color(icon))
            assert.are.same({0, 1, 0, 1}, Color(sibling))

            -- A minimap icon's hover lights nothing.
            local minimapIcon = MapIcon({Id = 123, Type = "monster"}, {1, 1, 1, 1})
            minimapIcon.miniMapIcon = true
            IconHighlight.Spotlight(minimapIcon)
            assert.are.same({1, 0.5, 0, 1}, Color(icon))
        end)

        it("keeps the colors to restore when the hover starts again before it ends", function()
            local data = {Id = 123, Type = "monster"}
            local icon = MapIcon(data, {1, 0.5, 0, 1})
            pins = {icon}

            -- A path's hover starts it, then the icon's own hover, with no end between.
            IconHighlight.Spotlight(icon)
            IconHighlight.Spotlight(icon)
            IconHighlight.EndSpotlight(data)

            assert.are.same({1, 0.5, 0, 1}, Color(icon))
        end)

        it("lights a quest once for as long as any of its overlapping hovers lasts", function()
            local first, second = {Id = 123, Type = "monster"}, {Id = 123, Type = "item"}
            local icon, sibling = MapIcon(first, {1, 0.5, 0, 1}), MapIcon(second, {0, 1, 0, 1})
            pins = {icon, sibling}

            -- The gamepad's hover still shows for a moment as the mouse starts another; a tracker
            -- preview hovers all of an objective's icons at once.
            IconHighlight.Spotlight(icon)
            IconHighlight.Spotlight(sibling)
            assert.are.equal(1, enumerations)
            IconHighlight.EndSpotlight(first)
            assert.are.same({0.6, 1, 1, 1}, Color(sibling))
            IconHighlight.EndSpotlight(second)

            assert.are.same({1, 0.5, 0, 1}, Color(icon))
            assert.are.same({0, 1, 0, 1}, Color(sibling))
        end)

        it("puts one quest's icons back before another quest's spotlight lights its icons", function()
            local data, otherData = {Id = 123, Type = "monster"}, {Id = 456, Type = "item"}
            local icon, otherQuest = MapIcon(data, {1, 0.5, 0, 1}), MapIcon(otherData, {0, 1, 0, 1})
            pins = {icon, otherQuest}
            IconHighlight.Spotlight(icon)
            IconHighlight.Spotlight(otherQuest)
            assert.are.same({1, 0.5, 0, 1}, Color(icon))
            assert.are.same({0.6, 1, 1, 1}, Color(otherQuest))

            IconHighlight.EndSpotlight(data)
            assert.are.same({0.6, 1, 1, 1}, Color(otherQuest))
            IconHighlight.EndSpotlight(otherData)
            assert.are.same({0, 1, 0, 1}, Color(otherQuest))
        end)

        it("keeps a fade or a redraw made during the spotlight when putting icons back", function()
            local data = {Id = 123, Type = "monster"}
            local icon, sibling = MapIcon(data, {1, 0.5, 0, 1}), MapIcon({Id = 123, Type = "item"}, {0, 1, 0, 1})
            pins = {icon, sibling}
            IconHighlight.Spotlight(icon)
            -- FadeOut keeps the lit color and lowers the opacity; a redraw sets the icon's own color.
            icon.faded = true
            icon.texture:SetVertexColor(0.6, 1, 1, 0.3)
            sibling.texture:SetVertexColor(0.2, 0.2, 0.2, 1)

            IconHighlight.EndSpotlight(data)

            assert.are.same({1, 0.5, 0, 0.3}, Color(icon))
            assert.are.same({0.2, 0.2, 0.2, 1}, Color(sibling))
        end)

        it("leaves an icon the pool handed out for other data since with its own color", function()
            local data = {Id = 123, Type = "monster"}
            local icon, sibling = MapIcon(data, {1, 0.5, 0, 1}), MapIcon({Id = 123, Type = "item"}, {0, 1, 0, 1})
            pins = {icon, sibling}
            IconHighlight.Spotlight(icon)
            sibling.data = {Id = 7, Type = "complete"}
            sibling.texture:SetVertexColor(1, 1, 0, 1)

            IconHighlight.EndSpotlight(data)

            assert.are.same({1, 0.5, 0, 1}, Color(icon))
            assert.are.same({1, 1, 0, 1}, Color(sibling))
        end)

        it("ends nothing for a hover that lit nothing", function()
            local icon = MapIcon({Id = 123, Type = "monster"}, {1, 0.5, 0, 1})
            pins = {icon}
            IconHighlight.Spotlight(icon)

            IconHighlight.EndSpotlight({Id = 123, Type = "monster"})

            assert.are.same({0.6, 1, 1, 1}, Color(icon))
        end)
    end)

    describe("Mark", function()
        it("lights one icon for as long as any light holds it, its quest's spotlight included", function()
            local data = {Id = 123, Type = "monster"}
            local icon, sibling = MapIcon(data, {1, 0.5, 0, 1}), MapIcon({Id = 123, Type = "item"}, {0, 1, 0, 1})
            pins = {icon, sibling}
            local area = {}

            -- A quest area's hover marks its marker alone.
            IconHighlight.Mark(icon, area)
            assert.are.same({0.6, 1, 1, 1}, Color(icon))
            assert.are.same({0, 1, 0, 1}, Color(sibling))
            -- The cursor reaches the marker: its quest lights up too, and then the area's hover ends.
            IconHighlight.Spotlight(icon)
            IconHighlight.Unmark(icon, area)
            assert.are.same({0.6, 1, 1, 1}, Color(icon))
            IconHighlight.EndSpotlight(data)
            assert.are.same({1, 0.5, 0, 1}, Color(icon))
            assert.are.same({0, 1, 0, 1}, Color(sibling))

            -- And the other way round.
            IconHighlight.Spotlight(icon)
            IconHighlight.Mark(icon, area)
            IconHighlight.EndSpotlight(data)
            assert.are.same({0.6, 1, 1, 1}, Color(icon))
            IconHighlight.Unmark(icon, area)
            assert.are.same({1, 0.5, 0, 1}, Color(icon))

            -- A mark left on an icon the pool hands out for other data has no say over its new color.
            IconHighlight.Mark(icon, area)
            icon.data = {Id = 7, Type = "item"}
            icon.texture:SetVertexColor(0, 0, 1, 1)
            local other = {}
            IconHighlight.Mark(icon, other)
            assert.are.same({0.6, 1, 1, 1}, Color(icon))
            IconHighlight.Unmark(icon, area)
            IconHighlight.Unmark(icon, other)
            assert.are.same({0, 0, 1, 1}, Color(icon))
        end)

        it("keeps an icon's own opacity, such as a minimap icon's distance fade", function()
            local icon = MapIcon({Id = 123, Type = "monster"}, {1, 0.5, 0, 0.5})
            icon.miniMapIcon = true
            local area = {}
            IconHighlight.Mark(icon, area)
            assert.are.same({0.6, 1, 1, 0.5}, Color(icon))
            -- The player walks into fade range meanwhile.
            icon.texture:SetVertexColor(0.6, 1, 1, 1)
            IconHighlight.Unmark(icon, area)
            assert.are.same({1, 0.5, 0, 1}, Color(icon))

            -- Minimap icons follow the minimap's objective color setting.
            Questie.db.profile.questMinimapObjectiveColors = true
            IconHighlight.Mark(icon, area)
            assert.are.same({1, 1, 1, 1}, Color(icon))
        end)

        it("puts back a light a redraw undid when lit again", function()
            local data = {Id = 123, Type = "monster"}
            local icon = MapIcon(data, {1, 0.5, 0, 1})
            pins = {icon}
            local area = {}
            IconHighlight.Mark(icon, area)
            icon.texture:SetVertexColor(1, 0.5, 0, 1) -- A progress update draws the marker anew.
            IconHighlight.Mark(icon, area)
            assert.are.same({0.6, 1, 1, 1}, Color(icon))
            -- So does its quest's spotlight starting, which also shows it fully opaque.
            icon.texture:SetVertexColor(1, 0.5, 0, 0.4)
            IconHighlight.Spotlight(icon)
            assert.are.same({0.6, 1, 1, 1}, Color(icon))
            IconHighlight.EndSpotlight(data)
            IconHighlight.Unmark(icon, area)
            assert.are.same({1, 0.5, 0, 1}, Color(icon))
        end)
    end)
end)
