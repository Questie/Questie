-- Fixture-driven harness for map tooltip drop rates.
-- Loads DropDB with Forever-shaped Classic support snippets from
-- test/fixtures/questItemDropCases.lua, then wires QuestieDB.GetItemDroprate
-- to the real DropDB path used in production.

local LoadQuestieDBMock = dofile("test/QuestieDBMock.lua")
local cases = dofile("test/fixtures/questItemDropCases.lua")

---@class MapTooltipDropHarness
local Harness = {}

---Mirrors MapIconTooltip/Tooltip FormatDropText for expected suffix assertions.
---@param rate number
---@return string
function Harness.FormatDropText(rate)
    if rate >= 10 then
        return string.format("%.0f", rate)
    elseif rate >= 2 then
        return string.format("%.1f", rate)
    elseif rate >= 0.01 then
        return string.format("%.2f", rate)
    end
    return string.format("%.3f", rate)
end

---pfQuest map tooltip GetColor(rate, 100): red→yellow (0–50%), yellow→green (50–100%).
---@param rate number
---@return string hex RRGGBB
function Harness.DropRateColorHex(rate)
    local perc = (tonumber(rate) or 0) / 100
    local r1, g1, b1, r2, g2, b2
    if perc <= 0.5 then
        perc = perc * 2
        r1, g1, b1 = 1, 0, 0
        r2, g2, b2 = 1, 1, 0
    else
        perc = perc * 2 - 1
        r1, g1, b1 = 1, 1, 0
        r2, g2, b2 = 0, 1, 0
    end
    local r = r1 + (r2 - r1) * perc
    local g = g1 + (g2 - g1) * perc
    local b = b1 + (b2 - b1) * perc
    return string.format("%02x%02x%02x", math.floor(r * 255 + 0.5), math.floor(g * 255 + 0.5), math.floor(b * 255 + 0.5))
end

---pfQuest-style brackets: dark gray `[` `]` with gradient-colored percent text.
---@param rateText string
---@param rate number?
---@return string
function Harness.SuffixFor(rateText, rate)
    local numeric = rate
    if numeric == nil then
        numeric = tonumber(rateText)
    end
    local hex = Harness.DropRateColorHex(numeric or 0)
    return "  |cff555555[|cff" .. hex .. rateText .. "%|cff555555]"
end

---@param npcRates table<number, number>
---@return string
local function EncodeNpcRates(npcRates)
    local parts = {}
    for npcId, rate in pairs(npcRates) do
        parts[#parts + 1] = string.format("[%d] = %s", npcId, tostring(rate))
    end
    table.sort(parts)
    return "{" .. table.concat(parts, ", ") .. "}"
end

---@param itemId number
---@param npcRates table<number, number>
---@return string
local function EncodeItemDropBlob(itemId, npcRates)
    return string.format("return {[%d] = %s}", itemId, EncodeNpcRates(npcRates))
end

---@param case table
---@param opts {useCorrections: boolean?}?
---@return QuestieDBMock mock
---@return DropDB DropDB
function Harness.LoadDropDB(case, opts)
    opts = opts or {}
    local useCorrections = opts.useCorrections ~= false

    dofile("Database/SupportValidation.lua")
    QuestieLoader:ImportModule("SupportValidation").ValidateDropTables = function()
        return true
    end

    local mock = LoadQuestieDBMock()
    local Expansions = QuestieLoader:ImportModule("Expansions")
    Expansions.Current = Expansions.Era
    Questie.IsClassic, Questie.IsTBC, Questie.IsWotlk, Questie.IsCata, Questie.IsMoP =
        true, false, false, false, false

    mock.supportModules.QuestieClassicItemDrops = {
        wowheadData = EncodeItemDropBlob(case.itemId, case.wowhead),
        cmangosData = EncodeItemDropBlob(case.itemId, case.cmangos or {}),
    }
    mock.supportModules.QuestieItemDropCorrections = {
        Era = {},
        Tbc = {},
        Wotlk = {},
        Cata = {},
        MoP = {},
    }
    if useCorrections and case.corrections then
        mock.supportModules.QuestieItemDropCorrections.Era[case.itemId] = case.corrections
    end

    dofile("Database/DropTables/dropDB.lua")
    local DropDB = QuestieLoader:ImportModule("DropDB")
    local valid, report = DropDB:Initialize()
    if not valid then
        error("DropDB:Initialize failed: " .. tostring(report), 2)
    end

    local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
    QuestieDB.GetItemDroprate = function(itemId, npcId)
        return DropDB.GetItemDroprate(itemId, npcId)
    end

    return mock, DropDB
end

---@return table[]
function Harness.Cases()
    return cases
end

---@param caseId string
---@return table
function Harness.Case(caseId)
    for _, case in ipairs(cases) do
        if case.id == caseId then
            return case
        end
    end
    error("unknown quest-item drop case: " .. tostring(caseId), 2)
end

---Builds icon.data shaped like QuestieQuest:_DetermineIconsToDraw for an item drop pin.
---@param case table
---@param source {npcId: number, name: string}
---@param overrides table?
---@return table icon
---@return table objective
function Harness.BuildIcon(case, source, overrides)
    overrides = overrides or {}
    local objective = {
        Index = overrides.objectiveIndex or 1,
        Type = overrides.type or "item",
        Id = overrides.itemId or case.itemId,
        Description = case.objectiveDescription or case.itemName,
        Collected = 0,
        Needed = 10,
        Update = function() end,
    }
    local data = {
        Id = case.questId,
        Type = objective.Type,
        ObjectiveIndex = objective.Index,
        ObjectiveData = objective,
        Name = source.name,
    }
    -- Do not use `flag and nil or id`: in Lua that collapses to `id`.
    if not overrides.omitTargetId then
        data.ObjectiveTargetId = source.npcId
    end
    local icon = {
        x = 50,
        y = 50,
        AreaID = 1,
        texture = {
            GetVertexColor = function() return 1, 1, 1, 1 end,
            SetVertexColor = function() end,
        },
        data = data,
    }
    return icon, objective
end

---Collects one map pin per case source (and optional extras) for ShowOnTooltip.
---@param case table
---@param sources table[]?
---@return table[] icons
---@return table objective
function Harness.BuildIcons(case, sources)
    sources = sources or case.sources
    local icons = {}
    local sharedObjective
    for _, source in ipairs(sources) do
        local icon, objective = Harness.BuildIcon(case, source)
        sharedObjective = sharedObjective or objective
        -- Share one objective table so merge keys match a single item objective line.
        icon.data.ObjectiveData = sharedObjective
        icons[#icons + 1] = icon
    end
    return icons, sharedObjective
end

---Default Forever QuestieDB DropTables dir on this machine; override with QUESTIE_FOREVER_DB.
---@return string?
function Harness.ForeverDropTablesDir()
    local override = os.getenv("QUESTIE_FOREVER_DB")
    if override and override ~= "" then
        return override:gsub("[/\\]$", "") .. "/support/Forever/DropTables"
    end
    local candidates = {
        "C:/Program Files (x86)/World of Warcraft/_forever_/Interface/AddOns/QuestieDB/support/Forever/DropTables",
        "C:/Program Files/World of Warcraft/_forever_/Interface/AddOns/QuestieDB/support/Forever/DropTables",
    }
    for _, dir in ipairs(candidates) do
        local handle = io.open(dir .. "/classicItemDrops.lua", "r")
        if handle then
            handle:close()
            return dir
        end
    end
    return nil
end

---Whether Forever DropTables mention `[itemId] = {` (wowhead, cmangos, or corrections).
---@param itemId number
---@param dropTablesDir string?
---@return boolean? present nil when Forever DropTables are not installed locally
---@return string? detail
function Harness.ForeverDropTablesHasItem(itemId, dropTablesDir)
    dropTablesDir = dropTablesDir or Harness.ForeverDropTablesDir()
    if not dropTablesDir then
        return nil, "Forever DropTables not found (set QUESTIE_FOREVER_DB)"
    end

    local needle = "[" .. tostring(itemId) .. "] ="
    local files = {
        dropTablesDir .. "/classicItemDrops.lua",
        dropTablesDir .. "/itemDropCorrections.lua",
    }
    for _, path in ipairs(files) do
        local handle = io.open(path, "r")
        if handle then
            local contents = handle:read("*a")
            handle:close()
            -- Match `[277277] = {` / `[277277] = { -- name` style rows only.
            if contents:find("%[" .. tostring(itemId) .. "%]%s*=%s*{", 1) then
                return true, path
            end
            if contents:find(needle, 1, true) and contents:find("%[" .. tostring(itemId) .. "%]", 1) then
                -- Fall through; require `{` form for real item rows.
            end
        end
    end
    return false, dropTablesDir
end

---Cases that currently expect empty DropDB (Forever-custom / data gaps).
---@return table[]
function Harness.MissingDropDataCases()
    local missing = {}
    for _, case in ipairs(cases) do
        if case.expectMissingDropData then
            missing[#missing + 1] = case
        end
    end
    return missing
end

---Cases that expect real DropDB rates on the tip.
---@return table[]
function Harness.RatedCases()
    local rated = {}
    for _, case in ipairs(cases) do
        if not case.expectMissingDropData then
            rated[#rated + 1] = case
        end
    end
    return rated
end

return Harness
