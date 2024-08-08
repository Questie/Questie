
-- todo: move this in to a proper global
---@class QuestieTooltips
local QuestieTooltips = QuestieLoader:CreateModule("QuestieTooltips");
-------------------------
--Import modules.
-------------------------
---@type QuestieComms
local QuestieComms = QuestieLoader:ImportModule("QuestieComms");
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib");
---@type QuestiePlayer
local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer");
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB");

local tinsert = table.insert
local _QuestieTooltips = {};
QuestieTooltips.lastTooltipTime = GetTime() -- hack for object tooltips
QuestieTooltips.lastGametooltip = ""
QuestieTooltips.lastGametooltipCount = -1;
QuestieTooltips.lastGametooltipType = "";
QuestieTooltips.lastFrameName = "";

QuestieTooltips.tooltipLookup = {
    --["u_Grell"] = {questid, {"Line 1", "Line 2"}}
}

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
    --tinsert(QuestieTooltips.tooltipLookup[key], tooltip);
    QuestieTooltips.tooltipLookup[key][tostring(questid) .. " " .. Objective.Index] = tooltip
end

function QuestieTooltips:RemoveTooltip(key)
    QuestieTooltips.tooltipLookup[key] = nil
end

function QuestieTooltips:GetTooltip(key)
    if key == nil then
        return nil
    end

    --Do not remove! This is the datastrucutre for tooltipData!
    --[[tooltipdata[questId] = {
        title = coloredTitle,
        objectivesText = {
            [objectiveIndex] = {
                [playerName] = {
                    [color] = color,
                    [text] = text
                }
            }
        }
    }]]--
    local tooltipData = {}

    local name = UnitName("player");

    if(QuestieTooltips.tooltipLookup[key]) then
        for k, tooltip in pairs(QuestieTooltips.tooltipLookup[key]) do
            tooltip.Objective:Update() -- update progress
            local questId = tooltip.Objective.QuestData.Id; --Short hand to make it more readable.
            local objectiveIndex = tooltip.Objective.Index;
            if(not tooltipData[questId]) then
                tooltipData[questId] = {}
                tooltipData[questId].title = tooltip.Objective.QuestData:GetColoredQuestName();
            end

            if not QuestiePlayer.currentQuestlog[questId] then
                QuestieTooltips.tooltipLookup[key][k] = nil
            else
                if(not tooltipData[questId].objectivesText) then
                    tooltipData[questId].objectivesText = {}
                end
                if(not tooltipData[questId].objectivesText[objectiveIndex]) then
                    tooltipData[questId].objectivesText[objectiveIndex] = {}
                end
                if(not tooltipData[questId].objectivesText[objectiveIndex][name]) then
                    tooltipData[questId].objectivesText[objectiveIndex][name] = {}
                end

                local text = nil;
                local color = QuestieLib:GetRGBForObjective(tooltip.Objective)

                if tooltip.Objective.Needed then
                    text = "   " .. color .. tostring(tooltip.Objective.Collected) .. "/" .. tostring(tooltip.Objective.Needed) .. " " .. tostring(tooltip.Objective.Description);
                else
                    text = "   " .. color .. tostring(tooltip.Objective.Description);
                end

                --Reduntant if
                if tooltip.Objective.Needed then
                    tooltipData[questId].objectivesText[objectiveIndex][name] = {["color"] = color, ["text"] = text};
                else
                    tooltipData[questId].objectivesText[objectiveIndex][name] = {["color"] = color, ["text"] = text};
                end
            end
        end
    end

    -- This code is related to QuestieComms, here we fetch all the tooltip data that exist in QuestieCommsData
    -- It uses a similar system like here with i_ID etc as keys.
    local anotherPlayer = false;
    if(QuestieComms and QuestieComms.data:KeyExists(key)) then
        ---@tooltipData @tooltipData[questId][playerName][objectiveIndex].text
        local tooltipDataExternal = QuestieComms.data:GetTooltip(key);
        for questId, playerList in pairs(tooltipDataExternal) do
            if(not tooltipData[questId]) then
                local quest = QuestieDB:GetQuest(questId);
                if quest then
                    tooltipData[questId] = {}
                    tooltipData[questId].title = quest:GetColoredQuestName();
                end
            end
            for playerName, objectives in pairs(playerList) do
                local playerInfo = QuestiePlayer:GetPartyMemberByName(playerName);
                if playerInfo then
                    anotherPlayer = true;
                    for objectiveIndex, objective in pairs(objectives) do
                        if not objective then
                            objective = {}
                        end
                        --Setup data structures that might be missing.
                        if(not tooltipData[questId].objectivesText) then
                            tooltipData[questId].objectivesText = {}
                        end
                        if(not tooltipData[questId].objectivesText[objectiveIndex]) then
                            tooltipData[questId].objectivesText[objectiveIndex] = {}
                        end
                        if(not tooltipData[questId].objectivesText[objectiveIndex][playerName]) then
                            tooltipData[questId].objectivesText[objectiveIndex][playerName] = {}
                        end

                        local text = nil;
                        local color = QuestieLib:GetRGBForObjective(objective)

                        if objective.required then
                            text = "   " .. color .. tostring(objective.fulfilled) .. "/" .. tostring(objective.required) .. " " .. objective.text;
                        else
                            text = "   " .. color .. objective.text;
                        end

                        tooltipData[questId].objectivesText[objectiveIndex][playerName] = {["color"] = color, ["text"] = text};
                    end
                end
            end
        end
    end
    local tip = nil;
    --[[tooltipdata[questId] = {
    title = coloredTitle,
    objectivesText = {
        [objectiveIndex] = {
            [playerName] = {
                [color] = color,
                [text] = text
            }
        }
    }
    }]]--
    for questId, questData in pairs(tooltipData) do
        --Initialize it here to return nil if tooltipData is empty.
        if(tip == nil) then
            tip = {}
        end
        tinsert(tip, questData.title);
        local tempObjectives = {}
        for objectiveIndex, playerList in pairs(questData.objectivesText or {}) do -- Should we do or {} here?
            for playerName, objectiveInfo in pairs(playerList) do
                local playerInfo = QuestiePlayer:GetPartyMemberByName(playerName);
                local useName = "";
                if(playerName == name and anotherPlayer) then
                    local _, classFilename = UnitClass("player");
                    local _, _, _, argbHex = GetClassColor(classFilename)
                    useName = " (|c"..argbHex..name.."|r"..objectiveInfo.color..")|r";
                elseif(playerInfo and playerName ~= name) then
                    useName = " (|c"..playerInfo.colorHex..playerName.."|r"..objectiveInfo.color..")|r";
                end
                if(anotherPlayer) then
                    objectiveInfo.text = objectiveInfo.text..useName;
                end
                -- We want the player to be on top.
                if(playerName == name) then
                    tinsert(tempObjectives, 1, objectiveInfo.text);
                else
                    tinsert(tempObjectives, objectiveInfo.text);
                end
            end
        end
        for index, text in pairs(tempObjectives) do
            tinsert(tip, text);
        end
    end
    return tip
end

function QuestieTooltips:RemoveQuest(questid)
    for k, v in pairs(QuestieTooltips.tooltipLookup) do
        local stillHave = false
        for index, tooltip in pairs(v) do
            if tooltip.QuestId == questid then
                v[index] = nil
            else
                stillHave = true
            end
        end
        if not stillHave then
            QuestieTooltips.tooltipLookup[k] = nil
        end
    end
end




local lastGuid = nil;
local function TooltipShowing_unit(self)
    if self.IsForbidden and self:IsForbidden() then return; end
    if not Questie.db.global.enableTooltips then return; end
    --QuestieTooltips.lastTooltipTime = GetTime()
    local name, unitToken = self:GetUnit();
    if not unitToken then return end
    local guid = UnitGUID(unitToken);
    if(guid == nil) then
      guid = UnitGUID("mouseover");
    end
    local type, zero, server_id, instance_id, zone_uid, npc_id, spawn_uid = strsplit("-",guid or "");
    if name and type=="Creature" and (name ~= QuestieTooltips.lastGametooltipUnit or (not QuestieTooltips.lastGametooltipCount) or _QuestieTooltips:CountTooltip() < QuestieTooltips.lastGametooltipCount or QuestieTooltips.lastGametooltipType ~= "monster" or lastGuid ~= guid) then
        --Questie:Debug(DEBUG_DEVELOP, "[QuestieTooltip] Unit Id on hover : ", npc_id);
        QuestieTooltips.lastGametooltipUnit = name
        local tooltipData = QuestieTooltips:GetTooltip("m_" .. npc_id);
        if tooltipData then
            for _, v in pairs (tooltipData) do
                GameTooltip:AddLine(v)
            end
        end
        QuestieTooltips.lastGametooltipCount = _QuestieTooltips:CountTooltip()
    end
    lastGuid = guid;
    QuestieTooltips.lastGametooltipType = "monster";
end

local lastItemId = 0;
local function TooltipShowing_item(self)
    if self.IsForbidden and self:IsForbidden() then return; end
    if not Questie.db.global.enableTooltips then return; end
    --QuestieTooltips.lastTooltipTime = GetTime()
    local name, link = self:GetItem()
    local itemId = nil;
    if(link) then
        local _, _, _, _, id, _, _, _, _, _, _, _, _, itemName = string.find(link, "|?c?f?f?(%x*)|?H?([^:]*):?(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%-?%d*):?(%-?%d*):?(%d*):?(%d*):?(%-?%d*)|?h?%[?([^%[%]]*)%]?|?h?|?r?")
        itemId = id;
    end
    if name and itemId and (name ~= QuestieTooltips.lastGametooltipItem or (not QuestieTooltips.lastGametooltipCount) or _QuestieTooltips:CountTooltip() < QuestieTooltips.lastGametooltipCount or QuestieTooltips.lastGametooltipType ~= "item" or lastItemId ~= itemId or QuestieTooltips.lastFrameName ~= self:GetName()) then
        QuestieTooltips.lastGametooltipItem = name
        --Questie:Debug(DEBUG_DEVELOP, "[QuestieTooltip] Item Id on hover : ", itemId);
        local tooltipData = QuestieTooltips:GetTooltip("i_" .. (itemId or 0));
        if tooltipData then
            for _, v in pairs (tooltipData) do
                self:AddLine(v)
            end
        end
        QuestieTooltips.lastGametooltipCount = _QuestieTooltips:CountTooltip()
    end
    lastItemId = itemId;
    QuestieTooltips.lastGametooltipType = "item";
    QuestieTooltips.lastFrameName = self:GetName();
end



local function TooltipShowing_maybeobject(name)
    if not Questie.db.global.enableTooltips then return; end
    if name then
        for index, gameObjectId in pairs(LangObjectNameLookup[name] or {}) do
            local tooltipData = QuestieTooltips:GetTooltip("o_" .. gameObjectId);
            if(type(gameObjectId)=="number" and tooltipData)then
                --Questie:Debug(DEBUG_DEVELOP, "[QuestieTooltip] Object Id on hover : ", gameObjectId);
                if tooltipData then
                    for _, v in pairs (tooltipData) do
                        GameTooltip:AddLine(v)
                    end
                end
                QuestieTooltips.lastTooltipTime = GetTime()
                break;
            end
        end
        GameTooltip:Show()
    end
    QuestieTooltips.lastGametooltipType = "object";
end

function _QuestieTooltips:CountTooltip()
    local tooltipcount = 0
    for i = 1, 25 do -- Should probably use GameTooltip:NumLines() instead.
        local frame = _G["GameTooltipTextLeft"..i]
        if(frame and frame:GetText()) then
            tooltipcount = tooltipcount + 1
        else
            return tooltipcount
        end
    end
    return tooltipcount
end

function QuestieTooltips:Initialize()
    -- For the clicked item frame.
    ItemRefTooltip:HookScript("OnTooltipSetItem", TooltipShowing_item)
    ItemRefTooltip:HookScript("OnHide", function(self)
        if (not self.IsForbidden) or (not self:IsForbidden()) then -- do we need this here also
            QuestieTooltips.lastGametooltip = ""
            QuestieTooltips.lastGametooltipItem = nil
            QuestieTooltips.lastGametooltipUnit = nil
            QuestieTooltips.lastGametooltipCount = 0
            QuestieTooltips.lastFrameName = "";
        end
    end)

    -- For the hover frame.
    GameTooltip:HookScript("OnTooltipSetUnit", TooltipShowing_unit)
    GameTooltip:HookScript("OnTooltipSetItem", TooltipShowing_item)
    GameTooltip:HookScript("OnShow", function(self)
        if (not self.IsForbidden) or (not self:IsForbidden()) then -- do we need this here also
            QuestieTooltips.lastGametooltipItem = nil
            QuestieTooltips.lastGametooltipUnit = nil
            QuestieTooltips.lastGametooltipCount = 0
            QuestieTooltips.lastFrameName = "";
        end
    end)
    GameTooltip:HookScript("OnHide", function(self)
        if (not self.IsForbidden) or (not self:IsForbidden()) then -- do we need this here also
            QuestieTooltips.lastGametooltip = ""
            QuestieTooltips.lastGametooltipItem = nil
            QuestieTooltips.lastGametooltipUnit = nil
            QuestieTooltips.lastGametooltipCount = 0
        end
    end)

    GameTooltip:HookScript("OnUpdate", function(self)
        if (not self.IsForbidden) or (not self:IsForbidden()) then
            --Because this is an OnUpdate we need to check that it is actually not a Unit or Item to think its a
            local uName, unit = self:GetUnit()
            local iName, link = self:GetItem()
            if((uName == nil and unit == nil and iName == nil and link == nil) and (QuestieTooltips.lastGametooltip ~= GameTooltipTextLeft1:GetText() or (not QuestieTooltips.lastGametooltipCount) or _QuestieTooltips:CountTooltip() < QuestieTooltips.lastGametooltipCount  or QuestieTooltips.lastGametooltipType ~= "object")) then
                TooltipShowing_maybeobject(GameTooltipTextLeft1:GetText())
                QuestieTooltips.lastGametooltipCount = _QuestieTooltips:CountTooltip()
            end
            QuestieTooltips.lastGametooltip = GameTooltipTextLeft1:GetText()
        end
    end)
end
