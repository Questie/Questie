dofile("setupTests.lua")

describe("JourneyNameColors", function()
    ---@type JourneyNameColors
    local JourneyNameColors
    local npcs, items, originals

    ---@param name string
    ---@return table color Like Blizzard's colors, which wrap text in their color code
    local function Color(name)
        return {WrapTextInColorCode = function(_, text) return "<" .. name .. ">" .. text end}
    end

    before_each(function()
        originals = {}
        for _, key in ipairs({"RED_FONT_COLOR", "GREEN_FONT_COLOR", "YELLOW_FONT_COLOR", "NORMAL_FONT_COLOR", "ITEM_QUALITY_COLORS"}) do
            originals[key] = _G[key]
        end
        _G.RED_FONT_COLOR, _G.GREEN_FONT_COLOR, _G.YELLOW_FONT_COLOR = Color("red"), Color("green"), Color("yellow")
        _G.NORMAL_FONT_COLOR = Color("gold")
        _G.ITEM_QUALITY_COLORS = {[1] = {color = Color("white")}, [4] = {color = Color("epic")}}

        npcs, items = {}, {}
        QuestieLoader:ImportModule("QuestieDB").QueryNPCSingle = function(id, key)
            return npcs[id] and npcs[id][key]
        end
        QuestieLoader:ImportModule("QuestieCompat").GetItemInfo = function(id)
            if items[id] then return "Item", "link", items[id] end
        end
        QuestieLoader:ImportModule("QuestiePlayer").faction = "Alliance"

        dofile("Modules/Journey/JourneyNameColors.lua")
        JourneyNameColors = QuestieLoader:ImportModule("JourneyNameColors")
    end)

    after_each(function()
        for key, value in pairs(originals) do
            _G[key] = value
        end
    end)

    describe("an NPC", function()
        it("should be red when it is hostile to both factions", function()
            npcs[1] = {factionID = 14}

            assert.are.equal("<red>Kobold", JourneyNameColors.Npc(1, "Kobold"))
        end)

        it("should be green when it belongs to the faction of the player, and red for the other faction", function()
            npcs[1], npcs[2] = {factionID = 12, friendlyToFaction = "A"}, {factionID = 29, friendlyToFaction = "H"}

            assert.are.equal("<green>Guard", JourneyNameColors.Npc(1, "Guard"))
            assert.are.equal("<red>Grunt", JourneyNameColors.Npc(2, "Grunt"))

            QuestieLoader:ImportModule("QuestiePlayer").faction = "Horde"
            assert.are.equal("<red>Guard", JourneyNameColors.Npc(1, "Guard"))
            assert.are.equal("<green>Grunt", JourneyNameColors.Npc(2, "Grunt"))
        end)

        it("should be yellow when it is friendly to both factions, unless it is friendly to everyone", function()
            npcs[1] = {factionID = 189, friendlyToFaction = "AH"} -- A boar
            npcs[2] = {factionID = 120, friendlyToFaction = "AH"} -- Booty Bay
            npcs[3] = {factionID = 35, friendlyToFaction = "AH"}

            assert.are.equal("<yellow>Stonetusk Boar", JourneyNameColors.Npc(1, "Stonetusk Boar"))
            assert.are.equal("<yellow>Baron Revilgaz", JourneyNameColors.Npc(2, "Baron Revilgaz"))
            assert.are.equal("<green>Greatfather Winter", JourneyNameColors.Npc(3, "Greatfather Winter"))
        end)
    end)

    it("should show objects in gold, like other names", function()
        assert.are.equal("<gold>Chest", JourneyNameColors.Object("Chest"))
    end)

    describe("an item", function()
        it("should be in the color of its quality", function()
            items[1], items[2] = 4, 1

            assert.are.equal("<epic>Thunderfury", JourneyNameColors.Item(1, "Thunderfury"))
            assert.are.equal("<white>Linen Cloth", JourneyNameColors.Item(2, "Linen Cloth"))
        end)

        it("should be as it is while the client doesn't know it yet", function()
            assert.are.equal("Unknown", JourneyNameColors.Item(3, "Unknown"))
        end)
    end)
end)
