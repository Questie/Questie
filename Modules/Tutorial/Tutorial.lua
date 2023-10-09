---@class Tutorial
---@field Initialize function
local Tutorial = QuestieLoader:CreateModule("Tutorial")

function Tutorial.Initialize()
    if Questie.IsWotlk and (not Questie.db.global.tutorialObjectiveTypeChosen) then
        Tutorial.CreateChooseObjectiveTypeFrame()
    end
end
