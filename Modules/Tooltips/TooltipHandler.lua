---@type QuestieTooltips
local QuestieTooltips = QuestieLoader:ImportModule("QuestieTooltips");
local _QuestieTooltips = QuestieTooltips.private

local lastGuid = nil;
function _QuestieTooltips:AddUnitDataToTooltip()
    if (self.IsForbidden and self:IsForbidden()) or (not Questie.db.global.enableTooltips) then
        return
    end

    local name, unitToken = self:GetUnit();
    if not unitToken then return end
    local guid = UnitGUID(unitToken);
    if (not guid) then
        guid = UnitGUID("mouseover");
    end
    local type, zero, server_id, instance_id, zone_uid, npcId, spawn_uid = strsplit("-", guid or "");
    if name and type == "Creature" and (
        name ~= QuestieTooltips.lastGametooltipUnit or
        (not QuestieTooltips.lastGametooltipCount) or
        _QuestieTooltips:CountTooltip() < QuestieTooltips.lastGametooltipCount or
        QuestieTooltips.lastGametooltipType ~= "monster" or
        lastGuid ~= guid
    ) then
        --Questie:Debug(DEBUG_DEVELOP, "[QuestieTooltip] Unit Id on hover : ", npc_id);
        QuestieTooltips.lastGametooltipUnit = name
        local tooltipData = QuestieTooltips:GetTooltip("m_" .. npcId);
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
function _QuestieTooltips:AddItemDataToTooltip()
    if (self.IsForbidden and self:IsForbidden()) or (not Questie.db.global.enableTooltips) then
        return
    end

    local name, link = self:GetItem()
    local itemId = nil;
    if link then
        local _, _, _, _, id, _, _, _, _, _, _, _, _, itemName = string.find(link, "|?c?f?f?(%x*)|?H?([^:]*):?(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%-?%d*):?(%-?%d*):?(%d*):?(%d*):?(%-?%d*)|?h?%[?([^%[%]]*)%]?|?h?|?r?")
        itemId = id;
    end
    if name and itemId and (
        name ~= QuestieTooltips.lastGametooltipItem or
        (not QuestieTooltips.lastGametooltipCount) or
        _QuestieTooltips:CountTooltip() < QuestieTooltips.lastGametooltipCount or
        QuestieTooltips.lastGametooltipType ~= "item" or
        lastItemId ~= itemId or
        QuestieTooltips.lastFrameName ~= self:GetName()
    ) then
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

function _QuestieTooltips:AddObjectDataToTooltip(name)
    if (not Questie.db.global.enableTooltips) then
        return
    end
    if name then
        for index, gameObjectId in pairs(LangObjectNameLookup[name] or {}) do
            local tooltipData = QuestieTooltips:GetTooltip("o_" .. gameObjectId);
            if type(gameObjectId) == "number" and tooltipData then
                --Questie:Debug(DEBUG_DEVELOP, "[QuestieTooltip] Object Id on hover : ", gameObjectId);
                if tooltipData then
                    for _, v in pairs (tooltipData) do
                        GameTooltip:AddLine(v)
                    end
                end
                break
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
        if frame and frame:GetText() then
            tooltipcount = tooltipcount + 1
        else
            return tooltipcount
        end
    end
    return tooltipcount
end
