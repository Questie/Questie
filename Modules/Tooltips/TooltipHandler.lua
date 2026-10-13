---@type QuestieTooltips
local QuestieTooltips = QuestieLoader:ImportModule("QuestieTooltips");
local _QuestieTooltips = QuestieTooltips.private

---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestiePlayer
local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")

local lastGuid

-- Forever can hide unit and tooltip values, inside instances and for some tooltips in combat. The lookups
-- below test, compare and split them, so a secret value must be checked before any of that.
local function _IsSecret(value)
    return issecretvalue and issecretvalue(value)
end

function _QuestieTooltips:AddUnitDataToTooltip()
    if (self.IsForbidden and self:IsForbidden()) or (not Questie.db.profile.enableTooltips) then
        return
    end

    local name, unitToken = self:GetUnit();
    if _IsSecret(name) or _IsSecret(unitToken) or not unitToken then return end
    local guid = UnitGUID(unitToken);
    if _IsSecret(guid) then return end
    if (not guid) then
        guid = UnitGUID("mouseover");
        if _IsSecret(guid) then return end
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

-- itemId -> questId of a one-time quest this character's race and class can take, or false
local oneTimeQuestByStartItem = {}

---Returns the quest an item starts when it can only be turned in once and is available to the player,
---so items like Head of Onyxia only report the quest of the player's own faction.
---@param itemId number
---@return QuestId?
local function _GetOneTimeStartQuest(itemId)
    local cached = oneTimeQuestByStartItem[itemId]
    if cached ~= nil then
        return cached or nil
    end

    local questId = QuestieDB.QueryItemSingle(itemId, "startQuest")
    if (not questId) or questId == 0
        or QuestieDB.IsRepeatable(questId)
        or (not QuestiePlayer.HasRequiredRace(QuestieDB.QueryQuestSingle(questId, "requiredRaces")))
        or (not QuestiePlayer.HasRequiredClass(QuestieDB.QueryQuestSingle(questId, "requiredClasses"))) then
        questId = nil
    end

    oneTimeQuestByStartItem[itemId] = questId or false
    return questId
end

---Adds whether the one-time quest started by an item is active, not done, or turned in (with its Journey date when known).
---Added outside of GetTooltip so it still shows in raids, where most of these items drop.
---@param tooltip GameTooltip
---@param itemId number
local function _AddStartQuestCompletionToTooltip(tooltip, itemId)
    local questId = _GetOneTimeStartQuest(itemId)
    if not questId then
        return
    end

    -- Same copy and colors as the quest link tooltip.
    if QuestiePlayer.currentQuestlog[questId] then
        tooltip:AddLine(Questie:Colorize(l10n("You are on this quest"), "green"))
        return
    elseif not Questie.db.char.complete[questId] then
        tooltip:AddLine(Questie:Colorize(l10n("You have not done this quest"), "yellow"))
        return
    end

    local timestamp
    local journey = Questie.db.char.journey
    if journey then
        for i = #journey, 1, -1 do
            if journey[i].Quest == questId and journey[i].SubType == "Complete" and journey[i].Timestamp then
                timestamp = journey[i].Timestamp
                break
            end
        end
    end

    -- Quests turned in before Journey recorded them have no date.
    tooltip:AddLine(Questie:Colorize(l10n("You have completed this quest"), "green"))
    if timestamp then
        tooltip:AddLine(l10n("Completed on") .. l10n(": ") .. Questie:Colorize(QuestieLib.FormatDate(timestamp), "lightBlue"))
    end
end

function _QuestieTooltips:AddItemDataToTooltip()
    if (self.IsForbidden and self:IsForbidden()) or (not Questie.db.profile.enableTooltips) then
        return
    end

    local name, link = self:GetItem()
    if _IsSecret(name) or _IsSecret(link) then return end
    local itemId
    if link then
        -- Read the payload independently of legacy hex colors or modern named colors such as |cnIQ1:.
        itemId = string.match(link, "item:(%d+)")
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
            -- A clicked item link shows in ItemRefTooltip; its ID belongs there, not on the hover tooltip.
            self:AddDoubleLine(l10n("Item ID"), "|cFFFFFFFF" .. itemId .. "|r")
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

        local itemIdAsNumber = tonumber(itemId)
        if itemIdAsNumber then
            _AddStartQuestCompletionToTooltip(self, itemIdAsNumber)
        end
        QuestieTooltips.lastGametooltipCount = _QuestieTooltips:CountTooltip()
    end
    lastItemId = itemId;
    QuestieTooltips.lastGametooltipType = "item";
    QuestieTooltips.lastFrameName = self:GetName();
end

---Resolves a hovered name through the provider, then adds local and party quest lines for matching Objects.
---The caller owns showing/resizing the tooltip after its native render pass.
---@param name string
---@param playerZone AreaId
---@return nil
function _QuestieTooltips.AddObjectDataToTooltip(name, playerZone)
    if (not Questie.db.profile.enableTooltips) or (not name) then
        return
    end

    -- Name ambiguity depends on all provider Objects, even when the Object ID line is disabled.
    -- Login Initialization warms the provider index.
    local ids = LibQuestieDB.Object.IdsByName(name)
    local count = ids and #ids or 0
    if Questie.db.profile.enableTooltipsObjectID then
        if count == 1 then
            GameTooltip:AddDoubleLine(l10n("Object ID"), "|cFFFFFFFF" .. ids[1] .. "|r")
        elseif count > 10 and (not Questie.db.profile.debugEnabled) then
            GameTooltip:AddDoubleLine(l10n("Object ID"), "|cFFFFFFFF" .. ids[1] .. " (10+)|r")
        elseif count > 1 then
            GameTooltip:AddDoubleLine(l10n("Object ID"), "|cFFFFFFFF" .. ids[1] .. " (" .. count .. ")|r")
        end
    end

    -- Only a provider-wide unique name can bypass zone disambiguation (0 = any zone).
    local zoneFilter = count == 1 and 0 or playerZone

    local addedObjects = 0
    local alreadyAddedObjectiveLines = {}
    -- GetTooltip checks local and Comms registrations; party-only Objects need no local registration.
    for _, gameObjectId in ipairs(ids or {}) do
        if addedObjects >= 10 then
            break
        end

        local tooltipData = QuestieTooltips.GetTooltip("o_" .. gameObjectId, zoneFilter)
        if tooltipData and next(tooltipData) then
            for _, line in pairs(tooltipData) do
                if not alreadyAddedObjectiveLines[line] then
                    alreadyAddedObjectiveLines[line] = true
                    GameTooltip:AddLine(line)
                end
            end
            addedObjects = addedObjects + 1
        end
    end

    QuestieTooltips.lastGametooltipType = "object"
end

function _QuestieTooltips:CountTooltip()
    local tooltipCount = 0
    for i = 1, GameTooltip:NumLines() do
        local frame = _G["GameTooltipTextLeft"..i]
        local text = frame and frame:GetText()
        -- A secret native row still occupies a line; count it without testing its text.
        if _IsSecret(text) or text then
            tooltipCount = tooltipCount + 1
        else
            return tooltipCount
        end
    end
    return tooltipCount
end