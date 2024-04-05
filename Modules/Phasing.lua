---@class Phasing
local Phasing = QuestieLoader:CreateModule("Phasing")

local _Phasing = {}

-- https://old.wow.tools/dbc/?dbc=phase&build=4.3.4.15595
local phases = {
    UNKNOWN = 169, -- Most Deepholm NPCs (and others) have this ID but are not phased
    KEZAN_CHAPTER_1 = 378,
    KEZAN_CHAPTER_2 = 379,
    KEZAN_CHAPTER_3 = 380,
    KEZAN_CHAPTER_4 = 381,
    KEZAN_CHAPTER_5 = 382,
    KEZAN_CHAPTER_6 = 383,
    KEZAN_CHAPTER_7 = 384,
}
Phasing.phases = phases

---@param phase number|nil @The phase belonging to a spawn of an NPC
---@return boolean @true if the spawn is visible, false otherwise
function Phasing.IsSpawnVisible(phase)
    if (not phase) or phase == phases.UNKNOWN then
        return true
    end

    local complete = Questie.db.char.complete

    if phase >= phases.KEZAN_CHAPTER_1 and phase <= phases.KEZAN_CHAPTER_7 then
        return _Phasing.Kezan(phase, complete)
    end
    return false
end

_Phasing.Kezan = function(phase, complete)
    if phase == phases.KEZAN_CHAPTER_1 and (complete[14125] or complete[14126]) then
        return false
    elseif phase == phases.KEZAN_CHAPTER_1 then
        return true
    end
    if phase == phases.KEZAN_CHAPTER_6 and complete[14125] then
        return true
    end
    if phase == phases.KEZAN_CHAPTER_7 and complete[14126] then
        return true
    end

    return false
end

return Phasing
