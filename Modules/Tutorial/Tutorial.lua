---@class Tutorial
---@field Initialize function
local Tutorial = QuestieLoader:CreateModule("Tutorial")

function Tutorial.Initialize()
    if (Questie.IsWotlk or Questie.IsCata) and GetCVar("questPOI") ~= nil and (not Questie.db.global.tutorialObjectiveTypeChosen) then
        Tutorial.CreateChooseObjectiveTypeFrame()
    end

    if Questie.IsSoD and (not Questie.db.profile.tutorialShowRunesDone) then
        Tutorial.ShowRunes()
    end
end
