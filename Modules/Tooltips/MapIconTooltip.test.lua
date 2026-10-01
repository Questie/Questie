dofile("setupTests.lua")

describe("MapIconTooltip objective wording", function()
    local MapIconTooltip, QuestieComms, cached, objective, icon, now
    local savedGlobals

    before_each(function()
        savedGlobals = {
            LibStub = _G.LibStub, GetTime = _G.GetTime, GameTooltip = _G.GameTooltip,
            WorldMapFrame = _G.WorldMapFrame, C_Map = _G.C_Map, IsShiftKeyDown = _G.IsShiftKeyDown,
            UnitName = _G.UnitName, UnitClassBase = _G.UnitClassBase, GetClassColor = _G.GetClassColor,
            C_CurrencyInfo = _G.C_CurrencyInfo, OPTIONAL_QUEST_OBJECTIVE_DESCRIPTION = _G.OPTIONAL_QUEST_OBJECTIVE_DESCRIPTION,
        }
        now = 0
        _G.GetTime = function() return now end
        _G.IsShiftKeyDown = function() return false end
        _G.UnitName = function() return "Local" end
        _G.UnitClassBase = function() return "MAGE" end
        _G.GetClassColor = function() return 1, 1, 1, "FFFFFFFF" end
        _G.C_CurrencyInfo = {GetCoinTextureString = function() return "" end}
        _G.C_Map = {GetMapInfo = function() return nil end}
        _G.WorldMapFrame = {GetMapID = function() return 1 end}
        _G.GameTooltip = {
            IsShown = function() return false end,
            SetOwner = function() end, SetFrameStrata = function() end, Show = function() end,
        }
        Questie.db.profile = {trackerColorObjectives = "minimal"}
        dofile("Localization/l10n.lua")
        dofile("Modules/Libs/QuestieLib.lua")
        local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
        QuestieLib.GetColoredQuestName = function() return "Quest Name" end
        QuestieLoader:ImportModule("QuestieMap").zoneWaypointHoverColorOverrides = {}
        QuestieLoader:ImportModule("QuestieDB").GetQuest = function() return {} end
        QuestieLoader:ImportModule("QuestieDB").QueryItemSingle = function() return "Spell item" end
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
        local pins = {worldmapProvider = {GetMap = function()
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
        _G.OPTIONAL_QUEST_OBJECTIVE_DESCRIPTION = savedGlobals.OPTIONAL_QUEST_OBJECTIVE_DESCRIPTION
        _G.C_CurrencyInfo = savedGlobals.C_CurrencyInfo
        _G.LibStub, _G.GetTime, _G.GameTooltip = savedGlobals.LibStub, savedGlobals.GetTime, savedGlobals.GameTooltip
        _G.WorldMapFrame, _G.C_Map, _G.IsShiftKeyDown = savedGlobals.WorldMapFrame, savedGlobals.C_Map, savedGlobals.IsShiftKeyDown
        _G.UnitName, _G.UnitClassBase, _G.GetClassColor = savedGlobals.UnitName, savedGlobals.UnitClassBase, savedGlobals.GetClassColor
    end)

    local function RenderObjectiveLines()
        MapIconTooltip.Show(icon)
        local lines = {}
        for _, row in ipairs(GameTooltip.questOrder[1]) do
            for text in pairs(row) do
                lines[text] = true
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
            ["|cFFEEEEEEWindstone Cluster: 9/15 (|cFFFFFFFFLocal|r|cFFEEEEEE)|r"] = true,
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
            ["|cFFEEEEEEWolf slain: 2/5 (Optional) (|cFFFFFFFFLocal|r|cFFEEEEEE)|r"] = true,
            ["|cFFEEEEEEWolf slain: 3/5 (Optional) (|cFFFFFFFFBob|r|cFFEEEEEE)|r"] = true,
        }, RenderObjectiveLines())
        assert.are.equal("Wolf slain (Optional)", objective.Description)
        assert.are.equal("Wolf slain: 2/5 (Optional)", cached[1].objectives[3].text)
    end)

    it("does not show local counters as remote progress when party counts are missing", function()
        cached[1] = {objectives = {[3] = {text = "Windstone Cluster: 9/15"}}}
        QuestieComms.GetQuest = function() return {Bob = {[3] = {}}} end

        assert.are.same({
            ["|cFFEEEEEEWindstone Cluster: 9/15 (|cFFFFFFFFLocal|r|cFFEEEEEE)|r"] = true,
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

    it("keeps remote fallback for an instruction without a recognized counter", function()
        objective.IsPartyObjective = true
        objective.NativeText = "Use Walk on Air"
        objective.Description = "Use Walk on Air"
        QuestieComms.GetQuest = function() return {Bob = {[3] = {fulfilled = 0, required = 1}}} end

        assert.are.same({["|cFFEEEEEE0/1 Use Walk on Air (|cFFFFFFFFBob|r|cFFEEEEEE)|r"] = true}, RenderObjectiveLines())
    end)
end)
