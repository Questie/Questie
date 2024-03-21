---@class Phasing
local Phasing = QuestieLoader:CreateModule("Phasing")

-- https://old.wow.tools/dbc/?dbc=phase&build=4.3.4.15595
local phases = {
    KEZAN_CHAPTER_1 = 378,
    KEZAN_CHAPTER_2 = 379,
    KEZAN_CHAPTER_3 = 380,
    KEZAN_CHAPTER_4 = 381,
    KEZAN_CHAPTER_5 = 382,
    KEZAN_CHAPTER_6 = 383,
    KEZAN_CHAPTER_7 = 384,
}
Phasing.phases = phases

function Phasing.IsSpawnVisible(phase)
    local complete = Questie.db.char.complete

    if phase == phases.KEZAN_CHAPTER_6 and complete[14125] then
        return true
    end
    if phase == phases.KEZAN_CHAPTER_7 and complete[14126] then
        return true
    end
    if phase == phases.KEZAN_CHAPTER_1 then
        return true
    end
    return false
end

return Phasing
