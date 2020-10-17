---@class QuestieTooltips
local QuestieTooltips = QuestieLoader:CreateModule("QuestieTooltips");
local _QuestieTooltips = QuestieTooltips.private
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
local LSM30 = LibStub("LibSharedMedia-3.0", true)
QuestieTooltips.lastGametooltip = ""
QuestieTooltips.lastGametooltipCount = -1;
QuestieTooltips.lastGametooltipType = "";
QuestieTooltips.lastFrameName = "";

QuestieTooltips.tooltipLookup = {
    --["u_Grell"] = {questid, {"Line 1", "Line 2"}}
}

local _InitObjectiveTexts

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

function QuestieTooltips:GetTooltip(key)
    Questie:Debug(DEBUG_DEVELOP, "[QuestieTooltips:GetTooltip]", key)
    if key == nil then
        return nil
    end

    if GetNumGroupMembers() > 15 then
        return nil -- temporary disable tooltips in raids, we should make a proper fix
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

    local playerName = UnitName("player");

    if QuestieTooltips.tooltipLookup[key] then
        for k, tooltip in pairs(QuestieTooltips.tooltipLookup[key]) do
            local objective = tooltip.Objective
            if (not objective.IsSourceItem) then
                -- Tooltip was registered for a sourceItem and not a real "objective"
                objective:Update() -- update progress
            end

            local questId = objective.QuestData.Id; --Short hand to make it more readable.
            local objectiveIndex = objective.Index;
            if(not tooltipData[questId]) then
                tooltipData[questId] = {}
                tooltipData[questId].title = objective.QuestData:GetColoredQuestName();
            end

            if not QuestiePlayer.currentQuestlog[questId] then
                QuestieTooltips.tooltipLookup[key][k] = nil
            else

                tooltipData[questId].objectivesText = _InitObjectiveTexts(tooltipData[questId].objectivesText, objectiveIndex, playerName)

                local text = nil;
                local color = QuestieLib:GetRGBForObjective(objective)

                if objective.Needed then
                    text = "   " .. color .. tostring(objective.Collected) .. "/" .. tostring(objective.Needed) .. " " .. tostring(objective.Description);
                    tooltipData[questId].objectivesText[objectiveIndex][playerName] = {["color"] = color, ["text"] = text};
                else
                    text = "   " .. color .. tostring(objective.Description);
                    tooltipData[questId].objectivesText[objectiveIndex][playerName] = {["color"] = color, ["text"] = text};
                end
            end
        end
    end

    -- This code is related to QuestieComms, here we fetch all the tooltip data that exist in QuestieCommsData
    -- It uses a similar system like here with i_ID etc as keys.
    local anotherPlayer = false;
    if QuestieComms and QuestieComms.data:KeyExists(key) then
        ---@tooltipData @tooltipData[questId][playerName][objectiveIndex].text
        local tooltipDataExternal = QuestieComms.data:GetTooltip(key);
        for questId, playerList in pairs(tooltipDataExternal) do
            if (not tooltipData[questId]) then
                local quest = QuestieDB:GetQuest(questId);
                if quest then
                    tooltipData[questId] = {}
                    tooltipData[questId].title = quest:GetColoredQuestName();
                end
            end
            for playerName, objectives in pairs(playerList) do
                local playerInfo = QuestiePlayer:GetPartyMemberByName(playerName);
                if playerInfo or QuestieComms.remotePlayerEnabled[playerName] then
                    anotherPlayer = true
                    break
                end
            end
            if anotherPlayer then
                break
            end
        end
    end

    if QuestieComms and QuestieComms.data:KeyExists(key) and anotherPlayer then
        ---@tooltipData @tooltipData[questId][playerName][objectiveIndex].text
        local tooltipDataExternal = QuestieComms.data:GetTooltip(key);
        for questId, playerList in pairs(tooltipDataExternal) do
            if (not tooltipData[questId]) then
                local quest = QuestieDB:GetQuest(questId);
                if quest then
                    tooltipData[questId] = {}
                    tooltipData[questId].title = quest:GetColoredQuestName();
                end
            end
            for playerName, objectives in pairs(playerList) do
                local playerInfo = QuestiePlayer:GetPartyMemberByName(playerName);
                if playerInfo or QuestieComms.remotePlayerEnabled[playerName] then
                    anotherPlayer = true;
                    for objectiveIndex, objective in pairs(objectives) do
                        if (not objective) then
                            objective = {}
                        end

                        tooltipData[questId].objectivesText =  _InitObjectiveTexts(tooltipData[questId].objectivesText, objectiveIndex, playerName)

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

    local tip = nil

    for questId, questData in pairs(tooltipData) do
        --Initialize it here to return nil if tooltipData is empty.
        if (not tip) then
            tip = {}
        end
        local hasObjective = false
        local tempObjectives = {}
        for objectiveIndex, playerList in pairs(questData.objectivesText or {}) do -- Should we do or {} here?
            for playerName, objectiveInfo in pairs(playerList) do
                local playerInfo = QuestiePlayer:GetPartyMemberByName(playerName)
                local playerColor = nil
                local playerType = ""
                if playerInfo then
                    playerColor = "|c" .. playerInfo.colorHex
                elseif QuestieComms.remotePlayerEnabled[playerName] and QuestieComms.remoteQuestLogs[questId] and QuestieComms.remoteQuestLogs[questId][playerName] and (not Questie.db.global.onlyPartyShared or UnitInParty(playerName)) then
                    playerColor = QuestieComms.remotePlayerClasses[playerName]
                    if playerColor then
                        playerColor = Questie:GetClassColor(playerColor)
                        playerType = " ("..QuestieLocale:GetUIString("Nearby")..")"
                    end
                end
                if playerName == playerName and anotherPlayer then -- why did we have this case
                    local _, classFilename = UnitClass("player");
                    local _, _, _, argbHex = GetClassColor(classFilename)
                    objectiveInfo.text = objectiveInfo.text.." (|c"..argbHex..playerName.."|r"..objectiveInfo.color..")|r"
                elseif playerColor and playerName ~= playerName then
                    objectiveInfo.text = objectiveInfo.text.." ("..playerColor..playerName.."|r"..objectiveInfo.color..")|r"..playerType
                end
                -- We want the player to be on top.
                if playerName == playerName then
                    tinsert(tempObjectives, 1, objectiveInfo.text);
                    hasObjective = true
                elseif playerColor then
                    tinsert(tempObjectives, objectiveInfo.text);
                    hasObjective = true
                end
            end
        end
        if hasObjective then
            tinsert(tip, questData.title);
            for index, text in pairs(tempObjectives) do
                tinsert(tip, text);
            end
        end
    end
    return tip
end

_InitObjectiveTexts = function (objectivesText, objectiveIndex, playerName)
    if (not objectivesText) then
        objectivesText = {}
    end
    if (not objectivesText[objectiveIndex]) then
        objectivesText[objectiveIndex] = {}
    end
    if (not objectivesText[objectiveIndex][playerName]) then
        objectivesText[objectiveIndex][playerName] = {}
    end
    return objectivesText
end

function QuestieTooltips:RemoveQuest(questid)
    Questie:Debug(DEBUG_DEVELOP, "[QuestieTooltips:RemoveQuest]", questid)
    for key, tooltipData in pairs(QuestieTooltips.tooltipLookup) do
        local stillHave = false
        for index, tooltip in pairs(tooltipData) do
            if tooltip.QuestId == questid then
                tooltipData[index] = nil
            else
                stillHave = true
            end
        end
        if not stillHave then
            QuestieTooltips.tooltipLookup[key] = nil
        end
    end
end

function QuestieTooltips:Initialize()
    -- For the clicked item frame.
    ItemRefTooltip:HookScript("OnTooltipSetItem", _QuestieTooltips.AddItemDataToTooltip)
    ItemRefTooltip:HookScript("OnHide", function(self)
        if (not self.IsForbidden) or (not self:IsForbidden()) then -- do we need this here also
            QuestieTooltips.lastGametooltip = ""
            QuestieTooltips.lastItemRefTooltip = ""
            QuestieTooltips.lastGametooltipItem = nil
            QuestieTooltips.lastGametooltipUnit = nil
            QuestieTooltips.lastGametooltipCount = 0
            QuestieTooltips.lastFrameName = "";
        end
    end)

    -- For the hover frame.
    GameTooltip:HookScript("OnTooltipSetUnit", _QuestieTooltips.AddUnitDataToTooltip)
    GameTooltip:HookScript("OnTooltipSetItem", _QuestieTooltips.AddItemDataToTooltip)
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
            QuestieTooltips.lastItemRefTooltip = ""
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
            if (uName == nil and unit == nil and iName == nil and link == nil) and (
                QuestieTooltips.lastGametooltip ~= GameTooltipTextLeft1:GetText() or
                (not QuestieTooltips.lastGametooltipCount) or
                _QuestieTooltips:CountTooltip() < QuestieTooltips.lastGametooltipCount
                or QuestieTooltips.lastGametooltipType ~= "object"
            ) then
                _QuestieTooltips:AddObjectDataToTooltip(GameTooltipTextLeft1:GetText())
                QuestieTooltips.lastGametooltipCount = _QuestieTooltips:CountTooltip()
            end
            QuestieTooltips.lastGametooltip = GameTooltipTextLeft1:GetText()
        end
    end)
end

