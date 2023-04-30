---@class Sounds
local Sounds = QuestieLoader:CreateModule("Sounds")

Sounds.QUEST_COMPLETE_SOUND_FILE = "sound/creature/peon/peonbuildingcomplete1.ogg"
Sounds.QUEST_OBJECTIVE_COMPLETE_SOUND_FILE = "sound/interface/iquestupdate.ogg"

local shouldPlayObjectiveSound = false

function Sounds.PlayObjectiveComplete()
    if (not Questie.db.char.soundOnObjectiveComplete) then
        return
    end

    if (not shouldPlayObjectiveSound) then
        shouldPlayObjectiveSound = true
        C_Timer.After(0.5, function ()
            if shouldPlayObjectiveSound then
                PlaySoundFile(Sounds.QUEST_OBJECTIVE_COMPLETE_SOUND_FILE, "Master")
                shouldPlayObjectiveSound = false
            end
        end)
    end
end

function Sounds.PlayQuestComplete()
    if (not Questie.db.char.soundOnQuestComplete) then
        return
    end

    shouldPlayObjectiveSound = false
    PlaySoundFile(Sounds.QUEST_COMPLETE_SOUND_FILE, "Master")
end