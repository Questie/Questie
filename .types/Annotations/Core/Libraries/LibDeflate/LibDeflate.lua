---@meta _
---@class LibDeflate
local lib = {}

---@alias LibDeflate.Dictionary { adler32: integer, hash_tables: table, string_table: table, strlen: integer }

---Calculate the Adler-32 checksum of the string.
---
---See RFC1950 Page 9 https://tools.ietf.org/html/rfc1950 for the definition of Adler-32 checksum.
---@param str string the input string to calcuate its Adler-32 checksum.
---@return integer checksum The Adler-32 checksum, which is greater or equal to 0, and less than 2^32 (4294967296).
function lib:Adler32(str)
end

---Create a preset dictionary.
---
---This function is not fast, and the memory consumption of the produced dictionary is about 50 times of the input string. Therefore, it is suggestted to run
---this function only once in your program.
---
---It is very important to know that if you do use a preset dictionary, compressors and decompressors MUST USE THE SAME dictionary. That is, dictionary must be
---created using the same string. If you update your program with a new dictionary, people with the old version won't be able to transmit data with people with
---the new version. Therefore, changing the dictionary must be done very carefully.
---
---The parameters `strlen` and `adler32` add a layer of verification to ensure the parameter `str` is not modified unintentionally during the program
---development.
---
--- ```
---local dict_str = "1234567890"
---
----- print(dict_str:len(), LibDeflate:Adler32(dict_str))
----- Hardcode the print result below to verify it to avoid accidental modification of 'str' during the program development.
----- string length: 10, Adler-32: 187433486,
----- Don't calculate string length and its Adler-32 at run-time.
---
---local dict = LibDeflate:CreateDictionary(dict_str, 10, 187433486)
--- ```
---
---@param str string The string used as the preset dictionary.<br/>You should put stuffs that frequently appears in the dictionary string and preferablely put more appeared stuff toward the end of the string.<br/>Empty string and string longer than `32768` bytes are not allowed.
---@param strlen integer The length of `str`. Please pass in this parameter as a hardcoded constant, in order to verify the content of `str`. The value of this parameter should be known before your program runs.
---@param adler32 integer The Adler-32 checksum of `str`. Please pass in this parameter as a hardcoded constant, in order to verify the content of `str`. The value of this parameter should be known before your program runs.
---@return LibDeflate.Dictionary dictionary The dictionary used for preset dictionary compression and decompression.
function lib:CreateDictionary(str, strlen, adler32)
end

---Compress using the raw deflate format.
---@param str string The data to be compressed.
---@param configs? table The configuration table to control the compression. If nil, use the default configuration.
---@return string data The compressed data.
---@return integer padding The number of bits padded at the end of output. `0 <= bits < 8`<br/>This means the most significant "bits" of the last byte of the returned compressed data are padding bits and they don't affect decompression. You don't need to use this value unless you want to do some postprocessing to the compressed data.
function lib:CompressDeflate(str, configs)
end

---Compress using the raw deflate format with a preset dictionary.
---@param str string The data to be compressed.
---@param dictionary LibDeflate.Dictionary The preset dictionary produced by `LibDeflate:CreateDictionary`
---@param configs? table The configuration table to control the compression. If nil, use the default configuration.
---@return string data The compressed data.
---@return integer padding The number of bits padded at the end of output. `0 <= bits < 8`<br/>This means the most significant "bits" of the last byte of the returned compressed data are padding bits and they don't affect decompression. You don't need to use this value unless you want to do some postprocessing to the compressed data.
function lib:CompressDeflateWithDict(str, dictionary, configs)
end

---Compress using the zlib format.
---@param str string The data to be compressed.
---@param configs? table The configuration table to control the compression. If nil, use the default configuration.
---@return string data The compressed data.
---@return integer padding The number of bits padded at the end of output. Should always be 0. Zlib formatted compressed data never has padding bits at the end.
function lib:CompressZlib(str, configs)
end

---Compress using the zlib format with a preset dictionary.
---@param str string The data to be compressed.
---@param dictionary LibDeflate.Dictionary The preset dictionary produced by `LibDeflate:CreateDictionary`
---@param configs? table The configuration table to control the compression. If nil, use the default configuration.
---@return string data The compressed data.
---@return integer padding The number of bits padded at the end of output. Should always be 0. Zlib formatted compressed data never has padding bits at the end.
function lib:CompressZlib(str, dictionary, configs)
end

---Decompress a raw deflate compressed data.
---@param str string The data to be decompressed.
---@return string? data If the decompression succeeds, return the decompressed data. If the decompression fails, return nil. You should check if this return value is non-nil to know if the decompression succeeds.
---@return integer? numUnprocessedBytes If the decompression succeeds, return the number of unprocessed bytes in the input compressed data. This return value is a positive integer if the input data is a valid compressed data appended by an arbitary non-empty string. This return value is 0 if the input data does not contain any extra bytes.<br/>If the decompression fails (The first return value of this function is nil), this return value is undefined.
function lib:DecompressDeflate(str)
end

---Decompress a raw deflate compressed data with a preset dictionary.
---@param str string The data to be decompressed.
---@param dictionary LibDeflate.Dictionary The preset dictionary used by `LibDeflate:CompressDeflateWithDict` when the compressed data is produced. Decompression and compression must use the same dictionary. Otherwise wrong decompressed data could be produced without generating any error.
---@return string? data If the decompression succeeds, return the decompressed data. If the decompression fails, return nil. You should check if this return value is non-nil to know if the decompression succeeds.
---@return integer? numUnprocessedBytes If the decompression succeeds, return the number of unprocessed bytes in the input compressed data. This return value is a positive integer if the input data is a valid compressed data appended by an arbitary non-empty string. This return value is 0 if the input data does not contain any extra bytes.<br/>If the decompression fails (The first return value of this function is nil), this return value is undefined.
function lib:DecompressDeflateWithDict(str, dictionary)
end

---Decompress a zlib compressed data.
---@param str string The data to be decompressed.
---@return string? data If the decompression succeeds, return the decompressed data. If the decompression fails, return nil. You should check if this return value is non-nil to know if the decompression succeeds.
---@return integer? numUnprocessedBytes If the decompression succeeds, return the number of unprocessed bytes in the input compressed data. This return value is a positive integer if the input data is a valid compressed data appended by an arbitary non-empty string. This return value is 0 if the input data does not contain any extra bytes.<br/>If the decompression fails (The first return value of this function is nil), this return value is undefined.
function lib:DecompressZlib(str)
end

---Decompress a raw deflate compressed data with a preset dictionary.
---@param str string The data to be decompressed.
---@param dictionary LibDeflate.Dictionary The preset dictionary used by `LibDeflate:CompressZlibWithDict` when the compressed data is produced. Decompression and compression must use the same dictionary. Otherwise wrong decompressed data could be produced without generating any error.
---@return string? data If the decompression succeeds, return the decompressed data. If the decompression fails, return nil. You should check if this return value is non-nil to know if the decompression succeeds.
---@return integer? numUnprocessedBytes If the decompression succeeds, return the number of unprocessed bytes in the input compressed data. This return value is a positive integer if the input data is a valid compressed data appended by an arbitary non-empty string. This return value is 0 if the input data does not contain any extra bytes.<br/>If the decompression fails (The first return value of this function is nil), this return value is undefined.
function lib:DecompressZlibWithDict(str, dictionary)
end

---Create a custom codec with encoder and decoder.
---
---This codec is used to convert an input string to make it not contain some specific bytes. This created codec and the parameters of this function do NOT take
---localization into account. One byte (0-255) in the string is exactly one character (0-255). Credits to LibCompress.
---
---```
----- Create an encoder/decoder that maps all "\000" to "\003", and escape "\001" (and "\002" and "\003") properly
---local codec = LibDeflate:CreateCodec("\000\001", "\002", "\003")
---
---local encoded = codec:Encode(SOME_STRING)
----- "encoded" does not contain "\000" or "\001"
---local decoded = codec:Decode(encoded)
----- assert(decoded == SOME_STRING)
---```
---@param reserved_chars string The created encoder will ensure encoded data does not contain any single character in reserved_chars. This parameter should be non-empty.
---@param escape_chars string The escape character(s) used in the created codec. The codec converts any character included in `reserved_chars` / `escape_chars` / `map_chars` to (one escape char + one character not in `reserved_chars` / `escape_chars` / `map_chars`). You usually only need to provide a length-1 string for this parameter. Length-2 string is only needed when `reserved_chars` + `escape_chars` + `map_chars` is longer than 127. This parameter should be non-empty.
---@param map_chars string The created encoder will map every `reserved_chars:sub(i, i) (1 <= i <= #map_chars)` to `map_chars:sub(i, i)`. This parameter CAN be empty string.
---@return LibDeflate.Codec? codec If the codec cannot be created, return nil. If the codec can be created according to the given parameters, return the codec, which is a encode/decode table.
---@return string? error If the codec is successfully created, return nil. If not, return a string that describes the reason why the codec cannot be created.
function lib:CreateCodec(reserved_chars, escape_chars, map_chars)
end

---Encode the string to make it ready to be transmitted in World of Warcraft addon channel.
---
---The encoded string is guaranteed to contain no NULL ("\000") character.
---@param str string The string to be encoded.
---@return string encoded The encoded string.
function lib:EncodeForWoWAddonChannel(str)
end

---Decode the string produced by `LibDeflate:EncodeForWoWAddonChannel`
---@param str string The string to be decoded.
---@return string? decoded The decoded string if succeeds. nil if fails.
function lib:DecodeForWoWAddonChannel(str)
end

---Encode the string to make it ready to be transmitted in World of Warcraft chat channel.
---
---See also https://warcraft.wiki.gg/wiki/Valid_chat_message_characters
---@param str string The string to be encoded.
---@return string encoded The encoded string.
function lib:EncodeForWoWChatChannel(str)
end

---Decode the string produced by `LibDeflate:EncodeForWoWChatChannel`.
---@param str string The string to be decoded.
---@return string? decoded The decoded string if succeeds. nil if fails.
function lib:DecodeForWoWChatChannel(str)
end

---Encode the string to make it printable.
---
---Credis to WeakAuras2, this function is equivalant to the implementation it is using right now.
---
---The encoded string will be 25% larger than the origin string. However, every single byte of the encoded string will be one of 64 printable ASCII characters
---which are can be easier copied, pasted and displayed. (26 lowercase letters, 26 uppercase letters, 10 numbers digits, left parenthese, or right parenthese)
---@param str string The string to be encoded.
---@return string encoded The encoded string.
function lib:EncodeForPrint(str)
end

---Decode the printable string produced by `LibDeflate:EncodeForPrint`.
---
---`str` will have its prefixed and trailing control characters or space removed before it is decoded, so it is easier to use if "str" comes form user copy and
---paste with some prefixed or trailing spaces. Then decode fails if the string contains any characters cant be produced by `LibDeflate:EncodeForPrint`. That
---means, decode fails if the string contains a characters NOT one of 26 lowercase letters, 26 uppercase letters, 10 numbers digits, left parenthese, or right
---parenthese.
---@param str string The string to be decoded.
---@return string? decoded The decoded string if succeeds. nil if fails.
function lib:DecodeForPrint(str)
end

---@class LibDeflate.Codec
local codec = {}

---@param str string
---@return string encoded The encoded string
function codec:Encode(str)
end

---@param str string
---@return string? decoded The decoded string if succeeds. nil if fails.
function codec:Decode(str)
end
