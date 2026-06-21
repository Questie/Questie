---@class utf8
local utf8 = QuestieLoader:CreateModule("utf8")


-- ! -------------------------------------------
-- !
-- !  The reason for all these utf-8 things is that chinese characters are multiple "chars" in a lua string
-- !  So if we just do the normal len for strings it would split a chinese character in the middle -
-- !  creating errors ingame.
-- !
-- ! -------------------------------------------
-- UTF-8 char boundary pattern for Lua 5.1 (no \x escapes)
local _CHARPAT = "[%z\1-\127\194-\244][\128-\191]*"

---UTF-8 safe substring function that respects character boundaries.
---Unlike Lua's built-in string.sub which works on bytes, this function works on
---UTF-8 characters to prevent splitting multi-byte characters (like Chinese text).
---@param s string UTF-8 encoded string
---@param i number Start index in characters (1 = first char; negative = from end)
---@param j number? End index in characters (inclusive; positive or negative). If nil, defaults to -1 (last character)
---@return string The UTF-8-safe substring
function utf8.sub(s, i, j)
  -- 1) collect byte-offsets of each UTF-8 character
  local offsets = {}
  for pos in s:gmatch("()" .. _CHARPAT) do
    offsets[#offsets + 1] = pos
  end
  local n = #offsets
  if n == 0 then return "" end

  -- 2) handle defaults & negative indices
  if not j then j = -1 end
  if i < 0 then i = n + 1 + i end
  if j < 0 then j = n + 1 + j end

  -- 3) clamp to [1..n]
  if i < 1 then i = 1 end
  if j > n then j = n end
  if i > j then return "" end

  -- 4) byte positions for slicing
  local start_byte = offsets[i]
  local end_byte = offsets[j + 1] and (offsets[j + 1] - 1) or #s

  return s:sub(start_byte, end_byte)
end

---Returns the number of UTF-8 characters in a string.
---Unlike Lua's built-in string.len which counts bytes, this function counts
---actual UTF-8 characters for proper length calculation.
---@param s string UTF-8 encoded string
---@return number Count of UTF-8 codepoints/characters
function utf8.strlen(s)
  local count = 0
  for _ in s:gmatch(_CHARPAT) do
    count = count + 1
  end
  return count
end

return utf8
