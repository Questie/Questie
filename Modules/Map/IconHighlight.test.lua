dofile("setupTests.lua")

describe("IconHighlight", function()
    ---@type IconHighlight
    local IconHighlight
    local pins, enumerations, mapShown, savedLibStub

    -- A texture keeping its color as QuestieFrame's own SetVertexColor does.
    local function Texture(alpha)
        local texture = {r = 1, g = 1, b = 1, a = alpha}
        function texture:SetVertexColor(r, g, b, a) self.r, self.g, self.b, self.a = r, g, b, a end
        return texture
    end

    -- QuestieFrame sizes the picture and ring from the scales IconHighlight sets, as GlowUpdate runs.
    local function MapIcon(data, alpha)
        local icon = {data = data, texture = Texture(alpha), glowTexture = Texture(alpha)}
        function icon:GlowUpdate() self.fitted = {self.pictureScale, self.glowScale} end
        return icon
    end

    ---What the icon was last fitted to: its picture's growth and its ring's.
    local function Fitted(icon)
        return icon.fitted or {}
    end

    before_each(function()
        pins, enumerations, mapShown = {}, 0, true
        savedLibStub = _G.LibStub
        _G.LibStub = function()
            return {worldmapProvider = {GetMap = function()
                return {IsShown = function() return mapShown end, EnumeratePinsByTemplate = function()
                    enumerations = enumerations + 1
                    local i = 0
                    return function()
                        i = i + 1
                        return pins[i] and {icon = pins[i]}
                    end
                end}
            end}}
        end
        -- Records the level each icon was last drawn at: in front while grown.
        QuestieLoader:ImportModule("QuestieMap").utils = {SetDrawOrder = function(icon)
            icon.drawnInFront = icon.pictureScale ~= nil
            icon.drawOrders = (icon.drawOrders or 0) + 1
        end}
        dofile("Modules/Map/IconHighlight.lua")
        IconHighlight = QuestieLoader:ImportModule("IconHighlight")
    end)

    after_each(function()
        _G.LibStub = savedLibStub
    end)

    describe("hovering an icon", function()
        it("grows it, lights up its quest's objective icons and dims other quests', then puts them back", function()
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
            local otherGiver, otherTurnIn = MapIcon({Id = 456, Type = "available"}, 1), MapIcon({Id = 789, Type = "complete"}, 1)
            -- A note's ID is its NPC's, here the same number as the quest's.
            local note = MapIcon({Id = 123, Type = "manual"}, 1)
            pins = {icon, sibling, giver, hidden, otherQuest, fadedOther, otherGiver, otherTurnIn, note}

            IconHighlight.StartHover(icon)

            assert.are.same({1.35, 1.5}, Fitted(icon))
            assert.are.equal(1, icon.texture.a)
            -- The quest's icons show fully opaque with their glow ring grown, staying in their place.
            assert.are.same({nil, 1.5}, Fitted(sibling))
            assert.is_nil(sibling.drawOrders)
            assert.are.same({1, 1}, {sibling.texture.a, sibling.glowTexture.a})
            -- Hidden icons stay as they are.
            assert.are.equal(1, hidden.texture.a)
            -- Other quests' objective icons dim, the glow ring with the icon, and none brightens.
            assert.are.same({0.5, 0.5}, {otherQuest.texture.a, otherQuest.glowTexture.a})
            assert.are.same({}, Fitted(otherQuest))
            assert.are.equal(0.3, fadedOther.texture.a)
            -- Quest givers, turn-ins and notes are a layer of their own: they keep their look, of any quest.
            for _, untouched in ipairs({giver, otherGiver, otherTurnIn, note}) do
                assert.are.same({1, 1}, {untouched.texture.a, untouched.glowTexture.a})
                assert.are.same({}, Fitted(untouched))
            end

            IconHighlight.EndHover(icon, data)

            assert.are.same({}, Fitted(icon))
            assert.are.equal(1, icon.texture.a)
            assert.are.same({}, Fitted(sibling))
            assert.are.same({0.3, 0.3}, {sibling.texture.a, sibling.glowTexture.a})
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
                assert.are.same({1.35, 1.5}, Fitted(icon))
                IconHighlight.EndHover(icon, icon.data)
                assert.are.same({}, Fitted(icon))
            end

            assert.are.equal(0, enumerations)
            assert.are.equal(1, other.texture.a)
            -- A minimap icon's own opacity, its distance fade, stays.
            assert.are.equal(0.6, minimapIcon.texture.a)
        end)

        it("lights and dims nothing on a closed world map, which keeps the last map's icons", function()
            local data = {Id = 123, Type = "monster"}
            local icon, other = MapIcon(data, 1), MapIcon({Id = 456, Type = "item"}, 1)
            pins = {icon, other}
            mapShown = false

            IconHighlight.StartHover(icon)

            assert.are.equal(0, enumerations)
            assert.are.equal(1, other.texture.a)
            assert.are.same({1.35, 1.5}, Fitted(icon))
            IconHighlight.EndHover(icon, data)
            assert.are.same({}, Fitted(icon))
        end)

        it("keeps the spotlight for as long as any icon of its quest is hovered", function()
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
            assert.are.same({nil, 1.5}, Fitted(icon))
            assert.are.same({1.35, 1.5}, Fitted(sibling))
            assert.are.equal(0.5, other.texture.a)
            IconHighlight.EndHover(sibling, second)
            assert.are.equal(1, other.texture.a)
        end)

        it("tells apart the hovers of icons sharing one data table, as an NPC's spawns do", function()
            local data = {Id = 123, Type = "monster"}
            local spawn, otherSpawn, other = MapIcon(data, 1), MapIcon(data, 1), MapIcon({Id = 456, Type = "item"}, 1)
            pins = {spawn, otherSpawn, other}
            -- A tracker preview hovers both.
            IconHighlight.StartHover(spawn)
            IconHighlight.StartHover(otherSpawn)

            IconHighlight.EndHover(spawn, data)
            assert.are.same({nil, 1.5}, Fitted(spawn))
            assert.are.same({1.35, 1.5}, Fitted(otherSpawn))
            assert.are.equal(0.5, other.texture.a)
            IconHighlight.EndHover(otherSpawn, data)
            assert.are.equal(1, other.texture.a)
        end)

        it("puts one quest's icons back before another quest's spotlight starts", function()
            local data, otherData = {Id = 123, Type = "monster"}, {Id = 456, Type = "item"}
            local icon, otherQuest = MapIcon(data, 1), MapIcon(otherData, 0.3)
            otherQuest.faded = true
            pins = {icon, otherQuest}

            IconHighlight.StartHover(icon)
            IconHighlight.StartHover(otherQuest)
            assert.are.same({1, 1.5}, {otherQuest.texture.a, Fitted(otherQuest)[2]})
            -- Dimmed with the rest, though still grown until its own hover ends.
            assert.are.same({0.5, 1.35}, {icon.texture.a, Fitted(icon)[1]})

            -- The first hover ending late changes nothing of the other quest's spotlight.
            IconHighlight.EndHover(icon, data)
            assert.are.same({}, Fitted(icon))
            assert.are.equal(0.5, icon.texture.a)
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

            -- A quest area's hover grows its marker alone, drawn in front of the icons around it.
            IconHighlight.Mark(icon, area)
            assert.are.same({1.35, 1.5}, Fitted(icon))
            assert.is_true(icon.drawnInFront)
            assert.are.equal(0.6, icon.texture.a)
            assert.are.same({}, Fitted(sibling))
            -- The cursor reaches the marker, and then the area's hover ends.
            IconHighlight.StartHover(icon)
            IconHighlight.Unmark(icon, area)
            assert.are.same({1.35, 1.5}, Fitted(icon))
            IconHighlight.EndHover(icon, data)
            assert.are.same({}, Fitted(icon))
            assert.is_false(icon.drawnInFront)
            assert.are.equal(0.6, icon.texture.a)
            -- Drawn anew only as it grew and as it shrank back.
            assert.are.equal(2, icon.drawOrders)
        end)

        it("lets a mark held for an icon's old data go once the pool hands it out again", function()
            local icon = MapIcon({Id = 123, Type = "monster"}, 1)
            local area, other = {}, {}
            IconHighlight.Mark(icon, area)

            icon.data = {Id = 7, Type = "item"}
            IconHighlight.Mark(icon, other)
            IconHighlight.Unmark(icon, other)
            assert.are.same({}, Fitted(icon))
            IconHighlight.Unmark(icon, area)
            assert.are.same({}, Fitted(icon))
        end)
    end)

    describe("Forget", function()
        it("shrinks an unloading icon back at once, though its hover and marks have not ended", function()
            local icon, marker = MapIcon({Id = 123, Type = "monster"}, 1), MapIcon({Id = 456, Type = "item"}, 1)
            pins = {icon, marker}
            IconHighlight.StartHover(icon)
            local area = {}
            IconHighlight.Mark(marker, area)

            IconHighlight.Forget(icon)
            IconHighlight.Forget(marker)

            assert.are.same({}, Fitted(icon))
            assert.are.same({}, Fitted(marker))
            -- The pool hands the marker out for another quest, whose spotlight lights it without growing it.
            IconHighlight.EndHover(icon, icon.data)
            marker.data = {Id = 7, Type = "item"}
            local sibling = MapIcon({Id = 7, Type = "monster"}, 1)
            pins = {sibling, marker}
            IconHighlight.StartHover(sibling)
            assert.are.same({nil, 1.5}, Fitted(marker))
        end)
    end)
end)
