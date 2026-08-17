-- Replays the addon's executable load graph for CLI validators. XML UI declarations are not emulated;
-- only load-time Script and Include elements are executed, recursively and in document order.
local addonName = "Questie"
local addonTable = {}

local function NormalizePath(path)
    path = string.gsub(path, "\\", "/")

    local segments = {}
    for segment in string.gmatch(path, "[^/]+") do
        if segment == ".." then
            table.remove(segments)
        elseif segment ~= "." then
            table.insert(segments, segment)
        end
    end
    return table.concat(segments, "/")
end

local function DirectoryOf(path)
    return string.match(path, "^(.*)/[^/]*$") or ""
end

local function ResolvePath(directory, referencedPath)
    if directory == "" then
        return NormalizePath(referencedPath)
    end
    return NormalizePath(directory .. "/" .. referencedPath)
end

local function ReadFile(path)
    local file, openError = io.open(path, "r")
    if not file then
        error("Error loading " .. path .. ": " .. tostring(openError), 0)
    end

    local contents = file:read("*a")
    file:close()
    return contents
end

local function RunChunk(chunk, path)
    local succeeded, runError = pcall(chunk, addonName, addonTable)
    if not succeeded then
        error("Error loading " .. path .. ": " .. tostring(runError), 0)
    end
end

local function LoadPath(path)
    path = NormalizePath(path)
    if not string.match(string.lower(path), "%.xml$") then
        local chunk, compileError = loadfile(path)
        if not chunk then
            error("Error loading " .. path .. ": " .. tostring(compileError), 0)
        end
        RunChunk(chunk, path)
        return
    end

    -- XML comments may contain disabled Script or Include elements. Remove them before walking the
    -- executable elements in document order, just as the client ignores them.
    local xml = string.gsub(ReadFile(path), "<!%-%-.-%-%->", "")
    local xmlDirectory = DirectoryOf(path)
    local cursor = 1

    while true do
        local elementStart, elementEnd, elementName, attributes =
            string.find(xml, "<([%a]+)([^>]*)>", cursor)
        if not elementStart then
            return
        end
        cursor = elementEnd + 1

        if elementName == "Include" then
            local includedFile = string.match(attributes, 'file%s*=%s*"([^"]+)"')
            if includedFile then
                LoadPath(ResolvePath(xmlDirectory, includedFile))
            end
        elseif elementName == "Script" then
            local scriptFile = string.match(attributes, 'file%s*=%s*"([^"]+)"')
            if scriptFile then
                LoadPath(ResolvePath(xmlDirectory, scriptFile))
            elseif not string.match(attributes, "/%s*$") then
                local closeStart, closeEnd = string.find(xml, "</Script%s*>", cursor)
                if not closeStart then
                    error("Error loading " .. path .. ": unclosed inline Script element", 0)
                end

                local scriptSource = string.sub(xml, cursor, closeStart - 1)
                if string.find(scriptSource, "%S") then
                    local chunk, compileError = loadstring(scriptSource, "@" .. path .. ":<Script>")
                    if not chunk then
                        error("Error loading " .. path .. ": " .. tostring(compileError), 0)
                    end
                    RunChunk(chunk, path .. ":<Script>")
                end
                cursor = closeEnd + 1
            end
        end
    end
end

local function loadTOC(path)
    path = NormalizePath(path)
    local tocDirectory = DirectoryOf(path)
    local tocFile, openError = io.open(path, "r")
    if not tocFile then
        error("Error loading " .. path .. ": " .. tostring(openError), 0)
    end

    for line in tocFile:lines() do
        local entry = string.match(line, "^%s*(.-)%s*$")
        if entry ~= "" and not string.match(entry, "^#") then
            LoadPath(ResolvePath(tocDirectory, entry))
        end
    end
    tocFile:close()
end

return loadTOC
