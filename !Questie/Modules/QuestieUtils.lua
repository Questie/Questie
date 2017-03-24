---------------------------------------------------------------------------------------------------
-- Name: QuestieUtils
-- Description: Utility Functions
---------------------------------------------------------------------------------------------------
--///////////////////////////////////////////////////////////////////////////////////////////////--
---------------------------------------------------------------------------------------------------
-- todo give these functions a QuestieUtils: in front
function print_r ( t )
    local print_r_cache={}
    local function sub_print_r(t,indentAmount)
        if (print_r_cache[tostring(t)]) then
            questieDebugPrint(string.rep(" ", indentAmount).."*"..tostring(t))
        else
            print_r_cache[tostring(t)]=true
            if (type(t)=="table") then
                for pos,val in pairs(t) do
                    if (type(val)=="table") then
                        questieDebugPrint(string.rep(" ", indentAmount).."["..pos.."] => "..tostring(t).." {")
                        if next(val) then
                            sub_print_r(val,indentAmount+1)
                        end
                        questieDebugPrint(string.rep(" ", indentAmount).."}")
                    elseif (type(val)=="string") then
                        questieDebugPrint(string.rep(" ", indentAmount).."["..pos..'] => "'..val..'"')
                    else
                        questieDebugPrint(string.rep(" ", indentAmount).."["..pos.."] => "..tostring(val))
                    end
                end
            else
                questieDebugPrint(string.rep(" ", indentAmount)..tostring(t))
            end
        end
    end
    if (type(t)=="table") then
        questieDebugPrint(tostring(t).." {")
        sub_print_r(t,1)
        questieDebugPrint("}")
    else
        sub_print_r(t,1)
    end
    questieDebugPrint()
end
---------------------------------------------------------------------------------------------------
function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end
---------------------------------------------------------------------------------------------------
-- Debug print function
---------------------------------------------------------------------------------------------------
-- todo make existing usages of Questie:debug_Print use this function instead
function questieDebugPrint(...)
    local debugWin = 0;
    local name, shown;
    for i=1, NUM_CHAT_WINDOWS do
        name,_,_,_,_,_,shown = GetChatWindowInfo(i);
        if (string.lower(name) == "questiedebug") then debugWin = i; break; end
    end
    if (debugWin == 0) then return end
    local out = "";
    for i = 1, arg.n, 1 do
        if (i > 1) then out = out .. ", "; end
        local t = type(arg[i]);
        if (t == "string") then
            out = out .. '"'..arg[i]..'"';
        elseif (t == "number") then
            out = out .. arg[i];
        else
            out = out .. dump(arg[i]);
        end
    end
    getglobal("ChatFrame"..debugWin):AddMessage(out, 1.0, 1.0, 0.3);
end
---------------------------------------------------------------------------------------------------
-- Get numeric value from string
---------------------------------------------------------------------------------------------------
function GetNumberFromString(arg)
    if type(arg) == "string" then
        local n
        for x in string.gfind(arg, "%d+") do n = x; end
        n = tonumber(n);
        return n
    end
    return nil
end
---------------------------------------------------------------------------------------------------
-- Simple Rounding Function
---------------------------------------------------------------------------------------------------
function round(x)
	return floor(x+0.5)
end