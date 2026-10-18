dofile("setupTests.lua")

describe("ObjectivePreview", function()
    local ObjectivePreview
    local originals
    local frames, textures, tooltip
    local cursorX, cursorY, focus, gamepad

    local BLUE, SCARLET = {80 / 255, 113 / 255, 1}, {1, 38 / 255, 0}
    local function _Square(minimum, maximum)
        return {{x = minimum, y = minimum}, {x = maximum, y = minimum}, {x = maximum, y = maximum}, {x = minimum, y = maximum}}
    end
    -- Two objectives in percent of the preview. The kobolds' area (20 to 40 both ways) overlaps the wolves' (25 to
    -- 75), whose area holds the kobolds' marker; the wolves also have a stray marker without an area.
    local KOBOLDS = {questId = 7, quest = "Kobold Camp Cleanup", level = 2, npc = 6, target = "Kobold Vermin", needed = 10,
        icon = "slay", color = BLUE, icons = {{x = 10, y = 10}, {x = 15, y = 12}},
        clusters = {{x = 30, y = 30, outline = _Square(20, 40)}}}
    local WOLVES = {questId = 33, quest = "Wolves Across the Border", level = 2, item = 750, target = "Tough Wolf Meat",
        needed = 8, icon = "loot", color = SCARLET, icons = {{x = 90, y = 90}},
        clusters = {{x = 60, y = 60, outline = _Square(25, 75)}, {x = 90, y = 10}}}
    local function _Area(image) return function() return {image = image, objectives = {KOBOLDS, WOLVES}} end end
    local START_AREAS = {
        races = {Human = "Northshire", Dwarf = "ColdridgeValley"},
        areas = {Northshire = _Area("northshire"), ColdridgeValley = _Area("coldridge"), ValleyOfTrials = _Area("trials")},
    }
    -- Which art set each client's TOC loads: Cataclysm rebuilt the start areas.
    local ART_SETS = {
        ["Questie_Vanilla.toc"] = "Classic", ["Questie_TBC.toc"] = "Classic", ["Questie_Wrath.toc"] = "Classic",
        ["Questie_Camelot.toc"] = "Classic", ["Questie_Cata.toc"] = "Cata", ["Questie_Mists.toc"] = "Cata",
    }

    local function _CreateTexture(frame)
        local texture = {parent = frame}
        textures[#textures + 1] = texture
        function texture:SetTexture(path) self.path = path end
        function texture:SetSize(width, height) self.width, self.height = width, height end
        function texture:SetVertexColor(...) self.color = {...} end
        function texture:SetPoint() end
        function texture:SetAllPoints() end
        function texture:SetParent(parent) self.parent = parent end
        function texture:SetSnapToPixelGrid() end
        function texture:SetTexelSnappingBias() end
        function texture:SetVertexOffset() end
        function texture:SetTexCoord() end
        function texture:Show() end
        function texture:Hide() end
        function texture:ClearAllPoints() end
        return texture
    end

    -- Every frame sits at left 100, top 700 at effective scale 2: the preview's point (x, y) in percent is on
    -- screen at ((100 + 2.2x) * 2, (700 - 2.2y) * 2).
    local function _CreateFrame(_kind, _name, parent)
        local frame = {parent = parent, scripts = {}, children = {}, shown = true}
        frames[#frames + 1] = frame
        if parent and parent.children then parent.children[#parent.children + 1] = frame end
        function frame:SetScript(name, callback) self.scripts[name] = callback end
        function frame:Show() self.shown = true end
        function frame:IsShown() return self.shown end
        -- Hiding a frame hides its children with it.
        function frame:Hide()
            local wasShown = self.shown
            self.shown = false
            if not wasShown then return end
            if self.scripts.OnHide then self.scripts.OnHide(self) end
            for _, child in ipairs(self.children) do
                if child.shown and child.scripts.OnHide then child.scripts.OnHide(child) end
            end
        end
        function frame:GetEffectiveScale() return 2 end
        function frame:GetLeft() return 100 end
        function frame:GetTop() return 700 end
        function frame:GetFrameLevel() return 1 end
        function frame:SetFrameLevel() end
        function frame:SetSize() end
        function frame:SetPoint() end
        function frame:SetAllPoints() end
        function frame:ClearAllPoints() end
        function frame:SetClipsChildren() end
        frame.CreateTexture = _CreateTexture
        return frame
    end

    ---Runs one game frame with the cursor on the preview's point, or off it for nil. The preview has the mouse
    ---there unless another frame, `over`, covers it.
    local function _Hover(view, x, y, over)
        focus = over or (x and view or nil)
        if x then cursorX, cursorY = (100 + 2.2 * x) * 2, (700 - 2.2 * y) * 2 end
        for _, frame in ipairs(frames) do
            if frame.scripts.OnUpdate then frame.scripts.OnUpdate(frame) end
        end
    end

    local function _Textures(path)
        local found = {}
        for _, texture in ipairs(textures) do
            if texture.path == path then found[#found + 1] = texture end
        end
        return found
    end

    local function _Alphas(path)
        local alphas = {}
        for _, texture in ipairs(_Textures(path)) do alphas[#alphas + 1] = texture.color[4] end
        return alphas
    end

    local function _Create(style, race, faction)
        _G.UnitRace = function() return "Race", race end
        _G.UnitFactionGroup = function() return faction end
        return ObjectivePreview.Create({}, style)
    end

    before_each(function()
        frames, textures, focus, gamepad = {}, {}, nil, false
        tooltip = {lines = {}}
        function tooltip:SetOwner(owner) self.owner, self.lines, self.shown = owner, {}, false end
        function tooltip:AddLine(text) self.lines[#self.lines + 1] = text end
        function tooltip:Show() self.shown = true end
        function tooltip:Hide() self.shown = false end
        function tooltip:IsOwned(owner) return self.owner == owner end

        originals = {
            CreateFrame = _G.CreateFrame, DrawLine = _G.DrawLine, GameTooltip = _G.GameTooltip, UnitRace = _G.UnitRace,
            UnitFactionGroup = _G.UnitFactionGroup, GetCursorPosition = _G.GetCursorPosition, icons = Questie.icons,
            UPPER_LEFT_VERTEX = _G.UPPER_LEFT_VERTEX, UPPER_RIGHT_VERTEX = _G.UPPER_RIGHT_VERTEX,
            LOWER_LEFT_VERTEX = _G.LOWER_LEFT_VERTEX, LOWER_RIGHT_VERTEX = _G.LOWER_RIGHT_VERTEX,
        }
        _G.CreateFrame = _CreateFrame
        _G.DrawLine = function() end
        _G.UPPER_LEFT_VERTEX, _G.UPPER_RIGHT_VERTEX = "UL", "UR"
        _G.LOWER_LEFT_VERTEX, _G.LOWER_RIGHT_VERTEX = "LL", "LR"
        _G.GameTooltip = tooltip
        _G.GetCursorPosition = function() return cursorX, cursorY end
        Questie.icons = {glow = "glow.blp", slay = "slay.blp", loot = "loot.blp"}

        local QuestieCompat = QuestieLoader:ImportModule("QuestieCompat")
        QuestieCompat.GetMouseFocus = function() return focus end
        QuestieCompat.IsGamepadUIEnabled = function() return gamepad end
        local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
        QuestieLib.PrintDifficultyColor = function(_, _, text) return text end
        -- The client's own names where QuestieDB has them; the wolves' quest has none.
        local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
        QuestieDB.QueryQuestSingle = function(id) if id == 7 then return "Koboldlager säubern" end end
        QuestieDB.QueryNPCSingle = function(id) if id == 6 then return "Koboldungeziefer" end end
        QuestieDB.QueryItemSingle = function() end

        dofile("Modules/Map/Polygon/PolygonRenderer.lua")
        dofile("Modules/Tutorial/ObjectivePreview.lua")
        ObjectivePreview = QuestieLoader:ImportModule("ObjectivePreview")
        ObjectivePreview.startAreas = START_AREAS
    end)

    after_each(function()
        _G.CreateFrame, _G.DrawLine, _G.GameTooltip = originals.CreateFrame, originals.DrawLine, originals.GameTooltip
        _G.UnitRace, _G.UnitFactionGroup, _G.GetCursorPosition = originals.UnitRace, originals.UnitFactionGroup,
            originals.GetCursorPosition
        Questie.icons = originals.icons
        _G.UPPER_LEFT_VERTEX, _G.UPPER_RIGHT_VERTEX = originals.UPPER_LEFT_VERTEX, originals.UPPER_RIGHT_VERTEX
        _G.LOWER_LEFT_VERTEX, _G.LOWER_RIGHT_VERTEX = originals.LOWER_LEFT_VERTEX, originals.LOWER_RIGHT_VERTEX
    end)

    it("previews the player's own start area, or their faction's", function()
        local cases = {
            {race = "Dwarf", faction = "Alliance", image = "coldridge"},
            {race = "BloodElf", faction = "Horde", image = "trials"},
            {race = "Pandaren", faction = "Neutral", image = "northshire"},
        }
        for _, case in ipairs(cases) do
            _Create("icons", case.race, case.faction)
            assert.are_equal(1, #_Textures(case.image), case.race)
        end
    end)

    it("has each client's TOC load its own art set's start areas", function()
        local LoaderUsage = dofile("cli/loaderUsage.lua")
        for toc, artSet in pairs(ART_SETS) do
            local loaded = {}
            for _, path in ipairs(LoaderUsage.ReadTocLuaPaths(toc)) do
                loaded[#loaded + 1] = path:match("^Modules/Tutorial/Previews/(%w+)%.lua$")
            end
            assert.are_same({artSet}, loaded, toc)
        end
    end)

    it("has a generated map for every start area, in both art sets", function()
        local players = {
            {"Human", "Alliance"}, {"Dwarf", "Alliance"}, {"Gnome", "Alliance"}, {"NightElf", "Alliance"}, {"Draenei", "Alliance"},
            {"Orc", "Horde"}, {"Troll", "Horde"}, {"Scourge", "Horde"}, {"Tauren", "Horde"}, {"Goblin", "Horde"},
        }
        for _, artSet in ipairs({"Classic", "Cata"}) do
            dofile("Modules/Tutorial/Previews/" .. artSet .. ".lua")
            for _, player in ipairs(players) do
                textures = {}
                for _, style in ipairs({"icons", "blobs"}) do _Create(style, player[1], player[2]) end
                local image = textures[1].path
                local file = io.open(image:gsub("^Interface\\Addons\\Questie\\", ""):gsub("\\", "/"), "rb")
                assert.is_not_nil(file, image)
                file:close()
                assert.is_true(#_Textures("slay.blp") + #_Textures("loot.blp") > 2, image)
            end
        end
    end)

    it("puts a Questie icon on each of its icons' spots and a blob marker on every cluster", function()
        _Create("icons", "Human", "Alliance")
        assert.are_same({2, 1}, {#_Textures("slay.blp"), #_Textures("loot.blp")})

        textures = {}
        _Create("blobs", "Human", "Alliance")
        assert.are_same({1, 2}, {#_Textures("slay.blp"), #_Textures("loot.blp")})
    end)

    it("shows a hovered marker's objective, then the areas beneath it, in the client's language", function()
        local view = _Create("blobs", "Human", "Alliance")

        _Hover(view, 30, 30) -- The kobolds' marker, on the wolves' area.

        assert.is_true(tooltip.shown)
        assert.are_equal(view, tooltip.owner)
        assert.are_equal(4, #tooltip.lines)
        assert.are_equal("[2] Koboldlager säubern", tooltip.lines[1])
        assert.truthy(tooltip.lines[2]:find(":80:113:255|t", 1, true), "the kobolds' area colour")
        assert.truthy(tooltip.lines[2]:find("0/10 Koboldungeziefer$"))
        assert.are_equal("[2] Wolves Across the Border", tooltip.lines[3])
        assert.truthy(tooltip.lines[4]:find(":255:38:0|t", 1, true), "the wolves' area colour")
        assert.truthy(tooltip.lines[4]:find("0/8 Tough Wolf Meat$"))
    end)

    it("lists every area under the cursor and grows their markers, without a spotlight", function()
        local view = _Create("blobs", "Human", "Alliance")

        _Hover(view, 35, 35) -- Inside both areas, off every marker.

        assert.are_same({"[2] Koboldlager säubern", "[2] Wolves Across the Border"}, {tooltip.lines[1], tooltip.lines[3]})
        local kobold, wolves = _Textures("slay.blp")[1], _Textures("loot.blp")
        assert.are_same({true, true, false}, {kobold.width > 16, wolves[1].width > 16, wolves[2].width > 16})
        assert.are_same({1, 1}, _Alphas("loot.blp"))
    end)

    it("puts a hovered marker's quest in the spotlight until the cursor moves on", function()
        local view = _Create("blobs", "Human", "Alliance")
        local kobold = _Textures("slay.blp")[1]

        _Hover(view, 30, 30)

        assert.are_equal(1, kobold.color[4])
        assert.are_same({0.5, 0.5}, _Alphas("loot.blp"))
        assert.is_true(kobold.width > 16, "the hovered marker grows")

        _Hover(view, 95, 50) -- Bare map.

        assert.are_same({1, 1}, _Alphas("loot.blp"))
        assert.are_equal(16, kobold.width)
        assert.is_false(tooltip.shown)
    end)

    it("shows a Questie icon's objective without an area colour", function()
        local view = _Create("icons", "Human", "Alliance")

        _Hover(view, 90, 90) -- The wolves' spawn.

        assert.are_equal(2, #tooltip.lines)
        assert.are_equal("[2] Wolves Across the Border", tooltip.lines[1])
        assert.is_nil(tooltip.lines[2]:find("quest-log-fill", 1, true))
        assert.are_same({0.5, 0.5}, _Alphas("slay.blp"))
    end)

    it("ends its hover when the popup closes under the cursor", function()
        local view = _Create("blobs", "Human", "Alliance")
        _Hover(view, 35, 35)

        view:Hide()

        assert.is_false(tooltip.shown)
        assert.are_same({16, 16}, {_Textures("slay.blp")[1].width, _Textures("loot.blp")[1].width})
    end)

    it("ignores the cursor under another frame and in the gamepad UI", function()
        local view = _Create("blobs", "Human", "Alliance")

        _Hover(view, 35, 35)
        _Hover(view, 35, 35, {})
        assert.is_false(tooltip.shown)

        gamepad = true
        _Hover(view, 35, 35)
        assert.is_false(tooltip.shown)
    end)
end)
