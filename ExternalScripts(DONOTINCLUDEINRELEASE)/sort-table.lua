-- lua
-- Usage: lua sort_table_by_key.lua [path]

local path = arg[1]

local function read_all_lines(p)
    local f, err = io.open(p, "r")
    if not f then return nil, err end
    local lines = {}
    for line in f:lines() do table.insert(lines, line) end
    f:close()
    return lines
end

local function write_all_lines(p, lines)
    local f, err = io.open(p, "w")
    if not f then return nil, err end
    for _, line in ipairs(lines) do f:write(line, "\n") end
    f:close()
    return true
end

local lines, err = read_all_lines(path)
if not lines then
    io.stderr:write("Error reading file: ", err or "unknown", "\n")
    os.exit(1)
end

-- find the start of the returned table (first '{' after a 'return')
local start_brace_idx, brace_level
for i = 1, #lines do
    if lines[i]:match("return%s*{") then
        start_brace_idx = i
        break
    end
    if lines[i]:match("^%s*return%s*$") then
        -- search for next line(s) with an opening brace
        for j = i, #lines do
            if lines[j]:find("{") then
                start_brace_idx = j
                break
            end
        end
        if start_brace_idx then break end
    end
end

if not start_brace_idx then
    io.stderr:write("Could not find `return {` table in file\n")
    os.exit(1)
end

-- locate matching closing brace by counting braces from start_brace_idx
brace_level = 0
local end_brace_idx
for i = start_brace_idx, #lines do
    -- count braces in the line (handles multiple braces on a line)
    for c in lines[i]:gmatch(".") do
        if c == "{" then brace_level = brace_level + 1 end
        if c == "}" then brace_level = brace_level - 1 end
    end
    if brace_level == 0 then
        end_brace_idx = i
        break
    end
end

if not end_brace_idx then
    io.stderr:write("Could not find matching closing '}'\n")
    os.exit(1)
end

-- parse entries inside the braces
local entries = {} -- key (string) -> value (string)
local keys = {} -- numeric keys list
local first_entry_indent = nil

for i = start_brace_idx + 1, end_brace_idx - 1 do
    local line = lines[i]
    -- match patterns like: [123] = true,   or    [  123 ]=false,  etc.
    local key, val = line:match("^%s*%[(%d+)%]%s*=%s*(.-)%s*,?%s*$")
    if key and val then
        entries[key] = val
        table.insert(keys, tonumber(key))
        if not first_entry_indent then
            first_entry_indent = line:match("^(%s*)%[") or "    "
        end
    end
end

if #keys == 0 then
    io.stderr:write("No numeric table entries found to sort\n")
    os.exit(0)
end

table.sort(keys)

-- build new lines: keep header up to the opening brace line,
-- then the sorted entries, then the original closing brace line and remainder
local out = {}

-- header (up to and including the line that contains the first '{')
for i = 1, start_brace_idx do
    table.insert(out, lines[i])
end

local indent = first_entry_indent or "    "
for _, k in ipairs(keys) do
    local v = entries[tostring(k)]
    -- ensure we preserve the value exactly as captured
    table.insert(out, indent .. "[" .. k .. "] = " .. v .. ",")
end

-- closing brace line (the original) and any following lines
for i = end_brace_idx, #lines do
    table.insert(out, lines[i])
end

local ok, werr = write_all_lines(path, out)
if not ok then
    io.stderr:write("Error writing file: ", werr or "unknown", "\n")
    os.exit(1)
end

print("Sorted table entries by numeric key in " .. path)
