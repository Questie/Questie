---@meta _
C_CVar = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CVar.GetCVar)
---@param name CVar
---@return string? value
function C_CVar.GetCVar(name) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CVar.GetCVarBitfield)
---@param name CVar
---@param index number
---@return boolean? value
function C_CVar.GetCVarBitfield(name, index) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CVar.GetCVarBool)
---@param name CVar
---@return boolean? value
function C_CVar.GetCVarBool(name) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CVar.GetCVarDefault)
---@param name CVar
---@return string? defaultValue
function C_CVar.GetCVarDefault(name) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CVar.GetCVarInfo)
---@param name string
---@return string value
---@return string defaultValue
---@return boolean isStoredServerAccount
---@return boolean isStoredServerCharacter
---@return boolean isLockedFromUser
---@return boolean isSecure
---@return boolean isReadOnly
function C_CVar.GetCVarInfo(name) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CVar.RegisterCVar)
---@param name string
---@param value? string|number
function C_CVar.RegisterCVar(name, value) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CVar.ResetTestCVars)
function C_CVar.ResetTestCVars() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CVar.SetCVar)
---@param name CVar
---@param value? string|number
---@return boolean success
function C_CVar.SetCVar(name, value) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CVar.SetCVarBitfield)
---@param name CVar
---@param index number
---@param value boolean
---@return boolean success
function C_CVar.SetCVarBitfield(name, index, value) end

---@class CVarInfo
---@field value string
---@field defaultValue string
---@field isStoredServerAccount boolean
---@field isStoredServerCharacter boolean
---@field isLockedFromUser boolean
---@field isSecure boolean
---@field isReadOnly boolean
