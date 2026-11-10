dofile("setupTests.lua")

local Harness = dofile("test/MapTooltipDropHarness.lua")

describe("MapIconTooltip quest-item drop cases", function()
    local MapIconTooltip, DropDB, savedGlobals, rendered

    local function SetupTooltipEnv()
        savedGlobals = {
            LibStub = _G.LibStub, GetTime = _G.GetTime, GameTooltip = _G.GameTooltip,
            WorldMapFrame = _G.WorldMapFrame, C_Map = _G.C_Map, IsShiftKeyDown = _G.IsShiftKeyDown,
            GetUnitName = _G.GetUnitName, UnitClassBase = _G.UnitClassBase, GetClassColor = _G.GetClassColor,
            C_CurrencyInfo = _G.C_CurrencyInfo, Minimap = _G.Minimap, GetCVar = _G.GetCVar,
        }
        _G.GetTime = function() return 1 end
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
        QuestieLib.GetColoredQuestName = function(_, questId)
            return "Quest " .. tostring(questId)
        end
        QuestieLib.GetEffectiveQuestLevel = function() return 1, 0 end

        local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
        QuestieDB.GetQuest = function() return {} end
        QuestieDB.QueryItemSingle = function() return "item" end
        QuestieDB.GetQuestTagInfo = function() end
        QuestieDB.GetCreatureLevels = function() return {} end

        QuestieLoader:ImportModule("QuestXP").GetQuestLogRewardXP = function() return 0 end
        QuestieLoader:ImportModule("QuestiePlayer").GetPartyMemberByName = function() end
        QuestieLoader:ImportModule("QuestieComms").GetQuest = function() return nil end
        QuestieLoader:ImportModule("QuestieComms").remotePlayerClasses = {}
        QuestieLoader:ImportModule("QuestLogCache").TryGetQuest = function() return nil end
        dofile("Modules/Quest/ActiveQuests.lua")
        local ActiveQuests = QuestieLoader:ImportModule("ActiveQuests")
        for _, case in ipairs(Harness.Cases()) do
            ActiveQuests.Add(case.questId, {})
        end

        local layout = QuestieLoader:ImportModule("TooltipLayout")
        layout.CreateIndentUI = function() return "", 0 end
        rendered = {}
        layout.CreateRows = function()
            local function Add(_, text) rendered[#rendered + 1] = text end
            return {AddLine = Add, AddDoubleLine = Add}
        end
        layout.Render = function() end
        QuestieLoader:ImportModule("QuestieWaypoints").SetHighlighted = function() end
        QuestieLoader:ImportModule("WaypointHover").End = function() end
        QuestieLoader:ImportModule("QuestieReputation").GetReputationReward = function() return {} end

        _G.LibStub = function()
            return {worldmapProvider = {GetMap = function()
                return {EnumeratePinsByTemplate = function() return function() end end}
            end}}
        end

        dofile("Modules/Tooltips/MapIconTooltip.lua")
        MapIconTooltip = QuestieLoader:ImportModule("MapIconTooltip")
    end

    ---@return string?
    local function RowContaining(text)
        for _, line in ipairs(rendered) do
            if line:find(text, 1, true) then
                return line
            end
        end
    end

    after_each(function()
        if not savedGlobals then
            return
        end
        _G.LibStub, _G.GetTime, _G.GameTooltip = savedGlobals.LibStub, savedGlobals.GetTime, savedGlobals.GameTooltip
        _G.WorldMapFrame, _G.C_Map, _G.IsShiftKeyDown = savedGlobals.WorldMapFrame, savedGlobals.C_Map, savedGlobals.IsShiftKeyDown
        _G.GetUnitName, _G.UnitClassBase, _G.GetClassColor = savedGlobals.GetUnitName, savedGlobals.UnitClassBase, savedGlobals.GetClassColor
        _G.C_CurrencyInfo, _G.Minimap, _G.GetCVar = savedGlobals.C_CurrencyInfo, savedGlobals.Minimap, savedGlobals.GetCVar
    end)

    for _, case in ipairs(Harness.RatedCases()) do
        describe(case.id, function()
            before_each(function()
                SetupTooltipEnv()
                _, DropDB = Harness.LoadDropDB(case)
            end)

            it("resolves DropDB rates for every known source NPC", function()
                for _, source in ipairs(case.sources) do
                    local drop = DropDB.GetItemDroprate(case.itemId, source.npcId)
                    assert.is_not_nil(drop, "missing drop for npc " .. source.npcId)
                    assert.are.equal(source.source, drop[2])
                    assert.are.equal(source.expectedRateText, Harness.FormatDropText(drop[1]))
                end
            end)

            it("renders [N%] on the item objective line for each source pin", function()
                local icons = Harness.BuildIcons(case)
                MapIconTooltip.ShowOnTooltip(icons[1], GameTooltip, nil, icons)

                local tipRow = GameTooltip.questOrder[case.questId][1]
                local itemNeedle = case.objectiveDescription or case.itemName
                for _, source in ipairs(case.sources) do
                    local drop = DropDB.GetItemDroprate(case.itemId, source.npcId)
                    local expected = {
                        name = source.name,
                        suffix = Harness.SuffixFor(source.expectedRateText, drop and drop[1]),
                    }
                    assert.are.same(expected, tipRow.lines[1].sources[source.npcId],
                        "source " .. source.name .. " (" .. source.npcId .. ")")
                    local rateNeedle = source.expectedRateText .. "%"
                    local itemWithRate
                    for _, line in ipairs(rendered) do
                        if line:find(itemNeedle, 1, true) and line:find(rateNeedle, 1, true) then
                            itemWithRate = line
                            break
                        end
                    end
                    assert.is_not_nil(itemWithRate,
                        "expected " .. rateNeedle .. " on item line for " .. source.name)
                    local mobLine
                    for _, line in ipairs(rendered) do
                        if line:find(source.name, 1, true) and not line:find(itemNeedle, 1, true) then
                            mobLine = line
                            break
                        end
                    end
                    assert.is_not_nil(mobLine, "missing mob line for " .. source.name)
                    assert.is_nil(mobLine:find("%]", 1),
                        "drop % must not sit on mob/quest name line for " .. source.name)
                end
            end)

            it("omits rates for NPCs that do not drop the item", function()
                for _, source in ipairs(case.unrelatedSources or {}) do
                    assert.is_nil(DropDB.GetItemDroprate(case.itemId, source.npcId))
                    local icon = Harness.BuildIcon(case, source)
                    MapIconTooltip.ShowOnTooltip(icon, GameTooltip, nil, {icon})
                    local tipRow = GameTooltip.questOrder[case.questId][1]
                    assert.are.same({name = source.name, suffix = ""}, tipRow.lines[1].sources[source.npcId])
                end
            end)

            it("omits rates when the pin lacks ObjectiveTargetId (contract for missing %)", function()
                local source = case.sources[1]
                assert.is_not_nil(DropDB.GetItemDroprate(case.itemId, source.npcId),
                    "fixture must still have a rate so empty tip means missing ObjectiveTargetId")
                local icon = Harness.BuildIcon(case, source, {omitTargetId = true})
                assert.is_nil(icon.data.ObjectiveTargetId)
                MapIconTooltip.ShowOnTooltip(icon, GameTooltip, nil, {icon})
                local tipRow = GameTooltip.questOrder[case.questId][1]
                assert.is_not_nil(tipRow)
                -- Name-keyed fallback (no ObjectiveTargetId); never invent a % from DropDB alone.
                assert.are.same({name = source.name, suffix = ""}, tipRow.lines[1].sources[source.name])
                assert.is_nil(RowContaining("%]"))
            end)
        end)
    end

    for _, case in ipairs(Harness.MissingDropDataCases()) do
        describe(case.id .. " (Forever DropTables gap)", function()
            before_each(function()
                SetupTooltipEnv()
                _, DropDB = Harness.LoadDropDB(case)
            end)

            it("has no DropDB rate for known source NPCs today", function()
                for _, source in ipairs(case.sources) do
                    assert.is_nil(DropDB.GetItemDroprate(case.itemId, source.npcId),
                        "unexpected drop for npc " .. source.npcId .. "; update fixture if Forever added rates")
                end
            end)

            it("renders the source pin without inventing a %", function()
                local icons = Harness.BuildIcons(case)
                MapIconTooltip.ShowOnTooltip(icons[1], GameTooltip, nil, icons)
                local tipRow = GameTooltip.questOrder[case.questId][1]
                assert.is_not_nil(tipRow)
                for _, source in ipairs(case.sources) do
                    assert.are.same({name = source.name, suffix = ""}, tipRow.lines[1].sources[source.npcId])
                end
                assert.is_nil(RowContaining("%]"))
            end)

            it("shows [N%] once a provisional DropDB correction exists (tooltip path is fine)", function()
                assert.is_not_nil(case.provisionalCorrection)
                local filled = {
                    id = case.id,
                    itemId = case.itemId,
                    questId = case.questId,
                    itemName = case.itemName,
                    objectiveDescription = case.objectiveDescription,
                    wowhead = {},
                    cmangos = {},
                    corrections = case.provisionalCorrection,
                    sources = case.sources,
                }
                _, DropDB = Harness.LoadDropDB(filled)
                local icons = Harness.BuildIcons(case)
                MapIconTooltip.ShowOnTooltip(icons[1], GameTooltip, nil, icons)
                local tipRow = GameTooltip.questOrder[case.questId][1]
                local rateText = case.provisionalExpectedRateText
                for _, source in ipairs(case.sources) do
                    local drop = DropDB.GetItemDroprate(case.itemId, source.npcId)
                    assert.is_not_nil(drop)
                    assert.are.equal("questie", drop[2])
                    assert.are.equal(rateText, Harness.FormatDropText(drop[1]))
                    assert.are.same(
                        {name = source.name, suffix = Harness.SuffixFor(rateText, drop[1])},
                        tipRow.lines[1].sources[source.npcId]
                    )
                end
            end)
        end)
    end

    describe("Forever DropTables coverage audit", function()
        it("matches fixture foreverDropTablesStatus against the installed Forever DB", function()
            local dir = Harness.ForeverDropTablesDir()
            if not dir then
                pending("Forever QuestieDB DropTables not installed; set QUESTIE_FOREVER_DB to audit")
                return
            end
            for _, case in ipairs(Harness.Cases()) do
                if case.foreverDropTablesStatus then
                    local present, detail = Harness.ForeverDropTablesHasItem(case.itemId, dir)
                    if case.foreverDropTablesStatus == "present" then
                        assert.is_true(present,
                            case.id .. " item " .. case.itemId .. " should be in Forever DropTables (" .. tostring(detail) .. ")")
                    elseif case.foreverDropTablesStatus == "absent" then
                        assert.is_false(present,
                            case.id .. " item " .. case.itemId
                                .. " appeared in Forever DropTables; clear expectMissingDropData and add real rates ("
                                .. tostring(detail) .. ")")
                    end
                end
            end
        end)
    end)

    describe("consumed-by-hatred-tusks without Era corrections", function()
        local case

        before_each(function()
            case = Harness.Case("consumed-by-hatred-tusks")
            SetupTooltipEnv()
            -- Hierarchy is corrections > cmangos > wowhead; without Era corrections cmangos wins.
            _, DropDB = Harness.LoadDropDB(case, {useCorrections = false})
        end)

        it("falls back to cmangos rates and formats them for the tip", function()
            local classicSources = {}
            for _, source in ipairs(case.sources) do
                if case.cmangosExpected[source.npcId] then
                    classicSources[#classicSources + 1] = source
                end
            end
            local icons, _ = Harness.BuildIcons(case, classicSources)
            for _, source in ipairs(classicSources) do
                local drop = DropDB.GetItemDroprate(case.itemId, source.npcId)
                assert.are.equal("cmangos", drop[2])
                assert.are.equal(case.cmangosExpected[source.npcId], Harness.FormatDropText(drop[1]))
            end

            MapIconTooltip.ShowOnTooltip(icons[1], GameTooltip, nil, icons)
            local tipRow = GameTooltip.questOrder[case.questId][1]
            for _, source in ipairs(classicSources) do
                local drop = DropDB.GetItemDroprate(case.itemId, source.npcId)
                local rateText = case.cmangosExpected[source.npcId]
                assert.are.same(
                    {name = source.name, suffix = Harness.SuffixFor(rateText, drop and drop[1])},
                    tipRow.lines[1].sources[source.npcId]
                )
            end
        end)

        it("uses Forever wowhead rates when cmangos is empty", function()
            local classicSources = {}
            for _, source in ipairs(case.sources) do
                if case.wowheadOnlyExpected[source.npcId] then
                    classicSources[#classicSources + 1] = source
                end
            end
            local wowheadOnly = {
                id = case.id,
                itemId = case.itemId,
                questId = case.questId,
                itemName = case.itemName,
                objectiveDescription = case.objectiveDescription,
                wowhead = case.wowhead,
                cmangos = {},
                sources = classicSources,
            }
            _, DropDB = Harness.LoadDropDB(wowheadOnly, {useCorrections = false})
            local icons, _ = Harness.BuildIcons(case, classicSources)
            for _, source in ipairs(classicSources) do
                local drop = DropDB.GetItemDroprate(case.itemId, source.npcId)
                assert.are.equal("wowhead", drop[2])
                assert.are.equal(case.wowheadOnlyExpected[source.npcId], Harness.FormatDropText(drop[1]))
            end

            MapIconTooltip.ShowOnTooltip(icons[1], GameTooltip, nil, icons)
            local tipRow = GameTooltip.questOrder[case.questId][1]
            for _, source in ipairs(classicSources) do
                local drop = DropDB.GetItemDroprate(case.itemId, source.npcId)
                local rateText = case.wowheadOnlyExpected[source.npcId]
                assert.are.same(
                    {name = source.name, suffix = Harness.SuffixFor(rateText, drop and drop[1])},
                    tipRow.lines[1].sources[source.npcId]
                )
            end
        end)
    end)

    describe("pin data contract from spawn drawing", function()
        it("documents ObjectiveTargetId = spawnData.Id and ObjectiveData.Id = itemId", function()
            -- Mirrors QuestieQuest:_DetermineIconsToDraw for item loot pins.
            local case = Harness.Case("consumed-by-hatred-tusks")
            local spawnData = {
                Id = 3258,
                Name = "Bristleback Hunter",
                ItemId = case.itemId,
            }
            local objective = {
                Index = 1,
                Type = "item",
                Id = case.itemId,
                Description = case.itemName,
            }
            local data = {
                Id = case.questId,
                ObjectiveIndex = objective.Index,
                ObjectiveData = objective,
                Name = spawnData.Name,
                Type = objective.Type,
                ObjectiveTargetId = spawnData.Id,
            }

            assert.are.equal(case.itemId, data.ObjectiveData.Id)
            assert.are.equal(spawnData.Id, data.ObjectiveTargetId)
            assert.are.equal(spawnData.ItemId, data.ObjectiveData.Id)
        end)
    end)
end)
