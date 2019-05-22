
-- todo: move this in to a proper global
QuestieTooltips = {};
local _QuestieTooltips = {};


QuestieTooltips.tooltipLookup = {
	--["u_Grell"] = {questid, {"Line 1", "Line 2"}}
}


function QuestieTooltips:OldPrintDifficultyColor(level, text)
	local PlayerLevel = UnitLevel("player");
	if level == nil then return "FFFFFFFF"; end
	local levelDiff = level - UnitLevel("player");
	if (levelDiff >= 5) then
		return "|cFFFF1A1A"..text.."|r";
	elseif (levelDiff >= 3) then
		return "|cFFFF8040"..text.."|r";
	elseif (levelDiff >= -2) then
		return "|cFFFFFF00"..text.."|r";
	elseif (-levelDiff <= GetQuestGreenRange()) then
		return "|cFF40C040"..text.."|r";
	else
		return "|cFFC0C0C0"..text.."|r";
	end
end

function QuestieTooltips:PrintDifficultyColor(level, text)
	if level == -1 then
			level = UnitLevel("player");
	end
	local PlayerLevel = UnitLevel("player");
	if (level > (PlayerLevel + 4)) then
	    return "|cFFFF1A1A"..text.."|r"; -- Red
	elseif (level > (PlayerLevel + 2)) then
	    return "|cFFFF8040"..text.."|r"; -- Orange
	elseif (level <= (PlayerLevel + 2)) and (level >= (PlayerLevel - 2)) then
	    return "|cFFFFFF00"..text.."|r"; -- Yellow
	elseif (level > _QuestieTooltips:GetQuestGreyLevel(PlayerLevel)) then
	    return "|cFF40C040"..text.."|r"; -- Green
	else
	    return "|cFFC0C0C0"..text.."|r"; -- Grey
	end
	return "|cFFffffff"..text.."|r"; --white
end

function _QuestieTooltips:GetQuestGreyLevel(level)
    if (level <= 5) then
        return 0;
    elseif (level <= 39) then
        return (level - math.floor(level/10) - 5);
    else
        return (level - math.floor(level/5) - 1);
    end
end

-- key format:
--  The key is the string name of the object the tooltip is relevant to, started with a small flag that specifies the type:
--        units: u_
--        items: i_
--      objects: o_
function QuestieTooltips:RegisterTooltip(questid, key, value)
	QuestieTooltips.tooltipLookup[key] = {questid, value};
end

function QuestieTooltips:RemoveTooltip(key)
	QuestieTooltips.tooltipLookup[key] = nil
end

function QuestieTooltips:GetTooltip(key)
    return QuestieTooltips.tooltipLookup[key][2];
end

function QuestieTooltips:RemoveQuest(questid)
    for k, v in pairs(QuestieTooltips.tooltipLookup) do
	  if v[1] == questid then
	    QuestieTooltips:RemoveTooltip(k)
	  end
	end
end





local function TooltipShowing_unit(self)
	local name, ttype = self:GetUnit()
	if name then
		local tooltipData = QuestieTooltips.tooltipLookup["u_" .. name];
		if tooltipData then
			for k,v in pairs(tooltipData[2]) do
				GameTooltip:AddLine(v)
			end
		end
	end
end

local function TooltipShowing_item(self)
	local name, link = self:GetItem()
	if name then
		local tooltipData = QuestieTooltips.tooltipLookup["i_" .. name];
		if tooltipData then
			for k,v in pairs(tooltipData[2]) do
				GameTooltip:AddLine(v)
			end
		end
	end
end

function QuestieTooltips:init()
    GameTooltip:HookScript("OnTooltipSetUnit", TooltipShowing_unit)
	GameTooltip:HookScript("OnTooltipSetItem", TooltipShowing_item)
end

-- todo move this call into loader
QuestieTooltips:init()
