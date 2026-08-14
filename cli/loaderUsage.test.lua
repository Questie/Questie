dofile("setupTests.lua")

local LoaderUsage = require("cli.loaderUsage")

describe("LoaderUsage", function()
    describe("IsCandidateLine", function()
        local cases = {
            {
                name = "accepts an import call",
                line = 'local QuestieDB = QuestieLoader:ImportModule("QuestieDB")',
                expected = true,
            },
            {
                name = "accepts a CreateModule call",
                line = 'local QuestieTooltips = QuestieLoader:CreateModule("QuestieTooltips")',
                expected = true,
            },
            {
                name = "accepts a chained call",
                line = 'QuestieLoader:ImportModule("Profiler"):Start()',
                expected = true,
            },
            {
                name = "accepts a bracket-indexed call, which reaches the same function",
                line = '    QuestieLoader["ImportModule"](QuestieLoader, "QuestieDB")',
                expected = true,
            },
            {
                name = "accepts a bracket-indexed call through a variable",
                line = '    QuestieLoader[methodName](QuestieLoader, "QuestieDB")',
                expected = true,
            },
            {
                name = "rejects indexing into a loader field, which is not a module call",
                line = '    local module = QuestieLoader._modules["QuestieDB"]',
                expected = false,
            },
            {
                name = "rejects a whole-line comment",
                line = '    -- local QuestieDB = QuestieLoader:ImportModule("QuestieDB")',
                expected = false,
            },
            {
                name = "rejects a call quoted in a trailing comment",
                line = 'local function toggle(key) -- /run QuestieLoader:ImportModule("QuestieMap"):ShowNPC(525)',
                expected = false,
            },
            {
                name = "rejects QuestieLoader declaring its own method",
                line = 'function QuestieLoader:ImportModule(name)',
                expected = false,
            },
            {
                name = "rejects a line with no loader call",
                line = '    local questId = 1234',
                expected = false,
            },
            {
                name = "accepts a dot call, which reaches the same function",
                line = 'local QuestieDB = QuestieLoader.ImportModule(QuestieLoader, "QuestieDB")',
                expected = true,
            },
        }

        for _, case in ipairs(cases) do
            it(case.name, function()
                assert.are_same(case.expected, LoaderUsage.IsCandidateLine(case.line))
            end)
        end
    end)

    describe("IsInsideFunction", function()
        it("reports a file-scope import as main chunk", function()
            assert.is_false(LoaderUsage.IsInsideFunction([[
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")]]))
        end)

        it("reports an import inside a function", function()
            assert.is_true(LoaderUsage.IsInsideFunction([[
function Something.Update()
    local QuestieDB = QuestieLoader:ImportModule("QuestieDB")]]))
        end)

        it("treats a file-scope if block as main chunk", function()
            -- Indentation alone would call this a runtime call; the block is still the main chunk.
            assert.is_false(LoaderUsage.IsInsideFunction([[
if Expansions.Current >= Expansions.Wotlk then
    local QuestieDB = QuestieLoader:ImportModule("QuestieDB")]]))
        end)

        it("treats a file-scope table constructor as main chunk", function()
            assert.is_false(LoaderUsage.IsInsideFunction([[
local handlers = {
    db = QuestieLoader:ImportModule("QuestieDB")]]))
        end)

        it("reports an unindented call inside a function", function()
            -- Indentation alone would miss this entirely.
            assert.is_true(LoaderUsage.IsInsideFunction([[
function Something.Update()
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")]]))
        end)

        it("reports a callback nested deep inside options tables", function()
            assert.is_true(LoaderUsage.IsInsideFunction([[
QuestieOptions.tabs.general = {
    args = {
        yell = {
            set = function(_, value)
                if not value then
                    QuestieLoader:ImportModule("QuestieComms"):RemoveAllRemotePlayers()]]))
        end)

        it("reports a call inside a loop inside a function", function()
            assert.is_true(LoaderUsage.IsInsideFunction([[
function Something.Update()
    for i = 1, 10 do
        QuestieLoader:ImportModule("QuestieDB")]]))
        end)

        it("reports a call inside a repeat block inside a function", function()
            assert.is_true(LoaderUsage.IsInsideFunction([[
function Something.Update()
    repeat
        QuestieLoader:ImportModule("QuestieDB")]]))
        end)
    end)

    describe("JudgedFragment", function()
        it("judges scope at the call, so a one-line function body cannot pass as main chunk", function()
            local line = 'function Foo() local x = QuestieLoader:ImportModule("X") end'

            -- Judged at end of line, the body's own `end` closes the function and the call reads as main
            -- chunk - the dangerous direction, since this validator exists to reject runtime calls.
            assert.is_true(LoaderUsage.IsInsideFunction(LoaderUsage.JudgedFragment(line)))
            assert.is_false(LoaderUsage.IsInsideFunction(line))
        end)

        it("keeps the whole line for the bracket form, which has no call to cut at", function()
            local line = '    QuestieLoader["ImportModule"](QuestieLoader, "QuestieDB")'

            assert.are_same(line .. "\n", LoaderUsage.JudgedFragment(line))
        end)
    end)

    describe("ScanBindingsXml", function()
        it("sees the runtime loader call the TOC-driven scan cannot", function()
            local findings = LoaderUsage.ScanBindingsXml("Bindings.xml")

            assert.are_same(1, #findings)
            assert.are_same(3, findings[1].lineNumber)
            -- Exempted with a reason rather than invisible: a binding body has no file scope to hoist to.
            assert.is_true(findings[1].known)
        end)
    end)

    describe("EnclosingBlocks", function()
        it("names the open blocks innermost first", function()
            assert.are_same({"if", "function"}, LoaderUsage.EnclosingBlocks([[
function Something.Update()
    if ready then
        QuestieLoader:ImportModule("QuestieDB")]]))
        end)

        it("returns no blocks at file scope", function()
            assert.are_same({}, LoaderUsage.EnclosingBlocks('local a = 1'))
        end)
    end)

    describe("the shipped codebase", function()
        local ALL_TOCS = {
            "Questie-Classic.toc",
            "Questie-BCC.toc",
            "Questie-WOTLKC.toc",
            "Questie-Cata.toc",
            "Questie-Mists.toc",
        }

        it("has no runtime call outside the reviewed files", function()
            local unexpected = {}
            for _, finding in ipairs(LoaderUsage.ScanTocs(ALL_TOCS)) do
                if not finding.known then
                    table.insert(unexpected, finding.path .. ":" .. finding.lineNumber)
                end
            end

            assert.are_same({}, unexpected)
        end)

        it("resolves the scope of every call site it inspects", function()
            local unresolved = {}
            for _, finding in ipairs(LoaderUsage.ScanTocs(ALL_TOCS)) do
                if finding.parseError then
                    table.insert(unresolved, finding.path .. ":" .. finding.lineNumber)
                end
            end

            assert.are_same({}, unresolved)
        end)
    end)

    describe("ReadTocLuaPaths", function()
        it("returns lua entries in load order with forward slashes", function()
            local paths = LoaderUsage.ReadTocLuaPaths("Questie-Classic.toc")

            assert.are_same("Modules/Libs/QuestieLoader.lua", paths[1])
            assert.is_true(#paths > 100)
        end)

        it("skips commented entries", function()
            for _, path in ipairs(LoaderUsage.ReadTocLuaPaths("Questie-Classic.toc")) do
                assert.are_same(nil, string.match(path, "^#"))
            end
        end)
    end)
end)
