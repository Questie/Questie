---@class Tutorial
---@field Initialize function
local Tutorial = QuestieLoader:CreateModule("Tutorial")

local chooseObjectiveTypeFrame

function Tutorial.Initialize()
    chooseObjectiveTypeFrame = Tutorial.CreateChooseObjectiveTypeFrame()
end

-- /run Tutorial.ShowObjectiveTypeChooser()
function Tutorial.ShowObjectiveTypeChooser()
    chooseObjectiveTypeFrame:Show()
end

-- /run Tutorial.HideObjectiveTypeChooser()
function Tutorial.HideObjectiveTypeChooser()
    chooseObjectiveTypeFrame:Hide()
end
