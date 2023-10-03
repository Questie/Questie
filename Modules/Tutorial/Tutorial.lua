---@class Tutorial
local Tutorial = QuestieLoader:CreateModule("Tutorial")

-- /run Tutorial.ShowObjectiveTypeChooser()
function Tutorial.ShowObjectiveTypeChooser()
    QuestieTutorialChooseObjectiveType:Show()
end

-- /run Tutorial.HideObjectiveTypeChooser()
function Tutorial.HideObjectiveTypeChooser()
    QuestieTutorialChooseObjectiveType:Hide()
end
