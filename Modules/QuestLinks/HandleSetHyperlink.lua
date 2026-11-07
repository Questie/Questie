---@class HandleSetHyperlink
local HandleSetHyperlink = QuestieLoader:CreateModule("HandleSetHyperlink")
---@type QuestieLink
local QuestieLink = QuestieLoader:ImportModule("QuestieLink")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")

---Used to track the last questId that was displayed in the ItemRefTooltip. This is used to
---detect repeated clicks on the same quest link, which should close the tooltip.
---@type QuestId?
local lastItemRefTooltip

--- Body of the ItemRefTooltip:SetHyperlink override. The fallback handler is passed in as a
--- parameter (instead of being captured as an upvalue by the caller) so it can be unit tested
--- with a mock/spy in isolation, without installing the real hook.
---@param self Frame
---@param fallbackHandler function
---@param link string
function HandleSetHyperlink.Run(self, fallbackHandler, link, ...)
    if (not HandleSetHyperlink.TryShowQuestTooltip(link)) then
        fallbackHandler(self, link, ...)
    end
end

--- Link handler for LinkUtil.RegisterLinkHandler. Blizzard's SetItemRef calls it before
--- ItemRefTooltip:SetHyperlink, so Questie doesn't need to replace SetHyperlink.
---@param link string
---@return number @LinkProcessorResponse
function HandleSetHyperlink.ProcessLink(link)
    -- Modified clicks (e.g. shift-click to insert into chat) must reach Blizzard's default handling
    if IsModifiedClick() then
        return LinkProcessorResponse.Unhandled
    end

    if HandleSetHyperlink.TryShowQuestTooltip(link) then
        return LinkProcessorResponse.Handled
    end
    return LinkProcessorResponse.Unhandled
end

--- Shows the Questie quest tooltip in the ItemRefTooltip for questie and native quest links.
---@param link string
---@return boolean @true if the link was handled
function HandleSetHyperlink.TryShowQuestTooltip(link)
    -- If Questie hasn't started yet, let the default handler take over to avoid accessing uninitialized DB
    if (not Questie.started) then
        return false
    end

    local questiePrefix, questId = string.match(link, "(questie):(%d+):")
    local isQuestieLink = questiePrefix == "questie"

    -- Detect native Blizzard quest links (format: quest:questId:level)
    local nativeQuestId = string.match(link, "quest:(%d+):")
    local isNativeQuestLink = nativeQuestId ~= nil

    local extractedQuestId
    if isQuestieLink and questId then
        extractedQuestId = tonumber(questId)
    elseif isNativeQuestLink then
        extractedQuestId = tonumber(nativeQuestId)
    end

    if (not extractedQuestId) then
        -- We weren't able to find the questId. Nothing we can do, so we let the default handler take over
        lastItemRefTooltip = nil
        return false
    end

    local quest = QuestieDB.GetQuest(extractedQuestId)
    if (not quest) then
        -- We don't have the quest in our DB, so we let the default handler take over
        lastItemRefTooltip = nil
        return false
    end

    if (not ItemRefTooltip:IsShown()) then
        lastItemRefTooltip = nil
    end

    Questie.Debug(Questie.DEBUG_DEVELOP, "[QuestieTooltips:ItemRefTooltip] SetHyperlink:", link)
    ShowUIPanel(ItemRefTooltip)
    ItemRefTooltip:SetOwner(UIParent, "ANCHOR_PRESERVE");
    ItemRefTooltip:ClearLines()

    local tooltipLink = isNativeQuestLink and ("questie:" .. extractedQuestId .. ":0") or link

    QuestieLink:CreateQuestTooltip(tooltipLink, ItemRefTooltip)
    ItemRefTooltip:Show()

    -- A repeated click on the same quest link closes the tooltip.
    if lastItemRefTooltip == extractedQuestId then
        ItemRefTooltip:Hide()
        lastItemRefTooltip = nil
        return true
    end

    lastItemRefTooltip = extractedQuestId
    return true
end
