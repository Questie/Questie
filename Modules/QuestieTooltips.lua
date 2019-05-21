
-- todo: move this in to a proper global
QuestieTooltips = {};


QuestieTooltips.tooltipLookup = {
	--["u_Grell"] = {"Line 1", "Line 2"}
}


function QuestieTooltips:PrintDifficultyColor(level, text)
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

-- key format:
--  The key is the string name of the object the tooltip is relevant to, started with a small flag that specifies the type:
--        units: u_
--        items: i_
--      objects: o_
function QuestieTooltips:RegisterTooltip(key, value)
	QuestieTooltips.tooltipLookup[key] = value;
end

function QuestieTooltips:RemoveTooltip(key)
	QuestieTooltips.tooltipLookup[key] = nil
end






local function TooltipShowing_unit(self)
	local name, ttype = self:GetUnit()
	if name then
		local tooltipData = QuestieTooltips.tooltipLookup["u_" .. name];
		if tooltipData then
			for k,v in pairs(tooltipData) do
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
			for k,v in pairs(tooltipData) do
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