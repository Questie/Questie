---@type QuestieCompat
local QuestieCompat = QuestieLoader:ImportModule("QuestieCompat")

---@class QuestieJourneyUtils
local QuestieJourneyUtils = QuestieLoader:CreateModule("QuestieJourneyUtils")

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
---@type WrappedText
local WrappedText = QuestieLoader:ImportModule("WrappedText")
---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")
---@type QuestieJourney
local QuestieJourney = QuestieLoader:ImportModule("QuestieJourney")
local _QuestieJourney = QuestieJourney.private
---@type QuestieSearchResults
local QuestieSearchResults = QuestieLoader:ImportModule("QuestieSearchResults")
local GetItemInfo = QuestieCompat.GetItemInfo
local GetItemIcon = QuestieCompat.GetItemIcon

--- QuestieGUI
local QuestieGUI = QuestieLoader:ImportModule("QuestieGUI")

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
    local spacer = QuestieGUI:Create("Label");
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
    local label = QuestieGUI:Create("Label")
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
    for dungeonZoneId, dungeonName in pairs(l10n.zoneCategoryLookup[9]) do
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
    local journeyFrame = _G["QuestieJourneyFrame"]
    local tooltipOwner = journeyFrame and (journeyFrame.frame or journeyFrame)
    if not tooltipOwner then
        return
    end
    GameTooltip:SetOwner(tooltipOwner, "ANCHOR_CURSOR")
    if type == "quest" then
        local quest = QuestieDB.GetQuest(id)
        GameTooltip:AddLine("["..quest.level.."] "..quest.name.." ("..id..")")
        if quest.Description and quest.Description ~= {} then
            for _, line in pairs(quest.Description) do
                for _, text in pairs(WrappedText:TextWrap(line, '    ', false, 360)) do
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

---Open a quest directly in the Journey quest detail view.
---@param questId QuestId
function QuestieJourneyUtils.OpenQuestInJourney(questId)
    if not QuestieJourney or not QuestieJourney.tabGroup or not QuestieSearchResults then
        return
    end

    if QuestieJourney.OpenQuestInCurrentView
        and QuestieJourney:OpenQuestInCurrentView(questId) then
        return
    end

    local currentWindow = _QuestieJourney.lastOpenWindow

    -- Keep the existing Advanced Search result tabs when navigating from one
    -- quest link to another. Only the detail pane needs to change.
    if currentWindow == "search" then
        if QuestieSearchResults.OpenDetails then
            QuestieSearchResults:OpenDetails("quest", questId)
        else
            QuestieSearchResults:SetSearch("quest", questId)
        end
        return
    end

    -- Do not cross from the faction view into another tab when the target is
    -- not part of the currently rendered faction tree.
    if currentWindow == "faction" then
        if QuestieJourney.OpenQuestDetailsInCurrentView then
            QuestieJourney:OpenQuestDetailsInCurrentView(questId)
        end
        return
    end

    local function OpenQuestInZone()
        local opened = QuestieJourney.OpenQuestInZone and QuestieJourney:OpenQuestInZone(questId)
        if not opened and QuestieJourney.OpenQuestDetailsInCurrentView then
            QuestieJourney:OpenQuestDetailsInCurrentView(questId)
        end
    end

    -- A Zone link remains in the Zone tab even when the target requires a
    -- zone/category change. If the target has no zone location, leave the
    -- current view unchanged instead of falling back to Advanced Search.
    if currentWindow == "zone" then
        if C_Timer and C_Timer.After then
            C_Timer.After(0, OpenQuestInZone)
        else
            OpenQuestInZone()
        end
        return
    end

    -- Quest links should stay in the Journey zone browser whenever the target
    -- can be located there. The tab is initialized before the deferred lookup.
    QuestieJourney.tabGroup:SelectTab("zone")

    -- The search controls are created while the tab is selected.  Deferring
    -- one frame makes this work both from an already-open tab and from a
    -- quest details panel in the zone/faction tabs.
    local openQuest = function()
        OpenQuestInZone()
    end
    if C_Timer and C_Timer.After then
        C_Timer.After(0, openQuest)
    else
        openQuest()
    end
end

function QuestieJourneyUtils.ApplyModernQuestLinkStyle(label)
    if not label or not label.highlight then
        return
    end

    local function RefreshQuestLinkBounds()
        local surface = label.modernQuestLinkSurface
        if not surface or not label.label or not label.label.GetStringWidth then
            return
        end

        local textWidth = label.label:GetStringWidth() or 0
        local frameWidth = label.frame:GetWidth() or 0
        local highlightWidth = textWidth + 8
        if frameWidth > 0 then
            highlightWidth = math.min(highlightWidth, math.max(4, frameWidth - 2))
        end
        highlightWidth = math.max(4, highlightWidth)

        surface:ClearAllPoints()
        surface:SetPoint("TOPLEFT", label.frame, "TOPLEFT", 2, -1)
        surface:SetPoint("BOTTOMLEFT", label.frame, "BOTTOMLEFT", 2, 1)
        surface:SetWidth(highlightWidth)

        local edgeWidth = math.max(1, highlightWidth - 4)
        label.modernQuestLinkTopEdge:ClearAllPoints()
        label.modernQuestLinkTopEdge:SetPoint("TOPLEFT", label.frame, "TOPLEFT", 4, -1)
        label.modernQuestLinkTopEdge:SetWidth(edgeWidth)

        label.modernQuestLinkBottomEdge:ClearAllPoints()
        label.modernQuestLinkBottomEdge:SetPoint("BOTTOMLEFT", label.frame, "BOTTOMLEFT", 4, 1)
        label.modernQuestLinkBottomEdge:SetWidth(edgeWidth)
    end

    if not label.modernQuestLinkSurface then
        -- Use explicit hover visibility rather than the legacy HIGHLIGHT
        -- region, which renders as a heavy blue block on some clients.
        local surface = label.frame:CreateTexture(nil, "BACKGROUND")
        -- Match the selected-row treatment used by the Journey tree on the
        -- left, so linked quests have the same golden-bronze contrast.
        surface:SetColorTexture(0.42, 0.27, 0.05, 0.52)
        surface:SetPoint("TOPLEFT", label.frame, "TOPLEFT", 2, -1)
        surface:SetPoint("BOTTOMRIGHT", label.frame, "BOTTOMRIGHT", -2, 1)
        surface:Hide()

        local accent = label.frame:CreateTexture(nil, "ARTWORK")
        accent:SetColorTexture(0.98, 0.72, 0.18, 0.95)
        accent:SetPoint("TOPLEFT", label.frame, "TOPLEFT", 2, -1)
        accent:SetPoint("BOTTOMLEFT", label.frame, "BOTTOMLEFT", 2, 1)
        accent:SetWidth(2)
        accent:Hide()

        local topEdge = label.frame:CreateTexture(nil, "ARTWORK")
        topEdge:SetColorTexture(0.98, 0.72, 0.18, 0.22)
        topEdge:SetPoint("TOPLEFT", label.frame, "TOPLEFT", 4, -1)
        topEdge:SetPoint("TOPRIGHT", label.frame, "TOPRIGHT", -2, -1)
        topEdge:SetHeight(1)
        topEdge:Hide()

        local bottomEdge = label.frame:CreateTexture(nil, "ARTWORK")
        bottomEdge:SetColorTexture(0.08, 0.05, 0.02, 0.24)
        bottomEdge:SetPoint("BOTTOMLEFT", label.frame, "BOTTOMLEFT", 4, 1)
        bottomEdge:SetPoint("BOTTOMRIGHT", label.frame, "BOTTOMRIGHT", -2, 1)
        bottomEdge:SetHeight(1)
        bottomEdge:Hide()

        label.modernQuestLinkSurface = surface
        label.modernQuestLinkAccent = accent
        label.modernQuestLinkTopEdge = topEdge
        label.modernQuestLinkBottomEdge = bottomEdge
        label.modernQuestLinkRefresh = RefreshQuestLinkBounds

        label.frame:HookScript("OnEnter", function()
            if label.modernQuestLinkActive then
                label.modernQuestLinkSurface:Show()
                label.modernQuestLinkAccent:Show()
                label.modernQuestLinkTopEdge:Show()
                label.modernQuestLinkBottomEdge:Show()
            end
        end)
        label.frame:HookScript("OnLeave", function()
            label.modernQuestLinkSurface:Hide()
            label.modernQuestLinkAccent:Hide()
            label.modernQuestLinkTopEdge:Hide()
            label.modernQuestLinkBottomEdge:Hide()
        end)
        label.frame:HookScript("OnSizeChanged", RefreshQuestLinkBounds)
    end

    RefreshQuestLinkBounds()
    label.modernQuestLinkActive = true
    label.modernQuestLinkSurface:Hide()
    label.modernQuestLinkAccent:Hide()
    label.modernQuestLinkTopEdge:Hide()
    label.modernQuestLinkBottomEdge:Hide()
    label.highlight:SetTexture(nil)
    label.highlight:Hide()
end

---@param quest Quest
---@return QuestieInteractiveLabel
function QuestieJourneyUtils.GetInteractiveQuestLabel(quest)
    ---@class QuestieInteractiveLabel
    local label = QuestieGUI:Create("InteractiveLabel")
    local questId = quest.Id

    QuestieJourneyUtils.ApplyModernQuestLinkStyle(label)

    label:SetText(QuestieLib:GetColoredQuestName(questId, Questie.db.profile.enableTooltipsQuestLevel, false))
    if label.modernQuestLinkRefresh then
        label.modernQuestLinkRefresh()
    end
    label:SetUserData('id', questId)
    label:SetUserData('type', 'quest')
    label:SetUserData('name', quest.name)
    label:SetCallback("OnClick", function()
        QuestieJourneyUtils.HideJourneyTooltip()
        QuestieJourneyUtils.OpenQuestInJourney(questId)
    end)
    label:SetCallback("OnEnter", QuestieJourneyUtils.ShowJourneyTooltip)
    label:SetCallback("OnLeave", QuestieJourneyUtils.HideJourneyTooltip)

    return label
end

---@param itemId ItemId
---@return QuestieIcon
function QuestieJourneyUtils.GetItemIcon(itemId)
    local itemLink = select(2, GetItemInfo(itemId))

    local function GetItemLink()
        if not itemLink then
            itemLink = select(2, GetItemInfo(itemId))
        end
        return itemLink
    end

    ---@class QuestieIcon
    local itemIcon = QuestieGUI:Create("Icon")
    itemIcon:SetWidth(25)
    itemIcon:SetHeight(25)
    itemIcon:SetImage(GetItemIcon(itemId))
    itemIcon:SetImageSize(25, 25)
    itemIcon:SetCallback("OnEnter", function()
        GameTooltip:SetOwner(itemIcon.frame, "ANCHOR_CURSOR")
        local link = GetItemLink()
        if link then
            GameTooltip:SetHyperlink(link)
        elseif GameTooltip.SetItemByID then
            GameTooltip:SetItemByID(itemId)
        end
        GameTooltip:Show()
    end)
    itemIcon:SetCallback("OnLeave", function()
        GameTooltip:Hide()
    end)
    itemIcon:SetCallback("OnClick", function()
        local link = GetItemLink()
        if IsShiftKeyDown() then
            if link then
                if ChatEdit_GetActiveWindow() then
                    ChatEdit_InsertLink(link)
                else
                    ChatFrame_OpenChat(link)
                end
            end
        elseif IsControlKeyDown() and link then
            DressUpItemLink(link)
        end
    end)

    return itemIcon
end
