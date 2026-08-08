-- Finds QuestieLoader:CreateModule / ImportModule calls that are made from inside a function body rather
-- than from a file's main chunk.
--
-- Why this matters: QuestieLoader times addon file load by measuring the gap between consecutive module
-- calls, attributing it to the file that opened the interval. A call made at runtime - from an init routine,
-- an event handler, a lazy import - reopens that interval under the calling file's name and charges it
-- whatever happens to run next. That is not hypothetical: installing the profiler's hooks was once reported
-- as QuestieProfiler.lua's load cost because of one such call.
--
-- The in-game loader also ignores non-main-chunk calls, so a slip cannot corrupt measurements. This check
-- exists because that guard depends on `debugstack`, a WoW-only global that cannot run under plain Lua 5.1 -
-- so the pattern is caught here, at commit time, where it can be read and fixed rather than tolerated.
--
-- Scope is decided by Lua's own parser rather than by indentation. Compiling the source up to and including
-- the call reports every block still open at that point, and the report names each one. Only a `function`
-- among them makes the call a runtime call: a file-scope `if` or table constructor is still the main chunk.

local LoaderUsage = {}

-- Escape hatch for a call that genuinely cannot move to file scope. Empty on purpose: hoisting is
-- behaviour-identical, because ImportModule returns the same table CreateModule later populates, so an
-- import placed above the owning file still sees its functions. Exhaust that option before adding an entry.
--
-- Keyed by addon-relative path with forward slashes, exactly as the TOC lists it. The value is the reason,
-- and it is read by a human deciding whether the entry may finally be removed - so give the constraint, not
-- a restatement of the rule. One entry exempts every runtime call in that file, so keep the list short.
LoaderUsage.knownRuntimeCallFiles = {
    -- ["Modules/SomeModule.lua"] = "resolved per call because the module is swapped at runtime by X",
}

-- What to append to close each block the parser can report as unterminated.
local BLOCK_CLOSERS = {
    ["function"] = "\nend",
    ["if"] = "\nend",
    ["for"] = "\nend",
    ["while"] = "\nend",
    ["do"] = "\nend",
    ["repeat"] = "\nuntil true",
    ["{"] = "}",
    ["("] = ")",
    ["["] = "]",
}

-- A prefix ending mid-expression can leave many blocks open; this only bounds a pathological file.
local MAX_OPEN_BLOCKS = 64

---Cheap text filter so the parser only runs on lines that could possibly matter.
---@param line string
---@return boolean
function LoaderUsage.IsCandidateLine(line)
    -- Comments are stripped for this test only; the parser still sees the untouched source. Worst case a
    -- contrived line holding "--" inside a string is skipped, which no call site in the addon looks like.
    local code = string.gsub(line, "%-%-.*$", "")

    -- QuestieLoader.lua declaring its own methods, which read exactly like calls to them.
    if string.match(code, "function%s+QuestieLoader[:.]") then
        return false
    end
    -- Method-call form, and the bracket-indexed form that reaches the same functions.
    return string.match(code, "QuestieLoader:[CI][a-z]*Module%s*%(") ~= nil
        or string.match(code, "QuestieLoader%s*%[") ~= nil
end

---Names every block still open at the end of `sourcePrefix`, outermost last.
---@param sourcePrefix string
---@return string[]? openBlocks @nil when the prefix could not be resolved
---@return string? parseError
function LoaderUsage.EnclosingBlocks(sourcePrefix)
    local openBlocks = {}
    local closingSuffix = ""

    for _ = 1, MAX_OPEN_BLOCKS do
        local chunk, compileError = loadstring(sourcePrefix .. closingSuffix)
        if chunk then
            return openBlocks
        end

        local opener = string.match(compileError or "", "to close '([^']+)' at line %d+")
        local closer = opener and BLOCK_CLOSERS[opener]
        if not closer then
            return nil, compileError
        end

        table.insert(openBlocks, opener)
        closingSuffix = closingSuffix .. closer
    end

    return nil, "more than " .. MAX_OPEN_BLOCKS .. " unterminated blocks"
end

---@param sourcePrefix string @File source up to and including the line being judged
---@return boolean? insideFunction @nil when the prefix could not be resolved
---@return string? parseError
function LoaderUsage.IsInsideFunction(sourcePrefix)
    local openBlocks, parseError = LoaderUsage.EnclosingBlocks(sourcePrefix)
    if not openBlocks then
        return nil, parseError
    end

    for _, block in ipairs(openBlocks) do
        if block == "function" then
            return true
        end
    end
    return false
end

---@param tocPath string
---@return string[] luaPaths @Addon-relative, forward-slashed, in load order
function LoaderUsage.ReadTocLuaPaths(tocPath)
    local paths = {}
    local tocFile = io.open(tocPath, "r")
    if not tocFile then
        return paths
    end

    for line in tocFile:lines() do
        local trimmed = string.gsub(line, "%s+$", "")
        if string.match(trimmed, "%.lua$") and not string.match(trimmed, "^#") then
            table.insert(paths, (string.gsub(trimmed, "\\", "/")))
        end
    end
    tocFile:close()
    return paths
end

---@class LoaderUsageFinding
---@field path string
---@field lineNumber integer
---@field text string
---@field known boolean
---@field enclosingBlocks string[] @Open blocks at the call, outermost last
---@field parseError string? @Set when scope could not be resolved, so a human decides rather than the tool

---@param path string
---@return LoaderUsageFinding[]
function LoaderUsage.ScanFile(path)
    local findings = {}
    local sourceFile = io.open(path, "r")
    if not sourceFile then
        return findings
    end

    local lines = {}
    for line in sourceFile:lines() do
        table.insert(lines, line)
    end
    sourceFile:close()

    local isKnown = LoaderUsage.knownRuntimeCallFiles[path] ~= nil
    for lineNumber, line in ipairs(lines) do
        if LoaderUsage.IsCandidateLine(line) then
            local sourcePrefix = table.concat(lines, "\n", 1, lineNumber)
            local openBlocks, parseError = LoaderUsage.EnclosingBlocks(sourcePrefix)
            local insideFunction = false
            for _, block in ipairs(openBlocks or {}) do
                if block == "function" then
                    insideFunction = true
                end
            end

            if insideFunction or not openBlocks then
                table.insert(findings, {
                    path = path,
                    lineNumber = lineNumber,
                    text = (string.gsub(line, "^%s+", "")),
                    known = isKnown,
                    enclosingBlocks = openBlocks or {},
                    parseError = not openBlocks and parseError or nil,
                })
            end
        end
    end
    return findings
end

---@param tocPaths string[]
---@return LoaderUsageFinding[]
function LoaderUsage.ScanTocs(tocPaths)
    local seenPaths = {}
    local findings = {}
    for _, tocPath in ipairs(tocPaths) do
        for _, luaPath in ipairs(LoaderUsage.ReadTocLuaPaths(tocPath)) do
            if not seenPaths[luaPath] then
                seenPaths[luaPath] = true
                for _, finding in ipairs(LoaderUsage.ScanFile(luaPath)) do
                    table.insert(findings, finding)
                end
            end
        end
    end
    return findings
end

return LoaderUsage
