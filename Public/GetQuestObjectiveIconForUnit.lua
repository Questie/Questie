---@type QuestieNameplate
local QuestieNameplate = QuestieLoader:ImportModule("QuestieNameplate")

--- Returns the icon path for the quest objective marker for the given unit GUID.
--- Only NPC GUIDs are valid inputs.
---@param guid string
---@return string | nil -- Path to the icon texture, or nil if no icon is available.
function Questie.API.GetQuestObjectiveIconForUnit(guid)
    if (not Questie.API.isReady) then
        return nil
    end

    if type(guid) ~= "string" then
        error("Questie.API.GetQuestObjectiveIconForUnit: guid must be a string")
    end

    return QuestieNameplate.GetIcon(guid)
end
