---Highlights the map and minimap icons of a hovered quest: the quest hovered in the map's quest log, or
---the quest line hovered in Questie's tracker.
---
---Blizzard's map quest log reports the hovered quest through EventRegistry: its highlight manager
---(QuestPOIHighlightManager on Wrath, Cata and Mists, POIButtonHighlightManager on Forever) fires
---SetHighlightedQuestPOI and ClearHighlightedQuestPOI with the quest ID. Those are the same events the
---client uses to highlight its own pins, so Questie can follow them without replacing or scraping a
---frame. Questie only changes its own icon frames, plus an OnHide on the quest log panel that drops the
---highlight when the panel closes under the mouse.
---
---@class QuestMapHover
local QuestMapHover = QuestieLoader:CreateModule("QuestMapHover")

---@type QuestieMap
local QuestieMap = QuestieLoader:ImportModule("QuestieMap")

---Where a highlight was asked for, so leaving one surface does not clear another surface's highlight.
QuestMapHover.SOURCE_MAP_QUEST_LOG = "MapQuestLog"
QuestMapHover.SOURCE_TRACKER = "Tracker"

---Icons of the quest currently highlighted, so exactly those are restored.
---@type IconFrame[]
local highlightedIcons = {}

---The surface that asked for the current highlight, one of the SOURCE_ constants.
---@type string?
local highlightSource

---Whether QuestMapFrame's OnHide is already hooked.
local questMapFrameHooked

local function _ClearHighlight()
    for i = #highlightedIcons, 1, -1 do
        highlightedIcons[i]:SetHoverHighlight(false)
    end
    highlightedIcons = {}
    highlightSource = nil
end

---Highlights the world map and minimap icons of a quest.
---@param questId QuestId
---@param source string @One of the SOURCE_ constants
function QuestMapHover.HighlightQuest(questId, source)
    _ClearHighlight()
    highlightSource = source

    for _, icon in pairs(QuestieMap:GetFramesForQuest(questId)) do
        icon:SetHoverHighlight(true)
        highlightedIcons[#highlightedIcons + 1] = icon
    end
end

---Drops the highlight, unless another surface owns it.
---@param source string @One of the SOURCE_ constants
function QuestMapHover.ClearQuest(source)
    if highlightSource ~= source then
        return
    end
    _ClearHighlight()
end

---The quest log can close under the mouse without its entries sending OnLeave, which would leave the
---highlight behind until the mouse moves. Clear it when the panel it belongs to hides.
local function _OnQuestMapHide()
    QuestMapHover.ClearQuest(QuestMapHover.SOURCE_MAP_QUEST_LOG)
end

local function _HookQuestMapFrameOnHide()
    if questMapFrameHooked or not QuestMapFrame then
        return
    end
    questMapFrameHooked = true
    QuestMapFrame:HookScript("OnHide", _OnQuestMapHide)
end

---@param _ QuestMapHover
---@param questId QuestId
local function _OnSetHighlightedQuestPOI(_, questId)
    _HookQuestMapFrameOnHide()
    QuestMapHover.HighlightQuest(questId, QuestMapHover.SOURCE_MAP_QUEST_LOG)
end

---@param _ QuestMapHover
local function _OnClearHighlightedQuestPOI(_)
    QuestMapHover.ClearQuest(QuestMapHover.SOURCE_MAP_QUEST_LOG)
end

EventRegistry:RegisterCallback("SetHighlightedQuestPOI", _OnSetHighlightedQuestPOI, QuestMapHover)
EventRegistry:RegisterCallback("ClearHighlightedQuestPOI", _OnClearHighlightedQuestPOI, QuestMapHover)
