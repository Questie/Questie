---@class HandleSetHyperlink
local HandleSetHyperlink = QuestieLoader:CreateModule("HandleSetHyperlink")
---@type QuestieLink
local QuestieLink = QuestieLoader:ImportModule("QuestieLink")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")

--- Body of the ItemRefTooltip:SetHyperlink override. The fallback handler is passed in as a
--- parameter (instead of being captured as an upvalue by the caller) so it can be unit tested
--- with a mock/spy in isolation, without installing the real hook.
---@param self Frame
---@param fallbackHandler function
---@param link string
function HandleSetHyperlink.Run(self, fallbackHandler, link, ...)
    -- If Questie hasn't started yet, delegate to the default handler to avoid accessing uninitialized DB
    if (not Questie.started) then
        fallbackHandler(self, link, ...)
        return
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
        QuestieLink.lastItemRefTooltip = nil
        fallbackHandler(self, link, ...)
        return
    end

    local quest = QuestieDB.GetQuest(extractedQuestId)
    if (not quest) then
        -- We don't have the quest in our DB, so we let the default handler take over
        QuestieLink.lastItemRefTooltip = nil
        fallbackHandler(self, link, ...)
        return
    end

    if (not ItemRefTooltip:IsShown()) then
        QuestieLink.lastItemRefTooltip = nil
    end

    Questie.Debug(Questie.DEBUG_DEVELOP, "[QuestieTooltips:ItemRefTooltip] SetHyperlink:", link)
    ShowUIPanel(ItemRefTooltip)
    ItemRefTooltip:SetOwner(UIParent, "ANCHOR_PRESERVE");
    ItemRefTooltip:ClearLines()

    local tooltipLink = isNativeQuestLink and ("questie:" .. extractedQuestId .. ":0") or link

    QuestieLink:CreateQuestTooltip(tooltipLink, ItemRefTooltip)
    ItemRefTooltip:Show()

    -- A repeated click on the same quest link closes the tooltip.
    if QuestieLink.lastItemRefTooltip == extractedQuestId then
        ItemRefTooltip:Hide()
        QuestieLink.lastItemRefTooltip = nil
        return
    end

    QuestieLink.lastItemRefTooltip = extractedQuestId
end
