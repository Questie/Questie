---Selects the persisted compiled database namespace for the active content flavor.
---Compile-time corrections change bins and pointer maps, so SoD and Titan cannot reuse the standard cache.
---@class QuestieDBCache
local QuestieDBCache = QuestieLoader:CreateModule("QuestieDBCache")

---@return table activeStorage
function QuestieDBCache.GetActiveStorage()
    if Questie.IsSoD then
        return Questie.db.global.sod
    elseif Questie.IsTitanReforged then
        return Questie.db.global.titanReforged
    end

    return Questie.db.global
end

---Invalidates only the active flavor so other compiled variants remain reusable.
function QuestieDBCache.InvalidateActiveStorage()
    QuestieDBCache.GetActiveStorage().dbIsCompiled = false
end
