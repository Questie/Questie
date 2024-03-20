---@class Phasing
local Phasing = QuestieLoader:CreateModule("Phasing")

-- https://old.wow.tools/dbc/?dbc=phase&build=4.3.4.15595
local phases = {
    KEZAN_CHAPTER_1 = 1, --378,
    KEZAN_CHAPTER_2 = 2, --379,
}

function Phasing.IsSpawnVisible(phase)
    if phase == phases.KEZAN_CHAPTER_1 then
        return true
    end
    return false
end
