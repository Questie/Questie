---Selects the persisted compiled database namespace for the active content flavor.
---Compile-time corrections change bins and pointer maps, so SoD and Titan cannot reuse the standard storage.
---@class QuestieDBStorage
local QuestieDBStorage = QuestieLoader:CreateModule("QuestieDBStorage")

---@return table activeStorage
function QuestieDBStorage.GetActiveStorage()
    if Questie.IsSoD then
        return Questie.db.global.sod
    elseif Questie.IsTitanReforged then
        return Questie.db.global.titanReforged
    end

    return Questie.db.global
end

---Invalidates only the active flavor so other compiled variants remain reusable.
---@return nil
function QuestieDBStorage.InvalidateActiveStorage()
    QuestieDBStorage.GetActiveStorage().dbIsCompiled = false
end
