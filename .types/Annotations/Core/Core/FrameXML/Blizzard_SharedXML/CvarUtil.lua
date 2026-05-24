---@meta _
---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CVar.RegisterCVar)
---@param name CVar
---@param value? string
function RegisterCVar(name, value)
	C_CVar.RegisterCVar(name, value);
end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CVar.ResetTestCVars)
function ResetTestCvars()
	C_CVar.ResetTestCVars();
end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CVar.SetCVar)
---@param name CVar
---@param value? boolean|string|number
---@return boolean success
function SetCVar(name, value)
	if type(value) == "boolean" then
		return C_CVar.SetCVar(name, value and "1" or "0");
	else
		return C_CVar.SetCVar(name, value and tostring(value) or nil);
	end
end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CVar.GetCVar)
---@param name CVar
---@return string? value
function GetCVar(name)
	return C_CVar.GetCVar(name);
end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CVar.SetCVarBitfield)
---@param name CVar
---@param index number
---@param value boolean
---@return boolean success
function SetCVarBitfield(name, index, value)
	return C_CVar.SetCVarBitfield(name, index, value);
end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CVar.GetCVarBitfield)
---@param name CVar
---@param index number
---@return boolean? value
function GetCVarBitfield(name, index)
	return C_CVar.GetCVarBitfield(name, index);
end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CVar.GetCVarBool)
---@param name CVar
---@return boolean? value
function GetCVarBool(name)
	return C_CVar.GetCVarBool(name);
end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_CVar.GetCVarDefault)
---@param name CVar
---@return string? defaultValue
function GetCVarDefault(name)
	return C_CVar.GetCVarDefault(name);
end
