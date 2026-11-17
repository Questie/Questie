dofile("setupTests.lua")
local match = require("luassert.match")

describe("MapIconTooltip objective wording", function()
    local MapIconTooltip, QuestieComms, ActiveQuests, cached, objective, icon, now, pins
    local savedGlobals

    before_each(function()
        savedGlobals = {
            GetTime = _G.GetTime, GameTooltip = _G.GameTooltip,
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
            IsShown = function() return false end,
            SetOwner = function() end, SetFrameStrata = function() end, Show = function() end,
        }
        Questie.db.profile = {trackerColorObjectives = "minimal", enableTooltipDroprates = true}
        dofile("Localization/l10n.lua")
        dofile("Modules/Libs/QuestieLib.lua")
        local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
        QuestieLib.GetColoredQuestName = function() return "Quest Name" end
        QuestieLib.GetEffectiveQuestLevel = function() return 1, 0 end
        local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
        QuestieDB.GetQuest = function() return {} end
        QuestieDB.QueryItemSingle = function() return "Spell item" end
        QuestieDB.GetQuestTagInfo = function() end
        QuestieDB.GetCreatureLevels = function() return {} end
        QuestieDB.GetItemDroprate = function() return nil end
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
        dofile("Modules/Quest/ActiveQuests.lua")
        ActiveQuests = QuestieLoader:ImportModule("ActiveQuests")
        ActiveQuests.Add(1, {})
        ActiveQuests.Add(2, {})
        local layout = QuestieLoader:ImportModule("TooltipLayout")
        layout.CreateIndentUI = function() return "", 0 end
        layout.CreateRows = function()
            return {AddLine = function() end, AddDoubleLine = function() end}
        end
        layout.Render = function() end
        QuestieLoader:ImportModule("QuestieWaypoints").SetHighlighted = function() end
        QuestieLoader:ImportModule("WaypointHover").End = function() end

        objective = {Index = 3, Type = "item", Description = "Windstone Cluster", Collected = 9, Needed = 15,
            Update = function() end}
        icon = {
            x = 50, y = 50, AreaID = 1,
            texture = {GetVertexColor = function() return 1, 1, 1, 1 end, SetVertexColor = function() end},
            data = {Id = 1, Type = "item", ObjectiveIndex = 3, ObjectiveData = objective, Name = "Windstone"},
        }
        -- Show traverses visible pins; only one pin participates in these renderer tests.
        pins = QuestieLoader:ImportModule("HBDPins")
        pins.activeMinimapPins = nil
        pins.worldmapProvider = {GetMap = function()
            return {EnumeratePinsByTemplate = function()
                local returned = false
                return function()
                    if not returned then
                        returned = true
                        return {icon = icon}
                    end
                end
            end}
        end}
        dofile("Modules/Tooltips/MapIconTooltip.lua")
        MapIconTooltip = QuestieLoader:ImportModule("MapIconTooltip")
        now = 1
    end)

    after_each(function()
        _G.QUEST_MONSTERS_KILLED = savedGlobals.QUEST_MONSTERS_KILLED
        _G.OPTIONAL_QUEST_OBJECTIVE_DESCRIPTION = savedGlobals.OPTIONAL_QUEST_OBJECTIVE_DESCRIPTION
        _G.C_CurrencyInfo = savedGlobals.C_CurrencyInfo
        _G.GetTime, _G.GameTooltip = savedGlobals.GetTime, savedGlobals.GameTooltip
        _G.WorldMapFrame, _G.C_Map, _G.IsShiftKeyDown = savedGlobals.WorldMapFrame, savedGlobals.C_Map, savedGlobals.IsShiftKeyDown
        _G.GetUnitName, _G.UnitClassBase, _G.GetClassColor = savedGlobals.GetUnitName, savedGlobals.UnitClassBase, savedGlobals.GetClassColor
        _G.Minimap, _G.GetCVar = savedGlobals.Minimap, savedGlobals.GetCVar
    end)

    local function RenderObjectiveLines()
        MapIconTooltip.Show(icon)
        local lines = {}
        for _, row in ipairs(GameTooltip.questOrder[1]) do
            for _, line in ipairs(row.lines) do
                lines[line.text] = true
            end
        end
        return lines
    end

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

    it("should not list the objectives of a quest that left the quest log before its icon was removed", function()
        local update = spy.new(function() end)
        objective.Update = update
        ActiveQuests.Remove(1)

        MapIconTooltip.Show(icon)

        assert.is_nil(GameTooltip.questOrder[1])
        assert.spy(update).was.not_called()
    end)

    it("should list the objectives of a party member's quest the player does not have", function()
        objective.IsPartyObjective = true
        objective.NativeText = "9/15 Windstone Cluster"
        QuestieComms.GetQuest = function() return {Bob = {[3] = {fulfilled = 0, required = 15}}} end
        ActiveQuests.Remove(1)

        assert.is_not_nil(next(RenderObjectiveLines()))
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
    describe("RefreshQuest", function()
        local QuestieFrame, originalReset, owner

        local function ListedText()
            local text = {}
            for _, row in ipairs(GameTooltip.questOrder[1]) do
                for line in pairs(row) do
                    text[#text + 1] = line
                end
            end
            return table.concat(text, "\n")
        end

        before_each(function()
            QuestieFrame = QuestieLoader:ImportModule("QuestieFrame")
            originalReset = QuestieFrame.ResetHoverHighlights
            QuestieFrame.ResetHoverHighlights = spy.new(function() end)
            owner = nil
            GameTooltip.IsShown = function() return true end
            GameTooltip.SetOwner = spy.new(function(_, frame) owner = frame end)
            GameTooltip.GetOwner = function() return owner end
            objective.IsPartyObjective = true
            QuestieComms.GetQuest = function() return {Bob = {[3] = {fulfilled = 3, required = 15}}} end
            MapIconTooltip.Show(icon)
        end)

        after_each(function()
            QuestieFrame.ResetHoverHighlights = originalReset
        end)

        it("should show the open tooltip again with the changed progress of a listed quest", function()
            assert.is_truthy(ListedText():find("3/15", 1, true))
            QuestieComms.GetQuest = function() return {Bob = {[3] = {fulfilled = 4, required = 15}}} end

            -- Within the throttle of the tooltip's own show
            MapIconTooltip.RefreshQuest(1)

            assert.is_truthy(ListedText():find("4/15", 1, true))
            assert.spy(GameTooltip.SetOwner).was.called(2)
            assert.are.equal(icon, owner)
        end)

        it("should reset the hover highlights of the icon before showing again", function()
            MapIconTooltip.RefreshQuest(1)

            assert.spy(QuestieFrame.ResetHoverHighlights).was.called_with(icon)
        end)

        it("should leave a tooltip alone that does not list the quest", function()
            MapIconTooltip.RefreshQuest(2)

            assert.spy(GameTooltip.SetOwner).was.called(1)
            assert.spy(QuestieFrame.ResetHoverHighlights).was.not_called()
        end)

        describe("for a hovered patrol path", function()
            local pathTooltip, minimap, pathOwner

            before_each(function()
                minimap = {}
                pathOwner = nil
                pathTooltip = {
                    IsShown = function() return true end,
                    SetOwner = spy.new(function(_, frame) pathOwner = frame end),
                    GetOwner = function() return pathOwner end,
                    SetFrameStrata = function() end,
                    Show = function() end,
                }
                now = now + 0.1
                MapIconTooltip.ShowOnTooltip(icon, pathTooltip, minimap, {icon})
            end)

            it("should show the tooltip again with its own owner, icons and the changed progress", function()
                QuestieComms.GetQuest = function() return {Bob = {[3] = {fulfilled = 4, required = 15}}} end

                MapIconTooltip.RefreshQuest(1)

                assert.spy(pathTooltip.SetOwner).was.called(2)
                assert.are.equal(minimap, pathOwner)
                local text = {}
                for _, row in ipairs(pathTooltip.questOrder[1]) do
                    for line in pairs(row) do
                        text[#text + 1] = line
                    end
                end
                assert.is_truthy(table.concat(text, "\n"):find("4/15", 1, true))
            end)

            it("should leave the tooltip alone when it was closed", function()
                pathTooltip.IsShown = function() return false end

                MapIconTooltip.RefreshQuest(1)

                assert.spy(pathTooltip.SetOwner).was.called(1)
            end)

            it("should not list an icon again that was reused for another quest since", function()
                local other = {
                    x = 90, y = 10, AreaID = 2,
                    texture = {GetVertexColor = function() return 1, 1, 1, 1 end, SetVertexColor = function() end},
                    data = {Id = 2, Type = "item", ObjectiveIndex = 3, ObjectiveData = objective, Name = "Windstone"},
                }
                now = now + 0.1
                MapIconTooltip.ShowOnTooltip(icon, pathTooltip, minimap, {icon, other})
                assert.is_not_nil(pathTooltip.questOrder[2])
                other.data = {Id = 3, Type = "item", ObjectiveIndex = 3, ObjectiveData = objective, Name = "Windstone"}

                MapIconTooltip.RefreshQuest(1)

                assert.is_not_nil(pathTooltip.questOrder[1])
                assert.is_nil(pathTooltip.questOrder[2])
                assert.is_nil(pathTooltip.questOrder[3])
            end)

            it("should leave the tooltip alone when its icon was reused for another quest", function()
                icon.data = {Id = 2, Type = "item", ObjectiveIndex = 3, ObjectiveData = objective, Name = "Windstone"}

                MapIconTooltip.RefreshQuest(1)

                assert.spy(pathTooltip.SetOwner).was.called(1)
                assert.spy(QuestieFrame.ResetHoverHighlights).was.not_called()
            end)

            it("should leave the tooltip alone when another frame took it over", function()
                pathOwner = {}

                MapIconTooltip.RefreshQuest(1)

                assert.spy(pathTooltip.SetOwner).was.called(1)
            end)

            it("should leave the tooltip alone when it does not list the quest", function()
                MapIconTooltip.RefreshQuest(2)

                assert.spy(pathTooltip.SetOwner).was.called(1)
            end)

            it("should keep showing an icon that is faded out, which a hovered path shows whatever its fade", function()
                icon.texture.GetVertexColor = function() return 1, 1, 1, 0 end

                MapIconTooltip.RefreshQuest(1)

                assert.spy(pathTooltip.SetOwner).was.called(2)
            end)
        end)

        it("should leave the tooltip and its highlights alone when the icon faded out meanwhile", function()
            icon.texture.GetVertexColor = function() return 1, 1, 1, 0 end

            MapIconTooltip.RefreshQuest(1)

            assert.spy(GameTooltip.SetOwner).was.called(1)
            assert.spy(QuestieFrame.ResetHoverHighlights).was.not_called()
        end)

        it("should leave the tooltip alone when the icon was reused for another quest", function()
            icon.data = {Id = 2, Type = "item", ObjectiveIndex = 3, ObjectiveData = objective, Name = "Windstone"}

            MapIconTooltip.RefreshQuest(1)

            assert.spy(GameTooltip.SetOwner).was.called(1)
            assert.spy(QuestieFrame.ResetHoverHighlights).was.not_called()
        end)

        it("should leave the tooltip alone when the icon was unloaded", function()
            icon.data = nil

            MapIconTooltip.RefreshQuest(1)

            assert.spy(GameTooltip.SetOwner).was.called(1)
        end)

        it("should leave the tooltip alone when it was closed", function()
            GameTooltip.IsShown = function() return false end

            MapIconTooltip.RefreshQuest(1)

            assert.spy(GameTooltip.SetOwner).was.called(1)
        end)
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

        it("keeps the colors to restore when a hovered icon's tooltip shows again before its reset", function()
            GameTooltip.IsShown = function() return true end
            icon.texture.r, icon.texture.g, icon.texture.b, icon.texture.a = 1, 0.5, 0, 1
            icon.texture.SetVertexColor = function(texture, r, g, b, a)
                texture.r, texture.g, texture.b, texture.a = r, g, b, a
            end

            -- The path's hover shows the tooltip, then the icon's own hover past the throttle, with no reset between.
            MapIconTooltip.ShowOnTooltip(icon, GameTooltip)
            now = now + 0.1
            MapIconTooltip.ShowOnTooltip(icon, GameTooltip)

            assert.are.equal(1, #icon.data.touchedPins)
            assert.are.equal(icon, icon.data.touchedPins[1].icon)
            assert.are.equal(icon.data, icon.data.touchedPins[1].data)
            assert.are_same({1, 0.5, 0, 1}, icon.data.touchedPins[1].color)
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

    describe("source names and drop rates", function()
        local rendered

        before_each(function()
            rendered = {}
            local layout = QuestieLoader:ImportModule("TooltipLayout")
            layout.CreateRows = function()
                local function Add(_, text) rendered[#rendered + 1] = text end
                return {AddLine = Add, AddDoubleLine = Add}
            end
            QuestieLoader:ImportModule("QuestieReputation").GetReputationReward = function() return {} end
        end)

        ---@return string?
        local function RowContaining(text)
            for _, line in ipairs(rendered) do
                if line:find(text, 1, true) then
                    return line
                end
            end
        end

        it("always shows the source mob name without holding Shift", function()
            MapIconTooltip.Show(icon)

            assert.is_not_nil(RowContaining("Windstone"))
        end)

        it("stores drop rates on sources and renders [N%] on the item objective line", function()
            objective.Id = 1234
            icon.data.ObjectiveTargetId = 5678
            QuestieLoader:ImportModule("QuestieDB").GetItemDroprate = function(itemId, npcId)
                assert.are.equal(1234, itemId)
                assert.are.equal(5678, npcId)
                -- Rates in [2, 10) keep one decimal via FormatDropText (same as world tooltips)
                return {7.5, "questie"}
            end

            MapIconTooltip.Show(icon)

            local tipRow = GameTooltip.questOrder[1][1]
            assert.are.same({name = "Windstone", suffix = "  |cff555555[|cffff26007.5%|cff555555]"}, tipRow.lines[1].sources[5678])
            local itemLine = RowContaining("Windstone Cluster")
            assert.is_not_nil(itemLine)
            assert.is_truthy(itemLine:find("%[7%.5%%%]", 1) or itemLine:find("7.5%", 1, true))
            -- Mob name stays bare; rate belongs on the item/objective wording (like unit tips).
            local mobLine = RowContaining("|cFFDDDDDDWindstone")
            assert.is_not_nil(mobLine)
            assert.is_nil(mobLine:find("7.5%", 1, true))
        end)

        it("omits drop rates when enableTooltipDroprates is disabled", function()
            Questie.db.profile.enableTooltipDroprates = false
            objective.Id = 1234
            icon.data.ObjectiveTargetId = 5678
            QuestieLoader:ImportModule("QuestieDB").GetItemDroprate = function()
                return {50, "questie"}
            end

            MapIconTooltip.Show(icon)

            local tipRow = GameTooltip.questOrder[1][1]
            assert.are.same({name = "Windstone", suffix = ""}, tipRow.lines[1].sources[5678])
            assert.is_nil(RowContaining("50%"))
        end)

        it("does not look up drop rates for non-item objectives", function()
            objective.Type = "monster"
            objective.Id = 999
            icon.data.ObjectiveTargetId = 111
            local called = false
            QuestieLoader:ImportModule("QuestieDB").GetItemDroprate = function()
                called = true
                return {10, "questie"}
            end

            MapIconTooltip.Show(icon)

            assert.is_false(called)
            local tipRow = GameTooltip.questOrder[1][1]
            assert.are.same({name = "Windstone", suffix = ""}, tipRow.lines[1].sources[111])
        end)

        it("keeps distinct drop rates for same-named sources with different ids", function()
            objective.Id = 1234
            icon.data.ObjectiveTargetId = 10
            local other = {
                x = 50, y = 50, AreaID = 1,
                texture = icon.texture,
                data = {
                    Id = 1, Type = "item", ObjectiveIndex = 3, ObjectiveData = objective,
                    Name = "Windstone", ObjectiveTargetId = 20,
                },
            }
            QuestieLoader:ImportModule("QuestieDB").GetItemDroprate = function(_, npcId)
                if npcId == 10 then return {7.5, "questie"} end
                if npcId == 20 then return {3.2, "questie"} end
            end

            MapIconTooltip.ShowOnTooltip(icon, GameTooltip, nil, {icon, other})

            local tipRow = GameTooltip.questOrder[1][1]
            assert.are.same({name = "Windstone", suffix = "  |cff555555[|cffff26007.5%|cff555555]"}, tipRow.lines[1].sources[10])
            assert.are.same({name = "Windstone", suffix = "  |cff555555[|cffff10003.2%|cff555555]"}, tipRow.lines[1].sources[20])
            assert.is_truthy(RowContaining("7.5%"):find("Windstone Cluster", 1, true))
            assert.is_truthy(RowContaining("3.2%"):find("Windstone Cluster", 1, true))
        end)

        it("shows a shared source name again on a second objective line", function()
            local secondObjective = {
                Index = 4, Type = "item", Description = "Intact Horn", Collected = 0, Needed = 1,
                Id = 9999, Update = function() end,
            }
            local second = {
                x = 50, y = 50, AreaID = 1,
                texture = icon.texture,
                data = {
                    Id = 1, Type = "item", ObjectiveIndex = 4, ObjectiveData = secondObjective,
                    Name = "Windstone", ObjectiveTargetId = 5678,
                },
            }
            objective.Id = 1234
            icon.data.ObjectiveTargetId = 5678
            QuestieLoader:ImportModule("QuestieDB").GetItemDroprate = function(itemId)
                if itemId == 1234 then return {7.5, "questie"} end
                if itemId == 9999 then return {4.1, "questie"} end
            end

            MapIconTooltip.ShowOnTooltip(icon, GameTooltip, nil, {icon, second})

            local windstoneRows = 0
            for _, line in ipairs(rendered) do
                if line:find("Windstone", 1, true) then
                    windstoneRows = windstoneRows + 1
                end
            end
            assert.is_true(windstoneRows >= 2)
            assert.is_not_nil(RowContaining("7.5%"))
            assert.is_not_nil(RowContaining("4.1%"))
        end)

        it("keeps separate drop rates when two objectives share identical text", function()
            -- Force identical fallback wording so merge-by-text would collide.
            objective.Description = "Collect Windstone"
            objective.Id = 1234
            icon.data.ObjectiveTargetId = 10
            local twinObjective = {
                Index = 4, Type = "item", Description = "Collect Windstone", Collected = 9, Needed = 15,
                Id = 5678, Update = function() end,
            }
            local twin = {
                x = 50, y = 50, AreaID = 1,
                texture = icon.texture,
                data = {
                    Id = 1, Type = "item", ObjectiveIndex = 4, ObjectiveData = twinObjective,
                    Name = "Windstone", ObjectiveTargetId = 10,
                },
            }
            QuestieLoader:ImportModule("QuestieDB").GetItemDroprate = function(itemId)
                if itemId == 1234 then return {7.5, "questie"} end
                if itemId == 5678 then return {4.1, "questie"} end
            end

            MapIconTooltip.ShowOnTooltip(icon, GameTooltip, nil, {icon, twin})

            assert.are.equal(2, #GameTooltip.questOrder[1])
            assert.are.same({name = "Windstone", suffix = "  |cff555555[|cffff26007.5%|cff555555]"}, GameTooltip.questOrder[1][1].lines[1].sources[10])
            assert.are.same({name = "Windstone", suffix = "  |cff555555[|cffff15004.1%|cff555555]"}, GameTooltip.questOrder[1][2].lines[1].sources[10])
            assert.is_not_nil(RowContaining("7.5%"))
            assert.is_not_nil(RowContaining("4.1%"))
        end)

        it("keeps special objectives distinct when both pins use ObjectiveIndex 0", function()
            -- Special objectives are populated with ObjectiveIndex 0 but carry Index = 64+n.
            objective.Index = 65
            objective.Description = "Special objective"
            objective.Id = 111
            icon.data.ObjectiveIndex = 0
            icon.data.ObjectiveTargetId = 10
            local otherObjective = {
                Index = 66, Type = "item", Description = "Special objective", Collected = 9, Needed = 15,
                Id = 222, Update = function() end,
            }
            local other = {
                x = 50, y = 50, AreaID = 1,
                texture = icon.texture,
                data = {
                    Id = 1, Type = "item", ObjectiveIndex = 0, ObjectiveData = otherObjective,
                    Name = "Windstone", ObjectiveTargetId = 10,
                },
            }
            QuestieLoader:ImportModule("QuestieDB").GetItemDroprate = function(itemId)
                if itemId == 111 then return {7.5, "questie"} end
                if itemId == 222 then return {4.1, "questie"} end
            end

            MapIconTooltip.ShowOnTooltip(icon, GameTooltip, nil, {icon, other})

            assert.are.equal(2, #GameTooltip.questOrder[1])
            assert.is_not_nil(RowContaining("7.5%"))
            assert.is_not_nil(RowContaining("4.1%"))
        end)

        it("keeps local and party player lines in insertion order", function()
            cached[1] = {objectives = {[3] = {text = "Windstone Cluster: 9/15"}}}
            QuestieComms.GetQuest = function() return {Bob = {[3] = {fulfilled = 3, required = 15}}} end
            QuestieLoader:ImportModule("QuestieLib").GetColoredQuestName = function() return "Quest Name" end

            MapIconTooltip.Show(icon)

            local tipRow = GameTooltip.questOrder[1][1]
            assert.are.equal(2, #tipRow.lines)
            local firstText = tipRow.lines[1].text
            local secondText = tipRow.lines[2].text
            assert.is_truthy(firstText:find("Bob", 1, true) or secondText:find("Bob", 1, true))
            assert.is_truthy(firstText:find("Local Fullname", 1, true) or secondText:find("Local Fullname", 1, true))

            local firstRow, secondRow
            for row, line in ipairs(rendered) do
                if line:find(firstText, 1, true) then firstRow = row end
                if line:find(secondText, 1, true) then secondRow = row end
            end
            assert.is_not_nil(firstRow)
            assert.is_not_nil(secondRow)
            assert.is_true(firstRow < secondRow)
        end)
    end)
end)
