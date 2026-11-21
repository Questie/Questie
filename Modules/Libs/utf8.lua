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

local function _DecodeCodepoint(s, position)
  local first = string.byte(s, position)
  if not first then
    return nil, position
  elseif first < 0x80 then
    return first, position + 1
  elseif first < 0xE0 then
    return (first - 0xC0) * 0x40 + string.byte(s, position + 1) - 0x80, position + 2
  elseif first < 0xF0 then
    return (first - 0xE0) * 0x1000
      + (string.byte(s, position + 1) - 0x80) * 0x40
      + string.byte(s, position + 2) - 0x80, position + 3
  end
  return (first - 0xF0) * 0x40000
    + (string.byte(s, position + 1) - 0x80) * 0x1000
    + (string.byte(s, position + 2) - 0x80) * 0x40
    + string.byte(s, position + 3) - 0x80, position + 4
end

local function _EncodeCodepoint(codepoint)
  if codepoint < 0x80 then
    return string.char(codepoint)
  elseif codepoint < 0x800 then
    return string.char(
      0xC0 + math.floor(codepoint / 0x40),
      0x80 + codepoint % 0x40
    )
  elseif codepoint < 0x10000 then
    return string.char(
      0xE0 + math.floor(codepoint / 0x1000),
      0x80 + math.floor(codepoint / 0x40) % 0x40,
      0x80 + codepoint % 0x40
    )
  end
  return string.char(
    0xF0 + math.floor(codepoint / 0x40000),
    0x80 + math.floor(codepoint / 0x1000) % 0x40,
    0x80 + math.floor(codepoint / 0x40) % 0x40,
    0x80 + codepoint % 0x40
  )
end

local function _LowerCodepoint(codepoint)
  if codepoint >= 0x41 and codepoint <= 0x5A then
    return codepoint + 0x20
  end

  -- Latin-1 Supplement, Latin Extended-A, Greek, and Cyrillic cover the
  -- case-bearing alphabets used by Questie's translations.
  if (codepoint >= 0xC0 and codepoint <= 0xD6) or (codepoint >= 0xD8 and codepoint <= 0xDE) then
    return codepoint + 0x20
  elseif codepoint == 0x1E9E then
    return 0xDF
  elseif codepoint >= 0x100 and codepoint <= 0x12F and codepoint % 2 == 0 then
    return codepoint + 1
  elseif codepoint >= 0x139 and codepoint <= 0x148 and codepoint % 2 == 1 then
    return codepoint + 1
  elseif codepoint >= 0x14A and codepoint <= 0x177 and codepoint % 2 == 0 then
    return codepoint + 1
  elseif codepoint >= 0x179 and codepoint <= 0x17E and codepoint % 2 == 1 then
    return codepoint + 1
  elseif (codepoint >= 0x391 and codepoint <= 0x3A1) or (codepoint >= 0x3A3 and codepoint <= 0x3AB) then
    return codepoint + 0x20
  elseif codepoint >= 0x400 and codepoint <= 0x40F then
    return codepoint + 0x50
  elseif codepoint >= 0x410 and codepoint <= 0x42F then
    return codepoint + 0x20
  elseif codepoint >= 0x460 and codepoint <= 0x480 and codepoint % 2 == 0 then
    return codepoint + 1
  elseif codepoint >= 0xFF21 and codepoint <= 0xFF3A then
    return codepoint + 0x20
  end

  return codepoint
end

---Lowercases ASCII and common case-bearing UTF-8 alphabets without splitting characters.
---@param s string UTF-8 text
---@return string
function utf8.lower(s)
  local lowered = {}
  local position = 1
  while position <= #s do
    local codepoint, nextPosition = _DecodeCodepoint(s, position)
    table.insert(lowered, _EncodeCodepoint(_LowerCodepoint(codepoint)))
    position = nextPosition
  end
  return table.concat(lowered)
end

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

---Computes byte offsets for each UTF-8 character in a string.
---@param s string UTF-8 encoded string
---@return table<number, number> offsets 1-based byte start position of each character
function utf8.computeOffsets(s)
  local offsets = {}
  for pos in s:gmatch("()" .. _CHARPAT) do
    offsets[#offsets + 1] = pos
  end
  return offsets
end

---UTF-8 safe substring using precomputed offsets.
---@param s string UTF-8 encoded string
---@param offsets table<number, number> Precomputed offsets from utf8.computeOffsets
---@param i number Start index in characters (1 = first char; negative = from end)
---@param j number? End index in characters (inclusive; positive or negative). If nil, defaults to -1 (last character)
---@return string The UTF-8-safe substring
function utf8.subWithOffsets(s, offsets, i, j)
  local n = #offsets
  if n == 0 then return "" end

  if not j then j = -1 end
  if i < 0 then i = n + 1 + i end
  if j < 0 then j = n + 1 + j end

  if i < 1 then i = 1 end
  if j > n then j = n end
  if i > j then return "" end

  local start_byte = offsets[i]
  local end_byte = offsets[j + 1] and (offsets[j + 1] - 1) or #s

  return s:sub(start_byte, end_byte)
end

---Converts a UTF-8 character index to a byte index using precomputed offsets.
---WoW's CalculateScreenAreaFromCharacterSpan expects byte indices, not character indices.
---@param offsets table<number, number> Precomputed offsets from utf8.computeOffsets
---@param charIndex number 1-based UTF-8 character index
---@param strLen number String length in bytes
---@return number 1-based byte index
function utf8.charIndexToByteIndexWithOffsets(offsets, charIndex, strLen)
  if charIndex <= 1 then
    return 1
  end

  local n = #offsets

  if charIndex > n then
    return strLen + 1
  end

  return offsets[charIndex]
end

---Converts a UTF-8 character index to a byte index.
---WoW's CalculateScreenAreaFromCharacterSpan expects byte indices, not character indices.
---@param s string UTF-8 encoded string
---@param charIndex number 1-based UTF-8 character index
---@return number 1-based byte index
function utf8.charIndexToByteIndex(s, charIndex)
  if charIndex <= 1 then
    return 1
  end

  local offsets = {}
  for pos in s:gmatch("()" .. _CHARPAT) do
    offsets[#offsets + 1] = pos
  end
  local n = #offsets

  if charIndex > n then
    return #s + 1
  end

  return offsets[charIndex]
end

---Converts a byte index to a UTF-8 character index.
---@param s string UTF-8 encoded string
---@param byteIndex number 1-based byte index
---@return number 1-based UTF-8 character index
function utf8.byteIndexToCharIndex(s, byteIndex)
  if byteIndex <= 1 then
    return 1
  end

  local offsets = {}
  for pos in s:gmatch("()" .. _CHARPAT) do
    offsets[#offsets + 1] = pos
  end
  local n = #offsets

  if byteIndex > #s then
    return n + 1
  end

  for i = 1, n do
    local startByte = offsets[i]
    local endByte = offsets[i + 1] and (offsets[i + 1] - 1) or #s
    if byteIndex >= startByte and byteIndex <= endByte then
      return i
    end
  end

  return n
end
