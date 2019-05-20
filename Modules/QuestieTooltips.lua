
-- todo: move this in to a proper global
QuestieTooltips = {};


QuestieTooltips.tooltipLookup = {
	--["u_Grell"] = {"Line 1", "Line 2"}
}


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