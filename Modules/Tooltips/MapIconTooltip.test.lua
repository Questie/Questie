dofile("setupTests.lua")
local match = require("luassert.match")

describe("MapIconTooltip objective wording", function()
    local MapIconTooltip, QuestieComms, cached, objective, icon, now, pins
    local savedGlobals

    before_each(function()
        savedGlobals = {
            LibStub = _G.LibStub, GetTime = _G.GetTime, GameTooltip = _G.GameTooltip,
            WorldMapFrame = _G.WorldMapFrame, C_Map = _G.C_Map, IsShiftKeyDown = _G.IsShiftKeyDown,
            GetUnitName = _G.GetUnitName, UnitClassBase = _G.UnitClassBase, GetClassColor = _G.GetClassColor,
            C_CurrencyInfo = _G.C_CurrencyInfo, OPTIONAL_QUEST_OBJECTIVE_DESCRIPTION = _G.OPTIONAL_QUEST_OBJECTIVE_DESCRIPTION,
            QUEST_MONSTERS_KILLED = _G.QUEST_MONSTERS_KILLED, Minimap = _G.Minimap, GetCVar = _G.GetCVar,
        }
        now = 0
        _G.GetTime = function() return now end
        _G.IsShiftKeyDown = function() return false end
        _G.GetUnitName = function(unit, fullName)
            if unit == "player" and fullName then
                return "Local Fullname"
            end
            return "Local"
        end
        _G.UnitClassBase = function() return "MAGE" end
        _G.GetClassColor = function() return 1, 1, 1, "FFFFFFFF" end
        _G.C_CurrencyInfo = {GetCoinTextureString = function() return "" end}
        _G.C_Map = {GetMapInfo = function() return nil end}
        _G.WorldMapFrame = {GetMapID = function() return 1 end}
        _G.GameTooltip = {
            IsShown = function() return false end, IsOwned = function() return false end,
            SetOwner = function() end, SetFrameStrata = function() end, Show = function() end,
        }
        Questie.db.profile = {trackerColorObjectives = "minimal"}
        dofile("Localization/l10n.lua")
        dofile("Modules/Libs/QuestieLib.lua")
        local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
        QuestieLib.GetColoredQuestName = function() return "Quest Name" end
        QuestieLib.GetEffectiveQuestLevel = function() return 1, 0 end
        QuestieLoader:ImportModule("QuestieDB").GetQuest = function() return {} end
        QuestieLoader:ImportModule("QuestieDB").QueryItemSingle = function() return "Spell item" end
        QuestieLoader:ImportModule("QuestieDB").GetQuestTagInfo = function() end
        QuestieLoader:ImportModule("QuestXP").GetQuestLogRewardXP = function() return 0 end
        local player = QuestieLoader:ImportModule("QuestiePlayer")
        player.GetPartyMemberByName = function(_, name)
            if name == "Bob" then return {colorHex = "FFFFFFFF"} end
        end
        QuestieComms = QuestieLoader:ImportModule("QuestieComms")
        QuestieComms.GetQuest = function() return nil end
        QuestieComms.remotePlayerClasses = {}
        cached = {}
        QuestieLoader:ImportModule("QuestLogCache").TryGetQuest = function(id) return cached[id] end
        local layout = QuestieLoader:ImportModule("TooltipLayout")
        layout.CreateIndentUI = function() return "", 0 end
        layout.CreateRows = function()
            return {AddLine = function() end, AddDoubleLine = function() end}
        end
        layout.Render = function() end

        objective = {Index = 3, Type = "item", Description = "Windstone Cluster", Collected = 9, Needed = 15,
            Update = function() end}
        icon = {
            x = 50, y = 50, AreaID = 1,
            texture = {GetVertexColor = function() return 1, 1, 1, 1 end, SetVertexColor = function() end},
            data = {Id = 1, Type = "item", ObjectiveIndex = 3, ObjectiveData = objective, Name = "Windstone"},
        }
        pins = {worldmapProvider = {GetMap = function()
            return {EnumeratePinsByTemplate = function()
                local returned = false
                return function()
                    if not returned then
                        returned = true
                        return {icon = icon}
                    end
                end
            end}
        end}}
        -- Show traverses visible pins; only one pin participates in these renderer tests.
        _G.LibStub = function() return pins end
        dofile("Modules/Tooltips/MapIconTooltip.lua")
        MapIconTooltip = QuestieLoader:ImportModule("MapIconTooltip")
        now = 1
    end)

    after_each(function()
        _G.QUEST_MONSTERS_KILLED = savedGlobals.QUEST_MONSTERS_KILLED
        _G.OPTIONAL_QUEST_OBJECTIVE_DESCRIPTION = savedGlobals.OPTIONAL_QUEST_OBJECTIVE_DESCRIPTION
        _G.C_CurrencyInfo = savedGlobals.C_CurrencyInfo
        _G.LibStub, _G.GetTime, _G.GameTooltip = savedGlobals.LibStub, savedGlobals.GetTime, savedGlobals.GameTooltip
        _G.WorldMapFrame, _G.C_Map, _G.IsShiftKeyDown = savedGlobals.WorldMapFrame, savedGlobals.C_Map, savedGlobals.IsShiftKeyDown
        _G.GetUnitName, _G.UnitClassBase, _G.GetClassColor = savedGlobals.GetUnitName, savedGlobals.UnitClassBase, savedGlobals.GetClassColor
        _G.Minimap, _G.GetCVar = savedGlobals.Minimap, savedGlobals.GetCVar
    end)

    local function ObjectiveLines()
        local lines = {}
        for _, row in ipairs(GameTooltip.questOrder[1]) do
            for text in pairs(row) do
                lines[text] = true
            end
        end
        return lines
    end

    local function RenderObjectiveLines()
        MapIconTooltip.ShowOnTooltip(icon, GameTooltip)
        return ObjectiveLines()
    end

    it("replaces another owner's tooltip at once, such as a quest area's", function()
        now = 0.01
        GameTooltip.IsShown = function() return true end
        GameTooltip.SetOwner = spy.new(function() end)

        MapIconTooltip.ShowOnTooltip(icon, GameTooltip)

        assert.spy(GameTooltip.SetOwner).was.called(1)
        assert.are.equal(icon, GameTooltip.SetOwner.calls[1].refs[2])
    end)

    it("uses accepted native text without appending counts or stripping punctuation", function()
        cached[1] = {objectives = {[3] = {text = "9/15 Windstone Cluster."}}}

        assert.are.same({["|cFFEEEEEE9/15 Windstone Cluster."] = true}, RenderObjectiveLines())
        assert.are.equal("9/15 Windstone Cluster.", cached[1].objectives[3].text)
    end)

    it("does not invent a counter for a native action objective", function()
        objective.Type, objective.Collected, objective.Needed = "object", 1, 1
        cached[1] = {objectives = {[3] = {text = "Use Walk on Air"}}}

        assert.are.same({["|cFFEEEEEEUse Walk on Air"] = true}, RenderObjectiveLines())
    end)

    it("keeps fallback wording and punctuation with one progress counter", function()
        objective.Description = "Collect Windstone Clusters."

        assert.are.same({["|cFFEEEEEE9/15 Collect Windstone Clusters."] = true}, RenderObjectiveLines())
    end)

    it("does not borrow native text for synthetic source items", function()
        objective.IsRequiredSourceItem = true
        cached[1] = {objectives = {[3] = {text = "Unrelated native instruction"}}}

        assert.are.same({["|cFFEEEEEE9/15 Windstone Cluster"] = true}, RenderObjectiveLines())
    end)

    it("retains spell-item fallback when there is no native row", function()
        objective.Type = "spell"
        objective.spawnList = {[10] = {ItemId = 25}}
        icon.data.ObjectiveTargetId = 10

        assert.are.same({["|cFFEEEEEESpell item"] = true}, RenderObjectiveLines())
    end)

    it("replaces remote counters without changing the local row", function()
        cached[1] = {objectives = {[3] = {text = "Windstone Cluster: 9/15"}}}
        QuestieComms.GetQuest = function() return {Bob = {[3] = {fulfilled = 3, required = 15}}} end

        assert.are.same({
            ["|cFFEEEEEEWindstone Cluster: 9/15 (|cFFFFFFFFLocal Fullname|r|cFFEEEEEE)|r"] = true,
            ["|cFFEEEEEEWindstone Cluster: 3/15 (|cFFFFFFFFBob|r|cFFEEEEEE)|r"] = true,
        }, RenderObjectiveLines())
        assert.are.equal("Windstone Cluster: 9/15", cached[1].objectives[3].text)
    end)

    it("keeps local and remote optional counters separate without duplicating progress", function()
        _G.OPTIONAL_QUEST_OBJECTIVE_DESCRIPTION = "%s (Optional)"
        cached[1] = {objectives = {[3] = {text = "Wolf slain: 2/5 (Optional)"}}}
        objective.Description = QuestieLoader:ImportModule("QuestieLib").GetFullObjectiveText(cached[1].objectives[3].text)
        QuestieComms.GetQuest = function() return {Bob = {[3] = {fulfilled = 3, required = 5}}} end

        assert.are.same({
            ["|cFFEEEEEEWolf slain: 2/5 (Optional) (|cFFFFFFFFLocal Fullname|r|cFFEEEEEE)|r"] = true,
            ["|cFFEEEEEEWolf slain: 3/5 (Optional) (|cFFFFFFFFBob|r|cFFEEEEEE)|r"] = true,
        }, RenderObjectiveLines())
        assert.are.equal("Wolf slain (Optional)", objective.Description)
        assert.are.equal("Wolf slain: 2/5 (Optional)", cached[1].objectives[3].text)
    end)

    it("replaces French party progress without duplicating the local counter or dropping the suffix", function()
        _G.QUEST_MONSTERS_KILLED = "%1$s\194\160: %2$d/%3$d |4personnage tué:personnages tués;"
        _G.OPTIONAL_QUEST_OBJECTIVE_DESCRIPTION = "%s (optionnel)"
        local nativeText = "Vide-gousset défias\194\160: 2/5 personnages tués (optionnel)"
        cached[1] = {objectives = {[3] = {text = nativeText}}}
        objective.Type, objective.Collected, objective.Needed = "monster", 2, 5
        objective.Description = QuestieLoader:ImportModule("QuestieLib").GetFullObjectiveText(nativeText)
        QuestieComms.GetQuest = function() return {Bob = {[3] = {fulfilled = 3, required = 5}}} end

        assert.are.same({
            ["|cFFEEEEEEVide-gousset défias\194\160: 2/5 personnages tués (optionnel) (|cFFFFFFFFLocal Fullname|r|cFFEEEEEE)|r"] = true,
            ["|cFFEEEEEEVide-gousset défias\194\160: 3/5 personnages tués (optionnel) (|cFFFFFFFFBob|r|cFFEEEEEE)|r"] = true,
        }, RenderObjectiveLines())
        assert.are.equal(nativeText, cached[1].objectives[3].text)
    end)

    it("does not show local counters as remote progress when party counts are missing", function()
        cached[1] = {objectives = {[3] = {text = "Windstone Cluster: 9/15"}}}
        QuestieComms.GetQuest = function() return {Bob = {[3] = {}}} end

        assert.are.same({
            ["|cFFEEEEEEWindstone Cluster: 9/15 (|cFFFFFFFFLocal Fullname|r|cFFEEEEEE)|r"] = true,
            ["|cFFedededWindstone Cluster (|cFFFFFFFFBob|r|cFFededed)|r"] = true,
        }, RenderObjectiveLines())
    end)

    it("uses loaded party-only native wording with remote progress and no local row", function()
        objective.IsPartyObjective = true
        objective.NativeText = "9/15 Windstone Cluster"
        objective.Needed, objective.Collected = nil, nil
        QuestieComms.GetQuest = function() return {Bob = {[3] = {fulfilled = 0, required = 15}}} end

        assert.are.same({["|cFFEEEEEE0/15 Windstone Cluster (|cFFFFFFFFBob|r|cFFEEEEEE)|r"] = true}, RenderObjectiveLines())
        assert.are.equal("9/15 Windstone Cluster", objective.NativeText)
    end)

    it("ignores a local cached row at the same index for a party-only objective", function()
        -- The local player has the same quest ID cached with a different objective at index 3.
        cached[1] = {objectives = {[3] = {text = "1/1 Local objective"}}}
        objective.IsPartyObjective = true
        objective.NativeText = "9/15 Windstone Cluster"
        objective.Needed, objective.Collected = nil, nil
        QuestieComms.GetQuest = function() return {Bob = {[3] = {fulfilled = 0, required = 15}}} end

        assert.are.same({["|cFFEEEEEE0/15 Windstone Cluster (|cFFFFFFFFBob|r|cFFEEEEEE)|r"] = true}, RenderObjectiveLines())
    end)

    it("keeps remote fallback for an instruction without a recognized counter", function()
        objective.IsPartyObjective = true
        objective.NativeText = "Use Walk on Air"
        objective.Description = "Use Walk on Air"
        QuestieComms.GetQuest = function() return {Bob = {[3] = {fulfilled = 0, required = 1}}} end

        assert.are.same({["|cFFEEEEEE0/1 Use Walk on Air (|cFFFFFFFFBob|r|cFFEEEEEE)|r"] = true}, RenderObjectiveLines())
    end)
    describe("for a patrol path", function()
        it("belongs to the frame it is given", function()
            local owner = {}
            GameTooltip.SetOwner = spy.new(function() end)

            MapIconTooltip.ShowOnTooltip(icon, GameTooltip, owner)

            assert.spy(GameTooltip.SetOwner).was.called_with(match._, match.is_ref(owner), "ANCHOR_CURSOR")
        end)

        it("shows for an icon faded out by distance, which shows nothing when hovered itself", function()
            icon.texture.GetVertexColor = function() return 1, 1, 1, 0 end
            GameTooltip.Show = spy.new(function() end)

            MapIconTooltip.ShowOnTooltip(icon, GameTooltip)
            assert.spy(GameTooltip.Show).was.not_called()

            MapIconTooltip.ShowOnTooltip(icon, GameTooltip, {})
            assert.spy(GameTooltip.Show).was.called(1)
        end)

        it("lists the given icons of an NPC's quests, however far away and faded", function()
            _G.Minimap = {GetZoom = function() return 0 end, SetZoom = function() end}
            _G.GetCVar = function() return "0" end
            icon.miniMapIcon = true
            -- HereBeDragons shows neither icon: both are out of range. The second is faded out, elsewhere.
            pins.activeMinimapPins = {}
            local secondQuest = {
                x = 90, y = 10, AreaID = 2, miniMapIcon = true,
                texture = {a = 0, GetVertexColor = function() return 1, 1, 1, 0 end},
                data = {Id = 2, Type = "item", ObjectiveIndex = 3, ObjectiveData = objective, Name = "Windstone"},
            }

            MapIconTooltip.ShowOnTooltip(icon, GameTooltip, _G.Minimap, {icon, secondQuest})

            assert.is_not_nil(GameTooltip.questOrder[1])
            assert.is_not_nil(GameTooltip.questOrder[2])
        end)

    end)
    describe("order", function()
        local rendered, questLevels

        before_each(function()
            rendered, questLevels = {}, {}
            local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
            QuestieLib.GetEffectiveQuestLevel = function(questId) return questLevels[questId], 0 end
            QuestieLib.GetColoredQuestName = function(_, questId) return "Quest " .. questId end
            QuestieLoader:ImportModule("QuestieReputation").GetReputationReward = function() return {} end
            QuestieLoader:ImportModule("TooltipLayout").CreateRows = function()
                local function Add(_, text) rendered[#rendered + 1] = text end
                return {AddLine = Add, AddDoubleLine = Add}
            end
        end)

        ---@return number? row Where the first row containing text was rendered.
        local function RowOf(text)
            for row, line in ipairs(rendered) do
                if line:find(text, 1, true) then return row end
            end
        end

        -- An icon of another quest, where the hovered icon is.
        local function QuestIcon(questId, type)
            return {x = 50, y = 50, AreaID = 1, texture = icon.texture,
                data = {Id = questId, Type = type, ObjectiveIndex = 3, ObjectiveData = objective, Name = "Windstone", QuestData = {}}}
        end

        it("lists a giver's quests by level, low to high", function()
            questLevels = {[1] = 1, [10] = 30, [11] = 5, [12] = 18}

            local hovered = QuestIcon(10, "complete")

            MapIconTooltip.ShowOnTooltip(hovered, GameTooltip, nil, {hovered, QuestIcon(11, "complete"), QuestIcon(12, "complete")})

            assert.is_true(RowOf("Quest 11") < RowOf("Quest 12"))
            assert.is_true(RowOf("Quest 12") < RowOf("Quest 10"))
        end)

        it("lists active quests' objectives by level, low to high", function()
            questLevels = {[1] = 20, [2] = 5}

            MapIconTooltip.ShowOnTooltip(icon, GameTooltip, nil, {QuestIcon(2, "item")})

            assert.is_true(RowOf("Quest 2") < RowOf("Quest 1"))
        end)
    end)

    describe("for given icons", function()
        -- A tooltip frame acting like GameTooltip: the last SetOwner holds it until it hides.
        local function HoldingTooltip()
            local tooltip = {}
            function tooltip:SetOwner(frame, anchor) self.holder, self.anchor = frame, anchor end
            function tooltip:IsOwned(frame) return self.holder == frame end
            function tooltip:IsShown() return self.holder ~= nil end
            function tooltip:GetAnchorType() return self.anchor end
            function tooltip:ClearLines() end
            function tooltip:SetFrameStrata() end
            function tooltip:Show() end
            tooltip.Hide = spy.new(function(self) self.holder = nil end)
            return tooltip
        end

        it("prefixes the icons' own objective lines, not party lines", function()
            cached[1] = {objectives = {[3] = {text = "Windstone Cluster: 9/15"}}}
            QuestieComms.GetQuest = function() return {Bob = {[3] = {fulfilled = 3, required = 15}}} end

            MapIconTooltip.ShowForIcons({}, {icon}, GameTooltip, function(prefixed)
                assert.are.equal(icon, prefixed)
                return "[area] "
            end)

            assert.are.same({
                ["[area] |cFFEEEEEEWindstone Cluster: 9/15 (|cFFFFFFFFLocal Fullname|r|cFFEEEEEE)|r"] = true,
                ["|cFFEEEEEEWindstone Cluster: 3/15 (|cFFFFFFFFBob|r|cFFEEEEEE)|r"] = true,
            }, ObjectiveLines())
        end)

        it("releases only the tooltip shown for its owner", function()
            local tooltip = HoldingTooltip()
            local area, other = {}, {}

            -- A map icon tooltip shown since for another frame stays.
            MapIconTooltip.ShowForIcons(area, {icon}, tooltip)
            MapIconTooltip.ShowForIcons(other, {icon}, tooltip)
            MapIconTooltip.Release(area, tooltip)
            assert.spy(tooltip.Hide).was.not_called()
            assert.are.equal(other, MapIconTooltip.GetOwner(tooltip))

            MapIconTooltip.Release(other, tooltip)
            assert.spy(tooltip.Hide).was.called(1)
            assert.is_nil(MapIconTooltip.GetOwner(tooltip))
        end)

        it("stops counting a tooltip another frame took, and leaves that frame's tooltip alone", function()
            local tooltip = HoldingTooltip()
            local area, pin = {}, {}
            MapIconTooltip.ShowForIcons(area, {icon}, tooltip)

            -- A Blizzard pin takes the tooltip. The tracker's own `_owner` field means nothing here.
            tooltip:SetOwner(pin, "ANCHOR_RIGHT")
            tooltip._owner = area
            assert.is_nil(MapIconTooltip.GetOwner(tooltip))
            MapIconTooltip.Redraw()
            MapIconTooltip.Release(area, tooltip)

            assert.spy(tooltip.Hide).was.not_called()
            assert.are.equal(pin, tooltip.holder)
        end)

        it("redraws every tooltip its owner still holds, at the same anchor", function()
            local mapTooltip, gamepadTooltip, endedTooltip = HoldingTooltip(), HoldingTooltip(), HoldingTooltip()
            local ended = {}
            MapIconTooltip.ShowForIcons(icon, {icon}, mapTooltip)
            MapIconTooltip.ShowForIcons(icon, {icon}, gamepadTooltip)
            -- The gamepad's tooltip sits beside its cursor.
            gamepadTooltip:SetOwner(icon, "ANCHOR_RIGHT")
            MapIconTooltip.ShowForIcons(ended, {icon}, endedTooltip)
            MapIconTooltip.Release(ended, endedTooltip)
            local rendered = {}
            QuestieLoader:ImportModule("TooltipLayout").Render = function(_, tooltip) rendered[tooltip] = true end

            MapIconTooltip.Redraw()

            assert.are.same({[mapTooltip] = true, [gamepadTooltip] = true}, rendered)
            assert.are.equal("ANCHOR_CURSOR", mapTooltip.anchor)
            assert.are.equal("ANCHOR_RIGHT", gamepadTooltip.anchor)
            assert.are.equal(icon, gamepadTooltip.holder)
        end)
    end)
end)
