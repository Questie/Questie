---@type QuestieTooltips
local QuestieTooltips = QuestieLoader:ImportModule("QuestieTooltips");
local _QuestieTooltips = QuestieTooltips.private

---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")

local lastGuid

function _QuestieTooltips:AddUnitDataToTooltip()
    if (self.IsForbidden and self:IsForbidden()) or (not Questie.db.profile.enableTooltips) then
        return
    end

    local name, unitToken = self:GetUnit();
    if not unitToken then return end
    local guid = UnitGUID(unitToken);
    if (not guid) then
        guid = UnitGUID("mouseover");
    end

    local type, _, _, _, _, npcId, _ = strsplit("-", guid or "");

    if name and (type == "Creature" or type == "Vehicle") and (
        name ~= QuestieTooltips.lastGametooltipUnit or
        (not QuestieTooltips.lastGametooltipCount) or
        _QuestieTooltips:CountTooltip() < QuestieTooltips.lastGametooltipCount or
        QuestieTooltips.lastGametooltipType ~= "monster" or
        lastGuid ~= guid
    ) then
        QuestieTooltips.lastGametooltipUnit = name
        if Questie.db.profile.enableTooltipsNPCID then
            GameTooltip:AddDoubleLine(l10n("NPC ID"), "|cFFFFFFFF" .. npcId .. "|r")
        end

        local tooltipData = QuestieTooltips.GetTooltip("m_" .. npcId);
        if tooltipData then
            for _, v in pairs (tooltipData) do
                GameTooltip:AddLine(v)
            end
        end
        QuestieTooltips.lastGametooltipCount = _QuestieTooltips:CountTooltip()
    elseif (type == "Player") then
        local _, serverid, playerid = strsplit("-", guid or "");
        QuestieTooltips.lastGametooltipUnit = name
        if Questie.devChars[serverid] and tContains(Questie.devChars[serverid], playerid) then
            GameTooltip:AddLine("|T" .. "Interface\\AddOns\\Questie\\Icons\\questie.png" .. ":0|t |cnIQ5:" .. l10n("Questie Developer") .. "|r")
        end
    end
    lastGuid = guid;
    QuestieTooltips.lastGametooltipType = "monster";
end

local checkedQuestStartItems = {} -- cache item IDs that were already checked if they start a quest
local lastItemId = 0;
function _QuestieTooltips:AddItemDataToTooltip()
    if (self.IsForbidden and self:IsForbidden()) or (not Questie.db.profile.enableTooltips) then
        return
    end

    local name, link = self:GetItem()
    local itemId
    if link then
        itemId = select(3, string.match(link, "|?c?f?f?(%x*)|?H?([^:]*):?(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%-?%d*):?(%-?%d*):?(%d*):?(%d*):?(%-?%d*)|?h?%[?([^%[%]]*)%]?|?h?|?r?"))
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
        if Questie.db.profile.enableTooltipsItemID then
            GameTooltip:AddDoubleLine(l10n("Item ID"), "|cFFFFFFFF" .. itemId .. "|r")
        end

        if (not checkedQuestStartItems[itemId]) then
            checkedQuestStartItems[itemId] = true
            local itemIdAsNumber = tonumber(itemId)
            if itemIdAsNumber then
                local startQuestId = QuestieDB.QueryItemSingle(itemIdAsNumber, "startQuest")
                local itemName = QuestieDB.QueryItemSingle(itemIdAsNumber, "name")
                if startQuestId and startQuestId ~= 0 and itemName then
                    QuestieTooltips:RegisterQuestStartTooltip(startQuestId, itemName, itemIdAsNumber, "i_"..itemId, "itemFromMonster")
                end
            end
        end

        local tooltipData = QuestieTooltips.GetTooltip("i_" .. (itemId or 0));
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

---Adds Questie's lines to a hovered world object's tooltip. The client only supplies a name, so two
---questions with different owners are answered separately: the optional Object ID line reads
---composed provider truth, and the quest lines come only from Objects Questie registered tooltip
---data for.
---@param name string
---@param playerZone AreaId
---@return nil
function _QuestieTooltips.AddObjectDataToTooltip(name, playerZone)
    if (not Questie.db.profile.enableTooltips) or (not name) then
        return
    end

    if Questie.db.profile.enableTooltipsObjectID then
        -- Contributors need every composed Object with this name, not only Objects whose quest
        -- tooltip data is currently registered. Login Initialization warms the provider index.
        local ids = LibQuestieDB.Object.IdsByName(name)
        local count = ids and #ids or 0
        if count == 1 then
            GameTooltip:AddDoubleLine(l10n("Object ID"), "|cFFFFFFFF" .. ids[1] .. "|r")
        elseif count > 10 and (not Questie.db.profile.debugEnabled) then
            GameTooltip:AddDoubleLine(l10n("Object ID"), "|cFFFFFFFF" .. ids[1] .. " (10+)|r")
        elseif count > 1 then
            GameTooltip:AddDoubleLine(l10n("Object ID"), "|cFFFFFFFF" .. ids[1] .. " (" .. count .. ")|r")
        end
    end

    -- Quest lines come only from Objects for which Questie registered tooltip data. An append-only
    -- set entry with no remaining tooltip data costs one GetTooltip call that returns nil.
    local addedObjects = 0
    local alreadyAddedObjectiveLines = {}
    for gameObjectId in pairs(QuestieTooltips.objectIdsByName[name] or {}) do
        if addedObjects >= 10 then
            break
        end

        local tooltipData = QuestieTooltips.GetTooltip("o_" .. gameObjectId, playerZone)
        if tooltipData then
            for _, line in pairs(tooltipData) do
                if not alreadyAddedObjectiveLines[line] then
                    alreadyAddedObjectiveLines[line] = true
                    GameTooltip:AddLine(line)
                end
            end
            addedObjects = addedObjects + 1
        end
    end

    GameTooltip:Show()
    QuestieTooltips.lastGametooltipType = "object"
end

function _QuestieTooltips:CountTooltip()
    local tooltipCount = 0
    for i = 1, GameTooltip:NumLines() do
        local frame = _G["GameTooltipTextLeft"..i]
        if frame and frame:GetText() then
            tooltipCount = tooltipCount + 1
        else
            return tooltipCount
        end
    end
    return tooltipCount
end