---@type QuestieTooltips
local QuestieTooltips = QuestieLoader:ImportModule("QuestieTooltips");
local _QuestieTooltips = QuestieTooltips.private

---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")

-- Unit rendering is shared; identity lookup and duplicate protection belong to each client path.
local function _AddUnitLines(tooltip, guid)
    local unitType, _, _, _, _, npcId = strsplit("-", guid or "")
    if unitType == "Creature" or unitType == "Vehicle" then
        if Questie.db.profile.enableTooltipsNPCID then
            tooltip:AddDoubleLine(l10n("NPC ID"), "|cFFFFFFFF" .. npcId .. "|r")
        end

        local lines = QuestieTooltips.GetTooltip("m_" .. npcId)
        for _, line in pairs(lines or {}) do
            tooltip:AddLine(line)
        end
    elseif unitType == "Player" then
        local _, serverId, playerId = strsplit("-", guid)
        if Questie.devChars[serverId] and tContains(Questie.devChars[serverId], playerId) then
            tooltip:AddLine("|TInterface\\AddOns\\Questie\\Icons\\questie.png:0|t |cnIQ5:" .. l10n("Questie Developer") .. "|r")
        end
    end
end

local lastGuid

---@param tooltip GameTooltip
---@param guid string? Public GUID supplied by the structured callback; nil selects the legacy unit-token path.
function _QuestieTooltips.AddUnitDataToTooltip(tooltip, guid)
    if tooltip.IsForbidden and tooltip:IsForbidden() then
        return
    end
    if not Questie.db.profile.enableTooltips then
        return
    end

    -- Structured callbacks already validate identity and add once per clear. Never read native text here.
    if guid then
        _AddUnitLines(tooltip, guid)
        return
    end

    -- Legacy clients resolve the unit token and detect rebuilds by counting rendered lines.
    if Questie.IsForever and IsInInstance() then
        return
    end
    local name, unitToken = tooltip:GetUnit()
    if not unitToken then
        return
    end
    guid = UnitGUID(unitToken) or UnitGUID("mouseover")

    local unitType = strsplit("-", guid or "")
    if name and (unitType == "Creature" or unitType == "Vehicle") then
        local needsUpdate = name ~= QuestieTooltips.lastGametooltipUnit
            or not QuestieTooltips.lastGametooltipCount
            or _QuestieTooltips:CountTooltip() < QuestieTooltips.lastGametooltipCount
            or QuestieTooltips.lastGametooltipType ~= "monster"
            or lastGuid ~= guid

        if needsUpdate then
            QuestieTooltips.lastGametooltipUnit = name
            _AddUnitLines(tooltip, guid)
            QuestieTooltips.lastGametooltipCount = _QuestieTooltips:CountTooltip()
        end
    elseif unitType == "Player" then
        QuestieTooltips.lastGametooltipUnit = name
        _AddUnitLines(tooltip, guid)
    end
    lastGuid = guid
    QuestieTooltips.lastGametooltipType = "monster"
end

-- Item rendering retains quest-start registration for both callback and hyperlink identities.
local checkedQuestStartItems = {}

---@param tooltip GameTooltip
---@param itemId string Numeric ID, normalized to the same cache key on both client paths.
local function _AddItemLines(tooltip, itemId)
    if Questie.db.profile.enableTooltipsItemID then
        tooltip:AddDoubleLine(l10n("Item ID"), "|cFFFFFFFF" .. itemId .. "|r")
    end

    -- Register quest-start items on first encounter, before looking up their quest lines.
    if not checkedQuestStartItems[itemId] then
        checkedQuestStartItems[itemId] = true
        local itemIdAsNumber = tonumber(itemId)
        if itemIdAsNumber then
            local startQuestId = QuestieDB.QueryItemSingle(itemIdAsNumber, "startQuest")
            local itemName = QuestieDB.QueryItemSingle(itemIdAsNumber, "name")
            if startQuestId and startQuestId ~= 0 and itemName then
                QuestieTooltips:RegisterQuestStartTooltip(startQuestId, itemName, itemIdAsNumber, "i_" .. itemId, "itemFromMonster")
            end
        end
    end

    local lines = QuestieTooltips.GetTooltip("i_" .. itemId)
    for _, line in pairs(lines or {}) do
        tooltip:AddLine(line)
    end
end

local lastItemId = 0

---@param tooltip GameTooltip
---@param itemId ItemId? Public ID supplied by the structured callback; nil selects the legacy hyperlink path.
function _QuestieTooltips.AddItemDataToTooltip(tooltip, itemId)
    if tooltip.IsForbidden and tooltip:IsForbidden() then
        return
    end
    if not Questie.db.profile.enableTooltips then
        return
    end

    -- Structured callbacks own duplicate protection; only Classic needs getters and line counting.
    if itemId then
        _AddItemLines(tooltip, tostring(itemId))
        return
    end

    local name, link = tooltip:GetItem()
    if link then
        -- Match the link payload independently of legacy hex colors or modern named colors.
        itemId = string.match(link, "item:(%d+)")
    end
    if name and itemId then
        local needsUpdate = name ~= QuestieTooltips.lastGametooltipItem
            or not QuestieTooltips.lastGametooltipCount
            or _QuestieTooltips:CountTooltip() < QuestieTooltips.lastGametooltipCount
            or QuestieTooltips.lastGametooltipType ~= "item"
            or lastItemId ~= itemId
            or QuestieTooltips.lastFrameName ~= tooltip:GetName()

        if needsUpdate then
            QuestieTooltips.lastGametooltipItem = name
            _AddItemLines(tooltip, itemId)
            QuestieTooltips.lastGametooltipCount = _QuestieTooltips:CountTooltip()
        end
    end
    lastItemId = itemId
    QuestieTooltips.lastGametooltipType = "item"
    QuestieTooltips.lastFrameName = tooltip:GetName()
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
        if frame and frame:GetText() then
            tooltipCount = tooltipCount + 1
        else
            return tooltipCount
        end
    end
    return tooltipCount
end