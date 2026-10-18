---@class MapPreview
local MapPreview = QuestieLoader:CreateModule("MapPreview")

---@type QuestieMap
local QuestieMap = QuestieLoader:ImportModule("QuestieMap")
---@type QuestieFrame
local QuestieFrame = QuestieLoader:ImportModule("QuestieFrame")

-- Previews a quest, or one of its objectives, on the maps from outside them, such as from the tracker
-- or a quest log: as if each of its world map icons were hovered. So in every icon style its icons
-- grow, its quest goes in the spotlight and its NPCs' patrol paths highlight, and features show more of
-- their own through Subscribe, such as Questie blobs' areas. Whoever starts a preview ends it, as the
-- cursor ends a hover.

---@alias MapPreviewListener fun(questId: QuestId, objectiveIndex: ObjectiveIndex?, previewing: boolean)

---@type MapPreviewListener[]
local listeners = {}
---@type table<function, true>
local reported = {}

---@class MapPreviewHandle
---@field questId QuestId
---@field objectiveIndex ObjectiveIndex?
---@field hovers {icon: IconFrame, data: IconData}[] Each icon it hovers, with the data its hover started with: the pool may hand an icon out again before the preview ends.
---@field ended boolean?

---Tells each listener, in a pcall: a failing one is reported once and stops neither the others nor
---the preview.
---@param questId QuestId
---@param objectiveIndex ObjectiveIndex?
---@param previewing boolean
local function _Notify(questId, objectiveIndex, previewing)
    for i = 1, #listeners do
        local listener = listeners[i]
        local ok, err = pcall(listener, questId, objectiveIndex, previewing)
        if not ok and not reported[listener] then
            reported[listener] = true
            Questie.Error("Map preview listener failed:", err)
        end
    end
end

---Calls listener as each preview starts and ends.
---@param listener MapPreviewListener
function MapPreview.Subscribe(listener)
    listeners[#listeners + 1] = listener
end

---Previews a quest, or one of its objectives, until End with what it returns. Its quest givers and
---turn-ins, and icons Questie hides, are not hovered.
---@param questId QuestId
---@param objectiveIndex ObjectiveIndex? The objective; nil previews every objective of the quest.
---@return MapPreviewHandle
function MapPreview.Start(questId, objectiveIndex)
    local preview = {questId = questId, objectiveIndex = objectiveIndex, hovers = {}}
    for _, frameName in pairs(QuestieMap.questIdFrames[questId] or {}) do
        local icon = _G[frameName]
        local data = icon and icon.data
        if data and not icon.miniMapIcon and not icon.hidden and data.Type ~= "available" and data.Type ~= "complete"
            and (objectiveIndex == nil or data.ObjectiveIndex == objectiveIndex) then
            preview.hovers[#preview.hovers + 1] = {icon = icon, data = data}
            QuestieFrame.ApplyHoverHighlights(icon)
        end
    end
    _Notify(questId, objectiveIndex, true)
    return preview
end

---Ends a preview; ending it again does nothing.
---@param preview MapPreviewHandle
function MapPreview.End(preview)
    if preview.ended then return end
    preview.ended = true
    local hovers = preview.hovers
    for i = #hovers, 1, -1 do QuestieFrame.ResetHoverHighlights(hovers[i].icon, hovers[i].data) end
    _Notify(preview.questId, preview.objectiveIndex, false)
end
