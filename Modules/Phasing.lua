---@class Phasing
local Phasing = QuestieLoader:CreateModule("Phasing")

local _Phasing = {}

-- https://old.wow.tools/dbc/?dbc=phase&build=4.3.4.15595
local phases = {
    UNKNOWN = 169, -- Most Deepholm NPCs (and others) have this ID but are not phased
    LOST_ISLES_CHAPTER_1 = 170,
    LOST_ISLES_CHAPTER_2 = 171,

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

    if phase == phases.LOST_ISLES_CHAPTER_1 and (not complete[14303]) then
        return complete[14126]
    end

    if phase == phases.LOST_ISLES_CHAPTER_2 then
        return complete[14303]
    end

    if phase >= phases.KEZAN_CHAPTER_1 and phase <= phases.KEZAN_CHAPTER_7 then
        return _Phasing.Kezan(phase, complete)
    end
    return false
end

_Phasing.Kezan = function(phase, complete)
    local isChapter5Available = complete[14115]
    local isChapter6Available = complete[14121] and complete[14122] and complete[14123] and complete[14124]
    local isChapter7Available = complete[14125]
    if phase == phases.KEZAN_CHAPTER_1 and (isChapter5Available or isChapter6Available or isChapter7Available) then
        return false
    elseif phase == phases.KEZAN_CHAPTER_1 then
        return true
    end
    if phase == phases.KEZAN_CHAPTER_5 and isChapter5Available and (not (isChapter6Available or isChapter7Available)) then
        return true
    end
    if phase == phases.KEZAN_CHAPTER_6 and isChapter6Available and (not isChapter7Available) then
        return true
    end
    if phase == phases.KEZAN_CHAPTER_7 and isChapter7Available then
        return true
    end

    return false
end

return Phasing
