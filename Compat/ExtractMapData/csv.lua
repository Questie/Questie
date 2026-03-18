--- Read a comma or tab (or other delimiter) separated file.
--  This version of a CSV reader differs from others I've seen in that it
--
--  + handles embedded newlines in fields (if they're delimited with double
--    quotes)
--  + is line-ending agnostic
--  + reads the file line-by-line, so it can potientially handle large
--    files.
--
--  Of course, for such a simple format, CSV is horribly complicated, so it
--  likely gets something wrong.

--  (c) Copyright 2013-2014 Incremental IP Limited.
--  (c) Copyright 2014 Kevin Martin
--  Available under the MIT licence.  See LICENSE for more information.

local DEFAULT_BUFFER_BLOCK_SIZE = 1024 * 1024


------------------------------------------------------------------------------

local function trim_space(s)
  return s:match("^%s*(.-)%s*$")
end


local function fix_quotes(s)
  -- the sub(..., -2) is to strip the trailing quote
  return string.sub(s:gsub('""', '"'), 1, -2)
end


------------------------------------------------------------------------------

local column_map = {}
column_map.__index = column_map


local function normalise_string(s)
  return (s:lower():gsub("[^%w%d]+", " "):gsub("^ *(.-) *$", "%1"))
end


--- Parse a list of columns.
--  The main job here is normalising column names and dealing with columns
--  for which we have more than one possible name in the header.
function column_map:new(columns)
  local name_map = {}
  for n, v in pairs(columns) do
    local names
    local t
    if type(v) == "table" then
      t = { transform = v.transform, default = v.default }
      if v.name then
        names = { normalise_string(v.name) }
      elseif v.names then
        names = v.names
        for i, n in ipairs(names) do names[i] = normalise_string(n) end
      end
    else
      if type(v) == "function" then
        t = { transform = v }
      else
        t = {}
        if type(v) == "string" then
          names = { normalise_string(v) }
        end
      end
    end

    if not names then
      names = { (n:lower():gsub("[^%w%d]+", " ")) }
    end

    t.name = n
    for _, n in ipairs(names) do
      name_map[n:lower()] = t
    end
  end

  return setmetatable({ name_map = name_map }, column_map)
end


--- Map "virtual" columns to file columns.
--  Once we've read the header, work out which columns we're interested in and
--  what to do with them.  Mostly this is about checking we've got the columns
--  we need and writing a nice complaint if we haven't.
function column_map:read_header(header)
  local index_map = {}

  -- Match the columns in the file to the columns in the name map
  local found = {}
  local found_any
  for i, word in ipairs(header) do
    word = normalise_string(word)
    local r = self.name_map[word]
    if r then
      index_map[i] = r
      found[r.name] = true
      found_any = true
    end
  end

  if not found_any then return end

  -- check we found all the columns we need
  local not_found = {}
  for name, r in pairs(self.name_map) do
    if not found[r.name] then
      local nf = not_found[r.name]
      if nf then
        nf[#nf+1] = name
      else
        not_found[r.name] = { name }
      end
    end
  end
  -- If any columns are missing, assemble an error message
  if next(not_found) then
    local problems = {}
    for k, v in pairs(not_found) do
      local missing
      if #v == 1 then
        missing = "'"..v[1].."'"
      else
        missing = v[1]
        for i = 2, #v - 1 do
          missing = missing..", '"..v[i].."'"
        end
        missing = missing.." or '"..v[#v].."'"
      end
      problems[#problems+1] = "Couldn't find a column named "..missing
    end
    error(table.concat(problems, "\n"), 0)
  end

  self.index_map = index_map
  return true
end


function column_map:transform(value, index)
  local field = self.index_map[index]
  if field then
    if field.transform then
      local ok
      ok, value = pcall(field.transform, value)
      if not ok then
        error(("Error reading field '%s': %s"):format(field.name, value), 0)
      end
    end
    return value or field.default, field.name
  end
end


------------------------------------------------------------------------------

local file_buffer = {}
file_buffer.__index = file_buffer

function file_buffer:new(file, buffer_block_size)
  return setmetatable({
      file              = file,
      buffer_block_size = buffer_block_size or DEFAULT_BUFFER_BLOCK_SIZE,
      buffer_start      = 0,
      buffer            = "",
    }, file_buffer)
end


--- Cut the front off the buffer if we've already read it
function file_buffer:truncate(p)
  p = p - self.buffer_start
  if p > self.buffer_block_size then
    local remove = self.buffer_block_size *
      math.floor((p-1) / self.buffer_block_size)
    self.buffer = self.buffer:sub(remove + 1)
    self.buffer_start = self.buffer_start + remove
  end
end


--- Find something in the buffer, extending it if necessary
function file_buffer:find(pattern, init)
  while true do
    local first, last, capture =
      self.buffer:find(pattern, init - self.buffer_start)
    -- if we found nothing, or the last character is at the end of the
    -- buffer (and the match could potentially be longer) then read some
    -- more.
    if not first or last == #self.buffer then
      local s = self.file:read(self.buffer_block_size)
      if not s then
        if not first then
          return
        else
          return first + self.buffer_start, last + self.buffer_start, capture
        end
      end
      self.buffer = self.buffer..s
    else
      return first + self.buffer_start, last + self.buffer_start, capture
    end
  end
end


--- Extend the buffer so we can see more
function file_buffer:extend(offset)
  local extra = offset - #self.buffer - self.buffer_start
  if extra > 0 then
    local size = self.buffer_block_size *
      math.ceil(extra / self.buffer_block_size)
    local s = self.file:read(size)
    if not s then return end
    self.buffer = self.buffer..s
  end
end


--- Get a substring from the buffer, extending it if necessary
function file_buffer:sub(a, b)
  self:extend(b)
  b = b == -1 and b or b - self.buffer_start
  return self.buffer:sub(a - self.buffer_start, b)
end


--- Close a file buffer
function file_buffer:close()
  self.file:close()
  self.file = nil
end


------------------------------------------------------------------------------

local separator_candidates = { ",", "\t", "|" }
local guess_separator_params = { record_limit = 8; }


local function try_separator(buffer, sep, f)
  guess_separator_params.separator = sep
  local min, max = math.huge, 0
  local lines, split_lines = 0, 0
  local iterator = coroutine.wrap(function() f(buffer, guess_separator_params) end)
  for t in iterator do
    min = math.min(min, #t)
    max = math.max(max, #t)
    split_lines = split_lines + (t[2] and 1 or 0)
    lines = lines + 1
  end
  if split_lines / lines > 0.75 then
    return max - min
  else
    return math.huge
  end
end


--- If the user hasn't specified a separator, try to work out what it is.
function guess_separator(buffer, f)
  local best_separator, lowest_diff = "", math.huge
  for _, s in ipairs(separator_candidates) do
    local ok, diff = pcall(function() return try_separator(buffer, s, f) end)
    if ok and diff < lowest_diff then
      best_separator = s
      lowest_diff = diff
    end
  end

  return best_separator
end


local unicode_BOMS =
{
  {
    length = 2,
    BOMS =
    {
      ["\254\255"]      = true, -- UTF-16 big-endian
      ["\255\254"]      = true, -- UTF-16 little-endian
    }
  },
  {
    length = 3,
    BOMS =
    {
      ["\239\187\191"]  = true, -- UTF-8
    }
  }
}


local function find_unicode_BOM(sub)
  for _, x in ipairs(unicode_BOMS) do
    local code = sub(1, x.length)
    if x.BOMS[code] then
      return x.length
    end
  end
  return 0
end


--- Iterate through the records in a file
--  Since records might be more than one line (if there's a newline in quotes)
--  and line-endings might not be native, we read the file in chunks of
--  we read the file in chunks using a file_buffer, rather than line-by-line
--  using io.lines.
local function separated_values_iterator(buffer, parameters)
  local field_start = 1

  local advance
  if buffer.truncate then
    advance = function(n)
      field_start = field_start + n
      buffer:truncate(field_start)
    end
  else
    advance = function(n)
      field_start = field_start + n
    end
  end


  local function field_sub(a, b)
    b = b == -1 and b or b + field_start - 1
    return buffer:sub(a + field_start - 1, b)
  end


  local function field_find(pattern, init)
    init = init or 1
    local f, l, c = buffer:find(pattern, init + field_start - 1)
    if not f then return end
    return f - field_start + 1, l - field_start + 1, c
  end


  -- Is there some kind of Unicode BOM here?
  advance(find_unicode_BOM(field_sub))


  -- Start reading the file
  local sep = "(["..(parameters.separator or
                     guess_separator(buffer, separated_values_iterator)).."\n\r])"
  local line_start = 1
  local line = 1
  local field_count, fields, starts, nonblanks = 0, {}, {}
  local header, header_read
  local field_start_line, field_start_column
  local record_count = 0


  local function problem(message)
    error(("%s:%d:%d: %s"):
      format(parameters.filename, field_start_line, field_start_column,
             message), 0)
  end


  while true do
    local field_end, sep_end, this_sep
    local tidy
    field_start_line = line
    field_start_column = field_start - line_start + 1

    -- If the field is quoted, go find the other quote
    if field_sub(1, 1) == '"' then
      advance(1)
      local current_pos = 0
      repeat
        local a, b, c = field_find('"("?)', current_pos + 1)
        current_pos = b
      until c ~= '"'
      if not current_pos then problem("unmatched quote") end
      tidy = fix_quotes
      field_end, sep_end, this_sep = field_find(" *([^ ])", current_pos+1)
      if this_sep and not this_sep:match(sep) then problem("unmatched quote") end
    else
      field_end, sep_end, this_sep = field_find(sep, 1)
      tidy = trim_space
    end

    -- Look for the separator or a newline or the end of the file
    field_end = (field_end or 0) - 1

    -- Read the field, then convert all the line endings to \n, and
    -- count any embedded line endings
    local value = field_sub(1, field_end)
    value = value:gsub("\r\n", "\n"):gsub("\r", "\n")
    for nl in value:gmatch("\n()") do
      line = line + 1
      line_start = nl + field_start
    end

    value = tidy(value)
    if #value > 0 then nonblanks = true end
    field_count = field_count + 1

    -- Insert the value into the table for this "line"
    local key
    if parameters.column_map and header_read then
      local ok
      ok, value, key = pcall(parameters.column_map.transform,
        parameters.column_map, value, field_count)
      if not ok then problem(value) end
    elseif header then
      key = header[field_count]
    else
      key = field_count
    end
    if key then
      fields[key] = value
      starts[key] = { line=field_start_line, column=field_start_column }
    end

    -- if we ended on a newline then yield the fields on this line.
    if not this_sep or this_sep == "\r" or this_sep == "\n" then
      if parameters.column_map and not header_read then
        header_read = parameters.column_map:read_header(fields)
      elseif parameters.header and not header_read then
        if nonblanks or field_count > 1 then -- ignore blank lines
          header = fields
          header_read = true
        end
      else
        if nonblanks or field_count > 1 then -- ignore blank lines
          coroutine.yield(fields, starts)
          record_count = record_count + 1
          if parameters.record_limit and
             record_count >= parameters.record_limit then
            break
          end
        end
      end
      field_count, fields, starts, nonblanks = 0, {}, {}
    end

    -- If we *really* didn't find a separator then we're done.
    if not sep_end then break end

    -- If we ended on a newline then count it.
    if this_sep == "\r" or this_sep == "\n" then
      if this_sep == "\r" and field_sub(sep_end+1, sep_end+1) == "\n" then
        sep_end = sep_end + 1
      end
      line = line + 1
      line_start = field_start + sep_end
    end

    advance(sep_end)
  end
end


------------------------------------------------------------------------------

local buffer_mt =
{
  lines = function(t)
      return coroutine.wrap(function()
          separated_values_iterator(t.buffer, t.parameters)
        end)
    end,
  close = function(t)
      if t.buffer.close then t.buffer:close() end
    end,
  name = function(t)
      return t.parameters.filename
    end,
}
buffer_mt.__index = buffer_mt


--- Use an existing file or buffer as a stream to read csv from.
--  (A buffer is just something that looks like a string in that we can do
--  `buffer:sub()` and `buffer:find()`)
--  @return a file object
local function use(
  buffer,           -- ?string|file|buffer: the buffer to read from.  If it's:
                    --   - a string, read from that;
                    --   - a file, turn it into a file_buffer;
                    --   - nil, read from stdin
                    -- otherwise assume it's already a a buffer.
  parameters)       -- ?table: parameters controlling reading the file.
                    -- See README.md
  parameters = parameters or {}
  parameters.filename = parameters.filename or "<unknown>"
  parameters.column_map = parameters.columns and
    column_map:new(parameters.columns)

  if not buffer then
    buffer = file_buffer:new(io.stdin)
  elseif io.type(buffer) == "file" then
    buffer = file_buffer:new(buffer)
  end

  local f = { buffer = buffer, parameters = parameters }
  return setmetatable(f, buffer_mt)
end


------------------------------------------------------------------------------

--- Open a file for reading as a delimited file
--  @return a file object
local function open(
  filename,         -- string: name of the file to open
  parameters)       -- ?table: parameters controlling reading the file.
                    -- See README.md
  local file, message = io.open(filename, "r")
  if not file then return nil, message end

  parameters = parameters or {}
  parameters.filename = filename
  return use(file_buffer:new(file), parameters)
end


------------------------------------------------------------------------------

local function makename(s)
  local t = {}
  t[#t+1] = "<(String) "
  t[#t+1] = (s:gmatch("[^\n]+")() or ""):sub(1,15)
  if #t[#t] > 14 then t[#t+1] = "..." end
  t[#t+1] = " >"
  return table.concat(t)
end


--- Open a string for reading as a delimited file
--  @return a file object
local function openstring(
  filecontents,     -- string: The contents of the delimited file
  parameters)       -- ?table: parameters controlling reading the file.
                    -- See README.md

  parameters = parameters or {}


  parameters.filename = parameters.filename or makename(filecontents)
  parameters.buffer_size = parameters.buffer_size or #filecontents
  return use(filecontents, parameters)
end


------------------------------------------------------------------------------

return { open = open, openstring = openstring, use = use }

------------------------------------------------------------------------------
