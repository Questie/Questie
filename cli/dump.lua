------------------------------------------------------------------------------
-- Dump.lua
--
-- Contributed by Iriel, Esamynn and Kirov from DevTools v1.11
-- /dump Implementation
--
-- Globals: DevTools, SLASH_DEVTOOLSDUMP1, DevTools_Dump, DevTools_RunDump
-- Globals: DEVTOOLS_MAX_ENTRY_CUTOFF, DEVTOOLS_LONG_STRING_CUTOFF
-- Globals: DEVTOOLS_DEPTH_CUTOFF, DEVTOOLS_INDENT
-- Globals: DEVTOOLS_USE_TABLE_CACHE, DEVTOOLS_USE_FUNCTION_CACHE
-- Globals: DEVTOOLS_USE_USERDATA_CACHE
---------------------------------------------------------------------------

local DT = {};
DEVTOOLS_MAX_ENTRY_CUTOFF = 30;    -- Maximum table entries shown
DEVTOOLS_LONG_STRING_CUTOFF = 200; -- Maximum string size shown
DEVTOOLS_DEPTH_CUTOFF = 10;        -- Maximum table depth
DEVTOOLS_USE_TABLE_CACHE = true;   -- Look up table names
DEVTOOLS_USE_FUNCTION_CACHE = true;-- Look up function names
DEVTOOLS_USE_USERDATA_CACHE = true;-- Look up userdata names
DEVTOOLS_INDENT='  ';              -- Indentation string
local DEVTOOLS_TYPE_COLOR="";
local DEVTOOLS_TABLEREF_COLOR="";
local DEVTOOLS_CUTOFF_COLOR="";
local DEVTOOLS_TABLEKEY_COLOR="";
local FORMATS = {};
-- prefix type suffix
FORMATS["opaqueTypeVal"] = "%s" .. DEVTOOLS_TYPE_COLOR .. "<%s>%s";
-- prefix type name suffix
FORMATS["opaqueTypeValName"] = "%s" .. DEVTOOLS_TYPE_COLOR .. "<%s %s>%s";
-- type
FORMATS["opaqueTypeKey"] = "<%s>";
-- type name
FORMATS["opaqueTypeKeyName"] = "<%s %s>";
-- value
FORMATS["bracketTableKey"] = "[%s]";
-- prefix value
FORMATS["tableKeyAssignPrefix"] = DEVTOOLS_TABLEKEY_COLOR .. "%s%s=";
-- prefix cutoff
FORMATS["tableEntriesSkipped"] = "%s" .. DEVTOOLS_CUTOFF_COLOR .. "";
-- prefix suffix
FORMATS["tableTooDeep"] = "%s" .. DEVTOOLS_CUTOFF_COLOR .. "%s";
-- prefix value suffix
FORMATS["simpleValue"] = "%s%s%s";
-- prefix tablename suffix
FORMATS["tableReference"] = "%s" .. DEVTOOLS_TABLEREF_COLOR .. "%s%s";
-- Grab a copy various oft-used functions
local rawget = rawget;
local type = type;
local string_len = string.len;
local string_sub = string.sub;
local string_gsub = string.gsub;
local string_format = string.format;
local string_match = string.match;
local function GetScrollingMessageFrame()
	return DEFAULT_CHAT_FRAME or DeveloperConsole.MessageFrame;
end
local function WriteMessage(msg)
	print(msg)
end
local function prepSimple(val, context)
	local valType = type(val);
	if (valType == "nil")  then
		return "nil";
	elseif (valType == "number") then
		return val;
	elseif (valType == "boolean") then
		if (val) then
			return "true";
		else
			return "false";
		end
	elseif (valType == "string") then
		local l = string_len(val);
		if ((l > DEVTOOLS_LONG_STRING_CUTOFF) and
			(DEVTOOLS_LONG_STRING_CUTOFF > 0)) then
			local more = l - DEVTOOLS_LONG_STRING_CUTOFF;
			val = string_sub(val, 1, DEVTOOLS_LONG_STRING_CUTOFF);
			return string_gsub(string_format("%q...+%s",val,more),"[|]", "||");
		else
			return string_gsub(string_format("%q",val),"[|]", "||");
		end
	elseif (valType == "function") then
		local fName = context:GetFunctionName(val);
		if (fName) then
			return string_format(FORMATS.opaqueTypeKeyName, valType, fName);
		else
			return string_format(FORMATS.opaqueTypeKey, valType);
		end
		return string_format(FORMATS.opaqueTypeKey, valType);
	elseif (valType == "userdata") then
		local uName = context:GetUserdataName(val);
		if (uName) then
			return string_format(FORMATS.opaqueTypeKeyName, valType, uName);
		else
			return string_format(FORMATS.opaqueTypeKey, valType);
		end
	elseif (valType == 'table') then
		local tName = context:GetTableName(val);
		if (tName) then
			return string_format(FORMATS.opaqueTypeKeyName, valType, tName);
		else
			return string_format(FORMATS.opaqueTypeKey, valType);
		end
	end
	error("Bad type '" .. valType .. "' to prepSimple");
end
local function prepSimpleKey(val, context)
	local valType = type(val);
	if (valType == "string") then
		local l = string_len(val);
		if ((l <= DEVTOOLS_LONG_STRING_CUTOFF) or
			(DEVTOOLS_LONG_STRING_CUTOFF <= 0)) then
			if (string_match(val, "^[a-zA-Z_][a-zA-Z0-9_]*$")) then
				return val;
			end
		end
	end
	return string_format(FORMATS.bracketTableKey, prepSimple(val, context));
end
local function DevTools_InitFunctionCache(context)
	local ret = {};
	for _,k in ipairs(DT.functionSymbols) do
		local v = getglobal(k);
		if (type(v) == 'function') then
			ret[v] = '[' .. k .. ']';
		end
	end
	for k,v in pairs(getfenv(0)) do
		if (type(v) == 'function') then
			if (not ret[v]) then
				ret[v] = '[' .. k .. ']';
			end
		end
	end
	return ret;
end
local function DevTools_InitUserdataCache(context)
	local ret = {};
	for _,k in ipairs(DT.userdataSymbols) do
		local v = getglobal(k);
		if (type(v) == 'table') then
			local u = rawget(v,0);
			if (type(u) == 'userdata') then
				ret[u] = k .. '[0]';
			end
		end
	end
	for k,v in pairs(getfenv(0)) do
		if (type(v) == 'table') then
			local u = rawget(v, 0);
			if (type(u) == 'userdata') then
				if (not ret[u]) then
					ret[u] = k .. '[0]';
				end
			end
		end
	end
	return ret;
end
local function DevTools_Cache_Nil(self, value, newName)
	return nil;
end
local function DevTools_Cache_Function(self, value, newName)
	if (not self.fCache) then
		self.fCache = DevTools_InitFunctionCache(self);
	end
	local name = self.fCache[value];
	if ((not name) and newName) then
		self.fCache[value] = newName;
	end
	return name;
end
local function DevTools_Cache_Userdata(self, value, newName)
	if (not self.uCache) then
		self.uCache = DevTools_InitUserdataCache(self);
	end
	local name = self.uCache[value];
	if ((not name) and newName) then
		self.uCache[value] = newName;
	end
	return name;
end
local function DevTools_Cache_Table(self, value, newName)
	if (not self.tCache) then
		self.tCache = {};
	end
	local name = self.tCache[value];
	if ((not name) and newName) then
		self.tCache[value] = newName;
	end
	return name;
end
local function DevTools_Write(self, msg)
	print(msg)
end
local DevTools_DumpValue;
local function DevTools_DumpTableContents(val, prefix, firstPrefix, context)
	local showCount = 0;
	local oldDepth = context.depth;
	local oldKey = context.key;
	-- Use this to set the cache name
	context:GetTableName(val, oldKey or 'value');
	local iter = pairs(val);
	local nextK, nextV = iter(val, nil);
	while (nextK) do
		local k,v = nextK, nextV;
		nextK, nextV = iter(val, k);
		showCount = showCount + 1;
		if ((showCount <= DEVTOOLS_MAX_ENTRY_CUTOFF) or
			(DEVTOOLS_MAX_ENTRY_CUTOFF <= 0)) then
			local prepKey = prepSimpleKey(k, context);
			if (oldKey == nil) then
				context.key = prepKey;
			elseif (string_sub(prepKey, 1, 1) == "[") then
				context.key = oldKey .. prepKey
			else
				context.key = oldKey .. "." .. prepKey
			end
			context.depth = oldDepth + 1;
			local rp = string_format(FORMATS.tableKeyAssignPrefix, firstPrefix,
									 prepKey);
			firstPrefix = prefix;
			DevTools_DumpValue(v, prefix, rp,
							   (nextK and ",") or '',
							   context);
		end
	end
	local cutoff = showCount - DEVTOOLS_MAX_ENTRY_CUTOFF;
	if ((cutoff > 0) and (DEVTOOLS_MAX_ENTRY_CUTOFF > 0)) then
		context:Write(string_format(FORMATS.tableEntriesSkipped,firstPrefix,
									cutoff));
	end
	context.key = oldKey;
	context.depth = oldDepth;
	return (showCount > 0)
end
-- Return the specified value
function DevTools_DumpValue(val, prefix, firstPrefix, suffix, context)
	local valType = type(val);
	if (valType == "userdata") then
		local uName = context:GetUserdataName(val, 'value');
		if (uName) then
			context:Write(string_format(FORMATS.opaqueTypeValName,
										firstPrefix, valType, uName, suffix));
		else
			context:Write(string_format(FORMATS.opaqueTypeVal,
										firstPrefix, valType, suffix));
		end
		return;
	elseif (valType == "function") then
		local fName = context:GetFunctionName(val, 'value');
		if (fName) then
			context:Write(string_format(FORMATS.opaqueTypeValName,
										firstPrefix, valType, fName, suffix));
		else
			context:Write(string_format(FORMATS.opaqueTypeVal,
										firstPrefix, valType, suffix));
		end
		return;
	elseif (valType ~= "table")  then
		context:Write(string_format(FORMATS.simpleValue,
									firstPrefix,prepSimple(val, context),
									suffix));
		return;
	end
	local cacheName = context:GetTableName(val);
	if (cacheName) then
		context:Write(string_format(FORMATS.tableReference,
									firstPrefix, cacheName, suffix));
		return;
	end
	if ((context.depth >= DEVTOOLS_DEPTH_CUTOFF) and
		(DEVTOOLS_DEPTH_CUTOFF > 0)) then
		context:Write(string_format(FORMATS.tableTooDeep,
									firstPrefix, suffix));
		return;
	end
	firstPrefix = firstPrefix .. "{";
	local oldPrefix = prefix;
	prefix = prefix .. DEVTOOLS_INDENT;
	context:Write(firstPrefix);
	firstPrefix = prefix;
	local anyContents = DevTools_DumpTableContents(val, prefix, firstPrefix,
												   context);
	context:Write(oldPrefix .. "}" .. suffix);
end
local function Pick_Cache_Function(func, setting)
	if (setting) then
		return func;
	else
		return DevTools_Cache_Nil;
	end
end
function DevTools_RunDump(value, context)
	local prefix = "";
	local firstPrefix = prefix;
	local valType = type(value);
	if (type(value) == 'table') then
		local any =
			DevTools_DumpTableContents(value, prefix, firstPrefix, context);
		if (context.Result) then
			return context:Result();
		end
		if (not any) then
			context:Write("empty result");
		end
		return;
	end
	DevTools_DumpValue(value, '', '', '', context);
	if (context.Result) then
		return context:Result();
	end
end
-- Dump the specified list of value
function DevTools_Dump(value, startKey)
	local context = {
		depth = 0,
		key = startKey,
	};
	context.GetTableName = Pick_Cache_Function(DevTools_Cache_Table,
											   DEVTOOLS_USE_TABLE_CACHE);
	context.GetFunctionName = Pick_Cache_Function(DevTools_Cache_Function,
												  DEVTOOLS_USE_FUNCTION_CACHE);
	context.GetUserdataName = Pick_Cache_Function(DevTools_Cache_Userdata,
												  DEVTOOLS_USE_USERDATA_CACHE);
	context.Write = DevTools_Write;
	DevTools_RunDump(value, context);
end
function DevTools_DumpCommand(msg, editBox)

	if (string_match(msg,"^[A-Za-z_][A-Za-z0-9_]*$")) then
		WriteMessage("Dump: " .. msg);
		local val = _G[msg];
		local tmp = {};
		if (val == nil) then
			local key = string_format(FORMATS.tableKeyAssignPrefix,
									  '', prepSimpleKey(msg, {}));
			WriteMessage(key .. "nil,");
		else
			tmp[msg] = val;
		end
		DevTools_Dump(tmp);
		return;
	end
	WriteMessage("Dump: value=" .. msg);
	local func,err = loadstring("return " .. msg);
	if (not func) then
		WriteMessage("Dump: ERROR: " .. err);
	else
		DevTools_Dump({ func() }, "value");
	end
end
DT.functionSymbols = {};
DT.userdataSymbols = {};
local funcSyms = DT.functionSymbols;
local userSyms = DT.userdataSymbols;
for k,v in pairs(getfenv(0)) do
	if (type(v) == 'function') then
		table.insert(funcSyms, k);
	elseif (type(v) == 'table') then
		if (type(rawget(v,0)) == 'userdata') then
			table.insert(userSyms, k);
		end
	end
end

return DevTools_Dump