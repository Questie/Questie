---@meta string_wow
--- added: string.join, string.rtgsub, string.split, strsplittable, string.trim
--- added: strcmputf8i, strlenutf8, strconcat, tostringall
--- removed: string.dump, string.pack, string.packsize, string.unpack
--- obsolete-removed: string.gfind -> renamed to string.gmatch
--- string.rtgsub is from RestrictedTable_rtgsub

---
---
---
---[View documents](command:extension.lua.doc?["en-us/51/manual.html/pdf-string"])
---
---@class stringlib
string = {}

---
---Returns the internal numeric codes of the characters `s[i], s[i+1], ..., s[j]`.
---
---[View documents](command:extension.lua.doc?["en-us/51/manual.html/pdf-string.byte"])
---
---@param s  string|number
---@param i? integer
---@param j? integer
---@return integer ...
---@nodiscard
function string.byte(s, i, j) end

---
---Returns a string with length equal to the number of arguments, in which each character has the internal numeric code equal to its corresponding argument.
---
---[View documents](command:extension.lua.doc?["en-us/51/manual.html/pdf-string.char"])
---
---@param byte integer
---@param ... integer
---@return string
---@nodiscard
function string.char(byte, ...) end

---
---Looks for the first match of `pattern` (see [§6.4.1](command:extension.lua.doc?["en-us/51/manual.html/6.4.1"])) in the string.
---
---[View documents](command:extension.lua.doc?["en-us/51/manual.html/pdf-string.find"])
---
---@param s       string|number
---@param pattern string|number
---@param init?   integer
---@param plain?  boolean
---@return integer|nil start
---@return integer|nil end
---@return any|nil ... captured
---@nodiscard
function string.find(s, pattern, init, plain) end

---
---Returns a formatted version of its variable number of arguments following the description given in its first argument.
---
---[View documents](command:extension.lua.doc?["en-us/51/manual.html/pdf-string.format"])
---
---@param s string|number
---@param ... any
---@return string
---@nodiscard
function string.format(s, ...) end

---
---Returns an iterator function that, each time it is called, returns the next captures from `pattern` (see [§6.4.1](command:extension.lua.doc?["en-us/51/manual.html/6.4.1"])) over the string s.
---
---As an example, the following loop will iterate over all the words from string s, printing one per line:
---```lua
---    s =
---"hello world from Lua"
---    for w in string.gmatch(s, "%a+") do
---        print(w)
---    end
---```
---
---
---[View documents](command:extension.lua.doc?["en-us/51/manual.html/pdf-string.gmatch"])
---
---@param s       string|number
---@param pattern string|number
---@return fun():string, ...
---@nodiscard
function string.gmatch(s, pattern) end

---
---Returns a copy of s in which all (or the first `n`, if given) occurrences of the `pattern` (see [§6.4.1](command:extension.lua.doc?["en-us/51/manual.html/6.4.1"])) have been replaced by a replacement string specified by `repl`.
---
---[View documents](command:extension.lua.doc?["en-us/51/manual.html/pdf-string.gsub"])
---
---@param s       string|number
---@param pattern string|number
---@param repl    string|number|table|function
---@param n?      integer
---@return string
---@return integer count
---@nodiscard
function string.gsub(s, pattern, repl, n) end

---
---Returns its length.
---
---[View documents](command:extension.lua.doc?["en-us/51/manual.html/pdf-string.len"])
---
---@param s string|number
---@return integer
---@nodiscard
function string.len(s) end

---
---Returns a copy of this string with all uppercase letters changed to lowercase.
---
---[View documents](command:extension.lua.doc?["en-us/51/manual.html/pdf-string.lower"])
---
---@param s string|number
---@return string
---@nodiscard
function string.lower(s) end

---
---Looks for the first match of `pattern` (see [§6.4.1](command:extension.lua.doc?["en-us/51/manual.html/6.4.1"])) in the string.
---
---[View documents](command:extension.lua.doc?["en-us/51/manual.html/pdf-string.match"])
---
---@param s       string|number
---@param pattern string|number
---@param init?   integer
---@return any ...
---@nodiscard
function string.match(s, pattern, init) end

---
---Returns a string that is the concatenation of `n` copies of the string `s` .
---
---[View documents](command:extension.lua.doc?["en-us/51/manual.html/pdf-string.rep"])
---
---@param s    string|number
---@param n    integer
---@return string
---@nodiscard
function string.rep(s, n) end

---
---Returns a string that is the string `s` reversed.
---
---[View documents](command:extension.lua.doc?["en-us/51/manual.html/pdf-string.reverse"])
---
---@param s string|number
---@return string
---@nodiscard
function string.reverse(s) end

---
---Returns the substring of the string that starts at `i` and continues until `j`.
---
---[View documents](command:extension.lua.doc?["en-us/51/manual.html/pdf-string.sub"])
---
---@param s  string|number
---@param i  integer
---@param j? integer
---@return string
---@nodiscard
function string.sub(s, i, j) end

---
---Returns a copy of this string with all lowercase letters changed to uppercase.
---
---[View documents](command:extension.lua.doc?["en-us/51/manual.html/pdf-string.upper"])
---
---@param s string|number
---@return string
---@nodiscard
function string.upper(s) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_strjoin)
---@param delim string|number
---@param ... string|number
---@return string
---@nodiscard
function string.join(delim, ...) end

---string.gsub but for restricted tables
---
---[Documentation](https://warcraft.wiki.gg/wiki/API_string.rtgsub)
---@param s       string|number
---@param pattern string|number
---@param repl    string|number|table|function
---@param n?      integer
---@return string
---@return integer count
---@nodiscard
function string.rtgsub(s, pattern, repl, n) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_strsplit)
---@param delimiter string
---@param str string
---@param pieces? number
---@return string ...
---@nodiscard
function string.split(delimiter, str, pieces) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_strsplittable)
---@param delimiter string
---@param str string
---@param pieces? number
---@return string[] chunks
---@nodiscard
function strsplittable(delimiter, str, pieces) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_strtrim)
---@param str string
---@param chars? string
---@return string
---@nodiscard
function string.trim(str, chars) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_strcmputf8i)
---@param str1 string
---@param str2 string
---@return number result <= -1: smaller, 0: equal, >= 1: larger
---@nodiscard
function strcmputf8i(str1, str2) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_strlenutf8)
---@param str string
---@return number
---@nodiscard
function strlenutf8(str) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_strconcat)
---@param ... string
---@return string
---@nodiscard
function strconcat(...) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_tostringall)
---@param ... any
---@return string ...
---@nodiscard
function tostringall(...) end

return string
