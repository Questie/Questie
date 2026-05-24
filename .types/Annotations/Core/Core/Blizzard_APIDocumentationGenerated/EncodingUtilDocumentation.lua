---@meta _
C_EncodingUtil = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_EncodingUtil.CompressString)
---@param source stringView
---@param method? Enum.CompressionMethod Default = Deflate
---@param level? Enum.CompressionLevel Default = Default
---@return string output
function C_EncodingUtil.CompressString(source, method, level) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_EncodingUtil.DecodeBase64)
---@param source stringView
---@param variant? Enum.Base64Variant Default = Standard
---@return string output
function C_EncodingUtil.DecodeBase64(source, variant) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_EncodingUtil.DecodeHex)
---@param source string
---@return string output
function C_EncodingUtil.DecodeHex(source) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_EncodingUtil.DecompressString)
---@param source stringView
---@param method? Enum.CompressionMethod Default = Deflate
---@return string output
function C_EncodingUtil.DecompressString(source, method) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_EncodingUtil.DeserializeCBOR)
---@param source stringView
---@return LuaValueVariant? value
function C_EncodingUtil.DeserializeCBOR(source) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_EncodingUtil.DeserializeJSON)
---@param source string
---@return LuaValueVariant? value
function C_EncodingUtil.DeserializeJSON(source) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_EncodingUtil.EncodeBase64)
---@param source stringView
---@param variant? Enum.Base64Variant Default = Standard
---@return string output
function C_EncodingUtil.EncodeBase64(source, variant) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_EncodingUtil.EncodeHex)
---@param source stringView
---@return string output
function C_EncodingUtil.EncodeHex(source) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_EncodingUtil.SerializeCBOR)
---@param value? LuaValueVariant
---@param options? CBORSerializationOptions
---@return string output
function C_EncodingUtil.SerializeCBOR(value, options) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_EncodingUtil.SerializeJSON)
---@param value? LuaValueVariant
---@param options? JSONSerializationOptions
---@return string output
function C_EncodingUtil.SerializeJSON(value, options) end

---@class CBORSerializationOptions
---@field ignoreSerializationErrors boolean? Default = false

---@class JSONSerializationOptions
---@field ignoreSerializationErrors boolean? Default = false
