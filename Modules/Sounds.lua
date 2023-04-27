---@class Sounds
local Sounds = QuestieLoader:CreateModule("Sounds")


local shouldPlayObjectiveSound = false

function Sounds.PlayObjectiveComplete()
    if (not shouldPlayObjectiveSound) then
        shouldPlayObjectiveSound = true
        C_Timer.After(0.5, function ()
            if shouldPlayObjectiveSound then
                PlaySoundFile("sound/interface/iquestupdate.ogg")
                shouldPlayObjectiveSound = false
            end
        end)
    end
end

function Sounds.PlayQuestComplete()
    shouldPlayObjectiveSound = false
    PlaySoundFile("sound/creature/peon/peonbuildingcomplete1.ogg")
end