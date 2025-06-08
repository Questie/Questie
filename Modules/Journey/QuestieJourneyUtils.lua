---@class QuestieJourneyUtils
local QuestieJourneyUtils = QuestieLoader:CreateModule("QuestieJourneyUtils")

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local GetItemInfo = C_Item.GetItemInfo or GetItemInfo

local AceGUI = LibStub("AceGUI-3.0")

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
    for category, data in pairs(l10n.zoneLookup) do
        if data[id] then
            return l10n.zoneLookup[category][id]
        end
    end
    for dungeonZoneId, dungeonName in pairs(l10n.zoneCategoryLookup[6]) do
        if dungeonZoneId == id then
            return dungeonName
        end
    end
    return l10n("Unknown Zone")
end

---@param desc table | string
---@return string
function QuestieJourneyUtils.CreateObjectiveText(desc)
    local objText = ""

    if desc then
        if type(desc) == "table" then
            for _, v in ipairs(desc) do
                objText = objText .. v .. "\n"
            end
        else
            objText = objText .. tostring(desc) .. "\n"
        end
    else
        objText = Questie:Colorize(l10n('This quest is an automatic completion quest and does not contain an objective.'), 'yellow')
    end

    return objText
end

function QuestieJourneyUtils.ShowJourneyTooltip(self)
    if GameTooltip:IsShown() then
        return
    end

    local id = tonumber(self:GetUserData('id'))
    local type = self:GetUserData('type')
    GameTooltip:SetOwner(_G["QuestieJourneyFrame"].frame:GetParent(), "ANCHOR_CURSOR")
    if type == "quest" then
        local quest = QuestieDB.GetQuest(id)
        GameTooltip:AddLine("["..quest.level.."] "..quest.name.." ("..id..")")
        if quest.Description and quest.Description ~= {} then
            for _, line in pairs(quest.Description) do
                for _, text in pairs(QuestieLib:TextWrap(line, '    ', true, 360)) do
                    GameTooltip:AddLine("|cFFFFFFFF" .. text .. "|r")
                end
            end
        end
    elseif type == "npc" then
        local npc = QuestieDB:GetNPC(id)
        GameTooltip:AddLine("[".. npc.minLevel .."] ".. npc.name .." (".. id ..")")
        if npc.subName then GameTooltip:AddLine("|cFFFFFFFF    "..npc.subName.."|r") end
    elseif type == "object" then
        local object = QuestieDB.QueryObjectSingle(id, "name")
        GameTooltip:AddLine(object.." ("..id..")")
    elseif type == "item" then
        local item = QuestieDB.QueryItemSingle(id, "name")
        GameTooltip:AddLine(item.." ("..id..")")
    end
    GameTooltip:AddLine("\n"..l10n("Click to show"))
    GameTooltip:SetFrameStrata("TOOLTIP")
    GameTooltip:Show()
end

function QuestieJourneyUtils.HideJourneyTooltip()
    if GameTooltip:IsShown() then
        GameTooltip:Hide()
    end
end

---@param quest Quest
---@return AceInteractiveLabel
function QuestieJourneyUtils.GetInteractiveQuestLabel(quest)
    ---@class AceInteractiveLabel
    local label = AceGUI:Create("InteractiveLabel")
    local questId = quest.Id

    label:SetText(QuestieLib:GetColoredQuestName(questId, Questie.db.profile.enableTooltipsQuestLevel, false, true))
    label:SetUserData('id', questId)
    label:SetUserData('type', 'quest')
    label:SetUserData('name', quest.name)
    label:SetCallback("OnClick", function()
        ItemRefTooltip:SetHyperlink("%|Hquestie:" .. questId .. ":.*%|h", "%[%[" .. quest.level .. "%] " .. quest.name .. " %(" .. questId .. "%)%]")
    end)
    label:SetCallback("OnEnter", QuestieJourneyUtils.ShowJourneyTooltip)
    label:SetCallback("OnLeave", QuestieJourneyUtils.HideJourneyTooltip)

    return label
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
