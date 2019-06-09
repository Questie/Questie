
-- todo: move this in to a proper global
QuestieTooltips = {};
local _QuestieTooltips = {};
QuestieTooltips.lastTooltipTime = GetTime() -- hack for object tooltips
QuestieTooltips.lastGametooltip = ""
QuestieTooltips.lastGametooltipCount = -1;

QuestieTooltips.tooltipLookup = {
    --["u_Grell"] = {questid, {"Line 1", "Line 2"}}
}


function QuestieTooltips:OldPrintDifficultyColor(level, text)
    local PlayerLevel = qPlayerLevel;
    if level == nil then return "FFFFFFFF"; end
    local levelDiff = level - qPlayerLevel;
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
        level = qPlayerLevel;
    end
    local PlayerLevel = qPlayerLevel;
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
        return (level - math.floor(level / 10) - 5);
    else
        return (level - math.floor(level / 5) - 1);
    end
end

-- key format:
--  The key is the string name of the object the tooltip is relevant to, started with a small flag that specifies the type:
--        units: u_
--        items: i_
--      objects: o_
function QuestieTooltips:RegisterTooltip(questid, key, Objective)
    if QuestieTooltips.tooltipLookup[key] == nil then
        QuestieTooltips.tooltipLookup[key] = {};
    end
    local tooltip = {};
    tooltip.QuestId = questid;
    tooltip.Objective = Objective
    table.insert(QuestieTooltips.tooltipLookup[key], tooltip);
end

function QuestieTooltips:RemoveTooltip(key)
    QuestieTooltips.tooltipLookup[key] = nil
end

function QuestieTooltips:GetTooltip(key)
    if key == nil or QuestieTooltips.tooltipLookup[key] == nil then
        return nil
    end
    local tip = {};
    for k, tooltip in pairs(QuestieTooltips.tooltipLookup[key]) do
        tooltip.Objective:Update() -- update progress

        -- we need Objective:IsComplete()
        local complete = tooltip.Objective.Completed
        if complete and tostring(key):sub(1, #"i_") ~= "i_" then -- BAD CODE: dont remove complete item tooltips
            QuestieTooltips.tooltipLookup[key][k] = nil
        else
            table.insert(tip, tooltip.Objective.QuestData:GetColoredQuestName());
            if tooltip.Objective.Needed then
                table.insert(tip, "   |cFF33FF33" .. tostring(tooltip.Objective.Collected) .. "/" .. tostring(tooltip.Objective.Needed) .. " " .. tostring(tooltip.Objective.Description));
            else
                table.insert(tip, "   |cFF33FF33" .. tostring(tooltip.Objective.Description));
            end
        end
    end
    return tip
end

function QuestieTooltips:RemoveQuest(questid)
    for k, v in pairs(QuestieTooltips.tooltipLookup) do
        local stillHave = false
        for index, tooltip in pairs(v) do
            if tooltip.QuestId == questid then
                table.remove(v, index);
            else
                stillHave = true
            end
        end
        if not stillHave then
            QuestieTooltips.tooltipLookup[k] = nil
        end
    end
end





local function TooltipShowing_unit(self)
    --QuestieTooltips.lastTooltipTime = GetTime()
    local name, ttype = self:GetUnit()
    if name then
        local tooltipData = QuestieTooltips:GetTooltip("u_" .. name);
        if tooltipData then
            for _, v in pairs (tooltipData) do
                GameTooltip:AddLine(v)
            end
        end
    end
end

local function TooltipShowing_item(self)
    --QuestieTooltips.lastTooltipTime = GetTime()
    local name, link = self:GetItem()
    if name then
        local tooltipData = QuestieTooltips:GetTooltip("i_" .. name);
        if tooltipData then
            for _, v in pairs (tooltipData) do
                GameTooltip:AddLine(v)
            end
        end
    end
end

local function TooltipShowing_maybeobject(name)
    if name then
        local tooltipData = QuestieTooltips:GetTooltip("o_" .. name);
        if tooltipData then
            for _, v in pairs (tooltipData) do
                GameTooltip:AddLine(v)
            end
        end
        QuestieTooltips.lastTooltipTime = GetTime()
        GameTooltip:Show()
    end
end

function _QuestieTooltips:countTooltip()
    local tooltipcount = 0
    for i = 1, 25 do
        local frame = _G["GameTooltipTextLeft"..i]
        if(frame and frame:GetText()) then
            tooltipcount = tooltipcount + 1
        else
            return tooltipcount
        end
    end
end

function QuestieTooltips:init()
    GameTooltip:HookScript("OnTooltipSetUnit", TooltipShowing_unit)
    GameTooltip:HookScript("OnTooltipSetItem", TooltipShowing_item)
    GameTooltip:HookScript("OnShow", function(self)
        --local name, unit = self:GetUnit()
        --Questie:Debug(DEBUG_DEVELOP,"SHOW!", unit)
        --if name == nil and unit == nil  then
        --    TooltipShowing_maybeobject(GameTooltipTextLeft1:GetText())
        --nd
    end)
    GameTooltip:HookScript("OnHide", function(self)
        QuestieTooltips.lastGametooltip = ""
    end)

    GameTooltip:HookScript("OnUpdate", function(self)
        local name, unit = self:GetUnit()
        if( name == nil and unit == nil and (QuestieTooltips.lastGametooltip ~= GameTooltipTextLeft1:GetText() or _QuestieTooltips:countTooltip() ~= QuestieTooltips.lastGametooltipCount)) then
            TooltipShowing_maybeobject(GameTooltipTextLeft1:GetText())
            QuestieTooltips.lastGametooltipCount = _QuestieTooltips:countTooltip()
        end
        QuestieTooltips.lastGametooltip = GameTooltipTextLeft1:GetText()
    end)
end

-- todo move this call into loader
QuestieTooltips:init()
