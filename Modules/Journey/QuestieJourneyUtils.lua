---@class QuestieJourneyUtils
local QuestieJourneyUtils = QuestieLoader:CreateModule("QuestieJourneyUtils")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local AceGUI = LibStub("AceGUI-3.0");

function QuestieJourneyUtils:GetSortedZoneKeys(zones)
    local function compare(a, b)
        return zones[a] < zones[b]
    end

    local zoneNames = {}
    for k, _ in pairs(zones) do
        table.insert(zoneNames, k)
    end
    table.sort(zoneNames, compare)
    return zoneNames
end

function QuestieJourneyUtils:Spacer(container, size)
    local spacer = AceGUI:Create("Label");
    spacer:SetFullWidth(true);
    spacer:SetText(" ");
    if size and size == "large" then
        spacer:SetFontObject(GameFontHighlightLarge);
    elseif size and size == "small" then
        spacer:SetFontObject(GameFontHighlightSmall);
    else
        spacer:SetFontObject(GameFontHighlight);
    end
    container:AddChild(spacer);
end

function QuestieJourneyUtils:AddLine(frame, text)
    local label = AceGUI:Create("Label")
    label:SetFullWidth(true);
    label:SetText(text)
    label:SetFontObject(GameFontNormal)
    frame:AddChild(label)
end

function QuestieJourneyUtils:GetZoneName(id)
    local name = l10n("Unknown Zone")
    for category, data in pairs(l10n.zoneLookup) do
        if data[id] then
            name = l10n.zoneLookup[category][id]
            break
        end
    end
    return name
end

---@param itemId ItemId
---@return AceIcon
function QuestieJourneyUtils.GetItemIcon(itemId)
    local itemLink = select(2, GetItemInfo(itemId))

    ---@class AceIcon
    local itemIcon = AceGUI:Create("Icon")
    itemIcon:SetWidth(25)
    itemIcon:SetHeight(25)
    itemIcon:SetImage(GetItemIcon(itemId))
    itemIcon:SetImageSize(25, 25)
    itemIcon:SetCallback("OnEnter", function()
        if (not itemLink) then
            itemLink = select(2, GetItemInfo(itemId))
        end
        GameTooltip:SetOwner(UIParent, "ANCHOR_CURSOR")
        GameTooltip:SetHyperlink(itemLink)
        GameTooltip:Show()
    end)
    itemIcon:SetCallback("OnLeave", function()
        GameTooltip:Hide()
    end)
    itemIcon:SetCallback("OnClick", function()
        if (not itemLink) then
            itemLink = select(2, GetItemInfo(itemId))
        end
        if IsShiftKeyDown() then
            if (not ChatFrame1EditBox:IsVisible()) then
                ChatFrame_OpenChat(itemLink)
            else
                ChatEdit_InsertLink(itemLink)
            end
        elseif IsControlKeyDown() then
            DressUpItemLink(itemLink)
        end
    end)

    return itemIcon
end
